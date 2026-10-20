#!/usr/bin/env bash
# CursorMemo — secure installer for Linux / macOS / WSL2 (Funapp distro).
#
# Version 2.0 — production-grade installer:
#   * Pinned upstream engine (ai-memory 3.1.1) — never a floating "latest".
#   * The upstream installer script is verified against its published SHA-256
#     checksum BEFORE it runs; the upstream script then verifies the binary
#     archive the same way. A mismatch aborts everything.
#   * Existing Cursor configuration is backed up before any change:
#       ~/.cursormemo/backups/<timestamp>/  (mcp.json, hooks.json)
#   * Idempotent: safe to re-run. Modes: install (default), --update,
#     --repair, --uninstall, --purge (with --uninstall), --dry-run.
#   * Uninstall NEVER deletes your memory data unless you pass --purge.
#
# Prefer to review before running? Download-then-review works fine:
#   curl -fsSL https://cursormemo.funapp.live/install.sh -o install.sh
#   less install.sh && bash install.sh
#
# Upstream project (MIT): https://github.com/akitaonrails/ai-memory
set -euo pipefail

CURSORMEMO_INSTALLER_VERSION="2.0.0"
PINNED_ENGINE_VERSION="3.1.1"
RELEASE_BASE="https://github.com/akitaonrails/ai-memory/releases/download/v${PINNED_ENGINE_VERSION}"
CURSOR_DIR="$HOME/.cursor"
BACKUP_ROOT="$HOME/.cursormemo/backups"

MODE="install"
PURGE=0
DRY_RUN=0
CLEANUP_DIR=""
trap 'rm -rf "$CLEANUP_DIR"' EXIT

for arg in "$@"; do
  case "$arg" in
    --update) MODE="update" ;;
    --repair) MODE="repair" ;;
    --uninstall) MODE="uninstall" ;;
    --purge) PURGE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --version) echo "CursorMemo installer ${CURSORMEMO_INSTALLER_VERSION} (engine pinned: ai-memory ${PINNED_ENGINE_VERSION})"; exit 0 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^#\{0,1\} \{0,1\}//' | head -30
      echo ""
      echo "Modes: (default) install | --update | --repair | --uninstall [--purge] | --dry-run | --version"
      exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

say()  { printf '%s\n' "$*"; }
step() { printf '\n[%s] %s\n' "$1" "$2"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY_RUN" = "1" ]; then printf '[dry-run] would run: %s\n' "$*"; else "$@"; fi; }

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}';
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}';
  else die "No SHA-256 tool found (need sha256sum or shasum)."; fi
}

engine_version() {
  if command -v ai-memory >/dev/null 2>&1; then ai-memory --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true; fi
}

find_data_dir() {
  # The engine's data directory. Probed locations, first existing wins.
  local d
  for d in "${AI_MEMORY_HOME:-}" "$HOME/.local/share/ai-memory" "$HOME/.ai-memory" "$HOME/.local/state/ai-memory"; do
    [ -n "$d" ] && [ -d "$d" ] && { printf '%s' "$d"; return 0; }
  done
  return 1
}

backup_cursor_config() {
  local ts dest f
  ts="$(date +%Y%m%d-%H%M%S)"
  dest="$BACKUP_ROOT/$ts"
  local made=0
  for f in mcp.json hooks.json; do
    if [ -f "$CURSOR_DIR/$f" ]; then
      if [ "$DRY_RUN" = "1" ]; then
        printf '[dry-run] would back up %s -> %s/\n' "$CURSOR_DIR/$f" "$dest"
      else
        mkdir -p "$dest" && cp -a "$CURSOR_DIR/$f" "$dest/$f" && made=1
      fi
    fi
  done
  if [ "$made" = "1" ]; then say "Backed up existing Cursor config to: $dest"; fi
}

install_engine() {
  local current; current="$(engine_version || true)"
  if [ "$current" = "$PINNED_ENGINE_VERSION" ] && [ "$MODE" != "update" ]; then
    say "ai-memory ${PINNED_ENGINE_VERSION} already installed — skipping download."
    return 0
  fi
  step "engine" "Downloading upstream installer for ai-memory v${PINNED_ENGINE_VERSION}..."
  local tmp; tmp="$(mktemp -d)"
  CLEANUP_DIR="$tmp"
  if [ "$DRY_RUN" = "1" ]; then
    say "[dry-run] would download ${RELEASE_BASE}/install.sh + install.sh.sha256, verify SHA-256, then run it with AI_MEMORY_VERSION=${PINNED_ENGINE_VERSION}"
    return 0
  fi
  curl -fsSL "$RELEASE_BASE/install.sh" -o "$tmp/install.sh" || die "Download failed: ${RELEASE_BASE}/install.sh"
  curl -fsSL "$RELEASE_BASE/install.sh.sha256" -o "$tmp/install.sh.sha256" || die "Download failed: checksum file"
  local expected actual
  expected="$(awk '{print $1}' "$tmp/install.sh.sha256")"
  actual="$(sha256_of "$tmp/install.sh")"
  [ -n "$expected" ] || die "Checksum file was empty — aborting."
  if [ "$expected" != "$actual" ]; then
    die "CHECKSUM MISMATCH for upstream install.sh (expected $expected, got $actual). Aborting — nothing was run."
  fi
  say "Checksum verified: install.sh SHA-256 OK."
  say "Installing engine (upstream script verifies the binary archive the same way)..."
  AI_MEMORY_VERSION="$PINNED_ENGINE_VERSION" sh "$tmp/install.sh"
  export PATH="$HOME/.local/bin:$PATH"
  command -v ai-memory >/dev/null 2>&1 || die "ai-memory is still not on PATH after install. Open a new terminal and re-run."
  local now; now="$(engine_version || true)"
  [ "$now" = "$PINNED_ENGINE_VERSION" ] || warn "Installed ai-memory version reports '$now', expected '${PINNED_ENGINE_VERSION}'."
}

wire_cursor() {
  step "setup" "Backing up existing Cursor configuration..."
  backup_cursor_config
  step "setup" "Wiring Cursor (MCP + hooks + skills, merged into existing config)..."
  if [ "$DRY_RUN" = "1" ]; then say "[dry-run] would run: ai-memory setup --agent cursor --yes"; return 0; fi
  local rc=0
  ai-memory setup --agent cursor --yes || rc=$?
  if grep -q 'ai-memory' "$CURSOR_DIR/mcp.json" 2>/dev/null; then
    if [ "$rc" != "0" ]; then
      warn "Setup reported an error (often: the background service could not start in this session), but Cursor IS wired. Restart Cursor to finish."
    fi
    say "Verified: ~/.cursor/mcp.json contains the ai-memory entry."
  else
    die "Setup did not wire Cursor (no ai-memory entry in ~/.cursor/mcp.json). Your previous config is in $BACKUP_ROOT — restore it, or re-run with --repair."
  fi
}

do_uninstall() {
  step "uninstall" "Backing up Cursor configuration first..."
  backup_cursor_config
  if command -v ai-memory >/dev/null 2>&1; then
    run ai-memory uninstall --apply || warn "Upstream uninstall reported an issue; continuing."
  else
    warn "ai-memory binary not found — nothing to unwire via the engine."
  fi
  local data_dir; data_dir="$(find_data_dir || true)"
  if [ -n "$data_dir" ]; then
    if [ "$PURGE" = "1" ]; then
      if [ "$DRY_RUN" = "1" ]; then
        say "[dry-run] would DELETE memory data at: $data_dir"
      else
        if [ -t 0 ]; then
          printf 'Really delete ALL memory data at %s ? Type YES to confirm: ' "$data_dir"
          local ans; read -r ans; [ "$ans" = "YES" ] || die "Purge not confirmed — memory preserved."
        fi
        rm -rf "$data_dir"
        say "Memory data deleted: $data_dir"
      fi
    else
      say "Memory data PRESERVED at: $data_dir"
      say "To delete it too, re-run: bash install.sh --uninstall --purge"
    fi
  else
    say "No engine data directory found — nothing to purge."
  fi
  say "Uninstall complete. Cursor config backups remain in $BACKUP_ROOT"
}

main() {
  say ""
  say "=== CursorMemo installer v${CURSORMEMO_INSTALLER_VERSION} (engine: ai-memory v${PINNED_ENGINE_VERSION}, pinned + checksum-verified) ==="

  step "preflight" "Checking environment..."
  local os arch
  os="$(uname -s)"; arch="$(uname -m)"
  case "$os" in
    Linux|Darwin) ;;
    *) die "Unsupported OS: $os. On Windows use install.ps1 instead." ;;
  esac
  case "$arch" in x86_64|amd64|aarch64|arm64) ;; *) die "Unsupported architecture: $arch" ;; esac
  say "Platform: $os / $arch"
  command -v curl >/dev/null 2>&1 || die "curl is required but not found."
  command -v tar  >/dev/null 2>&1 || die "tar is required but not found."
  if [ -d "$CURSOR_DIR" ] || command -v cursor >/dev/null 2>&1 || command -v cursor-cli >/dev/null 2>&1; then
    say "Cursor installation detected."
  else
    warn "Cursor was not detected on this machine. The engine installs globally and Cursor can be wired later with --repair."
  fi
  export PATH="$HOME/.local/bin:$PATH"

  case "$MODE" in
    install|update)
      install_engine
      wire_cursor
      ;;
    repair)
      command -v ai-memory >/dev/null 2>&1 || die "ai-memory is not installed — run the installer without --repair first."
      wire_cursor
      ;;
    uninstall)
      do_uninstall
      ;;
  esac

  if [ "$MODE" != "uninstall" ]; then
    say ""
    say "Done! Next steps:"
    say "  1. Restart Cursor (or toggle the ai-memory server off/on in Settings -> MCP)."
    say "  2. Open a project and ask the agent: \"What do you remember about this project?\""
    say ""
    say "Uninstall anytime:  bash install.sh --uninstall   (your memory is kept)"
  fi
  say ""
}

main

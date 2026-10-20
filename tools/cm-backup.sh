#!/usr/bin/env bash
# CursorMemo backup wrapper — a thin, honest layer over `ai-memory backup`.
#
# The engine already snapshots wiki/ + db/ + config.toml into a .tar.gz.
# This wrapper adds what Phase 7 asks for around it:
#   * timestamped backup files with a SHA-256 sidecar (integrity)
#   * `verify`  — checksum + tar integrity + page count, without restoring
#   * `preview` — list the pages inside a backup, without restoring
#   * `restore` — verify first, then restore, then print the one manual step
#                 the engine requires afterwards (a fresh auth token —
#                 credentials are deliberately NOT inside the backup)
#
# Usage:
#   tools/cm-backup.sh backup  [backup-dir]
#   tools/cm-backup.sh verify  <backup.tar.gz>
#   tools/cm-backup.sh preview <backup.tar.gz>
#   tools/cm-backup.sh restore <backup.tar.gz> [--force]
#
# Env: AI_MEMORY_DATA_DIR or --data-dir via AI_MEMORY_HOME conventions are
# honoured by the engine itself; this wrapper uses the default data dir.
set -euo pipefail

sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'; else shasum -a 256 "$1" | awk '{print $1}'; fi }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
command -v ai-memory >/dev/null 2>&1 || die "ai-memory not found on PATH. Install CursorMemo first."

# `ai-memory backup` talks to the engine's local API, so the server must be
# up. On a normal install it runs as a service; if it is not reachable we
# start it just for this command and stop it again afterwards.
PORT="${CM_PORT:-49374}"
STARTED_PID=""
server_up() { curl -s -o /dev/null --max-time 2 "http://127.0.0.1:$PORT/" 2>/dev/null; }
ensure_server() {
  if server_up; then return 0; fi
  echo "ai-memory server not reachable — starting it temporarily..."
  nohup ai-memory serve --transport http >/tmp/cm-backup-server.log 2>&1 &
  STARTED_PID=$!
  local i
  for i in $(seq 1 20); do server_up && return 0; sleep 1; done
  die "Server did not come up (see /tmp/cm-backup-server.log)."
}
cleanup() { if [ -n "$STARTED_PID" ]; then kill "$STARTED_PID" 2>/dev/null || true; fi; }
trap cleanup EXIT

cmd="${1:-}"; shift || true

case "$cmd" in
  backup)
    dir="${1:-$HOME/.cursormemo/backups}"
    mkdir -p "$dir"
    ts="$(date +%Y%m%d-%H%M%S)"
    out="$dir/cursormemo-backup-$ts.tar.gz"
    ensure_server
    ai-memory backup --to "$out"
    printf '%s  %s\n' "$(sha "$out")" "$(basename "$out")" > "$out.sha256"
    pages="$(tar -tzf "$out" | grep -c '^wiki/.*\.md$' || true)"
    echo "Backup:  $out"
    echo "SHA-256: $out.sha256"
    echo "Pages inside: $pages (wiki .md files)"
    echo "Keep both files together. Verify anytime: tools/cm-backup.sh verify \"$out\""
    ;;
  verify)
    f="${1:-}"; [ -n "$f" ] && [ -f "$f" ] || die "usage: cm-backup.sh verify <backup.tar.gz>"
    if [ -f "$f.sha256" ]; then
      expected="$(awk '{print $1}' "$f.sha256")"; actual="$(sha "$f")"
      [ "$expected" = "$actual" ] || die "SHA-256 MISMATCH — backup is corrupted or was modified."
      echo "SHA-256 OK."
    else
      echo "WARNING: no .sha256 sidecar found — integrity is NOT verified, only tar readability."
    fi
    tar -tzf "$f" >/dev/null 2>&1 || die "Tarball is unreadable/truncated."
    echo "Tarball readable. Pages inside: $(tar -tzf "$f" | grep -c '^wiki/.*\.md$' || true)"
    ;;
  preview)
    f="${1:-}"; [ -n "$f" ] && [ -f "$f" ] || die "usage: cm-backup.sh preview <backup.tar.gz>"
    echo "Pages in $f:"
    tar -tzf "$f" | grep '^wiki/.*\.md$' | while IFS= read -r line; do
      rel="${line#wiki/}"; rel="${rel#*/}"
      case "$rel" in */*) rel="${rel#*/}" ;; esac
      printf '  %s\n' "$rel"
    done | sort
    echo "Total .md files: $(tar -tzf "$f" | grep -c '^wiki/.*\.md$' || true)"
    ;;
  restore)
    f="${1:-}"; [ -n "$f" ] && [ -f "$f" ] || die "usage: cm-backup.sh restore <backup.tar.gz> [--force]"
    "$0" verify "$f"
    extra=""; [ "${2:-}" = "--force" ] && extra="--force"
    # shellcheck disable=SC2086
    ai-memory restore --from "$f" $extra
    echo ""
    echo "Restore complete. ONE manual step remains:"
    echo "  Backups deliberately exclude credentials, so on a fresh data dir run:"
    echo "    ai-memory auth enable"
    echo "  then restart the ai-memory service / Cursor."
    ;;
  *) echo "usage: cm-backup.sh {backup|verify|preview|restore} ..." >&2; exit 2 ;;
esac

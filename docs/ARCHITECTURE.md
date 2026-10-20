# CursorMemo — Architecture

_Version: 2.0 milestone 1 · Engine: ai-memory v3.1.1 (pinned) · Upstream: https://github.com/akitaonrails/ai-memory (MIT)_

## The ownership boundary (read this first)

CursorMemo is a **distribution**, not a fork. The boundary is deliberate and is the
core design decision of the project:

| Layer | Owned by | Contents |
|---|---|---|
| Engine | Upstream ai-memory (akitaonrails, MIT) | Rust binary: capture hooks, sanitizer, consolidation, markdown wiki store, SQLite FTS5 index, MCP server, local web dashboard |
| Distribution | CursorMemo (Funapp, MIT) | Pinned + checksum-verified installers, Cursor-first presets, Burmese/English documentation & website, backup/rollback wrapper around Cursor config |

CursorMemo never patches the engine binary. All integration goes through the
engine's public surface: its release artifacts, its installer scripts, and its
CLI (`setup`, `uninstall`, `upgrade`). This keeps upgrades a version-pin change,
not a merge.

## Install flow (v2 installer)

```
user runs install.sh / install.ps1
  → detect OS + architecture (linux/macos × x86_64/aarch64, windows-x86_64)
  → preflight: curl/tar + sha256 tool present; Cursor config dir noted
  → download upstream install script for the PINNED release (v3.1.1)
  → verify it against the release's published .sha256 file — abort on mismatch
  → run it with AI_MEMORY_VERSION=3.1.1
       upstream script downloads the platform archive, verifies ITS .sha256,
       unpacks to ~/.local/lib/ai-memory, links ~/.local/bin/ai-memory
  → back up existing Cursor config to ~/.cursormemo/backups/<timestamp>/
       (~/.cursor/mcp.json, ~/.cursor/hooks.json)
  → ai-memory setup --agent cursor --yes     (MCP + hooks + skills, merged)
  → verify: binary version == pinned; mcp.json contains an ai-memory entry
```

## Runtime data flow (owned by upstream; verified at integration level)

1. **Capture** — Cursor lifecycle hooks POST session events to the local
   ai-memory server (loopback `127.0.0.1:49374`, bearer-token authenticated).
2. **Sanitize** — events pass a secret-redaction stage before persistence.
3. **Consolidate** — at session end, observations become Markdown wiki pages
   (the canonical store, git-versioned) scoped per project by directory path.
4. **Recall** — the next session receives a bounded handoff brief; deeper
   detail is fetched on demand through MCP tools backed by a SQLite FTS5
   index (derived from the Markdown store, rebuildable).

## Files CursorMemo touches

- `~/.local/bin/ai-memory`, `~/.local/lib/ai-memory/` — engine (via upstream installer)
- `~/.cursor/mcp.json`, `~/.cursor/hooks.json` — written by `ai-memory setup` (merged, not replaced)
- `~/.agents/skills/` — ai-memory agent skills (via upstream setup)
- `~/.cursormemo/backups/` — CursorMemo config backups (this project)
- Engine data directory — created/managed by the engine; never deleted by
  CursorMemo uninstall unless the user passes `--purge` explicitly.

## Design principles

Local-first · no telemetry · no API key in the default path · pinned versions ·
checksums before execution · backups before mutation · idempotent operations ·
memory data is user data — never silently deleted.

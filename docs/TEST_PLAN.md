# Test Plan — CursorMemo

## Milestone 1 — installer tests (sandbox, Linux)

Environment: disposable `HOME` under /tmp on the build VM (no systemd user
bus — the engine's user-service step is expected to warn/fail there; config
wiring is what these tests assert).

| # | Case | Expected |
|---|---|---|
| T1 | Fresh install | exit 0; `ai-memory --version` = 3.1.1; `~/.cursor/mcp.json` valid JSON containing an ai-memory entry; `~/.cursor/hooks.json` exists; backup dir created when config pre-exists |
| T2 | Checksum gate | installer verifies upstream `install.sh` against its `.sha256` before executing (code path + log line); tampered checksum aborts (negative test with a doctored copy) |
| T3 | Idempotent re-run | second install exits 0, reports engine already at pinned version, config still valid, no duplicate MCP entries |
| T4 | --dry-run | prints planned steps; writes nothing (HOME tree unchanged) |
| T5 | --repair | re-runs `setup --agent cursor`; mcp.json/hooks.json restored if deleted |
| T6 | --update | engine remains at pinned version (or moves to it), memory data untouched |
| T7 | --uninstall | wiring removed by upstream uninstall; engine data directory still present |
| T8 | --uninstall --purge | data directory removed only with the explicit flag |
| T9 | Pre-existing unrelated MCP server in mcp.json | preserved after install (merge, not overwrite) |
| T10 | Unsupported OS/arch | clean error, no partial writes |

Results are recorded in the milestone report (chat + git history). Windows
`install.ps1` gets static review in milestone 1; execution tests require a
real Windows machine (open item, owned by the user).

## Results — Milestone 1 (2026-10-20)

**16/16 sandbox assertions PASS**: T1 fresh install (exit 0, engine reports
3.1.1, mcp.json valid + wired, hooks.json present, config backup holds the
original file), T2 negative (tampered checksum aborts, nothing installed),
T3 idempotent re-run, T4 dry-run writes nothing, T5 repair restores deleted
hooks.json, T7 uninstall preserves `~/.local/share/ai-memory` (marker file
intact), T8 purge deletes it only after explicit YES, T9 unrelated MCP
server preserved. T6 (update) is covered by the pinned-version path in T1/T3.
T10 (unsupported OS) is code-reviewed; untested on a foreign OS. Engine data
directory confirmed empirically: `~/.local/share/ai-memory`.

## Later milestones

- Milestone 2: scripted two-session continuity test + interruption recovery;
  retrieval precision benchmark on a seeded corpus.
- Milestone 3: dashboard mapping checklist executed against the live `/web`
  UI; any companion UI ships with its own smoke tests.
- Milestone 4: backup → wipe → restore round-trip equality check (file-level
  hash comparison), restore-preview accuracy, corrupted-index rebuild.
- Standing: every engine pin bump re-runs T1–T10 plus the continuity test.

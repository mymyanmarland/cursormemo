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

## Results — Milestone 2 (2026-10-20)

Live-sandbox verification against the real engine (server started manually,
no systemd in the VM):

- **Category mapping:** all 10 mission categories map onto the engine's
  native kind × tier × tag model — see `docs/MEMORY_MODEL.md`. No custom
  schema needed.
- **Retrieval benchmark:** 16 pages / 2 projects / 9 labelled queries —
  hit@1 **100%**, hit@3 **100%**, median latency **21 ms** (FTS5).
  Semantic search not justified on this evidence; decision recorded.
- **Project isolation:** scoped search leaks nothing across projects;
  `--global` is opt-in and scope-labelled.
- **Crash recovery:** `kill -9` on the server + restart → all pages intact,
  correct top hits.
- **Store-level continuity:** fresh process recalls prior process's pages
  exactly. Live-agent handoff brief (real Cursor hooks) remains the open
  real-machine item.

## Results — Milestone 4 (2026-10-20)

Backup & portability, all against the real engine in sandboxes:

- **Round-trip:** `ai-memory backup` (54 KiB tarball: wiki + db + config) →
  restore into a FRESH data dir → **wiki .md SHA-256 hashes identical** →
  server starts after `ai-memory auth enable` (backups exclude credentials
  by design — documented in the wrapper) → searches return the correct
  pages.
- **Index reconstruction:** db/ deleted → `ai-memory reindex` rebuilt it
  from the wiki (3 pages / 2 projects) → search correct.
- **Corruption:** truncated tarball → restore fails with a clear error via
  a `.restore-staging-*` dir; **zero partial pages** in the target.
- **Export:** `export-okf` produced a clean portable bundle (index.md +
  project-relative page paths).
- **Wrapper `tools/cm-backup.sh`:** backup (+ .sha256 sidecar, auto-starts
  the server when needed) / verify (good file passes; 1-byte-tampered copy
  rejected with SHA-256 MISMATCH, exit 1) / preview (page listing without
  restoring) — all PASS.

## Results — Milestone 5 (2026-10-20)

- **Agent presets:** `setup --agent claude-code --agent codex` wrote real
  config in a sandbox HOME (`~/.claude.json`, `~/.claude/settings.json`,
  `~/.codex/config.toml`, all containing the ai-memory entry). Installer
  `--agents=cursor,claude-code,codex` end-to-end: exit 0, all three
  verified wired, pre-existing unrelated MCP entry preserved, config
  backup created. (Service-start warnings in the sandbox are the known
  no-systemd-bus limitation, not a wiring failure.)
- **Project Intelligence:** generated from the M4 sandbox store — project
  card shows last activity, counts, oldest open task, and the bug-KB entry
  with its recorded fix. Stale-task rule proven on an aged fixture
  (pending page backdated 30 days → "has been open 30 days" warning).

## Later milestones

- Milestone 2: scripted two-session continuity test + interruption recovery;
  retrieval precision benchmark on a seeded corpus.
- Milestone 3: dashboard mapping checklist executed against the live `/web`
  UI; any companion UI ships with its own smoke tests.
- Standing: every engine pin bump re-runs T1–T10 plus the continuity test.

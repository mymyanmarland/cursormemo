# Feature Gap Analysis — CursorMemo 2.0

Audit date: 2026-10-20. Method: read the CursorMemo v1 installers, fetched and
read the upstream v3.1.1 installer source, listed v3.1.1 release assets via the
GitHub API, and re-checked the sandbox integration test (setup writes
`~/.cursor/mcp.json`, `~/.cursor/hooks.json`, 6 agent skills).

Legend: **EXISTS** = provided by upstream and verified at integration level ·
**PARTIAL** = exists but with gaps CursorMemo must close · **VERIFY** = claimed
or plausible upstream, not yet re-verified by us · **MISSING** = not present.

## Phase 1 — Architecture audit & security

| Capability | Status | Notes |
|---|---|---|
| OS/arch detection | EXISTS | Upstream installer maps uname → target tarball. |
| Binary checksum verification | EXISTS | Upstream installer verifies archive vs published `.sha256`; aborts on mismatch. |
| Pinned version install | PARTIAL → fixed in v2 | v1 used `releases/latest` and unverified piping. v2 pins v3.1.1 and verifies the installer script's own `.sha256` before running it. |
| Cursor config backup before setup | MISSING → fixed in v2 | v2 copies `mcp.json`/`hooks.json` to `~/.cursormemo/backups/<ts>/`. |
| Config merge (no overwrite of other MCP servers) | EXISTS | Upstream `setup` merges; verified in sandbox (adds its entry, keeps the file valid JSON). |
| Idempotent re-install | EXISTS | Upstream installer detects its own symlink; `setup` is re-runnable (repair path). |
| Rollback after failure | PARTIAL | v2 restores config backups on setup failure; engine itself is versioned under `~/.local/lib/ai-memory`. Full binary rollback = re-run installer with older pin. |
| Uninstall that preserves memory | EXISTS + v2 guard | `ai-memory uninstall --apply` removes wiring; v2 never deletes the data dir unless `--purge`. |
| Download-then-review install option | PARTIAL → v2 | Documented in README; installer is a readable script by design. |

## Phase 2 — Intelligent long-term memory

| Capability | Status | Notes |
|---|---|---|
| Capture → sanitize → consolidate → recall pipeline | EXISTS | Upstream core; zero-LLM by default. |
| Per-project isolation | EXISTS | Scoped by project directory path; `.ai-memory.toml` for monorepo routing. |
| Structured categories (decisions, bugs, failed approaches…) | VERIFY | Consolidation produces typed observations upstream; the exact category taxonomy of the mission brief must be mapped against the engine's wiki schema before CursorMemo claims it. Milestone 2 task. |
| Duplicate detection / importance scoring / lifecycle | VERIFY | Engine has consolidation logic; scoring specifics unverified by us. |
| Hybrid/semantic search | VERIFY | FTS5 is verified. Semantic retrieval is optional upstream capability — benchmark before enabling (mission rule). |

## Phase 3 — Session continuity

| Capability | Status | Notes |
|---|---|---|
| Automatic handoff brief at session start | EXISTS | Verified conceptually + sandbox wiring; real-Cursor behaviour needs the owner's Windows machine (still the open e2e item). |
| Recovery from interrupted sessions | VERIFY | Engine design (session-end consolidation + durable Markdown) suggests resilience; crash-path test is in TEST_PLAN. |

## Phase 4 — Dashboard

| Capability | Status | Notes |
|---|---|---|
| Local web dashboard | EXISTS | Engine serves `/web` on loopback with token auth. |
| Overview / projects / memory explorer / timeline / tasks / decisions as specified | VERIFY → likely PARTIAL | The mission's dashboard spec must be mapped page-by-page against the upstream dashboard before building anything. **Do not build a duplicate dashboard** until this mapping exists. Milestone 3 task. |

## Phases 5–7 — Context optimization, project intelligence, backup

| Capability | Status | Notes |
|---|---|---|
| Bounded context injection (handoff brief, on-demand recall) | EXISTS | Core upstream design. |
| Markdown as canonical, portable store; index rebuildable | EXISTS | By upstream design. |
| Backup/export/import UX, restore preview, scheduled backups | PARTIAL/MISSING | Store is plain files (trivially backable), but productised backup flows are a CursorMemo-side opportunity (wrapper CLI) — P2. |
| Project intelligence (health warnings, bug KB views) | MISSING (as product surface) | Data exists in the wiki; views depend on the Phase 4 mapping. P2. |

## Phase 8 — Website & DX

| Capability | Status | Notes |
|---|---|---|
| Bilingual site, install guide, tech explanation, FAQ | EXISTS | Live at cursormemo.funapp.live. |
| Version info / tested-platform matrix / upstream-vs-CursorMemo attribution | PARTIAL → v2 | Site updated with pinned engine version + tested status in milestone 1; full docs set (this folder) is new. |
| Troubleshooting / repair / update / uninstall guides | PARTIAL → v2 | Installer modes implemented; website guides land with milestone 1 docs. |

## Phase 9 — QA

See `docs/TEST_PLAN.md`. Sandbox installer tests are automated in milestone 1;
CI and cross-platform manual Cursor verification remain open (Windows e2e is
the owner's machine — cannot be faked from CI).

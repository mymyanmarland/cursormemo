# Implementation Plan — CursorMemo 2.0

Priorities follow the mission brief: P0 foundation → P1 core product → P2
advanced. Every milestone ends with tests + a report; nothing is claimed
complete without verification.

## Milestone 1 — P0: Audit, plan, secure installer ✅ (2026-10-20)

- [x] Audit current installers; read upstream v3.1.1 installer source; list
      release assets/checksums via GitHub API.
- [x] `docs/ARCHITECTURE.md`, `docs/FEATURE_GAP_ANALYSIS.md`,
      `docs/SECURITY.md`, `docs/IMPLEMENTATION_PLAN.md`, `docs/TEST_PLAN.md`.
- [x] Secure installer v2 (bash): pinned engine v3.1.1, checksum-verified
      bootstrap, OS/arch + dependency preflight, Cursor detection, config
      backup, modes: install / --update / --repair / --uninstall / --purge /
      --dry-run; memory preserved on uninstall by default.
- [x] `install.ps1` v2 mirroring the same flow for Windows.
- [x] Sandbox test matrix (fresh / rerun / repair / dry-run / uninstall /
      purge) — **16/16 assertions PASS**, see TEST_PLAN results.
- [x] Website: version + pinning info; README: installer modes + security.

Exit criteria: installer tests pass in a clean sandbox HOME; no regression to
the v1 happy path; docs shipped in-repo.

## Milestone 2 — P0/P1: Memory model mapping + continuity verification ✅ (2026-10-20)

- [x] Category mapping — all 10 mission categories map onto the engine's
      native kind × tier × tag model; no custom schema. `docs/MEMORY_MODEL.md`.
- [x] Scripted continuity test — cross-process capture → recall verified;
      **crash case included** (`kill -9` + restart, store intact).
- [x] Retrieval benchmark — 16 pages / 9 labelled queries: **hit@1 100%,
      median 21 ms**. Semantic search **rejected for now** on this evidence
      (embeddings exist upstream; revisit at 1k+ pages).
- [x] Bonus audit find: upstream already ships `backup` / `restore` /
      `export-okf` / `reindex` — milestone 4 rescoped to verification +
      thin wrapper.

## Milestone 3 — P1: Dashboard mapping + minimal companion ✅ (2026-10-20)

- [x] Page-by-page map of the upstream `/web` dashboard against Phase 4 —
      `docs/DASHBOARD_MAP.md` (two independent live crawls agree).
- [x] Gaps confirmed narrow: Timeline, Task view, Decision Log, Myanmar
      localization. Dashboard itself is deliberately read-only; no fork.
- [x] Companion built: `tools/cm-views.py` — bilingual static views
      (Tasks / Decision Log / Timeline + counts) generated from the local
      wiki, recorded data only. Verified on sandbox data; sample live.
- [ ] Deferred: Overview+ live status (last capture, hook/MCP status) via
      `/api/v1`/CLI — later milestone.

## Milestone 4 — P1/P2: Backup & portability ✅ (2026-10-20)

- [x] Round-trip verified end-to-end (fresh-dir restore, hash-identical
      wiki, search-correct) — see TEST_PLAN results.
- [x] Index rebuild from canonical files verified (`reindex` after db
      deletion). Corrupted-backup failure mode verified clean.
- [x] Wrapper shipped: `tools/cm-backup.sh` (backup/verify/preview/restore
      with sha256 sidecar + the documented `auth enable` step).
- [ ] Selective restore — engine restores whole snapshots; page-level
      recovery already exists via git checkpoints + `restore-page`.
      Scheduled backups = run the wrapper from cron/Task Scheduler.

## Milestone 5 — P2: Project intelligence + more agents

- Project status / bug-KB / health views from recorded memories (facts vs
  suggestions labelled).
- Additional MCP-agent presets (Claude Code, Codex…) shipped only after the
  same sandbox + real-machine verification Cursor received.

## Standing rules

- Engine stays pinned; a pin bump is its own tested milestone.
- No paid APIs or cloud dependencies in the default install. Ever.
- Burmese-first docs/site; English always available.
- Windows real-machine e2e remains an explicit open item until the owner runs
  it — CI does not substitute for it.

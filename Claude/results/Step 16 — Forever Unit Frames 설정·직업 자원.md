# Step 16 — Forever Unit Frames 설정·직업 자원 (Phase 6)

Recorded: 2026-11-18 15:34:25 +0900

## Done
- A2: DevilForever_FUFDefaults (raid only, per character, ≥20 s after first PEW, out of combat, /fuf raid off via FUF handler, post-check), registry FUF entry (15 frames, positions/sizes) + FUFDefaults SV, phase6.md, appearance-6.md, tests fufdefaults 16/16, core 48/48, ZIP rebuilt.
- Review B 1 pass: critical 0 · major 1 (party switch account-wide vs per-character record) · minor 5 → design change (raid only) + minors 2, 4 → master check.
- Class resources table in work_log; mismatch: warlock soul shards not shown by FUF (decision (가) leave, final report).

## Basis
master read review report, TRIAGE_phase6.md decisions, FUFDefaults.lua party grep (0), tests rerun; A2 read ranges in Claude/results/handoffs/phase6/iter_1/work_log-a2.md (Commands.lua 1–143, Storage.lua, UnitProfiles.lua, Boot.lua 1–93, Settings.lua).

## Files
Collection/AddOns/DevilForever_FUFDefaults/**, registry_extra.json, Registry.lua, Collection/tests/fufdefaults/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-6.md, phase6.md, outputs/collection/DevilForever-collection.zip

## Gates
fufdefaults 16/16 (master rerun); core 48/48; luacheck failed=0; genregistry --check up to date; build sha256 bc15c185…3036

## Next
Phase 7 Step 17 — Quartz 기본 설정·중복 시전바 정리

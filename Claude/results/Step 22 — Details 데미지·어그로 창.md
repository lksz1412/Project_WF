# Step 22 — Details 데미지·어그로 창 (Phase 10)

Recorded: 2026-11-18 17:57:59 +0900

## Done
Details 20261109 + Details_TinyThreat kept as-is (no Core defaults file: Details rewrites its SVs from memory at logout). Registry entry for Details added. A DevilForever_DetailsSetup bridge was built, then dropped under R101 (restore point 0392a27); opening window 2 with Tiny Threat is a one-time manual step written in phase10.md item 2 and appearance-10.md. Codex briefs phase10.md / appearance-10.md written; ZIP rebuilt, hash updated in 20 briefs.

## Basis
Read: settings-phase brief template; plan rows 222-223; A2 work_log Claude/results/handoffs/phase10/iter_1/work_log-a2.md (Details window_main.lua 5370-5440, slash.lua 40-60, locales enUS/koKR, TinyThreat enUS.lua 7). Triage = handoffs/phase10/TRIAGE_phase10.md. Compaction recovery reads: .claude/CLAUDE.md (system-loaded), feedback_communication_style.md 1-88, feedback_flow_interruption.md 1-65, both method skills reloaded, session jsonl queue scan (all user messages through R108 in ledgers). Impact map: A2 work_log 'DQ1 apply' (bridge folder+tests removed, registry_extra entry removed, Registry.lua regen, core test check flipped, briefs hash/lists).

## Files
Collection/codex-briefs/phase10.md, Collection/codex-briefs/appearance-10.md, Collection/AddOns/!DevilForever_Core/registry_extra.json, Registry.lua, Collection/tests/core/run.py, 18 earlier briefs (hash), outputs/collection/DevilForever-collection.zip; removed DevilForever_DetailsSetup + tests/detailssetup

## Gates
master re-run: core tests 61/61 pass; genregistry --check up to date (50995 bytes); AddOns list without DetailsSetup; new hash d0210532... in 20 briefs; DetailsSetup mentions in briefs/AddOns 0; ZIP sha256 d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820. A2 luacheck 203/0, tocdeps unresolved 0.

## Next
Phase 14 (Step 26) nameplates Codex brief.

# Step 17 — Quartz 시전바 정리 (Phase 7)

Recorded: 2026-11-18 15:54:49 +0900

## Done
- A2: DevilForever_Castbars (hooksecurefunc on FUF castbar SetShown/Show, hide while Quartz module enabled; retry at PLAYER_REGEN_ENABLED for combat logins; post-hook Quartz3 Enable/DisableModule), registry Quartz entry (6 frames), phase7.md, appearance-7.md, castbars tests 16/16, ZIP rebuilt. No Quartz defaults file (Quartz defaults already fit).
- Review B 1 pass (rerun after container restart): critical 0 · major 1 (combat login never hooked) · minor 3 → M1 + minor 1 fixed → master check.

## Basis
master read review report, triage; tests rerun. A2 read ranges in Claude/results/handoffs/phase7/iter_1/work_log-a2.md (Quartz modules, CastBarTemplate, FUF Castbar/Shape/Single/Init).

## Files
Collection/AddOns/DevilForever_Castbars/**, registry_extra.json, Registry.lua, Collection/tests/castbars/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-7.md, phase7.md, outputs/collection/DevilForever-collection.zip

## Gates
castbars 16/16 (master rerun); core 48/48; luacheck failed=0; tocdeps unresolved 0; build sha256 2604ad70…01af

## Next
Phase 8 Step 18 — Hekili 원천 정독·직업 지원표·갈래 판정

# Step 40b — Defaults and defects after merging Codex 0.1.4 (Phase 25)

Recorded: 2026-11-20 09:28:40 +0900

## Done
- R118/R119: party + raid = Grid2; new Core module `Party.lua` records the party owner on the shared unit-frame profile (CoreDB party.owner["<PitBull4|ForeverUnitFrames>/<profile>"]), set by a fresh install (both sides new) or `/dfp party grid2|unitframes`; every login reconciles ownership only (not exact values); Grid2 never written ahead of the unit side (FUF confirmed by read-back); one chat line per session for automatic writes; install notes cover new installs and upgrades.
- R123-14: healer indicators come from Grid2's first-start templates (Classic/Modern/Blizzard map dispel border, range alpha, incoming heals) — no values written.
- Audit M1: SexyMap appearance as per-character Presets fragment (profileKey), merge-only at PLAYER_ENTERING_WORLD, never replaces a "global" choice or creates partial core; kept/skipped → one notice with /dfp preset hint.
- R122-11: Probe/SessionProbe and DevilForever_UIReviewDB out of Skin_Nameplates load.
- Prat defaults file removed (not loaded); package manifests mark ExperienceForever/SexyMap "modified".
- Deferred to 40c: PitBull4 targetpet (R120) and shaman-only Totems (R123-15) — need fork code.

## Basis
Brief Claude/results/handoffs/phase25/brief-40b.md; A2 work_log iter_2/work_log-a2.md (fix 1–4, impact maps); B audit iter_2/audit_log-40b.md (review + 4 re-checks); triage TRIAGE_phase25.md. Master verified quotes per round (listed in audit log). Read: phase25 detail plan, triage lines, quoted code lines.

## Files
Core: Party.lua (new), TOC, Commands.lua, Presets.lua, Profiles.lua, Registry.lua, Defaults/Grid2.lua, Defaults/PitBull4.lua, Defaults/SexyMap.lua, Defaults/Prat-3.0.lua (deleted); FUFDefaults.lua (header line); Skin_Nameplates TOC; install notes ×4; feature-map.md; Review/0.1.4/packages/*/manifest.json; tests firststart (new, 22).

## Gates
core 107/108 (genregistry_output_matches_file → 40d), firststart 22/22, fufdefaults 22/22, Codex runner 8/8 (195), luacheck 0 fail, pitbull4 5/6 (LICENSE line endings → 40d).

## Next
Step 40c runtime fixes (PitBull4 fork M1–M5, targetpet, shaman Totems, Core allocations, CastBar ticker).

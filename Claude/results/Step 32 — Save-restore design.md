# Step 32 — Save/restore design (Phase 20)

## Done
A1 wrote `Claude/results/handoffs/phase20/design-32.md` (467 lines, §0–11): ProfileManager coverage (profile switch only; 14 of 27 registry SVs switchable; keybinds/game settings fully covered on user action; no snapshots, no registry scope, no spec switch, no layout presets), gap list, placement, data model (load-time write after /reload, snapshots in DevilForever_ProfilesDB, registry `restore`/`shape` fields, Defaults:Suppress), layout preset layer (token < registry default < preset < user/AI edit) and per-addon preset fragments (route for EF global values), /dfp commands, safety vs Test Plan 428, tests T1–T28, file list. Master decisions in DECISIONS_32.md (module in Core; PM kept for keys/game settings; Core contract wording updated).

## Basis
[Phase 20 start — master plan re-read 1–549.] A1 read ranges: work_log-a1.md. Master triangulated PM Providers.lua:593–600 and Presets.lua:125–130.

## Files
design-32.md, DECISIONS_32.md, iter_1/work_log-a1.md

## Gates
Design complete; unverified items listed (handler order, Details partial restore, GetAddOnMetadata, snapshot size, talent-group event).

## Next
Step 33 implementation (A2) + B 3 rounds.

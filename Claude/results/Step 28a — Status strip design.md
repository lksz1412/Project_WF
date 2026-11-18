# Step 28a — Status strip design (Phase 16)

## Done
A1 analyst wrote `Claude/results/handoffs/phase16/design-28a.md` (496 lines): five items (gold, bags, durability, clock, latency, fps) with Forever API evidence table, 1 s shared ticker + events, taint rules, Codex interface (frame + six FontStrings, small API, registry entry), saved settings, exclusions, 13 test areas, file list for 28b. Master decisions in `DECISIONS_28a.md` (separate addon DevilForever_StatusStrip; local 24 h clock on; /dfstatus; no warning colour/tooltip/ammo).

## Basis
[Phase 16 start — master plan re-read 1–549.] A1 read ranges: design §10 + work_log-a1.md. Master triangulated Core.lua:3 and Defaults/SexyMap.lua:70.

## Files
design-28a.md, DECISIONS_28a.md, iter_1/work_log-a1.md

## Gates
Design complete; every API row cites file:line or 확인 필요 (PLAYER_EQUIPMENT_CHANGED firing, BAG_CONTAINER_UPDATE, timeMgr CVars, INVSLOT globals inferred).

## Next
Step 28b implementation by A2 coder.

# Step 18 — Hekili support table and branch verdict (Phase 8)

Recorded: 2026-11-18 16:08:45 +0900

## Done
- A1 wrote `Collection/data/hekili-support.{md,json}`: 28 specs; supported 24, unsupported 4 (holy paladin, holy priest, resto shaman, resto druid — Kits.lua:141). ㉠ class-kit aura/proc/CD data present for all 28 (inherited per spec). ㉡ no EventAlert-style alert in Hekili (no PlaySound, glow only on recommended ability, displays = recommendation queues). Branch verdict: branch 2 for all 28.
- New fact (master-confirmed): the Forever client marks aura data "secret in combat; errors when tainted" (Hekili Game/API/Facade.lua:725–739) and has Blizzard's Cooldown Manager viewers (EssentialCooldownViewer, UtilityCooldownViewer, BuffIconCooldownViewer, BuffBarCooldownViewer — Hekili CooldownViewer.lua:1–30 reads them).

## Basis
- Master read Facade.lua 725–739, CooldownViewer.lua 1–30, A1 report. A1 read ranges: Claude/results/handoffs/phase8/iter_1/work_log-a1.md.

## Gates
- 28/28 specs covered (python check vs classes.json); 290 cited lines checked by A1 script (5 label lines). Review: master check (R87).

## Next
- User decision: status alerts/CD via the client's built-in Cooldown Manager vs our DevilForever_Combat module (combat secrecy limits addon aura reads). Then Step 19.

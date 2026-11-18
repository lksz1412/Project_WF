# Step 19 — Hekili display defaults (Phase 8)

Recorded: 2026-11-18 16:52:59 +0900

## Done
- A2: Defaults/Hekili.lua (AceDB HekiliDB, shared profile "Default", barGlow.enabled = true — recommended ability's action button glows; everything else = Hekili defaults: only Primary display, healer specs show nothing), registry Hekili entry (6 display frames, positions + primary size), core tests 50/50, ZIP rebuilt. No status/CD module (R104).
## Basis
- Master read Defaults/Hekili.lua, A2 report; A2 read ranges in Claude/results/handoffs/phase8/iter_1/work_log-a2.md (Profile.lua:20, Options.lua 306–314, UI.lua 1294–1307, ChatCommands.lua).
## Gates
- core tests 50/50 (master rerun); luacheck failed=0; genregistry --check; tocdeps unresolved 0; build sha256 ae52cfc3…2487. Review: master check (R87, one-value defaults).
## Next
- Step 20 (done in same dispatch).

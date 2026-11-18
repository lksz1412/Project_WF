# Work log — A1 analyst, Phase 16 Step 28a (iter 1)

Role: design only. Wrote two files: `../design-28a.md` and this log. No addon code was written, nothing was committed, and nothing was deleted. Upstream, V42 and work trees were read only and never run. Python ran with `-I` on profile data only.

## Steps

| # | Step | Result |
|---|---|---|
| 1 | Read the plan rows and lines the order names (141, 150, 228, 270, 398–412, 429, 448) and the phase16 detail plan | Constraints fixed (design §0). Line numbers re-checked by grep: 404, 405, 408, 426, 230, 232. |
| 2 | Read Core in full (TOC, Core.lua, API.lua, Theme.lua, Edit.lua, Defaults.lua), the Registry.lua header, registry_extra.json, genregistry.py | Facts used for placement (Core no-frame contract, DB layout, edit fields have no boolean, own-addon registry path) and the registry entry shape |
| 3 | Read the V42 references: shPerformance, Broker_Money, the ChocolateBar TOC and modules (grep), the !DevilUI ChocolateBar profile | ChocolateBar has no clock, durability or bag plugin (not found). The profile's V42 info set is Broker_Money, shFps, shLatency and durability brokers. |
| 4 | Searched upstream addons with 16001 TOCs for the APIs and events | Evidence table, design §1.3 |
| 5 | Read the Step 5 layout (Codex doc) for the band | Band 28px, y 2124–2152 at 4K; status text 22px |
| 6 | Wrote the design | design-28a.md |
| 7 | Self-check: re-verified the cited plan line numbers by grep; fixed :403 → :404 and :409 → :408 | Done |

## Read ranges

These are the same as design §10. Every range listed there was read in this session. No compaction happened, and no rule files were re-read.

## Labels used

Labels are confirmed (file:line), not found, inferred, and 확인 필요 / unverified. Items that are 확인 필요:
- `BAG_CONTAINER_UPDATE` exists on Forever.
- `PLAYER_EQUIPMENT_CHANGED` fires on Forever (FUF registers it only under pcall).
- Forever counts as game type "mainline" (BasicMinimap evidence).
- The CVars `timeMgrUseLocalTime` / `timeMgrUseMilitaryTime` exist on Forever.
- The protected-anchor rule holds exactly on Forever.
- The currency and ammo APIs (excluded items).

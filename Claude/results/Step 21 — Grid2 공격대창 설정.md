# Step 21 — Grid2 공격대창 설정 (Phase 9)

Recorded: 2026-11-18 17:44:27 +0900

## Done
- A2: Defaults/Grid2.lua (AceDB Grid2DB, profile $char; hideBlizzard.raid=true; Grid2Layout layouts solo/party/arena=None, FrameDisplay=Raid), registry Grid2 entry (layout frame, position/size/spacing), phase9.md (items 0–9 incl. mouseover macro check), appearance-9.md, core tests 61/61, ZIP rebuilt (16 brief hashes updated).
- Master check: defaults read, tests rerun.

## Basis
master read Defaults/Grid2.lua, A2 report; A2 read ranges in Claude/results/handoffs/phase9/iter_1/work_log-a2.md (GridCore.lua:124,143, GridLayout.lua:29–33,60,74,156,534,826–849, GridBlizFramesHide.lua:92–119, GridFrame.lua:79–94).

## Files
Collection/AddOns/!DevilForever_Core/Defaults/Grid2.lua, registry_extra.json, Registry.lua, TOC, Collection/tests/core/run.py, Collection/codex-briefs/phase9.md, appearance-9.md, outputs/collection/DevilForever-collection.zip

## Gates
core tests 61/61 (master rerun); luacheck failed=0; tocdeps unresolved 0; genregistry --check; build sha256 12845c35…b06d

## Next
Phase 10 Step 22 — Details! + 어그로 창(TinyThreat)

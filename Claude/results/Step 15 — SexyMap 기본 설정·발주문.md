# Step 15 — SexyMap 기본 설정·발주문 (Phase 5)

Recorded: 2026-11-18 15:16:44 +0900

## Done
- A2: Defaults/SexyMap.lua (plain SexyMap2DB, per-character profile key computed like SexyMap.lua:37–45, core+buttons tables, rightClickToConfig=false, MiniMapTracking=always), registry entry (minimap frame, position editable), appearance-5.md (fragment sexymap-profile.fragment.lua, square shape 130871 etc. to Codex), phase5.md (items 0–9), core tests 48/48, ZIP rebuilt.
- Master check: profile key code compared with upstream SexyMap.lua:37–45 (same rule, computed at file load) — accepted without B (R87: small key derivation).
- Master decisions on DQ: right-click config off accepted; Ping.lua not in TOC left as is; others accepted.

## Basis
master read Defaults/SexyMap.lua code lines, upstream SexyMap.lua 37–45; A2 read ranges in Claude/results/handoffs/phase5/iter_1/work_log-a2.md (SexyMap.lua 325–352, Buttons.lua 217–246, toc 17, 43–58).

## Files
Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua, registry_extra.json, Registry.lua, TOC, Collection/tests/core/run.py, Collection/codex-briefs/appearance-5.md, phase5.md, outputs/collection/DevilForever-collection.zip

## Gates
core tests 48/48; chatsetup 13/13; luacheck failed=0; genregistry --check up to date; tocdeps unresolved 0; build sha256 ef42850c…7e9f

## Next
Phase 6 Step 16 — Forever Unit Frames 기본 설정·직업 자원 대조·발주문

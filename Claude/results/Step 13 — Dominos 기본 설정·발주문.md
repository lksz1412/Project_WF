# Step 13 — Dominos 기본 설정·발주문 (Phase 3)

Recorded: 2026-11-18 14:45:51 +0900

## Done
- A2: Defaults/Dominos.lua (AceDB DominosDB, profile $className, showBindingText), registry_extra Dominos entry (14 frames, position/spacing), appearance-3.md (bar 8 hidden via layout fragment), phase3.md (items 0–9), tests 41/41, ZIP rebuilt.
- Master decisions: DQ1 drop ab.count (fill-missing would change existing 8-bar default); DQ6 Codex returns dominos-profile.fragment.lua merged later with version bump; DQ3/4/5/7/8 accepted.

## Basis
master read Defaults/Dominos.lua, A2 report; A2 read ranges in Claude/results/handoffs/phase3/iter_1/work_log-a2.md (Dominos.lua 250–262, bar.lua 40–70, frame.lua 214, AceDB 318–321).

## Files
Collection/AddOns/!DevilForever_Core/Defaults/Dominos.lua, registry_extra.json, Registry.lua, !DevilForever_Core.toc, Collection/codex-briefs/appearance-3.md, phase3.md, Collection/tests/core/run.py, outputs/collection/DevilForever-collection.zip

## Gates
luacheck checked=9 failed=0; tests 41/41 (master rerun); genregistry --check up to date; tocdeps unresolved 0; build sha256 39e4c40a…1310

## Next
Phase 4 Step 14 — Prat 세 창 기본 설정·발주문

# Step 14 — Prat 대화창·세 창 분담 (Phase 4)

Recorded: 2026-11-18 15:06:40 +0900

## Done
- A2: Defaults/Prat-3.0.lua (AceDB Prat3DB profile Default, Prat_History scrollback=false, Prat_Memory on=false), DevilForever_ChatSetup addon (first-login only, out of combat, free-window count first, in-progress/interrupted markers), registry entries (30 chat frames, ChatSetup SV), appearance-4.md, phase4.md (items 0–9), tests core 43/43 + chatsetup 13/13, ZIP rebuilt.
- Review B 1 pass (new code): critical 0 · major 1 (free-window assumption) · minor 5 → M1 + minor 2 fixed by same A2 → master check.
- Master decisions: keep Prat text modules as shipped; Codex returns chat-windows/prat-profile fragments (merged later).

## Basis
master read ChatSetup.lua 129–143, 158–162, V42 !DevilUI.lua 1155–1163, review report; A2 read ranges + API evidence table in Claude/results/handoffs/phase4/iter_1/work_log-a2.md; triage Claude/results/handoffs/phase4/TRIAGE_phase4.md.

## Files
Collection/AddOns/DevilForever_ChatSetup/**, Collection/AddOns/!DevilForever_Core/Defaults/Prat-3.0.lua, registry_extra.json, Registry.lua, TOC, Collection/tests/chatsetup/run.py, Collection/tests/core/run.py, Collection/codex-briefs/appearance-4.md, phase4.md, outputs/collection/DevilForever-collection.zip

## Gates
chatsetup tests 13/13 (master rerun); core 43/43; luacheck failed=0; genregistry --check up to date; tocdeps unresolved 0; build sha256 13fc220d…54c2

## Next
Phase 5 Step 15 — SexyMap 기본 설정·발주문

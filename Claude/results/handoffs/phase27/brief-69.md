# Brief — Phase 27 Step 69: Grid2 size and text, chat height, Details stack, Details text (same work A)

You are the work sub (code) of Phase 27, Step 69, in the 3-session unit (master + work A + review B). Scope = the items below only. Commit belongs to the master: change files and write the work log only. Nothing outside this brief (no new documents, standards, commits, memory); anything else goes to "Decision Queue" in the work log. Do not attribute your own choices to the user. No cleanup deletes (no `rm -rf`, no `rm -f` for tidying); new runs in a new scratch folder (`mktemp -d`). Hekili code, patch and defaults stay untouched. Saved settings under `C:/Program Files (x86)/World of Warcraft/_forever_/WTF/Account/LKZ1412/` may be read, never written (the game is running; those files are from the last logout).

## User requests (2026-11-26 07:56, with screenshot)

- R233: "그리드 두배로 키웠더니 너무크다. 지금현재의 75% 정도로 줄여봐." — Grid2 cells ≈ 75% of what is shown now.
- R237: "그리드도 글씨가 너무 작아" — Grid2 text too small.
- R234: "대화창 가로 길이는 맞췄는데 새로길이는 안맞췄더라." — chat window width fits, height does not.
- R235: "3번 대화창 위에 둔다더니 1번 대화창 위에 떴었다. 내가 원하는 위치 변경한다. 딱 저기 3번 대화창위, 도미노스 끝나는 지점부터 창 우측변 끝나는 곳까지 딜 미터기 아래 어그로 미터그 위에 상하단 배치로 바꾼다." — Details: right above chat 3, horizontally from where the Dominos action bar ends to the right edge of the window/screen; stacked vertically: threat (TinyThreat) on top, damage meter below. This replaces the Step 68 side-by-side row (R228).
- R236: "지금은 글씨가 너무 작은것 같다. UHD 용 세팅이 맞냐?" — Details text too small. Master checked: saved `!DevilForever_Core` preset = "uhd", `Config.wtf` uiScale 1; `DevilForever_DetailsLayout/Layout.lua` sets no font size (only line 136 `GetPhysicalScreenSize`).

Screenshot reading (image-reader sub, image 2000×1125 = UHD ×0.5208): `Claude/results/handoffs/phase27/iter_4/image-17-reading.md` — read it in full. Key numbers: Grid2 8×5 cells ≈59 px pitch 60.3 (≈113 UHD px), cell text ≈6–7 px (≈13 UHD); action bar last button ends ≈x 1765, cap ≈1782–1790 (≈3430 UHD); chat 3 inner x ≈1520–1981, text lines y 963–1096 inside inner y 947–1105, but lines 1 and 6 run to x 1992 past the inner right edge onto the border (also a width problem in this window); Details today ≈ x 1505–1999, y 802–892 (two windows side by side, top-left corner under the target-pet frame); quest tracker ≈ x 1743–1999, y 270–695.

## Items

a. Grid2: frame size to ≈75% of the size the user sees now (find what the installed preset/saved values give on uhd and why it is ≈113 px; give fhd/qhd/uhd the same ratio), keep square cells and the anchor rule (above the quest tracker / current spot unless the smaller size needs a new anchor — state it). Text: every Grid2 text indicator the user sees in a cell readable at each preset (saved values show fontSize 8/9 on several indicators beside text-center 18) — pick sizes in proportion to the new cell and say why.
b. Chat height: find why the seeded/refitted Chattynator windows' height does not match the theme panel inner height (and why window 3's lines run past the inner right edge) on uhd; fix for fhd/qhd/uhd so the message area = panel inner rectangle with the tab row on the strip (Step 61/62/66 rules). Existing seeded windows follow the layout (refit once, like `FIT_VERSION`), user-moved windows are left alone.
c. Details: two windows stacked in the area x = [Dominos action bar right end + gap, chat-3 right edge (screen right edge)], bottom = the top of the chat surround/theme (same row as the action bar if that space is free), threat window on top, damage window below, both the same width; heights: split the free height between the quest tracker bottom (and any other frame) and the stack bottom; no overlap with Grid2, quest tracker, unit frames, action bars, minimap, chat. Per preset numbers from the screen map (`tests/layoutv2` helpers). Existing setups move once without a command (the `detailsLayout` marker / catch-up), windows the user made or moved stay alone. If the free height is too small for two readable windows, take the best fit and record it in the Decision Queue.
d. Details text: set row height and text size per preset so text is about the chat text size (chat ≈ 24–25 UHD px in the screenshot); also the title bar text. Use the Details API the code already uses (read Details source for the instance font/row settings) — first setup and the one-time move only.

## Before changing

Impact map with all rows in the work log (presets fhd/qhd/uhd, V2, catch-up revision, DetailsLayout, ChatSetup, tests, check list, install guide, codex brief numbers that quote the Details spot).

## Gates

layoutv2 · detailslayout · chatsetup · core · firststart suites, luacheck on changed Lua, build dry-run both variants, any new tests for the stack rectangles (no overlap, inside the screen, threat above damage) and Grid2 size ratio. Do not stage or install.

## Work log

New section "Step 69" at the end of `Claude/results/handoffs/phase27/iter_4/work_log-60.md`: read ranges, impact map, per-preset numbers before/after, changes, command verdict lines, Decision Queue. Return a short report.

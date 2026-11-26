# Brief — Phase 27 Step 72: aura order the user picked + dispel border (same work A)

You are the work sub (code) of Phase 27, Step 72, in the 3-session unit (master + work A + review B). Scope = the items below only. Commit belongs to the master: change files and write the work log only. Nothing outside this brief (no new documents, standards, commits, memory); anything else goes to "Decision Queue" in the work log. Do not attribute your own choices to the user. No cleanup deletes (no `rm -rf`, no `rm -f` for tidying); new runs in a new scratch folder (`mktemp -d`). Hekili code, patch and defaults stay untouched. The game folder is not yours: do not stage or install. If you were compacted since Step 69, re-read in full the files below before editing and note the ranges.

## User requests (2026-11-26)

- R245 18:30: "뭔 개소리야 오른쪽 위로 왜 보내." — no aura goes to the top-right (the game's default buff frame).
- R246 18:32: "적은 적한테 걸린 디버프가 바로 위에 오게 내캐릭터는 버프가 바로 위에 오게해." — target frame: debuffs directly above the frame, buffs above them. Player frame: buffs directly above the frame (as now), debuffs above them.
- R247 18:32: "핏불 테두리에 옛날에는 저주, 독, 마법에 따라 테두리 색이 바뀌는 기능이 있었는데 여전히 있는가? 디버프는 해제가능한것만 그렇게 띄워주면 될것 같은데?" — frame border coloured by debuff type, only for debuffs the player can dispel.

## Facts the master checked

- Current aura layouts: `Collection/AddOns/!DevilForever_Core/Presets/uhd.lua:493–511` (fhd/qhd same shape) — layouts "보통" (player) and "대상" (target) are identical: buffs `placement(8)`, debuffs `placement(8+buffRows*(size+spacing)+spacing)` with `my_size=64`, `reverse=true`; `highlight=false, highlight_style="thinborder"`. Party/focus/pet layout "데빌 파티" `uhd.lua:540–545`, `highlight=false`.
- PitBull4 aura highlight: `Collection/AddOns/PitBull4/Modules/Aura/Highlight.lua:113–206` (filters run per aura; colour by debuff type from `global.colors.type` when `highlight_filters_color_by_type[id]` is true; drawn as a texture over the whole frame, style `border`/`thinborder`/normal). Defaults `Modules/Aura/Options.lua:112–125` (`highlight_filters={'!H','!L','!I','!J'}`, `color_by_type={true,true,false,false}`). Filter `!H` = "Highlight: dispellable by me debuffs" (`Options.lua:1680–1686`).
- The collection's patched PitBull4 places managed aura blocks itself: `Collection/AddOns/PitBull4/Modules/Aura/Layout.lua` ~430–485 (`GetManagedLayoutDB`) always puts the buff block first (`buff.offset_y`) and the debuff block above it (`debuff.offset_y = buff.offset_y + buff_rows + …`) — the preset offsets alone may not decide the order. Read the whole managed rule, who calls it, and how the vendor patch for PitBull4 is recorded/applied in the collection (patch files, `tools/`, tests) before changing it; a per-layout order switch is the A1's estimate, not checked.
- HideBlizzard: `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua:250` region; PitBull4 module `HideBlizzard` (`aura` option) — read how the collection sets it today.

## Items

a. Target layout "대상": debuff block directly above the frame (first row at the current buff offset), buff rows above the debuff block; keep sizes (own debuffs 64 at uhd, scaled the same on fhd/qhd) unless the order change needs another value — say why. Player layout "보통": keep buffs directly above, debuffs above them. Check the stack height against what sits above each frame on every preset (screen map in `Collection/tests/layoutv2/run.py` — Grid2, quest tracker, Details stack, target-pet chain).
b. Game default buff/debuff frame hidden (PitBull4 HideBlizzard `aura`), so nothing shows at the top-right — check what else that option hides (temporary enchant / weapon buff frame) and record it.
c. Dispel border: `highlight=true` for "보통", "대상" and "데빌 파티"; `highlight_filters={'!H'}`, `highlight_filters_color_by_type={true}`, custom colour list kept the same length; choose the style (`border` or `thinborder`) that reads on the Devil border art and say why.
d. Existing setups follow once without a command (the layout revision catch-up — read `Presets.lua` catch-up and `V2.lua` revision; bump it), user-made layouts stay alone.
e. Check list (`Collection/codex-briefs/phase27-game-check.md`): a short section telling the user what to look at (target debuffs nearest the frame, player buffs nearest, nothing top-right, border colour on a dispellable debuff — e.g. a Magic debuff on a class that can dispel it).

## Before changing

Impact map with all rows in the work log (presets fhd/qhd/uhd, V2 revision, catch-up, Defaults/PitBull4 HideBlizzard, tests, check list, install guide / feature map lines that describe auras).

## Gates

layoutv2 · firststart · core suites, luacheck on changed Lua, build dry-run both variants, a new test for the aura order (target debuff offset below buff offset; player the reverse) and the highlight values on all three presets. Do not stage or install.

## Work log

New section "Step 72" at the end of `Claude/results/handoffs/phase27/iter_4/work_log-60.md`: read ranges, impact map, per-preset numbers before/after, changes, command verdict lines, Decision Queue. Return a short report.

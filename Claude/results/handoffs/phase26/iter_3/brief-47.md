# Step 47 brief (A2 coder) — merged Codex live branch + R130/R134/R140/R144④/R145/R146

Base: work branch `ccr-ba95560e-h298t2` @9c46a837 (Codex live branch d8b63f59 merged). Hekili changes are OUT (R144 ⑥).
Findings sources (read the cited lines yourself): `Claude/results/handoffs/phase26/iter_2/audit_log-48-1.md`, `-48-2.md`, `-48-3.md`.

## A. Party (R130 · R145 · R146)
1. PitBull4 party frames (top-left vertical) shown in party AND raid; Grid2 shows party and raid at the same time (healer mouseover). Today `Party.lua` keeps one owner (grid2 | unitframes, new install = grid2 at :397-398) and PitBull4 party `show_when` has raid*=false (`Presets/fhd.lua:469`, same in qhd/uhd, `Defaults/PitBull4.lua:40`). Redesign so both run; `/dfp party …` becomes the explicit way to turn the unit-frame party on/off (Grid2 stays on). FUF variant: keep it building; its party follows the same unit-frame switch.
2. Party sub-groups (party, party target, party target-of-target, party pet): on/off is written only at first install and by the explicit `/dfp party` command — never re-applied at login (today `alignPB4` :186-203 re-applies every login).
3. Party pet group (`Presets/*.lua` "파티원 소환수", now `{enabled=false,dfPartyRole="hidden"}`): enabled, `unit_group="partypet"`, a layout and a position beside the party frames, for fhd/qhd/uhd. PitBull4 uses SecureGroupPetHeaderTemplate (GroupHeader.lua:58) so it shows only existing pets.
4. Party:Set notice counts only groups it changed (audit 1 m5, Party.lua:495).

## B. Presets / Core (audit 1)
- M1: V2 must not inherit V1 aura-avoid keys (size_ratio .7 etc.) — V2.lua:121-122, Presets.lua:482, Core.lua:269, fhd.lua:588.
- m1 V2 moves the Quartz Pet castbar too (V2.lua:57) · m2 layout-only preset vs screen resolution check (Presets.lua:267-271) — at least a notice · m3 alignPixel group signature · m4 dfOffset/dfHeight nil arithmetic (UnitFrameLayout.lua:444-445) · m6 Skin_Dominos tail re-apply after combat (Skin.lua:32/54-58).

## C. Quartz swing (R140 · audit 3) — change via `Collection/patches/Quartz.patch` (patches.py regenerate)
- Swing bar enabled for HUNTER only; other classes off (melee use the game's built-in swing timer).
- Hunter: ranged cycle bar plus a stand-still window drawn as the last N seconds of the ranged cycle; N is a default value (0.5) in Core defaults, editable; in-game value is measured later by Codex — say so in the Codex check note, not in code comments.
- Enum.PlayerSwingType guard: fall back to numbers 0 main / 1 off / 2 ranged (Hekili Rows.lua:180-188) when the enum or key is missing.
- m3 V1 scale drift on UI scale change (SwingForever.lua:146 vs Defaults/Quartz.lua:51-57) · m6 unlock preview if cheap · when the delayed shot passes 0, keep the bar visible (full) until the next PLAYER_SWING instead of hiding (audit 3 M3).

## D. Grid2 / Grid2LDB (audit 2, code-fixable, no Hekili/Dominos-Hekili items)
- m11 guard `hooksecurefunc("CompactUnitFrame_UpdateUnitEvents", …)` existence (GridBlizFramesHide.lua:84) — new Grid2 patch.
- m12 new character template popup (GridProfiles.lua:123-145 + GridDefaults.lua:88-90): our defaults pre-seed the profile so the popup does not appear.
- m13 Grid2LDB minimap icon hidden by default via our Defaults.
- m9 UNIT_FACTION closure per event (GridFrame.lua:307-312) if trivial in the same Grid2 patch; m7/m8/m10 are estimates — leave, list in work_log.

## E. Tests / build
- Fix the patch-count test (`tests/patches`, 1 fail now).
- `tests/detailslayout` fails on a missing References file — report why; fix only if it is our test's path bug.
- Add tests for A1–A4, B-M1, C (hunter-only, stand-still window, enum fallback).
- Version stays 0.1.5. Rebuild: `build.py --install` and `--variant fuf` twice identical, `catalog.py --write` then `--check`, `genregistry.py --check`, `patches.py verify`, all suites.

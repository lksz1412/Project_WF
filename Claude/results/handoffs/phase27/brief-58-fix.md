# Brief — Phase 27 Step 58 fix (same work sub A)

Input: your diagnosis `Claude/results/handoffs/phase27/iter_2/diag-58.md` (master checked the quoted lines: ThemeSwitcher.lua:77–82 / :197, !BugGrabber.lua:15 "Font not set", BugGrabber SexyMap stack at Defaults/SexyMap.lua:211, V2.lua:100–112). Fix everything below in ONE change set, then run the gates. Hekili untouched.

## Decided by master (defaults; the user may still correct them — keep changes easy to adjust)

| # | Item | Decision |
|---|---|---|
| 1 | Grid2 spot | Above the quest tracker (R158, the user's latest words; supersedes R148). BOTTOMRIGHT corner just above the Blizzard objective tracker, right edge aligned with the tracker's right edge, grows up/left. Check that a 40-man window does not cover the top-right buff icons or the minimap; if it would, shrink spacing first, then say so in the work log. |
| 2 | Grid2 cells | Square. fhd 44 · qhd 58 · uhd 88 px (one unit = one physical px as today). |
| 3 | V2 default | Fold the V2 layout into the base fhd/qhd/uhd presets (keep the active names fhd/qhd/uhd). The *-v2 compare presets go away or become aliases — choose the one with the smaller impact and record it. Existing players get it on `/dfp preset <name>` + `/dfp go` (as today); do not force-overwrite saved settings on login. |
| 4 | Focus frame | Horizontal centre of the focus frame = screen centre (W − focusWidth)/2; lay both sides out symmetrically (timer gap on both sides). Pet frames unchanged. |
| 5 | Auras | Player, target and focus use one aura table (target's counts 14 buffs / 16 debuffs, icon sizes and placement of player/target per preset: uhd 40/64, qhd 27/43, fhd 20/32). Give the focus its own layout so the pet/party layouts stay unchanged. Focus frame width: keep unless the aura row needs player/target width — record what you chose. |
| 6 | Target-pet chain | Add `targetpettarget` and `targetpettargettarget` frames under the target-pet, same style as the existing chains under the player pet and focus, in all presets; set `enabled=true` explicitly on the target's-target rows. Deliver through the fragment/version path existing saved settings use. |
| 7 | Bottom HUD art (D2) | Code-side first: end pieces at uniform scale (no aspect change), middle section repeated/tiled, the deck sliced the same way; draw the action-bar 1–3 surrounds as separate textures anchored to DominosFrame1–3 with frame level above the Masque Onyx borders. If you need new texture pieces, cut them deterministically from the existing art with a dev tool (no hand-drawn art). |
| 8 | Theme switcher (D1) | Move the two `SetText("◀"/"▶")` calls into `apply()` after the SetFont loop; make the statusstrip test stub raise on SetText without a font, and add a load-order test so this class of error is caught. |
| 9 | SexyMap error | `Defaults/SexyMap.lua:211` "Invalid region point" (32×) — find the cause (values.point/relpoint or SetPoint signature) and fix it in our file only. |

## Gates
All affected suites (statusstrip, core, presets/V2, any party/Grid2 tests), `genregistry --check`, `patches.py verify`, build dry-run for pitbull4 and fuf. Add tests for: switcher load without font error, focus centred (uhd/qhd/fhd numbers), identical aura tables for player/target/focus, Grid2 square cell sizes and anchor, target-pet chain units present, HUD pieces keep aspect (computed texel ratio equal across x/y for end pieces).

## Records
Work log `Claude/results/handoffs/phase27/iter_2/work_log-58.md`: the impact map (all rows), commands with verdict lines, files and line ranges read, what you chose where this brief left a choice.

## Rules
No commits, no deletes, no popups (no rm -rf), nothing in the game folder, no publishing. Same-container sub: master commits.

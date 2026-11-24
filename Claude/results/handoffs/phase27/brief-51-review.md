# Review brief — Phase 27 Step 51 (review sub B, A3 reviewer)

Worktree: `D:/Projects/Project_WF/_local_only/claude-phase27`. Read only.

## Change type and scope

Code ② (local change) — new art tool + new TGA files + `ThemeSwitcher.lua` changes + test additions + regenerated manifest. One review pass: changed lines + impact-map units + one adversarial item + linked-place check + "connections outside the map". Execution came first: the work sub already ran the gates (see its work_log section with commands/verdicts). Do not rerun tests that already passed; run something only if the log has no record or looks wrong.

## Spec (what the change must do)

`Collection/codex-briefs/appearance-26-theme-switcher.md` §1 (art) and §2 items 1–6 (code), read in full. Claude makes the art instead of Codex (user R152–R154, `Claude/results/REQUEST_LEDGER_phase27.md`).

## Input files (read in full)

Target:
- `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` (236 lines; compare with `git diff HEAD -- <file>`)
- `Collection/tools/theme_switcher_art.py`
- `Collection/tests/statusstrip/theme_switcher.py` (changed part via `git diff HEAD`)
- `Collection/manifest.json` / `manifest.md` diff (`git diff HEAD`)
- The 63 TGA + `LICENSE-OFL.txt` under `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/` — check by machine (headers, list), not by eye.

Linked (read the parts the change uses):
- `Collection/AddOns/!DevilForever_Core/Theme.lua` (Cycle, ListChoices, GetChoiceName, display names)
- `Collection/AddOns/DevilForever_Skin_StatusStrip/Skin.lua` (how the switcher is built/applied, strip frame scale, bar preset values)
- `Collection/AddOns/!DevilForever_Core/Presets/fhd.lua`, `qhd.lua`, `uhd.lua` — the `statusstrip.bar` blocks only
- `Collection/AddOns/DevilForever_Appearance/Composition.lua:60–140` (pattern the brief copies: preset pick, edited-size discard, SetTexture result)
- `Collection/tools/build.py` packaging filter (what is shipped)

Work record (execution outputs + impact map only): `Claude/results/handoffs/phase27/iter_1/work_log-51.md`.

## What to check

1. Changed lines against brief §2 items 1–6, one by one (texture objects made once; SetTexture result checked before Set*Texture; BLEND highlight; FontStrings kept and hidden/shown correctly; fallback conditions incl. edited bar height/font size, file missing from the table, SetTexture false, non-fhd/qhd/uhd preset; arrows fall back as a pair per preset; swaps only in apply(); animation on image + text; combat alpha incl. login in combat; Disable only when ≤1 choice; nothing else changed).
2. Art against brief §1: names/ids/order vs `Theme.lua`, canvas sizes, TexCoord fractions in the Lua equal draw area / canvas, transparent outside the draw area, TGA type 2 / 32 bpp / alpha / origin convention same as existing Appearance TGAs, licence file present, no TTF in AddOns.
3. Impact map in the work_log vs reality; then look for connections outside the map (e.g. other code that touches the switcher's FontStrings or buttons, tests elsewhere that load ThemeSwitcher.lua, installer catalog / file counts that assume a file total).
4. Adversarial item: a path where the player sees an empty box, a white square, a mismatched arrow pair, a stuck alpha, or a Lua error (nil texture object, re-entry during the slide animation, preset change while in combat, `/reload` in combat).
5. Work sub's Decision Queue items 1–3 in the log: say for each whether it is a real defect in this change's scope.

## Report form

First line: counts by grade ("중대 n · 중간 m · 경미 k", or "중대·중간 없음"). For each 중대/중간: file:line · what breaks · evidence as an original quote (not a summary) or run output · linked places · pre-existing or introduced here. Minor items one line each (max 5). Read ranges per file. If 중대·중간 = 0, write the ranges read and the refutation attempts. No fix proposals.

Grades: 중대 = does not run / meaning reversed / breaks the main flow; 중간 = runs but a real user or maintainer would misuse it or need a workaround (write who/when/what in one line, otherwise it is minor); 경미 = wording or polish. Your grade is a proposal; master confirms against the source.

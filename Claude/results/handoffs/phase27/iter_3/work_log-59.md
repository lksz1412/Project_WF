# Work log — Phase 27 Step 59 (same work sub A): HUD art by parts, code and positions

Brief: `brief-59.md` 1–11 (user decision R162). Base `6e4433c2`, Collection clean at start.
Scratch (volatile, raw outputs only): `C:/Users/lksz1/AppData/Local/Temp/claude/712c5ac97757b4a3/5a41c91b-71c1-4f88-8d73-93b3933d99f1/scratchpad/s59/`.
After the compaction notice I re-read the rule files: `feedback_flow_interruption.md` 1–64, `feedback_change_impact_analysis.md` 1–60, `banned_lexicon.json` 1–75 (before writing the Codex brief).

## Read (file : lines)

| File | Lines |
|---|---|
| `Claude/results/handoffs/phase27/brief-59.md` | 1–11 (all) |
| `Claude/results/handoffs/phase27/brief-58-art.md` | 1–16 (all) |
| `iter_2/work_log-58.md` | 1–30, 81–108, 208–231 (round-3 stop report) |
| `Collection/AddOns/DevilForever_Appearance/Composition.lua` | 1–174 (all, base) · new file re-read 225–499 after the edits |
| `Collection/AddOns/DevilForever_Appearance/Appearance.lua` | 1–192 (all) |
| `Collection/AddOns/DevilForever_Appearance/Crests.lua` · `.toc` | all |
| `Collection/tests/composition/run.py` | 1–243 (all) |
| `Collection/codex-briefs/appearance-26-theme-switcher.md` | 1–59 (all) |
| `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` | 16–52 (SHIPPED table pattern) |
| `Collection/tools/theme_switcher_art.py` | 1–60, `tga_bytes` 225–235, function list |
| `Collection/tools/build.py` | 225–272 (runtime_files) |
| `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` | appearance.* entries 17–246 (parsed), uhd 1–16, 291, 295–345 (Dominos geometry) |
| `Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | grep appearance/Dominos: none |
| `Collection/AddOns/DevilForever_Skin_Dominos/Skin.lua` | 40–80, hook lines |
| `Collection/AddOns/Dominos/core/frame.lua` | 1–30, method list, 232–237, 785–791, 1134–1165 |
| `Collection/AddOns/Dominos/Dominos.lua` | callbacks:Fire lines, 13, 985 |

## What was built

| File | Change |
|---|---|
| `Collection/AddOns/DevilForever_Appearance/Composition.lua` | Part tables (`PART_SIZES`, `PART_SHAPES`, required 16 + optional `deck_crest`, `PARTS_SHIPPED = {}`), shared `readBounds()` (the old `GetPlan` gating, unchanged in effect), `GetPartsPlan` (caps, tiled fills, joints at panel boundaries, rivets, optional crest), `GetSurroundPlan` (DominosFrame1–3 rectangles in root pixels, touching bars merged, nine-slice ring at bar rect + gap + border), painting with texture pools, Dominos watching (LAYOUT_LOADED callback, post-hooks on bar methods, OnShow/OnHide), `Apply` tries parts first and otherwise runs the old body unchanged. Exposed as `Composition.parts`. |
| `Collection/tools/hud_parts.py` (new, dev tool, not shipped) | `--spec`, `--placeholders OUT` (refuses inside `Collection/AddOns`), `--check [ROOT]` (TGA format, canvas, transparency, seam and lighting ramp of strips, complete-or-none sets, PARTS_SHIPPED vs disk). Sizes read from Composition.lua through lupa. |
| `Collection/tests/composition/parts.py` (new) | 12 cases + `--preview DIR`. |
| `Collection/codex-briefs/appearance-27-hud-parts.md` (new) | Parts spec for Codex (Korean, like the 26 brief). |

## Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Composition.lua` `GetPlan`/`Apply` old path | same rule (gating, surfaces) | read whole file | change (refactor into `readBounds`, old body kept) | parts must fall back to today's drawing; verified call for call against `6e4433c2` (below) |
| `Appearance.lua:46,165` | callers (`Create`, `Apply`) | read whole file, grep `DevilForever_Composition` | check only | signatures unchanged; `Create` makes the same calls; `Apply(root, frames)` same |
| `tests/composition/run.py` | locking test | read whole file | check only | still 8/8; reads `topPieces`, `active`, `frame.shown` — unchanged |
| `tests/core/run.py:477–479`, `tests/performance/run.py`, `tests/pitbull4runtime/run.py` | loaders of Appearance | grep | check only | core 109/109, pitbull4runtime 20/20; performance needs `--dominos-zip` (external input, not run) |
| `Composition.active/.reviewed/.frame/.crest` readers | readers | grep over Collection | none outside Composition.lua | — |
| Preset `appearance.*` + Dominos frames 1–3 geometry | input producers | parsed the three preset files | check only (values used by the spec and tests) | band/deck heights 124/214 · 144/248 · 204/332 match the code's bounds; bars contiguous |
| `Dominos/core/frame.lua`, `Dominos.lua` | called side (hooked methods, callbacks) | read listed lines | check only | method names exist; `Addon.callbacks` = CallbackHandler, `_G.Dominos` |
| `Skin_Dominos/Skin.lua` | twin hook pattern | read 40–80 | none | same `hooksecurefunc(bar, method)` pattern; no shared state |
| `ThemeSwitcher.lua` SHIPPED table | same design decision (shipped table) | read 16–52 | none | pattern followed, not changed |
| `build.py runtime_files` | packer | read 225–272 | check only | no new shipped files: dry-run counts unchanged 2284 / 2228 |
| `extract.py` / manifest, `genregistry` | readers of AddOns | ran | check only | manifest unchanged, registry up to date |
| Twin copies | twin | none — Composition.lua has no copy | — | — |
| work_log-58, plans, ledgers | records | — | none (record) | not edited |

## Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/composition/run.py` | rc=0 · 8/8 |
| `python -I Collection/tests/composition/parts.py` | rc=0 · 12/12 |
| `python -I <scratch>/old_vs_new.py <scratch>/Composition_6e4433c2.lua` (base file from `git show 6e4433c2:…`) | `applies identical=56 different=0`, create logs identical — 13 themes × 3 presets, edited layout, failing reviewed deck, client without IsKnownFile |
| `python -I Collection/tests/composition/parts.py --preview <scratch>/preview.uZXh` | rc=0 · fhd 97 parts, qhd 109, uhd 149 placements; looked at `uhd_left.png`: caps, fill, joint with two round rivets, ring around the bar box with even gap |
| `python -I Collection/tools/hud_parts.py --spec` | rc=0 (17 parts × 3 presets) |
| `hud_parts.py --placeholders <scratch>/ph.YnFK` then `--check` on it | placeholders=663 · problems=0 |
| `hud_parts.py --placeholders Collection/AddOns/x` | rc=1 · `refusing to write placeholders inside …\Collection\AddOns` |
| `python -I Collection/tools/hud_parts.py --check` | rc=0 · `part files=0 problems=0 shipped table compared=True` |
| `python -I Collection/tools/theme_switcher_art.py --check` | rc=0 · tga=69 problems=0 |
| `python -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_Appearance` | checked=7 failed=0 |
| statusstrip/run 20/20 · theme_switcher rc=0 · core 109/109 · layoutv2 rc=0 · firststart 29/29 · castbars 16/16 · chatsetup 32/32 · fufdefaults 22/22 · pitbull4 6/6 · pitbull4runtime 20/20 · thirdparty 8/8 | rc=0 each |
| `tests/performance/run.py` | rc=2 · `the following arguments are required: --dominos-zip` (external input; not part of this change) |
| `python Collection/tools/extract.py` | rc=0 · errors=0 · manifest.json unchanged |
| `python Collection/tools/genregistry.py --check` | up to date |
| `python <scratch>/../s51.XsBX/devnull_run.py Collection/tools/patches.py verify` | patches=7 unmodified=20 failures=0 |
| `build.py --dry-run --variant pitbull4` / `fuf` (through devnull_run.py; plain run fails on Git diff `nul`, environment) | rc=0 · files 2284 / 2228 (same as before) |

## Choices I made (defaults, for the Decision Queue)

1. **Part sizes** (pixels): caps 48/64/96, fill repeat 256, joint 16/20/32, rivet 8/10/16, crest 128/160/224, surround border 6/8/12, edge repeat 64, gap 2 (fhd/qhd/uhd). Band/deck heights are the real layout values, not choices.
2. **All-or-nothing per theme × preset**: the 16 required parts (surround included) must all be listed and known; otherwise today's drawing. `deck_crest` optional.
3. **One surround around touching bars**: bars whose ring would touch share one ring around their union (today: one ring around bars 1–3); separated bars get one each.
4. **Surround rect** = DominosFrame rect rounded to whole root pixels + (gap + border). The Dominos frame rect is the native button box, about 1 px (fhd 0.7, uhd 1.1) outside the Onyx visual edge, so the visible gap Onyx→ring is about 3 px.
5. **Surround layer**: the highest strata among bars 1–3, level = highest level of the bar, its buttons and their children (depth 3) + 1, capped at 10000. Ring textures on ARTWORK; frame mouse and keyboard off.
6. **Re-measure triggers**: Dominos `LAYOUT_LOADED`; post-hooks on `Layout`, `RestorePosition`, `SetFrameScale`, `UpdateDisplayLayer`, `UpdateDisplayLevel`, `ShowFrame`, `HideFrame`; `OnShow`/`OnHide` scripts. Re-measuring also runs in combat (only our own unprotected frames are touched, nothing anchored to a bar).
7. **The old recess lip** of the top band is not drawn in parts mode; the band fill runs behind the bars and the ring frames them.
8. **Crest** placement: centre at 65 % of the last (right chat) panel's width, vertically centred in the deck, drawn as is (no extra alpha).
9. **Rivets**: two per joint, inset one rivet size from the deck's top and bottom.
10. **Art check thresholds** (heuristics): seam ≤ 2 × median neighbouring-line difference + 8 levels; lighting ramp ≤ 24 levels between quarters along the repeat axis.

## Decision Queue

1. The sizes in choice 1 are my defaults; the user or Codex may want other cap/joint/border widths — change `PART_SIZES` (tool and brief follow; brief tables are text and need the same edit).
2. Dominos fade (mouseover alpha) is not followed: the ring stays opaque when a bar fades out.
3. Real-client checks not possible here: actual frame levels of Masque Onyx regions, texture wrap of non-power-of-two drawings (avoided by cropping, no wrap mode used), and whether the ring at y up to 859/1185/1819 meets the deck edge cleanly.

## Remaining

Nothing in this brief is left undone. Not run: real install, game check (needs Codex art).

## Review fix (one medium: ring did not follow a bar dragged in Dominos config)

Read: `Dominos_Config/overlay/dragFrame.lua` 295–320 (drag end: `StopMovingOrSizing`, `Stick`, `UpdateWatched`) and 515–540 (keyboard nudge: `ClearSavedAnchor`, `SetPoint`, `SaveRelativePosition`, `RestorePosition`) · `Dominos/core/frame.lua` 705–765 (`SavePosition`, `SaveRelativePosition`), 960–1060 (`Stick`, `StickToFrame/Grid/Edge`) · grep `SavePosition|:Stick()|RestorePosition` over Dominos and Dominos_Config.

Why `SavePosition`: every user move ends in it after the final `SetPoint` — `Stick` → `StickToFrame` (SetPoint, SaveAnchor, SaveRelativePosition), `StickToGrid`/`StickToEdge` (SetPoint, SaveRelativePosition), free drag (ClearSavedAnchor, SaveRelativePosition), keyboard nudge (SaveRelativePosition, then RestorePosition). `SaveRelativePosition` calls `self:SavePosition`, so the instance post-hook runs. `Stick` alone would miss the nudge path. The ring is re-measured at drag end, not during the drag.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Composition.lua` `BAR_METHODS` | the defect | review quote, read | change: add `SavePosition` (+ one comment line naming what it covers) | ends every user move path |
| `watchDominos` hook loop | caller of the list | read | check only | hooks each listed method with `hooksecurefunc(bar, method, …)`; no other change |
| `tests/composition/parts.py` Bar stub method list + `surround_follows_dominos_layout_changes` | locking test | read | change: stub `SavePosition`, `SaveRelativePosition`, `Stick`, `StopMovingOrSizing`, `UpdateWatched` (drag frame order); drag case and nudge case | new path tested |
| Codex brief §2 「다시 배치·이동…할 때」 and §4-4 「바를 옮기거나 숨겼을 때 틀이 따라가는지」 | text describing the behaviour | grep, read the lines | check only, no edit | wording now matches the code |
| `Skin_Dominos/Skin.lua` hooks on `Layout` | twin hook pattern | read earlier (40–80) | none | different bars/methods, no shared state |
| work_log-59 「Choices」 item 6 | record | — | none (record) | the trigger list in item 6 is the state before this fix; this section supersedes it |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/composition/parts.py` | rc=0 · 12/12 (drag + nudge checks inside `surround_follows_dominos_layout_changes`) |
| same case against a scratch copy without `SavePosition` in `BAR_METHODS` (`<scratch>/Composition_nohook.lua`) | FAIL as expected · `dragged bar: own ring at its new place: expected True, got False` |
| `python -I Collection/tests/composition/run.py` | rc=0 · 8/8 |
| `python -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_Appearance` | checked=7 failed=0 |
| `build.py --dry-run --variant pitbull4` / `fuf` (through devnull_run.py) | rc=0 · files 2284 / 2228 (unchanged) |
| `python -I <scratch>/old_vs_new.py <scratch>/Composition_6e4433c2.lua` | `applies identical=56 different=0` (fallback still call-for-call) |

## Stage and dry run (commit e96261cb)

| Command | Verdict |
|---|---|
| `git log --oneline -1` · `git status --porcelain -- Collection` | `e96261cb` · empty |
| `python <scratch>/../s51.XsBX/devnull_run.py <scratch>/../s51.XsBX/stage_build.py <worktree> D:/Projects/Project_WF/_local_only` | rc=0 · `stage=…\claude-p27-stage-6fe26361 commit=e96261cb clean=True version=0.1.5 variant=pitbull4 folders=35 files=2281 bytes=338941656 excluded=106 verified=True` |
| `tasklist /FI "IMAGENAME eq Wow.exe"` | no task (game not running at that moment) |
| `pwsh -NoProfile -File Collection/tools/install_local.ps1 -StagedAddOns D:\Projects\Project_WF\_local_only\claude-p27-stage-6fe26361\AddOns -BackupRoot D:\Projects\Project_WF\_local_only\claude-p27-backup-77d4a273 -AllowRunningGame -DryRun` | rc=0 · staged 35 folders, 2281 files, commit e96261cb…, pitbull4, 0.1.5 · left alone `!BugGrabber, BugSack` · backup plan AddOns 2751 entries / 2310 files, WTF 113 / 105 → `claude-p27-backup-77d4a273` · 35 mirror steps · robocopy /L file lines 2281, all in the Newer class (0 New, 0 EXTRA) · would check 35 folders and write installation.json |
| `ls -d …/claude-p27-backup-*` | `5b85dff4`, `65cdb3bf`, `767a1dcc`, `a48b4467` (dry run created nothing) |

Raw: `<scratch>/stage59.txt`, `<scratch>/dry59.txt`. Real install not run.

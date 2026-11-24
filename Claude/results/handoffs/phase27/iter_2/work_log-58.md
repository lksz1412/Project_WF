# Work log — Phase 27 Step 58 fix (same work sub A)

Inputs: `brief-58-fix.md` 1–26, `brief-58-fix-r159.md` 1–13 (supersedes rows 1, 3, 4; adds the version switcher and the running-game install switch), my diagnosis `iter_2/diag-58.md`.
Scratch (volatile, raw outputs only): `C:/Users/lksz1/AppData/Local/Temp/claude/712c5ac97757b4a3/5a41c91b-71c1-4f88-8d73-93b3933d99f1/scratchpad/s51.XsBX/`.
After the compaction notice I re-read the rule files: `feedback_change_impact_analysis.md` 1–66, `feedback_confirmed_items_policy.md` 1–63, `feedback_full_file_read_required.md` 1–58, `feedback_post_edit_runtime_verification.md` 1–47, `feedback_code_comment_discipline.md` 1–42, `feedback_code_ownership_scope.md` 1–40, `feedback_unit_loop.md` 1–40.

## Read (file : lines)

| File | Lines |
|---|---|
| `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` | whole file (70–135 re-read before the edit; rewritten) |
| `Collection/AddOns/!DevilForever_Core/Defaults/SexyMap.lua` | 1–236 (all) |
| `Collection/AddOns/SexyMap/SexyMap.lua` | 555–580, 375–420, 600–616, grep scale |
| `git show 34b9125d^` / `34b9125d` of `Defaults/SexyMap.lua` | grep for SetScale / applyScale |
| `_local_only/claude-p27-backup-5b85dff4/AddOns/!DevilForever_Core/Defaults/SexyMap.lua` (read only) | 185–215 |
| `Collection/tests/firststart/run.py` | 200–340, 600–980 |
| `Collection/tests/layoutv2/run.py` | 1–140, 345–494 |
| `Collection/AddOns/!DevilForever_Core/Presets.lua` | 40–161, 343–597 (fragment writing, receipts, fresh/requested) |
| `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua` | 1–623 (all) |
| `Collection/AddOns/!DevilForever_Core/Party.lua` | 1–160, 405–437 |
| `Collection/AddOns/!DevilForever_Core/Commands.lua` | 209–219 |
| `Collection/AddOns/!DevilForever_Core/Profiles.lua` | 325–342 |
| `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` | uhd 1–751 (diag), structure diff fhd/qhd vs uhd (numbers only differ) |
| `Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | 1–175 (diag) |
| `Collection/tools/theme_switcher_art.py` | 1–52, 181–195, 236–245 |
| `Collection/tools/install_local.ps1` | whole file (Step 52) |
| `Collection/install/설치안내.md` | :57 |
| `Collection/codex-briefs/phase27-game-check.md` | :33, :38, :67–75 |
| `Themes/horde/Composition/uhd_top.tga`, `uhd_deck_reviewed.tga` | looked at as one image (art layout) |

## Rows and what was done

| Row | Decision | Done |
|---|---|---|
| 1 (R159) | Grid2 top = quest-tracker top, right edge = tracker left edge, party and raid same spot | `Presets/{fhd,qhd,uhd}.lua` Grid2Layout `anchor="TOPRIGHT"`, `PosX=-247/-330/-495*factor`, `PosY=-259/-346/-518*factor`; V2 no longer overrides the spot (`gridBottom` removed) |
| 2 | Square cells fhd 44 · qhd 58 · uhd 88 | `Grid2Frame` frameWidth = frameHeight |
| 3 (R159) | V1 kept; New = V2 default, Old = V1 | base `<size>` preset = V1 fragments followed by the V2 layout's fragments at version + 10 (fresh install / first pick / `/dfp preset <size>` end on V2); `<size>-v1` = Old, `<size>-v2` = New (same as base). Active names stay fhd/qhd/uhd |
| 3b (R159) | Version switcher left of the theme switcher | `ThemeSwitcher.lua` rewritten as `makeSwitcher(def)` with two instances: themes (`DevilForever_StatusStripThemes`, unchanged behaviour) and layouts (`DevilForever_StatusStripLayouts`, anchored RIGHT to the theme panel's LEFT). Images `layout_new.tga` / `layout_old.tga` per preset from `theme_switcher_art.py`, same arrows, slide, text fallback, combat refusal + dim. A switch = `Presets:Restore("<size>-v2"/"-v1")` then `Profiles:Go()` → automatic `/reload`. Hidden when PitBull4 is not loaded or the size has no variants |
| 4 (R159) | Focus midway between player and target | `V2.lua`: xFocus = (W − cw)/2, player and target each one timer gap away (focus centre = midpoint, row centred); pets unchanged |
| 5 | One aura table | presets: Aura loop for `보통`, `대상`, `주시` with 14/16 and `highlight=false` (target's value from Defaults); focus gets layout `주시` (copy of `소환수와 주시` frame look); pets keep `소환수와 주시` (party aura). Focus width kept 356 |
| 6 | Target-pet chain | presets: rows `대상의 소환수의 대상` (targetpettarget) and `…의 대상의 대상` (off in V1), new fragment version 6; V2 enables and places them under the target-pet; `enabled=true` on `대상의 대상`, `대상의 대상의 대상` |
| 7 | HUD art aspect | **not done** — see Decision Queue 1 |
| 8 | Switcher font error | arrow `SetText` moved after `SetFont`; test stub raises `Font not set`; load-order test |
| 9 | SexyMap `:211` | **no change** — already fixed before this step (see below) |
| new (R159) | install switch | `install_local.ps1 -AllowRunningGame`: skips only the running-game refusal; backup + package folders only, WTF never written; help text; `installation.json` records it |

## Impact map

| Place | Type | Found by | Impact | Reason |
|---|---|---|---|---|
| `ThemeSwitcher.lua` | changed code | read | fix | rows 3b, 8 |
| `Media/ThemeSwitcher/*/layout_{new,old}.tga` (6 new) | ★ producer output | art tool | fix (generated) | row 3b |
| `tools/theme_switcher_art.py` | ★ producer | read | fix | LAYOUTS added; same font size and baseline as the theme names |
| `Media/ThemeSwitcher/LICENSE-OFL.txt`, `manifest.json` license_files | ★ reader | extract.py | check only | same folder, licence already listed; extract: no manifest content change |
| `Presets/{fhd,qhd,uhd}.lua` | changed values | read + structure diff | fix | rows 1, 2, 5, 6 |
| `Presets/V2.lua` | changed layout source | read | fix | rows 1, 3, 4, 6 |
| `Presets.lua` fragment writer (receipts, fresh/requested, alignPixel) | ★ callee | read 343–597 | check only | V2 copies at version + 10 are written after base in both modes; receipt for the PitBull4 root key = 11 |
| `Defaults/PitBull4.lua:572–585` runtime geometry check | ★ reader of unit layouts | full read | fix | accepts focus layout `주시` (old profiles keep `소환수와 주시`), new chain names |
| `PitBull4/Modules/Aura/Layout.lua:433–478` | ★ consumer of dfAuraGeometry | diag read | check only | unchanged; tests drive it |
| `PitBull4/Utils.lua`, `UnitFrame.lua` unit ids | ★ callee | diag read | check only | targetpettarget accepted |
| `Party.lua` moveGrid2 / message | ★ reader of the Grid2 spot | read | fix | V2 spot lookup removed (same spot now); message "(퀘스트 목록 왼쪽, 위 끝 맞춤)" |
| `Defaults/Grid2.lua` reapplyAfterTemplate | ★ reader | diag read | check only | first Grid2Layout fragment written per key; spot identical |
| `Composition.lua:7`, switcher `ART`, `Party.lua:104` | ★ readers of active preset name | grep | check only | names unchanged |
| `Profiles:Go`, `Presets:Restore`, `Commands.lua` go | ★ callee of the version switcher | read | check only | same path as `/dfp preset` + `/dfp go` |
| `install/설치안내.md:57` | user doc | grep | fix | Grid2 spot words |
| `codex-briefs/phase27-game-check.md:33, :38, item 6` | check list | grep | fix | new spot, V2 default, focus, auras, chain |
| `tests/statusstrip/theme_switcher.py` | ★ locked test | read | fix | stub + new tests |
| `tests/layoutv2/run.py` | ★ locked test | read | fix | V2 default lifecycle, Grid2 spot, new tests |
| `tests/firststart/run.py` | ★ locked test | read | fix | pinned Grid2 values, V2 default, receipt 11, chain |
| `Collection/Installer/ReleaseCatalog.json` | ★ reader of release ZIPs | Step 56 | check only | stale for the new build — regenerate at release (DQ 4) |
| `References/codex-appearance/26-theme-switcher/index.md` | record (Step 51) | — | none (record) | — |
| `codex-briefs/phase26-step47-check.md` | record | grep | none (record) | — |

## Item 9 — SexyMap (확정, no change)

- In-game log: `!BugGrabber.lua:7–12` "Minimap:SetPoint(): Invalid region point 1.2063…", stack `[C] SetScale` ← `Defaults/SexyMap.lua:211` in a function at `:187`, session 26, time 2026-11-24 02:50:16.
- Cause: SexyMap's own hook `SexyMap.lua:569–571` calls `mod.frame.SetPoint(Minimap, scale)` after every `Minimap:SetScale` (upstream bug). The file loaded at 02:50 called `Minimap:SetScale(...)` directly.
- Commit `34b9125d` (2026-11-24 02:53:47, after the error) changed it to `setFrameScale(Minimap, …)` (the Frame metatable method, `Defaults/SexyMap.lua:24, :213`), which does not run the instance hook; `tests/firststart/run.py:300–324` locks it (a direct `Minimap:SetScale` raises, the package path does not). The log's last occurrence stays at session 26 while the current session is 56.
- No edit made; the upstream line `SexyMap.lua:570` is a third-party bug (patched folder exists) — DQ 5.

## Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · last lines: load-order PASS, version switcher PASS ×3 presets, hidden-without-PitBull4 PASS |
| old file `git show c34716a3:…ThemeSwitcher.lua` through the new stub | raises `ThemeSwitcher.lua:81: FontString:SetText(): Font not set` (the stub catches the installed bug) |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 30 PASS (V2 lifecycle ×4, aura consumers, Grid2 spot ×8, stand-still, V2 default ×4, square cells) |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 28/28 |
| `python -I Collection/tests/core/run.py` | rc=0 · 109/109 |
| statusstrip/run 20/20 · castbars 16/16 · chatsetup 32/32 · composition 8/8 · fufdefaults 22/22 · pitbull4 6/6 · pitbull4runtime 20/20 · thirdparty 8/8 | rc=0 each |
| `python <scratch>/devnull_run.py Collection/tests/patches/run.py` | rc=0 · 4/4 |
| `tests/catalog/run.py` (TEMP on C:) | rc=1 · cross-drive `relpath` (environment, same as Step 56; passed there with TEMP on D:) |
| `tests/detailslayout/run.py` | rc=1 · `FileNotFoundError …References\codex-appearance\10\…` (input missing in this worktree; untouched area) |
| `python -I Collection/tools/luacheck.py …!DevilForever_Core …Skin_StatusStrip` | checked=23 failed=0 |
| `python -I Collection/tools/theme_switcher_art.py --check` | tga=69 licence=1 problems=0 |
| `python Collection/tools/extract.py` | rc=0 · errors=0 · manifest content unchanged |
| `python Collection/tools/genregistry.py --check` | up to date |
| `python <scratch>/devnull_run.py Collection/tools/patches.py verify` | patches=7 unmodified=20 failures=0 |
| `… build.py --dry-run --variant pitbull4` / `--variant fuf` | rc=0 · files 2284 (2278 + 6) / 2228 (2222 + 6) |
| pwsh `Parser::ParseFile(install_local.ps1)` | parse errors=0 |
| `tasklist` | **Wow.exe running** (pid 32644) |
| `install_local.ps1 … -DryRun -AllowRunningGame` (pwsh 7 and PowerShell 5.1) | rc=0 · staged 35/2275 · left alone !BugGrabber, BugSack · backup plan AddOns 2745 entries, WTF 113 · 35 mirror steps |
| same without `-AllowRunningGame` | rc=1 · `ERROR Wow or WowClassic is running; close the game first.` |
| `-Help` | rc=0 · `-AllowRunningGame` explained |
| bad `-BackupRoot` with the switch | rc=1 · single ERROR line |
| backup folders after the dry runs | only the existing `claude-p27-backup-5b85dff4`; nothing new created |

## Choices I made

1. New/Old mapping: New = base `<size>` = `<size>-v2`; Old = `<size>-v1`. The layout in use is read from the PitBull4 profile flag `dfLayoutV2`.
2. Version switcher click = automatic reload (`Profiles:Go`), with the Restore lines printed first; refused in combat with the same tooltip line as the theme switcher.
3. Version switcher hidden (not only disabled) when PitBull4 is not loaded (FUF build) or the screen preset has no New/Old variants.
4. Text fallback labels "New" / "Old" in both client languages; tooltips "이전/다음 배치" (koKR), "Previous/Next layout".
5. Tracker geometry measured from the user's uhd screenshot only: top ≈ 24 % of screen height, left edge ≈ 23 % of screen height from the right edge (fhd 259/247, qhd 346/330, uhd 518/495). 추정 — needs the in-game check.
6. Aura table: target's values for all three, including `highlight=false` (from the target's Defaults) so the stored tables are identical; focus width kept 356.
7. Focus: both inner gaps = the timer gap (the player's totem timer needs it), so the focus is midway and the row stays centred.
8. Target-pet chain rows delivered in a new fragment version 6 (complete rows), placed last so its version is the receipt for existing profiles until the V2 copies (11) are written.

## Decision Queue

1. **Row 7 (HUD art aspect) not implemented.** The deck texture is one 2048×512 picture of five framed panels with rivets on every separator, and the top texture is one picture with the raised action-bar band (`Themes/horde/Composition/uhd_top.tga`, `uhd_deck_reviewed.tga`). A code-side 3-slice with a repeated middle would duplicate panel separators and misplace them against the chat/action/minimap frames. Per-element pieces (rivets, joints, bars) would need a new cutting tool and a new composition engine. That is a design change bigger than this change set. Options: (a) new per-resolution art drawn at the real aspect (art task); (b) a cutting tool + element-based Composition (new Phase/Step). No HUD aspect test added.
2. Grid2 at the new spot: the 40-player window reaches the target's full debuff band in every preset, and on fhd both windows reach the first Details window (`tests/layoutv2` locks exactly these overlaps). Size/shape wait for the user's feedback (R159).
3. Tracker position values are estimates from one uhd screenshot (choice 5).
4. `Collection/Installer/ReleaseCatalog.json` no longer matches a new build (6 more TGA, preset changes); rebuild ZIPs and rerun `catalog.py --write` at release time.
5. SexyMap upstream `SexyMap.lua:570` (`SetPoint` with a number) stays in SexyMap; our code avoids it. Patching SexyMap is a separate decision.
6. Wow.exe is running now: a real install would need `-AllowRunningGame`; the game may rewrite WTF on reload/logout, which the backup does not cover after the install.

## Remaining

Nothing committed. Real install and in-game check are master's / the user's.

## Staging and dry run from commit a2531127

| Command | Verdict |
|---|---|
| `git log --oneline -1` · `git status --porcelain -- Collection` | `a2531127` · empty |
| `python <scratch>/stage_build.py <worktree> D:/Projects/Project_WF/_local_only` | rc=0 · `stage=…\claude-p27-stage-679e45f3 commit=a2531127 clean=True version=0.1.5 variant=pitbull4 folders=35 files=2281 bytes=338923283 excluded=106 verified=True` |
| `tasklist /FI "IMAGENAME eq Wow.exe"` | Wow.exe running |
| `pwsh -NoProfile -File Collection/tools/install_local.ps1 -StagedAddOns D:\Projects\Project_WF\_local_only\claude-p27-stage-679e45f3\AddOns -BackupRoot D:\Projects\Project_WF\_local_only\claude-p27-backup-767a1dcc -AllowRunningGame -DryRun` (PowerShell 7) | rc=0 · staged 35 folders, 2281 files, commit a2531127…, pitbull4, 0.1.5 · left alone `!BugGrabber, BugSack` · backup plan AddOns 2745 entries / 2304 files, WTF 113 entries / 105 files → `claude-p27-backup-767a1dcc` · 35 mirror steps · robocopy /L: Newer 2275 + New File 6 (the `layout_new/old.tga`) = 2281, EXTRA 0 (nothing removed) · would check 35 folders and write installation.json |
| `ls -d …/claude-p27-backup-*` | only `claude-p27-backup-5b85dff4` (the dry run created nothing) |

Raw: `<scratch>/stage58.txt`, `<scratch>/dry58b.txt` (robocopy text cp949). Real install not run (master).

## Round 2 (brief-58-fix2.md, user re-check R160 + review M1)

Read: `brief-58-fix2.md` 1–12 · `REQUEST_LEDGER_phase27.md` row R160 · `Presets/V2.lua` 26–175 · `tests/layoutv2/run.py` 255–345 · `Presets/{fhd,qhd,uhd}.lua` Quartz Player line, companion layout size line (grep) · `PitBull4/Modules/Totems/Totems.lua` :8, :36, :233–243 (grep) · `Defaults/PitBull4.lua` 502–508 · `Grid2/GridLayout.lua` 878–886 · game WTF `PitBull4.lua` and backups `claude-p27-backup-{5b85dff4,767a1dcc}/WTF/…/PitBull4.lua` (read only, python/grep for `dfLayoutV2`). The screenshots `user-check-02..05` were not judged; every point below is tied to code or saved data.

### Findings

1. **Switcher state.** The user's PitBull4 profile already had `dfLayoutV2 = true` before the a2531127 install (backup `767a1dcc` WTF = state just before that install; it came from an earlier `uhd-v2` request), and the game now has `true`. So after the install the switcher showed **New** (flag true) while the profile still held the earlier V2 geometry (the install writes nothing into an existing profile). The review's "dfLayoutV2=false → Old" does not match this profile (근거: the two saved files above). Going Old→New then wrote the current V2, which is why the layout changed.
   Fix: the V2 layout writes `dfLayoutRevision = 2` (`V2.lua:21`, `:96`); the switcher shows New only when the profile has the V2 flag **and** this revision (`ThemeSwitcher.lua:256–258`), otherwise Old — one step then applies the current New. Login still writes nothing.
2. **Grid2 cells on switch.** The `-v1/-v2` presets wrote only Grid2Layout (spot). Now they also write Grid2Frame cells: New = the preset's square cells (44/58/88), Old = V1 cells (96×32, 120×44, 154×56 — `V2.lua:13–17` `oldCells`, `:71–77`). `/dfp preset <size>` + `/dfp go` writes the base cells (square) and the V2 copies (square). Spot unchanged (TOPRIGHT, tracker top / tracker left).
3. **The 4 slots right of the player frame = the PitBull4 totem timer** (Totems module, 4 slots = `MAX_TOTEMS = 4`, `PitBull4/Modules/Totems/Totems.lua:8`; enabled by `Defaults/PitBull4.lua:504–508`; layout of the player frame `보통` in `Presets/uhd.lua:479`: `attach_to="root", location="out_right_bottom", totem_direction="h", line_break=4, size=36/15` (fhd/qhd the same line). `hide_inactive=true`, so the slots show for a shaman with totems out, and in config mode). V2 reserved `timerGap` for it between player and focus (old `V2.lua` lines `timerWidth`/`timerGap`).
   Fix: in New the timer is `location="out_top_right"` (directly above the player frame, right-aligned, `V2.lua:103`), and the player's aura rows are raised past it (`dfAuraGeometry["플레이어"].top_margin = outside margin + icon + 4`, `V2.lua:152`). Under the player there was no free spot: the two "플레이어 아래" frames fill the full player width at `lower = bottom + 8`, so the brief's second choice (above, right-aligned, under the aura rows) was taken. Old (V1) keeps `out_right_bottom`.
   Gaps: player–focus = focus–target = `sideGap` (`V2.lua:111`) = the frame gap (castHeight + 4), widened only where the Quartz player cast bar above the focus (with its icon on the left) is wider than the focus: fhd 56, qhd 76, uhd 107 px (frame gap 34/38/44). With the plain frame gap the timer and the player's aura band overlapped the Quartz player bar (test: fhd totems (722,561,108,24) vs `quartz Player`; aura band (581,493,256,64) vs the bar). Focus stays at the midpoint and the screen centre; vertical positions unchanged; pets unchanged.
4. **Check-list x formula (M1).** `phase27-game-check.md:33` now uses Grid2's own rule for both values (`GridLayout.lua:880` right, `:883` top): `(P:GetWidth()*t - f:GetRight()*s)/u`, `(P:GetHeight()*t - f:GetTop()*s)/u` (205 bytes). Item 6 expectations updated (totem timer, switcher state, cells).

### Impact map (round 2)

| Place | Type | Impact | Reason |
|---|---|---|---|
| `Presets/V2.lua` | layout source | fix | revision, cells, totems, side gap |
| `ThemeSwitcher.lua` versionInUse | ★ reader of the profile flag | fix | revision rule |
| `Presets.lua` writer | ★ callee | check only | new Grid2Frame fragments use the same path as Grid2Layout |
| `Defaults/Grid2.lua` reapply | ★ reader | check only | first Grid2Frame fragment per key is the base square one |
| `PitBull4/Modules/Aura/Layout.lua:468` top_margin | ★ consumer | check only | raises the player's aura rows |
| `PitBull4/Modules/Totems/Totems.lua` | ★ consumer of `location` | check only | standard indicator location |
| `Defaults/PitBull4.lua` geometry check | ★ reader | check only | layouts/units unchanged |
| `Party.lua` | reader of Grid2 spot | none | spot unchanged |
| `tests/statusstrip/theme_switcher.py`, `tests/layoutv2/run.py`, `tests/firststart/run.py` | ★ locked tests | fix | new rules and tests |
| `codex-briefs/phase27-game-check.md` :33, item 6 | check list | fix | M1 + new expectations |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · version switcher PASS ×3 (current V2 = New, earlier V2 = Old → steps to New) |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 30 PASS (V2 default: equal side gaps 56/76/107, totem rect clear of every rectangle, player aura bands above the timer) |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 29/29 (new `grid2_cells_follow_the_layout_version`: fresh 44×44 → v1 96×32 → v2 44×44 → v1 → base 44×44, spot unchanged) |
| core 109/109 · statusstrip 20/20 · pitbull4 6/6 · pitbull4runtime 20/20 · composition 8/8 · castbars 16/16 · chatsetup 32/32 · fufdefaults 22/22 · thirdparty 8/8 | rc=0 each |
| luacheck Core + Skin_StatusStrip | checked=23 failed=0 |
| genregistry --check | up to date |
| patches verify (devnull wrapper) | patches=7 unmodified=20 failures=0 |
| build --dry-run pitbull4 / fuf | rc=0 · files 2284 / 2228 |
| theme_switcher_art --check | tga=69 problems=0 |

### Choices (round 2)

1. A V2 profile without this package's revision shows **Old** (one step = current New) — the honest state, since it does not hold the current New geometry.
2. Totem timer above the player frame (no free spot under it); aura rows raised by `top_margin`.
3. Side gap widened past the Quartz player cast bar where needed (fhd 56, qhd 76, uhd 107) instead of the plain frame gap, to avoid overlaps.
4. Old cell sizes = the V1 values the presets had before Step 58.

Remaining: master commits; then the new stage. HUD art is next round.

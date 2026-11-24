# Work log — Phase 27 Step 51 (work sub A, iteration 1)

Scratch for raw outputs (volatile): `C:/Users/lksz1/AppData/Local/Temp/claude/712c5ac97757b4a3/5a41c91b-71c1-4f88-8d73-93b3933d99f1/scratchpad/s51.XsBX/`

## Read before editing (file : lines)

| File | Lines |
|---|---|
| `Claude/results/handoffs/phase27/brief-51.md` | 1–29 (all) |
| `Collection/codex-briefs/appearance-26-theme-switcher.md` | 1–60 (all) |
| `~/.claude/BADA_HUB/feedback_change_impact_analysis.md` | 1–66 (all) |
| `~/.claude/BADA_HUB/feedback_unit_loop.md` | 1–71 (all) |
| `~/.claude/BADA_HUB/feedback_post_edit_runtime_verification.md` | 1–47 (all) |
| `~/.claude/BADA_HUB/feedback_full_file_read_required.md` | 1–58 (all) |
| `~/.claude/BADA_HUB/feedback_code_comment_discipline.md` | 1–42 (all) |
| `~/.claude/BADA_HUB/feedback_code_ownership_scope.md` | 1–84 (all) |
| `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` | 1–106 (all) |
| `Collection/AddOns/DevilForever_Skin_StatusStrip/Skin.lua` | 1–159 (all) |
| `Collection/AddOns/DevilForever_Skin_StatusStrip/DevilForever_Skin_StatusStrip.toc` | 1–8 (all) |
| `Collection/AddOns/!DevilForever_Core/Theme.lua` | 1–253 (all) |
| `Collection/AddOns/!DevilForever_Core/Presets.lua` | 1–40, 232–244, 595–634 (GetActive, PickForScreen, first-choice) |
| `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` | statusstrip.bar line (fhd :272) — height 22/24/28, font 16/18/22 |
| `Collection/AddOns/!DevilForever_Core/Edit.lua` | 276–295 (Edit:Get) |
| `Collection/AddOns/!DevilForever_Core/Core.lua` | 196–197 (Core.InCombat) |
| `Collection/AddOns/DevilForever_Appearance/Composition.lua` | 1–174 (all) |
| `Collection/AddOns/DevilForever_Appearance/Appearance.lua` | 1–40 |
| `Collection/AddOns/DevilForever_Appearance/Themes/{devil,horde,alliance}.lua` | color.panel.background lines (:6) |
| `Collection/tests/statusstrip/theme_switcher.py` | 1–168 (all) |
| `Collection/tests/statusstrip/run.py` | 1–784 (all) |
| `Collection/tests/core/run.py` | 1–230 (stubs, Session) |
| `Collection/tools/extract.py` | 1–721 (all) |
| `Collection/tools/build.py` | 1–390 (all) |
| `Collection/tools/luacheck.py` | 1–96 (all) |
| `Collection/tools/patches.py` | :140 (diff call with os.devnull) |
| `Claude/results/REQUEST_LEDGER_phase26.md` | rows R132, R134, R135, R141, R142 |
| `Claude/results/REQUEST_LEDGER_phase27.md` | 1–11 (all) |

## Baseline (before any edit)

| Command | Verdict |
|---|---|
| `sha256sum Collection/codex-briefs/assets/26-theme-switcher/*` | Allura-Regular.ttf = 9c142b2e…4cc6 (matches brief) · OFL.txt = c8cb4c94…ad49 |
| TGA header scan of `Collection/AddOns/DevilForever_Appearance/**/*.tga` (python, 18-byte header + size) | all: id 0, colormap 0, type 2, origin 0,0, 32 bpp, descriptor 8 (8 alpha bits, bottom-left origin), 26-byte TRUEVISION-XFILE footer |
| `python Collection/tools/extract.py` | rc=0 · `packages=39 … errors=0` · manifest.json/md content unchanged (git diff --stat empty; CRLF warning only) — Collection/upstream created |
| `python Collection/tools/patches.py verify` | rc=2 · `ERROR diff failed for PitBull4/Compat.lua: diff: nul: No such file or directory` (os.devnull = "nul" on Windows, Git diff.exe does not accept it) |
| `python <scratch>/devnull_run.py Collection/tools/patches.py verify` (wrapper sets os.devnull="/dev/null" then runs the script unchanged) | rc=0 · `verify patches=7 unmodified=20 failures=0` |
| `python <scratch>/devnull_run.py Collection/tools/build.py --dry-run` | rc=0 · `dry-run folders=35 files=2214` · `excluded files=106` |
| `python Collection/tools/genregistry.py --check` | rc=0 · `up to date` |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 4 resolution PASS lines + 3 PASS lines |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |

## Change list (before the map)

1. New dev tool `Collection/tools/theme_switcher_art.py` (writes TGAs + LICENSE-OFL.txt; `--check`).
2. New files `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/<fhd|qhd|uhd>/*.tga` (63) + `Media/ThemeSwitcher/LICENSE-OFL.txt`.
3. Edit `ThemeSwitcher.lua`: name Texture beside the name FontString, arrow state textures, shipped-file table, preset/edit/table/SetTexture fallback, Enable/Disable, combat alpha, PLAYER_REGEN_DISABLED registration, second animation group for the image.
4. Edit `Collection/tests/statusstrip/theme_switcher.py`: client stubs for the new calls + new checks.
5. Regenerated `Collection/manifest.json` / `manifest.md` via extract.py (license_files of the status strip skin).
6. New `References/codex-appearance/26-theme-switcher/preview.png` + `index.md`.

## Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `ThemeSwitcher.lua` `apply()` :58–94 | ★ code callee/caller — the changed function | full read | change together | brief §2 items 1–5: texture swap only inside apply() |
| `ThemeSwitcher.lua` events :96–106 (PLAYER_LOGIN / PLAYER_REGEN_ENABLED / Theme + Edit callbacks) | ★ callers of apply() | full read | change together | add PLAYER_REGEN_DISABLED + alpha; login dim when in combat; callers kept |
| `ThemeSwitcher.lua` `choose`/`hint` :34–56 | ★ code (click path, tooltip) | full read | check only | brief §2-5: click area, left click only, tooltip text unchanged; buttons stay Enabled in combat so hint keeps firing |
| `ThemeSwitcher.lua` animation :15–24, :84–92 | ★ code | full read | change together | brief §2-4: image moves with text |
| `Core.Theme:Cycle` / `ListChoices` / `GetDisplayName` / `GetSet` (`Theme.lua:140–181`) | ★ callee (return contract) | full read | check only | ListChoices = array of available choices → `#` for the ≤1 rule; GetSet returns active name (image key); not edited (brief §2-6) |
| `Core.Presets:GetActive()` (`Presets.lua:232–237`) | ★ callee | read | check only | returns name, registered; nil before Core.ready → text fallback |
| `Core.Edit:Get("statusstrip.bar")` (`Edit.lua:276–295`) | ★ callee | read | check only | effective values (registry default → preset → user edit); compared with brief §1 table |
| `Core.InCombat()` (`Core.lua:196`) | ★ callee | read | check only | boolean |
| `Composition.lua:67–76, :131` | same idea (preset gate, edit gate, SetTexture == false) | full read | check only | pattern copied, file not touched |
| `Skin.lua` (apply, separators, events) | ★ neighbour code in same addon | full read | no impact | does not read ThemeSwitcher state; brief §2-6 forbids changes |
| `DevilForever_Skin_StatusStrip.toc` | ★ reads the files to load | full read | no impact | textures/licence are not TOC entries; ThemeSwitcher.lua already listed |
| `Collection/tests/statusstrip/theme_switcher.py` | ★ locked test of the switcher | full read | change together | stubs needed for new client calls (SetTexCoord, SetAlpha, Enable/Disable, Set*Texture); new checks per brief item 4 |
| `Collection/tests/statusstrip/run.py` | ★ locked test (standalone strip, STUBS reused by theme_switcher.py) | full read | check only | standalone session does not load the skin; "no combat start/end events" check is on the standalone strip only |
| `Collection/tests/core/run.py` | ★ harness reused (Session) | read 1–230 | check only | `collection_presets` / `GetPhysicalScreenSize` path used by new test sessions; not edited |
| `Collection/tools/extract.py` `license_files` / `LICENSE_RE` :159, :314–322 | ★ reader of the new licence file | full read | check only (regenerate) | `LICENSE-OFL.txt` matches the regex (os.walk includes subfolders) |
| `Collection/manifest.json` / `manifest.md` | ★ generated copy | extract.py output | change together (by regeneration only) | not hand-edited |
| `Collection/tools/build.py` `runtime_files` :256–271 | ★ reader (packs the new files) | full read | check only | .tga and .txt are kept (not CODE_EXT, not DEV_FILES, not _deck) |
| `Collection/tools/build.py` `install_manifest` license_files :178 | ★ reader of manifest license_files | full read | check only | copies the manifest list into the ZIP install manifest |
| `Collection/tools/patches.py` | reader of third-party folders | read :140 | no impact | own folder, not patched/unmodified third-party |
| `Collection/tools/genregistry.py` | reader of TOCs/SVs | `--check` run | no impact | TOC unchanged |
| twin copy of ThemeSwitcher.lua (other packages / Codex) | ★ twin copy | `grep -rl ThemeSwitcher` over repo (excluding records) | none found | only Collection copy + plans/brief records |
| Phase plans / ledgers mentioning the switcher | record | grep | no impact (record) | records are not edited |
| `Collection/tests/performance/run.py:124` | locked test (loads Skin.lua only) | `grep -rln Skin_StatusStrip Collection/tests` | no impact | does not load ThemeSwitcher.lua |
| `Collection/tests/install/verify_archives.py:172` | reader of built ZIPs (must_ship list) | same grep | check only | checks real ZIPs (not built in this step); folder name unchanged |
| `Collection/Installer/ReleaseCatalog.json:24,72` | folder list | same grep | no impact | folder name unchanged |
| `Collection/codex-briefs/appearance-26-theme-switcher.md` | spec (pointer source) | full read | no impact | spec, not edited |

## Units done (unit loop record)

| Unit | Read (file:lines) | Made/changed | Self-check (brief gates only) |
|---|---|---|---|
| 1 Art tool | brief §1, TGA header scan, font name table | `Collection/tools/theme_switcher_art.py` (new) | font sha256 check before use; `--check` in a second process = 0 differences (same bytes); preview looked at (scratch `preview1.png`, `preview2.png`) — arrow chevron enlarged once after the first look |
| 2 Images + licence | tool output | 63 TGA under `Media/ThemeSwitcher/<fhd|qhd|uhd>/`, `Media/ThemeSwitcher/LICENSE-OFL.txt` | headers/canvas/transparency/licence copy/no TTF asserted in the test |
| 3 ThemeSwitcher.lua | ThemeSwitcher.lua 1–106, Composition.lua 1–174, Theme.lua 1–253, Presets.lua parts, Edit.lua 276–295 | ThemeSwitcher.lua 106 → 236 lines (+136/−6), CRLF kept (the committed file is CRLF; first write was LF and showed a whole-file diff — converted back) | luacheck 2 files 0 failed; runtime through the test harness below |
| 4 Tests | theme_switcher.py 1–168, statusstrip/run.py 1–784, core/run.py 1–230 | theme_switcher.py: stubs (SetTexture result, SetTexCoord, SetAlpha, Enable/Disable, Set*Texture), `load(source=)`, `session(screen=, switcher=, combat_login=)`, image block | full suites below |
| 5 Manifest + build gates | extract.py, build.py | manifest.json/md regenerated | below |
| 6 Preview + index | — | `References/codex-appearance/26-theme-switcher/preview.png`, `index.md` (63 image rows) | line ranges in index re-checked against the file with grep -n |

## Commands after the edits (verdict lines only)

| Command | Verdict |
|---|---|
| `python -I Collection/tools/theme_switcher_art.py --preview <scratch>/preview2.png` | rc=0 · `wrote tga=63 licence=1 font_size fhd=20.75 qhd=22.50 uhd=26.50` |
| `python -I Collection/tools/theme_switcher_art.py --check` | rc=0 · `check tga=63 licence=1 … problems=0` |
| `python -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_Skin_StatusStrip` | `checked=2 failed=0` |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 15 PASS lines (7 old + 8 new) |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |
| `python Collection/tools/extract.py` | rc=0 · `errors=0` · status strip skin `license_files` = `['Media/ThemeSwitcher/LICENSE-OFL.txt']` · diff = that list (json) + that cell (md) only |
| `python Collection/tools/genregistry.py --check` | rc=0 · `up to date (58497 bytes)` |
| `python <scratch>/devnull_run.py Collection/tools/patches.py verify` | rc=0 · `verify patches=7 unmodified=20 failures=0` |
| `python <scratch>/devnull_run.py Collection/tools/build.py --dry-run` | rc=0 · `dry-run folders=35 files=2278` (baseline 2214, +64) · `excluded files=106` (unchanged) |
| `build.runtime_files('DevilForever_Skin_StatusStrip', …)` (python, devnull set) | kept 67 · Media 64 (LICENSE-OFL.txt + 63 TGA) · excluded [] |
| `python -I Collection/tools/theme_switcher_art.py --preview References/codex-appearance/26-theme-switcher/preview.png` | rc=0 · same wrote line; `--check` afterwards still 0 problems (TGAs rewritten with identical bytes) |
| (after CRLF conversion of ThemeSwitcher.lua) theme_switcher.py / statusstrip run.py / luacheck / art --check | rc=0 · 15 PASS · 20/20 · 0 failed · 0 problems |

## Decisions I made (my judgment)

1. Font size: one size and one baseline per preset (largest supersampled size where every name plus a 1 px outline margin fits the name area) — fhd 20.75 · qhd 22.50 · uhd 26.50. The shadow may be cut at the draw-area edge; the canvas outside the area is forced transparent.
2. TGA bytes written by hand (header + BGRA rows bottom-up + TRUEVISION footer) to copy the Appearance TGA layout exactly; transparent pixels get RGB 0.
3. Arrow look: chevron + small diamond; hover = 35 % toward white, pushed = 18 % darker + 1 px down (drawn into the image, no pushed offset in code), disabled = desaturated × 0.55.
4. Text fallback for arrows: the four state texture objects stay attached and get `SetTexture(nil)`; the ◀ ▶ FontStrings are shown again. I did not call `SetNormalTexture(nil)`/`ClearNormalTexture` because I could not confirm which of them this client accepts.
5. Name image and text slide with two Translation groups started together (brief §2-4 allows this); the name FontString keeps its own group so the existing test contract (`text.animation`) holds.
6. The shipped-file table lists the 21 file names per preset explicitly (63 entries) so that one file can be left out for one preset.
7. Edit gate = effective `statusstrip.bar` height and font size compared with the preset values (22/16, 24/18, 28/22), not `Edit:GetEdits`; a user edit equal to the preset value keeps the image.
8. `patches.py verify` and `build.py` were run through a scratch wrapper that sets `os.devnull = "/dev/null"`, because `patches.py` passes Windows `nul` to Git's `diff.exe`, which fails on this PC. The tools themselves are unchanged.
9. Preview background = flat devil/horde/alliance `color.panel.background` colours (stand-in for the strip).

## Decision Queue

1. `Collection/tools/patches.py:140` uses `os.devnull` with Git Bash `diff` — fails on Windows (`diff: nul: No such file or directory`). Not fixed (outside this brief). Options: leave (run on Linux / with a wrapper) or change patches.py to pass an empty temp file or `/dev/null` when diff is MSYS.
2. In game (Step 53): does this client accept texture objects in `SetNormalTexture`/`SetPushedTexture`/`SetDisabledTexture`/`SetHighlightTexture(obj, "BLEND")`, and does `SetTexture(nil)` blank them for the text fallback?
3. `Collection/codex-briefs/assets/26-theme-switcher/OFL.txt` has no `-text` attribute while `Collection/AddOns` has; with `core.autocrlf=true` a fresh checkout could give the two files different line endings, and the test compares them byte for byte. Today they are equal (sha c8cb4c94…ad49 for both).

## Remaining

Nothing open inside the brief. In-game checks are Step 53. Nothing committed (master).

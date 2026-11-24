# Work log — Phase 27 Step 52 (same work sub A, iteration 1)

Base = commit `c34716a3` (Step 51). Scratch for raw outputs (volatile): `C:/Users/lksz1/AppData/Local/Temp/claude/712c5ac97757b4a3/5a41c91b-71c1-4f88-8d73-93b3933d99f1/scratchpad/s51.XsBX/`
The rule memory files of brief-51 (change impact analysis, unit loop, post-edit runtime verification, full file read, code comment discipline, code ownership scope) were read in full earlier in this same session (Step 51, no compaction since).

## Read (file : lines)

| File | Lines |
|---|---|
| `Claude/results/handoffs/phase27/brief-52.md` | 1–22 (all) |
| `D:/Projects/Project_WF/_local_only/live-015-pitbull-install-20261124.ps1` (read only) | 1–136 (all) |
| `D:/Projects/Project_WF/_local_only/live-015-pitbull-20261124/.live-pitbull/work_log.md` (read only) | 1–29 (all) |
| `…/.live-pitbull/receipt.json` (read only, JSON data) | python: top-level keys, strategy, folders, patch_verify, files[0] |
| `Collection/install.json` | 1–50 (all) |
| `Collection/tools/patches.py` | 1–336 (all) |
| `Collection/tools/build.py` | 1–390 (all, Step 51 read, same file at c34716a3) |
| `Collection/codex-briefs/phase26-step47-check.md` | 1–12 (all) |
| `Collection/codex-briefs/appearance-26-theme-switcher.md` | 1–60 (all, Step 51 read) |
| `Collection/AddOns/!DevilForever_Core/Commands.lua` | 1–70, 125–140, 215–265 |
| `Collection/AddOns/!DevilForever_Core/Edit.lua` | 108–126, 139–215 |
| `Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | 40–60, 160–172 |
| `Collection/AddOns/!DevilForever_Core/Defaults/Quartz.lua` | 1–40 |
| `Collection/AddOns/!DevilForever_Core/Defaults/Grid2.lua` | :22, :47–54 (grep hits) |
| `Collection/AddOns/PitBull4/Options/Options.lua` | 1–70 |
| `Collection/AddOns/PitBull4/Options/ConfigMode.lua` | 1–70 |
| `Collection/AddOns/Grid2/GridCore.lua` | 300–375 |
| `Collection/AddOns/Grid2/GridLayout.lua` | 395–418, :218 |
| `Collection/AddOns/Grid2/GridUtilsCmd.lua` | 100–178 |
| `Collection/AddOns/Grid2Options/modules/themes/GridLayouts.lua` | 60–100 |
| `Collection/AddOns/Quartz/Config.lua` | 50–75, 186–216 |
| `Collection/AddOns/Quartz/Quartz.lua` | 100–130 |
| `Collection/AddOns/Quartz/modules/Swing.lua` | 110–135, 320–345, 405–440 |
| `Collection/AddOns/Quartz/modules/SwingForever.lua` | grep hits :27, :54, :64, :71, :140, :151–152, :163, :176, :329–334 |
| `Collection/AddOns/Dominos/plugins/slashCommands.lua` | 20–80 |
| `Collection/AddOns/DevilForever_Skin_Dominos/Skin.lua` | grep hits :6, :14, :33, :60, :150, :159, :164, :169 |
| game folder `C:\Program Files (x86)\World of Warcraft\_forever_` | listing only: root, `Interface`, `Interface\AddOns` (37 folders incl. `!BugGrabber`, `BugSack`) |

## Change list

1. New staging tree `D:/Projects/Project_WF/_local_only/claude-p27-stage-255f4725/AddOns` + `receipt.json` (outside git), made by scratch helper `stage_build.py` (build.install_selection → install_sources → check_sources → plan_entries, then plain file copies).
2. New `Collection/tools/install_local.ps1` (dev tool, not shipped — `build.py` packs only `Collection/AddOns`).
3. New `Collection/codex-briefs/phase27-game-check.md`.

No existing file was edited.

## Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `build.py` install_selection / install_sources / check_sources / plan_entries | ★ callee (staging) | full read | check only | used unchanged; same chain as Codex's receipt `strategy` |
| `patches.py` verify / file_diff `os.devnull` | ★ callee | full read | check only | process-only `os.devnull = "/dev/null"`; tool unchanged |
| `Collection/install.json` | ★ input (folder set, variant, version) | full read | check only | pitbull4 default, 0.1.5 = Core TOC |
| `Collection/manifest.json` | ★ input made by extract.py | Step 51 regeneration | check only | current at c34716a3 (Collection clean) |
| Codex `live-015-pitbull-install-20261124.ps1` | twin/reference (other tool) | full read | no impact (read only) | safety checks reused (fixed game root, Wow.exe, Wow/WowClassic process, reparse points, inventory compare, robocopy /XJ exit ≥ 8) |
| game `Interface\AddOns`, `WTF` | ★ target of the new tool | listing | no impact in this step | dry run only; real install by master |
| `Interface\AddOns.BeforeDevilForever015-3434ca83`, `!BugGrabber`, `BugSack` | neighbours in the game folder | listing | no impact | tool touches only `Interface\AddOns\<package folder>` |
| `.gitignore` `_local_only/` | reader | Step 51 read | check only | stage/backup outside git |
| `phase26-step47-check.md`, `appearance-26-theme-switcher.md` §3 | sources of the check list | full read | no impact | copied into the new list; not edited |
| addon sources cited in the check list | ★ commands quoted | read ranges above | check only | file:line re-checked with grep -n after writing |
| `build.py` packing of `Collection/tools/*` | reader | Step 51 read | no impact | tools folder is not packed |

## Commands (verdict lines only)

| Command | Verdict |
|---|---|
| `git status --porcelain -- Collection` | empty (Collection = c34716a3) |
| `python <scratch>/stage_build.py <worktree> D:/Projects/Project_WF/_local_only` | rc=0 · `stage=…\claude-p27-stage-255f4725 commit=c34716a3 clean=True version=0.1.5 variant=pitbull4 folders=35 files=2275 bytes=338652752 excluded=106 verified=True` (patches.verify inside: passed, else check_sources would raise) |
| `tasklist /FI "IMAGENAME eq Wow.exe"` | no task |
| `pwsh -NoProfile -File Collection/tools/install_local.ps1 -StagedAddOns …\claude-p27-stage-255f4725\AddOns -BackupRoot …\claude-p27-backup-fc74f5af -DryRun` (PowerShell 7.6.10) | rc=0 · staged 35 folders 2275 files commit c34716a3 pitbull4 0.1.5 = receipt · left alone `!BugGrabber, BugSack` · backup plan AddOns 2674 entries / 2238 files, WTF 113 entries / 105 files · 35 mirror steps · robocopy /L: Newer 2209 + New File 66 = 2275 copies, 0 EXTRA (no file removed inside package folders) · backup folder not created |
| same with `powershell -NoProfile -ExecutionPolicy Bypass -File …` (Windows PowerShell 5.1) | rc=0 · same summary lines · same counts 2209 / 66 / 0 EXTRA |
| `pwsh … install_local.ps1 -Help` | rc=0 · usage + restore lines |
| `pwsh … -BackupRoot D:\Projects\Project_WF\_local_only\bad-name -DryRun` | rc=1 · `ERROR BackupRoot must be …claude-p27-backup-<8 hex>` |
| `pwsh … -StagedAddOns …\claude-phase27\Collection\AddOns -DryRun` | rc=1 · `ERROR StagedAddOns must be …claude-p27-stage-<8 hex>\AddOns` |
| `ls -d D:/Projects/Project_WF/_local_only/claude-p27-backup-*` after all dry runs | none |

Raw outputs: `<scratch>/stage.txt`, `dry7.txt` (pwsh 7), `dry51.txt` (5.1), `help.txt` (robocopy text is cp949).
The 66 new files = `!DevilForever_Core/Presets/V2.lua`, `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua`, `Media/ThemeSwitcher/LICENSE-OFL.txt` + 63 TGA (the game copy predates both).

## Decisions I made (my judgment)

1. The staging tree includes Hekili folders: brief-52 says the same folder set as the release build (install.json). R153 keeps Hekili *work* out; the check list drops Hekili lines.
2. The installer checks the staged tree against `receipt.json` (every file size + sha256, folder list) before anything else.
3. Mirror uses robocopy `/MIR /COPY:DAT /R:1 /W:1 /XJ` per package folder; afterwards each package folder's inventory must equal the staged folder. robocopy compares size/time, so a file with the same size and time but other content would be skipped — the post-copy hash check stops the script in that case.
4. Dry run still reads and hashes the game AddOns/WTF (counts printed) and runs `robocopy /L`, which writes nothing.
5. Folder-name allow pattern `^[A-Za-z0-9!_.-]+$` for package folders (all 35 match).
6. Check list: Grid2 test layout through `Grid2Layout:SetTestMode` (the function the options button calls); PitBull4 through `PitBull4:SetConfigMode`; Quartz through `/q3` Toggle Bar Lock; status-strip text fallback through `Edit:Set/Clear` of `statusstrip.bar` font. Items needing combat, real party members, real auras or auto shot are marked 「플레이 필요 — 이번 확인 제외」. Grid2 new-character item needs a new character (not gameplay) — left to the user.

## Decision Queue

1. Real install (`install_local.ps1` without `-DryRun`) is master's; backup root name to choose then (dry run used `claude-p27-backup-fc74f5af`, not created).
2. Hekili folders are in the staged tree (release folder set). If R153 means "do not install Hekili", the stage must be rebuilt without them — not done.
3. Theme-switcher «file left out of the table» and «one theme only → disabled» are not checkable in game without editing game files; the list points to the code tests instead.
4. `patches.py` `os.devnull` on Windows (same as Step 51 queue item 1).

## Remaining

Nothing inside brief-52 except the real install (master). Nothing committed.

## Fix round 1 (audit M1·M2·M3, master triage `TRIAGE_phase27.md` 「Step 52 review」)

Read for this round (file : lines): `TRIAGE_phase27.md` 21–41 · `Collection/codex-briefs/phase27-game-check.md` 1–97 (all, before edit) · `Collection/tools/install_local.ps1` 1–203 (all, before edit) · `!DevilForever_Core/Presets.lua` 300–330 · `Presets/V2.lua` 8–20, 140–156 · `Presets/{fhd,qhd,uhd}.lua` Grid2Layout fragment on line 730 (grep) · `Grid2/GridLayout.lua` 870–916. The audit log itself was not used as input.

Note: the Grid2 `PosY` of fhd is on `Presets/fhd.lua:730` (`["PosY"]=776*factor`), not :272 (:272 is the `statusstrip.bar` edit line); qhd/uhd same line 730 (`988*factor`, `1398*factor`).

### Impact map rows vs what was done

| Triage row | Effect | Done |
|---|---|---|
| `phase27-game-check.md:33` formula | fix | :33 now `h − f:GetBottom()*f:GetEffectiveScale()/PixelUtil.GetPixelToUIUnitFactor()` (from the screen top) + basis line (Grid2 saves `GetBottom()*scale` as PosY, `GridLayout.lua:882`; preset PosY = physical px × factor) |
| `:38` and other lines comparing physical y | fix (check all) | :38 values 304/452/762 · 347/541/904 kept (they are top-based and now match the formula); other y mentions (:40 "최대 13 px" relative, :58 "1번 좌표" pointer) need no change |
| `install_local.ps1:165–201` | fix | `$gameWriteStarted` set just before the first real mirror (:186); catch (:208–216) prints ERROR, "game folder … partly changed", backup path and the restore commands from `Get-RestoreText $backup`, exit 1; dry run never sets the flag |
| `install_local.ps1:29–32` help, `phase27-game-check.md:13` | check only | help now builds its restore lines from the same `Get-RestoreText` (:14–20, :38–39) → help and failure text are equal; check list :13 has the same two robocopy lines (placeholder `<백업>`) — unchanged |
| `phase27-game-check.md:4`, `:38`, `:70` and other 「되돌린다」 | fix | :4 states that `/dfp preset`/`/dfp go`/`/pb4`/`/q3`/Grid2 settings rewrite WTF (`Presets.lua:304–306`, `:323–327`) and that the way back is: close the game and copy the §0 WTF backup; :38, :51, :70 point to that rule. :63 (Quartz lock toggle) and :93 (`Edit:Clear` of an edit that was nil) are not settings rollbacks of that kind — unchanged |
| `phase26-step47-check.md` | no effect (record) | untouched |

### Formula check (python)

`factor = 768/h` (= `PixelUtil.GetPixelToUIUnitFactor()` on a 768-unit root); Grid2 saved y = PosY; measure = h − y/factor:
fhd 776×(768/1080)=551.822 → 1080−776 = **304** · qhd 1440−988 = **452** · uhd 2160−1398 = **762** · V2 `PosY=(h−gridBottom)×factor` → 347 · 541 · 904.

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `tasklist /FI "IMAGENAME eq Wow.exe"` | no task |
| pwsh `Parser::ParseFile(install_local.ps1)` | parse errors=0 |
| `pwsh -File install_local.ps1 -StagedAddOns …stage-255f4725\AddOns -BackupRoot …backup-fc74f5af -DryRun` | rc=0 · 35 folders 2275 files c34716a3 · left alone !BugGrabber, BugSack · backup plan 2674/2238, 113/105 · 35 mirror steps · robocopy /L Newer 2209 + New File 66, 0 EXTRA · "partly changed" lines 0 |
| same with Windows PowerShell 5.1 | rc=0 · same lines and counts |
| `-Help` (pwsh 7 and 5.1) | rc=0 · restore block printed from `Get-RestoreText '<backup>'` |
| bad `-BackupRoot` (pwsh 7 / 5.1) · bad `-StagedAddOns` (pwsh 7) | rc=1 / rc=1 / rc=1 · single ERROR line (flag not set before checks) |
| `ls -d …/claude-p27-backup-*` | none (nothing written) |

Failure-after-mirror path: not executed — it needs a real write to the game folder. Judged by reading: the flag is false until line 186, set immediately before the first non-dry `robocopy /MIR`; every later throw (robocopy exit ≥ 8, post-copy inventory mismatch, installation.json write) lands in the catch, which prints the four lines and the restore commands with the actual backup path, then `exit 1`.
Raw: `<scratch>/dry7b.txt`, `dry51b.txt`, `help2.txt`.

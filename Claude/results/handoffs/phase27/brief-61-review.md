# Brief — Phase 27 Step 61 review (same review sub B)

Type: code ③ structural — 3 rounds, refute mandate, no empty pass. Work tree not committed; base `821f2a1b`.

## Scope (read in full)

Changed: `Collection/AddOns/Chattynator/Display/Main.lua`, `Collection/AddOns/Chattynator/Core/Fonts.lua`, `Collection/patches/Chattynator.patch` (header + hunks), `Collection/AddOns/DevilForever_ChatSetup/Chattynator.lua`, `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` (changed parts + the fragments they touch), `Collection/AddOns/!DevilForever_Core/Presets/V2.lua`, plus the re-apply code (`Core.Presets:ReapplyOutdatedLayout`, wherever it lives), `Collection/tests/{chatsetup/run.py,layoutv2/run.py,statusstrip/theme_switcher.py}` changed parts, `Collection/codex-briefs/phase27-game-check.md` §6/§10/§11, `Collection/install/설치안내.md` changed lines.
Linked: the parts of PitBull4 (`Collection/AddOns/PitBull4` ModuleHandling, Text/Name font use, CastBar), Quartz Player/Target placement code they rely on, `ThemeSwitcher.lua` revision check, `Profiles:Go()` / `Presets:Restore`, Chattynator `Display/Main.lua` / `Display/Buttons.lua` parts used by the window geometry.
Record: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` sections "Step 61 fix" and "Step 61 fix, continued (items f-i)" (command lines; do not rerun unless missing or contradictory; impact maps — look for connections outside them).

## User requests (ledger R169–R185)

(a) 한/영 works: edit box scale 1 (R172 test). (b/c) message area = theme panel inner rectangle, tab row above (R173/R175; A chose R175 when both cannot hold — accepted by master as default). (d) battleground groups in window 2 seed. (e) every LFG-named channel to window 3. (f) PitBull4 player/target name text scaled to frame. (g) V2: Quartz Player bar under the player frame like Target; PitBull4 cast bar gone; focus aura rows same size and height as the pet rows. (h) stray PitBull4 cast bar off in Old and New. (i) on first login after install, re-apply the active New/Old preset once when the stored revision is older; no WTF hand edits; Chattynator untouched.

## Rounds

1. Connection/compat: data each piece writes vs what PitBull4/Quartz/Grid2/Chattynator read; revision numbers vs the theme switcher's New/Old detection; FUF variant copies; Old/V1 path.
2. Runtime safety (adversarial): re-apply loop risk (reload → stale again → reload), combat, profile switch, missing addons (Quartz/Grid2 off), first install with no profile, IME/scale math with other font sizes, edit box anchors in all positions.
3. User intent: each item a–i matches the request text; nothing the user set by hand is overwritten beyond the development overwrite of R162 (note what re-apply resets); check list tells the user what to look at.

## Report

First line counts (critical · medium · minor). Critical/medium: file:line, what breaks, quoted lines, connected places, pre-existing or not. Minor up to 5. Read ranges. Read only.

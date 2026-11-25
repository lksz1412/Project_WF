# Brief — Phase 27 Step 63 review (same review sub B)

Type: code ③ structural — 3 rounds, refute mandate, no empty pass. Work tree not committed; base `0f9351d0`.

## Scope (read in full)

Changed: `Collection/AddOns/!DevilForever_Core/Presets.lua` (changed parts + the request/fragment apply functions they use), `Collection/AddOns/!DevilForever_Core/Presets/V2.lua` (removed re-apply), `Collection/tests/layoutv2/run.py` catch-up block, `Collection/tests/statusstrip/theme_switcher.py` change, `Collection/codex-briefs/phase27-game-check.md` :70, :115–116, :126, `Collection/install/설치안내.md` new line.
Linked: `Core/Profiles.lua` (ready step, takePending, writeFragment, ADDON_LOADED order), `ThemeSwitcher.lua` switch takeover, fresh-install path (`dueFragments`, `onAddonLoaded`).
Record: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` sections "Step 63 … mechanism found before the change" and "Step 63 — what changed" (commands; do not rerun unless missing or contradictory).

## User request

R205: nobody types a command or presses anything after installing an update; layout values apply by themselves (same load where possible, else next load automatically); new installs need nothing; foreign profiles untouched; switch never blocked.

## Rounds

1. Connection/compat: writes happen before each target reads its saved variables; AceDB already-open skip; due list consumed next load; revision bump to 4 for the user's profile (New, rev 3); interaction with an armed `/dfp go` request or a switch request in the same load; FUF.
2. Runtime safety (adversarial): load order different from assumed (Grid2/Dominos after PitBull4, or PitBull4 disabled), character unknown at ADDON_LOADED, repeated loads, partially applied state (PitBull4 rev 4 while Grid2 waits — anything reading revision to decide New/Old mid-way, e.g. the switch), profile switch, `/dfp cancel`, Quartz absent.
3. User intent: no command anywhere in the update path (notice, check list, install guide); the user's own case (New rev 3) ends at New rev 4 with totem bar/Grid2 on the next login; check list tells the user what to expect.

## Report

First line counts (critical · medium · minor). Critical/medium: file:line, what breaks, quoted lines, connected places, pre-existing or not. Minor up to 5. Read ranges. Read only.

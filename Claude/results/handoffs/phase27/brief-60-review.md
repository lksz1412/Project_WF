# Brief — Phase 27 Step 60 review (same review sub B)

Type: code ③ structural — 3 rounds (rounds = one perspective over the whole scope each; windows inside a round are reading units, not rounds). Refute mandate: try to break it. No empty pass: if critical/medium = 0, write what you read and what you tried.

## Scope (read in full)

Changed or new (work tree, not committed; base `4b5f2436`):
- `Collection/AddOns/Chattynator/Skins/DevilForever.lua` (new, 220 lines) and the TOC line in `Collection/AddOns/Chattynator/Chattynator.toc`
- `Collection/patches/Chattynator.patch` (new)
- `Collection/AddOns/DevilForever_ChatSetup/Chattynator.lua` (new, 328 lines), `ChatSetup.lua`, `ChatLayout.lua`, `DevilForever_ChatSetup.toc`
- `Collection/AddOns/DevilForever_Skin_NativeChat/Skin.lua`
- `Collection/tools/extract.py`, `Collection/install.json`, `Collection/AddOns/!DevilForever_Core/registry_extra.json` (generated `Registry.lua`, `manifest.json/md`: check only the Chattynator rows)
- `Collection/tests/chatsetup/run.py`, `Collection/codex-briefs/phase27-game-check.md` §10
Linked files (read the parts they rely on): upstream Chattynator `Core/Config.lua`, `Core/Initialize.lua`, `Skins/Main.lua`, `Skins/Dark.lua`, `Display/Main.lua`, `Core/Overrides.lua` (folder `Collection/AddOns/Chattynator/`), `!DevilForever_Core` Edit/Theme APIs used, `DevilForever_Appearance` `GetPixelUnit`.

Work record (use its command output lines, do not rerun tests unless a record is missing or contradicts the code): `Claude/results/handoffs/phase27/iter_4/work_log-60.md` sections with commands and results, and its impact map (check it and look for connections outside the map).

## What the user asked (R167)

Window 1 = general chat (say, yell, emote) + channels 1–3; window 2 = whisper, guild, Battle.net whisper, raid, party; window 3 = the looking-for-group channel if Forever has one (user joins later). Chattynator replaces the native chat; native skin only when Chattynator is off. Already decided (do not reopen without file:line evidence): system/loot/money/errors in window 1; message storage off on seed; seed once per profile, never overwrite user changes; Devil skin default only on first run; Prat not shipped.

## Rounds (perspectives)

1. Connection/compat: data shape written to Chattynator config matches what Chattynator reads (tabs, groups, channels, whispers, position/size, options keys); load order; behaviour with Chattynator absent / Core absent / Appearance absent; skin registration timing vs Chattynator's skin init; TOC and patch match the files; build lists.
2. Runtime safety (adversarial): combat lockdown and taint (frame moves, SetPoint on protected frames, hooks), event storms (CHANNEL_UI_UPDATE loops), nil channel info on Forever, secret values, first login vs `/reload` vs relog, profile switch, a user who already used Chattynator, multiple characters.
3. User intent and correctness of the split: every chat type the user named lands in the right window, nothing named is lost, LFG detection by id 26 / names, later join moves only when unassigned, layout following stops after the user moves a window, check list §10 tells the user what to look at.

## Report

First line: counts per grade (critical · medium · minor). For each critical/medium: file:line, what breaks, the quoted original line(s), connected places, whether it existed before. Minor: one line each, up to 5. Read ranges per file. No fix proposals column. Read only; do not edit any file.

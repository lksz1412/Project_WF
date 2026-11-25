# Brief — Phase 27 Steps 64(c)–68 review (same review sub B)

Type: code ③ structural — 3 rounds, refute mandate, no empty pass. Work tree not committed; base `111f00b5` (plus master's `git rm` of six `layout_{new,old}.tga`).

## Scope

One combined change covering:
- Step 65 kept part: PitBull4 debuff gap (`Collection/AddOns/PitBull4/Modules/Aura/Layout.lua`, `Collection/patches/PitBull4.patch`).
- Step 66: Devil target structure — equal chat panels, uniform borders, chat text areas, minimap inside its panel, Dominos bars 4/5 + pet bar + totem bar right-aligned to the player frame, timestamps off (`Presets/{fhd,qhd,uhd,V2}.lua`, `Presets.lua`, `Defaults/SexyMap.lua`, `DevilForever_ChatSetup/Chattynator.lua`, `DevilForever_Appearance/Themes/horde.lua`, Codex brief `Collection/codex-briefs/appearance-28-devil-structure.md`).
- Step 67: Old layout and the version switcher removed, catch-up moves Old profiles (`Presets/V2.lua`, `Presets.lua`, `Defaults/SexyMap.lua`, `ThemeSwitcher.lua`, `tools/theme_switcher_art.py`).
- Step 64 (c): Hekili out (`install.json` `not_shipped`, `tools/build.py`, `tools/extract.py`, manifest/registry, Core TOC, presets, tests, docs). Musca items not done (blocked, expected).
- Step 68: Details two windows (`DevilForever_DetailsLayout/Layout.lua`, `.toc`).
- Tests changed in `Collection/tests/{chatsetup,core,firststart,layoutv2,statusstrip,detailslayout,install}/`, docs `phase27-game-check.md`, `install/설치안내.md`, `data/feature-map.md`.

Read every changed code file's changed parts and the functions they call/are called by in full; for the Codex brief read it in full (it goes to another worker).
Record: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` sections "Step 65", "Step 66", "Step 67", "Step 64", "Step 68" (command lines — do not rerun unless missing or contradictory; impact maps — look for connections outside them).

## User requests to check against

R214 (debuff gap), R216–R221 (Devil baseline, equal chat panels, uniform borders, Codex brief: all 13 themes redrawn, no stretched rivets — per-resolution art or centre-only stretch), R225 (pet + totem bars end at the player frame's right edge), R226 (only one layout, no version switch, themes only), R223/R208 (Hekili out of the collection), R227/R228 (Details: damage + threat windows side by side, combined width = one chat panel, height = chat panel), R229/R230 (timestamps off by default, turn on in settings). Already decided: no command after an update (R205); foreign profiles untouched; user changes never overwritten after first setup.

## Rounds

1. Connection/compat: catch-up revision 7 path for Old/older profiles; fresh install ends on the single layout; `-v1` names gone everywhere (tests, docs, `/dfp` help); ThemeSwitcher without the version box (frame anchors, status strip width); build `not_shipped` logic cannot hide a missing folder or ship Hekili; registry/manifest/install.json/verify_archives consistent; Details APIs used as Details defines them; Chattynator inset/timestamp keys; SexyMap fragment in base and -v2.
2. Runtime safety (adversarial): catch-up with partial loads; Details first setup retries/combat/missing TinyThreat/user windows; equal-panel numbers vs action bars and minimap (overlaps); pet bar for non-pet classes and totem bar for non-shamans; UI scale other than the presets'.
3. User intent + Codex brief quality: each request above met; the brief gives exact numbers per preset, the per-theme differences, the two drawing methods, file names/formats, and nothing contradictory with `appearance-27-hud-parts.md`; check list tells the user what to look at; Details default spot recorded as a decision.

## Report

First line counts (critical · medium · minor). Critical/medium: file:line, what breaks, quoted lines, connected places, pre-existing or not. Minor up to 5. Read ranges. Read only.

# Brief — Phase 27 Step 62 review (same review sub B)

Type: code ③ structural — 3 rounds, refute mandate, no empty pass. Work tree not committed; base `d3fc1bb2`.

## Scope (read in full)

Changed: `Collection/AddOns/DevilForever_ChatSetup/Chattynator.lua`, `Collection/AddOns/!DevilForever_Core/Presets/V2.lua`, `Collection/AddOns/!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` (changed parts), `Collection/AddOns/!DevilForever_Core/Presets.lua` (changed parts), `Collection/AddOns/DevilForever_Skin_StatusStrip/ThemeSwitcher.lua`, `Collection/AddOns/PitBull4/UnitFrameLayout.lua` + `Collection/patches/PitBull4.patch`, tests changed parts (`chatsetup`, `layoutv2`, `statusstrip/theme_switcher.py`), `Collection/codex-briefs/phase27-game-check.md` §6/§10/§11/§12, `Collection/install/설치안내.md` changed lines.
Linked: `Core/Profiles.lua` request/pending/Go, Chattynator `Display/Main.lua` (resize bounds, save, edit box), Composition panel/strip rect code (`appearance.ribbon`, joints), PitBull4 indicator placement (`position_indicator_on_bar`, root indicators), Dominos totem bar frame data.
Record: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` section "Step 62" (diagnosis with saved-settings evidence, impact map, numbers, command lines — do not rerun unless missing or contradictory). Saved settings may be read (never written): `C:/Program Files (x86)/World of Warcraft/_forever_/WTF/Account/LKZ1412/...`.

## User requests

R186–R198: (a) 한/영 on every load; (b) New/Old switch never dead after the first-login re-apply (R185 wanted Claude to overwrite settings without hand work — note how far the new "arm only + one line" design meets it); (c) all three seeded chat windows placed with the tab row centred on the theme strip, message area inside the panel (left/right/bottom), nothing past panel border or screen edge, including the user's existing windows (R187, R188, R192 "take particular care with the chat size"); (d) level + name centred; (e) Dominos totem bar centred under the player frame in New; (f) player/target aura rows equal height, PitBull4 totem timer kept and moved next to the totem bar (R198).

## Rounds

1. Connection/compat: saved-values test vs the real saved file; window size raised to 240×140 vs receipt; FIT_VERSION one-time re-place; revision bumps vs ThemeSwitcher; switch cancelling a pending request (only its own kind?); PitBull4 patch fields; Old untouched where promised; FUF variant.
2. Runtime safety (adversarial): repeated re-place loops, user drags after re-place, theme change, UI scale change, combat, a pending request of another kind (e.g. a full preset), `/dfp cancel`, the SetScale 0.99→1 timer in combat or before the box exists, long names, missing Dominos totem bar (non-shaman).
3. User intent: each item a–f matches the request text; the user's 4K uhd numbers in the work log really put the tab row on the strip and text inside the panels; check list tells the user what to do (including whether `/dfp go` is needed after install).

## Report

First line counts (critical · medium · minor). Critical/medium: file:line, what breaks, quoted lines, connected places, pre-existing or not. Minor up to 5. Read ranges. Read only.

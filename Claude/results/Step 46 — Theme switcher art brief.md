# Step 46 — Status-strip theme switcher art brief (Phase 26) — R131·R132

Recorded: 2026-11-24 13:25:11 +0900

## Done
- Codex appearance brief Collection/codex-briefs/appearance-26-theme-switcher.md (47 lines): 13 English script name images × fhd/qhd/uhd + prev/next arrows × 4 states × 3; sizes from presets statusstrip.bar (slots 192×22 / 216×24 / 264×28, canvases 256/256/512 × 32, arrows 32×32) with SetTexCoord numbers; gold script, font default Great Vibes (R132 candidates, OFL 1.1), ship Media/ThemeSwitcher/LICENSE-OFL.txt, no TTF; only ThemeSwitcher.lua changes; textures created once, swapped only in apply(); four text fallbacks (preset, edited size, shipped table, SetTexture false); hover BLEND; slide animation moves image+text; strip background unchanged; checks + deliverables References/codex-appearance/26-theme-switcher/.
- Font search (Haiku, user R132): 7 OFL candidates; preview Claude/results/handoffs/phase26/script-font-preview.png.

## Basis
A2 writer work_log iter_1 (initial, fix 1, fix 2); B audit iter_1/audit_log.md (3 rounds); triage TRIAGE_phase26.md; master checks: licence lines re-read at source, LICENSE_RE match test.

## Gates
banned-word grep 0; cited paths exist on Codex branch; numbers checked by A2 and B.

## Next
User: font choice, combat disabled-look question. Codex: run the brief. Step 47 (merge live branch) on user go.

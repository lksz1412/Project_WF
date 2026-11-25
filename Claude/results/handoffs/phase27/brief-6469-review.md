# Brief — Phase 27 review of Step 64 (Musca Auras items a, b, d) + Step 69 (same review sub B)

Type: code ③ structural — 3 rounds (connection/compat · runtime safety, adversarial · user intent), refute mandate, no empty pass. Work tree not committed; base `309b0e60`. Read only; do not edit files, do not delete anything.

If you were compacted since your last review, re-read in full the target and linked files below before judging, and note the ranges.

## Scope

Step 64 (Musca): `Collection/tools/extract.py`, `Collection/install.json`, `Collection/manifest.json/md` (Musca rows), new `Collection/AddOns/!DevilForever_Core/Defaults/WeakAuras.lua`, `Defaults.lua` (new `freshOnly` option — read the whole defaults engine flow it changes), `API.lua`, Core TOC, `registry_extra.json` / `Registry.lua` (Musca entries), `tests/core/run.py`, `tests/install/verify_archives.py`, docs (`install/설치안내.md`, `data/feature-map.md`, check list §16). Upstream Musca folders `Collection/AddOns/WeakAuras*` are unchanged copies — only read the mute paths the change relies on: `WeakAuras/RegionTypes/RegionPrototype.lua` ~185–200, `WeakAuras/BlizzardAuraDisplaySounds.lua` ~90–105, `WeakAuras/WeakAuras.lua` ~580–600, ~1880–1890, ~4365–4375, and how `WeakAurasSaved` is created at load (fresh vs existing).

Step 69: `Presets/{fhd,qhd,uhd,V2}.lua` (Grid2 sizes, revision 7→8), `Defaults/Grid2.lua` (one-time text resize), `DevilForever_DetailsLayout/Layout.lua` + `.toc` (stack, text sizes, one-time move), tests `layoutv2`, `detailslayout`, `firststart`, docs (install guide, feature map, check list §15 rewritten, §17 new). Read the Details API functions the code calls in the Details source (`SetBarSettings`, `SetBarTextSettings`, `AttributeMenu`, window size/position calls) and the catch-up code in `Presets.lua` that revision 8 triggers.

Records: `Claude/results/handoffs/phase27/iter_4/work_log-60.md` sections "Step 64 (Musca Auras: items a, b, d)" and "Step 69" — command verdict lines (do not rerun tests unless a record is missing or contradicts the code), impact maps (look for connections outside them). Screenshot reading: `iter_4/image-17-reading.md`.

## User requests to check against

R223 ("Musca로", sounds off — "소리는 없어도돼. 오히려 방해돼"), R232 (download approved, 1.21.0 shipped). R233 Grid2 ≈75% of what is shown now; R237 Grid2 text too small; R234 chat height does not match (A changed no code — judge the evidence in the work log); R235 Details: right above chat 3, from where the Dominos bar ends to the right edge, threat on top, damage below; R236 Details text too small.

## Already decided (master, 2026-11-26)

- Details windows the collection made are moved once to the new stack even if the user dragged them after Step 68 — R235 asked for the new spot. Windows the user created stay alone.
- fhd best fit (two thin windows above the bar row) and the overlap with the right theme ornament on every preset are accepted defaults, reported to the user.
- Musca 1.21.0 (approved version) ships, not 1.22.0. `WeakAurasSaved` is not in `/dfp` save/restore.

## Rounds

1. Connection/compat: `freshOnly` in the defaults engine — every existing target unchanged; what "fresh" means when `WeakAurasSaved` is created by WeakAuras before/after Core's hook; registry/manifest/install.json/verify_archives/build consistent for the five Musca folders; revision 8 catch-up path; Grid2 one-time text resize only on values the collection wrote; Details API calls as Details defines them.
2. Runtime safety (adversarial): Musca loaded without Core, Core without Musca, an account with another WeakAuras build; Details first setup vs one-time move, combat, TinyThreat missing, window 2 missing, user-created windows; Grid2 profiles the user edited; stack rectangles vs Grid2 / quest tracker / unit frames / action bar on all presets; repeated loads (no repeat moves).
3. User intent: each request above met; check list §15–§17 tell the user what to look at; nothing the user set by hand overwritten beyond the decided Details move.

## Report

First line counts (critical · medium · minor). Critical/medium: file:line, what breaks, quoted lines, connected places, pre-existing or not. Minor up to 5. Read ranges. No fix proposals.

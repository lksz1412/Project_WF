# Audit log — Step 46 review 1 — B (bada-a3-reviewer) — appearance-26-theme-switcher.md ②
Counts: 중대 0 · 중간 3 · 경미 6
- M1 user-edited strip size (ThemeSwitcher.lua:62–66 recompute from Edit:Get) not covered — brief :24 forbids stretching, :31 fallback only for preset/file table; precedent Composition.lua:73–76 drops composite on edits.
- M2 hover texture blend undefined (:12, :30) — Button highlight default ADD would oversaturate a complete gold image (inferred API behaviour).
- M3 font licence handling missing (:14 only index) — candidates file :15 says ship OFL.txt; precedent Details/fonts/SIL Open Font License.txt; manifest StatusStrip skin "license_files": []; R132 candidates not in brief.
- m1 disabled state practically never shown (:34, :39), no Disable()/Enable() instruction; m2 arrow fallback unit (per preset, not per theme) unclear (:31); m3 hide FontString when image shown (:30); m4 table-listed but missing file → no SetTexture==false fallback (cf. Composition.lua:131); m5 SetTexCoord numbers not given (:24); m6 animation only on FontString (ThemeSwitcher.lua:15) — image needs same animation (:33).
Verified: sizes/canvas maths, physical pixels (Skin.lua:132), cited lines, file counts, existing TGA format, preset-switch callback (Presets.lua:284–291), build keeps Media (build.py:27–35).

## Re-check 1 (same B) — 중대 0 · 중간 1 · 경미 3 (was 0·3·6)
- M1–M3, m1–m6 fixed.
- N1 brief :47 hand-edit of manifest license_files, but manifest is generated (extract.py:556) and license_files re-found by LICENSE_RE (extract.py:158) which does not match "OFL.txt" → lost on regeneration.
- m: button textures set by path cannot report SetTexture false (:32/:33); fallback cleanup (clear button textures, re-show arrow FontStrings :27–28) unstated; disabled-state check has no recipe.
Master: LICENSE_RE matches "LICENSE-OFL.txt" (checked) → rename the shipped licence file instead of hand-editing manifest.

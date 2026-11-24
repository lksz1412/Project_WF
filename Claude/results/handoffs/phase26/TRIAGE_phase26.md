# Triage — Phase 26

## Already decided
- R131 images by Codex, Claude plans; R130 ⑥ background unchanged, gold script; R117 no runtime burden; R132 font candidates (OFL 1.1, master-verified).

## Step 46 review 1 — master triage
| ID | Verdict | What / why |
|---|---|---|
| M1 | fix | edited strip font/height differing from the preset slot → text fallback (same rule as Composition's edit fallback) |
| M2 | fix | name the method: SetHighlightTexture(path, "BLEND") with a complete image, or swap the normal texture on enter/leave — pick one, state it |
| M3 | fix | list the R132 candidates (default Great Vibes unless the user picks), ship OFL.txt beside the images in Media/ThemeSwitcher/, do not ship the TTF, Claude updates manifest license_files in its later check |
| m1–m6 | fix together | Disable()/Enable() rule (default: disabled only when ≤1 theme; combat keeps refusal+tooltip — user question open), arrow fallback per preset, hide the FontString while an image shows, SetTexture()==false → text fallback, give the texcoord numbers, animate image and text together |

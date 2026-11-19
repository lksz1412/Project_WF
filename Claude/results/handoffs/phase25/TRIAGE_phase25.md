# Triage — Phase 25

## Already decided (carried)
- R110: unit default by Codex comparison; nameplate castbar kept; clock = status strip only (minimap clock hidden); Aurora limits accepted; restore-scope risk accepted.

## Step 44 audit (B af00496cd38816ba0) — master check
| ID | Master check (source quote) | Verdict | What / why |
|---|---|---|---|
| C1 | install.json:4 "0.1.2"; build.py:298-300 version check — confirmed | defect (Step 40) | branch cannot rebuild its own package; decide source layout (upstream copies in Collection/AddOns vs upstream extract) then fix install.json/manifest/genregistry |
| M1 | Defaults/SexyMap.lua:144-151 — confirmed | defect (Step 40) | appearance via Defaults overwrites layout of existing SexyMap users; move to preset fragment (nil-SV only) |
| M2 | pitbull4/manifest.json:237-238 "unmodified" — confirmed | defect (Step 40) | record patches (patch files + manifest "modified"); else normal build drops them |
| M3 | — | decision needed (user) | Prat dropped for native chat by Codex (Codex trace cites R112/R145 — Codex-local R numbers, not on branch); plan Phase 4 says Prat |
| M4 | — | test update (Step 40) | contract holds; fixture must exclude Presets/ |
| M5 | — | client check (Codex) | load-time scale constants |
| m2 | Defaults/SexyMap.lua:70 "never" — confirmed | accepted | = R110 ③ |
| perf ×4 | TinyThreat 90-92/912-915 — confirmed | low priority | upstream behaviour; small cost; patching as-is addons only if user wants |
| candidates ×4 | receipt + TOC 16001 present (FarmerNodes/WhatsTraining multi-interface) | optional only | not for default set (R101); game untested |

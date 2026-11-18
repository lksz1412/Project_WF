# Phase 23 detail plan — Collection integration check and fixes

[Phase 23 start — master plan re-read in full 1–549 (Read 1–240, 241–390, 391–549) on 2026-11-18.]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 37 | Static integration check: combos (required bundle only / everything on / each feature off), TOC + deps resolution incl. upstream start addons, registry vs manifest vs TOC SVs, load order, one-function-two-addons duplicates, install ZIP vs manifest + SHA list, install list (which third-party originals ship, D4), Dominos_Cast/Progress/Roll exclusion, unit-frame default (FUF vs PitBull4 — Codex comparison not yet in, R109), install notes (first-time steps: Tiny Threat window etc.), collected open minors from Phase triages → fix list for Step 38 | A2 coder | integration report with every check result + fix list | master check | 90–150 | ⏳ |
| 38 | Fix the defects found, re-run the linked checks | same A2 | all gates | B code logic review 1 on the fixes + adversarial (plan line 431) | 60–120 | ⏳ |

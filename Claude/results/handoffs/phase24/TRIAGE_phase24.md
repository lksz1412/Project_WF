# Triage — Phase 24

## Already decided (carried)
- Solo state, no Grid2; no game nameplates; PitBull4 provisional default + one FUF crop; classes WARRIOR/ROGUE/SHAMAN/DRUID-cat; Aurora excluded; Codex picks zoom factor; References/codex-appearance/ absent (upload targets).

## Review 1 (B a85df9716ff2f9bbd) — appearance-24.md
| ID | Master check (source) | Verdict | What / why |
|---|---|---|---|
| M1 | layout doc 45–56 has no Quartz/Hekili/Details/XP rows — confirmed | fix | Regions without Step 5 coordinate and without result: do not draw a guessed box; list in index 「자리 없음 — 못 그림」 (no invention, plan 413) |
| M2 | appearance-10.md:31, -4.md:32, -22.md:26 ask for game screenshots — confirmed | fix | Forbid using any screenshot (incl. from appearance results) as image source; draw only from code/fragment values, assets, tokens |
| M3 | manifest.json/.md, registry_extra.json exist; brief cites none — confirmed | fix | Add manifest + frame-name list to inputs (plan 351/433) |
| m1 | same input paragraph as M3 | fix together (impact map) | "모두" wrong — say which inputs exist now |
| m2 | | minor → final report | |
| m3 | R109 in REQUEST_LEDGER_phase19.md:7 | not a defect | user decision recorded in request ledger |
| m4 | | fix together (cheap, same §2-3 sentence) | UHD: use uhd.lua preset if present, else Step 5; note differences in index |
| m5 | | fix together (same §1 row) | key glyphs = text-metrics.json sample keys only |
| m6 | | minor → final report (solo state already decided) | |

## Re-check 1 (same B) — middle 3 → 1
| ID | Master check | Verdict | What / why |
|---|---|---|---|
| M1′ | :35/:37 Dominos bars; layout :60 no stance/totem positions — confirmed | fix | Class crops: resource elements without result or coordinate follow :55 (「자리 없음 — 못 그림」); Dominos bars come from appearance-3 result if present |
| m1 | :51 vs :61 — confirmed | fix together (same index spec) | add frame-name column; rows for not-made images |
| m2 | | fix together (one word) | example says "Step 5 설계나 preset 에 자리가 없으면" |
| m3 | REQUEST_LEDGER_phase19.md:7 — confirmed | fix together | cite Phase 23 provisional decision (설치안내.md:28) instead of R109 at :29 |

## Re-check 2 (same B) — middle 1 → 0. Closed.
| ID | Verdict |
|---|---|
| m-a :29 citation covers part of sentence | minor → final report |
| m-b :17 crop vs Dominos bars | minor → final report |
Remaining minors for final report: review1 m2 (FHD/QHD label spot), m6 (solo state: combat/target/cast undefined); re-check2 m-a, m-b.

# Step 28b — Status strip addon (Phase 16)

Recorded: 2026-11-18 19:02:11 +0900

## Done
New addon `Collection/AddOns/DevilForever_StatusStrip/` (TOC + StatusStrip.lua 714 lines): gold, free general-bag slots, lowest durability, local 24 h clock, latency home/world, fps; 1 s shared ticker (latency every 30 ticks, clock on minute change), events for gold/bags/durability, no hooks/secure/CVar/colours, mouse-through, /dfstatus, account SV with fill-missing and unknown-schema guard, LAYOUT callback API for Codex. Registry entry + Registry.lua regenerated, tests/statusstrip/run.py (20 cases), core test registry expectations, Codex briefs phase16.md / appearance-16.md, ZIP rebuilt (sha256 2460bd1de6dd86f71dc15f7a990144fe2a45b7da2561eb88dd0a7fcbe5ef9df4) and hash in 26 briefs.

## Basis
Spec = handoffs/phase16/design-28a.md + DECISIONS_28a.md. A2 read ranges and impact map: handoffs/phase16/iter_1/work_log-a2.md (initial + Fix 1). Master triangulated B quotes (phase16.md:32,45,53; StatusStrip.lua:134,206,422,473,570; appearance-16.md:25,31) and re-ran statusstrip 17/17 and core 61/61 before review.

## Impact map (summary — full rows in TRIAGE_phase16.md and work_log Fix 1)
| Place | Verdict |
|---|---|
| StatusStrip.lua fps/runLayout/events/header | fixed |
| run.py new cases | fixed together |
| phase16.md, appearance-16.md | fixed |
| ZIP + 26 brief hashes | fixed together |
| registry | check only (up to date) |

## Gates
luacheck checked=15 failed=0; statusstrip 20/20; core 61/61; other own-addon tests pass; genregistry --check up to date; tocdeps unresolved 0; build ×2 same sha256; /run ≤255 bytes; banned words 0. Review B 0/3/6 → re-check 0/0/2.

## Next
Phase 16 close; Phase 19 Experience Forever.

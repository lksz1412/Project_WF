# Review triage — Phase 6
## Check 1 — FUFDefaults (B 1 pass: critical 0 · major 1 · minor 5)
| ID | Verdict | Fix · why |
|---|---|---|
| M1 | confirmed major · design change | FUF party lives in the account-wide shared profile, so a per-character once-only switch cannot be safe. FUFDefaults touches only FUF **raid** (per character). Party frames stay FUF's. Overlap is avoided on the Grid2 side in Phase 9 (Grid2 shows raid groups only, not party). Remove party code, records and tests; add a test that a shared-profile alt keeps party on. Why: never override a user value, never affect characters without Grid2. |
| minor 2 | include | run after FUF's 15 s fresh-install save hold (delay ≥ 20 s after first PEW) and verify raid value after sending (already for raid). |
| minor 4 | include | fix Boot.lua citations (27, 31, 91–93) in tests and work_log. |
| minor 1 | moot (party removed) |
| minor 3, 5 | not fixed → final report (api-missing permanent; Grid2 "loaded" not collection on/off) |
Phase 9 note (carry to Phase 9 brief): Grid2 must not show party when FUF party is on — party = FUF, raid = Grid2.
Master decision on A2 DQ 3 (warlock soul shards not shown by FUF): (가) leave for now → final report as an R61 gap candidate.

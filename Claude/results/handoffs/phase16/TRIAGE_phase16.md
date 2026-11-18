# Triage — Phase 16 (Step 28b, DevilForever_StatusStrip)

## Already decided (carry forward)
- Separate addon; local 24 h clock on; /dfstatus; no warning colour, tooltip, ammo (DECISIONS_28a.md).
- No hard-coded look (R87); no hooks on Blizzard frames, no secure templates, no CVar writes.

## Review B (0 / 3 / 6) — master triangulated (quotes confirmed at phase16.md:32,45,53; StatusStrip.lua:134,206,422,473,570; appearance-16.md:25,31)
| ID | Verdict | Fix (what · why) |
|---|---|---|
| M1 phase16.md latency check requires exact equality with live GetNetStats while the strip caches every 30 ticks | major, confirmed | Expected result: each of the two numbers within 100 ms of the live GetNetStats home/world value (state the rule explicitly). Why: cached value is correct by design; Codex must not judge. |
| M2 phase16.md quiver check — moving ammo from a general bag correctly changes the count | major, confirmed | Replace the "put in / take out" step with: while a quiver/special bag has free slots, the strip number equals the manually counted general-bag free slots. |
| M3 coin colours promised later but no contract path | major, confirmed | Master decision: no coin colours (R87; one colour per FontString is the contract). phase16.md:32 says "글자 색 없음 — 동전 색은 넣지 않는다", appearance-16 says the gold text is plain and the skin may set one colour for the whole FontString. Record as accepted design deviation. |
| m1 per-tick table/string alloc for fps | minor → fix | reuse a table; format only when the integer fps changes |
| m2 SetSpacing inside LAYOUT recursion | minor → fix | re-entrancy guard in runLayout (ignore nested call, run once after) + one line in appearance-16 |
| m3 RegisterEvent returning false not treated as failure | minor → fix | treat `ok and result == false` as failure too; phase16.md:9 wording "확인 필요 — 등록 실패가 오류 없이 지나갈 수도 있다" |
| m4 failedEvents dead state | minor → fix | remove |
| m5a family nil counted as general | minor → keep, list as declared deviation in work_log | |
| m5b ListItems header says positional | minor → fix header to named fields |
| m6 Skin overwriting OnShow/OnHide breaks ticker | minor → fix brief | appearance-16: do not SetScript OnShow/OnHide on the strip frame; use HookScript |

## Impact map
| Place | Verdict | Why |
|---|---|---|
| StatusStrip.lua fps refresh, runLayout, event registration, failedEvents, header | fix | m1–m5b |
| tests/statusstrip/run.py | fix together | add cases: no alloc per tick when fps unchanged (count table creations or same table identity), nested SetSpacing from LAYOUT runs layout once more and no recursion, RegisterEvent returning false is reported |
| phase16.md :9, :32, item with latency, item with quiver | fix | M1–M3, m3 |
| appearance-16.md gold / spacing / OnShow-OnHide lines | fix | M3, m2, m6 |
| ZIP + hash in all 26 briefs | fix together | code changes → rebuild |
| registry_extra / Registry.lua | check only | no contract change expected |
| records | no change | |

## Re-check (same B): 0 / 0 / 2 — all fixed. Minor to final report: n1 layoutRunning flag sticks if anchorShownItems raises (theoretical); n2 appearance-16.md:29 still mentions colouring units separately (conflicts with one-colour rule).

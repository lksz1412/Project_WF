# Triage — Phase 15 (Step 27, Aurora Codex briefs)

## Already decided (carry forward)
- Codex decides Aurora use (R107 ④), weighed against R101; nothing shipped now; ZIP d0210532… unchanged.
- Pattern = phase14/appearance-14 (separate move folder, full restore, originals recorded and put back, CVar rule).

## Review B (0 / 1 / 4) — master triangulated
| ID | Verdict | Fix (what · why) |
|---|---|---|
| M1 appearance-15.md:13,24 — Aurora's own CVar write (`questTextContrast`=4 on every load, `Skin/init.lua:342–344`, confirmed) not in the 갈래 A record/restore rule | major, confirmed | Branch A: DevilForever_Skin_Aurora records the original `questTextContrast` in our SV before Aurora's first change is observed (or Codex records it from phase15 item 1), and its restore command puts it back; acceptance line checks it with `GetCVar`. State that removing Aurora alone leaves the CVar at 4. Why: same rule as appearance-14 — no change without recorded original and way back. |
| m2 phase15.md:85–86 — no step when questTextContrast is not back after restore | minor → fix | Add: if not back, `/run SetCVar("questTextContrast", <1번 값>)` then check again. |
| m3 phase15.md:85 — bugsack.txt missing from upload list (also line 5) | minor → fix | Add it. |
| m4 phase15.md:12 — "접속할 때마다" → also on `/reload` | minor → fix (wording) | "접속·/reload 때마다". |
| m1 commit hash inside the same commit (same as phase14) | minor → final report list | pattern-wide; Codex writes hash in its reply |

## Impact map
| Place | Verdict | Why |
|---|---|---|
| appearance-15.md:13, :24 | fix | M1 |
| phase15.md:5, :12, :85–86 | fix | m2–m4 |
| phase15.md item 1 (original questTextContrast recorded) | check only | source of the original value for M1 |
| appearance-14.md | no change | its rule is the pattern, already covers its own CVars |
| records | no change | |

## A2 Decision Queue — master decisions
1–4 (Aurora nameplate/CDM/buff skins not togglable, questTextContrast, GC change): Codex records in decision.md; if Codex picks "사용", master puts the open trade-offs (patch Aurora vs accept vs drop) in the final report for the user. 5–6: answered by item 2 output.

## Re-check 1 (same B): 0 / 2 / 0 — m2–m4 fixed; M1 not fixed: N1 (restore command cannot run once Aurora is off — our folder depends on Aurora, appearance-15.md:10,13,24, confirmed by the Dependencies line) and N2 (recorded "original" can be Aurora's own 4 from earlier sessions, confirmed: write persists in Config.wtf).
Majors did not go down (1 → 2) → root-cause change, not another patch on the same rule.

### Root-cause decision (master)
Cause: the way back depended on (a) our Aurora-dependent addon being loaded and (b) knowing the user's exact earlier value. Change the design so neither is needed:
- The way back for `questTextContrast` is one `/run` line that works with no addon: `/run SetCVar("questTextContrast", GetCVarDefault("questTextContrast"))` (game default). `GetCVarDefault` existence on Forever = 확인 필요 → phase15 item 1 checks it and records the default; if it is missing, the fallback is the item-1 (가) value written in the report.
- Our skin addon does not try to own this CVar: it records nothing for it and does not promise to restore it. The brief states that Aurora changes it, gives the `/run` line above as the way back after Aurora is removed, and asks Codex to put that line in its report so master carries it into the Phase 23 install notes.
- The option-restore rule (Aurora options in AuroraConfig) stays as is — it runs while Aurora is on.

## Re-check 2: 0 / 1 / 1 — N1, N2 resolved (B quotes appearance-15.md:13,24). Majors went down (2 → 1).
| ID | Verdict | Fix |
|---|---|---|
| N3 phase15.md:86–87 — item 9 restores to the game default although the user's own original (가) is known; pass accepted even if they differ | major, confirmed | Item 9: set the (가) value first (it is this user's original); expected result = the (가) value. appearance-15.md:13: the install-notes line = (가) value line when the original is known, game-default line when not. |
| n1 phase15.md:23 — "없음" also when the function exists but returns nil | minor → fix wording | "함수가 없거나 기본값을 주지 않는 것". |

## Re-check 3: 0 / 0 / 2 — N3, n1 fixed (master fixed result-field wording at phase15.md:89 as a plain substitution). Minor to final report: unknown-install line has no fallback when GetCVarDefault is missing; item 1 no longer says where the recorded default is used (appearance-15:13).

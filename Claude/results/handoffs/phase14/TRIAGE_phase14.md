# Triage — Phase 14 (Step 26, nameplate Codex briefs)

## Already decided (carry forward)
- Phase 14 ships no addon (R107 ③). Cast = Quartz (Phase 7), threat number = Tiny Threat (Phase 10).
- Briefs use the current ZIP d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820 (no rebuild).

## Review B findings — master triangulated against the files (all quotes confirmed)
| ID | Verdict | Fix (what · why) |
|---|---|---|
| M1 phase14.md:51 `/run` 269 chars | major, confirmed | Split into lines ≤ 255 chars each (chat input limit, estimate) so Codex runs it unchanged. |
| M2 phase14.md:73 incomplete restore | major, confirmed | Restore = full backup restore: quit game, rename current `AddOns` and `WTF` aside, copy the item-0 backup of both back. Why: steps change WTF beyond Config.wtf (per-character AddOns.txt, Core SV). |
| M3 phase14.md:21 nameplate on/off changed, original not recorded | major, confirmed | Record original enemy/friendly on/off in item 1 result line; put back at end of item 1 (or in item 8 before restore). |
| M4 appearance-14.md:19,34 CVar changes outlive the addon | major, confirmed | Skin addon must: save each CVar's original value in its own SavedVariables before first change; set our value once (not every login — if the user later changed it, keep the user's value); give a slash command that writes the originals back; acceptance criteria add "restore command returns every changed CVar to its original". State in the brief that turning the addon off alone does not undo CVars. |
| m1 phase14.md:14 move destination = "백업 쪽" collides with copy | minor → fix (same line as M2) | Name a separate folder for moved addons, e.g. `forever_moved_phase14/AddOns`. |
| m2 phase14.md:36 threat-as-colour stated as fact vs :37 확인 필요 | minor → fix (one phrase) | Say "이름표는 색 등으로 보일 수 있다(확인 필요)". |
| m3 Phase 23 decides cast overlap | rejected | Plan Test Plan Phase 23 row (plan line 431: 「한 기능 두 애드온 중복 (적대)」) gives that check to Phase 23. |
| m4 appearance briefs have no backup step | minor → final report list | Same shape in appearance-2/10; appearance work is Codex's own dev setup. |
| m5 layouts order for nameplates | minor → final report list | |

## Impact map (fix M2 restore line)
| Place | Verdict | Why |
|---|---|---|
| phase14.md:14, :73 | fix | finding |
| phase6.md, phase6-rev.md, phase7.md, phase8.md, phase9.md, phase10.md restore lines ("원래 상태로 돌아가려면 …") | fix together | same incomplete restore shape (B note on phase10:82); briefs not yet run by Codex per References/ (no results on main) |
| phase2–5.md (no restore line, item 0 moves to "백업 쪽") | check only — add the same one-line full restore to their last item | same backup shape; consistent restore path for Codex |
| appearance-*.md | no change | m4 listed |
| Step histories, Results, triage files | no change (records) | |

## A2 Decision Queue — master decisions
1. Registry key for nameplates: deferred — Codex proposes keys, Core registry entry added when appearance results arrive (Phase 23/25).
2. Cast overlap: Phase 23 (see m3).
3. Aurora double skin: add one line to the Phase 15 brief (Phase 15 A2).
4. CVar persistence: = M4 fix.
5. Plan row 446: master updates the row (verification also covers cast bar, settings list, stacking, persistence).

## Re-check (same B) — 0 critical / 0 major / 4 minor; M1–M4, m1, m2 fixed (quotes confirmed by B with file:line)
Minor to final report: m-a CVar per-layout vs set-once (Codex design), m-b restore-flag/SV-loss/per-character CVar edge cases, m-c "keep or drop" wording after full restore (phase6/6-rev/7), m-d result templates of phase2–5 lack a full-restore column, note: phase2–10 item 0 still moves to "백업 쪽" (m1 shape; restore unaffected). Plus m4, m5 from first review.
DQ6 phase5.md:37 /run 257 → 238 chars (same A, fix 1b).

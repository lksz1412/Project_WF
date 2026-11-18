# Triage — Phase 19 (Step 31, Experience Forever)

## Already decided
- No Core defaults file (EF AceDB global defaults already match the row; confirmed ExperienceForever.lua:44,59,82,373). EF not in our ZIP; Codex installs from References ZIP. Dominos_Progress not shipped (phase3.md:8).
- R109: Codex on hold until after work; Claude continues its own share.

## Review B (0 / 2 / 3) — master triangulated (registry_extra.json:880–903 confirmed; Edit.lua:7 size = {width,height} together)
| ID | Verdict | Fix |
|---|---|---|
| M1 registry/appearance offer font + size edits that EF re-applies itself | major, confirmed | Editable items on `experienceforever.bar` = **position only**. Width, height, font size go through EF's own value file per layout (appearance-19 already has that path). Why: Core size edits width+height together (Edit.lua:7) and EF re-applies height/font (source 785–826); an edit with no effect is a broken contract. Update registry_extra, Registry.lua, core test expectations, appearance-19 table and :24 text. |
| M2 phase19 item 3 changes the watched faction without recording/restoring | major, confirmed | Record the original watched faction (name or "없음") before item 3; restore it at the end of item 3 (phase14 pattern). |
| m1 pet dismissed at end of item 4 | minor → fix | re-summon if it was out at start |
| m2 quest completion is irreversible | minor → fix | gain XP by killing a mob only |
| m3 koKR checkbox label unverified | minor → fix | mark 확인 필요, describe by position (평판 탭에서 진영을 누르면 나오는 칸) |

## Impact map
| Place | Verdict |
|---|---|
| registry_extra.json EF editable items, Registry.lua | fix |
| tests/core/run.py EF asserts | fix together |
| appearance-19.md :20, :24 | fix |
| phase19.md items 2–4 | fix |
| ZIP (Registry.lua inside) + hash in all briefs | fix together |
| records | no change |

## Re-check (same B): 0 / 0 / 0 — M1, M2, m1–m3 fixed.

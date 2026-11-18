# Step 33 — Save/restore build (Phase 20)

Recorded: 2026-11-18 20:17:34 +0900

## Done
Inside `!DevilForever_Core`: Profiles.lua (snapshots in DevilForever_ProfilesDB, scoped restore of registry SVs with restore whole/keys/profile/skip, load-time write after /dfp go, version check, undo slot), Presets.lua (layout preset layer token < registry default < preset < user edit; per-addon fragments incl. AceDB global — EF route), Spec.lua (LibDualSpec talent-group link), Commands.lua (/dfp, /dfprofile; keys/game pass-through to ProfileManager). Registry fields restore/shape/keys with generator rules; Core/API contract wording updated. Tests: core 102 cases. Codex brief phase20.md; appearance-2-layouts §5 preset addendum. ZIP sha256 b6392ea37d7cfefa123a3ef023ded82990c1be27826af6f54e23abc6bafd51c1.

## Basis
Spec design-32.md + DECISIONS_32.md. A2 read ranges and impact maps: handoffs/phase20/iter_1/work_log-a2.md (initial, fix 1, fix 2). Master triangulated B quotes Profiles.lua:729–738, 566–568, 590, 880–884, 901–904, Presets.lua:385–391 and re-ran all suites before review (89/89 then).

## Impact map (summary — full rows in TRIAGE_phase20.md and work_log fix 1 / fix 2)
| Place | Verdict |
|---|---|
| Profiles/Presets/Commands/Core/API | fixed |
| tests/core/run.py | fixed together |
| phase20.md | fixed |
| ZIP + 29 brief hashes | fixed together |
| design-32.md | no change (record) |

## Gates
luacheck 21/0; core 102/102, other suites unchanged pass; genregistry --check up to date; tocdeps 0; build ×2 same sha; /run ≤255 bytes; banned words 0. Review B 3 rounds 0/4/10 → re-check 0/3/5 (new code) → re-check 0/0/7.

## Next
Phase 22 alternate theme interface + Codex brief.

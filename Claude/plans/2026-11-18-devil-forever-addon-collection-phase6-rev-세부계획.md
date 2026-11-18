# Phase 6-rev detail plan — PitBull4 Forever variant (compare with FUF)

[Phase 6-rev start — master plan re-read: rows 6, 6-rev, Correction History R107, Phase N table on 2026-11-18.]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 42 | Diff V42 PitBull4 4.2.49-Forever-v42 vs upstream v4.2.50 (find V42's Forever fixes: TOC, Compat.lua, API guards), design the port; read V42 `!DevilUI/Profile/PitBull4.lua` (Devil layout) | A2 | diff summary with file:line in work_log | — | 60–120 | ⏳ |
| 43 | Build `Collection/AddOns/PitBull4/` = upstream 4.2.50 + Forever TOC (16001) + ported fixes; `patches/PitBull4.patch`; Defaults/PitBull4.lua from the Devil profile (functional values only; appearance values → Codex fragment); FUF-vs-PitBull4 comparison table; Codex briefs (phase6-rev.md incl. side-by-side comparison, appearance-6-rev.md) | A2 | luacheck, tocdeps, tests, build | 1 logic review (modified original) | 120–210 (+10–20/class) | ⏳ |

# Phase 16 detail plan — Light status strip (clock, FPS/latency, gold, durability, free bag slots)

[Phase 16 start — master plan re-read in full 1–549 (Read 1–240, 241–390, 391–549) on 2026-11-18.]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 28a | Design: the five info items (APIs/events per item on Forever 1.60.1 — from sources in the repo, unconfirmed marked), update model (events vs throttled timer, no work in combat beyond cheap text), where it lives (inside `!DevilForever_Core` as an optional module vs one small addon — R101 prefers no new addon, R44 prefers separately selectable features: decide and justify), the data/appearance contract for Codex (frame names, registry entry, edit items), what is excluded (heavy items, R107 ⑤) | A1 analyst | design doc complete, every API cited to a repo source or marked 확인 필요 | master check (feeds 28b) | 30–60 | ⏳ |
| 28b | Implement per the design, logic tests in lupa, luacheck, registry, build ZIP + hash in briefs, Codex briefs phase16.md / appearance-16.md | A2 coder | luacheck rc0, tests pass, genregistry --check, build sha256 | B code logic review 1 + adversarial (heavy info mixed in; combat cost; taint) | 60–120 | ⏳ |

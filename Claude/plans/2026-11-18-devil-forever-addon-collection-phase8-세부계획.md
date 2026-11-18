# Phase 8 detail plan — class combat assist (Hekili v0.8.6-forever)

[Phase 8 start — master plan re-read: row 215 (Phase 8 branch structure), Non-goals 289–300 (no recommendation/judgment/rotation logic; static display lists allowed), Interfaces, Test Plan Phase 8 row on 2026-11-18.]

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 18 | Source read: per spec in `Collection/data/classes.md` check ㉠ Hekili class module aura/proc/CD watch data, ㉡ Hekili alert form (EventAlert-style center icon/sound/highlight?) → support table class × spec × (status alert / proc / CD / next-action recommendation) with file:line → branch verdict 1/2/3 | A1 | table covers all 28 specs; every cell cites file:line or "source missing" | master check vs cited lines | 90–150 | ⏳ |
| 19 | Hekili display defaults (D2 가: alerts+CD+recommendation, recommendation separately off-able); if branch 2/3: `DevilForever_Combat` display-only module (static per-spec lists from Hekili data or D7 Codex data; no recommendation/judgment/rotation logic; center icon/sound/highlight each off-able; one feature with Hekili) | A2 | luacheck, tests, tocdeps, build | 3 rounds (new structure module) if module built, else master check | 60–120 (+60–180 if module) | ⏳ |
| 20 | Per-class check (shaman first, R7) + Codex appearance/real-use briefs | A2 | briefs ≤10 items each | master check | 45–75 (+20–40/class) | ⏳ |

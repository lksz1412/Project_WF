# Phase 25 detail plan — Codex verification results → fixes → freeze

[Phase 25 start — master plan re-read in full 1–550 (Read 1–240, 241–400, 401–550) on 2026-11-18 after compaction recovery.]

Inputs needed: `References/codex-verify/phase<ID>/` and `References/codex-appearance/<ID>/`. Checked on 2026-11-18 21:17 KST against origin/main b8a7c50: both folders absent. User R109: Codex on hold until the user's PC is free; Claude finishes its own part first.

| Step | Work | Owner | Gate | Review | Est. | Status |
|---|---|---|---|---|---|---|
| 40 | Fix code defects found by Codex verification results (per Phase brief result tables) | A2 coder + B | static gates + logic review of fixes | code ② | 60–120 (+30–60 per result bundle) | ⏸ waiting for Codex results (R109) |
| 41 | Freeze final bundle (ZIP, manifest, SHA256), restore method, unverified list, handover | master (handover) / A2 (freeze docs after Step 40) | build rc0 + sha256; handover 5 items | — | 30–60 | ⏸ handover written now; freeze waits for Step 40 |

# Review triage — Phase 2

## Already decided
- Phase 0/1 decided items (TRIAGE_phase0.md, TRIAGE_phase1.md) + R83/R86/R87.
- A2 design choices accepted: per-target applied keys; plain SV not created unless createIfMissing; theme switch waits for combat end.

## Check 1 — Core 3 rounds (B: critical 1 · major 3 · minor 5)
Master confirmed Defaults.lua:135–138, 203–208; Theme.lua:84; AceDB-3.0.lua:263–278 regional branch.

| ID | Verdict | Fix · why |
|---|---|---|
| C1 | confirmed critical | Root fix of "first load" semantics for plain targets. (a) Rename the folder to `!DevilForever_Core` (TOC, registry, genregistry, tests, any path refs) so Core loads before other addons in alphabetical order (assumption — add to Codex phase2 brief: confirm Core loads first). (b) For each plain target record at the target addon's ADDON_LOADED whether its SV was nil ("fresh"). If fresh: at the first PLAYER_ENTERING_WORLD after that, write the spec's keys with overwrite (the values present then were created by the addon in this same session, not by the user), then record applied; note in status that some addons pick it up after /reload. If not fresh: fill-only-missing as now. Never overwrite in any later session. Never record applied when nothing was attempted on a fresh target that was still nil at final phase. Tests: add an addon stub that self-fills its defaults at init (Platynator-like) for both fresh and existing cases. Why: plan contract "처음 로드 때 한 번 넣고 사용자 값은 덮어쓰지 않는다". |
| M1 | confirmed major | Player char/realm key: follow AceDB's own logic incl. the RegionalUniqueNamesEnabled branch (copy the key derivation from upstream AceDB-3.0 263–278, guarded for missing APIs). Why: AceDB profile miss → silent wrong profile. |
| M2 | confirmed major | Theme callbacks never fire in combat: RegisterSet on the active set during lockdown queues the notify to PLAYER_REGEN_ENABLED like SetActiveSet. API.lua header states the rule for every callback path. Why: protected-frame changes in combat. |
| M3 | confirmed major | Defaults reads registry ④: a `Register(folder, spec)` is accepted only if the registry entry of that folder names the calling defaults file (or the folder has `defaults` set) and every target SV is listed in that folder's savedVariables; scope comes from registry, not a default "account". Rejections go to status log. genregistry keeps validating the file path. Why: registry is the source of truth for Phase 20/23. |
| minor 1 | include | AceDB target key includes character when the SV is per-character. |
| minor 4 | include | genregistry validates editable[].frame against frame keys and default against kind/min/max. |
| minor 5 | include | RegisterReadyCallback already-ready path uses pcall. |
| minor 2, 3 | not fixed | list → final report. |

## Recheck 1 (same B · critical 0 · major 3 · minor 2) — 4 → 3, decreasing
M1, M2, M3, minors 1/4/5 resolved. C1 partly.

| ID | Verdict | Fix · why |
|---|---|---|
| N1 | confirmed major | First-load overwrite only for targets whose addon loaded before the session's first PLAYER_ENTERING_WORLD (login loading screen). A target addon loaded after that (LoadOnDemand / mid-session) and fresh: write on the next frame after its ADDON_LOADED (after the addon's own handler, before user interaction), via the client's next-frame timer (guard if the API is absent → fall back to fill-missing, never wait for a later PEW). Test case for LoD mid-session with user change after. Why: never overwrite user values. |
| N2 | confirmed major (limit, not fixable generically) | Do not guess. Status for a target whose SV was nil at load and still nil at final phase: state "late-created", reason "addon creates its saved variable later; defaults need an addon-specific path" — never "applied". In later sessions such a target stays "fill-missing" but status carries `lateCreated = true` from a persisted marker. Phase 3+ defaults authors must check SV creation timing of their addon (add to Phase 3–19 Step template). |
| N3 | confirmed (verification item) | Codex phase2 brief must check both: load order (Core before others) and same-event handler order (Core's ADDON_LOADED before the target's). Defaults header states both as assumptions. |
| minor b | include | log a reason when player keys are unavailable (AceDB target waiting). |
| minor a | not fixed | note for Phase 10 (Details per-character SV) → final report list. |

Master direct (pure rename, word substitution): old folder name `DevilForever_Core` → `!DevilForever_Core` in plan / phase2 detail plan / judgment.md where it names the folder (records left as is).

## Recheck 2 (same B · critical 0 · major 1 · minor 2) — 3 → 1, decreasing
N1/N2/N3/minor b resolved. Third finding on the same spot (first-load overwrite) → re-judged before fixing: real (same-frame writers such as our own Phase 20 restore). Root cause: overwrite mid-session cannot tell addon-generated values from values other code writes in that frame.

| ID | Verdict | Fix · why |
|---|---|---|
| N4 | confirmed major · root fix | Remove the mid-session next-frame overwrite: a fresh target first seen after the first PLAYER_ENTERING_WORLD gets fill-missing only (no overwrite, no timer). Keep first-load overwrite only for targets seen during the login loading window (before the first PEW). Add `Core.Defaults:Suppress(folder[, reason])` (session-scoped, logged) so restore/import code (Phase 20) can opt a folder out before it loads or writes it; Suppress also cancels a pending login-window overwrite. Tests: same-frame writer after LoD load keeps its value; Suppress before login-window overwrite keeps values. Why: never overwrite values someone other than the addon's own init wrote. |
| minor 1 | moot after N4 (no-timer path removed); header must match |
| minor 2 | include | API.lua documents GetStatus states (waiting/skipped/late-created/already/applied), mode, lateCreated, and Suppress. |
Re-verification after this fix: master check of changed lines + test gates (R87 — strength by master; loop has converged 4→3→1).
Recheck 2 fix: master ran tests (pass) + luacheck, read Defaults.lua first-load/Suppress lines — accepted; unit closed (C/M trend 4→3→1→0).

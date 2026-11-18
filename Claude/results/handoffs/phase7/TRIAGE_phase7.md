# Review triage — Phase 7
## Check 1 — Castbars bridge (B 1 pass, rerun after container restart: critical 0 · major 1 · minor 3)
| ID | Verdict | Fix · why |
|---|---|---|
| M1 | confirmed major | Also try hooking at PLAYER_REGEN_ENABLED (FUF builds frames after combat via its queue, Single.lua:338–339, Init.lua:71–75) and keep retrying on that event until all four units are hooked; fix the header comment; test: login in combat → frames built after combat → hooked. Why: both bars show for a whole session. |
| minor 1 | include | re-evaluate hidden state when a Quartz module is enabled/disabled (post-hook Quartz3 EnableModule/DisableModule or the module's OnEnable/OnDisable) so a mid-session toggle hands over at once. |
| minor 2 | not fixed | FUF test-mode preview hidden while Quartz owns the unit → final report. |
| minor 3 | not fixed | Quartz Focus frame may not exist on Forever; registry entry harmless if Core tolerates missing frames → Phase 23 check. |
Master decisions on A2 DQ: 2 Dominos_Cast left out of the shipped Dominos folders (Phase 23 build/manifest); 3 Quartz Buff module (가) leave; 4 focus+pet in bridge accepted; 5, 6, 7 accepted (judgment.md stays a record).

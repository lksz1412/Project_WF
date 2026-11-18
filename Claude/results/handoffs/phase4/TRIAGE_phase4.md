# Review triage — Phase 4
## Check 1 — ChatSetup + Prat defaults (B 1 pass: critical 0 · major 1 · minor 5)
Master confirmed ChatSetup.lua:158–162 and V42 !DevilUI.lua:1155–1163 (counts free windows before opening).
| ID | Verdict | Fix · why |
|---|---|---|
| M1 | confirmed major | Before any change, count free windows the V42 way (ids 3..limit, saved `active` from GetChatWindowInfo false and not isTemporary); if fewer than 2 free → result "no-free-window", change nothing. Do not rely on FCF_OpenNewWindow returning nil. Tests: stub that reuses the last window instead of nil. Why: guild/party/whisper could vanish. |
| minor 2 | include | write an "in-progress" marker before the first change; a later login that finds it does not rerun (stores "interrupted"). |
| minor 1,3,4,5 | not fixed | minor 1 placement temporary (Codex fragment); 3 reload request as designed; 4 new environment (R10); 5 kept → final report. |
Master decisions on A2 DQ: 1 keep Prat text modules as shipped (note R24 for Codex/user later); 5 approved (chat-windows/prat-profile fragments from Codex, merged later); others accepted.

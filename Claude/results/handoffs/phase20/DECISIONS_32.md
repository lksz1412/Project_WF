# Master decisions on design-32 Decision Queue
| ID | Decision | Why |
|---|---|---|
| 1 | (b) module inside `!DevilForever_Core` | plan line 312 puts save/restore in the required bundle; R101 no new addon; load-time write needs Core's earliest load and single event frame (Core.lua:110–129) |
| 2 | Keep ProfileManager for keybinds + game settings; `/dfp keys|game` pass through | R44 scope; PM covers them fully on user action (Keybinds.lua:225–261, GameSettings.lua:213–257) |
| 3 | Core contract wording becomes: "changes no frame directly; writes registered saved variables only at load time after a user command" — update Core.lua:3 and API.lua:74 headers in Step 33 | honest contract for the new module |
| 4 | PM provider adapter: not now | not needed for the row |
| 5–16 | accept design defaults (registry `restore` table §4.1, /reload capture, restore→go two-step, same character within 600 s, version mismatch = untouched no force, 10 snapshots + undo slot, preset clears only its frames, first-run preset by screen height fallback uhd, Codex preset brief addendum + Claude wraps files, F68 via LibDualSpec talent group, skip default, chat split not restorable) | design reasons in design-32 §11; safest defaults |
Review for Step 33 = 3 rounds (연계·뜻·적대), plan line 428, since Core is modified.

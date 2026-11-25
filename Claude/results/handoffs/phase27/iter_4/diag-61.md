# Step 61 diagnosis (same work sub A) — 2026-11-25

Full report text: sub transcript `C:/Users/lksz1/.claude/projects/D--Projects-Project-WF/5a41c91b-71c1-4f88-8d73-93b3933d99f1/subagents/agent-a64ebefa708243db9.jsonl` (last hand-back).

Result: cause not found in code. No Chattynator or DevilForever code calls an IME/input-language API (search over all Lua/XML except libs). Unverified candidates (things Chattynator does to `ChatFrame1EditBox` that native chat did not):
- (a) `Core/CommandHistory.lua:49` `SetAltArrowKeyMode(false)` + `:70` OnKeyDown hook (UP/DOWN only)
- (b) `Display/Main.lua:242–243` `ClearAllPoints()` / `SetScale(GetFontScalingFactor())`
- (c) `Display/Main.lua:269–274` `SetFontObject` on all edit box FontStrings
- (d) `Core/Overrides.lua:124–131` ChatFrame1 parented to a hidden frame, events unregistered
- (e) `Core/Overrides.lua:171–193` show/hide on activate/deactivate with one-frame OnUpdate
Our Devil skin edit box skinner mirrors Dark (`Skins/Dark.lua:156–161`): textures parked, background + 1 px borders; no focus/keyboard/font calls.
Upstream: GitHub issue pages 404, CurseForge comments empty; a "Korean IME Fix" addon appears in search but its page 404 (unverified).

User test 1 (other input box with Chattynator on) done by the user: mail works (R171) → specific to the chat input. Next: user tests 2 (disable Chattynator), 3 (Dark skin), 4 (`/run` one line at a time).

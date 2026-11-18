# Work log — Phase 4 Step 14 (Prat-3.0 3.9.117 settings + three-window split) — work A2

Raw output: scratchpad `step14.V0J6/` (volatile; verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole); phase4 detail plan (whole, 7 lines); `Claude/results/handoffs/phase4/SESSIONS.md` (whole)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 195–230 (feature table incl. row 211), 380–460 (Interfaces, Test Plan, verification split), 480–500 (D2–D6, D3 at 485–487), grep R24/R33/R10 (91, 142, 156)
- `Collection/judgment.md` 1–58, 68–84 (Phase 3–4 sections), 267–320 (4-5, 5, 6)
- `Collection/manifest.json` Prat-3.0 package (Python extract)
- `Claude/results/REQUEST_LEDGER_phase0.md` 1–40
- `Codex/docs/forever-clean-chat-research.md` 1–116 (whole); `Codex/docs/devil-ui-old-4k-layout.md` grep chat (5, 37, 47–51, 83)
- Core: `!DevilForever_Core.toc`, `Defaults/Dominos.lua`, `registry_extra.json` (whole), `API.lua` 1–80, `Defaults.lua` 1–395 (whole); `Collection/tools/genregistry.py` (whole); `build.py` 1–40; `luacheck.py` 1–60; `tocdeps.py -h`
- `Collection/tests/core/run.py` 1–270, 370–410, 610–645, 780–830
- Phase 3 work log (whole); `Collection/codex-briefs/appearance-3.md`, `phase3.md` (whole, form)
- Upstream Prat (read only, never run): `Prat-3.0.toc` (whole); `addon/addon.lua` 1–853 (whole); `addon/modules.lua` 1–316 (whole); `addon/profileAPI.lua` (whole); `addon/options.lua` 90–178; `modules/includes.xml` (whole); `modules/Memory.lua` 1–447 (whole); `modules/History.lua` 1–283 (whole); `modules/Scrollback.lua` 1–240 (whole); `modules/ChatLog.lua` 26–105; `modules/Achievements.lua` 28–70, 190–228; `modules/Invites.lua` 50–75, 130–180; `modules/Editbox.lua` 195–300; per-module `NewModule`/`on =` grep of all modules; state-changing call grep (SetCVar, LoggingChat, JoinChannel, SendChatMessage, InviteUnit, message group / channel calls); `ChatTabs.lua` `"Tab"` grep; `Libs/AceAddon-3.0` 231–243; `Libs/AceDB-3.0` 743–765
- Comparison (API evidence only): Glass Forever `Modules/DefaultTabs.lua` 1–189 (whole), `Modules/Hyperlinks.lua` 170–235, `UIManager.lua` grep (551–552, 599–600, 669, 701–702); Chattynator `CustomiseDialog/Filtering.lua` group grep (6–64, 159); Details `functions/chat_embed.lua` 130–160; upstream-wide API grep (FCF_*, message group, GetChatWindow*, ChatTypeGroup)

## Findings used
- SV: `Prat3DB` account AceDB (`Prat-3.0.toc:28`), `Prat3CharDB`/`Prat3HighCPUPerCharDB` character (toc:29). `AceDB:New("Prat3DB", defaults, "Default")` in `OnInitialize` (`addon.lua:159`, Prat's ADDON_LOADED) → profile rule literal `"Default"`, split common.
- Module on/off: each module's settings incl. `on` live in namespace `Prat_<module>` (`modules.lua:104–124`; AceAddon module name `Prat_<name>` at `AceAddon-3.0.lua:239`; `RegisterNamespace` uses the parent profile key, `AceDB-3.0.lua:760`). `onInit` mirrors `on` into `profile.modules` (`modules.lua:122`) and the options control writes `on` (`options.lua:93–98`) → namespace `on` is the authority. `on` is read at ADDON_LOADED (module init); History/Scrollback read `scrollback` in `OnModuleEnable` (PLAYER_LOGIN).
- Core hooks (`addon.lua:392–457`): inbound handler proxy (581–742), outbound `ChatEdit_ParseText` (467–524, skips secure commands 481–483, no SetText in combat on Forever 507–510), ItemRef, FCF hooks, DummyFrame capture. These stay (Prat itself); A2 judgment: no setting removes them; checked by phase4.md items 3, 6, 9.
- History: `savehistory = false` default → command history not saved (`History.lua:40, 182–187`); `chatlinesframes` empty → no `SetMaxLines`. Scrollback extension (`Scrollback.lua:73–97`): with `scrollback = true` (History default, `History.lua:41`) the chat frames' history buffers are kept in `Prat3HighCPUPerCharDB.scrollback` and restored at next login (208–239) → set `scrollback = false`.
- ChatLog default off (`ChatLog.lua:33`); `LoggingChat` only on enable/toggle (69–93) → not set.
- Memory: default on, `autoload = false` (`Memory.lua:45–49`), loads only on user Load or autoload; Load rewrites message groups/channels/CVars (`Memory.lua:215–241, 355–439`) → off (save/restore owner = Phase 20).
- Every other module keeps Prat's own default (R87 as-is); appearance modules Buttons/ChatTabs/Editbox/Font/Frames left for Codex.
- Window split is client chat config (`Memory.lua:221–239` shows the same calls); not a Prat setting → `DevilForever_ChatSetup`.

## DevilForever_ChatSetup — client API used and evidence of the same call in this client's upstream code
| API | evidence (upstream file:line) |
|---|---|
| `FCF_OpenNewWindow(name, true)` (returns the frame) | Glass `Modules/DefaultTabs.lua:64–65`; Details `functions/chat_embed.lua:143` |
| `frame:AddMessageGroup` / `ChatFrame_AddMessageGroup` | Glass `DefaultTabs.lua:68–72`; Prat `modules/Memory.lua:35, 223` |
| `frame:RemoveMessageGroup` / `ChatFrame_RemoveMessageGroup` | Glass `DefaultTabs.lua:74–78`; Details `chat_embed.lua:149` |
| `frame.messageTypeList`, `frame.isDocked`, `frame:IsShown()` | Glass `DefaultTabs.lua:37–41`; Details `chat_embed.lua:148` |
| `ChatTypeGroup[group]` | Chattynator `CustomiseDialog/Filtering.lua:159`; Prat `modules/CustomFilters.lua:49` |
| group names | Chattynator `Filtering.lua:6–64` (every name used, PING at 64; TRADESKILLS·OPENING·PET_INFO·COMBAT_MISC_INFO are commented out there at 43–46) · Prat `addon/MessageEventHandler.lua:66` (OPENING·TRADESKILLS·PET_INFO) · Chattynator `Core/Messages.lua:188` (COMBAT_MISC_INFO) · unknown names are skipped through `ChatTypeGroup`; Glass `DefaultTabs.lua:17–21` |
| `NUM_CHAT_WINDOWS` / `Constants.ChatFrameConstants.MaxChatWindows` | Glass `DefaultTabs.lua:9, 35`; Prat `Memory.lua:27` |
| `FCF_UnDockFrame`, `frame:SetSize`, `ClearAllPoints`, `SetPoint`, `FCF_SetTabPosition`, `FCF_UpdateButtonSide`, `FCF_SavePositionAndDimensions` | Glass `Modules/Hyperlinks.lua:185–186, 217–218, 222–224` |
| `frame:GetRight()`, `GetBottom()`, `UIParent:GetWidth()` | Glass `Hyperlinks.lua:195, 199, 202` |
| `frame:GetID()` | Prat `ChatFrames.lua:240` (`frame:GetID()`) |
| `InCombatLockdown`, `C_Timer.After`, `print` | Glass `DefaultTabs.lua:173, 179, 168` |
| `GetLocale` | Prat `addon/modules.lua:10` |
| `CreateFrame("Frame")`, `RegisterEvent`, `SetScript("OnEvent")` | Glass `DefaultTabs.lua:85` (CreateFrame); standard |
Glass `DefaultTabs.lua:116–120` (author comment, unverified): addon-made windows become regular after a reload → ChatSetup prints a /reload request.

## Steps
1. Wrote `Collection/AddOns/!DevilForever_Core/Defaults/Prat-3.0.lua` (acedb, two namespace targets on `Prat3DB`, profile `"Default"`: `Prat_History.scrollback = false`, `Prat_Memory.on = false`).
2. Core TOC: `Defaults\Prat-3.0.lua` after `Defaults\Dominos.lua`.
3. New addon `Collection/AddOns/DevilForever_ChatSetup/` (TOC 16001, deps `!DevilForever_Core`, SV per character `DevilForever_ChatSetupDB`; `ChatSetup.lua`).
4. `registry_extra.json`: Prat-3.0 (30 frames `prat.chatframe1–10`/`prat.editbox1–10`/`prat.tab1–10` → `ChatFrame<i>`, `ChatFrame<i>EditBox`, `ChatFrame<i>Tab` — `addon.lua:78–89, 401`, `ChatTabs.lua:298`; no editable; three SVs common; defaults path) and DevilForever_ChatSetup (SV common). Dominos entry unchanged (diff = additions only).
5. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote ... (38844 bytes, sha256 d0c5b6e13a715292d8cecc873ab214c2f6c1d31faf14feac9f456bb92fbad4ff)` both, sha256sum identical; `--check` → up to date rc0.
6. Core tests first run: `cases=41 passed=40 failed=1` (`generated_registry_lookup`: frames were Dominos only). `run.py`: that expectation now Dominos + Prat frames (30), Prat defaults path, ChatSetup SV; new cases `prat_defaults_fresh_default_profile`, `prat_defaults_user_values_and_profile_kept`.
7. New `Collection/tests/chatsetup/run.py` (stubs: ChatFrame1–10, FCF_*, ChatTypeGroup without PING, C_Timer, combat, locale) — 11 cases.
8. Briefs `Collection/codex-briefs/appearance-4.md`, `Collection/codex-briefs/phase4.md` (items 0–9).
9. Snippet check (scratchpad `check.py`, Core harness, generated registry): item 4 → `true true Prat3DB/Prat_History applied fill-missing Prat3DB/Prat_History@profile:Default 1` and the Memory line, status log empty; item 8 → `true false nil`. Logic only, not the client.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py` ×2 identical + `--check` → up to date (38844 bytes) rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/tests/core/fixtures` → `checked=11 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py '<Core>' Collection/AddOns/DevilForever_ChatSetup Collection/upstream/Prat-3.0-3.9.117/Prat-3.0` → `folders=3 unresolved=0 client_provided=0 optional_missing=7 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0 (optional_missing = Prat's embedded libs listed as OptionalDeps)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=43 passed=43 failed=0` rc0
- `python3 -I Collection/tests/chatsetup/run.py` → `lupa=2.8 cases=11 passed=11 failed=0` rc0
- `python3 -I Collection/tools/build.py` ×2 → `built folders=2 files=12 zip_entries=14` rc0, sha256 `387e55fe5798e411b7c2c2a5a23a85898400d7ff55a5b7456caab0b1810a0e2d` both
- `References/forever-addons/Prat-3.0/Prat-3.0-3.9.117.zip` sha256 `d72baef9…084db1` = manifest

## Decision Queue
1. Prat module set (A2 judgment): only History `scrollback = false` (no chat text kept on disk / restored next login) and Memory off (Phase 20 owns save/restore; Memory's Load rewrites groups/channels/CVars). All other modules at Prat defaults (incl. Timestamps, ChannelNames, PlayerNames, UrlCopy, Invites, Achievements on; ChatLog, ChatTabs off). Alternative: also turn off formatter modules for a closer-to-Blizzard text.
2. Core message/input hooks of Prat cannot be turned off by settings; accepted as Prat's nature (as-is); covered by phase4.md items 3/6/9.
3. ChatSetup group lists: window 2 = guild/officer/guild achievement/party/raid/raid warning/instance/whisper/BN whisper; window 3 = system/errors/ignored/target icons/BN toast/ping/xp/honor/faction/skill/loot/currency/money/tradeskills/opening/pet info/combat misc/BG system. ACHIEVEMENT, MONSTER_*, CHANNEL stay in window 1. "전투" read as combat-related messages (xp/honor/loot), not the combat log (ChatFrame2 untouched).
4. Existing-split guard: skips when a window 3..N (docked/shown) already carries a moved group (Glass `HasTab` style); a user's own changes inside ChatFrame1 only cannot be detected.
5. Initial window places are temporary (right of window 1 + 40px, right edge − 8px, window 1 size); final places come from Codex `chat-windows.fragment.lua` into ChatSetup's first-login placement (contract in appearance-4.md §3 — needs master OK, like Phase 3 DQ6).
6. /reload request printed after creation (Glass author note, unverified); not forced.
7. Registered frames: ChatFrame/EditBox/Tab 1–10 under Prat-3.0; no editable items (Phase 21). ChatSetup registry entry has `phases = []` (genregistry gives own folders no phase).
8. Timing: if the client runs Prat's ADDON_LOADED before Core's, Memory `on = false` takes effect after one /reload (Memory does nothing without autoload meanwhile); History `scrollback` is read at PLAYER_LOGIN, so it applies the same session either way.
9. Manifest not edited (template §0 boundary lists no manifest file; Phase 3 did the same).

---

# Check 1 fix (master triage `Claude/results/handoffs/phase4/TRIAGE_phase4.md`: M1 + minor 2; DQ1 keep, DQ5 approved, rest accepted)

Read: `TRIAGE_phase4.md` (whole); V42 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/!DevilUI/!DevilUI.lua` 1042–1047 (`window_info`), 1130–1190 (free count 1151–1163 before any change); `ChatSetup.lua` 1–25, 120–190; `tests/chatsetup/run.py` 130–148, 303–316.

## Impact map
| Place | Link | Verdict |
|---|---|---|
| `ChatSetup.lua` `setup()` (open loop relied on FCF_OpenNewWindow nil) | M1 root | fix: `freeWindows()` counts ids max(3, reserved+1)..N, not shown (GetChatWindowInfo 7th value), not docked, not temporary (V42 1155–1163); < 2 → "no-free-window", nothing changed; a returned window not counted free → stop "no-free-window" |
| `ChatSetup.lua` setup start / PLAYER_ENTERING_WORLD handler | minor 2 | fix: "in-progress" stored (with db.windows) before the first change; a login that finds it stores "interrupted", no rerun; window id recorded right after opening |
| `ChatSetup.lua` header result list | describes results | fix ("no-free-window" meaning, "in-progress", "interrupted") |
| `tests/chatsetup/run.py` stub FCF_OpenNewWindow (returned nil) | M1 test | fix: reuses the last window; GetChatWindowInfo stub; `no_free_window_recorded` replaced by `free_window_count_checked_before_any_change` (0, 1 shown, 1 docked, temporary, 2 free); new `window_not_counted_as_free_stops`, `interrupted_run_not_repeated` |
| `phase4.md`, `appearance-4.md` ZIP sha256 lines | ZIP content changed | fix (hash) |
| `phase4.md` item 2/7 expected `created` | result names | check only — unchanged meaning |
| `appearance-4.md` §1 `db.windows` ids | contract | check only — keys unchanged |
| Core, registry, Prat defaults | not linked | no impact |
| work_log earlier sections, DQ list | record | no impact (record) |

## Gates (raw: scratchpad `step14.V0J6/fix_*`)
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_ChatSetup` → `checked=1 failed=0` rc0
- `python3 -I Collection/tests/chatsetup/run.py` → `lupa=2.8 cases=13 passed=13 failed=0` rc0 (first run 12/13: test caught `lupa.LuaError` instead of `lua51.LuaError`; then interrupted expectation changed to include the opened window 3)
- `python3 -I Collection/tests/core/run.py` → `cases=43 passed=43 failed=0` rc0 (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=2 files=12 zip_entries=14` rc0, sha256 `13fc220d18f176763c11978015da5017df7080b6177e7f1fa29fd39451b854c2` both
- Brief sha256 lines replaced (phase4.md 1, appearance-4.md 1); old hash 387e55fe… left in Collection/codex-briefs, Collection/AddOns → 0

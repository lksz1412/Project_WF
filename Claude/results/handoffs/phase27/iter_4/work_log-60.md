# Work log — Phase 27 Step 60 (same work sub A): chat replacement with Chattynator 237

Brief: `brief-60.md` 1–34. Base `e53cde6f`, worktree clean in `Collection/` at start (only the master's ledger file modified).
Scratch (volatile, raw outputs only): `C:/Users/lksz1/AppData/Local/Temp/claude/712c5ac97757b4a3/5a41c91b-71c1-4f88-8d73-93b3933d99f1/scratchpad/s60/`.
Rule files re-read after the compaction notice: `feedback_communication_style.md` 1–87, `feedback_flow_interruption.md` 1–64 (earlier in this session), `feedback_change_impact_analysis.md` 1–66, `banned_lexicon.json` 1–75 (earlier in this session).

## Read (file : lines)

| File | Lines |
|---|---|
| `Claude/results/handoffs/phase27/brief-60.md` | 1–34 |
| `Claude/results/REQUEST_LEDGER_phase27.md` | rows R163–R167 (lines 20–24) |
| `References/forever-addons/Chattynator/SOURCE.txt` · `ANALYSIS.md` | all · 1–17 |
| Chattynator 237 (`Collection/upstream/Chattynator-237/Chattynator/`) `Chattynator.toc` | 1–70 |
| `Core/Config.lua` | 1–405 |
| `Core/Initialize.lua` | 1–256 |
| `Core/Constants.lua` | 1–71 |
| `Core/Overrides.lua` | 1–251 |
| `Core/Fonts.lua` | 1–142 |
| `Core/Objects.lua` · `Core/HyperlinkHandler.xml` | 1–11 · all |
| `Core/Messages.lua` | 1–30, 86–366, 500–540, 735–805 (channel map, message type, store) — **not the whole file** |
| `API/Main.lua` | 1–202 |
| `Display/Main.lua` | 1–310 |
| `Display/Tabs.lua` | 1–611 |
| `Skins/Main.lua` · `Skins/Dark.lua` | 1–114 · 1–522 |
| `CustomiseDialog/Filtering.lua` | 1–370 |
| `CustomiseDialog/Main.lua` | 325–385, 755–860, 1000–1078 (tab/button options, skin options UI) — not the whole file |
| not read: `Display/ScrollingMessages.lua`, `Display/Buttons.lua` (grep for `hover` only), `Skins/Boxed.lua`, `Skins/Blizzard.lua` and the other skins, `CustomiseDialog/*` rest | — |
| `Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua` · `ChatLayout.lua` · `.toc` | 1–367 · 1–303 · 1–10 |
| `Collection/AddOns/DevilForever_Skin_NativeChat/Skin.lua` · `.toc` | 1–151 · 1–7 |
| `Collection/tests/chatsetup/run.py` | 1–906 |
| `Collection/tools/extract.py` · `patches.py` · `genregistry.py` · `build.py` | 1–721 · 1–336 · 1–486 · 1–390 |
| `Collection/install.json` | 1–50 |
| `!DevilForever_Core/registry_extra.json` | per-addon summary (python) + 200–240 |
| `!DevilForever_Core/Registry.lua` | appearance.chat1 rows 175–204 |
| `!DevilForever_Core/Theme.lua` · `Themes/devil.lua` · `Edit.lua` | grep token list / API · 1–25 · grep `path` |
| `!DevilForever_Core/Presets/{fhd,qhd,uhd}.lua` · `V2.lua` | appearance.chat1 entry (uhd 17–32), grep chat/font · grep `chat` (none) |
| `Collection/codex-briefs/phase27-game-check.md` | 1–96 |
| `Collection/tests/install/verify_archives.py` | 1–40, 160–200 |
| `Collection/install/설치안내.md` · `Collection/data/feature-map.md` | grep 대화/ChatSetup/Prat · grep chat |
| `Collection/manifest.json` | python query (roles, how_to_use, third_party) |
| existing patch headers (`Collection/patches/*.patch`) | header parts |

SHA-256 of `References/forever-addons/Chattynator/Chattynator-237.zip` = `7bf89cbb…31c9`, equal to `SOURCE.txt`.

## What was built

| File | Change |
|---|---|
| `Collection/AddOns/Chattynator/` (new) | byte copy of `Collection/upstream/Chattynator-237/Chattynator` (67 files) + the patch below |
| `Collection/AddOns/Chattynator/Skins/DevilForever.lua` (new, LF) | skin "Devil Forever" via `addonTable.Skins.RegisterSkin(..., autoEnable = true)`; themed regions: ChatFrame (transparent body), ChatTab (flat, theme text/accent colour, underline when selected or flashing), ChatEditBox (Blizzard textures hidden, panel background + 1 px border in theme colours — the box is only shown while typing); ChatButton / ResizeWidget / everything else = Dark skinner; without `DevilForever_Core` + `DevilForever_Appearance` every region = Dark skinner. Message font size follows `appearance.chat1` font size × `GetPixelUnit(UIParent)` while it still equals the last value the skin wrote (hidden option `skins.devilforever.applied_font_size`). Defines `DevilForever_ChattynatorBridge` (Get/Set/GetDefault/GetEmptyTabConfig/GetEmptyWindowConfig/GetProfileName/GetChannels/WindowsChanged/IsReady/Options) |
| `Collection/AddOns/Chattynator/Chattynator.toc` | one line `Skins/DevilForever.lua` after `Skins/GW2.lua` (CRLF kept) |
| `Collection/patches/Chattynator.patch` (new) | `patches.py regenerate --package Chattynator` + hand header |
| `Collection/tools/extract.py` | `FEATURE_PHASES["forever-addons/Chattynator"]` comparison → start; `PATCHED["Chattynator"] = ["Chattynator"]` |
| `Collection/install.json` | `"upstream": {"Chattynator": ["Chattynator"], …}` (base list → both variants) |
| `!DevilForever_Core/registry_extra.json` | `Chattynator.saved_variables.CHATTYNATOR_CONFIG` = common / whole / plain |
| `Collection/manifest.json` · `manifest.md` · `!DevilForever_Core/Registry.lua` | regenerated (`extract.py`, `genregistry.py`) |
| `DevilForever_ChatSetup/Chattynator.lua` (new) | `addon.ChattynatorActive`, `addon.SeedChattynator`, `addon.RouteChattynatorLookingForGroup`, `addon.FollowChattynatorLayout`, events |
| `DevilForever_ChatSetup/DevilForever_ChatSetup.toc` | `OptionalDeps: DevilForever_Appearance, Chattynator`; `Chattynator.lua` between `ChatLayout.lua` and `ChatSetup.lua` |
| `DevilForever_ChatSetup/ChatSetup.lua` | event handler returns at once while Chattynator is active (native setup not run, `db.result` untouched) |
| `DevilForever_ChatSetup/ChatLayout.lua` | `apply()` returns (`layoutState = "chattynator"`) while Chattynator is active |
| `DevilForever_Skin_NativeChat/Skin.lua` | `apply()` returns while Chattynator is active (CRLF kept) |
| `Collection/tests/chatsetup/run.py` | 7 new cases (Chattynator files loaded on one addon table) |
| `Collection/codex-briefs/phase27-game-check.md` | §10 Chattynator check items |

### "Untouched" (seed condition)

Chattynator's window config counts as untouched when it equals Chattynator's own default (`Config.Defaults.windows`, `Core/Config.lua:26–78`) after its first-run migration (`Core/Initialize.lua:28–57`): exactly one window, position and size equal to the default (numbers within 0.01), tabs = default GENERAL and GUILD, plus — only on window 1 and only as the last tab — the combat log tab the migration adds (`name COMBAT_LOG, custom combat_log, 262626 / c97c48`). Tabs are compared on their meaningful fields: empty tables (`channels`, `whispersTemp`, `filters`, `addons` added by `RemoveTemporaryWindows`) and `isTemporary = false` count as absent. Anything else (a moved/resized window, a changed group or channel, an extra tab or window) = not untouched → the profile is marked `kept` and never touched.

Seed flag: `DevilForever_ChatSetupDB.chattynator.profiles[<Chattynator profile>] = "seeded" | "kept"` (per character, keyed by `CHATTYNATOR_CURRENT_PROFILE`; another character on the same Chattynator profile finds the config no longer default → `kept`).

### Seed

| Window | Place (prepared layout of the active preset, `ChatLayout.lua` roles) | Tab |
|---|---|---|
| 1 | `public` | `GENERAL`, `invert = true`: groups false = Chattynator's default hidden set (TRADESKILLS, COMBAT_MISC_INFO, COMBAT_XP_GAIN, PET_BATTLE_COMBAT_LOG, PET_INFO, OPENING, VOICE_TEXT) + the window-2 types; channels: every joined channel = true, the looking-for-group channel = false. Then Chattynator's combat log tab as it was |
| 2 | `group` | `Group`/`파티·길드`: groups true = WHISPER, BN_WHISPER, GUILD, OFFICER, GUILD_ACHIEVEMENT, GUILD_DISCORD, PARTY, PARTY_LEADER, RAID, RAID_LEADER, RAID_WARNING, INSTANCE_CHAT, INSTANCE_CHAT_LEADER |
| 3 | `system` (the native third slot) | `Looking for Group`/`파티 찾기`: channels {LFG = true} when joined, else empty |

Options set once on seed: `store_messages = false`, `show_tabs_1 = "hover"`, `show_buttons = "hover"`, `button_position = "inside_left"`. Written with `Config.Set(WINDOWS, new table)` (fires `SettingChanged`, Chattynator makes the new frames, `Core/Initialize.lua:176–187`).

Looking-for-group channel = zone channel id 26 through `C_ChatInfo.GetChannelInfoFromIdentifier(GetChannelName(n))` when the client has it, else the display name without spaces, lower-case, containing `lookingforgroup` or `파티찾기`. Joined later (`CHANNEL_UI_UPDATE`, `CHAT_MSG_CHANNEL_NOTICE` YOU_JOINED/YOU_CHANGED, 3 s later, out of combat): added to window 3's first tab and set false in window 1's inverted tab, only when no tab of any window already has it `true`, the profile was seeded by this module and window 3's first tab is still the seeded one.

Layout follow (brief item 5): today `ChatLayout.lua` moves managed native windows on preset / screen scale / `appearance.chat1..3` edits (the bounds are per preset; V1/V2 does not move chat — `Presets/V2.lua` has no chat entries). With Chattynator: windows still equal to the stored placement receipt move to the new preset bounds on `UI_SCALE_CHANGED`, `DISPLAY_SIZE_CHANGED` and `appearance.chat1..3` edits; a window the user moved is released.

## Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Collection/AddOns/Chattynator` (folder) | new shipped folder | — | change | brief item 1 |
| `extract.py` `FEATURE_PHASES`, `PATCHED` | reader of folders / manifest producer | read 1–721 | change | role "start" is what genregistry registers (`genregistry.py manifest_entries` keeps only start packages); patched state needs `PATCHED` |
| `install.json` | reader (build, genregistry) | read 1–50, build/genregistry read | change | build refuses unnamed folders (`build.py install_selection`) |
| `registry_extra.json` | registry extras | read | change | settings save/restore for `CHATTYNATOR_CONFIG` (other packages list theirs the same way) |
| `manifest.json/md`, `Registry.lua` | generated | tools | change (regenerated) | generator output |
| `Collection/patches/Chattynator.patch` | patch store | patches.py read | change (new) | brief item 2 |
| `patches.py`, `build.py`, `genregistry.py` | tools reading the above | read in full | check only | no code change; verify = 8 patches, build ships the folder |
| `DevilForever_ChatSetup/ChatSetup.lua` | native seed (writes ChatFrame windows, `DevilForever_ChatSetupDB.result/windows`) | read 1–367 | change (gate) | brief item 3/4 fallback |
| `DevilForever_ChatSetup/ChatLayout.lua` | native placement (writes ChatFrame geometry, `db.managedLayout`); `GetPreparedChatWindow` read by the new module | read 1–303 | change (gate) | brief item 4/5 |
| `DevilForever_ChatSetup/Chattynator.lua` | new seed/follow (writes `CHATTYNATOR_CONFIG` through the bridge, `db.chattynator`) | — | change (new) | brief item 3/5 |
| `DevilForever_ChatSetup.toc` | load order | read | change | Chattynator first; new file before ChatSetup.lua |
| `DevilForever_Skin_NativeChat/Skin.lua` | native skin (reads `db.windows`, styles ChatFrames) | read 1–151 | change (gate) | brief item 4 |
| `DevilForever_Skin_NativeChat.toc` | deps | read | check only | depends on ChatSetup → `DevilForever_ChatSetup.ChattynatorActive` exists |
| `DevilForever_ChatSetupDB` readers: `tests/install/verify_diagnostics.py:44–71`, `tests/installer/recovery.py:75–104` | readers of the saved variable / folder | grep | check only | they read `result`/`windows`; the new `chattynator` key is additive |
| `tests/chatsetup/run.py` | locking test | read 1–906 | change | new cases; old 32 cases unchanged and passing |
| `tests/core/run.py:462, 584–586` | registry tests (ChatSetup SV, no Prat) | grep | check only | 109/109 |
| `tests/install/verify_archives.py:172–177` | archive must-ship list | read | check only | needs built ZIPs (not built here); Chattynator not in `must_ship` — open question |
| `Collection/codex-briefs/phase27-game-check.md` | user check list | read 1–96 | change | brief item 7 |
| `Collection/install/설치안내.md:54` | user guide (native "대화창 3개" message) | grep | check only | now describes the native fallback; outside the brief — open question |
| `Collection/data/feature-map.md:7, 40–41` | user feature map (native chat rows) | grep | check only | outside the brief — open question |
| `Collection/Installer/ReleaseCatalog.json` | release catalog | grep (known from earlier steps) | check only | regenerated at release time (`catalog.py --write`) |
| Hekili, `!BugGrabber`, `BugSack`, other upstream folders | — | — | none | not touched |
| work logs, plans, ledger | records | — | none (record) | not edited |

## Commands (verdict lines)

| Command | Verdict |
|---|---|
| `sha256sum References/forever-addons/Chattynator/Chattynator-237.zip` | `7bf89cbb0cb221a0313ffd2bd3abc761b9c6a11b01bc993216ee8b23b63931c9` = SOURCE.txt |
| `cp -r Collection/upstream/Chattynator-237/Chattynator Collection/AddOns/Chattynator` · `diff -r` | identical before the patch |
| `python Collection/tools/extract.py` (1st, before the patch file) | rc=1 · `ERROR Collection/AddOns/Chattynator: patch file missing` (expected) |
| `python <scratch>/../s51.XsBX/devnull_run.py Collection/tools/patches.py regenerate --package Chattynator` | `wrote Collection/patches/Chattynator.patch (9496 bytes)` (then the header was written by hand) |
| `python Collection/tools/extract.py` | rc=0 · `start=14 comparison=25 … errors=0` |
| `python Collection/tools/genregistry.py` · `--check` | wrote 59395 bytes · `up to date` |
| `… patches.py verify` | rc=0 · `verify patches=8 unmodified=20 failures=0` · `OK patched Chattynator (2 files)` |
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · `cases=39 passed=39 failed=0` (7 new) |
| core 109/109 · statusstrip 20/20 · theme_switcher rc=0 · layoutv2 rc=0 · firststart 29/29 · composition 8/8 + parts 12/12 · castbars 16/16 · fufdefaults 22/22 · pitbull4 6/6 · pitbull4runtime 20/20 · thirdparty 8/8 | rc=0 each |
| `python -I Collection/tools/luacheck.py Chattynator/Skins/DevilForever.lua DevilForever_ChatSetup DevilForever_Skin_NativeChat !DevilForever_Core` | `checked=26 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · folders 36 / 38 · files 2284→2353 / 2228→2297 (+68 Chattynator, +1 `ChatSetup/Chattynator.lua`) · Chattynator `from upstream:Chattynator`, 0 excluded |

Raw outputs: `<scratch>/s60/*.txt`.

## Defaults chosen (Decision Queue)

1. System, loot, money, skill, currency, errors → window 1 (brief default). XP / honor / faction gain stay as Chattynator's GENERAL default has them (COMBAT_XP_GAIN hidden, the others shown).
2. GUILD_DISCORD (not in the user's list) → window 2 with the guild types.
3. AFK/DND: Chattynator files a message under the first ChatTypeGroup that lists its event (`Core/Messages.lua:14–22`); if the client lists CHAT_MSG_AFK/DND under WHISPER they land in window 2 — not verifiable here (unverified).
4. Tab names: window 1 `GENERAL` (Chattynator localises it), window 2 `파티·길드`/`Group` (as the native role), window 3 `파티 찾기`/`Looking for Group`. Tab colours: Chattynator's GENERAL/GUILD colours and the empty-tab default.
5. `button_position = "inside_left"` on seed (the native public window starts 1.5 % from the screen edge; an outside column would not fit), `show_tabs_1`/`show_buttons = "hover"`.
6. Windows use the native rectangles exactly (Chattynator's frame includes its tab bar; the native tab sat above the frame). Chattynator's `SetResizeBounds(240, 140)` — whether `SetSize` below 140 is clamped (fhd height 148 × pixel unit can be < 140 UI units) is unverified.
7. Fallback places without a prepared layout: window 1 stays at Chattynator's default, window 2 to its right (+40), window 3 at the right edge (−8), same size.
8. Skin auto-enable uses Chattynator's own `autoEnable`/`DISABLED_SKINS` rule: selected on Chattynator's first run; once the user picks another skin it is never selected again. A user who picked another skin in Chattynator before this install gets Devil Forever once (no earlier "disabled" mark).
9. Message font size follows `appearance.chat1` only (Chattynator has one message font); font file stays Chattynator's default (ChatFontNormal family).
10. Bridge global `DevilForever_ChattynatorBridge` lives in the patched skin file (Chattynator has no config API; `API/Main.lua` has none) — no other Chattynator file changed.
11. `CHATTYNATOR_CONFIG` restore = whole/plain in settings save/restore; message log and per-character variables skipped.

## Open questions

- `Collection/install/설치안내.md:54` and `Collection/data/feature-map.md` still describe the native chat windows; not in the brief.
- `tests/install/verify_archives.py` `must_ship` does not list Chattynator (needs built archives to run).
- `Prat-3.0` keeps role "start" for Phase 4 in `extract.py` (only Chattynator was changed); manifest `how_to_use` for Chattynator is empty (judgment.md has no Chattynator verdict), so the registry `use` is nil.
- Forever channel 4 (zone id 46) and the existence of a looking-for-group channel: unknown — in the check list.
- `C_ChatInfo.GetChannelInfoFromIdentifier` on Forever: unverified (name fallback covers it).

## Review fix (M1 + docs/lists, TRIAGE_phase27.md "Step 60 review")

Read: `TRIAGE_phase27.md` 67–77 · `Chattynator/Skins/Main.lua` 1–114 (again: `:20–31` auto-enable, `:42–52` skin applied at PLAYER_LOGIN, `:55–62` disabled mark, `:63–72` live switch commented out) · `Core/Initialize.lua` 89–91, 159 (InitializeData → MigrateSettings → … → Skins.Initialize) · `Skins/DevilForever.lua` whole (191–193 RegisterSkin) · `DevilForever_ChatSetup/Chattynator.lua` whole · `Collection/install/설치안내.md` 1–85 · `Collection/data/feature-map.md` 1–78 · `tests/install/verify_archives.py` 160–200 · `tools/extract.py` 80–116.

M1 fix: the skin registers with autoEnable = false and wraps `addonTable.Skins.Initialize` (defined by `Skins/Main.lua`, which loads before the skin file; `Core.Initialize` calls it through the table after the profile is loaded and migrated). Just before the original runs, `autoEnable` is set only when the profile is untouched — the same window rule as the seed, now one function `untouched()` in the skin file, exposed as `DevilForever_ChattynatorBridge.IsUntouched` and used by `DevilForever_ChatSetup/Chattynator.lua` (its own copy removed) — **and** the current skin is still Chattynator's default (`dark`). So a new profile shows Devil Forever in its first session; a profile that already used Chattynator (windows changed, or another skin picked) keeps its skin; a seeded profile keeps the skin chosen in its first session (current_skin is stored); a later pick by the user is kept by Chattynator's `disabled_skins` mark.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Chattynator/Skins/DevilForever.lua` RegisterSkin / Initialize wrapper / `untouched` / bridge `IsUntouched` | the defect | review quote, read | change | M1 |
| `Chattynator/Skins/Main.lua` `Initialize`, CURRENT_SKIN handler | called side | read 1–114 | check only | wrapper calls the original unchanged; `autoEnable` read at `:25` and `:59` |
| `Core/Initialize.lua` `Core.Initialize` | caller of `Skins.Initialize` | read 89–212 | check only | table lookup → wrapper runs |
| `DevilForever_ChatSetup/Chattynator.lua` `untouched`/`meaningful` | twin rule | read | change (removed, uses `b.IsUntouched()`) | one rule for seed and skin |
| `Collection/patches/Chattynator.patch` | patch store | regenerate | change | body + header text |
| `tests/chatsetup/run.py` `chattynator_skin_default_once_and_without_core` | locking test | read | change | used profiles keep dark / own skin; seeded profile keeps Devil; fresh profile Devil in first session |
| `Collection/codex-briefs/phase27-game-check.md` §10 | check list | read | change | skin chosen only for a fresh profile; theme item needs the Devil skin |
| `Collection/install/설치안내.md` 7–9, 42, 54 | user guide | read 1–85 | change | 36/38 folders, Chattynator chat, three windows as seeded, native chat only with Chattynator off |
| `Collection/data/feature-map.md` 7, 39–41 | user feature map | read 1–78 | change | Chattynator rows |
| `tests/install/verify_archives.py` `must_ship` | release check | read | change | Chattynator added (needs built ZIPs to run; parsed only) |
| `tools/extract.py` `FEATURE_PHASES` Prat-3.0 | manifest producer | read | change | comparison → Chattynator is the Phase 4 start addon |
| `manifest.json/md`, `Registry.lua` | generated | tools | change (regenerated) | Registry bytes unchanged (Prat not shipped) |
| `Collection/install/설치안내.md:20` ("0.1.4 부터 기본 채팅을 쓴다") | history of the Prat removal | read | none (record of past versions) | describes 0.1.0–0.1.4 |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `… patches.py regenerate --package Chattynator` (header then edited) | `wrote Collection/patches/Chattynator.patch (13583 bytes)` |
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · `cases=39 passed=39 failed=0` |
| same skin case against a scratch copy with the old `autoEnable = true` and no wrapper (`<scratch>/s60/mut.*`) | FAIL as expected · `used profile (windows changed) keeps dark: expected 'dark', got 'devilforever'` |
| `python -I Collection/tests/core/run.py` | rc=0 · 109/109 |
| `python -I Collection/tools/luacheck.py Chattynator/Skins/DevilForever.lua DevilForever_ChatSetup` | `checked=4 failed=0` |
| `python Collection/tools/extract.py` | rc=0 · `start=13 comparison=26 … errors=0` |
| `python Collection/tools/genregistry.py` · `--check` | up to date (59395 bytes, unchanged) |
| `… patches.py verify` | `verify patches=8 unmodified=20 failures=0` · Chattynator OK (2 files) |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders 2353 files / 38 folders 2297 files |
| `tests/install/verify_archives.py` | not run (needs built archives) · Python parse OK |

Default added: the Devil skin is auto-chosen only when the windows are untouched **and** the skin is still Chattynator's default `dark` (stricter than the window rule alone, so a profile that only changed its skin also keeps it).

## Step 61 fix (one change, four items + LFG case)

User results / requests: (a) 한/영 dead in the Chattynator input; `/run ChatFrame1EditBox:SetScale(1)` fixes it (SetAltArrowKeyMode(true) does not) · (b) R173 tab row onto the theme strip · (c) R175 message area inside the theme chat panel · (d) R176 battleground messages in window 2 · (e) `/입장 파티찾기` → "6. 파티찾기 2" already lands in window 3 (test only; a second LFG channel needed a code change, below).

Re-read in full before editing: `Chattynator/Display/Main.lua` 1–311 · `Chattynator/Core/Fonts.lua` 1–143 · `Chattynator/Display/Buttons.lua` 250–394 (button layout per position) · `Chattynator/Skins/GW2.lua` 215–250 · `DevilForever_ChatSetup/Chattynator.lua` whole · `DevilForever_ChatSetup/ChatLayout.lua` 1–41 (native rectangles) · `DevilForever_Appearance/Appearance.lua` 1–192 and `Composition.lua` (whole, Step 59) for panel rects and insets · `Themes/{devil,horde,alliance}.lua` `border.size` · `Presets/{fhd,qhd,uhd}.lua` appearance.* (parsed) · `CustomiseDialog/Filtering.lua:49–53` (OTHER_PVP keys BG_HORDE, BG_ALLIANCE, BG_NEUTRAL) · check list §10 · install guide 1–85.

### What changed

| Item | Change |
|---|---|
| (a) | `Chattynator/Display/Main.lua` UpdateEditBox: `ChatFrame1EditBox:SetScale(1)` always; height = edit_box_height × factor; anchor offsets × factor (`bottom`: TOPLEFT y = (yOffset + H − clampBottom·f)·f, TOPRIGHT y = (H − clampBottom·f)·f — the same screen place as the old box at scale f, whose offsets were in its own scaled space; `top`/`screen*`: x and y offsets × f); the message-area bottom line keeps its form (`GetHeight()` already scaled, `GetScale()` = 1). Fonts: new `Core/Fonts.lua` `GetScaledFont(name, factor)` = a font family copy with every alphabet member's height × factor (files, flags, shadow, text colour copied; cached; factor 1 → the base font), set on the box itself and its FontString regions. The only `SetScale` on the box was `Display/Main.lua:243` (grep); our skin never scaled it; `Skins/GW2.lua:235` scales its own `fakeEditBoxTex` (child of the chat frame visuals, not of the box) — check only |
| (c), supersedes the centring rule of (b) | `DevilForever_ChatSetup/Chattynator.lua` `prepared(role)`: each window is placed so Chattynator's message area (ScrollingMessagesWrapper: window top −27, left +2 with buttons inside, right flush, bottom +5 for windows 2/3) equals the inner rectangle of its chat panel (`appearance.chat1/2/3`). Window 1 keeps its input box inside the panel (window bottom = inner bottom; its message area is the inner rectangle minus the input row). The tab row (top 22 units of the window) sits directly above the message area |
| (d) | `GROUP_TYPES` + `BG_HORDE`, `BG_ALLIANCE`, `BG_NEUTRAL` → window 2 on seed, hidden in window 1 (seed only) |
| (e) | `joinedChannels` returns every looking-for-group channel; seed and later routing handle each one (a second LFG channel joined later also goes to window 3 when no tab shows it — before, only the first was handled) |
| layout follow | Theme callback added (panel insets depend on the art); seeded, unmoved windows (receipt match) move to the new rectangles — including windows seeded with the old native rectangles; moved windows are released |

Panel inner rectangle, from the appearance code (no values from the screenshot):
- Composition prepared surfaces (shipping state — `Composition.active`, no parts shipped): the code puts no inset inside the deck picture → inner = the panel rectangle (a border painted in the art is not known to the code: unverified).
- Composition parts (when parts ship): end caps (48/64/96 px) at the screen edges and joints (16/20/32 px) centred on the panel boundaries cover the panel edges → inner left/right move inside them.
- Individual panels (composition off, e.g. after a layout edit): top and bottom edge lines of theme `border.size` px (devil/alliance 1, horde 2).

Rectangles per preset (physical px; V1 = V2 — `Presets/V2.lua` has no appearance/chat entries):

| Preset | chat1 panel | chat2 panel | chat3 panel | individual-panel inner y (border 1) |
|---|---|---|---|---|
| fhd | x 0–438, y 860–1052 | x 440–878 | x 1486–1920 | 861–1051 |
| qhd | x 0–620, y 1186–1410 | x 622–1242 | x 1946–2560 | 1187–1409 |
| uhd | x 0–960, y 1820–2124 | x 962–1922 | x 2902–3840 | 1821–2123 |

Window (UI units) = panel px × pixel unit (`GetPixelUnit(UIParent)`), then x − 2 (clamped at 0 → window 1 text starts 2 units inside the screen-edge panel), top + 27, bottom − 5 (windows 2/3).

Tab row against the theme strip right above the panels (`appearance.ribbon`; individual-panel case, message top = panel top + 1). Tab row = 27 to 5 UI units above the message top; p = UI units per px:

| Preset | strip px | tab row px at p = 1 | tab row px at UI scale 1 (p = 768/height) |
|---|---|---|---|
| fhd | 850–860 (centre 855) | 834–856 (centre 845) | 823–854 (centre 838.5) |
| qhd | 1174–1186 (centre 1180) | 1160–1182 (centre 1171) | 1136–1178 (centre 1157) |
| uhd | 1804–1820 (centre 1812) | 1794–1816 (centre 1805) | 1745–1807 (centre 1776) |

The tab row (22 UI units) is taller than the strip (10/12/16 px); its centre lies 7–36 px above the strip centre and it overlaps the strip's upper part. Centring it on the strip (R173 fallback rule) and keeping the message area exactly on the panel (R175) cannot both hold: Chattynator keeps the tab row and the message area 27 units apart (`Display/Main.lua:228`). Default chosen: R175 (message area exact), tab row directly above it — open for the user.

Buttons: the seed's `button_position = "inside_left"` + `show_buttons = "hover"` make them overlay: with an inside position the message area starts 2 units from the window edge (`Display/Main.lua:228`) and the buttons are anchored over the message area's top-left (`Display/Buttons.lua:298–305`), shown only on hover (`:259–282`). They take no width. A window that still shows them always was set by the user (never reseeded).

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Chattynator/Display/Main.lua` UpdateEditBox (:234–275) | the defect (a) | user test, read | change | scale 1 |
| `Chattynator/Core/Fonts.lua` | font families | read whole | change (GetScaledFont added) | text size without scale |
| `Display/Main.lua:80–83, 107–121` callers of UpdateEditBox | callers | read | check only | same function, same triggers |
| `Display/Main.lua:198–206` RepositionBlizzardWidgets → skin AddFrame | caller | read | check only | skin gets the box after UpdateEditBox |
| `Core/Messages.lua:94, 302, 369`, `Display/ScrollingMessages.lua:246, 265` | same factor, other widgets | grep | check only | message text keeps SetTextScale (not the IME widget) |
| `Skins/GW2.lua:235` fakeEditBoxTex scale | look-alike | read | check only | not the box |
| `Skins/DevilForever.lua` edit box skinner | our skin | read | check only | no scale; 1-unit border lines now unscaled |
| `DevilForever_ChatSetup/Chattynator.lua` prepared / panelInner / GROUP_TYPES / joinedChannels / route / Theme callback | seed + follow | read whole | change | (b)(c)(d)(e) |
| `DevilForever_ChatSetup/ChatLayout.lua` | native rectangles | read | check only | still used by the native path, no longer by the Chattynator seed |
| `DevilForever_Appearance/Composition.lua` (`active`, `partsShown`, `partsPlan`, `parts.sizes`) | read by panelInner | read | check only | fields exist (Step 59) |
| `Collection/patches/Chattynator.patch` | patch store | regenerate | change | 4 files now |
| `tests/chatsetup/run.py` | tests | read | change | new geometry expectations and cases |
| check list §10, `install/설치안내.md:54` | user docs | read | change | (a)–(d) |
| `data/feature-map.md` chat rows | user doc | read | check only | still true in general terms |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · `cases=43 passed=43 failed=0` |
| edit-box case against a scratch copy with upstream `Display/Main.lua` (`<scratch>/s60/mut61.*`) | FAIL as expected · `size 28: edit box scale stays 1: expected 1, got 2` |
| `python -I Collection/tools/luacheck.py Display/Main.lua Core/Fonts.lua Skins/DevilForever.lua DevilForever_ChatSetup` | `checked=6 failed=0` |
| `… patches.py regenerate --package Chattynator` (header edited) | wrote 19554 bytes |
| `… patches.py verify` | `verify patches=8 unmodified=20 failures=0` · Chattynator OK (4 files) |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

### Behaviour change against upstream Chattynator

The chat input box is never scaled: it is as tall as before (32 × factor) and in the same place, but its child textures and text insets no longer grow with the factor, and its typed text uses Chattynator's message font family at the scaled size (upstream: the client's chat font scaled with the box). With the default message font (a clone of ChatFontNormal) the text looks the same.

## Step 61 fix, continued (items f-i: R179, R181-R183, R184, R185)

Compaction during this round. Re-read after it, before any edit: rule files (constitution `.claude/CLAUDE.md`, communication and flow memory files whole, plan-execution and multi-session skills reloaded), then `Presets/V2.lua` 1-245, `tests/layoutv2/run.py` 1-140 and 500-607, `tests/core/run.py` 1-110, 160-215, 1355-1370, `Presets.lua` 225-300, `Profiles.lua` 95-105 and 325-360, `Core.lua` 190-200 and 310-330, `Defaults/PitBull4.lua` 555-625, `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` 250-290, check list 113-120, this log 195-270. Reads for (f)-(h) before the compaction: `Presets/{fhd,qhd,uhd}.lua` PitBull4 / LuaTexts / Aura / CastBar fragments, `Presets/V2.lua`, `Defaults/PitBull4.lua:194-211`, `PitBull4/UnitFrame.lua:747`, `PitBull4/ModuleHandling/Module.lua:311`, `PitBull4/UnitFrameLayout.lua:442-446`.

### What changed

| Item | Change |
|---|---|
| (f) R179 | `Presets/{fhd,qhd,uhd}.lua`: `Lua:이름` size on layouts 보통 and 대상 = preset size x (보통.size_y / 소환수와 주시.size_y). Pets, focus, small and party frames keep the preset size; bar texts (생명력, 마력, 직업, 백분율, 레벨) unchanged. One rule: name text scales with frame height against the companion frame. Results: fhd 16 x 72/56 = 20.57 px, qhd 18 x 96/74 = 23.35 px, uhd 22 x 144/112 = 28.29 px. Health/power bars of the main frames are about the companion bar height, so their texts keep the size. V1 bars are a little taller now (the PitBull4 cast slot is gone, item h) |
| (g) R181/R183 | `Presets/V2.lua`: the Quartz Player bar goes in the cast row under the player frame like Target (`point TOP`, `y = -castY*pixel`, `x` centred on the frame, `w = frame - 10`, `h = castHeight - 10`); the old outside PitBull4 cast bar lines (`dfOutside`, `dfOffset`, `dfHeight`) removed; `quartz.Player.y = -footY` and the focus `top_margin` line removed; `footY` dropped from `modes` |
| (g) R182 | focus auras = pet auras: `Aura.layouts["주시"] = CopyTable(Aura.layouts["데빌 파티"])` in the presets (the player/target aura loop now covers 보통 and 대상 only); V2 `dfAuraGeometry["주시 대상"] = {above = true, width = companion size_x}` like the pet |
| (g) side gap | recheck: the extra side gap is gone; player-focus and focus-target gaps are one frame gap (castHeight + 4 = 34/38/44 px) |
| (h) R184 | cause: the preset CastBar fragment (`Presets/{fhd,qhd,uhd}.lua:553-555` before the change) set `global.enabled = true` and `layouts.보통.enabled = true`, overriding Core `Defaults/PitBull4.lua:194-211` (off). In V2, `V2.lua:147-148` (old) moved that bar outside through `dfOutside` (read by our PitBull4 patch `UnitFrameLayout.lua:442-446`). No other cast bar code in Core, Party or Appearance. Fix: CastBar fragment `global.enabled = false`, `layouts.보통.enabled = false`; player LuaTexts `Lua:시전` and `Lua:시전시간` `enabled = false`. PitBull4 clears a module whose layout entry is disabled (`ModuleHandling/Module.lua:311`). Old and New both: Quartz only |
| (i) R185 | `Presets/V2.lua`: `layoutV2Revision` 2 -> 3, new `layoutV1Revision = 1`; both versions write `dfLayoutRevision`. New `Core.Presets:ReapplyOutdatedLayout()`: at PLAYER_ENTERING_WORLD (+1 s timer), when the PitBull4 profile's `dfLayoutRevision` (missing = 0) is lower than this build's revision of the version it is on (`dfLayoutV2 == true` -> New, else Old), it runs `Presets:Restore(<active>-v2 or -v1)` then `Profiles:Go()` (the status strip switch path, `ThemeSwitcher.lua:276-280`). In combat: waits for PLAYER_REGEN_ENABLED. One attempt per profile key and revision (`DevilForever_CoreDB.layoutRevision.tried["<profile>|<suffix>"]`). One chat line after the reload (`layoutRevision.notice`, printed and cleared at the next PLAYER_ENTERING_WORLD). The layout-only presets carry PitBull4, Quartz and Grid2 fragments only, so Chattynator windows are not touched |

Apply path for existing profiles: automatic at the first login after install (item i). Manual paths stay: the status strip New/Old switch, or `/dfp preset <fhd|qhd|uhd>` + `/dfp go`.

### Impact map (items f-i)

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets/{fhd,qhd,uhd}.lua` LuaTexts, Aura, CastBar fragments | the change (f, g, h) | read | change | name ratio, focus auras, cast bar off |
| `Presets/V2.lua` modes, gap, Quartz loop, cast lines, revisions, re-apply block | the change (g, i) | read whole | change | Quartz Player row, side gap, revisions, re-apply |
| `Defaults/PitBull4.lua:194-211` CastBar defaults | same setting, Core defaults | read | check only | already off; the preset was the override |
| `Defaults/PitBull4.lua:555-625` applyScale | uses `_G.PitBull4` at login | read | check only | the test stub needs `IterateHeaders` / `IterateFrames` |
| `PitBull4/UnitFrameLayout.lua:442-446` dfOutside | reader of the removed V2 lines | read | check only | no V2 writer left; V1 still writes `dfOutside = false` |
| `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua:254-280` versionInUse / cycle | reader of `layoutV2Revision`, same switch path | read | check only | New shown only for revision 3; re-apply uses the same Restore + Go |
| `Presets.lua:277-300` Restore, `Profiles.lua:333-341` Go, `Core.lua:196`, `:318` | APIs called | read | check only | layoutOnly -> SetPending; Go arms and reloads; combat refused |
| `tests/statusstrip/theme_switcher.py:113` | pinned revision | test failure | change | 2 -> 3 |
| `tests/layoutv2/run.py` | tests | read | change | cast bar, aura, gap, name text, cast-bar-off, revision 3, re-apply cases; `session(before_boot=)` hook |
| check list §6 line 70, §11 | user docs | read, grep | change | auto re-apply replaces "switch once"; new first-login item |
| `install/설치안내.md` | user doc | grep (`Old → New`, `다시 적용`, revision) | no impact | no apply-path wording there |
| Earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines (re-apply: 3 new, one per preset) |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 |
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · `cases=43 passed=43 failed=0` |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |
| `python -I Collection/tests/firststart/run.py` | rc=0 · `cases=29 passed=29 failed=0` |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/pitbull4/run.py` | rc=0 · `cases=6 passed=6 failed=0` |
| `python -I Collection/tests/pitbull4runtime/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/castbars/run.py` | rc=0 · `cases=16 passed=16 failed=0` |
| `python -I Collection/tools/luacheck.py <Core> DevilForever_ChatSetup <Chattynator Main/Fonts/skin>` | `checked=27 failed=0` |
| `python -I Collection/tools/extract.py` | rc=0 · `start=13 comparison=26 … errors=0` (manifest unchanged in git) |
| `python -I Collection/tools/genregistry.py --check` | `up to date (59395 bytes)` |
| `… patches.py verify` | `verify patches=8 unmodified=20 failures=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s61g_*.txt`, `s61i_layoutv2.txt`.

Re-apply test cases (`tests/layoutv2/run.py`, last block, fhd/qhd/uhd): same revision -> no reload, no line, nothing pending · New profile at revision 2 -> one reload, pending `<preset>-v2` armed, `tried` marked, notice stored; next login -> revision 3, one chat line, no reload; the login after that -> nothing · Old profile without a revision -> the same with `-v1`, revision 1 · a profile still stale after its attempt -> no second reload · combat at login -> nothing pending until PLAYER_REGEN_ENABLED, then one reload; a later combat end -> no second reload.

### Open (for the master / user)

- Tab row vs theme strip (b vs c): R175 kept exact, tab row directly above the message area; numbers in the table above.
- A border painted inside the prepared composition art is not known to the code (unverified).
- The re-apply goes the same way as the New/Old switch, so it also rewrites the Quartz bar spots and Grid2 cell sizes of the version in use (Quartz bars the user moved go back). Chattynator is untouched.
- Window 1 left clamp at 0 (text 2 units inside the screen-edge panel).

## Step 61 review fix (M1)

Input: `Claude/results/handoffs/phase27/TRIAGE_phase27.md` "Step 61 review" (79-end). Re-read in full before and after the edit: `Presets/V2.lua` 190-248 (re-apply block); `tests/layoutv2/run.py` 607-675 (re-apply block).

Finding M1: before this fix, `profileState` (`Presets/V2.lua:202-204`) read a PitBull4 profile without `dfLayoutV2` (one the collection never laid out) as "Old, revision 0". `ReapplyOutdatedLayout` (:210-217) then requested `-v1` and reloaded, which overwrote a user's own profile. Fix: `profileState` returns nothing unless `profile.dfLayoutV2` is a boolean. Every collection layout writes that flag: true for New, false for Old (`V2.lua:39`, `:90`). With no flag, `ReapplyOutdatedLayout` returns at `not key` (:213), before the tried mark, so nothing is requested, reloaded or marked.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets/V2.lua` `profileState` | the defect | triage, read | change | boolean flag required |
| `Presets/V2.lua` `ReapplyOutdatedLayout` (:209-233) | only caller | read | check only | `not key` returns before the tried mark and Restore |
| `Presets/V2.lua:39`, `:90` (flag writers: base preset false then V2 copies true; -v1 false, -v2 true) | writers | read | check only | every collection layout writes a boolean |
| `ThemeSwitcher.lua:254-260` versionInUse | other reader of the flag | read (earlier) | no impact | shows Old for a profile without the flag, unchanged |
| `tests/layoutv2/run.py` re-apply block | test that locked the old behaviour | read | change | Old case now asserts flag false (collection Old profile, no revision → -v1 once); new foreign case (no flag, no revision) → no request, no reload, no tried mark, no line, flag still absent |
| check list §11 apply line | user doc | read | check only | it speaks of profiles with a stored layout revision; a foreign profile has none |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 20 PASS lines |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |
| `python -I Collection/tools/luacheck.py Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | `checked=1 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s61r_*.txt`. The new foreign-profile case was not run against the code from before the fix (no mutation run). Reasoning instead: the old code read a missing flag as Old at revision 0, below `layoutV1Revision` 1, so it would have requested `-v1` and reloaded.

Minor 1 (tried mark set before Restore) and minor 2 (ReloadUI from a timer without hardware input, unverified in game) are not fixed, per triage.

## Step 62 (R186-R195, R198): chat window fit, IME, first-login re-apply, level/name, totem bar and timer, aura rows

Read before editing:
- `DevilForever_ChatSetup/Chattynator.lua` 1-353 (whole).
- `Chattynator/Display/Main.lua` 1-300.
- upstream `Chattynator-237/Chattynator/Display/Main.lua` UpdateEditBox.
- `Chattynator/Core/Fonts.lua` 95-143.
- `Chattynator/Skins/DevilForever.lua` (edit box grep).
- `DevilForever_Skin_NativeChat/Skin.lua` 1-100.
- `DevilForever_Appearance/Composition.lua` 1-62, 130-202, 455-518.
- `Presets/V2.lua` 1-250.
- `Presets/{fhd,qhd,uhd}.lua`: LuaTexts loop, companion/focus copies 568-600, Dominos frames 300-345, Totems 470-482, 640-670.
- `Presets.lua` 225-300.
- `Profiles.lua` 225-260, 315-341, 398-410.
- `API.lua` 80-110.
- `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` 230-285.
- `PitBull4/UnitFrameLayout.lua` 430-470, 500-600, 639-660, 805-862, 1280-1345, 1440-1560.
- `PitBull4/Main.lua` 495-515.
- `PitBull4/Modules/Totems/Totems.lua` (grep for placement and size).
- `Dominos/bars/totemBar/bar.lua` 90-260.
- `Dominos/core/buttonBar.lua` 195-300.
- `Dominos/core/frame.lua` 700-760.
- tests: `chatsetup/run.py` 896-1120 and 1370-1504; `layoutv2/run.py` 1-140, 262-500, 500-607; `statusstrip/theme_switcher.py` 86-120 and 345-380.
- check list 98-121; install guide line 54.

Read only, user saved settings: `WTF/Account/LKZ1412/SavedVariables/{Chattynator.lua, !DevilForever_Core.lua(.bak), PitBull4.lua(.bak)}` and `WTF/Account/LKZ1412/92/성좌-우부르카/SavedVariables/{DevilForever_ChatSetup.lua, Chattynator.lua}`. Only window, layout and request entries were read; no chat logs.
- Timestamps: 21:03:44 and 21:03:47 (the `/dfp go` reload) and 21:11:25 (later).
- The 20:41 files were rewritten before I opened the Chattynator files, so they show the post-install state, not the pre-install one.

### Diagnosis

| Item | Grade | Evidence |
|---|---|---|
| (c) window 1 never follows | confirmed | Per-character `DevilForever_ChatSetup.lua`: `layout.windows = {nil, {…}, {…}}`, so window 1 has no receipt. `FollowChattynatorLayout` drops a receipt that no longer matches (`Chattynator.lua:297-298` before this change) and never moves a window without one. Chattynator raises a window below its resize bounds: `Display/Main.lua:11` `self:SetResizeBounds(240, 140)`, then saves the raised size (`:16-19` OnSizeChanged → SavePosition/SaveSize). The user's window 1 is exactly `140.0000152587891` high, and the native-rectangle seed height was 135.56 (`managedLayout.roles.public.height`), so its receipt could never match. |
| (c) windows 2/3 "unchanged" | confirmed | After the go reload the receipts 2 and 3 equal the Chattynator windows (532.44, −984.11, 535.33×200.89 and 1610.22, …). The follow ran and placed them by the Step 61 rule: message top = panel top 1820 px, sides = the panel rectangle with no inset. |
| (c) window 3 text over the border and to the right edge | confirmed | The Step 61 rule put the message area exactly on the panel rectangle for a prepared composition (`panelInner`: "the code places no border inside it"). The deck picture paints a frame along the screen edges and the panel boundaries. Luminance sampled from `Themes/dwarf/Composition/uhd_deck_reviewed.tga` (2048×512, the user's theme `dwarf`, `CoreDB.theme.active`): bright frame at texels ~2-14 (left edge), ~509-522 (chat1/chat2 boundary), ~2030-2044 (right edge), which is ≈16 texels ≈ 30 px at uhd. Devil, fhd and qhd decks show the same pattern. The window's right side was the screen edge (1610.22 + 523.11 = 2133.3 units = 3840 px). |
| (c) tab row in the action bar row (R187) | confirmed | Step 61 kept R175: window top = message top + 27 units, so the tab row (top 22 units) sat 27..5 units above the panel top. At the user's 0.5556 units/px that is 1771-1811 px, centre 1791 px, ≈21 px above the strip centre (1812 px) and inside the upper bar band. |
| (a) 한/영 broken on the first login, fine after the go reload (R190) | mechanism unverified | Our code already sets scale 1 before anything else (`Display/Main.lua:247`). What restored IME both times was a later change to the finished box: the user's runtime `SetScale(1)` from scale ≠ 1, and the go reload. Nothing in our code differs between a fresh login and a reload (same PLAYER_ENTERING_WORLD path; the native chat skin's `SetFont` on `ChatFrame1EditBox` runs only for native windows, `styleRole`, and `result == "created"` is set for this character, so it may also touch the box — unverified whether it runs with Chattynator active). Default chosen: reproduce the user's working action at every load (scale 0.99, then 1 on the next frame, after Chattynator's setup), plus a one-line check. |
| (b) switch dead after the first login | confirmed | Core SV (21:03:47 file): `pending = {name = "uhd-v2", armed = true, requestedAt = 1795608227, armedAt = 1795608227}`, so the first-login re-apply ran Restore and Go in the same second. Go armed the request and called ReloadUI (`Profiles.lua:333-341`). No reload followed until the user typed `/dfp go` (R191), so a ReloadUI from the 1 s timer (`V2.lua` re-apply, `C_Timer.After(1, …)`) is not carried out. While a request waits, every Restore is refused (`Profiles.lua:235-237` "이미 기다리는 요청이 있음 … /dfp go 또는 /dfp cancel"), which is exactly the user's chat line from the switch. After the go (21:11:25 file): `dfLayoutV2 = true`, `dfLayoutRevision = 3`, no pending, `tried["Default|-v2"] = 3`, so the switch works again (R191). |
| (b) profile Old/revision 1 just before the go | not found | The 21:03:47 PitBull4 file shows `dfLayoutV2 = false`, `dfLayoutRevision = 1` while the tried mark says `-v2`. I found no code path in this session that writes revision 1 without a `-v1` apply; not explained. |
| (d) level + name off centre | confirmed | Level and name are two texts at `Portrait` `center` (`Presets/*.lua` LuaTexts loop: `Lua:레벨` position 1, `Lua:이름` position 2). PitBull4 places several centre texts from an estimated width: `UnitFrameLayout.lua` `position_indicator_on_bar:center` → `SetPoint("LEFT", bar, "CENTER", -get_half_width(...))`, with `get_half_width` = `ASSUMED_TEXT_WIDTH * size` per text. So the pair starts at a fixed offset regardless of the real text width. One text is anchored at CENTER (`#indicators_and_texts == 1`). |
| (e) totem bar beside the player | confirmed | Dominos `frames.totem` is a fixed TOPLEFT spot from the V1 design (uhd x 878 px). The layout-only presets carried no Dominos fragment, so New never moved it. |
| (f) player aura rows raised | confirmed | V2.lua set `root.dfAuraGeometry["플레이어"].top_margin=math.ceil(outside+icon+4)` for the totem timer at `out_top_right`, and the target has no raise. |

### What changed

| Item | Change |
|---|---|
| (c) | `DevilForever_ChatSetup/Chattynator.lua`: `rootRect`, `partSizes`, `stripCentre` added. Prepared composition: panel sides move in by one composition joint (fhd 16 / qhd 20 / uhd 32 px). The tab row is centred on `appearance.ribbon` (window top = strip centre + 11 units) and the message top is never above the panel inner top. Sizes are raised to Chattynator's 240×140 bounds by growing upwards. `FIT_VERSION = 2`: a seeded profile below it has all three windows placed once more regardless of receipts; receipts are then kept for all three; after that a dragged window is released as before. The seed writes `layout.version = 2`. |
| (a) | Same file: `addon.RefreshChattynatorEditBox()` at the PLAYER_ENTERING_WORLD timer (after seed and follow): `ChatFrame1EditBox:SetScale(0.99)`, then `SetScale(1)` on the next frame. |
| (b) | `Presets/V2.lua` re-apply: Restore only (no Go, no timer reload), then one chat line naming `/dfp go` and the switch; the notice-after-reload mechanism is removed. `ThemeSwitcher.lua` cycle: a waiting `preset <active>-v1/-v2` request is cancelled and replaced by the switch's own request, so the switch never stays dead. |
| (d) | `Presets/{fhd,qhd,uhd}.lua` LuaTexts loop (보통, 대상; copied to 소환수와 주시 and 주시): `Lua:레벨` `enabled=false`; `Lua:이름` code `Outline() return "%s %s",Level(unit),Name(unit)`, events + `UNIT_LEVEL`. One centred text in Old and New. |
| (e) | `Presets/V2.lua`: the base Dominos fragment's `frames.totem` goes into both layout-only presets. Old keeps the preset spot; New gets x centred under the player frame, anchored TOPLEFT to the screen's TOP (a wider screen keeps it under the player), y = preset totem row (fhd 748 / qhd 1056 / uhd 1636 px, between the cast row with swing and the action bars). Its `dfGeometry` signature follows. `modes.totemButton` = 44/52/72 px. Bar width = 6 buttons + 5 × 2 units (Dominos `bars/totemBar/bar.lua`: summon, 4 totems, recall). The layout-only message reads "PitBull4, Quartz, Grid2, Dominos 토템 막대" (`Presets.lua:290`). |
| (f) | `Presets/V2.lua`: no top_margin, so the player aura geometry equals the target's `{above=true,width=512}`. The PitBull4 totem timer stays on (R198): `out_bottom_left` with `dfOffsetX/dfOffsetY` = right of the Dominos totem bar + 8 px, vertically centred on it. Old: location unchanged (`out_right_bottom`), offsets 0. `PitBull4/UnitFrameLayout.lua` (patch): root indicators with `dfOffsetX`/`dfOffsetY` (frame units, right/down) move by that after their location; `Collection/patches/PitBull4.patch` regenerated (header unchanged). |
| revisions | `layoutV2Revision` 3 → 4 and `layoutV1Revision` 1 → 2, so existing profiles get d-f through the re-apply request. |

Old (V1) aura heights: V1 keeps the player `size_ratio .7` + `avoid_frame` rule and above = false for player and target (`V2.lua:94-95`). The totem timer in Old sits right of the player frame bottom, not in a buff row. No raise exists in Old, so it is left as it is.

Numbers (window rule, prepared composition, joint inset; tab row centre vs strip centre):

| Preset @ units/px | strip centre px | window 1 (x, top, w, h units) | tab row centre px | message top px (panel top) | message x px | bottom px |
|---|---|---|---|---|---|---|
| uhd @ 0.5556 (user, UI 0.64) | 1812 | 15.8, −995.7, 499.8, 184.3 | 1812.0 | 1840.8 (1820) | 32-928 / 994-1890 / 2934-3808 | 2124 |
| fhd @ 0.7111 (UI 1) | 855 | 9.4, −597.0, 290.7, 151.1 | 855.0 | 877.5 (860) | 16-422 / 456-862 / 1502-1904 | 1052 |
| qhd @ 0.5333 (UI 1) | 1180 | 8.7, −612.0, 311.3, 140.0 | 1168.1 / 1177.5 | 1198.1 (1186) | 20-600 / 642-1222 / 1966-2540 | 1410 |

At qhd UI scale 1 the windows are below Chattynator's 140-unit minimum height, so they grow upwards and the tab row sits 2.5-12 px above the strip centre. At the user's uhd scale and at fhd it is exact.

The user's windows under the new code (test `chattynator_users_saved_windows_are_placed_again_once`, built from the saved values): all three move (window 1 included), tab rows on the strip centre, message area inside the inner rectangle, right edge 2115.6 units < 2133.3 (screen), receipts 1-3 kept, `version = 2`. A later drag stays where the user put it.

Totem bar and timer at fhd/qhd/uhd, New (layoutv2 test): bar centred under the player, top at the totem row, below the swing line, above the action bars; timer 8 px right of the bar, centred on it; neither overlaps any other rectangle in the screen map. The only exception is the `appearance.aux` art band behind the class/totem row, which the Old totem bar also sits on. The timer at uhd is right of 1670 px and below the focus column's cast row, so it does not overlap it.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `DevilForever_ChatSetup/Chattynator.lua` panelInner / prepared / follow / seed / PEW timer | the defect (c, a) | read whole | change | rules above |
| `Chattynator/Display/Main.lua:11, :16-19, :228` (bounds, saving, message offsets) | Chattynator rules the placement relies on | read | check only | 240×140, TabsBar 22, message top 27 / left 2 / bottom 5 |
| `DevilForever_Appearance/Composition.lua` `parts.sizes`, `active`, `partsShown` | read by panelInner | read | check only | joint sizes per preset |
| `DevilForever_Skin_NativeChat/Skin.lua` edit box SetFont | other code touching ChatFrame1EditBox | read | check only | native windows only; not changed (IME cause unverified) |
| `Presets/V2.lua` re-apply, modes, Dominos copy, totem/timer/aura lines, revisions | the defect (b, e, f) | read | change | |
| `Profiles.lua:235-237, :315-341` CanRequest / Cancel / Go | APIs | read | check only | the switch cancels, then requests |
| `ThemeSwitcher.lua` cycle | switch | read | change | takeover |
| `Presets.lua:290` layout-only message | user-facing text | grep | change | Dominos totem bar now in the layout-only presets |
| `Presets/{fhd,qhd,uhd}.lua` LuaTexts loop | the defect (d) | read | change | |
| `PitBull4/UnitFrameLayout.lua` indicator layout | needed for (f) | read | change (patch) | offset for root indicators |
| `Collection/patches/PitBull4.patch` | patch store | regenerate | change | |
| `DevilForever_Skin_Dominos` dfGeometry rescale | reads the totem `dfGeometry` | grep | check only | signature kept in step |
| `Dominos/core/frame.lua:714-750` saved position | reader of point/relPoint | read | check only | relPoint TOP supported |
| tests chatsetup, layoutv2, theme_switcher | tests | read | change | new rules and cases |
| check list §6 line 70, §10, §11, new §12; install guide line 54 | user docs | read | change | |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · `cases=45 passed=45 failed=0` |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |
| `python -I Collection/tests/firststart/run.py` | rc=0 · `cases=29 passed=29 failed=0` |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/pitbull4/run.py` | rc=0 · `cases=6 passed=6 failed=0` |
| `python -I Collection/tests/pitbull4runtime/run.py` | rc=0 · `cases=20 passed=20 failed=0` |
| `python -I Collection/tests/castbars/run.py` | rc=0 · `cases=16 passed=16 failed=0` |
| `python -I <devnull_run.py> Collection/tests/patches/run.py` | rc=0 · `cases=4 passed=4 failed=0` (without the wrapper: Git diff `nul` error, environment) |
| `python -I Collection/tools/luacheck.py <Core> DevilForever_ChatSetup ThemeSwitcher.lua PitBull4/UnitFrameLayout.lua` | `checked=26 failed=0` |
| `… patches.py regenerate --package PitBull4` | wrote 331827 bytes · header unchanged |
| `… patches.py verify` | `verify patches=8 unmodified=20 failures=0` |
| `python -I Collection/tools/extract.py` | rc=0 · `errors=0` |
| `python -I Collection/tools/genregistry.py --check` | up to date |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s62*.txt`. `tests/performance/run.py` needs `--dominos-zip` and was not run.

### Open (for the master / user)

- (a) The IME mechanism is unverified; the fix repeats the user's working action at every load. Check on a fresh login; if it still fails, the next candidate is the box's font object (`SetFontObject` with a font family copy, `Display/Main.lua:274`).
- (c) The one-time re-placement moves all three windows of a seeded profile once, even one a user had moved under an earlier rule (no way to tell those apart; R188 says these were never moved).
- (c) qhd at UI scale 1: the tab row sits up to 12 px above the strip centre (Chattynator's 140-unit minimum height).
- (c) The joint inset is my default from the deck art samples (frame ≈16 texels). Themes other than dwarf/devil were not sampled.
- (d) A very long name can still reach the percent text; PitBull4 texts have no width limit.
- (e) The 30-unit Dominos totem button size is taken from the presets' own scale (pixel × button / 30), not measured in game. The Dominos class bar row (`frames.class`, uhd x 760) is unchanged and empty for a shaman.
- (b) The Old/revision-1 state just before the go is not explained.

## Step 62 review fix (M1)

Input: `TRIAGE_phase27.md` "Step 62 review". Re-read before editing: `Presets/V2.lua` 193-262 (re-apply block), check list lines 70, 115-116, 126, install guide (grep `dfp go`, `버전 전환`: no such line), `tests/layoutv2/run.py` notice assertions, `tests/statusstrip/theme_switcher.py:373`.

M1: the first-login notice told the player that pressing the status strip version switch applies the reservation. For a profile below this build's revision the switch shows Old (`ThemeSwitcher.lua` versionInUse needs `dfLayoutRevision == layoutV2Revision`), so pressing it cancels the reservation and requests the other version. For an Old profile that means New instead of the reserved Old.

Fix:
- The notice and its code comment name only `/dfp go` as the way to apply the reservation.
- The check list describes the switch as an ordinary "go to the other version" control that is never blocked: pressing it drops the reservation. An earlier-build layout shows Old, so pressing it goes to New.
- No code path changed (switch takeover as in Step 62).

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets/V2.lua` re-apply notice + comment | the defect | triage, read | change | `/dfp go` only |
| `ThemeSwitcher.lua` cycle comment ("replaced by this one") | same behaviour described | read | check only | already says the switch replaces the request |
| check list :70, :115, :116, :126 | user docs | grep `버전 전환` | change | apply = `/dfp go`; switch = other version, never blocked |
| install guide | user doc | grep | no impact | no line on applying the reservation |
| `tests/layoutv2/run.py` notice check | test | read | change | also asserts the notice does not name the switch |
| `tests/statusstrip/theme_switcher.py:373` | test | read | check only | matches the unchanged prefix `다시 적용하도록 예약` |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 20 PASS lines |
| `python -I Collection/tools/luacheck.py Collection/AddOns/!DevilForever_Core/Presets/V2.lua` | `checked=1 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s62r*.txt`. Minor 1 and minor 2 are not fixed, per triage.

## Step 63 (R205): update applies by itself — mechanism found before the change

Read: `!DevilForever_Core/Profiles.lua` 15-60, 840-930, 1075-1139; `Presets.lua` 1-92, 425-700; `Core.lua` 242-265.

- An armed request is taken at Core's ready step (`Profiles.lua:1081` readyCallbacks → `takePending` 846-889). It is used only when `armed`, on the same character, and within `PENDING_MAX_AGE` of `/dfp go` (878). A preset request becomes `presetRequest`, which `Presets.lua:614-623` (readyCallbacks) takes into `request`.
- Fragments are written at each target addon's ADDON_LOADED (`Presets.lua:633-636` → `onAddonLoaded` 556-596). Core loads first, so its handler runs before the target's own: `Profiles.lua:33` "before the addon's own handler (Core loads first …)", and `Presets.lua:48` writes after Defaults' handler. In "requested" mode every fragment of the request for that folder is written (`writeFragment` 457-523). The only exception is a saved variable whose AceDB is already open (468-470, skipped).
- So a request has to exist before a target's ADDON_LOADED. PitBull4's own saved variable (`PitBull4DB`, which holds the layout flag and revision) is readable only from PitBull4's ADDON_LOADED. Targets that load before PitBull4 (Dominos, Grid2 load alphabetically before PitBull4; Quartz after — load order not checked in game) are past their write point by then. They can only get the values at the next load.
- Fresh install: PitBull4DB is nil at its ADDON_LOADED, so `Profiles:WasFresh` is true and the active preset's fragments are written in "fresh" mode (`dueFragments` 549-552 → `onAddonLoaded` 573-593). The base preset carries the V2 fragments at version + 10 (`V2.lua`), so a new profile gets New at the current revision without any request or command.
- The ReloadUI the earlier re-apply needed is not carried out from a timer (Step 62 diagnosis). Typing `/dfp go` was the only remaining path, which R205 rules out.

### Step 63 — what changed

Further reads for the change: `Presets.lua` 1-92 and 425-700, re-read after the edit (catch-up block, ready step, PEW summary, the new PEW handler); `Presets/V2.lua` tail; `tests/layoutv2/run.py` 1-45 and the old re-apply block; `tests/statusstrip/theme_switcher.py` 360-385; check list 69-70, 113-129; install guide 44-60.

| Place | Change |
|---|---|
| `!DevilForever_Core/Presets.lua` | Layout catch-up (header comment). `outdatedLayout(v2, revision)` treats a boolean flag below the build's revision of its version as outdated. The request starts at PitBull4's ADDON_LOADED (Core's handler, before PitBull4 reads `PitBull4DB`), or at Core's ready step when the last load recorded the state (`layoutRevision.seen`, written at every PLAYER_ENTERING_WORLD for a collection profile). `startCatchUp` sets `request = {name = <active>-v2/-v1, auto, only = folders not loaded yet, later = folders already loaded}`, marks `tried["Default|<suffix>"] = revision`, and stores `due = {name, char, keys, folders}` for the folders already loaded. At the next ready step `due` becomes an `only` request for those folders (same character, or the character not known yet). `dueFragments` honours `only`. One line at the first PLAYER_ENTERING_WORLD: "New/Old 배치를 이 판에 맞춰 적용했습니다(<written>) — <later> 는 다음 접속 때 자동으로 적용됩니다." or "…적용했습니다(<written>).". Nothing goes to `DevilForever_ProfilesDB.pending`, so no `/dfp go`, no ReloadUI, and the switch is never blocked. `layoutRevision` is created only when written. |
| `!DevilForever_Core/Presets/V2.lua` | The PLAYER_ENTERING_WORLD re-apply (Restore + notice) is removed; the revision comment points to the catch-up. |
| `tests/layoutv2/run.py` | `session(after=…)` and `ADDON_VERSIONS` (target addon metadata), and `carry` includes `Grid2DB` and `DominosDB`. The old re-apply block is replaced by the catch-up cases per preset (listed below). |
| `tests/statusstrip/theme_switcher.py` | The waiting request is made with `Presets:Restore(<preset>-v1)`; the switch still replaces it. |
| check list §6 line 70, §11 lines 115-116, §12 line 126; install guide (new line after "unit 프레임은 …") | The update path names no command: values go in by themselves (PitBull4·Quartz on the first login, Dominos totem bar·Grid2 on the next), and the switch is always "go to the other version", never blocked. |

Catch-up test cases (`tests/layoutv2/run.py`, per preset):
- Fresh install: the fresh path gives New at the current revision; no line, no tried mark.
- Same revision: nothing happens.
- Older New profile with no recorded state: PitBull4 and Quartz are written in the same load and the revision is current in that load; one line; `due = {dominos, grid2}`; no reload, nothing pending. At the next load Dominos and Grid2 are written and the Dominos totem x equals the V2 value; one line; `due` is cleared. The third load does nothing.
- Recorded state, later update: all four targets in one load.
- Old profile without a revision: Old is written (not New).
- Tried revision: nothing.
- Foreign profile (no flag): nothing; no tried mark, no `seen`.

Targets affected by "next load":
- Every folder whose ADDON_LOADED comes before PitBull4's, among the layout preset's folders. With the usual alphabetical load order (not checked in game) that is Dominos (totem bar) and Grid2 (cell size and window spot).
- PitBull4 and Quartz get the values in the same load.
- From the next update on, the state recorded at the last load starts the catch-up at Core's ready step, so all four targets update in the first load.

Combat: the catch-up writes saved-variable data at load before the addons read it; no frame is moved, so there is no combat case left (the earlier Restore refused in combat).

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets.lua` request / dueFragments / onAddonLoaded / ready / PEW | the change | read | change | catch-up |
| `Profiles.lua` takePending / pending | other request path | read | check only | not used by the catch-up (nothing pending) |
| `Presets/V2.lua` re-apply block | replaced behaviour | read | change (removed) | |
| `ThemeSwitcher.lua` versionInUse and takeover | switch | read | check only | still compares the stored revision and takes over waiting requests |
| `DevilForever_ChatSetup/ChatLayout.lua:139` `GetAppliedRequest` | reader of the applied request | grep | check only | the catch-up does not set `appliedRequest` (native chat layout only follows a typed request) |
| `Core.lua:293` CoreDB layout comment | doc of CoreDB keys | grep | check only | lists keys per module; layoutRevision existed since Step 61 |
| tests core, layoutv2, theme_switcher | tests | run | change (layoutv2, theme_switcher) | |
| check list, install guide | user docs | grep `dfp go`, `예약` | change | |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines (catch-up: 3) |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 20 PASS lines |
| `python -I Collection/tests/core/run.py` | first run 108/109 (`core_without_other_addons`: an empty `layoutRevision` table made at ready); after the fix rc=0 · `cases=109 passed=109 failed=0` |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 29/29 |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · 20/20 |
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · 45/45 |
| `python -I Collection/tests/pitbull4/run.py` | rc=0 · 6/6 |
| `python -I Collection/tests/pitbull4runtime/run.py` | rc=0 · 20/20 |
| `python -I Collection/tests/castbars/run.py` | rc=0 · 16/16 |
| `python -I <devnull_run.py> Collection/tests/patches/run.py` | `cases=4 passed=4 failed=0` |
| `python -I Collection/tools/luacheck.py <Core> ThemeSwitcher.lua` | `checked=22 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s63*.txt`.

### Open
- The load order (Dominos and Grid2 before PitBull4) is the usual alphabetical one and was not checked in game. The chat line names what was written and what waits, whichever order the client uses.
- If the character is not known at PitBull4's ADDON_LOADED, the catch-up does not start in that load; it starts at the next load's ready step from the recorded state.
- The user's current profile (New, revision 3, tried `-v2` = 3) gets revision 4 by this path: PitBull4 and Quartz on the first login, Dominos and Grid2 on the next.

## Step 63 review fix (M1)

Input: `TRIAGE_phase27.md` "Step 63 review". Re-read before editing: `Presets.lua` 678-712 (ready step) and the header block.

M1: the deferred catch-up part (`layoutRevision.due`) was dropped only for an unregistered name or when its own request finished. The ready step takes a player's own request first (status strip switch or `/dfp preset` + `/dfp go`) and then skips `due` (`if not request and type(due) == "table"`). So `due` survived, and a later load wrote the old version's Dominos totem bar and Grid2 values over the player's choice.

Fix: at the ready step, a request present before the catch-up code (only the player's own; the catch-up's requests are made after this point) drops `due`. The header comment names the rule.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets.lua` ready step | the defect | triage, read | change | drop `due` when a player request is taken |
| `Presets.lua` header comment | describes `due` | read | change | names the rule |
| `Presets.lua` PEW `finishing` clear, unregistered-name clear | other places that drop `due` | read | check only | unchanged |
| `ThemeSwitcher.lua` / `Commands.lua` (switch, `/dfp preset`) | where player requests come from | read (earlier) | check only | they make an ordinary pending request, taken at the ready step |
| `tests/layoutv2/run.py` catch-up block | test | read | change | new case |
| earlier sections of this log | record | - | no impact (record) | |

New test, per preset:
1. Catch-up first load (`due` = dominos + grid2).
2. The player requests `<preset>-v1` and types `/dfp go`.
3. Next load: `due` is gone; PitBull4 is Old at the V1 revision; the Dominos totem matches the V1 x and relPoint; the Grid2 cells match V1.
4. The load after: no catch-up line, no `due`, Dominos and Grid2 unchanged (still Old).

The assertion `'due' not in` at step 3 targets the defect directly. The test was not run against the code before the fix (no mutation run).

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 45 PASS lines |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 20 PASS lines |
| `python -I Collection/tests/core/run.py` | rc=0 · `cases=109 passed=109 failed=0` |
| `python -I Collection/tests/firststart/run.py` | rc=0 · `cases=29 passed=29 failed=0` |
| `python -I Collection/tools/luacheck.py Collection/AddOns/!DevilForever_Core/Presets.lua` | `checked=1 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36 folders/2353 files · 38/2297 |

Raw outputs: `<scratch>/s60/s63r*.txt`. Minors are not fixed, per triage.

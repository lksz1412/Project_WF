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

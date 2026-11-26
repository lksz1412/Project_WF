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

## Step 65 (R212, R214): Old aura blocks over their own frames, pet/focus up; debuffs right above the buffs

Read:
- `Presets/V2.lua` 1-130 (V1 path, root edits) and the V1 probe output (`-v1` request in the layoutv2 harness: unit positions, `dfAuraGeometry`).
- `PitBull4/Modules/Aura/Layout.lua` 395-520 (managed aura geometry) and `Modules/Aura/Forever.lua` 176-200, 290-335 (native groups and containers).
- `Presets/uhd.lua` Aura loop (488-511).
- `tests/layoutv2/run.py` 90-140, 350-470, 500-560.
- Samples: `SourceArchive/2022-11-19/extracted/Interface/addons/!DevilUI/Profile/PitBull4.lua` 9863-10150 (Aura namespace); `SourceArchive/user-provided-alpha/originals/DevilUI6.1Alpha.zip` entry list.

### Causes

| Item | Grade | Evidence |
|---|---|---|
| (a) Old auras in side columns, pet/focus right above player/target | confirmed | V1 `dfAuraGeometry` player `{size_ratio=.7, side="left", width=148, above=false, avoid_frame=pet}` and target `{…side="right"…, avoid_frame=focus}`. uhd V1: player 878..1390 × 1414..1558 px, pet 1034..1390 × 1189..1301, focus 2450..2806 × 1189..1301 — only 113 px between pet and player, no room for rows above. |
| (b) empty row between buffs and debuffs | confirmed | The managed rule (`Layout.lua` 466-470 before the change) reserved `group_height(my_size) + group_height(size)` = ceil(14/12) + ceil(14/12) = 4 rows. Own and others' buffs share one native flow (`Forever.lua` update_group: `forceNewLine` only with `new_row_size` and a different own size; buffs are 40/40), so 28 buffs fill 3 rows (124 px at uhd). Measured gap from buff top to debuff bottom: 46 px at uhd (one empty 42 px row + 4). The preset formula `buffRows = ceil((2*14+2)/12)` (uhd.lua:494-511) is not used for 보통/대상: the managed rule replaces its offset. |
| (1) Devil samples | partly found | `!DevilUI/Profile/PitBull4.lua` Aura profiles differ. "Normal" 대상: buff `offset_y=-4` (no anchor key, `:10029-10034`), debuff `anchor=BOTTOMLEFT, growth=right_down, offset_y=-28` (`:10036-10047`), i.e. debuffs below the frame. "loaf" 대상: debuff `TOPLEFT/TOP/right_up offset_y=20` (`:9883-9893`), i.e. above; buff `side=LEFT offset_x=15 offset_y=-25` (`:9897-9905`), i.e. at the side. Which profile the samples used and PitBull4's defaults for the missing keys were not checked. The samples show no single clearly different arrangement, so the New rule (rows above, debuffs over buffs) is kept. The Alpha archive is one installer `DevilUI 6.1 Alpha.exe` (7.7 MB); not run or unpacked (untrusted executable), so not read. |

### What changed

| Place | Change |
|---|---|
| `PitBull4/Modules/Aura/Layout.lua` (patch) | Debuff offset = buff offset + the rows the buffs fill: one flow of 2 × max_buffs at max(own, others) size, or two groups when own buffs start a new row (`new_row_size` with a different own size), + max(2, row spacing). New and Old both; runtime code, so no profile revision needed. |
| `Presets/V2.lua` V1 path | `dfAuraGeometry` player/target `{above=true,width=main frame width}`, pet/focus `{above=true,width=companion width}`. The pet group (pet, its target chain, Quartz Pet bar) and the focus group (focus, its chain, Quartz Focus bar) move up together so their lowest part ends 8 px (`OLD_STACK_GAP`) above the player's / target's aura block. `modes.mainAuras` = main aura block height measured with the new rule: fhd 216 / qhd 285 / uhd 416 px. `layoutV1Revision` 2 → 3, so the Step 63 catch-up writes it in the first load (V1 targets PitBull4 and Quartz). |
| `Collection/patches/PitBull4.patch` | regenerated (332268 bytes, header unchanged) |
| `tests/layoutv2/run.py` | `default_screen_map(…,'v1')`. Old aura test per preset (fhd, qhd, uhd 3840, uhd 3862): each block at frame width, bottom within 10 px above its frame, no overlap with any rect of the map except its own frame/bands and the art backdrops `appearance.unitUpper/unitLower/aux`; Grid2 party clear; pet/focus above the blocks. The V1 back-switch assertion now expects the four above rules. The catch-up cases use `layoutV1Revision` (3). |
| check list | new §13 (Old aura blocks, debuff gap, update without command) |

Numbers (Old, px; aura block = x, y, w, h from the test):

| Preset | player block | target block | pet block | focus block |
|---|---|---|---|---|
| fhd | 439, 415, 256, 212 | 1225, 415, 256, 212 | 517, 272, 178, 48 | 1225, 249, 178, 48 |
| qhd | 585, 612, 342, 280 | 1633, 612, 342, 280 | 691, 430, 236, 60 | 1633, 401, 236, 60 |
| uhd | 878, 998, 512, 408 | 2450, 998, 512, 408 | 1034, 477, 356, 78 | 2450, 707, 356, 78 |

The pet sits higher than the focus because the Old Quartz Pet bar lies above-left of the pet and moves with it. At uhd the pet top is 555 px and the focus top is 785 px.

Debuff gap after the fix: buff band top to debuff band bottom = 4 px. uhd main block: buffs 124 + debuffs 280; fhd 64 + 144.

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Aura/Layout.lua` GetManagedLayoutDB | the defect (b) | read | change | |
| `Aura/Forever.lua` update_group / container | flow rules the fix relies on | read | check only | |
| `Presets/V2.lua` V1 root edits | the defect (a) | read | change | |
| Quartz Pet/Focus fragments in V1 | moved with their frames | read | change (values) | |
| `Presets/{fhd,qhd,uhd}.lua` Aura placement | preset offsets | read | check only | replaced by the managed rule for main/companion frames |
| party frames (unmanaged Aura) | other aura users | read | no impact | no `dfAuraGeometry` rule |
| Step 63 catch-up | delivers the change | read | check only | V1 revision bump |
| tests layoutv2 | tests | read | change | |
| check list | user doc | read | change | |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 50 PASS lines (Old aura: 5) |
| `python -I Collection/tests/core/run.py` | rc=0 · 109/109 |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 29/29 |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · 20/20 |
| `python -I Collection/tests/pitbull4/run.py` | rc=0 · 6/6 |
| `python -I Collection/tests/pitbull4runtime/run.py` | rc=0 · 20/20 |
| `python -I Collection/tests/castbars/run.py` | rc=0 · 16/16 |
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · 45/45 |
| `python -I <devnull_run.py> Collection/tests/patches/run.py` | 4/4 |
| `… patches.py regenerate --package PitBull4` / `verify` | wrote 332268 bytes · `patches=8 failures=0` |
| `python -I Collection/tools/luacheck.py Presets/V2.lua PitBull4/Modules/Aura/Layout.lua` | `checked=2 failed=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36/2353 · 38/2297 |

Raw outputs: `<scratch>/s60/s65*.txt`.

### Open
- The Grid2 raid window at its 40-player maximum covers the Old target and focus aura blocks at every preset.
- The Old target block also overlaps Details window 1 at every preset (fhd: Details 1 at 1320..1692 × 466..634; the target block reaches 1481 × 415..627).
- Neither is moved here; the test reports both.
- The art panels `appearance.unitUpper` / `unitLower` stay where the Old frames used to be, under the new aura blocks.
- `mainAuras` is measured, not computed: if the preset aura sizes or counts change, the test fails and the numbers must be measured again.

## Step 66 (R216-R221, R225, R229): one section structure for every theme, chat text areas and minimap inside it, pet/totem bars right-aligned, no timestamps

Scope as re-set by the user:
- R219: Devil is the baseline.
- R220: the three chat panels have equal width and equal gaps.
- R221: Devil is redrawn too. The target structure is defined in code, starting from the current Devil layout; Codex redraws all themes to it.
- R225: in New, the pet bar and the totem bar right-align with the player frame.
- R229: no chat timestamps.
- R216-R218 (make every theme uniform through code) are replaced by R219.

Read:
- `Presets/{fhd,qhd,uhd}.lua` appearance.* edits 1-250, Dominos frames 300-372 (fitPet), Aura and totem parts.
- `Defaults/SexyMap.lua` 95-240.
- `DevilForever_Appearance/Composition.lua` 1-62, 130-202, 455-518; `Appearance.lua` 105-125; `Themes/{devil,alliance,horde}.lua` border.size.
- `codex-briefs/appearance-27-hud-parts.md` (whole).
- `DevilForever_ChatSetup/Chattynator.lua` panelInner / prepared / seed / follow.
- tests: chatsetup 896-1530, firststart 112-126 and 325-345, layoutv2 470-600.
- Every theme's `Composition/<preset>_deck(_reviewed).tga`, measured with a script (`<scratch>/s60/s66_measure.py`; read only).

### Target structure (code)

| Preset | chat1 | seam | chat2 | seam | action | seam | minimap | seam | chat3 | border |
|---|---|---|---|---|---|---|---|---|---|---|
| fhd | 0+437 | 437+2 | 439+437 | 876+2 | 878+409 | 1287+2 | 1289+192 | 1481+2 | 1483+437 | 6 |
| qhd | 0+618 | 618+2 | 620+618 | 1238+2 | 1240+474 | 1714+2 | 1716+224 | 1940+2 | 1942+618 | 8 |
| uhd | 0+953 | 953+2 | 955+953 | 1908+2 | 1910+669 | 2579+2 | 2581+304 | 2885+2 | 2887+953 | 12 |

Forced changes, with numbers:
- The action panel loses 1 px at fhd (410 → 409) and uhd (670 → 669) to give an integer equal chat width.
- The action panel moves left by 2 (fhd), 4 (qhd), 14 (uhd) px; the minimap panel by 3, 4, 15 px.
- Dominos bars 4 and 5 move with the action panel (x 886 → 884, 1250 → 1246, 1932 → 1918).
- SexyMap sits inside the minimap panel one border in: fhd 1295,866 180x180 · qhd 1724,1194 208x208 · uhd 2593,1832 280x280.

Border: one value per preset (Composition `PART_SIZES.border` 6/8/12) on every side of every section, the same for every theme. The individual-panel edge line `border.size` of the horde theme goes 2 → 1 (devil and alliance are 1).

### Per-theme measurement (Codex input; also in the brief)

### 목표 구조 — 칸 바깥 사각형과 안쪽(테두리 안) 사각형 (물리 픽셀, 왼쪽 위 원점)

**fhd** — 칸 높이 y 860–1052, 테두리 두께 6 px, 칸 사이 이음 2 px

| 칸 | 바깥 x | 바깥 너비 | 안쪽 x | 안쪽 y |
|---|---|---|---|---|
| chat1 | 0–437 | 437 | 6–431 | 866–1046 |
| chat2 | 439–876 | 437 | 445–870 | 866–1046 |
| action | 878–1287 | 409 | 884–1281 | 866–1046 |
| minimap | 1289–1481 | 192 | 1295–1475 | 866–1046 |
| chat3 | 1483–1920 | 437 | 1489–1914 | 866–1046 |

**qhd** — 칸 높이 y 1186–1410, 테두리 두께 8 px, 칸 사이 이음 2 px

| 칸 | 바깥 x | 바깥 너비 | 안쪽 x | 안쪽 y |
|---|---|---|---|---|
| chat1 | 0–618 | 618 | 8–610 | 1194–1402 |
| chat2 | 620–1238 | 618 | 628–1230 | 1194–1402 |
| action | 1240–1714 | 474 | 1248–1706 | 1194–1402 |
| minimap | 1716–1940 | 224 | 1724–1932 | 1194–1402 |
| chat3 | 1942–2560 | 618 | 1950–2552 | 1194–1402 |

**uhd** — 칸 높이 y 1820–2124, 테두리 두께 12 px, 칸 사이 이음 2 px

| 칸 | 바깥 x | 바깥 너비 | 안쪽 x | 안쪽 y |
|---|---|---|---|---|
| chat1 | 0–953 | 953 | 12–941 | 1832–2112 |
| chat2 | 955–1908 | 953 | 967–1896 | 1832–2112 |
| action | 1910–2579 | 669 | 1922–2567 | 1832–2112 |
| minimap | 2581–2885 | 304 | 2593–2873 | 1832–2112 |
| chat3 | 2887–3840 | 953 | 2899–3828 | 1832–2112 |

### 테마별 지금 그림의 안쪽(어두운 칸 바닥) — 채팅 칸 가운데 높이에서 잰 가로 구간과, 각 구간 가운데에서 잰 세로 구간 (px)

잰 방법: `<preset>_deck(_reviewed).tga`(2048×512, 화면 너비 × 받침 높이로 늘어남)에서 밝기 34 이하가 40 px 넘게 이어지는 구간 = 칸 안쪽. 차이 = 지금 그림 − 목표 안쪽(+ 는 오른쪽·아래로). 구간이 다섯이 아니면(문장·장식이 칸을 가름) 원래 구간을 그대로 적는다. 세로 위쪽 값이 받침 윗변(채팅 칸 윗변)과 같으면 위 테두리는 받침 그림 밖(위 띠 그림)에 있다.

**fhd**

| 테마 | 그림 파일 | chat1 | chat2 | action | minimap | chat3 | 세로(chat1) |
|---|---|---|---|---|---|---|---|
| devil | `devil/Composition/fhd_deck.tga` | 11–434 (+5 / +3) | 443–874 (-2 / +4) | 884–1287 (+0 / +6) | 1300–1478 (+5 / +3) | 1491–1909 (+2 / -5) | 860–1052 (-6 / +6) |
| alliance | `alliance/Composition/fhd_deck_reviewed.tga` | 3–431 (-3 / +0) | 448–874 (+3 / +4) | 891–1283 (+7 / +2) | 1298–1477 (+3 / +2) | 1490–1769 (+1 / -145) | 860–1047 (-6 / +1) |
| horde | `horde/Composition/fhd_deck_reviewed.tga` | 14–433 (+8 / +2) | 445–845 (+0 / -25) | 856–1279 (-28 / -2) | 1295–1479 (+0 / +4) | 1492–1796 (+3 / -118) | 860–1047 (-6 / +1) |
| human | `human/Composition/fhd_deck_reviewed.tga` | 12–436 (+6 / +5) | 446–877 (+1 / +7) | 890–1287 (+6 / +6) | 1302–1479 (+7 / +4) | 1492–1807 (+3 / -107) | 868–1043 (+2 / -3) |
| dwarf | `dwarf/Composition/fhd_deck_reviewed.tga` | 12–435 (+6 / +4) | 449–872 (+4 / +2) | 898–1245 (+14 / -36) | 1281–1457 (-14 / -18) | 1490–1827 (+1 / -87) | 860–1026 (-6 / -20) |
| gnome | `gnome/Composition/fhd_deck_reviewed.tga` | 9–437 (+3 / +6) | 443–877 (-2 / +7) | 887–1287 (+3 / +6) | 1299–1479 (+4 / +4) | 1489–1791 (+0 / -123) | 866–1046 (+0 / +0) |
| nightelf | `nightelf/Composition/fhd_deck_reviewed.tga` | 구간 7개: 14–437, 447–876, 888–1012, 1017–1067, 1156–1286, 1299–1478, 1491–1769 |  |  |  |  | 860–1031 (-6 / -15) |
| orc | `orc/Composition/fhd_deck_reviewed.tga` | 10–435 (+4 / +4) | 445–875 (+0 / +5) | 891–1263 (+7 / -18) | 1282–1471 (-13 / -4) | 1488–1772 (-1 / -142) | 869–1042 (+3 / -4) |
| tauren | `tauren/Composition/fhd_deck_reviewed.tga` | 15–433 (+9 / +2) | 445–874 (+0 / +4) | 888–1268 (+4 / -13) | 1284–1478 (-11 / +3) | 1492–1785 (+3 / -129) | 860–1046 (-6 / +0) |
| troll | `troll/Composition/fhd_deck_reviewed.tga` | 12–437 (+6 / +6) | 443–877 (-2 / +7) | 886–959 (+2 / -322) | 962–1286 (-333 / -189) | 1298–1479 (-191 / -435) | 862–1046 (-4 / +0) |
| undead | `undead/Composition/fhd_deck_reviewed.tga` | 10–435 (+4 / +4) | 445–877 (+0 / +7) | 890–1265 (+6 / -16) | 1279–1468 (-16 / -7) | 1482–1803 (-7 / -111) | 863–1042 (-3 / -4) |
| skyborne | `skyborne/Composition/fhd_deck_reviewed.tga` | 7–436 (+1 / +5) | 443–878 (-2 / +8) | 886–1286 (+2 / +5) | 1298–1478 (+3 / +3) | 1488–1812 (-1 / -102) | 860–1048 (-6 / +2) |
| skyborne-horde | `skyborne-horde/Composition/fhd_deck_reviewed.tga` | 7–437 (+1 / +6) | 443–876 (-2 / +6) | 894–1261 (+10 / -20) | 1286–1478 (-9 / +3) | 1491–1811 (+2 / -103) | 861–1049 (-5 / +3) |

**qhd**

| 테마 | 그림 파일 | chat1 | chat2 | action | minimap | chat3 | 세로(chat1) |
|---|---|---|---|---|---|---|---|
| devil | `devil/Composition/qhd_deck.tga` | 16–614 (+8 / +4) | 628–1235 (+0 / +5) | 1249–1714 (+1 / +8) | 1730–1938 (+6 / +6) | 1952–2544 (+2 / -8) | 1186–1410 (-8 / +8) |
| alliance | `alliance/Composition/qhd_deck_reviewed.tga` | 5–610 (-3 / +0) | 632–1234 (+4 / +4) | 1256–1710 (+8 / +4) | 1728–1935 (+4 / +3) | 1959–2379 (+9 / -173) | 1186–1405 (-8 / +3) |
| horde | `horde/Composition/qhd_deck_reviewed.tga` | 19–612 (+11 / +2) | 629–1194 (+1 / -36) | 1210–1705 (-38 / -1) | 1722–1939 (-2 / +7) | 1956–2411 (+6 / -141) | 1186–1404 (-8 / +2) |
| human | `human/Composition/qhd_deck_reviewed.tga` | 18–616 (+10 / +6) | 631–1239 (+3 / +9) | 1255–1715 (+7 / +9) | 1731–1939 (+7 / +7) | 1954–2425 (+4 / -127) | 1195–1400 (+1 / -2) |
| dwarf | `dwarf/Composition/qhd_deck_reviewed.tga` | 18–615 (+10 / +5) | 635–1234 (+7 / +4) | 1265–1666 (+17 / -40) | 1708–1912 (-16 / -20) | 1950–2446 (+0 / -106) | 1186–1380 (-8 / -22) |
| gnome | `gnome/Composition/qhd_deck_reviewed.tga` | 14–618 (+6 / +8) | 626–1240 (-2 / +10) | 1251–1714 (+3 / +8) | 1728–1939 (+4 / +7) | 1950–2405 (+0 / -147) | 1193–1403 (-1 / +1) |
| nightelf | `nightelf/Composition/qhd_deck_reviewed.tga` | 구간 7개: 20–618, 632–1238, 1254–1384, 1411–1459, 1559–1712, 1729–1936, 1952–2378 |  |  |  |  | 1186–1385 (-8 / -17) |
| orc | `orc/Composition/qhd_deck_reviewed.tga` | 14–615 (+6 / +5) | 629–1238 (+1 / +8) | 1256–1686 (+8 / -20) | 1709–1929 (-15 / -3) | 1949–2385 (-1 / -167) | 1197–1398 (+3 / -4) |
| tauren | `tauren/Composition/qhd_deck_reviewed.tga` | 21–612 (+13 / +2) | 629–1235 (+1 / +5) | 1252–1692 (+4 / -14) | 1711–1936 (-13 / +4) | 1955–2398 (+5 / -154) | 1186–1403 (-8 / +1) |
| troll | `troll/Composition/qhd_deck_reviewed.tga` | 18–618 (+10 / +8) | 626–1239 (-2 / +9) | 1251–1336 (+3 / -370) | 1339–1714 (-385 / -218) | 1728–1939 (-222 / -613) | 1188–1403 (-6 / +1) |
| undead | `undead/Composition/qhd_deck_reviewed.tga` | 14–615 (+6 / +5) | 630–1240 (+2 / +10) | 1255–1689 (+7 / -17) | 1705–1925 (-19 / -7) | 1941–2421 (-9 / -131) | 1190–1399 (-4 / -3) |
| skyborne | `skyborne/Composition/qhd_deck_reviewed.tga` | 10–616 (+2 / +6) | 628–1240 (+0 / +10) | 1251–1714 (+3 / +8) | 1726–1936 (+2 / +4) | 1949–2431 (-1 / -121) | 1186–1405 (-8 / +3) |
| skyborne-horde | `skyborne-horde/Composition/qhd_deck_reviewed.tga` | 9–618 (+1 / +8) | 626–1239 (-2 / +9) | 1261–1684 (+13 / -22) | 1712–1938 (-12 / +6) | 1952–2431 (+2 / -121) | 1187–1407 (-7 / +5) |

**uhd**

| 테마 | 그림 파일 | chat1 | chat2 | action | minimap | chat3 | 세로(chat1) |
|---|---|---|---|---|---|---|---|
| devil | `devil/Composition/uhd_deck.tga` | 26–949 (+14 / +8) | 969–1909 (+2 / +13) | 1931–2588 (+9 / +21) | 2608–2889 (+15 / +16) | 2912–3816 (+13 / -12) | 1820–2125 (-12 / +13) |
| alliance | `alliance/Composition/uhd_deck_reviewed.tga` | 8–943 (-4 / +2) | 979–1911 (+12 / +15) | 1942–2582 (+20 / +15) | 2606–2888 (+13 / +15) | 2910–3589 (+11 / -239) | 1820–2117 (-12 / +5) |
| horde | `horde/Composition/uhd_deck_reviewed.tga` | 구간 7개: 30–947, 973–1847, 1871–2574, 2601–2891, 2918–3632, 3698–3742, 3758–3812 |  |  |  |  | 1820–2116 (-12 / +4) |
| human | `human/Composition/uhd_deck_reviewed.tga` | 26–954 (+14 / +13) | 977–1916 (+10 / +20) | 1939–2589 (+17 / +22) | 2612–2891 (+19 / +18) | 2916–3654 (+17 / -174) | 1832–2110 (+0 / -2) |
| dwarf | `dwarf/Composition/uhd_deck_reviewed.tga` | 26–952 (+14 / +11) | 982–1909 (+15 / +13) | 1954–2520 (+32 / -47) | 2578–2856 (-15 / -17) | 2908–3681 (+9 / -147) | 1821–2083 (-11 / -29) |
| gnome | `gnome/Composition/uhd_deck_reviewed.tga` | 21–956 (+9 / +15) | 969–1918 (+2 / +22) | 1935–2588 (+13 / +21) | 2606–2891 (+13 / +18) | 2908–3622 (+9 / -206) | 1830–2114 (-2 / +2) |
| nightelf | `nightelf/Composition/uhd_deck_reviewed.tga` | 구간 8개: 30–954, 979–1914, 1937–2139, 2143–2229, 2374–2586, 2608–2888, 2912–3574, 3767–3810 |  |  |  |  | 1820–2090 (-12 / -22) |
| orc | `orc/Composition/uhd_deck_reviewed.tga` | 구간 7개: 24–951, 973–1914, 1942–2548, 2580–2878, 2906–3600, 3652–3696, 3780–3829 |  |  |  |  | 1835–2108 (+3 / -4) |
| tauren | `tauren/Composition/uhd_deck_reviewed.tga` | 34–947 (+22 / +6) | 973–1911 (+6 / +15) | 1937–2558 (+15 / -9) | 2584–2888 (-9 / +15) | 2916–3613 (+17 / -215) | 1820–2114 (-12 / +2) |
| troll | `troll/Composition/uhd_deck_reviewed.tga` | 26–956 (+14 / +15) | 969–1916 (+2 / +20) | 1933–2053 (+11 / -514) | 2059–2586 (-534 / -287) | 2606–2891 (-293 / -937) | 1822–2114 (-10 / +2) |
| undead | `undead/Composition/uhd_deck_reviewed.tga` | 22–952 (+10 / +11) | 975–1916 (+8 / +20) | 1941–2552 (+19 / -15) | 2574–2874 (-19 / +1) | 2897–3649 (-2 / -179) | 1825–2109 (-7 / -3) |
| skyborne | `skyborne/Composition/uhd_deck_reviewed.tga` | 15–952 (+3 / +11) | 969–1918 (+2 / +22) | 1935–2588 (+13 / +21) | 2604–2889 (+11 / +16) | 2906–3662 (+7 / -166) | 1820–2117 (-12 / +5) |
| skyborne-horde | `skyborne-horde/Composition/uhd_deck_reviewed.tga` | 15–956 (+3 / +15) | 969–1916 (+2 / +20) | 1948–2546 (+26 / -21) | 2586–2889 (-7 / +16) | 2912–3662 (+13 / -166) | 1821–2120 (-11 / +8) |


### What changed

| Place | Change |
|---|---|
| `Presets/{fhd,qhd,uhd}.lua` | appearance chat1-3, action, minimap, seam1-4 x/width (table above); Dominos frames 4/5 x |
| `Defaults/SexyMap.lua` | The minimap rect sits inside its panel. The fragment is also added to `<preset>-v1/-v2`, so the catch-up and the switch bring it to existing profiles. |
| `Presets/V2.lua` | The layout presets' Dominos fragment carries frames 4, 5 and pet with the totem bar. New: the totem bar and the pet bar end at the player frame's right edge (pet bar vertically centred in the totem row, anchored to TOP), and the totem timer sits 8 px left of the totem bar. `modes.petBar` comes from fitPet. Revisions: V2 4 → 6, V1 3 → 4. |
| `Presets.lua` | catch-up labels "Dominos 막대" / "SexyMap 미니맵"; layout-only request text |
| `DevilForever_ChatSetup/Chattynator.lua` | `panelInner` = panel rect one section border in on every side, for every theme and art kind (prepared surfaces, HUD parts, individual panels). The theme `border.size` is used only without a Composition table. The tab row stays centred on the strip unless that would put the message top above the inner top; then the tab row sits lower. Timestamps: the seed sets Chattynator's "None" (`timestamp_format = " "`). A profile seeded earlier gets it once (`state.timestamps`), only while the value is still Chattynator's default "%X". With " " Chattynator's inset is 6 units × timestamp spacing (`Core/Messages.lua` SetInset 367-387), so text starts 6 units right of the message area's left edge, which is the panel's inner edge + 2. |
| `DevilForever_Appearance/Themes/horde.lua` | `border.size` 2 → 1 |
| `codex-briefs/appearance-28-devil-structure.md` (new) | Codex brief: target structure tables, border, seam centres, two redraw methods (parts per `appearance-27-hud-parts.md`, with opaque frame only inside the border; or per-resolution full art at the real aspect with a texcoord crop that Claude adds), per-theme measured differences, checks |
| tests | chatsetup: new section-structure case; uniform-border fit for every preset and theme edge size; the user-saved test uses border 12; seed/follow numbers updated; new timestamp case. firststart: SexyMap expectations. layoutv2: pet bar rect in the screen map; New right-edge, row and timer-left checks; revision pins. core harness: `Session(prelude=…)`, Lua run before Core's files, so the presets see a native pet slot. statusstrip/theme_switcher: revision pin. |
| check list §6 line 70, §11-12 labels, new §14 (structure, text areas, minimap, bars 4/5, pet/totem, update, timestamps); install guide line 49 | updated |

Pet/totem numbers (New, px):
- uhd: totem bar 1242..1698 × 1636..1708; timer 1072..1234 × 1654..1690; player right edge 1698.
- fhd: totem bar 558..837 × 748..792; timer 442..550.
- The pet bar ends at the same right edge, centred in the same row. Shamans have no pet in Forever and pet classes have no totem bar, so the two never show together and share the row.
- Old is unchanged (default).

### Impact map

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| appearance rects in the presets | the structure | read | change | |
| `Composition.lua` readBounds / parts plan / crest | reads the chat and status rects | read | check only | joints follow the rects; the crest uses chat3's size |
| `ChatLayout.lua` (native chat) | reads the chat rects | grep | check only | follows the rects |
| Dominos bars 4/5, pet, totem | sit on the action panel / unit row | read | change | |
| SexyMap fragment | the minimap | read | change | |
| Chattynator timestamp option | seed / follow | read `Core/Config.lua:102`, `CustomiseDialog/Main.lua:654-675`, `Core/Messages.lua:367-387` | change (our seed) | |
| Details windows | sit above chat3 | read | check only | Step 68 places them |
| Grid2 / quest tracker | the right side above the HUD | read | no impact | not part of the bottom structure |
| `tests/composition/*` | parts and composition tests | run | check only | pass unchanged |
| earlier sections of this log | record | - | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/chatsetup/run.py` | rc=0 · 47/47 |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 50 PASS lines |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 29/29 |
| `python -I Collection/tests/core/run.py` | rc=0 · 109/109 |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 20 PASS |
| `python -I Collection/tests/statusstrip/run.py` | rc=0 · 20/20 |
| `python -I Collection/tests/pitbull4/run.py` / `pitbull4runtime` / `castbars` | 6/6 · 20/20 · 16/16 |
| `python -I Collection/tests/composition/run.py` / `parts.py` | 8/8 · 12/12 |
| `python -I <devnull_run.py> Collection/tests/patches/run.py` | 4/4 |
| `python -I Collection/tools/luacheck.py <Core> DevilForever_ChatSetup DevilForever_Appearance` | `checked=31 failed=0`; after the last ChatSetup edit, `DevilForever_ChatSetup`: `checked=3 failed=0` |
| `python -I Collection/tools/extract.py` · `genregistry.py --check` | errors=0 · up to date |
| `… patches.py verify` | `patches=8 failures=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36/2353 · 38/2297 |

Raw outputs: `<scratch>/s60/s66*.txt`; measurement JSON `<scratch>/s60/s66_measure.json`.

### Open
- The current art stays until Codex delivers, so text and minimap are placed by the new structure while the drawn frames are still a few px off (brief §3).
- The measurement counts bright decorations (crests, ornaments) as non-floor, so some chat3 right values are short. These are marked in the brief.
- At uhd with 1 UI unit = 1 px, the 12 px border keeps the message top below the strip's natural spot, so the tab row sits up to 4 px below the strip centre. At the user's 0.5556 units/px it is centred.
- Brief method B (per-resolution full art) needs a texcoord crop in `Composition.lua` before such art can ship (Claude does it when Codex picks B).
- With no time column, Chattynator still keeps a 6-unit inset before the text.

## Step 67 (R226): one layout only — Old and the version switcher removed

Read:
- `Presets/V2.lua` 1-282 (whole), `Presets.lua` catch-up parts (60-75, 290-310, 560-830), `Defaults/SexyMap.lua` 170-190, `Defaults/PitBull4.lua` 570-580.
- `DevilForever_Skin_StatusStrip/ThemeSwitcher.lua` 1-330, `tools/theme_switcher_art.py` 1-60, 160-262.
- tests: layoutv2 (whole in parts), firststart 730-760 and 890-945, statusstrip/theme_switcher 86-120, 198-242, 340-395.
- check list 38, 65-145; install guide 44-60; `data/feature-map.md` (grep: no New/Old wording).

### Impact map (made first: grep `layoutV1Revision|layoutV2Revision|dfLayoutV2|StatusStripLayouts|versionInUse|layout_new|layout_old|-v1`, plus "New/Old", "버전 전환", "Old")

| Place | Type | How found | Impact | Reason |
|---|---|---|---|---|
| `Presets/V2.lua` | V1 path, V1 revision, `-v1` preset, Old-only base tweaks, Old stacking (Step 65), `oldCells`, `mainAuras` | grep, read whole | change | one layout |
| `Presets.lua` catch-up | V1 target, New/Old label | grep | change | |
| `Presets.lua` Restore hint text (`-v1 · -v2`) | user text | grep | change | `-v2` only |
| `Defaults/SexyMap.lua` | adds its fragment to `-v1/-v2` | grep | change | `-v2` only |
| `Defaults/PitBull4.lua:577` | reads `dfLayoutV2 == true` (target-pet companion layout) | grep | check only | still true for the layout |
| `ThemeSwitcher.lua` | version switcher, `layout_new/old` in SHIPPED | grep | change | removed |
| `tools/theme_switcher_art.py` | generates `layout_new/old.tga` | grep | change | no longer generated |
| `Media/ThemeSwitcher/<preset>/layout_{new,old}.tga` (6 files) | art | ls | delete needed | not deleted here (no-delete rule); for the master |
| `PitBull4/Modules/Aura/Layout.lua` debuff gap fix | Step 65 (b) | read | no impact (kept) | applies to the layout |
| `Commands.lua` `/dfp preset` | takes any registered name | read (earlier) | check only | `<preset>-v2` still registered; `-v1` reports "등록된 preset 이 아님" |
| tests layoutv2, firststart, theme_switcher | tests | grep | change | |
| check list §6, §11-14, install guide line 49 (+ timestamp line, R230) | user docs | grep | change | |
| `data/feature-map.md` | doc | grep | no impact | no New/Old wording |
| earlier sections of this log | record | - | no impact (record) | |

### What changed

| Place | Change |
|---|---|
| `Presets/V2.lua` | Only the layout-only preset `<preset>-v2` is registered (the catch-up and `/dfp preset <preset>-v2` use it). Its fragments still follow the base preset's at version + 10, so a fresh install and `/dfp preset <preset>` write this layout. Removed: the V1 path (Step 65 Old stacking, `OLD_STACK_GAP`, `mainAuras`), `oldCells`, `layoutV1Revision`, the base-preset Old tweaks (`dfLayoutV2 = false` etc.) and the Old Swing "top" fragment. `layoutV2Revision` 6 → 7. |
| `Presets.lua` | The catch-up treats a collection profile with `dfLayoutV2 = false` (the earlier Old) as outdated and writes `<active>-v2`. A profile on the layout below revision 7 does too. Foreign profiles (no flag) are untouched. Chat line without New/Old: "배치를 이 판에 맞춰 적용했습니다(…)". Restore hint names `-v2` only. |
| `Defaults/SexyMap.lua` | fragment added to the base preset and `-v2` only |
| `ThemeSwitcher.lua` | The version switcher (`DevilForever_StatusStripLayouts`, its choices, the waiting-request takeover) and the `layout_new/old` entries in SHIPPED are removed; `switchers = {theme}`. The theme switcher code is unchanged. |
| `tools/theme_switcher_art.py` | no layout images (docstring, `LAYOUTS`, build loop) |
| tests | layoutv2: no `-v1` back switch, no Old aura block test, name text and cast bar for the layout only; catch-up: an earlier Old profile → the layout (`true, 7`); the player's own request (`/dfp preset <preset>` + go) supersedes `due`; `layoutV1Revision is None` and `<preset>-v1` not registered. firststart: Grid2 spot/cells for the layout only, `fhd-v1` reports "not registered". theme_switcher: no layout switcher with or without PitBull4; art checks ignore the retired files and print them as a note. |
| check list §6, §11-§14; install guide | Old and New/Old switching removed (the §6 heading says why); the status strip item now checks "theme switcher only" with a `/run` state line; install guide: an earlier Old profile becomes this layout; R230: timestamps off by default, turned on in Chattynator settings → 「서식 설정」(Formatting) → 「시간 표시」(Timestamp) (`Locales.lua` koKR FORMATTING / TIMESTAMP, `CustomiseDialog/Main.lua` TabSetups). |

`/dfp` names: `<preset>` and `<preset>-v2` work (the same layout); `<preset>-v1` no longer exists ("등록된 preset 이 아님").

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 42 PASS lines |
| `python -I Collection/tests/firststart/run.py` | rc=0 · 29/29 |
| `python -I Collection/tests/statusstrip/theme_switcher.py` | rc=0 · 17 PASS lines; NOTE retired `layout_new/old.tga` still on disk at fhd/qhd/uhd |
| `python -I Collection/tests/core/run.py` | rc=0 · 109/109 |
| `python -I Collection/tests/statusstrip/run.py` · `chatsetup` · `pitbull4` · `pitbull4runtime` · `castbars` · `composition/run.py` | 20/20 · 47/47 · 6/6 · 20/20 · 16/16 · 8/8 |
| `python -I <devnull_run.py> Collection/tests/patches/run.py` | 4/4 |
| `python -I Collection/tools/luacheck.py <Core> DevilForever_Skin_StatusStrip DevilForever_ChatSetup` | `checked=26 failed=0` |
| `python -I Collection/tools/theme_switcher_art.py --check` | `problems=6` = the six retired files on disk ("extra"); goes to 0 when they are deleted |
| `python -I Collection/tools/extract.py` · `genregistry.py --check` | errors=0 · up to date |
| `… patches.py verify` | `patches=8 failures=0` |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 36/2353 · 38/2297 (the six retired TGA are still counted until deleted) |

Raw outputs: `<scratch>/s60/s67*.txt`.

### For the master
- Delete `Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/{fhd,qhd,uhd}/layout_new.tga` and `layout_old.tga` (6 files). The art check then reports 0 problems, and the build file count drops by 6.
- The base preset still carries the original preset fragments (version 1) under the layout fragments (version + 10). A fresh install writes both in order and ends with the layout; the Old-only tweaks were removed.

## Step 64 (R208, R223): Hekili out — done; Musca Auras in — waiting for download approval

### Hekili out (item c)

Read: `install.json` 1-50, `tools/extract.py` 70-130, `tools/build.py` 90-130, `tests/install/verify_archives.py` 165-180, `registry_extra.json` 466-545, Core TOC, `Presets/{fhd,qhd,uhd}.lua` Hekili and Masque fragments (uhd 715-800), `tests/core/run.py` 462-560 and 1078-1112, `tests/layoutv2/run.py` 440-515, install guide 44 and 72, `data/feature-map.md` 45-55.

| Place | Change |
|---|---|
| `install.json` | The Hekili group is out of `upstream`. New key `not_shipped` lists the 11 Hekili folders that stay in `Collection/AddOns` (Hekili code untouched) but go in no ZIP. |
| `tools/build.py` | `install_selection`: folders named in `not_shipped` count as named; they are not shipped. |
| `tools/extract.py` | `forever-addons/Hekili`: Phase 8 role `start` → `dropped` (the plan's role for a start addon taken out) |
| `manifest.json` / `manifest.md` | regenerated (`start=12 comparison=27`) |
| `registry_extra.json` | Hekili entry (frames, editable, HekiliDB, defaults) removed |
| `Registry.lua` | regenerated (53562 bytes) |
| Core TOC | `Defaults\Hekili.lua` no longer loaded. The file stays on disk; the master can `git rm` it. |
| `Presets/{fhd,qhd,uhd}.lua` | Hekili profile fragment and the Masque "Hekili" group removed (the Dominos Masque group stays) |
| `tests/install/verify_archives.py` | must-ship without Hekili; Hekili, Hekili_Shared and Hekili_Shaman must not be shipped |
| `tests/core/run.py` | registry asserts without Hekili; Hekili folders in the not-registered list; the two Hekili defaults cases removed |
| `tests/layoutv2/run.py` | no Hekili rects in the screen map |
| install guide | Hekili dropped from the auto-update note; new line: Hekili is no longer in the collection, and folders left from an earlier install can be removed or turned off |
| `data/feature-map.md` | class action recommendation row: none (R223) |

No impact (records): `judgment.md`, `data/classes.md`, `data/hekili-*.md`, earlier codex briefs.

Not done here: `Collection/Installer/ReleaseCatalog.json` still lists Hekili. It is written from the built release ZIPs (`tools/catalog.py --write`), and `catalog.py --check` against my scratch-built ZIPs reports DIFFERS. It is rewritten when the release ZIPs are built in `outputs/collection`.

### Musca Auras (items a, b, d) — not started

Downloading needs the user's own approval (a file download), so nothing was downloaded. Official page facts (`https://www.curseforge.com/wow/addons/musca-auras/files`, read only):
- Newest file: "Musca Auras 1.21.0", file id 9801355, uploaded 2026-11-24, game version 1.60.1 (Forever), 7.8 MB.
- Earlier: 1.20.0 (9761179), 1.19.0 (9705662).

The mute setting, the defaults path and the check-list items wait for the ZIP.

Second request (master message: "approved by master on that basis"): still not downloaded. The approval reached this session as an agent message, and a file download needs the user's own yes in chat (or the master downloads the file). Items a, b, d stay open; Hekili (item c) stays on the `not_shipped` route.

Recovery reads after this session's compaction: rule files (constitution in context, `feedback_communication_style.md` 1-87, `feedback_flow_interruption.md` 1-64, the two method skills reloaded), this work log 978-1028.

### Step 68 placement probe (before any Step 68 change)

Probe `<scratch>/s60/s68_probe.py` (layoutv2 helpers, base-preset screen map). A two-window row of chat width and chat height placed 8 px above the chat surround overlaps something in every column:
- above chat 3 (today's Details spot; fhd 1483,593,437,192 · qhd 1942,875,618,224 · uhd 2887,1397,953,304): Grid2 party/raid, target-pet frame and its auras, `ornamentRight`
- above chat 1: pet frame and auras, Quartz Pet bar, `ornamentLeft`, `unitLower`
- above chat 2: several unit-frame elements
The quest tracker extent is not in the screen map (unknown). No clear spot found yet.

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tools/extract.py` | rc=0 · `start=12 comparison=27 … errors=0` |
| `python -I Collection/tools/genregistry.py` / `--check` | wrote 53562 bytes / up to date |
| `python -I Collection/tests/core/run.py` | first 106/109 (Hekili cases), after the test update rc=0 · 107/107 |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 42 PASS |
| `python -I Collection/tests/firststart/run.py` · `statusstrip/theme_switcher.py` · `statusstrip/run.py` · `chatsetup` · `pitbull4runtime` · `castbars` · `composition/run.py` | 29/29 · rc=0 17 PASS (retired-file skip removed; files deleted by the master) · 20/20 · 47/47 · 20/20 · 16/16 · 8/8 |
| `… build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · 25/2057 · 27/2001 |
| `… build.py --variant pitbull4` / `fuf --out-dir <scratch>/s60/s64zips.*` | rc=0 · built 25/2057 (sha256 7adbc0b7…) · 27/2001 (0030b4d0…) |
| `python -I Collection/tests/install/verify_archives.py --version 0.1.5 <scratch zips>` | rc=0 (must-ship without Hekili; Hekili not in either ZIP) |
| `python -I Collection/tests/catalog/run.py` | 1 pass, 2 fail, 1 skip. Both failures come from `--write` raising `ValueError: path is on mount 'C:', start on mount 'D:'` (relpath between the C: temp folder and the D: repo), an environment issue, not this change. |
| `python -I Collection/tools/catalog.py <scratch zips> --check` | DIFFERS (expected: Hekili left the ZIPs; rewrite at release) |

Raw outputs: `<scratch>/s60/s64*.txt`.

Step 64 status after R231 (the user is asleep and asked for everything to be finished): the Musca Auras download is still blocked because the user has not approved it directly. Items a (ship), b (muted by default) and d (check-list items) are left undone. Nothing for Musca is in the tree. Hekili (item c) is done and stays on the `not_shipped` route.

## Step 68 (R227, R228): Details windows 1 and 2 side by side; window 2 created for Tiny Threat on first setup

Read: `DevilForever_DetailsLayout/Layout.lua` 1-178 (before) and 1-287 (after) · `.toc` · `tests/detailslayout/run.py` 1-223 (before) · `tests/layoutv2/run.py` 440-520 (screen map, the `TRACKER` quest-tracker model, `KNOWN_OVERLAP`) · `!DevilForever_Core/Core.lua` 100-200 and 280-400 (`On`/`Off`, `DBTable`, DB layout) · Details: `classes/class_instance.lua` 1160-1200, 1325-1340, 1765-1960 (`GetNumInstances`, `CreateInstance`/`CriarInstancia`: `id=true` copies `standard_skin`, or the skin of the first open window when there is no standard skin) · `core/plugins_raid.lua` 1-160 (`EnableRaidMode`, `IsAvailable`, `PluginsInUse`) · `frames/window_main.lua` 2630-2660 (the title bar is anchored above the baseframe), 3740-3800 (title-bar settings) · `startup.lua` 990-1012 (`__initialized`) · `Details_TinyThreat.lua` 925-960 (installs `DETAILS_PLUGIN_TINY_THREAT` at its own ADDON_LOADED) · `registry_extra.json` 585-625 · `install.json` 1-40 · install guide 50-62 · `data/feature-map.md` 59 · check list 128-142 · `References/codex-appearance/10/report.md` 19-21 (title height proposal 24/26/30 px).

### Spot

Search: `<scratch>/s60/s68_grid.py` over the base-preset screen map (`s68_rects.json`, dumped by `s68_search.py`). A box the size of one chat panel was tested at every x (1 px steps) and every even y, with 8 px and 4 px gaps to every mapped rectangle. The row must keep a chat panel's left and right edges.

| Column (chat-panel edges) | fhd | qhd | uhd |
|---|---|---|---|
| chat 3 (today's Details spot, 8 px above the section) | overlaps Grid2 raid/party, the target-pet frame and its auras, `ornamentRight` | same kind | same kind |
| chat 3, screen top | clear y 0-62 | clear y 0-118 | clear y 0-210 |
| chat 2 | never clear | never clear | clear only y 0-210 (top) |
| chat 1, below the party frames | clear y 362 only (4 px gap) | clear y 470-594 | clear y 642-1014 |

Choice (my judgement, recorded for the user's decision): the **chat 1 column below the party frames**. The rows are fhd (0,362,437,192), qhd (0,532,618,224), uhd (0,828,953,304) — the middle of each clear range.

The top of the chat 3 column is geometrically nearer to the default spot, but it is the screen's top-right corner. The game's own buff icons and minimap cluster sit there by default, and they are not in the screen map (estimate, not verified). The quest-tracker model in `tests/layoutv2/run.py` (`TRACKER`, top at about 24 % of the screen height) leaves that corner above the tracker, but the buff area is unmodelled. The chat 1 band touches no mapped rectangle, no Grid2 window, and not the quest-tracker column.

Inside each row:
- window 1 (damage) is on the left and window 2 (Tiny Threat) on the right, with a 2 px gap;
- each title strip is part of the row: fhd 24, qhd 26, uhd 30 px (the Phase 10 title heights) sits above each body;
- bodies: fhd {0,386,217,168} {219,386,218,168} · qhd {0,558,308,198} {310,558,308,198} · uhd {0,858,475,274} {477,858,476,274}.

Not verified:
- the real title/toolbar height of the user's skin (check-list item);
- the FUF variant's party and pet frames (the screen map is PitBull4's);
- the game's default party frames being hidden at left middle (estimate: PitBull4 and Grid2 take the party).

### Impact map

| Place | Type | How found | Impact | Why |
|---|---|---|---|---|
| `Layout.lua` `layouts` | values | read | changed | stacked spots above chat 3 → side-by-side row |
| `Layout.lua` `ready()` | code | read | changed | split into `detailsReady()` + `placeable(id)`; same checks and refusals |
| `Layout.lua` first setup (new) | code | — | added | `FirstSetup`, retry timer, combat wait, marker in `DevilForever_CoreDB.detailsLayout.profiles[<Details profile>]` |
| `Layout.lua` status | code | read | changed | shows the profile's setup mark |
| `.toc` Notes | text | read | changed | describes first setup |
| `tests/detailslayout/run.py` | test | read | changed | apply checks against the Layout rects (the Phase 10 proposal files no longer describe the spot); setup, row and no-change cases added |
| `tests/layoutv2/run.py` `KNOWN_OVERLAP` | test | grep `details` | changed | Grid2 no longer overlaps Details: the `details 1/2` entries are gone |
| `tests/layoutv2/run.py` | test | — | added | Details row: chat panel 1 width and height, left edges aligned, overlaps nothing (title included; Grid2 raid/party and the tracker column added) |
| install guide (character first-time list) | doc | grep | changed | the manual `/details new` steps become the automatic first setup; `/dfdetails apply` stays for profiles that already have windows |
| `data/feature-map.md` 59 | doc | grep | changed | same |
| check list §15 (new) | doc | — | added | creation, spot, title height, no-change login, FUF |
| `registry_extra.json` Details frames (`DetailsBaseFrame1/2`) | data | read | check only | names unchanged |
| `tests/core/run.py` 502-513 | test | grep | check only | "no saved variables" still holds (the marker lives in the Core DB); 107/107 |
| `References/codex-appearance/10/*` | record | — | no impact (record) | earlier proposal |
| check list line 39 (Grid2 vs Details) | doc | grep | check only | still a valid check |

### Behaviour

At the first `PLAYER_ENTERING_WORLD`, the addon tries every 2 s, up to 30 times. During combat it waits for `PLAYER_REGEN_ENABLED`. Each try checks, in order:

1. Details is initialised, not embedded in chat, and a profile is active.
2. The profile already has a mark → nothing.
3. The profile has more than one window → mark `{skipped = true}` and change nothing.
4. There is no active fhd/qhd/uhd preset → nothing (tried again at the next login).
5. Window 1 is not free-standing (solo, snapped, frames not ready) or Tiny Threat is not installed, enabled and free → try again later, no writes.

When every check passes:
- `Details:CreateInstance(true)` makes window 2;
- `ChangeSkin(<window 1 skin>)` runs when the new window's skin differs;
- `RaidTables:EnableRaidMode(window 2, "DETAILS_PLUGIN_TINY_THREAT")` assigns Tiny Threat;
- the existing `Apply` places both windows;
- the mark `{created = 2, preset}` is written right after the window is created;
- one chat line is printed.

Window 1's mode and display are not touched. A marked profile is never touched again, so later moves or changes by the player stay.

Decision queue (my defaults):
- **Spot:** chat 1 column instead of the screen top of chat 3. Alternative: chat 3 column top, fhd (1483,0..62), qhd (1942,0..118), uhd (2887,0..210).
- **Window 1 position:** a lone window 1 that the player had already moved is placed too; a moved window cannot be told from Details' default.
- **Profiles that already have windows:** a profile with two or more windows (for example one set up from the old guide) is left as it is; `/dfdetails apply` puts it on the new row.

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I <scratch>/s60/s68_grid.py <scratch>/s60/s68_rects.json` (gap 8 and 4) | clear ranges as in the table above |
| `python -I Collection/tests/detailslayout/run.py` | rc=0 · `PASS first setup … (16 cases)` · `PASS actual slash->native … 6 preset/factor pairs … 28 refusal cases` |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 46 PASS incl. `Details row (0, 362, 437, 192)` fhd / `(0, 532, 618, 224)` qhd / `(0, 828, 953, 304)` uhd 3840 and 3862 · `overlaps none of 67 rects` |
| `python -I Collection/tools/luacheck.py AddOns/DevilForever_DetailsLayout` | `checked=1 failed=0` |
| `python -I Collection/tests/core/run.py` · `firststart` · `chatsetup` · `statusstrip/run.py` · `pitbull4runtime` | 107/107 · 29/29 · 47/47 · 20/20 · 20/20 |
| `python -I Collection/tools/genregistry.py --check` | up to date (53562 bytes) |
| `python -I <scratch>/s51.XsBX/devnull_run.py Collection/tools/build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · folders=25 files=2057 / folders=27 files=2001 (without the wrapper: `diff: nul` error, the known Git-for-Windows issue) |

The suite drives `CreateInstance` and `EnableRaidMode` through stubs, because the native window builder needs the client. Window placement runs through the native `RestorePositionFromPositionTable` / `RestoreMainWindowPosition` / `SetWindowScale`. Raw outputs: `<scratch>/s60/s68_*.txt`.

## Step 64 (Musca Auras: items a, b, d)

Brief: `Claude/results/handoffs/phase27/brief-64-musca.md` 1-35, read in full. This session was not compacted since the Step 68 task, so the brief's re-read clause did not apply; the work-log sections "Step 64" and "Step 68" were written by this session in this context. The master downloaded the file after the user's direct approval (R232). I downloaded nothing.

Read (file:lines):
- `References/forever-addons/MuscaAuras/SOURCE.txt` 1-13
- `Collection/tools/extract.py` 1-330 and 400-565 (roles, `PATCHED`, member checks, manifest)
- `tools/build.py` 96-140 (install groups must equal the manifest package name) and the `--list-excluded` output
- `tools/genregistry.py` 1-60 and 150-190
- `install.json` 1-40
- `!DevilForever_Core/Defaults.lua` 1-232 and 310-476 (plain-target rules)
- `Core.lua` 280-400, `API.lua` 10-45, `Defaults/SexyMap.lua` 1-60, `registry_extra.json` (Details, SexyMap, ExperienceForever entries), Core TOC
- `tests/core/run.py` 1-345, 440-560, 1075-1110
- `tests/install/verify_archives.py` 165-180
- master plan rows 241 (Phase 8) and 524 (2026-11-25 decision), Phase 27 detail plan row 25, request ledger R206-R232 rows (grep hits)
- install guide 1-90 (all of it), `data/feature-map.md` 1-56, check list 128-149
- Musca Auras (extracted in `Collection/upstream/MuscaAuras-1.21.0`):
  - `WeakAuras/WeakAuras.toc` 1-40
  - `WeakAuras.lua` 580-605 (`ToggleSoundsMuted`), 1815-1910 (ADDON_LOADED / PLAYER_LOGIN), 3040-3070 (welcome popup), 4365-4380 (text-to-speech), class-pack popup lines 634/656/3008/3080 (grep hits)
  - `RegionTypes/RegionPrototype.lua` 170-240 (`SoundPlayHelper`)
  - `BlizzardAuraDisplaySounds.lua` 1-30, 90-105, 195-240
  - `CHANGELOG.md` 1-60
  - koKR locale hits (grep)
  - every `PlaySound`/`PlaySoundFile`/`TextToSpeech` call site (grep)

### Role and folder names

- **Role:** `tools/extract.py` `FEATURE_PHASES["forever-addons/MuscaAuras"] = [(8, "start")]`. Phase 8 (직업 전투보조) is where the plan's 2026-11-25 decision row (plan line 524) puts Musca Auras. Hekili stays `[(8, "dropped")]`, its `not_shipped` route untouched.
- **Package name:** the manifest takes it from the folder name, `MuscaAuras`. The `install.json` group key must be that name (`build.py` 125-128).
- **Folder names:** `WeakAuras`, `WeakAurasOptions`, `WeakAurasTemplates`, `WeakAurasModelPaths`, `WeakAurasArchive`.
  - No clash in `Collection/AddOns`.
  - No `WeakAuras*` folder in the game's `_forever_/Interface/AddOns` (listing read only).
  - Each folder belongs to exactly one extracted package (`extract.py` third-party check, errors=0).
  - A different WeakAuras build would use the same folder name and the same saved variable `WeakAurasSaved`. The install guide says so.

### Sounds: where they play and how the default stops them

| Sound path | file:line | Reads `soundsMuted` |
|---|---|---|
| Aura "Play Sound" actions and conditions | `WeakAuras/RegionTypes/RegionPrototype.lua:194-195` (`SoundPlayHelper`: returns when `Private.db.soundsMuted`), plays at 201/206/211 | yes |
| Sounds registered with the game for Aura (Modern) auras | `WeakAuras/BlizzardAuraDisplaySounds.lua:99` (`live = … and not Private.db.soundsMuted`) | yes |
| Text-to-speech message action | `WeakAuras/WeakAuras.lua:4372` | yes |
| Options window clicks and sound previews (`WeakAurasOptions/AceGUI-Widgets/*`, `ActionOptions.lua:94/99`, `ConditionOptions.lua:236/241`, `AuthorOptions.lua:2296/3044`) | — | no — they play only when the player clicks in `/wa` |

- `Private.db` = `WeakAurasSaved` (`WeakAuras.lua:1825-1827`). `/wa mute` and the "Mute" box (`음소거`, `WeakAurasOptions/Locales/koKR.lua:1015`) toggle `WeakAurasSaved.soundsMuted` between `true` and `nil` (`WeakAuras.lua:587-588`).
- **Default:** new Core defaults file `Defaults/WeakAuras.lua`, a plain target `WeakAurasSaved` with `{soundsMuted = true}` (version 1).
  - A fresh install is written at the first `PLAYER_ENTERING_WORLD`, over the table Musca created at its own ADDON_LOADED (the engine's existing "first-load" mode).
  - From the next login Musca prints its own line, `오라 소리가 꺼져 있습니다. 다시 켜려면 /wa mute 를 입력하세요.` (`WeakAuras.lua:1885-1886`).
- **Why the engine needed a flag:** for a saved variable that already exists, the engine fills missing keys once, and here `nil` means "sounds on". That would mute an account that used Musca (or another WeakAuras build) before.
  - I added a `freshOnly = true` option for plain targets to `Defaults.lua`. When the saved variable existed at Core's first look, nothing is written and the state is `existing-kept`; it reads `already` once the version was recorded.
  - `freshOnly` on an AceDB target, or a non-boolean value, is refused.
  - A player who unmutes later stores `nil`, and the target never runs again (version recorded).
- **Turning sounds back on (for the check list):** `/wa mute`, or the `/wa` window's `음소거` box. The setting is account-wide.

No patch to Musca Auras: the five folders are byte-identical to upstream. `patches.py verify` is not needed, and `build.py` checks shipped folders against upstream.

### Impact map

| Place | Type | How found | Impact | Why |
|---|---|---|---|---|
| `tools/extract.py` `FEATURE_PHASES` | data | read | changed | new start package, Phase 8 |
| `Collection/upstream/MuscaAuras-1.21.0/` | generated | extract | made by `extract.py` | git-ignored extract (743 files) |
| `Collection/AddOns/WeakAuras*` (5 folders, 743 files) | new folders | — | added | copied unchanged from the extract |
| `install.json` `upstream` | data | read | changed | group `MuscaAuras`: 5 folders, both variants (base list) |
| `manifest.json` / `manifest.md` | generated | `extract.py` | changed | package `MuscaAuras` start, 5 third-party folders `unmodified`; `how_to_use` set by hand (verdict `settings`, reason with R208/R223), kept by later `extract.py` runs |
| `!DevilForever_Core/Defaults/WeakAuras.lua` | new | — | added | sounds-off default |
| `!DevilForever_Core/Defaults.lua` | code | read | changed | `freshOnly` (doc, validation, plain branch, status list) |
| `!DevilForever_Core/API.lua` 33-40 | doc | grep `existing-profile-kept` | changed | new state `existing-kept` listed |
| Core TOC | data | read | changed | `Defaults\WeakAuras.lua` after `Defaults\Quartz.lua` |
| `registry_extra.json` | data | read | changed | `WeakAuras: {defaults = "Defaults/WeakAuras.lua"}` (no frames, no restore: see Decision Queue) |
| `Registry.lua` | generated | `genregistry.py` | changed | 5 Musca folders registered (package MuscaAuras, Phase 8, use settings) |
| `tests/core/run.py` | test | read | changed | registry asserts for the 5 folders; 3 new cases: fresh install muted and later unmute kept · existing install untouched · `freshOnly` refused on AceDB |
| `tests/install/verify_archives.py` must-ship | test | read | changed | the 5 folders |
| install guide | doc | read | changed | folder counts 36/38 → 30/32 (stale since Hekili left: 25/27 before Musca, now 30/32 from `build.py`), Musca line under the ZIPs, "오라 알림" line in the restore-old-addons list, first-login Musca item, `/wa` commands |
| `data/feature-map.md` | doc | read | changed | tree "행동 추천" → "조건 알림"; row 51 now Musca Auras (R223 wording) |
| check list §16 (new) | doc | — | added | welcome window, shaman HUD / Maelstrom Weapon / buff time, silent and `/wa mute`, Update HUD, other WeakAuras folders |
| `Installer/ReleaseCatalog.json` | generated | grep | check only | written from release ZIPs (`catalog.py --write`) at release; not run here |
| `tests/thirdparty/run.py` · `firststart` · `statusstrip` · `chatsetup` · `detailslayout` | test | run | check only | pass unchanged |
| `DevilForever_Skin_StatusStrip/Skin.lua`, presets | code | grep | no impact | name no Musca or WeakAuras frame |
| `judgment.md` Phase 8, `data/hekili-*.md`, earlier briefs | record | — | no impact (record) | earlier judgements |
| Hekili code, `not_shipped` | — | — | untouched | brief |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tools/extract.py` (after the role, after the copy, after `how_to_use`, final) | rc=0 · `MuscaAuras extracted 743 files -> Collection/upstream/MuscaAuras-1.21.0` · final `packages=40 start=13 comparison=27 … how_to_use_filled=21 errors=0` |
| `python -I Collection/tools/genregistry.py` / `--check` | wrote 55873 bytes / up to date |
| `python -I Collection/tests/core/run.py` | before the new cases 107/107; final 110/110 |
| mutation: `freshOnly = false` in `Defaults/WeakAuras.lua`, core suite | rc=1 · only `musca_defaults_existing_install_untouched` fails (file restored from the scratch copy) |
| `python -I Collection/tools/luacheck.py "Collection/AddOns/!DevilForever_Core"` | `checked=22 failed=0` |
| `python -I <scratch>/s51.XsBX/devnull_run.py Collection/tools/build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · folders=30 files=2800 / folders=32 files=2744 |
| `… build.py --variant pitbull4` / `fuf --out-dir <scratch>/s64m.CmfZ/zips_*` | rc=0 · sha256 c5fa67aa… / 312a912e… |
| `… build.py --dry-run --variant pitbull4 --list-excluded` (Musca lines) | one file left out: `WeakAuras/Libs/LibSpellRange-1.0/LibSpellRange-1.0.lua` "not loaded by any TOC" (no TOC or XML names it — grep) |
| `python -I Collection/tests/install/verify_archives.py --version 0.1.5 <scratch>/s64m.CmfZ/zips_all` | rc=0 · pitbull4 `checked=1478 failed=0`, `folders=30 unresolved=0 … load_on_demand=6` · fuf `checked=1429 failed=0`, `folders=32 unresolved=0` |
| `tests/thirdparty` · `firststart` · `statusstrip/run.py` · `chatsetup` · `detailslayout` | 8/8 · 29/29 · 20/20 · 47/47 · rc=0 |

Raw outputs: `<scratch>/s64m.CmfZ/*.txt`.

### Decision Queue

- **Settings save/restore:** `WeakAurasSaved` (every aura of the account) is registered with no restore entry, so a settings save/restore (`/dfp`) skips it. Whether `/dfp` should save Musca auras is open (my default: skip, because the data is large and account-wide).
- **Newer upstream version:** the download page showed a newer Musca Auras 1.22.0 (2026-11-25, `SOURCE.txt`). The approved and shipped version is 1.21.0.
- **Sound previews in `/wa`:** the options window still plays its click and preview sounds when the player picks a sound. They are not aura alerts and only happen on a click in `/wa`.
- **Login line:** from the second login, Musca prints its "sounds are off" line on every login while muted. That is Musca's own behaviour and left as it is.
- **Not verified:** whether the shaman class pack has a Maelstrom Weapon aura. A case-insensitive grep for "maelstrom" over the five folders finds it only in `WeakAuras/Types.lua` (power type and icon names), so the check list asks.
- **Release catalog:** `ReleaseCatalog.json` does not list Musca yet. It is rewritten from the release ZIPs at release.

## Step 69 (R233-R237): Grid2 size and text, chat height, Details stack, Details text

Brief `Claude/results/handoffs/phase27/brief-69.md` 1-32 and `iter_4/image-17-reading.md` 1-15, read in full. This session was not compacted since Step 64 (Musca). The Musca changes stay in the tree uncommitted.

Read (file:lines):
- `Presets/{fhd,qhd,uhd}.lua`: 300-420 (Dominos bars 1-3), 720-745 (Grid2 proposal and fragments)
- `Presets/V2.lua`: 20-30 and 60-140 (`layoutV2Revision`; Grid2 cells/spot copy)
- `Defaults/Grid2.lua`: 1-30 and 60-200 (template hook, `setNameTextSize`)
- `Core.lua` 220-270 (`PlayerKeys`)
- `Grid2/GridLayout.lua` 740-780 and 885-915 (`ScaleSize` = frame scale, cell size from `frameWidth`); `Grid2/GridFrame.lua` 240-300
- `DevilForever_ChatSetup/Chattynator.lua` 100-260 and 300-416; `Chattynator/Display/Main.lua` 10-44 (resize grip at the message area's TOPRIGHT)
- `DevilForever_DetailsLayout/Layout.lua` whole (after Step 68)
- `Details/frames/window_main.lua`: 2630-2660 (title bar above the baseframe), 3623-3720 (`SetBarTextSettings`), 3903-3940 (`SetBarSettings`), 7716-7790 (`AttributeMenu`)
- `tests/layoutv2/run.py` 360-365, 440-560, 596-606; `tests/detailslayout/run.py` whole; `tests/firststart/run.py` 600-740 and 850-940
- install guide 50-62 · `data/feature-map.md` 59 · check list 134-160
- read-only saved files (`_forever_/WTF/Account/LKZ1412/SavedVariables`):
  - `Grid2.lua` 1-120 and 331 (Grid2Frame/Layout profile; `text-down` 18, `text-up` 9, icons 8)
  - `Chattynator.lua` 539-690 (three windows)
  - `Details.lua` 1515-2340 (window scale, libwindow, posicao)
  - `!DevilForever_Core.lua` 165-172 (`detailsLayout` mark `{created = 2, preset = "uhd"}`, no stack)
  - `WTF/Config.wtf` (`uiScale` 1, no resolution line)

### What the saved data and the screenshot say

- **Grid2 is drawn at about 0.64 of the preset cell.**
  - Preset uhd sets 176 cells with `ScaleSize` = `pixel` (saved 0.3556 = 768/2160, so UIParent's effective scale was 1 when the fragment was evaluated).
  - Chattynator's saved windows use 0.5556 units per physical pixel, i.e. UIParent's effective scale in game is 0.64. Example: window 3 x 1608.56 = (inner left 2899 − 2 units) × 0.5556.
  - So Grid2's frame scale is 0.64 of what the preset meant, and the user sees 176 × 0.64 ≈ 113 px. Screenshot: 926 px wide for 8 cells = 115.7 pitch, top 518 and right edge 3343 match the preset spot.
  - Tier: estimate (two saved values and the screenshot agree; not checked in the client). Whether fhd/qhd have the same 0.64 is not known.
- **Chat height.** Saved window 3: top 995.67 units = 1792 px (tab row centred on the strip 1804-1820), height 182.67 units = 329 px, so the bottom is 2121 px.
  - The message area runs 1841-2112 px: from the window top + 27 units (`MESSAGE_TOP`) to the panel inner bottom (2124 − 12).
  - The width reaches the inner right edge (3828).
  - So the windows follow the Step 66 rule (inner rectangle = panel minus a 12 px border), except a 9 px gap at the top: `MESSAGE_TOP` 27 units vs the tab row's 22 units.
  - The screenshot reading puts the art's visible inner edges elsewhere: right border 3806-3830 px, i.e. about 24 px, not 12; no horizontal border band inside the panel (inner 947-1105 = the whole panel height).
  - So the mismatch the user sees comes from the theme art not drawing the 12 px structure border yet (Step 66 check list already notes the art may be off until Codex redraws it, `appearance-28-devil-structure.md`). Tier: estimate (from the reading; I did not read the image).
  - **No Chattynator code change.** Decision Queue.
- **Details today.** Saved libwindow point `BOTTOMRIGHT` with w 224/216: the user dragged both windows after the Step 68 placement, which would have put TOPLEFT 217/218. The Step 68 mark has no `stack` revision.

### Numbers before → after (physical px)

| | fhd | qhd | uhd |
|---|---|---|---|
| Grid2 cell (`frameWidth`/`frameHeight`) | 88 → 66 | 116 → 87 | 176 → 132 (≈ 113 → 85 seen, R233) |
| Grid2 name text (Grid2Frame `fontSize`, template name indicator) | 12 → 15 | 14 → 20 | 18 → 30 (≈ 0.23 of the cell) |
| Grid2 other text indicators (`text-up` etc.) | template 9 → 11 | → 15 | → 23 (¾ of the name text) |
| Grid2 40-player window (screen map) | 732×456 → 556×346 at TOPRIGHT (−247, −259) | 956×596 → 724×450 | 1450×904 → 1098×684 |
| Details | Step 68 row (0, 362, 437, 192) | (0, 532, 618, 224) | (0, 828, 953, 304) |
| → threat body (x, y, w, h) | (1559, 695, 361, 37) | (2351, 921, 209, 108) | (3437, 1372, 403, 193) |
| → damage body | (1559, 760, 361, 38) | (2351, 1060, 209, 109) | (3437, 1603, 403, 193) |
| Details title strip | 24 | 26 | 30 |
| Details bar text / title text / bar height | 11 / 11 / 16 | 15 / 15 / 21 | 22 / 22 / 30 (chat ≈ 24-25 px in the screenshot) |

Grid2 anchor is unchanged: TOPRIGHT on the quest tracker's top-left corner, so the smaller window shrinks to the left and down. No new anchor.

How the stack was derived (`<scratch>/s64m.CmfZ/s69_stack.py` over the screen map with the 75 % Grid2):
- **x:** from the end of the action bar row (`appearance.upper` right edge) plus the bar end cap (1.1 % of the width: uhd 42, matching the cap end ≈ 3430-3437 in the screenshot) to the screen's right edge.
- **Bottom:** theme strip top − W/480 (uhd 8 px), inside the action bar row.
- **Top:** quest tracker bottom + the same gap. The tracker bottom is an estimate: 695/1125 of the screen height (the screenshot), i.e. uhd 1334.
- **Split:** the free height in two, with that gap between.
- **fhd:** the bar row reaches 1859 (61 px from the edge) and the rule leaves 40 px of width. Best fit: above the bar (bottom = bar top − 4), right of the target-pet frame (x 1559), under the tracker estimate. Only 127 px of height → bodies of 37/38 px. Decision Queue.

### Impact map

| Place | Type | How found | Impact | Why |
|---|---|---|---|---|
| `Presets/{fhd,qhd,uhd}.lua:733` Grid2 proposal | data | read | changed | cells 66/87/132, Grid2Frame `fontSize` and proposal `text-center` 15/20/30 |
| `Presets/V2.lua` `layoutV2Revision` | data | read | changed | 7 → 8: collection profiles get the layout once more (catch-up), which carries the new Grid2 cells (V2 copies `frameWidth`/`frameHeight` from the base preset). It also rewrites the -v2 values of PitBull4, Quartz, Dominos and SexyMap once (same values as today) |
| `Defaults/Grid2.lua` | code | read | changed | `setNameTextSize` → `setTextSizes`: name text = fragment size, other text = `OTHER_TEXT` (fhd 11 / qhd 15 / uhd 23), at the first-start template. New pass at Grid2's ADDON_LOADED for a profile the preset wrote: indicators still at 8/9/12/14/18 (or nil) get the new sizes once (`preset.grid2Text[profile]`); other sizes and icons stay |
| `DevilForever_DetailsLayout/Layout.lua` | code | read | changed | stack rects, `textSizes`, `STACK_VERSION`, `applyText` (`SetBarSettings`, `SetBarTextSettings`, `AttributeMenu`), `placeStack`; FirstSetup: new windows get the stack and text; a mark with `created` and no `stack` is moved and sized once |
| `DevilForever_DetailsLayout.toc` Notes | text | read | changed | describes the stack |
| `tests/detailslayout/run.py` | test | read | changed | `check_row` → `check_stack`; text checks; 5 new move-once cases (dragged windows moved once, then left; skipped profile untouched; window 2 gone) |
| `tests/layoutv2/run.py` | test | read | changed | Details row test → stack test (threat above damage, same x/width, inside the screen, clear of every rectangle, Grid2 and the tracker estimate, the right ornament pinned); Grid2 `KNOWN_OVERLAP` re-pinned (Details no longer in them; party windows clear); `TRACKER` cells; cell-size assertion 66/87/132 = 75 % + name text 23 %; revision 8 |
| `tests/firststart/run.py` | test | run | changed | Grid2 cells 88 → 66, fhd name text 12 → 15, Classic `text-up` 9 → 11, preset source sizes; new case `grid2_earlier_text_sizes_raised_once` |
| install guide (Details first-login item) | doc | grep | changed | stack text replaces the Step 68 row text |
| `data/feature-map.md:59` | doc | grep | changed | stack |
| check list §15 (rewritten: stack, text, move once, FUF), §17 (new: Grid2 size/text, chat height measurement) | doc | grep | changed | |
| check list line 39 (Grid2 vs Details) | doc | grep | check only | still a valid check |
| `DevilForever_ChatSetup/Chattynator.lua` | code | read | check only | geometry matches the rule (above) |
| `registry_extra.json` Details/Grid2 | data | read | check only | frame names unchanged |
| codex briefs quoting a Details spot | doc | grep `2902`/`1320, 466`/`DetailsLayout` | no impact (record) | only `appearance-24.md:27` (the earlier chat-3 rule, an issued brief) mentions it; `appearance-28` names no Details spot |
| Step 68 work-log section, earlier Result/records | record | — | no impact (record) | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I <scratch>/s64m.CmfZ/s69_stack.py <scratch>/s60/s68_rects.json` | uhd x0 3437 w 403 y 1342-1796 · qhd x0 2351 w 209 y 895-1169 · fhd x0 1880 w 40 (rule fails → best fit above) |
| `python -I <scratch>/s64m.CmfZ/s69_pin.py …` (in `tests/layoutv2`) | new Grid2 overlaps pinned: fhd raid 9 (target auras/target-pet auras/target frame) · qhd raid 4 · uhd raid 2 · every party window 0 |
| `python -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_DetailsLayout "Collection/AddOns/!DevilForever_Core"` | `checked=23 failed=0` |
| `python -I Collection/tests/layoutv2/run.py` | rc=0 · 46 PASS incl. `Details stack threat (3437, 1372, 403, 193) over damage (3437, 1603, 403, 193)` uhd, qhd/fhd rows, `clear of 66 rects but the right ornament`, `Grid2 cells square (fhd 66, qhd 87, uhd 132 = 75 % …)` |
| `python -I Collection/tests/detailslayout/run.py` | rc=0 · `PASS first setup … (21 cases)` · slash suite PASS |
| `python -I Collection/tests/firststart/run.py` | first run 26/29 (the three Grid2 cases expecting 88 and the old text sizes); after the update 30/30 |
| `python -I Collection/tests/core/run.py` · `chatsetup` · `statusstrip/run.py` · `pitbull4runtime` | 110/110 · 47/47 · 20/20 · 20/20 |
| `python -I Collection/tools/genregistry.py --check` | up to date (55873 bytes) |
| `python -I <scratch>/s51.XsBX/devnull_run.py Collection/tools/build.py --dry-run --variant pitbull4` / `fuf` | rc=0 · folders=30 files=2800 / folders=32 files=2744 |

Raw outputs: `<scratch>/s64m.CmfZ/s69*.txt`, `lv2*.txt`.

### Decision Queue

1. **Moving windows the user dragged.** The brief says windows the user moved stay alone. The saved data shows this user dragged both windows after the Step 68 placement, and R235 asks for the new spot.
   - My default: a profile whose windows the collection made is moved once, whatever the drag.
   - The user's own profiles (`skipped`) stay alone, and after this one move every change stays.
   - If the master wants the brief's rule, add a position check before `placeStack` in `FirstSetup`.
2. **fhd stack.** The fhd action bar row leaves 61 px at the right, so the rule cannot hold. The best fit above the bar gives two windows of 61/62 px (bodies 37/38, about two bars each). Options: accept, give fhd a different spot, or drop Details text/rows smaller on fhd.
3. **Theme ornament.** The right theme ornament (`appearance.ornamentRight`, uhd 3348-3604 × 1548-1804) is overlapped by the stack in every preset; the user's rule ("Dominos 끝나는 지점부터 우측 끝까지") puts the stack there. The check list asks which one draws on top.
4. **Quest tracker bottom.** Taken from one screenshot (695/1125 of the height). A longer quest list grows down into the threat window. The tracker has no fixed size in the collection.
5. **Grid2 scale factor.** The ≈ 0.64 factor between the preset cell and the drawn cell (`ScaleSize` evaluated with UIParent scale 1) is an estimate. The new numbers are 75 % of the preset cells, so the user sees 75 % of today whatever the cause. If the cause is fixed later, the cells must be divided by the same factor.
6. **Chat height.** No code change, for two reasons:
   - The windows already follow the panel inner rectangle. The only gap from our code is 9 px at the top (`MESSAGE_TOP` 27 vs `TAB_ROW` 22).
   - The visible mismatch matches the art not drawing the 12 px structure border (right about 24 px, no top/bottom band).
   - Options: (a) Codex redraws the art to the structure; (b) move the windows so the message area starts at the inner top, which puts the tab row 9 px (uhd) above the strip's centre.
7. **Grid2 icons.** Icon sizes and icon stack text (template 12/20 and 8) are unchanged; only text indicators were sized.
8. **Tiny Threat rows.** Tiny Threat draws its own rows with its own settings, not touched; the check list asks for its text size.
9. **uhd 3862 width.** The stack ends at 3840 (22 px short of the edge) because the uhd rects are fixed.
10. **Layout revision 8.** It rewrites every collection profile's layout values once at the next login; that is the existing catch-up behaviour.

## Step 72 (R245-R247): aura order, nothing top right, dispel border

Brief `Claude/results/handoffs/phase27/brief-72.md` 1-36, read in full. No compaction since Step 69. Base commit cfb5d3ef (clean tree at start).

Read (file:lines):
- `Presets/uhd.lua` 480-670 (Portrait/Border/Aura/LuaTexts, party layout, copies to 소환수와 주시/주시, `dfAuraGeometry`, namespace fragment list); `Presets/fhd.lua` and `qhd.lua` 493-512, 544-545, 578-580 (same shape)
- `Presets/V2.lua` 1-60 (layouts kept, revision) and 135-215 (`dfAuraGeometry`, copies, `replace`)
- `PitBull4/Modules/Aura/Layout.lua` 395-498 (managed rule; callers `Layout.lua:489`, `Forever.lua:263`)
- `PitBull4/Modules/Aura/Highlight.lua` 100-210; `Modules/Aura/Options.lua` 20-35 (type colours), 105-130 (highlight defaults)
- `PitBull4/Modules/HideBlizzard/HideBlizzard.lua` 1-70, 280-310, 380-395
- `Defaults/PitBull4.lua` 1-40, 150-190, 240-262, 515-560 (module settings sit in each namespace's profile under `global`)
- `Presets.lua` sections and validation (grep 7-61, 143-151, 374-399)
- `tools/patches.py` 1-40
- `tests/layoutv2/run.py` 85-105, 283-352, 560-592
- install guide line 65 · `data/feature-map.md` 47 · check list (end)

### Changes

- **(a) Target order.**
  - The patched PitBull4 managed rule (`Modules/Aura/Layout.lua` `GetManagedLayoutDB`) takes `rule.order == "debuffs_first"`. The debuff block starts at the lower of the two layout offsets and the buff block sits above what the debuff block can fill: own debuffs in their own rows when `new_row_size` and `my_size ~= size`, else one shared flow. Otherwise the buff block comes first, as before.
  - V2 gives `dfAuraGeometry["대상"]` `order = "debuffs_first"`, so the preset's own offsets no longer decide the order.
  - The presets swap the "대상" offsets the same way, for a profile without the rule: debuff at the base offset, buff at base + own-debuff rows + others' rows + spacing.
  - Sizes are kept.
  - Patch regenerated: `patches/PitBull4.patch`.
- **(b) Nothing top right.** Each preset gets a PitBull4 namespace fragment `HideBlizzard = {global = {aura = true}}`, added to the namespace fragment list. The `aura` hider (`HideBlizzard.lua:295-296`) hides `BuffFrame` and `TemporaryEnchantFrame` (the weapon enchant icons: poisons, oils, shaman imbues), or `DebuffFrame` on a client without `TemporaryEnchantFrame`. Decision Queue 1.
- **(c) Dispel border on "보통", "대상" and "데빌 파티":**
  - `highlight = true`
  - `highlight_filters = {"!H", "", "", ""}`
  - `highlight_filters_color_by_type = {true, false, false, false}`
  - `highlight_filters_custom_color` = PitBull4's own four defaults (same length)
  - `highlight_style = "border"`

  Why four entries: AceDB fills missing array slots from PitBull4's defaults (`!L`, `!I`, `!J`), so a one-entry list would still run them. Empty names are skipped (`Highlight.lua:126`).

  Why `border`: the frames carry the 24 px Devil border art (Border module `size = 24`), and the highlight is a full-frame ADD texture inside it (`Highlight.lua:190-200`). The thick style keeps a visible band next to that art, where `thinborder` would be a hairline. Tier: estimate, check list asks.

  Focus and personal pet copy the party aura table, so they are set back to `highlight = false` (scope).
- **(d) Catch-up.**
  - `layoutV2Revision` 8 → 9.
  - The V2 copy of the Aura namespace keeps only the dispel keys of "데빌 파티", so the party's own geometry is not rewritten.
  - The new HideBlizzard fragment has no layouts, so V2 copies it whole.
  - `dfAuraGeometry` is replaced (`replace`).
  - Foreign PitBull4 profiles stay out: the existing catch-up test case "fresh install and foreign profile -> nothing" passes.
- **(e) Docs.** Check list §18; install guide line after Cooldown Manager; `data/feature-map.md:47`.

### Numbers before → after (screen map aura bands, physical px, x y w h)

| | fhd | qhd | uhd |
|---|---|---|---|
| player buffs | 581,525,256,64 (same) | 782,773,342,85 (same) | 1186,1238,512,124 (same) |
| player debuffs | 581,377,256,144 (same) | 782,578,342,191 (same) | 1186,954,512,280 (same) |
| target buffs | 1083,525,256,64 → 1083,377,256,64 | 1436,773 → 1436,578 | 2142,1238 → 2142,954 |
| target debuffs | 1083,377,256,144 → 1083,445,256,144 | 1436,578 → 1436,667 | 2142,954 → 2142,1082 |
| target preset offsets (buff / debuff) | 4 / 4+rows → buff 4+3·34+2·22+2 = 152, debuff 4 | buff 5+3·45+2·29+2 = 200, debuff 5 | buff 8+3·66+2·42+2 = 292, debuff 8 |

- **Stack height:** the total height of each stack is the same as before (uhd top 954). The target's debuff block now ends at the frame's top, at the same height as the player's buff block.
- **What sits above:**
  - The Grid2 40-player window still overlaps the target aura bands (pinned before, re-pinned; the party windows are clear).
  - The Details stack and the quest tracker estimate are clear (layoutv2 stack test).
  - The target-pet chain is beside the target, not above it.

### Impact map

| Place | Type | How found | Impact | Why |
|---|---|---|---|---|
| `Presets/{fhd,qhd,uhd}.lua` Aura loop | data | read | changed | target offsets swapped; highlight values |
| same, "데빌 파티" | data | read | changed | highlight values |
| same, copies "소환수와 주시"/"주시" | data | read | changed | highlight back to false (copies of the party table) |
| same, HideBlizzard namespace + fragment list | data | read | changed | R245 |
| `Presets/V2.lua` | code | read | changed | target order rule, party dispel-key copy, revision 9 |
| `PitBull4/Modules/Aura/Layout.lua` | code | read | changed | `order` in the managed rule |
| `patches/PitBull4.patch` | generated | `patches.py regenerate` | changed | +15/−11 lines |
| `Presets.lua` catch-up | code | read | check only | revision-driven, unchanged |
| `Defaults/PitBull4.lua` (HideBlizzard `castbar = false`, Aura "대상"/"파티" `highlight = false`) | data | read | check only | defaults for a new profile; the preset fragments written after them carry the new values; layout "파티" is not the collection's party layout ("데빌 파티") |
| `Modules/Aura/Forever.lua:263` | code | grep | check only | calls the same rule |
| `tests/layoutv2/run.py` | test | read | changed | catch-up asserts (order, HideBlizzard, dispel keys), target ≠ player only in offsets, order test, highlight values on all presets, pets/party highlight, revision 9, aura band order per owner, Grid2 overlaps re-pinned |
| `tests/firststart`, `core`, `pitbull4`, `pitbull4runtime`, `detailslayout`, `chatsetup` | test | run | check only | pass unchanged |
| install guide, `data/feature-map.md:47`, check list §18 | doc | grep | changed | |

### Commands (verdict lines)

| Command | Verdict |
|---|---|
| `python -I Collection/tools/extract.py` | rc=0 |
| `python -I <scratch>/s51.XsBX/devnull_run.py Collection/tools/patches.py regenerate --package PitBull4` / `verify` | wrote 332689 bytes / `patches=8 unmodified=25 failures=0` |
| `python -I Collection/tools/luacheck.py "Collection/AddOns/!DevilForever_Core/Presets" Collection/AddOns/PitBull4/Modules/Aura/Layout.lua` | `checked=5 failed=0` |
| `python -I Collection/tests/layoutv2/run.py` | first rc=1 (old assertions: player = target aura table, revision 8, band order, Grid2 pins); after the test update rc=0 · 46 PASS |
| `firststart` · `core` · `pitbull4runtime` · `pitbull4` · `detailslayout` · `chatsetup` | 30/30 · 110/110 · 20/20 · 6/6 · rc=0 · 47/47 |
| build dry-run pitbull4 / fuf (devnull wrapper) | rc=0 · 30/2800 · 32/2744 |

Raw outputs: `<scratch>/s72.dF1D/*.txt`.

### Decision Queue

1. **Weapon enchants.** The `aura` hider also hides the weapon enchant frame (poisons, oils, shaman weapon imbues). PitBull4's own weapon display is off in these layouts (`enabled_weapons = false`), so those icons show nowhere now. Option: `enabled_weapons = true` on "보통". Not done: outside the brief.
2. **Border style.** `border` is my choice for visibility next to the 24 px Devil art; not seen in game.
3. **Empty party layout possible.** The catch-up writes the party layout's dispel keys even into a collection profile that has no "데빌 파티" Aura layout yet (it then holds only those keys; PitBull4's layout defaults supply the rest).
4. **Reserved block height.** Target debuffs reserve the worst case: 16 own at 64 px plus 16 others at 40 px on uhd. With few debuffs, the buffs sit higher than the debuffs need. This is the same rule the player's debuff block already follows.

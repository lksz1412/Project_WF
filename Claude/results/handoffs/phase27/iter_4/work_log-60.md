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

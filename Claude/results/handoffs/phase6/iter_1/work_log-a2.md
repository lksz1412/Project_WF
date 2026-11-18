# Work log — Phase 6 Step 16 (Forever Unit Frames 0.65.2 functional settings) — work A2

Raw output: scratchpad `step16.Ve2t/` (volatile; verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole); phase6 detail plan (whole, 7 lines); `Claude/results/handoffs/phase6/SESSIONS.md` (whole); Phase 5 work log (whole, form)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 195–240 (feature table, row 213 = Phase 6), 391–460 (Interfaces, Test Plan, verification split)
- `Collection/judgment.md` 1–58, 76–124 (Phase 4–9), 282–320 (5, 6)
- `Collection/data/classes.md` (whole)
- `Collection/manifest.json` FUF, Grid2, PitBull4, NugComboBar packages (Python extract)
- Core: `!DevilForever_Core.toc`, `registry_extra.json` (whole); `Defaults.lua` 1–395 (whole); `Core.lua` 1–268 (whole); `API.lua` 1–80; `Collection/tools/genregistry.py` 1–400 (whole); `build.py` 1–40
- `Collection/AddOns/DevilForever_ChatSetup/` TOC + `ChatSetup.lua` 1–233 (whole, pattern); `Collection/tests/chatsetup/run.py` 1–240, 400–443; `Collection/tests/core/run.py` 120–200, 375–417
- `Collection/codex-briefs/phase5.md`, `appearance-5.md` (whole, form); `appearance-2.md` 1–34 (sections)
- Upstream FUF (read only, never run): `ForeverUnitFrames.toc` (whole); `Core/Init.lua` 1–164, `Core/Storage.lua` 1–268, `Core/Codec.lua` 1–164, `Core/Config.lua` 1–259, `Core/Boot.lua` 1–93, `Core/Commands.lua` 1–143, `Core/UnitProfiles.lua` 1–185, `Core/Preset.lua` 1–244, `Core/Registry.lua` 1–212, `Core/Settings.lua` 1–1155 (all whole); `Core/Debug.lua` 185–206; `Core/Themes.lua` 1–40, 460–477; `Raid/Settings.lua` 1–130 (+ grep party/solo); `Raid/Profiles.lua` 1–140; `Raid/Header.lua` 10–40; `Raid/Panel.lua` grep name (208, 458); `Elements/Power.lua` 1–91, `DruidMana.lua` 1–81, `ComboPoints.lua` 1–146 (whole); `Totems.lua` 1–280; `PetHappiness.lua` 1–60; `FiveSecondRule.lua` 1–60 (+ grep 225–229); `Health.lua` grep 140, 207–217; `Units/Units.lua` 17–37; `Units/Single.lua` 255–300; `Units/Party.lua` grep 15–16, 343; `Locales/enUS.lua` grep 146–156, 1070
- Comparison (only where needed): NugComboBar `NugComboBar-Camelot.toc` (whole), `NugComboBar.lua` 95–190 (Forever class config: WARLOCK `Disabled`)

## Findings used
- SV `ForeverUnitFramesDB` (account, `ForeverUnitFrames.toc:10`). Created at FUF's PLAYER_LOGIN (`Core/Boot.lua:27`), not at ADDON_LOADED. Unit profiles are **plain Lua tables**, overrides only, account-wide `profiles[<name>]`, character choice in `active["Name-Realm"]`, `profile` = old mirror of Default (`Core/UnitProfiles.lua:3–5, 41–54, 93–97`). Encoded strings are only for providers/export/macro backup (`Core/Storage.lua:114–123`, `Core/Codec.lua:3–7`) — judgment.md Phase 6 (iii) 「저장값이 부호화된 문자열」 is not what the SV holds (recorded here, judgment.md not edited).
- Why a Core defaults file cannot work: FUF reads the stored profile once at PLAYER_LOGIN into memory (`Boot.lua:31`, `Storage.lua:54–71`) and every save replaces the whole profile table with its in-memory copy (`UnitProfiles.Write` 93–97 ← `Storage.Save` 108–124, also at PLAYER_LOGOUT `Boot.lua:91–93`). Core's plain target would be fresh at FUF's ADDON_LOADED (SV nil), wait, write at the first PLAYER_ENTERING_WORLD after FUF already loaded defaults, and FUF's next save/logout would overwrite it. Fill-missing on later logins writes keys FUF has only in memory → lost at the next save too. Raid profiles (`ForeverUnitFramesDB.raid[charKey]`) are the live table (`Raid/Profiles.lua:5–8, 92–103`) but are created at PLAYER_LOGIN too.
- FUF public API: `ForeverUnitFrames.RegisterStorageProvider` (`Storage.lua:24–29`; load is asked only when the SV has no profile, `Storage.lua:63–67`; contract = encoded string) and the `/fuf` command handler `SlashCmdList.FOREVERUNITFRAMES` (`Commands.lua:92–143`; `set <scope> <setting> <value>` → `Config.Set` 133–139, bools take on/off 13–17, colours refused 28; `raid off|on` → `RaidConfig.Set("general","enabled")` 69–78, 101–107; help text `Locales/enUS.lua:146`). `Debug.lua:195–206` wraps the handler and passes other commands on.
- Row 213 needs vs FUF shipped defaults (no change needed): health on every frame (`Health.lua:207–217`); power bar on every frame `powerEnabled` true (`Settings.lua:174`); heal prediction `healPrediction` true (183); range fade `rangeFade` true (982), `rangeAlpha` 70 / friendly YARDS / hostile 40 yd (`Preset.lua:20–22`); buffs on target/focus/party, debuffs on all but ToT/ToToT/focustarget/pettarget (`Settings.lua:585–615`); class elements below default on. → no FUF value to change for the row except "party/raid off when Grid2".
- Mana/totems not forced: power bar colour/type from `UnitPowerType` (`Power.lua:69–88`); druid mana strip only for DRUID and only while the bar is not mana (`DruidMana.lua:20–23, 56–69`); totem icons only for occupied slots (`Totems.lua:229–252`), click areas armed for shamans only (`Totems.lua:109–118, 123–130`); five-second spark only while the bar shows mana (`FiveSecondRule.lua:51–53, 225–229`); low-mana warning off (`Settings.lua:1089`).
- Decided: no `Defaults/ForeverUnitFrames.lua`, no Core TOC line. New addon `DevilForever_FUFDefaults` (TOC 16001, deps `!DevilForever_Core, ForeverUnitFrames`, SV `DevilForever_FUFDefaultsDB` account): 3 s after the first PLAYER_ENTERING_WORLD, out of combat, when Grid2 is loaded, once per character (FUF key `Name-Realm`, `Raid/Profiles.lua:31–35`): sends `/fuf raid off` unless the raid profile stores `general.enabled`, and `/fuf set party enabled off` unless the active unit profile stores `party.enabled`. Reads FUF's SV, never writes it. FUF's own command is the only write path (no encoded strings).

## Class resources (FUF 0.65.2 vs `Collection/data/classes.md`)

FUF has no spec data (classes.md 「원천 없음」 row 1); every spec of a class gets the same elements. F/ = `Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/`.

| Class (specs) | classes.md primary / secondary | FUF shows (player frame unless noted) | FUF file:line | Match |
|---|---|---|---|---|
| WARRIOR (arms, fury, protection) | Rage / none | power bar by `UnitPowerType` → rage colour `powerColorRage` | F/Elements/Power.lua:13–18, 69–88; F/Core/Settings.lua:174 | yes |
| PALADIN (holy, protection, retribution) | Mana / none | mana bar + five-second-rule spark | Power.lua:69–88; FiveSecondRule.lua:1–7, 51–53; Settings.lua:1062 | yes |
| HUNTER (BM, MM, SV) | Mana / pet resource 원천 없음 | mana bar; pet frame power bar by the pet's own `UnitPowerType`; pet happiness icon on the pet frame (hunter only) | Power.lua:69–88; PetHappiness.lua:3–9, 50–57; Settings.lua:877 | yes (pet resource shown generically; classes.md has no source for its type) |
| ROGUE (assassination, combat, subtlety) | Energy / ComboPoints | energy bar; combo pips on the **target** frame, hidden at 0 | Power.lua:13–18; ComboPoints.lua:3–5, 36, 109–118; Settings.lua:722–723 | yes |
| PRIEST (discipline, holy, shadow) | Mana / none | mana bar + spark; shield watch exists but off | Power.lua; FiveSecondRule.lua; Settings.lua:759 (`shieldsEnabled` false) | yes |
| SHAMAN (elemental, enhancement, restoration) | Mana / none; totems 4 slots | mana bar + spark; totem icons for occupied slots, right-click destroys | Totems.lua:56–64, 109–130, 229–252; Settings.lua:701 | yes |
| MAGE (arcane, fire, frost) | Mana / none | mana bar + spark | Power.lua; FiveSecondRule.lua | yes |
| WARLOCK (affliction, demonology, destruction) | Mana / soul shards = item count (6265) | mana bar + spark; pet frame for the demon; **no soul shard display** | Power.lua; FiveSecondRule.lua; no shard element in the TOC file list | **mismatch: shards not shown** (classes.md: item count, not a power bar). NugComboBar Forever config also `WARLOCK = Disabled` (`NugComboBar.lua:177–183`) → Decision Queue 3 |
| DRUID (balance, feral, guardian, restoration) | Mana (caster) / cat Energy+ComboPoints, bear Rage | bar follows form (`UNIT_DISPLAYPOWER`); mana strip under the bar while not mana; combo pips on target frame in cat | Power.lua:6, 69–88; DruidMana.lua:3–8, 20–23, 56–69; ComboPoints.lua; Settings.lua:1053 | yes |

Mismatch count with classes.md: 1 (warlock soul shards — no FUF element).

## Steps
1. Wrote `Collection/AddOns/DevilForever_FUFDefaults/DevilForever_FUFDefaults.toc` and `FUFDefaults.lua` (one step, results per part: switched-off / kept-user-value / not-applied / api-missing / error; nothing stored while Grid2 is not loaded, FUF's SV is missing or the player name is unknown; `DevilForever_FUFDefaults.GetStatus()`; one Core `info` log line).
2. `registry_extra.json`: `ForeverUnitFrames` (15 frames `fuf.*` → `ForeverUnitFrames_<unit>`, `ForeverUnitFramesParty`, `ForeverUnitFrames_boss1–5`, `ForeverUnitFramesRaid`; editable position ×7, size ×5 (8–600); `ForeverUnitFramesDB` common; no defaults) and `DevilForever_FUFDefaults` (`DevilForever_FUFDefaultsDB` common). Diff = 136 added lines, 0 removed (`diff` vs scratchpad copy `registry_extra.before.json`).
3. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (43344 bytes, sha256 98214787be746a3e40d84beba2ea51bf8125426cd0f26316fb09c4ad81d8d75b)` both, sha256sum identical; `--check` → up to date rc0.
4. New `Collection/tests/fufdefaults/run.py` (18 cases; FUF command stand-in copies only the two commands' effects, FUF not run) → first run `cases=18 passed=18 failed=0`.
5. Core tests first run `cases=48 passed=47 failed=1` (`generated_registry_lookup`: frame list was Dominos+Prat+SexyMap). Expectation extended with FUF frames (15), FUF SV, FUF defaults = nil, FUF editable (12), FUFDefaults SV → `48/48`. No Core test with a real defaults-file shape: there is no FUF defaults file (finding above).
6. Briefs `Collection/codex-briefs/phase6.md` (items 0–9), `Collection/codex-briefs/appearance-6.md`.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py` ×2 identical + `--check` → up to date (43344 bytes) rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/AddOns/DevilForever_FUFDefaults Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=13 failed=0` rc0
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_FUFDefaults Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames` → `folders=3 unresolved=0 client_provided=0 optional_missing=0 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=48 passed=48 failed=0` rc0
- `python3 -I Collection/tests/fufdefaults/run.py` → `lupa=2.8 cases=18 passed=18 failed=0` rc0
- `python3 -I Collection/tests/chatsetup/run.py` → `lupa=2.8 cases=13 passed=13 failed=0` (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=3 files=15 zip_entries=17` rc0, sha256 `474064c5add9cdeac598559b1ede0d83cda4221fc36e179687b18389b73e52c5` both
- `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip` sha256 `cc50d16b…e1a80` = manifest

## Decision Queue
1. Template deviation: no `Defaults/ForeverUnitFrames.lua` (FUF rewrites its profile from memory on every save; Core plain injection would be lost — findings). The row's functional needs are already FUF defaults, so nothing else is shipped. Instead the brief-allowed addon `DevilForever_FUFDefaults` (new code → per Test Plan 「새 코드」 a code logic review 1회 is due; template's "master check" alone may not be enough).
2. Path used = FUF's `/fuf` command handler (`SlashCmdList.FOREVERUNITFRAMES`), the documented settings interface. Alternative: `RegisterStorageProvider` (works only on a fully fresh account, needs encoded strings) — not used per brief preference.
3. Warlock soul shards: FUF has no display (classes.md: item count). Options: (가) leave (bag count only), (나) a small display in a later Phase. NugComboBar on Forever disables warlock too. Default taken: (가).
4. "Once per character" semantics: the step runs the first login on which Grid2 is loaded (not only FUF's first load). Raid profile is per character; party lives in the account-wide unit profile, so the second character finds `party.enabled = false` already stored → `kept-user-value`. A user who turned FUF party/raid back on is never overridden (record exists). If Grid2 is never loaded, nothing happens.
5. A2 judgment: only `general.enabled` (raid) and `party.enabled` (unit profile) are touched. FUF party pets/targets follow the party frame. Blizzard party/raid frames: with FUF's off, FUF stops hiding them after a /reload (`Storage.lua:185–190`, `Locales/enUS.lua:1070`); hiding Blizzard's while Grid2 is on is Grid2's setting → Phase 9.
6. Castbars: FUF player castbar is ON in the shipped preset (`Preset.lua:39`, overriding `Settings.lua:394–395` player false) — judgment.md Phase 6 (iv) says player off by default; Phase 7 should start from the preset value. Not changed here (Phase 7 scope).
7. Appearance values cannot be injected by Core either; `/fuf set` refuses colours (`Commands.lua:28`). How Codex's `fuf-profile.fragment.lua` reaches FUF (extend FUFDefaults with `/fuf set` for non-colour keys, a storage provider for fresh accounts, or FUF's own import string) is open — appearance-6.md 3절 leaves it to Claude.
8. Registry size editable uses one range 8–600 for width and height (registry schema has one min/max); FUF clamps to 40–600 × 8–200 itself.
9. judgment.md Phase 6 (iii)/(iv) statements that are now known to be inaccurate (encoded strings in SV; player castbar default off) — judgment.md not edited (boundary).
10. Manifest not edited (template §0 boundary).

## Check 1 fix (triage `Claude/results/handoffs/phase6/TRIAGE_phase6.md`: M1, minor 2, minor 4)

Read: `TRIAGE_phase6.md` (whole); `Core/Boot.lua` 20–35, 85–93 re-read (cause of the wrong citations: Codec·Config·Boot had been printed by one `cat -n`, numbering ran on across files; Codec/Config citations checked — only Boot was cited with the shifted numbers).

### Impact map
| Place | Link | Verdict |
|---|---|---|
| `Collection/AddOns/DevilForever_FUFDefaults/FUFDefaults.lua` header, `activeProfile`, party branch in `run`, log line, `DELAY` | party code + timing | fix together (party removed, raid only, DELAY 3 → 20) |
| `…/DevilForever_FUFDefaults.toc` `## Notes` | says party and raid | fix together |
| `Collection/tests/fufdefaults/run.py` docstring, `fuf_after_login` docstring (Boot citation), party cases (`stored_user_values_are_kept`, `active_named_profile_is_read`, `missing_named_profile_falls_back_to_default`, `legacy_profile_mirror_counts_for_default`), expected records/calls in the rest, delay case | party expectations, Boot 450 | fix together; new `shared_profile_alt_keeps_party_on`; delay case asserts ≥ 20 |
| `Collection/codex-briefs/phase6.md` intro line, items 1 (wait), 4 (title), 5, 6, 7 | party-off text, 10 s waits, ZIP hash | fix together (raid only, party stays FUF, Grid2 raid-only → Phase 9; waits 30 s; hash) |
| `Collection/codex-briefs/appearance-6.md` §2 last line, ZIP hash | party-off text | fix together |
| `outputs/collection/DevilForever-collection.zip` | contains FUFDefaults | rebuild |
| this work_log Findings (Boot 450/454/514–516) | wrong citation | fix (27, 31, 91–93) |
| this work_log Findings "Decided", Steps 1, Gates (final), DQ 4–5 | party design of the first pass | no impact (record) — superseded by this section |
| `registry_extra.json`, `Registry.lua`, `tests/core/run.py` | FUFDefaults SV only, no party data | check only — unchanged (`--check` up to date, core 48/48) |
| `Defaults.lua`/Core | not used by FUFDefaults beyond `Log`/`IsLoadedInClient` | no impact |

### Change
- FUFDefaults: only `/fuf raid off` (per-character raid profile), post-check `general.enabled == false` kept (`not-applied` otherwise); party code, `activeProfile` and party records removed; record = `{version, raid}`; log `"<key>: raid <result>"`; `DELAY = 20` (FUF holds saves 15 s on a fresh install, `Core/Storage.lua:161, 227–245`).
- Tests: 16 cases (party cases removed, `shared_profile_alt_keeps_party_on` added: alt with Grid2 and an account-wide Default profile → only `raid off`, party profile unchanged, alt record `{version 1, raid switched-off}`).
- Briefs: party stays FUF; Grid2 showing raid only is Phase 9 (triage note); expected outputs updated; waits 30 s.

### Gates (fix)
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_FUFDefaults` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=1 failed=0` rc0
- `python3 -I Collection/tests/fufdefaults/run.py` → `lupa=2.8 cases=16 passed=16 failed=0` rc0
- `python3 -I Collection/tools/genregistry.py --check` → up to date (43344 bytes) rc0 (registry unchanged)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=48 passed=48 failed=0` rc0
- `python3 -I Collection/tools/build.py` ×2 → `built folders=3 files=15 zip_entries=17` rc0, sha256 `bc15c185ebb3f38d88df88f060b2a4196b9517d5e7c2b7130a4ffb65f3e53036` both; phase6.md and appearance-6.md hash lines updated

### Decision Queue (after fix)
- DQ 4–5 of the first pass are replaced: FUF party is never touched; Grid2 must not show party while FUF party is on (Phase 9, triage note).
- Minor 3, 5 (api-missing is stored permanently; "Grid2 loaded" means the client loaded it, not a collection switch) → final report (triage).
- DQ 3 (warlock soul shards): master chose (가) — final report as an R61 gap candidate.

# Work log — Phase 6-rev Steps 42–43 (PitBull4 Forever variant, compared with FUF) — work A2

Raw output: scratchpad `step42.TGoi/` (volatile; the verdict lines below are the record). Paths: `U/` = `Collection/upstream/pitbull-unit-frames-4-0-v4.2.50/PitBull4/` (v4.2.50, read only, never run), `V/` = `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/PitBull4/` (4.2.49-Forever-v42, read only, never run), `O/` = `Collection/AddOns/PitBull4/` (our copy), `D/` = `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/!DevilUI/`.

## Read (basis)
- Phase 6-rev detail plan (whole, 8 lines); `Claude/results/handoffs/phase6-rev/SESSIONS.md` (whole); `Claude/results/REQUEST_LEDGER_phase6-rev.md` (whole, 6 lines); `Claude/results/REQUEST_LEDGER_phase8.md` rows 9, 18–20 (R105–R107 text)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: 20–88 (contents, Step totals), 92–94, 143–146, 213, 217–218 (rows 6, 6-rev), 222–233, 249, 268–274, 374–377, 444 (6-rev verification split), 479–548 (Correction History D1–D7, exception R87, stop table)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole, 28 lines); Phase 8 work_log-a2 1–80 (whole, form); Phase 6 work_log-a2 1–60 (FUF findings, class table); `Claude/results/handoffs/phase6/TRIAGE_phase6.md` (whole, 11 lines)
- `Collection/judgment.md` 92–100 (Phase 6); `Collection/data/classes.md` (whole, 47 lines); `Collection/manifest.md` 1–40; `Collection/manifest.json` PitBull4 package (Python dump: role comparison, 4 TOCs, no 16001, `PitBull4DB`)
- `Collection/codex-briefs/phase6.md` (whole, 81 lines), `appearance-6.md` (whole, 34 lines)
- Core: `API.lua` 1–168 (whole), `Defaults.lua` 1–395 (whole), `!DevilForever_Core.toc` (whole), `Defaults/Dominos.lua`, `Defaults/Hekili.lua` (whole), `registry_extra.json` (Python summary of every entry)
- Tools: `genregistry.py` 1–390 (whole), `luacheck.py` 1–96 (whole), `tocdeps.py` 1–139 (whole), `build.py` 1–144 (whole), `toclib.py` 1–60, 149–231; `Collection/tests/core/run.py` 1–200, 375–440, 1030–1051
- U/: all four TOCs (whole), `CHANGELOG.md` 1–8 (v4.2.50 = TOC bump for 5.5.4 + LuaTexts SmartRace fix), `Main.lua` 80–330, 1095–1300, 1555–1620 (defaults, DEFAULT_GROUPS/UNITS, upgrade functions, AceDB:New), `Modules/SoulShards_Classic/SoulShards.lua` 1–120, `Modules/LuaTexts/ScriptEnv.lua` 536–575
- V/: all eight TOCs (whole), `README_Forever_koKR.txt` (whole, 66 lines), `Compat.lua` 1–213 (whole), `SpecProfiles.lua` 1–242 (whole), `modules_Camelot.xml` (whole) vs `modules_Vanilla.xml`/`modules_TBC.xml` (diff), `Main.lua` 1179–1225 (upgrade [1]) and full diff vs U, `GroupHeader.lua` 308–340, `UnitFrame.lua` 60–100, `ModuleHandling/Module.lua` 195–274, `Modules/ComboPoints/ComboPoints.lua` 1–120, 177–202, `Modules/HappinessIcon_Classic/HappinessIcon.lua` 1–60, `Modules/AltManaBar/AltManaBar.lua` 1–30, `Modules/Totems/Totems.lua` 1–30, 230–233, `Modules/LuaTexts/LuaTexts.lua` 723–742, 1445–1448, 1648–1656, `Options/LayoutEditor/General.lua` 25–75, heads (1–25) + function lists of `Modules/Aura/Forever.lua`, `Modules/CastBar/Forever.lua`, `Modules/LuaTexts/Forever.lua`, `Options/NativeControls.lua`; the four `load.xml` that add them (whole)
- Diffs V vs U (`diff -ru --strip-trailing-cr`): Main.lua (whole diff), ScriptEnv.lua (whole diff), all library and XML loader diffs (whole), and every removed line of every other file with its hunk header (`-U0`, Libs and TOCs excluded: 1118 removed lines read)
- D/: `!DevilUI.lua` 1–60, 1280–1320, 1475–1510 (profile choice: default "Wide"); `Profile/PitBull4.lua` (9036 lines) parsed with a non-executing Lua-table reader (scratchpad `tools/luatable.py`) → profiles Wide/Wide_B/Wide_P/Wide_T/Wide_WH; profile "Wide" and every namespace's "Wide" profile dumped in full (scratchpad `ns_wide.txt`, `devil_pb4.json`)

## Step 42 — V42 vs v4.2.50: what is Forever-specific

Commands: `diff -rq U V` → 194 lines, almost every file differs; cause = U files are CRLF, V files LF (`file` check). `diff -rq --strip-trailing-cr U V` → 86 lines (72 changed files + 14 only-in). Changed+added lines without CR noise: 3985 added / 1370 removed in changed files; new V files 1352 lines.

Upstream 4.2.49→4.2.50 (`U/CHANGELOG.md:3–8`): Mists TOC bump to 50504 and LuaTexts SmartRace guard. V's Mists TOC is already 50504; V lacks the SmartRace guard (`U/Modules/LuaTexts/ScriptEnv.lua:540` vs V 572) → keep upstream's. Libraries (decided by the library's own version number): LibDBIcon MINOR U 56 > V 55 → U; LibDualSpec MINOR U 29 > V 28 → U file kept but V stops loading it (`V/libs.xml:21–28`) → follow V; AceGUI Slider widget U 24 > V 23 → U; AceGUI CheckBox widget V 28 > U 26 (replaces the removed global `SetDesaturation` with `:SetDesaturated`) → V. CallbackHandler, LibStub, LibDataBroker, LibUnitEvent, SimpleSticky: line endings only.

Every other difference is V's Forever work. Forever = `WOW_PROJECT_CAMELOT` with a 12.x engine (secret/restricted values, `C_RestrictedActions`, curves — `V/Compat.lua:12–14, 48–85`; `V/Modules/Aura/Forever.lua:1–4` "Forever's 12.1 engine"). V42 fix list (line numbers = our copy `O/`, identical to V's except CRLF):

| # | Kind | Where (O/ file:lines) | What |
|---|---|---|---|
| 1 | TOC | new `PitBull4_Camelot.toc`, `PitBull4.toc` 1–28 (V's own: `V/PitBull4_Camelot.toc:1–29`) | Interface 16001, loads `modules_Camelot.xml`; OptionalDeps without LibDualSpec |
| 2 | Module set | new `modules_Camelot.xml` 1–57 | TBC list with CastBar (not CastBar_Classic); CastBarLatency, EnergySpark_Classic, ManaSpark_Classic, SoulShards_Classic, Runes_Classic, Chi, HolyPower, Essence, QuestIcon, SummonIcon, BattlePet, AltPowerBar, ArcaneCharges, ArtifactPowerBar not loaded |
| 3 | Compat layer | new `Compat.lua` 1–213; `libs.xml` 1–7 (loaded first) | client detection (`IsForever`, expansion level 0), secret-value test, optional events, restriction state, C_AddOns/C_Spell adapters |
| 4 | Spec profiles | new `SpecProfiles.lua` 1–242; `libs.xml` 21–28; `Main.lua` 1398–1403, 1446–1454; `Options/Options.lua` 126–141; `Localization/enUS.lua`/`koKR.lua` 1211–1221/1193–1203 | replaces LibDualSpec (not loaded) with an own per-spec/talent-group profile switch on the same saved namespace `LibDualSpec-1.0`; off until the player turns it on; no switch in combat |
| 5 | Secret-value guards | `Main.lua` 1–109, 594–650, 949–1014, 1951–1969 (GUID maps); `Utils.lua` 14–151 (`Safe*`); `ModuleHandling/BarModules.lua`, `FaderModule.lua` 172–178, `IndicatorModule.lua` 31–64, `Module.lua` 308–314 (`FrameHasUnit` instead of `frame.guid`); `GroupHeader.lua` 1823–1834; `UnitFrame.lua` 2–24, 264–869 | no GUID/number arithmetic or table keys on restricted values; restricted NPC identity handled as a live unit (`UpdateProtectedUnit`) |
| 6 | Combat restriction | `Main.lua` 1782–1856 (`ADDON_RESTRICTION_STATE_CHANGED`, `HasRestrictedUnitData`), 2176–2183 | pending updates replayed when the restriction ends |
| 7 | Bars | `Controls/BetterStatusBar.lua` 1131–1167, 1278–1576; `Modules/HealthBar/HealthBar.lua` 30–451 (v2: one basis for number and bar, `UnitHealthPercent` with predicted health — readme 42–45); `Modules/PowerBar/PowerBar.lua` 1–263; `Modules/AltManaBar/AltManaBar.lua` 1–272 (druid/priest/shaman mana); `Modules/VisualHeal/VisualHeal.lua` 4–191 | bars fed by `UnitHealthPercent(unit, true[, curve])` / `UnitPowerPercent` (HealthBar.lua 156–167, 305–310; PowerBar.lua 155–157) |
| 8 | Auras | new `Modules/Aura/Forever.lua` 1–311 + `load.xml`/`load_Classic.xml`; `Aura.lua` 5–80, `Update.lua`, `Filter.lua`, `FilterTypes.lua`, `Highlight.lua`, `Controls.lua` 40–92, `Layout.lua` 4–21, 248–254 | v3: debuffs through Blizzard `CustomAuraContainer` (readme 12–33: only layouts whose debuff filter is "none"; per-group max; fixed timer colour; no Masque/highlight on that path; old path when the template is missing); scans skip restricted entries; size-to-fit and name sort removed |
| 9 | Cast bar | new `Modules/CastBar/Forever.lua` 1–90; `CastBar.lua` 29–407 | duration objects from `UnitCastingDuration`/`UnitChannelDuration`, no GUID keys |
| 10 | Texts | new `Modules/LuaTexts/Forever.lua` 1–75; `LuaTexts.lua` 38–1237+; `ScriptEnv.lua` 1–752+ | restricted values go to native FontString sinks; script helpers return safe values |
| 11 | Class elements | `ComboPoints.lua` 1–381 (target frame in classic rules, curve path when restricted); `HappinessIcon_Classic/HappinessIcon.lua` 4–97 (`GetPetHappiness` or `C_PetInfo`); `Totems/Totems.lua` 57–1238 (LSM sounds dropped); `RaidTargetIcon.lua` 1–208 (per-icon toggles dropped) | — |
| 12 | Blizzard frame hiding | `Modules/HideBlizzard/HideBlizzard.lua` 6–416 | rewritten for 12.x frames; `SetParent` only out of combat, in combat `SetAlpha` and a retry (O/ 109–223) |
| 13 | Other modules | Aggro 58–112, Background, Border, CastBarLatency, CombatFader 1–166, CombatText 77–158, ExperienceBar 20–26, Highlight, LeaderIcon, PhaseFader, PhaseIcon, Portrait, PvPIcon, RangeFader 1–6, ReadyCheckIcon, ReputationBar, RoleIcon, ThreatBar | API guards and `C_*` adapters |
| 14 | Options UI | new `Options/NativeControls.lua` 1–306 + `Options/load.xml`; `Options.lua`, `General.lua`, `Modules.lua`, `LayoutEditor/Bars.lua` 491–543; AceGUI CheckBox 28 | own toggle/collection widgets for the options dialog |
| 15 | Removed module (Forever) | `modules_Camelot.xml:49` SoulShards_Classic commented out | its shards are a power type (`U/Modules/SoulShards_Classic/SoulShards.lua:10, 53–56`); Forever shards are an item count (classes.md WARLOCK) |

Not Forever-specific in V and not ported: `V/load.xml` (only drops the packager `@debug@` comment), `V/PitBull4_Classic.toc`/`_Vanilla.toc`/`modules_Vanilla.xml` (Era 11509, not a target), `V/README_Forever_koKR.txt`, V's version strings and TOC Author/InterfaceStatus lines (V's claims about V's build).

Port design (A2 judgment): our copy = v4.2.50 bytes + V's file for every V change except the five library/loader files above + the SmartRace guard restored; two new 16001 TOCs with upstream Author, version `v4.2.50-forever.1`, `X-PitBull4-Manifest` (read by `Compat.GetClientInfo`, `O/Compat.lua:211`); CRLF kept for every file. V's game confirmation (TOC `X-PitBull4-InterfaceStatus`) is not copied: our build is not game-tested.

## Step 43 — build, defaults, registry, tests, briefs

### Edits
1. NEW `Collection/AddOns/PitBull4/` (309 files) by scratchpad script `tools/build_pb4.py` (copy of U/, then V/ files; script refuses an existing target): 70 files taken from V (63 changed + 7 new: `Compat.lua`, `SpecProfiles.lua`, `modules_Camelot.xml`, `Modules/Aura/Forever.lua`, `Modules/CastBar/Forever.lua`, `Modules/LuaTexts/Forever.lua`, `Options/NativeControls.lua`), 9 kept from U (4 flavour TOCs, `load.xml`, Slider, LibDBIcon, LibDualSpec .lua/.toc), version line `Main.lua:454` → `v4.2.50-forever.1`, SmartRace guard restored `Modules/LuaTexts/ScriptEnv.lua:572`, new `PitBull4_Camelot.toc`/`PitBull4.toc` (Interface 16001, upstream Author, OptionalDeps without LibDualSpec, `X-PitBull4-Manifest`, `X-DevilForever-Patch`). All files CRLF like U.
   - check `diff -rq --strip-trailing-cr V O` → only the intended differences (U-only CHANGELOG.md; the 9 kept-U files; Main.lua line 454; ScriptEnv.lua 572; the two new TOCs; V-only Classic/Vanilla TOCs, modules_Vanilla.xml, readme)
2. NEW `Collection/patches/PitBull4.patch` (header 33 lines: base + sha256, V42 source attribution, port choices, CRLF note, apply command; body = `diff -ruN a/PitBull4 b/PitBull4`, 9,291 lines, 72 files), sha256 `dbb430414c92810a380d05c4452ec3ed1a184a3985d4eb092e64a37ccd36a976`.
   - check: fresh copy of U + `patch -p1 --binary` → rc 0, `diff -r` with O → `TREE_IDENTICAL`
3. NEW `Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua` (486 lines): generated by scratchpad `tools/gen_pb4_defaults.py` (functional allowlist over Devil "Wide") + `tools/emit_pb4_lua.py`, then header and block comments. Shape: 26 AceDB targets on `PitBull4DB`, profile `"Default"` — 1 main profile target + 25 namespace targets (Aggro, Aura, BlankSpace, CastBar, CombatFader, CombatIcon, CombatText, ComboPoints, ExperienceBar, HideBlizzard, Highlight, HostilityFader, LeaderIcon, LuaTexts, PowerBar, PvPIcon, RangeFader, ReputationBar, RestIcon, RoleIcon, Sounds, ThreatBar, Totems, VisualHeal, VoiceIcon).
   - check (lupa, stand-in Register): `folder PitBull4 version 1 targets 26 profile_match True namespaces_match True ns 25` (= Devil functional values + the one added marker)
4. `!DevilForever_Core.toc`: `Defaults\PitBull4.lua` after `Defaults\Hekili.lua`.
5. `registry_extra.json`: `PitBull4` entry (round-trip of the old file identical first; +76 lines, 0 removed): 10 frames `pb4.*` → `PitBull4_Frames_<koKR unit name>` ×7, `PitBull4_Groups_<group>` ×3 (naming `O/UnitFrame.lua:80`, `O/GroupHeader.lua:39–51`); editable position ×6 (player, target, targettarget, focus, pet, party); `PitBull4DB` split common; defaults path. `Registry.lua` regenerated.
6. `Collection/tests/core/run.py`: `generated_registry_lookup` frame set + PitBull4 entry asserts; new cases `pitbull4_defaults_fresh_shared_default_profile`, `pitbull4_defaults_user_values_and_spec_profile_kept`.
7. NEW `Collection/tests/pitbull4/run.py` (5 cases, PitBull4 never run): 16001 TOCs + version, every Script/Include of all six TOCs exists, Camelot module set (class elements present, SoulShards etc. absent), patch reproduces O byte for byte (temp dir), defaults spec vs the copy (namespaces = loaded module ids, layouts exist, no appearance keys, LuaTexts attach only to loaded bars, `first = false`).
8. NEW `Collection/data/unitframes-compare.md`, `Collection/codex-briefs/phase6-rev.md` (items 0–9), `Collection/codex-briefs/appearance-6-rev.md`. Banned-lexicon scan (`.claude/tools/banned_lexicon.json`, 30 terms) on the five new text files → 0 hits.

### Defaults decisions (A2 judgment)
- Functional = which units/groups exist and are on (`enabled`, `unit`, `unit_group`, `exists`), the layout each uses, layout `exists`, module `global.enabled`, per-layout module `enabled`, Aura counts/filters/`highlight`/`enabled_weapons`, LuaTexts `code`/`events`/`attach_to`/`exists`/`enabled`/`first`, `HideBlizzard.castbar`, `lock_movement`, `frame_snap`, `minimap_icon.hide`, `class_order`, `made_units`/`made_groups`. Everything else of "Wide" (164 paths: positions, anchors, scale, sizes, spacing, textures, fonts, colours, borders, backgrounds, portraits, text locations/sizes, aura sizes/timers) → appearance-6-rev.md. Portrait on/off counted as appearance (same as FUF `portraitMode` in appearance-6.md). `attach_to` of a text counted as functional (which bar's number it is); `location` as appearance.
- Explicit `layout = "보통"` on units without one (Devil relied on koKR `L["Normal"]` = 보통) and `unit_group = "party"` on 파티 → result independent of client language.
- Added `group_anchors_updated = true` (not in Devil): on a Core-created `PitBull4DB` PitBull4 finds no `global.config_version` and runs upgrades 1–7 once (`O/Main.lua:1179–…`, `check_config_version`); upgrade 2 would otherwise recompute group offsets from defaults (`O/GroupHeader.lua:308–318`) and write raw positions; it clears the flag itself.
- Namespaces of modules not loaded on Camelot (CastBarLatency, Chi, Eclipse, HolyPower, MasterLooterIcon, Runes, ShadowOrbs, SoulShards) left out.
- Devil values kept although they differ from the FUF row: VisualHeal off (heal prediction), RangeFader off, Totems off (Dominos totem bar), no Boss group (Blizzard boss frames stay: `O/Modules/HideBlizzard/HideBlizzard.lua:14–26` `boss = false`). → DQ 2.
- Profile rule / timing: `AceDB:New("PitBull4DB", DATABASE_DEFAULTS, "Default")` (`U/Main.lua:1279`) → shared profile "Default"; modules `RegisterNamespace(module.id, …)` (`O/ModuleHandling/Module.lua:205–239`); OnInitialize at PitBull4's ADDON_LOADED after Core's handler → Core creates the tables first (core test case 1). profileKeys (spec profile `O/SpecProfiles.lua`, or a user/Devil "Wide") wins (core test case 2).

### Class resources (PitBull4 copy vs `Collection/data/classes.md`, modules loaded by `O/modules_Camelot.xml`)

| Class | classes.md | PitBull4 on Forever | Match |
|---|---|---|---|
| WARRIOR | Rage | PowerBar by power type (`O/Modules/PowerBar/PowerBar.lua:155–157`) | yes |
| PALADIN | Mana | PowerBar | yes |
| HUNTER | Mana; pet + happiness | PowerBar; pet unit 플레이어의 소환수 on; HappinessIcon (hunter only, `O/Modules/HappinessIcon_Classic/HappinessIcon.lua:1–40`, indicator default on `O/ModuleHandling/IndicatorModule.lua:15`) | yes |
| ROGUE | Energy + ComboPoints | PowerBar; ComboPoints on the target frame (classic rule, `O/Modules/ComboPoints/ComboPoints.lua:177–193`); off on 대상의대상/파티 layouts (Devil) | yes |
| PRIEST | Mana | PowerBar (DruidManaBar module also loads for priests, shows only when mana is not the primary power, `O/Modules/AltManaBar/AltManaBar.lua:3–5, 18–24`) | yes |
| SHAMAN | Mana; totems 4 | PowerBar; Totems module present but **off** (Devil; Dominos totem bar per classes.md) | yes (totems not forced) |
| MAGE | Mana | PowerBar | yes |
| WARLOCK | Mana; shards = item count 6265 | PowerBar; pet unit; **no shard display** — PitBull4's shard modules count power-type shards (`U/Modules/SoulShards_Classic/SoulShards.lua:10, 53–56`) and are not loaded (`O/modules_Camelot.xml:49`) | **mismatch** (same as FUF) → DQ 1 |
| DRUID | Mana; cat Energy+CP; bear Rage; mana in forms | PowerBar follows form; ComboPoints in cat on target; DruidManaBar while shifted (`show_in_forms` default true for druids) | yes |

Mismatch count: 1 (warlock soul shards — neither FUF nor PitBull4).

### Gates (verdict lines)
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Castbars Collection/AddOns/PitBull4 Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=202 failed=0` rc0 (PitBull4 alone: `checked=186 failed=0`)
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/PitBull4` → `folders=2 unresolved=0 client_provided=0 optional_missing=14 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` rc0 (optional = Ace3, LibSharedMedia-3.0, AceGUI-3.0-SharedMediaWidgets, LibDBIcon-1.0, LibBossIDs-1.0, Clique, Masque ×2 TOCs; all but LibBossIDs/Clique/Masque are embedded under `Libs/`)
- embedded library TOCs (information): `tocdeps.py …/Libs/LibDeflate …/Libs/LibDualSpec-1.0 …/Modules/Aura/Libs/LibPlayerSpells-1.0` → `folders=3 unresolved=0 … no_interface_toc=3 … load_on_demand=2` (embedded, loaded through `libs.xml`/`load.xml`, not as addons; LibDualSpec and LibPlayerSpells are not loaded on Camelot)
- `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (49640 bytes, sha256 cc511a49461ca312de8a6e9bc343389f362e2a27f96eefd96b81a57719ab8013)` both; `--check` → up to date rc0
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=52 passed=52 failed=0` (first run after the registry change 49/50: `generated_registry_lookup` frame list → expectation extended)
- `python3 -I Collection/tests/pitbull4/run.py` → `lupa=2.8 cases=5 passed=5 failed=0` (first run 3/5: module-id regex required `")"` after the id, `NewModule("LuaTexts", "AceHook-3.0")` missed → regex fixed)
- `castbars/run.py` → `cases=16 passed=16`; `chatsetup/run.py` → `cases=13 passed=13`; `fufdefaults/run.py` → `cases=16 passed=16` (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=5 files=328 zip_entries=330` rc0, sha256 `7f377e64515b66bb56746d0efa2bf1f59bfa2465b9611dd1445201ec73eeb5ad` both; ZIP now holds `Interface/AddOns/PitBull4/`
- briefs: `phase6-rev.md` sections=10 (items 0–9); `appearance-6-rev.md` 4 sections

## Decision Queue (A2 defaults taken)
1. Warlock soul shards: no display in either variant. A PitBull4-native config-only route exists (a LuaTexts text with `GetItemCount(6265)` on the player layout + a bag event added to LuaTexts `global.events`), not built — new behaviour beyond the Devil profile and not verifiable here. Default: not added; R61 gap candidate in the final report (as Phase 6 DQ 3).
2. Devil profile values that differ from the FUF row (heal prediction off, range fade off, totem icons off, no PitBull4 boss frames): kept as the plan says "Devil profile 을 기본값으로". If master wants the comparison on equal terms, flip `VisualHeal`/`RangeFader` `global.enabled` (two lines in Defaults/PitBull4.lua).
3. Existing non-Devil PitBull4 profiles: Core fills missing keys, so a profile whose frames carry other names (e.g. an enUS "Player") would get the Devil koKR units added → duplicate frames. The brief moves `PitBull4.lua` aside first. A Devil/V42 "Wide" profile gets only missing keys (benign, core test 2). Core has no "fresh profile only" switch for AceDB targets — Core change if wanted.
4. Manifest/registry: `Collection/manifest.json` still lists PitBull4 as role `comparison` (Phase 6), so the registry entry comes from our-addon discovery: `package = "DevilForever"`, `phases = {}`, `use = "new"`. Making it start/modify for 6-rev needs a manifest change plus a genregistry rule for modified start addons kept in `Collection/AddOns` (today it errors "both ours and a start package") — outside this boundary.
5. The collection ZIP (build.py takes every `Collection/AddOns` folder) now ships `PitBull4` next to the FUF helpers; the brief switches one variant off per pass. Bundling (one, both, or neither by default) is Phase 23's decision (R107 ①).
6. Ported V42 v3 debuff path (`Modules/Aura/Forever.lua`) is, by V42's own readme (lines 47–52), not game-verified; kept (falls back to the old path without the template). Brief items 3/5 check it.
7. Other flavour TOCs (Cata/Mainline/Mists/TBC) kept byte-identical to v4.2.50 but now load the Forever code (`libs.xml` with Compat/SpecProfiles, V42 module files) — as V42 shipped them; untested on those clients; not a target.
8. `PitBull4_DogTagTexts` (second folder of the v4.2.50 package, no 16001 TOC) is not ported; Devil "Wide" uses LuaTexts only (V42 readme 57).
9. Registry editable items: position only (6 frames). PitBull4 sizes are layout values shared by several frames; they go through the appearance fragment instead of Edit `size` items. Codex may propose items in its registry fragment.

## Check 1 fix (TRIAGE_phase6-rev.md: M1 Core AceDB rule, minor 1, minor 3)

Read for this fix: `Claude/results/handoffs/phase6-rev/TRIAGE_phase6-rev.md` (whole, 11 lines); `O/Libs/AceDB-3.0/AceDB-3.0.lua` 165–180 (removeDefaults: default-equal values set to nil), 345–360 (logout handler strips every DB), 418–430; `O/Main.lua` 1764–1771 (`OnNewProfile` marks `layouts[L["Normal"]].exists`); `O/Localization/*.lua` grep `L["Normal"]` (deDE 673, enUS 697, esES 603, esMX 584, frFR 615, koKR 682, ptBR 340, ruRU 598, zhCN 686, zhTW 620); `Core.lua` 29–46 (FillMissing), 196–208; `Defaults.lua` 1–395 (in context, whole); `API.lua` 18–38; `Collection/tests/core/run.py` 326–372, 690–722, 836–978; `fixtures/Defaults_Example.lua` (whole); `Defaults/Dominos.lua`, `Hekili.lua`, `Prat-3.0.lua` heads; brief grep `GetStatus|written|fill-missing` (phase3 29–31, phase4 42–43, phase5 29–31, phase8 23–26).

### Impact map (before editing)

| # | Place | Link | Verdict |
|---|---|---|---|
| 1 | `Defaults.lua` 47–54 (AceDB header: "raw keys are the user's"), 56–66 (once per version, higher version fills missing) | the wrong premise | fix together |
| 2 | `Defaults.lua` `locateAce` 200–232, `attempt` AceDB branch 276–319 | writes into an existing profile; creates tables before deciding | fix together (first-look snapshot of every AceDB target before any write of the attempt; write only into a profile new at that look; else state `existing-profile-kept`, kept marker, nothing created) |
| 3 | `Defaults.lua` 343–347 GetStatus comment, `API.lua` 23–34 state list | new state | fix together |
| 4 | plain path (`firstLook`, `locatePlain`, late-created, WriteOver) | not AceDB | no impact (plain saved variables are not stripped by AceDB) |
| 5 | `Core.lua` 29–46 FillMissing | still used for the new-profile write and plain targets | check only |
| 6 | `tests/core/run.py` `defaults_acedb_profile_fill` 330–341, `dominos_defaults_existing_profile_kept`, `prat_defaults_user_values_and_profile_kept`, `hekili_defaults_user_and_dual_spec_profile_kept`, `pitbull4_defaults_user_values_and_spec_profile_kept` (959–976) | existing-profile cases, some seeded default-equal raw values AceDB would have stripped | fix together (seed what AceDB leaves after logout; expect nothing written) + new cases: stripped-empty profile kept via profileKeys, new character on existing SV written, namespace without data under an existing profile kept, version bump on an existing profile kept |
| 7 | fresh-install cases (Dominos/Prat/Hekili/PitBull4 fresh, TestAce new character, regional, char scope) | profile new at first look | check only (must stay applied) |
| 8 | `Defaults/PitBull4.lua` header 6–8, 19 ("fills the profileKeys profile", "only gets keys it lacks") | rule changed | fix together; + minor 1 (CastBar layouts off), minor 3 (`L["Normal"]` layout exists by client locale) |
| 9 | `Defaults/Dominos.lua` 4–6, `Hekili.lua` 3–5, `Prat-3.0.lua` 3–5 header text "Core fills the profile that profileKeys names" | comment now inaccurate | outside the granted boundary → Decision Queue (comment-only) |
| 10 | briefs phase3/4/8 expected `applied fill-missing … 1` | fresh install (SVs moved aside first); mode stays `fill-missing` for the new-profile write | check only; ZIP hash lines in every phase*/appearance* brief → fix together after the build |
| 11 | `Collection/data/unitframes-compare.md` 51, `phase6-rev.md` intro | "missing keys only" / duplicate-frame risk | fix together (existing profile untouched) |
| 12 | `tests/pitbull4/run.py` defaults case | layouts gain the `Normal` name | check + add the locale-map check |
| 13 | work logs, triage, Step 43 DQ 3 | records | no impact (record) |

### Check 1 fix — edits
1. `Defaults.lua` (161 lines changed): header 47–72 rewritten (AceDB stripping; write only into a profile new at Core's first look; new = SV nil, or no profileKeys entry for this character and neither `<SV>.profiles` nor the namespace's profiles holds the profile; else state `existing-profile-kept` + marker `defaults.kept[folder][targetKey] = version`; version bump never reaches a profile written before). `locateAce` split into `inspectAce` (214–242, no writes) and `createAce` (244–266, creates tables of a new profile only). `attempt` (284–…): first-look pass over every AceDB target before any write of the attempt (293–300), AceDB loop (301–343), plain loop unchanged in behaviour (`info` always set there). `fresh` comment 91, GetStatus comment 427–430.
2. `API.lua` 28–35: state `existing-profile-kept`; `fill-missing` note for AceDB.
3. `Defaults/PitBull4.lua`: header 6–10 (rule), 21–22 + `NORMAL_LAYOUT` 26–28 and line 499 (minor 3: `layouts[L["Normal"]].exists`, map = PitBull4 Localization koKR 682 / ruRU 598 / zhCN 686 / zhTW 620, others "Normal"); `CastBar.layouts` 대상/대상의대상/보통/파티 `enabled = false` (minor 1, 173–194).
4. `tests/core/run.py`: comment on AceDB stripping (AceDB-3.0.lua 165–178, 352–356); `defaults_acedb_profile_fill` → `defaults_acedb_existing_profile_kept` (+ next session still kept); new `defaults_acedb_stripped_profile_kept_by_profile_key`, `defaults_acedb_new_character_on_existing_sv_written`, `defaults_acedb_namespace_under_existing_profile_kept`, `defaults_acedb_version_bump_existing_kept`; `defaults_acedb_new_character_uses_profile_rule` + namespace written in the same pass; Dominos/Prat/Hekili/PitBull4 existing-profile cases re-seeded as AceDB leaves them (default-equal values absent) and expect `existing-profile-kept`, nothing written; PitBull4 fresh case: CastBar layouts, `Normal` layout, koKR run (`GetLocale` → 보통).
5. `tests/pitbull4/run.py`: new case `normal_layout_names_match_localization` (map in the defaults file = non-"Normal" `L["Normal"]` of the 10 PitBull4 locale files).
6. `Collection/data/unitframes-compare.md:51` (existing profile untouched), `phase6-rev.md` intro (existing PitBull4 profile gets nothing).
7. ZIP hash `f03f8dd1…458a` in all 16 briefs carrying it (appearance-2…8, appearance-6-rev, phase2…8, phase6-rev); phase2–8 content parentheses replaced by the current folder list + "only the folders this brief names; PitBull4 is Phase 6-rev's".

### Check 1 fix — gates (verdict lines)
- luacheck Core + ChatSetup + FUFDefaults + Castbars + PitBull4 + fixtures → `checked=202 failed=0` rc0
- core `cases=56 passed=56 failed=0` (52 → 56: +4 AceDB cases); castbars `16/16`; chatsetup `13/13`; fufdefaults `16/16`; pitbull4 `cases=6 passed=6` (first run 5/6: locale count 11 → 10, test fixed)
- `genregistry.py --check` → up to date (49640 bytes) rc0; tocdeps Core + PitBull4 → `unresolved=0 … duplicates=0` rc0
- `build.py` ×2 → `built folders=5 files=328 zip_entries=330`, sha256 `f03f8dd1353b34744b2220ac9a4aab0294ad41769b79a2d888f4e1ca142d458a` both
- banned-lexicon scan of all briefs + compare doc: 1 hit 「당해」 at `phase7.md:37`, not in this change (git diff has no hit) → left, DQ 11

### Decision Queue (added)
10. `Defaults/Dominos.lua:4–6`, `Defaults/Hekili.lua:3–5`, `Defaults/Prat-3.0.lua:3–5` still say "Core fills the profile that profileKeys names" — now inaccurate (comment only); outside the granted boundary.
11. Pre-existing banned word 「당해」 in `Collection/codex-briefs/phase7.md:37` (not from this change).
12. Behaviour change for Phase 3/4/8: a user who installs over existing Dominos/Prat/Hekili profiles gets no defaults (state `existing-profile-kept`); only first installs and new characters/profiles get them. Their briefs move SVs aside, so their expected `applied fill-missing … 1` lines stand.
13. Brief content notes for phase2–8 lost the "defaults file X included" remark (the folder list replaced it).

## Recheck 1 fix (TRIAGE "Recheck 1" N1: first look waited on the player key)

Read: TRIAGE_phase6-rev.md Recheck 1 (whole); `Defaults.lua` 40–72, 210–266, 284–345 (current); `Core.lua` 167–189 (PlayerKeys: name/realm or regional surname may be unknown at ADDON_LOADED → nil, reason).

| # | Place | Verdict |
|---|---|---|
| 1 | `Defaults.lua` pre-pass 293–300 (look only when `inspectAce` returns a table, i.e. after the key exists) | fix: take a key-free snapshot at the first look (SV nil?; profileKeys entries; `<SV>.profiles` names; the namespace's profile names) |
| 2 | `inspectAce` 212–242 (newness from live SV) | fix: newness from the snapshot (char entry in snapshot profileKeys, else resolved token; existing = SV was not nil and (snapshot entry exists or snapshot profiles / namespace profiles hold the profile)); location/target key from the live profileKeys entry (AceDB may have set it meanwhile), else the resolved token |
| 3 | AceDB loop 316–327 (`look.existing`) | fix together (use the snapshot result) |
| 4 | header 43–64 | fix: first look no longer needs the key; late key writes into the live tables AceDB made (addon may read them only after /reload) |
| 5 | plain path, `createAce`, FillMissing | no impact / check only |
| 6 | tests: AceDB cases (new: late key fresh install written, late key existing install kept, late key namespace under existing profile kept); `player_key_regional_without_rules_api_waits` and `defaults_player_keys_unavailable_logged` (waiting state) | fix together / check |
| 7 | briefs: ZIP hash (all occurrences) | fix after build |
| 8 | applied-before-newness order (outside-map minor) | not fixed (master: final report) |

### Recheck 1 fix — edits
1. `Defaults.lua`: header 56–70 (snapshot rule, key-free first look, late key writes into the live AceDB tables); new `names` 218–225, `snapshotAce` 229–243 (SV nil?, profileKeys copy, `<SV>.profiles` names, namespace profile names — no player key), `profileName` 245–248; `inspectAce(target, snap)` 252–273: location/key from the live profileKeys entry (else resolved token), `existing` from the snapshot only; pre-pass 326–330 stores `snapshotAce` for every AceDB target before any write; loop passes the snapshot (334) and uses `info.existing` (349); `fresh` comment 91.
2. `tests/core/run.py`: helper `late_key_session` (player name unknown at ADDON_LOADED → waiting; the addon's AceDB:New simulated as profileKeys entry + empty profile; key known at PLAYER_LOGIN) and `acedb_new_warrior`; cases `defaults_acedb_late_key_fresh_install_written`, `defaults_acedb_late_key_existing_install_kept`, `defaults_acedb_late_key_namespace_under_existing_profile_kept`.
3. Briefs: ZIP hash `554837ac…cae7` (current in the 16 briefs) → new hash, all 16 occurrences.

### Recheck 1 fix — gates (verdict lines)
- luacheck Core + ChatSetup + FUFDefaults + Castbars + PitBull4 + fixtures → `checked=202 failed=0` rc0
- core `cases=59 passed=59 failed=0` (+3 late-key cases); castbars 16/16; chatsetup 13/13; fufdefaults 16/16; pitbull4 6/6
- `genregistry.py --check` → up to date (49640 bytes); tocdeps Core + PitBull4 → `unresolved=0 … duplicates=0`
- `build.py` ×2 → `built folders=5 files=328 zip_entries=330`, sha256 `81b23bd0c40ec4194ab989168878f55ecf3fb25f0cd8c646c91b5f5de1f47ef7` both
- briefs: old hash occurrences 0, new hash in 16 files (16 occurrences)

### Decision Queue (added)
14. Late key on a fresh install: the values land in tables the addon's AceDB already read during its init (e.g. PitBull4 may already have made its own default units, since `made_units` was still unset) — they take effect from the next /reload, and PitBull4's own default units can sit beside the Devil ones (koKR names coincide, so fill-missing keeps one set). Not testable here; the brief's first-login status line shows the state.

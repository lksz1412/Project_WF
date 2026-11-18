# Design — Phase 20 Step 32: settings save and restore

Author: A1 analysis sub (design only; no addon code). Implementer: A2 coder, Step 33. Review: 3 rounds (plan Test Plan line 428).

Tiers used on every claim: **[C]** confirmed (file:line given) · **[NF]** not found in repo sources · **[I]** inferred · **[U]** unverified (needs the game; listed for the Codex verification brief). "A1 judgment" marks my own choices. User decisions are cited by R-number only.

Paths: `PM/` = `Collection/upstream/profilemanager-ProfileManager_v4.0.zip/ProfileManager/`; `Core/` = `Collection/AddOns/!DevilForever_Core/`; `RV42/` = `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/Reflux/`; `PLAN` = `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`; `LDS` = `Collection/upstream/Dominos-12.0.4/Dominos/libs/LibDualSpec-1.0/LibDualSpec-1.0.lua`.

---

## 0. What the plan asks (inputs, quoted)

- Row 20 [C] PLAN:232 — 「등록 표의 저장 변수만 다루는 범위 복원. 세 겉보기(FHD·QHD·UHD) preset 으로 되돌리기도 복원 범위다 … 공통 배치·외관 설정과 직업·특성별 설정을 나눠 저장하고 특성이 바뀌면 그 profile 로 전환한다(features F68). 설치되지 않은 애드온 항목은 지우지 않고, 알 수 없는 판의 데이터는 조용히 초기화하지 않는다. 키 설정과 게임 설정 … 사용자가 고를 때만 되돌리며 … 매크로는 다루지 않는다(R14–R17).」
- Why PM [C] PLAN:286 — 「ProfileManager 가 우리 애드온들을 얼마나 지원하는지는 아직 모른다 — Step 32 에서 `Providers.lua`·`Addons.lua` 를 읽고 모자라면 Reflux 의 기전을 참고해 그 부분만 만든다.」 Assumption still open [C] PLAN:471.
- Interfaces [C] PLAN:407 「등록된 변수만 사본·복원한다. 없는 애드온 항목은 남겨 둔다. 판이 다른 데이터는 사용자에게 알리고 건드리지 않는다. 세 겉보기 preset 으로 되돌리기를 고를 수 있다(R107 ⑥)」 · PLAN:408 「Core 는 등록된 편집 항목의 값을 프레임별 편집값으로 내주고 … 전투 중에는 보호된 프레임을 바꾸지 않고 전투가 끝나면 적용한다」.
- Review targets [C] PLAN:428 — 「등록 표의 변수만 다루는지, 없는 애드온 항목 보존, 판이 다른 데이터를 지우는지 (적대), 공통/직업·특성별 나눔과 전환, 세 겉보기 preset 으로 되돌리기, 사용자가 고르지 않은 범위의 키·게임 설정·필터 불변·매크로 미접촉」. Codex check [C] PLAN:451 — 「실제 저장·복원·재접속, 특성 전환, 세 겉보기 preset 으로 되돌리기」.
- Reflux ground truth [C] PLAN:122 — 「전역 전환이 AceDB 전체와 다른 변수까지 바꾸고 ReloadUI 를 부르며, save 가 비어 있는 항목을 지운다 — 그대로는 범위 복원으로 안전하지 않다」 (Codex record; re-confirmed from source in §2.3).
- Constraints [C] PLAN:141–143 (R44·R107 ⑥ no integrated editor; Core per-frame edit values stay as the read contract), PLAN:150 (R101 fewer addons). Non-goals [C] PLAN:295–306: no macro move/convert, no key auto-assignment (PLAN:304), no user chat filter / uiScale / full WTF reset (PLAN:300).
- Required bundle [C] PLAN:312 — 「설정 저장·복원(Phase 20) … 폴더는 각자 따로 두고 manifest 에서 필수로 표시한다.」
- User decisions: R101 「애드온은 적을수록좋으니까」 [C] `Claude/results/REQUEST_LEDGER_phase8.md:14`; R107 ⑥ 「UI 는 유저가 AI를 써서 수정하게 만들자. 대신 AI로 처음부터 FHD, QHD, UHD 세가지 겉보기로 만들기로하고」 [C] same file :20; R109 (Codex on hold, Claude continues) [C] `REQUEST_LEDGER_phase19.md:7`.

---

## 1. ProfileManager v4.0 — what it is and what it covers

### 1.1 Mechanism (confirmed from source)

PM is a **profile switcher**, not a settings snapshot tool.

| Part | What it does | Source |
|---|---|---|
| TOC | `## Interface: 120105, 16001`, one SV `ProfileManagerDB` (account), slash `/pm` | [C] PM/ProfileManager.toc:1,6 · PM/Commands.lua:3 |
| Provider API | `addon:RegisterProviderDef({id, detect, buildProvider})`; a provider object has `GetProfiles`, `GetCurrentProfile`, `SetProfile`/`ApplyProfile`, `ExportProfile`, `ImportProfile`, `DeleteProfile`, optional `RequiresReload` | [C] PM/Providers.lua:593–619, 2962–2999 · PM/Presets.lua:92–108 |
| Extensible? | Yes: `ProfileManager:RegisterProviderDef` is a public method on the global `ProfileManager`; `TryRegisterAllProviders` runs on every `ADDON_LOADED`/`PLAYER_LOGIN` | [C] PM/Core.lua:1 · PM/Providers.lua:595–601, 3117–3136 |
| AceDB scan | Every AceDB-3.0 database in `LibStub("AceDB-3.0").db_registry` (not a namespace) becomes provider `acedb:<SV name>`; operations = switch / export / import / delete **named profiles** | [C] PM/Providers.lua:541–591, 3060–3115 |
| "Preset" | `{name, addons = {[providerId] = profileName}, savedAt}` — only the **names** of the current profiles of every registered provider, not their contents | [C] PM/Presets.lua:61–71, 110–123 |
| Apply preset | For each provider: `SetProfile(profileName)`; refuses in combat; collects `RequiresReload` and then offers a Reload popup | [C] PM/Presets.lua:125–157 · PM/Commands.lua:231–242 · PM/UI.lua:1213–1224 |
| Content copy | Only through export strings (LibSerialize + LibDeflate, payload `{1, providerId, name, data, namespaces}`) and import, which always creates a **new** profile name | [C] PM/Providers.lua:49–95, 185–235, 270–362 |
| Keybinds | Reads every binding command (`GetNumBindings`/`GetBinding`, skips `HEADER_`), stores `{bound, unbound, set, savedAt}` per name in `ProfileManagerDB.keybindProfiles`; Load = for actions in the profile, clear their keys, bind the stored keys, `SaveBindings(current set)`; actions not in the profile keep their keys; refuses in combat | [C] PM/Keybinds.lua:18–22, 56–67, 225–261, 263–267, 324–335, 378–383 |
| Game settings | Reads `SettingsPanel.settings` (Game category set, keybinding category excluded, device CVars excluded), stores values per name in `ProfileManagerDB.gameSettingsProfiles`; Load = `C_CVar.SetCVar` / `setting:SetValue` for changed values only, may call `RestartGx`/`UpdateWindow`; refuses in combat | [C] PM/GameSettings.lua:13–21, 52–56, 96–138, 213–257, 315–319, 348–355, 409–414 |
| Addon sets | Saves/loads which addons are enabled per character (`C_AddOns.EnableAddOn/DisableAddOn` + `SaveAddOns`) | [C] PM/Addons.lua:109–176, 227–233, 270–275 |
| Macros | No macro API anywhere in PM (`CreateMacro`/`EditMacro`/`DeleteMacro`: 0 hits outside Libs) | [C] grep of PM/*.lua (work log) |
| Reload / reset | `ReloadUI` only from user actions: reload popup after a preset with `RequiresReload` (UI.lua:1213–1224), import wizard end (UI.lua:1634–1637), addon-set page button (UI.lua:3145–3147). "Delete unused profiles" deletes profiles in other addons on a user click (UI.lua:564–628). No reset of other addons' SVs. | [C] |
| Login automation | Only if the user configured it: new-character defaults (`newCharDefault`/`newCharKeybinds`/`newCharAddons`/`newCharSettings`) applied at the first login of a new character; per-character `charPresets[...].applyOnLogin` applied once | [C] PM/UI.lua:318–382 |
| SVs written | `ProfileManagerDB.{presets, settings, minimap, favorites, keybindProfiles, gameSettingsProfiles, addonSets, charPresets, knownChars, charClasses, charNames, newChar*}` | [C] PM/Core.lua:59–68 · PM/Presets.lua:40–46 · PM/Keybinds.lua:263–267 · PM/GameSettings.lua:315–319 · PM/Addons.lua:172–176 · PM/UI.lua:329–343 |
| UI | One window (6,316-line UI.lua), minimap/LDB icon, addon-compartment entry | [C] PM/Core.lua:8–57 · PM/UI.lua:3596, 4889 |
| Spec switching | None: no `ACTIVE_TALENT_GROUP_CHANGED` / `PLAYER_SPECIALIZATION_CHANGED` / `GetSpecialization` in PM | [C] grep of PM/UI.lua (work log) — [NF] in all PM files |

[U] Forever availability of PM's game-settings path: it needs the modern `SettingsPanel`/`Settings.GetSetting` (PM/GameSettings.lua:52–56). Repo sources do not show whether the Forever 1.60.1 client has them → 확인 필요 (Codex).

### 1.2 Coverage table — every registry addon with saved variables

Registry rows extracted from `Core/Registry.lua` with lupa (work log). "PM" = what PM can do with it.

| Folder (bundle) | Saved variable (scope / split) | PM support | Basis |
|---|---|---|---|
| `!DevilForever_Core` (required) | `DevilForever_CoreDB` (account / common) | No — plain table, not AceDB, no provider | [C] Core/Core.lua:212–234 · PM/Providers.lua:3060–3108 |
| `!KalielsTracker` (dropped R100) | `KalielsTrackerDB` (a/common) | Profile switch/export/import (explicit provider; AceDB scan suppressed for it) | [C] PM/Providers.lua:2336–2433, 3031–3033 |
| | `KalielsTrackerCache` (a/common) | No | [NF] |
| `Aurora` | `AuroraConfig` (a/common) | No — plain | [C] `aurora-12.1.5.4/Aurora/config.lua:338,407` |
| `BagBrother`, `Bagnon` (dropped R100) | `BrotherBags`, `Bagnon_Sets` | No (PM has Baganator only) | [C] PM/Providers.lua:3001–3004 |
| `Details` | `_detalhes_global` (a), `_detalhes_database` (c) | Switch between Details' own named profiles (`_detalhes_global.__profiles`, `active_profile`), export/import | [C] PM/Providers.lua:686–920 |
| | `__details_backup`, `__details_debug` (a) | No | [NF] |
| `Details_DataStorage` | `DetailsDataStorage` (a) | No | [NF] |
| `Details_EncounterDetails` | `EncounterDetailsDB` (c) | No | [NF] |
| `Details_Streamer` | `Details_StreamerDB` (a) | No | [NF] |
| `Details_Vanguard` | `_detalhes_databaseVanguard` (c) | No | [NF] |
| `DevilForever_ChatSetup` | `DevilForever_ChatSetupDB` (c) | No | [C] its TOC (no AceDB) |
| `DevilForever_FUFDefaults` | `DevilForever_FUFDefaultsDB` (a) | No | [C] its TOC |
| `DevilForever_StatusStrip` | `DevilForever_StatusStripDB` (a) | No | [C] its TOC |
| `Dominos` | `DominosDB` (a / **class**) | AceDB scan → switch named profile | [C] `Dominos/Dominos.lua:252–262` (`AceDB:New(dbName, defaults, UnitClass('player'))`) · PM/Providers.lua:541–591 |
| `ExperienceForever` | `ExperienceForeverDB` (a/common) | Listed by the AceDB scan, but EF keeps every setting in the AceDB `global` section, so switching profiles changes nothing → effectively No | [C] `ExperienceForever.lua:373` · phase19 work log `Claude/results/handoffs/phase19/iter_1/work_log-a2.md:21` |
| `ForeverThreat` (merged into Details, R107 ②) | `ForeverThreatDB` | No — plain | [C] `ForeverThreat/Core.lua:1543,1899` |
| `ForeverUnitFrames` | `ForeverUnitFramesDB` (a/common) | No — plain (`ForeverUnitFramesDB = ForeverUnitFramesDB or {}`) | [C] `ForeverUnitFrames/Core/Boot.lua:27` |
| `Grid2` | `Grid2DB` | AceDB scan → switch | [C] `Grid2/GridCore.lua:124` |
| `Hekili` | `HekiliDB` | AceDB scan → switch | [C] `Hekili/Options/Profile.lua:20` |
| `Mapster` (dropped R100) | `MapsterDB` | AceDB scan → switch | [C] `Mapster/Mapster.lua:36` |
| `Masque` (required) | `MasqueDB` | AceDB scan → switch | [C] `Masque/Masque.lua:182` |
| `PitBull4` (our fork) | `PitBull4DB` | AceDB scan → switch | [C] `Collection/AddOns/PitBull4/Main.lua:1389` |
| `Platynator` (dropped R107 ③) | `PLATYNATOR_CONFIG`, `PLATYNATOR_CURRENT_PROFILE` | Explicit provider → switch/export/import | [C] PM/Providers.lua:2435–2574 |
| | `PLATYNATOR_LAST_INSTANCE` | No | [NF] |
| `Prat-3.0` | `Prat3DB` (a) | AceDB scan → switch | [C] `Prat-3.0/addon/addon.lua:159` |
| | `Prat3CharDB`, `Prat3HighCPUPerCharDB` (c) | No — plain module data (history, scrollback) | [C] `Prat-3.0/modules/History.lua:128` · `modules/Scrollback.lua:77–82` |
| `ProfileManager` (required) | `ProfileManagerDB` | PM's own store | [C] PM/ProfileManager.toc:6 |
| `Quartz` | `Quartz3DB` | AceDB scan → switch | [C] `Quartz/Quartz.lua:54` |
| `SexyMap` | `SexyMap2DB` | No — own profile scheme (`SexyMap2DB.global`, string links) | [C] `SexyMap/SexyMap.lua:217–280` |
| `TipTac` (dropped R100) | `TipTac_Config` | AceDB scan → switch (via LibFroznFunctions) | [C] `TipTac/ttCore.lua:1829` |
| `Titan*` (not used, R107 ⑤) | `TitanAll`, `TitanSettings`, `TitanSkins`, `GoldSave`, `TitanUI_User_Slash` | No | [NF] |

[I] The AceDB scan works only for databases created through the same LibStub `AceDB-3.0` instance (LibStub keeps one instance per major version). Each addon embeds its own copy; LibStub keeps the highest minor. This is standard LibStub behaviour, not checked in the client.

**Keybinds and game settings** [C]: PM saves and restores both, and only when the user runs a save/load (commands `/pm save keybinds <name>`, `/pm apply keybinds <name>`, `/pm save settings <name>`, `/pm apply settings <name>` — PM/Commands.lua:142–156) or configured login automation (PM/UI.lua:349–380). Keybinds cover binding **commands** only (PM/Keybinds.lua:59–64); macros are never touched.

### 1.3 Coverage summary

- Of the 27 registry SVs that hold settings (§4.1 list plus the settings SVs of dropped addons), PM can switch named profiles for 14 SVs of 12 addons — 9 through the AceDB scan (Dominos, Grid2, Hekili, Mapster, Masque, PitBull4, Prat, Quartz, TipTac) plus Details (2 SVs), Platynator (2 SVs) and Kaliel's — and nothing for the other 13 (plain tables, EF's AceDB `global`, our own SVs, Titan, Aurora, SexyMap, FUF, ForeverThreat, Bagnon) [C] §1.2 rows.
- Even where it "supports" an addon, PM **does not keep a copy of the values**: a PM preset is a list of profile names (PM/Presets.lua:65–69). If the user changes the profile after saving, applying the preset brings back the name, not the old values.
- PM has no spec-change switching, no notion of registry scope (its preset captures every provider it found, including addons outside our collection — PM/Presets.lua:110–123), and no layout preset concept.
- What PM does cover fully: keybinds and game settings, user-chosen only.

---

## 2. Gap — what row 20 needs that PM does not provide

| Need (row 20 / PLAN:407) | PM | Gap |
|---|---|---|
| Restore that touches only registry SVs | Preset applies every provider it captured, including non-registry AceDB addons [C] PM/Presets.lua:110–123, 135–154 | Full: a registry-scoped mechanism is needed |
| Values restored, not only profile names | Names only [C] PM/Presets.lua:65–69 | Full: value snapshots are needed |
| Plain-table SVs (FUF, SexyMap, Aurora, ours) | No provider [C] §1.2 | Full |
| Entries of addons that are not installed stay | PM preset keeps unknown provider ids and skips them ("not loaded") [C] PM/Presets.lua:138–140 — good, but there is no value data to keep | New mechanism must keep entries and never drop them on save |
| Unknown-version data reported and left untouched | PM export payload has a format version only (`payload[1] ~= V` → "Bad version") [C] PM/Providers.lua:49, 90–92; no addon-version check | Full: per-entry addon version + compare at restore |
| Common layout/appearance part separate from per-class/per-spec part | No [NF] | Full |
| Automatic switch on spec change (F68) | No spec events [NF in PM] | Full — see §2.1 for what Forever offers |
| Keybinds and game settings only when the user chooses | Yes [C] §1.1 | None (use PM as-is; optional pass-through command, §6) |
| Macros never touched | Yes [C] | None; the new code must also call no macro API (test §8) |
| Three appearance presets (FHD·QHD·UHD) restore | No [NF] | Full: Core preset layer (§5) |

### 2.1 Spec change on Forever (F68) — what repo sources say

- [C] `LDS:71–77`: 「XXX ClassicExpansionAtLeast is always true in Forever, which uses Dual Specialization」 — for build 16000–19999 the library sets `isSpecBased = false`.
- [C] `LDS:89–93`: non-spec-based → `numSpecs = 2` (primary/secondary talent group).
- [C] `LDS:515–523` (Forever branch): `GetProfileSpecialization()` returns `C_SpecializationInfo.GetActiveSpecGroup()` when `GetNumSpecGroups() > 1`, else 0.
- [C] `LDS:535–541`: non-spec-based → registers `ACTIVE_TALENT_GROUP_CHANGED`.
- [C] `Collection/upstream/Hekili-v0.8.6/Hekili/Engine/Sim/Events.lua:386–394`: Hekili listens to `ACTIVE_TALENT_GROUP_CHANGED` and others, with the comment 「TRAIT_CONFIG_UPDATED = 1 -- Forever fires this one for spent points, not the two above (probe session W)」.
- [C] Dominos embeds and uses LDS on `DominosDB`: `Dominos/embeds.xml:10`, `Dominos/Dominos.lua:258–262`. Dominos_Config does not expose LDS options (grep: no `EnhanceOptions` in `Dominos_Config`, work log), so the user has no in-game switch to turn spec profiles on.
- [I] On Forever, "특성 전환" in daily play is the dual-spec talent-group swap (group 1 / 2). A respec that moves the dominant tree inside one group is a different event (`TRAIT_CONFIG_UPDATED`, per the Hekili comment) and rarely changes the bar layout.
- [U] Whether `ACTIVE_TALENT_GROUP_CHANGED` fires on a Forever dual-spec swap, and whether `GetNumSpecGroups`/`GetActiveSpecGroup` exist in the client: 확인 필요 (Codex item, §7).

**Design consequence (A1 judgment):** F68 = per talent group (1/2) AceDB profile for every `split = "class"` SV, switched by the addon's own LibDualSpec where present. No Core event handler for spec change in v1 (§4.6).

### 2.2 The ordering problem every restore must solve

- [C] AceDB strips defaults and empty tables at `PLAYER_LOGOUT` for every registered database (PM/Libs/AceDB-3.0/AceDB-3.0.lua:355–401).
- [C] Details rewrites its saved variables at logout (`Details222.SaveVariables.SaveConfig`, or sets both to nil on a full wipe): `Details/core/parser.lua:6950–6965`.
- [C] Addons build live tables from their SV at load (Details `loaddata.lua:19–27, 59–69`; AceDB `db.profile` sub-tables).
→ Writing new values into a live SV in the middle of a session is lost or mixed: the addon keeps using its old sub-tables and its logout code writes over them during the `/reload`.

### 2.3 What Reflux does (reference and list of problems to avoid)

All [C] from `RV42/Reflux.lua` (V42 Forever copy; upstream 1.17 differs only in API aliases and init — diff in work log):

| Reflux behaviour | Line | Problem for us |
|---|---|---|
| `switch`: `_G[k] = DeepCopy(v)` for every emulated SV, then `setAceProfile(arg)` on **every** AceDB database, then `ReloadUI()` | 407–434, 76–101 | Global: touches all AceDB addons, not a registry scope (PLAN:122) |
| Re-writes `_G[k]` again in its own `PLAYER_LOGOUT` handler | 422–432 | Depends on handler order against AceDB's and Details' logout writers (§2.2) |
| `save`: `RefluxDB.profiles[active] = {}` then copies each emulated SV; an SV that is nil now is simply absent | 446–457 | Drops entries of addons not loaded at save time (PLAN:122 「save 가 비어 있는 항목을 지운다」) |
| `cleardb` wipes everything | 443–445 | Unconfirmed destructive command |
| `addons`: enable/disable then `ReloadUI()` | 344–351 | Out of scope (addon enable state) |
| `DeepCopy` with cycle lookup, no metatables | 40–51 | Good pattern — reuse the idea (cycle-safe copy) |

What we take from Reflux: deep copy of plain data with a cycle table; per-SV emulation of non-AceDB addons. What we avoid: global AceDB switching, logout-time writes, destructive save, unconfirmed wipe.

---

## 3. Placement — options, trade-off, recommendation

| | (a) PM provider/extension in our addon | (b) Module inside `!DevilForever_Core` | (c) Small addon `DevilForever_Profiles` |
|---|---|---|---|
| Addon count (R101) | +0 new, but **requires PM** for the whole feature | +0 | +1 |
| Load-time restore (§4.4) | Impossible alone: PM loads after "D…" addons (alphabetical; [I]), so it cannot write Details'/Dominos'/Grid2's SV before they read it | Yes: Core loads first (`!` prefix — same assumption as Defaults, `Core/Defaults.lua:43–45`) and its single event frame runs handlers in a fixed order (`Core/Core.lua:110–129`) | Only if named `!DevilForever_Profiles`; then its handler order against Core's Defaults handler crosses two frames → 확인 필요 |
| `Defaults:Suppress` before Defaults acts | Late | Same frame, handler registered before Defaults' (TOC order) — deterministic in Core | Must suppress at its own ADDON_LOADED (works if it loads before targets) |
| Preset layer (needs a change to `Edit:Get`) | Not possible in PM | Natural: preset = a layer of Core edit values (`Core/Edit.lua:15–18, 233–244`) | Split across two addons (layer in Core, logic outside) |
| Core contract 「Core changes no frame」 (`Core/Core.lua:3`, `Core/API.lua:74`) | Unchanged | Still true for frames; Core gains "writes registered SVs at load after a user command" — wording change needed | Unchanged |
| Plan PLAN:312 「폴더는 각자 따로」 | PM folder kept | PM folder kept (keybinds/settings); the missing part sits in the Core folder | Matches literally |
| User can disable save/restore alone | n/a | No (Core is required) | Yes (but it is a required-bundle feature) |
| Code size | Adapter ~80 lines + all logic still needed elsewhere | ~1,100 lines Lua in Core (§9) | Same logic + TOC + duplicated helpers |

**Recommendation (A1 judgment): (b)** — put the missing part (snapshots, scoped restore, layout presets, spec-profile link, `/dfprofile` commands) in `!DevilForever_Core`, and keep ProfileManager **as-is** in the required bundle for keybinds and game settings (and its own profile switching, if the user wants it).

Why: (1) R101 — no new addon; (2) load-time restore and `Defaults:Suppress` need the earliest load and a fixed handler order, which only Core has without new assumptions; (3) layout-preset restore is a change to Core's edit layering anyway; (4) PM still covers the two parts it does fully (keybinds, game settings), which is "PM + only the missing part" (PLAN:232, 286). The cost is a wording change of Core's contract (Decision Queue 3). Option (a) is not viable for the restore engine; a PM provider adapter can be added later if the master wants `/pm apply all` to include our snapshots (Decision Queue 4).

---

## 4. Data model and restore mechanics

### 4.1 Registry extension (scope = "only registry SVs")

Today the registry holds `{name, scope, split}` per SV (`Core/API.lua:7–8`, `Collection/tools/genregistry.py:92–101, 270–277`). Restore needs two more facts per SV, kept in `registry_extra.json` and emitted by `genregistry.py`:

- `restore`: `"whole"` | `"profile"` | `"keys"` | `"skip"` — **default `"skip"` when absent** (A1 judgment: opt-in, so caches, history and run-once markers generated from TOCs are never touched; PLAN:403 ③ already says registration names the restore targets).
- `shape`: `"plain"` | `"acedb"` (needed for `profile`, and for preset fragments).
- `keys` (only with `restore = "keys"`): list of top-level keys restored; other keys untouched.

Generator rules (Step 33): `split = "class"` requires `shape = "acedb"` and `restore = "profile"`; `restore = "keys"` requires a non-empty `keys` list; unknown values stop the generator (same style as `genregistry.py:270–277`). `Registry.lua` entries gain `restore`, `shape`, `keys`.

Proposed classification (A1 judgment; master/user may change — Decision Queue 5):

| SV | restore | shape | Reason |
|---|---|---|---|
| `DevilForever_CoreDB` | `skip` (raw SV) | plain | Core's layout part (`edits`, `theme.active`, `preset.active`) is snapshotted separately (§4.2); its `defaults` bookkeeping must never roll back |
| `DevilForever_ProfilesDB` (new) | `skip` | plain | The snapshot store itself |
| `ProfileManagerDB` | `skip` | plain | PM's own store (keybind/settings profiles) |
| `DominosDB` | `profile` | acedb, split class | Per-class bars; §4.3 |
| `Grid2DB`, `HekiliDB`, `MasqueDB`, `PitBull4DB`, `Quartz3DB`, `Prat3DB`, `ExperienceForeverDB` | `whole` | acedb | Account-wide layout/settings |
| `ForeverUnitFramesDB`, `SexyMap2DB`, `AuroraConfig`, `DevilForever_StatusStripDB`, `Details_StreamerDB` | `whole` | plain | Settings tables |
| `_detalhes_global` | `keys` = `{"__profiles"}` | plain | Rest is data/logs (`exit_log`, caches) — [U] that every Details setting lives in `__profiles` |
| `_detalhes_database` | `keys` = `{"active_profile"}` | plain | Rest is combat history — [U] same |
| `DevilForever_ChatSetupDB`, `DevilForever_FUFDefaultsDB` | `skip` | plain | Run-once markers (ChatSetup header `DevilForever_ChatSetup/*.lua:1–30`, FUFDefaults header lines 1–24): rolling them back would re-run or block those steps |
| `Prat3CharDB`, `Prat3HighCPUPerCharDB`, `__details_backup`, `__details_debug`, `DetailsDataStorage`, `EncounterDetailsDB`, `_detalhes_databaseVanguard`, `KalielsTrackerCache`, `BrotherBags`, `GoldSave`, `PLATYNATOR_LAST_INSTANCE` | `skip` | — | Data, history, caches |
| SVs of dropped addons (Kaliel's, Bagnon, Mapster, TipTac, Platynator, Titan, ForeverThreat) | `skip` (absent → default) | — | Not shipped (R100, R107); add when an addon comes back |

Note [C]: the chat window split itself is client chat settings, not an SV (ChatSetup header lines 1–8 use the chat API), so no snapshot can restore it; this is outside this mechanism and matches the non-goal on chat filters (PLAN:300).

### 4.2 Snapshot store — new SV `DevilForever_ProfilesDB`

Declared in the Core TOC (`## SavedVariables: DevilForever_CoreDB, DevilForever_ProfilesDB`). Separate from `DevilForever_CoreDB` because CoreDB's layout part is itself restored, and to keep a large store away from Core's small state (A1 judgment).

```lua
DevilForever_ProfilesDB = {
  schema = 1,
  snapshots = {                         -- at most MAX_SNAPSHOTS (10) user names + "__before-restore"
    [name] = {
      name = name, savedAt = <time()>, schema = 1,
      savedBy = {char = <AceDB char key>, realm = ..., class = <token>, group = <talent group 1|2|0>},
      core = {edits = <copy>, theme = <name|nil>, preset = <name|nil>},       -- layout part of Core
      common = {                                                               -- split = "common"
        [svName] = {folder = ..., scope = "account"|"character", restore = "whole"|"keys",
                    keys = {...}|nil, char = <char key, character scope only>,
                    version = <addon Version metadata>, registryVersion = <registry version>,
                    savedAt = <time()>, carried = <true when kept from an older save>,
                    data = <cycle-safe deep copy>},
      },
      class = {                                                                -- split = "class"
        [classToken] = {
          [svName] = {folder = ..., version = ..., registryVersion = ..., savedAt = ...,
                      char = <char key>, profileKey = <profile name for this char>,
                      lds = {[1] = <profile>|nil, [2] = <profile>|nil, enabled = bool}|nil,
                      profiles = {[profileName] = <copy of sv.profiles[profileName]>},
                      namespaces = {[ns] = {[profileName] = <copy>}}},
        },
      },
    },
  },
  pending = nil | {action = "save"|"restore"|"preset", name = ..., parts = {core=bool, common=bool, class=bool},
                   only = <folder>|nil, char = <char key>, requestedAt = <time()>},
  last = {action = ..., name = ..., at = ..., lines = {<report lines>}},   -- last result, shown by /dfprofile status
}
```

- **Deep copy** (new `Core.CopyData`, A1 judgment): plain data only (string/number/boolean keys and values, tables); functions, userdata and threads dropped and counted; a table met twice on the current path is dropped and counted (cycle guard, pattern of `RV42/Reflux.lua:40–51` and `PM/Providers.lua:97–125`). Metatables are not copied — AceDB defaults that live in metatables are not stored, which is what AceDB itself writes to disk (`AceDB-3.0.lua:355–401`). `Core.CopyTable` (`Core/Core.lua:17–23`) has no cycle guard, so it is not reused for foreign data.
- **Version**: `C_AddOns.GetAddOnMetadata(folder, "Version")` when the function exists (used by PM, `PM/Addons.lua:25`; [U] on Forever), else the registry `version` field. Both are stored; the compare (§4.5) uses the first that both sides have.
- **Size** [I]: settings SVs are tens of KB of SV text each; one snapshot with the classification above is estimated at 100–600 KB, ten snapshots ≤ ~6 MB. Details data is excluded by `keys`. [U] the client's practical SV size/load-time limits: 확인 필요 in the Codex brief (measure file size of `DevilForever_ProfilesDB` after 3 snapshots). Bound: `MAX_SNAPSHOTS = 10` (A1 judgment); `/dfprofile list` prints per-snapshot node and byte estimates (a walk that counts characters of keys/values).
- **Unknown schema** (A1 judgment): if `DevilForever_ProfilesDB.schema` (or a snapshot's `schema`) is greater than the code knows, the module goes read-only for that data: no save, no restore, no rewrite, a status line says so. It never resets the table. A value of the wrong type at the root is kept on disk (session-only table used), the same rule as Core's DB (`Core/Core.lua:217–232`).

### 4.3 Common vs class/spec parts

- **common** = every registry SV with `split = "common"` and `restore ≠ "skip"` + Core's layout part (`core`). Account-scope SVs restore on any character; character-scope SVs restore only on the character whose key is stored (others: "other character — untouched").
- **class** = every registry SV with `split = "class"` (today only `DominosDB`, [C] registry extraction). Stored per class token, at **AceDB profile level**, not whole SV: the profile this character uses (`sv.profileKeys[charKey]`, else the addon's default profile — Dominos: localized class name, [C] `Dominos/Dominos.lua:255`) plus the profiles LibDualSpec maps for this character (`sv.namespaces["LibDualSpec-1.0"].char[charKey][1|2]`, [C] `LDS:174–209, 270–274`), each with its namespace profiles. Restore writes only those profiles and this character's `profileKeys`/LDS entry; other classes' profiles in the same account SV are untouched. Restore on a different class token: "class part is for <token> — untouched".
- A snapshot always records both parts; restore picks `all` (default), `common`, `class` or `only <Folder>` (§6).

### 4.4 How values are written — at load time, after one `/reload`

Decision (A1 judgment, from §2.2 and §2.3): **no live writes into other addons' SVs.** Both save and restore are two-phase:

1. The command (out of combat) validates, prints the plan, writes `pending` into `DevilForever_ProfilesDB`, and on `/dfprofile go` calls `ReloadUI()`.
2. In the next session, inside Core's single event frame:
   - **Core ready** (Core's own `ADDON_LOADED`, `Core/Core.lua:263–268`): read `pending`. Check `pending.char == current char key` and `time() - requestedAt <= PENDING_MAX_AGE` (600 s; A1 judgment). If not, keep nothing, clear `pending`, report why. For a restore: call `Core.Defaults:Suppress(folder, "profile restore")` for every folder that will be written (`Core/Defaults.lua:479–501`). Apply Core's layout part (`edits`, theme, preset) directly to `DevilForever_CoreDB` before any `readyCallbacks` reader sees it.
   - **Target `ADDON_LOADED`** (Profiles handler registered before Defaults' handler — TOC order `Edit.lua` → `Profiles.lua` → `Defaults.lua`; `Core:On` runs handlers in registration order, `Core/Core.lua:112–129`):
     - *save*: copy `_G[sv]` (disk state written by the previous logout) into the snapshot.
     - *restore*: version check (§4.5); AceDB too-late check: if `LibStub("AceDB-3.0", true)` has a database in `db_registry` whose `sv == _G[svName]` already, the addon read its data first → do not write, report "too late". Otherwise copy the current `_G[sv]` into the `__before-restore` snapshot entry, then write: `whole` → `_G[sv] = CopyData(entry.data)`; `keys` → for each listed key `sv[key] = CopyData(entry.data[key])` (nil when the snapshot had none); `profile` → `sv.profiles[p] = copy`, `sv.namespaces[ns].profiles[p] = copy`, `sv.profileKeys[charKey] = entry.profileKey`, LDS char entry; creating missing tables.
   - **First `PLAYER_ENTERING_WORLD`**: finalize. Entries of addons that did not load: *save* → carry the old entry of the same name forward (`carried = true`), never drop it; *restore* → "not loaded — kept in snapshot, SV not created". Clear `pending`, store `last`, print the report.

Why load time (summary): the addon reads the restored table first; no detached live tables; no logout writer can overwrite it; the snapshot captures the canonical disk state including what Details writes at logout. Cost: one `/reload` per save and per restore. Assumption shared with Defaults: Core's handler for a target's `ADDON_LOADED` runs before the target's own (`Core/Defaults.lua:43–45`) — [U], Codex item; the AceDB too-late check turns a violation into a reported skip for AceDB targets.

`Defaults:Suppress` is per session (`Core/Defaults.lua:479–488`); restored folders are suppressed in the session where the restore lands. Later sessions see the defaults version already recorded (`applied`) or the profile existing (`existing-profile-kept`), so Defaults never re-applies over restored data (`Core/Defaults.lua:72–77, 346–356`) [C].

### 4.5 Version mismatch, missing addons, combat

- **Version mismatch** (PLAN:407): entry version ≠ current version → SV untouched, report "saved <v1>, installed <v2> — untouched". No force option in v1 (Decision Queue 9).
- **Snapshot entry of the wrong type** (data not a table where `whole`/`profile` expects one) → untouched, report.
- **Addon not installed / not loaded** → snapshot entry kept, SV not created, report. Saving under an existing name **merges**: entries of addons not loaded now are carried from the old snapshot (fixes the Reflux save problem, `RV42/Reflux.lua:451–457`).
- **SVs outside the registry or with `restore = "skip"`** → never read for a save, never written.
- **Combat**: every command that saves, restores, switches a preset or links spec profiles refuses while `InCombatLockdown()` (Core helper `Core.InCombat`, `Core/Core.lua:133–135`): "nothing changed". `/dfprofile go` refuses in combat. Load-time writes are not protected actions and happen during the loading screen. Preset Core-layer changes go through `Edit` (queued in combat, `Core/Edit.lua:152–160`).
- **Undo**: the `__before-restore` snapshot holds the pre-restore disk state of every SV that was written; `/dfprofile restore __before-restore` undoes the last restore. It is replaced by the next restore (one slot; A1 judgment).

### 4.6 Spec profile link (F68)

`Spec.lua` (A1 judgment, minimal): for each `split = "class"` SV, find its AceDB object (`db_registry` entry with `db.sv == _G[svName]` and no `db.parent` — pattern of `PM/Providers.lua:3071–3074`, `RV42/Reflux.lua:86–91`).

- If the object has the LibDualSpec mixin (`SetDualSpecEnabled`, `SetDualSpecProfile`, `GetDualSpecProfile` — [C] `LDS:167–221`): `/dfprofile spec link` = `db:SetDualSpecEnabled(true)` (first time; LDS then maps both groups to the current profile, `LDS:174–185`) and `db:SetDualSpecProfile(db:GetCurrentProfile(), currentGroup)`. From then on **LibDualSpec itself** switches the profile on `ACTIVE_TALENT_GROUP_CHANGED` (`LDS:213–221, 526–541`). `/dfprofile spec off` = `db:SetDualSpecEnabled(false)`.
- `/dfprofile spec new` (out of combat): create profile `<current> (2)` as a copy of the current one for the other group and link it (AceDB `db:SetProfile(new)` + `db:CopyProfile(old)`; Dominos reacts through its own `OnProfileChanged` callback, [C] `Dominos/Dominos.lua:264–269`).
- Without LibDualSpec: report "spec profiles not supported for <SV>"; no Core event handler in v1 (no such SV today).
- Current group shown from `LibStub("LibDualSpec-1.0", true).currentSpec` ([C] `LDS:50, 526–527`), so Core calls no talent API itself.
- [U] Forever behaviour of the swap event and of Dominos' bar update on profile change — Codex item.

---

## 5. Layout preset restore (R107 ⑥)

### 5.1 Layer model

`Edit:Get(frameKey)` today: field token → registry item default → stored edit (`Core/Edit.lua:15–18, 233–244`) [C]. New order (A1 judgment):

**token → registry default → active preset value → stored edit (user/AI)**

- `DevilForever_CoreDB.preset = {active = <name>|nil, fragments = {[presetName] = {[targetKey] = <fragment version>}}}` (added to `DB_LAYOUT`, `Core/Core.lua:220`; `FillMissing` adds it to old DBs).
- `Core.Presets:Register(def)` → number of kept values. `def`:
  ```lua
  { name = "uhd", screen = {3840, 2160}, uiScale = <number|nil>,
    edits = { ["<frame key>"] = {position = {...}, size = {...}, font = {...}, color = {...}, rows = n, spacing = n} },
    fragments = {
      { folder = "ExperienceForever", savedVariable = "ExperienceForeverDB", section = "global",
        addonVersion = "2.0.4", version = 1, values = { barHeight = 14, ... } },
      { folder = "Quartz", savedVariable = "Quartz3DB", section = "profile", profile = "$char",
        namespace = nil, addonVersion = "3.8.0", version = 1, values = {...} },
    } }
  ```
  Validation: each `edits` value through `Edit:Validate` (registered frame key, field, range — `Core/Edit.lua:114–120`); bad values dropped and logged (the `Theme:RegisterSet` rule, `Core/Theme.lua:71–94`). Each fragment: `folder` in the registry, `savedVariable` one of its SVs, `section` ∈ `root | global | profile`, `profile` token as Defaults (`$char`, `$class`, `$className`, `$realm`, literal — `Core/Defaults.lua:169–175`), `values` a table.
- `Core.Presets:GetValue(frameKey, field)`, `:GetActive()`, `:List()`.

### 5.2 "Restore preset X" (`/dfprofile preset X`)

1. Refuse in combat.
2. Core layer (live, no reload): for every frame key in X's `edits`, `Edit:Clear(frameKey)` (drops the AI-edited values for those frames only; other frames keep their edits — A1 judgment, Decision Queue 11); set `preset.active = X`; fire `Edit` listeners for every (frameKey, field) of the old and new preset so appearance code re-reads `Edit:Get` (listener contract `Core/Edit.lua:20–23`). In combat these would queue like Edit changes (they cannot, the command refuses).
3. Addon fragments (need a reload): write `pending = {action = "preset", name = X}`; at load, for each fragment, at its target's `ADDON_LOADED` (handler registered **after** Defaults' — TOC places `Presets.lua` after `Defaults.lua` — so Defaults' first-look snapshot of an AceDB target is taken before any fragment write): version check against `addonVersion` (mismatch → skip, report); `Core.WriteOver` the `values` into the section (`Core/Core.lua:192–208`: replaces listed keys, keeps the rest); record `fragments[X][targetKey] = version`. Prints "reload to apply addon values: <folders>"; `/dfprofile go`.

### 5.3 First install

- At Core ready with no `preset.active` (A1 judgment): choose by `GetPhysicalScreenSize()` height (≥ 2000 → `uhd`, ≥ 1400 → `qhd`, else `fhd`) when the function exists ([I] used by `Dominos_Config/overlay/dragFrame.lua`, Forever presence [U]); else `uhd` (R21: user screen is 4K, PLAN:120). Only registered names are chosen; none registered → no preset.
- Fragments of the active preset not yet recorded are applied in the same session only to **fresh** targets (SV nil at first look): AceDB targets at their `ADDON_LOADED` (after Defaults' handler), plain targets at the first `PLAYER_ENTERING_WORLD` with `WriteOver` (the Defaults rule for fresh plain SVs, `Core/Defaults.lua:22–26`). A target that already has data is not written: status "existing settings kept — `/dfprofile preset <name>` applies preset values". This keeps the "never overwrite user values" contract of PLAN:403.
- Rule checked by a Step 33 test: fragment keys and Defaults keys of the same SV are disjoint (fragments = appearance values, Defaults = functional values), so the order between them cannot hide a value.

### 5.4 Interface Codex delivers presets in

Already fixed for Codex [C] `Collection/codex-briefs/appearance-2-layouts.md:26–29`: `layouts/<fhd|qhd|uhd>.lua` returning `{name, screen, uiScale, edits = {[frame key] = {...}}}` with Edit.lua value shapes; per-addon value files `<addon>-profile.fragment.<fhd|qhd|uhd>.lua`; for EF `experienceforever-global.fragment.<fhd|qhd|uhd>.lua` with `ExperienceForeverDB.global` keys ([C] `appearance-19.md:29–30`, 「넣는 길은 Claude 가 정한다」).

Additions needed (brief addendum, later step — Decision Queue 13):
- Each fragment file returns `{folder, savedVariable, section = "root"|"global"|"profile", profile = <token>|nil, namespace = <name>|nil, addonVersion = <Version the values were made against>, version = <integer ≥ 1>, values = {...}}`.
- Codex files keep `return {...}`. Claude's integration wraps each layout and its fragments into one Core file `Core/Presets/<name>.lua` calling `DevilForever_Core.Presets:Register({... , fragments = {...}})`, listed in the Core TOC after `Presets.lua`. Reason: preset data must be registered before the target addons load (Details loads before any `DevilForever_Appearance` folder alphabetically, [I]), so it cannot live in Codex's appearance addon.

### 5.5 Experience Forever and other AceDB-`global` addons

[C] Core Defaults reach only `profiles[...]` of AceDB targets (`Core/Defaults.lua:47–55`) — EF's values live in `ExperienceForeverDB.global` (phase19 work log :21–22; TRIAGE_phase19.md:4). The preset fragment target `section = "global"` writes there with `WriteOver`, at load time, with the version check. This closes the phase19 open point (phase19 work log :62, 「넣는 길 … integration step」). Same route for any addon whose values are a plain table (`section = "root"`).

---

## 6. User interface without an editor (slash commands only)

`/dfprofile` (short `/dfp`; no conflict found in repo sources — precedent `/dfstatus`, `DevilForever_StatusStrip/StatusStrip.lua:693`). Text only, no window, no popup (A1 judgment; appearance-neutral). Every changing command prints what it will do; nothing reloads until `go`.

| Command | Effect |
|---|---|
| `/dfp` or `/dfp help` | List commands |
| `/dfp status` | Active preset, pending action, last result lines, spec link state |
| `/dfp list` | Snapshots: name, date, saving character/class, entries, size estimate |
| `/dfp show <name>` | Per entry: folder, part, installed?, version match?, would write / would skip and why (dry run) |
| `/dfp save <name>` | Pending load-time save (merge into an existing name); then `/dfp go` |
| `/dfp restore <name> [all|common|class|only <Folder>]` | Pending restore of the chosen part; then `/dfp go` |
| `/dfp go` | `ReloadUI()` when something is pending |
| `/dfp cancel` | Clear pending |
| `/dfp delete <name>` | Delete one snapshot (asks `/dfp delete <name> yes`) |
| `/dfp preset` / `/dfp preset <name>` | List presets / restore preset `<name>` (§5.2) |
| `/dfp spec` · `spec link` · `spec new` · `spec off` | §4.6 |
| `/dfp keys save|load|list <name>` · `/dfp game save|load|list <name>` | Thin pass-through to PM: `ProfileManager.Keybinds:SaveProfile/UpdateProfile/LoadProfile/GetProfileNames` ([C] `PM/Keybinds.lua:301–383`) and `ProfileManager.GameSettings` ([C] `PM/GameSettings.lua:325–414`); `IsAvailable()` checked first; PM absent → "ProfileManager not loaded". Only on this explicit command (A1 judgment; Decision Queue 2) |

Strings follow the koKR client in Step 33 (Core has no locale table today; A2 decides whether to add `L` like StatusStrip's).

---

## 7. Safety — Test Plan line 428 checks

| PLAN:428 item | How the design meets it | Test (§8) | Game check (Codex) |
|---|---|---|---|
| Only registry SVs touched | Engine iterates `Core:GetSavedVariables()` only, `restore ≠ "skip"`; Core layout part only `edits/theme/preset` | T1, T2 | — |
| Missing addons preserved | Save merges (`carried`); restore skips without creating SVs; snapshot entries never deleted except by `/dfp delete` | T3, T4 | uninstall one addon, restore, reinstall |
| Version mismatch (adversarial: is data erased?) | Mismatch → untouched; unknown schema → read-only, never reset; wrong type → untouched | T5, T15, T16 | — |
| Common vs spec split and switch | `common`/`class` parts; class at profile level per class token; LDS link | T11, T12, T25 | dual-spec swap changes Dominos bars |
| Presets | Layer order; restore clears only preset frames' edits; fragments version-checked, load-time | T18–T24, T27 | FHD/QHD/UHD restore after AI edits |
| Keys, game settings, filters, macros untouched unless chosen | New code calls no binding/CVar/chat-filter/macro API (static scan); PM only through `/dfp keys|game` | T26 | keybinds unchanged after restore |
| Never in combat | All commands refuse in combat | T13 | — |
| Load order assumption | AceDB too-late detection → reported skip | T8 | restore + reload actually changes values |

Codex verification items for the Phase 20 brief (later step): handler order (restore visible after reload, for Details, Dominos, Grid2, SexyMap); `ACTIVE_TALENT_GROUP_CHANGED` and LDS switch on Forever; `C_AddOns.GetAddOnMetadata` and `GetPhysicalScreenSize` exist; PM `/pm save settings` available (SettingsPanel); `DevilForever_ProfilesDB` file size after 3 snapshots; keybinds identical before/after a restore; macros count unchanged.

---

## 8. Test plan for Step 33 (pure Lua, lupa, fake SV data)

Extend `Collection/tests/core/run.py` (Session model: stubs, SVs from Python, `load_addon` fires `ADDON_LOADED` with Core's handler first and a self-fill stub after — `run.py:33–70, 88–186`). New stubs: `C_AddOns.GetAddOnMetadata` from a Python dict; `time()` controllable; `ReloadUI` records a call; fake `LibStub` with `AceDB-3.0.db_registry` and a fake LDS mixin that records calls; fake `ProfileManager.Keybinds/GameSettings` that record calls; a `print` sink. Fixture registry gains `restore`/`shape`/`keys` and a class-split AceDB SV; fixture preset file.

| # | Case | Expect |
|---|---|---|
| T1 | registry scope | non-registry `OtherDB` and `restore="skip"` SV unchanged after save+restore |
| T2 | Core layout part | `edits/theme/preset` restored; `defaults.applied` unchanged |
| T3 | save merge keeps missing addon | old entry carried, `carried=true` |
| T4 | restore with addon not loaded | entry intact; SV global still nil; report line |
| T5 | version mismatch | SV unchanged; report has both versions |
| T6 | write before addon reads | self-fill stub sees restored values |
| T7 | Defaults suppressed | `GetStatus(folder).suppressed` set; no defaults write |
| T8 | AceDB too late | db already in `db_registry` → no write; report |
| T9 | before-restore backup and undo | undo restores pre-restore disk state |
| T10 | character-scope SV on another char | untouched |
| T11 | class part profile level | only this char's profile(s) + profileKeys written; other class profiles untouched; other class token → skip |
| T12 | `common` vs `class` selection | the other part untouched |
| T13 | combat | every command refuses; no pending |
| T14 | pending other char / too old | not applied, cleared, reported |
| T15 | unknown schema | read-only; table unchanged byte-for-byte |
| T16 | wrong-type entry | untouched, reported |
| T17 | copy safety | cycle, function, userdata dropped and counted; no error |
| T18 | preset register validation | unknown frame key / out of range dropped and logged |
| T19 | layer order | token < registry default < preset < edit in `Edit:Get` |
| T20 | preset restore | clears edits of preset frames only; listeners fired |
| T21 | fragment first run, AceDB `global` fresh | written at `ADDON_LOADED`; existing SV kept + status |
| T22 | fragment restore | `WriteOver` listed keys only; version mismatch skipped |
| T23 | fragment plain fresh | written at first `PLAYER_ENTERING_WORLD`, not before |
| T24 | Defaults then fragment | new AceDB profile gets both; Defaults state `applied` |
| T25 | spec link | fake LDS gets `SetDualSpecEnabled(true)`, `SetDualSpecProfile(cur, group)`; no LDS → message |
| T26 | forbidden APIs | source scan of new files: no `SetBinding`, `SaveBindings`, `LoadBindings`, `SetCVar`, `C_CVar`, `CreateMacro`, `EditMacro`, `DeleteMacro`, `ChatFrame_AddMessageGroup`, `ChatFrame_RemoveMessageGroup`, `SetOverrideBinding`; fake PM records no call during boot/save/restore, one call on `/dfp keys load` |
| T27 | first-run preset pick | screen height → name; no API → `uhd`; none registered → nil |
| T28 | generator | `genregistry.py` accepts `restore/shape/keys`, rejects `split=class` without `acedb/profile`, `keys` without list |

Existing suites must stay green: core 61/61, castbars 16/16, chatsetup 13/13, fufdefaults 16/16, pitbull4 6/6, statusstrip 20/20 (phase19 work log :51–52, 74).

---

## 9. Files and size estimate for Step 33

| File | Change | Estimate |
|---|---|---|
| `Core/Profiles.lua` (new) | snapshot store, pending engine (save/restore at load), scoped parts, merge, version checks, backup/undo, report | 450–550 lines |
| `Core/Presets.lua` (new) | register/validate, active preset, restore, fragments (pending + first run), first-run pick | 250–320 |
| `Core/Spec.lua` (new) | AceDB lookup, LDS link/new/off | 80–120 |
| `Core/Commands.lua` (new) | `/dfprofile`, `/dfp`, PM pass-through | 180–240 |
| `Core/Core.lua` | `CopyData` (cycle-safe), `DB_LAYOUT.preset`, contract comment line 3 | +40 |
| `Core/Edit.lua` | preset layer in `Get` | +15 |
| `Core/API.lua` | header: Profiles/Presets/Spec API | +45 |
| `Core/!DevilForever_Core.toc` | SV `DevilForever_ProfilesDB`; order `Core, Registry, Theme, Edit, Profiles, Defaults, Defaults\*, Presets, Presets\* (none yet), Spec, Commands, API` | +5 |
| `Core/registry_extra.json` | `restore/shape/keys` for §4.1 SVs | +60 |
| `Collection/tools/genregistry.py` | accept/validate/emit new keys; docstring | +35 |
| `Core/Registry.lua` | regenerated | generated |
| `Collection/tests/core/run.py` + `fixtures/` | stubs, T1–T28, fixture registry/preset | +600–750 |
| Codex brief hashes | ZIP hash changes (Core in the ZIP) → replace hash in briefs (phase19 precedent: 28 files) | mechanical (A3/A4 helper) |

Total new Lua in Core ≈ 1,000–1,300 lines. Not in Step 33: Phase 20 Codex verification brief, `appearance-2-layouts.md` addendum (§5.4), preset data files (wait for Codex, R109).

---

## 10. Key risks

1. **Handler order** [U]: Core's handler for a target's `ADDON_LOADED` must run before the target's (shared with Defaults, `Core/Defaults.lua:43–45`). Detected for AceDB targets (too-late skip); not detectable for plain targets → Codex item.
2. **Account-wide `whole` restore** [I]: restoring `whole` account AceDB SVs also restores other characters' `profileKeys`/profiles of those addons. Accepted by design ("common" = shared layout) — Decision Queue 5.
3. **Details split** [U]: `keys` choice for `_detalhes_global`/`_detalhes_database` assumes settings live only in `__profiles`/`active_profile`.
4. **Version source** [U]: if `C_AddOns.GetAddOnMetadata` is missing on Forever, the registry version is used; an addon updated outside the collection then looks unchanged.
5. **SV size / load time** [U] with 10 snapshots.
6. **Dual-spec event on Forever** [U] (`LDS:535–541`, Hekili comment Events.lua:393).
7. **PM features outside scope** [C]: PM's preset capture of all providers (PM/Presets.lua:110–123), "delete unused profiles" (PM/UI.lua:564–628), new-character automation (PM/UI.lua:349–358), addon sets (PM/Addons.lua) stay available in PM's window. They act only on the user's click/configuration; the collection docs should say to use `/dfp` for restore and `/pm` only for keys/settings.
8. **Core contract change**: Core starts writing other addons' SVs (load time, after a user command).
9. **Fragment/Defaults overlap**: kept disjoint by test T24 and an integration check.

## 11. Decision Queue (for the master)

1. Placement: (b) Core module recommended; (c) `!DevilForever_Profiles` if the master wants Core's contract untouched (+1 addon, R101).
2. Keep ProfileManager as-is in the required bundle for keybinds/game settings, with `/dfp keys|game` pass-through (default) — or no pass-through (users type `/pm …`), or drop PM (R101; keybinds/settings would then be missing or rewritten — not recommended, R47/R63).
3. Core contract wording: 「Core changes no frame directly; it writes registered saved variables only at load time after a user command」 (`Core/Core.lua:3`, `Core/API.lua:74`).
4. Optional later: a PM provider adapter (`ProfileManager:RegisterProviderDef`, `RequiresReload = true`) exposing snapshots to `/pm apply all` — not in Step 33.
5. Registry `restore` classification (§4.1), opt-in default `skip`; account-wide `whole` for common AceDB SVs; Details `keys`.
6. Save = load-time capture (needs `/reload`) instead of a live copy — chosen for Details' logout writes; costs one reload.
7. Two-step commands (`restore` then `go`) vs reload immediately.
8. Pending validity: same character and ≤ 600 s.
9. Version mismatch: untouched, no force option in v1.
10. `MAX_SNAPSHOTS = 10` + one `__before-restore` slot.
11. Preset restore clears edits only for frames the preset covers (not every edit).
12. First-run preset pick by screen height, fallback `uhd` (R21); fragments only into fresh SVs on first run.
13. Codex interface addendum (§5.4): fragment header fields; Claude wraps Codex files into `Core/Presets/<name>.lua`.
14. F68 = dual-spec talent group via LibDualSpec (Dominos is the only class-split SV); dominant-tree switching not done.
15. Registry still lists dropped addons (Bagnon, Titan, Kaliel's, Platynator, Mapster, TipTac, ForeverThreat, Dominos_Progress/Roll — phase19 work log :60); with default `skip` they are inert.
16. Chat window split (ChatSetup) is not an SV and cannot be restored by snapshots.

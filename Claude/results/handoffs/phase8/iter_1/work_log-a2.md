# Work log — Phase 8 Steps 19–20 (Hekili display defaults · Cooldown Manager notes · class check · briefs) — work A2

Raw output: scratchpad `step19.hAAl/` (volatile; the verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole, 39 lines); Phase 8 detail plan (whole, 11 lines)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: 135–166 (constraints), 205–216 + row 220 (Phase 8 feature row), 295–360 (Non-goals, Implementation Changes, Codex briefs), 398–413 (Interfaces), 445 (Phase 8 verification split), 489–548 (Decisions Required — D2, exception, stop table)
- `Claude/results/REQUEST_LEDGER_phase8.md` (whole, 21 lines — R94–R108 incl. R99, R100, R104, R107)
- `Collection/data/hekili-support.md` (whole, 202 lines; §4–§5 supplement-module design superseded by R104); `Collection/data/classes.md` (whole, 47 lines)
- `Collection/judgment.md` 39, 62, 71, 108–115, 236, 263–278 (grep hits for Hekili / Phase 8); `Collection/manifest.json` Hekili package (Python dump)
- Core: `Defaults.lua` 1–395 (whole), `Defaults/Dominos.lua` (whole), `Defaults/SexyMap.lua` (whole), `API.lua` 1–80, `Edit.lua` 1–60, `!DevilForever_Core.toc` (whole), `registry_extra.json` (whole), `Registry.lua` 1–40, 1014–1035
- Tools/tests: `Collection/tools/genregistry.py` 1–80; `Collection/tests/core/run.py` 1–420, 800–1015
- Briefs (form): `Collection/codex-briefs/appearance-2.md` (whole), `appearance-7.md` (whole), `phase7.md` (whole), `phase3.md` 1–40
- Step 5 design: `Codex/docs/devil-ui-old-4k-layout.md` grep hits 5–99 (sizing rule lines 20–37)
- Phase 7 work log 1–91 (format, gate commands)
- Upstream Hekili (read only, never run) `U/` = `Collection/upstream/Hekili-v0.8.6/Hekili/`: `Options/Profile.lua` 1–72 (whole), `Options/Options.lua` 100–560 (displayTemplate, GetDefaults), 3640–3800 (Cooldown Manager panel), 6740–6760 (override binds), 8855–8880; `Options/ChatCommands.lua` 1–140, 559–600; `UI/UI.lua` 1070–1095, 1269–1330, 1420–1440, 860–895; `UI/Styles/Classic.lua` 67–92, 120–135; `UI/Styles.lua` 30–70; `UI/BarGlow.lua` 1–60; `Game/State/Sources/Presence/CooldownViewer.lua` 1–60 + grep IsVisible/hidden (91, 478); `Options/StyleOptions.lua` grep min/max (220–237); `Engine/Schema/Spec/Kits.lua` 100–150; `Engine/Schema/Spec.lua` 46–63

## Findings used (Step 19)
- SV shape: `HekiliDB` account (`Hekili.toc`, manifest), AceDB-3.0: `LibStub("AceDB-3.0"):New("HekiliDB", self:GetDefaults(), true)` (`Options/Profile.lua:20`) → defaultProfile `true` = profile **"Default"** shared by every character. LibDualSpec may move a character to a per-spec profile (`Profile.lua:25–28`) — only when the player turns it on; then profileKeys names it and Core fills that one.
- Creation timing: `InitializeProfile` is called from `OnInitialize` (`Engine/Sim/Core.lua:43–45`) = Hekili's ADDON_LOADED; Core's ADDON_LOADED handler runs first (Core assumption), so on a fresh install Core creates `HekiliDB.profiles.Default` with the value and AceDB:New takes it. Same path as Dominos/Prat (AceDB fill-missing).
- D2 / R104 "recommendation on" = Hekili's own defaults: `profile.enabled = true` (`Options.lua:302`), `displays.Primary.enabled = true` (416–417). Visibility rule (`UI/UI.lua:1294–1307`): Primary always shown; AOE only in dual/reactive mode (default `automatic`); Cooldowns/Defensives/Interrupts only when that toggle's `separate` is true (defaults false) → by default only the Primary next-action queue shows. Unsupported (healer) specs: `s.options.enabled = false` (`Kits.lua:141`) and `specEnabled` false → no display (`UI.lua:1285–1294`).
- "Separately switchable" exists natively: `/hekili disable` · `/hekili enable` (sets `profile.enabled`, `ChatCommands.lua:61–62, 559–572`), per-display "Enabled" in Hekili options, Hekili's pause binding `ALT-SHIFT-P` (Hekili's own override bind, `Options.lua:6748–6757`, default `toggles.pause.key` 322 — not ours), and turning the addon off in the addon list. No value needed.
- Action bar glow `barGlow` (`Options.lua:306–314`; table at 307): off by Hekili default ("off until the player turns it on"); glows the Dominos button holding the first recommendation (`UI/BarGlow.lua:1–11`), `combatOnly = true`.
- Frames: displays `HekiliDisplay<id>` (`UI/UI.lua:1083`) for Primary/AOE/Cooldowns/Defensives/Interrupts, buttons `Hekili_<id>_B<n>` (`Classic.lua:128`), notification `HekiliNotification` (`UI.lua:1427`, centre text). Icon size range 10–500 (`StyleOptions.lua:224–237`); sizes are multiplied by `Hekili:GetScale()` = one physical pixel in UI units (`UI.lua:51–53`) → Hekili sizes are physical pixels. Masque group "Hekili" (`UI.lua:1403–1408`); public `Hekili:RegisterDisplayStyle` (`Styles.lua:41–58`).
- Cooldown Manager: Hekili reads `EssentialCooldownViewer`·`UtilityCooldownViewer`·`BuffIconCooldownViewer`·`BuffBarCooldownViewer` read-only (`CooldownViewer.lua:1–21, 29–30`); per viewer `IsVisible` each sweep — a hidden viewer makes Hekili's reading stale (46, 91, 478). Hekili's options read `C_CooldownViewer.IsCooldownViewerAvailable` and CVar `cooldownViewerEnabled` (`Options.lua:3687–3766`) — we read, never write.

## Step 19 — decisions (A2 judgment)
- Defaults file `Defaults/Hekili.lua`: AceDB target `HekiliDB`, `profile = "Default"`, one value `barGlow.enabled = true`. Reason: the plan row lists "단축바 강조" among the Step 19 display defaults and Hekili ships it off; every other D2/R104 value (recommendation on, Primary only, healer specs off, player-switchable) is Hekili's own default and is not written (AceDB would strip equal values at logout — same rationale as Phase 7 Quartz). If master reads the plan row as "leave glow at Hekili's default", the file reduces to nothing → DQ 1.
- Registry entry `Hekili`: frames `hekili.primary|aoe|cooldowns|defensives|interrupts` → `HekiliDisplay<Id>`, `hekili.notification` → `HekiliNotification`; editable = position for all six + size 10–500 for `hekili.primary` (Hekili's own range); `HekiliDB` split common (one shared profile); defaults path. Cooldown Manager viewers are client frames, not an addon folder — genregistry refuses unregistered folders, so they are not in our registry; the Codex skin folder registers them in its own fragment (appearance-8.md).
- No CVar writes from code (`cooldownViewerEnabled`, `countdownForCooldowns` are read/checked by Codex only).

## Step 19 — edits
1. NEW `Collection/AddOns/!DevilForever_Core/Defaults/Hekili.lua` (30 lines).
2. `!DevilForever_Core.toc`: `Defaults\Hekili.lua` after `Defaults\Dominos.lua` (below the defaults marker).
3. `registry_extra.json`: `Hekili` entry added (Python json load/dump, indent 2, ensure_ascii — round-trip of the old file identical before the edit).
4. `Registry.lua` regenerated.
5. `Collection/tests/core/run.py`: `generated_registry_lookup` frame-set assertion now includes Hekili + Hekili frames/SV/defaults/editable count; new cases `hekili_defaults_fresh_shared_default_profile`, `hekili_defaults_user_and_dual_spec_profile_kept`.

## Step 19 — gates (verdict lines)
- `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (47109 bytes, sha256 63eb6a4696be0d6fc7411e0ae4baf65cdc67eb5980d07ac357ec81e83f4a251a)` both; `--check` → up to date (47109 bytes) rc0
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Castbars Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=15 failed=0`
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/upstream/Hekili-v0.8.6/Hekili` → `folders=2 unresolved=0 client_provided=0 optional_missing=5 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` (optional = ConsolePort, ElvUI, LibDualSpec-1.0, Masque, WeakAuras — Hekili's OptionalDeps)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=50 passed=50 failed=0` (48 before + 2 Hekili cases)
- `castbars/run.py` → `cases=16 passed=16 failed=0`; `fufdefaults/run.py` → `cases=16 passed=16 failed=0`; `chatsetup/run.py` → `cases=13 passed=13 failed=0` (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=4 files=18 zip_entries=20` rc0, sha256 `ae52cfc3bbaa26f5d0320ec57622e6402e2871459a1479699ceaa48ac2e42487` both; ZIP holds `Interface/AddOns/!DevilForever_Core/Defaults/Hekili.lua`
- `References/forever-addons/Hekili/Hekili-v0.8.6-forever.zip` sha256 `8063fd78…4c45e3` = manifest; top folders Hekili, Hekili_Shared, 9 class modules

## Step 20 — class check (shaman first, R7) against `Collection/data/hekili-support.md` §2 and `classes.md`
Source-only check (no game run here). "Hekili" = next-action recommendation (Primary display, glow); "CDM" = client Cooldown Manager (status/CD for every spec, R104). Rows marked unsupported get CDM only (Hekili hides its displays, `Kits.lua:141`).

| Class | Hekili recommends (spec · priority line) | Unsupported → CDM only | What Codex looks at in game (phase8.md item) |
|---|---|---|---|
| SHAMAN | elemental `Shaman.lua:1279` · enhancement `:1284` | restoration (`:67`) | elemental + enhancement: Primary + glow (2); restoration: nothing from Hekili, CDM shows (4); proc centre/sound with maelstrom_weapon 5 stacks (571) / clearcasting (667) (6). Totems = Dominos totem bar, not Phase 8 |
| WARRIOR | arms `Warrior.lua:2237` · fury `:2232` · protection `:2227` | — | Primary for the spec played (2, other class line) |
| PALADIN | protection `Paladin.lua:1324` · retribution `:1319` (Holy Shock build `:1329`) | holy (`:39`) | holy: nothing from Hekili (4) |
| HUNTER | beast_mastery `Hunter.lua:1338`, `:1323` · marksmanship `:1343`, `:1328` · survival `:1348`, `:1333`, `:1353` | — | pet not modelled (`Hunter.lua:14`) — recommendation only for the hunter |
| ROGUE | assassination `Rogue.lua:1369` · combat `:1364` · subtlety `:1374` | — | — |
| PRIEST | discipline `Priest.lua:1076` (Smite) · shadow `:1071` | holy (`:56`) | holy: nothing from Hekili (4) |
| MAGE | arcane `Mage.lua:1375` · fire `:1380`, Frostfire `:1385` · frost `:1390` | — | — |
| WARLOCK | affliction `Warlock.lua:1525` · demonology `:1530`, `:1545` · destruction `:1535`, `:1540` | — | demon spells not modelled (`Warlock.lua:33–34`) |
| DRUID | balance `Druid.lua:2335` · feral `:2330` · guardian `:2340` (chosen by Thick Hide 3/3, 31–33) | restoration (`:63`) | restoration: nothing from Hekili (4) |

Totals: supported 24, unsupported 4 (all healer specs) — matches hekili-support.md 합계. Hekili's own Cooldown Manager panel (Options, per-spec aura switches `profile.specs[id].cdm`, `Options.lua:3770–3800`) only steers Hekili's belief; it does not change what the CDM shows. Per-class in-game runs beyond shaman and one other class are not in the ≤10-item brief: phase8.md item 2 asks for shaman and "any other class character the user has" (recorded, not required) — DQ 3.

## Step 20 — edits
1. NEW `Collection/codex-briefs/appearance-8.md` (36 lines): Hekili displays (frames, Masque group "Hekili", style API, physical-pixel sizes, value fragment per layout, functional keys not to touch) + Cooldown Manager four viewers (separate `DevilForever_Skin_CooldownManager`, deps Core only; never hide viewers — Hekili's IsVisible read; no `cooldownID`/`layoutIndex` change; Edit Mode first; no CVar writes; spell choice stays with the game's Cooldown Settings).
2. NEW `Collection/codex-briefs/phase8.md` (84 lines, items 0–9 = 10): start · load+defaults status · shaman supported specs recommendation+glow · disable/enable/reload/per-display off · healer spec shows nothing · Cooldown Manager on/per-spec/showing · centre emphasis/sound (record) · overlap with Quartz/FUF/Dominos + taint · `countdownForCooldowns` + built-in tooltip/bags/tracker/world map (record, R99/R100) · Hekili off + reload + upload.
3. NEW `Collection/codex-briefs/appearance-2-layouts.md` (35 lines): R107 ⑥ addendum — FHD/QHD/UHD from the start, UHD = Step 5 design, FHD/QHD by button size → rows/gaps → bottom-up stacked height, no ratio scaling (R21/R22); preset `layouts/<fhd|qhd|uhd>.lua` in Edit.lua value shapes over registry keys and ranges; resolution-free values in one token set; preset choose/apply layer not in Core yet (Codex proposes, Claude adds); applies to appearance-3…8 and later.
4. Banned-lexicon scan (`.claude/tools/banned_lexicon.json`, confirmed terms): one hit 「발동」 in phase8.md → replaced by "proc"; rescan 0 in the five files.

## Step 20 — gates (verdict lines)
- briefs: `phase8.md` sections=10 (≤10 items) · `appearance-8.md` 36 lines · `appearance-2-layouts.md` 35 lines
- `python3 -I Collection/tools/genregistry.py --check` → up to date (47109 bytes); ZIP sha256 unchanged `ae52cfc3…42487` (briefs are not in the ZIP)

## Decision Queue (A2 defaults taken)
1. `barGlow.enabled = true` is the only Hekili default written (read of plan row "단축바 강조"). Hekili's author ships it off. If master reads the row as "leave at Hekili default", delete the value → the defaults file has nothing left and should be dropped with its TOC line, registry `defaults` key and the two tests (Phase 7 Quartz precedent).
2. Manifest / judgment text still names the superseded supplement module `DevilForever_Combat` (`Collection/manifest.json` Hekili `how_to_use.reason`; `Collection/judgment.md:39, 112–114`) — outside this brief's write boundary; master/plan update.
3. Per-class in-game runs: phase8.md checks shaman (elemental, enhancement, restoration) and "one other class if the user has one"; the other 8 classes are source-checked only (work log table). Default: no extra Codex items (≤10 limit).
4. Cooldown Manager viewers cannot go in our registry (not an addon folder; genregistry refuses unregistered folders). Default: Codex's `DevilForever_Skin_CooldownManager` registers them in its fragment; Claude merges then. If master wants Core-side keys now, genregistry needs a "client frames" pseudo-folder (Core tool change).
5. Layout presets need a Core layer (choose fhd/qhd/uhd; sit under user edits; Phase 20 restore "back to preset"). Not in Core today (`Edit.lua` layers: token → registry default → stored edit). Default: Codex delivers data + proposal; Claude adds the layer when results arrive.
6. `countdownForCooldowns` / `cooldownViewerEnabled`: brief lets Codex turn them on by hand in game settings if off (user setting, not code) and record the menu path.

# Work log — Phase 8 Step 18 (Hekili v0.8.6-forever support table) — work A1

Outputs: `Collection/data/hekili-support.md`, `Collection/data/hekili-support.json`.
Scratch (volatile, not a record): `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/s18/` (extract.py, show.py, gen.py, per-class JSON dumps). Upstream was read only; no upstream file was executed (Python read the `.lua` files as text with `-I`).

## Read (basis)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 205–225 (feature table; row 215 = Phase 8 branch structure, R62 boundary).
- Phase 8 detail plan (whole, 9 lines); `Claude/results/handoffs/phase8/SESSIONS.md` (whole).
- `Collection/data/classes.md` 1–47 (whole); `Collection/data/classes.json` head (schema form) + Python spec-key comparison.
- `Collection/judgment.md` Phase 8 headers by grep, 108–116 (Phase 8 section), 263–265, 277–278.
- `.claude/tools/banned_lexicon.json` (Python: confirmed entries).
- Hekili core (`H/` = `Collection/upstream/Hekili-v0.8.6/`):
  - `Hekili/Engine/Schema/Spec/Kits.lua` 1–156 (whole); `Spec/Auras.lua` 1–203 (whole); `Spec/Abilities.lua` 1–430 (whole).
  - `Hekili/Engine/Schema/Spec.lua` 112–125, 715–740; `Spec/Activation.lua` 95–130, 370–420; `Engine/Schema/Tracked.lua` 1–30; `Engine/Schema/Trees.lua` 8–30.
  - `Hekili/Hekili.lua` 1–216; `Hekili/UI/Styles.lua` 1–70; `Hekili/Engine/Output.lua` 1–25 (+ grep 88, 236); `Hekili/Integrations/WeakAuras.lua` 1–15.
  - `Hekili/Options/Options.lua` 340–510, 8165–8180, 4488–4505; grep notifications/Notify (Options, ChatCommands, UI, Hekili.lua).
  - `Hekili/UI/Styles/Classic.lua` 1–80 + grep glow/flash (185–760); `UI/Styles/Timeline.lua` 1–40; `UI/Truth.lua` 1–30 + grep 9, 26, 57; `UI/BarGlow.lua` 1–60; `UI/Resolve.lua` grep 5–126.
  - `Hekili/Engine/Sim/State.lua` grep filter 6530–6543, 7226–7229.
  - `Hekili/Game/API/Facade.lua` 1–40, 160–200, 715–745, 1020–1070, 1150–1300, 1340–1436; `Game/State/Sources/Auras.lua` 1–60; `Game/State/Sources/Presence/CooldownViewer.lua` 1–45.
  - Greps over `Hekili/` and `Hekili_*` (Libs excluded): PlaySound/PlaySoundFile/UIFrameFlash/Flash/overlay glow/RaidNotice → 0 `PlaySound`; SpellFlash only in `Locales/zhCN.lua:1036–1067` + `Options.lua:8173`; `unsupported` (Options 4496, ChatCommands 700, Kits 114/135/141, Activation 386, Spec 727, Trees 49–138, Selectors 56).
  - `Hekili_Shared/Shared/Auras.lua` 1–15.
- Class modules (each: header + NewClass whole; RegisterAuras / RegisterAbilities / RegisterTalents blocks scanned by Python into key·line·id·duration·max_stack·cooldown·toggle·form·overlay, aura preceding comments printed; the lines cited in the outputs re-checked by a Python gate, 290 line cites, 5 label-only non-matches, all correct):
  - `Hekili_Shaman/Shaman.lua` 1–80, 480–710 (read), 1084–1160, 1275–1291; talents 1152–1206 (scan).
  - `Hekili_Warrior/Warrior.lua` 1–52; auras 562–845, abilities 1008–2124, talents 503–560 (scan).
  - `Hekili_Paladin/Paladin.lua` 1–58, 409–446, 831–840, 1295–1336 (read); talents 277–332 (scan + spot lines 285–329).
  - `Hekili_Hunter/Hunter.lua` 1–77; 382–463, 590–1242, 1249–1303 (scan).
  - `Hekili_Rogue/Rogue.lua` 1–61; 164–222, 224–362, 503–1355 (scan).
  - `Hekili_Priest/Priest.lua` 1–67, 380–397, 925–999 (read); 368–434, 436–863, 1000–1056 (scan).
  - `Hekili_Mage/Mage.lua` 1–70; 284–919, 377–1289, 1305–1362 (scan).
  - `Hekili_Warlock/Warlock.lua` 1–87; 320–405, 593–1407, 1425–1481 (scan).
  - `Hekili_Druid/Druid.lua` 1–65, 728–731 (read); 361–417, 434–745, 851–2273 (scan), `form =` grep.

## Findings used
- Aura/CD data live on the class kit, shared by every spec through `__index` (`Kits.lua:117–151`). Per spec = talent-tree key match (machine) + source comments + Druid ability `form`.
- All 28 specs have kit data (incl. 4 unsupported healers; Paladin notes «Holy-only auras (B8, Holy is unsupported)» at 431).
- No EventAlert-style alert: 5 displays are recommendation queues (Options 414–506, State 6541–6543/7226–7229); glow/bar glow/Truth mark only on recommended abilities (Resolve 124, Classic 689–760, BarGlow 1–11, Truth 1–9); notification text = toggles/modes (Options 8861–9003); no sound (grep).
- Forever: aura reads secret in combat (Facade 725–739), cooldown times secret in combat (1027–1035), `IsSpellOverlayed` plain (1245); `Hekili.Client` answers from belief (Hekili.lua 151–154).

## Verdict (A1 judgment)
- Supported 24 / unsupported 4. Branch 2 for all 28; branch 3 none; static list source ① (Hekili data) for all.

## Self-review (1 round)
- Coverage gate: 28 specs in JSON = 28 in classes.json (Python set compare: no missing, no extra).
- Line gate: 290 cited key lines checked against module text by Python; 5 non-matches are labels (echoes, poisons, header, talent), lines correct.
- Banned-word scan on md: 0 hits.
- Corrections during self-review: C11 wording (Priest 384 says «registered for the displays and custom priorities» — rewrote so it does not claim the opposite); `Hekili.Client` claim limited to what `Hekili.lua:151–154` says.

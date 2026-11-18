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

---

# plan update R104/R107 — work A1 (same Phase 8)

## Read (basis)
- `Claude/results/REQUEST_LEDGER_phase8.md` 1–20 (whole; R101, R103–R107 verbatim user words).
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 1–533 (whole, two reads 1–261, 262–533).
- Facts checked for new cells: `Collection/upstream/Details-Details.20261109.15410.172/Details_TinyThreat/Details_TinyThreat_Camelot.toc` (Interface 16001, RequiredDeps Details) = `Collection/manifest.md:96–104`; `Collection/upstream/pitbull-unit-frames-4-0-v4.2.50/PitBull4/*.toc` (Cata 40402, Mainline 110207, Mists 50504, TBC 20505 — no 16001); V42 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/PitBull4/PitBull4.toc:1–2,19` (Interface 16001, «Confirmed Forever 1.60.1 build 70291», Version 4.2.49-Forever-v42); `!DevilUI/Profile/PitBull4.lua` exists; `References/addon-sources/pitbull-unit-frames-4-0/` (PitBull4-v4.2.50.zip, SOURCE.txt, ANALYSIS.md); `Collection/manifest.md:24` (PitBull4 comparison row).
- Totals: python over the outline estimates (before: all 2,090–3,790 = line 85 text; minus R100 steps = 1,910–3,460 — line 85 had not been updated after R100).

## Impact map (★ = must change)

| # | Place (plan line, before edit) | Same meaning / cause | Verdict | Why |
|---|---|---|---|---|
| 1 | 33–36 outline Phase 8 | R104 | ★ change | Hekili recommendation only, CDM for alerts/CD; Step 19 new content, supplement time gone |
| 2 | outline after Phase 8 | R107 ① | ★ add Phase 6-rev, Steps 42–43 | next free step after 41; runs after Phase 8 (A1 default, DQ) |
| 3 | 39–42 outline Phase 10–11 | R107 ② | ★ change | TinyThreat into Phase 10, Phase 11 merged |
| 4 | 48–53 outline Phase 14–16 | R107 ③④⑤ | ★ change | 14 no addon/brief only, 15 Codex decides, 16 light strip 28a/28b (new development → sub-steps rule line 81/326) |
| 5 | 62–67 outline Phase 20–21 | R107 ⑥ | ★ change | preset restore; Phase 21 dropped |
| 6 | 71–73 outline Phase 23 | R107 ① | ★ change | FUF vs PitBull4 default decision recorded in Phase 23 |
| 7 | 20 outline Phase 2 | R107 ⑥ | ★ change (label) | three layouts by Codex |
| 8 | 81 paragraph (multi-step Phases, Phase 21) | R104/R107 | ★ change | Phase 8 no code, Phase 21 dropped, 6-rev and 16 sub-steps |
| 9 | 85 totals | all | ★ change (python) | new fixed 1,850–3,400; per class 55–105 |
| 10 | 89 Summary (전투보조, UI 편집 필수) | R104/R107 ⑥ | ★ change | |
| 11 | 91 Summary 시각 기준 (4K) | R107 ⑥ | ★ change | three layouts; 4K design = UHD layout |
| 12 | 139 constraint 전투보조 | R104 | ★ change | |
| 13 | 140 constraint UI 편집 필수 | R107 ⑥ | ★ change | |
| 14 | 143 constraint 4K rule | R107 ⑥ | ★ change | rule applies per layout |
| 15 | 147 constraint fewer addons (R101) | R107 ⑤ | check only | used as reason for strip data part placement |
| 16 | 210 feature row 2 | R107 ⑥ | ★ change | |
| 17 | 214 feature row 6 | R107 ① | ★ change | pointer to 6-rev |
| 18 | new feature row 6-rev | R107 ① | ★ add | |
| 19 | 216 feature row 8 | R104 | ★ rewrite | |
| 20 | 218–219 rows 10–11 | R107 ② | ★ change | |
| 21 | 222–224 rows 14–16 | R107 ③④⑤ | ★ change | |
| 22 | 228–229 rows 20–21 | R107 ⑥ | ★ change | |
| 23 | 230 row 22 | — | no impact | theme token swap unchanged |
| 24 | 243–245 exclusion rows (버프·디버프, CD 관리자, 위협 상태) | R104/R107 ②③ | ★ change | sources of alerts/CD/threat changed |
| 25 | 247 exclusion row (화폐·가방…) | R107 ⑤ | check only | Phase 16 still holds gold; 13 dropped earlier (R100) — not this change |
| 26 | 261, 264, 266, 270 V42 classification | R107 ①⑤⑥ | ★ change | PitBull4 → 6-rev source; ChocolateBar → reference only; Devilconfig/minimap handles → not used |
| 27 | 277–284 「바꾼 곳」 1–8 | — | no impact (record) | design history of the plan; add item 9 instead |
| 28 | 200 범위 경위 | — | no impact (record) | |
| 29 | 293–295 Non-goals | R104 | ★ change | supplement wording gone |
| 30 | 307 모음집 구성 (필수 묶음 Phase 21) | R107 ⑥ | ★ change | |
| 31 | 333 Phase 24 mockup | R107 ⑥ | ★ change | three layouts in mockup (A1 default, DQ) |
| 32 | 342–347 Codex 외관 발주문 표·몫 목록 | R104/R107 | ★ change | |
| 33 | 359–388 Phase N table and intro | R104/R107 | ★ change | rows 6-rev, 11, 14, 15, 16, 21; statuses of other rows stale (not this change — DQ) |
| 34 | 398–403 Interfaces (등록 규약, 테마 토큰, 저장·복원, 편집, 직업 목록) | R104/R107 ⑥ | ★ change | Core edit values stay the read contract; writer = layout presets + AI edits |
| 35 | 421–423 Test Plan rows | R104/R107 | ★ change | supplement row gone; PitBull4 fork + strip data part added; Phase 21 gone |
| 36 | 422 Test Plan Phase 20 | R107 ⑥ | ★ change | preset return |
| 37 | 436–442 verification split | R104/R107 | ★ change | |
| 38 | 457–458 Assumptions (Hekili alerts) | R104 + Step 18 | ★ change | resolved; new assumptions CDM, PitBull4, TinyThreat |
| 39 | 471–473 Correction History | R104/R107 | ★ add 2 rows | |
| 40 | 484 D2, 501 D6, 505 D7 ①⑤ | R104/R107 | ★ add «바뀜» notes (decision records kept) | user decision records are not rewritten; a pointer line is added |
| 41 | 512 예외 (Hekili 보완 모듈 3라운드) | R104 | ★ change | |
| 42 | Phase 8 detail plan, hekili-support.md | R104 | out of scope (master) | not the master plan; DQ |
| 43 | code (`Collection/`) | — | not touched | order |

## Change applied (one change, one script: 50 exact replacements, each asserted to occur once)
- Script: scratchpad `s18/planedit.py` (volatile). Plan diff hunks (new line numbers): 20, 33–40 (Phase 8 + 6-rev), 42–45, 51–57, 66, 69–70, 74–75, 84, 88, 92, 94, 142–143, 146, 213, 217–218, 220, 222–223, 226–228, 232–233, 247–249, 265, 268, 270, 274, 289, 298–300, 312–313, 338, 347–348, 352, 364, 376–377, 379–380, 383–385, 390, 405, 407–409, 427–429, 442–449, 451, 453, 466–470, 486–487, 499, 517, 521, 528.
- No code touched. Phase 8 detail plan and `hekili-support.md` not touched (master scope).

## Re-check against the map (self-review 1 round)
- Leftover grep (보완 모듈 · Phase 21 · Platynator · Titan · ForeverThreat · 편집 창 · 갈래 · Phase 11 · UI 편집 · 9–11 · DevilForever_Combat): remaining hits are new «빠짐/합침/안 씀» wording, Ground Truth facts (112–121), the constraint-table column name «갈래», Test Plan «갈래» (review type), Step 18 title (done step), «바꾼 곳» 2/8 (record), Correction History and Decisions «바뀜» notes — all intended.
- Table column check (python, backticks ignored): 0 rows with a wrong column count.
- Totals re-derived from the edited outline by python: 1,850–3,400 (= line 88 text). Rows counted: 6–22, 26–28b, 31–33, 36–43 (dropped 23–25, 29–30b, 34–35 excluded).
- Banned-word scan on added lines: 0.

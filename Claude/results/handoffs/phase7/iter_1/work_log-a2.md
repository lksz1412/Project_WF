# Work log — Phase 7 Step 17 (Quartz 3.8.0 cast bars) — work A2

Raw output: scratchpad `step17.trA9/` (volatile; the verdict lines below are the record).

## Read (basis)
- `Claude/results/handoffs/settings-phase-brief-template.md` (whole); phase7 detail plan (whole, 7 lines)
- Master plan `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` 200–230 (feature table, row 214 = Phase 7), 300–460 (Implementation Changes, Phase list, Interfaces, Test Plan, verification split)
- `Claude/results/handoffs/phase6/TRIAGE_phase6.md` (whole); Phase 6 work log (whole)
- `Collection/judgment.md` 1–60, 96–110 (Phase 6–7), 215–270 (4-1, 4-2)
- `Collection/manifest.json` Quartz, Dominos (addon folders), FUF packages (Python extract)
- Core: `!DevilForever_Core.toc`, `Defaults.lua` 1–395, `Defaults/Dominos.lua` 1–25, `API.lua` 1–80 (all whole); `registry_extra.json` (Python dump + SexyMap block 348–378); `Collection/tools/genregistry.py` 1–70, 109–290; `build.py` 1–80; `luacheck.py` 1–30; `tocdeps.py` 1–25
- `Collection/AddOns/DevilForever_FUFDefaults/` TOC + `FUFDefaults.lua` 1–178 (pattern); `Collection/tests/fufdefaults/run.py` 1–400 (pattern); `Collection/tests/core/run.py` 375–427
- `Collection/codex-briefs/phase6.md`, `appearance-6.md` (whole, form); `appearance-2.md` 1–40 (sections)
- Upstream Quartz (read only, never run) `U/Quartz-3.8.0/Quartz/`: `Quartz.toc` 1–71, `Quartz.lua` 1–270, `modules/Player.lua` 1–671 (tick table rows skipped by filter), `modules/Target.lua` 19–145, `modules/Focus.lua` 19–80, `modules/Interrupt.lua` 19–98, `modules/BuffContainer.lua` 19–110, 1020–1110, `CastBarTemplate.lua` 19–860, 860–935, 1105–1294 (860–1104 option keys scanned by grep), `CHANGELOG.md` 1–20; grep `SetEnabledState|hideblizz|MODNAME` over modules; `modules/GCD.lua` 76–84, `SwingForever.lua` 74–84; `libs/LibStub/LibStub.lua:29`
- Upstream Dominos: `Dominos_Cast/Dominos_Cast.toc`, `castBarModule.lua` 1–23, `mirrorTimerModule.lua` 1–93, `castBar.lua` 1–140; `Dominos/Dominos.lua` 140–330
- Upstream FUF: `Core/Settings.lua` 385–436, `Core/Preset.lua` 1–60, `Elements/Castbar.lua` 1–573 (whole), `Core/Init.lua` 1–40, `Core/Blizzard.lua` 90–160, `Units/Single.lua` 250–300, `Units/Units.lua` 17–31, 90–130, `Elements/Shape.lua` 40–50, 130–145, `Core/Boot.lua` 20–35

## Findings used
- Quartz SV `Quartz3DB` (account, `Quartz.toc:17`), `AceDB:New("Quartz3DB", defaults, true)` (`Quartz.lua:54`) → every character uses the one "Default" profile; per-bar values in module namespaces (`RegisterNamespace`, e.g. `Player.lua:106`).
- Quartz defaults already implement the row: all modules on except EnemyCasts (`Quartz.lua:26`); Player/Target/Focus/Pet `hideblizz = true` hide Blizzard's bars (`Player.lua:40, 141–161`; `Target.lua:40, 111–114` — only while the Target module is enabled; `Focus.lua:46`; `Pet.lua:33`); target shows friendly and hostile (`Target.lua:37–38`). Cast/channel colours, stop = complete colour, FAILED/INTERRUPTED = full bar in fail colour fading ~1 s, time text cleared (`CastBarTemplate.lua:351, 384–434, 137–154`); not-interruptible shield on non-player bars (`noInterruptShield = true`, 1236; 275–282; events 675–678 for retail and forever). → **no Core defaults file** (all needed values are Quartz defaults; AceDB would strip equal values anyway).
- Quartz template default names `noInterruptBorderChange`/`noInterruptColorChange` (1230, 1234) are not the keys the code reads (`noInterruptChangeBorder`/`noInterruptChangeColor`, 232, 250, 1115, 1148) → those two are off unless set; recorded in appearance-7.md, not changed.
- Interrupt module ("INTERRUPTED (name)" text, `Interrupt.lua:55–61`) is `[ExcludeLoadGameType mainline]` (`Quartz.toc:70`). Quartz itself treats Forever as inside mainline: `Swing.lua` (mainline-excluded) and `SwingForever.lua` (camelot) both define module "Swing" (`Swing.lua:22`, `SwingForever.lua:26`), so they can only coexist if camelot ⊂ mainline (A2 judgment, supports judgment.md 4-1). Interrupt therefore not expected; interrupt shows as the red fail bar without a word (brief item 1 checks the module, item 3 records the look).
- Cast-bar candidates: Blizzard (hidden by Quartz), Dominos_Cast (`castBarModule.lua:5–23`: own bar + unregisters/reparents Blizzard player/pet bars; `mirrorTimerModule.lua` also takes the mirror timers that Quartz Mirror takes), FUF (`castbarEnabled` default player/pet off, others on `Settings.lua:394–395`; preset turns player on with `castbarAlwaysShow` `Preset.lua:38–39`; `hideBlizzardCastbar` default false 398–399), Quartz.
- FUF cast bar: a plain StatusBar child built once per frame (`Castbar.lua:314–351`, `frame.castbar`), shown/hidden only via `setShown` → `bar:SetShown`, then `Shape.Refresh` reads `IsShown` (206–210, `Shape.lua:137`); FUF calls it in combat too (event path 553–571), so the bar is not protected. FUF shows no failed/interrupted state (stop events → Refresh → Stop, 49–52, 565–566). FUF settings are the account-wide shared profile (TRIAGE_phase6 M1) → changing `castbarEnabled` there would change characters without Quartz.
- Dominos modules can be switched per profile: `profile.modules[id]` gates both `OnFirstLoad` and `Load` (`Dominos.lua:150–166, 316`); module ids "CastBar", "MirrorTimer". Dominos profile = class name, account-wide (`Dominos.lua:255–256`) — that file belongs to Phase 3 → Decision Queue.

## Ownership design (A2 judgment)
- **Quartz owns player, target, focus and pet cast bars.** Blizzard's are hidden by Quartz's own `hideblizz` default. FUF's bar of the same unit is hidden by a new session-only bridge `DevilForever_Castbars`, only while that Quartz module is enabled; FUF keeps its bars on all other units (target-of-target, party, boss). Dominos_Cast is not used in the collection (DQ 2).
- Why Quartz over FUF: Quartz shows failed/interrupted casts (red bar), FUF drops the bar; Quartz is the Phase 7 start addon; Quartz's default already hides Blizzard's bars.
- Why a bridge and not settings: FUF's `castbarEnabled` lives in the shared profile (Phase 6 M1 rule: never affect characters without the other addon). The bridge writes nothing, needs `Quartz` and `ForeverUnitFrames` as TOC dependencies (a character without Quartz never loads it), and re-checks the Quartz module on every show (turning a Quartz module off hands the unit back to FUF).
- Risks: (1) FUF player debuffs anchor below the (now hidden) cast bar slot (`Preset.lua:38–43`) → possible empty gap — appearance-7 §3 asks Codex to handle it via the Phase 6 fragment, without touching `castbarEnabled`. (2) If the bridge hooks after FUF already showed the always-show player bar, it hides it directly; FUF's shape refresh then waits for FUF's next show (PLAYER_ENTERING_WORLD update `Units.lua:17` normally comes after PLAYER_LOGIN hooking). (3) With the bridge off, Quartz and FUF bars both show (brief item 8 records it). (4) Game behaviour unverified until Codex (R86).

## Steps
1. New `Collection/AddOns/DevilForever_Castbars/DevilForever_Castbars.toc` (16001, `Dependencies: Quartz, ForeverUnitFrames`, `OptionalDeps: !DevilForever_Core`, no SV) and `Castbars.lua` (hooks `SetShown`/`Show` of `ForeverUnitFrames_<unit>.castbar` for player/target/focus/pet at PLAYER_LOGIN and every PLAYER_ENTERING_WORLD, each bar once; hides when `LibStub("AceAddon-3.0"):GetAddon("Quartz3", true):GetModule(<Module>, true):IsEnabled()`; `DevilForever_Castbars.GetStatus()`; one Core `info` log line). Found while testing: `fufShown = bar and x or nil` gave nil for a hidden bar → explicit branch.
2. New `Collection/tests/castbars/run.py` (12 cases; LibStub stand-in is a callable table as in `LibStub.lua:29`). Runs: `cases=12 passed=5` (test stub LibStub was a function, addon checks `type(LibStub) == "table"`; stub fixed to the real shape) → `passed=11` (test read a nil key) → `cases=12 passed=12 failed=0`.
3. `registry_extra.json`: `Quartz` — 6 frames `quartz.player|target|focus|pet|gcd|swing` → `Quartz3CastBarPlayer|Target|Focus|Pet`, `Quartz3GCDBar`, `Quartz3SwingBar` (`CastBarTemplate.lua:1241`, `GCD.lua:83`, `SwingForever.lua:82`); editable position ×4, size ×4 (10–1500; Quartz w 50–1500, h 10–50 `CastBarTemplate.lua:860–872`); `Quartz3DB` common; no defaults. Diff vs scratchpad `registry_extra.before.json`: 75 added, 0 removed.
4. `python3 -I Collection/tools/genregistry.py` ×2 → `wrote … (45470 bytes, sha256 0bce064d02c505b6145d7a6fc7ff1d10194a37c05ed8c84370d9b669e84906f1)` both; `--check` up to date rc0. `DevilForever_Castbars` registered as own addon (use new, no SV).
5. Core tests first run `cases=48 passed=47 failed=1` (`generated_registry_lookup`: frame list lacked Quartz — expected). Expectation extended: Quartz frames (6), SV, defaults nil, editable 8, Castbars entry `use=new`, no SV → `48/48`. No Core test with a real defaults-file shape: there is no Quartz defaults file (finding above).
6. Briefs `Collection/codex-briefs/phase7.md` (items 0–9), `Collection/codex-briefs/appearance-7.md`.

## Gates (final)
- `python3 -I Collection/tools/genregistry.py --check` → up to date (45470 bytes) rc0 (×2 identical above)
- `python3 -I Collection/tools/luacheck.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_ChatSetup Collection/AddOns/DevilForever_FUFDefaults Collection/AddOns/DevilForever_Castbars Collection/tests/core/fixtures` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=14 failed=0`
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_Castbars Collection/upstream/Quartz-3.8.0/Quartz Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames` → `folders=4 unresolved=0 client_provided=0 optional_missing=6 no_interface_toc=0 forever_load_check=0 forever_load_no=0 duplicates=0 load_on_demand=0` (optional-missing = Quartz's Ace3/LibSharedMedia/SharedMedia names, embedded)
- `python3 -I Collection/tests/core/run.py` → `lupa=2.8 cases=48 passed=48 failed=0`
- `python3 -I Collection/tests/castbars/run.py` → `lupa=2.8 cases=12 passed=12 failed=0`
- `python3 -I Collection/tests/fufdefaults/run.py` → `cases=16 passed=16 failed=0`; `chatsetup/run.py` → `cases=13 passed=13 failed=0` (unchanged)
- `python3 -I Collection/tools/build.py` ×2 → `built folders=4 files=17 zip_entries=19` rc0, sha256 `b680f12a70d089ec2ad3efc215ac8989bfb31478bf9f834d66366b80c921f74c` both
- `References/forever-addons/Quartz/Quartz-3.8.0.zip` sha256 `2a76cdda…5ed70` = manifest

## Decision Queue
1. Template deviation: no `Defaults/Quartz.lua`, no Core TOC line — every value the row needs is a Quartz default. Instead a new code bridge `DevilForever_Castbars` (new code → per Test Plan 「새 코드」 a code logic review 1회 is due).
2. Dominos_Cast: not part of the collection (A2 default). Build/manifest: when Phase 23 decides to ship upstream folders, leave `Dominos_Cast` out of the Dominos selection (`build.py --select` takes folders; manifest lists `Dominos_Cast` under Dominos). Users who installed Dominos from CurseForge get it on → phase7.md item 7 measures the overlap. Optional extra (Phase 3 file, master decision): `Defaults/Dominos.lua` version 2 with `modules = {CastBar = false, MirrorTimer = false}` (fill-missing into the class-named profile; with Dominos_Cast loaded it then neither draws nor hides Blizzard's bars — `Dominos.lua:150–166`). Not done.
3. Quartz `Buff` module (mainline `BuffContainer.lua`, on by default) shows the player's own buffs/debuffs on target and focus as bars — overlaps FUF's frame auras (Phase 6 scope), not a cast bar. Left at Quartz's default; options: (가) leave, (나) `modules.Buff = false` via a Quartz defaults file.
4. Focus and pet included in the bridge (same rule as player/target) — beyond the row's "player/target" wording, to keep one owner where Quartz draws a bar.
5. Registry size editable: one range 10–1500 for width and height (registry has one min/max; Quartz clamps itself).
6. Interrupt display relies on the fail-colour bar (Interrupt module not expected on Forever); no "interrupted" word — Codex item 3 records the look. An early-ended channel looks like a finished one (`CastBarTemplate.lua:384–394`).
7. judgment.md Phase 7 (iv) "FUF `castbarEnabled` 대상 쪽 끔" not followed (shared profile) — replaced by the bridge; judgment.md not edited (boundary). Manifest not edited.

## Check 1 fix (triage `Claude/results/handoffs/phase7/TRIAGE_phase7.md`: M1, minor 1)

Read: `TRIAGE_phase7.md` (whole); `Castbars.lua` 1–107 (whole, re-read after container restart); `tests/castbars/run.py` (whole); FUF `Units/Single.lua` 320–360 (`Single.CreateAll` → `ns.AfterCombat("createSingle", …)` 334–352), `Core/Init.lua` 60–140 (`AfterCombat` queues in combat 71–87; drain runs in 25 ms slices, continues next frame `C_Timer.After(0, drain)` 106–127); Quartz `Quartz.lua` 88–101, 205–219; `libs/AceAddon-3.0/AceAddon-3.0.lua` 280–350 (`EnableModule`/`DisableModule` → `module:Enable()/Disable()`), 448–480 (mixins copied onto the addon object).

Cause (M1): a login in combat queues FUF's frame build until after combat, over possibly several frames; the bridge only tried at PLAYER_LOGIN / PLAYER_ENTERING_WORLD, so both bars showed for the session. Minor 1: a Quartz module toggle only took effect at FUF's next show; a turned-off module left FUF's bar hidden.

### Impact map
| Place | Link | Verdict |
|---|---|---|
| `Castbars.lua` header 9, 16–18 | describes hook timing and toggle hand-over | fix together |
| `Castbars.lua` events 84–87 | hook timing | fix together: add PLAYER_REGEN_ENABLED (kept registered while a unit is unhooked) + retries 1 s and 5 s after it (FUF drain may span frames) |
| `Castbars.lua` `conceal`/hooks 53–82 | hand-over on toggle needs FUF's last wanted state | fix together: record `wanted[unit]` from FUF's SetShown/Show; post-hook `Quartz3.EnableModule`/`DisableModule` (once) → re-evaluate that unit (enable: hide; disable: show again if FUF wanted it shown) |
| `Castbars.lua` GetStatus 89–107 | status fields | fix together: add `wanted` |
| `tests/castbars/run.py` stubs (Quartz stand-in, C_Timer, InCombatLockdown), `module_toggled_mid_session` 203–209 | expectation was "at next show" | fix together; new cases combat-login, drain-late, toggle at once, hook-once on Quartz |
| `Collection/codex-briefs/phase7.md` intro hash, item 6; `appearance-7.md` hash | ZIP hash, toggle expectation | fix together |
| `outputs/collection/DevilForever-collection.zip` | contains Castbars | rebuild |
| this work_log sections above (design, steps, gates) | record of the first pass | no impact (record) |
| `registry_extra.json`, `Registry.lua`, `tests/core/run.py` | no SV, no frames for Castbars | check only (`--check`, core tests) |
| FUF / Quartz upstream | read only | no impact |

### Change
- `Castbars.lua`: header (toggle hand-over, timing); `wanted[unit]` recorded by the SetShown/Show hooks (initial = `IsShown()` at hook time); `hookQuartz()` post-hooks `Quartz3.EnableModule`/`DisableModule` once → `moduleSwitched(name)`: module on → `conceal`, off → `bar:Show()` when FUF last asked shown; `hookAll()` returns whether a unit is still unhooked and keeps `PLAYER_REGEN_ENABLED` registered only then; on that event retries at 1 s and 5 s (`RETRY`); `GetStatus` adds `wanted`. Note: a FUF frame that never exists (e.g. focus on a client without focus) keeps the REGEN watch on (two timers per combat end, cheap).
- Hand-over by `bar:Show()` skips FUF's own shape refresh until FUF's next show (same as the install-time case in the first-pass risks).
- Tests: stubs C_Timer, Quartz `EnableModule`/`DisableModule`; `module_toggled_mid_session` now expects hand-over at once; new `toggle_does_not_show_a_bar_fuf_hid`, `login_in_combat_frames_built_after_combat`, `fuf_drain_after_regen_caught_by_retry`, `regen_not_watched_once_all_hooked`; hook count 8 → 10; status expectation with `wanted`. First run `cases=16 passed=15` (status expectation lacked `wanted` — expected) → 16/16.
- Briefs: hash lines; phase7 item 6 adds the Player toggle-at-once check; item 9 adds a `/reload` in combat check.

### Gates (fix)
- `python3 -I Collection/tests/castbars/run.py` → `lupa=2.8 cases=16 passed=16 failed=0`
- `python3 -I Collection/tools/luacheck.py Collection/AddOns/DevilForever_Castbars` → `runtime=Lua 5.1 luajit=False lupa=2.8 checked=1 failed=0`
- `python3 -I Collection/tools/tocdeps.py 'Collection/AddOns/!DevilForever_Core' Collection/AddOns/DevilForever_Castbars Collection/upstream/Quartz-3.8.0/Quartz Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames` → `folders=4 unresolved=0 … duplicates=0`
- `python3 -I Collection/tools/genregistry.py --check` → up to date (45470 bytes); `python3 -I Collection/tests/core/run.py` → `cases=48 passed=48 failed=0`
- `python3 -I Collection/tools/build.py` ×2 → `built folders=4 files=17 zip_entries=19`, sha256 `2604ad700ba0e14958fe28e59ef5db792b720ff6d20545a68315409191d901af` both; phase7.md / appearance-7.md hash lines updated
- Raw output: scratchpad `fix7.I5QY/`

### Decision Queue (after fix)
- Master accepted DQ 2–7 (triage). Minor 2 (FUF test-mode preview hidden while Quartz owns the unit) and minor 3 (Quartz Focus frame may not exist; registry entry) → final report / Phase 23 (triage).

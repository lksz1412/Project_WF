# Phase 23 · Step 37 — static integration check (A2 report)

INTEGRATION_READY

Scope: static checks only (R86). Passing a static check is not a game pass; every in-game result stays unverified until Codex results arrive (none are in the repository — `References/codex-verify/` and `References/codex-appearance/` do not exist; R109 Codex on hold). Commands, verdict lines and ranges read: `iter_1/work_log-a2.md`.

Combination set used (folders): ours from `Collection/AddOns/`, upstream folders as the briefs tell Codex to install them.

| Group | Folders |
|---|---|
| Required bundle (plan 312) | `!DevilForever_Core`, `ProfileManager`, `Masque`, `Masque_Onyx` |
| P3 Dominos | `Dominos`, `Dominos_Config`, `Masque_Dominos` (not `Dominos_Cast`/`_Progress`/`_Roll`) |
| P4 chat | `Prat-3.0`, `DevilForever_ChatSetup` |
| P5 minimap | `SexyMap` |
| P6 FUF build | `ForeverUnitFrames`, `DevilForever_FUFDefaults` |
| P6-rev PitBull4 build | `PitBull4` (ours, `v4.2.50-forever.1`) |
| P7 cast bars | `Quartz`, `DevilForever_Castbars` |
| P8 | `Hekili`, `Hekili_Shared`, 9 `Hekili_<class>` |
| P9 | `Grid2`, `Grid2Options`, `Grid2LDB` |
| P10 | `Details`, `Details_TinyThreat` |
| P16 | `DevilForever_StatusStrip` |
| P19 | `ExperienceForever` |
| Not in the collection | `Aurora` (Codex decides, R107 ④), `BugSack`+`!BugGrabber` (verification tools, D1) |

---

## 1. TOC and dependency resolution (tocdeps, Interface 16001)

| Combo | Folders | Unresolved hard deps | Notes |
|---|---|---|---|
| (a) required only | 4 | 0 | — |
| (b1) everything, FUF build | 32 | 0 | LoD 12 (Dominos_Config, Grid2Options, Hekili_*) |
| (b2) everything, PitBull4 build | 31 | 1: `DevilForever_Castbars` needs `ForeverUnitFrames` | by design (bridge for FUF only, `unitframes-compare.md` §2 cast-bar row); it simply does not load |
| (b3) everything + both unit frames | 33 | 0 | TOC-clean but two unit-frame addons (check 4) |
| (b4) everything + Aurora + BugSack | 35 | 0 | Aurora's 7 `Blizzard_Deprecated*` deps are client-provided and carry `[AllowLoadGameType classic]` (manifest.md:191) |
| (c) each feature off | 29–31 | 0, except FUF off → Castbars | — |
| (c+) single folder off | — | FUF off → Castbars, FUFDefaults · Quartz off → Castbars · Core off → ChatSetup, FUFDefaults · Details off → Details_TinyThreat · Masque off → Masque_Onyx | all are the intended "turn the parent off, the child does not load" behaviour |
| (d1) proposed install ZIP, PitBull4 default (§5) | 30 | 0 | — |
| (d2) proposed install ZIP, FUF variant | 32 | 0 | — |

- Duplicate folder names: 0 in every combo. No TOC without a 16001 line, no `forever_load` check/no folder.
- Missing optional deps (b1, information only): standalone library names the addons embed (Ace3, LibSharedMedia-3.0, LibDBIcon-1.0, LibDataBroker-1.1, LibDualSpec-1.0, LibWindow-1.1, AceGUI-3.0-SharedMediaWidgets, AceGUI-3.0_SFX-Widgets, LibKeyBound-1.0, FlyPaper, LibSink-2.0, LibAlts-1.0, LibChatAnims, LibGraph-2.0, NickTag-1.0, SharedMedia), client `Blizzard_TimeManager` (SexyMap), and integrations we do not ship (Clique for Grid2; ConsolePort, ElvUI, WeakAuras for Hekili). PitBull4 build adds its own embedded-lib names and Clique. Nothing to fix.
- Files named in our TOCs and in PitBull4's `libs.xml`/`load.xml`/`modules_Camelot.xml`: 118 listed, 0 missing.
- Our own hard deps: `ChatSetup` → Core (Core not used in `ChatSetup.lua`; already listed as Phase 4 minor 5), `FUFDefaults` → Core + FUF, `Castbars` → Quartz + FUF (Core optional). `StatusStrip` has no Core dep and does not use Core. `PitBull4` has no dep on us.

## 2. Registry vs manifest vs TOC

- `genregistry.py --check`: Registry.lua up to date.
- SavedVariables names and scope (account / character) of all 73 registry entries re-parsed from the TOCs on disk: **0 mismatches** (incl. `_detalhes_database` character, `Prat3CharDB`/`Prat3HighCPUPerCharDB` character, `DevilForever_ChatSetupDB` character, `PitBull4DB` account).
- Every folder of every install combo is registered (0 missing).
- **Finding R-1 (medium): 39 registered folders are in no install combination.** Dropped Phases still registered as start packages: `ForeverThreat` (11, merged R107 ②), `TipTac`×4 (12, R100), `Bagnon`/`BagBrother`×5 (13, R100), `Platynator` (14, R107 ③), `Titan`×16 (16, R107 ⑤), `!KalielsTracker` (17, R100), `Mapster` (18, R100). Unshipped sub-folders of kept packages: `Details_Compare2`/`DataStorage`/`EncounterDetails`/`RaidCheck`/`Streamer`/`Vanguard` (Phase 10 DQ4), `Dominos_Cast`/`_Progress`/`_Roll` (Phase 7 DQ2, plan 231, 241). Cause: `Collection/tools/extract.py:78–112` `FEATURE_PHASES` still marks Phases 11–18 as `start` (written before R100/R107), so `manifest.json` role = start and `genregistry.manifest_entries` (genregistry.py:120–148) takes every folder of every start package. Runtime effect today is nil (Core never resolves frame globals; `Profiles.registryTargets` only takes SVs with a restore kind — of the 39 only `Details_Streamer` has one, `registry_extra.json:948–950`), but the registry is the declared source of truth for Phase 20/23 (TRIAGE_phase2 M3) and it now lists folders that will never be there. `Aurora` stays pending (Codex decides) — keep it registered until the verdict.
- **Finding R-2 (medium): our own folders and the PitBull4 fork are not in `manifest.json`.** Plan 403 asks per addon: folder, role, start addon, original version, SHA256, licence files, kind (settings/skin/fork/new), deps, SVs. `manifest.json` holds only the 39 extracted packages. The registry fills our folders from their TOCs with `package = "DevilForever"`, `use = "new"`, `phases = []` (genregistry.py:165–178) — for `PitBull4` that reads "new", not "fork of PitBull4 v4.2.50 + `Collection/patches/PitBull4.patch`".
- Stale `how_to_use.reason` text in manifest.json (low): Hekili still names `DevilForever_Combat` (dropped R104 — Phase 8 Result calls it a record), Experience Forever reason says "feature_phases·role 칸은 A2 가 … 다시 만든다", dropped packages still say `settings`. Goes with R-1.
- Phase 7 minor 3 (Quartz Focus frame may not exist on Forever): **closed** — Core never looks frames up (`_G[...]` is used only for saved variables: Defaults.lua 204–397, Profiles.lua 475–1067, Presets.lua 283–342, Spec.lua 32; `Edit.lua:44–80` indexes frame keys only). The appearance code (Codex) must nil-check `_G[frame]`; that rule is Codex's (appearance-2 §2).

## 3. Load-order assumptions

| Assumption | Where it lives | Static status |
|---|---|---|
| Core loads before every target addon: folder name `!DevilForever_Core` sorts first | TRIAGE_phase2 C1(a); test "Core sorts first" (tests/core/run.py:459) | holds for every combo: the only other `!` folders are `!BugGrabber` (sorts before Core, no Core target, no deps) and `!KalielsTracker` (dropped). No target addon is a dependency of a folder that sorts before Core, so nothing pulls a target in early |
| Core's `ADDON_LOADED` handler runs before the target's own handler for the same event | Defaults.lua header (line 45), TRIAGE_phase2 N3 | assumption; Codex phase2 brief checks it |
| Defaults write only into new AceDB profiles / fresh plain SVs at login window | Defaults.lua header 21–61, TRIAGE_phase6-rev M1/N1 | unchanged by any combo; a target that is absent just stays "waiting" |
| Profiles restore writes at the target's `ADDON_LOADED` before the addon reads its SV | Profiles.lua 20–, 1066 | same event-order assumption as above |
| Hard deps order our bridges after their parents | Castbars → Quartz, FUF; FUFDefaults → Core, FUF; ChatSetup → Core | client loads deps first; OK |
| `StatusStrip` does not need Core | no Core reference in StatusStrip.lua | OK; a future `DevilForever_Skin_StatusStrip` (Codex) must declare Core |

No defect found.

## 4. One function, two addons

| Pair | What happens now | Build / briefs | Verdict |
|---|---|---|---|
| FUF vs PitBull4 | Same function. WoW has no "conflicts with" TOC field, so if both folders are present both load. The current ZIP ships `PitBull4` and the FUF bridges together; FUF comes from References | phase6-rev.md header and phase15.md item 4 say never both on; no install doc yet | **Fix F1**: install ZIP ships only the default build; install notes say how to swap |
| FUF cast bars vs Quartz | `DevilForever_Castbars` hides the FUF bar of a unit for the session while that Quartz module is on; Quartz hides the game cast bar itself. PitBull4 build: CastBar module off | phase7.md header | OK (game check = Codex phase7) |
| Nameplate cast bar vs Quartz | Phase 14 records whether the game nameplate shows casts (phase14.md:44); appearance-14 §3 leaves the final call to Phase 23 | no result yet (R109) | Provisional (A2 judgment): **keep** the nameplate cast bar — it shows casts of every enemy with a nameplate, Quartz only target/focus/pet, so it is not the same job; Codex may make it small. Re-decide when the phase14 result arrives (Decision Queue 4) |
| Dominos_Cast / _Progress / _Roll | Not in our build (we ship no Dominos folders yet) | phase7.md:13 and phase8.md:9 exclude Dominos_Cast; **phase3.md:8, phase15.md:10, phase20.md:9 still install `Dominos_Cast`** (phase15 item 4 also installs Quartz → two player cast bars during the Aurora overlap check). _Progress/_Roll excluded everywhere | **Fix F4** |
| Game XP bar vs Experience Forever | EF hides `StatusTrackingBarManager` by alpha + mouse off, default `hideDefaultXpBar = true` (ExperienceForever.lua:82, 1215–1240). Dominos hides only action bars (actionBar/module.lua:13–60) | phase19.md header | OK |
| Hekili vs Cooldown Manager | Hekili: Primary display + button glow only (Defaults/Hekili.lua 7–13, 25); Cooldowns/Defensives/Interrupts displays only when their toggle is "separate". Status/CD = game Cooldown Manager (R104) | phase8.md:11, item 5 | OK — different jobs by R104 |
| Details windows vs third chat window | Details chat-tab embed stays off (Details default); appearance-10 forbids the third chat window's place (R33); ChatSetup makes window 3 for system messages | phase10.md:10, appearance-10 §1 | OK |
| Grid2 vs FUF/PitBull4 raid | FUF: `DevilForever_FUFDefaults` sends `/fuf raid off` once per character when Grid2 is loaded; FUF party stays. Grid2 defaults: solo/party/arena layout None, show in raid only. PitBull4 build: no raid group, party group shows in party only | phase6.md, phase9.md, phase6-rev.md | OK (Phase 6 minor 5: if the user later turns Grid2 off, FUF raid stays off — listed) |
| Minimap clock vs status-strip clock | SexyMap default `TimeManagerClockButton = "always"` (Defaults/SexyMap.lua:70) and the strip clock is on (24 h, PC time) | appearance-16.md:45 and DECISIONS_28a DQ-3: user decides | Not a fix: final-report item (Decision Queue 5). Note: strip = PC local time, minimap clock = game setting (realm or local), so the two can differ |

## 5. Install ZIP vs manifest

Current `outputs/collection/DevilForever-collection.zip` (sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874`, tracked in git, rebuilt in scratch → identical bytes):

| Folder | Files |
|---|---|
| `Interface/AddOns/!DevilForever_Core/` | 18 |
| `DevilForever_Castbars/` | 2 |
| `DevilForever_ChatSetup/` | 2 |
| `DevilForever_FUFDefaults/` | 2 |
| `DevilForever_StatusStrip/` | 2 |
| `PitBull4/` | 309 |
| + `Interface/`, `Interface/AddOns/` directory entries | 337 entries |

- **No manifest and no SHA256 list inside** (plan 411; also Phase 2 Result open item) → **Fix F1**.
- No upstream folder inside; `build.py` always adds every `Collection/AddOns/` folder (no exclude), so a unit-frame-specific ZIP cannot be built today (dry run with the proposed list gave 32 folders, not 30).
- This ZIP is the **verification ZIP**: 26 briefs quote its sha256 and tell Codex which of its folders to take. Changing its bytes means editing every brief (TRIAGE_phase16/19 pattern). Proposal: leave it as is and build the user's install ZIP as a separate file `outputs/collection/DevilForever-<판>.zip`, the name plan 411 already uses.

### D4 install list proposal (A2 judgment)

Facts weighed: all 71 reference ZIPs are already committed on the public main (`git ls-files References`), so shipping the same unmodified folders inside our ZIP adds no new exposure (D4 (나), R83 — user carries the licence risk; Details and Onyx licence notes stay in the final report). R101 counts addons, not ZIPs: shipping the originals does not add a single addon, it only removes manual steps. Without them the user must open 10 ZIPs and pick sub-folders by hand (Dominos 3 of 6, Details 2 of 8, Hekili 11, Grid2 3) — the error-prone part.

**Ship in the install ZIP** (unmodified, folder subset, versions pinned by manifest):

| Package (version) | Folders |
|---|---|
| Masque 12.1.8 · Masque Onyx 12.1.6 · ProfileManager 4.0 (required bundle) | `Masque`, `Masque_Onyx`, `ProfileManager` |
| Dominos 12.0.4 | `Dominos`, `Dominos_Config`, `Masque_Dominos` |
| Prat-3.0 3.9.117 | `Prat-3.0` |
| SexyMap v12.1.7 | `SexyMap` |
| Quartz 3.8.0 | `Quartz` |
| Hekili v0.8.6-forever | `Hekili`, `Hekili_Shared`, 9 class modules |
| Grid2 4.1.13-forever | `Grid2`, `Grid2Options`, `Grid2LDB` |
| Details 20261109 | `Details`, `Details_TinyThreat` |
| Experience Forever 2.0.4 | `ExperienceForever` |
| ours | `!DevilForever_Core`, `DevilForever_ChatSetup`, `DevilForever_StatusStrip` + the default unit-frame build (§6): `PitBull4` (fork) — or, for the FUF variant, `ForeverUnitFrames` + `DevilForever_Castbars` + `DevilForever_FUFDefaults` |

= 30 folders (PitBull4 default) / 32 (FUF variant); tocdeps unresolved 0 for both.

**Do not ship**: `Dominos_Cast`, `Dominos_Progress`, `Dominos_Roll`; the six other Details plugins; `PitBull4_DogTagTexts` (our profile uses LuaTexts); Aurora until Codex says "use"; BugSack/!BugGrabber (verification tools, install from `References/addon-sources/` only for Codex runs); the non-default unit-frame build (kept in the repo for the swap); every comparison/dropped package.

## 6. Unit-frame default — provisional (A2 judgment, to confirm with Codex phase6-rev item 7)

**Provisional default: PitBull4 build (`v4.2.50-forever.1`). FUF stays as the fallback build.**

Reasons:
1. The user's own history and lean: R105 「계속 핏불만썼는데 FUF를 쓰는게 맞는지 모르겠어」, R107 ① 「핏불 고쳐줄 사람은 없지만 AI는 있잖아 너」.
2. Its defaults are the user's own V42 Devil profile (`Defaults/PitBull4.lua` from `!DevilUI/Profile/PitBull4.lua`).
3. Fewer addons (R101): 1 folder, no bridge. FUF needs `DevilForever_Castbars` + `DevilForever_FUFDefaults` (3 folders).
4. AceDB: defaults only into new profiles, Phase 20 restore and spec profiles work through the AceDB path (`unitframes-compare.md` §4).
5. No raid group → no Grid2 overlap without a helper.

Against (why it is only provisional):
- It is a fork (72 files, patch 9,291 lines): auto-update must be off, every new upstream version must be re-ported; plan R87 order ("use as-is first") points to FUF.
- Game load, taint and the Forever debuff path are unverified; the V42 "Confirmed Forever" mark was for the V42 build.
- Devil profile turns off heal prediction, range fade and totem icons and makes no boss frames (FUF has them on).

Switch rule: if the Codex phase6-rev run shows a load error, blocked-action/taint errors or a broken debuff display for PitBull4, the default becomes FUF; otherwise the Codex/user comparison table (compare.md) decides. Either way the swap is folders only (install notes below).

## 7. Install notes (draft for the master to place — Korean)

> 데빌 포에버 모음집 — 처음 설치 안내
>
> **설치 전**
> 1. 게임을 완전히 끈다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사해 둔다. 되돌릴 때는 이 두 폴더를 그대로 되돌려 놓는다.
> 2. 설치 ZIP 을 `_forever_` 폴더에 푼다. `Interface/AddOns/` 아래에 폴더가 들어간다. 같은 이름 폴더가 이미 있으면 그 폴더를 백업 쪽으로 옮긴 뒤 넣는다. ZIP 안 `DevilForever-install/SHA256SUMS.txt` 로 파일이 온전한지 볼 수 있다.
> 3. 폴더 이름 `!DevilForever_Core` 는 `!` 로 시작한다 — 맨 먼저 불러오게 하려는 이름이니 바꾸지 않는다.
> 4. CurseForge 앱·WowUp 같은 관리 프로그램을 쓰면 **PitBull4 는 「업데이트 무시」(자동 업데이트 끔)** 로 둔다. 켜 두면 Forever 용 고침이 없는 원본으로 덮인다. 다른 애드온은 고치지 않은 원본이라 업데이트해도 되지만, 판이 바뀌면 모음집 기본값이 맞지 않을 수 있다.
>
> **같은 일을 하는 애드온을 함께 켜지 않는다**
> - unit 프레임은 PitBull4 와 Forever Unit Frames(FUF) 가운데 하나만 켠다. 모음집 기본은 PitBull4 다.
> - FUF 로 바꾸려면: 게임을 끄고 FUF(`References/forever-addons/Forever Unit Frames/` 의 ZIP 안 `ForeverUnitFrames`)와 모음집의 `DevilForever_Castbars`·`DevilForever_FUFDefaults` 를 넣은 뒤, 캐릭터 선택 화면 애드온 창에서 PitBull4 를 끄고 셋을 켠다. 되돌릴 때는 반대로 한다.
> - Dominos 묶음의 `Dominos_Cast`(시전바는 Quartz 가 맡는다)·`Dominos_Progress`(경험치는 Experience Forever 가 맡는다)·`Dominos_Roll` 은 넣지 않는다.
>
> **캐릭터마다 처음 한 번**
> - 대화창 3개: 대화창이 아직 기본 상태인 캐릭터로 처음 접속하면 몇 초 뒤 「DevilForever: 대화창 3개를 만들었습니다. /reload 를 입력하면 설정이 마무리됩니다.」 가 뜬다. `/reload` 를 한 번 친다. 이미 대화창을 나눠 쓰던 캐릭터는 건드리지 않는다.
> - 위협 창(Tiny Threat): 대화창에 `/details new` 를 쳐서 Details 창 2 를 열고, 창 2 제목 줄의 모드 단추 → 「플러그인」 → 「Tiny Threat」 를 누른다. 그 뒤로는 Details 가 저장한다.
> - Grid2: 처음 켜질 때 Grid2 가 프로필 고르기 창(「Welcome to Grid2 …」)을 띄운다. 하나를 고른다(검증에서는 「Modern」). 공격대일 때만 Grid2 가 보인다.
> - (FUF 를 쓸 때만) Grid2 가 켜진 캐릭터는 접속 20초쯤 뒤 FUF 공격대 프레임이 한 번 꺼진다(공격대는 Grid2 가 맡는다).
> - Cooldown Manager(상태 알림·재사용 대기시간): 게임 설정에서 꺼져 있으면 사람이 직접 켠다(애드온이 바꾸지 않는다).
>
> **쓰는 명령**
> - 설정 저장·되돌리기: `/dfp save <이름>` · `/dfp restore <이름>` 뒤 `/dfp go`(UI 를 다시 불러오며 적용). 취소는 `/dfp cancel`. 키 설정·게임 설정은 `/dfp keys …`·`/dfp game …` 을 칠 때만 다룬다. 매크로는 다루지 않는다.
> - 테마: `/dfp theme <이름>`(전투 중에는 안 된다).
> - 상태 띠: `/dfstatus`(칸 켜고 끄기, 시계 12/24 시간). 띠 전체는 애드온 창에서 끈다.
> - Experience Forever 설정: `/ef`. Hekili 추천 끄기: `/hekili disable`.
>
> **(Aurora 를 쓰기로 정해진 경우에만)** Aurora 는 접속·`/reload` 때마다 게임 설정 `questTextContrast` 를 4 로 바꾸고, Aurora 를 빼도 4 로 남는다. 원래대로 돌리려면 애드온 없이 `/run SetCVar("questTextContrast", <설치 전 값>)` 을 친다(설치 전 값을 모르면 `/run SetCVar("questTextContrast", GetCVarDefault("questTextContrast"))`). — 실제 줄은 Codex phase15 결과로 채운다.
>
> **아직 게임에서 확인되지 않은 것**: 모든 동작은 정적 검사와 코드 검수만 거쳤다. Codex 실사용 검증 결과가 올라오기 전까지는 미검증이다.

Sources of each line: backup/restore (phase2–22 item 0, TRIAGE_phase14 M2), auto-update (phase6-rev.md:18, plan 218), FUF/PitBull4 (phase6-rev.md header), Dominos_* (TRIAGE_phase7 DQ2, phase19 Result, plan 231/241), chat (phase4.md:11, :22; Phase 4 minor 3), Tiny Threat (appearance-10.md:7, TRIAGE_phase10 DQ1), Grid2 picker (phase9.md:23), FUF raid (phase6.md header), Cooldown Manager (phase8.md:53), commands (phase20.md header, phase22.md header, phase16.md header, phase19.md header, phase8.md:40), questTextContrast (appearance-15.md:13, TRIAGE_phase15 re-check 2). The `SHA256SUMS.txt` sentence and the `DevilForever-install/` folder name depend on F1 (Decision Queue 2).

## 8. Collected open minors

Proposal codes: **38** = fix now in Step 38 · **FR** = list in the final report · **L** = leave (closed or covered).

| Phase | Id | Item | Proposal |
|---|---|---|---|
| 0 | check-1 minors (11), recheck minors 1–6 | plan wording items, content not itemised in the triage | FR (records) |
| 1 | tool minors 2–5 | content not itemised in the triage ("경미 4건(도구)", Phase 1 Result) | FR |
| 2 | minor 2 / 3 | edit queue memory-only; `Clear` return mismatch (Phase 2 Result) | FR |
| 2 | minor a | Details per-character SV note for Phase 10 | L — registry carries `_detalhes_database` scope character, restore keys |
| 2 | Result open item | ZIP has no manifest/SHA list | 38 = F1 |
| 4 | minor 1 | temporary window placement (Codex fragment) | FR |
| 4 | minor 3 | `/reload` needed after window creation | L — install notes line |
| 4 | minor 4 | moving window-1 groups on pre-existing characters (R10 new environment) | FR |
| 4 | minor 5 | ChatSetup hard dep on Core although unused; no retry after `api-missing` | FR |
| 6 | minor 3 / 5 | `api-missing` permanent; FUFDefaults keys on Grid2 loaded, not on collection on/off | FR |
| 6 | DQ3 | warlock soul shards not shown (both builds) | FR (R61 gap) |
| 6-rev | minor 2 | LibDualSpec dead refs in other-flavour TOCs | L (other-flavour TOCs are not loaded on 16001) |
| 6-rev | minor 4 | Core-only install stacks frames until Codex fragment | FR |
| 6-rev | outside-map minor | applied record checked before newness | FR |
| 7 | minor 2 | FUF test-mode preview hidden while Quartz owns the unit | FR |
| 7 | minor 3 | Quartz Focus frame may not exist | L — checked §2 (Core never resolves frames) |
| 7 | DQ2 | Dominos_Cast out of the shipped set | 38 = F1 (list) + F4 (briefs) |
| 9 | Result | hiding Blizzard raid frames also hides raid tools (marks/ready check); Grid2 first-run template overrides look values | FR |
| 10 | DQ1 / DQ4 | Tiny Threat first-time note; ship Details + TinyThreat only | 38 = install notes (master) + F1 list |
| 14 | m4, m5, m-a, m-b, m-c, m-d, item-0 note | backup step in appearance briefs; nameplate layouts order; CVar per-layout; restore edge cases; "keep or drop" wording; result templates; move-to-backup wording | FR |
| 14 | DQ1 | nameplate registry keys after Codex appearance | L until Codex (Phase 25) |
| 14 | m3/DQ2 | nameplate cast vs Quartz | provisional §4, Decision Queue 4 |
| 15 | m1 | commit hash inside same commit | FR |
| 15 | re-check 3 minors (2) | no fallback when `GetCVarDefault` missing; item 1 no longer says where the default is used | FR |
| 15 | install note | questTextContrast line | 38 = install notes (master), filled from Codex result |
| 16 | n1 | `layoutRunning` can stick if `anchorShownItems` raises | FR |
| 16 | n2 | appearance-16.md:29 still offers `color.text.highlight` "단위·이름을 다른 색으로 나눌 때" against the one-colour-per-FontString rule (TRIAGE_phase16 M3) | 38 = F6 (one phrase, misleads Codex) |
| 16 | DQ-3 | minimap clock vs strip clock | FR — user decides (Decision Queue 5) |
| 19 | DQ2 / DQ5 | EF bar cannot be switched off; no path yet for Codex EF value file | FR / L until Codex |
| 20 | ②-b | whole-SV restore also restores other characters' data (accepted risk) | FR |
| 20 | re-check 2 minors (7) | undo re-attach to shared class profile; free name over own unused profile; unknown-key preset clears unfinished; cancel without reminder; Details half restore with unknown key; kept-notice noise; phase20 item 4 wording after rename | FR |
| 22 | minors (6) | status help omits 테마; untested combat paths; "not registered" wording; restore report says 테마 when absent; API.lua header notes; appearance-22 luacheck line lacks path | FR |
| 6-rev | auto-update | PitBull4 auto-update off | L — install notes line |

## 9. Fix list for Step 38

### F1 — install ZIP with manifest and SHA list (plan 411, D4) · medium
- **What**: add an install mode to `build.py` driven by one new list file (proposed `Collection/install.json`: own folders to ship, upstream folders by package, unit-frame variant). It writes `outputs/collection/DevilForever-<판>.zip` with `Interface/AddOns/<folder>/…` for the §5 list, plus `DevilForever-install/manifest.json` (per folder: origin = ours-new / ours-fork(base package, base version, patch path) / upstream(package, version, source ZIP sha256, licence files), role required/individual, SVs) and `DevilForever-install/SHA256SUMS.txt` (sha256 of every file under `Interface/AddOns/`). The default mode (verification ZIP) must give the same bytes as now.
- **Why**: plan 411 asks for manifest + SHA list in the ZIP; Phase 2 Result open item; D4 needs a concrete list; FUF and PitBull4 must not ship together (check 4).
- **Files**: `Collection/tools/build.py`, `Collection/install.json` (new), `outputs/collection/DevilForever-<판>.zip` (new).
- **Impact map**:

| Place | Verdict | Why |
|---|---|---|
| `Collection/tools/build.py` | fix | install mode, exclude of own folders not in the list, manifest + SHA writer |
| `Collection/install.json` | new | single list (also read by F2) |
| `outputs/collection/DevilForever-collection.zip` | check only | rebuild in default mode must stay `718c3f4a…` |
| 26 briefs' ZIP/sha lines | no change | verification ZIP unchanged |
| plan 411, Phase 23 detail plan | check only (master) | wording already names `DevilForever-<판>.zip` |
| `Claude/docs/INDEX.md` structure map | fix (master) | new file `Collection/install.json`, new output ZIP |
| install notes (§7) | check only | `DevilForever-install/` name |
- **Gates**: build twice → same sha; `unzip -l` folder list = §5 list; `sha256sum -c` of the SHA list on an extracted copy; tocdeps on the extracted tree unresolved 0; default-mode sha unchanged.

### F2 — registry without dropped / unshipped folders · medium
- **What**: (a) `extract.py` `FEATURE_PHASES`: Phases 11, 12, 13, 14, 16, 17, 18 packages → use `dropped` (role becomes comparison); rerun `extract.py --no-extract` → `manifest.json`/`manifest.md`; refresh the stale `how_to_use.reason` texts listed in §2 (Decision Queue 6). (b) `genregistry.py`: register an upstream folder only when it is in `install.json` or named in `registry_extra.json` (keeps `Aurora` pending). (c) `registry_extra.json`: drop the `Details_Streamer` entry (not shipped, Phase 10 DQ4 — Decision Queue 7). Regenerate `Registry.lua`, rerun `tests/core/run.py`.
- **Why**: check 2 finding R-1; registry = source of truth for Phase 20/23 (TRIAGE_phase2 M3).
- **Files**: `Collection/tools/extract.py`, `Collection/manifest.json`, `Collection/manifest.md`, `Collection/tools/genregistry.py`, `Collection/AddOns/!DevilForever_Core/registry_extra.json`, `Collection/AddOns/!DevilForever_Core/Registry.lua`.
- **Impact map**:

| Place | Verdict | Why |
|---|---|---|
| extract.py 78–112 | fix | stale table |
| manifest.json / manifest.md | fix (regenerated) | role / phases |
| genregistry.py 120–148 | fix | install-list filter |
| registry_extra.json 948–950 | fix | Details_Streamer |
| Registry.lua | fix (regenerated) | — |
| tests/core/run.py 445–560 | check only (fix if an assertion counts all folders) | current asserts look up named folders only |
| Profiles.lua `registryTargets` 168–175, Spec.lua 30–32, Presets.lua 68–90, Edit.lua 44–80 | check only | fewer entries; Details_Streamer leaves the restore set |
| phase20.md | check only | does not name Details_Streamer (grep 0) |
| design-32.md, Results, triages | no change (records) | — |
| verification ZIP + 26 briefs' sha | **fix together** if Registry.lua changes (it is inside `!DevilForever_Core` of the verification ZIP) | TRIAGE_phase16/19 pattern; see Decision Queue 1 |

### F3 — our folders and the PitBull4 fork in the manifest · medium
- **What**: `extract.py` adds a `collection` section to `manifest.json`/`manifest.md` from `Collection/AddOns/` TOCs plus a small hand table (feature Phase, role, kind new/fork, base package + version + patch path for PitBull4, licence files). `genregistry.py` takes package/use/phases of own folders from it (PitBull4 → package `PitBull4`, use `modify`). F1's install manifest reads the same section.
- **Why**: plan 403 contract; check 2 finding R-2.
- **Files**: `Collection/tools/extract.py`, `Collection/manifest.json`, `Collection/manifest.md`, `Collection/tools/genregistry.py`, `Registry.lua`.
- **Impact map**:

| Place | Verdict | Why |
|---|---|---|
| extract.py manifest writer 380–440 | fix | new section |
| genregistry.py `own_addon_entries` 151–179 | fix | metadata from manifest |
| Registry.lua | fix (regenerated) | — |
| tests/core/run.py 513–518, 539 | check only (fix if `use` asserted for PitBull4) | Castbars `use = "new"` stays |
| API.lua header 3–8 | check only | field meanings unchanged |
| verification ZIP + briefs' sha | fix together with F2 (one rebuild) | Registry.lua inside |

### F4 — briefs install Dominos_Cast · medium
- **What**: remove `Dominos_Cast` from the install lists phase3.md:8, phase15.md:10, phase20.md:9 and from the addon-window lists phase3.md:21, :72; phase3.md:8 reason for `_Progress`/`_Roll` → "모음집에서 쓰지 않는다"; fix any folder count in the same items' expected results.
- **Why**: Phase 7 decision (TRIAGE_phase7 DQ2, phase7.md:13); phase15 item 4 would show two player cast bars (Quartz + Dominos_Cast) while Codex judges Aurora overlap.
- **Files**: `Collection/codex-briefs/phase3.md`, `phase15.md`, `phase20.md`.
- **Impact map**: phase7.md item 7 — check only (installs Dominos_Cast on purpose to test the double bar); phase8.md:9 — check only (already excludes); appearance-3.md — check only; ZIP/sha — no change.

### F5 — install notes text · low (master places)
- **What**: §7 draft; where it goes is a master decision (Decision Queue 2: also inside the install ZIP as `DevilForever-install/설치안내.md`).
- **Files**: target chosen by master; if inside the ZIP, `build.py` (F1) copies it.

### F6 — appearance-16.md:29 one phrase · low
- **What**: drop "단위·이름을 다른 색으로 나눌 때 `color.text.highlight`" (or say it applies to a whole FontString only).
- **Why**: TRIAGE_phase16 M3 one-colour contract; n2.
- **Files**: `Collection/codex-briefs/appearance-16.md`. **Impact**: appearance-16 gold line (check only), StatusStrip.lua (no change).

## Decision Queue (defaults chosen, master/user to confirm)

1. **Verification ZIP rebuild** — F2/F3 change `Registry.lua`, which sits inside the verification ZIP. Default: rebuild it once at the end of Step 38 and update the sha line in all briefs in the same step (Codex has not run any brief yet, R109). Alternative: leave the verification ZIP and briefs on the old Registry until Phase 25.
2. **Install ZIP shape** — default: separate `DevilForever-<판>.zip` (판 = Core TOC Version `0.1.0`), with `DevilForever-install/{manifest.json,SHA256SUMS.txt,설치안내.md}` at the ZIP root (extracts next to `Interface/` in `_forever_`). Alternative: put them inside `!DevilForever_Core/`.
3. **Unit-frame default** — provisional PitBull4 (§6); user/Codex confirm.
4. **Nameplate cast bar** — provisional keep (§4); confirm after the phase14 result.
5. **Minimap clock vs strip clock** — user decides (appearance-16:45, DECISIONS_28a DQ-3); final report.
6. **Stale manifest reasons** — default: rewrite the `how_to_use.reason` texts with F2 (manifest is live data, not a record); Phase 8 Result called the Hekili one a record — master decides.
7. **Details_Streamer restore entry** — default: remove with F2 (not shipped). Alternative: keep in case the user adds the plugin later.
8. **Registry `phases` type** — the registry holds integers; Phase "6-rev" for PitBull4 (F3) needs either a string or `6` with use `modify`. Default: `6` + use `modify` + `variant = "6-rev"` field.
9. **D4 list** — §5 list as default; user confirms whether unmodified originals ship (default yes).

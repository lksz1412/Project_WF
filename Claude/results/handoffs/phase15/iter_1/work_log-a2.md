# work_log — Phase 15 · Step 27 · A2 문서 서브 (iter 1)

작업: Aurora 12.1.5.4 Codex 발주문 둘 저작. 고친 파일 = 새로 만든 셋(아래). 그 밖은 읽기만.

## 만든 파일

| 파일 | 줄 수 | 내용 |
|---|---|---|
| `Collection/codex-briefs/phase15.md` | 88 | 실사용 검증 발주문 10항목(0–9), 항목마다 하는 법·기대 결과·결과 한 줄 양식 |
| `Collection/codex-briefs/appearance-15.md` | 24 | 외관 발주문 — 갈래 A(사용: `DevilForever_Skin_Aurora`)·갈래 B(안 씀)·올릴 것·기준 |
| `Claude/results/handoffs/phase15/iter_1/work_log-a2.md` | — | 이 파일 |

## 읽은 범위 (판단 근거)

- 마스터 플랜 `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: 145–155(늘 지킬 제약, R101 줄 150), 225–229(Phase 표 13–17, 15 = 227), 245–249(제외 표, 버프·디버프 = 247), 338–362(Codex 외관 발주문 341–352 · 실사용 검증 규칙 354–360), 445–449(Phase 별 검증 나눔, 15 = 447).
- 본보기: `Collection/codex-briefs/phase14.md` 1–77 전문, `appearance-14.md` 1–34 전문, `appearance-2.md` 1–36 전문, `appearance-2-layouts.md` 1–35 전문. `phase10.md` 1–20, `phase8.md` 8 · 절 머리 13–79(5번 = Cooldown Manager), `phase3.md` 8, `phase9.md` 8–9, `phase6-rev.md` 1·5·9·14·18, `phase1.md` 51·58 (ZIP 경로·sha256 행만).
- Aurora: `References/addon-sources/aurora/SOURCE.txt` 1–7, `ANALYSIS.md` 1–17 전문. `Collection/upstream/aurora-12.1.5.4/`: `.extract-source.json` 1–15·210–222, `Aurora/Aurora.toc` 1–46 전문, `config.lua` 1–539 전문, `aurora.lua` 1–330 전문, `integration.lua` 1–510 전문, `compatibility.lua` 1–245 전문, `analytics.lua` 1–120 전문, `gui.lua` 240–260·1005–1133 + grep(옵션·슬래시 줄 위치), `Skin/init.lua` 1–391 전문, `Skin/api.lua` 1–367 전문, `Skin/color.lua` 300–435 + 함수 머리 grep, `Skin/theme.lua` 395–420 + 함수 머리 grep, `libs/Libs.xml`·`libs/Shim.lua` 1–30, `Skin/Interface/AddOns/AddOns_Forever.xml` 1–30 + 켜진 Script 줄 전체 목록(grep), `Blizzard_BuffFrame/Mainline/Blizzard_BuffFrame.lua` 1–99 전문, `Blizzard_NamePlates/Mainline/Blizzard_NamePlates.lua` 130–160 + 함수 머리 grep, `Blizzard_UnitFrame/Mainline/Blizzard_UnitFrame.lua` 10–54, 그 밖 스킨 파일은 진입 함수·옵션 검사 줄 grep 만.
- Core: `Collection/AddOns/!DevilForever_Core/API.lua` 1–77.
- 금지어 등재부 `.claude/tools/banned_lexicon.json` (구조·confirmed 항목, python).

## Aurora 에서 찾은 사실 (파일:줄 · 경로 앞머리 `Collection/upstream/aurora-12.1.5.4/Aurora/`)

1. TOC 하나, Interface `120105, 16001, …`(`Aurora.toc:1`), `## SavedVariables: AuroraConfig`(`:11`, 계정 공통), Forever 스킨 목록은 `AllowLoadGameType camelot`(`:36`). 따로 된 AuroraConfig 설정 애드온 폴더는 없다 — `AuroraConfig` 는 저장값 이름이다. 설정 창은 `gui.lua` 안(`/aurora`, `gui.lua:1010`).
2. 옵션과 기본값 `config.lua:13–56` (bags·banks·chat·loot true, mainmenubar false, fonts·tooltips·chatBubbles·chatBubbleNames·characterSheet·objectiveTracker·talentArtBackground true, buttonsHaveGradient true, customHighlight off, alpha 0.5, hasAnalytics true, gcMode smooth, colorMode Normal). 모르는 키는 로드 때 지운다 `config.lua:251–266`. Forever 저장값 주석 `config.lua:21–25`.
3. 옵션으로 끌 수 있는 스킨 = bags·banks·chat·fonts·tooltips·mainmenubar·loot·chatBubbles(`aurora.lua:285–306`), characterSheet(`aurora.lua:171`), objectiveTracker(`Skin/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_ObjectiveTracker.lua:291`). 끌 옵션이 없는 스킨 = 이름표(`Blizzard_NamePlates/Mainline/Blizzard_NamePlates.lua:138`), 버프(`Blizzard_BuffFrame/Mainline/Blizzard_BuffFrame.lua:42`), Cooldown Manager(`Blizzard_CooldownViewer/Blizzard_CooldownViewer.lua:185`), 게임 미터(`Blizzard_DamageMeter/Blizzard_DamageMeter.lua:53`), 공격대 프레임(`Blizzard_CompactRaidFrames/Mainline/Blizzard_CompactRaidFrames.lua:53`), 시전바(`Blizzard_UIPanels_Game/Mainline/CastingBarFrame.lua:65`).
4. Forever 목록(`AddOns_Forever.xml`): 버프 71, 대화창 124·129, 공격대 152, Cooldown Manager 157, 게임 미터 165, 이름표 361, 주문 창 378, 캐릭터 687(Camelot), 가방 706, 지도 726·779, 퀘스트 701·735. 설정 창 스킨 줄은 꺼져 있다 414–417, 미니맵도 꺼져 있다 350.
5. 버프 스킨은 아이콘 잘라 내기·임시 마법부여 테두리 지우기뿐 `Blizzard_BuffFrame.lua:12–31`.
6. 다른 애드온 감지: Prat(대화창)·Dominos(메뉴줄) 등 `compatibility.lua:13–75`. 경고만 찍고 자동으로 끄지 않는다(safe mode 일 때만 끔 `:157–171`), 2초 뒤 출력 `:229–231`, info 등급(Dominos)은 찍지 않음 `:190`.
7. 게임 전체 영향: GC 방식 바꿈 `Skin/init.lua:198–266`, 5분마다 `collectgarbage("collect")` `integration.lua:479–480,322`, 접속마다 CVar `questTextContrast`=4 `Skin/init.lua:342–344`, UI scale 은 기본으로 안 바꿈 `Skin/init.lua:56,70`, koKR 글꼴 `Fonts/2002.ttf` `Skin/init.lua:94–95`, 로드 때 대화창 출력 `Skin/init.lua:319–320,339`, 첫 실행 안내 창 `aurora.lua:327–329`.
8. 외부에서 걸 수 있는 길: 전역 `Aurora` `Skin/init.lua:154`, `Color.SetTokenOverride("frame"|"button", color|nil)` `Skin/color.lua:351–370`, `Color.SetMode` (저장값에 씀) `Skin/color.lua:406–422`, `Color.RefreshHighlightColor` `Skin/color.lua:679`, `Theme.SetGlobalAlpha` `Skin/theme.lua:402`, `Base.AddSkin`(호출마다 대화창 출력) `Skin/api.lua:42–50`.
9. 분석 정보: WagoAnalytics 는 그 애드온이 없으면 아무 일도 안 하는 대리 함수 `libs/Shim.lua:4–19`.
10. Aurora 는 Prat·Details·Grid2·Dominos·SexyMap·Quartz·FUF·PitBull4·Hekili 를 직접 스킨하는 파일이 없다(grep — 맞은 파일은 모두 낱말 우연 일치). 겹침은 그 애드온들이 쓰는 게임 기본 창(대화창 등)을 거쳐 생길 수 있다 → 실사용 4번.

## 명령 · 판정

| 명령 | 판정 |
|---|---|
| `sha256sum outputs/collection/DevilForever-collection.zip` | `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` — 발주문 값과 같음 |
| `sha256sum References/addon-sources/aurora/Aurora-12.1.5.4.zip` | `bd8b36a0…f3c` — `SOURCE.txt:7` 과 같음, 두 발주문에 같은 값 |
| `sha256sum` Prat·Details·Grid2·Dominos·SexyMap·Quartz·FUF·Hekili ZIP 여덟 | 모두 앞 발주문(phase3–10)에 적힌 값과 같음 |
| python `/run` 길이 검사(두 파일) | 6줄: 135·200·239·189·196·40 — 모두 ≤255 |
| python 항목 검사 | `phase15.md` 항목 10개, 모두 하는 법·기대 결과·결과 한 줄 양식 있음 |
| `grep -nE '정본\|거울\|문면\|문안\|전량\|발동\|수권'` 두 파일 | 0건 (rc=1) |
| 등재부 confirmed 항목 대조(python) | 0건 |

임시 파일: `/tmp/claude-0/-home-user-Project-WF/eb60f530-f589-5d62-967e-8afbddb90ec0/scratchpad/g15.L6kK/` (gates.py·lex.py·lex2.py). 지운 것 없음.

## A2 선택 (내 판단)

- 항목 순서: 옵션 원래 값 기록(3번)을 모음집 겹침(4번)보다 앞에 둠 — 4번에서 옵션을 끄기 전에 원래 값이 있어야 해서.
- `questTextContrast` 원래 값은 1번 (가) 에서 Aurora 를 끈 채 접속해 잼(Aurora 가 로드 때 바로 바꾸므로). 9번에서 되돌린 뒤 이 값과 견줌.
- 4번은 모음집 ZIP 의 `!DevilForever_Core` 만 넣고 `DevilForever_Castbars`·`DevilForever_ChatSetup`·`DevilForever_FUFDefaults` 는 넣지 않음 — 원본 애드온 창 위의 겹침만 보려고. Dominos 는 `Masque_Dominos` 빼고 셋.
- appearance-15 의 frame key 기본 제안 `aurora.windows`, Aurora 해상도별 값이 없으면 세 겉보기 파일에 같은 값.
- 이름표가 Phase 14 스킨을 고르면 Aurora 원본을 고치지 않는 한 Aurora 이름표 스킨을 끌 수 없음 → 판정 이유·남은 문제로 넘김.

## Decision Queue

1. Aurora 를 쓰고 이름표는 Phase 14 스킨만 남기기로 하면, Aurora 이름표 스킨(`Blizzard_NamePlates.lua:138–213`)은 옵션으로 못 끈다. 길은 (a) Aurora 원본 패치(PitBull4 처럼 `Collection/patches/`) (b) Aurora 이름표 스킨을 그대로 받아들임 (c) Aurora 안 씀. master 결정 필요 — 발주문은 Codex 가 결과로 적게만 했다.
2. Cooldown Manager(Phase 8)·버프·시전바·공격대·게임 미터 스킨도 끌 옵션이 없다. Phase 8 외관(`appearance-8.md`)과 겹칠 수 있음 — 같은 처리 필요할 수 있음.
3. Aurora 가 접속마다 `questTextContrast`=4 로 바꾸는 것은 Aurora 를 쓰는 동안 되돌려도 다시 4 가 된다(`Skin/init.lua:342–344`). 쓰기로 하면 이 CVar 변경을 받아들일지 master 확인 필요.
4. Aurora 의 GC 설정 변경은 게임 전체(다른 애드온 포함)에 걸린다. 6번 결과로 판단하게 했으나 받아들일지는 사용자·master 몫일 수 있음.
5. Forever 의 주문책·퀘스트 목록 창 이름(PlayerSpellsFrame/SpellBookFrame, QuestMapFrame/QuestLogFrame)은 확인 필요 — 2번 출력으로 확인.
6. `aurora.lua:219–221` 주석은 Camelot CharacterFrame 스킨이 「아직 없다」 고 하나 파일은 있다(`Skin/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/CharacterFrame.lua:139`, 293줄). 실제 걸리는지는 2번이 본다.

## fix 1 — 검수 B 결과 반영 (M1 · m2 · m3 · m4)

읽은 범위: `Claude/results/handoffs/phase15/TRIAGE_phase15.md` 1–26 전문, `Collection/codex-briefs/phase15.md` 5·12·85–86, `appearance-15.md` 13·24, `Collection/upstream/aurora-12.1.5.4/Aurora/Skin/init.lua` 328–346(Aurora 의 CVar 변경이 `C_Timer.After(0)` 로 미뤄짐 — 330·343).

영향 지도:

| 자리 | 판정 | 이유 |
|---|---|---|
| `appearance-15.md:13` | 함께 고침 | M1 — `questTextContrast` 원래 값 기록(우리 SV · 확인 안 되면 phase15 1번 (가) 값), 되돌리기 명령에 포함, 「Aurora 를 끄고 되돌리기」 순서, Aurora 만 빼면 4 로 남음 |
| `appearance-15.md:24` | 함께 고침 | M1 — 기준에 `GetCVar("questTextContrast")` 확인 추가 |
| `phase15.md:5` | 함께 고침 | m3 — `bugsack.txt` 를 따로 두는 파일 목록에 |
| `phase15.md:12` | 함께 고침 | m4 — 「접속·`/reload` 때마다」 |
| `phase15.md:85` | 함께 고침 | m2 — 원래 값이 아니면 `SetCVar` 후 다시 보기 · m3 — 올릴 목록에 `bugsack.txt` |
| `phase15.md:86` | 확인만 | 기대 결과 「`questTextContrast` 가 원래 값」 그대로 맞음 |
| `phase15.md` 1번(23–27) | 확인만 | M1 원래 값의 출처 — (가) 에서 이미 적음, 고칠 것 없음 |
| `appearance-14.md` | 영향 없음 | 본보기 규칙, 자기 CVar 만 다룸 |
| 기록(work_log 앞 절) | 영향 없음(기록) | |

명령 · 판정:

| 명령 | 판정 |
|---|---|
| python 치환(줄마다 한 번만 맞는지 assert) | 6곳 모두 한 번씩 바뀜 |
| `gates.py` `/run` 길이 | 8줄: 135·200·239·189·196·40·47(phase15:85) · 40(appearance-15:24) — 모두 ≤255 |
| `gates.py` 항목 | 10개, 모두 세 칸 있음 |
| 금지어 grep(두 파일) | 0건 (rc=1) · 등재부 confirmed 대조 0건 |
| `git diff --stat`(추적 파일) | 계획서만 — 두 발주문은 새 파일이라 untracked |

A2 선택: M1 원래 값은 「우리 로드 때 읽은 값이 Aurora 변경 전인지 게임에서 확인, 안 되면 phase15 1번 (가) 값」 — Aurora 의 변경이 다음 실행 틀로 미뤄져(`init.lua:330`) 우리 ADDON_LOADED 가 먼저일 가능성이 있으나 Claude 쪽에선 확인 못 함.

## fix 2 — 재검증 N1·N2 → master 원인 수정 설계 반영

읽은 범위: `Claude/results/handoffs/phase15/TRIAGE_phase15.md` 26–35(「Re-check 1」·「Root-cause decision」 전문), `Collection/codex-briefs/phase15.md` 23·24·25·27·85·86·88(바꾸기 전 줄 번호), `appearance-15.md` 13·24.

영향 지도:

| 자리 | 판정 | 이유 |
|---|---|---|
| `appearance-15.md:13` 의 `questTextContrast` 부분 | 함께 고침 | N1·N2 — 우리 애드온이 원래 값을 적거나 되돌린다는 약속 삭제, 애드온 없이 치는 `/run SetCVar("questTextContrast", GetCVarDefault("questTextContrast"))` 줄, 없으면 1번 (가) 값 줄, 보고서에 적어 Phase 23 설치 안내로, 「빼도 4 로 남는다」 유지 |
| `appearance-15.md:13` 나머지(AuroraConfig 옵션 규칙) | 영향 없음 | master 결정 — 그대로 |
| `appearance-15.md:24` | 함께 고침 | 기준을 「우리 코드에 이 CVar 줄 0 + 보고서에 되돌림 줄과 친 뒤 값」 으로 |
| `phase15.md` 1번 하는 법(23)·새 줄(25)·양식(28) | 함께 고침 | 기본값 기록 `/run print("qtc", GetCVar(...), "default", GetCVarDefault and GetCVarDefault(...) or "없음")`, 양식에 `기본값=<값/없음>` |
| `phase15.md` 9번 하는 법(86) | 함께 고침 | 되돌림 = 기본값 줄 먼저, 기본값 `없음` 이면 (가) 값 줄 |
| `phase15.md` 9번 기대 결과(87)·양식(89) | 함께 고침 | 「(가) 값이거나 되돌림 줄로 넣은 값」 — 기본값을 넣으면 (가) 값과 다를 수 있어서 |
| `phase15.md:12` | 확인만 | 「접속·`/reload` 때마다」 그대로 맞음 |
| 기록(앞 절) | 영향 없음(기록) | |

명령 · 판정:

| 명령 | 판정 |
|---|---|
| python 치환(맞는 곳 한 번 assert) | phase15 6곳 · appearance-15 2곳 모두 한 번씩 |
| `gates.py` `/run` 길이 | 11줄: phase15 135·122·200·239·189·196·40·70·47, appearance-15 70·40 — 모두 ≤255 |
| `gates.py` 항목 | 10개, 모두 세 칸 |
| 금지어 grep(두 파일) | 0건 (rc=1) · 등재부 confirmed 0건 |
| 옛 설계 남은 문구 grep(`SavedVariables 의 원래`·`되돌리기 명령은 이 CVar`) | 0건 (rc=1) |

## fix 3 — 재검증 2: N3 · n1

읽은 범위: `Claude/results/handoffs/phase15/TRIAGE_phase15.md` 37–41(「Re-check 2」 전문), `phase15.md` 23·86·87·89, `appearance-15.md` 13.

영향 지도:

| 자리 | 판정 | 이유 |
|---|---|---|
| `phase15.md:23` | 함께 고침 | n1 — 「`GetCVarDefault` 가 없거나 기본값을 주지 않는 것」, 9번 대체 안내 문구 뺌(9번이 이제 (가) 값만 씀) |
| `phase15.md:86` | 함께 고침 | N3 — 되돌림은 1번 (가) 값(이 사용자의 원래 값)을 넣는 `SetCVar` 줄 |
| `phase15.md:87` | 함께 고침 | N3 — 기대 결과 = 1번 (가) 의 값 |
| `appearance-15.md:13` | 함께 고침 | N3 — 설치 안내 줄: 원래 값을 알면 (가) 값 줄, 모르면 게임 기본값 줄 |
| `phase15.md:25`(기본값 기록 줄) | 확인만 | 설치 안내의 기본값 줄을 위해 그대로 둠 |
| `phase15.md:89`(9번 결과 한 줄 양식) | 확인만 — 고치지 않음(발주 범위 밖) | 칸 `questTextContrast=<(가) 값 그대로/되돌림 줄(기본값·(가) 값)로 넣음 · 값>` 의 「기본값」 이 이제 9번에서 안 쓰이는 길 — master 판단 대기 |
| 기록(앞 절) | 영향 없음(기록) | |

명령 · 판정:

| 명령 | 판정 |
|---|---|
| python 치환(한 번 assert) | phase15 3곳 · appearance-15 1곳 |
| `gates.py` `/run` 길이 | 11줄: phase15 135·122·200·239·189·196·40·47, appearance-15 47·70·40 — 모두 ≤255 |
| `gates.py` 항목 | 10개, 모두 세 칸 |
| 금지어 grep(두 파일) | 0건 (rc=1) · 등재부 confirmed 0건 |

## Decision Queue (추가)

7. `phase15.md:89` 9번 결과 양식의 「되돌림 줄(기본값·(가) 값)」 은 fix 3 뒤 「되돌림 줄((가) 값)로 넣음」 이 맞다 — 지정 줄 밖이라 그대로 둠.

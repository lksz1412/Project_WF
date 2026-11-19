# Step 46 기능 반증 작업 기록

2026-11-19T11:33:24+09:00

현재 기록은 작업 A의 근거와 중대도 후보를 담는다. 독립 검수 전이며 Step47 코드 수정은 별도 발주를 따른다. 소유 파일은 이 기록과 step46-findings.json 두 개다.

## 자연 단위별 수행

| 단위 | 근거·수행 | 게이트·판정 | 다음 소비 |
|---|---|---|---|
| 승인·기준 입력 | 현행 계획과 Phase26.1 결과 정독, 기준 ZIP 세 변형 데이터 확인 | 0.1.0/16001, 35·37·38폴더와 baseline 해시 식별 | 같은 과거 코드를 반증하는 기준 |
| 채팅 소유·실패 | 실제 패키지 ChatSetup/ChatLayout을 기존 Lua 시험 대역에서 호출 | 정상 보존 3 PASS. 이벤트 재배치 RED, 주입 예외 부분 진행 RED. master의 API 부재 31개 유실과 둘째 창 실패 12개 부분 이동을 파일로 대조 | F46-01–03 수정 게이트 |
| FUF 실제 연결 | 세 ZIP×세 해상도 preset 등록 평가. TOC와 native UnitProfiles/Storage/Config/Commands 대조 | 9개 등록 모두 FUF geometry 0. native Custom 선택과 legacy mirror를 별도 값으로 실행. source 4개와 ZIP 바이트 일치 | F46-04 보존·적용 계약 |
| 경험치·전투 담당 | actual preset의 XP 값 키와 제안 보고, Hekili 지원표의 현재 링크 대조 | XP 키는 font·texture·color뿐이며 가로는 공간 대안. R104와 폐기된 Combat 제안 잔존 | F46-05 수용 범위·F46-06 Step48 정정 |
| 나머지 갈래 | master의 8개 기존 시험 원출력, composition 39조합, clock boundary를 현재 트리에 연결 | 기존 정상 시험 반복 없이 범위를 한정. actual game 미검증 | 독립 검수와 라이브 확인표 |

## 기능별 범위

| 기능 | 요청 | 현재 근거 | 제한 |
|---|---|---|---|
| 공통 설정·저장·복원 | R44·R107·R148 | 기존 오프라인 시험 PASS 범위 | 기존 프로필·전투·버전·요청 대역 시험 108건. 게임 설정/키 경로는 명시 명령일 때만. |
| 채팅 | R112·R145 | 수정 필요 | 새 반증의 기대·관측은 findings와 원출력 참조 |
| 하단 조작·13종 테마 | R115·R130·R135·R136·R138·R140·R142·R143 | ZIP·Lua/TGA 대역 확인; 실게임 대기 | 39조합, 오른쪽 문양 크롭·알파와 유닛 겹침대 투명성. 실제 읽기/클릭/밝기·전투·소환수 표시 수명 미검증 |
| 시계·기존 사용자값 | R110 | 기본값과 보존 경계 확인 | 새 SexyMap never, 사용자 명시 always 보존. 현재 게임 시계는 미관측 |
| 전투·유닛 | R107·R110·R121·R140 | PitBull 위치 대역 통과; FUF 연결 수정 필요 | PitBull singleton 실제 함수 8×3 사각형. 기본 플레이어 Aura false는 보존된 기능값, 항상 켜라는 확정 선택 미확인. |
| 추천·기본 쿨다운·이름표 | R62·R99·R100·R104·R110 | 구분된 담당 확인; 실제 전투 대기 | Hekili 24 지원/4 미지원은 원천 분석. countdownForCooldowns와 viewer 네 개, 4K 글자는 게임 확인. |
| 그룹·Details | R95·R97·R107·R145 | 기존 오프라인 시험 PASS 범위 | 기존 창만 명시 apply, 6조합/28거절/부분원복. 실제 창2 생성·TinyThreat 모드·공격대는 별도 관측 |
| 성장·퀘스트 | R100·R132·R145 | XP 현행 세로·공간 대안 표기 정리; 기본 Quest 실측 대기 | 현재 세로 배치 유지. R132·R145의 실제 크기·현행 목업 일치 의무는 유지하고 Step48에서 가로 공간 대안을 구분. CDM/quest 실측 대기. |
| 배포 | R145·R151 | Phase26.1 기준 PASS 재사용 | 세 과거 입력 ZIP; 수정 후 새 빌드/해시 Step48 필요 |
| FUF 기존 저장·provider·매크로 백업 로딩 | R107·R110·R145 | SV 선기록 시 native 수명 변경 반증 | 실제 패키지의 UnitProfiles/Storage+대역 호출. 개인 매크로 API/실게임 데이터 접근 없음 |

## 중대·중간 후보와 수용 범위

등급은 작업 A 제안이다. 실제 게임 발생으로 사용하지 않는다. F46-05는 미채택 공간 대안과 현행 배치의 표기·수용 범위를 기록한다.

### F46-01 · 중대 후보

대상 창의 메시지 추가 API가 없으면 원래 창 구독을 제거하고 성공 기록.

조건은 새 캐릭터에서 frame.AddMessageGroup과 ChatFrame_AddMessageGroup이 없고 제거 API는 존재. 기대는 구독 변경 전에 거절, 또는 대상 구독 확인 뒤에만 원래 구독 제거.

관측값은 {"originalGroupsRemoved": 31, "destinationGroups": 0, "recordedResult": "created"}이다. 전달 실패를 성공으로 기록하므로 그룹·시스템 메시지 31종을 어느 새 역할 창에서도 받지 못할 수 있음.

직접 근거는 다음과 같다.

- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L75 — `local function addGroup(frame, group)`
- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L229 — `addGroup(chatFrame, group)`
- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L230 — `removeGroup(general, group)`

수정 뒤 확인할 조건은 다음과 같다.

- 추가/제거 API를 양쪽에 대해 변경 전에 확인
- 대상에 실제 구독된 상태에서만 원래 구독 제거
- API 없음 및 무효 반환 시 메시지 집합 전후 동일, 성공 표시 금지
- methods/global 두 정상 경로 유지

### F46-02 · 중간 후보

두 번째 창 실패 또는 구독 추가 예외 뒤 초기화가 일부만 저장됨.

조건은 첫 창 생성·구독 이동 뒤 두 번째 Open이 미예약 기존 창을 반환, 또는 WHISPER 추가 중 예외. 기대는 실패 시 초기 라우팅 보존과 재시도/복구 가능한 상태.

관측값은 {"secondOpenFailure": {"result": "no-free-window", "movedGroups": 12}, "injectedException": {"result": "in-progress", "movedGroups": 10, "groupsLostFromAllRoles": 0}}이다. 세 창 배치가 완성되지 않았는데 개인 라우팅을 일부 바꾸고 다음 로그인에서는 완료 이력 때문에 다시 시도하지 않음.

직접 근거는 다음과 같다.

- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L217 — `finish(db, "in-progress", windows)`
- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L219 — `local chatFrame = FCF_OpenNewWindow(localized(role.names), true)`
- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L222 — `finish(db, "no-free-window", windows)`

수정 뒤 확인할 조건은 다음과 같다.

- 두 목적 창을 확보·검증한 뒤 라우팅 이동
- 그룹·창 속성의 원복 가능한 범위를 변경 전에 저장
- 두 번째 창 거절과 이동 중 예외에서 기존 구독·수동 창 보존
- 기존 in-progress/interrupted 이력은 임의 재초기화하지 않고 안전한 복구 경계를 정함

### F46-03 · 중간 후보

자동 생성 채팅 창에 프리셋 변경을 반영하는 입구가 없음.

조건은 UHD에서 created한 창의 저장값을 유지한 채 QHD 활성 프리셋으로 재입장 또는 프리셋/배율 이벤트. 기대는 프로그램 관리 창은 선택한 프리셋 기준으로 재배치할 수 있고 사용자가 옮긴 창은 보존.

관측값은 {"systemX": 2910, "expectedQhdX": 1952, "newGeometryWrites": 0}이다. 배경은 선택 프리셋으로 바뀌어도 입력·출력 창은 옛 위치에 남음. 단위 픽셀 배율의 QHD 오른쪽 화면 밖 예시.

직접 근거는 다음과 같다.

- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L186 — `if db.result ~= nil then return db.result end`
- Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua L255 — `if db.result == "in-progress" then`
- Collection/AddOns/DevilForever_ChatSetup/ChatLayout.lua L37 — `local active = DevilForever_Core.Presets:GetActive()`

수정 뒤 확인할 조건은 다음과 같다.

- 기존 마지막 프로그램 배치와 사용자 이동을 구분할 위치 영수증 또는 명시 적용 계약
- 수동 분할·메시지 필터·창 닫기 보존
- 프리셋 변경과 /reload, UI_SCALE_CHANGED, DISPLAY_SIZE_CHANGED, 전투 지연 검증
- 초기 created만 있는 legacy DB를 무단 재배치하지 않는 전이 정의

### F46-04 · 중간 후보

FUF 대체판의 제안 좌표가 실제 설치 배치 경로에 연결되지 않음.

조건은 FUF 단독 ZIP 또는 비교판의 FUF로 처음 들어가도 공통 preset fragments에 FUF가 없음. 기대는 같은 해상도·공통 배치 기준에서 두 유닛 프레임을 비교할 수 있는 실제 적용 입구.

관측값은 {"presetRegistrationsEvaluated": 9, "fufGeometryFragments": 0, "fufAdapterTocFiles": ["FUFDefaults.lua"], "existingProfile": "Custom", "existingWidth": 211, "legacyDefaultWidth": 77}이다. 자산·공통 바만 준비된 상태로 FUF 원래 위치와 새 PitBull 배치를 비교하면 동일 조건의 비교가 어려움.

직접 근거는 다음과 같다.

- Collection/AddOns/DevilForever_FUFDefaults/DevilForever_FUFDefaults.toc L8 — `FUFDefaults.lua`
- Collection/AddOns/DevilForever_FUFDefaults/FUFDefaults.lua L118 — `elseif not send(handler, "raid off") then`
- References/codex-appearance/6/report.md L19 — `CLASSIC 테마를 바탕으로 FUF native 정수 설정을 제안한다. widths/heights/font/x/y는 physicalPx×pixelFactor/UIParentEff를 반올림한다. Single.Size가 footer·TOP portrait·spacing을 높이에 더하므로 LEFT/OFF portrait, footer0·내부 spacing0으로 외곽을 유지했다. player는 unitUpper, target은 unitLower다. party는 4명 세로 배치, pet은 오른쪽 첫 열, target은 다음 열로 두며 enabled·partyShowPets·partyTargets는 바꾸지 않는다. native border extent와 반올림 때문에 child 실제 x는 목표에서 몇px 달라질 수 있어 접속 검사 대상이다. boss는 5개 열의 자리만 미리 정했다. 기능·오라 개수/필터·시전바 설정은 바꾸지 않았다.`
- Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/UnitProfiles.lua L53 — `active = (type(chosen) == "string" and db.profiles[chosen]) and chosen or UnitProfiles.DEFAULT`

수정 뒤 확인할 조건은 다음과 같다.

- SavedVariables 선기록으로 Storage의 provider/legacy backup 복원·기다림을 건너뛰지 않음
- 표준 FUF API/설정 schema로 신규 기본값 또는 명시 배치 적용을 연결
- profiles[active]와 legacy profile mirror 및 raid, language, 기타 계정 프로필 보존
- Default에 고정된 AceDB profileKeys 규칙을 FUF에 적용하지 않음
- 기존 사용자 프로필은 자동 덮어쓰지 않고 명시 적용·검증된 원복
- 세 해상도 새 프로필과 기존 Custom, legacy profile, 전투/15초 storage waiting, 판 전환을 시험

새 geometry를 로그인 전 SV에 선기록하는 방식을 기본 해법으로 삼지 않음. 기존 native 로딩·백업 복원 수명을 유지. master actual packaged native Lua: empty SV calls macro-read once and waits; preseeded geometry selects SavedVariables, macro-read 0 and reserved-backup cleanup called once. 공개 명령 적용 후보는 Core/Commands.lua public /fuf set after native load and 15s waiting, explicit apply with snapshot/verification/rollback; implementation gate required. 해당 실행은 master의 대역 시험이다. 근거 파일은 _local_only/phase26-work-r151-20261119/step46-root/fuf-storage-guard.json.

### F46-05 · 수용·표기 범위 기록

경험치 가로 공간 대안과 현행 세로 배치의 수용·표기 범위 정리.

기존 보고는 가로 세 구획을 공간 대안으로 명시했다. 현행 설치본은 세로 배치를 사용하며, 가로 3분할을 채택한 명시 근거는 이번 범위에서 확인하지 못했다. R132·R145의 실제 애드온 크기와 현행 채택 배치의 목업 일치 의무는 유지한다.

관측값은 {"presetRegistrations": 9, "experienceKeys": ["barTexture", "baseColor", "fontName", "fontOutline", "petBarTexture", "petColor", "questColor", "repBarTexture", "restedColor"], "nativeLayout": "세로 쌓기라는 기존 보고와 기능 트리", "nativeRuntimeRerun": false}이다. 모사용 가로 대안과 현행 세로 배치를 같은 수용 기준으로 읽으면 실제 설치 크기·위치 판정이 어긋날 수 있다.

직접 근거는 다음과 같다.

- References/codex-appearance/19/report.md L21 — `24 JSON의 experience.main/reputation/pet 세 가로 사각형은 공간 대안이다. native 2.0.4는 세 막대를 세로로 쌓으므로 현재 runtime이 가로3분할됐다고 보고하지 않는다. 검은 띠10/12/16px 안에서 원래 본문 상하 슬롯과 rep/pet 문구를 모두 가독성 있게 보이는 native 저장값 조합은 없다. 필요한 변경은 원본 CreateFrames의 RepBar·PetBar SetPoint(대략556–585), Update의 재배치/표시(대략873–913), ApplyBarSizes/ApplyFontSettings(대략776–826), 상하 Texts slot anchor(357–367)다. 지금 발주 범위의 skin은 primary 위치/장식만 허용하므로 child 재앵커는 구현하지 않았다. 부모에게 경계를 보고했고 부모가 geometry·slot을 보존한 외관 조각만 먼저 준비하도록 지시했다.`
- Collection/data/feature-map.md L64 — ``| 경험치·평판·소환수 경험치 | `ExperienceForever` | 프리셋에서 질감과 글꼴 등록. 수직 막대와 표시는 `/ef`. [가로 배치 제안의 적용 범위](../../References/codex-appearance/19/report.md) |``

Step48에서 정리할 조건은 다음과 같다.

- 모사용 가로 공간 대안과 설치본의 현행 세로 배치를 목업·기능 지도·수용 기록에서 구분
- R132·R145의 실제 애드온 크기와 현행 채택 배치의 목업 일치 의무 유지
- 가로 3분할을 새 native 기능 변경 의무로 해석하지 않음
- 별도 명시 채택 없이 XP 본체·계산·자식 재앵커·사용자 프로필을 변경하지 않음

이 항목은 Step47의 XP native 기능 변경 게이트를 만들지 않는다. 현재 세로 배치를 유지한다.

### F46-06 · 중간 후보

기능 트리가 참조하는 Hekili 지원표에 폐기된 Combat 구현 지시와 CDM 결정 대기가 남음.

조건은 현행 feature-map의 직업 지원표 링크로 들어가 Step19 설계 입력과 결정 대기를 소비. 기대는 R104 이후 현재 선택과 역사 분석을 식별할 수 있음.

관측값은 {"installedCombatAddon": false, "oldPlanStillReadAsDesignInput": true}이다. 후속 작업자가 이미 폐기된 보완 모듈을 재설계하거나 결정된 CDM 선택을 다시 묻게 됨.

직접 근거는 다음과 같다.

- Collection/data/hekili-support.md L143 — ``**전체 판정(A1 판단):** 갈래 2. 보완 모듈 `DevilForever_Combat` 은 28개 특성 모두의 알림 꼴(화면 중앙 아이콘·소리·강조, 각각 끔 가능)을 맡는다. 무엇을 보일지(정적 표시 목록)는 특성마다 Hekili 직업 모듈 자료에서 고른다(원천 ①). 갈래 3 이 아니라서 D7 Codex 자료(②)는 「있는지」 를 위해서는 필요 없다. 다만 Hekili 자료 일부는 원천 스스로 「in-game check」 를 달았으므로 ID·지속 시간의 게임 안 확인은 Step 20 몫이다(결정 대기 3).``
- Collection/data/hekili-support.md L198 — ``1. **Forever 클라이언트 Cooldown Manager 를 쓸지** — 클라이언트에 버프·CD 아이콘 창 넷이 있다(`CooldownViewer.lua:29–30`, 추정). 보완 모듈 알림과 겹칠 수 있다. 기본값(A1): 이 단계에서는 건드리지 않고 Step 20 Codex 실사용 발주문에서 「켜져 있는지·겹치는지」 를 본다.``
- Collection/codex-briefs/phase8.md L11 — ``- 이 Phase 의 담당 나눔(R104): Hekili 는 **다음 행동 추천만** 보인다(화면 위 가운데 Primary 표시창, 전투 중 추천 능력이 놓인 단축바 버튼 빛남 — 우리 기본값이 켬). 상태 알림·쿨다운은 **게임 기본 Cooldown Manager**(창 넷: `EssentialCooldownViewer`·`UtilityCooldownViewer`·`BuffIconCooldownViewer`·`BuffBarCooldownViewer`)가 보인다. Hekili 는 치유 특성 넷(성기사·사제 신성, 주술사·드루이드 회복)에는 아무것도 보이지 않는다. 주술사부터 본다(R7). 대상은 훈련용 허수아비나 들판 몹이면 된다.``

수정 뒤 확인할 조건은 다음과 같다.

- 역사 원문은 보존
- 현재 기능 트리에서 정정/현행 지원표를 먼저 찾게 함
- 24 지원·4 미지원의 원천 사실과 폐기된 보완 제안 구분
- 현재 ZIP에 Combat 모듈 추가 없이 R104 소유권 명확히 유지

## 변경 전 영향 지도

| 곳 | 유형·찾는 방법 | 영향 | 사유 |
|---|---|---|---|
| 두 Step46 기록 | 신규 자료·같은 후보 ID. 기계 파싱·개수·경로 대조 | 함께 작성 | 같은 기능 범위·중대도·후속 게이트 |
| ChatSetup·ChatLayout·시험 | 소비 함수·전투·저장값·재배치. 전문과 ZIP 호출 | 확인만 | Step47의 API·부분실패·프리셋 수정 입구 |
| FUF 어댑터·native Storage/UnitProfiles/Commands | 입력 생성·공개 호출·기존값·대기·복원. 전문·ZIP 동일성·native 호출 | 확인만 | SV 선기록으로 복원 원천을 건너뛰지 않도록 경계 유지 |
| preset 세 개·XP·Hekili 기록 | 쌍둥이 배포 데이터·소비·역사제안 | 확인만 | geometry/문서 차이와 사용자 확정 선택 판정 |
| 기능 트리·접속 확인표·설치 목록·세 ZIP | 같은 값·원천·후속 입력·배포 | 확인만 | Step48 및 실게임 확인 연결 |
| 본체 코드·기존 시험·게임 저장값 | 기존 결과 보존 | 변경 없음 | Step46은 반증 근거 작성 |

## 실행 명령과 판정

새 실행 명령은 다음과 같다.

    python -X utf8 -B -I D:/Projects/Project_WF/_local_only/phase26-work-r151-20261119/step46-a/audit-pr1yyjq7/probe-step46.py

판정은 rc0, chat-preservation guards 3 PASS, injected exception과 preset event 각 RED, 실제 preset 9개 모두 FUF geometry fragment 0, FUF adapter raid-defaults만 로드, 실제 native UnitProfiles가 Custom=211·Default mirror=77·raid sentinel을 보존했다. RED는 기존 동작을 재현하는 감사의 성공이며 기능 수용 PASS가 아니다.

초기 실행 두 번은 대역의 Core.Log와 Hekili pixel-grid API 누락으로 rc1이었다. 대역을 정상 경로에 맞춰 보완한 뒤 같은 스크립트가 rc0으로 전부 완료했다. 제품 코드 실패와 대역 준비 오류를 구분한다.

원출력은 D:/Projects/Project_WF/_local_only/phase26-work-r151-20261119/step46-a/audit-pr1yyjq7/probe-output.txt, probe-output-fixed.txt, probe-output-final.txt 및 audit-results.json에 있다. 기존 suite 원출력은 _local_only/phase26-work-r151-20261119/step44-evidence/의 core/chat/details/integration/diagnostics/status/fuf/castbars.log이며 master의 실제 실행으로 구분했다.

## 정독과 데이터 확인 범위

| 파일 | 범위 |
|---|---|
| Codex/plans/2026-11-19-devil-forever-audit-and-installer-plan.md | 1–164 |
| Codex/plans/2026-11-19-devil-forever-audit-and-installer-phase26.2-세부계획.md | 1–36 |
| Codex/results/PHASE_26.1_audit-baseline_RESULT.md | 1–49 |
| Codex/results/Step 44 — 요청과 실제 기능 대조.md | 1–34 |
| Codex/results/Step 45 — 배포 기준 ZIP 검증.md | 1–37 |
| Collection/data/feature-map.md | 1–77 |
| Collection/install.json | 1–93 |
| References/codex-verify/one-session-review.md | 1–52 |
| Collection/AddOns/DevilForever_ChatSetup/ChatSetup.lua | 1–265 |
| Collection/AddOns/DevilForever_ChatSetup/ChatLayout.lua | 1–54 |
| Collection/tests/chatsetup/run.py | 1–449 |
| Collection/AddOns/DevilForever_FUFDefaults/FUFDefaults.lua | 1–170 |
| Collection/AddOns/DevilForever_FUFDefaults/DevilForever_FUFDefaults.toc | 1–8 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Storage.lua | 1–268 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/UnitProfiles.lua | 1–185 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Config.lua | 1–259 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Init.lua | 1–164 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Commands.lua | 1–143 |
| Collection/upstream/Forever_Unit_Frames-0.65.2/ForeverUnitFrames/Core/Boot.lua | 1–93 |
| References/codex-appearance/6/report.md | 1–25 |
| References/codex-appearance/6/fuf-profile.fragment.fhd.lua | 1–27 |
| References/codex-appearance/6/fuf-profile.fragment.qhd.lua | 1–27 |
| References/codex-appearance/6/fuf-profile.fragment.uhd.lua | 1–27 |
| References/codex-appearance/19/report.md | 1–23 |
| References/codex-appearance/8/report.md | 1–31 |
| Collection/codex-briefs/phase8.md | 1–84 |
| Collection/data/hekili-support.md | 1–202 |
| Collection/AddOns/!DevilForever_Core/Defaults/PitBull4.lua | 1–509 |
| Collection/AddOns/DevilForever_Skin_Nameplates/Appearance.lua | 1–125 |
| Collection/AddOns/DevilForever_Skin_NativeChat/Skin.lua | 1–150 |
| Collection/AddOns/DevilForever_Skin_Dominos/Skin.lua | 1–85 |
| _local_only/phase26-work-r151-20261119/step44-evidence/master-work.md | 1–31 |
| _local_only/phase26-work-r151-20261119/step44-evidence/chat-source-probe.py | 1–53 |
| C:/Users/lksz1/.agents/skills/skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md | 1–57 |
| C:/Users/lksz1/.agents/skills/skill_LKS_original_plan-execution/references/policies/feedback_unit_loop.md | 1–73 |
| C:/Users/lksz1/.agents/skills/skill_LKS_original_communication-decisions/references/policies/feedback_flow_interruption.md | 1–66 |
| C:/Users/lksz1/.agents/skills/skill_LKS_original_multi-session-orchestration/references/policies/feedback_session_division.md | 1–102 |

requirement-trace.md는 머리 결정표와 T1–T8, 지정 주요 행을 확인했다. 긴 한 행의 출력이 잘린 부분은 JSON에서 ID R44·62·99·104·107·110·112·121·140·145·148·151과 openItems 전부를 파싱했다. 요청표 151행 전체를 이번 A가 전문 재검한 것으로 세지 않는다.

package-baseline.json은 전체 파싱 후 variant ID·hash·interface·folder count·sourceFiles를 확인했다. preset fhd/qhd/uhd는 생성된 등록 데이터로 9회 전체 실행해 fragmentFolders와 XP 값 키를 얻었다. 해당 571행 세 파일의 모든 계산 경로를 전문 검수한 것으로 세지 않는다. UHD Hekili·Grid2·Masque 소비부와 FHD toolbar 등록 실패 문맥은 직접 읽었다.

chat-source-probe.json·chat-partial-window.json, 새 audit-results.json, master composition-path.json(39조합)·minimap-clock-boundary.json·fuf-storage-guard.json은 구조와 관련 모든 값을 파싱했다. 지목과 수치는 findings JSON에 남겼다.

## 결정 대기와 다음

R13 retail 원본 반영 근거, 실제 비교 이후 기본 유닛 프레임, 미지정 추가 해상도·4K 단독, 상단 Aura 항상 켜기 선택은 열린 상태다. 개인 데이터·미관측 게임 값을 보충하지 않는다. 실제 화면·전투·추천·Cooldown Manager·퀘스트 확인은 Step41에 연결한다.

다음은 master의 중대도 확인과 독립 B 검수다. 이후 같은 A가 명시된 Step47 코드·시험 변경을 이어받는다. 개인 프로필·매크로·WTF, Git 상태, 게임 및 다른 작업자의 본체 코드 변경은 수행하지 않았다.

## 산출물 기계 게이트

검사 명령은 python -X utf8 -B -I D:/Projects/Project_WF/_local_only/phase26-work-r151-20261119/step46-a/audit-pr1yyjq7/verify-output.py 이다. rc0으로 후보 6개·기능 10행의 필수 필드, 직접 원문 인용과 정확한 행, 근거 파일 존재, 3개 보존 PASS/2개 RED, 9개 preset 등록과 FUF native 선택값을 대조했다. 원출력은 같은 scratch의 verify-output.log에 있다.

기록 시각 2026-11-19T11:33:52+09:00

## 독립 검수 반영

F46-05를 구현 결함 후보에서 현행 세로·공간 대안의 수용 범위 기록으로 정정했다. Step47의 XP native 변경 게이트를 비우고 Step48의 표기·수용 정리로 연결했다. R132·R145의 실제 크기·현행 목업 일치 의무는 유지한다. 원문 인용은 코드로 감싸 문건 안 상대 링크가 잘못 해석되지 않게 했다.

수정 뒤 분류는 중대 후보 1·중간 후보 4·수용 범위 기록 1이며 기존 실제 호출·관측값은 동일하다. 기록 시각 2026-11-19T11:37:56+09:00

수정 검사 명령은 python -X utf8 -B -I D:/Projects/Project_WF/_local_only/phase26-work-r151-20261119/step46-a/review-doc-fix-ztzse6ua/verify-docfix.py 이다. rc0으로 중대1·중간4·범위기록1, XP Step47 게이트0·Step48 게이트4, 다른 발견·실행 근거·결정 대기 동일, 원문 인용18개 코드 표시를 확인했다. 최초 검사기의 인용 기대 개수16을 실제18로 정정한 뒤 통과했다. 출력은 같은 폴더의 verify-docfix-final.log에 있다.

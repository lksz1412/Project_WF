# Devil Black 기반 — WoW Forever 전체 직업 공용 애드온 모음집 계획

R44–R71 반영 검수용 후보 · 2026-11-18 · D:/Projects/Project_WF

지금 할 일은 저장된 마스터플랜과71개 요구 대응표를 완성해 독립 품질검수와 **사용자 검수**를 받는 것이다. root 통합·사용자 피드백/계획 갱신·명시 GO 전에는 기능 코드·설치·설정·게임 입력·이미지/목업을 제작하지 않는다. 자체 게임 애드온과 완성 목업은 아직 없다.

간략 목차 — 실제1–5 이력 보존, 이후는 미착수 미래 번호. ‘구현1’ 등은 사용자가 보는 기능 순번이며 내부 Phase ID와 함께 쓴다.

```text
1. 원형·기준·검수용 계획
   Phase1.1 원본 역사분석
     Step1 공개원본/profile 분석             45~90분 [완료]
     Step2 첫배치/style                     45~90분 [2022기준철회·동결]
   Phase1.3 옛원형·채팅·설계 인계
     Step3 전수원형/샘플 대조                60~150분 [수용0/0/1]
     Step4 Forever채팅 조사                  30~60분 [수용0/0/0]
     Step5 새원형4K 설계 인계                45~90분 [미완렌더/P4는39로이월]
   Phase1.2 준비/실제직업목록/시작제품 확정 [사용자 검수/GO 뒤]
     Step6 전체요구·환경/R13·실제직업목록     45~90분
     Step7 기능별시작제품/manifest/지원표     60~120분
2. 기능별 기존 애드온 수정·최신화 [한 기능=한 Phase]
   구현1 / Phase2.1 공통외관 — V42 DevilUI 기전/보존자산
     Step8 source/load/등록·외관기준          45~90분
     Step9 수정/최신화·공통외관 검증          75~120분
   구현2 / Phase2.2 행동단축바 — Dominos
     Step10 source/profile·배치 수정         45~90분
     Step11 paging/입력/키label 검증          45~90분
   구현3 / Phase2.3 미니맵 — SexyMap
     Step12 profile/사각지도/스타일 수정      45~90분
     Step13 지도입력/아이콘/저장 검증         30~60분
   구현4 / Phase2.4 native3chat 외형 — Prat
     Step14 관련source/부수동작·설정 수정     45~90분
     Step15 세역할/분류/입력/저장 검증        45~90분
   구현5 / Phase2.5 기본unit상태·직업자원 — FUF
     Step16 class/resource기능·source 확인    45~90분
     Step17 profile/연결 수정·상태검증        45~90분
   구현6 / Phase2.6 시전바 — Quartz
     Step18 source/profile·수정              40~60분
     Step19 시전/취소/target·중복 검증        30~60분
   구현7 / Phase2.7 설정 저장/범위복원 — V42 Reflux
     Step20 기존profile기전·지원범위 확정     45~90분
     Step21 수정/조정·snapshot/복원 검증      60~120분
   구현8 / Phase2.8 사용자 편집 — V42 Devilconfig
     Step22 기존설정UI/위치저장·지원면 확인   45~90분
     Step23 수정·사용자편집/되돌림 검증       60~120분
   구현9 / Phase2.9 직업별 전투보조 — 선택된 Hekili 기반
     Step24 정확Forever판/직업spec지원 검증   60~90분 [+N×15~30분]
     Step25 기존기능/데이터·profile/skin 연결 75~120분
     Step26 전수지원행렬·offline 사례검사     60~90분 [+T×15~30분]
   구현10 / Phase2.10 선택 공격대frame — Grid2
     Step27 정확제품/지원/독립로드 확인       45~90분
     Step28 설정/스킨 수정·조작/off 검증      45~90분
   구현11 / Phase2.11 선택 데미지meter — Details!
     Step29 정확Forever판/의존·source 확인    45~60분
     Step30 설정/스킨 수정·표시/off 검증      30~60분
   구현12 / Phase2.12 선택 어그로meter — ForeverThreat
     Step31 정확제품/지원/의존 확인           45~60분
     Step32 설정/스킨 수정·표시/off 검증      30~60분
   구현13 / Phase2.13 대안테마/조건부질감 — 공통외관의기존기반
     Step33 등록/style·실제질감 평가          45~75분
     Step34 두테마/필요개선·자산/스타일 검증   75~135분 [+조건부60~120분]
3. 가능한 연계검사/수정 뒤 최종 목업, 이후 실제게임
   Phase3.1 모음집 연계검증
     Step35 manifest/독립선택·공통/직업설정   60~90분
     Step36 가능한실행흐름·전환/부재/update   45~90분
   Phase3.2 연계 발견 수정
     Step37 확정gap/결함·영향수정             30~60분
     Step38 수정된연계 재검증                30~60분
   Phase3.3 최종 목업·offline 인계 [가능한작업닫힘이선행]
     Step39 최종4K/하단/테마·직업상태 비교    90~150분 [+V×15~30분,Step5렌더수신]
     Step40 고정목록·복원/미검증 인계         30~45분
   Phase3.4 실제게임 [접속가능·실제적용 별도승인]
     Step41 실제환경/R13재확인·백업/입력      45~75분
     Step42 주술사우선 실제전투/기능 확인     60~90분
     Step43 추가직업/spec 실제검증            30~60분 [+U×30~60분]
   Phase3.5 실제게임 발견 정정·고정
     Step44 확정결함수정                     30~60분
     Step45 해당연계 재검증                  30~60분
     Step46 실제통과범위·복원/버전 인계       30~45분
```

가능한 미래 Step6–40의 고정 부분은1690~3075분이다. 여기에 N×15~30분(실제 Forever 직업별 Hekili/provider 지원 판정), T×15~30분(중복 없는 class/spec·자원/전환 검사 사례), V×15~30분(서로 다른 최종 직업상태 상세)을 더한다. 기존 애드온 수정/설정으로 해결되지 않은 **입증된 gap**이 G묶음 생기면 G×30~90분을 그 기능 Phase에서 추가 산정한다. G는 직업별 자체 rotation/판단 엔진 수가 아니다. 필요가 관찰된 Devil 질감 개선은 별도60~120분이다.

실제게임 Step41–46은225~390분+U×30~60분(주술사 우선 외에 실제 접근 가능한 추가 class/spec 사례)이다. 전체 미래 고정 부분1915~3465분은 직전475행 후보1185~2100분보다730~1365분 늘었다. 최초370행 계획의 미래540~930분 대비1375~2535분 증가다. 이는 기능마다 기존 source/설정 수정·최신화·검증을 분리하고 공용직업 지원을 추가한 새 추정이며, 예전 Step1–5 예상/실제를 고친 값이 아니다. N/T/V/G/U는 미확정이며 실제 목록/지원 차이 확인 뒤 채워 총계를 갱신한다. 직업 수를 Retail 명단으로 추정하거나 미확정 변수를0으로 보고 완료시각을 약속하지 않는다. 네트워크/사용자접속 대기·옛 소형 custom unit frame4~8시간은 조건부 참고이며 실제G와같은범위는중복가산하지않는다. 큰 gap은 실제범위로 재추정한다.

## Summary

목표는 **실제 Forever가 제공하는 전체 직업용 애드온 모음집(AddOn collection/package)**이다. 필수 외관/관리와 독립 선택 기능 제품은 각 폴더·TOC(게임 파일 로드 목록)·저장·수명을 유지한다. 모음집 통일 외형과 전투보조 한 제품 역할은 단일 monolith를 뜻하지 않는다.

최신 방식은 **공통 외관을 구현1로 조성 → 기능마다 기존 시작 애드온 하나를 배정 → source/설정 수정·최신화·검증 → 입증된 미해결 부분만 제한 개발 → 연계검사/정정 → 최종 목업 마지막**이다(R63–65). ‘모든 기능이 외관보다 먼저’나 ‘자체 외관/채팅/관리부터 새로 개발’하는 이전 해석은 대체한다. 기존 자체 구현이 나중에 동등/우수하면 유지하되, 아직 없는 자체 코드를 우월하다고 하지 않는다. 사용자 선택 Hekili 기반을 일반 후보 재선정으로 되돌리지 않는다.

시각 기준은 idx45 실제 네 번째 샘플이다.11218의 오른쪽 meter는 제외해 세 번째 chat을 유지한다.3반투명chat·thin seam·양끝장식·아래사각지도·4K 버튼→행/간격→높이는 공통 원칙이다.2022결과는 철회/동결이다. 공통 health와 실제 직업 주/보조자원·시전/특수입력은 구분하고, 모든 직업에 mana/totem/주술사키를 강제하지 않는다. 주술사는 첫 실검증 우선이며 독점지원 대상이 아니다.

직업별 상태/proc·cooldown(CD, 재사용 대기시간)·선택 추천은 **정확 Forever Hekili의 기능/데이터/엔진을 기반**으로 한다(R62). 자체 rotation/직업별 판단 엔진을 새로 만들지 않는다. 정확판·지원 class/spec/레벨·자원·효과·추천/치유 범위는 확인해야 한다. ‘기반’은 전체 source 이식이나 사용권한 확인을 뜻하지 않는다. 미지원 기능은 정확 gap과 다음조건으로 남기며 다른 combat제품/중복stack을 조용히 추가하지 않는다.

저장/범위복원·사용자 편집은 필수다. 각 시작제품의 profile/설정/기존편집 기능을 먼저 수정·연결하고 모음집 수준의 실제 부족만 조정한다. 공통 layout/style와 class/spec 옵션을 분리한다. 기존 기능 제품에 별도 skin/profile/작은 adapter를 붙이는 hybrid는 허용되지만 기능 의미·입력·업데이트를 보존한다. 공격대/데미지/어그로는 독립 선택이며 세 번째 chat을 차지하지 않는다.

두 대안테마는 같은 구획을 유지한 ‘네온 보컬 스테이지’/‘백자와 먹빛’의 root 제안이며 사용자 최종선택이 아니다. 원형 질감이 실제로 부족하면 별도 개선 Devil 자산/비교를 만든다. 최종 전체/하단/상세·테마비교 목업은 모든 가능한 기능 작업/검사/수정 뒤 Step39에서 이 채팅에 제시한다. 사용자 출근 중 실제게임 검증은 NOT_RUN이며 목업으로 대신 통과시키지 않는다.

## Current Ground Truth

### 실제 확인과 한계

| 항목 | 근거가 있는 현재 사실 | 적용 한계 |
|---|---|---|
|client/화면 |관찰 client1.60.1.70938·koKR,사용자4K |실제현재render/UIscale 미검증;옛2560캡처로대체/전체ratio환산0 |
|모음집/전직업/Hekili |R60–62 사용자 명시 |실제Forever class/spec/resource 수/목록·Hekili전지원·치유는미검증 |
|현재 제작 |자체게임코드·최종렌더 없음 |이 발주는계획/71추적만,사용자검수/갱신/GO가먼저 |
|옛원형 |Step3 수용0/0/1,34글/확보50고유그림·56/58참조 |8906두그림미관찰·샘플build동일성/현재작동미확정 |
|원본취득 |2009/Alpha/2022와X2/1932/3461/V42 보존·정적분석 |X2전체4217/288차단·46subset, V42설정3개부분파싱;설치EXE/Lua실행0 |
|현재채팅 조사 |Step4 수용0/0/0,공식4후보·선택46source파일 |Prat/BCM 부수입력/기록,Glass혼합/instance한계,Chatty미확보,Leatrixcore미독 |
|기존 시작점 |각 기능에 V42/Prat/Dominos/SexyMap/FUF/Quartz/Reflux/Hekili/Grid2/Details/ForeverThreat 배정 |root공식 파일metadata와 Reflux5파일은 아래출처. 제품배정/배포선언≠현재게임PASS |
|사용자설정/정리 |새환경·정리의사만확인 |현재설정존재/삭제완료 가정없음;자동키/profile이식0 |
|R13 Retail참고 |비매크로설정 읽기참고 요청 유지 |Step6에서안정된로컬참고가능여부확인;불안정부분만보류,게임접근불가와동일시0 |
|macro |원형4파일·44개·6487B 보존/색인, root R68–70 공개사본 게시 완료 |원본불변·A1 raw미독. 실제계정/캐릭터 식별자만 추상화한 사본은 이름/조건/본문도 공개허용, 게임import/변환 아님 |
|offline도구 |root가기존lupa2.8 lua51/Lua5.1·무해probe7확인 |도구가용성만,애드온/게임API/taint시험PASS아님;재실행/설치0 |
|작업영역 |D:/Projects/Project_WF |root만canonical/detail/INDEX/요청/Result/Git통합. A1소유5파일만 |
|GitHub 게시 |root가 main b1b658f에 전체작업물20,062파일 게시, source payload19,692/누락0·macro4파일44개/ZIP15개 동일바이트 보고 |R67–70 별도허용·완료. 이번계획은 당시WIP였고 최신폐쇄문건은 그snapshot뒤 생성;후속commit/root통합예정 |

### 원천·고정 위치

- 현재/과거 사용자 원문은 `Codex/results/REQUEST_LEDGER.md`와 `Codex/results/REQUEST_LEDGER_phase1.3.md`, 추가R42–71 개별메시지다. 현재71요청 대응표는 `Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md`와 `.json`이다. 대장원문/옛숫자는역사그대로보존하고현재처리만따로적는다.
- 최신 요청 근거는 `Codex/results/handoffs/old-reference/r44-plan-update/baseline-request-ledger-r71-before-integration.md`(88행·SHA2560F39335B0AB8ADD70407417D4ECED19245762051DDB9FF54821E492FF9F6F6CF)에 고정한다. 원래 `REQUEST_LEDGER_phase1.3.md`는 root가 갱신할 운영대장이며, 검수한 원문행은 이 불변사본을 소비한다. R71은 이번계획묶음 마감→같은B검수→root통합/일반commit·push 요청으로, 새기능Phase나제작GO를뜻하지않는다.
- M1의 옛 숫자 좌표는 불변370행 보존 사본 `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md`만 가리킨다(SHA256703AFF3F268D678193ACDB074AAFE8EC6191477AF7A5AAE43D5583DFA6E24D79). 현재 계획을 같은경로로 교체해도 과거201/253–260/352의 근거가바뀌지않는다.
- 수용원형근거 `Codex/docs/old-devil-reference-comparison.md:1–192`, V42실물근거 `Codex/results/old-reference/a1-r36-source-evidence.md:1–118`, 채팅근거 `Codex/docs/forever-clean-chat-research.md:1–116`와 귀마개사실표 `Codex/docs/guimagae-addon-public-facts-2026-11-18.md:1–60`은 기존범위만유효하다. 새제품전체/전직업 source감사를한것이아니다.
- 동결Step5는 `Codex/docs/devil-ui-old-4k-layout.md`, `Codex/results/old-devil-layout/layout-spec.json`/`DESIGN_READY.json`에연결된다. 설계/자산/G5design30개는실제렌더/P4/다직업실게임배치통과가아니다.
- V42원문루트는 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/`다. core=`!DevilUI/!DevilUI.lua`, map=`!DevilUI/minimap.lua`, compat=`Devilconfig/ForeverCompat.lua`; 실제독해/해시는R36근거9–18행이다.
- R13은 `_retail_/WTF`의 필요한 비macro설정뜻만읽기전용으로참고한다. 원천안정/준비가필요하며 실제계정/캐릭터/사용자경로 식별자는 공개사본에서 추상화한다. 이 A1은현재접근하지않는다.
- 시작제품 보완은 `Codex/results/handoffs/old-reference/r44-plan-update/root-starting-addon-facts-and-r67.md:4–21`이다. root가 공식 Grid2/ForeverThreat/Details/Hekili 파일metadata를 확인했으며 A1은 새네트워크를 수행하지 않았다. Reflux 원문은 위V42루트 `Reflux/`의 TOC15행×2/README39/changelog13/Lua567행을 A1이 전문읽었다.
- R67–70 게시근거는 `Codex/results/handoffs/old-reference/github-publish/publish-control.md`와 `r67-main-publication-result.md/.json`이다. GitHub는 사용자지정 [Project_WF main](https://github.com/lksz1412/Project_WF/tree/main), root확인commit `b1b658ff6d8185671cb59dcf00f7bf6ef0e8d807`이다. 게시성공은 코드호환/사용권한/계획검수PASS가 아니다.

### 늘 지킬 제약

| 명령 | 처리 | 현재 적용 |
|---|---|---|
|모음집·전직업·Hekili기반 |작업한정R60–62 |실제제공범위확인,공통/직업옵션분리,전직업/치유지원창작0 |
|외관구현1·기능마다Phase·수정우선 |작업한정R63–64 |시작제품하나→source/설정수정·최신화·검증→실제gap만개발 |
|사용자검수먼저 |작업한정R65–66 |저장마스터/독립품질검수/root통합→사용자피드백/갱신/명시GO→제작 |
|원형/3chat/4K적층 |작업한정R20–34 |45실제sample4·11218meter제외,최종39목업까지보존 |
|macro/키/현재필터 |작업한정R13–17/R24/R68–70 |원형44개불변·허용된식별자추상화공개사본과구별;게임import/키자동배정/채널분담reset0 |
|R48/R49 재사용 |작업한정 |전체제품/전체모듈/부분/own/hybrid구분,실제더나은자체유지;선택Hekili를재선정하는핑계로확대0 |
|기능별독립선택 |작업한정R44 |선택제품은실제별도AddOn로드·수명,항상로드monolith의표시toggle만으로대체0 |
|목업마지막/원천동결 |작업한정R55/52 |입증된가능작업/검사닫힘뒤39,원본ZIP/옛결과/Step5/private변경0 |

### 구조 맵

| 경로 | 역할·현재상태 |
|---|---|
|`Codex/plans/2026-11-17-devil-ui-forever-plan.md` |root가검수후통합할현행계획 |
|`Codex/plans/2026-11-17-devil-ui-forever-phase<ID>-세부계획.md` |실제기존1.1/1.3보존,나머지는착수때만생성할미래경로 |
|`Codex/results/handoffs/old-reference/r44-plan-update/` |A1후보/요구표쌍/변경지도/ownlog·root불변baseline/B원문 |
|`Codex/results/old-devil-layout/` |기존설계/자산/영수증보존,최종렌더출력은미래별도경로 |
|`SourceArchive/`·`work/` |원본/캐시 보존. R68–70 공개snapshot에 포함됐으나 원본실행/정리삭제없음 |
|`MacroLibrary/` |로컬 원형44개/색인 불변;허용된 공개사본은 GitHubsnapshot에 포함.이번A1접근/가공없음 |
|미래모음집manifest·각기능소스/설정adapter |Step7과기능별Phase에서경로/판본/의존확정,현재코드폴더없음 |

확정은실제원문/관찰,근거미발견은찾았지만없음,추정은설계가설,미검증은실제확인하지않은것이다. 제품배포선언·정적코드·도구probe는현재게임PASS가아니다. 사용자용계획은한글,내부기록은기존영어기준을유지한다.

## Phase Range

실제 원형연구 Phase1.1/1.3와 Step1–5는 보존한다. Phase1.2의 준비·실제목록/시작제품 확인 뒤 **구현1은 공통외관(Phase2.1)**이다. 아래 각행은 한 기능이며 별도 상세계획·gate·산출·검증을 갖는다. source/설정 수정·최신화에서 해결 안 된 실제 요구만 같은 기능 Phase의 제한 개발로 처리한다. 직업마다 전체UI/자체엔진 Phase를 만들지 않는다.

| 구현순번 | 내부Phase | 한 기능 | 배정된시작점 | 재사용단위 | 현재근거/미검증 | 수정·검증·실제gap 기준 | 예상 |
|---|---|---|---|---|---|---|---|
| 1 | 2.1 | 공통외관 | V42 !DevilUI panel/theme/load helpers +보존원형자산 | wholeinstaller아닌부분기전/설정·필요adapter | core/map/compat정적근거24–38,원형자산/Step5 | panel/skin등록·폰트/질감·thin seam·비입력장식;installer/filterreset/uiScale/Reflux일괄import제외 | 120~210분 |
| 2 | 2.2 | 행동단축바 | Dominos | 전체제품+지원profile/작은skin연결 | 기존공식Forever/과거12.0.4후보기록 | 현재판/source/profile·slot/bind/paging·직업특수page·입력/label;자동키배정0 | 90~180분 |
| 3 | 2.3 | 미니맵 | SexyMap | 전체제품+profile/skin | 기존공식Forever/과거v12.1.7후보기록 | 아래사각지도·click/zoom/ping/tracking/icons/tooltip·저장·단일담당 | 75~150분 |
| 4 | 2.4 | 3nativechat외형 | Prat | 기존전체제품의관련모듈/설정우선;이식은별도조건 | 정확3.9.117·18관련파일독해/Step4 | Buttons/Tabs/Editbox/Font/Frames수정·3역할/필터/한글입력/저장;core입력/History부수동작검증 | 90~180분 |
| 5 | 2.5 | 기본unit health/실제직업자원 | Forever Unit Frames(FUF) | 기존전체제품+지원설정/필요한정연결 | 기존Forever지원선언·0.65.0후보,전직업자원미검증 | 공통health와해당주/보조자원/aura·target/no-target·현재API·중복/입력;mana강제0 | 90~180분 |
| 6 | 2.6 | 시전바 | Quartz | 기존전체제품+profile/skin | 기존공식Forever·원Quartz3.8.0후보기록 | 정확원제품/의존·시전/취소/차단/target·중복off는실제확인뒤 | 70~120분 |
| 7 | 2.7 | 설정저장/범위복원 | V42 Reflux1.17-Forever-v1 | 기존제품/profile기전 수정우선·scope조정은입증된gap만 | 실제동봉5파일전문·TOC16001;Lua76–142/400–434/446–461/497–561 | 전역switch직접사용제외·명시DB/범위allowlist·공통/class분리·snapshot/copy/복원/absent/schema검증 | 105~210분 |
| 8 | 2.8 | 사용자편집 | V42 Devilconfig | 기존설정UI/저장연결수정·부족한coordination만 | ForeverCompat와core/map편집/저장기전,전체GUI미감사 | 실제source/로드·지원move/size/font/color/rows/gaps·취소/되돌림·전투유예·persistence | 105~210분 |
| 9 | 2.9 | 전직업전투보조 | 선택된Hekili Forever v0.8.6/file9665215 | 전체제품우선+profile/skin/필요capability연결,모듈/data이식은별도판정 | R62선택·공식Forever1.60.1/2026-11-17·GPLv3표기;전직업미검증 | 정확source/의존·실제class/spec/level/state/proc/CD/추천지원표·단일담당·ownrotation0 | 195~300분+N/T추가 |
| 10 | 2.10 | 선택공격대frame | Grid2 4.1.13-forever/file9637467 | 독립전체제품+지원설정/별도styleadapter | 공식2026-11-15·Forever1.60.1·zlib/libpng표기;source/runtime미확인 | FUFplayer/target와분리·Grid2활성때FUFparty/raid중복0;role/debuff/경보/mouseover/clickcasting·off/update | 90~180분 |
| 11 | 2.11 | 선택데미지meter | Details! file9521145/Details.20261109.15410.172 | 전체제품+지원profile/skinadapter | 공식2026-11-09·Forever1.60.1·AllRightsReserved표기;source/runtime미확인 | 정확source/의존·값/정렬/세션·style·독립off,3chat침범0·sourcecopy권한추정0 | 75~120분 |
| 12 | 2.12 | 선택어그로meter | ForeverThreat1.12.3/file9671243 | 독립전체제품+지원profile/skinadapter | 공식2026-11-17·Forever1.60.1·skin/profile선언·AllRightsReserved표기;source/runtime미확인 | 정확source/의존·위험의미/값/갱신·off/update·3chat밖;sourcecopy권한추정0 | 75~120분 |
| 13 | 2.13 | 대안테마/조건부질감 | 구현1에서수정한V42기반공통theme등록/자산 | 기존외관기반의별도theme/style·증명된품질gap새자산 | R51두제안/R52조건부허용,실제품질미판정 | 두테마+필요한Devil개선·geometry/입력/색의미보존·원천별도·최종목업아직0 | 120~210분+조건부60~120 |

정확 공식파일: [Grid2 9637467](https://www.curseforge.com/wow/addons/grid2/files/9637467), [ForeverThreat 9671243](https://www.curseforge.com/wow/addons/foreverthreat-threat-meter-for-wow-forever/files/9671243), [Details 9521145](https://www.curseforge.com/wow/addons/details/files/9521145), [Hekili 9665215](https://www.curseforge.com/wow/addons/hekili-forever/files/9665215). root의공식metadata확인근거이며 A1현재다운로드/코드감사/게임검증이아니다.

공통외관→각기능수정본/검증→모음집연계(3.1)/정정(3.2)→최종목업/인계(3.3)→실제접근가능때live검증(3.4)/정정고정(3.5) 순서다. 공격대/어그로/저장은 root가 제공한 Grid2/ForeverThreat/Reflux 실제근거로 시작점을 배정했다. 제품정체성과 정확공식파일은 확인범위이며, 수정에필요한 source/지원/의존·사용조건·현재게임 검증은 각 기능 Phase의 진입/종료조건이다. 과거 Omen이나 제품이름만으로 현재지원을 창작하거나 시작점을 다시미배정으로돌리지않는다.

## Non-goals

- 사용자 검수/피드백·갱신·명시 GO 전 기능 코드·설치·설정·게임 입력·이미지/렌더 제작.
- 자체 외관/채팅/관리부터 새로 만들기, 선택Hekili 재선정, 자체 rotation/직업별 판단엔진, 전직업별 전체UI fork.
- 단일monolith·기능표시toggle만의선택·같은기능복수provider·미선택제품기능전부로드.
- Retail 직업명단/개수·Hekili전class/spec·치유지원·미시험직업PASS 창작.
- 모든직업mana/totem/주술사키/8보조placeholder/68빈action을실제보유주문으로취급·키/macro자동이식.
- 원본/Step5/2022/private 수정·정리삭제·기본필터/전체WTF/uiScale reset·무단재배포/사용권한추정.
- 중복미터·우측3chat대체·자동cast/target·보안제한우회·미요청extras의자동추가.

## Implementation Changes

### 기존 시작제품 수정·최신화가 먼저다

각 기능 Phase는 같은 루프를 따른다: 정확file/flavor/판본·의존·source/profile/loadchain 전독 → 기능 요구와 기존 동작 비교 → 사본/지원설정에서 수정·최신화 → 실제 가능한 실행/연계검증 → 실패한 요구만 구체적 gap 기록 → 그 부분만 제한 개발 → 해당 수정/연계 재검증. 제품이름 배정은 현재PC 작동 통과와 다르며 source 이식/권리 허가도 아니다. 외부원본·기존설정은 보존하고 공개배포 조건은 확인된 것만 남긴다.

공통외관은 이미 읽은 V42 core/map의 panel·native배치/저장·compat와 보존원형자산을 시작점으로 삼는다. V42의 설치기전체·필터reset·배포자채널·uiScale/fraction·scriptErrors숨김을 가져오지 않는다. Prat는 기존native창/입력에외형을적용하는시작제품이며 core의메시지/입력hook·History/ChatLog/Memory 부수동작을 실제 필요한범위로검증한다. 모듈을끄면부작용0이라고하지않는다. 다른BCM/Glass/Leatrix를동일영역에겹치지않는다.

### 재사용 범위·호출/수명 계약

| 대상 | 선택/활용 범위 | 실제근거 | 함께검증할연결·제외 |
|---|---|---|---|
|Hekili |사용자선택전체제품 기반·지원설정/skin/작은연결 |R62,정확판/전직업지원은미검증 |TOC/의존/classdata/엔진·event·저장/disable·전투/지원표.미지원gap명시,ownengine/중복stack/자동대체0 |
|V42 native창/배치 |부분기능/설정·필요한caller/callee포함 |R36근거26–33,core967–976/1096–1207/765–806·map197–226/487–513 |native역할·undock·SaveLayouts/ReloadUI·combat/EditMode guard.필터reset1174–1184/map815–838제외 |
|V42 compat |whole독립module또는필요helper부분,실제callchain판정후 |R36근거24,ForeverCompat1–37 |namespace/C_AddOns/AceConfigDialog·gradient/resize·loadorder.새의존자동추가0 |
|V42 panel/map |부분helper/설정 |R36근거34, map12–31/235–237/605–627/707 |mask/backdrop·입력·저장·frame수명.사진동일asset/비율이식보장0 |
|V42 installer/PitBull/Leatrix/profile |installer전체이식제외·그외근거대기 |R36근거35/38/78–79,채팅보고82–84 |전체지원/미독core/partialprofile최종값확정0·필요source만미래확인 |
|기존기능제품+skin |whole제품+별도style/profile/작은adapter |R45/50,기능별시작점표 |기능·입력은제품,skin은허용외형만.부재/off/update·frame재생성/저장·버전고정 |
|입증된gap |위수정/설정검증이실패한부분만한정개발 |실제실패/미지원source·범위·이유가필수 |필요caller/callee·반환/빈값/초기화/event/저장/종료함께,부수snippet복사0 |

이 표의원천경로/정적독해는 Current Ground Truth/R36근거9–18에연결된다. 모든번들/외부제품을감사했다는뜻이아니다. R48의더나은자체유지와R49전체/부분구분은따르지만 아직없는자체코드를완성품처럼비교하지않으며 최신R62/63선택을뒤집지않는다. Ellesmere는기능참고만,귀마개프로젝트동일성/전체코드이식권한은확정하지않았다.

### 공통 상태·전투보조·직업전용 입력

실제Forever class/spec/주·보조자원/특수능력/입력집합은 Step6에서정확client/build와연결된원천으로확정한다. class/spec ID·이름·원문/코드위치·버전/해시·미확보를기록하며Retail목록을복사하지않는다. 공통health/해당resource·target/aura/cast는기본unit기능,proc/CD/추천은Hekili기반선택전투기능,실제특수입력은native/해당입력provider한곳이다. 토템은주술사사례이며폼/펫/특수bar는실제로존재할때만해당직업에맞춘다.

Hekili source/데이터/기존판단엔진을검증해기능별지원표를만든다. 한class의지원선언을전class/spec·치유에확대하지않는다. 미지원이면정확class/spec·필수기능·원천/실패·다음수정/지원확인조건을남긴다. 가능한부분은진행하되필수기능미완을‘선택안함’이나‘지원완료’로바꾸지않는다. 새제품대체/중복combatstack/ownrotation을임의도입하지않는다.

미래 class-support-matrix는 실제모든class/spec 행에 목록원천/client·기본health/실제자원/특수입력·Hekili상태/proc/CD/선택추천별source/선언/구현/gap·담당/whole/partial·공통/class설정·검사T/결과·NOT_RUN사유/다음조건을갖는다. 지금실제행/수가없는빈표를지원완료데이터로생성하지않는다. T는적어도각실제직업의필수baseline을포함하고의미가다른spec/자원/전환사례를더한다. 직업×기능무조건곱셈이나직업별UI fork가아니다.

동결Step5geometry는원형참조이며다직업실게임배치를검증한것이아니다.3chat·사각지도·button-first구획은유지하고실제class자원/입력차이는그영역에맞춘다.8보조placeholder/68빈slot을실제보유주문이라하지않고macro/키자동배정도없다.

### 저장/복원·편집과 외부제품 스타일

기존제품의profile/save/copy/reset/지원편집기능이출발점이다. Reflux 실제source의 switchexact400–406은 DB하나만선택하지만 switch407–434는 전체AceDB와emulated _G를바꾸고 logout hook/ReloadUI를연결한다. save446–461·copy497–517·snapshot546–561도 별도전체registry/변수범위를갖는다. combatguard362–365가있어도사용자범위복원이안전하다는증거는아니다. save451은현재snapshot을빈table로교체하고454에서nil인emulated변수는키가남지않으므로부재provider entry보존을기본Reflux가보장하지않는다. saveaddons460은전체addon상태수집으로연결된다. 따라서 전역switch·addon전체상태복원344–351·일괄삭제는도입하지않고,명시DB/namespace allowlist와provider지원profile로수정·검증한뒤부족한scope/schema/실패복구만같은Phase의gap으로보완한다. 공통layout/style와class/spec별기능옵션·선택provider판본을분리하며모음집coordination은실제부족만만든다. 버전있는범위별snapshot/copy/Devil기본값·이전사용자값복원,초안/확인/적용/취소/되돌림을계획한다. 미설치/미선택제품entry는보존하고적용만생략한다. unknownschema/version은silentreset하지않으며다른직업값/필터/키/macro/전체WTF를바꾸지않는다.

사용자move/size/font/color/row-gap는실제시작제품이지원하는값부터편집·저장한다. 지원안하는항목은있는척노출하지않고실제gap기준으로조정한다. class/spec전환·reload/relogin·providerupdate뒤사용자값을확인한다. protected편집은전투밖,현재API·EditMode는실제게임검증전미검증이다.

외부raid/meter는지원profile/skin/theme hook부터공통Devil외관에맞추며부족하면별도작은adapter,직접fork가필요하면source/호출체인/사용조건·업데이트범위를먼저확인한다.경보/역할/위험도·debuff·mouseover/clickcasting·값/세션의미를보존한다. 기능과style담당을분리하고부재/off때style작업0·update뒤적용/되돌림을검증한다. 독립AddOn선택을checkbox만으로위장하지않고nativeparty/raid는제품선택전baseline이다.

### 두 테마·조건부 Devil 질감과 마지막 전달

Phase2.13은수정된공통외관의기존등록/style를기반으로두테마를만든다.‘네온보컬스테이지’/‘백자와먹빛’은root디자인제안이지최종사용자선택/필수캐릭터IP가아니다.단순recolor가아닌재질/폰트/막대/장식의일관성을만들고구획/3chat/map/입력의미는유지한다.

지정판독자가원천자산과4K목표부품의실제품질을관찰해거친확대/흐림/alpha halo/이음새/글자방해가확인될때만Devil개선본을별도자산/원형비교로만든다.모든texture교체의무나원천/동결Step5덮어쓰기아니다.미래raster창작/편집에는제공ImageGen을조건에맞게쓰고참조이미지를연결하며,code-native기하/compositing은renderer가맡는다.현재생성은없다.

각기능style작업과가능한검사/수정이끝난뒤 Step39에서만 최종baseline/조건부개선/두테마4K전체·원배율하단·키/서로다른V직업상태상세·비교를렌더하고이채팅에제시한다.모든그림은제안목업으로표시하고실제모든직업캐릭터의게임캡처/전투PASS로꾸미지않는다.

### macro 원형 보존과 허용된 공개사본

현재 R68–70은 모든 작업물과 개인 macro의 공개사본을 허용한다. 실제계정/캐릭터/사용자경로 식별자만 추상화하며 이름·조건·본문을일괄금지하지않는다. root는 원형4파일/44개에 실제계정/캐릭터명본문이없어 byte동일 공개했으며 manifest의개인경로를추상화했다고기록했다. 로컬원형은불변이고 이번A1은raw를열지않았다. 게임import·주문변환·키배정은계속취소상태다.

아래 문단은 불변 baseline201의 **R17 당시 승인·검증 원문**이다. 그중 옛 Git제외/외부비공개는 현재R68–70의허용/게시를취소하지않는다.

최종 승인 범위는 `D:\Projects\Project_WF\MacroLibrary\` 안의 private 라이브러리다. 보존본은 `MacroLibrary/archive-egl0lld0/`에 만들어졌다는 helper 완료 반환을 master가 전달했다. 원본4파일을 계정 공용1·캐릭터3 scope로 나눠 byte 그대로 보관하고 private manifest와 INDEX를 만들었다. source/archive SHA256 4/4·총6487bytes·9+11+16+8=44개, strict UTF-8 4/4·이름/원문행/literal 명령 대조44/44·빈본문1개 보존·Git 제외 확인은 helper의 실제 기계검증 반환값이며 이 A의 raw 재검사가 아니다. INDEX는 원본이름·scope·원문참조번호·실제 조건문에서 기계확인한 검색키만 담는 찾기 보조이며 raw 원형이 원본이다. typo·빈본문·이름·조건·명령순서·ID·인코딩을 보존한다. source 삭제·변환·병합·Forever 파일 복사·적용사본·키 배정·새 macro 저작은 하지 않았다. raw·실계정 경로·식별자·macro 이름은 library 내부에만 두고 Git/외부 자료로 보내지 않는다. master가 원문 대조·통합 확인을 맡고 이 A는 raw를 받지 않는다. 나중에 사용자가 필요한 원형을 요청하면 그때 해당 원문을 꺼낸다. 현재 게임 적용·호환성 시험은 미수행이다.

## Phase N — 복원·구성·검증

아래계획경로는해당Phase착수때작성할미래파일이다. 각기능Phase는 Phase Range의단일시작점·수정/최신화·검증·입증된gap조건을소비하고,수정소스/profile/판본manifest/지원표와실행결과를다음단계에넘긴다. 기존1.1/1.3/Step1–5는실제이력그대로다.

| Phase | 상세계획 경로 | Step | 상태 |
|---|---|---|---|
|1.1역사분석 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.1-세부계획.md` |1–2 |완료/철회동결 |
|1.3원형/채팅/설계 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md` |3–5 |3/4수용·5설계반환/렌더39이월 |
|1.2준비/시작점 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.2-세부계획.md` |6–7 |사용자검수/GO뒤 |
|2.1 공통외관 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.1-세부계획.md` |8–9 |미착수·기능별수정/검증 |
|2.2 행동단축바 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.2-세부계획.md` |10–11 |미착수·기능별수정/검증 |
|2.3 미니맵 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.3-세부계획.md` |12–13 |미착수·기능별수정/검증 |
|2.4 3nativechat외형 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.4-세부계획.md` |14–15 |미착수·기능별수정/검증 |
|2.5 기본unit health/실제직업자원 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.5-세부계획.md` |16–17 |미착수·기능별수정/검증 |
|2.6 시전바 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.6-세부계획.md` |18–19 |미착수·기능별수정/검증 |
|2.7 설정저장/범위복원 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.7-세부계획.md` |20–21 |미착수·기능별수정/검증 |
|2.8 사용자편집 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.8-세부계획.md` |22–23 |미착수·기능별수정/검증 |
|2.9 전직업전투보조 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.9-세부계획.md` |24–26 |미착수·기능별수정/검증 |
|2.10 선택공격대frame |`Codex/plans/2026-11-17-devil-ui-forever-phase2.10-세부계획.md` |27–28 |미착수·기능별수정/검증 |
|2.11 선택데미지meter |`Codex/plans/2026-11-17-devil-ui-forever-phase2.11-세부계획.md` |29–30 |미착수·기능별수정/검증 |
|2.12 선택어그로meter |`Codex/plans/2026-11-17-devil-ui-forever-phase2.12-세부계획.md` |31–32 |미착수·기능별수정/검증 |
|2.13 대안테마/조건부질감 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.13-세부계획.md` |33–34 |미착수·기능별수정/검증 |
|3.1 모음집연계 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.1-세부계획.md` |35–36 |미착수 |
|3.2 연계정정 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.2-세부계획.md` |37–38 |미착수 |
|3.3 최종목업/인계 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.3-세부계획.md` |39–40 |미착수 |
|3.4 실제게임 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.4-세부계획.md` |41–43 |미착수 |
|3.5 실게임정정/고정 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.5-세부계획.md` |44–46 |미착수 |

직전475행미착수역할→현재:6준비→6/7,7비교→7및기능별진입,8bar/map→10–13,9chat/unit/cast→14–19,10저장→20/21,11편집→22/23,12combat→24–26,13raid/meters→27–32,14style/theme→8/9및각기능style/33/34,15검사→35/36,16정정→37/38,17최종목업→39,18offline인계→40,19실환경→41,20전투→42/43,21정정→44/45,22고정→46. 실제1–5와timestamp는재번호하지않는다.

**Step5 이월 계약(root 담당):** 기존설계/자산/G5design30개/기존DESIGN_READY해시를보존한다. Step5이력·현재detail·Phase1.3 Result addendum(md/json)에 `DESIGN_HANDOFF; VISUAL_USER_DEFERRED_TO_STEP39`와R55/R63–65·이월목록·수신Phase3.3/Step39를기록한다. 이전475행후보의수신17은현재39로바뀌며렌더완료를뜻하지않는다. 연구/설계인계범위를이조건으로닫아다음기능Phase를열고,visual/P4는39의실제렌더→픽셀/역할대조→지정판독→같은B P4→채팅전달로닫는다.기존고정파일을다직업실게임배치PASS로표시하지않는다.이A는root기록/동결원천을수정하지않는다.

## Implementation Interfaces

현재source/게임코드수정은없다. 다음은사용자검수/GO뒤기능별계획의입출력계약이다.

| 연결 | 입력→출력 | 계약 |
|---|---|---|
|원형→공통외관 |45sample4/보존자산·V42기전→수정theme/등록 |wholeinstaller/filterreset/uiScale이식0·3chat/사각map/button-first |
|기능시작점→수정본 |정확제품/file/source/profile/loadchain→지원설정/수정·최신화 |기능별1시작점·증명된gap만개발·원본보존·사용조건창작0 |
|Hekili→직업지원 |선택정확Forever판/실제class-spec목록→기능/data/엔진지원표 |자체rotation/대체제품/중복stack0·미지원/치유/gap명시 |
|unit/native→역할 |health/해당resource/특수입력→표시·수동조작 |전투proc/CD와기본상태분리·mana/totem강제0·키자동배정0 |
|공통/class설정→관리 |기존profile/save/edit+공통style/class옵션→범위snapshot/copy/restore |다른직업/namespace/필터/키불변·absententry보존·unknownschema reset0 |
|편집→저장 |지원move/size/font/color/rows/gaps→확인/적용/취소/저장 |기존편집기능먼저·combat보호·class/spec전환/reload/relogin유지 |
|선택제품→모음집 |독립폴더/TOC/의존→선택기능만로드 |필요reload뒤disabled제품/adapter미로드·event/timer/hook업무0·core단독 |
|provider→skin |지원profile/skin/frame수명→공통Devil외형 |기능값/경보/mouse/clickcasting의미보존·3chat침범0·off/update검증 |
|R13→구성 |Step6안정된비macro설정참고→뜻/채택기록 |미준비부분만보류·원본읽기전용·공개사본실제ID추상화·Step41적용전재확인 |
|기능검사→연계 |각기능원천/수정본/실행결과→35/36통합검사 |가능한실제흐름전체·가짜fixture만으로게임PASS0 |
|이월설계→최종39 |Step5보존geometry+실제수정기능/theme→최종4K/하단/상세비교 |모든가능작업/수정닫힘선행·원형/제안/실게임구분 |
|실제검증→고정 |41–45의접근가능직업실측→46통과/미검증/복원 |미접근class/spec NOT_RUN·전체지원완료창작0 |
|macro→보존/공개사본 |기존원형4파일/44개→검색보조·허용ID추상화사본 |R68–70공개완료root근거·원형불변·A1raw접근0·게임이동/변환0 |

## Test Plan

### 현재 계획 변경 검수와 delta gate

| 대상 | 갈래 | 고정5 | 고정③ | 가변5 |
|---|---|---|---|---|
|M1/R60–71계획·71요구대응 |비코드③/P5 |구조/사실·참조/연계/정의·완결/요청뜻 |수정연계:불변baseline·최신원문→기능별시작점/순서→계약/비용/검사·최종수신 |①공용collection/실제class-spec/선택Hekili ②외관구현1/기능별1Phase/기존수정우선 ③공통-vs직업저장/지원행렬·gap·미검증과장반증(적대) ④M1승격후불변pins/71추적·R68–71익명공개/마감범위 ⑤사용자검수먼저·새변수비용·가능작업닫힘→39목업 |

같은B가새사용자범위/변경·연계단위를검수한다. 이미통과한변하지않은원천/22+8검사/CRC/G5를전부다시돌리지않는다. A1은원문/현재파일전독과자연단위자체확인뒤바뀐표/번호/비용/지원·이월·요구/pin gate만실행한다. 번호열거71은71기능구현완료가아니다.

### 미래 기능별 수정/실행 검증

| 대상 | 갈래·고정5 | 고정③ | 가변5 |
|---|---|---|---|
|각기능source/adapter수정 |실제diff로상향판정;P1 문법/상태마커/후속구획영향/문서완결/기존인터페이스호환.코드③은실제가능구동후연계/뜻/적대3라운드,코드②한번 |기존source수정=연계;순수새gap모듈=연결 |①기존수정우선/입증gap ②caller/callee·load/event/lifecycle ③공통/class설정/실제지원행렬 ④native입력/필터·Hekili미지원과장반증(적대) ⑤disabled/update/복원·제품별사용조건 |
|시각/테마최종39 |비코드③/P4 실제렌더/토큰·가독성/연결/완결/4K읽기·같은B10관점 |보존명세수정영역연계·새theme와최종출력연결 |①원형3chat/thin seam/하단map·button-first ②동일구획/직업상태의미 ③한글/키·alpha/halo ④원형/창작/실게임혼동(적대) ⑤외부skin·입력/update |

각기능Phase에서source/설정수정/최신화를실행·검증한뒤안된부분만gap으로기록해한정개발한다.기존lupa.lua51은own-code계약/harness검사가능도구이며source/game API/taint PASS아니다.실제currentgame에서만검증할입력/전투/보안/분류도착은NOT_RUN으로남긴다.

### 기능 gate·연계 gate·최종 수신

| gate | 증거/확인 | 실패·미검증 처리 |
|---|---|---|
|G-start |기능별정확1시작제품/source·파일/flavor/판본·지원/의존·사용조건 |불명근거를창작하지않음,해당진입조건만보류/root확인 |
|G-existing-first |기존설정/source수정/최신화결과와안된요구 |입증된gap만제한개발,own-first/새rotation/무단Hekili대체0 |
|G-class |실제목록/원천과N직업·spec별Hekili/기본상태/입력지원행렬·T사례 |선언/source/구현/offline/live/해당없음/미지원/gap분리 |
|G-native |3역할/filter·Enter/slash/Escape/한글조합/focus/history·slot/bind/page·특수입력 |과거ID/필터/mana/totem/키강제0·실게임도착/조작은41–43 |
|G-state/cast/map |health/실제주보조자원·aura/target·시전취소차단·지도모든입력 |기본값대조/중복0,없음/unavailable을정상값으로꾸미지않음 |
|G-save/edit |기존profile/snapshot/copy/default/범위restore·지원편집·class/spec전환 |다른값/필터/키/macro불변·Reflux451/454의nilentry소실을보완한absententry보존·unknownschema/사용자값유지 |
|G-optional/style |각선택제품부재/off/reload·실제독립로드·frame수명/skin/update/조작 |checkbox만의독립선택0·skin입력/의미손상0·실패style만보류 |
|G-R13 |6의읽기준비/안정된비macro참고·41의적용전재확인 |미준비subset/이유/조건기록,출근만으로로컬읽기불가추정0 |
|G-integration35/36 |각기능실행/지원행렬·모음집공통/class설정·전환/로드/부재/update의실제흐름 |미완필수기능을미선택으로돌리지않음·가능한검사와live-only분리 |
|G-fix37/38 |확정결함/실제gap과영향단위수정·해당연계재검사 |원천/무관통과시험반복0·중대/중간미해소완료처리0 |
|G-final39 |가능작업/검사/수정닫힘+Step5이월목록→최종렌더/픽셀/지정판독/P4·채팅 |그전최종목업제작0,모든 직업의 실제 게임 PASS로위장0 |
|G-live41–45 |접속가능/실제적용승인·현상태백업/복원·주술사우선+가능한추가class/spec |실제resource/상태/입력/전투/taint/persistence·미접근NOT_RUN |
|G-freeze40/46 |offline/실게임을구분한제품/file/owner/schema/profile/style/지원표·복원 |실제통과범위만고정,미시험/gap명시·원형/private보존 |

최종39입력에는각71요구의현재상태·실제가능한작업완료/조건부미선택/근거있는live이월과기능별검사결과가연결돼야한다.현재모든미래기능/렌더/게임gate는미수행이다.

## Assumptions

| 전제 | 상태·다음확인 |
|---|---|
|모음집/전직업/Hekili/기존수정우선 |R60–65확정·재질문안함.실제파일/기능/개수는미검증 |
|직업/지원범위 |실제Forever roster/spec/resource는6/24원천확인,N/T는그뒤확정.주술사우선외직업도지원행렬에포함 |
|시작제품 |표의배정≠runtimePASS.Reflux/Grid2/ForeverThreat의시작정체성근거는확보;정확source/사용조건/현재게임은각Phase검증 |
|관리/편집 |필수요구,기존기전수정우선·collectiongap만개발.현재완성품없음 |
|원형/4K |45sample4/3chat/button-first확정,실제raster/UIscale·build/asset동일성/권리미검증 |
|Step5 |고정원형설계입력,다직업실게임기능배치/렌더/P4미완;39로이월 |
|Hekili |기반제품선택확정,전class/spec/level/치유추천지원미확정·새엔진가정0 |
|raid/meters |선택기능,기본party/raid는native.별도제품/skin가능성/update는실제확인 |
|R13/private |안정된자료는6읽기참고가능,미준비subset만보류.현재A1raw접근없음 |
|macro/키 |44원본보존과R68–70ID추상화공개사본게시완료(root),이동/변환취소·키자동배정0 |
|시간/접근 |1690~3075offline고정+N/T/V/G변수,live별도225~390+U,미확정0추정없음 |

## Correction History

| 날짜 | 반영 | 근거 |
|---|---|---|
| 2026-11-17 | 최초 초안: 원본 역할·단일 owner·후보 gate, 15개 일괄 적용 제외 | R1~R7·S1~S10 |
| 2026-11-17 | 관찰 종료·정리 가능성·새 환경 | R8~R10 |
| 2026-11-17 | 최종 D: 프로젝트, C: 기록 보존 | R11·R12·PROJECT_LOCATION addendum |
| 2026-11-17 | 최신 선택으로 원본44개 private 라이브러리·검색색인에 한정, 이전 이동/게임 적용 취소 | 최신 사용자 원문·master source4파일 실측 보고 |
| 2026-11-17 | 1차 검수 중간2건 정정: 현재 R17 범위 addendum, R13 비매크로 참고의 준비·입력·계약·gate 연결, 색인·실제 검수 기록 반영. 수정 재검증 대기 | audit_log·TRIAGE_phasePlanning |
|2026-11-18 |R44–R59 계획 후보:필수 관리/독립선택/단일combat·실제비교·whole/partial/hybrid·외부style·기능우선·후속테마/조건부질감·최종목업·59요청추적 |개별사용자원문/현재요청대장·본발주;A1계획판단 |
|2026-11-18 |같은B확정M1수정·R60–66모음집/전직업/Hekili/외관1/기능별Phase/수정우선/사용자검수반영 |불변370baseline·rawB·최신원문/발주 |
|2026-11-18 |R67–70 main전체게시완료·원형불변/ID추상화공개예외와R71계획묶음마감·71요구추적,Reflux/Grid2/ForeverThreat실제시작점 |root공식사실표·Reflux5전문·publication결과/불변요청88행;후보품질/사용자검수대기 |

현재 별도 계획 이력 파일은 실제 존재하지 않았다. 아래는 R44 수정 전 불변 baseline의 당시 기록을 보존한 것이며 지금 상태는 본문이 우선한다. root가 Phase 종료 기록을 관리한다.



### 이전 추정과 과거 검수 안내 — 역사 보존

다음은 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:37`의 당시 추정이며 현재 미래비용과 다르다.

R25 기준 재설정 후 미착수 경로 Step3~15의 합계는 675~1230분, 약 11.25~20.5시간이다. 이는 옛 원형 전수조사·채팅 해결법·새 배치와 미래 구현을 모두 포함한 추정이며, 현재 원형·채팅 조사는 Step3~4이며, R20의 오프라인 배치 설계 목표는 새 원형을 확인한 뒤 Step5로 이어간다. 게임 코드·설치·설정은 이 승인에 포함하지 않는다. 동결된 2022기준 작업시간은 별도 역사 기록이다. 원본 회수 난항·사용자의 게임 접속 대기시간은 별도다. 소형 custom unit frame이 필요하면 추가 4~8시간을 예상하며 범위·비용을 구체화해 결정한다. 이 시간은 완료 약속이 아니다. 관찰 종료·기존 AddOns 정리 가능성·새 환경·최종 D: 경로는 현재 전제와 Phase 1.2에 반영했다. macro는 별도 승인된 원본 라이브러리로 보관하며 UI 구성·게임 적용과 분리한다.

원래Step2/최초계획 검수의 당시 상태는 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:253–260`에 보존돼 있고 현재Step5목표/P4를대신하지 않는다. 실제Step3/4수용과Step5설계상태는현행본문에반영했다.

### timestamp 추가 원문 — 당시 결정만 보존

아래는 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:338–370`의 내용 그대로다. 옛Step번호/당시미승인/원형가정은 역사이며 R44–R71 현재본문·Step6–46를대체하지 않는다.

검수 상태 추가 — 2026-11-17 20:08:07 +09:00: 위 수정 반환 시점의 재검증 대기 상태는 해소됐다. 같은 검수자의 재검증 결과는 중대0·중간0·경미0이며 두 지적이 모두 해소됐다. 실제 반환 원문은 `Codex/results/handoffs/forever-ui/iter_1/recheck.md`에 보존했다. UI 게임 실행과 Retail 설정 준비 확인은 여전히 미수행이다. 다음은 §11 사용자 피드백이며 구현에 착수하지 않았다.

현재 실행 범위 추가 — 2026-11-17 20:57:39 +09:00: 사용자 R19의 명시 요청으로 Phase1.1 Step1(공개 구버전ZIP 확보·격리 분석·재현/제작 역할 보고)만 시작한다. 앞선 제시안에 대한 피드백을 반영한 한정 승인이다. Phase1.1 Step2 정밀 이미지 측정과 Phase1.2 이후 설치·설정·구현은 미착수로 둔다. 한정 분석은 특성·알림량 미정과 독립적으로 진행 가능하다. 관련 세부계획은 `2026-11-17-devil-ui-forever-phase1.1-세부계획.md`. SourceArchive 원본은 Git 제외·변경 없이 보관하고 게임 폴더에는 쓰지 않는다. 분석 결과만으로 현재 게임 작동을 보장하지 않는다. 검증 대상 source-analysis 보고는 비코드③/P5, 고정5와 가변5(원본무결성, 설정/프로필출처, 외형연결, API호환성 추정반증, 재사용권한/유지보수) 총10라운드 독립검수 후 전달한다.

R19 결과 반영 — 2026-11-17 21:32:48 +09:00: Phase1.1 Step1 원본 확보·정적분석·독립검수0/0/0 완료. 하단집중형 loaf 프로필, kgPanels8패널, Onyx Classic 스킨·원형 배치값을 재현 근거로 확보했다. 새로 만들 부분은 원본 자산·패널을 현재 후보와 연결하는 작은 테마/설정 코드가 중심이라는 조건부 설계 판단이다. Masque/Onyx 현재지원·의존성 추가와 FUF 외형 수용 여부는 후속 검증/선택이며 이번 설치 승인으로 바꾸지 않는다. Step2 첫 그림 정밀 비교 및 이후 설정·구현·게임 검증은 미착수. 상태 기록은 Step1 이력과 PHASE_1.1_source-analysis_RESULT.md에 있다.


현재 Step2 범위 — R20/R21/R22: 원본 첫 스크린샷·회수 설정을 대조한 배치 설계와 오프라인 미리보기만 진행한다. 기존 Phase1.1 Step2의 한정 GO이며 설치·게임 설정·새 addon Lua·개인 macro 작업은 포함하지 않는다. 사용자 화면4K, 스킬바 아래부터 적당한 높이로 쌓기를 우선한다. 버튼 크기→간격·단 수→바닥 여백→체력/마나·미니맵·배경 순서. 첫 이미지나 화면 전체의 비례 확대를 설계 기준으로 쓰지 않는다. 정확한 버튼 pixel과 높이는 제안값, 원본 측정값·실제 게임 실측과 구분한다. 검수: 비코드③/P4, 고정5(시각 구조·사실/참조·안팎 연결·완결성·의도)와 가변5(원형 배열·스킨, 하단 적층 높이, 4K 버튼·글자 가독성, 좌표/UI scale 혼동 적대, 게임·매크로 범위 보호) 총10라운드. 같은 A/source_analysis와 B/source_review를 직렬 재사용한다.



R23 현재 역할 확인 — 2026-11-17 22:25:52 +09:00 : 반투명 음영이 있는 세 직사각형 구획은 사용자 확인으로 대화창3개다. 왼쪽둘을 용도미확정 빈패널로만 두던 설명은 현재 역할판정에서 대체한다. 각 창의 위치·반투명 배경·구획을 유지하고 채널분담은 미정으로 둔다. 현재Step2 설명/명세에 반영; 실제 chat 창 설정/설치는 후속 게임구현 범위이며 이번에 적용하지 않는다.


최우선 현재 기준 재설정 — 2026-11-17 22:31:12 +09:00 : R24–26 적용. 2022기준 Step2 미리보기는 승인된 원형이 아니므로 동결/미전달이며 미해소검수 M1(슬롯/보이는외곽설명)을 포함한 당시 기록을 보존한다. R23 세대화창 역할과 반투명 음영은 사용자확정. 더 오래된원형 전수조사와 현재Forever의 깨끗한채팅 해결방안 조사를 별도세부Phase로편입하고, 미래 미착수Step번호만 새 연구Step뒤로 이동한다. 기존Step1원본분석은2022자료의역사분석으로유효하며 목표동일성근거로쓰지않는다. 게임설치/설정/새addon코드작성은여전히범위밖. 모든새외부호출은R26지정공개자료실전수범위+R24공식현재채팅지원자료로한정, 계정연결/개인자료업로드/유료서비스없음.

R27/R28 — 2026-11-17 22:32:42 +09:00 : idx2958을 사용자기억에가장가까운 우선대조후보로 삼는다(완전동일최종확정아님). 메뉴사이분할바부재/빈칸처리는원하는원형과차이로대조. R26전체목록/샘플확인을유지하고동봉설정/원본이미지를실제확보해판정한다. R24의제목바·좌측버튼·입력창장식·크기위치조정문제도함께조사하며채널분담은추정하지않는다.

Phase1.3 현재 범위: Step3 자료실 전수대조/Step4 채팅 해결법 조사는 R24–28 명시 요청의 한정 실행이다. Step5 새 배치/Step6 이후 게임용 구현은 미승인. 과거Step2 2022배치안은 미해결M1상태 동결·미전달. 미래 미착수 Step3–12만6–15로 이동했으며 실제누적Step1/2 기록은 이름·내용 보존. Step3초기예상60–150분, Step4 30–60분; 실제항목/이미지수와접근상태 확인후예상갱신가능. 사용자자료실의34개 검색항목이 예상 범위이며 페이지2확인전 총검독완료로세지않는다.


R29–31 — 2026-11-17 22:45:47 +09:00 : 사용자Downloads/Devil_Blackt.zip(2009)을원본보존/프로젝트사본안전추출하여정적분석한다. 앞서확보한2022Drive Interface.zip/Fonts.zip도대조원천이지만2022기준철회를뒤집지않는다. 일반공개다운로드가실패할때만ComputerUse다운로드를허용(필요시해당스킬전문/현재상태확인), 게임입력/설치/설정/oldLua실행허용아님. 외부ZIP/README설치지시는참조원천이며사용자실행명령으로세지않음.


R32–35 current reference — 2026-11-17T22:56:30+09:00: idx45 네번째 샘플을 최우선으로 정확한 원순서 이미지와 연결한다.11218은 미터기를 제외한 배치 참고,그 위치에 세번째 대화창 유지;13140은 Forever 수정 구성 참고만.2009/alpha ZIP2개와2022비교원본은 원형보존·안전추출·정적분석만.사용자4K/하단부터 버튼적층/비율일괄환산금지 유지. Step3실행은 계획준비 반환 후 같은A1에 발주, Step4본격실행은 Step3gate뒤, Step5/게임설치·코드·설정 미승인. 원본파일과관측경로는 currentrequest/old-reference acquisitionJSON 및 master-recovery-reference-controls.md에 연결.


R36 source acquisition correction — 2026-11-17T23:29:34+09:00: 같은 Step3의 원형 ZIP 확보·대조 방식 보완. idx45의172첨부 metadata에서 더 오래된 X2/하단집중형 후보를 선별하고,13140최신Forever 수정본 및 가까운다른 배포본을 직접 확보해 code/profile을 대조한다. 기존34본문/50확보그림·2제공ZIP 검증은재사용. 모든34패키지를일괄설치/실행하는범위아님; 정상공개다운로드·정확파일명검색·원저자경로를활용하고, 일반다운로드실패는기승인ComputerUse다운로드로보완가능. 설치EXE/Lua직접실행·개인자료접근·게임변경·새의존성설치없음. R36는기존원형조사의취득방법/원천추가이며최종보고단위·호환성보장범위를확대하지않음. Step3완료주장은추가실물대조뒤로,Step4채팅조사진입은그gate뒤.

현재 범위 정정 — R20 원문 재확인: “좋아. 그럼 원본 스크린샷이랑 회수한 설정을 대조해서 내 화면에 맞는 배치부터 잡아봐. 데빌UI 블랙 하단집중형 느낌을 최대한 그대로 살려줘.” 이후 R25는 잘못된2022원형을 철회하고 R34는45샘플4로 기준을 보완했으며 배치 목표를 취소하지 않았다. 앞의 “Step5미승인”은 master의 한정 발주를 전체 사용자 승인과 혼동한 해석이었다. 현재는 Step3 대조 수용→Step4 채팅근거→Step5 새 원형의4K 오프라인 배치·미리보기로 이어간다. R20을 다시 승인받지 않는다. 기존2022결과 동결·게임코드/설치/설정/입력 별도승인과3채팅·4K아래적층은 그대로다. 이전 해석 기록은 삭제하지 않는다.

Step5 새 원형 미리보기 검증: 비코드③/P4, 고정5=실제생성·렌더/색·타이포·간격·대비/원천→명세→PNG 연결/요소·설명완결성/4K에서읽기. 가변5=45실제샘플4·세채팅·얇은구분선·아래사각지도 충실도; 버튼→행·간격→높이의하단적층; 글자·단축키크기와중앙게임영역; 원본측정/제안pixel/현재실측혼동반증(적대); 설치·원본·개인자료범위보호. 긴윗줄정확셀수와정확build는미확정으로남기고2022배열을답으로재사용하지않는다. 실제렌더와전문판독뒤같은Phase B10관점, 같은A정정·같은B재확인. 게임작동판정이아니다.
Recorded 2026-11-18T00:46:21.4180796+09:00


## Decisions Required

**먼저 이 마스터플랜을 사용자에게 검수받는다(R65).** root의독립품질검수/통합뒤목표·기능별시작점·순서·미확정사실·비용을검토받고피드백을계획에반영한후명시GO로제작을시작한다.현재A1은계획/71추적만저장하고멈춘다.예전R64의‘시작’으로이게이트를건너뛰지않는다.

이미정한모음집·전직업·Hekili기반·외관구현1·기능별Phase/기존수정우선·3chat/4K/목업마지막은다시선택하게하지않는다.실제Forever목록/정확판/시작기전지원은원천확인대상이지사용자가추정답을줘야할질문이아니다.Grid2/ForeverThreat/Reflux시작점은제공근거로배정했으며지원/수정가능면/실제작동은각Phase에서검증한다.미적취향은제공reference로판단한다.

아직미정인실제접근가능캐릭터/class-spec/레벨·콘텐츠·추천량/선택raid/meters on-off·최종테마는현재계획작성과공통기반설계를막지않는다.검수/GO뒤에도게임설치·설정/입력은그실제범위승인과접속가능성을따로따른다.출근상태를원격게임조작허가로해석하지않는다.

### 멈출 일 미리 점검

| 항목 | 현재/미래 기본 대책 |
|---|---|
|사용자검수/GO |현재계획만.검수본제시/피드백·갱신·명시GO전기능/이미지제작0 |
|새의존/설치 |기능별정확기존제품/필수dependency근거·scope,새필수의존은실제계획범위로처리 |
|외부호출 |현재A1network0.미래정확공식공개source·기승인R67–70프로젝트공개사본게시,실제ID추상화.계정/쿠키우회·유료확장없음 |
|시작제품/지원gap |부재사실창작0·해당진입조건만보류/root확인,선택Hekili자동교체/새엔진/중복stack0 |
|수정/원천 |기존제품사본/설정수정우선·기존원본/ZIP/고정Step5/역사/private보존·정리삭제없음 |
|권한 |D쓰기실제권한검토,게임/새시스템권한은당연시하지않음 |
|시각제작 |공통외관구현이먼저지만최종목업은39;별도theme/asset·ImageGen조건·기하renderer·실제판독gate |
|검수/세션 |같은A/B순차,이번새범위/연계수정만.새독립병렬/임의모델대체없음 |
|FAIL/정합 |확정결함과영향단위만정정/복원·같은B재확인,미해소중대/중간완료0 |
|직업/비용 |실제N/T/V/G/U확정뒤합계갱신·미접근class시험PASS0·지원선언/치유과장0 |
|실측불가 |가능한offline작업/검사는진행,실제게임항목NOT_RUN.미완필수기능은정확gap/다음조건 |
|외부skin/update |지원설정/skin수정우선·필요adapter/gap만,기능/조작/경보/사용자값유지·버전한계 |
|Git/게시 |R67–70이지정GitHub main전체게시/ID추상화macro사본을허용했고root가실제완료.R71이번계획묶음검수/통합후후속commit/push요청,Git은root만;A1행위0·force/merge임의권한/제품재사용권리확인창작없음 |

별도지침예외를새로요청하지않는다.R68–70개인macro공개사본허용은실제사용자명시변경으로기록했고원형불변/ID추상화조건을따른다.이후실제제작발주는아직시작하지않았고이후단계완료를주장하지않는다.

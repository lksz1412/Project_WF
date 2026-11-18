# Devil Black 기반 — WoW Forever 공용 애드온 모음집 계획

R44–R59 반영 후보 · 2026-11-18 · 프로젝트 `D:\Projects\Project_WF`

UI(User Interface, 게임 조작·정보 화면) 복원을 위한 이 파일은 R44 수정 전370행 보존 baseline 기반 A1 계획 변경 후보다. root 통합·같은 B 검수 전이며 게임용 구현·설치·설정·입력은 시작하지 않는다. 최신 R55–R59에 따라 기능 추가·개선을 먼저 수행하고 최종 목업은 마지막으로 이월하며 자작 macro 원본44개 private 라이브러리는 별도 보존한다.

간략 목차 — 챕터 → Phase → 누적 Step (1–5 최초 예상 보존,6 이후 미래 추정)

```text
1. 원형·현재 요구와 재사용 기준
   Phase 1.1 원본 확보·외형 추출
     Step 1 공개 원본·profile 구성 확인       45~90분 [완료된 역사분석]
     Step 2 첫 이미지 배치·style 기록         45~90분 [철회된2022기준·동결]
   Phase 1.3 옛 원형·채팅·설계 인계
     Step 3 자료실 전체·옛 샘플 대조          60~150분 [수용0/0/1]
     Step 4 Forever 채팅 해결법                30~60분 [수용0/0/0]
     Step 5 새 원형4K 설계 인계                45~90분 [설계 반환; 미수행렌더/P4는17로 사용자 이월]
   Phase 1.2 현재 요구·기능별 비교
     Step 6 요구·환경목록·안정Retail 참고    30~60분
     Step 7 전체/모듈/부분/자체 비교·담당 확정  60~120분
2. 기능 추가·개선, 관리와 외관 통합 [저장 계획·검수/피드백·GO 뒤 offline 제작]
   Phase 2.1 필수 기능 기반
     Step 8 모듈 기반·행동단축바·미니맵         60~120분
     Step 9 native3chat·체력/마나·시전·외관      120~180분
   Phase 2.2 필수 설정·사용자 편집
     Step 10 profile 저장·범위별 복원          120~180분
     Step 11 사용자 배치·스타일 편집기         120~180분
   Phase 2.3 독립 선택 기능
     Step 12 단일 전투보조·토템 입력 연계       60~120분
     Step 13 선택 공격대·데미지/어그로 통합     90~180분
   Phase 2.4 외부 스타일·데빌 질감·두 테마 작업
     Step 14 스킨/스타일·자산·테마 완성         120~210분 [+실제필요한질감개선60~120분]
   Phase 2.5 가능한 기능·연계 검증과 수정
     Step 15 offline 기능·통합·저장/복원 검사   60~120분
     Step 16 발견 수정·해당 연결 재검증         45~90분
3. 가능한 작업을 끝낸 뒤 최종 모습 전달·이후 실제게임 확인
   Phase 3.1 최종 목업·offline 인계 [앞의 가능한 기능작업 모두 닫은 뒤]
     Step 17 최종4K/하단/상세·테마비교 목업    90~150분 [Step5미수행렌더/P4 수신]
     Step 18 offline 고정판·복원/검증 인계      30~45분
   Phase 3.2 실제 게임 확인 [접속가능·게임적용 별도승인 때]
     Step 19 실제환경·Retail참고/백업·입력/저장 45~90분
     Step 20 전투·주술사·지도·외부스킨 연계    60~120분
   Phase 3.3 실제게임 발견 수정·확정
     Step 21 발견 정정·해당 연계 재검증        45~90분
     Step 22 실제통과 버전·복원 자료·인계      30~45분
```

현재 가능한 미래 Step6–18은1005~1755분(16.75~29.25시간), 실제 필요한 R52 질감 개선까지 포함하면1065~1875분(17.75~31.25시간)으로 추정한다. 사용자 접속·게임 적용 승인이 필요한 Step19–22는 별도180~345분이며 지금 가능한 작업이나 최종 목업을 막지 않는다. 전체 미래6–22의 합계는1185~2100분, 조건부 개선 포함1245~2220분이다. 기존 미래6–15의540~930분 대비 기본 증가645~1170분은 테마/자산120~210, 기능 비교15~60, 필수 설정/편집240~360, 선택 통합45~120, offline검증60~120, 해당수정45~90, 요구목록0~15, 최종목업/인계120~195분이다. 최종목업 비용은 이미 끝난 Step5 시간을 다시 계산한 값이 아니라 이월된 실제렌더·변형비교·검증을 남은 작업으로 산정한 것이다. Step1–5 최초 예상과 실제 이력은 유지한다. 네트워크 회수/사용자 접속 대기와 기존 소형 custom unit frame 추가4~8시간은 별도다. 큰 fork/지원 gap이 확인되면 해당 범위를 실제 근거로 재추정하며 완료 시각이나 모든 provider의 스킨 가능성을 약속하지 않는다.

## Summary

목표 제품은 **애드온 모음집(AddOn collection/package)**이다(R60). 필수 외관·채팅·설정/편집과 실제 필요한 기존 외관 제품은 배포 묶음으로 관리하고, 기능 제품은 각 폴더/TOC/저장/선택 경계를 유지한다. 한 전투보조 역할은 모음집 전체를 하나의 AddOn/TOC로 합친다는 뜻이 아니다.

최신 실행 순서는 **기능 추가·개선 → 필수 저장/복원·편집 → 선택 기능 통합 → 스타일/질감·두 테마 작업 → 가능한 offline 기능·연계 검증/수정 → 최종 목업**이다(R55–R59). 자체 게임 애드온 Lua와 완성 목업은 아직 작성되지 않았다. 사용자의 최신 기능 제작 의도를 과거 조사-only 문구로 취소하지 않는다. 다만 이번 A1 발주는 계획·요구 대응표만 작성하며 실제 제작은 저장 계획의 독립 검수·사용자 피드백/갱신·명시 GO를 root가 처리한 뒤 발주한다. offline 코드 작성·검사와 게임 폴더 설치·설정·입력·실제 전투 검증은 구분한다.

시각 기준은 **idx45 실제 네 번째 샘플**이며11218의 오른쪽 미터기는 제외하고 세 번째 채팅창을 유지한다. 세 반투명 대화창·얇은 이음새·긴 검은 띠·양끝 장식·아래 사각 지도와4K 버튼→행/간격→하단 높이 순서를 고정한다. EllesmereUI는 기능 참고이며 외관 전환·코드 복제 대상으로 선택하지 않았다.2022 FanFix 결과는 철회·동결 상태다.

필수 baseline은 데빌 외관·native 세 채팅의 외형·설정 저장/복원·사용자 편집이다. 필요한 기존 외관 provider는 한 배포 묶음의 manifest로 관리할 수 있으나 외부 제품의 소스를 합치거나 권리를 바꾸는 뜻은 아니다. 전투보조·데미지·어그로·조건부 공격대 frame은 **독립 선택 가능한 별도 AddOn 제품**으로 둔다. 한 항상 로드되는 monolith 안에서 표시만 끄는 방식은 이 요구를 충족하지 않는다.

주술사 상태/proc·cooldown(CD, 재사용 대기시간) 표시·선택 추천은 한 전투보조 제품 역할로 평가한다. Hekili Forever는 조건부 후보이며 전체 요구·복원 치유 지원이 확인됐다는 뜻은 아니다. 데미지와 어그로도 성숙한 기존 제품을 선택할 수 있으며 전부 자체제작으로 확대하지 않는다. native Totem Bar는 소환 입력, 기본 party/raid는 미선택 상태의 안전 baseline이다.

재사용은 기능별 실측 비교로 정한다. 더 낫거나 동등한 자체 구현은 유지하고, 자체가 부족하며 외부가 그 차이를 실제로 메울 때 도입한다. 현재 자체 게임 애드온은 미구현이라 우열 판정은 아직 없다. 전체 외부제품 사용·독립 모듈 이식·부분 기능/설정·자체 유지·외부 기능에 자체 스킨을 연결하는 방식을 구분한다. V42의 실제 native 채팅/저장·compat·panel/map 기전은 이 비교의 후보이며 설치기·필터 초기화·uiScale 일괄 복사는 제외한다.

완성된 목업은 이 채팅에4K 전체와 하단/상세 원배율 그림으로 전달한다. 선택 기능 예시가 필요하면 별도 가상 시나리오로 표시하고 세 채팅 baseline이나 실제 선택·게임 시험으로 위장하지 않는다. R46은 전달 방식이며 출근 중 실제 게임 검증을 대신 완료했다는 뜻이 아니다.

R51의 마지막 목업에 포함할 대안은 원래 데빌 구획을 유지한 두 테마다. root가 제안한 ‘네온 보컬 스테이지’와 ‘백자와 먹빛’을 작업 방향으로 삼되 사용자 최종 선택으로 적지 않는다. 단순 recolor를 넘어 재질·장식·폰트·막대·패널을 일관되게 구성하고 baseline을 교체하지 않는다. 세 창·버튼/행·지도/health 위치와 입력 의미는 동일하게 둔다.

R52는 원형 데빌 질감이 실제4K에서 부족할 때만 별도 개선본을 만들 수 있다는 허용이다. 원본 충실 baseline을 보존하고, 개선 자산·목업과 원형 대비를 별도로 제시한다. 모든 오래된 texture가 나쁘거나 교체 대상이라는 판정은 아직 없다.

## Current Ground Truth

### 실제 관찰·제약

| 구분 | 확인한 내용 | 한계·적용 |
|---|---|---|
| client | `_forever_\Wow.exe`, file/product version `1.60.1.70938` | 관찰 시점 사실, 실행 직전 재확인 |
| 화면 | 사용자 R21: 4K 화면. 과거 캡처2560×1440은 캡처 metadata만 의미, locale koKR | 실제 render resolution·UI scale 미확인. R22: 버튼 크기와 하단부터 쌓는 높이 우선, 화면 전체 비율 환산 금지 |
| CurseForge | 15개 과거 프로젝트, 9개 Update·6개 Recently Updated | 앱 label은 현재 지원·작동·개발 중단의 증거가 아님 |
| 정리 가능성 | 사용자가 AddOns를 직접 정리할 의사 표시 | 삭제 완료 미확인. 과거 목록을 현재 설치 상태로 가정하지 않음 |
| 새 환경 | 사용자: “지금은 와우 포에버라 전혀 아무것도 없는데?” | 옛 macro·keybind·profile이 이전됐다고 가정하지 않음 |
| 비매크로 Retail 설정 참고(R13) | 사용자 요청: 본섭 설치·설정 저장 뒤 `_retail_\WTF` 설정도 참고. 폴더 존재만 확인됐고 저장 완료·안정 상태는 미검증 | Phase1.2 Step6에서 준비·안정 상태를 확인해 가능하면 먼저 읽기 전용 참고. 미준비 부분만 이유/재확인 조건과 함께 보류하고 Step19에서 적용 전 재확인. Devil 외형 고정, 파일/profile 자동 이식·macro 작업 없음 |
| macro 후속 | 최종 요청은 원본 보관·도서관 관리. master 전달의 helper 완료 반환: 원본4파일·44개·6487bytes, scope별9/11/16/8개, SHA256 4/4 동일·private manifest/INDEX 생성·Git 제외 확인 | 이 A는 raw 미독. 원본 라이브러리 보관 완료 반환을 반영했으며 게임 복사·병합·적용·호환성 시험은 수행하지 않음 |
| 원본 | Step3에서 제공2009/Alpha와 기존2022 비교원천에 더해 공개 X2 R3.4·2008 Black CUSTOM·BlackEdition2 Alpha·Forever V42를 직접 확보 | X2 전체4217개 중288개 경로가 목록에서 부적합해 전체추출 차단, 정확한46개만 안전 회수. 다른 새배포본도 손상·경로·추출 검사 기록 보존. 설치EXE/Lua 실행 없음; 샘플4와각build의동일성·현재작동은미확정. 결과 old-reference/acquisition/r36/ |
| archive | SourceArchive/2022-11-19/originals에 ZIP2개 보존, CRC 오류0·추출파일4614/4614 일치. 관련 설정파일7개 비실행 파싱과 loaf 선택·자산 연결 분석 | 원형분석 보고 original-source-analysis.md 참조. Quartz loaf 부재·병존 초기화·재배포 권한 한계 유지 |
| 실제 게임 | 설치·설정·전투 시험 없음, 관찰 종료 | 모든 runtime gate는 예정. 지금 게임 입력하지 않음 |
| offline검사 도구 |root 사전관찰 전달: 설치된 Python lupa2.8의 lua51에서 Lua5.1 생성과 무해한 table/function probe7 확인 |도구 가용성만 확인. A1재실행/새설치 없음,애드온/게임API/전투 시험 PASS 아님 |
| 프로젝트 | 최종 `D:\Projects\Project_WF`; 앞선 C: 기록 보존 | 현재 발주는 계획 후보만 작성. canonical 통합·Git은 root 담당, 게임·개인자료 변경 없음 |

### 원문·관찰 위치

- 사용자 요구: `Codex/results/REQUEST_LEDGER.md`와 최신 master 전달. 첫 이미지 확정, 15개 참고, 주술사, 새 환경, D: 경로와 최종 macro 원본 라이브러리 범위를 구분한다.
- 관찰: `Codex/docs/observed-environment.md` 1~29행. 과거 파일명·앱 제공판: `Codex/docs/addon-reference-inventory.md` 1~31행.
- 외부 근거: `Codex/docs/shaman-source-evidence.md` S1~S10·U1~U6. 실제 URL·작성자/유형·기간·짧은 원문·한계를 담는다.
- 원본: [공개 Drive 폴더](https://drive.google.com/drive/folders/1QMZiceFpizZ5dHxTkG2UemZAYKaQFdg7), 로컬 SourceArchive/2022-11-19/. 실제 원형 분석은 Codex/docs/original-source-analysis.md 및 source-analysis 근거 기록에 있다. 정적 분석과 게임 시험은 구분한다.
- 비매크로 참고 입력(R13): `C:\Program Files (x86)\World of Warcraft\_retail_\WTF`. 본섭 종료·설정 저장이 끝나 파일이 안정됐는지 Step6에서 먼저 확인한다. 이미 안정된 로컬 자료라면 게임 조작 없이 읽기 전용 참고가 가능하며 출근 상태만으로 불가 판정하지 않는다. 불안정/미준비 부분만 근거와 함께 보류하고 그 자료에 기대지 않는 기능은 계속한다. Step19는 실제 적용 전 재확인·현재 상태 백업이다. 필요한 설정의 뜻만 읽기 전용으로 참고하고 raw·개인 식별자는 공개 기록하지 않는다.
- 경로·현재 범위: `Codex/docs/PROJECT_LOCATION.md`의 `Current R17 scope — original library only` addendum과 `Codex/docs/INDEX.md`. 앞선 경로·macro 적용본 설명은 역사 기록이며 현재 실행 근거로 쓰지 않는다.

확정은 관찰·페이지 표기·사용자 결정 확인, 근거 미발견은 조사했으나 못 찾은 내용, 추정은 설계 가설, 미검증은 확인하지 않은 항목이다. 배포 선언과 개인 후기는 이 PC runtime PASS가 아니다.

### 늘 지킬 제약

| 명령 | 처리 갈래 | 근거·적용 |
|---|---|---|
| 옛 블랙 하단집중형 복원 | 작업 한정 | R25·R26의2022 기준 제외·전수조사는 완료. R34의45 실제샘플4를 현재 기준,11218 미터기 제외를 보조 참고로 유지 |
| 기존 조합은 참고 | 작업 한정 | R4: “참고만해”; 전체 적용 금지 |
| Hekili 경험·주술사 후기 | 작업 한정 | R6·R7: 효과 알림+추천, 토템·mana·치유 요구 반영 |
| 개발과 실제 게임 적용 구분 | 작업 한정 | R55–59: 기능 제작 우선,offline개발은 root의 저장계획/검수·피드백·GO 뒤. 실제 게임 파일 설치·설정·입력은 별도 승인·접속가능 때 |
| 4K 하단 적층 | 작업 한정 | R21·R22: 버튼 크기·행·간격·바닥 여백부터 쌓고 주변 창 배치. 화면 전체 비율 환산 금지 |
| 새 환경·D: 경로 | 작업 한정 | R10·R12, 옛 설정 존재 가정 없음 |
| 자작 macro 원본 라이브러리 | 작업 한정 | 최신 사용자: “그냥 원본만 보관하고 도서관처럼 관리해줘. 나중에 필요한거 꺼내달라고할게.”; 44개 원문·scope 보존, 검색색인만 추가. 게임 적용·변환 취소 |
| 비매크로 Retail 설정 참고 | 작업 한정 | R13의 저장 뒤 참고 요청 유지. R17은 macro 이동·적용본만 취소. 읽기 전용 참고이며 Devil 외형·현재 Forever 설정을 자동 교체하지 않음 |

### R42–R59 현재 확정 요구

| 요구 | 현재 적용 | 범위·근거 |
|---|---|---|
| 기능 참고 | EllesmereUI의 기능을 참고할 수 있음 | R42–43; 데빌 외관 교체·코드 복제·귀마개 프로젝트 동일성 확정 아님 |
| 필수 외관 묶음 + 독립 선택 기능 | 필수 appearance provider는 baseline 배포 묶음, 선택 기능은 별도 AddOn 폴더/TOC(게임의 파일 로드 목록) | R44; 한 monolith의 숨김 toggle만으로 대체하지 않음 |
| 설정 저장·복원과 사용자 편집 | 필수 core 관리 기능 | R44; 기본값·사용자 변경값을 구분하고 reload/relogin 뒤 유지 |
| 전투보조 한 담당 | 주술사 상태/proc·cooldown 표시와 선택 추천을 한 제품 역할로 묶음 | R44–45; 토템 소환 입력은 native 담당, 전체 부가기능 자체제작 아님 |
| 유용한 V42 재사용 | 실제 읽은 기전별 전체/부분/보류를 선택 | R47; 현재 동작·이식 성공과 별개 |
| 더 나은 자체 구현 유지 | 기능별 비교에서 자체가 동등/우수하면 유지, 실제 부족을 외부가 보완할 때 도입 | R48; 현재 자체 게임 코드가 없어 우열 비교 완료 아님 |
| 재사용 단위 명시 | 전체 외부제품 사용/독립 모듈/부분 기능·설정/자체 유지/외부기능+자체스킨 구분 | R49–50; loader·caller·저장·의존·업데이트 경계 포함 |
| 외부 공격대/미터 외형 | 설정·스킨·별도 작은 adapter로 필요 시 데빌 외관 연결 | R50; 특정 공격대 제품 강제 없음, native baseline 유지 |
| 다른 테마1–2안 |Phase2.4 Step14에서 두테마 스타일/자산,Phase3.1 Step17에서 최종 전체/하단/비교 목업 |R51; root 디자인 제안은 최종 사용자 선택 아님, Step5 고정 파일 무변경 |
| 데빌 질감 조건부 개선 |실제4K 관찰로 미달이 확인될 때 별도 개선 자산/목업·원형 비교 |R52; 모든texture교체나 원천/고정Step5 변경 아님 |
| 기능 먼저·목업 마지막 |R55–R59 최신 순서,전체59요청 대응표 |기능/관리/선택/스타일→가능한검사/수정→Step17최종목업; Step5미수행렌더 명시 이월 |
| 목업 전달 | 완성 후 이 채팅에4K 전체와 원배율 하단·상세 제시 | R46; 출근 중 게임 확인 불가, 실제 게임 조작/검증 승인 아님 |

이 요구는 작업 한정이다. 미터를 세 번째 채팅창 자리에 넣지 않으며, 필터·키·macro·전체WTF 자동 이식도 하지 않는다.

### 구조 맵

| 경로 | 역할·상태 |
|---|---|
| `Codex/plans/2026-11-17-devil-ui-forever-plan.md` | 현재 초안 |
| `Codex/plans/2026-11-17-devil-ui-forever-phase<ID>-세부계획.md` | 각 Phase 착수 때 작성할 미래 파일 |
| `Codex/docs/` | 관찰·참고표·후기 근거·프로젝트 위치·INDEX |
| `Codex/results/` | 요청·발주·작업·검수·향후 실행 기록 |
| `outputs/` | 검수 후 전달본 자리 |
| `Codex/results/handoffs/old-reference/r44-plan-update/` | 이번 계획 후보·작업로그·변경 지도. canonical은 root 통합 전까지 변경 없음 |
| `Codex/results/old-devil-layout/` | 이미 반환된 A1 설계·자산·고정 영수증. 이번 계획 수정은 내용 변경 없음 |
| 미래 core/선택 AddOn·스타일 adapter | Step 7에서 경로/TOC/의존 manifest 확정할 계획 대상. 지금 폴더나 코드를 생성하지 않음 |
| `work/` · `MacroLibrary/` | work는 임시 자료, MacroLibrary는 ignored private 원본4파일·manifest·44개 검색색인. 개인 raw는 Git 추적·외부 전송 안 함 |

현재 요구 원본은 이전 REQUEST_LEDGER.md와 현재 REQUEST_LEDGER_phase1.3.md의 R1–R59다. 신규 R42–R59는 개별 메시지도 직접 대조한다. 전수 대응은 `Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.md`와 `Codex/results/handoffs/old-reference/r44-plan-update/requirements-coverage.json`에 고정한다. Step3/4 보고는 수용됐고 Step5 A1 설계가 반환됐다. 완성 렌더·게임용 자체 애드온은 아직 없다. 기존 계획의 최초 진입·2022 분석 설명은 당시 기록이다. 사용자용 계획은 한글, 내부 실행 기록은 addon·파일·API(Application Programming Interface, 애드온이 사용하는 게임 기능) 식별자를 다루므로 영어로 유지한다.


판정 근거: 수용된 old-devil-reference-comparison.md1–192, a1-r36-source-evidence.md1–118, forever-clean-chat-research.md1–116. V42는 core1905행·minimap1203행과 관련 loader/compat를 읽은 정적 근거이며 전체 번들/PitBull·Leatrix core·모든 profile 감사가 아니다. Ellesmere/귀마개 관계는 guimagae-addon-public-facts-2026-11-18.md1–60의 한계를 유지한다. 기능 목록·구성 참고를 새 코드 독해나 재사용 허가로 바꾸지 않는다.

## Phase Range

| 챕터·Phase | 목표·선행 조건 | 다음 단계 입력 |
|---|---|---|
|1·1.1 |완료된 역사분석·철회Step2 보존 |현재 원형과 구분한 역사 입력 |
|1·1.3 |수용Step3/4·Step5 고정 설계 인계 |설계/자산 그대로; 미수행렌더/P4·전달은 Step17로 USER_DEFERRED |
|1·1.2 |Step6 요구/가능한 입력·안정Retail참고·Step7 기능별 비교 |59요청 대응·범위/담당·전체/부분/자체/하이브리드·의존/저장 manifest |
|2·2.1 |offline 기능 기반·native3chat·bar/health/mana/cast/map |선택 기능 없이도 사용하는 필수 기능과 입력/분류 보존 계약 |
|2·2.2 |필수 저장/복원·사용자 편집 |기본값/사용자값·범위별 snapshot/copy/restore·편집 persistence |
|2·2.3 |단일 전투보조·독립 선택 raid/데미지/어그로 |기능별 한 제품,선택모듈 부재/중지에도 core 유지 |
|2·2.4 |기능 소유권을 유지한 외부 스타일·데빌 질감 평가·두 테마 자산/스타일 |고정 geometry를 소비하는 구현/자산; 최종 전체/하단 목업은 아직 생성하지 않음 |
|2·2.5 |현재 가능한 기능·통합검사와 발견 수정 |모듈/저장/편집/분류 모델·부재/업데이트 검사 결과,live-only NOT_RUN 목록 |
|3·3.1 |앞선 가능한 작업/수정 종료 뒤 최종 모습·offline 인계 |Step5 이월렌더+원형/조건부개선/두테마4K·하단/상세·비교·P4·채팅 전달 |
|3·3.2 |접속 가능·실제 적용 승인 뒤 환경/백업·runtime |실제입력/필터/저장/전투/외부제품 증거; 그 전에는 미검증 |
|3·3.3 |실제게임 발견 수정·해당 검증·최종 고정 |통과/미검증 구분한 버전·복원·사용자 편집 인계 |

현재 발주는 이 계획 후보와59요청 대응표 작성뿐이다. 각 미래 Phase는 상세 계획 저장→범위 확인→실행→결과→해당 검증→기록 순서로 진행한다. 같은 산출물의 작업 A와 검수 B는 순차 왕복하며 새로운 독립 병렬 유닛 승인을 만들지 않는다. Step5의 미수행 렌더는 R55로 Step17에 이월됐으며 즉시 시작하지 않는다. 최신 요청에 따른 offline 기능 제작은 root의 구체적 계획 게이트 뒤 진행하고, 실제 게임 파일 설치/설정/입력은 별도 승인·접속 가능 때만 수행한다.

## Non-goals

- 과거 조사-only 범위를 최신 기능 제작 의도의 취소 근거로 사용하거나, 기능 미구현 상태에서 목업만 먼저 완성하기. 현재 A1은 계획만, 실제 offline 제작은 root 계획 게이트 후다.
- 미래 구현 계획을 현재 게임 실행 승인으로 바꾸기, 출근 중 게임을 자동 조작하거나 미수행 시험을 PASS로 보고하기.
- 기존15개 전체 설치, 기능 모듈 전부 자체제작, 전체 외부 UI로 전환, 자체보다 약한 외부 코드로 강제 교체.
- 외부 애드온 전체 사용을 소스 합치기/재배포 허가로 해석, V42 전체 이식·Leatrix core/PitBull 전체 호환성 단정.
- 선택 미터로 세 번째 채팅 대체, 선택 기능 off인데 항상 로드되어 event/timer/hook 작업이 남는 monolith.
- macro·keybind·계정전체WTF 자동 import/reset, 과거 필터·창ID·uiScale·화면 비율 이식, 개인 raw 외부 전송.
- 자동 cast/target·전투 protected frame 제한 우회, 모든 특성/레벨/콘텐츠·모든 외부 스킨/업데이트 호환 보장.
- 채팅 검색/복사/history/저장 같은 미요청 extras의 자동 추가. 기능 참고를 이유로 새 extras 목록을 만들지 않음.

## Implementation Changes

### 필수 baseline과 독립 선택 AddOn

필수 baseline 배포 묶음은 자체 데빌 외관/native 채팅 스타일/설정·편집 기능과 실제 필요한 기존 외관 provider를 manifest로 관리한다. 외부 제품은 고유 폴더·TOC(게임의 AddOn 로드 목록)·버전·저장영역을 유지한다. 여러 폴더를 한 배포 묶음으로 제공하는 것과 원본 코드를 하나로 합치는 것은 다르다. 정확한 패키지명·경로·필수 의존은 Step7에서 정한다. 지금 새 필수 dependency를 선택하지 않는다.

전투보조·데미지/어그로·조건부 공격대 provider는 각각 게임 AddOn 목록에서 독립 선택할 수 있어야 한다. 동일 제품이 데미지와 어그로를 지원하면 두 제품을 겹쳐 넣지 않고 표시 기능을 선택한다. 선택 기능이 없어도 core 외관·세 채팅·설정/편집은 사용 가능해야 한다. 스타일 adapter도 해당 provider와 함께 선택/중지하는 별도 단위다. 공유 core 의존은 실제 필요한 경우에만 선언한다.

### 기능·표시·스타일의 단일 담당

| 범위 | 계획상 담당 | 경계·현재 상태 |
|---|---|---|
| 일반 행동단축바·label·paging |Dominos 조건부 전체제품 |기존 기록12.0.4는 과거 후보값, Step7 정확판 재확인. 현재 slot/bind 보존 |
| player/target health·mana |Forever Unit Frames(FUF) 조건부 또는 native; 부족한 자체 연결 |기존0.65.0은 후보 metadata. 더 나은 자체 구현이 생기면 R48 비교 뒤 유지, 현재 자체 완성품 없음 |
| party/raid |기본 frame baseline, 선택 시 검증된 기존 공격대 제품 한 개 |별도 제품 필수화 없음. 선택 전 FUF/별도 frame 중첩 없음. 선택 후 native 중복은 실제 시험 뒤 처리 |
| 미니맵 |SexyMap 조건부 전체제품 |기존v12.1.7 후보 기록. 아래 사각형·클릭·zoom·tracking 검증 |
| player/target 시전바 |Quartz 조건부 전체제품 |기존3.8.0 후보 기록. Dominos Cast/FUF castbar 중복 제거는 실제 확인 뒤 |
| 세 native 메시지창·일반 입력 |기본 채팅 엔진 |현재 필터·dock·창 역할 보존. 과거1/2/3 또는1/3/4 자동 이식 없음 |
| 채팅 장식·폰트·배치 |작은 자체 외형 담당 우선 설계; Prat 조건부 대안 |Step4 근거. 대안 선택 시 같은 부분을 자체/BasicChatMods(BCM)/Glass/Leatrix가 중복 제어하지 않음. history/메시지 부작용0 주장 없음 |
| 블랙 panel·seam·장식 |자체 외관 담당 |비입력 장식, native/provider 기능 소유권을 빼앗지 않음 |
| 저장·복원·사용자 편집 |필수 자체 관리 |own profile와 지원되는 provider 설정을 범위별 연결. 전역WTF/키/macro reset 없음 |
| 토템 소환·교체·회수 입력 |기본 Totem Bar; 이동 대체 시 검증한 입력 담당 하나 |상태/proc/cooldown 알림과 입력 소유권을 구분 |
| 주술사 상태/proc·cooldown·선택 추천 |선택된 기존 전투보조 제품 하나 |Hekili Forever 조건부 후보. FUF의 별도 토템 상태 indicator를 필수 중복 owner로 요구하지 않음. 필요한 상태를 못 채우면 조합을 확정하지 않고 기능 gap으로 남김 |
| 데미지·어그로 |선택된 기존 제품, 각 표시 영역 한 담당 |특정 제품/판본/Forever 호환 미확정. 둘 다 설치/on 필수 아님. 세 번째 채팅 자리는 유지 |
| 외부 공격대/미터 외형 |provider 기능 + 지원 설정/스킨 또는 자체 스타일 adapter |R50 하이브리드. 값 계산·대상 조작은 provider, 색/폰트/경계/spacing 등 스타일만 연결 |

모든 현재 버전 표기는 기존 계획의 기록이며 새 조사로 최신성을 갱신한 것이 아니다. 기능 선택 시 정확 Forever 파일·의존·소스/제작자 선언과 실제 동작을 구분해 확인한다. PitBull은 V42 동봉 TOC 선언만으로 전체 호환을 확정하지 않는다. native party/raid가 기본이며 새 공격대 제품을 먼저 강제하지 않는다.

### R48–R49 재사용 범위와 비교 gate

| 대상 역할 | 잠정 재사용 단위 | 실제 근거 | 함께 확인할 연결 | 가져올 것 / 제외할 것 | 최종 판정 시점 |
|---|---|---|---|---|---|
| 전투보조 |기존 AddOn 전체제품 사용 |R44–45·기존Hekili 선언/후기 한계 |TOC·라이브러리·spec/event·저장·enable/disable·전투 제한 |검증된 상태/proc/CD와 같은 제품의 선택 추천; 별도 EventAlert/CD stack 자동 추가 제외 |Step7 범위 선택→Step12 실제 기능·Step20 전투 확인 |
| 데미지/어그로 |기존 제품 전체, 필요 시 동일 제품 안 기능 선택 |R45; 제품·지원판 아직 미선정 |provider 데이터/창/저장·의존·정확 Forever판 |검증한 기능; 중복 계산/동일 표시 두 owner 제외 |Step7 선택→Step13 통합→Step19–20 확인 |
| 공격대/미터 + 데빌 외형 |전체 기능제품 + 자체 별도 스타일 adapter |R50, 원형 스타일은 수용된Step3/고정Step5 |지원 skin/profile API→frame lifecycle→style 적용/해제→저장→provider 업데이트 |필요한 외형만. 기능 계산·필터·mouse/click-cast 의미는 provider에 유지 |Step7 실제 제어면 비교→Step13 기능/Step14 스타일 구현→Step15/19–20 |
| V42 native 창 생성/배치 |부분 기능·설정·연결 코드 후보 |a1-r36-source-evidence.md:9–38; core967–976/1096–1207, minimap197–226/487–513 |TOC→core→profileXML→minimap, 창 생성/undock·배치·저장 caller |세 독립 native 역할과 허용 배치 연결; core1174–1184와map815–838 필터reset/배포자 채널 분담 제외 |Step7 자체 gap·연결검증→Step9 최소 이식 여부, 현재 이식 없음 |
| V42 native 위치 저장 |부분 기능 후보, 자체 관리와 구분 |core765–806 CommitNativeChat·minimap88–103/487–513, a1-r36-source-evidence.md:31–33 |C_EditMode 사용 가능성·save/reload 호출·변경 신호·combat/EditMode guard |지원되는 native 위치 저장 연결만; own 설정 전체 snapshot 기능이 이미 있다는 주장 제외 |Step7 계약 비교→Step10 scope복원/Step19 persistence |
| V42 compatibility adapters |전체 독립 모듈 후보 또는 필요한 helper 부분 |Devilconfig/ForeverCompat.lua1–37, a1-r36-source-evidence.md:24 |C_AddOns/global fallback·AceConfigDialog 호출·namespace·load order·gradient/resize caller |같은 기능의 자체 구현보다 나을 때 필요한 helper만. AceConfig 등 dependency를 자동 도입하지 않음 |Step7 전 파일/호출체인·조건 비교 후 모듈/부분/미채택 결정 |
| V42 panel/map helper |부분 기능/설정 후보 |minimap12–31/235–237/605–627/707, a1-r36-source-evidence.md:34 |mask/backdrop·style option·profile 저장·map input·frame lifecycle |사각 mask/얇은 경계/선택 저장의 실제 gap; cfg.x*w 같은 fraction과 installer의 globaluiScale 제외 |Step7 비교→Step8/9 담당과 연결검증 |
| V42 installer·profile import |통째 이식 제외, 필요한 자료만 비교 |core1595–1675; import_presets·uiScale0.7/0.9·Reflux, a1-r36-source-evidence.md:35 |프로필명/입력/초기화·외부 의존 영향 |실제 유효한 한정 설정 뜻만; 전체reset·오류숨김·채널삭제·구형비율 복사 제외 |Step7 한정 비교, 전체 installer 실행/이식 없음 |
| V42 PitBull/Leatrix·부분 profile |근거 대기 |a1-r36-source-evidence.md:38/78–79·forever-clean-chat-research.md:82–84: TOC/loader와 제한된 정적 근거만 |전체 관련 모듈·실제 loader/API/데이터 최종값·조건 |현재 근거가 없는 whole-module/전체 지원 주장은 가져오지 않음; V42세 profile 전체파싱 아님 |실제 필요가 생긴 해당 범위만 후속검증, 지금 새 감사 안 함 |
| 자체 외관·채팅·설정·편집 |자체 유지 또는 gap만 외부로 보완 |R48·현재자체게임코드미구현 |자체 기능/품질·입력·저장·의존·유지보수의 동등 조건 비교 |자체가 동등/우수면 유지. 실제 미달만 외부가 입증해 채울 때 도입 |Step7 후보판정은 잠정, 구현된 부분의 실검증 후 선택 고정 |
| EllesmereUI 기능 참고 |기능 요구/구성 참고, 코드 이식 미선정 |R42–43·사실표60행·root 공식페이지 확인 |원제품/본인 프로젝트 정체성·실제 관련 source·재사용 조건은 별도 |기능적 기준; 외관 변경·원제품과귀마개프로젝트동일시·코드복제권한 제외 |실제 필요/근거를 얻은 기능만 미래 비교, 현재 새source감사 없음 |

V42 원문 루트는 `work/old-reference-r36-3ed3y_p1/extracted-forever-v42/Interface/AddOns/`다. 표의 source 약칭 core는 `!DevilUI/!DevilUI.lua`, minimap/map은 `!DevilUI/minimap.lua`이며 compat는 `Devilconfig/ForeverCompat.lua`다. 파일별 해시와 실제 전문 독해 범위는 `Codex/results/old-reference/a1-r36-source-evidence.md:9–18`에 있다.

표의 V42 source 위치는 Step3에서 실제 전문 독해한 보존 원문을 가리킨다. 모듈이 있다는 사실·함수 정의·현재 TOC tag는 이 PC 작동 PASS가 아니다. whole 외부제품 통합은 해당 AddOn을 그대로 사용하는 방식이고, module/부분 이식은 소스를 자체 코드에 가져오는 별도 선택이다. source 이식에는 필요한 caller/callee·반환/빈값·초기화·event/저장/종료 계약까지 묶으며 snippet만 복사하지 않는다. 원천 버전/해시·적용 차이·지원 조건·유지보수 담당과 확인된 사용 조건을 남긴다. 알려지지 않은 재사용 권한을 만들지 않는다. Ellesmere 공식의 All Rights Reserved 표기는 root가 확인한 배포 조건이며 이번 A1이 새제품 코드를 독해하거나 허가를 얻었다는 뜻은 아니다.

R48 비교표의 최종 행은 실제 동일 feature set·4K 가독성·분류/입력 보존·저장/복원·combat/lifecycle·dependency/업데이트 비용으로 판정한다. 자체 완성품이 없을 때는 ‘미구현/후보’로 적는다. mature 전투보조/미터를 쓰기 위해 비교용 자체 미터를 일부러 만드는 작업도 하지 않는다. 외부가 더 낫다는 추정만으로 교체를 미리 정하지 않는다.

### 필수 설정 저장·복원·사용자 편집

- **own profile**: 기본 Devil 값과 사용자 편집값을 구분하고 schema/version·canvas/UI scale·선택 provider 버전을 함께 기록한다. snapshot/copy/Devil 기본값으로의 범위별 reset과 이전 own profile 복원을 지원하도록 설계한다. 기본값을 되돌리는 것은 개인WTF 전체 초기화가 아니다.
- **적용 흐름**: 현재 지원값 읽기→초안/미리확인→허용 상태에서 적용→성공 시 저장. 실패 시 해당 변경 전 snapshot으로 되돌린다. provider에는 지원된 API/profile 범위만 쓰고 raw DB 전체 교체를 기본으로 삼지 않는다.
- **지원 범위별 복원**: 자체 설정과 실제 지원되는 외부 설정 adapter를 명시한다. 미선택/미설치 provider의 저장 entry는 보존하되 현재 적용은 건너뛰고 이유를 표시한다. 알 수 없는 schema/version은 silent reset하지 않으며 다른 provider·창 필터·키/macro를 바꾸지 않는다.
- **사용자 편집**: 이동·크기·폰트/크기·색·행/열·gap 등 지원되는 값을 직접 바꾸고 잠금·취소·되돌리기·기본값/사용자 profile 선택을 할 수 있어야 한다. provider가 제한하는 항목을 작동하는 척 노출하지 않는다. 사용자 수정값은 reload/relogin 뒤 유지하며 테마 전환/업데이트가 위치와 필터를 몰래 초기화하지 않는다.
- **전투 경계**: protected 편집은 전투 밖으로 미룬다. 실제 안전한 API·EditMode 상태 확인과 UIscale 변환은 후속 게임 검증이다. 클라우드/계정연결/sync는 추가하지 않는다.

### R50 외부 공격대·미터의 스타일 연결

설정/profile로 가능한 것부터 적용하고, 부족하면 지원 skin/theme extension이나 작은 별도 adapter를 검토한다. 직접 소스 수정/fork가 꼭 필요할 때는 실제 source/API/callchain·사용 조건·고정판/업데이트 diff·유지보수 범위를 확인한다. 기존 제품이라는 이유로 기본 외형을 고정하지도, 모든 제품에 안전한 skin API가 있다고 가정하지도 않는다.

스타일 기준은 선택된 테마의 panel 재질·얇은 border/seam·일관된 폰트/크기·막대 질감/간격이다. 데빌 baseline은 검고 반투명한 구획을 따른다. 역할/경보/위험도 색은 의미가 먼저이며 색만으로 판정을 전달하지 않는다. raid 역할·debuff/경보·선택/사거리 등 필요한 의미와 mouseover/click casting·마우스 선택·전투 제한을 보존한다. 미터 스타일도 값·정렬·세션 의미를 바꾸지 않으며 세 번째 채팅에 자리 잡지 않는다. 미정 위치는 미래 별도 시나리오에서 제안하며 현재 Step5 geometry는 바꾸지 않는다.

provider와 스타일 adapter는 버전을 구분해 저장하고 provider update 뒤 적용/복원·frame 재생성·style 유지 여부를 확인한다. update가 skin을 지우거나 더 나은 자체 구현을 강제로 교체하지 않게 실제 지원 버전을 고정/비교한다. 미지원 update라면 기능을 손상시키는 잘못된 hook을 계속 적용하지 않고 해당 style만 보류·한계를 표시한다. 외관 선호는 이미 준 reference로 판단하며 같은 미적 선택을 다시 질문하지 않는다.

### R51–R52 동일 구획의 질감 평가·다른 테마 목업

기능 기반·관리·선택 제품 통합 뒤 Phase2.4 Step14에서 별도 theme/style와 필요한 자산으로 두 변형을 완성하고 가능한 기능검증에 넘긴다. 최종 전체/하단 목업은 Step15–16의 가능한 검사/수정 종료 뒤 Step17에서 만든다. ‘네온 보컬 스테이지’는 중성 dark 재질·절제된 cyan/pink·전자음악 파형/조명, ‘백자와 먹빛’은 ivory 도자기·먹색·절제된 jade를 탐색하는 **root 제안**이다. 보컬로이드 특정 캐릭터/IP가 필수거나 사용자가 두 이름을 최종 선택했다는 뜻은 아니다.

바꾸는 것은 전체 재질·장식·폰트/막대·panel 스타일이며 좌표·button rows·세 chat·아래 사각 map·health 위치·입력 의미는 고정 geometry를 소비한다. 모든 그림은 제안 목업으로 표시한다. 역사 그림을 새로 만든 것처럼 쓰거나 실제 게임 캡처/상태를 꾸미지 않는다. 장식이 label·click 영역을 가리지 않게 하고 한글/단축키·combat 의미색의 읽기를 검증한다. 최종 Step17에서 baseline과 두 변형의4K 전체/원배율 하단·비교 화면을 채팅에 제시하고 사용자 선택 전 기본 테마를 대체하지 않는다. 미래 선택된 공격대/미터 skin도 해당 선택 테마를 따라가되 기능 의미·사용자 배치를 유지한다.

질감 품질은 후속 지정 판독자가 보존 자산의 실제 크기와4K 목표에서의 필요한 부품 품질을 관찰해 판단한다. 거친 확대·흐림·alpha halo·이음새·텍스트/상태 의미의 방해가 확인될 때만 개선한다. 검은 구획·얇은 접합·끝 장식의 silhouette/성격을 유지하고 새 재질을 별도 이름·원천/작업 provenance로 보존한다. source ZIP/자산·현재 고정Step5 파일은 덮어쓰지 않는다. 원형 충실본/개선 제안본/다른 테마를 각각 표시해 역사 자료와 새 창작을 구별한다.

미래 raster artwork의 새 제작/수정에는 제공된 ImageGen을 해당 조건에 맞게 쓰고, edit는 실제 참조 이미지를 지정 판독한 뒤 연결한다. code-native 도형·좌표·compositing과 결정적 미리보기 렌더는 제작 renderer가 맡는다. 이 계획 작성 중 이미지 생성/편집·도구 설치는 하지 않는다. 개선 질감이 시끄러운 panel·흐린 글자·경계 halo를 만들면 채택하지 않고 원형 충실본을 유지한다. R52는 추가 대안 컨셉이나 기본 테마 자동 변경이 아니다.

### 과거15개와 주술사 범위의 현재 해석

원래15개는 참고 목록이다. Details!는 R45 이후 선택 데미지 provider 후보 범주에 들어가지만 과거 앱판 metadata를 현재 Forever 지원으로 쓰지 않는다. OmniCC·OmniCD·WeakAuras는 통합 전투보조가 맡는 상태/CD를 중복시키는 기본 설치 대상이 아니다. Party cooldown 등 별도 미요청 기능을 채우려고 자동 추가하지 않는다. 경매/우편/수집 도구도 현재 범위 밖이다.

고양/정기는 실제 학습 주문/rank·mana/proc·cooldown·토템 상태를 같은 전투보조 담당으로 대조한다. 복원은 native 또는 선택한 한 raid frame의 health/mana·debuff·수동 대상 조작을 우선하며 Hekili의 치유 추천 지원을 확인한 것으로 쓰지 않는다. 선택 추천을 꺼도 필요한 상태/CD 표시가 독립적으로 유효한지 검증한다. 요구를 못 채운 제품에 또 EventAlert/CD AddOn을 겹쳐 붙이기보다 단일 제품 후보를 다시 판정한다. 실제 유일한 선택이 막히면 gap을 사용자에게 정확히 제시하며 미래 허용 범위를 넘겨 자체 엔진을 만들지 않는다.

### 이미 승인된 macro 원본 라이브러리

최종 승인 범위는 `D:\Projects\Project_WF\MacroLibrary\` 안의 private 라이브러리다. 보존본은 `MacroLibrary/archive-egl0lld0/`에 만들어졌다는 helper 완료 반환을 master가 전달했다. 원본4파일을 계정 공용1·캐릭터3 scope로 나눠 byte 그대로 보관하고 private manifest와 INDEX를 만들었다. source/archive SHA256 4/4·총6487bytes·9+11+16+8=44개, strict UTF-8 4/4·이름/원문행/literal 명령 대조44/44·빈본문1개 보존·Git 제외 확인은 helper의 실제 기계검증 반환값이며 이 A의 raw 재검사가 아니다. INDEX는 원본이름·scope·원문참조번호·실제 조건문에서 기계확인한 검색키만 담는 찾기 보조이며 raw 원형이 원본이다. typo·빈본문·이름·조건·명령순서·ID·인코딩을 보존한다. source 삭제·변환·병합·Forever 파일 복사·적용사본·키 배정·새 macro 저작은 하지 않았다. raw·실계정 경로·식별자·macro 이름은 library 내부에만 두고 Git/외부 자료로 보내지 않는다. master가 원문 대조·통합 확인을 맡고 이 A는 raw를 받지 않는다. 나중에 사용자가 필요한 원형을 요청하면 그때 해당 원문을 꺼낸다. 현재 게임 적용·호환성 시험은 미수행이다.

## Phase N — 복원·구성·검증

아래 미래 상세계획은 경로 예약이며 지금 만들지 않는다. 실제 Step1–5 번호·기록·최초 예상은 보존한다. Step5는 설계 인계까지의 실제 상태와 사용자가 뒤로 미룬 렌더/P4를 분리해 기록한다.

| Phase | 상세계획 파일 | 현재 Step | 상태 |
|---|---|---|---|
|1.1 원본·외형 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.1-세부계획.md` |1–2 |역사분석 완료/철회동결 |
|1.3 원형·채팅·설계 인계 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.3-세부계획.md` |3–5 |3/4수용,5설계반환; 렌더/P4/전달은17로 USER_DEFERRED |
|1.2 요구·비교 |`Codex/plans/2026-11-17-devil-ui-forever-phase1.2-세부계획.md` |6–7 |root 계획게이트 뒤 |
|2.1 필수 기능 기반 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.1-세부계획.md` |8–9 |미착수 |
|2.2 필수 설정·편집 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.2-세부계획.md` |10–11 |미착수 |
|2.3 독립 선택 기능 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.3-세부계획.md` |12–13 |미착수 |
|2.4 스타일·자산·테마 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.4-세부계획.md` |14 |미착수,최종목업 전 기능구현/스타일 작업 |
|2.5 가능한 검증·수정 |`Codex/plans/2026-11-17-devil-ui-forever-phase2.5-세부계획.md` |15–16 |모든 가능한 기능/통합검사와 해당수정 먼저 |
|3.1 최종 목업·offline 인계 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.1-세부계획.md` |17–18 |17이 Step5 미수행렌더/P4 수신,앞선가능작업닫힘이선행조건 |
|3.2 실제게임 확인 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.2-세부계획.md` |19–20 |접속가능/실제적용 승인 뒤,현재 NOT_RUN |
|3.3 실제게임 수정·고정 |`Codex/plans/2026-11-17-devil-ui-forever-phase3.3-세부계획.md` |21–22 |실제게임결과에만 의존,현재미착수 |

R44 수정 전 불변 baseline의 미착수 역할 연결: 옛6 환경/백업은 새6의 가능한 목록·R13준비/안정된읽기참고와 새19의 실제환경/적용전재확인·백업으로 분리,7→7 기능비교,8→8 bar/map,9→9 health/cast/nativechat,옛10/11 주술사 상태·알림/추천은 새12의 한 전투보조로 통합,12→19 입력/저장,13→20 전투/지도,14→21 수정,15→22 실제고정. 새10/11 관리·13 선택제품·14스타일/테마·15/16 offline검증/수정·17/18 최종목업/offline인계를 추가/명시한다. 옛 번호의 일대일 치환이 아니며 역사 timestamp는 원문 그대로다.

**Step5 이월·Phase 종료 계약(root 담당):** root가 원래 Step5 설계/자산/30개G5 설계검사와 DESIGN_READY.json의 기존 해시를 보존하고, Step5 이력·현재detail·Phase1.3 Result의 새 addendum(md/json)에 `DESIGN_HANDOFF; VISUAL_USER_DEFERRED_TO_STEP17`를 기록한다. 기존 설계를 새로 수용된 render/P4로 표시하지 않는다. Phase1.3의 연구/설계 인계 범위를 닫을 수 있는 조건은 설계 파일/한계·사용자 R55 원문·이월목록·수신 Step17/Phase3.1 gate가 모두 연결된 기록이다. 미완 렌더를 완료 처리하지 않고 이 조건에 따라 분리 이관해야 다음 기능 Phase가 열린다. Step17은 보존 geometry/assets+구현 후 실제 스타일/선택기능 상태를 입력받아 baseline/조건부 개선/두테마 전체·하단·상세·비교를 렌더→픽셀/역할 대조→지정 판독→같은 B P4→채팅 전달로 닫는다. 그 전에는 visual acceptance 미완이다. 이번 A1은 이 root 전용 기록을 수정하지 않는다.

## Implementation Interfaces

실제 자체 게임 코드·설정은 미구현이다. 표는 미래 입출력 계약이며 현재 구현됐다는 주장이 아니다.

| 연결 | 입력 → 출력 | 범위·lifecycle 계약 |
|---|---|---|
| 원형→고정 baseline |45sample4·수용근거→보존Step5명세→최종Step17실제목업 |원본/제안/실제값 구분,2022목표 재사용 없음 |
| baseline→테마 제안 |보존된 고정 geometry·별도style/assets→Step14테마구성→Step17전체/하단/비교 |행·구획/3chat/지도/health 위치 동일; label·hit 영역 보존; 원본 충실/개선/대안 구별 |
| 질감 평가→조건부 개선 |지정 판독자의 실제4K 품질 근거→별도 새 자산·원형 대비 |기존source/고정Step5 보존,ImageGen적용조건·sourceprovenance·alpha/질감/글자 gate |
| 비교표→재사용 결정 |동등 feature/runtime/유지보수 비교→전체/모듈/부분/자체/하이브리드 |더 나은 자체 유지,미구현을 우열 완료로 쓰지 않음; 실제 부족·외부 개선 근거 기록 |
| V42부분→자체 연결 |필요 helper/설정·loader/API/호출체인→좁은 adapter |namespace·load/event/combat/save/disable·caller/callee 일치. installer/filterreset/uiScale/fraction 이식 제외 |
| baseline manifest→providers |정확판·폴더/TOC·의존·저장namespace→필수 묶음 |제품 코드 합침/권리 변경 아님; 미확정dependency 자동 추가 없음 |
| 선택 AddOn→core |게임 AddOn 목록·실제필수 dependency→선택된 기능만 로드 |필요 reload 완료 뒤 disabled제품/adapter 미로드·등록 event/timer 없음,core 단독 정상 |
| 외부제품→스타일 adapter |지원 profile/skin API·frame lifecycle·선택테마→외형 |데이터/조작 owner는 제품,adapter는 허용 style만; provider 부재/중지 시 스타일 작업0 |
| provider update→style/profile |원천/adapter 고정판·이전snapshot→검증된 새 조합 |skin silent소거·설정reset·자체강제교체 없음. 미지원 조합은 style 적용 보류/한계 표시 |
| 자체관리→설정 저장 |default+user edits+schema/version→ownprofiles/snapshot/copy |macro/키/창필터를 무단 저장/대체하지 않음;외부 지원범위만 명시 |
| scoped restore→담당 |ownsnapshot+provider판본/유무→해당 설정 복원 |없는 선택 기능entry 보존/적용 생략;다른 설정 불변;미지원schema silentreset 없음 |
| 편집기→담당 |move/size/font/color/rows/gaps 초안→확인/적용/취소/저장 |지원값만,전투protected변경 유예,사용자값 reload/relogin 유지 |
| bar→입력 |실제slot/bind→같은 실행·label/page |빈값 그대로,키 자동배정 없음,토템 입력 한 담당 |
| 채팅→외관 |기본수신/송신/창별filter/input→세패널의 외형 |과거ID/채널reset 없음,한글 조합 입력/focus/history/키편집 현재runtime 별도 확인 |
| combat→표시 |실제spec·주문/rank·상태/proc/CD→한 전투보조 |선택 추천은 같은 제품 내 옵션,치유 지원/미학습 상태를 추정하지 않음 |
| raid/meter→스타일 |실제기능값/역할·선택테마→가독성 있는표시 |경보/역할 의미·mouse/click-cast/combat 보존,미터는3chat밖 |
| Retail참고(R13)→선택 |Step6준비확인/안정된비매크로설정 읽기→뜻/채택기록;Step19적용전재확인 |원본읽기전용·macro제외,게임/profile/키 자동이식 없음;미준비자료만보류·offline작업계속 |
| macro→private library |보존원본4파일/44개→찾기색인 |이미별도승인;이번재검사/가공/게임복사 없음 |
| 실제검증→고정판 |통과버전/선택profile/style→복원/인계 |미검증범위·업데이트경계·사용자수정방법 명시 |

## Test Plan

### 현재 계획 후보 검수

| 대상 | 갈래 | 고정5 | 고정③ | 가변5 |
|---|---|---|---|---|
|R44–R59 계획·59요청 대응표 |비코드③ |P5 구조·형식/사실·참조/연계/정의·완결성/요청 뜻·범위 |수정 연계:원요구→현행규칙→단계/담당→인터페이스/시험·역사호환 |①독립선택AddOn과단일combat역할 ②필수저장/복원/편집·default/user값 ③R48비교·전체/부분/lifecycle·V42근거(적대) ④raid/meter하이브리드style·업데이트/조작 ⑤R55–59기능우선/최종목업·59요청/이월종료·offline와live승인경계(R46/51/52포함) |

같은 Phase1.3 B가10관점·10라운드로 검수하며 이 A가 확인된 수정에 돌아온다. 현재 기계 gate는11절·번호/범위·예상 합계·원문/동결 보존·요구 연결이다. 문장 의미 자체는 전문 자체확인과 B가 대조한다. 기계 검색만으로 검수 완료라 하지 않는다.

### 현재 Step5와 미래 시각 제안

| 대상 | 갈래 | 고정5 | 고정③ | 가변5 |
|---|---|---|---|---|
|Step17의 Step5이월 baseline 렌더 |비코드③/P4 |실제렌더/토큰·타이포·간격·대비/연결/완결성/4K읽기 |신규 연결:45실제sample4·원형→고정spec→실제PNG |원래3chat·thin seam·하단사각map;버튼부터적층;키/글자·중앙시야;source/제안/runtime혼동(적대);보호범위 |
|Step14스타일/자산→Step17최종질감/테마목업 |비코드③/P4 |실제생성·렌더/색·타이포·alpha·대비/geometry-style-자산연결/전체·하단·비교완결성/4K읽기 |신규 연결:보존Step5설계geometry→별도improved/theme→Step17채팅목업 |①동일구획/행/3chat/map/health ②장식·폰트·막대·재질의일관성/조건부개선 ③4K질감·alpha/halo·koKR/키/상태읽기 ④원형/창작·실제게임·사용자선택혼동(적대) ⑤선택provider테마·업데이트/조작경계 |

Step15–16의 가능한 기능검증/수정 종료가 먼저다. Step17에서 실제 renderer 실행·픽셀/geometry동일성·label/border/alpha 검사→지정 판독자의 원형/자산/실제목업 대조→해당 같은 B P4 순서다. 최종 baseline4K 전체·원배율 하단/키상세,두 대안 전체/하단·비교,조건부 개선 시 원형/개선 비교를 이 채팅에 제시한다. 대안 선택이나 게임지원 PASS를 미리 적지 않는다. 현재 Step5 산출물은 수정하지 않으며 별도 버전으로 만든다.

### 미래 기능 코드의 검증 관점

| 대상 | 갈래 | 고정5 | 고정③ | 가변5 |
|---|---|---|---|---|
|Step8–14 자체 AddOn·필수관리·스타일 adapter |코드③,실제구동/계약검사 먼저·뒤에3라운드 |P1 문법/상태마커/구획연결/문서화/인터페이스 |신규 구획연결; 실제 기존소스 수정이 생기면 root가 영향지도로 연계까지 포함해 재판정 |독립선택/로드수명;scope저장/편집/버전;native입력/필터/키보존;단일combat/외부style의기능경계;외부우열/미독core/실게임PASS과장반증(적대) |

검증은 실제 작성한 코드와 이를 사용하는 가능한 실행 흐름으로 먼저 확인한다. root가 가용성을 확인한 기존 Lupa Lua5.1을 own-code 계약/harness 검사에 사용할 수 있으며 별도 설치를 전제하지 않는다. offline에서 검증할 수 없는 현재게임 API/입력/보안동작은 실패를 숨기거나 stub 성공으로 바꾸지 않고 Step19–20 미검증으로 분리한다. 이 표는 future code의 기본 검증이며 실제 source/code 생산을 지금 시작하는 권한이 아니다.

### 기능 작업 완료 뒤 최종 목업으로 넘기는 gate

Step15는 모듈 로드/의존/이벤트 수명, 실제 자체 설정의 snapshot→편집→저장→범위복원 흐름, 미설치/disabled provider, schema/version, 필터/키를 보존하는 입출력, 외부 스타일 adapter 적용/해제·지원판 변화 등 현재 가능한 검사를 실제 구현 대상으로 수행한다. stub/harness 검사는 그 계약만 검증하며 게임 API·실제 채팅도착·전투/taint의 PASS를 만들지 않는다. 실제 제품 소스 연결·로드체인과 같은 실제 흐름 꼴을 시험하고 fixture/가짜고정값만으로 제품 동작을 확정하지 않는다. Step16에서 발견과 연계만 고친다. 필요한 기능이 남았는데 목업을 먼저 생성하지 않는다. live-only 미검증은 해당 원인·다음 Step19/20을 적고 분리한다. root의 제작/검수 수용 및59요청별 가능한 작업 완료/미선택/명시적live이월이 Step17 입력 gate다.

### 미래 구현·실제 게임 gate

아래 전부 예정/NOT_RUN이다. offline 제작/검사는 저장 계획의 root 게이트 뒤 수행하며, 실제게임 항목은 접속가능·게임적용 승인 전 실행하지 않는다. 코드 구조 변경은 실제 구동과 해당 실행 흐름 확인이 먼저이며 그 뒤 연계·뜻·적대3라운드, 비코드구조는 정한10관점을 적용한다. 통과한 무관한 원천/압축/앞단 시험은 반복하지 않는다.

| gate | 실제 확인할 것 | 성공/실패 경계 |
|---|---|---|
|G1 대상·보존 |실제client/목록·완전종료·현재범위백업/복원 |개인raw 비공개,없는값은없음,게임적용전복원가능 |
|G1-R13 |Step6읽기준비/저장안정 판정 뒤 필요한 비매크로설정;Step19적용전재확인 |원본읽기전용·뜻만참고;미준비부분/사유/재확인조건만보류,게임접근불가와동일시0 |
|G2 파일·담당 |Step7정확Forever파일·TOC·dependency·저장명·role |한영역한owner;버전선언≠동작;신규필수의존자동추가없음 |
|G-reuse |실제자체/외부 동일요구·input/save/combat·유지보수 비교 |동등/우수자체유지,미구현은미구현;whole/partial/하이브리드·callchain근거 |
|G3 화면 |실제resolution/UIscale·button-first하단/3chat·style |전체ratio환산0,thin seam/사각지도·중앙시야,미터침범0 |
|G4 입력·page |모든채워진slot/bind/label/page·토템/stance/pet/vehicle |의도치않은키변경0;실제불가/미학습 별도 |
|G-chat |창별group/channel전후·분류도착·Enter/slash/Escape/한글 조합 입력/focus/history |native역할3보존,탭/hover/알림/복귀 접근,원형filter이식0 |
|G-save |own snapshot/copy/defaultreset/선택범위restore·지원외부adapter |이전사용자값복구,다른namespace불변,없는선택모듈reset0,unknownschema보존 |
|G-edit |move/resize/font/color/row/gap·초안/취소/적용 |지원값만·금지combat유예·사용자값 reload/relogin유지 |
|G-optional-off |core단독/각선택모듈on-off/부재/필수reload후 상태 |disabled선택TOC/adapter미로드·owned event/timer작업0·core 정상 |
|G5 상태·시전 |native와health/mana/target/aura/시전·취소·차단 비교 |오표시/멈춤/중복0,비전투만으로전투PASS아님 |
|G6 저장수명 |reload/relogin·profilecopy/reset/모듈유무변화 |분류/편집·위치/skin유지,전역uiScale/profile자동reset0 |
|G7 전투 |실제수동전투진입/종료·EditMode/임시창·보안오류 |protected/taint우회0,전투편집강행0 |
|G8 combat-role |같은제품state/proc/CD·토템상태·선택추천off/on |한combat표시담당,추천off에도검증된필요상태,복원healing추정0 |
|G9 raid/meter/style |nativebaseline/선택raid·debuff/경보/역할/수동대상·값/정렬 |mouse/clickcasting·위험의미보존,미터는3chat밖,style와기능 별도확인 |
|G10 map |click/zoom/ping/tracking/button/tooltip·필요시Questie |panel/장식입력차단0;미설치연계는해당없음 |
|G-update |선택provider/update/adapter판본·frame재생성·skin/사용자값 |style소거/강제교체/silentreset0;미지원style만보류·core안전 |
|G11 rollback |변경부분snapshot으로되돌림·다른profile영향 |원천/private무변경,실패부분복원·미해소중대/중간완료처리0 |
|G12 고정 |파일/role/provider/style/profile/schema·검증목록 |실제통과만고정,미시험spec/레벨/raid/vehicle별도 |

선택제품이 없는 경우 core-only를 실제 확인한다. 선택 기능/스킨은 실제 선택된 조합만 시험하고 미선택 제품까지 검증했다고 하지 않는다. 사용자 출근 중에도 가능한 offline 기능 제작·검증/수정을 끝내고 최종 목업을 마지막에 제공한다. 실제게임 gate는 NOT_RUN으로 남기며 offline 결과를 게임 PASS로 확대하지 않는다.

## Assumptions

| 전제 | 상태·확인 방법 |
|---|---|
|원형 |45실제sample4/3chat/11218meter제외 확정. samplebuild/asset동일성 미검증,2022철회 유지 |
|현재 own구현 |게임애드온 미구현. 설계·source독해와 실제우열/이식성공 구분 |
|V42 재사용 |네이티브창/배치저장·compat/helper의 정적 근거 있음. 전체bundle/모든profile/PitBull/Leatrixcore지원은 미확정 |
|4K·UIscale |사용자4K 확정,현재클라이언트raster/UIscale실측 없음. Step5제안과실측구분 |
|관리기능 |저장/복원·사용자편집 필수 요구 확정,실제구현·provideradapter는 미래 |
|외부기능 |기존전투/데미지/어그로 활용 허용,제품/판본/확정선택 미정;raid는nativebaseline |
|외부style |R50수정의향·미적판단위임 확정,모든provider의skinnability/update호환 미검증 |
|테마 |R51한두안요청에root두컨셉제안. 기본은Devil,사용자최종선택/대안완성 아님 |
|원형질감 |R52조건부개선 허용,실제4K미달판독 전 전부불량/교체판정 없음 |
|게임접근 |R46출근중직접확인불가. offline전달과실제게임gate 분리 |
|이전profile/keybind |존재/이전가정 없음. 현재값 있으면 보존,자동배정없음 |
|Retail참고 |R13요청유지,Step6안정된자료 먼저읽기전용;미준비부분만보류/19재확인;private공개/키/macro이식없음 |
|macro |private44원본보관별도완료반환,이A raw미독;게임복사/호환시험취소 |
|권리·의존 |확인한source조건만기록. 외부전체사용≠소스이식허가,새필수의존미선택 |
|구성·시간 |최소기능·지원설정/작은adapter추정. 직접fork/큰gap발견시그범위재추정,추측완료일없음 |

## Correction History

| 날짜 | 반영 | 근거 |
|---|---|---|
| 2026-11-17 | 최초 초안: 원본 역할·단일 owner·후보 gate, 15개 일괄 적용 제외 | R1~R7·S1~S10 |
| 2026-11-17 | 관찰 종료·정리 가능성·새 환경 | R8~R10 |
| 2026-11-17 | 최종 D: 프로젝트, C: 기록 보존 | R11·R12·PROJECT_LOCATION addendum |
| 2026-11-17 | 최신 선택으로 원본44개 private 라이브러리·검색색인에 한정, 이전 이동/게임 적용 취소 | 최신 사용자 원문·master source4파일 실측 보고 |
| 2026-11-17 | 1차 검수 중간2건 정정: 현재 R17 범위 addendum, R13 비매크로 참고의 준비·입력·계약·gate 연결, 색인·실제 검수 기록 반영. 수정 재검증 대기 | audit_log·TRIAGE_phasePlanning |
|2026-11-18 |R44–R59 계획 후보:필수 관리/독립선택/단일combat·실제비교·whole/partial/hybrid·외부style·기능우선·후속테마/조건부질감·최종목업·59요청추적 |개별사용자원문/현재요청대장·본발주;A1계획판단 |

현재 별도 계획 이력 파일은 실제 존재하지 않았다. 아래는 R44 수정 전 불변 baseline의 당시 기록을 보존한 것이며 지금 상태는 본문이 우선한다. root가 Phase 종료 기록을 관리한다.



### 이전 추정과 과거 검수 안내 — 역사 보존

다음은 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:37`의 당시 추정이며 현재 미래비용과 다르다.

R25 기준 재설정 후 미착수 경로 Step3~15의 합계는 675~1230분, 약 11.25~20.5시간이다. 이는 옛 원형 전수조사·채팅 해결법·새 배치와 미래 구현을 모두 포함한 추정이며, 현재 원형·채팅 조사는 Step3~4이며, R20의 오프라인 배치 설계 목표는 새 원형을 확인한 뒤 Step5로 이어간다. 게임 코드·설치·설정은 이 승인에 포함하지 않는다. 동결된 2022기준 작업시간은 별도 역사 기록이다. 원본 회수 난항·사용자의 게임 접속 대기시간은 별도다. 소형 custom unit frame이 필요하면 추가 4~8시간을 예상하며 범위·비용을 구체화해 결정한다. 이 시간은 완료 약속이 아니다. 관찰 종료·기존 AddOns 정리 가능성·새 환경·최종 D: 경로는 현재 전제와 Phase 1.2에 반영했다. macro는 별도 승인된 원본 라이브러리로 보관하며 UI 구성·게임 적용과 분리한다.

원래Step2/최초계획 검수의 당시 상태는 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:253–260`에 보존돼 있고 현재Step5목표/P4를대신하지 않는다. 실제Step3/4수용과Step5설계상태는현행본문에반영했다.

### timestamp 추가 원문 — 당시 결정만 보존

아래는 불변 보존 baseline `Codex/results/handoffs/old-reference/r44-plan-update/baseline-master-plan-before-R44.md:338–370`의 내용 그대로다. 옛Step번호/당시미승인/원형가정은 역사이며 R44–R59 현재본문·Step6–22를대체하지 않는다.

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

이미 정한3chat/4K하단적층·설정/편집 필수·독립선택AddOn·단일combat역할·전체/부분 비교·외부style·다른테마/조건부질감 제안은 다시 묻지 않는다. 최신 요청은 가능한 기능 추가·개선이 먼저이고 최종 목업은 마지막이다. 현재 A1은 계획·59요청 대응표만 반환하며, root가 저장계획의 검수·피드백/갱신·명시 GO를 처리한 뒤 offline 기능 제작을 발주한다. 실제 게임 파일 설치·설정·입력은 별도 승인/접속 가능 때다. R46 출근 상태를 게임 원격 조작 허가로 해석하지 않는다.

아직 미정인 것은 실제 주술사spec/레벨·콘텐츠,검증을 통과한combat/raid/meter provider와선택on/off,추천량,두대안/개선Devil중최종테마다. 미정은 현재baseline·계획/오프라인제안을 막지 않는다. 이미 준reference의미적취향은 재질의하지 않는다. 새 테마는 기본Devil을자동대체하지 않으며 필요한 제품/기능 선택은 구체적 비교결과를 갖춘 뒤 정한다.

### 멈출 일 미리 점검

| 항목 | 현재·미래 기본 대책 |
|---|---|
|새의존/설치 |현재설치0. 미래Step7정확provider/필수dependency를근거로선택;외형묶음만으로추가권한이생기지않음 |
|네트워크/외부호출 |현재추가수집0. 미래정확공식공개source/필요재사용범위만,계정/쿠키우회·raw업로드·유료확장없음 |
|이미지제작 |현재생성0. 미래Step14질감/테마 작업과 Step17최종목업은원형별도보존·제공ImageGen적용조건·renderer기하합성·판독gate,기존Step5덮어쓰기없음 |
|파괴/덮어쓰기 |원본ZIP/source/기존결과/private보존. 미래게임종료·현재범위백업→사본/profile,직접합류는허용범위먼저,정리삭제없음 |
|권한 |D현재후보쓰기실제권한검토;게임/시스템/새외부권한은그시점범위별확인,관리자/보안변경당연시없음 |
|세션/검수 |현재동일A→동일B순차. 새미래Phase는발주범위/입력/같은Phase왕복규율,독립병렬승인없음 |
|FAIL/지원gap |실패한기능/style만적용보류/해당snapshot복원;중대/중간수정후해당연계만재확인,무관한통과시험반복없음 |
|외부style/update |지원설정→skin/작은adapter;직접fork필요시실제연결/사용조건/업데이트유지보수범위재평가,기본외형무조건고정/강제교체없음 |
|기존문제/비교 |원래결함·미구현·새도입결함구분. 더나은자체유지,근거없는외부우월판정·전부자체제작확대없음 |
|push/게시 |공유트리Git/root전용. 공개배포/외부upload/merge현재승인없음,원천/폰트권리추정없음 |
|실측불가 |가능한 offline기능/통합검사 먼저,목업은마지막17; livegate NOT_RUN 유지. 실제접근가능시해당검증,성능/compat보장없음 |
|모델미가용 |지정역할임의대체없음. 실제한계·파일·상태반환,이미읽기/반환기록보존 |

지침 예외를 요청하지 않는다. 현재 후보의 수용·root 통합은 미래 게임 실행 완료나 추가 권한이 아니다. Step5 미수행렌더/P4는 R55에 따라 Step17로 이월하며 root가 Phase1.3 인계범위/Result addendum을 연결한다. 기능 제작 전 실제 계획 게이트를 생략하거나 사용자에게 같은 미적 선택을 다시 묻지 않으며, 이 A는 계획 후보 반환 뒤 멈춘다.

# Devil UI Black 하단집중형 — WoW Forever 복원 계획

초안 · 2026-11-17 · 프로젝트 `D:\Projects\Project_WF`

UI(User Interface, 게임의 조작·정보 화면) 복원은 조사·계획 단계다. 설치·코드·설정 적용은 아직 승인되지 않았다. 별도 후속으로 사용자가 명시 요청한 **자작 macro 원본 보관·private 라이브러리 관리**는 승인된 작업이다. 게임 파일 복사·적용과 호환 변환은 취소됐다. 두 승인 범위를 섞지 않는다.

간략 목차 — 챕터 → Phase → 주요 Step (UI 실행 승인 뒤 작업시간 추정)

```text
1. 원형·적용 기준 확보
   Phase 1.1 원본 확보·외형 추출
     Step 1 공개 원본·profile 구성 확인       45~90분
     Step 2 첫 이미지 배치·style 기록         45~90분
   Phase 1.2 실행 준비·후보 선택
     Step 3 새 환경·현재 상태·백업 확인        30~45분
     Step 4 파일·의존·단일 provider 선택       45~60분
2. 하단 UI 구성
   Phase 2.1 핵심 prototype
     Step 5 행동단축바·미니맵 배치             60~120분
     Step 6 체력·마나·시전바·블랙 외형         120~180분
   Phase 2.2 주술사 정보
     Step 7 토템·자원·특성별 정보              45~90분
     Step 8 선택한 효과 알림·추천              60~90분
3. 실제 게임 검증·인계
   Phase 3.1 게임에서 검증
     Step 9 재접속·profile·기본 조작           45~90분
     Step 10 전투·주술사·지도 연계             60~120분
   Phase 3.2 정정·고정
     Step 11 발견 정정·해당 연계 재검증        45~90분
     Step 12 버전·복원 자료·인계               30~45분
```

기본 경로 630~1110분, 즉 약 10.5~18.5시간(아래 12개 Step 범위 합계). 원본 회수 난항·사용자의 게임 접속 대기시간은 별도다. 소형 custom unit frame이 필요하면 추가 4~8시간을 예상하며 범위·비용을 구체화해 결정한다. 이 시간은 완료 약속이 아니다. 관찰 종료·기존 AddOns 정리 가능성·새 환경·최종 D: 경로는 현재 전제와 Phase 1.2에 반영했다. macro는 별도 승인된 원본 라이브러리로 보관하며 UI 구성·게임 적용과 분리한다.

## Summary

사용자가 확정한 [2022 Devil UI Black FanFix 게시글 첫 스크린샷](https://www.inven.co.kr/board/wow/1636/31588)의 **블랙 하단집중형 외형과 행동단축바·단축키 표시·체력/마나·미니맵**을 복원한다. 기존 CurseForge 15개는 불만족했던 참고 조합이며 전체 설치 대상이 아니다.

추천 구조는 원래 역할의 **Dominos + SexyMap + Quartz**, 별도 선택할 체력·마나 frame, 부족한 블랙 장식만 맡는 작은 연결 코드다. PitBull은 Forever 지원 근거를 찾지 못해 확정하지 않는다. Forever Unit Frames를 우선 검토하되 외형·전투 gate를 통과할 때만 선택한다. ElvUI 전환은 기본안이 아니다.

주술사 토템·mana·시전 정보를 먼저 확보한다. 사용자가 기억하는 Hekili의 효과 알림과 행동 추천을 함께 평가하되, Hekili Forever의 독립 주술사 후기는 충분히 찾지 못했다. 고양·정기 지원은 제작자 선언이며 복원 치유 추천 지원은 확인하지 못했다. 실제 게임 시험과 원본 외형 비교 전에는 어떤 후보도 최종 작동 보장으로 쓰지 않는다.

## Current Ground Truth

### 실제 관찰·제약

| 구분 | 확인한 내용 | 한계·적용 |
|---|---|---|
| client | `_forever_\Wow.exe`, file/product version `1.60.1.70938` | 관찰 시점 사실, 실행 직전 재확인 |
| 화면 | 캡처 2560×1440, locale koKR | 임시 기준. 실제 render resolution·UI scale 미확인 |
| CurseForge | 15개 과거 프로젝트, 9개 Update·6개 Recently Updated | 앱 label은 현재 지원·작동·개발 중단의 증거가 아님 |
| 정리 가능성 | 사용자가 AddOns를 직접 정리할 의사 표시 | 삭제 완료 미확인. 과거 목록을 현재 설치 상태로 가정하지 않음 |
| 새 환경 | 사용자: “지금은 와우 포에버라 전혀 아무것도 없는데?” | 옛 macro·keybind·profile이 이전됐다고 가정하지 않음 |
| macro 후속 | 최종 요청은 원본 보관·도서관 관리. master 전달의 helper 완료 반환: 원본4파일·44개·6487bytes, scope별9/11/16/8개, SHA256 4/4 동일·private manifest/INDEX 생성·Git 제외 확인 | 이 A는 raw 미독. 원본 라이브러리 보관 완료 반환을 반영했으며 게임 복사·병합·적용·호환성 시험은 수행하지 않음 |
| 원본 | 2022 게시글은 Dominos·PitBull·Quartz·SexyMap·ChocolateBar_FanFix 조합 | 첫 이미지 정밀 판독·좌표·texture·font 추출 미수행 |
| archive | 공개 Drive의 Fonts.zip·Interface.zip metadata 확인, Interface raw fetch 성공을 master가 기록 | 로컬 실물 분석·profile 회수·자산 사용 조건 확인 미완 |
| 실제 게임 | 설치·설정·전투 시험 없음, 관찰 종료 | 모든 runtime gate는 예정. 지금 게임 입력하지 않음 |
| 프로젝트 | 최종 `D:\Projects\Project_WF`; 앞선 C: 기록 보존 | 계획-only 새 commit 없음. push·merge·외부 게시 없음 |

### 원문·관찰 위치

- 사용자 요구: `Codex/results/REQUEST_LEDGER.md`와 최신 master 전달. 첫 이미지 확정, 15개 참고, 주술사, 새 환경, D: 경로와 최종 macro 원본 라이브러리 범위를 구분한다.
- 관찰: `Codex/docs/observed-environment.md` 1~29행. 과거 파일명·앱 제공판: `Codex/docs/addon-reference-inventory.md` 1~31행.
- 외부 근거: `Codex/docs/shaman-source-evidence.md` S1~S10·U1~U6. 실제 URL·작성자/유형·기간·짧은 원문·한계를 담는다.
- 원본: [공개 Drive 폴더](https://drive.google.com/drive/folders/1QMZiceFpizZ5dHxTkG2UemZAYKaQFdg7). ZIP 내용을 분석했다고 취급하지 않는다.
- 경로: `Codex/docs/PROJECT_LOCATION.md` 마지막 addendum, `Codex/docs/INDEX.md`. 기존 원본·기록을 지우지 않고 이어 왔다.

확정은 관찰·페이지 표기·사용자 결정 확인, 근거 미발견은 조사했으나 못 찾은 내용, 추정은 설계 가설, 미검증은 확인하지 않은 항목이다. 배포 선언과 개인 후기는 이 PC runtime PASS가 아니다.

### 늘 지킬 제약

| 명령 | 처리 갈래 | 근거·적용 |
|---|---|---|
| 블랙 하단집중형 복원 | 작업 한정 | R1·R2: “응 맞아 딱 저모양이었어”; 확정한 참조 재질문 없음 |
| 기존 조합은 참고 | 작업 한정 | R4: “참고만해”; 전체 적용 금지 |
| Hekili 경험·주술사 후기 | 작업 한정 | R6·R7: 효과 알림+추천, 토템·mana·치유 요구 반영 |
| UI는 조사·계획 | 작업 한정 | R3와 대장 경계; 별도 실행 GO 전 설치·코드·설정 적용 없음 |
| 새 환경·D: 경로 | 작업 한정 | R10·R12, 옛 설정 존재 가정 없음 |
| 자작 macro 원본 라이브러리 | 작업 한정 | 최신 사용자: “그냥 원본만 보관하고 도서관처럼 관리해줘. 나중에 필요한거 꺼내달라고할게.”; 44개 원문·scope 보존, 검색색인만 추가. 게임 적용·변환 취소 |

### 구조 맵

| 경로 | 역할·상태 |
|---|---|
| `Codex/plans/2026-11-17-devil-ui-forever-plan.md` | 현재 초안 |
| `Codex/plans/2026-11-17-devil-ui-forever-phase<ID>-세부계획.md` | 각 Phase 착수 때 작성할 미래 파일 |
| `Codex/docs/` | 관찰·참고표·후기 근거·프로젝트 위치·INDEX |
| `Codex/results/` | 요청·발주·작업·검수·향후 실행 기록 |
| `outputs/` | 검수 후 전달본 자리 |
| `work/` · `MacroLibrary/` | work는 임시 자료, MacroLibrary는 ignored private 원본4파일·manifest·44개 검색색인. 개인 raw는 Git 추적·외부 전송 안 함 |

지정 입력을 전문 확인했고 기존 마스터플랜·판 이력·Next Step 실행 기록은 없었다. UI 실행 Step은 1에서 시작한다. 사용자용 계획은 한글, 이후 내부 실행 기록은 addon·파일·API 식별자를 다루므로 영어로 고정한다. 원본 추출은 아직 미완이다.

## Phase Range

| 챕터·Phase | 목표·선행 조건 | 다음 단계의 입력 |
|---|---|---|
| 1·1.1 | 공개 원본·첫 이미지에서 기준 확보 | 자산/profile 목록, 측정한 배치·style |
| 1·1.2 | UI 명시 GO 후 새 환경·백업·파일 선택 | 대상 경로·복원 지점·단일 owner·manifest |
| 2·2.1 | 기준과 manifest를 소비하는 핵심 prototype | 단축바·체력/마나·미니맵·시전바·블랙 외형 |
| 2·2.2 | 핵심 prototype 위 주술사 정보 | 토템·특성별 정보·선택한 알림/추천 profile |
| 3·3.1 | 실제 client와 현재 주술사에서 검증 | 통과·실패·미검증 게임 증거 |
| 3·3.2 | 정정과 해당 연계 재확인 | 고정판·설정·복원 경로·남은 제약 |

각 Phase는 세부계획 저장 → 실행 → 결과 저장 → 검증 → 대장 반영 순서다. 자연 단위마다 근거 읽기·구성·자체 확인·앞뒤 정합·필요한 실행·기록을 마친다. 계획 작성·독립 검수는 UI 구현 Phase 진입이 아니다. 이미 승인된 macro 원본 보관은 별도 정형 helper가 처리하고 master가 원문 대조·통합 확인한다.

## Non-goals

- UI 실행 GO 전 addon 설치·업데이트·토글·게임 설정 적용·게임 입력. 새 macro 저작·호환 변환·주문 치환·자동 key mapping.
- 15개 전체 복원, 새 통합 UI로 임의 전환, 경매·meter·우편 등 부가 기능 추가.
- 플레이 자동화, 전투 protected frame 변경·제한 우회, 계정 식별자 수집·외부 게시.
- 모든 특성·레벨·콘텐츠 작동 보장, 2022 코드 전체 이식, 자작 macro를 Forever 호환성 이유로 수정·필터링·정리.

## Implementation Changes

### 추천 구성·단일 owner

아래는 조건부 후보 구조다. Phase 1.2에서 선택하고 Phase 3.1에서 실제 작동을 판정한다. 같은 범위를 여러 addon이 동시에 제어하지 않는다.

| 기능 범위 | 우선 후보 owner | 조건·범위 |
|---|---|---|
| 일반 행동단축바·keybind label·paging | Dominos 12.0.4 | 원래 역할 유지. 현재 slot/action·입력·page 일치, 키 할당 보존 |
| player·target 체력/마나 | Forever Unit Frames 0.65.0 후보 | 원본 배치/폰트·자원/target·전투·koKR gate 통과 때만 선택. 아래 FUF는 이 제품 약칭 |
| party/raid | 게임 기본 frame | 복원 선택 시 실제 표시·조작 검증. FUF party/raid 기본 off; 필요하면 그 범위만 단일 owner 전환 |
| 미니맵 위치·테두리·버튼 | SexyMap v12.1.7 | 원본 profile·클릭·zoom·tracking 아이콘 gate |
| player·target 시전바 | 원본 Quartz 3.8.0 | 같은 표시의 Dominos Cast·FUF castbar off; 기본 시전바 중복도 시험 뒤 제거 |
| 토템 소환·세트 선택 | 게임 기본 Totem Bar | Dominos가 대체/이동하는 경우 실제 소환·교체·회수·page를 검증한 한 개만 유지 |
| 토템 상태 indicator | 선택된 unit frame의 표시 하나 | 같은 상태 보조 표시 중복 off. 입력용 Totem Bar와 역할 구분 |
| 블랙 panel·장식·정렬 연결 | 부족한 부분의 소형 glue 후보 | 기존 owner를 다시 제어하지 않음. 장식은 클릭 가로채기 없음 |
| optional 효과/proc 알림+추천 | Hekili Forever v0.8.5 후보 | 고양/정기·사용자 희망 때만 시험, core layout과 profile 분리. 복원 healer 추천으로 채택 안 함 |

[Dominos](https://www.curseforge.com/wow/addons/dominos)·[SexyMap](https://www.curseforge.com/wow/addons/sexymap)·[Quartz](https://www.curseforge.com/wow/addons/quartz)는 공식 Forever 배포를 확인했다. [FUF](https://www.curseforge.com/wow/addons/forever-unit-frames)는 Forever·토템·profile 기능을 선언하지만 Devil 외형 재현과 이 PC 전투 작동은 미검증이다. [PitBull](https://www.curseforge.com/wow/addons/pitbull-unit-frames-4-0)의 명시 Forever 지원은 근거 미발견이며 중단·작동 불가로 단정하지 않는다.

### 후보 선택 gate·대안

| 대상 | 선택 gate | 미통과 때 |
|---|---|---|
| 원본 source/profile | ZIP 목록·관련 설정·font/texture 실물과 원본 첫 그림 연결, 자산 사용 조건 확인 | 없는 profile은 없음 기록, 나머지만 새 profile 구성. 회수 완료 주장 없음 |
| Dominos | Forever 파일·의존·slot/label/paging·lockdown | native bar 안전 상태 유지. 다른 bar addon은 새 선택 없이 도입 안 함 |
| SexyMap | 원래 profile/테두리·모든 미니맵 입력 | native minimap 단일 owner, 허용된 배치·장식만 검토. 외형 미달을 완료로 세지 않음 |
| Quartz | 원본 3.8.0 파일·의존, 시전·취소·차단·target | native castbar. Redux/Updated는 별도 제품이므로 임의 교체 안 함 |
| FUF | health/mana·aura 전투 정확성, 원본 style 재현·입력/profile 보존 | native unit frame 안전 상태. 외형 부족이면 소형 custom 설계·추가 비용 구체화 후 결정 |
| custom/glue | 허용된 API(Application Programming Interface, addon이 호출하는 게임 기능)로 최소 prototype 실측 | 제한된 값 연산·보안 우회 금지, native 유지·불가능 항목 명시 |
| Hekili Forever | spec·학습 주문/rank·mana/proc/토템·추천 변화, 알림+추천 요구 충족 | optional만 보류. 알림만 원하면 기본 효과 표시 먼저. ProcDoc/EverAuras는 추가 검증·선택 전 설치 안 함 |

### 외형 복원 순서

1. 공개 원본을 별도 위치에서 확보해 관련 source·profile·자산을 읽는다. 오래된 Interface 전체를 게임 폴더에 덮지 않는다.
2. 확정한 첫 그림의 기준점·크기·간격·bar 수·글자·texture를 측정해 기준표에 기록한다. 지금 미판독 좌표·색·폰트를 만들지 않는다.
3. 임시 2560×1440에서 실제 resolution·UI scale을 확정하고 anchor·크기를 환산한다. 원문 16:10/4K 최적화 설명을 16:9에 그대로 늘리지 않는다.
4. core owner를 한 개씩 배치하고 부족한 블랙 장식만 연결한다. 한글·단축키를 읽을 수 있게 하고 중앙 게임 장면·토템·치유 정보를 가리지 않는다.
5. 같은 조건의 원본/현재 캡처로 영역별 위치·비율·테두리·글자·누락을 비교한다. 확보하지 못한 항목은 미검증으로 남긴다.

### 과거 15개 처리표

관찰판→앱 제공판은 **과거 metadata**이며 현재 설치를 뜻하지 않는다. 앞의 9개는 앱 game version 1.60.1, 나머지 6개는 값이 없었다. 정확한 ZIP 이름은 inventory를 따른다. 모든 실제 게임 작동은 미검증이다.

| # | 프로젝트 | 관찰판 → 제공판 | 처리 | 이유·조건 |
|---|---|---|---|---|
| 1 | Auctionator | 11.0.13 → 347 | 보류 | 경매 부가 기능 |
| 2 | BigWigs (Boss Timers & Tools) | v366.1 → v427.9 | 선택 | dungeon/raid 희망 때 별도 선택, core 제외 |
| 3 | Details! Damage Meter | 13132.161 → 20261109.15410.172 | 보류 | meter 요구 없음 |
| 4 | Dominos | 11.0.5 → 12.0.4 | 핵심 후보 | 원래 행동단축바, 선택·runtime gate 필수 |
| 5 | HandyNotes | v1.6.21 → v1.6.32 | 보류 | 지도 부가 데이터 |
| 6 | LittleWigs | v11.0.44 → v12.1.23 | 선택 | BigWigs 연계·콘텐츠 필요 확인 |
| 7 | Quartz | 3.7.13 → 3.8.0 | 핵심 후보 | 원래 시전바, 중복 off |
| 8 | RareScanner | 11.0.5.1 → FOREVER_1.60.1.8 | 보류 | 수집 부가 기능 |
| 9 | Simulationcraft | patch-11.0.5-01 → 12.1.5-04 | 보류 | 장비 분석 요구 없음 |
| 10 | Hekili [The War Within] | v11.0.5-1.0.4 → 동일 | 대체 후보 | 별도 Hekili Forever 평가, 동명 folder/DB 충돌 방지 |
| 11 | O Item Level (OiLvL) | 11.0.5.0 → 동일 | 보류 | 아이템 레벨 부가 기능 |
| 12 | OmniCC | 11.0.2 → 동일 | 게임 기본 우선 | cooldown 숫자 충족 시 불필요, 부족하면 지원 검증 |
| 13 | OmniCD - Party Cooldown Tracker | v11.0.2.2807 → 동일 | 보류 | party cooldown 요구 미정 |
| 14 | Postal | v4.2.0 → 동일 | 보류 | 우편 부가 기능 |
| 15 | WeakAuras | 5.17.3 → 동일 | 보류 | 옛 문자열 일괄 이전 없음, 알림 계층 중복 방지 |

### 주술사·알림

[토템 경험](https://www.reddit.com/r/wowforever/comments/1xtmxel/shaman_totems_setup/)은 버튼 부담과 상황별 접근을 보여 준다. [복원 경험](https://www.reddit.com/r/wowforever/comments/1xxogd5/which_healer_classes_are_decent/)은 치유 대상 조작을, [Riptide 토론](https://www.reddit.com/r/classicwow/comments/1xx0gdm/feedback_on_riptide/)은 기본 frame 추적 문제와 설정으로 해결 가능하다는 반론을 함께 보여 준다. 개인 보고이며 native 기능 PASS가 아니다. 한국어 정기/고양 경험은 검색 본문을 확보했으나 원문·댓글 접근 한계가 있다. 원문·한계는 U1~U6을 따른다.

| 선택 | 먼저 검증할 정보 | optional·한계 |
|---|---|---|
| 정기 Elemental | mana·대상·시전·실제 보유 proc·토템 | Hekili Forever 지원 선언 있음. 현재 학습 주문/rank·추천 대조 |
| 고양 Enhancement | mana·무기 강화·proc·토템 교체·action page | 지원 선언 있음. 상반된 mana/사용감 후기를 본인 실제 흐름에서 확인 |
| 복원 Restoration | 본인/party mana·health·치유 대상·해제 debuff·Riptide 등 실제 효과 | native party/raid 먼저, 부족하면 선택 frame 하나에서 보완. 피해량 추천을 치유 판단으로 취급 안 함 |

사용자의 EventAlert식 효과 알림과 Hekili 종합 도움을 함께 충족하는지가 기준이다. [Hekili Forever](https://www.curseforge.com/wow/addons/hekili-forever)의 Focus/proc·추천·glow는 제작자 설명에서 확인했다. 충분한 독립 주술사 후기는 **근거 미발견**이고 복원 healing 추천 지원도 미확인이다. 필요 없는 aura 도구를 추가하거나 추천만으로 요구를 축소하지 않는다.

### 이미 승인된 macro 원본 라이브러리

최종 승인 범위는 `D:\Projects\Project_WF\MacroLibrary\` 안의 private 라이브러리다. 보존본은 `MacroLibrary/archive-egl0lld0/`에 만들어졌다는 helper 완료 반환을 master가 전달했다. 원본4파일을 계정 공용1·캐릭터3 scope로 나눠 byte 그대로 보관하고 private manifest와 INDEX를 만들었다. source/archive SHA256 4/4·총6487bytes·9+11+16+8=44개, strict UTF-8 4/4·이름/원문행/literal 명령 대조44/44·빈본문1개 보존·Git 제외 확인은 helper의 실제 기계검증 반환값이며 이 A의 raw 재검사가 아니다. INDEX는 원본이름·scope·원문참조번호·실제 조건문에서 기계확인한 검색키만 담는 찾기 보조이며 raw 원형이 원본이다. typo·빈본문·이름·조건·명령순서·ID·인코딩을 보존한다. source 삭제·변환·병합·Forever 파일 복사·적용사본·키 배정·새 macro 저작은 하지 않았다. raw·실계정 경로·식별자·macro 이름은 library 내부에만 두고 Git/외부 자료로 보내지 않는다. master가 원문 대조·통합 확인을 맡고 이 A는 raw를 받지 않는다. 나중에 사용자가 필요한 원형을 요청하면 그때 해당 원문을 꺼낸다. 현재 게임 적용·호환성 시험은 미수행이다.

## Phase N — 복원·구성·검증

세부계획 파일은 아직 생성하지 않은 미래 경로이며 해당 Phase 착수 때만 작성한다.

| Phase | 세부계획 파일 | Step | 상태 |
|---|---|---|---|
| 1.1 원본·외형 | `Codex/plans/2026-11-17-devil-ui-forever-phase1.1-세부계획.md` | 1~2 | 예정 |
| 1.2 준비·선택 | `Codex/plans/2026-11-17-devil-ui-forever-phase1.2-세부계획.md` | 3~4 | 예정 |
| 2.1 core prototype | `Codex/plans/2026-11-17-devil-ui-forever-phase2.1-세부계획.md` | 5~6 | 예정 |
| 2.2 주술사 | `Codex/plans/2026-11-17-devil-ui-forever-phase2.2-세부계획.md` | 7~8 | 예정 |
| 3.1 실제 게임 | `Codex/plans/2026-11-17-devil-ui-forever-phase3.1-세부계획.md` | 9~10 | 예정 |
| 3.2 정정·인계 | `Codex/plans/2026-11-17-devil-ui-forever-phase3.2-세부계획.md` | 11~12 | 예정 |

## Implementation Interfaces

현재 UI 코드·설정 변경은 없다. 다음은 실행 승인 뒤 연결 계약이다.

| 연결 | 입력 → 출력 | 계약 |
|---|---|---|
| 원본→layout | 첫 그림·자산/profile → anchor·크기·style 기준 | 추출 근거·미확보 구분, 좌표 임의 생성 없음 |
| 배포→client | project/file ID·flavor·의존 → 고정 manifest | 숫자 유사성·앱 label만으로 flavor/제품 선택 안 함 |
| profile→addon | 새 `DevilForever-Test` 후보 profile → owner 설정 | 기존 것이 있으면 백업·사본에서 작업, 계정 전체 reset 없음 |
| bar→입력 | 현재/기본 slot·keybind → 동일 실행·label | 빈 bind는 빈 상태, 자동 key mapping 없음 |
| frame→상태 | 허용된 health/mana·target·aura → 표시 | 제한된 값 연산·우회 없음, unavailable을 정상값으로 꾸미지 않음 |
| 게임→optional | 실제 spec·주문·효과·자원 → 알림/추천 | 수동 입력 보조만, 자동 cast/target 없음 |
| macro 원문→private library | 자작 원본4파일 → 보존본·manifest·44개 검색색인 생성 반환 | 원문 동일성4/4·원본scope 유지라는 helper 검증값을 master가 확인. 검색색인은 보조, 게임 적용·변환 없음. 다음 요청 때 검색 |
| prototype→고정판 | 통과한 버전/profile/layout → 복원 가능한 구성 | 증거 연결, 개인 raw·허용 미확인 외부 자산 공개 없음 |

CurseForge 프로젝트 목록과 게임 macro/keybind/WTF는 별개다. 새 환경에 이전 설정이 있었다고 가정하지 않고 실제 현재 설정만 보존한다.

## Test Plan

### 독립 문서 검수

| 대상 | 갈래 | 고정 5 | 고정 ③ | 가변 5 |
|---|---|---|---|---|
| 신규 plan·인용 evidence | ③ 구조 변경·비코드 | P5 일반 문서 | 신규 연결: 계획 안 전제→선택→검증, 밖의 요구·관찰·원문 | Forever flavor/앱 label; 원본 충실도/임의 layout; 주술사·후기 한계(적대); 백업·단축키·개인정보·macro 원문; 단일 owner·의존·업데이트 |

독립 검수자가 **총 10관점·10라운드** 수행한다. 현재 미수행이다. 고정 다섯은 ①구조·표 형식 ②사실·인용·링크 ③앞뒤/원천 연결 ④정의·단계·누락 ⑤요청 범위·뜻이다. 가변 다섯은 표와 같다. 적대 관점은 지원 선언/개인 후기를 실제 주술사 작동 보장으로 오독하는지 반증한다. master 원문 대조 뒤 같은 A가 연결된 중대·중간을 함께 고치고 같은 B가 재확인한다.

미래 Lua 구조 변경은 실제 게임 실행부터 확인하고 코드 ③의 연계·뜻·적대 **3라운드**를 수행한다. 문법/import만으로 작동을 선언하지 않는다. 실제 시험 불가 부분은 미검증이다.

### 실제 게임 gate — UI 실행 승인 뒤

| gate | 수행·증거 | 통과·실패 처리 |
|---|---|---|
| G1 대상·보존 | `_forever_`·client·addon 재목록, 게임 완전 종료 뒤 현재 AddOns/WTF/Config·설정 백업·목록/hash | 복원 가능한 백업 확인. 없는 설정은 없음 기록, 계정 내용/식별자 외부 기록 없음. 실패 시 적용 안 함 |
| G2 파일 | 공식 flavor·file ID·동봉 의존·folder/version 기록, 후보 한 개씩 격리 | manifest 일치, Hekili 구판/Forever 동명 folder/DB 충돌 0. 새 필수 의존은 재결정 |
| G3 화면·외형 | 실제 resolution·UI scale, 같은 조건 캡처와 기준표 대조 | 임시 2560×1440 확인/수정, anchor·크기·간격·한글·테두리·누락 기록. 미달 숨기지 않음 |
| G4 입력·page | 채워진 모든 버튼 action/label·bind 전후 대조, 수동 실행과 page | 의도하지 않은 bind 변화 0. 토템·Ghost Wolf/stance·pet·vehicle/override는 해당 상황에서 시험, 미학습/불가 이유 구분 |
| G5 상태·시전 | 기본 게임값과 대조, damage/heal·mana 소비/회복·target/no target·시전/취소/차단 | 멈춤·오표시·중복 0. 비전투만 맞는 것을 전투 PASS로 세지 않음 |
| G6 reload·relogin | 전투 밖 reload 1회·재접속 1회 후 layout/profile/bind | 위치·profile 유지, 중복·오류 0; reset되면 원인 수정 |
| G7 lockdown | 안전한 상황에서 사용자가 수동 전투, 진입/종료·target·page·상태 관찰 | protected action/taint 오류·금지 frame 변경 0. 전투 중 설정 이동 없음 |
| G8 주술사 | 실제 학습 토템 세트·소환/교체/회수·시간·mana·강화/proc·선택 spec 흐름 | 토템 입력 접근·표시 일치. 타 spec·미학습 주문 제외, 레벨업 후 재확인 목록 |
| G9 복원/알림 | 복원은 party/raid health/mana·debuff·Riptide·수동 대상 조작. 선택 Hekili는 proc/추천·자원 대조 | native 표시 상반 보고를 실제 확인. 틀린 추천/상태 미관측이면 optional 미통과, 치유 지원 오인 금지 |
| G10 minimap | click·zoom·ping·tracking·button·tooltip, Questie 사용 시 icon/클릭/추적 | panel/장식이 입력 막지 않음. Questie 미설치면 현재 해당 없음, 추후 설치 전 연계 gate |
| G11 격리·오류·rollback | 다른 profile 영향·Lua/전투 오류 기록, 게임 종료 뒤 백업 복원 시험 | profile/bind 손상 0, 중대·중간 미해소 0, 복원 뒤 기준 상태 재현. 수집 addon은 승인 범위 안 |
| G12 고정 | 파일/version·owner·profile·layout·검증/미검증 목록 | 재현 가능한 구성, 미시험 raid·vehicle·레벨·spec 따로 표기 |

실패 기능은 백업/native 상태로 복원하고 그 부분·연계만 정정한다. 통과한 무관한 시험을 반복하지 않는다. 사용자 PC의 UI 게임 검증은 실제 접근 가능한 승인 시점에 한다. macro 라이브러리는 이미 승인됐으므로 위 UI GO와 별개로 원문 동일성·4파일/44개 보존·private 검색색인을 helper가 기계검증하고 master가 원문 대조한다. 게임 적용/호환성 PASS로 세지 않는다.

## Assumptions

| 전제 | 상태·검증 |
|---|---|
| 첫 이미지·하단집중형 | 사용자 확정, 재선택 없음 |
| 설치 목록 | 과거 관찰, 삭제됐을 수 있어 실행 전 재확인 |
| 옛 profile/keybind | 존재·이전 가정 없음, 현재 값 있으면 보존 |
| macro | 원본44개 private library·검색색인 생성 완료 반환을 master가 전달. 이 A raw 미독. 대상 캐릭터 대응·게임 적용은 취소, 실제 게임 로딩·호환성 미검증 |
| 2560×1440·scale | 캡처 크기만 확정, G3 실측 |
| archive profile 회수 | 미검증, 실제 ZIP 내용 확인 |
| 후보 | 공식 배포 선언만 확정, 선택 gate·G2~G11 별도 |
| spec·콘텐츠·알림 | 미정, 임의 spec 고정 없음 |
| 게임 접근·성능 | 사용자 접속 시점 미정, 관찰 종료 후 자동 전환/입력 금지, 성능 수치 보장 없음 |

## Correction History

| 날짜 | 반영 | 근거 |
|---|---|---|
| 2026-11-17 | 최초 초안: 원본 역할·단일 owner·후보 gate, 15개 일괄 적용 제외 | R1~R7·S1~S10 |
| 2026-11-17 | 관찰 종료·정리 가능성·새 환경 | R8~R10 |
| 2026-11-17 | 최종 D: 프로젝트, C: 기록 보존 | R11·R12·PROJECT_LOCATION addendum |
| 2026-11-17 | 최신 선택으로 원본44개 private 라이브러리·검색색인에 한정, 이전 이동/게임 적용 취소 | 최신 사용자 원문·master source4파일 실측 보고 |

구현 Phase 종료가 아직 없어 별도 계획 이력 파일은 만들지 않았다. Phase 종료 때 해당 이력을 보존해 별도 이력 파일로 옮긴다.

## Decisions Required

UI는 **독립 검수 → 사용자 피드백 → 계획 최소 1회 갱신 → 갱신본 명시 GO** 뒤 설치·구성·코드·게임 검증으로 들어간다. 이미 허용된 읽기·조사와 명시 요청한 macro 원본 라이브러리 보관은 재질의하지 않는다. 게임 적용은 현재 범위 밖이다.

열린 선택:

- **주술사 특성·플레이:** 정기·고양·복원과 주 콘텐츠(레벨업/퀘스트·dungeon/raid·PvP). 미정이면 공통 core까지 설계하고 특성 optional은 보류한다.
- **효과 알림·추천 양:** 최소 정보 / 효과·proc 알림 중심 / 효과 알림+다음 행동 추천. 마지막은 Hekili Forever 우선 시험, 정확성 통과가 조건이다.
- **체력·마나 후보·custom 비용:** FUF 외형/전투 gate 통과 때 채택하는 안. 실패하면 native 안전 상태를 두고 추가 custom 4~8시간의 범위를 구체화해 결정한다. 지금 custom 구현 승인으로 세지 않는다.

### 멈출 일 미리 점검

| 항목 | 기본 대책·GO에 포함할 범위 |
|---|---|
| 새 의존성·설치 | Dominos·SexyMap·Quartz·FUF와 선택한 Hekili를 manifest로 확정 후 설치. 부가 15개·새 aura stack·오류 수집 addon 자동 포함 없음. 새 필수 의존은 계획 갱신·결정 |
| 네트워크·외부 호출 | 공개 원본 Drive·공식 release/document 확보. 유료 서비스·계정 연결·대규모 수집·외부 raw 업로드 없음 |
| 파괴·삭제·덮어쓰기 | 게임 종료·현재 상태 백업·복원 확인 먼저. 원본/사용자 설정 전체 삭제·덮어쓰기 없음. 사본/profile에서 먼저 구성, 실제 합류/기존 파일 변경 전 사용자 승인. macro는 private library 신규 보관만, 게임파일 수정 없음. 정리 삭제 없음 |
| 권한 | D: 문서 쓰기는 실제 권한 검토, 게임 경로 등 새 권한은 시점에 범위 제시. 관리자·보안 설정 변경 당연시하지 않음 |
| 세션 전환 | 같은 A↔B 순차, 기본 한 유닛, 병렬 추가 승인 없음. 지정 입력·실행 상태·다음 gate 인계 |
| 검증 미수렴 | 실패 기능 rollback·원문/영향 지도 정정·같은 B 재확인. 중대·중간 미해소 기능 완료/배포 안 함 |
| 기존 문제 | 현재 기록과 실제 재현·이번 변경 도입 여부 구분, 범위 밖 자동 수정 없음 |
| push·외부 게시 | remote 없음, 계획-only 새 commit 금지. 이후 실행 local commit은 프로젝트 규칙대로 master 판단. push/merge/공개 게시 별도 사용자 명시 |
| 실측 불가 | 전투·치유·vehicle·레벨 미달 기능 미검증 기록. 문서/설계는 진행, 실제 접근 시 해당 gate. PASS 추정 없음 |
| 모델 미가용 | 지정 역할·설정을 다른 모델로 임의 대체하지 않음. 파일·상태 보존·실제 제약 보고 |

요청하는 지침 예외는 없다. 계획 자체가 UI 설치·게임 설정 변경·기존 결과 덮어쓰기의 권한을 만들지 않는다.

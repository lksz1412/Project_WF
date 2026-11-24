# Devil Forever 기능 트리

```text
Devil Forever
├─ 공통 설정     해상도 프리셋 · 테마 · 설정 저장과 복원
├─ 하단 조작     행동·소환수 단축바 · 미니맵 · 상태띠
├─ 대화          공개 · 그룹 · 시스템
├─ 전투          유닛 · 시전 · 이름표 · 행동 추천 · 쿨다운
├─ 그룹·기록     파티 · 공격대 · 데미지와 위협
└─ 성장·퀘스트   경험치 · 평판 · 목표 추적
```

**해상도 프리셋** · [FHD 1920×1080](../AddOns/!DevilForever_Core/Presets/fhd.lua) · [QHD 2560×1440](../AddOns/!DevilForever_Core/Presets/qhd.lua) · [4K 3840×2160](../AddOns/!DevilForever_Core/Presets/uhd.lua)

**테마** · [진영 2종·종족 10종·데빌 1종](../../References/codex-appearance/24/racial-appearance/index.md) · [기능 좌표표](../../References/codex-appearance/24/feature-positions.json)

## 공통 설정

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 해상도와 초기 배치 | `!DevilForever_Core` | 최초 사용 시 화면에 맞는 프리셋 선택. `/dfp status`에서 활성 프리셋 확인. `/dfp preset <이름>`으로 배치 복원 예약 |
| 테마와 공통 패널 | `DevilForever_Appearance` | `/dfp theme <번호>`. 기본값은 `0` 데빌이며 단축바와 하단 채팅·미니맵 외곽에 선택한 그림 적용 |
| 설정 관리 | `!DevilForever_Core` · `ProfileManager` | Core의 등록 범위는 `/dfp save`·`restore`. 키와 게임 설정은 ProfileManager 경로를 호출하는 `/dfp keys`·`/dfp game` |

## 하단 조작

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 행동 단축바·태세·토템·메뉴·가방·대기열 | `Dominos` · `Dominos_Config` | 프리셋의 직업별 초기 배치. 슬롯과 키 할당은 Dominos와 게임 키 설정 |
| 단축바 및 소환수 버튼 테두리 | `Masque` · `Masque_Onyx` · `Masque_Dominos` · `DevilForever_Skin_Dominos` | Onyx 기본 외곽과 테마별 소환수 테두리. 소환수 스킨은 해당 기술 버튼 표시와 연동 |
| 미니맵 | `SexyMap` | 사각 미니맵 초기 기본값과 해상도별 크기 192 / 224 / 304px. 기존 미니맵 프로필은 SexyMap에서 설정 |
| 골드·가방·내구도·시계·지연·초당 프레임 | `DevilForever_StatusStrip` · `DevilForever_Skin_StatusStrip` | 프리셋 하단 띠와 테마. 표시 항목은 `/dfstatus` |
| 테마 선택 | `DevilForever_Skin_StatusStrip` · `DevilForever_Core` | 상태띠 오른쪽 화살표로 13종을 순환한다. `/dfp theme`의 번호, 현재 테마와 저장을 공유한다. |

## 대화

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 수신·송신·한글 입력 | 게임 기본 채팅 | 현재 게임 채널·입력 경로 사용 |
| 공개·그룹·시스템 초기 세 창 | `DevilForever_ChatSetup` | [해상도별 실제 창 좌표](../AddOns/DevilForever_ChatSetup/ChatLayout.lua). 자동 배치 기록이 있고 사용자가 움직이지 않은 창은 프리셋·화면 배율을 따라간다. 기존 분할과 사용자가 옮기거나 닫은 창은 유지 |
| 채팅 배경·글꼴·문양 | `DevilForever_Skin_NativeChat` · `DevilForever_Appearance` | 공통 프리셋과 선택 테마. 종족·진영 문양은 오른쪽 창, 데빌은 흑회색 면 |

## 전투

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 플레이어·대상·소환수·주시·파티 유닛 | `PitBull4` 초기 시험판 | Core 초기 프리셋. 아군 우측·적군 좌측 배치. 오라 필터와 세부 설정은 PitBull4 |
| 유닛 프레임 대체판 | `ForeverUnitFrames` · `DevilForever_FUFDefaults` · `DevilForever_Castbars` | 해당 해상도의 별도 비교 프로필에서 `/dffuf layout fhd`, `qhd`, `uhd` 중 하나로 좌표를 적용한다. 최종 판은 [같은 접속의 실제 비교](../../References/codex-verify/one-session-review.md) 뒤 결정 |
| 플레이어·대상·주시·소환수 시전 | `Quartz` | Core 초기 프리셋의 위치와 크기. 시전 동작 옵션은 Quartz |
| 이름표·이름표 시전 | 게임 기본 이름표 · `DevilForever_Skin_Nameplates` | [해상도별 이름표 크기](../AddOns/DevilForever_Skin_Nameplates/NameplateProfiles.lua). 실제 쓰기 가능한 이름표 요소에 적용 |
| 직업 행동 추천 | `Hekili` · `Hekili_Shared` · 직업 9개 모듈 | 초기 프리셋의 추천 칸. [현행 추천 범위와 기본 쿨다운의 담당](hekili-current.md)과 Hekili 자체 설정 |
| 기본 쿨다운 관리자 | 게임 기본 Cooldown Manager | [네 표시 구역의 해상도별 목표 좌표](../../References/codex-appearance/8/report.md). 게임의 편집 모드에서 실제 프레임과 좌표 확인 |

## 그룹·기록

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 파티와 공격대 | `Grid2` · `Grid2Options` · `Grid2LDB`(파티·공격대, 오른쪽 적 대상 프레임 바로 위) 와 유닛 프레임 파티(`PitBull4` 파티 그룹 — 왼쪽 위 세로, 공격대에서는 내 소그룹, 또는 FUF 파티)가 함께. 유닛 프레임 파티 켜기/끄기는 `/dfp party on`·`/dfp party off`(접속 때 되돌리지 않음) | Core 초기 프리셋. Grid2 틀은 Modern 자동(고르기 창 없음). Grid2 세부 지표는 Grid2 프로필 |
| 데미지와 위협 | `Details` · `Details_TinyThreat` · `DevilForever_DetailsLayout` | 기존 창 1·2에 `/dfdetails apply`로 [해상도별 위치](../AddOns/DevilForever_DetailsLayout/Layout.lua) 적용. 모드와 세부 표시 설정은 Details |

## 성장·퀘스트

| 기능 | 담당 | 적용 경로 |
|---|---|---|
| 경험치·평판·소환수 경험치 | `ExperienceForever` | 설치본은 세로 막대를 사용한다. 프리셋은 질감과 글꼴을 등록하고 표시 설정은 `/ef`에서 관리한다. [가로 공간 대안](../../References/codex-appearance/19/report.md)은 목업의 제안 값이다 |
| 퀘스트 추적 | 게임 기본 목표 추적기 | 실제 창 경계 측정용 `/dfcheck quest` 는 기본으로 불러오지 않음(진단 파일을 TOC 에 넣을 때만). [4K 가독성과 배치 확인](../../References/codex-verify/one-session-review.md) |

## 설정을 둘 위치

| 설정 | 권장 관리 위치 |
|---|---|
| 해상도별 전체 배치, 테마, 모음집 백업·복원, 유닛 프레임 파티 켜기/끄기(`/dfp party on|off`) | Core의 `/dfp`. 게임 재확인용 `/dfcheck` 는 기본으로 불러오지 않음 |
| 키·오라·필터·추천·미터기 모드 | 해당 애드온의 기존 설정. 공통 배치는 초기값으로 제공 |
| 기본 쿨다운 창과 기본 퀘스트 추적기 | 게임 설정. 프리셋의 목표 좌표를 접속 때 대조 |

공통 배치를 바꾸는 화면이 필요해지면 해상도·테마·배치 복원부터 붙인다. 기능별 옵션이 어디에 있는지는 이 트리에서 찾아간다.

[설치와 복원](../install/설치안내.md) · [설치 목록](../install.json) · [한 번의 접속 검증](../../References/codex-verify/one-session-review.md)

# Step 60 준비 — 상위 애드온 1차 등급과 자체 Lua 성능 검수

2026-11-19 · 포에버 1.60.1 · Devil Forever 0.1.1

## 1차 등급

두 목록의 순위 항목 40개를 고유 프로젝트 30개로 맞췄다. 유지 1개, 선택 7개, 의존 6개, 참고 5개, 제외 11개다. 기본 포함을 새로 권고한 후보는 없다. 선택은 필요한 사용자가 따로 설치할 후보, 의존은 본체를 선택할 때 확인할 구성품이다. 이 등급은 공식 설명, 기존 구성과 네 우선 후보의 코드 대조에 따른 1차 권고다. 후보 추가에 따른 프레임 시간과 메모리는 게임에서 측정해야 한다.

[인기순](https://www.curseforge.com/wow/search?class=addons&gameVersionTypeId=88568&page=1&pageSize=50&sortBy=popularity&version=1.60.1) · [누적 다운로드순](https://www.curseforge.com/wow/search?class=addons&gameVersionTypeId=88568&page=1&pageSize=50&sortBy=total+downloads&version=1.60.1) · [평가 기준](../plans/2026-11-19-devil-forever-addon-adoption-plan.md)

| 프로젝트 | 인기 | 다운로드 | 1차 등급 | 이유 |
|---|---:|---:|---|---|
| Questie | 1 | 3 | 선택 | 기본 목표 창과 함께 지도에 추가 정보만 제공할 때 가치가 있다. 데이터 조회와 지도 갱신은 실게임 비교 대상이다. |
| Auctionator | 2 | 4 | 선택 | 경매 검색 목록, 단가 확인, 가격 조회가 빈 곳을 채운다. 경매장·전문기술을 자주 쓰는 사람용이다. |
| QuestieDB | 3 | — | 의존 | Questie 사용에 필요한 데이터다. 공식 CurseForge 배포에서는 Questie와 따로 온다. |
| Details! | 4 | 2 | 유지 | 0.1.1 두 판의 기존 데미지·위협 담당이다. |
| DungeonJournal | 5 | — | 선택 | 던전 퀘스트와 드롭을 한곳에서 찾는다. 현행판에는 전투·지도에도 연결되는 기능이 여럿 있다. |
| DBM Core | 6 | 1 | 선택 | 던전·공격대 경보를 쓰는 사람용이다. 해당 콘텐츠 모듈을 붙여 판단한다. |
| RareScanner | 7 | 7 | 제외 | 희귀 몹·보물 알림은 별도 플레이 목적이다. |
| Leatrix Plus | 8 | 16 | 참고 | 개별 편의 옵션만 참고한다. 기존 채팅과 화면 관리에 겹치는 옵션이 있다. |
| Bagnon | 9 | 6 | 제외 | 게임 기본 통합 가방을 유지한다. 부캐 검색을 기본 구성의 요구로 보지 않는다. |
| BagBrother | 10 | — | 의존 | Bagnon의 내부 엔진으로 Bagnon에 이미 동봉된다. |
| Leatrix Maps | 11 | — | 제외 | 기존 세계지도에 별도 화면 기능을 더하는 범위다. |
| TomTom | 12 | 13 | 제외 | 좌표·방향 안내는 별도 탐색 목적이다. |
| DBM Dungeons | 13 | 12 | 의존 | DBM Core에 던전 경보를 붙이는 콘텐츠 모듈이다. |
| What's Training? | 14 | — | 선택 | 포에버 전문기술 창에서 배울 도안과 습득 경로를 확인한다. 전문기술 후보 중 우선 검토한다. |
| Baganator | 15 | — | 제외 | 분류·검색이 추가되지만 기본 가방을 바꾸고 Syndicator가 필요하다. |
| Plater Nameplates | 16 | 10 | 참고 | 이름표 가독성의 비교 기준이다. 기존 이름표 담당을 교체할 근거는 아직 없다. |
| AtlasLoot Classic Forever | 17 | — | 참고 | 던전 드롭과 장비 목표를 찾는 비교군이다. 던전 조회에서 DungeonJournal과 일부 겹친다. |
| Syndicator | 18 | — | 의존 | Baganator를 사용할 때 필요한 재고 데이터 모듈이다. |
| OpenMap | 19 | — | 제외 | 기본 세계지도 유지와 겹치는 확대·이동·지도 그림 기능이다. |
| EllesmereUI | 20 | — | 참고 | 정렬과 화면 배율을 비교할 수 있다. 전체 통합 UI의 추가 비용과 기능 중복이 크다. |
| BigWigs | — | 5 | 참고 | DBM의 대안 비교에 쓴다. 같은 경보를 두 벌 설치하지 않는 구성을 검토한다. |
| LittleWigs | — | 8 | 의존 | BigWigs를 선택할 때 검토할 던전 콘텐츠 모듈이다. |
| Pawn | — | 9 | 제외 | 스탯 가중치에 따른 장비 추천은 기존 패키지 범위를 넓힌다. |
| GTFO | — | 11 | 선택 | 바닥 피해 음성 알림이 필요한 사람용이다. DBM과 같은 상황에서 알림이 겹치는지 확인한다. |
| HealBot Continued | — | 14 | 제외 | Grid2와 마우스오버 치유 설정을 유지한다. |
| Bartender4 | — | 15 | 제외 | 같은 단축바를 담당하는 Dominos를 유지한다. |
| TradeSkillMaster | — | 17 | 선택 | 제작·재료비·판매까지 관리하는 전문 이용자용이다. Auctionator와 경매 기능이 겹친다. |
| ALL THE THINGS | — | 18 | 제외 | 수집 전체를 추적하는 별도 목적의 도구다. |
| HandyNotes | — | 19 | 제외 | 지도 메모와 별도 콘텐츠 모듈은 개인 용도에 둔다. |
| DBM Forever and Vanilla | — | 20 | 의존 | DBM Core에 포에버와 오리지널 공격대 콘텐츠를 붙이는 후보이다. 실제 대상 보스의 경보 범위를 확인한다. |

전문기술 창의 도안과 얻는 곳을 확인하는 목적이면 What's Training?이 맞는다. TradeSkillMaster는 거래까지 관리할 때 비교하며, Auctionator도 경매 가격과 제작 재료를 연결하는 기능이 있다. 포에버에서 어느 범위까지 겹치는지는 설정과 실제 거래 기능을 대조한다. [What's Training?](https://www.curseforge.com/wow/addons/whats-training) · [TradeSkillMaster](https://www.curseforge.com/wow/addons/tradeskill-master) · [Auctionator](https://www.curseforge.com/wow/addons/auctionator)

## 네 분야의 코드 확인

| 애드온 | 공식 배포와 확인한 경로 | 쓸 이유와 비용 |
|---|---|---|
| DungeonJournal | 2.0.12, SHA-256 `c985faabe513830ca5733e57f3a8f35c7418d79bf5be5f63747d6737503a07d3`. TOC 전체, `Systems/QuestText.lua` 90–113, `Systems/PortraitPool.lua` 399–435, `Systems/RunLog.lua` 2321–2333 | 66.4 MiB ZIP. 던전 드롭·퀘스트를 한곳에서 찾을 수 있고, 데이터와 실행 기록을 함께 로드하고 이름표·전투 이벤트에도 등록한다. 실제 처리 비용과 그래픽 메모리는 미측정이다. 여러 퀘스트 변경을 1초 뒤 한 번으로 묶고, 화면에 대기 중인 초상화가 없으면 타이머 프레임을 숨기는 방법을 확인했다. [배포 파일](https://www.curseforge.com/wow/addons/dungeonjournal/files/9687205) |
| Auctionator | 349, SHA-256 `da056c2461a0badec3ff3bcd64b1b870a3c4058d015aca55d171044ef0c49423`. TOC 전체, 공통 `Source/Manifest.xml` 전체, 클래식 초기화 `Source_Classic/Initialize/Main.lua` 전체 | 경매장 열기와 상호작용 이벤트에서 필요한 창을 만들고, 별도 전문기술·상인 이벤트를 처리하는 방법을 확인했다. 정확한 포에버 이벤트 성능과 전체 스캔 시간은 미측정이다. 가격 데이터와 검색 업무를 통째로 자체 구현할 필요는 적다. [배포 파일](https://www.curseforge.com/wow/addons/auctionator/files/9690303) |
| DBM | 공식 던전 저장소의 포에버 TOC 1–42행과 README, Core 설명 및 LICENSE | 포에버 던전 모듈은 확인한 소스에서 `LoadOnDemand`와 Core 의존성을 선언한다. 일부 신규 던전은 범용 경보만 제공하고 전용 타이머가 없는 상태라고 제작자가 명시했다. 경보 본체는 제작자가 관리하는 모듈로 쓰고 자체 UI에는 필요한 화면 갱신만 유지한다. [Core](https://github.com/DeadlyBossMods/DeadlyBossMods) · [포에버 던전 모듈](https://github.com/DeadlyBossMods/DBM-Dungeons) · [공격대 모듈](https://github.com/DeadlyBossMods/DBM-Vanilla) |
| Questie | 12.11.0, SHA-256 `8fcaa90cdffe5e99b9209afa4c90dd9c20131bb4c78e2a83ab3c753152f40aa5`. 포에버 TOC 1–27, `QuestieOptionsDefaults.lua` 67·181, `QuestieOptionsTracker.lua` 104 이후와 지도 프레임 재사용 경로 대조 | CurseForge ZIP의 폴더는 Questie와 QuestieTrace다. QuestieDB는 제작자가 별도 필수로 안내한다. 미수락 퀘스트와 자체 추적기 설정이 분리되어 있어 기본 목표 추적을 유지하는 선택 구성을 우선 확인한다. 지도 아이콘 프레임 재사용은 자체 UI 비교에 참고한다. [배포 파일](https://www.curseforge.com/wow/addons/questie/files/9687964) · [설치 안내](https://github.com/Questie/Questie) |

이전 Phase 17 후보는 Kaliel's Tracker였고 기존 사용자 결정으로 빠졌다. 0.1.1 목표 추적은 게임 기본이 담당한다. DungeonJournal·Auctionator·DBM Core는 배포 원본이 All Rights Reserved, Questie는 GPLv3 표기다. 외부 코드와 데이터는 공식 파일을 그대로 읽어서 근거를 확인했다. 자체 구현 후보는 동작 조건과 적용 범위를 별도로 정한 뒤 우리 코드로 작성한다. [현재 기능 트리](../../Collection/data/feature-map.md) · [이전 판단](../../Claude/results/REQUEST_LEDGER_phase8.md) · [DBM Core 라이선스](https://raw.githubusercontent.com/DeadlyBossMods/DeadlyBossMods/master/LICENSE)

## 아스트라 성능 검수

검수 요청으로 지정한 모델은 gpt-6.2-astra, high다. 0.1.1 기본판과 FUF판에서 자체 패키지 9개와 11개를 검수했다. 두 ZIP과 작업 트리의 해당 파일이 바이트 단위로 같음을 아스트라와 총괄이 각각 확인했다. 중대 0, 중간 3건이 보고됐다.

| 현상 | 독립 검수와 총괄 대조 | 개선 방향 |
|---|---|---|
| 프리셋 복원 시 필드마다 화면 전체 갱신 | ZIP의 실제 Lua와 기존 시험 대역의 조작 경로에서 UHD→QHD, QHD→FHD, FHD→UHD 각각 외관 전체 39회, 합성 질감 설정 호출 78회, Dominos 갱신 콜백 11회, 이름표 콜백 4회, 상태 띠 콜백 4회. 편집값 하나를 지우는 경우 외관 40회. 테마만 바꾸면 1회. `Presets.lua` 211–250과 `Appearance.lua` 144–189 | 변경 알림을 한 배치로 넘기고 스킨별 갱신을 한 번으로 합친다. 배치와 개별 편집 동작, 전투 뒤 보류 처리까지 검증한다. |
| 소환수 단축바 재구성 시 전체 단축바 갱신 | 자체 `DevilForever_Skin_Dominos/Skin.lua` 14–17·57–71, ZIP의 Dominos `core/buttonBar.lua` 76–87. 이미 후킹한 바에서 기존 10개를 떼고 새 10개를 붙이는 조건이면 전투 밖에서 20회. 소환만으로 이 경로가 발생하는지는 미검증이다. | 바뀐 소환수 버튼만 고치거나 재구성 뒤 소환수 바를 한 번 갱신한다. |
| 선택 FUF 비교 배치의 명령 전송 | `LayoutPresets.lua` 37–61, `NativeLayout.lua` 59–94. 비교 프로필 한 번 적용 때 최대 116개 명령 전송. ZIP의 FUF `Core/Commands.lua` 133–139 및 `Core/Config.lua` 126–146에서 각 유효한 설정의 갱신 알림 확인. | PitBull4 기본판과 비용을 따로 평가한다. 비교판 안에서 값이 같은 요청을 줄일 수 있는 공식 경로를 확인한다. |

게임 이름표는 전투 중 추가 이벤트에서 변경을 보류하고 종료 뒤 대기가 있을 때 전체를 한 번 처리한다. 상태 띠는 보이는 동안 시간 항목이 있으면 1초 타이머 하나를 사용하며, 숨겨지거나 시간 항목을 끄면 중지한다. 합성 배경의 한 쌍은 원본 픽셀 6 MiB이며 실제 그래픽 메모리는 미측정이다. 검수 중 코드는 수정하지 않았다.

## 남은 범위

30개 프로젝트에 첫 등급을 붙였다. 전체 후보의 출시 파일·라이선스·이벤트 경로까지 동일한 깊이로 확인하는 검토와 실제 게임의 프레임 시간 측정은 남아 있다. 자체 코드 수정 여부와 실제 설치 구성은 이번 결과에서 결정하지 않았다.

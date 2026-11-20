# Step 61 — 최소 선택 설치 구성

2026-11-19 · Phase 29.2 · Devil Forever 0.1.1

## 판정

당장 기본에 새로 넣을 것은 0개다. Details!와 그 위협 모듈은 기존 담당으로 유지한다. 양쪽 상위 20위를 합친 40개 순위 항목은 고유 30개이며, 유지 1개, 선택 7개, 의존 6개, 참고 5개, 제외 11개다. 30개 각각의 권고와 두 순위는 [후보별 배포 원본 대조](Step%2060%20%E2%80%94%20후보별%20배포%20원본%20대조.md)에 있다.

가방과 세계지도는 기존 선택대로 게임 기본을 유지한다. EllesmereUI와 Baganator는 실행 비용을 측정하지 않았으므로 비용 크기를 이유로 판정하지 않는다. 각각 현재 화면 담당과 겹치는 범위, 기본 가방에서 충족되지 않은 요구가 있는지를 근거로 삼는다.

## 선택 설치 후보 7개

| 필요한 기능 | 먼저 고려할 구성 | 설정과 실사용 확인 |
|---|---|---|
| 미수락 퀘스트 위치 | Questie 12.11.0과 포에버용 QuestieDB 1.1.3. 두 공식 ZIP에서 `Questie`와 `QuestieDB` 폴더를 확인했다. QuestieTrace는 별도 선택 기능이다. | 자체 추적기·미니맵 퀘스트 아이콘·이름표 아이콘·대상 프레임 아이콘·모든 마을 시설 아이콘을 끈다. 세계 툴팁과 퀘스트 창의 Questie 아이콘 추가도 끈다. 세계지도 아이콘과 미수락 일반 퀘스트 표시만 켜고 퀘스트 목표·완료 아이콘은 끈다. 원래 퀘스트 목록·기본 목표 추적창·PitBull 대상 프레임·기본 이름표에 Questie 표시가 겹치지 않는지 확인한다. 지도 이동, 같은 위치의 아이콘 중복, 미수락 필터와 새 지역 표시도 확인한다. [Questie](https://www.curseforge.com/wow/addons/questie/files/9687964) · [포에버 QuestieDB](https://www.curseforge.com/wow/addons/questiedb/files/9687647) |
| 도안과 습득처 | What's Training? 11.4.8의 `WhatsTraining` 한 폴더. 자체 ZIP의 포에버 로드 목록에는 선택 의존성만 있다. | 단순 도안 조회의 우선 후보다. 실제 배포 코드에서 게임패드 입력 감시와 트레이너 창 감시 경로를 확인했다. 주로 키보드를 쓸 때도 관련 프레임이 언제 일을 하는지와 전문기술 창 열기 비용을 측정한다. [What's Training?](https://www.curseforge.com/wow/addons/whats-training/files/9621224) |
| 경매 검색과 단가 | Auctionator 349의 `Auctionator` 한 폴더. 별도 필수 외부 모듈은 확인되지 않았다. | 검색 목록과 단가부터 확인한다. 전문기술 가격 표시와 기본 툴팁이 어떻게 함께 나오는지 보고, 조회와 전체 가격 스캔은 비용을 나눠 측정한다. [Auctionator](https://www.curseforge.com/wow/addons/auctionator/files/9690303) |
| 던전 퀘스트와 보스 드롭 | DungeonJournal 2.0.12의 `ForeverDungeonJournal` 한 폴더. | 도감이 실제로 필요한 경우에 선택한다. 퀘스트·드롭 조회로 시작하고 지도·추적·진행 기록의 쓰임과 비용을 따로 확인한다. 룻 테이블 조회가 주 목적이면 AtlasLoot를 비교한다. [DungeonJournal](https://www.curseforge.com/wow/addons/dungeonjournal/files/9687205) |
| 보스 경보 | DBM Core와 참여 콘텐츠의 포에버 모듈. 5인 던전은 DBM Dungeons, 공격대는 DBM Forever and Vanilla다. | 제작자의 포에버 지원 표기와 실제로 갈 던전·보스의 경보를 따로 확인한다. 저장소가 밝힌 일부 신규 던전의 경보 공백이 있다. BigWigs는 같은 용도의 비교 후보로 둔다. [DBM Core](https://www.curseforge.com/wow/addons/deadly-boss-mods) · [던전](https://github.com/DeadlyBossMods/DBM-Dungeons) · [공격대](https://www.curseforge.com/wow/addons/dbm-vanilla) |
| 제작 비용과 판매 기록 | TradeSkillMaster 4.15.8. 가격 자동 공급을 원하면 TSM 데스크톱 앱과 TSM_AppHelper 연동이 설치 안내에 있다. | 경매 검색·단가 정도면 Auctionator를 우선한다. 제작과 판매까지 장기 관리할 때만 TSM을 비교한다. 4.15.8 제작자 기록에 포에버 마법부여 스캔 수정이 있으나 한국 서버의 가격 데이터 공급 범위는 확인되지 않았다. [포에버 릴리스](https://www.curseforge.com/wow/addons/tradeskill-master/files/9688716) · [가격 설정 안내](https://support.tradeskillmaster.com/tsm-desktop-application/how-do-i-set-up-the-tsm-desktop-application?from_search=202589806) |
| 바닥 피해 음성 알림 | GTFO 단독 또는 DBM의 해당 경보를 보완하는 경우. | 같은 위험을 두 번 알리는지 먼저 확인한다. 6.12.4는 제작자 페이지의 포에버 최근 표시를 근거로 했으며 해당 파일 본문 및 실제 보스별 동작 확인은 남아 있다. [GTFO](https://www.curseforge.com/wow/addons/gtfo) |

## 확인 순서

- 전체 묶음을 먼저 켠 상태의 값을 기준으로 저장한다. 같은 캐릭터와 배율, 장소, 창 상태에서 후보 한 조합만 켠 경우와 비교한다. 게임 안 로드 시간과 같은 전투 구간 프레임 시간, 화면과 채팅 오류, 기본 창이나 개인 설정이 바뀌었는지를 함께 본다.
- 후보 폭을 좁힐 때 비교할 순서는 지도 정보의 Questie, 전문기술의 What's Training?, 거래의 Auctionator, 실제 콘텐츠에 맞는 DBM이다. 던전 도감은 드롭·퀘스트 조회의 실제 빈도가 높을 때 별도로 비교한다. 
- 자체 최적화의 39회 → 1회는 게임 없이 실제 0.1.1 Lua를 메모리에서 임시 조정한 대역에 한정한다. 0.1.1 코드와 패키지를 수정한 결과는 아니다. 나머지 스킨과 전투·개인 설정 동작은 [29.3 수정안](../plans/2026-11-19-devil-forever-addon-adoption-phase29.3-세부계획.md)의 별도 작업이다.

## 근거 범위

Phase 29.2 착수 때 마스터 플랜 본문과 12행 세부계획을 다시 읽었다. Step 60 배포 근거 92행 전문과 0.1.1 구성 목록을 대조했다. Questie 공식 ZIP의 지도 옵션과 추적기 설정 구간, 포에버 QuestieDB TOC의 상단 버전·클라이언트 항목, What's Training? 공식 ZIP의 포에버 TOC와 `Forever/Controller.lua` 600–683행, `Crafting/Controller.lua` 329–402행, `Forever/Trainer.lua` 444–499행을 확인했다. 라이선스는 제작자 표기로 기록했다. 실제 게임 측정은 아직 없다.

검수에서 Questie의 추가 표시 기본값을 확인해 선택 설정을 보완했다. 수정 작업자는 12.11.0 공식 ZIP의 `Modules/Options/QuestieOptionsDefaults.lua` 1–262행과 `Modules/QuestieNameplate.lua` 1–357행을 전부 읽었다. 기본값 파일의 42·56행은 이름표·대상 프레임 표시를 켜며 204–220행의 마을 시설 중 일부도 켜져 있다. 69·180·183행에는 세계 툴팁과 NPC 툴팁의 퀘스트 정보, 퀘스트 창 아이콘 설정이 있다. 이름표 파일 22·166행의 해제 조건과 268–269행의 PitBull 대상 프레임 연결을 대조했다. 설정 권고에 이 표시를 모두 해제하고 기존 담당에 중복되지 않는지 확인할 항목을 추가했다. 영향 지도에서 함께 수정한 곳은 위 Questie 행과 이 근거 범위이며 Step 60의 Questie·QuestieDB 행과 마스터 플랜의 기존 담당 유지 조건은 확인만 했다.

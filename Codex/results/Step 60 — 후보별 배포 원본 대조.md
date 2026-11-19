# Step 60 — 후보별 배포 원본 대조

2026-11-19 16:45:01 +09:00 기준 조회 · Phase 29.1 · 기준 패키지 0.1.1

## 확인 범위와 읽는 법

기존 두 순위표의 40개 항목을 고유 30개 프로젝트로 대조했다. 아래 표는 조회 시 CurseForge 제작자 페이지가 포에버 최근 파일로 가리킨 판을 기록한다. 프로젝트 전체의 마지막 수정일과 선택한 파일의 업로드 날짜가 다를 수 있어 파일 쪽 날짜를 사용했다. 순위는 준비 기록의 값을 유지한다.

포에버 지원 표시는 제작자가 등록한 메타데이터다. 게임에서 로드하거나 정상 작동하는지는 이번 작업에서 시험하지 않았다. 파일 페이지가 열리지 않은 GTFO 6.12.4는 프로젝트의 포에버 최근 파일 표기와 연결 주소까지 확인했다. 아래 라이선스는 페이지 표기다. GNU General Public License는 표에서 GPL로 줄여 쓴다. 라이선스의 배포 허용 범위와 ZIP 내부의 모든 외부 리소스 권한은 별도 판단이 필요하다.

“별도 필수 미확인”은 이번에 읽은 제작자 설명과 페이지에서 별도 설치품을 확정하지 못했다는 뜻이다. 의존성 페이지 여러 개가 관계 검색 틀만 표시하므로 이를 필수 모듈이 없다는 증거로 쓰지 않았다. 파일 크기, 모듈 수, 애드온 수만으로 전투 성능을 단정하지 않는다.

## 후보 30개

| 프로젝트와 공식 원본 | 인기 / 다운로드 | 포에버 최근 파일과 업로드 날짜 | 라이선스 표기 | 필수·동봉 관계 | 기존 담당과 고도화 판단 |
|---|---|---|---|---|---|
| [Questie](https://www.curseforge.com/wow/addons/questie) | 1 / 3 | [12.11.0](https://www.curseforge.com/wow/addons/questie/files/9687964) · 2026-11-18 | GPLv3 | 필수 QuestieDB. GitHub 전체 배포의 동봉과 CurseForge 분리 배포를 구분 | 기본 목표 추적기 · 선택 유지. 미수락 퀘스트 지도 정보부터 사용 범위를 좁혀 비교 |
| [Auctionator](https://www.curseforge.com/wow/addons/auctionator) | 2 / 4 | [349](https://www.curseforge.com/wow/addons/auctionator/files/9690303) · 2026-11-18 | All Rights Reserved | 이전 ZIP 대조에서 OptionalDeps LibAHTab. 별도 필수 모듈은 미확인 | 경매 보완 기능 없음 · 선택 유지. 검색 목록과 단가 조회부터, 전문기술 탭 가격 연계도 확인 |
| [QuestieDB](https://www.curseforge.com/wow/addons/questiedb) | 3 / — | [1.1.3 (Forever)](https://www.curseforge.com/wow/addons/questiedb/files/9687647) · 2026-11-18 | GPLv3 | Questie의 필수 데이터. 이 파일은 포에버 전용 | 독립 담당 없음 · 의존 유지. Questie 선택 시 포에버 파일을 함께 관리 |
| [Details!](https://www.curseforge.com/wow/addons/details) | 4 / 2 | [Details.20261109.15410.172](https://www.curseforge.com/wow/addons/details/files/9521145) · 2026-11-09 | All Rights Reserved | 0.1.1에 Details와 Details_TinyThreat 포함. 추가 외부 필수 미확인 | 동일 애드온과 자체 배치 · 유지. 조회한 최신 파일과 현 동봉판을 같은 판으로 가정하지 않음 |
| [DungeonJournal](https://www.curseforge.com/wow/addons/dungeonjournal) | 5 / — | [DungeonJournal2.0.12.zip](https://www.curseforge.com/wow/addons/dungeonjournal/files/9687205) · 2026-11-18 | All Rights Reserved | 앞선 ZIP 대조에서 단일 ForeverDungeonJournal 폴더. 별도 필수 미확인 | 던전 조회 기능 없음 · 선택 유지. 퀘스트·드롭 조회와 지도·진행 기록의 추가 범위를 함께 고려 |
| [DBM Core](https://www.curseforge.com/wow/addons/deadly-boss-mods) | 6 / 1 | [12.1.23](https://www.curseforge.com/wow/addons/deadly-boss-mods/files/9587232) · 2026-11-13 | All Rights Reserved | 경보 대상별 던전·공격대 모듈은 별도 선택 | 보스 경보 기능 없음 · 선택 유지. 해당 콘텐츠의 실제 경보 지원 범위를 확인 |
| [RareScanner](https://www.curseforge.com/wow/addons/rarescanner) | 7 / 7 | [RareScanner_FOREVER_1.60.1.9](https://www.curseforge.com/wow/addons/rarescanner/files/9681561) · 2026-11-18 | All Rights Reserved | 별도 필수 미확인 | 기본 미니맵 · 제외 유지. 희귀·보물 수집 목적을 기본 구성으로 넓힐 근거 없음 |
| [Leatrix Plus](https://www.curseforge.com/wow/addons/leatrix-plus) | 8 / 16 | [1.60.33-forever](https://www.curseforge.com/wow/addons/leatrix-plus/files/9691047) · 2026-11-18 | All Rights Reserved | 별도 필수 미확인 | 자체 채팅·화면 관리와 일부 겹침 · 참고 유지. 필요한 개별 편의 기능을 먼저 식별 |
| [Bagnon](https://www.curseforge.com/wow/addons/bagnon) | 9 / 6 | [12.1.12](https://www.curseforge.com/wow/addons/bagnon/files/9688481) · 2026-11-18 | All Rights Reserved | BagBrother 동봉은 제작자 설명으로 확인 | 게임 기본 통합 가방 · 제외 유지. 가방 교체보다 필요한 검색 기능의 추가 이득을 먼저 판단 |
| [BagBrother](https://www.curseforge.com/wow/addons/bagbrother) | 10 / — | [12.1.12](https://www.curseforge.com/wow/addons/bagbrother/files/9688476) · 2026-11-18 | All Rights Reserved | Bagnon과 Bagnonium의 동봉 엔진. 별도 설치 필요 없음 | 게임 기본 가방 · 의존 유지. Bagnon을 쓰지 않으면 이번 기본 구성에 추가할 이유 없음 |
| [Leatrix Maps](https://www.curseforge.com/wow/addons/leatrix-maps) | 11 / — | [1.60.32-forever](https://www.curseforge.com/wow/addons/leatrix-maps/files/9676913) · 2026-11-18 | All Rights Reserved | 별도 필수 미확인 | 게임 기본 세계지도 · 제외 유지. 기본 지도 유지 결정과 대조 |
| [TomTom](https://www.curseforge.com/wow/addons/tomtom) | 12 / 13 | [v4.4.1-release](https://www.curseforge.com/wow/addons/tomtom/files/9493883) · 2026-11-07 | All Rights Reserved | 별도 필수 미확인 | 기본 지도·퀘스트 안내 · 제외 유지. 별도 좌표 경로를 요구하는 사용 때 다시 판단 |
| [DBM Dungeons](https://www.curseforge.com/wow/addons/deadly-boss-mods-dbm-dungeons) | 13 / 12 | [DBM-Dungeons-r272](https://www.curseforge.com/wow/addons/deadly-boss-mods-dbm-dungeons/files/9570049) · 2026-11-12 | All Rights Reserved | DBM Core 필수. 정확한 릴리스 파일의 1.60.1 지원 표기 확인 | DBM Core 선택에 따른 콘텐츠 · 의존 유지. 포에버 던전별 경보 구현 범위와 버전을 같이 확인 |
| [What's Training?](https://www.curseforge.com/wow/addons/whats-training) | 14 / — | [11.4.8](https://www.curseforge.com/wow/addons/whats-training/files/9621224) · 2026-11-15 | MIT License | 별도 필수 미확인. 릴리스에 Auctionator 가격 표시 연동 수정 있음 | 전문기술 도안 조회 기능 없음 · 선택 유지. 전문기술 창의 도안·습득 경로 조회를 우선 검토 |
| [Baganator](https://www.curseforge.com/wow/addons/baganator) | 15 / — | [865](https://www.curseforge.com/wow/addons/baganator/files/9689225) · 2026-11-18 | All Rights Reserved | Syndicator 필수. CurseForge 앱 자동 설치 안내 | 게임 기본 통합 가방 · 제외 유지. 분류·부캐 조회의 이득을 기능별로 판단. 느리다고 단정할 근거는 없음 |
| [Plater Nameplates](https://www.curseforge.com/wow/addons/plater-nameplates) | 16 / 10 | [Plater-v664](https://www.curseforge.com/wow/addons/plater-nameplates/files/9628184) · 2026-11-15 | All Rights Reserved | 별도 필수 미확인. 확장 스크립트와 프로필은 별도 범위 | 기본 이름표와 자체 스킨 · 참고 유지. 같은 화면 조건에서 가독성과 설정만 비교 |
| [AtlasLoot Classic Forever](https://www.curseforge.com/wow/addons/atlasloot-forever) | 17 / — | [AtlasLoot Classic Forever 1.4.4-191126-16001.zip](https://www.curseforge.com/wow/addons/atlasloot-forever/files/9693986) · 2026-11-19 | GPLv2 | 내부 구성 모듈의 동봉·필수 구분 미검토 | 던전 드롭 조회 공백, DungeonJournal 후보와 겹침 · 참고 유지. 정확히 이 프로젝트로 비교하고 다른 AtlasLoot 포크와 섞지 않음 |
| [Syndicator](https://www.curseforge.com/wow/addons/syndicator) | 18 / — | [291](https://www.curseforge.com/wow/addons/syndicator/files/9632417) · 2026-11-15 | All Rights Reserved | Baganator가 요구하는 별도 재고 데이터 애드온 | 기본 가방 · 의존 유지. Baganator를 제외한 현재 기본 구성의 필수품으로 세지 않음 |
| [OpenMap](https://www.curseforge.com/wow/addons/openmap) | 19 / — | [OpenMap v0.8.10 (WoW Forever)](https://www.curseforge.com/wow/addons/openmap/files/9657589) · 2026-11-17 | MIT License | 별도 필수 미확인 | 게임 기본 세계지도 · 제외 유지. 지도 교체의 추가 이득과 취향이 생기면 비교 |
| [EllesmereUI](https://www.curseforge.com/wow/addons/ellesmereui) | 20 / — | [v9.8.9](https://www.curseforge.com/wow/addons/ellesmereui/files/9679998) · 2026-11-18 | Custom License | 추가 필수 미확인. 별도 Forever Essentials 프로젝트와 구분 | 여러 기존 화면 담당과 겹침 · 참고 유지. 정렬·배율 방식 비교. 추가 비용의 크기는 미측정 |
| [BigWigs](https://www.curseforge.com/wow/addons/bigwigs) | — / 5 | [v427.9](https://www.curseforge.com/wow/addons/bigwigs/files/9516569) · 2026-11-08 | All Rights Reserved | LittleWigs는 별도 던전 플러그인 | DBM의 보스 경보 대안 · 참고 유지. DBM과 비교할 대안으로 두고 필요한 콘텐츠 지원부터 확인 |
| [LittleWigs](https://www.curseforge.com/wow/addons/littlewigs) | — / 8 | [v12.1.23](https://www.curseforge.com/wow/addons/littlewigs/files/9437389) · 2026-11-04 | All Rights Reserved | 제작자 본문에서 BigWigs 필수 명시 | BigWigs 선택에 따른 콘텐츠 · 의존 유지. BigWigs와 묶어 비용·지원 범위를 평가 |
| [Pawn](https://www.curseforge.com/wow/addons/pawn) | — / 9 | [2.14.4 (Forever)](https://www.curseforge.com/wow/addons/pawn/files/9669292) · 2026-11-17 | Custom License | 별도 필수 미확인 | 장비 비교의 게임 기본 정보 · 제외 유지. 가중치 장비 추천을 기본 요구로 넓힐 근거 없음 |
| [GTFO](https://www.curseforge.com/wow/addons/gtfo) | — / 11 | [6.12.4](https://www.curseforge.com/wow/addons/gtfo/files/9695357) · 2026-11-19 | All Rights Reserved | 별도 필수 미확인 | DBM 후보와 위험 상황 알림 일부 겹침 · 선택 유지. 필요한 바닥 경보가 있는지 대상 보스와 알림 중복 확인 |
| [HealBot Continued](https://www.curseforge.com/wow/addons/heal-bot-continued) | — / 14 | [26.11.14](https://www.curseforge.com/wow/addons/heal-bot-continued/files/9606225) · 2026-11-14 | All Rights Reserved | 별도 필수 미확인 | Grid2와 마우스오버 치유 · 제외 유지. 이미 선택한 공격대·치유 조작을 교체할 근거 없음 |
| [Bartender4](https://www.curseforge.com/wow/addons/bartender4) | — / 15 | [4.19.1](https://www.curseforge.com/wow/addons/bartender4/files/9691458) · 2026-11-18 | All Rights Reserved | 별도 필수 미확인 | Dominos 행동 단축바 · 제외 유지. 같은 기능의 단축바 두 벌을 기본에 넣을 이유 없음 |
| [TradeSkillMaster](https://www.curseforge.com/wow/addons/tradeskill-master) | — / 17 | [v4.15.8](https://www.curseforge.com/wow/addons/tradeskill-master/files/9688716) · 2026-11-18 | All Rights Reserved | 데스크톱 가격 공급 경로와 한국 서버 범위는 이번 자료에서 미확인 | 경제·제작 관리 없음, Auctionator 후보와 일부 겹침 · 선택 유지. 제작·재료비·판매를 함께 관리할 필요가 있을 때 확인 |
| [ALL THE THINGS](https://www.curseforge.com/wow/addons/all-the-things) | — / 18 | [5.4.14](https://www.curseforge.com/wow/addons/all-the-things/files/9689417) · 2026-11-18 | All Rights Reserved | 별도 필수 미확인 | 수집 전체 추적 기능 없음 · 제외 유지. 전체 수집 진행은 별도 플레이 목적 |
| [HandyNotes](https://www.curseforge.com/wow/addons/handynotes) | — / 19 | [v1.6.32](https://www.curseforge.com/wow/addons/handynotes/files/9414756) · 2026-11-03 | All Rights Reserved | 콘텐츠별 플러그인은 별도. 필수 관계는 모듈별 미검토 | 기본 지도 · 제외 유지. 개인 지도 메모가 필요할 때 선택 범위에서 다시 판단 |
| [DBM Forever and Vanilla](https://www.curseforge.com/wow/addons/dbm-vanilla) | — / 20 | [DBM-Vanilla_SoD-r835](https://www.curseforge.com/wow/addons/dbm-vanilla/files/9414575) · 2026-11-03 | All Rights Reserved | 제작자 제목·본문에서 DBM Core 필요 명시 | DBM Core 선택에 따른 공격대 콘텐츠 · 의존 유지. 프로젝트명과 파일명의 Vanilla_SoD를 그대로 보존 |

## 우선 후보의 적용 범위

### 퀘스트와 전문기술

Questie 12부터 QuestieDB가 별도 필수 애드온이라는 제작자 설치 안내를 확인했다. CurseForge 배포를 수동으로 설치하면 QuestieDB를 따로 받아야 하고 GitHub 전체 릴리스의 동봉 여부와 구분해야 한다. 이번에 조회한 QuestieDB의 포에버 전용 파일은 `QuestieDB-1.1.3-Forever.zip`이다. 앞선 준비 기록에서 확인한 Questie 자체 추적기 설정과 미수락 퀘스트 표시의 분리 경로를 재사용한다. 0.1.1에 현재 들어간 목표 추적은 게임 기본이며, 과거 Kaliel's Tracker 후보의 미채택 기록과도 맞는다. [제작자 설치 안내](https://github.com/Questie/Questie) · [QuestieDB 포에버 파일](https://www.curseforge.com/wow/addons/questiedb/files/9687647) · [앞선 확인](Step%2060%20%E2%80%94%20상위%20애드온%201차%20등급과%20자체%20성능%20검수.md)

What's Training?은 제작자가 포에버 전문기술 창에 트레이너, 드롭, 퀘스트 등에서 얻는 도안 목록을 추가했다고 설명한다. 일반 전문기술의 도안 확인을 우선 요구로 두면 이 후보를 먼저 비교할 이유가 있다. TradeSkillMaster는 제작부터 거래까지 관리하는 범위가 더 넓다. 가격 공급용 데스크톱 경로와 한국 서버의 지원 범위는 이번 조회만으로 확인하지 못했으므로 전제에 넣지 않는다. 두 애드온 모두 실제 전문기술 창 처리 시간은 미검증이다. [What's Training? 설명](https://www.curseforge.com/wow/addons/whats-training) · [11.4.8 변경 기록](https://www.curseforge.com/wow/addons/whats-training/files/9621224) · [TradeSkillMaster 포에버 파일](https://www.curseforge.com/wow/addons/tradeskill-master/files/9688716)

### 던전과 보스 경보

던전 정보를 찾는 DungeonJournal과 전투 경보를 보내는 DBM은 서로 다른 빈 기능을 채운다. 준비 기록의 DungeonJournal ZIP 정적 대조를 재사용하며 이번에 그 79개 Lua 전체를 새로 검수한 것은 아니다. DBM은 프로젝트 전체에 포에버가 표시된 것과 현재 선택 파일의 포에버 태그를 구분했다. 본체는 12.1.23, 던전 콘텐츠는 r272, 포에버·오리지널 공격대 콘텐츠는 r835로 서로 다른 판이다. 각 파일의 포에버 표시가 모든 보스의 맞춤 경보 구현을 보장하지 않는다. [DungeonJournal](https://www.curseforge.com/wow/addons/dungeonjournal/files/9687205) · [DBM Core](https://www.curseforge.com/wow/addons/deadly-boss-mods/files/9587232) · [DBM 던전 파일](https://www.curseforge.com/wow/addons/deadly-boss-mods-dbm-dungeons/files/9570049) · [DBM 공격대 파일](https://www.curseforge.com/wow/addons/dbm-vanilla/files/9414575)

제작자 던전 저장소의 현재 README에는 신규 다섯 던전의 34개 보스 등록에 맞춤 타이머와 경보가 아직 없다는 설명이 남아 있다. 이는 조회한 저장소의 설명이다. 이전에 배포된 r272 파일 안의 모든 보스별 구현을 직접 대조한 결과로 확대하지 않는다. 이 차이는 선택 설치를 결정하기 전, 사용할 실제 던전의 경보 유무를 확인할 이유다. [제작자 던전 저장소](https://github.com/DeadlyBossMods/DBM-Dungeons)

### 경매장

Auctionator 349의 파일은 제작자가 1.60.1 지원을 등록했고 변경 기록에 포에버 가격 데이터의 기존 규칙 가져오기를 적었다. 경매 검색과 시세 조회를 원하면 우선 비교할 수 있다. 앞선 ZIP 확인에서는 실제 경매장 창이 열릴 때 필요한 화면을 만드는 경로가 보였으나, 포에버에서 어떤 화면 처리 경로가 쓰이고 얼마나 걸리는지는 미측정이다. [Auctionator 349 파일과 변경 기록](https://www.curseforge.com/wow/addons/auctionator/files/9690303)

## 판정 보완과 남은 근거

기존 등급은 유지 1개, 선택 7개, 의존 6개, 참고 5개, 제외 11개로 유지했다. 새 기본 포함 권고는 없다. 이는 이번 패키지의 현재 기능과 사용자 선택을 기준으로 한 판단이다. 애드온 전체의 품질 순위를 뜻하지 않는다.

EllesmereUI의 실행 비용이 크다는 기존 표현은 실측 근거가 없다. 현재 담당과의 기능 중복, 전면 교체 비용, 별도 성능 확인 필요로 이유를 좁혔다. Baganator 제작자는 기본 가방 대비 처리 성능 개선을 주장하므로 추가 애드온 개수만으로 더 느리다는 결론도 낼 수 없다. 기본 가방 유지 결정과 실제로 필요한 부캐·검색 기능을 기준으로 제외 판단을 유지한다. 제작자의 성능 주장은 우리 포에버 환경의 측정치로 사용하지 않았다. [EllesmereUI](https://www.curseforge.com/wow/addons/ellesmereui) · [Baganator](https://www.curseforge.com/wow/addons/baganator)

확정한 동봉·필수 관계는 Questie와 QuestieDB, Bagnon과 동봉 BagBrother, Baganator와 별도 필수 Syndicator, BigWigs와 필수 플러그인 관계인 LittleWigs, DBM Core와 그 콘텐츠 모듈이다. 자체 설치 목록의 Details_TinyThreat도 기존 동봉 구성이다. 표의 나머지 행은 외부 라이브러리나 별도 모듈의 부재를 확정하지 않는다. [BagBrother 동봉 안내](https://www.curseforge.com/wow/addons/bagbrother) · [Baganator 필수 안내](https://www.curseforge.com/wow/addons/baganator) · [LittleWigs 필수 안내](https://www.curseforge.com/wow/addons/littlewigs) · [현재 설치 목록](../../Collection/install.json)

Pawn의 Custom License 페이지는 Creative Commons Attribution-NonCommercial-NoDerivs 3.0을 표시한다. EllesmereUI의 Custom License 페이지는 제작자가 명시한 범위 밖 권리를 보유한다고 적는다. 두 페이지의 파일 버전 표시는 별도 캐시에서 예전 판을 보여 주었으므로 최신 파일 버전 근거로 재사용하지 않았다. 표의 버전은 포에버 최근 파일과 연결 주소를 따랐다. [Pawn 라이선스](https://www.curseforge.com/wow/addons/pawn/license) · [EllesmereUI 라이선스](https://www.curseforge.com/wow/addons/ellesmereui/license)

## 읽은 범위와 자체 확인

| 입력 | 읽은 범위와 사용 |
|---|---|
| 발주문 | 역할·신규 파일 하나·기존 작업 보존·조사 범위 전부 |
| `feedback_full_file_read_required.md` | 1–57행. 첫 출력에서 본문 전부 확인 |
| `feedback_unit_loop.md` | 1–73행. 큰 묶음 출력에서 잘린 구간을 단독 재조회해 전부 확인 |
| `feedback_flow_interruption.md` | 1–66행. 단독 조회에서 전부 확인 |
| `2026-11-19-devil-forever-addon-adoption-plan.md` | 1–140행. 기준표·범위·성능 기준·확인 조건 전부 |
| `2026-11-19-devil-forever-addon-adoption-phase29.1-세부계획.md` | 1–7행 전부 |
| `Step 60 — 상위 애드온 1차 등급과 자체 성능 검수.md` | 1–71행 전부. 앞선 코드 확인·기존 등급과 대조 |
| `Collection/install.json` | 1–93행 전부. 기존 포함 구성과 두 변형 확인 |
| `Collection/data/feature-map.md` | 1–77행 전부. 기존 담당과 후보 기능을 비교 |
| CurseForge 프로젝트 30개 | 각 표 행의 프로젝트 페이지에서 라이선스·포에버 최근 파일 메타데이터 구간을 확인. 실제 파일 클릭 주소를 대조 |
| 제작자 문서 | Questie 설치 README의 데이터 분리 설명, DBM 던전 README의 신규 콘텐츠 제한, LittleWigs의 BigWigs 요구, BagBrother의 동봉 설명, Baganator의 Syndicator 요구, What's Training?의 전문기술 설명 |

후보별 자연 단위에서 공식 페이지를 읽고 버전·날짜·필수 관계를 표로 구성한 뒤 기존 기능·등급과 대조했다. 표 완성 뒤 실제 기계 확인은 종료 코드 0이었다. 고유 프로젝트 30개, 순위 항목 40개, 두 순위의 1–20 각각 누락·중복 0개, 준비 기록과 순위 불일치 0개, 공식 프로젝트 주소 30개, 공식 파일 주소 30개, 라이선스 표기 30개, 한자 문자 0개다. 등급 개수는 유지 1·선택 7·의존 6·참고 5·제외 11이다. 이 자체 확인은 실제 클라이언트 로드 시험과 성능 측정을 포함하지 않는다.

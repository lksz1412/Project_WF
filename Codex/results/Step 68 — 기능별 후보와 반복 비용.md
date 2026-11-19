# Step 68 — 기능별 후보와 반복 비용

2026-11-19 · Phase 29.4 · 비교 목록 4–11

| 순서 | 지금 쓰는 기능과 후보 | 확인 결과와 판단 |
|---:|---|---|
| 4 | Quartz · Grid2와 공격대 대안 VuhDo | Quartz 시전바는 활성 시전·채널과 종료 처리에서 프레임 갱신을 쓴다. 시전 시간의 정확성이 필요하므로 겹치는 시전바를 끄는 것이 우선이다. Grid2 설정은 필요할 때 불러오고 자체 기본 프리셋은 공격대에만 표시한다. VuhDo는 포에버 로드 목록이 있고 설정 패키지까지 기본 로드 표기다. 같은 공격대 지표와 클릭 기능을 쓴 실행 근거가 생길 때 비교하며 현재는 Quartz와 Grid2 유지 |
| 5 | Dominos · Masque와 Bartender4 | 두 단축바 모두 소환수 바를 별도 처리한다. Dominos에서 자체 외관 반복은 0.1.2에서 이미 줄였다. Bartender4 4.19.0의 클래식 소환수 키 재지정에서 버튼마다 조회 결과를 한 번 꺼내 쓰는 실험은 키 20개를 동일 순서로 저장하고 조회를 30회에서 10회로 줄였다. 키 변경 경로이므로 전투 중 상시 비용으로 잡지 않는다. 기존 배치와 외관이 확보된 Dominos와 Masque 유지 |
| 6 | SexyMap · Experience Forever · ProfileManager | SexyMap 좌표를 끈 다음에도 10초 동안 위치 조회가 10회 있었다. 타이머를 취소한 대역에서 0회, 다시 켠 뒤 5초 동안 양쪽 모두 5회였고 예약은 1개였다. Experience Forever는 한 화면 갱신 전에 퀘스트 알림 12개와 퀘스트 20개를 받아 목록 읽기 240회, 화면 갱신 1회였다. 목록 읽기도 같은 시점에 묶으니 20회, 화면 갱신 1회, 경험치 11,000으로 같았다. ProfileManager의 확인 지점은 로그인 시 대기 프로필 적용과 초기 진입 캐릭터 등록이다. 좌표 타이머와 경험치 목록부터 개선 후보로 둔다 |
| 7 | DungeonJournal과 AtlasLoot Classic Forever | 던전 퀘스트와 드롭을 같이 찾을 때 DungeonJournal, 드롭만 볼 때 AtlasLoot를 우선 비교한다. DungeonJournal은 기존 코드 확인에서 이벤트가 여러 번 와도 퀘스트 글자 갱신을 묶고, 초상화 대기가 없으면 갱신 프레임을 숨겼다. AtlasLoot 1.4.4의 포에버 파일은 확인했다. 압축 크기는 실행 시간과 따로 본다. 동일 보스 자료의 완전성과 창 열기 전 실행이 남은 비교 조건이다 |
| 8 | Auctionator와 TradeSkillMaster | Auctionator 349는 경매장 상호작용에서 화면 입구를 만드는 코드 확인 이력이 있다. 검색·단가는 Auctionator가 우선 후보이고 제작 비용과 거래 기록까지 필요하면 TradeSkillMaster를 비교한다. 가격 자동 공급은 별도 연동이므로 검색과 전체 스캔을 같은 시험값으로 합치지 않는다 |
| 9 | DBM과 BigWigs · LittleWigs | 정확한 후보 버전의 포에버 지원 표기를 다시 확인했다. DBM 던전 제작자 문서는 신규 던전 다섯 곳의 등록과 일반 잡몹 지원, 맞춤 보스 경보 공백을 명시한다. BigWigs 릴리스에는 포에버 유닛 이름 처리와 특정 콘텐츠 변경이 있다. 실제로 갈 우두머리의 맞춤 경보를 먼저 고르고 그때 본체와 필요한 콘텐츠 한 조합만 비교한다 |
| 10 | 게임 기본 지도·목표 창과 Questie · QuestieDB | 미수락 퀘스트 지도 정보만 선택 기능으로 남긴다. Questie 12.10.0 로컬 원문에서 반복 목표 추적 요청 하나로 묶기와 로딩 실패 때 재시도 간격 늘리기를 확인했다. 12.11.0의 실제 표시 범위는 이전 버전 코드를 그대로 일반화하지 않는다. 자체 목표 창과 아이콘 중복을 끄는 기존 설정과 QuestieDB의 정확한 판을 비교 전에 확인한다 |
| 11 | 전문기술 기본 창과 What's Training? | 포에버용 도안·습득처 조회는 What's Training?을 선택 후보로 두었다. 앞선 공개 ZIP 확인에서 게임패드 처리와 트레이너 창 감시가 있었다. 키보드 상태에서 남는 작업과 도안 목록을 처음 열 때의 비용을 실제 확인한다. 거래 가격과 전문기술 정보가 모두 필요한 경우에는 목록 8과 겹치는 창을 따로 확인한다 |

## 근거

- 미니맵 대안 BasicMinimap 12.1.6의 클래식 좌표 코드도 확인했다. 숨겨진 좌표의 상세 위치 계산은 건너뛰지만 지도 확인과 5초 재예약은 이어진다. SexyMap에서 검증한 변경안은 좌표 표시를 끈 동안 예약 자체를 취소한다. [BasicMinimap 좌표 코드](../../Collection/upstream/basic-minimap-v12.1.6/BasicMinimap/BasicMinimap_Classic.lua#L524)
- Quartz CastBarTemplate 102행 이후와 등록부 1255행, Grid2 GridFrame 209–218행과 Grid2Options의 로드 선언, [공격대 기본값](../../Collection/AddOns/!DevilForever_Core/Defaults/Grid2.lua), [VuhDo 포에버 로드 목록](../../Collection/upstream/vuhdo-v3.221/VuhDo/VuhDo_Camelot.toc).
- Bartender4 PetBar 전문의 키 재지정과 소환수 이벤트. 동봉 Dominos의 버튼 연결과 재구성, Step 65의 실제 소환수 버튼 시험. [Bartender4 PetBar](../../Collection/upstream/bartender4-4.19.0/Bartender4/PetBar.lua#L67)
- SexyMap 좌표 옵션 19–32행 및 226–359행. Experience Forever 초기화 373–447행, 갱신·경험치 831–866행, 진입과 레벨 변화 1273–1305행. ProfileManager 초기 진입 317–355행. [지도와 경험치 대역](../../_local_only/perf-review-29.4/minimap-and-xp.json)
- DungeonJournal, Auctionator, Questie, What's Training?의 정확한 배포 판과 기존 소스 확인 범위는 [Step 60 순위와 성능 검토](Step%2060%20%E2%80%94%20상위%20애드온%201차%20등급과%20자체%20성능%20검수.md)와 [Step 61 선택 설치](Step%2061%20%E2%80%94%20최소%20선택%20설치%20구성.md)에 있다. [DungeonJournal 2.0.12](https://www.curseforge.com/wow/addons/dungeonjournal/files/9687205) · [AtlasLoot 1.4.4](https://www.curseforge.com/wow/addons/atlasloot-forever/files/9693986) · [Auctionator 349](https://www.curseforge.com/wow/addons/auctionator/files/9690303)
- 경보는 제작자 문서와 파일 표기까지 확인했다. 게임 안 우두머리 대응 일치와 성능은 미측정이다. [DBM 던전 원본](https://github.com/DeadlyBossMods/DBM-Dungeons) · [BigWigs v427.9](https://www.curseforge.com/wow/addons/bigwigs/files/9516569) · [LittleWigs v12.1.23](https://www.curseforge.com/wow/addons/littlewigs/files/9437389)
- Questie 로컬 이벤트 파일 61–121행, 최신 비교판의 변경 기록, What's Training? 비교 파일을 확인했다. [Questie 12.11.0과 QuestieDB 1.1.3 변경 기록](https://www.curseforge.com/wow/addons/questie/files/9687964) · [What's Training? 11.4.8](https://www.curseforge.com/wow/addons/whats-training/files/9621224)
- TradeSkillMaster 4.15.8의 포에버 마법부여 스캔 수정과 검색 관련 개선 표기는 제작자 변경 기록에 있다. 같은 품목과 창에서 실행한 성능 수치는 확보하지 않았다. [TradeSkillMaster 4.15.8](https://www.curseforge.com/wow/addons/tradeskill-master/files/9688716)

새 AtlasLoot ZIP 직접 확보는 로컬 도구에서 호스트를 찾지 못했다. 해당 후보의 새 코드 실행 근거는 없다. 표의 수치는 원래 소스를 Lua 대역에서 실행한 조회와 호출의 개수다.

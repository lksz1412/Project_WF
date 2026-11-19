# 아스트라 6.2의 0.1.4 재검수

2026-11-20 · 기본 PitBull4, FUF, 한 접속 비교판. 코드 비용과 플레이 범위를 같은 독립 세션에 차례로 맡겼다.

## 코드와 실행 비용

| 우선순위 | 확인 결과 | 보완 방향 |
|---|---|---|
| 중간 · TinyThreat | `HIDE`에서 타이머를 취소한 뒤 다음 전투 이벤트가 숨은 상태의 타이머를 다시 시작한다. 실제 ZIP Lua에서 40명과 1초 타이머 30번을 넣었을 때 위협 조회 1,200회였다. | 전투 중이며 위협 창이 표시될 때만 조회한다. 창을 다시 열거나 모드를 전환하는 경로를 확인한다. [숨김과 전투 이벤트](../../Collection/AddOns/Details_TinyThreat/Details_TinyThreat.lua#L90) · [타이머 재시작](../../Collection/AddOns/Details_TinyThreat/Details_TinyThreat.lua#L908) |
| 중간 · PitBull4 | 보이는 파생 유닛 프레임 5개를 두고 2초를 한 프레임에 전달하면 식별자 조회 66회가 몰렸다. 같은 시간을 120프레임으로 나누면 프레임당 최대 1회였다. | 한 프레임에서 각 유닛을 한 번만 확인하는 방법을 검토한다. 실제 프레임 그리기 호출 수와 식별자 조회 수를 따로 검증한다. [갱신 콜백](../../Collection/AddOns/PitBull4/Main.lua#L1893) |
| 중간 · ExperienceForever | 변화가 없는 Lua 시험에서 타이머 30회가 글자 설정 270회, 막대 값과 범위 쓰기 180회, 평판·테두리 처리 각각 30회를 불렀다. | 시간 표시와 경험치·평판·테두리의 갱신 조건을 나눈다. [타이머](../../Collection/AddOns/ExperienceForever/ExperienceForever.lua#L444) · [글자와 테두리](../../Collection/AddOns/ExperienceForever/ExperienceForever.lua#L1179) |
| 중간 · ProfileManager | 로그인과 애드온 로드마다 전체 프로필 공급자를 다시 찾는다. 코드상 각 루트 데이터베이스의 예외 검사에 최대 86개 이름을 조회한다. | 이어지는 로드 이벤트를 묶고, 설정 창을 열 때 필요한 공급자가 즉시 보이는지 확인한다. [예외 검사](../../Collection/AddOns/ProfileManager/Providers.lua#L443) · [재탐색 이벤트](../../Collection/AddOns/ProfileManager/Providers.lua#L3129) |
| 경미 · 외관 | 합성판이 표시되는 경로에서 개별 텍스처 31개를 먼저 표시했다가 같은 호출에서 숨겼다. 로그인과 테마·배율 변경의 비용이다. | 합성판이 성공하면 뒤에 가려지는 그리기를 생략하는 방법을 검토한다. [외관 적용](../../Collection/AddOns/DevilForever_Appearance/Appearance.lua#L163) · [합성판 처리](../../Collection/AddOns/DevilForever_Appearance/Composition.lua#L121) |

기본판은 35개 폴더이며 12개가 필요할 때 로드를 선언한다. 압축을 푼 애드온 파일의 약 82%는 외관 폴더 용량이다. 검수 수치는 디스크 용량, 코드 경로, Lua 시험의 호출 횟수다. 실제 프레임 시간과 메모리는 게임에서 따로 측정한다. 전투 중 새 이름표는 보호된 프레임 수정을 피하려고 처리를 미룬다. 잠깐 나타나는 적의 이름표 크기까지 실제 화면에서 확인한다.

## 플레이 범위

| 플레이 | 판단 |
|---|---|
| 일반 성장과 일상 | 기본 지도·목표창·가방과 자체 채팅 배치를 유지한다. 미수락 퀘스트 위치가 필요한 경우 Questie와 포에버용 QuestieDB를 선택한다. [Blizzard 기본 기능](https://worldofwarcraft.blizzard.com/en-us/news/24315821/) · [포에버 사용자 사례](https://www.reddit.com/r/wowaddons/comments/1xp4lyn/what_addons_are_you_using_in_wow_forever/) |
| 던전과 공격대 | 선행 퀘스트와 드롭이 필요한 사람은 DungeonJournal을 선택한다. 경보는 참여할 보스의 지원을 확인하고 DBM 또는 BigWigs 계열 중 하나를 쓴다. 제작자가 열거한 신규 던전 다섯 곳의 DBM 모듈은 전투 등록과 일반 몹 지원까지만 제공한다. [DungeonJournal](https://www.curseforge.com/wow/addons/dungeonjournal) · [DBM 제작자 기록](https://github.com/DeadlyBossMods/DBM-Dungeons/blob/master/README.md) |
| 힐러 | 5인 PitBull4와 공격대 Grid2에서 기본 클릭 시전, 마우스오버, 해제 표시를 실전 확인한다. 필요한 입력이 기본 경로에서 부족하면 Clique를 선택 비교한다. [Grid2 초기 설정](../../Collection/AddOns/!DevilForever_Core/Defaults/Grid2.lua#L13) · [Clique 배포판](https://www.curseforge.com/wow/addons/clique/files/all) |
| 경매와 전문기술 | Auctionator와 What's Training?을 각 목적에 맞춰 선택한다. 반복 채광·약초의 위치 기록은 기존 선택 목록에도 없다. GatherMate2를 선택 후보로 두고 한국어 인식과 지도 표시를 확인한다. [훈련과 도안](https://www.curseforge.com/wow/addons/whats-training) · [GatherMate2 포에버 파일](https://www.curseforge.com/wow/addons/gathermate2/files/9600843) |
| 접근성 | 4K 목표 글자와 지상의 작은 퀘스트 물체는 별개로 확인한다. 물체가 배경에 묻히면 게임 기본 강조 표시와 Forever Loot Sparkles를 비교한다. [플레이어 사례](https://eu.forums.blizzard.com/en/wow/t/accessibility-request-better-visibility-for-quest-items-in-wow-forever/629768) · [제작자 설명](https://github.com/svengabr/ForeverLootSparkles) |

일상·레벨링·일반 5인 기준에서 기본에 추가할 애드온은 0개로 판단했다. 위 선택은 공개 사례와 배포 근거에 따른 후보 평가다. 게임 안 실행이나 포에버 이용자 전체의 사용 비율은 확인하지 못했다.

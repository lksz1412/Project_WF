# Codex 실사용 검증 발주문 — Phase 9 (공격대 프레임 · Grid2 4.1.13-forever)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/grid2` 입력은 모두 사람이 하듯 직접 한다. 프레임의 자리·크기·질감·글꼴은 이 Phase 에서 보지 않는다(외관 단계 몫).

- 결과를 올릴 자리: `References/codex-verify/phase9/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 셋:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core`·`DevilForever_FUFDefaults` 둘만 넣는다).
  - Grid2 원본 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`, sha256 `f198bc3ce2d02e023f81052074a2e9aa4ba41819931bd302ff7429dac9515393`. 안의 `Grid2`·`Grid2Options`·`Grid2LDB` 세 폴더.
  - FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`, sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`. 안의 `ForeverUnitFrames` 폴더 하나(파티 프레임 담당).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 담당 나눔: **공격대는 Grid2, 파티·혼자는 unit 프레임 애드온(FUF)**. 우리 기본값(`!DevilForever_Core` 의 `Defaults/Grid2.lua`)은 새 Grid2 프로필에만 들어간다: 혼자·파티·투기장 배치 「None」, 창 표시 「Raid」(공격대일 때만 보임), 블리자드 공격대 프레임 숨김. 역할·해제 가능 디버프·버프(지속 치유) 표시는 Grid2 가 처음 켜질 때 띄우는 자체 프로필 고르기 창에서 고른 틀이 정한다 — 우리는 바꾸지 않는다. 클릭 시전 기능은 넣지 않는다(R97 — 사용자는 마우스오버 매크로로 치유한다). Grid2 단추의 클릭은 Grid2 기본 그대로다(왼쪽 = 대상 잡기, 오른쪽 = 메뉴). FUF 공격대 프레임은 `DevilForever_FUFDefaults` 가 Grid2 가 켜진 캐릭터에서 한 번 끈다(Phase 6).
- 공격대가 필요한 항목(4–6)은 두 사람 이상 파티를 공격대로 바꾸면 된다. 공격대를 짤 수 없으면 그 항목은 `못 함` 으로 적는다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase9/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 세 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_FUFDefaults`, `ForeverUnitFrames`, `Grid2`, `Grid2Options`, `Grid2LDB`)가 있으면 백업 쪽으로 옮긴 뒤 이 여섯 폴더를 넣는다. 다른 unit 프레임·공격대 프레임 애드온(PitBull4·VuhDo 등)이 켜져 있으면 백업 쪽으로 옮긴다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/` 의 `Grid2.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 셋 다 같고, 여섯 폴더가 설치되고, `Grid2.lua` 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/Grid2/FUF)=<예·예·예> | 넣은 폴더=<목록> | 옮긴 애드온=<목록/없음> | Grid2.lua 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드·처음 켜짐 창·기본값 상태

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Grid2·Grid2 Options·Grid2 LDB·DevilForever Core 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 혼자 접속한다. Grid2 의 프로필 고르기 창(「Welcome to Grid2 …」)이 뜨면 「Modern」 을 고르고 확인한다. 30초 기다린 뒤 `/run local s=DevilForever_Core.Defaults:GetStatus("Grid2"); for k,v in pairs(s.targets) do print(k, v.state) end` 와 `/run print(#DevilForever_Core:GetFrameNames("Grid2"), DevilForever_Core:GetAddonInfo("Grid2").defaults)` 를 친다. `/bugsack` 을 열고 `Grid2`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase9/bugsack.txt` 에 복사한다.
- 기대 결과: 넷 다 「사용 가능」, 프로필 고르기 창이 한 번 뜬다, 첫 출력 두 줄 `Grid2DB applied`·`Grid2DB/Grid2Layout applied`(순서 무관), 둘째 출력 `1 Defaults/Grid2.lua`, 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 고르기 창=<뜸·Modern 고름/안 뜸/다른 결과> | 첫 출력=<줄들> | 둘째 출력=<줄> | 오류 수=<n>`

## 2. 들어간 값

- 하는 법: `/run local p=Grid2.db.profile; local l=Grid2Layout.db.profile; print(p.hideBlizzard and p.hideBlizzard.raid, l.layouts.solo, l.layouts.party, l.layouts.arena, l.layouts.raid, l.FrameDisplay, Grid2.db:GetCurrentProfile())` 를 친다.
- 기대 결과: `true None None None By Group Raid <이름> - <서버>`.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 출력=<줄>`

## 3. 혼자·파티에서는 Grid2 가 안 보임

- 하는 법: 혼자일 때 화면에 Grid2 창(작은 상자 포함)이 있는지 본다. 파티를 짜고(두 사람 이상) 보이는 파티 프레임을 모두 센다: FUF 파티 프레임, Grid2 단추, 블리자드 파티 프레임. `/run print(Grid2:GetGroupType(), Grid2LayoutFrame:IsShown())` 를 친다.
- 기대 결과: 혼자일 때 Grid2 창 없음, 파티에서 FUF 파티 프레임만 보인다, 출력 `party <…> false`.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 혼자 Grid2=<안 보임/보임> | 파티에서 보인 프레임=<목록/파티 없음> | 출력=<줄>`

## 4. 공격대에서는 Grid2 하나

- 하는 법: 파티를 공격대로 바꾼다. 보이는 공격대 프레임을 모두 센다: Grid2 단추, FUF 공격대 프레임, 블리자드 공격대 프레임(화면 왼쪽 위 칸들과 왼쪽 가장자리 공격대 관리 판). `/run print(Grid2:GetGroupType(), Grid2LayoutFrame:IsShown(), CompactRaidFrameContainer and CompactRaidFrameContainer:IsShown(), CompactRaidFrameManager and CompactRaidFrameManager:IsShown())` 를 친다. 블리자드 공격대 관리 판이 숨으면서 그 안의 공격대 도구(전장 표식·준비 확인 단추 등)를 쓸 곳이 없어졌는지 적는다.
- 기대 결과: 공격대원 모두가 Grid2 단추로 보이고 FUF 공격대 프레임·블리자드 공격대 프레임은 없다. 출력 `raid <…> true false false`(클라이언트에 블리자드 공격대 프레임이 없으면 `nil nil`).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 보인 공격대 프레임=<목록/공격대 없음> | 출력=<줄> | 블리자드 공격대 도구=<숨음/보임/원래 없음>`

## 5. Grid2 표시 의미 (Grid2 가 준 그대로)

- 하는 법: 공격대에서 본다 — 역할 아이콘(파티 찾기로 역할이 정해진 경우), 체력 막대가 맞을 때 줄어듦, 40미터 밖 공격대원이 흐려짐, 내가 해제할 수 있는 디버프가 걸린 공격대원의 테두리 색, 내가 건 지속 치유·버프 아이콘. 할 수 있는 것만 본다.
- 기대 결과: 위 다섯이 보인다. 이 Phase 는 의미를 바꾸지 않았다 — 안 보이는 것은 그대로 적는다(Grid2 쪽 결과).

결과 한 줄 양식: `5 | <통과/실패/못 함> | 역할=<보임/안 보임/못 봄> | 체력=<됨/안 됨> | 거리 흐림=<됨/안 됨/못 봄> | 해제 디버프 테두리=<보임/안 보임/못 봄> | 지속 치유 아이콘=<보임/안 보임/못 봄>`

## 6. 마우스오버 매크로로 치유 (R97)

- 하는 법: 사용자가 쓰는 마우스오버 치유 매크로가 있으면 그것을 쓴다. 없으면 임시 매크로 `DFTEST` 를 만든다: `/cast [@mouseover,help,nodead][] <치유 주문 이름>`, 그리고 두 번째 임시 매크로 `DFTEST2`: `/run local f=GetMouseFocus and GetMouseFocus() or (GetMouseFoci and GetMouseFoci()[1]); print(f and f:GetName(), f and f:GetAttribute("unit"), UnitName("mouseover"))`. 둘을 단축바에 올리고 키를 붙인다. 대상을 나 자신으로 잡은 채, 다른 공격대원의 Grid2 단추에 마우스를 올리고 `DFTEST2` 키를 누른 뒤 치유 매크로 키를 누른다. Grid2 단추를 왼쪽 클릭·오른쪽 클릭도 한 번씩 해 본다. 끝나면 임시로 만든 매크로만 지운다(사용자 매크로는 건드리지 않는다).
- 기대 결과: `DFTEST2` 출력 `Grid2LayoutHeader<n>UnitButton<m> raid<k> <그 공격대원 이름>`, 치유가 마우스를 올린 공격대원에게 들어간다(내 대상은 그대로 나). 왼쪽 클릭 = 그 공격대원이 대상이 됨, 오른쪽 클릭 = 메뉴.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 매크로=<사용자 것/임시> | DFTEST2 출력=<줄> | 치유 대상=<올린 공격대원/다른 결과> | 왼쪽/오른쪽 클릭=<대상·메뉴/다른 결과> | 임시 매크로 지움=<예/만들지 않음>`

## 7. 다른 캐릭터·사용자 값 유지

- 하는 법: 같은 계정의 다른 캐릭터로 접속한다(프로필 고르기 창이 뜨면 「Modern」). 2번의 `/run` 줄을 친다. 다시 처음 캐릭터로 접속해 `/grid2` 설정 창에서 파티일 때의 배치를 「By Group」 으로 바꾸고 창을 닫는다. `/reload` 뒤 1번 첫 `/run` 줄과 2번 `/run` 줄을 친다. 끝나면 파티 배치를 「None」 으로 되돌린다.
- 기대 결과: 다른 캐릭터도 2번과 같은 값(프로필 이름만 그 캐릭터). 처음 캐릭터는 reload 뒤 상태 `already` 두 줄, 2번 출력의 파티 칸이 `By Group`(사용자가 바꾼 값이 남는다).

결과 한 줄 양식: `7 | <통과/실패/못 함> | 다른 캐릭터 2번 출력=<줄/캐릭터 없음> | reload 뒤 상태=<줄들> | reload 뒤 2번 출력=<줄> | 되돌림=<예/아니오>`

## 8. 끄기

- 하는 법: 애드온 창에서 Grid2 를 끄고 접속한다(Grid2 Options·LDB 는 의존이라 함께 로드되지 않는다). 공격대가 있으면 보이는 공격대 프레임을 센다. 파티에서 파티 프레임을 센다. 끝나면 Grid2 를 다시 켠다.
- 기대 결과: Grid2 가 없고 오류 0. 공격대 프레임은 블리자드 공격대 프레임이 다시 보인다(FUF 공격대는 Phase 6 에서 꺼 둔 그대로 — 다르면 적는다). 파티는 FUF 파티 프레임 그대로.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 공격대 프레임=<목록/공격대 없음> | 파티 프레임=<목록/파티 없음> | 오류 수=<n>`

## 9. 재접속·결과 올리기

- 하는 법: `/reload` 뒤 2번 줄을 다시 치고, 공격대가 있으면 4번처럼 센다. 몹과 전투를 시작해 전투 중 공격대원이 들어오거나 나갈 때 Grid2 단추가 따라 바뀌는지 본다(할 수 있으면). `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Grid2`·`ForeverUnitFrames`·`DevilForever` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase9/result.md` 에 순서대로 적고 필요한 화면 갈무리(혼자·파티·공격대 하나씩)와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고 0 에서 옮긴 폴더·저장 파일을 되돌린다.
- 기대 결과: reload 뒤 2번과 같은 출력, 공격대에서 Grid2 하나, 오류 0, `References/codex-verify/phase9/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | reload 뒤 출력=<줄> | 전투 중 명단 바뀜=<따라 바뀜/다른 결과/못 봄> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오> | 커밋=<해시>`

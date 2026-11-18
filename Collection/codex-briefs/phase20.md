# Codex 실사용 검증 발주문 — Phase 20 (설정 저장·복원 · DevilForever Core + ProfileManager)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/dfp`·`/pm` 입력은 모두 사람이 하듯 직접 한다. 겉보기(자리·크기·질감·글꼴)는 이 Phase 에서 보지 않는다.

- 결과를 올릴 자리: `References/codex-verify/phase20/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 대화창에 찍힌 `[DF 설정]` 줄은 항목마다 `chat.md` 에 그대로 옮긴다.
- 설치 ZIP:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `b6392ea37d7cfefa123a3ef023ded82990c1be27826af6f54e23abc6bafd51c1` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core` 하나만 넣는다).
  - ProfileManager 원본 `References/addon-sources/profilemanager/ProfileManager.zip`, sha256 `f905c4381473a7cb6e033e89aa1878177d996ca965d167cd5fdbf086c8c9f2b1`. 안의 `ProfileManager` 폴더 하나.
  - Dominos `References/forever-addons/Dominos/Dominos-12.0.4.zip`(sha256 `2dbcf9857a91b772a42200369386fc17f875530ffd47984b555ecdb8e11bef1a`, `Dominos`·`Dominos_Config`·`Dominos_Cast`), Details `References/forever-addons/Details/Details-Details.20261109.15410.172.zip`(sha256 `5002bdd5c3e92dd59bffa3ebdfc867f980b09ed629c51dab056fb5442f92ad41`, `Details`·`Details_TinyThreat`), Grid2 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`(sha256 `f198bc3ce2d02e023f81052074a2e9aa4ba41819931bd302ff7429dac9515393`, `Grid2`·`Grid2Options`·`Grid2LDB`), SexyMap `References/forever-addons/SexyMap/SexyMap-v12.1.7.zip`(sha256 `1868eb714b8c9ea4efaa615109bfd457a0c3bb625f0b2a1f1befdadfc9143321`, `SexyMap`).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 구성: 설정 저장·복원은 Core 안의 새 부분이 맡는다(명령 `/dfp`, 길게 `/dfprofile`). 등록 표가 고른 저장 변수만 다룬다 — Dominos(직업별 profile), Details(설정 부분만), Grid2, SexyMap 이 이번 검증 대상이다. 키 설정과 게임 설정은 ProfileManager 가 맡고, `/dfp keys …`·`/dfp game …` 을 칠 때만 ProfileManager 를 부른다. 매크로는 아무것도 다루지 않는다.
- 저장·되돌리기는 두 단계다: `/dfp save <이름>` 이나 `/dfp restore <이름>` 은 예약만 하고, `/dfp go` 가 UI 를 다시 불러온다. 다시 불러온 뒤 각 애드온이 자기 값을 읽기 전에 Core 가 저장하거나 쓴다. `/dfp go` 없이 `/reload` 하거나 다시 접속하면 예약은 쓰이지 않고 남는다(`/dfp go` 또는 `/dfp cancel` 을 기다린다). 예약은 같은 캐릭터에서 `/dfp go` 뒤 600초 안에만 쓰인다. 다시 불러온 순간 캐릭터 이름을 아직 모르면 저장 예약은 버리고, 되돌리기·preset 예약은 `/dfp go` 뒤 120초 안일 때만 계정 공통 값만 쓴다(캐릭터별 저장 변수·직업별 값·캐릭터에 따라 갈리는 preset 값은 건드리지 않고 「캐릭터를 모름」 줄로 알린다 — 접속 뒤 다시 `/dfp go`). 접속 뒤 캐릭터가 예약한 캐릭터와 다르면 `!! 경고` 줄이 되돌리는 명령과 함께 나온다. 예약만 하고 `/dfp go` 하지 않은 요청은 예약한 캐릭터에게만 알린다. 결과는 다시 불러온 뒤 대화창에 `[DF 설정]` 줄로 나온다.
- 이중 특성(특성 두 벌)을 배운 캐릭터가 있으면 6번을 한다. 없으면 6번은 `못 함` 으로 적는다. 아래 `/run` 줄에서 오류가 나면 그 문구를 결과 줄 마지막 칸에 적고 다음으로 간다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase20/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 여섯 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에서 `BugSack`·`!BugGrabber` 를 뺀 모든 애드온 폴더를 백업과 다른 폴더 `forever_moved_phase20/AddOns` 로 옮긴다(다른 애드온이 섞이지 않게 — 지우지 않는다. 백업 폴더에는 아무것도 더 넣지 않는다). 그 뒤 위 ZIP 들에서 적힌 폴더만 넣는다: `!DevilForever_Core`, `ProfileManager`, `Dominos`·`Dominos_Config`·`Dominos_Cast`, `Details`·`Details_TinyThreat`, `Grid2`·`Grid2Options`·`Grid2LDB`, `SexyMap`. BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 여섯 모두 같고, AddOns 에 위 열한 폴더와 `BugSack`·`!BugGrabber` 만 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치=<여섯 모두 예/다른 것 이름> | 옮긴 애드온 수=<n>(옮긴 곳=<경로>) | AddOns 남은 폴더=<목록> | BugSack 켜짐=<예/아니오>`

## 1. 로드 · 처음 상태 · 키 설정·매크로 기준값

- 하는 법: 캐릭터 선택 화면 애드온 창에서 넣은 애드온이 모두 「사용 가능」 인지 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속한다. `/dfp help` 를 쳐서 명령 목록이 나오는지 본다. 다음 세 줄을 차례로 친다:
  `/run local C=DevilForever_Core print(C.Profiles~=nil,C.Presets~=nil,C.Spec~=nil,(C_AddOns and C_AddOns.GetAddOnMetadata)~=nil,GetPhysicalScreenSize~=nil,C.Presets:GetActive())`
  `/dfp status`
  `/run local n,s=GetNumBindings(),0 for i=1,n do for _,v in ipairs({GetBinding(i)}) do if type(v)=="string" then for j=1,#v do s=(s*31+v:byte(j))%1000003 end end end end print(n,s,GetNumMacros())`
  셋째 줄의 출력(키 설정 수·키 설정 지문·매크로 수 두 개)을 「기준값」 으로 적어 둔다 — 8번에서 같은 줄로 비교한다.
- 기대 결과: 첫 출력 `true true true <true/false> <true/false> nil false`(넷째·다섯째 값은 이 클라이언트에 그 함수가 있는지 — 보인 그대로 적는다. 마지막 둘은 등록된 겉보기 preset 이 아직 없어서 `nil false`). `/dfp status` 에 `preset: 없음`, `기다리는 요청: 없음`, `저장본: 0/10` 이 보인다. 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 첫 출력=<줄> | status=<줄들 요약> | 기준값=<셋째 출력> | 오류 수=<n>`

## 2. 표시값을 넣고 저장

- 하는 법: 네 애드온 설정에 표시값을 넣는다(Dominos 는 지금 profile, Grid2 는 지금 profile, SexyMap 은 저장 변수 맨 위, Details 는 갱신 간격 값):
  `/run Dominos.db.profile.dfTest=1 Grid2.db.profile.dfTest=1 SexyMap2DB.dfTest=1 Details.update_speed=0.25 print("set")`
  확인 줄(3·4·5번에서도 같은 줄을 쓴다):
  `/run print(Dominos.db.profile.dfTest,Grid2.db.profile.dfTest,SexyMap2DB.dfTest,Details.update_speed,Dominos.db:GetCurrentProfile())`
  `/dfp save t1` 을 친다(대화창에 저장할 애드온 목록이 나온다). `/dfp go` 를 친다(UI 를 다시 불러온다). 다시 불러온 뒤 대화창의 `[DF 설정]` 줄을 모두 `chat.md` 에 옮긴다. `/dfp list` 를 친다. 확인 줄을 다시 친다.
- 기대 결과: 확인 줄 `1 1 1 0.25 <profile 이름>`(다시 불러온 뒤에도 같음). 저장 보고에 `Dominos DominosDB: 저장`, `Grid2 Grid2DB: 저장`, `SexyMap SexyMap2DB: 저장`, `Details _detalhes_global: 저장`, `Details _detalhes_database: 저장`, 마지막 `t1 저장 끝`(넣지 않은 다른 등록 애드온마다 `애드온이 켜지지 않음 — 이번에 저장 못 함` 줄도 나온다 — 정상). `/dfp list` 에 `t1` 한 줄(날짜·캐릭터·직업·항목 수·KB).

결과 한 줄 양식: `2 | <통과/실패/못 함> | 넣은 뒤 확인=<줄> | 저장 보고=<저장된 애드온 목록/다른 줄> | list=<줄> | 다시 불러온 뒤 확인=<줄>`

## 3. 값을 바꾸고 되돌리기 · 재접속

- 하는 법: 표시값을 바꾼다:
  `/run Dominos.db.profile.dfTest=2 Grid2.db.profile.dfTest=2 SexyMap2DB.dfTest=2 Details.update_speed=0.45 print("set")`
  `/reload` 한 뒤 확인 줄을 친다(바뀐 값이 저장된 것). `/dfp show t1` 을 친다(무엇을 쓸지 미리 보기). `/dfp restore t1` 을 친 뒤 먼저 `/reload` 만 하고 확인 줄을 친다. 그 다음 `/dfp go`. 다시 불러온 뒤 `[DF 설정]` 줄을 옮기고 확인 줄을 친다. 게임을 완전히 종료했다가 다시 접속해 확인 줄을 한 번 더 친다.
- 기대 결과: `/reload` 뒤 `2 2 2 0.45 …`. `show` 에 네 애드온이 `씀` 으로 나온다. 예약 뒤 `/reload` 만 했을 때는 값이 그대로 `2 2 2 0.45 …` 이고 `restore t1: 기다리는 요청(아직 /dfp go 안 함) — 쓰지 않고 남김` 줄이 나온다. 되돌린 뒤 `1 1 1 0.25 …`, 보고에 애드온마다 `되돌림` 과 마지막 `t1 되돌리기 끝 — 되돌리기 전 상태는 __before-restore 에 있음`. 재접속 뒤에도 `1 1 1 0.25 …`. 같은 계정의 다른 캐릭터가 같은 Dominos profile(기본은 직업 이름)을 쓰고 있으면 그 profile 은 건드리지 않고 이 캐릭터 이름의 profile 에 써서 그쪽으로 바꾼다 — 보고에 `profile … 은 다른 캐릭터의 것 — 값을 … profile 에 씀` 줄이 나오고 확인 줄 다섯째 값이 그 이름으로 바뀐다(정상). Details 넷째 값이 `0.45` 로 남으면 「Details 안 됨」 으로 적는다(Details 설정이 `__profiles` 밖에도 있는지 Claude 쪽에서 확인하지 못했다).

결과 한 줄 양식: `3 | <통과/실패/못 함> | 바꾼 뒤=<줄> | show=<줄 요약> | reload 만=<확인 줄·안내 줄> | 되돌린 뒤=<줄> | 보고=<줄 요약> | 재접속 뒤=<줄> | Details=<됨/안 됨>`

## 4. 되돌리기를 다시 되돌리기 (`__before-restore`)

- 하는 법: `/dfp restore __before-restore` 를 치고 `/dfp go`. 다시 불러온 뒤 확인 줄을 친다. 그 다음 `/dfp restore t1` → `/dfp go` 로 다시 1 로 맞춘다.
- 기대 결과: `__before-restore` 를 쓴 뒤 `2 2 2 0.45 …`(3번에서 되돌리기 바로 전 값), 다시 `t1` 을 쓴 뒤 `1 1 1 0.25 …`.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 되돌리기 전 값으로=<줄> | 다시 t1=<줄>`

## 5. 없는 애드온 항목을 남기는지

- 하는 법: 게임을 종료하고 `SexyMap` 폴더를 `forever_moved_phase20/AddOns` 로 옮긴다. 접속해 `/dfp save t1` → `/dfp go`. 보고 줄을 옮긴다. 이어서 `/dfp restore t1` → `/dfp go`, 보고 줄을 옮긴다. 게임을 종료하고 `SexyMap` 폴더를 다시 AddOns 로 넣는다. 접속해 `/dfp show t1` 을 친다.
- 기대 결과: 저장 보고에 `SexyMap SexyMap2DB: 애드온이 켜지지 않음 — 이번에 저장 못 함` 과 `전에 저장한 값을 남김`. 되돌리기 보고에 `SexyMap SexyMap2DB: 애드온이 켜지지 않음 — 저장본 항목은 남기고 저장 변수는 만들지 않음`. SexyMap 을 다시 넣은 뒤 `show` 에 `SexyMap SexyMap2DB — 씀`.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 없을 때 저장 보고=<줄> | 없을 때 되돌리기 보고=<줄> | 다시 넣은 뒤 show=<줄>`

## 6. 특성 전환 (이중 특성)

- 하는 법: 이중 특성을 배운 캐릭터로 접속한다. 특성 바뀜 알림 줄을 켠다(이번 접속에서만 있다):
  `/run local f=CreateFrame("Frame") f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED") f:SetScript("OnEvent",function(_,e,...) print(e,...) end) print(LibStub("LibDualSpec-1.0").currentSpec,Dominos.db:GetCurrentProfile())`
  `/dfp spec` 를 친다. `/dfp spec new` 를 친다. 그 다음 게임 특성 창에서 다른 특성으로 바꾼다. 바꾼 뒤 위 줄의 끝 부분만 다시 친다:
  `/run print(LibStub("LibDualSpec-1.0").currentSpec,Dominos.db:GetCurrentProfile())`
  행동 단축바에 새 profile 이 걸리는지 본다(새 profile 은 지금 profile 의 복사본이라 처음에는 모습이 같다 — 바뀐 특성에서 단축바 하나를 Dominos 설정으로 옮긴 뒤 원래 특성으로 돌아가 자리가 따로 남는지 본다). 원래 특성으로 돌아가 다시 친다.
- 기대 결과: 처음 출력 `<1 또는 2> <profile 이름>`. `spec new` 보고 `Dominos DominosDB: 1번 특성 = <이름>, 2번 특성 = <이름> (2)`(번호는 지금 특성에 따라). 특성을 바꾸면 `ACTIVE_TALENT_GROUP_CHANGED …` 줄이 찍히고, 출력의 profile 이름이 `<이름> (2)` 로 바뀐다. 옮긴 단축바 자리는 그 특성에만 남는다. 돌아가면 원래 이름. 알림 줄이 안 찍히거나 이름이 안 바뀌면 보인 그대로 적는다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 처음=<줄> | spec new=<줄> | 바꾼 뒤=<알림 줄·출력> | 단축바 자리=<따로 남음/같이 바뀜> | 돌아온 뒤=<줄> | 이중 특성 캐릭터=<있음/없음>`

## 7. 겉보기 preset 층 (Core 값만)

- 하는 법: 아직 FHD·QHD·UHD preset 파일이 없다(외관 발주 뒤에 들어온다). 그래서 시험용 preset 하나를 이번 접속에서만 등록해 Core 의 층 순서만 본다. 단축바 모습은 바뀌지 않는다(Dominos 외관 코드가 아직 Core 편집값을 읽지 않는다). 다음 줄을 차례로 친다:
  `/run local C=DevilForever_Core print(C.Presets:Register({name="t",edits={["dominos.bar1"]={position={point="CENTER",x=0,y=-200}}}}),C.Edit:Set("dominos.bar1","position",{point="CENTER",x=100,y=0}))`
  `/dfp preset t`
  `/run local C=DevilForever_Core local p=C.Edit:Get("dominos.bar1").position print(p.point,p.x,p.y,C.Presets:GetActive(),next(C.Edit:GetEdits("dominos.bar1")))`
- 기대 결과: 첫 출력 `1 true applied`. `/dfp preset t` 보고 `t preset 적용 — 편집값을 지운 프레임 1개`. 셋째 출력 `CENTER 0 -200 t nil`(사용자 편집값이 지워지고 preset 값이 보인다 — `t` 는 지금 preset, `nil` 은 남은 편집값 없음). 애드온 값 조각(fragment) 쓰기는 preset 파일이 들어온 뒤 따로 본다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | 등록·편집=<줄> | preset 보고=<줄> | 결과=<줄>`

## 8. 키 설정·게임 설정은 고를 때만 · 매크로 그대로

- 하는 법: 1번 셋째 `/run` 줄(기준값)을 다시 친다. 그 다음 `/dfp keys save dft` → `/dfp keys list` → `/dfp keys load dft` 를 차례로 치고, 기준값 줄을 한 번 더 친다. `/dfp game list` 를 친다. `/pm list` 를 친다.
- 기대 결과: 2–7번을 지나도 기준값 줄 출력이 1번과 같다(저장·되돌리기가 키 설정·매크로를 건드리지 않는다). `keys save` → `Keybinds save dft: 됨`, `keys list` 에 `dft`, `keys load` → `Keybinds load dft: 됨`, 그 뒤 기준값도 같다. `game list` 는 profile 목록 또는 `이 클라이언트에서 ProfileManager GameSettings 를 쓸 수 없음`(보인 그대로). `/pm list` 의 Keybinds 에 `dft` 가 있다.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 2–7 뒤 기준값=<줄>(1번과 같음 예/아니오) | keys save/list/load=<줄들> | load 뒤 기준값=<줄> | game list=<줄> | pm list=<줄 요약>`

## 9. 저장본 셋의 파일 크기

- 하는 법: `/dfp save t2` → `/dfp go`, `/dfp save t3` → `/dfp go`. `/dfp list` 를 친다. 게임을 완전히 종료하고 `_forever_/WTF/Account/<계정>/SavedVariables/!DevilForever_Core.lua` 의 바이트 수를 적는다. 다시 접속해 UI 가 뜰 때까지 걸린 시간이 평소와 비슷한지 본다.
- 기대 결과: `/dfp list` 에 `t1`·`t2`·`t3`·`__before-restore` 가 있고, 파일 크기는 보인 그대로 적는다(Claude 쪽 어림은 저장본 하나에 수백 KB 까지).

결과 한 줄 양식: `9 | <통과/실패/못 함> | list=<줄 요약(KB 포함)> | 파일 크기=<바이트> | 접속 시간=<평소와 같음/느림(초)>`

## 10. 전투 중에는 아무것도 바꾸지 않음

- 하는 법: 몹과 싸우는 동안(전투 중) `/dfp save x`, `/dfp restore t1`, `/dfp preset t`, `/dfp go` 를 차례로 친다. 전투가 끝난 뒤 `/dfp status` 를 친다.
- 기대 결과: 네 명령 모두 `안 함: 전투 중 — 바꾼 것 없음`, UI 가 다시 불리지 않는다. status 에 `기다리는 요청: 없음`.

결과 한 줄 양식: `10 | <통과/실패/못 함> | 전투 중 출력=<줄들> | 다시 불림=<없음/있음> | 전투 뒤 status=<줄>`

## 11. 오류·결과 올리기

- 하는 법: `/bugsack` 을 열어 이번 검증 동안 쌓인 `DevilForever`·`ProfileManager`·`Dominos`·`Details`·`Grid2`·`SexyMap` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 문구 전체를 `bugsack.txt` 에 복사). 0–11 의 결과 줄을 `References/codex-verify/phase20/result.md` 에 순서대로 적고 `chat.md`·`bugsack.txt`(있으면)와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase20`, `WTF_after_phase20`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다. 2번의 표시값·6번의 특성 profile·8번의 키 설정 profile 도 이것으로 시작 전으로 돌아간다).
- 기대 결과: 오류 0, `References/codex-verify/phase20/result.md` 가 있다.

결과 한 줄 양식: `11 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 백업 되돌림=<예/아니오> | 커밋=<해시>`

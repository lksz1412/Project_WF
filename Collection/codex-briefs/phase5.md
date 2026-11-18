# Codex 실사용 검증 발주문 — Phase 5 (미니맵 · SexyMap v12.1.7)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run` 입력은 모두 사람이 하듯 직접 한다. 미니맵의 모양·자리·테두리는 이 Phase 에서 보지 않는다(외관 단계 몫).

- 결과를 올릴 자리: `References/codex-verify/phase5/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 둘:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - SexyMap 원본 `References/forever-addons/SexyMap/SexyMap-v12.1.7.zip`, sha256 `1868eb714b8c9ea4efaa615109bfd457a0c3bb625f0b2a1f1befdadfc9143321`. 안의 `SexyMap` 폴더 하나를 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- SexyMap 은 캐릭터마다 `<캐릭터 이름>-<서버 이름>` 이름의 프로필을 쓴다. 아래 `/run` 줄은 그 이름을 스스로 만든다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase5/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 두 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_ChatSetup`, `SexyMap`)가 있으면 백업 쪽으로 옮긴 뒤 두 ZIP 에서 위 폴더를 넣는다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/SexyMap.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 둘 다 같고, 세 폴더가 설치되고, SexyMap 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | 모음집 sha256 일치=<예/아니오> | SexyMap sha256 일치=<예/아니오> | 넣은 폴더=<목록> | SexyMap 저장 파일 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드와 Lua 오류

- 하는 법: 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 DevilForever Core·SexyMap 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 `/run print(SexyMap ~= nil, type(SexyMap2DB))` 를 친다(SexyMap 의 핵심 파일은 TOC 에서 `mainline` 조건으로만 로드된다 — 이 줄이 Forever 에서 그 파일이 로드됐는지 본다). `/bugsack` 을 열고 `SexyMap` 이나 `!DevilForever_Core` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase5/bugsack.txt` 에 복사한다.
- 기대 결과: 둘 다 「사용 가능」, 출력 `true table`, 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 출력=<줄> | 오류 수=<n>`

## 2. 기본값 주입 상태

- 하는 법: 접속한 그대로 직접 친다.
  `/run local s=DevilForever_Core.Defaults:GetStatus("SexyMap"); local t=s.targets.SexyMap2DB; print(s.registered, s.loaded, t and t.state, t and t.mode, t and t.key, t and t.written)`
  상태 기록도 본다: `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end`
- 기대 결과: `true true applied first-load SexyMap2DB 28`(`fill-missing … 0` 이 나오면 실패로 적는다 — Core 가 SexyMap 보다 먼저 처리한다는 전제가 이 클라이언트에서 맞지 않다는 뜻이다). 상태 기록에 `error`·`skip`·`conflict` 줄이 없다(`info` 줄은 적기만 한다).

결과 한 줄 양식: `2 | <통과/실패/못 함> | 출력=<줄> | 상태 기록=<error/skip/conflict 줄 또는 없음>`

## 3. SexyMap 이 읽은 값

- 하는 법: `/reload` 를 친다(처음 접속에서는 일부 값이 다음 불러오기부터 쓰인다). 그다음 `/run local k=UnitNameUnmodified("player").."-"..GetRealmName(); local p=SexyMap2DB[k]; local t=type(p)=="table"; print(k, type(p), t and p.core.rightClickToConfig, t and p.buttons.visibilitySettings.MiniMapTracking, t and p.core.autoZoom)` 를 친다.
- 기대 결과: `<이름>-<서버> table false always 5`.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 출력=<줄>`

## 4. 클릭과 핑

- 하는 법: 미니맵 위를 왼쪽 단추로 한 번 누른다. 오른쪽 단추로 한 번 누른다. 그다음 `/sexymap` 을 친다. 파티원이 있으면 파티원에게 미니맵에 핑이 보였는지 묻는다.
- 기대 결과: 왼쪽 클릭 자리에 핑 표시가 뜬다. 오른쪽 클릭으로는 아무 창도 열리지 않는다. `/sexymap` 은 SexyMap 설정 창을 연다. (「누가 핑했는지」 이름 표시는 이 판 SexyMap 이 로드하지 않는 모듈이라 없다 — 보이면 적는다.)

결과 한 줄 양식: `4 | <통과/실패/못 함> | 왼쪽 클릭 핑=<보임/안 보임> | 오른쪽 클릭 창=<안 열림/열림> | /sexymap=<열림/안 열림> | 파티원 핑 보임=<예/아니오/파티 없음> | 핑한 이름 표시=<없음/보임>`

## 5. 확대·축소

- 하는 법: 미니맵 위에서 마우스 휠을 위로 두 칸 굴려 지도가 두 단계 커지는지 눈으로 본다. 곧바로 아래로 한 칸 굴려 한 단계 작아지는지 본다. 손을 떼고 10초 기다린 뒤 `/run print(Minimap:GetZoom())` 를 친다.
- 기대 결과: 휠 위로 확대, 아래로 축소. 마지막 휠 뒤 5초쯤 지나 지도가 저절로 가장 작은 배율로 돌아가고 출력은 `0`. 미니맵 확대·축소 단추(+/−)는 보이지 않는다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 휠 위=<확대/변화 없음> | 휠 아래=<축소/변화 없음> | 자동 축소 뒤 출력=<값> | +/− 단추=<안 보임/보임>`

## 6. 추적 아이콘과 단추 정리

- 하는 법: 마우스를 미니맵에서 뗀 상태로 미니맵 둘레를 본다. 추적 단추(돋보기 아이콘)를 눌러 추적 메뉴에서 항목 하나를 켰다가 끈다. 마우스를 미니맵 위에 올렸다가 다시 뗀다. 애드온 미니맵 단추(예: BugSack 단추)의 표시를 본다.
- 기대 결과: 추적 단추는 마우스를 올리지 않아도 늘 보이고, 누르면 추적 메뉴가 열려 켜고 끌 수 있다. 애드온 미니맵 단추는 마우스를 미니맵에 올렸을 때만 보이고 떼면 1초쯤 뒤 사라진다. 시계·지역 이름은 늘 보인다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 추적 단추=<늘 보임/올릴 때만/안 보임> | 추적 메뉴=<열림·바뀜/안 열림> | 애드온 단추=<올릴 때만/늘 보임/안 보임> | 시계·지역 이름=<보임/안 보임>`

## 7. 사용자 값을 덮지 않는지와 재접속 유지

- 하는 법: `/run local k=UnitNameUnmodified("player").."-"..GetRealmName(); SexyMap2DB[k].core.rightClickToConfig=true` → `/reload` → `/run local k=UnitNameUnmodified("player").."-"..GetRealmName(); print(SexyMap2DB[k].core.rightClickToConfig, DevilForever_Core.Defaults:GetStatus("SexyMap").targets.SexyMap2DB.state)` → 캐릭터 선택으로 나갔다가 다시 접속해 같은 줄을 한 번 더 친다. 이때 미니맵을 오른쪽 클릭해 본다 → 끝나면 앞 줄의 `=true` 를 `=false` 로 바꿔 쳐서 되돌린다.
- 기대 결과: reload 뒤와 재접속 뒤 둘 다 `true already`, 오른쪽 클릭이 SexyMap 설정 창을 연다(사용자가 바꾼 값을 Core 가 되돌리지 않는다).

결과 한 줄 양식: `7 | <통과/실패/못 함> | reload 뒤=<출력> | 재접속 뒤=<출력> | 오른쪽 클릭 창=<열림/안 열림> | 되돌림=<예/아니오>`

## 8. SexyMap 끄기

- 하는 법: 캐릭터 선택 화면 애드온 창에서 SexyMap 을 끈다. 접속해 `/run local s=DevilForever_Core.Defaults:GetStatus("SexyMap"); print(s.registered, s.loaded, s.targets.SexyMap2DB)` 를 치고 기본 미니맵이 돌아왔는지, BugSack 에 새 오류가 있는지 본다. 끝나면 다시 켜고 접속한다.
- 기대 결과: `true false nil`, 기본 미니맵 보임, 새 오류 0. 다시 켠 뒤 3의 줄 출력이 그대로(`… table false always 5`, 7 에서 되돌렸으므로).

결과 한 줄 양식: `8 | <통과/실패/못 함> | 끈 상태 출력=<줄> | 기본 미니맵 보임=<예/아니오> | 새 오류 수=<n> | 다시 켠 뒤 3 출력=<줄>`

## 9. 마지막 오류 확인과 결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `SexyMap`·`!DevilForever_Core` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase5/result.md` 에 순서대로 적고 필요한 화면 갈무리와 함께 저장소에 올린다. 원래 SexyMap 설정으로 돌아가려면 게임을 종료하고 0 에서 옮긴 `SexyMap.lua` 를 되돌린다(돌렸는지 한 줄 적는다). 모든 것을 시작 전 상태로 되돌리려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase5`, `WTF_after_phase5`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: 오류 0, `References/codex-verify/phase5/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | SexyMap 저장 파일 되돌림=<예/아니오> | 커밋=<해시>`

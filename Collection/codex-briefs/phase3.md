# Codex 실사용 검증 발주문 — Phase 3 (행동단축바 · Dominos 12.0.4)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run` 입력은 모두 사람이 하듯 직접 한다. 키 배정은 바꾸지 않는다(이 Phase 는 키를 자동으로 배정하지 않는다).

- 결과를 올릴 자리: `References/codex-verify/phase3/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 둘:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - Dominos 원본 `References/forever-addons/Dominos/Dominos-12.0.4.zip`, sha256 `2dbcf9857a91b772a42200369386fc17f875530ffd47984b555ecdb8e11bef1a`. 이 안의 `Dominos`·`Dominos_Config`·`Dominos_Cast`·`Masque_Dominos` 네 폴더만 넣는다. `Dominos_Progress`·`Dominos_Roll` 은 넣지 않는다(다른 Phase 몫). `Masque_Dominos` 는 Masque 가 이미 설치돼 있을 때만 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 발주문에서 「직업 이름」 은 게임이 보여 주는 한국어 직업 이름(예: 전사)이다. Dominos 는 처음 접속한 캐릭터에 직업 이름과 같은 이름의 프로필을 쓴다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase3/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 두 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `Dominos*`, `Masque_Dominos`)가 있으면 백업 쪽으로 옮긴 뒤 두 ZIP 에서 위 폴더를 넣는다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/Dominos.lua`(와 `Dominos.lua.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 둘 다 같고, 폴더가 설치되고, Dominos 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | 모음집 sha256 일치=<예/아니오> | Dominos sha256 일치=<예/아니오> | 넣은 폴더=<목록> | Dominos 저장 파일 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드와 Lua 오류

- 하는 법: 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 DevilForever Core·Dominos·Dominos Config·Dominos Cast·Masque: Dominos 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 `/bugsack` 을 열고 `Dominos` 나 `!DevilForever_Core` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase3/bugsack.txt` 에 복사한다.
- 기대 결과: 모두 「사용 가능」(Masque: Dominos 는 넣었을 때만), 오류 0. 화면 아래에 Dominos 행동단축바가 보이고 기본 행동단축바는 숨는다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 오류 수=<n> | Dominos 바 보임=<예/아니오>`

## 2. 기본값 주입 상태

- 하는 법: 직업 하나로 접속한 뒤 직접 친다.
  `/run local s=DevilForever_Core.Defaults:GetStatus("Dominos"); local t=s.targets.DominosDB; print(s.registered, s.loaded, t and t.state, t and t.mode, t and t.key, t and t.written)`
  상태 기록도 본다: `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end`
- 기대 결과: `true true applied fill-missing DominosDB@profile:<직업 이름> 1`. 상태 기록에 `error`·`skip`·`conflict` 줄이 없다(`info` 줄은 적기만 한다).

결과 한 줄 양식: `2 | <통과/실패/못 함> | 직업=<직업 이름> | 출력=<줄> | 상태 기록=<error/skip/conflict 줄 또는 없음>`

## 3. Dominos 가 읽은 값과 바 개수

- 하는 법: `/run local d=Dominos.db; print(d:GetCurrentProfile(), d.profile.ab.count, d.profile.ab.length, d.profile.showBindingText, d.profile.modules.StanceBar, d.profile.modules.PetBar, d.profile.modules.PossessBar)` 를 친다. 이어서 `/dom config` 로 설정 모드를 켜고 화면에 보이는 행동단축바 번호를 센 뒤 `/dom config` 로 끈다(바를 옮기지 않는다).
- 기대 결과: `<직업 이름> 8 12 true true true true`, 설정 모드에서 행동단축바 1–8(바 개수는 Dominos 기본값 그대로 — 남는 바는 외관 단계에서 숨긴다).

결과 한 줄 양식: `3 | <통과/실패/못 함> | 출력=<줄> | 보인 행동단축바=<번호 목록>`

## 4. 단축키 글자 (키 자동 배정 없음)

- 하는 법: 게임 메뉴 「단축키 설정」 에서 지금 배정된 키를 바꾸지 않고, 행동단축바 1 의 버튼 1–12 와 「행동단축바 버튼 1–12」 에 배정된 키를 비교한다. 다른 바(2–7)의 버튼 중 키가 배정된 것이 있으면 버튼에 키 글자가 보이는지 본다. `/run print(GetBindingKey("CLICK DominosActionButton13:HOTKEY"), GetBindingKey("CLICK DominosActionButton73:HOTKEY"))` 를 친다.
- 기대 결과: 키가 배정된 버튼에는 그 키 글자가 버튼 위에 보이고, 배정 안 된 버튼에는 글자가 없다. 마지막 줄 출력은 이 설치 전에 사용자가 배정한 값 그대로다(이 Phase 가 새로 배정한 키 없음).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 바1 키 글자=<보임/안 보임/일부> | 다른 바 키 글자=<보임/배정 없음/안 보임> | GetBindingKey 출력=<줄>`

## 5. 페이지 전환

- 하는 법: 전투 밖에서 행동단축바 페이지 전환 키(게임 기본 배정이면 Shift+2 로 2 페이지, Shift+1 로 1 페이지 — 배정이 다르면 「단축키 설정」 의 「행동단축바 페이지 2·1」 에 배정된 키)로 바 1 을 2 페이지로 바꿨다가 1 페이지로 돌린다. 전사(전투·방어·광폭 태세), 드루이드(표범·곰·달빛야수 형태), 도적(은신), 사제(어둠의 형상) 캐릭터가 있으면 태세·형태를 바꿔 바 1 의 아이콘이 바뀌는지 본다(드루이드 여행·수중 형태와 그 밖의 직업은 바뀌지 않는 것이 기본). 있는 캐릭터만 한다.
- 기대 결과: 페이지 키로 바 1 아이콘 묶음이 바뀌고 돌아온다. 위 직업은 태세·형태·은신마다 바 1 이 따로 아이콘 묶음을 보인다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 페이지 키=<바뀜/안 바뀜> | 직업별=<직업:태세나 형태=바뀜/안 바뀜, …> | 해 본 직업=<목록>`

## 6. 직업 특수 바

- 하는 법: 있는 캐릭터마다 본다 — 전사·드루이드: 태세 바(태세·형태 버튼). 사냥꾼·흑마법사: 소환수를 부른 뒤 소환수 바. 주술사: 토템 바. 성기사(오라)·사냥꾼(상)·도적(은신)은 태세 바에 그 버튼이 뜨는지 기록한다(받은 원천에는 근거가 없다). 빙의 바는 탈것·빙의 상황이 있을 때만 본다(없으면 `못 함`).
- 기대 결과: 전사·드루이드 태세 바, 사냥꾼·흑마법사 소환수 바, 주술사 토템 바가 보이고 누르면 동작한다. 성기사·사냥꾼·도적 칸은 본 대로 적는다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 직업별=<직업:바=보임/안 보임/동작, …> | 오라/상/은신 태세 바=<직업:뜸/안 뜸, …> | 빙의 바=<보임/못 함>`

## 7. 사용자 값을 덮지 않는지와 재접속 유지

- 하는 법: `/run Dominos:SetActionBarSize(6, 12)` → `/reload` → `/run print(Dominos.db.profile.ab.count, DevilForever_Core.Defaults:GetStatus("Dominos").targets.DominosDB.state)` → 캐릭터 선택으로 나갔다가 다시 접속해 같은 줄을 한 번 더 친다 → 끝나면 `/run Dominos:SetActionBarSize(8, 12)` 로 되돌린다.
- 기대 결과: reload 뒤와 재접속 뒤 둘 다 `6 already` (사용자가 바꾼 6 을 Core 가 되돌리지 않고, 기본값은 다시 넣지 않는다). 되돌린 뒤 바 1–8.

결과 한 줄 양식: `7 | <통과/실패/못 함> | reload 뒤=<출력> | 재접속 뒤=<출력> | 되돌림 뒤 바 개수=<n>`

## 8. Dominos 끄기

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Dominos 를 끈다(Dominos Config·Dominos Cast·Masque: Dominos 는 Dominos 에 기대므로 함께 꺼진다). 접속해 `/run local s=DevilForever_Core.Defaults:GetStatus("Dominos"); print(s.registered, s.loaded, s.targets.DominosDB)` 를 치고 기본 행동단축바가 돌아왔는지, BugSack 에 새 오류가 있는지 본다. 끝나면 다시 켜고 접속한다.
- 기대 결과: `true false nil`, 기본 행동단축바 보임, 새 오류 0. 다시 켠 뒤 Dominos 바 1–8.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 끈 상태 출력=<줄> | 기본 바 보임=<예/아니오> | 새 오류 수=<n> | 다시 켠 뒤 바=<번호 목록>`

## 9. 마지막 오류 확인과 결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Dominos`·`!DevilForever_Core` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase3/result.md` 에 순서대로 적고 필요한 화면 갈무리와 함께 저장소에 올린다. 원래 Dominos 설정으로 돌아가려면 게임을 종료하고 0 에서 옮긴 `Dominos.lua` 를 되돌린다(돌렸는지 한 줄 적는다).
- 기대 결과: 오류 0, `References/codex-verify/phase3/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | Dominos 저장 파일 되돌림=<예/아니오> | 커밋=<해시>`

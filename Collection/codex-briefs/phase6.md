# Codex 실사용 검증 발주문 — Phase 6 (기본 unit·직업 자원 · Forever Unit Frames 0.65.2)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/fuf` 입력은 모두 사람이 하듯 직접 한다. 프레임의 자리·크기·질감·글꼴은 이 Phase 에서 보지 않는다(외관 단계 몫). 시전바 겹침(FUF·Quartz·기본 시전바)은 Phase 7 에서 본다.

- 결과를 올릴 자리: `References/codex-verify/phase6/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 셋:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`, sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`. 안의 `ForeverUnitFrames` 폴더 하나를 넣는다.
  - Grid2 원본 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`, sha256 `f198bc3ce2d02e023f81052074a2e9aa4ba41819931bd302ff7429dac9515393`. 5번 항목에서만 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- `DevilForever_FUFDefaults` 가 하는 일은 하나다: Grid2 가 켜져 있으면 캐릭터마다 한 번, 접속 20초쯤 뒤 FUF 자체 명령 `/fuf raid off` 를 보내 FUF 공격대 프레임을 끈다(FUF 공격대 설정은 캐릭터마다 따로다). 이미 FUF 에 저장된 값이 있으면 건드리지 않는다. 파티 프레임은 FUF 가 그대로 맡는다(FUF 파티 설정은 계정 공용이라 건드리지 않는다 — Grid2 가 공격대만 보이게 하는 것은 Phase 9 몫). 그 밖의 FUF 설정은 FUF 기본값 그대로다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase6/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 세 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_ChatSetup`, `DevilForever_FUFDefaults`, `ForeverUnitFrames`, `Grid2`)가 있으면 백업 쪽으로 옮긴 뒤 모음집과 FUF ZIP 에서 앞의 네 폴더를 넣는다(Grid2 는 아직 넣지 않는다). 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/` 의 `ForeverUnitFrames.lua`·`DevilForever_FUFDefaults.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 셋 다 같고, 네 폴더가 설치되고, 두 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/FUF/Grid2)=<예·예·예> | 넣은 폴더=<목록> | 저장 파일 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드와 Lua 오류

- 하는 법: 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 DevilForever Core·DevilForever FUF Defaults·Forever Unit Frames 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 30초 기다린 뒤 `/run print(ForeverUnitFrames ~= nil, type(ForeverUnitFramesDB), DevilForever_FUFDefaults.GetStatus().state)` 를 친다. `/fuf status` 를 친다. `/bugsack` 을 열고 `ForeverUnitFrames`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase6/bugsack.txt` 에 복사한다.
- 기대 결과: 셋 다 「사용 가능」, 출력 `true table grid2-not-loaded`, `/fuf status` 가 채팅에 몇 줄을 낸다, 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 출력=<줄> | /fuf status 원천 줄=<Source 줄 그대로> | 오류 수=<n>`

## 2. 체력과 직업 자원

- 하는 법: 가진 캐릭터마다(가능한 직업만) 접속해 내 프레임을 본다. 막대에 마우스를 올리지 않고 맞거나 자원을 써서 값이 움직이는지 본다. 직업마다 볼 것: 전사 = 분노 막대 / 도적 = 기력 막대 + 대상 프레임 아래 연계 점(공격해서 점이 차는지) / 드루이드 = 사람 형태 마나 막대, 표범 형태 기력 막대 + 대상 프레임 연계 점 + 자원 막대 아래 얇은 마나 띠, 곰 형태 분노 막대 + 마나 띠 / 주술사 = 마나 막대 + 토템을 놓았을 때만 내 프레임 옆 토템 아이콘 / 사냥꾼 = 마나 막대 + 소환수 프레임의 만족도 아이콘 / 성기사·사제·마법사·흑마법사 = 마나 막대(주문 뒤 5초 동안 막대 아래 빛 점이 흐른다). 마나를 쓰지 않는 직업에 마나 막대가, 주술사가 아닌 직업에 빈 토템 칸이 보이면 실패로 적는다. 흑마법사의 영혼의 조각 개수는 FUF 에 표시가 없다(보이면 적는다).
- 기대 결과: 모든 직업에서 체력 막대가 움직이고, 자원 막대가 위 표대로 그 직업의 자원을 보인다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 본 직업=<직업=통과/실패 목록> | 연계 점=<보임/안 보임/못 봄> | 드루이드 마나 띠=<보임/안 보임/못 봄> | 토템 아이콘=<놓을 때만/늘 보임/못 봄> | 소환수 만족도=<보임/안 보임/못 봄> | 엉뚱한 자원 표시=<없음/있음: 직업·내용>`

## 3. 프레임 위 오라·치유 예측·거리 흐림

- 하는 법: 아무 몹이나 대상을 잡는다. 대상에 디버프를 건다(가능한 직업으로). 파티가 있으면 파티원이 나를 치유할 때 체력 막대 끝에 들어올 치유가 옅게 미리 보이는지 본다. 대상(우호 캐릭터 또는 몹)에서 40미터 넘게 떨어졌다가 다가간다.
- 기대 결과: 대상 프레임 위에 버프·디버프 아이콘, 내 프레임 위 버프 아이콘은 없음(기본 버프 창이 보인다), 치유 예측 보임, 멀어지면 대상 프레임이 흐려지고 가까워지면 돌아온다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 대상 오라=<보임/안 보임> | 내 프레임 버프=<없음/보임> | 치유 예측=<보임/안 보임/파티 없음> | 거리 흐림=<됨/안 됨>`

## 4. Grid2 없이 공격대 설정

- 하는 법: Grid2 가 없는 그대로 `/run local s=DevilForever_FUFDefaults.GetStatus(); local d=ForeverUnitFramesDB; local r=d.raid and d.raid[s.key]; print(r and r.general and tostring(r.general.enabled), s.record)` 를 친다. 파티가 있으면 파티를 짜서 FUF 파티 프레임을 본다.
- 기대 결과: `nil nil`(FUF 기본 켜짐, 우리 애드온은 아무것도 하지 않음), 파티 프레임이 FUF 것으로 보인다.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 출력=<줄> | FUF 파티 프레임=<보임/안 보임/파티 없음>`

## 5. Grid2 를 켜면 한 번 끔

- 하는 법: 게임을 종료하고 Grid2 ZIP 의 `Grid2`·`Grid2Options`·`Grid2LDB` 폴더를 `_forever_/Interface/AddOns` 에 넣는다. 같은 캐릭터로 접속해 30초 기다린다. 채팅에 FUF 의 공격대 프레임 끔 안내 줄(영어 클라이언트면 「Raid frames off. /reload brings back Blizzard's raid frames.」)이 떴는지 본다. `/run local s=DevilForever_FUFDefaults.GetStatus(); print(s.state, s.key, s.record and s.record.raid)` 를 친다. `/reload` 뒤 `/run local d=ForeverUnitFramesDB; local k=DevilForever_FUFDefaults.GetStatus().key; local p=d.profiles and d.profiles.Default; print(d.raid[k].general.enabled, p and p.party and tostring(p.party.enabled))` 를 친다. 파티가 있으면 파티를 짠다(공격대가 있으면 공격대도).
- 기대 결과: 채팅 줄 보임, 첫 출력 `applied <이름>-<서버> switched-off`, reload 뒤 출력 `false nil`(공격대 끔, 파티는 FUF 기본 켜짐 그대로), 파티에서 FUF 파티 프레임이 보인다, 공격대에서 FUF 공격대 프레임은 없고 Grid2 프레임이 보인다(파티에서 Grid2 가 함께 보이면 적는다 — Phase 9 에서 정리).

결과 한 줄 양식: `5 | <통과/실패/못 함> | 채팅 줄=<보임/안 보임> | 첫 출력=<줄> | reload 뒤 출력=<줄> | FUF 파티 프레임=<보임/안 보임/파티 없음> | 파티의 Grid2=<보임/안 보임/파티 없음> | 공격대 FUF·Grid2=<FUF 없음·Grid2 보임/다른 결과/공격대 없음>`

## 6. 사용자가 다시 켠 값은 그대로 (한 번만)

- 하는 법: `/fuf raid on` 을 친다 → `/reload` → 30초 뒤 5번의 두 `/run` 줄을 다시 친다 → 캐릭터 선택으로 나갔다가 다시 접속해 30초 뒤 같은 두 줄을 한 번 더 친다 → 끝나면 `/fuf raid off` 로 되돌리고 `/reload` 한다.
- 기대 결과: reload 뒤와 재접속 뒤 모두 첫 줄 `done-before <이름>-<서버> switched-off`, 둘째 줄 `nil nil`(다시 켠 값이 그대로 — 우리 애드온이 다시 끄지 않는다), 5번의 공격대 프레임 끔 안내 줄이 다시 뜨지 않는다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | reload 뒤=<두 출력> | 재접속 뒤=<두 출력> | 채팅 줄 다시 뜸=<아니오/예> | 되돌림=<예/아니오>`

## 7. 등록 표와 상태 기록

- 하는 법: `/run print(#DevilForever_Core:GetFrameNames("ForeverUnitFrames"), DevilForever_Core:GetAddonInfo("ForeverUnitFrames").defaults)` 를 친다. `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end` 를 친다. 다른 캐릭터(같은 계정)로 한 번 접속해 5번 첫 `/run` 줄을 친다.
- 기대 결과: `15 nil`. 상태 기록에 `error`·`skip`·`conflict` 줄이 없다. 다른 캐릭터(30초 뒤)는 `applied <그 캐릭터 키> switched-off`(공격대는 캐릭터마다 따로라 그 캐릭터도 끔), 그 캐릭터의 FUF 파티 프레임은 켜진 그대로다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | 출력=<줄> | 상태 기록=<error/skip/conflict 줄 또는 없음> | 다른 캐릭터 출력=<줄/캐릭터 없음>`

## 8. 끄기

- 하는 법: 캐릭터 선택 화면 애드온 창에서 DevilForever FUF Defaults 를 끄고 접속해 BugSack 을 본다. 다음에 Forever Unit Frames 를 끄고(FUF Defaults 는 의존하는 FUF 가 꺼져 로드되지 않는다) 접속해 기본 프레임(내 프레임·대상 프레임)이 돌아왔는지, 새 오류가 있는지 본다. 끝나면 둘 다 다시 켠다.
- 기대 결과: 첫 접속 오류 0. FUF 를 끈 접속에서 기본 프레임 보임, FUF Defaults 는 애드온 창에서 「의존 애드온 없음」 류 표시, 오류 0.

결과 한 줄 양식: `8 | <통과/실패/못 함> | FUF Defaults 끈 접속 오류 수=<n> | FUF 끈 접속 기본 프레임=<보임/안 보임> | FUF Defaults 표시=<문구> | 오류 수=<n>`

## 9. 마지막 오류 확인과 결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `ForeverUnitFrames`·`DevilForever`·`Grid2` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase6/result.md` 에 순서대로 적고 필요한 화면 갈무리와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase6`, `WTF_after_phase6`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다). Grid2 를 남길지 빼낼지도 한 줄 적는다.
- 기대 결과: 오류 0, `References/codex-verify/phase6/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오, Grid2 남김/뺌> | 커밋=<해시>`

# Codex 실사용 검증 발주문 — Phase 10 (데미지 미터·어그로 미터 · Details! 20261109 + Tiny Threat)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/details` 입력은 모두 사람이 하듯 직접 한다. 창의 자리·크기·질감·글꼴은 이 Phase 에서 보지 않는다(외관 단계 몫).

- 결과를 올릴 자리: `References/codex-verify/phase10/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 둘:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core` 하나만 넣는다).
  - Details 원본 `References/forever-addons/Details/Details-Details.20261109.15410.172.zip`, sha256 `5002bdd5c3e92dd59bffa3ebdfc867f980b09ed629c51dab056fb5442f92ad41`. 안의 8폴더 가운데 `Details`·`Details_TinyThreat` 둘만 넣는다(나머지 여섯 — `Details_Compare2`·`Details_DataStorage`·`Details_EncounterDetails`·`Details_RaidCheck`·`Details_Streamer`·`Details_Vanguard` — 은 넣지 않는다. 모음집 묶음에는 Details·Tiny Threat 둘만 넣을 계획이다).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 구성: **창 1 = 데미지(Details 기본 그대로 — 준 피해, 큰 값이 위), 창 2 = 위협(Tiny Threat 플러그인)**. ForeverThreat 는 쓰지 않는다(R107 ②). Details 의 설정 파일은 Details 가 로그아웃 때 자기 메모리 값으로 다시 쓰므로 모음집은 Details 기본값을 넣지 않는다. 창 2 는 캐릭터마다 한 번 손으로 만든다(2번) — 그 뒤로는 Details 가 저장·복원한다. Details 를 대화창 탭 안에 넣는 기능은 Details 기본(꺼짐) 그대로다 — 미터가 세 번째 대화창 자리를 차지하지 않는다(R33).
- 위협이 필요한 항목(4)은 몹과 싸우면 되고, 파티가 있으면 더 좋다. 할 수 없는 칸은 `못 봄` 으로 적는다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase10/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 두 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 `Details` 로 시작하는 폴더나 `!DevilForever_Core` 가 있으면 백업 쪽으로 옮긴 뒤 세 폴더(`!DevilForever_Core`, `Details`, `Details_TinyThreat`)를 넣는다. 다른 미터 애드온(Skada·ForeverThreat·ThreatClassic2 등)이 켜져 있으면 백업 쪽으로 옮긴다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/Details.lua`(와 `.bak`)와 이 검증에 쓸 두 캐릭터의 `_forever_/WTF/Account/<계정>/<서버>/<캐릭터>/SavedVariables/Details.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다 — Phase 1 에서 Details 를 넣었다면 있다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 둘 다 같고, 세 폴더가 설치되고, Details 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/Details)=<예·예> | 넣은 폴더=<목록> | 옮긴 애드온=<목록/없음> | Details 저장 파일 옮김=<계정·캐릭터별 예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드·처음 켜짐

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Details!·Details!: Tiny Threat·DevilForever Core 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 혼자 접속한다. Details 첫 실행 안내 창이 뜨면 닫는다(그 안의 「두 번째 창 만들기」 단추는 누르지 않는다 — 창 2 는 2번에서 만든다). 다음 두 줄을 친다:
  `/run local w1=Details:GetInstance(1); print(Details:GetNumInstances(), w1:GetMode(), w1:GetDisplay())`
  `/run print(#DevilForever_Core:GetFrameNames("Details"), DevilForever_Core:GetAddonInfo("Details").defaults, Details.chat_tab_embed.enabled)`
  `/bugsack` 을 열고 `Details`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase10/bugsack.txt` 에 복사한다.
- 기대 결과: 셋 다 「사용 가능」, 화면에 Details 창 하나(데미지), 첫 출력 `1 2 1 1`(창 하나·표준 모드·데미지·준 피해), 둘째 출력 `2 nil false`, 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 안내 창=<뜸·닫음/안 뜸> | 첫 출력=<줄> | 둘째 출력=<줄> | 오류 수=<n>`

## 2. 창 2 를 Tiny Threat 로 (캐릭터마다 한 번 — 손으로)

- 하는 법: 대화창에 `/details new` 를 친다(새 Details 창 열기 — `Details/functions/slash.lua:50–51`). 새로 생긴 창 2 의 제목 줄에서 모드 단추(창 모양 아이콘)에 마우스를 올리면 메뉴가 뜬다: 「표준」(Standard)·「모두」(Everything)·「플러그인」(Plugins) 세 줄(`Details/frames/window_main.lua:5408–5418`). 「플러그인」 줄에 마우스를 올려 옆에 뜨는 하위 메뉴에서 「Tiny Threat」 를 누른다(하위 메뉴 = 쓸 수 있는 공격대 플러그인 목록, 누르면 `Details.RaidTables:EnableRaidMode(창, 플러그인)` — `window_main.lua:5422–5431`, `Details/core/plugins_raid.lua:61`; 이름은 `Details_TinyThreat/enUS.lua:7`). 창 2 는 Codex 가 외관에서 자리를 잡으므로 지금은 창 1 과 겹치지 않게 끌어 두기만 한다. 다음 줄을 친다:
  `/run local w2=Details:GetInstance(2); print(Details:GetNumInstances(), w2 and w2:GetMode(), w2 and w2.current_raid_plugin, Details:GetInstance(1):GetDisplay())`
- 기대 결과: 창 2 에 Tiny Threat 화면(전투 밖이면 빈 줄일 수 있다), 출력 `2 4 DETAILS_PLUGIN_TINY_THREAT 1 1`(창 1 은 데미지 그대로). 메뉴 이름이 다르게 보이면 보인 그대로 적는다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 메뉴에 보인 이름=<줄들> | 출력=<줄> | 걸린 시간=<초>`

## 3. 데미지 값·정렬 (창 1 — Details 기본 그대로)

- 하는 법: 몹(또는 훈련용 허수아비)과 30초 이상 싸운다. 파티가 있으면 파티원도 함께 싸운다. 창 1 의 줄을 본다: 맨 위가 가장 큰 값인지, 줄 오른쪽 값(총량·초당·비율)이 싸우는 동안 늘어나는지, 내 줄 값이 내가 준 피해와 맞는 범위인지(기술 하나 맞힌 뒤 늘어난 양). 전투가 끝난 뒤 그 전투가 창 1 에 남는지 본다.
- 기대 결과: 큰 값이 위로 정렬, 값이 전투 중 늘어남, 전투 뒤 그 전투가 남는다. 이 Phase 는 값·정렬 뜻을 바꾸지 않았다 — 다르면 그대로 적는다(Details 쪽 결과).

결과 한 줄 양식: `3 | <통과/실패/못 함> | 정렬=<큰 값 위/다른 결과> | 전투 중 값=<늘어남/안 늘어남> | 내 값=<맞는 범위/다른 결과> | 전투 뒤 남음=<예/아니오> | 파티=<함께/혼자>`

## 4. 위협 (창 2 — Tiny Threat)

- 하는 법: 몹 하나를 대상으로 잡고 싸운다. 창 2 에 위협 줄(이름·비율)이 뜨는지, 내가 몹을 잡고 있을 때 내 줄이 맨 위·100% 근처인지 본다. 파티가 있으면 탱커가 몹을 잡은 상태에서 다른 사람의 비율이 탱커보다 낮게 보이는지, 대상이 바뀌면 줄이 그 대상 기준으로 바뀌는지 본다. 전투 중 `/run print(UnitDetailedThreatSituation("player","target"))` 를 한 번 친다. 게임 기본 이름표의 위협 색이 같은 몹에 켜져 있는지도 본다(Phase 14 와 나눔 — 보기만).
- 기대 결과: 전투 중 창 2 에 위협 줄이 뜬다, 몹을 잡은 사람이 맨 위, 출력에 값들이 나온다(`nil` 만 나오면 클라이언트가 위협 정보를 주지 않는 것 — 그대로 적는다).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 위협 줄=<뜸/안 뜸> | 맨 위=<몹 잡은 사람/다른 결과> | 대상 바뀜=<따라 바뀜/다른 결과/못 봄> | 출력=<줄> | 이름표 위협 색=<보임/안 보임/못 봄>`

## 5. 대화창 자리 (R33)

- 하는 법: 세 대화창(모음집 대화창 Phase 의 창 셋이 있으면 그것, 없으면 지금 있는 대화창)과 Details 창 둘의 자리를 본다. 대화창 탭 줄에 Details 창이 탭으로 들어가 있는지, Details 창이 세 번째 대화창 위를 덮는지 본다. 화면 갈무리 하나를 남긴다.
- 기대 결과: Details 창은 대화창 탭에 들어가지 않는다(1번 둘째 출력 `false`). 자리 겹침은 외관 단계에서 정하므로 여기서는 겹침 여부만 적는다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 대화창 탭 안=<아님/들어감> | 세 번째 대화창 덮음=<아니오/예/대화창 셋 없음> | 갈무리=<파일 이름>`

## 6. 다른 캐릭터·사용자 값 유지

- 하는 법: 같은 계정의 다른 캐릭터(0 에서 저장 파일을 옮긴 캐릭터)로 접속해 1번 첫 `/run` 줄을 친다(창 2 가 저절로 생기지 않는다 — 캐릭터마다 2번을 한 번 해야 한다는 것을 확인). 다시 처음 캐릭터로 접속해 창 1 의 표시를 「치유」 로 바꾼다. `/reload` 뒤 2번 `/run` 줄을 친다. 끝나면 창 1 을 「데미지 → 준 피해」 로 되돌린다.
- 기대 결과: 다른 캐릭터 출력 `1 2 1 1`. 처음 캐릭터는 reload 뒤 `2 4 DETAILS_PLUGIN_TINY_THREAT 2 1`(창 2 그대로, 창 1 은 사용자가 고른 치유가 남음).

결과 한 줄 양식: `6 | <통과/실패/못 함> | 다른 캐릭터 출력=<줄/캐릭터 없음> | reload 뒤 출력=<줄> | 되돌림=<예/아니오>`

## 7. 끄기

- 하는 법: 애드온 창에서 `Details!: Tiny Threat` 만 끄고 처음 캐릭터로 접속한다. 창 2 에 무엇이 보이는지(빈 창·플러그인 기다림 표시 등) 적는다. 다시 켜고 접속해 창 2 가 Tiny Threat 로 돌아오는지 본다. 이번에는 `Details!` 를 끄고 접속한다(Tiny Threat 는 Details 가 없으면 로드되지 않는다). 끝나면 둘 다 다시 켠다.
- 기대 결과: Tiny Threat 끔 = 창 2 에 Details 의 플러그인 기다림 표시(오류 0), 다시 켜면 창 2 가 Tiny Threat. Details 끔 = Details 창 없음, 오류 0.

결과 한 줄 양식: `7 | <통과/실패/못 함> | Tiny Threat 끔=<창 2 모습> | 다시 켬=<Tiny Threat/다른 결과> | Details 끔=<창 없음/다른 결과> | 오류 수=<n>`

## 8. 재접속

- 하는 법: 처음 캐릭터로 `/reload` 한 뒤 2번 `/run` 줄을 친다. 게임을 종료했다가 다시 접속해 같은 줄을 친다. 접속 직후 바로 몹과 싸워 창 2 가 위협을 보이는지 본다.
- 기대 결과: 두 번 모두 `2 4 DETAILS_PLUGIN_TINY_THREAT 1 1`, 전투 중 창 2 에 위협 줄.

결과 한 줄 양식: `8 | <통과/실패/못 함> | reload 뒤=<줄> | 재접속 뒤=<줄> | 접속 직후 위협 줄=<뜸/안 뜸>`

## 9. 오류·결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Details`·`DevilForever` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase10/result.md` 에 순서대로 적고 화면 갈무리(창 둘이 보이는 전투 중 하나, 5번 하나)와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase10`, `WTF_after_phase10`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: 오류 0, `References/codex-verify/phase10/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오> | 커밋=<해시>`

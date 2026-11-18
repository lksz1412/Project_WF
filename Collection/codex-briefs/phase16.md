# Codex 실사용 검증 발주문 — Phase 16 (상태 띠 · DevilForever_StatusStrip)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/dfstatus` 입력은 모두 사람이 하듯 직접 한다. 띠의 위치·크기·글꼴·색·바탕은 이 Phase 에서 보지 않는다(외관 단계 몫 — `appearance-16.md`). 지금 띠는 화면 맨 아래에 게임 기본 글꼴로 글자만 보인다.

- 결과를 올릴 자리: `References/codex-verify/phase16/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 1번의 `/dfstatus` 출력 전체는 `dfstatus.txt`, 오류 문구는 `bugsack.txt` 에 따로 둔다.
- 이 Phase 가 내는 것: 작은 애드온 `DevilForever_StatusStrip` 하나(R101 — 모음집 안에서 이 다섯 정보를 함께 보이는 것이 따로 없어서 하나 만들었다). 띠에 보이는 것은 왼쪽부터 골드 · 가방 빈칸 · 내구도 · 시계 · 지연 · FPS 여섯 칸뿐이다(R107 ⑤ — 화폐 목록·길드/친구 목록·LDB 묶음 같은 무거운 것은 넣지 않았다). 마우스는 받지 않는다(띠 위를 눌러도 아래 것이 눌린다). 설정 창은 없고 `/dfstatus` 명령 하나로 칸을 켜고 끄며 시계를 12/24 시간으로 바꾼다. 띠 전체를 끄는 것은 애드온 목록에서 애드온을 끄는 것이다(R44·R60).
- 설치 ZIP 하나: 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `b6392ea37d7cfefa123a3ef023ded82990c1be27826af6f54e23abc6bafd51c1` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core`·`DevilForever_StatusStrip` 둘만 넣는다).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- Claude 가 코드와 시험(게임 밖 Lua 5.1 시험 `Collection/tests/statusstrip/run.py`)으로 본 것: 글자 꼴, 1초 타이머 하나(지연은 30초마다, 시계는 분이 바뀔 때만), 칸을 끄면 그 칸의 이벤트·함수 호출이 멈춤, 저장 변수 읽기. 이 클라이언트(WoW Forever 1.60.1, Interface 16001)에서 아래 함수·이벤트가 있는지는 Claude 쪽에서 확인하지 못했다 — 이 검증이 본다. 특히 `BAG_CONTAINER_UPDATE`·`PLAYER_EQUIPMENT_CHANGED` 두 이벤트는 없으면 등록이 실패하고(오류가 나거나 등록 함수가 `false` 를 돌려줄 때), 그 사실이 `/dfstatus` 출력에 한 줄씩 나온다(그래도 띠는 돈다). 다만 이 클라이언트가 없는 이벤트 등록을 오류도 `false` 도 없이 받아 넘길 수도 있다(확인 필요 — 등록 실패가 오류 없이 지나갈 수도 있다). 그래서 줄이 없다고 그 이벤트가 있다는 뜻은 아니다 — 3번(장비 바꾼 뒤 내구도 칸이 바뀌는지)과 4번(가방 칸이 바뀌는지)이 실제로 오는지를 본다.
- 칸마다 값을 언제 새로 읽는지: 골드 = 돈이 바뀔 때, 가방 = 가방 내용이 바뀐 뒤, 내구도 = 내구도가 바뀌거나 장비를 바꿀 때, 시계 = 분이 바뀔 때, 지연 = 30초마다, FPS = 1초마다. 접속·`/reload`·순간이동 때 모든 칸을 한 번 읽고 5초 뒤 골드·가방·내구도를 한 번 더 읽는다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase16/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에서 `BugSack`·`!BugGrabber` 를 뺀 모든 애드온 폴더를 백업과 다른 폴더 `forever_moved_phase16/AddOns` 로 옮긴다(띠와 같은 정보를 보이는 애드온이 섞이지 않게 — 지우지 않는다. 백업 폴더에는 아무것도 더 넣지 않는다). 그 뒤 ZIP 에서 `!DevilForever_Core` 와 `DevilForever_StatusStrip` 두 폴더만 넣는다. BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 같고, AddOns 에 `!DevilForever_Core`·`DevilForever_StatusStrip`·`BugSack`·`!BugGrabber` 넷만 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치=<예/아니오> | 옮긴 애드온 수=<n>(옮긴 곳=<경로>) | AddOns 남은 폴더=<목록> | BugSack 켜짐=<예/아니오>`

## 1. 로드 · 띠가 뜨는지 · `/dfstatus` 출력

- 하는 법: 캐릭터 선택 화면 애드온 창에서 「DevilForever Core」 와 「DevilForever Status Strip」 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속한다. 화면 맨 아래 왼쪽에 여섯 칸 글자가 한 줄로 보이는지 본다. 화면 갈무리 하나를 남긴다. `/dfstatus` 를 친다. 그 다음 아래 두 줄을 차례로 친다 — 첫 줄은 띠가 쓰는 함수가 이 클라이언트에 있는지, 둘째 줄은 띠가 쓰는 번호 값을 찍는다:
  `/run local C=C_Container print(DevilForever_StatusStrip and DevilForever_StatusStrip.version, GetFramerate~=nil, GetNetStats~=nil, GetMoney~=nil, GetInventoryItemDurability~=nil, C and C.GetContainerNumFreeSlots~=nil, GetContainerNumFreeSlots~=nil)`
  `/run print(INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, BACKPACK_CONTAINER, NUM_BAG_SLOTS, C_Timer and C_Timer.NewTicker~=nil)`
  `/dfstatus` 출력 전체와 두 `/run` 출력을 `dfstatus.txt` 에 옮긴다.
- 기대 결과: 두 애드온이 「사용 가능」 으로 보인다. 띠에 `<골드> · 가방 <n> · 내구 <n>% · <시:분> · <n>/<n> ms · <n> fps` 순서의 여섯 칸이 보인다(koKR 클라이언트 기준. 칸 사이 구분 글자는 없고 띄어져 있다). `/dfstatus` 첫 줄은 `DevilForever 상태 띠: gold=켬 bags=켬 durability=켬 clock=켬 latency=켬 fps=켬 clock=24시간`. 그 아래에 `event <이벤트 이름> not registered: …` 줄이 있으면 그 이벤트는 이 클라이언트에 없는 것이다 — 결과로 적는다(실패가 아니다). 첫 `/run` 은 `1` 과 `true` 들이 기대값이고, `C_Container…` 와 `GetContainerNumFreeSlots` 는 둘 중 하나만 `true` 여도 된다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 표시=<Core: …/Strip: …> | 띠 보임=<예/아니오> | 칸 순서=<보인 그대로> | 등록 실패 이벤트=<이름들/없음> | run1=<출력> | run2=<출력> | 갈무리=<파일 이름>`

## 2. 골드

- 하는 법: 가방 창 아래의 돈 표시와 띠의 골드 칸을 비교한다. `/run print(DevilForever_StatusStrip:GetValue("gold")) print(GetMoney())` 를 친다. 상인에게 물건 하나를 팔거나 사서(또는 우편·퀘스트 보상으로) 돈을 바꾼 뒤 띠 칸이 곧바로 바뀌는지 본다.
- 기대 결과: 띠 칸이 가방 창 돈과 같다. 꼴은 `1,234g 05s 07c`(골드가 있을 때), `5s 07c`(골드 0, 실버가 있을 때), `7c`(그 밖) — 글자 색 없음 — 동전 색은 넣지 않는다(외관 단계에서도 칸 전체에 한 색만 입힌다). `/run` 의 두 숫자(구리 단위)가 같다. 돈이 바뀌면 1초 안에 칸이 바뀐다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 띠=<칸 글자> | 가방 창=<보인 그대로> | 출력=<줄> | 돈 바꾼 뒤 바뀜=<예/아니오>`

## 3. 내구도

- 하는 법: 캐릭터 창(C)을 열고 장비마다 내구도를 본다(마우스를 올리면 풍선에 `내구도 n / m` 이 보인다). 가장 낮은 장비의 `n/m×100` 을 내림한 값과 띠 칸을 비교한다. 장비 하나를 벗었다 다시 입고 칸이 바뀌는지(가장 낮은 장비를 벗으면 다음으로 낮은 값으로) 본다. 몹과 싸우거나 죽어 내구도가 줄면 칸이 따라 바뀌는지 본다(할 수 있으면). `/run print(DevilForever_StatusStrip:GetValue("durability"))` 를 친다.
- 기대 결과: 띠 칸 `내구 <n>%` 의 n 이 가장 낮은 장비의 값과 같다(평균이 아니다). 장비를 바꾸거나 내구도가 줄면 칸이 바뀐다. 내구도 있는 장비가 하나도 없으면 `내구 -`.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 띠=<칸 글자> | 가장 낮은 장비=<이름 n/m> | 장비 바꾼 뒤 바뀜=<예/아니오/못 봄> | 싸운 뒤 바뀜=<예/아니오/못 봄> | 출력=<줄>`

## 4. 가방 빈칸

- 하는 법: 가방을 모두 열고 일반 가방(배낭과 일반 가방 네 칸)의 빈칸 수를 센다. 화살통·탄약 주머니·전문 기술 가방이 있으면 그 빈칸은 세지 않는다. 띠 칸과 비교한다. 물건 하나를 줍거나 버린 뒤 칸이 바뀌는지 본다. 화살통·탄약 주머니·전문 기술 가방이 있고 그 안에 빈칸이 있으면, 그 상태에서 띠 숫자가 손으로 센 일반 가방 빈칸 수와 같은지 본다(특수 가방의 빈칸이 더해지지 않았는지). 일반 가방에서 탄약을 특수 가방으로 옮기면 일반 가방 빈칸이 늘어나므로 띠 숫자가 바뀌는 것이 맞다. `/run print(DevilForever_StatusStrip:GetValue("bags"))` 를 친다.
- 기대 결과: 띠 칸 `가방 <n>` 의 n 이 일반 가방 빈칸 수와 같다. 물건이 들고 나면 바뀐다. 화살통·탄약 주머니·전문 기술 가방에 빈칸이 있어도 띠 숫자는 일반 가방 빈칸 수와 같다.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 띠=<칸 글자> | 센 빈칸=<n> | 특수 가방=<종류·그 안 빈칸 n/없음> | 줍기·버리기 뒤 바뀜=<예/아니오> | 특수 가방 빈칸 있을 때 같음=<예/아니오/특수 가방 없음> | 출력=<줄>`

## 5. 지연 · FPS

- 하는 법: 게임 메뉴(ESC)나 마이크로 메뉴의 네트워크 표시(지연 ms)와 띠의 지연 칸을 비교한다. 클라이언트의 프레임 수 표시(Ctrl+R — 이 클라이언트에 있으면)와 FPS 칸을 비교한다. 1분 동안 지켜보며 FPS 칸이 1초마다, 지연 칸이 30초쯤마다 바뀌는지 본다. `/run print(DevilForever_StatusStrip:GetValue("latency")) print(GetNetStats())` 를 친다.
- 기대 결과: 지연 칸 `<집>/<월드> ms` 가 게임 표시와 비슷하다(게임 표시가 하나뿐이면 둘 중 하나와 같다). FPS 칸 `<n> fps` 가 프레임 표시와 비슷하다. `/run` 첫 줄의 두 숫자(띠가 가진 집·월드 값)가 둘째 줄 `GetNetStats()` 출력의 셋째(집)·넷째(월드) 값과 각각 100 ms 안의 차이면 통과다. 띠는 지연을 30초마다 한 번 읽으므로 그 사이 바뀐 값만큼 다를 수 있다 — 이것은 정상이고, 100 ms 를 넘을 때만 실패로 적는다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 지연 띠=<칸> | 게임 지연=<보인 그대로/표시 없음> | FPS 띠=<칸> | 게임 FPS=<보인 그대로/표시 없음> | 바뀌는 간격=<FPS ≈n초·지연 ≈n초> | 출력=<줄>`

## 6. 시계 · 12/24 시간

- 하는 법: PC(Windows 작업 표시줄) 시계와 띠의 시계 칸을 비교한다. 분이 바뀌는 순간 띠도 1초 안에 바뀌는지 본다. `/dfstatus clock 12` 를 치고 칸 꼴을 본다. `/dfstatus clock 24` 로 되돌린다. 미니맵 시계(게임 시계)가 보이면 그 시각과 띠 시각도 적는다.
- 기대 결과: 띠 시계가 PC 시계와 같다(서버 시간이 아니라 PC 시간이다). 24 시간 꼴은 `09:05`, 12 시간 꼴은 `오전 9:05` / `오후 9:05`(자정은 `오전 12:05`, 정오는 `오후 12:00`). 미니맵 시계도 보이면 같은 정보가 두 곳에 보이는 것이다 — 「미니맵 시계와 겹침」 으로 적는다. 하나를 끌지는 이 검증에서 정하지 않는다(Claude 최종 보고에서 사용자가 정한다).

결과 한 줄 양식: `6 | <통과/실패/못 함> | 띠 시계=<보인 그대로> | PC 시계=<보인 그대로> | 분 바뀜 따라감=<예/아니오> | 12시간 꼴=<보인 그대로> | 미니맵 시계=<보임: 시각/안 보임> | 미니맵 시계와 겹침=<예/아니오>`

## 7. `/dfstatus` 로 칸 켜고 끄기

- 하는 법: `/dfstatus fps off` 를 친다. FPS 칸이 사라지는지 본다. `/dfstatus gold off` 를 친다. 골드 칸이 사라지고 나머지 칸이 왼쪽으로 당겨지는지 본다. `/dfstatus gold on`·`/dfstatus fps on` 으로 되돌린다. 잘못된 줄 `/dfstatus fps maybe` 를 치고 사용법 한 줄이 나오며 아무것도 바뀌지 않는지 본다. 칸을 끈 동안 `/run print(DevilForever_StatusStrip:IsItemEnabled("gold"), DevilForever_StatusStrip:GetValue("gold"))` 를 친다.
- 기대 결과: 끈 칸은 사라지고 나머지는 빈자리 없이 왼쪽부터 붙는다. 켜면 그 자리에 바로 값이 돌아온다. 잘못된 줄은 `사용법: /dfstatus · …` 한 줄만 찍는다. 골드를 끈 동안 출력은 `false nil`.

결과 한 줄 양식: `7 | <통과/실패/못 함> | fps off=<사라짐/그대로> | gold off 뒤 당겨짐=<예/아니오> | 다시 켬=<값 돌아옴/안 돌아옴> | 잘못된 줄=<사용법 한 줄/다른 결과> | 출력=<줄>`

## 8. 애드온 끄기

- 하는 법: (가) 애드온 목록(ESC → 애드온, 또는 캐릭터 선택 화면)에서 「DevilForever Status Strip」 만 끄고 `/reload`(또는 재접속)한다. 띠가 없는지 보고 `/dfstatus` 가 알 수 없는 명령으로 나오는지 본다. (나) 다시 켜고 이번에는 「DevilForever Core」 만 끈 채 `/reload` 한다 — 띠는 Core 없이도 돈다(띠 코드는 Core 를 부르지 않는다). 여섯 칸이 그대로 보이는지 본다. (다) Core 를 다시 켜고 `/reload` 한다.
- 기대 결과: (가) 띠 없음, `/dfstatus` 는 알 수 없는 명령. (나) 띠와 여섯 칸 값이 그대로 보인다. (다) 원래대로.

결과 한 줄 양식: `8 | <통과/실패/못 함> | Strip 끔=<띠 없음/다른 결과> | 끈 뒤 /dfstatus=<알 수 없는 명령/다른 결과> | Core 만 끔=<띠 보임/안 보임> | 되켬=<예/아니오>`

## 9. `/reload` · 재접속 · 다른 캐릭터 뒤 유지

- 하는 법: `/dfstatus bags off` 와 `/dfstatus clock 12` 를 친다. `/reload` 뒤 가방 칸이 꺼져 있고 시계가 12 시간 꼴인지 본다. 게임을 완전히 종료했다가 다시 접속해 다시 본다. 같은 계정의 다른 캐릭터로 접속해서도 본다(이 설정은 계정 공통이다). 게임을 종료한 상태에서 `_forever_/WTF/Account/<계정>/SavedVariables/DevilForever_StatusStrip.lua` 를 열어 내용을 적는다. 끝나면 `/dfstatus bags on`·`/dfstatus clock 24` 로 되돌린다.
- 기대 결과: `/reload` 뒤·재접속 뒤·다른 캐릭터에서 모두 가방 칸 꺼짐·12 시간 꼴이 남는다. 저장 파일에 `DevilForever_StatusStripDB = { … items = { … bags = false … }, clock24 = false, schema = 1 }` 꼴이 보인다(줄 순서는 달라도 된다).

결과 한 줄 양식: `9 | <통과/실패/못 함> | reload 뒤=<남음/돌아감> | 재접속 뒤=<남음/돌아감> | 다른 캐릭터=<같음/다름/캐릭터 없음> | 저장 파일=<경로·핵심 줄> | 되돌림=<예/아니오>`

## 10. 전투 한 번 · 오류

- 하는 법: 몹 여럿과 한 번 싸운다(1분 이상). 싸우는 동안 띠 칸(특히 FPS·시계)이 계속 바뀌는지, 끊김이 느껴지는지 본다. 띠가 있는 화면 아래쪽(다른 버튼이 겹쳐 있으면 그 버튼)을 눌러 띠가 클릭을 막지 않는지 본다. 싸움이 끝난 뒤 `/bugsack` 을 열어 이번 검증 동안 쌓인 오류를 모두 센다(있으면 문구 전체를 `bugsack.txt` 에). `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 도 센다.
- 기대 결과: 전투 중에도 칸이 바뀌고 끊김이 없다. 띠는 클릭을 막지 않는다. 오류 0, 차단 오류 0.

결과 한 줄 양식: `10 | <통과/실패/못 함> | 전투 중 칸 바뀜=<예/아니오> | 끊김=<없음/있음: 설명> | 클릭 막음=<아니오/예: 어디> | 오류 수=<n> | 차단 오류 수=<n>`

## 11. 결과 올리기 · 전체 되돌리기

- 하는 법: 0–10 의 결과 줄을 `References/codex-verify/phase16/result.md` 에 순서대로 적고 `dfstatus.txt`·`bugsack.txt`(있으면)·갈무리와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase16`, `WTF_after_phase16`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다). `forever_moved_phase16/AddOns` 는 백업에 이미 같은 것이 있으니 그대로 둔다.
- 기대 결과: `References/codex-verify/phase16/result.md` 가 있다, 되돌린 뒤 AddOns 폴더 목록이 백업과 같다.

결과 한 줄 양식: `11 | <통과/실패/못 함> | 올린 파일=<목록> | 백업 되돌림=<예/아니오> | 되돌린 뒤 AddOns 목록 같음=<예/아니오> | 커밋=<해시>`

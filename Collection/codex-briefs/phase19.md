# Codex 실사용 검증 발주문 — Phase 19 (경험치·평판 바 · Experience Forever 2.0.4)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/ef` 입력은 모두 사람이 하듯 직접 한다. 막대의 자리·크기·질감·글꼴은 이 Phase 에서 보지 않는다(외관 단계 몫 — `appearance-19.md`).

- 결과를 올릴 자리: `References/codex-verify/phase19/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 둘:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core` 하나만 넣는다).
  - Experience Forever 원본 `References/addon-sources/experience-forever/ExperienceForever.zip`, sha256 `2bfdda8717b6e0d40fcc1847b233e23b187f839c75749c15fe2ed430ecf15b85`. 안의 `ExperienceForever` 폴더 하나를 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 구성: 경험치·평판·사냥꾼 소환수 경험치를 **Experience Forever 하나**가 맡는다. Dominos 묶음 안의 `Dominos_Progress`(경험치·평판 막대)는 쓰지 않는다 — 같은 기능을 두 애드온이 맡지 않게 넣지 않고, 켜져 있지 않은지 확인한다(5번). 모음집은 Experience Forever 기본값 파일을 넣지 않는다: Experience Forever 자기 기본값이 이미 소환수 막대 켬·평판 막대 켬·게임 기본 경험치 막대 숨김이다(`ExperienceForever/ExperienceForever.lua:44,59,82`). 설정은 계정 공통이다(같은 계정의 모든 캐릭터가 같은 값).
- Experience Forever 설정 창은 `/ef` 로 연다(ESC → 설정 → 애드온의 「Experience Forever」 와 같은 창). 항목 이름은 영어 그대로다.
- 사냥꾼 캐릭터(소환수 있음)가 있으면 4번을 한다. 없으면 4번은 `못 함` 으로 적는다. 만렙 캐릭터만 있으면 2번은 `못 함` 이고 막대에 보이는 글자만 적는다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase19/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 두 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에서 `BugSack`·`!BugGrabber` 를 뺀 모든 애드온 폴더를 백업과 다른 폴더 `forever_moved_phase19/AddOns` 로 옮긴다(`Dominos_Progress` 와 다른 경험치 막대 애드온이 섞이지 않게 — 지우지 않는다. 백업 폴더에는 아무것도 더 넣지 않는다). 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/ExperienceForever.lua`(와 `.bak`)가 있으면 `forever_moved_phase19/WTF/` 로 옮긴다. 그 뒤 모음집 ZIP 의 `!DevilForever_Core` 와 Experience Forever ZIP 의 `ExperienceForever` 를 넣는다. BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 둘 다 같고, AddOns 에 `!DevilForever_Core`·`ExperienceForever`·`BugSack`·`!BugGrabber` 넷만 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/EF)=<예·예> | 옮긴 애드온 수=<n>(옮긴 곳=<경로>) | EF 저장 파일 옮김=<예/없었음> | AddOns 남은 폴더=<목록> | BugSack 켜짐=<예/아니오>`

## 1. 로드·처음 켜짐·기본값

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Experience Forever·DevilForever Core 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속한다. 화면 위쪽 가운데(Experience Forever 기본 자리)에 경험치 막대가 뜨는지 본다. 다음 두 줄을 친다:
  `/run local E=LibStub("AceAddon-3.0"):GetAddon("ExperienceForever") local g=E.db.global print(g.showPetBar,g.showRepBar,g.repFollowWatched,g.hideDefaultXpBar,ExperienceForeverFrame:IsShown())`
  `/run local C=DevilForever_Core local s=C.Defaults:GetStatus("ExperienceForever") print(s.registered,s.loaded,C:GetAddonInfo("ExperienceForever").defaults,#C:GetFrameNames("ExperienceForever"))`
  `/bugsack` 을 열고 `ExperienceForever`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase19/bugsack.txt` 에 복사한다.
- 기대 결과: 둘 다 「사용 가능」, 막대 하나가 뜬다, 첫 출력 `true true true true true`, 둘째 출력 `false true nil 2`(Core 는 Experience Forever 기본값을 넣지 않는다 — 등록 표에 프레임 둘), 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 막대=<뜸/안 뜸> | 첫 출력=<줄> | 둘째 출력=<줄> | 오류 수=<n>`

## 2. 경험치를 얻으면 막대가 움직인다

- 하는 법: 경험치를 주는 몹을 하나 잡는다(퀘스트 완료는 되돌릴 수 없으므로 쓰지 않는다). 잡기 전과 잡은 뒤에 한 번씩 친다:
  `/run local E=LibStub("AceAddon-3.0"):GetAddon("ExperienceForever") print(UnitLevel("player"),UnitXP("player"),UnitXPMax("player"),E.ProgressBar:GetValue())`
  막대 가운데 글자(레벨·「현재 / 필요」 경험치)가 바뀌는지 본다. 레벨이 오르면 막대가 처음부터 다시 차는지도 적는다.
- 기대 결과: 뒤의 둘째 값(현재 경험치)이 앞보다 크고, 넷째 값(막대 값)이 둘째 값과 같다. 막대 채움과 가운데 글자가 함께 늘어난다. 만렙이면 `못 함`, 막대 글자에 `Max Level` 이 보이는지 적는다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 잡기 전=<줄> | 잡은 뒤=<줄> | 막대 채움·글자=<늘어남/안 바뀜> | 레벨 오름=<처음부터 다시 참/다른 결과/없었음>`

## 3. 평판 막대

- 하는 법: 먼저 지금 경험치 막대로 표시 중인 진영을 적는다(평판 창 — 캐릭터 창의 평판 탭 — 에서 표시가 켜진 진영 이름, 없으면 「없음」. 끝에서 이 값으로 되돌린다). 평판 탭에서 진영 하나를 누르면 나오는 작은 창의 「경험치 막대로 표시」 칸을 켠다(koKR 이름은 확인 필요 — 보인 이름을 적는다). 경험치 막대 바로 아래에 평판 막대가 생기는지 본다. 다음 줄을 친다:
  `/run local E=LibStub("AceAddon-3.0"):GetAddon("ExperienceForever") local d=E.repData print(E.RepBar:IsShown(),d and d.name,d and d.value,E.RepBar:GetValue())`
  그 진영 평판을 주는 몹을 잡은 뒤 다시 친다(퀘스트 완료는 쓰지 않는다). 평판 막대에 마우스를 올려 풍선 도움말이 뜨는지 본다. 그 칸을 끄고 평판 막대가 사라지는지 본다. 끝나면 처음 적은 진영의 칸을 다시 켠다(「없음」 이었으면 끈 채로 둔다).
- 기대 결과: 켜면 평판 막대가 뜨고 첫 값 `true`, 둘째 값이 고른 진영 이름. 평판을 얻은 뒤 셋째 값이 늘어난다(얻을 곳이 없으면 그 칸만 `못 봄`). 끄면 평판 막대가 사라진다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 원래 진영=<이름/없음> | 칸 이름=<보인 이름> | 고른 진영=<이름> | 켬 출력=<줄> | 얻은 뒤 출력=<줄/못 봄> | 풍선 도움말=<뜸/안 뜸> | 끔=<사라짐/남음> | 원래 진영 되돌림=<예/아니오>`

## 4. 사냥꾼 소환수 경험치

- 하는 법: 사냥꾼 캐릭터로 접속해 소환수가 나와 있는지 적고(끝에서 되돌린다), 없으면 부른다. 평판 막대가 켜져 있으면 그 아래, 아니면 경험치 막대 바로 아래에 소환수 막대가 생기는지 본다. 다음 줄을 친다:
  `/run local E=LibStub("AceAddon-3.0"):GetAddon("ExperienceForever") print(select(2,UnitClass("player")),UnitExists("pet"),E.PetBar:IsShown(),E.PetBar:GetValue()) if GetPetExperience then print(GetPetExperience()) end`
  소환수와 함께 몹을 잡은 뒤 다시 친다. 소환수를 돌려보낸 뒤 막대가 사라지는지 본다. 처음에 소환수가 나와 있었으면 다시 부른다.
- 기대 결과: 첫 출력 `HUNTER true true <값>`, 다음 줄 `<현재> <필요>`(넷째 값과 현재가 같음). 잡은 뒤 값이 늘어난다(소환수가 만렙이면 그대로일 수 있다 — 보인 그대로 적는다). 소환수를 돌려보내면 막대가 사라진다. 사냥꾼이 없으면 `못 함`.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 부른 뒤 출력=<줄> | 잡은 뒤 출력=<줄> | 막대 자리=<평판 아래/경험치 아래> | 돌려보냄=<사라짐/남음> | 처음 소환수=<나와 있음/없음> | 다시 부름=<예/해당 없음> | 사냥꾼=<있음/없음>`

## 5. 한 기능은 한 애드온 — 게임 기본 경험치 막대·Dominos_Progress

- 하는 법: 화면 아래 게임 기본 경험치(평판) 막대 자리를 본다. 다음 줄을 친다:
  `/run local m=StatusTrackingBarManager print(m~=nil,m and m:GetAlpha(),DevilForever_Core:IsAddonLoaded("Dominos_Progress"))`
  캐릭터 선택 화면 애드온 창에 `Dominos Progress` 가 보이는지 본다. `_forever_/Interface/AddOns` 에 `Dominos_Progress` 폴더가 없는지 본다.
- 기대 결과: 게임 기본 경험치 막대가 보이지 않는다(Experience Forever 가 투명하게 한다), 출력 `true 0 false`. 첫 값이 `false` 면 이 클라이언트에 그 관리자가 없는 것이다 — 그때는 게임 기본 막대가 보이는지 보인 그대로 적는다. 애드온 창에 Dominos Progress 가 없고, 폴더도 없다.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 기본 경험치 막대=<안 보임/보임> | 출력=<줄> | 애드온 창 Dominos Progress=<없음/있음(켬·끔)> | 폴더=<없음/있음>`

## 6. 끄기

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Experience Forever 만 끄고 접속한다. 1번 둘째 `/run` 줄을 친다. 화면에 Experience Forever 막대가 없는지, 게임 기본 경험치 막대가 다시 보이는지 본다. 끝나면 다시 켜고 접속해 막대가 돌아오는지 본다.
- 기대 결과: 끔 = Experience Forever 막대 없음, 게임 기본 경험치 막대가 보임, 출력 `false false nil 2`, 오류 0. 다시 켬 = 막대가 1번과 같이 돌아온다.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 끔=<막대 없음/다른 결과> | 기본 막대=<보임/안 보임> | 끔 출력=<줄> | 다시 켬=<돌아옴/다른 결과> | 오류 수=<n>`

## 7. `/reload` · 재접속 뒤 유지

- 하는 법: `/ef` 로 설정 창을 열고 「Show Reputation Bar」 를 끈다. `/reload` 뒤 1번 첫 `/run` 줄을 친다. 게임을 종료했다가 다시 접속해 한 번 더 친다. 같은 계정의 다른 캐릭터로 접속해 한 번 더 친다(설정이 계정 공통인지). 경험치 막대를 끌어 옮긴 뒤 `/reload` 해 자리가 남는지도 본다. 끝나면 「Show Reputation Bar」 를 다시 켜고 `/ef reset` 으로 막대 자리를 되돌린다.
- 기대 결과: reload 뒤·재접속 뒤·다른 캐릭터 모두 첫 출력 둘째 값이 `false`(나머지 `true`), 옮긴 자리가 남는다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | reload 뒤=<줄> | 재접속 뒤=<줄> | 다른 캐릭터=<줄/캐릭터 없음> | 옮긴 자리=<남음/돌아감> | 되돌림=<예/아니오>`

## 8. 오류·결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `ExperienceForever`·`DevilForever` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다 — Experience Forever 는 게임 기본 경험치 막대를 숨길 때 차단 창을 피하려고 투명하게 하는 방식을 쓴다, `ExperienceForever/ExperienceForever.lua:1220–1222`). 0–8 의 결과 줄을 `References/codex-verify/phase19/result.md` 에 순서대로 적고, 막대 셋(경험치·평판·소환수 — 있는 것만)이 보이는 화면 갈무리 하나와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase19`, `WTF_after_phase19`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: 오류 0, `References/codex-verify/phase19/result.md` 가 있다.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 백업 되돌림=<예/아니오> | 커밋=<해시>`

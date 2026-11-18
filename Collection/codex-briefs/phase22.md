# Codex 실사용 검증 발주문 — Phase 22 (테마 바꾸기 · DevilForever Core)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/dfp` 입력은 모두 사람이 하듯 직접 한다.

- 결과를 올릴 자리: `References/codex-verify/phase22/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 대화창에 찍힌 `[DF 설정]`·`[DFTC]` 줄은 항목마다 `chat.md` 에 그대로 옮긴다.
- 설치 ZIP 하나: 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문은 `!DevilForever_Core` 하나만 넣는다).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 구성: 테마는 Core 의 토큰 세트다. 기본 테마 `devil` 의 값과 대안 테마(`appearance-22.md`)는 Codex 외관 폴더가 넣는다. 그 폴더가 아직 저장소(`References/codex-appearance/2/`, `.../22/`)에 없으면 아래 시험 애드온 `DFThemeCheck` 만으로 1–7을 하고 8은 `못 함` 으로 적는다. 시험 애드온은 시험용 세트 둘(`check_a`·`check_b`)을 넣고, 테마가 바뀔 때마다 스킨 대신 두 듣는 함수(`skin1`·`skin2`)가 `[DFTC]` 줄을 찍는다. 시험 값은 겉보기와 무관하다.
- 테마 바꾸기는 `/dfp theme <이름>` 으로 바로 된다(`/dfp go` 없음). 전투 중에는 명령이 거절되고, 함수로 부른 바꾸기는 전투가 끝난 뒤 된다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase22/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에서 `BugSack`·`!BugGrabber` 를 뺀 모든 애드온 폴더를 백업과 다른 폴더 `forever_moved_phase22/AddOns` 로 옮긴다(다른 애드온이 섞이지 않게 — 지우지 않는다. 백업 폴더에는 아무것도 더 넣지 않는다). 그 뒤 ZIP 에서 `!DevilForever_Core` 하나만 넣는다. `_forever_/Interface/AddOns/DFThemeCheck/` 폴더를 만들고 아래 두 파일을 그대로 쓴다. 외관 폴더가 저장소에 있으면 그것도 넣고 이름을 적는다. BugSack·!BugGrabber 가 켜져 있는지 본다.
  - `DFThemeCheck.toc`:
    ```
    ## Interface: 16001
    ## Title: DF Theme Check
    ## Dependencies: !DevilForever_Core
    DFThemeCheck.lua
    ```
  - `DFThemeCheck.lua`:
    ```lua
    local T = DevilForever_Core.Theme
    T:RegisterSet("check_a", {["color.accent"] = {1, 0, 0, 1}, ["font.size.normal"] = 14})
    T:RegisterSet("check_b", {["color.accent"] = {0, 0, 1, 1}})
    DFTC = {}
    for _, who in ipairs({"skin1", "skin2"}) do
      T:RegisterCallback(who, function(new, old)
        DFTC[#DFTC + 1] = who .. ":" .. tostring(old) .. ">" .. tostring(new) .. (InCombatLockdown() and ":combat" or "")
        print("[DFTC] " .. DFTC[#DFTC])
      end)
    end
    ```
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 같고, AddOns 에 `!DevilForever_Core`·`DFThemeCheck`·`BugSack`·`!BugGrabber`(와 넣었으면 외관 폴더)만 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치=<예/아니오> | 옮긴 애드온 수=<n>(옮긴 곳=<경로>) | AddOns 남은 폴더=<목록> | 외관 폴더=<이름/없음> | BugSack 켜짐=<예/아니오>`

## 1. 로드 · 테마 목록 · 빠진 토큰 알림

- 하는 법: 캐릭터 선택 화면 애드온 창에서 넣은 애드온이 모두 「사용 가능」 인지 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속한다. `/dfp help` 에 `/dfp theme` 줄이 있는지 본다. `/dfp theme` 를 친다. 다음 줄을 친다:
  `/run for _,x in ipairs(DevilForever_Core:GetStatusLog()) do if tostring(x.subject):find("Theme") then print(x.kind,x.subject,x.message) end end`
- 기대 결과: 목록에 `check_a — 빠진 토큰 18개는 devil 값`, `check_b — 빠진 토큰 19개는 devil 값`, `devil (지금)` 이 있다(외관 폴더를 넣었으면 그 테마도 — 완성 테마는 「빠진 토큰」 이 없다). `/run` 출력에 `info Theme:check_a 18 tokens not set …`, `info Theme:check_b 19 tokens not set …` 두 줄이 있다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 사용 가능=<예/다른 결과> | help 줄=<있음/없음> | 목록=<줄들> | 상태 기록=<줄들>`

## 2. 테마 바꾸기

- 하는 법: `/dfp theme check_a` 를 친다. 다음 줄을 친다:
  `/run local T=DevilForever_Core.Theme local c=T:Get("color.accent") print(T:GetSet(),c and c[1],c and c[3],T:Get("font.size.normal"))`
  `/dfp theme check_b` 를 치고 같은 `/run` 줄을 다시 친다. `/dfp theme check_b` 를 한 번 더 친다. `/dfp status` 를 친다.
- 기대 결과: 첫 명령에 `[DF 설정] 테마 check_a 으로 바꿈`, 첫 출력 `check_a 1 0 14`. 둘째 명령 뒤 출력 `check_b 0 1` 다음 칸은 `devil` 의 값(외관 폴더가 없으면 `nil`). 셋째 명령에 `[DF 설정] 이미 check_b 테마`. status 에 `테마: check_b` 줄.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 명령 줄=<줄들> | 출력 check_a=<줄> | 출력 check_b=<줄> | 같은 이름=<줄> | status=<줄>`

## 3. 모든 듣는 쪽이 따라오는지

- 하는 법: 2번에서 찍힌 `[DFTC]` 줄을 본다. 다음 줄을 친다: `/run print(table.concat(DFTC," "))`. 외관 폴더를 넣었으면 2번의 바꿈마다 공통 외관과 각 스킨의 모습이 함께 바뀌었는지 보고 갈무리를 남긴다.
- 기대 결과: 바꿈 한 번마다 `skin1`·`skin2` 가 한 줄씩(`skin1:devil>check_a skin2:devil>check_a skin1:check_a>check_b skin2:check_a>check_b`), 같은 이름으로 다시 친 셋째 명령에는 줄이 없고, `:combat` 이 붙은 줄이 없다. 외관 폴더가 있으면 남아 있는 옛 테마 모습이 없다. 외관 폴더를 넣었으면 로드 때 `devil` 값이 들어오며 `skin1:devil>devil` 같은 줄이 앞에 더 있을 수 있다(그대로 적는다).

결과 한 줄 양식: `3 | <통과/실패/못 함> | DFTC=<출력> | 외관이 따라옴=<예/아니오(남은 곳)/외관 없음> | 갈무리=<파일 이름/없음>`

## 4. `/reload` · 재접속 뒤 유지

- 하는 법: `check_b` 인 채로 `/reload` 한다. `/dfp theme` 와 `/run print(DevilForever_CoreDB.theme.active,DevilForever_Core.Theme:GetSet(),table.concat(DFTC," "))` 를 친다. 게임을 완전히 종료했다가 다시 접속해 같은 두 줄을 다시 친다.
- 기대 결과: 두 번 모두 목록에 `check_b (지금) — 빠진 토큰 19개는 devil 값`, 출력 `check_b check_b skin1:devil>check_b skin2:devil>check_b`(접속 때 저장된 테마로 한 번 바뀐다 — 외관 폴더가 있으면 3번처럼 `devil>devil` 줄이 더 있을 수 있다).

결과 한 줄 양식: `4 | <통과/실패/못 함> | reload 뒤=<목록·출력> | 재접속 뒤=<목록·출력>`

## 5. 전투 중에는 미룸

- 하는 법: 훈련용 허수아비나 몹과 싸움을 시작한다. 전투 중에 `/dfp theme check_a` 를 친다. 이어서 `/run print(DevilForever_Core.Theme:SetActiveSet("check_a"),DevilForever_Core.Theme:GetSet())` 를 친다. 전투가 끝날 때까지 `[DFTC]` 줄이 나오는지 본다. 전투가 끝나면 `/run print(DevilForever_Core.Theme:GetSet(),DevilForever_CoreDB.theme.active,DFTC[#DFTC])` 를 친다.
- 기대 결과: 명령은 `[DF 설정] 안 함: 전투 중 — 바꾼 것 없음`. `/run` 은 `true check_b check_a`(첫 값 `true` 다음은 지금 테마 — 아직 `check_b` — 와 기다리는 테마 `check_a`). 전투 중 `[DFTC]` 줄 없음. 전투가 끝난 바로 뒤 `[DFTC] skin1:check_b>check_a`·`skin2:…` 가 나오고, 마지막 출력은 `check_a check_a skin2:check_b>check_a`(`:combat` 없음).

결과 한 줄 양식: `5 | <통과/실패/못 함> | 명령=<줄> | 전투 중 출력=<줄> | 전투 중 DFTC 줄=<없음/줄> | 전투 뒤=<줄들>`

## 6. 모르는 이름은 거절 · 등록이 없어진 테마

- 하는 법: `/dfp theme nope` 를 친다. `/run print(DevilForever_Core.Theme:SetActiveSet("nope"),DevilForever_Core.Theme:GetSet())` 를 친다. 그 뒤 `/dfp theme check_a` 인 채로 캐릭터 선택 화면으로 나가 애드온 창에서 `DFThemeCheck` 를 끄고 접속한다. `/dfp theme` 를 치고 1번의 상태 기록 `/run` 줄을 다시 친다. 다시 나가서 `DFThemeCheck` 를 켜고 접속해 `/dfp theme` 를 친다.
- 기대 결과: 명령은 `[DF 설정] 안 함: nope: 등록된 테마가 아님 — /dfp theme 로 목록`, `/run` 은 `false check_a nil`(지금 테마 그대로, 기다리는 테마 없음). 끈 채 접속하면 목록이 `devil (지금)` 과 `저장된 테마 check_a 은 등록돼 있지 않음 — devil 사용`, 상태 기록에 `skip Theme saved set check_a is not registered; base set kept`. 다시 켜고 접속하면 `check_a (지금)`.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 모르는 이름=<줄·출력> | 끈 채 접속=<목록·상태 기록> | 다시 켠 뒤=<목록>`

## 7. 설정 저장본에 테마가 들어가는지

- 하는 법: `check_a` 인 채로 `/dfp save t22` → `/dfp go`. 다시 불러온 뒤 `/dfp theme check_b`. `/dfp show t22` 를 친다. `/dfp restore t22` → `/dfp go`. 다시 불러온 뒤 `/dfp theme` 를 친다.
- 기대 결과: show 에 `common !DevilForever_Core 편집값·테마·preset — 씀` 줄. 되돌린 뒤 `check_a (지금)`.

결과 한 줄 양식: `7 | <통과/실패/못 함> | show 줄=<줄> | 되돌린 뒤=<목록>`

## 8. 대안 테마 화면 (외관 폴더가 있을 때만)

- 하는 법: `devil` 과 `appearance-22.md` 로 받은 테마마다 `/dfp theme <이름>` 으로 바꾸고 지금 해상도에서 갈무리 하나씩. 패널·구분선·장식·글꼴·상태 막대가 함께 바뀌는지, 글자가 읽히는지 본다.
- 기대 결과: 테마마다 질감·글꼴·막대·장식이 함께 바뀌고 남는 옛 모습이 없다. 외관 폴더가 없으면 `못 함`.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 해상도=<가로×세로> | 테마=<이름: 갈무리 파일, …> | 남은 곳=<없음/목록>`

## 9. 오류·결과 올리기

- 하는 법: `/bugsack` 을 열어 이번 검증 동안 쌓인 `DevilForever`·`DFThemeCheck`(와 외관 폴더) 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 문구 전체를 `bugsack.txt` 에 복사). 0–9 의 결과 줄을 `References/codex-verify/phase22/result.md` 에 순서대로 적고 `chat.md`·갈무리·`bugsack.txt`(있으면)와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase22`, `WTF_after_phase22`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다. 시험 애드온 `DFThemeCheck` 와 고른 테마·저장본 `t22` 도 이것으로 시작 전으로 돌아간다).
- 기대 결과: 오류 0, `References/codex-verify/phase22/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 백업 되돌림=<예/아니오> | 커밋=<해시>`

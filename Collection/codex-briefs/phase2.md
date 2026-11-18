# Codex 실사용 검증 발주문 — Phase 2 (`!DevilForever_Core`)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run` 입력은 모두 사람이 하듯 직접 한다.

- 결과를 올릴 자리: `References/codex-verify/phase2/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP: `outputs/collection/DevilForever-collection.zip`, sha256 `2460bd1de6dd86f71dc15f7a990144fe2a45b7da2561eb88dd0a7fcbe5ef9df4` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase2/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. ZIP 의 sha256 이 위 값과 같은지 본 뒤 ZIP 을 풀어 `Interface/AddOns/!DevilForever_Core` 를 `_forever_/Interface/AddOns/` 에 넣는다(같은 이름 폴더가 있으면 그 폴더를 백업 쪽으로 옮긴 뒤 넣는다). BugSack·!BugGrabber(Phase 1 에서 설치)가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 같고, 폴더가 설치된다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치=<예/아니오> | BugSack 켜짐=<예/아니오>`

## 1. 로드와 Lua 오류

- 하는 법: 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 「DevilForever Core」 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 `/bugsack` 을 열고 `!DevilForever_Core` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase2/bugsack.txt` 에 복사한다.
- 기대 결과: 「사용 가능」, Core 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창 표시=<사용 가능/오래됨/의존 없음/안 보임> | Core 오류 수=<n>`

## 2. 준비 상태와 토큰 이름

- 하는 법: 대화 입력창에 직접 친다.
  `/run local C=DevilForever_Core; print(C and C:IsReady(), #C.Theme:ListTokens(), C.Theme:GetSet(), #C:ListAddons(), #C:GetStatusLog())`
- 기대 결과: `true 20 devil 67 0` (준비됨, 토큰 이름 20개, 활성 세트 devil, 등록 표 67개 폴더, 상태 기록 0줄). 상태 기록이 0 이 아니면 다음을 쳐서 나온 줄을 그대로 옮긴다: `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end`

결과 한 줄 양식: `2 | <통과/실패/못 함> | IsReady=<값> | 토큰 수=<n> | 활성 세트=<이름> | 등록 폴더 수=<n> | 상태 기록 줄 수=<n>`

## 3. 로드 순서와 같은 이벤트 안의 처리 순서 (Core 기본값 주입의 두 가정)

- 하는 법: 게임을 종료하고 확인용 임시 폴더 `_forever_/Interface/AddOns/DevilForever_LoadProbe` 를 만들어 두 파일을 넣는다.
  `DevilForever_LoadProbe.toc`:
  ```
  ## Interface: 16001
  ## Title: DevilForever LoadProbe
  DevilForever_LoadProbe.lua
  ```
  `DevilForever_LoadProbe.lua`:
  ```lua
  local name = ...
  local core = DevilForever_Core
  local result = {coreLoadedBefore = (core ~= nil and core.ready == true), coreHandlerFirst = false}
  DevilForever_LoadProbeResult = result
  if core and core.eventFrame then
    local original = core.eventFrame:GetScript("OnEvent")
    core.eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
      if event == "ADDON_LOADED" and arg1 == name then result.coreSawProbe = true end
      return original(self, event, arg1, ...)
    end)
  end
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(_, _, loaded)
    if loaded == name then result.coreHandlerFirst = result.coreSawProbe == true end
  end)
  ```
  게임을 켜고 접속해 직접 친다: `/run local r=DevilForever_LoadProbeResult; print(r and r.coreLoadedBefore, r and r.coreHandlerFirst)`. 이어서 (API 가 있으면) `/run if GetFramesRegisteredForEvent then local t={GetFramesRegisteredForEvent("ADDON_LOADED")} for i,f in ipairs(t) do if f==DevilForever_Core.eventFrame then print("Core", i, "of", #t) end end else print("API 없음") end`. 끝나면 게임을 종료하고 `DevilForever_LoadProbe` 폴더를 백업 쪽으로 옮긴다(지우지 않는다).
- 기대 결과: `true true` — Core 가 다른 애드온보다 먼저 로드되고, 같은 ADDON_LOADED 이벤트에서 Core 의 처리기가 그 애드온의 처리기보다 먼저 돈다. 둘째 줄은 기록만(작은 번호일수록 앞).

결과 한 줄 양식: `3 | <통과/실패/못 함> | coreLoadedBefore=<값> | coreHandlerFirst=<값> | Core 처리기 순번=<i/n 또는 API 없음>`

## 4. 기본값 주입 상태

- 하는 법: `/run local n=0 for f,s in pairs(DevilForever_Core.Defaults:GetStatus()) do n=n+1 print(f, s.registered, s.loaded) end print("registered", n)`
- 기대 결과: 이번 Phase 에는 기본값 파일이 없다 → `registered 0`. 다른 값이 나오면 출력 줄을 그대로 옮긴다.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 등록 수=<n> | 출력=<줄 또는 없음>`

## 5. 저장 변수가 /reload 뒤에도 남는지

- 하는 법: `/run print(DevilForever_Core.Edit:Set("probe.test", "rows", 3))` → `/reload` → `/run print(DevilForever_Core.Edit:GetEdits("probe.test").rows)` → 끝나면 `/run print(DevilForever_Core.Edit:Clear("probe.test"))`. 이어서 게임을 종료하고 `_forever_/WTF/Account/<계정>/SavedVariables/!DevilForever_Core.lua` 가 있는지 본다(파일 이름의 계정 부분은 결과에 적지 않는다).
- 기대 결과: 첫 줄 `true applied`, reload 뒤 `3`, 지움 `true applied`, 파일 있음(안에 `DevilForever_CoreDB`).

결과 한 줄 양식: `5 | <통과/실패/못 함> | Set=<출력> | reload 뒤 rows=<값> | Clear=<출력> | 저장 파일 있음=<예/아니오>`

## 6. 전투 중 보류와 차단 오류

- 하는 법: 훈련용 허수아비나 쉬운 몹과 전투를 시작한다. 전투 중(캐릭터 옆 전투 표시가 켜진 동안)에 직접 친다: `/run print(DevilForever_Core.Edit:Set("probe.combat", "rows", 4)); print(#DevilForever_Core.Edit:GetPending())`. 전투가 끝난 뒤: `/run print(DevilForever_Core.Edit:GetEdits("probe.combat").rows, #DevilForever_Core.Edit:GetPending())` → `/run DevilForever_Core.Edit:Clear("probe.combat")`. 마지막에 `/bugsack` 에서 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 중 Core 이름이 든 것을 찾는다.
- 기대 결과: 전투 중 `true queued` 와 `1`, 전투 뒤 `4 0`, 차단 오류 0.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 전투 중=<출력> | 전투 뒤=<출력> | 차단 오류 수=<n>`

## 7. 결과 올리기

- 하는 법: 0–6 의 결과 줄을 `References/codex-verify/phase2/result.md` 에 순서대로 적고, (있으면) `bugsack.txt` 와 필요한 화면 갈무리를 같은 폴더에 넣어 저장소에 올린다. 3 의 확인용 폴더를 옮긴 위치를 한 줄 덧붙인다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase2`, `WTF_after_phase2`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: `References/codex-verify/phase2/result.md` 가 있다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | 올린 파일=<목록> | 커밋=<해시>`

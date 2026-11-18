# Codex 실사용 검증 발주문 — Phase 7 (시전바 · Quartz 3.8.0)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/quartz` 입력은 모두 사람이 하듯 직접 한다. 시전바의 자리·크기·질감·글꼴은 이 Phase 에서 보지 않는다(외관 단계 몫).

- 결과를 올릴 자리: `References/codex-verify/phase7/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 넷:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - Quartz 원본 `References/forever-addons/Quartz/Quartz-3.8.0.zip`, sha256 `2a76cdda6b53e7eb26472c0b8b6bf8f50c02388f8f515e6746c5e14657d5ed70`. 안의 `Quartz` 폴더 하나.
  - FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`, sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`. 안의 `ForeverUnitFrames` 폴더 하나.
  - Dominos 원본 `References/forever-addons/Dominos/Dominos-12.0.4.zip`, sha256 `2dbcf9857a91b772a42200369386fc17f875530ffd47984b555ecdb8e11bef1a`. 7번 항목에서만 `Dominos`·`Dominos_Cast` 두 폴더를 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 담당 나눔: 내 시전바·대상 시전바(그리고 주시·소환수)는 **Quartz 하나**가 맡는다. Quartz 는 자기 기본값으로 기본 시전바를 숨긴다. FUF 의 같은 대상 시전바는 `DevilForever_Castbars` 가 그 접속 동안만 숨긴다 — 저장 파일에 아무것도 쓰지 않으므로, Quartz 를 켜지 않은 캐릭터의 FUF 시전바는 그대로다. Quartz 의 그 모듈을 끄면 FUF 시전바가 다시 맡는다. Dominos_Cast 는 모음집에서 쓰지 않는다(켜면 시전바가 둘 — 7번에서 확인). Quartz 설정은 Quartz 기본값 그대로다(우리 기본값 파일 없음).

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase7/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 네 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_Castbars`, `DevilForever_ChatSetup`, `DevilForever_FUFDefaults`, `Quartz`, `ForeverUnitFrames`, `Dominos`, `Dominos_Cast`)가 있으면 백업 쪽으로 옮긴 뒤 모음집의 네 폴더와 `Quartz`·`ForeverUnitFrames` 를 넣는다(Dominos 는 아직 넣지 않는다). 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/` 의 `Quartz.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 넷 다 같고, 여섯 폴더가 설치되고, `Quartz.lua` 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/Quartz/FUF/Dominos)=<예·예·예·예> | 넣은 폴더=<목록> | Quartz.lua 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드·등록 표·Lua 오류

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Quartz·Forever Unit Frames·DevilForever Castbars 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 10초 기다린 뒤 `/run local s=DevilForever_Castbars.GetStatus(); print(s.player.hooked, s.player.quartz, s.target.hooked, s.target.quartz)` 를 친다. `/run print(#DevilForever_Core:GetFrameNames("Quartz"), DevilForever_Core:GetAddonInfo("Quartz").defaults, LibStub("AceAddon-3.0"):GetAddon("Quartz3"):GetModule("Interrupt", true) ~= nil)` 를 친다. `/bugsack` 을 열고 `Quartz`·`ForeverUnitFrames`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase7/bugsack.txt` 에 복사한다.
- 기대 결과: 셋 다 「사용 가능」, 첫 출력 `true true true true`, 둘째 출력 `6 nil false`(Quartz 의 차단 문구 모듈은 이 클라이언트에서 로드되지 않는다고 본다 — `true` 면 그대로 적는다), 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 첫 출력=<줄> | 둘째 출력=<줄> | 오류 수=<n>`

## 2. 내 시전바 — 하나만 보이는지

- 하는 법: 시전 시간이 있는 주문(예: 치유·화염구·번개 화살)을 쓴다. 화면에 보이는 시전바를 모두 센다: Quartz 시전바(화면 아래 가운데), FUF 내 프레임 밑의 시전바, 기본(블리자드) 시전바. 채널 주문이 있는 직업이면 채널 주문도 한 번 쓴다(막대가 줄어드는지, 틱 표시가 보이는지). 끝나고 `/run local s=DevilForever_Castbars.GetStatus().player; print(s.hooked, s.quartz, s.fufShown, s.hidden)` 를 친다.
- 기대 결과: 시전 중 시전바는 Quartz 것 하나, FUF 내 프레임 밑 시전바(빈 막대 포함)와 기본 시전바는 안 보임, 출력 `true true false <1 이상>`.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 보인 시전바=<Quartz/FUF/기본 중 보인 것> | 채널=<막대 줄어듦·틱 보임/못 봄/직업에 없음> | 출력=<줄> | FUF 프레임 밑 빈 자리=<없음/있음>`

## 3. 내 시전의 취소·차단 표시

- 하는 법: 시전 시간이 있는 주문을 쓰는 중에 움직여 끊는다. 다음에 시전 중 Esc 나 다른 주문으로 한 번 더 끊는다. 채널 주문이 있으면 채널 중 움직여 끊는다. 할 수 있으면 시전을 차단하는 몹(예: 차단 기술을 쓰는 인간형 몹) 앞에서 시전해 차단을 당해 본다.
- 기대 결과: 끊긴 시전은 Quartz 막대가 꽉 찬 빨간색으로 바뀌고 1초쯤에 걸쳐 사라진다(남은 시간 글자는 지워진다). 차단당한 시전도 같다(「차단됨」 같은 글자는 없을 수 있다 — 보이는 그대로 적는다). 일찍 끊은 채널은 다 끝난 채널과 같은 꼴로 사라질 수 있다 — 보이는 그대로 적는다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 움직여 끊음=<빨강·사라짐/다른 모습: 내용> | Esc·다른 주문=<빨강·사라짐/다른 모습> | 채널 끊음=<모습/직업에 없음> | 차단당함=<모습/못 봄>`

## 4. 대상 시전바 — 하나만, 차단 가능 표시

- 하는 법: 시전하는 몹(적대)을 대상으로 잡고 시전을 기다린다. 보이는 대상 시전바를 모두 센다(Quartz 대상 시전바, FUF 대상 프레임 밑 시전바, 기본 대상 시전바). 차단할 수 없는 시전(방패 아이콘)이 보이면 적는다. 차단 기술이 있는 직업(전사·도적·마법사·사제·주술사 등)이면 대상의 시전을 차단해 본다. 우호 캐릭터가 시전할 때도 한 번 본다. 끝나고 `/run local s=DevilForever_Castbars.GetStatus().target; print(s.hooked, s.quartz, s.fufShown, s.hidden)` 를 친다.
- 기대 결과: 대상 시전바는 Quartz 것 하나(우호·적대 모두), FUF 대상 프레임 밑 시전바와 기본 대상 시전바는 안 보임, 차단할 수 없는 시전에 방패 아이콘, 내가 차단한 시전은 빨간 막대로 바뀌어 사라짐, 출력 `true true false <1 이상>`.

결과 한 줄 양식: `4 | <통과/실패/못 함> | 보인 시전바=<목록> | 방패 아이콘=<보임/안 보임/차단 불가 시전 못 봄> | 내가 차단=<빨강·사라짐/다른 모습/차단 기술 없음> | 우호 시전=<Quartz 하나/다른 결과/못 봄> | 출력=<줄>`

## 5. 주시·소환수 시전바

- 하는 법: `/focus` 로 시전하는 몹을 주시 대상으로 잡고 시전을 본다(이 클라이언트에 주시가 없으면 `못 함`). 소환수가 있는 직업이면 소환수가 시전하는 기술을 쓰게 한다. `/run local s=DevilForever_Castbars.GetStatus(); print(s.focus.hooked, s.focus.quartz, s.focus.fufShown, s.pet.quartz, s.pet.fufShown)` 를 친다.
- 기대 결과: 주시 시전바는 Quartz 것 하나(FUF 주시 프레임 밑 시전바는 안 보임), 소환수 시전은 Quartz 소환수 시전바 하나. 출력 `true true false true false`(FUF 소환수 시전바는 FUF 기본 꺼짐).

결과 한 줄 양식: `5 | <통과/실패/못 함> | 주시 시전바=<Quartz 하나/다른 결과/주시 없음> | 소환수 시전바=<Quartz 하나/다른 결과/소환수 없음> | 출력=<줄>`

## 6. Quartz 모듈을 끄면 FUF 가 맡음

- 하는 법: `/quartz` 로 설정 창을 열고 「Target」(한글 클라이언트는 「대상」) 항목의 「Enable」(「사용」) 을 끈다. 시전하는 몹을 대상으로 잡고 다시 센다. `/run print(DevilForever_Castbars.GetStatus().target.quartz)` 를 친다. 다시 「Enable」 을 켜고 대상을 한 번 바꾼 뒤 시전을 본다. 다음에 「Player」(「플레이어」) 항목의 「Enable」 을 끄고 — 시전하지 않은 채 — FUF 내 프레임 밑을 본 뒤 다시 켜고 또 본다.
- 기대 결과: 끈 동안 대상 시전바는 FUF 대상 프레임 밑 것 하나(Quartz 대상 시전바 없음), 출력 `false`. 다시 켜면 Quartz 것 하나로 돌아온다(기본 대상 시전바는 끈 동안 보일 수 있다 — 보이면 적는다). Player 를 끄는 순간 FUF 내 프레임 밑 빈 시전바가 바로 나타나고, 켜는 순간 바로 사라진다(시전을 기다리지 않는다).

결과 한 줄 양식: `6 | <통과/실패/못 함> | 끈 동안 보인 시전바=<목록> | 출력=<줄> | 다시 켠 뒤=<Quartz 하나/다른 결과> | Player 끔/켬 즉시=<FUF 빈 막대 나타남·사라짐/다른 결과>`

## 7. Dominos_Cast 를 켜면 둘 — 끄면 하나

- 하는 법: 게임을 종료하고 Dominos ZIP 의 `Dominos`·`Dominos_Cast` 폴더를 넣는다. 접속해 시전 시간이 있는 주문을 쓰고 내 시전바를 센다. 게임을 종료하고 캐릭터 선택 화면 애드온 창에서 Dominos Cast 만 끈다(Dominos 는 켠 채). 접속해 다시 센다. 숨 참기(물속) 타이머가 보이는 곳이 있으면 물속에서 타이머 막대 수도 센다.
- 기대 결과: Dominos_Cast 를 켜면 내 시전바가 둘(Quartz + Dominos), 끄면 Quartz 하나. 숨 참기 타이머도 켰을 때 둘, 껐을 때 하나일 수 있다 — 보이는 그대로 적는다.

결과 한 줄 양식: `7 | <통과/실패/못 함> | Dominos_Cast 켬=<보인 시전바 목록> | 끔=<보인 시전바 목록> | 숨 타이머 켬/끔=<수/수 또는 못 봄>`

## 8. 끄기

- 하는 법: 애드온 창에서 DevilForever Castbars 를 끄고 접속해 내 시전과 대상 시전을 센다. 다음에 Quartz 를 끄고(Castbars 는 의존하는 Quartz 가 꺼져 로드되지 않는다) 접속해 다시 센다. 끝나면 둘 다 다시 켠다.
- 기대 결과: Castbars 만 끈 접속은 Quartz 와 FUF 시전바가 함께 보인다(겹침 — 이 애드온이 막던 것), 오류 0. Quartz 를 끈 접속은 FUF 시전바(내 것은 기본 시전바와 함께 보일 수 있다 — FUF 기본은 기본 시전바를 숨기지 않는다), Castbars 표시는 「의존 애드온 없음」 류, 오류 0.

결과 한 줄 양식: `8 | <통과/실패/못 함> | Castbars 끈 접속=<내/대상 보인 시전바> | Quartz 끈 접속=<내/대상 보인 시전바> | Castbars 표시=<문구> | 오류 수=<n>`

## 9. 재접속·다른 캐릭터·결과 올리기

- 하는 법: `/reload` 뒤 2번의 `/run` 줄을 다시 치고 시전 한 번으로 시전바를 센다. 몹과 전투를 시작해 전투 중에 `/reload` 하고, 전투가 끝난 뒤 10초 기다려 1번 첫 `/run` 줄을 치고 시전 한 번으로 내 시전바를 센다. 같은 계정의 다른 캐릭터로 나가 캐릭터 선택 화면 애드온 창의 캐릭터 고르기에서 그 캐릭터만 Quartz 를 끈 뒤 접속해 내 시전·대상 시전을 센다(FUF 시전바가 그대로 보여야 한다), 끝나면 다시 켠다. `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Quartz`·`ForeverUnitFrames`·`DevilForever`·`Dominos` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase7/result.md` 에 순서대로 적고 필요한 화면 갈무리와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase7`, `WTF_after_phase7`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다). Dominos 를 남길지 빼낼지도 한 줄 적는다.
- 기대 결과: reload 뒤 2번과 같은 결과, 전투 중 reload 뒤에도 전투가 끝나면 `true true true true` 와 Quartz 시전바 하나, 다른 캐릭터는 FUF 시전바가 보이고 Quartz 시전바는 없음, 오류 0, `References/codex-verify/phase7/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | reload 뒤=<출력·보인 시전바> | 전투 중 reload 뒤=<출력·보인 시전바/못 함> | 다른 캐릭터(Quartz 끔)=<내/대상 보인 시전바 또는 캐릭터 없음> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오, Dominos 남김/뺌> | 커밋=<해시>`

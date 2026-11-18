# Codex 실사용 검증 발주문 — Phase 8 (직업 전투보조 · Hekili v0.8.6-forever + 게임 기본 Cooldown Manager)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/hekili` 입력은 모두 사람이 하듯 직접 한다. 표시창·Cooldown Manager 의 자리·크기·스킨은 이 Phase 에서 보지 않는다(외관 단계 몫). 키 배정은 바꾸지 않는다.

- 결과를 올릴 자리: `References/codex-verify/phase8/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 6·8 번은 **있는 그대로 적는 기록 항목**이다(무엇이 보이든 `통과` 는 「확인해서 적었다」 는 뜻).
- 설치 ZIP:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `718c3f4a378867550e8d40ec27cccb99302470348ac4f2d090aac8f809cfd874` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - Hekili 원본 `References/forever-addons/Hekili/Hekili-v0.8.6-forever.zip`, sha256 `8063fd78c988af76c6a74653c21ff9f268546c44320922688ea2f7dd3d4c45e3`. 안의 열한 폴더(`Hekili`, `Hekili_Shared`, `Hekili_<직업>` 아홉) 모두.
  - 7번 항목에서만: Quartz `References/forever-addons/Quartz/Quartz-3.8.0.zip`(sha256 `2a76cdda6b53e7eb26472c0b8b6bf8f50c02388f8f515e6746c5e14657d5ed70`, `Quartz` 폴더), FUF `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`(sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`, `ForeverUnitFrames` 폴더), Dominos `References/forever-addons/Dominos/Dominos-12.0.4.zip`(sha256 `2dbcf9857a91b772a42200369386fc17f875530ffd47984b555ecdb8e11bef1a`, `Dominos`·`Dominos_Config`·`Masque_Dominos` — `Dominos_Cast` 는 넣지 않는다).
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 이 Phase 의 담당 나눔(R104): Hekili 는 **다음 행동 추천만** 보인다(화면 위 가운데 Primary 표시창, 전투 중 추천 능력이 놓인 단축바 버튼 빛남 — 우리 기본값이 켬). 상태 알림·쿨다운은 **게임 기본 Cooldown Manager**(창 넷: `EssentialCooldownViewer`·`UtilityCooldownViewer`·`BuffIconCooldownViewer`·`BuffBarCooldownViewer`)가 보인다. Hekili 는 치유 특성 넷(성기사·사제 신성, 주술사·드루이드 회복)에는 아무것도 보이지 않는다. 주술사부터 본다(R7). 대상은 훈련용 허수아비나 들판 몹이면 된다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase8/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. ZIP 다섯의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(모음집 넷, `Hekili*`, `Quartz`, `ForeverUnitFrames`, `Dominos*`, `Masque_Dominos`)가 있으면 백업 쪽으로 옮긴 뒤 모음집 넷과 Hekili 열한 폴더를 넣는다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/Hekili.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 다섯 다 같고, 열다섯 폴더가 설치되고, `Hekili.lua` 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/Hekili/Quartz/FUF/Dominos)=<예·예·예·예·예> | 넣은 폴더 수=<n> | Hekili.lua 옮김=<예/없었음> | BugSack 켜짐=<예/아니오>`

## 1. 로드·기본값 주입 상태·Lua 오류

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Hekili 와 Hekili 직업 모듈의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 주술사로 접속해 10초 기다린 뒤 직접 친다.
  `/run local s=DevilForever_Core.Defaults:GetStatus("Hekili"); local t=s.targets.HekiliDB; print(s.registered, s.loaded, t and t.state, t and t.mode, t and t.key, t and t.written)`
  `/run local p=Hekili.DB.profile; print(Hekili.DB:GetCurrentProfile(), p.enabled, p.displays.Primary.enabled, p.barGlow.enabled, p.toggles.cooldowns.separate, #DevilForever_Core:GetFrameNames("Hekili"))`
  상태 기록: `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end`. `/bugsack` 에서 `Hekili`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase8/bugsack.txt` 에 복사한다.
- 기대 결과: Hekili 「사용 가능」, 직업 모듈은 「요청 시 불러옴」 류, 첫 출력 `true true applied fill-missing HekiliDB@profile:Default 1`, 둘째 출력 `Default true true true false 6`, 상태 기록에 `error`·`skip`·`conflict` 줄 없음, 오류 0.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<표시> | 첫 출력=<줄> | 둘째 출력=<줄> | 상태 기록=<error/skip/conflict 줄 또는 없음> | 오류 수=<n>`

## 2. 추천 표시 — 지원 특성 (주술사 정기·고양 먼저)

- 하는 법: 주술사 정기(elemental) 특성으로 `/run print(Hekili.State.spec.key)` 를 친다. 허수아비·몹과 30초 전투하며 화면 위 가운데를 본다: Hekili 아이콘 줄(Primary)이 뜨는지, 추천이 바뀌는지, 그 능력이 놓인 Dominos 아닌 기본 단축바 버튼이 빛나는지(7번 전에는 Dominos 가 없다). Hekili 표시창이 몇 개 보이는지 센다. 고양(enhancement) 특성으로 바꿔 같은 것을 본다. 다른 직업 캐릭터가 있으면 지원 특성 하나로 같은 것을 본다(없으면 `없음`).
- 기대 결과: 특성 key 출력 `elemental` / `enhancement`, 전투 중 Primary 하나에 추천 아이콘이 뜨고 바뀜, 추천 능력 버튼이 빛남(전투 밖에서는 빛나지 않음), 다른 표시창 없음.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 정기=<key·Primary 보임·빛남> | 고양=<key·Primary 보임·빛남> | 보인 표시창 수=<n> | 다른 직업=<직업·특성·결과/없음>`

## 3. 추천 끄기·다시 켜기·재접속 유지

- 하는 법: 지원 특성에서 `/hekili disable` 을 치고 전투해 본다. `/reload` 뒤 다시 전투해 본다. `/hekili enable` 을 치고 전투해 본다. 그다음 `/hekili` 로 설정 창을 열어 Primary 표시창의 「Enabled」(한글 「사용」) 만 끄고 전투해 본 뒤 다시 켠다. 각 단계에서 `/run print(Hekili.DB.profile.enabled, Hekili.DB.profile.displays.Primary.enabled)` 를 친다.
- 기대 결과: disable 뒤 Hekili 표시창·빛남 없음(`false true`), reload 뒤에도 없음, enable 뒤 다시 보임(`true true`), Primary 「Enabled」 만 끄면 표시창 없음(`true false`), 다시 켜면 보임. Cooldown Manager 는 이 동안 그대로다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | disable=<보임 여부·출력> | reload 뒤=<보임 여부> | enable=<보임 여부·출력> | Primary 끔/켬=<결과>`

## 4. 치유 특성 — Hekili 는 아무것도 안 보임

- 하는 법: 주술사 회복(restoration)으로 바꾼다(그 캐릭터에 없으면 성기사·사제 신성 또는 드루이드 회복 캐릭터). `/run print(Hekili.State.spec.key)` 를 친다. 허수아비·몹과 전투하고 파티원(또는 자기)을 치유해 본다. Hekili 표시창·단축바 빛남이 있는지, Cooldown Manager 창이 버프·쿨다운을 보이는지 본다. `/bugsack` 오류를 센다.
- 기대 결과: Hekili 표시창·빛남 없음, Cooldown Manager 는 보임(5번이 켜짐을 확인한 뒤면), 오류 0. key 출력은 그대로 적는다(`restoration`·빈 값 모두 가능 — 원천에서 확정 못 함).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 직업·특성=<…> | key 출력=<줄> | Hekili 보임=<아니오/예: 내용> | Cooldown Manager 보임=<예/아니오> | 오류 수=<n>`

## 5. Cooldown Manager 켜짐·표시

- 하는 법: 지원 특성으로 돌아와 친다: `/run print(GetCVar("cooldownViewerEnabled"), C_CooldownViewer and C_CooldownViewer.IsCooldownViewerAvailable and C_CooldownViewer.IsCooldownViewerAvailable())`. 첫 값이 `1` 이 아니면 게임 설정 창에서 Cooldown Manager(한글 이름은 화면 그대로) 를 사람이 직접 켜고 메뉴 경로를 적는다(코드로 바꾸지 않는다). 게임의 Cooldown Settings 창을 열어 특성마다 따로 고를 수 있는지 본다. 전투하며 버프가 걸릴 때·쿨다운 기술을 쓸 때 창에 뜨는지 본다. 끝나고 `/run for _,n in ipairs({"EssentialCooldownViewer","UtilityCooldownViewer","BuffIconCooldownViewer","BuffBarCooldownViewer"}) do local f=_G[n]; print(n, f~=nil, f and f:IsVisible(), f and f:GetNumChildren()) end` 를 친다.
- 기대 결과: CVar `1`(또는 켠 뒤 `1`), 사용 가능 `true`, 특성마다 고르는 칸이 있음, 버프·쿨다운이 창에 뜸, 네 줄 모두 `true` 와 보임 여부·아이템 수.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 첫 출력=<줄> | 직접 켬=<아니오/예: 메뉴 경로> | 특성별 설정=<있음/없음> | 버프 뜸=<예/아니오> | 쿨다운 뜸=<예/아니오> | 창 넷=<이름=보임·아이템 수 …>`

## 6. 화면 가운데 강조·소리 (기록)

- 하는 법: 주술사 고양으로 「소용돌이 무기(Maelstrom Weapon)」 를 5중첩까지, 정기로 「정신 집중(Clearcasting)」 을 띄워 본다(다른 직업이면 그 직업의 proc 효과 하나). 그때 Cooldown Manager 와 게임 화면에 무엇이 보이고 들리는지 적는다: 화면 가운데 큰 아이콘(게임 자체 proc 그림 포함), 아이콘 빛남·테두리 강조, 소리. Cooldown Manager 설정에 소리·강조 칸이 있는지도 본다.
- 기대 결과: 정해진 값은 없다 — 보이고 들리는 그대로 적는다. 없으면 `없음` 으로 적는다(새 알림 제품은 붙이지 않는다 — 결과는 최종 보고에 싣는다).

결과 한 줄 양식: `6 | <통과/못 함> | proc=<이름> | 가운데 아이콘=<있음(무엇이 그림)/없음> | 빛남·강조=<있음(어디)/없음> | 소리=<있음/없음> | 설정 칸=<소리·강조 칸 있음/없음>`

## 7. Quartz·FUF·Dominos 와 함께 — 겹침·전투 중 오류

- 하는 법: 게임을 종료하고 Quartz·FUF·Dominos 폴더(위 목록)를 넣는다. 주술사 지원 특성으로 접속해 1분 전투한다. 화면에서 Hekili 표시창·Cooldown Manager 창이 Quartz 시전바·FUF 프레임·Dominos 바와 겹치는지 적는다(아직 외관 전이라 자리는 기본값 — 겹침 기록만). 추천 능력의 **Dominos** 버튼이 빛나는지 본다. 끝나고 `/bugsack` 에서 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 과 `Hekili`·`Dominos`·`Quartz`·`ForeverUnitFrames` 오류를 센다.
- 기대 결과: Dominos 버튼 빛남 보임, 차단 오류 0, 오류 0. 겹침은 보이는 그대로.

결과 한 줄 양식: `7 | <통과/실패/못 함> | 겹침=<Hekili×무엇, Cooldown Manager×무엇 또는 없음> | Dominos 버튼 빛남=<예/아니오> | 차단 오류 수=<n> | 오류 수=<n>`

## 8. 게임 기본 기능으로 충분한가 (기록 · R99·R100)

- 하는 법: `/run print(GetCVar("countdownForCooldowns"))` 를 친다. 쿨다운이 긴 기술을 쓰고 Dominos 버튼 위에 남은 시간 숫자가 뜨는지 본다(값이 `0` 이면 게임 설정에서 사람이 직접 켜고 메뉴 경로를 적는다). 이어서 게임 기본 툴팁(아이템·몹), 가방(한 창으로 합쳐 보이는지), 퀘스트·목표 추적기, 세계지도를 각각 1분씩 써 보고 「이대로 충분/모자람(무엇이)」 을 적는다.
- 기대 결과: 정해진 값은 없다 — 쿨다운 숫자는 보이기를 바란다(R99). 나머지 넷은 적기만 한다(애드온을 더 넣지 않는다, R100·R101).

결과 한 줄 양식: `8 | <통과/못 함> | countdownForCooldowns=<값, 직접 켬 여부·경로> | 버튼 숫자=<보임/안 보임> | 툴팁=<충분/모자람: 무엇> | 가방=<…> | 추적기=<…> | 세계지도=<…>`

## 9. Hekili 끄기·재접속·결과 올리기

- 하는 법: 전투 중 `/reload` 하고 전투가 끝난 뒤 10초 기다려 1번 둘째 `/run` 줄을 다시 치고 전투해 추천을 본다. 게임을 종료하고 캐릭터 선택 화면 애드온 창에서 Hekili 를 끈 뒤 접속해 전투한다(Cooldown Manager 만 보여야 한다). `/run local s=DevilForever_Core.Defaults:GetStatus("Hekili"); print(s.registered, s.loaded)` 를 친다. 끝나면 Hekili 를 다시 켠다. `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Hekili`·`DevilForever` 오류와 차단 오류를 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase8/result.md` 에 순서대로 적고 필요한 화면 갈무리(2·5·6·7번)와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase8`, `WTF_after_phase8`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: 전투 중 reload 뒤에도 `Default true true true false 6` 과 추천, Hekili 끈 접속은 Hekili 표시 없음·Cooldown Manager 보임·출력 `true false`, 오류 0, `result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 전투 중 reload 뒤=<출력·추천 보임> | Hekili 끈 접속=<보인 것·출력> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오> | 커밋=<해시>`

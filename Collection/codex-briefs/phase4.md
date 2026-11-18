# Codex 실사용 검증 발주문 — Phase 4 (대화창 3개 · Prat-3.0 3.9.117)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run` 입력은 모두 사람이 하듯 직접 한다. 실제 대화 내용·개인 채팅 기록은 결과에 옮기지 않는다(메시지가 어느 창에 왔는지만 적는다).

- 결과를 올릴 자리: `References/codex-verify/phase4/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄.
- 설치 ZIP 둘:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef` (지금 판 안에는 `!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_FUFDefaults/`, `DevilForever_StatusStrip/`, `PitBull4/` — 이 발주문이 넣으라는 폴더만 넣는다(PitBull4 는 Phase 6-rev 몫이라 다른 Phase 검증에서는 넣지 않는다)).
  - Prat 원본 `References/forever-addons/Prat-3.0/Prat-3.0-3.9.117.zip`, sha256 `d72baef9c99bb1583b269abd85088bcb957d9a0d8ca57c323144442875084db1`. 안의 `Prat-3.0` 폴더 하나를 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 대화창 분담은 **그 캐릭터의 첫 접속에 한 번만** 만들어진다. 검증에는 새로 만든 캐릭터나, 대화창이 아직 기본 상태(「일반」 과 「전투 기록」 탭만)인 캐릭터를 쓴다. 어느 캐릭터를 썼는지 적는다.

## 0. 시작 (늘 같음)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase4/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 두 ZIP 의 sha256 이 위 값과 같은지 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_ChatSetup`, `Prat-3.0`)가 있으면 백업 쪽으로 옮긴 뒤 두 ZIP 에서 위 폴더를 넣는다. 처음 설치 상태를 보려고 `_forever_/WTF/Account/<계정>/SavedVariables/Prat-3.0.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 둘 다 같고, 세 폴더가 설치되고, Prat 저장 파일이 없는 상태다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | 모음집 sha256 일치=<예/아니오> | Prat sha256 일치=<예/아니오> | 넣은 폴더=<목록> | Prat 저장 파일 옮김=<예/없었음> | BugSack 켜짐=<예/아니오> | 캐릭터=<새 캐릭터/기본 대화창 캐릭터>`

## 1. 로드와 Lua 오류

- 하는 법: 게임을 켜고 캐릭터 선택 화면의 애드온 창에서 DevilForever Core·DevilForever Chat Setup·Prat 3.0 의 표시를 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 전투 밖에서 5초쯤 기다린다. `/bugsack` 을 열고 `Prat`·`!DevilForever_Core`·`DevilForever_ChatSetup` 이 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase4/bugsack.txt` 에 복사한다.
- 기대 결과: 셋 다 「사용 가능」, 오류 0. 대화창에 「DevilForever: 대화창 3개를 만들었습니다. /reload 를 입력하면 설정이 마무리됩니다.」 한 줄이 보인다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<폴더=표시 목록> | 오류 수=<n> | 안내 줄 보임=<예/아니오>`

## 2. 세 창과 메시지 그룹

- 하는 법: `/reload` 를 친다. 그다음 `/run local d=DevilForever_ChatSetupDB; print(d.result, d.windows and d.windows.public, d.windows and d.windows.group, d.windows and d.windows.system)` 를 친다. 이어서 `/run for i=1,NUM_CHAT_WINDOWS do local n,_,_,_,_,_,s,_,k=GetChatWindowInfo(i); if s or k then print(i,n,s,k,table.concat({GetChatWindowMessages(i)},","),table.concat({GetChatWindowChannels(i)},",")) end end` 를 친다. 출력 줄을 `References/codex-verify/phase4/windows.txt` 에 그대로 옮긴다. 화면에서 대화창이 몇 개 따로 떠 있는지 본다(자리·크기는 외관 단계에서 정한다 — 겹쳐도 실패로 치지 않는다).
- 기대 결과: 첫 줄 `created 1 <n> <m>`. 창 `1`(일반)에 SAY·YELL·EMOTE·CHANNEL 이 있고 GUILD·PARTY·WHISPER·SYSTEM·LOOT 는 없으며 채널(공개·거래 등)이 붙어 있다. 창 `<n>` 에 GUILD·OFFICER·PARTY·RAID·INSTANCE_CHAT·WHISPER·BN_WHISPER, 창 `<m>` 에 SYSTEM·ERRORS·COMBAT_XP_GAIN·LOOT·MONEY·CURRENCY, 두 창 모두 채널 없음. 창 2(전투 기록)는 그대로 일반 창에 탭으로 붙어 있다. 따로 뜬 창 3개(일반·`<n>`·`<m>`).

결과 한 줄 양식: `2 | <통과/실패/못 함> | 첫 줄=<출력> | 창1 그룹 요약=<…> | 창n 그룹 요약=<…> | 창m 그룹 요약=<…> | 따로 뜬 창 수=<n> | 전투 기록 탭=<그대로/바뀜>`

## 3. 메시지가 맞는 창에 오는지

- 하는 법: 할 수 있는 것만 한다 — `/s 시험`·`/y 시험`(외치기), 공개 채널 `/1 시험`(일반 채널에 들어가 있을 때), 자기 자신에게 귓속말 `/w <내 이름> 시험`, 길드가 있으면 `/g 시험`, 파티를 만들 수 있으면 `/p 시험`, `/played`(시스템 메시지), 몬스터를 잡아 경험치·전리품·돈을 얻는다. 각 메시지가 어느 창에 나왔는지 본다.
- 기대 결과: 말하기·외치기·공개 채널 = 창 1, 귓속말(보냄·받음)·길드·파티 = 창 `<n>`, `/played`·경험치·전리품·돈 = 창 `<m>`. 한 메시지가 두 창에 겹쳐 나오지 않는다.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 말하기=<창> | 외치기=<창> | 공개 채널=<창/못 함> | 귓속말=<창> | 길드=<창/못 함> | 파티=<창/못 함> | 시스템=<창> | 경험치·전리품·돈=<창/못 함> | 겹침=<없음/있음:종류>`

## 4. 기본값 주입 상태

- 하는 법: `/run local s=DevilForever_Core.Defaults:GetStatus("Prat-3.0"); for l,t in pairs(s.targets) do print(s.registered, s.loaded, l, t.state, t.mode, t.key, t.written) end` 를 친다. 상태 기록도 본다: `/run for _,e in ipairs(DevilForever_Core:GetStatusLog()) do print(e.kind, e.subject, e.message) end`
- 기대 결과: 두 줄 — `true true Prat3DB/Prat_History applied fill-missing Prat3DB/Prat_History@profile:Default 1` 과 `true true Prat3DB/Prat_Memory applied fill-missing Prat3DB/Prat_Memory@profile:Default 1`(첫 접속이 아니면 `already`). 상태 기록에 `error`·`skip`·`conflict` 줄이 없다(`info` 줄은 적기만 한다).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 출력=<줄들> | 상태 기록=<error/skip/conflict 줄 또는 없음>`

## 5. Prat 이 읽은 값과 기록 저장 끔

- 하는 법: `/run local h=Prat.Addon:GetModule("History"); local m=Prat.Addon:GetModule("Memory"); print(Prat.db:GetCurrentProfile(), h:IsEnabled(), h.db.profile.scrollback, h.db.profile.savehistory, m:IsEnabled())` 를 친다. 대화창에 메시지가 몇 줄 쌓이게 한 뒤(3번 이후면 됨) 캐릭터 선택으로 나갔다가 다시 접속해, 이전 접속의 대화 줄이 구분선과 함께 다시 나타나는지 본다. `/run local n=0; for _ in pairs(Prat3HighCPUPerCharDB and Prat3HighCPUPerCharDB.scrollback or {}) do n=n+1 end; print(n)` 를 친다.
- 기대 결과: `Default true false false false`(첫 접속 직후 마지막 칸이 `true` 면 `/reload` 뒤에 다시 쳐서 `false` 인지 적는다). 다시 접속해도 이전 대화 줄이 복원되지 않고, 마지막 출력은 `0`.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 출력=<줄> | reload 뒤 Memory=<true/false/안 함> | 이전 대화 복원=<없음/있음> | scrollback 수=<n>`

## 6. 기본 입력

- 하는 법: 세 창 각각에서 Enter 로 입력창을 열고 `/s 가나다 abc` 를 입력해 보낸다(한글 조합이 끝까지 되는지). `/dance` 같은 감정 명령, `/1`·`/s` 로 채널 바꾸기, 입력 중 Esc 로 닫기, 위쪽 화살표(또는 Alt+위쪽)로 앞서 보낸 줄 불러오기를 한다. 전투 중(허수아비나 몬스터)에 `/s 전투 시험` 을 한 번 보낸다. 링크(가방 아이템을 Shift+클릭해 입력창에 넣기)를 한 번 보낸다.
- 기대 결과: 모두 기본 게임과 같이 동작한다. 한글이 깨지지 않고, 입력창이 사라지거나 포커스가 빠지지 않는다. 전투 중 보낸 줄도 나온다. BugSack 에 새 오류·`ADDON_ACTION_BLOCKED` 없음.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 한글=<됨/안 됨> | 감정 명령=<됨/안 됨> | 채널 바꾸기=<됨/안 됨> | Esc=<됨/안 됨> | 앞 줄 불러오기=<위쪽/Alt+위쪽/안 됨> | 전투 중 입력=<됨/안 됨> | 링크=<됨/안 됨> | 새 오류 수=<n>`

## 7. 사용자 변경 유지와 재접속

- 하는 법: 창 `<n>` 의 탭을 오른쪽 클릭 → 설정 → 대화 에서 「길드」 를 끄고, 일반 창 설정에서 「길드」 를 켠다. `/reload` → 2번의 둘째 `/run` 줄을 다시 친다 → 캐릭터 선택으로 나갔다가 다시 접속해 같은 줄을 한 번 더 치고 `/run print(DevilForever_ChatSetupDB.result)` 를 친다. 끝나면 길드를 원래대로(창 `<n>` 켬, 일반 끔) 돌린다.
- 기대 결과: reload 뒤와 재접속 뒤 둘 다 GUILD 가 창 1 에 있고 창 `<n>` 에 없다(애드온이 되돌리지 않음). 새 창이 더 생기지 않는다. 마지막 출력 `created`.

결과 한 줄 양식: `7 | <통과/실패/못 함> | reload 뒤 GUILD 창=<번호> | 재접속 뒤 GUILD 창=<번호> | 창 수 변화=<없음/있음> | result=<출력> | 되돌림=<예/아니오>`

## 8. 끄기

- 하는 법: 캐릭터 선택 화면 애드온 창에서 Prat 3.0 을 끈다. 접속해 `/run local s=DevilForever_Core.Defaults:GetStatus("Prat-3.0"); print(s.registered, s.loaded, next(s.targets))` 를 치고, 세 창이 그대로인지, 입력·메시지가 기본 게임대로 되는지, BugSack 에 새 오류가 있는지 본다. 이어서 Prat 을 다시 켜고 DevilForever Chat Setup 을 끈 채 접속해 창 분담이 그대로인지 본다. 끝나면 둘 다 켜고 접속한다.
- 기대 결과: `true false nil`, 세 창과 분담 그대로, 기본 입력 동작, 새 오류 0. Chat Setup 을 꺼도 분담 그대로(이미 만든 창은 게임이 저장한다).

결과 한 줄 양식: `8 | <통과/실패/못 함> | Prat 끈 출력=<줄> | Prat 끈 뒤 창·분담=<그대로/바뀜> | Chat Setup 끈 뒤 분담=<그대로/바뀜> | 새 오류 수=<n>`

## 9. 마지막 오류 확인과 결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `Prat`·`!DevilForever_Core`·`DevilForever_ChatSetup` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase4/result.md` 에 순서대로 적고 `windows.txt`·필요한 화면 갈무리와 함께 저장소에 올린다. 원래 Prat 설정으로 돌아가려면 게임을 종료하고 0 에서 옮긴 `Prat-3.0.lua` 를 되돌린다(돌렸는지 한 줄 적는다). 모든 것을 시작 전 상태로 되돌리려면 게임을 종료하고, 지금의 `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 다른 이름(예: `AddOns_after_phase4`, `WTF_after_phase4`)으로 바꿔 옆에 두고, 0 에서 만든 백업의 `AddOns`·`WTF` 두 폴더를 원래 자리로 복사한다(지우지 않는다 — 백업은 시작 전 상태 전체다).
- 기대 결과: 오류 0, `References/codex-verify/phase4/result.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | Prat 저장 파일 되돌림=<예/아니오> | 커밋=<해시>`

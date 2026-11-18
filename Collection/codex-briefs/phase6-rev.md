# Codex 실사용 검증 발주문 — Phase 6-rev (기본 unit·직업 자원 두 번째 판 · PitBull4 v4.2.50-forever.1, FUF 판과 나란히 비교)

받는 쪽: Codex (사용자 PC). 보내는 쪽: Claude 세션. 위에서 아래로 그대로 하면 된다. 게임 입력을 자동으로 보내는 도구(키 입력·마우스 매크로)는 쓰지 않는다 — 게임 안 동작과 `/run`·`/pb` 입력은 모두 사람이 하듯 직접 한다. 프레임의 자리·크기·질감·글꼴은 보지 않는다(외관 단계 몫, `appearance-6-rev.md`). 원천상 비교표는 `Collection/data/unitframes-compare.md` 에 있다 — 이 검증은 그 표를 게임에서 확인하는 것이다.

**두 판을 함께 켜지 않는다.** PitBull4 판을 볼 때는 `ForeverUnitFrames`·`DevilForever_FUFDefaults`·`DevilForever_Castbars` 를 끄고, FUF 판을 볼 때는 `PitBull4` 를 끈다(애드온 창에서 끄기 · 폴더는 그대로).

- 결과를 올릴 자리: `References/codex-verify/phase6-rev/` (저장소). 결과 표 `result.md` 에 항목마다 「결과 한 줄 양식」 을 한 줄씩 적는다. 두 번째 칸은 `통과` / `실패` / `못 함` 중 하나, 실패면 마지막 칸에 오류 문구 한 줄. 나란히 비교표는 `compare.md`(7번).
- 설치 ZIP 넷:
  - 모음집 `outputs/collection/DevilForever-collection.zip`, sha256 `d726a254197affceb9c8f3da892c97efb12ed76127d14ae988f000759a8e4846` (안에는 `Interface/AddOns/!DevilForever_Core/`, `DevilForever_Castbars/`, `DevilForever_ChatSetup/`, `DevilForever_DetailsSetup/`, `DevilForever_FUFDefaults/`, `PitBull4/`).
  - FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`, sha256 `cc50d16b5d926240a4dc48e7e6f9e4ee7fbb5107c14ebb734a685542e50e1a80`. 안의 `ForeverUnitFrames` 폴더 하나.
  - Quartz 원본 `References/forever-addons/Quartz/Quartz-3.8.0.zip`, sha256 `2a76cdda6b53e7eb26472c0b8b6bf8f50c02388f8f515e6746c5e14657d5ed70`. 안의 `Quartz` 폴더 하나(시전바는 Quartz 하나 — Phase 7).
  - Grid2 원본 `References/forever-addons/Grid2/Grid2-4.1.13-forever.zip`, sha256 `f198bc3ce2d02e023f81052074a2e9aa4ba41819931bd302ff7429dac9515393`. 4번 항목에서만 넣는다.
- 폴더 이름이 `!` 로 시작한다. bash 로 다룰 때는 작은따옴표로 감싼다(예: `ls '_forever_/Interface/AddOns/!DevilForever_Core'`).
- 우리 PitBull4 는 원본 v4.2.50 을 고친 판이다(고친 내용 `Collection/patches/PitBull4.patch`). 처음 접속 때 `!DevilForever_Core` 가 V42 Devil profile 의 기능 값(어떤 프레임·파티 묶음·모듈·오라 수·글자)을 공용 프로필 「Default」 에 넣는다. 이미 있던 PitBull4 프로필에는 아무것도 넣지 않는다(상태 `existing-profile-kept`) — 그래서 0번에서 `PitBull4.lua` 저장 파일을 옮긴다. 자리·크기·질감은 아직 PitBull4 기본이라 프레임이 겹쳐 보일 수 있다(실패가 아니다).

## 0. 시작 (자동 업데이트 끄기 포함)

- 하는 법: 게임을 완전히 종료한다(런처까지). `_forever_/Interface/AddOns` 와 `_forever_/WTF` 를 통째로 다른 곳에 복사한다(예: `forever_backup_phase6rev/AddOns`, `.../WTF`). 복사본의 폴더·파일 수가 원래와 같은지 본다. 네 ZIP 의 sha256 을 본다. `_forever_/Interface/AddOns` 에 같은 이름 폴더(`!DevilForever_Core`, `DevilForever_Castbars`, `DevilForever_ChatSetup`, `DevilForever_FUFDefaults`, `PitBull4`, `PitBull4_DogTagTexts`, `ForeverUnitFrames`, `Quartz`, `Grid2`)가 있으면 백업 쪽으로 옮긴 뒤 모음집의 다섯 폴더와 `ForeverUnitFrames`·`Quartz` 를 넣는다. `_forever_/WTF/Account/<계정>/SavedVariables/` 의 `PitBull4.lua`·`ForeverUnitFrames.lua`·`DevilForever_FUFDefaults.lua`·`DevilForever_Core.lua`(와 `.bak`)가 있으면 백업 쪽으로 옮긴다(지우지 않는다). 쓰는 애드온 관리 프로그램(CurseForge 앱·WowUp 등)이 있으면 PitBull4 를 「업데이트 무시」(자동 업데이트 끔)로 둔다 — 켜 두면 Forever TOC 가 없는 원본으로 덮인다. BugSack·!BugGrabber 가 켜져 있는지 본다.
- 기대 결과: 백업 두 폴더가 원래와 같은 수로 생기고, sha256 이 넷 다 같고, 일곱 폴더가 설치되고, 저장 파일 넷이 없는 상태이고, PitBull4 자동 업데이트가 꺼져 있다.

결과 한 줄 양식: `0 | <통과/실패/못 함> | 백업 위치=<경로> | sha256 일치(모음집/FUF/Quartz/Grid2)=<예·예·예·예> | 넣은 폴더=<목록> | 저장 파일 옮김=<목록/없었음> | PitBull4 자동 업데이트=<끔/관리 프로그램 없음> | BugSack 켜짐=<예/아니오>`

## 1. PitBull4 판 로드·기본값·오류

- 하는 법: 캐릭터 선택 화면의 애드온 창에서 `ForeverUnitFrames`·`DevilForever FUF Defaults`·`DevilForever Castbars` 를 끄고 `PitBull Unit Frames 4.0` 이 켜져 있는지, 「오래된 애드온」 표시 없이 보이는지 본다(「오래된 애드온 불러오기」 는 켜지 않는다). 접속해 30초 기다린 뒤 `/run local s=DevilForever_Core.Defaults:GetStatus("PitBull4"); local n=0; for _,t in pairs(s.targets) do if t.state=="applied" then n=n+1 end end; print(PitBull4 and PitBull4.version, s.loaded, n, PitBull4.db:GetCurrentProfile())` 를 친다. `/reload` 뒤 같은 줄을 한 번 더 친다(이번엔 `applied` 대신 `already` 를 센다 — 줄의 `"applied"` 를 `"already"` 로 바꿔 친다). `/bugsack` 을 열고 `PitBull4`·`DevilForever` 가 들어간 오류를 찾는다. 있으면 문구 전체를 `References/codex-verify/phase6-rev/bugsack.txt` 에 복사한다.
- 기대 결과: 출력 `v4.2.50-forever.1 true 26 Default`, reload 뒤 `already` 26, 오류 0. 내 프레임·대상·주시·파티 프레임이 PitBull4 것으로 보이고 블리자드 기본 내 프레임·대상·주시·파티 프레임은 숨는다(PitBull4 기본값). 블리자드 우두머리 프레임은 그대로 남는다.

결과 한 줄 양식: `1 | <통과/실패/못 함> | 애드온 창=<PitBull4 표시> | 첫 출력=<줄> | reload 뒤 출력=<줄> | 오류 수=<n>`

## 2. 체력과 직업 자원 (PitBull4 판)

- 하는 법: 가진 캐릭터마다(가능한 직업만) 접속해 내 프레임을 본다. 맞거나 자원을 써서 값이 움직이는지 본다. 직업마다 볼 것: 전사 = 분노 막대 / 도적 = 기력 막대 + **대상 프레임**의 연계 점(공격해서 점이 차는지) / 드루이드 = 사람 형태 마나 막대, 표범 형태 기력 막대 + 대상 프레임 연계 점 + 마나 막대가 따로 하나 더(변신 중), 곰 형태 분노 막대 + 마나 막대 / 사냥꾼 = 마나 막대 + 소환수 프레임의 만족도 아이콘 / 성기사·사제·마법사·흑마법사·주술사 = 마나 막대. 이 판은 **토템 아이콘을 보이지 않는다**(주술사 토템은 Dominos 토템 바)와 **흑마법사 영혼의 조각 개수를 보이지 않는다**(보이면 적는다). 마나를 쓰지 않는 직업에 마나 막대가 보이면 실패로 적는다. 막대 오른쪽·왼쪽의 숫자(생명력 `현재/최대`, 마력)가 전투 중에도 비지 않고 바뀌는지 본다.
- 기대 결과: 모든 직업에서 체력 막대와 숫자가 움직이고, 자원 막대가 위대로 그 직업의 자원을 보인다.

결과 한 줄 양식: `2 | <통과/실패/못 함> | 본 직업=<직업=통과/실패 목록> | 연계 점=<대상 프레임에 보임/안 보임/못 봄> | 드루이드 변신 중 마나=<보임/안 보임/못 봄> | 소환수 만족도=<보임/안 보임/못 봄> | 전투 중 숫자=<바뀜/빈칸/0 고정> | 엉뚱한 자원 표시=<없음/있음: 직업·내용>`

## 3. 오라·글자 (PitBull4 판)

- 하는 법: 아무 몹이나 대상을 잡고 디버프를 건다(가능한 직업으로). 다른 사람이 건 디버프가 있는 대상(공격대 우두머리·다른 사람이 때리는 몹)도 하나 본다. 대상을 바꾸고(같은 종류 몹 사이 전환 포함) 디버프가 새 대상 것으로 바뀌는지 본다. 파티가 있으면 파티원 프레임의 버프를 본다. 내 프레임에 버프 아이콘이 없는지 본다.
- 기대 결과: 대상 프레임에 버프·디버프 아이콘과 남은 시간 표시(시계 바늘이나 글자 — 크기·글꼴은 외관 몫), 대상을 바꾸면 바로 바뀜, 내 프레임 위 오라 없음(기본 버프 창이 보인다), 파티원 버프 보임.

결과 한 줄 양식: `3 | <통과/실패/못 함> | 대상 버프=<보임/안 보임> | 대상 디버프=<보임/안 보임> | 다른 사람 디버프=<보임/안 보임/못 봄> | 대상 전환=<바뀜/안 바뀜> | 내 프레임 오라=<없음/보임> | 파티 버프=<보임/안 보임/파티 없음>`

## 4. 파티·공격대 (PitBull4 판)

- 하는 법: 파티가 있으면 파티를 짜서 PitBull4 파티 프레임(파티원·파티원 대상·파티원 소환수)을 본다. 게임을 종료하고 Grid2 ZIP 의 `Grid2`·`Grid2Options`·`Grid2LDB` 폴더를 넣고 다시 접속한다. 공격대가 있으면 공격대를 본다. `/run print(PitBull4DB.profiles.Default.groups["파티"].enabled, PitBull4DB.profiles.Default.groups["공격대"])` 를 친다.
- 기대 결과: 파티에서 PitBull4 파티 프레임 보임, 공격대에서 PitBull4 프레임은 없고 Grid2 프레임이 보인다, 출력 `true nil`(PitBull4 에는 공격대 묶음이 없다).

결과 한 줄 양식: `4 | <통과/실패/못 함> | 파티 프레임=<보임/안 보임/파티 없음> | 공격대=<PitBull4 없음·Grid2 보임/다른 결과/공격대 없음> | 출력=<줄>`

## 5. 전투 중 오류·taint (PitBull4 판)

- 하는 법: 몹 여럿과 전투한다. 전투 중 대상을 여러 번 바꾸고, 주시 대상을 잡았다 풀고, 소환수를 부르거나 내보낸다(가능한 직업). 시전바가 Quartz 하나만 보이는지 본다(PitBull4 프레임 안에 시전바 없음). 전투 중 `/pb` 로 설정 창을 열어 본다(바꾸지 않는다). 전투가 끝나면 `/bugsack` 에서 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN`·「taint」 가 들어간 줄과 `PitBull4` 오류를 센다.
- 기대 결과: 전투 중 프레임이 대상 전환을 따라가고, 시전바는 Quartz 하나, 설정 창의 값 칸은 전투 중 잠기거나 열리지 않는다, 차단 오류 0.

결과 한 줄 양식: `5 | <통과/실패/못 함> | 대상 전환 따라감=<예/아니오> | 시전바=<Quartz 하나/겹침: 무엇> | 전투 중 설정 창=<잠김/안 열림/바꿀 수 있음> | 차단 오류 수=<n> | PitBull4 오류 수=<n>`

## 6. FUF 판으로 같은 항목

- 하는 법: 게임을 종료하고 애드온 창에서 `PitBull Unit Frames 4.0` 을 끄고 `ForeverUnitFrames`·`DevilForever FUF Defaults`·`DevilForever Castbars` 를 켠다. 같은 캐릭터로 접속해 2·3·5번과 같은 것을 FUF 로 본다(연계 점·드루이드 마나 띠·토템 아이콘·소환수 만족도·대상 오라·대상 전환·시전바·차단 오류). FUF 판에서 무엇이 보이는지는 `Collection/codex-briefs/phase6.md` 2·3번의 기대 결과와 같다.
- 기대 결과: FUF 프레임이 보이고 PitBull4 프레임은 없다, 오류 0.

결과 한 줄 양식: `6 | <통과/실패/못 함> | 본 직업=<목록> | FUF 2번 결과=<요약> | FUF 3번 결과=<요약> | 시전바=<Quartz 하나/겹침> | 차단 오류 수=<n>`

## 7. 나란히 비교표

- 하는 법: `References/codex-verify/phase6-rev/compare.md` 에 한 표로 적는다. 행: 로드·오류 / 체력·숫자(전투 중 포함) / 직업 자원(직업별) / 연계 점 / 드루이드 변신 중 마나 / 토템 / 소환수 만족도 / 영혼의 조각 / 대상 오라(내 것·다른 사람 것·전환) / 파티 / 공격대와 Grid2 / 시전바 겹침 / 전투 차단 오류 / 치유 예측·거리 흐림(FUF 는 켜짐, PitBull4 판은 꺼 둠 — 보이는 대로) / 설정 창 쓰기 편함 / 접속·`/reload` 시간 느낌 / 그 밖에 눈에 띈 것. 열: FUF 판 · PitBull4 판 · 어느 쪽이 나은지와 이유 한 줄. 사용자가 보고 있으면 사용자 의견을 한 줄 더한다.
- 기대 결과: 표 한 장. 어느 쪽을 기본으로 묶을지는 이 표로 Phase 23 에서 정한다(이번에 정하지 않는다).

결과 한 줄 양식: `7 | <통과/못 함> | compare.md=<있음/없음> | Codex 의견=<FUF/PitBull4/비슷함 + 이유 한 줄> | 사용자 의견=<한 줄/없음>`

## 8. 함께 켜지 않음·끄기·재접속

- 하는 법: 애드온 창에서 FUF 와 PitBull4 가 동시에 켜져 있지 않은지 본다(지금은 FUF 만). 게임을 종료하고 FUF 묶음 셋을 끄고 PitBull4 를 켠다 → 접속 → 1번 첫 `/run` 줄(`already` 셈)을 친다 → 캐릭터 선택으로 나갔다가 다시 접속해 같은 줄을 친다. 다음에 PitBull4 도 끄고 접속해 블리자드 기본 프레임(내 프레임·대상 프레임·파티)이 돌아왔는지, 새 오류가 있는지 본다. 끝나면 PitBull4 를 다시 켠다.
- 기대 결과: 동시에 켜진 적 없음, 재접속 뒤에도 `already` 26 이고 1번과 같은 프레임 구성, PitBull4 를 끈 접속에서 기본 프레임 보임, 오류 0.

결과 한 줄 양식: `8 | <통과/실패/못 함> | 동시 켜짐=<없음/있었음> | 재접속 뒤 출력=<줄> | 같은 구성=<예/아니오> | PitBull4 끈 접속 기본 프레임=<보임/안 보임> | 오류 수=<n>`

## 9. 마지막 오류 확인과 결과 올리기

- 하는 법: `/bugsack` 을 다시 열어 이번 검증 동안 쌓인 `PitBull4`·`ForeverUnitFrames`·`DevilForever`·`Grid2` 오류와 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN` 을 센다(있으면 `bugsack.txt` 에 덧붙인다). 0–9 의 결과 줄을 `References/codex-verify/phase6-rev/result.md` 에 순서대로 적고 `compare.md`·필요한 화면 갈무리와 함께 저장소에 올린다. 원래 상태로 돌아가려면 게임을 종료하고 0 에서 옮긴 폴더·저장 파일을 되돌린다(Grid2·PitBull4 를 남길지 뺄지와 함께 한 줄 적는다).
- 기대 결과: 오류 0, `result.md`·`compare.md` 가 있다.

결과 한 줄 양식: `9 | <통과/실패/못 함> | 오류 수=<n> | 차단 오류 수=<n> | 올린 파일=<목록> | 되돌림=<예/아니오, 남긴 폴더> | 커밋=<해시>`

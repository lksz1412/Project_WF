# work_log — Phase 14 Step 26 · 작업 A2 (bada-a2-writer) · iter_1

## 쓴 파일
- `Collection/codex-briefs/phase14.md` (새 파일, 76줄 — 항목 0–8, 9개)
- `Collection/codex-briefs/appearance-14.md` (새 파일, 34줄)
- 이 work_log

## 읽은 파일·줄 범위
- `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md`: 215–230(행 219 Phase 7, 222 Phase 10, 226 Phase 14 포함), 338–362(Codex 외관 발주문 341–352, 실사용 검증 규칙 354–360), 440–450(Phase 별 검증 나눔 행 14 = 446)
- `Collection/codex-briefs/phase10.md` 1–85 전문
- `Collection/codex-briefs/appearance-10.md` 1–32 전문
- `Collection/codex-briefs/appearance-2.md` 1–36 전문
- `Collection/codex-briefs/appearance-2-layouts.md` 1–35 전문 (세 겉보기 값의 꼴 — R107 ⑥ 근거)
- `Collection/AddOns/!DevilForever_Core/API.lua` 1–77 (머리 주석 전체 1–76 + 다음 줄)
- `Collection/AddOns/!DevilForever_Core/Edit.lua` 1–60 (머리 주석: frameKey 는 임의 문자열, 등록 key 는 공유용)
- `Collection/codex-briefs/phase7.md` 1–25, `appearance-7.md` 1–15 (Quartz 담당 확인용)
- `Claude/results/handoffs/phase14/SESSIONS.md` 1–7
- 기계 검색: `grep -rn -i nameplate Collection/ --include=*.json --include=*.md` → Aurora `.extract-source.json:217–218` 의 Blizzard_NamePlates 스킨 파일 발견(appearance-14 3절에 씀). 등록 표에 이름표 항목 없음.
- 존재 확인만(본문 읽지 않음): V42 `!DevilUI/Profile/Plater.lua` (68125줄 — 계획 행 226 이 「참고」 로 든 파일, 발주문에서 참고 경로로만 가리킴)

## 명령·판정
- `sha256sum outputs/collection/DevilForever-collection.zip` → `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820` — 발주 값과 같음 (통과)
- `unzip -l` 폴더 목록 → `!DevilForever_Core`, `DevilForever_Castbars`, `DevilForever_ChatSetup`, `DevilForever_FUFDefaults`, `PitBull4` — phase14.md 머리 설명과 같음 (통과)
- 항목 게이트: `grep -c '^## [0-9]' phase14.md` → 9 (≤10 통과); 항목마다 하는 법·기대 결과·결과 한 줄 양식 각 1 (0–8 모두 1/1/1, 통과)
- sha256 게이트: 두 발주문에 각 1회, 실제 값과 같음 (통과)
- 금지어 게이트: 발주문이 정한 금지어 7개를 `grep -nE` 하나로 두 발주문 + 이 work_log 에 걸음 → 일치 없음 (통과 — 이 줄에 낱말을 적지 않아 work_log 도 같은 검색에 걸 수 있게 함)

## A2 choice (내 판단)
- 0번에서 BugSack·!BugGrabber 를 뺀 모든 애드온을 백업 쪽으로 옮기고 ZIP 에서 `!DevilForever_Core` 하나만 넣음 — 기본 이름표를 다른 애드온이 바꾸지 않은 상태로 보기 위해.
- CVar 이름(`nameplateShowEnemies`·`nameplateShowFriends`·`nameplateShowCastBars`·`nameplateMotion`)은 다른 클라이언트의 이름을 후보로 든 것이고, Forever 에 있는지는 확인 필요로 적고 `nil` 이면 「없음」 으로 받게 함. 5번은 `C_Console.GetAllCommands` 로 목록을 찍되 함수가 없으면 그 사실을 적게 함.
- 체력·위협 색의 기대 색은 정하지 않고 「보인 그대로」 를 기대 결과로 둠(Forever 사실을 지어내지 않기 위해).
- 7번에서 저장 자리 확인용으로 `Config.wtf` 사본 비교를 넣음.
- appearance-14: frame key 기본 제안 `nameplates.enemy`·`nameplates.friendly`; 이름표 위협 숫자 추가 금지와 색 뜻 보존을 받아들이는 기준에 넣음.

## Decision Queue
1. 이름표 frame 등록 방식: 이름표는 몹마다 생기는 프레임이라 등록 표의 `frame`(전역 프레임 이름) 칸에 하나로 적기 어렵다. Codex 제안을 받은 뒤 등록 표 꼴(패턴 이름·key 만 두기 등)을 master 가 정해야 함.
2. 이름표 시전바가 뜨면 Quartz 와 겹침 — 남길지 Phase 23 결정(발주 지시대로 넘김). appearance-14 는 「끄거나 작게」 를 Codex 판단에 맡김.
3. Aurora(Phase 15)를 쓰면 Aurora 의 Blizzard_NamePlates 스킨과 이 Skin 애드온이 함께 걸릴 수 있음 — Phase 15 발주문에도 한 줄 넣을지 master 판단.
4. 이름표 CVar 는 사용자 계정 설정(Config.wtf 로 보임 — 확인 필요)이라, Skin 애드온이 CVar 를 바꾸면 끈 뒤에도 남을 수 있음. 되돌림 방식(원래 값 기록 등)을 요구할지 master 판단.
5. 계획 행 446 의 Phase 14 검증 칸은 「체력·위협 색 표시」 만 적혀 있으나 발주는 시전바·설정 목록·쌓기·유지까지 요구 — 계획 행 갱신 여부 master 판단.

## fix 1 (검수 결과 반영 — `Claude/results/handoffs/phase14/TRIAGE_phase14.md` 1–34 전문 읽음)

### 영향 지도 (TRIAGE 표대로 + 내가 본 것)
| 자리 | 판정 | 한 일 |
|---|---|---|
| phase14.md:14 (0번, m1) | 함께 고침 | 옮길 곳을 `forever_moved_phase14/AddOns` 로 따로 둠, 결과 줄에 옮긴 곳 |
| phase14.md:21 (1번, M3) | 함께 고침 | 켜기 전 적·아군 이름표 켜짐 기록, 결과 줄 `원래 켜짐` |
| phase14.md:36 (3번, m2) | 함께 고침 | 「색 등으로 보일 수 있다(확인 필요)」 |
| phase14.md:51–52 (5번, M1) | 함께 고침 | `/run` 두 줄로 나눔(243·62자), 출력 문구 `no GetAllCommands` 로 줄이고 54행 기대 결과도 같이 바꿈 |
| phase14.md:74·77 (8번, M2·M3) | 함께 고침 | 이름표 켜짐 되돌림 + 전체 백업 되돌림(지금 폴더 이름 바꿔 옆에 두고 백업 복사), 결과 줄 두 칸 |
| appearance-14.md:19·33·34 (M4) | 함께 고침 | 끄기만으로 안 돌아감 명시, 원래 값 SV 저장·한 번만 넣기·되돌리기 슬래시 명령, report 칸, 받아들이는 기준 |
| phase6.md:78, phase6-rev.md:81, phase7.md:79, phase8.md:81, phase9.md:79, phase10.md:82 | 함께 고침 | 「0 에서 옮긴 폴더·저장 파일을 되돌린다」 문장만 전체 백업 되돌림 문장으로 바꿈(뒤의 괄호 메모는 문장으로 남김). 이름 예시는 각 파일 0번 백업 이름에 맞춤(`phase6rev` 등) |
| phase2.md:87, phase3.md:79, phase4.md:77, phase5.md:79 (마지막 항목 하는 법 줄) | 함께 고침(줄 끝에 한 문장 덧붙임) | 2 = 「원래 상태로 돌아가려면 …」, 3–5 = 기존 저장 파일 되돌림 문장 뒤에 「모든 것을 시작 전 상태로 되돌리려면 …」 |
| appearance-*.md 다른 파일, 기록 문건 | 영향 없음 | TRIAGE 대로(m4 목록, 기록) |

### 읽은 범위 (fix 1)
- TRIAGE_phase14.md 1–34
- 모든 phaseN.md 에서 `원래 상태로` 줄 grep, phase2.md 85–90, phase3.md 77–82, phase4.md 75–80, phase5.md 77–82 (마지막 항목), 10개 파일 0번의 백업 이름 grep(모두 `forever_backup_phase<N>/AddOns`, `.../WTF` 같은 꼴 확인)
- phase14.md 12–24·34–40·48–56·70–77, appearance-14.md 19·34 (고친 뒤 다시 읽음)

### 명령·판정
- 바꾸기 스크립트(python3 -I): 6개 파일 각 1회 일치·바꿈 `ok`, phase2–5 마지막 하는 법 줄 끝 확인 뒤 덧붙임 `ok` (87·79·77·79행). `git diff --stat` = 10개 파일 각 1줄
- `/run` 길이(python, 모든 `Collection/codex-briefs/*.md` 의 `` `/run …` ``): phase14 최대 243 → 통과. **phase5.md:37 의 `/run` 이 257자로 255 초과** — 이번 발주 범위 밖(phase5 는 마지막 항목 줄만 고치라 함)이라 고치지 않음 → Decision Queue
- phase14 항목: 9개, 0–8 모두 하는 법/기대 결과/양식 1/1/1 → 통과
- 금지어 7개 grep(모든 briefs + 이 work_log) → exit 1, 일치 없음 → 통과
- `sha256sum outputs/collection/DevilForever-collection.zip` → `d02105320a0d82abe3a7f680dd7a4eef27357d6938383bd1e40cd8206060b820`, phase14·appearance-14 각 1회 같은 값 → 통과

### A2 choice (fix 1)
- 이름표 켜짐은 2–7번에 켜진 채 필요하므로 1번이 아니라 8번(게임 끄기 전)에서 되돌림.
- 되돌리기 슬래시 명령·SavedVariables 이름은 Codex 가 정해 보고서에 적게 함(지어 정하지 않음).
- 바꾼 폴더 이름 예시 `AddOns_after_phase<N>`·`WTF_after_phase<N>`.

### Decision Queue (fix 1)
6. phase5.md:37 의 `/run` 257자(255 초과 추정 한도) — 고칠지, 누가 고칠지 master 판단.

## fix 1b (DQ6 master 결정 — phase5.md:37 `/run` 줄이기)
- 읽은 범위: phase5.md 33–42 (3번 항목 전체)
- 영향 지도: phase5.md:37 함께 고침(`type(p)=="table"` 세 번을 `local t=type(p)=="table"` 한 번으로 묶음 — 출력 값·순서 같음) · phase5.md:38 기대 결과·:40 결과 줄 = 확인만, 출력 문구가 그대로라 고치지 않음
- 명령·판정: python 길이 검사(모든 `Collection/codex-briefs/*.md`) → phase5:37 = 238자, `/run` 78줄 중 255 초과 0 → 통과 · 금지어 7개 grep(모든 briefs + 이 work_log) → exit 1 → 통과 · `git diff --stat phase5.md` = 2줄(37행 이번, 79행 fix 1)

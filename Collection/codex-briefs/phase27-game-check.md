# 게임 확인 — Phase 27 (0.1.5 PitBull4 판, Step 51 테마 넘김 그림 포함)

기준: `claude/phase27-local-20261124` 의 Step 51 커밋 `c34716a3`. 출처 = `Collection/codex-briefs/phase26-step47-check.md` 1–8번 · `Collection/codex-briefs/appearance-26-theme-switcher.md` §3. Hekili 항목은 뺐다(R153).
확인은 게임 플레이 없이 한다(R154) — 애드온 설정·시험·배치 보기 모드, 슬래시 명령, `/reload` 만 쓴다. 전투·파티 구성·이동이 꼭 있어야 하는 항목은 「플레이 필요 — 이번 확인 제외」로 적었다. 확인에 쓰는 `/dfp preset`·`/dfp go`·`/pb4`·`/q3`·Grid2 설정은 `WTF` 의 저장값을 고쳐 쓴다(`/dfp preset` 은 그 preset 이 덮는 창의 편집값을 지우고 `/dfp go` 뒤 애드온 값을 다시 쓴다 — `!DevilForever_Core/Presets.lua:304–306`, `:323–327`). 그래서 같은 명령으로 「원래대로」 돌려도 설정이 확인 전과 같아지지 않는다. 확인을 모두 마친 뒤 게임을 끄고 0절의 `WTF` 백업을 복사해 넣는 것이 되돌리기다(설치는 `WTF` 를 건드리지 않으므로 이것으로 모든 설정이 확인 전 상태로 돌아간다 · 설치 뒤 확인 전까지 직접 바꾼 설정도 함께 돌아간다). `/run` 한 줄은 255바이트 이하.
결과 칸 꼴: `결과: 맞음 / 다름(무엇이 · 화면 갈무리 파일) / 못 봄(이유)`.

## 0. 설치·되돌리기

- 설치한 것: 0.1.5 PitBull4 판 35 폴더 2275 파일(커밋 `c34716a3`). 스테이징 = `D:\Projects\Project_WF\_local_only\claude-p27-stage-255f4725\AddOns` (같은 폴더의 `receipt.json` 에 파일마다 크기·sha256).
- 설치 도구: `Collection/tools/install_local.ps1 -StagedAddOns <스테이징>\AddOns -BackupRoot D:\Projects\Project_WF\_local_only\claude-p27-backup-<8자리 16진수>` (게임을 끈 상태에서만 돈다 · `-DryRun` 은 아무것도 쓰지 않는다 · `-Help` 는 되돌리기 줄까지 보여 준다).
- 백업: 설치 직전의 `Interface\AddOns` 와 `WTF` 통째 = `-BackupRoot` 폴더의 `AddOns\`·`WTF\` (설치 때 정한 폴더 · 그 안의 `installation.json` 에 게임 경로·커밋·폴더 목록·파일 수·백업 항목 수·남겨 둔 폴더).
- 손대는 곳: `Interface\AddOns\<패키지 폴더 35개>` 만. `!BugGrabber`·`BugSack` 과 `Interface\AddOns.BeforeDevilForever015-3434ca83`, `WTF` 는 그대로 둔다(WTF 는 백업만).
- 되돌리기(게임 끈 상태): `robocopy "<백업>\AddOns" "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns" /MIR /COPY:DAT` 그리고 `robocopy "<백업>\WTF" "C:\Program Files (x86)\World of Warcraft\_forever_\WTF" /MIR /COPY:DAT`. `/MIR` 는 백업 뒤에 생긴 파일을 지운다.
- 결과: 설치 뒤 `installation.json` 이 있는가 · 게임 첫 화면에서 애드온 목록에 35 폴더가 켜져 있는가 — `결과:`

## 확인에 쓰는 명령 (출처)

| 명령 | 하는 일 | 출처 |
|---|---|---|
| `/dfp help`, `/dfp status` | 도움말·지금 preset 등 | `!DevilForever_Core/Commands.lua:32–45`, `:262–263` |
| `/dfp preset` · `/dfp preset <이름>` → `/dfp go` | preset 목록 · 그 preset 으로 되돌리기 예약 → 다시 불러오기 | `Commands.lua:219–227`, `:38` |
| `/dfp theme` · `/dfp theme <번호>` | 테마 목록 · 테마 바꾸기 | `Commands.lua:125–140`, `:228–229` |
| `/dfp party` · `/dfp party on` | 유닛 프레임 파티 상태 보기 · 켜기(→ `/reload`) | `Commands.lua:243–252` |
| `/pb4` (`/pitbull4` 등) | PitBull4 설정 창 | `PitBull4/Options/Options.lua:30–40` |
| `/run PitBull4:SetConfigMode("party")` (`"solo"`·`"raid"`·`"raid40"`·`"disabled"`) | PitBull4 설정 모드(가짜 유닛으로 창 보이기) · 전투 중 불가 | `PitBull4/Options/ConfigMode.lua:5–16`, `:38–55` |
| `/run Grid2Layout:SetTestMode(true,0,"By Group",40)` · `…SetTestMode(false)` | Grid2 시험 배치(40명) 켜기·끄기 — Grid2 설정 창 Layouts 의 시험 단추와 같은 함수 | `Grid2/GridLayout.lua:399–416`, `Grid2Options/modules/themes/GridLayouts.lua:69–80` |
| `/grid2`, `/grid2 unlock`·`lock`, `/grid2 minimapicon show/hide` | Grid2 설정·잠금·미니맵 단추 | `Grid2/GridCore.lua:313–314`, `:363–369`, `Grid2/GridUtilsCmd.lua:135–177` |
| `/q3` (`/quartz`) → 「Toggle Bar Lock」 | Quartz 설정 창 · 막대 잠금 풀기(미리보기 막대) | `Quartz/Config.lua:56–62`, `:190–203`, `Quartz/Quartz.lua:103–128` |
| `/dom config` (`/dominos lock`) | Dominos 배치 모드 켜기·끄기 | `Dominos/plugins/slashCommands.lua:24–33` |
| `/run DevilForever_Core.Edit:Set("statusstrip.bar","font",{size=17})` · `…Edit:Clear("statusstrip.bar","font")` | 상태띠 글꼴 크기 편집 · 지우기(전투 밖) | `!DevilForever_Core/Edit.lua:118–122`, `:188–198` |
| `/reload` | 애드온 다시 불러오기(R154 ④) | — |

물리 px 재기(창 위 끝 · 오른쪽 끝이 화면 위·오른쪽에서 떨어진 거리): `/run local f,P=Grid2LayoutFrame,UIParent local s,t,u=f:GetEffectiveScale(),P:GetEffectiveScale(),PixelUtil.GetPixelToUIUnitFactor() print((P:GetHeight()*t-f:GetTop()*s)/u,(P:GetWidth()*t-f:GetRight()*s)/u)` (`Grid2/GridLayout.lua:218`). 두 값 모두 Grid2 가 자리를 저장하는 규칙 그대로다 — 오른쪽 기준 `f:GetRight()*s-UIParent:GetWidth()*t`, 위 기준 `f:GetTop()*s-UIParent:GetHeight()*t`(`Grid2/GridLayout.lua:880`, `:883` · s = 창의 실효 배율, t = UIParent 실효 배율)를 부호를 바꿔 `PixelUtil.GetPixelToUIUnitFactor()` 로 나눈 물리 px 이라 UI 배율과 상관없이 같은 값이 나온다. preset 값: fhd `["PosX"]=-247*factor,["PosY"]=-259*factor` · qhd 330·346 · uhd 495·518(퀘스트 목록 위 끝 ≈ 화면 높이의 24 %, 왼쪽 끝 ≈ 오른쪽에서 화면 높이의 23 % — 사용자 화면 갈무리에서 잰 값, 확인 필요).

## 1. 파티 창: PitBull4 파티와 Grid2 함께

- 보는 법: 혼자 있는 상태에서 `/run PitBull4:SetConfigMode("party")` 와 `/run Grid2Layout:SetTestMode(true,0,"By Group",5)` → 다음에 `"raid40"` 와 `…,"By Group",40)` 로 공격대 40명 모양. 끝나면 `SetConfigMode("disabled")`, `SetTestMode(false)`.
- 기대: PitBull4 파티 창(좌상단 세로)과 Grid2 창이 함께 뜨고 겹치지 않는다 · Grid2 창은 퀘스트 목록 바로 왼쪽(창 위 끝 = 퀘스트 목록 위 끝, 창 오른쪽 끝 = 퀘스트 목록 왼쪽 끝, 인원이 늘면 아래·왼쪽으로 커짐) · 파티·공격대 같은 자리 · 칸은 정사각형 fhd 88 · qhd 116 · uhd 176 px(크기·모양은 사용자 확인 뒤 피드백). 위 「물리 px 재기」 값: fhd 259·247 · qhd 346·330 · uhd 518·495. 비교 배치 New·Old 모두 같은 자리.
- 40명 모양에서 대상 프레임·대상 오라·주시 대상·Details 와 겹치지 않는가(대상·주시 대상은 `SetConfigMode("solo")` 로 함께 보인다).
- fhd 만: 대상 약화 효과가 아주 많을 때 오른쪽 오라 기둥 위 끝이 창 아래로 최대 13 px 들어갈 수 있음 — 약화 효과 수는 실제 대상이 있어야 하므로 「플레이 필요 — 이번 확인 제외」.
- 마우스오버로 Grid2 칸에 치유가 가는가: 「플레이 필요 — 이번 확인 제외」(실제 파티원·주문).
- `결과:`

## 2. 파티원 소환수 창

- 소환수가 있는 파티원 옆에만 뜨는가: 설정 모드는 모든 칸에 가짜 유닛을 그리므로 판정이 안 된다 — 「플레이 필요 — 이번 확인 제외」(소환수가 있는 파티원이 있는 실제 파티).
- 설정 모드(`SetConfigMode("party")`)에서 소환수 칸이 파티원 창 옆 자리에 붙는지만 본다 — `결과:`

## 3. 다시 접속해도 파티 하위 창 켜기·끄기 유지

- 보는 법: `/pb4` → 파티 그룹의 하위 창(소환수 등) 하나의 켜기·끄기를 바꾼다(원래 값 기록) → `/reload` 두 번, 그리고 캐릭터 선택 화면으로 나갔다가 다시 접속 한 번 → 같은 값인가(되돌리기 = 맨 위 규칙, 0절 `WTF` 백업 복사).
- 기대: 사용자가 바꾼 값 그대로.
- `결과:`

## 4. 이전 판에서 올린 캐릭터

- 보는 법: 이 판 설치 전에 쓰던 캐릭터로 접속 → `/dfp party` 로 상태 보기 → `/dfp party on` → `/reload` → `/run PitBull4:SetConfigMode("raid")` 로 공격대 모양.
- 기대: 공격대 모양에서도 PitBull4 파티 창이 뜬다 · Grid2 창이 예전 기본 자리였으면 새 자리(1번 좌표)로 옮겨져 있다 · `/dfp party on` 때 대화창에 알림 줄이 찍힌다.
- `결과:`

## 5. Quartz 스윙 막대

- 사냥꾼에게만: 사냥꾼 캐릭터와 다른 직업 캐릭터(전사·도적 등)로 각각 접속해 `/q3` → 「Toggle Bar Lock」 → 사냥꾼에게만 스윙 미리보기 막대가 보이는가(`Quartz/modules/SwingForever.lua:64`, `:151–152` — 사냥꾼이 아니면 잠금 풀기에도 막대를 만들지 않음). 다시 눌러 잠근다. — `결과:`
- 잠금 해제 때 미리보기 막대가 보이고 정지 구간(기본 0.5초, `SwingForever.lua:54`, Swing 설정 `:329–334`)이 막대 오른쪽에 칠해져 있는가 — `결과:`
- 자동 사격 주기와 맞는가 · 정지 구간이 실제로 멈춰야 하는 시간과 맞는가(값을 재서 알려 줄 것) · 이동으로 사격이 한 주기 넘게 밀릴 때 막대가 사라졌다 다음 사격 때 다시 뜨는 동작: 「플레이 필요 — 이번 확인 제외」(실제 자동 사격).

## 6. V2 배치

- 보는 법: 기본 배치가 V2 다(새 설치 · `/dfp preset <fhd|qhd|uhd>` → `/dfp go`) → `/run PitBull4:SetConfigMode("solo")` (플레이어·대상·소환수·주시 대상·대상의 소환수와 그 아래 줄 가짜 유닛).
- 기대: 주시 대상 창의 가로 가운데 = 화면 가운데, 플레이어·대상이 양쪽으로 같은 간격 · 주술사 토템 시간 4칸은 플레이어 창 바로 위 오른쪽 끝(플레이어 오라 줄은 그 위) · 상태띠 버전 전환(New/Old)이 지금 배치를 보여 준다(이 판 이전에 받은 배치는 설치 뒤 첫 접속 때 쓰던 버전 그대로 한 번 자동으로 다시 적용된다 — §11 첫 줄) · New 는 Grid2 칸 정사각형, Old 는 예전 칸 크기 · 플레이어·대상·주시 대상의 버프·약화 효과가 같은 모양(최대 14·16개, 아이콘 uhd 40 · qhd 27 · fhd 20 px, 내 약화 효과 64 · 43 · 32 px) · 소환수 창은 그대로 · 대상의 소환수 아래에 「대상의 소환수의 대상」·「…의 대상의 대상」 두 칸 · `/q3` 잠금 해제에서 Quartz 소환수 시전 막대가 소환수 창 자리에 있다. 되돌리기 = 맨 위 규칙(0절 `WTF` 백업 복사).
- 실제 오라(버프·약화 효과) 크기: 「플레이 필요 — 이번 확인 제외」.
- `결과:`

## 7. Grid2 새 캐릭터

- 보는 법: 캐릭터 선택 화면에서 새 캐릭터를 만들어 접속(전투·이동 없음).
- 기대: Grid2 템플릿 고르기 창이 뜨지 않는다 · 미니맵 Grid2 단추가 숨겨져 있다(`!DevilForever_Core/Defaults/Grid2.lua:53–54` · 보이려면 `/grid2 minimapicon show`).
- 새 캐릭터를 만들지 않으면 「못 봄(새 캐릭터 없음)」.
- `결과:`

## 8. Dominos 전투 중 미룬 꼬리 배치

- 전투 중에 미룬 배치가 전투 뒤 맞춰지는가(`DevilForever_Skin_Dominos/Skin.lua:33`, `:60`, `:164`): 「플레이 필요 — 이번 확인 제외」(전투 진입).
- 전투 밖 확인만: `/dom config` 로 배치 모드를 켰다 끈 뒤 막대 자리가 그대로인가 — `결과:`

## 9. 상태띠 테마 넘김 그림 (Step 51)

- 13 이름 × 지금 겉보기: `/dfp theme 0` … `/dfp theme 12` 또는 상태띠 오른쪽 ▶ 를 13번 눌러 이름 그림이 모두 금색 필기체로 보이는가 · 원배율 갈무리(줄이거나 늘리지 않음). 다른 겉보기(fhd·qhd·uhd)는 그 해상도 화면에서만 확인 가능 — 없으면 「못 봄」. — `결과:`
- 화살표 normal · hover(마우스를 올림 — 하얗게 날아가지 않는가) · pushed(누르고 있음 — 1 px 아래·조금 어둡게) — `결과:`
- 양방향 넘김: ◀ ▶ 를 눌러 이름이 칸 안에서 미끄러지고 칸 밖은 잘리는가 — `결과:`
- `/reload` 뒤 같은 테마·같은 그림 — `결과:`
- 한글판 클라이언트에서도 영문 그림 — `결과:`
- 글자 대체(편집): `/run DevilForever_Core.Edit:Set("statusstrip.bar","font",{size=17})` → 이름이 글자(한글판이면 한글 이름)로, 화살표가 ◀ ▶ 글자로 돌아가는가 → `/run DevilForever_Core.Edit:Clear("statusstrip.bar","font")` 로 지워 그림으로 돌아오는가. 먼저 `/run print(DevilForever_Core.Edit:GetEdits("statusstrip.bar").font)` 가 `nil` 이 아니면(사용자 편집이 있음) 건너뛴다. — `결과:`
- 글자 대체(파일 하나를 표에서 뺌): 게임 폴더의 코드를 고쳐야 하므로 이번 확인 제외 — 코드 시험 `Collection/tests/statusstrip/theme_switcher.py` 에서 PASS.
- disabled 그림(고를 테마가 하나뿐일 때): 시험용 설치가 필요하므로 이번 확인 제외 — 코드 시험에서 PASS.
- 전투 중 클릭 거절과 말풍선(「전투 중에는 바꿀 수 없습니다.」) · 전투 진입·종료 때 화살표 흐림(0.45)·복귀: 「플레이 필요 — 이번 확인 제외」.

## 10. 대화창 — Chattynator 237 (Step 60)

- 바뀐 것: 대화창을 Chattynator 237 이 맡는다(R163·R166·R167). 처음 접속 때 Chattynator 설정이 아직 기본값이면 창 세 개를 지금 화면 preset 의 예전 세 창 자리·크기로 만든다(`DevilForever_ChatSetup/Chattynator.lua`). Chattynator 설정을 이미 바꿨으면 손대지 않는다. 스킨 「Devil Forever」 도 처음 설정하는 프로필에서만 첫 접속부터 골라지고, Chattynator 를 이미 쓰던 프로필은 쓰던 스킨 그대로다(Chattynator 설정 → 테마에서 바꿈). Chattynator 를 끄면 예전 기본 대화창 세 개로 돌아간다.
- 채널 목록 먼저 보기: `/chatlist` 를 입력하거나 소셜 창의 채널 목록을 열어 지금 들어가 있는 채널 번호와 이름을 적는다. Forever 의 4번 채널(저장된 채팅 기록에 지역 채널 번호 46 으로 남은 채널)이 무엇인지와 파티 찾기 채널이 있는지는 아직 모른다 — 확인 결과에 채널 번호·이름을 함께 적어 줄 것. — `결과:`
- 세 창과 내용: 1번 창 = 말하기·외치기·감정 표현·NPC 말·업적·자리 비움/다른 용무 중·숫자 채널 1–3과 그 밖에 들어가 있는 채널(파티 찾기 채널 빼고), 시스템·전리품·돈·기술 숙련·화폐·오류 메시지, Chattynator 전투 기록 탭 · 2번 창 = 귓속말(받은 것·보낸 것)·길드·관리자·길드 업적·Battle.net 귓속말·파티·파티장·공격대·공격대장·공격대 경보·인스턴스 대화·전장 메시지(호드·얼라이언스·중립 — 처음 설정하는 프로필에서만, 이미 쓰던 창은 사용자가 고른 그대로) · 3번 창 = 파티 찾기 채널만(그 채널에 안 들어가 있으면 빈 창). — `결과:`
- 탭 줄과 글 영역(처음 설정하는 프로필 · 또는 직접 옮기지 않은 창): 탭 이름(일반·전투·파티·길드·파티 찾기)이 대화 칸 위 테마 띠 쪽에 있고, 세 창의 글이 각자 테마 대화 칸 안쪽(왼쪽·오른쪽·아래 테두리 안)에서만 보이는가 · 3번 창 글이 화면 오른쪽 끝까지 넘어가지 않는가 · 단추(검색·복사·설정)는 마우스를 올렸을 때만 글 위에 겹쳐 보이고 글 폭을 줄이지 않는가 · 1번 창 입력창이 칸 안에 있는가(화면 갈무리). — `결과:`
- 창 가장자리·크기: 창을 끌어 옮기고 오른쪽 위 손잡이로 크기를 바꿀 수 있는가 · 세 창이 예전 세 창 자리에 있는가(화면 갈무리). — `결과:`
- 단추와 탭: 창에 마우스를 올렸을 때만 보이고, 마우스가 떠나면 잠시 뒤 사라지는가 · 입력창 테두리는 글을 쓰는 동안만 보이는가. — `결과:`
- 한글 입력: 1번 창 입력창에 한글을 쳐서 보내면 글자가 깨지지 않고 보이는가. — `결과:`
- 한/영 전환: 1번 창 입력창에서 한/영 키로 한글·영문을 오가며 칠 수 있는가(`/run` 없이 · 글꼴 크기를 Chattynator 설정에서 바꾼 뒤에도). 입력창 크기·자리가 전과 같아 보이는가. — `결과:`
- 귓속말: 다른 캐릭터(또는 자기 자신)에게 `/w <이름> 시험` → 2번 창에 보이고 1번 창에는 안 보이는가. — `결과:`
- 파티 찾기 채널: `/join <파티 찾기 채널 이름>`(위 채널 목록에서 본 이름) → 그 채널 글이 3번 창에만 보이는가 · 1번 창에서는 빠졌는가. 파티 찾기 채널이 없으면 「못 봄(채널 없음)」. — `결과:`
- `/reload` 뒤: 창 세 개의 자리·크기·탭·채널 배치가 그대로인가 · 이전 대화 글은 다시 접속하면 남지 않는다(메시지 저장 기본 꺼짐 — Chattynator 설정에서 켤 수 있음). — `결과:`
- 테마 바꾸기: 스킨이 「Devil Forever」 일 때 `/dfp theme <번호>` 또는 상태띠 ▶ → 고른 탭 글자색과 입력창 테두리 색이 새 테마 색으로 바뀌는가(`/reload` 없이). — `결과:`

## 11. 유닛 프레임 글자·시전 막대·주시 대상 오라 (Step 61)

- 적용 방법: 이미 쓰던 PitBull4 프로필은 설치 뒤 첫 접속 때 저장된 배치 판(`dfLayoutRevision`)이 이 빌드보다 낮으면 쓰던 버전(New 또는 Old)을 상태띠 버전 전환과 같은 길로 한 번 다시 적용하고 화면을 다시 불러온다(전투 중이면 전투가 끝난 뒤 · 프로필·판마다 한 번 · 대화창 위치는 건드리지 않음). 새 프로필은 처음부터 들어간다. 손으로 다시 넣으려면 상태띠 버전 전환 또는 `/dfp preset <fhd|qhd|uhd>` → `/dfp go`.
- 첫 접속: 설치 뒤 처음 들어가면 화면이 한 번 다시 불러와지고, 그 뒤 대화창에 `[DF 설정] New 배치를 이 판에 맞춰 다시 적용했습니다(PitBull4·Quartz·Grid2).`(Old 를 쓰던 프로필이면 `Old 배치를…`) 한 줄이 한 번 나오는가 · 다시 접속하거나 `/reload` 해도 그 줄과 다시 불러오기가 또 일어나지 않는가 · 대화창(Chattynator)을 손으로 옮겨 두었던 자리가 그대로인가. — `결과:`
- 이름 글자: 플레이어·대상 프레임의 이름이 소환수·주시 대상 프레임 이름보다 프레임 높이 비율만큼 크게 보이는가(fhd 72/56 · qhd 96/74 · uhd 144/112 = 약 1.29~1.30배) · 생명력·마력·레벨/직업 글자는 전과 같은 크기로 막대 안에 있는가 · 이름이 레벨 글자와 겹치지 않는가. — `결과:`
- 시전 막대(New 배치): 자기에게 주문을 시전할 때 플레이어 프레임 아래 작은 프레임 줄 밑에 Quartz 시전 막대(주문 아이콘 포함) 하나만 보이고, 대상 시전 막대와 같은 줄·같은 폭인가 · 화면 가운데 위의 막대와 납작한 노란 막대는 더 이상 없는가. — `결과:`
- 주시 대상 오라(New 배치): 주시 대상 프레임 위 버프·약화 효과 아이콘이 소환수 프레임 위 아이콘과 같은 크기·같은 높이인가 · 플레이어·주시 대상·대상 사이 간격이 같고 토템 시간 칸이 플레이어 프레임 위 오른쪽에 있는가(§6 의 「플레이어·대상·주시 대상의 버프·약화 효과가 같은 모양」 줄은 이것으로 바뀐다 — 주시 대상은 소환수 모양). — `결과:`
- Old 배치: 시전할 때 화면 가운데 위 Quartz 시전 막대(아이콘 포함) 하나만 보이고, 플레이어 프레임 아래쪽 안의 얇은 PitBull4 시전 막대(주문 이름)는 더 이상 없는가 · 그 자리만큼 플레이어 프레임의 생명력·마력 막대가 조금 높아졌는가. — `결과:`

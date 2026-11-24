# Step 52 — 0.1.5 PitBull4판 게임 폴더 설치·확인표

Phase 27 · 2026-11-24 20:40–21:01 +0900

## 수행
- 같은 작업 A 가 Step 51 커밋(`c34716a3`)에서 PitBull4판 설치 트리를 만들었다: `D:/Projects/Project_WF/_local_only/claude-p27-stage-255f4725/AddOns` + `receipt.json`(35 폴더 · 2,275 파일 · 338,652,752 B · 파일마다 sha256). build.py 의 릴리스 함수(폴더 고르기·원천·검사·파일 계획)를 썼다.
- 새 도구 `Collection/tools/install_local.ps1`(배포 안 함): 게임 경로 고정·Wow.exe·실행 중 거절·링크 거절·영수증 대조 → `AddOns`·`WTF` 백업과 목록 대조 → 패키지 폴더 35개만 미러 → 설치 뒤 대조 → `installation.json`. 게임에 쓰기 시작한 뒤 실패하면 「일부 바뀜」·백업 경로·되돌리기 명령을 낸다.
- 확인표 `Collection/codex-briefs/phase27-game-check.md`: 0 설치·되돌리기, 명령 표(file:line), Step 47·50 항목 1–8(Hekili 뺌), 9 테마 넘김. 플레이 없이 설정·시험 모드·슬래시 명령·`/reload` 로 보는 법(R154). 확인으로 바뀐 설정은 게임을 끄고 WTF 백업을 복사해 되돌린다.
- 검수 B: 중대 0 · 중간 3(M1 측정식이 화면 아래 기준 · M2 반만 설치됐을 때 알리지 않음 · M3 「원래 preset 으로 되돌리기」가 설정을 덮어씀) → master 원문 확인 → 같은 A 가 한 번에 고침 → 같은 B 재검증 중대·중간 0 · 경미 2.
- master 가 복원 지점 커밋(`b8e1a889`) 뒤 실제 설치를 돌렸다: 게임 꺼짐 확인 → `install_local.ps1 -StagedAddOns …\claude-p27-stage-255f4725\AddOns -BackupRoot D:\Projects\Project_WF\_local_only\claude-p27-backup-5b85dff4` (pwsh 7) → `installed 35 folders, 2275 files; installation.json in …claude-p27-backup-5b85dff4` · RC=0.

## 근거·판단
- 읽은 범위(master): 세부 계획서 Step 52 행, brief-52·brief-52-review(직접 씀), 작업 A 반환 글 두 번, 검수 B 보고 두 번, 인용 대조 — `phase27-game-check.md:4,33,38,70`, `install_local.ps1:93,178,187,199–201`, `Presets/fhd.lua` Grid2 줄(grep), `Grid2/GridLayout.lua:882`, `Presets.lua:304–306,323–327`, 설치 뒤 `installation.json` 1–40. 작업 A 범위 = `iter_1/work_log-52.md`, 검수 B = `iter_1/audit_log-52.md`·`audit_log-52-recheck.md` 「읽은 범위」.
- 영향 지도(고침 라운드) 전 행 = `TRIAGE_phase27.md` 「Step 52 review」 절:

| 곳 | 영향도 | 이유 |
|---|---|---|
| 확인표 :33 측정식 · :38 비교값 | 함께 고침 / 확인만 | M1 |
| install_local.ps1 :165–201 | 함께 고침 | M2 |
| 도움말 되돌리기 · 확인표 :13 | 확인만 | 같은 문구 유지 |
| 확인표 :4 · :38 · :51 · :70 | 함께 고침 | M3 |
| phase26-step47-check.md | 영향 없음(기록) | 옛 발주문, 숫자는 맞음 |

- 정한 것: 설치 폴더 묶음은 릴리스와 같게(Hekili 폴더 포함 — R153 은 Hekili 작업 제외이지 폴더 제외가 아님, 작업 A·검수 B 판단과 같음). `patches.py`·`build.py` 는 스크래치 래퍼로 실행(원래 있던 Windows 문제, 도구는 안 고침).
- 게임 폴더: 패키지 폴더 35개만 바뀜. `!BugGrabber`·`BugSack`·`AddOns.BeforeDevilForever015-3434ca83`·Codex 백업은 그대로. WTF 는 건드리지 않음(백업만).

## 변경·생성 파일
`Collection/tools/install_local.ps1` · `Collection/codex-briefs/phase27-game-check.md` · 기록 `Claude/results/handoffs/phase27/{brief-52.md,brief-52-review.md,TRIAGE_phase27.md,iter_1/work_log-52.md,iter_1/audit_log-52.md,iter_1/audit_log-52-recheck.md}` · git 밖: 스테이징 `_local_only/claude-p27-stage-255f4725`, 백업 `_local_only/claude-p27-backup-5b85dff4`(AddOns 2,238 파일 · WTF 105 파일 + installation.json), 게임 `Interface/AddOns` 35 폴더.

## 게이트
work_log-52 판정 줄: 드라이런 pwsh 7·5.1 rc=0(35 폴더·2,275 파일·갱신 2,209·새 66·지움 0) · 거절 시험 rc=1 · -Help rc=0 · 고친 뒤 같은 판정. 검수 중대·중간 3 → 0. 실제 설치 RC=0, 설치 뒤 대조 통과(스크립트 :196), installation.json 기록. 서브 토큰: 작업 A 누적 510,849 · 검수 B 누적 328,778(작업 기록 알림 값).

## 다음
Step 53 — Haiku 서브 화면 확인(R154).

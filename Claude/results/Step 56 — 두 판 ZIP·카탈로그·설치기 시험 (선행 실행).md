# Step 56 — 두 판 ZIP·카탈로그·설치기 시험 (선행 실행)

Phase 27 · 2026-11-24 21:06–21:14 +0900

## 수행
- Step 53(게임 확인)이 사용자 대기로 막혀 릴리스는 기다리고, 게시 없이 할 수 있는 일을 먼저 했다. 같은 작업 A(bada-a2-coder) → 같은 검수 B(④ 기계적 변경).
- 후보 ZIP(커밋 `3facebd5`, Collection 은 `c34716a3` 와 같음) — 폴더 `D:/Projects/Project_WF/_local_only/claude-p27-release-1c6f066c/`, 두 번 빌드 같은 바이트:
  - `DevilForever-0.1.5.zip` (PitBull4) 81,650,602 B · `9d4d371e14814d62eff23f19ad5c987c3463b8f7d033192ff2132d375eb95d7c` · 35 폴더
  - `DevilForever-0.1.5-fuf.zip` 82,305,192 B · `4bfe901b69bf3facc8fb5afe2f222472f26fffc3c1f4a17c4c625516ca4fa2d1` · 37 폴더
- `Collection/Installer/ReleaseCatalog.json` 를 `catalog.py` 로 다시 씀 → `--check` 「matches the ZIPs」.
- .NET SDK 10.0.404(사용자 폴더 `C:\Users\lksz1\.dotnet`, 공식 설치 스크립트 — §11 질문 1 기본값)로 설치기 빌드: `installer/DevilForeverSetup.exe` 51,700,838 B · `37f605a8…645f`.
- 설치기 시험 `Collection/tests/installer/run.py`: 9 PASS / 23 호출 — 승인 두 판 받음, 비교판(one-session)·변조판 쓰기 전 거부, 게임 폴더 안 씀.

## 근거·판단
- 읽은 범위(master): brief-56(직접 씀), 작업 A 반환 글, 검수 B 보고. 작업 A 범위 = `iter_1/work_log-56.md`, 검수 B = `iter_1/audit_log-56.md` 「Read」.
- 영향 지도(카탈로그 변경) 전 행 = work_log-56 「Impact map」:

| 곳 | 영향도 | 이유 |
|---|---|---|
| `ReleaseCatalog.json` | 함께 고침 | 새 ZIP 값 |
| Publish-Installer.ps1 · csproj · ApprovedPackage.cs · Contract.md · tests/catalog · catalog.py | 확인만 | 값을 읽기만 함(검수 B git grep 으로 지도 밖 없음 확인) |

- 정한 것(기본값 · 결정 대기): 릴리스 때 최종 커밋 뒤 설치기를 다시 빌드한다(EXE ProductVersion 이 커밋 id 를 담으므로). 설치기 EXE 는 릴리스에 붙이지 않는다(Codex 계획 — 릴리스 하나에 ZIP 하나).
- 원래 있던 문제(고치지 않음, 최종 보고): `patches.py` os.devnull · `catalog.py` 드라이브가 다르면 relpath 오류 · `ReleaseCatalog.json` 줄바꿈 속성 없음.

## 변경·생성 파일
`Collection/Installer/ReleaseCatalog.json` · 기록 `Claude/results/handoffs/phase27/{brief-56.md,iter_1/work_log-56.md,iter_1/audit_log-56.md}` · git 밖 `_local_only/claude-p27-release-1c6f066c/`.

## 게이트
두 번 빌드 같은 sha256 · catalog --check rc=0 · tests/catalog 3 pass 1 skip(TEMP 를 D: 로) · Publish rc=0 · installer run.py rc=0 9 PASS. 검수 B 중대 0 · 중간 0 · 경미 3. 서브 토큰 누적 작업 A 545,635 · 검수 B 350,628.

## 다음
Step 53 사용자 확인 대기. 확인이 끝나면(고칠 것이 없으면) 이 ZIP 그대로 Step 54·55 게시, 고칠 것이 있으면 고친 뒤 다시 빌드.

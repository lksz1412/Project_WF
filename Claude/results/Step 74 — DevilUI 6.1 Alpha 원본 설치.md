# Step 74 — DevilUI 6.1 Alpha 원본 설치

Phase 27 · 2026-11-26 18:35–18:45 +0900 · 요청 R249

## 수행
- idx=45 페이지(Chrome, 사용자 로그인 상태)를 읽음: 제목 "DevilUI 6.1 Alpha", 등록 nicecurry, 최종 2015.03.04, 클라이언트 5.3.0 · 애드온 5.3a 표기. 다운로드 단추 = `javascript:downloadLatest();`. 최신 첨부 = `DevilUI6.1Alpha.zip`(이미 보관: `SourceArchive/user-provided-alpha/originals/DevilUI6.1Alpha.zip`, 7,517,334 B, SHA-256 앞 16자 1982b7b99f4f9cd5) — 안에 NSIS 설치 EXE 하나(`DevilUI 6.1 Alpha.exe`).
- 설치 EXE 는 실행하지 않았다(내려받은 실행 파일은 돌리지 않는다는 규칙). 대신 저장소에 커밋된 정적 추출본 `work/old-reference-collection-0qlzzyxg/extracted-alpha-nsis`(2,745 파일)를 설치기와 같은 자리로 복사했다. 설치기 선택지(`$PLUGINSDIR/DevilUI.ini`) NORMAL/SPECIAL 중 **SPECIAL(하단 집중형)** — 사용자가 기준으로 고른 idx45 네 번째 샘플이 SPECIAL Wide 라서(기본값 · 결정 대기에 기록).
- 순서(게임 꺼짐 확인 뒤): WTF 전체 사본 → `D:/Projects/Project_WF/_local_only/claude-p27-devil61-backup-b3cc320e/WTF` · Fonts 목록 `Fonts-before.txt` · `Interface/AddOns` → `AddOns.BeforeDevil61Alpha-b3cc320e` 로 이름 바꿈 · SavedVariables 3곳(계정 공통·계정·캐릭터) → `SavedVariables.BeforeDevil61Alpha-b3cc320e` · 새 `Interface/AddOns` = 추출본 `Interface/addons` + `var/SPECIAL/Interface/AddOns` 덮어쓰기 · `!BugGrabber`·`BugSack` 은 옛 폴더에서 복사해 넣음(원본은 손대지 않음) · `Fonts` 에 2002.ttf·2002b.ttf·K_Damage.TTF 추가(같은 이름 없음 확인).
- Config.wtf 는 덮어쓰지 않았다: 설치기의 Config.wtf(SPECIAL·STANDARD 같음)는 창 모드·소리·그래픽·locale 만 담고 있고, 애드온(`!DevilUI.lua:225–240`)이 첫 접속 때 `checkAddonVersion 0`·`uiScale` 등을 스스로 건다. 사용자 접속 설정을 지키려고 그대로 둠(결정 대기).
- 되돌리는 법: 백업 폴더 `RESTORE.txt`.

## 근거·판단
- 읽은 범위: idx=45 페이지 본문 · `extracted-alpha-nsis` 목록·`var/SPECIAL/WTF/Config.wtf` 전문·`$PLUGINSDIR/DevilUI.ini` 1–40 · `!DevilUI.lua` 의 StaticPopup/SetCVar 줄(66–243 검색) · `Codex/docs/old-devil-reference-comparison.md` 24, 97, 171 줄 · 게임 `PitBull4.toc` Interface 줄.
- 클라이언트 판: 게임의 기존 PitBull4 = `## Interface: 16001`, Devil 6.1 Alpha = `60100`. 판이 크게 달라 많은 애드온이 "구버전"으로 꺼지거나 오류를 낼 수 있음 [추정 · 게임에서 미확인]. 페이지 댓글(2025-03-13)에 "설치는 했지만 아무런 변화가 없는" 이 있음.
- 영향 지도: 저장소 코드 변경 없음 · 게임 폴더 = 이름 바꿔 보관 + 새로 복사(삭제 없음).

## 변경·생성 파일
- 게임 폴더(위 목록) · 백업 폴더 `claude-p27-devil61-backup-b3cc320e`(WTF 사본·Fonts-before.txt·RESTORE.txt) · 세부 계획서 Step 74–75 행 · 요청 대장 R249.

## 게이트
- 설치 폴더 127개(추출본 124 + Devilconfig + !BugGrabber + BugSack) · 파일 2,727 · 덮어쓰기 대상 아닌 기본 파일 비교 불일치 0 · SPECIAL 덮어쓰기 파일 비교 불일치 0.

## 다음
사용자가 게임에서 확인(첫 접속 때 Devil 설정 창 · 캐릭터 선택 화면 애드온 목록의 "구버전 애드온 불러오기"). Step 72 설치는 사용자가 우리 모음집으로 되돌리라고 할 때까지 보류. Step 75(포럼 글 1636 읽기)는 Step 72 유닛 뒤.

# Step 59 — HUD 부품 조립 코드 · Codex 부품 규격서

Phase 27 · 2026-11-25 07:15–07:35 +0900

## 수행
- R162(그림은 Codex, Claude 는 코드·위치)에 따라 같은 작업 A 가 만듦: Codex 부품 규격서 `Collection/codex-briefs/appearance-27-hud-parts.md`(테마 × fhd/qhd/uhd, 필수 16 + 선택 문장, 크기·형식·반복 방향), 부품 조립 코드(`Composition.lua` — 같은 배율, 반복 띠는 잘라 쓰고 늘리지 않음, 이음매는 실제 대화·단축바·미니맵 칸 경계, 단축바 1–3 둘레 틀은 실제 Dominos 바 크기 + 여백, 바·버튼·Masque 보다 한 단 위, 마우스 끔), 부품이 없으면 지금 그림 그대로(호출 하나하나 같음), 임시 부품 도구 `tools/hud_parts.py`(AddOns 밖에만 씀), 시험 `tests/composition/parts.py`.
- 검수 B(code ③ 3라운드): 중대 0 · 중간 1(Dominos 설정에서 바를 끌어 옮기면 틀이 안 따라감) · 경미 4. master 원문 대조(dragFrame.lua:311–313, Composition.lua:64–65) → 같은 A 가 `SavePosition` 훅 추가·시험 추가 → 같은 B 재검증 중대·중간 0.

## 근거·판단
- 읽은 범위(master): 작업 A 반환 글 2건, 검수 보고 2건, dragFrame.lua 308–314, Composition.lua 64–65 · 바뀐 diff, frame.lua 함수 위치 grep.
- 영향 지도 전 행 = `iter_3/work_log-59.md` (본 작업 · Review fix 절). 요약:

| 곳 | 영향도 | 이유 |
|---|---|---|
| Composition.lua | 함께 고침 | 부품 조립·둘레 틀·훅 |
| Appearance.lua 호출(Create/Apply) | 확인만 | 서명 그대로 |
| Skin_Dominos/Skin.lua | 확인만 | 꼬리 바 빈 칸이 틀 안(경미) |
| Codex 규격서 · 도구 · 시험 | 함께 고침(새 파일) | 숫자는 코드 표에서 |

- 정한 것(작업 A 기본값, 사용자 확인 대기): 부품 크기(끝 48/64/96, 이음매 16/20/32, 나사 8/10/16, 틀 두께 6/8/12 …) · 틀은 Dominos 흐려짐을 따라가지 않음(경미) · 부품 모드에서는 옛 홈 테두리를 그리지 않음.

## 변경·생성 파일
커밋 7797ed71 · 034a2552 — Composition.lua, tools/hud_parts.py, tests/composition/parts.py, codex-briefs/appearance-27-hud-parts.md · 기록 brief-59*.md, iter_3/work_log-59.md, TRIAGE.

## 게이트
composition 8/8 · parts 12/12(훅 뺀 사본에서 끌기 사례 FAIL 확인) · 옛/새 Apply 호출 56 일치 · statusstrip 20/20 · core 109/109 · 나머지 suite 통과 · luacheck 0 · art check 0 · extract·genregistry·patches · build dry-run 2284/2228(새 배포 파일 없음) · 성능 시험은 `--dominos-zip` 입력이 없어 못 돌림. 검수 중대·중간 1→0.

## 다음
설치(화면 변화 없음 확인용) → 사용자 퇴근 뒤 확인. Codex 는 규격서로 그림 작업(사용자 전달). 대화창 대체(R163) 결정 대기.

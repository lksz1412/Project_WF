# Step 70 — 데빌 버프·디버프 배치 조사와 제시안 4종

Phase 27 · 2026-11-26 (끝 09:02 +0900)

## 수행
- R238–R244: master 가 인벤 Devil 글 사진 72건 중 70장 받음(`_local_only/devil-inven-r240/images`, 8906 두 장 404) → 판독 서브가 68장(고유) 판독(`iter_4/devil-aura-images.md`) → A1 분석 서브(+A4 helper 다운로드·정적 추출, 실행 없음)가 첨부 54개 중 53개 받아 유닛 프레임 설정 93파일·프로필 119개 집계 + 인터넷 자료 → 제시안 4종(통계 3 · 독자 추천 1) `Claude/results/handoffs/phase27/proposal-70-auras.md`.
- 같은 검수 B(P5 ②): 중대 0 · 중간 1(제안마다 대상 근거 수 기준이 다름) · 경미 4 → 같은 A1 이 한 번에 고침 → 같은 B 재확인: 중대·중간 0 · 경미 1(W·Normal 화면 비율 설명 근거 없음) → master 가 표기만 [근거 미발견] 으로 고침(단순 표기).

## 근거·판단
- 읽은 범위(master): 판독 보고 둘, A1 보고 둘, B 보고 둘, `proposal-70-auras.md` 1–229 전문, `tally.txt` 1–11, `HideBlizzard.lua` 10–26, `Defaults/PitBull4.lua` 248–256, `Codex/docs/old-devil-reference-comparison.md` 1–192.
- 영향 지도: 고친 것은 제안 문서 한 파일(대상 수 기준 통일 — 표 2 메모·제안 A–D·비교 표·§0·§6) — 전 행은 `iter_4/work_log-70.md` 「Step 70 fix」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| proposal-70-auras.md 의 대상 수 문장 전부 | 함께 고침 | 같은 모양 기준으로 통일 |
| 표 2 행 | 확인만 | 이미 맞음 |
| 애드온 코드 | 영향 없음 | 제안만 — 사용자가 고른 뒤 구현 |

- 남은 한계: 34개 글 본문 사본 전체 정독 안 함(검색만), 11218·11361·12174 설치 EXE 못 엶, 게임에서 기본 버프 창 위치 미확인.

## 변경·생성 파일
`Claude/results/handoffs/phase27/{brief-70.md,brief-70-review.md,proposal-70-auras.md}` · `iter_4/{devil-aura-images.md,work_log-70.md}` (원자료·사진은 git 밖 `_local_only/devil-inven-r240/`)

## 게이트
집계 수 = tally 원본(B 재계산 일치) · 인용 코드 줄 원문 일치(B) · ElvUI 줄 번호 사본 대조 일치(B).

## 다음
사용자가 돌아와 제안 하나와 §7 두 가지를 고르면 같은 작업 A 가 구현.

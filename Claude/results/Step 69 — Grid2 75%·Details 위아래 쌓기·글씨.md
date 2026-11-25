# Step 69 — Grid2 75%·Details 위아래 쌓기·글씨

Phase 27 · 2026-11-26 (끝 08:25 +0900)

## 수행
- R233–R237(사용자 스크린샷): 판독 서브가 스크린샷을 읽음(`iter_4/image-17-reading.md`) → 같은 작업 A(brief-69.md): Grid2 칸 75%(fhd 88→66 · qhd 116→87 · uhd 176→132) · 이름 글씨 15/20/30 · 다른 글씨 11/15/23(모음집이 쓴 값일 때만 한 번 바꿈) · layoutV2Revision 7→8 · Details 위협(위)·피해량(아래) 쌓기 — uhd 3437,1342,403,223 / 3437,1573,403,223 · qhd 2351,895,209,134 / 2351,1034,209,135 · fhd 단축바 위 최선 배치(1559,671,361,61 / 1559,736,361,62) · Details 막대·제목 글씨 11/15/22, 막대 높이 16/21/30 · 대화창 높이(R234)는 코드 변경 없음(저장된 창 = 패널 안쪽 규칙, 남은 어긋남은 테마 그림 — 확인표 §17).
- 같은 검수 B(Musca 와 묶음, code ③ 3라운드, brief-6469-review.md): 중대 0 · 중간 0 · 경미 5.

## 근거·판단
- 읽은 범위(master): 스크린샷 판독 보고, A 보고, B 보고, `Layout.lua` 44–82(placeable), 저장된 Details.lua 의 `__snap`(두 창 모두 빈 표·`__snapV/H` false → B 경미 2 의 "붙은 창이면 안 옮김" 은 이 사용자에게 해당 없음).
- master 결정(처리표 TRIAGE_phase27.md): 사용자가 끈 모음집 창도 R235 자리로 한 번 옮김 · fhd 최선 배치 · 오른쪽 장식과 겹침 허용 · 대화창 높이 코드 변경 없음.
- 영향 지도 전 행 = work_log-60 「Step 69」.

| 곳 | 영향도 | 이유 |
|---|---|---|
| Presets fhd/qhd/uhd/V2 · Defaults/Grid2 · DetailsLayout | 함께 고침 | 요청 |
| 따라잡기(revision 8) | 함께 고침 | 기존 설치에 새 칸 크기 |
| PitBull4·Quartz·Dominos·SexyMap 값 | 확인만 | revision 8 로 같은 값 한 번 다시 씀(B 경미 4) |
| Chattynator 대화창 | 확인만 | 저장값이 규칙대로 — 코드 변경 없음 |
| 지난 기록 | 영향 없음(기록) | 당시 기록 |

## 변경·생성 파일
Presets/{fhd,qhd,uhd,V2}.lua · Defaults/Grid2.lua · DevilForever_DetailsLayout/{Layout.lua,.toc} · tests layoutv2/detailslayout/firststart · 설치안내 · feature-map · 확인표 §15·§17

## 게이트
layoutv2 46 PASS · detailslayout 21 · firststart 30/30 · core 110/110 · chatsetup 47 · statusstrip 20 · pitbull4runtime 20 · luacheck 0 · genregistry up to date · build dry-run 30/2800 · 32/2744 (work_log 판정 줄).

## 다음
커밋 → 게임이 꺼지면 설치 → 사용자 확인(§15–§17). 경미 5건·결정 대기는 최종 보고.

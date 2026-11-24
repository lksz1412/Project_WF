# Step 50 — Grid2 창 자리 오른쪽 대상 위 (Phase 26-rev)

## 수행
- R148: Grid2 기본 창을 화면 위 가운데에서 오른쪽 PitBull4 대상(적) 프레임 위로. 같은 A2 coder 가 fhd/qhd/uhd + V2 조각에 BOTTOMRIGHT 기준(오른쪽 끝 = 대상 오른쪽 끝, 위·왼쪽으로 자람)으로 넣고, 겹침 시험을 PitBull4 Aura 모듈 실제 계산(회피 규칙·그룹별 16+16)으로 바꿈. 같은 B 검수 0·2·1 → 고침 → 재검증 0·0·1.
- 자리(물리 px, 아래 끝 y): V1 fhd 304 · qhd 452 · uhd 762 / V2 fhd 347 · qhd 541 · uhd 904. `/dfp party on` 옛 자리 이동은 활성 preset(V1/V2) 자리로.

## 근거·판단
- 읽은 범위: 세부계획 Step 50 행, fhd.lua:589, PitBull4 Aura/Layout.lua:455·461, V2.lua(Grid2 grep). 서브 범위 = work_log-47 「Step 50」·「Step 50 고침」, audit_log-50-1/2.
- 영향 지도: 전 행 = work_log-47 「Step 50」 절(작업 A).
- 남은 것(최종 보고): fhd V1 에서 주시 대상이 보이고 대상 약화 효과가 거의 꽉 찰 때(남의 것 16 + 내 것 11 이상) 대상 오른쪽 오라 기둥이 Grid2 아래 13 px 까지 — Hekili 줄 때문에 더 못 올림. V2 를 기준보다 넓은 화면에서 쓰면 Grid2 오른쪽 끝이 대상에서 (폭 차이/2) 만큼 벗어남.

## 변경·생성 파일
- Presets/fhd·qhd·uhd·V2.lua, Party.lua, Presets.lua(문구), tests/layoutv2·firststart, 설치안내.md, feature-map.md, codex-briefs/phase26-step47-check.md, ReleaseCatalog.json.

## 게이트
- suites 13개 통과(firststart 28) · patches verify 7/20/0 · genregistry up to date · build 두 번 같은 해시 · ZIP 0efdb7218a75b4b0c380f9fb4ecd71389efade321dfe5e840b353a82bd1671da / fuf d641a4ce40121b63319e6f503a82fbb7e202bf8dee50d154634b0ff8454f3fce · catalog --check 일치. detailslayout·performance·installer 는 앞과 같음.

## 다음
- 커밋·푸시·main 머지(R149). Codex 게임 확인.

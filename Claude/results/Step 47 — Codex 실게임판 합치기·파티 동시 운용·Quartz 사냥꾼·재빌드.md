# Step 47 — Codex 실게임판 합치기·파티 동시 운용·Quartz 사냥꾼·재빌드

Phase 26 · GO R147(2026-11-24 18:14 KST) · 끝 19:10 KST

## 수행
- master: Codex 가지 `codex/live-015-pitbull-20261124`(d8b63f59) 합침 — 충돌 없음, 커밋 9c46a837.
- 같은 A2 coder(af6f0db6ed69ea82b) 가 발주문 `handoffs/phase26/iter_3/brief-47.md` 를 구현 → 같은 B(a9e959095c3408e8b, 코드 ③ 3라운드) 검수 0·2·6 → 고침 1 → 재검증 0·1·2 → 고침 2 → 재검증 0·0·1 → master 문구 한 줄.
- 내용: 파티 단일 담당 폐지(PitBull4 파티 + Grid2 동시, 공격대 포함, `/dfp party on|off` = 유닛 프레임 파티 스위치, 접속 때 비교·되쓰기 없음) · 파티원 소환수 그룹 실제 생성(빈칸 모드) · 이전 판 설치를 명시 명령으로 새 설계에 맞춤(Grid2 창은 옛 기본 자리일 때만 옮김) · V2 오라 상속 제거(fragment `replace`) · Quartz 스윙 = 사냥꾼만, 정지 구간 `dfStandStill` 0.5, enum 폴백 · Grid2 패치 신설(훅 존재 확인·UNIT_FACTION 묶음) · Grid2 템플릿 자동 선택·미니맵 단추 숨김(새 프로필) · Grid2 기본 자리 = 화면 위 가운데(겹침 시험) · 문서 2개 갱신 · 패치 개수 시험 고침. Hekili 는 손대지 않음(R144 ⑥).
- master 실수와 복구: catalog.py 를 `--write <zip>` 꼴로 불러 PitBull4 ZIP(빌드 산출물, 저장소 밖)에 JSON 이 써짐 → 다시 빌드해 같은 해시(1a9516de…)로 복구, 인자 순서를 `<zips> --write` 로 다시 실행.

## 근거·판단
- 읽은 범위: Phase 26 세부계획 전문(Step 착수 재독), Party.lua 110-115·136·151-159·415(검수 인용 대조), Presets/fhd.lua Grid2Layout 줄·469-472, catalog.py 55-75. 작업 A·검수 B 의 읽은 범위 = `iter_3/work_log-47.md`, `audit_log-47-1/2/3.md`.
- 영향 지도: 전 행 = `iter_3/work_log-47.md`(작업 A). master 가 고친 한 줄 = Party.lua:415 문구 → 함께 고침 tests/firststart/run.py:886 · 확인만 설치안내.md:57(문구 인용 없음) · 영향 없음(기록) audit log·TRIAGE.
- 결정 대기(최종 보고): Grid2 를 화면 위 가운데에 두는 것(시선 이동·인원 따라 가로 폭 변화 — B 의견) · 게임 글자 겹침·정지 구간 실제 값·늦은 사격 숨김 = Codex 확인.

## 변경·생성 파일
- Core 10, Skin_Dominos, Grid2 2(+ `patches/Grid2.patch` 신규), PitBull4 1, Quartz 1(+ 두 패치), 시험 5, extract.py, manifest 2, ReleaseCatalog.json, 설치안내.md, feature-map.md, Codex 확인 문서 `Collection/codex-briefs/phase26-step47-check.md`(신규).

## 게이트
- suites: castbars 16 · catalog 4 · chatsetup 32 · composition 8 · core 109 · firststart 27 · fufdefaults 22 · layoutv2 rc0 · patches 4 · pitbull4 6 · pitbull4runtime 20 · statusstrip 20 · thirdparty 8 — 전부 통과(work_log 판정 줄 + master 재실행 firststart·catalog).
- 못 돈 것: detailslayout(커밋된 적 없는 References 조각 파일 — 원래 있던 결함), performance(HEAD 에서도 같은 줄 실패 — 원래 있던 결함), installer(Windows exe 필요).
- patches verify 7/20/0 · genregistry up to date · build 두 번 같은 해시 · ZIP sha256 PitBull4판 1a9516de3d9c7d625bdf0099c05274e4f7e5f6de0b6ddc0260c63c9973cf627d, fuf판 a50fe2d1c03dee5f7ab61ad15d2dc7f2836ac6cfe0e80e9b6e9cf76b305af85b · catalog --check 일치.
- 검수 비용: A ≈428k+504k+528k 토큰, B ≈566k+617k+635k(누적 context), 약 55분.

## 다음
- Codex: `phase26-step47-check.md` 게임 확인 · 테마 전환 그림(appearance-26). R128: 두 판 따로 올리기는 Codex 확인 뒤.

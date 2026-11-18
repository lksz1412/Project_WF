# Phase 24 · Step 39 — work_log (A2 writer)

## 읽은 범위 (판단 근거)

| 파일 | 줄 |
|---|---|
| `Claude/plans/2026-11-18-devil-forever-addon-collection-plan.md` | 90–98(94 포함), 140–148(144–146 포함), 335–355(339·351 포함), 409–416(413 포함), 452–458(455 포함) — 발주문이 정한 줄과 그 둘레 |
| `Claude/plans/2026-11-18-devil-forever-addon-collection-phase24-세부계획.md` | 1–7 전문 |
| `Claude/results/handoffs/settings-phase-brief-template.md` | 1–28 전문 |
| `Claude/results/handoffs/phase24/SESSIONS.md` | 전문 |
| `Codex/docs/devil-ui-old-4k-layout.md` | 1–105 전문 |
| `Collection/codex-briefs/appearance-2.md` | 1–36 전문 |
| `Collection/codex-briefs/appearance-2-layouts.md` | 1–52 전문 |
| `Collection/codex-briefs/appearance-22.md` | 1–30 전문 |
| `Collection/codex-briefs/appearance-{3,4,5,6,6-rev,7,8,9,10,14,15,16,19}.md` | 각 1–12 (머리) |
| `Collection/install.json` | 1–36 전문 |
| `Collection/install/설치안내.md` | 1–53 전문 |
| `Collection/data/classes.md` | 1–47 전문 |
| `Codex/results/old-devil-layout/layout-spec.json` | python 으로 최상위 키, `elements` 의 `proposal-label`·`world-context`, `rendererContract.requiredOutputs`·`outputBase`·`placeholders` 만 (DB성 JSON) |
| `Codex/results/old-devil-layout/DESIGN_READY.json` | 앞 1500자 (상태 확인) |
| `.claude/tools/banned_lexicon.json` | 앞 3000자 |

## 명령과 판정

| 명령 | 판정 |
|---|---|
| `ls References/codex-appearance/` | 없음 — 「cannot access」. 입력 결과물은 아직 하나도 없다 → 발주문 3절의 「외관 미완」·「설계 좌표 없음」 규칙으로 처리 |
| `ls Claude/results/handoffs/phase24/` | `SESSIONS.md` 하나. `iter_1/` 은 이 로그를 쓰며 만듦 |
| python `layout-spec.json` 키 조회 | `proposal-label` 문구 「배치 미리보기」 자리 [24,20,500,40] 28px · `world-context` notGameCapture true · requiredOutputs 5개 |
| `grep -nE "<금지어 7개 — 발주문 5항목>" Collection/codex-briefs/appearance-24.md` | rc=1, 걸린 줄 0 — 통과 |
| 경로 존재 검사(백틱 안 경로 추출 → `test -e`) | 저장소 경로 14개 모두 있음(appearance-9 를 전체 경로로 고친 뒤 재검사 OK). `References/codex-appearance/...` 9개는 없음 — Codex 가 올릴 자리라 의도된 것이고 발주문 머리에 「아직 없다」 고 적음. PNG·`mockup-index.md` 는 산출물 이름 |
| `sed -n '25p;28p;30p;33p' Collection/data/classes.md` | WARRIOR·ROGUE·SHAMAN·DRUID 줄 — 발주문 인용 줄 번호 맞음 |
| `sed -n 10p Collection/codex-briefs/appearance-9.md` | 「Grid2 는 공격대일 때만 보인다」 가 10행에 있음 |
| `wc -l Collection/codex-briefs/appearance-24.md` | 62줄 (1–2쪽) |

## 덮음 표 — 계획 339행 항목

| 339행 항목 | 발주문 자리 |
|---|---|
| 세 겉보기(FHD·QHD·UHD) 각각 | 1절 머리 · 표 전부가 `<겉보기>` 마다 |
| 전체 화면 | 1절 표 「전체 화면」 |
| 하단 원배율 잘라 보기 | 1절 표 「하단 원배율」(UHD y 1440–2160) |
| 단축키 글자 확대 | 1절 표 「단축키 확대」 |
| 직업별 자원 표시 예시 | 1절 표 「직업 자원 예시」 + 2절 직업 표(classes.md 25·28·30·33) |
| 데빌 기본 테마와 대안 테마 비교 | 1절 표 「테마 비교」 + 없으면 「대안 테마 없음」 |
| 모든 그림에 「목업 — 실제 게임 화면 아님」 | 2절 1 |
| Claude 가 Step 5 구획·표시 문구와 대조 뒤 채팅에 제시(R46) | 5절 |
| (351행) 입력 = 모든 기능의 manifest·토큰·테마 목록, 직업 자원 표 | 3절 입력 표 |
| (413행) 설계 좌표·실제 자산만, 게임 캡처처럼 꾸미지 않음 | 2절 2·3 |
| (455행) 목업은 게임 검증이 아님 | 머리 · 5절 끝 |

## 내가 정한 기본값 (결정 대기로 올림)

1. 전체 화면은 혼자 있는 상태 — Grid2 는 그리지 않음(공격대일 때만 보이므로).
2. 게임 기본 이름표 스킨(14)은 그리지 않음 — 중성 배경에 이름표가 붙을 unit 이 없음. 입력 표에서도 뺌.
3. FUF 비교 그림은 겉보기마다 1장(PitBull4 같은 자리 1장과 짝).
4. 직업 예시 4개: WARRIOR·ROGUE·SHAMAN·DRUID(표범). 고른 이유 = 자원 모양이 서로 다르고 classes.md 에 근거 줄이 있음.
5. 테마 비교는 대안 테마마다 전체 화면 + 하단 잘라 보기 두 장.
6. 단축키 확대 배수는 Codex 가 정수로 정함.
7. 템플릿 §3 게이트(genregistry·luacheck·빌드)는 이번 산출(문서 하나)에 해당 없음 — 코드·기본값 표를 만들지 않았다. 발주문이 정한 세 게이트로 대신 봄.

## 상태

산출 끝. 커밋 안 함(master 몫). 임시 파일 만들지 않음.

## fix 1 — 검수 1 반영 (M1·M2·M3 + 함께 고침 3)

### 읽은 범위
- `Claude/results/handoffs/phase24/iter_1/audit_log.md` 1–15 전문, `Claude/results/handoffs/phase24/TRIAGE_phase24.md` 1–17 전문
- `Collection/codex-briefs/appearance-24.md` 1–62 전문 (고치기 전)
- 인용 확인: 계획 351·433행, `appearance-4.md:32`, `appearance-10.md:31`, `appearance-22.md:26`, `appearance-2.md:32`, `appearance-9.md:29`(grep 「갈무리」)
- `Collection/manifest.md` 1–8, `Collection/manifest.json`·`registry_extra.json` 최상위 키 (python, DB성 JSON)
- `Codex/results/old-devil-layout/text-metrics.json` `checks` 의 key 역할 글자·`sampleGlyphs` 앞부분, `layout-spec.json` `rendererContract.referenceScreenshotInRenderedScene`(=False)·`elements` id 24개 (python)

### 영향 지도
| 자리 (고치기 전 줄) | 판정 | 이유 |
|---|---|---|
| :52 입력이 없을 때 (M1) | 함께 고침 → 새 :53–55 | 좌표 있는 구역 = 빈 테두리 + 「외관 미완 — 설계 좌표만」 유지, 결과도 좌표도 없는 구역 = 「자리 없음 — 못 그림」 |
| :29 §2-7 묶음 목록 | 함께 고침 | Quartz·Hekili·Details·Experience Forever 가 목록에 있으므로 「자리가 없는 구역은 3절 대로」 한 구 추가 |
| :48 §3 기능 외관 행 | 확인만 | 목록은 그대로 맞음 — 자리 없음 처리는 :53–55 가 맡음 |
| :40 직업 자원 「외관 미완」 | 확인만 | unit 묶음은 Step 5 좌표(`unit-upper`·`unit-lower`)가 있어 기존 규칙과 맞음 |
| :24 갈무리 금지 (M2) | 함께 고침 | 모든 갈무리 금지, `References/codex-appearance/*/` 보고서 갈무리 포함, `referenceScreenshotInRenderedScene` 근거 |
| :25 「결과에서 읽는다」 (M2·m4) | 함께 고침 | 읽는 것 = 코드·조각 파일의 자리·크기 값, 자산, 토큰 값. UHD = `uhd.lua` 있으면 preset, 없으면 Step 5, 다르면 preset + 색인 기록 |
| :28 비율 금지 | 함께 고침 | UHD 자리 출처를 2절 3 으로 가리킴 |
| :44–50 §3 입력 (M3) | 함께 고침 → 새 :51 | manifest.json·.md, registry_extra.json 행 추가 |
| :6 「모두 … 올릴 자리」 (m1) | 함께 고침 | `References/codex-appearance/` 아래만 올릴 자리, Step 5·`Collection/` 은 이미 있음 |
| :16 단축키 확대 (m5) | 함께 고침 | 키 글자 = text-metrics.json `checks` 예시 키 16개만 |
| :58 색인 칸 | 함께 고침 → 새 :61 | 「자리 없음」 구역·preset 과 Step 5 차이 칸 추가 |
| :62 §5 Claude 확인 | 확인만 | Step 5 구획·preset 대조 문장 그대로 맞음 |
| :23 FHD·QHD 표시 자리 · :14 혼자 상태 · R109 인용 | 영향 없음 | 발주대로 바꾸지 않음 (이미 정한 것·경미 → 최종 보고) |
| 이 work_log 앞 절 | 영향 없음(기록) | 당시 기록 |

### 명령과 판정
| 명령 | 판정 |
|---|---|
| python 치환 9건 (`s.count(a)==1` 단언) | 9건 모두 한 번씩 맞고 적용 — 62줄 → 65줄 |
| `grep -nE "<금지어 7개 — 발주문 5항목>" Collection/codex-briefs/appearance-24.md` | rc=1, 걸린 줄 0 — 통과 |
| 백틱 경로 추출 → `test -e` (References·자리표시 제외) | 저장소 경로 15개 모두 OK (새로 넣은 `Collection/manifest.json`·`Collection/manifest.md`·`registry_extra.json`·`text-metrics.json` 포함). 맨 이름(`classes.md`·`install.json`·`layout-spec.json` 등)은 같은 문서에 전체 경로로 적힌 파일의 줄임, `uhd.lua`·`layouts/*.lua` 는 `References/codex-appearance/2-layouts/` 아래 올릴 자리, `mockup-index.md` 는 산출물 |
| 줄 번호 확인 | 새로 넣은 `devil-ui-old-4k-layout.md:26–35, 45–56` 은 쌓기 표·좌표 표 줄과 맞음. text-metrics `checks` key 역할 글자 = C-S-1·1–8·A-1·C-1·E·F·Q·R·S-1 (16개) |

## fix 2 — 재검수 1 반영 (M1′ + 함께 고침 m1·m2·m3)

### 읽은 범위
- `Claude/results/handoffs/phase24/iter_1/audit_log.md` 16–22 (재검수 1 절), `Claude/results/handoffs/phase24/TRIAGE_phase24.md` 17–25 (재검수 1 절)
- `Claude/results/REQUEST_LEDGER_phase19.md:7` (R109 = Codex 보류, Claude 몫 먼저), `Codex/docs/devil-ui-old-4k-layout.md:60`, `Collection/install/설치안내.md:28`
- `Collection/codex-briefs/appearance-24.md` 19·29·35–40·51·54–56·61 (고치기 전, 앞 절에서 전문을 읽은 판 위)

### 영향 지도
| 자리 | 판정 | 이유 |
|---|---|---|
| :40 직업 자원 대체 규칙 (M1′) | 함께 고침 | unit 프레임 자원 = 6-rev 결과, 태세·토템 바 = Dominos 결과(3). 요소마다 3절과 같은 두 갈래 규칙. Step 5 에 태세·토템 자리 없음(:60) 명시 |
| fix 1 영향 지도의 「:40 확인만」 행 | 고쳐 적음(아래) | 그 판정은 틀렸다 — Dominos 바(:35·:37)를 빠뜨렸다. 앞 절 기록은 당시 기록이라 그대로 두고 여기서 바로잡는다: :40 = 함께 고침 |
| :35·:37 직업 표 (Dominos 바) | 확인만 | 내용 맞음(classes.md:25·:30) — 규칙은 :40 이 맡음 |
| :54–55 §3 두 갈래 | :55 함께 고침 (m2) | 예시 문구를 「Step 5 설계에도 그 겉보기 preset 에도 자리가 없으면」 으로 — :54 와 맞춤 |
| :61 색인 칸 (m1) | 함께 고침 | 「구역마다 프레임(등록 key → 전역 프레임 이름)」 칸 추가, 만들지 않은 그림도 한 줄씩 |
| :51 manifest·프레임 이름 행 | 확인만 | :61 에 칸이 생겨 이제 맞음 |
| :19 「대안 테마 없음」·:56 「설계 좌표 없음 — 못 만듦」 | 확인만 | 색인에 한 줄씩 적는 규칙은 :61 이 맡음 |
| :29 R109 인용 (m3) | 함께 고침 | R109 는 unit 기본판 결정이 아니다. Phase 23 임시 결정(`설치안내.md:28`)으로 바꾸고 「Codex 비교 결과에 따라 바뀔 수 있다」 유지 |
| :3·:65 R109 | 영향 없음 | 발주대로 그대로 둠 — R109 뜻(Codex 보류)과 맞음 |

### 명령과 판정
| 명령 | 판정 |
|---|---|
| python 치환 5건 (`s.count(a)==1` 단언) | 5건 모두 한 번씩 맞고 적용 — 65줄 그대로 |
| `grep -nE "<금지어 7개 — 발주문 5항목>" Collection/codex-briefs/appearance-24.md` | rc=1, 걸린 줄 0 — 통과 |
| `grep -n R109` | :3·:65 두 곳만 남음 |
| 백틱 경로 추출 → `test -e` (References·자리표시 제외) | 저장소 경로 15개 모두 OK. `layouts/*.lua` 는 `References/codex-appearance/2-layouts/` 아래 올릴 자리 |
| `sed -n 28p Collection/install/설치안내.md` | 「모음집 기본은 PitBull4 다」 — 인용 줄 맞음. 「임시」 라는 말은 이 줄에 없고 Phase 23 세부 계획 7행(「Codex comparison not yet in」)에서 온 것 |

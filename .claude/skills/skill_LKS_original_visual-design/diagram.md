# Diagram 어댑터 (에디토리얼 기술·제품 다이어그램)

코어 규칙(압축·통일·타이포 원리·의미 정확성)은 `core_principles.md`, 접근성(색·대비·이중 인코딩)은 `accessibility.md`, 검수 라운드·검증은 `verification.md` · `skill:skill_LKS_original_review-chunking` · 헌법 §3. 여기는 **Diagram 매체 수단** — self-contained HTML + inline SVG.

**html_css.md 와 분업**: 문서 내 반복 흐름도 = `html_css.md` 상속 CSS 컴포넌트(손좌표 SVG 비통일 회피). 독립 에디토리얼 다이어그램(아키텍처·시퀀스·39타입) = 이 어댑터 inline SVG — 통일은 **소스-우선 결정론 렌더 + 4px 그리드 토큰**이 보장(CSS 상속을 대신하는 통일 기전).

> **코어 §5 명시 예외**: `core_principles.md` §5 「각진 상자 + 직선 화살표 + 한 방향 흐름」이 원칙(코어 쪽에도 이 예외를 표시). 에디토리얼 다이어그램 한정으로 아래만 예외 — ① 커넥터 = **직교 둥근 elbow**(§4 규칙 1 · 모서리 r=8/6 · 대각선·자유 곡선은 그대로 금지) ② **형태·방향이 곧 뜻인 타입**(§7 카탈로그의 Venn·Pyramid·Radar·Loop·State·Sequence·Scatter·Line 등)은 그 형태(원·삼각·순환·왕복 메시지·좌표 평면)를 쓴다 ③ 그 밖의 상자-화살표 타입(Architecture·Flowchart·Data flow·Process 등)은 코어대로 사각형 노드 · 한 도식 한 방향.

---

## 1. 생성 접근 — 소스-우선 · 자기완결

| 규칙 |
|---|
| **소스-우선** — typed 데이터/명세(스키마 준수) → 결정론 렌더. 소스 = 타입드 데이터, 렌더 = 순수 함수(같은 소스 → 같은 그림 · 재현 가능 소스) |
| **자기완결** — self-contained HTML + inline SVG, 외부 의존 0(CDN·웹폰트·런타임 fetch 금지 · 폰트는 임베드/시스템 스택) |
| **통일 기전** — 손코딩 좌표 대신 4px 그리드 토큰 + 결정론 렌더가 viewBox·폰트·박스폭을 전 다이어그램에서 공유(§2) |
| **다크·라이트** — 크롬색(배경·글자·테두리·커넥터) = 테마 토큰 추종 · 데이터색 = hue 고정 명시값 라이트·다크 두 벌(분리 규칙 = `accessibility.md` §3·§6 ②) · **토큰 블록 출처** = 웹 페이지 안 도식은 페이지 블록을 그대로 상속 · 독립 도식은 `web_page.md` §5 기준 블록(표준 이름 · 라이트·OS 다크·강제 다크 세 블록)을 HTML 머리 `<style>` 에 넣고 데이터색도 같은 세 블록에 토큰으로 둔다 · SVG `fill`·`stroke` 는 `var(--…)` 로 토큰을 가리킨다(리터럴 색은 테마를 따라가지 못함) |
| **export** — PNG · SVG · 공유카드(1200×630) 결정론 산출(모션 다이어그램에 한해 WebM) |

## 2. 4px 그리드 — 값 스케일

전 좌표·치수·간격 **4 배수**. 스케일 밖 임의값 금지. 웹 페이지 안 도식은 간격(틀 안 여백·노드 사이)·반경을 페이지 토큰으로 둔다(우선 규칙 원본 = `web_page.md` §4 「페이지 안 도식」) — 아래 gap·radius 는 페이지 밖 단독 도식의 기본값.

| 축 | 값(4배수) |
|---|---|
| font | 8 / 12 / 16 / 20 / 24 / 28 / 32 / 40 |
| node 폭 | 80~320 정규 |
| gap | 20 / 24 / 32 / 40 / 48 |
| radius | 4 / 6 / 8 (상한 8 · rounded-2xl 과곡률 금지) |

## 3. 복잡도 예산 · remove-test

초과 시 **overview + detail 분할**(한 장에 욱여넣기 금지).

| 요소 | 상한 |
|---|---|
| node | ≤9 (faithful import 예외 = 24 + zoning) |
| arrow | ≤12 |
| accent(강조 토큰) | ≤2 요소 |
| sequence lifeline | ≤5 |
| swimlane lane | ≤5 |
| tree depth | ≤4 |
| nesting | ≤6 |
| gantt bar | ≤12 |
| scatter point | ≤30 |

**remove-test** — "다 넣었을 때가 아니라 뺄 게 없을 때 완성". 목표 밀도 4/10 · node 1개 = 아이디어 1개 · 추가보다 삭제 · node>9 = 십중 2다이어그램.

## 4. 6대 커넥터 규칙

하나라도 위반 = 자동 fail.

| # | 규칙 |
|---|---|
| 1 | **직교 둥근 elbow만** — 대각선 금지(자동 fail) · quarter-arc r=8, tight r=6 |
| 2 | **label–stroke 여백 6~10px** — mask 가 stroke 에 안 닿음 |
| 3 | **경로 겹침·평행 중첩 0** — 교차는 bridge/hop(≥12px offset) |
| 4 | **공유 엣지 attach 분리** — 한 노드 다중 연결은 각자 ≥12px 간격으로 부챗살 분리 |
| 5 | **비종단 통과 금지** — 불가피 시 dashed · arrowhead 금지 · label 은 보이는 끝에 |
| 6 | **label mask 규율** — 뒤 그려진 node 와 안 겹침(node 안에 완전 포함되는 mask=badge 는 OK) |

## 5. 타이포 — 역할별 서체 (§3 "서체 하나" 조건부 예외)

> **명시 예외**: `core_principles.md` §3 은 "서체 하나"가 원칙. 다이어그램은 **에디토리얼 다이어그램 한정 조건부 예외** — 역할별 서체를 허용한다(제목·노드명·기술 라벨의 층위를 서체로 구분). 이 예외는 **다이어그램에만** 적용 · 일반 시각물(개요 HTML·덱·UI)은 "서체 하나"를 유지한다.

| 역할 | 서체 | 스케일 |
|---|---|---|
| 제목 | serif | 24~40 |
| node 명 | sans | 12px / 600 |
| 기술 sublabel(포트·URL·타입) | mono | 9px |
| eyebrow | mono upper | 7~8px |
| arrow label | mono | 8px |

- **mono = 기술 내용만** — 사람이름·제목·서술에 mono 금지("만능 dev 폰트" 오용).
- CJK 는 12px+ (9px mono 는 라틴 기술 라벨 전용).

## 6. SVG 접근성 계약 (구조 a11y · 다이어그램 특화)

색·대비·이중 인코딩·크롬/데이터색 분리는 `accessibility.md`(되풀이 안 함). 여기는 **SVG 구조 계약**만.

| 계약 |
|---|
| `role="img"` + `aria-labelledby="<slug>-title <slug>-desc"` |
| `<title>` = `<svg>` 첫 자식(`<defs>` 앞) · ≤60자 |
| ID 다이어그램별 **prefix**(`<slug>-title`/`-desc` · bare ID 금지 → 한 페이지 다중 다이어그램 ID 충돌 회피) |
| `<desc>` = **내용 서술**(무엇을 말하는가) · 기하 서술("사각형 3개") 금지 |
| 장식 요소 = `aria-hidden="true"` |

```html
<svg role="img" aria-labelledby="auth-title auth-desc" viewBox="0 0 480 240">
  <title id="auth-title">인증 흐름</title>
  <desc id="auth-desc">클라이언트 요청이 게이트웨이 검증을 거쳐 토큰을 발급받는 3단계</desc>
  <!-- 도형: 4px 그리드 좌표 · 순수 장식은 aria-hidden -->
</svg>
```

## 7. semantic ↔ type 2단계 선택

레이아웃은 **먼저 의미, 그다음 형태**. 렌더 전 1줄 계획 선언.

| 단계 | 행동 |
|---|---|
| 1 · 의미 | 행동 서술(fan-in · stage · governance · lifecycle …) → **semantic pattern 택1** |
| 2 · 형태 | semantic pattern → 근접 **visual type 택1**(type = 레이아웃 grammar) |
| 예외 | 대응 패턴 없으면 type 직접 선택 |
| 게이트 | 렌더 전 "type=X, 근거=Y" 1줄 선언 |

**visual type 카탈로그(39)**: Architecture · Flowchart · Sequence · State · ER · Timeline · Swimlane · Quadrant · Radar · Loop · Nested · Tree · Org · Layer stack · Venn · Pyramid · Treemap · Bar · Line · Gantt · Scatter · Process · Medallion · Data flow · Sankey · Fishbone · Wardley · Kanban · User journey · Deployment · Dependency graph · UML class · Story map · DB schema 외.

## 8. pre-output 체크리스트 (생성 직전 self-gate)

검수 **라운드**가 아니라 전달 전 taste gate(아래 표). 다이어그램을 검수 라운드로 볼 때 확인할 것(커넥터 기하 · 복잡도 · 범례 · a11y · 의미 정확성 — 아래 표와 별개)은 P4 시각 프리셋 라운드에서 함께 보고, 라운드 운용·청크 전환·재검증은 `verification.md` · `skill:skill_LKS_original_review-chunking` · 헌법 §3.

| 항목 | 확인 |
|---|---|
| 커넥터 기하 | 6대 규칙 전건 통과 |
| 타이포 | 역할별 서체 정합 · mono 남용 0 |
| 신호 | accent ≤2 · remove-test 통과(밀도 4/10) |
| SVG | title 첫 자식 · ID prefix · arrow before box(렌더 순서) · legend 하단 스트립 |
| 타입 적합 | 렌더 전 1줄 계획과 결과 일치 |
| 색 | 웹 매체 3축 색 게이트(대비·채도·유채 면적 — 라이트·다크 각각 · `accessibility.md` §2-2) = `<설치경로>/tools/check_color_tokens.py <도식.html>`(`<설치경로>` = SKILL.md 「도구 경로」 · 사용법·판정 0 = 「판정 안 됨」 = `web_page.md` §7) — §1 토큰 블록이 있어야 판정된다(루트 토큰이 없으면 도구가 입력 오류 · 종료코드 2 로 멈춤 = 미통과 · 리터럴 색으로만 칠한 도식은 §1 대로 토큰으로 바꾼 뒤 돌린다) · SVG 가 실제로 쓰는 전경/배경 조합은 `--pair` 로 빠짐없이 추가(같은 절 「대비 쌍 열거」) · 그래도 남은 리터럴 `fill`·`stroke` 는 도구가 판정하지 않아 사람 확인(같은 절 「사용처 검사」) |

## 9. 안티패턴

| 안티패턴 | 증상 | 교정 |
|---|---|---|
| 그림자·글로우 | 다크+cyan/purple glow · 입체 장식 | flat · 그림자 0 |
| 동일 박스 반복 | 정보 없는 중복 노드 | 제거(remove-test) |
| legend 내부 부유 | 본체와 겹쳐 판독 방해 | 범례는 다이어그램 **밖**(하단 스트립) |
| mask 없는 arrow label | 라벨이 stroke 위 겹쳐 판독 불가 | label mask(여백 6~10px) |
| mono 남용 | 사람이름·제목까지 mono | mono = 기술 내용만 |
| vertical text | 세로 텍스트 판독 부하 | 가로 배치 |
| rounded-2xl 과곡률 | 모서리 과다 라운드 | radius 상한 8(단독 도식 · 웹 페이지 안 = 페이지 반경 토큰 — §2 머리) |
| 대각선 커넥터 | 6대 위반(자동 fail) | 직교 둥근 elbow |
| Mermaid 자동 레이아웃 재현 | 기계 배치 = 의미 안 맞음 | 의도 배치(1줄 계획 선언) |

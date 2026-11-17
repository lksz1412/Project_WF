---
version: "1.4.8"
updated: "2026-11-11"
name: skill_LKS_original_visual-design
description: "내용을 핵심으로 압축해 시각적으로 배치(산문·문장 나열 금지)하는 시각 설계·검수가 필요할 때 쓴다. 웹 페이지·claude.ai 아티팩트·HTML/CSS 개요·플로우차트, 다이어그램(아키텍처·시퀀스·39타입), 슬라이드 덱, PyQt/데스크톱 UI, 코드 문서 구조(구획·헤더·마커) 공통. 통일성·단일소스 토큰·매체 간 토큰(색 포함) 이식 금지·타이포 위계(소수 이산 단계·고정 크기·서체 하나)·웹 페이지 토큰(뉴트럴 램프+강조 1·채도 예산·다크 전 단계 재배정·한글 타이포 KRDS)·접근성(색+도형 이중 인코딩·WCAG 2.2 대비·수치·크롬색 테마 추종 vs 데이터색 명시 분리)·근거 하나+핵심 직접 지목·다이어그램 의미 정확성(각진 상자·직선 화살표)·장식 억제·레이아웃 의도 축(논증형 리듬 vs 카탈로그·시리즈형 균일)·검증(정적+렌더+육안, 구조 변경은 관점 전환 10라운드)을 다룬다. 아티팩트도 외부 스킬에는 매체 수단만 맡기고 이 규범을 그대로 적용. 특화 매체(PPTX·LaTeX·코드 구조·PyQt)는 전용 어댑터로 분기. 트리거: 'UI 설계', '화면 배치', '웹 페이지 디자인', '아티팩트 시각 설계', '다크 모드', '한글 타이포', '플로우차트', '개요 HTML', '덱 시각 규칙', '접근성 색 대비', '색맹 도형 인코딩', '테마 색 분리', 'PyQt UI 여백', '다이어그램', '아키텍처 다이어그램', '코드 구조·독스트링·구획 지도'."
metadata:
  type: method
---

# 시각 설계 (매체 무관 코어 + 매체 어댑터)

## ★ 제1원칙 (최상단 고정 · 전 매체 공통)

**내용을 핵심으로 압축 → 시각적으로 배치해 한눈에 이해. 산문·문장 나열 금지.**

| 항목 | 규칙(명사구) |
|---|---|
| 목표 | "문장 읽히기" 아님 → "핵심 압축 후 배치로 이해" |
| 배치 장치 | action title·카드·박스·플로우차트 = 문장 대신 공간 배치 |
| 콘텐츠 = 시각 | 콘텐츠 배치가 곧 시각 배치(하나, 별도 수사층 아님) |
| 하한 경계 | 압축 = 어미 처리(명사형 종결), 내용 삭감 아님(과압축=오답) |

## 적용 조건

화면·문서·UI·소스를 **압축→시각 배치로 설계·검수**할 때 — 웹 페이지(claude.ai Artifact 포함)·HTML 개요·플로우차트, 다이어그램, 슬라이드 덱, PyQt/데스크톱 UI, 코드 문서 구조, 접근성 색·대비 검수. 경량 조회·설명은 대상 아님.

## 매체 라우팅표

어댑터 7종 — 웹 페이지·HTML 도식·Diagram(+코어·접근성·검수)과 특화 저작 어댑터 4종 LaTeX·PPTX·Code·PyQt. 설치 구성이 하나라 일곱 모두 깔린다(행 끝 `<!--profile:inhouse-->`·`<!--ih-->` 표지는 남아 있으나 거르지 않는다).

| 매체 | 어댑터 | 성격 |
|---|---|---|
| 웹 페이지 (HTML 개요·보고 페이지·claude.ai Artifact) | `web_page.md` | 페이지 토큰(뉴트럴 램프+강조 1·채도 예산·다크·한글 타이포·간격) · 오프라인 자기완결(CDN 금지 · Artifact 는 그 환경 규칙) · Artifact 도 적용 — Anthropic `artifact-design` 에는 **매체 수단만** 위임 |
| HTML 도식 (플로우차트·페이지 속 흐름도) | `html_css.md` | 상속 CSS 컴포넌트 · 페이지 토큰·오프라인 규칙 상속 |
| Diagram (아키텍처·시퀀스·39타입) | `diagram.md` | self-contained HTML+inline SVG · 소스-우선·4px 그리드 |
| PPTX (슬라이드 덱·`.pptx`) | `pptx.md` | pptxgenjs·source-first·3-게이트 |<!--profile:inhouse-->
| LaTeX (수식·논문·교과서급) | `latex.md` | 수식 rigor·식번호·build log |<!--profile:inhouse-->
| Code (소스 파일 시각 구조) | `code.md` | 구획·박스헤더·상태마커·4단계 번호 · 주석/명명은 원본 위임 |<!--profile:inhouse-->
| PyQt / 데스크톱 UI | `pyqt.md` | palette 추종·GroupBox 여백·시트 균일 |<!--profile:inhouse-->

## 코어 ↔ 어댑터 로드 지도 (progressive disclosure)

```
SKILL.md(얇은 라우터)
  → core_principles.md (항상 · 제1원칙·압축·구조 배치 — 매체 무관)
  → [시각 매체] +accessibility.md (색·대비·채도 예산·이중 인코딩)   ← 비시각(Code·LaTeX)은 미적재
  → [매체 분기] 위 라우팅표의 해당 어댑터 1개   ← 웹 페이지 안 도식 = web_page.md 먼저 + 도식 유형에 맞는 어댑터 하나
  → [검수] verification.md → 매체 도구 + skill:skill_LKS_original_review-chunking
```

| 로드 시점 | 파일 |
|---|---|
| 작업 진입(항상 · 매체 무관) | `core_principles.md` |
| 시각 매체 진입(웹 페이지·HTML 도식·Diagram·PPTX·PyQt) | `accessibility.md` |
| 매체 분기 | 위 라우팅표의 해당 어댑터 1개 · 웹 페이지에 도식이 들면 `web_page.md`(페이지 토큰 먼저) + 도식 유형에 맞는 어댑터 하나(흐름도·플로우차트 = `html_css.md` · 아키텍처·시퀀스 등 SVG 다이어그램 = `diagram.md`) · 웹 페이지 밖 도식(`html_css.md`·`diagram.md` 단독)도 토큰 블록·색 게이트 사용법은 `web_page.md` §5·§7 을 그 절만 읽는다 |
| 검수 단계 | `verification.md`(철학·라우팅) → 매체 도구 + `skill:skill_LKS_original_review-chunking` |

조건 밖 어댑터는 읽지 않는다. **비시각 매체(Code·LaTeX)는 `accessibility.md`를 적재하지 않는다**(색·대비 축 없음).

## 도구 경로 (`<설치경로>` — 이 스킬 파일들의 명령이 쓰는 자리표시자 · 원본 = 여기)

| 쓰는 곳 | `<설치경로>` 값 |
|---|---|
| 설치본 | 홈 폴더의 `.claude` 를 펼친 절대 경로(예 `/home/<사용자>/.claude` · `C:\Users\<사용자>\.claude`) — `~` 는 쓰지 않음(Node `require` 는 `~` 를 풀지 않고, 명령 줄의 `~` 는 셸에 따라 풀리지 않는다) |
| 패키지 저장소 세션 | `Settings_for_Claude` 폴더의 절대 경로 |

도구 = `<설치경로>/tools/<파일>` — 작업 폴더와 무관하게 이 절대 경로로 부른다.

## 분기해도 코어는 빠지지 않는다 (외부 스킬 위임 경계)

| 외부 스킬에 위임 — 매체 수단만 | 이 스킬이 항상 적용 |
|---|---|
| claude.ai Artifact 의 런타임·게시 절차·외부 리소스 허용 범위(Anthropic `artifact-design` 등) | 코어(`core_principles.md`) · 접근성(`accessibility.md`) · 웹 페이지 토큰(`web_page.md` — 색 램프·채도 예산·다크·한글 타이포·간격) |

- 외부 스킬은 이 스킬의 색·한글·접근성 규범을 모름 → 그 스킬의 기본 팔레트·타이포 값을 그대로 쓰지 않는다.
- 충돌 시 이 스킬 우선(헌법 지침 우선순위 — 사용자 저작 지침 > 타 플러그인).

## 자기 적용 규범

이 SKILL·references 자신도 제1원칙을 적용 — 규칙은 **명사구 1줄 + 표·매트릭스**로. 설명 문단 나열 금지(산문이면 자기모순).

## 위임 규율 (중복 서술 금지 — 포인터로 위임)

| 주제 | 위임 대상 |
|---|---|
| 검수 라운드·관점·청크·재검증 | 헌법 §3 · `skill:skill_LKS_original_review-chunking` |
| 세션 분업·서브 스폰 | 헌법 §1 · `skill:skill_LKS_original_multi-session-orchestration` |
| 계획·실행·기록 양식 | `skill:skill_LKS_original_plan-execution` |
| 원본 불가침·git-safety | `memory:feedback_workspace_git_safety` · `skill:skill_LKS_original_project-scaffold` |
| 전문 정독 규율 | `memory:feedback_full_file_read_required` |
| 문서 파일 읽기·만들기·고치기·변환(파일 조작) | `skill:skill_LKS_custom_document` |

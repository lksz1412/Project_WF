<!--ih-->
# LaTeX 어댑터 (수식·논문·교과서급 문서 저작·검수)

> **이 파일 = `skill:skill_LKS_original_visual-design` 의 LaTeX 어댑터.** 압축→시각 배치·통일·검수 코어는 visual-design 코어(`core_principles.md`·`verification.md`)에 있고, 여기는 그 코어를 LaTeX(수식 rigor·식 번호·build log)로 구현한다. 비시각 매체라 색·접근성(`accessibility.md`)은 미적재.

# LaTeX / Academic Authoring

LaTeX 문서(논문 챕터·수식 전개)를 작성·검수할 때의 절차. 논문급 논리 깊이와 교과서급 형식을 함께 목표로 하며, 수식 완결성·번호·orphan 없이 그룹화·빌드 검증까지 겸해 규율한다. 상위 작업 방법론은 `skill:skill_LKS_original_multi-session-orchestration`이다. 검수는 `skill:skill_LKS_original_review-chunking`, 계획·실행은 `skill:skill_LKS_original_plan-execution`을 사용한다.

## 적용 조건

LaTeX 문서, 논문 챕터, 수식 전개, paper/textbook-style chapter를 작성하거나 검수할 때 적용한다.

## 핵심 원칙

### 품질 목표

- 논리 깊이 = 리뷰 논문급: 가정·유도·근사·한계를 명시하고, 결과를 재유도·극한·반례로 도전할 수 있는 수준까지.
- 형식 = 교과서급: 새 개념·식·구조가 전제 없이 등장하면 안 된다. 전제부터 단계적으로 전개하고, 비유에만 의존하지 않는다. 학부생이 앞 내용만으로 따라갈 수 있게 쓴다.
- 완전 무결 직전("턱밑")까지 다듬는다.
- 표기: 한글 prose + 영어 학술 원어(첫 출현 시 병기). 예: "경계 조건(boundary condition)".

## 실행 방법

### 단위 구성 루프 (수식·문단에 적용)

단위 구성 루프의 일반 절차와 금지는 **규범 원본 `memory:feedback_unit_loop`**(절차·양식은 `skill:skill_LKS_original_plan-execution`)를 따른다. 여기서는 LaTeX 대응만 정한다 — 자연 작업 단위는 **절 / 수식 블록 / 문단** 하나이고, "앞 단위·기반 정합" 은 **선행 절의 기존 식·정의·기호와 대조**를 뜻한다.

### 수식 완결성 (orphan 0)

완결성 규범(`memory:feedback_unit_loop`)을 식에 적용할 때의 판정 기준은 다음 둘이다:

- (a) 앞이 동기 부여: 그 식을 도입하는 문장·선행 식이 앞에 있다.
- (b) 뒤가 실제 사용: 그 식이 downstream에서 인용·대입·활용된다.

앞 문맥과 단절된 식은 "유용해 보여도 쓸 수 없는" 댕글링 orphan 이다.

### 통합 문서 규율

통합 산출물 규율(`memory:feedback_unit_loop`)을 LaTeX 에 적용하면: 하나의 문서·책으로 묶이는 절들 사이에는 인계·recap·전달 비계를 두지 않고, 필요한 것은 쓰는 자리에서 **식 번호·정의 inline 참조**로 가리킨다. **논문식 결론 절은 교과서 챕터에 두지 않는다.**

### 수식 검수 — 관점을 수식에 적용하는 법

수식은 정확성만으로 부족하다. LaTeX 문서는 P5(일반 문서) 프리셋으로 검증하고, P5 에 칸이 없는 것(usable·수식 검산)은 그 프로젝트의 가변 5 관점으로 올린다 — 수식에서는 아래처럼 본다:

- **follow(G-follow) — P5 고정 ③ 연결(비약 없음)·④ 완결성(빠진 단계)을 수식에 적용** — 학부생이 앞 식 + 본문만으로 이 식을 따라갈 수 있는가. 중간 단계가 생략돼 도약이 있으면 단계를 채운다.
- **usable(G-usable) — 가변 5 관점** — 절 끝에서 실데이터에 대입 가능한 닫힌식(closed form)이 있는가. "맞지만 못 쓰는" 식을 통과시키지 않는다.
- **수식 검산(가변 5 관점)** — 다음 네 확인 항목을 한 라운드 안에서 함께 본다(항목마다 따로 다시 읽지 않는다): **부호(sign)** — 항의 부호가 물리·수학적으로 맞는가 · **단위·차원(unit/dimension)** — 좌우변 차원이 일치하는가 · **독립 변수(independent variable)** — 무엇의 함수인지 명시됐는가, 적분·미분 변수가 일관되는가 · **경계 조건(boundary condition)** — 극한·경계에서 알려진 값으로 환원되는가.

정확성만 보면 "맞지만 못 따라가고 못 쓰는" 결함을 통과시킨다 → follow 는 고정 ③·④ 라운드에서 반드시 보고, usable·수식 검산은 수식 문서의 핵심 위험이라 마스터 플랜 Test Plan 「검증 관점」 표의 가변 5 에 넣는다(라운드를 더하지 않는다 · 프리셋 표 원본 = `skill:skill_LKS_original_review-chunking`). 관점 하나·청크 창을 라운드마다 바꾸는 검증 라운드는 `skill:skill_LKS_original_review-chunking`를 따른다.

정성 판단이 불가피한 영역(수식 의미·물리 가정)은 판단을 하지 말라는 게 아니라 판단을 구성 요소로 분해한다:

- "수식 의미가 맞아 보인다" → "수식의 부호·단위·독립 변수·경계 조건을 명시했고 4-tier(확정/근거 미발견/추정/미검증)로 분류했다".
- "참조 문헌 적용이 적절해 보인다" → "참조 문헌의 각 방법론·본 문제 변수 매핑·그대로 가져오면 안 되는 물리 가정 차이를 별도 sub-section으로 기록했다".

### 식 번호 관리

- 식 번호는 인용의 절대 좌표다. `\label`/`\ref`(또는 `\eqref`)로 관리하고, 본문 인용은 하드코딩된 번호가 아니라 참조 매크로를 쓴다.
- 절을 추가·재배치해도 번호가 자동 갱신되도록 하고, 빌드 후 `??`(미해결 참조)가 남지 않는지 확인한다.
- 인용된 식은 반드시 정의돼 있어야 하고(dangling `\ref` 0), 정의된 식은 downstream에서 쓰여야 한다(orphan 0).

## 검증

정성 판단("적절해 보임")이 아니라 명령 + 증거 + 범위로 검증 가능한 조건만 gate로 삼는다:

- **LaTeX 빌드 실행**: `pdflatex`(또는 `latexmk`/`xelatex` 등 프로젝트 설정)를 실행하고 성공/실패 + 컴파일 로그 일부를 기록한다. 참조 해결을 위해 필요하면 2회 이상 컴파일한다.
- **로그 정독**: 로그에서 Error, Overfull/Underfull, 미해결 `\ref(??)`, 미정의 제어열, 누락된 파일·그림을 확인한다. "빌드가 통과됐다"만으로 PASS 처리하지 않는다.
- **산출 PDF 보호 속성**: 기존 PDF 를 수정·재빌드로 덮어쓸 때는 빌드 전에 쓰기 보호(ReadOnly) 속성을 해제하고, LaTeX 빌드·참조 해결 재빌드·렌더·로그 QA 를 모두 마친 최종 산출물에만 다시 적용한다. 적용 후 속성값을 검증해 기록한다(구체 명령·경로는 실행 환경에 맞춘다). 여기서 ReadOnly 는 파일시스템 속성(예: Windows `FILE_ATTRIBUTE_READONLY`)이지 PDF 내부 권한 암호화가 아니다 — qpdf `--encrypt` 나 pypdf `writer.encrypt(...)` 를 ReadOnly 대용으로 쓰지 않는다.
- **읽은 범위 gate**: 지정 `.tex` 파일을 1행부터 끝행까지 읽었고 읽은 범위를 result 문건 Read Coverage에 기록했다.
- **기준식 대조 gate**: 앞 챕터에서 뒤 챕터로 전달되는 기준식 목록을 원문 식 번호와 함께 대조했다.
- **문헌 대조 gate**: 참조 문헌의 서지 정보 + 본문 내 사용 위치(page·paragraph)를 확인했다.
- **의존성 gate**: self-consistent 변수 의존성을 dependency graph로 작성했고 순환 위치를 표시했다.

각 gate는 result 문건 Validation에 PASS/FAIL + 근거(명령 출력 인용 / 파일 라인 / 증거 위치)와 함께 기록한다. gate 미통과 시 다음 단계로 진입하지 않는다.

gate 설계 원칙(확인 가능한 조건)은 `skill:skill_LKS_original_plan-execution` §3a를 따른다.

### 계획서 연계

LaTeX·수식·논문 전개를 실제로 검토·재구성하는 작업은 계획서를 먼저 저장하고 시작한다. `skill:skill_LKS_original_plan-execution` 「① 계획 착수 시」를 따른다. 계획서의 관련 섹션:

- **Implementation Interfaces**: 수식·표 양식·결과 문건 양식(실행자가 그대로 따를 인터페이스).
- **Test Plan**: LaTeX 빌드·수식 검수·문헌 대조·읽은 범위 대조·논리 의존성 검수.

## 예외·금지

사용자 원본·다른 산출물을 덮어쓰지 않는다. 식별·비교가 필요하면 원본 사본(예: `<name>_review.tex`)을 만들어 그 위에서만 작업한다(결과 문건 보호 상세는 `skill:skill_LKS_original_plan-execution` §4).

## 관련 문건

- `skill:skill_LKS_original_plan-execution` — 계획 저작(「① 계획 착수 시」)·단계 실행·기록(「② GO 직후」)
- `skill:skill_LKS_original_review-chunking` — 검증 라운드·재검증·관점 10개·청크 분할
- `memory:feedback_unit_loop` — 단위 구성 루프·완결성·품질 목표의 규범 원본
- `memory:feedback_full_file_read_required` — 전문 정독 의무
<!--/ih-->

# MEMORY 색인 — 상시 지침 메모리 (feedback_)

지금 하려는 작업이 헌법 지침 줄의 적용 조건에 해당하면, 그 줄의 `feedback_<주제>` 파일을 Read 해 전문을 요약 없이 그 작업에 적용한다(해당 여부가 애매하면 읽는다 · 컴팩션 뒤에는 앞서 읽었어도 다시 읽는다 — 요약·기억은 읽은 것이 아니다). 조건에 해당하지 않는 줄의 memory 는 읽지 않는다 — 매 턴 모든 포인터를 읽는 것이 아니다. 아래 각 줄은 이름과 그 memory 가 다루는 주제 한 구뿐이고 규칙은 본문(매 응답에 걸리는 요지는 헌법 줄)에 있다. 특정 task type 의 절차는 말미 「방법론·주요 스킬」 표에서 찾는다.

## 읽기·검증

- **`feedback_full_file_read_required`** — 문건 전문 정독 — 정독 대상·예외(DB성 자료)·A/B 비교 · 판단 근거로 읽은 파일·줄 범위 기록
- **`feedback_post_edit_runtime_verification`** — 코드를 고친 뒤 확인 — 실제 구동 먼저 · 의도한 동작·호출 체인·남아 있는 가드

## 흐름·소통·결정

- **`feedback_flow_interruption`** — 흐름 보호 — 팝업·확인 창 도구 · 승인 창 부르는 셸 명령 · 정지와 물음 · 사용자 추가 지시 · 결정 대기
- **`feedback_communication_style`** — 소통 스타일 — 메타 발언·지침 이름 · 두문자어·용어 · 금지 어휘 · 화면 글(그 턴의 마지막 글 — 사용자 메시지 답 · 진행 표 · Phase 정리 보고 · 최종 작업 보고 · 기다리는 턴 한 줄)
- **`feedback_decision_request_clarity`** — 사용자에게 결정·승인·피드백을 요청하는 글의 모양 — 라벨·내용·근거·위치
- **`feedback_confirmed_items_policy`** — 확정된 사안 다루기 · 보고의 4-tier 분류(확정 / 근거 미발견 / 추정 / 미검증)
- **`feedback_user_decision_no_requery`** — 사용자가 이미 정한 사항의 처리 — 재질의 · 「일 다 끝내놔」 범위
- **`feedback_execute_explicit_choice_not_judgment`** — 사용자가 고른 방식(지침·memory 에 적힌 절차 포함)의 실행 · 비용 tradeoff
- **`feedback_planning_vs_execution`** — 기획·계획 검토 단계와 실행(명시 GO) 단계의 구분
- **`feedback_completion_scope`** — 「완료 시점에 X」 류 후속 행동의 범위 · 큰 비용·외부 호출·새 권한·주관 검토의 경계

## 코드 작업

- **`feedback_code_ownership_scope`** — 사용자 코드·문서의 명명·컨벤션·수정 범위 · 부분 수정 · 새 이름 짓기
- **`feedback_code_comment_discipline`** — 코드 주석에 적을 것과 적지 않을 것(버전 이력·Phase·검수 ID) · 관리 대장

## 작업 방법론(세션 분업·단위 루프·청크 검수)

- **`feedback_session_division`** — 세션 분업 — 1 유닛{master + 같은 작업 A ↔ 같은 검수 B} · 병렬 게이트 · 요약 판단 · 스폰 5항목 고지 · commit
- **`feedback_unit_loop`** — 자연 작업 단위별 단위 루프 · 통째 배치 · 완결성(orphan) · 품질 목표
- **`feedback_change_impact_analysis`** — 고치기 전 영향 지도(연결된 곳 · 곳마다 영향도 · 연계 찾기 필수 칸) · 한 번에 고침 · 지도 기준 재확인
- **`feedback_chunked_review`** — 본작업 뒤 검증 — 검수 구분(갈래 넷 — ③ 구조 변경 10라운드 · ①·②·④ 한 번 검수·실행 게이트 · 범위 = 바뀐 단위 + 지도 단위 · 코드 실행 먼저) · 관점 10개 · 결함 등급 · 같은 작업 A 고침 · 같은 검수 B 재검증 · 진동
- **`feedback_review_chunk_discipline`** — 검수 창 규율 — 창 크기(~500줄) · 대형 파일 통째 위임 · 자기보고 coverage
- **`feedback_workspace_git_safety`** — 작업물 보호(git-safety) — git 안 수정·삭제 · 복원 지점 · git 밖 파일 · 침범 뒤 복원

## 세션 진입·컴팩션 복구

- **`feedback_session_entry_reading`** — 세션 진입 정독 — 작업지시·대상·명시 문건 · 인계 chain · 프로젝트-local CLAUDE.md
- **`feedback_handover`** — 인계 — 세션 전환·중단·소진 임박 때 인계 5항목 · 저장 위치 · 인계 chain
- **`feedback_compaction_recovery`** — 컴팩션·재개 직후 복구 — 규칙 파일 재독 · 새 편집 전 6-check · 복구 읽기 순서 · 읽은 범위 기록

---

## 방법론·주요 스킬 (task type 진입 시 로드)

로드 시점 열이 「필수」인 스킬은 해당 작업에 들어갈 때 반드시 로드한다(헌법 「방법론 필수」·「계획·실행」·「지침 운용체계」 줄과 동일 규범). 나머지는 지금 하려는 작업이 해당 줄의 적용 조건에 해당하면 로드한다 — 조건에 해당하지 않으면 읽지 않는다.

| task type | 스킬 | 로드 시점·목적 |
|---|---|---|
| 계획 저작·실행·기록 | `skill_LKS_original_plan-execution` | 필수 — 「① 계획 착수 시」 절: 11-section 계획서·cumulative step·작성 전 확인 / 「② GO 직후」 절: 5-stage loop·스텝 이력·Result/Ledger·재독 강제·검증 gate |
| 분업 운용·서브 스폰 | `skill_LKS_original_multi-session-orchestration` | 필수 — 「① 유닛 설계」 절: 유닛{master+sub} 역할·흐름·검수 방향 / 「② 첫 스폰 직전」 절: 도구·모델·effort 배정·spawn 5항목 고지·sub prompt 머리말 |
| 반복 검수 | `skill_LKS_original_review-chunking` | 필수 — 검증 절차(관점 10 = 고정 5 프리셋 + 가변 5)·검수 sub 프롬프트·프리셋 표 |
| 이미지 판독 | `skill_LKS_original_ocr-image-extraction` | 이미지에서 텍스트·코드 전사·검증(판독+OCR 엔진 교차검증) |
| 시각 설계(화면·문서·UI·소스) | `skill_LKS_original_visual-design` | 압축→시각 배치·통일성·타이포·접근성·검수 (HTML·다이어그램 · LaTeX·PPTX·Code·PyQt 는 전용 어댑터) |
| LaTeX 저작 | `skill_LKS_original_visual-design` | LaTeX 어댑터(`latex.md`) — 수식·논문·교과서급 저작·검증 | <!--profile:inhouse-->
| Deck 저작(PPTX 어댑터) | `skill_LKS_original_visual-design` | PPTX 어댑터(`pptx.md`) — source-first deck 저작·3-게이트 | <!--profile:inhouse-->
| 문서 파일 읽기·만들기·고치기 | `skill_LKS_custom_document` | docx·pdf·pptx·xlsx 읽기·추출·만들기·고치기·변환(형식별 하위 문서 · 기존 파일 읽기 = decrypt 하위 문서) |
| 자료 수집·검토 | `skill_LKS_original_source-research` | 논문·학술 조사 / 유튜브·커뮤니티 정보 수집·교차검토 / 인용·링크 실재 검증이 필요한 본격 자료 작업일 때(단발 즉답은 헌법 「검색」 줄) — 모드 택1·공개 API 직접·인용 게이트·자막 우선 추출·4-tier |
| 데이터 파이프라인 | `skill_LKS_original_data-pipeline` | 확보한 데이터를 파싱·검증·처리·산출하는 파이프라인 작업일 때 — 정규화 선검사·provenance·재현성·정량 신뢰도 |
| 보안망 Windows 도구 | `skill_LKS_original_secured-windows-tooling` | 통제 Windows 환경(기업·보안 network)일 때 — PowerShell download·API·winget 금지·Windows `python` 명령 |
| 로컬 웹 서비스 | `skill_JJH_original_local_web_service` | 내부망 개인 PC 를 서버 삼아 Python 웹앱·API 를 배포·운용할 때 — host·`__file__`·방화벽 3함정 · 부팅 기동·/health 감시 |
| 지침·패키지 저작·개정 | `skill_LKS_original_instruction-architecture` | 필수 — 지침 배치·기전·§14 개정 SOP(헌법 「지침 운용체계」 줄과 동일 규범) |
| 프로젝트 구조·git-safety 절차 | `skill_LKS_original_project-scaffold` | 폴더 스캐폴드·구조 맵·git-safety how-to |

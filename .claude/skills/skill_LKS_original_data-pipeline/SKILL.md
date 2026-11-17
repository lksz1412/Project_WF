---
version: "1.4.0"
updated: "2026-09-27"
name: skill_LKS_original_data-pipeline
description: >
  실험·측정·수집으로 확보한 데이터를 파싱·처리·산출하는 파이프라인 작업 시 사용한다.
  골격 = Input → Validation(정규화 선검사) → Processing → Output + Provenance.
  데이터 규약 불일치(단위·인덱스 base·키 표기)를 처리 진입 전에 차단하고, 산출물에
  출처·근거 위치(line-pinned)를 고정하며, 파라미터·의존성 pin·오프라인 재실행으로
  재현성을 확보하고, 품질을 수치 지표로 부착한다.
  비적용 = 단발 사실 조회·인용 실재 검증은 skill:skill_LKS_original_source-research.
  트리거: "데이터 파이프라인", "데이터 취급", "provenance", "재현성",
  "정규화", "데이터 검증", "재현 가능한 파이프라인", "line-pinned 근거".
metadata:
  type: method
---

# Data Pipeline (데이터 취급·재현성·provenance)

확보된 데이터를 **파싱 → 검증 → 처리 → 산출**의 단방향 파이프라인으로 다루고, 산출물에 **재현성·출처 고정·품질 수치화**를 기본값으로 부착하는 방법론. 상류 수집·인용 실재 검증은 `skill:skill_LKS_original_source-research` 몫이고, 이 스킬은 **이미 확보된 데이터의 취급·산출**이다.

## 적용 조건

| 구분 | 대상 |
|---|---|
| 적용 | 실험·측정·수집으로 확보한 데이터를 파싱·검증·처리해 산출물로 만드는 파이프라인 작업 |
| 비적용 | 단발 사실 조회·경량 질의 → 헌법 「검색」 · 인용/링크 실재 검증(상류) → `skill:skill_LKS_original_source-research` |

## 파이프라인 골격 (5단계 · 각 1줄 규율)

| 단계 | 1줄 규율 |
|---|---|
| **Input** | 포맷별 파서로 원자료 적재 · 원본 무변형(읽기 전용 사본) · source 식별자를 적재 시점에 부착 |
| **Validation (정규화 선검사)** | 데이터 규약(단위·인덱스 base·키 표기)을 **처리 진입 전** 검사·차단 — 오염 원천 봉쇄 |
| **Processing** | 결정론 변환 · 파라미터 명시 · 각 변환의 입력↔출력 계약 유지 |
| **Output** | 산출물 + 품질 지표(수치) + provenance 동반 · 규약(컬럼명·enum·인코딩) 보존 |
| **Provenance** | 주장↔출처 바인딩 · source URI·취득 계약·근거 위치(line-pinned)를 산출물에 고정 |

## 정규화 선검사 (처리 진입 전 · 오염 방지)

규약 불일치는 **처리 후 정정이 아니라 진입 전 차단**이 원칙이다 — 사후 정정 대상은 이미 오염된 산출물이다. 예시는 도메인 무관 일반형:

| 검사 축 | 불일치 예(도메인 무관) | 조치 |
|---|---|---|
| 단위 | 같은 양을 다른 스케일·접두어로 표기 | 표준 단위로 정규화, 불가하면 차단 |
| 인덱스 base | 0-based ↔ 1-based 혼용 | 하나로 통일 · off-by-one 원천 차단 |
| 키·식별자 표기 | 같은 개체의 키가 대소문자·구분자·공백 차이로 갈림 | 정준(canonical) 키로 정규화 |
| 결측·형·범위 | 결측값 · 형 불일치 · 범위 이탈 | 명시 규칙으로 거르고 사유를 로그에 남김 |

사용자 데이터 규약(정수 enum · 컬럼명 · 인코딩)의 **보존 권위**는 `memory:feedback_code_ownership_scope` — 정규화는 규약을 통일하는 것이지 사용자 규약을 임의 재설계하는 것이 아니다.

## Provenance (산출물 ↔ 출처 바인딩)

| 부착 대상 | 내용 |
|---|---|
| source | source URI · 취득 계약(쿼리·시점·버전) |
| 근거 위치 | line-pinned — 주장이 나온 원자료의 행/오프셋을 고정 |
| 바인딩 | 각 확정 주장을 그 근거에 1:1 연결 · 근거 없는 주장은 강등 |

여기서 provenance 는 **확보된 데이터 내부의 근거 위치 고정**이다. 외부 인용/링크가 실제로 resolve 되는지의 실재 검증은 `skill:skill_LKS_original_source-research` 인용 게이트 소관 — 축이 다르다(경계 참조).

## 재현성 (같은 입력 → 같은 산출)

| 축 | 규율 |
|---|---|
| 파라미터 | 전 파라미터 명시(암묵 기본값 금지) · 파라미터 세트를 산출물에 기록 |
| 의존성 | 버전 pin(범위 아님) · 실행 환경 명시 |
| 예제 | 오프라인 재실행 가능한 최소 예제 동반 · 네트워크·비공개 자원 비의존 |
| 결정론 | 랜덤 seed 고정 · 순서 의존 제거 · 부동소수 재현 유의 |

## 정량 신뢰도 1급 (추상 주장 대신 측정치)

품질은 형용사가 아니라 **수치 지표로 산출물에 부착**한다(1급 시민). 미측정이면 "미측정"이라 명시하고 추측으로 채우지 않는다.

| 형용사 주장 대신 | 부착할 측정치 |
|---|---|
| "대체로 정확" | 검증 통과율 · 오류 건수 |
| "충분한 커버리지" | 커버리지 % · 결측률 |
| "신뢰할 만함" | 표본 수 · 불확실도 · 검증 방식 |

## 결과 시각화 (위임)

표·차트·다이어그램·대시보드는 `skill:skill_LKS_original_visual-design`(Diagram/HTML 어댑터)로 위임한다. 색·대비·접근성·다이어그램 기하 규칙은 그쪽이 소유하므로 여기서 되풀이하지 않는다.

## 경계 (source-research vs 이 스킬)

| 스킬 | 담당 | 축 |
|---|---|---|
| `skill:skill_LKS_original_source-research` | 조사·문헌·인용의 실재 검증(무엇을·어디서 가져오고 실재하는가) | 상류 수집·검증 |
| `skill_LKS_original_data-pipeline` (이 스킬) | 확보된 데이터의 파싱·정규화·처리·산출 + 재현성·provenance | 하류 취급·산출 |

데이터 규약(정수 enum · 컬럼명 · 인코딩) 보존 권위 = `memory:feedback_code_ownership_scope`.

## 검증

- 정규화 선검사가 Processing 보다 **먼저** 도는가.
- 산출물에 provenance(source · line-pinned)와 품질 지표(수치)가 붙었는가.
- 오프라인 재실행이 같은 산출을 내는가(결정론).
- 근거 없는 주장을 확정으로 올리지 않았는가 · 미측정을 "측정치"로 위장하지 않았는가.

## 예외·금지

- 정규화 선검사를 건너뛰고 Processing 부터 시작하지 않는다.
- provenance·품질 지표 없이 산출물을 확정하지 않는다.
- 파라미터·의존성 미고정으로 "재현 가능"을 주장하지 않는다.
- 사용자 데이터 규약(enum·컬럼명·인코딩)을 임의 변경하지 않는다(→ `memory:feedback_code_ownership_scope`).
- 시각 규칙을 여기서 재정의하지 않는다(→ `skill:skill_LKS_original_visual-design`).

## 위임·관련 (되풀이 X — 포인터로 위임)

| 주제 | 위임 대상 |
|---|---|
| 검수 라운드·관점·청크·재검증 | 헌법 §3 · `skill:skill_LKS_original_review-chunking` |
| 계획·실행·기록 양식 | `skill:skill_LKS_original_plan-execution` |
| 결과 시각화 | `skill:skill_LKS_original_visual-design` |
| 데이터 규약·명명 보존 | `memory:feedback_code_ownership_scope` |
| 조사·인용 실재 검증(상류) | `skill:skill_LKS_original_source-research` |

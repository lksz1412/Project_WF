# Step 74 · 검토 근거와 링크 복원

2026-11-20 · Phase 30.1 · 기준 `477eb06` · 작업 브랜치 `codex/claude-phase25-handoff`

현재 인계에 빠졌던 근거 13개를 복원하고 Codex 요청 39건의 연결을 맞췄다. 독립 검수 전 작업 결과다. Claude와 Collection의 변경은 0이다. 실제 게임이나 과거 제품 시험을 새로 실행하지 않았다.

## 현재 인계에서 읽을 곳

- [Codex 사용자 원문 CR111–CR149](REQUEST_LEDGER_codex-phase25.md)
- [Phase29.1 원본 확인 결과](PHASE_29.1_addon-evidence_RESULT.md) · [기계 기록](PHASE_29.1_addon-evidence_RESULT.json)
- [Phase29.2 채택·검수 결과](PHASE_29.2_addon-adoption_RESULT.md) · [기계 기록](PHASE_29.2_addon-adoption_RESULT.json)
- [Step60 초기 검토](<Step 60 — 상위 애드온 1차 등급과 자체 성능 검수.md>) · [Step60 배포 원본](<Step 60 — 후보별 배포 원본 대조.md>) · [Step61 선택 설치](<Step 61 — 최소 선택 설치 구성.md>) · [Step62 당시 독립 검수](<Step 62 — 채택 권고 독립 검수.md>)
- [Step40 Codex 통합 기록](<Step 40 — Codex collection integration.md>) · [기계 기록](<Step 40 — Codex collection integration.json>)
- 기존 추적 파일인 [외관8 보고](../../References/codex-appearance/8/report.md) · [외관19 보고](../../References/codex-appearance/19/report.md)
- [요청별 현재 연결](audit-installer/requirement-trace.md) · [기계 대응표](audit-installer/requirement-trace.json)

복원 입력은 기존 D 드라이브 프로젝트 작업본이다. Step40은 기존 `Claude/results/Step 40 — Codex collection integration.md/json`을 Codex 소유 기록의 자리로 옮겼다. 원문 내용의 저자를 새로 붙이지 않는다. [복원 파일별 원본·최종 해시](phase30.1-restored-evidence.json)로 이동과 보정 범위를 구분한다. 이 문건의 0.1.0 기록과 Phase29의 과거 결과를 현재 0.1.4 게임 통과로 해석하지 않는다.

## 전후 링크 검사

| 범위 | Markdown | 내부 주소 등장 | 깨진 대상 | 깨진 등장 |
|---|---:|---:|---:|---:|
| 수정 전, 477eb06 추적 문서 | 427 | 1265 | 104 | 129 |
| 같은 427개 문서, 복원 뒤 실제 목적지 | 427 | 1173 | 2 | 2 |
| 새 인계 문서 포함, 최종 | 443 | 1214 | 2 | 2 |

기존 범위는 루트 README와 `Codex/`, `Review/`, `References/codex-appearance/`, `References/codex-verify/`, `Collection/data/`의 추적 Markdown이다. 새 인계 행은 같은 경로 범위에 새 문서까지 포함한다. 주소 삭제가 포함되므로 주소 등장 수 감소를 문서 누락으로 해석하지 않는다. [수정 전 목록](phase30.1-links-before.json) · [같은 범위의 수정 후](phase30.1-links-after-original-scope.json) · [새 인계 포함](phase30.1-links-after.json) · [주소별 처리](phase30.1-link-changes.json).

검사기는 fenced code를 제외하고 인라인 링크와 이미지 주소를 읽는다. URL decode·fragment 제거·문서 기준 상대 경로 정규화 뒤 Git 파일 목록과 상위 폴더 집합에서 찾는다. 외부 URL과 빈 fragment 링크는 제외한다. 디스크에만 있는 파일은 공개 링크로 인정하지 않는다. Markdown 전체 문법, heading anchor, 외부 웹의 현 유효성은 이 개수에 포함하지 않는다. 원래 427개 비교에는 `git ls-tree -r --name-only -z 477eb06`의 source 집합을 고정하고, 목적지 집합에는 현재 추적·새 파일을 모두 사용했다.

### 사유 있는 잔여 2건

| 문서 | 위치 | 남긴 이유 |
|---|---|---|
| `audit-installer/step46-work-log.md` | F46-05의 feature-map 원문 인용 | inline code 안 `../../References/codex-appearance/19/report.md`를 검사기가 바깥 문서 기준으로 해석한다. 원문 인용은 보존. 실제 동일 보고서는 위 외관19 링크다. |
| `audit-installer/step47-work-log.md` | 독립 B 보정 실행 명령 | inline Python에서 `verify_chat` 배열 조회 뒤 함수를 호출하는 부분을 Markdown 주소로 잘못 셈. 역사 실행 명령은 보존. |

검사 범위에 있던 `Collection/data/`에서는 깨진 인라인 주소가 나오지 않았다. Claude 문서 본문은 기존 427개 범위 밖이므로 전수 검사했다고 주장하지 않는다. Codex 계획·추적표가 가리키던 Claude의 Step40 통합 경로는 복원한 Codex 위치로 연결했다. 같은 옛 통합 경로를 Claude·Collection의 Markdown/JSON에서 기계 검색했으며 일치 0건이었다. 보호 범위 안의 수정을 요구하는 잔여 위치는 이번 검사에서 발견하지 못했다.

## 요청 번호와 역사 기록

새 원문 대장은 Codex 요청을 CR111–CR149로 구분한다. 추적표의 39개 주 출처는 각 원문의 heading으로 연결하고 JSON은 실제 행과 anchor를 기록했다. Claude의 실제 R110, 다른 Claude 번호, 역사 작업 로그의 원문과 당시 읽기 위치는 보존한다. 현재 JSON의 `legacyPrimarySource`는 예전 잘못된 대응표 주소이며 새 원문 출처가 아니다. `primarySource`가 복구한 현재 주소다.

## 실제 한계와 확인 결과

Python 기본 문자 인코딩 때문에 첫 목록 조회에서 읽기·화면 출력 오류 2건이 났다. UTF-8을 명시한 뒤 같은 전체 목록을 얻었다. 제품·원본 파일을 건드린 오류는 없었다. 과거 웹 조사, 과거 ZIP·Lua 시험과 게임 화면은 재검증하지 않았다. 원본의 당시 검수 결과와 새 링크 검사 결과를 구분한다. [작업 영향 지도·읽은 범위·실행 기록](phase30.1-evidence-work_log.md).

# Step 0 — 조사·계획·원본보관

## 수행

UI 실행 전의 조사·계획 토픽과 별도 승인된 매크로 보관을 마쳤다. UI 실행 Step1–12는 시작하지 않았다. 원본 UI 배포글·공개 ZIP 위치와 현재 후보 지원 선언·주술사 실제 후기를 정리하고 11절 계획을 저장했다. 과거15개 조합은 참고만 유지한다. 매크로는 사용자 최종 요청 R17대로44개를 네 원본 파일로 private library에 보관하고 찾기 색인을 만들었다.

## 근거·판단

요청 대장R1–R17, canonical plan, source evidence와 실제 A/B 보고를 직접 대조했다. 원본 macro4파일은 보관 전 master가 전문을 읽었고 보관 뒤 원문색인404행과 rootINDEX5행을 읽었다. source에서 관측한 SHA256과 archive4개 해시가 일치했다. 이 검증은 archive 보존 검증이며 게임 호환성 시험이 아니다. 현재 raw 원본을 공개 산출물에 넣지 않았다.

컴팩션 뒤 복구 읽기와 transcript 미확인 범위는 handoffs/forever-ui/recovery-checkpoint.md에 남겼다. Master actual reads: plan303행 수정 전과310행 수정 후 전문(1–147/148–끝), PROJECT_LOCATION37행 수정 전/47행 수정 후 전문, INDEX16/17 전문, REQUEST_LEDGER38/37 전문, evidence42 전문, observations29/inventory31 전문, macro-library-result 전문, triage26와 audit69 전문, A work_log1–101/102–217/218–끝 전문. 최초 큰 출력의 잘린 정책 구간은 나눠 재독했고 규칙 읽기 목록은 복구 기록에 있다. B의 첫10라운드와 재검증 범위는 해당 실제 보고에 있다.

| 곳 | 영향도 | 이유·상세 지도 |
|---|---|---|
| plan·PROJECT_LOCATION·INDEX | 함께 고침 | R13 입력과 R17 현재 범위; 전체 지도 fix-brief/triage 및 A work_log218–239 |
| REQUEST_LEDGER | 상태·반영 칸만 갱신 | 원문 칸17행 보존 대조; master 복구 기록 |
| audit/recheck·A log·source | 확인만 | 실제 인용·실행 출력과 원본 요구 대조; 기존 기록 보존 |
| outputs 전달본 | 기계 생성 | canonical plan/evidence를 D:outputs와 chat outputs에 복사, SHA256 일치4/4 |
| macro/source·게임 파일 | 수정 없음 | 보존 검증은 이미 별도로 완료; 신규 적용·해시 반복 없음 |
| 코드 호출자·입력생성기·잠근 시험 | 해당 없음 | UI 구현 코드 없음; 문서 관계 게이트만 수행 |

## 변경·생성 파일

계획·근거표·현재 프로젝트 위치·INDEX·요청 대장·발주/검수/처리/복구 기록, private MacroLibrary 원본·명세·색인, outputs 전달본. canonical root는 D:\Projects\Project_WF. 앞선 C:체크포인트는 보존했다.

## 게이트

A:11절 순서·15행·12 Step·시간합계630–1110분·인용23단어·금지어0 확인. 이후 수정 관계R13 8/8, R17 현재범위1, 역사 prefix 보존, 검수링크2/2 확인. 정확한 명령/출력은 A work_log92–106/147–182/240–285. B:10관점 검수 중대0/중간2/경미0 → 같은 A 수정 → 같은 B 재검증 중대0/중간0/경미0. Master는 인용한 실제 파일을 다시 읽어 두 건을 확인했다. 검수/재검수 input·cached input·output·reasoning usage와 소요시간, 실제 runtime model/effort는 미관측이다. 역할 설정과 실행 관측을 구별한다. 계획-only commit·push 없음.

원본 macro 보존:4파일/44개/6487bytes, source/archive SHA2564/4, UTF-8 4/4, 이름/조건/literal/행대조44/44, 빈본문1개 보존. 상세는 macro-library-result.md. 게임 가져오기·변환·설치·전투 시험 없음. 전달 gate의 실제 결과와 기록 시각은 동반 Phase Result에 있다.

## 다음

사용자에게 계획을 제시하고 §11의 주술사 특성·콘텐츠·알림/추천량 피드백을 받는다. 계획을 갱신한 뒤 명시 GO가 있어야 UI Step1에 진입한다. 매크로는 이후 필요한 원형을 요청받을 때 꺼낸다. R13 비매크로 Retail 설정은 Step3에서 저장/안정 상태 확인 뒤 읽기 전용으로 참고한다.

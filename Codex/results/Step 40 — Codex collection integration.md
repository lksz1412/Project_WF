# Step 40 — 실제 애드온 묶음 통합

2026-11-19 · Phase 25 · CR145–CR148 · 로컬

승인된 하단 목업의 테마 13종과 FHD·QHD·4K 프리셋을 `Collection`의 설치용 Lua와 텍스처에 통합했다. 이제 프로젝트의 기본 빌드 명령에서 새 모음집이 나온다. [기능 트리](../../Collection/data/feature-map.md) · [테마 적용 목업](../../References/codex-appearance/24/racial-appearance/index.md)

## 위치와 설정

- Core는 공통 프리셋과 외관, 지원하는 설정의 저장·복원, ProfileManager 연계를 맡는다. Dominos·PitBull4·Quartz·Grid2·Hekili·Details의 세부 기능 설정은 각 제품에 둔다. 내장 쿨다운 관리자는 게임 편집 모드에서 다룬다.
- 네이티브 채팅의 수신·발신과 기존 메시지 필터를 사용한다. 새 캐릭터의 세 창 배치와 공통 색·글꼴은 모음집 안에서 적용된다. 이미 창을 분할한 캐릭터는 그대로 사용한다.
- Details는 기존 창 두 개가 준비되면 `/dfdetails apply`로 활성 프리셋 좌표를 적용한다. 적용 전 위치를 같은 세션의 `/dfdetails restore`로 복원한다. 창 생성과 Tiny Threat 모드는 Details에서 다룬다. 소환 전·후 비교는 `/dfcheck petabsent`와 `/dfcheck pet`에 기록한다.
- 설치 모델은 기본 PitBull4형, Forever Unit Frames 전용형, 한 번의 접속에서 두 형을 비교하는 시험형이다. 비교할 때 둘을 동시에 로드하지 않는다.

## 범위와 근거

| 연결 | 검증 |
|---|---|
| 승인 ZIP → 기본 빌드 | `Collection/install.json`, `extract.py`, 생성 manifest, registry, 설치 안내, 각 ZIP의 파일 목록과 해시 |
| 세 프리셋 → 위치를 읽는 애드온 | Core 시작, 채팅 생성, PitBull4·Dominos 위치 계산과 저장값, SexyMap 초기 프로필, Details 실제 위치 함수 |
| 세 채팅창 → 사용자 현재 구독 | 기존 전투 기록 및 공개창 도킹, 사용자가 선택한 원래 대화 종류, 기존 외부 Prat 값 |
| 테마 → 실제 ZIP | 승인된 세 프리셋과 테마 이미지·Lua 해시, PetEdge, 핏불 자산. 새 ZIP의 세 변형에서 공통 애드온 파일 비교 |
| 단일 접속 흐름 → 진단 | 게임 폴더 백업·복원 절차, 기준과 소환수 전후 측정, 전투·파티·공격대, 두 유닛 프레임 교대 |

## 로컬 설치 파일

| 변형 | ZIP | 애드온 | Lua | SHA256 |
|---|---|---|---|---|
| 기본 PitBull4 | DevilForever-0.1.0.zip (로컬 전용) | 35 | 1,344 | `4cfd4b8076a067581708350cf6b614dd2c19d714a759c0105c78e4fd89bf40aa` |
| Forever Unit Frames | DevilForever-0.1.0-fuf.zip (로컬 전용) | 37 | 1,288 | `3fe183a789e1908723a6483081a0cd7c4fb29bab0aa1888293815d246a2bc7ca` |
| 접속 한 번에 비교 | DevilForever-0.1.0-one-session.zip (로컬 전용) | 38 | 1,474 | `3d78bec772f2a463c41d99424b0a9f605aac977a6fada649d69958633c6fd8cc` |

- 세 ZIP의 내부 SHA256, 설치 목록, Lua 5.1 컴파일, 필수 의존성 누락을 검사했다. 테마 파일 120개와 프리셋 3개는 승인된 목업에 쓴 설치 ZIP과 일치한다.
- Core 108건, 채팅 13건, 상태띠 20건, 시전바 연결 16건, Forever Unit Frames 기본값 16건을 실행했다. 실제 런타임 경로의 세 프리셋, 두 채팅 배율, PitBull4 24개 위치, Details 6개 배율 조합과 28개 거절 조건, 읽기 전용 진단 10개 상태를 대조했다.
- Details의 화면 밖 좌표와 복원할 크기가 없을 때 적용 전에 거절하도록 고쳤다. 정상적인 legacy 위치와 부분 실패의 기존 위치 복원은 호출 시험을 통과했다.
- 독립 검수는 두 예외를 수정 전 실제 호출에서 재현했다. 수정 뒤 두 조건 모두 쓰기 0건, 정상 위치와 부분 실패 원복 통과, 세 ZIP에 같은 수정 파일을 확인했다. 최종 중대·중간·경미 미해결 결함은 0건이다.
- PitBull4 원천 패치 시험은 Windows의 GNU `patch` 실행 제한으로 Git 적용을 사용했다. 원본에 패치한 309개 파일에서 내용 차이 0, `LICENSE` 한 파일의 줄바꿈 차이를 확인했다.
- 기존 `Collection` 수정 전 사본은 로컬 전용이다.

## 전면 재검토 제안

마스터 플랜은 승인된 사용자 요구에서 시작해 기능, 해당 코드·프리셋, 실제 설치 결과를 차례로 확인한다. 가장 먼저 검사할 곳은 목업에서만 연결돼 있던 좌표, 예전 기본 빌드가 담는 파일, 기존 사용자 설정에 쓰는 경로다. 이번 통합에서 기본 빌드 불일치와 Details 위치 적용 누락을 확인했다. 확인 가능한 내용은 코드와 테스트까지 대조하고 클라이언트 전용 항목은 접속 결과를 기록한다.

## 접속에서 확인

실제 창 너비와 실효 배율, 클릭·전투 중 상태, 한글 입력, 쿨다운 관리자의 실제 프레임, 4K 퀘스트 글자와 소환 상태를 한 번의 접속에서 기록한다. 경험치 가로 배치는 설계안에 있고 현재 Experience Forever의 세 막대 동작은 세로다. [단일 접속 확인표](../../References/codex-verify/one-session-review.md)

## 2026-11-20 인계 연결

기존 작업본의 `Claude/results/Step 40 — Codex collection integration.md`를 Codex 작업 기록 자리로 복원했다. 당시 0.1.0과 오프라인 검증을 기록한 문건이며 현재 0.1.4 재검증 결과가 아니다. [Codex 사용자 원문](REQUEST_LEDGER_codex-phase25.md#cr145) · [복원 파일 대조](phase30.1-restored-evidence.json).

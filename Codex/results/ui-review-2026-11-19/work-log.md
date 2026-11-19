# 화면 설계 재검토 작업 기록

2026-11-19 · 작업 분석자 A1 · 총괄에게 넘기는 검토 초안

## 소유 범위와 제약

- 작성 파일: 이 폴더의 `review.md`, `work-log.md` 두 개만. 총괄이 작성한 `evidence.json`은 읽기만 수행.
- 제품 코드·프리셋·목업·설치 ZIP·기존 기록 수정 없음. 설치·게임 실행·외부 접속·게시·메모리 기록·커밋·삭제 없음. 추가 서브 호출 없음.
- 신규 파일은 저장소 안에 작성. 같은 폴더의 타 작업을 되돌리거나 덮지 않음. 기존 파일 보호를 위한 복원 명령도 수행하지 않음.
- 목적: 승인 화면 기준을 기능별로 대조하는 분석. 제품 구현과 최종 독립 검수는 이 반환의 완료 주장에 포함하지 않음.

## 단위별 수행

| 단위 | 수행과 결과 | 남은 확인 |
|---|---|---|
| 기준·사용자 결정 | 실제 글·버튼, 같은 배율, 긴 글, 장식 침범, 모서리 허용 조건 대조 | 없음 |
| 세 해상도와 네 번째 사양 | 실제 세 프리셋, 4종 언급, 미지정 네 번째·4K 단독 여부 구별 | 네 번째 확정 사양 근거 미발견 |
| 하단 조작 | 단축바·미니맵·상태띠의 실제 콘텐츠 부재와 기존 유지 근거 구별 | 게임 글·클릭·배율 |
| 전투·그룹 | 기존 유닛 정렬·오라 개인값·소환수 자동 표시, 이름표·쿨다운·Grid2 상태 구별 | 게임 전투·표시 조건 |
| 퀘스트·기록·경험치 | 긴 글·많은 행, 목표 좌표와 실제 적용, 세로 경험치와 가로 대안 구별 | 기본 프레임의 실제 크기·가독성 |
| 설정·채팅·설치기 | 명령 분담, 테마 기록 보존, 새 HTML과 ZIP 차이, 설치기 긴 경로 상태 대조 | 별도 적용과 실제 화면 |
| 자체 확인 | 본문 정독 1회, 범위·출처·수치·확인 수준 및 문자 검사 | 총괄 교차 확인·독립 검수 |

## 직접 읽은 문건과 코드

줄 범위는 해당 파일의 이번 읽기 시점 기준이다. 검색 결과만으로 읽었다고 기록하지 않았다. 처음의 묶음 출력이 잘린 구간은 더 작은 구간으로 다시 읽었다.

| 파일 | 읽은 범위 | 사용 목적 |
|---|---|---|
| `C:/Users/lksz1/.codex/AGENTS.md` | 1–153 | 발주 적용 경계 |
| `C:/Users/lksz1/.agents/skills/skill_LKS_original_file-reading/references/policies/feedback_full_file_read_required.md` | 1–57 | 전문·데이터 구별과 기록 |
| `C:/Users/lksz1/.agents/skills/skill_LKS_original_visual-design/SKILL.md` | 1–97 | 시각 검토 진입 |
| 같은 스킬의 `core_principles.md` | 1–143 | 구조·글·장식 구별 |
| 같은 스킬의 `accessibility.md` | 1–115 | 대비와 상태 식별 |
| 같은 스킬의 `verification.md` | 1–50 | 정적·렌더·게임 관측 구별 |
| 같은 스킬의 `pyqt.md` | 1–172 | 데스크톱 화면 참고. 게임·Windows Forms에 Qt 수치를 이식하지 않음 |
| `C:/Users/lksz1/.agents/skills/skill_LKS_original_review-chunking/SKILL.md` | 1–138 | 중간 분석과 최종 검수 경계 |
| 같은 스킬의 `references/policies/feedback_review_chunk_discipline.md` | 1–39 | 출력 잘림 구간 재독 |
| 같은 스킬의 `references/policies/feedback_chunked_review.md` | 1–139 | 자체 확인·최종 독립 검수 구별 |
| `C:/Users/lksz1/.codex/tools/banned_lexicon.json` | 1–75 | 문구 점검 |
| `Codex/docs/ui-design-criteria.md` | 1–17 | 승인 기준 |
| `Collection/data/feature-map.md` | 1–77 | 기능별 담당·입구 |
| `References/codex-appearance/24/ux/index.md` | 1–64 | 해상도·상태·목업 한계 |
| `References/codex-verify/one-session-review.md` | 1–52 | 같은 접속의 확인 범위 |
| `Codex/results/Step 48 — 검토한 ZIP과 기능 기준 확정.md` | 1–35 | 최신 ZIP 경계 |
| `Claude/results/REQUEST_LEDGER_phase25.md` | 1–56 | 채팅·정렬·자동 표시·설정 선택 |
| `Claude/results/REQUEST_LEDGER_phase8.md` | 1–21 | 쿨다운·시전·Grid2·세 프리셋 |
| `Codex/results/REQUEST_LEDGER_phase26.md` | 1–6 | 기존 로컬 승인 기록 |
| `Codex/results/REQUEST_LEDGER.md` | 1–91 | 초기 4K·채팅 구획과 현재 범위 구별 |
| `Codex/docs/devil-ui-work-order-and-addons-2026-11-18.md` | 1–45 | 옛 구성과 현행 기능 지도 구별 |
| `References/codex-appearance/24/mockup-index.md` | 1–50 | 빈 슬롯·실제 그림 없는 구역 |
| `Claude/results/Step 40 — Codex pet alignment reference check.md` | 1–53 | 이동 제안과 오라 확인·보존 |
| `Collection/data/hekili-current.md` | 1–19 | 추천·쿨다운 분담 |
| `Codex/results/audit-installer/requirement-trace.md` | 1–195 | 이전 결정과 열린 항목 탐색. 끊긴 63–120·121–176·152–155·61–63 재독 |
| `References/codex-appearance/3/report.md` | 1–105 | 단축바·소환수 입력과 제한 |
| `References/codex-appearance/5/report.md` | 1–15 | 미니맵 실제 콘텐츠와 기존값 |
| `References/codex-appearance/16/report.md` | 1–9 | 상태띠 긴 값과 실측 경계 |
| `References/codex-appearance/19/report.md` | 1–23 | 가로 경험치 대안과 세로 설치본 |
| `References/codex-appearance/6-rev/report.md` | 1–33 | 유닛 부속·오라 위치 보존 |
| `Collection/Installer/UI/InstallerText.cs` | 1–89 | 상태·결과 표시 문구 |
| `Collection/Installer/사용안내.md` | 1–23 | 설치기 흐름 |
| `Collection/Installer/UI/InstallerForm.cs` | 1–175, 176–350 | 창 크기·자동 배치·길어지는 목록 |
| `References/codex-verify/phase1/result.md` | 1–76 | 4종 언급·과거 화면 크기 구별 |
| `Collection/AddOns/DevilForever_Appearance/Composition.lua` | 1–134 | 문양 레이어·여백·자르기 |
| `_local_only/mobile-orc-rail-19/render.py` | 1–167 | 오크 새 테두리·문양 합성 코드 |

## 데이터 확인 범위

JSON은 구조와 대상 키를 실제 파일에서 읽었다. 문건 정독 대신 검색한 것으로 처리하지 않았다.

| 파일 | 확인한 구조와 대상 |
|---|---|
| `References/codex-appearance/24/feature-positions.json` | `schema=1`, `coordinateSpace`, `state`, `conditions` 전체, `layouts` 세 해상도의 화면·유닛·소환수·쿨다운·경험치·목표·도움말 값, `notes` 전체. 3개 layout의 역할과 후보 사각형 의미 확인 |
| `Codex/results/audit-installer/reviewed-packages.json` | `packages` 세 항목의 변형·실물 경로·해시·포함 폴더·변경 목록, `gameObserved=false` |
| `_local_only/ui-review-2026-11-19/probe.json` | 최상위 `profiles`, `archives`; 세 해상도 지표·상태·메뉴·후보 교차·퀘스트 틈·소환수, 세 ZIP의 해시·18개 입력 비교·추출 코드 |
| `_local_only/ui-review-2026-11-19/live-check-gaps.json` | `presetSelection` 6개, 테마 호출 세 개와 보존 행 1개·마지막 테마 |
| `Codex/results/ui-review-2026-11-19/evidence.json` | 초기 6개 키 전체와 후속 추가 `current_install_matches_older_theme_archive`, `sample_text_widths`를 직접 읽음. 실제 ZIP 시험·HTML 해시·이름표 쓰기·긴 글 폭·게임 미실행 구별 |

`outputs/devil-forever-mobile-orc-rail.html`은 3,051줄과 큰 내장 이미지 데이터로 구성돼 있다. 파일 길이·검색을 했으나 전문 읽기나 렌더를 수행했다고 주장하지 않는다. 이번 차이 판단의 직접 근거는 승인 기준 문건·새 렌더 코드 전문·현재 Composition 코드 전문·총괄의 ZIP 원시 결과다. HTML 전체의 독립 품질 판정은 수행하지 않았다.

## 열어 본 이미지

이미지에서 문자를 추출하거나 전사하지 않고 배치·빈 상태·콘텐츠 유무를 육안으로 대조했다. 모두 로컬 목업이며 게임 갈무리로 기록하지 않는다.

- `References/codex-appearance/24/ux/fhd-combat.png`
- `References/codex-appearance/24/ux/fhd-input.png`
- `References/codex-appearance/24/ux/uhd-devil-objectives.png`
- `References/codex-appearance/24/ux/resolution-native-comparison.png`
- `References/codex-appearance/24/ux/fhd-party.png`
- `References/codex-appearance/24/ux/fhd-raid.png`
- `References/codex-appearance/24/ux/qhd-pet-alignment.png`
- `References/codex-appearance/24/ux/uhd-nameplates.png`

18개 상태 전체를 직접 육안 확인했다고 쓰지 않는다. 18개 상태의 기존 렌더·사각형 검사는 총괄의 실행이며 그 원시 결과를 읽어 판단에 사용했다.

## 실행과 오류 구분

- 직접 수행: PowerShell `Get-Content`의 줄 번호 출력·구간 읽기, `rg`의 파일·결정 위치 탐색, Python 표준 라이브러리의 JSON 파싱·키·값 확인, 이미지 열기, 지정 두 문건 작성, 두 문건 자체 확인.
- 총괄 수행 후 원시 결과 확인: ZIP 해시·렌더 입력 비교·후보 좌표 교차, 실제 ZIP Lua를 사용한 해상도 자동 선택·테마 기록·이름표 대역 시험, 긴 목표·상태띠 문자열 폭. 이 A가 다시 실행했다고 쓰지 않음.
- `rg`의 파일 인자에 PowerShell에서 펼쳐지지 않는 `REQUEST_LEDGER*`를 넣은 탐색은 오류가 났다. 이후 상위 폴더와 `-g 'REQUEST_LEDGER*.md'` 및 확정 경로로 확인. 오류 실행을 검색 성공으로 세지 않음.
- 일부 도구 출력은 긴 행이나 묶음 출력으로 잘렸다. 읽는 근거 문건은 작은 구간으로 재독. HTML의 거대 내장 이미지가 출력된 검색 결과는 판단 근거에서 제외.
- 진행 글 한 건에 요청 밖 언어가 섞였다. 이후 진행 글을 한국어로 고쳤다. 지정 산출물 두 개의 본문 문자 검사에서 한자·중국어 문자 0개를 확인했고 문장부호도 확인했다.
- 설치·게임·브라우저·외부 도구 실행 없음. 제품 기능의 새 실행 통과 주장은 없음. 도구의 실제 모델·사용량 통계는 미관측.

## 자체 확인에서 보존한 경계

- 사용자 선택: 아군 우측·적군 좌측, 소환수 버튼 자동 표시, 자체 채팅·기본 입력, 기존 개인 오라값, 세 해상도, 통합 편집기 제외.
- 분석자 제안: 긴 콘텐츠 예시 보강과 후속 확인 순위. 새 목업 생성은 이 검토 완료 조건이 아님.
- 기본 파티·공격대 분리와 사용자 설정 동시 표시는 별개. 후보 사각형 교차를 실제 겹침으로 쓰지 않음.
- 기본 이름표의 전투 중 적용 보류 시험과 게임 실제 가독성은 별개.
- 채팅 HTML과 ZIP은 같은 결과로 쓰지 않음. 경험치 가로 공간안은 설치본으로 쓰지 않음.
- 이번 결과는 검토 초안과 작업 기록. 최종 수용·독립 검수 완료를 선언하지 않음.

자체 정독 범위: `review.md:1–203`을 1–105·106–203으로 나눠 읽고 `work-log.md:1–112`를 읽었다. 마지막 변경은 자료 경로 설명, 해상도 이름 풀이, 문장부호, 이 읽기 기록이다. 테마 입력 103개 동일과 긴 글 폭의 추가 근거를 채팅·퀘스트·상태띠·우선순위에 반영했다. 파일 작성 완료 후 편집을 멈추고 총괄의 독립 검수 결과를 기다린다.

마지막 문자 확인의 첫 실행은 한국어 문장을 출력하는 중 Windows 기본 인코딩 오류가 났다. 파일 읽기는 UTF-8이었고 파일 변경은 없었다. `python -X utf8 -`로 다시 실행해 `review.md` 203줄·`work-log.md` 당시 114줄 모두 검사 문자 0개를 확인했다. 이 문단은 그 실행 결과 기록이다.

# Phase 30.2 외관 동기화 작업 기록

## 작업 경계와 변경 전 영향 지도

승인된 목업 3개·JSON 2개·render.py를 새 폴더에 복사하고 README 초안에 재실행 조건과 미검증 범위를 보강한다. 기존 파일은 수정하지 않는다. Collection·Claude는 읽기 전용이고 stage·commit·push·게임 실행은 하지 않는다.

| 곳 | 유형·찾은 방법 | 영향도 | 이유 |
|---|---|---|---|
| 이 폴더 README·render.py·이미지·JSON | 같은 수치·용어·값: 초안 전문 + positions JSON 파싱 + rg 검색 | 함께 고침 | 같은 공개 폴더에 실행과 설명 동기화 |
| ../24/geometry-checks.json, feature-positions.json, racial-appearance/screens/*-devil.png | 입력 생산 측·기준 자료: JSON key·화면·rect 실값 대조 | 확인만 | 승인 입력 보존, 새 코드가 기존 형식을 소비 |
| Collection/AddOns/DevilForever_Appearance/Themes/*/Composition/*.tga, Themes/devil/statusbar.tga, Grid2/media/gradient32x32.tga, PitBull4/Modules/Totems/border.tga | 입력 생산 측·그림: render.py 전체 호출 경로 | 확인만 | 기존 실제 TGA 사용, 새 원화 없음 |
| render.py main → planned_positions/stack_rules/paint_mockup/compare_split → Pillow·JSON | 호출측·피호출측: script 전문 | 함께 고침 | 함수 계약·3해상도·13테마 실구동 확인 |
| README 재실행 명령, JSON 결과, 향후 Claude 인계 | 읽는·파싱하는 쪽: 초안·계획 전문, rg | 함께 고침 | 게임 기본값을 자동 변경하지 않는 제안 자료 |
| 로컬 df-phase30-render.py, df-phase30-layout-report-draft.md, df-phase30-visual-final/* | 쌍둥이 사본: 부모가 지정한 입력 | 확인만 | 입력은 보존하며 정확히 복사, README만 공개 한계 추가 |
| render.py 내 assert와 PASS 출력 | 잠근 시험: 기존 별도 시험 검색 결과 없음; script 내 기계 게이트 | 함께 고침 | 새 출력 폴더에서 전체 실행, 5개 출력 바이트 대조 |
| positions.json·piece-comparison.json → .gitattributes → Git autocrlf → 재현 SHA-256 | 렌더 출력·소비 계약·쌍둥이 바이트: core.autocrlf=true 확인, 기존 해시 표 연결 | 함께 고침 | 두 JSON만 -text로 저장·checkout 줄바꿈 변환을 막아 재현 해시 보존; 검사: git check-attr text + 기존 5개 SHA-256 대조 + git diff --check |
| Codex 계획·References/codex-verify | 이웃 규칙·호출 문서 | 확인만 | master 소유, 이 서브는 쓰지 않음 |

## 판단 근거 정독 범위

- 로컬 작업 지침:1–153; 프로젝트 상위 지침:1–80.
- skill_LKS_original_change-control/SKILL.md:1–23; feedback_change_impact_analysis.md:1–65; feedback_code_ownership_scope.md:1–83; feedback_code_comment_discipline.md:1–41; feedback_post_edit_runtime_verification.md:1–46.
- skill_LKS_original_file-reading/SKILL.md:1–20; feedback_full_file_read_required.md:1–57.
- skill_LKS_original_visual-design/SKILL.md:1–97; core_principles.md:1–143; accessibility.md:1–115; verification.md:1–50.
- skill_LKS_original_review-chunking/SKILL.md:1–138. 독립 검수는 master가 별도 배정하며 이 서브는 발주한 실행 게이트만 수행한다.
- Codex/plans/2026-11-20-devil-forever-claude-sync-plan.md:1–104; phase30.2-세부계획.md:1–8.
- 로컬 df-phase30-render.py:1–215; df-phase30-layout-report-draft.md:1–61.
- banned_lexicon.json:1–75.
- JSON 자료는 Python으로 schema·key·3개 layouts·target/player/grid2.button 값을 확인했다. QHD target y=980, targetpet y=994로 +14; UHD 1536→1540으로 +4.
- Totems.lua는 rg 위치 탐색만 수행했다. 이 파일 전문을 읽거나 직업별 동작을 검증했다고 주장하지 않는다. 주술사만 표시하는 조건은 구현·게임 확인 대기로 공개한다.

## 실행·판정

- 명령: `python -B -I References/codex-appearance/25-codex-handoff/render.py --font "$env:WINDIR/Fonts/malgun.ttf" --output ../df-phase30-sync-1_tek7yj/rendered`
- 판정: `RENDER_RC=0`; `PASS 9 proposed frame groups on 3 approved canvases, no modeled overlaps`; `PASS bottom-up stacking and slot widths reproduce 3 approved canvases`; `PASS 39 themes and presets: 78 assembled surfaces, changed visible pixels 0`.
- 명령: Python hashlib·read_bytes로 공개 파일·로컬 승인 결과·새 출력 3자 대조, render.py는 지정 초안과 바이트 대조.
- 판정: `PASS byte equality: 5/5 published = source = fresh render; render.py exact source copy`.
- 원 출력: `../df-phase30-sync-1_tek7yj/render.log`, `../df-phase30-sync-1_tek7yj/compare.log` (휘발 scratch, 판정 근거는 위 판정 줄).
- 환경: Python 3.12.10, Pillow 12.1.1, Windows malgun.ttf.
- 처음 실행의 OS 임시 경로는 다음 도구 실행에서 파일을 열 수 없어 바이트 대조가 실패했다(FileNotFoundError). 재실행은 새 workspace scratch에서 실행·대조를 같은 프로세스로 완료했다. 최초 복사 중 부모가 추가한 review-grid.png를 발견하여 지정 5개 파일만 복사하도록 바로잡았다. 둘 다 입력·기존 결과는 변경하지 않았다.
- README.md:1–76 전문 대조: 3해상도 표와 JSON 일치, QHD +14·UHD +4 오프셋 확인, 공유 마진·기존 오라 보존, 재현 명령과 입력·미검증 한계 명시.
- 부모가 만든 3화면 review-grid.png를 형태 확인에 사용했다. 글자 추출이나 실제 게임 판독은 수행하지 않았다.
- 자체검수는 발주한 실행·동일성 게이트까지다. 독립 검수 대기. 개별 크기 조절·게임 구동은 미검증이며 별도 실행하지 않았다.

## 결과 SHA-256

| 파일 | 바이트 | SHA-256 |
|---|---:|---|
| fhd-party-targetpet-totems.png | 442625 | 149e54f5377ed15f1db78062c1059c9370a6468613e5eb5b93c07666f880ccef |
| qhd-party-targetpet-totems.png | 586176 | 670e4a7a4fd6a8031f313594ed05dc02f03d4b933032df8eff2ab3a031b38123 |
| uhd-party-targetpet-totems.png | 917926 | 39124ed778ee6ba2a9bd061fc9192e51bde2ac3dcee3e6fbf516612ed0ba6b96 |
| positions.json | 2661 | bfc0701c9f46620aa0b2aac95ce925212d89d9d90f5af04c2c16a74bb1b84109 |
| piece-comparison.json | 36003 | 6c25a097a394c0b6fa1b37db54988200774146f1133ca24190edca8eef5a12fe |

## 남은 결정 대기

없음. 적응형 규칙과 테마 운용은 검토 제안이며 최종 선택·게임 적용은 master 인계 범위다. 실제 runtime model·usage는 도구에서 미제공으로 미관측이다.

## JSON 줄바꿈 보존 수정 확인

- 읽은 범위: work_log.md:1–57 전문; .gitattributes:1–2 신규 작성 후 대조. 영향 지도에 렌더 JSON·autocrlf·재현 해시 연결 추가.
- 명령: `git check-attr text -- References/codex-appearance/25-codex-handoff/positions.json References/codex-appearance/25-codex-handoff/piece-comparison.json`; 판정: 두 파일 모두 `text: unset`, rc=0.
- 명령: Python hashlib로 위 표 5개 SHA-256과 현재 파일 대조; 판정: `PASS original SHA-256 5/5 unchanged`.
- 명령: `git diff --check -- References/codex-appearance/25-codex-handoff`; 판정: rc=0, 공백 오류 출력 없음.
- 원 출력·수정 전 work_log 사본: `../df-phase30-attrs-9ljb26kb/{attributes.log,whitespace.log,work_log-before.md}`. stage·commit·checkout 검사는 수행하지 않았다.

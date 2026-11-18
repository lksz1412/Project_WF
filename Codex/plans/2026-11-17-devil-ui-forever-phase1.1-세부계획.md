# Phase 1.1 — 원본 확보·외형 분석 세부계획

## Summary

R19의 Step1은 완료됐다. R20–22가 승인한 Step2 배치 설계·미리보기를 진행한다. 공개 Interface.zip·Fonts.zip 확보, byte 보존, 안전한 격리 추출, 핵심 애드온·내장 설정·자산 정적분석으로 원형 재사용/설정 재작성/코드 보완/미확인 부분을 증거와 연결한다. UI 설치·게임 테스트·새 UI 구현은 하지 않는다.

## Current Ground Truth

Master plan312행을 이전 설명 시점에1–110/111–221/222–끝 전문으로 재독했고 이번 시작의 최신 INDEX·Planning Result·REQUEST_LEDGER·SESSIONS를 전문으로 읽었다. 원본 배포글 https://www.inven.co.kr/board/wow/1636/31588 첫 그림이 확정 기준. 이번Drive listing에는 Fonts.zip35611779bytes, Interface.zip31392260bytes 두 파일만 있다. 배포시각2022-11-19. 원본 폴더 https://drive.google.com/drive/folders/1QMZiceFpizZ5dHxTkG2UemZAYKaQFdg7. raw fetch는 원격 파일참조이며 로컬ZIP확보로 세지 않는다. source read-only, private MacroLibrary·Retail WTF 이번 범위 밖.

## Phase Range

챕터1·Phase1.1의 Step1 완료, Step2 원본 이미지 대조·4K 하단 적층 배치 설계 실행. 이전 Step0 결과는 immutable history로 둔다. 같은 Phase의 A/source_analysis·B/source_review 한 유닛을 직렬 재사용.

## Non-goals

게임/CurseForge 입력·설치·업데이트·WTF읽기/쓰기·매크로·새UI Lua 코드·전투시험·대량 웹후기 재조사·원본 변경/삭제·공개게시 없음.

## Implementation Changes

SourceArchive/2022-11-19/{originals,extracted}에 공개ZIP과 추출 실물 보관(Git 제외). Codex/results/source-analysis/에 작은 provenance/inventory/read-coverage 기계기록, Codex/docs/original-source-analysis.md에 사용자용 결론. scratch는 fresh work/하위. 기존작업 복원사본은 entry backup에 있다.

| 곳 | 유형/찾은 방법 | 영향도 | 이유 |
|---|---|---|---|
| master plan·현재 Phase 세부계획 | 사용자 범위, full current read | 함께 고침 | R19 한정 실행·후속경계·검수 관점 |
| REQUEST_LEDGER | 입력원문, fullread | append | R19 추가, 이전행보존 |
| INDEX·.gitignore | 구조소비자, fullread | 함께 고침 | 원본대형파일 Git제외·실제경로맵 |
| SourceArchive | 신규입력, Drive listing/fetch | 신규 | byte보존 후정적분석, 실행안함 |
| 원형분석 report/provenance/inventory | 신규소비자 | 신규 | 핵심주장↔실물파일/행·해시 연결 |
| 기존 source-evidence/관찰/Planning Result·C:체크포인트 | 이전기록 | 영향없음 | 당시기록유지, 미래분석결과로 덮지 않음 |
| 생성전달본 | generated twin | 이후기계생성 | 검수후 canonical보고 복사 |
| codecallers/callees/lockedtests | 없음(noncode) | 해당없음 | source를 실행/수정하지 않음 |

## Phase N — 세부 Step

| Step | 범위 | 예상 | 상태 |
|---|---|---|---|
| 1 | 원본확보15–25분 + 핵심구성분석·결론30–60분; 독립검수 포함 필요시간 관측해 기록 |45–90분(master 기존예상), 합산작업45–85분 추정 | 완료 |
| 2 | 첫이미지·회수 설정 대조, 4K 버튼 크기·간격·단 수·바닥 여백부터 쌓고 체력/마나·미니맵·블랙 패널 배치, 오프라인 미리보기 |45–90분 | R20–22 한정 실행 중 |

Step1 자연단위: 취득/보존→목록·설정원천확인→핵심영역별source추적→재현/제작표→기계gate→같은A/B 검수정정→Step1 결과기록. 각 단위 읽기·작성·연계·자체gate·이유를 A log에 기록.

## Implementation Interfaces

Drive canonicalURL/id/metadata → rawZIP + size/SHA256/CRC/취득시각 → 안전한 추출실물/원래경로/encoding → core Lua/XML/TOC/default profiles/assets 행근거 → 재현가능성표. 원본 Lua나 설치명령은 실행하지 않는다. HTML 오류·압축부패·경로탈출·symlink는 추출전 검사. 필요한 config/source는 전문읽기, vendor라이브러리 전체를 읽었다고 하지 않는다.

## Test Plan

크기2/2 metadata일치·ZIP전체CRC0오류·항목경로안전검사·추출보존·hash·폰트/그림존재·TOC/프로필목록과 결론 연결, fullreadcoverage/미독구별. 실제client호환성은 미검증이며 정적장애후보와 구별.

사용자용 신규보고: 비코드③/P5 고정5(형식,사실/참조,연결,완결성,사용자의도)+가변5(취득무결성,profile출처,외형source연결,API호환추정적대,재사용권한/유지보수) 총10관점·10라운드. 한 B가 순차검수, 발견전체를 같은A 수정 후 같은B 범위재검증1회. source index 중간기록은 기계gate/자체1회. UI실행시험·게임API실측은 없음.

## Assumptions

ZIP에 당시계정WTF가 들어있다고 가정하지 않는다. 단순addon나열은 분석완료 아님. 추출한내장defaults/profile설치로직에서 하단배치가 복원되는지 직접찾는다. 없는설정/자산은 근거미발견. 전체애드온port나100%픽셀일치는 보장하지 않는다.

## Correction History

R19 사용자피드백: 원본실물부터분석, 이번실행범위 Step1 한정. 초기계획의ZIP미확보전제를 실제취득후 갱신.

## Decisions Required

이번 Step1 승인됨. 읽기/취득·정적분석·보고/기록만, 특성/알림결정은 이작업의blocking아님. 새의존성설치 없이 기존도구 우선; 부재시 가벼운해석가능범위 기록. 공개원본다운로드만, 계정연결·유료서비스·외부개인자료업로드 없음. 기존게임파일/원본덮어쓰기·삭제 없음. 임시정리삭제 없음. 실제권한은 호스트검토대로. A/B 직렬·같은역할 재사용, Phase전환 새역할. 검수실패는 원인고침·scope재확인, 미해소결함보고는 배포안함. local topic-endcommit은 사용자지침에따라 Step1완료시 master수행(개인raw·대형원본/추출은 제외); push/merge/게시 승인없음. 게임실측불가는 미검증. 모델미가용은 대체안함. 후속구현으로 자의진입없음.

Step1 결과 — 2026-11-17 21:32:48 +09:00: 원본ZIP2개·loaf/자산/설정 연결 분석과10라운드 독립검수0/0/0 완료. Step2는 미착수이고 Phase1.1 전체완료로 세지 않는다. 세부 근거는 source-analysis 보고·Step1 이력·현재범위 Result. 게임 구현·공개 배포 미수행.


Step2 현재 범위: 사용자4K, 화면 전체 비율 환산 금지. 버튼 적층 높이·읽을 수 있는 크기를 먼저 정한다. 원본 이미지 영역/단 수와 회수 anchor chain의 관계를 비교하되, 저장 좌표를 현재 pixel로 단정하지 않는다. 실제게임/UI scale 미측정은 미검증. 자연단위: 원본 이미지 취득·geometry판독→설정/화면 대조→버튼 적층 기준/좌표 제안→미리보기→가독성/충돌 기계확인·시각확인→같은B 독립10관점 검수→Step2/Result기록. 본체게임 구현없음. 새 도구·의존성 설치없음, 기존 renderer 우선. 정확한 raster 확인이 안 되면 3840×2160은 명시한 작업가정으로만 사용하고 바 크기·간격을 고정해 폭 변화에도 아래 적층을 보존한다. 검수는 masterplan 최신Step2 P4/가변5와 같다. R19 단독시점의 아래 Step1 결과는 역사기록이며 현재Step2 진행을 대체하지 않는다.

R23 Step2 역할 정정: 세 반투명 음영 구획은 각각 대화창(사용자확인). geometry는 보존, 보고/대조표/명세의 role을 chat3개로 맞추고 배경 투명·음영 표현 확인. 채널배정은 추정없음. 현재B 검수는같은B가이어가고 반환후 같은A2가 관련곳을한번에반영, 동일B가바뀐부분을재확인.

R25 재설정 — 2026-11-17 22:31:12 +09:00 : Step2는 2022FanFix 기준철회로 동결·대체됨. 수용/완료로세지않고PNG를최종원형처럼전달하지않음. B10라운드중대0/중간1/경미1, R23추가역할정정은미반영상태로역사보존. 새원형자료실전수확인으로이동, 기존자료삭제없음.

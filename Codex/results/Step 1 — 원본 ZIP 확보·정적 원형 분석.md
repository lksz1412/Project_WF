# Step 1 — 구버전 ZIP 확보·정적 원형 분석

## 수행

R19 한정 승인에 따라2022-11-19 Black FanFix10.0.2의 Interface.zip/Fonts.zip을 공개 원본 폴더에서 확보하고 격리 추출·정적 분석했다. 실제 하단집중형 loaf 선택부,내장배포설정,배경/스킨/폰트,애드온 소비코드를 연결해 재사용·직접제작·미검증 영역을 보고했다. Step1 완료이며 Phase1.1전체/Step2/게임구현 완료가 아니다.

## 근거·판단

A가 단순addon목록을 넘어 원본34개코드/로더/TOC/XML을 전문으로 읽고,7개의 순수literal설정은 Lua실행없는 끝까지파싱으로 구분했다. source-map와33key/spans,read-coverage에 근거가 있다. B는 지정10관점에서 실제원본과대조했고0/0/0. Master는 rawB보고와 실제산출물을 읽고 핵심원문을 직접대조했다.

Master readcoverage: 원형보고서1–70/71–83 전문 및검수상태append, source-map1–30/read-coverage1–99 전문, Aworklog 전문, Brawaudit 전문. 원본 !DevilUI.toc1–13/!DevilUI.lua1–207/load_Profile.xml1–21, nibProfileLoader.toc1–6/lua1–94, Devilconfig.lua1–144, sharedmedia.lua1–21/load_media.xml1–3 전문. Reflux.lua1–275/276–549, SexyMap.lua1–305/306–609, Dominos/core/bindableButton.lua1–151 전문. 두 생성기 inventory-complete.py1–66/parse-profile-literals.py1–75 전문. DB자료는2archive객체·7overview·선택keyschemas, kgPanels활성8패널전체값·Masque/SexyMaploaf전체·PitBullloaf전체·Dominos3/4/7/8/9/10/totem1·Quartzprofile목록을 실제질의했다. 코드실행·수만행수동전독으로 바꾸지 않는다. source.zip/TTF/TGA는 파일목록·해시/헤더 근거이며실제화면판독·OCR아님.

| 곳 | 영향도 | 이유·전체지도 |
|---|---|---|
| 신규보고·source-map·source기계기록 | 신규/함께고침 | source→consumer→look 연결; detailplan/brief/Alog/Baudit |
| masterplan·현재phase·INDEX | 사실/진행metadata 갱신 | ZIP미확보전제를 실물분석완료로; sourceprofile와pixel/runtime구별, Step2미착수 |
| 요청대장R19 | 상태/반영위치 갱신 | 사용자원문과기존행보존 |
| 원본ZIP·추출코드·PlanningResult/Step0 | readonly/history | 원본·이전기록보호, 과거미검증기록을 덮지않음 |
| 신규전달본 | 기계생성 | source보고·map·현재plan을NEW이름으로copy/hash; 이전전달본보존 |
| input생성기/독립실행/현재gamecallers/lockedtests | 확인만/해당없음 | 생성기실제성공출력대조, 통과CRC등재실행안함; 게임코드변경없음 |

## 변경·생성 파일

원본 SourceArchive/2022-11-19/originals/{Interface.zip,Fonts.zip}와extracted실물은 Git제외. Codex/docs/original-source-analysis.md, Codex/results/source-analysis의provenance/inventory/profile/layout/gates/coverage/map/review/unit기록, handoffs/source-analysis발주·Alog·Baudit·triage·sessions, phase1.1세부계획, 이번Step/Result/실행ledger. 기존plan·INDEX·.gitignore·R19대장에 이번사실/경계 반영. 게임/WTF/개인macro변경없음.

## 게이트

ZIP2개67004039bytes, CRC오류0·위험경로0·추출파일4614/4614해시일치. 해시는취득byte고정이며publisher공개checksum과비교인증아님. literal설정7파일완전소비, key/spans33, XML19참조/17존재/2누락, Quartzloaf부재, Wide중복1은loaf밖. 첫목록실행cp949출력실패는기록·정정했고성공으로세지않았다. A실제명령/판정은worklog의Executionoutputs및Finalexecutionaddendum. B10라운드중대0·중간0·경미0, 수정/재검증필요없음; master실물대조확인. 실제모델/effort/input/cachedinput/output/reasoning/검수compute시간은미관측. 역할설정gpt6.1-sol high와구분.

현재client호환·정밀pixel재현·profile가져오기·전투·input·reload/relogin·keymapping은미검증. 모든PASS는정적분석범위. 전달기계검증/기록시각/관측시간은동반Result. 커밋은Step종료시master가관련파일만수행, push/merge/게시없음.

## 다음

Step2 첫이미지 정밀비교와현재화면배율실측이남아있다. R19승인범위는Step1이므로후속설치/게임조작/새UI구현으로자동진입하지않는다. 원본자료로panel/asset/설정연결부를설계할수있고, 체력frame현재후보와Quartz배치는추가확인이필요하다. 사용자macro44원형도서관은그대로유지한다.

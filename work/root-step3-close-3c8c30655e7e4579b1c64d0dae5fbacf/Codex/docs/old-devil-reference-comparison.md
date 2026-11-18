# 옛 Devil 하단 UI 원형 대조 — Step3

상태: Step3 확대 조사 저장·A1 확인 완료, 독립 검수 대기.34개 글·확보된 고유 이미지50개와 추가4배포본을 대조했다. X2 전체 추출 차단·46개 안전 선택 추출, V42 설정3개 부분 파싱, 이미지2개 회수 불가를 한계로 유지한다. Step4는 아직 시작하지 않았다.

현재 시각 기준은 사용자가 선택한 **idx45의 실제 네 번째 샘플**이다. idx11218은 미터기를 제외한 배치 참고, idx2958/2009는 역사 비교, idx13140은 현재 Forever 수정 구성 참고로 둔다. 세 반투명 직사각형은 사용자가 확인한 세 대화창이다. 창별 채널·필터는 사용자 현재 설정이 확인되지 않았으므로 옛 배포본의 분담을 자동 적용하지 않는다. 4K에서는 버튼·행·간격을 아래부터 쌓으며 원본 화면 비율을 일괄 확대하지 않는다. 근거: REQUEST_LEDGER_phase1.3.md:10–25, 세부계획:15–17/75–79.

## 원천과 실제 확인 범위

수집일은2026-11-17이며, 검색 범위는 사용자가 지정한 두 페이지 전체다. 최근 자료만 고르는 기간 제한을 적용하지 않았다. 게시물의 최종 업데이트 날짜, 첨부 개별 날짜, 이미지 경로의 날짜는 서로 다른 값이다. 제목의 버전과 메타데이터가 다르면 각 값을 보존했다.

- 전체34개=첫 페이지20개+두 번째14개. 본문34개와 변경사항34개(내용 있음10/빈 섹션24)를 읽었다. 전체 웹 페이지의 광고·공통 메뉴나 확장 JSON이 반복된 큰 추출문서를 전부 읽었다는 뜻은 아니다.
- 원천 목록·취득 HTTP/시각/크기/SHA256(파일 내용 해시)은 `Codex/results/old-reference/acquisition/{catalog-v2.json,acquisition-provenance-v2.json}`. 게시물별 실제 읽기 범위는 `a1-article-read-coverage.json`. 완전 본문 사본은 `acquisition/articles-compact-v2/idx-번호.md`와 section별txt이며 원문HTML selector/행을 담는다.
- 이미지 원천58참조 중56참조 디코딩 성공·고유 SHA25650개. 동일 바이트의 중복만 한 번 관찰하고 모든 게시물/원순서 연결을 유지한다. 원본8906의 두 장은 원본·썸네일404, 정확4URL의 공개Wayback1회 조회도 capture없음이다. 해당 내용은 관찰 불가로 남긴다. 이미지 판독 최종 범위는 뒤에 기록한다.
- 제공ZIP두 개는 원본 해시 일치와 CRC(Cyclic Redundancy Check, 압축 데이터 손상 검사) 각1회·안전 경로·추출 개수 대조를 통과했다.2009는3495파일/37,823,930B. Alpha외부ZIP는EXE1개이며 이를 실행하지 않고 기존Bandizip으로 NSIS형식을 정적 추출해2745파일/39,016,814B를 얻었다. NSIS목록의 크기값은모두−1이므로 목록 합계와 추출 바이트의 동일성은 확인 불가다. 기존2022CRC·추출은 재실행하지 않았다.

취득과 독해, 그림 관찰, 정적 코드 해석, 게임 작동은 각각 별개 상태다. 이번 작업에서 게임 설치·설정·코드 실행은 하지 않았다. 이전2022미리보기와 당시 미해소 발견은 동결 상태다.

## 전체34개 글의 의미

아래 날짜는 각 글의 **최종 업데이트** 표기다. 모든 행은 실제 본문·변경사항·메타데이터를 읽은 뒤 분류했으며, 분류는 A1의 분석이다. 링크는 원문, 원문 대응 사본은 `acquisition/articles-compact-v2/idx-번호.md`다. 글 제목에 Devil이 들어간다는 이유로 모두 같은 완제품으로 합치지 않았다.

| 글 | 최종 업데이트 / client 표기 | 본문을 읽고 구분한 역할 |
|---|---|---|
| [45](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=45) | 2015.03.04 / 5.3.0 | nicecurry 원 배포글. 네 번째 샘플이 현재 최우선 시각 참고. 최신 첨부와 옛 샘플의 동일 build는 미확정. |
| [11218](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=11218) | 2023.05.15 / 10.1 | 일반 하단집중형이라고 본문에서 명시. 사용자 선택에 따라 외형 참고 유지; 오른쪽 미터기는 세 번째 채팅창으로 대체할 요구. |
| [2958](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=2958) | 2009.12.10 / 3.3.0 | 3.3 개인 임시수정 Black. 사용자 제공2009 ZIP의 비교 글; 단순 빈 간격과 구분선 차이 대조. |
| [13140](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=13140) | 2026.11.17 / 1.60.1 | 현재 Forever 수정 통합본 제작자 선언. V42 PitBull 수정·지도 전환 참고만; 목표 외형 아님. |
| [12993](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=12993) | 2026.02.11 / 12.0.1 | 일부 애드온 개인 저장. 전체 원형이나 현재 Forever 채팅 지원 근거로 쓰지 않음. |
| [11361](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=11361) | 2023.05.15 / 3.4.1 | 클래식 리치왕 하단집중형 수정판. 2019–2023 변경 기록; 버튼 제거용 Chatter 언급은 역사 근거. |
| [12610](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=12610) | 2022.07.30 / 2.5.5 | 불성클래식 하단집중형 개인 수정. 별도 Drive 링크; 이번에 추가 ZIP 수집하지 않음. |
| [12124](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=12124) | 2021.02.15 / 9.0.2 | 어둠땅 Black 통합 수정판. WideX/Plater 지시 포함; 실행하지 않은 역사 문서. |
| [12174](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=12174) | 2020.11.06 / 9.0.1 | 일반 Normal 재구성. 원형과 완전히 같지 않다고 저자 명시. |
| [10341](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=10341) | 2016.11.04 / 7.0.3 | 7.1 FanFix 저장글; 실본문은 짧은 이름뿐. 제목 이상의 동일성은 불명. |
| [9880](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=9880) | 2016.01.22 / 6.2.2 | 6.2.2 통합본 개별 모듈 업데이트. 원래 위치/profile에 의존. |
| [9789](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=9789) | 2015.09.21 / 6.2.2 | 6.2.2 업데이트. 채팅창 잠금 해제 후 위치·크기 조정 설명. |
| [3461](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=3461) | 2015.03.04 / 5.1.0 | nicecurry Black Edition2 원 배포글. 일반 와이드와5:4 배치 구분;45와 별도 제품/첨부. |
| [8906](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=8906) | 2014.10.17 / 알수없음 | 6.0.2 Black Fanfix. WideX와5.4Theta 선행 의존 설명; 샘플 두 개 원본·썸네일 회수 불가. |
| [8920](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=8920) | 2014.10.16 / 6.0.2 | 6.0.2 Normal Interface 모듈 모음. PitBull 위치 수동 변경 등 임시 업데이트. |
| [7618](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=7618) | 2012.09.03 / 5.0.4 | 5.0.4 일반16:10 모듈 갱신. 선행Devil4.3설정 의존; Black 원형으로 단정 불가. |
| [7546](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=7546) | 2012.08.31 / 5.0.4 | 5.0.4 DevilUI-X 임시 모듈 갱신. 기존WTF필요 선언. |
| [6405](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=6405) | 2011.07.06 / 4.2.0 | Dominos 폰트 수정 단일 기능. 전체 UI 배포본 아님. |
| [4238](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=4238) | 2010.10.10 / 3.3.5 | BlackEdition1 라이트 버전.1280×1024 최적화·레이드 모듈 축소. |
| [4019](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=4019) | 2010.07.02 / 3.3.3 | 3.46 저장글. 본문 aaaa, 제목/메타데이터 외 해석 제한. |
| [4018](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=4018) | 2010.07.02 / 3.3.5 | Black 임시 갱신 파일. ChocolateBar/Devilconfig/해상도별 초기화 모듈 교체 지시. |
| [4012](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=4012) | 2010.07.02 / 3.3.5 | 일반Devil 임시 갱신 파일.4018과 본문 같지만 별도 글/명칭 유지. |
| [2582](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=2582) | 2009.08.06 / 알수없음 | 3.2 하단집중형 개인 커스텀. 제목 버전과 클라이언트 알수없음 필드 구분. |
| [2312](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=2312) | 2009.04.23 / 3.1.0 | 3.29 EXE 저장글. 본문 파일명뿐; 해당EXE 미수집/미실행. |
| [1932](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1932) | 2008.11.02 / 3.0.2 | Black CUSTOM 3.0.2.1280×1024/Bartender4, 메뉴·가방 좌상단 변경; 원형과 구성 다름 명시. |
| [1877](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1877) | 2008.10.29 / 3.0.2 | WCK Wide 짜집기. Dominos→Bartender4, ButtonFacade→cyCircled, 모듈 추가. |
| [1865](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1865) | 2008.10.29 / 3.0.2 | Wide 개인 짜집기. 구2.43느낌 복구 의도; Bartender4/cyCircled 교체. |
| [1853](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1853) | 2008.10.24 / 3.0.2 | 3.02 Beta 기반D3_Skin 개인 혼합. 원본과 분리. |
| [1403](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1403) | 2008.04.21 / 2.4.1 | DevilSkin 질감 스킨 단일 자료. 저자 설명512×128, 전체UI 아님. |
| [1361](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1361) | 2008.04.14 / 2.4.1 | Devil/Wind 혼합 도적용 개인 구성. 질감·PitBull 등 변경. |
| [1121](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1121) | 2008.03.24 / 2.3.0 | 도적용 개인 혼합. Devil기반이지만 원본 동일성 근거 아님. |
| [1086](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1086) | 2008.03.13 / 2.3.0 | 도적용 혼합. NeonChat/SisterChatMods/SlipLifeChat 등 여러 채팅 모듈 목록. |
| [1008](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=1008) | 2008.02.26 / 2.3.3 | 2008년 힐러용 개인 혼합. 제목 Forever는 당시 작성자 맥락, 현재 게임 flavor 증거 아님. |
| [546](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=546) | 2007.10.19 / 2.2.3 | 2007년 간소화 도적 중앙집중 혼합. 본문은 메일 안내 한 줄. |

가장 오래된 글과 현재 가장 닮은 그림은 같은 분류가 아니다.45와3461의 nicecurry 등록글,2009개인 임시 Black,여러 도적용 혼합본,후대 일반 하단집중형과 Fanfix를 따로 유지했다.11218의 “블랙에디션 아니구요”라는 명칭 설명은 사용자가 선택한 외형 참고를 제외할 이유가 되지 않는다. [11218 원문](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=11218)

## 네 번째 샘플과 다른 계열의 실제 차이

지정 image-reader가 원본 전체 화면을 관찰해 남긴 원기록을 A1이 전부 읽고 대조했다. 원기록은 `image-observations/findings.md:1–426`의 해시별 관찰50건이다. 성공56참조·고유50개를 모두 관찰했고, 같은 바이트의 추가 연결6개를 보존했다. 확대·부분 화면·파일목록 등 비배치 그림7개와 중요한 가림9개는 각 그림에 한계를 남겼다.8906의 실패본 두 장은 관찰하지 않았다.

45의 screenshot iframe에서 DOM(Document Object Model, 문서 안 요소 순서) 네 번째 onclick은 `viewImage('wow/addonpds/image/1103_7276.jpg')`다. iframe33/40/47/54행 순서의 마지막이므로 파일명 정렬로 고르지 않았다. [실제 네 번째 원본](https://upload.inven.co.kr/upload/wow/addonpds/image/1103_7276.jpg)은800×500,95,482B, SHA256 `304A6B36ACD94B065142B8E8ADBA1EC99787BB649885D136D5CE707C1B2D5151`이다. 취득·원순서는 `acquisition/PRIORITY_READY.json`과 보존된`images-45.html:1–67`, 관찰은`findings.md:5–27`이다.

| 비교점 | 45 네 번째 원본 | 11218 첫 번째 / 2958 차이 |
|---|---|---|
| 아래 적층 구조 | 긴 단축줄→검은 가로 띠→낮은 모듈 구획→맨 아래 얇은 상태띠 |11218도 비슷한 구조.2958은 긴 장식 단축줄 없이 중앙 아래 grid가 주 구성 |
| 대화창 위치 | 왼쪽 두 인접 구획, 미니맵 오른쪽의 세 번째 구획. 원본 좌표 대략x0–195/195–389/609–798,y422–489 |11218오른쪽은 실제 미터기이며 목표에서 제외.2958의 여러 빈 구획을 전부 채팅이라고 추가 추정하지 않음 |
| 구분선·테두리 | 약1–2원본pixel의 얇은 회색 직선 테두리·좁은 접합, 위쪽 검은 가로 띠. 넓은 빈 간격과 구분 |2958에는 약5–8pixel의 단순 틈이 여러 모듈 사이에 보임.11218은 얇은 테두리와 긴 장식줄 유지 |
| 단축바 | 길게 이어진 윗줄과 짧은 보조줄, 중앙 아래 약8열×3행, 그 아래 작은 메뉴줄 |11218도 중앙약8×3.2958중앙약12열×4행. 긴 윗줄 정확한 셀 수·키/주문 구성은 그림에서 미확정 |
| 장식 | 긴 단축줄 양끝의 말린 뿔/곡선 같은 장식 |11218유사 장식.2958에는 같은 윗줄·끝 장식이 관찰되지 않음 |
| 미니맵 | 중앙 단축블록 바로 오른쪽의 아래 사각형 |11218/2958도 아래 사각형이나 주변 버튼·간격 다름.45다른샘플1/2는 위쪽 원형지도이므로 네 번째와 섞지 않음 |
| 체력·자원·시전 | 왼쪽 중앙 위의 작은 unit bar 묶음과 색 자원줄 |11218unit쌍은 좌우로 벌어짐.2958긴 수평unit쌍. 정지 그림의 특정 바를 실제 시전 상태라고 확정하지 않음 |
| 채팅 장식 | 큰 제목바·노출 탭줄·큰 입력창·왼쪽 버튼더미가 그 순간 눈에 띄게 튀어나오지 않음 | 정지 화면의 비노출일 뿐, 입력 때·마우스를 올렸을 때 동작이나 자동숨김의 증거는 아님 |

모든 좌표는 원본 비교를 위한 근사 측정이며 4K 목표 좌표가 아니다. 그림에서 바인딩·주문·필터를 추출하지 않았다.11218의 두 번째 샘플은 가방창 확대라 전체 배치를 판단할 수 없다.2958의 실제 bitmap은1920×1024이며 저자의16:9 지시와 별개다. 잘림 여부나 비율 의도는 미확정이다. 관찰 근거: `findings.md:74–118`.

확보한 나머지 그림도 전부 관찰했다.2582는 아래 사각 지도·긴 장식줄이 비슷하지만 왼쪽 구획 수와 중앙 셀 수가 다르다.1932/4238은2958처럼 단순 틈·중앙12×4 계열이다.3461 BlackEdition2는 위쪽 사각 지도·오른쪽 미터기와 다른 중앙 배열을 보인다.1853은 구체형 체력·자원 장식,1361은 분리된 두 행동블록과 중앙 아래 지도,1008은 원형 버튼·원형 지도 혼합이다.13140의 세 변형에는 노출 탭과 더 큰 셀 수가 보이지만 목표 외형으로 채택하지 않는다. 근거: `findings.md:120–419`의 각 출처·해시 항목.

## 제공 ZIP에서 회수한 설정·자산·채팅 기전

정적 코드의 실제 인용·파일별 읽은 행은 `Codex/results/old-reference/a1-static-source-evidence.md`에 고정했다. OLD/ALPHA/LATE는 각각2009·Alpha·기존2022 추출 루트다. 대용량 SavedVariables는 Lua로 실행하지 않고 literal table 데이터로 파싱했다.9자료의 전체 프로필·프레임·layout·패널 키 집합을 보존한 compact JSON에서 필요한 키를 조회했으며, 총계는29프로필·322프레임·5layout·30패널이다. 모두 동시에 활성·노출된다는 뜻은 아니다. 원문행·해시는 `literal-table-parse-overview.json`, 상세 키별 위치는 `literal-settings/`에 있다.

| 비교 | 실제 회수 근거 | 분석과 한계 |
|---|---|---|
|2009 패널 | `kgPanelsDB.profiles.Default.layout=devil`; devil 아래6패널. Chat1/Chat2/Minimap/Omen/Recount는 `border_texture=None`, BarBG만 Blizzard Tooltip/edge1 | 자산이 있어도 해당 구획은 이를 사용하지 않을 수 있다. 단순 틈의 관찰과 같은 방향의 근거이나 전체 화면 동일성은 별도 |
|2009 세 채팅 | 유일한 chat-cache.txt의 WINDOW1/3/4는 SHOWN1,2와5–10은0. 각 MESSAGES/CHANNELS 블록 존재 | 세 창 저장·메시지 분담의 실제 원형이다. 배포자 필터를 사용자 선호로 이식하지 않음 |
|Alpha 두 변형 | STANDARD의 kgPanels Normal/Wide는 각4패널, SPECIAL은 각8패널. SPECIAL Wide에는 chat1/chat2/chat3·사각 지도와 Devil2 테두리, 중단 Blizzard Dialog | 같은 ZIP 안에서도 배치가 다르다. SPECIAL Wide가 세 창·분할형의 중요한 설정 근거이며 STANDARD와 합치지 않음 |
|Alpha 중앙 grid | SPECIAL Wide Dominos frame3/4는 각각12버튼·4열. Normal/Wide Masque그룹 SkinID=Onyx | 두4×3블록으로8×3을 만들 수 있다는 구조적 추정은 가능하나 샘플4의 실제 render·버튼 소속은 미확정 |
|테두리 자산 |11파일55쌍 SHA256 대조. Devil/Devil2/roth는 각각2009=Alpha=2022, Devil3는Alpha=2022. TGA헤더128×16 | 여러 세대에 같은 바이트가 보존됐다는 사실이다. 같은 배치·사진 속 자산·현재 지원·재배포 권한의 증거로 확대하지 않음 |
|2022 차이 | 기존 !DevilUI는 Shapa계열 profile명·다른 resolution분기.2022 loaf Masque는 Onyx Classic, Alpha는 Onyx | 명칭을 그대로 구별한다. 공통 border파일로2022 배치를 다시 목표로 삼지 않음 |

2022 loaf의 Masque값은 보존된 `Profile/Masque.lua` 데이터구간29–119의 SkinID행33 이하에서 확인했다. Alpha의 두 kgPanels설정과 Dominos/Masque자료는 위 JSON의 sourceID별로 재조회할 수 있다. 저장된 비율폭·좌표·scale은 당시 환경의 데이터이며 새4K 전체 비율에 적용할 값이 아니다.

[45 원문](https://wow.inven.co.kr/dataninfo/addonpds/detail.php?idx=45)의 최신 첨부행은 `DevilUI6.1Alpha.zip / 6.1.0 / 2015-03-04`로 제공 파일명과 맞는다. 상단 client5.3.0/addon5.3a와 제목6.1Alpha는 별도 값으로 보존했다. 내부 TOC는60100이다. 첨부·내부 세대의 연결은 있지만 publisher checksum은 없고, **최신 ZIP의 어떤 변형이 샘플4를 그대로 만든 build인지는 미확정이다.**2958도 첨부명·client3.3.0·date2009-12-10이 제공 파일과 연결된다. 해시 검사는 외부 공증이 아닌 원본·프로젝트 사본의 동일성 검사다. 근거: `attachment-filename-matches.json`, 각 filesiframe37행과 archive-acquisition.json.

## 채팅 장식과 메시지 동작을 분리한 원형 분석

옛 깨끗한 채팅은 그림 파일 하나가 기능을 대체한 구조가 아니었다. 기본 ChatFrame과 입력창을 유지하면서 별도 모듈이 버튼·탭 질감·입력 테두리를 바꾸고, 저장 설정과 초기화가 창별 위치·필터를 다뤘다. 현재 PC에서 실제로 작동하는 범위는 미검증이다. 후반의 V42 실물 분석은 현재 통합본의 정적 수정 기전이며, Step4의 현재 채팅 제품 선택·지원 검증과 구별한다.

| 요소 | 읽은 실제 기전 | 복원 해석 |
|---|---|---|
|왼쪽 버튼 | DChat168–193/CAN buttons25–47: 메뉴·위아래 버튼 숨김, 휠스크롤 연결 | 외형 축소의 근거다. 아래로 돌아가기 버튼은 스크롤 상태에 따라 남을 수 있음 |
|입력창 | DChat199–213: 위치·기본border3영역 제거,238–266: 새Neon테두리. CAN core323–337: 위치flag,388–423: 활성 입력 배경·기본border숨김 | native 입력은 남는다. 완전 무테·입력창 부재와 다르다. Alpha profile Edit0과 config 기본 Edit1도 구별 |
|탭·제목 | CAN chattab53–99: 텍스처 제거 뒤 SetAlpha1·글자 스타일 | 탭 질감 제거와 글자 완전 숨김은 다르다. DChat만으로 제목 숨김은 근거 미발견. 현재 입력·마우스 상태별 표시는 후속 검증 |
|글꼴·크기 | DChat100–119/CAN core76–80:7..32 선택. CAN Out350–357의13은 OutLine1일 때만 | 큰 고정 폰트가 원형의 필수사항은 아니다. profile의0flag에서 무조건13이라고 단정하지 않음 |
|세 창·필터 |2009 chat-cache305행; Alpha SPECIAL Wide의1/3/4 생성·undock·개별 messagegroups | 세 native 창과 필터를 보존하는 설계의 근거다. 옛 필터 reset코드 전체를 가져오지 않음 |

CAN core에는 SendChatMessage wrapper, Ctrl귓말, 강조·제외 필터, 특정 상황의 파티창 자동숨김도 있다. 시각 복원에 그 동작을 함께 채택할 필요는 없다. initializer의 채팅reset·global uiScale변경·scriptErrors0도 새 구현 명령으로 쓰지 않는다. CAN_Chat.toc의 channelshort.lua 호출과 실파일1channelshort.lua 불일치도 남았다. 현재 호환을 구버전 통째 복사로 보장할 수 없는 실물 근거다. 원문·전체 읽기 범위: `a1-static-source-evidence.md:9–45`.

## 후속 제작에 넘길 수 있는 것과 새로 연결할 것

**확정:** 참고 그림의 실제 순서·분할 구획 차이·세 native창 구성 기전·border/배경 자산 경로·프로필 구조를 회수했다. **분석 판단:** 이 자료는 역할별 addon과 작은 시각 연결부를 설계할 출발점이다. 원본 통합본 전체를 그대로 현재 게임에 복제할 수 있다는 판정은 아니다.

| 범위 | 활용 가능한 입력 | 아직 필요한 별도 작업 |
|---|---|---|
|행동단축바 | Dominos의 frame/anchor/열수/숨김값과 Masque선택명 | 현재 지원판의 단일 담당 addon에서 입력·paging·키 보존 검증.4K버튼 크기→간격→행→바닥 여백 순서의 새 배치값 |
|미니맵 | 아래 사각형 위치·테두리 구획과 texture경로 | 현재 담당 addon 연결과 클릭·zoom·버튼·퀘스트 표시 검증 |
|체력·마나·시전 | 그림의 unit역할·배치 차이와 보존된 profile | 현재 허용 API·선택 addon에서 값 정확성·시전·전투 시험. 정지 그림만으로 기능 완료 판정 불가 |
|배경·구분선 | kgPanels의 비입력 배경·테두리 설정과 동일 바이트 자산 | 새4K 하단 높이에 맞는 구획·경계 접합·클릭 가로채기 없는 연결. 샘플 자산 동일성·사용권한 확인 |
|세 native채팅 | 창 생성·저장·장식 제거 기전 | 사용자 필터 보존·상태별 탭/입력 표시·크기 조정의 현재 지원 검증. Step4에서 공식 source 검토 |

현재 addon 설치·최종 선택, 소형 theme 코드, 새 미리보기, 게임 설정 변경은 이 보고서로 승인되지 않는다.13140 제작자 선언은 참고 근거이며 공식 upstream 지원·이 PC의 runtime 통과와 구별한다.

## 검증 상태와 남은 한계

| 항목 | 상태·분모 | 근거 |
|---|---|---|
|게시물 독해 | 확정34/34, 모든 본문·notes·metadata | a1-article-read-coverage.json: 원문·selector·행·해시 |
|이미지 관찰 | 확보50/50hashes·성공 연결56/58 확정; 실패2 미관찰 | findings.md1–426와coverage.json |
|전체 요청 이미지 |8906 두 장 원본·thumb404, Wayback4조회capture없음 | images-v2/thumbnail-fallbacks/idx8906-wayback-fallback.json |
|원본 보존·안전 추출 |제공2ZIP 검사 재사용; 추가 V42/1932/3461 정적 추출, X2 전체 차단·46개 선택 추출 | archive-checks 및 acquisition/r36/ 각 검사·보존 영수증 |
|핵심 코드·설정 |초기 코드·literal9자료에 더해 R36 관련37파일 읽기, 추가8+X2선택20자료 전체 파싱·필요 키 조회. V42설정3개 전체 파싱 아님 | a1-static-source-evidence.md, a1-r36-source-evidence.md, a1-r36-code-read-coverage.json |
|샘플4·ZIP 동일build | 미검증; 파일명·첨부·TOC만 연결 |45iframe·내부60100·변형 여러 개 |
|탭 완전숨김·현재Forever지원·실제입력/필터/전투 | 미검증; Step4·후속runtime 별도 | 구코드·metadata를 현재 작동 근거로 쓰지 않음 |
|독립 검수 | 대기; A1 자체확인은 최종 수용 아님 | master가 같은Phase B 발주 예정 |

원문 URL·보존 위치·읽은 행·관찰 해시·실패 경로는 위 근거 파일에 연결했다. A1의 구성·설계 추정은 따로 표시했으며 사용자 최종 승인이나 현재 작동으로 보고하지 않았다.

## R36 추가 원본 조사 결과

사용자 요청에 따라 제공한 두 ZIP 외에도 자료실의 관련 배포본을 직접 확보·대조했다.45의172개 첨부를 정리해2008 X2 R3.4를 선정했고,1932의2008 개인 Black·3461 BlackEdition2 Alpha·13140 Forever V42도 비교했다.2582의 현재 첨부 목록은0개여서 그 자체를 옛 파일 부재의 증거로 쓰지 않았다. 최초 날짜형 후보 주소 네 개는404였지만 관찰된 옛 공개 경로를 이용해 X2 후보 한 개를 실제 회수했다. 성공 뒤 R1/3.05 추가 탐색은 하지 않았다. 기존34본문·50그림·성공 압축 검사는 재사용했고, 원본 코드·설치기는 실행하지 않았다.


### 현재 Forever V42 실물에서 확인한 차이

idx13140의 실제 공개 첨부 `_forever_V42.zip`을 새로 확보했다.9,897,762B, SHA256 `7961B3AE6C308256345BE4DBE732019276AC04B0C123F63AB198B8F5A759A908`이며, 단1회 CRC·안전 경로·추출 대조로1,831파일/52,281,213B를 회수했다. 제작자 표기만 본 상태에서 한 단계 더 나아가, core1,905행과 채팅·배치 연결 파일1,203행을 실제로 끝까지 읽었다. 원문 경로·해시·인용행은 `a1-r36-source-evidence.md:5–38`이다. 목표 그림은 여전히45샘플4이며 V42 외형으로 바꾸지 않는다.

| 확인점 | 실제 코드 근거 | 복원에 주는 의미 |
|---|---|---|
|호환 처리 | Devilconfig/ForeverCompat.lua4–29: C_AddOns/global 함수 선택, 전투 중 설정 차단, gradient/resize 대체 호출 | 실제 수정 기전이 있다. 해당 API의 현재 PC 작동을 검증한 것은 아님 |
|창 수의 변형 차이 | !DevilUI.lua308–354: Wide/Wide_WH는 보조창2개, Wide_B는 singleChat=true.4–47에는 GamePad/Tablet도 별도 | 모든 변형이 세 창인 것은 아니다. 이름만으로 같은 profile 취급 금지 |
|메시지 처리 | core1174–1184는 보조창 group/channel을 지운 뒤 분류를 다시 설정하고 일반창에서도 해당 group을 제거. minimap.lua815–838은 일반·전투창 분류도 초기화 | 세 native 창을 만드는 기전은 참고할 수 있지만, 외형 복원에 이 필터 변경을 함께 가져오면 사용자 설정을 보존하지 못함 |
|탭·입력 | core1199는 tab:Show(). 이번 core·배치 파일만으로 좌측 버튼·제목·입력창 장식의 완전 제거는 입증되지 않음 | 세 창 배치 기능과 깨끗한 채팅 외형의 완성을 구분. 현재 해결법 최종 판단은 Step4 |
|위치·크기 저장 | core765–806의 기본 EditMode 저장과 minimap.lua197–226/487–513의 배치·저장 연결. 일부 경로는 화면폭·높이의 fraction 사용 | 연결 순서와 저장 기전은 참고하되4K 전체 비율 환산값은 채택하지 않음 |
|설치 범위 | core1618/1643–1644/1667: 여러 profile import, uiScale0.7 또는0.9, Reflux 전환 | 외형만 가져오는 작은 연결과 통합 설치를 구별. 이 초기화는 실행하지 않았음 |
|PitBull 표기 | PitBull4.toc2/19는1.60.1 build70291·4.2.49-Forever-v42를 선언 | 과거 이 PC 관찰70938과 다르다. 통합본 코드 존재·제작자 선언이 독립 upstream 지원 또는 이 PC runtime 통과가 되지는 않음 |

A1 판단은 **원형 자료와 현재 적응 코드에서 필요한 연결만 골라 설계할 근거가 생겼다**는 수준이다. V42의 설치·필터 초기화·화면 배율까지 복제하는 방식은 사용자 요구를 충족했다는 근거가 아니다. 현재 채팅 외형을 맡길 모듈과 각 요구의 지원 여부는 Step4에서 따로 검토한다.


### 다른 제공 게시글의 압축 실물 비교

1932의 실제 공개 주소에서 분할 RAR 두 개,3461의 실제 공개 주소에서 별도 BlackEdition2 Alpha ZIP을 확보했다.1932 part1 주소는 원문에 있던 파일명과 part2의 실제 경로를 조합한 후보였고, 실제 HTTP200·RAR 형식을 확인했다. 후보 주소였다는 출처 구분을 성공 뒤에도 유지한다. 세 파일 모두 SourceArchive의 별도 originals 폴더에 보존했으며 원본·사본 해시가 같다. 원문·취득 기록은 `acquisition/r36/other-posts/{package-acquisition.json,preserved-original-copies.json}`, 코드·설정의 실제 읽기와 인용은 `a1-r36-source-evidence.md:44–79`다.

| 배포본 | 실제 회수·검사 | 사진과 구별할 실물 차이 |
|---|---|---|
|1932 / 2008 Black CUSTOM | part1 5,242,880B+part2 3,202,564B. 기존 Bandizip 목록·손상 검사·안전 추출로2,407파일/38,791,956B, 파일별·총 바이트 일치 | 저장 채팅은1번만 SHOWN1이고3/4번은0. eePanels2 패널6개 중 Chat1만 채팅 이름, 경계 texture는 Interface\None. Bartender4/Vol II 계열. 세 창 원형과 같지 않음 |
|3461 / BlackEdition2_6.1Alpha | ZIP7,626,408B→내부 EXE 한 개. EXE 실행 없이 NSIS 정적 추출2,936파일/40,624,475B. 목록 크기−1이라 바이트 합계 동일성은 미확인 | 초기화는 일반1+보조3 두 메시지창, 위쪽 사각 지도. kgPanels 세 layout 각각5패널·Devil2/edge10/mouse=true. Masque Darion Clean으로 제공Alpha의 Onyx와 다름 |

1932의 SisterChatMods는 메뉴·스크롤 버튼을 숨기고 native 입력창을 이동하며, NeonChat은 기본 입력 테두리를 지운 뒤 채널색 테두리를 다시 만든다. 실제 저장값도 MoveEditBox=false, Neon border1/background0.75다. 이름의 chatFade는 코드에서 메시지 SetFading을 호출하므로 전체 창·탭 자동숨김으로 해석하지 않았다.3461의 CAN 공통 코드7개는 제공Alpha와 바이트가 같지만 초기화·설정 연결은 다르다. 특히 profile XML이 부르는 CAN_Chat.lua가 실제 Profile 폴더에 없어, 제공Alpha의 설정 flag를 이 배포본에서 불러온 값이라고 주장할 수 없다. 원본의 문제는 고치거나 실행하지 않았다.

추가 설정8개는 전체 literal token을 소비했고 중복 키0을 확인했다. 배포자 이름·캐릭터 대응표와 닉네임 자료는 전달용 compact JSON에서 명시적으로 제외하고, 원문·전체 파싱 자료는 보존했다. V42의 세 profile 데이터는 뒤따르는 Wide_T 대입에서 파서가 멈춰 **전체 파싱으로 세지 않았으며 최종 값·총계도 사용하지 않았다**. 현재 코드·배치 파일의 직접 읽기 근거와 구분했다.


### 2008 X2 SPECIALW와 기억한 외형의 연결

`DevilUI-X2 R3.4.zip`은 관찰된 옛 공개 경로와 실제 첨부 파일명으로 구성한 후보 주소에서 HTTP200으로 회수했다.7,245,308B이며 원본·보존 사본 해시가 같다. 내부 EXE는 실행하지 않았다. 기존 도구의 목록에서4,217개 중288개 경로가 Windows에 부적합하게 읽혀 **전체 추출은 차단**했다. 원래 이름의 문제인지 도구의 NSIS 해석 문제인지는 미검증이다. 정확히 검증한 관련46개만 별도 안전 추출했고940,901B·누락/예상 외/링크0을 확인했다. 전체 복구 성공으로 세지 않는다. 근거: `acquisition/r36/legacy-prefix-fallback/`과`x2-selected-subset/X2_SUBSET_READY.json`.

| X2 변형 | 저장된 표시 채팅창 | 실제 패널 설정 |
|---|---|---|
|SPECIALW |1·2·3 세 개.2/3은 undocked |eePanels2 9패널에 chat1/chat2/chat3, 좌우 angel/demon, 중간18높이 띠·아래19높이 띠. 모두 mouse=false |
|SPECIAL |1·2 두 개 |8패널, chat1/chat2 |
|STANDARD / STANDARDW |각1번 한 개 |각5패널. SPECIALW의 세 chat 패널과 구별 |

SPECIALW의 Bartender3 Bars3/4는 각각 Rows3이다. 공통 기본값 Buttons12가 적용된다면 두4×3블록이 되어 그림의 약8×3 배열과 구조적으로 맞는다는 **추정**은 가능하다. 하지만 실제 버튼 소속·render·샘플4와 같은 build임을 검증한 것은 아니다. 당시 cyCircled 스킨은 `Onyx: Square Gloss`로, 제공Alpha의 Masque `Onyx` 및3461의 `Darion Clean`과 구분한다. 세 채팅·양끝 장식·중간/바닥 띠의 원형 설정을 실제 회수했다는 점이 핵심이다. 네 변형을 합치거나 옛 채널 분담·배율·좌표를 사용자4K에 자동 이식하지 않는다. X2 SPECIALW는 창1/2/3, 이후Alpha SPECIAL은1/3/4를 쓰며 현재V42는2번을 전투창으로 다룬다. 보존할 것은 독립 메시지창 세 개의 역할이지 옛 숫자 ID의 일괄 복사나 특정 채널 분담이 아니다.

SisterChatMods·NeonChat·폰트 선택 모듈까지 직접 읽었다. 메뉴·위아래 버튼 숨김과 휠스크롤, 기본 입력 테두리 제거 뒤 새 채널색 테두리,7~24 폰트 선택이 확인된다. 완전 탭 숨김과 입력 중·마우스 상태별 현재 동작은 미검증이다. X2에서 선택한 설정20개는 전부 literal 파싱했고4개 변형을 구별했다. 자산은8개 바이트/헤더만 확인했으며 사진 관찰로 세지 않았다. 상세 원문·행·분모는 `a1-r36-source-evidence.md`의 현재 결과와 `a1-r36-code-read-coverage.json`에 있다.

A1의 현재 판단은 **45샘플4를 시각 기준으로 유지하면서 X2 SPECIALW와 제공Alpha SPECIAL의 실제 구성에서 필요한 역할·장식 기전을 회수해 새 연결을 설계할 수 있다**는 것이다. 서로 다른 세대의 설정을 통째로 합칠 근거는 없다. 정확한 build 동일성·현재 지원·게임 입력/필터·전투·자산 재사용 권한은 확인된 것으로 올리지 않았다. 현재 채팅 해결법 최종 조사는 Step4, 새4K 배치와 게임용 코드는 이후 범위다.

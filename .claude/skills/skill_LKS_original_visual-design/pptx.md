<!--ih-->

# PPT 저작 워크플로

> **이 파일 = visual-design 의 PPTX 어댑터.** 시각·콘텐츠 배치 규칙의 원본(제1원칙 압축→시각 배치·통일성·단일 소스 토큰·타이포 위계·접근성·다이어그램 의미 정확성·레이아웃 의도 축)은 **visual-design 코어**(`core_principles.md`·`accessibility.md`·`verification.md`)에 있고, 이 스킬은 그 코어를 PPTX(pptxgenjs·source-first·3-게이트)로 구현한다. 코어 규칙을 여기서 되풀이하지 않고 각 절 상단 포인터로 가리킨다(역방향: visual-design SKILL.md 매체 라우팅표가 PPTX 매체 → 이 스킬로 가리킨다).

이 스킬은 **무엇을 어떤 순서로 만들고 어떻게 검증하는가**를 규정한다. 슬라이드 내용·구조 규칙은 `references/pptx/content_rules.md`, 검증 절차와 도구 사용법은 `references/pptx/qa_procedure.md`, 카탈로그형 덱 규칙은 `references/pptx/catalog_deck_rules.md`에 있다. 세 파일은 이 워크플로가 지시하는 지점에서 정독한다.

## `skill:skill_LKS_custom_document` `references/pptx/GUIDE.md` 와의 구분

둘 다 .pptx를 다루므로 겹쳐 보인다. 나누는 기준은 **무엇을 판단하느냐**다.

| | 이 스킬 | `skill:skill_LKS_custom_document` `references/pptx/GUIDE.md` |
|---|---|---|
| 맡는 것 | **무엇을 어떤 순서로 말할지** — 논리·제목·근거·문체·검증 | **파일을 어떻게 읽고 쓸지** — 포맷·템플릿·발표자 노트·기존 파일 읽기 |
| 부를 때 | 덱을 새로 설계하거나 기존 덱의 **품질**을 올릴 때 | 기존 .pptx를 **읽거나 기계적으로 편집**할 때 |

- 기존 덱을 **읽어야** 하면 먼저 `skill:skill_LKS_custom_document` `references/pptx/GUIDE.md`(필요 시 `skill:skill_LKS_custom_document` `references/decrypt/GUIDE.md`)로 내용을 확보하고, **구조를 고치는 단계부터** 이 스킬로 넘어온다.
- 새 덱을 처음부터 만들 때는 이 스킬만 쓴다.

## 적용 범위

- **적용**: 논리·근거를 평가받는 자료(기술 사양서, 연구 결과, 조직 보고, 제품·패키지 설명서, 교육 자료).
- **비적용**: 발표 없이 읽히는 장문 보고서(그건 문서로 쓴다), 1~2장짜리 즉석 공유물.

## 산출 원칙 — source-first

**PPTX 파일을 직접 편집해 완성본으로 삼지 않는다.** 재현 가능한 소스(`deck.js` + pptxgenjs)를 만들고 그것을 실행해 PPTX를 생성한다. 수정은 소스를 고쳐 재생성한다.

이유: 슬라이드를 하나씩 손대면 전체 구조·간격·타이포가 슬라이드마다 어긋나고, 되돌릴 수도 없다. 소스가 있으면 일괄 수정·버전 관리·재현이 된다.

- 생성 라이브러리: **pptxgenjs**(PPTX 네이티브 — 받는 사람이 편집할 수 있다).
- **금지**: Marp·Slidev의 PPTX 출력(슬라이드를 이미지로 굽기 때문에 텍스트 편집·선택 불가), `python-pptx`로 생성(검사 용도만 허용).
- 기존 덱을 개선할 때도 소스가 있으면 소스를 고친다. 소스가 없으면 **0-b단계**로 복원한 뒤 진행한다.

## 작업 폴더

시작하기 전에 폴더를 정한다. **1단계부터 나오는 산출물은 전부 `out/` 아래에 만든다** — 나중에 옮기지 않도록 처음부터 그렇게 둔다.

```
<작업폴더>/
├── package.json          npm install pptxgenjs 를 여기서 한다
├── node_modules/
└── out/                  1~7단계 산출물 전부 (목록 = references/pptx/qa_procedure.md §산출물)
```

`deck.js`도 `out/` 안에 두고 **작업 폴더 루트에서** `node out/deck.js`로 실행한다. `require("pptxgenjs")`가 작업 폴더의 `node_modules`를 찾아야 하기 때문이다.

## 워크플로

각 단계의 산출물은 파일로 남긴다. 대화에만 남기면 세션이 바뀔 때 복구할 수 없다.

### 0. 환경 확인
도구는 외부 라이브러리를 번들하지 않는다. 없으면 4단계에서 막히므로 먼저 확인한다. **작업 폴더에서** 실행한다(모듈은 현재 디렉터리 기준으로 찾는다).

```
npm install pptxgenjs                        # 작업 폴더에 설치. 전역 설치는 require가 못 찾는다
node -e "require.resolve('pptxgenjs')"       # 경로가 찍히면 정상
python -c "import PIL"                       # 없으면: python -m pip install Pillow
python -c "import pptx"                      # 폰트 검사용(선택): python -m pip install python-pptx
powershell -c "New-Object -ComObject PowerPoint.Application | Out-Null; 'PowerPoint OK'"    # 로컬 Windows PC 의 렌더 엔진 — Windows 밖은 건너뛴다
dpkg -s libreoffice-impress >/dev/null && echo "Impress OK"                                 # 클라우드·로컬 리눅스의 렌더 부품(Mac = `command -v soffice`) — Windows 는 건너뛴다
command -v pdftoppm || python3 -c "import pypdfium2; print('pypdfium2 OK')"                 # 클라우드 래스터라이저(이 어댑터의 Windows 경로는 COM 이 PNG 를 바로 냄 · pypdfium2 는 설치본에선 pdfplumber 와 함께 깔림) — 둘 다 없으면: python3 -m pip install pypdfium2
```
렌더 엔진은 **환경이 정한다** — 설치된 엔진을 탐지해 고르지 않는다.

| 환경 | 렌더 엔진 | 판정 지위 |
|---|---|---|
| **로컬 Windows PC** | PowerPoint COM(`tools/render_pptx.ps1`) — 모든 로컬 Windows PC 에서 쓸 수 있다고 전제 · `soffice` 가 있어도 쓰지 않음 | 최종(실제 PowerPoint 렌더 · 서체 대체 없음) |
| **클라우드(리눅스 컨테이너)** | LibreOffice(Impress 부품) → PDF → 래스터(`pdftoppm` · 없으면 pypdfium2) | 근사 미리보기(서체 대체로 줄바꿈 근사) · 확정은 Windows COM |
| **Windows 밖 로컬 PC**(Mac·Linux — PowerPoint COM 없음) | 클라우드 행과 같은 경로(`soffice` 가 PATH 에 있어야 함) | 클라우드 행과 같음 |

- Windows PC 에서 COM 이 안 됨 = **전제 위반** → 게이트 2·3 **미실행** 기록 + 사용자에게 알림 · LibreOffice 로 대체하지 않음
- 클라우드·Windows 밖 로컬 PC 에 LibreOffice 부품 없음 → 설치(리눅스 = `sudo apt-get install -y libreoffice-impress`) · 설치 불가 = **미실행** 기록
- 명령·산출 경로 → `references/pptx/qa_procedure.md` §2-1 렌더

### 0-b. 기존 덱에서 소스 복원 (소스가 없을 때만)
원본 `.pptx`는 건드리지 않고 **사본에서** 읽는다(규범 = `memory:feedback_workspace_git_safety` · 절차 = `skill:skill_LKS_original_project-scaffold`).

1. python-pptx로 슬라이드별 shape를 덤프한다 — 종류 · `(left, top, width, height)`(EMU를 인치로: ÷914400) · 텍스트 · `font.size`·`font.name`·색.
2. 덤프에서 **반복되는 값**을 찾아 토큰과 자리표시자로 올린다(같은 x가 여러 슬라이드에 나오면 그것이 여백 기준선이다).
3. `deck.js`를 그 토큰으로 재구성한다. 좌표를 슬라이드마다 그대로 베끼면 복원이 아니라 복사다 — 어긋난 정렬까지 함께 옮겨진다.
4. 재생성한 덱을 렌더해 원본 렌더와 나란히 비교한다. 내용이 같고 정렬이 정돈됐으면 복원 완료.

### 1. 원본 전수 정독 → `source_coverage.md`
제공된 모든 원천 문서를 **처음부터 끝까지** 읽는다. 앞부분과 끝부분만 보고 중간을 추론하지 않는다. 분량이 크면 구간을 나눠 전 구간을 읽는다.
기록: 파일명 · 읽은 범위(행·페이지) · 추출한 사실 · 그 사실을 어느 슬라이드에 쓸지.
**없는 수치·인용·메커니즘·결론을 만들어 넣지 않는다.** 근거를 못 찾으면 "근거 미발견"으로 적는다.
→ 상세 규율 = `memory:feedback_full_file_read_required`

**원천 문서가 없는 경우**(구술·기억으로만 만드는 덱)에도 이 파일은 만든다. 표를 비우는 대신 각 사실의 출처를 `요청자 구술`·`작성자 지식`으로 적어 둔다. 게이트를 다 통과해도 **사실 검증은 받지 않은 덱**이라는 것을 남겨야, 나중에 그 덱을 근거로 쓰는 사람이 오해하지 않는다.

### 2. 청중·목적 확정 → `deck_brief.md`
청중(지식 수준·해당 도메인 경험) · **청중이 이미 아는 용어 목록** · 목적 · 발표 시간 또는 배포 형태 · 결론 · 그 결론을 지지할 증거 목록.
- 용어 목록은 필수다. 이 목록에 없는 용어가 곧 정의 대상이 된다(→ `references/pptx/content_rules.md` §6).
- 결론은 **덱 하나에 하나**를 기본으로 하되, 장문 설명서처럼 단일 결론이 성립하지 않는 덱은 **부별 결론**으로 적는다.
- **청중이 그 도메인을 처음 접한다면, 어려운 내용을 쉽게 바꾸는 것이 아니라 낯선 용어를 정확히 정의한다.** 하향 조정은 지적 수준을 오판하는 것이다.

### 3. 슬라이드 개요 → `slide_outline.md`
**이 단계 전에 `references/pptx/content_rules.md` §1~§5·§10(덱 구조)을 읽는다.** 한 슬라이드에 무엇을 담을 수 있는지(역할 하나·근거 하나·4요소 세트)가 개요를 좌우한다. 4단계에 가서 읽으면 확정한 개요를 다시 뜯게 된다.

슬라이드별 **action title(결론 문장)** + 담을 증거 유형(표/그림/식/코드)을 나열한다.
**제목만 읽기 검사**: 제목만 순서대로 읽어 논증이 성립하는지 확인한다. 성립하지 않으면 개요를 고친 뒤에 다음 단계로 간다.
슬라이드가 **10장을 넘으면** 여기서 개요를 **평문으로 제시하고 곧바로 다음 단계로 진행한다**(사용자 이견이 오면 그 시점에 반영 — 정지 아님 · 확인 팝업 도구 금지). 10장 이하면 제시 없이 진행한다.

**덱 유형 분기**: 구성물 N개(스킬·메모리·모듈)를 규격 페이지로 나열하는 **카탈로그·레퍼런스형 덱**이면 `references/pptx/catalog_deck_rules.md`를 함께 정독한다. 그 유형에서는 제목 형식(위 "제목만 읽기 검사"의 논증 전제 포함)·표 셀 문체·타이포 스케일·레이아웃 반복 여부 등 `references/pptx/content_rules.md`·`references/pptx/qa_procedure.md`의 일부 조항이 그 파일 §12 표대로 **덮어쓰인다** — 이 유형에 기존 규칙(특히 action title·본문 27pt 하한·레이아웃 반복 금지·표 셀 문장 금지)을 그대로 적용하면 틀린 덱이 나온다.

### 4. 소스 작성 (`deck.js`)
`references/pptx/content_rules.md`를 정독하고 그 규칙을 적용해 작성한다. 수치·색·문체 규정은 그 문서가 정의하며 여기서 되풀이하지 않는다.
- 캔버스를 `defineLayout`으로 **명시 선언**한다(§캔버스 주의).
- 디자인 값(색·폰트 크기·여백·그리드)은 **토큰으로 한 곳에 모은다**. 슬라이드 코드에 리터럴을 흩뿌리지 않는다.
- **색 = 발표 팔레트(투사용 고채도)** — 웹 팔레트(구조색 저채도 예산)를 덱에 들여오지 않고, 덱 팔레트를 웹으로 옮기지 않는다(원본 = 코어 `core_principles.md` §2 「매체 간 토큰 이식 금지 — 색 포함」 · 채도 예산의 PPTX 제외 = `accessibility.md` §2-2 · 덱 토큰표 = `references/pptx/content_rules.md` §8).
- 표·차트·코드·수식은 **편집 가능한 네이티브 요소**로 만든다(`addTable`·`addChart`·도형 조합). 스크린샷 이미지로 대체하지 않는다.
- 반복 레이아웃은 `pptx.defineSlideMaster({ title: "BODY", objects: [...] })`로 정의하고 `pptx.addSlide({ masterName: "BODY" })`로 쓴다. 슬라이드마다 좌표를 새로 적으면 정렬이 어긋난다.
- **게이트 1 호출을 이 단계에서 함께 넣는다** — 슬라이드마다 `reportSlide()`, `writeFile()` 앞에 중단 분기. 지금 `references/pptx/qa_procedure.md` §게이트 1을 열어 형식을 그대로 가져온다.
- 서체는 `fontFace: "Malgun Gothic"`처럼 **요소마다 명시**한다. 그림·도형에는 `altText: "…"`를 넣고, 뜻이 없는 도형은 `altText: ""`로 비운다.

### 5. 게이트 1 실행 — 정적 린트 (렌더 전)
생성 스크립트를 실행해 **캔버스 이탈·텍스트 겹침·상자 넘침·표 셀 단어 중간 끊김**을 잡는다. 렌더하지 않고 좌표만으로 판정하므로 비용이 없다.
의도적 예외 표시(`fullBleed`·`overlapOk`·`overflowOk`·`wordbreakOk`)와 판정 기준은 `references/pptx/qa_procedure.md`에 있다.

| 표 셀 검사 | 내용 |
|---|---|
| 판정 | 셀의 공백 없는 가장 긴 토큰 폭 > 열 폭 − 좌우 셀 여백 → **FAIL**(`wordbreak` · 단어 중간 끊김) |
| 빠듯함 | FAIL 은 아니나 그 토큰 폭이 가용 폭의 80% 초과 → **WARN**(`wordbreak` · 추정 오차로 끊길 수 있는 대역) — WARN 은 Windows PowerPoint 렌더로 확정 |
| 결함 아님 | 여러 줄 감김(행 높이만 늘어남) — 오탐을 줄이려고 판정을 끊김 하나로 좁힘 |
| 고치는 법 | 열 폭 재배분(합계 = 본문 폭 유지) · 글자 크기 · 토큰 안에 끊을 자리(공백·줄바꿈) |
| 한계 | 글자 폭은 추정(전각 1.0·반각 0.5) — 경계선 근처는 게이트 3 렌더로 확정(FAIL 이 거짓으로 의심되면 그 셀에 `wordbreakOk` + 사유 주석을 달아 생성한 뒤 Windows PowerPoint COM 렌더로 확정 · 끊기면 표시를 빼고 열 폭을 고친다 — `references/pptx/qa_procedure.md` 「심각도」) |

### 6. 게이트 2·3 — 렌더 후 검증
`references/pptx/qa_procedure.md` 절차대로 렌더 → 기계 검사 → 시각 검수를 수행한다. 반복 라운드와 검증 절차(③ 구조 변경 = 관점 10개로 10라운드 · ①·②·④ = 갈래별 검수 · 조기 종료 없음)도 그 문서를 따른다.

렌더 엔진은 0단계 표대로 환경이 정한다. 클라우드 경로(리눅스 컨테이너·Windows 밖 로컬 PC)의 어댑터 고유 사항:

| 항목 | 내용 |
|---|---|
| 변환 명령 | 원본 = `skill:skill_LKS_custom_document` `references/pptx/GUIDE.md` 「Converting to Images」 · 이 워크플로 산출 경로(`out/render/<시각>/png/slide-NN.png` — 렌더마다 새 폴더)에 맞춘 명령 = `references/pptx/qa_procedure.md` §2-1 |
| 부품 | `libreoffice-impress` — LibreOffice 코어만으로는 pptx 를 열지 못함(설치 = 0단계) |
| 서체 | Malgun Gothic 부재 → 대체 서체 → 줄바꿈 위치 근사 · 감김·넘침의 최종 판정 = 로컬 Windows PC 의 PowerPoint(COM) 렌더 |

### 7. 산출
산출물 목록과 **완료 선언 조건**은 `references/pptx/qa_procedure.md` §산출물 · §완료 선언 조건이 정의한다. 여기에 더해 `references/pptx/content_rules.md` §11 표를 **전 슬라이드에 대해** 통과시킨다 — 게이트는 공정만 보고 내용은 보지 않는다. 그 조건을 전부 만족하기 전에는 완료라고 적지 않는다(클라우드 경로로 근사 렌더까지 마친 덱의 끝 상태 = `references/pptx/qa_procedure.md` §완료 선언 조건 「클라우드 끝 상태」). (카탈로그·레퍼런스형 덱은 §11 대신 `references/pptx/catalog_deck_rules.md` §13 표를 쓴다.)

## 선택 패턴 — 발표자가 진행하는 덱 (필수 아님)

| 패턴 | 방법 | 조건·주의 |
|---|---|---|
| **강조는 아낄수록 강함** | 같은 페이지 여러 벌 · 벌마다 박스 **하나만** 강조(색 + 테두리 두께 이중 인코딩) · 첫 벌 = 강조 없는 설명용 · 강조 벌 바로 다음 장 = 그 박스의 상세 | 강조 벌 뒤에 상세 장이 오므로 리듬 항목(`references/pptx/qa_procedure.md` §3-2 항목 2 · `references/pptx/content_rules.md` §9)과 양립 |
| **빈칸(백지) 슬라이드로 구획** | 구획 사이에 화면을 완전히 비운 장 · 제목·쪽번호 없음 → 청중 시선을 발표자로 | 제목 단 구획 표지(`references/pptx/content_rules.md` §10)와 다른 장치 · 게이트 2 빈 슬라이드 검사는 의도한 빈칸과 렌더 실패를 픽셀로 구분하지 못한다 → 그 장 번호를 `qa_slides.py --allow-blank 12,30` 처럼 적으면 `빈칸(의도)`로 보고(적지 않은 빈 장은 그대로 `FAIL:blank`) · 내용 점검(`references/pptx/content_rules.md` §11 제목 행)·`slide_outline.md` 에서도 이 장은 `빈칸(의도)`로 적고 제목 판정에서 뺀다 |

## 캔버스 주의 (작업 전 필수 확인)

pptxgenjs의 `LAYOUT_16x9`는 **10″×5.625″**, `LAYOUT_WIDE`는 **13.333″×7.5″**다. 포인트(pt)는 절대 단위이므로 **10″ 기준으로 정해진 글자 크기를 13.333″ 캔버스에 그대로 쓰면 상대적으로 25% 작아 보인다.**

**기본값은 13.333″×7.5″**다. 이 값을 `defineLayout`으로 명시 선언하고 시작한다 — 도구의 기본값(`pptx_lint.js`)과 `references/pptx/content_rules.md`의 타이포 표가 모두 이 기준이다.

기본값을 벗어나는 경우는 하나뿐이다. **조직 표준 템플릿이 10″로 고정돼 있을 때**, 그때만 10″로 선언하고 `references/pptx/content_rules.md`의 pt 값을 ÷1.333로 되돌려 쓴다. 어느 쪽을 택했는지 `deck_brief.md`에 한 줄 적는다.

## 관련 규율 (중복 서술하지 않고 여기로 위임)

- 원본 전수 정독·"200줄만 보고 정독 완료" 금지 → `memory:feedback_full_file_read_required`
- 단위별 작업 루프(규범 원본 `memory:feedback_unit_loop`)·N회 가변청크 검수(`memory:feedback_chunked_review` · 수치 `memory:feedback_review_chunk_discipline`)·컴팩션 복구(`memory:feedback_compaction_recovery`) — 절차·양식은 `skill:skill_LKS_original_plan-execution`·`skill:skill_LKS_original_review-chunking`
- 검수 라운드·관점(고정 5 프리셋 + 가변 5)·청크 스킴 → `skill:skill_LKS_original_review-chunking`
- 원본 불가침(기존 덱을 덮어쓰지 않고 사본에서 작업) → `memory:feedback_workspace_git_safety`(절차 = `skill:skill_LKS_original_project-scaffold`)

## 경로 규약

| 종류 | 표기 | 설치 후 실제 위치 |
|---|---|---|
| memory | `memory:feedback_<전체 이름>` | `~/.claude/BADA_HUB/feedback_<전체 이름>.md` |
| 스킬 | `skill:이름` | `~/.claude/skills/이름/` |
| 도구 | `tools/파일명` | `~/.claude/tools/` |

도구는 작업 디렉터리와 무관하게 쓸 수 있도록 **절대 경로로 호출**한다(`<설치경로>/tools/…` · `<설치경로>` = `SKILL.md` 「도구 경로」). 설치 위치가 다르면 그 경로로 바꿔 쓴다.

검수 규율은 **스킬 포인터**로 가리킨다 — `skill:skill_LKS_original_review-chunking`. 포인터가 유효한지의 판단 기준은 "설치 위치 `~/.claude/skills/<이름>/` 에 그 스킬이 실재하는가" 하나다. 실재하지 않는 이름을 가리키면 그 포인터는 런타임에 아무것도 가리키지 못하므로, 포인터를 바꾸기 전에 반드시 확인한다.

## 참조 파일

| 언제 읽나 | 파일 |
|---|---|
| **2단계 청중 확정 전** (청중 대응·용어 정의) | `references/pptx/content_rules.md` §6 |
| **3단계 개요 전** (논리·제목·근거·4요소·덱 구조) | `references/pptx/content_rules.md` §1~§5 · §10 |
| **4단계 소스 작성 전** (문체·타이포·여백·색·구조) | `references/pptx/content_rules.md` §4~§10 |
| **3·4단계** (카탈로그·레퍼런스형 덱일 때) | `references/pptx/catalog_deck_rules.md` §1~§3·§12 → 전체 |
| 피드백 라운드 운영 (카탈로그형 덱 검수 루프) | `references/pptx/catalog_deck_rules.md` §10 |
| **4단계** — 게이트1 호출 형식 | `references/pptx/qa_procedure.md` §게이트 1 |
| 5~6단계 검증 (게이트 절차·도구 사용법) | `references/pptx/qa_procedure.md` |
| 7단계 — 산출물 목록·완료 조건 | `references/pptx/qa_procedure.md` §산출물 · §완료 선언 조건 |
| 배포 전 내용 점검 | `references/pptx/content_rules.md` §11 (카탈로그형 덱은 `references/pptx/catalog_deck_rules.md` §13 표로 대신) |
| **도구를 고쳤을 때** (`pptx_lint.js`·`qa_slides.py`·임계값 — 역테스트 두 벌) | `references/pptx/qa_procedure.md` §게이트 1 「도구를 고쳤을 때」 · 게이트 2 역테스트 명령·기대 판정 = `references/pptx/ATTRIBUTION.md` §3 「임계값을 바꿨을 때 다시 확인하는 법」(역테스트 두 벌은 패키지 저장소에서만 돈다) |
| 출처·라이선스 확인 | `references/pptx/ATTRIBUTION.md` |
<!--/ih-->

---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_custom_document
description: >
  문서 파일 우산 스킬. Word(.docx·.dotx)·PDF·PowerPoint(.pptx·.potx)·스프레드시트(.xlsx·.xlsm·.xltx·.csv·.tsv)
  파일이 입력이든 출력이든 걸리면 쓴다 — 기존 파일 읽기·내용 추출·재구성,
  새로 만들기(보고서·메모·편지·템플릿·덱·피치 덱·발표 자료·스프레드시트),
  고치기(편집·찾아 바꾸기·이미지 넣기/바꾸기·변경 추적·주석·목차·제목 단계·머리글·레터헤드·쪽 번호·열 추가·수식·서식·차트·지저분한 표 정리[깨진 행·잘못 놓인 머리행]·슬라이드 합치기/나누기·레이아웃·발표자 노트),
  형식 변환. PDF 합치기·나누기·회전·워터마크·양식 채우기·암호 걸기/풀기·이미지 추출·스캔 PDF OCR 도
  여기다. 작업 전에 라우팅 표로 형식을 고르고 그 하위 문서(references/<형식>/GUIDE.md)를 전문으로
  읽는다 — 기존 파일 읽기는 decrypt 하위 문서가 먼저다. 표 데이터가 있어도 결과물이 HTML 보고서·단독
  Python 스크립트·데이터베이스 파이프라인·Google Sheets API 연동이면 쓰지 않는다 · Google Docs·문서
  파일과 무관한 일반 코딩도 아니다.
  덱·문서의 논리·제목·근거·문체·겉보기 설계는 skill_LKS_original_visual-design.
  트리거: "Word", "워드", "docx", "PDF", "PowerPoint", "파워포인트", "pptx", "덱", "deck",
  "slides", "슬라이드", "presentation", "발표 자료", "Excel", "엑셀", "xlsx", "csv", "스프레드시트",
  "spreadsheet", "문서 읽어", "표 추출", "보고서 파일로".
metadata:
  type: method
---

# 문서 파일 (우산 — 형식별 하위 문서)

이 스킬은 문서 파일 작업의 우산이다 — 아래에 형식별 하위 문서 다섯(`references/decrypt/` · `references/docx/` · `references/pdf/` · `references/pptx/` · `references/xlsx/`)을 두고, 작업할 형식의 `GUIDE.md` 를 그때 읽는다. 이 파일은 고르는 길만 정하고, 읽기·만들기·고치기·변환 절차는 각 하위 문서가 정한다. 이 우산은 **파일 조작**을 맡고, 덱·문서의 논리 구조·제목·근거·문체·겉보기·검증 설계는 `skill:skill_LKS_original_visual-design` 이 맡는다(pptx 하위 문서 머리 절과 같은 나눔).

## 먼저 — 라우팅

| 작업 | 형식 | 먼저 읽을 하위 문서 | 비고 |
|---|---|---|---|
| 기존 파일 읽기·내용·데이터 추출 | `.xlsx`·`.xlsm`·`.pptx`·`.potx`·`.docx`·`.dotx`·`.pdf` | `references/decrypt/GUIDE.md` | 포맷별 Python 라이브러리로 읽는 경로 고정 · 읽기까지만 — 읽은 뒤 만들기·고치기로 이어지면 그 형식 행도 읽는다 |
| Word 문서 만들기·고치기·변환(변경 추적·주석·이미지·찾아 바꾸기·목차·쪽 번호) | `.docx`·`.dotx`(legacy `.doc` 는 변환 뒤) | `references/docx/GUIDE.md` | 기존 파일 읽기는 그 하위 문서 머리 「기존 파일 읽기」 절대로 decrypt 경로 |
| PDF 만들기·합치기·나누기·회전·워터마크·양식 채우기·암호 걸기/풀기·이미지 추출 | `.pdf` | `references/pdf/GUIDE.md` | 양식 = 같은 폴더 `FORMS.md` · 고급 = `REFERENCE.md`(하위 문서가 가리키는 대로) |
| 스캔 PDF(이미지 기반)의 글자 추출 | `.pdf` | `references/pdf/GUIDE.md` 머리 「스캔 PDF」 문단 → `skill:skill_LKS_original_ocr-image-extraction` | 엔진·판독 주체 = 그 문단 |
| 쓰기 보호된 기존 PDF 덮어쓰기 | `.pdf` | `skill:skill_LKS_original_visual-design` 의 `latex.md` 「산출 PDF 보호 속성」 항목 | pdf 하위 문서 머리 문단이 가리키는 절차의 실제 자리 |
| 기존 슬라이드 덱 파일 고치기·템플릿·합치기·나누기·발표자 노트 | `.pptx`·`.potx`(legacy `.ppt` 는 변환 뒤) | `references/pptx/GUIDE.md` | 새 덱을 처음부터 만들기 = `skill:skill_LKS_original_visual-design` 의 `pptx.md`(그 어댑터만) · 기존 덱의 품질을 올리면 그 하위 문서 머리 절대로 visual-design 도 |
| 스프레드시트 만들기·고치기·수식·서식·차트·지저분한 표 정리·표 형식 변환 | `.xlsx`·`.xlsm`·`.xltx`·`.csv`·`.tsv` | `references/xlsx/GUIDE.md` | 결과물이 스프레드시트 파일일 때(Word 문서면 docx 행) |
| 덱·문서의 논리·제목·근거·문체·겉보기·검증 설계 | 공통 | `skill:skill_LKS_original_visual-design` | 이 우산은 파일 조작 · 서로 가리킴 |

**작업에 들어가기 전에** 위 표에서 형식을 고르고 그 하위 문서를 **전문으로** 읽고 그 지시대로 한다 — 이 표의 한 줄만으로 하지 않는다.

- 경로는 이 SKILL.md 가 든 폴더 기준이다(설치본 = `~/.claude/skills/skill_LKS_custom_document/` · Windows `%USERPROFILE%\.claude\skills\skill_LKS_custom_document\`).

## 하위 문서 읽는 법

다섯 하위 문서 공통 규칙이다.

1. **상대 경로 = 그 GUIDE.md 가 든 폴더 기준이다** — 하위 문서 본문의 `scripts/<파일>`·`FORMS.md`·`REFERENCE.md` 는 `references/<형식>/` 아래 그 파일이다. 하위 문서가 「this skill's directory」·「이 스킬」 이라고 하면 그 하위 폴더다.
2. **하위 문서가 다른 형식을 `skill:skill_LKS_custom_document` `references/<형식>/GUIDE.md` 로 가리키면** 이 우산 폴더 기준 경로다 — 그 GUIDE.md 도 전문으로 읽는다.
3. **하위 문서 frontmatter 의 `name: skill_LKS_custom_<형식>` 은 스킬 이름이 아니다** — 전역 스킬 목록에는 이 우산만 있다. 사용자가 「docx 스킬」 처럼 형식 이름으로 부르면 이 우산의 그 하위 문서다.
4. **컴팩션 뒤에는 쓰던 하위 GUIDE.md 를 다시 전문으로 읽는다** — 다시 붙는 것은 이 스킬 앞부분뿐이다.
5. **작업 중에 하위 문서·`scripts/` 를 고치지 않는다** — 패키지 원본이다(설치본을 고치면 다시 설치에서 사라진다).
6. **하위 문서의 지시가 이 스킬·헌법과 부딪히면 이 스킬·헌법이 먼저다** — docx·pdf·pptx·xlsx 하위 문서의 공식 원문은 외부 원저작이다(헌법 「지침 우선순위」 `… > 타 플러그인 > …`).

## 적용 조건

| 구분 | 대상 |
|---|---|
| 적용 | 위 형식의 문서 파일을 읽기·추출 · 만들기 · 고치기 · 형식 변환하는 일 |
| 비적용 | 결과물이 문서 파일이 아닌 일(표 데이터가 있어도 HTML 보고서·단독 Python 스크립트·데이터베이스 파이프라인·Google Sheets API 연동) · Google Docs · 문서 파일과 무관한 일반 코딩 |

## 출처

- docx·pdf·pptx·xlsx 하위 문서와 그 `scripts/` = Anthropic 공식 skills(docx·pdf·pptx·xlsx) 원본 기반 — 고친 범위는 각 `GUIDE.md` 머리 주석 · 라이선스 = 각 하위 폴더 `LICENSE.txt`.

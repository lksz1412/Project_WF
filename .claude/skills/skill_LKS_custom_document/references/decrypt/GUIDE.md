---
version: "1.4.0"
updated: "2026-09-27"
name: skill_LKS_custom_decrypt
description: >
  xlsx·pptx·docx·pdf 파일을 열어 내용을 읽거나 데이터를 추출해야 할 때 사용한다 —
  포맷별 Python 라이브러리로 읽는 경로를 고정한다. 셸·범용 변환 도구로 읽으면
  파싱이 깨지거나 아예 실패하는 경우가 있어 도구에 따라 결과가 갈리는데, 경로를
  하나로 고정하면 그 차이가 사라진다. 이 스킬은 "읽기"까지만 다루며 문서 생성·
  편집·포맷팅은 skill_LKS_custom_docx / pdf / pptx / xlsx 를 따로 참조한다.
metadata:
  type: method
---

# 문서 읽기 — Python 경유 고정 (xlsx / pptx / docx / pdf)

> 이름과 달리 **암호 해제 스킬이 아니다** — 포맷별 **읽기 경로 고정** 스킬이다(암호 걸린 PDF 해제는 `skill:skill_LKS_custom_document` `references/pdf/GUIDE.md` 의 qpdf 절차 소관).

엑셀·파워포인트·워드·PDF 를 **읽거나 데이터를 추출**해야 할 때 이 스킬을 쓴다.
쓰는 방법은 하나다 — **포맷에 맞는 Python 라이브러리로 연다.**

## 왜 경로를 고정하는가

같은 파일이 도구에 따라 다르게 읽힌다. 셸의 파일 I/O 나 범용 변환 도구는 OOXML 컨테이너를
풀지 못하거나, 인코딩을 잘못 잡거나, 표·주석 같은 구조를 통째로 버린다. 그 결과 **"읽을 수
없는 파일"이라고 잘못 결론 내리는 일**이 생긴다.

경로를 Python 라이브러리 하나로 고정하면 그 변수를 없앨 수 있다. 파일을 열기 전에 무엇으로
읽을지 고민할 필요도 없어진다.

> **재검증 시 주의.** "안 읽힌다"를 확인할 때는 **원래 쓴 것과 같은 실행 경로로** 재현해야 한다.
> 다른 도구로 안 열리는 것을 보고 "재현 불가"라 단정하면 오판이다.

## 포맷별 방법

| 포맷 | 쓰는 것 | 대안 |
|---|---|---|
| xlsx · xlsm | 값 추출: `openpyxl.load_workbook(path, data_only=True)` | 수식 검토: `data_only=False`로 별도 read · `pandas.read_excel` |
| pptx · potx | `pptx.Presentation(path)` | `python -m markitdown`(POSIX 는 `python3 -m markitdown`) |
| docx · dotx | `zipfile` 로 열어 `word/document.xml` read-only 파싱 | — |
| pdf | `pypdf.PdfReader(path)` | `pdfplumber.open` |

- **xlsx 값 추출은 `data_only=True`**, 수식 모델 검토는 같은 파일을 `data_only=False`로도 별도 read한다. 한 번의 load로 수식과 cached value를 모두 얻었다고 단정하지 않는다.
- **xlsx 는 전체 시트를 훑는다.** 첫 시트만 읽고 끝내면 뒤 시트를 통째로 놓친다.
- **docx 읽기·추출(read-only 파싱)에는 범용 변환 도구를 쓰지 않는다.** 컨테이너를 못 푸는 경우가 있어 `zipfile` 로 직접 연다. (마크다운으로 변환하는 것이 목적이면 `skill:skill_LKS_custom_document` `references/docx/GUIDE.md` 의 pandoc 경로를 쓴다 — 파싱 안전 추출과 변환은 목적이 다르다.)
- 사람용 실행 예시는 **Windows 에선 `python`**(일부 환경에서 `python3` 이 스토어 스텁으로 연결됨 — 헌법 「Windows Python」 줄), **POSIX 에선 `python3`** 으로 쓴다(cross-platform shebang·resolver 는 유지).

## 추출 결과를 다루는 법

추출 결과 중 **표·레코드처럼 DB성 자료인 것**은 통째로 대화에 올리면 그것만으로 컨텍스트가 찬다.
그런 자료는 `memory:feedback_full_file_read_required` 의 "DB성 자료·실험 데이터는 통째 read 대신 Python 으로 필요한 값만(schema·key·count·sample)"
규칙을 따른다 — 별도 규칙을 새로 만들 필요가 없다. 문서 본문처럼 내용 자체를 다뤄야 하는 추출은 전문 정독 대상이다(아래 3항).

1. 먼저 **형태만** 확인한다 — 어떤 타입인지, 시트·슬라이드·페이지 목록이 무엇인지.
2. 대량 행·레코드 성격이면 **필요한 부분만** key·index 로 꺼낸다.
3. 요약·리라이팅·근거 인용처럼 **내용 자체를 다뤄야 하는 작업**이면 전문 정독 원칙에 따라
   끝까지 읽는다. 구간을 나눠 읽어도 되지만 "대충 훑고 넘김"은 안 된다.

내용을 별도 파일로 저장하려면 사용자 명시 요청·승인을 먼저 확인한다. 승인되면 원본 옆 사이드카(JSON)에 두고, 표준 출력에는 상태 요약만 남긴다.

## 참조 구현 (스크립트)

위 §포맷별 방법 표의 경로를 그대로 구현한 실행 스크립트가 `scripts/read_document.py` 에 있다 — 포맷별 `read_xlsx`·`read_pptx`·`read_docx`·`read_pdf` 를 확장자로 디스패치하고, 결과를 원본 옆 사이드카(`<파일>.<확장자>.dat`, JSON)에 쓴 뒤 표준 출력에는 상태 요약(`sheets`·`slide_count`·`char_count`·`page_count`)만 남긴다. §추출 결과를 다루는 법의 "사이드카 + 요약만" 규율을 코드로 굳힌 형태다.

```
python scripts/read_document.py <파일> [--sheet <시트명>]   # POSIX 에선 python3
```

xlsx 는 값 추출(`data_only=True`) 경로다 — 수식 모델 검토가 필요하면 위 표의 대안(`data_only=False` 별도 read)을 쓴다. 각 포맷은 해당 라이브러리(`openpyxl`·`python-pptx`·`pypdf`·`defusedxml`)가 있어야 읽히며, 없으면 `{"status": "error", ...}` 를 내고 종료한다.

## 하지 말아야 할 것

- **원본을 이 경로로 읽은 뒤 그대로 덮어쓰지 않는다.** 읽기만 검증된 경로다.
  새 파일이 필요하면 읽은 내용을 바탕으로 새 파일을 생성한다.
- 추출 결과 전체를 그대로 Read 도구에 올리지 않는다(위 §추출 결과 참조).

## 시스템 요구사항

Python 3 + 포맷별 라이브러리(`openpyxl` · `python-pptx` · `pypdf`). `docx` 는 표준 라이브러리
`zipfile` 만으로 되고, XML 파싱에 `defusedxml` 이 있으면 그것을 쓴다.

## 관련 스킬

읽은 데이터로 **신규 생성·편집·포맷팅**을 이어갈 때는 해당 포맷 스킬의 규칙을 따른다 —
`skill:skill_LKS_custom_document` `references/xlsx/GUIDE.md` · `skill:skill_LKS_custom_document` `references/docx/GUIDE.md` · `skill:skill_LKS_custom_document` `references/pdf/GUIDE.md` · `skill:skill_LKS_custom_document` `references/pptx/GUIDE.md`.
덱을 **저작**(논리·근거·게이트)하는 일은 `skill:skill_LKS_original_visual-design` 소관이다. <!--profile:inhouse-->

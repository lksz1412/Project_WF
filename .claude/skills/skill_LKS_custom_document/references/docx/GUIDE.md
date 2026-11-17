---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_custom_docx
description: "Use this skill whenever the user wants to create, read, edit, or manipulate Word documents (.docx files) or Word templates (.dotx files). Triggers include: any mention of 'Word doc', 'word document', '.docx', '.dotx', or requests to produce professional documents with formatting like tables of contents, headings, page numbers, or letterheads. Also use when extracting or reorganizing content from .docx or .dotx files, inserting or replacing images in documents, performing find-and-replace in Word files, working with tracked changes or comments, or converting content into a polished Word document. If the user asks for a 'report', 'memo', 'letter', 'template', or similar deliverable as a Word or .docx file, use this skill. Do NOT use for PDFs, spreadsheets, Google Docs, or general coding tasks unrelated to document generation."
license: Complete terms in LICENSE.txt
---

<!-- 애드온: Anthropic 공식 skills/docx 원본 기반(base = anthropics/skills `1780c5e5a552`) + name을 skill_LKS_custom_docx로 변경 + 아래 "기존 파일 읽기" 절 추가 + 본문·scripts 일부 수정·추가(Windows Office COM 경로 등 · 내역 = 패키지 CHANGELOG). 고친 범위(공식 새 판을 들일 때 다시 넣는다) = 본문: 첫 표 아래 Windows COM 안내 문단 · 「Verify the output」(Windows·LibreOffice 두 경로 · 매 실행 새 `render-N` 폴더 · pypdfium2 대체 줄 · 폴더 항목 빼기 줄 = `zip -d … || true` 대신 파이썬 `zipfile`[zip 도구가 없어도 같은 일]) · 「Editing existing documents」(`.doc` 변환·symlink 줄 주석·zip[`rm` 없이 `-FS`]·변경 수락 문단) · 「Dependencies」 / scripts: `accept_changes.py`(수정) · `office/soffice.py`(수정 — `soffice` 가 PATH 에 없으면 `soffice_available()` 이 거짓이고 `run_soffice` 가 `FileNotFoundError` 를 내 그 단계를 건너뜀) · `office/office_com.ps1`(추가 — docx·pptx·xlsx 세 포크의 `scripts/office/` 는 같은 파일이라 함께 고친다) · 고친 upstream 스크립트는 파일 머리에 변경 고지 한 줄(Apache-2.0 §4(b) — 원본·라이선스·바꾼 범위). -->

## ★ 기존 파일 읽기

기존 `.docx`의 내용을 **읽거나 데이터를 추출**해야 할 때는 `skill:skill_LKS_custom_document` `references/decrypt/GUIDE.md`의 read-only 경로(`zipfile`로 `word/document.xml` 파싱)가 원본이다. 아래 본문의 읽기·추출 지침은 그 경로의 상세이지 다른 경로가 아니다. 마크다운 **변환**이나 **편집·생성** 작업은 아래 공식 절차를 그대로 쓴다 — 파싱 안전 추출과 변환·편집은 목적이 다르다(decrypt 의 구분과 동일). 사용자가 기존 파일 편집을 요청했다면 새 파일 생성을 강제하지 않는다. legacy `.doc`는 OOXML ZIP이 아니므로 `word/document.xml`을 직접 파싱하지 말고 아래 변환 절차를 따른다. 새 문서를 처음부터 생성하는 작업은 아래 규칙을 그대로 쓴다.

# DOCX creation, editing, and analysis

A `.docx` is a ZIP archive of XML files. Choose your approach by task:

| Task | Approach |
|---|---|
| **Create** a new document | Write a `docx` (npm) script — see gotchas below |
| **Edit** an existing document | `unzip` → edit `word/document.xml` → `zip` (docx-js cannot open existing files) |
| **Read** content | `pandoc -t markdown file.docx` |

> Script paths below are relative to this skill's directory.

> On a Windows PC, rendering, `.doc` conversion, and accepting tracked changes drive Microsoft Word itself through COM (assumed installed — if Word cannot be used, because it will not start or cannot open or write the document, the premise is broken: do not switch to LibreOffice and do not try to repair or reinstall Office; record the step as not run and tell the user). A refusal the user can clear is not a broken premise: when the error says the document is already open in Word (`save and close it, then retry`), ask the user to save and close it, then run the step again. Elsewhere they use LibreOffice. Password-protected documents are not supported on the COM path: Word waits on a hidden password prompt — the Python scripts give up at their timeout, a direct `office_com.ps1` call waits until you end the windowless `WINWORD.EXE` it started (never a Word you have open).

## Creating with docx-js — gotchas

`docx` is preinstalled — do not run `npm install` first; write the script and `require('docx')` directly. Only if that require fails: `npm install docx`. The model knows the API; these are the footguns:

- **Page size defaults to A4.** For US Letter set `page: { size: { width: 12240, height: 15840 } }` (DXA; 1440 = 1″).
- **Landscape:** pass portrait dimensions and `orientation: PageOrientation.LANDSCAPE` — docx-js swaps width/height internally.
- **Tables need dual widths:** set `columnWidths` on the table AND `width` on every cell, both in `WidthType.DXA` (PERCENTAGE breaks in Google Docs). Column widths must sum to the table width.
- **Table shading:** use `ShadingType.CLEAR`, never `SOLID` (renders black).
- **Lists:** never insert `•` literally; use a `numbering` config with `LevelFormat.BULLET`.
- **`ImageRun` requires `type:`** (`"png"`, `"jpg"`, …).
- **`PageBreak` must be inside a `Paragraph`.**
- **Never use `\n`** — use separate `Paragraph` elements.
- **Headings:** style every level you use (`title`, `heading1`, `heading2`…) in `styles.default`: `heading1: { run: { font: "Arial", size: 32, bold: true }, paragraph: { spacing: { before: 240, after: 120 }, keepNext: true } }`. Every level needs its own font (even with a document default), `before` and `after` (even if 0) and `keepNext`: the built-in styles set none of them.
- **TOC:** headings must use built-in `HeadingLevel.*`; custom heading styles need `outlineLevel` set or they won't appear.
- **Don't use a table as a horizontal rule** — use a paragraph bottom border instead.
- **Dot-leader / right-aligned-on-same-line:** use `PositionalTab` (`alignment: PositionalTabAlignment.RIGHT`, `leader: PositionalTabLeader.DOT`) inside a `TextRun`, not literal `.` or space padding.

## Verify the output

After writing a `.docx`, render it and look at it. First, in either environment, drop the ZIP's folder entries:

```bash
python -c "import os, sys, tempfile, zipfile; p = sys.argv[1]; src = zipfile.ZipFile(p); fd, tmp = tempfile.mkstemp(suffix='.docx', dir=os.path.dirname(os.path.abspath(p))); os.close(fd); dst = zipfile.ZipFile(tmp, 'w'); [dst.writestr(i, src.read(i)) for i in src.infolist() if not i.is_dir()]; dst.close(); src.close(); os.replace(tmp, p)" output.docx   # drop the ZIP's folder entries (works without the zip tool): Word has refused a file that has them when opened through a cloud co-editing service
```

Rendering goes through a PDF. Each run writes the PDF and its page images into a new folder (`render-1`, then `render-2` after a fix, and so on; `mkdir` refuses a name already used), so neither a PDF nor pages from an earlier run mix in — if the conversion fails, the new folder has no PDF. On a Windows PC, Word renders it:

```bash
mkdir render-1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/office/office_com.ps1 export-pdf -In output.docx -Out render-1/output.pdf
```

Elsewhere, LibreOffice renders it. It needs its Writer component (e.g. the `libreoffice-writer` package) — without it, LibreOffice prints `Error: source file could not be loaded` and writes nothing:

```bash
mkdir render-1
python scripts/office/soffice.py --headless --convert-to pdf --outdir render-1 output.docx
```

Then, in either environment, turn the PDF in that folder into page images:

```bash
pdftoppm -jpeg -r 100 render-1/output.pdf render-1/page
ls -1 "$PWD"/render-1/page-*.jpg   # then Read the images
```

`pdftoppm` zero-pads page numbers to the width of the page count (`page-01.jpg`…`page-12.jpg`). Without `pdftoppm` (Poppler), run this pypdfium2 line in its place — same file names, same 100 DPI:

```bash
python -c "import sys, pypdfium2 as p; d = p.PdfDocument(sys.argv[1]); w = len(str(len(d))); [d[i].render(scale=100 / 72).to_pil().save(f'{sys.argv[2]}-{i + 1:0{w}d}.jpg') for i in range(len(d))]" render-1/output.pdf render-1/page
```

Keep the earlier folders while you work — they let you compare before and after a fix — and clear them once, when the work is done. After a fix, render the PDF again into the next folder and write its pages there.

## Editing existing documents

Legacy `.doc` files must be converted first — on a Windows PC: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/office/office_com.ps1 convert -In file.doc -Out file.docx`; elsewhere: `python scripts/office/soffice.py --headless --convert-to docx file.doc`.

```bash
unzip -q doc.docx -d unpacked/
find unpacked -type l -delete   # strip symlink entries — docx from external parties is untrusted; a required security step, not cleanup (keep it under a no-delete rule)
python scripts/merge_runs.py unpacked/   # coalesce fragmented runs so text is findable
# edit unpacked/word/document.xml in place — do NOT reformat or pretty-print
(cd unpacked && zip -FSXrD ../out.docx .)   # -FS drops parts deleted from unpacked/ (no rm) · -D writes no folder entries
python scripts/office/validate.py out.docx --original doc.docx   # XSD checks; --auto-repair fixes common issues
# redlining? add --author "<the name you redlined under>" to check every edit is tracked
```

Word splits text across many `<w:r>` runs (revision ids, spell-check markers), so a phrase you can see in the document often doesn't exist as a contiguous string in the XML. `merge_runs.py` merges adjacent identically-formatted runs in `word/document.xml` without changing content or rendering; it also accepts a `.docx` directly (`python scripts/merge_runs.py doc.docx -o merged.docx`).

**Tracked changes:** when redlining, validate with `--author "<the name you redlined under>"` (needs `--original`) — it reports any text you changed without a `<w:ins>`/`<w:del>` around it, which is easy to do by accident and invisible in the accepted view. Wrap runs in `<w:ins>`/`<w:del>` with `w:id`, `w:author`, `w:date` attributes. Inside `<w:del>`, the text element is `<w:delText>`, not `<w:t>`. A deleted paragraph mark (`<w:pPr><w:rPr><w:del w:id=".." w:author=".." w:date=".."/></w:rPr></w:pPr>`) means "merge this paragraph into the next" — so deleting a paragraph outright is that plus a `<w:del>` around every run. The `<w:del/>` must come before the rPr's other children; their order is schema-enforced.

To produce a clean copy with all tracked changes accepted: `python scripts/accept_changes.py in.docx out.docx`. On a Windows PC it has Word itself accept them through COM; elsewhere it runs a LibreOffice macro, which needs the Writer component. Either way it exits 0 only when the written copy has no tracked change left — a non-zero exit (tracked changes left, a timeout, or an error) means `out.docx` is not the clean copy.

Accepting a deleted paragraph mark should join that paragraph to the one below it, so a paragraph whose runs are *all* deleted vanishes. Word does this — so on a Windows PC, where Word does the accepting, `accept_changes.py` inherits it. In the cloud, `accept_changes.py` (LibreOffice) and `pandoc --track-changes=accept` don't always. Both fail the same way — they strip the deleted text but leave the emptied paragraph behind, which reads as a stray empty bullet when it was auto-numbered:

- `pandoc --track-changes=accept` never joins the paragraphs.
- `accept_changes.py` in the cloud (LibreOffice) joins them correctly, except when the deleted paragraph is followed by an empty spacer paragraph.

An empty bullet in either view is an artifact of that view, not a defect in the document. Check paragraph deletions in the XML.

## Comments

Comments require six cross-linked files. Use the helper — directory mode when you'll also be editing `document.xml` (saves an unzip/rezip cycle), `.docx`-direct mode otherwise:

```bash
# Against an already-unpacked directory (preferred when also placing markers)
python scripts/comment.py unpacked/ "Fees & expenses cap is too low"
python scripts/comment.py unpacked/ "Agreed" --parent 0

# Against a .docx directly
python scripts/comment.py contract.docx "This cap is too low" -o annotated.docx
```

The script writes `comments.xml`, `commentsExtended.xml`, `commentsIds.xml`, `commentsExtensible.xml`, the relationships, and the content-type overrides. Comment IDs are auto-assigned. It then prints the `<w:commentRangeStart>`/`<w:commentRangeEnd>`/`<w:commentReference>` snippet to add to `word/document.xml` so the comment anchors to specific text — until you place those markers, the comment exists but is not visible.

## Dependencies

`docx` (npm, preinstalled — install only if `require('docx')` fails) · `pandoc` · rendering, `.doc` conversion and accepting changes: on a Windows PC, Microsoft Word through COM (`scripts/office/office_com.ps1`, run with Windows PowerShell); elsewhere LibreOffice with its Writer component (`soffice`) · rasterizing: `pdftoppm` (Poppler), or `pypdfium2` (pip) where Poppler is absent

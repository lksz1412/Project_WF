"""Format-aware xlsx/pptx/docx/pdf reader (Python library route)."""
import argparse
import json
import sys
import zipfile
from pathlib import Path
from typing import Optional


def read_xlsx(path: Path, sheet_name: Optional[str]) -> dict:
    import openpyxl

    wb = openpyxl.load_workbook(path, data_only=True)
    target_sheets = [sheet_name] if sheet_name else wb.sheetnames
    sheets = {}
    for name in target_sheets:
        if name not in wb.sheetnames:
            raise ValueError(f"sheet not found: {name} (available: {wb.sheetnames})")
        ws = wb[name]
        sheets[name] = [list(row) for row in ws.iter_rows(values_only=True)]
    return {"type": "xlsx", "sheets": sheets}


def read_pptx(path: Path) -> dict:
    from pptx import Presentation

    prs = Presentation(path)
    slides = []
    for i, slide in enumerate(prs.slides, start=1):
        texts = [
            shape.text_frame.text
            for shape in slide.shapes
            if shape.has_text_frame
        ]
        slides.append({"slide": i, "text": "\n".join(texts)})
    return {"type": "pptx", "slides": slides}


def read_docx(path: Path) -> dict:
    import defusedxml.minidom as minidom

    with zipfile.ZipFile(path) as z:
        xml = z.read("word/document.xml").decode("utf-8")
    dom = minidom.parseString(xml)
    texts = [
        node.firstChild.nodeValue
        for node in dom.getElementsByTagName("w:t")
        if node.firstChild
    ]
    return {"type": "docx", "text": "".join(texts)}


def read_pdf(path: Path) -> dict:
    import pypdf

    reader = pypdf.PdfReader(path)
    pages = [
        {"page": i, "text": page.extract_text() or ""}
        for i, page in enumerate(reader.pages, start=1)
    ]
    return {"type": "pdf", "pages": pages}


READERS = {".xlsx": read_xlsx, ".pptx": read_pptx, ".docx": read_docx, ".pdf": read_pdf}


def main() -> None:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    parser = argparse.ArgumentParser(
        description="Format-aware xlsx/pptx/docx/pdf reader (Python library route)"
    )
    parser.add_argument("file", help="읽을 파일 경로")
    parser.add_argument("--sheet", default=None, help="xlsx 시트명")
    args = parser.parse_args()

    path = Path(args.file)
    if not path.exists():
        print(json.dumps({"status": "error", "reason": f"file not found: {path}"}))
        sys.exit(1)

    suffix = path.suffix.lower()
    reader = READERS.get(suffix)
    if reader is None:
        print(json.dumps({"status": "error", "reason": f"unsupported extension: {suffix}"}))
        sys.exit(1)

    try:
        result = reader(path, args.sheet) if suffix == ".xlsx" else reader(path)
    except Exception as e:
        print(json.dumps({"status": "error", "reason": str(e)}, ensure_ascii=False))
        sys.exit(1)

    dat_path = path.with_suffix(path.suffix + ".dat")
    dat_path.write_text(
        json.dumps(result, ensure_ascii=False, indent=2, default=str), encoding="utf-8"
    )

    summary = {"status": "success", "dat_file": str(dat_path)}
    if suffix == ".xlsx":
        summary["sheets"] = list(result["sheets"].keys())
    elif suffix == ".pptx":
        summary["slide_count"] = len(result["slides"])
    elif suffix == ".docx":
        summary["char_count"] = len(result["text"])
    elif suffix == ".pdf":
        summary["page_count"] = len(result["pages"])
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()

# 변경 고지(Apache License 2.0 §4(b)): Anthropic `anthropics/skills` 의 skills/pptx/scripts/thumbnail.py(라이선스 = 이 하위 문서 폴더 LICENSE.txt)를 고친 파일 — Windows 에서 PowerPoint COM 으로 PDF 를 만듦 · pdftoppm 이 없으면 pypdfium2 · Impress 안내.
"""Create thumbnail grids from PowerPoint presentation slides.

Creates a grid layout of slide thumbnails for quick visual analysis.
Labels each thumbnail with its XML filename (e.g., slide1.xml).
Hidden slides are shown with a placeholder pattern.

The slides are rendered to a PDF by PowerPoint through COM on Windows
(scripts/office/office_com.ps1) and by LibreOffice elsewhere, then rasterized
with pdftoppm, or with pypdfium2 when pdftoppm is not installed.
BADA_OFFICE_COM_RUNNER: test seam - a program run in place of PowerShell on the Windows path.

Usage:
    python thumbnail.py input.pptx [output_prefix] [--cols N]

Examples:
    python thumbnail.py presentation.pptx
    # Creates: thumbnails.jpg

    python thumbnail.py template.pptx grid --cols 4
    # Creates: grid.jpg (or grid-1.jpg, grid-2.jpg for large decks)
"""

import argparse
import json
import os
import posixpath
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

import defusedxml.minidom
from defusedxml import ElementTree
from office.helpers import SLIDE_REL_TYPE, opc_target
from office.soffice import run_soffice
from PIL import Image, ImageDraw, ImageFont


THUMBNAIL_WIDTH = 300
CONVERSION_DPI = 100
MAX_COLS = 6
DEFAULT_COLS = 3
JPEG_QUALITY = 95
GRID_PADDING = 20
BORDER_WIDTH = 2
FONT_SIZE_RATIO = 0.10
LABEL_PADDING_RATIO = 0.4

OFFICE_COM_SCRIPT = Path(__file__).resolve().parent / "office" / "office_com.ps1"
OFFICE_COM_RUNNER_ENV = "BADA_OFFICE_COM_RUNNER"
OFFICE_COM_TIMEOUT = 300
OFFICE_COM_REQUIRED = (
    "On Windows this step drives Microsoft Office through COM; it does not fall back to "
    "LibreOffice. If the error before this names something the user can clear - the file is "
    "already open or opened read-only, or other workbooks are open - ask the user to save "
    "and close it, then run this again; after a timeout, follow that error's advice. Any "
    "other failure means Office cannot be used here, which breaks the premise that it is "
    "installed and usable: record this step as not run and tell the user."
)
IMPRESS_REQUIRED = (
    "if LibreOffice Impress is not installed (e.g. the libreoffice-impress package), "
    "install it first: without Impress the deck never opens and no PDF is written"
)


def main():
    parser = argparse.ArgumentParser(
        description="Create thumbnail grids from PowerPoint slides."
    )
    parser.add_argument("input", help="Input PowerPoint file (.pptx)")
    parser.add_argument(
        "output_prefix",
        nargs="?",
        default="thumbnails",
        help="Output prefix for image files (default: thumbnails)",
    )
    parser.add_argument(
        "--cols",
        type=int,
        default=DEFAULT_COLS,
        help=f"Number of columns (default: {DEFAULT_COLS}, max: {MAX_COLS})",
    )

    args = parser.parse_args()

    cols = min(args.cols, MAX_COLS)
    if args.cols > MAX_COLS:
        print(f"Warning: Columns limited to {MAX_COLS}")

    input_path = Path(args.input)
    if not input_path.exists() or input_path.suffix.lower() != ".pptx":
        print(f"Error: Invalid PowerPoint file: {args.input}", file=sys.stderr)
        sys.exit(1)

    output_path = Path(f"{args.output_prefix}.jpg")

    try:
        slide_info = get_slide_info(input_path)

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            visible_images = convert_to_images(input_path, temp_path)

            if not visible_images and not any(s["hidden"] for s in slide_info):
                print("Error: No slides found", file=sys.stderr)
                sys.exit(1)

            slides = build_slide_list(slide_info, visible_images, temp_path)

            grid_files = create_grids(slides, cols, THUMBNAIL_WIDTH, output_path)

            print(f"Created {len(grid_files)} grid(s):")
            for grid_file in grid_files:
                print(f"  {grid_file}")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def _is_hidden(zf: zipfile.ZipFile, part: str) -> bool:
    try:
        with zf.open(part) as f:
            for _, root in ElementTree.iterparse(f, events=("start",)):
                return root.get("show") in ("0", "false")  
    except (KeyError, ElementTree.ParseError):
        return False
    return False


def get_slide_info(pptx_path: Path) -> list[dict]:
    with zipfile.ZipFile(pptx_path, "r") as zf:
        rels_content = zf.read("ppt/_rels/presentation.xml.rels").decode("utf-8")
        rels_dom = defusedxml.minidom.parseString(rels_content)

        rid_to_part = {}
        for rel in rels_dom.getElementsByTagName("Relationship"):
            if rel.getAttribute("Type") != SLIDE_REL_TYPE:
                continue
            part = opc_target(
                rel.getAttribute("Target"),
                "ppt/presentation.xml",
                rel.getAttribute("TargetMode"),
            )
            if part is not None:
                rid_to_part[rel.getAttribute("Id")] = part

        pres_content = zf.read("ppt/presentation.xml").decode("utf-8")
        pres_dom = defusedxml.minidom.parseString(pres_content)

        present = set(zf.namelist())

        slides = []
        for sld_id in pres_dom.getElementsByTagName("p:sldId"):
            part = rid_to_part.get(sld_id.getAttribute("r:id"))
            if part is not None and part in present:
                slides.append(
                    {"name": posixpath.basename(part), "hidden": _is_hidden(zf, part)}
                )

        return slides


def build_slide_list(
    slide_info: list[dict],
    visible_images: list[Path],
    temp_dir: Path,
) -> list[tuple[Path, str]]:
    visible_count = sum(1 for info in slide_info if not info["hidden"])
    rendered_hidden = len(visible_images) == len(slide_info) != visible_count

    if not rendered_hidden and visible_count != len(visible_images):
        raise ValueError(
            f"The PDF has {len(visible_images)} page(s) for {visible_count} "
            f"visible slide(s) of {len(slide_info)}; thumbnails would be mislabeled"
        )

    if visible_images:
        with Image.open(visible_images[0]) as img:
            placeholder_size = img.size
    else:
        placeholder_size = (1920, 1080)

    slides = []
    visible_idx = 0

    for info in slide_info:
        if info["hidden"] and not rendered_hidden:
            placeholder_path = temp_dir / f"hidden-{info['name']}.jpg"
            placeholder_img = create_hidden_placeholder(placeholder_size)
            placeholder_img.save(placeholder_path, "JPEG")
            slides.append((placeholder_path, f"{info['name']} (hidden)"))
        else:
            label = f"{info['name']} (hidden)" if info["hidden"] else info["name"]
            slides.append((visible_images[visible_idx], label))
            visible_idx += 1

    return slides


def create_hidden_placeholder(size: tuple[int, int]) -> Image.Image:
    img = Image.new("RGB", size, color="#F0F0F0")
    draw = ImageDraw.Draw(img)
    line_width = max(5, min(size) // 100)
    draw.line([(0, 0), size], fill="#CCCCCC", width=line_width)
    draw.line([(size[0], 0), (0, size[1])], fill="#CCCCCC", width=line_width)
    return img


def run_office_com(action, source, target=None, timeout=None):
    """Run office_com.ps1 and return (result, None), or (None, error text) on failure."""
    runner = os.environ.get(OFFICE_COM_RUNNER_ENV)
    if runner:
        cmd = [runner]
    else:
        shell = shutil.which("powershell.exe") or shutil.which("pwsh")
        if shell is None:
            return None, "neither powershell.exe nor pwsh was found on PATH"
        cmd = [shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File"]
    cmd += [str(OFFICE_COM_SCRIPT), action, "-In", os.path.abspath(source)]
    if target is not None:
        cmd += ["-Out", os.path.abspath(target)]

    with tempfile.TemporaryDirectory(prefix="office_com_", ignore_cleanup_errors=True) as tmp:
        result_path = os.path.join(tmp, "result.json")
        cmd += ["-ResultJson", result_path]
        try:
            proc = subprocess.run(
                cmd, capture_output=True, text=True, errors="replace", timeout=timeout
            )
        except subprocess.TimeoutExpired:
            return None, (
                f"no result within {timeout}s - Office may still be starting, a hidden Office "
                "dialog may be waiting (e.g. a password prompt), or the work needs longer (a direct "
                "scripts/office/office_com.ps1 call has no time limit); an Office process this run "
                "started (EXCEL.EXE / WINWORD.EXE / POWERPNT.EXE with no window) may be left running - "
                "end only that one, never an Office app you have open, then re-run"
            )
        except OSError as e:
            return None, f"could not run {cmd[0]}: {e}"
        try:
            with open(result_path, encoding="utf-8") as f:
                result = json.load(f)
        except (OSError, ValueError):
            result = None

    if not isinstance(result, dict):
        result = {}
    if proc.returncode == 0 and result.get("ok") is True:
        return result, None
    detail = result.get("error") or (proc.stderr or proc.stdout or "").strip()
    detail = detail.strip().rstrip(".") if detail else ""
    return None, detail or f"{cmd[0]} exited with code {proc.returncode}"


def export_pdf_with_powerpoint(pptx_path: Path, pdf_path: Path) -> None:
    _, error = run_office_com("export-pdf", pptx_path, pdf_path, timeout=OFFICE_COM_TIMEOUT)
    if error is None and not pdf_path.exists():
        error = f"no PDF was written to {pdf_path}"
    if error is not None:
        raise RuntimeError(f"PowerPoint could not export the PDF: {error}. {OFFICE_COM_REQUIRED}")


def rasterize_with_pypdfium2(pdf_path: Path, prefix: Path) -> None:
    try:
        import pypdfium2 as pdfium
    except ImportError as e:
        raise RuntimeError(
            "Image conversion needs pdftoppm (Poppler) or the pypdfium2 package; "
            f"install either one (pip install pypdfium2). pypdfium2 import failed: {e}"
        ) from None

    # Same output as `pdftoppm -jpeg -r DPI`: <prefix>-N.jpg, N zero-padded to the page count's width.
    pdf = pdfium.PdfDocument(str(pdf_path))
    try:
        page_count = len(pdf)
        digits = len(str(page_count))
        for index in range(page_count):
            page = pdf[index]
            try:
                bitmap = page.render(scale=CONVERSION_DPI / 72)
                bitmap.to_pil().save(f"{prefix}-{index + 1:0{digits}d}.jpg", "JPEG")
            finally:
                page.close()
    finally:
        pdf.close()


def convert_to_images(pptx_path: Path, temp_dir: Path) -> list[Path]:
    pdf_path = temp_dir / f"{pptx_path.stem}.pdf"

    if sys.platform == "win32":
        export_pdf_with_powerpoint(pptx_path, pdf_path)
    else:
        result = run_soffice(
            ["--headless", "--convert-to", "pdf", "--outdir", str(temp_dir), str(pptx_path)],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0 or not pdf_path.exists():
            detail = (result.stderr or result.stdout or "").strip()
            failed = f"PDF conversion failed: {detail}" if detail else "PDF conversion failed"
            raise RuntimeError(f"{failed} - {IMPRESS_REQUIRED}")

    if shutil.which("pdftoppm"):
        result = subprocess.run(
            [
                "pdftoppm",
                "-jpeg",
                "-r",
                str(CONVERSION_DPI),
                str(pdf_path),
                str(temp_dir / "slide"),
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            raise RuntimeError("Image conversion failed")
    else:
        rasterize_with_pypdfium2(pdf_path, temp_dir / "slide")

    return sorted(temp_dir.glob("slide-*.jpg"))


def create_grids(
    slides: list[tuple[Path, str]],
    cols: int,
    width: int,
    output_path: Path,
) -> list[str]:
    max_per_grid = cols * (cols + 1)
    grid_files = []

    for chunk_idx, start_idx in enumerate(range(0, len(slides), max_per_grid)):
        end_idx = min(start_idx + max_per_grid, len(slides))
        chunk_slides = slides[start_idx:end_idx]

        grid = create_grid(chunk_slides, cols, width)

        if len(slides) <= max_per_grid:
            grid_filename = output_path
        else:
            stem = output_path.stem
            suffix = output_path.suffix
            grid_filename = output_path.parent / f"{stem}-{chunk_idx + 1}{suffix}"

        grid_filename.parent.mkdir(parents=True, exist_ok=True)
        grid.save(str(grid_filename), quality=JPEG_QUALITY)
        grid_files.append(str(grid_filename))

    return grid_files


def create_grid(
    slides: list[tuple[Path, str]],
    cols: int,
    width: int,
) -> Image.Image:
    font_size = int(width * FONT_SIZE_RATIO)
    label_padding = int(font_size * LABEL_PADDING_RATIO)

    with Image.open(slides[0][0]) as img:
        aspect = img.height / img.width
    height = int(width * aspect)

    rows = (len(slides) + cols - 1) // cols
    grid_w = cols * width + (cols + 1) * GRID_PADDING
    grid_h = rows * (height + font_size + label_padding * 2) + (rows + 1) * GRID_PADDING

    grid = Image.new("RGB", (grid_w, grid_h), "white")
    draw = ImageDraw.Draw(grid)

    try:
        font = ImageFont.load_default(size=font_size)
    except Exception:
        font = ImageFont.load_default()

    for i, (img_path, slide_name) in enumerate(slides):
        row, col = i // cols, i % cols
        x = col * width + (col + 1) * GRID_PADDING
        y_base = (
            row * (height + font_size + label_padding * 2) + (row + 1) * GRID_PADDING
        )

        label = slide_name
        bbox = draw.textbbox((0, 0), label, font=font)
        text_w = bbox[2] - bbox[0]
        draw.text(
            (x + (width - text_w) // 2, y_base + label_padding),
            label,
            fill="black",
            font=font,
        )

        y_thumbnail = y_base + label_padding + font_size + label_padding

        with Image.open(img_path) as img:
            img.thumbnail((width, height), Image.Resampling.LANCZOS)
            w, h = img.size
            tx = x + (width - w) // 2
            ty = y_thumbnail + (height - h) // 2
            grid.paste(img, (tx, ty))

            if BORDER_WIDTH > 0:
                draw.rectangle(
                    [
                        (tx - BORDER_WIDTH, ty - BORDER_WIDTH),
                        (tx + w + BORDER_WIDTH - 1, ty + h + BORDER_WIDTH - 1),
                    ],
                    outline="gray",
                    width=BORDER_WIDTH,
                )

    return grid


if __name__ == "__main__":
    main()

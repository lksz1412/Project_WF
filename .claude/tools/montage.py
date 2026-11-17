#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""montage.py - contact sheet builder for slide renders (Gate 3 visual review).

Combines rendered slide PNGs into grid images so a reviewer (human or subagent)
can judge global rhythm, colour consistency and layout drift in one look instead
of opening 70 files. Slide numbers are burned in so findings can be traced back.

Only Pillow is required - no ImageMagick.
Python 3.12 pinned.
"""
from __future__ import annotations

import argparse
import glob
import os
import re
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit("Pillow is required: python -m pip install Pillow")

LABEL_H = 28
PAD = 8
BG = (245, 246, 248)
LABEL_BG = (31, 41, 55)
LABEL_FG = (255, 255, 255)


def slide_number(path: str) -> int:
    """Slide index from the trailing number, matching render_pptx.ps1.

    Concatenating every digit breaks on names carrying a date or a version
    (deck_2026-07-26_slide-3.png sorted as 202607263).
    """
    base = os.path.splitext(os.path.basename(path))[0]
    m = re.search(r"(\d+)\s*$", base)
    return int(m.group(1)) if m else 0


def build_sheet(files: list[str], cols: int, rows: int, cell_w: int) -> Image.Image:
    # Cell shape comes from the median aspect, not from files[0]. A single
    # odd-sized render (a failed slide) used to set the shape for the whole
    # sheet - measured: one 200x4000 file produced a 984x19280 sheet.
    ratios = []
    for f in files:
        try:
            with Image.open(f) as im:
                ratios.append(im.height / im.width)
        except Exception:
            continue
    aspect = sorted(ratios)[len(ratios) // 2] if ratios else 9 / 16
    cell_h = int(cell_w * aspect)
    sheet_w = cols * cell_w + (cols + 1) * PAD
    sheet_h = rows * (cell_h + LABEL_H) + (rows + 1) * PAD
    sheet = Image.new("RGB", (sheet_w, sheet_h), BG)
    draw = ImageDraw.Draw(sheet)

    for idx, path in enumerate(files):
        r, c = divmod(idx, cols)
        x = PAD + c * (cell_w + PAD)
        y = PAD + r * (cell_h + LABEL_H + PAD)
        try:
            with Image.open(path) as raw:
                img = raw.convert("RGB")
        except Exception:
            # Skip the unreadable slide but keep building the sheet. Aborting
            # leaves an older sheet on disk that a reviewer would open as current.
            draw.rectangle([x, y + LABEL_H, x + cell_w - 1, y + LABEL_H + cell_h - 1],
                           fill=(250, 235, 235), outline=(200, 120, 120))
            draw.text((x + 8, y + LABEL_H + 8), "UNREADABLE", fill=(160, 40, 40))
            continue
        # Fit rather than stretch: a slide rendered at a different size (a failed
        # render, a mixed-source folder) would otherwise be silently distorted.
        scale = min(cell_w / img.width, cell_h / img.height)
        tw, th = max(1, int(img.width * scale)), max(1, int(img.height * scale))
        cell = Image.new("RGB", (cell_w, cell_h), BG)
        cell.paste(img.resize((tw, th), Image.LANCZOS),
                   ((cell_w - tw) // 2, (cell_h - th) // 2))
        sheet.paste(cell, (x, y + LABEL_H))
        draw.rectangle([x, y, x + cell_w, y + LABEL_H], fill=LABEL_BG)
        draw.text((x + 6, y + 7), f"slide {slide_number(path):03d}", fill=LABEL_FG)
        # thin frame so white slides do not bleed into the sheet background
        draw.rectangle([x, y + LABEL_H, x + cell_w - 1, y + LABEL_H + cell_h - 1],
                       outline=(210, 214, 220))
    return sheet


def main() -> int:
    ap = argparse.ArgumentParser(description="Build contact sheets from slide PNGs")
    ap.add_argument("--png-dir", required=True)
    ap.add_argument("--out", default="montage.png")
    ap.add_argument("--cols", type=int, default=4)
    ap.add_argument("--rows", type=int, default=3)
    ap.add_argument("--cell-width", type=int, default=480)
    args = ap.parse_args()

    if args.cols < 1 or args.rows < 1 or args.cell_width < 1:
        print("--cols, --rows, --cell-width must all be >= 1", file=sys.stderr)
        return 1
    if args.cell_width > 2000:
        print(f"--cell-width {args.cell_width} is too large for a contact sheet "
              "(max 2000); the point of the sheet is to see many slides at once",
              file=sys.stderr)
        return 1
    stem, ext = os.path.splitext(args.out)
    if ext.lower() not in {".png", ".jpg", ".jpeg", ".webp"}:
        print(f"--out needs an image extension, got '{ext or 'none'}'", file=sys.stderr)
        return 1
    out_dir = os.path.dirname(os.path.abspath(args.out))
    os.makedirs(out_dir, exist_ok=True)

    # Writing sheets into the folder we read from means the next run treats them
    # as slides. Filtering them back out is guesswork that can silently eat real
    # input, so refuse the situation instead.
    # normcase + realpath: abspath alone compares case-sensitively on Windows, so
    # ...\render\PNG and ...\render\png slipped past and the sheet landed in the
    # input folder, where the next run read it as a slide.
    def _same_dir(a, b):
        return os.path.normcase(os.path.realpath(a)) == os.path.normcase(os.path.realpath(b))

    if _same_dir(args.png_dir, out_dir):
        print("--out must not be inside --png-dir: the next run would read the "
              "contact sheets as slides. Write it to a separate folder.",
              file=sys.stderr)
        return 1

    files = sorted(glob.glob(os.path.join(args.png_dir, "*.png")), key=slide_number)
    if not files:
        print(f"no PNG found in {args.png_dir}", file=sys.stderr)
        return 1

    # Remove sheets from a previous run before writing new ones. Otherwise a
    # shorter deck leaves the old montage.png next to the new montage-01.png and
    # a reviewer opens the wrong one.
    sheet_pat = re.compile(re.escape(os.path.basename(stem)) + r"(-\d+)?$")
    for old_sheet in glob.glob(f"{stem}{ext}") + glob.glob(f"{stem}-*{ext}"):
        if sheet_pat.match(os.path.splitext(os.path.basename(old_sheet))[0]):
            try:
                os.remove(old_sheet)
            except OSError:
                pass

    per_sheet = args.cols * args.rows
    sheets = 0
    for start in range(0, len(files), per_sheet):
        chunk = files[start:start + per_sheet]
        rows_needed = (len(chunk) + args.cols - 1) // args.cols
        sheet = build_sheet(chunk, args.cols, rows_needed, args.cell_width)
        sheets += 1
        name = args.out if len(files) <= per_sheet else f"{stem}-{sheets:02d}{ext}"
        sheet.save(name)
        print(f"{name}  slides {slide_number(chunk[0])}-{slide_number(chunk[-1])}  {sheet.size}")

    print(f"total slides={len(files)} sheets={sheets}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

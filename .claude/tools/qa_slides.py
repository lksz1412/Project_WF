#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""qa_slides.py - Gate 2 machine QA for rendered slide decks.

Checks (thresholds are explicit and measured; see the constants below):
  1) bg       : the ring's dominant colour holds too small a  -> WARN
                share for a background to be determined; the
                three ratio checks below are then skipped
  2) blank    : ink ratio < BLANK_MAX_RATIO                   -> FAIL
                (a slide listed in --allow-blank reads 빈칸(의도)
                instead; a listed slide that is not blank is a WARN)
  3) margin   : more than MARGIN_SHARE_MAX of a slide's ink    -> WARN
                sits inside the safe margin, excluding bands
  4) density  : content ratio > DENSITY_MAX_RATIO              -> WARN
  5) edge     : too many separate ink stretches along an       -> WARN
                outermost line (clipped content, not a rail)
  6) font     : fonts used in the .pptx that are not           -> FAIL
                installed on this system (needs --pptx)
  7) unreadable: the image could not be opened                 -> FAIL
  8) count    : deck slide count differs from the PNG count    -> FAIL
                (needs --pptx; without python-pptx it is 미실행)

Two ink measures, deliberately separate:
  ink     - differs from the background by more than COLOR_TOLERANCE. Sensitive
            enough that a pale card counts, which is what blank detection needs.
  content - differs by more than CONTENT_CONTRAST_MIN. Pale fills drop out, so
            density measures actual text and solid areas rather than layout.

Design notes
  - Background colour: dominant colour of the safe-margin ring, reported with a
    confidence score. See background_colour() for the three approaches that were
    measured and rejected first.
  - The safe margin defaults to 0.5 inch. At 1920 px across a 13.333 in canvas
    that is 144 px/inch -> 72 px. Pass --margin-px to override.
  - Deliberate full-bleed rails need no authoring hint: the margin check excludes
    flat lines spanning the whole width or height, and the edge check keys on run
    length so a solid band cannot look like clipped text. --except-slides remains
    for anything else.
  - The edge check counts ink stretches rather than colour runs, so it behaves the
    same on vertical edges as on horizontal ones.
  - Text overflowing its own text box while staying inside the canvas is NOT
    detectable from pixels. That case belongs to Gate 1 (pptx_lint.js).
  - Fixtures covering every check live in tools/negtest/make_negtest.py, which
    ships with this tool. Run it after changing any threshold.

Requires: Pillow. The font check and the slide count check additionally require
python-pptx; without it both are reported as 미실행, never as a pass (Windows
registry is used to enumerate installed fonts).
Python 3.12 pinned.
"""
from __future__ import annotations

import argparse
import glob
import os
import re
import sys
from collections import Counter

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
# 파이프로 캡처되면 Python 은 콘솔 CP 가 아니라 ANSI(한국어=cp949)로 인코딩 →
# '—'(U+2014) 등 cp949 밖 문자에서 UnicodeEncodeError. UTF-8 로 못박아 안전
# (BADA_recall 훅과 동일 방어를 전 CLI 도구로 표준화).
if sys.platform == "win32":
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except Exception:
        pass

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: python -m pip install Pillow")

BLANK_MAX_RATIO = 0.0005     # below this -> blank slide. Measured: a truly empty
                             # render is 0.000%, while the dark full-bleed cover
                             # fixture (slide-007) carrying one short line is
                             # 0.298%.
BG_CONFIDENCE_MIN = 0.70     # share the dominant ring colour must hold for the
                             # background to be trusted. Measured over every
                             # artefact in this repo: ordinary slides 0.910-0.997
                             # (baseline 70 + dry-run 4), fixture with both a top
                             # and a left rail 0.783, full-bleed cover 1.000,
                             # versus 0.528 for a half-and-half slide and 0.025
                             # for a gradient. 0.70 sits in the gap, leaving the
                             # rail case 0.08 of headroom rather than 0.03.
DENSITY_MAX_RATIO = 0.35     # above this -> dense slide (measured on content_ratio)
CONTENT_CONTRAST_MIN = 64    # per-channel distance from the background for a pixel
                             # to count as content. Pale card fills (#EAF0FF, 21/15/0
                             # from white) are layout, not density; body text
                             # (#1F2937, 224/214/200 from white) and brand fills
                             # clear this comfortably.
MARGIN_SHARE_MAX = 0.20      # >20% of a slide's ink inside the safe margin -> WARN.
                             # The bottom band is excluded by position (see
                             # analyse).
EDGE_BAND_PX = 2             # outermost band used to detect ink at the very edge
EDGE_MAX_SEGMENTS = 2        # separate ink stretches along an outermost line
                             # before the edge counts as clipped content. A solid
                             # full-bleed rail is 1 stretch however thick it is;
                             # clipped text leaves one per glyph or per text line.
                             # Measured: every slide of the 74 real renders in this
                             # repo scores 1, so 2 costs nothing in false positives.
                             # A vertical edge yields one stretch per text line,
                             # so a higher limit forgives that many clipped lines —
                             # the very case this rule exists for.
COLOR_TOLERANCE = 12         # per-channel distance to count as background.
                             # Measured: a pale card fill such as #EAF0FF differs
                             # from white by 21/15/0 per channel, so a tolerance of
                             # 24 swallowed every tinted card and reported "blank".
                             # 12 keeps anti-aliasing noise out while catching tints.
DEFAULT_MARGIN_PX = 72    # 0.5 inch at 1920 px / 13.333 in


def slide_number(path: str) -> int:
    """Slide index taken from the trailing number of the filename.

    Concatenating every digit breaks as soon as the name carries a date or a
    version: deck_2026-07-26_slide-3.png would sort as 202607263. The renderer
    already keys on the trailing number, so all three tools agree.
    """
    base = os.path.splitext(os.path.basename(path))[0]
    m = re.search(r"(\d+)\s*$", base)
    return int(m.group(1)) if m else 0


def _ring_pixels(img: Image.Image, margin_px: int, step: int):
    """Coordinates of the outer band of the slide (the safe-margin ring)."""
    w, h = img.size
    m = min(margin_px, w // 2, h // 2)
    for y in range(0, m, step):
        for x in range(0, w, step):
            yield x, y
    for y in range(h - m, h, step):
        for x in range(0, w, step):
            yield x, y
    for x in range(0, m, step):
        for y in range(m, h - m, step):
            yield x, y
    for x in range(w - m, w, step):
        for y in range(m, h - m, step):
            yield x, y


def background_colour(img: Image.Image, margin_px: int) -> tuple[tuple[int, int, int], float]:
    """Colour of the slide background, plus how dominant it was.

    Four approaches were measured before settling here:
      - four corners: a full-bleed top band owns two corners, the tie resolved to
        the band colour and every content slide then reported 90%+ ink.
      - mode of the whole image: flips to the fill colour whenever a large card or
        a dark block covers more than half the slide.
      - ring mode filtered by a background-dependent band test: circular, see
        flat_lines(). A tall band inverted the result and the filter then removed
        the real background instead of the band.
      - ring mode plus a confidence score (this one): the ring's dominant colour,
        with the share it holds. See BG_CONFIDENCE_MIN for the measured spread.
        When a band splits the slide roughly in half there is no defensible way to
        call either side "the background", so the caller is told the reading is
        unreliable instead of being handed a confident wrong number.
    """
    w, h = img.size
    step = max(1, min(w, h) // 200)
    px = img.load()

    # Quantise before counting. Exact-tuple counting made a background that looks
    # plainly white to the eye collapse to 0.36 confidence, because a 1-2 step
    # gradient spreads across many distinct tuples. The bucket width matches
    # COLOR_TOLERANCE, i.e. differences we already treat as "same colour".
    q = COLOR_TOLERANCE
    def bucket(p):
        return (p[0] // q, p[1] // q, p[2] // q)

    counts = Counter(bucket(px[x, y]) for x, y in _ring_pixels(img, margin_px, step))
    if not counts:
        # Ring is empty (degenerate image). Fall back to the whole image rather
        # than assuming white — a dark deck would invert.
        counts = Counter(bucket(px[x, y])
                         for y in range(0, h, step) for x in range(0, w, step))
    if not counts:
        return (255, 255, 255), 0.0
    top, n = counts.most_common(1)[0]
    confidence = n / sum(counts.values())

    # Report the most common *actual* colour inside the winning bucket, so the
    # value in the report is a real pixel value rather than a bucket midpoint.
    exact = Counter(p for p in (px[x, y][:3] for x, y in _ring_pixels(img, margin_px, step))
                    if bucket(p) == top)
    colour = exact.most_common(1)[0][0] if exact else tuple(c * q + q // 2 for c in top)
    return colour, confidence


def _aligned(start: int, stop: int, step: int):
    """range() whose indices land on the same lattice as range(0, n, step).

    analyse() samples rows at range(0, h, step). If a scan starts at an index of
    the opposite parity, the two index sets never intersect and every lookup
    against the scan result silently misses. Measured: h=1080 gave a 20/20 hit
    rate, h=1081 gave 0/20, which made the whole band exclusion a no-op and
    produced margin warnings on clean slides.
    """
    start = max(0, start - (start % step))
    return range(start, stop, step)


def edge_ink_segments(img: Image.Image, bg: tuple[int, int, int]) -> int:
    """Largest number of separate ink stretches along any outermost line.

    A deliberate full-bleed band paints its whole edge in one colour, so that
    edge is a single unbroken stretch. Content clipped by the canvas leaves one
    stretch per glyph or per text line, so the count climbs.
    """
    w, h = img.size
    px = img.load()

    def differs(p):
        return (abs(p[0] - bg[0]) > COLOR_TOLERANCE
                or abs(p[1] - bg[1]) > COLOR_TOLERANCE
                or abs(p[2] - bg[2]) > COLOR_TOLERANCE)

    worst = 0
    for line in ([px[x, 0] for x in range(w)],
                 [px[x, h - 1] for x in range(w)],
                 [px[0, y] for y in range(h)],
                 [px[w - 1, y] for y in range(h)]):
        segments = 0
        inside = False
        for p in line:
            ink = differs(p)
            if ink and not inside:
                segments += 1
            inside = ink
        worst = max(worst, segments)
    return worst


def flat_lines(img: Image.Image, margin_px: int, step: int) -> tuple[set[int], set[int]]:
    """Rows/columns inside the margin that are a single flat colour.

    Deliberately *independent of the background colour*.

    Flatness alone is the honest signal. Both the accent rail and the true
    background are flat; the caller decides which is which by area.
    """
    w, h = img.size
    px = img.load()
    xs = max(1, w // 200)
    ys = max(1, h // 200)
    rows: set[int] = set()
    cols: set[int] = set()
    for y in list(_aligned(0, min(margin_px, h), step)) + \
             list(_aligned(max(0, h - margin_px), h, step)):
        if len({px[x, y][:3] for x in range(0, w, xs)}) == 1:
            rows.add(y)
    for x in list(_aligned(0, min(margin_px, w), step)) + \
             list(_aligned(max(0, w - margin_px), w, step)):
        if len({px[x, y][:3] for y in range(0, h, ys)}) == 1:
            cols.add(x)
    return rows, cols


def analyse(path: str, margin_px: int) -> dict:
    with Image.open(path) as _im:
        # convert("RGB") on a 16-bit or float image clips every pixel to white,
        # which then reads as FAIL:blank on a perfectly good slide.
        if _im.mode in ("I", "I;16", "I;16B", "I;16L", "F"):
            _im = _im.point(lambda v: v * (1.0 / 256)).convert("L")
        img = _im.convert("RGB")
    w, h = img.size
    # A margin wider than half the image would put every pixel "inside the
    # margin" and make margin_share meaningless (measured: 100% on a 144x144).
    margin_px = max(1, min(margin_px, (min(w, h) - 1) // 2))
    bg, bg_confidence = background_colour(img, margin_px)
    px = img.load()

    # Downsample for speed: sampling every 2nd pixel keeps ratios stable.
    step = 2
    band_rows, band_cols = flat_lines(img, margin_px, step)
    # A flat line that *is* the background is not a band; excluding it would be
    # meaningless (it carries no ink anyway) but keeping the sets tight is cheaper.
    band_rows = {y for y in band_rows if px[0, y][:3] != bg}
    band_cols = {x for x in band_cols if px[x, 0][:3] != bg}
    total = 0
    ink = 0            # any pixel differing from the background - blank detection
    content = 0        # strongly contrasting pixels only - density judgement
    margin_ink = 0
    edge_ink = 0
    # The bottom margin is where footers and page numbers legitimately live, so
    # ink there is not "content that drifted out of the safe area".
    footer_top = h - margin_px

    for y in range(0, h, step):
        in_margin_row = y < margin_px or y >= h - margin_px
        in_edge_row = y < EDGE_BAND_PX or y >= h - EDGE_BAND_PX
        row_is_band = y in band_rows
        in_footer = y >= footer_top
        for x in range(0, w, step):
            total += 1
            r, g, b = px[x, y]
            dr, dg, db = abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2])
            if dr > COLOR_TOLERANCE or dg > COLOR_TOLERANCE or db > COLOR_TOLERANCE:
                ink += 1
                if max(dr, dg, db) > CONTENT_CONTRAST_MIN:
                    content += 1
                if (in_margin_row or x < margin_px or x >= w - margin_px) \
                        and not row_is_band and x not in band_cols and not in_footer:
                    margin_ink += 1
                if in_edge_row or x < EDGE_BAND_PX or x >= w - EDGE_BAND_PX:
                    edge_ink += 1

    ratio = ink / total if total else 0.0
    content_ratio = content / total if total else 0.0

    # "Blank" means the slide carries no content, which is a question about
    # variation, not about which colour won. Measured on a quantised grid so a
    # faint texture or gradient does not read as content.
    q = COLOR_TOLERANCE
    spread = Counter((px[x, y][0] // q, px[x, y][1] // q, px[x, y][2] // q)
                     for y in range(0, h, max(1, h // 100))
                     for x in range(0, w, max(1, w // 100)))
    dominant = spread.most_common(1)[0][1] / sum(spread.values()) if spread else 1.0
    uniform = dominant > (1.0 - BLANK_MAX_RATIO * 2) or ratio < BLANK_MAX_RATIO
    # Ratio of a slide's ink that sits inside the safe margin. A footer or a
    # header legitimately lives there, so an absolute pixel count is useless as
    # a gate (measured: every slide of the baseline deck hits it). What matters
    # is whether a *substantial part* of the content has drifted into the margin.
    margin_share = margin_ink / ink if ink else 0.0
    return {
        "slide": slide_number(path),
        "file": os.path.basename(path),
        "size": f"{w}x{h}",
        "bg": "#%02X%02X%02X" % bg,
        "bg_confidence": bg_confidence,
        "uniform": uniform,
        # A margin band that covers most of the frame makes margin_share
        # meaningless (measured: 100% on a 144x144 canvas).
        "margin_meaningful": (2 * margin_px) < 0.5 * min(w, h),
        "ink_ratio": ratio,
        "content_ratio": content_ratio,
        "margin_ink": margin_ink,
        "margin_share": margin_share,
        "edge_ink": edge_ink,
        # Ink at the very edge is only a defect when the edge is not a flat band.
        "edge_clipped": edge_ink > 0 and edge_ink_segments(img, bg) > EDGE_MAX_SEGMENTS,
    }


def _font_files() -> list[str]:
    """Absolute paths of installed font files (Windows registry)."""
    out: list[str] = []
    try:
        import winreg
    except ImportError:
        return out
    sysfonts = os.path.join(os.environ.get("SystemRoot", r"C:\Windows"), "Fonts")
    for root, key in ((winreg.HKEY_LOCAL_MACHINE,
                       r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"),
                      (winreg.HKEY_CURRENT_USER,
                       r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts")):
        try:
            with winreg.OpenKey(root, key) as k:
                for i in range(winreg.QueryInfoKey(k)[1]):
                    _, value, _ = winreg.EnumValue(k, i)
                    if not isinstance(value, str):
                        continue
                    out.append(value if os.path.isabs(value)
                               else os.path.join(sysfonts, value))
        except OSError:
            continue
    return out


def _names_from_font(path: str) -> set[str]:
    """Family names declared inside a font file, in every language it carries.

    The registry lists only the English name, so a deck authored in Korean
    PowerPoint (which writes "맑은 고딕") would be reported as using a font that
    is not installed. The localized names live in the font's own `name` table, so
    that is where we look. Reads the file directly - no dependencies.
    """
    names: set[str] = set()
    try:
        with open(path, "rb") as fh:
            data = fh.read()
    except OSError:
        return names

    offsets = []
    if data[:4] == b"ttcf":                      # font collection
        n = int.from_bytes(data[8:12], "big")
        for i in range(n):
            offsets.append(int.from_bytes(data[12 + i * 4:16 + i * 4], "big"))
    else:
        offsets.append(0)

    for base in offsets:
        try:
            num_tables = int.from_bytes(data[base + 4:base + 6], "big")
            for i in range(num_tables):
                rec = base + 12 + i * 16
                if data[rec:rec + 4] != b"name":
                    continue
                tbl = int.from_bytes(data[rec + 8:rec + 12], "big")
                count = int.from_bytes(data[tbl + 2:tbl + 4], "big")
                str_off = tbl + int.from_bytes(data[tbl + 4:tbl + 6], "big")
                for j in range(count):
                    r = tbl + 6 + j * 12
                    name_id = int.from_bytes(data[r + 6:r + 8], "big")
                    if name_id not in (1, 16):          # family / typographic family
                        continue
                    plat = int.from_bytes(data[r:r + 2], "big")
                    ln = int.from_bytes(data[r + 8:r + 10], "big")
                    off = int.from_bytes(data[r + 10:r + 12], "big")
                    raw = data[str_off + off:str_off + off + ln]
                    try:
                        s = raw.decode("utf-16-be") if plat in (0, 3) else raw.decode("latin-1")
                    except UnicodeDecodeError:
                        continue
                    s = s.strip()
                    if s:
                        names.add(s.lower())
        except (IndexError, ValueError):
            continue
    return names


def installed_fonts() -> set[str]:
    """Installed font family names, including localized names."""
    names: set[str] = set()
    try:
        import winreg
    except ImportError:
        return names
    for root, key in ((winreg.HKEY_LOCAL_MACHINE,
                       r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"),
                      (winreg.HKEY_CURRENT_USER,
                       r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts")):
        try:
            with winreg.OpenKey(root, key) as k:
                for i in range(winreg.QueryInfoKey(k)[1]):
                    value_name, _, _ = winreg.EnumValue(k, i)
                    base = value_name.split("(")[0].strip()
                    for part in base.split("&"):
                        names.add(part.strip().lower())
        except OSError:
            continue
    return names


def resolve_missing(used: set[str], have: set[str]) -> list[str]:
    """Names in `used` that are not installed, after checking localized names.

    Scanning font files is only worth it for names the registry could not
    account for, so it happens here rather than up front.
    """
    missing = sorted(f for f in used if f.strip().lower() not in have)
    if not missing:
        return []
    localized: set[str] = set()
    for path in _font_files():
        localized |= _names_from_font(path)
        if not [m for m in missing if m.strip().lower() not in localized]:
            break
    return [m for m in missing if m.strip().lower() not in localized]


_A_NS = "{http://schemas.openxmlformats.org/drawingml/2006/main}"


def _run_typefaces(run) -> set[str]:
    """Every typeface a run declares: Latin, East Asian and complex script.

    python-pptx's run.font.name exposes only <a:latin>. A Korean deck normally
    sets <a:ea> as well, so reading just the Latin slot reported "missing: none"
    while every Hangul glyph was being substituted at render time.
    """
    out: set[str] = set()
    rpr = getattr(getattr(run, "_r", None), "rPr", None)
    if rpr is None:
        if run.font.name:
            out.add(run.font.name.strip())
        return out
    for tag in ("latin", "ea", "cs"):
        el = rpr.find(_A_NS + tag)
        if el is not None:
            tf = (el.get("typeface") or "").strip()
            # "+mn-lt" / "+mj-ea" are theme references, not concrete fonts.
            if tf and not tf.startswith("+"):
                out.add(tf)
    return out


def fonts_used(pptx_path: str) -> set[str] | None:
    """Font names set at run level. None means the check could not run at all.

    The distinction matters: an empty set means "the deck inherits theme fonts",
    while None means "python-pptx is not installed". Collapsing both into an empty
    set turned a FAIL-grade check into a silent pass.
    """
    try:
        from pptx import Presentation
    except ImportError:
        return None
    used: set[str] = set()
    try:
        prs = Presentation(pptx_path)
    except Exception as exc:                       # missing / corrupt package
        raise RuntimeError(f"{pptx_path} 를 열 수 없다: {type(exc).__name__}") from exc

    def walk(shapes):
        for shape in shapes:
            # Groups nest, and table text lives in a GraphicFrame whose
            # has_text_frame is False — both were invisible to a flat scan.
            if getattr(shape, "shape_type", None) is not None and hasattr(shape, "shapes"):
                walk(shape.shapes)
                continue
            if getattr(shape, "has_table", False):
                for row in shape.table.rows:
                    for cell in row.cells:
                        for para in cell.text_frame.paragraphs:
                            for run in para.runs:
                                used.update(_run_typefaces(run))
                continue
            if not getattr(shape, "has_text_frame", False):
                continue
            for para in shape.text_frame.paragraphs:
                for run in para.runs:
                    used.update(_run_typefaces(run))

    for slide in prs.slides:
        walk(slide.shapes)
    return used


def parse_slide_list(text: str) -> set[int]:
    """Comma separated slide numbers, e.g. "12,30".

    Anything that is not a number is an error rather than skipped, so a typo
    cannot quietly change which slides are exempt.
    """
    out: set[int] = set()
    for part in text.split(","):
        tok = part.strip()
        if not tok:
            continue
        if not (tok.isascii() and tok.isdigit()):
            raise ValueError(f"장 번호가 아니다: {tok!r}")
        out.add(int(tok))
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description="Gate 2 machine QA for slide renders")
    ap.add_argument("--png-dir", required=True)
    ap.add_argument("--pptx", help="source .pptx for the font check and the slide count check")
    ap.add_argument("--out", default="qa_report.md")
    ap.add_argument("--margin-px", type=int, default=DEFAULT_MARGIN_PX)
    ap.add_argument("--except-slides", default="",
                    help="comma separated slide numbers exempt from the margin "
                         "and edge checks")
    ap.add_argument("--allow-blank", default="",
                    help="comma separated slide numbers left blank on purpose; "
                         "reported as 빈칸(의도) instead of FAIL:blank")
    args = ap.parse_args()

    exempt = {int(s) for s in args.except_slides.split(",") if s.strip().isdigit()}
    try:
        allow_blank = parse_slide_list(args.allow_blank)
    except ValueError as exc:
        ap.error(f"--allow-blank: {exc}")
    files = sorted(glob.glob(os.path.join(args.png_dir, "*.png")), key=slide_number)
    if not files:
        print(f"no PNG found in {args.png_dir}", file=sys.stderr)
        return 1

    rows = []
    fails = 0
    warns = 0
    intended = 0                  # --allow-blank 로 적힌 빈칸 장 중 실제로 빈 장
    for path in files:
        try:
            info = analyse(path, args.margin_px)
        except (OSError, ValueError) as exc:
            # One unreadable file must not abort the run. Aborting leaves the
            # previous qa_report.md in place, which reads as a current pass.
            # Deliberately narrow: a blanket except would file a programming
            # error as "unreadable" on every slide.
            rows.append({
                "slide": slide_number(path), "file": os.path.basename(path),
                "size": "-", "bg": "-", "bg_confidence": 0.0,
                "ink_ratio": 0.0, "content_ratio": 0.0, "margin_share": 0.0,
                "verdict": f"FAIL:unreadable ({type(exc).__name__})",
            })
            fails += 1
            continue

        verdicts = []
        # A blank slide is a render failure and must be caught whatever the
        # background looks like. Uniformity does not depend on knowing which
        # colour the background is, so it is judged on its own.
        if info["uniform"]:
            # 픽셀로는 의도한 빈칸과 렌더 실패를 구분할 수 없다. 저자가 장 번호로
            # 적은 장만 면제하고, 적지 않은 빈 장은 그대로 FAIL 이다.
            if info["slide"] in allow_blank:
                verdicts.append("빈칸(의도)")
                intended += 1
            else:
                verdicts.append("FAIL:blank")
                fails += 1
        elif info["slide"] in allow_blank:
            # 빈칸이라고 적었는데 내용이 있다 — 장을 끼우거나 빼서 번호가 밀린 목록일 수 있다.
            verdicts.append("WARN:allow-blank(내용 있음)")
            warns += 1

        # The ratio checks below do need a trustworthy background. Without one,
        # say so rather than publish numbers that look authoritative and are not.
        if info["bg_confidence"] < BG_CONFIDENCE_MIN:
            verdicts.append(f"WARN:bg-unclear({info['bg_confidence']:.2f})")
            warns += 1
        else:
            if info["content_ratio"] > DENSITY_MAX_RATIO:
                verdicts.append("WARN:density")
                warns += 1
            # A sparse slide makes margin_share meaningless: a standard footer is
            # a large share of very little ink (measured: 30% on a divider).
            margin_hit = info["margin_share"] > MARGIN_SHARE_MAX
            if margin_hit and info["margin_meaningful"] and info["slide"] not in exempt:
                verdicts.append("WARN:margin")
                warns += 1
        if info["edge_clipped"] and info["slide"] not in exempt:
            verdicts.append("WARN:edge")   # non-uniform ink at the canvas edge -> clipping
            warns += 1
        info["verdict"] = ", ".join(verdicts) if verdicts else "OK"
        rows.append(info)

    font_lines = []
    unrun = 0                     # 검사가 돌지 못한 항목 수. 통과와 구분해 셈한다.
    if args.pptx:
        try:
            used = fonts_used(args.pptx)
        except Exception as exc:
            # 여기서 죽으면 이전 실행의 qa_report.md 가 남아 최신 통과로 오독된다.
            used = None
            font_lines.append(f"- **미실행: 폰트 검사 중 오류 — {type(exc).__name__}: {exc}**")
            unrun += 1
        have = installed_fonts()
        if used is None:
            if not font_lines:
                font_lines.append("- **미실행: python-pptx 가 설치되지 않았다** "
                                  "(`python -m pip install python-pptx`). 통과가 아니다.")
                unrun += 1
        elif not used:
            font_lines.append("- 런 단위 폰트명이 지정되지 않았다(테마 폰트 상속). "
                              "**미실행 [근거 미발견]** — 통과가 아니다. "
                              "해소: 서체를 명시 지정한다.")
            unrun += 1
        elif not have:
            # 목록이 비었다고 전건 FAIL 로 처리하면 덱 전체가 실패로 읽힌다.
            font_lines.append("- **미실행: 설치 폰트 목록을 읽지 못했다**(레지스트리 접근 불가). "
                              f"사용 폰트: {', '.join(sorted(used))}")
            unrun += 1
        else:
            missing = resolve_missing(used, have)
            font_lines.append(f"- used: {', '.join(sorted(used))}")
            if missing:
                font_lines.append(f"- **missing (FAIL): {', '.join(missing)}**")
                fails += len(missing)
            else:
                font_lines.append("- missing: none")

    # 덱 장수와 PNG 장수가 다르면 일부만 검사한 것이다. 렌더 스크립트가 이미
    # 확인하지만 그 판정은 산출물에 남지 않아, 보고서만 보면 알 수 없다.
    # 대조를 못 했으면(python-pptx 없음 · 파일을 못 엶) 통과가 아니라 미실행이다.
    deck_slides = None
    count_unrun = ""              # 장 수 대조를 못 한 사유
    if args.pptx:
        try:
            from pptx import Presentation
        except ImportError:
            count_unrun = "python-pptx 없음"
        else:
            try:
                deck_slides = len(Presentation(args.pptx).slides)
            except Exception as exc:
                count_unrun = f".pptx 를 열 수 없음 — {type(exc).__name__}"
        if count_unrun:
            unrun += 1
    if deck_slides is not None and deck_slides != len(rows):
        fails += 1

    # 빈칸으로 적었는데 그 번호의 PNG 가 없다 — 목록이 덱과 어긋났다는 신호다.
    missing_blank = sorted(allow_blank - {r["slide"] for r in rows})
    warns += len(missing_blank)

    with open(args.out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# QA Report (Gate 2)\n\n")
        fh.write(f"- source: `{args.png_dir}`\n")
        fh.write(f"- slides: {len(rows)}\n")
        if deck_slides is not None:
            mark = "" if deck_slides == len(rows) else "  **← 불일치: 일부만 렌더됐다 (FAIL)**"
            fh.write(f"- deck slides: {deck_slides}{mark}\n")
        elif count_unrun:
            fh.write(f"- deck slides: **미실행({count_unrun})** — 장 수 대조를 하지 못했다. "
                     "통과가 아니다.\n")
        if allow_blank:
            line = (f"- allow-blank(의도한 빈칸): {', '.join(str(n) for n in sorted(allow_blank))}"
                    f" → 빈칸(의도) {intended}장")
            if missing_blank:
                line += f" · **PNG 에 없는 장: {', '.join(str(n) for n in missing_blank)} (WARN)**"
            fh.write(line + "\n")
        # .1% would round 0.0005 to "0.1%" and misstate the threshold by 2x.
        fh.write(f"- thresholds: blank<{BLANK_MAX_RATIO:.3%}, density>{DENSITY_MAX_RATIO:.0%}, "
                 f"margin={args.margin_px}px, margin_share>{MARGIN_SHARE_MAX:.0%}, "
                 f"bg_confidence>={BG_CONFIDENCE_MIN:.2f}\n")
        fh.write(f"- **FAIL={fails}, WARN={warns}, 미실행={unrun}**\n\n")
        if font_lines:
            fh.write("## Fonts\n\n" + "\n".join(font_lines) + "\n\n")
        fh.write("## Slides\n\n")
        fh.write("| slide | ink% | content% | margin share | bg | verdict |\n"
                 "|---:|---:|---:|---:|---|---|\n")
        for r in rows:
            fh.write(f"| {r['slide']} | {r['ink_ratio']*100:.1f} | "
                     f"{r['content_ratio']*100:.1f} | {r['margin_share']*100:.1f}% | "
                     f"{r['bg']} | {r['verdict']} |\n")
        fh.write("\n> Text overflowing its own box while inside the canvas is not visible "
                 "here; that is Gate 1 (`pptx_lint.js`).\n")

    print(f"slides={len(rows)} FAIL={fails} WARN={warns} UNRUN={unrun} -> {args.out}")
    if count_unrun:
        print(f"  deck slides: 미실행({count_unrun}) — 통과가 아니다")
    if allow_blank:
        tail = (f" · PNG 에 없는 장 {', '.join(str(n) for n in missing_blank)} (WARN)"
                if missing_blank else "")
        print(f"  allow-blank: 빈칸(의도) {intended}장{tail}")
    # 미실행도 종료코드에 반영한다. FAIL=0 WARN=0 만 보고 통과로 읽으면
    # 완료 조건이 요구하는 "근거 미발견 0" 을 기계가 확인할 방법이 없어진다.
    return 1 if (fails or unrun) else 0


if __name__ == "__main__":
    raise SystemExit(main())

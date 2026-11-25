"""Draw the status strip theme switcher images (theme names and arrows).

Usage:
  python -I Collection/tools/theme_switcher_art.py            # write the TGA files and LICENSE-OFL.txt
  python -I Collection/tools/theme_switcher_art.py --check    # exit 1 when a file on disk differs
  python -I Collection/tools/theme_switcher_art.py --preview OUT.png   # also write a preview sheet

Input: ``Collection/codex-briefs/assets/26-theme-switcher/Allura-Regular.ttf``
(sha256 checked; the tool stops when it differs) and ``OFL.txt`` next to it.
Output: ``Collection/AddOns/DevilForever_Skin_StatusStrip/Media/ThemeSwitcher/``
``<fhd|qhd|uhd>/name_<theme id>.tga`` (13 per preset),
``<fhd|qhd|uhd>/arrow_<prev|next>_<normal|hover|pushed|disabled>.tga`` (8 per preset)
and ``LICENSE-OFL.txt`` (copy of OFL.txt). The font file itself is not copied.

Images are 32-bit uncompressed TGA (type 2, 8 alpha bits, bottom-left origin,
TGA 2.0 footer), the layout of the TGAs in DevilForever_Appearance. The picture
is drawn only inside the top-left draw area (name slot or arrow button size of
the preset); the rest of the power-of-two canvas is fully transparent, because
ThemeSwitcher.lua shows only that area through SetTexCoord. No timestamps or
randomness: the same input and library versions give the same bytes.
"""

import argparse
import hashlib
import os
import struct
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
ASSETS = os.path.join(REPO, "Collection", "codex-briefs", "assets", "26-theme-switcher")
FONT_PATH = os.path.join(ASSETS, "Allura-Regular.ttf")
FONT_SHA256 = "9c142b2e515832c0dfc4ff8b8ea18f40314943bf937b72e2b23c4661bac14cc6"
OFL_PATH = os.path.join(ASSETS, "OFL.txt")
OUT_ROOT = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Skin_StatusStrip", "Media", "ThemeSwitcher")
LICENSE_NAME = "LICENSE-OFL.txt"

# Theme ids and English labels in Theme.lua CHOICES order.
THEMES = [
    ("devil", "Devil"), ("alliance", "Alliance"), ("horde", "Horde"), ("human", "Human"),
    ("dwarf", "Dwarf"), ("gnome", "Gnome"), ("nightelf", "Night Elf"), ("orc", "Orc"),
    ("tauren", "Tauren"), ("troll", "Troll"), ("undead", "Undead"),
    ("skyborne", "Skyborne (Alliance)"), ("skyborne-horde", "Skyborne (Horde)"),
]
# Layout version names of the version switcher (New = V2, Old = V1), drawn like the theme names.
SIDES = ["prev", "next"]
STATES = ["normal", "hover", "pushed", "disabled"]

# Per preset: bar height, font size (statusstrip.bar of Presets/<preset>.lua),
# name canvas, arrow canvas, and the largest Allura size that fits the bare
# names (measurement basis of the brief; decorations may need less).
# Name area = font size x 12 by bar height; arrow area = max(bar height, font size + 6) square.
PRESETS = {
    "fhd": {"bar": 22, "font": 16, "name_canvas": (256, 32), "arrow_canvas": (32, 32), "basis": 21},
    "qhd": {"bar": 24, "font": 18, "name_canvas": (256, 32), "arrow_canvas": (32, 32), "basis": 24},
    "uhd": {"bar": 28, "font": 22, "name_canvas": (512, 32), "arrow_canvas": (32, 32), "basis": 27},
}
SUPERSAMPLE = 4

# Gold ramp over the ink height (0 = top of the tallest letter, 1 = bottom of the deepest one).
GOLD = [(0.00, (255, 243, 196)), (0.30, (247, 214, 120)), (0.42, (255, 250, 224)), (0.52, (234, 180, 66)),
        (0.75, (186, 126, 36)), (1.00, (118, 72, 18))]
OUTLINE = (44, 23, 6)
SHADOW_ALPHA = 0.75
# Strip-like backgrounds for the preview: color.panel.background of devil, horde, alliance.
PREVIEW_BACKGROUNDS = [(38, 27, 23), (51, 22, 19), (19, 31, 56)]


class ArtError(Exception):
    pass


def name_area(preset):
    spec = PRESETS[preset]
    return spec["font"] * 12, spec["bar"]


def arrow_area(preset):
    spec = PRESETS[preset]
    side = max(spec["bar"], spec["font"] + 6)
    return side, side


def check_font():
    if not os.path.isfile(FONT_PATH):
        raise ArtError("font missing: %s" % FONT_PATH)
    with open(FONT_PATH, "rb") as fh:
        digest = hashlib.sha256(fh.read()).hexdigest()
    if digest != FONT_SHA256:
        raise ArtError("font sha256 %s differs from %s" % (digest, FONT_SHA256))


def ramp(stops, t):
    t = min(1.0, max(0.0, t))
    for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
        if t <= t1:
            f = 0.0 if t1 == t0 else (t - t0) / (t1 - t0)
            return tuple(int(round(a + (b - a) * f)) for a, b in zip(c0, c1))
    return stops[-1][1]


def tone(color, state):
    """Fill colour of one state from the normal gold colour."""
    r, g, b = color
    if state == "hover":
        return tuple(int(round(c + (255 - c) * 0.35)) for c in color)
    if state == "pushed":
        return tuple(int(round(c * 0.82)) for c in color)
    if state == "disabled":
        gray = 0.30 * r + 0.59 * g + 0.11 * b
        return tuple(int(round((gray * 0.75 + c * 0.25) * 0.55)) for c in color)
    return color


def gradient(size, top, bottom, state):
    """RGB image whose rows follow the gold ramp between ``top`` and ``bottom`` (pixels)."""
    width, height = size
    column = Image.new("RGB", (1, height))
    span = max(1.0, bottom - top)
    for y in range(height):
        column.putpixel((0, y), tone(ramp(GOLD, (y + 0.5 - top) / span), state))
    return column.resize((width, height), Image.NEAREST)


def decorate(alpha, area, canvas, top, bottom, state, shift_down=0):
    """Gold fill + 1 px dark outline + soft dark shadow, cut to ``area``, placed on ``canvas``."""
    outline = alpha.filter(ImageFilter.MaxFilter(3))
    shadow = Image.new("L", area, 0)
    shadow.paste(outline.crop((0, 0, area[0] - 1, area[1] - 1)), (1, 1))
    shadow = shadow.filter(ImageFilter.GaussianBlur(0.8))
    shadow = shadow.point(lambda v: int(round(v * SHADOW_ALPHA)))
    layer = Image.new("RGBA", area, (0, 0, 0, 0))
    black = Image.new("RGBA", area, (0, 0, 0, 0))
    black.putalpha(shadow)
    layer = Image.alpha_composite(layer, black)
    dark = Image.new("RGBA", area, OUTLINE + (0,))
    dark.putalpha(outline)
    layer = Image.alpha_composite(layer, dark)
    fill = gradient(area, top, bottom, state).convert("RGBA")
    fill.putalpha(alpha)
    layer = Image.alpha_composite(layer, fill)
    if shift_down:
        moved = Image.new("RGBA", area, (0, 0, 0, 0))
        moved.paste(layer.crop((0, 0, area[0], area[1] - shift_down)), (0, shift_down))
        layer = moved
    out = Image.new("RGBA", canvas, (0, 0, 0, 0))
    out.paste(layer, (0, 0))
    return clean(out)


def clean(image):
    """Transparent pixels get RGB 0 so equal pictures give equal bytes."""
    pixels = image.load()
    width, height = image.size
    for y in range(height):
        for x in range(width):
            if pixels[x, y][3] == 0:
                pixels[x, y] = (0, 0, 0, 0)
    return image


def name_layout(preset):
    """(font, baseline y, x per theme, ink top, ink bottom) at supersampled size, or ArtError."""
    width, height = name_area(preset)
    ss = SUPERSAMPLE
    for size in range(PRESETS[preset]["basis"] * ss, 8 * ss, -1):
        font = ImageFont.truetype(FONT_PATH, size)
        boxes = {theme: font.getbbox(label, anchor="ls") for theme, label in THEMES}
        top = min(b[1] for b in boxes.values())
        bottom = max(b[3] for b in boxes.values())
        widest = max(b[2] - b[0] for b in boxes.values())
        # 1 px of the final image on every side is kept for the outline.
        if widest <= (width - 2) * ss and bottom - top <= (height - 2) * ss:
            baseline = ((height * ss) - (bottom - top)) / 2.0 - top
            xs = {theme: ((width * ss) - (b[2] - b[0])) / 2.0 - b[0] for theme, b in boxes.items()}
            return {"font": font, "size": size / float(ss), "baseline": baseline, "x": xs,
                    "top": (baseline + top) / ss, "bottom": (baseline + bottom) / ss}
    raise ArtError("no font size fits the %s name area" % preset)


def name_image(preset, layout, theme, label):
    """Theme name image at the preset's name size and baseline."""
    width, height = name_area(preset)
    ss = SUPERSAMPLE
    big = Image.new("L", (width * ss, height * ss), 0)
    x = layout["x"].get(theme)
    if x is None:
        box = layout["font"].getbbox(label, anchor="ls")
        x = ((width * ss) - (box[2] - box[0])) / 2.0 - box[0]
    ImageDraw.Draw(big).text((x, layout["baseline"]), label, fill=255, font=layout["font"],
                             anchor="ls")
    alpha = big.reduce(ss)
    return decorate(alpha, (width, height), PRESETS[preset]["name_canvas"], layout["top"], layout["bottom"],
                    "normal")


def arrow_mask(preset, side):
    """Left-pointing ornamental chevron with a diamond behind it; ``next`` is its mirror."""
    n = arrow_area(preset)[0]
    ss = SUPERSAMPLE * 2
    s = n * ss
    big = Image.new("L", (s, s), 0)
    draw = ImageDraw.Draw(big)
    top, bottom, mid = 0.22 * s, 0.76 * s, 0.49 * s
    tip, back, thick = 0.17 * s, 0.56 * s, 0.18 * s
    draw.polygon([(tip, mid), (back, top), (back + thick, top), (tip + thick, mid),
                  (back + thick, bottom), (back, bottom)], fill=255)
    cx, r = 0.80 * s, 0.075 * s
    draw.polygon([(cx - r, mid), (cx, mid - r * 1.6), (cx + r, mid), (cx, mid + r * 1.6)], fill=255)
    alpha = big.reduce(ss)
    if side == "next":
        alpha = alpha.transpose(Image.FLIP_LEFT_RIGHT)
    return alpha, top / ss, bottom / ss


def arrow_image(preset, side, state):
    alpha, top, bottom = arrow_mask(preset, side)
    return decorate(alpha, arrow_area(preset), PRESETS[preset]["arrow_canvas"], top, bottom, state,
                    shift_down=1 if state == "pushed" else 0)


def tga_bytes(image):
    """32-bit uncompressed TGA: no ID, type 2, bottom-left origin, 8 alpha bits, TGA 2.0 footer."""
    width, height = image.size
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, width, height, 32, 8)
    rows = []
    for y in range(height - 1, -1, -1):
        row = image.crop((0, y, width, y + 1)).tobytes("raw", "BGRA")
        rows.append(row)
    footer = b"\x00" * 8 + b"TRUEVISION-XFILE.\x00"
    return header + b"".join(rows) + footer


def build():
    """{path relative to OUT_ROOT: bytes} of every output file, plus the images for the preview."""
    check_font()
    files, images, sizes = {}, {}, {}
    for preset in PRESETS:
        layout = name_layout(preset)
        sizes[preset] = layout["size"]
        for theme, label in THEMES:
            image = name_image(preset, layout, theme, label)
            rel = "%s/name_%s.tga" % (preset, theme)
            files[rel], images[rel] = tga_bytes(image), image
        for side in SIDES:
            for state in STATES:
                image = arrow_image(preset, side, state)
                rel = "%s/arrow_%s_%s.tga" % (preset, side, state)
                files[rel], images[rel] = tga_bytes(image), image
    with open(OFL_PATH, "rb") as fh:
        files[LICENSE_NAME] = fh.read()
    return files, images, sizes


def write(files):
    for rel, data in sorted(files.items()):
        path = os.path.join(OUT_ROOT, *rel.split("/"))
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "wb") as fh:
            fh.write(data)


def check(files):
    """Differences between ``files`` and the disk (missing, different, extra)."""
    problems = []
    for rel, data in sorted(files.items()):
        path = os.path.join(OUT_ROOT, *rel.split("/"))
        if not os.path.isfile(path):
            problems.append("missing " + rel)
            continue
        with open(path, "rb") as fh:
            if fh.read() != data:
                problems.append("differs " + rel)
    if os.path.isdir(OUT_ROOT):
        for dirpath, _dirnames, filenames in os.walk(OUT_ROOT):
            for name in filenames:
                rel = os.path.relpath(os.path.join(dirpath, name), OUT_ROOT).replace(os.sep, "/")
                if rel not in files:
                    problems.append("extra " + rel)
    return problems


def preview(images, out_path):
    """Sheet: per preset all names and arrow states at 1:1, the assembled switcher, then a 4x fhd row."""
    label_font = ImageFont.load_default()
    gap = 6
    blocks = []
    for preset in PRESETS:
        nw, nh = name_area(preset)
        aw, ah = arrow_area(preset)
        bg = PREVIEW_BACKGROUNDS[0]
        cols = 4
        rows = (len(THEMES) + cols - 1) // cols
        width = max(cols * (nw + gap) + gap, 8 * (aw + gap) + gap, 3 * (nw + 2 * aw + 8 + gap) + gap)
        height = 16 + rows * (nh + gap) + (ah + gap) + 16 + (nh + gap) + gap
        block = Image.new("RGBA", (width, height), bg + (255,))
        ImageDraw.Draw(block).text((gap, 2), "%s  names %dx%d  arrows %dx%d" % (preset, nw, nh, aw, ah),
                                   fill=(220, 220, 220, 255), font=label_font)
        y = 16
        for index, (theme, _label) in enumerate(THEMES):
            cell = images["%s/name_%s.tga" % (preset, theme)].crop((0, 0, nw, nh))
            x = gap + (index % cols) * (nw + gap)
            block.alpha_composite(cell, (x, y + (index // cols) * (nh + gap)))
        y += rows * (nh + gap)
        x = gap
        for side in SIDES:
            for state in STATES:
                cell = images["%s/arrow_%s_%s.tga" % (preset, side, state)].crop((0, 0, aw, ah))
                block.alpha_composite(cell, (x, y))
                x += aw + gap
        y += ah + gap
        ImageDraw.Draw(block).text((gap, y), "assembled on devil / horde / alliance panel colours",
                                   fill=(220, 220, 220, 255), font=label_font)
        y += 16
        x = gap
        for bg2, theme in zip(PREVIEW_BACKGROUNDS, ("devil", "horde", "skyborne")):
            strip = Image.new("RGBA", (nw + 2 * aw + 8, ah), bg2 + (255,))
            strip.alpha_composite(images["%s/arrow_prev_normal.tga" % preset].crop((0, 0, aw, ah)), (0, 0))
            strip.alpha_composite(images["%s/name_%s.tga" % (preset, theme)].crop((0, 0, nw, nh)),
                                  (aw + 4, (ah - nh) // 2))
            strip.alpha_composite(images["%s/arrow_next_normal.tga" % preset].crop((0, 0, aw, ah)),
                                  (aw + 4 + nw + 4, 0))
            block.alpha_composite(strip, (x, y))
            x += strip.size[0] + gap
        blocks.append(block)
    nw, nh = name_area("fhd")
    aw, ah = arrow_area("fhd")
    zoom_src = Image.new("RGBA", (nw + 2 * aw + 8 + 8 * (aw + 2), ah), PREVIEW_BACKGROUNDS[0] + (255,))
    zoom_src.alpha_composite(images["fhd/arrow_prev_normal.tga"].crop((0, 0, aw, ah)), (0, 0))
    zoom_src.alpha_composite(images["fhd/name_skyborne.tga"].crop((0, 0, nw, nh)), (aw + 4, 0))
    zoom_src.alpha_composite(images["fhd/arrow_next_normal.tga"].crop((0, 0, aw, ah)), (aw + 4 + nw + 4, 0))
    x = 2 * aw + nw + 8
    for side in SIDES:
        for state in STATES:
            zoom_src.alpha_composite(images["fhd/arrow_%s_%s.tga" % (side, state)].crop((0, 0, aw, ah)), (x, 0))
            x += aw + 2
    zoom = zoom_src.resize((zoom_src.size[0] * 4, zoom_src.size[1] * 4), Image.NEAREST)
    zoom_block = Image.new("RGBA", (zoom.size[0] + 2 * gap, zoom.size[1] + 16 + gap), PREVIEW_BACKGROUNDS[0] + (255,))
    ImageDraw.Draw(zoom_block).text((gap, 2), "fhd 4x (nearest): switcher + arrow states", fill=(220, 220, 220, 255),
                                    font=label_font)
    zoom_block.alpha_composite(zoom, (gap, 16))
    blocks.append(zoom_block)
    sheet = Image.new("RGBA", (max(b.size[0] for b in blocks), sum(b.size[1] for b in blocks) + gap * len(blocks)),
                      (12, 12, 12, 255))
    y = 0
    for block in blocks:
        sheet.alpha_composite(block, (0, y))
        y += block.size[1] + gap
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    sheet.convert("RGB").save(out_path, "PNG")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--check", action="store_true", help="compare with the files on disk, write nothing")
    parser.add_argument("--preview", help="also write a preview PNG to this path")
    args = parser.parse_args()
    try:
        files, images, sizes = build()
    except ArtError as exc:
        print("ERROR " + str(exc))
        return 2
    tgas = sum(1 for rel in files if rel.endswith(".tga"))
    size_text = " ".join("%s=%.2f" % (p, s) for p, s in sizes.items())
    if args.check:
        problems = check(files)
        for line in problems:
            print("FAIL " + line)
        print("check tga=%d licence=1 font_size %s problems=%d" % (tgas, size_text, len(problems)))
        return 1 if problems else 0
    write(files)
    if args.preview:
        preview(images, args.preview)
    print("wrote tga=%d licence=1 font_size %s -> %s" % (tgas, size_text, os.path.relpath(OUT_ROOT, REPO)))
    return 0


if __name__ == "__main__":
    sys.exit(main())

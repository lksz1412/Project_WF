"""HUD part sizes, placeholder parts and the part art check (development tool, not shipped).

Usage:
  python -I Collection/tools/hud_parts.py --spec                 # print every part's size per preset
  python -I Collection/tools/hud_parts.py --placeholders OUT     # write plain placeholder parts under OUT
  python -I Collection/tools/hud_parts.py --check [ROOT]         # check the part files under ROOT

Part sizes come from Composition.lua (``Composition.parts``), read through a Lua 5.1 runtime
(lupa), so this tool and the drawing code use one table. A part is drawn at one texel per
physical pixel of its preset; its canvas is the next power of two on each axis and the drawing
sits at the canvas's top-left, the rest fully transparent.

Placeholders (flat colour, 1-pixel outline, round rivet) go to
``OUT/Themes/<theme>/Parts/<preset>/<part>.tga``. OUT must not be inside ``Collection/AddOns``
(nothing here is shipped).

``--check`` looks at ``ROOT/Themes/<theme>/Parts/<preset>/*.tga`` (ROOT defaults to
``Collection/AddOns/DevilForever_Appearance``): known part names only, 32-bit uncompressed TGA
(type 2, 8 alpha bits), canvas size, transparency outside the drawing, seamless repeat edges and
no lighting ramp along the repeat axis of strip parts, every required part or none per theme and
preset, and - for the default ROOT - that the PARTS_SHIPPED table in Composition.lua lists exactly
the complete sets on disk. Exit 1 when a problem is found.
"""

import argparse
import hashlib
import os
import struct
import sys

from PIL import Image, ImageDraw

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
ADDONS = os.path.join(REPO, "Collection", "AddOns")
APPEARANCE = os.path.join(ADDONS, "DevilForever_Appearance")
COMPOSITION = os.path.join(APPEARANCE, "Composition.lua")
THEMES = ("devil", "alliance", "horde", "human", "dwarf", "gnome", "nightelf", "orc", "tauren", "troll",
          "undead", "skyborne", "skyborne-horde")
PRESETS = ("fhd", "qhd", "uhd")

# Seam check: mean absolute RGBA difference between the first and last line of a strip may be at
# most SEAM_FACTOR times the median difference between neighbouring lines plus SEAM_SLACK levels.
SEAM_FACTOR, SEAM_SLACK = 2.0, 8.0
# Lighting check: mean luminance of the drawn area may vary by at most this many levels (0-255)
# between the quarters along the repeat axis.
RAMP_LIMIT = 24.0


def load_parts(path=COMPOSITION):
    """Part table of Composition.lua: {sizes, shapes, required, optional, shipped}."""
    from lupa import lua51
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute("DevilForever_Core = {Theme = {ListTokens = function() return {} end}}")
    with open(path, "rb") as fh:
        fn = lua.globals().loadstring(fh.read(), b"@Composition.lua")
    (fn[0] if isinstance(fn, tuple) else fn)()
    parts = lua.globals().DevilForever_Composition.parts

    def plain(value):
        if hasattr(value, "items"):
            keys = list(value.keys())
            if keys and all(isinstance(k, int) for k in keys):
                return [plain(value[k]) for k in sorted(keys)]
            return {k: plain(v) for k, v in value.items()}
        return value

    table = {key: plain(parts[key]) for key in ("sizes", "shapes", "required", "optional", "shipped")}
    table["size"] = lambda preset, name: plain(parts.Size(preset, name))
    return table


def spec(parts):
    """{preset: {part: {width, height, canvasWidth, canvasHeight, tile}}} for every known part."""
    names = parts["required"] + parts["optional"]
    return {preset: {name: parts["size"](preset, name) for name in names} for preset in PRESETS}


def tga_bytes(image):
    """32-bit uncompressed TGA: no ID, type 2, bottom-left origin, 8 alpha bits, TGA 2.0 footer."""
    width, height = image.size
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, width, height, 32, 8)
    rows = [image.crop((0, y, width, y + 1)).tobytes("raw", "BGRA") for y in range(height - 1, -1, -1)]
    return header + b"".join(rows) + b"\x00" * 8 + b"TRUEVISION-XFILE.\x00"


def theme_colour(theme):
    digest = hashlib.sha256(theme.encode()).digest()
    return tuple(70 + digest[i] % 120 for i in range(3))


def placeholder(theme, name, size):
    """Plain part: flat theme colour, darker 1-pixel outline on the non-repeating edges, round rivet."""
    width, height = size["width"], size["height"]
    canvas = Image.new("RGBA", (size["canvasWidth"], size["canvasHeight"]), (0, 0, 0, 0))
    base = theme_colour(theme)
    if name.startswith("surround"):
        base = tuple(min(255, c + 50) for c in base)
    dark = tuple(c // 3 for c in base) + (255,)
    draw = ImageDraw.Draw(canvas)
    if name == "rivet":
        draw.ellipse((0, 0, width - 1, height - 1), fill=base + (255,), outline=dark)
        return canvas
    if name == "deck_crest":
        draw.ellipse((0, 0, width - 1, height - 1), outline=dark, width=max(2, width // 32))
        return canvas
    draw.rectangle((0, 0, width - 1, height - 1), fill=base + (255,))
    tile = size.get("tile")
    if tile != "x":
        draw.line((0, 0, 0, height - 1), fill=dark)
        draw.line((width - 1, 0, width - 1, height - 1), fill=dark)
    if tile != "y":
        draw.line((0, 0, width - 1, 0), fill=dark)
        draw.line((0, height - 1, width - 1, height - 1), fill=dark)
    return canvas


def inside(path, folder):
    path, folder = os.path.normcase(os.path.realpath(path)), os.path.normcase(os.path.realpath(folder))
    return path == folder or path.startswith(folder + os.sep)


def write_placeholders(out, parts, themes=THEMES):
    if inside(out, ADDONS):
        raise SystemExit("refusing to write placeholders inside %s" % ADDONS)
    table, written = spec(parts), []
    for theme in themes:
        for preset in PRESETS:
            folder = os.path.join(out, "Themes", theme, "Parts", preset)
            os.makedirs(folder, exist_ok=True)
            for name, size in table[preset].items():
                path = os.path.join(folder, name + ".tga")
                with open(path, "wb") as fh:
                    fh.write(tga_bytes(placeholder(theme, name, size)))
                written.append(path)
    return written


def read_tga(path):
    """(header problems, RGBA image or None) of a TGA file."""
    with open(path, "rb") as fh:
        data = fh.read()
    if len(data) < 18:
        return ["shorter than a TGA header"], None
    id_length, colour_map, kind = data[0], data[1], data[2]
    width, height, depth, descriptor = struct.unpack("<HHBB", data[12:18])
    problems = []
    if kind != 2 or colour_map != 0:
        problems.append("image type %d (colour map %d), expected uncompressed true-colour type 2" % (kind, colour_map))
    if depth != 32 or descriptor & 0x0F != 8:
        problems.append("%d bits per pixel with %d alpha bits, expected 32 and 8" % (depth, descriptor & 0x0F))
    if problems:
        return problems, None
    start = 18 + id_length
    pixels = data[start:start + width * height * 4]
    if len(pixels) != width * height * 4:
        return ["pixel data cut short"], None
    image = Image.frombytes("RGBA", (width, height), pixels, "raw", "BGRA")
    if not descriptor & 0x20:
        image = image.transpose(Image.FLIP_TOP_BOTTOM)
    return [], image


def line_difference(a, b):
    return sum(abs(x - y) for p, q in zip(a, b) for x, y in zip(p, q)) / (4.0 * max(1, len(a)))


def strip_problems(image, size):
    """Seam and lighting-ramp problems of a repeating strip's drawn area."""
    width, height, axis = size["width"], size["height"], size["tile"]
    area = image.crop((0, 0, width, height))
    pixels = area.load()
    count = width if axis == "x" else height
    lines = [[pixels[i, j] if axis == "x" else pixels[j, i] for j in range(height if axis == "x" else width)]
             for i in range(count)]
    problems = []
    neighbours = sorted(line_difference(lines[i], lines[i + 1]) for i in range(count - 1))
    median = neighbours[len(neighbours) // 2] if neighbours else 0.0
    seam = line_difference(lines[0], lines[-1])
    if seam > SEAM_FACTOR * median + SEAM_SLACK:
        problems.append("repeat seam: first/last line differ by %.1f (neighbouring lines %.1f)" % (seam, median))
    quarter = max(1, count // 4)
    means = []
    for start in range(0, count - quarter + 1, quarter):
        values = [0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2] for line in lines[start:start + quarter] for p in line if p[3]]
        if values:
            means.append(sum(values) / len(values))
    if means and max(means) - min(means) > RAMP_LIMIT:
        problems.append("lighting changes by %.1f levels along the repeat axis" % (max(means) - min(means)))
    return problems


def check(root, parts, compare_shipped):
    table, problems, complete = spec(parts), [], {}
    themes_dir = os.path.join(root, "Themes")
    required, known = set(parts["required"]), set(parts["required"]) | set(parts["optional"])
    files = 0
    for theme in sorted(os.listdir(themes_dir)) if os.path.isdir(themes_dir) else []:
        for preset in PRESETS:
            folder = os.path.join(themes_dir, theme, "Parts", preset)
            if not os.path.isdir(folder):
                continue
            present = set()
            for entry in sorted(os.listdir(folder)):
                rel = "%s/Parts/%s/%s" % (theme, preset, entry)
                name, ext = os.path.splitext(entry)
                if ext.lower() != ".tga" or name not in known:
                    problems.append("%s: not a part file of the spec" % rel)
                    continue
                files += 1
                present.add(name)
                size = table[preset][name]
                header, image = read_tga(os.path.join(folder, entry))
                problems.extend("%s: %s" % (rel, text) for text in header)
                if image is None:
                    continue
                if image.size != (size["canvasWidth"], size["canvasHeight"]):
                    problems.append("%s: canvas %dx%d, expected %dx%d" % (rel, image.size[0], image.size[1],
                                                                          size["canvasWidth"], size["canvasHeight"]))
                    continue
                alpha = image.getchannel("A").load()
                outside = sum(1 for x in range(image.size[0]) for y in range(image.size[1])
                              if (x >= size["width"] or y >= size["height"]) and alpha[x, y])
                if outside:
                    problems.append("%s: %d visible pixels outside the %dx%d drawing" % (rel, outside, size["width"], size["height"]))
                if size.get("tile"):
                    problems.extend("%s: %s" % (rel, text) for text in strip_problems(image, size))
            if present and not required <= present:
                problems.append("%s/Parts/%s: missing required parts %s (the code draws the prepared surfaces)"
                                % (theme, preset, ", ".join(sorted(required - present))))
            elif present:
                complete.setdefault(theme, {})[preset] = sorted(present)
    if compare_shipped:
        shipped = {theme: {preset: sorted(names) for preset, names in presets.items()}
                   for theme, presets in (parts["shipped"] or {}).items()}
        if shipped != complete:
            problems.append("PARTS_SHIPPED in Composition.lua %r differs from the complete part sets on disk %r"
                            % (shipped, complete))
    return files, problems


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--spec", action="store_true", help="print the part sizes")
    group.add_argument("--placeholders", metavar="OUT", help="write placeholder parts under OUT")
    group.add_argument("--check", nargs="?", const=APPEARANCE, metavar="ROOT", help="check part files under ROOT")
    args = parser.parse_args()
    parts = load_parts()
    if args.spec:
        for preset, sizes in spec(parts).items():
            for name, size in sizes.items():
                print("%s %-20s %4dx%-4d canvas %4dx%-4d %s" % (preset, name, size["width"], size["height"],
                                                               size["canvasWidth"], size["canvasHeight"],
                                                               "repeat " + size["tile"] if size.get("tile") else ""))
        return 0
    if args.placeholders:
        written = write_placeholders(args.placeholders, parts)
        print("placeholders=%d out=%s" % (len(written), args.placeholders))
        return 0
    compare = os.path.normcase(os.path.realpath(args.check)) == os.path.normcase(os.path.realpath(APPEARANCE))
    files, problems = check(args.check, parts, compare)
    for text in problems:
        print("PROBLEM " + text)
    print("part files=%d problems=%d shipped table compared=%s" % (files, len(problems), compare))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())

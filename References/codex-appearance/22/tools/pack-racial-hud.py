"""Build physical-resolution HUD textures and button edging from the painted masters."""

import argparse
from hashlib import file_digest
import json
from math import ceil
from pathlib import Path
import re
import runpy

from PIL import Image, ImageDraw, ImageFilter


COMMON = runpy.run_path(str(Path(__file__).with_name("pack-composed-hud.py")))
FAMILIES = ("devil", "horde", "alliance")
RACES = ("human", "dwarf", "gnome", "nightelf", "orc", "tauren", "troll", "undead", "skyborne", "skyborne-horde")
PANEL_ALPHA = (208, 186)
CHAT_ROLES = {"public": "chat1", "group": "chat2", "system": "chat3"}


def align_action_rail(art):
    """Move the painted rail behind the fixed action slots and keep the lower deck aligned."""
    alpha = art.getchannel("A")
    coverage = []
    for y in range(200):
        scan = alpha.crop((680, y, 1330, y + 1))
        coverage.append(sum(scan.histogram()[96:]) / scan.width)
    y = next((row for row in range(196) if min(coverage[row:row + 5]) >= .82), None)
    if y is None:
        raise ValueError("No continuous painted action rail")
    deck_top = COMMON["DECK_Y"][0]
    upper_top = COMMON["TOP_Y"][2] - 4
    piece = art.crop((0, max(0, y - 4), art.width, deck_top))
    result = art.copy()
    result.paste(Image.new("RGBA", (art.width, upper_top)), (0, 0))
    result.paste(piece.resize((art.width, deck_top - upper_top), Image.Resampling.BICUBIC), (0, upper_top))
    return result, y


def cap_chat_alpha(deck, rectangles, start, charcoal):
    """Keep painted rails opaque and let the game show through the three text areas."""
    for key in ("chat1", "chat2", "chat3"):
        left, y, right, bottom = rectangles[key]
        height = bottom - y
        sides = max(6, ceil((right - left) * .048))
        vertical = max(7, ceil(height * .05))
        bounds = (left, y - start, right, bottom - start)
        original = deck.crop(bounds)
        w, h = original.size
        face_mask = Image.new("L", (w, h))
        ImageDraw.Draw(face_mask).rectangle((sides, vertical, w - sides - 1, h - vertical - 1), fill=255)
        face_mask = face_mask.filter(ImageFilter.GaussianBlur(max(2, round(height * .013))))
        face = Image.new("RGBA", original.size, (18, 19, 21, 255)) if charcoal else original.copy()
        alpha = Image.new("L", (1, h))
        alpha.putdata([round(PANEL_ALPHA[0] + (PANEL_ALPHA[1] - PANEL_ALPHA[0]) * row / (h - 1))
                       for row in range(h)])
        face.putalpha(alpha.resize((w, h), Image.Resampling.NEAREST))
        deck.paste(Image.composite(face, original, face_mask), bounds[:2])


def chat_text_regions(preset):
    layout = Path(__file__).resolve().parents[2] / "4" / f"chat-windows.fragment.{preset}.lua"
    specification = layout.read_text(encoding="utf-8-sig")
    windows = re.findall(
        r'(public|group|system) = \{point = "TOPLEFT", x = (\d+) \* pixel, y = -(\d+) \* pixel, '
        r'width = (\d+) \* pixel, height = (\d+) \* pixel\}', specification,
    )
    if {role for role, *_ in windows} != CHAT_ROLES.keys() or len(windows) != len(CHAT_ROLES):
        raise ValueError(f"Unrecognized chat window layout in {layout}")
    return {CHAT_ROLES[role]: tuple(map(int, coords)) for role, *coords in windows}


def shade_chat_text_regions(deck, rectangles, start, regions):
    """Protect the native text boxes against bright terrain without masking the outer relief."""
    for key, (left, top, width, height) in regions.items():
        panel_left, panel_top, panel_right, panel_bottom = rectangles[key]
        right, bottom = left + width, top + height
        if not (panel_left <= left < right <= panel_right and panel_top <= top < bottom <= panel_bottom):
            raise ValueError(f"Native text box crosses panel bounds: {key}")
        feather = max(4, round(height * .025))
        x0, y0 = max(panel_left, left - feather), max(panel_top, top - feather)
        x1, y1 = min(panel_right, right + feather), min(panel_bottom, bottom + feather)
        bounds = (x0, y0 - start, x1, y1 - start)
        colors = deck.crop(bounds)
        maximum = 76 if key == "chat3" else 93
        minimum = 208 if key == "chat3" else 200
        output = []
        for index, color in enumerate(colors.get_flattened_data()):
            x, y = x0 + index % colors.width, y0 + index // colors.width
            distance = max(left - x, x - right + 1, top - y, y - bottom + 1, 0)
            weight = 1 - distance / feather
            r, g, b, a = color
            safe_alpha = max(a, minimum)
            opacity = safe_alpha / 255
            brightness = max(.2126 * r + .7152 * g + .0722 * b, 1)
            factor = min(1, (maximum - 255 * (1 - opacity)) / (opacity * brightness))
            tone = 1 - weight * (1 - factor)
            output.append((round(r * tone), round(g * tone), round(b * tone),
                           round(a + (safe_alpha - a) * weight)))
        colors.putdata(output)
        deck.paste(colors, bounds[:2])


def pet_edge(art):
    """Cut a narrow decorated strip from the main rail and frame a transparent center."""
    strip = art.crop((410, 191, 1130, 201)).resize((64, 5), Image.Resampling.LANCZOS)
    # The source color and joinery stay visible in a narrow strip under each native icon.
    strip.putalpha(Image.new("L", strip.size, 190))
    edge = Image.new("RGBA", (64, 64))
    edge.paste(strip, (0, 0))
    edge.paste(strip.transpose(Image.Transpose.FLIP_TOP_BOTTOM), (0, 59))
    side = strip.crop((5, 0, 59, 5)).transpose(Image.Transpose.ROTATE_90)
    edge.paste(side, (0, 5))
    edge.paste(side.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (59, 5))
    return edge


def sha(path):
    with path.open("rb") as stream:
        return file_digest(stream, "sha256").hexdigest()


def save(texture, path):
    if path.exists():
        raise FileExistsError(path)
    texture.save(path)
    return sha(path)


def build(args):
    geometry = json.loads(args.geometry.read_text(encoding="utf-8-sig"))
    features = json.loads(args.features.read_text(encoding="utf-8-sig"))["layouts"]
    regions = {preset: chat_text_regions(preset) for preset in geometry}
    receipt = {}
    for variant in args.variants:
        src = args.source / f"{variant}-whole.png"
        prefix = args.output / variant
        composition = prefix / "Composition"
        composition.mkdir(parents=True, exist_ok=True)
        with Image.open(src) as source:
            art, rail_y = align_action_rail(source.convert("RGBA").resize(COMMON["SIZE"], Image.Resampling.LANCZOS))
        entry = {"source_sha256": sha(src), "source_rail_y": rail_y,
                 "pet_edge_sha256": save(pet_edge(art), prefix / "PetEdge.tga"), "pieces": {}}
        for preset, value in geometry.items():
            rectangles = value["rectangles"]
            top, deck, top_bounds, deck_bounds = COMMON["compose"](art, rectangles, features[preset]["rects"])
            # The empty optional row above the long action bar is game space.
            alpha = top.getchannel("A")
            trim = rectangles["upper"][1] - top_bounds[1] - max(2, top.height // 30)
            alpha.paste(0, (0, 0, alpha.width, trim))
            top.putalpha(alpha)
            cap_chat_alpha(deck, rectangles, deck_bounds[1], variant == "devil")
            shade_chat_text_regions(deck, rectangles, deck_bounds[1], regions[preset])
            for part, image, bounds, size in (("top", top, top_bounds, (2048, 256)),
                                               ("deck", deck, deck_bounds, (2048, 512))):
                filename = f"{preset}_{part}.tga"
                digest = save(image.resize(size, Image.Resampling.BICUBIC), composition / filename)
                entry["pieces"][filename] = {"bounds": bounds, "sha256": digest}
        receipt[variant] = entry
        print(variant, "six surfaces plus pet edge")
    (args.output / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    cli = argparse.ArgumentParser()
    cli.add_argument("source", type=Path)
    cli.add_argument("output", type=Path)
    cli.add_argument("geometry", type=Path)
    cli.add_argument("features", type=Path)
    cli.add_argument("variants", choices=FAMILIES + RACES, nargs="+")
    build(cli.parse_args())

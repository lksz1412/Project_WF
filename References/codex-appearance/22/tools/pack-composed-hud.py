"""Cut each painted lower HUD along the calibrated gameplay layout."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw


THEMES = ("devil", "horde", "alliance")
SIZE = (1536, 512)
BLOCKING = ("player", "target", "pet", "petTarget", "dominos.pet", "quartz.pet")
TOP_X = (0, 112, 285, 575, 1424, 1536)
TOP_Y = (0, 31, 80, 199, 244)
DECK_X = (0, 384, 768, 1038, 1161, 1536)
DECK_Y = (244, 469, 512)


def warp(image, sx, sy, tx, ty):
    target = Image.new("RGBA", (tx[-1], ty[-1]))
    for i in range(len(sx) - 1):
        for j in range(len(sy) - 1):
            piece = image.crop((sx[i], sy[j], sx[i + 1], sy[j + 1]))
            piece = piece.resize((tx[i + 1] - tx[i], ty[j + 1] - ty[j]), Image.Resampling.BICUBIC)
            target.paste(piece, (tx[i], ty[j]))
    return target


def compose(image, rectangles, features, smooth_chat=False):
    aux = rectangles["aux"]
    upper = rectangles["upper"]
    chat1, chat3 = rectangles["chat1"], rectangles["chat3"]
    status = rectangles["status"]
    start = aux[1] - (aux[3] - aux[1]) // 4
    width = chat3[2]
    top_x = (0, upper[0], aux[0], aux[2], upper[2], width)
    top_y = tuple(y - start for y in (start, aux[1], upper[1], upper[3], chat1[1]))
    top = warp(image, TOP_X, TOP_Y, top_x, top_y)
    alpha = top.getchannel("A").point(lambda value: value if value >= 8 else 0)
    # Paint outside the two action bays stays clear of the native unit stack.
    brush = ImageDraw.Draw(alpha)
    for key in BLOCKING:
        x, y, wide, tall = features[key]
        brush.rectangle((x - 4, y - start - 4, x + wide + 4, y + tall - start + 4), fill=0)
    top.putalpha(alpha)

    deck_x = (0, rectangles["chat2"][0], rectangles["action"][0], rectangles["minimap"][0], chat3[0], width)
    deck_y = (0, status[1] - chat1[1], status[3] - chat1[1])
    deck = warp(image, DECK_X, DECK_Y, deck_x, deck_y)
    if smooth_chat:
        draw = ImageDraw.Draw(deck)
        for key in ("chat1", "chat2", "chat3"):
            left, y, right, bottom = rectangles[key]
            inset = max(3, (bottom - y) // 23)
            draw.rectangle((left + inset, y - chat1[1] + inset,
                            right - inset - 1, bottom - chat1[1] - inset - 1),
                           fill=(18, 19, 21, 255))
    return top, deck, (0, start, width, chat1[1]), (0, chat1[1], width, status[3])


def checksum(path):
    with path.open("rb") as payload:
        return hashlib.file_digest(payload, "sha256").hexdigest()


def run():
    cli = argparse.ArgumentParser()
    cli.add_argument("source", type=Path)
    cli.add_argument("output", type=Path)
    cli.add_argument("geometry", type=Path)
    cli.add_argument("features", type=Path)
    args = cli.parse_args()
    geometry = json.loads(args.geometry.read_text(encoding="utf-8-sig"))
    features = json.loads(args.features.read_text(encoding="utf-8-sig"))["layouts"]
    receipt = {}
    for theme in THEMES:
        filename = args.source / f"{theme}-whole.png"
        directory = args.output / theme / "Composition"
        directory.mkdir(parents=True, exist_ok=True)
        with Image.open(filename) as incoming:
            art = incoming.convert("RGBA").resize(SIZE, Image.Resampling.LANCZOS)
        receipt[theme] = {"source_sha256": checksum(filename), "pieces": {}}
        for name, values in geometry.items():
            top, deck, top_bounds, deck_bounds = compose(
                art, values["rectangles"], features[name]["rects"], smooth_chat=theme == "devil")
            for part, plate, bounds in (("top", top, top_bounds), ("deck", deck, deck_bounds)):
                size = (2048, 256) if part == "top" else (2048, 512)
                texture = plate.resize(size, Image.Resampling.BICUBIC)
                target = directory / f"{name}_{part}.tga"
                if target.exists():
                    raise FileExistsError(target)
                texture.save(target)
                receipt[theme]["pieces"][target.name] = {"bounds": bounds, "sha256": checksum(target)}
            print(theme, name, top_bounds, deck_bounds)
    (args.source / "composition-receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    run()

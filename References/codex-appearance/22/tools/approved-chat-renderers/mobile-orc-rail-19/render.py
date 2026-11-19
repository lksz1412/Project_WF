from base64 import b64decode, b64encode
from functools import lru_cache
from io import BytesIO
import os
from pathlib import Path
import re
import sys

import cv2
from lupa.lua51 import LuaRuntime
import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont


current, fragment, sheet = map(Path, sys.argv[1:])
source = current.read_text(encoding="utf-8")
asset_pattern = re.compile(
    r'(data-theme="([a-z-]+)"[^>]*>\s*<span[^>]*><span[^>]*><img src=")([^"]+)"'
)
original_images = {theme: data for _, theme, data in asset_pattern.findall(source)}
assert len(original_images) == 13


def read_renderer(relative):
    path = Path(relative).resolve()
    preamble, sentinel, _ = path.read_text(encoding="utf-8").partition("\nlua = LuaRuntime()\n")
    assert sentinel, path
    ns = {"__file__": str(path)}
    args = sys.argv[:]
    try:
        sys.argv[:] = [str(path), str(fragment), str(current)]
        exec(compile(preamble, str(path), "exec"), ns)
    finally:
        sys.argv[:] = args
    return ns


corners = read_renderer("_local_only/mobile-skyborne-human-19/render.py")
ratios = {"orc": 0.64}
names = {"orc": "오크"}


@lru_cache(maxsize=None)
def side_map(theme, height):
    x = np.arange(192, dtype=np.float64)
    y = np.arange(height, dtype=np.float64)
    shifted = corners["inverse_scale"](x, 110, 191, ratios[theme])
    strength = corners["smooth"]((y - 72) / 30) * (1 - corners["smooth"]((y - 201) / 44))
    mapped = x[None, :] + strength[:, None] * (shifted - x)[None, :]
    return mapped.astype(np.float32), np.broadcast_to(y[:, None], mapped.shape).astype(np.float32)


def trim_sides(image, theme):
    width, height = image.size
    maps = side_map(theme, height)
    depth = maps[0].shape[1]
    assert width > 2 * depth
    for side, x in (("left", 0), ("right", width - depth)):
        area = (x, 0, x + depth, height)
        panel = corners["remap_outer"](image.crop(area), maps, side)
        image.paste(panel, area[:2])
    return image


def narrow_chat(canvas, rects, preset, theme):
    working = Image.new("RGBA", canvas.size)
    if not corners["smaller_corners"](working, rects, preset, theme):
        return False
    for key in ("chat1", "chat2", "chat3"):
        box = rects[key].box
        canvas_panel = trim_sides(working.crop(box), theme)
        working.paste(canvas_panel, box[:2])
    canvas.alpha_composite(working)
    return True


def crest(canvas, panel, theme):
    before = corners["backdrop_mask"](panel, theme)
    info = corners["assets"]["crest_records"][theme]
    texture = corners["assets"]["art"].image(info["texture"])
    selected = texture.crop((0, 0, round(texture.width * 0.70), round(texture.height * 0.70)))
    side = round(panel.h * 0.78)
    mark = selected.resize((side, side), Image.Resampling.BILINEAR)
    mark.putalpha(mark.getchannel("A").point(lambda value: round(value * 0.16)))
    x, y = panel.w - side - 22, panel.h - side - 10
    matte = trim_sides(before.copy(), theme)
    old_edge = panel.w - np.flatnonzero(np.asarray(before)[108] >= 128)[-1] - 1
    new_edge = panel.w - np.flatnonzero(np.asarray(matte)[108] >= 128)[-1] - 1
    assert new_edge < old_edge
    original = canvas.crop(panel.box)
    marked = original.copy()
    marked.alpha_composite(mark, (x, y))
    canvas.paste(Image.composite(marked, original, matte), panel.box[:2])
    return old_edge, new_edge


def decode(data):
    assert data.startswith("data:image/webp;base64,")
    with Image.open(BytesIO(b64decode(data.split(",", 1)[1], validate=True))) as image:
        return image.convert("RGB")


def data_url(image):
    frame = image.resize((2400, 1350), Image.Resampling.LANCZOS)
    with BytesIO() as stream:
        frame.save(stream, "WEBP", quality=82, method=6)
        return "data:image/webp;base64," + b64encode(stream.getvalue()).decode("ascii")


renderer = corners["render"]
lua = LuaRuntime()
rects, _, width, height = renderer["geometry"](lua, "uhd")
screens = {}
replacement = dict(original_images)
for theme in ratios:
    tones = renderer["theme"](lua, theme)
    corners["assets"]["composition"] = corners["smaller_corners"]
    corners["assets"]["chat_crest"] = corners["layered_crest"]
    prior = corners["engine"]["draw_view"](lua, "uhd", theme, "quest")[0].convert("RGB")
    canvas = Image.new("RGBA", (width, height), "white")
    assert narrow_chat(canvas, rects, "uhd", theme)
    edge = crest(canvas, rects["chat3"], theme)
    foreground = tuple(round(tones["color.text.normal"][i] * 255) for i in (1, 2, 3))
    contrast = []
    for x, y, w, h in corners["chat_text_boxes"]()["uhd"]:
        sample = canvas.crop((x, y, x + w, y + h)).convert("RGB")
        luma = corners["luma"]
        contrast.append((luma(foreground) + 0.05) / (luma(sample).max() + 0.05))
    assert min(contrast) >= 4.5, (theme, contrast)
    corners["assets"]["composition"] = narrow_chat
    corners["assets"]["chat_crest"] = crest
    candidate = corners["engine"]["draw_view"](lua, "uhd", theme, "quest")[0].convert("RGB")
    difference = ImageChops.difference(prior, candidate)
    box = difference.getbbox()
    assert box is not None
    assert rects["chat3"].y + 72 < box[1] < box[3] <= rects["chat3"].y + 245, box
    for key in ("action", "minimap"):
        assert difference.crop(rects[key].box).getbbox() is None, key
    replacement[theme] = data_url(candidate)
    screens[theme] = (decode(original_images[theme]), decode(replacement[theme]))
    print(f"{theme}: right rail {edge[0]} -> {edge[1]} px, minimum text contrast {min(contrast):.2f}:1")


assert {name for name, data in replacement.items() if data != original_images[name]} == set(ratios)
updated = asset_pattern.sub(lambda match: match[1] + replacement[match[2]] + '"', source)
updated = updated.replace("4K 수정 목업 · 드워프, 노움, 트롤", "4K 수정 목업 · 오크 세로 테두리")
assert len(updated.encode("utf-8")) < 1_000_000
with fragment.open("x", encoding="utf-8", newline="\n") as out:
    out.write(updated)


win = Path(os.environ["WINDIR"]) / "Fonts"
bold = ImageFont.truetype(str(win / "malgunbd.ttf"), 39)
normal = ImageFont.truetype(str(win / "malgun.ttf"), 30)
board = Image.new("RGB", (1080, 330), "#15181c")
draw = ImageDraw.Draw(board)
draw.text((22, 11), "세로 테두리 비교", font=bold, fill="#f6f7f8")
for x, caption in ((22, "수정 전"), (548, "수정 후")):
    draw.text((x, 65), caption, font=normal, fill="#d3d8de")
for row, (theme, images) in enumerate(screens.items()):
    y = 110 + row * 210
    draw.text((22, y), names[theme], font=normal, fill="#f7f8f9")
    for x, image in zip((22, 548), images):
        chat = image.crop((1814, 1138, 2400, 1328)).resize((510, 165), Image.Resampling.LANCZOS)
        board.paste(chat, (x, y + 42))
with sheet.open("xb") as out:
    board.save(out, "PNG", optimize=True)

from base64 import b64encode
from concurrent.futures import ThreadPoolExecutor
from io import BytesIO
from math import ceil
from pathlib import Path
from zipfile import ZipFile
import re
import runpy
import sys

from lupa.lua51 import LuaRuntime
import numpy as np
from PIL import Image, ImageChops, ImageDraw


scratch = Path(__file__).resolve().parent
archive = Path("_local_only/appearance-candidate-0qz4p4yr/outputs/collection/DevilForever-0.1.0-one-session.zip")
output = Path(sys.argv[1])
engine = runpy.run_path("_local_only/offline-candidate-24wsjlg9/render_review.py")
render = engine["render"]
render["configure_package"](archive)
assets = render["chat_crest"].__globals__
root = Path("References/codex-appearance/24/racial-appearance/screens")
template = (scratch / "template.html").read_text(encoding="utf-8")
themes = re.findall(r'data-theme="([a-z-]+)"', template)
assert len(themes) == len(set(themes)) == 13


# Inside edges of the painted ornaments in the rightmost 436 × 304 of the 4K panel.
# The engine paints the texture under the lifted foreground, as it does under native chat text.
inner_edges = {
    "horde": [(0, 23), (384, 23), (399, 41), (399, 274), (389, 293), (0, 293)],
    "alliance": [(0, 20), (387, 20), (403, 30), (409, 50), (409, 284), (402, 294), (0, 294)],
    "orc": [(0, 26), (234, 26), (264, 40), (301, 70), (328, 97), (350, 118),
            (348, 130), (333, 154), (302, 183), (276, 200), (252, 209), (236, 209),
            (211, 219), (182, 233), (142, 250), (101, 257), (0, 284)],
    "troll": [(0, 17), (320, 17), (339, 30), (351, 55), (354, 86), (354, 163),
              (343, 173), (334, 188), (337, 201), (319, 218), (288, 236),
              (253, 248), (204, 261), (160, 278), (126, 291), (0, 291)],
    "undead": [(0, 18), (378, 18), (396, 33), (399, 49), (399, 215),
               (386, 236), (358, 249), (317, 258), (275, 264), (224, 269),
               (169, 278), (117, 291), (67, 302), (0, 302)],
    "tauren": [(0, 12), (155, 12), (166, 21), (249, 21), (276, 12),
               (390, 12), (398, 24), (400, 270), (395, 289), (384, 294), (0, 294)],
    "human": [(0, 19), (257, 19), (295, 25), (317, 36), (334, 50), (342, 67),
              (342, 200), (337, 216), (336, 229), (329, 241), (312, 252),
              (302, 267), (283, 281), (252, 290), (223, 294), (0, 294)],
    "dwarf": [(0, 13), (342, 13), (365, 26), (373, 39), (373, 246),
              (349, 261), (0, 261)],
    "gnome": [(0, 15), (389, 15), (399, 26), (400, 62), (400, 197), (396, 214),
              (384, 229), (367, 242), (342, 251), (317, 257), (281, 262),
              (247, 267), (217, 279), (180, 299), (0, 299)],
    "nightelf": [(0, 15), (398, 15), (401, 46), (399, 127), (396, 157),
                 (386, 179), (370, 197), (353, 210), (334, 221), (320, 234), (314, 241),
                 (274, 232), (246, 227), (215, 228), (192, 237), (187, 241),
                 (216, 242), (245, 250), (261, 259), (217, 257), (181, 264),
                 (156, 273), (116, 281), (0, 282)],
    "skyborne": [(0, 17), (356, 17), (380, 23), (396, 36), (405, 51), (405, 184),
                 (399, 204), (385, 224), (360, 242), (335, 257), (306, 268),
                 (260, 283), (222, 290), (177, 296), (0, 296)],
    "skyborne-horde": [(0, 17), (385, 17), (399, 29), (402, 46), (401, 135),
                       (394, 158), (383, 180), (366, 198), (337, 217),
                       (299, 234), (251, 248), (206, 256), (150, 263), (94, 274), (0, 296)],
}


def backdrop_mask(panel, theme):
    scale = 3
    mask = Image.new("L", (panel.w * scale, panel.h * scale))
    points = [(round((x + 502) * panel.w / 938 * scale), round(y * panel.h / 304 * scale))
              for x, y in inner_edges[theme]]
    points[0] = (0, points[0][1])
    points[-1] = (0, points[-1][1])
    ImageDraw.Draw(mask).polygon(points, fill=255)
    return mask.resize((panel.w, panel.h), Image.Resampling.LANCZOS)


def layered_crest(canvas, panel, theme):
    if theme == "devil":
        return
    texture = assets["art"].image(assets["crest_records"][theme]["texture"])
    selected = texture.crop((0, 0, round(texture.width * 0.70), round(texture.height * 0.70)))
    side = round(panel.h * 0.78)
    mark = selected.resize((side, side), Image.Resampling.BILINEAR)
    mark.putalpha(mark.getchannel("A").point(lambda value: round(value * 0.16)))
    foreground = canvas.crop(panel.box)
    background = foreground.copy()
    matte = backdrop_mask(panel, theme)
    original = np.asarray(mark.getchannel("A"), dtype=np.float64)
    right = ceil(panel.w * 0.052)
    bottom = ceil(panel.h * 0.053)
    y = panel.h - side - bottom
    # Sculpted corners can reach across the watermark. Keep its visible body near the curve.
    for step in range(7):
        x = panel.w - side - right - step * round(panel.h * 0.045)
        area = np.asarray(matte.crop((x, y, x + side, y + side)), dtype=np.float64)
        if (area * original).sum() >= 0.70 * 255 * original.sum():
            break
    background.alpha_composite(mark, (x, y))
    result = Image.composite(background, foreground, matte)
    assert not np.any(
        (np.asarray(matte) == 0) & np.any(np.asarray(result) != np.asarray(foreground), axis=2)
    ), (theme, "foreground frame pixels changed")
    canvas.paste(result, panel.box[:2])


def luma(rgb):
    rgb = np.asarray(rgb, dtype=np.float64) / 255
    linear = np.where(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055) ** 2.4)
    return linear @ np.array([0.2126, 0.7152, 0.0722])


def chat_text_boxes():
    with ZipFile(archive) as source:
        layout = source.read("Interface/AddOns/DevilForever_ChatSetup/ChatLayout.lua").decode("utf-8-sig")
    boxes = {}
    for preset, block in re.findall(r"  (fhd|qhd|uhd) = function\(\)(.*?)  end,", layout, re.S):
        windows = re.findall(
            r'(public|group|system) = .*?x = (\d+) \* pixel, y = -(\d+) \* pixel, '
            r'width = (\d+) \* pixel, height = (\d+) \* pixel', block)
        assert [name for name, *_ in windows] == ["public", "group", "system"]
        boxes[preset] = [tuple(map(int, rect)) for _, *rect in windows]
    assert set(boxes) == {"fhd", "qhd", "uhd"}
    return boxes


lua = LuaRuntime()
boxes = chat_text_boxes()
rendered = {}
assets["chat_crest"] = layered_crest
for preset in ("uhd",):
    rects, _, width, height = render["geometry"](lua, preset)
    chat = rects["chat3"]
    min_contrast = float("inf")
    for theme in themes:
        tones = render["theme"](lua, theme)
        canvas = Image.new("RGBA", (width, height))
        assert render["composition"](canvas, rects, preset, theme)
        bright = Image.new("RGBA", (width, height), "white")
        bright.alpha_composite(canvas)
        layered_crest(bright, chat, theme)
        fg = [round(tones["color.text.normal"][i] * 255) for i in (1, 2, 3)]
        for x, y, w, h in boxes[preset]:
            sample = np.asarray(bright.crop((x, y, x + w, y + h)).convert("RGB"))
            contrast = (luma(fg) + 0.05) / (luma(sample).max() + 0.05)
            assert contrast >= 4.5, (preset, theme, (x, y), contrast)
            min_contrast = min(min_contrast, contrast)
        if preset == "uhd":
            preview = engine["draw_view"](lua, preset, theme, "quest")[0].convert("RGB")
            with Image.open(root / f"{preset}-{theme}.png") as previous:
                difference = ImageChops.difference(previous.convert("RGB"), preview).getbbox()
                if theme == "devil":
                    assert difference is None
                else:
                    assert difference is not None, theme
                    assert chat.x <= difference[0] < difference[2] <= chat.box[2], (theme, difference)
                    assert chat.y <= difference[1] < difference[3] <= chat.box[3], (theme, difference)
                if theme in {"orc", "nightelf"}:
                    comparison = Image.new("RGB", (chat.w, chat.h * 2))
                    comparison.paste(previous.crop(chat.box), (0, 0))
                    comparison.paste(preview.crop(chat.box), (0, chat.h))
                    comparison.save(scratch / f"{theme}-comparison.png")
            rendered[theme] = preview
    print(preset, f"39 chat text boxes checked, minimum contrast {min_contrast:.2f}", flush=True)


tokens = {
    "chat_width": str(chat.w),
    "chat_height": str(chat.h),
    "chat_image_left": f"{-100 * chat.x / chat.w:.6f}",
    "chat_image_bottom": f"{-100 * (height - chat.box[3]) / chat.h:.6f}",
    "chat_image_width": f"{100 * width / chat.w:.6f}",
}


def encode(theme, width, quality):
    image = rendered[theme].resize((width, width * 9 // 16), Image.Resampling.LANCZOS)
    with BytesIO() as stream:
        image.save(stream, "WEBP", quality=quality, method=6)
        return theme, "data:image/webp;base64," + b64encode(stream.getvalue()).decode("ascii")


for export_width, quality in ((2400, 82), (2304, 79)):
    with ThreadPoolExecutor(max_workers=6) as pool:
        tokens.update(pool.map(lambda theme: encode(theme, export_width, quality), themes))
    html, count = re.subn(r"@([\w-]+)@", lambda match: tokens[match.group(1)], template)
    assert count == len(tokens), (count, len(tokens))
    payload = html.encode("utf-8")
    if len(payload) < 1_000_000:
        with output.open("xb") as stream:
            stream.write(payload)
        print(f"{output} | {len(payload):,} bytes | 13 themes")
        break
else:
    raise RuntimeError("Gallery exceeds the inline size limit")

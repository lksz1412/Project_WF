"""승인된 채팅 테두리와 무늬를 기존 덱 크기로 합성한다."""

import argparse
import ast
from dataclasses import dataclass
from functools import lru_cache
import hashlib
from html import unescape
import json
from math import ceil, floor
from pathlib import Path
import re
from types import SimpleNamespace

import cv2
from lupa.lua51 import LuaRuntime
import numpy as np
from PIL import Image, ImageChops, ImageDraw
from scipy.interpolate import PchipInterpolator


ROOT = Path(__file__).resolve().parents[4]
ADDON = ROOT / "Collection/AddOns/DevilForever_Appearance"
PRESETS = ("fhd", "qhd", "uhd")
THEMES = ("horde", "alliance", "human", "dwarf", "gnome", "nightelf", "orc",
          "tauren", "troll", "undead", "skyborne", "skyborne-horde")
CORNERS = {"orc": (0.34, 0.40), "human": (0.31, 1.0), "skyborne": (0.54, 0.62),
           "skyborne-horde": (0.46, 0.56), "troll": (0.60, 0.64), "undead": (0.66, 0.65)}
SIDES = {"orc": 0.64, "dwarf": 0.49, "gnome": 0.56, "troll": 0.58}
INNER_EDGES = {'horde': [(0, 23), (384, 23), (399, 41), (399, 274), (389, 293), (0, 293)],
 'alliance': [(0, 20), (387, 20), (403, 30), (409, 50), (409, 284), (402, 294), (0, 294)],
 'orc': [(0, 26),
         (234, 26),
         (264, 40),
         (301, 70),
         (328, 97),
         (350, 118),
         (348, 130),
         (333, 154),
         (302, 183),
         (276, 200),
         (252, 209),
         (236, 209),
         (211, 219),
         (182, 233),
         (142, 250),
         (101, 257),
         (0, 284)],
 'troll': [(0, 17),
           (320, 17),
           (339, 30),
           (351, 55),
           (354, 86),
           (354, 163),
           (343, 173),
           (334, 188),
           (337, 201),
           (319, 218),
           (288, 236),
           (253, 248),
           (204, 261),
           (160, 278),
           (126, 291),
           (0, 291)],
 'undead': [(0, 18),
            (378, 18),
            (396, 33),
            (399, 49),
            (399, 215),
            (386, 236),
            (358, 249),
            (317, 258),
            (275, 264),
            (224, 269),
            (169, 278),
            (117, 291),
            (67, 302),
            (0, 302)],
 'tauren': [(0, 12),
            (155, 12),
            (166, 21),
            (249, 21),
            (276, 12),
            (390, 12),
            (398, 24),
            (400, 270),
            (395, 289),
            (384, 294),
            (0, 294)],
 'human': [(0, 19),
           (257, 19),
           (295, 25),
           (317, 36),
           (334, 50),
           (342, 67),
           (342, 200),
           (337, 216),
           (336, 229),
           (329, 241),
           (312, 252),
           (302, 267),
           (283, 281),
           (252, 290),
           (223, 294),
           (0, 294)],
 'dwarf': [(0, 13), (342, 13), (365, 26), (373, 39), (373, 246), (349, 261), (0, 261)],
 'gnome': [(0, 15),
           (389, 15),
           (399, 26),
           (400, 62),
           (400, 197),
           (396, 214),
           (384, 229),
           (367, 242),
           (342, 251),
           (317, 257),
           (281, 262),
           (247, 267),
           (217, 279),
           (180, 299),
           (0, 299)],
 'nightelf': [(0, 15),
              (398, 15),
              (401, 46),
              (399, 127),
              (396, 157),
              (386, 179),
              (370, 197),
              (353, 210),
              (334, 221),
              (320, 234),
              (314, 241),
              (274, 232),
              (246, 227),
              (215, 228),
              (192, 237),
              (187, 241),
              (216, 242),
              (245, 250),
              (261, 259),
              (217, 257),
              (181, 264),
              (156, 273),
              (116, 281),
              (0, 282)],
 'skyborne': [(0, 17),
              (356, 17),
              (380, 23),
              (396, 36),
              (405, 51),
              (405, 184),
              (399, 204),
              (385, 224),
              (360, 242),
              (335, 257),
              (306, 268),
              (260, 283),
              (222, 290),
              (177, 296),
              (0, 296)],
 'skyborne-horde': [(0, 17),
                    (385, 17),
                    (399, 29),
                    (402, 46),
                    (401, 135),
                    (394, 158),
                    (383, 180),
                    (366, 198),
                    (337, 217),
                    (299, 234),
                    (251, 248),
                    (206, 256),
                    (150, 263),
                    (94, 274),
                    (0, 296)]}


@dataclass(frozen=True)
class Rect:
    x: int
    y: int
    w: int
    h: int

    @property
    def box(self):
        return self.x, self.y, self.x + self.w, self.y + self.h


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_image(path):
    with Image.open(path) as image:
        return image.convert("RGBA")


def layout(preset):
    path = ROOT / f"Collection/AddOns/!DevilForever_Core/Presets/{preset}.lua"
    text = path.read_text(encoding="utf-8-sig")
    definition = LuaRuntime().execute(text.split("\ndef.fragments = {}", 1)[0] + "\nreturn def")
    rects = {key.split(".")[1]: Rect(int(v.position.x), -int(v.position.y),
                                    int(v.size.width), int(v.size.height))
             for key, v in definition.edits.items()}
    expected = json.loads((ROOT / "References/codex-appearance/24/geometry-checks.json").read_text())[preset]
    assert {key: list(rect.box) for key, rect in rects.items()} == expected["rectangles"]
    features = json.loads((ROOT / "References/codex-appearance/24/feature-positions.json").read_text())["layouts"][preset]
    assert list(definition.screen.values()) == features["screen"] == expected["canvas"]
    return rects, path


def smooth(value):
    value = np.clip(value, 0, 1)
    return value * value * (3 - 2 * value)


def inverse_scale(axis, detail, blend, ratio, unit=1):
    shoulder = detail * ratio
    curve = PchipInterpolator((0, shoulder / 2, shoulder, blend - 32 * unit, blend),
                              (0, detail / 2, detail, blend - 32 * unit, blend))
    values = np.where(axis < blend, curve(axis), axis)
    assert (np.diff(values) > 0).all()
    return values


def corner_maps(theme, width, height, reference_width):
    sx, sy = width / reference_width, height / 304
    depth = round(570 * sx)
    x, y = np.arange(depth, dtype=float), np.arange(height, dtype=float)
    rx, ry = CORNERS[theme]
    if theme == "human":
        mapped = inverse_scale(x, 160 * sx, 430 * sx, rx, sx)
        return tuple(np.float32(a) for a in np.meshgrid(mapped, y))
    from_bottom = height - 1 - y
    dx = inverse_scale(x, 340 * sx, 569 * sx, rx, sx) - x
    dy = inverse_scale(from_bottom[::-1], 185 * sy, height - 1, ry, sy)[::-1] - from_bottom
    start, ramp = (5, 55) if theme == "orc" else ((66, 79) if theme.startswith("skyborne") else (5, 70))
    mx = x[None, :] + smooth((y[:, None] - start * sy) / (ramp * sy)) * dx[None, :]
    my = y[:, None] - (1 - smooth((x[None, :] - 194 * sx) / (250 * sx))) * dy[:, None]
    return mx.astype(np.float32), my.astype(np.float32)


def remap_outer(image, maps, side):
    source = np.asarray(image)
    if side == "right":
        source = source[:, ::-1].copy()
    result = cv2.remap(source, *maps, cv2.INTER_LINEAR, borderMode=cv2.BORDER_REPLICATE)
    return Image.fromarray(result if side == "left" else result[:, ::-1].copy())


def original_matte(panel, theme):
    scale = 3
    mask = Image.new("L", (panel.w * scale, panel.h * scale))
    points = [(round((x + 502) * panel.w / 938 * scale), round(y * panel.h / 304 * scale))
              for x, y in INNER_EDGES[theme]]
    points[0], points[-1] = (0, points[0][1]), (0, points[-1][1])
    ImageDraw.Draw(mask).polygon(points, fill=255)
    return mask.resize((panel.w, panel.h), Image.Resampling.LANCZOS)


def trim_sides(image, theme, reference_width):
    width, height = image.size
    sx, sy = width / reference_width, height / 304
    depth = round(192 * sx)
    assert 2 * depth < width
    x, y = np.arange(depth, dtype=float), np.arange(height, dtype=float)
    shifted = inverse_scale(x, 110 * sx, 191 * sx, SIDES[theme], sx)
    start, ramp, end, fall = (72, 30, 201, 44) if theme == "orc" else (6, 30, 229, 47)
    strength = smooth((y - start * sy) / (ramp * sy)) * (1 - smooth((y - end * sy) / (fall * sy)))
    mx = x[None, :] + strength[:, None] * (shifted - x)[None, :]
    maps = mx.astype(np.float32), np.broadcast_to(y[:, None], mx.shape).astype(np.float32)
    for side, left in (("left", 0), ("right", width - depth)):
        box = left, 0, left + depth, height
        image.paste(remap_outer(image.crop(box), maps, side), box[:2])
    return image


def transform_panel(image, panel, theme, key):
    matte = original_matte(panel, theme)
    reference_width = 938 if key == "chat3" else 960
    if theme in CORNERS and key in ("chat1", "chat3"):
        side = "left" if key == "chat1" else "right"
        maps = corner_maps(theme, panel.w, panel.h, reference_width)
        depth = maps[0].shape[1]
        assert depth <= panel.w
        left = 0 if side == "left" else panel.w - depth
        box = left, 0, left + depth, panel.h
        original = image.crop(box)
        right_mask = matte.crop((panel.w - depth, 0, panel.w, panel.h))
        mask = right_mask if side == "right" else right_mask.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        still_glass = ImageChops.multiply(mask, remap_outer(mask, maps, side))
        distance = cv2.distanceTransform((np.asarray(still_glass) > 240).astype(np.uint8), cv2.DIST_L2, 5)
        unit = min(panel.w / reference_width, panel.h / 304)
        still_glass = Image.fromarray(np.rint(255 * smooth(distance / (72 * unit))).astype(np.uint8))
        image.paste(Image.composite(original, remap_outer(original, maps, side), still_glass), box[:2])
        if key == "chat3":
            matte.paste(remap_outer(right_mask, maps, side), box[:2])
    if theme in SIDES:
        image = trim_sides(image, theme, reference_width)
        matte = trim_sides(matte, theme, reference_width)
    return image, matte


def add_crest(image, panel, theme, matte, crest_path):
    texture = read_image(crest_path)
    selected = texture.crop((0, 0, round(texture.width * .70), round(texture.height * .70)))
    side = round(panel.h * (.66 if theme.startswith("skyborne") else .78))
    mark = selected.resize((side, side), Image.Resampling.BILINEAR)
    mark.putalpha(mark.getchannel("A").point(lambda value: round(value * .16)))
    if theme in CORNERS:
        right, bottom = round(22 * panel.w / 938), round(10 * panel.h / 304)
        x, y = panel.w - side - right, panel.h - side - bottom
    else:
        right, bottom = ceil(panel.w * .052), ceil(panel.h * .053)
        y = panel.h - side - bottom
        alpha = np.asarray(mark.getchannel("A"), dtype=float)
        # 위치 선택은 세로 띠를 줄이기 전 승인 마스크를 따른다.
        before = original_matte(panel, theme)
        for step in range(7):
            x = panel.w - side - right - step * round(panel.h * .045)
            area = np.asarray(before.crop((x, y, x + side, y + side)), dtype=float)
            if (area * alpha).sum() >= .70 * 255 * alpha.sum():
                break
    assert 0 <= x < x + side <= panel.w and 0 <= y < y + side <= panel.h
    marked = image.copy()
    marked.alpha_composite(mark, (x, y))
    result = Image.composite(marked, image, matte)
    assert not np.any((np.asarray(matte) == 0) & np.any(np.asarray(result) != np.asarray(image), axis=2))
    return result, [x, y, side, side]


def compose(theme, preset, rects):
    path = ADDON / f"Themes/{theme}/Composition/{preset}_deck.tga"
    source = read_image(path)
    width, height = rects["chat3"].box[2], rects["status"].box[3] - rects["chat1"].y
    assert source.size == (2048, 512)
    physical = source.resize((width, height), Image.Resampling.BILINEAR)
    crest_name = "skyborne" if theme == "skyborne-horde" else theme
    positions = {}
    for key in ("chat1", "chat2", "chat3"):
        rect = rects[key]
        box = rect.x, rect.y - rects["chat1"].y, rect.x + rect.w, rect.box[3] - rects["chat1"].y
        panel, matte = transform_panel(physical.crop(box), rect, theme, key)
        panel = Image.alpha_composite(Image.new("RGBA", panel.size), panel)
        if key == "chat3":
            panel, positions[key] = add_crest(panel, rect, theme, matte, ADDON / f"Themes/Crests/{crest_name}.tga")
        physical.paste(panel, box[:2])
    converted = physical.resize(source.size, Image.Resampling.BICUBIC)
    result = source.copy()
    allowed = np.zeros((source.height, source.width), dtype=bool)
    storage_boxes = []
    changed_keys = ["chat3"]
    if theme in CORNERS or theme in SIDES:
        changed_keys.append("chat1")
    if theme in SIDES:
        changed_keys.append("chat2")
    for key in changed_keys:
        rect = rects[key]
        box = (ceil(rect.x * source.width / width), ceil((rect.y - rects["chat1"].y) * source.height / height),
               floor(rect.box[2] * source.width / width), floor((rect.box[3] - rects["chat1"].y) * source.height / height))
        result.paste(converted.crop(box), box[:2])
        allowed[box[1]:box[3], box[0]:box[2]] = True
        storage_boxes.append(box)
    difference = np.any(np.asarray(result) != np.asarray(source), axis=2)
    assert difference.any() and not difference[~allowed].any()
    return result, physical, {"source": str(path.relative_to(ROOT)), "source_sha256": sha(path),
                              "crest_box": positions["chat3"], "storage_boxes": storage_boxes,
                              "changed_panels": changed_keys,
                              "outside_changed_pixels": int(difference[~allowed].sum())}


def build(output, evidence):
    receipt = {"inputs": {}, "files": {}}
    for preset in PRESETS:
        rects, preset_path = layout(preset)
        receipt["inputs"][str(preset_path.relative_to(ROOT))] = sha(preset_path)
        for theme in THEMES:
            image, physical, entry = compose(theme, preset, rects)
            target = output / f"{theme}/Composition/{preset}_deck_reviewed.tga"
            target.parent.mkdir(parents=True, exist_ok=True)
            with target.open("xb") as stream:
                image.save(stream, format="TGA")
            assert read_image(target).tobytes() == image.tobytes()
            entry.update(sha256=sha(target), mode=image.mode, size=image.size)
            receipt["files"][str(target.relative_to(output))] = entry
            physical.save(evidence / f"{preset}-{theme}-physical.png")
    assert len(receipt["files"]) == 36
    for path in sorted((ADDON / "Themes").rglob("*.tga")):
        if not path.name.endswith("_deck_reviewed.tga"):
            receipt["inputs"][str(path.relative_to(ROOT))] = sha(path)
    for suffix in ("geometry-checks.json", "feature-positions.json"):
        path = ROOT / "References/codex-appearance/24" / suffix
        receipt["inputs"][str(path.relative_to(ROOT))] = sha(path)
    receipt["inputs"][str(Path(__file__).resolve().relative_to(ROOT))] = sha(Path(__file__))
    with (evidence / "reviewed-chat-receipt.json").open("x", encoding="utf-8") as stream:
        json.dump(receipt, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    print("PASS build files=36 size=2048x512 mode=RGBA outside_changed_pixels=0")


def verify_runtime():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(r'''
frames, failedTextures, hiddenAssets = {}, {}, {}
combat, activeTheme, activePreset = false, "devil", "uhd"
STANDARD_TEXT_FONT, UNIT_NAME_FONT = "client-font", "client-unit-font"
local methods = {}
local function record(self, key, ...)
  self.writes = self.writes + 1; self[key] = {...}
end
for _, name in ipairs({"SetFrameStrata", "SetFrameLevel", "EnableMouse", "EnableKeyboard",
  "SetScale", "SetSize", "SetHeight", "SetAllPoints", "SetTexCoord", "SetAlpha", "SetVertexColor"}) do
  local key=name:sub(4,4):lower() .. name:sub(5)
  methods[name] = function(self, ...) record(self, key, ...) end
end
function methods:GetEffectiveScale() return .64 end
function methods:GetHeight() return 1080 end
function methods:ClearAllPoints() self.points = {}; self.writes = self.writes + 1 end
function methods:SetPoint(...) self.points[#self.points + 1] = {...}; self.writes = self.writes + 1 end
function methods:SetTexture(path) record(self, "texture", path); return not failedTextures[path] end
function methods:Show() self.shown = true; self.writes = self.writes + 1 end
function methods:Hide() self.shown = false; self.writes = self.writes + 1 end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:SetScript(event, fn) self.scripts[event] = fn end
local function region(parent)
  return setmetatable({writes=0, parent=parent, points={}, events={}, scripts={}}, {__index=methods})
end
function methods:CreateTexture() local value=region(self); frames[#frames+1]=value; return value end
function CreateFrame(_, name, parent)
  local value=region(parent); if name then assert(not _G[name]); _G[name]=value end
  frames[#frames+1]=value; return value
end
UIParent=CreateFrame("Frame", "UIParent")
PixelUtil={GetPixelToUIUnitFactor=function() return .35 end}
function GetPhysicalScreenSize() return 3840,2160 end
function InCombatLockdown() return combat end
function fire(event)
  for _, frame in ipairs(frames) do
    if frame.events[event] then frame.scripts.OnEvent(frame,event) end
  end
end
function writes() local n=0; for _, f in ipairs(frames) do n=n+f.writes end; return n end
local sets, themeCallbacks, editCallbacks = {}, {}, {}
definitions, userEdits = {}, {}
local Theme, Edit, Presets = {}, {}, {}
DevilForever_Core={Theme=Theme, Edit=Edit, Presets=Presets, Log=function() end}
function Theme:RegisterSet(name, values) sets[name]=values end
function Theme:GetSet() return activeTheme end
function Theme:ListTokens() local result={};for key in pairs(sets.devil) do result[#result+1]=key end;return result end
function Theme:GetFromSet(name, token) return sets[name][token] end
function Theme:Get(token) return sets[activeTheme][token] end
function Theme:RegisterCallback(_, fn) themeCallbacks[#themeCallbacks+1]=fn end
function Theme:Set(name) activeTheme=name;for _,fn in ipairs(themeCallbacks) do fn() end end
function Edit:GetEdits(key) return userEdits[key] or {} end
function Edit:Get(key)
  local base, custom = definitions[activePreset].edits[key], userEdits[key] or {}
  local result={color={1,1,1,1}}
  for k,v in pairs(base) do result[k]=v end
  for k,v in pairs(custom) do result[k]=v end
  return result
end
function Edit:RegisterCallback(_, fn) editCallbacks[#editCallbacks+1]=fn end
function Edit:Notify(key) for _,fn in ipairs(editCallbacks) do fn(key) end end
function Presets:GetActive() return activePreset end
nativeSentinel={quest="retained",chat="retained",status="retained"}
C_UIFileAsset={IsKnownFile=function(path) return not hiddenAssets[path] and assetExists(path) end}
''')
    scope = lua.globals()
    scope.assetExists = lambda path: (ROOT / "Collection/AddOns" / path.replace("\\", "/").removeprefix("Interface/AddOns/")).is_file()
    for preset in PRESETS:
        source = (ROOT / f"Collection/AddOns/!DevilForever_Core/Presets/{preset}.lua").read_text(encoding="utf-8-sig")
        scope.definitions[preset] = lua.execute(source.split("\ndef.fragments = {}", 1)[0] + "\nreturn def")
    for name in ("Themes/devil.lua", "Themes/horde.lua", "Themes/alliance.lua", "Crests.lua", "Composition.lua", "Appearance.lua"):
        lua.execute((ADDON / name).read_text(encoding="utf-8-sig"))
    scope.fire("PLAYER_LOGIN")
    core, appearance, composition = scope.DevilForever_Core, scope.DevilForever_Appearance, scope.DevilForever_Composition
    for preset in PRESETS:
        scope.activePreset = preset
        for theme in ("devil", *THEMES):
            core.Theme.Set(core.Theme, theme)
            assert composition.active is True
            suffix = "_deck.tga" if theme == "devil" else "_deck_reviewed.tga"
            assert composition.deck.texture[1].endswith(f"Themes\\{theme}\\Composition\\{preset}{suffix}")
            assert composition.reviewed is (theme != "devil")
            assert composition.crest is None or composition.crest.shown is False
    prefix = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\"
    scope.activePreset = "fhd"
    cases = 0
    for theme in THEMES:
        family = composition.GetFamily(composition, theme)
        reviewed = prefix + theme + "\\Composition\\fhd_deck_reviewed.tga"
        legacy = prefix + theme + "\\Composition\\fhd_deck.tga"
        top = prefix + theme + "\\Composition\\fhd_top.tga"
        core.Theme.Set(core.Theme, theme)
        for method in ("hiddenAssets", "failedTextures"):
            scope[method][reviewed] = True
            appearance.Apply(appearance)
            assert composition.active is True and composition.reviewed is False
            assert composition.deck.texture[1] == legacy
            assert composition.crest.shown is True
            assert list(composition.crest.texCoord.values()) == [0, .70, 0, .70]
            assert composition.crest.alpha[1] == .16
            scope[method][reviewed] = None
            cases += 1
        scope.failedTextures[reviewed], scope.failedTextures[legacy] = True, True
        appearance.Apply(appearance)
        assert composition.reviewed is False
        if theme != family:
            assert composition.active is True
            assert composition.deck.texture[1] == prefix + family + "\\Composition\\fhd_deck.tga"
            assert composition.crest.texture[1] == scope.DevilForever_ChatCrests[theme].texture
        else:
            assert composition.active is False
            assert appearance.frames["appearance.chat1"].fill.shown is True
        scope.failedTextures[reviewed], scope.failedTextures[legacy] = None, None
        if theme != family:
            for missing in (legacy, top):
                scope.hiddenAssets[missing] = True
                appearance.Apply(appearance)
                assert composition.active is True and composition.reviewed is False
                assert composition.deck.texture[1] == prefix + family + "\\Composition\\fhd_deck.tga"
                scope.hiddenAssets[missing] = None
                cases += 1
        cases += 1
    core.Theme.Set(core.Theme, "orc")
    scope.C_UIFileAsset = None
    scope.failedTextures[prefix + "orc\\Composition\\fhd_deck_reviewed.tga"] = True
    appearance.Apply(appearance)
    assert composition.active is True and composition.reviewed is False
    assert composition.deck.texture[1] == prefix + "orc\\Composition\\fhd_deck.tga"
    scope.failedTextures = lua.table()
    for key in composition.covered.values():
        for field, value in (("position", {"point": "TOPLEFT", "relativePoint": "TOPLEFT", "relativeTo": "DevilForever_AppearanceRoot", "x": 10, "y": -40}),
                             ("size", {"width": 80, "height": 40}), ("color", [.2, .3, .4, .5])):
            value = lua.table_from(value)
            scope.userEdits["appearance." + key] = lua.table_from({field: value})
            appearance.Apply(appearance)
            assert composition.active is False
            assert appearance.frames["appearance.chat1"].fill.shown is True
            assert composition.crest is None or composition.crest.shown is False
            scope.userEdits["appearance." + key] = None
    appearance.Apply(appearance)
    scope.combat = True
    baseline = scope.writes()
    core.Theme.Set(core.Theme, "alliance")
    scope.fire("UI_SCALE_CHANGED")
    assert scope.writes() == baseline
    scope.combat = False
    scope.fire("PLAYER_REGEN_ENABLED")
    assert composition.reviewed is True
    assert composition.deck.texture[1] == prefix + "alliance\\Composition\\fhd_deck_reviewed.tga"
    lua.execute('assert(nativeSentinel.quest=="retained" and nativeSentinel.chat=="retained" and nativeSentinel.status=="retained")')
    print(f"PASS Lua 5.1 themes=39 fallback_cases={cases + 1} user_edit_cases=45 combat=deferred native_values=retained")


def verify_approved(evidence):
    rects, _ = layout("uhd")
    width, height = 3840, 2160
    split, bottom = rects["chat1"].y, rects["status"].box[3]
    lua = LuaRuntime()
    lua.execute((ADDON / "Crests.lua").read_text(encoding="utf-8-sig"))
    crests = {key: dict(value.items()) for key, value in lua.globals().DevilForever_ChatCrests.items()}

    def art_image(path):
        return read_image(ROOT / "Collection/AddOns" / path.replace("\\", "/").removeprefix("Interface/AddOns/"))

    def original(canvas, values, preset, theme):
        image = read_image(ADDON / f"Themes/{theme}/Composition/{preset}_deck.tga")
        image = image.resize((width, bottom - split), Image.Resampling.BILINEAR)
        canvas.alpha_composite(image, (0, split))
        return True

    sources = {}

    def source_kit(folder):
        path = ROOT / f"_local_only/{folder}/render.py"
        tree = ast.parse(path.read_text(encoding="utf-8-sig"))
        namespace = dict(globals())
        namespace.update(render={"composition": original}, original_composition=original, composition_maps={},
                         assets={"art": SimpleNamespace(image=art_image), "crest_records": crests})
        for node in tree.body:
            if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id in {"changed", "ratios", "inner_edges"} for t in node.targets):
                for target in node.targets:
                    namespace[target.id] = ast.literal_eval(node.value)
        functions = [node for node in tree.body if isinstance(node, ast.FunctionDef)]
        exec(compile(ast.Module(body=functions, type_ignores=[]), str(path), "exec"), namespace)
        sources[str(path.relative_to(ROOT))] = {"sha256": sha(path), "lines": len(path.read_text(encoding="utf-8-sig").splitlines())}
        return namespace

    base = source_kit("mobile-crest-corner-review-19")
    symmetric = source_kit("mobile-symmetric-corners-19")
    skyborne = source_kit("mobile-skyborne-human-19")
    slim = source_kit("mobile-slim-borders-19")
    slim.update(base=base, corners=symmetric)
    orc = source_kit("mobile-orc-rail-19")
    orc["corners"] = skyborne
    results = {}
    for theme in THEMES:
        kit = orc if theme == "orc" else (slim if theme in ("dwarf", "gnome", "troll") else (
            skyborne if theme in ("human", "skyborne", "skyborne-horde") else (symmetric if theme == "undead" else base)))
        canvas = Image.new("RGBA", (width, height))
        paint = kit["narrow_chat"] if theme in SIDES else (kit["smaller_corners"] if theme in CORNERS else original)
        assert paint(canvas, rects, "uhd", theme)
        crest = kit["crest"] if theme in SIDES else kit["layered_crest"]
        crest(canvas, rects["chat3"], theme)
        expected = canvas.crop((0, split, width, bottom))
        packed, physical, _ = compose(theme, "uhd", rects)
        diff = np.abs(np.asarray(expected).astype(int) - np.asarray(physical).astype(int))
        assert not diff.any(), (theme, int(diff.max()), int(np.any(diff, axis=2).sum()))
        decoded = packed.resize(physical.size, Image.Resampling.BILINEAR)
        error = np.abs(np.asarray(decoded).astype(int) - np.asarray(physical).astype(int))
        results[theme] = {"source_pixels_changed": 0, "storage_decode_mean_absolute_error": float(error.mean()),
                          "physical_sha256": hashlib.sha256(physical.tobytes()).hexdigest()}
        decoded.save(evidence / f"uhd-{theme}-decoded.png")
    gallery = ROOT / "outputs/devil-forever-mobile-orc-rail.html"
    names = re.findall(r'data-theme="([a-z-]+)"[^>]*>\s*<span[^>]*><span[^>]*><img src="data:image/webp;base64,', unescape(gallery.read_text(encoding="utf-8")))
    assert len(names) == len(set(names)) == 13 and set(names) == {"devil", *THEMES}
    report = {"gallery": {"path": str(gallery.relative_to(ROOT)), "sha256": sha(gallery), "themes": names},
              "sources": sources, "checks": results}
    with (evidence / "approved-pixel-check.json").open("x", encoding="utf-8") as stream:
        json.dump(report, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    print("PASS approved uhd_themes=12 original_source_changed_pixels=0 gallery_themes=13")


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--output", type=Path, default=ADDON / "Themes")
    cli.add_argument("--evidence", type=Path, required=True)
    cli.add_argument("--verify-runtime", action="store_true")
    cli.add_argument("--verify-approved", action="store_true")
    args = cli.parse_args()
    args.evidence.mkdir(parents=True, exist_ok=True)
    if args.verify_runtime:
        verify_runtime()
    elif args.verify_approved:
        verify_approved(args.evidence)
    else:
        build(args.output, args.evidence)


if __name__ == "__main__":
    main()

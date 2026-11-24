"""HUD composition from parts (DevilForever_Appearance/Composition.lua) and its development tool.

Usage:  python -I Collection/tests/composition/parts.py [--preview DIR]

Composition.lua runs in a Lua 5.1 runtime (lupa). Every method call on the frames and textures it
creates is written to a call log (object number, method, arguments), so two runs can be compared
call for call. Layout edits are the appearance.* values of Presets/<fhd|qhd|uhd>.lua; Dominos bars
1-3 are stand-ins whose rectangles follow the bar geometry of the same preset file (12 buttons,
Onyx coverage), seen through a root and a bar with different effective scales. The part files
themselves are never read by the code; the part table (PARTS_SHIPPED) is filled by each case.
Placeholder parts from Collection/tools/hud_parts.py are written to a temporary folder only.
--preview DIR also writes one PNG per preset assembled from placeholder parts at the planned
places (a look without the game). This does not emulate the game client.
"""

import argparse
import math
import os
import re
import sys
import tempfile
import traceback

try:
    import lupa
    from lupa import lua51
except ImportError as exc:  # pragma: no cover - environment check
    sys.stderr.write("lupa with Lua 5.1 is required (pip install lupa): %s\n" % exc)
    sys.exit(2)

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
FOLDER = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Appearance")
COMPOSITION = os.path.join(FOLDER, "Composition.lua")
PRESET_DIR = os.path.join(REPO, "Collection", "AddOns", "!DevilForever_Core", "Presets")
sys.path.insert(0, os.path.join(REPO, "Collection", "tools"))
import hud_parts  # noqa: E402

THEMES = hud_parts.THEMES
PRESETS = hud_parts.PRESETS
ONYX_COVERAGE = (40 / 36) * (112 / 128)
ROOT_SCALE, BAR_SCALE = 0.5, 0.6


def preset_geometry(preset):
    """appearance.* rectangles, screen size and Dominos bar 1-3 rectangles (root pixels) of a preset file."""
    with open(os.path.join(PRESET_DIR, preset + ".lua"), encoding="utf-8") as fh:
        text = fh.read()
    width, height = (int(v) for v in re.search(r'\["screen"\] = \{(\d+), (\d+)\}', text).groups())
    items = {}
    for match in re.finditer(r'\["appearance\.(\w+)"\] = \{(.*?)\n    \},', text, re.S):
        body = match.group(2)

        def number(key):
            return float(re.search(r'\["%s"\] = (-?[\d.]+)' % key, body).group(1))
        items[match.group(1)] = {"x": number("x"), "y": number("y"), "width": number("width"), "height": number("height")}
    pixels = int(re.search(r"local pixels = (\d+)", text).group(1))
    button = pixels / ONYX_COVERAGE
    bars = []
    for index, x, y in re.findall(r'\[(\d)\] = \{point = "TOPLEFT", relPoint = "TOPLEFT", x = (\d+) / effective \+ shiftX, '
                                  r'y = -(\d+) / effective', text):
        if index in "123":
            left, top = int(x) - (button - pixels) / 2, int(y) - (button - pixels) / 2
            bars.append({"x1": left, "y1": top, "x2": left + button + 11 * (pixels + 2), "y2": top + button})
    return {"screen": (width, height), "items": items, "bars": bars, "pixels": pixels}


GEOMETRY = {preset: preset_geometry(preset) for preset in PRESETS}

STUBS = r"""
TEST_log, TEST_fail, TEST_known, TEST_objects = {}, {}, {}, {}
TEST_combat = false
local function fmt(value)
  local kind = type(value)
  if kind == "number" then return string.format("%.6g", value) end
  if kind == "table" then return value.id and ("#" .. value.id) or "{}" end
  return tostring(value)
end
local function record(self, name, ...)
  local parts = {tostring(self.id), name}
  for index = 1, select("#", ...) do parts[#parts + 1] = fmt((select(index, ...))) end
  TEST_log[#TEST_log + 1] = table.concat(parts, "|")
end
local Obj = {}
local methods = {}
-- Capitalised keys are widget methods (logged); other keys are plain fields (nil until set).
Obj.__index = function(_, key)
  if methods[key] then return methods[key] end
  if type(key) ~= "string" or not key:match("^%u") then return nil end
  return function(self, ...) record(self, key, ...) end
end
local function new(kind, parent, layer, sublevel)
  local o = setmetatable({id = #TEST_objects + 1, kind = kind, parent = parent, layer = layer, sublevel = sublevel}, Obj)
  TEST_objects[o.id] = o
  return o
end
function methods:CreateTexture(name, layer, template, sublevel)
  record(self, "CreateTexture", name, layer, template, sublevel)
  return new("texture", self, layer, sublevel)
end
function methods:SetPoint(point, relative, relativePoint, x, y)
  record(self, "SetPoint", point, relative, relativePoint, x, y)
  self.anchor, self.x, self.y = relative, x, y
end
function methods:SetSize(width, height) record(self, "SetSize", width, height); self.width, self.height = width, height end
function methods:SetTexCoord(...) record(self, "SetTexCoord", ...); self.coords = {...} end
function methods:SetTexture(path)
  record(self, "SetTexture", path)
  if TEST_fail[path] then return false end
  self.path = path
  return true
end
function methods:Show() record(self, "Show"); self.shown = true end
function methods:Hide() record(self, "Hide"); self.shown = false end
function methods:SetDrawLayer(layer, sublevel) record(self, "SetDrawLayer", layer, sublevel); self.layer, self.sublevel = layer, sublevel end
function methods:SetFrameStrata(strata) record(self, "SetFrameStrata", strata); self.strata = strata end
function methods:SetFrameLevel(level) record(self, "SetFrameLevel", level); self.level = level end
function methods:EnableMouse(enable) record(self, "EnableMouse", enable); self.mouse = enable end
function CreateFrame(kind, name, parent)
  local o = new("frame", parent)
  o.name = name
  TEST_log[#TEST_log + 1] = "CreateFrame|" .. tostring(kind) .. "|" .. tostring(name) .. "|" .. fmt(parent) .. "|#" .. o.id
  return o
end
function InCombatLockdown() return TEST_combat end
C_UIFileAsset = {IsKnownFile = function(path) return TEST_known[path] == true end}
function hooksecurefunc(target, name, hook)
  local original = target[name]
  target[name] = function(...)
    local results = {original(...)}
    hook(...)
    return unpack(results)
  end
end
TEST_preset, TEST_theme, TEST_items = "fhd", "devil", {}
local nop = function() end
DevilForever_Core = {
  Presets = {GetActive = function() return TEST_preset end},
  Theme = {GetSet = function() return TEST_theme end, ListTokens = function() return {} end, GetFromSet = nop, RegisterSet = nop},
  Edit = {GetEdits = function(_, key) return TEST_edits and TEST_edits[key] or {} end,
          Get = function(_, key)
            local item = TEST_items[TEST_preset][key:match("%.(.*)")]
            if not item then return {} end
            return {position = {relativeTo = "DevilForever_AppearanceRoot", point = "TOPLEFT", relativePoint = "TOPLEFT",
                                x = item.x, y = item.y}, size = {width = item.width, height = item.height}}
          end},
}
TEST_frames = setmetatable({}, {__index = function(t, k)
  local f = new("panel"); f.fill = new("fill"); rawset(t, k, f); return f end})

-- Root: one unit is one physical pixel; Dominos bars report rectangles in their own scale.
TEST_rootScale, TEST_barScale = %ROOT%, %BAR%
function TEST_makeRoot(height)
  local root = new("root")
  root.GetLeft = function() return 0 end
  root.GetTop = function() return height end
  root.GetEffectiveScale = function() return TEST_rootScale end
  TEST_root = root
  return root
end
local Bar = {}
Bar.__index = Bar
function Bar:GetLeft() return self.x1 * TEST_rootScale / TEST_barScale end
function Bar:GetRight() return self.x2 * TEST_rootScale / TEST_barScale end
function Bar:GetTop() return (TEST_root:GetTop() - self.y1) * TEST_rootScale / TEST_barScale end
function Bar:GetBottom() return (TEST_root:GetTop() - self.y2) * TEST_rootScale / TEST_barScale end
function Bar:GetEffectiveScale() return TEST_barScale end
function Bar:IsShown() return self.visible end
function Bar:GetFrameStrata() return self.strata end
function Bar:GetFrameLevel() return self.level end
function Bar:GetChildren() return unpack(self.children) end
for _, name in ipairs({"Layout", "RestorePosition", "SavePosition", "SetFrameScale", "UpdateDisplayLayer",
    "UpdateDisplayLevel", "ShowFrame", "HideFrame"}) do Bar[name] = function(self) self.calls = (self.calls or 0) + 1 end end
-- Dominos drag end: StopMovingOrSizing, then Stick -> (StickToFrame/Grid/Edge or free) -> SaveRelativePosition -> SavePosition.
function Bar:StopMovingOrSizing() end
function Bar:UpdateWatched() end
function Bar:SaveRelativePosition() self:SavePosition("TOPLEFT", "TOPLEFT", self.x1, -self.y1) end
function Bar:Stick() self:SaveRelativePosition(); return false end
function Bar:HookScript(event, fn)
  self.scripts = self.scripts or {}
  self.scripts[event] = fn
end
local function child(level, children)
  return setmetatable({level = level, children = children or {}}, Bar)
end
function TEST_makeBar(name, x1, y1, x2, y2, strata, buttonLevel, skinLevel)
  local buttons = {}
  for index = 1, 12 do buttons[index] = child(buttonLevel, {child(skinLevel), child(buttonLevel + 1)}) end
  local bar = setmetatable({x1 = x1, y1 = y1, x2 = x2, y2 = y2, visible = true, strata = strata, level = 1,
    children = buttons}, Bar)
  _G[name] = bar
  return bar
end
TEST_callbacks = {}
function TEST_makeDominos()
  Dominos = {RegisterCallback = function(owner, event, fn) TEST_callbacks[event] = fn end}
end
"""


def runtime(path=COMPOSITION):
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute(STUBS.replace("%ROOT%", repr(ROOT_SCALE)).replace("%BAR%", repr(BAR_SCALE)))
    g = lua.globals()
    for preset in PRESETS:
        table = lua.table()
        for key, item in GEOMETRY[preset]["items"].items():
            table[key] = lua.table_from(item)
        if g.TEST_items[preset] is None:
            g.TEST_items[preset] = table
    for name in ("Crests.lua", os.path.basename(path)):
        source = path if name != "Crests.lua" else os.path.join(FOLDER, "Crests.lua")
        with open(source, "rb") as fh:
            fn = g.loadstring(fh.read(), ("@" + name).encode())
        (fn[0] if isinstance(fn, tuple) else fn)("DevilForever_Appearance", lua.table())
    return lua


def shipped_paths():
    """Every prepared surface and crest the release ships, as client paths."""
    import build
    kept, _excluded = build.runtime_files("DevilForever_Appearance", FOLDER)
    return {"Interface\\AddOns\\DevilForever_Appearance\\" + rel.replace("/", "\\") for rel, _full in kept}


SHIPPED = shipped_paths()


def part_names(lua, optional=True):
    parts = lua.globals().DevilForever_Composition.parts
    names = [parts.required[i] for i in range(1, len(parts.required) + 1)]
    if optional:
        names += [parts.optional[i] for i in range(1, len(parts.optional) + 1)]
    return names


def ship(lua, theme, preset, names):
    """List part files for theme/preset in PARTS_SHIPPED and make the client know them."""
    g = lua.globals()
    parts = g.DevilForever_Composition.parts
    if parts.shipped[theme] is None:
        parts.shipped[theme] = lua.table()
    parts.shipped[theme][preset] = lua.table_from(names)
    for name in names:
        g.TEST_known[parts.Path(theme, preset, name)] = True


def session(path=COMPOSITION, known=None):
    """A runtime with a root and the composition created; apply() places the Dominos bars of the preset."""
    lua = runtime(path)
    g = lua.globals()
    for item in (SHIPPED if known is None else known):
        g.TEST_known[item] = True
    lua.execute("TEST_makeRoot(0); DevilForever_Composition:Create(TEST_root)")
    return lua


def place_bars(lua, preset, dominos=True, strata="MEDIUM", bars=None):
    g = lua.globals()
    screen = GEOMETRY[preset]["screen"]
    lua.execute("TEST_root.GetTop = function() return %d end" % screen[1])
    for index in range(1, 4):
        g["DominosFrame%d" % index] = None
    if not dominos:
        g.Dominos = None
        return []
    lua.execute("TEST_makeDominos()")
    made = []
    for index, rect in enumerate(bars or GEOMETRY[preset]["bars"], start=1):
        made.append(g.TEST_makeBar("DominosFrame%d" % index, rect["x1"], rect["y1"], rect["x2"], rect["y2"], strata, 4, 7))
    return made


def apply(lua, theme, preset, dominos=True, strata="MEDIUM", bars=None):
    g = lua.globals()
    g.TEST_theme, g.TEST_preset = theme, preset
    place_bars(lua, preset, dominos, strata, bars)
    lua.execute("TEST_log = {}; DevilForever_Composition:Apply(TEST_root, TEST_frames)")
    log = g.TEST_log
    return [log[i] for i in range(1, len(log) + 1)]


def visible_parts(lua, frame_name=None):
    """Shown part textures as dicts (part from the path, rectangle, coords, layer)."""
    g = lua.globals()
    result = []
    for index in range(1, len(g.TEST_objects) + 1):
        o = g.TEST_objects[index]
        if o.kind != "texture" or not o.shown or not o.path or "\\Parts\\" not in o.path:
            continue
        owner = o.parent
        if not owner.shown:
            continue
        if frame_name is not None and owner.name != frame_name:
            continue
        result.append({"part": o.path.rsplit("\\", 1)[1][:-4], "x": o.x, "y": -o.y, "width": o.width, "height": o.height,
                       "coords": [o.coords[i] for i in range(1, 5)], "anchor": o.anchor.kind, "frame": owner.name,
                       "layer": o.layer, "sublevel": o.sublevel})
    return result


def bar_rect(rect):
    return tuple(math.floor(v + 0.5) for v in (rect["x1"], rect["y1"], rect["x2"], rect["y2"]))


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %.300r, got %.300r" % (what, expected, actual))


@case
def part_table_matches_tool_and_preset_bounds():
    lua = runtime()
    parts = hud_parts.load_parts()
    table = hud_parts.spec(parts)
    sizes = lua.globals().DevilForever_Composition.parts.sizes
    for preset in PRESETS:
        items = GEOMETRY[preset]["items"]
        top = -items["aux"]["y"] - math.floor(items["aux"]["height"] / 4)
        split, bottom = -items["chat1"]["y"], -items["status"]["y"] + items["status"]["height"]
        eq((sizes[preset].band, sizes[preset].deck), (split - top, bottom - split), "%s band/deck heights = layout" % preset)
        for name, size in table[preset].items():
            for key in ("canvasWidth", "canvasHeight"):
                value = size[key]
                eq(value & (value - 1), 0, "%s %s %s power of two" % (preset, name, key))
            eq(size["width"] <= size["canvasWidth"] and size["height"] <= size["canvasHeight"], True, "%s %s fits" % (preset, name))


@case
def placeholders_pass_check_and_bad_art_is_caught():
    parts = hud_parts.load_parts()
    with tempfile.TemporaryDirectory() as out:
        written = hud_parts.write_placeholders(out, parts, themes=("horde",))
        eq(len(written), 3 * len(parts["required"] + parts["optional"]), "placeholder count")
        files, problems = hud_parts.check(out, parts, False)
        eq((files, problems), (len(written), []), "placeholders pass the art check")
        from PIL import Image
        folder = os.path.join(out, "Themes", "horde", "Parts", "uhd")
        size = hud_parts.spec(parts)["uhd"]["band_fill"]
        ramp = Image.new("RGBA", (size["canvasWidth"], size["canvasHeight"]), (0, 0, 0, 0))
        for x in range(size["width"]):
            for y in range(size["height"]):
                ramp.putpixel((x, y), (40 + x // 2, 40 + x // 2, 40 + x // 2, 255))
        with open(os.path.join(folder, "band_fill.tga"), "wb") as fh:
            fh.write(hud_parts.tga_bytes(ramp))
        os.replace(os.path.join(folder, "rivet.tga"), os.path.join(out, "rivet.moved"))
        _files, problems = hud_parts.check(out, parts, False)
        text = "\n".join(problems)
        eq(("repeat seam" in text, "lighting changes" in text, "missing required parts rivet" in text), (True, True, True),
           "seam, ramp and incomplete set reported")
    try:
        hud_parts.write_placeholders(os.path.join(FOLDER, "x"), parts)
        raise AssertionError("placeholders written inside AddOns")
    except SystemExit:
        pass


@case
def parts_keep_one_texel_per_pixel():
    for preset in PRESETS:
        lua = session()
        ship(lua, "horde", preset, part_names(lua))
        apply(lua, "horde", preset)
        table = hud_parts.spec(hud_parts.load_parts())[preset]
        placed = visible_parts(lua)
        eq(len(placed) > 0, True, "%s parts drawn" % preset)
        for p in placed:
            size = table[p["part"]]
            u1, u2, v1, v2 = p["coords"]
            eq((u1, v1), (0, 0), "%s %s starts at the canvas corner" % (preset, p["part"]))
            eq((round(p["width"] - (u2 - u1) * size["canvasWidth"], 9), round(p["height"] - (v2 - v1) * size["canvasHeight"], 9)),
               (0, 0), "%s %s one texel per pixel" % (preset, p["part"]))
            eq(p["width"] <= size["width"] and p["height"] <= size["height"], True, "%s %s inside the drawing" % (preset, p["part"]))
            eq(p["anchor"], "root", "%s %s placed on the root, not on a bar" % (preset, p["part"]))


@case
def strips_tile_the_length_without_gaps_or_overlap():
    for preset in PRESETS:
        lua = session()
        ship(lua, "orc", preset, part_names(lua))
        apply(lua, "orc", preset)
        sizes = lua.globals().DevilForever_Composition.parts.sizes[preset]
        width = GEOMETRY[preset]["screen"][0]
        placed = visible_parts(lua)
        for part in ("band_fill", "deck_fill"):
            pieces = sorted((p for p in placed if p["part"] == part), key=lambda p: p["x"])
            length = width - 2 * sizes.cap
            eq(len(pieces), math.ceil(length / sizes.fill), "%s %s copies" % (preset, part))
            edge = sizes.cap
            for p in pieces:
                eq(p["x"], edge, "%s %s contiguous" % (preset, part))
                edge += p["width"]
            eq(edge, width - sizes.cap, "%s %s ends at the right cap" % (preset, part))
        for part, axis in (("surround_edge_top", "x"), ("surround_edge_left", "y")):
            pieces = sorted((p for p in placed if p["part"] == part), key=lambda p: (p["x"], p["y"]))
            key, extent = ("x", "width") if axis == "x" else ("y", "height")
            for a, b in zip(pieces, pieces[1:]):
                eq(b[key], a[key] + a[extent], "%s %s contiguous" % (preset, part))


@case
def joints_and_rivets_sit_on_the_panel_boundaries():
    for preset in PRESETS:
        lua = session()
        ship(lua, "human", preset, part_names(lua))
        apply(lua, "human", preset)
        sizes = lua.globals().DevilForever_Composition.parts.sizes[preset]
        items = GEOMETRY[preset]["items"]
        order = sorted((items[k] for k in ("chat1", "chat2", "action", "minimap", "chat3")), key=lambda i: i["x"])
        centres = [(a["x"] + a["width"] + b["x"]) / 2 for a, b in zip(order, order[1:])]
        seams = sorted(items["seam%d" % i]["x"] + items["seam%d" % i]["width"] / 2 for i in range(1, 5))
        eq(centres, seams, "%s panel boundaries are the seam centres" % preset)
        placed = visible_parts(lua)
        joints = sorted(p["x"] + p["width"] / 2 for p in placed if p["part"] == "deck_joint")
        eq([abs(j - c) <= 0.5 for j, c in zip(joints, centres)], [True] * 4, "%s joints centred on boundaries" % preset)
        rivets = sorted((p["x"] + p["width"] / 2, p["y"]) for p in placed if p["part"] == "rivet")
        eq(len(rivets), 8, "%s two rivets per joint" % preset)
        eq(all(any(abs(x - c) <= 0.5 for c in centres) for x, _y in rivets), True, "%s rivets on joints" % preset)
        split = -items["chat1"]["y"]
        bottom = -items["status"]["y"] + items["status"]["height"]
        eq(all(split <= y and y + sizes.rivet <= bottom for _x, y in rivets), True, "%s rivets inside the deck" % preset)


@case
def surround_is_bar_rectangle_plus_even_margin():
    for preset in PRESETS:
        lua = session()
        ship(lua, "troll", preset, part_names(lua))
        apply(lua, "troll", preset)
        comp = lua.globals().DevilForever_Composition
        sizes = comp.parts.sizes[preset]
        margin = sizes.gap + sizes.border
        bars = [bar_rect(r) for r in GEOMETRY[preset]["bars"]]
        union = (min(b[0] for b in bars), min(b[1] for b in bars), max(b[2] for b in bars), max(b[3] for b in bars))
        groups = comp.surroundPlan.groups
        eq(len(groups), 1, "%s bars 1-3 touch: one surround" % preset)
        outer = groups[1].outer
        eq((outer.x1, outer.y1, outer.x2, outer.y2),
           (union[0] - margin, union[1] - margin, union[2] + margin, union[3] + margin), "%s union + margin" % preset)
        placed = visible_parts(lua, "DevilForever_CompositionSurround")
        xs = [p["x"] for p in placed] + [p["x"] + p["width"] for p in placed]
        ys = [p["y"] for p in placed] + [p["y"] + p["height"] for p in placed]
        eq((min(xs), min(ys), max(xs), max(ys)), (outer.x1, outer.y1, outer.x2, outer.y2), "%s drawn ring = outer" % preset)
        inner = [p for p in placed if p["x"] < union[2] and p["x"] + p["width"] > union[0]
                 and p["y"] < union[3] and p["y"] + p["height"] > union[1]]
        eq(inner, [], "%s ring leaves the bars uncovered" % preset)
        # Bars apart: one surround per bar, each its own rectangle + margin.
        apart = [dict(r) for r in GEOMETRY[preset]["bars"]]
        for index, rect in enumerate(apart):
            rect["x1"] += index * 200
            rect["x2"] += index * 200
        lua2 = session()
        ship(lua2, "troll", preset, part_names(lua2))
        apply(lua2, "troll", preset, bars=apart)
        groups = lua2.globals().DevilForever_Composition.surroundPlan.groups
        got = [(groups[i].outer.x1, groups[i].outer.y1, groups[i].outer.x2, groups[i].outer.y2) for i in range(1, len(groups) + 1)]
        want = [(b[0] - margin, b[1] - margin, b[2] + margin, b[3] + margin) for b in map(bar_rect, apart)]
        eq(got, want, "%s separate bars: each rectangle + margin" % preset)


@case
def surround_draws_above_buttons_and_onyx_without_mouse():
    for strata in ("MEDIUM", "HIGH"):
        lua = session()
        ship(lua, "undead", "uhd", part_names(lua))
        log = apply(lua, "undead", "uhd", strata=strata)
        frame = lua.globals().DevilForever_Composition.surround
        eq((frame.strata, frame.level), (strata, 8), "%s: bar strata, above button (4-5) and Onyx (7) levels" % strata)
        eq(frame.mouse, False, "surround takes no mouse input")
        eq(frame.shown, True, "surround shown")
        eq(any(line.split("|")[1] == "EnableMouse" and line.split("|")[2] == "true" for line in log), False, "no mouse anywhere")


@case
def surround_follows_dominos_layout_changes():
    lua = session()
    ship(lua, "gnome", "qhd", part_names(lua))
    apply(lua, "gnome", "qhd")
    g = lua.globals()
    comp = g.DevilForever_Composition
    before = comp.surroundPlan.groups[1].outer.x1
    bar1 = g.DominosFrame1
    bar1.x1, bar1.x2 = bar1.x1 - 40, bar1.x2 - 40
    lua.execute("DominosFrame1:Layout()")
    eq(comp.surroundPlan.groups[1].outer.x1, before - 40, "re-measured after Layout")
    bar1.visible = False
    lua.execute("DominosFrame1:HideFrame()")
    groups = comp.surroundPlan.groups
    eq(groups[1].outer.x1 > before - 40, True, "hidden bar leaves the surround")
    # Dragged in Dominos config: the drag frame ends with StopMovingOrSizing, Stick, UpdateWatched.
    bar2 = g.DominosFrame2
    bar2.x1, bar2.x2, bar2.y1, bar2.y2 = bar2.x1, bar2.x2, bar2.y1 - 300, bar2.y2 - 300
    lua.execute("DominosFrame2:StopMovingOrSizing(); DominosFrame2:Stick(); DominosFrame2:UpdateWatched()")
    groups = comp.surroundPlan.groups
    margin = comp.parts.sizes.qhd.gap + comp.parts.sizes.qhd.border
    dragged = (math.floor(bar2.x1 + 0.5) - margin, math.floor(bar2.y1 + 0.5) - margin, math.floor(bar2.x2 + 0.5) + margin, math.floor(bar2.y2 + 0.5) + margin)
    got = [(groups[i].outer.x1, groups[i].outer.y1, groups[i].outer.x2, groups[i].outer.y2) for i in range(1, len(groups) + 1)]
    eq(dragged in got and len(got) == 2, True, "dragged bar: own ring at its new place")
    # Keyboard nudge: SaveRelativePosition, then RestorePosition.
    bar2.y1, bar2.y2 = bar2.y1 + 300, bar2.y2 + 300
    lua.execute("DominosFrame2:SaveRelativePosition()")
    eq(len(comp.surroundPlan.groups), 1, "nudged back: one ring again")
    # A secure state driver hides a bar without Dominos methods: OnHide re-measures.
    bar3 = g.DominosFrame3
    right = comp.surroundPlan.groups[1].outer.x2
    bar3.visible = False
    lua.execute("DominosFrame3.scripts.OnHide(DominosFrame3)")
    eq(comp.surroundPlan.groups[1].outer.x2 < right, True, "re-measured after OnHide")
    bar3.visible = True
    lua.execute("DominosFrame3.scripts.OnShow(DominosFrame3)")
    eq(comp.surroundPlan.groups[1].outer.x2, right, "re-measured after OnShow")
    # A profile change recreates the bars: LAYOUT_LOADED hooks the new frames and re-measures.
    fresh = g.TEST_makeBar("DominosFrame1", 100, 1118, 790, 1174, "MEDIUM", 4, 7)
    lua.execute("TEST_callbacks.LAYOUT_LOADED('LAYOUT_LOADED')")
    eq(comp.surroundPlan.groups[1].outer.x1, 100 - 10, "re-measured after LAYOUT_LOADED")
    fresh.x1 = 120
    lua.execute("DominosFrame1:RestorePosition()")
    eq(comp.surroundPlan.groups[1].outer.x1, 120 - 10, "new bar hooked")


@case
def missing_or_failing_part_draws_todays_picture_call_for_call():
    for theme in THEMES:
        for preset in PRESETS:
            plain = apply(session(), theme, preset)
            lua = session()
            names = part_names(lua)
            short = [n for n in names if n != "surround_edge_left"]
            ship(lua, theme, preset, short)
            eq(apply(lua, theme, preset), plain, "%s %s missing part = no parts" % (theme, preset))
    lua = session()
    ship(lua, "dwarf", "fhd", part_names(lua))
    lua.globals().TEST_known[lua.globals().DevilForever_Composition.parts.Path("dwarf", "fhd", "rivet")] = None
    eq(apply(lua, "dwarf", "fhd"), apply(session(), "dwarf", "fhd"), "part unknown to the client = no parts")
    lua = session()
    ship(lua, "dwarf", "fhd", part_names(lua))
    g = lua.globals()
    g.TEST_fail[g.DevilForever_Composition.parts.Path("dwarf", "fhd", "deck_joint")] = True
    apply(lua, "dwarf", "fhd")
    comp = g.DevilForever_Composition
    eq((comp.active, comp.frame.shown, comp.partsShown), (True, True, False), "failed part: prepared surfaces")
    eq(visible_parts(lua), [], "failed part: no part left visible")
    eq(comp.top.path, "Interface\\AddOns\\DevilForever_Appearance\\Themes\\dwarf\\Composition\\fhd_top.tga", "top surface")


@case
def themes_without_parts_are_unaffected():
    for preset in PRESETS:
        for theme in THEMES:
            if theme == "horde":
                continue
            lua = session()
            ship(lua, "horde", preset, part_names(lua))
            eq(apply(lua, theme, preset), apply(session(), theme, preset), "%s %s with horde parts shipped" % (theme, preset))
    lua = session()
    ship(lua, "horde", "uhd", part_names(lua))
    apply(lua, "horde", "uhd")
    eq(len(visible_parts(lua)) > 0, True, "horde parts drawn")
    apply(lua, "devil", "uhd")
    comp = lua.globals().DevilForever_Composition
    eq((visible_parts(lua), comp.surround.shown, comp.top.shown, comp.deck.shown), ([], False, True, True),
       "switch to a theme without parts: parts and surround hidden, surfaces back")


@case
def edits_combat_and_missing_dominos():
    lua = session()
    ship(lua, "orc", "fhd", part_names(lua))
    lua.execute("TEST_edits = {['appearance.chat2'] = {position = {}}}")
    apply(lua, "orc", "fhd")
    comp = lua.globals().DevilForever_Composition
    eq((comp.active, visible_parts(lua)), (False, []), "edited layout: individual shell, no parts")
    lua = session()
    ship(lua, "orc", "fhd", part_names(lua))
    lua.globals().TEST_combat = True
    eq(apply(lua, "orc", "fhd"), [], "in combat: nothing")
    lua = session()
    ship(lua, "orc", "fhd", part_names(lua))
    apply(lua, "orc", "fhd", dominos=False)
    comp = lua.globals().DevilForever_Composition
    eq((comp.active, len(visible_parts(lua)) > 0, comp.surround.shown), (True, True, False), "no Dominos: parts, no surround")


@case
def optional_crest_sits_in_the_last_panel():
    for preset in PRESETS:
        lua = session()
        names = part_names(lua, optional=False)
        ship(lua, "tauren", preset, names)
        apply(lua, "tauren", preset)
        eq(any(p["part"] == "deck_crest" for p in visible_parts(lua)), False, "%s no crest without the file" % preset)
        lua = session()
        ship(lua, "tauren", preset, part_names(lua))
        apply(lua, "tauren", preset)
        crest = [p for p in visible_parts(lua) if p["part"] == "deck_crest"]
        chat3 = GEOMETRY[preset]["items"]["chat3"]
        eq(len(crest), 1, "%s crest drawn" % preset)
        c = crest[0]
        eq(chat3["x"] <= c["x"] and c["x"] + c["width"] <= chat3["x"] + chat3["width"], True, "%s crest inside chat3" % preset)


def preview(out):
    """One PNG per preset: placeholder parts pasted at the planned places (horde)."""
    from PIL import Image
    parts = hud_parts.load_parts()
    with tempfile.TemporaryDirectory() as folder:
        hud_parts.write_placeholders(folder, parts, themes=("horde",))
        os.makedirs(out, exist_ok=True)
        for preset in PRESETS:
            lua = session()
            ship(lua, "horde", preset, part_names(lua))
            apply(lua, "horde", preset)
            width, height = GEOMETRY[preset]["screen"]
            image = Image.new("RGBA", (width, height), (24, 24, 28, 255))
            placed = sorted(visible_parts(lua), key=lambda p: ({"BACKGROUND": 0, "BORDER": 1, "ARTWORK": 2}[p["layer"]],
                                                               p["sublevel"]))
            for p in placed:
                _header, art = hud_parts.read_tga(os.path.join(folder, "Themes", "horde", "Parts", preset, p["part"] + ".tga"))
                piece = art.crop((0, 0, int(p["width"]), int(p["height"])))
                image.alpha_composite(piece, (int(p["x"]), int(p["y"])))
            for rect in GEOMETRY[preset]["bars"]:
                box = Image.new("RGBA", (int(rect["x2"] - rect["x1"]), int(rect["y2"] - rect["y1"])), (200, 60, 60, 120))
                image.alpha_composite(box, (int(rect["x1"]), int(rect["y1"])))
            path = os.path.join(out, "hud_parts_%s.png" % preset)
            image.convert("RGB").save(path)
            print("preview %s parts=%d" % (path, len(placed)))


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--preview", metavar="DIR", help="also write preview PNGs from placeholder parts")
    args = parser.parse_args()
    passed, failed = 0, []
    for fn in CASES:
        try:
            fn()
            passed += 1
            print("PASS %s" % fn.__name__)
        except Exception:  # noqa: BLE001 - report every failing case
            failed.append(fn.__name__)
            print("FAIL %s" % fn.__name__)
            traceback.print_exc(limit=4)
    if args.preview:
        preview(args.preview)
    print("lupa=%s cases=%d passed=%d failed=%d" % (lupa.__version__, len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

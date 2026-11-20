"""Composition surface choice of DevilForever_Appearance against the shipped file set.

Usage:  python3 -I Collection/tests/composition/run.py

Crests.lua and Composition.lua run in a Lua 5.1 runtime (lupa) with a stand-in
Core (active preset, active theme, layout edits) and frames that record every
SetTexture path. The client's file lookup (C_UIFileAsset.IsKnownFile) answers
from the files the release build ships (Collection/tools/build.py runtime_files
of Collection/AddOns/DevilForever_Appearance), so a path outside the archive is
unknown. Cases: every theme and preset paints its own top surface and the
reviewed deck (devil: its _deck.tga) and requests only shipped files; an
unknown reviewed deck, a client without the lookup API or a texture that fails
to load never leads to a _deck.tga request for a theme with a reviewed deck —
the composition is hidden and the individual shell stays. This does not
emulate the game client.
"""

import os
import sys
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
sys.path.insert(0, os.path.join(REPO, "Collection", "tools"))
import build  # noqa: E402

PREFIX = "Interface\\AddOns\\DevilForever_Appearance\\"
THEMES = ("devil", "horde", "alliance", "human", "dwarf", "gnome", "nightelf", "orc", "tauren", "troll", "undead",
          "skyborne", "skyborne-horde")
PRESETS = ("fhd", "qhd", "uhd")

STUBS = r"""
TEST_textures = {}
TEST_fail = {}
local Tex = {}
Tex.__index = Tex
local nop = function() end
for _, k in ipairs({"ClearAllPoints", "SetPoint", "SetSize", "SetTexCoord", "SetVertexColor", "SetAlpha"}) do Tex[k] = nop end
function Tex:Show() self.shown = true end
function Tex:Hide() self.shown = false end
function Tex:SetTexture(path)
  TEST_textures[#TEST_textures + 1] = path
  if TEST_fail[path] then return false end
  self.path = path
  return true
end
local function newObj()
  local o = setmetatable({}, Tex)
  function o:CreateTexture() return newObj() end
  function o:SetFrameStrata() end
  function o:SetFrameLevel() end
  function o:EnableMouse() end
  function o:EnableKeyboard() end
  function o:SetAllPoints() end
  return o
end
function CreateFrame() return newObj() end
function InCombatLockdown() return false end
TEST_known = {}
C_UIFileAsset = {IsKnownFile = function(path) return TEST_known[path] == true end}
TEST_preset, TEST_theme = "fhd", "devil"
local ys = {aux = -400, chat1 = -600, status = -850, chat3 = -600}
DevilForever_Core = {
  Presets = {GetActive = function() return TEST_preset end},
  Theme = {GetSet = function() return TEST_theme end, ListTokens = function() return {} end,
           GetFromSet = nop, RegisterSet = nop},
  Edit = {GetEdits = function() return {} end,
          Get = function(_, key)
            local name = key:match("%.(.*)")
            return {position = {relativeTo = "DevilForever_AppearanceRoot", point = "TOPLEFT", relativePoint = "TOPLEFT",
                                x = 0, y = ys[name] or -650}, size = {width = 500, height = 50}}
          end},
}
TEST_frames = setmetatable({}, {__index = function(t, k)
  local f = newObj(); f.fill = newObj(); rawset(t, k, f); return f end})
"""


def shipped_paths():
    kept, _excluded = build.runtime_files("DevilForever_Appearance", FOLDER)
    return {PREFIX + rel.replace("/", "\\") for rel, _full in kept}


SHIPPED = shipped_paths()


def session(known=None, api=True):
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute(STUBS)
    g = lua.globals()
    for path in (SHIPPED if known is None else known):
        g.TEST_known[path] = True
    if not api:
        lua.execute("C_UIFileAsset = nil")
    for name in ("Crests.lua", "Composition.lua"):
        with open(os.path.join(FOLDER, name), "rb") as fh:
            fn = lua.globals().loadstring(fh.read(), ("@" + name).encode())
        (fn[0] if isinstance(fn, tuple) else fn)("DevilForever_Appearance", lua.table())
    lua.execute("DevilForever_Composition:Create(CreateFrame())")
    return lua


def apply(lua, theme, preset):
    g = lua.globals()
    g.TEST_theme, g.TEST_preset = theme, preset
    lua.execute("TEST_textures = {}; DevilForever_Composition:Apply(CreateFrame(), TEST_frames)")
    comp = g.DevilForever_Composition
    return list(g.TEST_textures.values()), comp.active, comp.frame.shown


def surface(theme, preset, name):
    return PREFIX + "Themes\\%s\\Composition\\%s_%s.tga" % (theme, preset, name)


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


@case
def shipped_set_has_reviewed_decks_only():
    for theme in THEMES:
        for preset in PRESETS:
            legacy, reviewed = surface(theme, preset, "deck"), surface(theme, preset, "deck_reviewed")
            if theme == "devil":
                eq((legacy in SHIPPED, reviewed in SHIPPED), (True, False), "devil keeps its own deck %s" % preset)
            else:
                eq((legacy in SHIPPED, reviewed in SHIPPED), (False, True), "%s %s: reviewed deck only" % (theme, preset))


@case
def every_theme_paints_reviewed_deck_from_shipped_files():
    lua = session()
    for theme in THEMES:
        for preset in PRESETS:
            requested, active, shown = apply(lua, theme, preset)
            deck = surface(theme, preset, "deck" if theme == "devil" else "deck_reviewed")
            eq(requested, [surface(theme, preset, "top"), deck], "%s %s surfaces" % (theme, preset))
            eq(all(p in SHIPPED for p in requested), True, "%s %s: only shipped files requested" % (theme, preset))
            eq((active, shown), (True, True), "%s %s composition shown" % (theme, preset))


@case
def unknown_reviewed_deck_keeps_individual_shell():
    for theme in ("horde", "orc", "skyborne-horde"):
        known = SHIPPED - {surface(theme, "fhd", "deck_reviewed")}
        lua = session(known=known)
        requested, active, shown = apply(lua, theme, "fhd")
        eq((requested, active, shown), ([], False, False), "%s: reviewed deck unknown -> shell, nothing loaded" % theme)


@case
def failed_texture_does_not_fall_back_to_legacy_deck():
    lua = session()
    lua.globals().TEST_fail[surface("alliance", "qhd", "deck_reviewed")] = True
    requested, active, shown = apply(lua, "alliance", "qhd")
    eq(any(p.endswith("_deck.tga") for p in requested), False, "no _deck.tga request after a failed reviewed deck")
    eq((active, shown), (False, False), "composition hidden: individual shell")


@case
def failed_texture_without_lookup_api_keeps_shell():
    lua = session(api=False)
    lua.globals().TEST_fail[surface("orc", "fhd", "deck_reviewed")] = True
    requested, active, shown = apply(lua, "orc", "fhd")
    eq(requested, [surface("orc", "fhd", "top"), surface("orc", "fhd", "deck_reviewed")],
       "one attempt, no _deck.tga of the race or its family")
    eq((active, shown), (False, False), "composition hidden: individual shell")


@case
def without_lookup_api_still_only_shipped_names():
    lua = session(api=False)
    for theme in THEMES:
        requested, _active, _shown = apply(lua, theme, "uhd")
        eq(all(p in SHIPPED for p in requested), True, "%s: shipped names without IsKnownFile" % theme)


def main():
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
    print("lupa=%s cases=%d passed=%d failed=%d" % (lupa.__version__, len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

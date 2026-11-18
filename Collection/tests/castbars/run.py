"""Logic tests for DevilForever_Castbars (one cast bar per unit: Quartz over Forever Unit Frames).

Usage:  python3 -I Collection/tests/castbars/run.py

Each case starts a fresh Lua 5.1 runtime (lupa) with stubs for what the addon
calls: CreateFrame with event registration, C_Timer.After, hooksecurefunc (post-hook of an
instance method, as the client does), LibStub("AceAddon-3.0") holding a
stand-in "Quartz3" whose modules answer IsEnabled and whose EnableModule/DisableModule
switch them, and DevilForever_Core.Log.
Forever Unit Frames is stood in for by global frames ForeverUnitFrames_<unit>
with a .castbar that has SetShown/Show/Hide/IsShown; FUF's own show path is
copied from Elements/Castbar.lua setShown (206-210): SetShown, then the shape
code reads IsShown. Neither Quartz nor FUF is run; this checks the addon's
logic only and does not emulate the game client.
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
ADDON_DIR = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Castbars")
ADDON = "DevilForever_Castbars"

STUBS = r"""
TEST_logs = {}

local frames = {}
function CreateFrame(kind)
  local f = {events = {}, scripts = {}}
  function f:RegisterEvent(e) self.events[e] = true end
  function f:UnregisterEvent(e) self.events[e] = nil end
  function f:SetScript(name, fn) self.scripts[name] = fn end
  frames[#frames + 1] = f
  return f
end
function TEST_fire(event, ...)
  for _, f in ipairs(frames) do
    if f.events[event] and f.scripts.OnEvent then f.scripts.OnEvent(f, event, ...) end
  end
end

TEST_hookCount = 0
function hooksecurefunc(t, name, post)
  local orig = t[name]
  TEST_hookCount = TEST_hookCount + 1
  t[name] = function(...)
    local r = orig(...)
    post(...)
    return r
  end
end

-- Quartz stand-in: modules with IsEnabled.
TEST_modules = {}
local quartz = {GetModule = function(self, name, silent) return TEST_modules[name] end}
-- AceAddon mixins EnableModule/DisableModule (AceAddon-3.0.lua 328-349).
function quartz:EnableModule(name) TEST_setModule(name, true) end
function quartz:DisableModule(name) TEST_setModule(name, false) end
TEST_quartzObject = quartz

TEST_timers = {}
C_Timer = {After = function(delay, fn) TEST_timers[#TEST_timers + 1] = {delay, fn} end}
function TEST_runTimers()
  local due = TEST_timers
  TEST_timers = {}
  for _, t in ipairs(due) do t[2]() end
  return #due
end
local aceAddon = {GetAddon = function(self, name, silent) if name == "Quartz3" and TEST_quartz then return quartz end end}
TEST_quartz = true
-- LibStub is a table with a __call metamethod in the client (LibStub.lua).
LibStub = setmetatable({}, {__call = function(self, major, silent)
  if major == "AceAddon-3.0" then return aceAddon end
end})
function TEST_setModule(name, enabled)
  TEST_modules[name] = {IsEnabled = function() return enabled end}
end

function TEST_installCore()
  DevilForever_Core = {Log = function(self, kind, subject, message)
    TEST_logs[#TEST_logs + 1] = kind .. " " .. subject .. " " .. message end}
end

-- FUF stand-in: a unit frame with a cast bar (shown state only).
local barProto = {}
barProto.__index = barProto
function barProto:SetShown(v) self.shown = v and true or false end
function barProto:Show() self.shown = true end
function barProto:Hide() self.shown = false end
function barProto:IsShown() return self.shown end
function TEST_makeFrame(unit, shown)
  local bar = setmetatable({shown = shown and true or false}, barProto)
  _G["ForeverUnitFrames_" .. unit] = {castbar = bar}
  return bar
end
-- FUF Elements/Castbar.lua setShown: SetShown, then the shape reads IsShown.
function TEST_fufSetShown(unit, v)
  local bar = _G["ForeverUnitFrames_" .. unit].castbar
  bar:SetShown(v)
  return bar:IsShown()
end
"""


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


def lst(value):
    return list((value or {}).values()) if isinstance(value, dict) else value


class Session:
    def __init__(self, modules=None, frames=None, core=True, quartz=True):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.g
        g.TEST_quartz = quartz
        if core:
            g.TEST_installCore()
        for name, on in (modules if modules is not None else
                         {"Player": True, "Target": True, "Focus": True, "Pet": True}).items():
            g.TEST_setModule(name, on)
        for unit, shown in (frames if frames is not None else
                            {"player": True, "target": False, "focus": False, "pet": False}).items():
            g.TEST_makeFrame(unit, shown)

    @property
    def g(self):
        return self.lua.globals()

    def load(self):
        path = os.path.join(ADDON_DIR, "Castbars.lua")
        with open(path, "rb") as fh:
            src = fh.read()
        result = self.g.loadstring(src, ("@" + os.path.relpath(path, REPO)).encode())
        fn, err = result if isinstance(result, tuple) else (result, None)
        if fn is None:
            raise AssertionError("compile failed: %s" % err)
        self.before = set(self.g.keys())
        fn(ADDON, self.lua.table())
        return self

    def login(self):
        self.g.TEST_fire("PLAYER_LOGIN")
        self.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
        return self

    def shown(self, unit):
        return self.g["ForeverUnitFrames_" + unit].castbar.shown

    def status(self):
        return to_py(self.g.DevilForever_Castbars.GetStatus())


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


@case
def quartz_owns_player_and_target():
    s = Session().load().login()
    eq(s.shown("player"), False, "player bar shown at login (FUF always-show) hidden at hook time")
    eq(s.g.TEST_fufSetShown("target", True), False, "target cast: FUF shows, shape reads hidden")
    eq(s.g.TEST_fufSetShown("player", True), False, "player cast: hidden")
    eq(s.g.TEST_fufSetShown("player", False), False, "stop: stays hidden")
    st = s.status()
    eq((st["player"]["hidden"], st["target"]["hidden"]), (2, 1), "hide counts")
    eq(st["target"]["quartz"] and st["target"]["hooked"], True, "status")


@case
def show_method_also_hidden():
    s = Session().load().login()
    s.g.ForeverUnitFrames_target.castbar.Show(s.g.ForeverUnitFrames_target.castbar)
    eq(s.shown("target"), False, "Show() path hidden too")


@case
def quartz_module_off_leaves_fuf_bar():
    s = Session(modules={"Player": True, "Target": False, "Focus": True, "Pet": True}).load().login()
    eq(s.g.TEST_fufSetShown("target", True), True, "Quartz Target off: FUF target bar shows")
    eq(s.status()["target"], {"frame": "ForeverUnitFrames_target", "hooked": True, "quartz": False,
                              "fufShown": True, "wanted": True, "hidden": 0}, "target status")


@case
def module_toggled_mid_session():
    s = Session().load().login()
    q = s.g.TEST_quartzObject
    q.DisableModule(q, "Player")
    eq(s.shown("player"), True, "Quartz Player off: FUF's always-show bar back at once")
    eq(s.g.TEST_fufSetShown("player", True), True, "and stays FUF's on the next show")
    q.EnableModule(q, "Player")
    eq(s.shown("player"), False, "turned on again: hidden at once")


@case
def toggle_does_not_show_a_bar_fuf_hid():
    s = Session().load().login()
    q = s.g.TEST_quartzObject
    s.g.TEST_fufSetShown("target", True)
    s.g.TEST_fufSetShown("target", False)
    q.DisableModule(q, "Target")
    eq(s.shown("target"), False, "FUF last asked hidden: stays hidden")
    eq(s.status()["target"]["wanted"], False, "wanted state")
    q.EnableModule(q, "Focus")
    eq(s.shown("player"), False, "other unit's switch leaves player alone")


@case
def login_in_combat_frames_built_after_combat():
    # FUF queues its frame build until combat ends (Single.lua CreateAll, Init.lua AfterCombat).
    s = Session(frames={}).load().login()
    eq(s.status()["player"]["hooked"], False, "no FUF frames during combat")
    s.g.TEST_makeFrame("player", True)
    s.g.TEST_makeFrame("target", False)
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(s.shown("player"), False, "hooked and hidden at PLAYER_REGEN_ENABLED")
    eq(s.g.TEST_fufSetShown("target", True), False, "target hooked too")


@case
def fuf_drain_after_regen_caught_by_retry():
    # FUF's drain may run after our handler or over several frames (Init.lua drain).
    s = Session(frames={}).load().login()
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(len(to_py(s.g.TEST_timers)), 2, "retries scheduled while units are missing")
    s.g.TEST_makeFrame("player", True)
    s.g.TEST_runTimers()
    eq(s.shown("player"), False, "hooked by a retry")


@case
def regen_not_watched_once_all_hooked():
    s = Session(frames={"player": False, "target": False, "focus": False, "pet": False}).load().login()
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(len(to_py(s.g.TEST_timers)), 0, "no retries when every unit is hooked")


@case
def frames_made_after_login_hooked_at_world():
    s = Session(frames={}).load()
    s.g.TEST_fire("PLAYER_LOGIN")
    eq(s.status()["player"]["hooked"], False, "no FUF frame yet")
    s.g.TEST_makeFrame("player", True)
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.shown("player"), False, "hooked and hidden at PLAYER_ENTERING_WORLD")


@case
def missing_focus_frame_is_not_an_error():
    s = Session(frames={"player": False, "target": False}).load().login()
    st = s.status()
    eq((st["focus"]["hooked"], st["focus"].get("fufShown"), st["pet"]["hooked"]), (False, None, False),
       "focus/pet without FUF frames")


@case
def each_bar_hooked_once():
    s = Session().load().login()
    count = s.g.TEST_hookCount
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, False)
    eq(s.g.TEST_hookCount, count, "no second hooks on later PLAYER_ENTERING_WORLD")
    eq(count, 10, "two hooks per unit, four units, and Quartz EnableModule/DisableModule once")
    eq(lst(to_py(s.g.TEST_logs)), ["info DevilForever_Castbars FUF cast bars hooked: player, target, focus, pet"],
       "one Core log line")


@case
def rebuilt_bar_gets_hooked():
    s = Session().load().login()
    s.g.TEST_makeFrame("target", True)
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    eq(s.shown("target"), False, "a new castbar object on the frame is hooked and hidden")


@case
def without_quartz_object_nothing_hidden():
    s = Session(quartz=False).load().login()
    eq(s.shown("player"), True, "player bar left shown")
    eq(s.g.TEST_fufSetShown("target", True), True, "target bar left shown")


@case
def pet_bar_off_in_fuf_stays_off():
    s = Session().load().login()
    eq(s.shown("pet"), False, "FUF pet castbar off by default: never shown")
    eq(s.status()["pet"]["hidden"], 0, "nothing hidden")


@case
def without_core_no_error():
    s = Session(core=False).load().login()
    eq(s.shown("player"), False, "works without Core")
    eq(lst(to_py(s.g.TEST_logs)), [], "no log")


@case
def no_saved_variables_or_extra_globals():
    s = Session().load()
    s.g.ForeverUnitFramesDB = s.lua.table()
    s.g.Quartz3DB = s.lua.table()
    s.login()
    s.g.TEST_fufSetShown("target", True)
    added = set(s.g.keys()) - s.before - {"ForeverUnitFramesDB", "Quartz3DB"}
    eq(added, {"DevilForever_Castbars"}, "only the API table is added")
    eq((len(to_py(s.g.ForeverUnitFramesDB)), len(to_py(s.g.Quartz3DB))), (0, 0), "FUF and Quartz tables untouched")


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
            traceback.print_exc(limit=3)
    print("lupa=%s cases=%d passed=%d failed=%d" % (lupa.__version__, len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

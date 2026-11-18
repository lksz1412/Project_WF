"""Logic tests for DevilForever_StatusStrip (gold, bags, durability, clock, latency, fps).

Usage:  python3 -I Collection/tests/statusstrip/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs stubs for every client
call the addon makes (CreateFrame with event registration, OnShow/OnHide and
FontStrings, UIParent, C_Timer.NewTicker with test-driven ticks, C_Timer.After,
GetMoney, GetInventoryItemDurability, C_Container.GetContainerNumFreeSlots and
the global fallback, GetNetStats, GetFramerate, date, time, GetLocale,
InCombatLockdown, SlashCmdList, print, geterrorhandler), sets the saved
variable from Python data, runs StatusStrip.lua and fires the events a case
needs. hooksecurefunc and SetCVar raise when called. This checks the addon's
logic only; it does not emulate the game client.
"""

import os
import re
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
ADDON_DIR = os.path.join(REPO, "Collection", "AddOns", "DevilForever_StatusStrip")
ADDON = "DevilForever_StatusStrip"
ORDER = ["gold", "bags", "durability", "clock", "latency", "fps"]
FONTSTRING_NAMES = {
    "gold": "DevilForever_StatusStripGold",
    "bags": "DevilForever_StatusStripBags",
    "durability": "DevilForever_StatusStripDurability",
    "clock": "DevilForever_StatusStripClock",
    "latency": "DevilForever_StatusStripLatency",
    "fps": "DevilForever_StatusStripFPS",
}
EXPECTED_GLOBALS = {"DevilForever_StatusStrip", "DevilForever_StatusStripFrame", "DevilForever_StatusStripDB",
                    "SLASH_DEVILFOREVERSTATUS1"} | set(FONTSTRING_NAMES.values())
ALL_ITEM_EVENTS = {"PLAYER_MONEY", "BAG_UPDATE_DELAYED", "BAG_CONTAINER_UPDATE", "UPDATE_INVENTORY_DURABILITY",
                   "PLAYER_EQUIPMENT_CHANGED"}

STUBS = r"""
TEST_count = {}
local function count(name) TEST_count[name] = (TEST_count[name] or 0) + 1 end
function TEST_resetCounts() TEST_count = {} end

TEST_unknownEvents = {}
TEST_falseEvents = {}
TEST_frames = {}
local Region = {}
Region.__index = Region
function Region:SetPoint(point, rel, relPoint, x, y)
  self.points[#self.points + 1] = {point, rel, relPoint, x, y}
end
function Region:ClearAllPoints() self.points = {} end
function Region:Show()
  if not self.shown then
    self.shown = true
    if self.scripts and self.scripts.OnShow then self.scripts.OnShow(self) end
  end
end
function Region:Hide()
  if self.shown then
    self.shown = false
    if self.scripts and self.scripts.OnHide then self.scripts.OnHide(self) end
  end
end
function Region:IsShown() return self.shown end
function Region:SetText(text) self.text = text; self.setTextCalls = self.setTextCalls + 1 end
function Region:GetText() return self.text end
function Region:RegisterEvent(event)
  if TEST_unknownEvents[event] then error("Attempt to register unknown event \"" .. event .. "\"", 2) end
  if TEST_falseEvents[event] then return false end
  self.events[event] = true
end
function Region:UnregisterEvent(event) self.events[event] = nil end
function Region:SetScript(name, fn) self.scripts[name] = fn end
function Region:GetScript(name) return self.scripts[name] end
function Region:SetHeight(h) self.height = h end
function Region:SetFrameStrata(s) self.strata = s end
function Region:EnableMouse(on) self.mouse = on end
function Region:CreateFontString(name, layer, template)
  local fs = setmetatable({name = name, layer = layer, template = template, points = {}, shown = true,
                           setTextCalls = 0, parent = self}, Region)
  if name then _G[name] = fs end
  return fs
end

UIParent = setmetatable({name = "UIParent", points = {}, shown = true, scripts = {}, events = {}}, Region)

function CreateFrame(kind, name, parent)
  local f = setmetatable({kind = kind, name = name, parent = parent, points = {}, shown = true,
                          scripts = {}, events = {}}, Region)
  if name then _G[name] = f end
  TEST_frames[#TEST_frames + 1] = f
  return f
end
function TEST_fire(event, ...)
  for _, f in ipairs(TEST_frames) do
    if f.events[event] and f.scripts.OnEvent then f.scripts.OnEvent(f, event, ...) end
  end
end
function TEST_registered(event)
  for _, f in ipairs(TEST_frames) do
    if f.events[event] then return true end
  end
  return false
end

TEST_tickers = {}
TEST_after = {}
C_Timer = {
  NewTicker = function(seconds, fn)
    count("NewTicker")
    local handle = {seconds = seconds, fn = fn, live = true}
    function handle:Cancel() count("Cancel"); self.live = false end
    TEST_tickers[#TEST_tickers + 1] = handle
    return handle
  end,
  After = function(seconds, fn)
    count("After")
    TEST_after[#TEST_after + 1] = {seconds, fn}
  end,
}
function TEST_liveTickers()
  local n = 0
  for _, t in ipairs(TEST_tickers) do if t.live then n = n + 1 end end
  return n
end
TEST_maxLive = 0
function TEST_tick(n, secondsPerTick)
  for _ = 1, n do
    TEST_now = TEST_now + (secondsPerTick or 1)
    local live = TEST_liveTickers()
    if live > TEST_maxLive then TEST_maxLive = live end
    for _, t in ipairs(TEST_tickers) do
      if t.live then t.fn(t) end
    end
  end
end
function TEST_runAfter()
  local due = TEST_after
  TEST_after = {}
  for _, t in ipairs(due) do t[2]() end
  return #due
end

TEST_money = 0
function GetMoney() count("GetMoney"); return TEST_money end
TEST_durability = {}
function GetInventoryItemDurability(slot)
  count("GetInventoryItemDurability")
  TEST_slotsAsked[#TEST_slotsAsked + 1] = slot
  local d = TEST_durability[slot]
  if d then return d[1], d[2] end
  return nil
end
TEST_slotsAsked = {}
INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED = 1, 19
BACKPACK_CONTAINER, NUM_BAG_SLOTS = 0, 4
TEST_bags = {[0] = {16, 0}, [1] = {0, 0}, [2] = {0, 0}, [3] = {0, 0}, [4] = {0, 0}}
local function freeSlots(bag)
  local b = TEST_bags[bag]
  if b then return b[1], b[2] end
  return 0, 0
end
C_Container = {GetContainerNumFreeSlots = function(bag) count("C_Container.GetContainerNumFreeSlots"); return freeSlots(bag) end}
function GetContainerNumFreeSlots(bag) count("GetContainerNumFreeSlots"); return freeSlots(bag) end
TEST_net = {0, 0, 38.6, 41.2}
function GetNetStats() count("GetNetStats"); return TEST_net[1], TEST_net[2], TEST_net[3], TEST_net[4] end
TEST_fps = 59.7
function GetFramerate() count("GetFramerate"); return TEST_fps end

TEST_now = 1000 * 60 + 30
TEST_clock = nil
function time() count("time"); return TEST_now end
function date(fmt)
  count("date")
  local h, m
  if TEST_clock then
    h, m = TEST_clock[1], TEST_clock[2]
  else
    local minutes = math.floor(TEST_now / 60)
    h, m = math.floor(minutes / 60) % 24, minutes % 60
  end
  if fmt == "%H" then return string.format("%02d", h) end
  if fmt == "%M" then return string.format("%02d", m) end
  error("unexpected date format " .. tostring(fmt))
end

TEST_locale = "enUS"
function GetLocale() return TEST_locale end
TEST_combat = false
function InCombatLockdown() count("InCombatLockdown"); return TEST_combat end
SlashCmdList = {}
TEST_printed = {}
function print(...) TEST_printed[#TEST_printed + 1] = table.concat({...}, " ") end
TEST_errors = {}
function geterrorhandler() return function(err) TEST_errors[#TEST_errors + 1] = tostring(err) end end
function hooksecurefunc() error("hooksecurefunc must not be called") end
function SetCVar() error("SetCVar must not be called") end
"""


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


def lst(value):
    if isinstance(value, dict):
        return [value[k] for k in sorted(value)]
    return value if value is not None else []


class Session:
    def __init__(self, saved=None, locale="enUS", unknown_events=(), false_events=()):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.g
        g.TEST_locale = locale
        for event in unknown_events:
            g.TEST_unknownEvents[event] = True
        for event in false_events:
            g.TEST_falseEvents[event] = True
        if saved is not None:
            g.DevilForever_StatusStripDB = self.table(saved)
        self.before = set(self.globals_now())

    @property
    def g(self):
        return self.lua.globals()

    def globals_now(self):
        return [k for k in self.g.keys()]

    def table(self, value):
        if isinstance(value, dict):
            t = self.lua.table()
            for k, v in value.items():
                t[k] = self.table(v)
            return t
        if isinstance(value, (list, tuple)):
            t = self.lua.table()
            for i, v in enumerate(value, 1):
                t[i] = self.table(v)
            return t
        return value

    def load(self):
        path = os.path.join(ADDON_DIR, "StatusStrip.lua")
        with open(path, "rb") as fh:
            src = fh.read()
        result = self.g.loadstring(src, ("@" + os.path.relpath(path, REPO)).encode())
        fn, err = result if isinstance(result, tuple) else (result, None)
        if fn is None:
            raise AssertionError("compile failed: %s" % err)
        fn(ADDON, self.lua.table())
        return self

    def addon_loaded(self):
        self.g.TEST_fire("ADDON_LOADED", "SomeOtherAddon")
        self.g.TEST_fire("ADDON_LOADED", ADDON)
        return self

    def login(self):
        self.addon_loaded()
        self.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
        return self

    def api(self):
        return self.g.DevilForever_StatusStrip

    def call(self, method, *args):
        api = self.api()
        return api[method](api, *args)

    def fs(self, key):
        return self.g[FONTSTRING_NAMES[key]]

    def text(self, key):
        return self.fs(key).text

    def count(self, name):
        return self.g.TEST_count[name] or 0

    def db(self):
        return to_py(self.g.DevilForever_StatusStripDB)

    def printed(self):
        return lst(to_py(self.g.TEST_printed))

    def errors(self):
        return lst(to_py(self.g.TEST_errors))

    def slash(self, message):
        self.g.TEST_printed = self.lua.table()
        self.g.SlashCmdList.DEVILFOREVERSTATUS(message)
        return self.printed()

    def anchor(self, key):
        points = lst(to_py(self.fs(key).points))
        eq(len(points), 1, "%s has one anchor" % key)
        point, rel, rel_point, x, y = (points[0].get(i) for i in range(1, 6))
        return point, rel["name"] if rel is not None else None, rel_point, x, y


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


def same(s, a, b):
    return bool(s.g.rawequal(a, b))


def strip_colours(text):
    return re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", text)


# 1 Money format ----------------------------------------------------------------

@case
def money_format():
    s = Session().load().login()
    for copper, expected in ((0, "0c"), (7, "7c"), (507, "5s 07c"), (10000, "1g 00s 00c"),
                             (12345678, "1,234g 56s 78c"), (1000000000, "100,000g 00s 00c")):
        s.g.TEST_money = copper
        s.g.TEST_fire("PLAYER_MONEY")
        eq(strip_colours(s.text("gold")), expected, "gold %d without colour codes" % copper)
        eq(s.text("gold"), expected, "gold %d verbatim (the addon adds no colour codes)" % copper)
        eq(s.call("GetValue", "gold"), (copper, expected), "GetValue gold %d" % copper)
    s.g.TEST_money = None
    s.g.TEST_fire("PLAYER_MONEY")
    eq(s.text("gold"), "-", "GetMoney nil")


# 2 Grouping --------------------------------------------------------------------

@case
def gold_grouping():
    s = Session().load().login()
    for gold, grouped in ((999, "999"), (1000, "1,000"), (1234567, "1,234,567")):
        s.g.TEST_money = gold * 10000
        s.g.TEST_fire("PLAYER_MONEY")
        eq(s.text("gold"), grouped + "g 00s 00c", "grouping of %d" % gold)


# 3 Durability minimum ------------------------------------------------------------

@case
def durability_minimum():
    s = Session()
    s.g.TEST_durability = s.table({1: [50, 100], 5: [10, 80]})
    s.load().login()
    eq(s.text("durability"), "Dur 12%", "lowest slot, floor of 12.5")
    eq(s.call("GetValue", "durability"), (12, "Dur 12%"), "GetValue durability")
    s.g.TEST_durability = s.table({})
    s.g.TEST_fire("UPDATE_INVENTORY_DURABILITY")
    eq(s.text("durability"), "Dur -", "no slot has durability")
    s.g.TEST_durability = s.table({3: [0, 0], 7: [29, 100]})
    s.g.TEST_fire("PLAYER_EQUIPMENT_CHANGED")
    eq(s.text("durability"), "Dur 29%", "max 0 skipped (and 29 stays 29)")
    s.g.TEST_durability = s.table({1: [100, 100], 2: [80, 80]})
    s.g.TEST_fire("UPDATE_INVENTORY_DURABILITY")
    eq(s.text("durability"), "Dur 100%", "all full")
    slots = sorted(set(lst(to_py(s.g.TEST_slotsAsked))))
    eq(slots, list(range(1, 20)), "INVSLOT_FIRST_EQUIPPED .. INVSLOT_LAST_EQUIPPED used")


@case
def durability_fallback_range():
    s = Session()
    s.g.INVSLOT_FIRST_EQUIPPED = None
    s.g.INVSLOT_LAST_EQUIPPED = None
    s.load().addon_loaded()
    s.g.TEST_resetCounts()
    s.g.TEST_fire("UPDATE_INVENTORY_DURABILITY")
    eq(s.count("GetInventoryItemDurability"), 18, "fallback range 1..18")
    eq(sorted(lst(to_py(s.g.TEST_slotsAsked))), list(range(1, 19)), "slots 1..18")


@case
def durability_korean_label():
    s = Session(locale="koKR")
    s.g.TEST_durability = s.table({1: [87, 100]})
    s.load().login()
    eq(s.text("durability"), "내구 87%", "koKR label")
    eq(s.text("bags"), "가방 16", "koKR bag label")


# 4 Bag sum -----------------------------------------------------------------------

@case
def bag_sum_general_bags_only():
    s = Session()
    s.g.TEST_bags = s.table({0: [5, 0], 1: [3, 0], 2: [9, 8], 3: [0, 0], 4: [2, 0]})
    s.load().login()
    eq(s.text("bags"), "Bags 10", "family 8 skipped")
    eq(s.call("GetValue", "bags"), (10, "Bags 10"), "GetValue bags")
    eq(s.count("GetContainerNumFreeSlots"), 0, "global function not used while C_Container has it")
    s.g.C_Container = None
    s.g.TEST_resetCounts()
    s.g.TEST_fire("BAG_UPDATE_DELAYED")
    eq((s.text("bags"), s.count("GetContainerNumFreeSlots")), ("Bags 10", 5), "global fallback, bags 0..4")
    s.g.GetContainerNumFreeSlots = None
    s.g.TEST_fire("BAG_UPDATE_DELAYED")
    eq(s.text("bags"), "Bags -", "neither API")


@case
def bag_range_fallback():
    s = Session()
    s.g.BACKPACK_CONTAINER = None
    s.g.NUM_BAG_SLOTS = None
    s.load().addon_loaded()
    s.g.TEST_resetCounts()
    s.g.TEST_fire("BAG_UPDATE_DELAYED")
    eq(s.count("C_Container.GetContainerNumFreeSlots"), 5, "fallback bags 0..4")
    eq(s.text("bags"), "Bags 16", "sum")


# 5 Clock -------------------------------------------------------------------------

@case
def clock_formats():
    s = Session().load().login()
    s.g.TEST_clock = s.table([9, 5])
    s.g.TEST_tick(60)
    eq(s.text("clock"), "09:05", "24 h")
    eq(s.call("GetValue", "clock"), ("09:05", "09:05"), "GetValue clock")
    eq(s.call("SetClock24", False), True, "12 h")
    for (h, m), expected in (((21, 5), "9:05 PM"), ((0, 5), "12:05 AM"), ((12, 0), "12:00 PM")):
        s.g.TEST_clock = s.table([h, m])
        s.g.TEST_tick(60)
        eq(s.text("clock"), expected, "enUS 12 h %02d:%02d" % (h, m))
        eq(s.call("GetValue", "clock")[0], "%02d:%02d" % (h, m), "value stays 24 h")
    ko = Session(locale="koKR", saved={"clock24": False}).load().login()
    for (h, m), expected in (((0, 5), "오전 12:05"), ((12, 0), "오후 12:00"), ((21, 5), "오후 9:05")):
        ko.g.TEST_clock = ko.table([h, m])
        ko.g.TEST_tick(60)
        eq(ko.text("clock"), expected, "koKR 12 h %02d:%02d" % (h, m))


# 6 Latency and FPS ---------------------------------------------------------------

@case
def latency_and_fps():
    s = Session().load().login()
    eq(s.text("latency"), "38/41 ms", "home/world floor")
    eq(s.call("GetValue", "latency"), (38, 41, "38/41 ms"), "GetValue latency")
    eq(s.text("fps"), "59 fps", "fps floor")
    eq(s.call("GetValue", "fps"), (59, "59 fps"), "GetValue fps")
    s.g.TEST_net = s.table([0, 0, None, None])
    s.g.TEST_fps = None
    s.g.TEST_tick(30)
    eq((s.text("latency"), s.text("fps")), ("- ms", "- fps"), "missing values")


# 7 Throttle ----------------------------------------------------------------------

def throttle_counts(combat):
    s = Session().load()
    s.g.TEST_combat = combat
    s.login()
    login_net, login_date = s.count("GetNetStats"), s.count("date")
    s.g.TEST_resetCounts()
    fps = s.fs("fps")
    before = fps.setTextCalls
    s.g.TEST_tick(61)
    # TEST_now starts at second 30 of a minute: the minute changes at tick 30;
    # tick 60 forces one more clock refresh.
    return {"login GetNetStats": login_net, "login date": login_date,
            "GetFramerate": s.count("GetFramerate"), "fps SetText": fps.setTextCalls - before,
            "GetNetStats": s.count("GetNetStats"), "date": s.count("date"), "time": s.count("time")}


@case
def throttle():
    counts = throttle_counts(False)
    eq(counts, {"login GetNetStats": 1, "login date": 2, "GetFramerate": 61, "fps SetText": 0,
                "GetNetStats": 2, "date": 4, "time": 61}, "call counts over 61 ticks")
    eq(throttle_counts(True), counts, "same counts in combat")
    s = Session().load().login()
    fps = s.fs("fps")
    eq(fps.setTextCalls, 1, "fps text set once at login")
    s.g.TEST_fps = 61.2
    s.g.TEST_tick(3)
    eq(fps.setTextCalls, 2, "set again only when the value changes")


@case
def fps_tick_does_no_work_when_unchanged():
    s = Session(saved={"items": {"clock": False, "latency": False}}).load().login()
    s.lua.execute("""
      TEST_formats = 0
      local format = string.format
      string.format = function(...) TEST_formats = TEST_formats + 1; return format(...) end""")
    fps = s.fs("fps")
    before = fps.setTextCalls
    s.g.TEST_tick(10)
    eq((s.g.TEST_formats, fps.setTextCalls - before), (0, 0), "no formatting and no SetText while fps is unchanged")
    s.g.TEST_fps = 59.9
    s.g.TEST_tick(1)
    eq(s.g.TEST_formats, 0, "same whole number: still no formatting")
    s.g.TEST_fps = 75.2
    s.g.TEST_tick(1)
    eq((s.g.TEST_formats, fps.setTextCalls - before, s.text("fps")), (1, 1, "75 fps"), "formatted once on change")
    eq(s.call("GetValue", "fps"), (75, "75 fps"), "value updated")


# 8 Ticker life -------------------------------------------------------------------

@case
def ticker_life():
    s = Session(saved={"items": {"clock": False, "latency": False, "fps": False}}).load().login()
    eq(s.count("NewTicker"), 0, "no timed item: no ticker")
    eq(s.call("SetItemEnabled", "fps", True), True, "fps on")
    eq((s.count("NewTicker"), s.g.TEST_liveTickers()), (1, 1), "one ticker")
    s.call("SetItemEnabled", "clock", True)
    eq(s.count("NewTicker"), 1, "second timed item reuses the ticker")
    strip = s.g.DevilForever_StatusStripFrame
    strip.Hide(strip)
    eq((s.count("Cancel"), s.g.TEST_liveTickers()), (1, 0), "OnHide cancels")
    strip.Show(strip)
    eq((s.count("NewTicker"), s.g.TEST_liveTickers()), (2, 1), "OnShow makes a new ticker")
    s.g.TEST_tick(5)
    s.call("SetItemEnabled", "fps", False)
    eq(s.g.TEST_liveTickers(), 1, "clock still on")
    s.call("SetItemEnabled", "clock", False)
    eq((s.count("Cancel"), s.g.TEST_liveTickers()), (2, 0), "last timed item off cancels")
    eq(s.g.TEST_maxLive, 1, "never more than one live ticker")
    strip.Hide(strip)
    strip.Show(strip)
    eq(s.count("NewTicker"), 2, "no ticker while no timed item is on")


# 9 Item toggles ------------------------------------------------------------------

@case
def item_toggles_and_layout():
    s = Session().load()
    layouts = []
    s.g.TEST_layouts = s.lua.table()
    s.lua.execute("""
      DevilForever_StatusStrip:RegisterCallback('bad', function() error('boom') end)
      DevilForever_StatusStrip:RegisterCallback('good', function(kind, keys)
        local copy = {kind}
        for i, k in ipairs(keys) do copy[i + 1] = k end
        TEST_layouts[#TEST_layouts + 1] = table.concat(copy, ' ')
      end)""")
    s.addon_loaded()
    eq(lst(to_py(s.g.TEST_layouts)), ["LAYOUT " + " ".join(ORDER)], "layout callback at load, all shown")
    eq(len(s.errors()), 1, "callback error passed to the error handler, the next one still ran")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.anchor("gold"), ("LEFT", "DevilForever_StatusStripFrame", "LEFT", 12, 0), "first item on the strip")
    eq(s.anchor("bags"), ("LEFT", "DevilForever_StatusStripGold", "RIGHT", 12, 0), "next item on the previous")
    eq(s.call("SetItemEnabled", "gold", False), True, "gold off")
    eq(s.db()["items"]["gold"], False, "stored")
    eq(s.fs("gold").shown, False, "gold hidden")
    eq(s.g.TEST_registered("PLAYER_MONEY"), False, "PLAYER_MONEY unregistered")
    eq(s.anchor("bags"), ("LEFT", "DevilForever_StatusStripFrame", "LEFT", 12, 0), "bags now first")
    eq(lst(to_py(s.g.TEST_layouts))[-1], "LAYOUT bags durability clock latency fps", "shown keys in order")
    s.g.TEST_resetCounts()
    s.g.TEST_fire("PLAYER_MONEY")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    s.g.TEST_runAfter()
    eq(s.count("GetMoney"), 0, "gold off: GetMoney never called")
    eq(s.call("GetValue", "gold"), None, "no gold value while off")
    eq(s.call("IsItemEnabled", "gold"), False, "IsItemEnabled")
    items = lst(to_py(s.call("ListItems")))
    eq([(i["key"], i["enabled"], i["shown"]) for i in items],
       [("gold", False, False)] + [(k, True, True) for k in ORDER[1:]], "ListItems")
    s.call("SetItemEnabled", "durability", False)
    eq((s.g.TEST_registered("UPDATE_INVENTORY_DURABILITY"), s.g.TEST_registered("PLAYER_EQUIPMENT_CHANGED"),
        s.g.TEST_registered("BAG_UPDATE_DELAYED")), (False, False, True), "durability events off, bag events kept")
    eq(s.anchor("clock"), ("LEFT", "DevilForever_StatusStripBags", "RIGHT", 12, 0), "hidden items skipped")
    s.g.TEST_resetCounts()
    eq(s.call("SetItemEnabled", "gold", True), True, "gold back on")
    eq((s.count("GetMoney"), s.g.TEST_registered("PLAYER_MONEY"), s.fs("gold").shown), (1, True, True),
       "refreshed, registered and shown at once")
    eq(s.call("SetItemEnabled", "nope", True), (False, "unknown item"), "unknown key")
    eq(s.call("SetItemEnabled", "fps", "yes"), (False, "on must be a boolean"), "non-boolean")
    eq(s.call("SetSpacing", 4), True, "spacing 4")
    eq(s.anchor("bags"), ("LEFT", "DevilForever_StatusStripGold", "RIGHT", 4, 0), "re-layout with spacing 4")
    eq(s.call("SetSpacing", -1), (False, "spacing must be a number >= 0"), "negative refused")
    eq(s.call("SetSpacing", "8"), (False, "spacing must be a number >= 0"), "string refused")
    eq(s.call("UnregisterCallback", "bad"), True, "unregister")
    eq(s.call("UnregisterCallback", "bad"), False, "unregister twice")
    eq(same(s, s.call("GetFontString", "fps"), s.fs("fps")), True, "GetFontString")
    eq(s.call("GetFontString", "ammo"), None, "no ammo item")


@case
def spacing_set_from_layout_callback_is_not_nested():
    s = Session().load().login()
    s.lua.execute("""
      TEST_layoutRuns = 0
      DevilForever_StatusStrip:RegisterCallback('skin', function(kind, keys)
        TEST_layoutRuns = TEST_layoutRuns + 1
        local ok = DevilForever_StatusStrip:SetSpacing(4)
        assert(ok)
      end)""")
    eq(s.call("SetSpacing", 8), True, "spacing 8 asked from outside")
    eq(s.g.TEST_layoutRuns, 2, "callback ran for the first layout and once more after it, no recursion")
    eq(s.anchor("bags"), ("LEFT", "DevilForever_StatusStripGold", "RIGHT", 4, 0), "spacing set in the callback applied")
    eq(s.errors(), [], "no error")
    s.g.TEST_layoutRuns = 0
    s.call("SetItemEnabled", "fps", False)
    eq(s.g.TEST_layoutRuns, 2, "same for a layout started by a switch")
    s.lua.execute("""
      TEST_layoutRuns = 0
      DevilForever_StatusStrip:RegisterCallback('skin', function()
        TEST_layoutRuns = TEST_layoutRuns + 1
      end)""")
    s.call("SetSpacing", 6)
    eq(s.g.TEST_layoutRuns, 1, "a callback that asks for nothing: one run")


# 10 Settings ---------------------------------------------------------------------

@case
def settings_load():
    fresh = Session().load().addon_loaded()
    eq(fresh.db(), {"schema": 1, "items": {k: True for k in ORDER}, "clock24": True}, "nil: defaults written")
    partial = Session(saved={"items": {"gold": False}, "extra": {"a": 1}}).load().addon_loaded()
    eq(partial.db(), {"schema": 1, "items": dict({k: True for k in ORDER}, gold=False), "clock24": True,
                      "extra": {"a": 1}}, "missing keys filled, stored values and unknown keys kept")
    eq(partial.fs("gold").shown, False, "stored off flag used")
    bad_items = Session(saved={"items": "x", "clock24": False}).load().addon_loaded()
    eq(bad_items.db(), {"items": "x", "clock24": False, "schema": 1}, "items = 'x' left on disk")
    eq([bad_items.call("IsItemEnabled", k) for k in ORDER], [True] * 6, "session defaults for items")
    bad_items.call("SetItemEnabled", "fps", False)
    eq((bad_items.db()["items"], bad_items.call("IsItemEnabled", "fps")), ("x", False), "session-only switch")
    eq(any("items is not a table" in line for line in lst(to_py(bad_items.call("GetStatusLog")))), True,
       "noted in the status list")
    not_table = Session(saved="broken").load().addon_loaded()
    eq(not_table.g.DevilForever_StatusStripDB, "broken", "not a table: left alone")
    eq(not_table.call("IsItemEnabled", "gold"), True, "defaults used")
    future = {"schema": 2, "items": {"gold": False}, "newThing": 1}
    newer = Session(saved=future).load().addon_loaded()
    eq(newer.db(), future, "schema 2: nothing written")
    eq(newer.call("IsItemEnabled", "gold"), True, "schema 2: defaults used")
    newer.call("SetItemEnabled", "bags", False)
    newer.call("SetClock24", False)
    eq(newer.db(), future, "schema 2: switches stay in this session")
    odd = Session(saved={"schema": 1, "items": {"fps": "yes"}, "clock24": "no"}).load().addon_loaded()
    eq((odd.call("IsItemEnabled", "fps"), odd.db()["items"]["fps"], odd.db()["clock24"]), (True, "yes", "no"),
       "non-boolean flag counts as its default and stays on disk")
    eq(Session().load().call("SetItemEnabled", "fps", False), (False, "settings not loaded yet"), "before load")


# 11 Events -----------------------------------------------------------------------

@case
def events_refresh_and_late_timer():
    s = Session().load().addon_loaded()
    eq({e: bool(s.g.TEST_registered(e)) for e in ALL_ITEM_EVENTS}, {e: True for e in ALL_ITEM_EVENTS},
       "item events registered")
    s.g.TEST_resetCounts()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    eq({n: s.count(n) for n in ("GetMoney", "C_Container.GetContainerNumFreeSlots", "GetInventoryItemDurability",
                                "date", "GetNetStats", "GetFramerate", "After")},
       {"GetMoney": 1, "C_Container.GetContainerNumFreeSlots": 5, "GetInventoryItemDurability": 19, "date": 2,
        "GetNetStats": 1, "GetFramerate": 1, "After": 1}, "PEW refreshes every item and queues one timer")
    eq(s.g.TEST_after[1][1], 5, "5 s later")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    eq(s.count("After"), 1, "no second timer while one is pending")
    s.g.TEST_resetCounts()
    eq(s.g.TEST_runAfter(), 1, "one late refresh")
    eq({n: s.count(n) for n in ("GetMoney", "GetInventoryItemDurability", "GetNetStats", "GetFramerate", "date")},
       {"GetMoney": 1, "GetInventoryItemDurability": 19, "GetNetStats": 0, "GetFramerate": 0, "date": 0},
       "late refresh covers gold, bags and durability")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    eq(s.count("After"), 1, "a new timer after the first one ran")


@case
def unknown_event_does_not_stop_loading():
    s = Session(unknown_events=["BAG_CONTAINER_UPDATE"]).load().login()
    eq(s.g.TEST_registered("BAG_UPDATE_DELAYED"), True, "other bag event registered")
    eq(s.text("bags"), "Bags 16", "bags still shown")
    out = s.slash("")
    eq(any("BAG_CONTAINER_UPDATE not registered" in line for line in out), True, "listed by /dfstatus")
    s.call("SetItemEnabled", "bags", False)
    s.call("SetItemEnabled", "bags", True)
    eq(sum("BAG_CONTAINER_UPDATE" in line for line in lst(to_py(s.call("GetStatusLog")))), 1, "noted once")


@case
def register_event_returning_false_is_a_failure():
    s = Session(false_events=["PLAYER_EQUIPMENT_CHANGED"]).load().login()
    eq(s.g.TEST_registered("PLAYER_EQUIPMENT_CHANGED"), False, "not registered")
    eq(s.g.TEST_registered("UPDATE_INVENTORY_DURABILITY"), True, "other durability event registered")
    log = lst(to_py(s.call("GetStatusLog")))
    eq(log, ["event PLAYER_EQUIPMENT_CHANGED not registered: RegisterEvent returned false"], "reported")
    eq(any("PLAYER_EQUIPMENT_CHANGED not registered" in line for line in s.slash("")), True, "listed by /dfstatus")
    s.call("SetItemEnabled", "durability", False)
    s.call("SetItemEnabled", "durability", True)
    eq(len(lst(to_py(s.call("GetStatusLog")))), 1, "noted once after a retry")


# 12 Slash ------------------------------------------------------------------------

@case
def slash_command():
    s = Session().load().login()
    eq(s.slash(""), ["DevilForever status strip: gold=on bags=on durability=on clock=on latency=on fps=on clock=24 h"],
       "status line")
    s.slash("fps off")
    eq((s.db()["items"]["fps"], s.fs("fps").shown), (False, False), "/dfstatus fps off")
    s.slash("  CLOCK   12 ")
    eq(s.db()["clock24"], False, "/dfstatus clock 12")
    s.slash("clock off")
    eq(s.db()["items"]["clock"], False, "/dfstatus clock off switches the item")
    before = s.db()
    for bad in ("fps maybe", "ammo on", "clock 13", "fps off now", "on"):
        out = s.slash(bad)
        eq(len(out) == 1 and out[0].startswith("Usage: /dfstatus"), True, "usage line for %r" % bad)
        eq(s.db(), before, "nothing changed by %r" % bad)
    ko = Session(locale="koKR").load().login()
    eq(ko.slash("gold off")[0].startswith("DevilForever 상태 띠: gold=끔"), True, "koKR output")


# 13 Safety -----------------------------------------------------------------------

@case
def safety_globals_and_frames():
    s = Session().load().login()
    s.g.TEST_tick(61)
    s.slash("fps off")
    s.slash("clock 12")
    eq(s.errors(), [], "no error (hooksecurefunc and SetCVar stubs raise)")
    added = set(s.globals_now()) - s.before
    eq(added, EXPECTED_GLOBALS, "globals after load")
    strip = s.g.DevilForever_StatusStripFrame
    points = [tuple(p.get(i) for i in range(1, 6)) for p in lst(to_py(strip.points))]
    eq([(p[0], p[1]["name"], p[2], p[3], p[4]) for p in points],
       [("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0), ("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 0)],
       "two points on UIParent")
    eq((strip.parent.name, strip.strata, strip.mouse, strip.height), ("UIParent", "LOW", False, 20), "strip frame")
    for key in ORDER:
        fs = s.fs(key)
        eq((fs.layer, fs.template, same(s, fs.parent, strip)), ("OVERLAY", "GameFontHighlightSmall", True),
           "%s FontString" % key)
    eq(s.count("InCombatLockdown"), 0, "no combat check needed")
    eq(any(s.g.TEST_registered(e) for e in ("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")), False,
       "no combat start/end events")
    eq(s.g.SLASH_DEVILFOREVERSTATUS1, "/dfstatus", "slash name")
    api = s.api()
    eq(api.version, 1, "version")
    eq(same(s, s.call("GetFrame"), strip), True, "GetFrame")


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

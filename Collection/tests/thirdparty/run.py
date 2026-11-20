"""Behaviour tests and runtime probes of the DevilForever patches to third-party addons.

Usage:  python3 -I Collection/tests/thirdparty/run.py

Each case loads the addon's own Lua files into a fresh Lua 5.1 runtime (lupa)
with stand-in client functions (frames that record calls, a clock, C_Timer
with a ticker list and a next-frame queue, unit and XP values set by the
case). The same script runs against the extracted original
(``Collection/upstream``, the manifest ``third_party`` upstream path) and the
shipped copy (``Collection/AddOns``): probe lines print both call counts, the
cases assert the shipped behaviour and, where the patch must not change what
the player sees, that both copies show the same values. This does not
emulate the game client.

Patches covered: Details_TinyThreat (no threat timer while the plugin frame is
hidden), ExperienceForever (per-second time text split from the full bar and
border refresh), ProfileManager (one provider rescan per frame of load events).
"""

import json
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
ADDONS = os.path.join(REPO, "Collection", "AddOns")
MANIFEST = os.path.join(REPO, "Collection", "manifest.json")

STUBS = r"""
TEST_calls = {}
function TEST_count(name) TEST_calls[name] = (TEST_calls[name] or 0) + 1 end
local FRAMES = {}
local Frame = {}
local FrameMT = {__index = function(_, k)
  local v = Frame[k]
  if v ~= nil or k:sub(1, 1) == "_" then return v end
  return function() TEST_count(k) end
end}
function Frame:Show() TEST_count("Show"); self._shown = true end
function Frame:Hide() TEST_count("Hide"); self._shown = false end
function Frame:SetShown(v) if v then self:Show() else self:Hide() end end
function Frame:IsShown() return self._shown ~= false end
function Frame:SetText(t) TEST_count("SetText"); self._text = t end
function Frame:GetText() return self._text end
function Frame:SetValue(v) TEST_count("SetValue"); self._value = v end
function Frame:SetMinMaxValues(a, b) TEST_count("SetMinMaxValues"); self._min, self._max = a, b end
function Frame:SetScript(k, fn) self._scripts[k] = fn end
function Frame:GetScript(k) return self._scripts[k] end
function Frame:RegisterEvent(e) self._events[e] = true end
function Frame:UnregisterEvent(e) self._events[e] = nil end
function Frame:UnregisterAllEvents() self._events = {} end
function Frame:IsEventRegistered(e) return self._events[e] == true end
function Frame:GetFrameLevel() return 1 end
function Frame:GetEffectiveScale() return 1 end
function Frame:GetWidth() return 300 end
function Frame:GetHeight() return 20 end
function Frame:GetSize() return 300, 20 end
function Frame:GetFont() return "Fonts\\FRIZQT__.TTF", 12, "" end
function Frame:SetFont() TEST_count("SetFont"); return true end
function Frame:GetChildren() end
function Frame:GetName() return self._name end
function Frame:GetOwner() return nil end
function Frame:CreateFontString() return TEST_newFrame() end
function Frame:CreateTexture() return TEST_newFrame() end
function TEST_newFrame(name)
  local f = setmetatable({_scripts = {}, _events = {}, _name = name}, FrameMT)
  FRAMES[#FRAMES + 1] = f
  if name then _G[name] = f end
  return f
end
function CreateFrame(_, name) return TEST_newFrame(name) end
function TEST_fire(event, ...)
  for _, f in ipairs(FRAMES) do
    if f._events[event] and f._scripts.OnEvent then f._scripts.OnEvent(f, event, ...) end
  end
end
UIParent = TEST_newFrame("UIParent")
GameTooltip = TEST_newFrame("GameTooltip")
GameTooltip._shown = false
TEST_now = 1000
function GetTime() return TEST_now end
TEST_after = {}
TEST_tickers = {}
C_Timer = {
  After = function(_, fn) TEST_after[#TEST_after + 1] = fn end,
  NewTicker = function(d, fn)
    local t = {fn = fn, d = d}
    function t:Cancel() self.cancelled = true end
    TEST_tickers[#TEST_tickers + 1] = t
    return t
  end,
}
C_Timer.NewTimer = C_Timer.NewTicker
function TEST_flush()
  local rounds = 0
  while #TEST_after > 0 do
    rounds = rounds + 1
    assert(rounds < 50, "next-frame queue does not settle")
    local q = TEST_after
    TEST_after = {}
    for _, fn in ipairs(q) do fn() end
  end
end
function TEST_tick(sec)
  TEST_now = TEST_now + sec
  for _, t in ipairs(TEST_tickers) do if not t.cancelled then t.fn(t) end end
  TEST_flush()
end
function TEST_deepcopy(v)
  if type(v) ~= "table" then return v end
  local out = {}
  for k, x in pairs(v) do out[k] = TEST_deepcopy(x) end
  return out
end
function TEST_wrap(obj, name)
  local orig = obj[name]
  obj[name] = function(...) TEST_count(name); return orig(...) end
end
SlashCmdList = {}
"""


def upstream_dirs():
    with open(MANIFEST, encoding="utf-8") as fh:
        manifest = json.load(fh)
    return {t["folder"]: os.path.join(REPO, t["upstream_path"]) for t in manifest["third_party"]}


UPSTREAM = upstream_dirs()


def runtime(extra=""):
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    lua.execute(STUBS)
    if extra:
        lua.execute(extra)
    return lua


def run_file(lua, path, folder, ns):
    with open(path, "rb") as fh:
        src = fh.read()
    result = lua.globals().loadstring(src, ("@" + os.path.basename(path)).encode())
    fn, err = result if isinstance(result, tuple) else (result, None)
    if fn is None:
        raise AssertionError("compile failed %s: %s" % (path, err))
    fn(folder, ns)


def calls(lua, name):
    return lua.globals().TEST_calls[name] or 0


def reset_calls(lua):
    lua.execute("TEST_calls = {}")


def roots(folder):
    return (("upstream", UPSTREAM[folder]), ("shipped", os.path.join(ADDONS, folder)))


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


def probe(name, before, after):
    print("PROBE %s: upstream %s -> shipped %s" % (name, before, after))


# Details_TinyThreat -------------------------------------------------------------

TINY = r"""
local nop = function() end
DetailsFramework = {UnitGroupRolesAssigned = function() return "DAMAGER" end,
  IsTimewalkWoW = function() return false end, IsClassicWow = function() return false end}
TEST_combat = false
plugin = {Frame = TEST_newFrame("ThreatMeterTestFrame"), SetPluginDescription = nop,
  ScheduleRepeatingTimer = function(self, method, dt) TEST_count("timer"); return {method = method, dt = dt} end,
  CancelTimer = function() TEST_count("cancel") end,
  IsInCombat = function() return TEST_combat end,
  GetInstance = function() return {baseframe = {GetWidth = function() return 300 end}} end,
  GetPluginInstance = function() return {GetSize = function() return 300, 0 end, row_info = {height = 14}} end}
Details = {gump = {}, NewPluginObject = function() return plugin end, RegisterEvent = nop,
  InstallPlugin = function() return nil, {} end, GetSpellInfo = nop}
LibStub = setmetatable({GetLibrary = function() return {Fetch = nop} end},
  {__call = function() return {GetLocale = function() return {} end} end})
IsInRaid = function() return true end
IsInGroup = function() return true end
GetNumGroupMembers = function() return 40 end
GetNumSubgroupMembers = function() return 4 end
GetUnitName = function(name) return name end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitExists = function() return true end
UnitName = function(u) return u end
UnitIsFriend = function() return false end
UnitAffectingCombat = function() return TEST_combat end
UnitDetailedThreatSituation = function() TEST_count("threat"); return false, 0, 0, 0, 0 end
"""


def tiny_session(root):
    lua = runtime(TINY)
    run_file(lua, os.path.join(root, "Details_TinyThreat.lua"), "Details_TinyThreat", lua.table())
    lua.execute("plugin:OnEvent(nil, 'ADDON_LOADED', 'Details_TinyThreat')")
    return lua


def tiny_ticks(lua, n):
    lua.execute("for i = 1, %d do if plugin.job_thread then plugin:Tick() end end" % n)


@case
def tinythreat_probe_hidden_window_combat():
    counts = []
    for _label, root in roots("Details_TinyThreat"):
        lua = tiny_session(root)
        reset_calls(lua)
        lua.execute("plugin:OnDetailsEvent('HIDE'); TEST_combat = true; plugin:OnEvent(nil, 'PLAYER_REGEN_DISABLED')"
                    "; plugin:OnDetailsEvent('COMBAT_PLAYER_ENTER')")
        tiny_ticks(lua, 30)
        counts.append((calls(lua, "timer"), calls(lua, "threat")))
    probe("TinyThreat HIDE then combat, 30 ticks, 40 raid members (timers, threat reads)", counts[0], counts[1])
    eq(counts[0], (1, 1200), "upstream starts a timer while hidden")
    eq(counts[1], (0, 0), "shipped: no timer and no threat read while hidden")


@case
def tinythreat_shown_window_tracks_combat():
    lua = tiny_session(os.path.join(ADDONS, "Details_TinyThreat"))
    lua.execute("plugin:OnDetailsEvent('SHOW')")
    eq(lua.globals().plugin.job_thread, None, "shown out of combat: no timer yet")
    lua.execute("TEST_combat = true; plugin:OnEvent(nil, 'PLAYER_REGEN_DISABLED')")
    eq(calls(lua, "timer"), 1, "combat start while shown starts the timer")
    tiny_ticks(lua, 3)
    eq(calls(lua, "threat"), 120, "each tick reads the 40 members")
    lua.execute("plugin:OnDetailsEvent('COMBAT_PLAYER_ENTER')")
    eq(calls(lua, "timer"), 1, "Details combat event while active: no second timer")
    lua.execute("TEST_combat = false; plugin:OnEvent(nil, 'PLAYER_REGEN_ENABLED')")
    eq((lua.globals().plugin.job_thread, lua.globals().plugin.Actived), (None, False), "combat end stops it")


@case
def tinythreat_shown_again_during_combat_starts():
    lua = tiny_session(os.path.join(ADDONS, "Details_TinyThreat"))
    lua.execute("plugin:OnDetailsEvent('SHOW'); TEST_combat = true; plugin:OnEvent(nil, 'PLAYER_REGEN_DISABLED')")
    lua.execute("plugin:OnDetailsEvent('HIDE')")
    eq(lua.globals().plugin.job_thread, None, "HIDE during combat cancels the timer")
    lua.execute("plugin:OnDetailsEvent('COMBAT_PLAYER_ENTER'); plugin:OnEvent(nil, 'PLAYER_REGEN_DISABLED')")
    eq((calls(lua, "timer"), lua.globals().plugin.job_thread), (1, None), "hidden: combat events start nothing")
    lua.execute("plugin:OnDetailsEvent('SHOW')")
    eq(calls(lua, "timer"), 2, "shown again during combat: timer starts")
    reset_calls(lua)
    tiny_ticks(lua, 2)
    eq(calls(lua, "threat"), 80, "threat read again")


# ExperienceForever --------------------------------------------------------------

EF = r"""
local nop = function() end
TEST_unit = {level = 30, xp = 1000, max = 20000, rested = 500}
function UnitLevel() return TEST_unit.level end
function UnitXP() return TEST_unit.xp end
function UnitXPMax() return TEST_unit.max end
function GetXPExhaustion() return TEST_unit.rested end
function GetMaxPlayerLevel() return 60 end
function UnitClass() return "Warrior", "WARRIOR" end
function UnitExists() return false end
function UnitName() return "Hero" end
function UnitSex() return 2 end
function GetPhysicalScreenSize() return 1920, 1080 end
function GetQuestLogRewardXP() return 0 end
C_QuestLog = {GetNumQuestLogEntries = function() return 0 end}
RAID_CLASS_COLORS = {WARRIOR = {r = 0.78, g = 0.61, b = 0.43}}
NUM_CHAT_WINDOWS = 0
Minimap = TEST_newFrame("Minimap")
local function lib() return setmetatable({}, {__index = function() return nop end}) end
local LIBS = {}
LIBS["AceAddon-3.0"] = {NewAddon = function(_, name)
  local a = {RegisterChatCommand = nop, Print = nop}; TEST_addon = a; return a end}
LIBS["AceDB-3.0"] = {New = function(_, _, defaults) return {global = TEST_deepcopy(defaults.global)} end}
LIBS["LibSharedMedia-3.0"] = {Register = nop, RegisterCallback = nop,
  Fetch = function(_, _, key) return key end, List = function() return {} end, HashTable = function() return {} end}
LibStub = setmetatable({}, {__call = function(_, name) return LIBS[name] or lib() end})
"""


def ef_session(root):
    lua = runtime(EF)
    run_file(lua, os.path.join(root, "ExperienceForever.lua"), "ExperienceForever", lua.table())
    lua.execute("""
local a = TEST_addon
a:OnInitialize()
a:OnEnable()
TEST_fire('PLAYER_ENTERING_WORLD')
TEST_fire('TIME_PLAYED_MSG', 7200, 1800)
TEST_flush()
for _, name in ipairs({'Update', 'UpdateBorder', 'UpdateRepBar'}) do TEST_wrap(a, name) end
""")
    return lua


SNAPSHOT = r"""
return function()
  local a = TEST_addon
  local out = {}
  for k, fs in pairs(a.Texts) do out['text.' .. k] = fs._text end
  for _, name in ipairs({'ProgressBar', 'QuestBar', 'RestedBar', 'RepBar', 'PetBar'}) do
    local b = a[name]
    out[name] = tostring(b._value) .. '/' .. tostring(b._min) .. '-' .. tostring(b._max) .. ' ' .. tostring(b:IsShown())
  end
  return out
end
"""


def ef_snapshot(lua):
    fn = lua.execute(SNAPSHOT)
    return {k: v for k, v in fn().items()}


def ef_script(lua):
    """Display state after each of 40 one-second ticks with silent and event-driven changes."""
    states = []
    for second in range(1, 41):
        if second == 10:
            lua.execute("TEST_unit.xp = 1500")                       # no event: the ticker must see it
        if second == 15:
            lua.execute("TEST_unit.rested = 900")                    # rested growth, no event
        if second == 20:
            lua.execute("TEST_unit.xp = 2600; TEST_fire('PLAYER_XP_UPDATE')")
        if second == 25:
            lua.execute("TEST_addon.db.global.showLabels = not TEST_addon.db.global.showLabels;"
                        " TEST_addon:QueueUpdate()")
        if second == 30:
            lua.execute("TEST_unit.level = 31; TEST_unit.xp = 100; TEST_unit.max = 21000;"
                        " TEST_fire('PLAYER_LEVEL_UP'); TEST_fire('PLAYER_XP_UPDATE')")
        lua.execute("TEST_tick(1)")
        states.append(ef_snapshot(lua))
    return states


@case
def experienceforever_probe_idle_ticks():
    counts = []
    for _label, root in roots("ExperienceForever"):
        lua = ef_session(root)
        reset_calls(lua)
        lua.execute("for i = 1, 30 do TEST_tick(1) end")
        counts.append((calls(lua, "SetText"), calls(lua, "SetValue") + calls(lua, "SetMinMaxValues"),
                       calls(lua, "UpdateRepBar"), calls(lua, "UpdateBorder")))
    probe("ExperienceForever 30 idle ticks (SetText, bar value/range writes, rep refresh, border refresh)",
          counts[0], counts[1])
    eq(counts[0][2:], (30, 30), "upstream: full refresh every tick")
    eq(counts[1][1:], (0, 0, 0), "shipped: no bar, reputation or border work on idle ticks")
    eq(counts[1][0] < counts[0][0], True, "shipped sets fewer texts")


@case
def experienceforever_display_same_every_second():
    up, shipped = [ef_script(ef_session(root)) for _label, root in roots("ExperienceForever")]
    eq(len(up), 40, "40 snapshots")
    for second, (a, b) in enumerate(zip(up, shipped), 1):
        eq(b, a, "display at second %d" % second)
    eq(shipped[9]["ProgressBar"].startswith("1500/"), True, "silent XP change shown at the same tick")
    eq(shipped[14]["RestedBar"] != shipped[13]["RestedBar"], True, "silent rested change shown")
    eq(shipped[38]["text.barCenter"] != shipped[3]["text.barCenter"], True, "level text follows the level up")


@case
def experienceforever_ticker_full_update_only_on_change():
    lua = ef_session(os.path.join(ADDONS, "ExperienceForever"))
    reset_calls(lua)
    lua.execute("TEST_tick(1)")
    eq(calls(lua, "Update"), 0, "idle tick: no full update")
    lua.execute("TEST_unit.rested = 501; TEST_tick(1)")
    eq(calls(lua, "Update"), 1, "rested change: one full update")
    lua.execute("TEST_fire('UPDATE_FACTION'); TEST_tick(1)")
    eq(calls(lua, "Update"), 2, "event-driven update still runs once")


# ProfileManager -------------------------------------------------------------------

PM = r"""
local nop = function() end
local function lib() return setmetatable({}, {__index = function() return nop end}) end
TEST_registry = {}
for i = 1, 20 do
  local sv = {profiles = {Default = {}}, profileKeys = {}}
  _G["TestAddon" .. i .. "DB"] = sv
  TEST_registry[{sv = sv, keys = {profile = "Default"}, profiles = sv.profiles}] = true
end
local LIBS = {["AceDB-3.0"] = {db_registry = TEST_registry}}
LibStub = setmetatable({}, {__call = function(_, name) return LIBS[name] or lib() end})
C_AddOns = {GetAddOnInfo = function(name) return name, name, nil, false end, IsAddOnLoaded = function() return false end}
function issecurevariable(t, k) for name, v in pairs(_G) do if v == t[k] then return false, name end end return false, nil end
function UnitName() return "Hero" end
function GetRealmName() return "Realm" end
function UnitClass() return "Warrior", "WARRIOR" end
function strcmputf8i(a, b) a, b = a:lower(), b:lower(); return a < b and -1 or (a > b and 1 or 0) end
"""


def pm_session(root):
    lua = runtime(PM)
    ns = lua.table()
    for name in ("Core.lua", "Providers.lua"):
        run_file(lua, os.path.join(root, name), "ProfileManager", ns)
    lua.execute("TEST_wrap(ProfileManager, 'TryRegisterAllProviders'); TEST_wrap(ProfileManager, 'IsBlacklistedDB')")
    return lua


def pm_login(lua, addons=40):
    lua.execute("for i = 1, %d do TEST_fire('ADDON_LOADED', 'Addon' .. i) end; TEST_fire('PLAYER_LOGIN')" % addons)
    lua.execute("TEST_flush()")


def pm_providers(lua):
    return sorted(k for k in lua.globals().ProfileManager.Providers.keys())


@case
def profilemanager_probe_login_burst():
    counts = []
    for _label, root in roots("ProfileManager"):
        lua = pm_session(root)
        pm_login(lua)
        counts.append((calls(lua, "TryRegisterAllProviders"), calls(lua, "IsBlacklistedDB")))
    probe("ProfileManager 40 ADDON_LOADED + PLAYER_LOGIN in one frame (rescans, root-DB exception checks)",
          counts[0], counts[1])
    eq(counts[0], (41, 820), "upstream: one rescan per event")
    eq(counts[1], (1, 20), "shipped: one rescan for the burst")


@case
def profilemanager_same_providers_and_later_loads():
    up, shipped = [pm_session(root) for _label, root in roots("ProfileManager")]
    pm_login(up)
    pm_login(shipped)
    eq(pm_providers(shipped), pm_providers(up), "same providers after login")
    eq(len(pm_providers(shipped)) >= 20, True, "AceDB providers registered")
    shipped.execute("TEST_fire('ADDON_LOADED', 'LateAddon')")
    eq(calls(shipped, "TryRegisterAllProviders"), 1, "a later load waits for the next frame")
    shipped.execute("TEST_flush()")
    eq(calls(shipped, "TryRegisterAllProviders"), 2, "and is rescanned then")
    shipped.execute("ProfileManager.MainUI = TEST_newFrame(); ProfileManager.RefreshMainUI = function() end"
                    "; TEST_wrap(ProfileManager, 'RefreshMainUI')"
                    "; TEST_fire('ADDON_LOADED', 'Other'); TEST_fire('ADDON_LOADED', 'Other2'); TEST_flush()")
    eq((calls(shipped, "TryRegisterAllProviders"), calls(shipped, "RefreshMainUI")), (3, 2),
       "open UI: one rescan, refreshed as after one upstream event (rebuild + shown-UI refresh)")


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

"""Logic tests for DevilForever_DetailsSetup (second Details! window showing Tiny Threat).

Usage:  python3 -I Collection/tests/detailssetup/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs stubs for what the
addon calls (CreateFrame with event registration, C_Timer.After,
InCombatLockdown, C_AddOns.IsAddOnLoaded, geterrorhandler, a DevilForever_Core
with Log and IsLoadedInClient) and a stand-in for the Details! object. The
stand-in copies only what the addon reads and calls, as read in the Details
20261109 sources: IsLoaded / initializing (core/parser.lua 6744-6751,
startup.lua 424), character_first_run (functions/loaddata.lua 294-300),
always_use_profile (loaddata.lua 280-290), GetNumInstances / GetInstance
(classes/class_instance.lua 1163-1194), CreateInstance(true) (1800-1855: false
at the window limit, else the next window), RaidTables.NameTable /
PluginsInUse / EnableRaidMode (core/plugins_raid.lua 61-163: mode 4, plugin
shown when installed, enabled and not in use elsewhere). Details itself is not
run. This checks the addon's logic only; it does not emulate the game client.
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
ADDON_DIR = os.path.join(REPO, "Collection", "AddOns", "DevilForever_DetailsSetup")
ADDON = "DevilForever_DetailsSetup"
PLUGIN = "DETAILS_PLUGIN_TINY_THREAT"

STUBS = r"""
TEST_errors = {}
TEST_logs = {}
TEST_calls = {}

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

TEST_timers = {}
C_Timer = {After = function(delay, fn) TEST_timers[#TEST_timers + 1] = {delay, fn} end}
function TEST_runTimers()
  local due = TEST_timers
  TEST_timers = {}
  for _, t in ipairs(due) do t[2]() end
  return #due
end

TEST_combat = false
function InCombatLockdown() return TEST_combat end
function geterrorhandler() return function(err) TEST_errors[#TEST_errors + 1] = tostring(err) end end

TEST_loaded = {}
C_AddOns = {IsAddOnLoaded = function(folder) return TEST_loaded[folder] == true end}
function TEST_installCore()
  DevilForever_Core = {
    Log = function(self, kind, subject, message) TEST_logs[#TEST_logs + 1] = kind .. " " .. subject .. " " .. message end,
    IsLoadedInClient = function(folder) return TEST_loaded[folder] == true end,
  }
end

-- Stand-in for the Details! object (calls the addon uses only; see the docstring).
local function newFrame(name)
  local f = {name = name, points = {}}
  function f:SetPoint(...) self.points[#self.points + 1] = {...} end
  return f
end

local function newWindow(id)
  local w = {meu_id = id, modo = 2, ativa = true, baseframe = newFrame("DetailsBaseFrame" .. id)}
  function w:GetId() return self.meu_id end
  function w:SaveMainWindowPosition() TEST_calls[#TEST_calls + 1] = "save-pos " .. self.meu_id end
  function w:RestoreMainWindowPosition() TEST_calls[#TEST_calls + 1] = "restore-pos " .. self.meu_id end
  return w
end

function TEST_installDetails(opts)
  local D = {
    isLoaded = true, initializing = nil,
    character_first_run = opts.firstRun, always_use_profile = opts.shared or false,
    instances_amount = opts.limit or 5, tabela_instancias = {},
  }
  if opts.initializing then D.initializing = true end
  D.IsLoaded = function() return D.isLoaded end
  for i = 1, (opts.windows or 1) do D.tabela_instancias[i] = newWindow(i) end
  function D:GetNumInstances() return #D.tabela_instancias end
  function D:GetInstance(id) return D.tabela_instancias[id] end
  function D:CreateInstance(id)
    TEST_calls[#TEST_calls + 1] = "create " .. tostring(id)
    if opts.raiseOnCreate then error("stand-in error in CreateInstance") end
    if #D.tabela_instancias >= D.instances_amount then return false end
    local w = newWindow(#D.tabela_instancias + 1)
    D.tabela_instancias[#D.tabela_instancias + 1] = w
    return w
  end
  local plugin = nil
  if opts.plugin ~= false then plugin = {__enabled = opts.pluginEnabled ~= false, Frame = {}} end
  D.RaidTables = {NameTable = {}, PluginsInUse = {}}
  if plugin then D.RaidTables.NameTable[TEST_PLUGIN] = plugin end
  if opts.pluginInUse then D.RaidTables.PluginsInUse[TEST_PLUGIN] = opts.pluginInUse end
  function D.RaidTables:EnableRaidMode(instance, name)
    TEST_calls[#TEST_calls + 1] = "raid " .. instance.meu_id .. " " .. tostring(name)
    instance.modo = 4
    local p = self.NameTable[name]
    local inUse = self.PluginsInUse[name]
    if opts.noSwitch or not p or not p.__enabled or (inUse and inUse ~= instance.meu_id) then return end
    instance.current_raid_plugin = name
    instance.last_raid_plugin = name
    self.PluginsInUse[name] = instance.meu_id
  end
  Details = D
end
"""


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


def lst(value):
    return list((value or {}).values()) if isinstance(value, dict) else value


class Session:
    def __init__(self, saved=None, details=True, core=True, loaded=True, **opts):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.g
        g.TEST_PLUGIN = PLUGIN
        if core:
            g.TEST_installCore()
        g.TEST_loaded["Details"] = loaded
        if details:
            opts.setdefault("firstRun", True)
            g.TEST_installDetails(self.table(opts))
        if saved is not None:
            g.DevilForever_DetailsSetupDB = self.table(saved)

    @property
    def g(self):
        return self.lua.globals()

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
        path = os.path.join(ADDON_DIR, "DetailsSetup.lua")
        with open(path, "rb") as fh:
            src = fh.read()
        result = self.g.loadstring(src, ("@" + os.path.relpath(path, REPO)).encode())
        fn, err = result if isinstance(result, tuple) else (result, None)
        if fn is None:
            raise AssertionError("compile failed: %s" % err)
        fn(ADDON, self.lua.table())
        return self

    def login(self):
        self.g.TEST_fire("ADDON_LOADED", ADDON)
        self.g.TEST_fire("PLAYER_LOGIN")
        self.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
        return self.g.TEST_runTimers()

    def calls(self):
        return lst(to_py(self.g.TEST_calls))

    def record(self):
        return to_py(self.g.DevilForever_DetailsSetupDB)

    def status(self):
        return to_py(self.g.DevilForever_DetailsSetup.GetStatus())

    def window(self, i):
        return to_py(self.g.Details.tabela_instancias[i])


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


MADE = ["create true", "save-pos 2", "restore-pos 2", "raid 2 " + PLUGIN]


@case
def first_run_opens_threat_window():
    s = Session().load()
    eq(s.login(), 1, "one timer after PLAYER_ENTERING_WORLD")
    eq(s.calls(), MADE, "new window, placed like Details' welcome window, switched to the plugin")
    eq(s.record(), {"version": 1, "result": "created", "window": 2}, "record")
    w1, w2 = s.window(1), s.window(2)
    eq((w1["modo"], w1.get("current_raid_plugin")), (2, None), "window 1 untouched (group mode, damage)")
    eq((w2["modo"], w2["current_raid_plugin"]), (4, PLUGIN), "window 2 shows Tiny Threat")
    points = [lst(p) for p in lst(w2["baseframe"]["points"])]
    eq([(p[0], p[1]["name"], p[2], p[3], p[4]) for p in points],
       [("topleft", "DetailsBaseFrame1", "topright", 50, 0), ("bottomleft", "DetailsBaseFrame1", "bottomright", 50, 0)],
       "anchored right of window 1 as Details' welcome window")
    eq(lst(to_py(s.g.TEST_logs)), ["info DevilForever_DetailsSetup created"], "Core status log")
    eq((s.status()["state"], s.status()["record"]["result"]), ("applied", "created"), "GetStatus")


@case
def delay_and_only_first_world_entry():
    s = Session().load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    eq(to_py(s.g.TEST_timers)[1][1] >= 5, True, "delay after Details' startup (PLAYER_LOGIN + 1 frame, +4 s announce)")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    eq(len(to_py(s.g.TEST_timers)), 1, "only the first PLAYER_ENTERING_WORLD schedules")


@case
def existing_settings_are_kept():
    s = Session(firstRun=False).load()
    s.login()
    eq(s.calls(), [], "no Details call")
    eq(s.record(), {"version": 1, "result": "kept-existing", "reason": "settings existed before this session"},
       "record")
    eq(s.g.Details.tabela_instancias[2], None, "no second window")


@case
def shared_profile_is_kept():
    s = Session(shared=True).load()
    s.login()
    eq((s.calls(), s.record()["result"], s.record()["reason"]), ([], "kept-existing", "account-wide profile"),
       "account-wide profile untouched")


@case
def second_window_already_there_is_kept():
    s = Session(windows=2).load()
    s.login()
    eq((s.calls(), s.record()["reason"]), ([], "more than one window"), "user's windows kept")


@case
def plugin_already_shown_is_kept():
    s = Session(pluginInUse=1).load()
    s.login()
    eq((s.calls(), s.record()["reason"]), ([], "plugin already shown"), "plugin in use kept")


@case
def plugin_missing_or_disabled():
    s = Session(plugin=False).load()
    s.login()
    eq((s.calls(), s.record()), ([], {"version": 1, "result": "plugin-missing"}), "not installed")
    s2 = Session(pluginEnabled=False).load()
    s2.login()
    eq((s2.calls(), s2.record()["result"]), ([], "plugin-missing"), "disabled in Details")


@case
def window_limit_recorded():
    s = Session(limit=1).load()
    s.login()
    eq(s.calls(), ["create true"], "asked for a window")
    eq(s.record(), {"version": 1, "result": "window-limit"}, "record")


@case
def switch_not_taken_is_not_applied():
    s = Session(noSwitch=True).load()
    s.login()
    eq(s.record(), {"version": 1, "result": "not-applied", "window": 2}, "post-check after the switch")


@case
def details_error_reported():
    s = Session(raiseOnCreate=True).load()
    s.login()
    eq(s.record(), {"version": 1, "result": "error"}, "record")
    errors = lst(to_py(s.g.TEST_errors))
    eq(len(errors) == 1 and "stand-in error in CreateInstance" in errors[0], True, "error handler got it")


@case
def runs_once_per_character():
    saved = {"version": 1, "result": "created", "window": 2}
    s = Session(saved=saved).load()
    s.login()
    eq(s.calls(), [], "no call the second time")
    eq(s.status()["state"], "done-before", "state")


@case
def not_started_retries_then_stops():
    s = Session(initializing=True).load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    for _ in range(5):
        s.g.TEST_runTimers()
    eq((s.calls(), s.record()), ([], None), "nothing done, nothing stored")
    eq((s.status()["state"], s.status()["tries"]), ("details-not-ready", 3), "three tries in all")
    eq(len(to_py(s.g.TEST_timers)), 0, "no further timer")


@case
def started_on_retry():
    s = Session(initializing=True).load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    s.g.TEST_runTimers()
    s.g.Details.initializing = None
    eq(s.g.TEST_runTimers(), 1, "retry timer")
    eq(s.record()["result"], "created", "made on the second try")


@case
def details_not_loaded_stores_nothing():
    s = Session(details=False, loaded=False).load()
    s.login()
    eq((s.record(), s.status()["state"]), (None, "details-not-loaded"), "nothing without Details")


@case
def combat_delays_to_regen_enabled():
    s = Session().load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    s.g.TEST_combat = True
    s.g.TEST_runTimers()
    eq((s.calls(), s.status()["state"]), ([], "waiting-combat"), "nothing in combat")
    s.g.TEST_combat = False
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(s.g.TEST_runTimers(), 1, "one timer after combat")
    eq(s.calls(), MADE, "made after combat")
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(len(to_py(s.g.TEST_timers)), 0, "no second run")


@case
def without_core_table_client_api_used():
    s = Session(core=False).load()
    s.login()
    eq(s.record()["result"], "created", "Details seen through C_AddOns")
    eq(lst(to_py(s.g.TEST_logs)), [], "no Core log")


@case
def wrong_type_saved_variable_replaced():
    s = Session(saved="broken").load()
    s.login()
    eq(s.record()["result"], "created", "own saved variable recreated")


@case
def details_saved_variables_not_touched():
    s = Session().load()
    s.g._detalhes_database = s.table({"active_profile": "Hero-Realm"})
    s.g._detalhes_global = s.table({"__profiles": {"Hero-Realm": {"instances": {}}}})
    before = (to_py(s.g._detalhes_database), to_py(s.g._detalhes_global))
    s.login()
    eq((to_py(s.g._detalhes_database), to_py(s.g._detalhes_global)), before, "Details saved variables unchanged")


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

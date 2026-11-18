"""Logic tests for DevilForever_FUFDefaults (FUF raid frames off while Grid2 is loaded).

Usage:  python3 -I Collection/tests/fufdefaults/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs stubs for what the
addon calls (CreateFrame with event registration, C_Timer.After,
InCombatLockdown, UnitFullName, GetNormalizedRealmName, C_AddOns.IsAddOnLoaded,
geterrorhandler, a DevilForever_Core with Log and IsLoadedInClient) and a
stand-in for Forever Unit Frames' command handler SlashCmdList.FOREVERUNITFRAMES.
The stand-in copies only the effect of the command the addon sends, as read
in FUF Core/Commands.lua 69-78 and Raid/Profiles.lua 1-8: "raid off" stores
general.enabled = false in ForeverUnitFramesDB.raid[<char>] at once; "set party
enabled off" (never expected) is recorded and changes a stand-in for FUF's
in-memory profile. FUF itself is not run. This checks the addon's logic only; it
does not emulate the game client.
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
ADDON_DIR = os.path.join(REPO, "Collection", "AddOns", "DevilForever_FUFDefaults")
ADDON = "DevilForever_FUFDefaults"
CHAR = "Hero-Realm"

STUBS = r"""
TEST_calls = {}
TEST_errors = {}
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

TEST_name, TEST_realm, TEST_normalized = "Hero", "Realm", "Realm"
function UnitFullName(unit) return TEST_name, TEST_realm end
function GetNormalizedRealmName() return TEST_normalized end

TEST_loaded = {}
C_AddOns = {IsAddOnLoaded = function(folder) return TEST_loaded[folder] == true end}
function TEST_installCore()
  DevilForever_Core = {
    Log = function(self, kind, subject, message) TEST_logs[#TEST_logs + 1] = kind .. " " .. subject .. " " .. message end,
    IsLoadedInClient = function(folder) return TEST_loaded[folder] == true end,
  }
end

-- Stand-in for FUF's command handler (effects only, see the module docstring).
TEST_partyMemory = nil
TEST_raidStores = true
TEST_raiseOn = nil
function TEST_installFUF()
  SlashCmdList = SlashCmdList or {}
  SlashCmdList.FOREVERUNITFRAMES = function(msg)
    TEST_calls[#TEST_calls + 1] = msg
    if msg == TEST_raiseOn then error("stand-in error on " .. msg) end
    if msg == "raid off" and TEST_raidStores then
      local name, realm = UnitFullName("player")
      if not realm or realm == "" then realm = GetNormalizedRealmName() end
      local key = name .. "-" .. realm
      ForeverUnitFramesDB.raid = ForeverUnitFramesDB.raid or {}
      ForeverUnitFramesDB.raid[key] = ForeverUnitFramesDB.raid[key] or {general = {}}
      ForeverUnitFramesDB.raid[key].general.enabled = false
    elseif msg == "set party enabled off" then
      TEST_partyMemory = false
    end
  end
end
"""


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


def lst(value):
    return list((value or {}).values()) if isinstance(value, dict) else value


def fuf_after_login(raid_general=None, profiles=None, active=None, profile=None, char=CHAR):
    """ForeverUnitFramesDB as FUF leaves it after its PLAYER_LOGIN (Boot.lua 27, 31, Raid/Profiles.lua 92-103)."""
    db = {"raid": {char: {"general": dict(raid_general or {}), "r10": {}, "r20": {}, "r40": {}}},
          "profiles": profiles or {}, "active": active or {}}
    if profile is not None:
        db["profile"] = profile
    return db


class Session:
    def __init__(self, fuf=None, saved=None, grid2=True, core=True, command=True):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.g
        if core:
            g.TEST_installCore()
        if command:
            g.TEST_installFUF()
        g.TEST_loaded["ForeverUnitFrames"] = True
        g.TEST_loaded["Grid2"] = grid2
        if fuf is not None:
            g.ForeverUnitFramesDB = self.table(fuf)
        if saved is not None:
            g.DevilForever_FUFDefaultsDB = self.table(saved)

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
        path = os.path.join(ADDON_DIR, "FUFDefaults.lua")
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
        db = to_py(self.g.DevilForever_FUFDefaultsDB)
        return db and db.get("chars", {}).get(CHAR)

    def status(self):
        api = self.g.DevilForever_FUFDefaults
        return to_py(api.GetStatus())

    def raid_enabled(self):
        return to_py(self.g.ForeverUnitFramesDB)["raid"][CHAR]["general"].get("enabled")


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


RAID = ["raid off"]


@case
def first_login_with_grid2_switches_raid_off():
    s = Session(fuf=fuf_after_login()).load()
    eq(s.login(), 1, "one timer after PLAYER_ENTERING_WORLD")
    eq(s.calls(), RAID, "only the raid command sent")
    eq(s.record(), {"version": 1, "raid": "switched-off"}, "record")
    eq(s.raid_enabled(), False, "raid profile reads false")
    eq(s.g.TEST_partyMemory, None, "party frames untouched")
    eq(lst(to_py(s.g.TEST_logs)), ["info DevilForever_FUFDefaults Hero-Realm: raid switched-off"], "Core status log")
    eq(s.status()["state"], "applied", "session state")
    eq(s.status()["record"]["raid"], "switched-off", "GetStatus record copy")


@case
def timer_delay_waits_past_fuf_save_hold():
    s = Session(fuf=fuf_after_login()).load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    eq(to_py(s.g.TEST_timers)[1][1] >= 20, True, "delay at least 20 s (FUF holds saves 15 s on a fresh install)")
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", False, True)
    eq(len(to_py(s.g.TEST_timers)), 1, "only the first PLAYER_ENTERING_WORLD schedules")


@case
def without_grid2_nothing_then_later_once():
    s = Session(fuf=fuf_after_login(), grid2=False).load()
    s.login()
    eq(s.calls(), [], "no command without Grid2")
    eq(s.record(), None, "nothing stored")
    eq(s.status()["state"], "grid2-not-loaded", "state")
    saved = to_py(s.g.DevilForever_FUFDefaultsDB)
    s2 = Session(fuf=fuf_after_login(), saved=saved, grid2=True).load()
    s2.login()
    eq(s2.calls(), RAID, "next login with Grid2 sends the raid command")


@case
def stored_raid_value_is_kept():
    s = Session(fuf=fuf_after_login(raid_general={"enabled": False})).load()
    s.login()
    eq(s.calls(), [], "no command when FUF stores the raid value")
    eq(s.record(), {"version": 1, "raid": "kept-user-value"}, "record")


@case
def shared_profile_alt_keeps_party_on():
    # Account-wide Default profile with nothing stored for party (FUF default on);
    # an alt with Grid2 gets its own raid switch and the shared party stays on.
    profiles = {"Default": {"general": {}, "party": {}}}
    saved = {"chars": {CHAR: {"version": 1, "raid": "switched-off"}}}
    fuf = fuf_after_login(profiles=profiles, char="Alt-Realm")
    s = Session(fuf=fuf, saved=saved).load()
    s.g.TEST_name = "Alt"
    s.login()
    eq(s.calls(), RAID, "alt: raid command only")
    eq(s.g.TEST_partyMemory, None, "no party command")
    eq(to_py(s.g.ForeverUnitFramesDB)["profiles"]["Default"]["party"], {}, "shared party profile unchanged")
    eq(to_py(s.g.DevilForever_FUFDefaultsDB)["chars"]["Alt-Realm"], {"version": 1, "raid": "switched-off"},
       "alt record")


@case
def other_values_do_not_count_as_user_choice():
    s = Session(fuf=fuf_after_login(raid_general={"sizeMode": "AUTO"})).load()
    s.login()
    eq(s.calls(), RAID, "only general.enabled decides")


@case
def runs_once_per_character():
    saved = {"chars": {CHAR: {"version": 1, "raid": "switched-off"}}}
    s = Session(fuf=fuf_after_login(), saved=saved).load()
    s.login()
    eq(s.calls(), [], "no command the second time")
    eq(s.status()["state"], "done-before", "state")
    other = Session(fuf=fuf_after_login(char="Alt-Realm"), saved=saved).load()
    other.g.TEST_name = "Alt"
    other.login()
    eq(other.calls(), RAID, "another character gets its own run")


@case
def combat_delays_to_regen_enabled():
    s = Session(fuf=fuf_after_login()).load()
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    s.g.TEST_combat = True
    s.g.TEST_runTimers()
    eq(s.calls(), [], "nothing in combat")
    eq(s.status()["state"], "waiting-combat", "state")
    s.g.TEST_combat = False
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(s.g.TEST_runTimers(), 1, "one timer after combat")
    eq(s.calls(), RAID, "sent after combat")
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(len(to_py(s.g.TEST_timers)), 0, "no second run")


@case
def command_missing_is_recorded():
    s = Session(fuf=fuf_after_login(), command=False).load()
    s.login()
    eq(s.record(), {"version": 1, "raid": "api-missing"}, "record")


@case
def raid_value_not_stored_is_not_applied():
    s = Session(fuf=fuf_after_login()).load()
    s.g.TEST_raidStores = False
    s.login()
    eq(s.record(), {"version": 1, "raid": "not-applied"}, "post-check after sending")


@case
def command_error_reported():
    s = Session(fuf=fuf_after_login()).load()
    s.g.TEST_raiseOn = "raid off"
    s.login()
    eq(s.record(), {"version": 1, "raid": "error"}, "record")
    errors = lst(to_py(s.g.TEST_errors))
    eq(len(errors) == 1 and "stand-in error on raid off" in errors[0], True, "error handler got it")


@case
def fuf_not_ready_and_player_unknown_store_nothing():
    s = Session(fuf=None).load()
    s.login()
    eq((s.calls(), s.record(), s.status()["state"]), ([], None, "fuf-not-ready"), "no FUF saved variable")
    s2 = Session(fuf=fuf_after_login()).load()
    s2.g.TEST_name = None
    s2.login()
    eq((s2.calls(), s2.status()["state"]), ([], "player-unknown"), "player name unknown")
    eq(to_py(s2.g.DevilForever_FUFDefaultsDB), None, "own saved variable not made")


@case
def realm_from_normalized_name_when_missing():
    s = Session(fuf=fuf_after_login(char="Hero-Realm")).load()
    s.g.TEST_realm = ""
    s.g.TEST_normalized = "Realm"
    s.login()
    eq(s.record(), {"version": 1, "raid": "switched-off"}, "key Hero-Realm from GetNormalizedRealmName")


@case
def without_core_table_client_api_used():
    s = Session(fuf=fuf_after_login(), core=False).load()
    s.login()
    eq(s.calls(), RAID, "Grid2 seen through C_AddOns")
    eq(lst(to_py(s.g.TEST_logs)), [], "no Core log")


@case
def wrong_type_saved_variable_replaced():
    s = Session(fuf=fuf_after_login(), saved="broken").load()
    s.login()
    eq(s.record()["raid"], "switched-off", "own saved variable recreated")


@case
def fuf_saved_variables_not_written_by_addon():
    fuf = fuf_after_login(profiles={"Default": {"party": {}}})
    s = Session(fuf=fuf, command=True).load()
    s.g.TEST_raidStores = False
    before = to_py(s.g.ForeverUnitFramesDB)
    s.login()
    eq(to_py(s.g.ForeverUnitFramesDB), before, "ForeverUnitFramesDB untouched apart from FUF's own command")


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

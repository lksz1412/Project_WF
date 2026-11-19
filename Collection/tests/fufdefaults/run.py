"""Logic tests for DevilForever_FUFDefaults (FUF raid frames off while Grid2 is loaded).

Usage:  python -I Collection/tests/fufdefaults/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs stubs for what the
addon calls (CreateFrame with event registration, C_Timer.After,
InCombatLockdown, UnitFullName, GetNormalizedRealmName, C_AddOns.IsAddOnLoaded,
geterrorhandler, a DevilForever_Core with Log and IsLoadedInClient) and a
stand-in for Forever Unit Frames' command handler SlashCmdList.FOREVERUNITFRAMES.
The raid stand-in copies only the effect of the command the addon sends, as read
in FUF Core/Commands.lua 69-78 and Raid/Profiles.lua 1-8: "raid off" stores
general.enabled = false in ForeverUnitFramesDB.raid[<char>] at once; "set party
enabled off" (never expected) is recorded and changes a stand-in for FUF's
in-memory profile. The comparison tests separately execute native FUF Registry,
Settings, Preset, Config, UnitProfiles, Storage and Commands in isolated Lua.
Frames, secure state and the game client are not emulated.
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
TEST_printed = {}
function print(...) TEST_printed[#TEST_printed + 1] = table.concat({...}, " ") end

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
        for filename in ("FUFDefaults.lua", "LayoutPresets.lua", "NativeLayout.lua"):
            path = os.path.join(ADDON_DIR, filename)
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


def layout_client(preset="uhd", comparison=True):
    name = "DF Compare " + preset if comparison else "Custom"
    s = Session(fuf=fuf_after_login(profiles={"Default": {"player": {"width": 77}},
                                            "Custom": {"general": {"language": "koKR"}, "player": {"width": 211}},
                                            **({name: {"player": {"width": 211}}} if comparison else {})},
                                   active={CHAR: name}, profile={"player": {"width": 77}}), grid2=False)
    s.lua.execute("""
      UIParent = {GetEffectiveScale = function() return 0.64 end, GetHeight = function() return 1200 end}
      PixelUtil = {GetPixelToUIUnitFactor = function() return TEST_factor end}
      TEST_factor = 768 / 2160
      C_AddOns.GetAddOnMetadata = function() return TEST_version end
      TEST_version = "0.65.2"
      GetPhysicalScreenSize = function() return TEST_width, TEST_height end
      TEST_width, TEST_height = 3862, 2160
    """)
    return s.load()


@case
def comparison_layout_gates_keep_existing_profiles_unchanged():
    for mode in ("waiting", "combat", "custom", "version", "missing-api", "pixel", "preset", "small-screen", "unknown-screen"):
        s = layout_client(comparison=mode != "custom")
        before = to_py(s.g.ForeverUnitFramesDB)
        if mode != "waiting":
            s.login()
        if mode == "combat":
            s.g.TEST_combat = True
        if mode == "version":
            s.g.TEST_version = "other"
        if mode == "missing-api":
            s.g.SlashCmdList.FOREVERUNITFRAMES = None
        if mode == "pixel":
            s.g.TEST_factor = float("nan")
            s.g.UIParent.GetHeight = None
        if mode == "small-screen":
            s.g.TEST_width, s.g.TEST_height = 1920, 1080
        if mode == "unknown-screen":
            s.g.GetPhysicalScreenSize = None
        ok, reason = s.g.DevilForever_FUFDefaults.ApplyLayout("unknown" if mode == "preset" else "uhd")
        eq(ok, False, mode + " refused")
        eq(s.calls(), [], mode + " native writes zero")
        eq(to_py(s.g.ForeverUnitFramesDB), before, mode + " original values kept")


@case
def comparison_layout_reports_partial_failure_and_never_claims_readback():
    for mode in ("error", "false", "active", "combat"):
        s = layout_client()
        s.login()
        s.lua.execute("""
          local original = SlashCmdList.FOREVERUNITFRAMES
          local calls = 0
          SlashCmdList.FOREVERUNITFRAMES = function(command)
            calls = calls + 1
            if calls == 3 then
              if TEST_mode == "error" then error("native failure") end
              if TEST_mode == "false" then return false end
              if TEST_mode == "active" then ForeverUnitFramesDB.active["Hero-Realm"] = "Custom" end
              if TEST_mode == "combat" then TEST_combat = true end
            end
            return original(command)
          end
        """)
        s.g.TEST_mode = mode
        ok, reason = s.g.DevilForever_FUFDefaults.ApplyLayout("uhd")
        eq((ok, reason), (False, "partial-failure"), mode + " partial failure")
        state = to_py(s.g.DevilForever_FUFDefaults.GetLayoutStatus())
        eq(state["verified"], False, "not a native readback success")
        eq(state["sent"], 2 if mode in ("error", "false") else 3, "stops at changed context")
        eq(to_py(s.g.ForeverUnitFramesDB.profiles.Custom)["player"]["width"], 211, "custom untouched")


@case
def native_layout_early_rejection_reports_only_current_zero_writes():
    s = layout_client()
    s.login()
    eq(s.g.DevilForever_FUFDefaults.ApplyLayout("uhd"), (True, "sent-unverified"), "initial send")
    eq(s.g.DevilForever_FUFDefaults.GetLayoutStatus().sent, 116, "initial count")
    for mode in ("combat", "screen"):
        s.g.TEST_combat = mode == "combat"
        s.g.TEST_width = 1920 if mode == "screen" else 3862
        s.g.TEST_calls = s.table([])
        s.g.SlashCmdList.DEVILFOREVERFUFLAYOUT("layout uhd")
        eq(s.calls(), [], mode + " current invocation writes zero")
        eq(s.g.DevilForever_FUFDefaults.GetLayoutStatus().sent, 0, mode + " current count zero")
        lines = lst(to_py(s.g.TEST_printed))
        eq(any("0 native commands" in line for line in lines[-2:]), True, mode + " printed count zero")


def native_layout_client(preset):
    s = layout_client(preset, comparison=False)
    s.lua.execute("""
      TEST_native = {AuraBlocklist = {LETTERS = 1000, Check = function() return true end},
        RaidProfiles = {CharKey = function() return "Hero-Realm" end},
        L = setmetatable({}, {__index = function(_, key) return key end}), api = {}}
      local ns = TEST_native
      ns.events, ns.listeners = {}, {}
      ns.On = function(event, fn) ns.events[event] = fn end
      ns.Listen = function(event, fn) ns.listeners[event] = fn end
      ns.Fire = function(event, ...) if ns.listeners[event] then ns.listeners[event](...) end end
      ns.AfterCombat = function(_, fn) fn() end
      ns.Print = function(message) TEST_errors[#TEST_errors + 1] = message end
      ns.PresetUpgrade = {Due = function() return false end, Active = function() return false end,
        Apply = function() end}
      TEST_macroReads, TEST_macroDeletes = 0, 0
      ns.MacroBackup = {Read = function() TEST_macroReads = TEST_macroReads + 1 end,
        Delete = function() TEST_macroDeletes = TEST_macroDeletes + 1; return 0 end}
      local function encode(value)
        if type(value) ~= "table" then return tostring(value) end
        local keys, result = {}, {}
        for key in pairs(value) do keys[#keys + 1] = key end
        table.sort(keys)
        for _, key in ipairs(keys) do result[#result + 1] = key .. ":" .. encode(value[key]) end
        return "{" .. table.concat(result, ",") .. "}"
      end
      ns.Codec = {VERSION = 1, Encode = encode, Decode = function() return {} end}
      LibForeverThemes = {HubSync = function() end}
    """)
    root = os.path.join(REPO, "Collection", "upstream", "Forever_Unit_Frames-0.65.2", "ForeverUnitFrames", "Core")
    for filename in ("Registry.lua", "Settings.lua", "Preset.lua", "Config.lua", "UnitProfiles.lua", "Storage.lua", "Commands.lua"):
        with open(os.path.join(root, filename), "rb") as fh:
            s.g.loadstring(fh.read())("ForeverUnitFrames", s.g.TEST_native)
    s.lua.execute("""
      local ns = TEST_native
      ns.Config.Use(ns.Storage.Load(ForeverUnitFramesDB))
      ns.Storage.Attach(ForeverUnitFramesDB)
      ns.Storage.Start()
      ns.Listen("CONFIG_CHANGED", function() ns.Storage.RequestSave() end)
    """)
    return s


@case
def native_commands_run_all_three_presets_and_preserve_custom_legacy_raid():
    checked = 0
    for preset, height in (("fhd", 1080), ("qhd", 1440), ("uhd", 2160)):
        for scale in (0.64, 0.8):
            s = native_layout_client(preset)
            s.g.TEST_factor = 768 / height
            s.g.TEST_width, s.g.TEST_height = {"fhd": 1920, "qhd": 2560, "uhd": 3862}[preset], height
            s.g.UIParent.GetEffectiveScale = s.lua.eval("function() return %s end" % scale)
            before = to_py(s.g.ForeverUnitFramesDB)
            s.login()
            ok, reason = s.g.DevilForever_FUFDefaults.ApplyLayout(preset)
            eq((ok, reason), (False, "comparison-profile-required"), "native Custom refused")
            name = "DF Compare " + preset
            eq(s.g.TEST_native.UnitProfiles.SaveAs(name), True, "native UI SaveAs equivalent")
            ok, reason = s.g.DevilForever_FUFDefaults.ApplyLayout(preset)
            eq((ok, reason), (True, "sent-unverified"), "commands sent without runtime readback claim")
            commands, required = s.g.DevilForever_FUFDefaults.GetLayoutCommands(preset)
            eq(required, name, "explicit comparison profile")
            for command in lst(to_py(commands)):
                _, scope, key, raw = command.split(" ")
                value = s.g.TEST_native.Config.Get(scope, key)
                expected = raw == "true" if raw in ("true", "false") else float(raw) if raw.lstrip("-").isdigit() else raw
                eq(value, expected, preset + " native " + scope + "." + key)
                checked += 1
            s.g.TEST_runTimers()
            after = to_py(s.g.ForeverUnitFramesDB)
            for key in ("profile", "raid", "themeSets", "themeColors"):
                eq(after.get(key), before.get(key), key + " unchanged")
            eq(after["profiles"]["Custom"], before["profiles"]["Custom"], "original Custom intact")
            eq(after["profiles"]["Default"], before["profiles"]["Default"], "legacy Default intact")
            eq(lst(to_py(s.g.TEST_errors)), [], "no native invalid setting")
            eq(s.g.TEST_native.UnitProfiles.Switch("Custom"), True, "native original profile return")
            eq(s.g.TEST_native.Config.Get("player", "width"), 211, "original native geometry restored by profile selection")
    print("Native FUF geometry: 3 presets x2 scales; %d native Config.Get values verified; original profiles preserved" % checked)


@case
def native_storage_wait_and_macro_source_survive_adapter_loading():
    s = native_layout_client("uhd")
    s.g.ForeverUnitFramesDB = s.table({})
    s.lua.execute("""
      local ns = TEST_native
      ns.Config.Use(ns.Storage.Load(ForeverUnitFramesDB))
      ns.Storage.Attach(ForeverUnitFramesDB)
      ns.Storage.Start()
    """)
    eq(s.g.TEST_macroReads, 1, "empty SV still checks native macro backup")
    eq(s.g.TEST_native.Storage.IsWaiting(), True, "native waiting retained")
    before = to_py(s.g.ForeverUnitFramesDB)
    ok, reason = s.g.DevilForever_FUFDefaults.ApplyLayout("uhd")
    eq((ok, reason), (False, "waiting"), "adapter does not interrupt initial wait")
    eq(to_py(s.g.ForeverUnitFramesDB), before, "no geometry SV preseed")


@case
def native_layout_reads_status_once_and_stops_on_same_name_profile_replacement():
    for replace in (False, True):
        s = native_layout_client("uhd")
        s.login()
        eq(s.g.TEST_native.UnitProfiles.SaveAs("DF Compare uhd"), True, "select native comparison clone")
        s.g.TEST_replaceProfile = replace
        s.lua.execute("""
          TEST_statusReads, TEST_layoutCalls = 0, 0
          local API = DevilForever_FUFDefaults
          local status = API.GetStatus
          API.GetStatus = function()
            TEST_statusReads = TEST_statusReads + 1
            return status()
          end
          local handler = SlashCmdList.FOREVERUNITFRAMES
          SlashCmdList.FOREVERUNITFRAMES = function(command)
            TEST_layoutCalls = TEST_layoutCalls + 1
            local result = handler(command)
            if TEST_replaceProfile and TEST_layoutCalls == 1 then
              ForeverUnitFramesDB.profiles["DF Compare uhd"] = {}
            end
            return result
          end
        """)
        result = s.g.DevilForever_FUFDefaults.ApplyLayout("uhd")
        eq(result, (False, "partial-failure") if replace else (True, "sent-unverified"), "native result")
        eq(s.g.TEST_statusReads, 1, "one diagnostic copy per invocation")
        eq(s.g.TEST_layoutCalls, 1 if replace else 116, "native commands before changed context")
        state = to_py(s.g.DevilForever_FUFDefaults.GetLayoutStatus())
        eq(state["sent"], 1 if replace else 116, "reported sends")
        eq(state["verified"], False, "no game readback claim")
        if replace:
            eq(state["reason"], "context-changed", "same name with a new object is refused")
        eq(to_py(s.g.ForeverUnitFramesDB.profiles.Custom)["player"]["width"], 211, "personal profile kept")
        eq(lst(to_py(s.g.TEST_errors)), [], "native commands accepted")


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

"""Logic tests for the pure-Lua parts of !DevilForever_Core.

Usage:  python3 -I Collection/tests/core/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs minimal stubs
(CreateFrame with event registration only, InCombatLockdown toggle, addon
loaded set, player name/realm/class, error handler that records errors), sets
saved-variable globals from Python data, runs the Core files in TOC order with
``(addonName, namespace)`` as the chunk arguments, and fires the client events a
case needs. Saved variables are read back into Python to carry them to the
next simulated session. This checks Core logic only; it does not emulate the
game client, its frames or its load order.
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
CORE_DIR = os.path.join(REPO, "Collection", "AddOns", "!DevilForever_Core")
FIXTURES = os.path.join(HERE, "fixtures")
ADDON = "!DevilForever_Core"

STUBS = r"""
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
TEST_combat = false
function InCombatLockdown() return TEST_combat end
TEST_loaded = {}
C_AddOns = {IsAddOnLoaded = function(name) return TEST_loaded[name] == true end}
TEST_errors = {}
function geterrorhandler() return function(e) TEST_errors[#TEST_errors + 1] = tostring(e) end end
TEST_player = {name = "Hero", realm = "Realm", className = "Warrior", class = "WARRIOR"}
function UnitNameUnmodified() return TEST_player.name, TEST_player.surname end
-- Addon stubs that fill their own defaults at their ADDON_LOADED, the way
-- Platynator's ImportDefaultsToProfile does (only keys that are nil).
TEST_selfFill = {}
function TEST_runSelfFill(name)
  local spec = TEST_selfFill[name]
  if not spec then return end
  local sv = _G[spec.sv] or {}
  _G[spec.sv] = sv
  for k, v in pairs(spec.values) do
    if sv[k] == nil then sv[k] = v end
  end
end
function GetRealmName() return TEST_player.realm end
function UnitClass() return TEST_player.className, TEST_player.class end
-- Save/restore stubs: clock, reload, chat output, addon metadata, LibStub
-- libraries (AceDB-3.0 db_registry, LibDualSpec-1.0) and slash commands.
TEST_time = 1000
function time() return TEST_time end
TEST_reloads = 0
function ReloadUI() TEST_reloads = TEST_reloads + 1 end
TEST_prints = {}
function print(...)
  local parts = {}
  for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
  TEST_prints[#TEST_prints + 1] = table.concat(parts, " ")
end
TEST_meta = {}
C_AddOns.GetAddOnMetadata = function(name, field) local m = TEST_meta[name] return m and m[field] end
TEST_libs = {}
LibStub = setmetatable({}, {__call = function(_, name) return TEST_libs[name] end})
SlashCmdList = {}
"""


def toc_files():
    files = []
    with open(os.path.join(CORE_DIR, ADDON + ".toc"), encoding="utf-8") as fh:
        for raw in fh:
            line = raw.strip()
            if line and not line.startswith("#"):
                files.append(line.replace("\\", "/"))
    return files


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


FIXTURE_REGISTRIES = {"fixture": "Registry_Test.lua", "profiles": "Registry_Profiles.lua"}


class Session:
    """One simulated client session with Core loaded."""

    def __init__(self, saved=None, registry="fixture", extra_files=("Defaults_Example.lua",),
                 player=None, globals_=None, preset_files=(), collection_presets=False, prelude=None):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        if prelude:  # Lua run before Core's files (client objects the preset files read at load)
            self.lua.execute(prelude)
        g = self.lua.globals()
        if player:
            for k, v in player.items():
                g.TEST_player[k] = v
        for name, value in (globals_ or {}).items():
            g[name] = self.table(value) if isinstance(value, (dict, list, tuple)) else value
        for name, value in (saved or {}).items():
            g[name] = self.table(value)
        self.ns = self.lua.table()
        for rel in toc_files():
            # Real defaults files name folders of the generated registry only.
            if rel.startswith("Defaults/") and registry in FIXTURE_REGISTRIES:
                continue
            if rel.startswith("Presets/") and not collection_presets:
                continue
            if rel == "Registry.lua" and registry in FIXTURE_REGISTRIES:
                self.run_file(os.path.join(FIXTURES, FIXTURE_REGISTRIES[registry]))
            else:
                self.run_file(os.path.join(CORE_DIR, rel))
            if rel == "Defaults.lua":
                for extra in extra_files:
                    self.run_file(os.path.join(FIXTURES, extra))
            if rel == "Presets.lua":
                for extra in preset_files:
                    self.run_file(os.path.join(FIXTURES, extra))
        self.core = g.DevilForever_Core

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

    def run_file(self, path):
        with open(path, "rb") as fh:
            src = fh.read()
        loadstring = self.lua.globals().loadstring
        try:
            source_label = os.path.relpath(path, REPO)
        except ValueError:
            source_label = os.path.abspath(path)
        result = loadstring(src, ("@" + source_label).encode())
        fn, err = result if isinstance(result, tuple) else (result, None)
        if fn is None:
            raise AssertionError("compile failed: %s" % err)
        fn(ADDON, self.ns)

    @property
    def g(self):
        return self.lua.globals()

    def fire(self, event, *args):
        self.g.TEST_fire(event, *args)

    def load_addon(self, name):
        """Core's handler runs first (Core loaded first); a self-filling stub after it."""
        self.g.TEST_loaded[name] = True
        self.fire("ADDON_LOADED", name)
        self.g.TEST_runSelfFill(name)

    def self_fill(self, name, sv, values):
        self.g.TEST_selfFill[name] = self.table({"sv": sv, "values": values})

    def combat(self, on):
        self.g.TEST_combat = on
        self.fire("PLAYER_REGEN_DISABLED" if on else "PLAYER_REGEN_ENABLED")

    def boot(self, before=(), after=(), login=True):
        """Load `before` addons, then Core, then `after`, then login events."""
        for name in before:
            self.load_addon(name)
        self.load_addon(ADDON)
        for name in after:
            self.load_addon(name)
        if login:
            self.fire("PLAYER_LOGIN")
            self.fire("PLAYER_ENTERING_WORLD", True, False)
        return self

    def sv(self, name):
        return to_py(self.g[name])

    def errors(self):
        return list(to_py(self.g.TEST_errors).values())

    def status(self, folder):
        return to_py(self.core.Defaults.GetStatus(self.core.Defaults, folder))

    def log(self):
        return list(to_py(self.core.GetStatusLog(self.core)).values())


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


# Defaults ---------------------------------------------------------------------

@case
def defaults_fill_only_missing():
    s = Session(saved={"TestPlainDB": {"alpha": 99, "nested": {"gamma": 30}}}).boot(after=["TestPlain"])
    db = s.sv("TestPlainDB")
    eq(db["alpha"], 99, "user value kept")
    eq(db["beta"], 2, "missing key filled")
    eq(db["nested"], {"gamma": 30, "delta": {"epsilon": 4}}, "nested fill keeps user value")
    st = s.status("TestPlain")["targets"]["TestPlainDB"]
    eq(st["state"], "applied", "status")
    eq(s.sv("DevilForever_CoreDB")["defaults"]["applied"]["TestPlain"], {"TestPlainDB": 1}, "version recorded")
    eq(s.errors(), [], "no errors")


@case
def defaults_once_only():
    first = Session(saved={"TestPlainDB": {}}).boot(after=["TestPlain"])
    db = first.sv("TestPlainDB")
    del db["beta"]  # the user removes a value after the first fill
    core_db = first.sv("DevilForever_CoreDB")
    second = Session(saved={"TestPlainDB": db, "DevilForever_CoreDB": core_db}).boot(after=["TestPlain"])
    eq("beta" in second.sv("TestPlainDB"), False, "not filled again at the same version")
    eq(second.status("TestPlain")["targets"]["TestPlainDB"]["state"], "already", "status already")


@case
def defaults_version_bump_fills_missing_only():
    first = Session(saved={"TestPlainDB": {}}).boot(after=["TestPlain"])
    db = first.sv("TestPlainDB")
    db["alpha"] = 7
    del db["beta"]
    second = Session(saved={"TestPlainDB": db, "DevilForever_CoreDB": first.sv("DevilForever_CoreDB")},
                     globals_={"TEST_DEFAULTS_VERSION": 2}).boot(after=["TestPlain"])
    out = second.sv("TestPlainDB")
    eq(out["alpha"], 7, "user value kept on bump")
    eq(out["beta"], 2, "missing key filled on bump")
    eq(second.sv("DevilForever_CoreDB")["defaults"]["applied"]["TestPlain"]["TestPlainDB"], 2, "new version")


@case
def defaults_shape_conflict_logged():
    s = Session(saved={"TestPlainDB": {"shape": 5}}).boot(after=["TestPlain"])
    eq(s.sv("TestPlainDB")["shape"], 5, "non-table value kept")
    st = s.status("TestPlain")["targets"]["TestPlainDB"]
    eq(list(st["conflicts"].values()), ["shape"], "conflict path")
    eq(any(e["kind"] == "conflict" for e in s.log()), True, "conflict in status log")


@case
def defaults_sv_not_table_skipped():
    s = Session(saved={"TestPlainDB": "encoded-string"}).boot(after=["TestPlain"])
    eq(s.sv("TestPlainDB"), "encoded-string", "value untouched")
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "skipped", "skipped")
    eq("TestPlain" in s.sv("DevilForever_CoreDB")["defaults"]["applied"], False, "nothing recorded")


@case
def defaults_plain_absent_waits_then_skips():
    s = Session().boot(after=["TestPlain"], login=False)
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "waiting", "waits before login")
    s.fire("PLAYER_LOGIN")
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "waiting", "still waiting at login")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "late-created", "late-created after world")
    eq(s.sv("TestPlainDB"), None, "saved variable not created")


@case
def defaults_plain_created_by_addon_at_login():
    s = Session().boot(after=["TestPlain"], login=False)
    s.g.TestPlainDB = s.table({"alpha": 50})  # first load: the addon creates its table at PLAYER_LOGIN
    s.fire("PLAYER_LOGIN")
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "waiting", "first load waits for world")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.sv("TestPlainDB")["alpha"], 1, "addon-created value of this session replaced")
    eq(s.sv("TestPlainDB")["beta"], 2, "spec key written")
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["mode"], "first-load", "mode")


@case
def defaults_self_filling_addon_fresh():
    s = Session()
    s.self_fill("TestPlain", "TestPlainDB", {"alpha": 100, "beta": 200, "own": 1})
    s.boot(after=["TestPlain"])
    db = s.sv("TestPlainDB")
    eq((db["alpha"], db["beta"], db["own"]), (1, 2, 1), "spec over addon defaults, addon-only key kept")
    eq(db["nested"]["delta"]["epsilon"], 4, "nested spec written")
    st = s.status("TestPlain")["targets"]["TestPlainDB"]
    eq((st["state"], st["mode"]), ("applied", "first-load"), "status")
    db["alpha"] = 55  # the user changes a value after the first load
    nxt = Session(saved={"TestPlainDB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")})
    nxt.self_fill("TestPlain", "TestPlainDB", {"alpha": 100, "beta": 200, "own": 1})
    nxt.boot(after=["TestPlain"])
    eq(nxt.sv("TestPlainDB")["alpha"], 55, "never overwritten in a later session")
    eq(nxt.status("TestPlain")["targets"]["TestPlainDB"]["state"], "already", "already applied")


@case
def defaults_self_filling_addon_existing():
    s = Session(saved={"TestPlainDB": {"alpha": 99}})
    s.self_fill("TestPlain", "TestPlainDB", {"alpha": 100, "beta": 200, "own": 1})
    s.boot(after=["TestPlain"])
    db = s.sv("TestPlainDB")
    eq((db["alpha"], db["beta"], db["own"]), (99, 2, 1), "existing SV: missing keys only, before the addon fills")
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["mode"], "fill-missing", "mode")


@case
def defaults_fresh_still_nil_not_recorded():
    s = Session().boot(after=["TestPlain"])
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "late-created", "late-created")
    eq("TestPlain" in s.sv("DevilForever_CoreDB")["defaults"]["applied"], False, "nothing recorded")


@case
def defaults_addon_loaded_before_core():
    s = Session(saved={"TestPlainDB": {}}).boot(before=["TestPlain"])
    eq(s.sv("TestPlainDB")["beta"], 2, "filled for an addon loaded before Core")


@case
def defaults_character_scope_per_character():
    first = Session().boot(after=["TestChar"])
    eq(first.sv("TestCharDB"), {"enabled": True}, "created and filled")
    core_db = first.sv("DevilForever_CoreDB")
    eq(core_db["defaults"]["applied"]["TestChar"], {"TestCharDB@char:Hero - Realm": 1}, "per-character key")
    alt = Session(saved={"DevilForever_CoreDB": core_db}, player={"name": "Alt"}).boot(after=["TestChar"])
    eq(alt.sv("TestCharDB"), {"enabled": True}, "second character filled too")


# AceDB-3.0 removes every value equal to the addon's defaults at logout and
# drops tables left empty (AceDB-3.0.lua removeDefaults 165-178, logout handler
# 352-356), so saved data below is seeded the way AceDB leaves it: a key the
# user set back to the default is simply absent.

@case
def defaults_acedb_existing_profile_kept():
    saved = {"TestAceDB": {"profileKeys": {"Hero - Realm": "Main"},
                           "profiles": {"Main": {"scale": 2}, "Other": {"x": 1}}}}
    s = Session(saved=saved).boot(after=["TestAce"])
    db = s.sv("TestAceDB")
    eq(db, saved["TestAceDB"], "existing profile and its absent namespace left as they are")
    st = s.status("TestAce")["targets"]
    eq({k: (v["state"], v["key"]) for k, v in st.items()},
       {"TestAceDB": ("existing-profile-kept", "TestAceDB@profile:Main"),
        "TestAceDB/Module": ("existing-profile-kept", "TestAceDB/Module@profile:Main")}, "status")
    defaults = s.sv("DevilForever_CoreDB")["defaults"]
    eq("TestAce" in (defaults.get("applied") or {}), False, "nothing recorded as applied")
    eq(sorted(defaults["kept"]["TestAce"]), ["TestAceDB/Module@profile:Main", "TestAceDB@profile:Main"], "kept marker")
    again = Session(saved={"TestAceDB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")}).boot(after=["TestAce"])
    eq(again.status("TestAce")["targets"]["TestAceDB"]["state"], "existing-profile-kept", "next session: still kept")
    eq(again.sv("TestAceDB"), saved["TestAceDB"], "still untouched")


@case
def defaults_acedb_stripped_profile_kept_by_profile_key():
    # The user's profile held only default-equal values, so AceDB dropped it; profileKeys stays.
    saved = {"TestAceDB": {"profileKeys": {"Hero - Realm": "Warrior"}}}
    s = Session(saved=saved).boot(after=["TestAce"])
    eq(s.sv("TestAceDB"), saved["TestAceDB"], "nothing created")
    eq(s.status("TestAce")["targets"]["TestAceDB"]["state"], "existing-profile-kept", "kept")


@case
def defaults_acedb_new_character_on_existing_sv_written():
    saved = {"TestAceDB": {"profileKeys": {"Sage - Realm": "Mage"}, "profiles": {"Mage": {"scale": 3}}}}
    s = Session(saved=saved).boot(after=["TestAce"])
    db = s.sv("TestAceDB")
    eq(db["profiles"], {"Mage": {"scale": 3}, "Warrior": {"scale": 1, "bars": {"count": 8}}}, "new class profile written")
    eq(db["namespaces"]["Module"]["profiles"], {"Warrior": {"on": False}}, "its namespace profile written")
    eq({v["state"] for v in s.status("TestAce")["targets"].values()}, {"applied"}, "both applied")


@case
def defaults_acedb_namespace_under_existing_profile_kept():
    # Another Warrior uses the shared class profile; its Module values were all default-equal.
    saved = {"TestAceDB": {"profileKeys": {"Other - Realm": "Warrior"}, "profiles": {"Warrior": {"scale": 2}}}}
    s = Session(saved=saved).boot(after=["TestAce"])
    eq(s.sv("TestAceDB"), saved["TestAceDB"], "shared profile and its namespace untouched")
    eq({v["state"] for v in s.status("TestAce")["targets"].values()}, {"existing-profile-kept"}, "both kept")


@case
def defaults_acedb_version_bump_existing_kept():
    s = Session().boot(after=["TestAce"])
    first = s.sv("TestAceDB")
    bumped = Session(saved={"TestAceDB": first, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")},
                     globals_={"TEST_DEFAULTS_VERSION": 2}).boot(after=["TestAce"])
    eq(bumped.sv("TestAceDB"), first, "higher version does not reach a profile written before")
    eq(bumped.status("TestAce")["targets"]["TestAceDB"]["state"], "existing-profile-kept", "kept")


@case
def defaults_acedb_new_character_uses_profile_rule():
    s = Session().boot(after=["TestAce"])
    db = s.sv("TestAceDB")
    eq(db["profiles"], {"Warrior": {"scale": 1, "bars": {"count": 8}}}, "profile named by $className")
    eq(db["namespaces"]["Module"]["profiles"], {"Warrior": {"on": False}},
       "namespace written although the main target created the SV first in the same pass")
    eq("profileKeys" in db, False, "profileKeys left to AceDB")


@case
def defaults_invalid_spec_rejected():
    s = Session().boot()
    ok, reason = s.core.Defaults.Register(s.core.Defaults, "X", s.table({"version": 0, "targets": []}))
    eq(ok, False, "rejected")
    eq(bool(reason), True, "reason given")


@case
def core_without_other_addons():
    s = Session(registry="generated").boot()
    eq(s.errors(), [], "no errors")
    for folder in ("TestPlain", "TestChar", "TestAce"):
        st = s.status(folder)
        eq(st["loaded"], False, folder + " not loaded")
        eq(st["targets"], {}, folder + " nothing attempted")
    eq(s.sv("TestPlainDB"), None, "nothing created")
    eq(s.sv("TestAceDB"), None, "nothing created for AceDB either")
    eq(set(s.sv("DevilForever_CoreDB")), {"schema", "defaults", "theme", "edits", "preset"}, "Core DB layout")


# Registry ---------------------------------------------------------------------

@case
def generated_registry_lookup():
    s = Session(registry="generated", extra_files=()).boot()
    c = s.core
    info = to_py(c.GetAddonInfo(c, "dominos"))
    eq(info["package"], "Dominos", "case-insensitive lookup")
    eq(list(info["savedVariables"].values()), [{"name": "DominosDB", "scope": "account", "split": "class", "restore": "profile", "shape": "acedb"}], "SV")
    eq(info["defaults"], "Defaults/Dominos.lua", "defaults file named")
    eq(c.GetAddonInfo(c, "Prat-3.0"), None, "native chat collection excludes Prat")
    eq(to_py(c.GetAddonInfo(c, "!DevilForever_Core"))["bundle"], "required", "Core is required")
    eq(list(to_py(c.ListAddons(c)).values())[0], "!DevilForever_Core", "Core sorts first")
    eq(c.GetAddonInfo(c, "NoSuchAddon"), None, "unknown folder")
    eq(list(to_py(c.GetFrameNames(c)).values()),
       sorted(list(to_py(c.GetFrameNames(c, "Dominos")).values())
              + list(to_py(c.GetFrameNames(c, "SexyMap")).values())
              + list(to_py(c.GetFrameNames(c, "ForeverUnitFrames")).values())
              + list(to_py(c.GetFrameNames(c, "Quartz")).values())
              + list(to_py(c.GetFrameNames(c, "PitBull4")).values())
              + list(to_py(c.GetFrameNames(c, "Grid2")).values())
              + list(to_py(c.GetFrameNames(c, "Details")).values())
              + list(to_py(c.GetFrameNames(c, "DevilForever_StatusStrip")).values())
              + list(to_py(c.GetFrameNames(c, "ExperienceForever")).values())
              + list(to_py(c.GetFrameNames(c, "DevilForever_Appearance")).values())),
       "registered appearance frames")
    eq(len(to_py(c.GetFrameNames(c, "DevilForever_Appearance"))), 17, "common exterior frames")
    xpbar = to_py(c.GetAddonInfo(c, "experienceforever"))
    eq(list(to_py(c.GetFrameNames(c, "ExperienceForever")).values()),
       ["ExperienceForeverFrame", "ExperienceForeverMinimapButton"], "Experience Forever frames: the bar, the minimap button")
    eq(sorted((e["frame"], e["field"], e.get("min"), e.get("max")) for e in xpbar["editable"].values()),
       [("experienceforever.bar", "position", None, None)],
       "Experience Forever editable item: bar position only (EF re-applies its own sizes and fonts)")
    eq((xpbar["bundle"], xpbar["use"], xpbar.get("defaults"), list(xpbar["savedVariables"].values())),
       ("individual", "settings", None, [{"name": "ExperienceForeverDB", "scope": "account", "split": "common",
                                         "restore": "whole", "shape": "acedb"}]),
       "Experience Forever: no Core defaults file (its own defaults already match), account AceDB SV")
    strip = to_py(c.GetAddonInfo(c, "DevilForever_StatusStrip"))
    eq(list(to_py(c.GetFrameKeys(c, "DevilForever_StatusStrip")).values()),
       ["statusstrip.bags", "statusstrip.bar", "statusstrip.clock", "statusstrip.durability", "statusstrip.fps",
        "statusstrip.gold", "statusstrip.latency"], "status strip frame keys: the bar and its six texts")
    eq(sorted((e["field"], e.get("min"), e.get("max")) for e in strip["editable"].values()),
       [("color", None, None), ("font", 6, 64), ("position", None, None), ("size", 8, 8192), ("spacing", 0, 128)],
       "status strip editable items sit on the bar only")
    eq((strip["bundle"], strip["use"], strip.get("defaults"), list(strip["savedVariables"].values())),
       ("individual", "new", None, [{"name": "DevilForever_StatusStripDB", "scope": "account", "split": "common",
                                    "restore": "whole", "shape": "plain"}]),
       "status strip: own individual addon, no Core defaults file, account SV")
    details = to_py(c.GetAddonInfo(c, "details"))
    eq(list(to_py(c.GetFrameNames(c, "Details")).values()), ["DetailsBaseFrame1", "DetailsBaseFrame2"],
       "Details frames: damage window 1, threat window 2")
    eq(sorted((sv["name"], sv["scope"], sv["split"]) for sv in details["savedVariables"].values()),
       [("__details_backup", "account", "common"), ("__details_debug", "account", "common"),
        ("_detalhes_database", "character", "common"), ("_detalhes_global", "account", "common")], "Details SV")
    eq((details.get("defaults"), len(details["editable"])), (None, 4),
       "Details has no Core defaults file (its saved variables are rewritten by Details at logout); 2 positions, 2 sizes")
    eq(list(to_py(c.GetFrameNames(c, "Details_TinyThreat")).values()), [], "Tiny Threat draws inside window 2")
    layout = to_py(c.GetAddonInfo(c, "DevilForever_DetailsLayout"))
    eq((layout["bundle"], layout["use"], layout.get("savedVariables") or {}),
       ("individual", "new", {}), "Details layout is an explicit companion with no saved variables")
    grid2 = to_py(c.GetAddonInfo(c, "grid2"))
    eq(list(to_py(c.GetFrameNames(c, "Grid2")).values()), ["Grid2LayoutFrame"], "Grid2 frames: the layout window")
    eq(list(grid2["savedVariables"].values()), [{"name": "Grid2DB", "scope": "account", "split": "common",
                                                 "restore": "whole", "shape": "acedb"}],
       "Grid2 SV")
    eq((grid2["defaults"], len(grid2["editable"])), ("Defaults/Grid2.lua", 3),
       "Grid2 defaults file named; editable position, unit button size, padding")
    pb4 = to_py(c.GetAddonInfo(c, "pitbull4"))
    eq(len(to_py(c.GetFrameNames(c, "PitBull4"))), 10, "PitBull4: 7 unit frames, 3 party group headers")
    eq(list(pb4["savedVariables"].values()), [{"name": "PitBull4DB", "scope": "account", "split": "common",
                                               "restore": "whole", "shape": "acedb"}],
       "PitBull4 SV")
    eq((pb4["defaults"], len(pb4["editable"]), pb4["version"]), ("Defaults/PitBull4.lua", 6, "v4.2.50-forever.1"),
       "PitBull4 defaults file, 6 positions, version of our copy")
    eq(sorted(pb4["tocs"].values()), ["PitBull4.toc", "PitBull4_Camelot.toc"], "PitBull4 16001 TOCs")
    eq((pb4["package"], pb4["use"], list(pb4["phases"].values()), pb4["variant"], pb4["bundle"]),
       ("PitBull4", "modify", [6], "6-rev", "individual"), "PitBull4: our fork of the PitBull4 package, Phase 6-rev")
    castbars_info = to_py(c.GetAddonInfo(c, "DevilForever_Castbars"))
    eq(castbars_info["package"], "DevilForever", "our own folders keep package DevilForever")
    eq(list(castbars_info["phases"].values()), [7], "own folder phases come from the manifest collection section")
    eq(list(to_py(c.GetAddonInfo(c, "!DevilForever_Core"))["phases"].values()), [2, 20, 22], "Core phases")
    registered = list(to_py(c.ListAddons(c)).values())
    for gone in ("ForeverThreat", "TipTac", "Bagnon", "BagBrother", "Platynator", "Titan", "TitanClock",
                 "!KalielsTracker", "Mapster", "Details_Streamer", "Details_Compare2", "Dominos_Cast",
                 "Dominos_Progress", "Dominos_Roll", "Hekili", "Hekili_Shared", "Hekili_Shaman"):
        eq(gone in registered, False, "%s is not registered (dropped Phase or not shipped)" % gone)
    eq("Aurora" in registered, True, "Aurora stays registered while Codex decides (named in registry_extra)")
    with open(os.path.join(REPO, "Collection", "install.json"), encoding="utf-8") as stream:
        install = json.load(stream)
    shipped = set(install["own"])
    for part in (install, *install["unit_frame_variants"].values()):
        shipped.update(part["own"])
        for folders in part["upstream"].values():
            shipped.update(folders)
    eq(set(registered), shipped | {"Aurora"}, "registry covers all install variants and the Aurora comparison")
    quartz = to_py(c.GetAddonInfo(c, "quartz"))
    eq(list(to_py(c.GetFrameNames(c, "Quartz")).values()),
       ["Quartz3CastBarFocus", "Quartz3CastBarPet", "Quartz3CastBarPlayer", "Quartz3CastBarTarget",
        "Quartz3GCDBar", "Quartz3SwingBar"], "Quartz frames")
    eq(list(quartz["savedVariables"].values()), [{"name": "Quartz3DB", "scope": "account", "split": "common",
                                                  "restore": "whole", "shape": "acedb"}],
       "Quartz SV")
    eq(quartz.get("defaults"), "Defaults/Quartz.lua", "Quartz defaults are part of the fresh profile policy")
    eq(len(quartz["editable"]), 8, "Quartz editable: position and size of 4 cast bars")
    castbars = to_py(c.GetAddonInfo(c, "DevilForever_Castbars"))
    eq((castbars["use"], castbars.get("savedVariables") or {}), ("new", {}), "Castbars bridge: own addon, no SV")
    fuf = to_py(c.GetAddonInfo(c, "foreverunitframes"))
    eq(len(to_py(c.GetFrameNames(c, "ForeverUnitFrames"))), 15, "FUF: 8 single frames, party header, boss1-5, raid")
    eq(list(fuf["savedVariables"].values()), [{"name": "ForeverUnitFramesDB", "scope": "account", "split": "common",
                                               "restore": "whole", "shape": "plain"}],
       "FUF SV")
    eq(fuf.get("defaults"), None, "FUF has no Core defaults file (its profile is rewritten by FUF on save)")
    eq(len(fuf["editable"]), 12, "FUF editable: 7 positions, 5 sizes")
    fufdef = to_py(c.GetAddonInfo(c, "DevilForever_FUFDefaults"))
    eq(list(fufdef["savedVariables"].values()),
       [{"name": "DevilForever_FUFDefaultsDB", "scope": "account", "split": "common"}], "FUFDefaults SV")
    sexy = to_py(c.GetAddonInfo(c, "SexyMap"))
    eq(list(to_py(c.GetFrameNames(c, "SexyMap")).values()),
       ["Minimap", "SexyMapCoordFrame", "SexyMapZoneTextButton", "TimeManagerClockButton"], "SexyMap frames")
    eq(list(sexy["savedVariables"].values()), [{"name": "SexyMap2DB", "scope": "account", "split": "common",
                                                "restore": "whole", "shape": "plain"}], "SexyMap SV")
    eq(sexy["defaults"], "Defaults/SexyMap.lua", "SexyMap defaults file named")
    setup = to_py(c.GetAddonInfo(c, "DevilForever_ChatSetup"))
    eq(list(setup["savedVariables"].values()),
       [{"name": "DevilForever_ChatSetupDB", "scope": "character", "split": "common"}], "ChatSetup SV")
    names = list(to_py(c.ListAddons(c)).values())
    eq(names, sorted(names, key=str.lower), "sorted list")
    eq("Bartender4" in names, False, "comparison packages excluded")


@case
def registry_frame_lists():
    s = Session().boot()
    c = s.core
    eq(list(to_py(c.GetFrameNames(c)).values()), ["ChatFrame1", "TestBarFrame"], "frame names")
    eq(list(to_py(c.GetFrameKeys(c, "testframes")).values()), ["test.bar", "test.chat"], "frame keys")
    svs = [(x["folder"], x["name"], x["scope"]) for x in to_py(c.GetSavedVariables(c)).values()]
    eq(svs, [("TestAce", "TestAceDB", "account"), ("TestAceChar", "TestAceCharDB", "character"),
             ("TestAceChar", "TestAceCharOtherDB", "account"), ("TestChar", "TestCharDB", "character"),
             ("TestPlain", "TestPlainDB", "account")], "saved variables")


# Theme ------------------------------------------------------------------------

def devil_values(s):
    return s.table({"color.text.normal": [1, 1, 1, 1], "color.accent": [0.8, 0.1, 0.1, 1],
                    "font.normal": "Fonts\\FRIZQT__.TTF", "font.size.normal": 14, "spacing.default": 4})


@case
def theme_tokens_and_set_switch_callback():
    s = Session().boot()
    t = s.core.Theme
    eq(t.Get(t, "color.accent"), None, "placeholder set has names only")
    eq(len(to_py(t.ListTokens(t))) > 0, True, "token names listed")
    eq(t.RegisterSet(t, "devil", devil_values(s)), 5, "values supplied for the base set")
    kept = t.RegisterSet(t, "alt", s.table({"color.accent": [0, 0, 1, 1], "not.a.token": 1, "font.normal": 3}))
    eq(kept, 1, "unknown token and wrong kind dropped")
    calls = []
    s.g.TEST_cb = lambda new, old: calls.append((new, old))
    s.lua.execute("DevilForever_Core.Theme:RegisterCallback('test', function(n, o) TEST_cb(n, o) end)")
    ok, how = t.SetActiveSet(t, "alt")
    eq((ok, how), (True, "applied"), "switch result")
    eq(calls, [("alt", "devil")], "callback with new and old name")
    eq(to_py(t.Get(t, "color.accent")), {1: 0, 2: 0, 3: 1, 4: 1}, "token from active set")
    eq(t.Get(t, "font.size.normal"), 14, "fallback to base set")
    eq(t.SetActiveSet(t, "missing"), (False, "unknown set"), "unknown set refused")
    eq(s.sv("DevilForever_CoreDB")["theme"]["active"], "alt", "active set saved")


@case
def theme_switch_waits_for_combat_end():
    s = Session().boot()
    t = s.core.Theme
    t.RegisterSet(t, "alt", s.table({"color.accent": [0, 0, 1, 1]}))
    calls = []
    s.g.TEST_cb = lambda new, old: calls.append((new, old))
    s.lua.execute("DevilForever_Core.Theme:RegisterCallback('test', function(n, o) TEST_cb(n, o) end)")
    s.combat(True)
    eq(t.SetActiveSet(t, "alt"), (True, "queued"), "queued in combat")
    eq(t.GetSet(t), ("devil", "alt"), "still devil, alt pending")
    eq(calls, [], "no callback in combat")
    s.combat(False)
    eq(calls, [("alt", "devil")], "callback after combat")
    eq(t.GetSet(t), ("alt", None), "switched")


@case
def theme_saved_set_restored_at_login():
    first = Session().boot()
    t = first.core.Theme
    t.RegisterSet(t, "alt", first.table({"color.accent": [0, 0, 1, 1]}))
    t.SetActiveSet(t, "alt")
    second = Session(saved={"DevilForever_CoreDB": first.sv("DevilForever_CoreDB")}).boot(login=False)
    t2 = second.core.Theme
    t2.RegisterSet(t2, "alt", second.table({"color.accent": [0, 0, 1, 1]}))
    second.fire("PLAYER_LOGIN")
    eq(t2.GetSet(t2)[0], "alt", "saved set restored")


# Edit -------------------------------------------------------------------------

@case
def edit_overlay_over_tokens():
    s = Session().boot()
    t, e = s.core.Theme, s.core.Edit
    t.RegisterSet(t, "devil", devil_values(s))
    base = to_py(e.Get(e, "test.chat"))
    eq(base["color"], {1: 0.8, 2: 0.1, 3: 0.1, 4: 1}, "registry token map (color.accent)")
    eq(base["font"], {"path": "Fonts\\FRIZQT__.TTF", "size": 14}, "font from tokens")
    eq(base["rows"], 5, "registry default")
    eq(base["spacing"], 4, "spacing token")
    eq("position" in base, False, "no position without edit")
    eq(e.Set(e, "test.chat", "font", s.table({"size": 18})), (True, "applied"), "font edit")
    eq(e.Set(e, "test.chat", "rows", 7), (True, "applied"), "rows edit")
    eq(e.Set(e, "test.chat", "position", s.table({"point": "BOTTOMLEFT", "x": 10, "y": 20})), (True, "applied"),
       "position edit")
    out = to_py(e.Get(e, "test.chat"))
    eq(out["font"], {"path": "Fonts\\FRIZQT__.TTF", "size": 18}, "font merged per key")
    eq(out["rows"], 7, "edit over registry default")
    eq(out["position"], {"point": "BOTTOMLEFT", "x": 10, "y": 20}, "position")
    other = to_py(e.Get(e, "test.bar"))
    eq(other["color"], {1: 1, 2: 1, 3: 1, 4: 1}, "field default token color.text.normal")
    t.RegisterSet(t, "alt", s.table({"color.accent": [0, 0, 1, 1]}))
    t.SetActiveSet(t, "alt")
    eq(to_py(e.Get(e, "test.chat"))["color"], {1: 0, 2: 0, 3: 1, 4: 1}, "token switch reaches unedited field")
    eq(e.Clear(e, "test.chat", "rows"), (True, "applied"), "clear one field")
    eq(to_py(e.Get(e, "test.chat"))["rows"], 5, "back to registry default")
    eq(e.Clear(e, "test.chat"), (True, "applied"), "clear all")
    eq(to_py(e.GetEdits(e, "test.chat")), {}, "no edits stored")
    eq("test.chat" in s.sv("DevilForever_CoreDB")["edits"], False, "empty frame entry removed")


@case
def edit_validation_and_ranges():
    s = Session().boot()
    e = s.core.Edit
    bad = [("test.chat", "rows", 11), ("test.chat", "rows", 2.5), ("test.chat", "font", s.table({"size": 40})),
           ("test.chat", "size", s.table({"width": 10, "height": 100})), ("test.chat", "nope", 1),
           ("", "rows", 2), ("test.bar", "color", s.table([1, 2, 0])), ("test.bar", "spacing", -1),
           ("test.bar", "position", s.table({"x": 1, "y": 2}))]
    for frame, field, value in bad:
        ok, _reason = e.Set(e, frame, field, value)
        eq(ok, False, "rejected %s.%s" % (frame, field))
    eq(e.Set(e, "test.bar", "rows", 40)[0], True, "no range for an unregistered item")
    eq(to_py(s.sv("DevilForever_CoreDB")["edits"]), {"test.bar": {"rows": 40}}, "only the valid edit stored")


@case
def edit_combat_queue_then_flush():
    s = Session().boot()
    e = s.core.Edit
    calls = []
    s.g.TEST_cb = lambda key, field, value: calls.append((key, field, to_py(value)))
    s.lua.execute("DevilForever_Core.Edit:RegisterCallback('test', function(k, f, v) TEST_cb(k, f, v) end)")
    s.combat(True)
    eq(e.Set(e, "test.chat", "rows", 3), (True, "queued"), "queued")
    eq(e.Set(e, "test.chat", "rows", 4), (True, "queued"), "queued again")
    eq(e.Set(e, "test.bar", "spacing", 2), (True, "queued"), "second frame")
    eq(to_py(e.GetEdits(e, "test.chat")), {}, "not stored during combat")
    eq(calls, [], "no callback during combat")
    eq(len(to_py(e.GetPending(e))), 2, "two pending entries")
    s.combat(False)
    eq(calls, [("test.chat", "rows", 4), ("test.bar", "spacing", 2)], "flushed in order, last value wins")
    eq(to_py(e.GetEdits(e, "test.chat")), {"rows": 4}, "stored after combat")
    eq(to_py(e.GetPending(e)), {}, "queue empty")
    s.combat(True)
    eq(e.Clear(e, "test.chat"), (True, "queued"), "clear queued in combat")
    s.combat(False)
    eq(to_py(e.GetEdits(e, "test.chat")), {}, "cleared after combat")


@case
def edit_values_persist_across_sessions():
    first = Session().boot()
    e = first.core.Edit
    e.Set(e, "test.chat", "color", first.table([0.5, 0.5, 0.5]))
    second = Session(saved={"DevilForever_CoreDB": first.sv("DevilForever_CoreDB")}).boot()
    e2 = second.core.Edit
    eq(to_py(e2.Get(e2, "test.chat"))["color"], {1: 0.5, 2: 0.5, 3: 0.5}, "edit restored")


@case
def callback_error_does_not_stop_others():
    s = Session().boot()
    t = s.core.Theme
    t.RegisterSet(t, "alt", s.table({}))
    s.lua.execute("""
      TEST_second = false
      DevilForever_Core.Theme:RegisterCallback('a', function() error('boom') end)
      DevilForever_Core.Theme:RegisterCallback('b', function() TEST_second = true end)
    """)
    t.SetActiveSet(t, "alt")
    eq(s.g.TEST_second, True, "second listener ran")
    eq(len(s.errors()), 1, "error passed to the error handler")


@case
def core_db_wrong_type_kept_on_disk():
    s = Session(saved={"DevilForever_CoreDB": {"edits": "broken", "theme": False}}).boot()
    e = s.core.Edit
    eq(e.Set(e, "test.bar", "rows", 2), (True, "applied"), "edit works on a session-only table")
    eq(to_py(e.GetEdits(e, "test.bar")), {"rows": 2}, "readable this session")
    db = s.sv("DevilForever_CoreDB")
    eq((db["edits"], db["theme"]), ("broken", False), "wrong-typed values kept on disk")
    eq(sum(1 for x in s.log() if x["kind"] == "conflict"), 2, "both logged")


# Registry generator -------------------------------------------------------------

def load_genregistry():
    sys.path.insert(0, os.path.join(REPO, "Collection", "tools"))
    import genregistry  # noqa: E402
    return genregistry


@case
def genregistry_extra_applied_and_checked():
    gen = load_genregistry()
    entries = {"Dominos": {"savedVariables": [{"name": "DominosDB", "scope": "account", "split": "common"}],
                           "frames": [], "editable": [], "bundle": "individual", "defaults": None}}
    gen.apply_extra(entries, {"addons": {"dominos": {
        "frames": [{"key": "dominos.bar1", "frame": "DominosFrame1", "tokens": {"spacing": "spacing.default"}}],
        "editable": [{"frame": "dominos.bar1", "field": "spacing", "min": 0, "max": 10}],
        "saved_variables": {"DominosDB": {"split": "class", "restore": "profile", "shape": "acedb"}}}}})
    d = entries["Dominos"]
    eq(d["frames"][0]["frame"], "DominosFrame1", "frame added (folder matched ignoring case)")
    eq(d["editable"][0]["kind"], "spacing", "kind filled from field")
    eq(d["savedVariables"][0]["split"], "class", "split set")
    bad = [
        {"addons": {"NoSuch": {}}},
        {"addons": {"Dominos": {"saved_variables": {"OtherDB": {}}}}},
        {"addons": {"Dominos": {"editable": [{"frame": "x", "field": "width"}]}}},
        {"addons": {"Dominos": {"editable": [{"frame": "x", "field": "rows", "min": 5, "max": 1}]}}},
        {"addons": {"Dominos": {"defaults": "Defaults/Missing.lua"}}},
        {"addons": {"Dominos": {"defaults": "../outside.lua"}}},
    ]
    for extra in bad:
        fresh = {"Dominos": dict(d, frames=[], editable=[])}
        try:
            gen.apply_extra(fresh, extra)
        except gen.RegistryError:
            continue
        raise AssertionError("extra accepted: %r" % (extra,))


@case
def genregistry_output_matches_file():
    gen = load_genregistry()
    text = gen.render(gen.build()).encode("utf-8")
    with open(gen.OUTPUT, "rb") as fh:
        eq(fh.read() == text, True, "Registry.lua is the generator output")
    eq(gen.render(gen.build()).encode("utf-8") == text, True, "two builds give the same bytes")


@case
def defaults_register_rejected_by_registry():
    s = Session().boot()
    d = s.core.Defaults
    spec = lambda sv: s.table({"version": 1, "targets": [{"savedVariable": sv, "shape": "plain", "values": {}}]})
    cases = [("NotInRegistry", "X"), ("TestFrames", "X"), ("TestPlain", "OtherDB")]
    for folder, sv in cases:
        ok, reason = d.Register(d, folder, spec(sv))
        eq(ok, False, "refused %s %s" % (folder, sv))
        eq(bool(reason), True, "reason for %s" % folder)
    errors = [x for x in s.log() if x["kind"] == "error"]
    eq(len(errors), 3, "refusals logged")
    eq(d.Register(d, "testplain", spec("TestPlainDB")), True, "accepted (folder case ignored)")
    eq(list(to_py(d.ListRegistered(d)).values())[-1], "TestPlain", "registry spelling kept")


REGIONAL = """
RegionalUniqueNamesEnabled = function() return true end
Enum = {GameRule = {RPRuleset = 1, PvPRuleset = 2, HardcoreRuleset = 3}}
C_GameRules = {IsGameRuleActive = function(rule) return rule == 2 end}
"""


@case
def player_key_regional_names():
    s = Session(player={"surname": "Surname"})
    s.lua.execute(REGIONAL)
    keys = to_py(s.core.PlayerKeys())
    eq((keys["char"], keys["realm"]), ("Hero Surname", "PvP"), "AceDB regional key")
    s.boot(after=["TestChar", "TestAce"])
    applied = s.sv("DevilForever_CoreDB")["defaults"]["applied"]
    eq(list(applied["TestChar"]), ["TestCharDB@char:Hero Surname"], "character key uses regional form")
    eq(sorted(s.sv("TestAceDB")["profiles"]), ["Warrior"], "AceDB profile by class name")


@case
def player_key_regional_without_rules_api_waits():
    s = Session(player={"surname": "Surname"})
    s.lua.execute("RegionalUniqueNamesEnabled = function() return true end")
    eq(s.core.PlayerKeys()[0], None, "no key without the game-rule API")
    s.boot(after=["TestAce"])
    eq(s.status("TestAce")["targets"]["TestAceDB"]["state"], "waiting", "AceDB target waits")
    eq(s.errors(), [], "no errors")


@case
def defaults_acedb_character_scope_key():
    s = Session().boot(after=["TestAceChar"])
    applied = s.sv("DevilForever_CoreDB")["defaults"]["applied"]["TestAceChar"]
    eq(list(applied), ["TestAceCharDB@char:Hero - Realm@profile:Hero - Realm"], "per-character AceDB key")
    eq(s.sv("TestAceCharDB")["profiles"]["Hero - Realm"], {"on": True}, "filled")


@case
def theme_register_active_set_in_combat_waits():
    s = Session().boot()
    t = s.core.Theme
    calls = []
    s.g.TEST_cb = lambda new, old: calls.append((new, old))
    s.lua.execute("DevilForever_Core.Theme:RegisterCallback('test', function(n, o) TEST_cb(n, o) end)")
    s.combat(True)
    eq(t.RegisterSet(t, "devil", devil_values(s)), 5, "values kept")
    eq(calls, [], "no callback in combat")
    eq(t.Get(t, "font.size.normal"), 14, "values readable at once")
    s.combat(False)
    eq(calls, [("devil", "devil")], "notified once after combat")
    s.combat(True)
    s.combat(False)
    eq(calls, [("devil", "devil")], "no repeat")


@case
def genregistry_editable_frame_and_default_checked():
    gen = load_genregistry()
    frames = [{"key": "k1", "frame": "F1"}]
    good = {"addons": {"Dominos": {"frames": frames, "editable": [
        {"frame": "k1", "field": "rows", "min": 1, "max": 12, "default": 3},
        {"frame": "k1", "field": "color", "default": [0.1, 0.2, 0.3]},
        {"frame": "k1", "field": "font", "min": 8, "max": 30, "default": {"size": 12}}]}}}
    base = lambda: {"Dominos": {"savedVariables": [], "frames": [], "editable": [], "bundle": "individual",
                                "defaults": None}}
    entries = base()
    gen.apply_extra(entries, good)
    eq(len(entries["Dominos"]["editable"]), 3, "valid items kept")
    bad_items = [
        {"frame": "nope", "field": "rows"},
        {"frame": "k1", "field": "rows", "min": 1, "max": 12, "default": 20},
        {"frame": "k1", "field": "rows", "default": 2.5},
        {"frame": "k1", "field": "color", "default": [2, 0, 0]},
        {"frame": "k1", "field": "font", "min": 8, "default": {"size": 4}},
        {"frame": "k1", "field": "size", "default": {"width": 0, "height": 5}},
        {"frame": "k1", "field": "position", "default": {"x": 1, "y": 2}},
        {"frame": "k1", "field": "spacing", "default": -1},
    ]
    for item in bad_items:
        try:
            gen.apply_extra(base(), {"addons": {"Dominos": {"frames": frames, "editable": [item]}}})
        except gen.RegistryError:
            continue
        raise AssertionError("editable item accepted: %r" % (item,))


@case
def defaults_load_on_demand_fresh_fill_missing_only():
    s = Session().boot()
    s.self_fill("TestPlain", "TestPlainDB", {"alpha": 100, "own": 1})
    s.load_addon("TestPlain")  # loaded after the first PLAYER_ENTERING_WORLD, fresh SV
    s.g.TestPlainDB.alpha = 42  # a same-frame writer (e.g. restore) sets a value
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "waiting", "settles at the next world entry")
    s.fire("PLAYER_ENTERING_WORLD", False, False)
    db = s.sv("TestPlainDB")
    eq((db["alpha"], db["beta"], db["own"]), (42, 2, 1), "writer value kept, missing keys filled")
    st = s.status("TestPlain")["targets"]["TestPlainDB"]
    eq((st["state"], st["mode"]), ("applied", "fill-missing"), "fill-missing only")


@case
def defaults_suppress_before_login_overwrite():
    s = Session()
    s.self_fill("TestPlain", "TestPlainDB", {"alpha": 100})
    s.boot(after=["TestPlain"], login=False)
    eq(s.status("TestPlain")["targets"]["TestPlainDB"]["state"], "waiting", "login-window write pending")
    d = s.core.Defaults
    eq(d.Suppress(d, "testplain", "restore in progress"), True, "suppressed")
    s.g.TestPlainDB.alpha = 7  # the restore writes its value
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.sv("TestPlainDB"), {"alpha": 7}, "values kept, nothing written")
    st = s.status("TestPlain")
    eq((st["targets"]["TestPlainDB"]["state"], st["suppressed"]), ("suppressed", "restore in progress"), "status")
    eq("TestPlain" in s.sv("DevilForever_CoreDB")["defaults"]["applied"], False, "nothing recorded")
    eq(any("suppressed for this session" in x["message"] for x in s.log()), True, "logged")
    eq(d.Suppress(d, ""), (False, "folder must be a non-empty string"), "bad folder refused")


@case
def defaults_late_created_across_sessions():
    first = Session().boot(after=["TestPlain"])
    st = first.status("TestPlain")["targets"]["TestPlainDB"]
    eq((st["state"], st["key"]), ("late-created", "TestPlainDB"), "first session late-created")
    core_db = first.sv("DevilForever_CoreDB")
    eq(core_db["defaults"]["lateCreated"]["TestPlain"], {"TestPlainDB": True}, "marker persisted")
    eq("TestPlain" in core_db["defaults"]["applied"], False, "not recorded as applied")
    first.g.TestPlainDB = first.table({"alpha": 5})  # the addon creates it later in the session
    second = Session(saved={"TestPlainDB": first.sv("TestPlainDB"), "DevilForever_CoreDB": core_db})
    second.boot(after=["TestPlain"])
    st2 = second.status("TestPlain")["targets"]["TestPlainDB"]
    eq((st2["state"], st2["mode"], st2["lateCreated"]), ("applied", "fill-missing", True), "second session")
    eq((second.sv("TestPlainDB")["alpha"], second.sv("TestPlainDB")["beta"]), (5, 2), "missing keys only")


@case
def defaults_player_keys_unavailable_logged():
    s = Session(player={"name": ""}).boot(after=["TestAce"])
    st = s.status("TestAce")["targets"]["TestAceDB"]
    eq(st["state"], "waiting", "AceDB target waits")
    eq("player name or realm not known yet" in st["message"], True, "reason in status")
    eq(any("player name or realm not known yet" in (x["message"] or "") for x in s.log()), True, "reason logged")
    eq(s.sv("TestAceDB"), None, "nothing created")


def late_key_session(saved=None, acedb_new=None):
    """Player key unknown at the addon's ADDON_LOADED; the addon's AceDB:New runs
    (acedb_new edits TestAceDB the way it would); the key is known at PLAYER_LOGIN."""
    s = Session(saved=saved, player={"name": ""}).boot(after=["TestAce"], login=False)
    eq(s.status("TestAce")["targets"]["TestAceDB"]["state"], "waiting", "waits for the player key")
    if acedb_new:
        s.g.TestAceDB = s.table(acedb_new(s.sv("TestAceDB")))
    s.g.TEST_player.name = "Hero"
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


def acedb_new_warrior(db):
    # AceDB:New with defaultProfile "$className": profileKeys entry and an empty profile.
    db = db or {}
    db.setdefault("profileKeys", {})["Hero - Realm"] = db.get("profileKeys", {}).get("Hero - Realm", "Warrior")
    db.setdefault("profiles", {}).setdefault(db["profileKeys"]["Hero - Realm"], {})
    return db


@case
def defaults_acedb_late_key_fresh_install_written():
    s = late_key_session(acedb_new=acedb_new_warrior)
    db = s.sv("TestAceDB")
    eq(db["profiles"], {"Warrior": {"scale": 1, "bars": {"count": 8}}}, "written into the profile AceDB made")
    eq(db["namespaces"]["Module"]["profiles"], {"Warrior": {"on": False}}, "namespace written")
    eq(db["profileKeys"], {"Hero - Realm": "Warrior"}, "profileKeys as AceDB set it")
    eq({v["state"] for v in s.status("TestAce")["targets"].values()}, {"applied"}, "both applied")
    eq(s.errors(), [], "no errors")


@case
def defaults_acedb_late_key_existing_install_kept():
    saved = {"TestAceDB": {"profileKeys": {"Hero - Realm": "Main"}, "profiles": {"Main": {"scale": 2}}}}
    s = late_key_session(saved=saved, acedb_new=acedb_new_warrior)
    eq(s.sv("TestAceDB"), saved["TestAceDB"], "existing profile untouched")
    eq({v["state"] for v in s.status("TestAce")["targets"].values()}, {"existing-profile-kept"}, "both kept")


@case
def defaults_acedb_late_key_namespace_under_existing_profile_kept():
    # Another Warrior made the shared class profile; this character's AceDB:New adds its profileKeys entry.
    saved = {"TestAceDB": {"profileKeys": {"Other - Realm": "Warrior"}, "profiles": {"Warrior": {"scale": 2}}}}
    s = late_key_session(saved=saved, acedb_new=acedb_new_warrior)
    db = s.sv("TestAceDB")
    eq((db["profiles"], "namespaces" in db), ({"Warrior": {"scale": 2}}, False), "shared profile and namespace untouched")
    eq({v["state"] for v in s.status("TestAce")["targets"].values()}, {"existing-profile-kept"}, "both kept")


# Real defaults files ----------------------------------------------------------

@case
def dominos_defaults_fresh_class_profile():
    s = Session(registry="generated", extra_files=()).boot(after=["Dominos"])
    eq(s.sv("DominosDB"), {"profiles": {"Warrior": {"showBindingText": True}}},
       "profile named after the localized class name")
    st = s.status("Dominos")["targets"]["DominosDB"]
    eq((st["state"], st["key"], st["version"]), ("applied", "DominosDB@profile:Warrior", 1), "status")
    second = Session(registry="generated", extra_files=(),
                     saved={"DominosDB": s.sv("DominosDB"), "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")})
    second.boot(after=["Dominos"])
    eq(second.status("Dominos")["targets"]["DominosDB"]["state"], "already", "once per version")
    eq(s.errors() + second.errors(), [], "no errors")


@case
def dominos_defaults_existing_profile_kept():
    saved = {"DominosDB": {"profileKeys": {"Hero - Realm": "Custom"},
                           "profiles": {"Custom": {"ab": {"count": 10, "length": 12}, "showBindingText": False}},
                           "global": {"configVersion": 3}}}
    s = Session(registry="generated", extra_files=(), saved=saved).boot(after=["Dominos"])
    db = s.sv("DominosDB")
    eq(db["profiles"], {"Custom": {"ab": {"count": 10, "length": 12}, "showBindingText": False}},
       "user values kept, no class profile made")
    st = s.status("Dominos")["targets"]["DominosDB"]
    eq((st["state"], st["key"]), ("existing-profile-kept", "DominosDB@profile:Custom"), "profileKeys profile kept")
    other = Session(registry="generated", extra_files=(), player={"className": "Mage", "class": "MAGE", "name": "Sage"},
                    saved={"DominosDB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")}).boot(after=["Dominos"])
    eq(other.sv("DominosDB")["profiles"]["Mage"], {"showBindingText": True},
       "a new character of another class gets its class profile")


@case
def native_chat_install_leaves_prat_defaults_absent():
    s = Session(registry="generated", extra_files=()).boot(after=["Prat-3.0"])
    eq(s.sv("Prat3DB"), None, "collection did not create a Prat database")
    eq(s.status("Prat-3.0")["registered"], False, "Prat defaults absent")
    eq(s.errors(), [], "no errors")


@case
def native_chat_install_preserves_external_prat_values():
    # History left at Prat's default (stripped by AceDB: no Prat_History data); Memory changed.
    saved = {"Prat3DB": {"profileKeys": {"Hero - Realm": "Mine"},
                         "profiles": {"Mine": {"modules": {"Memory": 3}}},
                         "namespaces": {"Prat_Memory": {"profiles": {"Mine": {"autoload": True}}}}}}
    s = Session(registry="generated", extra_files=(), saved=saved).boot(after=["Prat-3.0"])
    eq(s.sv("Prat3DB"), saved["Prat3DB"], "user's profile, both namespaces and the absent History data untouched")
    eq(s.status("Prat-3.0")["targets"], {}, "no Prat target was selected")


GRID2_LAYOUT = {"layouts": {"solo": "None", "party": "By Group", "arena": "By Group"}, "FrameDisplay": "Grouped",
                "minimapIcon": {"hide": True}}


@case
def grid2_defaults_fresh_character_profile():
    s = Session(registry="generated", extra_files=()).boot(after=["Grid2"])
    eq(s.sv("Grid2DB"), {"profiles": {"Hero - Realm": {"hideBlizzard": {"raid": True}}},
                         "namespaces": {"Grid2Layout": {"profiles": {"Hero - Realm": GRID2_LAYOUT}}}},
       "AceDB:New(..., nil): profile named by the character key; layout namespace under the same name")
    st = s.status("Grid2")["targets"]
    eq((st["Grid2DB"]["state"], st["Grid2DB"]["key"]), ("applied", "Grid2DB@profile:Hero - Realm"), "main status")
    eq((st["Grid2DB/Grid2Layout"]["state"], st["Grid2DB/Grid2Layout"]["key"]),
       ("applied", "Grid2DB/Grid2Layout@profile:Hero - Realm"), "layout status")
    alt = Session(registry="generated", extra_files=(), player={"name": "Alt", "className": "Priest", "class": "PRIEST"},
                  saved={"Grid2DB": s.sv("Grid2DB"), "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")})
    alt.boot(after=["Grid2"])
    db = alt.sv("Grid2DB")
    eq((db["profiles"]["Alt - Realm"], db["namespaces"]["Grid2Layout"]["profiles"]["Alt - Realm"]),
       ({"hideBlizzard": {"raid": True}}, GRID2_LAYOUT), "a new character gets its own profile written")
    eq(db["profiles"]["Hero - Realm"], {"hideBlizzard": {"raid": True}}, "the first character's profile untouched")
    eq(s.errors() + alt.errors(), [], "no errors")


@case
def grid2_defaults_existing_profile_kept():
    # The user's profile after Grid2's first start: versions set, party layout chosen, Blizzard
    # raid frames left shown (hideBlizzard absent).
    saved = {"Grid2DB": {"profileKeys": {"Hero - Realm": "Hero - Realm"},
                         "profiles": {"Hero - Realm": {"versions": {"Grid2": 200}}},
                         "namespaces": {"Grid2Layout": {"profiles": {"Hero - Realm": {
                             "layouts": {"party": "By Role"}}}}}}}
    s = Session(registry="generated", extra_files=(), saved=saved).boot(after=["Grid2"])
    eq(s.sv("Grid2DB"), saved["Grid2DB"], "user's profile and layout namespace untouched")
    eq({k: v["state"] for k, v in s.status("Grid2")["targets"].items()},
       {"Grid2DB": "existing-profile-kept", "Grid2DB/Grid2Layout": "existing-profile-kept"}, "both kept")


PB4_UNITS_ON = sorted(["플레이어", "대상", "대상의 대상", "대상의 대상의 대상", "주시 대상", "주시 대상의 대상",
                       "주시 대상의 대상의 대상", "플레이어의 소환수", "플레이어의 소환수의 대상", "플레이어의 소환수의 대상의 대상"])


@case
def pitbull4_defaults_fresh_shared_default_profile():
    s = Session(registry="generated", extra_files=()).boot(after=["PitBull4"])
    db = s.sv("PitBull4DB")
    eq(sorted(db), ["namespaces", "profiles"], "Core creates only profiles and namespaces (AceDB adds the rest)")
    eq(sorted(db["profiles"]), ["Default"], "AceDB:New(..., \"Default\"): one shared profile")
    p = db["profiles"]["Default"]
    eq(sorted(n for n, u in p["units"].items() if u.get("enabled")), PB4_UNITS_ON, "Devil unit frames on")
    eq(p["units"]["플레이어"], {"enabled": True, "layout": "보통", "unit": "player"}, "player names its layout")
    eq(sorted(p["groups"]), ["파티", "파티원 대상", "파티원 소환수"], "party groups only")
    eq((p["made_units"], p["made_groups"], p["group_anchors_updated"]), (True, True, True), "PitBull4 markers")
    eq(len(db["namespaces"]), 25, "25 module namespaces")
    eq(db["namespaces"]["CastBar"]["profiles"]["Default"],
       {"global": {"enabled": False}, "layouts": {n: {"enabled": False} for n in ("대상", "대상의대상", "보통", "파티")}},
       "cast bar module and its four layouts off")
    eq(sorted(p["layouts"]), sorted(["Normal", "대상", "대상의대상", "보통", "파티"]),
       "L[\"Normal\"] layout exists (no GetLocale here: \"Normal\")")
    ko = Session(registry="generated", extra_files=(), globals_={"GetLocale": lambda: "koKR"}).boot(after=["PitBull4"])
    eq(sorted(ko.sv("PitBull4DB")["profiles"]["Default"]["layouts"]), sorted(["대상", "대상의대상", "보통", "파티"]),
       "koKR: L[\"Normal\"] is 보통, already one of the Devil layouts")
    eq(db["namespaces"]["Aura"]["profiles"]["Default"]["layouts"]["파티"]["layout"]["buff"]["filter"], "!C",
       "party buff filter")
    st = s.status("PitBull4")["targets"]
    eq(len(st), 26, "main profile + 25 namespaces")
    eq((st["PitBull4DB"]["state"], st["PitBull4DB"]["mode"], st["PitBull4DB"]["key"]),
       ("applied", "fill-missing", "PitBull4DB@profile:Default"), "main target status")
    eq(st["PitBull4DB/LuaTexts"]["key"], "PitBull4DB/LuaTexts@profile:Default", "namespace target key")
    eq(all(t["state"] == "applied" for t in st.values()), True, "every target applied")
    alt = Session(registry="generated", extra_files=(), player={"name": "Alt", "className": "Mage", "class": "MAGE"},
                  saved={"PitBull4DB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")})
    alt.boot(after=["PitBull4"])
    eq({t["state"] for t in alt.status("PitBull4")["targets"].values()}, {"already"}, "shared profile: once per version")
    eq(s.errors() + alt.errors(), [], "no errors")


@case
def pitbull4_defaults_user_values_and_spec_profile_kept():
    # The user switched the player frame off: enabled = false equals the "**" default, so AceDB
    # stripped it; the player frame keeps only unit = "player". No module namespace data
    # (every module setting default-equal, e.g. the cast bar left on).
    saved = {"PitBull4DB": {"profileKeys": {"Hero - Realm": "Wide"},
                            "global": {"config_version": 8},
                            "profiles": {"Wide": {"made_units": True,
                                                  "units": {"플레이어": {"unit": "player"}}}}}}
    s = Session(registry="generated", extra_files=(), saved=saved).boot(after=["PitBull4"])
    eq(s.sv("PitBull4DB"), saved["PitBull4DB"], "player frame stays off, no Devil units added, no namespaces made")
    st = s.status("PitBull4")["targets"]
    eq(len(st), 26, "26 targets")
    eq({v["state"] for v in st.values()}, {"existing-profile-kept"}, "every target kept")
    eq((st["PitBull4DB"]["key"], st["PitBull4DB/CastBar"]["key"]),
       ("PitBull4DB@profile:Wide", "PitBull4DB/CastBar@profile:Wide"), "profileKeys profile")
    alt = Session(registry="generated", extra_files=(), player={"name": "Alt", "className": "Mage", "class": "MAGE"},
                  saved={"PitBull4DB": {"profileKeys": {"Hero - Realm": "Wide"},
                                        "profiles": {"Default": {"made_units": True}}}})
    alt.boot(after=["PitBull4"])
    eq(alt.sv("PitBull4DB")["profiles"], {"Default": {"made_units": True}}, "shared Default of another character kept")
    eq(s.errors() + alt.errors(), [], "no errors")

# SexyMap's own first-load setup at its ADDON_LOADED (SexyMap.lua:325-353,
# Buttons.lua:217-246): the SV, the character profile and each module table are
# created only when missing. A test stand-in; the upstream file is not run.
SEXYMAP_INIT = r"""
local key = UnitNameUnmodified("player") .. "-" .. GetRealmName()
if type(SexyMap2DB) ~= "table" then SexyMap2DB = {} end
if not SexyMap2DB[key] then SexyMap2DB[key] = {} end
local p = SexyMap2DB[key]
if type(p) == "string" then
  if not SexyMap2DB.global then SexyMap2DB.global = {} end
  p = SexyMap2DB.global
end
if not p.core then
  p.core = {lock = false, clamp = true, rightClickToConfig = true, autoZoom = 5, northTag = true,
            shape = "Interface\\AddOns\\SexyMap\\shapes\\circle.tga"}
end
if type(p.buttons) ~= "table" then
  p.buttons = {radius = 10, scale = 1,
    dragPositions = {DayNight = 45, MiniMapTracking = -16, GameTimeFrame = 22, MiniMapMailFrame = 2,
                     AddonCompartmentFrame = 126, MinimapZoomIn = -55, MinimapZoomOut = -36},
    visibilitySettings = {MinimapZoomIn = "never", MinimapZoomOut = "never", MiniMapWorldMapButton = "never",
      SexyMapZoneTextButton = "always", TimeManagerClockButton = "always", MiniMapMailFrame = "always",
      CraftingOrder = "always", ExpansionLandingPageMinimapButton = "hover", AddonCompartmentFrame = "never",
      DayNight = "hover"},
    allowDragging = true, lockDragging = false, controlVisibility = true}
end
if type(p.ping) ~= "table" then p.ping = {showPing = true, showAt = "map"} end
"""

SEXYMAP_CORE = {"lock": False, "clamp": True, "rightClickToConfig": True, "autoZoom": 5, "northTag": True,
                "shape": "Interface\\AddOns\\SexyMap\\shapes\\circle.tga"}


def sexymap_session(saved=None, player=None):
    """Core first, SexyMap's ADDON_LOADED setup after Core's handler, then login."""
    s = Session(registry="generated", extra_files=(), saved=saved, player=player)
    s.load_addon(ADDON)
    s.g.TEST_loaded["SexyMap"] = True
    s.fire("ADDON_LOADED", "SexyMap")
    s.lua.execute(SEXYMAP_INIT)
    s.fire("PLAYER_LOGIN")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    return s


@case
def sexymap_defaults_fresh_written_at_world():
    s = sexymap_session()
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    eq((p["core"]["rightClickToConfig"], p["buttons"]["visibilitySettings"]["MiniMapTracking"]), (False, "always"),
       "requirement values over SexyMap's first-load values")
    eq(p["buttons"]["visibilitySettings"]["TimeManagerClockButton"], "never", "status strip is the only clock")
    eq(p["core"]["shape"], SEXYMAP_CORE["shape"], "shape left to SexyMap")
    eq(p["ping"], {"showPing": True, "showAt": "map"}, "other modules untouched")
    st = s.status("SexyMap")["targets"]["SexyMap2DB"]
    eq((st["state"], st["mode"], st["key"]), ("applied", "first-load", "SexyMap2DB"), "status")
    db = s.sv("SexyMap2DB")
    db["Hero-Realm"]["core"]["rightClickToConfig"] = True  # the user turns it back on
    nxt = sexymap_session(saved={"SexyMap2DB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")})
    eq(nxt.sv("SexyMap2DB")["Hero-Realm"]["core"]["rightClickToConfig"], True, "user value kept next session")
    eq(nxt.status("SexyMap")["targets"]["SexyMap2DB"]["state"], "already", "once per version")
    eq(s.errors() + nxt.errors(), [], "no errors")


@case
def sexymap_defaults_new_character_tables_complete():
    other = {"core": dict(SEXYMAP_CORE, autoZoom=0), "buttons": {"radius": 3}}
    saved = {"SexyMap2DB": {"Other-Realm": other, "presets": {}}}
    s = sexymap_session(saved=saved)
    db = s.sv("SexyMap2DB")
    eq(db["Other-Realm"], other, "another character's profile untouched")
    p = db["Hero-Realm"]
    core = dict(SEXYMAP_CORE, rightClickToConfig=False)
    del core["shape"]
    eq(p["core"], core, "core table complete without SexyMap's own (shape absent: Blizzard mask)")
    eq(p["buttons"]["visibilitySettings"]["MiniMapTracking"], "always", "tracking button")
    eq(sorted(p["buttons"].keys()), ["allowDragging", "controlVisibility", "dragPositions", "lockDragging",
                                     "radius", "scale", "visibilitySettings"], "buttons table complete")
    eq(len(p["buttons"]["dragPositions"]), 7, "SexyMap's button angles")
    eq(p["ping"], {"showPing": True, "showAt": "map"}, "missing module tables still made by SexyMap")
    st = s.status("SexyMap")["targets"]["SexyMap2DB"]
    eq((st["state"], st["mode"]), ("applied", "fill-missing"), "status")
    eq(s.errors(), [], "no errors")


@case
def sexymap_defaults_existing_and_global_profile_kept():
    mine = {"core": dict(SEXYMAP_CORE), "buttons": {"visibilitySettings": {"MiniMapTracking": "never"}}}
    s = sexymap_session(saved={"SexyMap2DB": {"Hero-Realm": mine}})
    p = s.sv("SexyMap2DB")["Hero-Realm"]
    eq((p["core"]["rightClickToConfig"], p["buttons"]["visibilitySettings"]["MiniMapTracking"]), (True, "never"),
       "stored values kept")
    eq(p["buttons"]["visibilitySettings"]["MinimapZoomIn"], "never", "missing keys filled")
    g = sexymap_session(saved={"SexyMap2DB": {"Hero-Realm": "global", "global": {"core": dict(SEXYMAP_CORE)}}})
    gdb = g.sv("SexyMap2DB")
    eq((gdb["Hero-Realm"], gdb["global"]["core"]["rightClickToConfig"]), ("global", True), "global choice kept")
    st = g.status("SexyMap")["targets"]["SexyMap2DB"]
    eq((st["state"], len(st["conflicts"])), ("applied", 1), "conflict recorded")
    eq(any(e["kind"] == "conflict" and e["subject"] == "SexyMap" for e in g.log()), True, "conflict logged")


@case
def sexymap_defaults_regional_profile_key():
    s = Session(registry="generated", extra_files=(), player={"surname": "Brave"}, saved={"SexyMap2DB": {}})
    s.lua.execute("RegionalUniqueNamesEnabled = function() return true end")
    s.run_file(os.path.join(CORE_DIR, "Defaults", "SexyMap.lua"))  # the defaults file as loaded with regional names on
    s.boot(after=["SexyMap"])
    eq(sorted(s.sv("SexyMap2DB").keys()), ["Hero Brave"], "regional names: \"<name> <surname>\" as SexyMap keys it")
    eq(s.status("SexyMap")["targets"]["SexyMap2DB"]["state"], "applied", "status")


@case
def sexymap_defaults_profile_key_unknown_not_registered():
    s = Session(registry="generated", extra_files=(), player={"realm": ""})
    eq(s.status("SexyMap")["registered"], False, "not registered without a realm")
    eq(any(e["kind"] == "skip" and e["subject"] == "Defaults:SexyMap" for e in s.log()), True, "logged")


# Save / restore (Profiles.lua) and layout presets (Presets.lua) -------------------
#
# A session ends with /dfp go; the next Session gets every saved variable of
# the previous one (as the client writes them at logout) and loads the addons
# after Core. Data below is plain test data, not any addon's real layout.

P_ADDONS = ["PPlain", "PChar", "PAce", "PKeys", "PClass", "PSkip"]
P_SVS = ["DevilForever_CoreDB", "DevilForever_ProfilesDB", "PPlainDB", "PCharDB", "PAceDB", "PKeysDB", "PClassDB",
         "PSkipDB", "OtherDB"]


def p_session(saved=None, after=P_ADDONS, login=True, presets=False, **kw):
    kw.setdefault("extra_files", ("Defaults_Profiles.lua",))
    if presets:
        kw["preset_files"] = ("Presets_Test.lua",)
    s = Session(saved=saved, registry="profiles", **kw)
    return s.boot(after=after, login=login)


def carry(s, changes=None):
    """Saved variables of session `s` for the next session, with `changes` applied."""
    out = {}
    for name in P_SVS:
        value = s.sv(name)
        if value is not None:
            out[name] = value
    for name, value in (changes or {}).items():
        if value is None:
            out.pop(name, None)
        else:
            out[name] = value
    return out


def dfp(s, text):
    """Runs /dfp `text`; returns the chat lines it printed."""
    before = len(to_py(s.g.TEST_prints))
    s.g.SlashCmdList.DFPROFILE(text)
    lines = list(to_py(s.g.TEST_prints).values())
    return lines[before:]


def snapshot(s, name):
    return s.sv("DevilForever_ProfilesDB")["snapshots"].get(name)


def last_lines(s):
    return list(s.sv("DevilForever_ProfilesDB")["last"]["lines"].values())


def has_line(lines, *parts):
    return any(all(p in line for p in parts) for line in lines)


def saved_with(s, name="A", changes=None, **kw):
    """Requests a save in `s`, goes, and returns the next session after the save."""
    dfp(s, "save " + name)
    dfp(s, "go")
    eq(s.g.TEST_reloads, 1, "save reloads once")
    return p_session(carry(s, changes), **kw)


def restored(s, command, changes=None, **kw):
    dfp(s, command)
    dfp(s, "go")
    return p_session(carry(s, changes), **kw)


BASE = {"PPlainDB": {"x": 1, "nested": {"y": 2}}, "PSkipDB": {"y": 1}, "OtherDB": {"z": 1},
        "PAceDB": {"profileKeys": {"Hero - Realm": "Hero - Realm"}, "profiles": {"Hero - Realm": {"scale": 3}}},
        "PKeysDB": {"settings": {"a": 1}, "history": [1, 2, 3]}}


@case
def profiles_t1_registry_scope_only():
    s2 = saved_with(p_session(BASE))
    snap = snapshot(s2, "A")
    eq(sorted(snap["common"]), ["PAceDB", "PKeysDB", "PPlainDB"], "only registry restore targets saved")
    eq(snap["common"]["PKeysDB"]["data"], {"settings": {"a": 1}}, "keys entry holds the listed keys only")
    changes = {"PPlainDB": {"x": 9}, "PSkipDB": {"y": 9}, "OtherDB": {"z": 9},
               "PKeysDB": {"settings": {"a": 9}, "history": [9]}}
    s3 = restored(s2, "restore A", changes)
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "registry SV restored whole")
    eq((s3.sv("PSkipDB"), s3.sv("OtherDB")), ({"y": 9}, {"z": 9}), "skip and non-registry SVs untouched")
    eq(s3.sv("PKeysDB"), {"settings": {"a": 1}, "history": {1: 9}}, "keys restore: listed keys only, the rest kept")
    eq("DevilForever_ProfilesDB" in snap["common"] or "DevilForever_CoreDB" in snap["common"], False,
       "Core's own saved variables are never entries")
    eq(s2.errors() + s3.errors(), [], "no errors")


@case
def profiles_t2_core_layout_part():
    core = {"schema": 1, "edits": {"p.bar": {"rows": 3}}, "theme": {"active": "alt"},
            "defaults": {"applied": {"PAce": {"k": 1}}}}
    s2 = saved_with(p_session(dict(BASE, DevilForever_CoreDB=core)))
    eq(snapshot(s2, "A")["core"], {"edits": {"p.bar": {"rows": 3}}, "theme": "alt"}, "layout part saved")
    db = s2.sv("DevilForever_CoreDB")
    db["edits"] = {"p.bar": {"rows": 7}}
    db["theme"] = {"active": "other"}
    db["defaults"]["applied"]["PAce"] = {"k": 2}
    s3 = restored(s2, "restore A", {"DevilForever_CoreDB": db})
    out = s3.sv("DevilForever_CoreDB")
    eq((out["edits"], out["theme"]["active"]), ({"p.bar": {"rows": 3}}, "alt"), "edits and theme restored")
    eq(out["defaults"]["applied"]["PAce"], {"k": 2}, "defaults bookkeeping never rolled back")


@case
def profiles_t3_save_merge_keeps_missing_addon():
    s2 = saved_with(p_session(BASE))
    s3 = saved_with(s2, changes={"PPlainDB": {"x": 5}}, after=["PPlain"])
    snap = snapshot(s3, "A")
    eq(snap["common"]["PAceDB"]["carried"], True, "entry of an addon not loaded now carried")
    eq(snap["common"]["PAceDB"]["data"]["profiles"]["Hero - Realm"], {"scale": 3}, "its data kept")
    eq(snap["common"]["PPlainDB"].get("carried"), None, "entry read now is fresh")
    eq(snap["common"]["PPlainDB"]["data"], {"x": 5}, "new value saved")
    eq(has_line(last_lines(s3), "PAce", "켜지지 않음"), True, "report names the addon not loaded")


@case
def profiles_t4_restore_addon_not_loaded():
    s2 = saved_with(p_session(BASE))
    s3 = restored(s2, "restore A", {"PPlainDB": None}, after=["PAce"])
    eq(s3.sv("PPlainDB"), None, "saved variable not created")
    eq(snapshot(s3, "A")["common"]["PPlainDB"]["data"], {"x": 1, "nested": {"y": 2}}, "snapshot entry intact")
    eq(has_line(last_lines(s3), "PPlain", "켜지지 않음"), True, "reported")


@case
def profiles_t5_version_mismatch_untouched():
    meta = {"TEST_meta": {"PPlain": {"Version": "1.0"}}}
    s1 = p_session(BASE, globals_=meta)
    dfp(s1, "save A")
    dfp(s1, "go")
    s2 = p_session(carry(s1), globals_=meta)
    eq(snapshot(s2, "A")["common"]["PPlainDB"]["version"], "1.0", "metadata version stored")
    dfp(s2, "restore A")
    dfp(s2, "go")
    s3 = p_session(carry(s2, {"PPlainDB": {"x": 9}}), globals_={"TEST_meta": {"PPlain": {"Version": "1.1"}}})
    eq(s3.sv("PPlainDB"), {"x": 9}, "saved variable untouched")
    eq(has_line(last_lines(s3), "PPlainDB", "1.0", "1.1", "건드리지 않음"), True, "both versions reported")


@case
def profiles_t6_written_before_the_addon_reads():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    dfp(s2, "go")
    s3 = Session(saved=carry(s2, {"PPlainDB": {"x": 9}}), registry="profiles", extra_files=("Defaults_Profiles.lua",))
    s3.self_fill("PPlain", "PPlainDB", {"x": 100, "own": 1})
    s3.boot(after=P_ADDONS)
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}, "own": 1}, "the addon saw the restored table")


@case
def profiles_t7_defaults_suppressed():
    saved = dict(BASE)
    del saved["PAceDB"]
    s1 = p_session(saved)
    eq(s1.status("PAce")["targets"]["PAceDB"]["state"], "applied", "defaults applied on the first session")
    s2 = saved_with(s1)
    core = s2.sv("DevilForever_CoreDB")
    core["defaults"] = {"applied": {}}
    s3 = restored(s2, "restore A", {"DevilForever_CoreDB": core, "PAceDB": None})
    st = s3.status("PAce")
    eq((st["suppressed"] is not None, st["targets"]["PAceDB"]["state"]), (True, "suppressed"), "suppressed")
    eq("PAce" in s3.sv("DevilForever_CoreDB")["defaults"]["applied"], False, "no defaults write recorded")


@case
def profiles_t8_acedb_too_late():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    dfp(s2, "go")
    changed = {"profileKeys": {"Hero - Realm": "Hero - Realm"}, "profiles": {"Hero - Realm": {"scale": 9}}}
    s3 = Session(saved=carry(s2, {"PAceDB": changed}), registry="profiles", extra_files=("Defaults_Profiles.lua",))
    s3.load_addon(ADDON)
    s3.lua.execute("TEST_libs['AceDB-3.0'] = {db_registry = {[{sv = PAceDB}] = true}}")
    for name in P_ADDONS:
        s3.load_addon(name)
    s3.fire("PLAYER_LOGIN")
    s3.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s3.sv("PAceDB"), changed, "nothing written")
    eq(has_line(last_lines(s3), "PAceDB", "너무 늦음"), True, "reported")
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "other targets still restored")


@case
def profiles_t9_before_restore_backup_and_undo():
    s2 = saved_with(p_session(BASE))
    s3 = restored(s2, "restore A", {"PPlainDB": {"x": 7}})
    undo = snapshot(s3, "__before-restore")
    eq(undo["common"]["PPlainDB"]["data"], {"x": 7}, "pre-restore disk state kept")
    eq(sorted(undo["common"]), ["PAceDB", "PKeysDB", "PPlainDB"], "every written SV backed up")
    s4 = restored(s3, "restore __before-restore")
    eq(s4.sv("PPlainDB"), {"x": 7}, "undo brings back the pre-restore state")
    eq(snapshot(s4, "__before-restore")["common"]["PPlainDB"]["data"], {"x": 1, "nested": {"y": 2}},
       "the undo slot now holds the state before the undo")
    eq(dfp(s4, "list")[0].startswith("[DF 설정] A"), True, "list prints snapshots")


@case
def profiles_t10_character_scope_other_character():
    s2 = saved_with(p_session(dict(BASE, PCharDB={"mine": 1})))
    eq(snapshot(s2, "A")["common"]["PCharDB"]["char"], "Hero - Realm", "character key stored")
    alt = {"name": "Alt"}
    s2b = p_session(carry(s2, {"PCharDB": {"alt": 1}}), player=alt)
    s3 = restored(s2b, "restore A", player=alt)
    eq(s3.sv("PCharDB"), {"alt": 1}, "another character's SV untouched")
    eq(has_line(last_lines(s3), "PCharDB", "다른 캐릭터"), True, "reported")
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "account SV restored on any character")


CLASS_DB = {"profileKeys": {"Hero - Realm": "Warrior", "Sage - Realm": "Mage"},
            "profiles": {"Warrior": {"a": 1}, "Warrior (2)": {"b": 1}, "Mage": {"m": 1}},
            "namespaces": {"Mod": {"profiles": {"Warrior": {"n": 1}, "Mage": {"n": 2}}},
                           "LibDualSpec-1.0": {"char": {"Hero - Realm": {"enabled": True, 1: "Warrior",
                                                                          2: "Warrior (2)"}}}}}


@case
def profiles_t11_class_part_profile_level():
    s2 = saved_with(p_session(dict(BASE, PClassDB=CLASS_DB)))
    e = snapshot(s2, "A")["class"]["WARRIOR"]["PClassDB"]
    eq((list(e["profileNames"].values()), e["profileKey"]), (["Warrior", "Warrior (2)"], "Warrior"), "profiles read")
    eq(sorted(e["profiles"]), ["Warrior", "Warrior (2)"], "other class profiles not saved")
    eq(e["namespaces"], {"Mod": {"Warrior": {"n": 1}}}, "namespace profiles of those names")
    changed = {"profileKeys": {"Hero - Realm": "Other", "Sage - Realm": "Mage"},
               "profiles": {"Warrior": {"a": 9}, "Mage": {"m": 9}, "Other": {"o": 1}},
               "namespaces": {"Mod": {"profiles": {"Warrior": {"n": 9}, "Mage": {"n": 8}}}}}
    s3 = restored(s2, "restore A", {"PClassDB": changed})
    db = s3.sv("PClassDB")
    eq(db["profiles"], {"Warrior": {"a": 1}, "Warrior (2)": {"b": 1}, "Mage": {"m": 9}, "Other": {"o": 1}},
       "this character's profiles written, others untouched")
    eq(db["namespaces"]["Mod"]["profiles"], {"Warrior": {"n": 1}, "Mage": {"n": 8}}, "namespace profile restored")
    eq(db["profileKeys"], {"Hero - Realm": "Warrior", "Sage - Realm": "Mage"}, "only this character's profileKeys")
    eq(db["namespaces"]["LibDualSpec-1.0"]["char"]["Hero - Realm"][2], "Warrior (2)", "LibDualSpec entry restored")
    mage = {"name": "Sage", "className": "Mage", "class": "MAGE"}
    s4 = p_session(carry(s3, {"PClassDB": changed}), player=mage)
    s5 = restored(s4, "restore A class", player=mage)
    eq(s5.sv("PClassDB"), changed, "another class token: untouched")
    eq(has_line(last_lines(s5), "PClassDB", "WARRIOR", "건드리지 않음"), True, "reported")
    eq(s2.errors() + s3.errors() + s5.errors(), [], "no errors")


@case
def profiles_t12_common_and_class_selection():
    s2 = saved_with(p_session(dict(BASE, PClassDB=CLASS_DB)))
    changed_class = dict(CLASS_DB, profiles={"Warrior": {"a": 9}})
    s3 = restored(s2, "restore A common", {"PClassDB": changed_class, "PPlainDB": {"x": 9}})
    eq((s3.sv("PPlainDB")["x"], s3.sv("PClassDB")["profiles"]), (1, {"Warrior": {"a": 9}}), "common only")
    s4 = restored(s3, "restore A class", {"PClassDB": changed_class, "PPlainDB": {"x": 9}})
    eq((s4.sv("PPlainDB"), s4.sv("PClassDB")["profiles"]["Warrior"]), ({"x": 9}, {"a": 1}), "class only")
    s5 = restored(s4, "restore A only PPlain", {"PPlainDB": {"x": 9}, "PKeysDB": {"settings": {"a": 9}}})
    eq((s5.sv("PPlainDB")["x"], s5.sv("PKeysDB")["settings"]), (1, {"a": 9}), "only one folder")


@case
def profiles_t13_combat_refuses_everything():
    s2 = saved_with(p_session(BASE), presets=True)
    s2.combat(True)
    for command in ("save B", "restore A", "delete A yes", "preset qhd", "spec link", "spec new", "spec off",
                    "keys load K", "game save G", "go", "cancel"):
        lines = dfp(s2, command)
        eq(has_line(lines, "전투 중"), True, "refused: " + command)
    eq(s2.sv("DevilForever_ProfilesDB").get("pending"), None, "nothing pending")
    eq((s2.g.TEST_reloads, snapshot(s2, "A") is not None), (0, True), "no reload, nothing deleted")
    eq(s2.core.Presets.GetActive(s2.core.Presets), ("uhd", True), "preset unchanged")


@case
def profiles_t14_pending_other_char_or_too_old():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    dfp(s2, "go")
    s3 = p_session(carry(s2, {"PPlainDB": {"x": 9}}), player={"name": "Alt"})
    eq(s3.sv("PPlainDB"), {"x": 9}, "other character: not applied")
    eq(s3.sv("DevilForever_ProfilesDB").get("pending"), None, "cleared")
    eq(has_line(last_lines(s3), "다른 캐릭터"), True, "reported")
    dfp(s2, "cancel")
    dfp(s2, "restore A")
    dfp(s2, "go")
    s4 = p_session(carry(s2, {"PPlainDB": {"x": 9}}), globals_={"TEST_time": 1000 + 601})
    eq((s4.sv("PPlainDB"), s4.sv("DevilForever_ProfilesDB").get("pending")), ({"x": 9}, None), "too old: dropped")
    eq(has_line(last_lines(s4), "600"), True, "reported")


@case
def profiles_t15_unknown_schema_read_only():
    store = {"schema": 2, "snapshots": {"A": {"schema": 2, "common": {"PPlainDB": {"data": {"x": 1}}}}}, "future": True}
    s = p_session(dict(BASE, DevilForever_ProfilesDB=store))
    for command in ("save B", "restore A", "delete A yes"):
        eq(has_line(dfp(s, command), "안 함"), True, "refused: " + command)
    eq(s.sv("DevilForever_ProfilesDB"), store, "store unchanged")
    snap_store = {"schema": 1, "snapshots": {"B": {"schema": 7, "x": 1}}}
    s2 = p_session(dict(BASE, DevilForever_ProfilesDB=snap_store))
    for command in ("save B", "restore B", "delete B yes"):
        eq(has_line(dfp(s2, command), "안 함"), True, "refused: " + command)
    eq(s2.sv("DevilForever_ProfilesDB"), snap_store, "snapshot of an unknown schema unchanged")
    s3 = p_session(dict(BASE, DevilForever_ProfilesDB="text"))
    eq((s3.sv("DevilForever_ProfilesDB"), has_line(dfp(s3, "save B"), "안 함")), ("text", True), "wrong type kept")


@case
def profiles_t16_wrong_type_entry():
    store = {"schema": 1, "snapshots": {"A": {"schema": 1, "name": "A", "common": {
        "PPlainDB": {"folder": "PPlain", "restore": "whole", "data": "not a table", "registryVersion": "1.0"},
        "PKeysDB": {"folder": "PKeys", "restore": "keys", "keys": ["settings"], "data": {"settings": {"a": 5}},
                    "registryVersion": "1.0"}}, "class": {"WARRIOR": "bad"}}}}
    s = p_session(dict(BASE, DevilForever_ProfilesDB=store))
    s2 = restored(s, "restore A")
    eq(s2.sv("PPlainDB"), BASE["PPlainDB"], "untouched")
    eq(s2.sv("PKeysDB")["settings"], {"a": 5}, "the valid entry still restored")
    eq(has_line(last_lines(s2), "PPlainDB", "형식이 맞지 않음"), True, "reported")


@case
def profiles_t17_copy_data_safety():
    s = p_session()
    s.lua.execute("""
      local t = {a = 1, list = {1, 2}, fn = function() end, co = coroutine.create(function() end), u = newproxy()}
      t.self = t
      t.list.back = t
      t[{}] = 1
      TEST_copy, TEST_dropped = DevilForever_Core.CopyData(t)
    """)
    eq(to_py(s.g.TEST_copy), {"a": 1, "list": {1: 1, 2: 2}}, "plain data kept")
    eq(s.g.TEST_dropped, 6, "function, thread, userdata, two cycles and a table key left out")
    eq(s.errors(), [], "no errors")


@case
def presets_t18_register_validation():
    s = p_session()
    pr = s.core.Presets
    kept = pr.Register(pr, s.table({"name": "x", "edits": {"p.bar": {"rows": 11, "spacing": 2}, "nope": {"rows": 2}},
                                    "fragments": [{"folder": "NoSuch", "savedVariable": "A", "section": "root",
                                                   "addonVersion": "1", "version": 1, "values": {}},
                                                  {"folder": "PAce", "savedVariable": "PAceDB", "section": "middle",
                                                   "addonVersion": "1", "version": 1, "values": {}},
                                                  {"folder": "!DevilForever_Core", "savedVariable": "DevilForever_CoreDB",
                                                   "section": "root", "addonVersion": "1", "version": 1, "values": {}},
                                                  {"folder": "PAce", "savedVariable": "PAceDB", "section": "global",
                                                   "addonVersion": "2.0", "version": 1, "values": {"h": 1}}]}))
    eq(kept, 2, "spacing and one fragment kept")
    eq(to_py(pr.Get(pr, "x"))["edits"], {"p.bar": {"spacing": 2}}, "out-of-range and unknown frame dropped")
    eq(sum(1 for x in s.log() if x["subject"] == "Presets:x" and x["kind"] == "skip"), 5, "drops logged")


@case
def presets_t19_layer_order():
    s = p_session(presets=True)
    t, e = s.core.Theme, s.core.Edit
    t.RegisterSet(t, "devil", s.table({"spacing.default": 4}))
    eq(s.core.Presets.GetActive(s.core.Presets), ("uhd", True), "first choice without a screen API: uhd")
    eq((to_py(e.Get(e, "p.bar"))["rows"], to_py(e.Get(e, "p.bar"))["spacing"]), (5, 6), "preset over default and token")
    e.Set(e, "p.bar", "rows", 7)
    eq(to_py(e.Get(e, "p.bar"))["rows"], 7, "edit over preset")
    e.Clear(e, "p.bar", "rows")
    eq(to_py(e.Get(e, "p.bar"))["rows"], 5, "preset again")
    s.core.Presets.Restore(s.core.Presets, "qhd")
    eq((to_py(e.Get(e, "p.bar"))["rows"], to_py(e.Get(e, "p.bar"))["spacing"]), (4, 4),
       "qhd rows; spacing back to the token")
    s.g.DevilForever_CoreDB.preset.active = None
    eq(to_py(e.Get(e, "p.bar"))["rows"], 2, "registry default without a preset")


@case
def presets_t20_restore_clears_preset_frames_only():
    s = p_session(presets=True)
    e = s.core.Edit
    e.Set(e, "p.bar", "rows", 7)
    e.Set(e, "p.chat", "rows", 9)
    calls = []
    s.g.TEST_cb = lambda key, field, value: calls.append((key, field, to_py(value)))
    s.lua.execute("DevilForever_Core.Edit:RegisterCallback('test', function(k, f, v) TEST_cb(k, f, v) end)")
    ok, lines = s.core.Presets.Restore(s.core.Presets, "uhd")
    eq(ok, True, "restored")
    eq((to_py(e.GetEdits(e, "p.bar")), to_py(e.GetEdits(e, "p.chat"))), ({}, {"rows": 9}), "only preset frames cleared")
    eq(("p.bar", "rows", None) in calls and ("p.bar", "spacing", None) in calls, True, "listeners told")
    calls.clear()
    s.core.Presets.Restore(s.core.Presets, "qhd")
    eq(("p.chat", "rows", None) in calls and ("p.bar", "spacing", None) in calls, True,
       "listeners for old and new preset fields")
    eq(to_py(e.GetEdits(e, "p.chat")), {}, "qhd covers p.chat: its edit cleared")


FRAG_GLOBAL = {"folder": "PAce", "savedVariable": "PAceDB", "section": "global", "addonVersion": "2.0",
               "version": 1, "values": {"barHeight": 14}}
FRAG_PROFILE = {"folder": "PAce", "savedVariable": "PAceDB", "section": "profile", "addonVersion": "2.0",
                "version": 1, "values": {"width": 100}}
FRAG_PLAIN = {"folder": "PPlain", "savedVariable": "PPlainDB", "section": "root", "addonVersion": "1.0",
              "version": 1, "values": {"size": 3}}


@case
def presets_t21_fragment_fresh_acedb_global():
    s = p_session(presets=True, globals_={"TEST_FRAGMENTS": None})
    eq(s.sv("PAceDB")["profiles"]["Hero - Realm"], {"scale": 1}, "no fragments: defaults only")
    fresh = Session(registry="profiles", extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",))
    fresh.g.TEST_FRAGMENTS = fresh.table([FRAG_GLOBAL])
    fresh = fresh_reload(fresh)
    eq(fresh.sv("PAceDB")["global"], {"barHeight": 14}, "written into a fresh saved variable")
    eq(fresh.sv("DevilForever_CoreDB")["preset"]["fragments"]["uhd"], {"PAceDB@global": 1}, "recorded")
    eq(fresh.errors(), [], "no errors")
    kept = fresh_reload(Session(saved={"PAceDB": {"global": {"barHeight": 20}}}, registry="profiles",
                                extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",)),
                        [FRAG_GLOBAL])
    eq(kept.sv("PAceDB")["global"], {"barHeight": 20}, "existing saved variable kept")
    st = to_py(kept.core.Presets.GetFragmentStatus(kept.core.Presets))
    eq(st["uhd|1"]["state"], "kept", "status says kept")
    eq("/dfp preset uhd" in st["uhd|1"]["message"], True, "status names the command")


def fresh_reload(s, fragments=None):
    """Runs the preset fixture again with TEST_FRAGMENTS set, then boots."""
    if fragments is not None:
        s.g.TEST_FRAGMENTS = s.table(fragments)
    s.run_file(os.path.join(FIXTURES, "Presets_Test.lua"))
    return s.boot(after=P_ADDONS)


@case
def presets_t22_fragment_restore_and_version():
    saved = {"PAceDB": {"global": {"barHeight": 20, "other": 1}}}
    s = fresh_reload(Session(saved=saved, registry="profiles", extra_files=("Defaults_Profiles.lua",),
                             preset_files=("Presets_Test.lua",)), [FRAG_GLOBAL])
    lines = dfp(s, "preset uhd")
    eq(has_line(lines, "PAce", "/dfp go"), True, "reload asked for addon values")
    dfp(s, "go")
    s2 = fresh_reload(Session(saved=carry(s), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                              preset_files=("Presets_Test.lua",)), [FRAG_GLOBAL])
    eq(s2.sv("PAceDB")["global"], {"barHeight": 14, "other": 1}, "listed keys written, others kept")
    dfp(s2, "preset uhd")
    dfp(s2, "go")
    s3 = Session(saved=carry(s2, {"PAceDB": saved["PAceDB"]}), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                 preset_files=("Presets_Test.lua",), globals_={"TEST_meta": {"PAce": {"Version": "2.5"}}})
    s3 = fresh_reload(s3, [FRAG_GLOBAL])
    eq(s3.sv("PAceDB")["global"], {"barHeight": 20, "other": 1}, "version mismatch: skipped")
    eq(has_line(list(to_py(s3.g.TEST_prints).values()), "PAce", "건너뜀", "2.5"), True, "reported")


@case
def presets_t23_fragment_plain_fresh_at_world():
    s = Session(registry="profiles", extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",))
    s.g.TEST_FRAGMENTS = s.table([FRAG_PLAIN])
    s.run_file(os.path.join(FIXTURES, "Presets_Test.lua"))
    s.self_fill("PPlain", "PPlainDB", {"own": 1})
    s.boot(after=P_ADDONS, login=False)
    s.fire("PLAYER_LOGIN")
    eq(s.sv("PPlainDB"), {"own": 1}, "not written before the world entry")
    s.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s.sv("PPlainDB"), {"own": 1, "size": 3}, "written at the first PLAYER_ENTERING_WORLD")


@case
def presets_t24_defaults_then_fragment():
    s = fresh_reload(Session(registry="profiles", extra_files=("Defaults_Profiles.lua",),
                             preset_files=("Presets_Test.lua",)), [FRAG_PROFILE])
    eq(s.sv("PAceDB")["profiles"]["Hero - Realm"], {"scale": 1, "width": 100}, "new profile gets both")
    eq(s.status("PAce")["targets"]["PAceDB"]["state"], "applied", "Defaults state applied")
    eq(s.sv("DevilForever_CoreDB")["preset"]["fragments"]["uhd"], {"PAceDB@profile:Hero - Realm": 1}, "recorded")


SPEC_DB = """
TEST_spec_calls = {}
local function rec(...) local t = {...} TEST_spec_calls[#TEST_spec_calls + 1] = table.concat(t, ",") end
local db = {sv = PClassDB, current = "Warrior"}
if TEST_with_lds then
  function db:SetDualSpecEnabled(on) rec("enable", tostring(on)) end
  function db:SetDualSpecProfile(p, g) rec("set", p, g) end
  function db:GetDualSpecProfile(g) return self.current end
end
function db:GetCurrentProfile() return self.current end
function db:SetProfile(p) rec("profile", p) self.current = p end
function db:CopyProfile(p) rec("copy", p) end
TEST_libs['AceDB-3.0'] = {db_registry = {[db] = true}}
TEST_libs['LibDualSpec-1.0'] = {currentSpec = 1}
"""


@case
def spec_t25_link_and_new():
    s = p_session(dict(BASE, PClassDB=dict(CLASS_DB, profiles={"Warrior": {"a": 1}})), globals_={"TEST_with_lds": True})
    s.lua.execute(SPEC_DB)
    dfp(s, "spec link")
    eq(list(to_py(s.g.TEST_spec_calls).values()), ["enable,true", "set,Warrior,1"], "link calls")
    s.lua.execute("TEST_spec_calls = {}")
    lines = dfp(s, "spec new")
    eq(list(to_py(s.g.TEST_spec_calls).values()),
       ["profile,Warrior (2)", "copy,Warrior", "profile,Warrior", "enable,true", "set,Warrior,1", "set,Warrior (2),2"],
       "new: copy for the other group")
    eq(has_line(lines, "2번 특성 = Warrior (2)"), True, "reported")
    s2 = p_session(dict(BASE, PClassDB=CLASS_DB))
    s2.lua.execute(SPEC_DB)
    eq(has_line(dfp(s2, "spec link"), "지원 없음"), True, "no LibDualSpec: message")
    eq(list(to_py(s2.g.TEST_spec_calls).values()), [], "nothing called")


FORBIDDEN = ("SetBinding", "SaveBindings", "LoadBindings", "SetCVar", "C_CVar", "CreateMacro", "EditMacro",
             "DeleteMacro", "ChatFrame_AddMessageGroup", "ChatFrame_RemoveMessageGroup", "SetOverrideBinding")

FAKE_PM = """
TEST_pm = {}
local function api(kind)
  return {
    IsAvailable = function() return true end,
    GetProfileNames = function() return {"K"} end,
    GetProfile = function() return nil end,
    SaveProfile = function(_, n) TEST_pm[#TEST_pm + 1] = kind .. ".save " .. n return true, n end,
    UpdateProfile = function(_, n) TEST_pm[#TEST_pm + 1] = kind .. ".update " .. n return true, n end,
    LoadProfile = function(_, n) TEST_pm[#TEST_pm + 1] = kind .. ".load " .. n return true end,
  }
end
ProfileManager = {Keybinds = api("keys"), GameSettings = api("game")}
"""


@case
def profiles_t26_no_bindings_cvars_chat_or_macros():
    for name in ("Core.lua", "Edit.lua", "Profiles.lua", "Presets.lua", "Spec.lua", "Commands.lua"):
        with open(os.path.join(CORE_DIR, name), encoding="utf-8") as fh:
            text = fh.read()
        for word in FORBIDDEN:
            eq(word in text, False, "%s calls no %s" % (name, word))
    s1 = Session(saved=BASE, registry="profiles", extra_files=("Defaults_Profiles.lua",))
    s1.lua.execute(FAKE_PM)
    s1.boot(after=P_ADDONS)
    dfp(s1, "save A")
    dfp(s1, "go")
    s2 = Session(saved=carry(s1), registry="profiles", extra_files=("Defaults_Profiles.lua",))
    s2.lua.execute(FAKE_PM)
    s2.boot(after=P_ADDONS)
    dfp(s2, "restore A")
    dfp(s2, "keys list")
    dfp(s2, "go")
    s3r = Session(saved=carry(s2, {"PPlainDB": {"x": 9}}), registry="profiles", extra_files=("Defaults_Profiles.lua",))
    s3r.lua.execute(FAKE_PM)
    s3r.boot(after=P_ADDONS)
    eq(s3r.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "the restore ran in this session")
    eq(list(to_py(s1.g.TEST_pm).values()) + list(to_py(s2.g.TEST_pm).values()) + list(to_py(s3r.g.TEST_pm).values()),
       [], "no PM call in boot/save/restore (restore load included)")
    dfp(s2, "keys load K")
    eq(list(to_py(s2.g.TEST_pm).values()), ["keys.load K"], "one call on /dfp keys load")
    dfp(s2, "game save G")
    eq(list(to_py(s2.g.TEST_pm).values())[-1], "game.save G", "game settings pass through")
    s3 = p_session()
    eq(has_line(dfp(s3, "keys load K"), "ProfileManager 가 켜져 있지 않음"), True, "PM absent: message")


@case
def presets_t27_first_run_pick():
    def pick(height, presets=True):
        s = Session(registry="profiles", extra_files=("Defaults_Profiles.lua",),
                    preset_files=("Presets_Test.lua",) if presets else ())
        if height:
            s.lua.execute("GetPhysicalScreenSize = function() return %d, %d end" % (height * 16 // 9, height))
        s.boot(after=P_ADDONS)
        return s.sv("DevilForever_CoreDB")["preset"].get("active")
    eq(pick(1440), "qhd", "1440 -> qhd")
    eq(pick(2160), "uhd", "2160 -> uhd")
    eq(pick(1080), "uhd", "fhd not registered -> uhd")
    eq(pick(None), "uhd", "no screen API -> uhd")
    eq(pick(1440, presets=False), None, "none registered -> no preset")
    kept = Session(saved={"DevilForever_CoreDB": {"preset": {"active": "uhd"}}}, registry="profiles",
                   extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",))
    kept.lua.execute("GetPhysicalScreenSize = function() return 2560, 1440 end")
    kept.boot(after=P_ADDONS)
    eq(kept.sv("DevilForever_CoreDB")["preset"]["active"], "uhd", "a stored choice is kept")


@case
def genregistry_t28_restore_options():
    gen = load_genregistry()

    def entries():
        return {"Dominos": {"savedVariables": [{"name": "DominosDB", "scope": "account", "split": "common"},
                                               {"name": "OtherDB", "scope": "account", "split": "common"}],
                            "frames": [], "editable": [], "bundle": "individual", "defaults": None}}
    good = entries()
    gen.apply_extra(good, {"addons": {"Dominos": {"saved_variables": {
        "DominosDB": {"split": "class", "restore": "profile", "shape": "acedb"},
        "OtherDB": {"restore": "keys", "shape": "plain", "keys": ["__profiles"]}}}}})
    svs = {sv["name"]: sv for sv in good["Dominos"]["savedVariables"]}
    eq(svs["DominosDB"], {"name": "DominosDB", "scope": "account", "split": "class", "restore": "profile",
                          "shape": "acedb"}, "class entry")
    eq(svs["OtherDB"]["keys"], ["__profiles"], "keys list")
    plain = entries()
    gen.apply_extra(plain, {"addons": {"Dominos": {"saved_variables": {"OtherDB": {"split": "common"}}}}})
    eq("restore" in plain["Dominos"]["savedVariables"][1], False, "no restore written when the extras give none")
    bad = [
        {"DominosDB": {"split": "class"}},
        {"DominosDB": {"split": "class", "restore": "whole", "shape": "acedb"}},
        {"DominosDB": {"split": "class", "restore": "profile", "shape": "plain"}},
        {"DominosDB": {"restore": "profile", "shape": "acedb"}},
        {"DominosDB": {"restore": "keys", "shape": "plain"}},
        {"DominosDB": {"restore": "keys", "shape": "plain", "keys": []}},
        {"DominosDB": {"restore": "keys", "shape": "plain", "keys": "__profiles"}},
        {"DominosDB": {"restore": "whole", "shape": "plain", "keys": ["a"]}},
        {"DominosDB": {"restore": "whole"}},
        {"DominosDB": {"restore": "all", "shape": "plain"}},
        {"DominosDB": {"shape": "json"}},
        {"DominosDB": {"split": "common", "mode": "x"}},
    ]
    for opts in bad:
        try:
            gen.apply_extra(entries(), {"addons": {"Dominos": {"saved_variables": opts}}})
        except gen.RegistryError:
            continue
        raise AssertionError("options accepted: %r" % (opts,))



# Review fixes (TRIAGE_phase20) -------------------------------------------------------

@case
def profiles_fix_request_waits_for_go():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    s3 = p_session(carry(s2, {"PPlainDB": {"x": 9}}))
    eq(s3.sv("PPlainDB"), {"x": 9}, "a request without /dfp go is not used on reload")
    eq(s3.sv("DevilForever_ProfilesDB")["pending"]["armed"], False, "it is kept, not armed")
    eq(has_line(list(to_py(s3.g.TEST_prints).values()), "/dfp go 안 함"), True, "reported at login")
    dfp(s3, "go")
    s4 = p_session(carry(s3, {"PPlainDB": {"x": 9}}))
    eq(s4.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "applied after /dfp go")


@case
def profiles_fix_player_key_unknown_fallback():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    dfp(s2, "go")
    nokey = {"name": ""}
    s3 = p_session(carry(s2, {"PPlainDB": {"x": 9}}), player=nokey)
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "key unknown, armed seconds ago: applied with stored keys")
    eq(has_line(last_lines(s3), "확인하지 못함"), True, "login check could not confirm: reported")
    s4 = Session(saved=carry(s2, {"PPlainDB": {"x": 9}}), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                 player=nokey).boot(after=P_ADDONS, login=False)
    s4.g.TEST_player.name = "Alt"
    s4.fire("PLAYER_LOGIN")
    s4.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(has_line(last_lines(s4), "경고", "Hero - Realm", "Alt - Realm", "/dfp restore __before-restore"), True,
       "mismatch at login: loud line with the undo command")
    s5 = p_session(carry(s2, {"PPlainDB": {"x": 9}}), player=nokey, globals_={"TEST_time": 1000 + 121})
    eq(s5.sv("PPlainDB"), {"x": 9}, "key unknown and older than 120 s: dropped")
    eq(has_line(last_lines(s5), "요청 버림"), True, "reported")


@case
def profiles_fix_restored_sv_not_fresh_for_fragments():
    s1 = Session(saved=BASE, registry="profiles", extra_files=("Defaults_Profiles.lua",),
                 preset_files=("Presets_Test.lua",))
    s1 = fresh_reload(s1, [FRAG_PLAIN])
    eq(s1.sv("PPlainDB"), BASE["PPlainDB"], "existing SV: fragment not written")
    dfp(s1, "save A")
    dfp(s1, "go")
    s2 = fresh_reload(Session(saved=carry(s1), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                              preset_files=("Presets_Test.lua",)), [FRAG_PLAIN])
    dfp(s2, "restore A")
    dfp(s2, "go")
    s3 = fresh_reload(Session(saved=carry(s2, {"PPlainDB": None}), registry="profiles",
                              extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",)), [FRAG_PLAIN])
    eq(s3.sv("PPlainDB"), BASE["PPlainDB"], "restored values not overwritten by a fresh-mode fragment")
    eq(s3.core.Profiles.WasFresh(s3.core.Profiles, "PPlainDB"), False, "written by the restore: not fresh")


@case
def profiles_fix_undo_of_undo_keeps_unwritten_entries():
    s2 = saved_with(p_session(BASE))
    s3 = restored(s2, "restore A", {"PPlainDB": {"x": 7}, "PAceDB": {"profiles": {"p": {"v": 7}}}})
    undo1 = snapshot(s3, "__before-restore")
    s4 = restored(s3, "restore __before-restore only PPlain")
    undo2 = snapshot(s4, "__before-restore")
    eq(undo2["common"]["PPlainDB"]["data"], {"x": 1, "nested": {"y": 2}}, "written SV: state before this restore")
    eq((undo2["common"]["PAceDB"]["data"], undo2["common"]["PAceDB"]["carried"]),
       (undo1["common"]["PAceDB"]["data"], True), "entry not written now kept from the previous slot")
    s5 = restored(s4, "restore __before-restore only PAce")
    eq(s5.sv("PAceDB"), {"profiles": {"p": {"v": 7}}}, "the kept entry can still be restored")
    s6 = restored(saved_with(p_session(BASE)), "restore A only PPlain")
    eq(sorted(snapshot(s6, "__before-restore")["common"]), ["PPlainDB"], "from a user snapshot: one-slot rule")


@case
def profiles_fix_class_restore_other_characters_own_profile():
    db = {"profileKeys": {"Hero - Realm": "Hero - Realm", "Sage - Realm": "Sage - Realm", "Ally - Realm": "Warrior"},
          "profiles": {"Hero - Realm": {"a": 1}, "Sage - Realm": {"s": 1}, "Warrior": {"w": 1}}}
    s2 = saved_with(p_session(dict(BASE, PClassDB=db)))
    sage = {"name": "Sage"}
    changed = dict(db, profiles={"Hero - Realm": {"a": 9}, "Sage - Realm": {"s": 9}, "Warrior": {"w": 1}})
    s3 = p_session(carry(s2, {"PClassDB": changed}), player=sage)
    s4 = restored(s3, "restore A class", {"PClassDB": changed}, player=sage)
    out = s4.sv("PClassDB")
    eq(out["profiles"]["Hero - Realm"], {"a": 9}, "Hero's own profile untouched")
    eq(out["profiles"]["Sage - Realm"], {"a": 1}, "saved values written to the restoring character's profile")
    eq(out["profileKeys"], {"Hero - Realm": "Hero - Realm", "Sage - Realm": "Sage - Realm", "Ally - Realm": "Warrior"},
       "this character points to its own profile")
    eq(has_line(last_lines(s4), "Hero - Realm", "Sage - Realm", "다른 캐릭터"), True, "rename reported")
    shared = dict(db, profileKeys={"Hero - Realm": "Warrior", "Ally - Realm": "Warrior"},
                  profiles={"Warrior": {"w": 1}})
    t2 = saved_with(p_session(dict(BASE, PClassDB=shared)))
    t3 = restored(t2, "restore A class", {"PClassDB": dict(shared, profiles={"Warrior": {"w": 9}})})
    out3 = t3.sv("PClassDB")
    eq((out3["profiles"]["Warrior"], out3["profiles"]["Hero - Realm"], out3["profileKeys"]["Hero - Realm"]),
       ({"w": 9}, {"w": 1}, "Hero - Realm"), "a profile another character uses is never written, even a shared one")


@case
def profiles_fix_suppress_after_version_and_keys_intersect():
    store = {"schema": 1, "snapshots": {"A": {"schema": 1, "name": "A", "common": {
        "PAceDB": {"folder": "PAce", "restore": "whole", "data": {"x": 1}, "registryVersion": "1.9"},
        "PKeysDB": {"folder": "PKeys", "restore": "keys", "keys": ["settings", "gone"],
                    "data": {"settings": {"a": 5}, "gone": 1}, "registryVersion": "1.0"}}, "class": {}}}}
    s = p_session(dict(BASE, DevilForever_ProfilesDB=store))
    s2 = restored(s, "restore A")
    eq(s2.status("PAce").get("suppressed"), None, "version mismatch: Defaults of that folder not suppressed")
    eq(has_line(last_lines(s2), "PAceDB", "1.9", "2.0"), True, "mismatch reported")
    eq(s2.sv("PKeysDB"), {"settings": {"a": 5}, "history": {1: 1, 2: 2, 3: 3}}, "only keys the registry lists written")
    eq(has_line(last_lines(s2), "PKeysDB", "등록 표에 없는 키 1개"), True, "dropped key reported")


@case
def profiles_fix_command_arguments():
    s2 = saved_with(p_session(BASE))
    eq(has_line(dfp(s2, "restore A only NoSuch"), "등록 표에 없는 폴더"), True, "unknown folder refused before reload")
    eq(s2.sv("DevilForever_ProfilesDB").get("pending"), None, "nothing pending")
    eq(has_line(dfp(s2, "restore A common only PPlain extra"), "알 수 없는 말: extra"), True, "extra word refused")
    eq(has_line(dfp(s2, "go now"), "알 수 없는 말: now"), True, "extra word after go refused")
    dfp(s2, "restore A COMMON ONLY PPlain")
    eq(s2.sv("DevilForever_ProfilesDB")["pending"]["parts"]["label"], "common", "part word in any case")
    dfp(s2, "cancel")
    dfp(s2, "delete A YES")
    eq(snapshot(s2, "A"), None, "YES in capitals deletes")


@case
def presets_fix_unfinished_and_kept_lines():
    saved = {"PAceDB": {"global": {"barHeight": 20}}}
    s = fresh_reload(Session(saved=saved, registry="profiles", extra_files=("Defaults_Profiles.lua",),
                             preset_files=("Presets_Test.lua",)), [FRAG_GLOBAL])
    eq(has_line(list(to_py(s.g.TEST_prints).values()), "uhd preset 애드온 값 1개는 쓰지 않음"), True,
       "kept fragment: one chat line at login")
    dfp(s, "preset uhd")
    dfp(s, "go")
    s2 = fresh_reload(Session(saved=carry(s), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                              preset_files=("Presets_Test.lua",), globals_={"TEST_time": 1000 + 601}), [FRAG_GLOBAL])
    prints2 = list(to_py(s2.g.TEST_prints).values())
    eq(has_line(prints2, "uhd preset 의 애드온 값이 아직 쓰이지 않음"), True, "timed-out preset switch reported")
    eq(has_line(prints2, "uhd preset 애드온 값 1개는 쓰지 않음"), False, "unchanged kept set: not printed again")
    dfp(s2, "preset uhd")
    dfp(s2, "go")
    s3 = fresh_reload(Session(saved=carry(s2), registry="profiles", extra_files=("Defaults_Profiles.lua",),
                              preset_files=("Presets_Test.lua",), globals_={"TEST_time": 1000 + 601}), [FRAG_GLOBAL])
    eq((s3.sv("PAceDB")["global"]["barHeight"], s3.sv("DevilForever_CoreDB")["preset"].get("unfinished")), (14, None),
       "finished after /dfp preset again and /dfp go")



# Re-check 1 fixes ---------------------------------------------------------------------

@case
def profiles_fix2_key_unknown_alt_after_interrupted_reload():
    # Hero arms a restore; the reload is interrupted and Alt logs in within 120 s
    # while the player name is still unknown at Core's load.
    saved = dict(BASE, PCharDB={"hero": 1}, PClassDB=CLASS_DB)
    s2 = saved_with(p_session(saved))
    dfp(s2, "restore A")
    dfp(s2, "go")
    alt_data = carry(s2, {"PCharDB": {"alt": 1}, "PPlainDB": {"x": 9},
                          "PClassDB": dict(CLASS_DB, profiles={"Warrior": {"a": 9}})})
    s3 = Session(saved=alt_data, registry="profiles", extra_files=("Defaults_Profiles.lua",),
                 player={"name": ""}, globals_={"TEST_time": 1000 + 60}).boot(after=P_ADDONS, login=False)
    s3.g.TEST_player.name = "Alt"
    s3.fire("PLAYER_LOGIN")
    s3.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(s3.sv("PCharDB"), {"alt": 1}, "per-character SV of Alt untouched")
    eq(s3.sv("PClassDB")["profiles"]["Warrior"], {"a": 9}, "class part untouched")
    eq(s3.sv("PPlainDB"), {"x": 1, "nested": {"y": 2}}, "account-wide common entry written")
    lines = last_lines(s3)
    eq(has_line(lines, "PCharDB", "캐릭터를 모름") and has_line(lines, "PClassDB", "캐릭터를 모름"), True, "skips reported")
    eq(has_line(lines, "경고", "Alt - Realm"), True, "mismatch warning")
    undo = snapshot(s3, "__before-restore")
    eq((undo["savedBy"]["char"], sorted(undo["common"])), ("unknown", ["PAceDB", "PKeysDB", "PPlainDB"]),
       "undo labelled unknown, account-wide entries only")
    s4 = restored(s3, "restore __before-restore", player={"name": "Alt"}, globals_={"TEST_time": 1000 + 60})
    eq(s4.sv("PPlainDB"), {"x": 9}, "undo works on the character that runs it")


@case
def profiles_fix2_save_refused_with_unknown_key():
    s1 = p_session(BASE)
    dfp(s1, "save A")
    dfp(s1, "go")
    s2 = p_session(carry(s1), player={"name": ""})
    eq(snapshot(s2, "A"), None, "save not run while the character is unknown")
    eq(has_line(last_lines(s2), "save A", "요청 버림"), True, "reported")


@case
def profiles_fix2_shared_character_named_profile():
    # Cara uses Sage's character-named profile; Sage restores Hero's snapshot.
    db = {"profileKeys": {"Hero - Realm": "Hero - Realm", "Sage - Realm": "Sage - Realm",
                          "Cara - Realm": "Sage - Realm"},
          "profiles": {"Hero - Realm": {"a": 1}, "Sage - Realm": {"s": 1}}}
    s2 = saved_with(p_session(dict(BASE, PClassDB=db)))
    sage = {"name": "Sage"}
    s3 = p_session(carry(s2), player=sage)
    s4 = restored(s3, "restore A class", player=sage)
    out = s4.sv("PClassDB")
    eq((out["profiles"]["Hero - Realm"], out["profiles"]["Sage - Realm"]), ({"a": 1}, {"s": 1}),
       "neither Hero's nor Cara's live profile written")
    eq((out["profiles"]["Sage - Realm (2)"], out["profileKeys"]["Sage - Realm"], out["profileKeys"]["Cara - Realm"]),
       ({"a": 1}, "Sage - Realm (2)", "Sage - Realm"), "free name chosen; Cara still on hers")
    eq(has_line(last_lines(s4), "Hero - Realm", "Sage - Realm (2)"), True, "rename reported")


@case
def profiles_fix2_other_characters_lds_profile():
    # Hero's dual-spec group 2 uses "Hero Heal" (only through LibDualSpec).
    db = {"profileKeys": {"Hero - Realm": "Hero - Realm"},
          "profiles": {"Hero - Realm": {"a": 1}, "Hero Heal": {"h": 1}},
          "namespaces": {"LibDualSpec-1.0": {"char": {"Hero - Realm": {"enabled": True, 1: "Hero - Realm",
                                                                        2: "Hero Heal"}}}}}
    s2 = saved_with(p_session(dict(BASE, PClassDB=db)))
    sage = {"name": "Sage"}
    changed = dict(db, profiles={"Hero - Realm": {"a": 9}, "Hero Heal": {"h": 9}})
    s3 = p_session(carry(s2, {"PClassDB": changed}), player=sage)
    s4 = restored(s3, "restore A class", {"PClassDB": changed}, player=sage)
    out = s4.sv("PClassDB")
    eq((out["profiles"]["Hero - Realm"], out["profiles"]["Hero Heal"]), ({"a": 9}, {"h": 9}),
       "Hero's profiles (profileKeys and LibDualSpec) untouched")
    eq((out["profiles"]["Sage - Realm"], out["profiles"]["Sage - Realm (2)"]), ({"a": 1}, {"h": 1}),
       "two names go to two distinct free targets")
    lds = out["namespaces"]["LibDualSpec-1.0"]["char"]
    eq((lds["Sage - Realm"][1], lds["Sage - Realm"][2], lds["Hero - Realm"][2]),
       ("Sage - Realm", "Sage - Realm (2)", "Hero Heal"), "Sage's groups point to the copies; Hero's mapping kept")


@case
def profiles_fix2_unarmed_notice_and_unfinished_cleared():
    s2 = saved_with(p_session(BASE))
    dfp(s2, "restore A")
    before = s2.sv("DevilForever_ProfilesDB")["last"]
    alt = p_session(carry(s2), player={"name": "Alt"})
    eq(has_line(list(to_py(alt.g.TEST_prints).values()), "/dfp go 안 함"), False, "other character: no notice")
    hero = p_session(carry(s2))
    eq(has_line(list(to_py(hero.g.TEST_prints).values()), "/dfp go 안 함"), True, "requesting character: notice")
    eq(hero.sv("DevilForever_ProfilesDB")["last"], before, "last result not replaced by the notice")
    p = fresh_reload(Session(saved={"PAceDB": {"global": {"x": 1}}}, registry="profiles",
                             extra_files=("Defaults_Profiles.lua",), preset_files=("Presets_Test.lua",)), [FRAG_GLOBAL])
    dfp(p, "preset uhd")
    eq(p.sv("DevilForever_CoreDB")["preset"]["unfinished"], "uhd", "set by the switch")
    dfp(p, "cancel")
    eq(p.sv("DevilForever_CoreDB")["preset"].get("unfinished"), None, "cleared by /dfp cancel of the request")
    dfp(p, "preset uhd")
    dfp(p, "cancel")
    dfp(p, "preset qhd")
    eq(p.sv("DevilForever_CoreDB")["preset"].get("unfinished"), None, "cleared by a later preset restore")


# Alternate themes (Phase 22): registration, switching, snapshots, /dfp theme ----

def theme_listener(s):
    calls = []
    s.g.TEST_cb = lambda new, old: calls.append((new, old))
    s.lua.execute("DevilForever_Core.Theme:RegisterCallback('test', function(n, o) TEST_cb(n, o) end)")
    return calls


ALT_TOKENS = {"color.text.normal": [1, 0, 0, 1], "font.normal": "B.ttf", "spacing.default": 9}
BASE_TOKENS = {"color.text.normal": [1, 1, 1, 1], "font.normal": "A.ttf", "font.size.normal": 12,
               "spacing.default": 4}


@case
def theme22_register_names_and_fallback_reported():
    s = Session().boot()
    t = s.core.Theme
    every = {name: "x" for name in to_py(t.ListTokens(t)).values()}
    eq(len(every), 20, "twenty token names")
    eq(t.RegisterSet(t, "full", s.table({k: ([0, 0, 0, 1] if k.startswith("color.") else
                                             (2 if t.TOKENS[k] in ("size", "number") else "p"))
                                         for k in every})), 20, "a complete set keeps every token")
    eq([x for x in s.log() if x["subject"] == "Theme:full"], [], "complete set: nothing reported")
    eq(t.RegisterSet(t, "devil", s.table(BASE_TOKENS)), 4, "base values")
    eq(t.RegisterSet(t, "alt", s.table(ALT_TOKENS)), 3, "partial set kept")
    rows = [x for x in s.log() if x["subject"] == "Theme:alt"]
    eq((len(rows), rows[0]["kind"], rows[0]["message"].startswith("17 tokens not set, base set values used: ")),
       (1, "info", True), "missing tokens reported once")
    eq([x for x in s.log() if x["subject"] == "Theme:devil"], [], "base set: no fallback report")
    for bad in ("", "two words", 3):
        eq(t.RegisterSet(t, bad, s.table({})), 0, "bad name refused: %r" % (bad,))
    eq(t.RegisterSet(t, "ok", 5), 0, "values must be a table")
    eq(sum(1 for x in s.log() if x["kind"] == "error" and x["subject"] == "Theme"), 4, "bad calls logged")
    eq("two words" in to_py(t.ListSets(t)).values(), False, "not registered")
    t.SetActiveSet(t, "alt")
    eq((t.Get(t, "font.normal"), t.Get(t, "font.size.normal")), ("B.ttf", 12), "own token, then base fallback")


@case
def theme22_base_replacement_notifies_active_alternate():
    s = Session().boot()
    t = s.core.Theme
    t.RegisterSet(t, "devil", s.table(BASE_TOKENS))
    t.RegisterSet(t, "alt", s.table(ALT_TOKENS))
    t.SetActiveSet(t, "alt")
    calls = theme_listener(s)
    t.RegisterSet(t, "devil", s.table(dict(BASE_TOKENS, **{"font.size.normal": 16})))
    eq(calls, [("alt", "alt")], "fallback values changed: listeners told with the active name")
    eq(t.Get(t, "font.size.normal"), 16, "new fallback value")
    t.RegisterSet(t, "other", s.table({}))
    eq(calls, [("alt", "alt")], "an inactive non-base set: no call")
    s.combat(True)
    t.RegisterSet(t, "devil", s.table(BASE_TOKENS))
    eq(calls, [("alt", "alt")], "held in combat")
    s.combat(False)
    eq(calls, [("alt", "alt"), ("alt", "alt")], "delivered after combat")


@case
def theme22_switch_persists_and_combat_waits():
    s = Session().boot()
    t = s.core.Theme
    t.RegisterSet(t, "devil", s.table(BASE_TOKENS))
    t.RegisterSet(t, "alt", s.table(ALT_TOKENS))
    calls = theme_listener(s)
    s.combat(True)
    eq(t.SetActiveSet(t, "alt"), (True, "queued"), "queued")
    eq((calls, s.sv("DevilForever_CoreDB")["theme"].get("active")), ([], None), "nothing called or saved in combat")
    s.combat(False)
    eq((calls, s.sv("DevilForever_CoreDB")["theme"]["active"]), ([("alt", "devil")], "alt"),
       "switched and saved after combat")
    eq(t.SetActiveSet(t, "nope"), (False, "unknown set"), "unknown name refused")
    eq((t.GetSet(t), s.sv("DevilForever_CoreDB")["theme"]["active"]), (("alt", None), "alt"), "refusal changes nothing")
    second = Session(saved={"DevilForever_CoreDB": s.sv("DevilForever_CoreDB")}).boot(login=False)
    t2 = second.core.Theme
    t2.RegisterSet(t2, "alt", second.table(ALT_TOKENS))
    calls2 = theme_listener(second)
    second.fire("PLAYER_LOGIN")
    eq((t2.GetSet(t2)[0], calls2), ("alt", [("alt", "devil")]), "restored at login after a reload")
    third = Session(saved={"DevilForever_CoreDB": s.sv("DevilForever_CoreDB")}).boot()
    t3 = third.core.Theme
    eq(t3.GetSet(t3)[0], "devil", "saved set not registered: base kept")
    eq(any("saved set alt is not registered" in x["message"] for x in third.log()), True, "and logged")
    eq(t3.SetActiveSet(t3, "devil"), (True, "unchanged"), "choosing the base")
    eq(third.sv("DevilForever_CoreDB")["theme"]["active"], "devil", "the choice is saved even when unchanged")
    third.combat(True)
    t3.RegisterSet(t3, "alt", third.table(ALT_TOKENS))
    t3.SetActiveSet(t3, "alt")
    t3.SetActiveSet(t3, "devil")
    third.combat(False)
    eq((t3.GetSet(t3), third.sv("DevilForever_CoreDB")["theme"]["active"]), (("devil", None), "devil"),
       "last call in combat wins")


@case
def theme22_edits_and_presets_overlay_new_tokens():
    s = p_session(presets=True)
    t, e = s.core.Theme, s.core.Edit
    t.RegisterSet(t, "devil", s.table(BASE_TOKENS))
    t.RegisterSet(t, "alt", s.table(ALT_TOKENS))
    e.Set(e, "p.bar", "font", s.table({"size": 20}))
    before = to_py(e.Get(e, "p.bar"))
    eq((before["color"], before["font"], before["spacing"]), ({1: 1, 2: 1, 3: 1, 4: 1}, {"path": "A.ttf", "size": 20}, 6),
       "devil tokens under the preset and the edit")
    t.SetActiveSet(t, "alt")
    after = to_py(e.Get(e, "p.bar"))
    eq(after["color"], {1: 1, 2: 0, 3: 0, 4: 1}, "unedited field follows the new set")
    eq(after["font"], {"path": "B.ttf", "size": 20}, "edit still over the new token (font merged per key)")
    eq((after["spacing"], after["rows"]), (6, 5), "preset values still over the new tokens")


@case
def theme22_snapshot_carries_active_theme():
    s1 = p_session(BASE)
    t = s1.core.Theme
    t.RegisterSet(t, "alt", s1.table(ALT_TOKENS))
    eq(dfp(s1, "theme alt"), ["[DF 설정] 테마 alt 으로 바꿈"], "switched by command")
    s2 = saved_with(s1, login=False)
    s2.core.Theme.RegisterSet(s2.core.Theme, "alt", s2.table(ALT_TOKENS))
    s2.fire("PLAYER_LOGIN")
    s2.fire("PLAYER_ENTERING_WORLD", True, False)
    eq(snapshot(s2, "A")["core"]["theme"], "alt", "snapshot holds the active theme")
    eq(dfp(s2, "theme devil"), ["[DF 설정] 테마 devil 으로 바꿈"], "back to the base")
    s3 = restored(s2, "restore A", login=False)
    t3 = s3.core.Theme
    eq(s3.sv("DevilForever_CoreDB")["theme"]["active"], "alt", "restore wrote the saved theme")
    t3.RegisterSet(t3, "alt", s3.table(ALT_TOKENS))
    s3.fire("PLAYER_LOGIN")
    eq(t3.GetSet(t3)[0], "alt", "restored theme active after login")
    eq(has_line(s2.core.Profiles.Describe(s2.core.Profiles, "A").values(), "테마"), True, "dry run names the theme")


@case
def theme22_command_list_switch_and_refusals():
    s = p_session(BASE)
    t = s.core.Theme
    t.RegisterSet(t, "devil", s.table(BASE_TOKENS))
    t.RegisterSet(t, "alt", s.table(ALT_TOKENS))
    eq(dfp(s, "theme"), ["[DF 설정] 0 devil (지금)", "[DF 설정] alt — 빠진 토큰 17개는 devil 값"], "list")
    eq(has_line(dfp(s, "help"), "/dfp theme"), True, "help names the command")
    eq(dfp(s, "theme nope"), ["[DF 설정] 안 함: nope: 등록된 테마가 아님 — /dfp theme 로 목록"], "unknown refused")
    eq(dfp(s, "theme alt extra"), ["[DF 설정] 알 수 없는 말: extra — /dfp help"], "one name only")
    eq(t.GetSet(t)[0], "devil", "refusals change nothing")
    eq(dfp(s, "theme devil"), ["[DF 설정] 이미 devil 테마"], "already active")
    s.combat(True)
    eq(dfp(s, "theme alt"), ["[DF 설정] 안 함: 전투 중 — 바꾼 것 없음"], "refused in combat")
    s.combat(False)
    eq(t.GetSet(t)[0], "devil", "nothing waits after a refused command")
    dfp(s, "theme alt")
    eq((t.GetSet(t)[0], s.sv("DevilForever_CoreDB")["theme"]["active"]), ("alt", "alt"), "switched and saved")
    eq(has_line(dfp(s, "status"), "테마: alt"), True, "status shows the theme")
    eq(dfp(s, "theme")[1], "[DF 설정] alt (지금) — 빠진 토큰 17개는 devil 값", "marker moved")
    later = p_session(carry(s))
    eq(dfp(later, "theme"), ["[DF 설정] 0 devil (지금)",
                             "[DF 설정] 저장된 테마 alt 은 등록돼 있지 않음 — devil 사용"], "saved set missing")


@case
def theme_numbers_select_and_save_the_built_in_themes():
    s = p_session(BASE)
    t = s.core.Theme
    names = ["devil", "alliance", "horde", "human", "dwarf", "gnome", "nightelf",
             "orc", "tauren", "troll", "undead", "skyborne", "skyborne-horde"]
    for name in reversed(names):
        t.RegisterSet(t, name, s.table(BASE_TOKENS))
    eq(t.GetSet(t)[0], "devil", "fresh default is theme zero")
    eq([line.removeprefix("[DF 설정] ").split(" — ", 1)[0].split(" (", 1)[0] for line in dfp(s, "theme")],
       [f"{number} {name}" for number, name in enumerate(names)], "fixed menu order")
    for number, name in enumerate(names):
        dfp(s, f"theme {number}")
        eq((t.GetSet(t)[0], s.sv("DevilForever_CoreDB")["theme"]["active"]), (name, name), "number selects and saves")
    eq(has_line(dfp(s, "theme 13"), "13", "등록된 테마가 아님"), True, "unknown number refused")
    eq(t.GetSet(t)[0], names[-1], "unknown number does not switch")
    s.combat(True)
    dfp(s, "theme 0")
    s.combat(False)
    eq(t.GetSet(t)[0], names[-1], "combat command does not queue a switch")
    dfp(s, "theme 0")
    eq(t.GetSet(t)[0], "devil", "zero returns to the default")


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

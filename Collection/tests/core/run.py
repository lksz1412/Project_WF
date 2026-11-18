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


class Session:
    """One simulated client session with Core loaded."""

    def __init__(self, saved=None, registry="fixture", extra_files=("Defaults_Example.lua",),
                 player=None, globals_=None):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.lua.globals()
        if player:
            for k, v in player.items():
                g.TEST_player[k] = v
        for name, value in (globals_ or {}).items():
            g[name] = value
        for name, value in (saved or {}).items():
            g[name] = self.table(value)
        self.ns = self.lua.table()
        for rel in toc_files():
            # Real defaults files name folders of the generated registry only.
            if rel.startswith("Defaults/") and registry == "fixture":
                continue
            if rel == "Registry.lua" and registry == "fixture":
                self.run_file(os.path.join(FIXTURES, "Registry_Test.lua"))
            else:
                self.run_file(os.path.join(CORE_DIR, rel))
            if rel == "Defaults.lua":
                for extra in extra_files:
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
        result = loadstring(src, ("@" + os.path.relpath(path, REPO)).encode())
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


@case
def defaults_acedb_profile_fill():
    saved = {"TestAceDB": {"profileKeys": {"Hero - Realm": "Main"},
                           "profiles": {"Main": {"scale": 2}, "Other": {"x": 1}}}}
    s = Session(saved=saved).boot(after=["TestAce"])
    db = s.sv("TestAceDB")
    eq(db["profiles"]["Main"], {"scale": 2, "bars": {"count": 8}}, "active profile filled, user value kept")
    eq(db["profiles"]["Other"], {"x": 1}, "other profile untouched")
    eq(db["namespaces"]["Module"]["profiles"]["Main"], {"on": False}, "namespace profile filled")
    eq(db["profileKeys"], {"Hero - Realm": "Main"}, "profileKeys untouched")
    applied = s.sv("DevilForever_CoreDB")["defaults"]["applied"]["TestAce"]
    eq(sorted(applied), ["TestAceDB/Module@profile:Main", "TestAceDB@profile:Main"], "target keys")


@case
def defaults_acedb_new_character_uses_profile_rule():
    s = Session().boot(after=["TestAce"])
    db = s.sv("TestAceDB")
    eq(db["profiles"], {"Warrior": {"scale": 1, "bars": {"count": 8}}}, "profile named by $className")
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
    eq(set(s.sv("DevilForever_CoreDB")), {"schema", "defaults", "theme", "edits"}, "Core DB layout")


# Registry ---------------------------------------------------------------------

@case
def generated_registry_lookup():
    s = Session(registry="generated", extra_files=()).boot()
    c = s.core
    info = to_py(c.GetAddonInfo(c, "dominos"))
    eq(info["package"], "Dominos", "case-insensitive lookup")
    eq(list(info["savedVariables"].values()), [{"name": "DominosDB", "scope": "account", "split": "class"}], "SV")
    eq(info["defaults"], "Defaults/Dominos.lua", "defaults file named")
    prat = to_py(c.GetAddonInfo(c, "Prat-3.0"))
    scopes = {sv["name"]: sv["scope"] for sv in prat["savedVariables"].values()}
    eq(scopes, {"Prat3DB": "account", "Prat3CharDB": "character", "Prat3HighCPUPerCharDB": "character"}, "scopes")
    eq(to_py(c.GetAddonInfo(c, "!DevilForever_Core"))["bundle"], "required", "Core is required")
    eq(list(to_py(c.ListAddons(c)).values())[0], "!DevilForever_Core", "Core sorts first")
    eq(c.GetAddonInfo(c, "NoSuchAddon"), None, "unknown folder")
    eq(list(to_py(c.GetFrameNames(c)).values()), list(to_py(c.GetFrameNames(c, "Dominos")).values()),
       "appearance frames are Dominos' only")
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
        "saved_variables": {"DominosDB": {"split": "class"}}}}})
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
    eq((st["state"], st["key"], st["written"]), ("applied", "DominosDB@profile:Custom", 0), "profileKeys profile")
    other = Session(registry="generated", extra_files=(), player={"className": "Mage", "class": "MAGE", "name": "Sage"},
                    saved={"DominosDB": db, "DevilForever_CoreDB": s.sv("DevilForever_CoreDB")}).boot(after=["Dominos"])
    eq(other.sv("DominosDB")["profiles"]["Mage"], {"showBindingText": True},
       "a new character of another class gets its class profile")


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

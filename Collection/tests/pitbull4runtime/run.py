"""Runtime-burden probes and behaviour checks for our PitBull4 fork and own addons.

Usage:  python3 -I Collection/tests/pitbull4runtime/run.py [--source DIR]

Each case loads one or a few fork files into a fresh Lua 5.1 runtime (lupa)
with stubbed client APIs, drives the same input several times and counts the
calls the code makes into the stubs (and the garbage it leaves). Numbers are
printed as "probe (stubbed)"; they measure the Lua work of our code, not the
game client. Behaviour checks compare what the code hands to the stubs
(texts, values, styles) for the same input. --source points the probes at
another copy of the PitBull4 folder (e.g. the previous version) to get the
"before" numbers; behaviour checks that need the new code are skipped there.
"""

import argparse
import os
import runpy
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
SOURCE = os.path.join(REPO, "Collection", "AddOns", "PitBull4")
NEW = True   # False when --source names another copy

# Counting stubs shared by every case: CALLS[name] counts calls of a stubbed API.
BASE_STUBS = r"""
CALLS = {}
function count(name) CALLS[name] = (CALLS[name] or 0) + 1 end
function reset_calls() CALLS = {} end
local function obj(kind)
  local o = {kind = kind, shown = true}
  return setmetatable(o, {__index = function(t, k)
    return function(self, ...)
      count(kind .. ":" .. k)
      local h = rawget(t, "on_" .. k)
      if h then return h(self, ...) end
      if type(k) == "string" and k:sub(1, 6) == "Create" then return obj(k:sub(7)) end
      if k == "GetFrameLevel" then return 1 end
    end
  end})
end
make_obj = obj
TIMERS = {}
C_Timer = {After = function(d, fn) TIMERS[#TIMERS + 1] = fn end,
           NewTicker = function(d, fn) local t = {fn = fn, cancelled = false}; function t:Cancel() self.cancelled = true end
             TICKERS[#TICKERS + 1] = t; return t end}
TICKERS = {}
function run_timers() local due = TIMERS; TIMERS = {}; for _, fn in ipairs(due) do fn() end; return #due end
function InCombatLockdown() return TEST_combat == true end
function UnitAffectingCombat() return TEST_combat == true end
function UnitIsFriend() return TEST_friend ~= false end
function UnitGUID(unit) count("UnitGUID:" .. tostring(unit)); return TEST_guids and TEST_guids[unit] end
wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
AnchorUtil = {FlowLayoutAxis = {Vertical = 1, Horizontal = 2}, FlowDirection = {Left = 1, Right = 2, Up = 3, Down = 4}}
"""


def runtime():
    L = lua51.LuaRuntime(unpack_returned_tuples=True)
    L.execute(BASE_STUBS)
    return L


def load(L, rel, *args):
    path = os.path.join(SOURCE, rel)
    with open(path, "rb") as fh:
        src = fh.read()
    fn = L.eval("loadstring")(src, ("@" + rel).encode())
    if isinstance(fn, tuple):
        fn, err = fn
        if fn is None:
            raise AssertionError("compile %s: %s" % (rel, err))
    return fn(*args)


def calls(L, prefix=""):
    t = L.globals().CALLS
    return sum(v for k, v in t.items() if str(k).startswith(prefix))


def garbage_kb(L, chunk):
    """KB allocated by Lua `chunk` (a function in the runtime) with the collector stopped."""
    return L.execute("""
      local f = ...
      collectgarbage("collect"); collectgarbage("stop")
      local before = collectgarbage("count")
      f()
      local after = collectgarbage("count")
      collectgarbage("restart")
      return after - before
    """, chunk)


CASES = []
RESULTS = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


def probe(name, **numbers):
    line = "probe (stubbed) %s: %s" % (name, ", ".join("%s=%s" % kv for kv in numbers.items()))
    RESULTS.append(line)
    print(line)


# Item 1 — Aura/Forever.lua native containers -----------------------------------

AURA_STUBS = r"""
TEST_guids = {target = "Creature-1"}
Aura = {db = {profile = {global = {colors = {
  caster = {my = {0, 1, 0, 1}, other = {1, 0, 0, 1}},
  type = {Poison = {0, 1, 0, 1}, Magic = {0, 0, 1, 1}, Disease = {.55, .15, 0, 1}, Curse = {5, 0, 5, 1},
          Enrage = {1, .55, 0, 1}, ["nil"] = {1, 0, 0, 1}}}}}},
  enabled = true, events = {}, UPDATE_ALL = 0}
function Aura:IsEnabled() return self.enabled end
function Aura:UpdateAll() self.UPDATE_ALL = self.UPDATE_ALL + 1 end
function Aura:RegisterEvent(event, method) self.events[event] = method or event end
function Aura:UnregisterEvent(event) self.events[event] = nil end
function Aura:OnEnable() self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAll"); self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAll") end
function Aura:OnDisable() end
function Aura:GetAuraIconSizes(cfg, width, spacing) return cfg.my_size, cfg.size end
function Aura:OnUpdate() Aura:UpdateNativeDebuffs(FRAME, DB) end
function Aura:UNIT_AURA() end
CONFIG_CALLBACKS = {}
local registry = {RegisterCallback = function(owner, event, fn) CONFIG_CALLBACKS[#CONFIG_CALLBACKS + 1] = {owner, event, fn} end}
function LibStub(name, silent) if name == "AceConfigRegistry-3.0" then return registry end end
function fire_config_change() for _, c in ipairs(CONFIG_CALLBACKS) do local fn = c[3]
  if type(fn) == "string" then c[1][fn](c[1], c[2], "PitBull4") else fn(c[2], "PitBull4") end end end
PitBull4 = {Compat = {IsForever = true, RegisterOptionalEvent = function(m, e, f) m:RegisterEvent(e, f) end},
  Utils = {SafeBoolean = function(v, d) if v == nil then return d end return v and true or false end,
           SafeGUID = function(v) if v == nil then return nil end return tostring(v) end,
           SafeString = function(v) if v == nil then return nil end return tostring(v) end},
  GetModule = function(_, name) return Aura end}
WATCH = nil
function CreateFrame(kind, name, parent, template)
  local o = make_obj(kind)
  if kind == "AuraContainer" then
    o.on_AddAuraGroup = function(self, key, filter, spec)
      for i = 1, 3 do local b = make_obj("Button"); spec.initializeFrame(b) end end
  elseif kind == "Frame" and not parent then
    rawset(o, "events", {})
    o.on_RegisterEvent = function(self, e) rawget(self, "events")[e] = true end
    o.on_SetScript = function(self, k, fn) self.script = fn end
    WATCH = o
  end
  o.on_CreateTexture = function(self) return make_obj("Texture") end
  o.on_CreateFontString = function(self) return make_obj("FontString") end
  o.on_GetFrameLevel = function() return 3 end
  return o
end
local texts = {count = {font = nil, size = 0.8, anchor = "BOTTOMRIGHT", offset_x = 0, offset_y = 0, color = {1, 1, 1, 1}},
               cooldown_text = {font = nil, size = 0.8, anchor = "TOP", offset_x = 0, offset_y = 0, color = {1, 1, 1, 1}}}
local border = {enabled = true, color_type = "type"}
DB = {enabled = true, enabled_debuffs = true, enabled_buffs = true, max_debuffs = 8, max_buffs = 8,
  zoom_aura = false, click_through = false,
  cooldown = {my_debuffs = true, other_debuffs = true, my_buffs = true, other_buffs = true},
  cooldown_text = {my_debuffs = false, other_debuffs = false, my_buffs = false, other_buffs = false},
  borders = {my_debuffs = {friend = border, enemy = border}, other_debuffs = {friend = border, enemy = border},
             my_buffs = {friend = border, enemy = border}, other_buffs = {friend = border, enemy = border}},
  texts = {my_debuffs = texts, other_debuffs = texts, my_buffs = texts, other_buffs = texts},
  layout = {debuff = {growth = "right_down", anchor = "BOTTOMLEFT", side = "BOTTOM", offset_x = 0, offset_y = 0,
                      width = 200, width_type = "fixed", width_percent = 1, frame_level = 1, sort = true, reverse = false,
                      row_spacing = 1, col_spacing = 1, size = 20, my_size = 24, new_row_size = false, filter = ""},
            buff = {growth = "right_up", anchor = "TOPLEFT", side = "TOP", offset_x = 0, offset_y = 0,
                    width = 200, width_type = "fixed", width_percent = 1, frame_level = 1, sort = true, reverse = false,
                    row_spacing = 1, col_spacing = 1, size = 20, my_size = 24, new_row_size = false, filter = ""}}}
FRAME = make_obj("UnitFrame")
FRAME.unit, FRAME.best_unit, FRAME.guid, FRAME.classification_db = "target", "target", "Creature-1", {}
FRAME.force_show = false
FRAME.is_wacky = false
FRAME.on_GetFont = function(self, f, s) count("GetFont"); return "Fonts\\2002.TTF", 12.5 * (s or 1) end
FRAME.on_GetWidth = function() return 340 end
FRAME.on_GetHeight = function() return 56 end
FRAME.on_GetFrameLevel = function() return 3 end
"""


def aura_runtime():
    L = runtime()
    L.execute(AURA_STUBS)
    load(L, "Modules/Aura/Forever.lua")
    L.execute("Aura:OnEnable()")
    return L


@case
def aura_native_update_reconfigures_only_on_change():
    L = aura_runtime()
    update = L.eval("function(n) for i = 1, n do Aura:UpdateNativeDebuffs(FRAME, DB) end end")
    update(1)
    L.execute("reset_calls()")
    n = 100
    kb = garbage_kb(L, L.eval("function() for i = 1, %d do Aura:UpdateNativeDebuffs(FRAME, DB) end end" % n))
    per = {"container": calls(L, "AuraContainer:") / n, "UpdateAllAuras": calls(L, "AuraContainer:UpdateAllAuras") / n,
           "GetFont": calls(L, "GetFont") / n, "button_style": calls(L, "Button:") / n}
    probe("Aura native debuffs, same unit/settings, per update", container_calls=per["container"],
          UpdateAllAuras=per["UpdateAllAuras"], GetFont=per["GetFont"], button_calls=per["button_style"],
          garbage_kb=round(kb / n, 3))
    if not NEW:
        return
    eq((per["container"], per["GetFont"], per["button_style"]), (0, 0, 0), "nothing reconfigured when nothing changed")
    # The underlying unit changes while the token stays "target": one UpdateAllAuras.
    L.execute("reset_calls(); FRAME.guid = 'Creature-2'; Aura:UpdateNativeDebuffs(FRAME, DB)")
    eq(calls(L, "AuraContainer:UpdateAllAuras"), 1, "new GUID: native refresh")
    eq(calls(L, "AuraContainer:SetAuraGroupLayout"), 0, "new GUID alone: layout kept")
    # A settings change (options dialog) restyles once.
    L.execute("reset_calls(); DB.zoom_aura = true; fire_config_change(); Aura:UpdateNativeDebuffs(FRAME, DB)")
    eq(calls(L, "Texture:SetTexCoord") > 0 and calls(L, "AuraContainer:SetAuraGroupLayout") == 2, True,
       "settings change: layout and button style applied")
    L.execute("reset_calls(); Aura:UpdateNativeDebuffs(FRAME, DB)")
    eq(calls(L, "AuraContainer:"), 0, "and then nothing again")
    # An aura event for the container's unit refreshes that container once (safety, see Forever.lua).
    L.execute("reset_calls(); Aura:UNIT_AURA('UNIT_AURA', 'target'); Aura:OnUpdate(); Aura:UpdateNativeDebuffs(FRAME, DB)")
    eq((calls(L, "AuraContainer:UpdateAllAuras"), calls(L, "AuraContainer:") - calls(L, "AuraContainer:UpdateAllAuras")), (1, 0),
       "UNIT_AURA: one UpdateAllAuras in the throttled update, none after it")
    L.execute("reset_calls(); FRAME.is_wacky = true; Aura:UpdateNativeDebuffs(FRAME, DB); FRAME.is_wacky = false")
    eq(calls(L, "AuraContainer:UpdateAllAuras"), 1, "wacky unit (no aura events): refreshed on its update")
    # Hidden and shown again: reconfigured.
    L.execute("reset_calls(); Aura:ClearNativeDebuffs(FRAME); Aura:UpdateNativeDebuffs(FRAME, DB)")
    eq(calls(L, "AuraContainer:SetEnabled") >= 2 and calls(L, "AuraContainer:UpdateAllAuras") == 1, True,
       "cleared frame comes back fully")


@case
def aura_combat_transition_updates_once():
    L = aura_runtime()
    regen = L.eval("Aura.events")
    handlers = 1 if regen["PLAYER_REGEN_DISABLED"] == "UpdateAll" else 0
    L.execute("WATCH.script(WATCH, 'PLAYER_REGEN_DISABLED'); run_timers()")
    deferred = L.eval("Aura.UPDATE_ALL")
    probe("Aura combat start", UpdateAll_per_transition=handlers + deferred)
    if NEW:
        eq(handlers + deferred, 1, "one UpdateAll per combat transition (the deferred one)")


# Item 2 — LuaTexts ---------------------------------------------------------------

LT_STUBS = r"""
local counting_find = string.find
FIND = 0
string.find = function(...) FIND = FIND + 1; return counting_find(...) end
TEST_health, TEST_max = 1500, 2000
function UnitHealth() count("UnitHealth"); return TEST_health end
function UnitHealthMax() return TEST_max end
function UnitPower() return 10 end
function UnitPowerMax() return 100 end
function UnitName() return "Hero" end
function UnitLevel() return 60 end
READABLE = true
PitBull4 = {Compat = {IsForever = true, IsValueAccessible = function(v) return READABLE end},
  CastBar = {GetForeverCast = function() return nil end}}
LT = {to_update = {}}
PitBull4.GetModule = function() return LT end
function new_text() local t = make_obj("FontString"); t.db = {attach_to = "HealthBar"}
  t.on_SetFormattedText = function(self, f, ...) self.shown = string.format(f, ...) end
  t.on_SetText = function(self, v) self.shown = v end
  return t end
"""

LT_CODES = [
    'local s = Status(unit)\nif s then\n  return s\nend\nreturn "%s/%s",HP(unit),MaxHP(unit)',
    'local cur, max = HP(unit), MaxHP(unit)\nreturn "%s || %s%%",HP(unit),Percent(cur,max)',
    "local r,g,b = ClassColor(unit)\nreturn '|cff%02x%02x%02x%s|r %s%s%s',r,g,b,Name(unit),Angle(AFK(unit) or DND(unit))",
    "local dr,dg,db = DifficultyColor(unit)\nreturn \"|cff%02x%02x%02x%s%s|r %s\",dr,dg,db,Level(unit),Classification(unit) and '+' or '',SmartRace(unit) or ''",
]


@case
def luatexts_forever_classification_cached():
    L = runtime()
    L.execute(LT_STUBS)
    load(L, "Modules/LuaTexts/Forever.lua")
    codes = L.table(*[c.encode().decode("unicode_escape") for c in LT_CODES])
    run = L.eval("""function(codes, n, readable)
      READABLE = readable
      local out, handled = {}, 0
      FIND = 0
      for i = 1, n do for j, code in ipairs(codes) do
        local t = new_text()
        if LT:TryForeverText(t, "target", code) then handled = handled + 1 end
        out[j] = tostring(t.shown)
      end end
      return FIND, handled, out
    end""")
    run(codes, 1, True)
    finds, handled, _ = run(codes, 100, True)
    r_finds, r_handled, shown = run(codes, 100, False)
    probe("LuaTexts TryForeverText, 4 Devil texts", readable_finds_per_text=finds / 400.0,
          restricted_finds_per_text=r_finds / 400.0)
    eq((handled, r_handled), (0, 400), "readable: user code runs; restricted: each text drawn natively")
    eq(list(shown.values()), ["1500 / 2000", "1500 / 2000", "Hero", "60"], "displayed values (restricted)")
    RESULTS.append("luatexts shown (restricted): %r" % list(shown.values()))


LT_EVENT_STUBS = r"""
PitBull4 = {Utils = {SafeGUID = function(v) count("SafeGUID"); if v == nil then return nil end return tostring(v) end,
                     SafeEqual = function(a, b) count("SafeEqual"); return a == b end}}
TEST_guids = {player = "Player-1", pet = "Pet-1", target = "Creature-1"}
"""


@case
def luatexts_event_loop_guid_work():
    """Probe of the OnEvent loop body (LuaTexts.lua) extracted with the file's own helpers."""
    path = os.path.join(SOURCE, "Modules/LuaTexts/LuaTexts.lua")
    src = open(path, "rb").read().decode("utf-8").replace("\r\n", "\n")
    start = src.index("function PitBull4_LuaTexts:OnEvent(event, unit, ...)")
    body = src[start:src.index("\nend\n", start) + 5]
    L = runtime()
    L.execute(LT_EVENT_STUBS)
    L.execute("""
      SafeGUID = PitBull4.Utils.SafeGUID
      local SafeEqual = PitBull4.Utils.SafeEqual
      function safe_guid_equal(left, right) if left == nil or right == nil then return false end
        return SafeEqual(SafeGUID(left), SafeGUID(right)) end
      function fs_frame_guid(fs) return fs.frame and fs.frame.guid or nil end
      UPDATED = {}
      function update_text(fs) UPDATED[#UPDATED + 1] = fs.name end
      function update_timers() end
      function update_cast_data() end
      event_cache = {UNIT_HEALTH = {}}
      for i = 1, 16 do
        local guid = (i == 1 and "Creature-1") or (i == 2 and "Player-1") or ("Other-" .. i)
        event_cache.UNIT_HEALTH[{name = i, frame = {guid = guid}}] = true
      end
      player_guid = "Player-1"
      PitBull4_LuaTexts = {db = {profile = {global = {events = {UNIT_HEALTH = {unit = true, player = false, pet = false}}}}}}
    """)
    L.execute("local SafeGUID, safe_guid_equal, fs_frame_guid, update_text, update_timers, update_cast_data, event_cache, player_guid = "
              "SafeGUID, safe_guid_equal, fs_frame_guid, update_text, update_timers, update_cast_data, event_cache, player_guid\n"
              + body + "\nLT = PitBull4_LuaTexts")
    L.execute("reset_calls(); LT:OnEvent('UNIT_HEALTH', 'target')")
    probe("LuaTexts OnEvent UNIT_HEALTH, 16 texts, unit event", SafeGUID=calls(L, "SafeGUID"),
          UnitGUID_pet=calls(L, "UnitGUID:pet"), SafeEqual=calls(L, "SafeEqual"))
    eq(list(L.eval("UPDATED").values()), [1], "only the text of the event's unit updated")
    L.execute("UPDATED = {}; PitBull4_LuaTexts.db.profile.global.events.UNIT_HEALTH = {pet = true}; TEST_guids.pet = 'Other-5'; "
              "LT:OnEvent('UNIT_HEALTH', 'pet')")
    eq(list(L.eval("UPDATED").values()), [5], "pet event updates the pet text")


# Item 3 — bars: one redraw per frame, one power event, texture early return -------

BAR_STUBS = r"""
UPDATES = 0
FRAME = make_obj("UnitFrame"); FRAME.unit, FRAME.best_unit, FRAME.force_show = "target", "target", false
local function one(t) local done = false; return function() if done then return nil end done = true; return t end end
MOD = nil
PitBull4 = {L = setmetatable({}, {__index = function(_, k) return k end}),
  Compat = {IsValueAccessible = function() return true end, RegisterOptionalEvent = function(m, e, f) m:RegisterEvent(e, f) end},
  PowerColors = {MANA = {0, 0, 1}}, wow_retail = false,
  IterateFrames = function() return one(FRAME) end,
  IterateFramesForUnitID = function(_, unit) if unit == FRAME.unit then return one(FRAME) end return function() end end}
function PitBull4:NewModule(name)
  local m = make_obj("Module")
  m.events = {}
  m.on_RegisterEvent = function(self, e, f) self.events[e] = f or e end
  m.on_Update = function() UPDATES = UPDATES + 1 end
  m.on_UpdateForUnitID = function(self, unit) for f in PitBull4:IterateFramesForUnitID(unit) do self:Update(f) end end
  m.on_UpdateAll = function(self) for f in PitBull4:IterateFrames() do self:Update(f) end end
  MOD = m
  return m
end
ONUPDATE = {}
function CreateFrame(kind)
  local o = make_obj(kind)
  o.on_SetScript = function(self, k, fn) if k == "OnUpdate" then ONUPDATE[#ONUPDATE + 1] = {self, fn} end end
  return o
end
function render() for _, e in ipairs(ONUPDATE) do e[2](e[1], 0.016) end end
PowerBarColor = {MANA = {r = 0, g = 0, b = 1}}
function UnitPowerType() return 0, "MANA" end
function fire(event, ...) local f = MOD.events[event]; if f then if type(f) == "string" then MOD[f](MOD, event, ...) else f(event, ...) end end end
"""


def bar_runtime(rel):
    L = runtime()
    L.execute(BAR_STUBS)
    load(L, rel)
    L.execute("MOD:OnEnable()")
    return L


@case
def healthbar_one_redraw_per_frame():
    L = bar_runtime("Modules/HealthBar/HealthBar.lua")
    L.execute("UPDATES = 0; fire('UNIT_HEALTH', 'target'); fire('UNIT_MAXHEALTH', 'target'); render()")
    n = L.eval("UPDATES")
    probe("HealthBar, UNIT_HEALTH + UNIT_MAXHEALTH in one frame", Update_calls=n)
    if NEW:
        eq(n, 1, "one update for the frame")
        L.execute("UPDATES = 0; fire('UNIT_HEALTH', 'focus'); render()")
        eq(L.eval("UPDATES"), 0, "another unit: not this frame")


@case
def powerbar_one_event_one_redraw():
    L = bar_runtime("Modules/PowerBar/PowerBar.lua")
    L.execute("UPDATES = 0; fire('UNIT_POWER_UPDATE', 'target', 'MANA'); fire('UNIT_POWER_FREQUENT', 'target', 'MANA'); render()")
    n = L.eval("UPDATES")
    registered = sum(1 for e in ("UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT") if L.eval("MOD.events")[e])
    probe("PowerBar, one power change (UPDATE + FREQUENT)", Update_calls=n, power_events_registered=registered)
    if NEW:
        eq((n, registered), (1, 1), "one handler, one redraw")


@case
def livestatusbar_texture_set_once():
    path = os.path.join(SOURCE, "Controls/BetterStatusBar.lua")
    src = open(path, "rb").read().decode("utf-8").replace("\r\n", "\n")
    start = src.index("function LiveStatusBar:SetTexture(texture)")
    end = src.index("function LiveStatusBar:GetTexture()")
    a = src.index("function LiveStatusBar:SetAtlas(atlas)")
    a_end = src.index("\nend\n", a) + 5
    L = runtime()
    L.execute("LiveStatusBar = {}\n" + src[start:end] + src[a:a_end])
    L.execute("""
      BAR = setmetatable({barTexture = make_obj("Texture"), public_bar = make_obj("PublicBar")}, {__index = LiveStatusBar})
      reset_calls()
      for i = 1, 10 do BAR:SetTexture("Devil"); BAR:SetAtlas(nil) end
    """)
    n = calls(L, "Texture:SetTexture") + calls(L, "PublicBar:")
    probe("LiveStatusBar SetTexture+SetAtlas(nil) x10, same path", texture_calls=n)
    L.execute("reset_calls(); BAR:SetTexture('Other'); BAR:SetAtlas('atlas1'); BAR:SetTexture('Other')")
    if NEW:
        eq(n, 2, "texture set once (bar + public bar)")
        eq((calls(L, "Texture:SetAtlas"), calls(L, "Texture:SetTexture") >= 2), (1, True),
           "a change and an atlas still apply; SetTexture after an atlas clears it")


# Item 4 — aura normalisation without per-field closures --------------------------

AURA_UPDATE_STUBS = r"""
PitBull4 = {Compat = {Spell = {}}, L = setmetatable({}, {__index = function(_, k) return k end}),
  Utils = {SafeGUID = function(v) return v end,
           SafeBoolean = function(v, d) if v == nil then return d end return v and true or false end,
           SafeString = function(v) if v == nil then return nil end return tostring(v) end}}
PitBull4_Aura = {can_dispel = {player = {}}}
function PitBull4:GetModule() return PitBull4_Aura end
C_Item = {}
HOUR_ONELETTER_ABBR, MINUTE_ONELETTER_ABBR = "%d h", "%d m"
function UnitIsUnit(a, b) count("UnitIsUnit"); return false end
"""


def aura_update_runtime():
    path = os.path.join(SOURCE, "Modules/Aura/Update.lua")
    src = open(path, "rb").read().decode("utf-8").replace("\r\n", "\n")
    head = src[:src.index("-- Fills an array of arrays")]
    L = runtime()
    L.execute(AURA_UPDATE_STUBS)
    L.execute(head + "\nNORMALIZE = normalize_aura_entry; IS_MINE = is_aura_mine")
    return L


@case
def aura_normalize_without_closures():
    L = aura_update_runtime()
    fresh = L.eval("""function() return {name = "Curse of Agony", icon = 136139, spellId = 980, auraInstanceID = 7,
      applications = 1, duration = 24, expirationTime = 1024, timeMod = 1, isHelpful = false, isHarmful = true,
      isStealable = false, isRaid = false, canApplyAura = true, isBossAura = false, isFromPlayerOrPlayerPet = true,
      nameplateShowPersonal = false, nameplateShowAll = false, isNameplateOnly = false, canActivePlayerDispel = false,
      isTankRoleAura = false, isDPSRoleAura = false, isHealerRoleAura = false, sourceUnit = "target", dispelName = "Curse"} end""")
    entries = [fresh() for _ in range(200)]
    L.globals().E = L.table(*entries)
    kb = garbage_kb(L, L.eval("function() for i = 1, 200 do NORMALIZE(E[i], 'target', i, 'HARMFUL', false) end end"))
    probe("Aura normalize_aura_entry", garbage_kb_per_aura=round(kb / 200.0, 3))
    one = L.eval("NORMALIZE")(fresh(), "target", 1, "HARMFUL", False)
    got = {k: one[k] for k in ("name", "spellId", "applications", "isHarmful", "canApplyAura", "dispelName", "sourceUnit")}
    eq(got, {"name": "Curse of Agony", "spellId": 980, "applications": 1, "isHarmful": True, "canApplyAura": True,
             "dispelName": "Curse", "sourceUnit": "target"}, "normalized values")
    if NEW:
        eq(one["pb4_is_mine"], False, "ownership stored on the entry")


# Item 5 — AltManaBar ------------------------------------------------------------

ALT_STUBS = r"""
function UnitClassBase() return "DRUID" end
TEST_power_type = 0
function UnitPowerType() count("UnitPowerType"); return TEST_power_type end
function UnitPower(u, t) return 700 end
function UnitPowerMax(u, t) return 1000 end
local real_format = string.format
string.format = function(...) count("format"); return real_format(...) end
"""


@case
def altmanabar_unit_events_and_early_return():
    L = runtime()
    L.execute(BAR_STUBS)
    L.execute(ALT_STUBS)
    L.execute("""MOD_UNIT_EVENTS = {}
      local new = PitBull4.NewModule
      function PitBull4:NewModule(name) local m = new(self, name)
        m.on_RegisterUnitEvent = function(self, e, f, ...) MOD_UNIT_EVENTS[e] = {f or e, ...} end
        m.on_GetLayoutDB = function() return {show_in_forms = true, hide_if_full = false} end
        return m end""")
    load(L, "Modules/AltManaBar/AltManaBar.lua")
    L.execute("MOD:OnEnable()")
    plain = sum(1 for _ in L.eval("MOD.events").items())
    unit = sum(1 for _ in L.eval("MOD_UNIT_EVENTS").items())
    L.execute("""UPDATES = 0; reset_calls(); FRAME.unit, FRAME.best_unit = "player", "player"
      local function power(e, unit) local f = MOD.events[e] or (MOD_UNIT_EVENTS[e] and (MOD_UNIT_EVENTS[e][1] or e))
        if f then MOD[f](MOD, e, unit, "MANA") end end
      for i = 1, 10 do power("UNIT_POWER_FREQUENT", "player"); power("UNIT_POWER_FREQUENT", "target") end""")
    updates = L.eval("UPDATES")
    L.execute("reset_calls(); TEST_power_type = 1; VALUE = MOD:GetValue({unit = 'player', best_unit = 'player'}); TEST_power_type = 0")
    probe("AltManaBar, 10 mana changes (player) + 10 target events, primary power mana",
          plain_events=plain, unit_events=unit, frame_updates=updates, format_calls_per_value=calls(L, "format"))
    if NEW:
        eq(updates, 0, "bar hidden while the primary power is mana: no refresh")
        L.execute("TEST_power_type = 1; UPDATES = 0; MOD:UNIT_POWER_FREQUENT('UNIT_POWER_FREQUENT', 'player', 'MANA')")
        eq(L.eval("UPDATES") > 0, True, "rage form: refreshed")
        eq(L.eval("MOD:GetValue({unit = 'player', best_unit = 'player'})"), 0.7, "value unchanged (700/1000)")
        eq(L.eval("MOD.events")["UNIT_POWER_FREQUENT"], None, "power events are unit events")


# Item 6 — CastBar ticker only while casting -------------------------------------

CAST_STUBS = r"""
CASTING = nil
function UnitCastingInfo(unit) if CASTING == unit then return "Fireball", nil, 135812, nil, nil, nil, nil, false end end
function UnitChannelInfo() end
function UnitCastingDuration(unit) if CASTING == unit then return {GetRemainingDuration = function() return 1 end} end end
function UnitChannelDuration() end
CB = make_obj("CastBarModule")
CB.db = {profile = {global = {casting_interruptible_color = {1, .7, 0}}}}
CB.foreverTicker = false
UPDATE_ALL = 0
FRAME = {unit = "target", best_unit = "target", force_show = false, CastBar = false}
local function one(t) local done = false; return function() if done then return nil end done = true; return t end end
CB.on_UpdateAll = function(self) UPDATE_ALL = UPDATE_ALL + 1; for f in PitBull4:IterateFrames() do self:UpdateFrame(f) end end
CB.on_UpdateForUnitID = function(self, unit) if unit == FRAME.unit then self:UpdateFrame(FRAME) end end
CB.on_GetLayoutDB = function() return {auto_hide = true, show_icon = true} end
CB.UpdateFrame = function(self, frame) self:GetRawValue(frame); return false end
PitBull4 = {Compat = {IsForever = true, IsValueAccessible = function() return true end,
  RegisterOptionalEvent = function(m, e, f) end},
  IterateFrames = function() return one(FRAME) end, IsInConfigMode = function() return false end,
  GetModule = function() return CB end}
function tick(n) for i = 1, n do for _, t in ipairs(TICKERS) do if not t.cancelled then t.fn() end end end end
"""


@case
def castbar_ticker_only_while_casting():
    L = runtime()
    L.execute(CAST_STUBS)
    load(L, "Modules/CastBar/Forever.lua")
    L.execute("CB:OnEnable(); UPDATE_ALL = 0; tick(66)")
    idle = L.eval("UPDATE_ALL")
    probe("CastBar Forever, 10 s without casts (66 ticks of 0.15 s)", UpdateAll_calls=idle)
    if not NEW:
        return
    eq(idle, 0, "no polling while nothing is cast")
    L.execute("CASTING = 'target'; CB:ForeverCastEvent('UNIT_SPELLCAST_START', 'target'); UPDATE_ALL = 0; tick(5)")
    eq(L.eval("UPDATE_ALL"), 5, "polling while casting")
    L.execute("CASTING = nil; tick(1); UPDATE_ALL = 0; tick(10)")
    eq(L.eval("UPDATE_ALL"), 0, "stops once the cast ended")


# Items 7, 8 — targetpet singleton, shaman-only Totems -----------------------------

UTILS_STUBS = r"""
PitBull4 = {L = setmetatable({}, {__index = function(_, k) return k end}), DEBUG = false}
function LibStub() return nil end
MAX_PARTY_MEMBERS, MAX_RAID_MEMBERS, MAX_BOSS_FRAMES = 4, 40, 5
"""


@case
def targetpet_is_a_singleton_unit():
    if not NEW:
        return
    L = runtime()
    L.execute(UTILS_STUBS)
    load(L, "Utils.lua")
    U = L.eval("PitBull4.Utils")
    eq((U.GetBestUnitID("targetpet"), U.IsSingletonUnitID("targetpet"), U.IsWackyUnitGroup("targetpet")),
       ("targetpet", True, True), "best unit, singleton, polled (no unit events)")
    eq(U.GetLocalizedClassification("targetpet"), "Target Pet", "options name")
    eq((U.GetBestUnitID("targettarget"), U.IsSingletonUnitID("focus")), ("targettarget", True), "existing units unchanged")
    main = open(os.path.join(SOURCE, "Main.lua"), "rb").read().decode("utf-8")
    block = main[main.index("local SINGLETON_CLASSIFICATIONS = {"):main.index("local UNIT_GROUPS")]
    eq('"targetpet"' in block, True, "listed with the singleton classifications")
    handler = main[main.index("function PitBull4:PLAYER_TARGET_CHANGED()"):main.index("function PitBull4:UNIT_TARGET")]
    eq('CheckGUIDForUnitID("targetpet")' in handler, True, "refreshed on target change")


TOTEM_STUBS = r"""
NEWMODULE = 0
PitBull4 = {L = setmetatable({}, {__index = function(_, k) return k end}), Compat = {IsForever = true},
  NewModule = function(self, name) NEWMODULE = NEWMODULE + 1; return make_obj("TotemsModule") end}
function tInvert(t) local o = {} for k, v in pairs(t) do o[v] = k end return o end
function LibStub() return nil end
"""


@case
def totems_module_for_shamans_only():
    made = {}
    for cls in ("SHAMAN", "PALADIN", "PRIEST", "WARRIOR"):
        L = runtime()
        L.execute(TOTEM_STUBS)
        L.execute("function UnitClassBase() return '%s' end" % cls)
        load(L, "Modules/Totems/Totems.lua")
        made[cls] = L.eval("NEWMODULE")
    probe("Totems module created per class on Forever", **made)
    if NEW:
        eq(made, {"SHAMAN": 1, "PALADIN": 0, "PRIEST": 0, "WARRIOR": 0}, "shamans only")


# Item 9 — nameplate styles cached ------------------------------------------------

NAMEPLATES = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Skin_Nameplates")
NP_STUBS = r"""
local function copy(v) if type(v) ~= "table" then return v end local t = {} for k, x in pairs(v) do t[k] = copy(x) end return t end
CB = {}
DevilForever_Core = {
  Presets = {GetActive = function() return "fhd" end},
  Edit = {Get = function(self, key) count("Edit:Get"); return {size = {width = 180, height = 20}, font = {size = 18}} end,
          RegisterCallback = function(self, owner, fn) CB.edit = fn end, AfterBatch = function(self, owner, fn) fn() end},
  Theme = {Get = function(self, token) count("Theme:Get"); return token == "font.normal" and "Fonts\\devil.ttf" or "Interface\\devil" end,
           RegisterCallback = function(self, owner, fn) CB.theme = fn end},
  Log = function() end}
DevilForever_Appearance = {GetPixelUnit = function() return 0.5 end}
function UnitIsFriend() return false end
TEST_combat = false
local function plate()
  local bar = make_obj("HealthBar"); local size = {0, 0}; local tex = make_obj("BarTexture"); local path = nil
  bar.on_SetSize = function(self, w, h) size = {w, h} end
  bar.on_GetSize = function() return size[1], size[2] end
  bar.on_SetStatusBarTexture = function(self, p) path = p end
  bar.on_GetStatusBarTexture = function() return tex end
  tex.on_GetTexture = function() return path end
  bar.on_IsForbidden = function() return false end; bar.on_IsProtected = function() return false end
  local font = make_obj("FontString"); local f = {"x", 10, "OUTLINE"}
  font.on_SetFont = function(self, a, b, c) f = {a, b, c} end
  font.on_GetFont = function() return f[1], f[2], f[3] end
  font.on_IsForbidden = function() return false end; font.on_IsProtected = function() return false end
  local uf = make_obj("UnitFrame"); uf.HealthBarsContainer = {healthBar = bar}; uf.name = font; uf.unit = "nameplate1"
  uf.on_IsForbidden = function() return false end; uf.on_IsProtected = function() return false end
  local p = make_obj("NamePlate"); p.UnitFrame = uf
  p.on_IsForbidden = function() return false end; p.on_IsProtected = function() return false end
  return p
end
PLATE = plate()
C_NamePlate = {GetNamePlateForUnit = function() return PLATE end, GetNamePlates = function() return {PLATE} end}
LISTENER = nil
function CreateFrame() local o = make_obj("Frame"); o.on_SetScript = function(self, k, fn) LISTENER = fn end; return o end
"""


def nameplate_runtime():
    L = runtime()
    L.execute(NP_STUBS)
    ns = L.table()
    for rel in ("NameplateProfiles.lua", "Appearance.lua"):
        src = open(os.path.join(NAMEPLATES, rel), "rb").read()
        fn = L.eval("loadstring")(src, ("@" + rel).encode())
        fn = fn[0] if isinstance(fn, tuple) else fn
        fn("DevilForever_Skin_Nameplates", ns)
    return L


@case
def nameplate_style_cached_and_unchanged_skipped():
    L = nameplate_runtime()
    L.execute("LISTENER(nil, 'NAME_PLATE_UNIT_ADDED', 'nameplate1')")
    L.execute("reset_calls()")
    kb = garbage_kb(L, L.eval("function() for i = 1, 100 do LISTENER(nil, 'NAME_PLATE_UNIT_ADDED', 'nameplate1') end end"))
    probe("nameplate NAME_PLATE_UNIT_ADDED, same plate and style, per event",
          Edit_Get=calls(L, "Edit:Get") / 100.0, Theme_Get=calls(L, "Theme:Get") / 100.0,
          SetSize=calls(L, "HealthBar:SetSize") / 100.0, SetStatusBarTexture=calls(L, "HealthBar:SetStatusBarTexture") / 100.0,
          SetFont=calls(L, "FontString:SetFont") / 100.0, garbage_kb=round(kb / 100, 3))
    w, h = L.eval("PLATE.UnitFrame.HealthBarsContainer.healthBar:GetSize()")
    eq((w, h), (90, 10), "bar size 180x20 physical at pixel unit 0.5")
    if NEW:
        eq((calls(L, "Edit:Get"), calls(L, "HealthBar:SetSize"), calls(L, "FontString:SetFont")), (0, 0, 0),
           "cached style, nothing re-applied")
        L.execute("reset_calls(); CB.edit('nameplates.enemy'); ")
        eq(calls(L, "Edit:Get") >= 1, True, "an edit of the nameplate style recomputes it")
        L.execute("PLATE.UnitFrame.HealthBarsContainer.healthBar:SetSize(1, 1); reset_calls(); "
                  "LISTENER(nil, 'NAME_PLATE_UNIT_ADDED', 'nameplate1')")
        eq(calls(L, "HealthBar:SetSize"), 1, "a plate the client resized gets its size again")


# Item 10 — leftover handlers and timers -----------------------------------------

def suite(name):
    return runpy.run_path(os.path.join(REPO, "Collection", "tests", name, "run.py"), run_name="harness_" + name)


@case
def core_handler_removed_after_its_work():
    if not NEW:
        return
    core = suite("core")
    s = core["Session"]()
    s.lua.execute("""SEEN = {}
      local function first() SEEN[#SEEN + 1] = "first"; DevilForever_Core:Off("TEST_EVENT", first) end
      DevilForever_Core:On("TEST_EVENT", first)
      DevilForever_Core:On("TEST_EVENT", function() SEEN[#SEEN + 1] = "second" end)""")
    s.fire("TEST_EVENT")
    s.fire("TEST_EVENT")
    eq(list(core["to_py"](s.g.SEEN).values()), ["first", "second", "second"], "removal waits for the running dispatch")
    s.boot()
    eq(s.sv("DevilForever_CoreDB") is not None, True, "Core still becomes ready")


@case
def chat_layout_waits_only_for_a_managed_layout():
    if not NEW:
        return
    chat = suite("chatsetup")
    s = chat["Session"](saved={"result": "skipped"})
    s.lua.execute("DevilForever_Core = {Presets = {GetActive = function() return 'uhd' end}, "
                  "Edit = {RegisterCallback = function(self, owner, fn) TEST_edit = fn end}}; "
                  "DevilForever_Appearance = {GetPixelUnit = function() return 1 end}")
    s.load(layout=True)
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    timers = len(list(s.g.TEST_timers.values()))
    eq(timers, 0, "unmanaged windows: no 4 s timer at each world entry")
    eq(s.lua.eval("_G").DevilForever_ChatSetupDB["result"], "skipped", "premise")


@case
def castbars_regen_retries_bounded():
    if not NEW:
        return
    cb = suite("castbars")
    s = cb["Session"](frames={"player": True}).load().login()   # target, focus, pet bars missing in FUF
    rounds = 0
    for i in range(6):
        s.g.TEST_fire("PLAYER_REGEN_ENABLED")
        rounds += len(list(s.g.TEST_timers.values()))
        s.g.TEST_timers = s.lua.table()
    eq(rounds, 6, "three combat ends with retries (2 timers each), then none")


@case
def sharedmedia_handler_unregistered_after_register():
    if not NEW:
        return
    L = runtime()
    L.execute("""
      EVENTS = 0
      DevilForever_Core = {Theme = {GetFromSet = function() return "x" end}}
      local media = {Register = function() end}
      function LibStub(name) return media end
      function CreateFrame() local f = make_obj("Frame")
        f.on_RegisterEvent = function() EVENTS = EVENTS + 1 end
        f.on_UnregisterAllEvents = function() EVENTS = 0 end
        return f end""")
    src = open(os.path.join(REPO, "Collection/AddOns/DevilForever_Appearance/SharedMedia.lua"), "rb").read()
    fn = L.eval("loadstring")(src, b"@SharedMedia.lua")
    (fn[0] if isinstance(fn, tuple) else fn)()
    eq(L.eval("EVENTS"), 0, "registered at load: ADDON_LOADED/PLAYER_LOGIN dropped")


def main():
    global SOURCE, NEW
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", help="another PitBull4 folder (before numbers)")
    args = parser.parse_args()
    if args.source:
        SOURCE, NEW = os.path.abspath(args.source), False
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

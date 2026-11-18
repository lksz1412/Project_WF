"""Logic tests for DevilForever_ChatSetup (the three-window chat split).

Usage:  python3 -I Collection/tests/chatsetup/run.py

Each case starts a fresh Lua 5.1 runtime (lupa), installs stubs for the client
chat API the addon calls (ChatFrame1-10 with message group lists, the dock flag
and the shown flag, FCF_OpenNewWindow, FCF_UnDockFrame and the other FCF_*
calls, ChatTypeGroup, C_Timer.After, InCombatLockdown, GetLocale, UIParent,
print, CreateFrame with event registration), sets the saved variable from
Python data, runs ChatSetup.lua and fires the events a case needs. This checks
the addon's logic only; it does not emulate the game client.
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
ADDON_DIR = os.path.join(REPO, "Collection", "AddOns", "DevilForever_ChatSetup")
ADDON = "DevilForever_ChatSetup"

GENERAL_GROUPS = ["SYSTEM", "SAY", "EMOTE", "YELL", "WHISPER", "BN_WHISPER", "PARTY", "PARTY_LEADER", "RAID",
                  "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER",
                  "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE",
                  "MONSTER_BOSS_WHISPER", "ERRORS", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL",
                  "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY",
                  "MONEY", "TRADESKILLS", "OPENING", "PET_INFO", "COMBAT_MISC_INFO", "ACHIEVEMENT",
                  "GUILD_ACHIEVEMENT", "CHANNEL", "TARGETICONS", "BN_INLINE_TOAST_ALERT"]
# The client of a case defines these groups (PING is left out on purpose).
KNOWN_GROUPS = GENERAL_GROUPS + ["GUILD_DISCORD", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO"]

GROUP_ROLE = ["GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER",
              "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "WHISPER", "BN_WHISPER"]
SYSTEM_ROLE = ["SYSTEM", "ERRORS", "IGNORED", "TARGETICONS", "BN_INLINE_TOAST_ALERT", "COMBAT_XP_GAIN",
               "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY", "TRADESKILLS",
               "OPENING", "PET_INFO", "COMBAT_MISC_INFO", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL"]

STUBS = r"""
TEST_calls = {}
local function record(...) TEST_calls[#TEST_calls + 1] = table.concat({...}, " ") end

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
TEST_locale = "enUS"
function GetLocale() return TEST_locale end
TEST_printed = {}
function print(...) TEST_printed[#TEST_printed + 1] = table.concat({...}, " ") end

NUM_CHAT_WINDOWS = 10
UIParent = {GetWidth = function() return 1920 end}

local Chat = {}
Chat.__index = Chat
function Chat:GetID() return self.id end
function Chat:GetName() return "ChatFrame" .. self.id end
function Chat:IsShown() return self.shown end
function Chat:GetWidth() return self.width end
function Chat:GetHeight() return self.height end
function Chat:GetRight() return self.left and (self.left + self.width) end
function Chat:GetBottom() return self.bottom end
function Chat:SetSize(w, h) self.width, self.height = w, h; record("SetSize", self.id, w, h) end
function Chat:ClearAllPoints() self.point = nil end
function Chat:SetPoint(p, rel, relp, x, y) self.point = {p, relp, x, y}; record("SetPoint", self.id, p, relp, x, y) end
local function addTo(frame, group)
  for _, g in ipairs(frame.messageTypeList) do if g == group then return end end
  table.insert(frame.messageTypeList, group)
end
local function removeFrom(frame, group)
  for i, g in ipairs(frame.messageTypeList) do
    if g == group then table.remove(frame.messageTypeList, i); return end
  end
end
function TEST_installMethods(on)
  if on then
    Chat.AddMessageGroup = function(self, group)
      if group == TEST_failOn then error("stopped at " .. group) end
      addTo(self, group); record("AddMessageGroup", self.id, group)
    end
    Chat.RemoveMessageGroup = function(self, group) removeFrom(self, group); record("RemoveMessageGroup", self.id, group) end
    ChatFrame_AddMessageGroup, ChatFrame_RemoveMessageGroup = nil, nil
  else
    Chat.AddMessageGroup, Chat.RemoveMessageGroup = nil, nil
    ChatFrame_AddMessageGroup = function(frame, group) addTo(frame, group); record("ChatFrame_AddMessageGroup", frame.id, group) end
    ChatFrame_RemoveMessageGroup = function(frame, group) removeFrom(frame, group); record("ChatFrame_RemoveMessageGroup", frame.id, group) end
  end
end
TEST_installMethods(true)

function TEST_makeFrames(general)
  for i = 1, 10 do
    local f = setmetatable({id = i, messageTypeList = {}, shown = false, isDocked = nil,
                            width = 430, height = 120, left = 32, bottom = 40}, Chat)
    _G["ChatFrame" .. i] = f
  end
  ChatFrame1.shown, ChatFrame1.isDocked = true, 1
  for _, g in ipairs(general) do table.insert(ChatFrame1.messageTypeList, g) end
  ChatFrame2.isDocked = 1
  ChatFrame2.messageTypeList = {}
end

function FCF_OpenNewWindow(name, noDefaultChannels)
  for i = 3, NUM_CHAT_WINDOWS do
    local f = _G["ChatFrame" .. i]
    if not f.isDocked and not f.shown then
      f.name, f.shown, f.isDocked = name, true, 1
      record("FCF_OpenNewWindow", name, tostring(noDefaultChannels), i)
      return f
    end
  end
  -- No free window: hand back the last window again (never nil), so the
  -- addon has to count free windows itself before changing anything.
  local last = _G["ChatFrame" .. NUM_CHAT_WINDOWS]
  last.name = name
  record("FCF_OpenNewWindow", name, tostring(noDefaultChannels), "reused", last.id)
  return last
end
function GetChatWindowInfo(id)
  local f = _G["ChatFrame" .. id]
  return f.name, 14, 0, 0, 0, 0.25, f.shown and true or false, false, f.isDocked, false
end
TEST_failOn = nil
function FCF_UnDockFrame(f) f.isDocked = nil; record("FCF_UnDockFrame", f.id) end
function FCF_SetTabPosition(f, x) record("FCF_SetTabPosition", f.id, x) end
function FCF_UpdateButtonSide(f) record("FCF_UpdateButtonSide", f.id) end
function FCF_SavePositionAndDimensions(f) record("FCF_SavePositionAndDimensions", f.id) end
"""


def to_py(value):
    if lua51.lua_type(value) == "table":
        return {k: to_py(v) for k, v in value.items()}
    return value


def lst(value):
    return list((value or {}).values()) if isinstance(value, dict) else value


class Session:
    def __init__(self, saved=None, known=KNOWN_GROUPS, general=GENERAL_GROUPS, methods=True, locale="enUS"):
        self.lua = lua51.LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(STUBS)
        g = self.g
        g.TEST_locale = locale
        g.TEST_installMethods(methods)
        g.TEST_makeFrames(self.table(general))
        if known is not None:
            g.ChatTypeGroup = self.table({name: ["CHAT_MSG_" + name] for name in known})
        if saved is not None:
            g.DevilForever_ChatSetupDB = self.table(saved)

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
        path = os.path.join(ADDON_DIR, "ChatSetup.lua")
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

    def groups(self, i):
        return lst(to_py(self.g["ChatFrame%d" % i].messageTypeList))

    def calls(self):
        return lst(to_py(self.g.TEST_calls))

    def db(self):
        return to_py(self.g.DevilForever_ChatSetupDB)


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


@case
def fresh_character_gets_three_windows():
    s = Session().load()
    eq(s.login(), 1, "one delayed run")
    eq(s.db(), {"setupVersion": 1, "result": "created", "windows": {"public": 1, "group": 3, "system": 4}}, "result")
    eq(s.groups(3), GROUP_ROLE, "window 2 groups")
    eq(s.groups(4), SYSTEM_ROLE, "window 3 groups (PING unknown to this client, skipped)")
    moved = set(GROUP_ROLE + SYSTEM_ROLE)
    eq(s.groups(1), [g for g in GENERAL_GROUPS if g not in moved], "window 1 keeps the public groups")
    eq("CHANNEL" in s.groups(1) and "SAY" in s.groups(1) and "YELL" in s.groups(1), True, "public chat in window 1")
    eq(s.groups(2), [], "combat log untouched")
    calls = s.calls()
    eq([c for c in calls if c.startswith("FCF_OpenNewWindow")],
       ["FCF_OpenNewWindow Group true 3", "FCF_OpenNewWindow System true 4"], "windows opened without default channels")
    eq([c for c in calls if c.startswith("SetPoint")],
       ["SetPoint 3 BOTTOMLEFT BOTTOMLEFT 502 40", "SetPoint 4 BOTTOMLEFT BOTTOMLEFT 1482 40"], "places")
    for i in (3, 4):
        for name in ("FCF_UnDockFrame", "FCF_SetTabPosition", "FCF_UpdateButtonSide", "FCF_SavePositionAndDimensions"):
            eq(sum(1 for c in calls if c.split(" ")[:2] == [name, str(i)]), 1, "%s once for %d" % (name, i))
    eq(s.g.ChatFrame3.isDocked, None, "window 2 undocked")
    eq(lst(to_py(s.g.TEST_printed)), ["DevilForever: three chat windows were made. Type /reload to finish the setup."],
       "reload asked once")
    eq(any("RemoveMessageGroup 2" in c or "AddMessageGroup 2" in c for c in calls), False, "no change on ChatFrame2")


@case
def later_sessions_keep_user_changes():
    first = Session().load()
    first.login()
    saved = first.db()
    # The user moves GUILD back to window 1 and closes window 3 in a later session.
    second = Session(saved=saved, general=[g for g in GENERAL_GROUPS
                                           if g not in set(GROUP_ROLE + SYSTEM_ROLE)] + ["GUILD"]).load()
    eq(second.login(), 0, "no run scheduled")
    eq(second.calls(), [], "no chat API call")
    eq(second.db(), saved, "stored result unchanged")
    eq("GUILD" in second.groups(1), True, "user value kept")


@case
def combat_delays_to_regen_enabled():
    s = Session().load()
    s.g.TEST_combat = True
    s.login()
    eq(s.db(), {}, "nothing stored in combat")
    eq(s.calls(), [], "no chat API call in combat")
    s.g.TEST_combat = False
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(s.g.TEST_runTimers(), 1, "run again after combat")
    eq(s.db()["result"], "created", "created after combat")
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    eq(s.g.TEST_runTimers(), 0, "no further run")


@case
def own_split_is_kept():
    s = Session()
    s.g.ChatFrame3.isDocked = 1
    s.g.ChatFrame3.messageTypeList = s.table(["GUILD", "OFFICER"])
    s.load().login()
    eq(s.db(), {"setupVersion": 1, "result": "kept-existing"}, "kept-existing")
    eq(s.calls(), [], "nothing changed")


@case
def unrelated_window_does_not_block():
    s = Session()
    s.g.ChatFrame3.isDocked = 1
    s.g.ChatFrame3.messageTypeList = s.table(["PET_BATTLE_INFO"])
    s.load().login()
    eq(s.db()["windows"], {"public": 1, "group": 4, "system": 5}, "free windows used")


@case
def free_window_count_checked_before_any_change():
    for free, docked in ((0, False), (1, False), (1, True)):
        s = Session()
        used = range(3, 11 - free)
        for i in used:
            if docked:
                s.g["ChatFrame%d" % i].isDocked = 1
            else:
                s.g["ChatFrame%d" % i].shown = True
        s.load().login()
        what = "%d free (%s)" % (free, "docked" if docked else "shown")
        eq(s.db(), {"setupVersion": 1, "result": "no-free-window"}, what + ": no-free-window")
        eq(s.calls(), [], what + ": no chat API call")
        eq(s.groups(1), GENERAL_GROUPS, what + ": window 1 unchanged")
        eq([s.groups(i) for i in range(2, 11)], [[]] * 9, what + ": other windows unchanged")
    two = Session()
    for i in range(3, 9):
        two.g["ChatFrame%d" % i].shown = True
    two.load().login()
    eq(two.db(), {"setupVersion": 1, "result": "created", "windows": {"public": 1, "group": 9, "system": 10}},
       "2 free: created in the free windows")
    eq(any("reused" in c for c in two.calls()), False, "no reused window")
    temp = Session()
    for i in range(3, 10):
        temp.g["ChatFrame%d" % i].shown = True
    temp.g.ChatFrame10.isTemporary = True
    temp.load().login()
    eq(temp.db()["result"], "no-free-window", "a temporary window is not free")


@case
def window_not_counted_as_free_stops():
    s = Session()
    s.g.ChatFrame4.shown = True
    s.g.ChatFrame5.shown = True
    s.load()
    # Window 3 and 6.. are free; the client hands back window 4 for the second window.
    s.lua.execute("""
      local open = FCF_OpenNewWindow
      local n = 0
      FCF_OpenNewWindow = function(name, x)
        n = n + 1
        if n == 2 then return ChatFrame4 end
        return open(name, x)
      end""")
    s.login()
    eq(s.db(), {"setupVersion": 1, "result": "no-free-window", "windows": {"public": 1, "group": 3}},
       "stopped, made window listed")
    eq(s.groups(4), [], "window 4 untouched")


@case
def interrupted_run_not_repeated():
    s = Session().load()
    s.g.TEST_failOn = "WHISPER"
    s.g.TEST_fire("PLAYER_ENTERING_WORLD", True, False)
    try:
        s.g.TEST_runTimers()
        raise AssertionError("the stub error did not stop the run")
    except lua51.LuaError:
        pass
    eq(s.db(), {"setupVersion": 1, "result": "in-progress", "windows": {"public": 1, "group": 3}}, "marker before the change")
    second = Session(saved=s.db()).load()
    eq(second.login(), 0, "no run scheduled")
    eq(second.db(), {"setupVersion": 1, "result": "interrupted", "windows": {"public": 1, "group": 3}}, "interrupted stored")
    eq(second.calls(), [], "no chat API call")
    third = Session(saved=second.db()).load()
    eq(third.login(), 0, "never again")
    eq(third.db()["result"], "interrupted", "kept")


@case
def api_missing_recorded():
    s = Session()
    s.g.FCF_OpenNewWindow = None
    s.load().login()
    eq(s.db(), {"setupVersion": 1, "result": "api-missing"}, "api-missing")
    eq(s.groups(1), GENERAL_GROUPS, "window 1 unchanged")


@case
def global_group_functions_used_without_methods():
    s = Session(methods=False).load()
    s.login()
    eq(s.groups(3), GROUP_ROLE, "groups added through ChatFrame_AddMessageGroup")
    eq(any(c.startswith("ChatFrame_RemoveMessageGroup 1 GUILD") for c in s.calls()), True, "removed from window 1")


@case
def korean_names_and_message():
    s = Session(locale="koKR").load()
    s.login()
    opened = [c for c in s.calls() if c.startswith("FCF_OpenNewWindow")]
    eq(opened, ["FCF_OpenNewWindow 파티·길드 true 3", "FCF_OpenNewWindow 전투·시스템 true 4"], "Korean names")
    eq(lst(to_py(s.g.TEST_printed)), ["DevilForever: 대화창 3개를 만들었습니다. /reload 를 입력하면 설정이 마무리됩니다."],
       "Korean message")


@case
def without_chat_type_group_every_name_used():
    s = Session(known=None).load()
    s.login()
    eq(s.groups(4), SYSTEM_ROLE[:5] + ["PING"] + SYSTEM_ROLE[5:], "PING used when ChatTypeGroup is absent")


@case
def wrong_type_saved_variable_replaced():
    s = Session(saved="broken").load()
    s.login()
    eq(s.db()["result"], "created", "own saved variable recreated")


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

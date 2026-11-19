"""Logic tests for DevilForever_ChatSetup (the three-window chat split).

Usage:  python -I Collection/tests/chatsetup/run.py

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
function Chat:GetScale() return self.scale or 1 end
function Chat:GetNumPoints() return self.point and 1 or 0 end
function Chat:SetShown(shown) self.shown = not not shown end
function Chat:GetText() return self.text or "" end
function Chat:SetText(text) self.text = text end
function Chat:GetPoint()
  if self.point then return self.point[1], UIParent, self.point[2], self.point[3], self.point[4] end
end
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
    _G["ChatFrame" .. i .. "Tab"] = setmetatable({id = i, width = 80, height = 20, shown = false, text = ""}, Chat)
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
function SetChatWindowName(id, name) _G["ChatFrame" .. id].name = name end
function SetChatWindowShown(id, shown) _G["ChatFrame" .. id].storedShown = shown end
function FCF_SetWindowName(frame, name, doNotSave)
  frame.name = name
  _G[frame:GetName() .. "Tab"]:SetText(name)
  record("FCF_SetWindowName", frame.id, name)
end
function FCF_CheckShowChatFrame(frame) frame:SetShown(true) end
function GetChatWindowInfo(id)
  local f = _G["ChatFrame" .. id]
  return f.name, 14, 0, 0, 0, 0.25, f.shown and true or false, false, f.isDocked, false
end
TEST_failOn = nil
function FCF_UnDockFrame(f) f.isDocked = nil; record("FCF_UnDockFrame", f.id) end
function FCF_SetTabPosition(f, x) record("FCF_SetTabPosition", f.id, x) end
function FCF_UpdateButtonSide(f) record("FCF_UpdateButtonSide", f.id) end
function FCF_SavePositionAndDimensions(f) record("FCF_SavePositionAndDimensions", f.id) end
function FCF_Close(f)
  f.shown, f.isDocked, f.name = false, nil, nil
  record("FCF_Close", f.id)
end
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

    def load(self, layout=False):
        namespace = self.lua.table()
        for filename in (("ChatLayout.lua", "ChatSetup.lua") if layout else ("ChatSetup.lua",)):
            path = os.path.join(ADDON_DIR, filename)
            with open(path, "rb") as fh:
                src = fh.read()
            result = self.g.loadstring(src, ("@" + os.path.relpath(path, REPO)).encode())
            fn, err = result if isinstance(result, tuple) else (result, None)
            if fn is None:
                raise AssertionError("compile failed: %s" % err)
            fn(ADDON, namespace)
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
    eq([c for c in calls if c.startswith("FCF_SetWindowName")],
       ["FCF_SetWindowName 3 Group", "FCF_SetWindowName 4 System"], "exact native slots named")
    eq(any(c.startswith("FCF_OpenNewWindow") for c in calls), False, "destructive opener not called")
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
    # A second activation fails after the first exact free slot was shown.
    s.lua.execute("""
      local show = FCF_CheckShowChatFrame
      FCF_CheckShowChatFrame = function(frame)
        if frame == ChatFrame6 then return end
        show(frame)
      end""")
    s.login()
    eq(s.db()["result"], "failed", "stopped")
    eq(s.groups(1), GENERAL_GROUPS, "original routing retained")
    eq(s.groups(3), [], "no partial routing")
    eq(s.g.ChatFrame3.shown, False, "activated frame hidden again")
    eq(s.g.ChatFrame4.shown, True, "existing frame not closed")
    eq(s.groups(4), [], "window 4 untouched")


@case
def interrupted_run_not_repeated():
    saved = {"setupVersion": 1, "result": "in-progress", "windows": {"public": 1, "group": 3}}
    second = Session(saved=saved).load()
    eq(second.login(), 0, "no run scheduled")
    eq(second.db(), {"setupVersion": 1, "result": "interrupted", "windows": {"public": 1, "group": 3}}, "interrupted stored")
    eq(second.calls(), [], "no chat API call")
    third = Session(saved=second.db()).load()
    eq(third.login(), 0, "never again")
    eq(third.db()["result"], "interrupted", "kept")


@case
def destination_failures_keep_original_routing():
    for mode in ("missing", "false", "silent", "exception"):
        s = Session().load()
        s.lua.execute("""
          local frame = ChatFrame3
          local method = getmetatable(frame).AddMessageGroup
          TEST_originalAdd = method
        """)
        if mode == "missing":
            s.lua.execute("getmetatable(ChatFrame3).AddMessageGroup = nil")
        elif mode == "false":
            s.lua.execute("getmetatable(ChatFrame3).AddMessageGroup = function() return false end")
        elif mode == "silent":
            s.lua.execute("getmetatable(ChatFrame3).AddMessageGroup = function() end")
        else:
            s.g.TEST_failOn = "WHISPER"
        s.login()
        eq(s.groups(1), GENERAL_GROUPS, mode + " original groups")
        eq(s.groups(2), [], mode + " combat log")
        eq(s.db()["result"] == "created", False, mode + " no success")
        eq(s.groups(3), [], mode + " partial additions removed")
        eq(s.groups(4), [], mode + " second destination empty")


@case
def removal_failure_restores_original_before_cleaning_destinations():
    s = layout_session()
    s.g.ChatFrame1.point = s.table(["BOTTOMLEFT", "BOTTOMLEFT", 32, 40])
    s.lua.execute("""
      local remove = getmetatable(ChatFrame1).RemoveMessageGroup
      getmetatable(ChatFrame1).RemoveMessageGroup = function(self, group)
        if self.id == 1 and group == "WHISPER" then return false end
        return remove(self, group)
      end
    """)
    s.login()
    eq(set(s.groups(1)), set(GENERAL_GROUPS), "all original routing restored")
    eq(s.groups(3), [], "group transaction undone")
    eq(s.groups(4), [], "system transaction undone")
    eq(s.db()["result"], "failed", "not created")
    eq(lst(to_py(s.g.ChatFrame1.point)), ["BOTTOMLEFT", "BOTTOMLEFT", 32, 40], "public original anchor restored")
    eq((s.g.ChatFrame1.width, s.g.ChatFrame1.height), (430, 120), "public original size restored")


@case
def hidden_authored_subscription_window_is_not_claimed():
    s = Session()
    s.g.ChatFrame3.messageTypeList = s.table(["PET_BATTLE_INFO"])
    s.load().login()
    eq(s.db()["result"], "created", "exact activation skips authored hidden slot")
    eq(s.db()["windows"]["group"], 4, "next free slot used")
    eq(s.groups(3), ["PET_BATTLE_INFO"], "hidden user filter kept")


@case
def native_allocation_candidate_is_checked_before_destructive_open():
    s = Session().load()
    s.g.ChatFrame3.name = "My old window"
    s.lua.execute("FCF_GetNextOpenChatWindowIndex = function() return 3 end")
    s.login()
    eq(s.db()["windows"]["group"], 4, "named hidden candidate skipped")
    eq(s.g.ChatFrame3.name, "My old window", "existing window name kept")
    for field in ("channelList", "privateMessageList", "bnConversationList"):
        filtered = Session().load()
        filtered.g.ChatFrame3[field] = filtered.table(["private-value"])
        filtered.lua.execute("FCF_GetNextOpenChatWindowIndex = function() return 3 end")
        filtered.login()
        eq(filtered.db()["windows"]["group"], 4, field + " prevents using authored slot")
        eq(lst(to_py(filtered.g.ChatFrame3[field])), ["private-value"], field + " preserved")


@case
def native_template_names_are_free_and_docked_hidden_public_stays_managed():
    s = layout_session()
    s.g.CHAT_NAME_TEMPLATE = "Chat %d"
    for i in range(3, 11):
        s.g["ChatFrame%d" % i].name = "Chat %d" % i
    s.g.VOICE = "Voice"
    s.g.ChatFrame3.name = "Voice"
    s.login()
    eq(s.db()["result"], "created", "client template name is not a personal name")
    s.g.ChatFrame1.shown = False
    s.g.TEST_preset = "qhd"
    s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
    s.g.TEST_runTimers()
    eq(s.g.ChatFrame1.width, 608, "tab-hidden docked public follows preset")
    eq("public" in s.db()["managedLayout"]["roles"], True, "public receipt kept")
    reserved = Session().load()
    reserved.lua.execute("""
      C_ChatInfo = {GetNumReservedChatWindows = function() return 3 end}
      FCF_GetNextOpenChatWindowIndex = function() return 3 end
      VOICE = "Voice"
      ChatFrame3.name = VOICE
    """)
    reserved.login()
    eq(reserved.db()["windows"]["group"], 4, "reserved Voice slot not activated")


@case
def newly_created_default_message_groups_are_normalized():
    s = Session().load()
    s.lua.execute("""
      local open = FCF_OpenNewWindow
      FCF_OpenNewWindow = function(...)
        local frame = open(...)
        frame.messageTypeList = {"SAY", "SYSTEM"}
        return frame
      end
    """)
    s.login()
    eq(s.db()["result"], "created", "created with client defaults")
    eq(s.groups(3), GROUP_ROLE, "role replaces new default groups")
    eq(s.groups(4), SYSTEM_ROLE, "system role exact")


def layout_session(preset="uhd", saved=None):
    s = Session(saved=saved)
    s.g.TEST_preset, s.g.TEST_pixel = preset, 1
    s.lua.execute("""
      DevilForever_Core = {Presets = {GetActive = function() return TEST_preset end},
        Edit = {RegisterCallback = function(self, owner, fn) TEST_edit = fn end}}
      DevilForever_Appearance = {GetPixelUnit = function() return TEST_pixel end}
    """)
    return s.load(layout=True)


@case
def managed_layout_tracks_three_presets_and_screen_scale_without_overlap():
    s = layout_session()
    s.login()
    eq(len(s.db()["managedLayout"]["roles"]), 3, "receipts created")
    filters = [s.groups(i) for i in (1, 3, 4)]
    for preset, system_x in (("fhd", 1492), ("qhd", 1952), ("uhd", 2910)):
        s.g.TEST_preset = preset
        s.g.TEST_edit("appearance.chat1")
        s.g.TEST_runTimers()
        eq(s.g.ChatFrame4.point[3], system_x, preset + " follows active preset")
        a, b, c = s.g.ChatFrame1, s.g.ChatFrame3, s.g.ChatFrame4
        eq(a.point[3] + a.width < b.point[3], True, "public-group gap")
        eq(b.point[3] + b.width < c.point[3], True, "group-system gap")
    s.g.TEST_pixel = 0.5
    s.g.TEST_fire("UI_SCALE_CHANGED")
    s.g.TEST_runTimers()
    eq(s.g.ChatFrame4.point[3], 1455, "screen scale reflow")
    eq([s.groups(i) for i in (1, 3, 4)], filters, "filters untouched")
    s.g.TEST_calls = s.table([])
    s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
    s.g.TEST_runTimers()
    eq(s.calls(), [], "same desired geometry writes zero")


@case
def managed_layout_protects_manual_move_close_and_combat():
    s = layout_session()
    s.login()
    s.g.ChatFrame3.point[3] = 1234
    s.g.ChatFrame4.shown = False
    s.g.TEST_combat = True
    s.g.TEST_preset = "qhd"
    s.g.TEST_calls = s.table([])
    s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
    s.g.TEST_runTimers()
    eq(s.calls(), [], "combat zero writes")
    s.g.TEST_combat = False
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    s.g.TEST_runTimers()
    eq(s.g.ChatFrame3.point[3], 1234, "manual move kept")
    eq(s.g.ChatFrame4.point[3], 2910, "closed frame not moved")
    eq(set(s.db()["managedLayout"]["roles"]), {"public"}, "manual roles released")
    eq(s.g.ChatFrame1.width, 608, "unmodified public role follows preset")


@case
def reload_retains_receipts_and_legacy_created_remains_unmanaged():
    first = layout_session()
    first.login()
    saved = first.db()
    second = layout_session("qhd", saved=saved)
    for role, receipt in saved["managedLayout"]["roles"].items():
        frame = second.g["ChatFrame%d" % receipt["id"]]
        frame.shown = True
        frame.isDocked = 1 if receipt["docked"] else None
        frame.width, frame.height = receipt["width"], receipt["height"]
        frame.point = second.table([receipt["point"], receipt["relativePoint"], receipt["x"], receipt["y"]])
    second.login()
    eq(second.g.ChatFrame4.point[3], 1952, "reload reflow using receipt")
    legacy = layout_session("qhd", saved={"setupVersion": 1, "result": "created", "windows": saved["windows"]})
    legacy.login()
    eq(legacy.calls(), [], "legacy has no geometry permission")


@case
def malformed_receipt_is_ignored_and_layout_failure_restores_geometry():
    s = layout_session()
    s.login()
    s.g.DevilForever_ChatSetupDB.managedLayout.roles.group = "invalid"
    s.g.TEST_preset = "qhd"
    s.lua.execute("""
      local set = ChatFrame4.SetPoint
      ChatFrame4.SetPoint = function(self, ...)
        ChatFrame4.SetPoint = set
        error("injected placement error")
      end
    """)
    s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
    s.g.TEST_runTimers()
    eq(s.g.ChatFrame4.point[3], 2910, "failed layout restored anchor")
    eq(s.g.ChatFrame4.width, 922, "failed layout restored width")
    eq(s.db()["managedLayout"]["roles"].get("group"), None, "malformed role released")


@case
def hidden_slot_messages_draft_and_input_history_survive_success_and_rollback():
    for failure in (False, "groups", "activation"):
        s = Session().load()
        s.lua.execute("""
          ChatFrame3.messages = {"existing message"}
          ChatFrame3.editBox = {draft = "unsent draft", history = {"previous input"}}
          FCF_OpenNewWindow = function()
            ChatFrame3.messages = {}
            ChatFrame3.editBox.history = {}
            error("destructive opener must not run")
          end
        """)
        if failure == "groups":
            s.g.TEST_failOn = "WHISPER"
        elif failure == "activation":
            s.lua.execute("""
              local show = FCF_CheckShowChatFrame
              FCF_CheckShowChatFrame = function(frame) if frame ~= ChatFrame4 then show(frame) end end
            """)
        s.login()
        eq(lst(to_py(s.g.ChatFrame3.messages)), ["existing message"], "message preserved")
        eq(s.g.ChatFrame3.editBox.draft, "unsent draft", "draft preserved")
        eq(lst(to_py(s.g.ChatFrame3.editBox.history)), ["previous input"], "input history preserved")
        if failure:
            eq(s.g.ChatFrame3.shown, False, "slot hidden after rollback")
            eq(s.g.ChatFrame3.name, None, "slot native name restored")
            eq(s.g.ChatFrame3.point, None, "slot original anchors restored")
            eq((s.g.ChatFrame3.width, s.g.ChatFrame3.height), (430, 120), "slot original size restored")
            eq(s.groups(1), GENERAL_GROUPS, "source routing preserved")
        else:
            eq(s.db()["result"], "created", "both windows ready")
            for index in (3, 4):
                eq(s.g["ChatFrame%d" % index].shown, True, "new frame shown")
                eq(s.g["ChatFrame%dTab" % index].shown, True, "new tab shown")
                eq(s.g["ChatFrame%d" % index].storedShown, True, "native visibility stored")


@case
def reflow_reports_worst_result_for_first_and_last_role_failures():
    for index, role in ((1, "public"), (4, "system")):
        s = layout_session()
        s.login()
        s.g.TEST_preset = "qhd"
        s.lua.execute("""
          local frame = _G["ChatFrame" .. TEST_failFrame]
          local original = frame.SetPoint
          frame.SetPoint = function(self, ...)
            frame.SetPoint = original
            error("one-time reflow failure")
          end
        """.replace("TEST_failFrame", str(index)))
        s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
        s.g.TEST_runTimers()
        status = to_py(s.g.DevilForever_ChatSetup.GetLayoutStatus())
        eq(status["state"], "failed-restored", "failure not masked by later successful role")
        eq(status["roles"][role], "failed-restored", "role failure visible")
        successful = "system" if role == "public" else "public"
        eq(status["roles"][successful], "applied", "other role success also visible")


@case
def source_rollback_failure_keeps_remaining_route_visible():
    s = Session().load()
    s.lua.execute("""
      local methods = getmetatable(ChatFrame1)
      local add, remove = methods.AddMessageGroup, methods.RemoveMessageGroup
      methods.AddMessageGroup = function(self, group)
        if self.id == 1 and group == "GUILD" then return false end
        return add(self, group)
      end
      methods.RemoveMessageGroup = function(self, group)
        if self.id == 1 and group == "WHISPER" then return false end
        return remove(self, group)
      end
    """)
    s.login()
    eq(s.db()["result"], "rollback-failed", "failed restoration reported")
    eq("GUILD" in s.groups(1), False, "source add failed")
    eq("GUILD" in s.groups(3), True, "destination still carries the group")
    eq(s.g.ChatFrame3.shown, True, "remaining route stays visible")
    eq(s.g.ChatFrame3.name, "Group", "remaining route keeps role title")


@case
def public_rollback_preserves_every_original_anchor():
    s = layout_session()
    s.lua.execute("""
      local frame = ChatFrame1
      frame.points = {{"TOPLEFT", UIParent, "TOPLEFT", 20, -30}, {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -40, 50}}
      frame.GetNumPoints = function(self) return #self.points end
      frame.GetPoint = function(self, index) return unpack(self.points[index or 1] or {}) end
      frame.ClearAllPoints = function(self) self.points = {} end
      frame.SetPoint = function(self, ...) self.points[#self.points + 1] = {...} end
      local remove = frame.RemoveMessageGroup
      frame.RemoveMessageGroup = function(self, group)
        if group == "WHISPER" then return false end
        return remove(self, group)
      end
    """)
    s.login()
    eq(s.db()["result"], "failed", "rollback completed")
    eq(len(s.g.ChatFrame1.points), 2, "both anchors restored")
    eq(s.g.ChatFrame1.points[1][1], "TOPLEFT", "first anchor")
    eq(s.g.ChatFrame1.points[2][1], "BOTTOMRIGHT", "second anchor")
    eq((s.g.ChatFrame1.points[1][4], s.g.ChatFrame1.points[2][5]), (20, 50), "original offsets")


@case
def skin_only_assigns_saved_roles_after_created_and_always_keeps_public_fallback():
    for result in ("created", "failed", "interrupted", "in-progress", "no-free-window"):
        s = Session(saved={"result": result, "windows": {"public": 1, "group": 3, "system": 4}})
        s.lua.execute("""
          TEST_fonts = {}
          for i = 1, 10 do
            _G["ChatFrame" .. i].SetFont = function(self) TEST_fonts[#TEST_fonts + 1] = self.id end
          end
          DevilForever_Core = {
            Edit = {Get = function() return {font = {path = "mock", size = 14}} end,
              RegisterCallback = function() end},
            Theme = {RegisterCallback = function() end}}
          DevilForever_Appearance = {GetPixelUnit = function() return 1 end}
        """)
        path = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Skin_NativeChat", "Skin.lua")
        with open(path, "rb") as fh:
            s.g.loadstring(fh.read())()
        s.g.TEST_fire("PLAYER_LOGIN")
        eq(lst(to_py(s.g.TEST_fonts)), [1, 3, 4] if result == "created" else [1], result + " assigned roles")


@case
def api_missing_recorded():
    s = Session()
    s.g.FCF_SetWindowName = None
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
    opened = [c for c in s.calls() if c.startswith("FCF_SetWindowName")]
    eq(opened, ["FCF_SetWindowName 3 파티·길드", "FCF_SetWindowName 4 전투·시스템"], "Korean names")
    eq(lst(to_py(s.g.TEST_printed)), ["DevilForever: 대화창 3개를 만들었습니다. /reload 를 입력하면 설정이 마무리됩니다."],
       "Korean message")


@case
def without_chat_type_group_only_subscribed_messages_move():
    for has_ping in (False, True):
        general = list(GENERAL_GROUPS)
        system = list(SYSTEM_ROLE)
        if has_ping:
            general.append("PING")
            system.insert(5, "PING")
        s = Session(known=None, general=general).load()
        s.login()
        eq(s.groups(4), system, "PING moved only when originally subscribed")


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

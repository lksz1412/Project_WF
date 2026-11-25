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
    eq(s.g.ChatFrame1.width, 555, "tab-hidden docked public follows preset")
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


def layout_session(preset="uhd", saved=None, edit_mode=None, requested=None):
    s = Session(saved=saved)
    s.g.TEST_preset, s.g.TEST_pixel = preset, 1
    s.g.TEST_requested = requested
    if edit_mode is not None:
        s.g.TEST_layoutIndex = edit_mode
        s.lua.execute("""
          C_EditMode={GetLayouts=function() return {activeLayout=TEST_layoutIndex} end}
          EditModePresetLayoutManager={presetLayoutInfo={{},{}}}
          UIParent.GetWidth=function() return 3840 end
          UIParent.GetHeight=function() return 2160 end
        """)
    s.lua.execute("""
      DevilForever_Core = {Presets = {GetActive = function() return TEST_preset end,
        GetAppliedRequest = function() return TEST_requested end},
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
    eq(s.g.ChatFrame1.width, 555, "unmodified public role follows preset")


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


def native_public_reset(s):
    s.g.ChatFrame1.width, s.g.ChatFrame1.height = 430, 170
    s.g.ChatFrame1.point = s.table(["BOTTOMLEFT", "BOTTOMLEFT", 32, 240])


def created_public_session(saved=None, requested="uhd", edit_mode=1):
    if saved is None:
        saved = {"setupVersion": 1, "result": "created", "windows": {"public": 1, "group": 4, "system": 5},
                 "managedLayout": {"version": 1, "roles": {}}}
    s = layout_session(saved=saved, edit_mode=edit_mode, requested=requested)
    native_public_reset(s)
    for index, x, width in ((4, 970, 944), (5, 2910, 922)):
        f = s.g["ChatFrame%d" % index]
        f.shown = True
        f.width, f.height = width, 244
        f.point = s.table(["TOPLEFT", "TOPLEFT", x, -1828])
    return s


@case
def explicit_public_recovery_keeps_other_frames_messages_and_next_reload():
    s = created_public_session()
    s.g.ChatFrame1.messages = s.table(["old message"])
    s.g.ChatFrame1.editBox = s.table({"draft": "draft", "history": ["old input"]})
    groups = [s.groups(i) for i in (1, 2, 4, 5)]
    s.login()
    eq((s.g.ChatFrame1.width, s.g.ChatFrame1.height), (868, 244), "explicit request restores public")
    eq(lst(to_py(s.g.ChatFrame1.point)), ["TOPLEFT", "TOPLEFT", 60, -1828], "public target")
    eq(all(c.split()[1] == "1" for c in s.calls()), True, "only public geometry APIs")
    eq([s.groups(i) for i in (1, 2, 4, 5)], groups, "routing preserved")
    eq(lst(to_py(s.g.ChatFrame1.messages)), ["old message"], "message preserved")
    eq(to_py(s.g.ChatFrame1.editBox), {"draft": "draft", "history": {1: "old input"}}, "input preserved")
    nxt = created_public_session(saved=s.db(), requested=None)
    nxt.login()
    eq(nxt.g.ChatFrame1.width, 868, "next plain reload restores native fallback")
    eq(all(c.split()[1] == "1" for c in nxt.calls()), True, "reload still public only")


@case
def public_anchor_normalization_and_builtin_reapply_preserve_ownership():
    first = created_public_session()
    first.login()
    s = created_public_session(saved=first.db(), requested=None)
    s.g.ChatFrame1.width, s.g.ChatFrame1.height = 868, 244
    s.g.ChatFrame1.point = s.table(["BOTTOMLEFT", "BOTTOMLEFT", 60, 88])
    s.login()
    eq(s.calls(), [], "same physical rectangle under bottom anchor needs no write")
    eq("public" in s.db()["managedLayout"]["roles"], True, "receipt retained")
    native_public_reset(s)
    s.g.TEST_fire("EDIT_MODE_LAYOUTS_UPDATED")
    s.g.TEST_runTimers()
    eq(s.g.ChatFrame1.width, 868, "native builtin reapplied after login repaired")


@case
def public_manual_move_and_custom_editmode_release_management():
    first = created_public_session()
    first.login()
    for custom in (False, True):
        s = created_public_session(saved=first.db(), requested=None, edit_mode=3 if custom else 1)
        s.g.ChatFrame1.point = s.table(["BOTTOMLEFT", "BOTTOMLEFT", 99, 300])
        s.login()
        eq(s.calls(), [], "custom/manual geometry untouched")
        eq("public" in s.db()["managedLayout"]["roles"], False, "public management released")
    fresh = layout_session(edit_mode=3)
    native_public_reset(fresh)
    fresh.login()
    eq((fresh.g.ChatFrame1.width, fresh.g.ChatFrame1.height), (430, 170), "fresh custom public unchanged")
    eq("public" in fresh.db()["managedLayout"]["roles"], False, "fresh custom public not claimed")


@case
def legacy_without_receipt_and_changed_builtin_recover_only_explicitly():
    saved = {"setupVersion": 1, "result": "created", "windows": {"public": 1, "group": 4, "system": 5}}
    s = created_public_session(saved=saved)
    s.login()
    eq(s.g.ChatFrame1.width, 868, "legacy without managedLayout schedules explicit settle")
    saved = s.db()
    second = created_public_session(saved=saved, edit_mode=2)
    second.g.ChatFrame1.point = second.table(["BOTTOMLEFT", "BOTTOMLEFT", 50, 250])
    second.login()
    eq(second.db()["managedLayout"]["publicFallback"]["preset"], 2, "new builtin replaces old fallback id")
    nxt = created_public_session(saved=second.db(), requested=None, edit_mode=2)
    nxt.g.ChatFrame1.point = nxt.table(["BOTTOMLEFT", "BOTTOMLEFT", 50, 250])
    nxt.login()
    eq(nxt.g.ChatFrame1.width, 868, "new builtin fallback survives plain reload")


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


# Chattynator ------------------------------------------------------------------
# Chattynator's own Core/Objects.lua, Core/Constants.lua, Core/Config.lua,
# Core/Initialize.lua, Skins/Main.lua, Skins/Dark.lua and the patched
# Skins/DevilForever.lua run on one addon table, so the seed goes through
# Chattynator's real config functions. Messages, chat frames and widgets are stubs.

CHATTY_DIR = os.path.join(REPO, "Collection", "AddOns", "Chattynator")
CHATTY_FILES = ("Core/Objects.lua", "Core/Constants.lua", "Core/Config.lua", "Core/Initialize.lua",
                "Skins/Main.lua", "Skins/Dark.lua", "Skins/DevilForever.lua")
PUBLIC_HIDDEN = ["TRADESKILLS", "COMBAT_MISC_INFO", "COMBAT_XP_GAIN", "PET_BATTLE_COMBAT_LOG", "PET_INFO", "OPENING",
                 "VOICE_TEXT"]
CHATTY_GROUP = ["WHISPER", "BN_WHISPER", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "GUILD_DISCORD", "PARTY",
                "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
                "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL"]

def _preset_items(preset):
    import re
    path = os.path.join(REPO, "Collection", "AddOns", "!DevilForever_Core", "Presets", preset + ".lua")
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    items = {}
    for match in re.finditer(r'\["appearance\.(\w+)"\] = \{(.*?)\n    \},', text, re.S):
        body = match.group(2)
        items[match.group(1)] = {key: float(re.search(r'\["%s"\] = (-?[\d.]+)' % key, body).group(1))
                                 for key in ("x", "y", "width", "height")}
    return items


PRESETS = ("fhd", "qhd", "uhd")
GEOMETRY_ITEMS = {preset: _preset_items(preset) for preset in PRESETS}

CHATTY_STUBS = r"""
function strsplit(sep, text)
  local out = {}
  for part in (text .. sep):gmatch("(.-)%" .. sep) do out[#out + 1] = part end
  return unpack(out)
end
function CopyTable(t)
  local out = {}
  for k, v in pairs(t) do out[k] = type(v) == "table" and CopyTable(v) or v end
  return out
end
function Mixin(target, ...)
  for i = 1, select("#", ...) do for k, v in pairs((select(i, ...))) do target[k] = v end end
  return target
end
function CreateFromMixins(...) return Mixin({}, ...) end
function GetKeysArray(t) local out = {} for k in pairs(t) do out[#out + 1] = k end return out end
function tIndexOf(t, v) for i, x in ipairs(t) do if x == v then return i end end end
function tAppendAll(t, s) for _, v in ipairs(s) do t[#t + 1] = v end end
function tFilter(t, pred) local out = {} for _, v in ipairs(t) do if pred(v) then out[#out + 1] = v end end return out end
function GetBuildInfo() return "1.60.1", "1", "Nov 1 2026", 16001 end
function CreateTextureMarkup() return "" end
function CallErrorHandler(err) error(err) end
function hooksecurefunc(target, name, hook)
  local original = target[name]
  target[name] = function(...)
    local results = {original(...)}
    hook(...)
    return unpack(results)
  end
end
TEST_events = {}
CallbackRegistryMixin = {
  OnLoad = function(self) self.callbacks = {} end,
  GenerateCallbackEvents = function() end,
  RegisterCallback = function(self, event, fn, owner)
    self.callbacks[event] = self.callbacks[event] or {}
    table.insert(self.callbacks[event], {fn, owner})
  end,
  TriggerEvent = function(self, event, ...)
    TEST_events[#TEST_events + 1] = event
    for _, entry in ipairs(self.callbacks[event] or {}) do entry[1](entry[2], ...) end
  end,
}
TEST_loaded = {Chattynator = true}
C_AddOns = {IsAddOnLoaded = function(name) return TEST_loaded[name] == true end}
CHATTYNATOR_CURRENT_PROFILE = nil

local Widget = {}
function TEST_widget()
  return setmetatable({}, Widget)
end
Widget.__index = function(t, key)
  if key == "GetUnboundedStringWidth" then return function() return 40 end end
  if key == "GetText" then return function(self) return self.text or "" end end
  if key == "SetText" then return function(self, text) self.text = text end end
  if key == "GetName" then return function() return "TEST_Widget" end end
  if key == "GetFontString" then return function(self) self.fs = self.fs or TEST_widget(); return self.fs end end
  if key == "SetTextColor" then return function(self, r, g, b) self.color = {r, g, b} end end
  if key == "SetShown" then return function(self, shown) self.shown = shown end end
  if key == "SetColorTexture" then return function(self, r, g, b, a) self.colorTexture = {r, g, b, a} end end
  if key:match("^Create") then return function() return TEST_widget() end end
  if key:match("^Get") or key:match("^Is") then return function() end end
  if key:match("^%u") then return function() end end
end
"""


def chatty_session(preset="uhd", saved=None, config=None, profile=None, channels=(), core=True, chatty=True):
    """Session with Chattynator files loaded on one addon table and ChatSetup (layout + Chattynator + setup)."""
    s = Session(saved=saved)
    s.lua.execute(CHATTY_STUBS)
    s.lua.execute("""
      local frame_ = CreateFrame
      CreateFrame = function(...)
        local f = frame_(...)
        f.Hide, f.Show = function() end, function() end
        return f
      end
    """)
    g = s.g
    g.TEST_preset, g.TEST_pixel = preset, 1
    g.TEST_loaded.Chattynator = chatty
    if core:
        s.lua.execute("""
          TEST_editCallbacks, TEST_themeCallbacks = {}, {}
          TEST_chat1Font = {size = 28}
          DevilForever_Core = {
            Presets = {GetActive = function() return TEST_preset end, GetAppliedRequest = function() return nil end},
            Edit = {RegisterCallback = function(self, owner, fn) table.insert(TEST_editCallbacks, fn) end,
                    Get = function(self, key)
                      local name = key:match("^appearance%.(.*)")
                      local item = name and TEST_panels and TEST_panels[TEST_preset] and TEST_panels[TEST_preset][name]
                      if not item then return {font = TEST_chat1Font} end
                      return {position = {point = "TOPLEFT", relativeTo = "DevilForever_AppearanceRoot",
                                          relativePoint = "TOPLEFT", x = item.x, y = item.y},
                              size = {width = item.width, height = item.height}, font = TEST_chat1Font}
                    end},
            Theme = {Get = function(self, token)
                       if token == "color.accent" then return {0.75, 0.33, 0.19, 1} end
                       if token == "border.size" then return TEST_border end
                       return {0.5, 0.5, 0.5, 1}
                     end,
                     RegisterCallback = function(self, owner, fn) table.insert(TEST_themeCallbacks, fn) end}}
          DevilForever_Appearance = {GetPixelUnit = function() return TEST_pixel end}
          function TEST_edit(key) for _, fn in ipairs(TEST_editCallbacks) do fn(key) end end
        """)
    g.TEST_border = 1
    g.TEST_panels = s.table({preset: GEOMETRY_ITEMS[preset] for preset in PRESETS})
    if config is not None:
        g.CHATTYNATOR_CONFIG = s.table(config)
    g.CHATTYNATOR_CURRENT_PROFILE = profile
    s.chatty = s.lua.table()
    s.chatty.Locales = s.lua.eval("setmetatable({}, {__index = function(_, key) return key end})")
    for name in CHATTY_FILES:
        path = os.path.join(CHATTY_DIR, name)
        with open(path, "rb") as fh:
            fn = g.loadstring(fh.read(), ("@Chattynator/" + name).encode())
        (fn[0] if isinstance(fn, tuple) else fn)("Chattynator", s.chatty)
    s.set_channels(channels)
    s.lua.execute("""
      function TEST_chattyLoaded(addonTable)
        addonTable.Config.InitializeData()
        addonTable.Core.MigrateSettings()
        -- Skins/Blizzard.lua is not loaded here; Initialize only reads its constants.
        addonTable.Skins.availableSkins.blizzard = addonTable.Skins.availableSkins.blizzard
          or {key = "blizzard", options = {}, constants = function() end}
        addonTable.Skins.Initialize()
        addonTable.Messages = {GetChannels = function() return TEST_channelMap, TEST_channelCount end}
        addonTable.allChatFrames = {{UpdateEditBox = function() end}}
      end
    """)
    g.TEST_chattyLoaded(s.chatty)
    namespace = s.lua.table()
    for filename in ("ChatLayout.lua", "Chattynator.lua", "ChatSetup.lua"):
        path = os.path.join(ADDON_DIR, filename)
        with open(path, "rb") as fh:
            fn = g.loadstring(fh.read(), ("@" + filename).encode())
        (fn[0] if isinstance(fn, tuple) else fn)(ADDON, namespace)
    s.namespace = namespace
    return s


def _set_channels(self, names):
    self.g.TEST_channelMap = self.table({i: n for i, n in enumerate(names, 1)})
    self.g.TEST_channelCount = len(names)


Session.set_channels = _set_channels


def windows(s):
    return to_py(s.g.CHATTYNATOR_CONFIG.Profiles[s.g.CHATTYNATOR_CURRENT_PROFILE].windows)


def option(s, key):
    return to_py(s.g.CHATTYNATOR_CONFIG.Profiles[s.g.CHATTYNATOR_CURRENT_PROFILE][key])


def true_keys(table):
    return sorted(k for k, v in (table or {}).items() if v is True)


def false_keys(table):
    return sorted(k for k, v in (table or {}).items() if v is False)


@case
def chattynator_seed_writes_three_windows_once():
    s = chatty_session(channels=("General", "Trade", "LocalDefense", "LookingForGroup"))
    s.login()
    w = windows(s)
    eq(len(w), 3, "three windows")
    eq([w[i]["position"] for i in (1, 2, 3)],
       [{1: "TOPLEFT", 2: "UIParent", 3: "TOPLEFT", 4: 0, 5: -1801},
        {1: "TOPLEFT", 2: "UIParent", 3: "TOPLEFT", 4: 954, 5: -1801},
        {1: "TOPLEFT", 2: "UIParent", 3: "TOPLEFT", 4: 2886, 5: -1801}],
       "uhd places: tab rows centred on the theme strip (1804-1820), sides from the chat panels")
    eq([w[i]["size"] for i in (1, 2, 3)], [{1: 952, 2: 322}, {1: 953, 2: 327}, {1: 953, 2: 327}],
       "uhd sizes from the chat panels")
    public = w[1]["tabs"][1]
    eq((public["name"], public["invert"]), ("GENERAL", True), "window 1 public tab")
    eq(false_keys(public["groups"]), sorted(PUBLIC_HIDDEN + CHATTY_GROUP), "window 1 hides group types only")
    eq(true_keys(public["channels"]), ["General", "LocalDefense", "Trade"], "channels 1-3 in window 1")
    eq(false_keys(public["channels"]), ["LookingForGroup"], "looking-for-group not in window 1")
    eq(w[1]["tabs"][2]["custom"], "combat_log", "combat log tab kept")
    eq(len(w[1]["tabs"]), 2, "default GUILD tab moved out")
    group = w[2]["tabs"][1]
    eq((group["name"], group.get("invert")), ("Group", None), "window 2 tab")
    eq(true_keys(group["groups"]), sorted(CHATTY_GROUP), "window 2 groups")
    lfg = w[3]["tabs"][1]
    eq((lfg["name"], true_keys(lfg["channels"]), lfg["groups"]), ("Looking for Group", ["LookingForGroup"], {}),
       "window 3 looking-for-group only")
    eq([option(s, k) for k in ("store_messages", "show_tabs_1", "show_buttons", "button_position")],
       [False, "hover", "hover", "inside_left"], "messages not stored, chrome on hover")
    state = s.db()["chattynator"]
    eq(state["profiles"], {"DEFAULT": "seeded"}, "seed flag per profile")
    eq(s.db().get("result"), None, "native setup not run")
    eq([c for c in s.calls() if c.split(" ")[0] in ("SetPoint", "AddMessageGroup", "FCF_SetWindowName")], [],
       "no native chat window call")
    eq("SettingChanged" in lst(to_py(s.g.TEST_events)), True, "Chattynator told through its own Config.Set")


@case
def chattynator_second_run_and_user_changes_are_left_alone():
    first = chatty_session(channels=("General", "Trade"))
    first.login()
    saved, config = first.db(), to_py(first.g.CHATTYNATOR_CONFIG)
    second = chatty_session(saved=saved, config=config, profile="DEFAULT", channels=("General", "Trade"))
    second.login()
    eq(windows(second), config["Profiles"]["DEFAULT"]["windows"], "second run: windows unchanged")
    eq(second.db()["chattynator"]["profiles"], {"DEFAULT": "seeded"}, "flag kept")
    # Another character of the same profile: no flag in its own saved variable, config no longer default.
    other = chatty_session(config=config, profile="DEFAULT", channels=("General",))
    other.login()
    eq(windows(other), config["Profiles"]["DEFAULT"]["windows"], "seeded config not reseeded")
    eq(other.db()["chattynator"]["profiles"], {"DEFAULT": "kept"}, "not untouched -> kept")
    # A user who moved Chattynator's default window before the first seed.
    fresh = chatty_session(channels=("General",))
    fresh.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[1].position[5] = 300")
    before = windows(fresh)
    fresh.login()
    eq(windows(fresh), before, "user-moved default window untouched")
    eq(fresh.db()["chattynator"]["profiles"], {"DEFAULT": "kept"}, "kept recorded")
    for change in ("tabs[2].groups.PARTY = true", "tabs[1].channels.Trade = false", "size[1] = 501"):
        edited = chatty_session(channels=("General",))
        edited.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[1]." + change)
        edited.login()
        eq(len(windows(edited)), 1, change + ": not seeded")
    combat = chatty_session(channels=("General",))
    combat.g.TEST_combat = True
    combat.login()
    eq(len(windows(combat)), 1, "combat: nothing yet")
    combat.g.TEST_combat = False
    combat.g.TEST_fire("PLAYER_REGEN_ENABLED")
    combat.g.TEST_runTimers()
    eq(len(windows(combat)), 3, "seeded after combat")


@case
def chattynator_lfg_joined_later_lands_in_window_three_once():
    s = chatty_session(channels=("General", "Trade"))
    s.login()
    eq(windows(s)[3]["tabs"][1]["channels"], {}, "window 3 empty without the channel")
    s.set_channels(("General", "Trade", "파티 찾기"))
    s.g.TEST_combat = True
    s.g.TEST_fire("CHAT_MSG_CHANNEL_NOTICE", "YOU_JOINED")
    s.g.TEST_runTimers()
    eq(windows(s)[3]["tabs"][1]["channels"], {}, "combat: not yet")
    s.g.TEST_combat = False
    s.g.TEST_fire("PLAYER_REGEN_ENABLED")
    s.g.TEST_runTimers()
    w = windows(s)
    eq(true_keys(w[3]["tabs"][1]["channels"]), ["파티 찾기"], "Korean channel name to window 3")
    eq(w[1]["tabs"][1]["channels"].get("파티 찾기"), False, "removed from window 1")
    # The user showed the channel in window 2 already: no move.
    t = chatty_session(channels=("General",))
    t.login()
    t.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[2].tabs[1].channels.LookingForGroup = true")
    t.set_channels(("General", "LookingForGroup"))
    t.g.TEST_fire("CHANNEL_UI_UPDATE")
    t.g.TEST_runTimers()
    eq(windows(t)[3]["tabs"][1]["channels"], {}, "assigned elsewhere: window 3 unchanged")
    # Profiles this module did not seed are not touched.
    u = chatty_session(channels=("General",))
    u.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[1].size[2] = 300")
    u.login()
    u.set_channels(("General", "LookingForGroup"))
    u.g.TEST_fire("CHANNEL_UI_UPDATE")
    u.g.TEST_runTimers()
    eq(len(windows(u)), 1, "kept profile: no window added")


@case
def chattynator_unmoved_windows_follow_preset_moved_ones_stay():
    s = chatty_session(channels=("General",))
    s.login()
    s.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[2].position[4] = 1234")
    s.g.TEST_preset = "qhd"
    s.g.TEST_edit("appearance.chat1")
    s.g.TEST_runTimers()
    w = windows(s)
    eq((w[1]["position"][4], w[1]["size"][1]), (0, 617), "window 1 follows qhd")
    eq(w[2]["position"][4], 1234, "moved window 2 kept")
    eq((w[3]["position"][4], w[3]["size"][1]), (1941, 618), "window 3 follows qhd")
    eq(sorted(s.db()["chattynator"]["layout"]["windows"]), [1, 3], "moved window released")
    s.g.TEST_pixel = 0.5
    s.g.TEST_fire("UI_SCALE_CHANGED")
    s.g.TEST_runTimers()
    eq(windows(s)[3]["position"][4], 969.5, "screen scale reflow")


@case
def chattynator_disables_native_chat_and_absent_chattynator_keeps_it():
    native = layout_session()
    native.login()
    s = chatty_session(saved=native.db(), channels=("General",))
    for receipt in native.db()["managedLayout"]["roles"].values():
        frame = s.g["ChatFrame%d" % receipt["id"]]
        frame.shown = True
        frame.width, frame.height = receipt["width"], receipt["height"]
        frame.point = s.table([receipt["point"], receipt["relativePoint"], receipt["x"] + 7, receipt["y"]])
    s.lua.execute("""
      TEST_fonts = {}
      for i = 1, 10 do _G["ChatFrame" .. i].SetFont = function(self) TEST_fonts[#TEST_fonts + 1] = self.id end end
    """)
    path = os.path.join(REPO, "Collection", "AddOns", "DevilForever_Skin_NativeChat", "Skin.lua")
    with open(path, "rb") as fh:
        s.g.loadstring(fh.read())()
    s.login()
    eq(lst(to_py(s.g.TEST_fonts)), [], "native skin idle")
    s.g.TEST_fire("DISPLAY_SIZE_CHANGED")
    s.g.TEST_runTimers()
    status = to_py(s.g.DevilForever_ChatSetup.GetLayoutStatus())
    eq(status["state"], "chattynator", "native layout idle while Chattynator is loaded")
    eq([c for c in s.calls() if c.startswith(("SetPoint", "SetSize"))], [], "no native geometry call")
    absent = chatty_session(chatty=False, channels=("General",))
    absent.login()
    eq(absent.db()["result"], "created", "native split when Chattynator is not loaded")
    eq(len(windows(absent)), 1, "Chattynator config untouched")


@case
def chattynator_skin_default_once_and_without_core():
    s = chatty_session(channels=("General",))
    eq(option(s, "current_skin"), "devilforever", "first run selects the Devil Forever skin")
    s.g.TEST_chattyTable = s.chatty
    s.lua.execute("TEST_chattyTable.Config.Set('current_skin', 'dark')")
    config = to_py(s.g.CHATTYNATOR_CONFIG)
    again = chatty_session(config=config, profile="DEFAULT", channels=("General",))
    eq(option(again, "current_skin"), "dark", "user's later pick kept")
    # Profiles that already used Chattynator (no disabled_skins entry for this skin) keep their skin.
    used = to_py(s.g.CHATTYNATOR_CONFIG)
    used["Profiles"]["DEFAULT"]["current_skin"] = "dark"
    used["Profiles"]["DEFAULT"]["disabled_skins"] = {}
    used["Profiles"]["DEFAULT"]["windows"][1]["size"][2] = 300
    moved = chatty_session(config=used, profile="DEFAULT", channels=("General",))
    eq(option(moved, "current_skin"), "dark", "used profile (windows changed) keeps dark")
    picked = to_py(s.g.CHATTYNATOR_CONFIG)
    picked["Profiles"]["DEFAULT"]["current_skin"] = "blizzard"
    picked["Profiles"]["DEFAULT"]["disabled_skins"] = {}
    own = chatty_session(config=picked, profile="DEFAULT", channels=("General",))
    eq(option(own, "current_skin"), "blizzard", "used profile (own skin) keeps it")
    seeded = chatty_session(channels=("General",))
    seeded.login()
    after = chatty_session(config=to_py(seeded.g.CHATTYNATOR_CONFIG), profile="DEFAULT", channels=("General",))
    eq(option(after, "current_skin"), "devilforever", "seeded profile keeps the skin chosen in its first session")
    bare = chatty_session(core=False, channels=("General",))
    bare.g.TEST_chattyTable = bare.chatty
    bare.lua.execute("""
      local skin = TEST_chattyTable.Skins.availableSkins.devilforever
      skin.constants()
      skin.initializer()
      TEST_frame = TEST_widget()
      TEST_frame.ScrollingMessagesWrapper = TEST_widget()
      skin.skinner({regionType = "ChatFrame", region = TEST_frame})
    """)
    eq(bare.g.TEST_frame.background is not None, True, "without Core: Dark look applied, no error")
    eq(bare.g.TEST_frame.background.colorTexture, None, "Dark look, not the transparent Devil body")


@case
def chattynator_skin_follows_theme_and_chat_font():
    s = chatty_session(channels=("General",))
    s.g.TEST_chattyTable = s.chatty
    s.login()
    s.lua.execute("""
      local skin = TEST_chattyTable.Skins.availableSkins.devilforever
      TEST_tab = TEST_widget()
      TEST_tab.SetSelected = function(self, state) self.selected = state end
      TEST_tab.SetFlashing = function(self, state) self.flashing = state end
      skin.skinner({regionType = "ChatTab", region = TEST_tab})
      TEST_tab:SetSelected(true)
    """)
    eq(lst(to_py(s.g.TEST_tab.fs.color)), [0.75, 0.33, 0.19], "selected tab in the theme accent")
    eq(option(s, "message_font_size"), 28, "font size = appearance.chat1 size x pixel unit")
    s.g.TEST_pixel = 0.5
    s.g.TEST_fire("UI_SCALE_CHANGED")
    eq(option(s, "message_font_size"), 14, "follows the pixel unit")
    s.g.TEST_chattyTable.Config.Set("message_font_size", 20)
    s.g.TEST_pixel = 1
    s.g.TEST_fire("UI_SCALE_CHANGED")
    eq(option(s, "message_font_size"), 20, "user's own size kept")


@case
def chattynator_edit_box_stays_at_scale_one():
    s = chatty_session(channels=("General",))
    s.g.TEST_chattyTable = s.chatty
    s.lua.execute("""
      LibStub = function() return {Fetch = function() return nil end} end
      FindValueInTableIf = function(t, pred) for _, v in ipairs(t) do if pred(v) then return v end end end
      TEST_fontNames = {}
      function GetFonts() return TEST_fontNames end
      local function fontObject(file, height, flags)
        local o = {file = file, height = height, flags = flags, shadow = {0, 0}, shadowColor = {0, 0, 0, 0}}
        function o:GetFont() return self.file, self.height, self.flags end
        function o:SetShadowOffset(x, y) self.shadow = {x, y} end
        function o:GetShadowOffset() return unpack(self.shadow) end
        function o:SetShadowColor(...) self.shadowColor = {...} end
        function o:GetShadowColor() return unpack(self.shadowColor) end
        return o
      end
      local function family(members)
        local f = {members = {}, color = {1, 1, 1, 1}}
        for _, m in ipairs(members) do f.members[m.alphabet] = fontObject(m.file, m.height, m.flags) end
        function f:GetFontObjectForAlphabet(a) return self.members[a] end
        function f:SetJustifyH() end
        function f:SetTextColor(...) self.color = {...} end
        function f:GetTextColor() return unpack(self.color) end
        return f
      end
      function CreateFontFamily(name, members)
        _G[name] = family(members)
        table.insert(TEST_fontNames, name)
        return _G[name]
      end
      ChatFontNormal = family({{alphabet = "roman", file = "Fonts/FRIZQT__.TTF", height = 14, flags = ""},
        {alphabet = "korean", file = "Fonts/2002.TTF", height = 14, flags = ""},
        {alphabet = "simplifiedchinese", file = "Fonts/ARKai_T.ttf", height = 14, flags = ""},
        {alphabet = "traditionalchinese", file = "Fonts/blei00d.TTF", height = 14, flags = ""},
        {alphabet = "russian", file = "Fonts/FRIZQT___CYR.TTF", height = 14, flags = ""}})
      local box = TEST_widget()
      box.scale, box.height, box.points, box.header = 1, 0, {}, TEST_widget()
      box.header.IsObjectType = function(_, kind) return kind == "FontString" end
      box.header.SetFontObject = function(self, font) self.font = font end
      function box:SetScale(v) self.scale = v end
      function box:GetScale() return self.scale end
      function box:SetHeight(v) self.height = v end
      function box:GetHeight() return self.height end
      function box:ClearAllPoints() self.points = {} end
      function box:SetPoint(...) table.insert(self.points, {...}) end
      function box:SetFontObject(font) self.font = font end
      function box:GetRegions() return self.header end
      ChatFrame1EditBox = box
      TEST_chattyTable.Display = TEST_chattyTable.Display or {}
    """)
    for name in ("Core/Fonts.lua", "Display/Main.lua"):
        with open(os.path.join(CHATTY_DIR, name), "rb") as fh:
            fn = s.g.loadstring(fh.read(), ("@Chattynator/" + name).encode())
        (fn[0] if isinstance(fn, tuple) else fn)("Chattynator", s.chatty)
    s.lua.execute("""
      local chat = setmetatable({}, {__index = TEST_chattyTable.Display.ChatFrameMixin})
      chat.ScrollingMessagesWrapper = TEST_widget()
      chat.ScrollingMessagesWrapper.SetPoint = function(self, ...) self.point = {...} end
      function chat:GetID() return 1 end
      function chat:GetClampRectInsets() return 0, 0, 0, 3 end
      TEST_chatFrame = chat
      function TEST_update(size)
        TEST_chattyTable.Config.Set("message_font_size", size)
        TEST_chatFrame:UpdateEditBox()
      end
    """)
    for size in (28, 21, 14):
        s.g.TEST_update(size)
        box = s.g.ChatFrame1EditBox
        factor = size / 14
        eq(box.GetScale(box), 1, "size %d: edit box scale stays 1" % size)
        eq(box.height, 32 * factor, "size %d: height = edit box height x factor" % size)
        font = s.g[box.font]
        eq((font.members.roman.height, font.members.korean.height, font.members.korean.file),
           (14 * factor, 14 * factor, "Fonts/2002.TTF"), "size %d: text size scaled, Korean font file kept" % size)
        eq(box.header.font, box.font, "size %d: header uses the same scaled font" % size)
        # Same place as upstream's scaled box: offsets were in the box's scaled space.
        top_left = to_py(box.points[1])
        eq(top_left[5], (0 + 32 - 3 * factor) * factor, "size %d: anchor offset as before" % size)
        eq(to_py(s.g.TEST_chatFrame.ScrollingMessagesWrapper.point)[3], 6 + 32 * factor - 3,
           "size %d: message area bottom as before" % size)
    eq(s.g.ChatFrame1EditBox.font, "ChattynatorFontdefault", "factor 1: the message font itself")


def message_area(window, public):
    """Chattynator's message area (left, top, right, bottom as TOPLEFT y) of a window config."""
    x, top = window["position"][4], window["position"][5]
    width, height = window["size"][1], window["size"][2]
    bottom = top - height
    return x + 2, top - 27, x + width, bottom if public else bottom + 5


def panel_inner(preset, key, pixel, border=1, side=0):
    item = GEOMETRY_ITEMS[preset][key]
    top, bottom = -item["y"] + border, -item["y"] + item["height"] - border
    return ((item["x"] + side) * pixel, -top * pixel, (item["x"] + item["width"] - side) * pixel,
            -bottom * pixel)


def strip_centre(preset, pixel):
    item = GEOMETRY_ITEMS[preset]["ribbon"]
    return (item["y"] - item["height"] / 2) * pixel


def check_fit(w, preset, pixel, what, border=1, side=0, screen=None):
    """Tab rows centred on the strip, message area sides and bottom on the panel inner rectangle,
    message top inside it, sizes within Chattynator's resize bounds, nothing past the screen."""
    for index, key in enumerate(("chat1", "chat2", "chat3"), start=1):
        window = w[index]
        left, top, right, bottom = message_area(window, index == 1)
        want = panel_inner(preset, key, pixel, border, side)
        name = "%s window %d" % (what, index)
        eq(round(left, 6), round(max(want[0], 2), 6), name + " left")
        eq([round(right, 6), round(bottom, 6)], [round(want[2], 6), round(want[3], 6)], name + " right/bottom")
        centre, strip = window["position"][5] - 11, strip_centre(preset, pixel)
        if abs(centre - strip) > 1e-6:  # only when the panel's inner top holds the message area down
            eq((abs(top - want[1]) < 1e-6, centre < strip), (True, True),
               name + " tab row below the strip centre only with the message top on the inner top (%s, %s)" % (centre, strip))
        eq(top <= want[1] + 1e-9, True, name + " message top inside the panel (%s <= %s)" % (top, want[1]))
        eq(window["size"][1] >= 240 and window["size"][2] >= 140, True, name + " within the resize bounds")
        if screen is not None:
            eq(window["position"][4] + window["size"][1] <= screen + 1e-6, True, name + " inside the screen")


@case
def section_structure_three_equal_chat_panels_two_pixel_seams():
    # The section structure every theme follows (appearance-28-devil-structure.md): chat1 | chat2 | action |
    # minimap | chat3 across the screen, 2-pixel seams between them, the three chat panels the same width.
    order = ("chat1", "seam1", "chat2", "seam2", "action", "seam3", "minimap", "seam4", "chat3")
    for preset, width in (("fhd", 1920), ("qhd", 2560), ("uhd", 3840)):
        items = GEOMETRY_ITEMS[preset]
        x = 0
        for key in order:
            eq(items[key]["x"], x, "%s %s starts where the previous section ends" % (preset, key))
            x += items[key]["width"]
        eq(x, width, preset + " sections fill the screen width")
        eq(len({items[k]["width"] for k in ("chat1", "chat2", "chat3")}), 1, preset + " three chat panels the same width")
        eq({items[k]["width"] for k in ("seam1", "seam2", "seam3", "seam4")}, {2}, preset + " seams 2 px")
        eq(items["minimap"]["width"], items["minimap"]["height"], preset + " minimap panel square")


@case
def chattynator_message_area_is_the_panel_inner_rect():
    for preset in PRESETS:
        for pixel in (1, 0.75):
            s = chatty_session(preset=preset, channels=("General",))
            s.g.TEST_pixel = pixel
            s.login()
            # A panel on the left screen edge: the window is clamped to the screen, so its
            # message area starts 2 units inside the panel (check_fit).
            check_fit(windows(s), preset, pixel, "%s pixel %s" % (preset, pixel), border=1, side=1)
            eq(option(s, "button_position"), "inside_left", "buttons overlay the message area")
    # Section structure: one section border (fhd 6 / qhd 8 / uhd 12, Composition parts border) inside
    # every side of each chat panel, whatever the theme; HUD parts also clear their caps and joints.
    for preset, border in (("fhd", 6), ("qhd", 8), ("uhd", 12)):
        for theme_border in (1, 2):  # the theme's own edge size does not change the section geometry
            s = chatty_session(preset=preset, channels=("General",))
            s.g.TEST_border = theme_border
            s.lua.execute("DevilForever_Composition = {active = true, parts = {sizes = {%s = {joint = 32, cap = 96, border = %d}}}}"
                          % (preset, border))
            s.login()
            check_fit(windows(s), preset, 1, "%s section border" % preset, border=border, side=border)
    p = chatty_session(channels=("General",))
    p.lua.execute("""
      DevilForever_Composition = {active = true, partsShown = true,
        parts = {sizes = {uhd = {joint = 32, cap = 96, border = 12}}},
        partsPlan = {preset = "uhd", joints = {954, 1909, 2580, 2886}, bounds = {width = 3840}}}
    """)
    p.login()
    w = windows(p)
    # HUD parts draw their frame inside the section border too (appearance-28): the same inner rectangle
    eq([message_area(w[i], i == 1)[0] for i in (1, 2, 3)], [12, 967, 2899], "parts: left edges one border in")
    eq([message_area(w[i], i == 1)[2] for i in (1, 2, 3)], [941, 1896, 3828], "parts: right edges one border in")


@case
def chattynator_windows_seeded_earlier_follow_the_panels_moved_ones_stay():
    s = chatty_session(channels=("General",))
    s.login()
    # The rectangles an earlier seed wrote (native chat rectangles), still unmoved by the user.
    s.lua.execute("""
      local old = {{60, -1828, 868, 244}, {970, -1828, 944, 244}, {2910, -1828, 922, 244}}
      local state = DevilForever_ChatSetupDB.chattynator.layout.windows
      for i, r in ipairs(old) do
        local w = CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[i]
        w.position = {"TOPLEFT", "UIParent", "TOPLEFT", r[1], r[2]}
        w.size = {r[3], r[4]}
        state[i] = {position = {"TOPLEFT", "UIParent", "TOPLEFT", r[1], r[2]}, size = {r[3], r[4]}}
      end
      CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[3].position[4] = 2800
    """)
    s.g.TEST_fire("UI_SCALE_CHANGED")
    s.g.TEST_runTimers()
    w = windows(s)
    eq((w[1]["position"][5], w[1]["size"][2]), (-1801, 322), "unmoved window 1 now has its tab row on the strip")
    eq((w[2]["position"][4], w[2]["position"][5]), (954, -1801), "unmoved window 2 follows")
    eq((w[3]["position"][4], w[3]["position"][5]), (2800, -1828), "window 3 moved by the user stays")
    eq(sorted(s.db()["chattynator"]["layout"]["windows"]), [1, 2], "moved window released")


# The user's saved state after the Step 61 build (uhd, UI scale 0.64 = 1200 / 2160 units per pixel,
# dwarf theme on the prepared composition): window 1's receipt is gone (Chattynator raised its
# 135.6-unit seed height to its 140-unit resize bound, so it never matched again), windows 2 and 3
# carry the Step 61 rule's places. Values copied from WTF/.../SavedVariables/Chattynator.lua and
# .../92/<character>/SavedVariables/DevilForever_ChatSetup.lua.
USER_WINDOWS = [
    (("TOPLEFT", "UIParent", "TOPLEFT", 33.33333587646484, -1011.111389160156), (491.6666564941406, 140.0000152587891)),
    (("TOPLEFT", "UIParent", "TOPLEFT", 532.444456390209, -984.1111337112061), (535.3333452542626, 200.8888926638499)),
    (("TOPLEFT", "UIParent", "TOPLEFT", 1610.222258258198, -984.1111337112061), (523.1111227588524, 200.8888926638499)),
]


@case
def chattynator_users_saved_windows_are_placed_again_once():
    pixel = 1200 / 2160
    config = {"Version": 1, "Profiles": {"DEFAULT": {"windows": [
        {"position": list(pos), "size": list(size), "tabs": [{"name": name, "channels": {}, "groups": {}}]}
        for (pos, size), name in zip(USER_WINDOWS, ("GENERAL", "파티·길드", "파티 찾기"))]}}}
    saved = {"chattynator": {"version": 1, "lfgTab": "파티 찾기", "lfg": "파티찾기", "profiles": {"DEFAULT": "seeded"},
             "layout": {"preset": "uhd", "windows": {2: {"position": list(USER_WINDOWS[1][0]),
                                                         "size": list(USER_WINDOWS[1][1])},
                                                     3: {"position": list(USER_WINDOWS[2][0]),
                                                         "size": list(USER_WINDOWS[2][1])}}}}}
    s = chatty_session(saved=saved, config=config, profile="DEFAULT", channels=("General", "파티찾기"))
    s.g.TEST_pixel = pixel
    s.lua.execute("DevilForever_Composition = {active = true, parts = {sizes = {uhd = {joint = 32, cap = 96, border = 12}}}}")
    s.login()
    w = windows(s)
    for index, (pos, size) in enumerate(USER_WINDOWS, start=1):
        eq(w[index]["position"][5] == pos[4] and w[index]["size"][2] == size[1], False, "window %d moved" % index)
    check_fit(w, "uhd", pixel, "user uhd 0.64", border=12, side=12, screen=3840 * pixel)
    state = s.db()["chattynator"]["layout"]
    eq((state["version"], sorted(state["windows"])), (2, [1, 2, 3]), "placed once, all three receipts kept")
    # A later drag is respected: the next follow releases the moved window and leaves it.
    s.lua.execute("CHATTYNATOR_CONFIG.Profiles.DEFAULT.windows[1].position[4] = 400")
    s.g.TEST_fire("UI_SCALE_CHANGED")
    s.g.TEST_runTimers()
    eq((windows(s)[1]["position"][4], sorted(s.db()["chattynator"]["layout"]["windows"])), (400, [2, 3]),
       "after the one placement a moved window stays where the user put it")


@case
def chattynator_edit_box_gets_one_scale_change_ending_at_one_on_load():
    s = chatty_session(channels=("General",))
    s.lua.execute("""
      TEST_scales = {}
      ChatFrame1EditBox = {SetScale = function(self, v) table.insert(TEST_scales, v) end}
    """)
    s.login()  # PLAYER_ENTERING_WORLD timer: seed, follow, edit box
    s.g.TEST_runTimers()  # next frame
    eq(lst(to_py(s.g.TEST_scales)), [0.99, 1], "one scale change after the setup, ending at 1")


@case
def chattynator_time_column_off_seed_and_once_for_seeded_profiles_user_choice_kept():
    s = chatty_session(channels=("General",))
    s.login()
    eq(option(s, "timestamp_format"), " ", "seed: Chattynator's None (no time column)")
    eq(s.db()["chattynator"]["timestamps"], "set", "seed marks it")
    for stored, want in ((None, " "), ("%H:%M", "%H:%M")):
        config = {"Version": 1, "Profiles": {"DEFAULT": {"windows": [
            {"position": list(pos), "size": list(size), "tabs": [{"name": "t", "channels": {}, "groups": {}}]}
            for pos, size in USER_WINDOWS]}}}
        if stored is not None:
            config["Profiles"]["DEFAULT"]["timestamp_format"] = stored
        saved = {"chattynator": {"version": 1, "profiles": {"DEFAULT": "seeded"}, "lfgTab": "t",
                 "layout": {"preset": "uhd", "version": 2, "windows": {}}}}
        u = chatty_session(saved=saved, config=config, profile="DEFAULT", channels=("General",))
        u.login()
        eq(option(u, "timestamp_format"), want, "seeded earlier with %r: %r" % (stored, want))
        eq(u.db()["chattynator"]["timestamps"], "set", "done once")
        u.lua.execute('CHATTYNATOR_CONFIG.Profiles.DEFAULT.timestamp_format = "%X"')  # the player turns it back on
        u.g.TEST_fire("UI_SCALE_CHANGED")
        u.g.TEST_runTimers()
        eq(option(u, "timestamp_format"), "%X", "a later choice of the player stays")


@case
def chattynator_numbered_and_second_lfg_channels_go_to_window_three():
    s = chatty_session(channels=("General", "LocalDefense"))
    s.login()
    s.set_channels(("General", "LocalDefense", "Trade", "Services", "파티찾기 2"))
    s.g.TEST_fire("CHAT_MSG_CHANNEL_NOTICE", "YOU_JOINED")
    s.g.TEST_runTimers()
    w = windows(s)
    eq(true_keys(w[3]["tabs"][1]["channels"]), ["파티찾기 2"], "'파티찾기 2' (custom, numbered) to window 3")
    eq(w[1]["tabs"][1]["channels"].get("파티찾기 2"), False, "and out of window 1")
    s.set_channels(("General", "LocalDefense", "Trade", "Services", "파티찾기 2", "LookingForGroup"))
    s.g.TEST_fire("CHANNEL_UI_UPDATE")
    s.g.TEST_runTimers()
    w = windows(s)
    eq(true_keys(w[3]["tabs"][1]["channels"]), sorted(["LookingForGroup", "파티찾기 2"]),
       "second looking-for-group channel joined later also to window 3")
    eq(false_keys(w[1]["tabs"][1]["channels"]), sorted(["LookingForGroup", "파티찾기 2"]), "both out of window 1")
    both = chatty_session(channels=("General", "파티찾기 2", "LookingForGroup"))
    both.login()
    eq(true_keys(windows(both)[3]["tabs"][1]["channels"]), sorted(["LookingForGroup", "파티찾기 2"]),
       "seed: every looking-for-group channel in window 3")


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

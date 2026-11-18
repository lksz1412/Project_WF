-- Three chat windows, made once per character with the client chat API:
--   window 1 = ChatFrame1 (public: say, yell, emote, channels such as General
--              and Trade, and every group not listed below),
--   window 2 = new window (guild, party, raid, instance, whispers),
--   window 3 = new window (system, errors, experience, honor, reputation,
--              skill, loot, money, currency and other game messages).
-- The combat log window (ChatFrame2) is not touched.
--
-- Runs a few seconds after the first PLAYER_ENTERING_WORLD of a session, out of
-- combat (a combat start delays it to PLAYER_REGEN_ENABLED). Once a result is
-- stored in DevilForever_ChatSetupDB (per character) it never runs again for
-- that character, so later changes made in the game are kept. Result:
--   "created"        both windows made; db.windows = {public, group, system} ids
--   "kept-existing"  a window 3..N already shows one of the moved groups (the
--                    character has its own split); nothing changed
--   "no-free-window" fewer than two free chat windows (counted before any
--                    change: ids 3..N, not shown, not docked, not temporary);
--                    nothing changed. Also stored, with db.windows listing what
--                    was made, when the client hands back a window that was
--                    not counted as free.
--   "api-missing"    FCF_OpenNewWindow is not there; nothing changed
--   "in-progress"    written just before the first change; a later login that
--                    finds it stores "interrupted" and does not run again
--   "interrupted"    an earlier run stopped after "in-progress"; db.windows
--                    lists the windows made before it stopped
-- Only chat frames are changed (not protected frames). A message asks for a
-- /reload after "created": windows made by an addon are fully set up by the
-- client after a reload.

local DB_NAME = "DevilForever_ChatSetupDB"
local SETUP_VERSION = 1
local DELAY = 3     -- seconds after PLAYER_ENTERING_WORLD / end of combat
local GAP = 40      -- pixels between window 1 and window 2 (room for the button column)
local EDGE = 8      -- pixels from the right screen edge for window 3

local ROLES = {
  {key = "group", names = {koKR = "파티·길드", default = "Group"}, groups = {
    "GUILD", "OFFICER", "GUILD_ACHIEVEMENT",
    "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING",
    "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
    "WHISPER", "BN_WHISPER",
  }},
  {key = "system", names = {koKR = "전투·시스템", default = "System"}, groups = {
    "SYSTEM", "ERRORS", "IGNORED", "TARGETICONS", "BN_INLINE_TOAST_ALERT", "PING",
    "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE",
    "SKILL", "LOOT", "CURRENCY", "MONEY", "TRADESKILLS", "OPENING", "PET_INFO", "COMBAT_MISC_INFO",
    "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL",
  }},
}

local MESSAGES = {
  koKR = "DevilForever: 대화창 3개를 만들었습니다. /reload 를 입력하면 설정이 마무리됩니다.",
  default = "DevilForever: three chat windows were made. Type /reload to finish the setup.",
}

local function localized(t)
  local locale = type(GetLocale) == "function" and GetLocale() or nil
  return t[locale] or t.default
end

local function maxWindows()
  if type(NUM_CHAT_WINDOWS) == "number" then return NUM_CHAT_WINDOWS end
  local c = type(Constants) == "table" and Constants.ChatFrameConstants
  if type(c) == "table" and type(c.MaxChatWindows) == "number" then return c.MaxChatWindows end
  return 10
end

-- A group name the client does not define is skipped; without ChatTypeGroup
-- every listed name is used.
local function knownGroup(group)
  return type(ChatTypeGroup) ~= "table" or ChatTypeGroup[group] ~= nil
end

local function addGroup(frame, group)
  if frame.AddMessageGroup then
    frame:AddMessageGroup(group)
  elseif ChatFrame_AddMessageGroup then
    ChatFrame_AddMessageGroup(frame, group)
  end
end

local function removeGroup(frame, group)
  if frame.RemoveMessageGroup then
    frame:RemoveMessageGroup(group)
  elseif ChatFrame_RemoveMessageGroup then
    ChatFrame_RemoveMessageGroup(frame, group)
  end
end

-- True when a window other than 1 and 2 (docked or shown) already carries one
-- of the groups this setup would move.
local function hasOwnSplit()
  local moved = {}
  for _, role in ipairs(ROLES) do
    for _, group in ipairs(role.groups) do moved[group] = true end
  end
  for i = 3, maxWindows() do
    local frame = _G["ChatFrame" .. i]
    if frame and (frame.isDocked or (frame.IsShown and frame:IsShown())) then
      for _, group in ipairs(frame.messageTypeList or {}) do
        if moved[group] then return true end
      end
    end
  end
  return false
end

-- Undocks `frame` and puts it next to window 1 (slot 1) or at the right edge
-- (slot 2), with window 1's size; the client saves the place.
local function place(frame, slot, general)
  if FCF_UnDockFrame then FCF_UnDockFrame(frame) end
  local width, height = general:GetWidth(), general:GetHeight()
  frame:SetSize(width, height)
  local x, y
  if slot == 1 then
    x, y = (general:GetRight() or width) + GAP, general:GetBottom() or 0
  else
    x, y = UIParent:GetWidth() - width - EDGE, general:GetBottom() or 0
  end
  frame:ClearAllPoints()
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", math.max(0, x), math.max(0, y))
  if FCF_SetTabPosition then FCF_SetTabPosition(frame, 0) end
  if FCF_UpdateButtonSide then FCF_UpdateButtonSide(frame) end
  if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(frame) end
end

-- Ids of chat windows the client can hand out: 3 (or the first id after the
-- reserved ones) .. N, neither shown nor docked, not temporary.
local function freeWindows()
  local info = FCF_GetChatWindowInfo or GetChatWindowInfo
  local reserved = C_ChatInfo and C_ChatInfo.GetNumReservedChatWindows and C_ChatInfo.GetNumReservedChatWindows() or 2
  local free = {}
  for id = math.max(3, reserved + 1), maxWindows() do
    local chatFrame = _G["ChatFrame" .. id]
    if chatFrame and not chatFrame.isTemporary then
      local shown = info and select(7, info(id))
      if not shown and not chatFrame.isDocked then free[id] = true end
    end
  end
  return free
end

local function count(set)
  local n = 0
  for _ in pairs(set) do n = n + 1 end
  return n
end

local function database()
  local db = _G[DB_NAME]
  if type(db) ~= "table" then
    db = {}
    _G[DB_NAME] = db
  end
  return db
end

local function finish(db, result, windows)
  db.setupVersion = SETUP_VERSION
  db.result = result
  db.windows = windows
end

local frame = CreateFrame("Frame")
local waitingForCombatEnd = false

-- Returns the stored result, or nil when it has to wait for the end of combat.
local function setup()
  local db = database()
  if db.result ~= nil then return db.result end
  if InCombatLockdown() then
    waitingForCombatEnd = true
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    return nil
  end
  if type(FCF_OpenNewWindow) ~= "function" then
    finish(db, "api-missing", nil)
    return db.result
  end
  if hasOwnSplit() then
    finish(db, "kept-existing", nil)
    return db.result
  end
  local free = freeWindows()
  if count(free) < #ROLES then
    finish(db, "no-free-window", nil)
    return db.result
  end
  local general = _G.ChatFrame1
  local windows = {public = general:GetID()}
  finish(db, "in-progress", windows)
  for slot, role in ipairs(ROLES) do
    local chatFrame = FCF_OpenNewWindow(localized(role.names), true)
    local id = chatFrame and chatFrame:GetID()
    if not id or not free[id] then
      finish(db, "no-free-window", windows)
      return db.result
    end
    free[id] = nil
    windows[role.key] = id
    for _, group in ipairs(role.groups) do
      if knownGroup(group) then
        addGroup(chatFrame, group)
        removeGroup(general, group)
      end
    end
    place(chatFrame, slot, general)
  end
  finish(db, "created", windows)
  print(localized(MESSAGES))
  return db.result
end

local function later()
  C_Timer.After(DELAY, setup)
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    local db = database()
    if db.result == "in-progress" then
      db.result = "interrupted"
    elseif db.result == nil then
      later()
    end
  elseif event == "PLAYER_REGEN_ENABLED" and waitingForCombatEnd then
    waitingForCombatEnd = false
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    later()
  end
end)

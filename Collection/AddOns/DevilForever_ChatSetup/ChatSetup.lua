-- Split subscribed public messages into two new windows; preserve ChatFrame2.
-- Stored results prevent reinitialization; layout receipts separately manage geometry.

local _, addon = ...
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

-- Without ChatTypeGroup, the public window's subscriptions identify available groups.
local function knownGroup(group)
  return type(ChatTypeGroup) ~= "table" or ChatTypeGroup[group] ~= nil
end

local function groupAPI(frame, action)
  local method = frame[action .. "MessageGroup"]
  if type(method) == "function" then return function(group) return method(frame, group) end end
  local global = _G["ChatFrame_" .. action .. "MessageGroup"]
  if type(global) == "function" then return function(group) return global(frame, group) end end
end

local function subscriptions(frame)
  local groups = frame and frame.messageTypeList
  if frame and type(groups) ~= "table" and type(GetChatWindowMessages) == "function" then
    groups = {GetChatWindowMessages(frame:GetID())}
  end
  if type(groups) ~= "table" then return nil end
  local set = {}
  for _, group in ipairs(groups) do set[group] = true end
  return set
end

local function changeGroup(frame, action, group, wanted)
  local api = groupAPI(frame, action)
  if not api or api(group) == false then error("message group API refused " .. action .. " " .. group) end
  local current = subscriptions(frame)
  if not current or not not current[group] ~= wanted then error("message group verification failed: " .. group) end
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

local function placePrepared(frame, role)
  local layout = type(addon) == "table" and addon.GetPreparedChatWindow
  local bounds = layout and layout(role)
  if not bounds then return false end
  if role ~= "public" and FCF_UnDockFrame then FCF_UnDockFrame(frame) end
  frame:SetSize(bounds.width, bounds.height)
  frame:ClearAllPoints()
  frame:SetPoint(bounds.point, UIParent, bounds.point, bounds.x, bounds.y)
  if role ~= "public" then
    if FCF_SetTabPosition then FCF_SetTabPosition(frame, 0) end
    if FCF_UpdateButtonSide then FCF_UpdateButtonSide(frame) end
  end
  if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(frame) end
  return true
end

-- Without an appearance layout, use the public window's size and bottom edge.
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
      local name = info and info(id)
      local shown = info and select(7, info(id))
      local groups = subscriptions(chatFrame)
      local defaultName = type(CHAT_NAME_TEMPLATE) == "string" and pcall(string.format, CHAT_NAME_TEMPLATE, id)
      if defaultName then defaultName = string.format(CHAT_NAME_TEMPLATE, id) end
      local unnamed = name == nil or name == "" or (type(defaultName) == "string" and name == defaultName)
        or (id == 3 and type(VOICE) == "string" and name == VOICE)
      local channels = chatFrame.channelList
      local private = chatFrame.privateMessageList
      local bn = chatFrame.bnConversationList
      if not shown and not chatFrame.isDocked and unnamed and groups and not next(groups)
          and (channels == nil or type(channels) == "table" and not next(channels))
          and (private == nil or type(private) == "table" and not next(private))
          and (bn == nil or type(bn) == "table" and not next(bn)) then free[id] = true end
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

local function geometry(widget)
  if not widget or type(widget.GetPoint) ~= "function" then error("chat geometry unavailable") end
  local saved = {width = widget:GetWidth(), height = widget:GetHeight(), points = {}}
  for i = 1, (widget.GetNumPoints and widget:GetNumPoints() or 1) do
    local point = {widget:GetPoint(i)}
    if point[1] then saved.points[#saved.points + 1] = point end
  end
  return saved
end

local function restoreGeometry(widget, saved)
  widget:SetSize(saved.width, saved.height)
  widget:ClearAllPoints()
  for _, point in ipairs(saved.points) do widget:SetPoint(unpack(point)) end
  if widget:GetWidth() ~= saved.width or widget:GetHeight() ~= saved.height then error("chat size restore failed") end
  local count = widget.GetNumPoints and widget:GetNumPoints() or #saved.points
  if count ~= #saved.points then error("chat anchor restore failed") end
  for i, expected in ipairs(saved.points) do
    local actual = {widget:GetPoint(i)}
    for j = 1, 5 do if actual[j] ~= expected[j] then error("chat anchor restore failed") end end
  end
end

local function saveSlot(destination)
  local tab = _G[destination:GetName() .. "Tab"]
  if not tab or type(destination.SetShown) ~= "function" or type(tab.SetShown) ~= "function" then error("chat visibility API unavailable") end
  local info = FCF_GetChatWindowInfo or GetChatWindowInfo
  return {frame = destination, tab = tab, name = info(destination:GetID()), frameName = destination.name,
    tabText = tab:GetText(), shown = destination:IsShown(), tabShown = tab:IsShown(),
    frameGeometry = geometry(destination), tabGeometry = geometry(tab), buttonSide = destination.buttonSide}
end

local function restoreSlot(saved)
  local destination = saved.frame
  FCF_SetWindowName(destination, saved.name or "", true)
  SetChatWindowName(destination:GetID(), saved.name or "")
  destination.name = saved.frameName
  saved.tab:SetText(saved.tabText or "")
  restoreGeometry(destination, saved.frameGeometry)
  restoreGeometry(saved.tab, saved.tabGeometry)
  if saved.buttonSide and type(FCF_SetButtonSide) == "function" then FCF_SetButtonSide(destination, saved.buttonSide, true) end
  destination:SetShown(saved.shown)
  saved.tab:SetShown(saved.tabShown)
  SetChatWindowShown(destination:GetID(), saved.shown)
  if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(destination) end
  if destination:IsShown() ~= saved.shown or saved.tab:IsShown() ~= saved.tabShown then error("chat visibility restore failed") end
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
  for _, name in ipairs({"FCF_SetWindowName", "SetChatWindowName", "SetChatWindowShown", "FCF_CheckShowChatFrame"}) do
    if type(_G[name]) ~= "function" then
      finish(db, "api-missing", nil)
      return db.result
    end
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
  local subscribed = subscriptions(general)
  if not subscribed or not groupAPI(general, "Add") or not groupAPI(general, "Remove") then
    finish(db, "api-missing", nil)
    return db.result
  end
  local windows = {public = general:GetID()}
  local destinations, slots, added, removed = {}, {}, {}, {}
  local originalGeometry = geometry(general)
  local publicPlaced = false
  local failure = "failed"
  finish(db, "in-progress", windows)
  local ok, reason = pcall(function()
    for slot, role in ipairs(ROLES) do
      local id
      for candidate = 3, maxWindows() do if free[candidate] then id = candidate; break end end
      local chatFrame = id and _G["ChatFrame" .. id]
      if not chatFrame then failure = "no-free-window"; error("reserved chat window unavailable") end
      free[id] = nil
      destinations[slot] = chatFrame
      slots[slot] = saveSlot(chatFrame)
      windows[role.key] = id
      local groups = subscriptions(chatFrame)
      if not groups or not groupAPI(chatFrame, "Add") or not groupAPI(chatFrame, "Remove") then
        failure = "api-missing"
        error("destination APIs or empty subscription list unavailable")
      end
    end
    for slot, role in ipairs(ROLES) do
      for _, group in ipairs(role.groups) do
        if subscribed[group] and knownGroup(group) then
          added[#added + 1] = {destinations[slot], group}
          changeGroup(destinations[slot], "Add", group, true)
        end
      end
    end
    for slot, role in ipairs(ROLES) do
      if not placePrepared(destinations[slot], role.key) then place(destinations[slot], slot, general) end
      local destination = destinations[slot]
      FCF_SetWindowName(destination, localized(role.names))
      FCF_CheckShowChatFrame(destination)
      FCF_CheckShowChatFrame(slots[slot].tab)
      SetChatWindowShown(destination:GetID(), true)
      if not destination:IsShown() or not slots[slot].tab:IsShown() then error("chat activation verification failed") end
    end
    local allowPublic = not (type(addon) == "table" and addon.CapturePublicFallback)
      or addon.CapturePublicFallback(general)
    publicPlaced = allowPublic and type(addon) == "table" and addon.GetPreparedChatWindow and addon.GetPreparedChatWindow("public") ~= nil
    if allowPublic then placePrepared(general, "public") end
    for _, entry in ipairs(added) do
      removed[#removed + 1] = entry[2]
      changeGroup(general, "Remove", entry[2], false)
    end
  end)
  if not ok then
    local restored = true
    for _, group in ipairs(removed) do
      local current = subscriptions(general)
      if not current or not current[group] then
        if not pcall(changeGroup, general, "Add", group, true) then restored = false end
      end
    end
    local sourceRestored = restored
    -- Remove only this transaction's additions, after restoring the original route.
    if restored then
      for _, destination in ipairs(destinations) do
        local current = subscriptions(destination)
        if not current then restored = false else
          for group in pairs(current) do
            if not pcall(changeGroup, destination, "Remove", group, false) then restored = false end
          end
        end
      end
    end
    if publicPlaced then
      local geometryOK = pcall(function()
        restoreGeometry(general, originalGeometry)
        if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(general) end
      end)
      if not geometryOK then restored = false end
    end
    if sourceRestored then
      for _, saved in ipairs(slots) do
        if not pcall(restoreSlot, saved) then restored = false end
      end
    end
    finish(db, restored and failure or "rollback-failed", windows)
    db.failure = tostring(reason)
    return db.result
  end
  finish(db, "created", windows)
  if type(addon) == "table" and addon.CaptureManagedLayout then addon.CaptureManagedLayout() end
  if type(addon) == "table" and addon.NotifyWindowsCreated then
    addon.NotifyWindowsCreated()
  end
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

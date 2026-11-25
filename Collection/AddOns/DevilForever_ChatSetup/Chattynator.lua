-- With Chattynator loaded, its three windows replace the native split: seeded
-- once per Chattynator profile, only while Chattynator's window config is still
-- its own default; afterwards only the looking-for-group channel and the
-- placement of unmoved windows are kept up to date.

local _, addon = ...
local DELAY = 3     -- seconds after PLAYER_ENTERING_WORLD / end of combat
local GAP = 40      -- pixels between window 1 and window 2 without a prepared layout
local EDGE = 8      -- pixels from the right screen edge for window 3 without a prepared layout
local LFG_ZONE_ID = 26
local LFG_NAMES = {"lookingforgroup", "파티찾기"}

-- Window 2: private, guild and group conversation. Every other message type stays in window 1.
local GROUP_TYPES = {
  "WHISPER", "BN_WHISPER", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "GUILD_DISCORD",
  "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
}
-- Chattynator's own GENERAL tab leaves these out; window 1 keeps that.
local PUBLIC_HIDDEN = {
  "TRADESKILLS", "COMBAT_MISC_INFO", "COMBAT_XP_GAIN", "PET_BATTLE_COMBAT_LOG", "PET_INFO", "OPENING", "VOICE_TEXT",
}
local NAMES = {
  group = {koKR = "파티·길드", default = "Group"},
  lfg = {koKR = "파티 찾기", default = "Looking for Group"},
}
local ROLES = {"public", "group", "system"}

local function localized(t)
  local locale = type(GetLocale) == "function" and GetLocale() or nil
  return t[locale] or t.default
end

function addon.ChattynatorActive()
  local loaded = C_AddOns and C_AddOns.IsAddOnLoaded
  return type(loaded) == "function" and loaded("Chattynator") and type(DevilForever_ChattynatorBridge) == "table"
    or false
end

local function bridge()
  local b = DevilForever_ChattynatorBridge
  if addon.ChattynatorActive() and b.IsReady() then return b end
end

local function database()
  local db = DevilForever_ChatSetupDB
  if type(db) ~= "table" then
    db = {}
    DevilForever_ChatSetupDB = db
  end
  if type(db.chattynator) ~= "table" then db.chattynator = {version = 1, profiles = {}} end
  if type(db.chattynator.profiles) ~= "table" then db.chattynator.profiles = {} end
  return db.chattynator
end

local function near(a, b)
  return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 0.01
end

local function same(a, b)
  if type(a) == "number" or type(b) == "number" then return near(a, b) end
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end

local function normalized(name)
  return (name:gsub("%s+", ""):lower())
end

-- The looking-for-group channel: zone channel 26, or its English or Korean name.
local function isLookingForGroup(index, name)
  local info = C_ChatInfo and C_ChatInfo.GetChannelInfoFromIdentifier
  if type(info) == "function" and type(GetChannelName) == "function" then
    local _, fullName = GetChannelName(index)
    local ok, details = pcall(info, fullName or index)
    if ok and type(details) == "table" and details.zoneChannelID == LFG_ZONE_ID then return true end
  end
  if type(name) ~= "string" then return false end
  local text = normalized(name)
  for _, pattern in ipairs(LFG_NAMES) do
    if text:find(pattern, 1, true) then return true end
  end
  return false
end

-- Display names of the joined channels: {name = true} and the looking-for-group name (or nil).
local function joinedChannels(b)
  local map, count = b.GetChannels()
  local others, lfg = {}, nil
  for index = 1, count or 0 do
    local name = map[index]
    if type(name) == "string" then
      if not lfg and isLookingForGroup(index, name) then lfg = name else others[name] = true end
    end
  end
  return others, lfg
end

-- Position and size of a role from the prepared layout of the active preset, or nil.
local function prepared(role)
  local bounds = addon.GetPreparedChatWindow and addon.GetPreparedChatWindow(role)
  if type(bounds) ~= "table" then return end
  return {bounds.point, "UIParent", bounds.point, bounds.x, bounds.y}, {bounds.width, bounds.height}
end

local function placements(first)
  local out = {}
  for index, role in ipairs(ROLES) do
    local position, size = prepared(role)
    out[index] = position and {position = position, size = size}
  end
  if out[1] and out[2] and out[3] then return out end
  -- Without a prepared layout: window 1 stays where Chattynator put it, 2 and 3 beside it.
  local width, height = first.size[1], first.size[2]
  local x, y = first.position[4] or 0, first.position[5] or 0
  return {
    {position = first.position, size = first.size},
    {position = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", x + width + GAP, y}, size = {width, height}},
    {position = {"BOTTOMLEFT", "UIParent", "BOTTOMLEFT", math.max(0, UIParent:GetWidth() - width - EDGE), y},
      size = {width, height}},
  }
end

local function copyPlace(window)
  return {position = {unpack(window.position)}, size = {unpack(window.size)}}
end

local function seed(b, state, profile)
  local windows = b.Get(b.Options.WINDOWS)
  local first = windows[1]
  local combat
  for _, tab in ipairs(first.tabs) do if tab.custom == "combat_log" then combat = tab end end
  local others, lfg = joinedChannels(b)

  local public = b.GetEmptyTabConfig("GENERAL")
  public.invert, public.tabColor = true, "06a1ff"
  for _, group in ipairs(PUBLIC_HIDDEN) do public.groups[group] = false end
  for _, group in ipairs(GROUP_TYPES) do public.groups[group] = false end
  for name in pairs(others) do public.channels[name] = true end
  if lfg then public.channels[lfg] = false end

  local group = b.GetEmptyTabConfig(localized(NAMES.group))
  group.tabColor = "309944"
  for _, name in ipairs(GROUP_TYPES) do group.groups[name] = true end

  local lookingForGroup = b.GetEmptyTabConfig(localized(NAMES.lfg))
  if lfg then lookingForGroup.channels[lfg] = true end

  local places = placements(first)
  local seeded = {}
  for index, tabs in ipairs({{public, combat}, {group}, {lookingForGroup}}) do
    local window = b.GetEmptyWindowConfig()
    window.position, window.size = places[index].position, places[index].size
    for _, tab in ipairs(tabs) do window.tabs[#window.tabs + 1] = tab end
    seeded[index] = window
  end
  b.Set(b.Options.WINDOWS, seeded)
  b.Set(b.Options.STORE_MESSAGES, false)
  b.Set(b.Options.SHOW_TABS, "hover")
  b.Set(b.Options.SHOW_BUTTONS, "hover")
  b.Set(b.Options.BUTTON_POSITION, "inside_left")
  state.profiles[profile] = "seeded"
  state.lfgTab = lookingForGroup.name
  state.lfg = lfg
  state.layout = {preset = DevilForever_Core and DevilForever_Core.Presets and DevilForever_Core.Presets:GetActive(),
    windows = {copyPlace(seeded[1]), copyPlace(seeded[2]), copyPlace(seeded[3])}}
end

local frame = CreateFrame("Frame")
local waiting = {}

local function later(name, fn)
  if waiting[name] then return end
  waiting[name] = true
  C_Timer.After(DELAY, function() waiting[name] = nil; fn() end)
end

local function inCombat(name)
  if not InCombatLockdown() then return false end
  waiting[name .. "Combat"] = true
  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  return true
end

-- Returns the result for this Chattynator profile, or nil when it must run again later.
function addon.SeedChattynator()
  local b = bridge()
  if not b or inCombat("seed") then return nil end
  local state = database()
  local profile = b.GetProfileName() or "DEFAULT"
  if state.profiles[profile] then return state.profiles[profile] end
  if not b.IsUntouched() then
    state.profiles[profile] = "kept"
    return "kept"
  end
  seed(b, state, profile)
  return "seeded"
end

local function seededProfile(b)
  local state = database()
  return state.profiles[b.GetProfileName() or "DEFAULT"] == "seeded" and state
end

-- A looking-for-group channel joined after the seed goes to window 3 and leaves window 1,
-- unless some tab already shows it or window 3 is no longer the seeded one.
function addon.RouteChattynatorLookingForGroup()
  local b = bridge()
  if not b or inCombat("lfg") then return false end
  local state = seededProfile(b)
  if not state then return false end
  local _, lfg = joinedChannels(b)
  if not lfg then return false end
  local windows = b.Get(b.Options.WINDOWS)
  for _, window in ipairs(windows) do
    for _, tab in ipairs(window.tabs or {}) do
      if type(tab.channels) == "table" and tab.channels[lfg] == true then return false end
    end
  end
  local target = windows[3] and windows[3].tabs and windows[3].tabs[1]
  if not target or target.name ~= state.lfgTab then return false end
  target.channels[lfg] = true
  local public = windows[1] and windows[1].tabs and windows[1].tabs[1]
  if public and public.invert and type(public.channels) == "table" then public.channels[lfg] = false end
  state.lfg = lfg
  b.WindowsChanged()
  return true
end

-- Windows still at the place this module gave them follow the active preset and screen scale.
function addon.FollowChattynatorLayout()
  local b = bridge()
  if not b or inCombat("layout") then return false end
  local state = seededProfile(b)
  local receipt = state and type(state.layout) == "table" and state.layout.windows
  if type(receipt) ~= "table" then return false end
  local windows = b.Get(b.Options.WINDOWS)
  local changed = false
  for index, role in ipairs(ROLES) do
    local window, placed = windows[index], receipt[index]
    if placed then
      if not window or not same(window.position, placed.position) or not same(window.size, placed.size) then
        receipt[index] = nil
      else
        local position, size = prepared(role)
        if position and not (same(position, window.position) and same(size, window.size)) then
          window.position, window.size = position, size
          receipt[index] = copyPlace(window)
          changed = true
        end
      end
    end
  end
  state.layout.preset = DevilForever_Core and DevilForever_Core.Presets and DevilForever_Core.Presets:GetActive()
  if changed then b.WindowsChanged() end
  return changed
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event, message)
  if not addon.ChattynatorActive() then return end
  if event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    for _, name in ipairs({"CHANNEL_UI_UPDATE", "CHAT_MSG_CHANNEL_NOTICE", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
      self:RegisterEvent(name)
    end
    later("seed", function()
      addon.SeedChattynator()
      addon.FollowChattynatorLayout()
    end)
  elseif event == "PLAYER_REGEN_ENABLED" then
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if waiting.seedCombat then waiting.seedCombat = nil; later("seed", addon.SeedChattynator) end
    if waiting.lfgCombat then waiting.lfgCombat = nil; later("lfg", addon.RouteChattynatorLookingForGroup) end
    if waiting.layoutCombat then waiting.layoutCombat = nil; later("layout", addon.FollowChattynatorLayout) end
  elseif event == "CHANNEL_UI_UPDATE" or event == "CHAT_MSG_CHANNEL_NOTICE" then
    if event == "CHANNEL_UI_UPDATE" or message == "YOU_JOINED" or message == "YOU_CHANGED" then
      later("lfg", addon.RouteChattynatorLookingForGroup)
    end
  else
    later("layout", addon.FollowChattynatorLayout)
  end
end)

local Core = DevilForever_Core
if Core and Core.Edit and type(Core.Edit.RegisterCallback) == "function" then
  Core.Edit:RegisterCallback(frame, function(key)
    if addon.ChattynatorActive() and (key == "appearance.chat1" or key == "appearance.chat2" or key == "appearance.chat3") then
      later("layout", addon.FollowChattynatorLayout)
    end
  end)
end

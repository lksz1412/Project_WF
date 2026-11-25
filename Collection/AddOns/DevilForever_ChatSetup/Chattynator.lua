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

-- Window 2: private, guild and group conversation and battleground messages. Every other message
-- type stays in window 1.
local GROUP_TYPES = {
  "WHISPER", "BN_WHISPER", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "GUILD_DISCORD",
  "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
  "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL",
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

-- Display names of the joined channels: {name = true} for the others and the list of
-- looking-for-group channels (a client can have more than one, e.g. "파티찾기 2").
local function joinedChannels(b)
  local map, count = b.GetChannels()
  local others, lfg = {}, {}
  for index = 1, count or 0 do
    local name = map[index]
    if type(name) == "string" then
      if isLookingForGroup(index, name) then lfg[#lfg + 1] = name else others[name] = true end
    end
  end
  return others, lfg
end

-- Chattynator window layout (Display/Main.lua, with tabs shown and buttons inside): the message
-- area (ScrollingMessagesWrapper) starts MESSAGE_TOP units below the window top with the tab row
-- above it, MESSAGE_LEFT units from the window's left edge, flush with its right edge, and
-- MESSAGE_BOTTOM units above the bottom of windows 2 and 3. Window 1 keeps the input box in its
-- bottom part, below the message area.
local MESSAGE_TOP, MESSAGE_LEFT, MESSAGE_BOTTOM = 27, 2, 5
-- The tab row is the top TAB_ROW units of the window (Display/Main.lua TabsBar height).
local TAB_ROW = 22
-- Chattynator's resize bounds (Display/Main.lua SetResizeBounds): the client raises a smaller window
-- to these and Chattynator saves the raised size.
local MIN_WIDTH, MIN_HEIGHT = 240, 140
-- Placement rule revision: a seeded profile below it has its three windows placed once again
-- (the receipts of earlier rules can no longer match).
local FIT_VERSION = 2
local PANELS = {public = "appearance.chat1", group = "appearance.chat2", system = "appearance.chat3"}

-- Rectangle of an appearance item in root pixels (left, top, right, bottom; y grows downwards),
-- with the pixel unit, or nil.
local function rootRect(key)
  local core, appearance = DevilForever_Core, DevilForever_Appearance
  if type(core) ~= "table" or type(core.Edit) ~= "table" or type(core.Edit.Get) ~= "function"
      or type(appearance) ~= "table" or type(appearance.GetPixelUnit) ~= "function" then return end
  local item = core.Edit:Get(key)
  local position, size = type(item) == "table" and item.position, type(item) == "table" and item.size
  local pixel = appearance:GetPixelUnit(UIParent)
  if type(position) ~= "table" or type(size) ~= "table" or position.point ~= "TOPLEFT"
      or position.relativeTo ~= "DevilForever_AppearanceRoot" or type(pixel) ~= "number" or pixel <= 0 then return end
  return position.x, -position.y, position.x + size.width, -position.y + size.height, pixel
end

-- Composition part sizes of the active screen preset (fhd, qhd, uhd), or nil.
local function partSizes(composition)
  local core = DevilForever_Core
  local active = core and core.Presets and core.Presets.GetActive and core.Presets:GetActive()
  local family = type(active) == "string" and active:match("^(%a+)")
  local parts = type(composition) == "table" and type(composition.parts) == "table" and composition.parts.sizes
  return type(parts) == "table" and family and parts[family] or nil
end

-- Inner rectangle of a role's chat panel as the appearance code draws it, in UIParent units
-- (left, top, right, bottom; top and bottom as TOPLEFT y offsets), or nil without the layout.
-- Composition parts: the end caps and the joints between panels cover the panel edges.
-- Prepared composition surfaces: the deck picture paints a frame along the screen edges and the
-- panel boundaries (about 16 texels of the 2048-texel picture), so the sides move in by one joint.
-- Individual panels: the top and bottom edge lines of border.size pixels.
local function panelInner(role)
  local left, top, right, bottom, pixel = rootRect(PANELS[role])
  if not left then return end
  local core = DevilForever_Core
  local composition = DevilForever_Composition
  local plan = type(composition) == "table" and composition.active and composition.partsShown and composition.partsPlan
  if plan then
    local sizes = composition.parts.sizes[plan.preset]
    for _, centre in ipairs(plan.joints or {}) do
      if math.abs(centre - left) <= sizes.joint then left = math.max(left, centre + sizes.joint / 2) end
      if math.abs(centre - right) <= sizes.joint then right = math.min(right, centre - sizes.joint / 2) end
    end
    left = math.max(left, sizes.cap)
    right = math.min(right, plan.bounds.width - sizes.cap)
  elseif type(composition) == "table" and composition.active then
    local sizes = partSizes(composition)
    if sizes then left, right = left + sizes.joint, right - sizes.joint end
  else
    local border = core.Theme and core.Theme.Get and core.Theme:Get("border.size")
    if type(border) == "number" then top, bottom = top + border, bottom - border end
  end
  return left * pixel, -top * pixel, right * pixel, -bottom * pixel
end

-- Centre of the theme strip above the chat panels as a TOPLEFT y offset in UIParent units, or nil.
local function stripCentre()
  local _, top, _, bottom, pixel = rootRect("appearance.ribbon")
  if not top then return end
  return -(top + bottom) / 2 * pixel
end

-- Window of a role: its tab row centred on the theme strip, its message area's left, right and
-- bottom on the panel's inner rectangle (window 1: the area above its input box) and its top
-- MESSAGE_TOP below the window top, never above the panel's inner top. A window smaller than
-- Chattynator's resize bounds grows upwards. Nil without the appearance layout.
local function prepared(role)
  local left, top, right, bottom = panelInner(role)
  if not left then return end
  local x = math.max(0, left - MESSAGE_LEFT)
  local strip = stripCentre()
  local windowTop = strip and strip + TAB_ROW / 2 or top + MESSAGE_TOP
  windowTop = math.min(windowTop, top + MESSAGE_TOP)
  local windowBottom = role == "public" and bottom or bottom - MESSAGE_BOTTOM
  local width = math.max(MIN_WIDTH, right - x)
  local height = math.max(MIN_HEIGHT, windowTop - windowBottom)
  return {"TOPLEFT", "UIParent", "TOPLEFT", x, windowBottom + height}, {width, height}
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
  for _, name in ipairs(lfg) do public.channels[name] = false end

  local group = b.GetEmptyTabConfig(localized(NAMES.group))
  group.tabColor = "309944"
  for _, name in ipairs(GROUP_TYPES) do group.groups[name] = true end

  local lookingForGroup = b.GetEmptyTabConfig(localized(NAMES.lfg))
  for _, name in ipairs(lfg) do lookingForGroup.channels[name] = true end

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
  state.lfg = lfg[1]
  state.layout = {preset = DevilForever_Core and DevilForever_Core.Presets and DevilForever_Core.Presets:GetActive(),
    version = FIT_VERSION, windows = {copyPlace(seeded[1]), copyPlace(seeded[2]), copyPlace(seeded[3])}}
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

-- Looking-for-group channels joined after the seed go to window 3 and leave window 1, each
-- unless some tab already shows it; nothing moves when window 3 is no longer the seeded one.
function addon.RouteChattynatorLookingForGroup()
  local b = bridge()
  if not b or inCombat("lfg") then return false end
  local state = seededProfile(b)
  if not state then return false end
  local _, lfg = joinedChannels(b)
  local windows = b.Get(b.Options.WINDOWS)
  local target = windows[3] and windows[3].tabs and windows[3].tabs[1]
  if not target or target.name ~= state.lfgTab then return false end
  local public = windows[1] and windows[1].tabs and windows[1].tabs[1]
  local moved = false
  for _, name in ipairs(lfg) do
    local shown = false
    for _, window in ipairs(windows) do
      for _, tab in ipairs(window.tabs or {}) do
        if type(tab.channels) == "table" and tab.channels[name] == true then shown = true end
      end
    end
    if not shown then
      target.channels[name] = true
      if public and public.invert and type(public.channels) == "table" then public.channels[name] = false end
      state.lfg = state.lfg or name
      moved = true
    end
  end
  if moved then b.WindowsChanged() end
  return moved
end

-- Windows still at the place this module gave them follow the active preset and screen scale.
-- A seeded profile from an earlier placement rule (layout version below FIT_VERSION) has its three
-- windows placed once more whatever their receipts say: earlier rules gave sizes Chattynator raised
-- to its resize bounds, so their receipts no longer matched windows nobody moved.
function addon.FollowChattynatorLayout()
  local b = bridge()
  if not b or inCombat("layout") then return false end
  local state = seededProfile(b)
  local receipt = state and type(state.layout) == "table" and state.layout.windows
  if type(receipt) ~= "table" then return false end
  local windows = b.Get(b.Options.WINDOWS)
  local refit = (tonumber(state.layout.version) or 1) < FIT_VERSION
  local changed, placedAll = false, true
  for index, role in ipairs(ROLES) do
    local window, placed = windows[index], receipt[index]
    if refit and window and type(window.position) == "table" and type(window.size) == "table" then
      placed = window
    end
    if placed then
      if not window or not same(window.position, placed.position) or not same(window.size, placed.size) then
        receipt[index] = nil
      else
        local position, size = prepared(role)
        if not position then
          placedAll = false
        elseif not (same(position, window.position) and same(size, window.size)) then
          window.position, window.size = position, size
          changed = true
        end
        if position then receipt[index] = copyPlace(window) end
      end
    end
  end
  if refit and placedAll then state.layout.version = FIT_VERSION end
  state.layout.preset = DevilForever_Core and DevilForever_Core.Presets and DevilForever_Core.Presets:GetActive()
  if changed then b.WindowsChanged() end
  return changed
end

-- Hangul/English (IME) switching in ChatFrame1EditBox comes back after a scale change on the box
-- once Chattynator has set it up; every load gives it one change that ends at scale 1.
function addon.RefreshChattynatorEditBox()
  local box = ChatFrame1EditBox
  if type(box) ~= "table" or type(box.SetScale) ~= "function" then return false end
  box:SetScale(0.99)
  C_Timer.After(0, function() box:SetScale(1) end)
  return true
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
      addon.RefreshChattynatorEditBox()
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
-- A theme change can switch the panel art (composition or individual panels) and its insets.
if Core and Core.Theme and type(Core.Theme.RegisterCallback) == "function" then
  Core.Theme:RegisterCallback(frame, function()
    if addon.ChattynatorActive() then later("layout", addon.FollowChattynatorLayout) end
  end)
end

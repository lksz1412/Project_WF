---@class addonTableChattynator
local addonTable = select(2, ...)

-- "Devil Forever" skin: transparent chat body, flat tabs in the active Devil
-- Forever theme colours, input box border only while it is shown (typing).
-- Without DevilForever_Core and DevilForever_Appearance every region gets the
-- Dark skin's look. Buttons and the resize widget always use the Dark look.
-- It becomes the current skin only for a profile Chattynator has never been
-- set up in (see untouched below); any other profile keeps its skin.

local KEY = "devilforever"
local FONT_OPTION = "skins." .. KEY .. ".applied_font_size"

local tabs, editBoxes = {}, {}
local subscribed = false

local function core()
  local c = DevilForever_Core
  if type(c) == "table" and type(c.Theme) == "table" and type(c.Theme.Get) == "function" then return c end
end

local function themed()
  return core() ~= nil and type(DevilForever_Appearance) == "table"
end

local function color(token, r, g, b, a)
  local c = core()
  local value = c and c.Theme:Get(token)
  if type(value) == "table" and type(value[1]) == "number" then
    return value[1], value[2], value[3], value[4] or 1
  end
  return r, g, b, a or 1
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

-- Tab fields that carry a choice: empty tables and isTemporary = false are the same as absent.
local function meaningful(tab)
  local out = {}
  for k, v in pairs(tab) do
    if not (type(v) == "table" and next(v) == nil) and not (k == "isTemporary" and v == false) then out[k] = v end
  end
  return out
end

-- Untouched = the profile's windows are exactly Chattynator's default: one window at the
-- default place and size with the default GENERAL and GUILD tabs, plus the combat log tab its
-- first-run migration adds. DevilForever_ChatSetup seeds its windows by the same rule.
local function untouched()
  local windows = addonTable.Config.Get(addonTable.Config.Options.WINDOWS)
  local defaults = CopyTable(addonTable.Config.Defaults[addonTable.Config.Options.WINDOWS])
  if type(windows) ~= "table" or #windows ~= #defaults then return false end
  for index, window in ipairs(windows) do
    local default = defaults[index]
    if type(window) ~= "table" or type(window.tabs) ~= "table"
        or not same(window.position, default.position) or not same(window.size, default.size) then return false end
    local expected = {}
    for _, tab in ipairs(default.tabs) do expected[#expected + 1] = meaningful(tab) end
    local last = window.tabs[#window.tabs]
    if index == 1 and #window.tabs == #default.tabs + 1 and type(last) == "table" and last.custom == "combat_log" then
      local combat = addonTable.Config.GetEmptyTabConfig("COMBAT_LOG")
      combat.backgroundColor, combat.tabColor, combat.custom = "262626", "c97c48", "combat_log"
      expected[#expected + 1] = meaningful(combat)
    end
    if #window.tabs ~= #expected then return false end
    for i, tab in ipairs(window.tabs) do
      if type(tab) ~= "table" or not same(meaningful(tab), expected[i]) then return false end
    end
  end
  return true
end

local function dark(details)
  local skin = addonTable.Skins.availableSkins.dark
  if skin then skin.skinner(details) end
end

local function tabWidth(tab)
  local text = tab:GetText() or ""
  if tab.minWidth then
    return tab:GetFontString():GetUnboundedStringWidth() + addonTable.Constants.TabPadding
  end
  return math.max(tab:GetFontString():GetUnboundedStringWidth(),
    not text:find("|K") and addonTable.Constants.MinTabWidth or 70) + addonTable.Constants.TabPadding
end

local function paintTab(tab)
  local r, g, b
  if tab.flashing or tab.selected then
    r, g, b = color("color.accent", 1, 0.82, 0)
  else
    r, g, b = color("color.text.normal", 0.9, 0.9, 0.9)
  end
  tab:GetFontString():SetTextColor(r, g, b)
  tab.Underline:SetColorTexture(color("color.accent", 1, 0.82, 0))
  tab.Underline:SetShown(tab.selected == true or tab.flashing == true)
  tab:SetAlpha((tab.selected or tab.flashing) and 1 or 0.7)
end

local function paintEditBox(editBox)
  local r, g, b = color("color.panel.background", 0.1, 0.1, 0.1)
  editBox.background:SetColorTexture(r, g, b, 0.85)
  local br, bg, bb = color("color.panel.border", 0.5, 0.5, 0.5)
  for _, line in ipairs(editBox.borderLines) do line:SetColorTexture(br, bg, bb, 1) end
end

local skinners = {
  ChatFrame = function(frame)
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints(frame.ScrollingMessagesWrapper)
    frame.background:SetColorTexture(0, 0, 0, 0)
  end,
  ChatTab = function(tab)
    table.insert(tabs, tab)
    tab:SetHeight(22)
    tab:SetNormalFontObject("GameFontNormalSmall")
    if tab:GetFontString() == nil then tab:SetText(" ") end
    tab:GetFontString():SetWordWrap(false)
    tab:GetFontString():SetNonSpaceWrap(false)
    tab:GetFontString():SetPoint("TOP", 0, -5)
    tab.Underline = tab:CreateTexture(nil, "ARTWORK")
    tab.Underline:SetHeight(1)
    tab.Underline:SetPoint("BOTTOMLEFT", 4, 2)
    tab.Underline:SetPoint("BOTTOMRIGHT", -4, 2)
    local width = tabWidth(tab)
    tab:GetFontString():SetWidth(width)
    tab:SetWidth(width)
    hooksecurefunc(tab, "SetText", function()
      local w = tabWidth(tab)
      tab:GetFontString():SetWidth(w)
      tab:SetWidth(w)
    end)
    hooksecurefunc(tab, "SetSelected", function() paintTab(tab) end)
    hooksecurefunc(tab, "SetFlashing", function(_, state)
      tab:SetIgnoreParentAlpha(state)
      paintTab(tab)
    end)
    paintTab(tab)
  end,
  ChatEditBox = function(editBox)
    table.insert(editBoxes, editBox)
    for _, texName in ipairs({"Left", "Right", "Mid", "FocusLeft", "FocusRight", "FocusMid"}) do
      local tex = _G[editBox:GetName() .. texName]
      if tex then tex:SetParent(addonTable.hiddenFrame) end
    end
    editBox.background = editBox:CreateTexture(nil, "BACKGROUND")
    editBox.background:SetAllPoints(editBox)
    editBox.borderLines = {}
    for _, side in ipairs({{"TOPLEFT", "TOPRIGHT"}, {"BOTTOMLEFT", "BOTTOMRIGHT"}, {"TOPLEFT", "BOTTOMLEFT"},
        {"TOPRIGHT", "BOTTOMRIGHT"}}) do
      local line = editBox:CreateTexture(nil, "BORDER")
      line:SetPoint(side[1])
      line:SetPoint(side[2])
      if side[1] == "TOPLEFT" and side[2] == "BOTTOMLEFT" or side[1] == "TOPRIGHT" then
        line:SetWidth(1)
      else
        line:SetHeight(1)
      end
      table.insert(editBox.borderLines, line)
    end
    paintEditBox(editBox)
  end,
}

-- Chattynator's message font size follows appearance.chat1 until the user sets
-- another size: the size is only replaced while it still equals the last value
-- this skin wrote (or Chattynator's default before the first write).
local function applyFontSize()
  local c = core()
  if not themed() or type(c.Edit) ~= "table" or type(c.Edit.Get) ~= "function"
      or type(DevilForever_Appearance.GetPixelUnit) ~= "function" then return end
  local item = c.Edit:Get("appearance.chat1")
  local font = type(item) == "table" and item.font
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if type(font) ~= "table" or type(font.size) ~= "number" or type(pixel) ~= "number" or pixel <= 0 then return end
  local wanted = math.max(8, math.floor(font.size * pixel + 0.5))
  local option = addonTable.Config.Options.MESSAGE_FONT_SIZE
  local current = addonTable.Config.Get(option)
  local applied = addonTable.Config.Get(FONT_OPTION)
  local untouched = current == applied or (applied == 0 and current == addonTable.Config.Defaults[option])
  if untouched and current ~= wanted then
    addonTable.Config.Set(FONT_OPTION, wanted)
    addonTable.Config.Set(option, wanted)
  elseif untouched then
    addonTable.Config.Set(FONT_OPTION, wanted)
  end
end

local function repaint()
  for _, tab in ipairs(tabs) do paintTab(tab) end
  for _, editBox in ipairs(editBoxes) do paintEditBox(editBox) end
  applyFontSize()
end

local function initialize()
  local darkSkin = addonTable.Skins.availableSkins.dark
  if darkSkin then
    darkSkin.constants()
    xpcall(darkSkin.initializer, CallErrorHandler)
  end
  if not themed() or subscribed then return end
  subscribed = true
  local c = core()
  local owner = {}
  if type(c.Theme.RegisterCallback) == "function" then c.Theme:RegisterCallback(owner, repaint) end
  if type(c.Edit) == "table" and type(c.Edit.RegisterCallback) == "function" then
    c.Edit:RegisterCallback(owner, function(key)
      if key == "appearance.chat1" then applyFontSize() end
    end)
  end
  local events = CreateFrame("Frame")
  events:RegisterEvent("UI_SCALE_CHANGED")
  events:SetScript("OnEvent", applyFontSize)
  applyFontSize()
end

local function skinFrame(details)
  local func = themed() and skinners[details.regionType]
  if func then
    func(details.region)
  else
    dark(details)
  end
end

local function constants()
  local darkSkin = addonTable.Skins.availableSkins.dark
  if darkSkin then darkSkin.constants() end
end

addonTable.Skins.RegisterSkin("Devil Forever", KEY, initialize, skinFrame, constants, {
  {type = "value", option = "applied_font_size", default = 0},
}, false)

-- Skins.Initialize (Skins/Main.lua) picks an auto-enabled skin once per login, after the
-- profile's settings are loaded and migrated; decide here, just before it, so a new profile
-- shows this skin in its first session. A profile whose windows or skin were already set up
-- keeps its skin.
local initializeSkins = addonTable.Skins.Initialize
addonTable.Skins.Initialize = function(...)
  local skin = addonTable.Skins.availableSkins[KEY]
  if skin then
    local option = addonTable.Config.Options.CURRENT_SKIN
    local ok, fresh = pcall(untouched)
    skin.autoEnable = ok and fresh and addonTable.Config.Get(option) == addonTable.Config.Defaults[option] or nil
  end
  return initializeSkins(...)
end

-- Narrow access to Chattynator's own config functions for DevilForever_ChatSetup.
DevilForever_ChattynatorBridge = {
  Options = addonTable.Config.Options,
  IsReady = function()
    return addonTable.Config.CurrentProfile ~= nil and addonTable.Messages ~= nil and addonTable.allChatFrames ~= nil
  end,
  Get = function(name) return addonTable.Config.Get(name) end,
  Set = function(name, value) addonTable.Config.Set(name, value) end,
  GetDefault = function(name)
    local value = addonTable.Config.Defaults[name]
    return type(value) == "table" and CopyTable(value) or value
  end,
  GetEmptyTabConfig = function(name) return addonTable.Config.GetEmptyTabConfig(name) end,
  GetEmptyWindowConfig = function() return addonTable.Config.GetEmptyWindowConfig() end,
  GetProfileName = function() return CHATTYNATOR_CURRENT_PROFILE end,
  IsUntouched = function() return untouched() end,
  -- Channel display names by channel number, as the tab filters key them.
  GetChannels = function()
    if not addonTable.Messages then return {}, 0 end
    return addonTable.Messages:GetChannels()
  end,
  -- Windows table edited in place: reposition frames and rebuild tab filters.
  WindowsChanged = function()
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", addonTable.Config.Options.WINDOWS)
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Tabs] = true})
  end,
}

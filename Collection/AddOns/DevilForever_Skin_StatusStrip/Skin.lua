-- Styles the status strip and the optional Experience Forever main bar.

local Core = DevilForever_Core
local Strip = DevilForever_StatusStrip
local owner = {}
local pending = false
local ready = false
local separators = {}
local experience
local applyExperience
local holder = CreateFrame("Frame", nil, Strip:GetFrame())
holder:SetAllPoints(Strip:GetFrame())
holder:EnableMouse(false)
holder:EnableKeyboard(false)

local function layoutSeparators(_, shownKeys)
  for _, texture in ipairs(separators) do texture:Hide() end
  local values = Core.Edit:Get("statusstrip.bar")
  local color = Core.Theme:Get("color.divider")
  local thickness = Core.Theme:Get("border.size")
  if not values.spacing or not color or not thickness then return end
  for index = 2, #shownKeys do
    local font = Strip:GetFontString(shownKeys[index])
    local texture = separators[index - 1]
    if not texture then
      texture = holder:CreateTexture(nil, "BACKGROUND")
      separators[index - 1] = texture
    end
    texture:SetTexture(Core.Theme:Get("texture.divider"))
    texture:SetVertexColor(unpack(color))
    texture:ClearAllPoints()
    texture:SetPoint("RIGHT", font, "LEFT", -values.spacing / 2, 0)
    texture:SetSize(thickness, values.font.size)
    texture:Show()
  end
end

local function layoutExperienceAux()
  local state = experience
  if not state then return end
  local addon, holder = state.addon, state.holder
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if not pixel then return end
  local mainHeight = addon:GetBarHeight("main")
  local rep, pet = addon.RepBar, addon.PetBar
  local height = mainHeight
  if rep:IsShown() then height = height + addon:GetBarHeight("rep") + 2 end
  if pet:IsShown() then height = height + addon:GetBarHeight("pet") + 2 end
  if state.height ~= height then holder:SetSize(state.width, height); state.height = height end
  if state.pixel ~= pixel then
    rep:SetScale(state.scale / pixel)
    pet:SetScale(state.scale / pixel)
    state.pixel = pixel
  end
  local _, relative, _, _, repY = rep:GetPoint(1)
  if relative ~= holder or repY ~= -mainHeight - 2 then
    rep:ClearAllPoints()
    rep:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -mainHeight - 2)
    rep:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -mainHeight - 2)
  end
  local anchor = rep:IsShown() and rep or holder
  local _, petRelative, _, _, petY = pet:GetPoint(1)
  local offset = anchor == holder and -mainHeight - 2 or -2
  if petRelative ~= anchor or petY ~= offset then
    pet:ClearAllPoints()
    local point = anchor == holder and "TOPLEFT" or "BOTTOMLEFT"
    local right = anchor == holder and "TOPRIGHT" or "BOTTOMRIGHT"
    pet:SetPoint("TOPLEFT", anchor, point, 0, offset)
    pet:SetPoint("TOPRIGHT", anchor, right, 0, offset)
  end
end

applyExperience = function()
  if not ready then return end
  if InCombatLockdown() then pending = true; return end
  local ace = LibStub and LibStub("AceAddon-3.0", true)
  local addon = ace and ace:GetAddon("ExperienceForever", true)
  if not addon or not addon.MainFrame or (addon.IsEnabled and not addon:IsEnabled()) then return end
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if not pixel then return end
  local frame = addon.MainFrame
  if not experience then
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetScale(frame:GetScale())
    holder:SetPoint(frame:GetPoint(1))
    holder:SetClampedToScreen(true)
    holder:EnableMouse(false)
    experience = {addon = addon, holder = holder, scale = frame:GetScale(), width = frame:GetWidth()}
    for _, method in ipairs({"ApplyBarSizes", "SetPosition", "ResetPosition"}) do
      hooksecurefunc(addon, method, applyExperience)
    end
    hooksecurefunc(addon, "LayoutSubBars", layoutExperienceAux)
    addon.PetBar:HookScript("OnShow", layoutExperienceAux)
    addon.PetBar:HookScript("OnHide", layoutExperienceAux)
    frame:HookScript("OnEnter", function()
      GameTooltip:SetOwner(frame, "ANCHOR_TOP")
      GameTooltip:ClearLines()
      GameTooltip:AddLine("Experience Forever")
      for _, key in ipairs({"topLeft", "topCenter", "topRight", "barLeft", "barCenter", "barRight",
          "bottomLeft", "bottomCenter", "bottomRight"}) do
        local text = addon.slotText and addon.slotText[key]
        if text and text ~= "" then GameTooltip:AddLine(text, 1, 1, 1) end
      end
      GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
  end
  local _, height = GetPhysicalScreenSize()
  frame:SetScale(pixel)
  frame:ClearAllPoints()
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
  frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
  frame:SetHeight(height >= 2000 and 8 or 6)
  addon.TextOverlay:Hide()
  layoutExperienceAux()
end

local function apply()
  if not ready then return end
  if InCombatLockdown() then pending = true; return end
  pending = false
  if not DevilForever_Appearance:GetPixelUnit(UIParent) then
    Core:Log("skip", "Feature appearance", "physical pixel factor unavailable")
    return
  end
  local values = Core.Edit:Get("statusstrip.bar")
  if not values.position or not values.size or not values.font or not values.color then
    Core:Log("skip", "StatusStrip skin", "position, size, font or color missing")
    return
  end
  local frame = Strip:GetFrame()
  frame:SetScale(DevilForever_Appearance:GetPixelUnit(UIParent))
  frame:ClearAllPoints()
  local position = values.position
  frame:SetPoint(position.point, UIParent, position.relativePoint or position.point, position.x, position.y)
  frame:SetSize(values.size.width, values.size.height)
  for _, item in ipairs(Strip:ListItems()) do
    local font = Strip:GetFontString(item.key)
    font:SetFont(values.font.path, values.font.size, values.font.flags or "")
    font:SetTextColor(unpack(values.color))
  end
  Strip:SetSpacing(values.spacing)
  applyExperience()
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "ADDON_LOADED"}) do
  events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, name)
  if event == "ADDON_LOADED" and name ~= "ExperienceForever" then return end
  if event == "PLAYER_LOGIN" then ready = true; apply()
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then apply() end
end)
Strip:RegisterCallback(owner, layoutSeparators)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "statusstrip.bar" then Core.Edit:AfterBatch(owner, apply) end
end)

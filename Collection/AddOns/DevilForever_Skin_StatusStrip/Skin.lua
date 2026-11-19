-- Styles only the public status-strip frame and font strings.

local Core = DevilForever_Core
local Strip = DevilForever_StatusStrip
local owner = {}
local pending = false
local ready = false
local separators = {}
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
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_REGEN_ENABLED", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
  events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then ready = true; apply()
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then apply() end
end)
Strip:RegisterCallback(owner, layoutSeparators)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "statusstrip.bar" then Core.Edit:AfterBatch(owner, apply) end
end)

local Core, Strip = DevilForever_Core, DevilForever_StatusStrip
if not Core or not Strip then return end

local korean = GetLocale() == "koKR"
local owner, ready, pending, direction = {}, false, false, 0
local panel = CreateFrame("Frame", "DevilForever_StatusStripThemes", Strip:GetFrame())
panel:EnableMouse(false)
panel:Hide()
local nameSlot = CreateFrame("Frame", nil, panel)
nameSlot:SetClipsChildren(true)
nameSlot:EnableMouse(false)
local name = nameSlot:CreateFontString(nil, "OVERLAY")
name:SetJustifyH("CENTER")
name:SetWordWrap(false)
local animation = name:CreateAnimationGroup()
local translation = animation:CreateAnimation("Translation")
translation:SetDuration(.12)
translation:SetSmoothing("OUT")
local function settle()
  name:ClearAllPoints()
  name:SetPoint("CENTER", nameSlot, "CENTER", 0, 0)
end
animation:SetScript("OnFinished", settle)
animation:SetScript("OnStop", settle)
local previous = CreateFrame("Button", nil, panel)
local following = CreateFrame("Button", nil, panel)
local previousText = previous:CreateFontString(nil, "OVERLAY")
local followingText = following:CreateFontString(nil, "OVERLAY")
previousText:SetAllPoints(previous)
followingText:SetAllPoints(following)
previousText:SetText("◀")
followingText:SetText("▶")

local function hint(button, step)
  GameTooltip:SetOwner(button, "ANCHOR_TOP")
  GameTooltip:SetText(korean and (step < 0 and "이전 테마" or "다음 테마")
    or (step < 0 and "Previous theme" or "Next theme"))
  if Core.InCombat() then
    GameTooltip:AddLine(korean and "전투 중에는 바꿀 수 없습니다." or "Unavailable in combat.", 1, .5, .2)
  end
  GameTooltip:Show()
end
local function choose(button, step)
  direction = step
  local ok = Core.Theme:Cycle(step)
  direction = 0
  if not ok then hint(button, step) end
end
previous:SetScript("OnClick", function(button) choose(button, -1) end)
following:SetScript("OnClick", function(button) choose(button, 1) end)
for _, button in ipairs({previous, following}) do
  button:EnableMouse(true)
  button:RegisterForClicks("LeftButtonUp")
  button:SetScript("OnEnter", function(button) hint(button, button == previous and -1 or 1) end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function apply()
  if not ready then return end
  if Core.InCombat() then pending = true; return end
  pending = false
  local values = Core.Edit:Get("statusstrip.bar")
  local font, size = values.font, values.size
  if not font or not size then return end
  local height, width = size.height, font.size * 12
  local buttonWidth = math.max(height, font.size + 6)
  panel:ClearAllPoints()
  panel:SetPoint("RIGHT", Strip:GetFrame(), "RIGHT", -(values.spacing or 12), 0)
  panel:SetSize(width + 2 * buttonWidth + 8, height)
  panel:SetFrameLevel(Strip:GetFrame():GetFrameLevel() + 2)
  previous:ClearAllPoints()
  previous:SetPoint("LEFT", panel, "LEFT", 0, 0)
  previous:SetSize(buttonWidth, height)
  following:ClearAllPoints()
  following:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
  following:SetSize(buttonWidth, height)
  nameSlot:ClearAllPoints()
  nameSlot:SetPoint("CENTER", panel, "CENTER", 0, 0)
  nameSlot:SetSize(width, height)
  for _, text in ipairs({name, previousText, followingText}) do
    text:SetFont(font.path, font.size, font.flags or "")
    text:SetTextColor(unpack(values.color or Core.Theme:Get("color.text.normal")))
  end
  animation:Stop()
  name:SetText(Core.Theme:GetDisplayName(Core.Theme:GetSet()))
  settle()
  if direction ~= 0 then
    name:ClearAllPoints()
    name:SetPoint("CENTER", nameSlot, "CENTER", direction * 8, 0)
    translation:SetOffset(-direction * 8, 0)
    animation:Play()
  end
  panel:Show()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then ready = true; apply()
  elseif pending then apply() end
end)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "statusstrip.bar" then Core.Edit:AfterBatch(owner, apply) end
end)

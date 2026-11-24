-- Pixel-based common backgrounds. API and integration contract are in report.md.

local Core = DevilForever_Core
local Appearance = {frames = {}}
DevilForever_Appearance = Appearance

-- A. Frame definitions ------------------------------------------------------

local definitions = {
  {"chat1", "DevilForever_ChatPanel1", "texture.panel", true},
  {"chat2", "DevilForever_ChatPanel2", "texture.panel", true},
  {"chat3", "DevilForever_ChatPanel3", "texture.panel", true},
  {"action", "DevilForever_ActionPanel", "texture.panel", true},
  {"minimap", "DevilForever_MinimapPanel", "texture.panel", true},
  {"ribbon", "DevilForever_BlackRibbon", "texture.statusbar", false},
  {"upper", "DevilForever_UpperPanel", "texture.panel", true},
  {"aux", "DevilForever_AuxPanel", "texture.panel", true},
  {"unitUpper", "DevilForever_UnitUpperPanel", "texture.panel", true},
  {"unitLower", "DevilForever_UnitLowerPanel", "texture.panel", true},
  {"ornamentLeft", "DevilForever_OrnamentLeft", "texture.ornament.left", false},
  {"ornamentRight", "DevilForever_OrnamentRight", "texture.ornament.right", false},
  {"status", "DevilForever_StatusPanel", "texture.statusbar", true},
  {"seam1", "DevilForever_Seam1", "texture.divider", false},
  {"seam2", "DevilForever_Seam2", "texture.divider", false},
  {"seam3", "DevilForever_Seam3", "texture.divider", false},
  {"seam4", "DevilForever_Seam4", "texture.divider", false},
}

local root
local loggedMissing = {}
local applying = false
local pending = false
local loggedIn = false

local function makeFrame(name)
  local frame = CreateFrame("Frame", name, root or UIParent)
  frame:SetFrameStrata("BACKGROUND")
  frame:SetFrameLevel(0)
  frame:EnableMouse(false)
  frame:EnableKeyboard(false)
  return frame
end

local function createFrames()
  root = makeFrame("DevilForever_AppearanceRoot")
  if DevilForever_Composition then DevilForever_Composition:Create(root) end
  for _, def in ipairs(definitions) do
    local key = "appearance." .. def[1]
    local frame = makeFrame(def[2])
    frame.fill = frame:CreateTexture(nil, "BACKGROUND")
    frame.fill:SetAllPoints(frame)
    if def[4] then
      frame.top = frame:CreateTexture(nil, "BORDER")
      frame.bottom = frame:CreateTexture(nil, "BORDER")
    end
    Appearance.frames[key] = frame
  end
end

-- B. Token and edit application --------------------------------------------

local function setColor(texture, color)
  texture:SetVertexColor(unpack(color))
end

local function applyEdge(texture, frame, point, thickness, color)
  texture:ClearAllPoints()
  texture:SetPoint(point .. "LEFT", frame, point .. "LEFT")
  texture:SetPoint(point .. "RIGHT", frame, point .. "RIGHT")
  texture:SetHeight(thickness)
  texture:SetTexture(Core.Theme:Get("texture.divider"))
  setColor(texture, color)
end

local function applyFrame(def)
  local key = "appearance." .. def[1]
  local frame = Appearance.frames[key]
  if def[1] == "aux" then frame:Hide(); return end
  local values = Core.Edit:Get(key)
  local position, size = values.position, values.size
  if not position or not size then
    frame:Hide()
    if not loggedMissing[key] then
      Core:Log("skip", "Appearance", key .. ": registry/preset position or size missing")
      loggedMissing[key] = true
    end
    return
  end
  local relative = position.relativeTo and _G[position.relativeTo] or root
  if not relative then
    frame:Hide()
    Core:Log("skip", "Appearance", key .. ": relative frame not available")
    return
  end
  loggedMissing[key] = nil
  frame:ClearAllPoints()
  frame:SetPoint(position.point, relative, position.relativePoint or position.point, position.x, position.y)
  frame:SetSize(size.width, size.height)
  if def[1] == "unitUpper" or def[1] == "unitLower" then
    frame.fill:Hide()
    frame.top:Hide()
    frame.bottom:Hide()
    frame:Show()
    return
  end
  local flatChat = Core.Theme:GetSet() == "devil" and (def[1] == "chat1" or def[1] == "chat2" or def[1] == "chat3")
  frame.fill:SetTexture(flatChat and "Interface\\Buttons\\WHITE8X8" or Core.Theme:Get(def[3]))
  frame.fill:Show()
  local color = values.color
  if flatChat and not Core.Edit:GetEdits(key).color then color = {18 / 255, 19 / 255, 21 / 255, 1} end
  setColor(frame.fill, color)
  if def[4] then
    local thickness = Core.Theme:Get("border.size")
    local color = Core.Theme:Get("color.panel.border")
    applyEdge(frame.top, frame, "TOP", thickness, color)
    applyEdge(frame.bottom, frame, "BOTTOM", thickness, color)
    frame.top:Show()
    frame.bottom:Show()
  end
  frame:Show()
end

function Appearance:GetPixelRoot()
  return root
end

function Appearance:GetPixelFactor()
  local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
  if type(factor) == "number" and factor > 0 then return factor end
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent:GetHeight()
  local effective = UIParent:GetEffectiveScale()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(effective) == "number" and effective > 0 then return logical * effective / height end
end

function Appearance:GetPixelUnit(region)
  local factor = self:GetPixelFactor()
  local effective = (region or UIParent):GetEffectiveScale()
  if factor and type(effective) == "number" and effective > 0 then return factor / effective end
end

-- One child coordinate unit equals one output pixel after the root scale is set.
function Appearance:Apply()
  if not loggedIn or applying then return end
  if InCombatLockdown() then
    pending = true
    return
  end
  applying = true
  pending = false
  local pixel = self:GetPixelUnit(UIParent)
  if not pixel then
    Core:Log("skip", "Appearance", "physical pixel factor unavailable")
    applying = false
    return
  end
  if not root then createFrames() end
  root:SetScale(pixel)
  root:ClearAllPoints()
  root:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
  local width, height = GetPhysicalScreenSize()
  root:SetSize(width, height)
  for _, def in ipairs(definitions) do applyFrame(def) end
  if DevilForever_Composition then DevilForever_Composition:Apply(root, self.frames) end
  applying = false
end

-- C. Events and subscriptions ----------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("UI_SCALE_CHANGED")
events:RegisterEvent("DISPLAY_SIZE_CHANGED")
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    loggedIn = true
    Appearance:Apply()
  elseif event == "PLAYER_REGEN_ENABLED" then
    if pending then Appearance:Apply() end
  else
    Appearance:Apply()
  end
end)

Core.Theme:RegisterCallback(Appearance, function() Appearance:Apply() end)
Core.Edit:RegisterCallback(Appearance, function(key)
  if key:sub(1, 11) == "appearance." then
    Core.Edit:AfterBatch(Appearance, function() Appearance:Apply() end)
  end
end)

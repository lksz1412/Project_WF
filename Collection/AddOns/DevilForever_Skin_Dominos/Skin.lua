-- Dominos owns button visibility, positions, paging and secure state.

local Core = DevilForever_Core
local owner = {}
local ready = false
local pending = false
local ids = {1, 2, 3, 4, 5, 6, 7, "class", "pet", "possess", "totem"}
local petEdges = setmetatable({}, {__mode = "k"})
local hookedBars = setmetatable({}, {__mode = "k"})
local petPending = false
local petScheduled = false
local schedulePet

local function applyPetEdges()
  local bar = _G.DominosFramepet
  if bar and not hookedBars[bar] and hooksecurefunc then
    for _, method in ipairs({"AttachButton", "DetachButton"}) do
      if type(bar[method]) == "function" then hooksecurefunc(bar, method, function() schedulePet() end) end
    end
    hookedBars[bar] = true
  end
  local active = Core.Theme:GetSet()
  local crest = DevilForever_ChatCrests and DevilForever_ChatCrests[active]
  local path = type(crest) == "table" and crest.petEdge
  if not path and (active == "devil" or active == "horde" or active == "alliance") then
    path = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\" .. active .. "\\PetEdge.tga"
  end
  if path and C_UIFileAsset and C_UIFileAsset.IsKnownFile and not C_UIFileAsset.IsKnownFile(path) then path = nil end
  local attached = {}
  if bar and bar.buttons then
    for _, button in pairs(bar.buttons) do
      attached[button] = true
      if path then
        local edge = petEdges[button]
        if not edge then
          edge = button:CreateTexture(nil, "BORDER", nil, -1)
          edge:SetAllPoints(button)
          edge:SetTexCoord(0, 1, 0, 1)
          edge:SetVertexColor(1, 1, 1, 1)
          petEdges[button] = edge
        end
        if edge:SetTexture(path) == false then edge:Hide() else edge:Show() end
      elseif petEdges[button] then
        petEdges[button]:Hide()
      end
    end
  end
  for button, edge in pairs(petEdges) do if not attached[button] then edge:Hide() end end
end

local function applyBar(id)
  local bar = _G["DominosFrame" .. id]
  if not bar or not bar.buttons then return end
  local key = type(id) == "number" and ("dominos.bar" .. id) or ("dominos." .. (id == "class" and "stance" or id))
  local values = Core.Edit:Get(key)
  for _, button in pairs(bar.buttons) do
    local text = button.HotKey
    if text and values.font and values.font.path and values.font.size then
      text:SetFont(values.font.path, values.font.size * DevilForever_Appearance:GetPixelUnit(text), values.font.flags or "OUTLINE")
      text:SetTextColor(unpack(values.color))
    end
  end
end

local function applyPet()
  if not ready then return end
  if InCombatLockdown() then petPending = true; return end
  if not DevilForever_Appearance:GetPixelUnit(UIParent) then
    Core:Log("skip", "Feature appearance", "physical pixel factor unavailable")
    return
  end
  applyBar("pet")
  applyPetEdges()
  petPending = false
end

schedulePet = function()
  petPending = true
  if petScheduled or InCombatLockdown() then return end
  petScheduled = true
  C_Timer.After(0, function()
    petScheduled = false
    if petPending then applyPet() end
  end)
end

local function apply()
  if not ready then return end
  if InCombatLockdown() then pending = true; return end
  if not DevilForever_Appearance:GetPixelUnit(UIParent) then
    Core:Log("skip", "Feature appearance", "physical pixel factor unavailable")
    return
  end
  for _, id in ipairs(ids) do applyBar(id) end
  applyPetEdges()
  pending = false
  petPending = false
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UPDATE_BINDINGS", "UI_SCALE_CHANGED"}) do
  events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then ready = true; apply()
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then apply()
  elseif petPending then applyPet() end
end)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key:sub(1, 8) == "dominos." then Core.Edit:AfterBatch(owner, apply) end
end)

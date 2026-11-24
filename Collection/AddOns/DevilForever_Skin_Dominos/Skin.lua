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
local geometryHooks = setmetatable({}, {__mode = "k"})
local tailPending = setmetatable({}, {__mode = "k"})   -- bars whose Layout ran in combat
local geometryKeys = {"point", "relPoint", "x", "y", "scale", "columns", "spacing", "rowSpacing",
  "rowOffset", "padW", "padH", "anchor", "isRightToLeft", "isBottomToTop"}

local function managedGeometry(bar)
  local sets = bar.sets
  local saved = sets and sets.dfGeometry
  if type(saved) ~= "table" then return end
  for _, key in ipairs(geometryKeys) do
    if (sets[key] or false) ~= (saved[key] or false) then
      sets.dfGeometry, sets.dfPixel, sets.dfTail = nil, nil, nil
      return
    end
  end
  return sets, saved
end

-- The second lower bar has four slots on its first row and eight on its last.
local function applyTail(bar)
  if InCombatLockdown() then pending = true; tailPending[bar] = true; return end
  tailPending[bar] = nil
  local sets = managedGeometry(bar)
  if not sets or not sets.dfTail then return end
  local left, _, top = bar:GetButtonInsets()
  local width, height = bar:GetButtonSize()
  local padW, padH = bar:GetPadding()
  local spacing = bar:GetSpacing()
  for index, button in ipairs(bar.buttons) do
    local row = index <= 4 and 0 or 1
    local column = index <= 4 and index + 3 or index - 5
    button:ClearAllPoints()
    button:SetPoint("TOPLEFT", bar, "TOPLEFT", padW - left + (width + spacing) * column,
      -(padH - top + (height + spacing + bar:GetRowSpacing()) * row))
  end
end

local function applyGeometry(pixel)
  for _, id in ipairs({1, 2, 3, 4, 5, "class", "pet", "possess", "totem", "menu", "bags", "queue"}) do
    local bar = _G["DominosFrame" .. id]
    if bar then
      local sets, saved = managedGeometry(bar)
      if sets and type(sets.dfPixel) == "number" and sets.dfPixel > 0 then
        if sets.dfTail and not geometryHooks[bar] then
          hooksecurefunc(bar, "Layout", applyTail)
          geometryHooks[bar] = true
          applyTail(bar)
        elseif tailPending[bar] then
          applyTail(bar)
        end
        if sets.dfPixel ~= pixel then
          sets.scale = sets.scale * pixel / sets.dfPixel
          sets.dfPixel, saved.scale = pixel, sets.scale
          bar:RestorePosition()
          bar:RestoreAnchor()
        end
      end
    end
  end
end

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
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if not pixel then
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
  local pixel = DevilForever_Appearance:GetPixelUnit(UIParent)
  if not pixel then
    Core:Log("skip", "Feature appearance", "physical pixel factor unavailable")
    return
  end
  applyGeometry(pixel)
  for _, id in ipairs(ids) do applyBar(id) end
  applyPetEdges()
  pending = false
  petPending = false
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED", "UPDATE_BINDINGS", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
  events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then ready = true; apply()
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then apply()
  elseif petPending then applyPet() end
  if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then C_Timer.After(0, apply) end
end)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key:sub(1, 8) == "dominos." then Core.Edit:AfterBatch(owner, apply) end
end)

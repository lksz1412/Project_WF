-- Two prepared physical-pixel surfaces; edited layouts retain the individual shell.
local Core = DevilForever_Core
local Composition = {}
DevilForever_Composition = Composition

local families = {devil = true, horde = true, alliance = true}
local presets = {fhd = true, qhd = true, uhd = true}
local covered = {"chat1", "chat2", "chat3", "action", "minimap", "ribbon", "upper", "aux",
  "ornamentLeft", "ornamentRight", "status", "seam1", "seam2", "seam3", "seam4"}
Composition.covered = covered

function Composition:GetFamily(name)
  if families[name] then return name end
  local crest = DevilForever_ChatCrests and DevilForever_ChatCrests[name]
  if type(crest) == "table" and (crest.family == "horde" or crest.family == "alliance") then return crest.family end
end

function Composition:RegisterCrestThemes()
  for id, crest in pairs(DevilForever_ChatCrests or {}) do
    if type(id) == "string" and not families[id] and type(crest) == "table"
        and type(crest.texture) == "string" and crest.texture ~= ""
        and (crest.family == "horde" or crest.family == "alliance") then
      local values = {}
      for _, token in ipairs(Core.Theme:ListTokens()) do values[token] = Core.Theme:GetFromSet(crest.family, token) end
      Core.Theme:RegisterSet(id, values)
    end
  end
end

function Composition:Create(root)
  if self.frame then return end
  local frame = CreateFrame("Frame", "DevilForever_CompositionFrame", root)
  frame:SetFrameStrata("BACKGROUND")
  frame:SetFrameLevel(0)
  frame:EnableMouse(false)
  frame:EnableKeyboard(false)
  frame:SetAllPoints(root)
  self.frame = frame
  self.top = frame:CreateTexture(nil, "BACKGROUND")
  self.deck = frame:CreateTexture(nil, "BACKGROUND")
end

local function known(path)
  return not (C_UIFileAsset and C_UIFileAsset.IsKnownFile) or C_UIFileAsset.IsKnownFile(path)
end

function Composition:GetPlan()
  local preset = Core.Presets:GetActive()
  if not presets[preset] then return end
  local active = Core.Theme:GetSet()
  local family = self:GetFamily(active)
  if not family then return end
  for _, key in ipairs(covered) do
    local edit = Core.Edit:GetEdits("appearance." .. key)
    if edit.position or edit.size or edit.color then return end
  end
  local aux, chat, right, status = Core.Edit:Get("appearance.aux"), Core.Edit:Get("appearance.chat1"),
    Core.Edit:Get("appearance.chat3"), Core.Edit:Get("appearance.status")
  for _, item in ipairs({aux, chat, right, status}) do
    if not item.position or not item.size or item.position.point ~= "TOPLEFT"
        or item.position.relativePoint ~= "TOPLEFT" or item.position.relativeTo ~= "DevilForever_AppearanceRoot" then return end
  end
  local top = -aux.position.y - math.floor(aux.size.height / 4)
  local split = -chat.position.y
  local bottom = -status.position.y + status.size.height
  local width = right.position.x + right.size.width
  if width <= 0 or split <= top or bottom <= split then return end
  -- Surfaces of the active theme only: devil ships <preset>_deck.tga; every other
  -- theme ships <preset>_deck_reviewed.tga and no _deck.tga (release build rule).
  -- A surface the client does not know leaves the individual shell (no plan).
  local path = "Interface\\AddOns\\DevilForever_Appearance\\Themes\\" .. family .. "\\Composition\\" .. preset
  local crest = DevilForever_ChatCrests and DevilForever_ChatCrests[active]
  if not families[active] then
    if type(crest) ~= "table" or type(crest.composition) ~= "string" then return end
    path = crest.composition .. preset
  end
  local reviewed = active ~= "devil"
  local deck = path .. (reviewed and "_deck_reviewed.tga" or "_deck.tga")
  if not known(path .. "_top.tga") or not known(deck) then return end
  return {top = {x = 0, y = top, width = width, height = split - top, texture = path .. "_top.tga"},
    deck = {x = 0, y = split, width = width, height = bottom - split, texture = deck},
    reviewed = reviewed, active = active}
end

local function paintSurfaces(self, root, plan)
  for _, key in ipairs({"top", "deck"}) do
    local values, texture = plan[key], self[key]
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", root, "TOPLEFT", values.x, -values.y)
    texture:SetSize(values.width, values.height)
    texture:SetTexCoord(0, 1, 0, 1)
    if texture:SetTexture(values.texture) == false then return false end
    texture:SetVertexColor(1, 1, 1, 1)
    texture:Show()
  end
  return true
end

function Composition:Apply(root, frames)
  if InCombatLockdown() then return end
  local plan = self:GetPlan()
  self.active = false
  self.reviewed = false
  if self.crest then self.crest:Hide() end
  if not plan or not paintSurfaces(self, root, plan) then self.frame:Hide(); return end
  self.frame:Show()
  self.active = true
  self.reviewed = plan.reviewed == true
  for _, key in ipairs(covered) do
    local frame = frames["appearance." .. key]
    frame.fill:Hide()
    if frame.top then frame.top:Hide(); frame.bottom:Hide() end
  end
  if self.reviewed then return end
  local crest = plan.active ~= "devil" and DevilForever_ChatCrests and DevilForever_ChatCrests[plan.active]
  if type(crest) ~= "table" or type(crest.texture) ~= "string" or not known(crest.texture) then return end
  local chat = frames["appearance.chat3"]
  self.crest = self.crest or chat:CreateTexture(nil, "ARTWORK")
  self.crest:ClearAllPoints()
  local size = Core.Edit:Get("appearance.chat3").size
  local height = size.height
  local inset = math.ceil(height * 0.145)
  local rightInset = math.ceil(size.width * 0.35)
  self.crest:SetPoint("BOTTOMRIGHT", chat, "BOTTOMRIGHT", -rightInset, inset)
  local side = height * 0.78
  self.crest:SetSize(side, side)
  if self.crest:SetTexture(crest.texture) == false then self.crest:Hide(); return end
  self.crest:SetTexCoord(0, 0.70, 0, 0.70)
  self.crest:SetVertexColor(1, 1, 1, 1)
  self.crest:SetAlpha(0.16)
  self.crest:Show()
end

Composition:RegisterCrestThemes()

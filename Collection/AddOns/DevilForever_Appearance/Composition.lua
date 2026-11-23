-- Two prepared physical-pixel surfaces; edited layouts retain the individual shell.
local Core = DevilForever_Core
local Composition = {}
DevilForever_Composition = Composition

local families = {devil = true, horde = true, alliance = true}
local presets = {fhd = true, qhd = true, uhd = true}

-- Calibrated inner shadow lips in the shipped 2048 x 256 top textures.
local lips = {
  alliance = {fhd = {78, 1965, 151, 215}, qhd = {201, 1842, 150, 213}, uhd = {247, 1795.25, 150, 216}},
  devil = {fhd = {80, 1964, 149, 215}, qhd = {203, 1842, 148, 214}, uhd = {248.75, 1795, 148, 216}},
  dwarf = {fhd = {122, 1913, 156, 231}, qhd = {240, 1798, 155, 229}, uhd = {282, 1753, 156, 232}},
  gnome = {fhd = {76, 1968, 150, 231}, qhd = {200, 1846, 149, 231}, uhd = {246.25, 1798, 149, 232}},
  horde = {fhd = {91, 1949.75, 160, 221}, qhd = {213, 1829, 159, 220}, uhd = {257.75, 1783, 160, 221}},
  human = {fhd = {84.5, 1958, 154, 235}, qhd = {207, 1837, 152, 236}, uhd = {252.5, 1790.75, 152, 237}},
  nightelf = {fhd = {190, 1869.0, 157, 232}, qhd = {300.25, 1759, 156, 230}, uhd = {335.25, 1723.0, 157, 231}},
  orc = {fhd = {140, 1890, 156, 241}, qhd = {256.75, 1779, 155, 241}, uhd = {298, 1735, 155, 242}},
  skyborne = {fhd = {83, 1956, 149, 239}, qhd = {206, 1835, 148, 240}, uhd = {252, 1787.5, 147, 241}},
  ["skyborne-horde"] = {fhd = {137, 1829.25, 148, 235}, qhd = {254, 1724.75, 147, 235}, uhd = {294.75, 1689.5, 147, 236}},
  tauren = {fhd = {136, 1897, 154, 229}, qhd = {253, 1784, 153, 228}, uhd = {293, 1739, 153, 230}},
  troll = {fhd = {82, 1952, 154, 244}, qhd = {206, 1832, 153, 243}, uhd = {251.25, 1786, 154, 244}},
  undead = {fhd = {75.25, 1970, 149, 237}, qhd = {198, 1856.0, 148, 236}, uhd = {245, 1802.0, 148, 238}},
}

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
  self.topPieces = {self.top}
  for index = 2, 9 do self.topPieces[index] = frame:CreateTexture(nil, "BACKGROUND") end
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
  local aux, chat, right, status, upper = Core.Edit:Get("appearance.aux"), Core.Edit:Get("appearance.chat1"),
    Core.Edit:Get("appearance.chat3"), Core.Edit:Get("appearance.status"), Core.Edit:Get("appearance.upper")
  for _, item in ipairs({aux, chat, right, status, upper}) do
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
  local x, y, wide, tall = upper.position.x, -upper.position.y, upper.size.width, upper.size.height
  if x <= 0 or wide <= 4 * tall or tall <= 0 or x + wide >= width
      or y <= top or y + tall >= split then return end
  local xs, ys = {0, x, x + wide, width}, {top, y, y + tall, split}
  local lip = lips[active] and lips[active][preset]
  if not lip then return end
  local us = {0, lip[1] / 2048, lip[2] / 2048, 1}
  local vs = {0, lip[3] / 256, lip[4] / 256, 1}
  local pieces = {}
  for row = 1, 3 do
    for column = 1, 3 do
      local u1, u2 = us[column], us[column + 1]
      if families[active] and column == 2 then u1 = 0.5 end
      pieces[#pieces + 1] = {x = xs[column], y = ys[row], width = xs[column + 1] - xs[column],
        height = ys[row + 1] - ys[row], coords = {u1, u2, vs[row], vs[row + 1]}}
    end
  end
  return {top = {x = 0, y = top, width = width, height = split - top, texture = path .. "_top.tga", pieces = pieces},
    deck = {x = 0, y = split, width = width, height = bottom - split, texture = deck},
    reviewed = reviewed, active = active}
end

local function paintSurfaces(self, root, plan)
  for _, key in ipairs({"top", "deck"}) do
    local values, texture = plan[key], self[key]
    for index, piece in ipairs(values.pieces or {values}) do
      local target = key == "top" and self.topPieces[index] or texture
      target:ClearAllPoints()
      target:SetPoint("TOPLEFT", root, "TOPLEFT", piece.x, -piece.y)
      target:SetSize(piece.width, piece.height)
      target:SetTexCoord(unpack(piece.coords or {0, 1, 0, 1}))
      if target:SetTexture(values.texture) == false then return false end
      target:SetVertexColor(1, 1, 1, 1)
      target:Show()
    end
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

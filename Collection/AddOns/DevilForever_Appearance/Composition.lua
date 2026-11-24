-- Two prepared physical-pixel surfaces; edited layouts retain the individual shell.
-- A theme that ships every HUD part for the active preset is built from those parts instead.
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

-- A. HUD parts -------------------------------------------------------------
-- One texel is one physical pixel of the preset. Sizes in pixels: band and deck = heights of the
-- two surfaces, cap = end cap width, fill = repeat length of a fill strip, joint = width of the
-- piece over a panel boundary, rivet = rivet side, crest = crest side, border = thickness of the
-- bar surround, edge = repeat length of a surround edge, gap = space between a bar and its surround.
local PART_SIZES = {
  fhd = {band = 124, deck = 214, cap = 48, fill = 256, joint = 16, rivet = 8, crest = 128, border = 6, edge = 64, gap = 2},
  qhd = {band = 144, deck = 248, cap = 64, fill = 256, joint = 20, rivet = 10, crest = 160, border = 8, edge = 64, gap = 2},
  uhd = {band = 204, deck = 332, cap = 96, fill = 256, joint = 32, rivet = 16, crest = 224, border = 12, edge = 64, gap = 2},
}

-- Part name -> {width size key, height size key, repeat axis or nil}.
local PART_SHAPES = {
  band_cap_left = {"cap", "band"}, band_cap_right = {"cap", "band"}, band_fill = {"fill", "band", "x"},
  deck_cap_left = {"cap", "deck"}, deck_cap_right = {"cap", "deck"}, deck_fill = {"fill", "deck", "x"},
  deck_joint = {"joint", "deck"}, rivet = {"rivet", "rivet"}, deck_crest = {"crest", "crest"},
  surround_corner_tl = {"border", "border"}, surround_corner_tr = {"border", "border"},
  surround_corner_bl = {"border", "border"}, surround_corner_br = {"border", "border"},
  surround_edge_top = {"edge", "border", "x"}, surround_edge_bottom = {"edge", "border", "x"},
  surround_edge_left = {"border", "edge", "y"}, surround_edge_right = {"border", "edge", "y"},
}
local REQUIRED_PARTS = {"band_cap_left", "band_cap_right", "band_fill", "deck_cap_left", "deck_cap_right",
  "deck_fill", "deck_joint", "rivet", "surround_corner_tl", "surround_corner_tr", "surround_corner_bl",
  "surround_corner_br", "surround_edge_top", "surround_edge_bottom", "surround_edge_left", "surround_edge_right"}
local OPTIONAL_PARTS = {"deck_crest"}

-- Part files shipped under Themes\<theme>\Parts\<preset>\<name>.tga, e.g.
-- horde = {uhd = {"band_cap_left", ...}}. A theme and preset without every required part draws
-- the prepared surfaces below.
local PARTS_SHIPPED = {}

-- Frames whose layout drives the surround and the Dominos methods after which it is re-measured.
local SURROUND_BARS = {"DominosFrame1", "DominosFrame2", "DominosFrame3"}
local BAR_METHODS = {"Layout", "RestorePosition", "SetFrameScale", "UpdateDisplayLayer", "UpdateDisplayLevel",
  "ShowFrame", "HideFrame"}
local STRATA = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}
local MAX_LEVEL = 10000

local function powerOfTwo(n)
  local value = 1
  while value < n do value = value * 2 end
  return value
end

-- Drawn size, power-of-two canvas (the drawing sits at its top-left) and repeat axis of a part.
local function partSize(preset, name)
  local sizes, shape = PART_SIZES[preset], PART_SHAPES[name]
  if not sizes or not shape then return end
  local width, height = sizes[shape[1]], sizes[shape[2]]
  return {width = width, height = height, canvasWidth = powerOfTwo(width), canvasHeight = powerOfTwo(height),
    tile = shape[3]}
end

local function partPath(theme, preset, name)
  return "Interface\\AddOns\\DevilForever_Appearance\\Themes\\" .. theme .. "\\Parts\\" .. preset .. "\\" .. name .. ".tga"
end

Composition.parts = {sizes = PART_SIZES, shapes = PART_SHAPES, required = REQUIRED_PARTS, optional = OPTIONAL_PARTS,
  shipped = PARTS_SHIPPED, bars = SURROUND_BARS, Size = partSize, Path = partPath}

-- B. Layout geometry -------------------------------------------------------

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

local function anchoredToRoot(item)
  return item.position and item.size and item.position.point == "TOPLEFT" and item.position.relativePoint == "TOPLEFT"
    and item.position.relativeTo == "DevilForever_AppearanceRoot"
end

-- Surface bounds of the unedited layout in root pixels (y grows downwards), or nil.
local function readBounds()
  local preset = Core.Presets:GetActive()
  if not presets[preset] then return end
  local active = Core.Theme:GetSet()
  local family = Composition:GetFamily(active)
  if not family then return end
  for _, key in ipairs(covered) do
    local edit = Core.Edit:GetEdits("appearance." .. key)
    if edit.position or edit.size or edit.color then return end
  end
  local aux, chat, right, status, upper = Core.Edit:Get("appearance.aux"), Core.Edit:Get("appearance.chat1"),
    Core.Edit:Get("appearance.chat3"), Core.Edit:Get("appearance.status"), Core.Edit:Get("appearance.upper")
  for _, item in ipairs({aux, chat, right, status, upper}) do
    if not anchoredToRoot(item) then return end
  end
  local top = -aux.position.y - math.floor(aux.size.height / 4)
  local split = -chat.position.y
  local bottom = -status.position.y + status.size.height
  local width = right.position.x + right.size.width
  if width <= 0 or split <= top or bottom <= split then return end
  local x, y, wide, tall = upper.position.x, -upper.position.y, upper.size.width, upper.size.height
  if x <= 0 or wide <= 4 * tall or tall <= 0 or x + wide >= width
      or y <= top or y + tall >= split then return end
  return {preset = preset, active = active, family = family, top = top, split = split, bottom = bottom,
    width = width, upper = {x = x, y = y, width = wide, height = tall}}
end

-- C. Prepared surfaces -----------------------------------------------------

function Composition:GetPlan()
  local bounds = readBounds()
  if not bounds then return end
  local preset, active, family = bounds.preset, bounds.active, bounds.family
  local top, split, bottom, width = bounds.top, bounds.split, bounds.bottom, bounds.width
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
  local x, y, wide, tall = bounds.upper.x, bounds.upper.y, bounds.upper.width, bounds.upper.height
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

-- D. Part placement --------------------------------------------------------
-- A placement draws the top-left width x height texels of a part's canvas at x, y (root pixels),
-- so every placement keeps one texel per pixel on both axes.

local function place(list, theme, preset, name, x, y, width, height, layer, sublevel)
  local size = partSize(preset, name)
  list[#list + 1] = {part = name, path = partPath(theme, preset, name), x = x, y = y, width = width, height = height,
    coords = {0, width / size.canvasWidth, 0, height / size.canvasHeight}, layer = layer, sublevel = sublevel}
end

-- Repeats a strip part along its axis over length pixels; the last copy is cut, never scaled.
local function tile(list, theme, preset, name, x, y, length, layer, sublevel)
  local size = partSize(preset, name)
  local step = size.tile == "x" and size.width or size.height
  local done = 0
  while done < length do
    local piece = math.min(step, length - done)
    if size.tile == "x" then
      place(list, theme, preset, name, x + done, y, piece, size.height, layer, sublevel)
    else
      place(list, theme, preset, name, x, y + done, size.width, piece, layer, sublevel)
    end
    done = done + piece
  end
end

local function round(value)
  return math.floor(value + 0.5)
end

-- Deck panels in screen order, or nil when one is missing or anchored elsewhere.
local function readPanels()
  local panels = {}
  for _, key in ipairs({"chat1", "chat2", "action", "minimap", "chat3"}) do
    local item = Core.Edit:Get("appearance." .. key)
    if not anchoredToRoot(item) then return end
    panels[#panels + 1] = {left = item.position.x, right = item.position.x + item.size.width}
  end
  table.sort(panels, function(a, b) return a.left < b.left end)
  return panels
end

function Composition:GetPartsPlan()
  local preset, active = Core.Presets:GetActive(), Core.Theme:GetSet()
  local listed = PARTS_SHIPPED[active] and PARTS_SHIPPED[active][preset]
  if type(listed) ~= "table" then return end
  local shipped = {}
  for _, name in ipairs(listed) do shipped[name] = true end
  for _, name in ipairs(REQUIRED_PARTS) do
    if not shipped[name] or not known(partPath(active, preset, name)) then return end
  end
  local bounds = readBounds()
  if not bounds or bounds.preset ~= preset then return end
  local sizes, panels = PART_SIZES[preset], readPanels()
  local top, split, bottom, width = bounds.top, bounds.split, bounds.bottom, bounds.width
  if not panels or split - top ~= sizes.band or bottom - split ~= sizes.deck or width <= 2 * sizes.cap then return end
  local list = {}
  tile(list, active, preset, "band_fill", sizes.cap, top, width - 2 * sizes.cap, "BACKGROUND", 1)
  place(list, active, preset, "band_cap_left", 0, top, sizes.cap, sizes.band, "BACKGROUND", 2)
  place(list, active, preset, "band_cap_right", width - sizes.cap, top, sizes.cap, sizes.band, "BACKGROUND", 2)
  tile(list, active, preset, "deck_fill", sizes.cap, split, width - 2 * sizes.cap, "BACKGROUND", 1)
  place(list, active, preset, "deck_cap_left", 0, split, sizes.cap, sizes.deck, "BACKGROUND", 2)
  place(list, active, preset, "deck_cap_right", width - sizes.cap, split, sizes.cap, sizes.deck, "BACKGROUND", 2)
  local joints = {}
  for index = 1, #panels - 1 do
    local centre = (panels[index].right + panels[index + 1].left) / 2
    joints[#joints + 1] = centre
    place(list, active, preset, "deck_joint", round(centre - sizes.joint / 2), split, sizes.joint, sizes.deck, "BORDER", 0)
  end
  for _, centre in ipairs(joints) do
    local x = round(centre - sizes.rivet / 2)
    place(list, active, preset, "rivet", x, split + sizes.rivet, sizes.rivet, sizes.rivet, "ARTWORK", 0)
    place(list, active, preset, "rivet", x, bottom - 2 * sizes.rivet, sizes.rivet, sizes.rivet, "ARTWORK", 0)
  end
  if shipped.deck_crest and known(partPath(active, preset, "deck_crest")) then
    local last = panels[#panels]
    place(list, active, preset, "deck_crest", round(last.left + (last.right - last.left) * 0.65 - sizes.crest / 2),
      split + round((sizes.deck - sizes.crest) / 2), sizes.crest, sizes.crest, "BORDER", 1)
  end
  return {theme = active, preset = preset, placements = list, joints = joints, bounds = bounds}
end

-- Rectangle of a frame in root pixels: {x1, y1, x2, y2}, rounded to whole pixels.
local function rootRect(frame, root)
  local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
  local rootLeft, rootTop = root:GetLeft(), root:GetTop()
  local scale, rootScale = frame:GetEffectiveScale(), root:GetEffectiveScale()
  if not (left and right and top and bottom and rootLeft and rootTop and scale and rootScale) or rootScale <= 0 then return end
  local ratio = scale / rootScale
  return {x1 = round(left * ratio - rootLeft), y1 = round(rootTop - top * ratio),
    x2 = round(right * ratio - rootLeft), y2 = round(rootTop - bottom * ratio)}
end

local function highestLevel(frame, depth)
  local level = frame:GetFrameLevel() or 0
  if depth > 0 and frame.GetChildren then
    for _, child in ipairs({frame:GetChildren()}) do level = math.max(level, highestLevel(child, depth - 1)) end
  end
  return level
end

local function strataRank(name)
  for index, value in ipairs(STRATA) do if value == name then return index end end
  return 0
end

-- Bars whose surrounds would touch share one surround around their union.
local function mergeRects(rects, margin)
  local groups = {}
  for _, rect in ipairs(rects) do groups[#groups + 1] = {x1 = rect.x1, y1 = rect.y1, x2 = rect.x2, y2 = rect.y2} end
  local merged = true
  while merged do
    merged = false
    for i = 1, #groups do
      for j = i + 1, #groups do
        local a, b = groups[i], groups[j]
        if a.x1 - margin <= b.x2 + margin and b.x1 - margin <= a.x2 + margin
            and a.y1 - margin <= b.y2 + margin and b.y1 - margin <= a.y2 + margin then
          a.x1, a.y1, a.x2, a.y2 = math.min(a.x1, b.x1), math.min(a.y1, b.y1), math.max(a.x2, b.x2), math.max(a.y2, b.y2)
          table.remove(groups, j)
          merged = true
          break
        end
      end
      if merged then break end
    end
  end
  table.sort(groups, function(a, b) return a.x1 < b.x1 or (a.x1 == b.x1 and a.y1 < b.y1) end)
  return groups
end

function Composition:GetSurroundPlan(root, theme, preset)
  local sizes = PART_SIZES[preset]
  if not sizes or not root then return end
  local rects, strata, level = {}, nil, 0
  for _, name in ipairs(SURROUND_BARS) do
    local bar = _G[name]
    local rect = bar and bar:IsShown() and rootRect(bar, root)
    if rect and rect.x2 > rect.x1 and rect.y2 > rect.y1 then
      rects[#rects + 1] = rect
      local barStrata = bar:GetFrameStrata()
      if not strata or strataRank(barStrata) > strataRank(strata) then strata = barStrata end
      level = math.max(level, highestLevel(bar, 3))
    end
  end
  if #rects == 0 then return end
  local margin, border = sizes.gap + sizes.border, sizes.border
  local groups, list = mergeRects(rects, margin), {}
  for _, group in ipairs(groups) do
    local x1, y1, x2, y2 = group.x1 - margin, group.y1 - margin, group.x2 + margin, group.y2 + margin
    group.outer = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    tile(list, theme, preset, "surround_edge_top", x1 + border, y1, x2 - x1 - 2 * border, "ARTWORK", 0)
    tile(list, theme, preset, "surround_edge_bottom", x1 + border, y2 - border, x2 - x1 - 2 * border, "ARTWORK", 0)
    tile(list, theme, preset, "surround_edge_left", x1, y1 + border, y2 - y1 - 2 * border, "ARTWORK", 0)
    tile(list, theme, preset, "surround_edge_right", x2 - border, y1 + border, y2 - y1 - 2 * border, "ARTWORK", 0)
    place(list, theme, preset, "surround_corner_tl", x1, y1, border, border, "ARTWORK", 1)
    place(list, theme, preset, "surround_corner_tr", x2 - border, y1, border, border, "ARTWORK", 1)
    place(list, theme, preset, "surround_corner_bl", x1, y2 - border, border, border, "ARTWORK", 1)
    place(list, theme, preset, "surround_corner_br", x2 - border, y2 - border, border, border, "ARTWORK", 1)
  end
  return {placements = list, groups = groups, bars = rects, strata = strata, level = math.min(level + 1, MAX_LEVEL)}
end

-- E. Part painting ---------------------------------------------------------

local function paintPlacements(pool, frame, root, placements)
  for index, placement in ipairs(placements) do
    local texture = pool[index]
    if not texture then
      texture = frame:CreateTexture(nil, placement.layer, nil, placement.sublevel)
      pool[index] = texture
    end
    texture:SetDrawLayer(placement.layer, placement.sublevel)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", root, "TOPLEFT", placement.x, -placement.y)
    texture:SetSize(placement.width, placement.height)
    texture:SetTexCoord(unpack(placement.coords))
    if texture:SetTexture(placement.path) == false then return false end
    texture:SetVertexColor(1, 1, 1, 1)
    texture:Show()
  end
  for index = #placements + 1, #pool do pool[index]:Hide() end
  return true
end

local function hideParts(self)
  for _, texture in ipairs(self.partPool or {}) do texture:Hide() end
  if self.surround then self.surround:Hide() end
  self.partsPlan = nil
  self.partsShown = false
end

function Composition:PaintSurround()
  local parts, root = self.partsPlan, self.root
  if not parts or not self.partsShown then return end
  local plan = self:GetSurroundPlan(root, parts.theme, parts.preset)
  if not self.surround then
    local surround = CreateFrame("Frame", "DevilForever_CompositionSurround", self.frame)
    surround:EnableMouse(false)
    surround:EnableKeyboard(false)
    surround:SetAllPoints(root)
    self.surround, self.surroundPool = surround, {}
  end
  self.surroundPlan = plan
  if not plan then self.surround:Hide(); return end
  self.surround:SetFrameStrata(plan.strata)
  self.surround:SetFrameLevel(plan.level)
  if not paintPlacements(self.surroundPool, self.surround, root, plan.placements) then self.surround:Hide(); return end
  self.surround:Show()
end

-- Re-measures the surround after Dominos lays out, moves, rescales, re-layers, shows or hides bars 1-3.
local function watchDominos(self)
  local addon = _G.Dominos
  if type(addon) == "table" and type(addon.RegisterCallback) == "function" and not self.dominosCallback then
    self.dominosCallback = true
    addon.RegisterCallback(self, "LAYOUT_LOADED", function()
      watchDominos(self)
      self:PaintSurround()
    end)
  end
  if not hooksecurefunc then return end
  self.hookedBars = self.hookedBars or {}
  for _, name in ipairs(SURROUND_BARS) do
    local bar = _G[name]
    if type(bar) == "table" and not self.hookedBars[bar] then
      for _, method in ipairs(BAR_METHODS) do
        if type(bar[method]) == "function" then hooksecurefunc(bar, method, function() self:PaintSurround() end) end
      end
      if type(bar.HookScript) == "function" then
        bar:HookScript("OnShow", function() self:PaintSurround() end)
        bar:HookScript("OnHide", function() self:PaintSurround() end)
      end
      self.hookedBars[bar] = true
    end
  end
end

-- The individual panel fills and edges under the composition.
local function hideCovered(frames)
  for _, key in ipairs(covered) do
    local frame = frames["appearance." .. key]
    frame.fill:Hide()
    if frame.top then frame.top:Hide(); frame.bottom:Hide() end
  end
end

local function paintParts(self, root, frames, plan)
  self.partPool = self.partPool or {}
  self.partsShown = true
  for _, texture in ipairs(self.topPieces) do texture:Hide() end
  self.deck:Hide()
  if self.crest then self.crest:Hide() end
  if not paintPlacements(self.partPool, self.frame, root, plan.placements) then return false end
  self.frame:Show()
  self.active, self.reviewed, self.partsPlan, self.root = true, false, plan, root
  hideCovered(frames)
  watchDominos(self)
  self:PaintSurround()
  return true
end

-- F. Apply -----------------------------------------------------------------

function Composition:Apply(root, frames)
  if InCombatLockdown() then return end
  local parts = self:GetPartsPlan()
  if parts and paintParts(self, root, frames, parts) then return end
  if self.partsShown then hideParts(self) end
  local plan = self:GetPlan()
  self.active = false
  self.reviewed = false
  if self.crest then self.crest:Hide() end
  if not plan or not paintSurfaces(self, root, plan) then self.frame:Hide(); return end
  self.frame:Show()
  self.active = true
  self.reviewed = plan.reviewed == true
  hideCovered(frames)
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

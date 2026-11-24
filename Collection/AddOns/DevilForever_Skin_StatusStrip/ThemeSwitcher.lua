local Core, Strip = DevilForever_Core, DevilForever_StatusStrip
if not Core or not Strip then return end

local korean = GetLocale() == "koKR"
local owner, ready, pending, direction = {}, false, false, 0

-- Image sets per preset: drawn for this statusstrip.bar height and font size;
-- the picture sits in the top-left corner of a canvas of these sizes.
local MEDIA = "Interface\\AddOns\\DevilForever_Skin_StatusStrip\\Media\\ThemeSwitcher\\"
local ART = {
  fhd = {height = 22, fontSize = 16, nameCanvas = 256, arrowCanvas = 32, canvasHeight = 32},
  qhd = {height = 24, fontSize = 18, nameCanvas = 256, arrowCanvas = 32, canvasHeight = 32},
  uhd = {height = 28, fontSize = 22, nameCanvas = 512, arrowCanvas = 32, canvasHeight = 32},
}
-- Shipped files of Media\ThemeSwitcher\<preset>\ (without .tga); a name not listed is shown as text.
local SHIPPED = {
  fhd = {
    "name_devil", "name_alliance", "name_horde", "name_human", "name_dwarf", "name_gnome",
    "name_nightelf", "name_orc", "name_tauren", "name_troll", "name_undead", "name_skyborne",
    "name_skyborne-horde", "arrow_prev_normal", "arrow_prev_hover", "arrow_prev_pushed",
    "arrow_prev_disabled", "arrow_next_normal", "arrow_next_hover", "arrow_next_pushed",
    "arrow_next_disabled",
  },
  qhd = {
    "name_devil", "name_alliance", "name_horde", "name_human", "name_dwarf", "name_gnome",
    "name_nightelf", "name_orc", "name_tauren", "name_troll", "name_undead", "name_skyborne",
    "name_skyborne-horde", "arrow_prev_normal", "arrow_prev_hover", "arrow_prev_pushed",
    "arrow_prev_disabled", "arrow_next_normal", "arrow_next_hover", "arrow_next_pushed",
    "arrow_next_disabled",
  },
  uhd = {
    "name_devil", "name_alliance", "name_horde", "name_human", "name_dwarf", "name_gnome",
    "name_nightelf", "name_orc", "name_tauren", "name_troll", "name_undead", "name_skyborne",
    "name_skyborne-horde", "arrow_prev_normal", "arrow_prev_hover", "arrow_prev_pushed",
    "arrow_prev_disabled", "arrow_next_normal", "arrow_next_hover", "arrow_next_pushed",
    "arrow_next_disabled",
  },
}
local shipped = {}
for preset, files in pairs(SHIPPED) do
  shipped[preset] = {}
  for _, file in ipairs(files) do shipped[preset][file] = true end
end
local ARROW_STATES = {"normal", "hover", "pushed", "disabled"}

local panel = CreateFrame("Frame", "DevilForever_StatusStripThemes", Strip:GetFrame())
panel:EnableMouse(false)
panel:Hide()
local nameSlot = CreateFrame("Frame", nil, panel)
nameSlot:SetClipsChildren(true)
nameSlot:EnableMouse(false)
local name = nameSlot:CreateFontString(nil, "OVERLAY")
name:SetJustifyH("CENTER")
name:SetWordWrap(false)
local nameArt = nameSlot:CreateTexture(nil, "OVERLAY")
nameArt:Hide()
local animation = name:CreateAnimationGroup()
local translation = animation:CreateAnimation("Translation")
translation:SetDuration(.12)
translation:SetSmoothing("OUT")
local artAnimation = nameArt:CreateAnimationGroup()
local artTranslation = artAnimation:CreateAnimation("Translation")
artTranslation:SetDuration(.12)
artTranslation:SetSmoothing("OUT")
local function center(region, x)
  region:ClearAllPoints()
  region:SetPoint("CENTER", nameSlot, "CENTER", x or 0, 0)
end
local function settle() center(name) end
local function settleArt() center(nameArt) end
animation:SetScript("OnFinished", settle)
animation:SetScript("OnStop", settle)
artAnimation:SetScript("OnFinished", settleArt)
artAnimation:SetScript("OnStop", settleArt)
local previous = CreateFrame("Button", nil, panel)
local following = CreateFrame("Button", nil, panel)
local previousText = previous:CreateFontString(nil, "OVERLAY")
local followingText = following:CreateFontString(nil, "OVERLAY")
previousText:SetAllPoints(previous)
followingText:SetAllPoints(following)
previousText:SetText("◀")
followingText:SetText("▶")
-- {button, fallback text, file side}; one texture object per state, made once.
local arrows = {{previous, previousText, "prev"}, {following, followingText, "next"}}
local arrowArt = {}
for _, arrow in ipairs(arrows) do
  local textures = {}
  for _, state in ipairs(ARROW_STATES) do
    textures[state] = arrow[1]:CreateTexture()
    textures[state]:SetAllPoints(arrow[1])
  end
  arrowArt[arrow[1]] = textures
end

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

-- Image set of the active preset when the bar height and font size are the ones it was drawn for.
local function artSpec(height, fontSize)
  local preset = Core.Presets and Core.Presets:GetActive()
  local spec = preset and ART[preset]
  if spec and spec.height == height and spec.fontSize == fontSize then return preset, spec end
end
local function artPath(preset, file)
  if preset and shipped[preset][file] then return MEDIA .. preset .. "\\" .. file .. ".tga" end
end

-- Name image when its file is listed and SetTexture accepts it; otherwise the FontString.
local function showName(preset, spec, width, height)
  local path = artPath(preset, "name_" .. Core.Theme:GetSet())
  if path and nameArt:SetTexture(path) ~= false then
    nameArt:SetTexCoord(0, width / spec.nameCanvas, 0, height / spec.canvasHeight)
    nameArt:SetSize(width, height)
    nameArt:Show()
    name:Hide()
  else
    nameArt:Hide()
    name:Show()
  end
end

-- Arrow images when all eight files of the preset load; otherwise both buttons show ◀ ▶.
local function showArrows(preset, spec, buttonWidth, height)
  local loaded = preset ~= nil
  for _, arrow in ipairs(arrows) do
    for _, state in ipairs(ARROW_STATES) do
      local path = loaded and artPath(preset, "arrow_" .. arrow[3] .. "_" .. state)
      loaded = path and arrowArt[arrow[1]][state]:SetTexture(path) ~= false
    end
  end
  for _, arrow in ipairs(arrows) do
    local button, text, textures = arrow[1], arrow[2], arrowArt[arrow[1]]
    if loaded then
      for _, state in ipairs(ARROW_STATES) do
        textures[state]:SetTexCoord(0, buttonWidth / spec.arrowCanvas, 0, height / spec.canvasHeight)
      end
      button:SetNormalTexture(textures.normal)
      button:SetPushedTexture(textures.pushed)
      button:SetDisabledTexture(textures.disabled)
      button:SetHighlightTexture(textures.hover, "BLEND")
      text:Hide()
    else
      for _, state in ipairs(ARROW_STATES) do textures[state]:SetTexture(nil) end
      text:Show()
    end
  end
end

local function dim(inCombat)
  for _, arrow in ipairs(arrows) do arrow[1]:SetAlpha(inCombat and .45 or 1) end
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
  local preset, spec = artSpec(height, font.size)
  showName(preset, spec, width, height)
  showArrows(preset, spec, buttonWidth, height)
  local single = #Core.Theme:ListChoices() <= 1
  for _, arrow in ipairs(arrows) do
    if single then arrow[1]:Disable() else arrow[1]:Enable() end
  end
  animation:Stop()
  artAnimation:Stop()
  name:SetText(Core.Theme:GetDisplayName(Core.Theme:GetSet()))
  settle()
  settleArt()
  if direction ~= 0 then
    center(name, direction * 8)
    center(nameArt, direction * 8)
    translation:SetOffset(-direction * 8, 0)
    artTranslation:SetOffset(-direction * 8, 0)
    animation:Play()
    artAnimation:Play()
  end
  panel:Show()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_REGEN_DISABLED" then dim(true); return end
  if event == "PLAYER_REGEN_ENABLED" then dim(false) end
  if event == "PLAYER_LOGIN" then ready = true; dim(Core.InCombat()); apply()
  elseif pending then apply() end
end)
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "statusstrip.bar" then Core.Edit:AfterBatch(owner, apply) end
end)

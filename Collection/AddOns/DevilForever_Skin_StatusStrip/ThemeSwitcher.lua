local Core, Strip = DevilForever_Core, DevilForever_StatusStrip
if not Core or not Strip then return end

local korean = GetLocale() == "koKR"
local ready, pending = false, false

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
    "arrow_next_disabled", "layout_new", "layout_old",
  },
  qhd = {
    "name_devil", "name_alliance", "name_horde", "name_human", "name_dwarf", "name_gnome",
    "name_nightelf", "name_orc", "name_tauren", "name_troll", "name_undead", "name_skyborne",
    "name_skyborne-horde", "arrow_prev_normal", "arrow_prev_hover", "arrow_prev_pushed",
    "arrow_prev_disabled", "arrow_next_normal", "arrow_next_hover", "arrow_next_pushed",
    "arrow_next_disabled", "layout_new", "layout_old",
  },
  uhd = {
    "name_devil", "name_alliance", "name_horde", "name_human", "name_dwarf", "name_gnome",
    "name_nightelf", "name_orc", "name_tauren", "name_troll", "name_undead", "name_skyborne",
    "name_skyborne-horde", "arrow_prev_normal", "arrow_prev_hover", "arrow_prev_pushed",
    "arrow_prev_disabled", "arrow_next_normal", "arrow_next_hover", "arrow_next_pushed",
    "arrow_next_disabled", "layout_new", "layout_old",
  },
}
local shipped = {}
for preset, files in pairs(SHIPPED) do
  shipped[preset] = {}
  for _, file in ipairs(files) do shipped[preset][file] = true end
end
local ARROW_STATES = {"normal", "hover", "pushed", "disabled"}

-- Image set of the active preset when the bar height and font size are the ones it was drawn for.
local function artSpec(height, fontSize)
  local preset = Core.Presets and Core.Presets:GetActive()
  local spec = preset and ART[preset]
  if spec and spec.height == height and spec.fontSize == fontSize then return preset, spec end
end
local function artPath(preset, file)
  if preset and shipped[preset][file] then return MEDIA .. preset .. "\\" .. file .. ".tga" end
end

-- One "◀ name ▶" switcher on the status strip. def: frameName, tooltips {previous, next},
-- choices() -> count, current() -> display name and image file name, cycle(step) -> ok,
-- place(panel, values) anchors the panel.
local function makeSwitcher(def)
  local direction = 0
  local panel = CreateFrame("Frame", def.frameName, Strip:GetFrame())
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
    GameTooltip:SetText(step < 0 and def.tooltips[1] or def.tooltips[2])
    if Core.InCombat() then
      GameTooltip:AddLine(korean and "전투 중에는 바꿀 수 없습니다." or "Unavailable in combat.", 1, .5, .2)
    end
    GameTooltip:Show()
  end
  local function choose(button, step)
    direction = step
    local ok = def.cycle(step)
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

  -- Name image when its file is listed and SetTexture accepts it; otherwise the FontString.
  local function showName(preset, spec, file, width, height)
    local path = artPath(preset, file)
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

  local switcher = {panel = panel}
  function switcher.dim(inCombat)
    for _, arrow in ipairs(arrows) do arrow[1]:SetAlpha(inCombat and .45 or 1) end
  end
  function switcher.apply()
    local values = Core.Edit:Get("statusstrip.bar")
    local font, size = values.font, values.size
    if not font or not size then return end
    local count = def.choices()
    if count == 0 then panel:Hide(); return end
    local height, width = size.height, font.size * 12
    local buttonWidth = math.max(height, font.size + 6)
    panel:ClearAllPoints()
    def.place(panel, values)
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
    previousText:SetText("◀")
    followingText:SetText("▶")
    local display, file = def.current()
    local preset, spec = artSpec(height, font.size)
    showName(preset, spec, file, width, height)
    showArrows(preset, spec, buttonWidth, height)
    for _, arrow in ipairs(arrows) do
      if count <= 1 then arrow[1]:Disable() else arrow[1]:Enable() end
    end
    animation:Stop()
    artAnimation:Stop()
    name:SetText(display)
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
  return switcher
end

local theme = makeSwitcher({
  frameName = "DevilForever_StatusStripThemes",
  tooltips = korean and {"이전 테마", "다음 테마"} or {"Previous theme", "Next theme"},
  choices = function() return #Core.Theme:ListChoices() end,
  current = function()
    local active = Core.Theme:GetSet()
    return Core.Theme:GetDisplayName(active), "name_" .. active
  end,
  cycle = function(step) return Core.Theme:Cycle(step) end,
  place = function(panel, values) panel:SetPoint("RIGHT", Strip:GetFrame(), "RIGHT", -(values.spacing or 12), 0) end,
})

-- Layout version of the active screen preset: New = <preset>-v2 (V2), Old = <preset>-v1 (V1).
-- The version in use is read from the PitBull4 profile: New only when it holds the V2 flag and this
-- package's V2 revision (an earlier V2 counts as Old, so one step brings the current New); a switch
-- requests that compare preset and reloads the interface (as /dfp preset <name> then /dfp go).
local VERSIONS = {{key = "new", suffix = "-v2", label = "New"}, {key = "old", suffix = "-v1", label = "Old"}}
local function versionChoices()
  local active = Core.Presets:GetActive()
  if not active or not Core.IsLoadedInClient("PitBull4") then return {} end
  local out = {}
  for _, version in ipairs(VERSIONS) do
    if Core.Presets:IsRegistered(active .. version.suffix) then out[#out + 1] = version end
  end
  return out
end
local function versionInUse()
  local addon = _G.PitBull4
  local profile = addon and addon.db and addon.db.profile
  local current = type(profile) == "table" and profile.dfLayoutV2 == true
    and profile.dfLayoutRevision == Core.Presets.layoutV2Revision
  return current and VERSIONS[1] or VERSIONS[2]
end
local version = makeSwitcher({
  frameName = "DevilForever_StatusStripLayouts",
  tooltips = korean and {"이전 배치", "다음 배치"} or {"Previous layout", "Next layout"},
  choices = function() return #versionChoices() end,
  current = function()
    local inUse = versionInUse()
    return inUse.label, "layout_" .. inUse.key
  end,
  cycle = function(step)
    if Core.InCombat() then return false end
    local choices = versionChoices()
    if #choices < 2 then return false end
    local index = 1
    for i, choice in ipairs(choices) do if choice == versionInUse() then index = i end end
    local target = choices[(index - 1 + step) % #choices + 1]
    local active = Core.Presets:GetActive()
    -- A layout request still waiting (e.g. the first-login re-apply) is replaced by this one.
    local status = Core.Profiles.GetStatus and Core.Profiles:GetStatus()
    local pending = type(status) == "table" and status.pending
    if type(pending) == "table" and pending.action == "preset"
        and (pending.name == active .. "-v1" or pending.name == active .. "-v2") then
      Core.Profiles:Cancel()
    end
    local ok, lines = Core.Presets:Restore(active .. target.suffix)
    for _, line in ipairs(type(lines) == "table" and lines or {lines}) do Core.Profiles:Print(line) end
    if not ok then return false end
    local went, why = Core.Profiles:Go()
    if not went then Core.Profiles:Print("안 함: " .. tostring(why)) end
    return went
  end,
  place = function(panel, values) panel:SetPoint("RIGHT", theme.panel, "LEFT", -(values.spacing or 12), 0) end,
})

local switchers = {theme, version}
local function apply()
  if not ready then return end
  if Core.InCombat() then pending = true; return end
  pending = false
  for _, switcher in ipairs(switchers) do switcher.apply() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_REGEN_DISABLED" then
    for _, switcher in ipairs(switchers) do switcher.dim(true) end
    return
  end
  if event == "PLAYER_REGEN_ENABLED" then
    for _, switcher in ipairs(switchers) do switcher.dim(false) end
  end
  if event == "PLAYER_LOGIN" then
    ready = true
    for _, switcher in ipairs(switchers) do switcher.dim(Core.InCombat()) end
    apply()
  elseif pending then apply() end
end)
local owner = {}
Core.Theme:RegisterCallback(owner, apply)
Core.Edit:RegisterCallback(owner, function(key)
  if key == "statusstrip.bar" then Core.Edit:AfterBatch(owner, apply) end
end)

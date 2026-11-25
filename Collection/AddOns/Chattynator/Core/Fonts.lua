---@class addonTableChattynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local fonts = {
  default = "ChatFontNormal",
}

local function GetOutlineKey()
  local outline = addonTable.Config.Get(addonTable.Config.Options.MESSAGE_FONT_OUTLINE)
  if outline == "thin" then
    return "OUTLINE"
  elseif outline == "thick" then
    return "THICKOUTLINE"
  else
    return ""
  end
end

local function GetShadowKey()
  local shadow = addonTable.Config.Get(addonTable.Config.Options.SHOW_FONT_SHADOW)
  if shadow then
    return "SHADOW"
  else
    return ""
  end
end

function addonTable.Core.GetFontByID(id)
  if not fonts[id .. GetOutlineKey() .. GetShadowKey()] then
    addonTable.Core.CreateFont(id, GetOutlineKey(), GetShadowKey())
  end
  return fonts[id .. GetOutlineKey() .. GetShadowKey()] or fonts["default" .. GetOutlineKey() .. GetShadowKey()] or fonts["default"]
end

local modes = {
  {"", ""},
  {"", "SHADOW"},
  {"OUTLINE", ""},
  {"OUTLINE", "SHADOW"},
  {"THICKOUTLINE", ""},
  {"THICKOUTLINE", "SHADOW"},
}

function addonTable.Core.OverwriteDefaultFont(id)
  for _, m in ipairs(modes) do
    local key = m[1] .. m[2]
    if not fonts[id .. key] and fonts["default" .. key] then
      addonTable.Core.CreateFont(id, m[1], m[2])
    end
    fonts["default" .. key] = fonts[id .. key] or fonts["default" .. key]
  end

  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.MessageFont] = true})
end

function addonTable.Core.GetFontScalingFactor()
  return addonTable.Config.Get(addonTable.Config.Options.MESSAGE_FONT_SIZE) / 14
end

local alphabet = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}

local locale = GetLocale()
local overrideAlphabet = "roman"
if locale == "koKR" then
  overrideAlphabet = "korean"
elseif locale == "zhCN" then
  overrideAlphabet = "simplifiedchinese"
elseif locale == "zhTW" then
  overrideAlphabet = "traditionalchinese"
elseif locale == "ruRU" then
  overrideAlphabet = "russian"
end

local function GetMembers(overrideFile, outline)
  local members = {}
  local coreFont = _G[fonts["default"]]
  for _, a in ipairs(alphabet) do
    local forAlphabet = coreFont:GetFontObjectForAlphabet(a)
    local file, size, _ = forAlphabet:GetFont()
    if a == overrideAlphabet and overrideFile then
      table.insert(members, {
        alphabet = a,
        file = overrideFile,
        height = size,
        flags = outline,
      })
    else
      table.insert(members, {
        alphabet = a,
        file = file,
        height = size,
        flags = outline,
      })
    end
  end

  return members
end

-- A copy of a font family at factor times its size, for widgets that are sized instead of
-- scaled (ChatFrame1EditBox). Returns the global name; the base name itself for factor 1 or a
-- font that is not a family.
local scaledFonts = {}
function addonTable.Core.GetScaledFont(fontName, factor)
  local base = _G[fontName]
  if factor == 1 or type(base) ~= "table" or not base.GetFontObjectForAlphabet then
    return fontName
  end
  local key = fontName .. "_" .. math.floor(factor * 1000 + 0.5)
  if scaledFonts[key] then
    return scaledFonts[key]
  end
  local globalName = "ChattynatorScaled" .. key
  if not _G[globalName] then
    local members = {}
    for _, a in ipairs(alphabet) do
      local file, size, flags = base:GetFontObjectForAlphabet(a):GetFont()
      table.insert(members, {alphabet = a, file = file, height = size * factor, flags = flags})
    end
    local family = CreateFontFamily(globalName, members)
    family:SetJustifyH("LEFT")
    family:SetTextColor(base:GetTextColor())
    for _, a in ipairs(alphabet) do
      local from, to = base:GetFontObjectForAlphabet(a), family:GetFontObjectForAlphabet(a)
      to:SetShadowOffset(from:GetShadowOffset())
      to:SetShadowColor(from:GetShadowColor())
    end
  end
  scaledFonts[key] = globalName
  return globalName
end

function addonTable.Core.CreateFont(lsmPath, outline, shadow, force)
  local key = lsmPath .. outline .. shadow
  if fonts[key] and not force then
    error("duplicate font creation " .. key)
  end
  local globalName = "ChattynatorFont" .. key
  local lowerGlobal = globalName:lower()

  --Protection against different lsmPaths with different capitalisation clashing when trying to make a font family
  local val = FindValueInTableIf(GetFonts(), function(a) return a:lower() == lowerGlobal:lower() end)
  if val then
    fonts[key] = val
    return
  end
  if lsmPath == "default" then
    CreateFontFamily(globalName, GetMembers(nil, outline))
  else
    local path = LSM:Fetch("font", lsmPath, true)
    if not path then
      return
    end

    local font = CreateFontFamily(globalName, GetMembers(path, outline))
    font:SetTextColor(1, 1, 1)
  end

  fonts[key] = globalName

  local fontFamily = _G[globalName]
  fontFamily:SetJustifyH("LEFT")

  if shadow == "SHADOW" then
    for _, a in ipairs(alphabet) do
      local font = fontFamily:GetFontObjectForAlphabet(a)
      font:SetShadowOffset(1, -1)
      font:SetShadowColor(0, 0, 0, 0.8)
    end
  end
end

addonTable.Core.CreateFont("default", "", "", true) -- Clone the ChatFontNormal to avoid sizing issues

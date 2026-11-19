-- Functional defaults for SexyMap (SexyMap2DB, plain table, account scope).
--
-- Shape: SexyMap creates SexyMap2DB at its own ADDON_LOADED and keeps one
-- profile per character under the key "<name>-<realm>" ("<name> <surname>"
-- with regional unique names), the key computed below exactly as SexyMap
-- does. A string there ("global") makes the character use SexyMap2DB.global;
-- that string is the user's choice and is kept (Core logs a conflict).
-- Each module table (core, buttons, ...) is created by SexyMap only when it is
-- missing, so a module table written here must hold every key SexyMap's own
-- table has: the values below are SexyMap's own defaults except the two marked
-- with a requirement. Appearance values (shape, scale, position, borders,
-- button angles) come from SexyMap's defaults or the Codex appearance fragment.
-- Mouse-wheel zoom and the left-click ping are always on in SexyMap and need
-- no value.

local Core = DevilForever_Core

local function sexyMapProfileKey()
  if type(RegionalUniqueNamesEnabled) == "function" and RegionalUniqueNamesEnabled() then
    local name, surname = UnitNameUnmodified("player")
    if type(name) == "string" and name ~= "" and type(surname) == "string" then return name .. " " .. surname end
    return nil
  end
  local name, realm = UnitNameUnmodified("player"), GetRealmName()
  if type(name) == "string" and name ~= "" and type(realm) == "string" and realm ~= "" then
    return name .. "-" .. realm
  end
end

local profileKey = type(UnitNameUnmodified) == "function" and type(GetRealmName) == "function" and sexyMapProfileKey()

if not profileKey then
  Core:Log("skip", "Defaults:SexyMap", "SexyMap profile key (character name and realm) not known at load; not registered")
  return
end

local spec = {
  version = 1,
  targets = {
    {
      savedVariable = "SexyMap2DB",
      shape = "plain",
      values = {
        [profileKey] = {
          core = {                       -- SexyMap.lua:344-351 (shape left to SexyMap / Codex)
            lock = false,
            clamp = true,
            rightClickToConfig = false,  -- plan row 5 (click): a right click on the map does not open the settings window
            autoZoom = 5,
            northTag = true,
          },
          buttons = {                    -- Buttons.lua:218-245
            radius = 10,
            scale = 1,
            dragPositions = {
              DayNight = 45,
              MiniMapTracking = -16,
              GameTimeFrame = 22,
              MiniMapMailFrame = 2,
              AddonCompartmentFrame = 126,
              MinimapZoomIn = -55,
              MinimapZoomOut = -36,
            },
            visibilitySettings = {
              MiniMapTracking = "always",  -- R1 / plan row 5 (tracking icon): tracking button always shown, not only on hover
              MinimapZoomIn = "never",
              MinimapZoomOut = "never",
              MiniMapWorldMapButton = "never",
              SexyMapZoneTextButton = "always",
              TimeManagerClockButton = "never",
              MiniMapMailFrame = "always",
              CraftingOrder = "always",
              ExpansionLandingPageMinimapButton = "hover",
              AddonCompartmentFrame = "never",
              DayNight = "hover",
            },
            allowDragging = true,
            lockDragging = false,
            controlVisibility = true,
          },
        },
      },
    },
  },
}

local appearance = {
  fhd = function()
-- Appearance body for a newly created native SexyMap profile through Defaults.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "SexyMap appearance", "UI scale unavailable at defaults registration")
  return {}
end
local effective = 192 / 140
return {core = {shape = 130871, point = "TOPLEFT", relpoint = "TOPLEFT", x = 1292 / effective, y = -860 / effective, scale = effective * pixel}}
  end,
  qhd = function()
-- Appearance body for a newly created native SexyMap profile through Defaults.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "SexyMap appearance", "UI scale unavailable at defaults registration")
  return {}
end
local effective = 224 / 140
return {core = {shape = 130871, point = "TOPLEFT", relpoint = "TOPLEFT", x = 1720 / effective, y = -1186 / effective, scale = effective * pixel}}
  end,
  uhd = function()
-- Appearance body for a newly created native SexyMap profile through Defaults.
local ui = UIParent and UIParent:GetEffectiveScale()
local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
if type(factor) ~= "number" or factor <= 0 then
  local _, height = GetPhysicalScreenSize()
  local logical = UIParent and UIParent:GetHeight()
  if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
      and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
end
local pixel = type(factor) == "number" and factor > 0 and type(ui) == "number" and ui > 0 and factor / ui
if not pixel then
  DevilForever_Core:Log("skip", "SexyMap appearance", "UI scale unavailable at defaults registration")
  return {}
end
local effective = 304 / 140
return {core = {shape = 130871, point = "TOPLEFT", relpoint = "TOPLEFT", x = 2596 / effective, y = -1820 / effective, scale = effective * pixel}}
  end,
}

local layout = appearance[Core.Presets:PickForScreen()]
if layout then
  local ok, proposed = pcall(layout)
  if ok and type(proposed) == "table" then
    local profile = spec.targets[1].values[profileKey]
    for field, value in pairs(proposed and proposed.core or {}) do
      profile.core[field] = value
    end
    if proposed.core and proposed.core.shape then
      profile.borders = {hideBlizzard = true, borders = {}, applyPreset = false,
        backdrop = {scale = 1, show = false, textureColor = {}, borderColor = {}, settings = {
          bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
          edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
          insets = {left = 4, top = 4, right = 4, bottom = 4}, edgeSize = 16, tile = false}}}
    end
  elseif not ok then
    Core:Log("skip", "Defaults:SexyMap", tostring(proposed))
  end
end
Core.Defaults:Register("SexyMap", spec)

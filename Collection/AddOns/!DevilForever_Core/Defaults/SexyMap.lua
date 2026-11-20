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
-- with a requirement. Appearance values (shape, scale, position, borders) are
-- not defaults: they are one root fragment per preset (fhd, qhd, uhd, each
-- computed for its screen) with profileKey = this character's key, added with
-- Presets:AddFragment. Presets writes it only when that profile was nil at
-- SexyMap's ADDON_LOADED, or on a /dfp preset request, at the next
-- PLAYER_ENTERING_WORLD and by merging into the tables SexyMap has made (no
-- table is created, a "global" choice is kept); an existing profile keeps its
-- appearance (one without those keys included) and the kept notice names
-- /dfp preset. Button angles are SexyMap's defaults below.
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
-- Appearance of the SexyMap profile for this preset's screen (a root fragment, see the header).
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
-- Appearance of the SexyMap profile for this preset's screen (a root fragment, see the header).
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
-- Appearance of the SexyMap profile for this preset's screen (a root fragment, see the header).
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

-- The installed SexyMap version the fragments are made for (SexyMap.toc).
local SEXYMAP_VERSION = "v12.1.7"

local presetNames = {}
for name in pairs(appearance) do presetNames[#presetNames + 1] = name end
table.sort(presetNames)
for _, name in ipairs(presetNames) do
  if Core.Presets:IsRegistered(name) then
    local ok, proposed = pcall(appearance[name])
    if ok and type(proposed) == "table" and type(proposed.core) == "table" and next(proposed.core) then
      local profile = {core = proposed.core}
      if proposed.core.shape then
        profile.borders = {hideBlizzard = true, borders = {}, applyPreset = false,
          backdrop = {scale = 1, show = false, textureColor = {}, borderColor = {}, settings = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            insets = {left = 4, top = 4, right = 4, bottom = 4}, edgeSize = 16, tile = false}}}
      end
      Core.Presets:AddFragment(name, {folder = "SexyMap", savedVariable = "SexyMap2DB", section = "root",
        profileKey = profileKey, addonVersion = SEXYMAP_VERSION, version = 1, values = profile})
    elseif not ok then
      Core:Log("skip", "Defaults:SexyMap", name .. " appearance: " .. tostring(proposed))
    end
  end
end
Core.Defaults:Register("SexyMap", spec)

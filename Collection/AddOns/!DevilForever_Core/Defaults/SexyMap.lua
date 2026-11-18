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

DevilForever_Core.Defaults:Register("SexyMap", {
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
              TimeManagerClockButton = "always",
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
})

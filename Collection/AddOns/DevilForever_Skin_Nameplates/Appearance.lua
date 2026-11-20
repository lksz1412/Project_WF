local _, addon = ...
local Core = DevilForever_Core
local Appearance = DevilForever_Appearance
local pending = false
local appliedTexture = setmetatable({}, {__mode = "k"})  -- [bar texture region] = what GetTexture read after our set

local function readable(v)
  return v ~= nil and not (type(issecretvalue) == "function" and issecretvalue(v))
end

local function writable(region)
  return region and not (region.IsForbidden and region:IsForbidden())
    and not (region.IsProtected and region:IsProtected())
end

local function parts(plate)
  local frame = plate and plate.UnitFrame
  if not frame then return end
  local bars = frame.HealthBarsContainer
  return frame, bars and bars.healthBar or frame.healthBar, frame.name
end

-- The two styles (enemy, friendly) of the active preset, with the theme's
-- texture and font paths; rebuilt after a theme or nameplate edit change and
-- when the active preset changes.
local styles, stylesPreset = {}, nil

local function dropStyles() styles, stylesPreset = {}, nil end

local function styleFor(unit)
  local name = Core.Presets:GetActive()
  local profile = addon.nameplateProfiles[name]
  if not profile then return end
  if stylesPreset ~= name then styles, stylesPreset = {}, name end
  local friendly = unit and type(UnitIsFriend) == "function" and UnitIsFriend("player", unit)
  local role = friendly and "friendly" or "enemy"
  local style = styles[role]
  if not style then
    local base = profile[role]
    local edit = Core.Edit:Get("nameplates." .. role)
    local size = edit.size or base
    style = {width = size.width, height = size.height, font = edit.font or {size = base.fontPx},
             texture = Core.Theme:Get(profile.textureToken), fontPath = Core.Theme:Get(profile.fontToken)}
    styles[role] = style
  end
  return style, profile
end

local function setAppearance(plate, unit)
  if not writable(plate) then return end
  local frame, bar, font = parts(plate)
  if not writable(frame) then return end
  local values, profile = styleFor(unit or frame.unit or frame.displayedUnit)
  if not values then return end
  -- Each value is written only when the region does not already hold it
  -- (the client may reset a plate it reuses, so the region is asked).
  if writable(bar) and type(bar.SetSize) == "function" then
    local pixel = Appearance:GetPixelUnit(bar)
    if pixel then
      local width, height = values.width * pixel, values.height * pixel
      local w, h = bar:GetSize()
      if not (readable(w) and readable(h) and w == width and h == height) then bar:SetSize(width, height) end
      if type(bar.SetStatusBarTexture) == "function" then
        local region = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture()
        local current = region and type(region.GetTexture) == "function" and region:GetTexture()
        if not (region and appliedTexture[region] ~= nil and appliedTexture[region] == current) then
          bar:SetStatusBarTexture(values.texture)
          region = type(bar.GetStatusBarTexture) == "function" and bar:GetStatusBarTexture()
          if region and type(region.GetTexture) == "function" then appliedTexture[region] = region:GetTexture() end
        end
      end
    end
  end
  if writable(font) and type(font.SetFont) == "function" and type(font.GetFont) == "function" then
    local pixel = Appearance:GetPixelUnit(font)
    if pixel then
      local path, size, flags = font:GetFont()
      local wantPath, wantSize = values.font.path or values.fontPath, values.font.size * pixel
      local wantFlags = values.font.flags or flags or ""
      if not (readable(path) and readable(size) and path == wantPath and size == wantSize and (flags or "") == wantFlags) then
        font:SetFont(wantPath, wantSize, wantFlags)
      end
    end
  end
end

local function safeApply(plate, unit)
  local ok, reason = pcall(setAppearance, plate, unit)
  if not ok and not addon.nameplateWarning then
    addon.nameplateWarning = true
    Core:Log("skip", "Nameplate appearance", tostring(reason))
  end
end

local function allPlates()
  local get = C_NamePlate and C_NamePlate.GetNamePlates
  if type(get) ~= "function" then return {} end
  local ok, plates = pcall(get)
  return ok and type(plates) == "table" and plates or {}
end

local function applyAll()
  if InCombatLockdown() then pending = true; return end
  pending = false
  for _, plate in ipairs(allPlates()) do safeApply(plate) end
end

local function dimensions(plate)
  if not plate or (plate.IsForbidden and plate:IsForbidden()) then return end
  local frame, bar = parts(plate)
  if not bar or not bar.GetSize or (bar.IsForbidden and bar:IsForbidden()) then return end
  local target = styleFor(frame.unit or frame.displayedUnit)
  if not target then return end
  local width, height = bar:GetSize()
  if type(issecretvalue) == "function" and (issecretvalue(width) or issecretvalue(height)) then return end
  local pixel = Appearance:GetPixelUnit(bar)
  if not pixel or type(width) ~= "number" or type(height) ~= "number" then return end
  return {width = width / pixel, height = height / pixel, targetWidth = target.width, targetHeight = target.height}
end

function addon.NameplateSizes()
  local result = {inspected = 0, measured = 0, matched = 0}
  for _, plate in ipairs(allPlates()) do
    result.inspected = result.inspected + 1
    local ok, size = pcall(dimensions, plate)
    if ok and size then
      result.measured = result.measured + 1
      if not result.first then result.first = size end
      if math.abs(size.width - size.targetWidth) < 1 and math.abs(size.height - size.targetHeight) < 1 then
        result.matched = result.matched + 1
      end
    end
  end
  return result
end

local listener = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_LOGIN", "NAME_PLATE_UNIT_ADDED", "PLAYER_REGEN_ENABLED",
                          "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
  listener:RegisterEvent(event)
end
listener:SetScript("OnEvent", function(_, event, unit)
  if event == "NAME_PLATE_UNIT_ADDED" then
    if InCombatLockdown() then pending = true; return end
    local get = C_NamePlate and C_NamePlate.GetNamePlateForUnit
    if type(get) == "function" then
      local ok, plate = pcall(get, unit)
      if ok and plate then safeApply(plate, unit) end
    end
  elseif event ~= "PLAYER_REGEN_ENABLED" or pending then
    applyAll()
  end
end)
Core.Theme:RegisterCallback(addon, function()
  dropStyles()
  applyAll()
end)
Core.Edit:RegisterCallback(addon, function(key)
  if key == "nameplates.enemy" or key == "nameplates.friendly" then
    dropStyles()
    Core.Edit:AfterBatch(addon, applyAll)
  end
end)

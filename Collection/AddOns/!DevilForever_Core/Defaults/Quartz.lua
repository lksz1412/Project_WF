local result = DevilForever_Core.Defaults:Register("Quartz", {
  version = 1,
  targets = {
    {
      savedVariable = "Quartz3DB",
      shape = "acedb",
      profile = "Default",
      preserveSharedProfiles = true,
      values = { modules = { Buff = false } },
    },
    {
      -- Swing bar (hunters, auto shot): the last seconds of the shot cycle drawn as the window to
      -- stand still in; editable in Quartz's Swing options.
      savedVariable = "Quartz3DB",
      shape = "acedb",
      profile = "Default",
      namespace = "Swing",
      preserveSharedProfiles = true,
      values = { dfStandStill = 0.5 },
    },
  },
})

local Core = DevilForever_Core
local loggedIn, pending, hookedAddon = false, false
local keys = {"point", "x", "y", "w", "h", "scale"}
local function applyScale()
  if not loggedIn then return end
  if Core.InCombat() then pending = true; return end
  pending = false
  local library = LibStub and LibStub("AceAddon-3.0", true)
  local addon = library and library:GetAddon("Quartz3", true)
  if not addon then return end
  if addon ~= hookedAddon and type(addon.ApplySettings) == "function" then
    hooksecurefunc(addon, "ApplySettings", applyScale)
    hookedAddon = addon
  end
  local ui = UIParent and UIParent:GetEffectiveScale()
  local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
  if type(factor) ~= "number" or factor <= 0 then
    local _, height = GetPhysicalScreenSize()
    local logical = UIParent and UIParent:GetHeight()
    if type(height) == "number" and height > 0 and type(logical) == "number" and logical > 0
        and type(ui) == "number" and ui > 0 then factor = logical * ui / height end
  end
  if type(factor) ~= "number" or factor <= 0 or type(ui) ~= "number" or ui <= 0 then return end
  local pixel, managed = factor / ui, false
  for _, name in ipairs({"Player", "Target", "Focus"}) do
    local module = addon:GetModule(name, true)
    local values = module and module.db and module.db.profile
    local saved = values and values.dfGeometry
    if type(saved) == "table" and type(values.dfPixel) == "number" and values.dfPixel > 0 then
      local matches = true
      for _, key in ipairs(keys) do if values[key] ~= saved[key] then matches = false; break end end
      if not matches then
        values.dfPixel, values.dfGeometry = nil, nil
      else
        managed = true
        if values.dfPixel ~= pixel then
          local ratio = pixel / values.dfPixel
          values.x, values.y, values.scale = values.x * ratio, values.y * ratio, values.scale * ratio
          values.dfPixel = pixel
          for _, key in ipairs(keys) do saved[key] = values[key] end
          if module:IsEnabled() and module.Bar then
            module.Bar:SetConfig(values)
            module.Bar:ApplySettings()
          end
        end
      end
    end
  end
  return managed
end

Core:On("PLAYER_LOGIN", function() loggedIn = true; applyScale() end)
Core:On("ADDON_LOADED", function(_, name) if name == "Quartz" then applyScale() end end)
for _, event in ipairs({"PLAYER_ENTERING_WORLD", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED"}) do
  Core:On(event, function()
    if applyScale() and C_Timer and C_Timer.After then C_Timer.After(0, applyScale) end
  end)
end
Core:On("PLAYER_REGEN_ENABLED", function() if pending then applyScale() end end)
return result

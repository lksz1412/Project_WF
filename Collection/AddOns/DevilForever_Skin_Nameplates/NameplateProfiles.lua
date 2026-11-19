local _, addon = ...
local profiles = {
  fhd = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="fhd",enemy={width=180,height=20,fontPx=18},friendly={width=180,height=20,fontPx=18},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
profile.edits = {}
for _, role in ipairs({"enemy", "friendly"}) do
  local values = profile[role]
  profile.edits["nameplates." .. role] = {size = {width = values.width, height = values.height},
    font = {size = values.fontPx}}
end
return profile
  end)(),
  qhd = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="qhd",enemy={width=220,height=24,fontPx=22},friendly={width=220,height=24,fontPx=22},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
profile.edits = {}
for _, role in ipairs({"enemy", "friendly"}) do
  local values = profile[role]
  profile.edits["nameplates." .. role] = {size = {width = values.width, height = values.height},
    font = {size = values.fontPx}}
end
return profile
  end)(),
  uhd = (function()
-- Native nameplate targets and Core edit defaults.
local profile = {name="uhd",enemy={width=280,height=30,fontPx=28},friendly={width=280,height=30,fontPx=28},textureToken="texture.statusbar",fontToken="font.normal",preserveHealthThreatColors=true,preserveCastbar=true}
profile.edits = {}
for _, role in ipairs({"enemy", "friendly"}) do
  local values = profile[role]
  profile.edits["nameplates." .. role] = {size = {width = values.width, height = values.height},
    font = {size = values.fontPx}}
end
return profile
  end)(),
}
if type(addon) == "table" then addon.nameplateProfiles = profiles end
return profiles

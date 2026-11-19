local API = DevilForever_FUFDefaults
local ready = false
local state = {state = "waiting", sent = 0, verified = false}
local scopes = {"player", "target", "focus", "pet", "targettarget", "targettargettarget", "focustarget", "pettarget", "boss", "party"}
local fields = {"width", "height", "x", "y", "portraitMode", "footerHeight", "spacingTitle", "spacingPower", "spacingPortrait", "spacingDocked",
  "bossSpacing", "partyOrientation", "partyGrowReverse", "partySpacing", "partyPetLayout", "partyPetSide", "partyPetGap",
  "partyPetsX", "partyPetsY", "partyPetWidth", "partyPetHeight", "partyTargetSide", "partyTargetWidth", "partyTargetHeight", "partyTargetX", "partyTargetY"}
local screens = {fhd = {1920, 1080}, qhd = {2560, 1440}, uhd = {3840, 2160}}

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function pixelUnit()
  local ui = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()
  local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
  if not finite(factor) or factor <= 0 then
    local height
    if type(GetPhysicalScreenSize) == "function" then local width; width, height = GetPhysicalScreenSize() end
    local logical = UIParent and UIParent.GetHeight and UIParent:GetHeight()
    if finite(height) and height > 0 and finite(logical) and logical > 0 and finite(ui) and ui > 0 then factor = logical * ui / height end
  end
  if finite(factor) and factor > 0 and finite(ui) and ui > 0 then return factor / ui end
end

function API.LayoutReady() ready = true end

function API.GetLayoutCommands(preset)
  local layout = type(API.LayoutPresets) == "table" and API.LayoutPresets[preset]
  if type(layout) ~= "function" then return nil, "unknown-preset" end
  local pixel = pixelUnit()
  if not pixel then return nil, "pixel-unavailable" end
  local values, commands = layout(pixel), {}
  for _, scope in ipairs(scopes) do
    for _, key in ipairs(fields) do
      local value = values[scope] and values[scope][key]
      if value ~= nil then
        if type(value) == "number" and not finite(value) then return nil, "invalid-geometry" end
        commands[#commands + 1] = "set " .. scope .. " " .. key .. " " .. tostring(value)
      end
    end
  end
  return commands, "DF Compare " .. preset
end

local function activeProfile()
  local db = ForeverUnitFramesDB
  local key = API.GetStatus().key
  local active = key and type(db) == "table" and type(db.active) == "table" and db.active[key]
  local profile = active and type(db.profiles) == "table" and db.profiles[active]
  return active, profile, db
end

local function refused(reason)
  state = {state = reason, sent = 0, verified = false}
  return false, reason
end

-- The native API has no profile clone/restore/readback; only an explicitly selected comparison clone may be changed.
function API.ApplyLayout(preset)
  if state.state == "sending" then return false, "busy" end
  if not ready then return refused("waiting") end
  if InCombatLockdown() then return refused("combat") end
  local commands, expected = API.GetLayoutCommands(preset)
  if not commands then return refused(expected) end
  local width, height
  if type(GetPhysicalScreenSize) == "function" then width, height = GetPhysicalScreenSize() end
  local minimum = screens[preset]
  if not finite(width) or not finite(height) then return refused("screen-unavailable") end
  if width < minimum[1] or height < minimum[2] then return refused("screen-too-small") end
  local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
  if type(metadata) ~= "function" or metadata("ForeverUnitFrames", "Version") ~= "0.65.2" then return refused("version-mismatch") end
  local active, profile, db = activeProfile()
  if active ~= expected or type(profile) ~= "table" then return refused("comparison-profile-required") end
  local handler = type(SlashCmdList) == "table" and SlashCmdList.FOREVERUNITFRAMES
  if type(handler) ~= "function" then return refused("api-missing") end
  state = {state = "sending", preset = preset, sent = 0, verified = false}
  for _, command in ipairs(commands) do
    local current, _, currentDB = activeProfile()
    if InCombatLockdown() or current ~= expected or currentDB ~= db then
      state.state = "partial-failure"
      state.reason = "context-changed"
      return false, state.state
    end
    local ok, result = pcall(handler, command)
    if not ok or result == false then
      state.state = "partial-failure"
      state.reason = ok and "native-refused" or "native-error"
      return false, state.state
    end
    state.sent = state.sent + 1
  end
  state.state = "sent-unverified"
  return true, state.state
end

function API.GetLayoutStatus()
  local copy = {}
  for key, value in pairs(state) do copy[key] = value end
  return copy
end

SLASH_DEVILFOREVERFUFLAYOUT1 = "/dffuf"
SlashCmdList = SlashCmdList or {}
SlashCmdList.DEVILFOREVERFUFLAYOUT = function(message)
  local command, preset = (message or ""):match("^%s*(%S*)%s*(%S*)%s*$")
  if command == "layout" and preset ~= "" then
    local ok, reason = API.ApplyLayout(preset)
    print("DevilForever FUF: " .. reason .. "; " .. API.GetLayoutStatus().sent .. " native commands. /fuf: select your original profile to return.")
    if not ok then print("DevilForever FUF: use /fuf to save and select a separate profile named DF Compare " .. preset .. ".") end
  else
    print("DevilForever FUF: /dffuf layout fhd|qhd|uhd. In /fuf, save a separate DF Compare <preset> profile first. Original profiles are not changed; native readback and visual checks are required.")
  end
end

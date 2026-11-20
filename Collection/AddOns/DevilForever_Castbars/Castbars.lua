-- One cast bar per unit between Quartz and Forever Unit Frames (FUF).
--
-- For each unit below, while the Quartz module of that unit is enabled, the
-- FUF cast bar of the same unit (<FUF frame>.castbar, a plain StatusBar that
-- FUF builds once per frame, FUF Elements/Castbar.lua Build) is hidden right
-- after FUF shows it. FUF shows and hides the bar only through SetShown and
-- then reads IsShown for the frame's shape (Castbar.lua setShown), so a hook
-- after SetShown/Show keeps FUF's layout code consistent. The check runs on
-- every show, and Quartz3:EnableModule/DisableModule (the path of Quartz's
-- options and profile changes, Quartz.lua ApplySettings/SetModuleEnabled) are
-- post-hooked: turning a module on hides FUF's bar at once, turning it off
-- shows FUF's bar again when FUF last asked for it to be shown.
--
-- Session only: nothing is written to Quartz3DB, ForeverUnitFramesDB or any
-- saved variable; a character without Quartz loaded never loads this addon
-- (TOC Dependencies). Blizzard's own cast bars are left to Quartz
-- (hideblizz, Quartz modules/Player.lua and Target.lua).
--
-- Hooks are set at PLAYER_LOGIN (after FUF made its frames) and retried at
-- every PLAYER_ENTERING_WORLD and, while a unit is still unhooked, at the
-- first REGEN_ROUNDS PLAYER_REGEN_ENABLED of a session and RETRY seconds after
-- each (a FUF bar that is still missing then is off in FUF): on a login in combat FUF
-- builds its frames after combat through its queue, which may run over
-- several frames (FUF Units/Single.lua CreateAll, Core/Init.lua AfterCombat).
-- Each bar is hooked once. A bar already shown when it is hooked is hidden at
-- once.

local ADDON = ...

local UNITS = {
  {unit = "player", module = "Player", frame = "ForeverUnitFrames_player"},
  {unit = "target", module = "Target", frame = "ForeverUnitFrames_target"},
  {unit = "focus", module = "Focus", frame = "ForeverUnitFrames_focus"},
  {unit = "pet", module = "Pet", frame = "ForeverUnitFrames_pet"},
}

local API = {}
DevilForever_Castbars = API

local RETRY = {1, 5}
local REGEN_ROUNDS = 3
local regenRounds = 0

local hooked = {}   -- [unit] = FUF castbar that carries our hooks
local hidden = {}   -- [unit] = number of times this session the bar was hidden
local wanted = {}   -- [unit] = shown state FUF last asked for (SetShown/Show)
local quartzHooked = false

local function log(message)
  local core = DevilForever_Core
  if type(core) == "table" and type(core.Log) == "function" then core:Log("info", ADDON, message) end
end

-- The Quartz module object, or nil when Quartz (AceAddon "Quartz3") or the
-- module is not there.
local function quartzModule(name)
  local stub = type(LibStub) == "table" and LibStub("AceAddon-3.0", true)
  local quartz = stub and stub:GetAddon("Quartz3", true)
  return quartz and quartz:GetModule(name, true) or nil
end

local function quartzOwns(entry)
  local module = quartzModule(entry.module)
  return module ~= nil and module:IsEnabled() and true or false
end

local function conceal(entry, bar)
  if bar:IsShown() and quartzOwns(entry) then
    bar:Hide()
    hidden[entry.unit] = (hidden[entry.unit] or 0) + 1
  end
end

local function fufBar(entry)
  local frame = _G[entry.frame]
  local bar = type(frame) == "table" and frame.castbar
  if type(bar) == "table" and type(bar.SetShown) == "function" then return bar end
  return nil
end

-- A Quartz module was switched: hand the unit over now.
local function moduleSwitched(name)
  for _, entry in ipairs(UNITS) do
    local bar = entry.module == name and hooked[entry.unit]
    if bar and bar == fufBar(entry) then
      if quartzOwns(entry) then
        conceal(entry, bar)
      elseif wanted[entry.unit] and not bar:IsShown() then
        bar:Show()
      end
    end
  end
end

local function hookQuartz()
  if quartzHooked then return end
  local stub = type(LibStub) == "table" and LibStub("AceAddon-3.0", true)
  local quartz = stub and stub:GetAddon("Quartz3", true)
  if type(quartz) ~= "table" or type(quartz.EnableModule) ~= "function" or type(quartz.DisableModule) ~= "function" then
    return
  end
  quartzHooked = true
  hooksecurefunc(quartz, "EnableModule", function(_, name) moduleSwitched(name) end)
  hooksecurefunc(quartz, "DisableModule", function(_, name) moduleSwitched(name) end)
end

local frame = CreateFrame("Frame")

-- Returns true while some unit has no hooked FUF bar.
local function hookAll()
  hookQuartz()
  local done, missing = {}, false
  for _, entry in ipairs(UNITS) do
    local bar = fufBar(entry)
    if bar and hooked[entry.unit] ~= bar then
      hooked[entry.unit] = bar
      wanted[entry.unit] = bar:IsShown() and true or false
      hooksecurefunc(bar, "SetShown", function(self, shown)
        wanted[entry.unit] = shown and true or false
        if shown then conceal(entry, self) end
      end)
      hooksecurefunc(bar, "Show", function(self)
        wanted[entry.unit] = true
        conceal(entry, self)
      end)
      conceal(entry, bar)
      done[#done + 1] = entry.unit
    elseif not bar then
      missing = true
    end
  end
  if #done > 0 then log("FUF cast bars hooked: " .. table.concat(done, ", ")) end
  if missing and regenRounds < REGEN_ROUNDS then
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  else
    frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
  end
  return missing
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_REGEN_ENABLED" then regenRounds = regenRounds + 1 end
  if hookAll() and event == "PLAYER_REGEN_ENABLED" then
    for _, delay in ipairs(RETRY) do C_Timer.After(delay, hookAll) end
  end
end)

-- {[unit] = {frame, hooked = bool, quartz = bool (the Quartz module is on),
-- fufShown = bool|nil (nil without a FUF bar), wanted = bool|nil (shown state
-- FUF last asked for), hidden = count this session}}
-- for player, target, focus and pet.
function API.GetStatus()
  local out = {}
  for _, entry in ipairs(UNITS) do
    local bar = fufBar(entry)
    local shown
    if bar then shown = bar:IsShown() and true or false end
    out[entry.unit] = {
      frame = entry.frame,
      hooked = bar ~= nil and hooked[entry.unit] == bar,
      quartz = quartzOwns(entry),
      fufShown = shown,
      wanted = wanted[entry.unit],
      hidden = hidden[entry.unit] or 0,
    }
  end
  return out
end

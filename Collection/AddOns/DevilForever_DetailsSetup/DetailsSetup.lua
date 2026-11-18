-- Details! threat window. Once per character, in the session in which Details!
-- makes this character's settings, a second Details! window is opened and set
-- to the Tiny Threat plugin (raid plugin DETAILS_PLUGIN_TINY_THREAT), through
-- Details' own calls:
--   Details:CreateInstance(true)                     the welcome window's
--       "create second window" (Details frames/window_welcome.lua), placed GAP
--       pixels right of window 1 the same way;
--   Details.RaidTables:EnableRaidMode(window, name)  the window's plugin menu
--       (Details frames/window_main.lua).
-- Window 1 (damage done, Details' default display) is not touched. Details!
-- keeps the new window in this character's profile and restores it itself;
-- Details' saved variables are never written here.
--
-- "Settings made in this session" = Details.character_first_run, which Details
-- sets while loading when _detalhes_database.active_profile is still ""
-- (Details functions/loaddata.lua). A character that already had Details
-- settings, an account-wide profile (Details.always_use_profile), a second
-- window or Tiny Threat already shown keeps what it has.
--
-- Runs DELAY seconds after the first PLAYER_ENTERING_WORLD of a session (Details
-- starts one frame after PLAYER_LOGIN), out of combat (a combat start delays it
-- to PLAYER_REGEN_ENABLED). While Details! has not finished starting it tries
-- again, at most TRIES times in all. The result is stored once in
-- DevilForever_DetailsSetupDB (per character) and the step never runs again:
--   "created"        window made and showing Tiny Threat; record.window = id
--   "not-applied"    window made, Details did not switch it to the plugin
--   "kept-existing"  nothing changed; record.reason says which case above
--   "plugin-missing" Details_TinyThreat is not loaded or is disabled in Details
--   "window-limit"   Details gave no new window (its window limit)
--   "error"          a Details call raised an error (passed to the client
--                    error handler)
-- Nothing is stored while Details! is not loaded or not started.

local ADDON = ...
local DB_NAME = "DevilForever_DetailsSetupDB"
local VERSION = 1
local PLUGIN = "DETAILS_PLUGIN_TINY_THREAT"
local DELAY = 10
local TRIES = 3
local GAP = 50

local API = {}
DevilForever_DetailsSetup = API

local session = {state = "waiting", tries = 0}

local function log(message)
  local core = DevilForever_Core
  if type(core) == "table" and type(core.Log) == "function" then core:Log("info", ADDON, message) end
end

local function report(err)
  local handler = type(geterrorhandler) == "function" and geterrorhandler()
  if handler then handler(err) end
end

local function loadedInClient(folder)
  local core = DevilForever_Core
  if type(core) == "table" and type(core.IsLoadedInClient) == "function" then return core.IsLoadedInClient(folder) end
  local fn = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
  return fn and fn(folder) and true or false
end

-- Details has run its startup (Details startup.lua clears `initializing`).
local function started(details)
  return type(details.IsLoaded) == "function" and details.IsLoaded() == true and not details.initializing
end

-- nil when the window should be made, else result, reason.
local function decide(details)
  if not details.character_first_run then return "kept-existing", "settings existed before this session" end
  if details.always_use_profile then return "kept-existing", "account-wide profile" end
  if details:GetNumInstances() ~= 1 then return "kept-existing", "more than one window" end
  local raid = details.RaidTables
  local plugin = type(raid) == "table" and type(raid.NameTable) == "table" and raid.NameTable[PLUGIN]
  if type(plugin) ~= "table" or not plugin.__enabled then return "plugin-missing" end
  if type(raid.PluginsInUse) == "table" and raid.PluginsInUse[PLUGIN] ~= nil then
    return "kept-existing", "plugin already shown"
  end
end

-- result, window id
local function make(details)
  local first = details:GetInstance(1)
  local window = details:CreateInstance(true)
  if type(window) ~= "table" then return "window-limit" end
  if type(first) == "table" and first.baseframe and window.baseframe then
    window.baseframe:SetPoint("topleft", first.baseframe, "topright", GAP, 0)
    window.baseframe:SetPoint("bottomleft", first.baseframe, "bottomright", GAP, 0)
    window:SaveMainWindowPosition()
    window:RestoreMainWindowPosition()
  end
  details.RaidTables:EnableRaidMode(window, PLUGIN)
  local id = window:GetId()
  if window.current_raid_plugin == PLUGIN then return "created", id end
  return "not-applied", id
end

local frame = CreateFrame("Frame")
local waitingForCombatEnd = false
local attempt

local function later()
  C_Timer.After(DELAY, attempt)
end

local function run()
  local stored = _G[DB_NAME]
  if type(stored) == "table" and stored.result ~= nil then
    session.state = "done-before"
    return
  end
  local details = _G.Details
  if not loadedInClient("Details") or type(details) ~= "table" then
    session.state = "details-not-loaded"
    return
  end
  session.tries = session.tries + 1
  if not started(details) then
    session.state = "details-not-ready"
    if session.tries < TRIES then later() end
    return
  end
  local record = {version = VERSION}
  local result, reason = decide(details)
  if result == nil then
    local ok, made, id = pcall(make, details)
    if ok then
      result, record.window = made, id
    else
      report(made)
      result = "error"
    end
  end
  record.result, record.reason = result, reason
  _G[DB_NAME] = record
  session.state = "applied"
  log(result .. (reason and (" (" .. reason .. ")") or ""))
end

attempt = function()
  if InCombatLockdown() then
    waitingForCombatEnd = true
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    session.state = "waiting-combat"
    return
  end
  run()
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    later()
  elseif event == "PLAYER_REGEN_ENABLED" and waitingForCombatEnd then
    waitingForCombatEnd = false
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    later()
  end
end)

-- {state = "waiting" | "waiting-combat" | "details-not-loaded" |
-- "details-not-ready" | "done-before" | "applied", tries = number,
-- record = copy of this character's stored record or nil}.
function API.GetStatus()
  local stored = _G[DB_NAME]
  local copy
  if type(stored) == "table" then
    copy = {}
    for k, v in pairs(stored) do copy[k] = v end
  end
  return {state = session.state, tries = session.tries, record = copy}
end

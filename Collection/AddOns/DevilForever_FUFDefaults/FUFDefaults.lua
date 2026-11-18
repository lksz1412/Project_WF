-- Forever Unit Frames (FUF) setting that depends on another addon: while Grid2
-- is loaded, FUF's raid frames are switched off, once per character, through
-- FUF's own command handler SlashCmdList.FOREVERUNITFRAMES (the documented
-- "/fuf raid off", FUF Core/Commands.lua). FUF's raid profile is per character
-- (ForeverUnitFramesDB.raid[<Name-Realm>]); FUF's party frames live in the
-- account-wide unit profile and are not touched. FUF's saved variables are only
-- read here, never written.
--
-- Runs DELAY seconds after the first PLAYER_ENTERING_WORLD of a session (after
-- FUF's 15 s save hold on a fresh install), out of combat (a combat start
-- delays it to PLAYER_REGEN_ENABLED). Per character the result is kept in
-- DevilForever_FUFDefaultsDB.chars[<Name-Realm>] (FUF's own character key) and
-- the step never runs again for that character:
--   raid  "switched-off"     "/fuf raid off" was sent and FUF's raid profile
--                            now stores general.enabled = false
--         "kept-user-value"  the raid profile already stores general.enabled
--         "not-applied"      sent, but the raid profile does not read false
--         "api-missing"      FUF's command handler is not there
--         "error"            the command raised an error (passed to the client
--                            error handler)
-- Nothing is stored (the next login tries again) while Grid2 is not loaded,
-- FUF has not made ForeverUnitFramesDB yet, or the player name is unknown.
-- FUF profiles store overrides only, so a stored value is one somebody chose;
-- a missing one is FUF's default (on).

local ADDON = ...
local DB_NAME = "DevilForever_FUFDefaultsDB"
local FUF_DB = "ForeverUnitFramesDB"
local RAID_ADDON = "Grid2"
local VERSION = 1
local DELAY = 20

local API = {}
DevilForever_FUFDefaults = API

local session = {state = "waiting"}

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

-- FUF's character key "Name-Realm" (FUF Raid/Profiles.lua, Profiles.CharKey).
local function charKey()
  if type(UnitFullName) ~= "function" then return nil end
  local name, realm = UnitFullName("player")
  if (not realm or realm == "") and type(GetNormalizedRealmName) == "function" then realm = GetNormalizedRealmName() end
  if type(name) ~= "string" or name == "" or type(realm) ~= "string" or realm == "" then return nil end
  return name .. "-" .. realm
end

local function database()
  local db = _G[DB_NAME]
  if type(db) ~= "table" then
    db = {}
    _G[DB_NAME] = db
  end
  if type(db.chars) ~= "table" then db.chars = {} end
  return db
end

local function stores(scopeTable, key)
  return type(scopeTable) == "table" and scopeTable[key] ~= nil
end

local function raidGeneral(fdb, key)
  local raid = type(fdb.raid) == "table" and fdb.raid[key]
  return type(raid) == "table" and raid.general or nil
end

local function send(handler, command)
  local ok, err = pcall(handler, command)
  if not ok then
    report(err)
    return false
  end
  return true
end

local function run()
  local fdb = _G[FUF_DB]
  if not loadedInClient(RAID_ADDON) then
    session.state = "grid2-not-loaded"
    return
  end
  if type(fdb) ~= "table" then
    session.state = "fuf-not-ready"
    return
  end
  local key = charKey()
  if not key then
    session.state = "player-unknown"
    return
  end
  local db = database()
  if type(db.chars[key]) == "table" then
    session.state = "done-before"
    return
  end
  local record = {version = VERSION}
  local handler = type(SlashCmdList) == "table" and SlashCmdList.FOREVERUNITFRAMES
  if type(handler) ~= "function" then
    record.raid = "api-missing"
  elseif stores(raidGeneral(fdb, key), "enabled") then
    record.raid = "kept-user-value"
  elseif not send(handler, "raid off") then
    record.raid = "error"
  else
    record.raid = (raidGeneral(fdb, key) or {}).enabled == false and "switched-off" or "not-applied"
  end
  db.chars[key] = record
  session.state = "applied"
  log(key .. ": raid " .. record.raid)
end

local frame = CreateFrame("Frame")
local waitingForCombatEnd = false

local function attempt()
  if InCombatLockdown() then
    waitingForCombatEnd = true
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    session.state = "waiting-combat"
    return
  end
  run()
end

local function later()
  C_Timer.After(DELAY, attempt)
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

-- {state = "waiting" | "waiting-combat" | "grid2-not-loaded" | "fuf-not-ready" |
-- "player-unknown" | "done-before" | "applied", key = character key or nil,
-- record = copy of this character's stored record or nil}.
function API.GetStatus()
  local key = charKey()
  local db = _G[DB_NAME]
  local stored = key and type(db) == "table" and type(db.chars) == "table" and db.chars[key]
  local copy
  if type(stored) == "table" then
    copy = {}
    for k, v in pairs(stored) do copy[k] = v end
  end
  return {state = session.state, key = key, record = copy}
end

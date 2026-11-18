-- Shared base of DevilForever_Core: namespace, saved-variable setup, event
-- dispatch, callback lists, status log and table helpers used by the modules.
-- Core changes no frame directly; it writes registered saved variables only at
-- load time: after a user command, or preset values into saved variables that
-- are new on disk (Profiles.lua, Presets.lua).

local addonName, Core = ...

DevilForever_Core = Core
Core.name = addonName
Core.DB_SCHEMA = 1
Core.STATUS_LIMIT = 200

local pairs, ipairs, type, next, pcall = pairs, ipairs, type, next, pcall
local tostring, tinsert, tremove = tostring, table.insert, table.remove

-- Tables -------------------------------------------------------------------

-- Deep copy of plain data; metatables are not copied.
function Core.CopyTable(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = Core.CopyTable(v) end
  return out
end

-- Deep copy of plain data taken from other addons' saved variables. Keys must be
-- strings, numbers or booleans; values strings, numbers, booleans or tables.
-- Other keys and values (functions, userdata, threads) and a table met again on
-- the current path (a cycle) are left out. Metatables are not copied.
-- Returns copy, number of values left out.
function Core.CopyData(value)
  local dropped = 0
  local onPath = {}
  local function copy(v)
    local kind = type(v)
    if kind == "string" or kind == "number" or kind == "boolean" then return v end
    if kind ~= "table" or onPath[v] then
      dropped = dropped + 1
      return nil
    end
    onPath[v] = true
    local out = {}
    for k, inner in next, v do
      local keyKind = type(k)
      if keyKind == "string" or keyKind == "number" or keyKind == "boolean" then
        local c = copy(inner)
        if c ~= nil then out[k] = c end
      else
        dropped = dropped + 1
      end
    end
    onPath[v] = nil
    return out
  end
  local result = copy(value)
  return result, dropped
end

-- Fills keys of `source` that are missing (raw nil) in `target`, recursing into
-- tables present on both sides. A target value that is not a table where the
-- source holds a table is left as it is and reported through `onConflict(path)`.
-- Returns the number of values written.
function Core.FillMissing(target, source, onConflict, path)
  local written = 0
  for k, v in pairs(source) do
    local here = path and (path .. "." .. tostring(k)) or tostring(k)
    local current = rawget(target, k)
    if current == nil then
      rawset(target, k, Core.CopyTable(v))
      written = written + 1
    elseif type(v) == "table" then
      if type(current) == "table" then
        written = written + Core.FillMissing(current, v, onConflict, here)
      elseif onConflict then
        onConflict(here)
      end
    end
  end
  return written
end

-- Status log ---------------------------------------------------------------

Core.status = {}

-- Appends {kind, subject, message} to the in-memory status list (newest last,
-- capped at STATUS_LIMIT). kind: "info" | "skip" | "conflict" | "error".
function Core:Log(kind, subject, message)
  local list = self.status
  tinsert(list, {kind = kind, subject = subject, message = message})
  while #list > self.STATUS_LIMIT do tremove(list, 1) end
end

-- Callbacks ----------------------------------------------------------------

local function report(err)
  local handler = type(geterrorhandler) == "function" and geterrorhandler()
  if handler then handler(err) end
end

-- A callback list keyed by owner (any value; one function per owner).
-- Fire calls every function in registration order; an error in one function is
-- passed to the client error handler and does not stop the others.
function Core.NewCallbackList()
  local list = {order = {}, fns = {}}

  function list:Register(owner, fn)
    if owner == nil or type(fn) ~= "function" then return false end
    if self.fns[owner] == nil then tinsert(self.order, owner) end
    self.fns[owner] = fn
    return true
  end

  function list:Unregister(owner)
    if self.fns[owner] == nil then return false end
    self.fns[owner] = nil
    for i, o in ipairs(self.order) do
      if o == owner then tremove(self.order, i) break end
    end
    return true
  end

  function list:Fire(...)
    local owners = {}
    for i, o in ipairs(self.order) do owners[i] = o end
    for _, o in ipairs(owners) do
      local fn = self.fns[o]
      if fn then
        local ok, err = pcall(fn, ...)
        if not ok then report(err) end
      end
    end
  end

  return list
end

-- Events -------------------------------------------------------------------

local handlers = {}
local eventFrame = CreateFrame("Frame")
Core.eventFrame = eventFrame

-- Adds `fn(event, ...)` to the handlers of `event`; handlers run in the order
-- they were added.
function Core:On(event, fn)
  local list = handlers[event]
  if not list then
    list = {}
    handlers[event] = list
    eventFrame:RegisterEvent(event)
  end
  tinsert(list, fn)
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
  local list = handlers[event]
  if not list then return end
  for _, fn in ipairs(list) do
    local ok, err = pcall(fn, event, ...)
    if not ok then report(err) end
  end
end)

-- Client state -------------------------------------------------------------

function Core.InCombat()
  return type(InCombatLockdown) == "function" and InCombatLockdown() and true or false
end

local IsAddOnLoadedFn = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded

function Core.IsLoadedInClient(folder)
  if not IsAddOnLoadedFn then return false end
  local loaded = IsAddOnLoadedFn(folder)
  return loaded and true or false
end

-- The AceDB-3.0 database object built on saved-variable table `sv` (a root
-- database, not a namespace), or nil when no AceDB:New has used `sv` yet.
function Core.FindAceDB(sv)
  if type(sv) ~= "table" or LibStub == nil then return nil end
  local ok, AceDB = pcall(LibStub, "AceDB-3.0", true)
  if not ok or type(AceDB) ~= "table" or type(AceDB.db_registry) ~= "table" then return nil end
  for db in pairs(AceDB.db_registry) do
    if type(db) == "table" and rawget(db, "sv") == sv and rawget(db, "parent") == nil then return db end
  end
  return nil
end

-- Player keys derived as AceDB-3.0 derives them (AceDB-3.0.lua, key setup):
--   regional unique names on: realm = ruleset name ("Hardcore", "RP-PvP",
--     "RP", "PvP", "PvE"), char = "<name> <surname>"
--   otherwise: realm = GetRealmName(), char = "<name> - <realm>"
-- class = class token, className = localized class name. Returns nil, reason
-- while the client has not reported the name parts (or lacks the game-rule API
-- the regional form needs).
local function rulesetRealm()
  local rules = C_GameRules
  local enum = Enum and Enum.GameRule
  if type(rules) ~= "table" or type(rules.IsGameRuleActive) ~= "function" or type(enum) ~= "table" then
    return nil
  end
  local function active(rule) return rule ~= nil and rules.IsGameRuleActive(rule) and true or false end
  local isRP, isPVP = active(enum.RPRuleset), active(enum.PvPRuleset)
  if active(enum.HardcoreRuleset) then return "Hardcore" end
  if isRP and isPVP then return "RP-PvP" end
  if isRP then return "RP" end
  if isPVP then return "PvP" end
  return "PvE"
end

function Core.PlayerKeys()
  local nameFn = UnitNameUnmodified or UnitName
  if not nameFn then return nil, "no UnitName API" end
  local char, realm
  if type(RegionalUniqueNamesEnabled) == "function" and RegionalUniqueNamesEnabled() then
    local name, surname = nameFn("player")
    realm = rulesetRealm()
    if not realm then return nil, "regional names on but the game-rule API is missing" end
    if type(name) ~= "string" or name == "" or type(surname) ~= "string" then
      return nil, "player name or surname not known yet"
    end
    char = name .. " " .. surname
  else
    local name = nameFn("player")
    realm = GetRealmName and GetRealmName()
    if type(name) ~= "string" or name == "" or type(realm) ~= "string" or realm == "" then
      return nil, "player name or realm not known yet"
    end
    char = name .. " - " .. realm
  end
  local className, classToken
  if UnitClass then className, classToken = UnitClass("player") end
  return {char = char, realm = realm, class = classToken, className = className}
end

-- Writes every key of `source` into `target`, replacing stored values; tables
-- on both sides are merged key by key, a stored non-table where `source` holds
-- a table is replaced. Keys of `target` that `source` lacks are kept.
-- Returns the number of values written.
function Core.WriteOver(target, source)
  local written = 0
  for k, v in pairs(source) do
    local current = rawget(target, k)
    if type(v) == "table" and type(current) == "table" then
      written = written + Core.WriteOver(current, v)
    else
      rawset(target, k, Core.CopyTable(v))
      written = written + 1
    end
  end
  return written
end

-- Saved variables ----------------------------------------------------------

-- DevilForever_CoreDB layout:
--   schema          number
--   defaults        {applied = {[folder] = {[targetKey] = version}},
--                    lateCreated = {[folder] = {[targetKey] = true}}}
--   theme           {active = setName}
--   edits           {[frameKey] = {[field] = value}}
--   preset          {active = presetName|nil, unfinished = presetName|nil,
--                    keptNotice = string|nil (last printed kept/skipped set),
--                    fragments = {[presetName] = {[targetKey] = fragment version}}}
-- A value of the wrong type is kept as it is on disk; the module then works on
-- a session-only table and the case is logged.
local DB_LAYOUT = {schema = Core.DB_SCHEMA, defaults = {applied = {}}, theme = {}, edits = {}, preset = {fragments = {}}}

local function initDB()
  local db = DevilForever_CoreDB
  if db == nil then
    db = {}
    DevilForever_CoreDB = db
  elseif type(db) ~= "table" then
    Core:Log("conflict", "DevilForever_CoreDB", "not a table; Core keeps its data for this session only")
    db = {}
  end
  Core.FillMissing(db, DB_LAYOUT,
    function(path) Core:Log("conflict", "DevilForever_CoreDB", path .. " is not a table; session-only table used") end)
  Core.db = db
end

local sessionOnly = {}

-- Returns the table at DevilForever_CoreDB[a][b]... (path of keys), or a
-- session-only table when some step is not a table.
function Core:DBTable(...)
  local t = self.db
  local key = table.concat({...}, ".")
  for i = 1, select("#", ...) do
    local k = select(i, ...)
    local nextT
    if type(t) == "table" then nextT = rawget(t, k) end
    if type(t) == "table" and nextT == nil then
      nextT = {}
      rawset(t, k, nextT)
    end
    if type(nextT) ~= "table" then
      sessionOnly[key] = sessionOnly[key] or {}
      return sessionOnly[key]
    end
    t = nextT
  end
  return t
end

Core.ready = false
Core.readyCallbacks = Core.NewCallbackList()

Core:On("ADDON_LOADED", function(_, loaded)
  if loaded ~= addonName or Core.ready then return end
  initDB()
  Core.ready = true
  Core.readyCallbacks:Fire(Core.db)
end)

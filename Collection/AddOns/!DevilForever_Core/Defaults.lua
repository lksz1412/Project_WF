-- Defaults injection for registered addons.
--
-- A defaults file (listed in the Core TOC after this file and named as the
-- folder's `defaults` in the registry) calls
--   DevilForever_Core.Defaults:Register(folder, {
--     version = 1,                        -- integer >= 1
--     targets = {
--       {savedVariable = "SomeDB", shape = "plain", values = {...},
--        createIfMissing = false},        -- plain table saved variable
--       {savedVariable = "OtherDB", shape = "acedb", values = {...},
--        profile = "$char", namespace = nil},  -- AceDB-3.0 saved variable
--     },
--   })
-- Register is refused (and logged) when the registry has no entry for
-- `folder`, the entry names no defaults file, or a target's saved variable is
-- not one of the entry's savedVariables. The scope of each saved variable
-- (account or character) comes from that registry entry.
--
-- Plain targets. A target is "fresh" when its saved variable is nil the first
-- time Core looks at it in a session (normally the target addon's
-- ADDON_LOADED), i.e. the addon's first load; nothing there is the user's.
--   fresh, addon loaded before the session's first PLAYER_ENTERING_WORLD:
--              at that PLAYER_ENTERING_WORLD the spec values are written over
--              what the addon created during this session (an addon that
--              fills its own defaults at init would otherwise hide every key);
--              some addons read them only after the next /reload.
--   fresh, first seen after the first PLAYER_ENTERING_WORLD (load on demand,
--              mid-session): missing keys only, never written over; in the
--              same frame other code (restore, import) may already have
--              written values that cannot be told from the addon's own. When
--              the saved variable is still nil, the next PLAYER_ENTERING_WORLD
--              settles it.
--   fresh, saved variable still nil when it settles: state
--              "late-created" (the addon creates it later; its defaults need an
--              addon-specific path), nothing written or recorded, a marker kept
--              in DevilForever_CoreDB.defaults.lateCreated; with
--              createIfMissing the table is created and written instead.
--   not fresh  only keys missing (raw nil) are filled; stored values are kept.
--              Status carries lateCreated = true when the marker exists.
-- Suppress(folder[, reason]) stops all further work on `folder` for this
-- session (a pending login-window write included); code that restores or
-- imports an addon's saved variables calls it before writing them.
-- Assumptions this rests on (to be confirmed in the client): Core loads before
-- the other addons (its folder name starts with "!"), and within one
-- ADDON_LOADED event Core's handler runs before the target addon's own.

-- AceDB targets fill <SV>.profiles[<profile>] (or
-- <SV>.namespaces[<namespace>].profiles[<profile>]) with missing keys only;
-- AceDB keeps its own defaults in metatables, so raw keys are the user's. The
-- profile is the one <SV>.profileKeys names for this character; when it names
-- none, `profile` decides, as the addon's AceDB:New defaultProfile would:
-- "$char" (default; the AceDB character key), "$class" (class token),
-- "$className" (localized class name), "$realm" (AceDB realm key), or a
-- literal name. Missing AceDB tables are created; profileKeys is left to AceDB.
--
-- Every target is written once per version: the version is recorded in
-- DevilForever_CoreDB.defaults.applied[folder][targetKey]; a higher version
-- runs again with missing-keys-only filling. Stored values are never replaced
-- in a later session. targetKey:
--   plain, account scope      "<SV>"
--   plain, character scope    "<SV>@char:<character key>"
--   acedb, account scope      "<SV>[/<namespace>]@profile:<profile>"
--   acedb, character scope    "<SV>[/<namespace>]@char:<character key>@profile:<profile>"
-- A saved variable or AceDB table of the wrong type skips the target; a stored
-- value that is not a table where the defaults hold a table keeps the stored
-- value when filling. Skips and conflicts go to the status log and GetStatus.
-- The addon itself is never called.

local _, Core = ...

local type, pairs, ipairs, tostring, floor = type, pairs, ipairs, tostring, math.floor

local Defaults = {}
Core.Defaults = Defaults

local specs = {}        -- [lower folder] = {folder, version, targets}
local status = {}       -- [lower folder] = {folder, targets = {[label] = {...}}}
local settled = {}      -- [lower folder] = {[target index] = true} for this session
local fresh = {}        -- [lower folder] = {[target index] = {fresh, due}} for this session
local suppressed = {}   -- [lower folder] = reason, for this session
local worldSeen = false -- the session's first PLAYER_ENTERING_WORLD has run

local SHAPES = {plain = true, acedb = true}

local function validSpec(folder, spec)
  if type(folder) ~= "string" or folder == "" then return "folder must be a non-empty string" end
  if type(spec) ~= "table" then return "spec must be a table" end
  local v = spec.version
  if type(v) ~= "number" or v < 1 or floor(v) ~= v then return "version must be an integer >= 1" end
  if type(spec.targets) ~= "table" or #spec.targets == 0 then return "targets must be a non-empty list" end
  for i, t in ipairs(spec.targets) do
    if type(t) ~= "table" then return "target " .. i .. " is not a table" end
    if type(t.savedVariable) ~= "string" or t.savedVariable == "" then return "target " .. i .. " savedVariable" end
    if not SHAPES[t.shape] then return "target " .. i .. " shape must be plain or acedb" end
    if type(t.values) ~= "table" then return "target " .. i .. " values must be a table" end
    if t.profile ~= nil and (type(t.profile) ~= "string" or t.profile == "") then return "target " .. i .. " profile" end
    if t.namespace ~= nil and (type(t.namespace) ~= "string" or t.namespace == "") then return "target " .. i .. " namespace" end
  end
end

local function registryEntry(folder)
  local registry = Core.Registry
  local addons = type(registry) == "table" and type(registry.addons) == "table" and registry.addons
  if not addons then return nil end
  if addons[folder] then return folder, addons[folder] end
  local lower = folder:lower()
  for name, e in pairs(addons) do
    if name:lower() == lower then return name, e end
  end
end

-- Registers the defaults of `folder`. Returns true, or false, reason. A second
-- call for the same folder replaces the first.
function Defaults:Register(folder, spec)
  local err = validSpec(folder, spec)
  local name, entry
  if not err then
    name, entry = registryEntry(folder)
    if not entry then
      err = "folder is not in the registry"
    elseif type(entry.defaults) ~= "string" then
      err = "the registry names no defaults file for this folder"
    end
  end
  local targets
  if not err then
    local scopes = {}
    for _, sv in ipairs(entry.savedVariables or {}) do scopes[sv.name] = sv.scope end
    targets = Core.CopyTable(spec.targets)
    for i, t in ipairs(targets) do
      t.scope = scopes[t.savedVariable]
      if not t.scope then
        err = "target " .. i .. " saved variable " .. t.savedVariable .. " is not registered for this folder"
        break
      end
    end
  end
  if err then
    Core:Log("error", "Defaults:" .. tostring(folder), err)
    return false, err
  end
  local key = name:lower()
  if specs[key] then Core:Log("info", "Defaults:" .. name, "registered again; previous spec replaced") end
  specs[key] = {folder = name, version = spec.version, targets = targets}
  settled[key] = {}
  fresh[key] = {}
  status[key] = {folder = name, targets = {}}
  return true
end

local function resolveProfile(token, keys)
  if token == nil or token == "$char" then return keys.char end
  if token == "$class" then return keys.class end
  if token == "$className" then return keys.className end
  if token == "$realm" then return keys.realm end
  return token
end

-- Returns a table at parent[k], creating it when nil; nil, reason when the
-- value there is not a table.
local function subTable(parent, k, label)
  local t = rawget(parent, k)
  if t == nil then
    t = {}
    rawset(parent, k, t)
  elseif type(t) ~= "table" then
    return nil, label .. " is not a table"
  end
  return t
end

-- Target key of a plain target, or nil, reason while the player key is unknown.
local function plainKey(target)
  if target.scope ~= "character" then return target.savedVariable end
  local keys, why = Core.PlayerKeys()
  if not keys then return nil, why end
  return target.savedVariable .. "@char:" .. keys.char
end

-- Plain target: returns {table, key} | "wait", reason | nil, reason.
-- `create` makes a missing saved variable.
local function locatePlain(target, create, final)
  local svName = target.savedVariable
  local key, why = plainKey(target)
  if not key then return "wait", "player key unavailable: " .. tostring(why) end
  local sv = _G[svName]
  if sv == nil then
    if not create then
      if final then return nil, "saved variable " .. svName .. " not present" end
      return "wait", "saved variable " .. svName .. " not present yet"
    end
    sv = {}
    _G[svName] = sv
  elseif type(sv) ~= "table" then
    return nil, "saved variable " .. svName .. " is not a table"
  end
  return {sv, key}
end

local function locateAce(target)
  local svName = target.savedVariable
  local keys, why = Core.PlayerKeys()
  if not keys then return "wait", "player key unavailable: " .. tostring(why) end
  local sv = _G[svName]
  if sv == nil then
    sv = {}
    _G[svName] = sv
  elseif type(sv) ~= "table" then
    return nil, "saved variable " .. svName .. " is not a table"
  end
  local profileKeys = rawget(sv, "profileKeys")
  local chosen = type(profileKeys) == "table" and profileKeys[keys.char]
  local profile = (type(chosen) == "string" and chosen ~= "") and chosen or resolveProfile(target.profile, keys)
  if type(profile) ~= "string" or profile == "" then return nil, "profile name could not be resolved" end
  local root, err = sv, nil
  if target.namespace then
    local spaces
    spaces, err = subTable(sv, "namespaces", svName .. ".namespaces")
    if not spaces then return nil, err end
    root, err = subTable(spaces, target.namespace, svName .. ".namespaces." .. target.namespace)
    if not root then return nil, err end
  end
  local where = svName .. (target.namespace and ("/" .. target.namespace) or "")
  local profiles
  profiles, err = subTable(root, "profiles", where .. ".profiles")
  if not profiles then return nil, err end
  local tbl
  tbl, err = subTable(profiles, profile, where .. ".profiles." .. profile)
  if not tbl then return nil, err end
  local charPart = target.scope == "character" and ("@char:" .. keys.char) or ""
  return {tbl, where .. charPart .. "@profile:" .. profile}
end

-- First-look state of a plain target: {fresh = bool, due = "world" | nil}.
-- due = "world": fresh during the login window, written over at the first
-- PLAYER_ENTERING_WORLD; otherwise missing keys only.
local function firstLook(target)
  local info = {fresh = (_G[target.savedVariable] == nil)}
  if info.fresh and not worldSeen then info.due = "world" end
  return info
end

local function marker(folder, targetKey)
  local root = Core:DBTable("defaults", "lateCreated")
  local byFolder = rawget(root, folder)
  return type(byFolder) == "table" and byFolder[targetKey] == true
end

-- phase: "load" (ADDON_LOADED, Core ready, PLAYER_LOGIN) or "world"
-- (PLAYER_ENTERING_WORLD).
local function attempt(lowerFolder, phase)
  local spec = specs[lowerFolder]
  if not spec or suppressed[lowerFolder] or not Core.ready or not Core.IsLoadedInClient(spec.folder) then return end
  local appliedRoot = Core:DBTable("defaults", "applied")
  local applied = rawget(appliedRoot, spec.folder)
  if type(applied) ~= "table" then applied = nil end
  local st = status[lowerFolder]
  local done = settled[lowerFolder]
  local looks = fresh[lowerFolder]
  for i, target in ipairs(spec.targets) do
    if not done[i] then
      local label = target.savedVariable .. (target.namespace and ("/" .. target.namespace) or "")
      local place, reason, info
      if target.shape == "plain" then
        info = looks[i]
        if info == nil then
          info = firstLook(target)
          looks[i] = info
        end
        local final = phase == "world"
        if info.due == "world" and not final then
          place, reason = "wait", "first load: written at the first PLAYER_ENTERING_WORLD"
        else
          place, reason = locatePlain(target, info.fresh and target.createIfMissing, final)
        end
      else
        place, reason = locateAce(target)
      end
      if place == "wait" then
        if not (st.targets[label] and st.targets[label].message == reason) then
          Core:Log("info", spec.folder, label .. " waiting: " .. reason)
        end
        st.targets[label] = {state = "waiting", message = reason}
      elseif place == nil and info and info.fresh and _G[target.savedVariable] == nil then
        done[i] = true
        local key = plainKey(target)
        if key then Core:DBTable("defaults", "lateCreated", spec.folder)[key] = true end
        reason = "addon creates its saved variable later; defaults need an addon-specific path"
        st.targets[label] = {state = "late-created", key = key, message = reason}
        Core:Log("skip", spec.folder, label .. ": " .. reason)
      elseif place == nil then
        done[i] = true
        st.targets[label] = {state = "skipped", message = reason}
        Core:Log("skip", spec.folder, reason)
      else
        done[i] = true
        local tbl, targetKey = place[1], place[2]
        local recorded = applied and applied[targetKey]
        local late = marker(spec.folder, targetKey) or nil
        if type(recorded) == "number" and recorded >= spec.version then
          st.targets[label] = {state = "already", key = targetKey, version = recorded, lateCreated = late}
        else
          local conflicts, written, mode, message = {}, 0, "fill-missing", nil
          if info and info.due == "world" and recorded == nil then
            mode = "first-load"
            message = "written over this session's addon values; some addons use them after /reload"
            written = Core.WriteOver(tbl, target.values)
          else
            written = Core.FillMissing(tbl, target.values, function(path)
              conflicts[#conflicts + 1] = path
              Core:Log("conflict", spec.folder, targetKey .. ": " .. path .. " kept (stored value is not a table)")
            end)
          end
          if not applied then applied = Core:DBTable("defaults", "applied", spec.folder) end
          applied[targetKey] = spec.version
          st.targets[label] = {state = "applied", mode = mode, key = targetKey, version = spec.version,
                               written = written, conflicts = conflicts, message = message, lateCreated = late}
        end
      end
    end
  end
end

local function attemptAll(phase)
  for key in pairs(specs) do attempt(key, phase) end
end

Core.readyCallbacks:Register(Defaults, function() attemptAll("load") end)

Core:On("ADDON_LOADED", function(_, loaded)
  if type(loaded) == "string" and specs[loaded:lower()] then attempt(loaded:lower(), "load") end
end)

Core:On("PLAYER_LOGIN", function() attemptAll("load") end)

-- Every PLAYER_ENTERING_WORLD settles waiting plain targets; the first one
-- also ends the login window.
Core:On("PLAYER_ENTERING_WORLD", function()
  attemptAll("world")
  worldSeen = true
end)

-- Status of `folder` ({folder, registered, loaded, version, targets = {[label]
-- = {state = "waiting"|"skipped"|"late-created"|"suppressed"|"already"|
-- "applied", mode = "first-load"|"fill-missing", lateCreated, ...}},
-- suppressed = reason|nil}), or of every registered folder when `folder` is
-- nil ({[folder] = status}).
function Defaults:GetStatus(folder)
  local function one(key)
    local spec = specs[key]
    if not spec then return {folder = folder, registered = false, loaded = Core.IsLoadedInClient(folder), targets = {}} end
    local st = Core.CopyTable(status[key])
    st.registered = true
    st.version = spec.version
    st.loaded = Core.IsLoadedInClient(spec.folder)
    st.suppressed = suppressed[key]
    return st
  end
  if folder ~= nil then return one(tostring(folder):lower()) end
  local all = {}
  for key, spec in pairs(specs) do all[spec.folder] = one(key) end
  return all
end

-- Stops defaults work on `folder` for the rest of this session: targets not yet
-- settled are left untouched (a pending login-window write included) and get
-- state "suppressed"; settled ones keep their state. Logged. Returns true, or
-- false, reason for a bad folder argument.
function Defaults:Suppress(folder, reason)
  if type(folder) ~= "string" or folder == "" then return false, "folder must be a non-empty string" end
  local key = folder:lower()
  reason = type(reason) == "string" and reason ~= "" and reason or "suppressed by caller"
  suppressed[key] = reason
  Core:Log("info", "Defaults:" .. folder, "suppressed for this session: " .. reason)
  local spec = specs[key]
  if spec then
    local done, st = settled[key], status[key]
    for i, target in ipairs(spec.targets) do
      if not done[i] then
        done[i] = true
        local label = target.savedVariable .. (target.namespace and ("/" .. target.namespace) or "")
        st.targets[label] = {state = "suppressed", message = reason}
      end
    end
  end
  return true
end

-- Sorted list of folders with registered defaults.
function Defaults:ListRegistered()
  local out = {}
  for _, spec in pairs(specs) do out[#out + 1] = spec.folder end
  table.sort(out)
  return out
end

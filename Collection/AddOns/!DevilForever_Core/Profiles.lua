-- Settings snapshots of registered saved variables, saved and restored at load
-- time.
--
-- Scope: only saved variables the registry marks with restore = "whole",
-- "keys" or "profile" (Core:GetSavedVariables); Core's own saved variables are
-- never targets. Core's layout part (DevilForever_CoreDB edits, theme.active,
-- preset.active) travels with the common part.
--   whole    the saved variable is copied and written back as a whole
--   keys     only the registry-listed top-level keys are copied; a restore
--            writes the saved keys the registry still lists
--   profile  (split = "class", AceDB) the profiles this character uses: the
--            profileKeys profile and the LibDualSpec group profiles, with
--            their namespace profiles, this character's profileKeys entry and
--            LibDualSpec entry; stored per class token. A saved profile name
--            that another character uses (its profileKeys or LibDualSpec
--            entry) is never written: the values go to a free name (this
--            character's key, then "<key> (2)", …) and this character's
--            entries point there; each rename is reported.
--
-- Two phases. A command stores a request in DevilForever_ProfilesDB.pending
-- {action = "save"|"restore"|"preset", name, parts, only, char, keys,
-- requestedAt, armed, armedAt}; /dfp go arms it and reloads. A request not
-- armed is kept and not used. At the next load, at Core's ready step an armed
-- request is taken (and removed): it is used only on the same character within
-- PENDING_MAX_AGE seconds of /dfp go. When the player key is not known yet,
-- a restore or preset request armed at most KEY_FALLBACK_AGE seconds ago
-- writes only account-scope common entries (character-scope saved variables,
-- the class part and character-dependent preset fragments are skipped and
-- reported); its "__before-restore" is labelled savedBy.char = "unknown";
-- the character is checked at PLAYER_LOGIN. A save request is dropped. An
-- un-armed request is reported only to the requesting character and does
-- not replace DevilForever_ProfilesDB.last. Each target is read or written at
-- its addon's ADDON_LOADED, before the addon's own handler (Core loads first;
-- this handler runs before Defaults'). The job ends at the first
-- PLAYER_ENTERING_WORLD with a report (printed, kept in
-- DevilForever_ProfilesDB.last).
--   save     copies the disk state into the named snapshot. Entries of the
--            old snapshot of that name that were not read now are kept with
--            carried = true; nothing is dropped.
--   restore  per target: an entry saved on another character (character
--            scope) or for another class token, an addon not loaded, an addon
--            whose AceDB already opened its saved variable, a version other
--            than the saved one, an entry or saved variable of the wrong type
--            -> untouched and reported. Defaults:Suppress is called for every
--            folder that passed these checks at the ready step. A saved
--            variable written by the restore no longer counts as fresh
--            (WasFresh false). Before a write the current disk state goes into
--            the "__before-restore" snapshot (kept only when something was
--            written; it replaces the previous one, except that a restore from
--            "__before-restore" itself keeps the slot's entries it did not
--            write, carried = true).
--
-- DevilForever_ProfilesDB = {schema, snapshots = {[name] = snapshot}, pending, last}
--   snapshot = {name, schema, savedAt, savedBy = {char, realm, class, group},
--     core = {edits, theme, preset} | nil,
--     common = {[svName] = {folder, scope, restore, keys, char, version,
--       registryVersion, savedAt, carried, dropped, absent, data}},
--     class = {[classToken] = {[svName] = {folder, version, registryVersion,
--       savedAt, carried, dropped, char, profileKey, profileNames, profiles,
--       namespaces = {[ns] = {[profile] = data}}, lds}}}}
-- A store or snapshot whose schema is unknown (or of the wrong type) is never
-- written, reset or deleted; the module reports it as read-only.

local _, Core = ...

local type, pairs, ipairs, tostring, tonumber, sort = type, pairs, ipairs, tostring, tonumber, table.sort
local floor, pcall = math.floor, pcall

local Profiles = {}
Core.Profiles = Profiles

Profiles.SCHEMA = 1
Profiles.MAX_SNAPSHOTS = 10
Profiles.UNDO = "__before-restore"
Profiles.PENDING_MAX_AGE = 600
Profiles.KEY_FALLBACK_AGE = 120
Profiles.NAME_MAX = 48

local LDS_NAMESPACE = "LibDualSpec-1.0"
local RESTORE_KINDS = {whole = true, keys = true, profile = true}
local PARTS = {all = true, common = true, class = true}

local store          -- DevilForever_ProfilesDB when usable
local readOnly       -- reason string when the store must not be written
local job            -- load-time job of this session
local presetRequest  -- validated "preset" request for Presets.lua
local loadLines = {} -- report lines of the ready step, printed at the first world entry
local noticeLines = {} -- printed at the first world entry, not kept in DevilForever_ProfilesDB.last
local freshAtLoad = {}  -- [svName] = true when nil at its addon's ADDON_LOADED (this handler);
                        -- false once this session's restore job wrote it
local watchedKeys = {}  -- [svName] = {[key] = true}: root keys whose absence is recorded at load
local absentAtLoad = {} -- [svName] = {[key] = true when <SV>[key] was nil at that ADDON_LOADED}
local verifyChar        -- requesting character key to check at PLAYER_LOGIN (key was unknown at load)
local worldSeen = false

-- Helpers ------------------------------------------------------------------------

local function now() return type(time) == "function" and time() or 0 end

function Profiles:Print(line)
  if type(print) == "function" then print("[DF 설정] " .. tostring(line)) end
end

local function printLines(lines)
  for _, line in ipairs(lines) do Profiles:Print(line) end
end

local function trim(text)
  return (tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function snapshotProblem(snap)
  if type(snap) ~= "table" then return "형식이 표가 아님" end
  local v = rawget(snap, "schema")
  if type(v) ~= "number" or v < 1 or v > Profiles.SCHEMA or floor(v) ~= v then
    return "알 수 없는 판(schema " .. tostring(v) .. ")"
  end
end

local function metadataVersion(folder)
  local fn = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  if type(fn) ~= "function" then return nil end
  local ok, v = pcall(fn, folder, "Version")
  if ok and type(v) == "string" and v ~= "" then return v end
  return nil
end

local function registryVersion(folder)
  local info = Core:GetAddonInfo(folder)
  local v = info and info.version
  return type(v) == "string" and v ~= "" and v or nil
end

-- Compares the saved versions of an entry with the installed addon: the
-- metadata Version when both sides have it, else the registry version.
-- Returns true | false, message.
local function versionMatches(entry, folder)
  local meta, reg = metadataVersion(folder), registryVersion(folder)
  if entry.version ~= nil and meta ~= nil then
    if entry.version ~= meta then return false, "저장 판 " .. tostring(entry.version) .. ", 설치 판 " .. meta end
    return true
  end
  if entry.registryVersion ~= nil and reg ~= nil then
    if entry.registryVersion ~= reg then
      return false, "저장 판 " .. tostring(entry.registryVersion) .. ", 설치 판 " .. reg
    end
    return true
  end
  return true, "판 정보 없음"
end

local function currentGroup()
  if LibStub == nil then return 0 end
  local ok, lds = pcall(LibStub, "LibDualSpec-1.0", true)
  local spec = ok and type(lds) == "table" and tonumber(lds.currentSpec) or 0
  return spec or 0
end

local function subTable(parent, key)
  local t = rawget(parent, key)
  if t == nil then
    t = {}
    rawset(parent, key, t)
  elseif type(t) ~= "table" then
    return nil
  end
  return t
end

-- Registry targets: {[svName] = {folder, name, scope, split, restore, shape, keys}}
local function registryTargets()
  local out = {}
  for _, sv in ipairs(Core:GetSavedVariables()) do
    if sv.folder ~= Core.name and RESTORE_KINDS[sv.restore] then out[sv.name] = sv end
  end
  return out
end

local function userSnapshotCount()
  local n = 0
  for name in pairs(store.snapshots) do
    if name ~= Profiles.UNDO then n = n + 1 end
  end
  return n
end

-- Store ---------------------------------------------------------------------------

local function initStore()
  local db = DevilForever_ProfilesDB
  if db == nil then
    db = {schema = Profiles.SCHEMA, snapshots = {}}
    DevilForever_ProfilesDB = db
  elseif type(db) ~= "table" then
    readOnly = "DevilForever_ProfilesDB 형식이 표가 아님 — 그대로 둠"
    Core:Log("conflict", "Profiles", readOnly)
    return
  end
  local schema = rawget(db, "schema")
  if schema == nil and next(db) == nil then
    db.schema = Profiles.SCHEMA
    schema = Profiles.SCHEMA
  end
  if type(schema) ~= "number" or schema < 1 or schema > Profiles.SCHEMA or floor(schema) ~= schema then
    readOnly = "DevilForever_ProfilesDB 의 판(schema " .. tostring(schema) .. ")을 모름 — 읽기만 함"
    Core:Log("conflict", "Profiles", readOnly)
    return
  end
  local snaps = rawget(db, "snapshots")
  if snaps == nil then
    db.snapshots = {}
  elseif type(snaps) ~= "table" then
    readOnly = "DevilForever_ProfilesDB.snapshots 형식이 표가 아님 — 읽기만 함"
    Core:Log("conflict", "Profiles", readOnly)
    return
  end
  store = db
end

local function writable()
  if not Core.ready then return false, "Core 저장 변수를 아직 읽지 않음" end
  if readOnly then return false, readOnly end
  if not store then return false, "저장소 없음" end
  return true
end

-- Requests -------------------------------------------------------------------------

-- Checks that a new request can be stored: store writable, out of combat,
-- nothing pending, player key known. Returns keys | nil, reason.
function Profiles:CanRequest()
  if Core.InCombat() then return nil, "전투 중 — 바꾼 것 없음" end
  local ok, why = writable()
  if not ok then return nil, why end
  if type(store.pending) == "table" then
    return nil, "이미 기다리는 요청이 있음(" .. tostring(store.pending.action) .. " " .. tostring(store.pending.name)
      .. ") — /dfp go 또는 /dfp cancel"
  end
  local keys, reason = Core.PlayerKeys()
  if not keys then return nil, "캐릭터 이름을 아직 모름: " .. tostring(reason) end
  return keys
end

-- Stores a request {action, name, parts, only} with the requesting player's
-- keys; it is not used until /dfp go arms it. Returns true | false, reason.
function Profiles:SetPending(request)
  local keys, why = self:CanRequest()
  if not keys then return false, why end
  local p = Core.CopyTable(request)
  p.char = keys.char
  p.keys = {char = keys.char, realm = keys.realm, class = keys.class, className = keys.className}
  p.requestedAt = now()
  p.armed = false
  store.pending = p
  return true
end

local function validName(name)
  name = trim(name)
  if name == "" then return nil, "이름이 비어 있음" end
  if #name > Profiles.NAME_MAX then return nil, "이름이 너무 김(" .. Profiles.NAME_MAX .. "바이트까지)" end
  if name:sub(1, 2) == "__" then return nil, "__ 로 시작하는 이름은 쓸 수 없음" end
  if name:find("%s") then return nil, "이름에 빈칸을 쓸 수 없음" end
  return name
end

local function partsFor(part)
  part = part or "all"
  if not PARTS[part] then return nil end
  return {common = part ~= "class", class = part ~= "common", label = part}
end

-- Returns true, lines | false, reason. The save happens at the next load.
function Profiles:RequestSave(name)
  local clean, why = validName(name)
  if not clean then return false, why end
  local keys, reason = self:CanRequest()
  if not keys then return false, reason end
  local old = store.snapshots[clean]
  if old ~= nil then
    local problem = snapshotProblem(old)
    if problem then return false, clean .. ": " .. problem .. " — 덮어쓰지 않음" end
  elseif userSnapshotCount() >= self.MAX_SNAPSHOTS then
    return false, "저장본이 이미 " .. self.MAX_SNAPSHOTS .. "개 — /dfp delete 로 하나 지운 뒤 다시"
  end
  local ok, err = self:SetPending({action = "save", name = clean})
  if not ok then return false, err end
  local lines = {clean .. " 저장 예약 — /dfp go 로 다시 불러온 뒤 저장한다"}
  for svName, t in pairs(registryTargets()) do
    lines[#lines + 1] = "  " .. t.folder .. " " .. svName .. " (" .. t.restore .. ")"
  end
  if old then lines[#lines + 1] = "  같은 이름의 저장본에 합친다(이번에 못 읽은 항목은 남긴다)" end
  return true, lines
end

-- part: "all" (default) | "common" | "class"; only: folder name or nil.
function Profiles:RequestRestore(name, part, only)
  if type(name) ~= "string" or name == "" then return false, "이름이 비어 있음" end
  local parts = partsFor(part)
  if not parts then return false, "부분은 all, common, class 중 하나" end
  local ok0, why0 = writable()
  if not ok0 then return false, why0 end
  local snap = store.snapshots[name]
  if snap == nil then return false, name .. ": 저장본 없음" end
  local problem = snapshotProblem(snap)
  if problem then return false, name .. ": " .. problem .. " — 건드리지 않음" end
  if only ~= nil then
    if type(only) ~= "string" or only == "" then return false, "only 뒤에 폴더 이름" end
    local known = Core:GetAddonInfo(only) or only:lower() == Core.name:lower()
    if not known then return false, only .. ": 등록 표에 없는 폴더" end
  end
  local ok, err = self:SetPending({action = "restore", name = name, parts = parts, only = only})
  if not ok then return false, err end
  local lines = {name .. " 되돌리기 예약(" .. parts.label .. (only and (", " .. only .. " 만") or "") .. ") — /dfp go"}
  for _, line in ipairs(self:Describe(name, part, only)) do lines[#lines + 1] = line end
  return true, lines
end

function Profiles:Cancel()
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  local ok, why = writable()
  if not ok then return false, why end
  if store.pending == nil then return false, "기다리는 요청 없음" end
  local p = store.pending
  store.pending = nil
  if type(p) == "table" and p.action == "preset" then
    local db = Core:DBTable("preset")
    if db.unfinished == p.name then db.unfinished = nil end
  end
  return true
end

function Profiles:Go()
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  if not store or type(store.pending) ~= "table" then return false, "기다리는 요청 없음" end
  if type(ReloadUI) ~= "function" then return false, "ReloadUI 없음" end
  store.pending.armed = true
  store.pending.armedAt = now()
  ReloadUI()
  return true
end

-- Deletes a user snapshot; `confirm` must be "yes".
function Profiles:Delete(name, confirm)
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  local ok, why = writable()
  if not ok then return false, why end
  local snap = store.snapshots[name]
  if snap == nil then return false, tostring(name) .. ": 저장본 없음" end
  local problem = snapshotProblem(snap)
  if problem then return false, name .. ": " .. problem .. " — 지우지 않음" end
  if confirm ~= "yes" then return false, "지우려면 /dfp delete " .. name .. " yes" end
  store.snapshots[name] = nil
  return true
end

-- Reading --------------------------------------------------------------------------

local function estimateBytes(value, seen)
  seen = seen or {}
  local kind = type(value)
  if kind == "string" then return #value + 3 end
  if kind ~= "table" then return 8 end
  if seen[value] then return 0 end
  seen[value] = true
  local n = 4
  for k, v in pairs(value) do n = n + estimateBytes(k, seen) + estimateBytes(v, seen) + 4 end
  return n
end

local function entryCounts(snap)
  local entries, carried = 0, 0
  for _, e in pairs(type(snap.common) == "table" and snap.common or {}) do
    entries = entries + 1
    if type(e) == "table" and e.carried then carried = carried + 1 end
  end
  for _, byName in pairs(type(snap.class) == "table" and snap.class or {}) do
    for _, e in pairs(type(byName) == "table" and byName or {}) do
      entries = entries + 1
      if type(e) == "table" and e.carried then carried = carried + 1 end
    end
  end
  return entries, carried
end

-- Sorted list of {name, savedAt, char, class, entries, carried, bytes, problem}.
function Profiles:List()
  local out = {}
  if not store then return out end
  for name, snap in pairs(store.snapshots) do
    local row = {name = name, problem = snapshotProblem(snap), bytes = estimateBytes(snap)}
    if not row.problem then
      row.savedAt = snap.savedAt
      local by = type(snap.savedBy) == "table" and snap.savedBy or {}
      row.char, row.class = by.char, by.class
      row.entries, row.carried = entryCounts(snap)
    end
    out[#out + 1] = row
  end
  sort(out, function(a, b) return tostring(a.name) < tostring(b.name) end)
  return out
end

function Profiles:GetStatus()
  return {readOnly = readOnly, pending = store and Core.CopyTable(store.pending) or nil,
          last = store and Core.CopyTable(store.last) or nil, maxSnapshots = self.MAX_SNAPSHOTS,
          snapshots = store and userSnapshotCount() or 0}
end

-- Dry run of a restore: one line per entry with what would happen.
function Profiles:Describe(name, part, only)
  local lines = {}
  if not store then return {readOnly or "저장소 없음"} end
  local snap = store.snapshots[name]
  if snap == nil then return {tostring(name) .. ": 저장본 없음"} end
  local problem = snapshotProblem(snap)
  if problem then return {name .. ": " .. problem .. " — 읽기만 함"} end
  local parts = partsFor(part) or partsFor("all")
  local keys = Core.PlayerKeys() or {}
  local targets = registryTargets()
  local onlyLower = type(only) == "string" and only:lower() or nil
  local function wanted(folder) return not onlyLower or tostring(folder):lower() == onlyLower end
  local function describe(svName, e, partName, kind)
    local folder = tostring(e.folder)
    local reg = targets[svName]
    local state
    if not reg or reg.restore ~= kind then
      state = "건너뜀: 등록 표에서 " .. kind .. " 대상이 아님"
    elseif not Core:IsAddonLoaded(folder) then
      state = "건너뜀: 애드온이 켜져 있지 않음(저장본 항목은 남김)"
    elseif kind ~= "profile" and e.restore == nil then
      state = "건너뜀: 항목 형식이 맞지 않음"
    elseif reg.scope == "character" and e.char ~= keys.char then
      state = "건너뜀: 다른 캐릭터(" .. tostring(e.char) .. ")의 값"
    else
      local okVersion, msg = versionMatches(e, folder)
      if not okVersion then state = "건너뜀: " .. msg else state = "씀" .. (msg and (" (" .. msg .. ")") or "") end
    end
    lines[#lines + 1] = "  " .. partName .. " " .. folder .. " " .. svName .. " — " .. state
  end
  if parts.common then
    if type(snap.core) == "table" and wanted(Core.name) then
      lines[#lines + 1] = "  common " .. Core.name .. " 편집값·테마·preset — 씀"
    end
    for svName, e in pairs(type(snap.common) == "table" and snap.common or {}) do
      if type(e) == "table" and wanted(e.folder) then describe(svName, e, "common", e.restore) end
    end
  end
  if parts.class then
    for token, byName in pairs(type(snap.class) == "table" and snap.class or {}) do
      for svName, e in pairs(type(byName) == "table" and byName or {}) do
        if type(e) == "table" and wanted(e.folder) then
          if token ~= keys.class then
            lines[#lines + 1] = "  class " .. tostring(e.folder) .. " " .. svName .. " — 건너뜀: " .. token .. " 직업의 값"
          else
            describe(svName, e, "class", "profile")
          end
        end
      end
    end
  end
  sort(lines)
  return lines
end

-- Capture ---------------------------------------------------------------------------

local function newEntryBase(target)
  return {folder = target.folder, version = metadataVersion(target.folder),
          registryVersion = registryVersion(target.folder), savedAt = now()}
end

-- Common entry from the current value of the saved variable; nil, reason when
-- the value is not a table (an absent value is kept as absent = true only when
-- `allowAbsent`).
local function captureCommon(target, keys, allowAbsent)
  local current = _G[target.name]
  if current ~= nil and type(current) ~= "table" then return nil, "저장 변수 형식이 표가 아님" end
  if current == nil and not allowAbsent then return nil, "저장된 값이 아직 없음" end
  local e = newEntryBase(target)
  e.scope, e.restore = target.scope, target.restore
  if target.scope == "character" then e.char = keys.char end
  if target.restore == "keys" then e.keys = Core.CopyTable(target.keys) end
  if current == nil then
    e.absent = true
    return e
  end
  local dropped = 0
  if target.restore == "whole" then
    e.data, dropped = Core.CopyData(current)
  else
    e.data = {}
    for _, k in ipairs(target.keys or {}) do
      local value, d = Core.CopyData(rawget(current, k))
      e.data[k] = value
      dropped = dropped + d
    end
  end
  if dropped > 0 then e.dropped = dropped end
  return e
end

local function addName(list, set, name)
  if type(name) == "string" and name ~= "" and not set[name] then
    set[name] = true
    list[#list + 1] = name
  end
end

-- Class entry (AceDB profile level) for this character; `extraNames` adds
-- profile names to read (absent ones restore as absent).
local function captureClass(target, keys, extraNames, allowEmpty)
  local current = _G[target.name]
  if current ~= nil and type(current) ~= "table" then return nil, "저장 변수 형식이 표가 아님" end
  current = current or {}
  local profileKeys = type(rawget(current, "profileKeys")) == "table" and current.profileKeys or {}
  local profileKey = rawget(profileKeys, keys.char)
  if type(profileKey) ~= "string" then profileKey = nil end
  local profiles = type(rawget(current, "profiles")) == "table" and current.profiles or {}
  local spaces = type(rawget(current, "namespaces")) == "table" and current.namespaces or {}
  local lds
  local ldsSpace = rawget(spaces, LDS_NAMESPACE)
  if type(ldsSpace) == "table" and type(rawget(ldsSpace, "char")) == "table" then
    local charEntry = rawget(ldsSpace.char, keys.char)
    if type(charEntry) == "table" then lds = Core.CopyData(charEntry) end
  end
  local names, set = {}, {}
  addName(names, set, profileKey or keys.className)
  if lds then
    addName(names, set, lds[1])
    addName(names, set, lds[2])
  end
  for _, n in ipairs(extraNames or {}) do addName(names, set, n) end
  local found = profileKey ~= nil
  for _, n in ipairs(names) do
    if rawget(profiles, n) ~= nil then found = true end
  end
  if not found and not allowEmpty then return nil, "이 캐릭터의 profile 이 아직 없음" end
  local e = newEntryBase(target)
  e.char, e.profileKey, e.profileNames, e.lds = keys.char, profileKey, names, lds
  e.profiles, e.namespaces = {}, {}
  local dropped = 0
  for _, n in ipairs(names) do
    local data = rawget(profiles, n)
    if type(data) == "table" then
      local d
      e.profiles[n], d = Core.CopyData(data)
      dropped = dropped + d
    end
  end
  for ns, space in pairs(spaces) do
    if ns ~= LDS_NAMESPACE and type(space) == "table" and type(rawget(space, "profiles")) == "table" then
      for _, n in ipairs(names) do
        local data = rawget(space.profiles, n)
        if type(data) == "table" then
          e.namespaces[ns] = e.namespaces[ns] or {}
          local d
          e.namespaces[ns][n], d = Core.CopyData(data)
          dropped = dropped + d
        end
      end
    end
  end
  if dropped > 0 then e.dropped = dropped end
  return e
end

-- Writing ---------------------------------------------------------------------------

-- Keys of a "keys" entry that the registry still lists (saved list ∩ registry list).
local function restorableKeys(target, e)
  local listed, out = {}, {}
  for _, k in ipairs(target.keys or {}) do listed[k] = true end
  for _, k in ipairs(type(e.keys) == "table" and e.keys or {}) do
    if listed[k] then out[#out + 1] = k end
  end
  return out
end

local function writeCommon(target, e)
  local svName = target.name
  if e.restore == "whole" then
    if e.absent then
      _G[svName] = nil
    else
      _G[svName] = Core.CopyData(e.data)
    end
    return true
  end
  local current = _G[svName]
  if current == nil then
    if e.absent then return true end
    current = {}
    _G[svName] = current
  end
  local data = type(e.data) == "table" and e.data or {}
  for _, k in ipairs(restorableKeys(target, e)) do rawset(current, k, (Core.CopyData(data[k]))) end
  return true
end

-- Profile names another character uses: the target of any other character's
-- profileKeys entry or LibDualSpec group entry.
local function profilesOfOthers(sv, charKey)
  local used = {}
  if type(sv) ~= "table" then return used end
  local profileKeys = rawget(sv, "profileKeys")
  if type(profileKeys) == "table" then
    for char, name in pairs(profileKeys) do
      if char ~= charKey and type(name) == "string" then used[name] = true end
    end
  end
  local spaces = rawget(sv, "namespaces")
  local ldsSpace = type(spaces) == "table" and rawget(spaces, LDS_NAMESPACE)
  local chars = type(ldsSpace) == "table" and rawget(ldsSpace, "char")
  if type(chars) == "table" then
    for char, entry in pairs(chars) do
      if char ~= charKey and type(entry) == "table" then
        for _, i in ipairs({1, 2}) do
          if type(entry[i]) == "string" then used[entry[i]] = true end
        end
      end
    end
  end
  return used
end

-- Saved profile names that another character uses are never written: each
-- gets a free name instead — this character's key, then "<key> (2)", "<key>
-- (3)", … — that no other character uses and that is not already a write
-- target of this entry. Returns {[saved name] = target name}.
local function characterRenames(target, e, keys)
  local rename = {}
  local used = profilesOfOthers(_G[target.name], keys.char)
  local names = type(e.profileNames) == "table" and e.profileNames or {}
  local taken = {}
  for _, n in ipairs(names) do
    if not used[n] then taken[n] = true end
  end
  for _, n in ipairs(names) do
    if used[n] and not rename[n] then
      local candidate, i = keys.char, 1
      while used[candidate] or taken[candidate] do
        i = i + 1
        candidate = keys.char .. " (" .. i .. ")"
      end
      taken[candidate] = true
      rename[n] = candidate
    end
  end
  return rename
end

local function writeClass(target, e, keys, rename)
  rename = rename or {}
  local function to(n) return rename[n] or n end
  local svName = target.name
  local sv = _G[svName]
  if sv == nil then
    sv = {}
    _G[svName] = sv
  end
  local profiles = subTable(sv, "profiles")
  local profileKeys = subTable(sv, "profileKeys")
  if not profiles or not profileKeys then return false, "profiles/profileKeys 형식이 표가 아님" end
  local spaces = rawget(sv, "namespaces")
  if spaces ~= nil and type(spaces) ~= "table" then return false, "namespaces 형식이 표가 아님" end
  local names = type(e.profileNames) == "table" and e.profileNames or {}
  for _, n in ipairs(names) do
    rawset(profiles, to(n), (Core.CopyData(e.profiles and e.profiles[n])))
  end
  for ns, byName in pairs(type(e.namespaces) == "table" and e.namespaces or {}) do
    if spaces == nil then
      spaces = {}
      rawset(sv, "namespaces", spaces)
    end
    local space = subTable(spaces, ns)
    local nsProfiles = space and subTable(space, "profiles")
    if nsProfiles then
      for n, data in pairs(byName) do rawset(nsProfiles, to(n), (Core.CopyData(data))) end
    end
  end
  if type(spaces) == "table" then
    for ns, space in pairs(spaces) do
      if ns ~= LDS_NAMESPACE and type(space) == "table" and type(rawget(space, "profiles")) == "table" then
        local saved = type(e.namespaces) == "table" and e.namespaces[ns] or {}
        for _, n in ipairs(names) do
          if saved[n] == nil then rawset(space.profiles, to(n), nil) end
        end
      end
    end
  end
  rawset(profileKeys, keys.char, e.profileKey and to(e.profileKey))
  if e.lds ~= nil then
    if spaces == nil then
      spaces = {}
      rawset(sv, "namespaces", spaces)
    end
    local ldsSpace = subTable(spaces, LDS_NAMESPACE)
    local charRoot = ldsSpace and subTable(ldsSpace, "char")
    if charRoot then
      local lds = Core.CopyData(e.lds)
      if type(lds) == "table" then
        for _, i in ipairs({1, 2}) do
          if type(lds[i]) == "string" then lds[i] = to(lds[i]) end
        end
      end
      rawset(charRoot, keys.char, lds)
    end
  elseif type(spaces) == "table" then
    local ldsSpace = rawget(spaces, LDS_NAMESPACE)
    local charRoot = type(ldsSpace) == "table" and rawget(ldsSpace, "char")
    if type(charRoot) == "table" then rawset(charRoot, keys.char, nil) end
  end
  return true
end

-- Jobs ------------------------------------------------------------------------------

local function addLine(lines, text) lines[#lines + 1] = text end

local function coreLayout()
  local db = Core.db
  local theme = type(rawget(db, "theme")) == "table" and db.theme.active or nil
  local preset = type(rawget(db, "preset")) == "table" and db.preset.active or nil
  local edits = rawget(db, "edits")
  return {edits = type(edits) == "table" and (Core.CopyData(edits)) or nil,
          theme = type(theme) == "string" and theme or nil, preset = type(preset) == "string" and preset or nil}
end

local function addTarget(byFolder, folder, item)
  local key = tostring(folder):lower()
  byFolder[key] = byFolder[key] or {}
  local list = byFolder[key]
  list[#list + 1] = item
end

local function startSave(p, keys)
  job = {action = "save", name = p.name, keys = keys, lines = {}, captured = {common = {}, class = {}},
         targets = {}, core = coreLayout(), pendingTargets = {}}
  for svName, t in pairs(registryTargets()) do
    if Core.IsLoadedInClient(t.folder) then
      addLine(job.lines, t.folder .. " " .. svName .. ": Core 보다 먼저 켜짐 — 이번에 저장 못 함")
    else
      addTarget(job.targets, t.folder, {svName = svName, target = t})
      job.pendingTargets[svName] = t
    end
  end
end

local function startRestore(p, keys, keyUnknown)
  local snap = store.snapshots[p.name]
  local problem = snap == nil and "저장본 없음" or snapshotProblem(snap)
  if problem then
    addLine(loadLines, tostring(p.name) .. " 되돌리기 안 함: " .. problem)
    return
  end
  local parts = type(p.parts) == "table" and p.parts or partsFor("all")
  local onlyLower = type(p.only) == "string" and p.only:lower() or nil
  local function wanted(folder) return not onlyLower or tostring(folder):lower() == onlyLower end
  job = {action = "restore", name = p.name, snap = snap, keys = keys, keyUnknown = keyUnknown, lines = {},
         targets = {}, written = 0, backup = {common = {}, class = {}}, folders = {}, pendingTargets = {}}
  local targets = registryTargets()
  local function consider(svName, e, kind)
    local folder = tostring(e.folder)
    local reg = targets[svName]
    local label = folder .. " " .. svName
    if not reg or reg.restore ~= kind or (kind ~= "profile" and e.restore ~= kind) then
      addLine(job.lines, label .. ": 등록 표에서 " .. tostring(kind) .. " 대상이 아님 — 건드리지 않음")
    elseif keyUnknown and (kind == "profile" or reg.scope == "character") then
      addLine(job.lines, label .. ": 캐릭터를 모름 — 건드리지 않음(캐릭터 확인 뒤 다시 /dfp go)")
    elseif kind ~= "profile" and reg.scope == "character" and e.char ~= keys.char then
      addLine(job.lines, label .. ": 다른 캐릭터(" .. tostring(e.char) .. ")의 값 — 건드리지 않음")
    elseif kind == "whole" and not e.absent and type(e.data) ~= "table" then
      addLine(job.lines, label .. ": 저장본 항목 형식이 맞지 않음 — 건드리지 않음")
    elseif kind == "keys" and (type(e.keys) ~= "table" or (not e.absent and type(e.data) ~= "table")) then
      addLine(job.lines, label .. ": 저장본 항목 형식이 맞지 않음 — 건드리지 않음")
    elseif kind == "profile" and (type(e.profileNames) ~= "table" or type(e.profiles) ~= "table") then
      addLine(job.lines, label .. ": 저장본 항목 형식이 맞지 않음 — 건드리지 않음")
    elseif Core.IsLoadedInClient(reg.folder) then
      addLine(job.lines, label .. ": Core 보다 먼저 켜짐 — 건드리지 않음")
    else
      local okVersion, msg = versionMatches(e, reg.folder)
      if not okVersion then
        addLine(job.lines, label .. ": " .. msg .. " — 건드리지 않음")
      else
        addTarget(job.targets, reg.folder, {svName = svName, target = reg, entry = e, kind = kind, versionNote = msg})
        job.folders[reg.folder] = true
        job.pendingTargets[svName] = reg
      end
    end
  end
  if parts.common then
    for svName, e in pairs(type(snap.common) == "table" and snap.common or {}) do
      if type(e) ~= "table" then
        addLine(job.lines, svName .. ": 저장본 항목 형식이 맞지 않음 — 건드리지 않음")
      elseif wanted(e.folder) then
        consider(svName, e, e.restore)
      end
    end
  end
  if parts.class then
    for token, byName in pairs(type(snap.class) == "table" and snap.class or {}) do
      for svName, e in pairs(type(byName) == "table" and byName or {}) do
        if type(e) ~= "table" then
          addLine(job.lines, svName .. ": 저장본 항목 형식이 맞지 않음 — 건드리지 않음")
        elseif wanted(e.folder) then
          if keyUnknown then
            addLine(job.lines, tostring(e.folder) .. " " .. svName .. ": 캐릭터를 모름 — 건드리지 않음(캐릭터 확인 뒤 다시 /dfp go)")
          elseif token ~= keys.class then
            addLine(job.lines, tostring(e.folder) .. " " .. svName .. ": " .. tostring(token)
              .. " 직업의 값 — 건드리지 않음")
          else
            consider(svName, e, "profile")
          end
        end
      end
    end
  end
  for folder in pairs(job.folders) do
    if Core.Defaults then Core.Defaults:Suppress(folder, "설정 되돌리기 " .. p.name) end
  end
  -- Core's layout part, before any reader of DevilForever_CoreDB.
  if parts.common and wanted(Core.name) and type(snap.core) == "table" then
    local db = Core.db
    local edits = rawget(db, "edits")
    if edits ~= nil and type(edits) ~= "table" then
      addLine(job.lines, Core.name .. ": 편집값 저장 자리가 표가 아님 — 건드리지 않음")
    else
      job.backup.core = coreLayout()
      db.edits = type(snap.core.edits) == "table" and (Core.CopyData(snap.core.edits)) or {}
      Core:DBTable("theme").active = type(snap.core.theme) == "string" and snap.core.theme or nil
      local presetName = snap.core.preset
      local presets = Core.Presets
      if type(presetName) == "string" and presets and not presets:IsRegistered(presetName) then
        addLine(job.lines, Core.name .. ": preset " .. presetName .. " 이 등록돼 있지 않음 — 지금 preset 유지")
      else
        Core:DBTable("preset").active = type(presetName) == "string" and presetName or nil
      end
      job.written = job.written + 1
      addLine(job.lines, Core.name .. ": 편집값·테마·preset 되돌림")
    end
  end
end

local function takePending()
  local p = store.pending
  if p == nil then return end
  local label = type(p) == "table" and (tostring(p.action) .. " " .. tostring(p.name)) or ""
  if type(p) == "table" and p.armed ~= true then
    local keys = Core.PlayerKeys()
    if keys and keys.char == p.char then
      addLine(noticeLines, label .. ": 기다리는 요청(아직 /dfp go 안 함) — 쓰지 않고 남김. /dfp go 또는 /dfp cancel")
    end
    return
  end
  store.pending = nil
  if type(p) ~= "table" then
    addLine(loadLines, "기다리던 요청의 형식이 맞지 않아 버림")
    return
  end
  local keys, why = Core.PlayerKeys()
  local age = type(p.armedAt) == "number" and (now() - p.armedAt) or nil
  local keyUnknown = false
  if not keys and p.action ~= "save" and age and age >= 0 and age <= Profiles.KEY_FALLBACK_AGE
      and type(p.keys) == "table" and type(p.keys.char) == "string" and p.keys.char == p.char then
    keys = Core.CopyTable(p.keys)
    keyUnknown = true
    verifyChar = p.char
    addLine(loadLines, label .. ": 캐릭터 이름을 아직 모름(" .. tostring(why) .. ") — 계정 공통 값만 씀"
      .. "(캐릭터별·직업별 값은 캐릭터 확인 뒤 다시 /dfp go)")
  end
  if not keys then
    addLine(loadLines, label .. ": 캐릭터 이름을 모름(" .. tostring(why) .. ") — 요청 버림")
  elseif p.char ~= keys.char then
    addLine(loadLines, label .. ": 다른 캐릭터(" .. tostring(p.char) .. ")의 요청 — 버림")
  elseif not age or age < 0 or age > Profiles.PENDING_MAX_AGE then
    addLine(loadLines, label .. ": /dfp go 한 지 " .. Profiles.PENDING_MAX_AGE .. "초가 넘음 — 버림")
  elseif p.action == "save" then
    startSave(p, keys)
  elseif p.action == "restore" then
    startRestore(p, keys, keyUnknown)
  elseif p.action == "preset" then
    presetRequest = {name = p.name, keys = keys, keyUnknown = keyUnknown}
  else
    addLine(loadLines, label .. ": 알 수 없는 요청 — 버림")
  end
end

-- Presets.lua takes the validated preset request once.
function Profiles:TakePresetRequest()
  local r = presetRequest
  presetRequest = nil
  return r
end

-- True when saved variable `svName` was nil when its addon's ADDON_LOADED
-- reached Core this session; nil when Core has not seen that load.
function Profiles:WasFresh(svName)
  return freshAtLoad[svName]
end

-- Asks for <svName>[key] to be looked at in the same handler as WasFresh.
function Profiles:WatchKey(svName, key)
  if type(svName) ~= "string" or key == nil then return end
  watchedKeys[svName] = watchedKeys[svName] or {}
  watchedKeys[svName][key] = true
end

-- True when <svName>[key] was nil (the saved variable nil included) when its
-- addon's ADDON_LOADED reached Core this session; false when it was there or
-- this session's restore job wrote the saved variable; nil when not seen.
function Profiles:KeyWasAbsent(svName, key)
  local byKey = absentAtLoad[svName]
  if byKey == nil then return nil end
  return byKey[key]
end

local function processSave(item)
  local t = item.target
  local e, why
  if t.restore == "profile" then
    e, why = captureClass(t, job.keys)
  else
    e, why = captureCommon(t, job.keys)
  end
  job.pendingTargets[item.svName] = nil
  if not e then
    addLine(job.lines, t.folder .. " " .. item.svName .. ": " .. why .. " — 저장 안 함")
    return
  end
  if t.restore == "profile" then
    job.captured.class[item.svName] = e
  else
    job.captured.common[item.svName] = e
  end
  addLine(job.lines, t.folder .. " " .. item.svName .. ": 저장" .. (e.dropped and (" (값 " .. e.dropped .. "개는 데이터가 아니라 뺌)") or ""))
end

local function processRestore(item)
  local t, e, kind = item.target, item.entry, item.kind
  local label = t.folder .. " " .. item.svName
  job.pendingTargets[item.svName] = nil
  local current = _G[item.svName]
  if current ~= nil and type(current) ~= "table" then
    addLine(job.lines, label .. ": 지금 저장 변수 형식이 표가 아님 — 건드리지 않음")
    return
  end
  if (t.shape == "acedb" or kind == "profile") and Core.FindAceDB(current) then
    addLine(job.lines, label .. ": 애드온이 먼저 읽음(너무 늦음) — 건드리지 않음")
    return
  end
  local msg = item.versionNote
  local rename, targetNames = {}, {}
  if kind == "profile" then
    rename = characterRenames(t, e, job.keys)
    for _, n in ipairs(e.profileNames) do targetNames[#targetNames + 1] = rename[n] or n end
  end
  local backup, why
  if kind == "profile" then
    backup, why = captureClass(t, job.keys, targetNames, true)
  else
    backup, why = captureCommon(t, job.keys, true)
  end
  if not backup then
    addLine(job.lines, label .. ": " .. why .. " — 건드리지 않음")
    return
  end
  freshAtLoad[item.svName] = false
  for key in pairs(absentAtLoad[item.svName] or {}) do absentAtLoad[item.svName][key] = false end
  local ok, err
  if kind == "profile" then
    ok, err = writeClass(t, e, job.keys, rename)
  else
    ok, err = writeCommon(t, e)
  end
  if not ok then
    addLine(job.lines, label .. ": " .. tostring(err) .. " — 건드리지 않음")
    return
  end
  if kind == "profile" then job.backup.class[item.svName] = backup else job.backup.common[item.svName] = backup end
  job.written = job.written + 1
  addLine(job.lines, label .. ": 되돌림" .. (msg and (" (" .. msg .. ")") or ""))
  for from, into in pairs(rename) do
    addLine(job.lines, label .. ": profile " .. from .. " 은 다른 캐릭터의 것 — 값을 " .. into .. " profile 에 씀")
  end
  if kind == "keys" then
    local kept = #restorableKeys(t, e)
    if kept < #e.keys then
      addLine(job.lines, label .. ": 등록 표에 없는 키 " .. (#e.keys - kept) .. "개는 쓰지 않음")
    end
  end
end

local function savedBy(keys)
  return {char = keys.char, realm = keys.realm, class = keys.class, group = currentGroup()}
end

local function finishSave()
  local old = store.snapshots[job.name]
  if snapshotProblem(old) and old ~= nil then
    addLine(job.lines, job.name .. ": 같은 이름의 저장본이 읽기만 하는 판 — 저장 안 함")
    return
  end
  if old == nil and userSnapshotCount() >= Profiles.MAX_SNAPSHOTS then
    addLine(job.lines, job.name .. ": 저장본이 이미 " .. Profiles.MAX_SNAPSHOTS .. "개 — 저장 안 함")
    return
  end
  for svName, t in pairs(job.pendingTargets) do
    addLine(job.lines, t.folder .. " " .. svName .. ": 애드온이 켜지지 않음 — 이번에 저장 못 함")
  end
  local snap = {name = job.name, schema = Profiles.SCHEMA, savedAt = now(), savedBy = savedBy(job.keys),
                core = job.core, common = {}, class = {}}
  if old then
    for svName, e in pairs(type(old.common) == "table" and old.common or {}) do
      if type(e) == "table" then e.carried = true end
      snap.common[svName] = e
    end
    for token, byName in pairs(type(old.class) == "table" and old.class or {}) do
      snap.class[token] = {}
      for svName, e in pairs(type(byName) == "table" and byName or {}) do
        if type(e) == "table" then e.carried = true end
        snap.class[token][svName] = e
      end
    end
  end
  for svName, e in pairs(job.captured.common) do snap.common[svName] = e end
  local token = job.keys.class or "?"
  for svName, e in pairs(job.captured.class) do
    snap.class[token] = snap.class[token] or {}
    snap.class[token][svName] = e
  end
  for svName, e in pairs(snap.common) do
    if e.carried then addLine(job.lines, tostring(e.folder) .. " " .. svName .. ": 전에 저장한 값을 남김") end
  end
  store.snapshots[job.name] = snap
  addLine(job.lines, job.name .. " 저장 끝")
end

local function finishRestore()
  for svName, t in pairs(job.pendingTargets) do
    addLine(job.lines, t.folder .. " " .. svName .. ": 애드온이 켜지지 않음 — 저장본 항목은 남기고 저장 변수는 만들지 않음")
  end
  if job.written > 0 then
    local by = job.keyUnknown and {char = "unknown"} or savedBy(job.keys)
    local backup = {name = Profiles.UNDO, schema = Profiles.SCHEMA, savedAt = now(), savedBy = by,
                    core = job.backup.core, common = job.backup.common, class = {}}
    if next(job.backup.class) then backup.class[job.keys.class or "?"] = job.backup.class end
    if job.name == Profiles.UNDO then
      -- Undoing from the undo slot: entries not written now stay in the slot.
      local prev = job.snap
      if backup.core == nil and type(prev.core) == "table" then backup.core = prev.core end
      for svName, e in pairs(type(prev.common) == "table" and prev.common or {}) do
        if backup.common[svName] == nil and type(e) == "table" then
          e.carried = true
          backup.common[svName] = e
        end
      end
      for token, byName in pairs(type(prev.class) == "table" and prev.class or {}) do
        for svName, e in pairs(type(byName) == "table" and byName or {}) do
          backup.class[token] = backup.class[token] or {}
          if backup.class[token][svName] == nil and type(e) == "table" then
            e.carried = true
            backup.class[token][svName] = e
          end
        end
      end
    end
    store.snapshots[Profiles.UNDO] = backup
    addLine(job.lines, job.name .. " 되돌리기 끝 — 되돌리기 전 상태는 " .. Profiles.UNDO .. " 에 있음")
  else
    addLine(job.lines, job.name .. " 되돌리기: 쓴 것 없음")
  end
end

-- Events ----------------------------------------------------------------------------

Core.readyCallbacks:Register(Profiles, function()
  initStore()
  if store then takePending() end
end)

Core:On("ADDON_LOADED", function(_, loaded)
  if type(loaded) ~= "string" or not Core.ready then return end
  local lower = loaded:lower()
  for _, sv in ipairs(Core:GetSavedVariables(loaded)) do
    if freshAtLoad[sv.name] == nil then freshAtLoad[sv.name] = (_G[sv.name] == nil) end
    if watchedKeys[sv.name] and absentAtLoad[sv.name] == nil then
      local value, byKey = _G[sv.name], {}
      for key in pairs(watchedKeys[sv.name]) do
        byKey[key] = type(value) ~= "table" or rawget(value, key) == nil
      end
      absentAtLoad[sv.name] = byKey
    end
  end
  if not job or not job.targets[lower] then return end
  local items = job.targets[lower]
  job.targets[lower] = nil
  for _, item in ipairs(items) do
    if job.action == "save" then processSave(item) else processRestore(item) end
  end
end)

-- A request taken while the player key was unknown is checked once the key is known.
Core:On("PLAYER_LOGIN", function()
  if not verifyChar then return end
  local keys = Core.PlayerKeys()
  local line
  if not keys then
    line = "캐릭터를 확인하지 못함 — 요청한 캐릭터 " .. verifyChar .. " 로 진행했음"
  elseif keys.char ~= verifyChar then
    line = "!! 경고: 요청한 캐릭터 " .. verifyChar .. " 와 지금 캐릭터 " .. keys.char
      .. " 가 다름 — 바뀐 값을 되돌리려면 /dfp restore " .. Profiles.UNDO .. " 후 /dfp go"
  end
  verifyChar = nil
  if line then
    Profiles:Print(line)
    addLine(job and job.lines or loadLines, line)
  end
end)

Core:On("PLAYER_ENTERING_WORLD", function()
  if worldSeen then return end
  worldSeen = true
  local lines = loadLines
  loadLines = {}
  if job then
    if job.action == "save" then finishSave() else finishRestore() end
    for _, line in ipairs(job.lines) do lines[#lines + 1] = line end
    store.last = {action = job.action, name = job.name, at = now(), lines = Core.CopyTable(job.lines)}
    job = nil
  elseif #lines > 0 and store then
    store.last = {action = "drop", at = now(), lines = Core.CopyTable(lines)}
  end
  if readOnly then lines[#lines + 1] = readOnly end
  printLines(lines)
  printLines(noticeLines)
  noticeLines = {}
end)

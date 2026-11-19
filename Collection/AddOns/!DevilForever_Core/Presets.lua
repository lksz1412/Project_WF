-- Layout presets (FHD, QHD, UHD and others): a layer of per-frame edit values
-- under the stored edits, plus value fragments for other addons' saved
-- variables.
--
-- Presets:Register({name, screen = {width, height}|nil, uiScale = number|nil,
--   edits = {[frameKey] = {[field] = value}},
--   fragments = {{folder, savedVariable, section = "root"|"global"|"profile",
--     profile = token|nil, namespace = name|nil, addonVersion = string,
--     version = integer >= 1, values = table}}})
-- Each edit value must pass Edit:Validate on a registered frame key; each
-- fragment must name a registered folder and one of its saved variables
-- (Core's own excluded). Bad values and fragments are dropped and logged.
-- Returns the number of edit values and fragments kept. Registering a name
-- again replaces the earlier definition.
-- profile tokens (section "profile"): "$char" (default), "$class",
-- "$className", "$realm" or a literal name; the profile <SV>.profileKeys names
-- for this character wins over the token.
--
-- Active preset: DevilForever_CoreDB.preset.active. Edit:Get reads
-- Presets:GetValue between the registry default and the stored edit.
-- When no preset is active at Core's ready step, one is chosen by the physical
-- screen height (>= 2000 "uhd", >= 1400 "qhd", else "fhd"; "uhd" when the
-- height is unknown or the chosen name is not registered; none when "uhd" is
-- not registered either).
--
-- Restore(name), out of combat: clears the stored edits of the frames the
-- preset covers (other frames keep theirs), makes it active, calls the Edit
-- listeners for every frame and field of the old and new preset; when it has
-- fragments, stores a "preset" request (Profiles.lua) so they are written at
-- the next load (/dfp go) and marks DevilForever_CoreDB.preset.unfinished =
-- name until that load has run the request; while it is set, each login
-- prints that the addon values are not written yet (cleared by the next
-- Restore, by a completed request and by /dfp cancel of the request). At the
-- first PLAYER_ENTERING_WORLD one line names how many fragments of the active
-- preset were kept or skipped, printed only when that set changed since the
-- last print (DevilForever_CoreDB.preset.keptNotice).
-- A request taken while the player key was unknown skips fragments of
-- section "profile" and of character-scope saved variables (reported).
-- Fragment writes, at the target addon's ADDON_LOADED after Defaults' handler
-- (a fresh plain target at the next PLAYER_ENTERING_WORLD): Core.WriteOver of
-- `values` into the section (listed keys replaced, others kept), recorded in
-- DevilForever_CoreDB.preset.fragments[preset][targetKey] = version.
--   requested  every fragment of the requested preset
--   otherwise  fragments of the active preset not recorded at their version,
--              only into a saved variable that was nil at its ADDON_LOADED
--              (an existing one is kept and reported)
-- A version other than addonVersion (addon metadata, else registry version),
-- an AceDB that already opened the saved variable (sections global and
-- profile) or a value of the wrong type skips the fragment.
-- targetKey: "<SV>[/<namespace>]@<section>[:<profile>][@char:<character key>]"
-- (the character part for character-scope saved variables).

local _, Core = ...

local type, pairs, ipairs, tostring, floor, sort = type, pairs, ipairs, tostring, math.floor, table.sort

local Presets = {}
Core.Presets = Presets

local SECTIONS = {root = true, global = true, profile = true}

local defs = {}           -- [name] = definition copy
local request             -- {name, keys} from a stored "preset" request
local fragmentState = {}  -- [preset .. "|" .. index] = {state, message, key}
local waitingWorld = {}   -- fragments due at the next PLAYER_ENTERING_WORLD
local worldSeen = false

-- Registry lookups read Core.Registry directly: preset files run at load time,
-- before API.lua.
local function registryEntry(folder)
  local registry = Core.Registry
  local addons = type(registry) == "table" and type(registry.addons) == "table" and registry.addons or {}
  if type(folder) ~= "string" then return nil end
  if addons[folder] then return addons[folder] end
  local lower = folder:lower()
  for name, entry in pairs(addons) do
    if name:lower() == lower then return entry end
  end
end

local function registeredFrameKeys()
  local out = {}
  local registry = Core.Registry
  for _, entry in pairs(type(registry) == "table" and type(registry.addons) == "table" and registry.addons or {}) do
    for _, frame in ipairs(entry.frames or {}) do
      if type(frame.key) == "string" then out[frame.key] = true end
    end
  end
  return out
end

local function svOfFolder(folder, svName)
  local entry = registryEntry(folder)
  for _, sv in ipairs(entry and entry.savedVariables or {}) do
    if sv.name == svName then return sv end
  end
end

local function fragmentProblem(f)
  if type(f) ~= "table" then return "not a table" end
  if type(f.folder) ~= "string" or not registryEntry(f.folder) then return "folder not in the registry" end
  if f.folder:lower() == Core.name:lower() then
    return "Core's own saved variables are not targets"
  end
  if type(f.savedVariable) ~= "string" or not svOfFolder(f.folder, f.savedVariable) then
    return "saved variable not registered for the folder"
  end
  if not SECTIONS[f.section] then return "section must be root, global or profile" end
  if f.profile ~= nil and (f.section ~= "profile" or type(f.profile) ~= "string" or f.profile == "") then
    return "profile token only with section profile"
  end
  if f.namespace ~= nil and (f.section ~= "profile" or type(f.namespace) ~= "string" or f.namespace == "") then
    return "namespace only with section profile"
  end
  if type(f.addonVersion) ~= "string" or f.addonVersion == "" then return "addonVersion must be a string" end
  if type(f.version) ~= "number" or f.version < 1 or floor(f.version) ~= f.version then
    return "version must be an integer >= 1"
  end
  if type(f.values) ~= "table" then return "values must be a table" end
end

function Presets:Register(def)
  if type(def) ~= "table" or type(def.name) ~= "string" or def.name == "" then
    Core:Log("error", "Presets", "definition without a name")
    return 0
  end
  local name, subject = def.name, "Presets:" .. def.name
  local keep = {name = name, edits = {}, fragments = {}}
  if type(def.screen) == "table" and type(def.screen[1]) == "number" and type(def.screen[2]) == "number" then
    keep.screen = {def.screen[1], def.screen[2]}
  end
  if type(def.uiScale) == "number" then keep.uiScale = def.uiScale end
  local kept = 0
  local frames = registeredFrameKeys()
  for frameKey, fields in pairs(type(def.edits) == "table" and def.edits or {}) do
    if not frames[frameKey] then
      Core:Log("skip", subject, "frame key " .. tostring(frameKey) .. " is not registered")
    elseif type(fields) ~= "table" then
      Core:Log("skip", subject, tostring(frameKey) .. " values are not a table")
    else
      for field, value in pairs(fields) do
        local ok, reason = Core.Edit:Validate(frameKey, field, value)
        if ok then
          keep.edits[frameKey] = keep.edits[frameKey] or {}
          keep.edits[frameKey][field] = Core.CopyTable(value)
          kept = kept + 1
        else
          Core:Log("skip", subject, frameKey .. "." .. tostring(field) .. ": " .. tostring(reason))
        end
      end
    end
  end
  for i, f in ipairs(type(def.fragments) == "table" and def.fragments or {}) do
    local problem = fragmentProblem(f)
    if problem then
      Core:Log("skip", subject, "fragment " .. i .. ": " .. problem)
    else
      keep.fragments[#keep.fragments + 1] = Core.CopyTable(f)
      kept = kept + 1
    end
  end
  if defs[name] then Core:Log("info", subject, "registered again; previous definition replaced") end
  defs[name] = keep
  return kept
end

function Presets:IsRegistered(name) return defs[name] ~= nil end

function Presets:List()
  local out = {}
  for name in pairs(defs) do out[#out + 1] = name end
  sort(out)
  return out
end

-- Active preset name (or nil) and whether it is registered.
function Presets:GetActive()
  if not Core.ready then return nil, false end
  local active = rawget(Core:DBTable("preset"), "active")
  if type(active) ~= "string" then return nil, false end
  return active, defs[active] ~= nil
end

-- Value of the active preset for (frameKey, field), or nil.
function Presets:GetValue(frameKey, field)
  local active = self:GetActive()
  local def = active and defs[active]
  local fields = def and def.edits[frameKey]
  if not fields or fields[field] == nil then return nil end
  return Core.CopyTable(fields[field])
end

-- Copy of a definition (edits, fragments, screen, uiScale) or nil.
function Presets:Get(name)
  return defs[name] and Core.CopyTable(defs[name]) or nil
end

local function fragmentFolders(def)
  local out, seen = {}, {}
  for _, f in ipairs(def.fragments) do
    if not seen[f.folder] then
      seen[f.folder] = true
      out[#out + 1] = f.folder
    end
  end
  sort(out)
  return out
end

-- Returns true, lines | false, reason.
function Presets:Restore(name)
  if Core.InCombat() then return false, "전투 중 — 바꾼 것 없음" end
  if not Core.ready then return false, "Core 저장 변수를 아직 읽지 않음" end
  local def = defs[name]
  if not def then return false, tostring(name) .. ": 등록된 preset 이 아님" end
  if #def.fragments > 0 then
    local keys, why = Core.Profiles:CanRequest()
    if not keys then return false, why end
  end
  local oldName = self:GetActive()
  local old = oldName and defs[oldName]
  local lines = {}
  local cleared = Core.Edit:Batch(function()
    local cleared = 0
    for frameKey in pairs(def.edits) do
      local _, how = Core.Edit:Clear(frameKey)
      if how ~= "unchanged" then cleared = cleared + 1 end
    end
    Core:DBTable("preset").active = name
    local touched = {}
    for _, d in ipairs({old or {edits = {}}, def}) do
      for frameKey, fields in pairs(d.edits) do
        touched[frameKey] = touched[frameKey] or {}
        for field in pairs(fields) do touched[frameKey][field] = true end
      end
    end
    for frameKey, fields in pairs(touched) do
      for field in pairs(fields) do Core.Edit:FireChanged(frameKey, field) end
    end
    return cleared
  end)
  lines[#lines + 1] = name .. " preset 적용 — 편집값을 지운 프레임 " .. cleared .. "개"
  Core:DBTable("preset").unfinished = nil
  if #def.fragments > 0 then
    local ok, why = Core.Profiles:SetPending({action = "preset", name = name})
    Core:DBTable("preset").unfinished = name
    if ok then
      lines[#lines + 1] = "애드온 값은 다시 불러온 뒤 씀: " .. table.concat(fragmentFolders(def), ", ") .. " — /dfp go"
    else
      lines[#lines + 1] = "애드온 값 예약 못 함: " .. tostring(why)
    end
  end
  return true, lines
end

-- Session state of fragment writes: {[preset .. "|" .. index] = {state, message, key}}
-- state: "written" | "kept" | "skipped".
function Presets:GetFragmentStatus()
  return Core.CopyTable(fragmentState)
end

-- Fragment writing ---------------------------------------------------------------

local function resolveProfile(token, keys)
  if token == nil or token == "$char" then return keys.char end
  if token == "$class" then return keys.class end
  if token == "$className" then return keys.className end
  if token == "$realm" then return keys.realm end
  return token
end

local function sub(parent, key)
  local t = rawget(parent, key)
  if t == nil then
    t = {}
    rawset(parent, key, t)
  elseif type(t) ~= "table" then
    return nil
  end
  return t
end

-- Target key and section table (created when missing) of fragment `f`, or
-- nil, reason. With `look` true nothing is created and the table is not returned.
local function locate(f, keys, look)
  local sv = _G[f.savedVariable]
  if sv ~= nil and type(sv) ~= "table" then return nil, "saved variable is not a table" end
  local reg = svOfFolder(f.folder, f.savedVariable)
  local charPart = reg and reg.scope == "character" and ("@char:" .. keys.char) or ""
  local where = f.savedVariable .. (f.namespace and ("/" .. f.namespace) or "")
  local profile
  if f.section == "profile" then
    local profileKeys = type(sv) == "table" and rawget(sv, "profileKeys")
    local entry = type(profileKeys) == "table" and rawget(profileKeys, keys.char)
    profile = type(entry) == "string" and entry ~= "" and entry or resolveProfile(f.profile, keys)
    if type(profile) ~= "string" or profile == "" then return nil, "profile name could not be resolved" end
  end
  local key = where .. "@" .. f.section .. (profile and (":" .. profile) or "") .. charPart
  if look then return key end
  if sv == nil then
    sv = {}
    _G[f.savedVariable] = sv
  end
  local tbl = sv
  if f.section == "global" then
    tbl = sub(sv, "global")
  elseif f.section == "profile" then
    local root = sv
    if f.namespace then
      local spaces = sub(sv, "namespaces")
      root = spaces and sub(spaces, f.namespace)
    end
    local profiles = root and sub(root, "profiles")
    tbl = profiles and sub(profiles, profile)
  end
  if not tbl then return nil, "a table on the way is of another type" end
  return key, tbl
end

local function installedMatches(f)
  local fn = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  local installed
  if type(fn) == "function" then
    local ok, v = pcall(fn, f.folder, "Version")
    if ok and type(v) == "string" and v ~= "" then installed = v end
  end
  if not installed then
    local entry = registryEntry(f.folder)
    installed = entry and entry.version
  end
  if installed ~= f.addonVersion then
    return false, "made for " .. f.addonVersion .. ", installed " .. tostring(installed)
  end
  return true
end

local function record(presetName, index, state, message, key)
  fragmentState[presetName .. "|" .. index] = {state = state, message = message, key = key}
  if state ~= "written" then Core:Log(state == "kept" and "info" or "skip", "Presets:" .. presetName,
    tostring(key or index) .. ": " .. tostring(message)) end
end

-- mode: "requested" | "fresh".
local function writeFragment(presetName, index, f, keys, mode)
  local sv = _G[f.savedVariable]
  if sv ~= nil and type(sv) ~= "table" then
    return record(presetName, index, "skipped", "saved variable is not a table")
  end
  if f.section ~= "root" and Core.FindAceDB(sv) then
    return record(presetName, index, "skipped", "the addon's AceDB opened the saved variable first")
  end
  local ok, why = installedMatches(f)
  if not ok then return record(presetName, index, "skipped", why) end
  local key, tbl = locate(f, keys)
  if not key then return record(presetName, index, "skipped", tbl) end
  local written = Core.WriteOver(tbl, f.values)
  Core:DBTable("preset", "fragments", presetName)[key] = f.version
  record(presetName, index, "written", mode .. ": " .. written .. " values", key)
end

local function recordedVersion(presetName, key)
  local byPreset = rawget(Core:DBTable("preset", "fragments"), presetName)
  return type(byPreset) == "table" and byPreset[key] or nil
end

-- Fragments of folder `lower` to look at now: {{presetName, index, fragment, mode}}.
local function dueFragments(lower)
  local out = {}
  if request and defs[request.name] then
    for i, f in ipairs(defs[request.name].fragments) do
      if f.folder:lower() == lower then out[#out + 1] = {request.name, i, f, "requested"} end
    end
    return out
  end
  local active, registered = Presets:GetActive()
  if not registered then return out end
  for i, f in ipairs(defs[active].fragments) do
    if f.folder:lower() == lower then out[#out + 1] = {active, i, f, "fresh"} end
  end
  return out
end

local function onAddonLoaded(folder)
  local keys = Core.PlayerKeys() or (request and request.keys)
  for _, due in ipairs(dueFragments(folder:lower())) do
    local presetName, index, f, mode = due[1], due[2], due[3], due[4]
    local reg = svOfFolder(f.folder, f.savedVariable)
    if not keys then
      record(presetName, index, "skipped", "player key unknown")
    elseif mode == "requested" and request.keyUnknown
        and (f.section == "profile" or (reg and reg.scope == "character")) then
      record(presetName, index, "skipped", "character not known at load — /dfp preset " .. presetName
        .. " again after login")
    elseif mode == "requested" then
      writeFragment(presetName, index, f, keys, mode)
    else
      local key = locate(f, keys, true)
      local recorded = key and recordedVersion(presetName, key)
      if not key then
        record(presetName, index, "skipped", "profile name could not be resolved")
      elseif type(recorded) == "number" and recorded >= f.version then
        fragmentState[presetName .. "|" .. index] = {state = "already", key = key}
      elseif Core.Profiles:WasFresh(f.savedVariable) ~= true then
        record(presetName, index, "kept", "existing settings kept — /dfp preset " .. presetName
          .. " applies preset values", key)
      elseif f.section == "root" then
        waitingWorld[#waitingWorld + 1] = {presetName, index, f}
      else
        writeFragment(presetName, index, f, keys, mode)
      end
    end
  end
end

-- First-run choice -----------------------------------------------------------------

-- Name chosen for this screen, or nil when no fitting preset is registered.
function Presets:PickForScreen()
  local height
  if type(GetPhysicalScreenSize) == "function" then
    local ok, _, h = pcall(GetPhysicalScreenSize)
    if ok and type(h) == "number" then height = h end
  end
  local name = "uhd"
  if height then
    if height >= 2000 then name = "uhd" elseif height >= 1400 then name = "qhd" else name = "fhd" end
  end
  if defs[name] then return name end
  if defs.uhd then return "uhd" end
  return nil
end

Core.readyCallbacks:Register(Presets, function()
  local r = Core.Profiles and Core.Profiles:TakePresetRequest()
  if r then
    if defs[r.name] then
      request = r
    else
      Core:Log("skip", "Presets", "requested preset " .. tostring(r.name) .. " is not registered")
    end
  end
  local db = Core:DBTable("preset")
  if rawget(db, "active") == nil then
    local pick = Presets:PickForScreen()
    if pick then
      db.active = pick
      Core:Log("info", "Presets", "first choice by screen size: " .. pick)
    end
  end
end)

Core:On("ADDON_LOADED", function(_, loaded)
  if type(loaded) ~= "string" or not Core.ready then return end
  onAddonLoaded(loaded)
end)

Core:On("PLAYER_ENTERING_WORLD", function()
  local due = waitingWorld
  waitingWorld = {}
  local keys = Core.PlayerKeys() or (request and request.keys)
  for _, item in ipairs(due) do
    if keys then writeFragment(item[1], item[2], item[3], keys, "fresh")
    else record(item[1], item[2], "skipped", "player key unknown") end
  end
  if not worldSeen then
    worldSeen = true
    if request then
      for i, f in ipairs(defs[request.name].fragments) do
        if not fragmentState[request.name .. "|" .. i] then
          record(request.name, i, "skipped", f.folder .. " not loaded")
        end
      end
      local lines = {request.name .. " preset 애드온 값:"}
      for i, f in ipairs(defs[request.name].fragments) do
        local st = fragmentState[request.name .. "|" .. i]
        lines[#lines + 1] = "  " .. f.folder .. " " .. f.savedVariable .. " " .. f.section .. " — "
          .. (st.state == "written" and "씀" or ("건너뜀: " .. tostring(st.message)))
      end
      for _, line in ipairs(lines) do Core.Profiles:Print(line) end
      Core:DBTable("preset").unfinished = nil
      request = nil
    else
      local db = Core:DBTable("preset")
      if type(db.unfinished) == "string" then
        Core.Profiles:Print(db.unfinished .. " preset 의 애드온 값이 아직 쓰이지 않음 — /dfp preset "
          .. db.unfinished .. " 을 다시 하면 끝남")
      end
      local active = Presets:GetActive()
      local ids = {}
      for id, st in pairs(fragmentState) do
        if active and id:sub(1, #active + 1) == active .. "|" and (st.state == "kept" or st.state == "skipped") then
          ids[#ids + 1] = id .. "=" .. tostring(st.key)
        end
      end
      sort(ids)
      local signature = #ids > 0 and table.concat(ids, ";") or nil
      if signature and db.keptNotice ~= signature then
        Core.Profiles:Print(active .. " preset 애드온 값 " .. #ids .. "개는 쓰지 않음(이미 있는 설정 유지 등) — /dfp preset "
          .. active .. " 으로 쓸 수 있음")
      end
      db.keptNotice = signature
    end
  end
end)

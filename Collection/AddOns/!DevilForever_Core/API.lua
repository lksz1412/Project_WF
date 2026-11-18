--[[ !DevilForever_Core public API (global table DevilForever_Core)

Registry (static data generated from Collection/manifest.json)
  Core:ListAddons()                 -> sorted list of registered folder names
  Core:GetAddonInfo(folder)         -> copy of the registry entry, or nil
      {package, version, phases, bundle = "required"|"individual", use,
       tocs, tocStatus, foreverLoad, savedVariables = {{name, scope =
       "account"|"character", split = "common"|"class", restore =
       "whole"|"keys"|"profile"|nil, shape = "plain"|"acedb"|nil,
       keys = {...}|nil}}, frames = {{key,
       frame, tokens}}, editable = {{frame, field, kind, min, max, step,
       default}}, defaults = "Defaults/<Folder>.lua"|nil}
      folder lookup ignores letter case, as the client does
  Core:IsAddonLoaded(folder)        -> true when the client has loaded it
  Core:GetFrameNames([folder])      -> sorted list of appearance frame names
                                       (all registered folders when nil)
  Core:GetFrameKeys([folder])       -> sorted list of registry frame keys
  Core:GetSavedVariables([folder])  -> list of {folder, name, scope, split,
                                       restore ("skip" when the registry
                                       names none), shape, keys}

Defaults (see Defaults.lua for the spec and the fill rules)
  Core.Defaults:Register(folder, spec)  -> true | false, reason
                                           (refused unless the registry entry of
                                           `folder` names a defaults file and
                                           lists every target saved variable)
  Core.Defaults:GetStatus([folder])     -> {folder, registered, loaded, version,
                                           suppressed = reason|nil, targets =
                                           {[label] = {state, mode, key, version,
                                           written, conflicts, lateCreated,
                                           message}}} (all folders when nil)
      state: "waiting" (not settled yet) | "skipped" (wrong type, absent) |
             "late-created" (fresh saved variable still nil; nothing written) |
             "suppressed" (Suppress called first) | "already" (version
             recorded earlier) | "existing-profile-kept" (AceDB target whose
             profile existed before Core first looked; nothing written) |
             "applied" (written this session)
      mode:  "first-load" (written over the addon's own values, login window
             only) | "fill-missing" (missing keys only; for AceDB targets
             only into a profile new at Core's first look)
      lateCreated: true when an earlier session marked the target late-created
  Core.Defaults:Suppress(folder[, reason]) -> true | false, reason
      no further defaults work on `folder` this session (restore/import code
      calls it before writing that addon's saved variables)
  Core.Defaults:ListRegistered()        -> sorted folder list

Theme tokens (see Theme.lua)
  Core.Theme:Get(token)                 -> value | nil
  Core.Theme:GetFromSet(name, token)    -> value | nil (no fallback)
  Core.Theme:GetSet()                   -> activeName, pendingName|nil
  Core.Theme:ListSets() / :ListTokens() -> sorted lists
  Core.Theme:RegisterSet(name, values)  -> number of tokens kept
  Core.Theme:SetActiveSet(name)         -> true, "applied"|"queued"|"unchanged" | false, reason
  Core.Theme:RegisterCallback(owner, fn(newName, oldName)) / :UnregisterCallback(owner)

Per-frame edit values (see Edit.lua)
  Core.Edit:Get(frameKey)               -> {[field] = resolved value}
  Core.Edit:GetEdits(frameKey)          -> stored edit values only
  Core.Edit:Set(frameKey, field, value) -> true, "applied"|"queued" | false, reason
  Core.Edit:Clear(frameKey[, field])    -> true, "applied"|"queued"|"unchanged" | false, reason
  Core.Edit:Validate(frameKey, field, value) -> true | false, reason
  Core.Edit:GetEditableItems(frameKey)  -> {[field] = registry item}
  Core.Edit:GetPending()                -> edits waiting for the end of combat
  Core.Edit:RegisterCallback(owner, fn(frameKey, field, storedValue)) / :UnregisterCallback(owner)

Layout presets (see Presets.lua; Edit:Get layers token < registry default <
active preset value < stored edit)
  Core.Presets:Register(def)            -> number of edit values and fragments kept
  Core.Presets:Restore(name)            -> true, lines | false, reason (out of
                                           combat; clears the stored edits of the
                                           preset's frames; addon fragments after
                                           /dfp go)
  Core.Presets:GetActive()              -> name|nil, registered
  Core.Presets:GetValue(frameKey, field) -> value of the active preset | nil
  Core.Presets:List() / :Get(name) / :IsRegistered(name) / :PickForScreen()
  Core.Presets:GetFragmentStatus()      -> {[preset|index] = {state, message, key}}
  Core.Edit:FireChanged(frameKey, field) -> calls the Edit listeners (preset change)

Settings save/restore (see Profiles.lua; all requests refuse in combat and
take effect at the next load, /dfp go)
  Core.Profiles:RequestSave(name)       -> true, lines | false, reason
  Core.Profiles:RequestRestore(name, [part], [onlyFolder]) -> true, lines | false, reason
                                           part: "all" | "common" | "class"
  Core.Profiles:Describe(name, [part], [onlyFolder]) -> dry-run lines
  Core.Profiles:Go() / :Cancel()        -> true | false, reason
  Core.Profiles:Delete(name, "yes")     -> true | false, reason
  Core.Profiles:List()                  -> {{name, savedAt, char, class, entries,
                                           carried, bytes, problem}}
  Core.Profiles:GetStatus()             -> {readOnly, pending, last, snapshots,
                                           maxSnapshots}
  Core.Profiles:WasFresh(svName)        -> true when the saved variable was nil at
                                           its addon's ADDON_LOADED this session
  Core.CopyData(value)                  -> plain-data copy, number of values left out
  Core.FindAceDB(svTable)               -> AceDB-3.0 database on that table | nil

Talent-group profiles (see Spec.lua; class-split saved variables, LibDualSpec)
  Core.Spec:GetState()                  -> lines
  Core.Spec:Link() / :New() / :Off()    -> true, lines | false, reason

Slash commands: /dfprofile, /dfp (see Commands.lua; /dfp help)

Status
  Core:GetStatusLog()               -> copy of the status list {{kind, subject, message}}
  Core:IsReady()                    -> true once DevilForever_CoreDB is loaded
  Core:RegisterReadyCallback(owner, fn(db)) -> fn runs at once when already ready

Callbacks
  Theme and Edit callbacks are never called while InCombatLockdown() is true:
  a set switch, a replacement of the active set, the login restore of the
  saved set and every Edit Set/Clear made in combat are held and delivered on
  PLAYER_REGEN_ENABLED. An error in one callback goes to the client error
  handler and the other callbacks still run.

Core changes no frame directly; it writes registered saved variables only at
load time: after a user command, or preset values into saved variables that are
new on disk. Appearance code reads tokens and edit values
and applies them.
]]

local _, Core = ...

local type, pairs, ipairs, sort, pcall = type, pairs, ipairs, table.sort, pcall

local lowerIndex

local function registryAddons()
  local registry = Core.Registry
  return type(registry) == "table" and type(registry.addons) == "table" and registry.addons or {}
end

local function findEntry(folder)
  if type(folder) ~= "string" then return nil end
  local addons = registryAddons()
  if addons[folder] then return folder, addons[folder] end
  if not lowerIndex then
    lowerIndex = {}
    for name in pairs(addons) do lowerIndex[name:lower()] = name end
  end
  local name = lowerIndex[folder:lower()]
  if name then return name, addons[name] end
end

local function selected(folder)
  if folder == nil then return registryAddons() end
  local name, entry = findEntry(folder)
  return name and {[name] = entry} or {}
end

function Core:ListAddons()
  local out = {}
  for name in pairs(registryAddons()) do out[#out + 1] = name end
  sort(out, function(a, b) return a:lower() < b:lower() end)
  return out
end

function Core:GetAddonInfo(folder)
  local _, entry = findEntry(folder)
  return entry and Core.CopyTable(entry) or nil
end

function Core:IsAddonLoaded(folder)
  local name = findEntry(folder) or folder
  return type(name) == "string" and Core.IsLoadedInClient(name)
end

local function collectFrames(folder, field)
  local out, seen = {}, {}
  for _, entry in pairs(selected(folder)) do
    for _, frame in ipairs(entry.frames or {}) do
      local v = frame[field]
      if type(v) == "string" and not seen[v] then
        seen[v] = true
        out[#out + 1] = v
      end
    end
  end
  sort(out)
  return out
end

function Core:GetFrameNames(folder) return collectFrames(folder, "frame") end
function Core:GetFrameKeys(folder) return collectFrames(folder, "key") end

function Core:GetSavedVariables(folder)
  local out = {}
  for name, entry in pairs(selected(folder)) do
    for _, sv in ipairs(entry.savedVariables or {}) do
      out[#out + 1] = {folder = name, name = sv.name, scope = sv.scope, split = sv.split,
                       restore = sv.restore or "skip", shape = sv.shape,
                       keys = sv.keys and Core.CopyTable(sv.keys) or nil}
    end
  end
  sort(out, function(a, b)
    if a.folder:lower() ~= b.folder:lower() then return a.folder:lower() < b.folder:lower() end
    return a.name < b.name
  end)
  return out
end

function Core:GetStatusLog() return Core.CopyTable(Core.status) end

function Core:IsReady() return Core.ready end

function Core:RegisterReadyCallback(owner, fn)
  if type(fn) ~= "function" then return false end
  if Core.ready then
    local ok, err = pcall(fn, Core.db)
    if not ok then
      local handler = type(geterrorhandler) == "function" and geterrorhandler()
      if handler then handler(err) end
    end
    return true
  end
  return Core.readyCallbacks:Register(owner, fn)
end

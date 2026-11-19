local addon = ProfileManager

local LibSerialize = LibStub("LibSerialize")
local LibDeflate   = LibStub("LibDeflate")

local GS = {}
addon.GameSettings = GS

local PAYLOAD_ID    = "PMGameSettings"
local PAYLOAD_V     = 1
local NATIVE_PREFIX = "PMGS1:"

local EXCLUDED = {
    PROXY_GX_ADAPTER = true,
    PROXY_PRIMARY_MONITOR = true,
    PROXY_GRAPHICS_API = true,
    PROXY_VOICE_INPUT_DEVICE = true,
    PROXY_VOICE_OUTPUT_DEVICE = true,
    Sound_OutputDriverIndex = true,
    PROXY_CHARACTER_SPECIFIC_BINDINGS = true,
}

local PARTICLE_VARS = { PROXY_PARTICLE_DENSITY = true, PROXY_RAID_PARTICLE_DENSITY = true }
local QUALITY_CVARS = { graphicsQuality = true, raidGraphicsQuality = true }

local function ParticleScale()
    local vo = C_VideoOptions
    if vo and vo.IsSecondaryLightingSupported and vo.IsSecondaryLightingSupported() then return "low0" end
    return "disabled0"
end

local function LocalMeta()
    return { particleScale = ParticleScale() }
end

local function Translate(map, meta)
    local from = (type(meta) == "table" and meta.particleScale) or "disabled0"
    local to = ParticleScale()
    if from == to then return map end
    local out = {}
    for k, v in pairs(map) do out[k] = v end
    for var in pairs(PARTICLE_VARS) do
        local n = tonumber(out[var])
        if n then
            if to == "low0" then n = math.max(0, n - 1) else n = n + 1 end
            out[var] = n
        end
    end
    return out
end

function GS:IsAvailable()
    return type(SettingsPanel) == "table" and type(SettingsPanel.settings) == "table"
        and Settings and type(Settings.GetSetting) == "function"
        and C_CVar and type(C_CVar.GetCVar) == "function" and type(C_CVar.SetCVar) == "function"
end

local function IsGameCategory(category)
    if type(category) ~= "table" or not category.GetCategorySet then return false end
    if Settings.CategorySet and category:GetCategorySet() ~= Settings.CategorySet.Game then return false end
    if Settings.KEYBINDINGS_CATEGORY_ID and category.GetID and category:GetID() == Settings.KEYBINDINGS_CATEGORY_ID then
        return false
    end
    return true
end

local function CategoryLabel(category)
    local parent = category.GetParentCategory and category:GetParentCategory()
    local name = category:GetName() or "?"
    if parent and parent.GetName then return parent:GetName() .. " > " .. name end
    return name
end

local function CVarState(var)
    if not C_CVar.GetCVarInfo then return nil end
    local value, _, _, _, locked, _, readOnly = C_CVar.GetCVarInfo(var)
    if value == nil then return nil end
    return value, not (locked or readOnly)
end

local current, currentVersion = nil, 0

function GS:Invalidate()
    current = nil
    currentVersion = currentVersion + 1
end

function GS:Version()
    return currentVersion
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("CVAR_UPDATE")
ev:SetScript("OnEvent", function() GS:Invalidate() end)

function GS:ReadCurrent()
    if current then return current end
    local out = {}
    for setting, category in pairs(SettingsPanel.settings) do
        local var = type(setting) == "table" and setting.GetVariable and setting:GetVariable()
        if type(var) == "string" and var:find("%S") and not EXCLUDED[var] and IsGameCategory(category) then
            local cvarValue, settable = CVarState(var)
            local value
            if cvarValue ~= nil then
                value = cvarValue
            else
                local ok, v = pcall(setting.GetValue, setting)
                if ok then value = v end
                settable = true
            end
            local t = type(value)
            if settable and (t == "string" or t == "number" or t == "boolean") then
                local okName, name = pcall(setting.GetName, setting)
                name = (okName and type(name) == "string" and name ~= "") and name or var
                local backing = type(setting.cvar) == "string" and setting.cvar or var
                if var:find("^PROXY_RAID_") or backing:find("^raid") then
                    name = name .. " (Raid)"
                end
                out[#out + 1] = {
                    var      = var,
                    value    = value,
                    cvar     = cvarValue ~= nil,
                    backing  = backing,
                    name     = name,
                    category = CategoryLabel(category),
                    order    = (setting.GetCommitOrder and setting:GetCommitOrder()) or 0,
                    vartype  = setting.GetVariableType and setting:GetVariableType(),
                }
            end
        end
    end
    table.sort(out, function(a, b)
        if a.category ~= b.category then return a.category < b.category end
        return a.name < b.name
    end)
    current = out
    return out
end

local function Norm(v)
    if v == true then return "1" end
    if v == false then return "0" end
    if type(v) == "number" then return (("%.4f"):format(v):gsub("%.?0+$", "")) end
    local n = tonumber(v)
    if n then return (("%.4f"):format(n):gsub("%.?0+$", "")) end
    return tostring(v)
end

function GS:Same(a, b)
    return Norm(a) == Norm(b)
end

function GS:Display(entry, value)
    if QUALITY_CVARS[entry.backing] and tonumber(value) then
        return tostring(math.floor(tonumber(value) + 1.5))
    end
    if entry.vartype == "boolean" or (Settings.VarType and entry.vartype == Settings.VarType.Boolean) then
        local n = Norm(value)
        return (n == "1" or n == "true") and "On" or "Off"
    end
    return Norm(value)
end

function GS:Snapshot()
    local map = {}
    for _, e in ipairs(self:ReadCurrent()) do map[e.var] = e.value end
    return map
end

local function Supported(e, value)
    if type(IsGraphicsSettingValueSupported) ~= "function" then return true end
    local setting = Settings.GetSetting(e.var)
    local cvar = setting and setting.cvar
    local n = tonumber(value)
    if type(cvar) ~= "string" or not n or QUALITY_CVARS[cvar] then return true end
    local ok, result = pcall(IsGraphicsSettingValueSupported, cvar, n, cvar:find("^raid") ~= nil)
    return not ok or result == nil or result == 0
end

function GS:Preview(map)
    local changes, known, unsupported = {}, {}, {}
    for _, e in ipairs(self:ReadCurrent()) do
        known[e.var] = true
        local want = map[e.var]
        if want ~= nil and not self:Same(e.value, want) then
            if Supported(e, want) then
                changes[#changes + 1] = { entry = e, to = want }
            else
                unsupported[#unsupported + 1] = { entry = e, to = want }
            end
        end
    end
    local missing = 0
    for var in pairs(map) do
        if not known[var] then missing = missing + 1 end
    end
    return changes, missing, unsupported
end

local function ForSetting(setting, value)
    local vt = setting.GetVariableType and setting:GetVariableType()
    if vt == "boolean" or (Settings.VarType and vt == Settings.VarType.Boolean) then
        if type(value) == "boolean" then return value end
        return Norm(value) == "1" or Norm(value) == "true"
    end
    if vt == "number" or (Settings.VarType and vt == Settings.VarType.Number) then
        return tonumber(value) or value
    end
    if type(value) == "boolean" then return value and "1" or "0" end
    return tostring(value)
end

function GS:Apply(map)
    if InCombatLockdown() then return false, "Can't change settings in combat." end
    local untouched = 0
    for _, e in ipairs(self:ReadCurrent()) do
        if map[e.var] == nil then untouched = untouched + 1 end
    end
    local changes = self:Preview(map)
    table.sort(changes, function(a, b) return a.entry.order < b.entry.order end)

    local applied, failed, failedNames = 0, 0, {}
    local gxRestart, windowUpdate, saveBindings, clientRestart = false, false, false, false
    local flags = Settings.CommitFlag or {}
    for _, c in ipairs(changes) do
        local e = c.entry
        local setting = Settings.GetSetting(e.var)
        local ok
        local now
        if e.cvar then
            ok = pcall(C_CVar.SetCVar, e.var, Norm(c.to))
            now = C_CVar.GetCVar(e.var)
        elseif setting then
            ok = pcall(setting.SetValue, setting, ForSetting(setting, c.to), true)
            local okGet, v = pcall(setting.GetValue, setting)
            now = okGet and v or nil
        end
        if ok and now ~= nil and self:Same(now, c.to) then
            applied = applied + 1
            if setting and setting.HasCommitFlag then
                gxRestart = gxRestart or (flags.GxRestart and setting:HasCommitFlag(flags.GxRestart)) or false
                windowUpdate = windowUpdate or (flags.UpdateWindow and setting:HasCommitFlag(flags.UpdateWindow)) or false
                saveBindings = saveBindings or (flags.SaveBindings and setting:HasCommitFlag(flags.SaveBindings)) or false
                clientRestart = clientRestart or (flags.ClientRestart and setting:HasCommitFlag(flags.ClientRestart)) or false
            end
        else
            failed = failed + 1
            failedNames[#failedNames + 1] = e.name
        end
    end

    if saveBindings and SaveBindings then SaveBindings(GetCurrentBindingSet()) end
    if gxRestart and RestartGx then RestartGx() end
    if windowUpdate and UpdateWindow then UpdateWindow() end
    self:Invalidate()
    return true, applied, failed, clientRestart, failedNames, untouched
end

local function NativeCodec()
    local E = C_EncodingUtil
    return E and E.SerializeCBOR and E.DeserializeCBOR and E.CompressString and E.DecompressString
        and E.EncodeBase64 and E.DecodeBase64 and E
end

function GS:Export(map, profileName, meta)
    local payload = { PAYLOAD_V, PAYLOAD_ID, profileName, map or self:Snapshot(), meta or LocalMeta() }
    local E = NativeCodec()
    if E then
        local ok, str = pcall(function()
            return E.EncodeBase64(E.CompressString(E.SerializeCBOR(payload)))
        end)
        if ok and type(str) == "string" and str ~= "" then return NATIVE_PREFIX .. str end
    end
    local ok, serialized = pcall(LibSerialize.Serialize, LibSerialize, payload)
    if not ok or type(serialized) ~= "string" then return nil, "Serialize failed" end
    local compressed = LibDeflate:CompressDeflate(serialized)
    if not compressed then return nil, "Compress failed" end
    return LibDeflate:EncodeForPrint(compressed)
end

function GS:Decode(str)
    str = strtrim(tostring(str or ""))
    if str == "" then return nil, "Paste an export string first." end
    local payload
    if str:sub(1, #NATIVE_PREFIX) == NATIVE_PREFIX then
        local E = NativeCodec()
        if not E then return nil, "This client can't read this export string." end
        local ok, p = pcall(function()
            return E.DeserializeCBOR(E.DecompressString(E.DecodeBase64(str:sub(#NATIVE_PREFIX + 1))))
        end)
        if ok then payload = p end
    else
        local decoded = LibDeflate:DecodeForPrint(str)
        local raw = decoded and LibDeflate:DecompressDeflate(decoded)
        if raw then
            local ok, success, p = pcall(LibSerialize.Deserialize, LibSerialize, raw)
            if ok and success then payload = p end
        end
    end
    if type(payload) ~= "table" then return nil, "Not a valid export string." end
    if payload[2] ~= PAYLOAD_ID then return nil, "This is not a game settings export." end
    if payload[1] ~= PAYLOAD_V then return nil, "Unsupported game settings export version." end
    if type(payload[4]) ~= "table" then return nil, "Export is missing its settings." end
    local map = {}
    for var, value in pairs(payload[4]) do
        local t = type(value)
        if type(var) == "string" and not EXCLUDED[var] and (t == "string" or t == "number" or t == "boolean") then
            map[var] = value
        end
    end
    local meta = type(payload[5]) == "table" and { particleScale = payload[5].particleScale } or nil
    return map, (type(payload[3]) == "string" and payload[3] ~= "") and payload[3] or nil, meta
end

local function Store()
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.gameSettingsProfiles = ProfileManagerDB.gameSettingsProfiles or {}
    return ProfileManagerDB.gameSettingsProfiles
end

local function CleanName(name)
    return (tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function GS:GetProfileNames()
    local out = {}
    for name in pairs(Store()) do out[#out + 1] = name end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

function GS:GetProfile(name)
    local p = Store()[name]
    if not p then return nil end
    return p, Translate(p.values or {}, p.meta)
end

function GS:UniqueProfileName(base)
    base = CleanName(base)
    if base == "" then base = "Settings" end
    local store = Store()
    if not store[base] then return base end
    local i = 2
    while store[("%s (%d)"):format(base, i)] do i = i + 1 end
    return ("%s (%d)"):format(base, i)
end

function GS:SaveProfile(name, map, meta)
    name = CleanName(name)
    if name == "" then return false, "Enter a profile name." end
    local entry = { values = map or self:Snapshot(), savedAt = time() }
    if map then entry.meta = meta else entry.meta = LocalMeta() end
    Store()[name] = entry
    return true, name
end

function GS:MatchingProfiles()
    local out = {}
    for _, name in ipairs(self:GetProfileNames()) do
        local _, map = self:GetProfile(name)
        if map and #self:Preview(map) == 0 then out[#out + 1] = name end
    end
    return out
end

function GS:UpdateProfile(name)
    local p, map = self:GetProfile(name)
    if not p then return false, "Profile not found." end
    local merged = {}
    for var, value in pairs(map) do
        if type(var) == "string" and var:find("%S") then merged[var] = value end
    end
    for var, value in pairs(self:Snapshot()) do merged[var] = value end
    return self:SaveProfile(name, merged, LocalMeta())
end

local function RetargetReferences(oldName, newName)
    local db = ProfileManagerDB
    if not db then return end
    if db.newCharSettings == oldName then db.newCharSettings = newName or "" end
    for _, cd in pairs(db.charPresets or {}) do
        if type(cd) == "table" and cd.settings == oldName then cd.settings = newName or "" end
    end
end

function GS:DeleteProfile(name)
    Store()[name] = nil
    RetargetReferences(name, nil)
end

function GS:RenameProfile(oldName, newName)
    newName = CleanName(newName)
    local store = Store()
    if newName == "" then return false, "Enter a profile name." end
    if not store[oldName] then return false, "Profile not found." end
    if newName == oldName then return true, newName end
    if store[newName] then return false, "A profile with that name already exists." end
    store[newName], store[oldName] = store[oldName], nil
    RetargetReferences(oldName, newName)
    return true, newName
end

function GS:ExportProfile(name)
    local p = Store()[name]
    if not p then return nil, "Profile not found." end
    return self:Export(p.values or {}, name, p.meta or LocalMeta())
end

function GS:LoadProfile(name)
    local p, map = self:GetProfile(name)
    if not p then return false, ("Settings profile '%s' not found."):format(tostring(name)) end
    self:Invalidate()
    return self:Apply(map)
end

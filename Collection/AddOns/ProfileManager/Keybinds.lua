local addon = ProfileManager

local LibSerialize = LibStub("LibSerialize")
local LibDeflate   = LibStub("LibDeflate")

local KB = {}
addon.Keybinds = KB

local PAYLOAD_ID    = "PMKeybinds"
local PAYLOAD_V     = 1
local NATIVE_PREFIX = "PMKB2:"

local SET_ACCOUNT   = (Enum.BindingSet and Enum.BindingSet.Account) or 1
local SET_CHARACTER = (Enum.BindingSet and Enum.BindingSet.Character) or 2

local EMPTY = {}

function KB:IsAvailable()
    return type(GetNumBindings) == "function" and type(GetBinding) == "function"
        and type(SetBinding) == "function" and type(SaveBindings) == "function"
        and type(LoadBindings) == "function" and type(GetCurrentBindingSet) == "function"
end

local function ContextFor(action)
    if C_KeyBindings and C_KeyBindings.GetBindingContextForAction then
        local ok, ctx = pcall(C_KeyBindings.GetBindingContextForAction, action)
        if ok then return ctx end
    end
    return nil
end

local function KeysFor(action, ctx)
    local k1, k2, k3 = GetBindingKey(action, nil, ctx)
    if not k1 then return EMPTY end
    local out = { k1 }
    if k2 then out[2] = k2 end
    if k3 then out[3] = k3 end
    return out
end

local current, currentVersion = nil, 0

function KB:Invalidate()
    current = nil
    currentVersion = currentVersion + 1
end

function KB:Version()
    return currentVersion
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("UPDATE_BINDINGS")
ev:SetScript("OnEvent", function() KB:Invalidate() end)

function KB:ReadCurrent()
    if current then return current end
    local out = {}
    for i = 1, GetNumBindings() do
        local action = GetBinding(i)
        if type(action) == "string" and action ~= "" and not action:find("^HEADER_") then
            out[#out + 1] = { action = action, keys = KeysFor(action, ContextFor(action)) }
        end
    end
    current = out
    return out
end

function KB:IsCharacterSet()
    return GetCurrentBindingSet() == SET_CHARACTER
end

function KB:SetName()
    return self:IsCharacterSet() and "Character" or "Account"
end

function KB:UseCharacterSet(useCharacter)
    if InCombatLockdown() then return false, "In combat" end
    if useCharacter then
        SaveBindings(SET_ACCOUNT)
        LoadBindings(SET_CHARACTER)
        SaveBindings(SET_CHARACTER)
    else
        LoadBindings(SET_ACCOUNT)
        SaveBindings(SET_ACCOUNT)
    end
    self:Invalidate()
    return true
end

local commandLabels, keyLabels = {}, {}

function KB:CommandLabel(action)
    local name = commandLabels[action]
    if name then return name end
    name = (type(GetBindingName) == "function") and GetBindingName(action) or _G["BINDING_NAME_" .. action]
    if type(name) ~= "string" or name == "" then name = action end
    commandLabels[action] = name
    return name
end

function KB:KeyLabel(key)
    local txt = keyLabels[key]
    if txt then return txt end
    txt = key
    if type(GetBindingText) == "function" then
        local ok, t = pcall(GetBindingText, key)
        if ok and type(t) == "string" and t ~= "" then txt = t end
    end
    keyLabels[key] = txt
    return txt
end

function KB:Snapshot()
    local map = {}
    for _, b in ipairs(self:ReadCurrent()) do map[b.action] = b.keys end
    return map
end

local function NativeCodec()
    local E = C_EncodingUtil
    return E and E.SerializeCBOR and E.DeserializeCBOR and E.CompressString and E.DecompressString
        and E.EncodeBase64 and E.DecodeBase64 and E
end

function KB:Export(map, profileName, setName)
    map = map or self:Snapshot()
    local binds = {}
    for action, keys in pairs(map) do
        local entry = { action }
        for _, key in ipairs(keys) do entry[#entry + 1] = key end
        binds[#binds + 1] = entry
    end
    local payload = { PAYLOAD_V, PAYLOAD_ID, setName or self:SetName(), binds, profileName }

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

local function DecodePayload(str)
    if str:sub(1, #NATIVE_PREFIX) == NATIVE_PREFIX then
        local E = NativeCodec()
        if not E then return nil, "This client can't read this export string." end
        local ok, payload = pcall(function()
            return E.DeserializeCBOR(E.DecompressString(E.DecodeBase64(str:sub(#NATIVE_PREFIX + 1))))
        end)
        if not ok or type(payload) ~= "table" then return nil, "Not a valid export string." end
        return payload
    end

    local decoded = LibDeflate:DecodeForPrint(str)
    local raw = decoded and LibDeflate:DecompressDeflate(decoded)
    if not raw then return nil, "Not a valid export string." end
    local ok, success, payload = pcall(LibSerialize.Deserialize, LibSerialize, raw)
    if not ok or not success or type(payload) ~= "table" then return nil, "Not a valid export string." end
    return payload
end

function KB:Decode(str)
    str = strtrim(tostring(str or ""))
    if str == "" then return nil, "Paste an export string first." end
    local payload, err = DecodePayload(str)
    if not payload then return nil, err end
    if payload[2] ~= PAYLOAD_ID then return nil, "This is not a keybinds export." end
    if payload[1] ~= PAYLOAD_V then return nil, "Unsupported keybinds export version." end
    if type(payload[4]) ~= "table" then return nil, "Export is missing its keybinds." end

    local map = {}
    for _, entry in ipairs(payload[4]) do
        if type(entry) == "table" and type(entry[1]) == "string" then
            local keys
            for k = 2, #entry do
                if type(entry[k]) == "string" and entry[k] ~= "" then
                    keys = keys or {}
                    keys[#keys + 1] = entry[k]
                end
            end
            map[entry[1]] = keys or EMPTY
        end
    end
    return map, tostring(payload[3] or ""), (type(payload[5]) == "string" and payload[5] ~= "") and payload[5] or nil
end

local function SameKeys(a, b)
    if #a ~= #b then return false end
    for _, key in ipairs(a) do
        if not tContains(b, key) then return false end
    end
    return true
end

local previewMap, previewVersion, previewChanges, previewMissing

function KB:Preview(map)
    if map == previewMap and previewVersion == currentVersion and current then
        return previewChanges, previewMissing
    end
    local changes, known = {}, {}
    for _, b in ipairs(self:ReadCurrent()) do
        known[b.action] = true
        local new = map[b.action]
        if new and not SameKeys(b.keys, new) then
            changes[#changes + 1] = { action = b.action, old = b.keys, new = new }
        end
    end
    local missing = 0
    for action, keys in pairs(map) do
        if not known[action] then missing = missing + #keys end
    end
    previewMap, previewVersion, previewChanges, previewMissing = map, currentVersion, changes, missing
    return changes, missing
end

function KB:Import(map)
    if InCombatLockdown() then return false, "Can't change keybinds in combat." end
    if type(map) ~= "table" then return false, "Nothing to import." end

    local list = self:ReadCurrent()

    local untouched = 0
    for _, b in ipairs(list) do
        if map[b.action] == nil and #b.keys > 0 then untouched = untouched + 1 end
    end

    for _, b in ipairs(list) do
        if map[b.action] then
            local ctx = ContextFor(b.action)
            for _, key in ipairs(b.keys) do SetBinding(key, nil, ctx) end
        end
    end

    local applied, failed = 0, 0
    for _, b in ipairs(list) do
        local keys = map[b.action]
        if keys then
            local ctx = ContextFor(b.action)
            for _, key in ipairs(keys) do
                if SetBinding(key, b.action, ctx) then
                    applied = applied + 1
                else
                    failed = failed + 1
                end
            end
        end
    end

    SaveBindings(GetCurrentBindingSet())
    self:Invalidate()
    return true, applied, failed, untouched
end

local function Store()
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.keybindProfiles = ProfileManagerDB.keybindProfiles or {}
    return ProfileManagerDB.keybindProfiles
end

local function CleanName(name)
    return (tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function Pack(map)
    local bound, unbound = {}, {}
    for action, keys in pairs(map) do
        if #keys > 0 then
            bound[action] = table.concat(keys, "\t")
        else
            unbound[#unbound + 1] = action
        end
    end
    return bound, table.concat(unbound, "\t")
end

local expanded = setmetatable({}, { __mode = "k" })

local function Unpack(p)
    local map = expanded[p]
    if map then return map end
    map = {}
    for action, str in pairs(p.bound or {}) do
        local keys = {}
        for key in str:gmatch("[^\t]+") do keys[#keys + 1] = key end
        map[action] = keys
    end
    for action in (p.unbound or ""):gmatch("[^\t]+") do map[action] = EMPTY end
    expanded[p] = map
    return map
end

function KB:GetProfileNames()
    local out = {}
    for name in pairs(Store()) do out[#out + 1] = name end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

function KB:GetProfile(name)
    local p = Store()[name]
    if not p then return nil end
    return p, Unpack(p)
end

function KB:UniqueProfileName(base)
    base = CleanName(base)
    if base == "" then base = "Keybinds" end
    local store = Store()
    if not store[base] then return base end
    local i = 2
    while store[("%s (%d)"):format(base, i)] do i = i + 1 end
    return ("%s (%d)"):format(base, i)
end

function KB:SaveProfile(name, map, setName)
    name = CleanName(name)
    if name == "" then return false, "Enter a profile name." end
    local bound, unbound = Pack(map or self:Snapshot())
    Store()[name] = {
        bound   = bound,
        unbound = unbound,
        set     = setName or self:SetName(),
        savedAt = time(),
    }
    return true, name
end

function KB:UpdateProfile(name)
    local p, map = self:GetProfile(name)
    if not p then return false, "Profile not found." end
    local merged = {}
    for action, keys in pairs(map) do merged[action] = keys end
    for action, keys in pairs(self:Snapshot()) do merged[action] = keys end
    return self:SaveProfile(name, merged, self:SetName())
end

local function RetargetReferences(oldName, newName)
    local db = ProfileManagerDB
    if not db then return end
    if db.newCharKeybinds == oldName then db.newCharKeybinds = newName or "" end
    for _, cd in pairs(db.charPresets or {}) do
        if type(cd) == "table" and cd.keybinds == oldName then cd.keybinds = newName or "" end
    end
end

function KB:DeleteProfile(name)
    Store()[name] = nil
    RetargetReferences(name, nil)
end

function KB:RenameProfile(oldName, newName)
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

function KB:ExportProfile(name)
    local p, map = self:GetProfile(name)
    if not p then return nil, "Profile not found." end
    return self:Export(map, name, p.set)
end

function KB:LoadProfile(name)
    local p, map = self:GetProfile(name)
    if not p then return false, ("Keybind profile '%s' not found."):format(tostring(name)) end
    self:Invalidate()
    return self:Import(map)
end

function KB:MatchingProfiles()
    local out = {}
    for _, name in ipairs(self:GetProfileNames()) do
        local _, map = self:GetProfile(name)
        local changes = map and self:Preview(map)
        if changes and #changes == 0 then out[#out + 1] = name end
    end
    return out
end

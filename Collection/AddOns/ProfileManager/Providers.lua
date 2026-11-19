local addon = ProfileManager
addon.Providers = addon.Providers or {}
addon.RegisterProvider = addon.RegisterProvider or function(self, id, provider)
    self.Providers = self.Providers or {}
    self.Providers[id] = provider
end

local AceDB = LibStub("AceDB-3.0")
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local StripHyperlinks = (C_StringUtil and C_StringUtil.StripHyperlinks) or StripHyperlinks
local function CharKey(db)
    if type(db) == "table" and type(db.keys) == "table" and type(db.keys.char) == "string" then
        return db.keys.char
    end
    for registered in pairs(AceDB.db_registry or {}) do
        if type(registered) == "table" and type(registered.keys) == "table" and type(registered.keys.char) == "string" then
            return registered.keys.char
        end
    end
    if RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled() and UnitNameUnmodified then
        local name, surname = UnitNameUnmodified("player")
        if name and surname then return name .. " " .. surname end
    end
    return UnitName("player") .. " - " .. GetRealmName()
end

function addon:CharacterProfileKey(providerId)
    local prov = self.Providers and self.Providers[providerId]
    return CharKey(type(prov) == "table" and prov.db or nil)
end
local DEFAULT_OPTION_KEY = "Default"

local PM_PRIV_PREFIX = "\1priv\1"
addon.PM_PRIV_PREFIX = PM_PRIV_PREFIX

local function PM_IsPrivateId(id)
    return type(id) == "string" and id:sub(1, #PM_PRIV_PREFIX) == PM_PRIV_PREFIX
end

local function PM_StripPrivatePrefix(id)
    if PM_IsPrivateId(id) then
        return id:sub(#PM_PRIV_PREFIX + 1), true
    end
    return id, false
end

local V = 1

local function PM_Encode(payloadArray)
    local okS, serialized = pcall(LibSerialize.Serialize, LibSerialize, payloadArray)
    if not okS or type(serialized) ~= "string" or serialized == "" then
        return nil, "LibSerialize serialize failed"
    end

    local compressed = LibDeflate:CompressDeflate(serialized, { level = 9 })
    if not compressed then
        return nil, "Compress failed"
    end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    if type(encoded) ~= "string" or encoded == "" then
        return nil, "Encode failed"
    end

    return encoded
end

local function PM_Decode(str)
    if type(str) ~= "string" or str == "" then
        return nil, "Missing string"
    end

    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then
        return nil, "Decode failed"
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return nil, "Decompress failed"
    end

    local okD, success, payload = pcall(LibSerialize.Deserialize, LibSerialize, decompressed)
    if not okD or not success or type(payload) ~= "table" then
        return nil, "Deserialize failed"
    end

    if payload[1] ~= V then
        return nil, "Bad version"
    end

    return payload
end

local function MakeSerializableCopy(src, seen)
    local t = type(src)
    if t == "number" or t == "string" or t == "boolean" or t == "nil" then
        return src
    end
    if t ~= "table" then
        return nil
    end

    seen = seen or {}
    if seen[src] then
        return nil
    end
    seen[src] = true

    local out = {}
    for k, v in pairs(src) do
        local kk = MakeSerializableCopy(k, seen)
        if kk ~= nil then
            local vv = MakeSerializableCopy(v, seen)
            if vv ~= nil then
                out[kk] = vv
            end
        end
    end

    seen[src] = nil
    return out
end

local function TryDecodeRaw(str)
    if type(str) ~= "string" or str == "" then return nil end

    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then return nil end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return nil end

    local ok, success, payload = pcall(LibSerialize.Deserialize, LibSerialize, decompressed)
    if not ok or not success or type(payload) ~= "table" then return nil end

    return payload
end

local function DeepCopy_NoCycles(src)
    if type(src) ~= "table" then return src end
    local out = {}
    for k, v in pairs(src) do
        out[DeepCopy_NoCycles(k)] = DeepCopy_NoCycles(v)
    end
    return out
end

local function WipeAndCopy(dest, src)
    if type(dest) ~= "table" or type(src) ~= "table" then return end
    for k in pairs(dest) do dest[k] = nil end
    for k, v in pairs(src) do
        dest[k] = (type(v) == "table") and DeepCopy_NoCycles(v) or v
    end
end

local function WantActivate(maybeOpts)
    if type(maybeOpts) == "boolean" then return maybeOpts end
    if type(maybeOpts) == "table" and maybeOpts.activate ~= nil then return not not maybeOpts.activate end
    return false
end

local function MakeUniqueKeyName(tbl, baseName)
    baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if baseName == "" then baseName = "Imported" end

    tbl = (type(tbl) == "table") and tbl or {}

    if tbl[baseName] == nil then
        return baseName
    end

    local i = 2
    while true do
        local candidate = string.format("%s (%d)", baseName, i)
        if tbl[candidate] == nil then
            return candidate
        end
        i = i + 1
    end
end

local function ExportProfile_Table(providerId, profilesTable, profileName)
    if type(profileName) ~= "string" or profileName == "" then
        return nil, "No profile selected."
    end
    if type(profilesTable) ~= "table" then
        return nil, "Profiles table not found."
    end

    local profileTable = profilesTable[profileName]
    if profileTable == nil then profileTable = {} end
    if type(profileTable) ~= "table" then
        return nil, "Profile data is not a table."
    end

    local safeCopy = MakeSerializableCopy(profileTable) or {}
    return PM_Encode({ V, tostring(providerId or ""), profileName, safeCopy })
end

local function ImportProfile_Table(expectedProviderId, profilesTable, serializedString, desiredBaseName)
    if type(profilesTable) ~= "table" then return false, "Profiles table not found." end
    if type(serializedString) ~= "string" or serializedString == "" then return false, "Missing import string" end

    local data, baseName

    local payload, err = PM_Decode(serializedString)
    if payload then
        local srcProvider = tostring(payload[2] or "")
        local expected = tostring(expectedProviderId or "")
        if srcProvider ~= expected then
            return false, ("Wrong provider (got '%s', expected '%s')"):format(srcProvider, expected)
        end

        data = payload[4]
        if type(data) ~= "table" then
            return false, "Import payload missing data."
        end

        baseName = tostring(desiredBaseName or payload[3] or "Imported")
    else
        local native = TryDecodeRaw(serializedString)
        if type(native) ~= "table" then
            return false, err or "Bad import string"
        end
        data = native
        baseName = tostring(desiredBaseName or "Imported")
    end

    local newName = MakeUniqueKeyName(profilesTable, baseName)
    profilesTable[newName] = data
    return true, newName
end

local function MakeUniqueProfileName(db, baseName)
    baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if baseName == "" then baseName = "Imported" end

    db.sv.profiles = db.sv.profiles or {}

    if db.sv.profiles[baseName] == nil then
        return baseName
    end

    local i = 2
    while true do
        local candidate = string.format("%s (%d)", baseName, i)
        if db.sv.profiles[candidate] == nil then
            return candidate
        end
        i = i + 1
    end
end

local function ResolveAceDBProfileName(db, selectedName)
    if type(selectedName) ~= "string" or selectedName == "" then return nil end
    db.sv = db.sv or {}
    db.sv.profileKeys = db.sv.profileKeys or {}

    local charKey = CharKey(db)
    if selectedName == charKey or selectedName == DEFAULT_OPTION_KEY then
        return db.sv.profileKeys[charKey] or "Default"
    end

    return selectedName
end

local function ExportProfile_AceDB(db, providerId, selectedName)
    if not db or not db.sv then return nil, "DB missing sv" end

    local resolved = ResolveAceDBProfileName(db, selectedName)
    if type(resolved) ~= "string" or resolved == "" then
        return nil, "No profile selected."
    end

    db.sv.profiles = db.sv.profiles or {}
    local root = db.sv.profiles[resolved]
    if type(root) ~= "table" then root = {} end

    local namespacesOut = nil
    if type(db.sv.namespaces) == "table" then
        for nsName, nsTbl in pairs(db.sv.namespaces) do
            if type(nsName) == "string" and type(nsTbl) == "table" then
                local p = nsTbl.profiles
                if type(p) == "table" then
                    local nsProfile = p[resolved]
                    if type(nsProfile) == "table" then
                        namespacesOut = namespacesOut or {}
                        namespacesOut[nsName] = MakeSerializableCopy(nsProfile) or {}
                    end
                end
            end
        end
    end

    return PM_Encode({
        V,
        tostring(providerId or ""),
        resolved,
        MakeSerializableCopy(root) or {},
        namespacesOut,
    })
end

local function ImportProfile_AceDB(db, expectedProviderId, serializedString, desiredBaseName)
    if not db or not db.sv then return false, "DB missing sv" end
    if type(serializedString) ~= "string" or serializedString == "" then return false, "Missing import string" end

    local rootProfile, nsProfiles, baseName

    local payload, err = PM_Decode(serializedString)
    if payload then
        local srcProvider = tostring(payload[2] or "")
        local expected = tostring(expectedProviderId or "")
        if srcProvider ~= expected then
            return false, ("Wrong provider (got '%s', expected '%s')"):format(srcProvider, expected)
        end

        rootProfile = payload[4]
        if type(rootProfile) ~= "table" then
            return false, "Import payload missing profile data"
        end

        nsProfiles = payload[5]
        if nsProfiles ~= nil and type(nsProfiles) ~= "table" then
            nsProfiles = nil
        end

        baseName = tostring(desiredBaseName or payload[3] or "Imported")
    else
       local native = TryDecodeRaw(serializedString)
        if type(native) ~= "table" then
            return false, err or "Bad import string"
        end
        rootProfile = native
        baseName = tostring(desiredBaseName or "Imported")
    end

    db.sv.profiles = db.sv.profiles or {}
    local newName = MakeUniqueProfileName(db, baseName)

    db.sv.profiles[newName] = rootProfile

    if nsProfiles then
        db.sv.namespaces = db.sv.namespaces or {}
        for nsName, nsData in pairs(nsProfiles) do
            if type(nsName) == "string" and type(nsData) == "table" then
                local nsTbl = db.sv.namespaces[nsName]
                if type(nsTbl) ~= "table" then
                    nsTbl = {}
                    db.sv.namespaces[nsName] = nsTbl
                end
                nsTbl.profiles = nsTbl.profiles or {}
                nsTbl.profiles[newName] = nsData
            end
        end
    end

    return true, newName
end

local function DeleteProfile_Table(profilesTable, profileName)
    if type(profilesTable) ~= "table" then return false end
    if type(profileName) ~= "string" or profileName == "" then return false end

    if profilesTable[profileName] ~= nil then
        profilesTable[profileName] = nil
        return true
    end

    return false
end

local function SortAddons(a, b)
    a = StripHyperlinks and StripHyperlinks(a) or tostring(a)
    b = StripHyperlinks and StripHyperlinks(b) or tostring(b)
    return strcmputf8i(a, b) < 0
end

local function SortLower(list)
    if type(list) ~= "table" then return {} end
    table.sort(list, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
    return list
end

local function KeysToSortedArray(tbl)
    local out = {}
    if type(tbl) ~= "table" then return out end
    for k in pairs(tbl) do
        if type(k) == "string" and k ~= "" then
            out[#out + 1] = k
        end
    end
    return SortLower(out)
end

local function ProfileExists(list, wanted)
    if type(list) ~= "table" then return false end
    wanted = tostring(wanted or "")
    for _, name in ipairs(list) do
        if name == wanted then return true end
    end
    return false
end

local function Detect_DBOrLoaded(svName, addonName)
    if svName and _G[svName] ~= nil then return true end
    if addonName and C_AddOns and C_AddOns.GetAddOnInfo then
        local _, _, _, enabled = C_AddOns.GetAddOnInfo(addonName)
        return enabled
    end
    return false
end

local function DotColonSafeGetter(fn)
    return function(selfOrNil, ...)
        return fn(...)
    end
end

local function DotColonSafeSetter(fn)
    return function(selfOrProfile, maybeProfile)
        local profile = (type(selfOrProfile) == "table") and maybeProfile or selfOrProfile
        return fn(profile)
    end
end

addon._aceDbResultCache = addon._aceDbResultCache or {}
function addon:FindGlobal(item)
    if not self._aceDbResultCache[item] then
        for k, v in pairs(_G) do
            if v == item then
                self._aceDbResultCache[item] = k
                break
            end
        end
    end
    return self._aceDbResultCache[item]
end

function addon:IsBlacklistedDB(db)
    for minor = 15, 100 do
        if db.sv == _G[("LibDualSpec-1.0-%d test"):format(minor)] then
            return true
        end
    end
    return false
end

addon._aceDbAddonNameCache = addon._aceDbAddonNameCache or {}
function addon:GetAddonNameForDB(db)
    if self._aceDbAddonNameCache[db] then
        return self._aceDbAddonNameCache[db]
    end

    local _, svGlobalName = issecurevariable(db, "sv")
    local title

    if C_AddOns and C_AddOns.GetAddOnInfo then
        local _, t = C_AddOns.GetAddOnInfo(svGlobalName)
        title = t
    elseif GetAddOnInfo then
        local _, t = GetAddOnInfo(svGlobalName)
        title = t
    end

    local name = title or svGlobalName or "Unknown"
    self._aceDbAddonNameCache[db] = name
    return name
end

local function GetProfiles_AceDB(db)
    local out, seen = {}, {}

    if type(db.GetProfiles) == "function" then
        local ok, list = pcall(function() return db:GetProfiles() end)
        if ok and type(list) == "table" then
            for k, v in pairs(list) do
                local name = (type(k) == "number") and v or k
                if type(name) == "string" and name ~= "" and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = name
                end
            end
        end
    end

    if type(db.sv) == "table" and type(db.sv.profiles) == "table" then
        for name in pairs(db.sv.profiles) do
            if type(name) == "string" and name ~= "" and not seen[name] then
                seen[name] = true
                out[#out + 1] = name
            end
        end
    end

    local charKey = CharKey(db)
    if not seen[DEFAULT_OPTION_KEY] then out[#out + 1] = DEFAULT_OPTION_KEY end
    if not seen[charKey] then out[#out + 1] = charKey end

    table.sort(out, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
    return out
end

local function GetCurrentProfile_AceDB(db)
    if type(db.GetCurrentProfile) == "function" then
        local ok, cur = pcall(function() return db:GetCurrentProfile() end)
        if ok and type(cur) == "string" and cur ~= "" then
            return cur
        end
    end
    if type(db.sv) == "table" and type(db.sv.profileKeys) == "table" then
        local cur = db.sv.profileKeys[CharKey(db)]
        if type(cur) == "string" and cur ~= "" then
            return cur
        end
    end
    return nil
end

local function SetProfile_AceDB(db, profileName)
    if InCombatLockdown() then return false end
    if type(profileName) ~= "string" or profileName == "" then return false end

    if type(db.SetProfile) == "function" then
        local ok = pcall(function() db:SetProfile(profileName) end)
        return ok
    end

    if type(db.sv) == "table" then
        db.sv.profileKeys = db.sv.profileKeys or {}
        db.sv.profileKeys[CharKey(db)] = profileName
        return true
    end

    return false
end

local function MakeAceDBScanProvider(id, name, db)
    local p = { displayName = name, _isAceDBScan = true, db = db }

    p.GetProfiles       = DotColonSafeGetter(function() return GetProfiles_AceDB(db) end)
    p.GetCurrentProfile = DotColonSafeGetter(function() return GetCurrentProfile_AceDB(db) end)

    p.SetProfile   = DotColonSafeSetter(function(profile) return SetProfile_AceDB(db, profile) end)
    p.ApplyProfile = p.SetProfile

    p.DeleteProfile = function(_, profileName)
        if not db or not db.sv or not db.sv.profiles then return false end

        local current = GetCurrentProfile_AceDB(db)
        if current == profileName then
            return false, "Cannot delete active profile"
        end

        if db.sv.profiles[profileName] then
            db.sv.profiles[profileName] = nil
            return true
        end

        return false
    end

    p.ExportProfile = function(_, profileName)
        return ExportProfile_AceDB(db, id, profileName)
    end

    p.ImportProfile = function(_, serialized, desiredBaseName, opts)
        if InCombatLockdown() then return false, "In combat" end

        local ok, newNameOrErr = ImportProfile_AceDB(db, id, serialized, desiredBaseName)
        if not ok then return false, newNameOrErr end
        local newName = newNameOrErr

        if WantActivate(opts) then
            if type(db.SetProfile) == "function" then
                pcall(function() db:SetProfile(newName) end)
            else
                if type(db.sv) == "table" then
                    db.sv.profileKeys = db.sv.profileKeys or {}
                    db.sv.profileKeys[CharKey(db)] = newName
                end
            end
        end

        return true, newName
    end
    return p
end

addon.ProviderDefs = addon.ProviderDefs or {}

function addon:RegisterProviderDef(def)
    if type(def) ~= "table" or type(def.id) ~= "string" or def.id == "" then
        return false
    end
    self.ProviderDefs[def.id] = def
    return true
end

function addon:TryRegisterProvider(id)
    if self.Providers and self.Providers[id] then
        return true
    end

    local def = self.ProviderDefs and self.ProviderDefs[id]
    if not def then return false end

    local okDetect, available = pcall(def.detect)
    if not okDetect or not available then return false end

    local okBuild, provider = pcall(def.buildProvider)
    if not okBuild or type(provider) ~= "table" then return false end

    self:RegisterProvider(def.id, provider)
    return true
end

addon:RegisterProviderDef({
    id = "Chattynator",
    detect = function() return Detect_DBOrLoaded("CHATTYNATOR_CONFIG", "Chattynator") end,
    buildProvider = function()
        local function ProfilesTable()
            return _G.CHATTYNATOR_CONFIG and _G.CHATTYNATOR_CONFIG.Profiles
        end

        return {
            displayName = "Chattynator",

            GetProfiles = DotColonSafeGetter(function()
                return KeysToSortedArray(ProfilesTable())
            end),

            GetCurrentProfile = DotColonSafeGetter(function()
                local cur = _G.CHATTYNATOR_CURRENT_PROFILE
                return (type(cur) == "string" and cur ~= "") and cur or "DEFAULT"
            end),

            ApplyProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end
                local profiles = ProfilesTable()
                if type(profiles) ~= "table" or profiles[profileName] == nil then return false end
                _G.CHATTYNATOR_CURRENT_PROFILE = profileName
                return true
            end),

            SetProfile = DotColonSafeSetter(function(profileName)
                return (ProfileManager and ProfileManager.Providers and ProfileManager.Providers.Chattynator
                    and ProfileManager.Providers.Chattynator.ApplyProfile and ProfileManager.Providers.Chattynator:ApplyProfile(profileName)) or false
            end),

            ExportProfile = function(_, profileName)
                local profiles = ProfilesTable()
                return ExportProfile_Table("Chattynator", profiles, profileName)
            end,
            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end

                local profiles = ProfilesTable()
                local ok, newNameOrErr = ImportProfile_Table("Chattynator", profiles, serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end

                if WantActivate(opts) then
                    _G.CHATTYNATOR_CURRENT_PROFILE = newNameOrErr
                end

                return true, newNameOrErr
            end,
            DeleteProfile = function(_, profileName)
                local profiles = ProfilesTable()
                if not profiles then return false end

                if _G.CHATTYNATOR_CURRENT_PROFILE == profileName then
                    return false, "Cannot delete active profile"
                end

                return DeleteProfile_Table(profiles, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "Details",
    detect = function()
        local D = _G._detalhes or _G.Details
        return D ~= nil and _G._detalhes_global ~= nil and type(_G._detalhes_global.__profiles) == "table"
    end,
    buildProvider = function()
        local D = _G._detalhes or _G.Details
        if not D then return nil end

        local function GetProfilesTable()
            local g = _G._detalhes_global
            return g and g.__profiles
        end

        local function NormalizeProfilesToArray(profiles)
            local out = {}
            if type(profiles) ~= "table" then return out end
            for k, v in pairs(profiles) do
                if type(k) == "number" then
                    if type(v) == "string" then out[#out + 1] = v end
                else
                    if type(k) == "string" then out[#out + 1] = k end
                end
            end
            return SortLower(out)
        end

        local function GetProfilesList()
            if type(D.GetProfileList) == "function" then
                local ok, list = pcall(function() return D:GetProfileList() end)
                if ok then
                    return NormalizeProfilesToArray(list)
                end
            end
            return KeysToSortedArray(GetProfilesTable())
        end

        local function GetCurrentProfile()
            if type(D.GetCurrentProfileName) == "function" then
                local ok, cur = pcall(function() return D:GetCurrentProfileName() end)
                if ok and type(cur) == "string" and cur ~= "" then return cur end
            end

            local db = _G._detalhes_database
            if type(db) == "table" and type(db.active_profile) == "string" and db.active_profile ~= "" then
                return db.active_profile
            end

            return nil
        end

        local function ApplyProfile(profileName)
            if InCombatLockdown() then return false end
            if type(profileName) ~= "string" or profileName == "" then return false end

            local profiles = GetProfilesTable()
            if type(profiles) == "table" and profiles[profileName] == nil then
                local list = GetProfilesList()
                if #list > 0 and not ProfileExists(list, profileName) then
                    return false
                end
            end

            if type(D.ApplyProfile) == "function" then
                local ok = pcall(function() D:ApplyProfile(profileName, true) end)
                return ok
            end

            local db = _G._detalhes_database
            if type(db) == "table" then
                db.active_profile = profileName
                return true
            end

            return false
        end

        local function ExportProfile_Details(profileName, fmt)
            local profiles = GetProfilesTable()
            if type(profiles) ~= "table" then
                return nil, "Details profiles table not found."
            end
            if type(profileName) ~= "string" or profileName == "" then
                return nil, "No profile selected."
            end

            local profileTable = profiles[profileName]
            if type(profileTable) ~= "table" then
                return nil, "Profile not found."
            end

            if fmt ~= "pm" then
                if profileName == GetCurrentProfile() and type(D.ExportCurrentProfile) == "function" then
                    local ok, nativeStr = pcall(function() return D:ExportCurrentProfile() end)
                    if ok and type(nativeStr) == "string" and nativeStr ~= "" then
                        return nativeStr
                    end
                end
                if fmt == "native" then
                    return nil, "Details can only native-export the ACTIVE profile. Apply it first, or use the ProfileManager format."
                end
            end

            local safeCopy = MakeSerializableCopy(profileTable) or {}
            return PM_Encode({ V, "Details", profileName, safeCopy })
        end

        local function MakeUniqueDetailsProfileName(baseName)
            baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if baseName == "" then baseName = "Imported" end

            local profiles = GetProfilesTable()
            profiles = (type(profiles) == "table") and profiles or {}

            if profiles[baseName] == nil then
                return baseName
            end

            local i = 2
            while true do
                local candidate = string.format("%s (%d)", baseName, i)
                if profiles[candidate] == nil then
                    return candidate
                end
                i = i + 1
            end
        end

        local function ImportDetails_Native(nativeStr, newName, opts)
            if type(D.ImportProfile) ~= "function" then
                return nil, "Details:ImportProfile not available"
            end
            if WantActivate(opts) then
                local ok = pcall(function() D:ImportProfile(nativeStr, newName) end)
                if not ok then return nil, "Details:ImportProfile failed" end
                return newName
            else
                if type(D.DecompressData) ~= "function" then
                    return nil, "Details:DecompressData not available"
                end
                local ok, dataTable = pcall(function() return D:DecompressData(nativeStr, "print") end)
                if not ok or type(dataTable) ~= "table" then
                    return nil, "Failed to decode Details native string"
                end
                local profileData = dataTable.profile
                if type(profileData) ~= "table" then
                    return nil, "No profile data in Details string"
                end
                local profiles = GetProfilesTable()
                if type(profiles) ~= "table" then
                    return nil, "Details profiles table not found."
                end
                profiles[newName] = MakeSerializableCopy(profileData) or {}
                return newName
            end
        end

        local function ImportProfile_Details(serializedString, desiredBaseName, opts)
            if type(serializedString) ~= "string" or serializedString == "" then
                return false, "Missing import string"
            end

            local payload, pmErr = PM_Decode(serializedString)
            if payload then
                if tostring(payload[2] or "") ~= "Details" then return false, "Wrong provider" end

                local innerData = payload[4]
                local baseName  = tostring(desiredBaseName or payload[3] or "Imported")
                local newName   = MakeUniqueDetailsProfileName(baseName)

                if type(innerData) == "string" then
                    local result, nErr = ImportDetails_Native(innerData, newName, opts)
                    if not result then return false, nErr or "Failed to import native Details string" end
                    return true, result
                elseif type(innerData) == "table" then
                    local profiles = GetProfilesTable()
                    if type(profiles) ~= "table" then
                        return false, "Details profiles table not found."
                    end
                    profiles[newName] = innerData
                    if WantActivate(opts) then ApplyProfile(newName) end
                    return true, newName
                else
                    return false, "Missing data"
                end
            end

            local newName = MakeUniqueDetailsProfileName(tostring(desiredBaseName or "Imported"))
            local result = ImportDetails_Native(serializedString, newName, opts)
            if result then return true, result end

            local native = TryDecodeRaw(serializedString)
            if type(native) == "table" then
                local profiles = GetProfilesTable()
                if type(profiles) ~= "table" then
                    return false, "Details profiles table not found."
                end
                local fbName = MakeUniqueDetailsProfileName(tostring(desiredBaseName or "Imported"))
                profiles[fbName] = native
                if WantActivate(opts) then ApplyProfile(fbName) end
                return true, fbName
            end

            return false, pmErr or "Bad import string"
        end

        return {
            displayName = "Details!",
            GetProfiles = DotColonSafeGetter(GetProfilesList),
            GetCurrentProfile = DotColonSafeGetter(GetCurrentProfile),
            ApplyProfile = DotColonSafeSetter(ApplyProfile),
            SetProfile = DotColonSafeSetter(ApplyProfile),

            nativeExport = true,
            ExportProfile = function(_, profileName, fmt)
                return ExportProfile_Details(profileName, fmt)
            end,
            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                return ImportProfile_Details(serialized, desiredBaseName, opts)
            end,
            DeleteProfile = function(_, profileName)
                local profiles = GetProfilesTable()
                if not profiles then return false end

                if GetCurrentProfile() == profileName then
                    return false, "Cannot delete active profile"
                end

                return DeleteProfile_Table(profiles, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "BlizzardEditMode",
    detect = function() return C_EditMode and type(C_EditMode.GetLayouts) == "function" end,
    buildProvider = function()
        local function GetLayoutsData()
            local data = C_EditMode.GetLayouts()
            return (type(data) == "table") and data or nil
        end

        local function GetCustomLayoutsList()
            local data = GetLayoutsData()
            return data and (data.layouts or data) or nil
        end

        local function GetCustomNames()
            local list = GetCustomLayoutsList()
            if type(list) ~= "table" then return {} end
            local out = {}
            for _, v in pairs(list) do
                if type(v) == "table" then
                    local name = v.layoutName or v.name or v.displayName or v.title
                    if name and tostring(name) ~= "" then out[#out + 1] = tostring(name) end
                end
            end
            return SortLower(out)
        end

        local function FindCustomLayoutInfoByName(targetName)
            local list = GetCustomLayoutsList()
            if type(list) ~= "table" then return nil end
            local target = tostring(targetName or ""):lower()
            for _, v in pairs(list) do
                if type(v) == "table" then
                    local name = v.layoutName or v.name or v.displayName or v.title
                    if name and tostring(name):lower() == target then
                        return v
                    end
                end
            end
            return nil
        end

        local function FindCustomIndexByName(targetName)
            local list = GetCustomLayoutsList()
            if type(list) ~= "table" then return nil end
            local target = tostring(targetName or ""):lower()
            for idx, v in ipairs(list) do
                if type(v) == "table" then
                    local name = v.layoutName or v.name or v.displayName or v.title
                    if name and tostring(name):lower() == target then
                        return idx
                    end
                end
            end
            return nil
        end

        local function SetActiveLayoutIndex(activeIndex)
            if InCombatLockdown() then return false end
            if type(C_EditMode.SetActiveLayout) == "function" then
                C_EditMode.SetActiveLayout(activeIndex); return true
            end
            if type(C_EditMode.SetActiveLayoutIndex) == "function" then
                C_EditMode.SetActiveLayoutIndex(activeIndex); return true
            end
            return false
        end

        local function MakeUniqueLayoutName(baseName)
            baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if baseName == "" then baseName = "Imported" end

            local existing = {}
            for _, n in ipairs(GetCustomNames()) do existing[n:lower()] = true end
            if not existing[baseName:lower()] then return baseName end

            local i = 2
            while true do
                local cand = string.format("%s (%d)", baseName, i)
                if not existing[cand:lower()] then return cand end
                i = i + 1
            end
        end

        local function MakeUniquePMDefaultName()
            return MakeUniqueLayoutName("PM_Layout")
        end

        local function EnumName(enumTable, value)
            if type(enumTable) ~= "table" then return nil end
            for k, v in pairs(enumTable) do
                if v == value then return k end
            end
        end

        local function PresetLayouts()
            local out = {}
            local mgr = _G.EditModePresetLayoutManager
            local list = mgr and mgr.presetLayoutInfo
            if type(list) == "table" then
                for i, info in ipairs(list) do
                    out[i] = {
                        name = EnumName(Enum.EditModePresetLayouts, info.layoutIndex) or tostring(info.layoutName or i),
                        style = info.interfaceStyle,
                    }
                end
            end
            if #out == 0 then
                out[1] = { name = "Modern" }
                out[2] = { name = "Classic" }
            end
            return out
        end

        local function PresetIndexByName(name)
            local lower = tostring(name or ""):lower()
            for i, p in ipairs(PresetLayouts()) do
                if p.name:lower() == lower then return i end
            end
        end

        local function PresetVisible(p)
            if p.style == nil then return true end
            if not (InputUtil and InputUtil.GetCurrentInterfaceStyle) then return true end
            local ok, style = pcall(InputUtil.GetCurrentInterfaceStyle)
            return not ok or style == p.style
        end

        local function CopyAnchor(a)
            if type(a) ~= "table" then return nil end
            return { point = a.point, relativeTo = a.relativeTo, relativePoint = a.relativePoint,
                     offsetX = a.offsetX, offsetY = a.offsetY }
        end

        local function ToPortable(info)
            local systems = {}
            for _, sys in ipairs(info.systems or {}) do
                local sysName = EnumName(Enum.EditModeSystem, sys.system)
                if sysName then
                    local settingEnum = Enum["EditMode" .. sysName .. "Setting"]
                    local indexEnum = Enum["EditMode" .. sysName .. "SystemIndices"]
                    local settings = {}
                    for _, st in ipairs(sys.settings or {}) do
                        settings[#settings + 1] = { EnumName(settingEnum, st.setting) or st.setting, st.value }
                    end
                    systems[#systems + 1] = {
                        system   = sysName,
                        index    = sys.systemIndex and (EnumName(indexEnum, sys.systemIndex) or sys.systemIndex),
                        anchor   = CopyAnchor(sys.anchorInfo),
                        anchor2  = CopyAnchor(sys.anchorInfo2),
                        default  = sys.isInDefaultPosition and true or false,
                        settings = settings,
                    }
                end
            end
            return { name = info.layoutName, systems = systems }
        end

        local function ModernSystems()
            local mgr = _G.EditModePresetLayoutManager
            if not (mgr and mgr.GetCopyOfPresetLayouts) then return nil end
            local ok, presets = pcall(mgr.GetCopyOfPresetLayouts, mgr)
            if not ok or type(presets) ~= "table" then return nil end
            local modern = presets[1]
            for _, l in ipairs(presets) do
                if Enum.EditModePresetLayouts and l.layoutIndex == Enum.EditModePresetLayouts.Modern then modern = l end
            end
            return modern and modern.systems
        end

        local function FillFromModern(layout)
            local modern = ModernSystems()
            if not modern then return end
            local have = {}
            for _, sys in ipairs(layout.systems) do
                have[sys.system .. ":" .. tostring(sys.systemIndex)] = sys
            end
            for _, def in ipairs(modern) do
                local key = def.system .. ":" .. tostring(def.systemIndex)
                local mine = have[key]
                if not mine then
                    layout.systems[#layout.systems + 1] = CopyTable(def)
                else
                    if not mine.anchorInfo then
                        mine.anchorInfo = CopyTable(def.anchorInfo)
                        mine.anchorInfo2 = def.anchorInfo2 and CopyTable(def.anchorInfo2) or nil
                    end
                    local known = {}
                    for _, st in ipairs(mine.settings) do known[st.setting] = true end
                    for _, st in ipairs(def.settings or {}) do
                        if not known[st.setting] then mine.settings[#mine.settings + 1] = CopyTable(st) end
                    end
                end
            end
        end

        local function AnchorExists(a)
            if type(a) ~= "table" then return false end
            local rel = a.relativeTo
            return rel == nil or rel == "" or _G[rel] ~= nil
        end

        local function FromPortable(p)
            local layout = { layoutName = p.name, systems = {} }
            local skipped, reset = {}, {}
            for _, s in ipairs(p.systems or {}) do
                local sysId = type(s.system) == "string" and Enum.EditModeSystem[s.system]
                local idx = s.index
                if sysId and type(idx) == "string" then
                    local indexEnum = Enum["EditMode" .. s.system .. "SystemIndices"]
                    idx = indexEnum and indexEnum[idx]
                end
                if sysId and (s.index == nil or idx ~= nil) then
                    local settingEnum = Enum["EditMode" .. s.system .. "Setting"]
                    local settings = {}
                    for _, pair in ipairs(s.settings or {}) do
                        local id = pair[1]
                        if type(id) == "string" then
                            id = settingEnum and settingEnum[id]
                        elseif settingEnum then
                            id = nil
                        end
                        if id ~= nil then settings[#settings + 1] = { setting = id, value = pair[2] } end
                    end
                    local anchor, anchor2, isDefault = CopyAnchor(s.anchor), CopyAnchor(s.anchor2), s.default and true or false
                    if anchor and not AnchorExists(anchor) then
                        reset[#reset + 1] = s.system .. " (" .. tostring(anchor.relativeTo) .. ")"
                        anchor, anchor2, isDefault = nil, nil, true
                    elseif anchor2 and not AnchorExists(anchor2) then
                        anchor2 = nil
                    end
                    layout.systems[#layout.systems + 1] = {
                        system = sysId, systemIndex = idx,
                        anchorInfo = anchor, anchorInfo2 = anchor2,
                        isInDefaultPosition = isDefault,
                        settings = settings,
                    }
                else
                    skipped[#skipped + 1] = tostring(s.system) .. (s.index and (" " .. tostring(s.index)) or "")
                end
            end
            FillFromModern(layout)
            for i = #layout.systems, 1, -1 do
                if not layout.systems[i].anchorInfo then table.remove(layout.systems, i) end
            end
            return layout, skipped, reset
        end

        local function ExportLayout(profileName, fmt)
            if type(profileName) ~= "string" or profileName == "" then
                return nil, "No layout selected."
            end
            if PresetIndexByName(profileName) then
                return nil, "Blizzard's preset layouts can’t be exported via addon."
            end
            if not C_EditMode.ConvertLayoutInfoToString then
                return nil, "Missing API: C_EditMode.ConvertLayoutInfoToString"
            end

            local info = FindCustomLayoutInfoByName(profileName)
            if type(info) ~= "table" then
                return nil, "Layout not found (custom layouts only)."
            end

            local ok, strOrErr = pcall(C_EditMode.ConvertLayoutInfoToString, info)
            if not ok or type(strOrErr) ~= "string" or strOrErr == "" then
                return nil, "Failed to export layout."
            end

            if fmt == "native" then
                return strOrErr
            end
            return PM_Encode({ V, "BlizzardEditMode", profileName, strOrErr, ToPortable(info) })
        end

        local function ParseLayoutImport(inputText)
            if type(inputText) ~= "string" then return nil, "Missing import string" end
            local s = strtrim(inputText)
            if s == "" then return nil, "Missing import string" end

            local payload = PM_Decode(s)
            if type(payload) == "table" then
                if tostring(payload[2] or "") ~= "BlizzardEditMode" then
                    return nil, "Wrong provider"
                end
                local native = type(payload[4]) == "string" and strtrim(payload[4]) or nil
                local portable = type(payload[5]) == "table" and payload[5] or nil
                if not native and not portable then return nil, "Missing layout data" end
                return { native = native, portable = portable }
            end
            return { native = s }
        end

        local function ImportLayout(serializedString, desiredBaseName, opts)
            if InCombatLockdown() then return false, "In combat" end

            local parsed, err = ParseLayoutImport(serializedString)
            if not parsed then return false, err end

            if type(C_EditMode.SaveLayouts) ~= "function" then
                return false, "Missing API: C_EditMode.SaveLayouts"
            end

            local imported
            if parsed.portable then
                local skipped, reset
                imported, skipped, reset = FromPortable(parsed.portable)
                if #skipped > 0 then
                    print(("|cffffaa00ProfileManager|r Edit Mode: skipped %d frame(s) this game version doesn't have: %s")
                        :format(#skipped, table.concat(skipped, ", ")))
                end
                if #reset > 0 then
                    print(("|cffffaa00ProfileManager|r Edit Mode: %d frame(s) were attached to frames this game version doesn't have and use their default position: %s")
                        :format(#reset, table.concat(reset, ", ")))
                end
            else
                if type(C_EditMode.ConvertStringToLayoutInfo) ~= "function" then
                    return false, "Missing API: C_EditMode.ConvertStringToLayoutInfo"
                end
                local okC, decoded = pcall(C_EditMode.ConvertStringToLayoutInfo, parsed.native)
                if not okC or type(decoded) ~= "table" then
                    return false, "Blizzard couldn't read this layout. If it comes from another game version (e.g. WoW Forever), update ProfileManager there and export it again in the ProfileManager format."
                end
                imported = decoded
            end

            local decodedName = tostring(imported.layoutName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local baseName = tostring(desiredBaseName or decodedName or ""):gsub("^%s+", ""):gsub("%s+$", "")

            local newName = (baseName == "") and MakeUniquePMDefaultName() or MakeUniqueLayoutName(baseName)

            imported.layoutName = newName
            imported.layoutType = (Enum.EditModeLayoutType and Enum.EditModeLayoutType.Account) or imported.layoutType

            local editModeLayouts = C_EditMode.GetLayouts()
            if type(editModeLayouts) ~= "table" or type(editModeLayouts.layouts) ~= "table" then
                return false, "Couldn’t read current Edit Mode layouts."
            end

            for i = #editModeLayouts.layouts, 1, -1 do
                local l = editModeLayouts.layouts[i]
                if type(l) == "table" and tostring(l.layoutName or ""):lower() == newName:lower() then
                    table.remove(editModeLayouts.layouts, i)
                end
            end
            pcall(C_EditMode.SaveLayouts, editModeLayouts)

            editModeLayouts = C_EditMode.GetLayouts()
            if type(editModeLayouts) ~= "table" or type(editModeLayouts.layouts) ~= "table" then
                return false, "Couldn't re-read Edit Mode layouts."
            end

            table.insert(editModeLayouts.layouts, imported)

            local okSave = pcall(C_EditMode.SaveLayouts, editModeLayouts)
            if not okSave then
                return false, "C_EditMode.SaveLayouts failed."
            end

            local pos = nil
            local verify = C_EditMode.GetLayouts()
            if type(verify) == "table" and type(verify.layouts) == "table" then
                for idx, l in ipairs(verify.layouts) do
                    if type(l) == "table" and tostring(l.layoutName or ""):lower() == newName:lower() then
                        pos = idx
                        break
                    end
                end
            end

            if WantActivate(opts) and pos then
                pcall(C_EditMode.SetActiveLayout, pos + #PresetLayouts())
            end

            return true, newName
        end

        return {
            displayName = "Blizzard Edit Mode",

            GetProfiles = DotColonSafeGetter(function()
                local out = {}
                for _, p in ipairs(PresetLayouts()) do
                    if PresetVisible(p) then out[#out + 1] = p.name end
                end
                for _, name in ipairs(GetCustomNames()) do out[#out + 1] = name end
                return out
            end),

            GetCurrentProfile = DotColonSafeGetter(function()
                local data = GetLayoutsData()
                if not data or type(data.activeLayout) ~= "number" then return nil end
                local active = data.activeLayout
                local presets = PresetLayouts()
                if presets[active] then return presets[active].name end

                local customIndex = active - #presets
                if customIndex < 1 then return nil end

                local list = data.layouts or data
                local info = list and list[customIndex]
                if type(info) == "table" then
                    return info.layoutName or info.name or info.displayName or tostring(customIndex)
                end
                return tostring(customIndex)
            end),

            ApplyProfile = DotColonSafeSetter(function(value)
                local presetCount = #PresetLayouts()
                if type(value) == "string" then
                    local preset = PresetIndexByName(value)
                    if preset then return SetActiveLayoutIndex(preset) end
                    local idx = FindCustomIndexByName(value)
                    return idx and SetActiveLayoutIndex(presetCount + idx) or false
                end
                if type(value) == "number" then
                    if value >= 1 and value <= presetCount then return SetActiveLayoutIndex(value) end
                    return SetActiveLayoutIndex(presetCount + value)
                end
                return false
            end),

            SetProfile = DotColonSafeSetter(function(value)
                return (ProfileManager and ProfileManager.Providers and ProfileManager.Providers.BlizzardEditMode
                    and ProfileManager.Providers.BlizzardEditMode.ApplyProfile
                    and ProfileManager.Providers.BlizzardEditMode:ApplyProfile(value)) or false
            end),

            nativeExport = true,
            ExportProfile = function(_, profileName, fmt)
                return ExportLayout(profileName, fmt)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                return ImportLayout(serialized, desiredBaseName, opts)
            end,

            DeleteProfile = function(_, profileName)
                if InCombatLockdown() then return false, "In combat" end

                profileName = tostring(profileName or "")
                if profileName == "" then return false end

                if PresetIndexByName(profileName) then
                    return false, "Cannot delete Blizzard preset layouts"
                end

                local layoutsData = C_EditMode.GetLayouts()
                if type(layoutsData) ~= "table" or type(layoutsData.layouts) ~= "table" then
                    return false, "Failed to read layouts"
                end

                local activeName = nil
                if layoutsData.activeLayout and layoutsData.layouts then
                    local activeIndex = layoutsData.activeLayout - #PresetLayouts()
                    if activeIndex and activeIndex > 0 then
                        local activeLayout = layoutsData.layouts[activeIndex]
                        if activeLayout then activeName = activeLayout.layoutName end
                    end
                end

                if activeName and activeName:lower() == profileName:lower() then
                    return false, "Cannot delete active layout"
                end

                local removed = false
                for i = #layoutsData.layouts, 1, -1 do
                    local l = layoutsData.layouts[i]
                    if type(l) == "table" and tostring(l.layoutName or ""):lower() == profileName:lower() then
                        table.remove(layoutsData.layouts, i)
                        removed = true
                        break
                    end
                end

                if not removed then return false, "Layout not found" end

                local ok = pcall(C_EditMode.SaveLayouts, layoutsData)
                if not ok then return false, "SaveLayouts failed" end
                return true
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "DandersFrames",
    detect = function()
        return _G.DandersFramesDB_v2 ~= nil or (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("DandersFrames"))
    end,
    buildProvider = function()
        local function EnsureDB()
            if not _G.DandersFramesDB_v2 then _G.DandersFramesDB_v2 = {} end
            if not _G.DandersFramesDB_v2.profiles then _G.DandersFramesDB_v2.profiles = {} end
            if not _G.DandersFramesDB_v2.currentProfile then _G.DandersFramesDB_v2.currentProfile = "Default" end
        end

        local function ProfilesTable()
            EnsureDB()
            _G.DandersFramesDB_v2.profiles = _G.DandersFramesDB_v2.profiles or {}
            return _G.DandersFramesDB_v2.profiles
        end

        local function GetDF()
            return _G.DandersFrames
        end

        local function RefreshDF()
            local DF = GetDF()
            if DF and DF.FullProfileRefresh then
                pcall(function() DF:FullProfileRefresh() end)
            end
        end

        local function SortedProfiles()
            EnsureDB()
            local profiles = { "Default" }
            for name in pairs(_G.DandersFramesDB_v2.profiles) do
                if name ~= "Default" then
                    table.insert(profiles, name)
                end
            end
            table.sort(profiles, function(a, b)
                if a == "Default" then return true end
                if b == "Default" then return false end
                return tostring(a):lower() < tostring(b):lower()
            end)
            return profiles
        end

        local provider = {
            displayName = "DandersFrames",

            GetProfiles = function()
                return SortedProfiles()
            end,

            GetCurrentProfile = function()
                EnsureDB()
                return _G.DandersFramesDB_v2.currentProfile or "Default"
            end,

            SetProfile = function(_, profileName)
                EnsureDB()
                profileName = tostring(profileName or "")
                if profileName == "" then return false end

                local DF = GetDF()
                if DF and DF.SetProfile then
                    local ok = pcall(function() DF:SetProfile(profileName) end)
                    if ok then return true end
                end

                _G.DandersFramesDB_v2.currentProfile = profileName
                RefreshDF()
                return true
            end,

            ApplyProfile = function(self, profileName)
                return self:SetProfile(profileName)
            end,
        }

        local function MakeDFP1String(profileData, profileName)
            local safeCopy = MakeSerializableCopy(profileData)
            if type(safeCopy) ~= "table" then return nil end
            safeCopy.profileName = profileName
            if not safeCopy.version then
                local DF2 = GetDF()
                safeCopy.version = (type(DF2) == "table" and DF2.VERSION) or 1
            end
            local serialized = LibSerialize:Serialize(safeCopy)
            if not serialized then return nil end
            local compressed = LibDeflate:CompressDeflate(serialized)
            if not compressed then return nil end
            local encoded = LibDeflate:EncodeForPrint(compressed)
            if type(encoded) ~= "string" or encoded == "" then return nil end
            return "!DFP1!" .. encoded
        end

        local function DecodeDFNative(str)
            if type(str) ~= "string" then return nil end
            local DF2 = GetDF()
            if str:sub(1, 6) == "!DFP1!" and DF2 and type(DF2.ValidateImportString) == "function" then
                local ok, importData = pcall(function() return DF2:ValidateImportString(str) end)
                if ok and type(importData) == "table" then
                    local profileData = MakeSerializableCopy(importData) or {}
                    profileData.profileName = nil
                    profileData.exportTime  = nil
                    profileData.exportedBy  = nil
                    return profileData
                end
            end
            return TryDecodeRaw(str)
        end

        provider.ExportProfile = function(_, profileName)
            local profiles = ProfilesTable()
            local rawProfile = profiles and profiles[profileName]
            if type(rawProfile) == "table" then
                local nativeStr = MakeDFP1String(rawProfile, profileName)
                if nativeStr then
                    local pmStr = PM_Encode({ V, "DandersFrames", profileName, nativeStr })
                    if pmStr then return pmStr end
                end
            end
            return ExportProfile_Table("DandersFrames", profiles, profileName)
        end

        provider.ImportProfile = function(_, serialized, desiredBaseName, opts)
            if InCombatLockdown() then return false, "In combat" end

            local profiles = ProfilesTable()

            local payload, pmErr = PM_Decode(serialized)
            if payload then
                if tostring(payload[2] or "") ~= "DandersFrames" then
                    return false, ("Wrong provider (got '%s', expected 'DandersFrames')"):format(payload[2] or "")
                end
                local innerData = payload[4]
                local baseName  = tostring(desiredBaseName or payload[3] or "Imported")
                local newName   = MakeUniqueKeyName(profiles, baseName)

                if type(innerData) == "string" then
                    local profileData = DecodeDFNative(innerData)
                    if type(profileData) ~= "table" then
                        return false, "Cannot decode native DandersFrames string"
                    end
                    profiles[newName] = profileData
                elseif type(innerData) == "table" then
                    profiles[newName] = innerData
                else
                    return false, "Import payload missing data."
                end

                if WantActivate(opts) then
                    _G.DandersFramesDB_v2.currentProfile = newName
                    local DF = GetDF()
                    if DF then DF.db = profiles[newName] end
                    RefreshDF()
                end
                return true, newName
            end

            local profileData = DecodeDFNative(serialized)
            if type(profileData) == "table" then
                local embeddedName = type(profileData.profileName) == "string" and profileData.profileName ~= "" and profileData.profileName
                local baseName = tostring(desiredBaseName or embeddedName or "Imported")
                profileData.profileName = nil
                local newName = MakeUniqueKeyName(profiles, baseName)
                profiles[newName] = profileData
                if WantActivate(opts) then
                    _G.DandersFramesDB_v2.currentProfile = newName
                    local DF = GetDF()
                    if DF then DF.db = profiles[newName] end
                    RefreshDF()
                end
                return true, newName
            end

            return false, pmErr or "Bad import string"
        end
        provider.DeleteProfile = function(_, profileName)
            EnsureDB()

            if _G.DandersFramesDB_v2.currentProfile == profileName then
                return false, "Cannot delete active profile"
            end

            local tbl = _G.DandersFramesDB_v2.profiles
            if tbl and tbl[profileName] then
                tbl[profileName] = nil
                return true
            end

            return false
        end
        return provider
    end,
})

addon:RegisterProviderDef({
    id = "MSUF",
    detect = function()
        return type(_G.MSUF_GetAllProfiles) == "function" and type(_G.MSUF_SwitchProfile) == "function"
    end,
    buildProvider = function()
        local function ProfilesTable()
            _G.MSUF_GlobalDB = _G.MSUF_GlobalDB or {}
            _G.MSUF_GlobalDB.profiles = _G.MSUF_GlobalDB.profiles or {}
            return _G.MSUF_GlobalDB.profiles
        end

        return {
            displayName = "MSUF (Midnight Simple UnitFrames)",

            GetProfiles = DotColonSafeGetter(function()
                local ok, list = pcall(_G.MSUF_GetAllProfiles)
                return (ok and type(list) == "table") and list or {}
            end),

            GetCurrentProfile = DotColonSafeGetter(function()
                local cur = _G.MSUF_ActiveProfile
                return (type(cur) == "string" and cur ~= "") and cur or nil
            end),

            ApplyProfile = DotColonSafeSetter(function(profile)
                if InCombatLockdown() then return false end
                if type(profile) ~= "string" or profile == "" then return false end

                local ok, list = pcall(_G.MSUF_GetAllProfiles)
                if ok and type(list) == "table" and #list > 0 and not ProfileExists(list, profile) then
                    return false
                end

                _G.MSUF_SwitchProfile(profile)
                return true
            end),

            SetProfile = DotColonSafeSetter(function(profile)
                _G.MSUF_SwitchProfile(profile)
                return true
            end),

            ExportProfile = function(_, profileName)
                return ExportProfile_Table("MSUF", ProfilesTable(), profileName)
            end,
            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end

                local ok, newNameOrErr = ImportProfile_Table("MSUF", ProfilesTable(), serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end

                if WantActivate(opts) then
                    pcall(function() _G.MSUF_SwitchProfile(newNameOrErr) end)
                end

                return true, newNameOrErr
            end,
            DeleteProfile = function(_, profileName)
                local tbl = ProfilesTable()
                if not tbl then return false end

                if _G.MSUF_ActiveProfile == profileName then
                    return false
                end

                return DeleteProfile_Table(tbl, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "DBM",
    detect = function()
        if _G.DBM and type(_G.DBM.ApplyProfile) == "function" then return true end
        if _G.DBM_AllSavedOptions ~= nil then return true end
        if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded("DBM-Core") end
        return false
    end,
    buildProvider = function()
        local function GetProfiles()
            local sv = _G.DBM_AllSavedOptions
            local out, seen = {}, {}
            if type(sv) == "table" then
                for name in pairs(sv) do
                    if type(name) == "string" and name ~= "" and not seen[name] then
                        seen[name] = true
                        out[#out + 1] = name
                    end
                end
            end
            if not seen["Default"] then out[#out + 1] = "Default" end
            return SortLower(out)
        end

        return {
            displayName = "DBM",
            GetProfiles = DotColonSafeGetter(GetProfiles),
            GetCurrentProfile = DotColonSafeGetter(function()
                local cur = _G.DBM_UsedProfile
                return (type(cur) == "string" and cur ~= "") and cur or "Default"
            end),

            ApplyProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end
                local list = GetProfiles()
                if #list > 0 and not ProfileExists(list, profileName) then return false end

                if _G.DBM and type(_G.DBM.ApplyProfile) == "function" then
                    local ok = pcall(function() _G.DBM:ApplyProfile(profileName) end)
                    return ok
                end

                _G.DBM_UsedProfile = profileName
                return true
            end),

            SetProfile = DotColonSafeSetter(function(profileName)
                if _G.DBM and type(_G.DBM.ApplyProfile) == "function" then
                    local ok = pcall(function() _G.DBM:ApplyProfile(profileName) end)
                    return ok
                end
                _G.DBM_UsedProfile = profileName
                return true
            end),

            ExportProfile = function(_, profileName)
                return ExportProfile_Table("DBM", _G.DBM_AllSavedOptions, profileName)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                if type(_G.DBM_AllSavedOptions) ~= "table" then
                    _G.DBM_AllSavedOptions = {}
                end

                local ok, newNameOrErr = ImportProfile_Table("DBM", _G.DBM_AllSavedOptions, serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end

                if WantActivate(opts) then
                    if _G.DBM and type(_G.DBM.ApplyProfile) == "function" then
                        pcall(function() _G.DBM:ApplyProfile(newNameOrErr) end)
                    else
                        _G.DBM_UsedProfile = newNameOrErr
                    end
                end
                return true, newNameOrErr
            end,

            DeleteProfile = function(_, profileName)
                if type(_G.DBM_AllSavedOptions) ~= "table" then return false end

                if _G.DBM_UsedProfile == profileName then
                    return false
                end

                return DeleteProfile_Table(_G.DBM_AllSavedOptions, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "ElvUI",
    detect = function()
        local eng = _G.ElvUI
        local E = eng and eng[1]
        local db = E and E.data
        return type(db) == "table"
            and type(db.GetProfiles) == "function"
            and type(db.SetProfile) == "function"
    end,
    buildProvider = function()
        local E = _G.ElvUI[1]
        local db = E.data

        local function PrivDB()
            local pdb = E and E.charSettings
            if type(pdb) == "table" and type(pdb.GetProfiles) == "function"
                and type(pdb.SetProfile) == "function" then
                return pdb
            end
            return nil
        end

        local function ResolveDB(id)
            local real, isPriv = PM_StripPrivatePrefix(id)
            if isPriv then
                return PrivDB(), real, true
            end
            return db, real, false
        end

        local function SortedProfilesOf(targetDB)
            local ok, list = pcall(function() return targetDB:GetProfiles() end)
            if ok and type(list) == "table" then
                table.sort(list, function(a, b) return a:lower() < b:lower() end)
                return list
            end
            return {}
        end

        local function GetGlobalProfiles()
            return SortedProfilesOf(db)
        end

        local function GetProfilesList()
            local out = GetGlobalProfiles()
            local pdb = PrivDB()
            if pdb then
                for _, name in ipairs(SortedProfilesOf(pdb)) do
                    out[#out + 1] = PM_PRIV_PREFIX .. name
                end
            end
            return out
        end

        local function CurrentProfileOf(targetDB)
            if type(targetDB) == "table" and type(targetDB.GetCurrentProfile) == "function" then
                local ok, cur = pcall(function() return targetDB:GetCurrentProfile() end)
                if ok then return cur end
            end
            return nil
        end

        local function Dist()
            local ok, mod = pcall(function() return E.GetModule and E:GetModule("Distributor", true) end)
            if ok and type(mod) == "table" then return mod end
            return nil
        end

        local function UniqueProfileName(targetDB, baseName)
            baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if baseName == "" then baseName = "Imported" end
            local existing = {}
            for _, n in ipairs(SortedProfilesOf(targetDB)) do existing[n] = true end
            if not existing[baseName] then return baseName end
            local i = 2
            while existing[string.format("%s (%d)", baseName, i)] do i = i + 1 end
            return string.format("%s (%d)", baseName, i)
        end

        return {
            displayName = "ElvUI",
            GetProfiles = DotColonSafeGetter(GetProfilesList),

            GetCurrentProfile = DotColonSafeGetter(function()
                return CurrentProfileOf(db)
            end),

            ApplyProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end

                local targetDB, real = ResolveDB(profileName)
                if not targetDB then return false end

                local list = SortedProfilesOf(targetDB)
                if #list > 0 and not ProfileExists(list, real) then
                    return false
                end

                local ok = pcall(function() targetDB:SetProfile(real) end)
                return ok
            end),

            SetProfile = DotColonSafeSetter(function(profileName)
                local targetDB, real = ResolveDB(profileName)
                if not targetDB then return false end
                local ok = pcall(function() targetDB:SetProfile(real) end)
                return ok
            end),

            nativeExport = true,
            ExportProfile = function(_, profileName, fmt)
                local targetDB, real, isPriv = ResolveDB(profileName)
                if not targetDB then return nil, "Private profiles unavailable." end
                if fmt ~= "pm" and not isPriv then
                    local dist = Dist()
                    if dist and type(dist.ExportProfile) == "function" then
                        local ok, _, nativeStr = pcall(function() return dist:ExportProfile("profile", real, "text") end)
                        if ok and type(nativeStr) == "string" and nativeStr ~= "" then
                            return nativeStr
                        end
                    end
                    if fmt == "native" then
                        return nil, "ElvUI native export failed for this profile."
                    end
                end
                if fmt == "native" then
                    return nil, "Private ElvUI profiles have no native string format."
                end
                return ExportProfile_AceDB(targetDB, isPriv and "ElvUI-Private" or "ElvUI", real)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end

                local str = tostring(serialized or "")
                if str:find("^!E1!") or str:find("^{") then
                    local dist = Dist()
                    if not (dist and type(dist.Decode) == "function") then
                        return false, "ElvUI Distributor unavailable"
                    end
                    local okD, pType, pKey, pData = pcall(function() return dist:Decode(str) end)
                    if not okD or type(pData) ~= "table" then
                        return false, "Failed to decode ElvUI string"
                    end
                    if pType ~= "profile" then
                        return false, "Only ElvUI profile strings are supported (got: " .. tostring(pType) .. ")"
                    end
                    if type(E.FilterTableFromBlacklist) == "function" and dist.blacklistedKeys and dist.blacklistedKeys.profile then
                        local okF, filtered = pcall(function() return E:FilterTableFromBlacklist(pData, dist.blacklistedKeys.profile) end)
                        if okF and type(filtered) == "table" then pData = filtered end
                    end
                    if not (db.sv and db.sv.profiles) then return false, "ElvUI DB unavailable" end
                    local newName = UniqueProfileName(db, desiredBaseName or pKey)
                    db.sv.profiles[newName] = pData
                    if WantActivate(opts) then
                        pcall(function() db:SetProfile(newName) end)
                    end
                    return true, newName
                end

                local payload = PM_Decode(serialized)
                local srcProvider = payload and tostring(payload[2] or "") or "ElvUI"
                local isPriv = (srcProvider == "ElvUI-Private")

                local targetDB = isPriv and PrivDB() or db
                if not targetDB then return false, "Private profiles unavailable." end

                local ok, newNameOrErr =
                    ImportProfile_AceDB(targetDB, isPriv and "ElvUI-Private" or "ElvUI", serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end

                if WantActivate(opts) then
                    pcall(function() targetDB:SetProfile(newNameOrErr) end)
                end
                return true, isPriv and (PM_PRIV_PREFIX .. newNameOrErr) or newNameOrErr
            end,

            DeleteProfile = function(_, profileName)
                local targetDB, real = ResolveDB(profileName)
                if not targetDB or not targetDB.sv or not targetDB.sv.profiles then return false end

                if CurrentProfileOf(targetDB) == real then
                    return false, "Cannot delete active profile"
                end

                if targetDB.sv.profiles[real] then
                    targetDB.sv.profiles[real] = nil
                    return true
                end

                return false
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "TotalRP3",
    detect = function()
        local A = _G.TRP3_API
        local p = A and A.profile
        return type(p) == "table"
            and type(p.getProfiles) == "function"
            and type(p.selectProfile) == "function"
            and (type(p.createProfile) == "function" or type(p.createProfileWithName) == "function" or type(p.createProfileWithID) == "function")
    end,
    buildProvider = function()
        local TRP3 = _G.TRP3_API
        local P = TRP3.profile

        local nameToID = {}

        local function BuildList()
            wipe(nameToID)
            local profiles = P.getProfiles()
            local out = {}
            if type(profiles) ~= "table" then return out end

            for profileID, profile in pairs(profiles) do
                local name =
                    (type(profile) == "table" and type(profile.profileName) == "string" and profile.profileName ~= "")
                    and profile.profileName
                    or tostring(profileID)

                if not nameToID[name] then
                    nameToID[name] = profileID
                    out[#out + 1] = name
                end
            end

            table.sort(out, function(a, b) return a:lower() < b:lower() end)
            return out
        end

        local function GetCurrentProfileName()
            local ok, id = pcall(P.getPlayerCurrentProfileID)
            if not ok or not id then return nil end

            local prof = (P.getProfileByID and P.getProfileByID(id)) or ((P.getProfiles() or {})[id])
            if prof and type(prof.profileName) == "string" and prof.profileName ~= "" then
                return prof.profileName
            end
            return nil
        end

        local function SelectByName(profileName)
            if InCombatLockdown() then return false end
            profileName = tostring(profileName or "")
            if profileName == "" then return false end

            BuildList()
            local id = nameToID[profileName]
            if not id then return false end

            local ok = pcall(function() P.selectProfile(id) end)
            return ok
        end

        local function CreateProfileReturningID(newName)
            if type(P.createProfile) == "function" then
                local ok, a, b = pcall(function() return P.createProfile(newName) end)
                if ok then
                    if type(a) == "string" then return true, a end
                    if type(b) == "string" then return true, b end
                end
            end

            if type(P.createProfileWithName) == "function" then
                local ok, a, b = pcall(function() return P.createProfileWithName(newName) end)
                if ok then
                    if type(a) == "string" then return true, a end
                    if type(b) == "string" then return true, b end
                end
            end

            local ok = pcall(function()
                if type(P.createProfileWithID) == "function" then
                    P.createProfileWithID()
                end
            end)
            if not ok then return false, "TRP3 create profile API not found." end

            BuildList()
            local id = nameToID[newName]
            if type(id) == "string" and id ~= "" then
                return true, id
            end

            return false, "Couldn't determine created profile ID."
        end

        return {
            displayName = "Total RP 3",

            GetProfiles = DotColonSafeGetter(BuildList),
            GetCurrentProfile = DotColonSafeGetter(GetCurrentProfileName),

            ApplyProfile = DotColonSafeSetter(SelectByName),
            SetProfile = DotColonSafeSetter(SelectByName),

            ExportProfile = function(_, profileName)
                BuildList()
                local id = nameToID[profileName]
                if not id then
                    return nil, "Profile not found."
                end

                local profiles = P.getProfiles()
                local src = profiles and profiles[id]
                if type(src) ~= "table" then
                    return nil, "Profile data not found."
                end

                local safeCopy = MakeSerializableCopy(src) or {}
                return PM_Encode({ V, "TotalRP3", profileName, safeCopy })
            end,

            ImportProfile = function(_, serializedString, desiredBaseName)
                if InCombatLockdown() then return false, "In combat" end
                if type(serializedString) ~= "string" or serializedString == "" then
                    return false, "Missing import string"
                end

                local payload, err = PM_Decode(serializedString)
                if not payload then
                    return false, err or "Bad import string"
                end
                if tostring(payload[2] or "") ~= "TotalRP3" then
                    return false, "Wrong provider"
                end

                local data = payload[4]
                if type(data) ~= "table" then
                    return false, "Import payload missing data."
                end

                local baseName = tostring(desiredBaseName or payload[3] or "Imported")

                local profiles = P.getProfiles()
                local usedNames = {}
                if type(profiles) == "table" then
                    for _, prof in pairs(profiles) do
                        if type(prof) == "table" and type(prof.profileName) == "string" then
                            usedNames[prof.profileName] = true
                        end
                    end
                end

                local newName = baseName
                if usedNames[newName] then
                    local i = 2
                    while usedNames[("%s (%d)"):format(baseName, i)] do i = i + 1 end
                    newName = ("%s (%d)"):format(baseName, i)
                end

                local okCreate, newIDOrErr = CreateProfileReturningID(newName)
                if not okCreate then
                    return false, tostring(newIDOrErr)
                end
                local newID = newIDOrErr

                profiles = P.getProfiles()
                if type(profiles) ~= "table" then
                    return false, "TRP3 profiles table not found after create."
                end

                profiles[newID] = data
                profiles[newID].profileName = newName

                pcall(function() P.selectProfile(newID) end)
                BuildList()

                return true, newName
            end,

            DeleteProfile = function(_, profileName)
                if InCombatLockdown() then
                    return false, "In combat"
                end

                profileName = tostring(profileName or "")
                if profileName == "" then
                    return false
                end

                local current = GetCurrentProfileName()
                if current == profileName then
                    return false, "Cannot delete active profile"
                end

                BuildList()
                local id = nameToID[profileName]
                if not id then
                    return false, "Profile not found"
                end

                local profiles = P.getProfiles()
                if type(profiles) ~= "table" then
                    return false
                end

                profiles[id] = nil
                nameToID[profileName] = nil

                return true
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "ArcUI",
    detect = function()
        local ns = _G.ArcUI_NS
        local g = ns and ns.CDMGroups
        return type(g) == "table"
            and type(g.GetProfileNames) == "function"
            and type(g.GetActiveProfileName) == "function"
            and type(g.LoadProfile) == "function"
            and type(g.GetProfile) == "function"
            and type(g.CreateProfile) == "function"
    end,
    buildProvider = function()
        local ns = _G.ArcUI_NS
        local g = ns and ns.CDMGroups
        if not g then return nil end

        local function GetProfilesList()
            local ok, list = pcall(function() return g.GetProfileNames() end)
            if ok and type(list) == "table" then
                local out = {}
                for _, v in ipairs(list) do
                    if type(v) == "string" and v ~= "" then out[#out + 1] = v end
                end
                table.sort(out, function(a, b) return a:lower() < b:lower() end)
                return out
            end
            return { "Default" }
        end

        local function MakeUniqueArcUIName(baseName)
            baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if baseName == "" then baseName = "Imported" end

            local existing = {}
            for _, n in ipairs(GetProfilesList()) do existing[n] = true end
            if not existing[baseName] then return baseName end

            local i = 2
            while true do
                local cand = string.format("%s (%d)", baseName, i)
                if not existing[cand] then return cand end
                i = i + 1
            end
        end

        return {
            displayName = "Arc UI",

            GetProfiles = DotColonSafeGetter(GetProfilesList),

            GetCurrentProfile = DotColonSafeGetter(function()
                local ok, cur = pcall(function() return g.GetActiveProfileName() end)
                return (ok and type(cur) == "string" and cur ~= "") and cur or "Default"
            end),

            ApplyProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end
                local ok = pcall(function() g.LoadProfile(profileName) end)
                return ok
            end),

            SetProfile = DotColonSafeSetter(function(profileName)
                local ok = pcall(function() g.LoadProfile(profileName) end)
                return ok
            end),

            ExportProfile = function(_, profileName)
                if type(profileName) ~= "string" or profileName == "" then
                    return nil, "No profile selected."
                end

                local ok, prof = pcall(function() return g.GetProfile(profileName) end)
                if not ok or type(prof) ~= "table" then
                    return nil, "ArcUI profile not found."
                end

                local safeCopy = MakeSerializableCopy(prof) or {}
                return PM_Encode({ V, "ArcUI", profileName, safeCopy })
            end,

            ImportProfile = function(_, serializedString, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                if type(serializedString) ~= "string" or serializedString == "" then
                    return false, "Missing import string"
                end

                local payload, err = PM_Decode(serializedString)
                if not payload then
                    return false, err or "Bad import string"
                end
                if tostring(payload[2] or "") ~= "ArcUI" then
                    return false, "Wrong provider"
                end

                local data = payload[4]
                if type(data) ~= "table" then
                    return false, "Import payload missing data."
                end

                local newName = MakeUniqueArcUIName(desiredBaseName or payload[3])

                local okC = pcall(function() return g.CreateProfile(newName) end)
                if not okC then
                    return false, "ArcUI failed to create profile."
                end

                local okG, dest = pcall(function() return g.GetProfile(newName) end)
                if not okG or type(dest) ~= "table" then
                    return false, "ArcUI created the profile, but it can't be accessed."
                end

                WipeAndCopy(dest, data)

                if WantActivate(opts) then
                    pcall(function() g.LoadProfile(newName) end)
                end

                return true, newName
            end,

            DeleteProfile = function(_, profileName)
                if InCombatLockdown() then
                    return false, "In combat"
                end

                profileName = tostring(profileName or "")
                if profileName == "" then
                    return false
                end

                local current = nil
                local ok, cur = pcall(function() return g.GetActiveProfileName() end)
                if ok then current = cur end

                if current == profileName then
                    return false, "Cannot delete active profile"
                end

                if type(g.DeleteProfile) == "function" then
                    local okDel = pcall(function() g.DeleteProfile(profileName) end)
                    if okDel then return true end
                end

                local okP, prof = pcall(function() return g.GetProfile(profileName) end)
                if okP and type(prof) == "table" then
                    wipe(prof)
                    return true
                end

                return false
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "KalielsTracker",
    detect = function()
        return Detect_DBOrLoaded("KalielsTrackerDB", "!KalielsTracker")
    end,
    buildProvider = function()
        local function SV()
            _G.KalielsTrackerDB = _G.KalielsTrackerDB or {}
            _G.KalielsTrackerDB.profiles = _G.KalielsTrackerDB.profiles or {}
            _G.KalielsTrackerDB.profileKeys = _G.KalielsTrackerDB.profileKeys or {}
            return _G.KalielsTrackerDB
        end

        local function GetProfiles()
            local sv = SV()
            local out, seen = {}, {}
            for name in pairs(sv.profiles) do
                if type(name) == "string" and name ~= "" and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = name
                end
            end
            if not seen[DEFAULT_OPTION_KEY] then out[#out + 1] = DEFAULT_OPTION_KEY end
            if not seen[CharKey()] then out[#out + 1] = CharKey() end
            table.sort(out, function(a,b) return tostring(a):lower() < tostring(b):lower() end)
            return out
        end

        local function GetCurrent()
            local sv = SV()
            local cur = sv.profileKeys[CharKey()]
            if type(cur) == "string" and cur ~= "" then return cur end
            return "Default"
        end

        local function ResolveSelectedName(selected)
            selected = tostring(selected or "")
            if selected == "" then return nil end
            if selected == CharKey() then
                return GetCurrent()
            end
            if selected == DEFAULT_OPTION_KEY then
                return "Default"
            end
            return selected
        end

        local function SetProfile_NoCallback(selected)
            if InCombatLockdown() then return false end
            local sv = SV()
            local resolved = ResolveSelectedName(selected)
            if not resolved then return false end

            sv.profileKeys[CharKey()] = resolved
            return true
        end

        local function Export(profileName)
            local sv = SV()
            return ExportProfile_Table("KalielsTracker", sv.profiles, profileName)
        end

        local function Import(serialized, desiredBaseName, opts)
            if InCombatLockdown() then return false, "In combat" end
            local sv = SV()

            local ok, newNameOrErr = ImportProfile_Table("KalielsTracker", sv.profiles, serialized, desiredBaseName)
            if not ok then return false, newNameOrErr end

            if WantActivate(opts) then
                sv.profileKeys[CharKey()] = newNameOrErr
            end

            return true, newNameOrErr
        end

        return {
            displayName = "Kaliel's Tracker",

            GetProfiles = DotColonSafeGetter(GetProfiles),
            GetCurrentProfile = DotColonSafeGetter(GetCurrent),

            ApplyProfile = DotColonSafeSetter(SetProfile_NoCallback),
            SetProfile   = DotColonSafeSetter(SetProfile_NoCallback),

            ExportProfile = function(_, profileName) return Export(profileName) end,
            ImportProfile = function(_, serialized, desiredBaseName, opts) return Import(serialized, desiredBaseName, opts) end,

            DeleteProfile = function(_, profileName)
                local sv = SV()
                if GetCurrent() == profileName then
                    return false, "Cannot delete active profile"
                end
                return DeleteProfile_Table(sv.profiles, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
  id = "Platynator",
  displayName = "Platynator",

  detect = function()
    return type(PLATYNATOR_CONFIG) == "table"
       and type(PLATYNATOR_CONFIG.Profiles) == "table"
       and type(PLATYNATOR_CURRENT_PROFILE) == "string"
  end,

  buildProvider = function()

    local function HasLiveAPI()
      return type(Platynator) == "table"
         and type(Platynator.API) == "table"
         and type(Platynator.API.ImportString) == "function"
    end

    local function ForceRefresh(profileName)
      if HasLiveAPI() then
        local data = PLATYNATOR_CONFIG.Profiles[profileName]
        if type(data) ~= "table" then return false end

        local copy = CopyTable(data)
        copy.addon = "Platynator"
        copy.version = 1
        copy.kind = "profile"

        local s = C_EncodingUtil.SerializeJSON(copy)
        s = s:gsub("%|%|", "|"):gsub("%|", "||")

        Platynator.API.ImportString(s, profileName)
        return true
      end

      return false
    end

    local prov = {
      id = "Platynator",
      displayName = "Platynator",

      GetProfiles = function()
        return KeysToSortedArray(PLATYNATOR_CONFIG.Profiles)
      end,

      GetCurrentProfile = function()
        return PLATYNATOR_CURRENT_PROFILE
      end,

      SetProfile = function(_, profileName)
        if not PLATYNATOR_CONFIG.Profiles[profileName] then
          return false
        end

        PLATYNATOR_CURRENT_PROFILE = profileName

        ForceRefresh(profileName)

        return true
      end,

      ApplyProfile = function(self, profileName)
        return self:SetProfile(profileName)
      end,

      DeleteProfile = function(_, profileName)
        if profileName == "DEFAULT" then return false end
        if profileName == PLATYNATOR_CURRENT_PROFILE then return false end

        PLATYNATOR_CONFIG.Profiles[profileName] = nil
        return true
      end,

            nativeExport = true,
            ExportProfile = function(_, profileName, fmt)
        if type(profileName) ~= "string" or profileName == "" then
          profileName = (type(PLATYNATOR_CURRENT_PROFILE) == "string" and PLATYNATOR_CURRENT_PROFILE ~= "")
            and PLATYNATOR_CURRENT_PROFILE
            or nil
        end
        if fmt ~= "pm" then
          local data = profileName and PLATYNATOR_CONFIG.Profiles[profileName]
          if type(data) == "table" and C_EncodingUtil
            and C_EncodingUtil.SerializeCBOR and C_EncodingUtil.CompressString and C_EncodingUtil.EncodeBase64 then
            local okN, nativeStr = pcall(function()
              local copy = CopyTable(data)
              copy.addon = "Platynator"
              copy.version = copy.version or 1
              copy.kind = copy.kind or "profile"
              return "PLATY!1!" .. C_EncodingUtil.EncodeBase64(C_EncodingUtil.CompressString(C_EncodingUtil.SerializeCBOR(copy)))
            end)
            if okN and type(nativeStr) == "string" then
              return nativeStr
            end
          end
          if fmt == "native" then
            return nil, "Platynator native export failed."
          end
        end
        return ExportProfile_Table("Platynator", PLATYNATOR_CONFIG.Profiles, profileName)
      end,

      ImportProfile = function(_, exportStr, desiredName, opts)
        if InCombatLockdown() then return false, "In combat" end

        local str = tostring(exportStr or "")
        if str:find("^PLATY!1!") or str:find("^{") then
          if not HasLiveAPI() then return false, "Platynator API unavailable" end
          local base = tostring(desiredName or "Imported")
          local newName = base
          local n = 2
          while PLATYNATOR_CONFIG.Profiles[newName] ~= nil do
            newName = string.format("%s (%d)", base, n)
            n = n + 1
          end
          local okI, errI = pcall(Platynator.API.ImportString, str, newName)
          if not okI then return false, "Platynator import failed: " .. tostring(errI) end
          if WantActivate(opts) then
            PLATYNATOR_CURRENT_PROFILE = newName
            ForceRefresh(newName)
          end
          return true, newName
        end

        local ok, newNameOrErr = ImportProfile_Table("Platynator", PLATYNATOR_CONFIG.Profiles, exportStr, desiredName)
        if not ok then return false, newNameOrErr end

        if WantActivate(opts) then
          PLATYNATOR_CURRENT_PROFILE = newNameOrErr
          ForceRefresh(newNameOrErr)
        end

        return true, newNameOrErr
      end,
    }

    return prov
  end,
})

addon:RegisterProviderDef({
    id = "EnhanceQoL",
    detect = function()
        return type(_G.EnhanceQoLDB) == "table"
            and type(_G.EnhanceQoLDB.profiles) == "table"
            and type(_G.EnhanceQoLDB.profileKeys) == "table"
    end,
    buildProvider = function()
        local function SV()
            _G.EnhanceQoLDB = _G.EnhanceQoLDB or {}
            _G.EnhanceQoLDB.profiles = _G.EnhanceQoLDB.profiles or {}
            _G.EnhanceQoLDB.profileKeys = _G.EnhanceQoLDB.profileKeys or {}
            return _G.EnhanceQoLDB
        end

        local function GetCurrent()
            local sv = SV()
            local guid = UnitGUID("player")
            local p = guid and sv.profileKeys[guid]
            if type(p) == "string" and p ~= "" then return p end
            if type(sv.profileGlobal) == "string" and sv.profileGlobal ~= "" then return sv.profileGlobal end
            return nil
        end

        local function SetProfile(profileName)
            if InCombatLockdown() then return false end
            profileName = tostring(profileName or "")
            if profileName == "" then return false end

            local sv = SV()
            if sv.profiles[profileName] == nil then return false end

            local guid = UnitGUID("player")
            if guid then
                sv.profileKeys[guid] = profileName
                return true
            end
            return false
        end

        local function Delete(profileName)
            local sv = SV()
            profileName = tostring(profileName or "")
            if profileName == "" then return false end

            if GetCurrent() == profileName then
                return false, "Cannot delete active profile"
            end
            if sv.profiles[profileName] == nil then
                return false, "Profile not found"
            end

            sv.profiles[profileName] = nil

            for guid, p in pairs(sv.profileKeys) do
                if p == profileName then sv.profileKeys[guid] = nil end
            end
            if sv.profileGlobal == profileName then sv.profileGlobal = nil end

            return true
        end

        return {
            displayName = "EnhanceQoL",

            GetProfiles = DotColonSafeGetter(function()
                local sv = SV()
                return KeysToSortedArray(sv.profiles)
            end),

            GetCurrentProfile = DotColonSafeGetter(GetCurrent),

            ApplyProfile = DotColonSafeSetter(SetProfile),
            SetProfile   = DotColonSafeSetter(SetProfile),

            ExportProfile = function(_, profileName)
                local sv = SV()
                return ExportProfile_Table("EnhanceQoL", sv.profiles, profileName)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                local sv = SV()

                local ok, newNameOrErr = ImportProfile_Table("EnhanceQoL", sv.profiles, serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end

                if WantActivate(opts) then
                    local guid = UnitGUID("player")
                    if guid then sv.profileKeys[guid] = newNameOrErr end
                end

                return true, newNameOrErr
            end,

            DeleteProfile = function(_, profileName)
                if InCombatLockdown() then return false, "In combat" end
                return Delete(profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "CursorTrail",
    detect = function() return Detect_DBOrLoaded("CursorTrail_Config", "CursorTrail") end,
    buildProvider = function()
        local PROVIDER_ID = "CursorTrail"
        local SELECTED_KEY = "_SelectedName"

        local function GetConfig()
            return _G.CursorTrail_Config
        end

        local function ProfilesTable()
            local cfg = GetConfig()
            return cfg and cfg.Profiles
        end

        local function GetCurrentProfile()
            local profiles = ProfilesTable()
            if type(profiles) ~= "table" then return nil end
            local selTbl = profiles[SELECTED_KEY]
            if type(selTbl) ~= "table" then return nil end
            local name, realm = UnitFullName("player")
            local key = (name or "") .. "-" .. (realm or "")
            local cur = selTbl[key]
            if type(cur) == "string" and cur ~= "" and profiles[cur] ~= nil then
                return cur
            end
            return nil
        end

        local function ApplyProfile(profileName)
            if InCombatLockdown() then return false end
            if type(profileName) ~= "string" or profileName == "" then return false end

            local CT = _G.CursorTrail
            if not CT then return false end

            if not CT.OptionsFrame and type(CT.OptionsFrame_Create) == "function" then
                local ok = pcall(CT.OptionsFrame_Create)
                if not ok then return false end
            end

            local profilesUI = CT.OptionsFrame and CT.OptionsFrame.ProfilesUI
            if profilesUI and type(profilesUI.loadProfile) == "function" then
                local ok = pcall(function() profilesUI:loadProfile(profileName, "bs") end)
                return ok
            end

            local profiles = ProfilesTable()
            if type(profiles) ~= "table" or profiles[profileName] == nil then return false end
            profiles[SELECTED_KEY] = type(profiles[SELECTED_KEY]) == "table" and profiles[SELECTED_KEY] or {}
            local name, realm = UnitFullName("player")
            profiles[SELECTED_KEY][(name or "") .. "-" .. (realm or "")] = profileName
            return true
        end

        return {
            displayName = "CursorTrail",

            GetProfiles = DotColonSafeGetter(function()
                local profiles = ProfilesTable()
                if type(profiles) ~= "table" then return {} end
                local out = {}
                for k in pairs(profiles) do
                    if type(k) == "string" and k ~= SELECTED_KEY then
                        out[#out + 1] = k
                    end
                end
                return SortLower(out)
            end),

            GetCurrentProfile = DotColonSafeGetter(GetCurrentProfile),
            ApplyProfile      = DotColonSafeSetter(ApplyProfile),
            SetProfile        = DotColonSafeSetter(ApplyProfile),

            ExportProfile = function(_, profileName)
                return ExportProfile_Table(PROVIDER_ID, ProfilesTable(), profileName)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                local ok, newNameOrErr = ImportProfile_Table(PROVIDER_ID, ProfilesTable(), serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end
                if WantActivate(opts) then ApplyProfile(newNameOrErr) end
                return true, newNameOrErr
            end,

            DeleteProfile = function(_, profileName)
                local profiles = ProfilesTable()
                if not profiles then return false end
                if GetCurrentProfile() == profileName then
                    return false, "Cannot delete active profile"
                end
                return DeleteProfile_Table(profiles, profileName)
            end,
        }
    end,
})

addon:RegisterProviderDef({
    id = "VuhDo",
    detect = function()
        return type(_G.VUHDO_PROFILES) == "table"
            and type(_G.VUHDO_getProfileNamed) == "function"
            and type(_G.VUHDO_loadProfile) == "function"
    end,
    buildProvider = function()
        local PROFILE_PARTS = { "CONFIG", "PANEL_SETUP", "POWER_TYPE_COLORS", "SPELL_CONFIG", "BUFF_SETTINGS", "BUFF_ORDER", "INDICATOR_CONFIG" }

        local function GetProfiles()
            local out = {}
            local profiles = _G.VUHDO_PROFILES
            if type(profiles) ~= "table" then return out end
            for _, profile in ipairs(profiles) do
                if type(profile) == "table" and type(profile["NAME"]) == "string" and profile["NAME"] ~= "" then
                    out[#out + 1] = profile["NAME"]
                end
            end
            return SortLower(out)
        end

        local function GetCurrentProfile()
            local cfg = _G.VUHDO_CONFIG
            if type(cfg) == "table" and type(cfg["CURRENT_PROFILE"]) == "string" and cfg["CURRENT_PROFILE"] ~= "" then
                return cfg["CURRENT_PROFILE"]
            end
            local def = _G.VUHDO_DEFAULT_PROFILE
            return (type(def) == "string" and def ~= "") and def or nil
        end

        local function ProfileNameExists(name)
            local profiles = _G.VUHDO_PROFILES
            if type(profiles) ~= "table" then return false end
            for _, profile in ipairs(profiles) do
                if type(profile) == "table" and profile["NAME"] == name then return true end
            end
            return false
        end

        local function MakeUniqueVuhDoName(baseName)
            baseName = tostring(baseName or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if baseName == "" then baseName = "Imported" end
            if not ProfileNameExists(baseName) then return baseName end
            local i = 2
            while true do
                local cand = string.format("%s (%d)", baseName, i)
                if not ProfileNameExists(cand) then return cand end
                i = i + 1
            end
        end

        local function ExportVuhDoProfile(profileName)
            if type(profileName) ~= "string" or profileName == "" then
                return nil, "No profile selected."
            end

            local ok, _, profileData = pcall(function()
                return _G.VUHDO_getProfileNamed(profileName)
            end)
            if not ok or type(profileData) ~= "table" then
                return nil, "Profile not found or could not be read."
            end

            local safeCopy = MakeSerializableCopy(profileData) or {}
            return PM_Encode({ V, "VuhDo", profileName, safeCopy })
        end

        local function TryDecodeVuhDoNative(str)
            local lib = _G.VUHDO_LibBase64
            if not lib or type(lib.Decode) ~= "function" then return nil end
            if type(_G.VUHDO_decompressIfCompressed) ~= "function" then return nil end

            local ok, decoded = pcall(function() return lib.Decode(str) end)
            if not ok or type(decoded) ~= "string" or decoded == "" then return nil end

            local ok2, tbl = pcall(function() return _G.VUHDO_decompressIfCompressed(decoded) end)
            if not ok2 or type(tbl) ~= "table" then return nil end

            local prof = tbl["profile"]
            if type(prof) ~= "table" or type(prof["NAME"]) ~= "string" then return nil end

            return prof
        end

        local function InsertProfile(data, desiredBaseName, opts)
            local baseName = tostring(desiredBaseName or data["NAME"] or "Imported")
            local newName = MakeUniqueVuhDoName(baseName)

            data["NAME"] = newName

            if type(_G.VUHDO_compressTable) == "function" then
                for _, key in ipairs(PROFILE_PARTS) do
                    if type(data[key]) == "table" then
                        data[key] = _G.VUHDO_compressTable(data[key])
                    end
                end
            end

            _G.VUHDO_PROFILES = _G.VUHDO_PROFILES or {}
            table.insert(_G.VUHDO_PROFILES, data)

            if WantActivate(opts) then
                pcall(function() _G.VUHDO_loadProfile(newName) end)
            end

            return true, newName
        end

        local function ImportVuhDoProfile(serializedString, desiredBaseName, opts)
            if type(serializedString) ~= "string" or serializedString == "" then
                return false, "Missing import string"
            end

            local payload, err = PM_Decode(serializedString)
            if payload then
                if tostring(payload[2] or "") ~= "VuhDo" then return false, "Wrong provider" end
                local data = payload[4]
                if type(data) ~= "table" then return false, "Import payload missing data." end
                return InsertProfile(data, desiredBaseName or payload[3], opts)
            end

            local native = TryDecodeVuhDoNative(serializedString)
            if native then
                return InsertProfile(native, desiredBaseName, opts)
            end

            return false, err or "Bad import string"
        end

        return {
            displayName = "VuhDo",

            GetProfiles = DotColonSafeGetter(GetProfiles),
            GetCurrentProfile = DotColonSafeGetter(GetCurrentProfile),

            ApplyProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end
                if not ProfileNameExists(profileName) then return false end
                local ok = pcall(function() _G.VUHDO_loadProfile(profileName) end)
                return ok
            end),

            SetProfile = DotColonSafeSetter(function(profileName)
                if InCombatLockdown() then return false end
                if type(profileName) ~= "string" or profileName == "" then return false end
                local ok = pcall(function() _G.VUHDO_loadProfile(profileName) end)
                return ok
            end),

            ExportProfile = function(_, profileName)
                return ExportVuhDoProfile(profileName)
            end,

            ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                return ImportVuhDoProfile(serialized, desiredBaseName, opts)
            end,

            DeleteProfile = function(_, profileName)
                profileName = tostring(profileName or "")
                if profileName == "" then return false end

                if GetCurrentProfile() == profileName then
                    return false, "Cannot delete active profile"
                end

                local profiles = _G.VUHDO_PROFILES
                if type(profiles) ~= "table" then return false end

                for i, profile in ipairs(profiles) do
                    if type(profile) == "table" and profile["NAME"] == profileName then
                        table.remove(profiles, i)
                        return true
                    end
                end

                return false
            end,
        }
    end,
})

local function NativeProfilesProvider(id, title, svName, addonName, getProfiles, getCurrent, setCurrent)
    addon:RegisterProviderDef({
        id = id,
        detect = function() return Detect_DBOrLoaded(svName, addonName) end,
        buildProvider = function()
            local p = { displayName = title, RequiresReload = true }
            p.GetProfiles = DotColonSafeGetter(function() return KeysToSortedArray(getProfiles()) end)
            p.GetCurrentProfile = DotColonSafeGetter(function()
                local cur = getCurrent()
                return (type(cur) == "string" and cur ~= "") and cur or "DEFAULT"
            end)
            p.ApplyProfile = DotColonSafeSetter(function(name)
                if InCombatLockdown() then return false end
                local profiles = getProfiles()
                if type(name) ~= "string" or type(profiles) ~= "table" or profiles[name] == nil then return false end
                setCurrent(name)
                return true
            end)
            p.SetProfile = p.ApplyProfile
            p.ExportProfile = function(_, name)
                return ExportProfile_Table(id, getProfiles(), name)
            end
            p.ImportProfile = function(_, serialized, desiredBaseName, opts)
                if InCombatLockdown() then return false, "In combat" end
                local ok, newNameOrErr = ImportProfile_Table(id, getProfiles(), serialized, desiredBaseName)
                if not ok then return false, newNameOrErr end
                if WantActivate(opts) then setCurrent(newNameOrErr) end
                return true, newNameOrErr
            end
            p.DeleteProfile = function(_, name)
                if getCurrent() == name then return false, "Cannot delete active profile" end
                if name == "DEFAULT" then return false, "Cannot delete the default profile" end
                return DeleteProfile_Table(getProfiles(), name)
            end
            return p
        end,
    })
end

NativeProfilesProvider("Baganator", "Baganator", "BAGANATOR_CONFIG", "Baganator",
    function() return _G.BAGANATOR_CONFIG and _G.BAGANATOR_CONFIG.Profiles end,
    function() return _G.BAGANATOR_CURRENT_PROFILE end,
    function(name) _G.BAGANATOR_CURRENT_PROFILE = name end)

NativeProfilesProvider("MoveAny", "MoveAny", "MATAB", "MoveAny",
    function() return _G.MATAB and _G.MATAB["PROFILES"] end,
    function() return _G.MATABPC and _G.MATABPC["CURRENTPROFILE"] end,
    function(name)
        if _G.MoveAny and _G.MoveAny.SetCP then
            _G.MoveAny:SetCP(name)
        else
            _G.MATABPC = _G.MATABPC or {}
            _G.MATABPC["CURRENTPROFILE"] = name
        end
    end)

local function IsSuppressedAceDBScan(baseName, svName)
    local bn = tostring(baseName or ""):lower()
    local sn = tostring(svName or ""):lower()

    if addon.ProviderDefs and addon.ProviderDefs["ElvUI"] then
        if bn:find("elvui", 1, true) or sn:find("elv", 1, true) then return true end
    end
    if addon.ProviderDefs and addon.ProviderDefs["TotalRP3"] then
        if bn:find("total rp", 1, true) or bn:find("trp", 1, true) or sn:find("trp", 1, true) then return true end
    end
    if addon.ProviderDefs and addon.ProviderDefs["ArcUI"] then
        if bn:find("arc ui", 1, true) or bn:find("arcui", 1, true) or sn:find("arcui", 1, true) then return true end
    end
    if addon.ProviderDefs and addon.ProviderDefs["KalielsTracker"] then
        if bn:find("kaliel", 1, true) or sn:find("kalielstrackerdb", 1, true) then return true end
    end

    return false
end

local function IsTomTomName(baseName, svGlobal)
    local bn = tostring(baseName or ""):lower()
    local sn = tostring(svGlobal or ""):lower()
    return bn:find("tomtom", 1, true) ~= nil or sn:find("tomtom", 1, true) ~= nil
end

local function TomTomKindFromSV(svGlobal)
    local sn = tostring(svGlobal or ""):lower()
    if sn:find("waypoint", 1, true) or sn:find("waypoints", 1, true) then
        return "Waypoints"
    end
    return "Options"
end

local function TomTomProviderId(kind)
    return (kind == "Waypoints") and "TomTom:Waypoints" or "TomTom:Options"
end

local function TomTomDisplayName(kind)
    return (kind == "Waypoints") and "TomTom — Waypoints" or "TomTom — Options"
end

function addon:RebuildAceDBProviders()
    if not AceDB or not AceDB.db_registry then
        return false
    end
    for id, prov in pairs(self.Providers) do
        if type(prov) == "table" and prov._isAceDBScan then
            self.Providers[id] = nil
        end
    end

    local rows = {}
    for db in pairs(AceDB.db_registry) do
        if type(db) == "table" and not db.parent and not self:IsBlacklistedDB(db) then
            local baseName = self:GetAddonNameForDB(db)
            local svGlobal = self:FindGlobal(db.sv) or ""

            if not IsSuppressedAceDBScan(baseName, svGlobal) then
                if IsTomTomName(baseName, svGlobal) then
                    local kind = TomTomKindFromSV(svGlobal)
                    local providerId = TomTomProviderId(kind)
                    rows[#rows + 1] = { id = providerId, name = TomTomDisplayName(kind), db = db, _forceId = true }
                else
                    local providerId = "acedb:" .. tostring(svGlobal ~= "" and svGlobal or baseName)
                    rows[#rows + 1] = { id = providerId, name = baseName, sv = svGlobal, db = db }
                end
            end
        end
    end

    local counts = {}
    for _, r in ipairs(rows) do
        local n = tostring(r.name or "")
        counts[n] = (counts[n] or 0) + 1
    end

    for _, r in ipairs(rows) do
        if counts[tostring(r.name or "")] and counts[tostring(r.name or "")] > 1 then
            local sv = tostring(r.sv or "")
            if sv ~= "" then
                r.name = string.format("%s (%s)", r.name, sv)
            end
        end
    end

    table.sort(rows, function(a, b) return SortAddons(a.name, b.name) end)

    for _, row in ipairs(rows) do
        self:RegisterProvider(row.id, MakeAceDBScanProvider(row.id, row.name, row.db))
    end

    if self.RefreshMainUI then
        pcall(function() self:RefreshMainUI() end)
    end

    return true
end

function addon:TryRegisterAllProviders()
    for id in pairs(self.ProviderDefs or {}) do
        self:TryRegisterProvider(id)
    end

    self:RebuildAceDBProviders()
    return true
end

local ef = addon._providerEventFrame or CreateFrame("Frame")
addon._providerEventFrame = ef
ef:UnregisterAllEvents()
ef:RegisterEvent("PLAYER_LOGIN")
ef:RegisterEvent("ADDON_LOADED")
ef:SetScript("OnEvent", function(_, event)
    addon:TryRegisterAllProviders()
    if addon.MainUI and addon.MainUI:IsShown() and addon.RefreshMainUI then
        addon:RefreshMainUI()
    end
end)

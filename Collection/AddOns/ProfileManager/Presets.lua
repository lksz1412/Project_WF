local addon = ProfileManager

local LibSerialize = LibStub("LibSerialize")
local LibDeflate   = LibStub("LibDeflate")

local function PM_ErrorHandler(err)
    return tostring(err or "unknown error")
end

local function SafeXCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "Missing function"
    end
    local ok, a, b, c, d = xpcall(fn, PM_ErrorHandler, ...)
    if not ok then
        return false, a
    end
    return true, a, b, c, d
end

local function SerializeAndCompress(tbl)
    local ok, serializedOrErr = SafeXCall(LibSerialize.Serialize, LibSerialize, tbl)
    if not ok or type(serializedOrErr) ~= "string" or serializedOrErr == "" then
        return nil, "LibSerialize serialize failed: " .. tostring(serializedOrErr)
    end

    local compressed = LibDeflate:CompressDeflate(serializedOrErr)
    if not compressed then
        return nil, "LibDeflate compress failed"
    end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    if type(encoded) ~= "string" or encoded == "" then
        return nil, "LibDeflate encode failed"
    end

    return encoded, nil
end

local function EnsureDB()
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.presets = ProfileManagerDB.presets or {}
    addon.db = ProfileManagerDB
    addon.db.favorites = addon.db.favorites or {}
    return addon.db
end

function addon:GetPreset(name)
    EnsureDB()
    return self.db.presets[name]
end

function addon:GetPresetNames()
    EnsureDB()
    local t = {}
    for k in pairs(self.db.presets) do t[#t+1] = k end
    table.sort(t)
    return t
end

function addon:SavePreset(name, selections)
    EnsureDB()
    if not name or name == "" then return false end

    self.db.presets[name] = {
        name = name,
        addons = selections or {},
        savedAt = time()
    }
    return true
end

function addon:DeletePreset(name)
    EnsureDB()
    self.db.presets[name] = nil
end

function addon:RenamePreset(oldName, newName)
    EnsureDB()
    if not oldName or oldName == "" then return false end
    if not newName or newName == "" then return false end
    if self.db.presets[newName] then return false end
    local p = self.db.presets[oldName]
    if not p then return false end

    self.db.presets[oldName] = nil
    p.name = newName
    self.db.presets[newName] = p
    return true
end

local function GetProviderCall(prov)
    if type(prov) ~= "table" then return nil end
    return prov.SetProfile or prov.ApplyProfile
end

local function ProviderRequiresReload(prov)
    if type(prov) ~= "table" then return false end

    if prov.RequiresReload == true then return true end

    if type(prov.RequiresReload) == "function" then
        local ok, ret = SafeXCall(prov.RequiresReload, prov)
        if ok and ret then return true end
    end

    return false
end

function addon:CaptureCurrentSelections()
    local out = {}

    for providerId, prov in pairs(self.Providers or {}) do
        if type(prov) == "table" and type(prov.GetCurrentProfile) == "function" then
            local ok, cur = SafeXCall(prov.GetCurrentProfile, prov)
            if ok and cur ~= nil then
                out[providerId] = cur
            end
        end
    end

    return out
end

function addon:ApplyProfilesMap(map)
    if InCombatLockdown() then
        print("|cffff5555ProfileManager|r Cannot apply profiles in combat.")
        return false
    end

    local anyApplied = false
    local needsReload = false
    local skipped = {}

    for providerId, profile in pairs(map or {}) do
        local prov = self.Providers and self.Providers[providerId]
        local fn = GetProviderCall(prov)
        if type(fn) ~= "function" then
            skipped[#skipped + 1] = { id = providerId, profile = profile, reason = "not loaded" }
        else
            local ok, retOrErr = SafeXCall(fn, prov, profile)
            if ok and retOrErr ~= false then
                anyApplied = true
                if ProviderRequiresReload(prov) then
                    needsReload = true
                end
            else
                if not ok then
                    print("|cffff5555ProfileManager|r Apply failed " .. tostring(providerId) .. ": " .. tostring(retOrErr))
                end
                skipped[#skipped + 1] = { id = providerId, profile = profile, reason = "failed" }
            end
        end
    end

    return anyApplied, needsReload, skipped
end

function addon:DescribeSkipped(skipped)
    if type(skipped) ~= "table" or #skipped == 0 then return nil end
    local parts = {}
    for _, s in ipairs(skipped) do
        local prov = self.Providers and self.Providers[s.id]
        local label = (type(prov) == "table" and type(prov.displayName) == "string" and prov.displayName ~= "")
            and prov.displayName or tostring(s.id):gsub("^acedb:", "")
        if s.reason == "not loaded" then
            parts[#parts + 1] = ("%s (addon not loaded)"):format(label)
        else
            parts[#parts + 1] = ("%s (couldn't switch to '%s')"):format(label, tostring(s.profile))
        end
    end
    table.sort(parts)
    return "Not switched: " .. table.concat(parts, ", ") .. "."
end

function addon:ApplyPreset(presetName)
    local preset = self:GetPreset(presetName)
    if not preset then return false end
    return self:ApplyProfilesMap(preset.addons or {})
end

function addon:ExportPreset(presetName)
    local preset = self:GetPreset(presetName)
    if not preset then return nil, "Preset not found" end

    local payload = {
        v = 2,
        type = "Preset",
        name = presetName,
        addons = {}
    }

    for providerId, profileName in pairs(preset.addons or {}) do
        local prov = self.Providers and self.Providers[providerId]
        if prov and type(prov.ExportProfile) == "function" then
            local ok, strOrNil = SafeXCall(prov.ExportProfile, prov, profileName)
            if ok and type(strOrNil) == "string" and strOrNil ~= "" then
                payload.addons[providerId] = strOrNil
            end
        end
    end

    return SerializeAndCompress(payload)
end

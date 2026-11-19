local addon = ProfileManager

local AO = {}
addon.Addons = AO

local SELF = "ProfileManager"

function AO:IsAvailable()
    return C_AddOns and type(C_AddOns.GetNumAddOns) == "function" and type(C_AddOns.EnableAddOn) == "function"
        and type(C_AddOns.DisableAddOn) == "function" and type(C_AddOns.GetAddOnEnableState) == "function"
end

function AO:Character()
    local guid = UnitGUID and UnitGUID("player")
    if guid and not (issecretvalue and issecretvalue(guid)) then return guid end
    return UnitName("player")
end

local function IsSecure(index)
    local sec = C_AddOns.GetAddOnSecurity and C_AddOns.GetAddOnSecurity(index)
    return sec == "SECURE" or (Enum.AddOnSecurityStatus and sec == Enum.AddOnSecurityStatus.Secure)
end

local function Markup(index)
    local tex = C_AddOns.GetAddOnMetadata(index, "IconTexture")
    local atlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
    if tex and tex ~= "" and CreateSimpleTextureMarkup then return CreateSimpleTextureMarkup(tex, 16, 16) .. " " end
    if atlas and atlas ~= "" and CreateAtlasMarkup then return CreateAtlasMarkup(atlas, 16, 16) .. " " end
    return ""
end

local list, listVersion = nil, 0

function AO:Invalidate()
    list = nil
    listVersion = listVersion + 1
end

function AO:Version()
    return listVersion
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function() AO:Invalidate() end)

function AO:List()
    if list then return list end
    local out, char = {}, self:Character()
    for i = 1, C_AddOns.GetNumAddOns() do
        if not IsSecure(i) then
            local name = C_AddOns.GetAddOnName(i)
            local title = C_AddOns.GetAddOnTitle(i)
            local loadable, reason = C_AddOns.IsAddOnLoadable(i, char)
            local _, loaded = C_AddOns.IsAddOnLoaded(i)
            local group = C_AddOns.GetAddOnMetadata(i, "Group")
            out[#out + 1] = {
                group    = (group and group ~= "") and group or name,
                index    = i,
                name     = name,
                title    = (title and title ~= "") and title or name,
                icon     = Markup(i),
                enabled  = C_AddOns.GetAddOnEnableState(i, char) > (Enum.AddOnEnableState and Enum.AddOnEnableState.None or 0),
                loaded   = loaded and true or false,
                lod      = C_AddOns.IsAddOnLoadOnDemand(i) and true or false,
                loadable = loadable and true or false,
                reason   = reason,
                locked   = name == SELF,
            }
        end
    end
    local byName = {}
    for _, a in ipairs(out) do byName[a.name] = a end
    for _, a in ipairs(out) do
        local parent = a.group ~= a.name and byName[a.group]
        if parent and parent.group == parent.name then
            a.parent = parent
            parent.children = parent.children or {}
            parent.children[#parent.children + 1] = a
        end
    end
    list = out
    return out
end

function AO:Roots()
    local roots = {}
    for _, a in ipairs(self:List()) do
        if not a.parent then roots[#roots + 1] = a end
    end
    return roots
end

function AO:NeedsReload(a)
    if a.enabled then
        return not a.loaded and not a.lod and a.loadable
    end
    return a.loaded
end

function AO:PendingReloads()
    local n = 0
    for _, a in ipairs(self:List()) do
        if self:NeedsReload(a) then n = n + 1 end
    end
    return n
end

function AO:SetEnabled(name, on)
    if name == SELF and not on then return false end
    local char = self:Character()
    if on then
        C_AddOns.EnableAddOn(name, char)
    else
        C_AddOns.DisableAddOn(name, char)
    end
    C_AddOns.SaveAddOns()
    self:Invalidate()
    return true
end

function AO:SetAll(on)
    local char = self:Character()
    for _, a in ipairs(self:List()) do
        if on then
            C_AddOns.EnableAddOn(a.name, char)
        elseif not a.locked then
            C_AddOns.DisableAddOn(a.name, char)
        end
    end
    C_AddOns.SaveAddOns()
    self:Invalidate()
end

function AO:Snapshot()
    local map = {}
    for _, a in ipairs(self:List()) do map[a.name] = a.enabled end
    return map
end

function AO:Preview(map)
    local changes, known = {}, {}
    for _, a in ipairs(self:List()) do
        known[a.name] = true
        local want = map[a.name]
        if want ~= nil and want ~= a.enabled and not (a.locked and not want) then
            changes[#changes + 1] = { addon = a, to = want }
        end
    end
    local missing = 0
    for name in pairs(map) do
        if not known[name] then missing = missing + 1 end
    end
    return changes, missing
end

function AO:Apply(map)
    local changes = self:Preview(map)
    local char = self:Character()
    for _, c in ipairs(changes) do
        if c.to then
            C_AddOns.EnableAddOn(c.addon.name, char)
        else
            C_AddOns.DisableAddOn(c.addon.name, char)
        end
    end
    C_AddOns.SaveAddOns()
    self:Invalidate()
    return #changes
end

local function Store()
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.addonSets = ProfileManagerDB.addonSets or {}
    return ProfileManagerDB.addonSets
end

local function CleanName(name)
    return (tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function Pack(map)
    local on, off = {}, {}
    for name, enabled in pairs(map) do
        if enabled then on[#on + 1] = name else off[#off + 1] = name end
    end
    table.sort(on)
    table.sort(off)
    return table.concat(on, "\t"), table.concat(off, "\t")
end

local expanded = setmetatable({}, { __mode = "k" })

local function Unpack(s)
    local map = expanded[s]
    if map then return map end
    map = {}
    for name in (s.enabled or ""):gmatch("[^\t]+") do map[name] = true end
    for name in (s.disabled or ""):gmatch("[^\t]+") do map[name] = false end
    expanded[s] = map
    return map
end

function AO:GetSetNames()
    local out = {}
    for name in pairs(Store()) do out[#out + 1] = name end
    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

function AO:GetSet(name)
    local s = Store()[name]
    if not s then return nil end
    return s, Unpack(s)
end

function AO:UniqueSetName(base)
    base = CleanName(base)
    if base == "" then base = "Addons" end
    local store = Store()
    if not store[base] then return base end
    local i = 2
    while store[("%s (%d)"):format(base, i)] do i = i + 1 end
    return ("%s (%d)"):format(base, i)
end

function AO:SaveSet(name, map)
    name = CleanName(name)
    if name == "" then return false, "Enter a set name." end
    local on, off = Pack(map or self:Snapshot())
    Store()[name] = { enabled = on, disabled = off, savedAt = time() }
    return true, name
end

function AO:UpdateSet(name)
    local s, map = self:GetSet(name)
    if not s then return false, ("Addon set '%s' not found."):format(tostring(name)) end
    local merged = {}
    for addonName, enabled in pairs(map) do merged[addonName] = enabled end
    for addonName, enabled in pairs(self:Snapshot()) do merged[addonName] = enabled end
    return self:SaveSet(name, merged)
end

local function RetargetReferences(oldName, newName)
    local db = ProfileManagerDB
    if not db then return end
    if db.newCharAddons == oldName then db.newCharAddons = newName or "" end
    for _, cd in pairs(db.charPresets or {}) do
        if type(cd) == "table" and cd.addons == oldName then cd.addons = newName or "" end
    end
end

function AO:DeleteSet(name)
    Store()[name] = nil
    RetargetReferences(name, nil)
end

function AO:RenameSet(oldName, newName)
    newName = CleanName(newName)
    local store = Store()
    if newName == "" then return false, "Enter a set name." end
    if not store[oldName] then return false, "Set not found." end
    if newName == oldName then return true, newName end
    if store[newName] then return false, "A set with that name already exists." end
    store[newName], store[oldName] = store[oldName], nil
    RetargetReferences(oldName, newName)
    return true, newName
end

function AO:LoadSet(name)
    local s, map = self:GetSet(name)
    if not s then return false, ("Addon set '%s' not found."):format(tostring(name)) end
    self:Invalidate()
    return true, self:Apply(map)
end

function AO:MatchingSets()
    local out = {}
    for _, name in ipairs(self:GetSetNames()) do
        local _, map = self:GetSet(name)
        if map and #(self:Preview(map)) == 0 then out[#out + 1] = name end
    end
    return out
end

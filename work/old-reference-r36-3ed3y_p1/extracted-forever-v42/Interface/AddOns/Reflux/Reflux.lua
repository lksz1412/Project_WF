-- Forever v1: private API aliases; Blizzard globals are never replaced.
local AddOns = C_AddOns or {}
local GetNumAddOns = AddOns.GetNumAddOns or GetNumAddOns
local GetAddOnInfo = AddOns.GetAddOnInfo or GetAddOnInfo
local GetAddOnMetadata = AddOns.GetAddOnMetadata or GetAddOnMetadata
local IsAddOnLoadOnDemand = AddOns.IsAddOnLoadOnDemand or IsAddOnLoadOnDemand
local IsAddOnLoaded = AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn = AddOns.LoadAddOn or LoadAddOn
local EnableAddOn = AddOns.EnableAddOn or EnableAddOn
local DisableAddOn = AddOns.DisableAddOn or DisableAddOn
local legacyEnableState = _G.GetAddOnEnableState
local function addonEnableState(name)
    if AddOns.GetAddOnEnableState then return AddOns.GetAddOnEnableState(name) end
    if legacyEnableState then return legacyEnableState(UnitName("player"), name) end
    return 0
end

local function initializeDatabase()
    if type(RefluxDB) ~= "table" then RefluxDB = {} end
    for _, key in ipairs({"profiles", "emulated", "addons", "ignored"}) do
        if type(RefluxDB[key]) ~= "table" then RefluxDB[key] = {} end
    end
    if type(RefluxDB.activeProfile) ~= "string" or RefluxDB.activeProfile == "" then
        RefluxDB.activeProfile = false
    end
end
local startup = CreateFrame("Frame")
startup:RegisterEvent("ADDON_LOADED")
startup:SetScript("OnEvent", function(self, _, name)
    if name == "Reflux" then
        initializeDatabase()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
local restoreAtLogout

local emulated_default_addons = {}

-- Deep copy with metatable support
local function DeepCopy(orig, lookup)
    lookup = lookup or {}
    if type(orig) ~= "table" then return orig end
    if lookup[orig] then return lookup[orig] end
    local copy = {}
    lookup[orig] = copy
    for k, v in pairs(orig) do
        copy[DeepCopy(k, lookup)] = DeepCopy(v, lookup)
    end
    -- SavedVariables contain data, never runtime metatables.
    return copy
end

local function loadAceLibs()
    local addonsToLoad = {"Ace2", "Ace3", "LibRock-1.0"}
    for _, addon in ipairs(addonsToLoad) do
        if GetAddOnInfo(addon) and IsAddOnLoadOnDemand(addon) and not IsAddOnLoaded(addon) then
            LoadAddOn(addon)
        end
    end
end

local function getDbNameForSv(sv)
    for k, v in pairs(_G) do
        if v == sv then return k end
    end
    return nil
end

local function isIgnored(dbName)
    if dbName and RefluxDB.ignored then
        return RefluxDB.ignored[dbName] ~= nil
    end
    return false
end

local function setAceProfile(profile, addon)
    loadAceLibs()

    local LibStub = _G.LibStub
    local AceLibrary = _G.AceLibrary
    local Rock = _G.Rock

    if LibStub then
        local AceDB = LibStub:GetLibrary("AceDB-3.0", true)
        if AceDB and AceDB.db_registry then
            for db in pairs(AceDB.db_registry) do
                if not db.parent then
                    local dbName = getDbNameForSv(db.sv)
                    if not isIgnored(dbName) then
                        if addon then
                            if dbName == addon or db.sv == _G[addon] then
                                db:SetProfile(profile)
                            end
                        else
                            db:SetProfile(profile)
                        end
                    end
                end
            end
        end
    end

    if AceLibrary and AceLibrary:HasInstance("AceDB-2.0") then
        local AceDB = AceLibrary("AceDB-2.0")
        if AceDB and AceDB.registry then
            for db in pairs(AceDB.registry) do
                if not isIgnored(db.db.name) then
                    if addon then
                        if db.db.name == addon then
                            db:SetProfile(profile)
                        end
                    else
                        if db:IsActive() then
                            db:SetProfile(profile)
                        else
                            db:ToggleActive(true)
                            db:SetProfile(profile)
                            db:ToggleActive(false)
                        end
                    end
                end
            end
        end
    end

    if Rock and Rock:HasLibrary("LibRockDB-1.0") then
        local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
        if RockDB and RockDB.data then
            for db in pairs(RockDB.data) do
                if not isIgnored(db.dbName) then
                    if addon then
                        if db.dbName == addon then
                            db:SetProfile(profile)
                        end
                    else
                        db:SetProfile(profile)
                    end
                end
            end
        end
    end
end

local function cloneProfiles(profile)
    loadAceLibs()

    local LibStub = _G.LibStub
    local AceLibrary = _G.AceLibrary
    local Rock = _G.Rock

    if LibStub then
        local AceDB = LibStub:GetLibrary("AceDB-3.0", true)
        if AceDB and AceDB.db_registry then
            for db in pairs(AceDB.db_registry) do
                if not db.parent and not isIgnored(getDbNameForSv(db.sv)) then
                    local currentProfile = db:GetCurrentProfile()
                    if currentProfile ~= profile then
                        db:SetProfile(profile)
                        db:CopyProfile(currentProfile, true)
                        db:SetProfile(currentProfile)
                    end
                end
            end
        end
    end

    if AceLibrary and AceLibrary:HasInstance("AceDB-2.0") then
        local AceDB = AceLibrary("AceDB-2.0")
        if AceDB and AceDB.registry then
            for db in pairs(AceDB.registry) do
                local function copyProfileSafe()
                    local currentProfile = db:GetProfile()
                    db:SetProfile(profile)
                    if currentProfile ~= profile then db:CopyProfileFrom(currentProfile) end
                    db:SetProfile(currentProfile)
                end
                if isIgnored(db.db.name) then
                    -- Respect ignored legacy databases too.
                elseif db:IsActive() then
                    pcall(copyProfileSafe)
                else
                    db:ToggleActive(true)
                    pcall(copyProfileSafe)
                    db:ToggleActive(false)
                end
            end
        end
    end

    if Rock and Rock:HasLibrary("LibRockDB-1.0") then
        local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
        if RockDB and RockDB.data then
            for db in pairs(RockDB.data) do
                if not isIgnored(db.dbName) then
                    local currentProfile = db:GetProfile()
                    if currentProfile ~= profile then
                        db:SetProfile(profile)
                        db:CopyProfile(currentProfile)
                        db:SetProfile(currentProfile)
                    end
                end
            end
        end
    end
end

local function copyAceProfile(profile)
    loadAceLibs()

    local LibStub = _G.LibStub
    local AceLibrary = _G.AceLibrary
    local Rock = _G.Rock

    if LibStub then
        local AceDB = LibStub:GetLibrary("AceDB-3.0", true)
        if AceDB and AceDB.db_registry then
            for db in pairs(AceDB.db_registry) do
                if not db.parent and not isIgnored(getDbNameForSv(db.sv))
                    and db:GetCurrentProfile() ~= profile and db.sv.profiles and db.sv.profiles[profile] then
                    db:CopyProfile(profile, true)
                end
            end
        end
    end

    if AceLibrary and AceLibrary:HasInstance("AceDB-2.0") then
        local AceDB = AceLibrary("AceDB-2.0")
        if AceDB and AceDB.registry then
            for db in pairs(AceDB.registry) do
                local function cp()
                    db:CopyProfileFrom(profile)
                end
                if isIgnored(db.db.name) then
                elseif db:IsActive() then
                    pcall(cp)
                else
                    db:ToggleActive(true)
                    pcall(cp)
                    db:ToggleActive(false)
                end
            end
        end
    end

    if Rock and Rock:HasLibrary("LibRockDB-1.0") then
        local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
        if RockDB and RockDB.data then
            for db in pairs(RockDB.data) do
                if not isIgnored(db.dbName) then db:CopyProfile(profile) end
            end
        end
    end
end

local function deleteAceProfile(profile)
    loadAceLibs()

    local LibStub = _G.LibStub
    local AceLibrary = _G.AceLibrary
    local Rock = _G.Rock

    if LibStub then
        local AceDB = LibStub:GetLibrary("AceDB-3.0", true)
        if AceDB and AceDB.db_registry then
            for db in pairs(AceDB.db_registry) do
                if not db.parent then
                    db:DeleteProfile(profile, true)
                end
            end
        end
    end

    if AceLibrary and AceLibrary:HasInstance("AceDB-2.0") then
        local AceDB = AceLibrary("AceDB-2.0")
        if AceDB and AceDB.registry then
            for db in pairs(AceDB.registry) do
                local function cp()
                    db:DeleteProfile(profile, true)
                end
                pcall(cp)
            end
        end
    end

    if Rock and Rock:HasLibrary("LibRockDB-1.0") then
        local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
        if RockDB and RockDB.data then
            for db in pairs(RockDB.data) do
                db:RemoveProfile(profile)
            end
        end
    end
end

local function showHelp()
    print("/reflux switch [profile name]")
    print("This switches to a given profile. Emulated variables are only touched if you previously created a profile in reflux. This automatically Reloads the UI")
    print("/reflux addons [profile name]")
    print("This restores a previously saved set of addons. Due to technical reasons, it cant switch profiles at the same time. This automatically Reloads the UI")
    print("/reflux create [profile name]")
    print("This created a profile set.")
    print("/reflux add [saved variable]")
    print("This will add a given saved variable to the profile emulation. You will need to get this name from the .toc file")
    print("/reflux save <addons>")
    print("This saves the emulated profiles. Optionally if you can save addon state as well in the profile.")
    print("/reflux cleardb")
    print("This will clear out all Reflux saved information.")
    print("/reflux show")
    print("This will show you what the active profile is, and all emulated variables.")
    print("/reflux copy [profile to copy]")
    print("This will attempt to copy the provide profile to the current profile. This automatically Reloads the UI.")
    print("/reflux delete [profile]")
    print("This is delete a given profile. Please NOTE you can NOT delete the active profile.")
    print("/reflux switchexact addonSVName profile")
    print("This will reset JUST the profiled addonSVname to the given profile. This requires advance knowledge of the addon saved variable name.")
    print("/reflux snapshot [new profile name]")
    print("This will instruct Reflux to scan your profiles and copy them into the new profile name. This command should allow you to snapshot your current config to a new profile.")
    print("/reflux ignore [saved variable]")
    print("This will mark the saved variable as ignored for the context of switching.")
    print("/reflux unignore [saved variable]")
    print("This will remove a previously set ignore.")
end

local function storeAddonState(tbl)
    local count = GetNumAddOns()
    for index = 1, count do
        local name = GetAddOnInfo(index)
        if name then tbl[name] = addonEnableState(name) > 0 and 1 or 0 end
    end
end

local function getAddonSV(tbl)
    local count = GetNumAddOns()
    for index = 1, count do
        local name = GetAddOnInfo(index)
        local variables = GetAddOnMetadata(name, "SavedVariables")
        tbl[name] = variables or ""
        if variables then
            print("Addon: "..name.." SV: "..variables)
        end
    end
end

local function restoreAddonState(tbl)
    for k, v in pairs(tbl) do
        if GetAddOnInfo(k) then
            if v == 1 then EnableAddOn(k) else DisableAddOn(k) end
        end
    end
    ReloadUI()
end

SlashCmdList["REFLUX"] = function(msg)
    initializeDatabase()
    local cmd, arg = string.match(msg or "", "^%s*([^%s]+)%s*(.-)%s*$")
    cmd = cmd and cmd:lower()
    if not cmd or #cmd == 0 or cmd == "help" then
        showHelp()
        return
    end

    if cmd ~= "show" and InCombatLockdown and InCombatLockdown() then
        print("Reflux: 전투가 끝난 뒤 프로필 명령을 실행해 주세요.")
        return
    end

    if cmd == "show" then
        if RefluxDB.activeProfile then
            print("Active Profile is "..RefluxDB.activeProfile)
        else
            print("There is no active profile")
        end
        for k in pairs(RefluxDB.profiles) do
            print(k.." is an available profile.")
        end
        if RefluxDB.emulated then
            if #RefluxDB.emulated < 1 then
                print("Nothing is being emulated.")
            end
            for _, var in pairs(RefluxDB.emulated) do
                print(var.." is being emulated.")
            end
        end
        if RefluxDB.addons and RefluxDB.activeProfile and RefluxDB.addons[RefluxDB.activeProfile] then
            print("Addon state for the active profile")
            for k,v in pairs(RefluxDB.addons[RefluxDB.activeProfile]) do
                local state = (v == 1) and "on" or "off"
                print(k..":"..state)
            end
        else
            print("Addon state is not being saved.")
        end
        if RefluxDB.ignored then
            for k in pairs(RefluxDB.ignored) do
                print(k.." is being ignored for switching.")
            end
        end
        local tbl = {}
        getAddonSV(tbl)
    elseif cmd == "switchexact" then
        local addonName, profileName = string.match(arg, "%s*([^%s]+)%s*(.*)")
        if not addonName or not profileName or profileName == "" then
            showHelp()
            return
        end
        setAceProfile(profileName, addonName)
    elseif cmd == "switch" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if RefluxDB.profiles[arg] then
            for k, v in pairs(RefluxDB.profiles[arg]) do
                if type(k) == "string" and k ~= "RefluxDB" and not isIgnored(k) then
                    _G[k] = DeepCopy(v)
                end
            end
        end
        setAceProfile(arg)
        RefluxDB.activeProfile = arg

        restoreAtLogout = restoreAtLogout or CreateFrame("Frame", "RefluxEmulator")
        restoreAtLogout:RegisterEvent("PLAYER_LOGOUT")
        restoreAtLogout:SetScript("OnEvent", function()
            if RefluxDB.profiles[arg] then
                for k, v in pairs(RefluxDB.profiles[arg]) do
                    if type(k) == "string" and k ~= "RefluxDB" and not isIgnored(k) then
                        _G[k] = DeepCopy(v)
                    end
                end
            end
        end)

        ReloadUI()
    elseif cmd == "addons" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if RefluxDB.addons[arg] then
            restoreAddonState(RefluxDB.addons[arg])
        end
    elseif cmd == "cleardb" then
        RefluxDB = { profiles = {}, activeProfile = false, emulated = {}, addons = {}, ignored = {} }
        print("Reflux database cleared.")
    elseif cmd == "save" then
        if not RefluxDB.activeProfile then
            print("No profiles are active, please create or switch to one.")
            return
        end
        RefluxDB.profiles[RefluxDB.activeProfile] = {}
        for _, var in ipairs(RefluxDB.emulated) do
            if type(var) == "string" and var ~= "RefluxDB" and not isIgnored(var) then
                RefluxDB.profiles[RefluxDB.activeProfile][var] = DeepCopy(_G[var])
                print("Saving "..var)
            end
        end
        if arg == "addons" then
            RefluxDB.addons[RefluxDB.activeProfile] = {}
            storeAddonState(RefluxDB.addons[RefluxDB.activeProfile])
            print("Saving addon state.")
        end
    elseif cmd == "create" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if not RefluxDB.profiles[arg] then
            RefluxDB.profiles[arg] = {}
            RefluxDB.activeProfile = arg
            print("Created and switched to profile "..arg)
        else
            print("Profile "..arg.." already exists.")
        end
    elseif cmd == "add" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if not arg:match("^[%a_][%w_]*$") or arg == "RefluxDB" or arg == "_G" then
            print("Reflux: 올바른 SavedVariables 이름을 입력해 주세요.")
            return
        end
        local found = false
        for _, v in ipairs(RefluxDB.emulated) do
            if v == arg then
                found = true
                break
            end
        end
        if not found then
            table.insert(RefluxDB.emulated, arg)
            print("Adding "..arg.." to emulated variables.")
        else
            print(arg.." already emulated.")
        end
    elseif cmd == "copy" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        copyAceProfile(arg)
        local source = RefluxDB.profiles[arg]
        if source and RefluxDB.activeProfile ~= arg then
            if RefluxDB.activeProfile then RefluxDB.profiles[RefluxDB.activeProfile] = DeepCopy(source) end
            for key, value in pairs(source) do
                if type(key) == "string" and key ~= "RefluxDB" and not isIgnored(key) then _G[key] = DeepCopy(value) end
            end
            restoreAtLogout = restoreAtLogout or CreateFrame("Frame", "RefluxEmulator")
            restoreAtLogout:RegisterEvent("PLAYER_LOGOUT")
            restoreAtLogout:SetScript("OnEvent", function()
                for key, value in pairs(source) do
                    if type(key) == "string" and key ~= "RefluxDB" and not isIgnored(key) then _G[key] = DeepCopy(value) end
                end
            end)
        end
        ReloadUI()
    elseif cmd == "delete" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if RefluxDB.activeProfile == arg then
            print("Cannot delete the active profile.")
            return
        end
        RefluxDB.profiles[arg] = nil
        print("Deleted profile "..arg)
    elseif cmd == "ignore" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        RefluxDB.ignored = RefluxDB.ignored or {}
        RefluxDB.ignored[arg] = true
        print("Ignoring "..arg.." for switching.")
    elseif cmd == "unignore" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if RefluxDB.ignored then
            RefluxDB.ignored[arg] = nil
            print("Removed ignore for "..arg)
        end
    elseif cmd == "snapshot" then
        if not arg or #arg == 0 then
            showHelp()
            return
        end
        if RefluxDB.profiles[arg] then
            print("Profile "..arg.." already exists.")
            return
        end
        cloneProfiles(arg)
        local snapshot = {}
        for _, var in ipairs(RefluxDB.emulated) do
            if type(var) == "string" and var ~= "RefluxDB" and not isIgnored(var) then snapshot[var] = DeepCopy(_G[var]) end
        end
        RefluxDB.profiles[arg] = snapshot
        print("Created snapshot profile "..arg)
    else
        showHelp()
    end
end

SLASH_REFLUX1 = "/reflux"

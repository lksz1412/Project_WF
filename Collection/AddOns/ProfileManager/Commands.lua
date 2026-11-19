local addon = ProfileManager

SLASH_PROFILEMANAGER1 = "/pm"

local GREEN, RED, YELLOW = "|cff00ff00", "|cffff5555", "|cffffd100"

local function Say(color, text)
    print(color .. "ProfileManager|r " .. text)
end

local function Join(list)
    return #list > 0 and table.concat(list, ", ") or "|cff9aa0a6none|r"
end

local function FindName(names, wanted)
    local lower = wanted:lower()
    for _, n in ipairs(names) do
        if n == wanted then return n end
    end
    for _, n in ipairs(names) do
        if n:lower() == lower then return n end
    end
end

local KINDS = {
    {
        key = "preset",
        label = "preset",
        plural = "Presets",
        noCombat = true,
        available = function() return true end,
        names = function() return addon:GetPresetNames() end,
        save = function(name)
            if addon.TryRegisterAllProviders then addon:TryRegisterAllProviders() end
            addon:SavePreset(name, addon:CaptureCurrentSelections())
            return true, ("Saved preset '%s'."):format(name)
        end,
        apply = function(name)
            if addon.TryRegisterAllProviders then addon:TryRegisterAllProviders() end
            local total = 0
            for _ in pairs(addon:GetPreset(name).addons or {}) do total = total + 1 end
            if total == 0 then return false, ("Preset '%s' has no addon profiles in it."):format(name) end
            local applied, needsReload, skipped = addon:ApplyPreset(name)
            skipped = skipped or {}
            local msg = ("Applied preset '%s': %d of %d addon profile(s) switched."):format(name, total - #skipped, total)
            local notSwitched = addon:DescribeSkipped(skipped)
            if notSwitched then msg = msg .. " " .. notSwitched end
            if not applied then return false, msg end
            return true, msg, needsReload, notSwitched ~= nil
        end,
    },
    {
        key = "keybinds",
        label = "keybinds",
        plural = "Keybinds",
        noCombat = true,
        available = function() return addon.Keybinds and addon.Keybinds:IsAvailable() end,
        names = function() return addon.Keybinds:GetProfileNames() end,
        save = function(name)
            local KB = addon.Keybinds
            local ok, savedOrErr
            if KB:GetProfile(name) then ok, savedOrErr = KB:UpdateProfile(name) else ok, savedOrErr = KB:SaveProfile(name) end
            if not ok then return false, savedOrErr end
            return true, ("Saved keybinds '%s' (%s bindings)."):format(savedOrErr, addon.Keybinds:SetName())
        end,
        apply = function(name)
            local ok, appliedOrErr, failed, untouched = addon.Keybinds:LoadProfile(name)
            if not ok then return false, appliedOrErr end
            local msg = ("Loaded keybinds '%s': %d key(s) bound."):format(name, appliedOrErr)
            if failed and failed > 0 then msg = msg .. (" %d couldn't be bound."):format(failed) end
            if untouched and untouched > 0 then
                msg = msg .. (" %d bound action(s) aren't in this profile and kept their keys."):format(untouched)
            end
            return true, msg, false, (failed or 0) + (untouched or 0) > 0
        end,
    },
    {
        key = "addons",
        label = "addon set",
        plural = "Addon sets",
        available = function() return addon.Addons and addon.Addons:IsAvailable() end,
        names = function() return addon.Addons:GetSetNames() end,
        save = function(name)
            local AO = addon.Addons
            local ok, savedOrErr
            if AO:GetSet(name) then ok, savedOrErr = AO:UpdateSet(name) else ok, savedOrErr = AO:SaveSet(name) end
            if not ok then return false, savedOrErr end
            return true, ("Saved addon set '%s'."):format(savedOrErr)
        end,
        apply = function(name)
            local ok, changedOrErr = addon.Addons:LoadSet(name)
            if not ok then return false, changedOrErr end
            if changedOrErr == 0 then
                return true, ("Addon set '%s' already matches this character."):format(name)
            end
            return true, ("Loaded addon set '%s': %d change(s)."):format(name, changedOrErr), true
        end,
    },
    {
        key = "settings",
        label = "game settings",
        plural = "Game settings",
        noCombat = true,
        available = function() return addon.GameSettings and addon.GameSettings:IsAvailable() end,
        names = function() return addon.GameSettings:GetProfileNames() end,
        save = function(name)
            local GS = addon.GameSettings
            local ok, savedOrErr
            if GS:GetProfile(name) then ok, savedOrErr = GS:UpdateProfile(name) else ok, savedOrErr = GS:SaveProfile(name) end
            if not ok then return false, savedOrErr end
            return true, ("Saved game settings '%s'."):format(savedOrErr)
        end,
        apply = function(name)
            local ok, appliedOrErr, failed, needsRestart, failedNames, untouched = addon.GameSettings:LoadProfile(name)
            if not ok then return false, appliedOrErr end
            local msg = ("Loaded game settings '%s': %d setting(s) changed."):format(name, appliedOrErr)
            if failed and failed > 0 then
                msg = msg .. (" %d couldn't be set: %s."):format(failed, table.concat(failedNames or {}, ", "))
            end
            if untouched and untouched > 0 then
                msg = msg .. (" %d setting(s) aren't in this profile and kept their values."):format(untouched)
            end
            if needsRestart then msg = msg .. " Some of them take effect after you restart the game." end
            return true, msg, false, (failed or 0) + (untouched or 0) > 0
        end,
    },
}

local KIND_BY_KEY = {}
for _, k in ipairs(KINDS) do KIND_BY_KEY[k.key] = k end

local KIND_WORDS = {
    preset = "preset", presets = "preset",
    keybinds = "keybinds", keybind = "keybinds", keys = "keybinds", binds = "keybinds",
    addons = "addons", addon = "addons", sets = "addons",
    settings = "settings", setting = "settings", game = "settings",
    all = "all",
}

local ACTION_WORDS = { apply = "apply", load = "apply", save = "save", list = "list", help = "help" }

local function PrintHelp()
    print(GREEN .. "ProfileManager commands:|r")
    print("/pm   Open the window")
    print("/pm apply <preset>   Apply a preset")
    print("/pm apply keybinds <name>   Load a keybind profile")
    print("/pm apply addons <name>   Load an addon set for this character")
    print("/pm apply settings <name>   Load a game settings profile")
    print("/pm apply all <name>   Load every profile saved under that name")
    print("/pm save <preset>   Save the current addon profiles as a preset")
    print("/pm save keybinds|addons|settings <name>   Save the current keybinds, addons or game settings")
    print("/pm save all <name>   Save a preset, keybinds, addon set and game settings under one name")
    print("/pm list   Show everything saved")
    print("Put ; between commands to run several at once:")
    print("/pm apply Raid; apply keybinds Healer; apply settings Low")
end

local function PrintList(only)
    print(GREEN .. "ProfileManager saved profiles:|r")
    for _, k in ipairs(KINDS) do
        if (not only or only == k.key) and k.available() then
            print(("%s: %s"):format(k.plural, Join(k.names())))
        end
    end
end

local function CleanName(s)
    s = strtrim(s or "")
    local unquoted = s:match('^"(.*)"$') or s:match("^'(.*)'$")
    return strtrim(unquoted or s)
end

local function ParseSegment(seg)
    seg = strtrim(seg or ""):gsub("^/pm%s*", "")
    if seg == "" then return nil end

    local first, rest = seg:match("^(%S+)%s*(.*)$")
    local action = ACTION_WORDS[first:lower()]
    if not action then return { error = ("Unknown command '%s'. Type /pm help."):format(first) } end
    if action == "help" then return { action = "help" } end

    local kind
    local word, after = rest:match("^(%S+)%s*(.*)$")
    if word and KIND_WORDS[word:lower()] then
        kind, rest = KIND_WORDS[word:lower()], after
    end

    if action == "list" then return { action = "list", kind = kind ~= "all" and kind or nil } end

    local name = CleanName(rest)
    if name == "" then
        return { error = ("Missing a name after '%s'."):format(strtrim(seg)) }
    end
    return { action = action, kind = kind or "preset", name = name }
end

local function Expand(cmd, steps, problems)
    local kinds = {}
    if cmd.kind == "all" then
        for _, k in ipairs(KINDS) do
            if k.available() then kinds[#kinds + 1] = k end
        end
    else
        local k = KIND_BY_KEY[cmd.kind]
        if not k.available() then
            problems[#problems + 1] = ("%s aren't available in this game."):format(k.plural)
            return
        end
        kinds[1] = k
    end

    local found = 0
    for _, k in ipairs(kinds) do
        local existing = FindName(k.names(), cmd.name)
        if cmd.action == "apply" then
            if existing then
                steps[#steps + 1] = { action = "apply", kind = k, name = existing }
                found = found + 1
            elseif cmd.kind ~= "all" then
                problems[#problems + 1] = ("No %s named '%s'."):format(k.label, cmd.name)
            end
        else
            steps[#steps + 1] = { action = "save", kind = k, name = existing or cmd.name, overwrite = existing ~= nil }
        end
    end
    if cmd.action == "apply" and cmd.kind == "all" and found == 0 then
        problems[#problems + 1] = ("Nothing is saved under '%s'."):format(cmd.name)
    end
end

local function Run(steps)
    local needsReload = false
    for _, s in ipairs(steps) do
        local ok, msg, reload, partial = s.kind[s.action](s.name)
        Say(not ok and RED or partial and YELLOW or GREEN, msg or "")
        if ok and reload then needsReload = true end
    end
    if addon.MainUI and addon.MainUI:IsShown() and addon.RefreshMainUI then addon:RefreshMainUI() end
    if needsReload and addon.ShowForceReloadPopup then
        addon:ShowForceReloadPopup("Profiles applied.\n\nSome addons require reload to apply changes")
    end
end

StaticPopupDialogs["PROFILEMANAGER_CMD_OVERWRITE"] = {
    text = "Save your current setup into %s?",
    button1 = SAVE or "Save",
    button2 = "Cancel",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnAccept = function(_, steps) Run(steps) end,
}

SlashCmdList["PROFILEMANAGER"] = function(msg)
    msg = strtrim(msg or "")
    if msg == "" then
        addon:ShowMainUI()
        return
    end

    local steps, problems = {}, {}
    local combat = InCombatLockdown()
    for seg in (msg .. ";"):gmatch("([^;]*);") do
        local cmd = ParseSegment(seg)
        if cmd then
            if cmd.error then
                problems[#problems + 1] = cmd.error
            elseif cmd.action == "help" then
                PrintHelp()
            elseif cmd.action == "list" then
                PrintList(cmd.kind)
            else
                Expand(cmd, steps, problems)
            end
        end
    end

    for _, s in ipairs(steps) do
        if combat and s.action == "apply" and s.kind.noCombat then
            problems[#problems + 1] = ("Can't load %s '%s' in combat."):format(s.kind.label, s.name)
        end
    end

    if #problems > 0 then
        for _, p in ipairs(problems) do Say(RED, p) end
        if #steps > 0 then Say(YELLOW, "Nothing was changed.") end
        return
    end
    if #steps == 0 then return end

    local overwrites = {}
    for _, s in ipairs(steps) do
        if s.overwrite then overwrites[#overwrites + 1] = ("%s '%s'"):format(s.kind.label, s.name) end
    end
    if #overwrites > 0 then
        StaticPopup_Show("PROFILEMANAGER_CMD_OVERWRITE", table.concat(overwrites, ", "), nil, steps)
        return
    end
    Run(steps)
end

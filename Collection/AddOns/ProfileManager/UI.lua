local addon = ProfileManager

local LibSerialize = LibStub("LibSerialize")
local LibDeflate   = LibStub("LibDeflate")

local THEME = {
    frameBg      = { 0.06, 0.06, 0.07, 0.96 },
    panelBg      = { 0.03, 0.03, 0.04, 0.70 },
    panelBorder  = { 1, 1, 1, 0.08 },
    rowBg        = { 1, 1, 1, 0.03 },
    rowHover     = { 0.35, 0.65, 1.00, 0.10 },
    rowSelected  = { 0.35, 0.65, 1.00, 0.18 },
    titleText    = { 0.95, 0.95, 0.98, 1.00 },
    text         = { 0.88, 0.88, 0.90, 1.00 },
    mutedText    = { 0.70, 0.70, 0.74, 1.00 },
    divider      = { 1, 1, 1, 0.14 },
}

local EDITOR_ROW_HEIGHT  = 34
local LEFT_PANEL_WIDTH   = 305
local LEFT_PANEL_GAP     = 6
local PRESET_ROW_H       = 26

local MAIN_W             = 1000
local MAIN_H             = 700
local MIN_W              = 880
local MIN_H              = 656

local FAV_BTN_W        = 26
local FAV_GAP_L        = 5
local NAME_EXTRA_PAD   = 2

local PURPLE_BAR_H       = 46
local DROPDOWN_FIXED_W   = 170

local LIVE_ICON = "|TInterface\\Buttons\\UI-CheckBox-Check:14:14:0:0|t "
local RELOAD_PREFIX = "|cffffaa00(reload)|r "

local PM_PRIV_PREFIX = addon.PM_PRIV_PREFIX or "\1priv\1"
local PM_PRIV_SUFFIX = "  |cff808080(Private)|r"

local function PM_ProfileDisplayLabel(name)
    local s = tostring(name or "")
    if s:sub(1, #PM_PRIV_PREFIX) == PM_PRIV_PREFIX then
        return s:sub(#PM_PRIV_PREFIX + 1) .. PM_PRIV_SUFFIX
    end
    return s
end

local function PM_GetAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata("ProfileManager", "Version")
    end
    if GetAddOnMetadata then
        return GetAddOnMetadata("ProfileManager", "Version")
    end
    return nil
end

local function SafeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function WipeRows(rows)
    if not rows then return end
    for _, r in ipairs(rows) do r:Hide() end
    wipe(rows)
end

local function Delay(seconds, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(seconds or 0, fn)
    else
        fn()
    end
end

local function Clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local PM_PENDING_APPLY_PROFILES_KEY = "_pmApplyOnLoginProfiles"

local function PM_IsFavorite(providerId)
  local fav = addon.db and addon.db.favorites
  return fav and fav[providerId] == true
end

local function PM_ToggleFavorite(providerId)
  addon.db = addon.db or ProfileManagerDB
  addon.db.favorites = addon.db.favorites or {}
  addon.db.favorites[providerId] = not addon.db.favorites[providerId]
end

local function PM_SetFavoriteIcon(tex, isFav)
    if not tex then return end

    tex:SetTexture("Interface\\COMMON\\FavoritesIcon")
    tex:SetTexCoord(0, 1, 0, 1)
    tex:SetDesaturated(false)

    if isFav then
        tex:SetAlpha(1)
    else
        tex:SetAlpha(0.15)
    end
end

function addon:PM_AddPendingApplyProfile(providerId, profileName)
    ProfileManagerDB = ProfileManagerDB or {}
    local t = ProfileManagerDB[PM_PENDING_APPLY_PROFILES_KEY]
    if type(t) ~= "table" then t = {} end
    t[tostring(providerId)] = tostring(profileName or "")
    ProfileManagerDB[PM_PENDING_APPLY_PROFILES_KEY] = t
end

function addon:PM_GetAndClearPendingApplyProfiles()
    if not ProfileManagerDB then return nil end
    local t = ProfileManagerDB[PM_PENDING_APPLY_PROFILES_KEY]
    ProfileManagerDB[PM_PENDING_APPLY_PROFILES_KEY] = nil
    if type(t) ~= "table" then return nil end

    for k, v in pairs(t) do
        if type(v) ~= "string" or v == "" then t[k] = nil end
    end
    if next(t) == nil then return nil end
    return t
end

local function PM_ApplyPresetWhenSafe(presetName)
    if not presetName or presetName == "" then return end
    if not addon.ApplyPreset then return end

    local function doApply()
        Delay(1.0, function()
            local function onSuccess(skipped)
                print("|cff00ff00ProfileManager|r Applied preset on login: " .. presetName)
                local notSwitched = addon:DescribeSkipped(skipped)
                if notSwitched then print("|cffffd100ProfileManager|r " .. notSwitched) end
                addon:ShowForceReloadPopup("Preset \"" .. presetName .. "\" was applied on login.\n\nReload to fully apply all profile changes.")
            end
            local function onError(err)
                print("|cffff5555ProfileManager|r Auto-apply failed on login: " .. tostring(err))
            end

            if InCombatLockdown and InCombatLockdown() then
                local f = CreateFrame("Frame")
                f:RegisterEvent("PLAYER_REGEN_ENABLED")
                f:SetScript("OnEvent", function(self)
                    self:UnregisterAllEvents()
                    self:SetScript("OnEvent", nil)
                    Delay(0.5, function()
                        xpcall(function() local _, _, skipped = addon:ApplyPreset(presetName); onSuccess(skipped) end, onError)
                    end)
                end)
                return
            end

            xpcall(function() local _, _, skipped = addon:ApplyPreset(presetName); onSuccess(skipped) end, onError)
        end)
    end

    doApply()
end

local function PM_OutOfCombat(fn)
    if not InCombatLockdown() then return fn() end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        self:SetScript("OnEvent", nil)
        Delay(0.5, function() PM_OutOfCombat(fn) end)
    end)
end

local function PM_ApplyKeybindsWhenSafe(profileName)
    if type(profileName) ~= "string" or profileName == "" then return end
    if not (addon.Keybinds and addon.Keybinds:IsAvailable()) then return end

    Delay(1.0, function()
        PM_OutOfCombat(function()
            local ok, appliedOrErr, _, untouched = addon.Keybinds:LoadProfile(profileName)
            if ok then
                print("|cff00ff00ProfileManager|r Loaded keybind profile on login: " .. profileName)
                if untouched and untouched > 0 then
                    print(("|cffffd100ProfileManager|r %d bound action(s) aren't in '%s' and kept their keys."):format(untouched, profileName))
                end
            else
                print("|cffff5555ProfileManager|r Keybinds on login failed: " .. tostring(appliedOrErr))
            end
        end)
    end)
end

local function PM_ApplyGameSettingsWhenSafe(profileName)
    if type(profileName) ~= "string" or profileName == "" then return end
    if not (addon.GameSettings and addon.GameSettings:IsAvailable()) then return end

    Delay(1.0, function()
        PM_OutOfCombat(function()
            local ok, appliedOrErr, failed, needsRestart, failedNames, untouched = addon.GameSettings:LoadProfile(profileName)
            if not ok then
                print("|cffff5555ProfileManager|r Game settings on login failed: " .. tostring(appliedOrErr))
                return
            end
            local msg = ("|cff00ff00ProfileManager|r Loaded game settings on login: %s (%d changed)"):format(profileName, appliedOrErr)
            if failed and failed > 0 then
                msg = msg .. (", %d couldn't be set: %s"):format(failed, table.concat(failedNames or {}, ", "))
            end
            if untouched and untouched > 0 then
                msg = msg .. (", %d not in the profile kept their values"):format(untouched)
            end
            print(msg)
            if needsRestart then
                print("|cffffd100ProfileManager|r Some of these game settings take effect after you restart the game.")
            end
        end)
    end)
end

local function PM_ApplyAddonSetWhenSafe(setName)
    if type(setName) ~= "string" or setName == "" then return end
    if not (addon.Addons and addon.Addons:IsAvailable()) then return end

    Delay(1.5, function()
        local ok, changedOrErr = addon.Addons:LoadSet(setName)
        if not ok then
            print("|cffff5555ProfileManager|r Addon set on login failed: " .. tostring(changedOrErr))
            return
        end
        print(("|cff00ff00ProfileManager|r Loaded addon set on login: %s (%d change(s))"):format(setName, changedOrErr))
        if changedOrErr > 0 then
            addon:ShowForceReloadPopup(("Addon set '|cffcfd0ff%s|r' was loaded for this character.\n\nReload to apply it?"):format(setName))
        end
    end)
end

local function PM_UniqueNames()
    return RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled() and true or false
end

local function PM_Ruleset()
    local rules, E = C_GameRules, Enum.GameRule
    if not (rules and rules.IsGameRuleActive and E) then return nil end
    local function On(rule)
        if rule == nil then return false end
        local ok, active = pcall(rules.IsGameRuleActive, rule)
        return ok and active and true or false
    end
    if On(E.HardcoreRuleset) then return "Hardcore" end
    local rp, pvp = On(E.RPRuleset), On(E.PvPRuleset)
    if rp and pvp then return "RP PvP" end
    if rp then return "RP" end
    if pvp then return "PvP" end
    return "PvE"
end

local function PM_CharacterDisplay(charKey)
    local info = ProfileManagerDB and ProfileManagerDB.charNames and ProfileManagerDB.charNames[charKey]
    if type(info) == "table" and type(info.name) == "string" then
        local full = (type(info.surname) == "string" and info.surname ~= "") and (info.name .. " " .. info.surname) or info.name
        return full, info.ruleset
    end
    if PM_UniqueNames() then
        local name, realm = tostring(charKey):match("^(.-) %- (.+)$")
        if name then return name, realm:match("(%S+)$") end
    end
    return charKey, nil
end

local function PM_ApplyProfilesWhenSafe(map)
    if type(map) ~= "table" then return end

    local function doApply()
        Delay(1.0, function()
            if addon.TryRegisterAllProviders then
                pcall(function() addon:TryRegisterAllProviders() end)
            end

            if InCombatLockdown and InCombatLockdown() then
                local f = CreateFrame("Frame")
                f:RegisterEvent("PLAYER_REGEN_ENABLED")
                f:SetScript("OnEvent", function(self)
                    self:UnregisterAllEvents()
                    self:SetScript("OnEvent", nil)
                    doApply()
                end)
                return
            end

            for providerId, profileName in pairs(map) do
                local prov = addon.Providers and addon.Providers[providerId]
                if prov then
                    xpcall(function()
                        if type(prov.SetProfile) == "function" then
                            prov:SetProfile(profileName)
                        elseif type(prov.ApplyProfile) == "function" then
                            prov:ApplyProfile(profileName)
                        end
                    end, function(err)
                        print("|cffff5555ProfileManager|r Auto-apply after /reload failed (" .. tostring(providerId) .. "): " .. tostring(err))
                    end)
                end
            end

            print("|cff00ff00ProfileManager|r Applied imported profile(s) after /reload.")
        end)
    end

    doApply()
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self, event, isInitialLogin)
        if event == "PLAYER_LOGIN" then
            local pendingProfiles = addon:PM_GetAndClearPendingApplyProfiles()
            if pendingProfiles then
                PM_ApplyProfilesWhenSafe(pendingProfiles)
            end

            local charName = UnitName("player") .. " - " .. GetRealmName()
            ProfileManagerDB = ProfileManagerDB or {}
            ProfileManagerDB.charClasses = ProfileManagerDB.charClasses or {}
            ProfileManagerDB.charClasses[charName] = select(2, UnitClass("player"))
            if PM_UniqueNames() and UnitNameUnmodified then
                local name, surname = UnitNameUnmodified("player")
                ProfileManagerDB.charNames = ProfileManagerDB.charNames or {}
                ProfileManagerDB.charNames[charName] = { name = name, surname = surname, ruleset = PM_Ruleset() }
            end

        elseif event == "PLAYER_ENTERING_WORLD" and isInitialLogin then
            local charName = UnitName("player") .. " - " .. GetRealmName()
            ProfileManagerDB = ProfileManagerDB or {}
            ProfileManagerDB.knownChars  = ProfileManagerDB.knownChars  or {}
            ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}

            local isNew = true
            for _, c in ipairs(ProfileManagerDB.knownChars) do
                if c == charName then isNew = false; break end
            end

            if isNew then
                table.insert(ProfileManagerDB.knownChars, charName)
                local def = ProfileManagerDB.newCharDefault
                if type(def) == "string" and def ~= "" then
                    PM_ApplyPresetWhenSafe(def)
                end
                PM_ApplyKeybindsWhenSafe(ProfileManagerDB.newCharKeybinds)
                PM_ApplyAddonSetWhenSafe(ProfileManagerDB.newCharAddons)
                PM_ApplyGameSettingsWhenSafe(ProfileManagerDB.newCharSettings)
            else
                local cd = ProfileManagerDB.charPresets[charName]
                if type(cd) == "table" and cd.applyOnLogin then
                    local any = false
                    if type(cd.preset) == "string" and cd.preset ~= "" then
                        PM_ApplyPresetWhenSafe(cd.preset)
                        any = true
                    end
                    if type(cd.keybinds) == "string" and cd.keybinds ~= "" then
                        PM_ApplyKeybindsWhenSafe(cd.keybinds)
                        any = true
                    end
                    if type(cd.addons) == "string" and cd.addons ~= "" then
                        PM_ApplyAddonSetWhenSafe(cd.addons)
                        any = true
                    end
                    if type(cd.settings) == "string" and cd.settings ~= "" then
                        PM_ApplyGameSettingsWhenSafe(cd.settings)
                        any = true
                    end
                    if any then cd.applyOnLogin = false end
                end
            end
        end
    end)
end

local function PM_IsModernDropdownAvailable()
    return CreateFrame
        and _G.MenuUtil ~= nil
        and _G.CreateFrame ~= nil
        and _G.DropdownButtonMixin ~= nil
end

local function PM_SetDropdownWidth(dd, width)
    width = tonumber(width or 0) or 0
    if not dd or width <= 0 then return end

    if dd._pmModern then
        if dd.SetWidth then dd:SetWidth(width) end

        if dd.Button and dd.Button.SetWidth then
            dd.Button:SetWidth(width)
        end
        if dd.DropDown and dd.DropDown.SetWidth then
            dd.DropDown:SetWidth(width)
        end

        if dd.Background and dd.Background.SetWidth then
            dd.Background:SetWidth(width)
        end

        if dd.Text and dd.Text.SetWidth then
            dd.Text:SetWidth(math.max(1, width - 35))
        end
        if dd.ButtonText and dd.ButtonText.SetWidth then
            dd.ButtonText:SetWidth(math.max(1, width - 35))
        end

        return
    end

    if dd and UIDropDownMenu_SetWidth then
        UIDropDownMenu_SetWidth(dd, width)
    elseif dd and dd.SetWidth then
        dd:SetWidth(width)
    end
end

local function PM_SetDropdownText(dd, text)
    text = tostring(text or "")

    if dd and dd._pmModern then
        if dd.SetText then
            dd:SetText(text)
            return
        end
        if dd.SetDefaultText then
            dd:SetDefaultText(text)
        end

        if dd.Text and dd.Text.SetText then
            dd.Text:SetText(text)
            return
        end
        if dd.ButtonText and dd.ButtonText.SetText then
            dd.ButtonText:SetText(text)
            return
        end
        if dd.Label and dd.Label.SetText then
            dd.Label:SetText(text)
            return
        end

        if dd.Button then
            if dd.Button.Text and dd.Button.Text.SetText then
                dd.Button.Text:SetText(text)
                return
            end
            local fs = dd.Button.GetFontString and dd.Button:GetFontString()
            if fs and fs.SetText then
                fs:SetText(text)
                return
            end
        end

        local fs = dd.GetFontString and dd:GetFontString()
        if fs and fs.SetText then
            fs:SetText(text)
            return
        end

        return
    end

    if dd and UIDropDownMenu_SetText then
        UIDropDownMenu_SetText(dd, text)
    end
end

local function PM_RememberDropdownText(dd, text)
    if dd and dd._pmModern then
        dd._pmLastText = tostring(text or "")
    end
end

local function PM_ModernDropdownForceText(dd, text)
    if not dd or not dd._pmModern then return end
    text = tostring(text or " ")

    dd._pmLastText = text

    if dd.Text and dd.Text.OverrideText then
        dd.Text:OverrideText(text)
    elseif dd.ButtonText and dd.ButtonText.OverrideText then
        dd.ButtonText:OverrideText(text)
    else
        PM_SetDropdownText(dd, text)
    end

    Delay(0, function()
        if dd and dd._pmModern then
            if dd.Text and dd.Text.OverrideText then
                dd.Text:OverrideText(dd._pmLastText or text)
            elseif dd.ButtonText and dd.ButtonText.OverrideText then
                dd.ButtonText:OverrideText(dd._pmLastText or text)
            else
                PM_SetDropdownText(dd, dd._pmLastText or text)
            end
        end
    end)
end

local function PM_EnsureModernSelectionFunc(dd)
    if not (dd and dd._pmModern) then return end

    local target = dd.Text or dd.ButtonText or dd.Label
    if target and target.SetSelectionText then
        target:SetSelectionText(function()
            return dd._pmLastText or target:GetText() or " "
        end)
    end
end

local function PM_BuildUsedProfilesMap()
    local used = {}

    local db = addon.db or _G.ProfileManagerDB
    local presets = db and db.presets
    if type(presets) ~= "table" then return used end

    for _, preset in pairs(presets) do
        local addonsMap = preset and preset.addons
        if type(addonsMap) == "table" then
            for providerId, profName in pairs(addonsMap) do
                if type(providerId) == "string" and type(profName) == "string" and profName ~= "" then
                    used[providerId] = used[providerId] or {}
                    used[providerId][profName] = true
                end
            end
        end
    end

    return used
end

local function PM_IsProtectedProfileName(providerId, profileName)
    if type(profileName) ~= "string" or profileName == "" then return true end

    if profileName:sub(1, #PM_PRIV_PREFIX) == PM_PRIV_PREFIX then
        profileName = profileName:sub(#PM_PRIV_PREFIX + 1)
    end

    local lower = profileName:lower()

    if providerId == "BlizzardEditMode" then
        if lower == "modern" or lower == "classic" or lower == "gamepad" then return true end
    end

    if lower == "default" then return true end
    if profileName == addon:CharacterProfileKey(providerId) then return true end

    return false
end

function addon:GetDeletableUnusedProfiles(providerId)
    local prov = self.Providers and self.Providers[providerId]
    if not prov or type(prov.GetProfiles) ~= "function" or type(prov.DeleteProfile) ~= "function" then
        return {}
    end

    local used = PM_BuildUsedProfilesMap()
    local usedForProvider = used[providerId] or {}

    local current = nil
    if type(prov.GetCurrentProfile) == "function" then
        local ok, cur = pcall(function() return prov:GetCurrentProfile() end)
        if ok then current = cur end
    end

    local ok, list = pcall(function() return prov:GetProfiles() end)
    if not ok or type(list) ~= "table" then return {} end

    local out = {}
    for _, name in ipairs(list) do
        if type(name) == "string" and name ~= "" then
            if not PM_IsProtectedProfileName(providerId, name)
                and name ~= current
                and not usedForProvider[name]
            then
                out[#out + 1] = name
            end
        end
    end

    table.sort(out, function(a, b) return a:lower() < b:lower() end)
    return out
end

function addon:DeleteAllUnusedProfiles(providerId)
    if InCombatLockdown() then
        return false, "In combat"
    end

    local prov = self.Providers and self.Providers[providerId]
    if not prov or type(prov.DeleteProfile) ~= "function" then
        return false, "Provider missing DeleteProfile"
    end

    local targets = self:GetDeletableUnusedProfiles(providerId)
    if #targets == 0 then
        return true, 0, 0
    end

    local deleted, failed = 0, 0
    for _, profileName in ipairs(targets) do
        local ok, a = pcall(function() return prov:DeleteProfile(profileName) end)
        local success = ok and (a == true)
        if success then
            deleted = deleted + 1
        else
            failed = failed + 1
        end
    end

    if self.RefreshMainUI then
        pcall(function() self:RefreshMainUI() end)
    end

    return true, deleted, failed
end

local function PM_CreateProfileDropdown(parent, initialWidth, getProfilesFn, getLiveFn, getUsageFn, onSelect, getSelectedFn)
    local dd

    if PM_IsModernDropdownAvailable() then
        dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dd._pmModern = true
        dd._pmLastText = " "
        PM_EnsureModernSelectionFunc(dd)

        dd:HookScript("OnShow", function(self)
            if self._pmLastText and self._pmLastText ~= "" then
                PM_SetDropdownText(self, self._pmLastText)
            end
        end)

        dd._pmGetSelected = function()
            if type(getSelectedFn) == "function" then
                return tostring(getSelectedFn() or "")
            end
            return ""
        end

        if dd.SetDefaultText then
            dd:SetDefaultText(" ")
        end

        if dd.SetupMenu then
            dd:SetupMenu(function(owner, rootDescription)
                if rootDescription.SetScrollMode then
                    rootDescription:SetScrollMode(20 * 20)
                end
                local profiles = {}
                local list = getProfilesFn and getProfilesFn()
                if type(list) == "table" then profiles = list end

                table.sort(profiles, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

                local live = getLiveFn and getLiveFn()
                live = (live ~= nil) and tostring(live) or nil

                local current = ""
                if owner and owner._pmGetSelected then
                    current = tostring(owner:_pmGetSelected() or "")
                end

                for _, name in ipairs(profiles) do
                    local n = tostring(name)
                    local used = (getUsageFn and getUsageFn(n)) or 0

                    local label = PM_ProfileDisplayLabel(n)
                    if used > 0 then
                        label = label .. ("  |cff9aa0a6(used in %d presets)|r"):format(used)
                    end

                    if live and n == live then
                        label = "|cff00ff00" .. LIVE_ICON .. label .. "|r"
                    end

                    rootDescription:CreateRadio(
                        label,
                        function() return tostring(current) == n end,
                        function()
                            if onSelect then onSelect(n) end
                        end
                    )
                end
            end)
        else
            dd:SetScript("OnMouseDown", function()
                local profiles = getProfilesFn and getProfilesFn() or {}
                if type(profiles) ~= "table" then profiles = {} end
                table.sort(profiles, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

                MenuUtil.CreateContextMenu(dd, function(owner, rootDescription)
                    local live = getLiveFn and getLiveFn()
                    live = (live ~= nil) and tostring(live) or nil

                    local current = ""
                    if owner and owner._pmGetSelected then
                        current = tostring(owner:_pmGetSelected() or "")
                    end

                    for _, name in ipairs(profiles) do
                        local n = tostring(name)
                        local used = (getUsageFn and getUsageFn(n)) or 0

                        local label = PM_ProfileDisplayLabel(n)
                        if used > 0 then
                            label = label .. ("  |cff9aa0a6(used in %d presets)|r"):format(used)
                        end

                        if live and n == live then
                            label = "|cff00ff00" .. LIVE_ICON .. label .. "|r"
                        end

                        rootDescription:CreateRadio(
                            label,
                            function() return tostring(current) == n end,
                            function()
                                if onSelect then onSelect(n) end
                            end
                        )
                    end
                end)
            end)
        end

        PM_SetDropdownWidth(dd, initialWidth or 150)
        return dd
    end

    dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dd._pmModern = false

    dd._pmGetSelected = function()
        if type(getSelectedFn) == "function" then
            return tostring(getSelectedFn() or "")
        end
        return ""
    end

    UIDropDownMenu_Initialize(dd, function(self, level)
        local profiles = {}
        local list = getProfilesFn and getProfilesFn()
        if type(list) == "table" then profiles = list end
        table.sort(profiles, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

        local live = getLiveFn and getLiveFn()
        live = (live ~= nil) and tostring(live) or nil

        for _, name in ipairs(profiles) do
            local n = tostring(name)
            local used = (getUsageFn and getUsageFn(n)) or 0

            local info = UIDropDownMenu_CreateInfo()
            info.notCheckable = true

            local label = PM_ProfileDisplayLabel(n)
            if used > 0 then
                label = label .. (" |cff9aa0a6(used in %d presets)|r"):format(used)
            end

            if live and n == live then
                label = "|cff00ff00" .. LIVE_ICON .. label .. "|r"
            end

            info.text = label
            info.func = function()
                if onSelect then onSelect(n) end
            end

            UIDropDownMenu_AddButton(info)
        end
    end)

    PM_SetDropdownWidth(dd, initialWidth or 150)
    PM_RememberDropdownText(dd, " ")
    return dd
end

local function PM_CreateDeleteDropdown(parent, initialWidth, getItemsFn, onSelect, getSelectedFn)
    local dd

    if PM_IsModernDropdownAvailable() then
        dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dd._pmModern = true
        dd._pmLastText = " "
        PM_EnsureModernSelectionFunc(dd)

        dd:HookScript("OnShow", function(self)
            if self._pmLastText and self._pmLastText ~= "" then
                PM_SetDropdownText(self, self._pmLastText)
            end
        end)

        dd._pmGetSelected = function()
            if type(getSelectedFn) == "function" then
                return tostring(getSelectedFn() or "")
            end
            return ""
        end

        if dd.SetDefaultText then
            dd:SetDefaultText(" ")
        end

        if dd.SetupMenu then
            dd:SetupMenu(function(owner, rootDescription)
                if rootDescription.SetScrollMode then
                    rootDescription:SetScrollMode(20 * 20)
                end
                local items = {}
                local list = getItemsFn and getItemsFn()
                if type(list) == "table" then items = list end
                table.sort(items, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

                local current = owner and owner._pmGetSelected and tostring(owner:_pmGetSelected() or "") or ""

                if #items == 0 then
                    rootDescription:CreateButton("(no unused profiles)", function() end):SetEnabled(false)
                    return
                end

                for _, name in ipairs(items) do
                    local n = tostring(name)
                    rootDescription:CreateRadio(
                        PM_ProfileDisplayLabel(n),
                        function() return tostring(current) == n end,
                        function()
                            if onSelect then onSelect(n) end
                        end
                    )
                end
            end)
        end

        PM_SetDropdownWidth(dd, initialWidth or 150)
        return dd
    end

    dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dd._pmModern = false

    dd._pmGetSelected = function()
        if type(getSelectedFn) == "function" then
            return tostring(getSelectedFn() or "")
        end
        return ""
    end

    UIDropDownMenu_Initialize(dd, function(self, level)
        local items = {}
        local list = getItemsFn and getItemsFn()
        if type(list) == "table" then items = list end
        table.sort(items, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

        if #items == 0 then
            local info = UIDropDownMenu_CreateInfo()
            info.text = "(no unused profiles)"
            info.notCheckable = true
            info.disabled = true
            UIDropDownMenu_AddButton(info)
            return
        end

        for _, name in ipairs(items) do
            local n = tostring(name)
            local info = UIDropDownMenu_CreateInfo()
            info.text = PM_ProfileDisplayLabel(n)
            info.checked = (tostring(dd:_pmGetSelected() or "") == n)
            info.func = function()
                if onSelect then onSelect(n) end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    PM_SetDropdownWidth(dd, initialWidth or 150)
    PM_RememberDropdownText(dd, " ")
    return dd
end

local function CreatePanel(parent, inset)
    local p = CreateFrame("Frame", nil, parent)
    p.bg = p:CreateTexture(nil, "BACKGROUND")
    p.bg:SetAllPoints(p.bg:GetParent())
    p.bg:SetColorTexture(unpack(THEME.panelBg))

    p.border = CreateFrame("Frame", nil, p, "BackdropTemplate")
    p.border:SetAllPoints(p.border:GetParent())
    p.border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    p.border:SetBackdropBorderColor(unpack(THEME.panelBorder))

    if inset then
        p.bg:ClearAllPoints()
        p.bg:SetPoint("TOPLEFT", p.bg:GetParent(), "TOPLEFT", inset, -inset)
        p.bg:SetPoint("BOTTOMRIGHT", p.bg:GetParent(), "BOTTOMRIGHT", -inset, inset)
    end

    return p
end

local function PM_GetProfileUsageCounts(providerId)
    local counts = {}

    if not addon.GetPresetNames or not addon.GetPreset then
        return counts
    end

    local names = addon:GetPresetNames()
    if type(names) ~= "table" then
        return counts
    end

    for i = 1, #names do
        local p = addon:GetPreset(names[i])
        if p and type(p.addons) == "table" then
            local prof = p.addons[providerId]
            if prof ~= nil and prof ~= "" then
                prof = tostring(prof)
                counts[prof] = (counts[prof] or 0) + 1
            end
        end
    end

    return counts
end

local function PM_FormatProviderDisplayName(providerId)
    if type(providerId) ~= "string" then
        return tostring(providerId or "?")
    end

    local aceName = providerId:match("^acedb:(.+)$")
    if aceName then
        aceName = aceName:gsub("DB$", "")
        return aceName
    end

    return providerId
end

local function PM_GetProviderNiceName(providerId)
    providerId = tostring(providerId or "")

    local prov = addon.Providers and addon.Providers[providerId]
    if prov and type(prov) == "table" and prov.displayName and prov.displayName ~= "" then
        return prov.displayName
    end

    return PM_FormatProviderDisplayName(providerId)
end

local function IsAddonLoadedCompat(addonName)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(addonName)
    end
    return false
end

local function UISpecialFrames_Add(name)
    UISpecialFrames = UISpecialFrames or {}
    for i = 1, #UISpecialFrames do
        if UISpecialFrames[i] == name then
            return
        end
    end
    table.insert(UISpecialFrames, name)
end

local function Two(n) return (n < 10 and ("0"..n) or tostring(n)) end

local function MakeDefaultPresetName()
    local t = date("*t")
    return string.format("Preset %d-%s-%s %s:%s", t.year, Two(t.month), Two(t.day), Two(t.hour), Two(t.min))
end

local function EnsureUniquePresetName(baseName)
    local name = baseName
    local i = 2
    while addon.GetPreset and addon:GetPreset(name) do
        name = baseName .. " (" .. i .. ")"
        i = i + 1
    end
    return name
end

local function UpdateRowChangeVisual(row)
    if not row or row.isMissing then return end

    local cur = row.currentLive
    local sel = row.selectedProfile
    local changed = (cur ~= nil and sel ~= nil and tostring(cur) ~= tostring(sel))

    if changed and row.bg then
        row.bg:SetColorTexture(0.35, 0.65, 1.00, 0.08)
    end
    if row.notInPreset then
        row.label:SetTextColor(1.00, 0.35, 0.35, 1.00)
    elseif changed then
        row.label:SetTextColor(0.90, 0.95, 1.00, 1.00)
    else
        row.label:SetTextColor(unpack(THEME.text))
    end
end

local function PM_MakeMinimalCheck(parent)
    local chk = CreateFrame("CheckButton", nil, parent)
    chk:SetSize(22, 22)
    local ok = pcall(function()
        local nt = chk:CreateTexture(nil, "ARTWORK"); nt:SetAtlas("checkbox-minimal", true); nt:SetAllPoints(chk)
        chk:SetNormalTexture(nt)
        local pt = chk:CreateTexture(nil, "ARTWORK"); pt:SetAtlas("checkbox-minimal", true); pt:SetAllPoints(chk)
        chk:SetPushedTexture(pt)
        local ct = chk:CreateTexture(nil, "OVERLAY"); ct:SetAtlas("checkmark-minimal", true); ct:SetAllPoints(chk)
        chk:SetCheckedTexture(ct)
        local dt = chk:CreateTexture(nil, "OVERLAY"); dt:SetAtlas("checkmark-minimal-disabled", true); dt:SetAllPoints(chk)
        chk:SetDisabledCheckedTexture(dt)
    end)
    if not ok then
        chk:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        chk:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        chk:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
        chk:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    end
    return chk
end

local function AddRowDivider(row)
    if not row or row.__hasDivider then return end
    row.__hasDivider = true

    row.divider = row:CreateTexture(nil, "ARTWORK")
    row.divider:SetColorTexture(unpack(THEME.divider))
    row.divider:SetHeight(1)
    row.divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    row.divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
end

function addon:RefreshInlineEditorLiveStates()
    local f = self.MainUI
    if not f then return end

    local pendingMap = _G.ProfileManagerDB and _G.ProfileManagerDB[PM_PENDING_APPLY_PROFILES_KEY]

    for _, row in ipairs(f.editorRows or {}) do
        if not row.isMissing and not row.isDashRow then
            local prov = self.Providers and self.Providers[row.providerId]

            if prov and prov.GetCurrentProfile then
                local live = SafeCall(function() return prov:GetCurrentProfile() end)
                if live ~= nil then
                    row.currentLive = live
                end
            end

            if row.dropdown and row.selectedProfile then
                local sel = tostring(row.selectedProfile)
                local live = tostring(row.currentLive or "")
                local pending = pendingMap
                    and pendingMap[row.providerId]
                    and tostring(pendingMap[row.providerId]) == tostring(sel)

                local selLabel = PM_ProfileDisplayLabel(sel)
                local desiredText
                if pending then
                    desiredText = RELOAD_PREFIX .. selLabel
                elseif sel == live and live ~= "" then
                    desiredText = "|cff00ff00" .. LIVE_ICON .. selLabel .. "|r"
                else
                    desiredText = selLabel
                end

                if row.dropdown._pmModern then
                    PM_ModernDropdownForceText(row.dropdown, desiredText)
                else
                    PM_RememberDropdownText(row.dropdown, desiredText)
                    PM_SetDropdownText(row.dropdown, desiredText)
                end
            end

            UpdateRowChangeVisual(row)
        end
    end
end

local function LayoutEditorRow(row)
    if not row or row.isMissing or not row:GetParent() then return end
    local w = row:GetWidth()
    if not w or w < 50 then return end

    row.selectChk:ClearAllPoints()
    row.selectChk:SetPoint("LEFT", row.selectChk:GetParent(), "LEFT", 4, 0)

    row.favBtn:ClearAllPoints()
    row.favBtn:SetPoint("LEFT", row.selectChk, "RIGHT", FAV_GAP_L, 0)

    if row.menuBtn then
        row.menuBtn:ClearAllPoints()
        row.menuBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    end
    if row.dropdown then
        row.dropdown:ClearAllPoints()
        if row.menuBtn then
            row.dropdown:SetPoint("RIGHT", row.menuBtn, "LEFT", -4, 0)
        else
            row.dropdown:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        end
    end

    row.label:ClearAllPoints()
    row.label:SetPoint("LEFT", row.favBtn, "RIGHT", NAME_EXTRA_PAD, 0)
    local rightAnchor = row.dropdown or row.menuBtn
    if row.warnIcon and rightAnchor then
        row.warnIcon:ClearAllPoints()
        row.warnIcon:SetPoint("RIGHT", rightAnchor, "LEFT", -6, 0)
        row.label:SetPoint("RIGHT", row.warnIcon, "LEFT", -4, 0)
    elseif rightAnchor then
        row.label:SetPoint("RIGHT", rightAnchor, "LEFT", -6, 0)
    end
end

function addon:ApplyEditorSearchFilter()
    local f = self.MainUI
    if not f then return end

    local filter = ""
    local txt = ""
    if f.editorSearch then
        if f.editorSearch._pmShowingPlaceholder then
            txt = ""
        else
            txt = f.editorSearch:GetText() or ""
        end
    end
    filter = strtrim(txt):lower()

    local y = -2
    local shown = 0

    for _, row in ipairs(f.editorRows or {}) do
        local hay = tostring(row.searchText or row.providerId or ""):lower()
        local match = (filter == "") or (hay:find(filter, 1, true) ~= nil)

        if match then
            row:Show()
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
            row:SetPoint("RIGHT", f.editorScrollChild, "RIGHT", 0, 0)
            if not row.isDashRow then Delay(0, function() LayoutEditorRow(row) end) end
            local rh = row.rowHeight or EDITOR_ROW_HEIGHT
            y = y - rh
            shown = shown + rh
        else
            row:Hide()
        end
    end

    f.editorScrollChild:SetHeight(math.max(1, shown + 6))
end

local function PM_EnsureBlizzardSettingsLoaded()
    if C_AddOns and C_AddOns.LoadAddOn then
        if not C_AddOns.IsAddOnLoaded("Blizzard_Settings_Shared") then
            C_AddOns.LoadAddOn("Blizzard_Settings_Shared")
        end
        if not C_AddOns.IsAddOnLoaded("Blizzard_Settings") then
            C_AddOns.LoadAddOn("Blizzard_Settings")
        end
    end
end

local function PM_ApplyBlizzardOptionsSkin(frame)
    PM_EnsureBlizzardSettingsLoaded()

    local src = _G.SettingsPanel

    if _G.NineSliceUtil and _G.NineSliceLayouts then
        frame.NineSlice = CreateFrame("Frame", nil, frame, "NineSlicePanelTemplate")
        frame.NineSlice:SetAllPoints(frame.NineSlice:GetParent())

        if src and src.NineSlice and src.NineSlice.layoutType and NineSliceLayouts[src.NineSlice.layoutType] then
            NineSliceUtil.ApplyLayout(frame.NineSlice, NineSliceLayouts[src.NineSlice.layoutType])
        elseif NineSliceLayouts.SettingsPanel then
            NineSliceUtil.ApplyLayout(frame.NineSlice, NineSliceLayouts.SettingsPanel)
        end

        frame.NineSlice:SetFrameStrata(frame:GetFrameStrata())
        frame.NineSlice:SetFrameLevel(frame:GetFrameLevel())
    end

    frame.Bg:SetPoint("TOPLEFT", frame.Bg:GetParent(), "TOPLEFT", 5, -20)
    frame.Bg:SetPoint("BOTTOMRIGHT", frame.Bg:GetParent(), "BOTTOMRIGHT", 0, 1)
end

local function PM_SortLower(a, b)
    return tostring(a):lower() < tostring(b):lower()
end

function addon:ShowForceReloadPopup(text)
    StaticPopupDialogs["PM_FORCE_RELOAD"] = {
        text = text or "Changes applied.\n\nSome addons require reload to apply changes.",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = ReloadUI,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopup_Show("PM_FORCE_RELOAD")
end

local function PM_DecodePresetPayload(str)
    local data, err = addon:DecompressAndDeserialize(str)
    if not data then return nil, err end

    if data.type ~= "Preset" then
        return nil, "Not a preset export"
    end
    if type(data.addons) ~= "table" then
        return nil, "Preset payload missing addons table"
    end

    return data, nil
end

local function CreateImportWizardEditBox(parent)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -44)
    box:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 54)
    box:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    box:SetBackdropColor(0.02, 0.02, 0.025, 0.95)
    box:SetBackdropBorderColor(1, 1, 1, 0.10)

    local sf = CreateFrame("ScrollFrame", nil, box, "ScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", box, "TOPLEFT", 6, -6)
    sf:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -26, 6)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(true)
    eb:EnableMouse(true)
    eb:SetFontObject(ChatFontNormal)
    eb:SetTextColor(0.92, 0.92, 0.94, 1)
    eb:SetWidth(1)
    eb:SetHeight(1)
    eb:SetTextInsets(8, 8, 8, 8)
    eb:SetScript("OnEscapePressed", function()
        eb:ClearFocus()
        if parent and parent.Hide then parent:Hide() end
    end)

    if eb.SetMaxLetters then eb:SetMaxLetters(0) end

    eb:SetScript("OnCursorChanged", function(self, x, y, w, h)
        sf:UpdateScrollChildRect()
        local offset = sf:GetVerticalScroll()
        local height = sf:GetHeight()
        if not height then return end
        local cy = -y
        if cy < offset then
            sf:SetVerticalScroll(cy)
        elseif (cy + h) > (offset + height) then
            sf:SetVerticalScroll((cy + h) - height)
        end
    end)

    eb:SetScript("OnTextChanged", function()
        sf:UpdateScrollChildRect()
    end)

    sf:SetScrollChild(eb)

    parent.pasteBoxFrame = box
    parent.pasteScroll = sf
    parent.pasteBox = eb
end

local function PM_CreatePresetImportStepperPopup()
    if addon.PresetImportStepper then return end

    local f = CreateFrame("Frame", "ProfileManagerPresetImportStepper", UIParent, "BackdropTemplate")
    f:SetSize(500, 560)
    f:SetPoint("CENTER", f:GetParent(), "CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(2200)
    f:Hide()

    f.Bg = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    f.Bg:SetColorTexture(0.08, 0.08, 0.09, 0.98)

    PM_ApplyBlizzardOptionsSkin(f)

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    UISpecialFrames_Add("ProfileManagerPresetImportStepper")

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -3)
    f.title:SetTextColor(unpack(THEME.titleText))
    f.title:SetText("Import Preset (Step-by-step)")
    f.title:SetDrawLayer("OVERLAY", 7)

    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonDefaultAnchors")
    f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 20)

    f.body = CreatePanel(f, 0)
    f.body:SetPoint("TOPLEFT", f.body:GetParent(), "TOPLEFT", 10, -32)
    f.body:SetPoint("BOTTOMRIGHT", f.body:GetParent(), "BOTTOMRIGHT", -10, 10)

    f.progress = f.body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.progress:SetPoint("TOPLEFT", f.progress:GetParent(), "TOPLEFT", 14, -14)
    f.progress:SetTextColor(unpack(THEME.text))
    f.progress:SetText("0 / 0")

    f.status = f.body:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    f.status:SetTextColor(unpack(THEME.mutedText))
    f.status:SetPoint("TOPLEFT", f.progress, "BOTTOMLEFT", 0, -8)
    f.status:SetTextColor(unpack(THEME.mutedText))
    f.status:SetWidth(520)
    f.status:SetJustifyH("LEFT")
    f.status:SetText("")

    f.current = f.body:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.current:SetPoint("TOPLEFT", f.status, "BOTTOMLEFT", 0, -14)
    f.current:SetTextColor(unpack(THEME.titleText))
    f.current:SetWidth(520)
    f.current:SetJustifyH("LEFT")
    f.current:SetText("")

    f.result = f.body:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.result:SetTextColor(unpack(THEME.mutedText))
    f.result:SetPoint("TOPLEFT", f.current, "BOTTOMLEFT", 0, -10)
    f.result:SetTextColor(unpack(THEME.mutedText))
    f.result:SetWidth(520)
    f.result:SetJustifyH("LEFT")
    f.result:SetText("")

    f.listPanel = CreatePanel(f.body, 0)
    f.listPanel:SetPoint("TOPLEFT", f.result, "BOTTOMLEFT", 0, -10)
    f.listPanel:SetPoint("BOTTOMRIGHT", f.body, "BOTTOMRIGHT", -14, 50)

    f.listScroll = CreateFrame("ScrollFrame", nil, f.listPanel, "ScrollFrameTemplate")
    f.listScroll:SetPoint("TOPLEFT", f.listScroll:GetParent(), "TOPLEFT", 6, -6)
    f.listScroll:SetPoint("BOTTOMRIGHT", f.listScroll:GetParent(), "BOTTOMRIGHT", -26, 6)

    f.listChild = CreateFrame("Frame", nil, f.listScroll)
    f.listChild:SetSize(1, 1)
    f.listScroll:SetScrollChild(f.listChild)

    f.listRows = {}

    f.cancelBtn = CreateFrame("Button", nil, f.body, "UIPanelButtonTemplate")
    f.cancelBtn:SetSize(120, 24)
    f.cancelBtn:SetPoint("BOTTOMLEFT", f.cancelBtn:GetParent(), "BOTTOMLEFT", 14, 14)
    f.cancelBtn:SetText("Cancel")

    f.skipBtn = CreateFrame("Button", nil, f.body, "UIPanelButtonTemplate")
    f.skipBtn:SetSize(120, 24)
    f.skipBtn:SetPoint("BOTTOMRIGHT", f.skipBtn:GetParent(), "BOTTOMRIGHT", -146, 14)
    f.skipBtn:SetText("Skip")

    f.importNextBtn = CreateFrame("Button", nil, f.body, "UIPanelButtonTemplate")
    f.importNextBtn:SetSize(120, 24)
    f.importNextBtn:SetPoint("BOTTOMRIGHT", f.importNextBtn:GetParent(), "BOTTOMRIGHT", -14, 14)
    f.importNextBtn:SetText("Import Next")
    f.importNextBtn:SetNormalFontObject("GameFontHighlight")

    addon.PresetImportStepper = f
end

local function PM_StartPresetImportStepper(importString, payload)
    PM_CreatePresetImportStepperPopup()
    local f = addon.PresetImportStepper
    if not f then return end

    local ids = {}
    for providerId in pairs(payload.addons or {}) do
        ids[#ids + 1] = providerId
    end
    table.sort(ids, function(a,b) return tostring(a):lower() < tostring(b):lower() end)

    local baseName = tostring(payload.name or "Imported Preset")
    local presetName = EnsureUniquePresetName(baseName)

    f._pm = {
        importString = importString,
        payload = payload,
        ids = ids,
        idx = 1,
        total = #ids,
        presetName = presetName,
        selections = {},
        imported = 0,
        skipped = 0,
        failed = 0,
        statusById = {},
        pendingImports = {}
    }
    f._pmDone = nil
    f.importNextBtn:SetText("Import Next")
    f.cancelBtn:SetText("Cancel")

        local function EnsureListRows()
        local st = f._pm
        if not st then return end

        for i = 1, st.total do
            if not f.listRows[i] then
                local r = CreateFrame("Frame", nil, f.listChild)
                r:SetHeight(18)
                r:SetPoint("LEFT", r:GetParent(), "LEFT", 0, 0)
                r:SetPoint("RIGHT", f.listChild, "RIGHT", 0, 0)

                r.bg = r:CreateTexture(nil, "BACKGROUND")
                r.bg:SetAllPoints(r.bg:GetParent())
                r.bg:SetColorTexture(1, 1, 1, 0)

                r.txt = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                r.txt:SetPoint("LEFT", r.txt:GetParent(), "LEFT", 6, 0)
                r.txt:SetJustifyH("LEFT")

                f.listRows[i] = r
            end
        end

        for i = st.total + 1, #f.listRows do
            if f.listRows[i] then f.listRows[i]:Hide() end
        end
    end

    local function StatusIcon(pid)
        local st = f._pm
        if not st then return "" end
        local s = st.statusById and st.statusById[pid] or nil
        if s == "imported" then return "|cff00ff00|r (imported) "
        elseif s == "skipped" then return "|cffffaa00|r (skipped) "
        elseif s == "failed" then return "|cffff5555|r (failed) "
        else return "|cff9aa0a6|r "
        end
    end

    local function RepaintList()
        local st = f._pm
        if not st then return end
        EnsureListRows()

        local y = -2
        for i = 1, st.total do
            local pid = st.ids[i]
            local r = f.listRows[i]
            local display = PM_GetProviderNiceName(pid)

            r:Show()
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", r:GetParent(), "TOPLEFT", 0, y)
            r:SetPoint("RIGHT", f.listChild, "RIGHT", 0, 0)

            local isCurrent = (i == st.idx and st.idx <= st.total)

            if isCurrent then
                r.bg:SetColorTexture(0.35, 0.65, 1.00, 0.14)
            else
                r.bg:SetColorTexture(1, 1, 1, 0)
            end

            r.txt:SetText(StatusIcon(pid) .. display)

            local prov = addon.Providers and addon.Providers[pid]
            local status = st.statusById and st.statusById[pid] or nil
            if not prov then
                r.txt:SetTextColor(1.00, 0.35, 0.35, 1.00)
            elseif status == "imported" then
                r.txt:SetTextColor(0.75, 1.00, 0.75, 1.00)
            elseif status == "skipped" then
                r.txt:SetTextColor(1.00, 0.90, 0.60, 1.00)
            elseif status == "failed" then
                r.txt:SetTextColor(1.00, 0.45, 0.45, 1.00)
            else
                r.txt:SetTextColor(unpack(THEME.text))
            end

            y = y - 18
        end

        f.listChild:SetHeight(math.max(1, st.total * 18 + 6))

        if st.idx and st.idx <= st.total then
            local lineH = 18
            local viewH = f.listScroll:GetHeight() or 1
            local targetTop = (st.idx - 1) * lineH
            local targetBottom = targetTop + lineH
            local cur = f.listScroll:GetVerticalScroll() or 0

            if targetTop < cur then
                f.listScroll:SetVerticalScroll(targetTop)
            elseif targetBottom > (cur + viewH) then
                f.listScroll:SetVerticalScroll(math.max(0, targetBottom - viewH))
            end
        end
    end

    local function AutoSkipMissingProviders_Iterative()
        local st = f._pm
        if not st then return end

        while st.idx <= st.total do
            local pid = st.ids[st.idx]
            local prov = addon.Providers and addon.Providers[pid]
            if prov then
                break
            end

            st.skipped = (st.skipped or 0) + 1
            st.statusById[pid] = "skipped"
            st.idx = st.idx + 1
        end
    end

    local function UpdateUI()
        local st = f._pm
        if not st then return end
        AutoSkipMissingProviders_Iterative()
        RepaintList()

        f.progress:SetText(("%d / %d"):format(math.min(st.idx, st.total), st.total))

        f.status:SetText(("Preset: |cffcfd0ff%s|r   Imported: |cff00ff00%d|r   Skipped: |cffffaa00%d|r   Failed: |cffff5555%d|r")
            :format(st.presetName, st.imported, st.skipped, st.failed))

        if st.idx > st.total then
            f.current:SetText("|cff00ff00Done.|r")
            f.result:SetText("Applying imported profiles...")

            if addon.SavePreset then
                addon:SavePreset(st.presetName, st.selections)
            end

            for providerId, profileName in pairs(st.selections) do
                local prov = addon.Providers and addon.Providers[providerId]
                if prov then
                    if type(prov.SetProfile) == "function" then
                        pcall(function()
                            prov:SetProfile(profileName)
                        end)
                    elseif type(prov.ApplyProfile) == "function" then
                        pcall(function()
                            prov:ApplyProfile(profileName)
                        end)
                    end
                end
            end

            addon:RefreshMainUI()
            addon:RefreshInlineEditorLiveStates()

            f.result:SetText(("|cff00ff00Done: %d imported, %d skipped, %d failed.|r Reload to finish applying them.")
                :format(st.imported or 0, st.skipped or 0, st.failed or 0))

            f.skipBtn:Disable()
            f._pmDone = true
            f.importNextBtn:SetText(RELOADUI or "Reload UI")
            f.importNextBtn:Enable()
            f.cancelBtn:SetText(CLOSE or "Close")
            return
        end

        local pid = st.ids[st.idx]
        local display = PM_GetProviderNiceName(pid)

        f.current:SetText(display)
        f.result:SetText("Ready to import this addon profile.")
        f.importNextBtn:Enable()
        f.skipBtn:Enable()
        RepaintList()
    end

    local function Advance()
        local st = f._pm
        if not st then return end
        st.idx = st.idx + 1
        UpdateUI()
    end

    f.cancelBtn:SetScript("OnClick", function()
        f._pm = nil
        f:Hide()
    end)

    f.skipBtn:SetScript("OnClick", function()
        local st = f._pm
        if not st then return end

        local pid = st.ids[st.idx]
        local prov = addon.Providers and addon.Providers[pid]
        if not prov then
            st.skipped = st.skipped + 1
            st.statusById[pid] = "skipped"
            f.result:SetText("|cffffaa00Skipped (missing provider).|r")
            Advance()
            return
        end

        st.skipped = st.skipped + 1
        st.statusById[pid] = "skipped"
        f.result:SetText("|cffffaa00Skipped by user.|r")
        Advance()
    end)

    f.importNextBtn:SetScript("OnClick", function()
        if f._pmDone then
            ReloadUI()
            return
        end
        local st = f._pm
        if not st then return end
        if st.idx > st.total then return end

        local pid = st.ids[st.idx]
        local prov = addon.Providers and addon.Providers[pid]
        local exportStr = (st.payload.addons or {})[pid]

        if not prov then
            st.skipped = st.skipped + 1
            st.statusById[pid] = "skipped"
            f.result:SetText("|cffffaa00Skipped (missing provider).|r")
            Advance()
            return
        end

        if type(prov.ImportProfile) ~= "function" then
            st.failed = st.failed + 1
            st.statusById[pid] = "failed"
            f.result:SetText("|cffff5555This provider does not support ImportProfile().|r")
            Advance()
            return
        end

        if type(exportStr) ~= "string" or exportStr == "" then
            st.failed = st.failed + 1
            st.statusById[pid] = "failed"
            f.result:SetText("|cffff5555Missing export payload for this provider.|r")
            Advance()
            return
        end

        f.importNextBtn:Disable()
        f.skipBtn:Disable()
        f.result:SetText("Importing...")

        Delay(0, function()
            local function PM_ImportProfile_NoApply(prov, exportStr)
                local oldSetProfile   = prov.SetProfile
                local oldApplyProfile = prov.ApplyProfile

                prov.SetProfile = function() return true end
                prov.ApplyProfile = function() return true end

                local db = prov.db
                local oldDbSetProfile
                if db and type(db.SetProfile) == "function" then
                    oldDbSetProfile = db.SetProfile
                    db.SetProfile = function() return true end
                end

                local ok, a, b = pcall(function()
                    return prov:ImportProfile(exportStr, st.presetName)
                end)

                if db and oldDbSetProfile then
                    db.SetProfile = oldDbSetProfile
                end
                prov.SetProfile = oldSetProfile
                prov.ApplyProfile = oldApplyProfile

                if not ok then
                    return false, a
                end
                return true, a, b
            end

            local ok, a, b = PM_ImportProfile_NoApply(prov, exportStr)

            if not ok then
                st.failed = st.failed + 1
                f.result:SetText("|cffff5555Import failed:|r " .. tostring(a))
                Advance()
                return
            end

            if a ~= true then
                st.failed = st.failed + 1
                f.result:SetText("|cffff5555Import failed:|r " .. tostring(b or a))
                Advance()
                return
            end

            local newName = tostring(b or "")
            if newName == "" then newName = "Imported" end

            st.pendingImports[pid] = exportStr
            st.selections[pid] = newName
            st.imported = st.imported + 1
            st.statusById[pid] = "imported"
            f.result:SetText("|cff00ff00Imported. Will apply all at the end.|r")
            Advance()
        end)
    end)

    UpdateUI()
    f:Show()
end

function addon:CreateImportWizard()
    if self.ImportWizard then return end

    local f = CreateFrame("Frame", "ProfileManagerImportWizard", UIParent, "BackdropTemplate")
    f:SetSize(760, 520)
    f:SetPoint("CENTER", f:GetParent(), "CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(2000)
    f:Hide()

    f.Bg = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    f.Bg:SetColorTexture(0.08, 0.08, 0.09, 0.98)

    PM_ApplyBlizzardOptionsSkin(f)

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -3)
    f.title:SetTextColor(unpack(THEME.titleText))
    f.title:SetText("Import Preset")

    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonDefaultAnchors")
    f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 20)

    f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    f.hint:SetTextColor(unpack(THEME.mutedText))
    f.hint:ClearAllPoints()
    f.hint:SetPoint("TOPLEFT", f.hint:GetParent(), "TOPLEFT", 16, -30)
    f.hint:SetTextColor(unpack(THEME.mutedText))
    f.hint:SetText("Paste your preset export string below (game might freeze for a few seconds):")

    CreateImportWizardEditBox(f)

    f.cancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.cancelBtn:SetSize(120, 24)
    f.cancelBtn:SetPoint("BOTTOMRIGHT", f.cancelBtn:GetParent(), "BOTTOMRIGHT", -150, 18)
    f.cancelBtn:SetText("Cancel")
    f.cancelBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    f.importBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.importBtn:SetSize(120, 24)
    f.importBtn:SetPoint("BOTTOMRIGHT", f.importBtn:GetParent(), "BOTTOMRIGHT", -20, 18)
    f.importBtn:SetText("Import")
    f.importBtn:SetNormalFontObject("GameFontHighlight")

    local function ResizePasteBox()
        if not f.pasteScroll or not f.pasteBox then return end
        local w = f.pasteScroll:GetWidth() or 600
        local h = f.pasteScroll:GetHeight() or 300
        f.pasteBox:SetWidth(math.max(1, w))
        f.pasteBox:SetHeight(math.max(1, h * 2))
        f.pasteScroll:UpdateScrollChildRect()
    end

    f:SetScript("OnShow", function()
        if f.pasteBox then
            f.pasteBox:SetText("")
            f.pasteBox:SetFocus()
        end
        ResizePasteBox()
    end)

    f:SetScript("OnSizeChanged", function()
        ResizePasteBox()
    end)

    f.importBtn:SetScript("OnClick", function()
        local text = f.pasteBox and strtrim(f.pasteBox:GetText() or "") or ""
        if text == "" then
            print("|cffff5555ProfileManager|r Paste an import string first.")
            return
        end

        local payload, err = PM_DecodePresetPayload(text)
        if not payload then
            print("|cffff5555ProfileManager|r Invalid preset string: " .. tostring(err))
            return
        end

        PM_StartPresetImportStepper(text, payload)
    end)

    UISpecialFrames_Add("ProfileManagerImportWizard")

    self.ImportWizard = f
end

function addon:ShowPresetImportWizard()
    self:CreateImportWizard()
    local f = self.ImportWizard
    if not f then return end
    f:Show()
end

local function PM_GetSetting(key, default)
    local s = ProfileManagerDB and ProfileManagerDB.settings
    if s and s[key] ~= nil then return s[key] end
    return default
end

local function PM_SetSetting(key, value)
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.settings = ProfileManagerDB.settings or {}
    ProfileManagerDB.settings[key] = value
end

local function PM_CollectFontStrings(frame, out)
    if not frame then return end
    local regions = { frame:GetRegions() }
    for _, r in ipairs(regions) do
        if r and r.GetObjectType and r:GetObjectType() == "FontString" then
            out[#out + 1] = r
        end
    end
    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        PM_CollectFontStrings(child, out)
    end
end

local PM_FontProbe
local function PM_FontApplies(path)
    if type(path) ~= "string" or path == "" then return false end
    if not PM_FontProbe then
        PM_FontProbe = CreateFrame("EditBox", nil, UIParent)
        PM_FontProbe:SetAutoFocus(false)
        PM_FontProbe:EnableKeyboard(false)
        PM_FontProbe:Hide()
    end
    return PM_FontProbe:SetFont(path, 12, "") and true or false
end

local PM_BUILTIN_FONTS = {
    ["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
    ["Arial Narrow"]     = "Fonts\\ARIALN.TTF",
    ["Skurri"]           = "Fonts\\skurri.ttf",
    ["Morpheus"]         = "Fonts\\MORPHEUS.ttf",
}

local function PM_ResolveFontPath(name)
    if type(name) ~= "string" or name == "" then return nil end
    local path
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then path = LSM:Fetch("font", name, true) end
    if not path then path = PM_BUILTIN_FONTS[name] end
    if not path and (name:find("\\") or name:find("/")) then path = name end
    if PM_FontApplies(path) then return path end
    return nil
end

local function PM_FontList()
    local names = {}
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then
        for _, n in ipairs(LSM:List("font")) do
            if PM_ResolveFontPath(n) then names[#names + 1] = n end
        end
    else
        for n in pairs(PM_BUILTIN_FONTS) do names[#names + 1] = n end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local function PM_ResolveFontDelta()
    local d = PM_GetSetting("fontDelta", nil)
    if d == nil then
        local fac = PM_GetSetting("fontSize", 1.0)
        d = math.floor(12 * ((tonumber(fac) or 1) - 1) + 0.5)
    end
    return math.max(-2, math.min(8, math.floor((tonumber(d) or 0) + 0.5)))
end

local function PM_ApplyFontSizeToMain(f)
    if not f then return end
    local delta = PM_ResolveFontDelta()
    local chosenFace = PM_ResolveFontPath(PM_GetSetting("fontFace", nil))
    local strings = {}
    PM_CollectFontStrings(f, strings)
    for _, fs in ipairs(strings) do
        if not fs._pm_baseSize then
            local _, size = fs:GetFont()
            if size and size > 0 then
                fs._pm_baseSize = size
            end
        end
        if fs._pm_baseSize then
            local face, _, flags = fs:GetFont()
            if not fs._pm_baseFace then fs._pm_baseFace = face end
            local useFace = chosenFace or fs._pm_baseFace or face
            if useFace then
                fs:SetFont(useFace, math.max(6, fs._pm_baseSize + delta), flags or "")
                local n = fs:GetNumPoints() or 0
                if n > 0 then
                    local pts = {}
                    for pi = 1, n do
                        pts[pi] = { fs:GetPoint(pi) }
                    end
                    fs:ClearAllPoints()
                    for pi = 1, n do
                        local p = pts[pi]
                        fs:SetPoint(p[1], p[2], p[3], p[4], p[5])
                    end
                end
            end
        end
    end
end

local function PM_ReanchorTree(frame)
    for _, child in ipairs({ frame:GetChildren() }) do
        local n = child:GetNumPoints() or 0
        if n > 0 then
            local pts = {}
            for i = 1, n do pts[i] = { child:GetPoint(i) } end
            child:ClearAllPoints()
            for i = 1, n do
                local p = pts[i]
                child:SetPoint(p[1], p[2], p[3], p[4], p[5])
            end
        end
        PM_ReanchorTree(child)
    end
end

local function PM_ApplyWindowScale(f)
    f:SetScale(PM_GetSetting("scale", 1.0))
end

local function PM_ShowNamePopup(key, text, defaultName, onAccept, maxLetters)
    StaticPopupDialogs[key] = {
        text = text,
        button1 = ACCEPT or "Accept",
        button2 = CANCEL,
        hasEditBox = true,
        editBoxWidth = 260,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        OnShow = function(self)
            local box = self.editBox or self.EditBox
            if not box then return end
            if box.SetMaxLetters then box:SetMaxLetters(maxLetters or 50) end
            box:SetText(defaultName or "")
            box:HighlightText()
            box:SetFocus()
        end,
        OnAccept = function(self)
            local box = self.editBox or self.EditBox
            onAccept(box and box:GetText() or "")
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            onAccept(self:GetText() or "")
            if parent then parent:Hide() end
        end,
        EditBoxOnEscapePressed = function(self)
            local parent = self:GetParent()
            if parent then parent:Hide() end
        end,
    }
    StaticPopup_Show(key)
end

local function PM_ShowConfirm(key, text, onAccept)
    StaticPopupDialogs[key] = {
        text = text,
        button1 = YES or "Yes",
        button2 = NO or "No",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        showAlert = true,
        OnAccept = onAccept,
    }
    StaticPopup_Show(key)
end

local function PM_ProfileIcon(row, atlas, tex, tip, fn, xText)
    local b = CreateFrame("Button", nil, row)
    b:SetSize(16, 16)
    if xText then
        b.xLbl = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.xLbl:SetPoint("CENTER", b.xLbl:GetParent(), "CENTER", 0, 0)
        b.xLbl:SetText("X")
        b.xLbl:SetTextColor(0.95, 0.25, 0.25, 1)
    else
        b:SetNormalTexture(tex)
        local nt = b:GetNormalTexture()
        if atlas and nt then pcall(nt.SetAtlas, nt, atlas) end
    end
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    b:SetScript("OnClick", function() fn(row.profileName) end)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tip)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
end

local function PM_BuildKeybindsPage(f)
    local KB = addon.Keybinds
    local ROW_H = 22

    local page = CreateFrame("Frame", nil, f)
    page:SetPoint("TOPLEFT", page:GetParent(), "TOPLEFT", 10, -38)
    page:SetPoint("BOTTOMRIGHT", page:GetParent(), "BOTTOMRIGHT", -10, 10)
    page:Hide()
    f.keysPage = page

    local function Label(parent, template, color, text)
        local fs = parent:CreateFontString(nil, "OVERLAY", template)
        fs:SetTextColor(unpack(color))
        fs:SetJustifyH("LEFT")
        fs:SetText(text or "")
        return fs
    end

    local left = CreateFrame("Frame", nil, page)
    left:SetPoint("TOPLEFT", left:GetParent(), "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", left:GetParent(), "BOTTOMLEFT", 0, 0)
    left:SetWidth(LEFT_PANEL_WIDTH)
    local leftBg = CreatePanel(page, 0)
    leftBg:SetAllPoints(left)
    leftBg:SetFrameLevel(left:GetFrameLevel())
    left:SetFrameLevel(left:GetFrameLevel() + 1)

    local title = Label(left, "GameFontHighlightLarge", THEME.text, "Keybind Profiles")
    title:SetPoint("TOPLEFT", title:GetParent(), "TOPLEFT", 10, -10)

    local nameBox = CreateFrame("EditBox", nil, left, "InputBoxTemplate")
    nameBox:SetSize(LEFT_PANEL_WIDTH - 25, 24)
    nameBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -12)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(50)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local nameHint = nameBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameHint:SetTextColor(0.62, 0.62, 0.65, 1)
    nameHint:SetPoint("LEFT", nameHint:GetParent(), "LEFT", 0, 0)
    nameHint:SetText("Profile name (optional)")
    nameBox:HookScript("OnTextChanged", function(self) nameHint:SetShown((self:GetText() or "") == "") end)

    local saveBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    saveBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    saveBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -5, -8)
    saveBtn:SetText("Save current keybinds")

    local importBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    importBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    importBtn:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 0, -8)
    importBtn:SetText("Import keybinds")

    local sep = left:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(unpack(THEME.divider))
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT",  importBtn, "BOTTOMLEFT",  0, -8)
    sep:SetPoint("TOPRIGHT", importBtn, "BOTTOMRIGHT", 0, -8)

    local listContainer = CreateFrame("Frame", nil, left)
    listContainer:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 0, -18)
    listContainer:SetPoint("BOTTOMRIGHT", listContainer:GetParent(), "BOTTOMRIGHT", -10, 10)
    local listPanel = CreatePanel(listContainer, 0)
    listPanel:SetAllPoints(listPanel:GetParent())

    local profScroll = CreateFrame("ScrollFrame", nil, listContainer, "ScrollFrameTemplate")
    profScroll:SetPoint("TOPLEFT", profScroll:GetParent(), "TOPLEFT", 4, -4)
    profScroll:SetPoint("BOTTOMRIGHT", profScroll:GetParent(), "BOTTOMRIGHT", -24, 4)
    profScroll:EnableMouseWheel(true)
    profScroll:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp((self:GetVerticalScroll() or 0) - delta * PRESET_ROW_H, 0, range))
    end)
    local profChild = CreateFrame("Frame", nil, profScroll)
    profChild:SetSize(1, 1)
    profScroll:SetScrollChild(profChild)

    local profEmpty = Label(listContainer, "GameFontDisable", THEME.mutedText,
        "No keybind profiles yet. Save your current keybinds or import an export string.")
    profEmpty:SetPoint("TOPLEFT", profEmpty:GetParent(), "TOPLEFT", 10, -10)
    profEmpty:SetPoint("RIGHT", profEmpty:GetParent(), "RIGHT", -10, 0)
    profEmpty:SetWordWrap(true)

    local vdiv = page:CreateTexture(nil, "ARTWORK")
    vdiv:SetColorTexture(1, 1, 1, 0.06)
    vdiv:SetPoint("TOPLEFT",    left, "TOPRIGHT",    LEFT_PANEL_GAP / 2, 0)
    vdiv:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", LEFT_PANEL_GAP / 2, 0)
    vdiv:SetWidth(1)

    local right = CreateFrame("Frame", nil, page)
    right:SetPoint("TOPLEFT",     left, "TOPRIGHT", LEFT_PANEL_GAP, 0)
    right:SetPoint("BOTTOMRIGHT", right:GetParent(), "BOTTOMRIGHT", 0, 0)
    local rightBg = CreatePanel(page, 0)
    rightBg:SetAllPoints(right)
    rightBg:SetFrameLevel(right:GetFrameLevel())
    right:SetFrameLevel(right:GetFrameLevel() + 1)

    local listTitle = Label(right, "GameFontHighlightLarge", THEME.titleText)
    listTitle:SetPoint("TOPLEFT", listTitle:GetParent(), "TOPLEFT", 12, -12)
    listTitle:SetPoint("RIGHT", right, "RIGHT", -240, 0)
    listTitle:SetWordWrap(false)

    local hint = Label(right, "GameFontDisable", THEME.mutedText)
    hint:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 0, -8)
    hint:SetPoint("RIGHT", right, "RIGHT", -12, 0)
    hint:SetWordWrap(true)

    local function SetStatus(text, isError)
        hint:SetText(text or "")
        if isError then hint:SetTextColor(1, 0.35, 0.35, 1) else hint:SetTextColor(unpack(THEME.mutedText)) end
    end

    local okSearch, search = pcall(CreateFrame, "EditBox", nil, right, "SearchBoxTemplate")
    if not okSearch or not search then
        search = CreateFrame("EditBox", nil, right, "InputBoxTemplate")
    end
    search:SetSize(200, 22)
    search:SetAutoFocus(false)
    search:SetPoint("TOPRIGHT", search:GetParent(), "TOPRIGHT", -30, -16)
    if search.Instructions then search.Instructions:SetText("Search command or key...") end

    local charChk = CreateFrame("CheckButton", nil, right, "UICheckButtonTemplate")
    charChk:SetSize(26, 26)
    charChk:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", -4, -8)
    if charChk.text then
        charChk.text:SetTextColor(unpack(THEME.text))
    end

    local loadBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    loadBtn:SetSize(140, 22)
    loadBtn:SetPoint("RIGHT", right, "RIGHT", -30, 0)
    loadBtn:SetPoint("TOP", charChk, "TOP", 0, -2)
    loadBtn:SetText("Load profile")

    local updateBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    updateBtn:SetSize(140, 22)
    updateBtn:SetPoint("RIGHT", loadBtn, "LEFT", -6, 0)
    updateBtn:SetText("Save profile")

    local list = CreateFrame("ScrollFrame", nil, right, "ScrollFrameTemplate")
    list:SetPoint("TOPLEFT", charChk, "BOTTOMLEFT", 4, -8)
    list:SetPoint("BOTTOMRIGHT", list:GetParent(), "BOTTOMRIGHT", -28, 10)
    local listChild = CreateFrame("Frame", nil, list)
    listChild:SetSize(1, 1)
    list:SetScrollChild(listChild)

    local rows, profRows = {}, {}
    local EMPTY_KEYS = {}
    local NO_BG = { 0, 0, 0, 0 }
    local pending, pendingSet
    local selectedProfile
    local RefreshList, RefreshProfiles

    local function KeysText(keys)
        if not keys or #keys == 0 then return "|cff777777Not bound|r" end
        local out = {}
        for i, key in ipairs(keys) do out[i] = KB:KeyLabel(key) end
        return table.concat(out, ", ")
    end

    local function GetRow(i)
        local row = rows[i]
        if row then return row end
        row = CreateFrame("Frame", nil, listChild)
        row:SetHeight(ROW_H)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row.bg:GetParent())
        row.name = Label(row, "GameFontHighlightSmall", THEME.text)
        row.name:SetPoint("LEFT", row.name:GetParent(), "LEFT", 6, 0)
        row.name:SetPoint("RIGHT", row, "CENTER", -6, 0)
        row.name:SetWordWrap(false)
        row.keys = Label(row, "GameFontHighlightSmall", THEME.text)
        row.keys:SetPoint("LEFT", row, "CENTER", 0, 0)
        row.keys:SetPoint("RIGHT", row.keys:GetParent(), "RIGHT", -6, 0)
        row.keys:SetWordWrap(false)
        PM_ApplyFontSizeToMain(row)
        rows[i] = row
        return row
    end

    local cacheKey, cacheVersion, cacheItems, cacheChanges, cacheMissing

    local function SearchText(label, keys, keys2)
        local parts = { label }
        for _, set in ipairs({ keys or EMPTY_KEYS, keys2 or EMPTY_KEYS }) do
            for _, key in ipairs(set) do
                parts[#parts + 1] = key
                parts[#parts + 1] = KB:KeyLabel(key)
            end
        end
        return table.concat(parts, "\n"):lower()
    end

    local function BuildItems()
        local key = pending or false
        if cacheItems and cacheKey == key and cacheVersion == KB:Version() then return cacheItems end
        local items = {}
        if pending then
            local changes, missing = KB:Preview(pending)
            for _, c in ipairs(changes) do
                local label = KB:CommandLabel(c.action)
                items[#items + 1] = {
                    label,
                    "|cffff7070" .. KeysText(c.old) .. "|r  ->  |cff70ff70" .. KeysText(c.new) .. "|r",
                    SearchText(label, c.old, c.new),
                }
            end
            cacheChanges, cacheMissing = #changes, missing
        else
            for _, b in ipairs(KB:ReadCurrent()) do
                if #b.keys > 0 then
                    local label = KB:CommandLabel(b.action)
                    items[#items + 1] = { label, KeysText(b.keys), SearchText(label, b.keys) }
                end
            end
        end
        cacheKey, cacheVersion, cacheItems = key, KB:Version(), items
        return items
    end

    local function DescribePending()
        local msg = (cacheChanges == 0) and "Matches your current keybinds." or
            ("%d command(s) will change when you load it."):format(cacheChanges)
        if cacheMissing > 0 then
            msg = msg .. (" %d key(s) belong to commands this client doesn't have and will be skipped."):format(cacheMissing)
        end
        if pendingSet and pendingSet ~= "" then
            msg = ("Saved from the %s set. "):format(pendingSet) .. msg
        end
        return msg
    end

    RefreshList = function()
        if not KB:IsAvailable() then return end
        local items = BuildItems()

        if pending then
            listTitle:SetText(selectedProfile)
            SetStatus(DescribePending())
            loadBtn:SetEnabled(cacheChanges > 0)
            updateBtn:Enable()
        else
            listTitle:SetText("Current Keybinds")
            SetStatus("Select a profile on the left to see what loading it would change.")
            loadBtn:SetEnabled(false)
            updateBtn:Disable()
        end

        local filter = strtrim(search:GetText() or ""):lower()
        local n = 0
        for _, item in ipairs(items) do
            if filter == "" or item[3]:find(filter, 1, true) then
                n = n + 1
                local row = GetRow(n)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT",  listChild, "TOPLEFT",  0, -(n - 1) * ROW_H)
                row:SetPoint("TOPRIGHT", listChild, "TOPRIGHT", 0, -(n - 1) * ROW_H)
                row.bg:SetColorTexture(unpack((n % 2 == 0) and THEME.rowBg or NO_BG))
                row.name:SetText(item[1])
                row.keys:SetText(item[2])
                row:Show()
            end
        end
        for i = n + 1, #rows do rows[i]:Hide() end
        listChild:SetWidth(math.max(1, list:GetWidth() or 1))
        listChild:SetHeight(math.max(n * ROW_H, 1))
    end

    local function RefreshSet()
        if not KB:IsAvailable() then return end
        if charChk.text then
            charChk.text:SetText((CHARACTER_SPECIFIC_KEYBINDINGS or "Character Specific Keybindings")
                .. "  |cff9aa0a6(active: " .. KB:SetName() .. ")|r")
        end
        charChk:SetChecked(KB:IsCharacterSet())
    end

    local function SelectProfile(name)
        local p, map
        if name then p, map = KB:GetProfile(name) end
        if p then
            selectedProfile, pending, pendingSet = name, map, p.set
        else
            selectedProfile, pending, pendingSet = nil, nil, nil
        end
        RefreshProfiles()
        RefreshList()
    end

    local function LoadProfile(name)
        local p, map = KB:GetProfile(name)
        if not p then return end
        local ok, applied, failed, untouched = KB:Import(map)
        if not ok then SetStatus(applied, true) return end
        SelectProfile(name)
        local msg = ("Loaded '%s' into the %s set: %d key(s) bound."):format(name, KB:SetName(), applied)
        if failed > 0 then msg = msg .. (" %d couldn't be bound."):format(failed) end
        if untouched > 0 then msg = msg .. (" %d bound action(s) aren't in this profile and kept their keys."):format(untouched) end
        SetStatus(msg)
    end

    local ShowNamePopup, ShowConfirm, ProfileIcon = PM_ShowNamePopup, PM_ShowConfirm, PM_ProfileIcon

    local function SaveProfile(name, map, setName, doneMsg, keepName)
        name = strtrim(name or "")
        local exists = KB:GetProfile(name) ~= nil
        local function DoSave()
            local ok, savedOrErr
            if exists and not map then
                ok, savedOrErr = KB:UpdateProfile(name)
            else
                ok, savedOrErr = KB:SaveProfile(name, map, setName)
            end
            if not ok then SetStatus(savedOrErr, true) return end
            if not keepName then
                nameBox:SetText("")
                nameBox:ClearFocus()
            end
            SelectProfile(savedOrErr)
            if doneMsg then SetStatus(doneMsg:format(savedOrErr) .. " " .. DescribePending()) end
        end
        if exists and map then
            ShowConfirm("PM_KEYBINDS_OVERWRITE", ("Overwrite keybind profile '%s'?"):format(name), DoSave)
        elseif exists then
            ShowConfirm("PM_KEYBINDS_OVERWRITE", ("Save your current keybinds into '%s'?\n\nCommands this game doesn't have keep their saved keys."):format(name), DoSave)
        else
            DoSave()
        end
    end

    local exportProvider = {
        ExportProfile = function(_, name) return KB:ExportProfile(name) end,
    }

    local function GetProfileRow(i)
        local row = profRows[i]
        if row then return row end
        row = CreateFrame("Button", nil, profChild)
        row:SetHeight(PRESET_ROW_H)
        row:RegisterForClicks("LeftButtonUp")

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row.bg:GetParent())
        if not pcall(row.bg.SetAtlas, row.bg, "Options_List_Hover", true) then
            row.bg:SetColorTexture(unpack(THEME.rowBg))
        end
        row.hover = row:CreateTexture(nil, "HIGHLIGHT")
        row.hover:SetAllPoints(row.hover:GetParent())
        if not pcall(row.hover.SetAtlas, row.hover, "Options_List_Hover", true) then
            row.hover:SetColorTexture(unpack(THEME.rowHover))
        end
        row.selBar = row:CreateTexture(nil, "ARTWORK")
        row.selBar:SetAllPoints(row.selBar:GetParent())
        if not pcall(row.selBar.SetAtlas, row.selBar, "Options_List_Active", true) then
            row.selBar:SetColorTexture(unpack(THEME.rowSelected))
        end
        row.selBar:Hide()

        row.nameText = Label(row, "GameFontNormal", THEME.text)
        row.nameText:SetPoint("LEFT", row.nameText:GetParent(), "LEFT", 8, 0)
        row.nameText:SetPoint("RIGHT", row.nameText:GetParent(), "RIGHT", -80, 0)
        row.nameText:SetWordWrap(false)

        local icons = {
            { "common-icon-checkmark", "Interface\\Buttons\\UI-CheckBox-Check", "Load keybinds", LoadProfile },
            { "common-icon-pencil", "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Rename", function(name)
                ShowNamePopup("PM_KEYBINDS_RENAME", ("Rename keybind profile '%s':"):format(name), name, function(newName)
                    local ok, res = KB:RenameProfile(name, newName)
                    if not ok then SetStatus(res, true) return end
                    if selectedProfile == name then selectedProfile = res end
                    RefreshProfiles()
                    RefreshList()
                end)
            end },
            { "common-icon-forwardarrow", "Interface\\Buttons\\UI-GuildButton-MOTD-Up", "Export", function(name)
                addon:ShowExportPopup(exportProvider, name)
            end },
            { nil, nil, "Delete", function(name)
                ShowConfirm("PM_KEYBINDS_DELETE", ("Delete keybind profile '%s'?"):format(name), function()
                    KB:DeleteProfile(name)
                    if selectedProfile == name then SelectProfile(nil) else RefreshProfiles() end
                end)
            end, true },
        }
        local prev
        for idx = #icons, 1, -1 do
            local d = icons[idx]
            local b = ProfileIcon(row, d[1], d[2], d[3], d[4], d[5])
            if prev then b:SetPoint("RIGHT", prev, "LEFT", -3, 0) else b:SetPoint("RIGHT", row, "RIGHT", 4, 0) end
            prev = b
        end

        row:SetScript("OnClick", function(self)
            SelectProfile((selectedProfile ~= self.profileName) and self.profileName or nil)
        end)
        row:SetScript("OnDoubleClick", function(self) LoadProfile(self.profileName) end)
        row:SetScript("OnEnter", function(self)
            local p = KB:GetProfile(self.profileName)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.profileName)
            if p then
                if p.set then GameTooltip:AddLine(("Saved from the %s set"):format(p.set), 1, 1, 1) end
                if p.savedAt then GameTooltip:AddLine(date("%Y-%m-%d %H:%M", p.savedAt), 0.7, 0.7, 0.74) end
            end
            GameTooltip:AddLine("Click to preview, double-click to load.", 0.7, 0.7, 0.74)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        PM_ApplyFontSizeToMain(row)
        profRows[i] = row
        return row
    end

    RefreshProfiles = function()
        local names = KB:GetProfileNames()
        profChild:SetWidth(math.max(1, (profScroll:GetWidth() or 1) - 8))
        for i, name in ipairs(names) do
            local row = GetProfileRow(i)
            row.profileName = name
            row.nameText:SetText(name)
            row.selBar:SetShown(name == selectedProfile)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT",  profChild, "TOPLEFT",  0, -2 - (i - 1) * PRESET_ROW_H)
            row:SetPoint("RIGHT",    profChild, "RIGHT",    0, 0)
            row:Show()
        end
        for i = #names + 1, #profRows do profRows[i]:Hide() end
        profChild:SetHeight(math.max(#names * PRESET_ROW_H + 6, 1))
        profEmpty:SetShown(#names == 0)
    end

    saveBtn:SetScript("OnClick", function()
        local name = strtrim(nameBox:GetText() or "")
        if name == "" then name = KB:UniqueProfileName(UnitName("player") or "Keybinds") end
        SaveProfile(name, nil, nil, "Saved your current keybinds as '%s'.")
    end)
    nameBox:SetScript("OnEnterPressed", function() saveBtn:Click() end)

    updateBtn:SetScript("OnClick", function()
        if selectedProfile then SaveProfile(selectedProfile, nil, nil, "Saved your current keybinds into '%s'.", true) end
    end)
    updateBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Save profile")
        GameTooltip:AddLine("Saves your current keybinds into the selected profile.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    updateBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    importBtn:SetScript("OnClick", function()
        if not KB:IsAvailable() then return end
        ShowNamePopup("PM_KEYBINDS_IMPORT", "Paste a keybinds export string:", "", function(text)
            local map, setOrErr, profName = KB:Decode(text)
            if not map then SetStatus(setOrErr, true) return end
            local base = strtrim(nameBox:GetText() or "")
            if base == "" then base = profName or "Imported" end
            SaveProfile(KB:UniqueProfileName(base), map, setOrErr, "Imported as '%s'.")
        end, 0)
    end)

    loadBtn:SetScript("OnClick", function()
        if selectedProfile then LoadProfile(selectedProfile) end
    end)

    StaticPopupDialogs["PM_KEYBINDS_TO_ACCOUNT"] = {
        text = CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS
            or "Switch to account keybindings? This character's own keybindings will be deleted.",
        button1 = OKAY,
        button2 = CANCEL,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        showAlert = true,
        OnAccept = function()
            local ok, err = KB:UseCharacterSet(false)
            if not ok then SetStatus(err, true) end
            RefreshSet()
            RefreshList()
        end,
        OnCancel = function() RefreshSet() end,
    }

    charChk:SetScript("OnClick", function(self)
        if self:GetChecked() then
            local ok, err = KB:UseCharacterSet(true)
            if not ok then SetStatus(err, true) end
            RefreshSet()
            RefreshList()
        else
            self:SetChecked(true)
            StaticPopup_Show("PM_KEYBINDS_TO_ACCOUNT")
        end
    end)

    search:HookScript("OnTextChanged", function() RefreshList() end)
    list:HookScript("OnSizeChanged", function(_, w) listChild:SetWidth(math.max(1, w or 1)) end)
    profScroll:HookScript("OnSizeChanged", function(_, w) profChild:SetWidth(math.max(1, (w or 1) - 8)) end)

    page:SetScript("OnShow", function()
        KB:Invalidate()
        RefreshSet()
        RefreshProfiles()
        RefreshList()
    end)
    page:SetScript("OnEvent", function()
        if not page:IsShown() or page._bindingsPending then return end
        page._bindingsPending = true
        Delay(0.1, function()
            page._bindingsPending = false
            if page:IsShown() then
                RefreshSet()
                RefreshList()
            end
        end)
    end)
    page:RegisterEvent("UPDATE_BINDINGS")

    if not KB:IsAvailable() then
        for _, b in ipairs({ saveBtn, importBtn, loadBtn, updateBtn }) do b:Disable() end
        charChk:Disable()
        SetStatus("Keybinding API not available on this client.", true)
    end
end

local function PM_BuildAddonsPage(f)
    local AO = addon.Addons
    local ROW_H = 24

    local page = CreateFrame("Frame", nil, f)
    page:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -38)
    page:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    page:Hide()
    f.addonsPage = page

    local function Label(parent, template, color, text)
        local fs = parent:CreateFontString(nil, "OVERLAY", template)
        fs:SetTextColor(unpack(color))
        fs:SetJustifyH("LEFT")
        fs:SetText(text or "")
        return fs
    end

    local left = CreateFrame("Frame", nil, page)
    left:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
    left:SetWidth(LEFT_PANEL_WIDTH)
    local leftBg = CreatePanel(page, 0)
    leftBg:SetAllPoints(left)
    leftBg:SetFrameLevel(left:GetFrameLevel())
    left:SetFrameLevel(left:GetFrameLevel() + 1)

    local title = Label(left, "GameFontHighlightLarge", THEME.text, "Addon Sets")
    title:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -10)

    local nameBox = CreateFrame("EditBox", nil, left, "InputBoxTemplate")
    nameBox:SetSize(LEFT_PANEL_WIDTH - 25, 24)
    nameBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -12)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(50)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local nameHint = nameBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameHint:SetTextColor(0.62, 0.62, 0.65, 1)
    nameHint:SetPoint("LEFT", nameBox, "LEFT", 0, 0)
    nameHint:SetText("Set name (optional)")
    nameBox:HookScript("OnTextChanged", function(self) nameHint:SetShown((self:GetText() or "") == "") end)

    local saveBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    saveBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    saveBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -5, -8)
    saveBtn:SetText("Save current addons")

    local sep = left:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(unpack(THEME.divider))
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 0, -8)
    sep:SetPoint("TOPRIGHT", saveBtn, "BOTTOMRIGHT", 0, -8)

    local listContainer = CreateFrame("Frame", nil, left)
    listContainer:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 0, -18)
    listContainer:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 10)
    local listPanel = CreatePanel(listContainer, 0)
    listPanel:SetAllPoints(listContainer)

    local setScroll = CreateFrame("ScrollFrame", nil, listContainer, "ScrollFrameTemplate")
    setScroll:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 4, -4)
    setScroll:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -24, 4)
    setScroll:EnableMouseWheel(true)
    setScroll:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp((self:GetVerticalScroll() or 0) - delta * PRESET_ROW_H, 0, range))
    end)
    local setChild = CreateFrame("Frame", nil, setScroll)
    setChild:SetSize(1, 1)
    setScroll:SetScrollChild(setChild)

    local setEmpty = Label(listContainer, "GameFontDisable", THEME.mutedText,
        "No addon sets yet. Choose your addons on the right, then save them as a set.")
    setEmpty:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 10, -10)
    setEmpty:SetPoint("RIGHT", listContainer, "RIGHT", -10, 0)
    setEmpty:SetWordWrap(true)

    local vdiv = page:CreateTexture(nil, "ARTWORK")
    vdiv:SetColorTexture(1, 1, 1, 0.06)
    vdiv:SetPoint("TOPLEFT", left, "TOPRIGHT", LEFT_PANEL_GAP / 2, 0)
    vdiv:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", LEFT_PANEL_GAP / 2, 0)
    vdiv:SetWidth(1)

    local right = CreateFrame("Frame", nil, page)
    right:SetPoint("TOPLEFT", left, "TOPRIGHT", LEFT_PANEL_GAP, 0)
    right:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    local rightBg = CreatePanel(page, 0)
    rightBg:SetAllPoints(right)
    rightBg:SetFrameLevel(right:GetFrameLevel())
    right:SetFrameLevel(right:GetFrameLevel() + 1)

    local listTitle = Label(right, "GameFontHighlightLarge", THEME.titleText)
    listTitle:SetPoint("TOPLEFT", right, "TOPLEFT", 12, -12)
    listTitle:SetPoint("RIGHT", right, "RIGHT", -240, 0)
    listTitle:SetWordWrap(false)

    local hint = Label(right, "GameFontDisable", THEME.mutedText)
    hint:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 0, -8)
    hint:SetPoint("RIGHT", right, "RIGHT", -12, 0)
    hint:SetWordWrap(true)

    local function SetStatus(text, isError)
        hint:SetText(text or "")
        if isError then hint:SetTextColor(1, 0.35, 0.35, 1) else hint:SetTextColor(unpack(THEME.mutedText)) end
    end

    local okSearch, search = pcall(CreateFrame, "EditBox", nil, right, "SearchBoxTemplate")
    if not okSearch or not search then
        search = CreateFrame("EditBox", nil, right, "InputBoxTemplate")
    end
    search:SetSize(200, 22)
    search:SetAutoFocus(false)
    search:SetPoint("TOPRIGHT", right, "TOPRIGHT", -30, -16)
    if search.Instructions then search.Instructions:SetText("Search addons...") end

    local function Button(text, w)
        local b = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
        b:SetSize(w, 22)
        b:SetText(text)
        return b
    end
    local enableAllBtn = Button("Enable all", 100)
    enableAllBtn:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -10)
    local disableAllBtn = Button("Disable all", 100)
    disableAllBtn:SetPoint("LEFT", enableAllBtn, "RIGHT", 6, 0)
    local currentBtn = Button("Use current", 100)
    currentBtn:SetPoint("LEFT", disableAllBtn, "RIGHT", 6, 0)
    currentBtn:Hide()
    local reloadBtn = Button("Apply", 110)
    reloadBtn:SetPoint("RIGHT", right, "RIGHT", -30, 0)
    reloadBtn:SetPoint("TOP", enableAllBtn, "TOP", 0, 0)
    local loadBtn = Button("Save", 90)
    loadBtn:SetPoint("RIGHT", reloadBtn, "LEFT", -6, 0)

    local list = CreateFrame("ScrollFrame", nil, right, "ScrollFrameTemplate")
    list:SetPoint("TOPLEFT", enableAllBtn, "BOTTOMLEFT", 0, -10)
    list:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -28, 10)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp((self:GetVerticalScroll() or 0) - delta * ROW_H * 3, 0, range))
    end)
    local listChild = CreateFrame("Frame", nil, list)
    listChild:SetSize(1, 1)
    list:SetScrollChild(listChild)

    local rows, setRows = {}, {}
    local expandedGroups = {}
    local drafts = {}

    local function Draft(name)
        if drafts[name] then return drafts[name] end
        local _, saved = AO:GetSet(name)
        local copy = {}
        for k, v in pairs(saved or {}) do copy[k] = v end
        drafts[name] = copy
        return copy
    end

    local function IsDirty(name)
        local d = drafts[name]
        if not d then return false end
        local _, saved = AO:GetSet(name)
        saved = saved or {}
        for k, v in pairs(d) do if saved[k] ~= v then return true end end
        for k, v in pairs(saved) do if d[k] ~= v then return true end end
        return false
    end
    local NO_BG = { 0, 0, 0, 0 }
    local selectedSet
    local RefreshList, RefreshSets

    local GOLD, RED, GREY = { 1, 0.82, 0 }, { 1, 0.35, 0.35 }, { 0.5, 0.5, 0.5 }

    local function LiveStatus(a)
        if a.enabled then
            if a.loaded then return "Loaded", { 0.45, 0.85, 0.45 } end
            if not a.loadable and a.reason and a.reason ~= "DEMAND_LOADED" and a.reason ~= "DEP_DEMAND_LOADED" then
                return _G["ADDON_" .. a.reason] or a.reason, RED
            end
            if a.lod then return "Load on demand", THEME.mutedText end
            return "Reload to load", GOLD
        end
        if a.loaded then return "Reload to unload", GOLD end
        return "Disabled", GREY
    end

    local function ShowTooltip(row)
        local a = row.addonInfo
        if not a then return end
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddDoubleLine(a.title, C_AddOns.GetAddOnMetadata(a.index, "Version") or "", 1, 1, 1, 0.7, 0.7, 0.74)
        local notes = C_AddOns.GetAddOnNotes(a.index)
        if notes and notes ~= "" then GameTooltip:AddLine(notes, 0.9, 0.9, 0.9, true) end
        local deps = { C_AddOns.GetAddOnDependencies(a.index) }
        if #deps > 0 then GameTooltip:AddLine((ADDON_DEPENDENCIES or "Dependencies: ") .. table.concat(deps, ", "), 1, 0.82, 0, true) end
        if a.parent then GameTooltip:AddLine(("Module of %s"):format(a.parent.title), 0.7, 0.7, 0.74, true) end
        if a.children then GameTooltip:AddLine(("%d module(s)"):format(#a.children), 0.7, 0.7, 0.74, true) end
        if a.locked then GameTooltip:AddLine("ProfileManager can't disable itself.", 0.7, 0.7, 0.74, true) end
        GameTooltip:Show()
    end

    local function OnToggle(chk)
        local a = chk:GetParent().addonInfo
        if not a then return end
        local on = chk:GetChecked() and true or false
        if a.locked and not on then
            chk:SetChecked(true)
            return
        end
        if selectedSet then
            Draft(selectedSet)[a.name] = on
        else
            AO:SetEnabled(a.name, on)
        end
        RefreshList()
    end

    local function GetRow(i)
        local row = rows[i]
        if row then return row end
        row = CreateFrame("Frame", nil, listChild)
        row:SetHeight(ROW_H)
        row:EnableMouse(true)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row)
        row.expand = CreateFrame("Button", nil, row)
        row.expand:SetSize(14, 14)
        row.expand:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.expand:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
        row.expand:SetScript("OnClick", function(self)
            local a = self:GetParent().addonInfo
            if not a then return end
            expandedGroups[a.name] = not expandedGroups[a.name]
            RefreshList()
        end)
        row.chk = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.chk:SetSize(22, 22)
        row.chk:SetPoint("LEFT", row, "LEFT", 20, 0)
        if row.chk.text then row.chk.text:SetText("") end
        row.chk:SetScript("OnClick", OnToggle)
        row.name = Label(row, "GameFontHighlight", THEME.text)
        row.name:SetPoint("LEFT", row.chk, "RIGHT", 4, 0)
        row.name:SetPoint("RIGHT", row, "RIGHT", -150, 0)
        row.name:SetWordWrap(false)
        row.status = Label(row, "GameFontHighlightSmall", THEME.mutedText)
        row.status:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.status:SetWidth(140)
        row.status:SetJustifyH("RIGHT")
        row.status:SetWordWrap(false)
        row:SetScript("OnEnter", ShowTooltip)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        PM_ApplyFontSizeToMain(row)
        rows[i] = row
        return row
    end

    RefreshList = function()
        if not AO:IsAvailable() then return end
        local all = AO:List()
        local map, changes, missing, dirty
        if selectedSet and not AO:GetSet(selectedSet) then selectedSet = nil end
        if selectedSet then
            dirty = IsDirty(selectedSet)
            map = drafts[selectedSet] or select(2, AO:GetSet(selectedSet))
            changes, missing = AO:Preview(map)
            listTitle:SetText(dirty and (selectedSet .. "  |cffffd100(unsaved)|r") or selectedSet)
            local msg = (#changes == 0) and "Matches this character's addons."
                or ("Applying this set changes %d addon(s) for this character."):format(#changes)
            if missing > 0 then msg = msg .. (" %d addon(s) in the set aren't installed."):format(missing) end
            if dirty then msg = msg .. " Unsaved changes." end
            SetStatus(msg .. " Use current fills it with this character's addons; Save keeps your edits; Apply puts the set on this character and reloads.")
            loadBtn:Show()
            currentBtn:Show()
        else
            local on = 0
            for _, a in ipairs(all) do if a.enabled then on = on + 1 end end
            listTitle:SetText(("Installed AddOns (%d of %d enabled)"):format(on, #all))
            SetStatus("Checkboxes enable or disable addons for this character. Select a set on the left to edit it.")
            loadBtn:Hide()
            currentBtn:Hide()
        end
        local pending = AO:PendingReloads()
        if selectedSet then
            loadBtn:SetEnabled(dirty)
            reloadBtn:SetEnabled(dirty or #changes > 0 or pending > 0)
            reloadBtn:SetText("Apply")
        else
            reloadBtn:SetEnabled(pending > 0)
            reloadBtn:SetText(pending > 0 and ("Apply (" .. pending .. ")") or "Apply")
        end

        local function IsOn(a)
            if selectedSet then
                local want = map[a.name]
                if want == nil then return a.enabled end
                return want or a.locked
            end
            return a.enabled
        end

        local filter = strtrim(search:GetText() or ""):lower()
        local function Matches(a)
            return filter == "" or a.title:lower():find(filter, 1, true) or a.name:lower():find(filter, 1, true)
        end

        local visible = {}
        for _, root in ipairs(AO:Roots()) do
            local hits = {}
            if filter ~= "" and root.children then
                for _, c in ipairs(root.children) do
                    if Matches(c) then hits[#hits + 1] = c end
                end
            end
            if Matches(root) or #hits > 0 then
                visible[#visible + 1] = root
                if root.children then
                    if expandedGroups[root.name] then
                        for _, c in ipairs(root.children) do visible[#visible + 1] = c end
                    else
                        for _, c in ipairs(hits) do visible[#visible + 1] = c end
                    end
                end
            end
        end

        local n = 0
        for _, a in ipairs(visible) do
            n = n + 1
            local row = GetRow(n)
            row.addonInfo = a
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", listChild, "TOPLEFT", 0, -(n - 1) * ROW_H)
            row:SetPoint("TOPRIGHT", listChild, "TOPRIGHT", 0, -(n - 1) * ROW_H)
            row.bg:SetColorTexture(unpack((n % 2 == 0) and THEME.rowBg or NO_BG))

            row.chk:ClearAllPoints()
            row.chk:SetPoint("LEFT", row, "LEFT", a.parent and 42 or 20, 0)
            if a.children then
                local open = expandedGroups[a.name] or (visible[n + 1] and visible[n + 1].parent == a)
                row.expand:SetNormalTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
                row.expand:Show()
            else
                row.expand:Hide()
            end

            local checked = IsOn(a)
            local statusText, statusColor
            if a.parent and checked and not IsOn(a.parent) then
                statusText, statusColor = "Needs " .. a.parent.title, RED
            elseif selectedSet then
                if map[a.name] == nil then
                    statusText, statusColor = "Not in set", GREY
                elseif checked ~= a.enabled then
                    statusText, statusColor = checked and "Will enable" or "Will disable", GOLD
                else
                    statusText, statusColor = checked and "Enabled" or "Disabled", THEME.mutedText
                end
            else
                statusText, statusColor = LiveStatus(a)
            end
            row.chk:SetChecked(checked)
            row.chk:SetAlpha(a.locked and 0.5 or 1)

            local color = GREY
            if checked then color = (a.loadable or a.lod or a.loaded or selectedSet) and GOLD or RED end
            local label = a.icon .. a.title
            if a.children then
                local on = 0
                for _, c in ipairs(a.children) do if IsOn(c) then on = on + 1 end end
                label = label .. ("  |cff9aa0a6%d/%d|r"):format(on, #a.children)
            end
            row.name:SetText(label)
            row.name:SetTextColor(color[1], color[2], color[3], 1)
            row.status:SetText(statusText)
            row.status:SetTextColor(statusColor[1], statusColor[2], statusColor[3], 1)
            row:Show()
        end
        for i = n + 1, #rows do rows[i]:Hide() end
        listChild:SetWidth(math.max(1, list:GetWidth() or 1))
        listChild:SetHeight(math.max(n * ROW_H, 1))
    end

    local function SelectSet(name)
        selectedSet = (name and AO:GetSet(name)) and name or nil
        RefreshSets()
        RefreshList()
    end

    local function LoadSet(name)
        local ok, changedOrErr = AO:LoadSet(name)
        if not ok then SetStatus(changedOrErr, true) return end
        SelectSet(name)
        if changedOrErr > 0 then
            addon:ShowForceReloadPopup(("Addon set '|cffcfd0ff%s|r' loaded for this character (%d change(s)).\n\nReload now to apply it?"):format(name, changedOrErr))
        else
            SetStatus(("'%s' already matches this character's addons."):format(name))
        end
    end

    local function GetSetRow(i)
        local row = setRows[i]
        if row then return row end
        row = CreateFrame("Button", nil, setChild)
        row:SetHeight(PRESET_ROW_H)
        row:RegisterForClicks("LeftButtonUp")

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row)
        if not pcall(row.bg.SetAtlas, row.bg, "Options_List_Hover", true) then
            row.bg:SetColorTexture(unpack(THEME.rowBg))
        end
        row.hover = row:CreateTexture(nil, "HIGHLIGHT")
        row.hover:SetAllPoints(row)
        if not pcall(row.hover.SetAtlas, row.hover, "Options_List_Hover", true) then
            row.hover:SetColorTexture(unpack(THEME.rowHover))
        end
        row.selBar = row:CreateTexture(nil, "ARTWORK")
        row.selBar:SetAllPoints(row)
        if not pcall(row.selBar.SetAtlas, row.selBar, "Options_List_Active", true) then
            row.selBar:SetColorTexture(unpack(THEME.rowSelected))
        end
        row.selBar:Hide()

        row.nameText = Label(row, "GameFontNormal", THEME.text)
        row.nameText:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.nameText:SetPoint("RIGHT", row, "RIGHT", -62, 0)
        row.nameText:SetWordWrap(false)

        local icons = {
            { "common-icon-checkmark", "Interface\\Buttons\\UI-CheckBox-Check", "Load for this character", LoadSet },
            { "common-icon-pencil", "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Rename", function(name)
                PM_ShowNamePopup("PM_ADDONS_RENAME", ("Rename addon set '%s':"):format(name), name, function(newName)
                    local ok, res = AO:RenameSet(name, newName)
                    if not ok then SetStatus(res, true) return end
                    drafts[res], drafts[name] = drafts[name], nil
                    if selectedSet == name then selectedSet = res end
                    RefreshSets()
                    RefreshList()
                end)
            end },
            { nil, nil, "Delete", function(name)
                PM_ShowConfirm("PM_ADDONS_DELETE", ("Delete addon set '%s'?"):format(name), function()
                    AO:DeleteSet(name)
                    drafts[name] = nil
                    if selectedSet == name then SelectSet(nil) else RefreshSets() end
                end)
            end, true },
        }
        local prev
        for idx = #icons, 1, -1 do
            local d = icons[idx]
            local b = PM_ProfileIcon(row, d[1], d[2], d[3], d[4], d[5])
            if prev then b:SetPoint("RIGHT", prev, "LEFT", -3, 0) else b:SetPoint("RIGHT", row, "RIGHT", 4, 0) end
            prev = b
        end

        row:SetScript("OnClick", function(self)
            SelectSet((selectedSet ~= self.profileName) and self.profileName or nil)
        end)
        row:SetScript("OnDoubleClick", function(self) LoadSet(self.profileName) end)
        row:SetScript("OnEnter", function(self)
            local s, map = AO:GetSet(self.profileName)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.profileName)
            if map then
                local on = 0
                for _, v in pairs(map) do if v then on = on + 1 end end
                GameTooltip:AddLine(("%d addon(s) enabled"):format(on), 1, 1, 1)
            end
            if s and s.savedAt then GameTooltip:AddLine(date("%Y-%m-%d %H:%M", s.savedAt), 0.7, 0.7, 0.74) end
            GameTooltip:AddLine("Click to edit or preview, double-click to load.", 0.7, 0.7, 0.74)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        PM_ApplyFontSizeToMain(row)
        setRows[i] = row
        return row
    end

    RefreshSets = function()
        local names = AO:GetSetNames()
        setChild:SetWidth(math.max(1, (setScroll:GetWidth() or 1) - 8))
        for i, name in ipairs(names) do
            local row = GetSetRow(i)
            row.profileName = name
            row.nameText:SetText(name)
            row.selBar:SetShown(name == selectedSet)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", setChild, "TOPLEFT", 0, -2 - (i - 1) * PRESET_ROW_H)
            row:SetPoint("RIGHT", setChild, "RIGHT", 0, 0)
            row:Show()
        end
        for i = #names + 1, #setRows do setRows[i]:Hide() end
        setChild:SetHeight(math.max(#names * PRESET_ROW_H + 6, 1))
        setEmpty:SetShown(#names == 0)
    end

    local function SaveSet(name)
        name = strtrim(name or "")
        local exists = AO:GetSet(name) ~= nil
        local function DoSave()
            local ok, savedOrErr
            if exists then
                ok, savedOrErr = AO:UpdateSet(name)
            else
                ok, savedOrErr = AO:SaveSet(name)
            end
            if not ok then SetStatus(savedOrErr, true) return end
            drafts[savedOrErr] = nil
            nameBox:SetText("")
            nameBox:ClearFocus()
            SelectSet(savedOrErr)
        end
        if exists then
            PM_ShowConfirm("PM_ADDONS_OVERWRITE", ("Save this character's current addons into '%s'?\n\nAddons that aren't installed here keep their saved state."):format(name), DoSave)
        else
            DoSave()
        end
    end

    saveBtn:SetScript("OnClick", function()
        local name = strtrim(nameBox:GetText() or "")
        if name == "" then name = AO:UniqueSetName(UnitName("player") or "Addons") end
        SaveSet(name)
    end)
    nameBox:SetScript("OnEnterPressed", function() saveBtn:Click() end)

    local function SetAllInDraft(on)
        local d = Draft(selectedSet)
        for _, a in ipairs(AO:List()) do d[a.name] = on or a.locked end
    end
    currentBtn:SetScript("OnClick", function()
        if not selectedSet then return end
        local d = Draft(selectedSet)
        for _, a in ipairs(AO:List()) do d[a.name] = a.enabled or a.locked end
        RefreshList()
    end)
    currentBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Use current")
        GameTooltip:AddLine("Fills this set with the addons enabled on this character. Click Save to keep it.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    currentBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    enableAllBtn:SetScript("OnClick", function()
        if selectedSet then SetAllInDraft(true) else AO:SetAll(true) end
        RefreshList()
    end)
    disableAllBtn:SetScript("OnClick", function()
        if selectedSet then SetAllInDraft(false) else AO:SetAll(false) end
        RefreshList()
    end)
    local function CommitDraft()
        if not (selectedSet and drafts[selectedSet]) then return true end
        local ok, err = AO:SaveSet(selectedSet, drafts[selectedSet])
        if not ok then SetStatus(err, true) return false end
        drafts[selectedSet] = nil
        return true
    end

    loadBtn:SetScript("OnClick", function()
        if not selectedSet or not CommitDraft() then return end
        RefreshSets()
        RefreshList()
        SetStatus(("Saved '%s'. Apply puts it on this character."):format(selectedSet))
    end)
    reloadBtn:SetScript("OnClick", function()
        if selectedSet then
            if not CommitDraft() then return end
            local ok, err = AO:LoadSet(selectedSet)
            if not ok then SetStatus(err, true) return end
        end
        ReloadUI()
    end)

    search:HookScript("OnTextChanged", function() RefreshList() end)
    list:HookScript("OnSizeChanged", function(_, w) listChild:SetWidth(math.max(1, w or 1)) end)
    setScroll:HookScript("OnSizeChanged", function(_, w) setChild:SetWidth(math.max(1, (w or 1) - 8)) end)

    page:SetScript("OnShow", function()
        AO:Invalidate()
        RefreshSets()
        RefreshList()
    end)

    if not AO:IsAvailable() then
        for _, b in ipairs({ saveBtn, enableAllBtn, disableAllBtn, currentBtn, loadBtn, reloadBtn }) do b:Disable() end
        SetStatus("The addon API isn't available on this client.", true)
    end
end

local function PM_BuildGameSettingsPage(f)
    local GS = addon.GameSettings
    local ROW_H = 22

    local page = CreateFrame("Frame", nil, f)
    page:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -38)
    page:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10)
    page:Hide()
    f.settingsPage = page

    local function Label(parent, template, color, text)
        local fs = parent:CreateFontString(nil, "OVERLAY", template)
        fs:SetTextColor(unpack(color))
        fs:SetJustifyH("LEFT")
        fs:SetText(text or "")
        return fs
    end

    local left = CreateFrame("Frame", nil, page)
    left:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
    left:SetWidth(LEFT_PANEL_WIDTH)
    local leftBg = CreatePanel(page, 0)
    leftBg:SetAllPoints(left)
    leftBg:SetFrameLevel(left:GetFrameLevel())
    left:SetFrameLevel(left:GetFrameLevel() + 1)

    local title = Label(left, "GameFontHighlightLarge", THEME.text, "Settings Profiles")
    title:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -10)

    local nameBox = CreateFrame("EditBox", nil, left, "InputBoxTemplate")
    nameBox:SetSize(LEFT_PANEL_WIDTH - 25, 24)
    nameBox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 5, -12)
    nameBox:SetAutoFocus(false)
    nameBox:SetMaxLetters(50)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local nameHint = nameBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    nameHint:SetTextColor(0.62, 0.62, 0.65, 1)
    nameHint:SetPoint("LEFT", nameBox, "LEFT", 0, 0)
    nameHint:SetText("Profile name (optional)")
    nameBox:HookScript("OnTextChanged", function(self) nameHint:SetShown((self:GetText() or "") == "") end)

    local saveBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    saveBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    saveBtn:SetPoint("TOPLEFT", nameBox, "BOTTOMLEFT", -5, -8)
    saveBtn:SetText("Save current settings")

    local importBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    importBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    importBtn:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 0, -8)
    importBtn:SetText("Import settings")

    local sep = left:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(unpack(THEME.divider))
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 0, -8)
    sep:SetPoint("TOPRIGHT", importBtn, "BOTTOMRIGHT", 0, -8)

    local listContainer = CreateFrame("Frame", nil, left)
    listContainer:SetPoint("TOPLEFT", importBtn, "BOTTOMLEFT", 0, -18)
    listContainer:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 10)
    local listPanel = CreatePanel(listContainer, 0)
    listPanel:SetAllPoints(listContainer)

    local profScroll = CreateFrame("ScrollFrame", nil, listContainer, "ScrollFrameTemplate")
    profScroll:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 4, -4)
    profScroll:SetPoint("BOTTOMRIGHT", listContainer, "BOTTOMRIGHT", -24, 4)
    profScroll:EnableMouseWheel(true)
    profScroll:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp((self:GetVerticalScroll() or 0) - delta * PRESET_ROW_H, 0, range))
    end)
    local profChild = CreateFrame("Frame", nil, profScroll)
    profChild:SetSize(1, 1)
    profScroll:SetScrollChild(profChild)

    local profEmpty = Label(listContainer, "GameFontDisable", THEME.mutedText,
        "No settings profiles yet. Save your current game settings or import an export string.")
    profEmpty:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 10, -10)
    profEmpty:SetPoint("RIGHT", listContainer, "RIGHT", -10, 0)
    profEmpty:SetWordWrap(true)

    local vdiv = page:CreateTexture(nil, "ARTWORK")
    vdiv:SetColorTexture(1, 1, 1, 0.06)
    vdiv:SetPoint("TOPLEFT", left, "TOPRIGHT", LEFT_PANEL_GAP / 2, 0)
    vdiv:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", LEFT_PANEL_GAP / 2, 0)
    vdiv:SetWidth(1)

    local right = CreateFrame("Frame", nil, page)
    right:SetPoint("TOPLEFT", left, "TOPRIGHT", LEFT_PANEL_GAP, 0)
    right:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    local rightBg = CreatePanel(page, 0)
    rightBg:SetAllPoints(right)
    rightBg:SetFrameLevel(right:GetFrameLevel())
    right:SetFrameLevel(right:GetFrameLevel() + 1)

    local listTitle = Label(right, "GameFontHighlightLarge", THEME.titleText)
    listTitle:SetPoint("TOPLEFT", right, "TOPLEFT", 12, -12)
    listTitle:SetPoint("RIGHT", right, "RIGHT", -240, 0)
    listTitle:SetWordWrap(false)

    local hint = Label(right, "GameFontDisable", THEME.mutedText)
    hint:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 0, -8)
    hint:SetPoint("RIGHT", right, "RIGHT", -30, 0)
    hint:SetHeight(40)
    hint:SetJustifyV("TOP")
    hint:SetWordWrap(true)

    local function SetStatus(text, isError)
        hint:SetText(text or "")
        if isError then hint:SetTextColor(1, 0.35, 0.35, 1) else hint:SetTextColor(unpack(THEME.mutedText)) end
    end

    local okSearch, search = pcall(CreateFrame, "EditBox", nil, right, "SearchBoxTemplate")
    if not okSearch or not search then
        search = CreateFrame("EditBox", nil, right, "InputBoxTemplate")
    end
    search:SetSize(200, 22)
    search:SetAutoFocus(false)
    search:SetPoint("TOPRIGHT", right, "TOPRIGHT", -30, -16)
    if search.Instructions then search.Instructions:SetText("Search settings...") end

    local loadBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    loadBtn:SetSize(140, 22)
    loadBtn:SetPoint("TOPRIGHT", hint, "BOTTOMRIGHT", 0, -4)
    loadBtn:SetText("Load profile")

    local updateBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    updateBtn:SetSize(140, 22)
    updateBtn:SetPoint("RIGHT", loadBtn, "LEFT", -6, 0)
    updateBtn:SetText("Save profile")

    local list = CreateFrame("ScrollFrame", nil, right, "ScrollFrameTemplate")
    list:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -34)
    list:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -28, 10)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp((self:GetVerticalScroll() or 0) - delta * ROW_H * 3, 0, range))
    end)
    local listChild = CreateFrame("Frame", nil, list)
    listChild:SetSize(1, 1)
    list:SetScrollChild(listChild)

    local rows, profRows = {}, {}
    local NO_BG = { 0, 0, 0, 0 }
    local selectedProfile
    local RefreshList, RefreshProfiles

    local function GetRow(i)
        local row = rows[i]
        if row then return row end
        row = CreateFrame("Frame", nil, listChild)
        row:SetHeight(ROW_H)
        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row)
        row.name = Label(row, "GameFontHighlightSmall", THEME.text)
        row.name:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.name:SetPoint("RIGHT", row, "RIGHT", -176, 0)
        row.name:SetWordWrap(false)
        row.value = Label(row, "GameFontHighlightSmall", THEME.text)
        row.value:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.value:SetWidth(166)
        row.value:SetJustifyH("RIGHT")
        row.value:SetWordWrap(false)
        PM_ApplyFontSizeToMain(row)
        rows[i] = row
        return row
    end

    RefreshList = function()
        if not GS:IsAvailable() then return end
        local all = GS:ReadCurrent()
        local items = {}
        if selectedProfile and not GS:GetProfile(selectedProfile) then selectedProfile = nil end
        if selectedProfile then
            local _, map = GS:GetProfile(selectedProfile)
            local changes, missing, unsupported = GS:Preview(map)
            listTitle:SetText(selectedProfile)
            local msg = (#changes == 0) and "Matches your current settings."
                or ("%d setting(s) will change when you load it."):format(#changes)
            if missing > 0 then
                msg = msg .. (" %d saved setting(s) don't exist in this game and will be skipped."):format(missing)
            end
            if #unsupported > 0 then
                local names = {}
                for i = 1, math.min(3, #unsupported) do
                    local u = unsupported[i]
                    names[i] = ("%s (%s)"):format(u.entry.name, GS:Display(u.entry, u.to))
                end
                msg = msg .. (" %d saved value(s) can't be used in this game and will be skipped: %s%s."):format(
                    #unsupported, table.concat(names, ", "), #unsupported > 3 and ", ..." or "")
            end
            SetStatus(msg)
            loadBtn:SetEnabled(#changes > 0)
            updateBtn:Enable()
            for _, c in ipairs(changes) do
                local e = c.entry
                items[#items + 1] = { e, "|cffff7070" .. GS:Display(e, e.value) .. "|r  ->  |cff70ff70" .. GS:Display(e, c.to) .. "|r" }
            end
        else
            listTitle:SetText(("Current Settings (%d)"):format(#all))
            SetStatus("Every setting from the game's Options window, except the ones that pick hardware (graphics card, monitor, audio devices). Select a profile to see what loading it would change.")
            loadBtn:SetEnabled(false)
            updateBtn:Disable()
            for _, e in ipairs(all) do items[#items + 1] = { e, GS:Display(e, e.value) } end
        end

        local filter = strtrim(search:GetText() or ""):lower()
        local n = 0
        for _, item in ipairs(items) do
            local e = item[1]
            if filter == "" or e.name:lower():find(filter, 1, true) or e.category:lower():find(filter, 1, true)
                or e.var:lower():find(filter, 1, true) then
                n = n + 1
                local row = GetRow(n)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", listChild, "TOPLEFT", 0, -(n - 1) * ROW_H)
                row:SetPoint("TOPRIGHT", listChild, "TOPRIGHT", 0, -(n - 1) * ROW_H)
                row.bg:SetColorTexture(unpack((n % 2 == 0) and THEME.rowBg or NO_BG))
                row.name:SetText(("|cff9aa0a6%s  >|r  %s"):format(e.category, e.name))
                row.value:SetText(item[2])
                row:Show()
            end
        end
        for i = n + 1, #rows do rows[i]:Hide() end
        listChild:SetWidth(math.max(1, list:GetWidth() or 1))
        listChild:SetHeight(math.max(n * ROW_H, 1))
    end

    local function SelectProfile(name)
        selectedProfile = (name and GS:GetProfile(name)) and name or nil
        RefreshProfiles()
        RefreshList()
    end

    local function LoadProfile(name)
        local ok, appliedOrErr, failed, needsRestart, failedNames, untouched = GS:LoadProfile(name)
        if not ok then SetStatus(appliedOrErr, true) return end
        SelectProfile(name)
        local msg = ("Loaded '%s': %d setting(s) changed."):format(name, appliedOrErr)
        if failed and failed > 0 then
            msg = msg .. (" %d couldn't be set: %s."):format(failed, table.concat(failedNames or {}, ", "))
        end
        if untouched and untouched > 0 then
            msg = msg .. (" %d setting(s) aren't in this profile and kept their values."):format(untouched)
        end
        if needsRestart then msg = msg .. " Some of them take effect after you restart the game." end
        SetStatus(msg)
    end

    local function SaveProfile(name, map, doneMsg, meta, keepName)
        name = strtrim(name or "")
        local exists = GS:GetProfile(name) ~= nil
        local function DoSave()
            local ok, savedOrErr
            if exists and not map then
                ok, savedOrErr = GS:UpdateProfile(name)
            else
                ok, savedOrErr = GS:SaveProfile(name, map, meta)
            end
            if not ok then SetStatus(savedOrErr, true) return end
            if not keepName then
                nameBox:SetText("")
                nameBox:ClearFocus()
            end
            SelectProfile(savedOrErr)
            if doneMsg then SetStatus(doneMsg:format(savedOrErr) .. " " .. hint:GetText()) end
        end
        if exists and map then
            PM_ShowConfirm("PM_GAMESETTINGS_OVERWRITE", ("Overwrite settings profile '%s'?"):format(name), DoSave)
        elseif exists then
            PM_ShowConfirm("PM_GAMESETTINGS_OVERWRITE", ("Save your current settings into '%s'?\n\nSettings this game doesn't have keep their saved values."):format(name), DoSave)
        else
            DoSave()
        end
    end

    local exportProvider = {
        ExportProfile = function(_, name) return GS:ExportProfile(name) end,
    }

    local function GetProfileRow(i)
        local row = profRows[i]
        if row then return row end
        row = CreateFrame("Button", nil, profChild)
        row:SetHeight(PRESET_ROW_H)
        row:RegisterForClicks("LeftButtonUp")

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row)
        if not pcall(row.bg.SetAtlas, row.bg, "Options_List_Hover", true) then
            row.bg:SetColorTexture(unpack(THEME.rowBg))
        end
        row.hover = row:CreateTexture(nil, "HIGHLIGHT")
        row.hover:SetAllPoints(row)
        if not pcall(row.hover.SetAtlas, row.hover, "Options_List_Hover", true) then
            row.hover:SetColorTexture(unpack(THEME.rowHover))
        end
        row.selBar = row:CreateTexture(nil, "ARTWORK")
        row.selBar:SetAllPoints(row)
        if not pcall(row.selBar.SetAtlas, row.selBar, "Options_List_Active", true) then
            row.selBar:SetColorTexture(unpack(THEME.rowSelected))
        end
        row.selBar:Hide()

        row.nameText = Label(row, "GameFontNormal", THEME.text)
        row.nameText:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.nameText:SetPoint("RIGHT", row, "RIGHT", -80, 0)
        row.nameText:SetWordWrap(false)

        local icons = {
            { "common-icon-checkmark", "Interface\\Buttons\\UI-CheckBox-Check", "Load settings", LoadProfile },
            { "common-icon-pencil", "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Rename", function(name)
                PM_ShowNamePopup("PM_GAMESETTINGS_RENAME", ("Rename settings profile '%s':"):format(name), name, function(newName)
                    local ok, res = GS:RenameProfile(name, newName)
                    if not ok then SetStatus(res, true) return end
                    if selectedProfile == name then selectedProfile = res end
                    RefreshProfiles()
                    RefreshList()
                end)
            end },
            { "common-icon-forwardarrow", "Interface\\Buttons\\UI-GuildButton-MOTD-Up", "Export", function(name)
                addon:ShowExportPopup(exportProvider, name)
            end },
            { nil, nil, "Delete", function(name)
                PM_ShowConfirm("PM_GAMESETTINGS_DELETE", ("Delete settings profile '%s'?"):format(name), function()
                    GS:DeleteProfile(name)
                    if selectedProfile == name then SelectProfile(nil) else RefreshProfiles() end
                end)
            end, true },
        }
        local prev
        for idx = #icons, 1, -1 do
            local d = icons[idx]
            local b = PM_ProfileIcon(row, d[1], d[2], d[3], d[4], d[5])
            if prev then b:SetPoint("RIGHT", prev, "LEFT", -3, 0) else b:SetPoint("RIGHT", row, "RIGHT", 4, 0) end
            prev = b
        end

        row:SetScript("OnClick", function(self)
            SelectProfile((selectedProfile ~= self.profileName) and self.profileName or nil)
        end)
        row:SetScript("OnDoubleClick", function(self) LoadProfile(self.profileName) end)
        row:SetScript("OnEnter", function(self)
            local p, map = GS:GetProfile(self.profileName)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.profileName)
            if map then
                local count = 0
                for _ in pairs(map) do count = count + 1 end
                GameTooltip:AddLine(("%d settings"):format(count), 1, 1, 1)
            end
            if p and p.savedAt then GameTooltip:AddLine(date("%Y-%m-%d %H:%M", p.savedAt), 0.7, 0.7, 0.74) end
            GameTooltip:AddLine("Click to preview, double-click to load.", 0.7, 0.7, 0.74)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        PM_ApplyFontSizeToMain(row)
        profRows[i] = row
        return row
    end

    RefreshProfiles = function()
        local names = GS:GetProfileNames()
        profChild:SetWidth(math.max(1, (profScroll:GetWidth() or 1) - 8))
        for i, name in ipairs(names) do
            local row = GetProfileRow(i)
            row.profileName = name
            row.nameText:SetText(name)
            row.selBar:SetShown(name == selectedProfile)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", profChild, "TOPLEFT", 0, -2 - (i - 1) * PRESET_ROW_H)
            row:SetPoint("RIGHT", profChild, "RIGHT", 0, 0)
            row:Show()
        end
        for i = #names + 1, #profRows do profRows[i]:Hide() end
        profChild:SetHeight(math.max(#names * PRESET_ROW_H + 6, 1))
        profEmpty:SetShown(#names == 0)
    end

    saveBtn:SetScript("OnClick", function()
        local name = strtrim(nameBox:GetText() or "")
        if name == "" then name = GS:UniqueProfileName(UnitName("player") or "Settings") end
        SaveProfile(name, nil, "Saved your current settings as '%s'.")
    end)
    nameBox:SetScript("OnEnterPressed", function() saveBtn:Click() end)

    updateBtn:SetScript("OnClick", function()
        if selectedProfile then SaveProfile(selectedProfile, nil, "Saved your current settings into '%s'.", nil, true) end
    end)
    updateBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Save profile")
        GameTooltip:AddLine("Saves your current game settings into the selected profile.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    updateBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    importBtn:SetScript("OnClick", function()
        if not GS:IsAvailable() then return end
        PM_ShowNamePopup("PM_GAMESETTINGS_IMPORT", "Paste a game settings export string:", "", function(text)
            local map, profNameOrErr, meta = GS:Decode(text)
            if not map then SetStatus(profNameOrErr, true) return end
            local base = strtrim(nameBox:GetText() or "")
            if base == "" then base = profNameOrErr or "Imported" end
            SaveProfile(GS:UniqueProfileName(base), map, "Imported as '%s'.", meta)
        end, 0)
    end)

    loadBtn:SetScript("OnClick", function()
        if selectedProfile then LoadProfile(selectedProfile) end
    end)

    search:HookScript("OnTextChanged", function() RefreshList() end)
    list:HookScript("OnSizeChanged", function(_, w) listChild:SetWidth(math.max(1, w or 1)) end)
    profScroll:HookScript("OnSizeChanged", function(_, w) profChild:SetWidth(math.max(1, (w or 1) - 8)) end)

    page:SetScript("OnShow", function()
        GS:Invalidate()
        RefreshProfiles()
        RefreshList()
    end)

    if not GS:IsAvailable() then
        for _, b in ipairs({ saveBtn, importBtn, loadBtn, updateBtn }) do b:Disable() end
        SetStatus("The game's settings aren't available yet. Close and reopen this tab once you're in the world.", true)
    end
end

function addon:CreateMainUI()
    if self.MainUI then return end

    local f = CreateFrame("Frame", "ProfileManagerMainUI", UIParent, "BackdropTemplate")
    f:SetSize(MAIN_W, MAIN_H)
    f:SetPoint("CENTER", f:GetParent(), "CENTER")
    f:Hide()

    f.Bg = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    f.Bg:SetColorTexture(0.08, 0.08, 0.09, 0.98)

    PM_ApplyBlizzardOptionsSkin(f)

    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(1000)

    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    if f.SetResizable then
        f:SetResizable(true)
    end
    if f.SetResizeBounds then
        f:SetResizeBounds(MIN_W, MIN_H)
    end

    local resizePending = 0
    f:SetScript("OnSizeChanged", function(self)
        if self._pmSizing then return end
        resizePending = (resizePending or 0) + 1
        local token = resizePending
        Delay(0.2, function()
            if token ~= resizePending then return end
            if addon.MainUI and addon.MainUI:IsShown() and not addon.MainUI._pmSizing then
                addon:RefreshMainUI()
                if addon.MainUI.selectedPresetName then
                    addon:OpenInlineEditor(addon.MainUI.selectedPresetName)
                end
            end
        end)
    end)

    local sizer = CreateFrame("Button", nil, f)
    sizer:SetSize(16, 16)
    sizer:SetPoint("BOTTOMRIGHT", sizer:GetParent(), "BOTTOMRIGHT", -6, 6)
    sizer:EnableMouse(true)
    sizer:SetFrameLevel(f:GetFrameLevel() + 100)
    sizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    sizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    sizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local function StopSizing(self)
        if not self._pmSizing then return end
        self:SetScript("OnUpdate", nil)
        self._pmSizing = nil
        f._pmSizing = nil
        Delay(0, function()
            if not (addon.MainUI and addon.MainUI:IsShown()) then return end
            PM_ReanchorTree(f)
            addon:RefreshMainUI()
            if addon.MainUI.selectedPresetName then
                addon:OpenInlineEditor(addon.MainUI.selectedPresetName)
            end
            if f._pmRefreshCharList and f.optionsPage:IsShown() then f._pmRefreshCharList() end
        end)
    end

    sizer:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local left, top = f:GetLeft(), f:GetTop()
        if not (left and top) then return end
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)

        local scale = f:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        f._pmSizing = true
        self._pmSizing = {
            x = cx / scale, y = cy / scale,
            w = f:GetWidth(), h = f:GetHeight(),
            maxW = (GetScreenWidth() * UIParent:GetEffectiveScale()) / scale - left,
            maxH = top,
        }
        self:SetScript("OnUpdate", function(btn)
            local st = btn._pmSizing
            if not st or not IsMouseButtonDown("LeftButton") then
                StopSizing(btn)
                return
            end
            local x, y = GetCursorPosition()
            x, y = x / scale, y / scale
            local w = Clamp(st.w + (x - st.x), MIN_W, math.max(MIN_W, st.maxW))
            local h = Clamp(st.h + (st.y - y), MIN_H, math.max(MIN_H, st.maxH))
            if math.abs(w - f:GetWidth()) >= 0.5 or math.abs(h - f:GetHeight()) >= 0.5 then
                f:SetSize(w, h)
            end
        end)
    end)
    sizer:SetScript("OnMouseUp", function(self)
        StopSizing(self)
    end)

    UISpecialFrames_Add("ProfileManagerMainUI")

    local ver = PM_GetAddonVersion()
    local title = ver and ver ~= "" and ("Profile Manager |cff9aa0a6v" .. ver .. "|r") or "Profile Manager"

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -3)
    f.title:SetTextColor(unpack(THEME.titleText))
    f.title:SetDrawLayer("OVERLAY", 7)
    f.title:SetText(title)

    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonDefaultAnchors")
    f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 20)

    local function MakeSlider(parent, sliderName, settingsKey, caption, minVal, maxVal, step, initVal, formatFn, onChanged)
        local w = CreateFrame("Frame", nil, parent)
        w:SetHeight(38)

        local lbl = w:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", w, "TOPLEFT", 0, -2)
        lbl:SetTextColor(unpack(THEME.mutedText))
        lbl:SetText(caption)

        local valLbl = w:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valLbl:SetPoint("TOPRIGHT", w, "TOPRIGHT", 0, -2)
        valLbl:SetTextColor(unpack(THEME.text))
        valLbl:SetJustifyH("RIGHT")
        valLbl:SetText(formatFn(initVal))

        local slider, inner
        local ok = pcall(function()
            slider = CreateFrame("Slider", sliderName, w, "MinimalSliderWithSteppersTemplate")
            inner  = slider.Slider or slider
        end)

        if not ok or not slider then
            slider = CreateFrame("Slider", sliderName, w)
            local track = slider:CreateTexture(nil, "BACKGROUND")
            track:SetPoint("TOPLEFT",     slider, "TOPLEFT",      2, -5)
            track:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", -2,  5)
            track:SetColorTexture(0.06, 0.06, 0.08, 1)
            local edge = slider:CreateTexture(nil, "BORDER")
            edge:SetPoint("TOPLEFT",     slider, "TOPLEFT",      2, -5)
            edge:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", -2,  5)
            edge:SetColorTexture(1, 1, 1, 0.12)
            local thumb = slider:CreateTexture(nil, "OVERLAY")
            thumb:SetSize(14, 14)
            thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
            slider:SetThumbTexture(thumb)
            inner = slider
        end

        slider:SetPoint("BOTTOMLEFT",  w, "BOTTOMLEFT",  0, 4)
        slider:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 0, 4)
        slider:SetHeight(16)

        inner:SetMinMaxValues(minVal, maxVal)
        inner:SetValue(initVal)
        inner:SetValueStep(step)
        if inner.SetObeyStepOnDrag then inner:SetObeyStepOnDrag(true) end

        local committedVal = initVal

        local function applyVal(val)
            val = math.floor(val / step + 0.5) * step
            committedVal = val
            PM_SetSetting(settingsKey, val)
            if onChanged then onChanged(val) end
        end

        inner:SetScript("OnValueChanged", function(_, val)
            val = math.floor(val / step + 0.5) * step
            valLbl:SetText(formatFn(val))
            if val ~= committedVal and not w._pmApplyPending then
                w._pmApplyPending = true
                Delay(0.05, function()
                    w._pmApplyPending = false
                    applyVal(inner:GetValue())
                end)
            end
        end)

        w:EnableMouseWheel(true)
        w:SetScript("OnMouseWheel", function(_, delta)
            local cur = math.floor(inner:GetValue() / step + 0.5) * step
            local new = math.max(minVal, math.min(maxVal, cur + delta * step))
            inner:SetValue(new)
            applyVal(new)
        end)

        w.slider   = inner
        w.valLabel = valLbl
        return w
    end

    local TAB_W = 100

    local function MakeTabButton(label)
        local btn
        local okTab = pcall(function()
            btn = CreateFrame("Button", nil, f, "PanelTabButtonTemplate")
        end)
        if okTab and btn then
            btn._pmNative = true
            btn:SetText(label)
            if PanelTemplates_TabResize then PanelTemplates_TabResize(btn, 15) end
            return btn
        end

        btn = CreateFrame("Button", nil, f)
        btn:SetSize(TAB_W, 30)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bg:GetParent())
        bg:SetColorTexture(0, 0, 0, 0)
        btn._tabBg = bg

        local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        txt:SetPoint("CENTER", btn, "CENTER", 0, 0)
        txt:SetText(label)
        btn._tabTxt = txt

        local bar = btn:CreateTexture(nil, "ARTWORK")
        bar:SetHeight(2)
        bar:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  4, 0)
        bar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 0)
        bar:SetColorTexture(1.00, 0.82, 0.00, 0.90)
        bar:Hide()
        btn._tabBar = bar

        return btn
    end

    f.tabDashboard = MakeTabButton("Dashboard")
    f.tabMain      = MakeTabButton("Presets")
    f.tabKeybinds  = MakeTabButton("Keybinds")
    f.tabAddons    = MakeTabButton("Addons")
    f.tabSettings  = MakeTabButton("Game Settings")
    f.tabOptions   = MakeTabButton("Options")

    local function PM_LayoutTabs()
        local x = 8
        for _, tab in ipairs({ f.tabDashboard, f.tabMain, f.tabKeybinds, f.tabAddons, f.tabSettings, f.tabOptions }) do
            if tab then
                local sc = tab:GetScale() or 1
                tab:ClearAllPoints()

                tab:SetPoint("TOPLEFT", f, "BOTTOMLEFT", x / sc, 1 / sc)

                tab:SetFrameLevel(math.max(0, (f:GetFrameLevel() or 1) - 1))
                x = x + ((tab:GetWidth() or TAB_W) * sc) + 4
            end
        end
    end
    PM_LayoutTabs()
    f._pmLayoutTabs = PM_LayoutTabs
    f:HookScript("OnShow", function()
        Delay(0, PM_LayoutTabs)
    end)

    local function SetTabActive(tab, active)
        if tab._pmNative then
            if active then
                if PanelTemplates_SelectTab then PanelTemplates_SelectTab(tab) end
            else
                if PanelTemplates_DeselectTab then PanelTemplates_DeselectTab(tab) end
            end
            return
        end
        if active then
            tab._tabTxt:SetTextColor(unpack(THEME.titleText))
            tab._tabBg:SetColorTexture(1.00, 0.82, 0.00, 0.06)
            tab._tabBar:Show()
        else
            tab._tabTxt:SetTextColor(unpack(THEME.mutedText))
            tab._tabBg:SetColorTexture(0, 0, 0, 0)
            tab._tabBar:Hide()
        end
    end

    local TAB_ORDER = { "dashboard", "presets", "keybinds", "addons", "settings", "options" }
    local TAB_BUTTONS = {
        dashboard = f.tabDashboard, presets = f.tabMain, keybinds = f.tabKeybinds,
        addons = f.tabAddons, settings = f.tabSettings, options = f.tabOptions,
    }
    local function PagesFor(key)
        if key == "presets" then return { f.leftPanel, f.leftPanelBg, f.vertDivider, f.editorContainer } end
        if key == "dashboard" then return { f.dashPage } end
        if key == "keybinds" then return { f.keysPage } end
        if key == "addons" then return { f.addonsPage } end
        if key == "settings" then return { f.settingsPage } end
        if key == "options" then return { f.optionsPage } end
        return {}
    end

    local function SwitchTo(key)
        for _, k in ipairs(TAB_ORDER) do
            SetTabActive(TAB_BUTTONS[k], k == key)
            if k ~= key then
                for _, page in ipairs(PagesFor(k)) do page:Hide() end
            end
        end
        for _, page in ipairs(PagesFor(key)) do page:Show() end
        PM_LayoutTabs()
        if key == "dashboard" and addon.BuildDashboardRows then addon:BuildDashboardRows() end
    end

    for _, k in ipairs(TAB_ORDER) do
        TAB_BUTTONS[k]:SetScript("OnClick", function() SwitchTo(k) end)
        SetTabActive(TAB_BUTTONS[k], k == "dashboard")
    end
    f._pmSwitchDashboard = function() SwitchTo("dashboard") end
    f._pmSwitchTo = SwitchTo

    f.leftPanel = CreateFrame("Frame", nil, f)
    f.leftPanel:SetPoint("TOPLEFT", f.leftPanel:GetParent(), "TOPLEFT", 10, -38)
    f.leftPanel:SetPoint("BOTTOMLEFT", f.leftPanel:GetParent(), "BOTTOMLEFT", 10, 10)
    f.leftPanel:SetWidth(LEFT_PANEL_WIDTH)

    f.leftPanelBg = CreatePanel(f, 0)
    f.leftPanelBg:SetPoint("TOPLEFT",     f.leftPanel, "TOPLEFT",     0, 0)
    f.leftPanelBg:SetPoint("BOTTOMRIGHT", f.leftPanel, "BOTTOMRIGHT", 0, 0)
    f.leftPanelBg:SetFrameLevel(f:GetFrameLevel() + 1)
    f.leftPanel:SetFrameLevel(f:GetFrameLevel() + 2)

    f.topTitle = f.leftPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.topTitle:SetPoint("TOPLEFT", f.topTitle:GetParent(), "TOPLEFT", 10, -10)
    f.topTitle:SetTextColor(unpack(THEME.text))
    f.topTitle:SetText("Add Presets")

    f.addBox = CreateFrame("EditBox", nil, f.leftPanel, "InputBoxTemplate")
    f.addBox:SetSize(LEFT_PANEL_WIDTH - 25, 24)
    f.addBox:SetPoint("TOPLEFT", f.topTitle, "BOTTOMLEFT", 5, -12)
    f.addBox:SetAutoFocus(false)
    f.addBox:SetMaxLetters(50)
    f.addBox:SetScript("OnEscapePressed", function()
        f.addBox:ClearFocus()
        if f and f.Hide then f:Hide() end
    end)

    local PLACEHOLDER_TEXT = "Preset name (optional)"
    local PLACEHOLDER_COLOR = { 0.62, 0.62, 0.65, 1.00 }
    local NORMAL_COLOR = { 1, 1, 1, 1 }

    local function AddBox_ShowPlaceholder()
        f.addBox:SetText(PLACEHOLDER_TEXT)
        f.addBox:SetTextColor(unpack(PLACEHOLDER_COLOR))
    end

    local function AddBox_ClearPlaceholder()
        local txt = f.addBox:GetText() or ""
        if txt == PLACEHOLDER_TEXT then
            f.addBox:SetText("")
        end
        f.addBox:SetTextColor(unpack(NORMAL_COLOR))
    end

    local function AddBox_GetRealText()
        local txt = f.addBox:GetText() or ""
        if txt == PLACEHOLDER_TEXT then return "" end
        return txt
    end

    AddBox_ShowPlaceholder()

    f.addBox:SetScript("OnEditFocusGained", function()
        AddBox_ClearPlaceholder()
    end)

    f.addBox:SetScript("OnEditFocusLost", function()
        local txt = strtrim(f.addBox:GetText() or "")
        if txt == "" then
            AddBox_ShowPlaceholder()
        end
    end)

    f.addBtn = CreateFrame("Button", nil, f.leftPanel, "UIPanelButtonTemplate")
    f.addBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    f.addBtn:SetPoint("TOPLEFT", f.addBox, "BOTTOMLEFT", -5, -8)
    f.addBtn:SetText("Add new profile")

    f.importPresetBtn = CreateFrame("Button", nil, f.leftPanel, "UIPanelButtonTemplate")
    f.importPresetBtn:SetSize(LEFT_PANEL_WIDTH - 20, 22)
    f.importPresetBtn:SetPoint("TOPLEFT", f.addBtn, "BOTTOMLEFT", 0, -8)
    f.importPresetBtn:SetText("Import preset")
    f.importPresetBtn:SetScript("OnClick", function()
        if addon.ShowPresetImportWizard then
            addon:ShowPresetImportWizard()
        else
            print("|cffff5555ProfileManager|r Import wizard not available (missing UI parts).")
        end
    end)

    local sep = f.leftPanel:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(unpack(THEME.divider))
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", f.importPresetBtn, "BOTTOMLEFT", 0, -8)
    sep:SetPoint("TOPRIGHT", f.importPresetBtn, "BOTTOMRIGHT", 0, -8)
    f.leftSep = sep

    f.listContainer = CreateFrame("Frame", nil, f.leftPanel)
    f.listContainer:ClearAllPoints()
    f.listContainer:SetPoint("TOPLEFT", f.importPresetBtn, "BOTTOMLEFT", 0, -18)
    f.listContainer:SetPoint("BOTTOMRIGHT", f.listContainer:GetParent(), "BOTTOMRIGHT", -10, 10)

    f.listPanel = CreatePanel(f.listContainer, 0)
    f.listPanel:SetAllPoints(f.listPanel:GetParent())

    f.scrollFrame = CreateFrame("ScrollFrame", nil, f.listContainer, "ScrollFrameTemplate")
    f.scrollFrame:EnableMouseWheel(true)
    f.scrollFrame.scrollStep = PRESET_ROW_H
    f.scrollFrame:EnableMouseWheel(true)
    f.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local step  = PRESET_ROW_H
        local cur   = self:GetVerticalScroll() or 0
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp(cur - delta * step, 0, range))
    end)

    f.scrollFrame:SetPoint("TOPLEFT", f.scrollFrame:GetParent(), "TOPLEFT", 4, -4)
    f.scrollFrame:SetPoint("BOTTOMRIGHT", f.scrollFrame:GetParent(), "BOTTOMRIGHT", -24, 4)

    f.scrollChild = CreateFrame("Frame", nil, f.scrollFrame)
    f.scrollChild:SetSize(1, 1)
    f.scrollFrame:SetScrollChild(f.scrollChild)

    f.presetRows = {}
    f.selectedPresetName = nil

    f.vertDivider = f:CreateTexture(nil, "ARTWORK")
    f.vertDivider:SetColorTexture(1, 1, 1, 0.06)
    f.vertDivider:SetPoint("TOPLEFT", f.leftPanel, "TOPRIGHT", LEFT_PANEL_GAP / 2, 0)
    f.vertDivider:SetPoint("BOTTOMLEFT", f.leftPanel, "BOTTOMRIGHT", LEFT_PANEL_GAP / 2, 0)
    f.vertDivider:SetWidth(1)

    f.editorContainer = CreateFrame("Frame", nil, f)
    f.editorContainer:SetPoint("TOPLEFT", f.editorContainer:GetParent(), "TOPLEFT", 10 + LEFT_PANEL_WIDTH + LEFT_PANEL_GAP, -38)
    f.editorContainer:SetPoint("BOTTOMRIGHT", f.editorContainer:GetParent(), "BOTTOMRIGHT", -10, 10)

    f.optionsPage = CreateFrame("Frame", nil, f)
    f.optionsPage:SetPoint("TOPLEFT", f.optionsPage:GetParent(), "TOPLEFT", 10, -38)
    f.optionsPage:SetPoint("BOTTOMRIGHT", f.optionsPage:GetParent(), "BOTTOMRIGHT", -10, 10)
    f.optionsPage:Hide()

    PM_BuildKeybindsPage(f)
    PM_BuildAddonsPage(f)
    PM_BuildGameSettingsPage(f)

    f.dashPage = CreateFrame("Frame", nil, f)
    f.dashPage:SetPoint("TOPLEFT", f.dashPage:GetParent(), "TOPLEFT", 10, -38)
    f.dashPage:SetPoint("BOTTOMRIGHT", f.dashPage:GetParent(), "BOTTOMRIGHT", -10, 10)
    f.dashPage:Hide()

    f.dashPanel = CreatePanel(f.dashPage, 0)
    f.dashPanel:SetAllPoints(f.dashPanel:GetParent())
    f.dashPanel.bg:SetColorTexture(0.03, 0.03, 0.04, 0.55)
    f.dashPanel.border:SetBackdropBorderColor(1, 1, 1, 0.06)

    f.dashTitle = f.dashPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.dashTitle:SetPoint("TOPLEFT", f.dashTitle:GetParent(), "TOPLEFT", 12, -14)
    f.dashTitle:SetTextColor(unpack(THEME.text))
    f.dashTitle:SetText("Current Setup")

    f.dashHint = f.dashPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.dashHint:SetPoint("TOPLEFT", f.dashTitle, "BOTTOMLEFT", 0, -6)
    f.dashHint:SetTextColor(unpack(THEME.mutedText))
    f.dashHint:SetText("")

    local okDashSearch, dashSearch = pcall(CreateFrame, "EditBox", nil, f.dashPage, "SearchBoxTemplate")
    if not okDashSearch or not dashSearch then
        dashSearch = CreateFrame("EditBox", nil, f.dashPage, "InputBoxTemplate")
    end
    f.dashSearch = dashSearch
    f.dashSearch:SetSize(220, 22)
    f.dashSearch:SetPoint("TOPRIGHT", f.dashSearch:GetParent(), "TOPRIGHT", -30, -16)
    f.dashSearch:SetAutoFocus(false)
    f.dashSearch:HookScript("OnTextChanged", function()
        if addon.ApplyDashboardSearchFilter then addon:ApplyDashboardSearchFilter() end
    end)

    local CARD_H, CARD_TOP = 64, -58
    local CARD_EDGE = { 1.00, 0.82, 0.00, 1 }
    local CARD_EDGE_HOVER = { 1.00, 0.93, 0.55, 1 }
    local CARD_BACKDROP = {
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    }
    local function MakeDashCard(tab, caption, tip)
        local c = CreateFrame("Button", nil, f.dashPage)
        c:SetHeight(CARD_H)
        local panel = CreateFrame("Frame", nil, c, "BackdropTemplate")
        panel:SetAllPoints(c)
        panel:SetBackdrop(CARD_BACKDROP)
        panel:SetBackdropColor(0.06, 0.06, 0.08, 0.92)
        panel:SetBackdropBorderColor(unpack(CARD_EDGE))
        c.panel = panel

        c.caption = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        c.caption:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -10)
        c.caption:SetTextColor(unpack(THEME.mutedText))
        c.caption:SetText(caption)

        c.arrow = panel:CreateTexture(nil, "ARTWORK")
        c.arrow:SetSize(14, 14)
        c.arrow:SetPoint("RIGHT", panel, "RIGHT", -12, 0)
        if not pcall(c.arrow.SetAtlas, c.arrow, "common-icon-forwardarrow") then
            c.arrow:SetTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
        end
        c.arrow:SetAlpha(0.5)

        c.value = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        c.value:SetPoint("TOPLEFT", c.caption, "BOTTOMLEFT", 0, -4)
        c.value:SetPoint("RIGHT", c.arrow, "LEFT", -8, 0)
        c.value:SetJustifyH("LEFT")
        c.value:SetWordWrap(false)
        c.value:SetTextColor(1.00, 0.82, 0.40, 1)

        c.detail = panel:CreateFontString(nil, "OVERLAY", "GameFontDisable")
        c.detail:SetPoint("TOPLEFT", c.value, "BOTTOMLEFT", 0, -4)
        c.detail:SetPoint("RIGHT", c.arrow, "LEFT", -8, 0)
        c.detail:SetJustifyH("LEFT")
        c.detail:SetWordWrap(false)
        c.detail:SetTextColor(unpack(THEME.mutedText))

        c:SetScript("OnClick", function() if f._pmSwitchTo then f._pmSwitchTo(tab) end end)
        c:SetScript("OnEnter", function(self)
            panel:SetBackdropBorderColor(unpack(CARD_EDGE_HOVER))
            c.arrow:SetAlpha(1)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(caption)
            GameTooltip:AddLine(tip, 1, 1, 1, true)
            GameTooltip:AddLine("Click to open the tab.", 0.7, 0.7, 0.74)
            GameTooltip:Show()
        end)
        c:SetScript("OnLeave", function()
            panel:SetBackdropBorderColor(unpack(CARD_EDGE))
            c.arrow:SetAlpha(0.5)
            GameTooltip:Hide()
        end)
        return c
    end

    f.dashKeysCard = MakeDashCard("keybinds", "GAME KEYBINDS",
        "Your current keybinds, and the saved keybind profile that matches them.")
    f.dashKeysCard:SetPoint("TOPLEFT", f.dashPage, "TOPLEFT", 6, CARD_TOP)
    f.dashKeysCard:SetWidth(300)

    f.dashAddonsCard = MakeDashCard("addons", "ADDON SET",
        "This character's enabled addons, and the saved addon set that matches them.")
    f.dashAddonsCard:SetPoint("TOPLEFT", f.dashKeysCard, "TOPRIGHT", 8, 0)
    f.dashAddonsCard:SetWidth(300)

    f.dashSettingsCard = MakeDashCard("settings", "GAME SETTINGS",
        "Your current game settings, and the saved settings profile that matches them.")
    f.dashSettingsCard:SetPoint("TOPLEFT", f.dashAddonsCard, "TOPRIGHT", 8, 0)
    f.dashSettingsCard:SetPoint("TOPRIGHT", f.dashPage, "TOPRIGHT", -28, CARD_TOP)

    f.dashScroll = CreateFrame("ScrollFrame", nil, f.dashPage, "ScrollFrameTemplate")
    f.dashScroll:SetPoint("TOPLEFT", f.dashScroll:GetParent(), "TOPLEFT", 6, CARD_TOP - CARD_H - 12)
    f.dashScroll:SetPoint("BOTTOMRIGHT", f.dashScroll:GetParent(), "BOTTOMRIGHT", -28, 10)
    f.dashScrollChild = CreateFrame("Frame", nil, f.dashScroll)
    f.dashScrollChild:SetSize(1, 1)
    f.dashScroll:SetScrollChild(f.dashScrollChild)
    f.dashRows = {}

    local OPT_PAD     = 14
    local OPT_ROW_GAP = 20
    local CHAR_ROW_H  = 30
    local OPT_TOP_H   = 136

    local optLeft = CreateFrame("Frame", nil, f.optionsPage)
    optLeft:SetPoint("TOPLEFT", optLeft:GetParent(), "TOPLEFT", 0, 0)
    optLeft:SetPoint("BOTTOMLEFT", optLeft:GetParent(), "BOTTOMLEFT", 0, 0)
    optLeft:SetWidth(LEFT_PANEL_WIDTH)

    local optLeftBg = CreatePanel(f.optionsPage, 0)
    optLeftBg:SetAllPoints(optLeft)
    optLeftBg:SetFrameLevel(optLeft:GetFrameLevel())
    optLeft:SetFrameLevel(optLeft:GetFrameLevel() + 1)

    local RefreshCharList

    f.minimapChk = CreateFrame("CheckButton", nil, optLeft, "UICheckButtonTemplate")
    f.minimapChk:SetSize(26, 26)
    f.minimapChk:SetPoint("TOPLEFT", f.minimapChk:GetParent(), "TOPLEFT", OPT_PAD, -OPT_PAD)
    f.minimapChk:SetChecked(not (ProfileManagerDB.minimap and ProfileManagerDB.minimap.hide))
    if f.minimapChk.text then
        f.minimapChk.text:SetText("Show Minimap icon")
        f.minimapChk.text:SetTextColor(unpack(THEME.text))
    end
    f.minimapChk:SetScript("OnClick", function(self)
        ProfileManagerDB.minimap = ProfileManagerDB.minimap or {}
        ProfileManagerDB.minimap.hide = not self:GetChecked()
        local Icon = LibStub and LibStub("LibDBIcon-1.0", true)
        if Icon then
            if ProfileManagerDB.minimap.hide then
                Icon:Hide("ProfileManager")
            else
                Icon:Show("ProfileManager")
            end
        end
    end)

    f.classColorsChk = CreateFrame("CheckButton", nil, optLeft, "UICheckButtonTemplate")
    f.classColorsChk:SetSize(26, 26)
    f.classColorsChk:SetPoint("TOPLEFT", f.minimapChk, "BOTTOMLEFT", 0, -4)
    f.classColorsChk:SetChecked(ProfileManagerDB.showClassColors == true)
    if f.classColorsChk.text then
        f.classColorsChk.text:SetText("Show class colors")
        f.classColorsChk.text:SetTextColor(unpack(THEME.text))
    end
    f.classColorsChk:SetScript("OnClick", function(self)
        ProfileManagerDB.showClassColors = self:GetChecked()
        if f.optionsPage:IsShown() then RefreshCharList() end
    end)

    f.fontSizeSliderCt = MakeSlider(
        optLeft, "PMFontSizeSlider", "fontDelta", "Font Size",
        -2, 8, 1, PM_ResolveFontDelta(),
        function(v) return string.format("%+d px", v) end,
        function(v) PM_ApplyFontSizeToMain(f) end
    )
    f.fontSizeSliderCt:SetWidth(220)
    f.fontSizeSliderCt:SetPoint("TOPLEFT", optLeft, "TOPLEFT", OPT_PAD, -(OPT_PAD + 26 + 4 + 26 + OPT_ROW_GAP))

    f.scaleSliderCt = MakeSlider(
        optLeft, "PMScaleSlider", "scale", "UI Scale",
        0.75, 1.5, 0.01, PM_GetSetting("scale", 1.0),
        function(v) return string.format("%.0f%%", v * 100) end,
        function(v) PM_ApplyWindowScale(f) end
    )
    f.scaleSliderCt:SetWidth(220)
    f.scaleSliderCt:SetPoint("TOPLEFT", f.fontSizeSliderCt, "BOTTOMLEFT", 0, -OPT_ROW_GAP)

    local function MakeFontDropdown(caption, settingsKey, anchorTo)
        local lbl = optLeft:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -OPT_ROW_GAP)
        lbl:SetTextColor(unpack(THEME.mutedText))
        lbl:SetText(caption)

        local okDD, dd = pcall(CreateFrame, "DropdownButton", nil, optLeft, "WowStyle1DropdownTemplate")
        if not okDD or not dd then return lbl end
        dd._pmModern = true
        dd:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -4)
        PM_SetDropdownWidth(dd, 220)

        local function Current() return PM_GetSetting(settingsKey, nil) end
        if dd.SetDefaultText then
            dd:SetDefaultText(Current() or "Default")
        end
        dd:SetupMenu(function(_, root)
            if root.SetScrollMode then root:SetScrollMode(20 * 20) end
            root:CreateRadio("Default", function() return Current() == nil end, function()
                PM_SetSetting(settingsKey, nil)
                if dd.SetDefaultText then dd:SetDefaultText("Default") end
                PM_ApplyFontSizeToMain(f)
            end)
            for _, name in ipairs(PM_FontList()) do
                root:CreateRadio(name, function() return Current() == name end, function()
                    PM_SetSetting(settingsKey, name)
                    if dd.SetDefaultText then dd:SetDefaultText(name) end
                    PM_ApplyFontSizeToMain(f)
                end)
            end
        end)
        return dd
    end

    f.fontFaceDD = MakeFontDropdown("Font", "fontFace", f.scaleSliderCt)

    local optVertDiv = f.optionsPage:CreateTexture(nil, "ARTWORK")
    optVertDiv:SetColorTexture(1, 1, 1, 0.06)
    optVertDiv:SetPoint("TOPLEFT",    optLeft, "TOPRIGHT",    LEFT_PANEL_GAP / 2, 0)
    optVertDiv:SetPoint("BOTTOMLEFT", optLeft, "BOTTOMRIGHT", LEFT_PANEL_GAP / 2, 0)
    optVertDiv:SetWidth(1)

    local optRight = CreateFrame("Frame", nil, f.optionsPage)
    optRight:SetPoint("TOPLEFT",     optLeft, "TOPRIGHT",    LEFT_PANEL_GAP, 0)
    optRight:SetPoint("BOTTOMRIGHT", optRight:GetParent(), "BOTTOMRIGHT", 0, 0)

    local optRightTop = CreateFrame("Frame", nil, optRight)
    optRightTop:SetPoint("TOPLEFT", optRightTop:GetParent(), "TOPLEFT", 0, 0)
    optRightTop:SetPoint("TOPRIGHT", optRightTop:GetParent(), "TOPRIGHT", 0, 0)
    optRightTop:SetHeight(OPT_TOP_H)

    local optRightTopBg = CreatePanel(optRight, 0)
    optRightTopBg:SetAllPoints(optRightTop)
    optRightTopBg:SetFrameLevel(optRightTop:GetFrameLevel())
    optRightTop:SetFrameLevel(optRightTop:GetFrameLevel() + 1)

    local newCharTitle = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    newCharTitle:SetTextColor(unpack(THEME.titleText))
    newCharTitle:SetText("New Character Default")
    newCharTitle:SetPoint("TOPLEFT", newCharTitle:GetParent(), "TOPLEFT", OPT_PAD, -OPT_PAD)

    local newCharDesc = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    f.newCharDesc = newCharDesc
    newCharDesc:SetTextColor(unpack(THEME.mutedText))
    newCharDesc:SetText("Preset, keybinds, addon set and game settings applied the first time a new character logs in.")
    newCharDesc:SetPoint("TOPLEFT", newCharTitle, "BOTTOMLEFT", 0, -4)

    local function GetPresetItems()
        local items = {"(None)"}
        if addon.GetPresetNames then
            local names = addon:GetPresetNames()
            if type(names) == "table" then
                for _, n in ipairs(names) do
                    table.insert(items, n)
                end
            end
        end
        return items
    end

    local function SetDDText(dd, text)
        PM_ModernDropdownForceText(dd, text)
        if dd.GenerateMenu then dd:GenerateMenu() end
    end

    local function GetKeybindItems()
        local items = {"(None)"}
        if addon.Keybinds then
            for _, n in ipairs(addon.Keybinds:GetProfileNames()) do items[#items + 1] = n end
        end
        return items
    end

    local function GetAddonSetItems()
        local items = {"(None)"}
        if addon.Addons then
            for _, n in ipairs(addon.Addons:GetSetNames()) do items[#items + 1] = n end
        end
        return items
    end

    local function GetSettingsItems()
        local items = {"(None)"}
        if addon.GameSettings then
            for _, n in ipairs(addon.GameSettings:GetProfileNames()) do items[#items + 1] = n end
        end
        return items
    end

    local function OrNone(v)
        return (type(v) == "string" and v ~= "") and v or "(None)"
    end

    local newCharDD
    newCharDD = PM_CreateDeleteDropdown(
        optRightTop, 160,
        GetPresetItems,
        function(selected)
            ProfileManagerDB.newCharDefault = (selected == "(None)") and "" or selected
            SetDDText(newCharDD, selected)
        end,
        function()
            local v = ProfileManagerDB.newCharDefault
            return (type(v) == "string" and v ~= "") and v or "(None)"
        end
    )
    local newCharPresetLbl = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    newCharPresetLbl:SetTextColor(unpack(THEME.mutedText))
    newCharPresetLbl:SetText("Preset")
    newCharPresetLbl:SetPoint("TOPLEFT", newCharDesc, "BOTTOMLEFT", 0, -10)
    newCharDD:SetPoint("TOPLEFT", newCharPresetLbl, "BOTTOMLEFT", 0, -4)
    do
        local v = ProfileManagerDB.newCharDefault
        SetDDText(newCharDD, (type(v) == "string" and v ~= "") and v or "(None)")
    end

    local newCharKeysDD
    newCharKeysDD = PM_CreateDeleteDropdown(
        optRightTop, 160,
        GetKeybindItems,
        function(selected)
            ProfileManagerDB.newCharKeybinds = (selected == "(None)") and "" or selected
            SetDDText(newCharKeysDD, selected)
        end,
        function() return OrNone(ProfileManagerDB.newCharKeybinds) end
    )
    newCharKeysDD:SetPoint("LEFT", newCharDD, "RIGHT", 16, 0)
    local newCharKeysLbl = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    newCharKeysLbl:SetTextColor(unpack(THEME.mutedText))
    newCharKeysLbl:SetText("Keybinds")
    newCharKeysLbl:SetPoint("BOTTOMLEFT", newCharKeysDD, "TOPLEFT", 0, 4)
    SetDDText(newCharKeysDD, OrNone(ProfileManagerDB.newCharKeybinds))

    local newCharAddonsDD
    newCharAddonsDD = PM_CreateDeleteDropdown(
        optRightTop, 160,
        GetAddonSetItems,
        function(selected)
            ProfileManagerDB.newCharAddons = (selected == "(None)") and "" or selected
            SetDDText(newCharAddonsDD, selected)
        end,
        function() return OrNone(ProfileManagerDB.newCharAddons) end
    )
    newCharAddonsDD:SetPoint("LEFT", newCharKeysDD, "RIGHT", 16, 0)
    local newCharAddonsLbl = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    newCharAddonsLbl:SetTextColor(unpack(THEME.mutedText))
    newCharAddonsLbl:SetText("Addons")
    newCharAddonsLbl:SetPoint("BOTTOMLEFT", newCharAddonsDD, "TOPLEFT", 0, 4)
    SetDDText(newCharAddonsDD, OrNone(ProfileManagerDB.newCharAddons))

    local newCharSettingsDD
    newCharSettingsDD = PM_CreateDeleteDropdown(
        optRightTop, 160,
        GetSettingsItems,
        function(selected)
            ProfileManagerDB.newCharSettings = (selected == "(None)") and "" or selected
            SetDDText(newCharSettingsDD, selected)
        end,
        function() return OrNone(ProfileManagerDB.newCharSettings) end
    )
    newCharSettingsDD:SetPoint("LEFT", newCharAddonsDD, "RIGHT", 16, 0)
    local newCharSettingsLbl = optRightTop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    newCharSettingsLbl:SetTextColor(unpack(THEME.mutedText))
    newCharSettingsLbl:SetText("Game Settings")
    newCharSettingsLbl:SetPoint("BOTTOMLEFT", newCharSettingsDD, "TOPLEFT", 0, 4)
    SetDDText(newCharSettingsDD, OrNone(ProfileManagerDB.newCharSettings))

    local function LayoutNewCharRow()
        local w = optRightTop:GetWidth()
        if not w or w < 100 then return end
        local ddW = math.max(90, math.min(160, math.floor((w - OPT_PAD * 2 - 16 * 3) / 4)))
        for _, dd in ipairs({ newCharDD, newCharKeysDD, newCharAddonsDD, newCharSettingsDD }) do
            PM_SetDropdownWidth(dd, ddW)
        end
    end

    local optHorizDiv = optRight:CreateTexture(nil, "ARTWORK")
    optHorizDiv:SetColorTexture(1, 1, 1, 0.06)
    optHorizDiv:SetHeight(1)
    optHorizDiv:SetPoint("TOPLEFT",  optRightTop, "BOTTOMLEFT",  0, -LEFT_PANEL_GAP / 2)
    optHorizDiv:SetPoint("TOPRIGHT", optRightTop, "BOTTOMRIGHT", 0, -LEFT_PANEL_GAP / 2)

    local optRightBot = CreateFrame("Frame", nil, optRight)
    optRightBot:SetPoint("TOPLEFT",     optRightTop, "BOTTOMLEFT",  0, -LEFT_PANEL_GAP)
    optRightBot:SetPoint("BOTTOMRIGHT", optRightBot:GetParent(), "BOTTOMRIGHT", 0, 0)

    local optRightBotBg = CreatePanel(optRight, 0)
    optRightBotBg:SetAllPoints(optRightBot)
    optRightBotBg:SetFrameLevel(optRightBot:GetFrameLevel())
    optRightBot:SetFrameLevel(optRightBot:GetFrameLevel() + 1)

    local charTitle = optRightBot:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    charTitle:SetTextColor(unpack(THEME.titleText))
    charTitle:SetText("Characters")
    charTitle:SetPoint("TOPLEFT", charTitle:GetParent(), "TOPLEFT", OPT_PAD, -OPT_PAD)

    local okCharSearch, charSearch = pcall(CreateFrame, "EditBox", nil, optRightBot, "SearchBoxTemplate")
    if not okCharSearch or not charSearch then
        charSearch = CreateFrame("EditBox", nil, optRightBot, "InputBoxTemplate")
    end
    charSearch:SetSize(180, 22)
    charSearch:SetAutoFocus(false)
    charSearch:SetMaxLetters(50)
    charSearch:SetPoint("TOPRIGHT", charSearch:GetParent(), "TOPRIGHT", -OPT_PAD, -OPT_PAD + 2)
    if charSearch.Instructions then charSearch.Instructions:SetText("Search characters...") end

    local charScrollFrame = CreateFrame("ScrollFrame", nil, optRightBot, "ScrollFrameTemplate")
    charScrollFrame:EnableMouseWheel(true)
    charScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur   = self:GetVerticalScroll() or 0
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp(cur - delta * CHAR_ROW_H, 0, range))
    end)
    charScrollFrame:SetPoint("TOPLEFT", charScrollFrame:GetParent(), "TOPLEFT", OPT_PAD, -(OPT_PAD + 22 + 6 + 16))
    charScrollFrame:SetPoint("BOTTOMRIGHT", charScrollFrame:GetParent(), "BOTTOMRIGHT", -20, OPT_PAD)

    local charScrollChild = CreateFrame("Frame", nil, charScrollFrame)
    charScrollChild:SetSize(1, 1)
    charScrollFrame:SetScrollChild(charScrollChild)

    local charRows = {}

    local function CharHeader(text)
        local h = optRightBot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        h:SetTextColor(unpack(THEME.mutedText))
        h:SetText(text)
        return h
    end
    local hdrChar, hdrPreset, hdrKeys, hdrAddons, hdrSettings, hdrLogin =
        CharHeader("Character"), CharHeader("Preset"), CharHeader("Keybinds"), CharHeader("Addons"),
        CharHeader("Game Settings"), CharHeader("Next login")

    RefreshCharList = function()
        LayoutNewCharRow()
        for _, row in ipairs(charRows) do row:Hide() end
        charRows = {}

        local chars = (ProfileManagerDB and ProfileManagerDB.knownChars) or {}
        local filterTxt = ""
        if not charSearch._pmShowingPlaceholder then
            filterTxt = strtrim(charSearch:GetText() or ""):lower()
        end

        local scrollW = charScrollFrame:GetWidth()
        if not scrollW or scrollW < 10 then
            scrollW = MAIN_W - 20 - LEFT_PANEL_WIDTH - LEFT_PANEL_GAP - OPT_PAD - 20
        end
        charScrollChild:SetWidth(math.max(scrollW, 1))

        local CHAR_NAME_W = math.max(100, math.min(140, math.floor(scrollW * 0.22)))
        local CHAR_CHK_W, CHAR_REMOVE_W, CHAR_GAP = 20, 20, 8
        local CHAR_DD_W   = math.floor((scrollW - 8 - CHAR_NAME_W - CHAR_CHK_W - CHAR_REMOVE_W - CHAR_GAP * 7) / 4)
        CHAR_DD_W = math.max(70, math.min(170, CHAR_DD_W))

        local presetX   = 4 + CHAR_NAME_W + CHAR_GAP
        local keysX     = presetX + CHAR_DD_W + CHAR_GAP
        local addonsX   = keysX + CHAR_DD_W + CHAR_GAP
        local settingsX = addonsX + CHAR_DD_W + CHAR_GAP
        hdrChar:SetPoint("BOTTOMLEFT", charScrollFrame, "TOPLEFT", 4, 4)
        hdrPreset:SetPoint("BOTTOMLEFT", charScrollFrame, "TOPLEFT", presetX, 4)
        hdrKeys:SetPoint("BOTTOMLEFT", charScrollFrame, "TOPLEFT", keysX, 4)
        hdrAddons:SetPoint("BOTTOMLEFT", charScrollFrame, "TOPLEFT", addonsX, 4)
        hdrSettings:SetPoint("BOTTOMLEFT", charScrollFrame, "TOPLEFT", settingsX, 4)
        hdrLogin:SetPoint("BOTTOMRIGHT", charScrollFrame, "TOPLEFT", scrollW - 4 - CHAR_REMOVE_W - CHAR_GAP, 4)
        local currentChar = (UnitName and UnitName("player") or "") .. " - " .. (GetRealmName and GetRealmName() or "")
        local rowIdx      = 0

        for _, charName in ipairs(chars) do
            if filterTxt == "" or charName:lower():find(filterTxt, 1, true) then
                rowIdx = rowIdx + 1
                local row = CreateFrame("Frame", nil, charScrollChild)
                row:SetSize(scrollW, CHAR_ROW_H)
                row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, -(rowIdx - 1) * CHAR_ROW_H)

                if rowIdx % 2 == 0 then
                    local rowBg = row:CreateTexture(nil, "BACKGROUND")
                    rowBg:SetAllPoints(rowBg:GetParent())
                    rowBg:SetColorTexture(1, 1, 1, 0.03)
                end

                local nameLbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                local classFile = ProfileManagerDB.charClasses and ProfileManagerDB.charClasses[charName]
                if ProfileManagerDB.showClassColors and classFile then
                    local c = (C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classFile))
                           or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile])
                    if c then
                        nameLbl:SetTextColor(c.r, c.g, c.b, 1)
                    else
                        nameLbl:SetTextColor(unpack(THEME.text))
                    end
                else
                    nameLbl:SetTextColor(unpack(THEME.text))
                end
                local shownName, ruleset = PM_CharacterDisplay(charName)
                nameLbl:SetText(shownName)
                nameLbl:SetWidth(CHAR_NAME_W)
                nameLbl:SetJustifyH("LEFT")
                if ruleset then
                    nameLbl:SetWordWrap(false)
                    nameLbl:SetPoint("BOTTOMLEFT", row, "LEFT", 4, 1)
                    local rulesetLbl = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                    rulesetLbl:SetTextColor(unpack(THEME.mutedText))
                    rulesetLbl:SetText(ruleset)
                    rulesetLbl:SetWidth(CHAR_NAME_W)
                    rulesetLbl:SetJustifyH("LEFT")
                    rulesetLbl:SetWordWrap(false)
                    rulesetLbl:SetPoint("TOPLEFT", row, "LEFT", 4, -1)
                else
                    nameLbl:SetPoint("LEFT", nameLbl:GetParent(), "LEFT", 4, 0)
                end

                local cn = charName

                local removeBtn = CreateFrame("Button", nil, row)
                removeBtn:SetSize(CHAR_REMOVE_W, CHAR_REMOVE_W)
                removeBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                removeBtn.xLbl = removeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                removeBtn.xLbl:SetPoint("CENTER", removeBtn, "CENTER", 0, 0)
                removeBtn.xLbl:SetText("X")
                removeBtn.xLbl:SetTextColor(0.95, 0.25, 0.25, 1)
                removeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
                removeBtn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(cn == currentChar and "Can't remove the character you're logged in on" or "Remove alt")
                    GameTooltip:Show()
                end)
                removeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                if cn == currentChar then
                    removeBtn:Disable()
                    removeBtn.xLbl:SetTextColor(0.5, 0.5, 0.5, 1)
                end
                removeBtn:SetScript("OnClick", function()
                    local kc = ProfileManagerDB.knownChars
                    for ki = #kc, 1, -1 do
                        if kc[ki] == cn then table.remove(kc, ki) end
                    end
                    if ProfileManagerDB.charPresets then
                        ProfileManagerDB.charPresets[cn] = nil
                    end
                    if ProfileManagerDB.charNames then
                        ProfileManagerDB.charNames[cn] = nil
                    end
                    RefreshCharList()
                end)

                local chk = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
                chk:SetSize(20, 20)
                chk:SetPoint("RIGHT", removeBtn, "LEFT", -8, 0)
                if chk.text then chk.text:SetText("") end
                local cd = ProfileManagerDB.charPresets and ProfileManagerDB.charPresets[cn]
                chk:SetChecked(type(cd) == "table" and cd.applyOnLogin == true)
                chk:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Apply on next login")
                    GameTooltip:AddLine("Applies this character's preset, keybinds, addon set and game settings the next time it logs in.", 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                chk:SetScript("OnLeave", function() GameTooltip:Hide() end)
                chk:SetScript("OnClick", function(self)
                    ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}
                    ProfileManagerDB.charPresets[cn] = ProfileManagerDB.charPresets[cn] or {}
                    ProfileManagerDB.charPresets[cn].applyOnLogin = self:GetChecked()
                end)

                local charDD
                charDD = PM_CreateDeleteDropdown(
                    row, CHAR_DD_W,
                    GetPresetItems,
                    function(selected)
                        ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}
                        ProfileManagerDB.charPresets[cn] = ProfileManagerDB.charPresets[cn] or {}
                        ProfileManagerDB.charPresets[cn].preset = (selected == "(None)") and "" or selected
                        SetDDText(charDD, selected)
                    end,
                    function()
                        local cdd = ProfileManagerDB.charPresets and ProfileManagerDB.charPresets[cn]
                        local v = type(cdd) == "table" and cdd.preset or ""
                        return (type(v) == "string" and v ~= "") and v or "(None)"
                    end
                )
                charDD:SetPoint("LEFT", row, "LEFT", presetX, 0)
                SetDDText(charDD, OrNone(cd and cd.preset))

                local keysDD
                keysDD = PM_CreateDeleteDropdown(
                    row, CHAR_DD_W,
                    GetKeybindItems,
                    function(selected)
                        ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}
                        ProfileManagerDB.charPresets[cn] = ProfileManagerDB.charPresets[cn] or {}
                        ProfileManagerDB.charPresets[cn].keybinds = (selected == "(None)") and "" or selected
                        SetDDText(keysDD, selected)
                    end,
                    function()
                        local cdd = ProfileManagerDB.charPresets and ProfileManagerDB.charPresets[cn]
                        return OrNone(type(cdd) == "table" and cdd.keybinds or "")
                    end
                )
                keysDD:SetPoint("LEFT", row, "LEFT", keysX, 0)
                SetDDText(keysDD, OrNone(cd and cd.keybinds))

                local addonsDD
                addonsDD = PM_CreateDeleteDropdown(
                    row, CHAR_DD_W,
                    GetAddonSetItems,
                    function(selected)
                        ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}
                        ProfileManagerDB.charPresets[cn] = ProfileManagerDB.charPresets[cn] or {}
                        ProfileManagerDB.charPresets[cn].addons = (selected == "(None)") and "" or selected
                        SetDDText(addonsDD, selected)
                    end,
                    function()
                        local cdd = ProfileManagerDB.charPresets and ProfileManagerDB.charPresets[cn]
                        return OrNone(type(cdd) == "table" and cdd.addons or "")
                    end
                )
                addonsDD:SetPoint("LEFT", row, "LEFT", addonsX, 0)
                SetDDText(addonsDD, OrNone(cd and cd.addons))

                local settingsDD
                settingsDD = PM_CreateDeleteDropdown(
                    row, CHAR_DD_W,
                    GetSettingsItems,
                    function(selected)
                        ProfileManagerDB.charPresets = ProfileManagerDB.charPresets or {}
                        ProfileManagerDB.charPresets[cn] = ProfileManagerDB.charPresets[cn] or {}
                        ProfileManagerDB.charPresets[cn].settings = (selected == "(None)") and "" or selected
                        SetDDText(settingsDD, selected)
                    end,
                    function()
                        local cdd = ProfileManagerDB.charPresets and ProfileManagerDB.charPresets[cn]
                        return OrNone(type(cdd) == "table" and cdd.settings or "")
                    end
                )
                settingsDD:SetPoint("LEFT", row, "LEFT", settingsX, 0)
                SetDDText(settingsDD, OrNone(cd and cd.settings))

                table.insert(charRows, row)
            end
        end

        charScrollChild:SetHeight(math.max(rowIdx * CHAR_ROW_H, 1))
    end

    charSearch:HookScript("OnTextChanged", function()
        RefreshCharList()
    end)

    f._pmRefreshCharList = function() RefreshCharList() end

    local charRelayoutToken = 0
    charScrollFrame:HookScript("OnSizeChanged", function()
        if not f.optionsPage:IsShown() then return end
        if f._pmSizing then return end
        charRelayoutToken = charRelayoutToken + 1
        local token = charRelayoutToken
        Delay(0.2, function()
            if token == charRelayoutToken and f.optionsPage:IsShown() then RefreshCharList() end
        end)
    end)

    f.optionsPage:SetScript("OnShow", function()
        local v = ProfileManagerDB.newCharDefault
        SetDDText(newCharDD, (type(v) == "string" and v ~= "") and v or "(None)")
        SetDDText(newCharKeysDD, OrNone(ProfileManagerDB.newCharKeybinds))
        SetDDText(newCharAddonsDD, OrNone(ProfileManagerDB.newCharAddons))
        SetDDText(newCharSettingsDD, OrNone(ProfileManagerDB.newCharSettings))
        RefreshCharList()
    end)

    f.editorPanel = CreatePanel(f.editorContainer, 0)
    f.editorPanel:SetAllPoints(f.editorPanel:GetParent())

    f.editorTitle = f.editorPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.editorTitle:SetTextColor(unpack(THEME.titleText))
    f.editorTitle:SetText("Edit Preset")

    f.editorHint = f.editorPanel:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    f.editorHint:SetTextColor(unpack(THEME.mutedText))
    f.editorHint:SetText("Select a preset on the left to edit it.")

    f.editorTitle:ClearAllPoints()
    f.editorTitle:SetPoint("TOPLEFT", f.editorTitle:GetParent(), "TOPLEFT", 12, -12)

    f.editorHint:ClearAllPoints()
    f.editorHint:SetPoint("TOPLEFT", f.editorTitle, "BOTTOMLEFT", 0, -8)

    local okEdSearch, edSearch = pcall(CreateFrame, "EditBox", nil, f.editorContainer, "SearchBoxTemplate")
    if not okEdSearch or not edSearch then
        edSearch = CreateFrame("EditBox", nil, f.editorContainer, "InputBoxTemplate")
    end
    f.editorSearch = edSearch
    f.editorSearch:SetSize(220, 22)
    f.editorSearch:SetAutoFocus(false)
    f.editorSearch:SetMaxLetters(50)
    f.editorSearch:ClearAllPoints()
    f.editorSearch:SetPoint("TOPRIGHT", f.editorSearch:GetParent(), "TOPRIGHT", -30, -14)
    f.editorSearch:HookScript("OnTextChanged", function()
        addon:ApplyEditorSearchFilter()
    end)

    f.editorScroll = CreateFrame("ScrollFrame", nil, f.editorContainer, "ScrollFrameTemplate")
    f.editorScroll:EnableMouseWheel(true)
    f.editorScroll:SetScript("OnMouseWheel", function(self, delta)
        local step  = EDITOR_ROW_HEIGHT * 2
        local cur   = self:GetVerticalScroll() or 0
        local range = self:GetVerticalScrollRange() or 0
        self:SetVerticalScroll(Clamp(cur - delta * step, 0, range))
    end)

    f.editorScroll:SetPoint("TOPLEFT", f.editorScroll:GetParent(), "TOPLEFT", 6, -48)
    f.editorScroll:SetPoint("BOTTOMRIGHT", f.editorScroll:GetParent(), "BOTTOMRIGHT", -28, PURPLE_BAR_H + 10)

    f.editorScrollChild = CreateFrame("Frame", nil, f.editorScroll)
    f.editorScrollChild:SetSize(1, 1)
    f.editorScroll:SetScrollChild(f.editorScrollChild)

    f.editorRows = {}

    f.purpleBar = CreatePanel(f.editorContainer, 0)
    f.purpleBar:SetPoint("BOTTOMLEFT", f.purpleBar:GetParent(), "BOTTOMLEFT", 6, 10)
    f.purpleBar:SetPoint("BOTTOMRIGHT", f.purpleBar:GetParent(), "BOTTOMRIGHT", -10, 10)
    f.purpleBar:SetHeight(PURPLE_BAR_H)
    f.purpleBar.bg:SetColorTexture(0.02, 0.02, 0.025, 0.75)
    f.purpleBar.border:SetBackdropBorderColor(1, 1, 1, 0.05)

    f.saveBtn = CreateFrame("Button", nil, f.purpleBar, "UIPanelButtonTemplate")
    f.saveBtn:SetSize(120, 26)
    f.saveBtn:SetText("Save Changes")
    f.saveBtn:SetPoint("LEFT", f.saveBtn:GetParent(), "LEFT", 10, 0)
    f.saveBtn:Disable()

    f.cancelBtn = CreateFrame("Button", nil, f.purpleBar, "UIPanelButtonTemplate")
    f.cancelBtn:SetSize(80, 26)
    f.cancelBtn:SetText("Cancel")
    f.cancelBtn:SetPoint("LEFT", f.saveBtn, "RIGHT", 8, 0)
    f.cancelBtn:Disable()

    f.selMenuBtn = CreateFrame("Button", nil, f.purpleBar, "UIPanelButtonTemplate")
    f.selMenuBtn:SetSize(110, 26)
    f.selMenuBtn:SetText("Selected")
    f.selMenuBtn.arrow = f.selMenuBtn:CreateTexture(nil, "OVERLAY")
    f.selMenuBtn.arrow:SetSize(12, 12)
    f.selMenuBtn.arrow:SetPoint("RIGHT", f.selMenuBtn.arrow:GetParent(), "RIGHT", -8, 0)
    if not pcall(f.selMenuBtn.arrow.SetAtlas, f.selMenuBtn.arrow, "uitools-icon-chevron-down") then
        f.selMenuBtn.arrow:SetSize(16, 16)
        f.selMenuBtn.arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    end
    f.selMenuBtn:SetPoint("RIGHT", f.selMenuBtn:GetParent(), "RIGHT", -10, 0)
    f.selMenuBtn:Disable()
    f.selMenuBtn:SetScript("OnClick", function(btn)
        if not (MenuUtil and MenuUtil.CreateContextMenu) then return end
        MenuUtil.CreateContextMenu(btn, function(_, root)
            root:CreateButton("Apply Selected", function() addon:ApplySelectedFromInlineEditor() end)
            root:CreateButton("Export Selected...", function() addon:ExportSelectedFromInlineEditor() end)
            root:CreateButton("Delete Unused (Selected)...", function() addon:DeleteUnusedProfilesForSelectedRows() end)
        end)
    end)
    f.exportSelectedBtn = f.selMenuBtn
    f.applySelectedBtn = f.selMenuBtn
    f.deleteUnusedSelectedBtn = f.selMenuBtn

    f.uncheckAllBtn = CreateFrame("Button", nil, f.purpleBar, "UIPanelButtonTemplate")
    f.uncheckAllBtn:SetSize(100, 26)
    f.uncheckAllBtn:SetText("Uncheck All")
    f.uncheckAllBtn:SetPoint("RIGHT", f.selMenuBtn, "LEFT", -12, 0)

    f.checkAllBtn = CreateFrame("Button", nil, f.purpleBar, "UIPanelButtonTemplate")
    f.checkAllBtn:SetSize(90, 26)
    f.checkAllBtn:SetText("Check All")
    f.checkAllBtn:SetPoint("RIGHT", f.uncheckAllBtn, "LEFT", -8, 0)

    local function SetAllRowChecks(state)
        for _, row in ipairs(f.editorRows or {}) do
            if row.selectChk and row.selectChk:IsEnabled() then
                row.selectChk:SetChecked(state and true or false)
                row.isSelected = state and true or false
            end
        end
    end

    f.checkAllBtn:SetScript("OnClick", function() SetAllRowChecks(true) end)
    f.uncheckAllBtn:SetScript("OnClick", function() SetAllRowChecks(false) end)

    f.saveBtn:SetScript("OnClick", function() addon:SaveInlineEditor() end)
    f.cancelBtn:SetScript("OnClick", function() addon:CancelInlineEditor() end)

    local function DoAddPreset()
        local typed = strtrim(AddBox_GetRealText() or "")
        local wasEmpty = (typed == "")

        local name
        if wasEmpty then
            name = EnsureUniquePresetName(MakeDefaultPresetName())
        else
            name = EnsureUniquePresetName(typed)
        end

        if addon.TryRegisterAllProviders then
            addon:TryRegisterAllProviders()
        end

        local selections = {}
        if type(addon.CaptureCurrentSelections) == "function" then
            selections = addon:CaptureCurrentSelections()
        end

        if type(addon.SavePreset) == "function" then
            local ok = addon:SavePreset(name, selections)
            if ok == false then return end
        end

        AddBox_ShowPlaceholder()
        addon:RefreshMainUI()
        addon:OpenInlineEditor(name)

        if wasEmpty and addon.ShowRenamePresetPopup then
            Delay(0, function()
                if addon.MainUI and addon.MainUI:IsShown() then
                    addon:ShowRenamePresetPopup(name)
                end
            end)
        end
    end

    f.addBtn:SetScript("OnClick", DoAddPreset)
    f.addBox:SetScript("OnEnterPressed", DoAddPreset)

    self.MainUI = f
    if f._pmSwitchDashboard then f._pmSwitchDashboard() end
end

function addon:ShowMainUI()
    self:CreateMainUI()

    if self.TryRegisterAllProviders then
        self:TryRegisterAllProviders()
    end

    PM_ApplyWindowScale(self.MainUI)
    local w, h = self.MainUI:GetSize()
    if (w or 0) < MIN_W - 0.5 or (h or 0) < MIN_H - 0.5 then
        self.MainUI:SetSize(math.max(w or 0, MIN_W), math.max(h or 0, MIN_H))
    end
    PM_ApplyFontSizeToMain(self.MainUI)
    self:RefreshMainUI()
    self.MainUI:Show()

    Delay(0, function()
        if not addon.MainUI or not addon.MainUI:IsShown() then return end
        if addon.TryRegisterAllProviders then addon:TryRegisterAllProviders() end
        addon:RefreshMainUI()
        if addon.MainUI.selectedPresetName then
            addon:OpenInlineEditor(addon.MainUI.selectedPresetName)
        end
    end)
end

function addon:RefreshMainUI()
    local f = self.MainUI
    if not f then return end

    self:RefreshPresetList()

    if not (f.selectedPresetName and self:GetPreset(f.selectedPresetName)) then
        self:ClearInlineEditor()
    end
    if f.dashPage and f.dashPage:IsShown() then
        self:BuildDashboardRows()
    end
end

function addon:RefreshPresetList()
    local f = self.MainUI
    if not f then return end

    WipeRows(f.presetRows)

    local names = self:GetPresetNames()
    local total = #names

    f.scrollChild:SetHeight(math.max(1, total * PRESET_ROW_H + 6))

    local leftW = (f.scrollFrame:GetWidth() or 1) - 8
    if leftW < 1 then leftW = 1 end
    f.scrollChild:SetWidth(leftW)

    local y = -2
    for i = 1, total do
        local presetName = names[i]
        local row = self:CreatePresetListRow(f.scrollChild, presetName, y)
        f.presetRows[#f.presetRows + 1] = row
        y = y - PRESET_ROW_H
    end
    PM_ApplyFontSizeToMain(f)
end

function addon:CreatePresetListRow(parent, presetName, y)
    local f = self.MainUI

    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(PRESET_ROW_H)
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    row:RegisterForClicks("LeftButtonUp")

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.bg:GetParent())
    if not pcall(row.bg.SetAtlas, row.bg, "Options_List_Hover", true) then
        row.bg:SetColorTexture(unpack(THEME.rowBg))
    end

    row.hover = row:CreateTexture(nil, "HIGHLIGHT")
    row.hover:SetAllPoints(row.hover:GetParent())
    if not pcall(row.hover.SetAtlas, row.hover, "Options_List_Hover", true) then
        row.hover:SetColorTexture(unpack(THEME.rowHover))
    end

    row.selBar = row:CreateTexture(nil, "ARTWORK")
    row.selBar:SetAllPoints(row.selBar:GetParent())
    if not pcall(row.selBar.SetAtlas, row.selBar, "Options_List_Active", true) then
        row.selBar:SetColorTexture(unpack(THEME.rowSelected))
    end
    row.selBar:Hide()

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("LEFT", row.nameText:GetParent(), "LEFT", 8, 0)
    row.nameText:SetPoint("RIGHT", row.nameText:GetParent(), "RIGHT", -80, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.nameText:SetTextColor(unpack(THEME.text))
    row.nameText:SetText(presetName)

    local function DoApply()
        local _, _, skipped = addon:ApplyPreset(presetName)
        local notSwitched = addon:DescribeSkipped(skipped)
        if notSwitched then print("|cffffd100ProfileManager|r " .. notSwitched) end
        addon:ShowForceReloadPopup(
            ("Preset '|cffcfd0ff%s|r' applied.\n\nSome addons require reload to apply changes"):format(presetName)
        )
    end

    local ICONS = {
        { key = "applyBtn",  atlas = "common-icon-checkmark",    tex = "Interface\\Buttons\\UI-CheckBox-Check",            tip = "Apply preset", fn = DoApply },
        { key = "renameBtn", atlas = "common-icon-pencil",       tex = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", tip = "Rename",
          fn = function() addon:ShowRenamePresetPopup(presetName) end },
        { key = "exportBtn", atlas = "common-icon-forwardarrow", tex = "Interface\\Buttons\\UI-GuildButton-MOTD-Up",       tip = "Export",
          fn = function() addon:ShowPresetExportPopup(presetName) end },
        { key = "deleteBtn", xText = true, tip = "Delete",
          fn = function() addon:ConfirmDeletePreset(presetName) end },
    }
    local prev
    for i = #ICONS, 1, -1 do
        local def = ICONS[i]
        local b = CreateFrame("Button", nil, row)
        b:SetSize(16, 16)
        if prev then
            b:SetPoint("RIGHT", prev, "LEFT", -3, 0)
        else
            b:SetPoint("RIGHT", row, "RIGHT", 4, 0)
        end
        if def.xText then
            b.xLbl = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.xLbl:SetPoint("CENTER", b.xLbl:GetParent(), "CENTER", 0, 0)
            b.xLbl:SetText("X")
            b.xLbl:SetTextColor(0.95, 0.25, 0.25, 1)
        else
            b:SetNormalTexture(def.tex)
            if def.atlas then
                local nt = b:GetNormalTexture()
                pcall(nt.SetAtlas, nt, def.atlas)
            end
        end
        b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
        b:SetScript("OnClick", def.fn)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(def.tip)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row[def.key] = b
        prev = b
    end

    row:SetScript("OnClick", function()
        if f.selectedPresetName == presetName then
            addon:ClearInlineEditor()
            addon:RefreshPresetList()
        else
            addon:OpenInlineEditor(presetName)
        end
    end)
    row:SetScript("OnDoubleClick", DoApply)

    if f.selectedPresetName == presetName then
        row.selBar:Show()
    end

    return row
end

function addon:ConfirmDeletePreset(presetName)
    StaticPopupDialogs["PROFILEMANAGER_DELETE"] = {
        text = "Delete preset '" .. presetName .. "'?",
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function()
            addon:DeletePreset(presetName)
            addon:RefreshMainUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("PROFILEMANAGER_DELETE")
end

function addon:ConfirmDeleteAllUnusedProfiles(providerId)
    if InCombatLockdown and InCombatLockdown() then
        print("|cffff5555ProfileManager|r Cannot delete profiles in combat.")
        return
    end

    local nice = PM_GetProviderNiceName(providerId)
    local list = self:GetDeletableUnusedProfiles(providerId)
    local count = #list

    if count == 0 then
        print("|cffffaa00ProfileManager|r No unused profiles to delete for: " .. nice)
        return
    end

    local key = "PROFILEMANAGER_DELETE_ALL_UNUSED_" .. tostring(providerId)

    StaticPopupDialogs[key] = {
        text = ("Delete ALL unused profiles for:\n\n|cffcfd0ff%s|r\n\nProfiles to delete: |cffffaa00%d|r\n\nThis cannot be undone.")
            :format(nice, count),
        button1 = "Delete All",
        button2 = "Cancel",
        OnAccept = function()
            local ok, a, b = self:DeleteAllUnusedProfiles(providerId)
            if not ok then
                print("|cffff5555ProfileManager|r Delete All failed: " .. tostring(a))
                return
            end

            local deleted = tonumber(a or 0) or 0
            local failed  = tonumber(b or 0) or 0
            print(("|cff00ff00ProfileManager|r Deleted %d unused profiles for %s. Failed: %d")
                :format(deleted, nice, failed))

            if self.MainUI and self.MainUI.selectedPresetName then
                self:OpenInlineEditor(self.MainUI.selectedPresetName)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopup_Show(key)
end

function addon:DeleteUnusedProfilesForSelectedRows()
    if InCombatLockdown and InCombatLockdown() then
        print("|cffff5555ProfileManager|r Can't delete profiles in combat.")
        return
    end

    local f = self.MainUI
    if not f or not f.selectedPresetName then return end

    local providerIds = {}
    local seen = {}

    for _, row in ipairs(f.editorRows or {}) do
        if row
            and not row.isMissing
            and row.providerId
            and row.selectChk
            and row.selectChk:IsEnabled()
            and row.selectChk:GetChecked()
        then
            local pid = tostring(row.providerId)
            if not seen[pid] then
                seen[pid] = true
                providerIds[#providerIds + 1] = pid
            end
        end
    end

    if #providerIds == 0 then
        print("|cffffaa00ProfileManager|r No rows selected.")
        return
    end

    table.sort(providerIds, function(a,b)
        return tostring(PM_GetProviderNiceName(a) or a):lower() < tostring(PM_GetProviderNiceName(b) or b):lower()
    end)

    local totalProfiles = 0
    local previewLines = {}

    for _, pid in ipairs(providerIds) do
        local list = self:GetDeletableUnusedProfiles(pid) or {}
        local n = #list
        totalProfiles = totalProfiles + n

        if n > 0 and #previewLines < 12 then
            previewLines[#previewLines + 1] = ("• %s: %d"):format(PM_GetProviderNiceName(pid), n)
        end
    end

    if totalProfiles == 0 then
        print("|cffffaa00ProfileManager|r No unused profiles to delete for the selected rows.")
        return
    end

    local key = "PM_DELETE_UNUSED_SELECTED_CONFIRM"
    StaticPopupDialogs[key] = {
        text = ("Delete ALL unused profiles for selected addons?\n\nSelected addons: |cffcfd0ff%d|r\nProfiles to delete: |cffff5555%d|r\n\n%s%s")
            :format(
                #providerIds,
                totalProfiles,
                table.concat(previewLines, "\n"),
                (#previewLines >= 12 and "\n|cff9aa0a6(and more...)|r" or "")
            ),
        button1 = "Delete",
        button2 = "Cancel",
        OnAccept = function()
            local deletedTotal, failedTotal = 0, 0

            for _, pid in ipairs(providerIds) do
                local ok, a, b = self:DeleteAllUnusedProfiles(pid)
                if ok then
                    deletedTotal = deletedTotal + (tonumber(a) or 0)
                    failedTotal  = failedTotal  + (tonumber(b) or 0)
                else
                    failedTotal = failedTotal + 1
                end
            end

            if failedTotal > 0 then
                print(("|cffffaa00ProfileManager|r Deleted %d unused profiles, %d failed."):format(deletedTotal, failedTotal))
            else
                print(("|cff00ff00ProfileManager|r Deleted %d unused profiles."):format(deletedTotal))
            end

            if self.RefreshMainUI then
                pcall(function() self:RefreshMainUI() end)
            end
            if self.OpenInlineEditor and f and f.selectedPresetName then
                pcall(function() self:OpenInlineEditor(f.selectedPresetName) end)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopup_Show(key)
end

function addon:ShowRenamePresetPopup(oldName)
    StaticPopupDialogs["PROFILEMANAGER_RENAME"] = {
        text = "Rename preset '" .. oldName .. "' to:",
        button1 = "Rename",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 220,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,

        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if not eb then return end
            eb:SetText(oldName)
            eb:HighlightText()
            eb:SetFocus()
        end,

        OnAccept = function(self)
            local eb = self.editBox or self.EditBox
            if not eb then return end

            local newName = strtrim(eb:GetText() or "")
            if newName == "" then return end

            if addon.RenamePreset and addon:RenamePreset(oldName, newName) then
                local f = addon.MainUI
                if f and f.selectedPresetName == oldName then
                    f.selectedPresetName = newName
                end
                addon:RefreshMainUI()
                addon:OpenInlineEditor(newName)
            else
                print("|cffffaa00ProfileManager:|r Rename failed (name exists or invalid).")
            end
        end,
    }
    StaticPopup_Show("PROFILEMANAGER_RENAME")
end

function addon:BuildDashboardRows()
    local f = self.MainUI
    if not f or not f.dashScrollChild then return end

    if self.TryRegisterAllProviders and not f._pmProvidersScanned then
        f._pmProvidersScanned = true
        self:TryRegisterAllProviders()
    end

    local ids = {}
    for providerId in pairs(self.Providers or {}) do
        ids[#ids + 1] = providerId
    end
    table.sort(ids, function(a, b)
        local af, bf = PM_IsFavorite(a), PM_IsFavorite(b)
        if af ~= bf then return af end
        return PM_SortLower(PM_GetProviderNiceName(a) or a, PM_GetProviderNiceName(b) or b)
    end)

    local DASH_ROW_H = 24
    f.dashRowPool = f.dashRowPool or {}
    wipe(f.dashRows)

    local scrollW = f.dashScroll:GetWidth() or 0
    if scrollW < 50 then
        local pageW = f.dashPage:GetWidth() or 0
        scrollW = math.max(50, pageW - 44)
    end
    f.dashScrollChild:SetWidth(math.max(1, scrollW - 10))

    local function MakeRow()
        local row = CreateFrame("Frame", nil, f.dashScrollChild)
        row:SetHeight(DASH_ROW_H)
        row.rowHeight = DASH_ROW_H

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row.bg:GetParent())
        if not pcall(row.bg.SetAtlas, row.bg, "Options_List_Hover", true) then
            row.bg:SetColorTexture(unpack(THEME.rowBg))
        end

        row.star = row:CreateTexture(nil, "ARTWORK")
        row.star:SetSize(14, 14)
        row.star:SetPoint("LEFT", row.star:GetParent(), "LEFT", 6, 0)
        if not pcall(row.star.SetAtlas, row.star, "auctionhouse-icon-favorite") then
            row.star:SetTexture("Interface\\COMMON\\FavoritesIcon")
        end
        row.star:Hide()

        row.liveText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.liveText:SetPoint("RIGHT", row.liveText:GetParent(), "RIGHT", -8, 0)
        row.liveText:SetJustifyH("RIGHT")
        row.liveText:SetTextColor(1.00, 0.82, 0.40, 1)

        row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.nameText:SetPoint("RIGHT", row.liveText, "LEFT", -10, 0)
        row.nameText:SetJustifyH("LEFT")
        row.nameText:SetWordWrap(false)
        row.nameText:SetTextColor(unpack(THEME.text))
        return row
    end

    for i, providerId in ipairs(ids) do
        local row = f.dashRowPool[i]
        if not row then
            row = MakeRow()
            f.dashRowPool[i] = row
        end

        local prov = self.Providers[providerId]
        local live
        if prov and prov.GetCurrentProfile then
            live = SafeCall(function() return prov:GetCurrentProfile() end)
        end

        row.providerId = providerId
        row.searchText = tostring(PM_GetProviderNiceName(providerId) or providerId)

        local fav = PM_IsFavorite(providerId)
        row.star:SetShown(fav)
        row.nameText:ClearAllPoints()
        row.nameText:SetPoint("LEFT", row.nameText:GetParent(), "LEFT", fav and 24 or 8, 0)
        row.nameText:SetPoint("RIGHT", row.liveText, "LEFT", -10, 0)
        row.nameText:SetText(row.searchText)
        row.liveText:SetText(live and PM_ProfileDisplayLabel(tostring(live)) or "|cff888888\226\128\148|r")

        f.dashRows[#f.dashRows + 1] = row
    end

    for i = #ids + 1, #f.dashRowPool do
        f.dashRowPool[i]:Hide()
    end

    if f.dashHint then
        f.dashHint:SetText(("%d addons managed."):format(#ids))
    end

    self:UpdateDashboardCards()
    PM_ApplyFontSizeToMain(f)
    self:ApplyDashboardSearchFilter()
end

function addon:UpdateDashboardCards()
    local f = self.MainUI
    if not (f and f.dashKeysCard) then return end
    local KB, AO, GS = self.Keybinds, self.Addons, self.GameSettings

    local pageW = f.dashPage:GetWidth()
    if pageW and pageW > 200 then
        local cardW = math.floor((pageW - 6 - 28 - 16) / 3)
        f.dashKeysCard:SetWidth(cardW)
        f.dashAddonsCard:SetWidth(cardW)
    end

    local keys = f.dashKeysCard
    if KB and KB:IsAvailable() then
        local match, saved = KB:MatchingProfiles(), #KB:GetProfileNames()
        keys.value:SetText(#match > 0 and table.concat(match, ", ") or "|cff9aa0a6Unsaved|r")
        keys.detail:SetText(("%s bindings, %d profile%s saved"):format(KB:SetName(), saved, saved == 1 and "" or "s"))
    else
        keys.value:SetText("|cff9aa0a6Not available|r")
        keys.detail:SetText("")
    end

    local adds = f.dashAddonsCard
    if AO and AO:IsAvailable() then
        local match = AO:MatchingSets()
        local on, total = 0, 0
        for _, a in ipairs(AO:List()) do
            total = total + 1
            if a.enabled then on = on + 1 end
        end
        local detail = ("%d of %d addons enabled"):format(on, total)
        if AO:PendingReloads() > 0 then detail = detail .. ", |cffffd100reload pending|r" end
        adds.value:SetText(#match > 0 and table.concat(match, ", ") or "|cff9aa0a6Unsaved|r")
        adds.detail:SetText(detail)
    else
        adds.value:SetText("|cff9aa0a6Not available|r")
        adds.detail:SetText("")
    end

    local gs = f.dashSettingsCard
    if GS and GS:IsAvailable() then
        local match, saved = GS:MatchingProfiles(), #GS:GetProfileNames()
        gs.value:SetText(#match > 0 and table.concat(match, ", ") or "|cff9aa0a6Unsaved|r")
        gs.detail:SetText(("%d settings, %d profile%s saved"):format(#GS:ReadCurrent(), saved, saved == 1 and "" or "s"))
    else
        gs.value:SetText("|cff9aa0a6Not available|r")
        gs.detail:SetText("")
    end
end

function addon:ApplyDashboardSearchFilter()
    local f = self.MainUI
    if not f or not f.dashRows then return end

    local txt = (f.dashSearch and f.dashSearch:GetText()) or ""
    local filter = strtrim(txt):lower()
    if filter == "search..." or filter == "search" then filter = "" end

    local y, shown = -2, 0
    for _, row in ipairs(f.dashRows) do
        local match = (filter == "")
            or (tostring(row.searchText or ""):lower():find(filter, 1, true) ~= nil)
        if match then
            row:Show()
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
            row:SetPoint("RIGHT", f.dashScrollChild, "RIGHT", 0, 0)
            y = y - (row.rowHeight or 24)
            shown = shown + 1
        else
            row:Hide()
        end
    end
    f.dashScrollChild:SetHeight(math.max(1, shown * 24 + 6))
end

function addon:ClearInlineEditor()
    local f = self.MainUI
    if not f then return end

    f.selectedPresetName = nil
    f.editorTitle:SetTextColor(unpack(THEME.text))
    f.editorTitle:SetText("Edit Preset")
    f.editorHint:SetText("Select a preset on the left to edit it.")

    WipeRows(f.editorRows)

    f.saveBtn:Disable()
    f.cancelBtn:Disable()
    if f.applySelectedBtn then f.applySelectedBtn:Disable() end
    if f.exportSelectedBtn then f.exportSelectedBtn:Disable() end
    if f.deleteUnusedSelectedBtn then f.deleteUnusedSelectedBtn:Disable() end
    if f.purpleBar then f.purpleBar:Hide() end
end

function addon:OpenInlineEditor(presetName)
    local f = self.MainUI
    if not f then return end

    if self.TryRegisterAllProviders then
        self:TryRegisterAllProviders()
    end

    local preset = self:GetPreset(presetName)
    if not preset then
        self:ClearInlineEditor()
        return
    end

    f.selectedPresetName = presetName
    if f.purpleBar then f.purpleBar:Show() end
    f.editorTitle:SetText("Edit Preset: " .. presetName)
    f.editorHint:SetText("Change addon profiles below, then click Save Changes.")

    self:RefreshPresetList()
    WipeRows(f.editorRows)

    local seen = {}
    local addonList = {}

    for providerId in pairs(self.Providers or {}) do
        if not seen[providerId] then
            seen[providerId] = true
            addonList[#addonList + 1] = providerId
        end
    end

    for providerId in pairs(preset.addons or {}) do
        if not seen[providerId] then
            local prov = self.Providers and self.Providers[providerId]
            if prov then
                seen[providerId] = true
                addonList[#addonList + 1] = providerId
            else
                if IsAddonLoadedCompat(providerId) then
                    seen[providerId] = true
                    addonList[#addonList + 1] = providerId
                end
            end
        end
    end

    table.sort(addonList, function(a, b)
        local af = PM_IsFavorite(a)
        local bf = PM_IsFavorite(b)
        if af ~= bf then
            return af
        end

        local pa = addon.Providers and addon.Providers[a]
        local pb = addon.Providers and addon.Providers[b]

        local na = (pa and pa.displayName) or a
        local nb = (pb and pb.displayName) or b

        return tostring(na):lower() < tostring(nb):lower()
    end)

    local y = -2
    local count = #addonList

    for i = 1, count do
        local providerId = addonList[i]
        local prov = self.Providers and self.Providers[providerId]
        local currentProfile = preset.addons and preset.addons[providerId]

        if currentProfile == nil and prov and prov.GetCurrentProfile then
            local cur = SafeCall(function() return prov:GetCurrentProfile() end)
            if cur ~= nil then currentProfile = cur end
        end

        local row
        if prov then
            row = self:CreateInlineEditorRow(f.editorScrollChild, providerId, prov, currentProfile, y, i)
        else
            row = self:CreateInlineEditorMissingRow(f.editorScrollChild, providerId, currentProfile, y, i)
        end

        if row and row.warnIcon and not row.isMissing then
            local isInPreset = (preset.addons and preset.addons[providerId] ~= nil)
            row.notInPreset = not isInPreset
            row.warnIcon:SetShown(not isInPreset)
            UpdateRowChangeVisual(row)
        end

        f.editorRows[#f.editorRows + 1] = row
        y = y - (row.rowHeight or EDITOR_ROW_HEIGHT)
    end

    local scrollW = f.editorScroll:GetWidth() or 0
    if scrollW < 50 then
        local containerW = f.editorContainer:GetWidth() or 0
        scrollW = math.max(50, containerW - 44)
    end
    local w = scrollW - 10
    if w < 1 then w = 1 end
    f.editorScrollChild:SetWidth(w)

    local totalH = 0
    for _, r in ipairs(f.editorRows or {}) do totalH = totalH + (r.rowHeight or EDITOR_ROW_HEIGHT) end
    f.editorScrollChild:SetHeight(math.max(1, totalH + 6))

    PM_ApplyFontSizeToMain(f)
    self:ApplyEditorSearchFilter()

    f.saveBtn:Enable()
    f.cancelBtn:Enable()
    if f.applySelectedBtn then f.applySelectedBtn:Enable() end
    if f.exportSelectedBtn then f.exportSelectedBtn:Enable() end
    if f.deleteUnusedSelectedBtn then f.deleteUnusedSelectedBtn:Enable() end

end

function addon:CreateInlineEditorMissingRow(parent, providerId, currentProfile, y, index)
    local row = CreateFrame("Frame", nil, parent)
    row.rowHeight = EDITOR_ROW_HEIGHT
    row:SetHeight(row.rowHeight)
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.bg:GetParent())

    local alt = (tonumber(index or 1) % 2 == 0)
    if alt then
        row.bg:SetColorTexture(1, 1, 1, 0.02)
    else
        row.bg:SetColorTexture(unpack(THEME.rowBg))
    end

    AddRowDivider(row)

    row.selectChk = PM_MakeMinimalCheck(row)
    row.selectChk:SetPoint("LEFT", row.selectChk:GetParent(), "LEFT", 4, 0)
    row.selectChk:SetChecked(false)
    row.selectChk:Disable()

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    row.label:SetPoint("LEFT", row.label:GetParent(), "LEFT", 34, 0)
    row.label:SetTextColor(unpack(THEME.mutedText))
    row.label:SetJustifyH("LEFT")
    row.label:SetText(providerId .. " (provider missing)")

    row.value = row:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    row.value:SetPoint("RIGHT", row.value:GetParent(), "RIGHT", -10, 0)
    row.value:SetTextColor(unpack(THEME.mutedText))
    row.value:SetText("[" .. tostring(currentProfile) .. "]")

    row.providerId = providerId
    row.selectedProfile = currentProfile
    row.isMissing = true
    row.searchText = providerId .. " provider missing"

    return row
end

function addon:CreateInlineEditorRow(parent, providerId, prov, currentProfile, y, index)
    local row = CreateFrame("Frame", nil, parent)
    row.rowHeight = EDITOR_ROW_HEIGHT
    row:SetHeight(row.rowHeight)
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
    row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row.bg:GetParent())

    local alt = (tonumber(index or 1) % 2 == 0)
    if alt then
        row.bg:SetColorTexture(1, 1, 1, 0.02)
    else
        row.bg:SetColorTexture(unpack(THEME.rowBg))
    end

    row.selectChk = PM_MakeMinimalCheck(row)
    row.selectChk:SetChecked(true)

    row.favBtn = CreateFrame("Button", nil, row)
    row.favBtn:SetSize(FAV_BTN_W, FAV_BTN_W)

    row.favIcon = row.favBtn:CreateTexture(nil, "ARTWORK")
    row.favIcon:SetAllPoints(row.favIcon:GetParent())

    local function UpdateFavIconTop()
        PM_SetFavoriteIcon(row.favIcon, PM_IsFavorite(providerId))
    end
    UpdateFavIconTop()

    row.favBtn:SetScript("OnClick", function()
        PM_ToggleFavorite(providerId)
        UpdateFavIconTop()

        if addon.MainUI and addon.MainUI.selectedPresetName then
            addon:OpenInlineEditor(addon.MainUI.selectedPresetName)
            addon:ApplyEditorSearchFilter()
        else
            addon:RefreshMainUI()
        end
    end)

    row.favBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(row.favBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText(PM_IsFavorite(providerId) and "Unfavorite" or "Favorite")
        GameTooltip:Show()
    end)
    row.favBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.label:SetTextColor(unpack(THEME.text))
    row.label:SetJustifyH("LEFT")

    row.warnIcon = CreateFrame("Frame", nil, row)
    row.warnIcon:SetSize(16, 16)
    row.warnIcon.tex = row.warnIcon:CreateTexture(nil, "ARTWORK")
    row.warnIcon.tex:SetAllPoints(row.warnIcon.tex:GetParent())
    if not pcall(row.warnIcon.tex.SetAtlas, row.warnIcon.tex, "services-icon-warning") then
        row.warnIcon.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
    end
    row.warnIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Addon is not saved in this preset", 1, 0.82, 0)
        GameTooltip:AddLine("Saving will add it with the selected profile.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    row.warnIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.warnIcon:Hide()

    row.selectChk:ClearAllPoints()
    row.selectChk:SetPoint("LEFT", row.selectChk:GetParent(), "LEFT", 4, 0)

    row.favBtn:ClearAllPoints()
    row.favBtn:SetPoint("LEFT", row.selectChk, "RIGHT", FAV_GAP_L, 0)

    row.label:ClearAllPoints()
    row.label:SetPoint("LEFT", row.favBtn, "RIGHT", NAME_EXTRA_PAD, 0)

    AddRowDivider(row)

    local display = prov.displayName or providerId
        row.label:SetText(display)

    row.currentLive = nil
    if prov.GetCurrentProfile then
        row.currentLive = SafeCall(function() return prov:GetCurrentProfile() end)
    end

    local initial = tostring(currentProfile or "")
    row.selectedProfile = initial

    row.dropdown = PM_CreateProfileDropdown(
        row,
        DROPDOWN_FIXED_W,
        function()
            if prov.GetProfiles then
                local list = SafeCall(function() return prov:GetProfiles() end)
                if type(list) == "table" then return list end
            end
            return {}
        end,
        function()
            local live = row.currentLive
            return (live ~= nil) and tostring(live) or nil
        end,
        function(profileName)
            local usageCounts = PM_GetProfileUsageCounts(providerId)
            return usageCounts[tostring(profileName)] or 0
        end,
        function(chosen)
            row.selectedProfile = tostring(chosen)

            local live = tostring(row.currentLive or "")
            local selLabel = PM_ProfileDisplayLabel(row.selectedProfile)
            local desiredText

            if live ~= "" and row.selectedProfile == live then
                desiredText = "|cff00ff00" .. LIVE_ICON .. selLabel .. "|r"
            else
                desiredText = selLabel
            end

            if row.dropdown and row.dropdown._pmModern then
                PM_ModernDropdownForceText(row.dropdown, desiredText)
                if row.dropdown.GenerateMenu then
                    row.dropdown:GenerateMenu()
                end
            else
                PM_RememberDropdownText(row.dropdown, desiredText)
                PM_SetDropdownText(row.dropdown, desiredText)
            end

            UpdateRowChangeVisual(row)
        end,
        function()
            return row.selectedProfile or ""
        end
    )

    local live = tostring(row.currentLive or "")
    local initialLabel = PM_ProfileDisplayLabel(initial)
    local desiredText
    if live ~= "" and tostring(initial) == live then
        desiredText = "|cff00ff00" .. LIVE_ICON .. initialLabel .. "|r"
    else
        desiredText = initialLabel
    end

    if row.dropdown and row.dropdown._pmModern then
        PM_ModernDropdownForceText(row.dropdown, desiredText)
    else
        PM_RememberDropdownText(row.dropdown, desiredText)
        PM_SetDropdownText(row.dropdown, desiredText)
    end

    row.providerId = providerId
    row.searchText = (prov.displayName or providerId) .. " " .. providerId
    row.extraRightWidth = 0

    UpdateRowChangeVisual(row)

    local function GetDeletableProfiles()
        local profiles = {}
        if prov.GetProfiles then
            local list = SafeCall(prov.GetProfiles)
            if type(list) == "table" then profiles = list end
        end

        local liveNow = nil
        if prov.GetCurrentProfile then
            liveNow = SafeCall(prov.GetCurrentProfile)
            if liveNow ~= nil then liveNow = tostring(liveNow) end
        end

        local usedCounts = PM_GetProfileUsageCounts(providerId)

        local deletable = {}
        for _, name in ipairs(profiles) do
            local n = tostring(name)
            local isBlizzPreset =
                (providerId == "BlizzardEditMode") and
                (n:lower() == "modern" or n:lower() == "classic")
            local usedCount = usedCounts[n] or 0
            if n ~= "" and n ~= liveNow and usedCount == 0 and not isBlizzPreset then
                deletable[#deletable + 1] = n
            end
        end

        table.sort(deletable, function(a, b) return a:lower() < b:lower() end)
        return deletable
    end

    local function DoDeleteProfile(name)
        local ok, err = false, nil
        if prov.DeleteProfile then
            ok, err = prov:DeleteProfile(name)
        elseif prov.db and prov.db.sv and prov.db.sv.profiles then
            if prov.db.sv.profiles[name] ~= nil then
                prov.db.sv.profiles[name] = nil
                ok = true
            end
        end
        if ok then
            print("|cff00ff00ProfileManager|r Deleted profile: " .. PM_ProfileDisplayLabel(name))
            addon:RefreshMainUI()
            if addon.MainUI and addon.MainUI.selectedPresetName then
                addon:OpenInlineEditor(addon.MainUI.selectedPresetName)
            end
        else
            print("|cffff5555ProfileManager|r Failed to delete profile: " .. tostring(name or err or "unknown"))
        end
    end

    row.menuBtn = CreateFrame("Button", nil, row)
    row.menuBtn:SetSize(22, 22)
    local function RoundTex(layer, size, r, g, b, a)
        local t = row.menuBtn:CreateTexture(nil, layer)
        t:SetPoint("CENTER", t:GetParent(), "CENTER")
        t:SetSize(size, size)
        t:SetColorTexture(r, g, b, a)
        local m = row.menuBtn:CreateMaskTexture()
        m:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        m:SetAllPoints(t)
        t:AddMaskTexture(m)
        return t
    end
    row.menuBtn.rim  = RoundTex("BACKGROUND", 22, 0.62, 0.62, 0.68, 0.9)
    row.menuBtn.disc = RoundTex("BORDER",     20, 0.10, 0.10, 0.12, 1.0)
    row.menuBtn.dots = {}
    for di = -1, 1 do
        local d = RoundTex("OVERLAY", 3, 0.92, 0.92, 0.96, 1)
        d:ClearAllPoints()
        d:SetPoint("CENTER", d:GetParent(), "CENTER", di * 5, 0)
        row.menuBtn.dots[#row.menuBtn.dots + 1] = d
    end
    RoundTex("HIGHLIGHT", 20, 1, 1, 1, 0.12)
    row.menuBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Import / Export / Delete")
        GameTooltip:Show()
    end)
    row.menuBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row.menuBtn:SetScript("OnClick", function(btn)
        if not (MenuUtil and MenuUtil.CreateContextMenu) then return end
        MenuUtil.CreateContextMenu(btn, function(_, root)
            if root.SetScrollMode then
                root:SetScrollMode(20 * 20)
            end
            if prov.ImportProfile then
                root:CreateButton("Import...", function()
                    addon:ShowImportWizard(providerId, prov, function(newName)
                        row.selectedProfile = tostring(newName)
                        local t = RELOAD_PREFIX .. PM_ProfileDisplayLabel(row.selectedProfile)
                        if row.dropdown then
                            if row.dropdown._pmModern then
                                PM_ModernDropdownForceText(row.dropdown, t)
                                if row.dropdown.GenerateMenu then row.dropdown:GenerateMenu() end
                            else
                                PM_RememberDropdownText(row.dropdown, t)
                                PM_SetDropdownText(row.dropdown, t)
                            end
                        end
                        UpdateRowChangeVisual(row)
                    end)
                end)
            end
            if prov.ExportProfile then
                root:CreateButton("Export...", function()
                    addon:ShowExportPopup(prov, row.selectedProfile or row.currentLive or SafeCall(prov.GetCurrentProfile))
                end)
            end
            local deletable = GetDeletableProfiles()
            if #deletable > 0 then
                local sub = root:CreateButton("Delete profile")
                if sub.SetScrollMode then sub:SetScrollMode(20 * 20) end
                for _, name in ipairs(deletable) do
                    sub:CreateButton(PM_ProfileDisplayLabel(name), function()
                        DoDeleteProfile(name)
                    end)
                end
                root:CreateButton("Delete All Unused", function()
                    addon:ConfirmDeleteAllUnusedProfiles(providerId)
                end)
            else
                local d = root:CreateButton("Delete profile")
                d:SetEnabled(false)
            end
        end)
    end)

    Delay(0, function() LayoutEditorRow(row) end)

    return row
end

function addon:ApplySelectedFromInlineEditor()
    local f = self.MainUI
    if not f or not f.selectedPresetName then return end

    local map = {}
    local any = false

    for _, row in ipairs(f.editorRows or {}) do
        if row.providerId and not row.isMissing and row.selectChk and row.selectChk:GetChecked() then
            local cur = row.currentLive
            local sel = row.selectedProfile

            if cur ~= nil and sel ~= nil and tostring(cur) ~= tostring(sel) then
                map[row.providerId] = sel
                any = true
            end
        end
    end

    if not any then return end

    local _, _, skipped = self:ApplyProfilesMap(map)
    local notSwitched = self:DescribeSkipped(skipped)
    if notSwitched then print("|cffffd100ProfileManager|r " .. notSwitched) end
    local function RefreshLeftAndLive()
        if addon.RefreshPresetList then addon:RefreshPresetList() end
        if addon.RefreshInlineEditorLiveStates then addon:RefreshInlineEditorLiveStates() end
    end
    for _, row in ipairs(f.editorRows or {}) do
        local new = map[row.providerId]
        if new and not row.isMissing then
            row.currentLive = tostring(new)
        end
    end
    addon:RefreshInlineEditorLiveStates()
    Delay(0.1, RefreshLeftAndLive)
    addon:ShowForceReloadPopup("Selected profiles applied.\n\nSome addons require reload to apply changes")
end

function addon:SaveInlineEditor()
    local f = self.MainUI
    if not f or not f.selectedPresetName then return end

    local preset = self:GetPreset(f.selectedPresetName)
    if not preset then return end

    preset.addons = preset.addons or {}

    for _, row in ipairs(f.editorRows or {}) do
        if row.providerId and not row.isMissing then
            local checked = row.selectChk and row.selectChk:GetChecked()
            if checked then
                preset.addons[row.providerId] = row.selectedProfile
            else
                preset.addons[row.providerId] = nil
            end
        end
    end

    self:OpenInlineEditor(f.selectedPresetName)
end

function addon:CancelInlineEditor()
    local f = self.MainUI
    if not f or not f.selectedPresetName then
        self:ClearInlineEditor()
        return
    end
    self:OpenInlineEditor(f.selectedPresetName)
end

function addon:ShowExportPopup(provider, profileName, fmt)
    if not provider or not provider.ExportProfile then return end

    if provider.nativeExport and fmt == nil then
        StaticPopupDialogs["PM_EXPORT_FORMAT"] = {
            text = "Export format for: " .. PM_ProfileDisplayLabel(profileName) .. "\n\nNative = usable directly in the addon's own import.\nProfileManager = works for any profile, PM-only.",
            button1 = "Native",
            button2 = "ProfileManager",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            OnAccept = function()
                addon:ShowExportPopup(provider, profileName, "native")
            end,
            OnCancel = function(_, _, reason)
                if reason == "clicked" then
                    addon:ShowExportPopup(provider, profileName, "pm")
                end
            end,
        }
        StaticPopup_Show("PM_EXPORT_FORMAT")
        return
    end

    local text, err = provider:ExportProfile(profileName, fmt)
    if not text then
        print("|cffff5555ProfileManager|r Export failed: " .. tostring(err or "unknown reason"))
        return
    end

    StaticPopupDialogs["PM_EXPORT_PROFILE"] = {
        text = "Export profile: " .. PM_ProfileDisplayLabel(profileName),
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 420,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,

        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if not eb then
                print("|cffff5555ProfileManager|r Export popup has no editbox (template mismatch).")
                return
            end

            if eb.SetMaxLetters then eb:SetMaxLetters(0) end

            eb:SetText(text)
            eb:HighlightText()
            eb:SetFocus()

            if eb.Instructions then eb.Instructions:Hide() end
        end,
    }
    StaticPopup_Show("PM_EXPORT_PROFILE")
end

function addon:ShowImportWizard(providerId, provider, onSuccess)
    if not providerId or not provider or type(provider.ImportProfile) ~= "function" then
        print("|cffff5555ProfileManager|r This provider does not support import.")
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        print("|cffff5555ProfileManager|r Cannot import in combat.")
        return
    end

    local popupKey = "PM_IMPORT_PROFILE"

    local function GetImportDisclaimer(pid)
        if provider.nativeExport then
            return "|cff00ff00Accepts ProfileManager exports AND this addon's own native strings.|r"
        end
        return "|cffffaa00Only ProfileManager export strings are supported.|r"
    end

    if not StaticPopupDialogs[popupKey] then
        StaticPopupDialogs[popupKey] = {
            text = "Paste import string below:",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = true,
            editBoxWidth = 420,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,

            OnShow = function(self)
                local eb = self.editBox or self.EditBox
                if not eb then return end
                if eb.SetMaxLetters then eb:SetMaxLetters(0) end
                eb:SetText("")
                eb:SetFocus()
                if eb.Instructions then eb.Instructions:Hide() end
            end,

            OnAccept = function(self, data)
                local ctx = data
                if type(ctx) ~= "table" then return end

                local eb = self.editBox or self.EditBox
                local text = eb and strtrim(eb:GetText() or "") or ""
                if text == "" then
                    print("|cffff5555ProfileManager|r Missing import string.")
                    return
                end

                local prov = ctx.provider
                local pid  = ctx.providerId

                local ok, a, b = pcall(function()
                    return prov:ImportProfile(text)
                end)

                if not ok then
                    print("|cffff5555ProfileManager|r Import failed: " .. tostring(a))
                    return
                end

                if a ~= true then
                    print("|cffff5555ProfileManager|r Import failed: " .. tostring(b or a))
                    return
                end

                local newName = tostring(b or "")
                if newName == "" then newName = "Imported" end

                print("|cff00ff00ProfileManager|r Import successful (" .. tostring(pid) .. "): " .. PM_ProfileDisplayLabel(newName))

                if addon.PM_AddPendingApplyProfile then
                    addon:PM_AddPendingApplyProfile(pid, newName)
                end

                if type(ctx.onSuccess) == "function" then
                    pcall(ctx.onSuccess, newName)
                end

                if addon.RefreshMainUI then
                    addon:RefreshMainUI()
                end

                StaticPopupDialogs["PM_RELOAD_AFTER_PROFILE_IMPORT"] = {
                    text = ("Imported profile:\n\n|cffcfd0ff%s|r\n\nReload UI now to apply it?"):format(PM_ProfileDisplayLabel(newName)),
                    button1 = "Reload",
                    button2 = "Later",
                    OnAccept = ReloadUI,
                    OnCancel = function()
                        print("|cffffaa00ProfileManager|r Reload later to apply the imported profile.")
                    end,
                    timeout = 0,
                    whileDead = true,
                    hideOnEscape = true,
                }
                StaticPopup_Show("PM_RELOAD_AFTER_PROFILE_IMPORT")
            end,
        }
    end

    local disclaimer = GetImportDisclaimer(providerId)
    StaticPopupDialogs[popupKey].text = disclaimer .. "\nPaste import string below:"

    StaticPopup_Show(popupKey, nil, nil, {
        providerId = providerId,
        provider = provider,
        onSuccess = onSuccess,
    })
end

function addon:ShowPresetExportPopup(presetName)
    if type(self.ExportPreset) ~= "function" then
        print("|cffff5555ProfileManager|r Missing ExportPreset() (Presets.lua not updated?)")
        return
    end

    local text, err = self:ExportPreset(presetName)
    if not text then
        print("|cffff5555ProfileManager|r Preset export failed: " .. tostring(err or "unknown"))
        return
    end

    StaticPopupDialogs["PM_EXPORT_PRESET"] = {
        text = "Export preset: " .. tostring(presetName),
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 420,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,

        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if not eb then return end
            if eb.SetMaxLetters then eb:SetMaxLetters(0) end
            eb:SetText(text)
            eb:HighlightText()
            eb:SetFocus()
        end,
    }

    StaticPopup_Show("PM_EXPORT_PRESET")
end
function addon:SerializeAndCompress(tbl)
    if type(tbl) ~= "table" then
        return nil, "Serialize expects a table"
    end

    local serialized = LibSerialize:Serialize(tbl)
    if type(serialized) ~= "string" or serialized == "" then
        return nil, "LibSerialize:Serialize failed"
    end

    local compressed = LibDeflate:CompressDeflate(serialized, { level = 9})
    if not compressed then
        return nil, "CompressDeflate failed"
    end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    if not encoded then
        return nil, "EncodeForPrint failed"
    end

    return encoded
end

function addon:DecompressAndDeserialize(str)
    if type(str) ~= "string" or str == "" then
        return nil, "Empty import string"
    end

    local decoded = LibDeflate:DecodeForPrint(str)
    if not decoded then
        return nil, "DecodeForPrint failed (not a LibDeflate string)"
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return nil, "DecompressDeflate failed"
    end

    local ok, tbl = LibSerialize:Deserialize(decompressed)
    if not ok then
        return nil, "LibSerialize:Deserialize failed"
    end
    if type(tbl) ~= "table" then
        return nil, "Deserialize returned non-table"
    end

    return tbl
end

local function PM_EncodePresetPayload(payload)
    return addon:SerializeAndCompress(payload)
end

function addon:ShowExportSelectedPopup(exportText, title)
    StaticPopupDialogs["PM_EXPORT_SELECTED"] = {
        text = title or "Export selected addons",
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 420,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,

        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if not eb then return end
            if eb.SetMaxLetters then eb:SetMaxLetters(0) end
            eb:SetText(exportText or "")
            eb:HighlightText()
            eb:SetFocus()
            if eb.Instructions then eb.Instructions:Hide() end
        end,
    }

    StaticPopup_Show("PM_EXPORT_SELECTED")
end

function addon:ExportSelectedFromInlineEditor()
    local f = self.MainUI
    if not f or not f.selectedPresetName then return end

    local payload = {
        v = 2,
        type = "Preset",
        name = tostring(f.selectedPresetName),
        addons = {},
    }

    local added = 0

    for _, row in ipairs(f.editorRows or {}) do
        if row
            and not row.isMissing
            and row.providerId
            and row.selectChk
            and row.selectChk:GetChecked()
        then
            local prov = self.Providers and self.Providers[row.providerId]
            if prov and type(prov.ExportProfile) == "function" then
                local profName = row.selectedProfile or row.currentLive
                if profName ~= nil and profName ~= "" then
                    local ok, exportStrOrErr = pcall(function()
                        return prov:ExportProfile(profName)
                    end)

                    if ok and type(exportStrOrErr) == "string" and exportStrOrErr ~= "" then
                        payload.addons[row.providerId] = exportStrOrErr
                        added = added + 1
                    end
                end
            end
        end
    end

    if added == 0 then
        print("|cffffaa00ProfileManager|r Nothing to export (no selected addons support Export).")
        return
    end

    local exportText, err = PM_EncodePresetPayload(payload)
    if type(exportText) ~= "string" or exportText == "" then
        print("|cffff5555ProfileManager|r Export failed: " .. tostring(err or "could not encode payload"))
        return
    end

    self:ShowExportSelectedPopup(exportText, ("Export selected (%d addons)"):format(added))
end

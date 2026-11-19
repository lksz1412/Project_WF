ProfileManager = ProfileManager or {}
local addon = ProfileManager

local LDB  = LibStub("LibDataBroker-1.1", true)
local Icon = LibStub("LibDBIcon-1.0", true)
addon.Providers = addon.Providers or {}

function ProfileManager_OnAddonCompartmentClick(addonName, mouseButton, button)
    if addon.MainUI and addon.MainUI:IsShown() then
        addon.MainUI:Hide()
    else
        addon:ShowMainUI()
    end
end

function ProfileManager_OnAddonCompartmentEnter(addonName, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:AddLine("ProfileManager")
    GameTooltip:AddLine("Click to toggle UI", 1, 1, 1)
    GameTooltip:Show()
end

function ProfileManager_OnAddonCompartmentLeave(addonName, button)
    GameTooltip:Hide()
end

function addon:InitMinimapIcon()
    if not (LDB and Icon) then return end

    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.minimap = ProfileManagerDB.minimap or { hide = false }

    if not self._minimapLDB then
        self._minimapLDB = LDB:NewDataObject("ProfileManager", {
            type = "data source",
            text = "ProfileManager",
            icon = "Interface\\AddOns\\ProfileManager\\Media\\Icon.tga",

            OnClick = function(_, button)
                if button ~= "LeftButton" then return end

                if addon.MainUI and addon.MainUI:IsShown() then
                    addon.MainUI:Hide()
                else
                    addon:ShowMainUI()
                end
            end,

            OnTooltipShow = function(tt)
                tt:AddLine("ProfileManager")
                tt:AddLine("Left-click: Toggle UI", 1, 1, 1)
            end,
        })
    end

    Icon:Register("ProfileManager", self._minimapLDB, ProfileManagerDB.minimap)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    ProfileManagerDB = ProfileManagerDB or {}
    ProfileManagerDB.presets = ProfileManagerDB.presets or {}
    ProfileManagerDB.settings = ProfileManagerDB.settings or {}
    ProfileManagerDB.settings.fontSize = ProfileManagerDB.settings.fontSize or 1.0
    ProfileManagerDB.settings.scale    = ProfileManagerDB.settings.scale    or 1.0
    addon:InitMinimapIcon()
end)

function addon:RegisterProvider(id, provider)
    self.Providers[id] = provider
end

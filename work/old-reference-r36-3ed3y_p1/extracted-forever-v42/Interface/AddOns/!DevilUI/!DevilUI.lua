local addonName, FC = ...
FC = FC or {}

local PROFILE_CONFIG = {
    Wide = {
        label = "Fan Wide",
        revisions = {CastbarsDB = 3, PitBull4DB = 3, PlaterDB = 4, ChocolateBarDB = 2, MasqueDB = 2},
        leftAnchors = {
            PitBull4DB = {units = {"플레이어", "대상", "대상의 대상", "대상의 대상의 대상", "주시 대상", "주시 대상의 대상", "플레이어의 소환수"}, groups = {"파티", "파티원 대상", "파티원 소환수"}},
            CastbarsDB = {"TargetCastingBarFrame", "FocusCastingBarFrame", "PetCastingBarFrame"},
        },
    },
    Wide_B = {
        label = "Standard Wide", reflux = true,
        revisions = {DominosDB = 3, kgPanelsDB = 2, PitBull4DB = 4, CastbarsDB = 3, PlaterDB = 4, TipTac_Config = 1, ChocolateBarDB = 2, MasqueDB = 2},
        anchorRevisions = {PitBull4DB = 3, CastbarsDB = 2},
        replaceFrames = {
            PitBull4DB = {units = {"주시 대상"}},
            CastbarsDB = {frames = {"FocusCastingBarFrame", "TargetCastingBarFrame"}},
        },
        leftAnchors = {
            PitBull4DB = {units = {"플레이어", "대상", "대상의 대상", "대상의 대상의 대상", "주시 대상", "주시 대상의 대상", "플레이어의 소환수"}, groups = {"파티", "파티원 대상", "파티원 소환수"}},
            CastbarsDB = {"TargetCastingBarFrame", "FocusCastingBarFrame"},
        },
    },
    Wide_WH = {
        label = "Special Wide", reflux = true, hiddenBars = {7, 8},
        revisions = {DominosDB = 5, kgPanelsDB = 2, PitBull4DB = 6, CastbarsDB = 3, PlaterDB = 5, TipTac_Config = 2, ChocolateBarDB = 2, MasqueDB = 2},
        anchorRevisions = {PitBull4DB = 5},
        disableAggro = true,
        leftAnchors = {
            PitBull4DB = {units = {"플레이어", "주시 대상", "플레이어의 소환수"}, groups = {"파티", "파티원 대상", "파티원 소환수"}},
            CastbarsDB = {"FocusCastingBarFrame", "PetCastingBarFrame"},
        },
    },
    Wide_P = {
        label = "GamePad", reflux = true, gamepad = true, hiddenBars = {1, 10},
        revisions = {PitBull4DB = 3, DominosDB = 2, PlaterDB = 4, ChocolateBarDB = 2, MasqueDB = 2},
        disableAggro = true,
    },
    Wide_T = {
        label = "Tablet", reflux = true, gamepad = true, hiddenBars = {1, 10},
        revisions = {BrokerXPBar_DB = 3, CastbarsDB = 3, ChocolateBarDB = 3,
            DominosDB = 3, kgPanelsDB = 3, MapsterDB = 3, MasqueDB = 3,
            PitBull4DB = 4, PlaterDB = 6, RangeDisplayDB3 = 3, TipTac_Config = 4},
    },
}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end

local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            merge(target[key], value)
        else
            target[key] = value
        end
    end
end

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key, item in pairs(a) do if not equal(item, b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end

local function clear_fields(target, keys)
    for _, key in ipairs(keys) do target[key] = nil end
end
FC.Copy = copy

do

FC.GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
FC.IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
FC.LoadAddOn = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
function FC.Resolution()
    if GetPhysicalScreenSize then
        local w,h = GetPhysicalScreenSize()
        if w and h then return string.format("%dx%d",w,h) end
    end
    return string.format("%dx%d",GetScreenWidth(),GetScreenHeight())
end
end

do

function FC.GetCharacterKey()
    local name = UnitName and UnitName("player")
    local realm = GetRealmName and GetRealmName()
    if type(name) ~= "string" or name == "" or name == UNKNOWNOBJECT or
        type(realm) ~= "string" or realm == "" then return end
    return realm .. "\031" .. name
end

function FC.GetCharacterState()
    if type(DevilUIAccount) ~= "table" then DevilUIAccount = {} end
    DevilUIAccount.characters = DevilUIAccount.characters or {}
    DevilUIAccount.seeded = DevilUIAccount.seeded or {}
    DevilUIAccount.backup = DevilUIAccount.backup or {}
    DevilUIAccount.profileImports = DevilUIAccount.profileImports or {}

    if not DevilUIAccount.profileImports.Wide then
        DevilUIAccount.profileImports.Wide = copy(DevilUIAccount.seeded)
    end
    local key = FC.GetCharacterKey()
    if not key then return end
    local entry = DevilUIAccount.characters[key]
    if not entry then
        entry = {owner = key, profile = "Wide", chat = {followPanel = true}, minimap = {followPanel = true}}

        if type(DevilUILayout) == "table" and not DevilUILayout.owner and
            DevilUILayout.enabled and DevilUILayout.stage == "complete" then
            entry.legacyLayout = {chat = copy(DevilUILayout.chat), minimap = copy(DevilUILayout.minimap)}
        end
        DevilUIAccount.characters[key] = entry
    end
    DevilUILayout = entry
    return entry
end
end

do

local function SetKnownCVar(name, value)
    local api = C_CVar
    if api and api.GetCVar and api.GetCVar(name) ~= nil then api.SetCVar(name, value)
    elseif not api and GetCVar(name) ~= nil then SetCVar(name, value) end
end
local resolution = FC.Resolution()
local welcome = CreateFrame("Frame")
welcome:RegisterEvent("PLAYER_ENTERING_WORLD")
welcome:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    print("DevilUI Forever")
    print("현재 해상도:", resolution)
    print("수정 : 윈드러너 - 프리라이프 : 기본형 Fan Ver.")
    print(" ")
    for _, option in ipairs({{"screenshotQuality", 8}, {"useUiScale", 1}, {"countdownForCooldowns", 1}}) do
        SetKnownCVar(option[1], option[2])
    end
end)

for _, name in ipairs({"BNToastFrame", "TimeAlertFrame"}) do
    local frame = _G[name]
    if frame then
        frame:SetClampedToScreen(true)
        frame:SetClampRectInsets(-15, 15, 15, -15)
    end
end
end

do

FC.ProfileVariables = {
    "BrokerGuildFriendsDB", "BrokerXPBar_DB", "CastbarsDB",
    "ChocolateBarDB", "DominosDB", "kgPanelsDB", "LeaPlusDB",
    "MapsterDB", "MasqueDB", "PitBull4DB", "PlaterDB", "PlaterDBChr", "QuestieDB", "RangeDisplayDB3", "TipTac_Config",
    "DevilUIProfileOverrides",
}
FC.PreviousProfileGlobals = {}
for _, name in ipairs(FC.ProfileVariables) do
    FC.PreviousProfileGlobals[name] = _G[name]
    _G[name] = nil
end
end

function FC.FinishProfileLoad(...)

do
FC.ProfileData = {}
for _, name in ipairs(FC.ProfileVariables) do
    if type(_G[name]) == "table" then FC.ProfileData[name] = _G[name] end
    _G[name] = FC.PreviousProfileGlobals[name]
end
FC.PreviousProfileGlobals = nil

local ace_names = {"BrokerXPBar_DB", "CastbarsDB", "ChocolateBarDB", "DominosDB",
    "kgPanelsDB", "MapsterDB", "MasqueDB", "PitBull4DB", "PlaterDB", "QuestieDB", "RangeDisplayDB3"}

function FC.BuildProfileSeeds(profile)
    local found = false
    for _, name in ipairs(ace_names) do
        local source = FC.ProfileData[name]
        if source and source.profiles and source.profiles[profile] then found = true end
    end
    if not found then return nil end
    local seeds = {ace = {}, plain = {}, fallback = {}}
    if FC.ProfileData.PlaterDBChr then seeds.character = {PlaterDBChr = copy(FC.ProfileData.PlaterDBChr)} end
    for _, name in ipairs(ace_names) do
        local source = FC.ProfileData[name]
        if source and source.profiles then
            local from = source.profiles[profile] and profile or source.profiles.Wide and "Wide" or "Default"
            local entry = source.profiles[from]
            if entry then
                local target = {profiles = {[profile] = copy(entry)}, namespaces = {}}
                if from ~= profile then seeds.fallback[name] = from end
                for key, namespace in pairs(source.namespaces or {}) do
                    if namespace.profiles and namespace.profiles[from] then
                        target.namespaces[key] = {profiles = {[profile] = copy(namespace.profiles[from])}}
                    end
                end
                if name == "kgPanelsDB" and source.global then
                    local layout = entry.layout or profile
                    if source.global.layouts and source.global.layouts[layout] then
                        target.global = {layouts = {[layout] = copy(source.global.layouts[layout])}}
                        if source.global.artLibrary then target.global.artLibrary = copy(source.global.artLibrary) end
                    end
                end
                seeds.ace[name] = target
            end
        end
    end
    for _, name in ipairs({"BrokerGuildFriendsDB", "TipTac_Config", "LeaPlusDB"}) do
        if FC.ProfileData[name] then seeds.plain[name] = copy(FC.ProfileData[name]) end
    end

    local tip = FC.ProfileData.TipTac_Config
    if (profile == "Wide_WH" or profile == "Wide_B" or profile == "Wide_P" or profile == "Wide_T") and tip and tip.profiles and tip.profiles[profile] then
        seeds.ace.TipTac_Config = {profiles = {[profile] = copy(tip.profiles[profile])}, namespaces = {}}
        seeds.plain.TipTac_Config = nil
    end

    if profile == "Wide_T" and seeds.ace.TipTac_Config and FC.GetNativeDefaults then
        local defaults = FC.GetNativeDefaults(profile)
        local height
        if GetPhysicalScreenSize then local width; width, height = GetPhysicalScreenSize() end
        if type(height) == "number" and height > 0 and defaults.tooltipOffsetUI then
            seeds.ace.TipTac_Config.profiles[profile].mouseOffsetX = defaults.tooltipOffsetUI * height * (defaults.uiScale or .9) / 768
        end
    end
    local overrides = FC.ProfileData.DevilUIProfileOverrides
    if overrides and overrides[profile] then seeds.scopedPlain = copy(overrides[profile]) end
    if seeds.plain.LeaPlusDB then
        for _, key in ipairs({"MinimapModder", "MinimapMod", "SquareMinimap", "UseEasyChatResizing", "SetEditModeLayout"}) do
            seeds.plain.LeaPlusDB[key] = "Off"
        end
    end
    return seeds
end
end

do

local HUD_SETTINGS = {
    AURA_1 = {0, 0, 1, 0, 2, 0, 3, 11, 5, 5, 6, 5},
    AURA_2 = {0, 0, 1, 0, 2, 0, 4, 8, 5, 5, 6, 5, 10, 1},
    CHAT = {0, 4, 1, 30, 2, 1, 3, 20},
    OBJECTIVE = {0, 30, 1, 0, 2, 0},
    COOLDOWN_1 = {0, 0, 1, 12, 2, 1, 3, 5, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    COOLDOWN_2 = {0, 0, 1, 7, 2, 1, 3, 5, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    COOLDOWN_3 = {0, 0, 1, 1, 2, 1, 3, 5, 4, 5, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    COOLDOWN_4 = {0, 1, 1, 1, 2, 0, 3, 5, 4, 5, 5, 100, 6, 0, 7, 0, 8, 1, 9, 1, 10, 1, 11, 100},
    MINIMAP = {0, 0, 1, 0, 2, 5, 3, 5},
    MINIMAP_WH = {0, 0, 1, 0, 2, 2, 3, 2},
    CHAT_WH = {0, 3, 1, 30, 2, 1, 3, 8},
    CHAT_B = {0, 3, 1, 33, 2, 1, 3, 44},
    OBJECTIVE_B = {0, 25, 1, 0, 2, 0},
}

local function hud(system, index, anchor, packed, in_default)
    local settings = {}
    for i = 1, #packed, 2 do
        settings[#settings + 1] = {setting = packed[i], value = packed[i + 1]}
    end
    return {system = system, systemIndex = index, isInDefaultPosition = in_default,
        anchorInfo = {point = anchor[1], relativePoint = anchor[2], relativeTo = anchor[3],
            offsetX = anchor[4], offsetY = anchor[5]}, settings = settings}
end

local function chat_rect(x, y, width, height, offset_y)
    return {followPanel = false, x = x, y = y, w = width, h = height, offsetY = offset_y}
end

local CHAT_WINDOWS = {
    [1] = {name = "일반", alpha = 0, groups = {
        "SYSTEM", "SYSTEM_NOMENU", "SAY", "EMOTE", "YELL",
        "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER",
        "RAID_WARNING", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL",
        "MONSTER_EMOTE", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY",
        "BN_WHISPER", "BN_WHISPER_INFORM", "BN_CONVERSATION", "CURRENCY", "BN_WHISPER_PLAYER_OFFLINE",
        "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD_ITEM_LOOTED", "OPENING",
        "PET_INFO", "COMBAT_XP_GAIN", "COMBAT_MISC_INFO", "ENCOUNTER_EVENT",
    }},
    [2] = {name = "전투", alpha = 0.1568627450980392, groups = {
        "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN",
        "COMBAT_MISC_INFO",
    }},
}

local function layout(data)
    data.revision = data.revision or 1
    data.systemCount = #data.systems
    data.windows = data.windows or CHAT_WINDOWS
    return data
end

FC.NativeDefaults = {}

FC.NativeDefaults.Wide = layout {
    chat = chat_rect(0.002294916047394526, 0.02599811164730745, 0.1711669782663376, 0.2082030918821682),
    extraChat = {
        guildChat = chat_rect(0.1844238320457225, 0.02391493048794843, 0.2089843125373593, 0.2102864034266918),
        lootChat = chat_rect(0.7783691770482982, 0.01905375084253155, 0.210376043735814, 0.2158419101505887),
    },
    minimap = {baseSize = 235, followPanel = false, h = 0.21601562500000002, labelY = 25.214096632451913, nativeSize = 5, w = 0.12150878906250001, x = 0.6532958984375, y = 0.019140625},
    systems = {
        hud(6, 1, {"TOPLEFT", "TOPLEFT", "UIParent", 1269.5, -25}, HUD_SETTINGS.AURA_1, false),
        hud(6, 2, {"TOPRIGHT", "BOTTOMRIGHT", "BuffFrame", -15, -4}, HUD_SETTINGS.AURA_2, false),
        hud(8, nil, {"BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 35, 145}, HUD_SETTINGS.CHAT, true),
        hud(12, nil, {"RIGHT", "RIGHT", "UIParent", -2, 173.6}, HUD_SETTINGS.OBJECTIVE, false),
        hud(20, 1, {"TOP", "CENTER", "UIParent", -352.8, -2}, HUD_SETTINGS.COOLDOWN_1, false),
        hud(20, 2, {"TOPLEFT", "BOTTOMLEFT", "EssentialCooldownViewer", 0, -4}, HUD_SETTINGS.COOLDOWN_2, false),
        hud(20, 3, {"BOTTOMLEFT", "TOPLEFT", "EssentialCooldownViewer", 0, 4}, HUD_SETTINGS.COOLDOWN_3, false),
        hud(20, 4, {"BOTTOM", "BOTTOM", "UIParent", 420, 430}, HUD_SETTINGS.COOLDOWN_4, true),
        hud(2, nil, {"BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 1274.2380952380952, 21}, HUD_SETTINGS.MINIMAP, false),
    },
}
local wide = FC.NativeDefaults.Wide

FC.NativeDefaults.Wide_WH = layout {
    revision = 2,
    chat = chat_rect(0.00542, 0.028776, 0.21022954855957032, 0.1477866350260417),
    extraChat = {
        guildChat = chat_rect(0.223486, 0.027778, 0.24648440485839845, 0.14848095208333334),
        lootChat = chat_rect(0.7760259407470702, 0.022527, 0.2228760592529297, 0.15542531393229167),
    },
    minimap = {baseSize = 246.9730528247876, followPanel = false, h = 0.1593968859321876, labelY = 21.810505415156427, nativeSize = 2, w = 0.08966073739629764, x = 0.6825708815974865, y = 0.02191824858524795},
    systems = {
        hud(2, nil, {"BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 1331.3382528682403, 24.04744987638632}, HUD_SETTINGS.MINIMAP_WH, false),
        copy(wide.systems[1]),
        copy(wide.systems[2]),
        hud(8, nil, {"BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 46.2, 46.8}, HUD_SETTINGS.CHAT_WH, false),
        copy(wide.systems[4]),
        hud(3, 6, {"TOPRIGHT", "TOPRIGHT", "UIParent", -296.0, -258.0}, {3, 0, 7, 1, 16, 0}, false),
        hud(20, 1, {"BOTTOM", "BOTTOM", "UIParent", -246.1, 450.6}, {0, 0, 1, 12, 2, 1, 3, 4, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1}, false),
        hud(20, 2, {"TOPLEFT", "BOTTOMLEFT", "EssentialCooldownViewer", 0.0, -4.0}, {0, 0, 1, 7, 2, 1, 3, 5, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1}, false),
        hud(20, 3, {"BOTTOMLEFT", "TOPLEFT", "EssentialCooldownViewer", 0.0, 4.0}, {0, 0, 1, 1, 2, 1, 3, 4, 4, 5, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1}, false),
        hud(20, 4, {"TOPLEFT", "TOPLEFT", "UIParent", 1324.5, -567.0}, {0, 1, 1, 1, 2, 0, 3, 5, 4, 5, 5, 100, 6, 0, 7, 0, 8, 1, 9, 1, 10, 1, 11, 100}, false),
    },
}

FC.NativeDefaults.Wide_B = layout {
    revision = 2,
    singleChat = true,
    chat = chat_rect(0.004248048748268042, 0.1371088945741302, 0.1711669782663376, 0.2082030918821682),
    minimap = {native = true},
    systems = {
        hud(2, nil, {"RIGHT", "RIGHT", "UIParent", -2, 385}, HUD_SETTINGS.MINIMAP, false),
        hud(6, 1, {"TOPRIGHT", "TOPLEFT", "MinimapCluster", 11, 0}, HUD_SETTINGS.AURA_1, false),
        copy(wide.systems[2]),
        hud(8, nil, {"LEFT", "LEFT", "UIParent", 34, -317.5}, HUD_SETTINGS.CHAT_B, false),
        hud(12, nil, {"TOPRIGHT", "BOTTOMRIGHT", "MinimapCluster", 0, -4}, HUD_SETTINGS.OBJECTIVE_B, false),
    },
}

local pad = copy(FC.NativeDefaults.Wide_B)
pad.singleChat = nil
pad.mergeGuildChat = true
pad.chat = copy(wide.chat)
pad.chat.offsetY = 20
pad.extraChat = {lootChat = copy(wide.extraChat.lootChat)}
pad.extraChat.lootChat.offsetY = 20
pad.windows = copy(CHAT_WINDOWS)
for _, group in ipairs({"CHANNEL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT"}) do
    pad.windows[1].groups[#pad.windows[1].groups + 1] = group
end
pad.systems[4] = copy(wide.systems[3])
for i = 5, 8 do pad.systems[#pad.systems + 1] = copy(wide.systems[i]) end
pad.systems[6].anchorInfo = {point = "CENTER", relativePoint = "CENTER", relativeTo = "UIParent", offsetX = -409.2, offsetY = -97.1}
FC.NativeDefaults.Wide_P = layout(pad)

local TABLET_SETTINGS = {
    S1 = {0, 0, 1, 1, 3, 5, 4, 2},
    S2 = {0, 0, 1, 1, 3, 5, 4, 2, 9, 0},
    S3 = {0, 0, 1, 0, 2, 0},
    S4 = {0, 0, 1, 0, 2, 4, 3, 5},
    S5 = {1, 0, 16, 0},
    S6 = {2, 1, 16, 0},
    S7 = {2, 0, 3, 0, 16, 0},
    S8 = {4, 0, 5, 0, 6, 0, 10, 0, 11, 0, 12, 0, 14, 1, 16, 0, 18, 0, 19, 5, 20, 100, 21, 5, 22, 5},
    S9 = {9, 0, 10, 0, 11, 0, 12, 0, 13, 0, 14, 0, 15, 5, 16, 0, 18, 0, 19, 5, 20, 100, 21, 5, 22, 5},
    S10 = {3, 0, 7, 1, 16, 0},
    S11 = {10, 0, 11, 0, 12, 0, 17, 1, 18, 0, 19, 5, 20, 100, 21, 5, 22, 5},
    S12 = {16, 0},
    S13 = {},
    S14 = {0, 0, 1, 0, 2, 0, 3, 11, 5, 4, 6, 5},
    S15 = {0, 0, 1, 0, 2, 0, 4, 8, 5, 4, 6, 5, 10, 1},
    S16 = {0, 0, 1, 0, 2, 1, 3, 11, 5, 5, 6, 5, 8, 0, 9, 100},
    S17 = {0, 2, 1, 10, 2, 1, 3, 60},
    S18 = {0, 0, 1, 0, 2, 6},
    S19 = {0, 0, 1, 0, 2, 5},
    S20 = {3, 10},
    S21 = {0, 5},
    S22 = {0, 0},
    S23 = {0, 10},
    S24 = {0, 0, 1, 12, 2, 1, 3, 4, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    S25 = {0, 0, 1, 7, 2, 1, 3, 5, 4, 2, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    S26 = {0, 0, 1, 1, 2, 1, 3, 5, 4, 5, 5, 100, 6, 0, 8, 1, 9, 1, 10, 1},
    S27 = {0, 1, 1, 1, 2, 0, 3, 4, 4, 5, 5, 100, 6, 0, 7, 0, 8, 1, 9, 1, 10, 1, 11, 50},
    S28 = {0, 0, 2, 0, 3, 0, 4, 5, 5, 5, 6, 0, 7, 100, 8, 0, 9, 3, 10, 0, 11, 0, 12, 5, 13, 0, 14, 0},
    S29 = {0, 1, 1, 1, 2, 0, 3, 5, 4, 5, 5, 0, 6, 50, 7, 1, 8, 2, 9, 1, 10, 0, 11, 0, 12, 50, 13, 2},
    S30 = {3, 5, 4, 5, 6, 50, 7, 0, 8, 2},
    S31 = {0, 0, 1, 0, 2, 1, 3, 200, 4, 20, 5, 2, 6, 50, 8, 1, 9, 1, 10, 1, 11, 5, 12, 50},
    S32 = {0, 5, 1, 50, 2, 0, 3, 120, 4, 6, 5, 1, 6, 1},
    S33 = {0, 0, 1, 1, 2, 1, 3, 1, 4, 1},
}

FC.NativeDefaults.Wide_T = layout {
    chat = {followPanel = false, h = 0.19978210312500003, w = 0.22987428021675052, x = 0.002295, y = 0.057857},
    extraChat = {lootChat = {followPanel = false, fontSize = 14, h = 0.19057876523437503, w = 0.22987428021675052, x = 0.7701257197832495, y = 0.025649}},
    fullLayout = true,
    mergeCombatLog = false,
    mergeGuildChat = true,
    minimap = {native = true},
    restoreCombatTab = true,
    revision = 4,
    tooltipOffsetUI = 85,
    uiScale = 0.9,
    windows = {
        {name = "일반", alpha = 0, fontSize = 14,
            groups = {"SYSTEM", "SYSTEM_NOMENU", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "CHANNEL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_WHISPER_INFORM", "BN_CONVERSATION", "BN_WHISPER_PLAYER_OFFLINE", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD_ITEM_LOOTED", "ENCOUNTER_EVENT"}},
        {name = "전투", alpha = 0.1568627450980392,
            groups = {"OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_MISC_INFO"}},
    },
    systems = {
        hud(0, 11, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S1, true),
        hud(0, 12, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S2, true),
        hud(0, 13, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S1, true),
        hud(1, nil, {"BOTTOM", "TOP", "GamepadMainActionBarFrame", 0, 20}, TABLET_SETTINGS.S3, true),
        hud(2, nil, {"RIGHT", "RIGHT", "UIParent", -2.0, 276.7}, TABLET_SETTINGS.S4, false),
        hud(3, 1, {"BOTTOMRIGHT", "BOTTOM", "UIParent", -185, 295}, TABLET_SETTINGS.S5, true),
        hud(3, 2, {"BOTTOMLEFT", "BOTTOM", "UIParent", 185, 295}, TABLET_SETTINGS.S6, true),
        hud(3, 3, {"BOTTOMLEFT", "BOTTOM", "UIParent", 386, 316}, TABLET_SETTINGS.S7, true),
        hud(3, 4, {"TOPLEFT", "TOPRIGHT", "CompactRaidFrameManager", 30, -170}, TABLET_SETTINGS.S8, true),
        hud(3, 5, {"TOPLEFT", "TOPRIGHT", "CompactRaidFrameManager", 30, -150}, TABLET_SETTINGS.S9, true),
        hud(3, 6, {"RIGHT", "RIGHT", "UIParent", 0, 0}, TABLET_SETTINGS.S10, true),
        hud(3, 7, {"RIGHT", "RIGHT", "UIParent", 0, 0}, TABLET_SETTINGS.S11, true),
        hud(3, 8, {"CENTER", "CENTER", "UIParent", 0, 0}, TABLET_SETTINGS.S12, true),
        hud(4, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S13, true),
        hud(5, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S13, true),
        hud(6, 1, {"TOPRIGHT", "TOPLEFT", "MinimapCluster", 11.0, 0.0}, TABLET_SETTINGS.S14, false),
        hud(6, 2, {"TOPRIGHT", "BOTTOMRIGHT", "BuffFrame", -15.0, -4.0}, TABLET_SETTINGS.S15, false),
        hud(6, 3, {"TOP", "TOP", "UIParent", 0, -25}, TABLET_SETTINGS.S16, true),
        hud(7, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S13, true),
        hud(8, nil, {"BOTTOMLEFT", "BOTTOMLEFT", "UIParent", 2.8, 40}, TABLET_SETTINGS.S17, false),
        hud(9, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, -4}, TABLET_SETTINGS.S13, true),
        hud(10, nil, {"TOPLEFT", "TOPLEFT", "UIParent", 16, -116}, TABLET_SETTINGS.S13, true),
        hud(11, nil, {"BOTTOMRIGHT", "BOTTOMRIGHT", "UIParent", -9, 9}, TABLET_SETTINGS.S13, true),
        hud(12, nil, {"TOPRIGHT", "BOTTOMRIGHT", "MinimapCluster", 0, -4}, TABLET_SETTINGS.S3, false),
        hud(13, nil, {"RIGHT", "RIGHT", "UIParent", -2, -383.6}, TABLET_SETTINGS.S18, false),
        hud(14, nil, {"BOTTOMLEFT", "BOTTOMRIGHT", "MicroMenuContainer", 7, -4}, TABLET_SETTINGS.S19, true),
        hud(15, 1, {"BOTTOM", "BOTTOM", "StatusTrackingBarManager", 0, 0}, TABLET_SETTINGS.S20, true),
        hud(15, 2, {"BOTTOM", "BOTTOM", "StatusTrackingBarManager", 0, 17}, TABLET_SETTINGS.S20, true),
        hud(16, nil, {"RIGHT", "RIGHT", "UIParent", 0, 0}, TABLET_SETTINGS.S21, true),
        hud(17, nil, {"TOP", "TOP", "UIParent", 0, -100}, TABLET_SETTINGS.S22, true),
        hud(18, nil, {"RIGHT", "RIGHT", "UIParent", 0, 0}, TABLET_SETTINGS.S23, true),
        hud(19, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, 0}, TABLET_SETTINGS.S22, true),
        hud(20, 1, {"LEFT", "CENTER", "UIParent", 2, -353.9}, TABLET_SETTINGS.S24, false),
        hud(20, 2, {"BOTTOMRIGHT", "BOTTOMLEFT", "EssentialCooldownViewer", -4, 0}, TABLET_SETTINGS.S25, false),
        hud(20, 3, {"BOTTOMLEFT", "BOTTOMRIGHT", "EssentialCooldownViewer", 4, 0}, TABLET_SETTINGS.S26, false),
        hud(20, 4, {"TOPLEFT", "TOPLEFT", "UIParent", 867.7, -248}, TABLET_SETTINGS.S27, false),
        hud(21, nil, {"BOTTOM", "BOTTOM", "UIParent", -410, 380}, TABLET_SETTINGS.S28, true),
        hud(22, 1, {"BOTTOMRIGHT", "BOTTOM", "UIParent", -457, 336}, TABLET_SETTINGS.S29, true),
        hud(22, 2, {"TOP", "TOP", "UIParent", 0, -40}, TABLET_SETTINGS.S30, true),
        hud(22, 3, {"TOP", "TOP", "UIParent", 0, -90}, TABLET_SETTINGS.S30, true),
        hud(22, 4, {"TOP", "TOP", "UIParent", 0, -130}, TABLET_SETTINGS.S30, true),
        hud(23, nil, {"TOPLEFT", "TOPLEFT", "UIParent", 0, 0}, TABLET_SETTINGS.S31, true),
        hud(24, nil, {"TOP", "TOP", "UIParent", 0, -182}, TABLET_SETTINGS.S13, true),
        hud(25, nil, {"RIGHT", "BOTTOM", "UIParent", -28, 128}, TABLET_SETTINGS.S13, true),
        hud(26, 1, {"TOPLEFT", "TOPLEFT", "UIParent", -26, 5}, TABLET_SETTINGS.S22, false),
        hud(26, 2, {"LEFT", "RIGHT", "BagsBar", -30, 5}, TABLET_SETTINGS.S22, true),
        hud(27, nil, {"CENTER", "CENTER", "Minimap", -68, -68}, TABLET_SETTINGS.S23, true),
        hud(28, nil, {"CENTER", "CENTER", "UIParent", 0, 0}, TABLET_SETTINGS.S21, true),
        hud(29, 1, {"BOTTOM", "BOTTOM", "UIParent", 0, 450}, TABLET_SETTINGS.S32, true),
        hud(29, 2, {"BOTTOM", "BOTTOM", "UIParent", 0, 425}, TABLET_SETTINGS.S32, true),
        hud(29, 3, {"BOTTOM", "BOTTOM", "UIParent", 0, 400}, TABLET_SETTINGS.S32, true),
        hud(30, nil, {"BOTTOM", "BOTTOM", "UIParent", 0, 110}, TABLET_SETTINGS.S33, true),
    },
}

function FC.GetNativeDefaults(profile)
    return FC.NativeDefaults[profile] or FC.NativeDefaults.Wide
end
end

do

local name_revision = 14

function FC.GetNativeInterfaceStyle(profile)
    local styles = Enum and Enum.InputDeviceInterfaceType
    if styles then
        local config = PROFILE_CONFIG[profile]
        return config and config.gamepad and styles.Gamepad or styles.Mkb
    end
end

function FC.GetCurrentInterfaceStyle()
    local styles = Enum and Enum.InputDeviceInterfaceType
    if not styles then return end
    if InputUtil and InputUtil.GetCurrentInterfaceStyle then return InputUtil.GetCurrentInterfaceStyle() end
    if InputUtil and InputUtil.IsGamepadUIEnabled then
        return InputUtil.IsGamepadUIEnabled() and styles.Gamepad or styles.Mkb
    end
    local get = C_CVar and C_CVar.GetCVar or GetCVar
    local value = get and tonumber(get("InputDeviceInterfaceStyle"))
    return value == styles.Gamepad and styles.Gamepad or styles.Mkb
end

function FC.IsNativeStyleCurrent(profile)
    local wanted = FC.GetNativeInterfaceStyle(profile)
    return wanted == nil or wanted == FC.GetCurrentInterfaceStyle()
end

local function context(read_only)
    local api = C_EditMode
    if InCombatLockdown() then return nil, "전투 종료를 기다립니다." end
    if not api or not api.GetLayouts or not api.SaveLayouts or not api.SetActiveLayout or
        not EditModePresetLayoutManager or not EditModePresetLayoutManager.GetCopyOfPresetLayouts then return nil, "편집 모드 초기화를 기다립니다." end
    if not read_only and FC.IsEditModeActive and FC.IsEditModeActive() then return nil, "편집 모드를 닫으면 설치를 마무리합니다." end

    local layouts = copy(api.GetLayouts())
    if not layouts or type(layouts.layouts) ~= "table" then return nil, "편집 모드 목록을 기다립니다." end
    local presets = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    if type(presets) ~= "table" or #presets == 0 then return nil, "기본 편집 모드 구성을 기다립니다." end
    return {api = api, layouts = layouts, presets = presets, preset_count = #presets}
end

local function has_style(info, style)
    if style == nil then return true end
    local styles = Enum.InputDeviceInterfaceType
    return info and (info.interfaceStyle == style or (style == styles.Mkb and info.interfaceStyle == nil))
end

local function preset_for_style(ctx, style)
    for i, preset in ipairs(ctx.presets) do
        if has_style(preset, style) then return preset, i end
    end
end

local function active_info(ctx)
    local index = ctx.layouts.activeLayout
    return index <= ctx.preset_count and ctx.presets[index] or ctx.layouts.layouts[index - ctx.preset_count]
end

function FC.IsNativeLayoutActive(settings)
    if not FC.IsNativeStyleCurrent(settings.profile) then return false end
    local ctx = context(true)
    if not ctx then return false end
    local active = active_info(ctx)
    return active and active.layoutType ~= Enum.EditModeLayoutType.Preset and
        active.layoutName == (settings.nativeLayoutName or settings.profile) and
        has_style(active, FC.GetNativeInterfaceStyle(settings.profile)) or false
end

function FC.GetMinimapIconPercent()
    local ctx, reason = context(true)
    if not ctx then return nil, nil, false, reason end
    local info = active_info(ctx)
    if not info then return nil, nil, false, "현재 편집 모드 구성을 기다립니다." end
    local id = Enum.EditModeMinimapSetting and Enum.EditModeMinimapSetting.IconScale
    if id == nil then return nil, nil, false, "미니맵 아이콘 설정을 기다립니다." end
    local raw = 5
    for _, system in ipairs(info.systems or {}) do
        if system.system == Enum.EditModeSystem.Minimap then
            for _, setting in ipairs(system.settings or {}) do
                if setting.setting == id then raw = setting.value; break end
            end
            break
        end
    end
    if type(raw) ~= "number" then return nil, nil, false, "미니맵 아이콘 설정을 읽지 못했습니다." end
    local editable = ctx.layouts.activeLayout > ctx.preset_count and info.layoutType ~= Enum.EditModeLayoutType.Preset
    local notice
    if not editable then notice = "편집 모드에서 사용자 레이아웃을 선택하세요."
    elseif FC.IsEditModeActive() then editable = false; notice = "편집 모드를 닫은 뒤 저장하세요."
    elseif FC.NativeSessionDirty then editable = false; notice = "UI 재시작 후 저장하세요." end
    return 50 + raw * 10, info.layoutName, editable, notice
end

local function save_icon_percent(percent, expected_name)
    if FC.NativeSessionDirty then return false, "UI 재시작을 마친 뒤 다시 조절하세요." end
    if type(percent) ~= "number" or percent ~= percent or percent < 50 or percent > 200 then
        return false, "아이콘 크기는 50~200% 범위에서 선택하세요."
    end
    local ctx, reason = context()
    if not ctx then return false, reason end
    local index = ctx.layouts.activeLayout - ctx.preset_count
    local info = ctx.layouts.layouts[index]
    if not info or info.layoutType == Enum.EditModeLayoutType.Preset then
        return false, "편집 모드에서 사용자 레이아웃을 선택하세요."
    end
    if expected_name and info.layoutName ~= expected_name then return false, "선택한 레이아웃이 바뀌었습니다. 값을 다시 선택하세요." end
    local id = Enum.EditModeMinimapSetting and Enum.EditModeMinimapSetting.IconScale
    if id == nil then return false, "미니맵 아이콘 설정을 기다립니다." end
    local minimap
    for _, system in ipairs(info.systems or {}) do
        if system.system == Enum.EditModeSystem.Minimap then minimap = system; break end
    end
    if not minimap then return false, "현재 레이아웃의 미니맵 설정을 기다립니다." end
    local raw = math.floor((percent - 50) / 10 + .5)
    minimap.settings = minimap.settings or {}
    local entry
    for _, setting in ipairs(minimap.settings) do if setting.setting == id then entry = setting; break end end
    if entry and entry.value == raw then return true, false end
    if entry then entry.value = raw else minimap.settings[#minimap.settings + 1] = {setting = id, value = raw} end
    FC.NativeSessionDirty = true
    ctx.api.SaveLayouts(ctx.layouts)
    return true, true
end

function FC.SaveMinimapIconPercent(percent, expected_name)
    local ok, ready, result = pcall(save_icon_percent, percent, expected_name)
    if not ok then return false, "미니맵 아이콘 설정 저장 중 오류: " .. tostring(ready) end
    return ready, result
end

local selected
local function target_for_style(ctx, original, style)
    if style == nil then return copy(original) end
    local preset = preset_for_style(ctx, style)
    if not preset then return end
    local target
    if has_style(original, style) then
        target = copy(original)
    else
        target = copy(preset)
        target.layoutIndex = nil
        if original then
            target.layoutType = original.layoutType
            for i, system in ipairs(target.systems) do
                for _, prior in ipairs(original.systems or {}) do
                    if system.system == prior.system and system.systemIndex == prior.systemIndex then
                        target.systems[i] = copy(prior); break
                    end
                end
            end
        end
    end

    if style == Enum.InputDeviceInterfaceType.Gamepad then
        for _, system in ipairs(preset.systems) do
            local found
            for _, prior in ipairs(target.systems) do
                if system.system == prior.system and system.systemIndex == prior.systemIndex then found = true; break end
            end
            if not found then target.systems[#target.systems + 1] = copy(system) end
        end
    end
    for _, prior in ipairs(original and original.systems or {}) do
        if selected(prior) then
            local found
            for _, system in ipairs(target.systems) do
                if system.system == prior.system and system.systemIndex == prior.systemIndex then found = true; break end
            end
            if not found then target.systems[#target.systems + 1] = copy(prior) end
        end
    end
    target.interfaceStyle = style
    return target
end

local function find_name(ctx, name)
    local best, score
    local style = PROFILE_CONFIG[name] and FC.GetNativeInterfaceStyle(name)
    for i, entry in ipairs(ctx.layouts.layouts) do
        if entry.layoutName == name and entry.layoutType ~= Enum.EditModeLayoutType.Preset then
            local rank = (has_style(entry, style) and 4 or 0) +
                (entry.layoutType == Enum.EditModeLayoutType.Account and 2 or 0) +
                (i + ctx.preset_count == ctx.layouts.activeLayout and 1 or 0)
            if not score or rank > score then best, score = i, rank end
        end
    end
    return best
end

local function legacy_name(name, profile)
    if type(name) ~= "string" then return false end
    for _, prefix in ipairs({"DevilUI " .. profile, "DevilUI_" .. profile}) do
        if name == prefix then return true end
        if name:sub(1, #prefix + 1) == prefix .. " " and name:sub(#prefix + 2):match("^%d+$") then return true end
    end
    return false
end

local function legacy_index(ctx, settings)
    local registry = DevilUIAccount.nativeLayouts or {}
    local known = registry[settings.profile]
    local active = ctx.layouts.layouts[ctx.layouts.activeLayout - ctx.preset_count]
    for _, name in ipairs({settings.nativePendingName or "", settings.nativeLayoutName or "",
        active and active.layoutName or "", known and known.name or ""}) do
        if legacy_name(name, settings.profile) then
            local index = find_name(ctx, name)
            if index then return index end
        end
    end
    for i, info in ipairs(ctx.layouts.layouts) do
        if legacy_name(info.layoutName, settings.profile) then return i end
    end
end

local function record(settings, info, revision)
    DevilUIAccount.nativeLayouts = DevilUIAccount.nativeLayouts or {}
    DevilUIAccount.nativeLayouts[settings.profile] = {name = info.layoutName, revision = revision}
    settings.nativeLayoutName = info.layoutName
    settings.nativeNameRevision = name_revision
    settings.nativePendingName = nil
end

function FC.HasSavedNativeLayout(profile)
    local ctx = context(true)
    return ctx and (find_name(ctx, profile) or legacy_index(ctx, {profile = profile})) ~= nil or false
end

local function reuse_layout(ctx, settings, index, revision)
    local original = ctx.layouts.layouts[index]
    local style = FC.GetNativeInterfaceStyle(settings.profile)
    local target = copy(original)
    if not has_style(original, style) then
        target = target_for_style(ctx, original, style)
        if not target then return false, "입력 방식에 맞는 편집 모드 구성을 기다립니다." end
    end
    target.layoutName = settings.profile
    if not equal(target, original) then
        ctx.layouts.layouts[index] = target
        FC.NativeSessionDirty = true
        ctx.api.SaveLayouts(ctx.layouts)
    end
    local activate = FC.IsNativeStyleCurrent(settings.profile)
    if activate and ctx.layouts.activeLayout ~= index + ctx.preset_count then
        FC.NativeSessionDirty = true
        ctx.api.SetActiveLayout(index + ctx.preset_count)
    end
    local after = ctx.api.GetLayouts()
    if not after or (activate and after.activeLayout ~= index + ctx.preset_count) then
        return false, "편집 모드 구성 선택을 기다립니다."
    end
    record(settings, target, revision)
    settings.nativeRevision, settings.nativeReady = revision, true
    settings.nativeAwaitingSelection = not activate or nil
    settings.chat.followNative = true
    settings.nativeMinimapRevision = not settings.minimap.native and 1 or nil
    settings.geometryRevision = 12
    return true
end

selected = function(info)
    local system = Enum.EditModeSystem
    if info.system == system.ObjectiveTracker or info.system == system.ChatFrame or info.system == system.CooldownViewer or info.system == system.Minimap then return true end
    local unit = Enum.EditModeUnitFrameSystemIndices
    if info.system == system.UnitFrame and unit and info.systemIndex == unit.Boss then return true end
    local aura = Enum.EditModeAuraFrameSystemIndices
    return info.system == system.AuraFrame and (info.systemIndex == aura.BuffFrame or info.systemIndex == aura.DebuffFrame)
end

local function adjust_chat(info, settings)
    if info.system ~= Enum.EditModeSystem.ChatFrame then return end
    local cfg = settings.chat
    local w, h = UIParent:GetWidth(), UIParent:GetHeight()
    if cfg.followPanel then return end
    info.isInDefaultPosition = false
    info.anchorInfo2 = nil
    info.anchorInfo = {point = "BOTTOMLEFT", relativePoint = "BOTTOMLEFT", relativeTo = "UIParent", offsetX = cfg.x * w, offsetY = cfg.y * h + (cfg.offsetY or 0)}
    local width, height = math.floor(cfg.w * w + .5), math.floor(cfg.h * h + .5)
    local ids = Enum.EditModeChatFrameSetting
    local dimensions = {
        {setting = ids.WidthHundreds, value = math.floor(width / 100)},
        {setting = ids.WidthTensAndOnes, value = width % 100},
        {setting = ids.HeightHundreds, value = math.floor(height / 100)},
        {setting = ids.HeightTensAndOnes, value = height % 100},
    }
    info.settings = info.settings or {}
    for _, value in ipairs(dimensions) do
        local found
        for _, previous in ipairs(info.settings) do
            if previous.setting == value.setting then previous.value = value.value; found = true; break end
        end
        if not found then info.settings[#info.settings + 1] = value end
    end
end

function FC.CommitNativeChat(settings)
    local ctx, reason = context()
    if not ctx then return false, reason end
    if not FC.IsNativeLayoutActive(settings) then return false, "현재 프로필의 편집 모드 구성을 선택하세요." end
    local info = active_info(ctx)
    for _, system in ipairs(info.systems) do
        if system.system == Enum.EditModeSystem.ChatFrame then
            adjust_chat(system, settings)
            FC.NativeSessionDirty = true
            ctx.api.SaveLayouts(ctx.layouts)
            settings.chat.nativeDirty = nil
            settings.chat.followNative = true
            return true
        end
    end
    return false, "편집 모드의 채팅창 항목을 기다립니다."
end

local function apply(settings)
    local ctx, reason = context()
    if not ctx then return false, reason end
    local api, layouts = ctx.api, ctx.layouts
    local defaults = FC.GetNativeDefaults(settings.profile)
    local existing = find_name(ctx, settings.profile) or legacy_index(ctx, settings)
    if existing then return reuse_layout(ctx, settings, existing, defaults.revision) end
    if type(defaults.systems) ~= "table" then return false, "저장된 편집 모드 구성을 읽지 못했습니다." end
    local sources = defaults.systems
    if defaults.preset == "Classic" then
        local classic
        for _, preset in ipairs(ctx.presets) do
            if preset.layoutIndex == Enum.EditModePresetLayouts.Classic or
                (LAYOUT_STYLE_CLASSIC and preset.layoutName == LAYOUT_STYLE_CLASSIC) then classic = preset; break end
        end
        if not classic then return false, "클래식 사전 설정 초기화를 기다립니다." end
        sources = copy(defaults.systems)
        local system, aura = Enum.EditModeSystem, Enum.EditModeAuraFrameSystemIndices
        for _, info in ipairs(classic.systems) do
            if info.system == system.Minimap or info.system == system.ObjectiveTracker or
                (info.system == system.AuraFrame and (info.systemIndex == aura.BuffFrame or info.systemIndex == aura.DebuffFrame)) then
                sources[#sources + 1] = copy(info)
            end
        end
    end
    local replacements = {}
    for _, info in ipairs(sources) do
        if defaults.fullLayout or selected(info) then replacements[#replacements + 1] = copy(info) end
    end
    if #replacements ~= (defaults.systemCount or 8) then return false, "편집 모드 구성의 필수 항목을 확인하지 못했습니다." end
    local name = settings.profile
    if api.IsValidLayoutName and not api.IsValidLayoutName(name) then return false, "편집 모드에서 사용할 수 없는 프로필 이름입니다." end

    local active = active_info(ctx)
    local style = FC.GetNativeInterfaceStyle(settings.profile)
    local target = target_for_style(ctx, active, style)
    if not target or type(target.systems) ~= "table" then return false, "현재 편집 모드 구성을 기다립니다." end
    local activate = FC.IsNativeStyleCurrent(settings.profile)
    local counts = {}
    for _, info in ipairs(layouts.layouts) do counts[info.layoutType] = (counts[info.layoutType] or 0) + 1 end
    local limit = Constants and Constants.EditModeConsts and Constants.EditModeConsts.EditModeMaxLayoutsPerType or 5
    local account, character = Enum.EditModeLayoutType.Account, Enum.EditModeLayoutType.Character
    target.layoutType = (counts[account] or 0) < limit and account or character
    if (counts[target.layoutType] or 0) >= limit then return false, "편집 모드의 저장 공간이 가득 찼습니다. 구성 하나를 비운 뒤 /devilui install을 실행하세요." end
    local index = #layouts.layouts + 1
    if target.layoutType == account then
        for i, info in ipairs(layouts.layouts) do if info.layoutType == character then index = i; break end end
    end
    target.layoutName = name
    for _, replacement in ipairs(replacements) do
        adjust_chat(replacement, settings)
        local replaced = false
        for i, info in ipairs(target.systems) do
            if info.system == replacement.system and info.systemIndex == replacement.systemIndex then

                local seen = {}
                for _, value in ipairs(replacement.settings) do seen[value.setting] = true end
                for _, value in ipairs(not defaults.preset and info.settings or {}) do
                    if not seen[value.setting] then replacement.settings[#replacement.settings + 1] = copy(value) end
                end
                target.systems[i] = replacement; replaced = true; break
            end
        end
        if not replaced then target.systems[#target.systems + 1] = replacement end
    end
    table.insert(layouts.layouts, index, target)
    if layouts.activeLayout >= index + ctx.preset_count then layouts.activeLayout = layouts.activeLayout + 1 end
    if not settings.nativeBackup and active then settings.nativeBackup = {layoutName = active.layoutName, activeLayout = layouts.activeLayout} end

    local fallback
    if not activate and not has_style(active_info(ctx), FC.GetCurrentInterfaceStyle()) then
        local _, preset_index = preset_for_style(ctx, FC.GetCurrentInterfaceStyle())
        fallback = preset_index
        if not fallback then return false, "현재 입력 방식의 기본 편집 구성을 기다립니다." end
        layouts.activeLayout = fallback
    end
    settings.nativePendingName = name
    FC.NativeSessionDirty = true
    api.SaveLayouts(layouts)
    if api.OnLayoutAdded then api.OnLayoutAdded(index + ctx.preset_count, activate, true) end
    local chosen = index + ctx.preset_count
    if activate and api.GetLayouts().activeLayout ~= chosen then
        FC.NativeSessionDirty = true
        api.SetActiveLayout(chosen)
    elseif not activate and api.GetLayouts().activeLayout ~= layouts.activeLayout then
        FC.NativeSessionDirty = true
        api.SetActiveLayout(layouts.activeLayout)
    end
    local after = api.GetLayouts()
    if not after or (activate and after.activeLayout ~= chosen) then return false, "편집 모드 구성 선택을 기다립니다." end
    local set = C_CVar and C_CVar.SetCVar or SetCVar
    if not set then return false, "재사용 대기시간 관리자 설정을 기다립니다." end
    local get = C_CVar and C_CVar.GetCVar or GetCVar
    if not get or get("cooldownViewerEnabled") ~= "1" then
        FC.NativeSessionDirty = true
        set("cooldownViewerEnabled", "1")
    end
    record(settings, target, defaults.revision)
    settings.nativeRevision = defaults.revision
    settings.nativeReady = true
    settings.nativeAwaitingSelection = not activate or nil
    settings.chat.followNative = true
    return true
end

function FC.ApplyNativeDefaults(settings)
    if settings.nativeReady then return true end
    local ok, ready, reason = pcall(apply, settings)
    if not ok then return false, "편집 모드 설정 적용 중 오류: " .. tostring(ready) end
    return ready, reason
end

local function migrate_name(settings)
    local ctx, reason = context()
    if not ctx then return false, reason end
    local index = find_name(ctx, settings.profile)
    local legacy = legacy_index(ctx, settings)
    if not index then
        index = legacy
        if not index then settings.nativeNameRevision = name_revision; return true end
        ctx.layouts.layouts[index].layoutName = settings.profile
        FC.NativeSessionDirty = true
        ctx.api.SaveLayouts(ctx.layouts)
    end

    if legacy and ctx.layouts.activeLayout == legacy + ctx.preset_count and index ~= legacy and
        FC.IsNativeStyleCurrent(settings.profile) and has_style(ctx.layouts.layouts[index], FC.GetCurrentInterfaceStyle()) then
        FC.NativeSessionDirty = true
        ctx.api.SetActiveLayout(index + ctx.preset_count)
    end
    record(settings, ctx.layouts.layouts[index], settings.nativeRevision)
    return true
end

function FC.UpgradeNativeLayoutName(settings)
    if FC.NativeSessionDirty then return false end
    if settings.nativeNameRevision == name_revision then return true end
    local ok, ready, reason = pcall(migrate_name, settings)
    if not ok or not ready then
        local message = tostring(ok and reason or ready)
        if settings.nativeNameNotice ~= message then print("DevilUI: " .. message); settings.nativeNameNotice = message end
        return false
    end
    settings.nativeNameNotice = nil
    if FC.NativeSessionDirty then
        if not FC.NativeReloadRequested then
            FC.NativeReloadRequested = true
            print("DevilUI: 편집 모드 구성 이름을 " .. settings.profile .. "로 정리했습니다. UI를 재시작합니다.")
            ReloadUI()
        end
        return false
    end
    return true
end
end

end

function FC.LoadChatSetup(...)

do

FC.ExtraChatWindows = {
    {key = "guildChat", name = "길드&귓말", panel = "chat2", point = "BOTTOMRIGHT", x = -196,
        groups = {"WHISPER", "GUILD", "OFFICER", "CHANNEL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_CONVERSATION"}},
    {key = "lootChat", name = "전리품&경험치", panel = "chat3", point = "BOTTOMLEFT", x = 546,
        groups = {"COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY", "CURRENCY", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN"}},
}

local function window_limit()
    return Constants and Constants.ChatFrameConstants and Constants.ChatFrameConstants.MaxChatWindows or NUM_CHAT_WINDOWS or 10
end

function FC.GetExtraChatDefinitions()
    local defaults = FC.GetNativeDefaults(DevilUILayout.profile)
    local result = {}
    for _, definition in ipairs(FC.ExtraChatWindows) do
        if not defaults.singleChat and not (defaults.mergeGuildChat and definition.key == "guildChat") then result[#result + 1] = definition end
    end
    return result
end

function FC.GetExtraChatDefault(key)
    local defaults = FC.GetNativeDefaults(DevilUILayout.profile)
    return defaults.extraChat and FC.Copy(defaults.extraChat[key]) or {followPanel = true}
end

local placement_fields = {"followPanel", "x", "y", "w", "h", "offsetY", "baseSize"}
local placement_keys = {"chat", "minimap", "guildChat", "lootChat"}

function FC.SaveSharedPlacement(settings)
    DevilUIAccount.placements = DevilUIAccount.placements or {}
    local saved = {}
    for _, key in ipairs(placement_keys) do
        local cfg = settings[key]
        if cfg then
            saved[key] = {}
            for _, field in ipairs(placement_fields) do saved[key][field] = cfg[field] end
        end
    end
    DevilUIAccount.placements[settings.profile] = saved
end

function FC.RestoreSharedPlacement(settings)
    local saved = DevilUIAccount.placements and DevilUIAccount.placements[settings.profile]
    if not saved then
        for _, previous in pairs(DevilUIAccount.characters or {}) do
            if previous ~= settings and previous.profile == settings.profile and previous.stage == "complete" then
                saved = previous
                break
            end
        end
    end
    for _, key in ipairs(placement_keys) do
        local cfg, previous = settings[key], saved and saved[key]
        if cfg and previous then
            for _, field in ipairs(placement_fields) do cfg[field] = previous[field] end
        end
    end
end

function FC.UpdateExtraChatDefaults()
    if FC.GetNativeDefaults(DevilUILayout.profile).singleChat then return end
    for _, definition in ipairs(FC.GetExtraChatDefinitions()) do
        local previous = DevilUILayout[definition.key]
        local cfg = FC.GetExtraChatDefault(definition.key)
        cfg.frameId, cfg.name = previous and previous.frameId, previous and previous.name
        DevilUILayout[definition.key] = cfg
    end
end
local function chat_frame(id)
    return FCF_GetChatFrameByID and FCF_GetChatFrameByID(id) or _G["ChatFrame" .. id]
end
local function window_info(id)
    local get = FCF_GetChatWindowInfo or GetChatWindowInfo
    if not get then return end
    local name, _, _, _, _, _, shown = get(id)
    local frame = chat_frame(id)
    return name, frame and not frame.isTemporary and (shown or frame.isDocked)
end
local function find_window(name)
    for id = 3, window_limit() do
        local title, active = window_info(id)
        if active and title == name then return chat_frame(id) end
    end
end

function FC.GetExtraChatFrame(definition)
    if DevilUILayout and FC.GetNativeDefaults(DevilUILayout.profile).singleChat then return end
    if DevilUILayout and FC.GetNativeDefaults(DevilUILayout.profile).mergeGuildChat and definition.key == "guildChat" then return end
    local saved = DevilUILayout and DevilUILayout[definition.key]
    local id = saved and saved.frameId
    if type(id) ~= "number" or id < 3 or id > window_limit() then return end
    local title, active = window_info(id)

    if active and title == definition.name then return chat_frame(id) end
end

function FC.CloseExtraChatWindows(disabled_only)
    local windows = {}
    local close_keys = {}
    local enabled = {}
    for _, definition in ipairs(FC.GetExtraChatDefinitions()) do enabled[definition.key] = true end
    for _, definition in ipairs(FC.ExtraChatWindows) do
        if not disabled_only or not enabled[definition.key] then
            close_keys[#close_keys + 1] = definition.key
            local frame = find_window(definition.name)
            if frame then windows[#windows + 1] = frame end
        end
    end
    if #windows > 0 and not FCF_Close then return false, "기본 채팅창 닫기 기능을 기다립니다." end
    if #windows > 0 or not disabled_only then FC.ChatSessionDirty = true end
    for _, frame in ipairs(windows) do
        FCF_Close(frame)
        if SetChatWindowShown then SetChatWindowShown(frame:GetID(), false) end
    end
    for _, key in ipairs(close_keys) do DevilUILayout[key] = nil end
    return true
end

local function place(frame, point, relative, relative_point, x, y)
    local clear = frame.ClearAllPointsBase or frame.ClearAllPoints
    local set = frame.SetPointBase or frame.SetPoint
    clear(frame)
    set(frame, point, relative, relative_point, x, y)
end

function FC.ApplyExtraChatLayout(get_panel)
    if FC.GetNativeDefaults(DevilUILayout.profile).singleChat then return end
    for _, definition in ipairs(FC.GetExtraChatDefinitions()) do
        local chat = FC.GetExtraChatFrame(definition)

        if chat and not chat.isDocked then
            local cfg = DevilUILayout[definition.key]
            local set_scale = chat.SetScaleBase or chat.SetScale
            set_scale(chat, 1)
            if chat.SetResizeBounds then chat:SetResizeBounds(100, 70) end
            if chat.SetClampedToScreen then chat:SetClampedToScreen(true) end
            if cfg.followPanel then
                local target = get_panel and get_panel(definition.panel)
                if target then
                    local ratio = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
                    place(chat, "BOTTOMLEFT", target, "BOTTOMLEFT", 6, 10)
                    chat:SetSize(math.max(100, target:GetWidth() * ratio - 14), math.max(70, target:GetHeight() * ratio - 28))
                else

                    local data = FC.ProfileData and FC.ProfileData.kgPanelsDB
                    local layouts = data and data.global and data.global.layouts
                    local layout = layouts and layouts[DevilUILayout.panelLayout or "Wide"]
                    local seed = layout and layout[definition.panel]
                    local w, h = seed and tonumber(seed.width), seed and tonumber(seed.height)
                    if w and h and seed.anchor == "UIParent" then
                        local inset = seed.anchorFrom:find("RIGHT") and -8 or 6
                        place(chat, seed.anchorFrom, UIParent, seed.anchorTo, (tonumber(seed.x) or 0) + inset, (tonumber(seed.y) or 0) + 10)
                        chat:SetSize(math.max(100, w - 14), math.max(70, h - 28))
                    else
                        place(chat, definition.point, UIParent, "BOTTOM", definition.x, 27)
                        chat:SetSize(definition.key == "guildChat" and 416 or 421, 217)
                    end
                end
            else
                local w, h = UIParent:GetWidth(), UIParent:GetHeight()
                place(chat, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", cfg.x * w, cfg.y * h + (cfg.offsetY or 0))
                chat:SetSize(cfg.w * w, cfg.h * h)
            end
            if chat.SetUserPlaced then chat:SetUserPlaced(true) end
            if FCF_SavePositionAndDimensions then FCF_SavePositionAndDimensions(chat) end
        end
    end
end

function FC.ConfigureExtraChat()
    if InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty then return false, "전투와 편집 모드를 종료한 뒤 다시 실행하세요." end
    if FC.GetNativeDefaults(DevilUILayout.profile).singleChat then return FC.CloseExtraChatWindows() end
    if not FCF_OpenNewWindow or not FCF_UnDockFrame or not (FCF_GetChatWindowInfo or GetChatWindowInfo) then
        return false, "기본 채팅 UI의 초기화를 기다립니다."
    end
    local remove_general = ChatFrame1 and (ChatFrame1.RemoveMessageGroup or ChatFrame_RemoveMessageGroup)
    if not remove_general then return false, "기본 채팅 UI의 초기화를 기다립니다." end
    local closed, close_reason = FC.CloseExtraChatWindows(true)
    if not closed then return false, close_reason end
    local definitions = FC.GetExtraChatDefinitions()
    local windows, missing, free = {}, 0, 0
    for index, definition in ipairs(definitions) do
        windows[index] = find_window(definition.name)
        if not windows[index] then missing = missing + 1 end
    end
    local reserved = C_ChatInfo and C_ChatInfo.GetNumReservedChatWindows and C_ChatInfo.GetNumReservedChatWindows() or 2
    for id = math.max(3, reserved + 1), window_limit() do
        local _, active = window_info(id)
        local frame = chat_frame(id)
        if frame and not active and not frame.isTemporary then free = free + 1 end
    end
    if free < missing then return false, "새 채팅창을 만들 빈 자리가 없습니다. 사용하지 않는 채팅 탭을 닫은 뒤 /devilui chat을 실행하세요." end
    FC.ChatSessionDirty = true

    local has_channels = false
    for _, group in pairs(ChatFrame1.messageTypeList or {}) do
        if group == "CHANNEL" then has_channels = true; break end
    end
    local add_general = ChatFrame1.AddMessageGroup or ChatFrame_AddMessageGroup
    if not has_channels and ChatTypeGroup and ChatTypeGroup.CHANNEL and add_general then add_general(ChatFrame1, "CHANNEL") end
    for index, definition in ipairs(definitions) do
        local chat = windows[index] or FCF_OpenNewWindow(definition.name, true)
        if not chat then return false, "채팅창을 만들지 못했습니다: " .. definition.name end
        local remove = chat.RemoveAllMessageGroups or ChatFrame_RemoveAllMessageGroups
        local add = chat.AddMessageGroup or ChatFrame_AddMessageGroup
        local clear_channels = chat.RemoveAllChannels or ChatFrame_RemoveAllChannels
        if not remove or not add or not clear_channels then return false, "채팅 메시지 설정 API를 찾지 못했습니다." end
        remove(chat)
        clear_channels(chat)
        for _, group in ipairs(definition.groups) do
            if ChatTypeGroup and ChatTypeGroup[group] then
                add(chat, group)

                if group ~= "CHANNEL" then remove_general(ChatFrame1, group) end
            end
        end
        if chat.ReceiveAllPrivateMessages then chat:ReceiveAllPrivateMessages() end
        if FCF_SetWindowName then FCF_SetWindowName(chat, definition.name) end
        local initial = FC.GetExtraChatDefault(definition.key)
        if initial.fontSize and FCF_SetChatWindowFontSize then FCF_SetChatWindowFontSize(nil, chat, initial.fontSize) end
        if FCF_SetWindowColor then FCF_SetWindowColor(chat, 0, 0, 0) end
        if FCF_SetWindowAlpha then FCF_SetWindowAlpha(chat, 0) end
        if FCF_SetUninteractable then FCF_SetUninteractable(chat, false) end
        FCF_UnDockFrame(chat)
        if FCF_SetLocked then FCF_SetLocked(chat, true) end
        chat:Show()
        local id = chat:GetID()
        local tab = _G["ChatFrame" .. id .. "Tab"]
        if tab then tab:Show() end
        if SetChatWindowShown then SetChatWindowShown(id, true) end
        local cfg = DevilUILayout[definition.key] or FC.GetExtraChatDefault(definition.key)
        cfg.frameId, cfg.name = id, definition.name
        DevilUILayout[definition.key] = cfg
    end
    if FC.PlaceExtraChatWindows then FC.PlaceExtraChatWindows() end
    if FCF_SelectDockFrame then FCF_SelectDockFrame(ChatFrame1) end
    return true
end
end

end

function FC.LoadInstaller(...)

do

DevilUIForever = FC
local revision = 1

local profile_revisions = {}
for name, config in pairs(PROFILE_CONFIG) do profile_revisions[name] = config.revisions end
local scoped_revisions = {BugSackLDBIconDB = 2}
local scoped_profile_revisions = {Wide_T = {BugSackLDBIconDB = 3, BugSackDB = 2, LeaPlusDB = 2, ForeverLootSparklesDB = 2}}
local events = CreateFrame("Frame")
local persist_on_logout
local waiting_for_combat
local waiting_for_editor
local pending_initial, prompt_queued
local entered_world, cinematic_active, loading_screen, movie_grace
local queue_initial

local function state()
    return FC.GetCharacterState()
end

local function import_ace(name, source, profile, partial)
    local target = _G[name]
    if type(target) ~= "table" then return false end
    target.profiles = target.profiles or {}
    target.namespaces = target.namespaces or {}
    if not DevilUIAccount.backup[name] then
        local backup = {Wide = copy(target.profiles.Wide), namespaces = {}}
        for key, namespace in pairs(target.namespaces) do
            backup.namespaces[key] = copy(namespace.profiles and namespace.profiles.Wide)
        end
        if name == "kgPanelsDB" then backup.global = copy(target.global) end
        DevilUIAccount.backup[name] = backup
    end
    local backup = DevilUIAccount.backup[name]
    backup.profiles = backup.profiles or {}
    if not backup.profiles[profile] then
        local saved = {value = copy(target.profiles[profile]), namespaces = {}}
        for key, namespace in pairs(target.namespaces) do saved.namespaces[key] = copy(namespace.profiles and namespace.profiles[profile]) end
        backup.profiles[profile] = saved
    end

    if name == "QuestieDB" then
        local entry = target.profiles[profile] or {}
        target.profiles[profile] = entry
        merge(entry, copy(source.profiles[profile]))
        return true
    end

    if partial and (partial.friendlyNames or partial.friendlyNPCNames) then
        local entry = target.profiles[profile]
        if partial.friendlyNames then
            entry.saved_cvars = entry.saved_cvars or {}
            for _, key in ipairs({"nameplateShowOnlyNameForFriendlyPlayerUnits", "nameplateUseClassColorForFriendlyPlayerUnitNames"}) do
                entry.saved_cvars[key] = source.profiles[profile].saved_cvars[key]
            end
        end
        if partial.friendlyNPCNames then
            local preset = source.profiles[profile]
            entry.hide_friendly_npc_healthbar = preset.hide_friendly_npc_healthbar
            entry.saved_cvars = entry.saved_cvars or {}
            for _, key in ipairs({"nameplateShowFriendlyPlayerMinions", "nameplateShowFriendlyPlayerPets", "nameplateShowFriendlyMinions", "nameplateShowFriendlyPets"}) do
                entry.saved_cvars[key] = preset.saved_cvars[key]
            end
            entry.plate_config = entry.plate_config or {}
            entry.plate_config.friendlynpc = entry.plate_config.friendlynpc or {}
            local cfg = entry.plate_config.friendlynpc
            cfg.only_names, cfg.level_text_enabled = true, false
        end
        return true
    end
    if partial and partial.disableAggro then
        local owner = target.namespaces.Aggro or {profiles = {}}
        target.namespaces.Aggro = owner
        owner.profiles = owner.profiles or {}
        local entry = owner.profiles[profile] or {}
        owner.profiles[profile] = entry
        entry.global = entry.global or {}
        entry.global.enabled = false
    end
    if partial and partial.leftAnchors then
        local entry, selected = target.profiles[profile], partial.leftAnchors
        if name == "PitBull4DB" then
            for _, kind in ipairs({"units", "groups"}) do
                entry[kind] = entry[kind] or {}
                for _, key in ipairs(selected[kind] or {}) do
                    entry[kind][key] = entry[kind][key] or {}
                    local saved, preset = entry[kind][key], source.profiles[profile][kind][key]
                    saved.anchor, saved.relative_point, saved.position_x = preset.anchor, preset.relative_point, preset.position_x
                    saved.relative_to = preset.relative_to
                end
            end
        else
            for _, key in ipairs(selected) do
                entry[key] = entry[key] or {}
                entry[key].Position = entry[key].Position or {}
                local saved, preset = entry[key].Position, source.profiles[profile][key].Position
                saved.point, saved.relpoint, saved.x = preset.point, preset.relpoint, preset.x
            end
        end
    end
    if partial and partial.replaceFrames then
        local entry, preset = target.profiles[profile], source.profiles[profile]
        for kind, keys in pairs(partial.replaceFrames) do
            local saved, defaults = entry, preset
            if kind ~= "frames" then
                entry[kind] = entry[kind] or {}
                saved, defaults = entry[kind], preset[kind]
            end
            for _, key in ipairs(keys) do saved[key] = copy(defaults[key]) end
        end
        return true
    elseif partial and (partial.leftAnchors or partial.disableAggro) then
        return true
    elseif partial and partial.tabletCombatStyle then
        for _, module in ipairs({"Aggro", "HealthBar", "CombatIcon"}) do
            local owner = target.namespaces[module] or {profiles = {}}
            target.namespaces[module] = owner
            owner.profiles = owner.profiles or {}
            local entry = owner.profiles[profile] or {}
            owner.profiles[profile] = entry
            entry.layouts = entry.layouts or {}
            if module == "Aggro" then
                entry.global = entry.global or {}; entry.global.enabled = false
                for layout in pairs(source.profiles[profile].layouts or {}) do
                    entry.layouts[layout] = entry.layouts[layout] or {}; entry.layouts[layout].enabled = false
                end
            else
                for _, layout in ipairs({"보통", "대상"}) do
                    entry.layouts[layout] = entry.layouts[layout] or {}
                    if module == "HealthBar" then
                        entry.layouts[layout].color_by_class = true
                        entry.layouts[layout].custom_color = nil
                    else
                        entry.layouts[layout].location = source.namespaces[module].profiles[profile].layouts[layout].location
                    end
                end
            end
        end
        return true
    elseif partial and partial.tabletTooltipShift then
        target.profiles[profile].mouseOffsetX = source.profiles[profile].mouseOffsetX
        return true
    end

    if partial and partial.brokerAlignment then
        local entry = target.profiles[profile]
        entry.objSettings = entry.objSettings or {}
        local highest = 0
        for plugin, settings in pairs(entry.objSettings) do
            if plugin ~= "BugSack" and plugin ~= "Plater" and settings.barName == "ChocolateBar1" and settings.align == "right" then
                highest = math.max(highest, settings.index or 500)
            end
        end
        for index, plugin in ipairs({"BugSack", "Plater"}) do
            entry.objSettings[plugin] = entry.objSettings[plugin] or {}
            local settings = entry.objSettings[plugin]
            settings.barName, settings.align, settings.index = "ChocolateBar1", "right", highest + index
        end
        return true
    elseif partial and partial.masqueSkin then
        local entry = target.profiles[profile]
        entry.Groups = entry.Groups or {}
        entry.Groups.Masque = entry.Groups.Masque or {}
        for _, group in pairs(entry.Groups) do group.SkinID = "Onyx Classic" end
        return true
    elseif partial and partial.gamepadBars then
        local entry = target.profiles[profile]
        entry.frames = entry.frames or {}
        for id = 1, 10 do
            entry.frames[id] = entry.frames[id] or {}
            entry.frames[id].hidden = true
        end
        return true
    end
    if partial then

        local entry = target.profiles[profile]
        entry.frames = entry.frames or {}
        if partial.exp then entry.frames.exp = copy(source.profiles[profile].frames.exp) end
        for _, id in ipairs({7, 8}) do
            entry.frames[id] = entry.frames[id] or {}
            entry.frames[id].hidden = true
        end
        return true
    end
    target.profiles[profile] = copy(source.profiles[profile])
    for _, namespace in pairs(target.namespaces) do
        if namespace.profiles then namespace.profiles[profile] = nil end
    end
    for key, namespace in pairs(source.namespaces or {}) do
        target.namespaces[key] = target.namespaces[key] or {}
        local profiles = target.namespaces[key].profiles or {}
        target.namespaces[key].profiles = profiles
        profiles[profile] = copy(namespace.profiles[profile])
    end
    if source.global then
        target.global = target.global or {}
        target.global.layouts = target.global.layouts or {}
        for layout, value in pairs(source.global.layouts) do

            if layout == profile or target.global.layouts[layout] == nil then target.global.layouts[layout] = copy(value) end
        end
        if source.global.artLibrary then
            target.global.artLibrary = target.global.artLibrary or {}
            merge(target.global.artLibrary, copy(source.global.artLibrary))
        end
    end
    return true
end

local function import_plain(name, source)
    local target = _G[name]
    if type(target) ~= "table" then return false end
    if not DevilUIAccount.backup[name] then DevilUIAccount.backup[name] = copy(target) end
    merge(target, copy(source))
    return true
end

local function hide_profile_bars(profile, center)
    local config = PROFILE_CONFIG[profile]
    local range = config and config.hiddenBars
    local target = DominosDB and DominosDB.profiles and DominosDB.profiles[profile]
    if type(target) ~= "table" then return end
    target.frames = target.frames or {}
    local first, last = range and range[1] or 9, range and range[2] or 10
    if not range and not center then return end
    for id = first, last do
        target.frames[id] = target.frames[id] or {}
        target.frames[id].hidden = true
    end
    if center then
        for id = 9, 10 do
            target.frames[id] = target.frames[id] or {}
            target.frames[id].hidden = true
        end
    end
end

local function import_presets(profile, seeds)
    local imported_ace, imported_plain, imported_scoped = {}, {}, {}
    local imported_character = {}

    for name, source in pairs(seeds.character or {}) do
        local target = _G[name]
        if type(target) == "table" then
            merge(target, copy(source))
            imported_character[name] = source
        end
    end
    local partial_ace = {}
    local imports = DevilUIAccount.profileImports[profile] or {}
    local revisions = profile_revisions[profile] or {}
    DevilUIAccount.profileImports[profile] = imports
    for name, source in pairs(seeds.ace) do
        local target = _G[name]
        local partial
        local config = PROFILE_CONFIG[profile]
        local anchors = config and config.leftAnchors
        local anchor_revision = config and config.anchorRevisions and config.anchorRevisions[name] or revisions[name]
        if anchors and anchors[name] and (imports[name] or 0) >= anchor_revision - 1 and (imports[name] or 0) < anchor_revision and
            type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            partial = {leftAnchors = anchors[name]}
        end
        local replacements = config and config.replaceFrames and config.replaceFrames[name]
        if replacements and (imports[name] or 0) >= anchor_revision - 1 and
            type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            partial = partial or {}
            partial.replaceFrames = replacements
        end
        if config and config.disableAggro and name == "PitBull4DB" and (imports[name] or 0) >= anchor_revision - 1 and
            type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            partial = partial or {}
            partial.disableAggro = true
        end
        if config and name == "PlaterDB" and (imports[name] or 0) >= revisions[name] - 2 and
            type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            partial = {friendlyNames = (imports[name] or 0) < revisions[name] - 1, friendlyNPCNames = true}
        end
        if profile == "Wide_WH" and name == "DominosDB" and (imports[name] or 0) >= 3 and
            type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            partial = {exp = imports[name] < 4}
        end
        if profile == "Wide_T" and (imports[name] or 0) >= 3 and type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            if name == "PitBull4DB" then partial = {tabletCombatStyle = true}
            elseif name == "TipTac_Config" then partial = {tabletTooltipShift = true} end
        end
        if profile ~= "Wide_T" and (imports[name] or 0) >= 1 and type(target) == "table" and target.profiles and type(target.profiles[profile]) == "table" then
            if name == "ChocolateBarDB" then partial = {brokerAlignment = true}
            elseif name == "MasqueDB" then partial = {masqueSkin = true}
            elseif (profile == "Wide_P" or profile == "Wide_T") and name == "DominosDB" then partial = {gamepadBars = true} end
        end
        if (imports[name] or 0) < (revisions[name] or revision) and import_ace(name, source, profile, partial) then
            imported_ace[name] = source
            partial_ace[name] = partial
        end
    end
    hide_profile_bars(profile)
    for name, source in pairs(seeds.plain) do
        if (DevilUIAccount.seeded[name] or 0) < revision and import_plain(name, source) then
            imported_plain[name] = source
        end
    end
    local scoped_imports
    if seeds.scopedPlain and next(seeds.scopedPlain) then
        DevilUIAccount.profilePlainImports = DevilUIAccount.profilePlainImports or {}
        scoped_imports = DevilUIAccount.profilePlainImports[profile] or {}
        DevilUIAccount.profilePlainImports[profile] = scoped_imports
        for name, source in pairs(seeds.scopedPlain) do
            if (scoped_imports[name] or 0) < ((scoped_profile_revisions[profile] or {})[name] or scoped_revisions[name] or revision) and import_plain(name, source) then imported_scoped[name] = source end
        end
    end

    local snapshot = RefluxDB and RefluxDB.profiles and RefluxDB.profiles[profile]
    if type(snapshot) == "table" then
        DevilUIAccount.backup.RefluxProfiles = DevilUIAccount.backup.RefluxProfiles or {}
        if not DevilUIAccount.backup.RefluxProfiles[profile] then DevilUIAccount.backup.RefluxProfiles[profile] = copy(snapshot) end
        for name in pairs(imported_ace) do snapshot[name] = nil end

        for name in pairs(imported_scoped) do snapshot[name] = nil end
        for name in pairs(imported_character) do snapshot[name] = nil end
        for name in pairs(imported_plain) do
            if snapshot[name] ~= nil then snapshot[name] = copy(_G[name]) end
        end
    end

    persist_on_logout = function()
        for name, source in pairs(imported_character) do
            if type(_G[name]) == "table" then merge(_G[name], copy(source)) end
        end
        for name, source in pairs(imported_ace) do
            import_ace(name, source, profile, partial_ace[name])
            imports[name] = revisions[name] or revision
            if profile == "Wide" then DevilUIAccount.seeded[name] = revisions[name] or revision end
        end
        for name, source in pairs(imported_plain) do
            import_plain(name, source)
            DevilUIAccount.seeded[name] = revision
        end
        for name, source in pairs(imported_scoped) do
            import_plain(name, source)
            scoped_imports[name] = (scoped_profile_revisions[profile] or {})[name] or scoped_revisions[name] or revision
        end

        hide_profile_bars(profile)
    end
    events:RegisterEvent("PLAYER_LOGOUT")
end

local addon_profiles = {}
for name, config in pairs(PROFILE_CONFIG) do addon_profiles[name] = config.reflux end
local wrapped_reflux
local installing_profile
function FC.HookRefluxProfiles()
    local command = SlashCmdList and SlashCmdList.REFLUX
    if type(command) ~= "function" or command == wrapped_reflux then return end
    wrapped_reflux = function(message, ...)
        local action, profile
        if type(message) == "string" then action, profile = message:match("^%s*(%S+)%s*(.-)%s*$") end
        if action and action:lower() == "switch" and addon_profiles[profile] then

            if installing_profile == profile then return command(message, ...) end

            if not InCombatLockdown() then
                if FC.IsEditModeActive() or FC.NativeSessionDirty then
                    print("DevilUI: 편집 모드를 닫고 UI 재시작을 마친 뒤 /reflux switch " .. profile .. "를 실행하세요.")
                    return
                end
                if not state() then return end
                local seeds = FC.BuildProfileSeeds(profile)
                if not seeds then print("DevilUI: Profile 폴더에 " .. profile .. " 프로필이 없습니다."); return end

                import_presets(profile, {ace = seeds.ace, plain = {}, scopedPlain = seeds.scopedPlain, character = seeds.character})
            end
        end
        return command(message, ...)
    end
    SlashCmdList.REFLUX = wrapped_reflux
end

function FC.StartInstall(profile)
    local settings = state()
    if not settings then return end
    profile = type(profile) == "string" and profile ~= "" and profile or settings.profile or "Wide"
    local seeds = FC.BuildProfileSeeds(profile)
    if not seeds then print("DevilUI: Profile 폴더에 '" .. profile .. "' 프로필이 없습니다."); return end
    if InCombatLockdown() then
        waiting_for_combat = profile
        print("DevilUI: 전투가 끝나면 초기 설정을 진행합니다.")
        return
    end
    if FC.IsEditModeActive() then
        waiting_for_editor = profile
        print("DevilUI: 편집 모드를 닫으면 초기 설정을 진행합니다.")
        return
    end
    if not SlashCmdList.REFLUX and FC.LoadAddOn then FC.LoadAddOn("Reflux") end
    if type(SlashCmdList.REFLUX) ~= "function" then
        print("DevilUI: Reflux를 활성화한 뒤 /devilui install을 실행하세요.")
        return
    end
    if FC.CaptureSharedPlacement then FC.CaptureSharedPlacement() end
    local reuse = FC.HasSavedNativeLayout(profile)
    import_presets(profile, seeds)
    hide_profile_bars(profile, true)
    if FC.ResetInstallLayout then FC.ResetInstallLayout() end
    DevilUILayout.enabled = true
    DevilUILayout.stage = "pending_reload"
    DevilUILayout.revision = revision
    DevilUILayout.profile = profile
    local kg = seeds.ace.kgPanelsDB
    DevilUILayout.panelLayout = kg and kg.profiles[profile].layout or profile
    local defaults = FC.GetNativeDefaults(profile)
    DevilUILayout.chat = copy(defaults.chat)
    DevilUILayout.chat.followNative = reuse or nil
    DevilUILayout.minimap = defaults.minimap and copy(defaults.minimap) or {followPanel = true}

    if defaults.extraChat then FC.UpdateExtraChatDefaults() end
    if reuse then FC.RestoreSharedPlacement(settings) end
    if FC.UpdateMinimapStyle then FC.UpdateMinimapStyle(settings) end
    clear_fields(DevilUILayout, {
        "nativeReady", "nativeAwaitingSelection", "nativeRevision", "nativeMinimapRevision",
        "geometryRevision", "chatReady", "nativePendingName", "nativeNotice",
        "finishAttempts", "legacyLayout", "channelsReady", "declined",
    })
    local api = C_CVar
    local set = api and api.SetCVar or SetCVar
    if set then
        set("useUiScale", "1")
        set("uiScale", profile == "Wide_T" and "0.9" or "0.7")

        set("SoftTargetTooltipInteract", (profile == "Wide_P" or profile == "Wide_T") and "1" or "0")
        if profile == "Wide_T" then

            set("SoftTargetInteract", "0")
            set("SoftTargetIconGameObject", "0")
        end
    end

    local chat_ready, chat_reason = FC.ConfigureChat()
    DevilUILayout.chatReady = chat_ready or nil
    if not chat_ready and chat_reason then print("DevilUI: " .. chat_reason) end

    local native_ready = FC.ApplyNativeDefaults(settings)
    if native_ready and not settings.nativeAwaitingSelection and settings.geometryRevision ~= 12 then
        local map_ok, map_reason = FC.PrepareNativeMinimap(settings, FC.GetMinimapPlacement(), true)
        if map_ok then settings.geometryRevision = 12
        elseif map_reason then print("DevilUI: " .. map_reason) end
    end
    print("DevilUI: " .. profile .. " 프로필과 UI 스케일 " .. (profile == "Wide_T" and "0.9" or "0.7") .. "을 적용하고 UI를 재시작합니다.")

    installing_profile = profile
    local ok, message = pcall(SlashCmdList.REFLUX, "switch " .. profile)
    installing_profile = nil
    if not ok then
        print("DevilUI: 프로필 전환을 완료하지 못했습니다: " .. tostring(message))
        if FC.NativeSessionDirty then FC.NativeReloadRequested = true; ReloadUI() end
    else
        FC.NativeReloadRequested = true
    end
end

local function intro_blocked()
    if InCombatLockdown() or cinematic_active or loading_screen then return true end
    if IsPlayerInWorld and not IsPlayerInWorld() then return true end
    if InCinematic and InCinematic() then return true end
    for _, frame in pairs({CinematicFrame, MovieFrame}) do
        if frame.IsShown and frame:IsShown() then return true end
    end
    if not UIParent or (UIParent.IsVisible and not UIParent:IsVisible()) or
        (UIParent.IsShown and not UIParent:IsShown()) then return true end
    return false
end

queue_initial = function()
    if not pending_initial or prompt_queued then return end
    prompt_queued = true
    C_Timer.After(1, function()
        prompt_queued = nil
        if not pending_initial then return end
        local settings = state()
        if settings and (settings.stage or settings.declined) then pending_initial = nil; return end
        if InCombatLockdown() then return end
        if not settings or intro_blocked() then queue_initial(); return end

        if movie_grace then movie_grace = nil; queue_initial(); return end
        local profile = settings.profile or "Wide"
        if not FC.BuildProfileSeeds(profile) then queue_initial(); return end
        FC.ShowInstall(profile)
    end)
end

local install_names = {}
for name, config in pairs(PROFILE_CONFIG) do install_names[name] = config.label end
StaticPopupDialogs.DEVILUI_FOREVER_INSTALL = {
    text = "DevilUI 초기 설정을 시작하겠습니다.\n\n%s 프로필로 초기설정을 하시겠습니까?",
    button1 = "초기 설정 적용", button2 = "나중에",
    OnAccept = function(_, profile) FC.StartInstall(profile) end,
    OnCancel = function() local settings = state(); if settings then settings.declined = true end end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}
function FC.ShowInstall(profile)
    pending_initial = nil
    local settings = state()
    if not settings then return end
    profile = type(profile) == "string" and profile ~= "" and profile or settings.profile or "Wide"
    if not FC.BuildProfileSeeds(profile) then print("DevilUI: Profile 폴더에 '" .. profile .. "' 프로필이 없습니다."); return end
    StaticPopup_Show("DEVILUI_FOREVER_INSTALL", install_names[profile] or profile, nil, profile)
end

local finishing, finish_queued
local finish_install
local function queue_finish()
    if finish_queued then return end
    finish_queued = true
    C_Timer.After(.5, function() finish_queued = nil; finish_install() end)
end
finish_install = function()
    local settings = state()
    if not settings or settings.stage ~= "pending_reload" then return end
    if finishing or InCombatLockdown() or FC.IsEditModeActive() then return end
    finishing = true
    local ready, reason = FC.ApplyNativeDefaults(settings)
    if ready and not settings.nativeAwaitingSelection and settings.geometryRevision ~= 12 then
        ready, reason = FC.PrepareNativeMinimap(settings, FC.GetMinimapPlacement(), true)
        if ready then settings.geometryRevision = 12 end
    end
    if FC.NativeSessionDirty then
        finishing = nil
        if not FC.NativeReloadRequested then
            FC.NativeReloadRequested = true
            print("DevilUI: 기본 편집 모드 설정을 저장했습니다. UI 재시작 후 설치를 마무리합니다.")
            ReloadUI()
        end
        return
    end
    if not ready then
        finishing = nil
        if settings.nativeNotice ~= reason then print("DevilUI: " .. tostring(reason)); settings.nativeNotice = reason end
        settings.finishAttempts = (settings.finishAttempts or 0) + 1
        if settings.finishAttempts < 10 then queue_finish() end
        return
    end
    if settings.nativeAwaitingSelection then

        settings.stage = "complete"
        if FC.ApplyTabletRuntime then FC.ApplyTabletRuntime() end
        settings.nativeNotice, settings.finishAttempts = nil, nil
        Devilinstall = true
        local mode = (settings.profile == "Wide_P" or settings.profile == "Wide_T") and "게임패드 모드를 켠 뒤" or "게임패드 모드를 끈 뒤"
        print("DevilUI: " .. settings.profile .. " 설정을 저장했습니다. " .. mode .. " 편집 모드에서 " .. settings.profile .. " 구성을 선택하세요.")
        finishing = nil
        return
    end
    local chat_ok, chat_ready, chat_reason = true, settings.chatReady, nil
    if not chat_ready then chat_ok, chat_ready, chat_reason = pcall(FC.ConfigureChat) end
    if not chat_ok or not chat_ready then
        finishing = nil
        local notice = chat_ok and (chat_reason or "채팅창 초기화를 기다립니다.") or "채팅창 설정 적용 중 오류: " .. tostring(chat_ready)
        if settings.nativeNotice ~= notice then print("DevilUI: " .. notice); settings.nativeNotice = notice end
        settings.finishAttempts = (settings.finishAttempts or 0) + 1
        if settings.finishAttempts < 10 then queue_finish() end
        return
    end
    if not settings.chatReady then
        settings.chatReady = true
        FC.NativeSessionDirty = true
        finishing = nil
        if not FC.NativeReloadRequested then FC.NativeReloadRequested = true; ReloadUI() end
        return
    end
    if FC.ApplyLayout() then
        settings.stage = "complete"
        if FC.CaptureSharedPlacement then FC.CaptureSharedPlacement() end
        if FC.ApplyTabletRuntime then FC.ApplyTabletRuntime() end
        settings.nativeNotice, settings.finishAttempts = nil, nil
        Devilinstall = true
        print("DevilUI: 초기 설정 완료. /devilui로 이동·크기를 조절할 수 있습니다.")
    end
    finishing = nil
end
FC.FinishInstall = finish_install
FC.QueueFinishInstall = function()
    C_Timer.After(.1, function()
        if FC.IsEditModeActive() then return end
        if waiting_for_editor then
            local profile = waiting_for_editor
            waiting_for_editor = nil
            FC.StartInstall(profile)
        else
            queue_finish()
        end
    end)
end

FC.HookRefluxProfiles()
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("CHANNEL_UI_UPDATE")
events:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
events:RegisterEvent("ADDON_LOADED")
for _, event in ipairs({"CINEMATIC_START", "CINEMATIC_STOP", "PLAY_MOVIE", "STOP_MOVIE", "LOADING_SCREEN_ENABLED", "LOADING_SCREEN_DISABLED"}) do
    if not C_EventUtils or C_EventUtils.IsEventValid(event) then events:RegisterEvent(event) end
end
events:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" or event == "PLAYER_ENTERING_WORLD" then FC.HookRefluxProfiles() end
    if event == "PLAYER_LOGOUT" then
        if FC.CaptureSharedPlacement then FC.CaptureSharedPlacement() end
        if persist_on_logout then persist_on_logout() end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        entered_world = true
        pending_initial = true
    elseif event == "CINEMATIC_START" then cinematic_active = true
    elseif event == "CINEMATIC_STOP" then cinematic_active = nil
    elseif event == "LOADING_SCREEN_ENABLED" then loading_screen = true
    elseif event == "LOADING_SCREEN_DISABLED" then loading_screen = nil
    elseif event == "PLAY_MOVIE" then movie_grace = true
    elseif event == "STOP_MOVIE" then movie_grace = nil end
    if entered_world then queue_initial() end
    local settings = state()
    if not settings then return end
    if event == "CHANNEL_UI_UPDATE" then
        if settings.enabled and settings.stage and not settings.channelsReady then FC.AttachChannels() end
        return
    end
    if event == "PLAYER_REGEN_ENABLED" and waiting_for_combat then
        local profile = waiting_for_combat
        waiting_for_combat = nil
        FC.StartInstall(profile)
        return
    end
    if settings.stage == "pending_reload" then
        queue_finish()
    elseif settings.enabled and settings.stage == "complete" then
        if not FC.IsNativeStyleCurrent(settings.profile) then return end
        if settings.nativeAwaitingSelection then
            if not FC.IsNativeLayoutActive(settings) then return end
            settings.nativeAwaitingSelection = nil
        end
        if not FC.UpgradeNativeLayoutName(settings) then return end
        if not FC.UpgradePlacementDefaults() then return end
        FC.QueueLayout()
    end
end)

SLASH_DEVILUIFOREVER1 = "/devilui"
function FC.RestoreExtraChatWindows()
    local settings = state()
    if not settings or not settings.enabled or settings.stage ~= "complete" then
        print("DevilUI: 먼저 초기 설정을 완료하세요. /devilui install")
        return
    end
    if InCombatLockdown() or FC.IsEditModeActive() or FC.NativeSessionDirty then
        print("DevilUI: 전투와 편집 모드를 종료한 뒤 /devilui chat을 실행하세요.")
        return
    end
    local ok, ready, reason = pcall(FC.ConfigureExtraChat)
    if not ok or not ready then
        print("DevilUI: " .. tostring(ok and reason or ready))
    elseif ready then
        local defaults = FC.GetNativeDefaults(settings.profile)
        print(defaults.singleChat and "DevilUI: 일반·전투 채팅창 설정을 저장하고 UI를 재시작합니다." or defaults.mergeGuildChat and "DevilUI: 일반·전투, 전리품&경험치 창을 저장하고 UI를 재시작합니다." or "DevilUI: 길드&귓말, 전리품&경험치 창을 저장하고 UI를 재시작합니다.")
    end

    if FC.ChatSessionDirty then FC.NativeSessionDirty = true; ReloadUI() end
end

SlashCmdList.DEVILUIFOREVER = function(message)
    local text = (message or ""):match("^%s*(.-)%s*$")
    local command, profile = text:match("^(%S+)%s*(.-)$")
    command = command and command:lower() or ""
    if command == "install" or command == "설치" then FC.ShowInstall(profile)
    elseif command == "update" or command == "갱신" then
        local settings = state()
        if settings and settings.stage == "complete" then
            settings.geometryRevision = nil
            FC.UpgradePlacementDefaults()
            FC.QueueLayout()
        end
    elseif command == "chat" or command == "채팅" then FC.RestoreExtraChatWindows()
    elseif command == "unlock" or command == "이동" then FC.SetUnlocked(true)
    elseif command == "lock" or command == "잠금" then FC.SetUnlocked(false)
    elseif command == "fit" or command == "맞춤" then FC.FitPanels()
    else FC.OpenLayoutOptions() end
end
end

end

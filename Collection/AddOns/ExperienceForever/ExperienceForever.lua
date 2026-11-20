-- Experience Forever
-- Clean, standalone XP & Quest tracking bar (With Reputation Bar, Hunter Pet Bar & Borders)

local ADDON_NAME = "ExperienceForever"
local ExperienceForever = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0")

local LSM = LibStub("LibSharedMedia-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Fixed behaviour
local FRAME_STRATA = "BACKGROUND"

local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

LSM:Register("statusbar", "UI-StatusBar", DEFAULT_TEXTURE)

-- Positions available for text elements
local SLOT_COUNT = 3
local DEFAULT_SLOTS = {
    topLeft      = { "totalTime", "levelTime", "none" },
    topCenter    = { "none", "none", "none" },
    topRight     = { "questPercent", "none", "none" },
    barLeft      = { "none", "none", "none" },
    barCenter    = { "level", "xp", "none" },
    barRight     = { "none", "none", "none" },
    bottomLeft   = { "timeToLevel", "none", "none" },
    bottomCenter = { "killsToLevel", "none", "none" },
    bottomRight  = { "xpHour", "none", "none" },
}

local function CopySlots()
    local out = {}
    for k, v in pairs(DEFAULT_SLOTS) do out[k] = { unpack(v) } end
    return out
end

local defaults = {
    global = {
        barWidth = 600,
        barHeight = 30,
        petBarHeight = 10,
        showPetBar = true,
        petShowText = true,
        petFontSize = 10,
        autoBarSize = true,   -- bar heights follow their font size
        
        -- Main Bar Font & Texture Settings
        fontSize = 14,
        fontName = "Friz Quadrata TT",
        fontOutline = "THICKOUTLINE",
        barTexture = "UI-StatusBar",
        
        -- Pet Bar Texture Settings
        petBarTexture = "UI-StatusBar",

        -- Reputation Bar Settings
        showRepBar = true,
        repFollowWatched = true,     -- follow the faction ticked in Blizzard's reputation panel
        repFactionID = 0,            -- used when repFollowWatched is off
        repFactionName = "",
        repBarHeight = 10,
        repBarTexture = "UI-StatusBar",
        repUseStandingColour = true, -- Hated..Exalted colours instead of repColor
        repShowText = true,
        repFontSize = 10,
        showRepBorder = false,
        repBorderClassColour = false,
        repBorderColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },
        repColor = { r = 0.0, g = 0.6, b = 0.1, a = 1.0 },
        repPerKill = 5,              -- default reputation gained per kill
        repPerKillByFaction = {},    -- [factionID] = rep per kill override
        repKillsInText = true,       -- append "N kills to <next standing>" to the bar text
        xpPerKill = 0,               -- XP from the most recent kill (learned from the game's XP messages)
        repAutoPerKill = true,       -- learn rep per kill from the game's reputation messages
        repLearned = {},             -- [factionName] = learned rep per kill
        repSamples = {},             -- [factionName] = { recent per-kill gains }

        classColour = false,
        lockBar = false,
        hideDefaultXpBar = true,
        showLabels = true,
        separator = "pipe",
        slots = CopySlots(),

        -- Main Bar Border Settings
        showBorder = false,
        borderClassColour = false,
        borderColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },

        -- Pet Bar Border Settings (Independent)
        showPetBorder = false,
        petBorderClassColour = false,
        petBorderColor = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 },

        location = { "TOP", "UIParent", "TOP", 0, -70 },
        minimap = {
            hide = false,
            angle = 225,
        },
        baseColor = { r = 0.4, g = 0.3, b = 0.9, a = 1.0 },
        questColor = { r = 1.0, g = 0.5, b = 0.0, a = 0.85 },
        restedColor = { r = 0.2, g = 0.5, b = 1.0, a = 0.4 },
        petColor = { r = 0.1, g = 0.8, b = 0.2, a = 1.0 },
    },
}

----------------------------------------------------
-- Helper Functions
----------------------------------------------------
local function FormatTime(seconds)
    if not seconds or seconds <= 0 then return "--" end
    if seconds < 60 then return "< 1m" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)

    if days > 0 then
        return string.format("%dd %dh %dm", days, hours, mins)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, mins)
    else
        return string.format("%dm", mins)
    end
end

local function FormatNumber(num)
    if _G.FormatLargeNumber then
        return _G.FormatLargeNumber(num)
    end
    return tostring(num)
end

local function ColorHex(c)
    return string.format("%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

----------------------------------------------------
-- Reputation helpers (mainline C_Reputation with legacy fallbacks)
----------------------------------------------------
local function GetWatchedFactionID()
    if C_Reputation and C_Reputation.GetWatchedFactionData then
        local d = C_Reputation.GetWatchedFactionData()
        local id = d and d.factionID
        return (id and id > 0) and id or nil
    end
    if GetWatchedFactionInfo then
        local _, _, _, _, _, id = GetWatchedFactionInfo()
        return (id and id > 0) and id or nil
    end
end

local function GetStandingLabel(reaction)
    if not reaction then return nil end
    local suffix = (UnitSex("player") == 3) and "_FEMALE" or ""
    return _G["FACTION_STANDING_LABEL" .. reaction .. suffix] or _G["FACTION_STANDING_LABEL" .. reaction]
end

-- Returns { name, reaction, standingText, min, max, value } or nil
local function GetFactionProgress(factionID)
    if not factionID or factionID <= 0 then return end

    local name, reaction, minV, maxV, value
    if C_Reputation and C_Reputation.GetFactionDataByID then
        local d = C_Reputation.GetFactionDataByID(factionID)
        if d and d.name then
            name, reaction = d.name, d.reaction
            minV, maxV, value = d.currentReactionThreshold, d.nextReactionThreshold, d.currentStanding
        end
    end
    if not name and GetFactionInfoByID then
        local n, _, standingID, bMin, bMax, bValue = GetFactionInfoByID(factionID)
        if n then name, reaction, minV, maxV, value = n, standingID, bMin, bMax, bValue end
    end
    if not name or not minV or not maxV or not value then return end

    -- Friendship-style factions keep their progress in a separate API
    if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local fr = C_GossipInfo.GetFriendshipReputation(factionID)
        if fr and fr.friendshipFactionID and fr.friendshipFactionID > 0 then
            local lo = fr.reactionThreshold or 0
            return {
                name = name,
                standingText = fr.reaction,
                min = lo,
                max = fr.nextThreshold or lo,
                value = fr.standing or lo,
            }
        end
    end

    return {
        name = name,
        reaction = reaction,
        standingText = GetStandingLabel(reaction),
        min = minV, max = maxV, value = value,
    }
end

-- Turns a localised format string such as "Reputation with %s increased by %d."
-- into a Lua pattern, remembering which capture is the name and which the amount.
local function BuildPattern(fmt)
    if type(fmt) ~= "string" then return end
    local pat, kinds, pos = "", {}, 1
    while true do
        local s, e, _, kind = fmt:find("%%(%d?)%$?([sd])", pos)
        if not s then
            pat = pat .. fmt:sub(pos):gsub("%p", "%%%0")
            break
        end
        pat = pat .. fmt:sub(pos, s - 1):gsub("%p", "%%%0")
        pat = pat .. (kind == "s" and "(.+)" or "(%d+)")
        kinds[#kinds + 1] = kind
        pos = e + 1
    end
    return "^" .. pat, kinds
end

local patternCache = {}
-- Matches msg against the game string named globalName; returns name, amount or nil
local function ParseMessage(globalName, msg)
    local c = patternCache[globalName]
    if c == nil then
        local pat, kinds = BuildPattern(_G[globalName])
        c = pat and { pat = pat, kinds = kinds } or false
        patternCache[globalName] = c
    end
    if not c then return end
    local caps = { msg:match(c.pat) }
    local name, amount
    for i, kind in ipairs(c.kinds) do
        if kind == "s" then name = caps[i] else amount = tonumber(caps[i]) end
    end
    if amount and amount > 0 then return name, amount end
end

local function ParseRepGain(msg)
    local name, amount = ParseMessage("FACTION_STANDING_INCREASED", msg)
    if name then return name, amount end
end

-- Absolute reputation needed to reach each standing (1 Hated .. 8 Exalted)
local STANDING_THRESHOLDS = {
    [1] = -42000, [2] = -6000, [3] = -3000, [4] = 0,
    [5] = 3000,   [6] = 9000,  [7] = 21000, [8] = 42000,
}

-- Returns an ordered list of { reaction, label, kills } for every standing above the
-- current one, where kills = kills needed from the current reputation to reach it.
local function GetKillsToStandings(data, perKill)
    if not data or not data.reaction or not perKill or perKill <= 0 then return end
    local list = {}
    for r = data.reaction + 1, 8 do
        local needed = STANDING_THRESHOLDS[r] - data.value
        if needed > 0 then
            list[#list + 1] = {
                reaction = r,
                label = GetStandingLabel(r) or ("Standing " .. r),
                kills = math.ceil(needed / perKill),
            }
        end
    end
    return list
end

-- { ["factionID"] = "Name" } of every faction currently visible in the reputation list
local function ListFactions()
    local list = {}
    local useNew = C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetFactionDataByIndex
    local num = useNew and C_Reputation.GetNumFactions() or (GetNumFactions and GetNumFactions()) or 0
    for i = 1, num do
        local name, id, isHeader, hasRep
        if useNew then
            local d = C_Reputation.GetFactionDataByIndex(i)
            if d then name, id, isHeader, hasRep = d.name, d.factionID, d.isHeader, d.isHeaderWithRep end
        elseif GetFactionInfo then
            local n, _, _, _, _, _, _, _, h, _, hr, _, _, fid = GetFactionInfo(i)
            name, id, isHeader, hasRep = n, fid, h, hr
        end
        if name and id and id > 0 and (not isHeader or hasRep) then
            list[tostring(id)] = name
        end
    end
    return list
end

----------------------------------------------------
-- Modules
----------------------------------------------------
local MODULES = {
    level = { name = "Level", fn = function(self, c)
        return nil, "Level " .. c.level
    end },
    xp = { name = "XP (current / needed)", fn = function(self, c)
        if c.isMax then return nil, "Max Level" end
        return nil, string.format("%s / %s", FormatNumber(c.currentXP), FormatNumber(c.maxXP))
    end },
    xpRemaining = { name = "XP remaining", fn = function(self, c)
        if c.isMax then return end
        return "To go", FormatNumber(c.maxXP - c.currentXP)
    end },
    xpPercent = { name = "XP percent", fn = function(self, c)
        return "XP", string.format("%.1f%%", c.pct)
    end },
    questPercent = { name = "Completed quests (% of level)", fn = function(self, c)
        if c.isMax then return end
        return "Completed quests", string.format("%.1f%%", c.questPct), "questColor"
    end },
    questXP = { name = "Completed quests (XP)", fn = function(self, c)
        if c.isMax then return end
        return "Quest XP", FormatNumber(c.questXP), "questColor"
    end },
    restedXP = { name = "Rested XP", fn = function(self, c)
        if c.isMax then return end
        return "Rested", FormatNumber(c.restedXP), "restedColor"
    end },
    restedPercent = { name = "Rested XP (% of level)", fn = function(self, c)
        if c.isMax then return end
        return "Rested", string.format("%.1f%%", c.restedPct), "restedColor"
    end },
    totalTime = { name = "Total played time", fn = function(self, c)
        return "Total played", FormatTime(c.totalSecs)
    end },
    levelTime = { name = "Time played this level", fn = function(self, c)
        return "This level", FormatTime(c.levelSecs)
    end },
    sessionTime = { name = "Session time", fn = function(self, c)
        return "Session", FormatTime(c.sessionDuration)
    end },
    timeToLevel = { name = "Time to level", fn = function(self, c)
        if c.isMax then return end
        return "Time to level", FormatTime(c.timeToLevel)
    end },
    killsToLevel = { name = "Kills to level", fn = function(self, c)
        if c.isMax then return end
        return "Kills to level", c.killsToLevel and FormatNumber(c.killsToLevel) or "-"
    end },
    xpHour = { name = "XP per hour", fn = function(self, c)
        if c.isMax then return end
        return "XP/Hour", FormatNumber(c.xpHour)
    end },
}

local MODULE_ORDER = {
    "none", "level", "xp", "xpRemaining", "xpPercent",
    "questPercent", "questXP", "restedXP", "restedPercent",
    "totalTime", "levelTime", "sessionTime", "timeToLevel", "killsToLevel", "xpHour",
}

local SEPARATORS = {
    pipe  = "  |  ",
    dash  = "  -  ",
    space = "   ",
}

local SLOTS = {
    { key = "topLeft",      name = "Top Left",      point = "BOTTOMLEFT",  rel = "TOPLEFT",     x = 5,  y = 3 },
    { key = "topCenter",    name = "Top Center",    point = "BOTTOM",      rel = "TOP",         x = 0,  y = 3 },
    { key = "topRight",     name = "Top Right",     point = "BOTTOMRIGHT", rel = "TOPRIGHT",    x = -5, y = 3 },
    { key = "barLeft",      name = "Bar Left",      point = "LEFT",        rel = "LEFT",        x = 8,  y = 0 },
    { key = "barCenter",    name = "Bar Center",    point = "CENTER",      rel = "CENTER",      x = 0,  y = 0 },
    { key = "barRight",     name = "Bar Right",     point = "RIGHT",       rel = "RIGHT",       x = -8, y = 0 },
    { key = "bottomLeft",   name = "Bottom Left",   point = "TOPLEFT",     rel = "BOTTOMLEFT",  x = 5,  y = -3 },
    { key = "bottomCenter", name = "Bottom Center", point = "TOP",         rel = "BOTTOM",      x = 0,  y = -3 },
    { key = "bottomRight",  name = "Bottom Right",  point = "TOPRIGHT",    rel = "BOTTOMRIGHT", x = -5, y = -3 },
}

----------------------------------------------------
-- Initialization
----------------------------------------------------
function ExperienceForever:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ExperienceForeverDB", defaults, true)

    -- Pet text now lives centred on the pet bar; clear the old pet slot modules
    local oldPetModules = { petName = true, petXP = true, petPercent = true, petRemaining = true }
    for _, items in pairs(self.db.global.slots) do
        for n = 1, SLOT_COUNT do
            if oldPetModules[items[n]] then items[n] = "none" end
        end
    end

    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "UpdateBarTextures")

    self.sessionStartTime = GetTime()
    self.sessionXP = 0
    self.startXP = UnitXP("player") or 0
    self.startMaxXP = UnitXPMax("player") or 0
    self.cachedQuestXP = 0

    self:CreateUI()
    self:SetupMinimapButton()
    self:SetupOptions()

    local f = self.MainFrame
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_XP_UPDATE")
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterEvent("QUEST_LOG_UPDATE")
    f:RegisterEvent("TIME_PLAYED_MSG")
    f:RegisterEvent("UI_SCALE_CHANGED")
    f:RegisterEvent("DISPLAY_SIZE_CHANGED")
    f:RegisterEvent("UPDATE_FACTION")
    f:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
    f:RegisterEvent("QUEST_TURNED_IN")
    
    -- Pet Events
    f:RegisterEvent("UNIT_PET")
    f:RegisterEvent("UNIT_PET_EXPERIENCE")
    f:RegisterEvent("PET_UI_UPDATE")

    f:SetScript("OnEvent", function(_, event, arg1, arg2)
        if event == "PLAYER_ENTERING_WORLD" then
            self:PLAYER_ENTERING_WORLD()
        elseif event == "PLAYER_XP_UPDATE" then
            self:TrackKillXP()
            self:PLAYER_XP_UPDATE()
        elseif event == "PLAYER_LEVEL_UP" then
            self:PLAYER_LEVEL_UP()
        elseif event == "TIME_PLAYED_MSG" then
            self:TIME_PLAYED_MSG(arg1, arg2)
        elseif event == "QUEST_LOG_UPDATE" then
            self.questXPPending = true
            self:QueueUpdate()
        elseif event == "CHAT_MSG_COMBAT_XP_GAIN" then
            self:OnXPGain()
        elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
            self:OnRepGain(arg1)
        elseif event == "QUEST_TURNED_IN" then
            self.lastQuestTime = GetTime()
        elseif event == "UNIT_PET" or event == "UNIT_PET_EXPERIENCE" or event == "PET_UI_UPDATE"
            or event == "UPDATE_FACTION" then
            self:QueueUpdate()
        else
            self:UpdateBorder()
        end
    end)

    self:RegisterChatCommand("ef", "OpenSettings")
    self:RegisterChatCommand("experienceforever", "OpenSettings")
end

function ExperienceForever:OnEnable()
    if not self.updateTicker then
        self.updateTicker = C_Timer.NewTicker(1.0, function()
            self:UpdateTimeText()
        end)
    end

    self:InitKillXPState()
    self:UpdateBarTextures()
    self:UpdateDefaultBarState()
    self:UpdateQuestXP()
    self:Update()
end

----------------------------------------------------
-- Minimap Button
----------------------------------------------------
function ExperienceForever:UpdateMinimapButtonPosition()
    local btn = self.MinimapButton
    if not btn then return end
    local angle = math.rad(self.db.global.minimap.angle or 225)
    local radius = (Minimap:GetWidth() / 2) + 5
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

function ExperienceForever:SetupMinimapButton()
    local btn = CreateFrame("Button", "ExperienceForeverMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(28, 28)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\ExperienceForever\\Media\\Logo")

    btn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            self.db.global.lockBar = not self.db.global.lockBar
            self:Print("Bar locked: " .. tostring(self.db.global.lockBar))
        else
            self:OpenSettings()
        end
    end)

    btn:SetScript("OnDragStart", function(b)
        b:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            local atan2 = math.atan2 or math.atan
            self.db.global.minimap.angle = math.deg(atan2(cy / scale - my, cx / scale - mx))
            self:UpdateMinimapButtonPosition()
        end)
    end)
    btn:SetScript("OnDragStop", function(b)
        b:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnEnter", function(b)
        GameTooltip:SetOwner(b, "ANCHOR_LEFT")
        GameTooltip:AddLine("Experience Forever")
        GameTooltip:AddLine("|cffFFFFFFLeft-Click:|r Open Settings")
        GameTooltip:AddLine("|cffFFFFFFRight-Click:|r Toggle Bar Lock")
        GameTooltip:AddLine("|cffFFFFFFDrag:|r Move Button")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.MinimapButton = btn
    self:UpdateMinimapButtonPosition()
    btn:SetShown(not self.db.global.minimap.hide)
end

----------------------------------------------------
-- UI Creation
----------------------------------------------------
function ExperienceForever:CreateUI()
    local cfg = self.db.global

    self.MainFrame = CreateFrame("Button", "ExperienceForeverFrame", UIParent)
    self.MainFrame:SetSize(cfg.barWidth, cfg.barHeight)
    self.MainFrame:SetFrameStrata(FRAME_STRATA)
    self.MainFrame:SetMovable(true)
    self.MainFrame:EnableMouse(true)
    self.MainFrame:RegisterForDrag("LeftButton")

    local loc = cfg.location
    self.MainFrame:SetPoint(loc[1] or "TOP", UIParent, loc[3] or "TOP", loc[4] or 0, loc[5] or -70)

    self.MainFrame:SetScript("OnDragStart", function(frame)
        if not self.db.global.lockBar then frame:StartMoving() end
    end)
    self.MainFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        self:SavePosition()
    end)

    self.ProgressBar = CreateFrame("StatusBar", nil, self.MainFrame)
    self.ProgressBar:SetAllPoints()

    self.QuestBar = CreateFrame("StatusBar", nil, self.MainFrame)
    self.QuestBar:SetAllPoints()

    self.RestedBar = CreateFrame("StatusBar", nil, self.MainFrame)
    self.RestedBar:SetAllPoints()

    -- Reputation Bar attached directly below the main bar
    self.RepBar = CreateFrame("StatusBar", nil, self.MainFrame)
    self.RepBar:SetPoint("TOPLEFT", self.MainFrame, "BOTTOMLEFT", 0, -2)
    self.RepBar:SetPoint("TOPRIGHT", self.MainFrame, "BOTTOMRIGHT", 0, -2)
    self.RepBar:SetHeight(cfg.repBarHeight or 10)
    self.RepBar:Hide()
    self.RepText = self.RepBar:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self.RepText:SetPoint("CENTER", self.RepBar, "CENTER", 0, 0)

    -- Hover for kills-to-standing tooltip; dragging still moves the whole bar
    self.RepBar:EnableMouse(true)
    self.RepBar:RegisterForDrag("LeftButton")
    self.RepBar:SetScript("OnEnter", function() self:ShowRepTooltip() end)
    self.RepBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.RepBar:SetScript("OnDragStart", function()
        if not self.db.global.lockBar then self.MainFrame:StartMoving() end
    end)
    self.RepBar:SetScript("OnDragStop", function()
        self.MainFrame:StopMovingOrSizing()
        self:SavePosition()
    end)

    -- Pet Experience Bar: sits under the reputation bar when that is showing,
    -- otherwise directly under the main bar (see LayoutSubBars)
    self.PetBar = CreateFrame("StatusBar", nil, self.MainFrame)
    self.PetBar:SetPoint("TOPLEFT", self.MainFrame, "BOTTOMLEFT", 0, -2)
    self.PetBar:SetPoint("TOPRIGHT", self.MainFrame, "BOTTOMRIGHT", 0, -2)
    self.PetBar:SetHeight(cfg.petBarHeight or 10)
    self.petAnchor = self.MainFrame
    self.PetText = self.PetBar:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self.PetText:SetPoint("CENTER", self.PetBar, "CENTER", 0, 0)

    self.TextOverlay = CreateFrame("Frame", nil, self.MainFrame)
    self.TextOverlay:SetAllPoints()
    self.TextOverlay:SetFrameLevel(self.RestedBar:GetFrameLevel() + 10)

    -- Main Bar Border Frame Elements
    self.Border = {}
    for _, edge in ipairs({ "top", "bottom", "left", "right" }) do
        self.Border[edge] = self.MainFrame:CreateTexture(nil, "BORDER")
    end

    -- Pet Bar Border Frame Elements
    self.PetBorder = {}
    for _, edge in ipairs({ "top", "bottom", "left", "right" }) do
        self.PetBorder[edge] = self.PetBar:CreateTexture(nil, "BORDER")
    end

    -- Reputation Bar Border Frame Elements
    self.RepBorder = {}
    for _, edge in ipairs({ "top", "bottom", "left", "right" }) do
        self.RepBorder[edge] = self.RepBar:CreateTexture(nil, "BORDER")
    end

    self:UpdateBarTextures()
    self:UpdateBarColors()
    self:UpdateBorder()

    self.Texts = {}
    for _, slot in ipairs(SLOTS) do
        local fs = self.TextOverlay:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        fs:SetPoint(slot.point, self.TextOverlay, slot.rel, slot.x, slot.y)
        self.Texts[slot.key] = fs
    end

    self:ApplyFontSettings()
end

----------------------------------------------------
-- Positioning & Media
----------------------------------------------------
local DEFAULT_LOCATION = { "TOP", "UIParent", "TOP", 0, -70 }
function ExperienceForever:GetPosition()
    local cx, cy = self.MainFrame:GetCenter()
    local ux, uy = UIParent:GetCenter()
    if not cx or not ux then return 0, 0 end
    -- Round to whole screen pixels so the bar's edges (and its border) land on the pixel grid
    local px = self:GetPixelSize()
    if not px or px <= 0 then px = 1 end
    return math.floor((cx - ux) / px + 0.5) * px, math.floor((cy - uy) / px + 0.5) * px
end

function ExperienceForever:SetPosition(x, y)
    local curX, curY = self:GetPosition()
    x, y = x or curX, y or curY
    self.MainFrame:ClearAllPoints()
    self.MainFrame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    self.db.global.location = { "CENTER", "UIParent", "CENTER", x, y }
    self:UpdateBorder()
    AceConfigRegistry:NotifyChange(ADDON_NAME)
end

function ExperienceForever:SavePosition()
    self:SetPosition(self:GetPosition())
end

function ExperienceForever:ResetPosition()
    local d = DEFAULT_LOCATION
    self.MainFrame:ClearAllPoints()
    self.MainFrame:SetPoint(d[1], UIParent, d[3], d[4], d[5])
    self.db.global.location = { d[1], d[2], d[3], d[4], d[5] }
    AceConfigRegistry:NotifyChange(ADDON_NAME)
end

function ExperienceForever:GetTexturePath(textureKey)
    local tbl = LSM:HashTable("statusbar")
    return (tbl and tbl[textureKey]) or DEFAULT_TEXTURE
end

function ExperienceForever:GetFontPath(fontKey)
    local tbl = LSM:HashTable("font")
    return (tbl and tbl[fontKey]) or DEFAULT_FONT
end

function ExperienceForever:GetPixelSize()
    local _, screenHeight = GetPhysicalScreenSize()
    local scale = self.MainFrame:GetEffectiveScale()
    if not screenHeight or screenHeight == 0 or not scale or scale == 0 then return 1 end
    return (768 / screenHeight) / scale
end

local function ApplyEdges(self, edges, target, enabled, classColour, color, px)
    if not edges then return end
    if not enabled or not (target and target:IsShown()) then
        for _, t in pairs(edges) do t:Hide() end
        return
    end

    local c = color
    if classColour then
        local cc = self:GetClassColor()
        if cc then c = { r = cc.r, g = cc.g, b = cc.b, a = color.a } end
    end

    edges.top:ClearAllPoints()
    edges.top:SetPoint("BOTTOMLEFT", target, "TOPLEFT", -px, 0)
    edges.top:SetPoint("BOTTOMRIGHT", target, "TOPRIGHT", px, 0)
    edges.top:SetHeight(px)

    edges.bottom:ClearAllPoints()
    edges.bottom:SetPoint("TOPLEFT", target, "BOTTOMLEFT", -px, 0)
    edges.bottom:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", px, 0)
    edges.bottom:SetHeight(px)

    edges.left:ClearAllPoints()
    edges.left:SetPoint("TOPRIGHT", target, "TOPLEFT", 0, 0)
    edges.left:SetPoint("BOTTOMRIGHT", target, "BOTTOMLEFT", 0, 0)
    edges.left:SetWidth(px)

    edges.right:ClearAllPoints()
    edges.right:SetPoint("TOPLEFT", target, "TOPRIGHT", 0, 0)
    edges.right:SetPoint("BOTTOMLEFT", target, "BOTTOMRIGHT", 0, 0)
    edges.right:SetWidth(px)

    for _, t in pairs(edges) do
        -- Pixel snapping can round a 1px line down to nothing depending on where the bar sits
        if t.SetSnapToPixelGrid then t:SetSnapToPixelGrid(false) end
        if t.SetTexelSnappingBias then t:SetTexelSnappingBias(0) end
        t:SetColorTexture(c.r, c.g, c.b, c.a)
        t:Show()
    end
end

function ExperienceForever:UpdateBorder()
    local cfg = self.db.global
    local px = self:GetPixelSize()

    ApplyEdges(self, self.Border, self.MainFrame, cfg.showBorder, cfg.borderClassColour, cfg.borderColor, px)
    ApplyEdges(self, self.RepBorder, self.RepBar, cfg.showRepBorder, cfg.repBorderClassColour, cfg.repBorderColor, px)
    ApplyEdges(self, self.PetBorder, self.PetBar, cfg.showPetBorder, cfg.petBorderClassColour, cfg.petBorderColor, px)
end

function ExperienceForever:UpdateBarTextures()
    local mainTexPath = self:GetTexturePath(self.db.global.barTexture)
    self.ProgressBar:SetStatusBarTexture(mainTexPath)
    self.QuestBar:SetStatusBarTexture(mainTexPath)
    self.RestedBar:SetStatusBarTexture(mainTexPath)

    if self.RepBar then
        self.RepBar:SetStatusBarTexture(self:GetTexturePath(self.db.global.repBarTexture))
    end

    if self.PetBar then
        local petTexPath = self:GetTexturePath(self.db.global.petBarTexture)
        self.PetBar:SetStatusBarTexture(petTexPath)
    end
end

function ExperienceForever:GetClassColor()
    local _, class = UnitClass("player")
    return (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class]) or RAID_CLASS_COLORS[class]
end

function ExperienceForever:UpdateBarColors()
    local cfg = self.db.global

    local q = cfg.questColor
    self.QuestBar:SetStatusBarColor(q.r, q.g, q.b, q.a)

    local r = cfg.restedColor
    self.RestedBar:SetStatusBarColor(r.r, r.g, r.b, r.a)

    if self.PetBar and cfg.petColor then
        local p = cfg.petColor
        self.PetBar:SetStatusBarColor(p.r, p.g, p.b, p.a)
    end

    if cfg.classColour then
        local color = self:GetClassColor()
        if color then
            self.ProgressBar:SetStatusBarColor(color.r, color.g, color.b, cfg.baseColor.a)
            return
        end
    end
    local b = cfg.baseColor
    self.ProgressBar:SetStatusBarColor(b.r, b.g, b.b, b.a)
end

function ExperienceForever:GetBarHeight(which)
    local cfg = self.db.global
    if cfg.autoBarSize then
        if which == "main" then return cfg.fontSize + 16 end
        if which == "rep" then return (cfg.repFontSize or 10) + 4 end
        return (cfg.petFontSize or 10) + 4
    end
    if which == "main" then return cfg.barHeight end
    if which == "rep" then return cfg.repBarHeight or 10 end
    return cfg.petBarHeight or 10
end

function ExperienceForever:ApplyBarSizes()
    if not self.MainFrame then return end
    self.MainFrame:SetHeight(self:GetBarHeight("main"))
    if self.RepBar then self.RepBar:SetHeight(self:GetBarHeight("rep")) end
    if self.PetBar then self.PetBar:SetHeight(self:GetBarHeight("pet")) end
end

function ExperienceForever:ApplyFontSettings(isRetry)
    local cfg = self.db.global
    local outline = cfg.fontOutline ~= "NONE" and cfg.fontOutline or nil
    local path = self:GetFontPath(cfg.fontName)
    local anyFailed = false

    for _, fontString in pairs(self.Texts) do
        if not fontString:SetFont(path, cfg.fontSize, outline) then
            anyFailed = true
            fontString:SetFont(DEFAULT_FONT, cfg.fontSize, outline)
        end
    end

    if self.RepText then
        local repSize = cfg.repFontSize or 10
        if not self.RepText:SetFont(path, repSize, outline) then
            anyFailed = true
            self.RepText:SetFont(DEFAULT_FONT, repSize, outline)
        end
    end

    if self.PetText then
        local petSize = cfg.petFontSize or 10
        if not self.PetText:SetFont(path, petSize, outline) then
            anyFailed = true
            self.PetText:SetFont(DEFAULT_FONT, petSize, outline)
        end
    end

    self:ApplyBarSizes()

    if anyFailed and not isRetry then
        C_Timer.After(0.25, function() self:ApplyFontSettings(true) end)
    end
end

----------------------------------------------------
-- Core Logic
----------------------------------------------------
function ExperienceForever:QueueUpdate()
    if self.updatePending then return end
    self.updatePending = true
    C_Timer.After(0, function()
        self.updatePending = false
        if self.questXPPending then
            self.questXPPending = false
            self:UpdateQuestXP()
        end
        self:Update()
    end)
end

function ExperienceForever:UpdateQuestXP()
    local totalQuestXP = 0
    local numEntries = C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries() or GetNumQuestLogEntries()

    for i = 1, numEntries do
        local questID
        if C_QuestLog.GetQuestIDForLogIndex then
            questID = C_QuestLog.GetQuestIDForLogIndex(i)
        else
            _, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
        end

        if questID and questID > 0 then
            local isComplete = false
            if C_QuestLog.IsComplete then
                isComplete = C_QuestLog.IsComplete(questID)
            elseif IsQuestComplete then
                isComplete = IsQuestComplete(questID)
            end

            if isComplete then
                totalQuestXP = totalQuestXP + (GetQuestLogRewardXP(questID) or 0)
            end
        end
    end
    self.cachedQuestXP = totalQuestXP
end

function ExperienceForever:LayoutSubBars()
    local anchor = self.RepBar:IsShown() and self.RepBar or self.MainFrame
    if self.petAnchor ~= anchor then
        self.petAnchor = anchor
        self.PetBar:ClearAllPoints()
        self.PetBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
        self.PetBar:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -2)
    end
end

function ExperienceForever:UpdateRepBar()
    local cfg = self.db.global
    local bar = self.RepBar
    if not bar then return end

    local factionID
    if cfg.repFollowWatched then
        factionID = GetWatchedFactionID()
    else
        factionID = cfg.repFactionID
    end

    local data = cfg.showRepBar and GetFactionProgress(factionID) or nil
    self.repData, self.repFactionID = data, factionID
    if not data then
        bar:Hide()
        self:LayoutSubBars()
        return
    end

    local cur = data.value - data.min
    local need = data.max - data.min
    local maxed = need <= 0
    if maxed then cur, need = 1, 1 end
    cur = math.max(0, math.min(cur, need))

    bar:SetHeight(self:GetBarHeight("rep"))
    bar:SetMinMaxValues(0, need)
    bar:SetValue(cur)

    local c = cfg.repColor
    local alpha = c.a
    if cfg.repUseStandingColour and data.reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[data.reaction] then
        c = FACTION_BAR_COLORS[data.reaction]
    end
    bar:SetStatusBarColor(c.r, c.g, c.b, alpha)

    if cfg.repShowText then
        local text = data.name
        if data.standingText then text = text .. " - " .. data.standingText end
        if maxed then
            text = text .. " (Max)"
        else
            text = string.format("%s: %s / %s", text, FormatNumber(data.value - data.min), FormatNumber(need))
        end
        if cfg.repKillsInText and not maxed then
            local kills = GetKillsToStandings(data, self:GetRepPerKill(factionID, data.name))
            if kills and kills[1] then
                text = string.format("%s | %s kills to %s", text, FormatNumber(kills[1].kills), kills[1].label)
            end
        end
        self.RepText:SetText(text)
        self.RepText:Show()
    else
        self.RepText:Hide()
    end

    bar:Show()
    self:LayoutSubBars()

    -- Keep an open tooltip live while reputation changes
    if GameTooltip:IsShown() and GameTooltip:GetOwner() == bar then
        self:ShowRepTooltip()
    end
end

function ExperienceForever:GetLearnedRepPerKill(name)
    local cfg = self.db.global
    if not (cfg.repAutoPerKill and name) then return end
    local v = cfg.repLearned[name]
    if v and v > 0 then return v end
end

-- Learned value (if auto-detect is on) > manual per-faction value > default
function ExperienceForever:GetRepPerKill(factionID, name)
    local cfg = self.db.global
    local learned = self:GetLearnedRepPerKill(name)
    if learned then return learned end
    local v = factionID and cfg.repPerKillByFaction[factionID]
    if v and v > 0 then return v end
    return cfg.repPerKill or 5
end

----------------------------------------------------
-- Learning rep per kill from reputation messages
----------------------------------------------------
local KILL_WINDOW = 2   -- seconds between a kill and its reputation message
local MAX_SAMPLES = 7  -- recent kill gains remembered per faction

function ExperienceForever:LearnRepPerKill(name, amount)
    local cfg = self.db.global
    local samples = cfg.repSamples[name]
    if not samples then samples = {}; cfg.repSamples[name] = samples end
    samples[#samples + 1] = amount
    while #samples > MAX_SAMPLES do table.remove(samples, 1) end

    -- Most common recent value wins; ties go to the most recent one
    local counts = {}
    for _, v in ipairs(samples) do counts[v] = (counts[v] or 0) + 1 end
    local best, bestCount
    for i = #samples, 1, -1 do
        local v = samples[i]
        if not bestCount or counts[v] > bestCount then best, bestCount = v, counts[v] end
    end
    cfg.repLearned[name] = best
    self:QueueUpdate()
end

function ExperienceForever:OnKill()
    local now = GetTime()
    self.lastKillTime = now
    -- the XP change can arrive just before the kill message
    local x = self.pendingXP
    if x and now - x.time <= KILL_WINDOW then
        self.pendingXP = nil
        self:SetXPPerKill(x.amount)
    end
end

function ExperienceForever:OnRepGain(msg)
    if not self.db.global.repAutoPerKill or type(msg) ~= "string" then return end
    local name, amount = ParseRepGain(msg)
    if not name then return end
    local t = GetTime()
    -- Wait a moment so a quest turn-in (which also gives reputation) can be told apart from a kill
    C_Timer.After(0.75, function()
        if self.lastQuestTime and math.abs(self.lastQuestTime - t) <= 3 then return end
        self:LearnRepPerKill(name, amount)
    end)
end

function ExperienceForever:SetXPPerKill(amount)
    self.db.global.xpPerKill = amount
    self:QueueUpdate()
end

function ExperienceForever:InitKillXPState()
    self.killXPState = {
        xp = UnitXP("player") or 0,
        max = UnitXPMax("player") or 0,
        level = UnitLevel("player"),
    }
end

-- Called on PLAYER_XP_UPDATE. An XP increase that lines up with a kill is that kill's XP
-- (this is the XP actually received, rested bonus included).
function ExperienceForever:TrackKillXP()
    local last = self.killXPState
    self:InitKillXPState()
    local cur = self.killXPState
    if not last or last.level ~= cur.level or last.max ~= cur.max then return end
    local delta = cur.xp - last.xp
    if delta <= 0 then return end

    local now = GetTime()
    if self.lastKillTime and now - self.lastKillTime <= KILL_WINDOW then
        self:SetXPPerKill(delta)
    else
        self.pendingXP = { amount = delta, time = now }
    end
end

-- The game's XP-from-a-kill chat message is itself a sign that something was killed
function ExperienceForever:OnXPGain()
    self:OnKill()
end

function ExperienceForever:ShowRepTooltip()
    local bar, data = self.RepBar, self.repData
    if not bar or not data then return end

    local perKill = self:GetRepPerKill(self.repFactionID, data.name)
    local learned = self:GetLearnedRepPerKill(data.name)
    GameTooltip:SetOwner(bar, "ANCHOR_BOTTOM")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(data.name or "Reputation")
    GameTooltip:AddDoubleLine("Current standing:", data.standingText or "Unknown", 1, 1, 1, 1, 1, 1)

    local list = GetKillsToStandings(data, perKill)
    if list and #list > 0 then
        GameTooltip:AddDoubleLine("Reputation per kill:", tostring(perKill) .. (learned and " (auto)" or ""), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Kills needed to reach:")
        for _, e in ipairs(list) do
            local col = FACTION_BAR_COLORS and FACTION_BAR_COLORS[e.reaction]
            local r, g, b = 1, 1, 1
            if col then r, g, b = col.r, col.g, col.b end
            GameTooltip:AddDoubleLine(e.label, FormatNumber(e.kills), r, g, b, 1, 1, 1)
        end
    elseif list then
        GameTooltip:AddLine("Maximum standing reached.", 0.7, 0.7, 0.7)
    else
        GameTooltip:AddLine("Kill estimates aren't available for this faction.", 0.7, 0.7, 0.7)
    end
    GameTooltip:Show()
end

-- Time-dependent context fields (session time, XP per hour, time to level,
-- played times); shared by Update and UpdateTimeText so both show the same values.
local function SetTimeFields(self, ctx, now)
    local sessionDuration = math.max(1, now - self.sessionStartTime)
    local xpHour = math.floor((self.sessionXP / sessionDuration) * 3600)
    local sincePlayed = self.playedAt and (now - self.playedAt)
    ctx.sessionDuration = sessionDuration
    ctx.xpHour = xpHour
    ctx.timeToLevel = (xpHour > 0 and not ctx.isMax) and math.floor(((ctx.maxXP - ctx.currentXP) / xpHour) * 3600) or 0
    ctx.levelSecs = sincePlayed and self.levelTime and (self.levelTime + sincePlayed)
    ctx.totalSecs = sincePlayed and self.totalTime and (self.totalTime + sincePlayed)
end

function ExperienceForever:Update()
    if not self.MainFrame then return end

    local cfg = self.db.global
    local level = UnitLevel("player")
    local maxXP = UnitXPMax("player") or 0
    local isMax = level >= GetMaxPlayerLevel() or maxXP <= 0

    local currentXP = UnitXP("player") or 0
    if maxXP <= 0 then maxXP = 1 end
    local restedXP = GetXPExhaustion() or 0
    local questXP = self.cachedQuestXP or 0

    -- Base XP
    self.ProgressBar:SetMinMaxValues(0, maxXP)
    self.ProgressBar:SetValue(currentXP)

    -- Completed-quest XP
    self.QuestBar:SetMinMaxValues(0, maxXP)
    if questXP > 0 then
        self.QuestBar:SetValue(math.min(currentXP + questXP, maxXP))
        self.QuestBar:Show()
    else
        self.QuestBar:SetValue(0)
        self.QuestBar:Hide()
    end

    -- Rested XP
    self.RestedBar:SetMinMaxValues(0, maxXP)
    if restedXP > 0 then
        self.RestedBar:SetValue(math.min(currentXP + questXP + restedXP, maxXP))
        self.RestedBar:Show()
    else
        self.RestedBar:SetValue(0)
        self.RestedBar:Hide()
    end

    -- Reputation bar (also re-anchors the pet bar beneath it)
    self:UpdateRepBar()

    -- Handle Pet Bar calculations
    local _, class = UnitClass("player")
    local hasPet = cfg.showPetBar and class == "HUNTER" and UnitExists("pet") and GetPetExperience ~= nil
    local petCurrXP, petMaxXP, petName, petPct = 0, 0, "", 0

    if hasPet then
        petCurrXP, petMaxXP = GetPetExperience()
        if petMaxXP and petMaxXP > 0 then
            self.PetBar:SetMinMaxValues(0, petMaxXP)
            self.PetBar:SetValue(petCurrXP)
            self.PetBar:SetHeight(self:GetBarHeight("pet"))
            self.PetBar:Show()
            petName = UnitName("pet") or "Pet"
            petPct = (petCurrXP / petMaxXP) * 100
            if cfg.petShowText then
                self.PetText:SetText(string.format("%s: %s / %s (%.1f%%)",
                    petName, FormatNumber(petCurrXP), FormatNumber(petMaxXP), petPct))
                self.PetText:Show()
            else
                self.PetText:Hide()
            end
        else
            hasPet = false
            self.PetBar:Hide()
        end
    else
        self.PetBar:Hide()
    end

    local pct = isMax and 100 or (currentXP / maxXP) * 100

    local xpPerKill = cfg.xpPerKill
    local killsToLevel = (not isMax and xpPerKill and xpPerKill > 0)
        and math.ceil((maxXP - currentXP) / xpPerKill) or nil

    local ctx = {
        level = level,
        isMax = isMax,
        currentXP = currentXP,
        maxXP = maxXP,
        pct = pct,
        questXP = questXP,
        questPct = (questXP / maxXP) * 100,
        restedXP = restedXP,
        restedPct = (restedXP / maxXP) * 100,
        killsToLevel = killsToLevel,
    }
    SetTimeFields(self, ctx, GetTime())
    self.lastCtx = ctx

    self.slotText = self.slotText or {}
    for _, slot in ipairs(SLOTS) do
        local text = self:BuildSlotText(slot.key, ctx)
        self.slotText[slot.key] = text
        self.Texts[slot.key]:SetText(text)
    end

    self:UpdateBorder()
end

-- Per-second refresh: rebuilds the slot texts from the last Update's values with
-- the time fields recomputed, and sets only texts that changed. A different
-- level, XP, max XP or rested XP (rested growth has no event here) or a
-- missing context runs the full Update instead.
function ExperienceForever:UpdateTimeText()
    if self.updatePending then return end
    local ctx = self.lastCtx
    if not ctx or not self.MainFrame then return self:QueueUpdate() end
    local maxXP = UnitXPMax("player") or 0
    if maxXP <= 0 then maxXP = 1 end
    if UnitLevel("player") ~= ctx.level or (UnitXP("player") or 0) ~= ctx.currentXP or maxXP ~= ctx.maxXP
        or (GetXPExhaustion() or 0) ~= ctx.restedXP then
        return self:QueueUpdate()
    end
    SetTimeFields(self, ctx, GetTime())
    for _, slot in ipairs(SLOTS) do
        local text = self:BuildSlotText(slot.key, ctx)
        if text ~= self.slotText[slot.key] then
            self.slotText[slot.key] = text
            self.Texts[slot.key]:SetText(text)
        end
    end
end

function ExperienceForever:BuildSlotText(slotKey, ctx)
    local cfg = self.db.global
    local items = cfg.slots[slotKey]
    if not items then return "" end

    local parts = {}
    for i = 1, SLOT_COUNT do
        local mod = MODULES[items[i]]
        if mod then
            local label, value, colorKey = mod.fn(self, ctx)
            if value then
                if colorKey then
                    value = string.format("|cff%s%s|r", ColorHex(cfg[colorKey]), value)
                end
                if label and cfg.showLabels then
                    value = label .. ": " .. value
                end
                parts[#parts + 1] = value
            end
        end
    end
    return table.concat(parts, SEPARATORS[cfg.separator] or SEPARATORS.pipe)
end

local function ForEachFrame(frame, depth, fn)
    fn(frame)
    if depth > 0 then
        for _, child in ipairs({ frame:GetChildren() }) do
            ForEachFrame(child, depth - 1, fn)
        end
    end
end

function ExperienceForever:UpdateDefaultBarState()
    local manager = StatusTrackingBarManager
    if not manager then return end
    local hide = self.db.global.hideDefaultXpBar

    -- Fade instead of Hide/Show: hiding Blizzard's status bar manager from addon code
    -- taints it and triggers the "blocked from an action only available to the Blizzard UI" popup.
    manager:SetAlpha(hide and 0 or 1)

    -- A faded bar still catches the mouse, so switch its mouse input off while it is hidden
    -- (and put it back exactly as it was when it is shown again).
    self.blizzMouse = self.blizzMouse or {}
    if hide then
        ForEachFrame(manager, 3, function(f)
            if f.IsMouseEnabled and f.EnableMouse and f:IsMouseEnabled() then
                self.blizzMouse[f] = true
                f:EnableMouse(false)
            end
        end)
        -- Blizzard rebuilds its bars when they change; switch the new ones off too
        if not self.blizzHooked and type(manager.UpdateBarsShown) == "function" then
            self.blizzHooked = true
            hooksecurefunc(manager, "UpdateBarsShown", function()
                if self.db.global.hideDefaultXpBar then self:UpdateDefaultBarState() end
            end)
        end
    else
        for f in pairs(self.blizzMouse) do f:EnableMouse(true) end
        wipe(self.blizzMouse)
    end
end

----------------------------------------------------
-- Event Handlers
----------------------------------------------------
function ExperienceForever:RequestPlayed()
    if type(RequestTimePlayed) ~= "function" then return end

    if not self.chatMuted then
        self.chatMuted = {}
        for i = 1, NUM_CHAT_WINDOWS or 10 do
            local frame = _G["ChatFrame" .. i]
            if frame and frame:IsEventRegistered("TIME_PLAYED_MSG") then
                frame:UnregisterEvent("TIME_PLAYED_MSG")
                self.chatMuted[#self.chatMuted + 1] = frame
            end
        end
        C_Timer.After(3, function()
            for _, frame in ipairs(self.chatMuted) do
                frame:RegisterEvent("TIME_PLAYED_MSG")
            end
            self.chatMuted = nil
        end)
    end

    RequestTimePlayed()
end

function ExperienceForever:PLAYER_ENTERING_WORLD()
    if not self.enteredWorld then
        self.enteredWorld = true
        self.sessionStartTime = GetTime()
        self.startXP = UnitXP("player") or 0
        self.startMaxXP = UnitXPMax("player") or 0
        self:RequestPlayed()
    end
    self:UpdateQuestXP()
    self:QueueUpdate()
end

function ExperienceForever:PLAYER_XP_UPDATE()
    local newXP = UnitXP("player") or 0
    if newXP > self.startXP then
        self.sessionXP = self.sessionXP + (newXP - self.startXP)
    elseif newXP < self.startXP and (self.startMaxXP or 0) > 0 then
        -- Levelled up: count the XP up to the end of the old level plus the overflow
        self.sessionXP = self.sessionXP + (self.startMaxXP - self.startXP) + newXP
    end
    self.startXP = newXP
    self.startMaxXP = UnitXPMax("player") or 0
    self:QueueUpdate()
end

function ExperienceForever:PLAYER_LEVEL_UP()
    -- Session XP is kept (XP/hour carries on across levels); only restart "time this level"
    if self.playedAt and self.levelTime then
        self.levelTime = -(GetTime() - self.playedAt)
    end
    self:UpdateQuestXP()
    self:QueueUpdate()
end

function ExperienceForever:TIME_PLAYED_MSG(totalTime, levelTime)
    self.totalTime = totalTime or 0
    self.levelTime = levelTime or 0
    self.playedAt = GetTime()
    self:QueueUpdate()
end

----------------------------------------------------
-- Options & Settings
----------------------------------------------------
function ExperienceForever:OpenSettings(input)
    local cmd = strtrim(type(input) == "string" and input or ""):lower()

    if cmd == "lock" then
        self.db.global.lockBar = not self.db.global.lockBar
        self:Print("Bar locked: " .. tostring(self.db.global.lockBar))
    elseif cmd == "reset" then
        self:ResetPosition()
        self:Print("Bar position reset.")
    elseif self.optionsPage and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(self.optionsPage)
    else
        self:Print("Commands: /ef lock (toggle lock), /ef reset (reset bar position)")
    end
end

local function MediaList(mediaType)
    local list = {}
    for _, name in ipairs(LSM:List(mediaType)) do
        list[name] = name
    end
    return list
end

local function ColorOption(self, key, name, order, refresh)
    local function apply()
        self:UpdateBarColors()
        self:UpdateBorder()
        if refresh then self:QueueUpdate() end
    end
    return {
        [key] = {
            type = "color",
            name = name,
            hasAlpha = false,
            order = order,
            width = "normal",
            get = function()
                local c = self.db.global[key]
                return c.r, c.g, c.b
            end,
            set = function(_, r, g, b)
                local a = self.db.global[key].a
                self.db.global[key] = { r = r, g = g, b = b, a = a }
                apply()
            end,
        },
        [key .. "Opacity"] = {
            type = "range",
            name = name:gsub(" Color", "") .. " Opacity",
            min = 0, max = 100, step = 1,
            order = order + 0.0005,
            width = "normal",
            get = function() return math.floor(self.db.global[key].a * 100 + 0.5) end,
            set = function(_, v)
                self.db.global[key].a = v / 100
                apply()
            end,
        },
    }
end

function ExperienceForever:AddLayoutOptions(args)
    local moduleValues = {}
    for key, mod in pairs(MODULES) do moduleValues[key] = mod.name end
    moduleValues.none = "- None -"

    args.layoutHeader = { type = "header", name = "Text Layout", order = 14.6 }
    args.layoutDesc = {
        type = "description",
        order = 14.61,
        name = "Choose what appears in each position around the bar. Each position can show up to "
            .. SLOT_COUNT .. " items side by side.",
    }
    args.showLabels = {
        type = "toggle",
        name = "Show Labels",
        desc = "Show a label before each value, e.g. \"Completed quests: 67%\" instead of just \"67%\".",
        order = 14.62,
        get = function() return self.db.global.showLabels end,
        set = function(_, v) self.db.global.showLabels = v; self:QueueUpdate() end,
    }
    args.separator = {
        type = "select",
        name = "Separator",
        desc = "What goes between items that share a position.",
        order = 14.63,
        values = { pipe = "|", dash = "-", space = "Space" },
        get = function() return self.db.global.separator end,
        set = function(_, v) self.db.global.separator = v; self:QueueUpdate() end,
    }
    args.resetLayout = {
        type = "execute",
        name = "Reset Layout",
        desc = "Put every position back to its default items.",
        order = 14.64,
        func = function()
            self.db.global.slots = CopySlots()
            self:QueueUpdate()
            AceConfigRegistry:NotifyChange(ADDON_NAME)
        end,
    }

    for i, slot in ipairs(SLOTS) do
        local group = {
            type = "group",
            inline = true,
            name = slot.name,
            order = 14.65 + i / 1000,
            args = {},
        }
        for n = 1, SLOT_COUNT do
            group.args["item" .. n] = {
                type = "select",
                name = "Item " .. n,
                order = n,
                values = moduleValues,
                sorting = MODULE_ORDER,
                get = function()
                    local items = self.db.global.slots[slot.key]
                    return items and items[n] or "none"
                end,
                set = function(_, v)
                    self.db.global.slots[slot.key][n] = v
                    self:QueueUpdate()
                end,
            }
        end
        args["slot_" .. slot.key] = group
    end
end

function ExperienceForever:SetupOptions()
    local halfWidth = math.floor((UIParent:GetWidth() or 1920) / 2)
    local halfHeight = math.floor((UIParent:GetHeight() or 1080) / 2)

    local options = {
        type = "group",
        name = "Experience Forever",
        args = {
            lockBar = {
                type = "toggle",
                name = "Lock Bar",
                order = 1,
                get = function() return self.db.global.lockBar end,
                set = function(_, v) self.db.global.lockBar = v end,
            },
            hideDefaultXpBar = {
                type = "toggle",
                name = "Hide Default Experience Bar",
                order = 2,
                get = function() return self.db.global.hideDefaultXpBar end,
                set = function(_, v) self.db.global.hideDefaultXpBar = v; self:UpdateDefaultBarState() end,
            },
            showMinimap = {
                type = "toggle",
                name = "Show Minimap Icon",
                order = 3,
                get = function() return not self.db.global.minimap.hide end,
                set = function(_, v)
                    self.db.global.minimap.hide = not v
                    self.MinimapButton:SetShown(v)
                end,
            },
            classColour = {
                type = "toggle",
                name = "Use Class Color",
                order = 4,
                get = function() return self.db.global.classColour end,
                set = function(_, v) self.db.global.classColour = v; self:UpdateBarColors() end,
            },
            showPetBar = {
                type = "toggle",
                name = "Show Hunter Pet XP Bar",
                order = 4.5,
                get = function() return self.db.global.showPetBar end,
                set = function(_, v) self.db.global.showPetBar = v; self:QueueUpdate() end,
            },
            petShowText = {
                type = "toggle",
                name = "Show Pet Text",
                order = 4.55,
                get = function() return self.db.global.petShowText end,
                set = function(_, v) self.db.global.petShowText = v; self:QueueUpdate() end,
            },
            showRepBar = {
                type = "toggle",
                name = "Show Reputation Bar",
                desc = "Show a reputation bar directly below the main bar.",
                order = 4.6,
                get = function() return self.db.global.showRepBar end,
                set = function(_, v) self.db.global.showRepBar = v; self:QueueUpdate() end,
            },
            repFollowWatched = {
                type = "toggle",
                name = "Follow Watched Faction",
                desc = "Track whichever faction is ticked \"Show as Experience Bar\" in Blizzard's reputation panel. "
                    .. "Untick to pick a specific faction below.",
                order = 4.7,
                disabled = function() return not self.db.global.showRepBar end,
                get = function() return self.db.global.repFollowWatched end,
                set = function(_, v) self.db.global.repFollowWatched = v; self:QueueUpdate() end,
            },
            repFaction = {
                type = "select",
                name = "Reputation Faction",
                order = 4.75,
                width = "double",
                disabled = function() return not self.db.global.showRepBar or self.db.global.repFollowWatched end,
                values = function()
                    local list = ListFactions()
                    local id = self.db.global.repFactionID
                    if id and id > 0 and not list[tostring(id)] then
                        local name = self.db.global.repFactionName
                        list[tostring(id)] = (name and name ~= "") and name or ("Faction " .. id)
                    end
                    if next(list) == nil then list["0"] = "- none available -" end
                    return list
                end,
                get = function() return tostring(self.db.global.repFactionID or 0) end,
                set = function(_, v)
                    local id = tonumber(v) or 0
                    self.db.global.repFactionID = id
                    local data = GetFactionProgress(id)
                    self.db.global.repFactionName = data and data.name or ""
                    self:QueueUpdate()
                end,
            },
            repExpand = {
                type = "execute",
                name = "Expand All Reputation Categories",
                desc = "The list above only shows factions in expanded categories of Blizzard's reputation panel. "
                    .. "This expands every category so all factions appear (it also expands them in the panel).",
                order = 4.76,
                disabled = function() return not self.db.global.showRepBar or self.db.global.repFollowWatched end,
                func = function()
                    if C_Reputation and C_Reputation.ExpandAllFactionHeaders then
                        C_Reputation.ExpandAllFactionHeaders()
                    elseif ExpandAllFactionHeaders then
                        ExpandAllFactionHeaders()
                    elseif ExpandFactionHeader and GetNumFactions then
                        for i = GetNumFactions(), 1, -1 do ExpandFactionHeader(i) end
                    end
                    AceConfigRegistry:NotifyChange(ADDON_NAME)
                end,
            },
            repUseStandingColour = {
                type = "toggle",
                name = "Colour Bar By Standing",
                desc = "Use Blizzard's Hated-to-Exalted colours. Untick to use the Reputation Bar Color below.",
                order = 4.8,
                get = function() return self.db.global.repUseStandingColour end,
                set = function(_, v) self.db.global.repUseStandingColour = v; self:QueueUpdate() end,
            },
            repKillsInText = {
                type = "toggle",
                name = "Show Kills To Next Standing",
                desc = "Append the number of kills needed to reach the next standing to the reputation bar text. "
                    .. "Hover the reputation bar for the kills needed for every standing.",
                order = 4.92,
                disabled = function() return not self.db.global.showRepBar end,
                get = function() return self.db.global.repKillsInText end,
                set = function(_, v) self.db.global.repKillsInText = v; self:QueueUpdate() end,
            },
            repPerKill = {
                type = "range",
                name = "Reputation Per Kill",
                desc = "Reputation gained per kill for the faction currently shown on the reputation bar "
                    .. "(remembered separately for each faction). Not used while a value has been "
                    .. "auto-detected for that faction.",
                order = 4.94,
                min = 1, max = 250, step = 1,
                disabled = function()
                    local d = self.repData
                    return not self.db.global.showRepBar or (d and self:GetLearnedRepPerKill(d.name)) ~= nil
                end,
                get = function() return self:GetRepPerKill(self.repFactionID, self.repData and self.repData.name) end,
                set = function(_, v)
                    if self.repFactionID then
                        self.db.global.repPerKillByFaction[self.repFactionID] = v
                    else
                        self.db.global.repPerKill = v
                    end
                    self:QueueUpdate()
                end,
            },
            repAutoPerKill = {
                type = "toggle",
                name = "Auto-Detect Reputation Per Kill",
                desc = "Learn the reputation per kill for each faction from the game's reputation messages "
                    .. "when you kill something. Uses the most common of your last few kills.",
                order = 4.93,
                disabled = function() return not self.db.global.showRepBar end,
                get = function() return self.db.global.repAutoPerKill end,
                set = function(_, v) self.db.global.repAutoPerKill = v; self:QueueUpdate() end,
            },
            repForgetLearned = {
                type = "execute",
                name = "Forget Learned Value",
                desc = "Clear the auto-detected reputation per kill for the faction currently shown on the bar.",
                order = 4.95,
                disabled = function()
                    local d = self.repData
                    return not self.db.global.showRepBar or not (d and self.db.global.repLearned[d.name])
                end,
                func = function()
                    local d = self.repData
                    if d then
                        self.db.global.repLearned[d.name] = nil
                        self.db.global.repSamples[d.name] = nil
                        self:QueueUpdate()
                        AceConfigRegistry:NotifyChange(ADDON_NAME)
                    end
                end,
            },
            repShowText = {
                type = "toggle",
                name = "Show Reputation Text",
                order = 4.9,
                get = function() return self.db.global.repShowText end,
                set = function(_, v) self.db.global.repShowText = v; self:QueueUpdate() end,
            },
            barTexture = {
                type = "select",
                name = "Main Bar Texture",
                order = 5,
                values = function() return MediaList("statusbar") end,
                get = function() return self.db.global.barTexture end,
                set = function(_, v)
                    self.db.global.barTexture = v
                    self:UpdateBarTextures()
                end,
            },
            repBarTexture = {
                type = "select",
                name = "Reputation Bar Texture",
                order = 5.05,
                values = function() return MediaList("statusbar") end,
                get = function() return self.db.global.repBarTexture end,
                set = function(_, v)
                    self.db.global.repBarTexture = v
                    self:UpdateBarTextures()
                end,
            },
            petBarTexture = {
                type = "select",
                name = "Pet Bar Texture",
                order = 5.1,
                values = function() return MediaList("statusbar") end,
                get = function() return self.db.global.petBarTexture end,
                set = function(_, v)
                    self.db.global.petBarTexture = v
                    self:UpdateBarTextures()
                end,
            },
            autoBarSize = {
                type = "toggle",
                name = "Auto-Size Bars To Font",
                desc = "Bar heights follow their text size (main bar, reputation bar and pet bar). "
                    .. "Untick to set the heights manually with the sliders.",
                order = 5.5,
                get = function() return self.db.global.autoBarSize end,
                set = function(_, v)
                    self.db.global.autoBarSize = v
                    self:ApplyBarSizes()
                    self:QueueUpdate()
                    AceConfigRegistry:NotifyChange(ADDON_NAME)
                end,
            },
            barWidth = {
                type = "range",
                name = "Width",
                min = 200, max = 1200, step = 10,
                order = 6,
                get = function() return self.db.global.barWidth end,
                set = function(_, v) self.db.global.barWidth = v; self.MainFrame:SetWidth(v); self:QueueUpdate() end,
            },
            barHeight = {
                type = "range",
                name = "Height",
                min = 10, max = 60, step = 1,
                order = 7,
                get = function() return self.db.global.barHeight end,
                disabled = function() return self.db.global.autoBarSize end,
                set = function(_, v) self.db.global.barHeight = v; self:ApplyBarSizes(); self:QueueUpdate() end,
            },
            repBarHeight = {
                type = "range",
                name = "Reputation Bar Height",
                min = 4, max = 30, step = 1,
                order = 7.9,
                get = function() return self.db.global.repBarHeight end,
                disabled = function() return self.db.global.autoBarSize end,
                set = function(_, v) self.db.global.repBarHeight = v; self:ApplyBarSizes(); self:QueueUpdate() end,
            },
            petBarHeight = {
                type = "range",
                name = "Pet Bar Height",
                min = 4, max = 30, step = 1,
                order = 8,
                get = function() return self.db.global.petBarHeight end,
                disabled = function() return self.db.global.autoBarSize end,
                set = function(_, v) self.db.global.petBarHeight = v; self:ApplyBarSizes(); self:QueueUpdate() end,
            },

            borderHeader = { type = "header", name = "1px Border Settings", order = 8.9 },

            -- Main Bar Border Options
            showBorder = {
                type = "toggle",
                name = "Show Main Bar Border",
                order = 9,
                get = function() return self.db.global.showBorder end,
                set = function(_, v) self.db.global.showBorder = v; self:UpdateBorder() end,
            },
            borderClassColour = {
                type = "toggle",
                name = "Class Color Main Border",
                order = 9.1,
                disabled = function() return not self.db.global.showBorder end,
                get = function() return self.db.global.borderClassColour end,
                set = function(_, v) self.db.global.borderClassColour = v; self:UpdateBorder() end,
            },
            borderColor = {
                type = "color",
                name = "Custom Main Border Color",
                hasAlpha = false,
                order = 9.2,
                disabled = function() return not self.db.global.showBorder or self.db.global.borderClassColour end,
                get = function()
                    local c = self.db.global.borderColor
                    return c.r, c.g, c.b
                end,
                set = function(_, r, g, b)
                    self.db.global.borderColor = { r = r, g = g, b = b, a = self.db.global.borderColor.a }
                    self:UpdateBorder()
                end,
            },
            borderOpacity = {
                type = "range",
                name = "Main Border Opacity",
                min = 0, max = 100, step = 1,
                order = 9.3,
                disabled = function() return not self.db.global.showBorder end,
                get = function() return math.floor(self.db.global.borderColor.a * 100 + 0.5) end,
                set = function(_, v) self.db.global.borderColor.a = v / 100; self:UpdateBorder() end,
            },

            -- Reputation Bar Border Options (Independent)
            showRepBorder = {
                type = "toggle",
                name = "Show Reputation Bar Border",
                order = 9.5,
                get = function() return self.db.global.showRepBorder end,
                set = function(_, v) self.db.global.showRepBorder = v; self:UpdateBorder() end,
            },
            repBorderClassColour = {
                type = "toggle",
                name = "Class Color Reputation Border",
                order = 9.6,
                disabled = function() return not self.db.global.showRepBorder end,
                get = function() return self.db.global.repBorderClassColour end,
                set = function(_, v) self.db.global.repBorderClassColour = v; self:UpdateBorder() end,
            },
            repBorderColor = {
                type = "color",
                name = "Custom Reputation Border Color",
                hasAlpha = false,
                order = 9.7,
                disabled = function() return not self.db.global.showRepBorder or self.db.global.repBorderClassColour end,
                get = function()
                    local c = self.db.global.repBorderColor
                    return c.r, c.g, c.b
                end,
                set = function(_, r, g, b)
                    self.db.global.repBorderColor = { r = r, g = g, b = b, a = self.db.global.repBorderColor.a }
                    self:UpdateBorder()
                end,
            },
            repBorderOpacity = {
                type = "range",
                name = "Reputation Border Opacity",
                min = 0, max = 100, step = 1,
                order = 9.8,
                disabled = function() return not self.db.global.showRepBorder end,
                get = function() return math.floor(self.db.global.repBorderColor.a * 100 + 0.5) end,
                set = function(_, v) self.db.global.repBorderColor.a = v / 100; self:UpdateBorder() end,
            },

            -- Pet Bar Border Options (Independent)
            showPetBorder = {
                type = "toggle",
                name = "Show Pet Bar Border",
                order = 10,
                get = function() return self.db.global.showPetBorder end,
                set = function(_, v) self.db.global.showPetBorder = v; self:UpdateBorder() end,
            },
            petBorderClassColour = {
                type = "toggle",
                name = "Class Color Pet Border",
                order = 10.1,
                disabled = function() return not self.db.global.showPetBorder end,
                get = function() return self.db.global.petBorderClassColour end,
                set = function(_, v) self.db.global.petBorderClassColour = v; self:UpdateBorder() end,
            },
            petBorderColor = {
                type = "color",
                name = "Custom Pet Border Color",
                hasAlpha = false,
                order = 10.2,
                disabled = function() return not self.db.global.showPetBorder or self.db.global.petBorderClassColour end,
                get = function()
                    local c = self.db.global.petBorderColor
                    return c.r, c.g, c.b
                end,
                set = function(_, r, g, b)
                    self.db.global.petBorderColor = { r = r, g = g, b = b, a = self.db.global.petBorderColor.a }
                    self:UpdateBorder()
                end,
            },
            petBorderOpacity = {
                type = "range",
                name = "Pet Border Opacity",
                min = 0, max = 100, step = 1,
                order = 10.3,
                disabled = function() return not self.db.global.showPetBorder end,
                get = function() return math.floor(self.db.global.petBorderColor.a * 100 + 0.5) end,
                set = function(_, v) self.db.global.petBorderColor.a = v / 100; self:UpdateBorder() end,
            },

            posHeader = { type = "header", name = "Position", order = 12 },
            posX = {
                type = "range",
                name = "X Offset (from screen center)",
                order = 13,
                min = -halfWidth,
                max = halfWidth,
                step = 1,
                get = function() return math.floor((self:GetPosition()) + 0.5) end,
                set = function(_, v) self:SetPosition(v, nil) end,
            },
            posY = {
                type = "range",
                name = "Y Offset (from screen center)",
                order = 14,
                min = -halfHeight,
                max = halfHeight,
                step = 1,
                get = function() local _, y = self:GetPosition(); return math.floor(y + 0.5) end,
                set = function(_, v) self:SetPosition(nil, v) end,
            },
            resetPosition = {
                type = "execute",
                name = "Reset Position",
                desc = "Move the bar back to the top center of the screen.",
                order = 14.5,
                func = function() self:ResetPosition() end,
            },

            fontHeader = { type = "header", name = "Font Settings", order = 14.51 },
            font = {
                type = "select",
                name = "Font",
                order = 14.52,
                values = function() return MediaList("font") end,
                get = function() return self.db.global.fontName end,
                set = function(_, v)
                    self.db.global.fontName = v
                    self:ApplyFontSettings()
                end,
            },
            fontSize = {
                type = "range",
                name = "Font Size",
                min = 8, max = 32, step = 1,
                order = 14.53,
                get = function() return self.db.global.fontSize end,
                set = function(_, v)
                    self.db.global.fontSize = v
                    self:ApplyFontSettings()
                end,
            },
            fontOutline = {
                type = "select",
                name = "Font Outline",
                order = 14.54,
                values = {
                    NONE = "None",
                    OUTLINE = "Outline",
                    THICKOUTLINE = "Thick Outline",
                    MONOCHROME = "Monochrome",
                },
                get = function() return self.db.global.fontOutline end,
                set = function(_, v)
                    self.db.global.fontOutline = v
                    self:ApplyFontSettings()
                end,
            },

            repFontSize = {
                type = "range",
                name = "Reputation Text Size",
                min = 6, max = 24, step = 1,
                order = 14.545,
                get = function() return self.db.global.repFontSize end,
                set = function(_, v)
                    self.db.global.repFontSize = v
                    self:ApplyFontSettings()
                end,
            },

            petFontSize = {
                type = "range",
                name = "Pet Text Size",
                min = 6, max = 24, step = 1,
                order = 14.546,
                get = function() return self.db.global.petFontSize end,
                set = function(_, v)
                    self.db.global.petFontSize = v
                    self:ApplyFontSettings()
                end,
            },

            colorHeader = { type = "header", name = "Color Settings", order = 14.55 },
        },
    }

    for _, def in ipairs({
        { "baseColor",   "Base XP Color",            14.551, false },
        { "questColor",  "Completed Quest XP Color", 14.552, true  },
        { "restedColor", "Rested XP Color",          14.553, true  },
        { "petColor",    "Pet XP Color",             14.554, true  },
        { "repColor",    "Reputation Bar Color",     14.555, true  },
    }) do
        for k, v in pairs(ColorOption(self, def[1], def[2], def[3], def[4])) do
            options.args[k] = v
        end
        options.args[def[1] .. "Break"] = {
            type = "description", name = " ", fontSize = "small",
            width = "full", order = def[3] + 0.0008,
        }
    end

    self:AddLayoutOptions(options.args)

    AceConfigRegistry:RegisterOptionsTable(ADDON_NAME, options)
    local _, categoryID = AceConfigDialog:AddToBlizOptions(ADDON_NAME, "Experience Forever")
    self.optionsPage = categoryID
end
local _G = _G

-- addon name and namespace
local ADDON, NS = ...

-- local functions
local tonumber = tonumber
local gsub     = string.gsub
local smatch   = string.match
local sqrt     = math.sqrt
local floor    = math.floor

local GetGuildInfo          = GetGuildInfo
local GetNumFactions        = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
local GetNumGroupMembers    = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetXPExhaustion       = GetXPExhaustion
local IsInRaid              = IsInRaid
local IsResting             = IsResting
local UnitLevel             = UnitLevel
local UnitXP                = UnitXP
local UnitXPMax             = UnitXPMax
local GetMaxLevelForPlayerExpansion = GetMaxLevelForPlayerExpansion
local C_Reputation_IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon
local GetWatchedFactionData = C_Reputation and C_Reputation.GetWatchedFactionData
local SetWatchedFactionID = C_Reputation and C_Reputation.SetWatchedFactionByID

local _

-- setup libs
local LibStub   = LibStub

-- coloring tools
local Crayon	= LibStub:GetLibrary("LibCrayon-3.0")

-- get translations
local L         = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- constants
local ICON         = "Interface\\Addons\\"..ADDON.."\\icon.tga"
local ICON_RESTING = "Interface\\Addons\\"..ADDON.."\\iconrest.tga"

-- addon and locals
local Addon = LibStub:GetLibrary("AceAddon-3.0"):NewAddon(ADDON, "AceEvent-3.0", "AceConsole-3.0", "AceBucket-3.0", "AceTimer-3.0")

-- wow versions
local toc = select(4, GetBuildInfo())
Addon.isForever = (WOW_PROJECT_CAMELOT and WOW_PROJECT_ID == WOW_PROJECT_CAMELOT)
    or (toc >= 16000 and toc < 17000)
if Addon.isForever or WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	Addon.wowVersion = "retail"
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
	Addon.wowVersion = "bcc"
elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
	Addon.wowVersion = "wrath" -- CN only
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
	Addon.wowVersion = "cata" -- CN only
elseif WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
	Addon.wowVersion = "mop"
else
	Addon.wowVersion = "classic"
end

-- internal event handling
Addon.callbacks = LibStub("CallbackHandler-1.0"):New(Addon)

-- add to namespace
NS.Addon = Addon

-- addon constants
Addon.MODNAME   = "BrokerXPBar"
Addon.FULLNAME  = "Broker: XP Bar"
Addon.MAX_LEVEL = GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

-- player level
Addon.playerLvl       = UnitLevel("player")

-- faction variables
Addon.faction         = nil

Addon.watchedStanding = 0
Addon.watchedFriendID = nil
Addon.atMaxRep        = false
Addon.inRaid	      = false

Addon.FONT_NAME_DEFAULT = "Friz Quadrata TT"
Addon.FONT_DEFAULT      = GameFontNormal:GetFont()

-- modules
local Options           = nil
local Tooltip           = nil
local MinimapButton     = nil
local DataBroker        = nil
local Bar               = nil
local Factions          = nil
local History           = nil
local ReputationHistory = nil
local QuestInfo         = nil
local Notifications     = nil
local TextEngine        = nil

-- aux variables
local countInitial = 0

-- combat log processing
-- using wow constants to avoid localization issues
-- NOTE: rested bonus and penalty(?) are string literals for some reason
local XPGAIN_SINGLE
local XPGAIN_SINGLE_RESTED
local XPGAIN_SINGLE_PENALTY
local XPGAIN_GROUP
local XPGAIN_GROUP_RESTED
local XPGAIN_GROUP_PENALTY
local XPGAIN_RAID
local XPGAIN_RAID_RESTED
local XPGAIN_RAID_PENALTY

local REP_GAIN_SIMPLE
local REP_LOSS_SIMPLE

do
-- NOTE: russian and korean clients use POSIX position indicators in COMBATLOG_XPGAIN_ patterns, 
-- which LUAs functions like string.find() or string.format() do not support
-- thx to Lua 5 for kicking them out of the language: "The format option %n$ is obsolete."
-- apparently argument 3 and 4 are always exchanged in those localizations
-- so we get rid of the position indicators and manually switch back the args after matching
	local temp
	
	-- "%s dies, you gain %d experience."
	temp                  = gsub(COMBATLOG_XPGAIN_FIRSTPERSON,      "(%%[0-9]$)([ds])", "%%%2") -- position indicators
	temp                  = gsub(temp,                              "%%s",   "(.+)")   -- string pattern
	XPGAIN_SINGLE         = gsub(temp,                              "%%d",   "(%%d+)") -- number pattern

	-- "%s dies, you gain %d experience. (%s exp %s bonus)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION1,      "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                              "[()+-]", "[%0]")  -- mask '(', ')', '+', '-'
	temp                  = gsub(temp,                              "%%s",    "(.+)")
	XPGAIN_SINGLE_RESTED  = gsub(temp,                              "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (%s exp %s penalty)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION4,      "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                              "[()+-]", "[%0]")
	temp                  = gsub(temp,                              "%%s",    "(.+)")
	XPGAIN_SINGLE_PENALTY = gsub(temp,                              "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (+%d group bonus)"
	temp                  = gsub(COMBATLOG_XPGAIN_FIRSTPERSON_GROUP, "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_GROUP          = gsub(temp,                               "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION1_GROUP, "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_GROUP_RESTED   = gsub(temp,                               "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (%s exp %s penalty, +%d group bonus)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION4_GROUP, "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_GROUP_PENALTY  = gsub(temp,                               "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (-%d raid penalty)"
	temp                  = gsub(COMBATLOG_XPGAIN_FIRSTPERSON_RAID,  "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_RAID           = gsub(temp,                               "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION1_RAID,  "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_RAID_RESTED    = gsub(temp,                               "%%d",    "(%%d+)")

	-- "%s dies, you gain %d experience. (%s exp %s penalty, -%d raid penalty)"
	temp                  = gsub(COMBATLOG_XPGAIN_EXHAUSTION4_RAID,  "(%%[0-9]$)([ds])", "%%%2")
	temp                  = gsub(temp,                               "[()+-]", "[%0]")
	temp                  = gsub(temp,                               "%%s",    "(.+)")
	XPGAIN_RAID_PENALTY   = gsub(temp,                               "%%d",    "(%%d+)")
	
	-- "Reputation with %s increased by %d."
	temp                  = gsub(FACTION_STANDING_INCREASED,        "(%%[0-9]$)([ds])", "%%%2") -- position indicators
	temp                  = gsub(temp,                              "%%s",   "(.+)")   -- string pattern
	REP_GAIN_SIMPLE       = gsub(temp,                              "%%d",   "(%%d+)") -- number pattern
	
	-- "Reputation with %s decreased by %d."
	temp                  = gsub(FACTION_STANDING_DECREASED,        "(%%[0-9]$)([ds])", "%%%2") -- position indicators
	temp                  = gsub(temp,                              "%%s",   "(.+)")   -- string pattern
	REP_LOSS_SIMPLE       = gsub(temp,                              "%%d",   "(%%d+)") -- number pattern
end

local updateHandler = {
	Spark                  = "UpdateBarSetting",
	Thickness              = "UpdateBarSetting",
	Length                 = "UpdateBarSetting",
	ShowXP                 = "UpdateXPBarSetting",
	ShowRep                = "UpdateRepBarSetting",
	ShowQuestCompletedXP   = "UpdateBarSetting",
	ShowQuestIncompleteXP  = "UpdateBarSetting",
	ShowQuestCompletedRep  = "UpdateBarSetting",
	ShowQuestIncompleteRep = "UpdateBarSetting",
	Shadow                 = "UpdateBarSetting",
	Inverse                = "UpdateBarSetting",
	ExternalTexture        = "UpdateTextureSetting",
	Texture                = "UpdateTextureSetting",
	NoTexture              = "UpdateBarSetting",
	Ticks                  = "UpdateBarSetting",
	ShowBarText            = "UpdateBarTextSetting",
	MouseOver              = "UpdateBarSetting",
	SideBySideText         = "UpdateBarSetting",
	SideBySideSeparator    = "UpdateBarSetting",
	Font                   = "UpdateBarSetting",
	FontSize               = "UpdateBarSetting",
	BarXPText              = "UpdateBarTextSetting",
	BarRepText             = "UpdateBarTextSetting",
	Frame                  = "UpdateBarSetting",
	Location               = "UpdateBarSetting",
	xOffset                = "UpdateBarSetting",
	yOffset                = "UpdateBarSetting",
	Strata                 = "UpdateBarSetting",
	Inside                 = "UpdateBarSetting",
	Jostle                 = "UpdateBarSetting",
	BlizzRep               = "UpdateRepColorSetting",
	ShowText               = "UpdateShowTextSetting",
	LabelXPText            = "UpdateLabelSetting",
	LabelRepText           = "UpdateLabelSetting",
	Separators             = "UpdateTextSetting",
	DecimalPlaces          = "UpdateTextSetting",
	AutoTrackOnGain        = "UpdateAutoTrackSetting",
	AutoTrackOnLoss        = "UpdateAutoTrackSetting",
	XP                     = "UpdateColorSetting",
	Rest                   = "UpdateColorSetting",
	QuestCompletedXP       = "UpdateColorSetting",
	QuestIncompleteXP      = "UpdateColorSetting",
	None                   = "UpdateColorSetting",
	Rep                    = "UpdateColorSetting",
	QuestCompletedRep      = "UpdateColorSetting",
	QuestIncompleteRep     = "UpdateColorSetting",
	NoRep                  = "UpdateColorSetting",
	TimeFrame              = "UpdateHistorySetting",
	Weight                 = "UpdateHistorySetting",
	MaxHideXPText          = "UpdateLabelSetting",
	MaxHideXPBar           = "UpdateXPBarSetting",
	MaxHideRepText         = "UpdateLabelSetting",
	MaxHideRepBar          = "UpdateRepBarSetting",
	ShowBlizzBars          = "UpdateBlizzardBarsSetting",
	Minimap                = "UpdateMinimapSetting",
	Notification           = "UpdateNotification",
	ToastNotification      = "UpdateNotification",
	XPCustomLabel          = "UpdateCustomText",
	XPCustomBar            = "UpdateCustomText",
	RepCustomLabel         = "UpdateCustomText",
	RepCustomBar           = "UpdateCustomText",
}

-- infrastructure
function Addon:OnInitialize()
	-- set module references
	Options           = self:GetModule("Options")
	Tooltip           = self:GetModule("Tooltip")
	MinimapButton     = self:GetModule("MinimapButton")
	DataBroker        = self:GetModule("DataBroker")
	Bar               = self:GetModule("Bar")
	Factions          = self:GetModule("Factions")
	History           = self:GetModule("History")
	ReputationHistory = self:GetModule("ReputationHistory")
	QuestInfo         = self:GetModule("QuestInfo")
	Notifications     = self:GetModule("Notifications")
	TextEngine        = self:GetModule("TextEngine")

	-- debug
	self.debug = false

	self:RegisterChatCommand("brokerxpbar", "ChatCommand")
	self:RegisterChatCommand("bxp",         "ChatCommand")	
end

function Addon:OnEnable()
	-- init session vars
	self.playerLvl      = UnitLevel("player")
	self.notifyLevel    = self.playerLvl
	self.notifyStanding = 0
	
	-- init xp history
	History:SetTimeFrame(self:GetSetting("TimeFrame") * 60)
	History:SetWeight(self:GetSetting("Weight"))

	-- init reputation history	
	ReputationHistory:SetTimeFrame(self:GetSetting("TimeFrame") * 60)
	ReputationHistory:SetWeight(self:GetSetting("Weight"))
	
	self:SetupEventHandlers()
	
	self:RegisterAutoTrack()
	
	self:UpdateIcon()

	-- if we don't want to show the bars we hide them else we leave them as they are
	if not self:GetSetting("ShowBlizzBars") then
		self:ShowBlizzardBars(false)
	end
	
	self:RefreshBarSettings()
	self:InitialAnchoring()
	
	MinimapButton:SetShow(Options:GetSetting("Minimap"))

	for id in TextEngine:IterateMutableTextIds() do
		local code = self:GetSetting(id)
		
		if code then
			TextEngine:SetCode(id, code)
		end
	end
	
	self:Update()
	-- Modules finish enabling after their parent. Read the watched faction on the
	-- next update, independently of anchor discovery or reputation history.
	self:ScheduleTimer("UpdateWatchedFactionIndex", 0)
end

function Addon:OnDisable()
	Bar:Hide()

	MinimapButton:SetShow(false)
	
	-- if we hid the bars ourselves we restore them else we leave them as they are
	if not self:GetSetting("ShowBlizzBars") then
		self:ShowBlizzardBars(true)
	end
	
	self:ResetEventHandlers()
	
	if self.timer then
		self:CancelTimer(self.timer)
		self.timer = nil
	end
	
	self:RegisterAutoTrack(false)
end

function Addon:OnOptionsReloaded()
	MinimapButton:SetShow(Options:GetSetting("Minimap"))
	self:ShowBlizzardBars(self:GetSetting("ShowBlizzBars")) 

	History:SetTimeFrame(self:GetSetting("TimeFrame") * 60)
	History:SetWeight(self:GetSetting("Weight"))
	
	ReputationHistory:SetTimeFrame(self:GetSetting("TimeFrame") * 60)
	ReputationHistory:SetWeight(self:GetSetting("Weight"))
	
	History:Process()
	ReputationHistory:ProcessFaction(self.faction)
	
	self:RegisterAutoTrack()

	self:RefreshBarSettings()
	
	self:UpdateWatchedFactionIndex()
end

function Addon:ChatCommand(input)
    if input then  
		args = NS:GetArgs(input)
		
		self:TriggerAction(unpack(args))
        
        NS:ReleaseTable(args)
	else
		self:TriggerAction("help")
	end
end

function Addon:OnClick(button)
	if ( button == "RightButton" ) then 
		if IsShiftKeyDown() then
			-- unused
		elseif IsControlKeyDown() then
			-- unused
		elseif IsAltKeyDown() then
			-- unused
		else
			-- open options menu
			self:TriggerAction("menu")
		end
	elseif ( button == "LeftButton" ) then 
		if IsShiftKeyDown() then
			-- reputation to open edit box
			self:TriggerAction("reputation")
		elseif IsControlKeyDown() then
			-- unused
		elseif IsAltKeyDown() then
			-- unused
		else
			-- xp to open edit box
			self:TriggerAction("xp")
		end
	end
end

function Addon:TriggerAction(action, ...)
    local args = NS:NewTable(...)

	action = type(action) == "string" and string.lower(action) or ""	

	if action == "xp" then
		-- xp to open edit box
		self:OutputExperience()
	elseif action == "reputation" then
		-- reputation to open edit box
		self:OutputReputation()
	elseif action == "menu" then
		-- open options menu
		Settings.OpenToCategory(self.frameName)
	elseif action == "debug" then
		if args[1] and string.lower(args[1]) == "on" then
			self:Output("debug mode turned on")
			self.debug = true
		end
		if args[1] and string.lower(args[1]) == "off" then
			self:Output("debug mode turned off")
			self.debug = false
		end
	elseif action == "setting" then
		self:Output("Setting: " .. tostring(args[1]) .. " = " .. tostring(self:GetSetting(args[1])))
	elseif action == "bar" then
		self:UserSetBarProgress(args[1], args[2])
	elseif action == "refresh" then
		Bar:Reanchor()
		self:Output("Refresh done.")
	elseif action == "update" then
		self:Update()
		self:Output("Update done.")
	elseif action == "text" then
		self:Output("TextEngine: id - " .. tostring(args[1]) .. ", mock - " .. tostring(args[2] and true or false) .. " : " .. TextEngine:GenerateText(args[1], args[2]))
	elseif action == "questinfo" then
		QuestInfo:Calculate()
	
		self:Output("QuestInfo: completed - " .. tostring(QuestInfo:GetValue("CompletedQuestXP")) .. ", incomplete - " .. tostring(QuestInfo:GetValue("IncompleteQuestXP")))
	elseif action == "faction" then
		Factions:GetFactionInfo(self.faction)
	elseif action == "version" then
		-- print version information
		self:PrintVersionInfo()
	else -- if action == "help" then
		-- display help
		self:Output(L["Usage:"])
		self:Output(L["/brokerxpbar arg"])
		self:Output(L["/bxp arg"])
		self:Output(L["Args:"])
		self:Output(L["version - display version information"])
		self:Output(L["menu - display options menu"])
		self:Output(L["help - display this help"])
	end
    
    NS:ReleaseTable(args)
end

function Addon:CreateTooltip(obj, autoHideDelay)
	Tooltip:Create(obj, autoHideDelay)
end

function Addon:RemoveTooltip()
	Tooltip:Remove()
end

function Addon:SetupEventHandlers()
	Options.RegisterCallback(self, ADDON .. "_SETTING_CHANGED", "UpdateSetting")
	QuestInfo.RegisterCallback(self, ADDON .. "_QUESTINFO_CHANGED", "UpdateQuestInfo")

	self:RegisterBucketEvent("UPDATE_EXHAUSTION", 60, "Update")
	
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "UpdateIcon")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:RegisterEvent("UPDATE_FACTION")

	if Addon.wowVersion == "retail" then
		self:RegisterEvent("QUEST_TURNED_IN")
		self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	end

	if self.playerLvl < self.MAX_LEVEL then
		self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
		self:RegisterEvent("PLAYER_XP_UPDATE")
		self:RegisterEvent("PLAYER_LEVEL_UP")
	else
		if Addon.wowVersion ~= "retail" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

function Addon:ResetEventHandlers()
	Options.UnregisterCallback(self, ADDON .. "_SETTING_CHANGED")
	QuestInfo.UnregisterCallback(self, ADDON .. "_QUESTINFO_CHANGED")

	self:UnregisterAllBuckets()
	
	self:UnregisterEvent("PLAYER_UPDATE_RESTING")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	self:UnregisterEvent("UPDATE_FACTION")
	
	if Addon.wowVersion == "retail" then
		self:UnregisterEvent("QUEST_TURNED_IN")
		self:UnregisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	end

	if self.playerLvl < self.MAX_LEVEL then
		self:UnregisterEvent("PLAYER_XP_UPDATE")
		self:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
		self:UnregisterEvent("PLAYER_LEVEL_UP")
	else
		if Addon.wowVersion ~= "retail" then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

function Addon:RegisterAutoTrack(register)
	if Addon.wowVersion == "retail" then
		return
	end
	if register == nil then
		register = self:GetSetting("AutoTrackOnGain") or self:GetSetting("AutoTrackOnLoss")
	end
	
	if register then
		self:RegisterEvent("COMBAT_TEXT_UPDATE")
	else
		self:UnregisterEvent("COMBAT_TEXT_UPDATE")
	end
end

function Addon:RefreshBarSettings()
	-- layout settings
	for option in Bar:IterateSettings() do
		if option == "ShowXP" then
			Bar:SetSetting(option, self:IsBarRequired("XP"), true)
		elseif option == "ShowRep" then
			Bar:SetSetting(option, self:IsBarRequired("Rep"), true)
		elseif option == "Texture" then
			Bar:SetSetting(option, self:GetSetting("ExternalTexture") and self:GetSetting("Texture") or nil, true)
		else
			Bar:SetSetting(option, self:GetSetting(option), true)
		end
	end

	-- update colors
	for id in Bar:IterateColors() do
		local r, g, b, a = Options:GetColor(id)
		
		if id == "Rep" and self:GetSetting("BlizzRep") then
			r, g, b, a = self:GetBlizzardReputationColor()
		end
		
		Bar:SetColor(id, r, g, b, a)
	end
	
	Bar:Reanchor()
end

function Addon:InitialAnchoring()
	-- try to attach to the anchor frame for 30 secs and then give up
	if not Bar:IsAnchored() and countInitial < 30 then
		Bar:Reanchor()
		countInitial = countInitial + 1
		self:ScheduleTimer("InitialAnchoring", 1)
	end
end

-- update functions
function Addon:Update()
	Notifications:Process(true)

	History:Process()
	ReputationHistory:ProcessMobHistory()
	ReputationHistory:ProcessFaction(self.faction)
	
	self:UpdateBar()
	self:UpdateLabel()
end

function Addon:UpdateBar()
	local temporal

	if self:GetSetting("ShowXP") then
		local currentXP = UnitXP("player")
		local maxXP     = UnitXPMax("player")
		local restXP    = GetXPExhaustion() or 0
		
		Bar:SetProgress("XP", maxXP > 0 and (currentXP / maxXP) or 0)
		Bar:SetProgress("Rested", maxXP > 0 and (restXP / maxXP) or 0)
		Bar:SetProgress("CompletedQuestXP", maxXP > 0 and (QuestInfo:GetValue("CompletedQuestXP")  / maxXP) or 0)
		Bar:SetProgress("IncompleteQuestXP", maxXP > 0 and (QuestInfo:GetValue("IncompleteQuestXP") / maxXP) or 0)
		
		local text, temporal = "", false
		
		if self:GetSetting("ShowBarText") then
			text, temporal = TextEngine:GenerateText(Options:GetSetting("BarXPText"))
			
			if temporal then
				self:ScheduleTextRefresh()
			end
		end
		
		Bar:SetText("XP", text)	
	end

	if self:GetSetting("ShowRep") then
		local total = 0
		local reputation = 0
		
		if self.faction then
			local name, _, standing, minRep, maxRep, currentRep = Factions:GetFactionInfo(self.faction)
			if name then
				total = maxRep - minRep
				reputation = currentRep - minRep
			end
		end

		Bar:SetProgress("Reputation", total > 0 and (reputation / total) or (self.atMaxRep and 1 or 0))
		Bar:SetProgress("CompletedQuestRep", total > 0 and (QuestInfo:GetValue("CompletedQuestRep") / total) or 0)
		Bar:SetProgress("IncompleteQuestRep", total > 0 and (QuestInfo:GetValue("IncompleteQuestRep") / total) or 0)

		local text, temporal = "", false

		if self.faction and self:GetSetting("ShowBarText") then
			text, temporal = TextEngine:GenerateText(Options:GetSetting("BarRepText"))
			
			if temporal then
				self:ScheduleTextRefresh()
			end
		end
		
		Bar:SetText("Reputation", text)
	end
		
	Bar:Update()
end

function Addon:UpdateLabel()
	local show = self:GetSetting("ShowText")

	if show == "XPFirst" then
		show = self.playerLvl == self.MAX_LEVEL and "Rep" or "XP"
	elseif show == "RepFirst" then
		show = (not self.faction or self.atMaxRep) and "XP" or "Rep"
	end
	
	local parts, temporal = {}, false
	
	if show == "XP" or show == "XPRep" then
		if self.playerLvl ~= self.MAX_LEVEL or not self:GetSetting("MaxHideXPText") then
			local text, changesWithTime = TextEngine:GenerateText(Options:GetSetting("LabelXPText"))
			if text ~= "" then parts[#parts + 1] = show == "XPRep" and ("XP: " .. text) or text end
			temporal = temporal or changesWithTime
		end
	end
	if show == "Rep" or show == "XPRep" then
		if self.faction and (not self.atMaxRep or not self:GetSetting("MaxHideRepText")) then
			local text, changesWithTime = TextEngine:GenerateText(Options:GetSetting("LabelRepText"))
			if text ~= "" then
				if show == "XPRep" then
					local name = Factions:GetFactionName(self.faction)
					if name ~= "" and not text:find(name, 1, true) then text = name .. ": " .. text end
				end
				parts[#parts + 1] = text
			end
			temporal = temporal or changesWithTime
		end
	end

	if temporal then
		self:ScheduleTextRefresh()
	end
	
	DataBroker:SetText(table.concat(parts, "  ·  "))
end

function Addon:UpdateIcon()
	local icon = self:GetIcon()
	
	DataBroker:SetIcon(icon)
	MinimapButton:SetIcon(icon)
end

function Addon:UpdateStanding()
	local standing = 0
	local friendmajorID = nil
	local barMax = 0
	local atMax = false
	
	if self.faction then
		_, _, standing, _, barMax, _, _, _, _, _, _, _, _, _, friendmajorID, atMax = Factions:GetFactionInfo(self.faction)

		ReputationHistory:UpdateByID(self.faction)
	end
	standing = standing or 0
	self.atMaxRep = atMax and true or false
	Bar:SetSetting("ShowRep", self:IsBarRequired("Rep"))
	
	local recolor = false
	
	if friendmajorID ~= self.watchedFriendID then
		self.watchedFriendID = friendmajorID
		
		recolor = true
	end
	
	if standing ~= self.watchedStanding then
		self.watchedStanding = standing

		recolor = true		
	end
	
	if recolor then
		if self:GetSetting("BlizzRep") then
			local paragon = false
			if self.faction and C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(self.faction) then
				paragon = true
			end
			local r, g, b, a = self:GetBlizzardReputationColor(standing, friendmajorID, paragon)

			Bar:SetColor("Rep", r, g, b, a)
		end
	end

	Notifications:Taint()
	
	self:Update()
end

function Addon:UpdateQuestInfo()
	Notifications:Taint()
	
	self:Update()
end

-- settings
function Addon:UpdateSetting(event, setting, value, old)
	local handler = updateHandler[setting]

	if handler == "UpdateBarSetting" then
		Bar:SetSetting(setting, value)
	elseif handler == "UpdateXPBarSetting" then
		Bar:SetSetting("ShowXP", self:IsBarRequired("XP"))
		
		self:UpdateBar()
	elseif handler == "UpdateRepBarSetting" then
		Bar:SetSetting("ShowRep", self:IsBarRequired("Rep"))

		self:UpdateBar()
	elseif handler == "UpdateTextureSetting" then
		Bar:SetSetting("Texture", Options:GetSetting("ExternalTexture") and Options:GetSetting("Texture") or nil)
	elseif handler == "UpdateBarTextSetting" then
		self:UpdateBar()
	elseif handler == "UpdateTextSetting" then
		self:Update()
	elseif handler == "UpdateRepColorSetting" then
		local r, g, b, a = Options:GetColor("Rep")

		if Options:GetSetting("BlizzRep") then
			r, g, b, a = self:GetBlizzardReputationColor()
		end

		Bar:SetColor("Rep", r, g, b, a)
	elseif handler == "UpdateLabelSetting" then
		self:UpdateLabel()
	elseif handler == "UpdateShowTextSetting" then
		self:UpdateLabel()
	elseif handler == "UpdateHistorySetting" then
		if setting == "TimeFrame" then
			History:SetTimeFrame(value * 60)
			ReputationHistory:SetTimeFrame(value * 60)
		elseif setting == "Weight" then
			History:SetWeight(value)
			ReputationHistory:SetWeight(value)
		end

		History:Process()
		ReputationHistory:Process()
	elseif handler == "UpdateAutoTrackSetting" then
		self:RegisterAutoTrack()
	elseif handler == "UpdateColorSetting" then
		if setting == "Rep" and self:GetSetting("BlizzRep") then
			return
		end
		
		Bar:SetColor(setting, value.r, value.g, value.b, value.a)	
	elseif handler == "UpdateNotification" then
		if self:GetSetting(setting) then
			Notifications:SettingChanged(setting)
		end
	elseif handler == "UpdateCustomText" then
		if TextEngine:SetCode(setting, value) then
			self:Update()
		end
	elseif handler == "UpdateBlizzardBarsSetting" then
		self:ShowBlizzardBars(value) 
	elseif handler == "UpdateMinimapSetting" then
		MinimapButton:SetShow(value)
	end
end

function Addon:GetSetting(setting)
	return Options:GetSetting(setting)
end

function Addon:GetFaction()
	return self.faction
end

-- Apply client state without writing it back. UPDATE_FACTION uses this path so
-- a watch change cannot cause a setter/event loop.
function Addon:ApplyFaction(factionId)
	factionId = tonumber(factionId)
	if not factionId or factionId <= 0 or not Factions:GetFactionInfo(factionId) then factionId = nil end
	local changed = factionId ~= self.faction
	self.faction = factionId
	if changed or not self.faction then
		self.watchedStanding = 0
		self.watchedFriendID = nil
		self.atMaxRep = false
	end

	if changed then Notifications:ResetType("Reputation") end
	QuestInfo:SetFaction(self.faction)
	
	self:UpdateStanding()
		
	Bar:SetSetting("ShowRep", self:IsBarRequired("Rep"))	
	
	Options:Update()
end

-- Selecting a faction in the addon must update Blizzard's watched faction as
-- well as our own bar. Previously factionId was ignored entirely.
function Addon:SetFaction(factionId)
	factionId = tonumber(factionId)
	if not factionId or factionId <= 0 then factionId = nil end
	if factionId and not Factions:GetFactionInfo(factionId) then return end
	if SetWatchedFactionID then
		SetWatchedFactionID(factionId or 0)
	else
		local setByIndex = C_Reputation and C_Reputation.SetWatchedFactionByIndex or SetWatchedFactionIndex
		if setByIndex then
			local index = factionId and Factions:GetFactionIndex(factionId) or 0
			setByIndex(index)
			Factions:RestoreUI()
		end
	end
	self:ApplyFaction(factionId)
end

-- utilities
function Addon:GetIcon()
	if IsResting() then
		return ICON_RESTING
	else
		return ICON
	end
end

function Addon:MaxLevelReached()
	if self.playerLvl == self.MAX_LEVEL then
		self:UnregisterEvent("PLAYER_XP_UPDATE")
		self:UnregisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
		self:UnregisterEvent("PLAYER_LEVEL_UP")
		
		if Addon.wowVersion ~= "retail" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
				
		Bar:SetSetting("ShowXP", self:IsBarRequired("XP"))
	end
end

function Addon:MaxReputationReached()
	if not self.atMaxRep then
		self.atMaxRep = true
		
		Bar:SetSetting("ShowRep", self:IsBarRequired("Rep"))
	end
end

function Addon:ScheduleTextRefresh()
	if not self.timer then
		self.timer = self:ScheduleTimer("ScheduledTextRefresh", 1)
	end
end

function Addon:ScheduledTextRefresh()
	self.timer = null
	
	self:Update()
end

-- events
function Addon:PLAYER_XP_UPDATE()
	Notifications:Taint()
	History:UpdateXP()

	self:Update()
end

function Addon:CHAT_MSG_COMBAT_XP_GAIN(_, xpMsg)
	if issecretvalue and issecretvalue(xpMsg) then
		return
	end
	-- kill, rested, group, penalty, raid penalty
	local kxp, rxp, gxp, pxp, rpxp
	local bonusType
	local kill = 0
	local mob
	
	if GetNumGroupMembers() > 0 then
		if IsInRaid() then
			mob, kxp, rpxp = smatch(xpMsg, XPGAIN_RAID)
			
			if not mob then
				mob, kxp, rxp, bonusType, rpxp = smatch(xpMsg, XPGAIN_RAID_RESTED)
			end
			
			if not mob then
				mob, kxp, pxp, bonusType, rpxp = smatch(xpMsg, XPGAIN_RAID_PENALTY)
			end
		else
			mob, kxp, gxp = smatch(xpMsg, XPGAIN_GROUP)
			
			if not mob then
				mob, kxp, rxp, bonusType, gxp = smatch(xpMsg, XPGAIN_GROUP_RESTED)
			end
			
			if not mob then
				mob, kxp, pxp, bonusType, gxp = smatch(xpMsg, XPGAIN_GROUP_PENALTY)
			end
		end
	end

	-- raid penalty not always applies it seems
	if not mob then
		mob, kxp, rxp, bonusType = smatch(xpMsg, XPGAIN_SINGLE_RESTED)
	end
	
	if not mob then
		mob, kxp, pxp, bonusType = smatch(xpMsg, XPGAIN_SINGLE_PENALTY)
	end

	if not mob then
		mob, kxp = smatch(xpMsg, XPGAIN_SINGLE)
	end
	
	if mob then 
		kill = 1
		
		-- rested bonus is marked as string in the constant for some reason
		rxp = tonumber(rxp)
		-- for koKR and ruRU rxp and bonustype are exchanged
		if not rxp and bonusType then
			rxp = tonumber(bonusType)
		end
		-- penalty is marked as string in the constant for some reason
		pxp = tonumber(pxp)
		-- for koKR and ruRU pxp and bonustype are exchanged
		if not pxp and bonusType then
			pxp = tonumber(bonusType)
		end
		
		kxp  = kxp  or 0
		rxp  = rxp  or 0
		gxp  = gxp  or 0
		pxp  = pxp  or 0
		rpxp = rpxp or 0

		-- pure kill xp: subtract bonuses, add penalties 
		kxp = kxp - rxp - gxp + pxp + rpxp
	else
		kxp = 0
	end

	if kill == 0 then
		return
	end

	History:AddKill(kxp, gxp, rpxp)
	ReputationHistory:AddKill()
	
	self:Update()
end

function Addon:PLAYER_LEVEL_UP(_, newLevel)
	self.playerLvl = newLevel

	if self.playerLvl == self.MAX_LEVEL then
		-- PLAYER_LEVEL_UP seems to be triggered before PLAYER_XP_UPDATE
		-- so we delay the unregister a bit
		self:ScheduleTimer("MaxLevelReached", 3)
	end
end

-- TODO: bound to CombatTextSetActiveUnit("unit")
--       could track incorrect unit
function Addon:COMBAT_TEXT_UPDATE(event, msgType)
	if msgType ~= "FACTION" then
		return
	end
	
	local factionName, arg3, arg4 = GetCurrentCombatTextEventInfo();
	local amount = tonumber(arg3)

	if (amount < 0 and self:GetSetting("AutoTrackOnLoss")) or 
	   (amount > 0 and self:GetSetting("AutoTrackOnGain")) then
		if factionName then
			-- NOTE: if rep is gained with guild the factionName passed is the generic 'Guild' instead of the guild name
			--       this matches with the header entry in the faction list, so we have to get the real guild name instead
			--       since factionName is localized we need to perform the 'Guild' check against a localized string
			--       hopefully CHAT_MSG_GUILD is equal to the factionName argument in all languages
			if factionName == CHAT_MSG_GUILD then
				local guildName = GetGuildInfo("player")
				
				factionName = guildName
			end
			
			local faction = Factions:GetFactionByName(factionName)
			
			ReputationHistory:TryRegisterKillReputation(faction, amount)
			self:SetFaction(faction)
		end
	end	
end

function Addon:PLAYER_ENTERING_WORLD(_, isLogin, isReload)
	if not isLogin and not isReload then
		self:UpdateIcon()
	end
	self:UpdateWatchedFactionIndex()
end

function Addon:CHAT_MSG_COMBAT_FACTION_CHANGE()
	self:UpdateStanding()
end

function Addon:COMBAT_LOG_EVENT_UNFILTERED(timestamp, logEvent)
	if logEvent == "PARTY_KILL" then
		History:AddKill(0, 0, 0)
		ReputationHistory:AddKill()
	end
end

function Addon:QUEST_TURNED_IN(_, questID)
	local paragon_questID = { --[questID] = factionID
		-- Legion
			[48976] = 2170, -- Argussian Reach
			[46777] = 2045, -- Armies of Legionfall
			[48977] = 2165, -- Army of the Light
			[46745] = 1900, -- Court of Farondis
			[46747] = 1883, -- Dreamweavers
			[46743] = 1828, -- Highmountain Tribes
			[46748] = 1859, -- The Nightfallen
			[46749] = 1894, -- The Wardens
			[46746] = 1948, -- Valarjar
		-- Battle for Azeroth
			-- Neutral
			[54453] = 2164, -- Champions of Azeroth
			[58096] = 2415, -- Rajani
			[55348] = 2391, -- Rustbolt Resistance
			[54451] = 2163, -- Tortollan Seekers
			[58097] = 2417, -- Uldum Accord
			-- Horde
			[54460] = 2156, -- Talanji's Expedition
			[54455] = 2157, -- The Honorbound
			[53982] = 2373, -- The Unshackled
			[54461] = 2158, -- Voldunai
			[54462] = 2103, -- Zandalari Empire
			-- Alliance
			[54456] = 2161, -- Order of Embers
			[54458] = 2160, -- Proudmoore Admiralty
			[54457] = 2162, -- Storm's Wake
			[54454] = 2159, -- The 7th Legion
			[55976] = 2400, -- Waveblade Ankoan
		-- Shadowlands
			[61100] = 2413, -- Court of Harvesters
			[64012] = 2470, -- Death's Advance
			[64266] = 2472, -- The Archivist's Codex
			[61097] = 2407, -- The Ascended
			[64087] = 2478, -- The Enlightened
			[61095] = 2410, -- The Undying Army
			[61098] = 2465, -- The Wild Hunt
			[64267] = 2432, -- Ve'nari
		-- Dragonflight
			[66156] = 2507, -- Dragonscale Expedition
			[76425] = 2574, -- Dream Wardens
			[66511] = 2511, -- Iskaara Tuskarr
			[75290] = 2564, -- Loamm Niffen
			[65606] = 2503, -- Maruuk Centaur
			[71023] = 2510, -- Valdrakken Accord
		-- The War Within
			[79219] = 2590, -- Council of Dornogal
			[79218] = 2570, -- Hallowfall Arathi
			[79220] = 2594, -- The Assembly of the Deep
			[79196] = 2600, -- The Severed Threads
			[79196] = 2600, -- The Severed Threads
			[83739] = 2605, -- The General
			[83740] = 2607, -- The Vizier
			[83738] = 2601, -- The Weaver
			[85471] = 2685, -- Gallagio Loyalty Rewards Club
			[85805] = 2653, -- The Cartels of Undermine
			[85806] = 2673, -- Bilgewater Cartel
			[85807] = 2675, -- Blackwater Cartel
			[85808] = 2669, -- Darkfuse Solutions
			[85809] = 2677, -- Steamwheedle Cartel
			[85810] = 2671, -- Venture Company
			[89515] = 2688, -- Flame's Radiance
			[85109] = 2658, -- The K'aresh Trust
		-- Midnight
			[93566] = 2696, -- Amani Tribe
			[89035] = 2704, -- Hara'ti
			[93811] = 2710, -- Silvermoon Court
			[94492] = 2770, -- Slayer's Duellum
			[89032] = 2699, -- The Singularity
	}
	
	if paragon_questID[questID] == self.faction then
		C_Timer.After(0.1, function()
			self:UpdateLabel()
		end)
	end
end


function Addon:UPDATE_FACTION()
	self:UpdateWatchedFactionIndex()
end

-- faction functions
function Addon:UpdateWatchedFactionIndex()
	local watchedFactionData = GetWatchedFactionData and GetWatchedFactionData()
	self:ApplyFaction(watchedFactionData and watchedFactionData.factionID)
end

function Addon:MAJOR_FACTION_RENOWN_LEVEL_CHANGED()
	self:UpdateWatchedFactionIndex()
end

-- auxiliary functions
function Addon:Output(msg)
	if ( msg ~= nil and DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( self.MODNAME..": "..msg, 0.6, 1.0, 1.0 )
	end
end

function Addon:Debug(msg)
	if self.debug and DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(self.MODNAME .. " (dbg): " .. tostring(msg), 1.0, 0.37, 0.37)
	end
end

function Addon:GetBlizzardReputationColor(standing, friendship, paragon)
	if not standing then
		standing   = self.watchedStanding
		friendship = self.watchedFriendID 
	end
		
	return Factions:GetBlizzardReputationColor(standing, friendship, paragon)
end

function Addon:IsBarRequired(bar)
	if bar == "XP" then
		if self:GetSetting("ShowXP") then
			return self.playerLvl < self.MAX_LEVEL or not self:GetSetting("MaxHideXPBar")
		end
	elseif bar == "Rep" then
		if self:GetSetting("ShowRep") and self.faction then
			return not self.atMaxRep or not self:GetSetting("MaxHideRepBar")
		end
	end
	
	return false
end

function Addon:ShowBlizzardBars(show)
	if show then
		-- restore the blizzard frames
		StatusTrackingBarManager:Show()
	else
		-- hide the blizzard frames
		StatusTrackingBarManager:Hide()
	end
end

function Addon:FormatNumber(number, prefix)
	if not prefix then
		prefix = ""
	end

	if type(prefix) ~= "string" then
		return number
	end
	
	return NS:FormatNumber(number, self:GetSetting("Separators"), self:GetSetting(prefix .. "Abbreviations"), self:GetSetting("DecimalPlaces"))
end

-- user functions
function Addon:OutputExperience()
	if self.playerLvl < self.MAX_LEVEL then
		local totalXP = UnitXPMax("player")
		local currentXP = UnitXP("player")
		local toLevelXP = totalXP - currentXP
		local xpEx = GetXPExhaustion() or 0

		local xpExPercent = floor((xpEx / totalXP) * 100)

		DEFAULT_CHAT_FRAME.editBox:SetText(string.format(L["%s/%s (%3.0f%%) %d to go (%3.0f%% rested)"], 
					currentXP,
					totalXP, 
					(currentXP/totalXP)*100, 
					totalXP - currentXP, 
					xpExPercent))
	else
		self:Output(L["Maximum level reached."])
	end
					
end

function Addon:OutputReputation()
	if self.faction then
		local name, desc, standing, minRep, maxRep, currentRep, _, _, _, _, _, _, _, _, friendmajorID = Factions:GetFactionInfo(self.faction)
		DEFAULT_CHAT_FRAME.editBox:SetText(string.format(L["%s: %s/%s (%3.2f%%) Currently %s with %d to go"],
					name,
					currentRep - minRep,
					maxRep - minRep, 
					(currentRep-minRep)/(maxRep-minRep)*100,
					Factions:GetStandingLabel(standing, friendmajorID),
					maxRep - currentRep))
	else
		self:Output(L["Currently no faction tracked."])
	end
end

function Addon:PrintVersionInfo()
    self:Output(L["Version"] .. " " .. NS:Colorize("White", C_AddOns.GetAddOnMetadata(ADDON, "Version")))
end

function Addon:UserSetBarProgress(bar, progress)
	local current = Bar:GetProgress(bar)
	
	if current then
		if not progress then
			self:Output("Current progress of bar " .. bar .. ": " .. tostring(current))
			
			return
		end
	
		local fraction = tonumber(progress)
		
		if not fraction then
			self:Output("No valid value given for bar progress: " .. tostring(progress))
		end
	
		Bar:SetProgress(bar, fraction)
		Bar:Update()
		
		self:Output("Progress of bar " .. bar .. " set to " .. tostring(Bar:GetProgress(bar)) .. " (from : " .. tostring(current) .. ")")
	else
		self:Output("Unknown bar: " .. tostring(bar))
	end
end

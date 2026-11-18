local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the QuestInfo module
local QuestInfo = Addon:NewModule("QuestInfo", "AceEvent-3.0")

-- internal event handling
QuestInfo.callbacks = LibStub("CallbackHandler-1.0"):New(QuestInfo)

-- LibQuestForGlory
local LibQFG = LibStub:GetLibrary("LibQuestForGlory-1.0")

-- modules
local Options

-- local functions
local C_QuestLog_GetNumQuestLogEntries   = _G.C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetSelectedQuest     = _G.C_QuestLog.GetSelectedQuest -- GetQuestLogSelection()
local GetMoney                 = _G.GetMoney
local C_QuestLog_GetTitleForLogIndex  = _G.C_QuestLog.GetTitleForLogIndex -- GetQuestLogTitle()
local C_QuestLog_SetSelectedQuest     = _G.C_QuestLog.SetSelectedQuest -- SelectQuestLogEntry()
local C_QuestLog_GetRequiredMoney     = _G.C_QuestLog.GetRequiredMoney -- GetQuestLogRequiredMoney()
local GetNumQuestLeaderBoards  = _G.GetNumQuestLeaderBoards
local GetQuestLogRewardXP      = _G.GetQuestLogRewardXP
local C_QuestLog_GetQuestIDForLogIndex = _G.C_QuestLog.GetQuestIDForLogIndex

local _

local factionBonuses = {}

local moduleData = {
	-- data
	values = {
		CompletedQuestXP   = 0,
		IncompleteQuestXP  = 0,
		CompletedQuestRep  = 0,
		IncompleteQuestRep = 0,
	},	
	factions = {},	
	faction = nil,
	lastFinishedQuest = nil,
}

-- module handling
function QuestInfo:OnInitialize()	
    Options = Addon:GetModule("Options")
	
	-- init the module
	self:Initialize()
end

function QuestInfo:OnEnable()
	self:SetupEvents()
	
	LibQFG:SetPlayerHasTradingPostLvl3(Options:GetCharSetting("TradingPostLvl3"))
	LibQFG:CheckForLvl3TradingPost()
	
	self:Calculate()
end

function QuestInfo:OnDisable()
	self:ShutdownEvents()

	self:Reset()
end

function QuestInfo:Initialize()
	self:Reset()
end

function QuestInfo:SetupEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Calculate")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "Calculate")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("PLAYER_LEVEL_UP", "Calculate")
	
	-- check for reputation buffs
    LibQFG.RegisterCallback(self, "BonusChanged", "Calculate")
end

function QuestInfo:ShutdownEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("QUEST_LOG_UPDATE")
	self:UnregisterEvent("PLAYER_LEVEL_UP")
	
	-- check for reputation buffs
    LibQFG.UnregisterCallback(self, "BonusChanged")
end

function QuestInfo:QUEST_LOG_UPDATE()
	self:Calculate()
	
	moduleData.lastFinishedQuest = nil
end

function QuestInfo:QUEST_TURNED_IN(event, questID, experience, money)
	moduleData.lastFinishedQuest = questID
	
	self:Calculate()
end

function QuestInfo:Reset()
	self:SetValue("CompletedQuestXP", 0) 
	self:SetValue("IncompleteQuestXP", 0) 
end

function QuestInfo:IsQuestComplete(index, money)
	money = money and money or GetMoney()

	local questID = C_QuestLog_GetQuestIDForLogIndex(index)
	local isComplete  = C_QuestLog.IsComplete(questID)
	
	local numObjectives = GetNumQuestLeaderBoards(index)
	local requiredMoney = C_QuestLog.GetRequiredMoney(questID)
	
	if numObjectives == 0 and money >= requiredMoney then
		-- breadcrumb quest without objectives other than money
		isComplete = true
	end
	
	return isComplete and true or false
end

function QuestInfo:Calculate()
	local completedXP   = 0
	local incompleteXP  = 0
	
	self:ResetFactionValues()
	
	NS:ClearTable(factionBonuses)
	
	local baseBonus = LibQFG:GetBaseBonus()
		
	local numQuestsEntries = C_QuestLog_GetNumQuestLogEntries()
	
	if numQuestsEntries > 0 then
		local origquestID = C_QuestLog_GetSelectedQuest()
		local index = 0
		local money = GetMoney()
		
		for index = 1, numQuestsEntries, 1 do
			local info = C_QuestLog.GetInfo(index)

			if info.questID ~= moduleData.lastFinishedQuest and info.title and not info.isHeader then
				C_QuestLog.SetSelectedQuest(info.questID)
				
				local isComplete = self:IsQuestComplete(index, money)								
				local xp = GetQuestLogRewardXP()

				self:CalculateReputationRewards(index, isComplete, baseBonus, factionBonuses, lvl3TradingPostBonus)
				
				if isComplete then
					completedXP = completedXP + xp
				else
					incompleteXP = incompleteXP + xp
				end
			end
		end
		
		C_QuestLog_SetSelectedQuest(origquestID)
	end
	
	Options:SetCharSetting("TradingPostLvl3", LibQFG:PlayerHasTradingPostLvl3())
	
	self:SetValue("CompletedQuestXP", completedXP) 
	self:SetValue("IncompleteQuestXP", incompleteXP) 
	self:SetValue("CompletedQuestRep", self:GetFactionValue(self:GetFaction(), "CompletedQuestRep")) 
	self:SetValue("IncompleteQuestRep", self:GetFactionValue(self:GetFaction(), "IncompleteQuestRep")) 
end

function QuestInfo:CalculateReputationRewards(index, isComplete, baseBonus, factionBonuses)
	if isComplete == nil then
		isComplete = self:IsQuestComplete(index)
	end

	local id = isComplete and "CompletedQuestRep" or "IncompleteQuestRep"	

	local questID = C_QuestLog_GetQuestIDForLogIndex(index)

	C_QuestLog_SetSelectedQuest(questID)
	
	-- NOTE: For some reason Blizzard broke/removed the operation of GetNumQuestLogRewardFactions() and GetQuestLogRewardFactionInfo(i).
	--       Instead of providing the correct data for the quest set via SelectQuestLogEntry(index)
	--       the data that is returned is that of the quest most recently selected with mouse in the quest log of the UI.
	--       So querying of xp, item, spell and skill rewards is valid, but not reputation. Great!
	--       Instead we now query a library containing data mined information.
        --
	-- local count = GetNumQuestLogRewardFactions()
	-- local faction, amount
	--
	-- for i = 1, count, 1 do
	--     local faction, amount = GetQuestLogRewardFactionInfo(i)
	--
	--     self:SetFactionValue(faction, id, self:GetFactionValue(faction, id) + floor(amount / 100))
	-- end

	if questID == moduleData.lastFinishedQuest then
		return
	end
	
	baseBonus = baseBonus and baseBonus or LibQFG:GetBaseBonus()
	
	local lookupFactions = type(factionBonuses) == "table"
	local questBonus = LibQFG:GetQuestBonus(questID)
	
	local faction, factionBonus, bonus, reputationReward
		
	for faction in LibQFG:IterateFactionIds(questID) do
		if lookupFactions then
			if not factionBonuses[faction] then
				factionBonuses[faction] = LibQFG:GetFactionBonus(faction)
			end
		
			factionBonus = factionBonuses[faction]
		else
			factionBonus = LibQFG:GetFactionBonus(faction)
		end
	
		bonus = baseBonus + factionBonus + questBonus
		reputationReward = (LibQFG:GetBaseReward(questID, faction) or 0) * (1 + bonus)
			
		self:SetFactionValue(faction, id, self:GetFactionValue(faction, id) + reputationReward)
	end	
end

function QuestInfo:GetValue(id)
	return moduleData.values[id]
end

function QuestInfo:SetValue(id, value)
	if not moduleData.values[id] then
		return
	end
	
	value = value < 0 and 0 or value
	
	local current = self:GetValue(id)
	
	if current == value then
		return
	end

	moduleData.values[id] = value
	
	-- fire event when quest info changed
	self.callbacks:Fire(ADDON .. "_QUESTINFO_CHANGED", id, value, current)
end

function QuestInfo:SetFaction(faction)
	if self.faction == faction then
		return
	end

	self.faction = faction
	
	local factionData = faction and moduleData.factions[faction]
	
	self:SetValue("CompletedQuestRep", self:GetFactionValue(faction, "CompletedQuestRep"))
	self:SetValue("IncompleteQuestRep", self:GetFactionValue(faction, "IncompleteQuestRep"))
end

function QuestInfo:GetFaction()
	return self.faction
end

function QuestInfo:GetFactionValue(faction, id)
	local factionData = faction and moduleData.factions[faction]
	
	return factionData and factionData[id] or 0
end

function QuestInfo:SetFactionValue(faction, id, value)
	local factionData = faction and moduleData.factions[faction]
	
	if not factionData then
		factionData = {
			CompletedQuestRep = 0,
			IncompleteQuestRep = 0,
		}
		
		moduleData.factions[faction] = factionData
	end
	
	if not factionData[id] then
		return
	end
	
	factionData[id] = value
end

function QuestInfo:ResetFactionValues()
	for faction, data in pairs(moduleData.factions) do
		data.CompletedQuestRep = 0
		data.IncompleteQuestRep = 0
	end
end

-- test
function QuestInfo:Debug(msg)
	Addon:Debug("(QuestInfo) " .. tostring(msg))
end

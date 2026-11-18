-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the QuestInfo module
local QuestInfo = Addon:NewModule("QuestInfo", "AceEvent-3.0")

-- internal event handling
QuestInfo.callbacks = LibStub("CallbackHandler-1.0"):New(QuestInfo)

-- modules
local Options

-- local functions (Common)
local GetMoney                 = GetMoney
local GetNumQuestLeaderBoards  = GetNumQuestLeaderBoards
local GetQuestLogRewardXP      = GetQuestLogRewardXP

-- local functions (Retail)
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog and C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetSelectedQuest = C_QuestLog and C_QuestLog.GetSelectedQuest
local C_QuestLog_GetTitleForLogIndex = C_QuestLog and C_QuestLog.GetTitleForLogIndex
local C_QuestLog_SetSelectedQuest = C_QuestLog and C_QuestLog.SetSelectedQuest
local C_QuestLog_GetRequiredMoney = C_QuestLog and C_QuestLog.GetRequiredMoney
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog and C_QuestLog.GetQuestIDForLogIndex

-- local functions (Classic)
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogSelection = GetQuestLogSelection
local GetQuestLogTitle = GetQuestLogTitle
local SelectQuestLogEntry = SelectQuestLogEntry
local GetQuestLogRequiredMoney = GetQuestLogRequiredMoney

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
end

function QuestInfo:ShutdownEvents()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("QUEST_LOG_UPDATE")
	self:UnregisterEvent("PLAYER_LEVEL_UP")
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
    local questID = C_QuestLog_GetQuestIDForLogIndex(index)
    return questID and C_QuestLog.IsComplete(questID) or false
end

function QuestInfo:IsQuestComplete_Classic(index, money)
	money = money and money or GetMoney()

	local _, _, _, _, _, isComplete  = GetQuestLogTitle(index)
	
	local numObjectives = GetNumQuestLeaderBoards(index)
	local requiredMoney = GetQuestLogRequiredMoney(index)		
	
	if isComplete and isComplete < 0 then
		isComplete = false
	elseif numObjectives == 0 and money >= requiredMoney then
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
	
	if Addon.wowVersion == "retail" then
		local numQuestsEntries = C_QuestLog_GetNumQuestLogEntries()
		
		if numQuestsEntries > 0 then
			local origquestID = C_QuestLog_GetSelectedQuest()
			local index = 0
			local money = GetMoney()
			
			for index = 1, numQuestsEntries, 1 do
				local info = C_QuestLog.GetInfo(index)

				if info and info.questID ~= moduleData.lastFinishedQuest and info.title and not info.isHeader then
					local isComplete = self:IsQuestComplete(index, money)
					local xp = GetQuestLogRewardXP(info.questID) or 0

					if isComplete then
						completedXP = completedXP + xp
					else
						incompleteXP = incompleteXP + xp
					end
				end
			end
			

		end
	else
		local numQuestsEntries = GetNumQuestLogEntries()
		
		if numQuestsEntries > 0 then
			local origIndex = GetQuestLogSelection()
			local index = 0
			local money = GetMoney()
			
			for index = 1, numQuestsEntries, 1 do
				local title, _, _, isHeader, _, _, _, questId = GetQuestLogTitle(index)

				if questId ~= moduleData.lastFinishedQuest and title and not isHeader then
					SelectQuestLogEntry(index)
					
					local isComplete = self:IsQuestComplete_Classic(index, money)								
					local xp = GetQuestLogRewardXP()

					if isComplete then
						completedXP = completedXP + xp
					else
						incompleteXP = incompleteXP + xp
					end
				end
			end
		
			SelectQuestLogEntry(origIndex)
		end
	end
	
	self:SetValue("CompletedQuestXP", completedXP) 
	self:SetValue("IncompleteQuestXP", incompleteXP) 
	self:SetValue("CompletedQuestRep", self:GetFactionValue(self:GetFaction(), "CompletedQuestRep")) 
	self:SetValue("IncompleteQuestRep", self:GetFactionValue(self:GetFaction(), "IncompleteQuestRep")) 
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

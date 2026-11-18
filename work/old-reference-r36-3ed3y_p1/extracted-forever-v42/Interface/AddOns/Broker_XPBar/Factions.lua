local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- the Factions module
local Factions = Addon:NewModule("Factions")

-- local functions (Common)
local pairs   = pairs
local tinsert = table.insert

-- local functions
local CollapseFactionHeader = C_Reputation and C_Reputation.CollapseFactionHeader or CollapseFactionHeader
local ExpandFactionHeader = C_Reputation and C_Reputation.ExpandFactionHeader or ExpandFactionHeader
local GetNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
local C_Reputation_GetFactionDataByIndex = C_Reputation and C_Reputation.GetFactionDataByIndex
local C_Reputation_GetFactionDataByID = C_Reputation and C_Reputation.GetFactionDataByID
local C_Reputation_IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo
local C_Reputation_IsMajorFaction = C_Reputation and C_Reputation.IsMajorFaction
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_GetRenownLevels = C_MajorFactions and C_MajorFactions.GetRenownLevels
local C_MajorFactions_GetCurrentRenownLevel = C_MajorFactions and C_MajorFactions.GetCurrentRenownLevel
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo and C_GossipInfo.GetFriendshipReputation
local C_GossipInfo_GetFriendshipReputationRanks = C_GossipInfo and C_GossipInfo.GetFriendshipReputationRanks

-- aux variables
local _

-- setup libs
local LibStub   = LibStub

-- module data
local moduleData = {
}

local friendStanding = {
	[1] = "Stranger",
	[2] = "Acquaintance",
	[3] = "Buddy",
	[4] = "Friend",
	[5] = "Good Friend",
	[6] = "Best Buddy",
}

local blizzRepColors = {
	[1] = {r=0.80, g=0.13, b=0.13, a=1}, -- hated
	[2] = {r=1.00, g=0.25, b=0.00, a=1}, -- hostile
	[3] = {r=0.93, g=0.40, b=0.13, a=1}, -- unfriendly
	[4] = {r=1.00, g=1.00, b=0.00, a=1}, -- neutral
	[5] = {r=0.00, g=0.70, b=0.00, a=1}, -- friendly
	[6] = {r=0.00, g=1.00, b=0.00, a=1}, -- honoured
	[7] = {r=0.00, g=0.70, b=0.40, a=1}, -- revered
	[8] = {r=0.00, g=1.00, b=1.00, a=1}, -- exalted
	[9] = {r=0.00, g=0.50, b=0.90, a=1}, -- paragon
}

-- module handling
function Factions:OnInitialize()	
	self:Setup()
end

function Factions:OnEnable()
	-- empty
end

function Factions:OnDisable()
	-- empty
end

function Factions:Setup()
end

function Factions:GetFactionInfo(factionId)
	return self:GetFactionInfoByIdOrIndex(factionId)
end

function Factions:GetFactionInfoByIndex(factionIndex)
	return self:GetFactionInfoByIdOrIndex(nil, factionIndex)
end

-- reputation interface (merging friendship into rep)
function Factions:GetFactionInfoByIdOrIndex(factionId, factionIndex)
	local useId = true

	if type(factionId) ~= "number" or factionId < 1 then
		if type(factionIndex) ~= "number" or factionIndex < 1 or factionIndex > GetNumFactions() then
			return
		else
			useId = false
		end
	end

	local name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, atMax

	if Addon.wowVersion == "retail" then
		local factionData
		if useId then
			factionData = C_Reputation_GetFactionDataByID(factionId)
			if not factionData and C_Reputation.GetWatchedFactionData then
				local watched = C_Reputation.GetWatchedFactionData()
				if watched and watched.factionID == factionId then factionData = watched end
			end
		else
			factionData = C_Reputation_GetFactionDataByIndex(factionIndex)
			factionId = factionData and factionData.factionID
		end
		if not factionData then return end
		-- Group headings can have no faction ID or progress values. Preserve their
		-- folding state so IterateAllFactions can reach the reputations inside.
		if factionData.isHeader and not factionData.isHeaderWithRep then
			return factionData.name, factionData.description, 0, 0, 0, 0,
				factionData.atWarWith, factionData.canToggleAtWar, true, factionData.isCollapsed,
				false, factionData.isWatched, factionData.isChild, factionId or 0, 0, false
		end
		if not factionId or factionId <= 0 then return end
		local repInfo = C_GossipInfo_GetFriendshipReputation and C_GossipInfo_GetFriendshipReputation(factionId)
		local friendmajorID = repInfo and repInfo.friendshipFactionID or 0
		local pending
		name, description, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = factionData.name, factionData.description, factionData.atWarWith, factionData.canToggleAtWar, factionData.isHeader, factionData.isCollapsed, factionData.isHeaderWithRep, factionData.isWatched, factionData.isChild

		if C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionId) then
			local majordata = C_MajorFactions_GetMajorFactionData(factionId)
			local levelInfo = C_MajorFactions_GetRenownLevels(factionId)
			standingId = C_MajorFactions_GetCurrentRenownLevel(factionId)
			local maxRank = majordata.maxLevel
			atMax = C_MajorFactions_HasMaximumRenown(factionId)
			barMin = 0
			barMax = majordata.renownLevelThreshold
			barValue = atMax and majordata.renownLevelThreshold or majordata.renownReputationEarned or 0
			friendmajorID = factionId
		else
			if friendmajorID == 0 then
				standingId, barMin, barMax, barValue = factionData.reaction, 0, factionData.nextReactionThreshold - factionData.currentReactionThreshold, factionData.currentStanding - factionData.currentReactionThreshold
				atMax = standingId == 8
			else
				-- store localized standing text
				local rankInfo = C_GossipInfo_GetFriendshipReputationRanks(factionId)
				standingId = rankInfo.currentLevel
				local maxRank = rankInfo.maxLevel

				if maxRank > 6 and not friendStanding[standingId] then
					friendStanding[standingId] = {}
				end
				friendStanding[standingId] = repInfo.reaction.." "..standingId.."/"..maxRank

				barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
				if not barMax then
					barMax = barMin
					atMax = true
				end
			end
		end

		if C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(factionId) and atMax then
			atMax = false
			barMin = 0
			pending = 0
			local hasPending
			local currentValue = 0
			currentValue, barMax, _, hasPending = C_Reputation_GetFactionParagonInfo(factionId)
			local level = math.floor(currentValue / barMax) - (hasPending and 1 or 0)
			barValue = math.floor(currentValue - barMax * (level + (hasPending and 1 or 0)))
			if hasPending then
				if barValue == (barMax - 1) then
					pending = 2
				else
					pending = 1
				end
			end
		end

		return name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, friendmajorID, atMax, pending
	elseif Addon.wowVersion == "mop" then
		if useId then
			name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfoByID(factionId)
		else
			name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId = GetFactionInfo(factionIndex)
			-- faction not found
			if not factionId then
				return
			end
		end
		local repInfo = C_GossipInfo_GetFriendshipReputation(factionId)
		local friendID = repInfo and repInfo.friendshipFactionID or 0

		if friendID == 0 then
			atMax = standingId == 8 and barValue + 1 == barMax
		else
			-- store localized standing text
			local rankInfo = C_GossipInfo_GetFriendshipReputationRanks(factionId)
			standingId = rankInfo.currentLevel
			local maxRank = rankInfo.maxLevel

			if maxRank > 6 and not friendStanding[standingId] then
				friendStanding[standingId] = {}
			end
			friendStanding[standingId] = repInfo.reaction

			barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing
			if not barMax then
				atMax = true
			end
		end

		return name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, friendID, atMax

	else
		if useId then
			name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfoByID(factionId)
		else
			name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId = GetFactionInfo(factionIndex)
			-- faction not found
			if not factionId then
				return
			end
		end

		atMax = standingId == 8 and barValue + 1 == barMax
		
		return name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, friendID, atMax
	end
end

-- NOTE: does not restore folding state of ui list because that would invalidate the returned index
function Factions:GetFactionIndex(factionId)
	if not factionId then
		return 0
	end
	
	for index, id in Factions:IterateAllFactions() do
		local _, _, _, _, _, _, _, _, _, _, _, _, _, id = self:GetFactionInfo(id)
		
		if factionId == id then
			return index
		end
	end
	
	return 0
end

-- NOTE: does not restore folding state of ui list because that would invalidate the returned index
function Factions:GetFactionIndexByName(factionName, expand)
	if not factionName then
		return 0
	end
	
	for index, id in Factions:IterateAllFactions() do
		local name = self:GetFactionInfo(id)
		
		if factionName == name then
			return index
		end
	end
	
	return 0
end

function Factions:GetFactionByName(factionName)
	if not factionName then
		return
	end
	
	local factionId
	
	for index, id in Factions:IterateAllFactions() do
		local name, _, _, _, _, _, _, _, _, _, _, _, _, id = self:GetFactionInfo(id)
		
		if factionName == name then
			factionId = id
			
			break
		end
	end
	
	-- restore folding state of factions in ui list
	self:RestoreUI()
	
	return factionId
end

function Factions:GetStandingLabel(standing, friendmajor, paragon, pending)
	if friendmajor and type(friendmajor) == "table" then -- Classic doesn't return friend ID but returns variables table of faction info
		friendmajor = nil
	end
	if paragon then
		if pending and pending > 0 then
			return L["Paragon"].." (+"..pending..")" or "???"
		else
			return L["Paragon"] or "???"
		end
	else
		if friendmajor and friendmajor > 0 then
			if C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(friendmajor) then
				return string.format(_G["RENOWN_LEVEL_LABEL"], standing) or "???"
			else
				return friendStanding[standing] or "???"
			end
		else
			return _G["FACTION_STANDING_LABEL"..tostring(standing)] or "???"
		end
	end
end

function Factions:GetBlizzardReputationColor(standing, friendmajor, paragon)
	local r, g, b, a = 0, 0, 0, 0
	
	if friendmajor and type(friendmajor) == "table" then -- Classic doesn't return friend ID but variables table of faction info
		friendmajor = nil
	end

	if type(standing) == "number" then
		if friendmajor and friendmajor > 0 then
			if standing <= 6 then
				standing = standing + 2
			elseif standing >= 7 then
				standing = 7
			end
		end
	
		if paragon then
			r = blizzRepColors[9].r
			g = blizzRepColors[9].g
			b = blizzRepColors[9].b
			a = blizzRepColors[9].a
		else
			if Addon.wowVersion == "retail" and friendmajor and friendmajor > 0 and C_Reputation_IsMajorFaction(friendmajor) then
				r = _G["BLUE_FONT_COLOR"].r
				g = _G["BLUE_FONT_COLOR"].g
				b = _G["BLUE_FONT_COLOR"].b
				a = _G["BLUE_FONT_COLOR"].a
			else
				if blizzRepColors[standing] then
					r = blizzRepColors[standing].r
					g = blizzRepColors[standing].g
					b = blizzRepColors[standing].b
					a = blizzRepColors[standing].a
				end
			end
		end
	end
		
	return r, g, b, a
end

function Factions:GetFactionName(faction)
	local name = self:GetFactionInfo(faction) or ""

	return name
end

-- iterators

local unfoldedHeaders = {}

-- iterator that unfolds the ui so all factions can be accessed
function Factions:IterateAllFactions()
	-- in case RestoreUI has not been called
	NS:ClearTable(unfoldedHeaders)
	
	local index  = 0
	local unfold = false

	return function()
		if unfold then
			ExpandFactionHeader(index)
			
			tinsert(unfoldedHeaders, index)
		end

		index = index + 1

		if index <= GetNumFactions() then
			local name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _, factionId = Factions:GetFactionInfoByIndex(index)
			unfold = isHeader and isCollapsed
			
			return index, factionId
		end
	end
end

-- function to restore ui state before the last iterator call
function Factions:RestoreUI()
	-- collapse in reverse order
	for index = #unfoldedHeaders, 1, -1 do
		CollapseFactionHeader(unfoldedHeaders[index])
	end
		
	NS:ClearTable(unfoldedHeaders)
end	

-- test
function Factions:Debug(msg)
	Addon:Debug("(Factions) " .. tostring(msg))
end

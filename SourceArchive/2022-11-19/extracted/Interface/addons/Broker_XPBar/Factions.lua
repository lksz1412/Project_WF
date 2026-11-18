local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- the Factions module
local Factions = Addon:NewModule("Factions")

-- local functions
local pairs   = pairs
local tinsert = table.insert

local CollapseFactionHeader        = _G.CollapseFactionHeader
local ExpandFactionHeader          = _G.ExpandFactionHeader
local GetFactionInfo               = _G.GetFactionInfo
local C_GossipInfo_GetFriendshipReputation      = _G.C_GossipInfo.GetFriendshipReputation
local C_GossipInfo_GetFriendshipReputationRanks = _G.C_GossipInfo.GetFriendshipReputationRanks
local GetNumFactions               = _G.GetNumFactions
local C_Reputation_IsFactionParagon   = _G.C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsMajorFaction = _G.C_Reputation.IsMajorFaction
local C_MajorFactions_GetMajorFactionData = _G.C_MajorFactions.GetMajorFactionData
local C_MajorFactions_GetRenownLevels = _G.C_MajorFactions.GetRenownLevels
local C_MajorFactions_GetCurrentRenownLevel = _G.C_MajorFactions.GetCurrentRenownLevel
local C_MajorFactions_HasMaximumRenown = _G.C_MajorFactions.HasMaximumRenown

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
	
	local name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild

	if useId then
		name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfoByID(factionId)
	else
		name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId = GetFactionInfo(factionIndex)
	end
	
	-- faction not found
	if not name or not factionId then
		return
	end
	
	-- NOTE: GetFriendshipReputationRanks(factionId) apparently no longer returns the maxRank
	--       since I haven't found any other way to query the max rank for a faction or a buddy via the API those values are now hard coded
	local rankinfo = C_GossipInfo_GetFriendshipReputationRanks(factionId)
	local maxRank = rankinfo.maxLevel

	local repinfo = C_GossipInfo_GetFriendshipReputation(factionId)
	local friendmajorID = repinfo.friendshipFactionID
	local levelInfo
	
	if rankinfo.maxLevel == 0 then
		maxRank = 8
	else
		maxRank = rankinfo.maxLevel
		standingId = rankinfo.currentLevel
		
		-- store localized standing text
		if maxRank > 6 and not friendStanding[standingId] then
			friendStanding[standingId] = {}
		end
		friendStanding[standingId] = repinfo.reaction
		
		barMin   = repinfo.reactionThreshold
		barMax   = repinfo.nextThreshold or barMin
		barValue = repinfo.standing
	end
	
	local atMax = standingId == maxRank and barValue == barMax
	local hasPending

	if C_Reputation_IsMajorFaction(factionId) then
		local majordata = C_MajorFactions_GetMajorFactionData(factionId)
		levelInfo = C_MajorFactions_GetRenownLevels(factionId)
		standingId = C_MajorFactions_GetCurrentRenownLevel(factionId)
		maxRank = #levelInfo
		atMax = C_MajorFactions_HasMaximumRenown(factionId)
		barMin = 0
		barMax = majordata.renownLevelThreshold
		barValue = atMax and majordata.renownLevelThreshold or majordata.renownReputationEarned or 0
		friendmajorID = factionId
	end

	if standingId == maxRank and C_Reputation_IsFactionParagon(factionId) then
		atMax = false
		barMin = 0
		barValue, barMax, _, hasPending = C_Reputation_GetFactionParagonInfo(factionId)
                if (barValue and barValue >= 10000) then
			local equation = barValue / 10000
			local base = math.floor(equation);
			barValue = math.floor((equation - base) * 10000)
                end
		if hasPending then
			if barValue == 9999 then
				hasPending = 2
			else
				hasPending = 1
			end
		else
			hasPending = 0
		end
	end

	return name, description, standingId, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionId, friendmajorID, atMax, hasPending, maxRank
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
	if paragon then
		if pending and pending > 0 then
			return L["Paragon"].." (+"..pending..")" or "???"
		else
			return L["Paragon"] or "???"
		end
	else
		if friendmajor > 0 then
			if C_Reputation_IsMajorFaction(friendmajor) then
				return _G["RENOWN_LEVEL_LABEL"]..standing or "???"
			else
				return friendStanding[standing] or "???"
			end
		else
			return _G["FACTION_STANDING_LABEL"..tostring(standing)] or "???"
		end
	end
end

function Factions:GetBlizzardReputationColor(standing, maxRank, friendmajor, paragon)
	local r, g, b, a = 0, 0, 0, 0
	
	if type(standing) == "number" then
		if friendmajor and friendmajor > 0 then
			standing = math.floor(standing / maxRank * 4)
			if standing == 1 then
				standing = standing + 3
			else
				standing = standing + 4
			end
		end
	
		if paragon then
			r = blizzRepColors[9].r
			g = blizzRepColors[9].g
			b = blizzRepColors[9].b
			a = blizzRepColors[9].a
		else
			if friendmajor and friendmajor > 0 and C_Reputation_IsMajorFaction(friendmajor) then
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

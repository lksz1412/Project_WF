local function print(msg)
	ChatFrame1:AddMessage(msg, 1.0, 1.0, 0.2)
end

local debug = false

local MAJOR_VERSION = "LibCombatParser-1.0"
local MINOR_VERSION = 6

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end -- No upgrade needed

local oldLib
if oldMinor then
	oldLib = {}
	for k,v in pairs(lib) do
		oldLib[k] = v
		lib[k] = nil
	end
end

local frame
-- frame for events
if oldLib and oldLib.frame then
	frame = oldLib.frame
	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	for k in pairs(frame) do
		if k ~= 0 then
			frame[k] = nil
		end
	end
else
	frame = CreateFrame("Frame", MAJOR_VERSION .. "_Frame", UIParent)
end
lib.frame = frame

local registry = oldLib and oldLib.registry or {}
lib.registry = registry

local tinsert = table.insert
local tremove = table.remove

local roster = {}
local rosterPet = {}
local rosterPetOwner = {}

local MELEE				= 0x00000001
local RANGE				= 0x00000002
local ATTACK_TYPE_MASK	= 0x00000003

-- Bit flags.
local AFFILIATION_MINE		= COMBATLOG_OBJECT_AFFILIATION_MINE
local AFFILIATION_PARTY		= COMBATLOG_OBJECT_AFFILIATION_PARTY
local AFFILIATION_RAID		= COMBATLOG_OBJECT_AFFILIATION_RAID
local AFFILIATION_OUTSIDER	= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER
local AFFILIATION_MASK		= COMBATLOG_OBJECT_AFFILIATION_MASK

local REACTION_FRIENDLY		= COMBATLOG_OBJECT_REACTION_FRIENDLY
local REACTION_NEUTRAL		= COMBATLOG_OBJECT_REACTION_NEUTRAL
local REACTION_HOSTILE		= COMBATLOG_OBJECT_REACTION_HOSTILE
local REACTION_MASK			= COMBATLOG_OBJECT_REACTION_MASK

local CONTROL_PLAYER		= COMBATLOG_OBJECT_CONTROL_PLAYER
local CONTROL_NPC			= COMBATLOG_OBJECT_CONTROL_NPC
local CONTROL_MASK			= COMBATLOG_OBJECT_CONTROL_MASK

local UNITTYPE_PLAYER		= COMBATLOG_OBJECT_TYPE_PLAYER
local UNITTYPE_NPC			= COMBATLOG_OBJECT_TYPE_NPC
local UNITTYPE_PET			= COMBATLOG_OBJECT_TYPE_PET
local UNITTYPE_GUARDIAN		= COMBATLOG_OBJECT_TYPE_GUARDIAN
local UNITTYPE_OBJECT		= COMBATLOG_OBJECT_TYPE_OBJECT
local UNITTYPE_MASK			= COMBATLOG_OBJECT_TYPE_MASK

local OBJECT_TARGET			= COMBATLOG_OBJECT_TARGET
local OBJECT_FOCUS			= COMBATLOG_OBJECT_FOCUS
local OBJECT_MAINTANK		= COMBATLOG_OBJECT_MAINTANK
local OBJECT_MAINASSIST		= COMBATLOG_OBJECT_MAINASSIST
local OBJECT_RAIDTARGET1	= COMBATLOG_OBJECT_RAIDTARGET1
local OBJECT_RAIDTARGET2	= COMBATLOG_OBJECT_RAIDTARGET2
local OBJECT_RAIDTARGET3	= COMBATLOG_OBJECT_RAIDTARGET3
local OBJECT_RAIDTARGET4	= COMBATLOG_OBJECT_RAIDTARGET4
local OBJECT_RAIDTARGET5	= COMBATLOG_OBJECT_RAIDTARGET5
local OBJECT_RAIDTARGET6	= COMBATLOG_OBJECT_RAIDTARGET6
local OBJECT_RAIDTARGET7	= COMBATLOG_OBJECT_RAIDTARGET7
local OBJECT_RAIDTARGET8	= COMBATLOG_OBJECT_RAIDTARGET8
local OBJECT_NONE			= COMBATLOG_OBJECT_NONE
local OBJECT_SPECIAL_MASK	= COMBATLOG_OBJECT_SPECIAL_MASK
local OBJECT_RAIDTARGET_MASK= COMBATLOG_OBJECT_RAIDTARGET_MASK


local FLAGS_ME				= bit.bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_PLAYER, UNITTYPE_PLAYER)
local FLAGS_MY_PET			= bit.bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_PLAYER, UNITTYPE_PET)
local FLAGS_MY_GUARDIAN		= bit.bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_PLAYER, UNITTYPE_GUARDIAN) -- Totems, Traps, guardians(like a "Nature of Force")
local FLAGS_MY_OBJECT		= bit.bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_PLAYER, UNITTYPE_OBJECT)

local TABLE_MISS_TYPES			= {
	["MISS"]					= MISS,
	["RESIST"]					= RESIST,
	["DODGE"]					= DODGE,
	["EVADE"]					= EVADE,
	["IMMUNE"]					= IMMUNE,
	["REFLECT"]					= REFLECT,
	["DEFLECT"]					= DEFLECT,
	["BLOCK"]					= BLOCK,
	["ABSORB"]					= ABSORB,
	["PARRY"]					= PARRY,
}

local function IsNPCID(guid) -- from Threat-2.0
	return tonumber(guid:sub(-12,-7),16)
end

local function TestFlagsAll(unitFlags, testFlags)
	if (bit.band(unitFlags, testFlags) == testFlags) then return true end
end

local function TestObjectIsA(unitFlags,  ... )
	for k, flagType in pairs( {...} ) do
		if (
			(
			bit.band( bit.band ( unitFlags, flagType ), AFFILIATION_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), REACTION_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), CONTROL_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), UNITTYPE_MASK ) > 0
			)
			or
			bit.band( bit.band ( unitFlags, flagType ), OBJECT_SPECIAL_MASK ) > 0
		) then
			return true
		end
	end

	return false
end

local function ExtraInfo(unitInfo, unitFlags)

	if TestFlagsAll(unitFlags, FLAGS_ME) then
		unitInfo.me = true
		unitInfo.unit = "player"
	elseif TestFlagsAll(unitFlags, FLAGS_MY_PET) then
		unitInfo.myPet = true
		unitInfo.unit = "pet"
	elseif TestFlagsAll(unitFlags, FLAGS_MY_GUARDIAN) then
		unitInfo.myGuardian = true
	elseif TestFlagsAll(unitFlags, FLAGS_MY_OBJECT) then
		unitInfo.myObject = true
	end
	if TestFlagsAll(unitFlags, OBJECT_TARGET) then
		unitInfo.isTarget = true
		unitInfo.unit = "target"
	end
	if TestFlagsAll(unitFlags, OBJECT_FOCUS) then
		unitInfo.isFocus = true
		if not unitInfo.unit then unitInfo.unit = "focus" end
	end
	if TestFlagsAll(unitFlags, OBJECT_RAIDTARGET1) then
		unitInfo.isRT1 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET2) then
		unitInfo.isRT2 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET3) then
		unitInfo.isRT3 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET4) then
		unitInfo.isRT4 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET5) then
		unitInfo.isRT5 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET6) then
		unitInfo.isRT6 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET7) then
		unitInfo.isRT7 = true
	elseif TestFlagsAll(unitFlags, OBJECT_RAIDTARGET8) then
		unitInfo.isRT8 = true
	end
end
local new, del
do
	local cache = setmetatable({}, {__mode='k'})
	function new()
		local t = next(cache)
		if t then
			cache[t] = nil
			return t
		else
			return {}
		end
	end

	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end

local rmem, pmem, unit
local function scanRoster()
	for k, v in pairs(roster) do
		roster[k] = nil
	end
	for k, v in pairs(rosterPet) do
		rosterPet[k] = nil
	end
	for k, v in pairs(rosterPetOwner) do
		rosterPetOwner[k] = nil
	end

	rmem = GetNumRaidMembers()
	if rmem == 0 then
		pmem = GetNumPartyMembers()
		if pmem > 0 then
			for i=1, pmem do
				unit = "party"..i
				roster[UnitGUID(unit)] = unit
				unit = "partypet"..i
				if UnitExists(unit) then
					roster[UnitGUID(unit)] = unit
					rosterPet[UnitGUID("party"..i)] = UnitGUID(unit)
					rosterPetOwner[UnitGUID(unit)] = UnitGUID("party"..i)
				end
			end
		end
	else
		for i=1, rmem do
			unit = "raid"..i
			roster[UnitGUID(unit)] = unit
			unit = "raidpet"..i
			if UnitExists(unit) then
				roster[UnitGUID(unit)] = unit
				rosterPet[UnitGUID("raid"..i)] = UnitGUID(unit)
				rosterPetOwner[UnitGUID(unit)] = UnitGUID("raid"..i)
			end
		end
	end
--	if UnitGUID("player") then
--		roster[UnitGUID("player")] = "player"
--	end
	if UnitExists("pet") then
		roster[UnitGUID("pet")] = "pet"
		rosterPet[UnitGUID("player")] = UnitGUID("pet")
		rosterPetOwner[UnitGUID("pet")] = UnitGUID("player")
	end
end

local info

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
frame:RegisterEvent("UNIT_PET")
frame:SetScript("OnEvent",
function(self, event, ...)
		if self[event] and type(self[event])=='function' then
			self[event](self, ...)
		end
	end
)

function frame:RAID_ROSTER_UPDATE() scanRoster() end
frame.PARTY_MEMBERS_CHANGED = frame.RAID_ROSTER_UPDATE
frame.UNIT_PET = frame.RAID_ROSTER_UPDATE

function frame:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = select(1, ...)
	self:parser(timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, select( 9, ... ))
end

function frame:CHAT_MSG_COMBAT_FACTION_CHANGE(...)
	local msg = select(1,...)
	info = new()
	for faction, amount in msg:gmatch("(.+)에 대한 평판이 (%d+)만큼 상승했습니다%.") do
		info.type = 'reputation'
		info.faction = faction
		info.amount = tonumber(amount)
	end
	for faction, amount in msg:gmatch("(.+)에 대한 평판이 (%d+)만큼 하락했습니다%.") do
		info.type = 'reputation'
		info.faction = faction
		info.amount = tonumber(amount)*-1
	end
	for faction, rank in msg:gmatch("(.+)에 대해 (.+) 평판이 되었습니다%.") do
		info.type = 'reputation'
		info.faction = faction
		info.amount = rank
	end
	if not info.type then
		return
	end
	-- trigger event
	for func in pairs(registry) do
		local success, ret = pcall(func, info)
		if not success then
			geterrorhandler()(ret)
		end
	end
end

function frame:parser(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	local spell, spellId, spellName, spellSchool
	local extraSpellId, extraSpellName, extraSpellSchool

	-- Damage standard order
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isDOT, overhealing
	-- Miss argument order
	local missType, amountMissed
	-- Aura arguments
	local auraType -- BUFF or DEBUFF

	-- Enchant arguments
	local itemId, itemName

	-- Special Spell values
	local extraAmount -- Used for Drains and Leeches
	local powerType -- Used for energizes, drains and leeches
	local environmentalType -- Used for environmental damage

	local source = new()
	local dest = new()

	info = new()
	info.spell = {}
	info.item = {}
	info.source = {}
	info.dest = {}

	if UnitGUID("player") and not roster[UnitGUID("player")] then
		roster[UnitGUID("player")] = true
	end

	if ( sourceName and not TestObjectIsA(sourceFlags, OBJECT_NONE) ) then
		source.name = sourceName
		source.guid = sourceGUID
		source.flags = sourceFlags
		source.unit = roster[source.guid]
		source.petguid = rosterPet[source.guid]
		source.ownerguid = rosterPetOwner[source.guid]
		ExtraInfo(source, sourceFlags)
		info.source = source
	end
	if ( destName and not TestObjectIsA(destFlags, OBJECT_NONE) ) then
		dest.name = destName
		dest.guid = destGUID
		dest.flags = destFlags
		dest.unit = roster[dest.guid]
		dest.petguid = rosterPet[dest.guid]
		dest.ownerguid = rosterPetOwner[dest.guid]
		ExtraInfo(dest, destFlags)
		info.dest = dest
	end

	local subVal = strsub(event, 1, 5)

	if ( event == "SWING_DAMAGE" ) then
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		info.type = 'hit'
		info.amount = amount
		info.overkill = overkill > 0 and overkill or nil
		info.school = school
		info.isCrit = critical
		info.resisted = resisted
		info.blocked = blocked
		info.absorbed = absorbed
		info.glancing = glancing
		info.crushing = crushing
		info.spell = {
			school = school,
		}
	elseif ( event == "SWING_MISSED" ) then
		missType, amountMissed = ...
		info.type = 'miss'
		info.missType = TABLE_MISS_TYPES[missType] or MISS
		if missType == "RESIST" and amountMissed ~= 0 then
			info.resisted = amountMissed
		elseif missType == "BLOCK" and amountMissed ~= 0 then
			info.blocked = amountMissed
		elseif missType == "ABSORB" and amountMissed ~= 0 then
			info.absorbed = amountMissed
		end

	elseif ( subVal == "RANGE" ) then

		-- Shots are spells, technically
		spellId, spellName, spellSchool = select(1, ...)
		info.spell = {
			name = spellName,
			id = spellId,
			school = spellSchool, -- fake-_-;;
		}
		info.isRange = true

		if ( event == "RANGE_DAMAGE" ) then
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)

			info.type = 'hit'
			info.amount = amount
			info.overkill = overkill > 0 and overkill or nil
			info.spell.school = school
			info.isCrit = critical
			info.resisted = resisted
			info.blocked = blocked
			info.absorbed = absorbed
			info.glancing = glancing
			info.crushing = crushing
		elseif ( event == "RANGE_MISSED" ) then
			missType = select(4, ...)
			info.type = 'miss'
			info.missType = TABLE_MISS_TYPES[missType] or MISS
		end
	
	elseif ( subVal == "SPELL" ) then
		spellId, spellName, spellSchool = select(1, ...)
		info.spell = {
			name = spellName,
			id = spellId,
			school = spellSchool,
		}

		if event == "SPELL_DAMAGE" or event == "SPELL_BUILDING_DAMAGE" then
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)
			info.type = 'hit'
			info.amount = amount
			info.overkill = overkill > 0 and overkill or nil
			info.school = school
			info.isCrit = critical
			info.resisted = resisted
			info.blocked = blocked
			info.absorbed = absorbed
			info.glancing = glancing
			info.crushing = crushing
		elseif event == "SPELL_MISSED" then
			missType,  amountMissed = select(4, ...)
			info.type = 'miss'
			info.missType = TABLE_MISS_TYPES[missType] or MISS
			if missType == "RESIST" and amountMissed > 0 then
				info.resisted = amountMissed
			elseif missType == "BLOCK" and amountMissed > 0 then
				info.blocked = amountMissed
			elseif missType == "ABSORB" and amountMissed > 0 then
				info.absorbed = amountMissed
			end
		elseif ( event == "SPELL_HEAL" or event == "SPELL_BUILDING_HEAL" ) then
			--amount, critical = select(4, ...)
			amount, overhealing, absorbed, critical = select(4, ...)
			info.type = 'heal'
			info.amount = amount
			info.isCrit = critical
			info.absorbed = absorbed
			if dest.unit then
				if (overhealing > 0) then info.overhealAmount = overhealing end
			end
		elseif ( event == "SPELL_ENERGIZE" ) then
			amount, powerType = select(4, ...)
			info.type = 'energize'
			info.amount = amount
			info.powerType = powerType
		elseif ( strsub(event, 1, 14) == "SPELL_PERIODIC" ) then

			info.isDOT = true

			if ( event == "SPELL_PERIODIC_MISSED" ) then
				missType = select(4, ...)
				info.type = 'miss'
				info.missType = TABLE_MISS_TYPES[missType] or MISS
			elseif ( event == "SPELL_PERIODIC_DAMAGE" ) then
				amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...)
				info.type = 'hit'
				info.amount = amount
				info.overkill = overkill > 0 and overkill or nil
				info.school = school
				info.isCrit = critical
				info.resisted = resisted
				info.blocked = blocked
				info.absorbed = absorbed
				info.glancing = glancing
				info.crushing = crushing
			elseif ( event == "SPELL_PERIODIC_HEAL" ) then
				amount, overhealing, absorbed, critical = select(4, ...)
				info.type = 'heal'
				info.amount = amount
				info.isCrit = critical
				info.absorbed = absorbed
				if dest.unit then
					if (overhealing > 0) then info.overhealAmount = overhealing end
				end
			elseif ( event == "SPELL_PERIODIC_DRAIN" ) then
				amount, powerType, extraAmount = select(4, ...)
				info.type = 'drain'
				info.amount = amount
				info.powerType = powerType
				info.extraAmount = extraAmount
				--print("나왔다. SPELL_PERIODIC_DRAIN "..spellName)
			elseif ( event == "SPELL_PERIODIC_LEECH" ) then
				amount, powerType, extraAmount = select(4, ...)
				info.type = 'leech'
				info.amount = amount
				info.powerType = powerType
				info.extraAmount = extraAmount
				--print("나왔다. SPELL_PERIODIC_LEECH "..spellName)
			elseif ( event == "SPELL_PERIODIC_ENERGIZE" ) then
				amount, powerType = select(4, ...)
				info.type = 'energize'
				info.amount = amount
				info.powerType = powerType
			end
		elseif strsub(event, 1, 10) == "SPELL_CAST" then
			if event == "SPELL_CAST_START" then
				info.type = 'cast'
				info.castType = 'start'
			end
			if event == "SPELL_CAST_SUCCESS" then
				info.type = 'cast'
				info.castType = 'success'
			end
			if event == "SPELL_CAST_FAILED" then
				local missType = select(4, ...)
				info.type = 'cast'
				info.castType = 'fail'
				info.reason = missType
			end

		elseif ( event == "SPELL_DRAIN" ) then
			amount, powerType, extraAmount = select(4, ...)
			info.type = 'drain'
			info.amount = amount
			info.powerType = powerType
			info.extraAmount = extraAmount
			--print("나왔다. SPELL_DRAIN "..spellName)

		elseif ( event == "SPELL_LEECH" ) then
			amount, powerType, extraAmount = select(4, ...)
			info.type = 'leech'
			info.amount = amount
			info.powerType = powerType
			info.extraAmount = extraAmount
			--print("나왔다. SPELL_LEECH "..spellName)

		elseif ( event == "SPELL_INTERRUPT" ) then
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...)
			info.type = 'interrupt'
			info.extraSpell = {
				name = extraSpellName,
				id = extraSpellId,
				school = extraSpellSchool,
			}

		elseif ( event == "SPELL_EXTRA_ATTACKS" ) then
			amount = select(4, ...)
			info.type = 'extraattack'
			info.amount = amount

		elseif ( event == "SPELL_INSTAKILL" ) then -- 인스타킬?
			--print("나왔다. 인스타킬 "..spellName)
			return
		elseif ( event == "SPELL_DURABILITY_DAMAGE" ) then
			-- 본적 없음 - _-
			return

		elseif ( event == "SPELL_DURABILITY_DAMAGE_ALL" ) then
			-- 본적 없음 - _-
			return

		elseif ( event == "SPELL_DISPEL_FAILED" ) then
			return

		elseif ( event == "SPELL_DISPEL" or event == "SPELL_STOLEN" ) then
			extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...)
			if ( extraSpellId ) then
				info.type = 'dispel'
				info.auraType = auraType
				info.extraSpell = {
					name = extraSpellName,
					id = extraSpellId,
					school = extraSpellSchool,
				}
			else
				return
			end

		elseif ( event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL" ) then
			-- Extra Spell standard, Aura standard
			if(event == "SPELL_AURA_BROKEN") then
				auraType = select(4, ...)
			else
				extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...)
			end
			
			info.type = 'dispel'
			info.auraType = auraType
			if ( extraSpellId ) then
				info.extraSpell = {
					name = extraSpellName,
					id = extraSpellId,
					school = extraSpellSchool,
				}
			end

		elseif ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_APPLIED_DOSE" ) then
			auraType, amount = select(4, ...)
			amount = amount or 1
			info.amount = amount
			if auraType == "BUFF" then
				info.type = 'buff'
			else
				info.type = 'debuff'
			end

		elseif ( event == "SPELL_AURA_REFRESH" ) then
			auraType, amount = select(4, ...)
			amount = amount or 1
			info.amount = amount
			if auraType == "BUFF" then
				info.type = 'buff'
			else
				info.type = 'debuff'
			end

		elseif event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_REMOVED_DOSE" then
			auraType, amount = select(4, ...)
			amount = amount or 1
			if auraType == "BUFF" then
				info.type = 'buff'
			else
				info.type = 'debuff'
			end
			info.isFade = true
			info.amount = amount
			info.auraType = auraType
		end
	
	elseif ( event == "DAMAGE_SHIELD" ) then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		info.type = 'hit'
		info.amount = amount
		info.overkill = overkill > 0 and overkill or nil
		info.spell = {
			name = spellName,
			id = spellId,
			school = school,
		}
		info.isCrit = critical
		info.resisted = resisted
		info.blocked = blocked
		info.absorbed = absorbed
		info.glancing = glancing
		info.crushing = crushing
		info.isDS = true

	elseif ( event == "DAMAGE_SHIELD_MISSED" ) then
		spellId, spellName, spellSchool, missType = ...
		info.type = 'miss'
		info.missType = TABLE_MISS_TYPES[missType] or MISS
		info.spell = {
			name = spellName,
			id = spellId,
			school = spellSchool,
		}
		info.isDS = true

	elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
		environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		info.type = 'hit'
		info.amount = amount
		info.overkill = overkill > 0 and overkill or nil
		info.spell = {
			name = environmentalType,
			school = school,
		}
		info.isCrit = critical
		info.resisted = resisted
		info.blocked = blocked
		info.absorbed = absorbed
		info.glancing = glancing
		info.crushing = crushing
		info.isEnvironmental = true

	elseif ( event == "DAMAGE_SPLIT" ) then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...

		info.type = 'hit'
		info.amount = amount
		info.overkill = overkill > 0 and overkill or nil
		info.spell = {
			name = spellName,
			id = spellId,
			school = school,
		}
		info.isCrit = critical
		info.resisted = resisted
		info.blocked = blocked
		info.absorbed = absorbed
		info.glancing = glancing
		info.crushing = crushing
		info.isSplit = true

	elseif ( event == "ENCHANT_APPLIED" ) then
		spellName, itemId, itemName  = select(1,...)
		info.type = 'enchant'
		info.spell = {
			name = spellName,
		}
		info.item = {
			name = itemName,
			id = itemId,
		}
	
	elseif ( event == "ENCHANT_REMOVED" ) then
		spellName, itemId, itemName  = select(1,...)
		info.type = 'enchant'
		info.spell = {
			name = spellName,
		}
		info.item = {
			name = itemName,
			id = itemId,
		}
		info.isFade = true

	elseif event == "PARTY_KILL" then
		info.type = "death"

	elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" then
		-- Swap Source with Dest
		--[[sourceName = destName
		sourceGUID = destGUID
		sourceFlags = destFlags
		]]--
	end

	if not info.type then
		return
	end

	-- trigger event
	for func in pairs(registry) do
		local success, ret = pcall(func, info)
		if not success then
			geterrorhandler()(ret)
		end
	end
end

function lib:AddListener(tab, method)
	local func
	if type(tab) == "table" then
		if type(method) ~= "string" then
			error(("Bad argument #3 to `AddListener'. Expected %q, got %q."):format("string", type(method)), 2)
		elseif type(tab[method]) ~= "function" then
			error(("Bad argument #3 to `AddListener'. Expected method, got %q."):format(type(tab[method])), 2)
		end
		func = function(...)
			return tab[method](tab, ...)
		end
	elseif type(tab) == "function" then
		func = tab
	else
		error(("Bad argument #2 to `AddListener'. Expected %q or %q, got %q."):format("table", "function", type(tab)), 2)
	end

	registry[func] = true
end

--lib:OnLoad()

--[[

"SWING_DAMAGE"
amount, school, resisted, blocked, absorbed, critical, glancing, crushing

"SWING_MISSED"
missType

"RANGE_DAMAGE"
spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing

"RANGE_MISSED"
spellId, spellName, spellSchool, missType

"SPELL_DAMAGE"
spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing

"SPELL_MISSED"
spellId, spellName, spellSchool, missType

"SPELL_HEAL"
spellId, spellName, spellSchool, amount, critical

"SPELL_ENERGIZE"
spellId, spellName, spellSchool, amount, powerType

"SPELL_PERIODIC_MISSED"
spellId, spellName, spellSchool, missType

"SPELL_PERIODIC_DAMAGE"
spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing

"SPELL_PERIODIC_HEAL"
spellId, spellName, spellSchool, amount, critical

"SPELL_PERIODIC_DRAIN"
spellId, spellName, spellSchool, amount, powerType, extraAmount

"SPELL_PERIODIC_LEECH"
spellId, spellName, spellSchool, amount, powerType, extraAmount

"SPELL_PERIODIC_ENERGIZE"
spellId, spellName, spellSchool, amount, powerType

"SPELL_DRAIN"
spellId, spellName, spellSchool, amount, powerType, extraAmount

"SPELL_LEECH"
spellId, spellName, spellSchool, amount, powerType, extraAmount

"SPELL_INTERRUPT"
spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool

"SPELL_EXTRA_ATTACKS"
spellId, spellName, spellSchool, amount

"SPELL_INSTAKILL"
spellId, spellName, spellSchool

"SPELL_DURABILITY_DAMAGE"
spellId, spellName, spellSchool

"SPELL_DURABILITY_DAMAGE_ALL"
spellId, spellName, spellSchool

"SPELL_DISPEL_FAILED"
spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool

"SPELL_AURA_DISPELLED"
spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool, auraType

"SPELL_AURA_STOLEN"
spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool, auraType

"SPELL_AURA_APPLIED"
spellId, spellName, spellSchool, auraType
(source arguments are nil)

"SPELL_AURA_REMOVED"
spellId, spellName, spellSchool, auraType
(source arguments are nil)

"SPELL_AURA_APPLIED_DOSE"
spellId, spellName, spellSchool, auraType, amount
(source arguments are nil)

"SPELL_AURA_REMOVED_DOSE"
spellId, spellName, spellSchool, auraType, amount
(source arguments are nil)

"SPELL_CAST_START"
spellId, spellName, spellSchool

"SPELL_CAST_SUCCESS"
spellId, spellName, spellSchool

"SPELL_CAST_FAILED"
spellId, spellName, spellSchool, missType

]]--
---------------------------------------------------------
--	Library
---------------------------------------------------------
local bzone = LibStub("LibBabble-Zone-3.0")
local bboss = LibStub("LibBabble-Boss-3.0")

if not _G.BZ then _G.BZ = bzone:GetLookupTable() end
if not _G.BB then _G.BB = bboss:GetLookupTable() end


---------------------------------------------------------
--	Localization
---------------------------------------------------------
local L = AceLibrary("AceLocale-2.2"):new("GridStatusRaidDebuff")
local LGrid = AceLibrary("AceLocale-2.2"):new("Grid")

L:RegisterTranslations("enUS", function()
	return {		
		["Raid Debuff"] = true,
		["Option for %s"] = true,
		["Enable %s"] = true,
		iconWarnName = "|cffff0000(No Icon)|r",
		iconWarnDesc = "\n\n|cffff0000You can't see this on center icon or other icon indicators. If you want to see this, you enable Raid Debuff of the border indicator or other color indicators.",
	}
end)

L:RegisterTranslations("koKR", function()
	return {
		["Raid Debuff"] = "레이드 디버프",
		["Option for %s"] = "%s의 설정",
		["Enable %s"] = "%s 활성화",
		iconWarnName = "|cffff0000(아이콘 없음)|r",
		iconWarnDesc = "\n\n|cffff0000이 디버프는 중앙아이콘이나 아이콘 표시기로 볼수 없습니다. 디버프를 보기 위해서는 테두리나 다른 색상 표시기의 레이드 디버프를  활성화 해야됩니다.",
	}
end)

L:RegisterTranslations("zhCN", function()
	return {
		["Raid Debuff"] = "团队减益",
		["Option for %s"] = "%s 设置",
		["Enable %s"] = "开启 %s",
		iconWarnName = "|cffff0000(No Icon)|r",
		iconWarnDesc = "\n\n|cffff0000You can't see this on center icon or other icon indicators. If you want to see this, you enable Raid Debuff of the border indicator or other color indicators.",
	}	
end)

L:RegisterTranslations("zhTW", function()
	return {
		["Raid Debuff"] = "團隊減益",
		["Option for %s"] = "%s 選項",
		["Enable %s"] = "啟用%s",
		iconWarnName = "|cffff0000(No Icon)|r",
		iconWarnDesc = "\n\n|cffff0000You can't see this on center icon or other icon indicators. If you want to see this, you enable Raid Debuff of the border indicator or other color indicators.",
	}
end)

L:RegisterTranslations("ruRU", function()
	return {
		["Raid Debuff"] = "Дебаффы рейда",
		["Option for %s"] = "Опции %s",
		["Enable %s"] = "Включить %s",
		iconWarnName = "|cffff0000(No Icon)|r",
		iconWarnDesc = "\n\n|cffff0000You can't see this on center icon or other icon indicators. If you want to see this, you enable Raid Debuff of the border indicator or other color indicators.",
	}
end)


---------------------------------------------------------
--	Core
---------------------------------------------------------
GridStatusRaidDebuff = GridStatus:NewModule("GridStatusRaidDebuff")

local GridStatusRaidDebuff = GridStatusRaidDebuff
GridStatusRaidDebuff.menuName = L["Raid Debuff"]

local GetSpellInfo = GetSpellInfo
local fmt = string.format

local MemberStatuses = {}
local debuff_lists = {}

local AuraCheckListZones = {}
local AuraCheckListAuras = {}

local zone
local db

GridStatusRaidDebuff.defaultDB = {
	debug = false,	
	isFirst = true,
	
	["alert_RaidDebuff"] = {
		text = L["Raid Debuff"],
		desc = L["Raid Debuff"],
		enable = true,
		color = { r = .0, g = .0, b = .0, a=1.0 },
		priority = 98,
		range = false,
	},
	
	["debuff_option"] = {}
}


function GridStatusRaidDebuff:OnInitialize()
	self.super.OnInitialize(self)
	self:RegisterStatuses()
end

function GridStatusRaidDebuff:OnEnable()
	self.debugging = self.db.profile.debug
	
	db = self.db.profile.debuff_option	
	
	if self.db.profile.isFirst then		
		GridFrame.db.profile.statusmap["icon"].alert_RaidDebuff  =  true,
		GridFrame:UpdateAllFrames()
		self.db.profile.isFirst = false
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneCheck")
end


function GridStatusRaidDebuff:ZoneCheck()
	zone = GetRealZoneText()

	self:NukeStatuses()

	if debuff_lists[zone] then
		if not self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "EventHandler")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")

			-- If this zone has debuffs that require aura checking, then register for
			-- the necessary events.
			if (AuraCheckListZones[zone]) then
				if not self:IsEventRegistered("UNIT_AURA") then
					self:RegisterEvent("UNIT_AURA", "ScanUnitAuras")
					self:RegisterEvent("Grid_UnitJoined")
				end
			else
				if self:IsEventRegistered("UNIT_AURA") then
					self:UnregisterEvent("UNIT_AURA")
					self:UnregisterEvent("Grid_UnitJoined")
				end
			end
		end
	else
		if self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")

			if self:IsEventRegistered("UNIT_AURA") then
				self:UnregisterEvent("UNIT_AURA")
				self:UnregisterEvent("Grid_UnitJoined")
			end
		end
	end
end

function GridStatusRaidDebuff:NukeStatuses()
	for guid in pairs(MemberStatuses) do
		MemberStatuses[guid] = nil
		self.core:SendStatusLost(guid, "alert_RaidDebuff")
	end
end

function GridStatusRaidDebuff:NukeUnit(guid)
	if (MemberStatuses and MemberStatuses[guid]) then
		MemberStatuses[guid] = nil
		self.core:SendStatusLost(guid, "alert_RaidDebuff")
	end
end

function GridStatusRaidDebuff:PLAYER_REGEN_ENABLED()
	for guid, unitid in GridRoster:IterateRoster() do
		if not UnitDebuff(unitid, 1) then			
			self:NukeUnit(guid)
		end
	end
end

function GridStatusRaidDebuff:PLAYER_ENTERING_WORLD()	
	self:ZoneCheck()	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")	
end

function GridStatusRaidDebuff:Grid_UnitJoined(guid, unitid)
	self:ScanUnitAuras(unitid)
end

function GridStatusRaidDebuff:RegisterStatuses()
	self:RegisterStatus("alert_RaidDebuff", L["Raid Debuff"])
	self:CreateMainMenu()
end

function GridStatusRaidDebuff:UnregisterStatuses()
	self:UnregisterStatus("alert_RaidDebuff")
end

-- Create a custom tooltip for debuff description
local tip = CreateFrame("GameTooltip", "GridStatusRaidDebuffTooltip", nil, "GameTooltipTemplate")
tip:SetOwner(UIParent, "ANCHOR_NONE")
for i = 1, 10 do
	tip[i] = _G["GridStatusRaidDebuffTooltipTextLeft"..i]
	if not tip[i] then
		tip[i] = tip:CreateFontString()
		tip:AddFontStrings(tip[i], tip:CreateFontString())
	end
end


function GridStatusRaidDebuff:Reset()
	self.super.Reset(self)
	self:UnregisterStatuses()
	self:RegisterStatuses()
end


function GridStatusRaidDebuff:GainedDebuff(guid, stNum, count)
	if debuff_lists[zone] then
		local settings = self.db.profile["alert_RaidDebuff"]
		local dInfo1 = debuff_lists[zone][stNum]	--delegater optino first	
		if dInfo1 then			
			local dID = stNum
			local dInfo2 = dInfo1
			
			if dInfo2.delegater then
				dID = dInfo2.delegater
				dInfo2 = debuff_lists[zone][dInfo2.delegater]
			end

			if not db[zone][dID] then
				if not MemberStatuses[guid] then MemberStatuses[guid] = {} end

				MemberStatuses[guid][stNum] = {
					value = count and fmt("%d",count),
					color = dInfo1.color or dInfo2.color or settings.color,
					icon = dInfo2.icon,
					start = GetTime(),
					duration = dInfo1.duration or dInfo2.duration,
					stackable = dInfo1.stackable or dInfo2.stackable,
				}
				
				if not MemberStatuses[guid][stNum].color.a then
					MemberStatuses[guid][stNum].color.a = settings.color.a
				end
				
				--fix invisible debuff
				if MemberStatuses[guid][stNum].color.a == 0 then 
					setting.color.a = 1
					MemberStatuses[guid][stNum].color.a = 1 
				end
				
				self:UpdateUnit(guid)
			end
		end
	end
end


-- COMBAT_LOG_EVENT_UNFILTERED handler
function GridStatusRaidDebuff:EventHandler(ts, event, srcguid, srcname, srcflg, dstguid, dstname, dstflg, ...)
	if GridRoster:IsGUIDInRaid(dstguid) then
		if
			event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" or event == "SPELL_AURA_REFRESH"
		then
			local spellId, name, _, _, count = select(1, ...)
			self:GainedDebuff(dstguid, spellId, count or 1)			
		elseif
			event == "SPELL_AURA_REMOVED"
		then
			local spellId = select(1, ...)			
			self:LostDebuff(dstguid, spellId)			
		elseif
			event == "UNIT_DIED"
		then
			if not UnitIsFeignDeath(GridRoster:GetUnitidByGUID(dstguid)) then
				self:NukeUnit(dstguid)
			end
		end
	end
end

function GridStatusRaidDebuff:LostDebuff(guid, stNum)
	if MemberStatuses[guid] and MemberStatuses[guid][stNum] then
		MemberStatuses[guid][stNum] = nil
		self:UpdateUnit(guid)
	end
end


function GridStatusRaidDebuff:UpdateUnit(guid)
	if (MemberStatuses[guid] and next(MemberStatuses[guid])) then
		local settings = self.db.profile["alert_RaidDebuff"]
		local icon, start, duration
		local value, stackicon

		local normalcolor
		local stackcolor
		for i, k in pairs(MemberStatuses[guid]) do
			if k.stackable then
				stackicon = k.icon
				value = k.value
				stackcolor = k.color
			end
			if not duration then
				icon = k.icon
				start = k.start
				duration = k.duration
				normalcolor = k.color
			end
		end	
		
		local	color = stackcolor or normalcolor

		self.core:SendStatusGained(
			guid, "alert_RaidDebuff", settings.priority, (settings.range and 40),
			color, nil, nil, nil, icon or stackicon, start, duration, value)
	else
		self.core:SendStatusLost(guid, "alert_RaidDebuff")
	end
end


local debuff_names_seen = {}

function GridStatusRaidDebuff:ScanUnitAuras(unitid)
	local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable

	local guid = UnitGUID(unitid)
	if not GridRoster:IsGUIDInRaid(guid) then
		return
	end

	self:Debug("UNIT_AURA", unitid, guid)

	-- scan for debuffs
	wipe(debuff_names_seen)
	local settings = self.db.profile["alert_RaidDebuff"]
	if (settings.enable) then
		local index = 1
		while true do
			name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitAura(unitid, index, "HARMFUL")

			if not name then
				break
			end

			if (AuraCheckListAuras[name]) then
				debuff_names_seen[name] = true
				self:GainedDebuff(guid, AuraCheckListAuras[name], count or 1)
			end

			index = index + 1
		end
	end

	-- handle lost debuffs
	for name in pairs(AuraCheckListAuras) do
		if not debuff_names_seen[name] then
			self:LostDebuff(guid, AuraCheckListAuras[name])
		else
			debuff_names_seen[name] = nil
		end
	end
end

function GridStatusRaidDebuff:RegisterDebuff(zone, debuffID, order, duration, stackable, color, disable, auraCheck, noicon)
	local db = self.db.profile.debuff_option
	
	if not db[zone] then db[zone] = {}	end	
	if disable then	db[zone][debuffID] = disable	end	
		
	self:CreateZoneMenu(zone)
		
	local args
	if not debuff_lists[zone][debuffID] then
		debuff_lists[zone][debuffID] = {}
		
		local name, _, icon = GetSpellInfo(debuffID)	
		
		local description = L["Enable %s"]:format(name or debuffID)
		tip:SetHyperlink("spell:"..debuffID)
		if tip:NumLines() > 1 then
			description = tip[tip:NumLines()]:GetText()
		end
		
		debuff_lists[zone][debuffID].name = name	
		debuff_lists[zone][debuffID].icon = (not noicon and icon) or nil
		
		local menuName = fmt("%s%s", name, stackable and "(*)" or "")		
		if color then
			menuName = fmt("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, menuName)
		end
		
		if noicon or not icon then
			menuName = fmt("|T%s:0|t%s%s", "Interface\\Icons\\mail_gmicon",menuName, L["iconWarnName"])
			description = fmt("%s%s", description, L["iconWarnDesc"])
		else
			menuName = fmt("|T%s:0|t%s", icon, menuName)
		end
		
		args = self.options.args[zone].args
		args[debuffID] = {
			type = "toggle",
			name = menuName,
			desc = description,
			order = order,
			get = function() return not db[zone][debuffID] end,
			set = function(v) db[zone][debuffID] = not v end,
		}
	end

	local data = debuff_lists[zone][debuffID]	
	
	data.stackable = stackable
	data.duration = duration
	
	if color then
		data.color = color
	end
	
	if auraCheck then	
		AuraCheckListZones[zone] = true
		AuraCheckListAuras[data.name] = debuffID
	end	
end

function GridStatusRaidDebuff:RegisterDebuffDelMod(zone, delID, debuffID, duration, stackable, color)
	debuff_lists[zone][debuffID] = {
	 delegater = delID,
	 stackable = stackable,
	 duration = duration,
	 color = color,
	}	
end

function GridStatusRaidDebuff:RegisterDebuffDelegater(zone, debuffID, ...)
	local n = select("#",...)
	if n > 0 then
		for i = 1,n do
			debuff_lists[zone][select(i,...)] = { delegater = debuffID }
		end
	end
end

function GridStatusRaidDebuff:RegisterMenuHeader(zone, order, header)
	self:CreateZoneMenu(zone)
	
	local args = self.options.args[zone].args
	args[header] = {
			type = "header",
			name = header,			
			order = order,
	}
end

function GridStatusRaidDebuff:CreateMainMenu()
	local args = self.options.args	
	
	for i,k in pairs(args["alert_RaidDebuff"].args) do
		args[i] = k		
	end	
	
	args["alert_RaidDebuff"].hidden = true
	
	args["Border"] = {
			type = "toggle",
			name = LGrid["Border"],			
			desc = L["Enable %s"]:format(LGrid["Border"]),
			order = 98,
			disabled = InCombatLockdown,
			get = function() return GridFrame.db.profile.statusmap["border"].alert_RaidDebuff end,
			set = function(v) 
							GridFrame.db.profile.statusmap["border"].alert_RaidDebuff  =  v 
							GridFrame:UpdateAllFrames()
						end,
	}
	
	args["Icon"] = {
			type = "toggle",
			name = LGrid["Center Icon"],			
			desc = L["Enable %s"]:format(LGrid["Center Icon"]),
			order = 99,
			disabled = InCombatLockdown,
			get = function() return GridFrame.db.profile.statusmap["icon"].alert_RaidDebuff end,
			set = function(v) 
							GridFrame.db.profile.statusmap["icon"].alert_RaidDebuff  =  v 
							GridFrame:UpdateAllFrames()
						end,
	}
	
end

function GridStatusRaidDebuff:CreateZoneMenu(zone)
	local args
	if not debuff_lists[zone] then 
		debuff_lists[zone] = {}
				
		args = self.options.args
		args[zone] = {
			type = "group",
			name = zone,
			desc = L["Option for %s"]:format(zone),		
			order = 91,	
			args = {},
		}
	end
end


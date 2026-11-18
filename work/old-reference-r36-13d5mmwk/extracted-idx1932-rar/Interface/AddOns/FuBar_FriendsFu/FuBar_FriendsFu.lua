-- setting upvalues

local _G				= getfenv(0)

local ipairs			= _G.ipairs
local select			= _G.select

local table_insert		= _G.table.insert
local table_remove		= _G.table.remove
local table_sort		= _G.table.sort

local GetFriendInfo		= _G.GetFriendInfo
local GetNumFriends		= _G.GetNumFriends
local IsAddOnLoaded		= _G.IsAddOnLoaded
local UnitInParty		= _G.UnitInParty
local UnitInRaid		= _G.UnitInRaid

local tablet = AceLibrary("Tablet-2.0")
local T = LibStub("LibTourist-3.0")
local L = AceLibrary("AceLocale-2.2"):new("FuBar_FriendsFu")

FuBar_FriendsFu = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")
local FuBar_FriendsFu = FuBar_FriendsFu
FuBar_FriendsFu.revision = tonumber(string.sub("$Revision: 91 $", 12, -3)) or 1

FuBar_FriendsFu.hasIcon = true
FuBar_FriendsFu.hasNoColor = true
FuBar_FriendsFu.clickableTooltip = true
FuBar_FriendsFu:RegisterDB("FuBar_FriendsFuDB")
FuBar_FriendsFu:RegisterDefaults("profile", {
	text = {
		show_displayed = true,
		show_online = true,
		show_total = true,
	},
	tooltip = {
		sort = "ZONE",
		group_show = true,
		name_color = "CLASS",
		name_status = true,
		class_show = false,
		class_align = "CENTER",
		level_show = true,
		level_align = "CENTER",
		level_color = "RELATIVE",
		zone_show = true,
		zone_align = "CENTER",
		zone_color = "FACTION",
		note_showblizzard = true,
		note_showauldlangsyne = true,
		note_showctplayernotes = true,
		note_align = "CENTER",
	},
	filter = {
		class_druid = true,
		class_hunter = true,
		class_mage = true,
		class_paladin = true,
		class_priest = true,
		class_rogue = true,
		class_shaman = true,
		class_warlock = true,
		class_warrior = true,
		level_0109 = true,
		level_1019 = true,
		level_2029 = true,
		level_3039 = true,
		level_4049 = true,
		level_5059 = true,
		level_6069 = true,
		level_70 = true,
		zone_bg = true,
		zone_inst = true,
		zone_open = true,
	}
})

function FuBar_FriendsFu:OnInitialize()
	self.players = {}
end

function FuBar_FriendsFu:OnEnable()
	self:ScheduleRepeatingEvent(ShowFriends, 15)
	self:RegisterBucketEvent("FRIENDLIST_UPDATE", 1, "Update")

	self:RegisterBucketEvent("RosterLib_RosterChanged", 1, "UpdateTooltip")
	
	FuBar_FriendsFu:UpdateData()
	ShowFriends()
end

-- function FuBar_FriendsFu:OnDisable()
-- end

FuBar_FriendsFu.sorts ={
	NAME =	function(a,b)
				return a[1]<b[1]
			end,
	CLASS =	function(a,b)
				if a[3]<b[3] then
					return true
				elseif a[3]>b[3] then
					return false
				else
					if a[2]<b[2] then
						return true
					elseif a[2]>b[2] then
						return false
					else
						return FuBar_FriendsFu.sorts.NAME(a, b)
					end
				end
			end,
	LEVEL =	function(a,b)
				if a[2]<b[2] then
					return true
				elseif a[2]>b[2] then
					return false
				else
					if a[3]<b[3] then
						return true
					elseif a[3]>b[3] then
						return false
					else
						return FuBar_FriendsFu.sorts.NAME(a, b)
					end
				end
			end,
	ZONE =	function(a,b)
				if a[4]<b[4] then
					return true
				elseif a[4]>b[4] then
					return false
				else
					return FuBar_FriendsFu.sorts.CLASS(a, b)
				end
			end,
}

local tablecache = {}
local function recycleplayertable(t)
	while #t > 0 do
		table_insert(tablecache, table_remove(t))
	end
	return t
end
local function getplayertable(...)
	local t
	if #tablecache > 0 then
		t = table_remove(tablecache)
	else
		t = {}
	end
	for i = 1, select('#', ...) do
		t[i] = select(i, ...)
	end
	return t
end

function FuBar_FriendsFu:OnDataUpdate()
	local players = recycleplayertable(self.players)
	local playersShown = 0
	local playersOnline = 0
	local playersTotal = 0

	local numFriends = GetNumFriends()
	local name, level, class, zone, online, status, note
	for i = 1, numFriends, 1 do
		name, level, class, zone, online, status, note = GetFriendInfo(i)
		if online then
			playersOnline = playersOnline + 1
			if self:checkFilter(class, level, zone) then
				playersShown = playersShown + 1
				table_insert(players, getplayertable(name or UNKNOWN, level or -1, class or UNKNOWN, zone or UNKNOWN, status, note))
			end
		end
	end
	table_sort(players, self.sorts[self.db.profile.tooltip.sort])
	self.players = players
	self.playersShown = playersShown
	self.playersOnline = playersOnline
	self.playersTotal = numFriends
end

function FuBar_FriendsFu:OnTextUpdate()
	if self.playersTotal == 0 and GetNumFriends() ~= 0 then
		self:SetText(L["Updating..."])
		return
	end

	local temptext = ""
	local settings_text = self.db.profile.text
	if settings_text.show_displayed then
		temptext = temptext..self.playersShown
	end
	if settings_text.show_online then
		if temptext ~= "" then
			temptext = temptext.."/"
		end
		temptext = temptext..self.playersOnline
	end
	if settings_text.show_total then
		if temptext ~= "" then
			temptext = temptext.."/"
		end
		temptext = temptext..self.playersTotal
	end
	if temptext ~= "" then
		self:SetText(temptext)
	else
		self:SetText("")
	end
end

local AuldLangSyne_notes
local CT_PlayerNotes_loaded

function FuBar_FriendsFu:OnTooltipUpdate()
	local settings_tooltip = self.db.profile.tooltip
	local cat
	if self.playersTotal == 0 then
		cat = tablet:AddCategory(
			'columns', 1,
			'text', L["You aren't having any known friends."],
			'hideBlankLine', true,
			'showWithoutChildren', true
		)
		return
	end

	if self.playersShown == 0 then
		cat = tablet:AddCategory(
			'columns', 1,
			'text', L["All friends offline or filtered."],
			'hideBlankLine', true,
			'showWithoutChildren', true
		)
		return
	end

	AuldLangSyne_notes = AuldLangSyne_notes or AuldLangSyne and AuldLangSyne:HasModule("Note") and AuldLangSyne:GetModule("Note")
	CT_PlayerNotes_loaded = CT_PlayerNotes_loaded or IsAddOnLoaded("CT_PlayerNotes")
	local show_notes = settings_tooltip.note_showblizzard or (AuldLangSyne_notes and settings_tooltip.note_showauldlangsyne) or (CT_PlayerNotes_loaded and settings_tooltip.note_showctplayernotes)
	
	local cols = {}
	table_insert(cols, L["Name"])
	if settings_tooltip.class_show then
		table_insert(cols, L["Class"])
	end
	if settings_tooltip.level_show then
		table_insert(cols, L["Level"])
	end
	if settings_tooltip.zone_show then
		table_insert(cols, L["Zone"])
	end
	if show_notes then
		table_insert(cols, L["Notes"])
	end

	cat = tablet:AddCategory(
		'columns', #cols
	)
	local header = {}
	for i = 1, #cols do
		if i == 1 then
			header['text'] = cols[i]
			header['justify'] = "CENTER"
		else
			header['text'..i] = cols[i]
			header['justify'..i] = "CENTER"
		end
	end
	cat:AddLine(header)
	local line = {}
	local colcount
	local temptext
	local classcolor
	local levelcolor
	local zonecolorR, zonecolorG, zonecolorB
	local reverse_class = self.reverse_class
	for _, data in ipairs(self.players) do
		classcolor = RAID_CLASS_COLORS[reverse_class[data[3]]]
		levelcolor = GetDifficultyColor(data[2])
		if settings_tooltip.name_status and data[5] ~= "" then
			line['text'] = data[5].." "..data[1]
		else
			line['text'] = data[1]
		end
		if settings_tooltip.name_color == "CLASS" then
			line['textR'] = classcolor.r
			line['textG'] = classcolor.g
			line['textB'] = classcolor.b
		else
			line['textR'] = 1
			line['textG'] = 1
			line['textB'] = 0
		end
		colcount = 1
		if settings_tooltip.class_show then
			colcount = colcount + 1
			line['text'..colcount] = data[3]
			line['justify'..colcount] = settings_tooltip.class_align
			line['text'..colcount..'R'] = classcolor.r
			line['text'..colcount..'G'] = classcolor.g
			line['text'..colcount..'B'] = classcolor.b
		end
		if settings_tooltip.level_show then
			colcount = colcount + 1
			line['text'..colcount] = data[2]
			line['justify'..colcount] = settings_tooltip.level_align
			line['text'..colcount..'R'] = levelcolor.r
			line['text'..colcount..'G'] = levelcolor.g
			line['text'..colcount..'B'] = levelcolor.b
		end
		if settings_tooltip.zone_show then
			colcount = colcount + 1
			line['text'..colcount] = data[4]
			line['justify'..colcount] = settings_tooltip.zone_align
			if settings_tooltip.zone_color == "FACTION" then
				zonecolorR, zonecolorG, zonecolorB = T:GetFactionColor(data[4])
			elseif settings_tooltip.zone_color == "LEVEL" then
				zonecolorR, zonecolorG, zonecolorB = T:GetLevelColor(data[4])
			else
				zonecolorR, zonecolorG, zonecolorB = 1, 1, 0
			end
			line['text'..colcount..'R'] = zonecolorR
			line['text'..colcount..'G'] = zonecolorG
			line['text'..colcount..'B'] = zonecolorB
		end
		if show_notes then
			colcount = colcount + 1
			temptext = ""
			if settings_tooltip.note_showblizzard then
				temptext = temptext ..((data[6] and (" {"..data[6].."} ")) or "")
			end
			if AuldLangSyne_notes and settings_tooltip.note_showauldlangsyne then
				temptext = temptext ..((AuldLangSyne_notes.db.realm.friend[data[1]] and (" {"..AuldLangSyne_notes.db.realm.friend[data[1]].."} ")) or "")
			end
			if CT_PlayerNotes_loaded and settings_tooltip.note_showctplayernotes then
				temptext = temptext ..((CT_GuildNotes[data[1]] and (" {"..CT_PlayerNotes[data[1]].."} ")) or "")
			end
			line['text'..colcount] = temptext
			line['justify'..colcount] = settings_tooltip.note_align
			line['text'..colcount..'R'] = 1
			line['text'..colcount..'G'] = 1
			line['text'..colcount..'B'] = 0
		end
		line['func'] = 'OnNameClick'
		line['arg1'] = self
		line['arg2'] = data[1]
		if settings_tooltip.group_show then
			line['hasCheck'] = true
			line['checked'] = (UnitInParty(data[1]) or UnitInRaid(data[1])) and true
-- 'checkIcon', self.factions[i].isCollapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up",
		end

		cat:AddLine(line)
	end
end

function FuBar_FriendsFu:OnClick()
	FriendsFrame.showFriendsList = true 
	ToggleFriendsFrame(1) 
end

function FuBar_FriendsFu:OnNameClick(name)
	if not name then return end
	if IsAltKeyDown() then
		InviteUnit(name)
	else
		SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
	end
end

function FuBar_FriendsFu:checkFilter(class, level, zone)
	local settings_filter = self.db.profile.filter
	local reverse_class = self.reverse_class
	if not settings_filter.class_druid		and reverse_class[class] == "DRUID"		then return false end
	if not settings_filter.class_hunter		and reverse_class[class] == "HUNTER"	then return false end
	if not settings_filter.class_mage		and reverse_class[class] == "MAGE"		then return false end
	if not settings_filter.class_paladin	and reverse_class[class] == "PALADIN"	then return false end
	if not settings_filter.class_priest		and reverse_class[class] == "PRIEST"	then return false end
	if not settings_filter.class_rogue		and reverse_class[class] == "ROGUE"		then return false end
	if not settings_filter.class_shaman		and reverse_class[class] == "SHAMAN"	then return false end
	if not settings_filter.class_warlock	and reverse_class[class] == "WARLOCK"	then return false end
	if not settings_filter.class_warrior	and reverse_class[class] == "WARRIOR"	then return false end
	
	if not settings_filter.level_0109 and level < 10 then return false end
	if not settings_filter.level_1019 and level >= 10 and level < 20 then return false end
	if not settings_filter.level_2029 and level >= 20 and level < 30 then return false end
	if not settings_filter.level_3039 and level >= 30 and level < 40 then return false end
	if not settings_filter.level_4049 and level >= 40 and level < 50 then return false end
	if not settings_filter.level_5059 and level >= 50 and level < 60 then return false end
	if not settings_filter.level_6069 and level >= 60 and level < 70 then return false end
	if not settings_filter.level_70 and level == 70 then return false end
	
	if not settings_filter.zone_bg and T:IsBattleground(zone) then return false end
	if not settings_filter.zone_inst and T:IsInstance(zone) and not T:IsBattleground(zone) then return false end
	if not settings_filter.zone_open and T:IsZone(zone) then return false end
	
	return true
end

FuBar_FriendsFu.reverse_class = setmetatable({}, {["__index"] = function() return "PRIEST" end }) -- priest color is white
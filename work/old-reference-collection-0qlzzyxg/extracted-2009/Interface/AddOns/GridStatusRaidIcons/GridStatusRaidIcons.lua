-- -------------------------------------------------------------------------- --
-- GridStatusRaidIcons by kunda                                               --
-- -------------------------------------------------------------------------- --
local GridRoster = GridRoster
if not GridRoster then
	DEFAULT_CHAT_FRAME:AddMessage("GridStatusRaidIcons requires GridRoster.")
	DEFAULT_CHAT_FRAME:AddMessage("Please update Grid: http://www.wowace.com/projects/grid/")
	return
end

GridStatusRaidIcons = GridStatus:NewModule("GridStatusRaidIcons")
GridStatusRaidIcons.menuName = RAID_TARGET_ICON

local _G = _G
local UnitGUID = _G.UnitGUID
local UnitExists = _G.UnitExists
local GetRaidTargetIndex = _G.GetRaidTargetIndex

local LOC_PLAYER       = RAID_TARGET_ICON..": "..PLAYER
local LOC_PLAYERTARGET = RAID_TARGET_ICON..": "..PLAYER.." "..TARGET
local icontext = {
	[1] = RAID_TARGET_1, -- Star
	[2] = RAID_TARGET_2, -- Circle
	[3] = RAID_TARGET_3, -- Diamond
	[4] = RAID_TARGET_4, -- Triangle
	[5] = RAID_TARGET_5, -- Moon
	[6] = RAID_TARGET_6, -- Square
	[7] = RAID_TARGET_7, -- Cross
	[8] = RAID_TARGET_8  -- Skull
}
local icontextcolor = {
	[1] = {r = 1.0, g = 0.92, b = 0},     -- Yellow 4-point Star
	[2] = {r = 0.98, g = 0.57, b = 0},    -- Orange Circle
	[3] = {r = 0.83, g = 0.22, b = 0.9},  -- Purple Diamond
	[4] = {r = 0.04, g = 0.95, b = 0},    -- Green Triangle
	[5] = {r = 0.7, g = 0.82, b = 0.875}, -- White Crescent Moon
	[6] = {r = 0, g = 0.71, b = 1},       -- Blue Square
	[7] = {r = 1.0, g = 0.24, b = 0.168}, -- Red 'X' Cross
	[8] = {r = 0.98, g = 0.98, b = 0.98}  -- White Skull
}

GridStatusRaidIcons.defaultDB = {
	debug = false,
	alert_raidicons_player = {
		text =  LOC_PLAYER,
		enable = true,
		color = { r = 1, g = 1, b = 1, a = 0.4 },
		priority = 50,
		range = false,
	},
	alert_raidicons_playertarget = {
		text =  LOC_PLAYERTARGET,
		enable = true,
		color = { r = 1, g = 1, b = 1, a = 0.4 },
		priority = 50,
		range = false,
	}
}

GridStatusRaidIcons.options = false

function GridStatusRaidIcons:OnInitialize()
	self.super.OnInitialize(self)
	self:RegisterStatus("alert_raidicons_player", LOC_PLAYER, nil, true)
	self:RegisterStatus("alert_raidicons_playertarget", LOC_PLAYERTARGET, nil, true)
end

function GridStatusRaidIcons:OnStatusEnable(status)
	if status == "alert_raidicons_player" or status == "alert_raidicons_playertarget" then
		self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateAllUnits")
		self:RegisterEvent("UNIT_TARGET", "UpdateUnit")
		self:RegisterEvent("Grid_UnitJoined")
		self:UpdateAllUnits()
	end
end

function GridStatusRaidIcons:OnStatusDisable(status)
	if not self.db.profile.alert_raidicons_playertarget.enable and not self.db.profile.alert_raidicons_player.enable then
		self:UnregisterEvent("RAID_TARGET_UPDATE")
		self:UnregisterEvent("UNIT_TARGET")
		self:UnregisterEvent("Grid_UnitJoined")
	end
	if status == "alert_raidicons_player" then
		self.core:SendStatusLostAllUnits("alert_raidicons_player")
	end
	if status == "alert_raidicons_playertarget" then
		self.core:SendStatusLostAllUnits("alert_raidicons_playertarget")
	end
end

function GridStatusRaidIcons:Grid_UnitJoined(guid, unitid)
	self:UpdateUnit(unitid)
end

function GridStatusRaidIcons:UpdateUnit(unitid)
	local guid = UnitGUID(unitid)
	if not GridRoster:IsGUIDInRaid(guid) then return end

	local settings = self.db.profile.alert_raidicons_playertarget
	local targetid = unitid .. "target"
	if settings.enable and UnitExists(targetid) then
		local raidicon = GetRaidTargetIndex(targetid)
		if raidicon then
			self.core:SendStatusGained(guid, "alert_raidicons_playertarget",
				settings.priority,
				(settings.range and 40),
				{ r = icontextcolor[raidicon].r, g = icontextcolor[raidicon].g, b = icontextcolor[raidicon].b, a = settings.color.a },
				icontext[raidicon],
				nil,
				nil,
				"Interface\\AddOns\\GridStatusRaidIcons\\icons\\icon".. raidicon ..".tga")
		else
			self.core:SendStatusLost(guid, "alert_raidicons_playertarget")
		end
	else
		self.core:SendStatusLost(guid, "alert_raidicons_playertarget")
	end
end

function GridStatusRaidIcons:UpdateAllUnits()
	local settings = self.db.profile.alert_raidicons_player
	for guid, unitid in GridRoster:IterateRoster() do
		local raidicon = GetRaidTargetIndex(unitid)
		-- unit
		if settings.enable and raidicon then
			self.core:SendStatusGained(guid, "alert_raidicons_player",
				settings.priority,
				(settings.range and 40),
				{ r = icontextcolor[raidicon].r, g = icontextcolor[raidicon].g, b = icontextcolor[raidicon].b, a = settings.color.a },
				icontext[raidicon],
				nil,
				nil,
				"Interface\\AddOns\\GridStatusRaidIcons\\icons\\icon".. raidicon ..".tga")
		else
			self.core:SendStatusLost(guid, "alert_raidicons_player")
		end

		-- unit target
		self:UpdateUnit(unitid)
	end
end
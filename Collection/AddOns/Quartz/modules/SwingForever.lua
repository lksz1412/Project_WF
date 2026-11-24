--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010-2017 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

-- The Swing module for WoW Forever.
--
-- The client announces every swing of the player there, and how long it takes until the next one,
-- which replaces putting the swings together from the combat log and the attack speed of the player.
-- Only hunters get the bar, for the ranged (auto shot) cycle; melee swings are left to the game's
-- own swing timer. The last dfStandStill seconds of a cycle (profile value, the same default as
-- DevilForever Core's Quartz defaults; 0 = none) are drawn as the window to stand still in before
-- the shot. A shot that comes later than the cycle keeps the bar full until the next shot; it
-- hides when the shot is overdue by more than one more cycle (auto shot stopped).
local MODNAME = "Swing"
local Swing = Quartz3:NewModule(MODNAME)
local Player = Quartz3:GetModule("Player")

local media = LibStub("LibSharedMedia-3.0")

-- Enum.PlayerSwingType.Ranged, else the client's number for the ranged hand (0 main, 1 off, 2 ranged).
local swingTypes = type(Enum) == "table" and type(Enum.PlayerSwingType) == "table" and Enum.PlayerSwingType or {}
local RANGED = type(swingTypes.Ranged) == "number" and swingTypes.Ranged or 2

local swingbar, swingbar_width, swingstatusbar, remainingtext, durationtext, standstill
local swingEnd, swingLength
local previewing = false

local db, getOptions

local defaults = {
	profile = {
		barcolor = {1, 1, 1},
		swingalpha = 1,
		swingheight = 4,
		swingposition = "top",
		swinggap = -4,
		dfStandStill = 0.5,

		durationtext = true,
		remainingtext = true,

		x = 300,
		y = 300,
	}
}

local function isHunter()
	local _, class = UnitClass("player")
	return class == "HUNTER"
end

-- The stand-still window: the right-hand part of the bar for the last dfStandStill seconds.
local function placeWindow()
	local window = db and tonumber(db.dfStandStill)
	if not standstill or not swingbar_width or not swingLength or not window or window <= 0 then
		if standstill then standstill:Hide() end
		return
	end
	standstill:SetWidth(math.max(1, swingbar_width * math.min(1, window / swingLength)))
	standstill:Show()
end

local function OnUpdate()
	if previewing then return end
	if not swingEnd then return swingbar:Hide() end
	local left = swingEnd - GetTime()
	if left <= 0 then
		if -left > swingLength then
			swingEnd, swingLength = nil, nil
			return swingbar:Hide()
		end
		swingstatusbar:SetValue(1)
		remainingtext:SetText("0.0")
		return
	end
	swingstatusbar:SetValue(1 - left / swingLength)
	remainingtext:SetFormattedText("%.1f", left)
end

local function OnHide()
	swingbar:SetScript("OnUpdate", nil)
end

local function OnShow()
	swingbar:SetScript("OnUpdate", OnUpdate)
end

function Swing:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Swing"])

end

function Swing:OnEnable()
	if not swingbar then
		swingbar = CreateFrame("Frame", "Quartz3SwingBar", UIParent, "BackdropTemplate")
		swingbar:SetFrameStrata("HIGH")
		swingbar:SetScript("OnShow", OnShow)
		swingbar:SetScript("OnHide", OnHide)
		swingbar:SetMovable(true)
		swingbar:RegisterForDrag("LeftButton")
		swingbar:SetClampedToScreen(true)

		swingstatusbar = Quartz3:CreateStatusBar(nil, swingbar)

		standstill = swingstatusbar:CreateTexture(nil, "OVERLAY")
		standstill:SetTexture("Interface\\Buttons\\WHITE8X8")
		standstill:SetVertexColor(1, 0.25, 0.25, 0.6)
		standstill:Hide()
		durationtext = swingstatusbar:CreateFontString(nil, "OVERLAY")
		remainingtext = swingstatusbar:CreateFontString(nil, "OVERLAY")
		swingbar:Hide()
	end
	if not self.dfPlayerHooked then
		-- width and scale follow the Player cast bar (UI scale changes rescale it at run time)
		hooksecurefunc(Player.Bar, "ApplySettings", function() Swing:ApplySettings() end)
		self.dfPlayerHooked = true
	end
	self:ApplySettings()
	if isHunter() then self:RegisterEvent("PLAYER_SWING") end
end

function Swing:OnDisable()
	self:UnregisterAllEvents()
	swingEnd, swingLength, previewing = nil, nil, false
	swingstatusbar:SetValue(0)
	swingbar:Hide()
end

-- Quartz3:Unlock / Lock: a full sample cycle with its stand-still window while unlocked (hunters).
function Swing:Unlock()
	if not swingbar or not isHunter() then return end
	previewing = true
	local length = swingLength
	swingLength = length or 2
	placeWindow()
	swingLength = length
	swingstatusbar:SetMinMaxValues(0, 1)
	swingstatusbar:SetValue(1)
	swingbar:Show()
end

function Swing:Lock()
	if not previewing then return end
	previewing = false
	if swingEnd then
		placeWindow()
		OnUpdate()
	else
		swingbar:Hide()
	end
end

-- A swing of the player happened, the next one of that type follows after the duration.
-- The bar shows the ranged (auto shot) cycle.
function Swing:PLAYER_SWING(event, duration, swingType)
	if issecretvalue(duration) or issecretvalue(swingType) then return end
	if swingType ~= RANGED then return end

	if type(duration) ~= "number" or duration <= 0 or duration == math.huge or duration ~= duration then
		swingEnd, swingLength = nil, nil
		swingstatusbar:SetValue(0)
		swingbar:Hide()
		return
	end

	swingEnd, swingLength = GetTime() + duration, duration
	swingstatusbar:SetMinMaxValues(0, 1)
	swingstatusbar:SetValue(0)
	placeWindow()

	durationtext:SetFormattedText("%.1f", duration)
	swingbar:Show()
end

function Swing:ApplySettings()
	db = self.db.profile
	if swingbar and self:IsEnabled() then
		swingbar:ClearAllPoints()
		swingbar:SetHeight(db.swingheight)
		swingbar_width = Player.Bar:GetWidth() - 8
		swingbar:SetWidth(swingbar_width)
		swingbar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
		swingbar:SetBackdropColor(0,0,0)
		swingbar:SetAlpha(db.swingalpha)
		swingbar:SetScale(Player.db.profile.scale)

		if db.swingposition == "bottom" then
			swingbar:SetPoint("TOP", Player.Bar, "BOTTOM", 0, -1 * db.swinggap)
		elseif db.swingposition == "top" then
			swingbar:SetPoint("BOTTOM", Player.Bar, "TOP", 0, db.swinggap)
		else -- L["Free"]
			swingbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
		end

		swingstatusbar:SetAllPoints(swingbar)
		standstill:ClearAllPoints()
		standstill:SetPoint("TOPRIGHT", swingbar, "TOPRIGHT")
		standstill:SetPoint("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT")
		placeWindow()
		swingstatusbar:SetStatusBarTexture(media:Fetch("statusbar", Player.db.profile.texture))
		swingstatusbar:SetStatusBarColor(unpack(db.barcolor))
		if swingEnd and GetTime() < swingEnd then
			-- keep a running swing going
			OnUpdate()
		else
			swingstatusbar:SetMinMaxValues(0, 1)
		end

		if db.durationtext then
			durationtext:Show()
			durationtext:ClearAllPoints()
			durationtext:SetPoint("BOTTOMLEFT", swingbar, "BOTTOMLEFT")
			durationtext:SetJustifyH("LEFT")
		else
			durationtext:Hide()
		end
		durationtext:SetFont(media:Fetch("font", Player.db.profile.font), 9)
		durationtext:SetShadowColor( 0, 0, 0, 1)
		durationtext:SetShadowOffset( 0.8, -0.8 )
		durationtext:SetTextColor(1,1,1)
		durationtext:SetNonSpaceWrap(false)
		durationtext:SetWidth(swingbar_width)

		if db.remainingtext then
			remainingtext:Show()
			remainingtext:ClearAllPoints()
			remainingtext:SetPoint("BOTTOMRIGHT", swingbar, "BOTTOMRIGHT")
			remainingtext:SetJustifyH("RIGHT")
		else
			remainingtext:Hide()
		end
		remainingtext:SetFont(media:Fetch("font", Player.db.profile.font), 9)
		remainingtext:SetShadowColor( 0, 0, 0, 1)
		remainingtext:SetShadowOffset( 0.8, -0.8 )
		remainingtext:SetTextColor(1,1,1)
		remainingtext:SetNonSpaceWrap(false)
		remainingtext:SetWidth(swingbar_width)
	end
end

do
	local locked = true
	local function nothing()
	end
	local function dragstart()
		swingbar:StartMoving()
	end
	local function dragstop()
		db.x = swingbar:GetLeft()
		db.y = swingbar:GetBottom()
		swingbar:StopMovingOrSizing()
	end

	local function setOpt(info, value)
		db[info[#info]] = value
		Swing:ApplySettings()
	end

	local function getOpt(info)
		return db[info[#info]]
	end

	local function getColor(info)
		return unpack(getOpt(info))
	end

	local function setColor(info, r, g, b, a)
		setOpt(info, {r, g, b, a})
	end

	local options
	function getOptions()
		options = options or {
		type = "group",
		name = L["Swing"],
		desc = L["Swing"],
		get = getOpt,
		set = setOpt,
		order = 600,
		args = {
			toggle = {
				type = "toggle",
				name = L["Enable"],
				desc = L["Enable"],
				get = function()
					return Quartz3:GetModuleEnabled(MODNAME)
				end,
				set = function(info, v)
					Quartz3:SetModuleEnabled(MODNAME, v)
				end,
				order = 100,
			},
			barcolor = {
				type = "color",
				name = L["Bar Color"],
				desc = L["Set the color of the swing timer bar"],
				get = getColor,
				set = setColor,
				order = 103,
			},
			swingheight = {
				type = "range",
				name = L["Height"],
				desc = L["Set the height of the swing timer bar"],
				min = 1, max = 20, step = 1,
				order = 104,
			},
			dfStandStill = {
				type = "range",
				name = "멈춤 구간(초)",
				desc = "사격 직전, 움직이지 말아야 하는 마지막 구간(0 = 표시 안 함)",
				min = 0, max = 2, step = 0.05,
				get = function() return tonumber(db.dfStandStill) or 0 end,
				order = 104.5,
			},
			swingalpha = {
				type = "range",
				name = L["Alpha"],
				desc = L["Set the alpha of the swing timer bar"],
				min = 0.05, max = 1, bigStep = 0.05,
				isPercent = true,
				order = 105,
			},
			swingposition = {
				type = "select",
				name = L["Bar Position"],
				desc = L["Set the position of the swing timer bar"],
				values = {["top"] = L["Top"], ["bottom"] = L["Bottom"], ["free"] = L["Free"]},
				order = 106,
			},
			lock = {
				type = "toggle",
				name = L["Lock"],
				desc = L["Toggle Cast Bar lock"],
				get = function()
					return locked
				end,
				set = function(info, v)
					if v then
						swingbar.Hide = nil
						swingbar:EnableMouse(false)
						swingbar:SetScript("OnDragStart", nil)
						swingbar:SetScript("OnDragStop", nil)
						if not swingEnd or GetTime() >= swingEnd then
							swingbar:Hide()
						end
					else
						swingbar:Show()
						swingbar:EnableMouse(true)
						swingbar:SetScript("OnDragStart", dragstart)
						swingbar:SetScript("OnDragStop", dragstop)
						swingbar:SetAlpha(1)
						swingbar.Hide = nothing
					end
					locked = v
				end,
				hidden = function()
					return db.swingposition ~= "free"
				end,
				order = 107,
			},
			x = {
				type = "range",
				name = L["X"],
				desc = L["Set an exact X value for this bar's position."],
				min = -2560, max = 2560, bigStep = 1,
				order = 108,
				hidden = function()
					return db.swingposition ~= "free"
				end,
			},
			y = {
				type = "range",
				name = L["Y"],
				desc = L["Set an exact Y value for this bar's position."],
				min = -2560,
				max = 2560,
				order = 108,
				hidden = function()
					return db.swingposition ~= "free"
				end,
			},
			swinggap = {
				type = "range",
				name = L["Gap"],
				desc = L["Tweak the distance of the swing timer bar from the cast bar"],
				min = -35, max = 35, step = 1,
				order = 108,
			},
			durationtext = {
				type = "toggle",
				name = L["Duration Text"],
				desc = L["Toggle display of text showing your total swing time"],
				order = 109,
			},
			remainingtext = {
				type = "toggle",
				name = L["Remaining Text"],
				desc = L["Toggle display of text showing the time remaining until you can swing again"],
				order = 110,
			},
		},
	}
	return options
	end
end

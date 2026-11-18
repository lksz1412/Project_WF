------------------------------------------------------------------------
--	Clock, Memory, Latency
--	Concept and original addon by rdji
--	Configurable adaptation by Phanx
------------------------------------------------------------------------

CML = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0")

local cml = CML
local db, frame, clock, stats
local c, m, l, f
local a, x, y, p1, p2, h, v, t
local cc, cs, cx

local collectgarbage = collectgarbage
local date = date
local string_format = string.format
local select = select
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats

-- This is annoying and shouldn't be necessary... why isn't it loading normally?!
if GetAddOnInfo("LibSharedMedia-2.0") then
	EnableAddOn("LibSharedMedia-2.0")
	LoadAddOn("LibSharedMedia-2.0")
end

local SharedMedia = LibStub and LibStub:GetLibrary("LibSharedMedia-2.0", true)

local L

if CML_LOCALS then
	L = setmetatable(CML_LOCALS, { __index = function(self, key) rawset(self, key, key) return key end })
	CML_LOCALS = nil
else
	L = setmetatable({}, { __index = function(self, key) rawset(self, key, key) return key end })
end
CML.L = L

------------------------------------------------------------------------
--	Update data
------------------------------------------------------------------------

function cml:UpdateStats()
	c = date("%H:%M")
	m = string_format("%.0f", collectgarbage("count") / 1024)
	l = select(3, GetNetStats())
end

------------------------------------------------------------------------
--	Update text
------------------------------------------------------------------------

function cml:UpdateTextSlow()			-- display without framerate, called every 60 seconds
	self:UpdateStats()

	clock:SetText("|cff"..cc..c.."|r")
	stats:SetText("|cff"..cs..m.."mb|cff"..cx.."+|r|cff"..cs..l.."ms|r")
end

function cml:UpdateTextFast()			-- display with framerate, called every 1 second
	clock:SetText("|cff"..cc..c.."|r")
	stats:SetText("|cff"..cs..string_format("%.0f", GetFramerate()).."fps|r|cff"..cx.."+|r|cff"..cs..m.."mb|r|cff"..cx.."+|r|cff"..cs..l.."ms|r")
end

------------------------------------------------------------------------
--	Schedule updates
------------------------------------------------------------------------

function cml:UpdateScheduledEvents()
	self:CancelAllScheduledEvents()
	if db.fps then
		self:ScheduleRepeatingEvent(self.UpdateStats, 60, self)
		self:ScheduleRepeatingEvent(self.UpdateTextFast, 1, self)
		self:UpdateStats()
		self:UpdateTextFast()
	else
		self:ScheduleRepeatingEvent(self.UpdateTextSlow, 60, self)
		self:UpdateTextSlow()
	end
end

------------------------------------------------------------------------
--	Update cached colors
------------------------------------------------------------------------

function cml:UpdateColors(cacheOnly)
	cc = db.colorClock
	cs = db.colorStats
	cx = db.colorOther

	if not cacheOnly then
		if db.fps then
			self:UpdateTextFast()
		else
			self:UpdateTextSlow()
		end
	end
end

------------------------------------------------------------------------
--	Set alignment and position
------------------------------------------------------------------------

function cml:UpdatePosition()
	a = db.pos
	x = a:find("RIGHT") and -db.posX or db.posX
	y = a:find("TOP") and -db.posY or db.posY
	h = db.align or "CENTER"
	v = db.grow or "DOWN"

	frame:ClearAllPoints()
	frame:SetPoint(a, UIParent, a, x, y)

	if h == "LEFT" then
		p1 = v == "UP" and "BOTTOMLEFT" or "TOPLEFT"
		p2 = v == "UP" and "TOPLEFT" or "BOTTOMLEFT"
	elseif h == "RIGHT" then
		p1 = v == "UP" and "BOTTOMRIGHT" or "TOPRIGHT"
		p2 = v == "UP" and "TOPRIGHT" or "BOTTOMRIGHT"
	else
		p1 = v == "UP" and "BOTTOM" or "TOP"
		p2 = v == "UP" and "TOP" or "BOTTOM"
	end

	clock:ClearAllPoints()
	clock:SetPoint(p1, frame, p1, 0, 0)
	clock:SetJustifyH(h)

	stats:ClearAllPoints()
	stats:SetPoint(p1, clock, p2, 0, 0)
	stats:SetJustifyH(h)
end

------------------------------------------------------------------------
--	Set fonts
------------------------------------------------------------------------

function cml:UpdateFonts()
	t = SharedMedia and SharedMedia:Fetch("font", db.fontFace) or "Fonts\\K_Damage.TTF"

	clock:SetFont(t, db.fontSizeClock, db.fontOutline)
	stats:SetFont(t, db.fontSizeStats, db.fontOutline)

	if db.fontShadow then
		clock:SetShadowOffset(1, -1)
		stats:SetShadowOffset(1, -1)
	else
		clock:SetShadowOffset(0, 0)
		stats:SetShadowOffset(0, 0)
	end

	clock:SetText("00:00")
	stats:SetText(db.fps and "00fps+00mb+000ms" or "00mb+000ms")
	frame:SetWidth(stats:GetWidth() > clock:GetWidth() and stats:GetWidth() or clock:GetWidth())
	frame:SetHeight(clock:GetHeight() + stats:GetHeight())

	self:UpdateStats()
	if db.fps then
		self:UpdateTextFast()
	else
		self:UpdateTextSlow()
	end
end

------------------------------------------------------------------------
--	Initialize
------------------------------------------------------------------------

function cml:OnEnable()
	if not CML_Frame then
		frame = CreateFrame("Frame", "CML_Frame", UIParent)
		frame:SetFrameStrata("BACKGROUND")
		frame:SetFrameLevel(0)
	
		clock = frame:CreateFontString("CML_Clock", "OVERLAY")
	
		stats = frame:CreateFontString("CML_Stats", "OVERLAY")

		self:UpdateColors(true)
		self:UpdateFonts()
		self:UpdatePosition()
	
		frame:Show()
	end
	self:UpdateScheduledEvents()
end

function cml:OnDisable()
	CML_Clock:SetText()
	CML_Stats:SetText()
	CML_Frame:Hide()
end

function cml:OnInitialize()
	self:RegisterDB("cmldb")
	self:RegisterDefaults("profile", {
		fps = false,
		align = "CENTER",
		grow = "DOWN",
		colorClock = "ffffff",
		colorStats = "ffffff",
		colorOther = "ffcc00",
		fontFace = "Friz Quadrata TT",
		fontSizeClock = 32,
		fontSizeStats = 16,
		pos = "BOTTOMRIGHT",
		posX = 0,
		posY = 0,
	})
	db = self.db.profile

	self:LoadOptions()
end
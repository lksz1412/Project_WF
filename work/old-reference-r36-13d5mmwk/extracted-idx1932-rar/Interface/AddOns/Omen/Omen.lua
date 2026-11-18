-----------------------------------------------------------------------------
-- Force used libraries to load. This is necessary because load on demand
-- addons (in our case, disembedded libs) will no longer load even when
-- listed in OptionalDeps and can only be loaded via LoadAddOn(). This must
-- be done before a LibStub("AceAddon-3.0"):NewAddon() call due to
-- ADDON_LOADED firing, as AceAddon-3.0 will call :OnInit() on any addon's
-- ADDON_LOADED event due to needing to support submodules which may not be
-- its their own addons.
LoadAddOn("Ace3")
LoadAddOn("LibSharedMedia-3.0")
LoadAddOn("AceGUI-3.0-SharedMediaWidgets")
LoadAddOn("LibSink-2.0")
LoadAddOn("LibRock-1.0")
LoadAddOn("FuBarPlugin-3.0")


-----------------------------------------------------------------------------
-- Addon declaration
local Omen = LibStub("AceAddon-3.0"):NewAddon("Omen", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "LibSink-2.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Omen", false)
local LSM = LibStub("LibSharedMedia-3.0")
_G["Omen"] = Omen


-----------------------------------------------------------------------------
-- Keybinding globals
BINDING_HEADER_OMEN = "Omen"
BINDING_NAME_OMENTOGGLE = L["Toggle Omen"]
BINDING_NAME_OMENTOGGLEFOCUS = L["Toggle Focus"]


-----------------------------------------------------------------------------
-- Register some media
LSM:Register("sound", "Rubber Ducky", [[Sound\Doodad\Goblin_Lottery_Open01.wav]])
LSM:Register("sound", "Cartoon FX", [[Sound\Doodad\Goblin_Lottery_Open03.wav]])
LSM:Register("sound", "Explosion", [[Sound\Doodad\Hellfire_Raid_FX_Explosion05.wav]])
LSM:Register("sound", "Shing!", [[Sound\Doodad\PortcullisActive_Closed.wav]])
LSM:Register("sound", "Wham!", [[Sound\Doodad\PVP_Lordaeron_Door_Open.wav]])
LSM:Register("sound", "Simon Chime", [[Sound\Doodad\SimonGame_LargeBlueTree.wav]])
LSM:Register("sound", "War Drums", [[Sound\Event Sounds\Event_wardrum_ogre.wav]])
LSM:Register("sound", "Cheer", [[Sound\Event Sounds\OgreEventCheerUnique.wav]])
LSM:Register("sound", "Humm", [[Sound\Spells\SimonGame_Visual_GameStart.wav]])
LSM:Register("sound", "Short Circuit", [[Sound\Spells\SimonGame_Visual_BadPress.wav]])
LSM:Register("sound", "Fel Portal", [[Sound\Spells\Sunwell_Fel_PortalStand.wav]])
LSM:Register("sound", "Fel Nova", [[Sound\Spells\SeepingGaseous_Fel_Nova.wav]])
LSM:Register("sound", "You Will Die!", [[Sound\Creature\CThun\CThunYouWillDIe.wav]])


-----------------------------------------------------------------------------
-- Localize some global functions
local floor, format = floor, format
local sort = sort
local tinsert, tremove = tinsert, tremove
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists, UnitGUID, UnitName, UnitClass = UnitExists, UnitGUID, UnitName, UnitClass
local UnitIsPlayer, UnitPlayerControlled, UnitCanAttack = UnitIsPlayer, UnitPlayerControlled, UnitCanAttack
local GetNumRaidMembers, GetNumPartyMembers = GetNumRaidMembers, GetNumPartyMembers


-----------------------------------------------------------------------------
-- Local variables used
local db
local defaults = {
	profile = {
		Alpha        = 1,
		Scale        = 1,
		GrowUp       = false,
		Autocollapse = false,
		NumBars      = 10,
		CollapseHide = false,
		Locked       = false,
		PositionW    = 200,
		PositionH    = 82,
		VGrip1       = 85,
		VGrip2       = 115,
		UseFocus     = false,
		Background = {
			Texture = "Blizzard Parchment",
			BorderTexture = "Blizzard Dialog",
			Color = {r = 1, g = 1, b = 1, a = 1,},
			BorderColor = {r = 0.8, g = 0.6, b = 0, a = 1,},
			Tile = false,
			TileSize = 32,
			EdgeSize = 8,
			BarInset = 3,
		},
		TitleBar = {
			Height = 16,
			Font = "Friz Quadrata TT",
			FontOutline = "",
			FontColor = {r = 1, g = 1, b = 1, a = 1,},
			FontSize = 10,
		},
		Bar = {
			Texture = "Blizzard",
			Height = 12,
			Spacing = 0,
			AnimateBars  = true,
			ShortNumbers = true,
			Font = "Friz Quadrata TT",
			FontOutline = "",
			FontColor = {r = 1, g = 1, b = 1, a = 1,},
			FontSize = 10,
			Classes = {
				DEATHKNIGHT = true,
				DRUID = true,
				HUNTER = true,
				MAGE = true,
				PALADIN = true,
				PET = true,
				PRIEST = true,
				ROGUE = true,
				SHAMAN = true,
				WARLOCK = true,
				WARRIOR = true,
				["*NOTINPARTY*"] = true,
			},
			ShowTPS = true,
			TPSWindow = 10,
			ShowHeadings = true,
			HeadingBGColor = {r = 0, g = 0, b = 0, a = 0,},
			UseMyBarColor = false,
			MyBarColor = {r = 1, g = 0, b = 0, a = 1,},
		},
		ShowWith = {
			Pet = true,
			Alone = false,
			Party = true,
			Raid = true,
			Resting = false,
			PVP = false,
			Dungeon = true,
			ShowOnlyInCombat = false,
		},
		FuBar = {
			HideMinimapButton = true,
			AttachMinimap = false,
		},
		Warnings = {
			Sound = true,
			Flash = true,
			Shake = false,
			Message = false,
			SinkOptions = {},
			Threshold = 90,
			SoundFile = "Fel Nova",
			DisableWhileTanking = true,
		},
	},
}
local guidNameLookup = {}   -- Format: guidNameLookup[guid] = "Unit Name"
local guidClassLookup = {}  -- Format: guidClassLookup[guid] = "CLASS"
local timers = {}           -- Format: timers.timerName = timer returned from AceTimer-3.0
local bars = {}             -- Format: bars[i] = frame containing the i-th bar from the top of Omen
local inRaid, inParty       -- boolean variables indicating if the player is in a raid and/or party
local testMode = false      -- boolean: Are we in test mode?

Omen.GuidNameLookup = guidNameLookup
Omen.GuidClassLookup = guidClassLookup
Omen.Timers = timers
Omen.Bars = bars
setmetatable(guidNameLookup, {__index = function(self, guid) return L["<Unknown>"] end})

local default_color = {     -- Default bar color for units not in the player's raid/party
	r = 1,
	g = 0,
	b = 0,
	a = 1
}
local pet_color = {         -- Default pet color for all pets in the player's raid/party
	r = 0.83,               -- This is a light green-ish color, or sort of a washed out
	g = 0.98,               -- version of the Hunter color
	b = 0.74,
	a = 0.6
}

-- For speedups. Rather than concantenating every time we need a unitID, we just look
-- it up instead. That is rID[i] is much faster than format("raid%d", i) or "raid"..i
local pID = {}
local ptID = {}
local ppID = {}
local pptID = {}
local rID = {}
local rtID = {}
local rpID = {}
local rptID = {}
for i = 1, 4 do
	pID[i] = format("party%d", i)
	ptID[i] = format("party%dtarget", i)
	ppID[i] = format("partypet%d", i)
	pptID[i] = format("partypet%dtarget", i)
end
for i = 1, 40 do
	rID[i] = format("raid%d", i)
	rtID[i] = format("raid%dtarget", i)
	rpID[i] = format("raidpet%d", i)
	rptID[i] = format("raidpet%dtarget", i)
end


-----------------------------------------------------------------------------
-- Table Pool for recycling tables
local tablePool = {}
setmetatable(tablePool, {__mode = "kv"}) -- Weak table

-- Get a new table
local function newTable()
	local t = next(tablePool) or {}
	tablePool[t] = nil
	return t
end

-- Delete table and return to pool -- Recursive!! -- Use with care!!
local function delTable(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			if type(v) == "table" then
				delTable(v) -- child tables get put into the pool
			end
			t[k] = nil
		end
		t[true] = true -- resize table to 1 item
		t[true] = nil
		setmetatable(t, nil)
		tablePool[t] = true
	end
	return nil -- return nil to assign input reference
end

-- Empties a table of everything -- Non-recursive
local function clearTable(t)
	if type(t) == "table" then
		for k, v in pairs(t) do
			t[k] = nil
		end
		t[true] = true
		t[true] = nil
		setmetatable(t, nil)
	end
end


-----------------------------------------------------------------------------
-- Omen initialization and frame functions

local function startmoving(self)
	if not db.Locked then
		Omen.Anchor.IsMovingOrSizing = 1
		Omen.Anchor:StartMoving()
	end
end
local function stopmoving(self)
	if Omen.Anchor.IsMovingOrSizing then
		Omen.Anchor:StopMovingOrSizing()
		Omen:SetAnchors()
		Omen:UpdateBars()
		Omen.Anchor.IsMovingOrSizing = nil
	end
end
local function sizing(self)
	local w = Omen.Anchor:GetWidth()
	db.VGrip1 = w * Omen.Anchor.VGrip1Ratio
	db.VGrip2 = w * Omen.Anchor.VGrip2Ratio
	if db.VGrip1 < 10 then db.VGrip1 = 10 end
	if db.VGrip1 > w - 10 then db.VGrip1 = w - 10 end
	if db.Bar.ShowTPS then
		if db.VGrip2 < db.VGrip1 + 10 then db.VGrip2 = db.VGrip1 + 10 end
		if db.VGrip1 > w - 20 then
			db.VGrip1 = w - 20
			db.VGrip2 = w - 10
		end
		Omen.VGrip2:ClearAllPoints()
		Omen.VGrip2:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip2, 0)
		Omen.VGrip2:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip2, 0)
	end
	Omen.VGrip1:ClearAllPoints()
	Omen.VGrip1:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip1, 0)
	Omen.VGrip1:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip1, 0)
	Omen:ResizeBars()
	Omen:ReAnchorLabels()
	Omen:UpdateBars()
end
local function movegrip1(self)
	local x = GetCursorPosition() / UIParent:GetEffectiveScale() / Omen.Anchor:GetScale()
	local x1 = Omen.Anchor:GetLeft() + 10
	local x2 = db.Bar.ShowTPS and Omen.Anchor:GetLeft() + db.VGrip2 - 10 or Omen.Anchor:GetRight() - 10
	if x > x1 and x < x2 then
		db.VGrip1 = x - x1 + 10
		Omen.VGrip1:ClearAllPoints()
		Omen.VGrip1:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip1, 0)
		Omen.VGrip1:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip1, 0)
	end
	Omen:ReAnchorLabels()
end
local function movegrip2(self)
	local x = GetCursorPosition() / UIParent:GetEffectiveScale() / Omen.Anchor:GetScale()
	local x1 = Omen.Anchor:GetLeft() + db.VGrip1 + 10
	local x2 = Omen.Anchor:GetRight() - 10
	if x > x1 and x < x2 then
		db.VGrip2 = x - x1 + db.VGrip1 + 10
		Omen.VGrip2:ClearAllPoints()
		Omen.VGrip2:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", db.VGrip2, 0)
		Omen.VGrip2:SetPoint("BOTTOMLEFT", Omen.BarList, "BOTTOMLEFT", db.VGrip2, 0)
	end
	Omen:ReAnchorLabels()
end

function Omen:CreateFrames()
	-- Create anchor
	self.Anchor = CreateFrame("Frame", "OmenAnchor", UIParent)
	self.Anchor:SetResizable(true)
	self.Anchor:SetMinResize(90, db.Background.EdgeSize * 2)
	self.Anchor:SetMovable(true)
	self.Anchor:SetPoint("CENTER", UIParent, "CENTER")
	self.Anchor:SetWidth(225)
	self.Anchor:SetHeight(150)
	self.Anchor:SetClampedToScreen(true)
	self.Anchor:SetScript("OnHide", stopmoving)

	-- Create Title
	self.Title = CreateFrame("Button", "OmenTitle", self.Anchor)
	self.Title:SetPoint("TOPLEFT", self.Anchor, "TOPLEFT")
	self.Title:SetPoint("TOPRIGHT", self.Anchor, "TOPRIGHT")
	self.Title:SetHeight(16)
	self.Title:SetMinResize(90, db.Background.EdgeSize * 2)
	self.Title:EnableMouse(true)
	self.Title:SetScript("OnMouseDown", startmoving)
	self.Title:SetScript("OnMouseUp", stopmoving)
	self.Title:SetScript("OnClick", function(self, button, down)
		if button == "RightButton" then
			ToggleDropDownMenu(1, nil, Omen_TitleDropDownMenu, self:GetName(), 0, 0)
		end
	end)
	self.Title:RegisterForClicks("RightButtonUp")

	-- Create Title text
	self.TitleText = self.Title:CreateFontString(nil, nil, "GameFontNormal")
	self.TitleText:SetPoint("LEFT", self.Title, "LEFT", 8, 1)
	self.TitleText:SetJustifyH("LEFT")
	self.TitleText:SetTextColor(1, 1, 1, 1)
	self.defaultTitle = "Omen|cffffcc003|r"
	self.TitleText:SetText(self.defaultTitle)

	-- Create Bar List
	self.BarList = CreateFrame("Frame", "OmenBarList", self.Anchor)
	self.BarList:SetResizable(true)
	self.BarList:EnableMouse(true)
	self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT")
	self.BarList:SetPoint("TOPRIGHT", self.Title, "BOTTOMRIGHT")
	self.BarList:SetPoint("BOTTOMLEFT", self.Anchor, "BOTTOMLEFT")
	self.BarList:SetPoint("BOTTOMRIGHT", self.Anchor, "BOTTOMRIGHT")
	self.BarList:SetScript("OnMouseDown", startmoving)
	self.BarList:SetScript("OnMouseUp", stopmoving)

	-- Create resizing corner grip
	self.Grip = CreateFrame("Button", "OmenResizeGrip", self.BarList)
	self.Grip:SetNormalTexture("Interface\\AddOns\\Omen\\ResizeGrip")
	self.Grip:SetHighlightTexture("Interface\\AddOns\\Omen\\ResizeGrip")
	self.Grip:SetWidth(16)
	self.Grip:SetHeight(16)
	self.Grip:SetPoint("BOTTOMRIGHT", self.BarList, "BOTTOMRIGHT", 0, 1)
	self.Grip:SetScript("OnMouseDown", function(self, button)
		if not db.Locked then
			Omen.Anchor.IsMovingOrSizing = 2
			Omen.Anchor.VGrip1Ratio = db.VGrip1 / Omen.Anchor:GetWidth()
			Omen.Anchor.VGrip2Ratio = db.VGrip2 / Omen.Anchor:GetWidth()
			Omen.Anchor:SetScript("OnSizeChanged", sizing)
			Omen.Anchor:StartSizing()
		end
	end)
	self.Grip:SetScript("OnMouseUp", function(self)
		if Omen.Anchor.IsMovingOrSizing == 2 then
			Omen.Anchor:SetScript("OnSizeChanged", nil)
			Omen.Anchor:StopMovingOrSizing()
			sizing()
			Omen:SetAnchors()
			Omen.Anchor.IsMovingOrSizing = nil
			Omen.Anchor.VGrip1Ratio = nil
		end
	end)
	self.Grip:SetScript("OnHide", self.Grip:GetScript("OnMouseUp"))

	-- Create label resizing vertical grip 1
	self.VGrip1 = CreateFrame("Button", "OmenVResizeGrip1", self.BarList)
	self.VGrip1:SetWidth(1)
	self.VGrip1:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", db.VGrip1, 0)
	self.VGrip1:SetPoint("BOTTOMLEFT", self.BarList, "BOTTOMLEFT", db.VGrip1, 0)
	self.VGrip1:SetNormalTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	self.VGrip1:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	self.VGrip1:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
	self.VGrip1:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.5)
	self.VGrip1:SetScript("OnMouseDown", function(self)
		if not db.Locked then self:SetScript("OnUpdate", movegrip1) end
	end)
	self.VGrip1:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
	self.VGrip1:SetScript("OnHide", self.VGrip1:GetScript("OnMouseUp"))
	self.VGrip1:SetFrameLevel(self.BarList:GetFrameLevel() + 2)

	-- Create label resizing vertical grip 2
	self.VGrip2 = CreateFrame("Button", "OmenVResizeGrip2", self.BarList)
	self.VGrip2:SetWidth(1)
	self.VGrip2:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", db.VGrip2, 0)
	self.VGrip2:SetPoint("BOTTOMLEFT", self.BarList, "BOTTOMLEFT", db.VGrip2, 0)
	self.VGrip2:SetNormalTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	self.VGrip2:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	self.VGrip2:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
	self.VGrip2:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.5)
	self.VGrip2:SetScript("OnMouseDown", function(self)
		if not db.Locked then self:SetScript("OnUpdate", movegrip2) end
	end)
	self.VGrip2:SetScript("OnMouseUp", self.VGrip1:GetScript("OnMouseUp"))
	self.VGrip2:SetScript("OnHide", self.VGrip1:GetScript("OnMouseUp"))
	self.VGrip2:SetFrameLevel(self.BarList:GetFrameLevel() + 2)

	--[[self.FocusButton = CreateFrame("Button", "OmenFocusButton", self.Title, "OptionsButtonTemplate")
	self.FocusButton:SetWidth(16)
	self.FocusButton:SetHeight(16)
	self.FocusButton:SetPoint("TOPRIGHT")
	self.FocusButton:SetText("F")
	self.FocusButton:SetScript("OnClick", function(self, button, down)
		db.UseFocus = not db.UseFocus
		if db.UseFocus then
			self:GetFontString():SetTextColor(1, 0.82, 0, 1)
		else
			self:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1)
		end
		Omen:UpdateBars()
	end)
	if db.UseFocus then
		self.FocusButton:GetFontString():SetTextColor(1, 0.82, 0, 1)
	else
		self.FocusButton:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1)
	end]]
end

function Omen:OnInitialize()
	-- Create savedvariables
	self.db = LibStub("AceDB-3.0"):New("Omen3DB", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	db = self.db.profile
	self:SetSinkStorage(db.Warnings.SinkOptions)

	self:CreateFrames()
	self:SetupOptions()

	self:RegisterEvent("PLAYER_LOGIN")
end

function Omen:PLAYER_LOGIN()
	-- We set up anchors here because we only want to do it once on
	-- PLAYER_LOGIN, hence we don't do it in OnEnable() which triggers on
	-- the same event as well as on every subsequent Enable()/Disable() calls.
	-- It cannot be earlier than PLAYER_LOGIN because layout-cache.txt
	-- is loaded just before this event fires.
	self:SetAnchors(true)
	self:UpdateBackdrop()
	self:UpdateTitleBar()
	self:UpdateGrips()
	self:UnregisterEvent("PLAYER_LOGIN")

	-- Optional launcher support for LDB-1.1 if present, this code is placed here so
	-- that it runs after all other addons have loaded since we don't embed LDB-1.1
	if LibStub("LibDataBroker-1.1", true) and not IsAddOnLoaded("Broker2FuBar") then
		local LDB = LibStub("LibDataBroker-1.1", true)
		local launcher = LDB:NewDataObject("Omen", {
		    type = "launcher",
		    icon = "Interface\\AddOns\\Omen\\icon",
		    OnClick = function(clickedframe, button)
				if button == "RightButton" then Omen:ShowConfig() else Omen:Toggle() end
			end,
		})
	end

	-- Optional launcher support for LFBP-3.0 if present, this code is placed here so
	-- that it runs after all other addons have loaded since we don't embed LFBP-3.0
	-- Yes, this is one big hack since LFBP-3.0 is a Rock library, and we embed it
	-- via Ace3. OnEmbedInitialize() needs to be called manually.
	if LibStub:GetLibrary("LibFuBarPlugin-3.0", true) and not IsAddOnLoaded("FuBar2Broker") then
		local LFBP = LibStub:GetLibrary("LibFuBarPlugin-3.0")
		LibStub("AceAddon-3.0"):EmbedLibrary(self, "LibFuBarPlugin-3.0")
		self:SetFuBarOption("tooltipType", "GameTooltip")
		self:SetFuBarOption("hasNoColor", true)
		self:SetFuBarOption("cannotDetachTooltip", true)
		self:SetFuBarOption("hideWithoutStandby", true)
		self:SetFuBarOption("iconPath", [[Interface\AddOns\Omen\icon]])
		self:SetFuBarOption("hasIcon", true)
		self:SetFuBarOption("defaultPosition", "RIGHT")
		self:SetFuBarOption("tooltipHiddenWhenEmpty", true)
		LFBP:OnEmbedInitialize(self)
		function Omen:OnUpdateFuBarTooltip()
			GameTooltip:AddLine("|cffffff00" .. L["Click|r to toggle the Omen window"])
			GameTooltip:AddLine("|cffffff00" .. L["Right-click|r to open the options menu"])
		end
		function Omen:OnFuBarClick(button)
			self:Toggle()
		end
		self.OpenMenu = self.ShowConfig
		self.optionsFrames["FuBar"] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Omen", L["FuBar Options"], "Omen", "FuBar")
		self:UpdateFuBarSettings()
	end
end

function Omen:OnEnable()
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")

	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("UNIT_PET", "PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("UNIT_NAME_UPDATE", "PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_PET_CHANGED", "PARTY_MEMBERS_CHANGED")
	--self:RegisterEvent("RAID_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED") -- Is this needed?

	self:RegisterEvent("PLAYER_UPDATE_RESTING", "UpdateVisible")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateVisible")

	if db.ShowWith.ShowOnlyInCombat then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisible")
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisible")
	end
	if db.UseFocus then
		self:RegisterEvent("UNIT_TARGET")
	end

	self:PARTY_MEMBERS_CHANGED()
	self:PLAYER_TARGET_CHANGED()
end

function Omen:OnDisable()
	-- Cancel all timers (well at least nil them all
	-- out in timers[], since AceTimer-3.0 cancels
	-- them all OnDisable anyway).
	for k, v in pairs(timers) do
		self:CancelTimer(v, true)
		timers[k] = nil
	end

	self:Toggle(false)
end

function Omen:OnProfileChanged(event, database, newProfileKey)
	db = database.profile
	self:SetAnchors(true)
	self:UpdateBackdrop()
	self:UpdateTitleBar()
	self:UpdateGrips()
	self:ResizeBars()
	self:ReAnchorBars()
	self:ReAnchorLabels()
	self:UpdateBarLabelSettings()
	self:UpdateVisible()
	self:UpdateBars()
	self:UpdateFuBarSettings()
end

function Omen:SetAnchors(useDB)
	local x, y, w, h

	-- Set the scale, since the scaling affects the position
	self.Anchor:SetScale(db.Scale)
	self.VGrip1:SetWidth(1 / self.VGrip1:GetEffectiveScale())
	self.VGrip2:SetWidth(1 / self.VGrip2:GetEffectiveScale())

	-- Get position
	if useDB then
		x, y = db.PositionX, db.PositionY
		if not x or not y then
			self.Anchor:ClearAllPoints()
			self.Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			x, y = self.Anchor:GetLeft(), db.GrowUp and self.Anchor:GetBottom() or self.Anchor:GetTop()
		end
	else
		x, y = self.Anchor:GetLeft(), db.GrowUp and self.Anchor:GetBottom() or self.Anchor:GetTop()
	end

	-- Get width/height
	w = useDB and db.PositionW or self.Anchor:GetWidth()
	h = useDB and db.PositionH or self.Anchor:GetHeight()

	-- Set the anchors and size
	self.Anchor:ClearAllPoints()
	self.Anchor:SetPoint(db.GrowUp and "BOTTOMLEFT" or "TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	self.Anchor:SetWidth(w)
	self.Anchor:SetHeight(h)
	self.Anchor:SetUserPlaced(nil)

	-- Save the data
	db.PositionX, db.PositionY = x, y
	db.PositionW, db.PositionH = w, h
end

function Omen:Toggle(setting)
	if setting == nil then
		setting = not self.Anchor:IsShown()
	end
	if setting then
		self.Anchor:Show()
	else
		self.Anchor:Hide()
	end
end

function Omen:UpdateVisible(event)
	local t = db.ShowWith
	if t.ShowOnlyInCombat and not InCombatLockdown() and event ~= "PLAYER_REGEN_DISABLED" then
		self:Toggle(false)
		return
	end

	local inInstance, instanceType = IsInInstance()
	local show
	if not t.Resting and IsResting() then
		show = false
	end
	if not t.PVP and inInstance and (instanceType == "pvp" or instanceType == "arena") then
		show = false
	end
	if not t.Dungeon and inInstance and (instanceType == "party" or instanceType == "raid") then
		show = false
	end
	if show == nil then
		show =	(t.Pet and UnitExists("pet")) or
				(t.Alone and GetNumPartyMembers() + GetNumRaidMembers() == 0 and not UnitExists("pet")) or
				(t.Party and GetNumPartyMembers() > 0) or
				(t.Raid and GetNumRaidMembers() > 0)
	end
	self:Toggle(show)
end

local bgFrame = {insets = {}}
function Omen:UpdateBackdrop()
	bgFrame.bgFile = LSM:Fetch("background", db.Background.Texture)
	bgFrame.edgeFile = LSM:Fetch("border", db.Background.BorderTexture)
	bgFrame.tile = db.Background.Tile
	bgFrame.tileSize = db.Background.TileSize
	bgFrame.edgeSize = db.Background.EdgeSize
	local inset = floor(db.Background.EdgeSize / 4)
	bgFrame.insets.left = inset
	bgFrame.insets.right = inset
	bgFrame.insets.top = inset
	bgFrame.insets.bottom = inset
	self.Title:SetBackdrop(bgFrame)
	self.BarList:SetBackdrop(bgFrame)

	local c = db.Background.Color
	self.Title:SetBackdropColor(c.r, c.g, c.b, c.a)
	self.BarList:SetBackdropColor(c.r, c.g, c.b, c.a)
	c = db.Background.BorderColor
	self.Title:SetBackdropBorderColor(c.r, c.g, c.b, c.a)
	self.BarList:SetBackdropBorderColor(c.r, c.g, c.b, c.a)

	local h = db.Background.EdgeSize * 2
	self.Anchor:SetMinResize(90, h)
	self.Title:SetMinResize(90, h)
	if h > db.TitleBar.Height then
		self.Title:SetHeight(h)
	else
		self.Title:SetHeight(db.TitleBar.Height)
	end
	self.Options.args.TitleBar.args.Height.min = h

	--self.FocusButton:SetPoint("TOPRIGHT", -inset, -inset)

	self:ResizeBars()
	self:ReAnchorBars()
	self:UpdateBars()
end

function Omen:UpdateTitleBar()
	local font = LSM:Fetch("font", db.TitleBar.Font)
	local size = db.TitleBar.FontSize
	local flags = db.TitleBar.FontOutline
	local color = db.TitleBar.FontColor
	self.TitleText:SetFont(font, size, flags)
	self.TitleText:SetTextColor(color.r, color.g, color.b, color.a)
	if db.Background.EdgeSize * 2 > db.TitleBar.Height then
		self.Title:SetHeight(db.Background.EdgeSize * 2)
	else
		self.Title:SetHeight(db.TitleBar.Height)
	end
end

function Omen:UpdateFuBarSettings()
	if LibStub:GetLibrary("LibFuBarPlugin-3.0", true) then
		if db.FuBar.HideMinimapButton then
			self:Hide()
		else
			self:Show()
			if self:IsFuBarMinimapAttached() ~= db.FuBar.AttachMinimap then
				self:ToggleFuBarMinimapAttached()
			end
		end
	end
end

function Omen:UpdateGrips()
	self.VGrip1:ClearAllPoints()
	self.VGrip1:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", db.VGrip1, 0)
	self.VGrip1:SetPoint("BOTTOMLEFT", self.BarList, "BOTTOMLEFT", db.VGrip1, 0)
	self.VGrip2:ClearAllPoints()
	self.VGrip2:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", db.VGrip2, 0)
	self.VGrip2:SetPoint("BOTTOMLEFT", self.BarList, "BOTTOMLEFT", db.VGrip2, 0)
	if db.Locked then
		self.Grip:Hide()
		self.VGrip1:Hide()
		self.VGrip2:Hide()
	else
		self.Grip:Show()
		self.VGrip1:Show()
		if db.Bar.ShowTPS then
			self.VGrip2:Show()
		else
			self.VGrip2:Hide()
		end
	end
end

function Omen:ToggleFocus()
	db.UseFocus = not db.UseFocus
	if db.UseFocus then
		Omen:RegisterEvent("UNIT_TARGET")
	else
		Omen:UnregisterEvent("UNIT_TARGET")
	end
	Omen:UpdateBars()
end


-----------------------------------------------------------------------------
-- Omen warnings

function Omen:Flash()
	if not self.FlashFrame then
		local flasher = CreateFrame("Frame", "OmenFlashFrame")
		flasher:SetToplevel(true)
		flasher:SetFrameStrata("FULLSCREEN_DIALOG")
		flasher:SetAllPoints(UIParent)
		flasher:EnableMouse(false)
		flasher:Hide()
		flasher.texture = flasher:CreateTexture(nil, "BACKGROUND")
		flasher.texture:SetTexture("Interface\\FullScreenTextures\\LowHealth")
		flasher.texture:SetAllPoints(UIParent)
		flasher.texture:SetBlendMode("ADD")
		flasher:SetScript("OnShow", function(self)
			self.elapsed = 0
			self:SetAlpha(0)
		end)
		flasher:SetScript("OnUpdate", function(self, elapsed)
			elapsed = self.elapsed + elapsed
			if elapsed < 2.6 then
				local alpha = elapsed % 1.3
				if alpha < 0.15 then
					self:SetAlpha(alpha / 0.15)
				elseif alpha < 0.9 then
					self:SetAlpha(1 - (alpha - 0.15) / 0.6)
				else
					self:SetAlpha(0)
				end
			else
				self:Hide()
			end
			self.elapsed = elapsed
		end)
		self.FlashFrame = flasher
	end

	self.FlashFrame:Show()
end

-- This function is adapted from Omen2 to be self-contained,
-- which was initially taken from BigWigs
function Omen:Shake()
	local shaker = self.ShakerFrame
	if not shaker then
		shaker = CreateFrame("Frame", "OmenShaker", UIParent)
		shaker:Hide()
		shaker:SetScript("OnUpdate", function(self, elapsed)
			elapsed = self.elapsed + elapsed
			local x, y = 0, 0 -- Resets to original position if we're supposed to stop.
			if elapsed >= 0.8 then
				self:Hide()
			else
				x, y = random(-8, 8), random(-8, 8)
			end
			if WorldFrame:IsProtected() and InCombatLockdown() then
				if not shaker.fail then
					Omen:Print(L["|cffff0000Error:|r Omen cannot use shake warning if you have turned on nameplates at least once since logging in."])
					shaker.fail = true
				end
				self:Hide()
			else
				WorldFrame:ClearAllPoints()
				for i = 1, #self.originalPoints do
					local v = self.originalPoints[i]
					WorldFrame:SetPoint(v[1], v[2], v[3], v[4] + x, v[5] + y)
				end
			end
			self.elapsed = elapsed
		end)
		shaker:SetScript("OnShow", function(self)
			-- Store old worldframe positions, we need them all, people have frame modifiers for it
			if not self.originalPoints then
				self.originalPoints = {}
				for i = 1, WorldFrame:GetNumPoints() do
					tinsert(self.originalPoints, {WorldFrame:GetPoint(i)})
				end
			end
			self.elapsed = 0
		end)
		self.ShakerFrame = shaker
	end

	shaker:Show()
end

function Omen:Warn(sound, flash, shake, message)
	if sound then PlaySoundFile(LSM:Fetch("sound", db.Warnings.SoundFile)) end
	if flash then self:Flash() end
	if shake then self:Shake() end
	if message then self:Pour(message, 1, 0, 0, nil, 24, "OUTLINE", true) end
end


-----------------------------------------------------------------------------
-- Omen bar stuff

do
	-- OnUpdate function for bar animation
	local function animate(self, elapsed)
		self.animationCursor = self.animationCursor + elapsed
		if self.animationCursor > self.animationTime then
			self.texture:SetWidth(self.animations[1])
			tremove(self.animations, 1)
			tremove(self.animations, 1)
			tremove(self.animations, 1)
			self.animationCursor = self.animationCursor - self.animationTime
			if #self.animations == 0 then
				self:SetScript("OnUpdate", nil)
			end
		else
			self.texture:SetWidth(self.animations[2] + (self.animations[3] * (self.animationCursor / self.animationTime)))
		end
	end

	-- function to start/queue bar animations
	local function AnimateTo(self, val)
		if val == 1/0 or val == -1/0 then return end
		if val == 0 then val = 1 end
		if #self.animations > 0 and self.animations[#self.animations-2] == val then
			return
		end
		local currentWidth = self.texture:GetWidth()
		local diff = (val - currentWidth)
		tinsert(self.animations, val)
		tinsert(self.animations, currentWidth)
		tinsert(self.animations, diff)
		self:SetScript("OnUpdate", animate)
	end

	-- Create bars on demand
	setmetatable(bars, {__index = function(self, barID)
		local bar = CreateFrame("Frame", nil, Omen.BarList)
		self[barID] = bar

		local inset = db.Background.BarInset
		local inset2 = db.Background.BarInset * 2
		local color = db.Bar.FontColor

		bar:SetWidth(Omen.Anchor:GetWidth() - inset2)
		bar:SetHeight(db.Bar.Height)
		if db.Bar.ShowHeadings then
			bar:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", inset, -inset + (barID) * -(db.Bar.Height + db.Bar.Spacing))
		else
			bar:SetPoint("TOPLEFT", Omen.BarList, "TOPLEFT", inset, -inset + (barID-1) * -(db.Bar.Height + db.Bar.Spacing))
		end

		bar.Text1 = bar:CreateFontString(nil, nil, "GameFontNormalSmall")
		bar.Text1:SetPoint("LEFT", bar, "LEFT", 5, 1)
		bar.Text1:SetJustifyH("LEFT")
		bar.Text1:SetFont(LSM:Fetch("font", db.Bar.Font), db.Bar.FontSize, db.Bar.FontOutline)
		bar.Text1:SetTextColor(color.r, color.g, color.b, color.a)
		bar.Text1:SetWidth(db.VGrip1 - 5)
		bar.Text1:SetHeight(db.Bar.FontSize)
		bar.Text1:SetNonSpaceWrap(false)

		bar.Text2 = bar:CreateFontString(nil, nil, "GameFontNormalSmall")
		bar.Text2:SetPoint("RIGHT", bar, "RIGHT", -5, 1)
		bar.Text2:SetJustifyH("RIGHT")
		bar.Text2:SetFont(LSM:Fetch("font", db.Bar.Font), db.Bar.FontSize, db.Bar.FontOutline)
		bar.Text2:SetTextColor(color.r, color.g, color.b, color.a)
		if db.Bar.ShowTPS then
			bar.Text2:SetWidth(Omen.BarList:GetWidth() - db.VGrip2 - 5)
		else
			bar.Text2:SetWidth(Omen.BarList:GetWidth() - db.VGrip1 - 5)
		end
		bar.Text2:SetHeight(db.Bar.FontSize)
		bar.Text2:SetNonSpaceWrap(false)

		bar.Text3 = bar:CreateFontString(nil, nil, "GameFontNormalSmall")
		bar.Text3:SetPoint("LEFT", bar.Text1, "RIGHT", 0, 1)
		bar.Text3:SetJustifyH("RIGHT")
		bar.Text3:SetFont(LSM:Fetch("font", db.Bar.Font), db.Bar.FontSize, db.Bar.FontOutline)
		bar.Text3:SetTextColor(color.r, color.g, color.b, color.a)
		bar.Text3:SetWidth(db.VGrip2 - db.VGrip1 - 5)
		bar.Text3:SetHeight(db.Bar.FontSize)
		bar.Text3:SetNonSpaceWrap(false)
		if not db.Bar.ShowTPS then bar.Text3:Hide() end

		bar.texture = bar:CreateTexture()
		bar.texture:SetTexture(LSM:Fetch("statusbar", db.Bar.Texture))
		bar.texture:SetPoint("TOPLEFT", bar, "TOPLEFT")
		bar.texture:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT")

		bar.animations = {}
		bar.animationCursor = 0
		bar.animationTime = 0.25
		bar.AnimateTo = AnimateTo

		if barID == 0 then
			bar.Text1:SetText(L["Name"])
			bar.Text2:SetText(L["Threat [%]"])
			bar.Text3:SetText(L["TPS"])
			color = db.Bar.HeadingBGColor
			bar.texture:SetVertexColor(color.r, color.g, color.b, color.a)
		elseif barID == 1 then
			-- Parent our TPS update frame to the first bar, so that TPS updates
			-- updates happen when at least 1 bar (the first bar) is shown.
			Omen.TPSUpdateFrame = CreateFrame("Frame", nil, bar)
			Omen.TPSUpdateFrame:SetScript("OnUpdate", function(self, elapsed) Omen:UpdateTPS() end)
			if not db.Bar.ShowTPS then Omen.TPSUpdateFrame:Hide() end
		end

		return bar
	end})
end

function Omen:ResizeBars()
	local inset = db.Background.BarInset * 2
	local w = Omen.Anchor:GetWidth() - inset
	for i = 0, #bars do
		bars[i]:SetWidth(w)
		bars[i]:SetHeight(db.Bar.Height)
	end
end

function Omen:ReAnchorBars()
	local inset = db.Background.BarInset
	if db.Bar.ShowHeadings then
		for i = 0, #bars do
			bars[i]:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", inset, -inset + (i) * -(db.Bar.Height + db.Bar.Spacing))
		end
	else
		for i = 1, #bars do
			bars[i]:SetPoint("TOPLEFT", self.BarList, "TOPLEFT", inset, -inset + (i-1) * -(db.Bar.Height + db.Bar.Spacing))
		end
		bars[0]:Hide()
	end
end

function Omen:UpdateBarLabelSettings()
	local font = LSM:Fetch("font", db.Bar.Font)
	local size = db.Bar.FontSize
	local flags = db.Bar.FontOutline
	local color = db.Bar.FontColor
	for i = 0, #bars do
		bars[i].Text1:SetFont(font, size, flags)
		bars[i].Text2:SetFont(font, size, flags)
		bars[i].Text3:SetFont(font, size, flags)
		bars[i].Text1:SetTextColor(color.r, color.g, color.b, color.a)
		bars[i].Text2:SetTextColor(color.r, color.g, color.b, color.a)
		bars[i].Text3:SetTextColor(color.r, color.g, color.b, color.a)
		bars[i].Text1:SetHeight(size)
		bars[i].Text2:SetHeight(size)
		bars[i].Text3:SetHeight(size)
	end
	color = db.Bar.HeadingBGColor
	bars[0].texture:SetVertexColor(color.r, color.g, color.b, color.a)
end

function Omen:ReAnchorLabels()
	local w = db.VGrip1
	local w2 = db.Bar.ShowTPS and Omen.BarList:GetWidth() - db.VGrip2 or Omen.BarList:GetWidth() - w
	local w3 = db.VGrip2 - db.VGrip1
	for i = 0, #bars do
		bars[i].Text1:SetWidth(w - 5)
		bars[i].Text2:SetWidth(w2 - 5)
		if db.Bar.ShowTPS then
			bars[i].Text3:SetWidth(w3 - 5)
			bars[i].Text3:Show()
		else
			bars[i].Text3:Hide()
		end
	end
end


-----------------------------------------------------------------------------
-- Omen event functions

-- Fired when a mob has its threat list updated. The mob that
-- had its list updated is the first parameter of the event.
function Omen:UNIT_THREAT_LIST_UPDATE(event, unitID)
	-- It appears that unitID can only be "target" or "focus"
	self:UpdateBars()
end

-- Fired when a unit's threat situation changes. The unit that
-- had a change in threat situation is the first parameter of
-- the event. Note that this only triggers when major state
-- changes, not when the raw threat values change.
function Omen:UNIT_THREAT_SITUATION_UPDATE(...)
	self:UpdateBars()
end

function Omen:PLAYER_TARGET_CHANGED()
	-- Stop our unit update timer for updating threat on "targettarget"
	if timers.UpdateBars then
		self:CancelTimer(timers.UpdateBars, true)
		timers.UpdateBars = nil
	end
	self:UpdateBars()
end

function Omen:UNIT_TARGET(event, unitID)
	if unitID == "focus" and db.UseFocus and self.unitID == "focustarget" then
		self:UpdateBars()
	end
end

local lastPartyUpdateTime = GetTime()

function Omen:PARTY_MEMBERS_CHANGED()
	inRaid = GetNumRaidMembers() > 0
	inParty = GetNumPartyMembers() > 0
	self:UpdateVisible()

	-- Run the update if the last call is more than 0.5 seconds ago else
	-- schedule an update 0.5 seconds later if one isn't already scheduled
	if GetTime() - lastPartyUpdateTime > 0.5 then
		self:UpdatePartyGUIDs()
	elseif not timers.UpdatePartyGUIDs then
		timers.UpdatePartyGUIDs = self:ScheduleTimer("UpdatePartyGUIDs", 0.5)
	end
end

-- This function updates the name and class guid lookup tables of the raid
function Omen:UpdatePartyGUIDs()
	lastPartyUpdateTime = GetTime()
	if timers.UpdatePartyGUIDs then
		self:CancelTimer(timers.UpdatePartyGUIDs, true)
		timers.UpdatePartyGUIDs = nil
	end

	local _
	for k, v in pairs(guidClassLookup) do
		guidClassLookup[k] = nil
	end
	if UnitGUID("player") then
		guidNameLookup[UnitGUID("player")] = UnitName("player")
		_, guidClassLookup[UnitGUID("player")] = UnitClass("player")
	end
	if UnitExists("pet") then
		guidClassLookup[UnitGUID("pet")] = "PET"
		guidNameLookup[UnitGUID("pet")] = UnitName("pet")--.." ["..UnitName("player").."]"
	end

	if inParty or inRaid then
		local playerFmt = inRaid and rID or pID
		local petFmt = inRaid and rpID or ppID
		local currentPartySize = inRaid and GetNumRaidMembers() or GetNumPartyMembers()

		for i = 1, currentPartySize do
			local unitID = playerFmt[i]
			local pGUID = UnitGUID(unitID)

			if pGUID then
				guidNameLookup[pGUID] = UnitName(unitID)
				_, guidClassLookup[pGUID] = UnitClass(unitID)

				-- lookup pet (if existing)
				local petID = petFmt[i]
				local petGUID = UnitGUID(petID)
				if petGUID then
					guidNameLookup[petGUID] = UnitName(petID)--.." ["..UnitName(unitID).."]"
					guidClassLookup[petGUID] = "PET"
				end
			end
		end
	end
end


-----------------------------------------------------------------------------
-- Omen update functions

--[[
First, some definitions:
* mob - enemy creature
* threat list - a mob's list of possible targets, along with each possible target's current threat value
* threat situation - the situation that a unit is currently in (either globally, or with respect to a certain mob)
* scaled percentage - a threat percentage, where 100% means you will pull aggro (become the primary target of the mob), and thus this % cannot be higher than 100% under normal circumstances
* raw threat percentage - the percentage of the units threat when divided by the threat of the mob's current primary target, this % CAN be over 100%
---------
state = UnitThreatSituation(unit, mob)

Returns the unit's threat situation with respect to the given mob. The state can be one of the following values:
nil = the unit is not on the mob's threat list
0 = 0-99% raw threat percentage (no indicator shown)
1 = 100% or more raw threat percentage (yellow warning indicator shown)
2 = tanking, other has 100% or more raw threat percentage (orange indicator shown)
3 = tanking, all others have less than 100% raw percentage threat (red indicator shown)
---------
state = UnitThreatSituation(unit)

Returns the unit's maximum threat state on any mob's threat list.
---------
isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation(unit, mob)

Returns detailed information about the unit's state on the mob's threat list.
isTanking is true if the unit the primary target of the mob (and by definition has 100% threat)
state is the unit's threat situation, as listed above.
scaledPercent is the current percent threat of the unit, scaled in the 0-100% range based on distance from target.
rawPercent is the current percent threat of the unit relative to the primary target of the mob.
threatValue is the amount of threat that the unit has on the mob's threat list. This is roughly approximate to the amount of damage and healing the unit has done.
---------
r, g, b = GetThreatStatusColor(state)

Returns the colors used in the UI to represent each major threat state.
]]

local threatTable           -- Format: threatTable[guid] = threatValue
local sortTable = {}        -- Format: threatTable[i] = guid -- used for sorting by sortfunction()
local tankGUID              -- Used to store which unit is tanking and hence has 100% threat by definition
local lastWarn = {          -- Used to store information for threat warnings
	threatpercent = 0,
}
local threatStore = {}      -- Format: threatStore[i] = threatTable[guid] -- used for storing past threatTables
local threatStoreTime = {}  -- Format: threatStoreTime[i] = GetTime()

local function sortfunction(a, b)
	return threatTable[a] > threatTable[b]
end

local function updatethreat(unitid, mobunitid)
	local guid = UnitGUID(unitid)
	if guid and not threatTable[guid] then
		local isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation(unitid, mobunitid)
		threatTable[guid] = threatValue or -1
		if isTanking then tankGUID = guid end
	end
end

local threatUnitIDFindList = {"target", "targettarget"}
local threatUnitIDFindList2 = {"focus", "focustarget", "target", "targettarget"}
function Omen:FindThreatMob()
	-- Figure out which mob to show threat on.
	-- It has to be attackable and not human controlled.
	local t = db.UseFocus and threatUnitIDFindList2 or threatUnitIDFindList
	local name, name2
	for i = 1, #t do
		local mob = t[i]
		if UnitExists(mob) then
			name2 = UnitName(mob)
			guidNameLookup[UnitGUID(mob)] = name2
			if not name then name = name2 end
			if not UnitIsPlayer(mob) and not UnitPlayerControlled(mob) and UnitCanAttack("player", mob) and UnitHealth(mob) > 0 then
				self.TitleText:SetText(name2)
				self.unitID = mob
				return mob
			end
		end
	end
	self.TitleText:SetText(name)
	self.unitID = nil
end

function Omen:UpdateBars()
	if not self.Anchor:IsShown() and not db.CollapseHide then return end

	-- TODO: Put a update throtle on this function

	local mobGUID, mobTargetGUID

	if testMode then
		threatTable = newTable()
		for i = 1, 25 do
			threatTable[i] = i*5000
		end
		tankGUID = 25
		self.TitleText:SetText(L["Test Mode"])
	else
		local mob = self:FindThreatMob()
		if not mob then
			self:ClearAll()
			return
		end
		mobGUID = UnitGUID(mob)

		-- Schedule a repeating timer for updating threat on "targettarget"
		-- since we get no events on a targettarget change.
		if mob == "targettarget" and not timers.UpdateBars then
			timers.UpdateBars = self:ScheduleRepeatingTimer("UpdateBars", 0.5)
		end

		-- We want the mob's target just in case the tank isn't
		-- in our raid (say an NPC or some other player)
		local mobTarget = mob.."target"
		local mobTargetGUID = UnitGUID(mobTarget)
		if mobTargetGUID then
			guidNameLookup[mobTargetGUID] = UnitName(mobTarget)
		end

		threatTable = newTable()
		threatTable[mobGUID] = -1
		tankGUID = nil

		-- Get data for threat on mob by scanning the whole raid
		if inParty or inRaid then
			if inRaid then
				for i = 1, GetNumRaidMembers() do
					updatethreat(rID[i], mob)
					updatethreat(rpID[i], mob)
					updatethreat(rtID[i], mob)
					updatethreat(rptID[i], mob)
				end
			else
				for i = 1, GetNumPartyMembers() do
					updatethreat(pID[i], mob)
					updatethreat(ppID[i], mob)
					updatethreat(ptID[i], mob)
					updatethreat(pptID[i], mob)
				end
			end

		end
		if not inRaid then
			updatethreat("player", mob)
			updatethreat("pet", mob)
			updatethreat("target", mob)
			updatethreat("pettarget", mob)
		end
		updatethreat("target", mob)
		updatethreat("targettarget", mob)
		updatethreat("focus", mob)
		updatethreat("focustarget", mob)
		updatethreat(mobTarget, mob)
		updatethreat("mouseover", mob)
		updatethreat("mouseovertarget", mob)
	end

	-- Sort the threatTable
	local i = 1
	for k, v in pairs(threatTable) do
		if v >= 0 then
			sortTable[i] = k
			i = i + 1
		end
	end
	for j = i, #sortTable do
		sortTable[j] = nil
	end
	if #sortTable == 0 then
		self:ClearAll()
		self.TitleText:SetText(guidNameLookup[mobGUID])
		return
	end
	sort(sortTable, sortfunction)

	-- Now update the bars on screen
	local inset = db.Background.BarInset * 2
	local w = self.BarList:GetWidth() - inset
	local h = self.BarList:GetHeight() - inset
	local topthreat = threatTable[sortTable[1]]
	if topthreat == 0 then topthreat = 1 end
	local tankThreat = threatTable[tankGUID or mobTargetGUID or sortTable[1]]
	local dbBar = db.Bar
	myGUID = UnitGUID("player")
	i = 1
	if db.Bar.ShowHeadings then
		if db.Autocollapse and i <= db.NumBars or i*dbBar.Height + (i-1)*dbBar.Spacing <= h then
			i = i + 1
			bars[0].texture:SetWidth(w)
			bars[0]:Show()
		end
	else
		bars[0]:Hide()
	end
	for j = 1, #sortTable do
		local guid = sortTable[j]
		local class = guidClassLookup[guid]
		if class == nil and dbBar.Classes["*NOTINPARTY*"] or dbBar.Classes[class] then
			if db.Autocollapse then
				if i > db.NumBars then break end
			else
				if i*dbBar.Height + (i-1)*dbBar.Spacing > h then break end
			end
			local bar = bars[j]
			local threat = threatTable[guid]
			bar.Text1:SetText(guidNameLookup[guid])
			if dbBar.ShortNumbers and threat > 100000 then
				bar.Text2:SetFormattedText("%2.1fk [%d%%]", threat / 100000, tankThreat == 0 and 0 or threat / tankThreat * 100)
			else
				bar.Text2:SetFormattedText("%d [%d%%]", threat / 100, tankThreat == 0 and 0 or threat / tankThreat * 100)
			end
			local c = (class == "PET" and pet_color) or (db.Bar.UseMyBarColor and guid == myGUID and db.Bar.MyBarColor) or RAID_CLASS_COLORS[class] or default_color
			bar.texture:SetVertexColor(c.r, c.g, c.b, c.a or 1)
			local width = w * threat / topthreat
			if width == 0 then width = 1 end
			if dbBar.AnimateBars and self.Anchor.IsMovingOrSizing ~= 2 then
				bar:AnimateTo(width)
			else
				bar.texture:SetWidth(width)
			end
			bar.guid = guid
			bar:Show()
			i = i + 1
		end
	end
	-- And hide the rest
	for j = db.Bar.ShowHeadings and i-1 or i, #bars do
		bars[j]:Hide()
	end
	if db.Autocollapse then
		self.Anchor:SetHeight((i-1)*dbBar.Height + (i-2)*dbBar.Spacing + self.Title:GetHeight() + inset)
	end
	self.Anchor:Show()
	self.BarList:Show()

	-- Threat warnings
	if testMode then
		threatTable = delTable(threatTable)
	else
		local pGUID = UnitGUID("player")
		local pClass = guidClassLookup[pGUID]
		local myThreatPercent = threatTable[pGUID] / tankThreat * 100
		local t = db.Warnings
		if lastWarn.mobGUID == mobGUID and myThreatPercent >= t.Threshold and t.Threshold > lastWarn.threatpercent then
			if not t.DisableWhileTanking or not (pClass == "WARRIOR" and GetBonusBarOffset() == 2 or
			  pClass == "DRUID" and GetBonusBarOffset() == 3 or
			  pClass == "PALADIN" and UnitAura("player", GetSpellInfo(25780)) or
			  pClass == "DEATHKNIGHT" and GetShapeshiftFormInfo(GetShapeshiftForm()) == "Interface\\Icons\\Spell_Deathknight_FrostPresence") then
				self:Warn(t.Sound, t.Flash, t.Shake, t.Message and L["Passed %s%% of %s's threat!"]:format(t.Threshold, guidNameLookup[tankGUID or mobTargetGUID or sortTable[1]]))
			end
		end
		-- Remove TPS data if the last scanned mob is different
		if lastWarn.mobGUID ~= mobGUID then
			delTable(threatStore)
			threatStore = newTable()
			clearTable(threatStoreTime)
		end
		tinsert(threatStore, threatTable)
		tinsert(threatStoreTime, GetTime())
		-- Store last scanned mob GUID
		lastWarn.mobGUID = mobGUID
		lastWarn.threatpercent = myThreatPercent
		threatTable = nil
	end
end

function Omen:ClearAll()
	for i = 0, #bars do
		bars[i]:Hide()
	end
	self.TitleText:SetText(self.defaultTitle)
	if db.Autocollapse then
		self.Anchor:SetHeight(self.Title:GetHeight())
		self.BarList:Hide()
		if db.CollapseHide and not self.Anchor.IsMovingOrSizing then
			self.Anchor:Hide()
		end
	end
	-- Store last scanned mob GUID
	lastWarn.mobGUID = nil
	lastWarn.threatpercent = 0
	-- Remove TPS data
	delTable(threatStore)
	threatStore = newTable()
	clearTable(threatStoreTime)
	threatTable = nil
end

function Omen:UpdateTPS()
	if testMode then
		for i = 1, #bars do
			bars[i].Text3:SetText(1300 - 50*i)
		end
		return
	end
	-- Remove data that is too old
	local TPSWindow = db.Bar.TPSWindow
	local startTime = GetTime() - TPSWindow
	while threatStoreTime[2] and startTime > threatStoreTime[2] do
		delTable(tremove(threatStore, 1))
		tremove(threatStoreTime, 1)
	end
	-- Now check that we still have enough data
	local dataSize = #threatStoreTime
	if dataSize == 0 or startTime <= threatStoreTime[1] then
		-- We do not have enough data, TPSWindow seconds has not passed
		for i = 1, #bars do
			bars[i].Text3:SetText("??")
		end
		return
	end
	-- Check for special case with just 1 data point past TPSWindow seconds
	if dataSize == 1 then
		-- Threat generated is 0
		for i = 1, #bars do
			bars[i].Text3:SetText("0")
		end
		return
	end
	-- We have at least 2 data points
	for i = 1, #bars do
		if not bars[i]:IsShown() then return end
		local guid = bars[i].guid
		local baseThreat = threatStore[1][guid]
		local secondThreat = threatStore[2][guid]
		local finalThreat = threatStore[dataSize][guid]
		if baseThreat and secondThreat and finalThreat then
			-- Calculate TPS
			local ratio = (startTime - threatStoreTime[1]) / (threatStoreTime[2] - threatStoreTime[1])
			local startThreat = (secondThreat - baseThreat) * ratio + baseThreat
			bars[i].Text3:SetFormattedText("%d", (finalThreat - startThreat) / TPSWindow / 100)
		else
			-- We don't have enough data for this unit
			bars[i].Text3:SetText("??")
		end
	end
end


-----------------------------------------------------------------------------
-- Title Right Click menu

do
	local info = {}
	local Omen_TitleDropDownMenu = CreateFrame("Frame", "Omen_TitleDropDownMenu")
	Omen_TitleDropDownMenu.displayMode = "MENU"
	Omen_TitleDropDownMenu.initialize = function(self, level)
		if not level then return end
		for k in pairs(info) do info[k] = nil end
		if level == 1 then
			-- Create the title of the menu
			info.isTitle      = 1
			info.text         = L["Omen Quick Menu"]
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil

			info.text = L["Lock Omen"]
			info.func = function()
				db.Locked = not db.Locked
				Omen:UpdateGrips()
				LibStub("AceConfigRegistry-3.0"):NotifyChange("Omen")
			end
			info.checked = db.Locked
			UIDropDownMenu_AddButton(info, level)

			info.text = "Use Focus Target"
			info.func = function() Omen:ToggleFocus() end
			info.checked = db.UseFocus
			UIDropDownMenu_AddButton(info, level)

			info.text = "Test Mode"
			info.func = function()
				testMode = not testMode
				Omen:UpdateBars()
			end
			info.checked = testMode
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Open Config"]
			info.func = function() Omen:ShowConfig() end
			info.checked = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = L["Hide Omen"]
			info.func = function() Omen:Toggle() end
			UIDropDownMenu_AddButton(info, level)

			-- Close menu item
			info.text         = CLOSE
			info.func         = function() CloseDropDownMenus() end
			info.checked      = nil
			info.arg1         = nil
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
		end
	end
end


-----------------------------------------------------------------------------
-- Omen config stuff

local outlines = {
	[""]             = L["None"],
	["OUTLINE"]      = L["Outline"],
	["THICKOUTLINE"] = L["Thick Outline"],
}

local function GetFuBarMinimapAttachedStatus(info)
	return Omen:IsFuBarMinimapAttached() or db.FuBar.HideMinimapButton
end

-- Option table for the AceGUI config only
local options = {
	type = "group",
	name = "Omen",
	get = function(info) return db[ info[#info] ] end,
	set = function(info, value) db[ info[#info] ] = value end,
	args = {
		General = {
			order = 1,
			type = "group",
			name = L["General Settings"],
			desc = L["General Settings"],
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["OMEN_DESC"],
				},
				Alpha = {
					order = 3,
					name = L["Alpha"],
					desc = L["Controls the transparency of the main Omen window."],
					type = "range",
					min = 0, max = 1, step = 0.01,
					isPercent = true,
					set = function(info, value)
						db.Alpha = value
						Omen.Anchor:SetAlpha(value)
					end,
				},
				Scale = {
					order = 5,
					name = L["Scale"],
					desc = L["Controls the scaling of the main Omen window."],
					type = "range",
					min = 0.50, max = 1.50, step = 0.01,
					isPercent = true,
					set = function(info, value)
						db.Scale = value
						Omen:SetAnchors()
					end,
				},
				Locked = {
					type = "toggle",
					name = L["Lock Omen"],
					desc = L["Locks Omen in place and prevents it from being dragged or resized."],
					order = 7,
					set = function(info, value)
						db.Locked = value
						Omen:UpdateGrips()
					end,
				},
				Autocollapse = {
					type = "toggle",
					name = L["Autocollapse"],
					desc = L["Collapse to show a minimum number of bars"],
					order = 10,
					set = function(info, value)
						db.Autocollapse = value
						Omen.Anchor:SetHeight(5*db.Bar.Height + 4*db.Bar.Spacing + Omen.Title:GetHeight() + 2*db.Background.BarInset)
						Omen:SetAnchors()
						Omen.BarList:Show()
						Omen:UpdateVisible()
						Omen:UpdateBars()
					end,
				},
				AutocollapseGroup = {
					type = "group",
					name = L["Autocollapse Options"],
					guiInline = true,
					order = 11,
					disabled = function() return not db.Autocollapse end,
					set = function(info, value)
						db[ info[#info] ] = value
						Omen:UpdateVisible()
						Omen:UpdateBars()
					end,
					args = {
						GrowUp = {
							order = 1,
							type = "toggle",
							name = L["Grow bars upwards"],
							desc = L["Grow bars upwards"],
							set = function(info, value)
								db.GrowUp = value
								Omen:SetAnchors()
							end,
						},
						CollapseHide = {
							order = 2,
							type = "toggle",
							name = L["Hide Omen on 0 bars"],
							desc = L["Hide Omen entirely if it collapses to show 0 bars"],
						},
						NumBars = {
							order = 3,
							name = L["Max bars to show"],
							desc = L["Max number of bars to show"],
							type = "range",
							min = 1, max = 40, step = 1,
						},
					},
				},
				Background = {
					type = "group",
					name = L["Background Options"],
					guiInline = true,
					order = 21,
					get = function(info) return db.Background[ info[#info] ] end,
					set = function(info, value)
						db.Background[ info[#info] ] = value
						Omen:UpdateBackdrop()
					end,
					args = {
						Texture = {
							type = "select", dialogControl = 'LSM30_Background',
							order = 1,
							name = L["Background Texture"],
							desc = L["Texture to use for the frame's background"],
							values = AceGUIWidgetLSMlists.background,
						},
						BorderTexture = {
							type = "select", dialogControl = 'LSM30_Border',
							order = 2,
							name = L["Border Texture"],
							desc = L["Texture to use for the frame's border"],
							values = AceGUIWidgetLSMlists.border,
						},
						Color = {
							type = "color",
							order = 3,
							name = L["Background Color"],
							desc = L["Frame's background color"],
							hasAlpha = true,
							get = function(info)
								local t = db.Background.Color
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = db.Background.Color
								t.r, t.g, t.b, t.a = r, g, b, a
								Omen:UpdateBackdrop()
							end,
						},
						BorderColor = {
							type = "color",
							order = 4,
							name = L["Border Color"],
							desc = L["Frame's border color"],
							hasAlpha = true,
							get = function(info)
								local t = db.Background.BorderColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = db.Background.BorderColor
								t.r, t.g, t.b, t.a = r, g, b, a
								Omen:UpdateBackdrop()
							end,
						},
						Tile = {
							type = "toggle",
							order = 5,
							name = L["Tile Background"],
							desc = L["Tile the background texture"],
						},
						TileSize = {
							type = "range",
							order = 6,
							name = L["Background Tile Size"],
							desc = L["The size used to tile the background texture"],
							min = 16, max = 256, step = 1,
							disabled = function() return not db.Background.Tile end,
						},
						EdgeSize = {
							type = "range",
							order = 7,
							name = L["Border Thickness"],
							desc = L["The thickness of the border"],
							min = 1, max = 16, step = 1,
						},
						BarInset = {
							type = "range",
							order = 8,
							name = L["Bar Inset"],
							desc = L["Sets how far inside the frame the threat bars will display from the 4 borders of the frame"],
							min = 1, max = 16, step = 1,
						},
					},
				},
			},
		},
		ShowWhen = {
			order = 2,
			type = "group",
			name = L["Show When..."],
			desc = L["Show Omen when..."],
			get = function(info) return db.ShowWith[ info[#info] ] end,
			set = function(info, value)
				db.ShowWith[ info[#info] ] = value
				Omen:UpdateVisible()
				Omen:UpdateBars()
			end,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["Show Omen when any of the following are true"],
				},
				Alone = {
					type = "toggle",
					order = 2,
					name = L["You are alone"],
					desc = L["Show Omen when you are alone"],
				},
				PVP = {
					type = "toggle",
					order = 3,
					name = L["You are in a battleground"],
					desc = L["Show Omen when you are in a battleground or arena"],
				},
				Dungeon = {
					type = "toggle",
					order = 4,
					name = L["You are in a dungeon"],
					desc = L["Show Omen when you are in a dungeon (5 man and raid)"],
				},
				Party = {
					type = "toggle",
					order = 5,
					name = L["You are in a party"],
					desc = L["Show Omen when you are in a 5-man party"],
				},
				Raid = {
					type = "toggle",
					order = 6,
					name = L["You are in a raid"],
					desc = L["Show Omen when you are in a raid"],
				},
				Resting = {
					type = "toggle",
					order = 7,
					name = L["You are resting"],
					desc = L["Show Omen when you are resting"],
				},
				Pet = {
					type = "toggle",
					order = 8,
					name = L["You have a pet"],
					desc = L["Show Omen when you have a pet out"],
				},
				intro2 = {
					order = 10,
					type = "description",
					name = L["In addition to the above options..."],
				},
				ShowOnlyInCombat = {
					type = "toggle",
					order = 11,
					width = "double",
					name = L["Only show when in combat"],
					desc = L["Turning this on will cause Omen to hide whenever you are not in combat."],
					set = function(info, value)
						db.ShowWith.ShowOnlyInCombat = value
						if value then
							Omen:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateVisible")
							Omen:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateVisible")
						else
							Omen:UnregisterEvent("PLAYER_REGEN_DISABLED")
							Omen:UnregisterEvent("PLAYER_REGEN_ENABLED")
						end
						Omen:UpdateVisible()
						Omen:UpdateBars()
					end,
				},
			},
		},
		ShowClasses = {
			order = 3,
			type = "group",
			name = L["Show Classes..."],
			desc = L["Show Classes..."],
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["SHOW_CLASSES_DESC"],
				},
				Classes = {
					type = "multiselect",
					order = 30,
					name = L["Show bars for these classes"],
					values = {
						DEATHKNIGHT = L["DEATHKNIGHT"],
						DRUID = L["DRUID"],
						HUNTER = L["HUNTER"],
						MAGE = L["MAGE"],
						PALADIN = L["PALADIN"],
						PET = L["PET"],
						PRIEST = L["PRIEST"],
						ROGUE = L["ROGUE"],
						SHAMAN = L["SHAMAN"],
						WARLOCK = L["WARLOCK"],
						WARRIOR = L["WARRIOR"],
						["*NOTINPARTY*"] = L["*Not in Party*"],
					},
					get = function(info, k) return db.Bar.Classes[k] end,
					set = function(info, k, v)
						db.Bar.Classes[k] = v
						Omen:UpdateBars()
					end,
				},
			},
		},
		TitleBar = {
			order = 4,
			type = "group",
			name = L["Title Bar Settings"],
			desc = L["Title Bar Settings"],
			get = function(info) return db.TitleBar[ info[#info] ] end,
			set = function(info, value)
				db.TitleBar[ info[#info] ] = value
				Omen:UpdateTitleBar()
			end,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["Configure title bar settings."],
				},
				Height = {
					type = "range",
					order = 2,
					name = L["Title Bar Height"],
					desc = L["Height of the title bar. The minimum height allowed is twice the background border thickness."],
					min = 2, max = 32, step = 1,
				},
				TitleText = {
					type = "group",
					name = L["Title Text Options"],
					guiInline = true,
					order = 20,
					args = {
						Font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 1,
							name = L["Font"],
							desc = L["The font that the title text will use"],
							values = AceGUIWidgetLSMlists.font,
						},
						FontOutline = {
							type = "select",
							order = 2,
							name = L["Font Outline"],
							desc = L["The outline that the title text will use"],
							values = outlines,
						},
						FontColor = {
							type = "color",
							order = 3,
							name = L["Font Color"],
							desc = L["The color of the title text"],
							hasAlpha = true,
							get = function(info)
								local t = db.TitleBar.FontColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = db.TitleBar.FontColor
								t.r, t.g, t.b, t.a = r, g, b, a
								Omen:UpdateTitleBar()
							end,
						},
						FontSize = {
							type = "range",
							order = 4,
							name = L["Font Size"],
							desc = L["Control the font size of the title text"],
							min = 4, max = 30, step = 1,
						},
					},
				},
			},
		},
		Bars = {
			order = 5,
			type = "group",
			name = L["Bar Settings"],
			desc = L["Bar Settings"],
			get = function(info) return db.Bar[ info[#info] ] end,
			set = function(info, value)
				db.Bar[ info[#info] ] = value
				Omen:UpdateBars()
			end,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["Configure bar settings."],
				},
				AnimateBars = {
					type = "toggle",
					order = 2,
					name = L["Animate Bars"],
					desc = L["Smoothly animate bar changes"],
				},
				ShortNumbers = {
					type = "toggle",
					order = 3,
					name = L["Short Numbers"],
					desc = L["Display large numbers in Ks"],
				},
				Height = {
					type = "range",
					order = 4,
					name = L["Bar Height"],
					desc = L["Height of each bar"],
					min = 5, max = 50, step = 1, bigStep = 1,
					set = function(info, value)
						db.Bar.Height = value
						Omen:ReAnchorBars()
						Omen:ResizeBars()
						Omen:UpdateBars()
					end,
				},
				Spacing = {
					type = "range",
					order = 5,
					name = L["Bar Spacing"],
					desc = L["Spacing between each bar"],
					min = 0, max = 20, step = 1, bigStep = 1,
					set = function(info, value)
						db.Bar.Spacing = value
						Omen:ReAnchorBars()
						Omen:UpdateBars()
					end,
				},
				ShowTPS = {
					type = "toggle",
					order = 6,
					name = L["Show TPS"],
					desc = L["Show threat per second values"],
					set = function(info, value)
						db.Bar.ShowTPS = value
						if db.VGrip1 > db.VGrip2 then
							db.VGrip1, db.VGrip2 = db.VGrip2, db.VGrip1
						end
						movegrip1()
						movegrip2()
						Omen:UpdateGrips()
						local f = Omen.TPSUpdateFrame
						if f then
							if value then f:Show() else f:Hide() end
						end
					end,
				},
				TPSWindow = {
					type = "range",
					order = 7,
					name = L["TPS Window"],
					desc = L["TPS_WINDOW_DESC"],
					min = 3, max = 15, step = 0.1,
					disabled = function() return not db.Bar.ShowTPS end,
				},
				ShowHeadings = {
					type = "toggle",
					order = 8,
					name = L["Show Headings"],
					desc = L["Show column headings"],
					set = function(info, value)
						db.Bar.ShowHeadings = value
						Omen:ReAnchorBars()
						Omen:UpdateBars()
					end,
				},
				HeadingBGColor = {
					type = "color",
					order = 9,
					name = L["Heading BG Color"],
					desc = L["Heading background color"],
					hasAlpha = true,
					get = function(info)
						local t = db.Bar.HeadingBGColor
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b, a)
						local t = db.Bar.HeadingBGColor
						t.r, t.g, t.b, t.a = r, g, b, a
						Omen:UpdateBarLabelSettings()
					end,
					disabled = function() return not db.Bar.ShowHeadings end,
				},
				UseMyBarColor = {
					type = "toggle",
					order = 10,
					name = L["Use 'My Bar' color"],
					desc = L["Use a different colored background for your threat bar in Omen"],
				},
				MyBarColor = {
					type = "color",
					order = 11,
					name = L["'My Bar' BG Color"],
					desc = L["The background color for your threat bar"],
					hasAlpha = true,
					get = function(info)
						local t = db.Bar.MyBarColor
						return t.r, t.g, t.b, t.a
					end,
					set = function(info, r, g, b, a)
						local t = db.Bar.MyBarColor
						t.r, t.g, t.b, t.a = r, g, b, a
						Omen:UpdateBars()
					end,
					disabled = function() return not db.Bar.UseMyBarColor end,
				},
				Texture = {
					type = "select", dialogControl = 'LSM30_Statusbar',
					order = 15,
					name = L["Bar Texture"],
					desc = L["The texture that the bar will use"],
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, v)
						db.Bar.Texture = v
						local texturepath = LSM:Fetch("statusbar", v)
						for i = 0, #bars do
							bars[i].texture:SetTexture(texturepath)
						end
					end,
				},
				BarLabelsGroup = {
					type = "group",
					name = L["Bar Label Options"],
					guiInline = true,
					order = 20,
					set = function(info, v)
						db.Bar[ info[#info] ] = v
						Omen:UpdateBarLabelSettings()
					end,
					args = {
						Font = {
							type = "select", dialogControl = 'LSM30_Font',
							order = 1,
							name = L["Font"],
							desc = L["The font that the labels will use"],
							values = AceGUIWidgetLSMlists.font,
						},
						FontOutline = {
							type = "select",
							order = 2,
							name = L["Font Outline"],
							desc = L["The outline that the labels will use"],
							values = outlines,
						},
						FontColor = {
							type = "color",
							order = 3,
							name = L["Font Color"],
							desc = L["The color of the labels"],
							hasAlpha = true,
							get = function(info)
								local t = db.Bar.FontColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = db.Bar.FontColor
								t.r, t.g, t.b, t.a = r, g, b, a
								Omen:UpdateBarLabelSettings()
							end,
						},
						FontSize = {
							type = "range",
							order = 4,
							name = L["Font Size"],
							desc = L["Control the font size of the labels"],
							min = 4, max = 30, step = 1,
						},
					},
				},
			},
		},
		Warnings = {
			order = 6,
			type = "group",
			name = L["Warning Settings"],
			desc = L["Warning Settings"],
			get = function(info) return db.Warnings[ info[#info] ] end,
			set = function(info, value)
				db.Warnings[ info[#info] ] = value
			end,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["OMEN_WARNINGS_DESC"],
				},
				Sound = {
					type = "toggle",
					order = 2,
					name = L["Enable Sound"],
					desc = L["Causes Omen to play a chosen sound effect"],
				},
				Flash = {
					type = "toggle",
					order = 3,
					name = L["Enable Screen Flash"],
					desc = L["Causes the entire screen to flash red momentarily"],
				},
				Shake = {
					type = "toggle",
					order = 4,
					name = L["Enable Screen Shake"],
					desc = L["Causes the entire game world to shake momentarily. This option only works if nameplates are turned off."],
				},
				Message = {
					type = "toggle",
					order = 5,
					name = L["Enable Warning Message"],
					desc = L["Print a message to screen when you accumulate too much threat"],
				},
				Output = Omen:GetSinkAce3OptionsDataTable(),
				Threshold = {
					type = "range",
					order = 7,
					name = L["Warning Threshold %"],
					desc = L["Warning Threshold %"],
					min = 60, max = 130, step = 1,
				},
				SoundFile = {
					type = "select", dialogControl = 'LSM30_Sound',
					order = 8,
					name = L["Sound to play"],
					desc = L["Sound to play"],
					values = AceGUIWidgetLSMlists.sound,
					disabled = function() return not db.Warnings.Sound end,
				},
				DisableWhileTanking = {
					type = "toggle",
					order = 9,
					name = L["Disable while tanking"],
					desc = L["DISABLE_WHILE_TANKING_DESC"],
				},
				test = {
					type = "execute",
					order = -1,
					name = L["Test warnings"],
					desc = L["Test warnings"],
					func = function()
						local t = db.Warnings
						Omen:Warn(t.Sound, t.Flash, t.Shake, t.Message and L["Test warnings"])
					end,
				},
			},
		},
		FuBar = {
			order = -4,
			type = "group",
			name = L["FuBar Options"],
			desc = L["FuBar Options"],
			hidden = function() return Omen.IsFuBarMinimapAttached == nil end,
			args = {
				hideIcon = {
					type = "toggle",
					order = 1,
					name = L["Hide minimap/FuBar icon"],
					desc = L["Hide minimap/FuBar icon"],
					get = function(info) return db.FuBar.HideMinimapButton end,
					set = function(info, v)
						db.FuBar.HideMinimapButton = v
						Omen:UpdateFuBarSettings()
					end,
				},
				attachMinimap = {
					type = "toggle",
					order = 2,
					name = L["Attach to minimap"],
					desc = L["Attach to minimap"],
					get = function(info) return Omen:IsFuBarMinimapAttached() end,
					set = function(info, v)
						Omen:ToggleFuBarMinimapAttached()
						db.FuBar.AttachMinimap = Omen:IsFuBarMinimapAttached()
					end,
					disabled = function() return db.FuBar.HideMinimapButton end,
				},
				showIcon = {
					type = "toggle",
					order = 3,
					name = L["Show icon"],
					desc = L["Show icon"],
					get = function(info) return Omen:IsFuBarIconShown() end,
					set = function(info, v) Omen:ToggleFuBarIconShown() end,
					disabled = GetFuBarMinimapAttachedStatus,
				},
				showText = {
					type = "toggle",
					order = 4,
					name = L["Show text"],
					desc = L["Show text"],
					get = function(info) return Omen:IsFuBarTextShown() end,
					set = function(info, v) Omen:ToggleFuBarTextShown() end,
					disabled = GetFuBarMinimapAttachedStatus,
				},
				position = {
					type = "select",
					order = 5,
					name = L["Position"],
					desc = L["Position"],
					values = {LEFT = L["Left"], CENTER = L["Center"], RIGHT = L["Right"]},
					get = function() return Omen:GetPanel() and Omen:GetPanel():GetPluginSide(Omen) end,
					set = function(info, val)
						if Omen:GetPanel() and Omen:GetPanel().SetPluginSide then
							Omen:GetPanel():SetPluginSide(Omen, val)
						end
					end,
					disabled = GetFuBarMinimapAttachedStatus,
				}
			}
		},
		Help = {
			type = "group",
			order = -1,
			name = L["Help File"],
			desc = L["A collection of help pages"],
			childGroups = "select",
			args = {
				FAQ = {
					type = "group",
					name = "FAQ",
					args = {
						header = {
							type = "header",
							name = L["Frequently Asked Questions"],
							order = 0,
						},
						text = {
							order = 1,
							type = "description",
							name = L["GENERAL_FAQ"],
						},
					},
				},
				WARRIOR = {
					type = "group",
					name = "Warrior",
					args = {
						header = {
							type = "header",
							name = L["Warrior"],
							order = 0,
						},
						text = {
							order = 1,
							type = "description",
							name = L["WARRIOR_FAQ"],
						},
					},
				},
			},
		},
	},
}
Omen.Options = options
options.args.Warnings.args.Output.order = 6
options.args.Warnings.args.Output.inline = true
options.args.Warnings.args.Output.disabled = function() return not db.Warnings.Message end

-- Option table for the slash command only
local optionsSlash = {
	type = "group",
	name = L["Slash Command"],
	order = -3,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["OMEN_SLASH_DESC"],
			cmdHidden = true,
		},
		toggle = {
			type = "execute",
			name = L["Toggle Omen"],
			desc = L["Toggle Omen"].." ( /omen toggle )",
			func = function()
				Omen:Toggle()
			end,
		},
		center = {
			type = "execute",
			name = L["Center Omen"],
			desc = L["Center Omen"].." ( /omen center )",
			func = function()
				Omen.Anchor:ClearAllPoints()
				Omen.Anchor:SetPoint("CENTER", UIParent, "CENTER")
				Omen:SetAnchors()
			end,
		},
		config = {
			type = "execute",
			name = L["Configure"],
			desc = L["Open the configuration dialog"].." ( /omen config )",
			func = function()
				Omen:ShowConfig()
			end,
			guiHidden = true,
		},
	},
}
Omen.OptionsSlash = optionsSlash

function Omen:SetupOptions()
	self.optionsFrames = {}

	-- setup options table
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Omen", options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("OmenSlashCommand", optionsSlash, "omen")
	local ACD3 = LibStub("AceConfigDialog-3.0")

	-- The ordering here matters, it determines the order in the Blizzard Interface Options
	self.optionsFrames.Omen = ACD3:AddToBlizOptions("Omen", nil, nil, "General")
	self.optionsFrames.ShowWhen = ACD3:AddToBlizOptions("Omen", L["Show When..."], "Omen", "ShowWhen")
	self.optionsFrames.ShowClasses = ACD3:AddToBlizOptions("Omen", L["Show Classes..."], "Omen", "ShowClasses")
	self.optionsFrames.TitleBar = ACD3:AddToBlizOptions("Omen", L["Title Bar Settings"], "Omen", "TitleBar")
	self.optionsFrames.Bars = ACD3:AddToBlizOptions("Omen", L["Bar Settings"], "Omen", "Bars")
	self.optionsFrames.Warnings = ACD3:AddToBlizOptions("Omen", L["Warning Settings"], "Omen", "Warnings")
	self:RegisterModuleOptions("OmenSlashCommand", optionsSlash, L["Slash Command"])
	self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), L["Profiles"])
	self.optionsFrames.Help = ACD3:AddToBlizOptions("Omen", L["Help File"], "Omen", "Help")

	-- Add ordering data to the option table generated by AceDBOptions-3.0
	options.args.Profiles.order = -2
end

function Omen:RegisterModuleOptions(name, optionTbl, displayName)
	options.args[name] = (type(optionTbl) == "function") and optionTbl() or optionTbl
	self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Omen", displayName, "Omen", name)
end

function Omen:ShowConfig()
	-- Open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Omen)
end

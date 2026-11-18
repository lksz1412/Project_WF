local L  		= AceLibrary("AceLocale-2.2"):new("eePanels2")
local media		= LibStub("LibSharedMedia-2.0")
local waterfall	= AceLibrary:HasInstance("Waterfall-1.0") and AceLibrary("Waterfall-1.0")
local dewdrop	= AceLibrary:HasInstance("Dewdrop-2.0") and AceLibrary("Dewdrop-2.0")

 

-- The keys in these tables are passed into our code to create/modify panels
-- The values in these tables are localized strings used in our AceOption GUI
local bgColorStyleOpt		= { ["Solid"] = L["Solid"], ["Gradient"] = L["Gradient"] }
local bgGradOrientationOpt	= { ["HORIZONTAL"]=L["Horizontal"], ["VERTICAL"]=L["Vertical"]}
local blendModeOpt			= { ["DISABLE"]=L["Disable"], ["BLEND"]=L["Blend"], ["ADD"]=L["Add"], ["MOD"]=L["Mod"] }
local offsetPositionOpt		= { ["TOPLEFT"]=L["TopLeft"], ["TOPRIGHT"]=L["TopRight"], ["CENTER"]=L["Center"], 
								["BOTTOMLEFT"]=L["BottomLeft"], ["BOTTOMRIGHT"]=L["BottomRight"], ["TOP"]=L["Top"], 
								["BOTTOM"]=L["Bottom"], ["LEFT"]=L["Left"], ["RIGHT"]=L["Right"] }
local frameStrataOpt		= { ["BACKGROUND"]=L["Background"], ["LOW"]=L["Low"], ["MEDIUM"]=L["Medium"], 
								["HIGH"]=L["High"], ["DIALOG"]=L["Dialog"], ["TOOLTIP"]=L["Tooltip"] }



--[[
-- Self explanitory
--]]
local function DeepCopy(t, lookup_table)
	local copy = {}
	if type(t) ~= "table" then return t end
	for i,v in pairs(t) do
		if type(v) ~= "table" then
			copy[i] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[t] = copy
			if lookup_table[v] then
				copy[i] = lookup_table[v] -- we already copied this table. reuse the copy.
			else
				copy[i] = DeepCopy(v,lookup_table) -- not yet copied. copy it.
			end
		end
	end
	return copy
end


--[[
-- Reverse table lookup
--]]
local function RLookup(table,value)
	for k,v in pairs(table) do
		if v == value then return k end
	end
	return nil
end


-- This is used to find if a panel's parent/anchor frame exists
-- When you perform a lookup on this table, it will see if the frame exists.  If not, it peforms a global lookup, and caches the name if found
local frameExists = setmetatable({["UIParent"]=true}, { 
	-- If we don't find a match in the frameExists table, this function will be called
	__index = function(self, frameName)
		-- Lookup the frame name in the global namespace
		local f = getglobal(frameName)
		-- Make sure it's a table that's created by users to cut down the risk of a naming collision
		if (f and (type(f) == "table") and type(rawget(f, 0)) == "userdata") then
			-- If frame is found, cache table as existing in our table
			self[frameName] = true
			return true
		end
	end
})


-- Holds copied panel data
local copyItem	= {}


-- This array is used to mark the indexes of panels with non-existant anchor/parent frames
-- (ie: badParents[PANEL_NUMBER] = false means it's 'bad')
local badParents = {}


-- Default panel settings
local dp = 
{
	locked = false,
	parent = "UIParent",
	name = "",
	x = 0,
	y = 0,
	width = 200,
	height = 100,
	scale = 1.0, -- placeholder
	visible = true,
	level = 0,
	strata = RLookup(frameStrataOpt, L["Background"]),
	mouse = false,
	anchor = "UIParent",
	anchorFrom = RLookup(offsetPositionOpt, L["Center"]),
	anchorTo = RLookup(offsetPositionOpt, L["Center"]),
	text = -- placeholder
	{
		text = "",
		font = "",
		size = 0,
	},
	border = 
	{
		color = {r=1,g=1,b=1,a=1},
		texture = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		media = "",
	},
	background = 
	{
		blend = RLookup(blendModeOpt, L["Disable"]),
		style = RLookup(bgColorStyleOpt, L["Solid"]),
		color = {r=.3,g=.3,b=.3,a=0.6},
		insetSizeAll = 4,
		insetSize = {t=4,b=4,l=4,r=4},
		tiling = false,
		tileSize = 0,
		gradient =
		{
			offset = 0,
			color = {r=1,g=1,b=1,a=0},
			orientation = RLookup(bgGradOrientationOpt, L["Horizontal"])
		},
		texture = -- background backdrop image options
		{
			texture = "Interface\\None",
			media = "",
			alpha = 1,
		},
	},
	scripts = 
	{
	},
}









-- Create addon table; inititalize mixins and libs
eePanels2 = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")
-- Fetch database data
eePanels2:RegisterDB("eePanels2DB")
-- Setup Ace variables
eePanels2.name						= L["eePanels2"]
eePanels2.defaultPosition			= "LEFT"
eePanels2.defaultMinimapPosition	= 75
eePanels2.hasIcon					= true
eePanels2.cannotDetachTooltip		= true
eePanels2.independentProfile		= true
eePanels2.hideWithoutStandby		= true
eePanels2.hasNoColor				= true
eePanels2.blizzardTooltip			= true
-- Setup main gui menu
eePanels2.OnMenuRequest = 
{ 
	type='group',
	args = 
	{
		mode = 
		{
			type = 'toggle',
			name = L["Mode"],
			desc = L["ModeDesc"],
			get  = function() return eePanels2.db.profile.advancedMode end,
			set  = function(val) eePanels2.db.profile.advancedMode = val eePanels2:CreateMenus() end,
			order = 5,
		},
		
		showWarnings = 
		{
			type = 'toggle',
			name = L["Warnings"],
			desc = L["WarningsDesc"],
			get  = function() return eePanels2.db.profile.showWarnings end,
			set  = function(val) eePanels2.db.profile.showWarnings = val end,
			order = 6,
		},
		
		dynamicFrameFix = 
		{
			type = 'toggle',
			name = L["DynamicFrame"],
			desc = L["DynamicFrameDesc"],
			get  = function() return eePanels2.db.profile.dynamicFrameHack end,
			set  = function(val) eePanels2.db.profile.dynamicFrameHack = val eePanels2:DynamicFrameHack(false) end,
			order = 7,
		},

		newPanel = 
		{
			type = 'group',
			name = L["NewPanel"],
			desc = L["NewPanelDesc"],
			order = 10,
			args = 
			{
			
				defaultPanel = 
				{
					type = 'execute',
					name = L["DefaultPanel"],
					desc = L["DefaultPanelDesc"],
					func = function(v) eePanels2:CreatePanel(nil,false) end,
					order = 5
				},
			
				globalPanel = 
				{
					type = 'execute',
					name = L["GlobalPanel"],
					desc = L["GlobalPanelDesc"],
					func = function(v) eePanels2:CreatePanel(nil,true) end,
					order = 10
				},
			}
		},
		
		space = 
		{
			name = " ",
			type = 'header',
			order = 15,
			hidden = function() return not (#eePanels2.db.profile.panels > 0) end,
		},

		globalSettings = 
		{
			type = 'group',
			name = L["GlobalSettings"],
			desc = L["GlobalSettingsDesc"],
			hidden = false,
			hidden = function() return not (#eePanels2.db.profile.panels > 0) end,
			order = 20,
			args = {}
		},
		
		panels = 
		{
			type = 'group',
			name = L["PanelSettings"],
			desc = L["PanelSettingsDesc"],
			hidden = function() return not (#eePanels2.db.profile.panels > 0) end,
			order = 25,
			args = {}
		},

		space1 = 
		{
			name = " ",
			type = 'header',
			order = 30,
		},
		 
		reset = 
		{
			type = 'execute',
			confirm = true,
			name = L["Reset"],
			desc = L["ResetDesc"],
			func = function(val) eePanels2:Reset() end,
			order = 1000,
		},
	  
	}
}


--[[
-- Initialize addon settings
--]]
function eePanels2:OnInitialize()
	-- Setup default database values
	self:RegisterDefaults('profile', {
		panels = {},
		global = DeepCopy(dp),
		filter = {},
		advancedMode = false,
		showWarnings = true,
		parentRecheckTime = 2,
		dynamicFrameHack = false, -- attempt to compensate for dynamically created frames used as parents/anchors
	})
	
	-- Listen for addons being enabled so we can setup panels with anchors/parents which use their frames
	self:RegisterEvent("ADDON_LOADED","ScheduleParentCheck");
	
	-- listen for command-line requests
	self:RegisterChatCommand( {L["/eePanels2"]}, eePanels2.OnMenuRequest )
	
	self:CreateWaterfallMenu()
	
	-- Add option to set background texture to none
	media:Register("background", L["None"], "Interface\\None")
	
	-- Modify 'Disable' text if FuBar isn't installed so it instead says 'Hide Icon'
	if not FuBar then
		self.OnMenuRequest.args.hide.guiName = L["HideIcon"]
		self.OnMenuRequest.args.hide.desc = L["HideIcon"]
	end
end


--[[
-- This function schedules a call to UpdateBadParent() - hopefully only once - after all addons have been loaded
-- This is a workaround to allow panels to use frames generated by other addons as parents/achors
-- Since it may take a few seconds after an addon has been loaded to generate all its frames, we schedule
-- the function call to occur a few seconds later, and hope that's enough time for all its frames to be created
--]]
function eePanels2:ScheduleParentCheck(addonName)
	-- We want to minimize the number of UpdateBadParents() calls we make (hopefully only after the last addon is loaded), so
	-- cancel any previously scheduled event, and re-schedule a new one in its palce
	self:CancelScheduledEvent("eeParentCheck")
	-- An addon might take a few seconds to build it's frames, so we'll wait until it's finishedS
	self:ScheduleEvent("eeParentCheck", eePanels2.UpdateBadParents, eePanels2.db.profile.parentRecheckTime)
end


--[[
-- This function will check all panel's with non-existant parent/anchor frames and see if those frames now exist
-- If the parent/anchor does now exist, we will reconfigure the panel accordingly
--]]
function eePanels2:UpdateBadParents()
	-- Loop through our list of eePanels with non-existant parents/anchors
	for k,_ in pairs(badParents) do
		local panel = eePanels2.db.profile.panels[k]
		
		local parentExists = frameExists[panel.parent]
		local anchorExists = frameExists[panel.anchor]
		
		-- We found that the parent exists now
		if parentExists and anchorExists then
			-- Remove the panel from the dirty list
			badParents[k] = false
			-- Update the panel's parent, anchor, position and re-enforce its level
			panel.frame:SetParent(panel.parent)
			eePanels2:ChangeWidth(panel)
			eePanels2:ChangeHeight(panel)
			eePanels2:ChangePosition(panel)
			eePanels2:ChangeLevel(panel)
			-- Change panel guideFrame color (if it exists)
			if panel.guideFrame ~= nil then
				panel.guideFrame.texture:SetTexture(eePanels2:GetHightlightColor(panel))
			end
			-- Might have inherited old parents visibility; if new parent is visible, set to visible
			if panel.frame:GetParent():IsVisible() then panel.frame:Show() end
		end
		
	end
end


--[[
-- In order to help us work with dynamically created frames, we'll hook into the CreateFrame() function, and call our UpdateBadParents() function 
-- Whenever a new frame is created.  This is a toggleable function since it may lead to a performance hit if there's a lot of frame churn going on
-- and because hooking a secure function might cause a bit of overhead on its own
-- NOTE: this could potentially cuase BadParentsUpdate to be called twice (once from our code, once from the hook) every time a panel is created
-- by us if it has a bad parent/anchor.  Might want to look into this later to minimize the problem
--]]
function eePanels2:DynamicFrameHack(overrideSavedVar)
	if overrideSavedVar or not eePanels2.db.profile.dynamicFrameHack then
		-- check if func is hooked; unhook it if it is
		if self:IsHooked("CreateFrame") then
			self:Unhook("CreateFrame")
		end
	elseif eePanels2.db.profile.dynamicFrameHack then
		-- hook func if not yet hooked
		if not self:IsHooked("CreateFrame") then
			self:SecureHook("CreateFrame", eePanels2.UpdateBadParents)
		end
	end
end


--[[
-- Create all panels when enabled
--]]
function eePanels2:OnEnable()
	self:InitPanels()
	eePanels2:DynamicFrameHack(false)
end


--[[
-- Create all panels and panel menus (and global panel options)
--]]
function eePanels2:InitPanels()
	-- Create global option menu
	eePanels2.OnMenuRequest.args.globalSettings.args = self:CreatePanelMenu(0)
	-- Create all panels
	for i in pairs(eePanels2.db.profile.panels) do
		-- PROBABLY WOULD MAKE MORE SENSE TO DO ALL THIS PARENT CHECK STUFF IN CreatePanel()
		local panel = eePanels2.db.profile.panels[i]
		-- Check if the parent/anchor frames exists
		local parentFound = frameExists[panel.parent] and frameExists[panel.anchor]
		
		-- If the parent frame wasn't created, mark its index in an array of bad parents for later
		if not parentFound then
			badParents[i] = true;
		end
		
		-- Next line fixes a problem which started in patch 2.0.3
		-- No guideFrame should exist at this point, but the ID of the guideFrame is still being stored in our saved vars.  Set it back to nil
		panel.guideFrame = nil
		-- Create the panel
		self:CreatePanel(i,nil,false)
		
		-- If we're in unlocked mode, create the guideFrame for this panel
		if not eePanels2.db.profile.panels[i].locked then
			self:CreateGuideFrame(panel,i) 
		end
	end

	self:CreateMenus()
end


--[[
-- Hide all frames when eePanels2 is disabled
--]]
function eePanels2:OnDisable()
	local panels = eePanels2.db.profile.panels
	for i in pairs(panels) do
		panels[i].frame:Hide()
	end
	eePanels2:DynamicFrameHack(true)
end


--[[
-- Hide all existing panels and clear the dewdrop menu when we disable a specific profile
-- Pave the way for a new profile's settings to take effect
--]]
function eePanels2:OnProfileDisable()
    -- Hide all existing panels
	local panels = eePanels2.db.profile.panels
	for i in pairs(panels) do
		if panels[i].frame then 
			panels[i].frame:Hide() 
		end
	end

	-- Empty panel menu table
	eePanels2.OnMenuRequest.args.panels.args = {}
	-- Empty global menu table
	eePanels2.OnMenuRequest.args.globalSettings.args = {}
	
	copyItem = {}
	badParents = {}

	-- Force dewdrop to update so the menu empties itself if it's still open
	if dewdrop then dewdrop:Refresh(1) end
	-- This should only be temporary, until a new profile is set, but why not
	eePanels2:DynamicFrameHack(true)
end


--[[
-- Create our panels and menus for a new profile
-- NOTE: this will not clear scripts loaded by a previous profile's panels from memory.  
--]]
function eePanels2:OnProfileEnable()
    self:InitPanels()
	eePanels2:DynamicFrameHack(false) -- I think Ace2 auto unhooks everything by a mod when disabled, but we'll do it anyway
	self:ShowWarning("You may want to /reload after changing your profile to flush any old scripts, etc")
end


--[[
-- Simple warning output which the user can turn on and off
--]]
function eePanels2:ShowWarning(msg)
	if self.db.profile.showWarnings then
		self:Print(msg)
	end
end







--[[
-- Removes a created panel and it's menu (
-- Actually, we regenerate the menus for all panels.  This could be improved upon, but it's a fair bit of work for an event which occurs infrequently
--]]
function eePanels2:RemovePanel(index)
	local panels = eePanels2.db.profile.panels
	local filter = eePanels2.db.profile.filter
	
	-- Hide the panel and remove it from out database
	--eePanels2.OnMenuRequest.args.panels.args["eePanel"..index] = {}  -- unnecessary since we're recreating all menus below
	panels[index].frame:Hide()
	panels[index] = {}
	table.remove(panels,index)
	
	-- We need to shift some values to compensate for the removed panel
	for i=index, #panels do
		-- Remove panel from filter list. 
		filter[i] = filter[i+1]
		-- Update the panel's guideFrame text and index
		if panels[i].guideFrame then 
			panels[i].guideFrame.text:SetText( L["eePanel"]..i..": "..panels[i].name ) 
			panels[i].guideFrame.index = i
		end
	end
	table.remove(filter, #panels)

	-- If this panel was marked as having a pad parent, remove it; shouldn't matter as the parent check shouldn't occur
	-- more than once, but it's possible the person could remove a panel before the check occurs
	if badParents[index] then table.remove(badParents, index) end
	
	-- Recreate panel menu
	self:CreateMenus()
	
	self:ShowWarning("You may want to perform a /reload after removing a panel to flush any attached scripts, etc")
end


--[[
-- Create a panel and insert a new panel menu for it
--]]
function eePanels2:CreatePanel(index,fromGlobal,createMenu)
	local panels = self.db.profile.panels

	-- Create a new panel and insert it into the database
	if not index or index == 0 then
		if fromGlobal then
			table.insert(panels, DeepCopy(self.db.profile.global))
		else
			table.insert(panels, DeepCopy(dp))
		end
		-- Set index to our newly created panel
		index = #panels
		
		-- Add to filter let
		self.db.profile.filter[index] = false
	end
	
	local panel = panels[index]
	
	-- Create the panel visually
	self:CreateFrame(panel,index)
	self:CreateTexture(panel)
	self:ChangeStrata(panel)
	self:ChangeWidth(panel)
	self:ChangeHeight(panel)
	self:ChangeBackdrop(panel)
	self:ChangeBorderColor(panel)
	self:ChangeBackgroundColor(panel)
	self:ChangeTextureBlend(panel)
	self:ChangeLevel(panel)
	self:InterceptMouse(panel)
	self:ChangeScript(panel)
	-- HACK: If anchor frame exists, we'll set its anchor point; otherwise we let UpdateBadParents change it if/when the anchor is found
	if frameExists[panel.anchor] then self:ChangePosition(panel) end
	
	-- If we're not in locked mode, create the guideFrame for this panel
	if not panels[index].locked then 
		self:CreateGuideFrame(panels[index],index) 
	end

	-- This stops multiple menu creation calls when we're loading all our panels OnEnable() 
	if createMenu == nil or createMenu then self:CreateMenus() end
end


--[[
-- Resets the AceDB to it's default (no panels)
--]]
function eePanels2:Reset()
	local panels = eePanels2.db.profile.panels
	
	-- Hide all existing panels
	for i in pairs(panels) do
		if panels[i].frame then 
			panels[i].frame:Hide() 
		end
		panels[i] = {}
	end

	-- Empty filter list
	eePanels2.db.profile.filter = {}
	-- Empty panel table
	panels = {}
	-- Empty panel menu table
	eePanels2.OnMenuRequest.args.panels.args = {}
	-- Reset the default panel options
	eePanels2.db.profile.global = DeepCopy(dp)
	-- Empty copy value
	copyItem = {}
	badParents = {}

	-- Force dewdrop to update so the menu empties itself while it's still open
	if dewdrop then dewdrop:Refresh(1) end
end







--[[
-- Creates and inserts the global option menu and all panel option menus
-- Basically regenerates the entire thing.  This could be improved upon, but it'd take a bit of work and I'm a lazy bastard.
--]]
function eePanels2:CreateMenus()
	-- Empty the current option table for panels
	eePanels2.OnMenuRequest.args.panels.args = {}

	-- We need to update the global, incase advanced mode has changed
	eePanels2.OnMenuRequest.args.globalSettings.args = eePanels2:CreatePanelMenu(0)
		
	-- Regenerate each panel's option menu
	for i in pairs(eePanels2.db.profile.panels) do
		eePanels2.OnMenuRequest.args.panels.args["eePanel"..i] = eePanels2:CreatePanelMenu(i)
	end
end


--[[
-- Creates and returns either a global option menu or a panel option menu based on our panel data
--]]
function eePanels2:CreatePanelMenu(index)
	local panelData

	-- This is the global panel menu
	if index == 0 then
		panelData = self.db.profile.global
	-- This is a normal panel menu
	else
		panelData = self.db.profile.panels[index]
	end

	local option =
	{
		lock = 
		{
			type = 'toggle',
			name = L["Lock"],
			desc = L["LockDesc"],
			get = function() return panelData.locked end,
			set = function(val) eePanels2:ToggleLock(index, val) end,
			order = 1,
		},
		
		spacer = 
		{
			name = " ",
			type = 'header',
			order = 5,
		},
			
		panelName = 
		{
			type='text', 
			usage=L["PanelNameUsage"],
			name = L["PanelName"], 
			desc = L["PanelNameDesc"], 
			get = function() return panelData.name end,
			set = function(val)
				if index ~= 0 then
					panelData.name = val
					self:ChangeName(panelData,index)
				end
			end,
			hidden = function() if index == 0 then return true else return false end end,
			order = 10,
			canCopy = true,
			copyType = "text",
		},

		backgroundColorStyle = 
		{
			type='text',
			name = L["BGColorStyle"], 
			desc = L["BGColorStyleDesc"], 
			get = function() return panelData.background.style end,
			set = function(val) 
				panelData.background.style = val
				if index == 0 then		
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.style = val
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i]) 
							eePanels2:ChangeBackgroundColor(eePanels2.db.profile.panels[i]) 
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData) 
					eePanels2:ChangeBackgroundColor(panelData) 
					eePanels2:ChangeBorderColor(panelData) 
				end
			end,
			validate = bgColorStyleOpt,
			order = 15,
			canCopy = true,
			copyType = "colorStyle",
		},
				
		backgroundColor = 
		{
			type='color',
			usage='',
			name = L["BGColor"], 
			desc = L["BGColorDesc"], 
			get = function() local bgc = panelData.background.color return bgc.r, bgc.g, bgc.b, bgc.a end,
			set = function(ir,ig,ib,ia)
				panelData.background.color = {r=ir,g=ig,b=ib,a=ia} 
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.color = {r=ir,g=ig,b=ib,a=ia} 
							eePanels2:ChangeBackgroundColor(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangeBackgroundColor(panelData) 
				end
			end,
			hasAlpha = true,
			order = 20,
			canCopy = true,
			copyType = "color",
		},
		
		backgroundGradientColor = 
		{
			type='color',
			name = L["BGGradientColor"], 
			desc = L["BGGradientColorDesc"], 
			get = function() local bgc = panelData.background.gradient.color return bgc.r, bgc.g, bgc.b, bgc.a end, 
			set = function(ir,ig,ib,ia) 
				panelData.background.gradient.color = {r=ir,g=ig,b=ib,a=ia} 
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.gradient.color = {r=ir,g=ig,b=ib,a=ia} 
							eePanels2:ChangeBackgroundColor(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeBackgroundColor(panelData) 
				end
			end,
			hasAlpha = true,
			order = 25,
			disabled = function() if panelData.background.style == bgColorStyleOpt["Gradient"] then return false else return true end end,
			canCopy = true,
			copyType = "color",
		},
		
		backgroundGradientOrientation = 
		{
			type='text',
			usage='',
			name = L["BGOrientation"], 
			desc = L["BGOrientationDesc"], 
			get = function() return panelData.background.gradient.orientation end,
			set = function(val) 
				panelData.background.gradient.orientation = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.gradient.orientation = val
							eePanels2:ChangeBackgroundColor(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangeBackgroundColor(panelData) 
				end
			end,
			validate = bgGradOrientationOpt,
			order = 30,
			disabled = function() if panelData.background.style == bgColorStyleOpt["Gradient"] then return false else return true end end,
			canCopy = true,
			copyType = "gradientOrientation",
		},
		
		backgroundBlend = 
		{
			type='text',
			usage='',
			name = L["BGBlend"], 
			desc = L["BGBlendDesc"], 
			get = function() return panelData.background.blend end,
			set = function(val)
				panelData.background.blend = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.blend = val
							eePanels2:ChangeTextureBlend(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeTextureBlend(panelData)
				end
			end,
			validate = blendModeOpt,
			order = 35,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "blend",
		},
		
		backgroundTexture = 
		{
			type="group",
			name = L["BGTexture"], 
			desc = L["BGTextureDesc"], 
			usage=L["BGTextureUsage"],
			args = 
			{
				Standard = 
				{
					type = "text", 
					name = L["BGTexture"].." "..L["TextureShared"], 
					desc = L["TextureSharedDesc"],
					usage = L["BGTextureUsage"],
					get = function() return panelData.background.texture.media end,
					set = function(val) 
						local tex = media:Fetch('background', val)
						panelData.background.texture.media = val
						panelData.background.texture.texture = tex
						if index == 0 then
							for i in pairs(eePanels2.db.profile.panels) do
								if not eePanels2.db.profile.filter[i] then
									eePanels2.db.profile.panels[i].background.texture.media = val
									eePanels2.db.profile.panels[i].background.texture.texture = tex
									eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i]) 
									eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
								end
							end
						else
							eePanels2:ChangeBackdrop(panelData) 
							eePanels2:ChangeBorderColor(panelData) 
						end
					end,
					validate = media:List('background'),
					order = 41,														
				},
				
				Custom = 
				{
					type = "text", 
					name = L["BGTexture"].." "..L["TextureCustom"], 
					desc = L["TextureCustomDesc"],
					usage = L["BGTextureUsage"],
					get = function() return panelData.background.texture.texture end,
					set = function(val) 
						panelData.background.texture.texture = val
						if index == 0 then
							for i in pairs(eePanels2.db.profile.panels) do
								if not eePanels2.db.profile.filter[i] then
									eePanels2.db.profile.panels[i].background.texture.texture = val
									eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i]) 
									eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
								end
							end
						else
							eePanels2:ChangeBackdrop(panelData) 
							eePanels2:ChangeBorderColor(panelData) 
						end
					end,
					order = 42,
					disabled = not eePanels2.db.profile.advancedMode,
					hidden = not eePanels2.db.profile.advancedMode,
					canCopy = true,
					copyType = "textureLocation",
				},					
			},
			order = 40,
		},

		backgroundTextureOpacity = 
		{
			type='range',
			name = L["BGTextureOpacity"], 
			desc = L["BGTextureOpacityDesc"], 
			get = function() return panelData.background.texture.alpha end,
			set = function(val)
				panelData.background.texture.alpha = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.texture.alpha = val
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData)
				end
			end,
			order = 44,
			min = 0, 
			max = 1, 
			step = .01,
			isPercent = true, 
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "alpha",
		},
		
		backgroundTextureTiling = 
		{
			type='toggle',
			name = L["BGTextureTiling"], 
			desc = L["BGTextureTilingDesc"], 
			get = function() return panelData.background.tiling end,
			set = function(val)
				panelData.background.tiling = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.tiling = val
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i])
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData)
					eePanels2:ChangeBorderColor(panelData)
				end
			end,
			order = 45,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "tiling",
		},
		
		backgroundTileSize = 
		{
			type='text', 
			usage = '',
			name = L["BGTileSize"], 
			desc = L["BGTileSizeDessc"], 
			get = function() return panelData.background.tileSize end,
			set = function(val)
				panelData.background.tileSize = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.tileSize = val
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i])
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData)
					eePanels2:ChangeBorderColor(panelData) 
				end
			end,
			validate = function(u) if string.match(u, "%d+") then return true else return false end end,
			order = 50,
			disabled = function() return not panelData.background.tiling end,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "tileSize",
		},
		
		backgroundInset = 
		{
			type='range',
			name = L["BGInset"]	, 
			desc = L["BGInsetDesc"], 
			get = function() return panelData.background.insetSizeAll end,
			set = function(val)
				panelData.background.insetSizeAll = val
				panelData.background.insetSize = {t=val,b=val,l=val,r=val}				
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].background.insetSizeAll = val
							eePanels2.db.profile.panels[i].background.insetSize = {t=val,b=val,l=val,r=val}
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i])
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i])
							eePanels2.db.profile.panels[i].background.frame:SetPoint("TOPLEFT", eePanels2.db.profile.panels[i].frame, "TOPLEFT",val,-val)
							eePanels2.db.profile.panels[i].background.frame:SetPoint("BOTTOMRIGHT", eePanels2.db.profile.panels[i].frame, "BOTTOMRIGHT",-val,val)
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData)
					eePanels2:ChangeBorderColor(panelData) 
					panelData.background.frame:SetPoint("TOPLEFT", panelData.frame, "TOPLEFT",val,-val)
					panelData.background.frame:SetPoint("BOTTOMRIGHT", panelData.frame, "BOTTOMRIGHT",-val,val)
				end
			end,
			
			min = 0, 
			max = 100, 
			step = 1, 
			isPercent = false,
			order = 55,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "insets",
		},	
		
		borderColor = 
		{
			type='color',
			name = L["BorderColor"], 
			desc = L["BorderColorDesc"], 
			get = function() local brc = panelData.border.color return brc.r, brc.g, brc.b, brc.a end,
			set = function(ir,ig,ib,ia)
				panelData.border.color = {r=ir,g=ig,b=ib,a=ia} 
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].border.color = {r=ir,g=ig,b=ib,a=ia} 
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangeBorderColor(panelData) 
				end
			end,
			hasAlpha = true,
			order = 60,
			canCopy = true,
			copyType = "color",
		},
		
		borderTexture = 
		{
			type = "group",
			name = L["BorderTexture"], 
			desc = L["BorderTextureDesc"], 
			args = 
			{
				Standard = 
				{
					type = "text", 
					name = L["BorderTexture"].." "..L["TextureShared"], 
					desc = L["TextureSharedDesc"],
					usage = L["BorderTextureUsage"],
					get = function() return panelData.border.media end,
					set = function(val) 
						local tex = media:Fetch('border', val)
						panelData.border.media = val
						panelData.border.texture = tex
						if index == 0 then
							for i in pairs(eePanels2.db.profile.panels) do
								if not eePanels2.db.profile.filter[i] then
									eePanels2.db.profile.panels[i].border.media = val
									eePanels2.db.profile.panels[i].border.texture = tex
									eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i]) 
									eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
								end
							end
						else
							eePanels2:ChangeBackdrop(panelData) 
							eePanels2:ChangeBorderColor(panelData) 
						end
					end,
					validate = media:List('border'),
					order = 66,														
				},
				
				Custom = 
				{
					type = "text", 
					name = L["BorderTexture"].." "..L["TextureCustom"], 
					desc = L["TextureCustomDesc"],
					usage = L["BorderTextureUsage"],
					get = function() return panelData.border.texture end,
					set = function(val) 
						panelData.border.texture = val
						if index == 0 then
							for i in pairs(eePanels2.db.profile.panels) do
								if not eePanels2.db.profile.filter[i] then
									eePanels2.db.profile.panels[i].border.texture = val
									eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i]) 
									eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i]) 
								end
							end
						else
							eePanels2:ChangeBackdrop(panelData) 
							eePanels2:ChangeBorderColor(panelData) 
						end
					end,
					order = 67,
					disabled = not eePanels2.db.profile.advancedMode,
					hidden = not eePanels2.db.profile.advancedMode,
					canCopy = true,
					copyType = "textureLocation",
				},					
			},
			order = 65,
		},
			
		borderEdgeSize = 
		{
			type='range',
			name = L["BorderEdgeSize"], 
			desc = L["BorderEdgeSizeDesc"], 
			get = function() return panelData.border.edgeSize end,
			set = function(val) 
				panelData.border.edgeSize = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].border.edgeSize = val
							eePanels2:ChangeBackdrop(eePanels2.db.profile.panels[i])
							eePanels2:ChangeBorderColor(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeBackdrop(panelData)
					eePanels2:ChangeBorderColor(panelData)
				end
			end,
			min = 1, 
			max = 100, 
			step = 1, 
			isPercent = false,
			order = 70,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "edgeSize",
		},	
			
		level = 
		{
			type='range',
			name = L["PanelLevel"], 
			desc = L["PanelLevelDesc"], 
			get = function() return panelData.level end,
			set = function(val)
				panelData.level = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].level = val
							eePanels2:ChangeLevel(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeLevel(panelData)
				end
			end,
			min = 0, 
			max = 20, 
			step = 1, 
			isPercent = false,
			order = 75,
			canCopy = true,
			copyType = "level",
		},
		
		strata = 
		{
			type='text',
			name = L["PanelStrata"], 
			desc = L["PanelStrataDesc"], 
			get = function() return panelData.strata end,
			set = function(val)
				panelData.strata = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].strata = val
							eePanels2:ChangeStrata(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangeStrata(panelData) 
				end
			end,
			validate = frameStrataOpt,
			order = 80,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,	
			canCopy = true,
			copyType = "strata",
		},
		
		width = 
		{
			type='text', 
			usage=' ',
			name = L["PanelWidth"], 
			desc = L["PanelWidthDesc"], 
			get = function() return panelData.width end,
			set = function(val) 
				panelData.width = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].width = val 
							eePanels2:ChangeWidth(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeWidth(panelData)
				end
			end,
			validate = function(u) if string.match(u, "%d+%.?%d*%%?") then return true else return false end end,
			order = 85,
			canCopy = true,
			copyType = "dimension",
		},

		height = 
		{
			type='text', 
			usage=' ',
			name = L["PanelHeight"], 
			desc = L["PanelHeightDesc"], 
			get = function() return panelData.height end,
			set = function(val) 
				panelData.height = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].height = val 
							eePanels2:ChangeHeight(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeHeight(panelData)
				end
			end,
			validate = function(u) if string.match(u, "%d+%.?%d*%%?") then return true else return false end end,
			order = 90,
			canCopy = true,
			copyType = "dimension",
		},
		
		--scale = {}, -- placeholder
		
		x = 
		{
			type='text', 
			usage=' ',
			name = L["PanelX"], 
			desc = L["PanelXDesc"],
			get = function() return math.floor(panelData.x) end,
			set = function(val) 
				panelData.x = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].x = val 
							eePanels2:ChangePosition(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangePosition(panelData) 
				end
			end,
			validate = function(u) if string.match(u, "%d+") then return true else return false end end,
			order = 95,
			canCopy = true,
			copyType = "position",
		},

		y = 
		{
			type='text', 
			usage=' ',
			name = L["PanelY"], 
			desc = L["PanelYDesc"], 
			get = function() return math.floor(panelData.y) end,
			set = function(val) 
				panelData.y = val 
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].y = val 
							eePanels2:ChangePosition(eePanels2.db.profile.panels[i]) 
						end
					end
				else
					eePanels2:ChangePosition(panelData) 
				end
			end,
			validate = function(u) if string.match(u, "%d+") then return true else return false end end,
			order = 100,
			canCopy = true,
			copyType = "position",
		},
		
		parent =
		{
			type='text', 
			usage=' ',
			name = L["PanelParent"], 
			desc = L["PanelParentDesc"], 
			get = function() return panelData.parent end,
			set = function(val) 
				panelData.parent = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].parent = val
							eePanels2:ChangeParent(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeParent(panelData)
				end
			end,
			validate = function(val) if val ~= panelData.parent then return true else return false end end, 
			order = 105,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "frame",
		},
		
		anchor = 
		{
			type='text', 
			usage=' ',
			name = L["PanelAnchor"], 
			desc = L["PanelAnchorDesc"], 
			get = function() return panelData.anchor end,
			set = function(val) 
				panelData.anchor = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].anchor = val
							eePanels2:ChangeAnchor(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangeAnchor(panelData)
				end
			end,
			validate = function(u) if u ~= panelData.anchor then return true else return false end end, 
			order = 110,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "frame",
		},
		
		anchorTo = 
		{
			type='text', 
			usage=' ',
			name = L["PanelAnchorTo"], 
			desc = L["PanelAnchorToDesc"], 
			get = function() return panelData.anchorTo end,
			set = function(val) 
				panelData.anchorTo = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].anchorTo = val
							eePanels2:ChangePosition(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangePosition(panelData)
				end
			end,
			validate = offsetPositionOpt,
			order = 115,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "anchorPoint",
		},
		
		anchorFrom = 
		{
			type='text', 
			usage=' ',
			name = L["PanelAnchorFrom"], 
			desc = L["PanelAnchorFromDesc"], 
			get = function() return panelData.anchorFrom end,
			set = function(val) 
				panelData.anchorFrom = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].anchorFrom = val
							eePanels2:ChangePosition(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:ChangePosition(panelData)
				end
			end,
			validate = offsetPositionOpt,
			order = 120,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
			canCopy = true,
			copyType = "anchorPoint",
		},
		
		interceptMouse = 
		{
			type='toggle',
			name = L["InterceptMouse"], 
			desc = L["InterceptMouseDesc"],  
			get = function() return panelData.mouse end,
			set = function(val) 
				panelData.mouse = val
				if index == 0 then
					for i in pairs(eePanels2.db.profile.panels) do
						if not eePanels2.db.profile.filter[i] then
							eePanels2.db.profile.panels[i].mouse = val
							eePanels2:InterceptMouse(eePanels2.db.profile.panels[i])
						end
					end
				else
					eePanels2:InterceptMouse(panelData)
				end
			end,
			order = 125,
			disabled = not eePanels2.db.profile.advancedMode,
			hidden = not eePanels2.db.profile.advancedMode,
		},
	
		scripts = 
		{
			type='group', 
			name = L["Scripts"], 
			desc = L["ScriptsDesc"],
			order = 130,
			hidden = function() if index == 0 or not eePanels2.db.profile.advancedMode then return true else return false end end,
			args = 
			{
				spacer1 = 
				{
					name = " ",
					type = 'header',
					order = 395,
					hidden = function() if #panelData.scripts > 0 then return false else return true end end,
				},
		
				add = 
				{
					type = 'execute',
					name = L["ScriptsAdd"], 
					desc = L["ScriptsAddDesc"], 
					func = function() eePanels2:DisplayScriptEditor(panelData,nil)	end,
					order = 500,
				},
			}
		},
		
		spacer1 = 
		{
			name = " ",
			type = 'header',
			order = 385,
		},
		
		filter = 
		{
			type = 'group',
			name = L["Filter"], 
			desc = L["FilterDesc"],
			order = 386,
			hidden = function() if index == 0 then return false else return true end end,
			args = 
			{
				spacer1 = 
				{
					name = " ",
					type = 'header',
					order = 385,
				},
				
				unfilterAll = 
				{
					type = 'execute',
					name = L["Unfilter"], 
					desc = L["UnfilterDesc"],
					func = function() 
						for i in pairs(eePanels2.db.profile.filter) do
							eePanels2.db.profile.filter[i] = false
						end
					end,
					order = 500,
				},
			}
		},
		
		copy = 
		{
			type = 'group',
			name = L["Copy"], 
			desc = L["CopyDesc"],
			hidden = function() if index == 0 then return true else return false end end,
			order = 390,
			args = {},
		},
		
		paste = 
		{
			type = 'group',
			name = L["Paste"], 
			desc = L["PasteDesc"],
			hidden = function() if index == 0 then return true else return false end end,
			disabled = function() if #copyItem > 0 then return false else return true end end,
			order = 395,
			args = {},
		},
			
		remove = 
		{
			type = 'execute',
			name = L["PanelRemove"], 
			desc = L["PanelRemoveDesc"], 
			func = function() 
				-- If we opened the dewdrop menu by right-clicking on the guideFrame, then close the dewdrop menu
				if dewdrop and panelData.guideFrame ~= nil then
					if dewdrop:GetOpenedParent() == panelData.guideFrame then
						dewdrop:Close()
					end
				end
				eePanels2:RemovePanel(index) 
			end,
			hidden = function() if index == 0 then return true else return false end end,
			order = 400,
		},
	}
	
	-- We're creating a normal panel menu
	if index ~= 0 then	
		-- Add panel to global's filter menu
		eePanels2.OnMenuRequest.args.globalSettings.args.filter.args[index] = {
			type = 'toggle',
			name = index .. ". "..eePanels2.db.profile.panels[index].name,
			desc = L["FilterPanel"]..index,
			get = function() return eePanels2.db.profile.filter[index] end,
			set = function(val) eePanels2.db.profile.filter[index] = val end,
			order = index,
		}
		
		-- Create menu options for all scripts
		for i in pairs(panelData.scripts) do
			option.scripts.args[i] = 
			{
				type='group', 
				name = i..". "..panelData.scripts[i].name, 
				desc = i..". "..panelData.scripts[i].name,  
				order = i,
				hidden = function() if index == 0 then return true else return false end end,
				args = 
				{
					edit = 
					{
						type = 'execute',
						name = L["ScriptsEdit"], 
						desc = L["ScriptsEditDesc"],
						func = function() eePanels2:DisplayScriptEditor(panelData,i) end,
						order = 500,
					},
					
					remove = 
					{
						type = 'execute',
						name = L["ScriptsRemove"], 
						desc = L["ScriptsRemoveDesc"],
						func = function() 
							table.remove(panelData.scripts,i)
							eePanels2:ShowWarning("The script won't be removed from memory until you relog or perform a /reload")
							eePanels2:ChangeScript(panelData)
							eePanels2:CreateMenus()
							end,
						order = 500,
					},
				}
			}
		end
		
		-- Generate the copy menu
		self:CreateCopyMenu(option, option.copy.args)
		
		-- Generate the paste menu
		self:CreatePasteMenu(option, option.paste.args)
		
		-- wrap it in an ace options group table
		return
		{
			type = 'group',
			name = index..'. '..panelData.name, 
			desc = index..'. '..panelData.name, 
			order = index,
			args = option
		}
	-- We're creating a global menu, just return the table
	else
		return option
	end
end


--[[
-- Create the copy option menu.  Scans through our ace option menu, looking for
-- any tables with canCopy == true
--]]
function eePanels2:CreateCopyMenu(t,optionMenu)
	if t ~= nil and type(t) == "table" then
		-- If this table has a copy variable, create a menu option and add it to the copy group
		if t.canCopy and not t.hidden then
			table.insert(optionMenu, {
				type = 'execute',
				name = t.name, 
				desc = L["Copy"].." "..t.name, 
				func = function() self:CopyValue(t.get, t.copyType) end,
				order = t.order,
			})
		-- Otherwise, recursively call this function with any child tables contained in the table
		else
			for i in pairs(t) do
				if t[i] and type(t[i]) == "table" then 
					self:CreateCopyMenu(t[i], optionMenu)
				end
			end
		end
	end
end


--[[
-- Create the paste option menu.  Scans through our ace option menu, looking for
-- any tables with canCopy == true, where copyType matches our copied info type
--]]
function eePanels2:CreatePasteMenu(t, optionMenu)
	if t ~= nil and type(t) == "table" and copyItem[2] ~= nil then
		-- If this table has a copy variable that has the same type as our copied data, create a menu option for it
		if t.canCopy and not t.hidden and t.copyType == copyItem[2] then
			table.insert(optionMenu, {
				type = 'execute',
				name = t.name, 
				desc = L["Paste"].." "..t.name, 
				func = function() self:PasteValue(t.set) end,
				order = t.order,
			})
		-- Otherwise, recursively call this function with any child tables contained in the table
		else
			for i in pairs(t) do
				if t[i] and type(t[i]) == "table" then 
					self:CreatePasteMenu(t[i], optionMenu)
				end
			end
		end
	end
end


--[[
-- Copy the value of an option from a panel
-- We store the data as well as the 'type' of value that's being stored.  This cType value is manually set for each option in our above table
-- by hand, so that we can't accidentaly paste a value into a field that doesn't make any sense (ie: copy a background color and paste it as width)
--]]
function eePanels2:CopyValue(panelGetFunc, cType)
	-- Function might return multiple values, so pack it in a table
	local results = {panelGetFunc()}
	-- Store the copy info; copyItem[1] = data, copyItem[2] = data type
	copyItem = { results, cType }
	-- Recreate menus.  It would be less processor intensive if we actually had it insert the new stuff into the paste 
	-- section of the existing options, but this is quick and dirty.
	eePanels2:CreateMenus()
end


--[[
-- Pastes a copied value into a panel's option menu
-- We actually pass the copied data into the panel option menu table function which saves us a lot of work from having to create any extra code
-- (panelSetFunc is the function name of a panel to paste to, which is what the user actually selects when from the gui)
--]]
function eePanels2:PasteValue(panelSetFunc)
	-- call the table's set function
	if copyItem ~= nil and copyItem[1] ~= nil then
		-- We have the values in a table, so unpack them
		panelSetFunc(unpack(copyItem[1]))
	end
end


--[[
-- Attempts to setup waterfall configuration menu for people who prefer it over the dewdrop menu style
--]]
function eePanels2:CreateWaterfallMenu()
	if waterfall then
		-- Register our menu with waterfall
		waterfall:Register(
			"eePanels", "aceOptions", eePanels2.OnMenuRequest,
			"treeType","TREE",
			"colorR", 0.2, "colorG", 0.2, "colorB", 0.2
		)
					   
		-- Put into option menu so that it's accessible through /slash commands
		eePanels2.OnMenuRequest.args.waterfall = 
		{
			type = "execute",
			name = L["Waterfall"],
			desc = L["WaterfallDesc"],
			order = 2,
			func = function() waterfall:Open("eePanels") if dewdrop then dewdrop:Close() end end,
			disabled = function() return waterfall:IsOpen("eePanels") end,
			guiHidden = true,
		}
	end
end


--[[
-- Show the dewdrop menu for this panel at the current cursor position
-- This is for people who want to open a dewdrop menu for an individual panel, instead of from the Fubar/Minimap icon
--]]
function eePanels2:ShowPanelMenu(guideFrame, index)
	if not eePanels2.OnMenuRequest.args.panels.args["eePanel"..index] then return end
	
	if dewdrop then
		dewdrop:Open(
			guideFrame, 
			'children', 
			function() dewdrop:FeedAceOptionsTable(eePanels2.OnMenuRequest.args.panels.args["eePanel"..index]) end, 
			'cursorX', 
			true, 
			'cursorY', 
			true)
	end
end


--[[
-- Handle mouse clicks which occur on the eePanel minimap/fubar icon
--]]
function eePanels2:OnClick()
	-- By default right-clicks will cause dewdrop menu's to open
	
	-- Shift-click cause waterfall menu to open
	if eePanels2.OnMenuRequest.args.waterfall and IsShiftKeyDown() then
		GameTooltip:Hide()
		eePanels2.OnMenuRequest.args.waterfall.func()
		return
	end
	
	-- Left-click toggles global panel locking
	self:ToggleLock()
	
	-- Update tooltip to reflect change in locking
	self:UpdateTooltip()
end


--[[
-- Setup eePanel fubar/minimap icon tooltips
--]]
function eePanels2:OnTooltipUpdate()
	-- Display global lock status, and mouse-click to change
	GameTooltip:AddLine(L["eePanels2"])
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Lock"]..": ", eePanels2.db.profile.global.locked and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r")
	GameTooltip:AddLine(" ")
	-- Display mouse-click to open waterfall 
	GameTooltip:AddLine("|cffeda55fLeft-Click|r to toggle lock.", 0.2, 1, 0.2)
	if eePanels2.OnMenuRequest.args.waterfall then
		GameTooltip:AddLine("|cffeda55fShift-Click|r to open waterfall configuration.", 0.2, 1, 0.2)
	end
	-- Display mouse-click to open dewdrop
	GameTooltip:AddLine("|cffeda55fRight-Click|r to open configuration menu.", 0.2, 1, 0.2)
end










--[[
-- Toggle panel locking for a specific/all panaels (ie: manually position/resize panels)
--]]
function eePanels2:ToggleLock(index,val)
	if val == nil then val = not eePanels2.db.profile.global.locked end

	-- Make recursive call for every panel
	if not index or index == 0 then
		eePanels2.db.profile.global.locked = val
		for i in pairs(eePanels2.db.profile.panels) do
			eePanels2:ToggleLock(i,eePanels2.db.profile.global.locked)
		end
	-- Change the lock status of a panel, and update its guideFrame to match setting
	else
		local panel = eePanels2.db.profile.panels[index]
		panel.locked = val
		if panel.locked then
			if panel.guideFrame then
				panel.guideFrame:Hide()
			end
		else
			eePanels2:CreateGuideFrame(panel,index)
		end
	end
end


--[[
-- Creates a panel's frame; sets its parent frame
--]]
function eePanels2:CreateFrame(panel,i)
	panel.frame = CreateFrame("Frame", "eePanel"..i, UIParent)
	-- Check to ensure parent exists.  It might not if the parent belongs to an addon that isn't loaded [yet]
	if frameExists[panel.parent] then
		panel.frame:SetParent(panel.parent);
	-- We'll set it to the default for now, so the frame can still be created.  We'll check its parent again later
	else
		panel.frame:SetParent("UIParent")
	end
end


--[[
-- Change the display name of a panel in our menu (only used for identification purposed for the user's sake)
--]]
function eePanels2:ChangeName(panel,i)
	if not panel.name then panel.name = "" end
	eePanels2.OnMenuRequest.args.panels.args["eePanel"..i].name = i..". "..panel.name
	eePanels2.OnMenuRequest.args.panels.args["eePanel"..i].desc = i..". "..panel.name
	eePanels2.OnMenuRequest.args.globalSettings.args.filter.args[i].name = i..". "..panel.name
	if panel.guideFrame then 
		panel.guideFrame.text:SetText(L["eePanel"]..i..": "..panel.name) 
	end
end


--[[
-- Change the position (offsets) of a panel
--]]
function eePanels2:ChangePosition(panel)
	panel.frame:ClearAllPoints()
	panel.frame:SetPoint(panel.anchorFrom, panel.anchor, panel.anchorTo, panel.x, panel.y)
	-- Fix for guideFrames not always adjust to changed panel size
	if panel.guideFrame then panel.guideFrame:ClearAllPoints() panel.guideFrame:SetAllPoints(panel.frame) end
end


--[[
-- Change the width of a panel
--]]
function eePanels2:ChangeWidth(panel)
	-- Percent size
	if string.match(panel.width, "%d+%.?%d*%%") then
		local uiWidth = panel.frame:GetParent():GetWidth()
		fWidth = string.match(panel.width, "%d+%.?%d*")
		panel.frame:SetWidth(uiWidth * (fWidth / (100.0)))
	-- Pixel size
	elseif string.match(panel.width, "%d+") then
		panel.frame:SetWidth(tonumber(panel.width))
	end

	-- Fix for guideFrames not always adjust to changed panel size
	if panel.guideFrame then panel.guideFrame:SetAllPoints(panel.frame) end
end


--[[
-- Change the height of a panel
--]]
function eePanels2:ChangeHeight(panel)
	-- Percent size
	if string.match(panel.height, "%d+%.?%d*%%") then
		local uiHeight = panel.frame:GetParent():GetHeight()
		fHeight = string.match(panel.height, "%d+%.?%d*")
		panel.frame:SetHeight(uiHeight * (fHeight / (100.0)))
	-- Pixel size
	elseif string.match(panel.width, "%d+") then
		panel.frame:SetHeight(tonumber(panel.height))
	end

	-- Fix for guideFrames not always adjust to changed panel size
	if panel.guideFrame then panel.guideFrame:SetAllPoints(panel.frame) end
end


--[[
-- Change the backdrop of a panel
--]]
function eePanels2:ChangeBackdrop(panel)
	-- Change the backdrop
	panel.frame:SetBackdrop(
	{
		bgFile = panel.background.texture.texture, 
		edgeFile = panel.border.texture,
		edgeSize = panel.border.edgeSize,
		tile = panel.background.tiling,
		tileSize = panel.background.tileSize,
		insets = 
		{ 
			left = panel.background.insetSize.l,
			right = panel.background.insetSize.r,
			top = panel.background.insetSize.t,
			bottom = panel.background.insetSize.b
		},
	})
	-- Change the backdrop color
	panel.frame:SetBackdropColor(1,1,1,panel.background.texture.alpha)
end


--[[
-- Creates a texture which we will place overtop the panel
-- This is actually only ever going to have the default tooltip texture (by default).  We use this so that every panel will have a color. 
--]]
function eePanels2:CreateTexture(panel)
	panel.background.frame = panel.frame:CreateTexture(nil, "PARENT")
	panel.background.frame:SetPoint("TOPLEFT", panel.frame, "TOPLEFT",panel.background.insetSize.t,-panel.background.insetSize.l)
	panel.background.frame:SetPoint("BOTTOMRIGHT", panel.frame, "BOTTOMRIGHT",-panel.background.insetSize.b,panel.background.insetSize.r)
end


--[[
-- Change the blend mode of the background texture
--]]
function eePanels2:ChangeTextureBlend(panel)
	panel.background.frame:SetBlendMode(panel.background.blend)
end


--[[
-- Change the strata of a panel
--]]
function eePanels2:ChangeStrata(panel)
	panel.frame:SetFrameStrata(panel.strata)
end


--[[
-- Change the level of a panel
--]]
function eePanels2:ChangeLevel(panel)
	panel.frame:SetFrameLevel(panel.level)
end


--[[
-- Change the parent of a panel
--]]
function eePanels2:ChangeParent(panel)
	panel.frame:SetParent(panel.parent)
	-- If the parent has been changed to UIParent, set size/position back to default
	if panel.parent == "UIParent" or not frameExists[panel.parent] then
		panel.width = dp.width
		panel.height = dp.height
		panel.anchor = dp.anchor
	-- Otherwise, set it's position to 0,0 for the new parent, and set it's width/height to 100%
	else
		panel.anchor = panel.parent
		panel.width="100%"
		panel.height="100%"
	end
	-- Update new dimsnsions
	eePanels2:ChangeHeight(panel)
	eePanels2:ChangeWidth(panel)
	-- Update anchor
	eePanels2:ChangeAnchor(panel)
	-- Update position
	eePanels2:ChangePosition(panel)
	-- Update level
	eePanels2:ChangeLevel(panel)
	
	-- Might have inherited old parents visibility; if new parent is visible, set to visible
	if panel.frame:GetParent():IsVisible() then panel.frame:Show() end
end


--[[
-- Change the anchoring of a panel
--]]
function eePanels2:ChangeAnchor(panel)
	local anchorExists = frameExists[panel.anchor]

	-- Anchor changed; center the panel to the new anchor
	panel.x = 0
	panel.y = 0
	panel.anchorTo = RLookup(offsetPositionOpt, L["Center"])
	panel.anchorFrom = RLookup(offsetPositionOpt, L["Center"])
	eePanels2:ChangePosition(panel)
	
	-- Change panel guideFrame color (if it exists)
	if panel.guideFrame ~= nil then
		panel.guideFrame:ClearAllPoints()
		panel.guideFrame:SetWidth(panel.frame:GetWidth())
		panel.guideFrame:SetHeight(panel.frame:GetHeight())
		panel.guideFrame:SetPoint(panel.anchorFrom, panel.anchor, panel.anchorTo, panel.x, panel.y)
		panel.guideFrame.texture:SetTexture(eePanels2:GetHightlightColor(panel))
	end
end


--[[
-- Change the border color of a panel
--]]
function eePanels2:ChangeBorderColor(panel)
	panel.frame:SetBackdropBorderColor(
		panel.border.color.r,
		panel.border.color.g,
		panel.border.color.b,
		panel.border.color.a )
end


--[[
-- Change the background color of a panel
--]]
function eePanels2:ChangeBackgroundColor(panel)
	-- Display flat color
	if panel.background.style == RLookup(bgColorStyleOpt,L["Solid"]) then
		panel.background.frame:SetGradientAlpha(
			panel.background.gradient.orientation,
			panel.background.color.r,
			panel.background.color.g,
			panel.background.color.b,
			panel.background.color.a,
			panel.background.color.r,
			panel.background.color.g,
			panel.background.color.b,
			panel.background.color.a
		)
		panel.background.frame:SetTexture(
			panel.background.color.r,
			panel.background.color.g,
			panel.background.color.b,
			panel.background.color.a
		)
	-- Display gradient color
	else
		panel.background.frame:SetGradientAlpha(
			panel.background.gradient.orientation,
			panel.background.color.r,
			panel.background.color.g,
			panel.background.color.b,
			panel.background.color.a,
			panel.background.gradient.color.r,
			panel.background.gradient.color.g,
			panel.background.gradient.color.b,
			panel.background.gradient.color.a
		)
		panel.background.frame:SetTexture(
			panel.background.color.r,
			panel.background.color.g,
			panel.background.color.b,
			1
		)
	end
end


--[[
-- Change panel to intercept mouse clicks
--]]
function eePanels2:InterceptMouse(panel)
	panel.frame:EnableMouse(panel.mouse)
end


--[[
-- Runs all user defined scripts for a given panel.  Note: use registered events or event listeners when inserting code as
-- RunScript is run arbitrarily on all panel scripts whenever a script is added or removed from a panel
--]]
function eePanels2:ChangeScript(panel)
	for i in pairs(panel.scripts) do
		if panel.scripts[i].code ~= nil then
			RunScript(panel.scripts[i].code)
		end
	end
end
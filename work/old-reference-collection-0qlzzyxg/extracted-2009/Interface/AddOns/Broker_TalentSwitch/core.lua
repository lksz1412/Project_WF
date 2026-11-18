
Broker_TalentSwitch_frame = CreateFrame("frame");
Broker_TalentSwitch = LibStub("AceAddon-3.0"):NewAddon("Broker_TalentSwitch", "AceConsole-3.0", "AceEvent-3.0");

-- --------------------------------------------------------------------------
--
--  Addon local vars
--
-- --------------------------------------------------------------------------
local frame = Broker_TalentSwitch_frame
local addon = Broker_TalentSwitch
local MODNAME = "TalentSwitch"
local FULLNAME = "Broker_TalentSwitch"
local DEFAULT_ICON = "Interface\\Icons\\Ability_Marksmanship";
local L = LibStub:GetLibrary( "AceLocale-3.0" ):GetLocale( MODNAME )
local GetTalentTabInfo = GetTalentTabInfo;
local addonversion = GetAddOnMetadata(FULLNAME, "Version");
local db;
local options, moduleOptions = nil, {}
local defaults = 
{
	profile = 
	{
		prefixOutput = MODNAME,
		primaryAlias = L["DEFAULT_PRIMARY_ALIAS"],
		secondaryAlias = L["DEFAULT_SECONDARY_ALIAS"],
		successMessage = L["DEFAULT_SUCCESS_MESSAGE"],
		lastIconUsed = DEFAULT_ICON,
		hideSpam = true,
	}
}
-- --------------------------------------------------------------------------
--
--  Local Methods
--
-- --------------------------------------------------------------------------
local function optFunc() 
	-- open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.Profiles);
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.TalentSwitch);
end
local function getOptions()
	if not options then
		options = 
		{
			type = "group",
			name = MODNAME,
			args = 
			{
				general = 
				{
					order	= 1,
					type	= "group",
					name	= L["General Information"],
					desc	= L["GENERAL_INFO_DESC"],
					args	= 
					{
						header1 = {
							order	= 10,
							type	= "header",
							name	= L["General Information"],
						},
						desc = {
							order	= 11,
							type	= "description",
							name	= L["GENERAL_INFO_DESC"],
						},
						version = {
							order	= 12,
							type	= "description",
							name	= L["Version : "] .. addonversion .. "\n",
						},
						prefixOutput = 
						{
							order = 13,
							type = "input",
							name = L["Broker Prefix Label"],
							desc = L["PREFIX_OUTPUT_DESC"],
							usage = L["MSG_USAGE"],
							set = function(info,val) 
								db.prefixOutput = val;
								frame:UpdateDisplay();
							end,
							get = function(info) return db.prefixOutput end
						},
						successMessage = 
						{
							order = 14,
							type = "input",
							name = L["On Change"],
							desc = L["ONCHANGE_OUTPUT_DESC"],
							usage = L["MSG_USAGE"],
							set = function(info,val) db.successMessage = val end,
							get = function(info) return db.successMessage end
						},
						hideSpam = 
						{
							order	= 15,
							type	= "toggle",
							name	= L["Hide Spam"],
							desc	= L["HIDE_SPAM_DESC"],
							set = function(info,val) db.hideSpam = val end,
							get = function(info) return db.hideSpam end
						},
						spacer1 = {
							order	= 16,
							type	= "description",
							name	= " ",
						},
						primaryAlias = 
						{
							order = 17,
							type = "input",
							name = L["Primary Talent Alias"],
							desc = L["PRIMARY_DESC"],
							usage = L["MSG_USAGE"],
							set = function(info,val) 
								db.primaryAlias = val
								frame:UpdateDisplay();
							end,
							get = function(info) return db.primaryAlias end
						},
						secondaryAlias = 
						{
							order = 18,
							type = "input",
							name = L["Secondary Talent Alias"],
							desc = L["SECONDARY_DESC"],
							usage = L["MSG_USAGE"],
							set = function(info,val) 
								db.secondaryAlias = val 
								frame:UpdateDisplay();
							end,
							get = function(info) return db.secondaryAlias end
						},
						talentButton =
						{
							order = 19,
							type = "execute",
							name = L["BTN_GET_TALENT"],
							desc = L["BTN_GET_TALENT_DESC"],
							func = function()
								addon:SetTalentData();
							end
						},
					},
				},
			},
		}
		for k,v in pairs(moduleOptions) do
			options.args[k] = (type(v) == "function") and v() or v
		end
	end
	
	return options
end
-- --------------------------------------------------------------------------
--
--  Addon Ini Methods
--
-- --------------------------------------------------------------------------
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("talentswitchDB", defaults);
	
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh");
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh");
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh");
	
	db = self.db.profile;
	
	self:SetupOptions();
end

function addon:OnEnable()
	
end
-- --------------------------------------------------------------------------
--
--  Addon Methods
--
-- --------------------------------------------------------------------------

function addon:SetTalentData()
	local icon, talent, text = self:GetTalentInfo(1);
	db.primaryAlias = talent.." " ..text;
	
	icon, talent, text = self:GetTalentInfo(2);
	db.secondaryAlias = talent.." " ..text;
	
	frame:UpdateDisplay();
end

function addon:GetTalentInfo(group)
	local maxPoints, talentTreeIcon, text = -1
	local talentTreeName = "";
	
	for tab = 1, 3 do
		local name, icon, points = GetTalentTabInfo(tab,nil,nil,group)		
		if points > maxPoints then
			maxPoints = points
			talentTreeIcon = icon
			talentTreeName = name;
		end
		
		text = format("%s%.2i", text and text.."/" or "", points)
	end
		
	return talentTreeIcon, talentTreeName, text
end

function addon:GetAlias(index)
	local prefix = "";
	if(db.prefixOutput ~= nil) then
		prefix = addon.db.profile.prefixOutput;
	end
	
	local icon, talent, talentText = self:GetTalentInfo(index);
	
	local text = db.primaryAlias;
	local label = prefix;
		
	if(index == 2) then
		text = db.secondaryAlias;
	end
	
	return icon, label, text
end

function addon:GetGroupAlias(index)
	
	if index == 1 then
		return "Primary";		
	end
	
	return "Secondary";
end
-- --------------------------------------------------------------------------
--
--  Addon Options Methods
--
-- --------------------------------------------------------------------------
function addon:SetupOptions()
	InterfaceOptionsFrame:SetFrameStrata("DIALOG");
	self.optionsFrames = {}
	
	-- setup options table
	LibStub("AceConfig-3.0"):RegisterOptionsTable(MODNAME, getOptions);
	self.optionsFrames.TalentSwitch = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(MODNAME, nil, nil, "general");
	self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), "Profiles")
	LibStub("AceConsole-3.0"):RegisterChatCommand("talentswitch", optFunc)
end

function addon:RegisterModuleOptions(name, optionTbl, displayName)
	moduleOptions[name] = optionTbl
	self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(MODNAME, displayName, MODNAME, name)
end

function addon:Refresh()
	db = self.db.profile;
	frame:UpdateDisplay();
end
-- --------------------------------------------------------------------------
--
--  LDB Code
--
-- --------------------------------------------------------------------------
-- --------------------------------------------------------------------------
--
--  LDB properties
--
-- --------------------------------------------------------------------------
local DEFAULT_ICON, DEFAULT_TALENT = "Interface\\Icons\\Ability_Marksmanship", "00/00/00"
local outputNext = "";
local firstTime = true;
local orgSetActiveTalentGroup = _G.SetActiveTalentGroup;

-- Filters Based on DualSpeccer by Jeffrey0
local filter1 = string.gsub(ERR_SPELL_UNLEARNED_S:gsub('%.', '%.'), '%%s', '(.*)')
local filter2 = string.gsub(ERR_LEARN_ABILITY_S:gsub('%.', '%.'), '%%s', '(.*)')
local filter3 = string.gsub(ERR_LEARN_SPELL_S:gsub('%.', '%.'), '%%s', '(.*)')

local SPELL_PRIMARY = GetSpellInfo(63645);
local SPELL_SECONDARY = GetSpellInfo(63644);

-- --------------------------------------------------------------------------
--
--  Local Methods
--
-- --------------------------------------------------------------------------
local function filter(self, event, msg)
	if strfind(msg, filter1) or strfind(msg, filter2) or strfind(msg, filter3) then return true end;
end

function SetActiveTalentGroup(...)
	local db = addon.db.profile;
	
	if(db.hideSpam == true) then
		frame:RegisterEvent"UNIT_SPELLCAST_SUCCEEDED";
		frame:RegisterEvent"UNIT_SPELLCAST_STOP";
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filter);
	end
	
	return orgSetActiveTalentGroup(...)
end

local function StatusMsg(str)
    local t = '|cFFFFFF00Broker_TalenSwitch:|r '..str;
    ChatFrame1:AddMessage(t)
end
-- --------------------------------------------------------------------------
--
--  LDB init
--
-- --------------------------------------------------------------------------
local L = LibStub:GetLibrary( "AceLocale-3.0" ):GetLocale( MODNAME )
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local dataobj = ldb:NewDataObject(MODNAME, 
{
	type = "data source",
	label = MODNAME,
	text = DEFAULT_TALENT, 
	icon = DEFAULT_ICON,
	OnLeave = function()
		return GameTooltip:Hide();
	end,
	OnClick = function(self, button)
		if button == "LeftButton" then
			SetActiveTalentGroup( 3 - GetActiveTalentGroup() ) 
		elseif button == "RightButton" then
			InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.Profiles)
			InterfaceOptionsFrame_OpenToCategory(addon.optionsFrames.TalentSwitch)
		end
	end
});

-- Tooltip Based on Ara_Broker_SpecSwitcher
function dataobj:OnEnter()
	local showBelow = select(2, self:GetCenter()) > UIParent:GetHeight()/2;
	GameTooltip:SetOwner( self, "ANCHOR_NONE" );
	GameTooltip:SetPoint( showBelow and "TOP" or "BOTTOM", self, showBelow and "BOTTOM" or "TOP" );

	for i = 1, GetNumTalentGroups() do
		local icon, talent, text = addon:GetTalentInfo(i);		
		local tooltiptext = format("%u) \124T%s:19\124t %s %s", i, icon, talent, text);
		GameTooltip:AddDoubleLine( tooltiptext, GetActiveTalentGroup() == i and "|cff20ff20Active|r" or "      " );
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["TOOLTIP_OPEN_CONFIG"]);
	GameTooltip:AddLine(L["TOOLTIP_INSTRUCTIONS1"] .. outputNext .. L["TOOLTIP_INSTRUCTIONS2"]);

	GameTooltip:Show();
end
-- --------------------------------------------------------------------------
--
--  Frame Events
--
-- --------------------------------------------------------------------------
function frame:UpdateDisplay()
	if( addon.db ~= nil) then
		local db = addon.db.profile;
		local activeGroup = GetActiveTalentGroup();
		
		if activeGroup == 1 then
			outputNext = db.secondaryAlias;
		else
			outputNext = db.primaryAlias;
		end

		dataobj.icon, dataobj.label, dataobj.text = addon:GetAlias(activeGroup);
	end
end
function frame:UNIT_SPELLCAST_STOP(event, unit, spell)
	if unit ~= "player" then return end
	self:UnregisterEvent"UNIT_SPELLCAST_SUCCEEDED"
	self:UnregisterEvent"UNIT_SPELLCAST_STOP"
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", filter)
end
frame.UNIT_SPELLCAST_SUCCEEDED = frame.UNIT_SPELLCAST_STOP;

function frame:PLAYER_TALENT_UPDATE()
	if( addon.db ~= nil) then
		local db = addon.db.profile;
		if (db.hideSpam == true) and (string.len(db.successMessage) > 0) then
			addon:Print(db.successMessage);
		end
	end
	
	frame:UpdateDisplay();
end

function frame:ADDON_LOADED(event, addon)
	if addon == "Broker_TalentSwitch" then
		frame:SetScript( "OnUpdate", 
			function() 
				frame:SetScript("OnUpdate", nil) 
				frame.PLAYER_TALENT_UPDATE() 
			end 
		)
	end
end

function frame:PLAYER_LEAVING_WORLD() 
	self:UnregisterEvent"PLAYER_TALENT_UPDATE"; 
end
function frame:PLAYER_ENTERING_WORLD() 
	self:RegisterEvent"PLAYER_TALENT_UPDATE";
end

-- --------------------------------------------------------------------------
--
--  Frame Register Events & Scripts
--
-- --------------------------------------------------------------------------
frame:SetScript( "OnEvent", function(self, event, ...) return self[event](self, event, ...) end )

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_TALENT_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_LEAVING_WORLD");
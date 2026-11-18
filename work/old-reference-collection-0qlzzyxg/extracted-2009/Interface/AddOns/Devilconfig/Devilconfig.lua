Devilconfig = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")

Devilconfig.hasIcon = "Interface\\AddOns\\Devilconfig\\Devilicon.tga"
Devilconfig.defaultPosition = "CENTER"
Devilconfig.hasNoColor = true
Devilconfig.cannotDetachTooltip = true

local console = AceLibrary("AceConsole-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")

local L = AceLibrary("AceLocale-2.2"):new("Devilconfig");

L:RegisterTranslations("enUS", function() return {
	["Right-click me to get started!"] = true,
	["No description provided."] = true,
	["Others"] = true,
	["AddOns in category %q."] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Right-click me to get started!"] = "DevilUI 설정",
	["No description provided."] = "애드온에 대한 설명이 없습니다.",
--	["Others"] = "기타",
--	["AddOns in category %q."] = "%q 분류의 애드온들.",
} end)

function Devilconfig:OnInitialize()
	self:RegisterChatCommand({"/Devilconfig", "/devil"})

-- Create the root of our AceOptions table, ready for addons' tables to be inserted
self.theTable = { type = "group", 
args = {
	------------------------------------------------
	config_tcb = {
		name = "센터바", type = "group", order = 2,
		desc = "ToolsCenterBar2",
		hidden = function()
		if (IsAddOnLoaded("Dominos")) then return false
		else return true end
		end,			
		args = {
			dca = {
				name = "센터바 켬", type = "execute", order = 1,
				desc = "센터바를 불러웁니다.",
				func = function()
				ChatFrameEditBox:SetText("/dom set 센터바");
				ChatEdit_SendText( ChatFrameEditBox );
				end,
			},
			dcb = {
				name = "센터바(조화드루이드) 켬", type = "execute", order = 2,
				desc = "센터바를 불러웁니다.",
				func = function()
				ChatFrameEditBox:SetText("/dom set 센터바-조드");
				ChatEdit_SendText( ChatFrameEditBox );
				end,
			},
			dcf = {
				name = "센터바 끔", type = "execute", order = 5,
				desc = "센터바를 끕니다.",
				func = function()
				ChatFrameEditBox:SetText("/dom set 센터바 끔");
				ChatEdit_SendText( ChatFrameEditBox );
				end,
			},
		}
	},
	config_keb = {
		name = "단축키 설정", type = "group", order = 12,
		desc = "단축키를 설정합니다.",
		hidden = function()
		if (IsAddOnLoaded("Dominos")) then return false
		else return true end
		end,			
		args = {
			pol = {
				name = "단축키 설정", type = "execute", order = 1,
				desc = "단축키 설정모드를 불러웁니다.",
				func = function()
				ChatFrameEditBox:SetText("/kb");
				ChatEdit_SendText( ChatFrameEditBox );
				end,
			},
		}
	},
	config_cru = {
		name = "애드온 재시작", type = "group", order = 99,
		desc = "애드온을 리로드합니다.",
		hidden = function()
		if (IsAddOnLoaded("Devilconfig")) then return false
		else return true end
		end,			
		args = {
			crt = {
				name = "애드온 재시작", type = "execute", order = 1,
				desc = "애드온을 리로드합니다.",
				func = function()
				ChatFrameEditBox:SetText("/console reloadui");
				ChatEdit_SendText( ChatFrameEditBox );
				end,
			},
		}
	},
}
}
end

function Devilconfig:OnEnable()
	self:Construct()

	function self:OnMenuRequest(level, value)
		dewdrop:FeedAceOptionsTable(self.theTable)
		if level == 1 then dewdrop:AddLine() end
	end

	-- When another addon's loaded, :Construct again to check if the new addon's got a slash command to be added. It's run 2 seconds after ADDON_LOADED to ensure that its slash command is definitely registered
	self:RegisterEvent("ADDON_LOADED", function() self:ScheduleEvent(self.Construct, 2, self) end)
end

function Devilconfig:OnTooltipUpdate()
	tablet:SetHint(L["Right-click me to get started!"])
end

function Devilconfig:Construct()
	if type(v) == "table" and v.handler and v.handler.name and not self.theTable.args[v.handler.name] then
		if not self.theTable.args[category] then
			self.theTable.args[category] = {
				name = category,
				desc = string.format(L["AddOns in category %q."], category),
				type = "group",
				args = {}
			}
		end
		local cattbl = self.theTable.args[category]
	end
end
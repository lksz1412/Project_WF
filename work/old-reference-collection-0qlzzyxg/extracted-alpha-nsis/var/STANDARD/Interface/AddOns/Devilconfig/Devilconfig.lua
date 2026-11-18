local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("Devilconfig", {
	icon = "Interface\\AddOns\\Devilconfig\\Devilicon.tga",
	label = "Devilconfig",
	type     = "launcher",
	text	= "DevilUI 6.1 Alpha"
})

local index = GetCurrentResolution();
local resolution = select(index, GetScreenResolutions());
local NORMAL = (resolution == "720x576" or resolution == "800x600" or resolution == "1024x768" or resolution == "1152x864" or resolution == "1280x960" or resolution == "1280x1024" or resolution == "1400x1050" or resolution == "1600x1200" or resolution == "1680x1200" or resolution == "1920x1440");

local AceConfig 		= LibStub("AceConfig-3.0")
--local AceConfigReg 	= LibStub("AceConfigRegistry-3.0")
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0")

function dataobj.OnTooltipShow(tip)
	tip:AddLine("DevilUI")
	tip:AddLine(" ")
	tip:AddLine("|cff69b950좌-클릭:|r |cffeeeeeeDevilUI 설정|r")
	tip:AddLine("|cff69b950우-클릭:|r |cffeeeeee단축키 설정|r")
	tip:AddLine("|cff69b950알트-클릭:|r |cffeeeeeeUI 재시작|r")
	tip:AddLine("|cff69b950쉬프트-클릭:|r |cffeeeeee접속 종료|r")
end

function dataobj.OnClick()
	local button = GetMouseButtonClicked()
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				Logout()
			elseif IsAltKeyDown() then
				ReloadUI()
		else InterfaceOptionsFrame_OpenToCategory("DevilUI")
		end
		elseif ( button == "RightButton" ) then
			ChatFrame1EditBox:SetText("/kb");
			ChatEdit_SendText( ChatFrame1EditBox );
		end
end

local options = {
	name = "DevilUI",
	type = "group",
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = "DevilUI의 몇몇 설정등을 표시합니다.(Beta)\n",
			cmdHidden = true
		},
		centerbar = {
			inline = true,
			name = "센터바 설정",
			type = "group",
			order = 2,
			args ={
				showcenter = {
					type = 'execute',
					order = 3,
					name = "센터바 켬",
					desc = "센터바를 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/dom toggle 9 10");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
				hidecenter = {
					type = 'execute',
					order = 4,
					name = "센터바 끔",
					desc = "센터바를 끕니다.",
					func = function()
						ChatFrame1EditBox:SetText("/dom Hide 9 10");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
				disableAll = {
					type = 'execute',
					order = 5,
					name = "설정",
					desc = "도미노스 설정창을 불러 옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/dom config");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
			},
		},
		layout = {
			inline = true,
			name = "레이아웃 변경",
			type = "group",
			order = 6,
			args ={
				showcenter = {
					type = 'execute',
					order = 7,
					name = "기본하단",
					desc = "센터바를 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch Wide");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					disabled = NORMAL,
				},
				hidecenter = {
					type = 'execute',
					order = 8,
					name = "우측행동바(4:3)",
					desc = "센터바를 끕니다.",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch Normal");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					disabled = NORMAL,
				},
			},
		},
	}
}
-- Add config to Blizzard menu
LibStub("AceConfig-3.0"):RegisterOptionsTable("DevilUI", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DevilUI")
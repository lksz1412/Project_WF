local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("Devilconfig", {
	icon = "Interface\\AddOns\\Devilconfig\\Devilicon.tga",
	label = "Devilconfig",
	type     = "launcher",
	text	= "DevilUI 10.0.2 Fixed by 마른가지"
})

local AceConfig 		= LibStub("AceConfig-3.0")
--local AceConfigReg 	= LibStub("AceConfigRegistry-3.0")
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0")

function dataobj.OnTooltipShow(tip)
	tip:AddLine("DevilUI설정")
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
			name = "DevilUI의 몇몇 설정등을 표시합니다.(Test중)\n",
			cmdHidden = true
		},
		centerbar = {
			inline = true,
			name = "도미노스 설정",
			type = "group",
			order = 2,
			args ={
				showcenter = {
					type = 'execute',
					order = 3,
					name = "왼쪽 센터바 On/Off",
					desc = "왼쪽 센터바를 On/Off 합니다.",
					func = function()
						ChatFrame1EditBox:SetText("/dom toggle 7 9");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
				hidecenter = {
					type = 'execute',
					order = 4,
					name = "오른쪽 센터바 On/Off",
					desc = "오른쪽 센터바를 On/Off 합니다.",
					func = function()
						ChatFrame1EditBox:SetText("/dom toggle 8 10");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
				disableAll = {
					type = 'execute',
					order = 5,
					name = "도미노스 설정창",
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
					name = "하단집중형",
					desc = "하단집중형형",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch loaf");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
			},
		},
		Addons = {
			inline = true,
			name = "애드온 설정",
			type = "group",
			order = 9,
			args ={
				showcenter = {
					type = 'execute',
					order = 10,
					name = "Sexymap",
					desc = "Sexymap 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/sexymap");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,					
				},
				hidecenter = {
					type = 'execute',
					order = 11,
					name = "kg panels",
					desc = "바탕배경 판넬(kg panels) 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/kgpanels config");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
				},
				disableAll = {
					type = 'execute',
					order = 13,
					name = "툴팁",
					desc = "툴팁(Tiptac) 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/tiptac");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,	
				},
			},
		},
	}
}
-- Add config to Blizzard menu
LibStub("AceConfig-3.0"):RegisterOptionsTable("DevilUI", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DevilUI")
local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("Devilconfig", {
	icon = "Interface\\AddOns\\Devilconfig\\Devilicon.tga",
	label = "Devilconfig",
	type     = "launcher",
	text	= "DevilUI 9.0.1 Fixed by 마법을써요"
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
					desc = "기본하단형을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch ShapaWide");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					disabled = NORMAL,
				},
				hidecenter = {
					type = 'execute',
					order = 8,
					name = "우측행동바(4:3)",
					desc = "우측행동바(4:3)을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch ShapaNormal");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					disabled = NORMAL,
				},
				disableAll = {
					type = 'execute',
					order = 9,
					name = "기본하단2(21:9)",
					desc = "기본하단형 (21:9)을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/reflux switch ShapaWH");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					disabled = NORMAL,
				},
			},
		},
		Addons = {
			inline = true,
			name = "애드온 설정",
			type = "group",
			order = 10,
			args ={
				showcenter = {
					type = 'execute',
					order = 11,
					name = "막공골드도우미",
					desc = "막공골드도우미(T-raid) 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/tr");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
					
				},
				hidecenter = {
					type = 'execute',
					order = 12,
					name = "파티찾기",
					desc = "파티찾기(Findyparty) 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/fp");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,
                                },
				disableAll = {
					type = 'execute',
					order = 13,
					name = "툴팁",
					desc = "툴팁(Tiptac) 설정창을 불러 옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/tiptac");
						ChatEdit_SendText( ChatFrame1EditBox );
					end,

					
				},
			},
		},

		setting = {
			inline = true,
			name = "애드온 설정 II",
			type = "group",
			order = 13,
			args ={
				showcenter = {
					type = 'execute',
					order = 14,
					name = "kg panels",
					desc = "바탕배경 판넬(kg panels) 설정창을 불러옵니다.",
					func = function()
						ChatFrame1EditBox:SetText("/kgpanels config");
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
local _, FC = ...
local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject("Devilconfig", {
	icon = "Interface\\AddOns\\Devilconfig\\Devilicon.tga",
	label = "Devilconfig",
	type     = "launcher",
	text	= "DevilUI Forever"
})

local resolution = FC.Resolution()
local NORMAL = (resolution == "720x576" or resolution == "800x600" or resolution == "1024x768" or resolution == "1152x864" or resolution == "1280x960" or resolution == "1280x1024" or resolution == "1400x1050" or resolution == "1600x1200" or resolution == "1680x1200" or resolution == "1920x1440");

local AceConfig 		= LibStub("AceConfig-3.0", true)
--local AceConfigReg 	= LibStub("AceConfigRegistry-3.0")
local AceConfigDialog 	= LibStub("AceConfigDialog-3.0", true)

function dataobj.OnTooltipShow(tip)
	tip:AddLine("DevilUI")
	tip:AddLine(" ")
	tip:AddLine("|cff69b950좌-클릭:|r |cffeeeeeeDevilUI 설정|r")
	tip:AddLine("|cff69b950우-클릭:|r |cffeeeeee단축키 설정|r")
	tip:AddLine("|cff69b950알트-클릭:|r |cffeeeeeeUI 재시작|r")
	tip:AddLine("|cff69b950쉬프트-클릭:|r |cffeeeeee접속 종료|r")
end

function dataobj.OnClick(_, button)
	button = button or "LeftButton"
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				Logout()
			elseif IsAltKeyDown() then
				ReloadUI()
		else FC.OpenOptions("DevilUI")
		end
		elseif ( button == "RightButton" ) then
			ChatFrame1EditBox:SetText("/kb");
			ChatEdit_SendText( ChatFrame1EditBox );
		end
end

local function GetDominos()
    local ace = LibStub("AceAddon-3.0", true)
    return ace and ace:GetAddon("Dominos", true)
end
local function SetCenterBars(show)
    if InCombatLockdown() then
        print("Devilconfig: 전투 종료 후 센터바를 변경하세요.")
        return false
    end
    local dominos = GetDominos()
    local method = show and "ShowFrames" or "HideFrames"
    if not dominos or type(dominos[method]) ~= "function" then
        print("Devilconfig: Dominos를 활성화한 뒤 센터바를 변경하세요.")
        return false
    end
    -- Separate IDs are required; keep these bars visible/hidden on repeated clicks.
    dominos[method](dominos, "9", "10")
    return true
end
local function OpenDominosOptions()
    if InCombatLockdown() then print("Devilconfig: 전투가 끝난 뒤 설정창을 열어 주세요."); return end
    local dominos = GetDominos()
    if dominos and type(dominos.ShowOptionsFrame) == "function" then
        dominos:ShowOptionsFrame()
    else
        print("Devilconfig: Dominos와 Dominos 설정 모듈을 활성화하세요.")
    end
end

local function RunAddonCommand(key, message, addon)
    if InCombatLockdown() then print("Devilconfig: 전투가 끝난 뒤 설정창을 열어 주세요."); return false end
    local handler = SlashCmdList and SlashCmdList[key]
    if type(handler) ~= "function" then
        print("Devilconfig: " .. addon .. " 애드온을 활성화하세요.")
        return false
    end
    handler(message or "")
    return true
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
					width = "relative", relWidth = 0.32,
					name = "센터바 켬",
					desc = "센터바를 불러옵니다.",
					func = function()
						SetCenterBars(true)
					end,
				},
				hidecenter = {
					type = 'execute',
					order = 4,
					width = "relative", relWidth = 0.32,
					name = "센터바 끔",
					desc = "센터바를 끕니다.",
					func = function()
						SetCenterBars(false)
					end,
				},
				disableAll = {
					type = 'execute',
					order = 5,
					width = "relative", relWidth = 0.32,
					name = "설정",
					desc = "도미노스 설정창을 불러 옵니다.",
					func = function()
						OpenDominosOptions()
					end,
				},
			},
		},
		settings = {
			inline = true,
			name = "설정",
			type = "group",
			order = 6,
			args ={
				placement = {
					type = 'execute',
					order = 1,
					width = "relative", relWidth = 0.32,
					name = "채팅창·미니맵 배치",
					desc = "채팅창·미니맵 배치와 편집 모드에 연동되는 내부 아이콘 크기(%)를 조절합니다.",
					func = function()
						if DevilUIForever and type(DevilUIForever.OpenLayoutOptions) == "function" then
							DevilUIForever.OpenLayoutOptions(true)
						else
							print("DevilUI: !DevilUI 애드온을 활성화하세요.")
						end
					end,
				},
				tooltip = {
					type = 'execute',
					order = 2,
					width = "relative", relWidth = 0.32,
					name = "툴팁",
					desc = "툴팁(Tiptac) 설정창을 불러 옵니다.",
					func = function()
						RunAddonCommand("TIPTAC", "", "TipTac")
					end,
				},
				panels = {
					type = 'execute',
					order = 3,
					width = "relative", relWidth = 0.32,
					name = "kg panels",
					desc = "바탕배경 판넬(kg panels) 설정창을 불러옵니다.",
					func = function()
						RunAddonCommand("ACECONSOLE_KGPANELS", "config", "kgPanels")
					end,
				},
			},
		},
		layouts = {
			inline = true,
			name = "레이아웃 이름",
			type = "group",
			order = 7,
			args = {
				wide = {
					type = 'execute', order = 1,
					width = "relative", relWidth = 0.32,
					name = "Fan Wide",
					desc = "Fan Wide 프로필의 초기 설정 안내를 엽니다.",
					func = function()
						RunAddonCommand("DEVILUIFOREVER", "install Wide", "!DevilUI")
					end,
				},
				standard = {
					type = 'execute', order = 2,
					width = "relative", relWidth = 0.32,
					name = "Standard Wide",
					desc = "Standard Wide 프로필의 초기 설정 안내를 엽니다.",
					func = function()
						RunAddonCommand("DEVILUIFOREVER", "install Wide_B", "!DevilUI")
					end,
				},
				special = {
					type = 'execute', order = 3,
					width = "relative", relWidth = 0.32,
					name = "Special Wide",
					desc = "Special Wide 프로필의 초기 설정 안내를 엽니다.",
					func = function()
						RunAddonCommand("DEVILUIFOREVER", "install Wide_WH", "!DevilUI")
					end,
				},
			},
		},



	}
}
-- Add config to Blizzard menu
if not AceConfig or not AceConfigDialog then
    print("Devilconfig: ChocolateBar 또는 Ace3를 활성화하세요.")
    return
end
LibStub("AceConfig-3.0"):RegisterOptionsTable("DevilUI", options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DevilUI")

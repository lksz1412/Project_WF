local addOnName = GetAddOnDependencies(...)
local BII3 = _G[addOnName]
local Option = BII3.optionFrame
Option:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local LBO = LibStub("LibBlueOption-1.0")

local _G = _G
local type = _G.type
local sort = _G.table.sort
local twipe = _G.table.wipe
local tinsert = _G.table.insert

Option.title = Option:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
Option.title:SetPoint("TOPLEFT", 16, -16)
Option.title:SetText(Option.name)
Option.version = Option:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
Option.version:SetPoint("LEFT", Option.title, "RIGHT", 2, 0)
Option.version:SetText("v"..GetAddOnMetadata(addOnName, "Version").."."..GetAddOnMetadata(addOnName.."_UI", "X-DB-NumItems"))
Option.subText = Option:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
Option.subText:SetPoint("TOPLEFT", Option.title, "TOPLEFT", 15, -40)
Option.subText:SetHeight(32)
Option.subText:SetJustifyH("LEFT")
Option.subText:SetJustifyV("TOP")
Option.subText:SetNonSpaceWrap(true)
Option.subText:SetPoint("TOPLEFT", Option.title, "BOTTOMLEFT", 0, -8)
Option.subText:SetPoint("RIGHT", -32, 0)
Option.subText:SetText("아이템의 획득처를 툴팁에 표시해주고 목록별로 브라우저창을 보여주는 애드온입니다.")

Option.tooltip = LBO:CreateWidget("TitleBorder", Option, "툴팁")
Option.tooltip:SetPoint("TOP", Option.subText, "BOTTOM", 0, 0)
Option.tooltip:SetPoint("LEFT", 10, 0)
Option.tooltip:SetSize(180, 120)
Option.drop = LBO:CreateWidget("CheckBox", Option.tooltip, "획득처 표시하기", "툴팁에 아이템의 획득처를 표시합니다.", nil, nil, nil,
	function()
		return BII3.db.drop
	end,
	function(v)
		BII3.db.drop = v
	end
)
Option.drop:SetPoint("TOPLEFT", 10, -5)
Option.count = LBO:CreateWidget("CheckBox", Option.tooltip, "소지량 표시하기", "툴팁에 아이템을 가지고 있는 수량을 표시합니다.", nil, nil, nil,
	function()
		return BII3.db.count
	end,
	function(v)
		BII3.db.count = v
	end
)
Option.count:SetPoint("TOP", Option.drop, "BOTTOM", 0, 10)
Option.itemID = LBO:CreateWidget("CheckBox", Option.tooltip, "아이템ID 표시하기", "툴팁에 아이템의 ID 및 레벨을 표시합니다.", nil, function() return not Blizzard_CombatLog_Filters end, nil,
	function()
		if Blizzard_CombatLog_Filters then
			return not Blizzard_CombatLog_Filters.noTooltipID
		else
			return true
		end
	end,
	function(v)
		Blizzard_CombatLog_Filters.noTooltipID = not v
	end
)
Option.itemID:SetPoint("TOP", Option.count, "BOTTOM", 0, 10)

Option.window = LBO:CreateWidget("TitleBorder", Option, "UI 창")
Option.window:SetPoint("TOPLEFT", Option.tooltip, "BOTTOMLEFT", 0, -10)
Option.window:SetSize(180, 130)
Option.scale = LBO:CreateWidget("Slider", Option.window, "창 크기", "UI 창의 전체적인 크기를 설정합니다.", nil, nil, nil,
	function()
		return BII3.db.scale * 100, 50, 150, 1, "%"
	end,
	function(v)
		BII3.db.scale = v / 100
		BII3:SetScale(BII3.db.scale)
	end
)
Option.scale:SetPoint("TOPLEFT", 10, -18)
Option.height = LBO:CreateWidget("Slider", Option.window, "창 높이", "UI 창의 높이를 설정합니다.", nil, nil, nil,
	function()
		return BII3.db.height, 183, 612, 1, "픽셀"
	end,
	function(v)
		BII3.db.height = v
		BII3:SetHeight(v)
	end
)
Option.height:SetPoint("TOP", Option.scale, "BOTTOM", 0, -10)

Option.dataPack = LBO:CreateWidget("TitleBorder", Option, "데이터 팩")
Option.dataPack:SetPoint("TOPLEFT", Option.tooltip, "TOPRIGHT", 10, 0)
Option.dataPack:SetSize(180, 154)

local function disablePack(pack)
	return not GetAddOnInfo(addOnName.."_"..pack)
end
local function getPack(pack)
	if GetAddOnInfo(addOnName.."_"..pack) then
		return BII3.db.dataPacks[pack]
	else
		return false
	end
end
local function setPack(v, pack)
	BII3.db.dataPacks[pack] = v
end

local dataPacks = {
	{ "WD", "드레노어의 전쟁군주" },
	{ "MP", "판다리아의 안개" },
	{ "CA", "대격변" },
	{ "LK", "리치 왕의 분노" },
	{ "BC", "불타는 성전" },
	{ "Original", "오리지널" },
}

Option.dataPack.packs = {}

for p, v in ipairs(dataPacks) do
	Option.dataPack.packs[p] = LBO:CreateWidget("CheckBox", Option.dataPack, v[2], v[2].." 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, v[1])
	if p == 1 then
		Option.dataPack.packs[p]:SetPoint("TOPLEFT", 10, -5)
	else
		Option.dataPack.packs[p]:SetPoint("TOP", Option.dataPack.packs[p - 1], "BOTTOM", 0, 10)
	end
end

Option.dataPack:SetHeight(math.floor(Option.dataPack.packs[1]:GetTop() - Option.dataPack.packs[#Option.dataPack.packs]:GetBottom() + 0.5) + 8)



--[[
Option.dataPackMP = LBO:CreateWidget("CheckBox", Option.dataPack, "판다리아의 안개", "판다리아의 안개 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, "MP")
Option.dataPackMP:SetPoint("TOPLEFT", 10, -5)
Option.dataPackCA = LBO:CreateWidget("CheckBox", Option.dataPack, "대격변", "대격변 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, "CA")
Option.dataPackCA:SetPoint("TOP", Option.dataPackMP, "BOTTOM", 0, 10)
Option.dataPackLK = LBO:CreateWidget("CheckBox", Option.dataPack, "리치 왕의 분노", "리치 왕의 분노 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, "LK")
Option.dataPackLK:SetPoint("TOP", Option.dataPackCA, "BOTTOM", 0, 10)
Option.dataPackBC = LBO:CreateWidget("CheckBox", Option.dataPack, "불타는 성전", "불타는 성전 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, "BC")
Option.dataPackBC:SetPoint("TOP", Option.dataPackLK, "BOTTOM", 0, 10)
Option.dataPackOriginal = LBO:CreateWidget("CheckBox", Option.dataPack, "오리지널", "오리지널 데이터를 툴팁 및 UI 창에 표시합니다. 변경 사항은 재접속 후 적용됩니다.", nil, disablePack, nil, getPack, setPack, "Original")
Option.dataPackOriginal:SetPoint("TOP", Option.dataPackBC, "BOTTOM", 0, 10)

print(Option.dataPackOriginal:GetBottom() - Option.dataPackMP:GetTop())
]]

Option.mapButton = LBO:CreateWidget("TitleBorder", Option, "미니맵 버튼")
Option.mapButton:SetPoint("TOPLEFT", Option.dataPack, "BOTTOMLEFT", 0, -10)
Option.mapButton:SetSize(180, 86)
Option.showButton = LBO:CreateWidget("CheckBox", Option.mapButton, "표시하기", "미니맵 버튼을 표시합니다.", nil, nil, nil,
	function()
		return BII3.db.minimapButton.show
	end,
	function(v)
		BII3.db.minimapButton.show = v
		_G[addOnName.."MapButton"]:Toggle()
	end
)
Option.showButton:SetPoint("TOPLEFT", 10, -5)
Option.lockButton = LBO:CreateWidget("CheckBox", Option.mapButton, "잠그기", "미니맵 버튼을 잠가 이동하지 못하게 합니다.", nil, function() return not BII3.db.minimapButton.show end, nil,
	function()
		return BII3.db.minimapButton.dragable
	end,
	function(v)
		BII3.db.minimapButton.dragable = v
	end
)
Option.lockButton:SetPoint("TOP", Option.showButton, "BOTTOM", 0, 10)


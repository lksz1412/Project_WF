local addOnName = ...
local BII3 = CreateFrame("Frame", addOnName, UIParent)
BII3:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BII3:RegisterEvent("PLAYER_LOGIN")
BII3:Hide()
BII3:SetToplevel(true)
BII3.isHorde = UnitFactionGroup("player") == "Horde"
BII3.codeList = "ABCDE0123456789abcdefghijklmnopqrstuvwxyzFGHIJKLMNOPQRSTUVWXYZ"
BII3.codeListLen = BII3.codeList:len()
BII3.codeListZero = BII3.codeList:find("0")
BII3.equalItemID = {
	--[62367] = { 68719, 68765 },
}
BII3.linkedItemID = {
	--[68719] = 62367,
}
local heroicCategory = {
	["S_Gx[0-9A-Za-z]"] = true, -- 티어 17 (영웅)
	["S_3q[0-9A-Za-z]"] = true, -- 티어 16 (영웅)
	["S_3u[0-9A-Za-z]"] = true,	-- 티어 15 (영웅)
	["S_3x[0-9A-Za-z]"] = true,	-- 티어 14 (영웅)
	["S_f0[0-9A-Za-z]"] = true,	-- 티어 13 (상급)
	["S_fw[0-9A-Za-z]"] = true,	-- 티어 12 (상급)
	["S_fy[0-9A-Za-z]"] = true,	-- 티어 11 (상급)
	["S_L0[0-9A-Za-z]"] = true,	-- 시즌 15 정예
	["S_L3[0-9A-Za-z]"] = true,	-- 시즌 14 정예
	["S_Lu[0-9A-Za-z]"] = true,	-- 시즌 13 정예
	["S_kd[0-9A-Za-z]"] = true,	-- 시즌 12 정예
	["S_kh[0-9A-Za-z]"] = true,	-- 시즌 11 정예
	["S_kk[0-9A-Za-z]"] = true,	-- 시즌 10 정예
	["S_kn[0-9A-Za-z]"] = true,	-- 시즌 9 정예
	["C_$i71617 %+ $i%d+"] = true,	-- 결정화된 화염석 업그레이드
	["s_%d+@%$i105856"] = true,	-- 전쟁의 메아리 업그레이드
}
local flexibleCategory = {
	["S_3s[0-9A-Za-z]"] = true,	-- 티어 16 (탄력적 공격대)
}
local mythicCategory = {
	["S_Gw[0-9A-Za-z]"] = true, -- 티어 17 (신화)
}
local findRaidCategory = {
	["S_3t[0-9A-Za-z]"] = true,	-- 티어 16 (공격대 찾기)
	["S_3w[0-9A-Za-z]"] = true,	-- 티어 15 (공격대 찾기)
	["S_3z[0-9A-Za-z]"] = true,	-- 티어 14 (공격대 찾기)
	["S_fv[0-9A-Za-z]"] = true,	-- 티어 13 (공격대 찾기)
}

local _G = _G
local select = _G.select
local ipairs = _G.ipairs
local tonumber = _G.tonumber
local loadstring = _G.loadstring
local sort = _G.table.sort
local UnitLevel = _G.UnitLevel
local GetSpellInfo = _G.GetSpellInfo
local GetItemIcon = _G.GetItemIcon
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetAddOnMetadata = _G.GetAddOnMetadata
local category, category1, category2, packIndex
local itemRarity, itemName, itemLevel, itemCategory, _

BII3.itemDB, BII3.categoryCode, BII3.dataPacks = {}, {}, {}

local LBI = LibStub("LibBlueItem-1.0")

SLASH_BLUEITEMINFO1 = "/bii"
SLASH_BLUEITEMINFO2 = "/blueiteminfo"
SLASH_BLUEITEMINFO3 = "/아이템인포"
SlashCmdList["BLUEITEMINFO"] = function() BlueItemInfo3:ToggleUI() end
BINDING_HEADER_BLUEITEMINFO3 = "Blue Item Info 3"
BINDING_NAME_BLUEITEMINFO3_TOGGLE = "UI창 열기/닫기"
BINDING_NAME_BLUEITEMINFO3_SEARCH = "아이템 검색창 열기/닫기"
BINDING_NAME_BLUEITEMINFO3_OPTION = "설정창 열기/닫기"

function BII3:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	local LBDB = LibStub("LibBlueDB-1.0")
	local function newTable() return {} end

	BlueItemInfo3DB = BlueItemInfo3DB or {}
	BlueItemInfo3CharDB = BlueItemInfo3CharDB or {}
	BlueItemInfo3ItemNameDB = BlueItemInfo3ItemNameDB or {}
	if BlueItemInfo3CharDB.favorite then
		BlueItemInfo3CharDB.favorite = nil
	end
	self.db = LBDB:RegisterDB(BlueItemInfo3DB, {
		code = nil,
		scale = 1,
		anchor = "CENTER",
		px = 0,
		py = 0,
		height = 312,
		drop = true,
		count = true,
		memo = {},
		dataPacks = { WD = true, MP = true, CA = true, LK = true, BC = true, Original = true },
		minimapButton = { show = true, dragable = true, angle = 183 },
	}, newTable)

	local favorite, c1, c2 = {}
	for i = self.codeListZero, self.codeListLen do
		c1 = self.codeList:sub(i, i)
		if self:GetCategory("A"..c1.."0") then
			c1 = tonumber(c1) or c1
			favorite[c1] = favorite[c1] or {}
			if self:GetCategory("A"..c1.."1") then
				favorite[c1][1] = {}
				for j = self.codeListZero + 2, self.codeListLen do
					c2 = self.codeList:sub(j, j)
					if self:GetCategory("A"..c1..c2) then
						c2 = tonumber(c2) or c2
						favorite[c1][c2] = {}
					else
						break
					end
				end
			end
		else
			break
		end
	end
	self.chardb = LBDB:RegisterDB(BlueItemInfo3CharDB, {
		favorite2 = favorite,
		search = { anchor = "CENTER", px = 0, py = 0 },
	}, newTable)
	self.favoriteDBTable = favorite
	self:UpdateFavorite()

	self.itemNameDB = BlueItemInfo3ItemNameDB
	for id, v in pairs(self.itemNameDB) do
		if GetAddOnMetadata(addOnName.."_UI", "X-DB-ItemName-"..id) or not select(3, ("|"):split(v)) or not self:IsFavorite(id) then
			self.itemNameDB[id] = nil
		end
	end
	setmetatable(self.itemDB, {
		__index = function(self, key)
			if type(key) == "number" then
				for pack, use in pairs(BII3.db.dataPacks) do
					use = GetAddOnMetadata(addOnName.."_"..pack, "X-DB-Info-"..key)
					if use then
						return loadstring("return "..use)()
					end
				end
				if BII3.mountDB then
					return BII3.mountDB[key]
				end
			end
			return nil
		end,
		__newindex = function() end,
	})
	LibStub("LibItemTooltip-3.0"):Register(self, "ProcessTooltip")
	LibStub("LibMapButton-1.1"):CreateButton(self, "BlueItemInfo3MapButton", "Interface\\AddOns\\BlueItemInfo3\\Icon", 183, BlueItemInfo3DB.minimapButton)
	LibStub("LibDataBroker-1.1"):NewDataObject("BlueItemInfo3", {
		type = "launcher",
		text = "BII3",
		OnClick = self.OnClick,
		icon = "Interface\\AddOns\\BlueItemInfo3\\Icon",
		OnTooltipShow = function(tooltip)
			if tooltip and tooltip.AddLine then
				BII3:OnTooltip(tooltip)
			end
		end,
	})
	self.optionFrame = CreateFrame("Frame", addOnName.."OptionFrame", InterfaceOptionsFramePanelContainer)
	self.optionFrame:Hide()
	self.optionFrame.name = "블루 아이템 인포 3"
	self.optionFrame:SetScript("OnShow", function(self)
		self:SetScript("OnShow", nil)
		LoadAddOn(addOnName.."_Option")
	end)
	InterfaceOptions_AddCategory(self.optionFrame)
	if self:HasModule("UI") then
		LoadAddOn(addOnName.."_UI")
		if not(type(self.db.code) == "string" and self.db.code:len() == 3 and self.itemList[self.db.code]) then
			self.db.code = nil
			for i = 3, self.codeListLen do
				if self.itemList[self.codeList:sub(i, i).."**"] then
					for j = self.codeListZero, self.codeListLen do
						if self.itemList[self.codeList:sub(i, i)..self.codeList:sub(j, j).."*"] then
							for k = self.codeListZero, self.codeListLen do
								if self.itemList[self.codeList:sub(i, i)..self.codeList:sub(j, j)..self.codeList:sub(k, k)] then
									self.db.code = self.codeList:sub(i, i)..self.codeList:sub(j, j)..self.codeList:sub(k, k)
									break
								end
							end
						end
						if self.db.code then
							break
						end
					end
				end
				if self.db.code then
					break
				end
			end
		end
		self.forceRefresh = true
	end
end

function BII3:HasModule(module)
	return not select(6, addOnName.."_"..module)
end

function BII3:ToggleUI()
	if self:IsShown() then
		HideUIPanel(self)
	else
		ShowUIPanel(self)
	end
end

function BII3:ToggleSearch()
	if self:HasModule("Search") then
		if self.search then
			if self.search:IsShown() then
				self.search:Hide()
			else
				self.search:Show()
			end
		else
			LoadAddOn(addOnName.."_Search")
			self.search:Show()
		end
	end
end

function BII3:ToggleOption()
	if InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == self.optionFrame then
		InterfaceOptionsFrame_Show()
	else
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(self.optionFrame)
	end
end

function BII3:OnClick(button)
	if button == "RightButton" then
		BII3:ToggleOption()
	elseif IsAltKeyDown() and BII3:HasModule("Search") then
		BII3:ToggleSearch()
	else
		BII3:ToggleUI()
	end
end

function BII3:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine("Blue Item Info 3 (fan fix) v"..GetAddOnMetadata(addOnName, "Version").."."..GetAddOnMetadata(addOnName.."_UI", "X-DB-NumItems"))
	tooltip:AddLine(GetAddOnMetadata(addOnName, "X-Website"), 1, 1, 1)
	tooltip:AddLine("좌클릭: 창 열기", 1, 1, 0)
	if BII3:HasModule("Search") then
		tooltip:AddLine("Alt+좌클릭: 아이템 검색창 열기", 1, 1, 0)
	end
	tooltip:AddLine("우클릭: 옵션창 열기", 1, 1, 0)
end

function BII3:HasItem(id)
	if GetItemCount(self:GetItemSimpleLink(id), true) > 0 then
		return true
	elseif self.equalItemID[id] then
		for _, equal in pairs(self.equalItemID[id]) do
			if GetItemCount(equal, true) > 0 then
				return true
			end
		end
	end
	return nil
end

local function getItem(id)
	if BII3.itemNameDB[id] then
		return BII3.itemNameDB[id]
	else
		id = GetAddOnMetadata(addOnName.."_UI", "X-DB-ItemName-"..id)
		if id then
			id = id:gsub(";", ":")
			return id
		end
	end
	return nil
end

function BII3:GetItem(id)
	id = getItem(id)
	if id then
		itemRarity, itemName, itemLevel, itemCategory = ("|"):split(id)
		return tonumber(itemRarity), itemName, tonumber(itemLevel), tonumber(itemCategory)
	end
	return nil
end

function BII3:IsItem(id)
	if id < 0 then
		return GetSpellInfo(-id) and true or nil
	else
		return getItem(id) and true or nil
	end
end

function BII3:GetItemName(id, suffix)
	if id < 0 then
		return GetSpellInfo(-id) or "미확인 주문"
	else
		id = select(2, self:GetItem(id))
		if id then
			return (suffix or "")..id
		else
			return "미확인 아이템"
		end
	end
end

local rarityColors = {}
for i = 0, 7 do
	rarityColors[i] = "|c"..select(4, GetItemQualityColor(i)):sub(-8)
end

local function getItemName(id, suffixID)
	itemRarity, itemName = BII3:GetItem(id)
	if itemRarity then
		suffixID = suffixID and LBI:GetRandomSuffixFormat(suffixID)
		if suffixID then
			return rarityColors[itemRarity], suffixID:format(itemName)
		end
		return rarityColors[itemRarity], itemName
	else
		return nil
	end
end

local function getSpellName(id)
	itemName = LBI:IsEnchantSpell(id)
	if itemName then
		return "|cffffd000", itemName
	else
		itemName = GetSpellInfo(id)
		if itemName then
			return "|cff71d5ff", itemName
		end
	end
	return nil
end

function BII3:GetItemColorName(id, suffixID)
	if id < 0 then
		itemRarity, itemName = getSpellName(-id)
		if itemRarity then
			return itemRarity..itemName.."|r"
		else
			return "|cffffffff미확인 주문|r"
		end
	else
		itemRarity, itemName = getItemName(id, suffixID)
		if itemRarity then
			return itemRarity..itemName.."|r"
		else
			return "|cffffffff미확인 아이템|r"
		end
	end
end

function BII3:IsRandomSuffixItem(id)
	return id and GetAddOnMetadata(addOnName.."_UI", "X-DB-ItemSuffix-"..id) and true or nil
end

function BII3:IsHeroicItem(id)
	id = self.itemDB[id]
	if type(id) == "number" then
		id = self.itemDB[id]
	end
	if type(id) == "string" then
		if id:find("r_") or id:find("d_") then
			if id:find("R_") or id:find("D_") then
				return nil
			else
				return true
			end
		else
			for p in pairs(heroicCategory) do
				if id:find(p) then
					return true
				end
			end
		end
	end
	return nil
end

function BII3:IsFlexibleItem(id)
	id = self.itemDB[id]
	if type(id) == "number" then
		id = self.itemDB[id]
	end
	if type(id) == "string" then
		if id:find("F_") then
			if id:find("R_") or id:find("r_") or id:find("f_") then
				return nil
			else
				return true
			end
		else
			for p in pairs(flexibleCategory) do
				if id:find(p) then
					return true
				end
			end
		end
	end
	return nil
end

function BII3:IsMythicItem(id)
	id = self.itemDB[id]
	if type(id) == "number" then
		id = self.itemDB[id]
	end
	if type(id) == "string" then
		if id:find("M_") then
			if id:find("R_") or id:find("r_") or id:find("f_") then
				return nil
			else
				return true
			end
		else
			for p in pairs(mythicCategory) do
				if id:find(p) then
					return true
				end
			end
		end
	end
	return nil
end

function BII3:IsFindRaidItem(id)
	id = self.itemDB[id]
	if type(id) == "number" then
		id = self.itemDB[id]
	end
	if type(id) == "string" then
		if id:find("f_") then
			if id:find("R_") or id:find("r_") or id:find("F_") then
				return nil
			else
				return true
			end
		else
			for p in pairs(findRaidCategory) do
				if id:find(p) then
					return true
				end
			end
		end
	end
	return nil
end

function BII3:GetLinkID(link)
	if type(link) == "string" then
		if link:find("item:%d+") then
			local id = tonumber(link:match("item:(%d+)"))
			return LBI:GetItemIDWithBonusID(id, link)
		elseif link:find("spell:%d+") then
			return -tonumber(link:match("spell:(%d+)"))
		elseif link:find("enchant:%d+") then
			return -tonumber(link:match("enchant:(%d+)"))
		end
	end
	return nil
end

function BII3:GetItemLink(id, suffixID, uniqueID)
	if id < 0 then
		id = -id
		itemName = LBI:IsEnchantSpell(id)
		if itemName then
			return ("|cffffd000|Henchant:%d|h[%s]|h|r"):format(id, itemName)
		else
			return GetSpellLink(id) or nil
		end
	else
		itemName = select(2, GetItemInfo(self:GetItemSimpleLink(id, suffixID, uniqueID)))
		if itemName then
			return itemName
		else
			itemRarity, itemName = getItemName(id, suffixID)
			if itemRarity then
				return ("%s|Hitem:%d:0:0:0:0:0:%d:%d:%d:0|h[%s]|h|r"):format(itemRarity, id, suffixID or 0, uniqueID or 0, UnitLevel("player"), itemName)
			end
		end
	end
	return nil
end

function BII3:GetItemSimpleLink(id, suffixID, uniqueID)
	if id < 0 then
		id = -id
		if LBI:IsEnchantSpell(id) then
			return "enchant:"..id
		else
			return "spell:"..id
		end
	else
		local chk, aid, bid = LBI:GetItemIDAndBonusID(id)
		if chk then
			return ("item:%d:0:0:0:0:0:%d:%d:%d:0:%d:1:%d"):format(aid, suffixID or 0, uniqueID or 0, UnitLevel("player"), 0, bid)
		else
			return ("item:%d:0:0:0:0:0:%d:%d:%d:0"):format(id, suffixID or 0, uniqueID or 0, UnitLevel("player"))
		end
	end
end

local safeIcons = {
	[89767] = "inv_belt_cloth_reputation_c_01",
	[89768] = "inv_gauntlets_cloth_reputation_c_01",
	[89802] = "inv_jewelry_ring_144",
	[89803] = "inv_jewelry_ring_148",
	[89817] = "inv_bracer_plate_reputation_c_01",
	[89818] = "inv_bracer_leather_reputation_c_01",
	[89819] = "inv_cape_pandaria_d_03",
	[89820] = "inv_helm_mail_reputation_c_01",
	[89823] = "inv_chest_plate_reputation_c_01",
	[89825] = "inv_glove_mail_reputation_c_01",
	[89828] = "inv_shoulders_plate_raidwarrior_l_01",
	[89829] = "inv_boots_cloth_challengepriest_d_01",
	[89830] = "inv_pant_mail_raidhunter_l_01",
	[89831] = "inv_helm_leather_raiddruid_l_01",
	[89832] = "inv_chest_plate_raiddeathknight_l_01",
	[89834] = "inv_robe_mail_raidshaman_l_01",
	[89835] = "inv_helm_mail_raidshaman_l_01",
	[89836] = "inv_shoulder_leather_raidrogue_l_01",
	[89837] = "inv_pants_plate_raidwarrior_l_01",
	[89839] = "inv_belt_mail_raidhunter_l_01",
	[89842] = "inv_gauntlets_leather_raidrogue_l_01",
	[89843] = "inv_gauntlets_plate_raiddeathknight_l_01",
	[89883] = "inv_shoulder_raidmage_l_01",
	[89884] = "inv_pants_leather_raiddruid_l_01",
	[89886] = "inv_chest_leather_raidrogue_l_01",
	[89887] = "inv_chest_cloth_challengepriest_d_01",
	[89917] = "inv_jewelry_necklace_103",
	[89918] = "inv_boots_cloth_challengepriest_d_01",
	[89919] = "inv_belt_plate_raiddeathknight_l_01",
	[89920] = "inv_pant_mail_raidhunter_l_01",
	[89921] = "inv_shoulders_plate_raidwarrior_l_01",
	[89922] = "inv_helm_leather_raiddruid_l_01",
	[89923] = "inv_chest_plate_raiddeathknight_l_01",
	[89924] = "inv_shoulder_cloth_challengepriest_d_01",
	[89925] = "inv_robe_mail_raidshaman_l_01",
	[89926] = "inv_shoulder_leather_dungeonleather_c_05",
	[89927] = "inv_helm_mail_raidshaman_l_01",
	[89928] = "inv_pants_plate_raidwarrior_l_01",
	[89930] = "inv_belt_cloth_raidwarlock_l_01",
	[89931] = "inv_glove_raidmage_l_01",
	[89932] = "inv_jewelry_ring_144",
	[89933] = "inv_jewelry_ring_148",
	[89934] = "inv_bracer_plate_raiddeathknight_l_01",
	[89935] = "inv_bracer_leather_raidrogue_l_01",
	[89936] = "inv_cape_pandaria_d_03",
	[89940] = "inv_helm_mail_raidhunter_l_01",
	[89941] = "inv_chest_plate_raidpaladin_l_01",
	[89942] = "inv_glove_mail_raidshaman_l_01",
	[89945] = "inv_gauntlets_leather_raidrogue_l_01",
	[89946] = "inv_gauntlets_plate_raiddeathknight_l_01",
	[89947] = "inv_shoulder_raidmage_l_01",
	[89948] = "inv_pants_leather_raiddruid_l_01",
	[89949] = "inv_chest_cloth_challengepriest_d_01",
	[89950] = "inv_chest_leather_raidrogue_l_01",
	[89951] = "inv_belt_mail_raidhunter_l_01",
	[89953] = "inv_boots_cloth_challengepriest_d_01",
	[89955] = "inv_pants_mail_dungeonmail_c_05",
	[89956] = "inv_shoulders_plate_raidwarrior_l_01",
	[89957] = "inv_helm_leather_raiddruid_l_01",
	[89958] = "inv_chest_plate_raiddeathknight_l_01",
	[89960] = "inv_robe_mail_raidshaman_l_01",
	[89961] = "inv_shoulder_leather_raidrogue_l_01",
	[89962] = "inv_helm_mail_raidshaman_l_01",
	[89963] = "inv_pants_plate_raidwarrior_l_01",
	[89965] = "inv_belt_cloth_reputation_c_01",
	[89966] = "inv_gauntlets_cloth_reputation_c_01",
	[89967] = "inv_jewelry_ring_144",
	[89968] = "inv_jewelry_ring_148",
	[89969] = "inv_bracer_plate_reputation_c_01",
	[89970] = "inv_bracer_leather_reputation_c_01",
	[89971] = "inv_cape_pandaria_d_03",
	[89975] = "inv_helm_mail_reputation_c_01",
	[89976] = "inv_chest_plate_reputation_c_01",
	[89977] = "inv_glove_mail_reputation_c_01",
	[89980] = "inv_gauntlets_leather_raidrogue_l_01",
	[89981] = "inv_gauntlets_plate_raiddeathknight_l_01",
	[89983] = "inv_pants_leather_raiddruid_l_01",
	[89984] = "inv_chest_cloth_challengepriest_d_01",
	[89985] = "inv_chest_leather_raidrogue_l_01",
	[89986] = "inv_belt_mail_dungeonmail_c_05",
	[89885] = "inv_shoulder_mail_raidshaman_l_01",
	[89841] = "inv_pants_leather_raidrogue_l_01",
	[89943] = "inv_pants_leather_raidrogue_l_01",
	[89944] = "inv_shoulder_mail_dungeonmail_c_05",
	[89978] = "inv_pants_leather_raidrogue_l_01",
	[89979] = "inv_shoulder_mail_raidshaman_l_01",
	[104895] = "INV_SHOULDER_PLATE_GARROSH_D_01",
	[105144] = "INV_SHOULDER_PLATE_GARROSH_D_01",
}

function BII3:GetItemIcon(id)
	if id > 0 then		
		return select(10, GetItemInfo(BII3:GetItemSimpleLink(id))) or GetItemIcon(select(2, LBI:GetItemIDAndBonusID(id))) or (safeIcons[id] and ("Interface\\Icons\\"..safeIcons[id])) or "Interface\\Icons\\INV_Misc_QuestionMark"
	elseif id < 0 then
		return select(3, GetSpellInfo(-id)) or (safeIcons[id] and ("Interface\\Icons\\"..safeIcons[id])) or "Interface\\Icons\\INV_Misc_QuestionMark"
	else
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end
end

function BII3:ReplaceFactionText(text)
	if text:find("$f{") then
		text = text:gsub("$f{([^{}]+)/([^{}]+)}", self.isHorde and "%1" or "%2")
	end
	return text
end

function BII3:GetCategory(code)
	return code and self.categoryCode[code] or GetAddOnMetadata(addOnName, "X-DB-Category-"..code:gsub("[A-Z]", "!%1"))
end

function BII3:GetCategoryName(code)
	category = self:GetCategory(code)
	if category then
		if code:find("0$") then
			category1, category2, category = ("_"):split(category)
		else
			category1 = self:GetCategory(code:sub(1, 2).."0")
			if category1 then
				category1, category2 = ("_"):split(category1)
			else
				return nil
			end
		end
		return category1, self:ReplaceFactionText(category2), category and self:ReplaceFactionText(category) or nil
	else
		return nil
	end
end

local itemRarity1, itemName1, itemLevel1, itemCategory1
local itemRarity2, itemName2, itemLevel2, itemCategory2
local itemID, itemSuffix

local function getOrder(id)
	if type(id) == "string" then
		id, itemSuffix = id:match("(%d+)%-%d+%-(%d+)")
		if id then
			itemRarity, itemName, itemLevel, itemCategory = BII3:GetItem(tonumber(id))
			if itemRarity then
				return itemRarity, (LBI:GetRandomSuffixFormat(tonumber(itemSuffix)) or "%s"):format(itemName), itemLevel, itemCategory
			end
		end
		return -2, tostring(id), 9999, 9999
	elseif id > 0 then
		itemRarity, itemName, itemLevel, itemCategory = BII3:GetItem(id)
		if itemRarity then
			return itemRarity, itemName, itemLevel, itemCategory
		else
			return -2, tostring(id), 9999, 9999
		end
	else
		itemName = GetSpellInfo(-id)
		if itemName then
			return -3, itemName, 9999, 9999
		else
			return -4, tostring(id), 9999, 9999
		end
	end
end

local function sortItemTable(a, b)
	itemRarity1, itemName1, itemLevel1, itemCategory1 = getOrder(a)
	itemRarity2, itemName2, itemLevel2, itemCategory2 = getOrder(b)
	if itemRarity1 == itemRarity2 then
		if itemCategory1 == 9999 and itemCategory2 == 9999 then
			if itemName1 == itemName2 then
				return a > b
			else
				return itemName1 < itemName2
			end
		elseif itemLevel1 == itemLevel2 then
			if itemCategory1 == itemCategory2 then
				if itemName1 == itemName2 then
					return a > b
				else
					return itemName1 < itemName2
				end
			else
				return itemCategory1 < itemCategory2
			end
		else
			return itemLevel1 > itemLevel2
		end
	else
		return itemRarity1 > itemRarity2
	end
end

local function sortFavoriteItemTable(a, b)
	itemName1, itemLevel1 = select(2, getOrder(a))
	itemName2, itemLevel2 = select(2, getOrder(b))
	if itemLevel1 == itemLevel2 then
		if itemName1 == itemName2 then
			return a > b
		else
			return itemName1 < itemName2
		end
	else
		return itemLevel1 > itemLevel2
	end
end

function BII3:Sort(tbl, isFavorite)
	if #tbl > 0 then
		sort(tbl, isFavorite and sortFavoriteItemTable or sortItemTable)
		itemRarity1, itemName1, itemLevel1, itemCategory1, itemRarity2, itemName2, itemLevel2, itemCategory2 = nil
	end
end

BII3:SetScript("OnShow", function(self)
	DEFAULT_CHAT_FRAME:AddMessage("BlueItemInfo3_UI가 존재하지 않습니다.")
	self:Hide()
end)

function BII3:GetItemIDSuffixUnique(link)
	if type(link) == "string" then
		local id = BII3:GetLinkID(link)
		if id and id > 0 then
			local suffix, unique = link:match("item:%d+:%d+:%d+:%d+:%d+:%d+:([%-]-[0-9]+):(%d+)")
			if suffix then
				id = LBI:GetItemIDWithBonusID(id, link)
				return id, tonumber(suffix), tonumber(unique)
			end
		end
	elseif type(link) == "number" then
		return link
	end
	return nil
end

function BII3:ItemOnClick(item, button)
	local id, suffix, unique = BII3:GetItemIDSuffixUnique(item)
	if id then
		if IsControlKeyDown() and IsShiftKeyDown() then
			self:AddMemo(id)
		elseif IsAltKeyDown() then
			self:AddFavorite(id)
		elseif IsModifiedClick("DRESSUP") and (self.IsMount and self:IsMount(id)) then
			DressUpItemLink(self:GetItemLink(id, suffix, unique))
		elseif IsModifiedClick() then
			HandleModifiedItemClick(self:GetItemLink(id, suffix, unique))
		else
			SetItemRef(self:GetItemSimpleLink(id, suffix, unique), self:GetItemLink(id, suffix, unique), button or "LeftButton")
		end
	end
end

function BII3:ModifiedItemClick(link)
	if type(link) == "string" and (link:find("item:") or link:find("spell:") or link:find("enchant:")) then
		if IsControlKeyDown() and IsShiftKeyDown() then
			self:AddMemo(self:GetLinkID(link))
			return true
		elseif IsAltKeyDown() then
			self:AddFavorite(self:GetLinkID(link))
			return true
		elseif IsModifiedClick("DRESSUP") and self.DressUp then
			return self:DressUp(self:GetLinkID(link))
		end
	end
	return nil
end

--[[
if StaticPopupDialogs.ADDON_ACTION_FORBIDDEN and not StaticPopupDialogs._ADDON_ACTION_FORBIDDEN then
	StaticPopupDialogs._ADDON_ACTION_FORBIDDEN, StaticPopupDialogs.ADDON_ACTION_FORBIDDEN = StaticPopupDialogs.ADDON_ACTION_FORBIDDEN, nil
else
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN = nil
end
]]
hooksecurefunc("ChatFrame_OnHyperlinkShow", function(self, link, text, button)
	if IsModifiedClick() and button == "LeftButton" and (self ~= COMBATLOG or not self) then
		BII3:ModifiedItemClick(link)
	end
end)
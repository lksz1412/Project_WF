BlueItemInfo2 = CreateFrame("Frame")
BlueItemInfo2:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BlueItemInfo2:RegisterEvent("ADDON_LOADED")

local ItemTooltip = LibStub("LibItemTooltip-1.0")
local LDM = LibStub("LibDropMenu-2.0")
local Broker = LibStub("LibDataBroker-1.1")
local MapButton = LibStub("LibMapButton-1.1")

local f = strsub(UnitFactionGroup("player"), 1, 1)
local cache, TokenNameCache, TokenCache, enchantCache = {}, {}, {}, {}
local _G = getfenv(0)
local testFarmItem = nil

if not BluePrint then function BluePrint() end end

BINDING_HEADER_BLUEITEMINFO2 = "Blue Item Info 2"
BINDING_NAME_BLUEITEMINFO2_TOGGLE = "GUI창 열기/닫기"

local _G = _G
local type = _G.type
local abs = _G.abs
local select = _G.select
local tonumber = _G.tonumber
local tinsert = _G.table.insert
local format = _G.format
local pairs = _G.pairs
local ipairs = _G.ipairs
local UnitName = _G.UnitName
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetItemInfo = _G.GetItemInfo
local GetItemIcon = _G.GetItemIcon
local GetItemQualityColor = _G.GetItemQualityColor
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink

BlueItemInfo2.title = "BlueItemInfo2"
BlueItemInfo2.version = GetAddOnMetadata("BlueItemInfo2", "Version")
BlueItemInfo2.website = GetAddOnMetadata("BlueItemInfo2", "X-Website")
BlueItemInfo2.icon = "Interface\\AddOns\\BlueItemInfo2\\Texture\\Icon"
BlueItemInfo2.defalutCode = "100"
BlueItemInfo2.data = { initDB = false, num = 0, items = {}, itemframes = 0, nver = "3.2.2", cver = GetBuildInfo(), virtual = false, unidentifiedItems = {}, equipItems = {} }
BlueItemInfo2.data.lockCategory = {
	["1i4"] = 2009090400,	-- 십자군의 시험장 아눕아락
	["1j6"] = 2009090400,	-- 십자군의 시험장 공물함
	["1j0"] = 2009090400,	-- 십자군 사령관의 시험장 노스렌드의 야수
	["1j1"] = 2009090400,	-- 십자군 사령관의 시험장 군주 자락서스
	["1j2"] = 2009090400,	-- 십자군 사령관의 시험장 종족 대표 용사
	["1j3"] = 2009090400,	-- 십자군 사령관의 시험장 발키르 쌍둥이
	["1j4"] = 2009090400,	-- 십자군 사령관의 시험장 아눕아락
	["1j6"] = 2009090400,	-- 십자군 사령관의 시험장 공물함
	["500"] = 2009090307,	-- 투기장 (시즌 7)
	["501"] = 2009090307,	-- 투기장 (시즌 7)
	["502"] = 2009090307,	-- 투기장 (시즌 7)
	["503"] = 2009090307,	-- 투기장 (시즌 7)
	["504"] = 2009090307,	-- 투기장 (시즌 7)
	["505"] = 2009090307,	-- 투기장 (시즌 7)
	["506"] = 2009090307,	-- 투기장 (시즌 7)
	["507"] = 2009090307,	-- 투기장 (시즌 7)
	["508"] = 2009090307,	-- 투기장 (시즌 7)
	["509"] = 2009090307,	-- 투기장 (시즌 7)
	["50a"] = 2009090307,	-- 투기장 (시즌 7)
	["50b"] = 2009090307,	-- 투기장 (시즌 7)
	["50c"] = 2009090307,	-- 투기장 (시즌 7)
	["50d"] = 2009090307,	-- 투기장 (시즌 7)
	["50e"] = 2009090307,	-- 투기장 (시즌 7)
	["50f"] = 2009090307,	-- 투기장 (시즌 7)
	["50g"] = 2009090307,	-- 투기장 (시즌 7)
	["50h"] = 2009090307,	-- 투기장 (시즌 7)
}

SLASH_BLUEITEMINFO1 = "/bii"
SLASH_BLUEITEMINFO2 = "/blueiteminfo"
SLASH_BLUEITEMINFO3 = "/아이템인포"
SlashCmdList["BLUEITEMINFO"] = function() BlueItemInfo2:OnClick() end

local count
local function numTableCount(table)
	if type(table) == "table" then
		count = 0
		for p in pairs(table) do
			count = count + 1
		end
		return count
	end
	return 0
end

function BlueItemInfo2:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self.data.nver = self.data.nver or self.data.cver
	self:SetDefault()
	self.ScheduleEventDB = {}
	self.timer = 0
	self.isTemp = true
	Broker:NewDataObject("BlueItemInfo2", {
		type = "launcher",
		text = "BlueItemInfo2",
		OnClick = BlueItemInfo2.OnClick,
		icon = self.icon,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			BlueItemInfo2:OnTooltip(tooltip)
		end,
	})
	MapButton:CreateButton(BlueItemInfo2, "BlueItemInfo2MapButton", self.icon, 183, BlueItemInfo2DB.minimapButton)
	self:SetScript("OnUpdate", self.OnUpdate)
	self:InitFavorite()
	self:InitMemo()
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:InventoryItemCheck()
	if IsLoggedIn() then
		self:PLAYER_LOGIN()
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
end

function BlueItemInfo2:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_LOGIN")
	LoadAddOn("BlueItemInfo2_BC")
	LoadAddOn("BlueItemInfo2_Original")
	self.data.itemDB = self.data.itemDB or {}	-- 리치왕의 분노
	self.data.itemDB1 = self.data.itemDB1 or {}	-- 불타는 성전
	self.data.itemDB0 = self.data.itemDB0 or {}	-- 오리지널
	self.data.num = numTableCount(self.data.itemDB)
	self.data.num = self.data.num + max(4672, numTableCount(self.data.itemDB1))
	self.data.num = self.data.num + max(2812, numTableCount(self.data.itemDB0))
	self.version = BlueItemInfo2.version.."."..self.data.num
	self.factionGroup = (UnitFactionGroup("player") or ""):sub(1, 1)
	local t = BlueItemInfo2:GetCurrentTime()
	for p, v in pairs(self.data.lockCategory) do
		if t >= v then
			self.data.lockCategory[p] = nil
		end
	end
	ItemTooltip:Register(self, "ProcessTooltip")
	if self.CreateFarmItemTable then
		self:CreateFarmItemTable()
	end
	collectgarbage()
end

function BlueItemInfo2:SetDefault()
	BlueItemInfo2DB = BlueItemInfo2DB or {
		info = true, id = false, level = false, sort = true, esc = true, pos = { "CENTER", 0, 0 }, height = 279, scale = 1.0,
		category = "100", backdrop = { 0, 0, 0.24, 0.8 }, memo = {},
		minimapButton = { show = true, dragable = true, angle = 183 },
	}
	BlueItemInfo2DB.minimapButton = BlueItemInfo2DB.minimapButton or { show = true, dragable = true, angle = 183 }
	BlueItemInfo2Char = BlueItemInfo2Char or { favorite = { {}, {}, {}, {}, {} } }

end

function BlueItemInfo2:GetCurrentTime()
	if BlueItemInfo2DB.forceIdenty then
		return 3000000000
	elseif GetGameTime() > 9 then
		return tonumber(date("%Y%m%d")..GetGameTime())
	else
		return tonumber(date("%Y%m%d").."0"..GetGameTime())
	end
end

local lockYear, lockMounth, lockDate, lockHour

function BlueItemInfo2:OnUpdate()
	self.timer = GetTime()
	self.isTemp = true
	for p, v in pairs(self.ScheduleEventDB) do
		if v[1] <= self.timer then
			if type(v[3]) == "function" then
				v[3](unpack(v[4]))
			elseif type(v[3]) == "string" and v[2] and v[2][v[3]] then
				v[2][v[3]](v[2], unpack(v[4]))
			end
			self.ScheduleEventDB[p] = nil
		else
			self.isTemp = nil
		end
	end
	if self.isTemp then
		self:SetScript("OnUpdate", nil)
	end
end

function BlueItemInfo2:ScheduleEvent(eventName, method, delay, owner, ...)
	if self:GetScript("OnUpdate") == nil then
		self:SetScript("OnUpdate", self.OnUpdate)
	end
	self.ScheduleEventDB[eventName] = { GetTime() + (delay or 0), owner or self, method, { ... } }
end

function BlueItemInfo2:CancelScheduledEvent(eventName)
	self.ScheduleEventDB[eventName] = nil
end

local invlink

function BlueItemInfo2:InventoryItemCheck()
	for p in pairs(self.data.equipItems) do
		self.data.equipItems[p] = nil
	end
	for i = 1, 19 do
		invlink = GetInventoryItemLink("player", i)
		if invlink then
			invlink = tonumber(invlink:match("item:(%d+)") or "")
			if invlink then
				self.data.equipItems[invlink] = self.data.equipItems[invlink] and (self.data.equipItems[invlink] + 1) or 1
			end
		end
	end
end

function BlueItemInfo2:UNIT_INVENTORY_CHANGED(unit)
	if unit == "player" then
		self:ScheduleEvent("BlueItemInfo2InventoryItemCheck", "InventoryItemCheck", 0.25)
	end
end

function BlueItemInfo2:OnClick(button)
	if not BlueItemInfo2DB then
		self:SetDefault()
	end
	if button == "RightButton" then
		if LDM:IsOpen("BlueItemInfo2") then
			LDM:CloseMenu(1)
		else
			LDM:OpenMenu("BlueItemInfo2", "TOPLEFT", self, "BOTTOMLEFT")
		end
	else
		LDM:CloseMenu(1)
		if BlueItemInfo2.data.initDB then
			if BlueItemInfo2.GUI:IsVisible() then
				BlueItemInfo2.GUI:Hide()
			else
				BlueItemInfo2.GUI:Show()
			end
		else
			BlueItemInfo2:CreateItemTable()
			if BlueItemInfo2.CreateFavoriteItemTable then
				BlueItemInfo2:CreateFavoriteItemTable()
			end
			BlueItemInfo2:CreateCategory()
			BlueItemInfo2:CreateGUI()
			collectgarbage()
			BlueItemInfo2.data.initDB = true
		end
	end
end

function BlueItemInfo2:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine(BlueItemInfo2.title.." v"..BlueItemInfo2.version)
	tooltip:AddLine(BlueItemInfo2.website, 1, 1, 1)
	tooltip:AddLine("좌클릭: GUI 열기", 1, 1, 0)
	tooltip:AddLine("우클릭: 메뉴 열기", 1, 1, 0)
end

local itemID, enchantID, itemLevel, itemName, itemLink, itemRarity, itemTexture
local bagCount, bankCount, invCount, totalCount, hasText

function BlueItemInfo2:ProcessTooltip(tooltip, name, link, id)
	if id then
		if id > 0 then
			itemLevel = select(4, GetItemInfo(link))
			if not BlueItemInfo2DB then
				self:SetDefault()
			end
			if BlueItemInfo2DB.info then
				text = self:GetItemText(id, nil)
				if text and text ~= "" then
					tooltip:AddLine(text.."|r")
				else
					text = self:GetItemCode(id)
					if type(text) == "string" then
						if self.factionGroup == "H" then
							if text:find("^a|") then
								if cache[0] == nil then
									cache[0] = "|cff64cd3c▶|cffff5050얼라이언스 진영 전용 아이템"
								end
								cache[id] = 0
								tooltip:AddLine(cache[0].."|r")
							end
						elseif text:find("^h|") then
							if cache[0] == nil then
								cache[0] = "|cff64cd3c▶|cffff5050호드 진영 전용 아이템"
							end
							cache[id] = 0
							tooltip:AddLine(cache[0].."|r")
						end
					end
				end
			end
			if BlueItemInfo2DB.memo[id] then
				tooltip:AddLine("|cff64cd3c▷|cffeaeaea"..BlueItemInfo2DB.memo[id].."|r")
			end
			if self:IsFavoriteItem(id) then
				tooltip:AddLine("|cff64cd3c▷|cffff8000즐겨찾기 아이템|r")
			end
			if not BlueItemInfo2DB.count then
				hasText = nil
				totalCount = GetItemCount(id, true) or 0
				if totalCount > 0 then
					bagCount = GetItemCount(id) or 0
					invCount = self.data.equipItems[id] or 0
					bankCount = totalCount - bagCount
					bagCount = bagCount - invCount
					if totalCount == 1 then
						if bankCount == 1 then
							hasText = "아이템 보유중(은행)"
						elseif bagCount == 1 then
							hasText = "아이템 보유중(가방)"
						else
							hasText = "아이템 착용중"
						end
					elseif totalCount > 1 then
						hasText = ("총 %d개 보유중("):format(totalCount)
						if invCount > 0 then
							hasText = ("%s착용 %d"):format(hasText, invCount)
						end
						if bagCount > 0 then
							if invCount > 0 then
								hasText = ("%s, 가방 %d"):format(hasText, bagCount)
							else
								hasText = ("%s가방 %d"):format(hasText, bagCount)
							end
						end
						if bankCount > 0 then
							if bagCount > 0 or invCount > 0 then
								hasText = ("%s, 은행 %d"):format(hasText, bankCount)
							else
								hasText = ("%s은행 %d"):format(hasText, bankCount)
							end
						end
						hasText = hasText..")"
					end
					if hasText then
						tooltip:AddLine("|cff64cd3c▷|cffffff00"..hasText)
					end
				end
			end
			if BlueItemInfo2DB.id and BlueItemInfo2DB.level and itemLevel then
				tooltip:AddDoubleLine("아이템ID: "..id, "아이템LV: "..itemLevel)
			elseif BlueItemInfo2DB.id then
				tooltip:AddLine("아이템ID: "..id)
			elseif BlueItemInfo2DB.level and itemLevel then
				tooltip:AddLine("아이템LV: "..itemLevel)
			end
		elseif id < 0 then
			if BlueItemInfo2DB.memo[id] then
				tooltip:AddLine("|cff64cd3c▷|cffeaeaea"..BlueItemInfo2DB.memo[id].."|r")
			end
			if BlueItemInfo2DB.id then
				tooltip:AddLine("주문ID: "..(abs(id)))
			end
		end
	end
end

local swich = {
	["cN"] = "|cff64cd3c▶|cffffffa4",
	["cH"] = "|cff7df4b2",
	["cW"] = "|cffffffff",
	["cR"] = "|cffff7db4",
	["cI"] = "|cffdcdcdc",
	["cA"] = "|cff46aa46투기장 ",
	["cO"] = "|cff50cbff명예 ",
	["cQ"] = "|cff76eec6▷",
	["cF"] = "|cfffdcd8c",
	["cT"] = "|cff1ea4ff",
	["cS"] = "|cffffffa4",
	["AV"] = "|cffdcdcdc알터랙 계곡 명예 훈장(",
	["ES"] = "|cffdcdcdc폭풍의 눈 명예 훈장(",
	["AB"] = "|cffdcdcdc아라시 분지 명예 훈장(",
	["WG"] = "|cffdcdcdc전쟁노래 협곡 명예 훈장(",
}

local reputation = {
	["-3"] = ": 매우 적대적 평판 필요",
	["-2"] = ": 적대적 평판 필요",
	["-1"] = ": 약간 적대적 평판 필요",
	["0"] = ": 중립적 평판 필요",
	["1"] = ": 약간 우호적 평판 필요",
	["2"] = ": 우호적 평판 필요",
	["3"] = ": 매우 우호적 평판 필요",
	["4"] = ": 확고한 동맹 평판 필요",
}

local cnames, tokenSplit, skipCode, dCacheText, pdCacheText, dropCode, itemTextCode, dorpType, detail, detail2, detail3, detail4, dorpText = {}, {}

function BlueItemInfo2:GetItemDropText(itemID, force, ...)
	if select(1, ...) then
		for i = 1, select('#', ...) do
			dropType, detail = select(i, ...):match("([A-Z|a-z])_(.+)")
			if dropType then
				pdCacheText = dCacheText
				dropText, dCacheText = nil
				if dropType == "D" or dropType == "B" then
					-- 5인 던전(일반)
					cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
					if cnames[1] and cnames[2] then
						dropText = ("cN%s cW%s"):format(cnames[1], cnames[2])
						if dropType == "D" then
							dCacheText = ("cN%s cW"):format(cnames[1])
						end
					end
				elseif dropType == "H" then
					-- 5인 던전(영웅)
					cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
					if cnames[1] and cnames[2] then
						dropText = ("cNcH%s(영웅) %s"):format(cnames[1], cnames[2])
						dCacheText = ("cNcH%s(영웅) "):format(cnames[1])
					end
				elseif dropType == "R" then
					if self.data.itemDB[itemID] then
						-- 공격대 던전(10인)
						cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
						if cnames[1] and cnames[2] then
							dropText = ("cNcR%s(10인) %s"):format(cnames[1], cnames[2])
							dCacheText = ("cNcR%s(10인) "):format(cnames[1])
						end
					else
						-- 공격대 던전
						cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
						if cnames[1] and cnames[2] then
							dropText = ("cNcR%s cW%s"):format(cnames[1], cnames[2])
							dCacheText = ("cNcR%s cW"):format(cnames[1])
						end
					end
				elseif dropType == "r" then
					-- 공격대 던전(25인)
					cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
					if cnames[1] and cnames[2] then
						dropText = ("cNcR%s(25인) %s"):format(cnames[1], cnames[2])
						dCacheText = ("cNcR%s(25인) "):format(cnames[1])
					end
				elseif dropType == "A" then
					-- 투기장
					detail, detail2, detail3 = ("@"):split(detail)
					cnames[1], cnames[2] = select(2, self:GetCategoryName(detail))
					if cnames[1] and cnames[2] then
						detail4 = cnames[1]:match("(%d+)")
						if detail2 then
							if detail2:find("*") then
								dropText = ("cNcA%s점, cO%s점"):format(("*"):split(detail2))
							else
								dropText = ("cNcA%s점"):format(detail2)
							end
							if detail3 then
								dropText = ("%s, cI개인평점 %s점"):format(dropText, detail3)
							end
							if detail4 then
								dropText = ("%s, cW시즌 %s"):format(dropText, detail4)
							end
						elseif detail4 then
							dropText = ("cNcAcW시즌 %s"):format(detail4)
						end
					end
				elseif dropType == "O" then
					-- 명예 아이템
					detail, detail2, detail3, detail4 = ("@"):split(detail)
					if detail3 and detail3 ~= "" then
						if detail4 then
							dropText = ("cNcO%s점 cW%s), cI개인평점 %s점"):format(detail2, detail3, detail4)
						elseif detail3:match("(%d+)") == detail3 then
							dropText = ("cNcO%s점, cI개인평점 %s점"):format(detail2, detail3)
						else
							dropText = ("cNcO%s점, cW%s점)"):format(detail2, detail3)
						end
					elseif detail3 == "" and detail4 then
						dropText = ("cNcO%s점, cI개인평점 %s점"):format(detail2, detail4)
					else
						dropText = ("cNcO%s점"):format(detail2)
					end
				elseif dropType == "o" then
					-- 명예 아이템2
					detail, detail2, detail3, detail4 = ("@"):split(detail)
					if detail2 and detail3 then
						if detail4 then
							dropText = ("cNcO%s점, cA%s점, cI개인평점 %s점"):format(detail2, detail3, detail4)
						else
							dropText = ("cNcO%s점, cA%s점"):format(detail2, detail3)
						end
					end
				elseif dropType == "J" then
					-- 정의의 휘장
					detail, detail2 = ("@"):split(detail)
					if detail2 then
						dropText = ("cNcI정의의 휘장(%s)"):format(detail2)
					end
				elseif dropType == "Y" then
					-- 용맹의 문장
					detail, detail2 = ("@"):split(detail)
					if detail2 then
						dropText = ("cNcI용맹의 문장(%s)"):format(detail2)
					end
				elseif dropType == "M" then
					-- 무용의 문장
					detail, detail2 = ("@"):split(detail)
					if detail2 then
						dropText = ("cNcI무용의 문장(%s)"):format(detail2)
					end
				elseif dropType == "U" then
					-- 정복의 문장
					detail, detail2 = ("@"):split(detail)
					if detail2 then
						dropText = ("cNcI정복의 문장(%s)"):format(detail2)
					end
				elseif dropType == "K" then
					-- 바위 문지기의 조각
					detail, detail2 = ("@"):split(detail)
					if detail2 then
						dropText = ("cNcI바위 문지기의 조각(%s)"):format(detail2)
					end
				elseif dropType == "V" then
					-- 승전의 문장
					detail, detail2, detail3 = ("@"):split(detail)
					if detail2 then
						if detail3 then
							dropText = ("cNcI승전의 문장(%s) + cI%s"):format(detail2, detail3)
						else
							dropText = ("cNcI승전의 문장(%s)"):format(detail2)
						end
					end
				elseif dropType == "S" then
					-- 세트 아이템
					detail = select(2, self:GetCategoryName(detail))
					if detail then
						dropText = ("cQ|cffeaeaea%s"):format(detail)
					end
				elseif dropType == "T" then
					-- 평판 아이템
					detail, detail2 = ("@"):split(detail)
					detail3 = select(2, self:GetCategoryName(detail))
					if detail3 and reputation[detail3] then
						dropText = ("cNcT%scW%s"):format(detail3, eputation[detail3])
					end
				elseif dropType == "Q" then
					-- 퀘스트
					detail, detail2, detail3, detail4 = ("@"):split(detail)
					cnames[1] = select(3, self:GetCategoryName(detail))
					if cnames[1] and detail2 then
						dropText = ("cN|cffbfefff%s |cff9ac0cd%s\ncQ[%s] %s"):format(cnames[1], detail2, detail3, detail4)
					end
				elseif dropType == "W" then
					dropText = "cN월드 드랍"
				elseif dropType == "C" then
					dropText = ("cN%s"):format(detail)
				elseif dropType == "X" then
					skipCode = (skipCode and (skipCode.."\n") or "")..("cN%s"):format(detail)
				elseif dropType == "s" then
					detail = tonumber(detail:match("(%d+)") or "")
					if type(detail) == "number" then
						dropText = TokenCache[detail] or "cN드랍 미확인 (cI미확인 아이템cW)"
					end
				elseif dropType == "n" then
					TokenNameCache[itemID] = detail
				end
				if dropText then
					if dCacheText then
						dCacheText = dCacheText:gsub("%(", "%%(")
						dCacheText = dCacheText:gsub("%)", "%%)")
						if pdCacheText == dCacheText then
							dropText = dropText:gsub(dCacheText, ", ")
						end
					end
					itemTextCode = (itemTextCode and (itemTextCode.."\n") or "")..dropText
				end
			end
		end
		if skipCode then
			itemTextCode = skipCode
		elseif itemTextCode then
			itemTextCode = itemTextCode:gsub("\n,", ",")
			itemTextCode = itemTextCode:gsub("%(", "cW(")
		else
			itemTextCode = ""
		end
		if TokenNameCache[itemID] then
			TokenCache[itemID] = nil
			if itemTextCode ~= "" then
				tokenSplit = { ("\n"):split(itemTextCode) }
				for _, v in ipairs(tokenSplit) do
					if v:find("^cN") then
						TokenCache[itemID] = ("%s%s cW(cI%scW)"):format(TokenCache[itemID] and (TokenCache[itemID].."\n") or "", v, TokenNameCache[itemID])
					end
				end
				for p in pairs(tokenSplit) do
					tokenSplit[p] = nil
				end
			end
		end
		if not force and itemTextCode ~= "" then
			for p, v in pairs(swich) do
				itemTextCode = itemTextCode:gsub(p, v)
			end
		end
		if type(self:GetItemData(itemID)) == "string" then
			cache[itemID] = itemTextCode
		elseif type(self:GetItemData(itemID)) == "number" then
			if itemTextCode == "" then
				cache[itemID] = ""
			else
				cache[self:GetItemData(itemID)] = itemTextCode
				cache[itemID] = self:GetItemData(itemID)
			end
		end
		skipCode, dCacheText, pdCacheText, dropCode, itemTextCode, dorpType, detail, detail2, detail3, detail4, dorpText = nil
		cnames[1], cnames[2], cnames[3] = nil
	end
	return nil
end

function BlueItemInfo2:CheckCategoryCode(c)
	if type(c) == "string" and c:len() == 3 and c:match("^[A-Z|0-9|a-z][0-9|a-z][0-9|a-z]$") and self.data.categoryCode[c] then
		return true
	end
	return nil
end

local itemCodeString, isSideFaction

function BlueItemInfo2:GetItemText(id, force)
	if id then
		if not cache[id] then
			itemCodeString = self:GetItemRealText(id, force)
			if itemCodeString then
				itemCodeString = "|"..itemCodeString
				if itemCodeString:find("|s_(%d+)") then
					itemCodeString = tonumber(itemCodeString:match("|s_(%d+)"))
					if itemCodeString then
						if not TokenCache[itemCodeString] then
							self:GetItemDropText(itemCodeString, force or nil, ("|"):split(self:GetItemRealText(itemCodeString, force) or ""))
						end
					end
				end
			else
				return nil
			end
			self:GetItemDropText(id, force or nil, ("|"):split(self:GetItemRealText(id, force) or ""))
		end
		if cache[id] then
			if type(cache[id]) == "string" then
				return cache[id]
			elseif type(cache[id]) == "number" and type(cache[cache[id]]) == "string" then
				return cache[cache[id]]
			end
		end
	end
	return nil
end

function BlueItemInfo2:ClearCache()
	for p in pairs(cache) do
		cache[p] = nil
	end
	for p in pairs(TokenNameCache) do
		TokenNameCache[p] = nil
		TokenCache[p] = nil
	end
end

function BlueItemInfo2:OnTooltipUpdate()
	GameTooltip:AddLine("BlueItemInfo2")
	GameTooltip:AddLine("좌클릭: UI창 토글", 0.2, 1, 0.2)
	GameTooltip:AddLine("우클릭: 설정", 0.2, 1, 0.2)
end

function BlueItemInfo2:GetItemInfo(id)
	if not id then return end
	if id > 0 then
		itemName, itemLink, itemRarity = GetItemInfo(id)
		itemTexture = GetItemIcon(id)
		if itemTexture == nil or itemTexture == "" then
			itemTexture = "Interface\\Icons\\INV_Misc_QuestionMark"
		end
		if itemName then
			return itemName, format("%s%s|r", select(4, GetItemQualityColor(itemRarity)) or "", itemName), itemLink, itemTexture
		else
			return nil, nil, nil, itemTexture
		end
	elseif id < 0 then
		id = -id
		itemName, _, itemRarity = GetSpellInfo(id)
		if itemName then
			if itemRarity == nil or itemRarity == "" or itemRarity == "Interface\\Icons\\Temp" then
				itemRarity = "Interface\\Icons\\Spell_Holy_GreaterHeal"
			end
			return itemName, format("|cffffd000%s|r", itemName), GetSpellLink(id), itemRarity
		else
			return nil, nil, nil, "Interface\\Icons\\INV_Misc_QuestionMark"
		end
	end
end

function BlueItemInfo2:GetItemData(id)
	if id then
		return self.data.itemDB[id] or self.data.itemDB1[id] or self.data.itemDB0[id]
	end
	return nil
end

function BlueItemInfo2:GetItemCode(id)
	for i = 1, 3 do
		id = self:GetItemData(id)
		if type(id) == "string" then
			return id:trim()
		end
	end
	return nil
end

function BlueItemInfo2:GetItemRealText(id, force)
	if self:GetItemData(id) and (id > 0 or (id < 0 and GetSpellInfo(-id))) then
		id = self:GetItemCode(id)
		if type(id) == "string" then
			if force then
				id = id:gsub("^v|", "")
				id = id:gsub("^a|", "")
				id = id:gsub("^h|", "")
				return id
			else
				if id:find("^v|") then
					if self.data.cver == self.data.nver or self.data.cver == ("0"..self.data.nver:sub(2)) then
						id = id:sub(3)
					else
						return nil
					end
				end
				if id:find("^a|") then
					return self.factionGroup == "A" and id:sub(3) or nil
				elseif id:find("^h|") then
					return self.factionGroup == "H" and id:sub(3) or nil
				else
					return id
				end
			end
		end
	end
	return nil
end

function BlueItemInfo2:GetCategory(code)
	code = code or BlueItemInfo2DB.category
	return code:sub(1, 1), code:sub(2, 2), code:sub(3, 3)
end

local categroyNames = {}, {}

function BlueItemInfo2:GetCategoryName(code)
	if code and self.data.categoryCode[code] then
		categroyNames[1], categroyNames[2], categroyNames[3] = ("_"):split(self.data.categoryCode[code:sub(1, 2).."0"])
		if code:sub(3, 3) ~= "0" then
			categroyNames[3] = self.data.categoryCode[code]
		end
		return categroyNames[1], categroyNames[2] or "", categroyNames[3] or ""
	end
	return nil, nil, nil
end

local tooltip = CreateFrame("GameTooltip", "BlueItemInfoTooltip", BlueItemInfo2, "GameTooltipTemplate")
tooltip.cache = {}
tooltip.firstLine = _G[tooltip:GetName().."TextLeft1"]
tooltip.GetFirstLine = function(self)
	if self.firstLine:IsShown() then
		self.firstLineText = self.firstLine:GetText()
		if self.firstLineText and self.firstLineText ~= "" then
			return self.firstLineText
		end
	end
	return nil
end

function BlueItemInfo2:GetLinkFirstText(link)
	if link then
		if not tooltip.cache[link] then
			tooltip:SetOwner(self, "ANCHOR_NONE")
			tooltip:SetHyperlink(link)
			tooltip:Show()
			tooltip.cache[link] = tooltip:GetFirstLine() or true
			tooltip:Hide()
		end
		return type(tooltip.cache[link]) == "string" and tooltip.cache[link] or nil
	else
		return nil
	end
end

function BlueItemInfo2:GetItemCache(itemID)
	if itemID and itemID ~= "" then
		local itemLink = "item:"..itemID
		if GetItemInfo(itemLink) then
			self:PrintItem(itemLink)
		elseif GetItemIcon(itemLink) then
			tooltip:SetOwner(self, "ANCHOR_NONE")
			tooltip:SetHyperlink(itemLink)
			tooltip:Hide()
			self:ScheduleEvent("BlueItemInfoPrintItem", "PrintItem", 1, self, itemLink)
		else
			ChatFrame1:AddMessage("|cffFFFF7F[BlueItemInfo2]|r "..itemID..": 서버에 존재하지 않습니다.")
		end
	end
end

function BlueItemInfo2:PrintItem(link)
	if link then
		local itemName, itemLink = GetItemInfo(link)
		local itemID = (link..":"):match("item:(%d+):")
		local head = "|cffFFFF7F[BlueItemInfo2]|r "..itemID..": "
		if itemName then
			itemID = select(3, itemLink:find("item:(%d+):"))
			ChatFrame1:AddMessage(head..itemLink)
		else
			ChatFrame1:AddMessage(head.."서버에 존재하지 않습니다.")
		end
	end
end
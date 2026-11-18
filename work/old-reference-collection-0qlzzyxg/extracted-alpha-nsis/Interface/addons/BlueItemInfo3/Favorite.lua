local addOnName = ...
local _G = _G
local pairs = _G.pairs
local select = _G.select
local floor = _G.math.floor
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local BII3 = _G[addOnName]

local LBI = LibStub("LibBlueItem-1.0")

local indexTable1 = {
	INVTYPE_2HWEAPON = 0,
	INVTYPE_WEAPONMAINHAND = 1,
	INVTYPE_WEAPON = 1,
	INVTYPE_WEAPONOFFHAND = 2,
	INVTYPE_HOLDABLE = 2,
	INVTYPE_SHIELD = 2,
	INVTYPE_CLOAK = 7,
	INVTYPE_NECK = 8,
	INVTYPE_FINGER = 9,
	INVTYPE_TRINKET = "a",
	[select(2, GetAuctionItemSubClasses(2))] = 3,	-- 천
	[select(3, GetAuctionItemSubClasses(2))] = 4,	-- 가죽
	[select(4, GetAuctionItemSubClasses(2))] = 5,	-- 사슬
	[select(5, GetAuctionItemSubClasses(2))] = 6,	-- 판금
	[select(3, GetAuctionItemSubClasses(1))] = 0,	-- 활류
	[select(4, GetAuctionItemSubClasses(1))] = 0,	-- 총기류
	[select(15, GetAuctionItemSubClasses(1))] = 0,	-- 석궁류
	[select(16, GetAuctionItemSubClasses(1))] = 1,	-- 마법봉류
	[select(8, GetAuctionItemClasses())] = "b",		-- 보석
}
local indexTable2 = {
	[select(9, GetAuctionItemSubClasses(1))] = 1,	-- 양손 도검류
	[select(6, GetAuctionItemSubClasses(1))] = 2,	-- 양손 둔기류
	[select(2, GetAuctionItemSubClasses(1))] = 3,	-- 양손 도끼류
	[select(7, GetAuctionItemSubClasses(1))] = 4,	-- 장창류
	[select(10, GetAuctionItemSubClasses(1))] = 5,	-- 지팡이류
	[select(3, GetAuctionItemSubClasses(1))] = 6,	-- 활류
	[select(4, GetAuctionItemSubClasses(1))] = 7,	-- 총기류
	[select(15, GetAuctionItemSubClasses(1))] = 8,	-- 석궁류
	[select(8, GetAuctionItemSubClasses(1))] = 1,	-- 한손 도검류
	[select(5, GetAuctionItemSubClasses(1))] = 2,	-- 한손 둔기류
	[select(1, GetAuctionItemSubClasses(1))] = 3,	-- 한손 도끼류
	[select(13, GetAuctionItemSubClasses(1))] = 4,	-- 단검류
	[select(11, GetAuctionItemSubClasses(1))] = 5,	-- 장착 무기류
	[select(16, GetAuctionItemSubClasses(1))] = 6,	-- 마법봉류
	INVTYPE_SHIELD = 6,
	INVTYPE_HOLDABLE = 7,
	INVTYPE_HEAD = 1,
	INVTYPE_SHOULDER = 2,
	INVTYPE_CHEST = 3,
	INVTYPE_ROBE = 3,
	INVTYPE_HAND = 4,
	INVTYPE_LEGS = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_WRIST = 7,
	INVTYPE_FEET = 8,
}

local name, rarity, mainType, subType, equipLoc, list, cate1, cate2, _
local removeItem = "%s|1이;가; 즐겨찾기(%s)에서 삭제되었습니다."
local insertItem = "%s|1이;가; 즐겨찾기(%s)에 추가되었습니다."

local function refreshList(index, link, form)
	if BII3:CreateFavorite(index) then
		if BII3:IsVisible() then
			BII3:Update(true)
		else
			BII3.forceRefresh = true
		end
	end
	cate1, cate2 = select(2, BII3:GetCategoryName("A"..index))
	if index:find("0$") then
		DEFAULT_CHAT_FRAME:AddMessage(form:format(link, cate1))
	else
		DEFAULT_CHAT_FRAME:AddMessage(form:format(link, cate1.." > "..cate2))
	end
	cate1, cate2 = nil
end

local favoriteCache = {}

function BII3:UpdateFavorite()
	self.UpdateFavorite = nil
	for a, b in pairs(self.favoriteDBTable) do
		if b[1] then
			for c, d in pairs(b) do
				for id in pairs(self.chardb.favorite2[a][c]) do
					favoriteCache[id] = a..c
				end
			end
		else
			for id in pairs(self.chardb.favorite2[a]) do
				favoriteCache[id] = a.."0"
			end
		end
	end
end

function BII3:IsFavorite(id)
	return favoriteCache[self.linkedItemID[id] or id]
end

function BII3:AddFavorite(id)
	id = self.linkedItemID[id] or id
	local originalID = select(2, LBI:GetItemIDAndBonusID(id))
	if type(id) == "number" and id == floor(id) and id ~= 0 and id ~= 1 then
		if favoriteCache[id] then
			name, favoriteCache[id] = favoriteCache[id]
			cate1, cate2 = name:sub(1, 1), name:sub(2, 2)
			cate1 = tonumber(cate1) or cate1
			if cate2 == "0" then
				self.chardb.favorite2[cate1][id] = nil
			else
				self.chardb.favorite2[cate1][tonumber(cate2) or cate2][id] = nil
			end
			refreshList(name, self:GetItemLink(id) or self:GetItemColorName(id), removeItem)
			if self.itemNameDB[id] and not self.itemDB[id] then
				self.itemNameDB[id] = nil
			end
			name, cate1, cate2 = nil
		elseif id > 0 and GetItemInfo(originalID) then
			_, _, _, _, mainType, subType, _, equipLoc = select(2, GetItemInfo(originalID))
			name = self:GetItemLink(id)
			cate1 = indexTable1[equipLoc] or indexTable1[mainType] or indexTable1[subType]
			if self.favoriteDBTable[cate1] then
				if self.favoriteDBTable[cate1][1] then
					cate2 = indexTable2[equipLoc] or indexTable2[mainType] or indexTable2[subType]
					if self.favoriteDBTable[cate1][cate2] then
						self.chardb.favorite2[cate1][cate2][id] = true
					else
						self.chardb.favorite2.e[id] = true
						cate1, cate2 = "e", 0
					end
				else
					self.chardb.favorite2[cate1][id] = true
					cate2 = 0
				end
			else
				self.chardb.favorite2.e[id] = true
				cate1, cate2 = "e", 0
			end
			favoriteCache[id] = cate1..cate2
			refreshList(favoriteCache[id], name, insertItem)
			name, mainType, subType, equipLoc, cate1, cate2 = nil
		elseif id < 0 and GetSpellInfo(-id) then
			name = self:GetItemLink(id)
			if name then
				if name:find("enchant:") then
					self.chardb.favorite2.c[id] = true
					favoriteCache[id] = "c0"
					refreshList("c0", name, insertItem)
				else
					self.chardb.favorite2.d[id] = true
					favoriteCache[id] = "d0"
					refreshList("d0", name, insertItem)
				end
				name = nil
			end
		end
	end
end

function BII3:CreateFavorite(index, noall)
	if self.itemList then
		cate1, cate2 = index:sub(1, 1), index:sub(2, 2)
		cate1 = tonumber(cate1) or cate1
		list = nil
		if cate2 == "0" then
			for id in pairs(self.chardb.favorite2[cate1]) do
				list = (list and (list.."/") or "!")..id
			end
		else
			if not noall then
				for _, a in pairs(self.chardb.favorite2[cate1]) do
					for id in pairs(a) do
						list = (list and (list.."/") or "!")..id
					end
				end
				self.itemList["A"..cate1.."0"], list = list or ""
			end
			cate2 = tonumber(cate2) or cate2
			for id in pairs(self.chardb.favorite2[cate1][cate2]) do
				list = (list and (list.."/") or "!")..id
			end
		end
		self.itemList["A"..index], list = list or ""
		return true
	end
	return nil
end
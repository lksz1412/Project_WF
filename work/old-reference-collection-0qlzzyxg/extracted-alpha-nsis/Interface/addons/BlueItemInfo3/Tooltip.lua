local _G = _G
local BII3 = _G[...]
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local max = _G.math.max
local wipe = _G.table.wipe
local GetItemCount = _G.GetItemCount
local GetInventoryItemID = _G.GetInventoryItemID
local GetAchievementInfo = _G.GetAchievementInfo
local tooltipText, tooltipText2, totalCount, invCount, bagCount, bankCount, countText, invItemID, isFavorite, _
local cache = { [0] = "|cff64cd3c▶|cffffffff"..RACE_CLASS_ONLY:format(BII3.isHorde and FACTION_ALLIANCE or FACTION_HORDE).."|r" }
local equipCache, subCache = {}, {}
local setAll, output, output2, set
local add_format = "|cff64cd3c%s|r%s%s|r"
local sub_format = "|cff64cd3c▶|r%s |cffffffff%s|r"
local unknown = "|cff64cd3c▶|r|cffff5d5d획득처 미확인|r"
local fontString = BII3:CreateFontString(nil, "OVERLAY", "GameTooltipText")
fontString:SetWidth(0)

local LBI = LibStub("LibBlueItem-1.0")

local function addOutput(text, small, color)
	color = color or "|cffffffa4"
	text = text:gsub("_COLOR_", color)
	text = add_format:format(small and "▷" or "▶", color, text)
	if output then
		output = output.."\n"..text
	else
		output = text
	end
end

local function addSub(d, c1, c2)
	if c1 and c2 then
		if d then
			if c1:find("%)") then
				c1 = c1:gsub("%)", " "..d..")", 1)
			else
				c1 = c1.."("..d..")"
			end
		end
		if subCache[c1] then
			subCache[c1] = subCache[c1]..", "..c2
		else
			subCache[c1] = c2
		end
	end
end

local function replaceCategory2nd(text)
	if text:find("$C[A-Z0-9a-z][0-9a-z][0-9a-z]") then
		local c = text:match("$C([A-Z0-9a-z][0-9a-z][0-9a-z])")
		local n = select(2, BII3:GetCategoryName(c)) or c
		if n ~= c then
			n = n:gsub("%((%d+)인%)", "")
			if not n:find("|r") then
				n = "_COLOR_"..n.."|r"
			end
		end
		text = text:gsub("$C"..c, n)
		return replaceCategory2nd(text)
	else
		return text
	end
end

local function replaceCategory3rd(text)
	if text:find("$c[A-Z0-9a-z][0-9a-z][0-9a-z]") then
		local c = text:match("$c([A-Z0-9a-z][0-9a-z][0-9a-z])")
		text = text:gsub("$c"..c, select(3, BII3:GetCategoryName(c)) or c)
		return replaceCategory3rd(text)
	else
		return text
	end
end

local function replaceItemName(text)
	if text:find("$i(%d+)") then
		local c = text:match("$i(%d+)")
		text = text:gsub("$i"..c, BII3:GetItemColorName(tonumber(c) or 0))
		return replaceItemName(text)
	else
		return text
	end
end

local function replacePostposition(text, p1, p2)
	local s, e = text:find(p1)
	if s then
		return ("%s"..p2.."%s"):format(text:sub(1, s - 1), text:sub(e + 1))
	end
	return text
end

local function replaceText(text)
	text = BII3:ReplaceFactionText(text)
	text = replaceCategory2nd(text)
	text = replaceCategory3rd(text)
	text = replaceItemName(text)
	text = replacePostposition(text, "<으로>", "|1으로;로;")
	text = replacePostposition(text, "<이가>", "|1이;가;")
	text = replacePostposition(text, "<을를>", "|1을;를;")
	text = text:gsub("$w", "|cffffffff")
	text = text:gsub("%(", "|cffffffff(")
	text = text:gsub("$r", "|cffff2020")
	return text
end

local function getCache(id)
	if type(cache[id]) == "string" then
		return cache[id]
	elseif type(cache[id]) == "number" and type(cache[cache[id]]) == "string" then
		return cache[cache[id]]
	else
		return nil
	end
end

local function parserInfo(dtype, dtext)
	if dtype then
		if dtype == "X" then
			-- 강제 툴팁
			setAll, output = true
			addOutput(replaceText(dtext))
			wipe(subCache)
			return true
		elseif dtype == "C" then
			-- 추가 툴팁 (분류 2 사용)
			addOutput(replaceText(dtext))
		elseif dtype == "c" then
			-- 추가 툴팁 (분류 3 사용)
			addOutput(replaceText(dtext), true, "|cff76eec6")
		elseif dtype == "R" or dtype == "D" then
			-- 일반 난이도 던전/레이드 툴팁
			addSub(nil, select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "r" then
			-- 영웅 난이도 레이드 툴팁
			addSub("영웅", select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "M" then
			-- 신화 난이도 레이드 툴팁
			addSub("신화", select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "F" then
			-- 탄력적 공격대 난이도 레이드 툴팁
			addSub("탄력적 공격대", select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "f" then
			-- 공격대 찾기 난이도 툴팁
			addSub("공격대 찾기", select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "d" then
			-- 영웅 난이도 던전 툴팁
			addSub("영웅", select(2, BII3:GetCategoryName(dtext)))
		elseif dtype == "A" then
			-- 업적 툴팁
			local id, desc = select(2, ("@"):split(dtext))
			if id then
				id = tonumber(id)
				if GetAchievementLink(id) then
					local name, _, _, _, _, _, desc2, _, _, _, isGuild = select(2, GetAchievementInfo(id))
					if name then
						if isGuild then
							addOutput(replaceText("길드 업적 $w"..name))
						else
							addOutput(replaceText("업적 $w"..name))
						end
						if desc then
							addOutput(desc, true, "|cff76eec6")
						elseif desc2 then
							addOutput(desc2, true, "|cff76eec6")
						end
					end
				end
			end
		elseif dtype == "S" then
			-- 세트 툴팁
			dtext = select(2, BII3:GetCategoryName(dtext))
			if dtext then
				addOutput(dtext, true, "|cffffffff")
			end
		elseif dtype == "s" then
			dtype, dtext = ("@"):split(dtext)
			dtype = dtype and tonumber(dtype) or nil
			set = dtype and getCache(dtype) or unknown
			if set then
				dtype = BII3:GetItemColorName(dtype)
				if dtext then
					dtype = dtype.." + "..replaceText(dtext)
				end
				dtype = " ("..dtype..")"
				set = set:gsub("\n", dtype.."\n")..dtype
				if output then
					output = output.."\n"..set
				else
					output = set
				end
			end
		elseif dtype == "Q" then
			-- 퀘스트 툴팁
			local code, zone, level, name = ("@"):split(dtext)
			if code and name then
				code = select(3, BII3:GetCategoryName(code))
				if code then
					addOutput(code.."|r |cff9ac0cd"..BII3:ReplaceFactionText(zone), nil, "|cffbfefff")
					addOutput("["..BII3:ReplaceFactionText(level).."] "..BII3:ReplaceFactionText(name), true, "|cff76eec6")
				end
			end
		end
	end
	return nil
end

local getTooltipText, getItemTooltipText, result

function getTooltipText(text)
	if type(text) == "string" then
		if text:find("s_(%d+)") then
			setAll, output, setoutput = nil
			getItemTooltipText(tonumber(text:match("s_(%d+)")))
		end
		setAll, output, setoutput = nil
		for info in text:gmatch("([^|]+)") do
			if parserInfo(info:match("([A-Za-z])_(.+)")) then
				break
			end
		end
		output2, output = output, nil
		for zone, detail in pairs(subCache) do
			detail = sub_format:format(zone, detail)
			if output then
				output = output.."\n"..detail
			else
				output = detail
			end
			subCache[zone] = nil
		end
		if output2 and output then
			result, output, output2 = output.."\n"..output2
		elseif output then
			result, output = output
		elseif output2 then
			result, output2 = output2
		else
			result = false
		end
		return result
	end
	return false
end

function getItemTooltipText(id)
	if cache[id] ~= nil then
		return getCache(id)
	end
	local itemDB = BII3.itemDB[id]
	if itemDB then
		if type(itemDB) == "number" then
			if type(cache[itemDB]) == "string" then
				cache[id] = itemDB
				return cache[itemDB]
			elseif type(BII3.itemDB[itemDB]) == "string" then
				cache[id] = itemDB
				id = itemDB
				itemDB = BII3.itemDB[itemDB]
			else
				return nil
			end
		elseif type(itemDB) ~= "string" then
			return nil
		end
		if itemDB == "a" or itemDB:find("^a|") then
			if BII3.isHorde then
				cache[id] = 0
				return cache[0]
			else
				itemDB = itemDB:sub(3)
			end
		elseif itemDB == "h" or itemDB:find("^h|") then
			if BII3.isHorde then
				itemDB = itemDB:sub(3)
			else
				cache[id] = 0
				return cache[0]
			end
		end
		cache[id] = getTooltipText(itemDB)
		return cache[id]
	end
	return nil
end

local function getStringWidth(text)
	fontString:SetText(text)
	return fontString:GetWidth()
end

local count_format = "|cff64cd3c▷|cffffff00%s|r"
local memo_format = "|cff64cd3c▷|cffffff00메모: |cffffffff%s|r"

local addTooltip = {}

function BII3:AddTooltip(func)
	tinsert(addTooltip, func)
end

function BII3:GetTooltip(id)
	tooltipText = self.GetMountObtain and self:GetMountObtain(id) or getItemTooltipText(id)
	if self:IsRandomSuffixItem(id) then
		if not (tooltipText and tooltipText:find("무작위 마법부여")) then
			tooltipText = (tooltipText and (tooltipText.."\n") or "")..getTooltipText("c_무작위 마법부여")
		end
	end
	for _, func in ipairs(addTooltip) do
		tooltipText2 = getTooltipText(func(id))
		if tooltipText2 then
			tooltipText = (tooltipText and (tooltipText.."\n") or "")..tooltipText2
		end
	end
	tooltipText2 = nil
	return tooltipText
end

function BII3:ClearCache()
	for p in pairs(cache) do
		if p ~= 0 then
			cache[p] = nil
		end
	end
end

function BII3:ProcessTooltip(tooltip, name, link, id)
	local originalID = id
	id = LBI:GetItemIDWithBonusID(id, link)
	if self.db.drop then
		tooltipText = self:GetTooltip(id)
		if tooltipText then
			if getStringWidth(tooltipText) > 350 then
				tooltip:SetMinimumWidth(max(tooltip:GetMinimumWidth() or 350, 350))
				tooltip:AddLine(tooltipText, 1, 1, 1, 1)
			else
				tooltip:AddLine(tooltipText, 1, 1, 1)
			end
		end
	end
	if self.db.count then
		if originalID > 0 and self:HasItem(originalID) then
			totalCount, bagCount, invCount = GetItemCount(originalID, true) or 0, GetItemCount(originalID) or 0, equipCache[originalID] or 0
			if self.equalItemID[originalID] then
				for _, equal in pairs(self.equalItemID[originalID]) do
					totalCount = totalCount + (GetItemCount(equal, true) or 0)
					bagCount = bagCount + (GetItemCount(equal) or 0)
					invCount = invCount + (equipCache[equal] or 0)
				end
			end
			bankCount = totalCount - bagCount
			bagCount = bagCount - invCount
			if totalCount == 1 then
				if bankCount == 1 then
					tooltip:AddLine(count_format:format("아이템 보유중(은행)"))
				elseif bagCount == 1 then
					tooltip:AddLine(count_format:format("아이템 보유중(가방)"))
				else
					tooltip:AddLine(count_format:format("아이템 착용중"))
				end
			elseif totalCount > 1 then
				countText = ("총 %d개 보유중("):format(totalCount)
				if invCount > 0 then
					countText = ("%s착용 %d"):format(countText, invCount)
				end
				if bagCount > 0 then
					if invCount > 0 then
						countText = ("%s, 가방 %d"):format(countText, bagCount)
					else
						countText = ("%s가방 %d"):format(countText, bagCount)
					end
				end
				if bankCount > 0 then
					if bagCount > 0 or invCount > 0 then
						countText = ("%s, 은행 %d"):format(countText, bankCount)
					else
						countText = ("%s은행 %d"):format(countText, bankCount)
					end
				end
				tooltip:AddLine(count_format:format(countText..")"))
			end
		elseif BII3.HasMount then
			totalCount = BII3:HasMount(id)
			if totalCount then
				tooltip:AddLine(count_format:format(totalCount == 1 and "탈것 보유중" or "애완동물 보유중"))
			end
		end
		totalCount, invCount, bagCount, bankCount, countText = nil
	end
	if self:IsFavorite(id) then
		tooltip:AddLine("|cff64cd3c▷|cffffff5a즐겨찾기 아이템|r")
		if self:SaveItemCache(id, name) and self.enter and tooltip:GetOwner() == self.enter then
			if self.itemList[self.db.code] and not self.itemList[self.db.code]:find("^!") then
				self.itemList[self.db.code] = "!"..self.itemList[self.db.code]
			end
			self:Update(true)
			return
		end
	end
	id = self.linkedItemID[id] or id
	if self.db.memo[id] then
		tooltip:AddLine(memo_format:format(self.db.memo[id]))
	end
end

function BII3:PLAYER_ENTERING_WORLD()
	self:UNIT_INVENTORY_CHANGED()
	if self.COMPANION_LEARNED then
		self:COMPANION_LEARNED()
	end
end

function BII3:UNIT_INVENTORY_CHANGED()
	wipe(equipCache)
	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		invItemID = GetInventoryItemID("player", i)
		if invItemID then
			equipCache[invItemID] = (equipCache[invItemID] or 0) + 1
		end
	end
	invItemID = nil
end

BII3:RegisterEvent("PLAYER_ENTERING_WORLD")
BII3:RegisterEvent("UNIT_INVENTORY_CHANGED")
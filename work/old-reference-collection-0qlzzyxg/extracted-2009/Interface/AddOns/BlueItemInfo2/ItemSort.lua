local itemOrder = {
	["양손 도검류"] = 1, ["양손 둔기류"] = 2, ["양손 도끼류"] = 3, ["장창류"] = 4, ["지팡이류"] = 5, ["한손 도검류"] = 6, ["한손 도끼류"] = 7,
	["한손 둔기류"] = 8, ["단검류"] = 9, ["장착 무기류"] = 10, ["총기류"] = 11, ["활류"] = 12, ["석궁류"] = 13, ["투척 무기류"] = 14,
	["마법봉류"] = 15, ["방패"] = 16, ["천"] = 17, ["가죽"] = 18, ["사슬"] = 19, ["판금"] = 20, ["토템"] = 21, ["우상"] = 22, ["성서"] = 23,
	["보석"] = 24, ["얼개"] = 25, ["붉은색"] = 26, ["노란색"] = 27, ["푸른색"] = 28, ["주황색 (노란+붉은)"] = 29, ["녹색 (노란+푸른)"] = 30,
	["보라색 (붉은+푸른)"] = 31, ["다색"] = 32, ["가방"] = 33, ["제조법"] = 34, ["마법부여"] = 35, ["대장기술"] = 36, ["가죽세공"] = 37,
	["재봉술"] = 38, ["연금술"] = 39, ["기계 공학"] = 40, ["보석세공"] = 41, ["응급치료"] = 42, ["소비용품"] = 43, ["방어구"] = 44,
	["INVTYPE_2HWEAPON"] = 1, ["INVTYPE_WEAPONMAINHAND"] = 2, ["INVTYPE_WEAPON"] = 2, ["INVTYPE_WEAPONOFFHAND"] = 2, ["INVTYPE_SHIELD"] = 5,
	["INVTYPE_RANGEDRIGHT"] = 6, ["INVTYPE_RANGED"] = 6, ["INVTYPE_THROWN"] = 8, ["INVTYPE_HOLDABLE"] = 9, ["INVTYPE_HEAD"] = 10,
	["INVTYPE_SHOULDER"] = 11, ["INVTYPE_CHEST"] = 12, ["INVTYPE_ROBE"] = 12, ["INVTYPE_HAND"] = 13, ["INVTYPE_LEGS"] = 14, ["INVTYPE_WAIST"] = 15,
	["INVTYPE_WRIST"] = 16, ["INVTYPE_FEET"] = 17, ["INVTYPE_CLOAK"] = 18, ["INVTYPE_TRINKET"] = 19, ["INVTYPE_NECK"] = 20, ["INVTYPE_FINGER"] = 21,
	["INVTYPE_RELIC"] = 22,
}
local weaponOrder = { ["INVTYPE_WEAPONMAINHAND"] = 1, ["INVTYPE_WEAPON"] = 2, ["INVTYPE_WEAPONOFFHAND"] = 3 }
local gemOrder = {
	[4] = { [80] = 2, [60] = 1, [70] = 1, [100] = 1, [130] = 1 },
	[3] = { [80] = 2, [75] = 2, [60] = 1, [70] = 1 },
	[2] = { [70] = 2, [60] = 1 },
	[1] = { [55] = 1 },
}

local tonumber = _G.tonumber
local tinsert = _G.table.insert
local sort = _G.sort
local GetItemInfo = _G.GetItemInfo

local pt, ut, ot, et, id
local name1, rarity1, level1, type1, subType1, equipLoc1, el1, name2, rarity2, level2, type2, subType2, equipLoc2, el2

function BlueItemInfo2:SortItemTable(items, mainCate)
	if not items or items[1] == nil then return end
	pt, ut, ot, et = {}, {}, {}, {}
	for i = 1, #(items) do
		id = tonumber(items[i])
		if id then
			if id > 0 then
				local name, _, _, _, _, _, subType, _, equipLoc = GetItemInfo(id)
				if name then
					if equipLoc and itemOrder[equipLoc] then
						tinsert(pt, id)
					else
						tinsert(ot, id)
					end
				else
					tinsert(ut, id)
				end
			else
				tinsert(et, id)
			end
		else
			return nil, nil
		end
	end
	if mainCate == "B" then
		-- 즐겨찾기 정렬
		sort(pt, function(a, b)
			name1, _, rarity1, level1 = GetItemInfo(a)
			name2, _, rarity2, level2 = GetItemInfo(b)
			if rarity1 == rarity2 and level1 == level2 then
				return name1 < name2
			elseif level1 == level2 then
				return rarity1 > rarity2
			else
				return level1 > level2
			end
		end)
	else
		sort(pt, function(a, b)
			name1, _, rarity1, level1, _, _, subType1, _, equipLoc1 = GetItemInfo(a)
			name2, _, rarity2, level2, _, _, subType2, _, equipLoc2 = GetItemInfo(b)
			el1, el2 = equipLoc1, equipLoc2
			equipLoc1, equipLoc2 = itemOrder[equipLoc1], itemOrder[equipLoc2]
			subType1, subType2 = itemOrder[subType1] or 99, itemOrder[subType2] or 99
			if equipLoc1 == equipLoc2 and subType1 == subType2 and rarity1 == rarity2 and level1 == level2 then
				if weaponOrder[el1] and weaponOrder[el2] and el1 ~= el2 then
					return weaponOrder[el1] < weaponOrder[el2]
				end
				return name1 < name2
			elseif equipLoc1 == equipLoc2 and subType1 == subType2 and rarity1 == rarity2 then
				return level1 > level2
			elseif equipLoc1 == equipLoc2 and subType1 == subType2 then
				return rarity1 > rarity2
			elseif equipLoc1 == equipLoc2 then
				return subType1 < subType2
			else
				return equipLoc1 < equipLoc2
			end
		end)
	end
	if mainCate == "c" or mainCate == "f" then
		-- 보석 정렬
		sort(ot, function(a, b)
			name1, _, rarity1, level1, _, _, subType1 = GetItemInfo(a)
			name2, _, rarity2, level2, _, _, subType2 = GetItemInfo(b)
			subType1, subType2 = itemOrder[subType1] or 99, itemOrder[subType2] or 99
			level1, level2 = gemOrder[rarity1][level1] or 1, gemOrder[rarity2][level2] or 1
			if level1 == level2 and rarity1 == rarity2 and subType1 == subType2 then
				if level1 > 1 and rarity1 == 2 then
					if name1:find("^완전무결한 ") then
						if name2:find("^완전무결한 ") then
							return name1 < name2
						else
							return true
						end
					elseif name2:find("^완전무결한 ") then
						return false
					end
				end
				return name1 < name2
			elseif rarity1 == rarity2 and subType1 == subType2 then
				return level1 > level2
			elseif level1 == level2 and rarity1 == rarity2 then
				return subType1 > subType2
			elseif level1 == level2 then
				return rarity1 > rarity2
			else
				return level1 > level2
			end
		end)
	else				-- 일반 정렬
		sort(ot, function(a, b)
			name1, _, rarity1, _, _, type1, subType1 = GetItemInfo(a)
			name2, _, rarity2, _, _, type2, subType2 = GetItemInfo(b)
			subType1, subType2 = itemOrder[subType1] or 99, itemOrder[subType2] or 99
			if type1 == type2 and subType1 == subType2 and rarity1 == rarity2 then
				return name1 < name2
			elseif type1 == type2 and subType1 == subType2 then
				return rarity1 > rarity2
			elseif subType1 == subType2 then
				return type1 > type2
			else
				return subType1 > subType2
			end
		end)
	end
	sort(et, function(a, b)
		return self:GetItemInfo(a) < self:GetItemInfo(b)
	end)
	sort(ut)
	for i = 1, #(ot) do
		tinsert(pt, ot[i])
	end
	for i = 1, #(et) do
		tinsert(pt, et[i])
	end
	for i = 1, #(ut) do
		tinsert(pt, ut[i])
	end
	return pt, #(ut)
end
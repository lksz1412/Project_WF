local addOnName = GetAddOnDependencies(...)
local BII3 = _G[addOnName]

BII3.itemList = { ["A**"] = true }

local _G = _G
local type = _G.type
local pairs = _G.pairs
local unpack = _G.unpack
local tonumber = _G.tonumber
local wipe = _G.table.wipe
local tinsert = _G.table.insert
local GetItemIcon = _G.GetItemIcon
local GetSpellInfo = _G.GetSpellInfo
local GetAddOnMetadata = _G.GetAddOnMetadata

local c, dtype, code = {}
local normal, heroic, findRaid, flexible, mythic = {}, {}, {}, {}, {}
local heroicCategory = "drh"
local findRaidCategory = "f"
local flexibleCategory = "F"
local mythicCategory = "M"
local noCategory = "XCcs"

for a, b in pairs(BII3.favoriteDBTable) do
	BII3.itemList["A"..a.."*"] = true
	if b[1] then
		for c, d in pairs(b) do
			BII3:CreateFavorite(a..c, true)
			if BII3.itemList["A"..a..c] ~= "" then
				BII3.itemList["A"..a.."0"] = (BII3.itemList["A"..a.."0"] and (BII3.itemList["A"..a.."0"].."/") or "!")..BII3.itemList["A"..a..c]:gsub("^!", "")
			end
		end
		BII3.itemList["A"..a.."0"] = BII3.itemList["A"..a.."0"] or ""
	else
		BII3:CreateFavorite(a.."0", true)
	end
end

local function addCategory(id, info)
	if id and type(info) == "string" and (id > 0 or (id < 0 and GetSpellInfo(-id))) then
		if info:find("^a|") and BII3.isHorde then
			-- 플레이어가 호드일 경우 얼라 아이템 무시
		elseif info:find("^h|") and not BII3.isHorde then
			-- 플레이어가 얼라일 경우 호드 아이템 무시
		else
			for v in info:gmatch("([^|]+)") do
				dtype, code = v:match("([A-Z|a-z])_(.+)")
				code = ("@"):split(code or v)
				code = ("*"):split(code)
				if BII3:GetCategory(code) then
					dtype = dtype or "*"
					if heroicCategory:find(dtype) then
						BII3.itemList[code:sub(1, 1).."**"] = true
						BII3.itemList[code:sub(1, 2).."*"] = true
						heroic[code] = heroic[code] or {}
						tinsert(heroic[code], id)
					elseif findRaidCategory:find(dtype) then
						BII3.itemList[code:sub(1, 1).."**"] = true
						BII3.itemList[code:sub(1, 2).."*"] = true
						findRaid[code] = findRaid[code] or {}
						tinsert(findRaid[code], id)
					elseif flexibleCategory:find(dtype) then
						BII3.itemList[code:sub(1, 1).."**"] = true
						BII3.itemList[code:sub(1, 2).."*"] = true
						flexible[code] = flexible[code] or {}
						tinsert(flexible[code], id)
					elseif mythicCategory:find(dtype) then
						BII3.itemList[code:sub(1, 1).."**"] = true
						BII3.itemList[code:sub(1, 2).."*"] = true
						mythic[code] = mythic[code] or {}
						tinsert(mythic[code], id)
					elseif not noCategory:find(dtype) then
						BII3.itemList[code:sub(1, 1).."**"] = true
						BII3.itemList[code:sub(1, 2).."*"] = true
						normal[code] = normal[code] or {}
						tinsert(normal[code], id)
					end
				end
			end
		end
	end
end

for id, info in pairs(BII3.itemDB) do
	addCategory(id, BII3.itemDB[info] or info)
end

local function itemDBParser(id, ...)
	id = tonumber(id)
	if id then
		local info = BII3.itemDB[id]
		if type(info) == "string" then
			addCategory(id, info)
		elseif type(info) == "number" then
			addCategory(id, BII3.itemDB[info])
		end
	end
	if ... then
		itemDBParser(...)
	end
end

BII3.hasDataPacks = {}

local function unpackItemDB(list)
	if list then
		for id in list:gmatch("([^/]+)") do
			id = tonumber(id)
			if id then
				local info = BII3.itemDB[id]
				if type(info) == "string" then
					addCategory(id, info)
				elseif type(info) == "number" then
					addCategory(id, BII3.itemDB[info])
				end
			end
		end
		return true
	else
		return nil
	end
end

for pack, use in pairs(BII3.db.dataPacks) do
	if use then
		use = 1
		while unpackItemDB(GetAddOnMetadata(addOnName.."_"..pack, "X-DB-Items-"..use)) do
			use = use + 1
			BII3.hasDataPacks[pack] = true
		end
	end
end

for code, items in pairs(normal) do
	for i, id in ipairs(items) do
		if i == 1 then
			BII3.itemList[code] = "!="..id
		else
			BII3.itemList[code] = BII3.itemList[code].."/"..id
		end
	end
end

for code, items in pairs(heroic) do
	for i, id in ipairs(items) do
		if i == 1 then
			if BII3.itemList[code] then
				BII3.itemList[code] = BII3.itemList[code].."_"..id
			else
				BII3.itemList[code] = "!_"..id
			end
		else
			BII3.itemList[code] = BII3.itemList[code].."/"..id
		end
	end
end

for code, items in pairs(flexible) do
	for i, id in ipairs(items) do
		if i == 1 then
			if BII3.itemList[code] then
				BII3.itemList[code] = BII3.itemList[code]..";"..id
			else
				BII3.itemList[code] = "!;"..id
			end
		else
			BII3.itemList[code] = BII3.itemList[code].."/"..id
		end
	end
end

for code, items in pairs(mythic) do
	for i, id in ipairs(items) do
		if i == 1 then
			if BII3.itemList[code] then
				BII3.itemList[code] = BII3.itemList[code].."#"..id
			else
				BII3.itemList[code] = "!;"..id
			end
		else
			BII3.itemList[code] = BII3.itemList[code].."/"..id
		end
	end
end

for code, items in pairs(findRaid) do
	for i, id in ipairs(items) do
		if i == 1 then
			if BII3.itemList[code] then
				BII3.itemList[code] = BII3.itemList[code]..":"..id
			else
				BII3.itemList[code] = "!:"..id
			end
		else
			BII3.itemList[code] = BII3.itemList[code].."/"..id
		end
	end
end

normal, heroic, findRaid, itemDBParser, unpackItemDB, heroicCategory, noCategory = nil
wipe(c)

if BII3.AddMountItemList then
	BII3:AddMountItemList()
end

if BII3.isHorde then
	BII3.itemList["n3*"] = nil
else
	BII3.itemList["n5*"] = nil
end

function BII3:UnpackItemList(tbl, list)
	if list and list ~= "" then
		for item in list:gmatch("([^/]+)") do
			tinsert(tbl, tonumber(item) or item)
		end
	end
end

function BII3:SplitList(code)
	if self.itemList[code] then
		normal = self.itemList[code]:match("=([^=_:;#]+)")
		heroic = self.itemList[code]:match("_([^=_:;#]+)")
		flexible = self.itemList[code]:match(";([^=_:;#]+)")
		mythic = self.itemList[code]:match("#([^=_:;#]+)")
		findRaid = self.itemList[code]:match(":([^=_:;#]+)")
		if normal or heroic or flexible or mythic or findRaid then
			return normal, heroic, flexible, mythic, findRaid
		else
			return self.itemList[code]:match("^[!]*([^=_:;#]+)"), nil, nil, nil
		end
	end
end

function BII3:SortItem(code)
	if self.itemList[code]:find("^!") then
		normal, heroic, flexible, mythic, findRaid = self:SplitList(code)
		self:UnpackItemList(c, normal)
		self:Sort(c, code:find("^[B]"))
		self.itemList[code] = "="..(("/"):join(unpack(c)) or "")
		wipe(c)
		self:UnpackItemList(c, heroic)
		self:Sort(c)
		self.itemList[code] = self.itemList[code].."_"..(("/"):join(unpack(c)) or "")
		wipe(c)
		self:UnpackItemList(c, flexible)
		self:Sort(c)
		self.itemList[code] = self.itemList[code]..";"..(("/"):join(unpack(c)) or "")
		wipe(c)
		self:UnpackItemList(c, mythic)
		self:Sort(c)
		self.itemList[code] = self.itemList[code].."#"..(("/"):join(unpack(c)) or "")
		wipe(c)
		self:UnpackItemList(c, findRaid)
		self:Sort(c)
		self.itemList[code] = self.itemList[code]..":"..(("/"):join(unpack(c)) or "")
		wipe(c)
		normal, heroic, findRaid, mythic, flexible = nil
	end
end
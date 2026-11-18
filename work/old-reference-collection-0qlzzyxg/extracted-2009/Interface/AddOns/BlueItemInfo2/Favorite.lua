local _G = getfenv(0)
local tonumber = _G.tonumber
local tinsert = _G.table.insert
local tremove = _G.table.remove
local GetInventoryItemLink = _G.GetInventoryItemLink
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsModifierKeyDown = _G.IsModifierKeyDown
local PlaySound = _G.PlaySound

local favoriteItemCacahe = {}
local orderTable = { ["INVTYPE_2HWEAPON"] = 1, ["INVTYPE_WEAPON"] = 1, ["INVTYPE_WEAPONMAINHAND"] = 1, ["INVTYPE_WEAPONOFFHAND"] = 1, ["INVTYPE_RANGEDRIGHT"] = 1, ["INVTYPE_RANGED"] = 1, ["INVTYPE_THROWN"] = 1, ["INVTYPE_HEAD"] = 2, ["INVTYPE_NECK"] = 3, ["INVTYPE_SHOULDER"] = 2, ["INVTYPE_CLOAK"] = 2, ["INVTYPE_CHEST"] = 2, ["INVTYPE_ROBE"] = 2, ["INVTYPE_WRIST"] = 2, ["INVTYPE_HAND"] = 2, ["INVTYPE_WAIST"] = 2, ["INVTYPE_LEGS"] = 2, ["INVTYPE_FEET"] = 2, ["INVTYPE_TRINKET"] = 3, ["INVTYPE_FINGER"] = 3, ["INVTYPE_RELIC"] = 1, ["INVTYPE_SHIELD"] = 1, ["INVTYPE_HOLDABLE"] = 1 }

local order, colorName, itemType, itemEquipLoc, hasItem, code
local linkID

local function GetItemID(link)
	if type(link) == "string" then
		linkID = link:match("item:(%d+):")
		if linkID then
			return tonumber(linkID)
		else
			linkID = link:match("enchant:(%d+)")
			if linkID then
				return tonumber(-linkID)
			end
		end
	elseif type(link) == "tonumber" then
		return link
	end
end

local function updateGUI()
	if BlueItemInfo2.GUI and BlueItemInfo2.GUI:IsShown() and BlueItemInfo2DB.category:sub(1, 1) == "A" then
		BlueItemInfo2:SetCategory()
	end
end

function BlueItemInfo2:InitFavorite()
	self:CreateFavoriteItemTable()
	self:HookOtherAddons()
end

local function createItems(order)
	code = "A"..(order - 1).."0"
	BlueItemInfo2.data.items[code] = ""
	BlueItemInfo2Char.favorite[order] = BlueItemInfo2Char.favorite[order] or {}
	for _, item in ipairs(BlueItemInfo2Char.favorite[order]) do
		favoriteItemCacahe[tonumber(item)] = true
		if BlueItemInfo2.data.items[code] == "" then
			BlueItemInfo2.data.items[code] = BlueItemInfo2.data.items[code]..item
		else
			BlueItemInfo2.data.items[code] = BlueItemInfo2.data.items[code].."/"..item
		end
	end
end

function BlueItemInfo2:CreateFavoriteItemTable(order)
	if self.data.items then
		self.data.items["A**"] = ""
		BlueItemInfo2Char.favorite = BlueItemInfo2Char.favorite or {}
		if order then
			createItems(order)
		else
			for i = 1, 5 do
				createItems(i)
			end
		end
	end
end

function BlueItemInfo2:AddFavoriteItem(id)
	if id and id ~= 0 then
		colorName = select(2, self:GetItemInfo(id))
		if id > 0 then
			itemType, _, _, itemEquipLoc = select(6, GetItemInfo(id))
			itemEquipLoc = itemEquipLoc or "*"
			if orderTable[itemEquipLoc] then
				order = orderTable[itemEquipLoc]
			elseif itemType == "제조법" then
				order = 4
			else
				order = 5
			end
		else
			order = 4
		end
		BlueItemInfo2Char.favorite[order] = BlueItemInfo2Char.favorite[order] or {}
		hasItem = nil
		for p, v in ipairs(BlueItemInfo2Char.favorite[order]) do
			if v == id then
				hasItem = p
				break
			end
		end
		if hasItem then
			favoriteItemCacahe[id] = nil
			tremove(BlueItemInfo2Char.favorite[order], hasItem)
			DEFAULT_CHAT_FRAME:AddMessage(colorName.."|1이;가; 즐겨찾기에서 삭제되었습니다.")
			PlaySound("igMainMenuOptionCheckBoxOff")
		else
			tinsert(BlueItemInfo2Char.favorite[order], id)
			BlueItemInfo2Char.favorite[order] = self:SortItemTable(BlueItemInfo2Char.favorite[order])
			DEFAULT_CHAT_FRAME:AddMessage(colorName.."|1이;가; 즐겨찾기에 추가되었습니다.")
			PlaySound("igMainMenuOptionCheckBoxOn")
		end
		self:CreateFavoriteItemTable(order)
		updateGUI()
	end
end

function BlueItemInfo2:IsFavoriteItem(itemID)
	return favoriteItemCacahe[itemID]
end

local hook = {}
local hookScript = {}
local dummyFunc = function() end

local function HookScript(method, script, func)
	if method then
		hookScript[method] = hookScript[method] or {}
		hookScript[method][script] = method:GetScript(script) or dummyFunc
		method:SetScript(script, func)
	end
end

local function Hook(method, funcName, newFunc)
	if method and funcName and newFunc then
		hook[method] = 	hook[method] or {}
		hook[method][funcName] = method[funcName]
		method[funcName] = newFunc
	else
		newFunc = funcName
		funcName = method
		hook[funcName] = _G[funcName]
		_G[funcName] = newFunc
	end

end

function BlueItemInfo2:HookOtherAddons()
	local f
	local slotNames = { "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1", "MainHand", "SecondaryHand", "Ranged" }
	local function processItemButton(link, id)
		if type(link) == "string" then
			id = id or GetItemID(link)
			if type(id) == "number" then
				if IsAltKeyDown() then
					BlueItemInfo2:AddFavoriteItem(id)
					return nil
				elseif IsControlKeyDown() and IsShiftKeyDown() then
					BlueItemInfo2:AddMemo(id)
					return nil
				else
					return true
				end
			end
		end
		return true
	end
	-- Examiner
	if Examiner then
		local function examiner_ButtonOnClick(self, button)
			if button == "LeftButton" and processItemButton(self.link, nil) then
				hookScript[self].OnClick(self, button)
			end
		end
		for _, slot in ipairs(slotNames) do
			HookScript(_G["ExaminerItemButton"..slot.."Slot"], "OnClick", examiner_ButtonOnClick)
		end
	-- BlizzardInspect
	else
		local function inspect_ButtonOnClick(self, button)
			if button == "LeftButton" and processItemButton(GetInventoryItemLink(InspectFrame.unit, self:GetID()), nil) then
				if IsModifierKeyDown() then
					HandleModifiedItemClick(GetInventoryItemLink(InspectFrame.unit, self:GetID()))
				else
					SetItemRef(GetInventoryItemLink(InspectFrame.unit, self:GetID()), GetInventoryItemLink(InspectFrame.unit, self:GetID()))
				end
			end
		end
		hooksecurefunc("InspectUnit", function()
			if not (InspectFrame and InspectFrame._blueItemInfoInit) then
				BlueItemInfo2:ScheduleEvent("InspectUnit", function()
					if InspectPaperDollFrame_OnLoad then
						InspectFrame._blueItemInfoInit = true
						for _, slot in ipairs(slotNames) do
							HookScript(_G["Inspect"..slot.."Slot"], "OnClick", inspect_ButtonOnClick)
						end
					end
				end, 2)
			end
		end)
	end
	-- Ludwig
	if LudwigUI_OnItemClick then
		Hook("LudwigUI_OnItemClick", function(self, button)
			if button == "LeftButton" then
				if LudwigDB then
					if processItemButton(LudwigDB:GetItemLink(self:GetID()), nil) then
						hook.LudwigUI_OnItemClick(self, button)
					end
				elseif processItemButton(Ludwig:GetItemLink(self:GetID()), nil) then
					hook.LudwigUI_OnItemClick(self, button)
				end
			else
				hook.LudwigUI_OnItemClick(self, button)
			end

		end)
	end
end
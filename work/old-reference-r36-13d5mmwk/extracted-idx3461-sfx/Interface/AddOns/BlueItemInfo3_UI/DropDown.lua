local addOnName = GetAddOnDependencies(...)
local BII3 = _G[addOnName]

local listInfo = {
	isNotRadio = true,
	notCheckable = true,
	func = function(self, code)
		CloseDropDownMenus(1)
		BII3.db.code = code
		BII3:Update()
	end,
}

local levels = {
	[1] = function()
		listInfo.hasArrow = true
		for j = BII3.codeListZero, BII3.codeListLen do
			if BII3.itemList[listInfo.value..BII3.codeList:sub(j, j).."*"] then
				for k = BII3.codeListZero, BII3.codeListLen do
					if BII3.itemList[listInfo.value..BII3.codeList:sub(j, j)..BII3.codeList:sub(k, k)] then
						listInfo.arg1 = listInfo.value..BII3.codeList:sub(j, j)..BII3.codeList:sub(k, k)
						return
					end
				end
			end
		end
		listInfo.arg1 = nil
	end,
	[2] = function()
		listInfo.hasArrow = BII3:GetCategory(listInfo.value.."0"):find("(.+)_(.+)_(.+)")
		if listInfo.hasArrow then
			for j = BII3.codeListZero, BII3.codeListLen do
				if BII3.itemList[listInfo.value..BII3.codeList:sub(j, j)] then
					listInfo.arg1 = listInfo.value..BII3.codeList:sub(j, j)
					return
				end
			end
			listInfo.arg1 = nil
		else
			listInfo.arg1 = listInfo.value.."0"
		end
	end,
	[3] = function()
		listInfo.hasArrow = nil
		listInfo.arg1 = listInfo.value
	end,
}

local n, star, zero

local rfm, rfmHas = {}
local rfmTitle = { "드레노어의 전쟁군주", "판다리아의 안개", "대격변", "리치 왕의 분노", "불타는 성전", "오리지널" }
local rfmTable = {}

for i = 1, BII3.codeListLen do
	n = BII3.codeList:sub(i, i)
	if BII3.itemList[n.."**"] then
		for j = 1, #rfmTitle do
			if BII3:GetCategoryName(n.."00"):find("^"..rfmTitle[j].." .+") then
				rfm[n] = rfmTitle[j]
				rfmTable[rfmTitle[j]] = rfmTable[rfmTitle[j]] or {}
				tinsert(rfmTable[rfmTitle[j]], n)
				if j > 1 then
					rfmHas = true
				end
				break
			end
		end
	end
end
n = nil

local initializeListDropDown

if rfmHas then
	rfmHas = nil
	local hasTable = {}
	initializeListDropDown = function(self, level)
		if type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
			if UIDROPDOWNMENU_MENU_VALUE == "" then
				for i = 1, BII3.codeListLen do
					n = BII3.codeList:sub(i, i)
					if BII3.itemList[n.."**"] then
						if rfm[n] and #rfmTable[rfm[n]] > 1 then
							if not hasTable[rfm[n]] then
								hasTable[rfm[n]] = true
								listInfo.text = rfm[n]
								listInfo.value = n
								levels[1]()
								listInfo.value = rfm[n]
								UIDropDownMenu_AddButton(listInfo, level)
							end
						else
							listInfo.text = BII3:ClearColor(BII3:GetCategoryName(n.."00"))
							listInfo.value = n
							levels[1]()
							UIDropDownMenu_AddButton(listInfo, level)
						end
					end
				end
				wipe(hasTable)
				n, listInfo.text, listInfo.hasArrow, listInfo.value, listInfo.arg1 = nil
			elseif rfmTable[UIDROPDOWNMENU_MENU_VALUE] then
				for i, v in ipairs(rfmTable[UIDROPDOWNMENU_MENU_VALUE]) do
					listInfo.text = BII3:GetCategoryName(v.."00"):gsub("^"..rfm[v].." ", "")
					listInfo.value = v
					levels[1]()
					UIDropDownMenu_AddButton(listInfo, level)
				end
			else
				n = UIDROPDOWNMENU_MENU_VALUE:len() + 1
				star = ("*"):rep(3 - n)
				zero = ("0"):rep(3 - n)
				for i = BII3.codeListZero, BII3.codeListLen do
					listInfo.value = UIDROPDOWNMENU_MENU_VALUE..BII3.codeList:sub(i, i)
					if BII3.itemList[listInfo.value..star] then
						listInfo.text = BII3:ClearColor(select(n, BII3:GetCategoryName(listInfo.value..zero)))
						levels[n]()
						UIDropDownMenu_AddButton(listInfo, level)
					end
				end
				n, star, zero, listInfo.text, listInfo.hasArrow, listInfo.value, listInfo.arg1 = nil
			end
		end
	end
else
	rfm, rfmTitle, rfmTable = nil
	initializeListDropDown = function(self, level)
		if type(UIDROPDOWNMENU_MENU_VALUE) == "string" then
			n = UIDROPDOWNMENU_MENU_VALUE:len() + 1
			star = ("*"):rep(3 - n)
			zero = ("0"):rep(3 - n)
			for i = n == 1 and 1 or BII3.codeListZero, BII3.codeListLen do
				listInfo.value = UIDROPDOWNMENU_MENU_VALUE..BII3.codeList:sub(i, i)
				if BII3.itemList[listInfo.value..star] then
					listInfo.text = BII3:ClearColor(select(n, BII3:GetCategoryName(listInfo.value..zero)))
					levels[n]()
					UIDropDownMenu_AddButton(listInfo, level)
				end
			end
			n, star, zero, listInfo.text, listInfo.hasArrow, listInfo.value, listInfo.arg1 = nil
		end
	end
end

for i = 1, 3 do
	BII3["listDropdown"..i] = CreateFrame("Frame", addOnName.."ListDropDown"..i, BII3, "UIDropDownMenuTemplate")
	BII3["listDropdown"..i]:SetID(i)
	UIDropDownMenu_Initialize(BII3["listDropdown"..i], initializeListDropDown)
end

local itemInfo = {
	isNotRadio = true,
	notCheckable = true,
	tooltipOnButton = true,
	func = function(self, item, process)
		local id, suffix, unique = BII3:GetItemIDSuffixUnique(item)
		if id then
			if process == 1 then
				if ChatEdit_GetActiveWindow() then
					ChatEdit_GetActiveWindow():SetFocus(true)
					ChatEdit_GetActiveWindow():Insert(BII3:GetItemLink(id, suffix, unique))
				else
					DEFAULT_CHAT_FRAME.editBox:Show()
					DEFAULT_CHAT_FRAME.editBox:SetFocus(true)
					DEFAULT_CHAT_FRAME.editBox:Insert(BII3:GetItemLink(id, suffix, unique))
				end
			elseif process == 2 then
				DressUpItemLink(BII3:GetItemSimpleLink(id))
			elseif process == 3 then
				BII3:AddFavorite(id)
			elseif process == 4 then
				BII3:AddMemo(id)
			end
		end
	end,
}

BII3.itemDropdownMenu = function(self, level)
	if level == 1 then
		if type(UIDROPDOWNMENU_MENU_VALUE) == "number" then
			itemInfo.arg1 = BII3:GetItemSimpleLink(UIDROPDOWNMENU_MENU_VALUE)
		elseif type(UIDROPDOWNMENU_MENU_VALUE) == "string" and BII3:GetLinkID(UIDROPDOWNMENU_MENU_VALUE) then
			itemInfo.arg1 = UIDROPDOWNMENU_MENU_VALUE
		end
		if itemInfo.arg1 then
			itemInfo.text = "채팅창에 링크하기"
			itemInfo.tooltipTitle = "아이템을 채팅창에 링크합니다."
			itemInfo.tooltipText = "Shift+클릭"
			itemInfo.arg2 = 1
			UIDropDownMenu_AddButton(itemInfo, level)
			if itemInfo.arg1:find("item:") then
				itemInfo.text = "미리보기"
				itemInfo.tooltipTitle = "아이템을 미리 입어봅니다."
				itemInfo.tooltipText = "Ctrl+클릭"
				itemInfo.arg2 = 2
				UIDropDownMenu_AddButton(itemInfo, level)
			end
			if BII3:IsFavorite(BII3:GetLinkID(itemInfo.arg1)) then
				itemInfo.text = "즐겨찾기에서 삭제하기"
				itemInfo.tooltipTitle = "아이템을 즐겨찾기에서 삭제합니다."
			else
				itemInfo.text = "즐겨찾기에 추가하기"
				itemInfo.tooltipTitle = "아이템을 즐겨찾기에 추가합니다."
			end
			itemInfo.tooltipText = "Alt+클릭"
			itemInfo.arg2 = 3
			UIDropDownMenu_AddButton(itemInfo, level)
			itemInfo.text = "메모"
			itemInfo.tooltipTitle = "아이템에 메모를 작성합니다."
			itemInfo.tooltipText = "Shift+Ctrl+클릭"
			itemInfo.arg2 = 4
			UIDropDownMenu_AddButton(itemInfo, level)
			itemInfo.tooltipText, itemInfo.tooltipTitle, itemInfo.arg1, itemInfo.arg2 = nil
			itemInfo.text = CLOSE
			UIDropDownMenu_AddButton(itemInfo, level)
			itemInfo.text = nil
		end
	end
end

local randomItemInfo = {
	isNotRadio = true,
	notCheckable = true,
	func = function(self)
		BII3:ItemOnClick(self.tooltipText, "LeftButton")
	end
}

local unique, list

BII3.randomItemDropdownMenu = function(self, level)
	if type(UIDROPDOWNMENU_MENU_VALUE) == "number" then
		list = GetAddOnMetadata(addOnName.."_UI", "X-DB-ItemSuffix-"..UIDROPDOWNMENU_MENU_VALUE)
		if list then
			unique, list = list:match("(%d+)_(.+)")
			if unique then
				unique = tonumber(unique)
				for suffix in list:gmatch("(%d+)") do
					suffix = tonumber(suffix)
					randomItemInfo.text = BII3:GetItemColorName(UIDROPDOWNMENU_MENU_VALUE, suffix)
					randomItemInfo.tooltipTitle = "_hyperlink"
					randomItemInfo.tooltipText = BII3:GetItemSimpleLink(UIDROPDOWNMENU_MENU_VALUE, -suffix, unique)
					UIDropDownMenu_AddButton(randomItemInfo, level)
				end
				randomItemInfo.text, randomItemInfo.tooltipTitle, randomItemInfo.tooltipText = CLOSE
				UIDropDownMenu_AddButton(randomItemInfo, level)
			end
		end
	end
end

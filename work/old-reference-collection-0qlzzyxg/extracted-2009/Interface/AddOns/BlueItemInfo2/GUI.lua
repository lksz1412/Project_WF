local _G = getfenv(0)
local pairs = _G.pairs
local ipairs = _G.ipairs
local tonumber = _G.tonumber
local GetItemInfo = _G.GetItemInfo
local GetItemIcon = _G.GetItemIcon
local GetMouseFocus = _G.GetMouseFocus
local PlaySound = _G.PlaySound
local SetCursor = _G.SetCursor
local CursorUpdate = _G.CursorUpdate
local SetItemButtonTexture = _G.SetItemButtonTexture
local SetItemButtonTextureVertexColor = _G.SetItemButtonTextureVertexColor
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsModifiedClick = _G.IsModifiedClick
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsAltKeyDown = _G.IsAltKeyDown
local itemName, itemColorName, itemLink, itemTexture

local itemCheckTooltip = CreateFrame("GameTooltip", nil, UIParent)

local LDM = LibStub("LibDropMenu-2.0")
local MapButton = LibStub("LibMapButton-1.1")

local simpleLink = strchar(124).."H(.+)"..strchar(124).."h%["
local v36 = "ABC0123456789abcdefghijklmnopqrstuvwxyz"
local v36Table
local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Addons\\BlueItemInfo2\\Texture\\Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

LDM:RegisterMenu("BlueItemInfo2", {
	type = "group",
	icon = BlueItemInfo2.icon,
	name = "Blue Item Info 2",
	args = {
		gui = {
			type = "execute",
			name = "열기/닫기",
			desc = "GUI창을 열고 닫습니다.",
			order = 1,
			func = function() BlueItemInfo2:OnClick() end,
		},
		item = {
			type = "text",
			name = "ID",
			desc = "아이템 ID로 아이템을 확인합니다.",
			order = 2,
			usage = "",
			get = function() return "" end,
			set = function(v) BlueItemInfo2:GetItemCache(v) end,
		},
		show = {
			type = "toggle",
			name = "아이템 획득 경로 표시",
			desc = "툴팁에 아이템의 획득 경로를 표시합니다.",
			order = 3,
			get = function() return BlueItemInfo2DB.info end,
			set = function() BlueItemInfo2DB.info = not BlueItemInfo2DB.info end,
		},
		itemid = {
			type = "toggle",
			name = "아이템 ID 표시",
			desc = "툴팁에 아이템 ID를 표시합니다.",
			order = 4,
			get = function() return BlueItemInfo2DB.id end,
			set = function() BlueItemInfo2DB.id = not BlueItemInfo2DB.id end,
		},
		itemlv = {
			type = "toggle",
			name = "아이템 레벨 표시",
			desc = "툴팁에 아이템 레벨을 표시합니다.",
			order = 5,
			get = function() return BlueItemInfo2DB.level end,
			set = function() BlueItemInfo2DB.level = not BlueItemInfo2DB.level end,
		},
		count = {
			type = "toggle",
			name = "아이템 소지 여부 표시",
			desc = "툴팁에 아이템 소지 여부를 표시합니다.",
			order = 6,
			get = function() return not BlueItemInfo2DB.count end,
			set = function() BlueItemInfo2DB.count = not BlueItemInfo2DB.count end,
		},
		sort = {
			type = "toggle",
			name = "목록내 아이템 정렬",
			desc = "GUI의 아이템 목록에서 아이템을 정렬합니다.",
			order = 7,
			get = function() return BlueItemInfo2DB.sort end,
			set = function() BlueItemInfo2DB.sort = not BlueItemInfo2DB.sort end,
		},
		esc = {
			type = "toggle",
			name = "ESC 창닫기",
			desc = "ESC키로 GUI창을 닫습니다.",
			order = 8,
			get = function() return BlueItemInfo2DB.esc end,
			set = function()
				BlueItemInfo2DB.esc = not BlueItemInfo2DB.esc
				if BlueItemInfo2DB.esc then
					tinsert(UISpecialFrames, "BlueItemInfoGUI")
				else
					for p, v in pairs(UISpecialFrames) do
						if v == "BlueItemInfoGUI" then
							tremove(UISpecialFrames, p)
							break
						end
					end
				end
			end,
		},
		scale = {
			type = "range",
			name = "크기 조절",
			desc = "GUI의 크기를 조절합니다.",
			order = 9,
			get = function() return BlueItemInfo2DB.scale end,
			set = function(v)
				BlueItemInfo2DB.scale = v
				if BlueItemInfo2.GUI then
					BlueItemInfo2.GUI:SetScale(v)
				end
			end,
			min = 0.5,
			max = 1.5,
			step = 0.1,
		},
		backdrop = {
			type = "color",
			name = "배경 색상",
			desc = "UI창의 배경 색상을 설정합니다.",
			order = 10,
			get = function() return unpack(BlueItemInfo2DB.backdrop) end,
			set = function(r, g, b, a)
				BlueItemInfo2DB.backdrop = { r, g, b, a }
				if BlueItemInfo2.GUI then
					BlueItemInfo2.GUI:SetBackdropColor(r, g, b, a)
				end
			end,
			hasAlpha = true,
		},
		mmButton = {
			type = "group",
			name = "미니맵 버튼",
			desc = "미니맵 버튼을 조정합니다.",
			order = 11,
			args = {
				lock = {
					type = "toggle",
					name = "미니맵 버튼 잠금",
					desc = "미니맵 버튼을 잠가 이동시키지 못하게 합니다.",
					order = 1,
					get = function() return not BlueItemInfo2DB.minimapButton.dragable end,
					set = function() BlueItemInfo2DB.minimapButton.dragable = not BlueItemInfo2DB.minimapButton.dragable end,
				},
				toggle = {
					type = "toggle",
					name = "미니맵 버튼 보이기",
					desc = "미니맵 버튼을 보이거나 숨깁니다.",
					order = 2,
					get = function() return BlueItemInfo2DB.minimapButton.show end,
					set = function()
						BlueItemInfo2DB.minimapButton.show = not BlueItemInfo2DB.minimapButton.show
						if MapButton:GetButton(BlueItemInfo2) then
							MapButton:GetButton(BlueItemInfo2):Toggle()
						end
					end,
				},
			},
		},
	},
})

local itemMenu = {
	type = "group", args = {
		link = {
			type = "execute", name = "채팅창에 링크", desc = "아이템을 채팅창에 링크합니다.\nShift+클릭", order = 10,
			func = function(link)
				ChatFrameEditBox:Show()
				ChatFrameEditBox:Insert(link)
				LDM:CloseMenu(1)
			end,
		},
		view = {
			type = "execute", name = "미리보기", desc = "아이템을 미리 입어봅니다.\nCtrl+클릭", order = 20,
			func = function(link)
				DressUpItemLink(itemLink)
				LDM:CloseMenu(1)
			end,
		},
		fav = {
			type = "execute", name = "즐겨찾기 추가/삭제", desc = "아이템을 즐겨찾기에 추가 및 삭제합니다.\nAlt+클릭", order = 30,
			func = function(id)
				BlueItemInfo2:AddFavoriteItem(id)
				LDM:CloseMenu(1)
			end,
		},
		memo = {
			type = "execute", name = "메모", desc = "아이템에 메모를 작성합니다.\nShift+Ctrl+클릭", order = 40,
			func = function(id)
				BlueItemInfo2:AddMemo(id)
				LDM:CloseMenu(1)
			end,
		},
	},
}

local itemIdentiMenu = {
	type = "group", args = {
		ident = {
			type = "execute", name = "미확인 아이템 확인", desc = "미확인 아이템의 정보를 서버로부터 가져옵니다.\n클라이언트가 강제 종료될 수 있습니다.", oder = 10,
			func = function(id)
				itemCheckTooltip:SetOwner(frame, "ANCHOR_NONE")
				itemCheckTooltip:SetHyperlink("item:"..id..":0:0:0:0:0:0:0")
				itemCheckTooltip:Show()
				BlueItemInfo2.GUI.itemUpdater.timer = 4
				LDM:CloseMenu(1)
			end,
		}
	},
}

local function menuClickFunc(code)
	PlaySound("igMainMenuOptionCheckBoxOff")
	LDM:CloseMenu(1)
	BlueItemInfo2:SetCategory(code)
end

function BlueItemInfo2:CreateCategory()
	self.menu = { type = "group", args = {} }
	local code1, code2, code3, name1, name2, name3
	for code, items in pairs(self.data.categoryCode) do
		code1, code2, code3 = self:GetCategory(code)
		if self.data.items[code] or ("ABC"):find(code1) then
			if not(self.menu.args[code1]) then
				name1, name2, name3 = self:GetCategoryName(code1.."00")
				self.menu.args[code1] = {
					type = "group", args = {}, order = ("ABC"):find(code1) or (tonumber(code1, 36) + 4),
					name = code1 == "A" and "즐겨찾기" or name1,
					desc = code1 == "A" and (UnitName("player").."의 즐겨찾기 목록") or (name1.."의 목록"),
					args = {},
				}
			end
			if not(self.menu.args[code1].args[code2]) then
				name1, name2, name3 = self:GetCategoryName(code1..code2.."0")
				self.menu.args[code1].args[code2] = {
					type = "group", order = tonumber(code2, 36) + 1, args = {},
					name = name2, desc = name2.."의 목록",
				}
			end
			name1, name2, name3 = self:GetCategoryName(code)
			if name2 == "" then
				self.menu.args[code1] = {
					type = "execute", order = ("ABC"):find(code1) or (tonumber(code1, 36) + 4),
					name = name1, desc = name1.."의 아이템 목록", arg1 = code, func = menuClickFunc,
				}
			elseif name3 == "" then
				self.menu.args[code1].args[code2] = {
					type = "execute", order = tonumber(code2, 36) + 1,
					name = name2, desc = name2.."의 아이템 목록", arg1 = code, func = menuClickFunc,
				}
			else
				self.menu.args[code1].args[code2].args[code3] = {
					type = "execute", order = tonumber(code3, 36) + 1,
					name = name3, desc = name3.."의 아이템 목록", arg1 = code, func = menuClickFunc,
				}
			end
		elseif BlueItemInfo2DB.category == code then
			BlueItemInfo2DB.category = self.defalutCode
		end
	end
end

function BlueItemInfo2:CreateGUI()
	local scrollbackdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Addons\\BlueItemInfo2\\Texture\\ScrollBar",
		tile = true, tileSize = 16,  edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
	local frame = CreateFrame("Frame", "BlueItemInfoGUI", UIParent)
	self.GUI = frame
	frame.itemFrames = {}
	frame:Hide()
	frame:SetWidth(628)
	frame:SetHeight(BlueItemInfo2DB.height)
	frame:SetPoint(BlueItemInfo2DB.pos[1], UIParent, BlueItemInfo2DB.pos[1], BlueItemInfo2DB.pos[2], BlueItemInfo2DB.pos[3])
	frame:EnableMouse()
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetMinResize(628, 108)
	frame:SetMaxResize(628, 628)
	frame:SetFrameStrata("MEDIUM")
	frame:SetToplevel(true)
	frame:SetBackdrop(backdrop)
	if Skinner then
		Skinner:applySkin(BlueItemInfoGUI, nil, nil, nil, nil, backdrop)
	end
	if BlueItemInfo2DB.esc then
		tinsert(UISpecialFrames, "BlueItemInfoGUI")
	end
	frame:SetBackdropColor(unpack(BlueItemInfo2DB.backdrop))
	frame:SetScript("OnShow", function(self)
		self.itemUpdater.timer = 0
		BlueItemInfo2:RefreshItemList(BlueItemInfo2DB.category)
		PlaySound("igCharacterInfoOpen")
	end)
	frame:SetScript("OnHide", function()
		LDM:CloseMenu(1)
		PlaySound("igCharacterInfoClose")
		BlueItemInfo2.data.enterItemFrame = nil
		collectgarbage()
	end)
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local p, _, _, x, y = self:GetPoint()
		BlueItemInfo2DB.pos = { p, x, y }
	end)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame.icon = CreateFrame("Button", nil, frame)
	frame.icon:SetWidth(18)
	frame.icon:SetHeight(18)
	frame.icon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	frame.icon:SetNormalTexture(self.icon)
	frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
	frame.icon:SetScript("OnClick", function(self)
		if LDM:IsOpen("BlueItemInfo2") then
			PlaySound("igMainMenuOptionCheckBoxOff")
			LDM:CloseMenu(1)
		else
			PlaySound("igMainMenuOptionCheckBoxOn")
			LDM:OpenMenu("BlueItemInfo2", "TOPLEFT", self, "CENTER", 0, 0)
		end
	end)
	frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -7)
	frame.title:SetFormattedText("Blue Item Info 2 |cffffffffv%s|r (%s)", self.version, self.website)
	frame.closebutton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.closebutton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
	frame.dropdowns = {}
	for i = 1, 3 do
		self:CreateDropdownFrame(i)
	end
	frame.dropdowns[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -24)
	frame.dropdowns[2]:SetPoint("LEFT", frame.dropdowns[1], "RIGHT", 0, 0)
	frame.dropdowns[3]:SetPoint("LEFT", frame.dropdowns[2], "RIGHT", 0, 0)
	frame.nolist = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.nolist:SetPoint("CENTER", frame, "CENTER", 0, -20)
	frame.nolist:SetText("|cffffffff아이템 정보가 없습니다.|r")
	frame.nolist:Hide()
	frame.scrollframe = CreateFrame("ScrollFrame", "BlueItemInfo2GUIScroll", frame, "UIPanelScrollFrameTemplate")
	frame.scrollchild = CreateFrame("Frame", "BlueItemInfo2GUIScrollChild", frame.scrollframe)
	frame.scrollframe:SetScrollChild(frame.scrollchild)
	frame.scrollframe:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -50)
	frame.scrollframe:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -27, 5)
	frame.scrollframe:HookScript("OnMouseWheel", function() LDM:CloseMenu(1) end)
	frame.scrollchild:SetWidth(594)
	frame.scrollchild:SetHeight(45)
	for k, v in pairs({ frame.scrollframe:GetRegions() }) do
		if regions then
			for _, r in pairs(regions) do
				if k == r then
					v:SetAlpha(0)
					break
				end
			end
		else
			v:SetAlpha(0)
		end
	end
	frame.scrollbar = BlueItemInfo2GUIScrollScrollBar
	frame.scrollbar:SetBackdrop(scrollbackdrop)
	frame.scrollbar:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
	frame.scrollbar:SetBackdropColor(0.1, 0.1, 0.1, 1)
	frame.sizer = CreateFrame("Frame", nil, frame)
	frame.sizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	frame.sizer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	frame.sizer:SetHeight(10)
	frame.sizer:EnableMouse()
	frame.sizer:SetScript("OnMouseDown", function()
		LDM:CloseMenu(1)
		frame:StartSizing("BOTTOM")
	end)
	frame.sizer:SetScript("OnMouseUp", function()
		frame:StopMovingOrSizing()
		BlueItemInfo2DB.height = frame:GetHeight()
		local p, _, _, x, y = frame:GetPoint()
		BlueItemInfo2DB.pos = { p, x, y }
	end)
	frame:SetScale(BlueItemInfo2DB.scale)
	frame.itemUpdater = CreateFrame("Frame", nil, frame)
	frame.itemUpdater:Hide()
	frame.itemUpdater.timer = 0
	frame.itemUpdater:SetScript("OnUpdate", function(self, timer)
		self.timer = self.timer + timer
		if self.timer >= 5 then
			self.timer, self.check = 0, true
			for p in pairs(BlueItemInfo2.data.unidentifiedItems) do
				self.check = nil
				if GetItemInfo(p) then
					self:Hide()
					return BlueItemInfo2:RefreshItemList(BlueItemInfo2DB.category)
				end
			end
			if self.check then
				self.check = nil
				self:Hide()
			end
		end
	end)
	frame:Show()
	self:SetCategory()
	LDM:RegisterMenu("BlueItemInfo2ItemFrameMenu", itemMenu)
	LDM:RegisterMenu("BlueItemInfo2ItemFrameIdentiMenu", itemIdentiMenu)

end

local function getSpellRealSpellLink(id, link)
	local realName = BlueItemInfo2:GetLinkFirstText(link)
	if realName and realName:find(": ") then
		return ("|cffffd000|Henchant:%d|h[%s]|h|r"):format(id, realName)
	else
		return link
	end
end

local function getSimpleLink(link)
	return link:match(simpleLink) or link
end

function BlueItemInfo2:CreateItemFrame(id)
	self.data.itemframes = max(self.data.itemframes, id)
	self.GUI.itemFrames[id] = CreateFrame("Button", "BlueItemInfo2ItemFrame"..id, self.GUI.scrollchild, "QuestItemTemplate")
	self.GUI.itemFrames[id]:SetID(id)
	self.GUI.itemFrames[id]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self.GUI.itemFrames[id]:SetScript("OnEnter", BlueItemInfo2.ItemFrameOnEnter)
	self.GUI.itemFrames[id]:SetScript("OnLeave", BlueItemInfo2.ItemFrameOnLeave)
	self.GUI.itemFrames[id]:SetScript("OnClick", BlueItemInfo2.ItemFrameOnClick)
	self.GUI.itemFrames[id].text = _G["BlueItemInfo2ItemFrame"..id.."Name"]
	self.GUI.itemFrames[id].highlight = self.GUI.itemFrames[id]:CreateTexture(nil, "BACKGROUND")
	self.GUI.itemFrames[id].highlight:SetWidth(102)
	self.GUI.itemFrames[id].highlight:SetHeight(37)
	self.GUI.itemFrames[id].highlight:SetPoint("CENTER", _G["BlueItemInfo2ItemFrame"..id.."NameFrame"], "CENTER")
	if id == 1 then
		self.GUI.itemFrames[id]:SetPoint("TOPLEFT", self.GUI.scrollchild, "TOPLEFT", 0, 0)
	elseif mod(id, 4) == 1 then
		self.GUI.itemFrames[id]:SetPoint("TOP", self.GUI.itemFrames[id - 4], "BOTTOM", 0, -4)
	else
		self.GUI.itemFrames[id]:SetPoint("LEFT", self.GUI.itemFrames[id - 1], "RIGHT", 2, 0)
	end
end

local spliter, LY, LM, LD, LH = {}

function BlueItemInfo2:ItemFrameOnClick(button)
	itemName, itemColorName, itemLink, itemTexture = BlueItemInfo2:GetItemInfo(self.itemID)
	if itemName and self.itemID < 0 then
		itemLink = getSpellRealSpellLink(-self.itemID, itemLink)
	end
	if button == "LeftButton" then
		if itemName then
			if self.itemID > 0 and IsShiftKeyDown() and IsControlKeyDown() then
				BlueItemInfo2:AddMemo(self.itemID)
			elseif IsAltKeyDown() then
				BlueItemInfo2:AddFavoriteItem(self.itemID)
			elseif IsShiftKeyDown() then
				if self.itemID > 0 and AuctionFrame and AuctionFrame:IsVisible() and BrowseName:IsVisible() then
					BrowseName:SetText(itemName)
				else
					ChatFrameEditBox:Show()
					ChatFrameEditBox:Insert(itemLink)
				end
			elseif IsControlKeyDown() then
				DressUpItemLink(itemLink)
			else
				SetItemRef(getSimpleLink(itemLink), itemName, button)
			end
		elseif self.isLockItem == nil then
			itemCheckTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			itemCheckTooltip:SetHyperlink("item:"..self.itemID..":0:0:0:0:0:0:0")
			itemCheckTooltip:Show()
			BlueItemInfo2.GUI.itemUpdater.timer = 4
		end
		LDM:CloseMenu(1)
	elseif LDM:IsOpen("BlueItemInfo2ItemFrameMenu") or LDM:IsOpen("BlueItemInfo2ItemFrameIdentiMenu") then
		LDM:CloseMenu(1)
	elseif self.itemID then
		if itemName then
			itemMenu.name, itemMenu.icon = itemColorName, itemTexture
			itemMenu.args.link.arg1 = itemLink
			itemMenu.args.view.arg1 = itemLink
			itemMenu.args.fav.arg1 = self.itemID
			itemMenu.args.memo.arg1 = self.itemID
			LDM:OpenMenu("BlueItemInfo2ItemFrameMenu", "TOPLEFT", self, "CENTER")
		elseif self.isLockItem == nil and self.itemID > 0  then
			itemIdentiMenu.args.ident.arg1 = self.itemID
			LDM:OpenMenu("BlueItemInfo2ItemFrameIdentiMenu", "TOPLEFT", self, "CENTER")
		end
	end
end

function BlueItemInfo2:ItemFrameShowItemTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -150, 0)
	GameTooltip:SetHyperlink("item:"..self.itemID)
	GameTooltip:Show()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

function BlueItemInfo2:ItemFrameOnEnter()
	self.UpdateTooltip = nil
	GameTooltip:Hide()
	BlueItemInfo2.data.enterItemFrame = self
	if self.itemID > 0 then
		if GetItemInfo(self.itemID) then
			if self.isUnknown then
				GameTooltip:Hide()
				BlueItemInfo2.GUI.itemUpdater.timer = 5
			else
				self.UpdateTooltip = BlueItemInfo2.ItemFrameShowItemTooltip
				BlueItemInfo2.ItemFrameShowItemTooltip(self)
			end
		else
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -150, 0)
			GameTooltip:AddLine("해당 아이템이 아이템 캐쉬에 존재하지 않습니다.", 1, 1, 1)
			if self.isLockItem == nil then
				spliter[1], spliter[2], spliter[3], spliter[4], spliter[5], spliter[6], spliter[7], spliter[8], spliter[9], spliter[10]  = ("|"):split(BlueItemInfo2:GetItemCode(self.itemID) or "")
				minLockItem = nil
				for _, v in pairs(spliter) do
					if v:len() >= 3 then
						v = select(2, v:match("(.+)_(.+)")) or v
						v = ("@"):split(v)
						v = ("*"):split(v)
						if v and v:len() == 3 and v:match("[0-9|A-Z|a-z][0-9|A-Z|a-z][0-9|A-Z|a-z]") and BlueItemInfo2.data.lockCategory[v] then
							self.isLockItem = BlueItemInfo2.data.lockCategory[v]..""
							break
						end
					end
				end
			end
			if self.isLockItem and (tonumber(self.isLockItem) or 0) > BlueItemInfo2:GetCurrentTime() then
				LY, LM, LD, LH = self.isLockItem:match("([0-9][0-9][0-9][0-9])([0-1][0-9])([0-3][0-9])([0-2][0-9])")
				if LY then
					GameTooltip:AddLine(("이 아이템은 %d년 %d월 %d일 %d시까지 강제 확인이 불가능합니다."):format(tonumber(LY), tonumber(LM), tonumber(LD), tonumber(LH)))
				else
					GameTooltip:AddLine("이 아이템은 강제 확인이 불가능합니다.")
				end
			else
				self.isLockItem = nil
				GameTooltip:AddLine("클릭하면 아이템의 정보를 서버로부터 가져옵니다.")
				GameTooltip:AddLine("!!주의!! 한번이라도 드랍된 기록이 없는 아이템은 클라이언트가 강제 종료될 수 있습니다!!", 1, 0.1, 0.1, 1)
			end
			BlueItemInfo2:ProcessTooltip(GameTooltip, nil, "item:"..self.itemID, self.itemID)
			GameTooltip:Show()
		end
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -150, 0)
		GameTooltip:SetHyperlink("enchant:"..abs(self.itemID))
		GameTooltip:Show()
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end
end

function BlueItemInfo2:ItemFrameOnLeave()
	BlueItemInfo2.data.enterItemFrame = nil
	self.UpdateTooltip = nil
	GameTooltip:Hide()
	ShoppingTooltip1:Hide()
	ShoppingTooltip2:Hide()
	ResetCursor()
end

local function dropdownOnClick(self)
	if LDM:IsOpen("BlueItemInfo2CategoryDropMenu") then
		PlaySound("igMainMenuOptionCheckBoxOff")
		LDM:CloseMenu(1)
	elseif type(self.menu) == "table" and self.menu.args then
		PlaySound("igMainMenuOptionCheckBoxOn")
		LDM:RegisterMenu("BlueItemInfo2CategoryDropMenu", self.menu)
		LDM:OpenMenu("BlueItemInfo2CategoryDropMenu", "TOPLEFT", self, "BOTTOMLEFT", 0, 0, nil, true)
	else
		LDM:CloseMenu(1)
	end
end

local function dropdownOnEnter(self)
	self:SetBackdropColor(1, 0, 0, 0.8)
end

local function dropdownOnLeave(self)
	self:SetBackdropColor(0, 0, 0, 0.8)
end

local function dropdownOnMouseWheelUp(self)
	if self:GetParent().prevCode then
		BlueItemInfo2:SetCategory(self:GetParent().prevCode)
	end
end

local function dropdownOnMouseWheelDown(self)
	if self:GetParent().nextCode then
		BlueItemInfo2:SetCategory(self:GetParent().nextCode)
	end
end

local function dropdownOnMouseWheel(self, wheel)
	if wheel > 0 then
		dropdownOnMouseWheelUp(self.up)
	else
		dropdownOnMouseWheelDown(self.down)
	end
end

function BlueItemInfo2:CreateDropdownFrame(id)
	self.GUI.dropdowns[id] = CreateFrame("Button", nil, self.GUI)
	self.GUI.dropdowns[id].id = id
	self.GUI.dropdowns[id]:SetID(id)
	self.GUI.dropdowns[id]:SetWidth(206)
	self.GUI.dropdowns[id]:SetHeight(24)
	self.GUI.dropdowns[id]:SetBackdrop(backdrop)
	self.GUI.dropdowns[id]:SetBackdropColor(0, 0, 0, 0.8)
	self.GUI.dropdowns[id]:EnableMouseWheel()
	self.GUI.dropdowns[id]:SetScript("OnClick", dropdownOnClick)
	self.GUI.dropdowns[id]:SetScript("OnEnter", dropdownOnEnter)
	self.GUI.dropdowns[id]:SetScript("OnLeave", dropdownOnLeave)
	self.GUI.dropdowns[id]:SetScript("OnMouseWheel", dropdownOnMouseWheel)
	self.GUI.dropdowns[id].text = self.GUI.dropdowns[id]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.GUI.dropdowns[id].text:SetPoint("CENTER", -10, 1)
	self.GUI.dropdowns[id].down = CreateFrame("Button", nil, self.GUI.dropdowns[id])
	self.GUI.dropdowns[id].down:SetWidth(20)
	self.GUI.dropdowns[id].down:SetHeight(20)
	self.GUI.dropdowns[id].down:SetPoint("RIGHT", self.GUI.dropdowns[id], "RIGHT", -2, 0)
	self.GUI.dropdowns[id].down:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	self.GUI.dropdowns[id].down:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	self.GUI.dropdowns[id].down:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	self.GUI.dropdowns[id].down:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	self.GUI.dropdowns[id].down:SetScript("OnClick", dropdownOnMouseWheelDown)
	self.GUI.dropdowns[id].up = CreateFrame("Button", nil, self.GUI.dropdowns[id])
	self.GUI.dropdowns[id].up:SetWidth(20)
	self.GUI.dropdowns[id].up:SetHeight(20)
	self.GUI.dropdowns[id].up:SetPoint("RIGHT", self.GUI.dropdowns[id].down, "LEFT", 5, 0)
	self.GUI.dropdowns[id].up:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
	self.GUI.dropdowns[id].up:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
	self.GUI.dropdowns[id].up:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled")
	self.GUI.dropdowns[id].up:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	self.GUI.dropdowns[id].up:SetScript("OnClick", dropdownOnMouseWheelUp)
end

local ncodes, categoryNames, prevCode, nextCode = {}, {}

function BlueItemInfo2:SetCategory(code)
	LDM:CloseMenu(1)
	code = code or BlueItemInfo2DB.category
	if not (code and self.data.categoryCode[code]) then
		code = self.defalutCode
	end
	BlueItemInfo2DB.category = code
	self.GUI.dropdowns[1].code, self.GUI.dropdowns[2].code, self.GUI.dropdowns[3].code = self:GetCategory(code)
	self.GUI.dropdowns[1].name, self.GUI.dropdowns[2].name, self.GUI.dropdowns[3].name = self:GetCategoryName(code)
	self.GUI.dropdowns[1].menu = self.menu
	self.GUI.dropdowns[2].menu = self.menu.args[self.GUI.dropdowns[1].code]
	self.GUI.dropdowns[3].menu = self.menu.args[self.GUI.dropdowns[1].code].args[self.GUI.dropdowns[2].code]
	for i = 1, 3 do
		self.GUI.dropdowns[i].text:SetText(self.GUI.dropdowns[i].name or "")
		self.GUI.dropdowns[i].prevCode, self.GUI.dropdowns[i].nextCode = self:GetNextCategory(i, code)
		if self.GUI.dropdowns[i].prevCode and self.GUI.dropdowns[i].nextCode then
			self.GUI.dropdowns[i]:Enable()
			self.GUI.dropdowns[i].up:Enable()
			self.GUI.dropdowns[i].down:Enable()
		elseif self.GUI.dropdowns[i].prevCode then
			self.GUI.dropdowns[i]:Enable()
			self.GUI.dropdowns[i].up:Enable()
			self.GUI.dropdowns[i].down:Disable()
		elseif self.GUI.dropdowns[i].nextCode then
			self.GUI.dropdowns[i]:Enable()
			self.GUI.dropdowns[i].down:Enable()
			self.GUI.dropdowns[i].up:Disable()
		else
			self.GUI.dropdowns[i]:Disable()
			self.GUI.dropdowns[i].up:Disable()
			self.GUI.dropdowns[i].down:Disable()
		end
	end
	self:SetItemList(code)
end

local step1, step2, step3, newCode

local function getNewCategory(step, id, c1, c2, c3)
	if id == 1 then
		if step < 0 then
			step1, step2, step3 = c1 - 1, 1, -1
		elseif step > 0 then
			step1, step2, step3 = c1 + 1, #v36Table, 1
		else
			return nil
		end
		for i = step1, step2, step3 do
			if BlueItemInfo2.data.items[v36Table[i].."**"] then
				for j = 1, #v36Table do
					if BlueItemInfo2.data.items[v36Table[i]..v36Table[j].."*"] then
						for k = 1, #v36Table do
							newCode = v36Table[i]..v36Table[j]..v36Table[k]
							if BlueItemInfo2.data.items[newCode] and BlueItemInfo2.data.categoryCode[newCode] then
								return newCode
							end
						end
					end
				end
			end
		end
	elseif id == 2 then
		if step < 0 then
			step1, step2, step3 = c2 - 1, 1, -1
		elseif step > 0 then
			step1, step2, step3 = c2 + 1, #v36Table, 1
		else
			return nil
		end
		for i = step1, step2, step3 do
			if BlueItemInfo2.data.items[v36Table[c1]..v36Table[i].."*"] then
				for j = 1, #v36Table do
					newCode = v36Table[c1]..v36Table[i]..v36Table[j]
					if BlueItemInfo2.data.items[newCode] and BlueItemInfo2.data.categoryCode[newCode] then
						return newCode
					end
				end
			end
		end
	elseif id == 3 then
		if step < 0 then
			step1, step2, step3 = c3 - 1, 1, -1
		elseif step > 0 then
			step1, step2, step3 = c3 + 1, #v36Table, 1
		else
			return nil
		end
		for i = step1, step2, step3 do
			newCode = v36Table[c1]..v36Table[c2]..v36Table[i]
			if BlueItemInfo2.data.items[newCode] and BlueItemInfo2.data.categoryCode[newCode] then
				return newCode
			end
		end
	end
	return nil
end

local code1, code2, code3

function BlueItemInfo2:GetNextCategory(id, code)
	id = tonumber(id)
	code = code or BlueItemInfo2DB.category
	if v36Table == nil then
		v36Table = {}
		for i = 1, v36:len() do
			v36Table[i] = v36:sub(i, i)
		end
	end
	code1, code2, code3 = self:GetCategory(code)
	code1, code2, code3 = v36:find(code1), v36:find(code2), v36:find(code3)
	return getNewCategory(-1, id, code1, code2, code3), getNewCategory(1, id, code1, code2, code3)
end

function BlueItemInfo2:ScrollCategory(id, scv)
	id = tonumber(id)
	local pi, ni = self:GetNextCategory(id)
	PlaySound("igMainMenuOptionCheckBoxOn")
	if scv > 0 and pi then
		self:SetCategory(pi)
	elseif scv < 0 and ni then
		self:SetCategory(ni)
	end
end

function BlueItemInfo2:CreateItemTable()
	self.fullsorted = "/"
	local hitems = {}
	local dropType, code, codes
	local spliter = {}
	local function processItemTable(itemTable)
		if type(itemTable) == "table" then
			for itemID in pairs(itemTable) do
				codes = BlueItemInfo2:GetItemRealText(itemID)
				if codes then
					spliter[1], spliter[2], spliter[3], spliter[4], spliter[5], spliter[6], spliter[7], spliter[8], spliter[9], spliter[10], spliter[11], spliter[12], spliter[13], spliter[14], spliter[15], spliter[16], spliter[17], spliter[18], spliter[19], spliter[20] = ("|"):split(codes)
					for _, v in pairs(spliter) do
						dropType, code = v:match("([A-Z|a-z])_(.+)")
						code = ("@"):split(code or v)
						code = ("*"):split(code)
						if BlueItemInfo2:CheckCategoryCode(code) then
							if dropType == "H" or dropType == "r" then
								hitems[code] = (hitems[code] and (hitems[code].."/") or "")..itemID
							elseif dropType ~= "C" and dropType ~= "X" and dropType ~= "s" and dropType ~= "n" then
								self.data.items[code] = (self.data.items[code] and (self.data.items[code].."/") or "")..itemID
							end
						end
					end
				end
			end
		end
	end
	processItemTable(self.data.itemDB)
	processItemTable(self.data.itemDB0)
	processItemTable(self.data.itemDB1)
	for p in pairs(spliter) do
		spliter[p] = nil
	end
	spliter = nil
	for p, v in pairs(hitems) do
		self.data.items[p] = (self.data.items[p] or "").."|"..v
		hitems[p] = nil
	end
	hitems = nil
	for code in pairs(self.data.items) do
		self.data.items[code:sub(1, 1).."**"] = ""
		self.data.items[code:sub(1, 2).."*"] = ""
	end
end

local i1, i2, mainCate, id, unknown, uk, item1, item2

function BlueItemInfo2:SetItemList(code)
	self.GUI.scrollframe:SetVerticalScroll(0)
	self:RefreshItemList(code)
end

function BlueItemInfo2:RefreshItemList(code)
	if self.GUI.itemUpdater:IsShown() then
		self.GUI.itemUpdater:Hide()
		self.GUI.itemUpdater.timer = 0
	end
	self.GUI.itemUpdater.run = nil
	for p in pairs(self.data.unidentifiedItems) do
		self.data.unidentifiedItems[p] = nil
	end
	if self.data.items[code] and self.data.items[code] ~= "" then
		self.data.items[code] = type(self.data.items[code]) == "string" and self.data.items[code] or (self.data.items[code].."")
		self.data.shownCode = code
		self.data.currentTime = self:GetCurrentTime()
		i1, i2 = ("|"):split(self.data.items[code])
		if self.data.items[code]:sub(1, 1) == "|" then
			i1, i2 = nil, self.data.items[code]:sub(2)
		end
		mainCate = code:sub(1, 1)
		id, unknown, uk = 1, 0
		item1, item2 = i1 and { ("/"):split(i1) } or {}, i2 and { ("/"):split(i2) } or {}
		if BlueItemInfo2DB.sort and not(self.fullsorted:find("/"..code.."/")) then
			if i1 then
				item1, uk = self:SortItemTable(item1, mainCate)
				unknown = unknown + uk
			end
			if i2 then
				item2, uk = self:SortItemTable(item2, mainCate)
				unknown = unknown + uk
			end
			if unknown == 0 then
				if i1 and i2 then
					self.data.items[code] = table.concat(item1, "/").."|"..table.concat(item2, "/")
				elseif i1 then
					self.data.items[code] = table.concat(item1, "/")
				elseif i2 then
					self.data.items[code] = "|"..table.concat(item2, "/")
				end
				self.fullsorted = self.fullsorted..code.."/"
			end
		end
		if i1 then
			for i = 1, #(item1) do
				local it = tonumber(item1[i])
				if (self:GetItemRealText(it) or "*"):find("B_"..code) then
					self:SetItemFrame(id, it, 0, 0.8, 0)
				else
					self:SetItemFrame(id, it)
				end
				id = id + 1
			end
		end
		if i2 then
			for i = 1, #(item2) do
				self:SetItemFrame(id, tonumber(item2[i]), 1, 0, 0)
				id = id + 1
			end
		end
		self:HideItemFrame(id - 1)
	else
		self:HideItemFrame(0)
	end
	i1, i2, mainCate, id, unknown, uk, item1, item2 = nil
	if self.GUI.itemUpdater.run then
		self.GUI.itemUpdater:Show()
	end
end

function BlueItemInfo2:SetItemFrame(id, itemID, r, g, b)
	if not self.GUI.itemFrames[id] then
		self:CreateItemFrame(id)
	end
	self.GUI.itemFrames[id].UpdateTooltip = nil
	itemName, itemColorName, itemLink, itemTexture = self:GetItemInfo(itemID)
	SetItemButtonTexture(self.GUI.itemFrames[id], itemTexture)
	self.GUI.itemFrames[id].itemID = itemID
	self.GUI.itemFrames[id].isLockItem = nil
	self.GUI.itemFrames[id].isUnknown = nil
	if itemName then
		SetItemButtonTextureVertexColor(self.GUI.itemFrames[id], 1, 1, 1)
		self.GUI.itemFrames[id].text:SetText(itemColorName)
	else
		self.GUI.itemFrames[id].text:SetText("|cffffffff미확인 아이템\nID "..itemID)
		if itemTexture == "Interface\\Icons\\INV_Misc_QuestionMark" then
			SetItemButtonTextureVertexColor(self.GUI.itemFrames[id], 1, 1, 1)
		else
			SetItemButtonTextureVertexColor(self.GUI.itemFrames[id], 1, 0.2, 0.2)
		end
		if itemID > 0 then
			if self.data.shownCode and self.data.lockCategory[self.data.shownCode] then
				if self.data.currentTime < self.data.lockCategory[self.data.shownCode] then
					self.GUI.itemFrames[id].isLockItem = self.data.lockCategory[self.data.shownCode]..""
				else
					self.data.lockCategory[self.data.shownCode] = nil
				end
			end
			self.data.unidentifiedItems[itemID] = true
			self.GUI.itemFrames[id].isUnknown = true
			self.GUI.itemUpdater.run = true
		end
	end
	if r and g and b then
		self.GUI.itemFrames[id].highlight:SetGradientAlpha("VERTICAL", r * 0.6, g * 0.6, b * 0.6, 1, r, g, b, 1)
		self.GUI.itemFrames[id].highlight:SetTexture(r, g, b, 0.4)
		self.GUI.itemFrames[id].highlight:Show()
	else
		self.GUI.itemFrames[id].highlight:Hide()
	end
	self.GUI.itemFrames[id]:EnableMouse(true)
	self.GUI.itemFrames[id]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self.GUI.itemFrames[id]:Show()
	if self.data.enterItemFrame == self.GUI.itemFrames[id] then
		self.ItemFrameOnEnter(self.GUI.itemFrames[id])
	end
end

function BlueItemInfo2:HideItemFrame(n)
	for i = n + 1, self.data.itemframes do
		self.GUI.itemFrames[i]:Hide()
	end
	if n == 0 then
		self.GUI.nolist:Show()
	else
		self.GUI.nolist:Hide()
	end
end
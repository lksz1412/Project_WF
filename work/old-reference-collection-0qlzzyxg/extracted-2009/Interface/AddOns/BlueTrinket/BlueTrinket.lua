BlueTrinket = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0")

BlueTrinket.title = "Blue Trinket"
BlueTrinket.version = "v3.0 (r15522)"

local numTrinket = 2
local prevNum = 0
local trinketName = {}
local trinket = {}
local cooldown = {}
local alretMessage = {}
local thisFrame = 0
local appointTrinket = {}
local delay = 0.5

local function GetTrinketInfo(x, y)
	local itemInfo
	if (x and y) then
		itemInfo = GetContainerItemLink(x, y)
	else
		itemInfo = GetInventoryItemLink("player", x)
	end
	if (itemInfo) then
		local _,_, itemId = strfind(itemInfo, "item:(%d+):")
		if (itemId) then
			local itemName, _, _, _, _, _, _, _, itemEquipLoc, itemTexture = GetItemInfo(itemId)
			if (itemName and itemEquipLoc and itemTexture) then
				if (itemEquipLoc == "INVTYPE_TRINKET") then
					return itemName, itemTexture
				end
			end
		end
	end
end

function BlueTrinket:OnInitialize()
	BINDING_HEADER_BLUETRINKET = "블루 장신구 관리기"
	BINDING_NAME_BLUETRINKETBUTTON1 = "상단 장신구 사용"
	BINDING_NAME_BLUETRINKETBUTTON2 = "하단 장신구 사용"
	self.menu = {
		type = "group",
		args = {
			reset = {
				name = "위치 초기화",
				type = "execute",
				desc = "프레임 위치를 초기화합니다.",
				func = function() self.db.profile.pos = nil self:LoadPosition() end,
				order = 1,
			},
			main = {
				name = "장신구 버튼 배치",
				type = "range",
				desc = "장신구 버튼의 배치를 가로 또는 세로 방향으로 정렬합니다.",
				get = function() return self.db.profile.type end,
				set = function(v) self.db.profile.type = v self:SetLayout() end,
				min = 1,
				max = 2,
				step = 1,
				order = 3,
			},
			sub = {
				name = "토글 장신구 버튼 배치",
				type = "range",
				desc = "토글되는 장신구의 배치를 조정합니다.",
				get = function() return self.db.profile.anchor end,
				set = function(v) self.db.profile.anchor = v self:SetLayout() end,
				min = 1,
				max = 2,
				step = 1,
				order = 4,
			},
			tab = {
				name = "버튼 간격",
				type = "range",
				desc = "장신구 버튼의 간격을 조정합니다.",
				get = function() return self.db.profile.tab end,
				set = function(v) self.db.profile.tab = v self:SetLayout() end,
				min = 0,
				max = 20,
				step = 1,
				order = 5,
			},
			mainscale = {
				name = "장신구 버튼 크기",
				type = "range",
				desc = "장신구 버튼의 크기를 조정합니다.",
				get = function() return self.db.profile.scale[1] end,
				set = function(v) self.db.profile.scale[1] = v self:SetLayout() self:LoadPosition() end,
				min = 0.6,
				max = 2.0,
				step = 0.1,
				order = 6,
			},
			subscale = {
				name = "토글 장신구 버튼 크기",
				type = "range",
				desc = "토글 장신구 버튼의 크기를 조정합니다.",
				get = function() return self.db.profile.scale[2] end,
				set = function(v) self.db.profile.scale[2] = v self:SetLayout() end,
				min = 0.6,
				max = 2.0,
				step = 0.1,
				order = 7,
			},
			toggle = {
				name = "토글 장신구 보이는 방식",
				type = "text",
				desc = "바의 텍스쳐를 설정합니다",
				get = function() return self.db.profile.toggle end,
				set = function(v)
					self.db.profile.toggle = v
				end,
				validate = { "None", "Alt", "Ctrl", "Shift" },
				order = 8,
			},
			alret = {
				name = "장신구 재사용 가능 알림",
				type = "toggle",
				desc = "재사용 가능한 장신구를 알립니다.",
				get = function() return self.db.profile.alret end,
				set = function(v) self.db.profile.alret = v end,
				order = 9,
			},
			alretsound = {
				name = "장신구 재사용 가능 알림 소리",
				type = "toggle",
				desc = "재사용 가능한 장신구를 알릴때 사운드를 재생합니다.",
				get = function() return self.db.profile.alretsound end,
				set = function(v) self.db.profile.alretsound = v end,
				hidden = function() return not self.db.profile.alret end,
				order = 10,
			},
		},
	}
	self.keyframe = CreateFrame("Frame", nil, UIParent)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", function() self.inCombat = nil self:CheckStatus() end)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", function() self.inCombat = 1 end)
	self:RegisterEvent("PLAYER_ALIVE", function() self.isDead = nil self:CheckStatus() end)
	self:RegisterEvent("PLAYER_DEAD", function() self.isDead = 1 end)
	self:RegisterEvent("PLAYER_CONTROL_GAINED", function() self.inability = nil self:CheckStatus() end)
	self:RegisterEvent("PLAYER_CONTROL_LOST", function() self.inability = 1 end)
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	self:RegisterEvent("PLAYER_LOGIN", function() self:BagUpdate()  self:LoadPosition() end)
	self:RegisterEvent("BAG_CLOSED")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("AceEvent_FullyInitialized", function()
		self:BagUpdate()
		self:LoadPosition()
		self:SetLayout()
		if self.AddSkinMenu then
			self.AddSkinMenu()
		end
	end)
	self:RegisterDB("BlueTrinketDB")
	self:RegisterDefaults("profile", {
		type = 1,
		anchor = 1,
		scale = { 1, 1 },
		alret = true,
		alretsound = true,
		cycircledskin = "Serenity",
		toolskin = "없음",
		tab = 2,
		toggle = "None",
	})
	self:RegisterChatCommand({ "/bt"}, self.menu)
	self:CreateFrame()
end

function BlueTrinket:BAG_UPDATE_COOLDOWN()
	for p, v in pairs(trinketName) do
		local s, d, e = GetItemCooldown(p)
		local cooldown = getglobal("BlueTrinketButton"..v.."Cooldown")
		CooldownFrame_SetTimer(cooldown, s, d, e)
	end
end

function BlueTrinket:UNIT_INVENTORY_CHANGED(unit)
	if unit == "player" then
		self:BagUpdate()
	end
end

function BlueTrinket:CheckCooldown()
	local s, d, e = GetItemCooldown(this.name)
	if s > 0 and e == 1 then
		local rt = s + d - GetTime()
		if self.db.profile.alret and (rt < 0.1 and d > 5) then
			self:AlretMessage(this.name.." 사용가능!")
		end
	end
end

function BlueTrinket:OnEnable()
	self:ConvertBindings()
	self:RegisterOverrideBindings()
	self:RegisterEvent("UPDATE_BINDINGS", "RegisterOverrideBindings")
	if UnitAffectingCombat("player") then
		self.inCombat = 1
	end
end

function BlueTrinket:CheckStatus()
	if UnitOnTaxi("player") then
		self.inability = nil
	end
	if not(self.inCombat) and not(self.inability) and not(self.isDead) and not(UnitIsDeadOrGhost("player")) and self.appoint then
		self:ChangeTrinket()
	end
	if not(self.inCombat) and self.updateBag then
		self.updateBag = nil
		self:BagUpdate()
	end
end

function BlueTrinket:ChangeTrinket()
	self.appoint = nil
	for i = 1, 2 do
		if appointTrinket[i] then
			EquipItemByName(appointTrinket[i], i + 12)
			appointTrinket[i] = nil
		end
	end
end

function BlueTrinket:BAG_CLOSED(msg)
	self.updateBag = 1
	self:CheckStatus()
end

function BlueTrinket:BagUpdate()
	self.newButton = false
	trinketName = {}
	numTrinket = 2
	for i = 1, 2 do
		local itemName, itemTexture = GetTrinketInfo(i + 12)
		self:CreateButton(i, BlueTrinketMainFrame, itemName, itemTexture)
	end
	for i = 0, 4 do
		for j = 1, GetContainerNumSlots(i) do
			local itemName, itemTexture = GetTrinketInfo(i, j)
			if itemName then
				numTrinket = numTrinket + 1
				self:CreateButton(numTrinket, nil, itemName, itemTexture)
			end
		end
	end
	if numTrinket + 1 ~= prevNum then
		for i = numTrinket + 1, prevNum do
			getglobal("BlueTrinketButton"..i):Hide()
		end
	end
	prevNum = numTrinket
	if self.newButton then
		self:SetLayout()
	end
	self:BAG_UPDATE_COOLDOWN()
end

function BlueTrinket:CreateFrame()
	local frame = CreateFrame("Frame", "BlueTrinketMainFrame", UIParent)
	frame:SetFrameStrata("LOW")
	frame:SetWidth(43)
	frame:SetHeight(43)
	frame:SetMovable(1)
	frame:SetClampedToScreen(1)
	frame:SetScript("OnUpdate", function()
		if self.toggleTime and self.toggleTime < GetTime() then
			self.toggleTime = nil
			BlueTrinketInvFrame:Hide()
		end
		if self.toggleTime then
			if self.db.profile.toggle == "Alt" and IsAltKeyDown() then
				BlueTrinketInvFrame:Show()
			elseif self.db.profile.toggle == "Ctrl" and IsControlKeyDown() then
				BlueTrinketInvFrame:Show()
			elseif self.db.profile.toggle == "Shift" and IsShiftKeyDown() then
				BlueTrinketInvFrame:Show()
			elseif self.db.profile.toggle == "None" then
				BlueTrinketInvFrame:Show()
			end
		end
	end)
	local sframe = CreateFrame("Frame", "BlueTrinketInvFrame", UIParent)
	sframe:SetWidth(43)
	sframe:SetHeight(43)
	sframe:EnableMouse(1)
	sframe:SetScript("OnUpdate", function() self:UpdateChecked() if (MouseIsOver(this)) then BlueTrinket.toggleTime = GetTime() + delay end end)
	frame:Show()
end

function BlueTrinket:CreateButton(id, parent, tname, texture)
	local name = "BlueTrinketButton"..id
	local frame = getglobal(name)
	if not frame then
		self.newButton = true
		frame = CreateFrame("CheckButton", name, parent or BlueTrinketInvFrame, id < 3 and "SecureActionButtonTemplate, ActionButtonTemplate" or "ActionButtonTemplate")
		frame.texture = getglobal(name.."Icon")
		frame.cooldown = getglobal(name.."Cooldown")
		frame:SetID(id)
		frame:RegisterForClicks("AnyUp")
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnEnter", function() self:ButtonOnEnter() end)
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		frame:SetWidth(35)
		frame:SetHeight(35)
		frame:SetNormalTexture("")
		if id < 3 then
			frame:SetScript("OnDragStart", self.DragStart)
			frame:SetScript("OnDragStop", self.DragStop)
			frame:SetScript("PostClick", function() this:SetChecked(0) end)
			frame:SetAttribute("type", "item")
			frame:SetAttribute("slot", id + 12)
			frame:SetScript("OnUpdate", function() self:CheckCooldown() if MouseIsOver(this) then BlueTrinket.toggleTime = GetTime() + delay end end)
		else
			frame:SetScript("OnUpdate", function() if MouseIsOver(this) then BlueTrinket.toggleTime = GetTime() + delay end end)
			frame:SetScript("OnClick", self.ButtonOnClick)
		end
		if self.ApplySkin then
			self.ApplySkin(frame)
		end
	end
	if tname then
		trinketName[tname] = id
		frame.cooldown:Show()
	else
		frame.cooldown:Hide()
	end
	frame.name = tname
	frame.texture:SetTexture(texture or "interface\\paperdoll\\UI-PaperDoll-Slot-Trinket")
end

function BlueTrinket:SetLayout()
	mframe = BlueTrinketMainFrame
	iframe = BlueTrinketInvFrame
	BlueTrinketButton1:ClearAllPoints()
	BlueTrinketButton1:SetPoint("CENTER", mframe, "CENTER", 0, 0)
	BlueTrinketButton2:ClearAllPoints()
	mframe:SetScale(self.db.profile.scale[1])
	iframe:SetScale(self.db.profile.scale[2])
	if self.db.profile.type == 1 then
		BlueTrinketButton2:SetPoint("LEFT", BlueTrinketButton1, "RIGHT", self.db.profile.tab, 0)
	else
		BlueTrinketButton2:SetPoint("TOP", BlueTrinketButton1, "BOTTOM", 0, -self.db.profile.tab)
	end
	local prev = BlueTrinketButton3
	if prev then
		prev:ClearAllPoints()
		prev:SetPoint("CENTER", iframe, "CENTER", 0, 0)
		if self.db.profile.type == 1 then
			if self.db.profile.anchor == 1 then
				for i = 4, numTrinket do
					local frame = getglobal("BlueTrinketButton"..i)
					frame:ClearAllPoints()
					frame:SetPoint("BOTTOM", prev, "TOP", 0, self.db.profile.tab)
					prev = frame
				end
			else
				for i = 4, numTrinket do
					local frame = getglobal("BlueTrinketButton"..i)
					frame:ClearAllPoints()
					frame:SetPoint("TOP", prev, "BOTTOM", 0, -self.db.profile.tab)
					prev = frame
				end
			end
		else
			if self.db.profile.anchor == 1 then
				for i = 4, numTrinket do
					local frame = getglobal("BlueTrinketButton"..i)
					frame:ClearAllPoints()
					frame:SetPoint("RIGHT", prev, "LEFT", -self.db.profile.tab, 0)
					prev = frame
				end
			else
				for i = 4, numTrinket do
					local frame = getglobal("BlueTrinketButton"..i)
					frame:ClearAllPoints()
					frame:SetPoint("LEFT", prev, "RIGHT", self.db.profile.tab, 0)
					prev = frame
				end
			end
		end
	end
end

function BlueTrinket:ButtonOnEnter()
	local id = this:GetID()
	if this.name then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.name)
		GameTooltip:Show()
		self.toggleTime = GetTime() + delay
	end
	if id < 3 then
		local pframe = getglobal("BlueTrinketButton"..id)
		thisFrame = id
		BlueTrinketInvFrame:ClearAllPoints()
		if self.db.profile.type == 1 then
			if self.db.profile.anchor == 1 then
				BlueTrinketInvFrame:SetPoint("BOTTOM", pframe, "TOP", 0, self.db.profile.tab - 5)
			else
				BlueTrinketInvFrame:SetPoint("TOP", pframe, "BOTTOM", 0, 5 - self.db.profile.tab)
			end
		elseif self.db.profile.type == 2 then
			if self.db.profile.anchor == 1 then
				BlueTrinketInvFrame:SetPoint("RIGHT", pframe, "LEFT", 5 - self.db.profile.tab, 0)
			else
				BlueTrinketInvFrame:SetPoint("LEFT", pframe, "RIGHT", self.db.profile.tab -5, 0)
			end
		end
	end
end

function BlueTrinket:UpdateChecked()
	local tname = appointTrinket[thisFrame]
	for i = 3, numTrinket do
		if tname and trinketName[tname] == i then
			getglobal("BlueTrinketButton"..i):SetChecked(1)
		else
			getglobal("BlueTrinketButton"..i):SetChecked(0)
		end
	end
end

function BlueTrinket:AlretMessage(msg)
	if (alretMessage[msg] and alretMessage[msg] >= GetTime()) then
		return
	else
		alretMessage[msg] = GetTime() + 9.99
	end
	if SCT then
		SCT:DisplayText(msg, nil , 1, nil, 2)
	else
		ChatFrame1:AddMessage(mgs)
	end
	if self.db.profile.alretsound then
		PlaySoundFile("Interface\\AddOns\\BlueTrinket\\Ready.mp3")
	end
end

function BlueTrinket.DragStart()
	if IsAltKeyDown() then
		BlueTrinket.isMov = 1
		BlueTrinketMainFrame:StartMoving()
		BlueTrinket.toggleTime = GetTime() - 1
		GameTooltip:Hide()
	end
end

function BlueTrinket.DragStop()
	if BlueTrinket.isMov then
		BlueTrinketMainFrame:StopMovingOrSizing()
		BlueTrinket:SavePosition()
		BlueTrinket.isMov = nil
	end
end

function BlueTrinket:SavePosition()
	local s = BlueTrinketMainFrame:GetEffectiveScale()
	local w = UIParent:GetEffectiveScale()
	self.db.profile.pos = { BlueTrinketMainFrame:GetLeft() * s, BlueTrinketMainFrame:GetTop() * s - (UIParent:GetTop()) * w }
	self:LoadPosition()
end

function BlueTrinket:LoadPosition()
	BlueTrinketMainFrame:ClearAllPoints()
	if self.db.profile.pos then
		local s = BlueTrinketMainFrame:GetEffectiveScale()
		BlueTrinketMainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.db.profile.pos[1] / s, self.db.profile.pos[2] / s)
	else
		BlueTrinketMainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

function BlueTrinket.ButtonOnClick()
	BlueTrinket.appoint = 1
	local tname = this.name
	if appointTrinket[1] == tname then
		appointTrinket[1] = nil
	elseif appointTrinket[2] == tname then
		appointTrinket[2] = nil
	end
	appointTrinket[thisFrame] = tname
	BlueTrinket:CheckStatus()
	BlueTrinket.toggleTime = GetTime() - 1
	BlueTrinket:UpdateChecked()
end

function BlueTrinket:ConvertBindings()
	for k, v in pairs(self.db.profile.Keybindings or {}) do
		if v and v[1] then
			SetBinding(v[1], k:upper())
		end
		if v and v[2] then
			SetBinding(v[2], k:upper())
		end
	end
	for i = 1, 2 do
		local key1, key2 = GetBindingKey("CLICK BlueTrinketButton"..i..":LeftButton")
		if key1 then
			SetBinding(key1, "BLUETRINKETBUTTON"..i)
		end
		if key2 then
			SetBinding(key2, "BLUETRINKETBUTTON"..i)
		end
	end
	SaveBindings(GetCurrentBindingSet())
	self.db.profile.Keybindings = nil
end

function BlueTrinket:RegisterOverrideBindings()
	ClearOverrideBindings(self.keyframe)
	for i = 1, 2 do
		local key1, key2 = GetBindingKey("BLUETRINKETBUTTON"..i)
		if key1 then
			SetOverrideBindingClick(self.keyframe, false, key1, "BlueTrinketButton"..i)
		end
		if key2 then
			SetOverrideBindingClick(self.keyframe, false, key2, "BlueTrinketButton"..i)
		end
	end
end
local addonName = ...

local frame = CreateFrame("Frame", addonName)
frame:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...); end)
frame:Show()

frame.OptionFrame = _G[addonName .. "OptionFrame"]

local EquipSlot = {
	[1]	 = "HeadSlot",
	[2]	 = "NeckSlot",
	[3]	 = "ShoulderSlot",
	--[4]	 = "ShirtSlot",
	[5]	 = "ChestSlot",
	[6]	 = "WaistSlot",
	[7]	 = "LegsSlot",
	[8]	 = "FeetSlot",
	[9]	 = "WristSlot",
	[10] = "HandsSlot",
	[11] = "Finger0Slot",
	[12] = "Finger1Slot",
	[13] = "Trinket0Slot",
	[14] = "Trinket1Slot",
	[15] = "BackSlot",
	[16] = "MainHandSlot",
	[17] = "SecondaryHandSlot",
	--[19] = "TabardSlot",
}

local AVG_ITEM_LEVEL_STR = "평균: %.2f"
local PLAYER_LEVEL_STR = "%s 레벨 %s |c%s%s %s|r"
local PLAYER_LEVEL_NO_SPEC_STR = "%s 레벨 %s |c%s%s|r"

local OPTION_INIT_LIST = {
	["ShowDurability"] = true,
	["ShowDetailIcon"] = true,
	["TooltipInspect"] = true,
	["StatPrecision"] = true,
}

--[[-----------------------------------------------------------------------------
-------------------------------------------------------------------------------]]

frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN()
	-- 옵션 초기값 설정
	if not CharInfoEnhancerOption then CharInfoEnhancerOption = {} end
	for k, v in pairs(OPTION_INIT_LIST) do
		if CharInfoEnhancerOption[k] == nil then CharInfoEnhancerOption[k] = v end
	end

	-- 아이템 레벨 표시 제한 레벨을 해제한다.
	MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY = 1

	-- 이동 속도 표시
	table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = "MOVESPEED" })

	-- EquipitemMixin 생성
	self.PlayerEquipUI = {}
	for slotID, slotName in pairs(EquipSlot) do
		self.PlayerEquipUI[slotID] = self:CreateEquipItemUIMixin()
		self.PlayerEquipUI[slotID]:SetSlot(nil, slotID)
		self.PlayerEquipUI[slotID]:SetUpUI(_G["Character"..slotName])
		self.PlayerEquipUI[slotID].GetUnit = function(self) return "player" end
	end

	self.MouseOverEquip = {}
	for slotID, slotName in pairs(EquipSlot) do
		self.MouseOverEquip[slotID] = self:CreateEquipItemMixin()
		self.MouseOverEquip[slotID]:SetSlot(nil, slotID)
		self.MouseOverEquip[slotID].GetUnit = function(self) return frame.InspectInfo.unit end
	end

	-- 각종 함수 hook
	hooksecurefunc("PaperDollFrame_SetLevel", function ()
		frame:OnPaperDollFrame_SetLevel()
		end)

	hooksecurefunc("PaperDollFrame_SetItemLevel", function ()
		frame:OnPaperDollFrame_SetItemLevel()
		end)

	hooksecurefunc("PaperDollFrame_SetLabelAndText", function (statFrame, label, text, isPercentage, numericValue)
		frame:OnPaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue)
		end)

	hooksecurefunc("CharacterFrame_UpdatePortrait", function ()
		frame:OnCharacterFrame_UpdatePortrait()
		end)	

	_G["PaperDollFrame"]:HookScript("OnShow", function(self, ...)
		frame:UpdatePlayerEquipItem()
		frame:UpdatePlayerDurability()

		frame:RegisterEvent("UNIT_INVENTORY_CHANGED")		
		frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
		frame:RegisterEvent("PLAYER_DEAD")
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		frame:RegisterEvent("PLAYER_UNGHOST")
		frame:RegisterEvent("MERCHANT_UPDATE")
		frame:RegisterEvent("MERCHANT_CLOSED")		
		frame:RegisterEvent("SOCKET_INFO_UPDATE")
		frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:RegisterEvent("AZERITE_ESSENCE_CHANGED")
		frame:RegisterEvent("AZERITE_ESSENCE_UPDATE")
		frame:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED")			
		frame:RegisterEvent("BAG_UPDATE")	
		frame:RegisterEvent("VOID_STORAGE_UPDATE")	
	end)

	_G["PaperDollFrame"]:HookScript("OnHide", function(self, ...)
		frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")

		frame:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
		frame:UnregisterEvent("PLAYER_DEAD")
		frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		frame:UnregisterEvent("PLAYER_UNGHOST")
		frame:UnregisterEvent("MERCHANT_UPDATE")
		frame:UnregisterEvent("MERCHANT_CLOSED")
		frame:UnregisterEvent("SOCKET_INFO_UPDATE")
		frame:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:UnregisterEvent("AZERITE_ESSENCE_CHANGED")
		frame:UnregisterEvent("AZERITE_ESSENCE_UPDATE")
		frame:UnregisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED")
		frame:UnregisterEvent("BAG_UPDATE")	
		frame:UnregisterEvent("VOID_STORAGE_UPDATE")	
	end)

	-- TooltipInspect.lua 관련
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, tooltipData) frame:OnTooltipSetUnit(tooltip, tooltipData) end)

	hooksecurefunc("InspectUnit", function (unit)
		frame:OnInspectUnit(unit)
		end)

	-- 캐릭창 UI 추가
	local font, _, flags = NumberFontNormal:GetFont()
	local durCheck = CreateFrame("CheckButton", addonName.."DurCheckButton", _G["PaperDollFrame"], "UICheckButtonTemplate")
	durCheck:SetSize(16,16)
	_G[durCheck:GetName() .. "Text"]:SetFont(font, 10, flags)
	_G[durCheck:GetName() .. "Text"]:SetTextColor(1,1,1)
	_G[durCheck:GetName() .. "Text"]:SetText("내구도")
	_G[durCheck:GetName() .. "Text"]:ClearAllPoints()
	_G[durCheck:GetName() .. "Text"]:SetPoint("LEFT", durCheck, "RIGHT", 0, 1)
	durCheck:SetChecked(CharInfoEnhancerOption.ShowDurability)
	durCheck:SetPoint("BOTTOMLEFT", _G["PaperDollFrame"], "BOTTOMLEFT", 6, 4)
	durCheck:SetScript("OnClick", function (self)
		CharInfoEnhancerOption.ShowDurability = self:GetChecked() and true or false
		frame:UpdatePlayerDurability()
		frame:RefreshEquipmentFlyoutUI()
	end)

	local detailCheck = CreateFrame("CheckButton", addonName.."DetailCheckButton", _G["PaperDollFrame"], "UICheckButtonTemplate")
	detailCheck:SetSize(16,16)
	_G[detailCheck:GetName() .. "Text"]:SetFont(font, 10, flags)
	_G[detailCheck:GetName() .. "Text"]:SetTextColor(1,1,1)
	_G[detailCheck:GetName() .. "Text"]:SetText("자세히")
	_G[detailCheck:GetName() .. "Text"]:ClearAllPoints()
	_G[detailCheck:GetName() .. "Text"]:SetPoint("LEFT", detailCheck, "RIGHT", 0, 0)
	detailCheck:SetChecked(CharInfoEnhancerOption.ShowDetailIcon)
	detailCheck:SetPoint("BOTTOMLEFT", _G["PaperDollFrame"], "BOTTOMLEFT", 6, 18)
	detailCheck:SetScript("OnClick", function (self)
		CharInfoEnhancerOption.ShowDetailIcon = self:GetChecked() and true or false
		frame:UpdatePlayerEquipItem()
		frame:RefreshEquipmentFlyoutUI()
	end)

	-- 성약 아이콘
	self.covenantSigil = CreateFrame("Frame", addonName.."CovenantSigil", CharacterFrame.NineSlice, "RuneforgeCovenantSigilTemplate")
	self.covenantSigil:SetPoint("CENTER", CharacterFramePortrait, "BOTTOMRIGHT", -10, 10)
	self.covenantSigil:Hide();

	frame:PLAYER_LOGIN_EquipmentFlyout()

	-- 초기화
	self.IsShowEquipmentFlyoutFrame = false

	-- 옵션 초기값 설정
	if not CharInfoEnhancerOption then CharInfoEnhancerOption = {} end
	for k, v in pairs(OPTION_INIT_LIST) do
		if CharInfoEnhancerOption[k] == nil then CharInfoEnhancerOption[k] = v end
	end

	-- 옵션 UI에 값 적용. 이것도 xml로 빼고 싶은데...
	for k, v in pairs(CharInfoEnhancerOption) do
		if self.OptionFrame[k] then self.OptionFrame[k]:SetChecked(v) end
	end
end

frame:RegisterEvent("ADDON_LOADED")
function frame:ADDON_LOADED(addon)
	-- 살펴보기 창은 처음 띄울때에 UI가 로드되기 때문에 그때에 별도로 초기화를 해야 한다.
	if addon == "Blizzard_InspectUI" then
		-- EquipitemMixin 생성
		self.InspectEquipUI = {}
		for slotID, slotName in pairs(EquipSlot) do
			self.InspectEquipUI[slotID] = self:CreateEquipItemUIMixin()
			self.InspectEquipUI[slotID]:SetSlot(nil, slotID)
			self.InspectEquipUI[slotID]:SetUpUI(_G["Inspect"..slotName])
			self.InspectEquipUI[slotID].GetUnit = function(self)
				if not frame:IsInspectFrameOpen() then return nil end
				return InspectFrame.unit
			end
		end

		-- 각종 함수 hook
		hooksecurefunc("InspectFrame_UpdateTabs", function()
			frame:UpdateInspectEquipItem()
			end)

		hooksecurefunc("InspectSwitchTabs", function(newwID)
			if newwID == 1 then self.InspectItemLevelStr:Show() 
			else self.InspectItemLevelStr:Hide() end	 
			end)		

			-- 살펴보기창 UI 추가
		local font, _, flags = NumberFontNormal:GetFont()
		self.InspectItemLevelStr = InspectFrame:CreateFontString(nil, "OVERLAY")
		self.InspectItemLevelStr:SetFont(font, 12, flags)
		self.InspectItemLevelStr:SetPoint("BOTTOMLEFT", InspectFrame, "BOTTOMLEFT", 8, 14)
		self.InspectItemLevelStr:SetTextColor(1,1,1)
	end
end

frame:RegisterEvent("INSPECT_READY");
function frame:INSPECT_READY(guid)
	self:OnInspectReady(guid)
end

function frame:UNIT_INVENTORY_CHANGED(unit)
	if (unit == "player") then
		self:UpdatePlayerEquipItem()
		self:RefreshEquipmentFlyoutUI()
	end
end

function frame:UPDATE_INVENTORY_DURABILITY()
	self:UpdatePlayerDurability()
end

function frame:PLAYER_DEAD()
	self:UpdatePlayerDurability()
end

function frame:PLAYER_REGEN_ENABLED()
	self:UpdatePlayerDurability()
end

function frame:PLAYER_UNGHOST()
	self:UpdatePlayerDurability()
end

function frame:MERCHANT_UPDATE()
	self:UpdatePlayerDurability()
end

function frame:MERCHANT_CLOSED()
	self:UpdatePlayerDurability()
end

function frame:SOCKET_INFO_UPDATE()
	self:UpdatePlayerEquipItem()
end

function frame:ITEM_UPGRADE_MASTER_UPDATE()
	self:UpdatePlayerEquipItem()
end

function frame:PLAYER_EQUIPMENT_CHANGED()
	self:UpdatePlayerEquipItem()
end

function frame:AZERITE_ESSENCE_CHANGED()
	self:UpdatePlayerEquipItem()
end

function frame:AZERITE_ESSENCE_UPDATE()
	self:UpdatePlayerEquipItem()
end

function frame:AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED()
	self:UpdatePlayerEquipItem()
end

function frame:BAG_UPDATE()
	self:RefreshEquipmentFlyoutUI()
end

function frame:VOID_STORAGE_UPDATE()
	self:RefreshEquipmentFlyoutUI()
end

--[[-----------------------------------------------------------------------------
-------------------------------------------------------------------------------]]

function frame:IsInspectFrameOpen()
	return (InspectFrame and InspectFrame:IsShown())
end

function frame:OnPaperDollFrame_SetLabelAndText(statFrame, label, text, isPercentage, numericValue)
	if not CharInfoEnhancerOption.StatPrecision then 
		return
	end

	if isPercentage or label == STAT_HASTE then
		text = format("%.2f%%", numericValue);
		statFrame.Value:SetText(text);
	end
end

function frame:OnPaperDollFrame_SetLevel()
	local covenantID = C_Covenants.GetActiveCovenantID()
	if UnitLevel("player") <= 60 and covenantID > 0 then
		-- function PaperDollFrame_SetLevel() 내용 복붙 후 편집
		local primaryTalentTree = GetSpecialization();
		local classDisplayName, class = UnitClass("player");
		local classColorString = RAID_CLASS_COLORS[class].colorStr;
		local specName, _;
	
		if (primaryTalentTree) then
			_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"));
		end
	
		local level = UnitLevel("player");
		local effectiveLevel = UnitEffectiveLevel("player");
	
		if ( effectiveLevel ~= level ) then
			level = EFFECTIVE_LEVEL_FORMAT:format(effectiveLevel, level);
		end

		local covenantName = C_Covenants.GetCovenantData(covenantID).name
		local covenantColoredName = COVENANT_COLORS[covenantID]:WrapTextInColorCode(covenantName)
	
		if (specName and specName ~= "") then
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL_STR, level, covenantColoredName, classColorString, specName, classDisplayName);
		else
			CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC_STR, level, covenantColoredName, classColorString, classDisplayName);
		end
	end
end

function frame:OnPaperDollFrame_SetItemLevel()
	-- 새로 계산할거 없고, API가 보내주는 값을 소수점 살려서 출력한다.
	local _, avgItemLevelEquipped = GetAverageItemLevel()
	local avgItemLevelStr = format("%.2f", avgItemLevelEquipped)
	CharacterStatsPane.ItemLevelFrame.Value:SetText(avgItemLevelStr)
	CharacterStatsPane.ItemLevelFrame.numericValue = avgItemLevelEquipped

	-- test
	--local calcAvgLevel = frame:GetAvgItemLevel(self.PlayerEquipUI)
	--print("calc : "..calcAvgLevel.." / api : "..avgItemLevelEquipped)
end

function frame:OnCharacterFrame_UpdatePortrait()
	local covenantID = C_Covenants.GetActiveCovenantID()
	if UnitLevel("player") <= 60 and covenantID > 0 then
		local sigilInfo = RuneforgeUtil.GetSigilInfoForCovenant(covenantID);
		self.covenantSigil:SetScale(sigilInfo.scale * 1.25);
		self.covenantSigil.Icon:SetAtlas(sigilInfo.atlas, TextureKitConstants.UseAtlasSize);
		self.covenantSigil.Icon:SetDesaturated(false);
		self.covenantSigil.UnavailableMask:SetAtlas(sigilInfo.mask);
		self.covenantSigil.DimOverlay:SetAlpha(0);
		self.covenantSigil:Show()
	else
		self.covenantSigil:Hide()
	end
end

function frame:UpdatePlayerEquipItem()
	for _, equipItem in pairs(self.PlayerEquipUI) do
		equipItem:SetTooltipData()
		equipItem:ShowItemLevelStr(true)

		if CharInfoEnhancerOption.ShowDetailIcon then
			equipItem:UpdateDetailIcon(false)
			equipItem:ShowDetailIcon(true)
		else
			equipItem:ShowDetailIcon(false)
		end
	end
end

function frame:UpdateInspectEquipItem()
	if not self:IsInspectFrameOpen() then
		return
	end

	for _, equipItem in pairs(self.InspectEquipUI) do
		equipItem:SetTooltipData()
		equipItem:ShowItemLevelStr(true)
		equipItem:UpdateDetailIcon(false)
		equipItem:ShowDetailIcon(true)
	end

	local calcAvgLevel = frame:GetAvgItemLevel(self.InspectEquipUI)
	self.InspectItemLevelStr:SetText(string.format(AVG_ITEM_LEVEL_STR, calcAvgLevel))
end

function frame:UpdatePlayerDurability()
	for _, equipItem in pairs(self.PlayerEquipUI) do
		equipItem:ShowDurabilityStr(CharInfoEnhancerOption.ShowDurability)
	end
end

function frame:GetAvgItemLevel(equipTable)
	local sum = 0
	local count = 0
	for slotID, equipItem in pairs(equipTable) do
		-- 무기는 별도 처리
		if slotID == INVSLOT_MAINHAND or slotID == INVSLOT_OFFHAND then
			-- not to do
		else
			sum = sum + (equipItem:IsEquipped() and equipItem.itemLevel or 0)
			count = count + 1
		end
	end

	-- 각종 문서들에는 양손무기면 보조를 빼고 계산한다던데, 실제론 아니다.
	-- 양손 무기를 어느 한쪽 손에 장착했을때, 그것이 다른쪽 손의 템렙보다 높다면, 그걸 쌍수로 낀걸로 처리한다. 그렇지 않다면 양쪽 손의 템렙을 각각 더한다- 라는 규칙을 적용해야 API와 동일한 평균템렙이 나온다.
	function CheckTwoHand(unit, slotID)
		local itemLink = GetInventoryItemLink(unit, slotID)
		if not itemLink then return nil end
		local itemEquipLoc = select(9, GetItemInfo(itemLink))
		return ("INVTYPE_2HWEAPON" == itemEquipLoc or "INVTYPE_RANGED" == itemEquipLoc or "INVTYPE_RANGEDRIGHT" == itemEquipLoc)
	end
	local mainHandLevel = equipTable[INVSLOT_MAINHAND]:IsEquipped() and equipTable[INVSLOT_MAINHAND].itemLevel or 0
	local isMainHandTwoHand = equipTable[INVSLOT_MAINHAND]:IsEquipped() and CheckTwoHand(equipTable[INVSLOT_MAINHAND]:GetUnit(), INVSLOT_MAINHAND) or false
	local offHandLevel = equipTable[INVSLOT_OFFHAND]:IsEquipped() and equipTable[INVSLOT_OFFHAND].itemLevel or 0
	local isOffHandTwoHand = equipTable[INVSLOT_OFFHAND]:IsEquipped() and CheckTwoHand(equipTable[INVSLOT_OFFHAND]:GetUnit(), INVSLOT_OFFHAND) or false

	if isMainHandTwoHand and mainHandLevel >= offHandLevel then
		sum = sum + (mainHandLevel * 2)
	elseif isOffHandTwoHand and offHandLevel >= mainHandLevel then
		sum = sum + (offHandLevel * 2)		
	else
		sum = sum + mainHandLevel + offHandLevel
	end
	count = count + 2

	return sum / count
end

function frame:OnUpdate(elapsed)
	self:OnUpdate_TooltipInspect(elapsed)

	if self.IsShowEquipmentFlyoutFrame == false and EquipmentFlyoutFrame:IsShown() then
		self:RefreshEquipmentFlyoutUI()
		self.IsShowEquipmentFlyoutFrame = true
	end

	if self.IsShowEquipmentFlyoutFrame == true and EquipmentFlyoutFrame:IsShown() == false then
		self.IsShowEquipmentFlyoutFrame = false
	end
end


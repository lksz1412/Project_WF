local addOnName = ...
local BII3 = _G[addOnName]

local thisItem
local added = "%s의 메모가 |cff10ff10%s|r|1으로;로; 추가되었습니다."
local edited = "%s의 메모가 |cff10ff10%s|r|1으로;로; 변경되었습니다."
local deleted = "%s의 메모가 삭제되었습니다."

local LBI = LibStub("LibBlueItem-1.0")

local function getItemName(id)
	if id > 0 then
			return select(2, GetItemInfo(id)) or BII3:GetItemLink(id) or BII3:GetItemColorName(id)
	else
		return BII3:GetItemLink(id) or BII3:GetItemColorName(id)
	end
end

function BII3:AddMemo(id)
	thisItem = self.linkedItemID[id] or id
	StaticPopup_Show("BlueItemInfo3EditMemo", getItemName(id))
end

local function editMemo(text)
	text = (text or ""):trim()
	if text == "" then
		BII3.db.memo[thisItem] = nil
		DEFAULT_CHAT_FRAME:AddMessage(deleted:format(getItemName(thisItem)))
	elseif not BII3.db.memo[thisItem] then
		BII3.db.memo[thisItem] = text
		DEFAULT_CHAT_FRAME:AddMessage(added:format(getItemName(thisItem), text))
	elseif BII3.db.memo[thisItem] ~= text then
		BII3.db.memo[thisItem] = text
		DEFAULT_CHAT_FRAME:AddMessage(edited:format(getItemName(thisItem), text))
	end
	thisItem = nil
end

StaticPopupDialogs["BlueItemInfo3EditMemo"] = {
	text = "%s의 메모를 입력하세요.",
	button1 = OKAY,
	button2 = CANCEL,
	sound = "levelup2",
	whileDead = 1,
	hideOnEscape = 1,
	timeout = 0,
	hasEditBox = 1,
	OnShow = function(self)
		self.editBox:SetText(BII3.db.memo[thisItem] or "")
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	EditBoxOnEnterPressed = function(self)
		editMemo(self:GetText())
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		histItem = nil
		self:GetParent():Hide()
	end,
	OnAccept = function(self)
		editMemo(self.editBox:GetText())
	end,
	OnCancel = function()
		histItem = nil
	end,
}
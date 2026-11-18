local thisItem
local _G = getfenv(0)

local function getMemoText(id)
	if id and BlueItemInfo2DB.memo[id] then
		return BlueItemInfo2DB.memo[id]
	else
		return ""
	end
end

local function editMemo(id, text)
	if not id then return end
	local _, colorName = BlueItemInfo2:GetItemInfo(id)
	if text == nil or text == "" then
		if BlueItemInfo2DB.memo[id] then
			DEFAULT_CHAT_FRAME:AddMessage(colorName.."의 메모가 삭제되었습니다.")
		end
		BlueItemInfo2DB.memo[id] = nil
	else
		if BlueItemInfo2DB.memo[id] then
			DEFAULT_CHAT_FRAME:AddMessage(colorName.."의 메모가 |cff10ff10"..text.."|r|1으로;로; 변경되었습니다.")
		else
			DEFAULT_CHAT_FRAME:AddMessage(colorName.."의 메모가 |cff10ff10"..text.."|r|1으로;로; 추가되었습니다.")
		end
		BlueItemInfo2DB.memo[id] = text
	end
end

function BlueItemInfo2:InitMemo()
	StaticPopupDialogs["BlueItemInfo2EditMemo"] = {
		text = "%s의 아이템 메모를 입력하세요.",
		button1 = OKAY,
		button2 = CANCEL,
		sound = "levelup2",
		whileDead = 1,
		hideOnEscape = 1,
		timeout = 0,
		OnShow = function()
			_G[this:GetName().."EditBox"]:SetText(getMemoText(thisItem))
		end,
		OnHide = function()
			if ChatFrameEditBox:IsShown() then
				ChatFrameEditBox:SetFocus()
			end
			_G[this:GetName().."EditBox"]:SetText("")
			thisItem = nil
		end,
		EditBoxOnEnterPressed = function()
			local text = _G[this:GetParent():GetName().."EditBox"]:GetText()
			editMemo(thisItem, text)
			this:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function()
			_G[this:GetName().."EditBox"]:SetText("")
			this:GetParent():Hide()
		end,
		OnAccept = function()
			local text = _G[this:GetParent():GetName().."EditBox"]:GetText()
			editMemo(thisItem, text)
		end,
		OnCancel = function()
			this:GetParent():Hide()
		end,
		hasEditBox = 1,
	}
end

function BlueItemInfo2:AddMemo(id)
	if not id then return end
	local _, colorName = self:GetItemInfo(id)
	thisItem = id
	StaticPopup_Show("BlueItemInfo2EditMemo", colorName)
end
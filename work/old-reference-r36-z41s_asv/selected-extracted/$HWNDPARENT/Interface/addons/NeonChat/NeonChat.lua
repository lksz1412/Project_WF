local AddOn = "|cFFFF7733NeonChat:|r "

NeonChatDefaults = {
	background = 0.75,
	border = 1,
}

if not NeonChatDB then NeonChatDB = NeonChatDefaults end

local function printhelp()
	ChatFrame1:AddMessage(AddOn.."slashcommands:")
	ChatFrame1:AddMessage("    ' /neonchat background value ' - where value is '0-1'")
	ChatFrame1:AddMessage("    ' /neonchat border value ' - where value is '0-1'")
end

SLASH_NEONCHAT1 = "/neonchat"
SlashCmdList["NEONCHAT"] = function(value)
	local a,b = strsplit(" ", value, 2)
	if (a == "border" or a == "background") then
		if (b == nil or b == "") then
			printhelp()
		elseif (b == "0" or b == "1") or (b > "0" and b < "1") then
			NeonChatDB[a] = b
		else
			ChatFrame1:AddMessage(AddOn.."|cFFFF0000Error:|r "..a.." Use value between 0-1. ie: 0.5.")
		end
	else
		printhelp()
	end
end

select(6, ChatFrameEditBox:GetRegions()):Hide()
select(7, ChatFrameEditBox:GetRegions()):Hide()
select(8, ChatFrameEditBox:GetRegions()):Hide()

local editbox = CreateFrame("Button", nil, ChatFrameEditBox)
editbox:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 14, insets = {left = 3, right = 3, top = 3, bottom = 3}})
editbox:ClearAllPoints()
editbox:SetPoint("TOPLEFT", "ChatFrameEditBoxLeft", "TOPLEFT", 2, -2)
editbox:SetPoint("BOTTOMRIGHT", "ChatFrameEditBoxRight", "BOTTOMRIGHT", -2, 2)
editbox:SetFrameLevel(ChatFrameEditBox:GetFrameLevel()-1)
editbox:Show()

hooksecurefunc("ChatEdit_UpdateHeader", function()
	local type = DEFAULT_CHAT_FRAME.editBox:GetAttribute("chatType")
	if ( type == "CHANNEL" ) then
		local id = GetChannelName(DEFAULT_CHAT_FRAME.editBox:GetAttribute("channelTarget"))
		if id == 0 then
			editbox:SetBackdropBorderColor(0.5,0.5,0.5,NeonChatDB.border)
		else
			editbox:SetBackdropBorderColor(ChatTypeInfo[type..id].r,ChatTypeInfo[type..id].g,ChatTypeInfo[type..id].b,NeonChatDB.border)
		end
	else
		editbox:SetBackdropBorderColor(ChatTypeInfo[type].r,ChatTypeInfo[type].g,ChatTypeInfo[type].b,NeonChatDB.border)
	end
	editbox:SetBackdropColor(ChatTypeInfo[type].r/10,ChatTypeInfo[type].g/10,ChatTypeInfo[type].b/10,NeonChatDB.background)
end)
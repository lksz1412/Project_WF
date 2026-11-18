function ND_ItemID_Button_OnClick()
	if ND_ItemID_Frame:IsVisible() then
		HideUIPanel(ND_ItemID_Frame);
	else
		ShowUIPanel(ND_ItemID_Frame);
		ND_ItemID_FrameEdit:SetFocus();
	end
end

function ND_ItemID_Search()

	local _, _, userLink = string.find(ND_ItemID_FrameEdit:GetText(), "([-0-9]+:?[-0-9]*:?[-0-9]*:?[-0-9]*:?[-0-9]*:?[-0-9]*:?[-0-9]*:?[-0-9]*)");

	if (userLink) then

		local sVar;

		if (tonumber(userLink)) then
			if (tonumber(userLink) <= 50000) and (tonumber(userLink) > 1) then
				sVar = userLink..":0:0:0:0:0:0:0";
			else
				NuguDrop_Print("|CFFA2D96F아이템 ID가 잘못되었습니다! (0~50000)|r");
				return nil;
			end
		else
			local sChk2 = string.gsub(userLink, "([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+)", "%8")
			if (not tonumber(sChk2)) then
				NuguDrop_Print("|CFFA2D96F아이템 ID가 잘못되었습니다!|r");
				return nil;
			end
			sVar = userLink;
		end

		if (not sVar) then NuguDrop_Print("|CFFA2D96F아이템 ID가 잘못되었습니다!|r"); return nil; end

		local coreid = string.gsub(sVar, "([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+)", "%1")
		local regid = string.gsub(sVar, "([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+)", "%1:0:0:0:0:0:%7:0")
		local subid = string.gsub(sVar, "([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+):([-0-9]+)", "%7")

		ND_ItemID_Start("item:"..sVar,coreid,subid);

	else
		NuguDrop_Print("|CFFA2D96F아이템 ID가 잘못되었습니다!|r");
	end
end

function ND_ItemID_Start(link, coreid, subid)

	if (not link or not coreid or not subid) then
		NuguDrop_Print("|CFFA2D96F아이템 ID가 잘못되었습니다!|r");
		return nil;
	end

	local frame = getglobal("ND_ItemID_Frame")
	if (not frame) then return nil; end

	ND_ItemID_Frame.TooltipButton = frame:GetID();
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");

	GameTooltip:SetHyperlink(link);
	GameTooltip:Show();
	GameTooltip:Hide();

	ND_ItemID_StartShow(link, coreid, subid, frame);
end

function ND_ItemID_StartShow(link, coreid, subid, frame)

	if (not link or not coreid or not frame or not subid) then
		NuguDrop_Print("|cffFC5252아이템 확인 실패!|r");
		return nil;
	end

	local itemName, ilink, itemRarity = GetItemInfo(tonumber(coreid));
	if (ilink) then
		NuguDrop_Print("|cffA2D96F아이템 확인 성공!|r");
		NuguDrop_Print(ilink.."  ▶아이템ID : "..coreid);

		ND_ItemID_FrameEdit:AddHistoryLine(ND_ItemID_FrameEdit:GetText());
		ND_ItemID_FrameEdit:SetText("");
	else
		NuguDrop_Print("|cffFC5252서버조회 시도!|r 다시 |cffffff00엔터|r를 누르면 |cffff9C00링크확인|r이 가능합니다. 확인이 안되는 경우는 아직 해당 아이템이 서버내에 존재하지 않기 때문입니다.|r");
	end
end
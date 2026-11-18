local aTotemBar
aTotemBarDB = {}

local TotemButtons = {
    	MultiCastSummonSpellButton,
	MultiCastActionPage1,
	MultiCastActionPage2,
	MultiCastActionPage3,
	MultiCastSlotButton1,
	MultiCastSlotButton2,
	MultiCastSlotButton3,
	MultiCastSlotButton4,
	MultiCastFlyoutFrame,
	MultiCastFlyoutButton,
    	MultiCastRecallSpellButton,
}

function aTotemBar_OnEvent(event)
	if event=="VARIABLES_LOADED" then
		if UnitLevel("player") >= 30 and select(2, UnitClass("player")) == "SHAMAN" then
			aTotemBar = CreateFrame("Frame","aTotemBar",UIParent)
  			aTotemBar:SetWidth(230)
  			aTotemBar:SetHeight(40)

			if (aTotemBarDB.Anchor == nil) or (aTotemBarDB.Anchor == 0) then
				aTotemBarDB.Anchor = "BOTTOM";
				aTotemBarDB.X = -230;
				aTotemBarDB.Y = 240;
				aTotemBarDB.Hide = false;
				aTotemBarDB.Scale = 0.9
			end
			-- For Compatability
			if (aTotemBarDB.Scale == nil) or (aTotemBarDB.Scale == 0) then
				aTotemBarDB.Scale = 0.9
			end
			aTotemBar:SetScale(aTotemBarDB.Scale)
 			aTotemBar:Show()
			aTotemBar:SetPoint(aTotemBarDB.Anchor,"UIParent",aTotemBarDB.Anchor,aTotemBarDB.X, aTotemBarDB.Y)

			for _, f in pairs(TotemButtons) do
				f:SetParent(aTotemBar);
			end
			MultiCastSummonSpellButton:ClearAllPoints();
			MultiCastSummonSpellButton:SetPoint("BOTTOMLEFT", 3, 3);
			local page;
			for i = 1, NUM_MULTI_CAST_PAGES do
				page = _G["MultiCastActionPage"..i];
				page:SetPoint("BOTTOMLEFT", 50, 3);
    			end
 			MultiCastRecallSpellButton:SetPoint("BOTTOMLEFT", 50, 3);
			if (aTotemBarDB.Hide == true) then
			  	aTotemBar:SetScale(0.0001)
				aTotemBar:SetAlpha(0.0)
			end
			aTotemBar:SetScript("OnMouseDown",function()
  			aTotemBar:StartMoving()
			end)
			aTotemBar:SetScript("OnMouseUp",function()
  			aTotemBar:StopMovingOrSizing()
			end)
		end
	end
end

SLASH_ATOTEMBAR1 = '/atbar';
SLASH_ATOTEMBAR2 = '/토템바';
local function handler(msg, editbox)
	if UnitLevel("player") < 30 and select(2, UnitClass("player")) ~= "SHAMAN" then
		print("aTotemBar: You are not a shaman or do not meet the level requirement.");
		return;
	end
	local command, rest = msg:match("^(%S*)%s*(.-)$");
 	if command == 'hide' then
		if (aTotemBarDB.Hide == false) then
  			aTotemBar:SetScale(0.0001)
			aTotemBar:SetAlpha(0.0)
			aTotemBarDB.Hide = true
		else
  			aTotemBar:SetScale(aTotemBarDB.Scale)
			aTotemBar:SetAlpha(1.0)
			aTotemBarDB.Hide = false
		end
	elseif command == 'lock' then
		if (aTotemBar:IsMovable()) then
			aTotemBar:SetMovable(false)
			aTotemBar:EnableMouse(false)
			aTotemBar:SetBackdrop(nil)
			local point, relativeTo, relativePoint, xOfs, yOfs = aTotemBar:GetPoint()
			aTotemBarDB.Anchor = point
			aTotemBarDB.X = xOfs
			aTotemBarDB.Y = yOfs
		else
			aTotemBar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",nil,
                                            tile = true, tileSize = 16, edgeSize = 16,
                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }});
			aTotemBar:SetBackdropColor(0,0,0,1);
			aTotemBar:SetMovable(true)
			aTotemBar:EnableMouse(true)
		end
	elseif command == 'scale' then
		if rest ~= "" then
			aTotemBar:SetScale(rest)
			aTotemBarDB.Scale = rest
		else
			print("크기 설정: /atbar scale X.X");
			print("X.X 값은 0.1에서 2.0 사이의 값으로 변경하세요.");
		end
	else
		print("창 위치 잠금 전환: /atbar lock");
		print("표시 전환: /atbar hide");
		print("크기 설정: /atbar scale 0.9");
 	end
end
SlashCmdList["ATOTEMBAR"] = handler;

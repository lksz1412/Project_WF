function DevilSkin_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
end

function DevilSkin_OnEvent()
	if (event == "VARIABLES_LOADED") then
		if (DevilSkin_FirstSetup == nil) then
			DevilSkin_FirstSetup = true;
		end
		
		if (DevilSkin_FirstSetup) then
			DevilSkin_FramePosition();
--			FindParty_FramePosition();
			DevilSkin_FirstSetup = false;
		end
	end
end

function DevilSkin_FramePosition()
		ChatFrame1:StartMoving();
		ChatFrame1:ClearAllPoints();
		ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 12, 34);
		ChatFrame1:SetWidth(426);
		ChatFrame1:SetHeight(150);
		ChatFrame1:StopMovingOrSizing();
end
--[[
function FindParty_FramePosition()
		FP_IconFrame:StartMoving();
		FP_IconFrame:ClearAllPoints();
		FP_IconFrame:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -586, 28);
		FP_IconFrame:SetWidth(34);
		FP_IconFrame:SetHeight(34);
		FP_IconFrame:StopMovingOrSizing();
end
]]
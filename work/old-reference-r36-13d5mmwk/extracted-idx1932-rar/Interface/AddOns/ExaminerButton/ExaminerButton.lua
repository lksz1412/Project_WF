-- Saved Data Tables
ExaminerButton_Config = {
};

--------------------------------------------------------------------------------------------------------
--                                           Event Handling                                           --
--------------------------------------------------------------------------------------------------------
function ExaminerButton_OnEvent(event)
	if( event == "PLAYER_TARGET_CHANGED" ) then
		if( ExaminerButton_Config.off == nil ) then

			if( ExaminerButton_Config.skin == 0 or ExaminerButton_Config.skin == nil) then
				if ( UnitIsVisible("target")) then
					ExaminerButton_Config.skin = 0
					ExaminerButtonFrame1:Show();
				else
					ExaminerButtonFrame1:Hide();
				end
			elseif ( ExaminerButton_Config.skin == 1 ) then
				if ( UnitIsVisible("target")) then
					ExaminerButtonFrame2:Show();
				else
					ExaminerButtonFrame2:Hide();
				end
			elseif ( ExaminerButton_Config.skin == 2 ) then
				if ( UnitIsVisible("target")) then
					ExaminerButtonFrame3:Show();
				else
					ExaminerButtonFrame3:Hide();
				end
			end

		else
			ExaminerButtonFrame1:Hide();
			ExaminerButtonFrame2:Hide();
			ExaminerButtonFrame3:Hide();
		end
	end
end

function ExaminerButton_OnDragStart()
	this:StartMoving()
end

function ExaminerButton_OnDragStop()
	this:StopMovingOrSizing()
end

--------------------------------------------------------------------------------------------------------
--                                           Slash Handling                                           --
--------------------------------------------------------------------------------------------------------
function ExaminerButton_OnSlash(cmd)
	-- Extract paramters
	local _,_,param1,param2 = string.find(cmd,"^([^%s]+)%s*(.*)$");
	if (param1 == nil) then
		param1 = string.lower(cmd);
	else
		param1 = string.lower(param1);
	end

	if (param1 == "show") then

		if (ExaminerButton_Config.off) then
			ExaminerButton_Config.off = nil;
			if (ExaminerButton_Config.skin == 0 or ExaminerButton_Config.skin == nil) then
				ExaminerButtonFrame1:Show();
				ExaminerButtonFrame2:Hide();
				ExaminerButtonFrame3:Hide();
			elseif (ExaminerButton_Config.skin == 1) then 
				ExaminerButtonFrame1:Hide();
				ExaminerButtonFrame2:Show();
				ExaminerButtonFrame3:Hide();
			elseif (ExaminerButton_Config.skin == 2) then 
				ExaminerButtonFrame1:Hide();
				ExaminerButtonFrame2:Hide();
				ExaminerButtonFrame3:Show();
			end
			AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_SHOW);
		else
			ExaminerButton_Config.off = 1;
			ExaminerButtonFrame1:Hide();
			ExaminerButtonFrame2:Hide();
			ExaminerButtonFrame3:Hide();
			AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_HIDE);
		end

	elseif (param1 == "skin") then

		if (ExaminerButton_Config.skin == 2 or ExaminerButton_Config.skin == nil) then
			ExaminerButton_Config.skin = 0;
			ExaminerButtonFrame1:Show();
			ExaminerButtonFrame2:Hide();
			ExaminerButtonFrame3:Hide();
			AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_SKIN1);
		elseif (ExaminerButton_Config.skin == 0) then
			ExaminerButton_Config.skin = 1;
			ExaminerButtonFrame1:Hide();
			ExaminerButtonFrame2:Show();
			ExaminerButtonFrame3:Hide();
			AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_SKIN2);
		elseif (ExaminerButton_Config.skin == 1) then
			ExaminerButton_Config.skin = 2;
			ExaminerButtonFrame1:Hide();
			ExaminerButtonFrame2:Hide();
			ExaminerButtonFrame3:Show();
			AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_SKIN3);		
		end

	elseif (param1 == "reset") then

		ExaminerButtonFrame1:ClearAllPoints();
		ExaminerButtonFrame2:ClearAllPoints();
		ExaminerButtonFrame3:ClearAllPoints();
		ExaminerButtonFrame1:SetPoint("CENTER", "UIParent", "CENTER", 0, -0);
		ExaminerButtonFrame2:SetPoint("CENTER", "UIParent", "CENTER", 0, -0);
		ExaminerButtonFrame3:SetPoint("CENTER", "UIParent", "CENTER", 0, -0);
		AzMsg("|cff20ff20"..EXAMINERBUTTON_MSG_RESET);

	--------------------------------------------------------------------------------------------------------
	--                                                                                      --
	--------------------------------------------------------------------------------------------------------

	else
		AzMsg("----- |2"..Examiner.modName.."_Button|r "..Examiner.modVers.." -----");
		AzMsg(EXAMINERBUTTON_USAGE1);
		AzMsg(EXAMINERBUTTON_USAGE2);
		AzMsg(EXAMINERBUTTON_USAGE3);
		AzMsg(EXAMINERBUTTON_USAGE4);
	end

end

--------------------------------------------------------------------------------------------------------
--                                               OnLoad                                               --
--------------------------------------------------------------------------------------------------------
function ExaminerButton_OnLoad()
	-- Events
	this:RegisterEvent("PLAYER_TARGET_CHANGED");

	-- Add slash command
	SlashCmdList["EXAMINERBUTTON"] = ExaminerButton_OnSlash;
	SLASH_EXAMINERBUTTON1 = "/exbutton";
	SLASH_EXAMINERBUTTON2 = "/exb";
	-- Default Config

	ExaminerButton_Config.off = nil;
	ExaminerButton_Config.skin = nil;

	this:RegisterForDrag("RightButton");
end
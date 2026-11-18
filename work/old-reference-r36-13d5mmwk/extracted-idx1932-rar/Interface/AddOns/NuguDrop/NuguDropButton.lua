function NuguDropButton_OnClick(arg1)
	-- 좌클릭시만 브라우저를 보여줌
	if arg1=="LeftButton" then
		if NuguDropListFrame:IsVisible() then
			HideUIPanel(NuguDropListFrame);
			HideUIPanel(NuguDropListFrameMobList);
			HideUIPanel(NuguDropListFrameItemList);
		else
			ShowUIPanel(NuguDropListFrame);
		end
	-- 가운데 버튼
    elseif arg1=="MiddleButton" then
		-- 미니맵 버튼 고정 토글
		if (IsShiftKeyDown()) then
			NuguDropOption.ND_MoveFree = not NuguDropOption.ND_MoveFree;
			if NuguDropOption.ND_MoveFree then
				NuguDrop_Print("이제부터 미니맵 버튼이 고정됩니다.");
				this:RegisterForDrag();
			else
				NuguDrop_Print("이제부터 미니맵 버튼을 마우스 드래그로 자유롭게 이동시킬 수 있습니다.");
				this:RegisterForDrag("LeftButton", "RightButton");
			end
		else
			-- 버튼 위치 초기화(미니맵 서쪽중앙)
			NuguDrop_Print("미니맵 버튼 위치가 초기화 되었습니다.(미니맵 제일 왼쪽)");
	        NuguDrop_MoveButton(0);
		end
	-- 쉬프트 우클릭시 미니맵에 종속적인 윈치 설정(예전) - 좀 더 보완할 것
    elseif arg1=="RightButton" then
		if (IsShiftKeyDown()) then
			NuguDropButton_BeingDragged = true;
			this:SetScript("OnUpdate", function() NuguDropButton_MovingRound(arg1) end);
		else
	-- 그냥 우클릭시 즐겨찾기창 팝업
			ND_Favorites();
		end
	-- 사각형 미니맵 종속적인 이동을 위한 부분 추가해야 함
    end
end

function NuguDropButton_Toggle()
	if (NuguDropButton:IsVisible()) then
		NuguDropOption.ButtonShow = 0;
		NuguDropButton:Hide();
		NuguDrop_Print("이제부터 미니맵 버튼을 숨김니다.");
	else
		NuguDropOption.ButtonShow = 1;
		NuguDropButton:Show();
		NuguDrop_Print("이제부터 미니맵 버튼이 보이게 합니다.");
	end
end

function NuguDropButton_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		NuguDropButton_OnVariablesLoaded();
	end
end

function NuguDropButton_OnVariablesLoaded()
	if (not NuguDropOption.ButtonShow) then
		NuguDropOption.ButtonShow = 1;
	end

	if (NuguDropOption.ButtonShow == 1) then
		NuguDropStateHeader:Show();
		NuguDropButton:Show();
	else
		NuguDropStateHeader:Hide();
	end
	NuguDropStateHeader:SetAttribute("state", "0");
	this:UnregisterEvent("VARIABLES_LOADED");
end

-- 미니맵 버튼이 자유로운 이동을 하게 하는 함수
function NuguDropButton_OnDragStart()
	-- 미니맵 버튼을 고정시켜놨을 때는 미작동
	if (not NuguDropOption.ND_MoveFree) then
		-- 쉬프트 우클릭으로 원모양의 미니맵에 종속적인 위치이동시에도 미작동
		if (not NuguDropButton_BeingDragged) then
			this:StartMoving();
			NuguDropButton_BeingDragged = true;
		end
	end
end

function NuguDropButton_OnDragStop()
	if (NuguDropButton_BeingDragged) then
			this:StopMovingOrSizing()
		NuguDropButton_BeingDragged = false;
		this:SetScript("OnUpdate", function() end);
	end
end

function NuguDrop_MoveButton(x)
	NuguDropButton:ClearAllPoints();
	NuguDropButton:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		52 - (80 * cos(x or NuguDropOption.NuguDropButtonPos)),
		(80 * sin(x or NuguDropOption.NuguDropButtonPos)) - 52
	);

end

function NuguDropButton_MovingRound(arg1)
	if (arg1=="RightButton") and (IsShiftKeyDown()) then
		local xpos, ypos = GetCursorPosition();
		local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom();

		xpos = xmin - xpos / UIParent:GetScale() + 70;
		ypos = ypos / UIParent:GetScale() - ymin - 70;

		NuguDropOption.NuguDropButtonPos = math.deg(math.atan2(ypos, xpos));
		NuguDrop_MoveButton();
	end
end
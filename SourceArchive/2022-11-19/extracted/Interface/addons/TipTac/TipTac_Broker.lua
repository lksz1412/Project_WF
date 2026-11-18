
  TTB = CreateFrame("Frame", "Broker_Tiptac")
 
TTB.obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_TipTac", {
	type = "launcher",
	label = "Tiptac Broker",
	icon = "Interface\\Icons\\INV_Misc_Note_04",
	text = "TipTac 설정"
	})


function TTB.obj.OnClick(self, button)
local loaded, reason = LoadAddOn("TipTacOptions");
 if (loaded) then
  if button == "LeftButton" and (TipTacOptions:IsShown()) then
    TipTacOptions:Hide();
  elseif button == "LeftButton" then
    TipTacOptions:Show();
  elseif button == "RightButton" and (TipTac:IsVisible()) then  
    TipTac:Hide();
  elseif button == "RightButton" then
    TipTac:Show();  
  else return    
  end
 end
end

function TTB.obj.OnTooltipShow(tt)

tt:AddLine("|cFF00FFFFTiptac_Broker")
tt:AddLine(">> |cFFFFFFFF마우스 좌클릭: Tiptac 설정 메뉴창를 여닫을 수 있습니다.|r\n>> |cFFFFFFFF마우스 우클릭: TipTac 툴팁 위치 조절 프레임을 여닫을 수 있습니다.|r")
tt:AddLine("\nTipTac은 기본 툴팁을 개선, 강화한 애드온으로 설정창을 통한 \n옵션을 조절하여 자신만의 툴팁을 만들어 낼 수 있습니다.")
tt:AddLine("|cFFFFFFFF\n예) 툴팁 크기, 글꼴, 배경, 직업별 색상, 아이템 등급 색 등을 표현 및 조절")
-- tt:show()
end

--[[
function TTB.obj.OnTooltipShow(gtt)

gtt:AddLine("Tiptac_Broker",1,1,1)
gtt:AddLine("|cFFFF46C5>> 마우스 좌클릭: Tiptac 설정 메뉴창를 여닫을 수 있습니다.\n>> 마우스 우클릭: TipTac 툴팁 위치 조절 프레임을 여닫을 수 있습니다.")

end
]]--

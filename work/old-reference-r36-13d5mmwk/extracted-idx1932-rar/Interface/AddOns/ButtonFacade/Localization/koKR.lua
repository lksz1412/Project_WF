local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:NewLocale( "ButtonFacade", "koKR", false )

if L then
	L["BF"] = "BF" -- Short for ButtonFacade
	L["ButtonFacade"] = "ButtonFacade"
	L["|cffffff00Right-click|r to open the Configuration GUI"] = "|cffffff00우-클릭|r: 설정 GUI 열기"
	L["Apply skin to all registered buttons."] = "등록된 모든 버튼에 스킨을 적용합니다."
	L["Apply skin to all buttons registered with %s."] = "%s|1으로;로; 등록된 모든 버튼에 스킨을 적용합니다."
	L["Apply skin to all buttons registered with %s/%s."] = "%s/%s|1으로;로; 등록된 모든 버튼에 스킨을 적용합니다."
	L["Apply skin to all buttons registered with %s/%s/%s."] = "%s/%s/%s|1으로;로; 등록된 모든 버튼에 스킨을 적용합니다."
	L["Elements"] = "구성 요소"
	L["Skin"] = "스킨"
	L["Gloss"] = "빛남"
	L["Backdrop"] = "배경"
	L["Color Options"] = "색상 옵션"
	L["Flash"] = "번쩍임"
	L["Normal Border"] = "보통의 테두리"
	L["Pushed Border"] = "눌려진 테두리"
	L["Disabled Border"] = "비활성화된 테두리"
	L["Checked"] = "체크된 테두리"
	L["Equipped"] = "장착된 테두리"
	L["Highlight"] = "강조"
	L["Reset Colors"] = "색상 초기화"
	L["FuBar options"] = "FuBar 옵션"
	L["Attach to minimap"] = "미니맵에 붙이기"
	L["Hide minimap/FuBar icon"] = "미니맵/FuBar 아이콘 숨기기"
	L["Show icon"] = "아이콘 보이기"
	L["Show text"] = "문자 보이기"
	L["Position"] = "위치"
	L["Left"] = "좌"
	L["Center"] = "정중앙"
	L["Right"] = "우"
end

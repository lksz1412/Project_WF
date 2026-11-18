local cfg = TipTac_Config;
local modName = "TipTac";

-- classic support
local isWoWClassic, isWoWBcc, isWoWWotlkc, isWoWSl, isWoWRetail = false, false, false, false, false;
if (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_CLASSIC"]) then
	isWoWClassic = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_BURNING_CRUSADE_CLASSIC"]) then
	isWoWBcc = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_WRATH_CLASSIC"]) then
	isWoWWotlkc = true;
else -- retail
	if (_G["LE_EXPANSION_LEVEL_CURRENT"] == _G["LE_EXPANSION_SHADOWLANDS"]) then
		isWoWSl = true;
	else
		isWoWRetail = true;
	end
end

-- DropDown Lists
local DROPDOWN_FONTFLAGS = {
	["|cffffa0a0없음"] = "", --["|cffffa0a0None"] = "",
	["얇은 테두리"] = "OUTLINE", --["Outline"] = "OUTLINE",
	["두꺼운 테두리"] = "THICKOUTLINE", --["Thick Outline"] = "THICKOUTLINE",
	["그림자"] = "SHADOW",
};
local DROPDOWN_ANCHORTYPE = {
	["기본 위치"] = "normal", --["Normal Anchor"] = "normal",
	["마우스 위치"] = "mouse", --["Mouse Anchor"] = "mouse",
	["원래 위치"] = "parent", --["Parent Anchor"] = "parent",
};

local DROPDOWN_ANCHORPOS = {
	["위"] = "TOP", --["Top"] = "TOP",
	["왼쪽 위"] = "TOPLEFT", --["Top Left"] = "TOPLEFT",
	["오른쪽 위"] = "TOPRIGHT", --["Top Right"] = "TOPRIGHT",
	["아래"] = "BOTTOM", --["Bottom"] = "BOTTOM",
	["왼쪽 아래"] = "BOTTOMLEFT", --["Bottom Left"] = "BOTTOMLEFT",
	["오른쪽 아래"] = "BOTTOMRIGHT", --["Bottom Right"] = "BOTTOMRIGHT",
	["왼쪽"] = "LEFT", --["Left"] = "LEFT",
	["오른쪽"] = "RIGHT", --["Right"] = "RIGHT",
	["가운데"] = "CENTER", --["Center"] = "CENTER",
};

local DROPDOWN_BARTEXTFORMAT = {
	["|cffffa0a0없음"] = "none", --["|cffffa0a0None"] = "none",
	["백분율"] = "percent", --["Percentage"] = "percent",
	["단일 실수치(영)"] = "current", --["Current Only"] = "current",
	["실수치(영)"] = "value", --["Values"] = "value",
	["실수치(영) + 백분율"] = "full", --["Values & Percent"] = "full",
	["손실치"] = "deficit", --["Deficit"] = "deficit",
-- Add to More Option : Start
	["실수치(한)"] = "autok",
	["단일 실수치(한)"] = "currentk",
	["실수치(한) + 백분율"] = "autokmix",
	["손실치 + 손실율"] = "deficitmix",
-- Add to More Option : End

};
--[[ 특성 형태 (사슴님 추가)
local DROPDOWN_TALENTFORMAT = {
	["이름(xx) 이름(xx) 이름(xx)"] = 2,
	["이름(xx)"] = 3,
	["이름 xx/xx/xx"] = 1,
};]]

-- 대화창의 링크에 대한 마우스 툴팁 위치 메뉴 추가 : Start
TipTacLayouts.M_anchor = {--TipTacDropDowns.M_anchor = {
	["툴팁 위치"] = "default",
	["대화창 위"] = "chatframe",
	["마우스 위치"] = "mouse",
};
-- 대화창의 링크에 대한 마우스 툴팁 위치 메뉴 추가 : End

-- 툴팁에 아이콘 표시 위치 추가 : Start
TipTacLayouts.IconPosition = {--TipTacDropDowns.IconPosition = {
	["툴팁 바깥"] = "outIcon",
	["툴팁 안쪽"] = "inIcon",
	["왼쪽 상단"] = "LEFT",  -- 아이콘 위치 추가
	["상단 왼쪽"] = "TOP",  -- 아이콘 위치 추가
};
-- 툴팁에 아이콘 표시 위치 추가 : End

-- Options -- The "y" value of a category subtable, will further increase the vertical offset position of the item
local activePage = 1;
local options = {
	-- General
	{
-- 앞으로 나와 있는 부분이 섬게이트 에디션 및 새로 추가된 기능입니다.
-- 수정 : 플레이어 길드, 자신을 대상으로 한 유닛, 길드 이름이 긴 경우 짧게 표시 추가
		[0] = "일반",
		{ type = "Check", var = "showUnitTip", label = "|cFF00FFFF유닛 툴팁 표시|r", tip = "유닛 툴팁의 모양을 변경합니다. TipTac의 툴팁에 관한 유용한 기능을 사용하려면 이 설정을 활성화 해야 합니다.\n\n|cFFFF4646주의: 영어 이외의 버전에서는 오류가 발생할 수 있습니다!", y = 8 },
		{ type = "Check", var = "showStatus", label = "플레이어 현재 상태 표시", tip = "플레이어의 이름 뒤에 |cffffffff<오프라인>|r, |cffffffff<자리비움>|r, |cffffffff<다른 용무 중>|r 상태를 표시합니다." },
		{ type = "Check", var = "showGuild", label = "플레이어 길드 표시 ", tip = "플레이어가 속한 길드 이름을 표시합니다. \n\n이 설정은 아래의 |cFFFFA500[플레이어 길드 등급 표시]|r 설정보다 우선하여 표시되며, 플레이어의 길드 등급을 표시하려면 반드시 이 설정을 사용해야 합니다.\n\n|cFFFF4646주의: 길드 이름이 표시되지 않으면 길드 등급도 표시되지 않습니다." },
		{ type = "Check", var = "showGuildRank", label = "플레이어 길드 등급 표시", tip = "길드 이름에 추가적으로 플레이어의 길드 등급을 표시합니다.\n\n|cFF33FFFF참고: 이 설정은 위의 |cFFFFA500[플레이어 길드 표시]|r |cFF33FFFF를 사용한 경우에만 표시됩니다. 길드 이름이 표시되지 않으면 길드 등급도 표시되지 않습니다." },
		{ type = "Check", var = "shortGname", label = "길드이름 짧게 표시", tip = "툴팁에 표시되는 길드 이름이 긴 경우에 짧게 표시합니다.\n\n|cFF33FFFF참고: 일부 플레이어들의 길드이름이 길게 표시되어 툴팁의 크기가 그에 따라 너무 넓어져 화면에 불필요한 공간을 많이 차지하는 것을 방지하기 위함입니다.",},
		{ type = "Check", var = "showTargetedBy", label = "대상을 선택한 파티원/공대원 표시", tip = "파티나 공격대에 속해 있을 때, 대상을 선택하고 있는 파티원이나 공대원을 표시합니다.", y = 10 }, -- y = 16
		{ type = "DropDown", var = "nameType", label = "이름 표시 형식", list = { ["이름만 표시"] = "normal", ["플레이어 칭호 사용"] = "title", ["기본 툴팁에서 복사"] = "original", ["Mary Sue Protocol"] = "marysueprot" } },
		{ type = "DropDown", var = "showRealm", label = "유닛 서버 표시", list = { ["서버를 표시하지 않음"] = "none", ["서버 표시"] = "show", ["서버 대신에(*) 마크 표시"] = "asterisk" } },
		{ type = "DropDown", var = "showTarget", label = "유닛 대상 표시", list = { ["표시 안함"] = "none", ["첫번째 줄에 표시"] = "first", ["두번째 줄에 표시"] = "second", ["마지막 줄에 표시"] = "last" }, y = 5 }, -- y = 16
		{ type = "Text", var = "targetYouText", label = "자신이 대상일 때\n표시할 문구 지정", y = 5 }, -- 기본값 없음
		{ type = "Check", var = "targetName", label = "자신이 대상일 때 이름 표시", tip = "자신이 대상일 경우에 지정한 문구가 아닌 이름을 표시합니다. \n\n|cFF00FFFF참고:이 설정을 사용하면 자신을 지정한 문구가 표시되지 않습니다.", y = 5 },  -- 기본값 없음
		{ type = "Check", var = "showPlayerGender", label = "플레이어의 성별 표시", tip = "플레이어의 여성/남성 성별을 표시합니다." },
	},
	-- Special
	{
-- 수정 : 정예프레임, 레벨 글자, 이동속도 표시, 설정창 크기 조절 추가
		[0] = "추가",
	{ type = "Check", var = "Eframe", label = "정예 프레임 표시", tip = "유닛이 '희귀' 또는 '정예'일 경우에 해당하는 프레임을 툴팁에 표시합니다. \n\n|cFF00FFFF참고:이 그림의 크기나 위치는 수동으로 조절해야 합니다." },
	{ type = "Check", var = "Uspeed", label = "이동속도 표시", tip = "유닛의 이동속도를 툴팁에 표시합니다.\n\n|cFF33FFFF참고: 유닛이 이동을 하는 경우에만 표시가 됩니다. 움직이지 않는 유닛은 표시되지 않습니다. "},
		{ type = "Check", var = "showBattlePetTip", label = "전투 애완 동물 표시", tip = "전투 애완 동물 모두에게 특별한 팁을 표시합니다.\n\n|cFFFF4646주의: 영어가 아닌 특정 클라이언트에서는 비활성화해야 할 수 있습니다." },
		{ type = "Slider", var = "gttScale", label = "툴팁 크기 |cffffffff(기본값 1)", min = 0.2, max = 4, step = 0.05 },
		{ type = "Slider", var = "updateFreq", label = "툴팁 갱신 주기 |cffffffff(기본값 0.5)", min = 0, max = 5, step = 0.05 }, -- y = 24
		{ type = "Check", var = "enableChatHoverTips", label = "대화창 링크에 마우스 활성화", tip = "대화창의 링크에 마우스를 가져다 대면, 해당 링크를 클릭하지 않아도 툴팁이 표시됩니다.", y = 6 }, -- 기본값 없음
	{ type = "DropDown", var = "M_anchor", label = "대화창의 링크에 대한\n마우스 툴팁 위치 지정", list = { ["툴팁 위치"] = "default", ["대화창 위"] = "chatframe", ["마우스 위치"] = "mouse"}, y = 10 }, -- 기본값 없음
	{ type = "Slider", var = "TOScaleV", label = "설정창 크기 |cffffffff(기본값 1)", min = 0.7, max = 2.5, step = 0.05 },
		{ type = "Check", var = "hidePvpText", label = "전쟁 참여 텍스트 숨기기", tip = "툴팁의 전쟁 참여 중 텍스트를 숨깁니다", y = 10 },
		{ type = "Check", var = "hideFactionText", label = "진영 텍스트 숨기기", tip = "툴팁에서 얼라이언스/호드 진영 텍스트를 숨깁니다" },
		{ type = "Check", var = "hideRealmText", label = "통합 서버 텍스트 숨기기", tip = "툴팁에서 통합 서버 텍스트를 숨깁니다" },
 	},
	-- Colors
	{
-- 수정 : 길드 이름 색상, 칭호 색상 추가
		[0] = "색상",
	{ type = "Check", var = "colorGuildByReaction", label = "우호도에 따른 길드 이름 색상 사용", tip = "길드의 우호도에 따른 색상으로 이름이 표시됩니다.\n\n길드 이름을 별도의 색상으로 표시하려면 이 설정을 끄고, 아래의 길드 이름 색상 설정에서 별도의 색상을 지정해야 합니다.", y = 4 }, -- y = 8
	{ type = "Color", subType = 2, var = "colGuild", label = "길드 이름 색상", tip = "길드 이름의 색상을 변경합니다.", y = 8 }, -- 기본값 없음
		{ type = "Color", subType = 2, var = "colSameGuild", label = "자신의 길드 이름 색상", tip = "같은 길드원의 구분을 손쉽게 하기 위하여 자신이 소속되어 있는 길드의 이름을 별도의 색상으로 변경합니다." }, -- y = 16
		{ type = "Color", subType = 2, var = "colRace", label = "종족 및 몬스터 유형 색상", tip = "종족이나 몬스터의 유형에 따른 색상을 변경합니다." },
		{ type = "Color", subType = 2, var = "colLevel", label = "중립 유닛 레벨 색상", tip = "플레이어를 공격할 수 없거나 중립인 유닛의 레벨 색상을 적용합니다.", y = 2 }, -- y = 12
	{ type = "Check", var = "uncolTitle", label = "칭호 색상 사용", tip = "칭호를 플레이어 이름과 구별하기 쉽게 별도의 색상으로 표시합니다.\n\n|cFF33FFFF참고: 아래의 |cFFFFA500[칭호 색상]|r |cFF33FFFF설정을 사용하며, 일반 탭에서|r |cFFFFA500 [이름 표시 형식]|r |cFF33FFFF의|r |cFFFFA500[플레이어 칭호 사용 및 기본 툴팁에서 복사]|r |cFF33FFFF를 선택해야만 표시됩니다.", y = 4 },
	{ type = "Color", subType = 2, var = "colTitle", label = "칭호 색상", tip = "플레이어 칭호의 색상을 변경합니다.\n\n|cFF33FFFF참고: |r|cFFFFA500[칭호 색상 사용]|r |cFF33FFFF설정을 사용해야 적용됩니다.", y = 8 },
		{ type = "Check", var = "colorNameByClass", label = "직업에 따른 플레이어 이름 색상", tip = "플레이어의 이름이 직업 색상에 따라 표시됩니다. 그외의 경우에는 우호도 색상에 의해 표시됩니다.", y = 8 },  -- 기본값 없음
		{ type = "Check", var = "classColoredBorder", label = "직업에 따른 툴팁 테두리 색상", tip = "플레이어의 경우에만 직업 색상에 따른 테두리를 색상화 합니다." },  -- y = 12
	},
	-- Reactions
	{
-- 수정: 8,9,10 항목 추가 및 순서 재배열 및 평판용 용어로 통일
		[0] = "우호도",
		{ type = "Check", var = "reactText", label = "유닛의 우호도 표시", tip = "대상의 유닛에 대한 우호도를 툴팁의 마지막 줄에 우호도 문자로 표시합니다.", y = 10 }, -- y = 42
		{ type = "Color", subType = 2, var = "colReactText1", label = "매우 적대적", y = 8 },
		{ type = "Color", subType = 2, var = "colReactText2", label = "적대적" },
		{ type = "Color", subType = 2, var = "colReactText3", label = "약간 적대적" },
		{ type = "Color", subType = 2, var = "colReactText4", label = "중립적" },
		{ type = "Color", subType = 2, var = "colReactText5", label = "약간 우호적" },
		{ type = "Color", subType = 2, var = "colReactText6", label = "우호적" },
	{ type = "Color", subType = 2, var = "colReactText7", label = "매우 우호적" },
	{ type = "Color", subType = 2, var = "colReactText8", label = "확고한 동맹" },
		{ type = "Color", subType = 2, var = "colReactText9", label = "죽음" },
	{ type = "Color", subType = 2, var = "colReactText10", label = "선점됨" },
	},
	-- BG Color
	{
-- 수정: 8,9,10 항목 추가 및 순서 재배열 및 평판용 용어로 통일
		[0] = "배경 색상",
		{ type = "Check", var = "reactColoredBackdrop", label = "우호도에 따른 배경 색상", tip = "툴팁의 배경색을 대상에 대한 우호도의 색상으로 변경합니다. 이 설정을 사용하지 않는다면,\n'모양' 설정에서 선택한 값으로 표시됩니다.", y = 8 },
		{ type = "Check", var = "reactColoredBorder", label = "우호도에 따른 테두리 색상", tip = "툴팁의 테두리 색상을 대상에 대한 우호도의 색상으로 변경합니다.\n\n|cFFFF4646주의: 이 설정은 '직업 색상에 따른 툴팁 테두리 색상'에 우선하여 적용됩니다." }, -- y = 20
		{ type = "Color", var = "colReactBack1", label = "매우 적대적", y = 8 },
		{ type = "Color", var = "colReactBack2", label = "적대적" },
		{ type = "Color", var = "colReactBack3", label = "약간 적대적" },
		{ type = "Color", var = "colReactBack4", label = "중립적" },
		{ type = "Color", var = "colReactBack5", label = "약간 우호적" },
		{ type = "Color", var = "colReactBack6", label = "우호적" },
	{ type = "Color", var = "colReactBack7", label = "매우 우호적" },
	{ type = "Color", var = "colReactBack8", label = "확고한 동맹" },
		{ type = "Color", var = "colReactBack9", label = "죽음" },
	{ type = "Color", var = "colReactBack10", label = "선점됨" },
	},
	-- Backdrop
	{
		[0] = "모양",
		{ type = "Check", var = "enableBackdrop", label = "배경 수정 활성화", tip = "배경의 모든 수정 사항을 켜거나 끕니다.\n참고: 설정을 적용하려면 UI를 재시작 해셔야 합니다." },		
    	{ type = "DropDown", var = "tipBackdropBG", label = "배경 무늬", media = "background", y = 4 },
    	{ type = "DropDown", var = "tipBackdropEdge", label = "테두리 무늬", media = "border", y = 8 },
		{ type = "Check", var = "pixelPerfectBackdrop", label = "픽셀 완벽한 배경 모서리 크기 및 삽입.", tip = "배경 모서리 크기 및 삽입은 실제 픽셀에 해당합니다.", y = 6 },
		{ type = "Slider", var = "backdropEdgeSize", label = "배경 모서리 크기 |cffffffff(기본값 14)", min = 0, max = 64, step = 0.5 },
		{ type = "Slider", var = "backdropInsets", label = "배경 삽입 |cffffffff(기본값 2.5)", min = -20, max = 20, step = 0.5, y = 18 },
		{ type = "Color", var = "tipColor", label = "게임 툴팁 배경 색상", y = 12 },
		{ type = "Color", var = "tipBorderColor", label = "게임 툴팁 테두리 색상" },
		{ type = "Check", var = "gradientTip", label = "툴팁 그라디언트 표시", tip = "툴팁 위쪽에 입체적인(3D)효과를 부여하여 그라디언트 효과를 적용합니다.\n\n|cFFFF4646주의: Skinner와 비슷한 UI의 배경을 변경해주는 애드온을 사용중이라면 애드온 오류를 방지하기 위해서 이 설정을 사용하지 마세요.", y = 6 },
		{ type = "Color", var = "gradientColor", label = "그라디언트 색상", tip = "그라디언트 효과에 대한 색상을 변경합니다.", y = 6 },
	},
	-- Font
	{
		[0] = "글꼴",
		{ type = "Check", var = "modifyFonts", label = "게임 툴팁 글꼴 템플릿 변경", tip = "TipTac의 툴팁 글꼴 템플릿을 게임 UI 전체 툴팁에 적용합니다.\n\n|cFF33FFFF참고: 이 설정을 사용치 않으면 하단의 옵션은 동작하지 않습니다.|r\n\n|cFFFF4646주의사항: ClearFont와 같은 글꼴 관련 애드온을 사용하고 있다면 이 옵션과 충돌 가능성이 있습니다.", y = 12 },
    	{ type = "DropDown", var = "fontFace", label = "글꼴 종류", media = "font" },
    	{ type = "DropDown", var = "fontFlags", label = "글꼴 장식", list = DROPDOWN_FONTFLAGS },
    	{ type = "Slider", var = "fontSize", label = "글꼴 크기 |cffffffff(기본값 12)", min = 6, max = 29, step = 1 },
    	{ type = "Slider", var = "fontSizeDeltaHeader", label = "툴팁의 큰 제목 글꼴 크기", min = -10, max = 10, step = 1, y = 20 },
		{ type = "Slider", var = "fontSizeDeltaSmall", label ="툴팁의 작은 제목 글꼴 크기", min = -10, max = 10, step = 1 },
	},
	-- Classify
	{
		[0] = "몬스터 등급",
--		{ type = "Text", var = "classification_minus", label = "Minus" },
		{ type = "Text", var = "classification_trivial", label = "미물", y = 5 },
    	{ type = "Text", var = "classification_normal", label = "일반" },
    	{ type = "Text", var = "classification_elite", label = "정예" },
    	{ type = "Text", var = "classification_worldboss", label = "월드보스" },
    	{ type = "Text", var = "classification_rare", label = "희귀" },
    	{ type = "Text", var = "classification_rareelite", label = "희귀정예" },
	},
	-- Fading
	{
		[0] = "사라짐",
		{ type = "Check", var = "overrideFade", label = "게임 툴팁 사라짐 사용", tip = "게임 툴팁의 사라짐 기능을 사용합니다. 툴팁의 사라짐 설정에 문제가 발생하면 해당 기능을 꺼주세요.", y = 16 },
		{ type = "Slider", var = "preFadeTime", label = "사라짐 이전 시간 |cffffffff(기본값 0.1)", min = 0, max = 5, step = 0.05 },
		{ type = "Slider", var = "fadeTime", label = "사라짐 시간 |cffffffff(기본값 0.1)", min = 0, max = 5, step = 0.05, y = 16 },
		{ type = "Check", var = "hideWorldTips", label = "월드프레임 툴팁 바로 숨김", tip = "객체에서 마우스를 떼면, 월드프레임의 툴팁이 바로 사라집니다. 예: 우편함, 약초 또는 광맥이 이에 해당합니다.\n\n|cFF00FFFF참고: 모든 객체에 적용되지는 않습니다." }
	},
	-- Bars
	{
		[0] = "바",
		{ type = "DropDown", var = "barFontFace", label = "글꼴 종류", media = "font", y = 4 },
		{ type = "DropDown", var = "barFontFlags", label = "글꼴 장식", list = DROPDOWN_FONTFLAGS },
	{ type = "Slider", var = "BFShadowx", label = "그림자 좌표 x값 |cffffffff(기본값 3)", min = 0, max = 5, step = 0.1},
	{ type = "Slider", var = "BFShadowy", label = "그림자 좌표 y값 |cffffffff(기본값 1)", min = 0, max = 5, step = 0.1, y = 12 },
		{ type = "Slider", var = "barFontSize", label = "글꼴 크기 |cffffffff(기본값 12)", min = 6, max = 29, step = 1 }, -- y = 36
		{ type = "DropDown", var = "barTexture", label = "바 무늬", media = "statusbar", y = 36 },
		{ type = "Slider", var = "barHeight", label = "바 높이 |cffffffff(기본값 10)", min = 1, max = 50, step = 1 },
	},
	-- Bar Types
	{
		[0] = "바 모양",
		{ type = "Check", var = "hideDefaultBar", label = "기본 툴팁 생명력 바 숨김", tip = "블리자드의 기본 툴팁 생명력 바를 숨깁니다.\n\n|cFF00FFFF참고: 아래의 설정을 사용하려면 기본 툴팁 생명력 바 숨김을 권장합니다.", y = 4 },
		{ type = "Check", var = "barsCondenseValues", label = "바 수치 짧게 표시 |cffFF7C0A(바 문자의 실수치 표시와 연계)", tip = "바에 표시되는 숫자가 긴 경우에 짧게 표시합니다.\n\n|cFF00FFFF예: 생명력이 '572542'인 경우 짧게 표시를 선택하여 '573.2k' 또는 '57.3만' 등의 형식으로 표시됩니다." },
		{ type = "Check", var = "healthBar", label = "생명력 바 표시", tip = "유닛의 생명력 바를 표시합니다." },
		{ type = "DropDown", var = "healthBarText", label = "생명력 바 문자", list = DROPDOWN_BARTEXTFORMAT },
		{ type = "Check", var = "healthBarClassColor", label = "직업에 따른 생명력 바 색상화", tip = "생명력 바를 유닛의 직업에 따른 색상으로 변경합니다.", y = 6 },
		{ type = "Color", var = "healthBarColor", label = "생명력 바 색상", tip = "생명력 바의 색상을 변경합니다. '직업에 따른 생명력 바 색상화' 설정을 사용중이라면 적용되지 않습니다.", y = 10 },
		{ type = "Check", var = "manaBar", label = "마나 바 표시", tip = "유닛이 마나를 사용한다면 마나 바를 표시합니다." },
		{ type = "DropDown", var = "manaBarText", label = "마나 바 문자", list = DROPDOWN_BARTEXTFORMAT },
		{ type = "Color", var = "manaBarColor", label = "마나 바 색상", tip = "마나 바의 색상을 변경합니다.", y = 10 },
		{ type = "Check", var = "powerBar", label = "파워 바 표시", tip = "유닛이 기력/분노/룬파워/집중을 사용한다면 파워 바를 표시합니다." },
		{ type = "DropDown", var = "powerBarText", label = "파워 바 문자", list = DROPDOWN_BARTEXTFORMAT },
	},
	-- Auras
	{
		[0] = "버프/디버프",
		{ type = "Check", var = "aurasAtBottom", label = "버프/디버프 아이콘을 툴팁의 위쪽 대신에 아래에 표시", tip = "강화/약화 효과의 아이콘을 툴팁의 아래쪽에 표시합니다.", y = 12 },
		{ type = "Check", var = "showBuffs", label = "유닛의 강화 효과(버프) 표시", tip = "유닛의 강화 효과(버프)를 표시합니다." },
		{ type = "Check", var = "showDebuffs", label = "유닛의 약화 효과(디버프) 표시", tip = "유닛의 약화 효과(디버프)를 표시합니다." },
		{ type = "Check", var = "selfAurasOnly", label = "플레이어가 가능한 오라만 표시", tip = "플레이어가 대상에게 시전 가능하거나 혹은 해제 가능한 강화/약화 효과만 표시합니다.", y = 12 },
		{ type = "Slider", var = "auraSize", label = "버프/디버프 아이콘 크기 |cffffffff(기본값 20)", min = 8, max = 60, step = 1 },
		{ type = "Slider", var = "auraMaxRows", label = "최대 오라 열 수 |cffffffff(기본값 2)", min = 1, max = 8, step = 1, y = 8 },
		{ type = "Check", var = "showAuraCooldown", label = "재사용 대기시간 표시", tip = "강화 효과 아이콘에 남은 시간을 시각적으로 표시합니다. 플레이어가 시전한 강화 효과에 대해서만 적용됩니다." },
		{ type = "Check", var = "noCooldownCount", label = "재사용 대기시간 숫자 표시 안함", tip = "OmniCC와 같은 재사용 대기시간 표시 애드온을 사용할 때 TipTac의 툴팁에는 재사용 대기시간을 표시하지 않습니다." },
	},
	-- Icon
	{
	  -- 수정 : 종족, 직업, 속성 아이콘 표시 및 아이콘의 위치 지정, 크기 조절 추가
		[0] = "아이콘",
	{ type = "Check", var = "raceIcon", label = "종족 아이콘 표시", tip = "유닛의 종족 아이콘을 표시합니다. 이 사항은 유저들에게만 적용됩니다. \n\n|cFF00FFFF참고: 아래의 |cFFFFA500[아이콘 위치]|r |cFF00FFFF메뉴로 위치를 조절할 수 있으며, 맨 아래의 |cFFFFA500[아이콘 크기]|r|cFF00FFFF로 아이콘의 크기 조절할 수 있습니다." },
	{ type = "Check", var = "clasIcon", label = "직업 아이콘 표시", tip = "유닛의 직업 아이콘을 표시합니다. 이 사항은 유저들에게만 적용됩니다. \n\n|cFF00FFFF참고: 아래의 |cFFFFA500[아이콘 위치]|r |cFF00FFFF메뉴로 위치를 조절할 수 있으며, 맨 아래의 |cFFFFA500[아이콘 크기]|r|cFF00FFFF로 아이콘의 크기 조절할 수 있습니다." },
	{ type = "Check", var = "crtIcon", label = "속성 아이콘 표시", tip = "유닛의 속성 아이콘을 합니다. 이 사항은 유저를 제외한 유닛이나 NPC등에게 적용됩니다.\n\n|cFF00FFFF참고: 아래의 |cFFFFA500[아이콘 위치]|r |cFF00FFFF메뉴로 위치를 조절할 수 있으며, 맨 아래의 |cFFFFA500[아이콘 크기]|r|cFF00FFFF로 아이콘의 크기 조절할 수 있습니다." },
	{ type = "DropDown", var = "classType", label = "종족, 직업, 속성\n아이콘 위치", list = { ["왼쪽 위"] = "tl", ["오른쪽 위"] = "tr", ["왼쪽 아래"] = "bl", ["오른쪽 아래"] = "br" }, y = 5 },
	{ type = "DropDown", var = "IconPosition", label = "종족, 직업, 속성 아이콘 \n표시 위치", list = { ["툴팁 바깥"] = "outIcon", ["툴팁 안쪽"] = "inIcon" }, y = 5},
	{ type = "Slider", var = "piconSize", label = "아이콘 크기 |cffffffff(기본값 35)", min = 24, max = 55, step = 1, y = 3 },
		{ type = "Check", var = "iconClass", label = "원형 직업 아이콘 표시", tip = "플레이어의 경우 툴팁 옆에 [원형] 직업 아이콘이 표시됩니다. \n\n|cFF00FFFF참고: 아래의 |cFFFFA500[아이콘 위치]|r |cFF00FFFF메뉴로 위치를 조절할 수 있으며, 맨 아래의 |cFFFFA500[아이콘 크기]|r|cFF00FFFF로 아이콘의 크기 조절할 수 있습니다." },
		{ type = "Check", var = "iconRaid", label = "공격대 아이콘 표시", tip = "툴팁의 외부에 공격대 징표 아이콘을 표시합니다.\n참고: 맨 아래의 |cFFFFA500[아이콘 크기]|r로 아이콘의 크기를 조절할 수 있습니다." },
		{ type = "Check", var = "iconFaction", label = "진영 아이콘 표시", tip = "툴팁의 외부에 진영 아이콘을 표시합니다. \n참고: 맨 아래의 |cFFFFA500[아이콘 크기]|r로 아이콘의 크기를 조절할 수 있습니다." },
		{ type = "Check", var = "iconCombat", label = "전투 아이콘 표시", tip = "툴팁의 외부에 전투 아이콘을 표시합니다. 전투중인 경우에만 표시됩니다. \n맨 아래의 |cFFFFA500[아이콘 크기]|r로 아이콘의 크기를 조절할 수 있습니다." }, -- y = 12
		{ type = "DropDown", var = "iconAnchor", label = "아이콘 위치", list = DROPDOWN_ANCHORPOS, y = 4 }, -- 기본값 없음
		{ type = "Slider", var = "iconSize", label = "아이콘 크기 |cffffffff(기본값 24)", min = 20, max = 55, step = 1 }, -- min = 8, max = 60
	},
	-- Anchors
	{
		[0] = "툴팁 기준위치",
		{ type = "DropDown", var = "anchorWorldUnitType", label = "월드 유닛 형식", list = DROPDOWN_ANCHORTYPE,y = 8 },
		{ type = "DropDown", var = "anchorWorldUnitPoint", label = "월드 유닛 위치", list = DROPDOWN_ANCHORPOS },
		{ type = "DropDown", var = "anchorWorldTipType", label = "월드 툴팁 형식", list = DROPDOWN_ANCHORTYPE, y = 14 },
		{ type = "DropDown", var = "anchorWorldTipPoint", label = "월드 툴팁 위치", list = DROPDOWN_ANCHORPOS },
	  	{ type = "DropDown", var = "anchorFrameUnitType", label = "프레임 유닛 형식", list = DROPDOWN_ANCHORTYPE, y = 14 },
		{ type = "DropDown", var = "anchorFrameUnitPoint", label = "프레임 유닛 위치", list = DROPDOWN_ANCHORPOS },
		{ type = "DropDown", var = "anchorFrameTipType", label = "프레임 툴팁 형식", list = DROPDOWN_ANCHORTYPE, y = 14 },
		{ type = "DropDown", var = "anchorFrameTipPoint", label = "프레임 툴팁 위치", list = DROPDOWN_ANCHORPOS },
	},
	-- Mouse
	{
		[0] = "마우스 위치",
		{ type = "Slider", var = "mouseOffsetX", label = "마우스 기준점 X 좌표", min = -200, max = 200, step = 1, y = 6 },
		{ type = "Slider", var = "mouseOffsetY", label = "마우스 기준점 Y 좌표", min = -200, max = 200, step = 1 },

		{ type = "Header", label = "앵커 재 정의", tip = "특수 앵커 재 정의 활성화/비활성화", y = 12 },
		{ type = "Check", var = "enableAnchorOverrideCF", label = "(길드 & 커뮤니티) 채팅 프레임", tip = "이 옵션은 (길드 및 커뮤니티) 채팅 프레임의 앵커를 무시합니다." },
		{ type = "DropDown", var = "anchorOverrideCFType", label = "툴팁 형식", list = DROPDOWN_ANCHORTYPE },
		{ type = "DropDown", var = "anchorOverrideCFPoint", label = "툴팁 위치", list = DROPDOWN_ANCHORPOS },
	},
	-- Combat
	{
		[0] = "전투",
		{ type = "Check", var = "hideAllTipsInCombat", label = "전투중 모든 유닛 툴팁 숨김", tip = "전투중에는 유닛(NPC, 몹, 케릭터 등) 툴팁을 숨깁니다.", y = 6 },
		{ type = "Check", var = "hideUFTipsInCombat", label = "전투중 유닛 프레임 툴팁 숨김", tip = "전투중에는 유닛프레임에 표시되는 툴팁을 숨깁니다." },
		{ type = "Check", var = "showHiddenTipsOnShift", label = "쉬프트키를 누르는 동안 툴팁 표시", tip = "전투중 툴팁 숨김을 설정했을 경우에도 쉬프트키를 누르는 동안에는 강제로 툴팁을 표시합니다." },
--		{ type = "DropDown", var = "hideCombatTip", label = "Hide Tips in Combat For", list = { ["Unit Frames"] = "uf", ["All Tips"] = "all", ["No Tips"] = "none" } },
	},
	-- Layouts
	{
		[0] = "레이아웃",
		{ type = "DropDown", label = "레이아웃 형식", init = TipTacLayouts.LoadLayout_Init, y = 20 },
--		{ type = "Text", label = "레이아웃 저장", func = nil },
--		{ type = "DropDown", label = "레이아웃 삭제", init = TipTacDropDowns.DeleteLayout_Init },
	},
};

-- TipTacTalents Support
if (TipTacTalents) then
	local tttOptions = {
		{ type = "Check", var = "t_showTalents", label = "|cFF00FFFF특성 살펴보기|r(TipTacTalents) |cFF00FFFF사용|r", tip = "다른 플레이어의 특성을 표시합니다.", y = 8 },
		{ type = "Check", var = "t_talentOnlyInParty", label = "파티 또는 공격대에서만 특성 표시", tip = "플레이어가 파티나 공격대에 속해 있을 때만 툴팁에 특성이 표시됩니다." }
	};
	
	if (not isWoWSl) and (not isWoWRetail) then
		tttOptions[#tttOptions + 1] = { type = "DropDown", var = "t_talentFormat", label = "특성 형식", list = { ["Elemental (57/14/00)"] = 1, ["Elemental"] = 2, ["57/14/00"] = 3,}, y = 8 };	-- not supported with MoP changes
	end
	if (C_PlayerInfo.GetPlayerMythicPlusRatingSummary) and (isWoWRetail) or (isWoWSl) then
		tttOptions[#tttOptions + 1] = { type = "Check", var = "showMythicPlusDungeonScore", label = "쐐기 점수 표시", tip = "플레이어의 mythic+ 던전 점수를 보여줍니다." };
	end
	tttOptions[#tttOptions + 1] = { type = "Slider", var = "t_talentCacheSize", label = "특성 캐쉬 크기|cffffffff(기본값 25)", min = 0, max = 50, step = 1, y = 10 };

	if (not isWoWSl) and (not isWoWRetail) then
	options[#options + 1] = {
		[0] = "특성",
		unpack(tttOptions)
	};
	end
	options[#options + 1] = {
		[0] = "특성/쐐기점수",
		unpack(tttOptions)
	};
end

-- TipTacItemRef Support -- Az: this category page is full
if (TipTacItemRef) then
	options[#options + 1] = {
		[0] = "정보강화 툴팁",
		{ type = "Check", var = "if_enable", label = "|cFF00FFFF정보강화 툴팁|r(TipTacItemRef) |cFF00FFFF사용|r", tip = "정보강화 툴팁(TipTacItemRef)을 사용합니다.", y = 8 }, 
		{ type = "Color", var = "if_infoColor", label = "정보 색상", tip = "정보강화에 대한 색상을 변경합니다.", y = 3 },
		{ type = "Check", var = "if_itemQualityBorder", label = "아이템 등급에 따른 툴팁 테두리에 색상 표시", tip = "아이템 등급의 색상에 따라 툴팁의 테두리를 색상화 합니다.", y = -5 },
	{ type = "Check", var = "if_spellColoredBorder", label = "주문 및 버프 툴팁 테두리에 색상 표시", tip = "주문과 버프형식의 툴팁 테두리에 정해진 색상을 적용합니다." },
		{ type = "Check", var = "if_showAuraCaster", label = "오라 시전자 표시", tip = "버프 및 디버프 툴팁에 오라를 시전한 플레이어 이름을 표시합니다." }, -- 기본값 없음
	{ type = "Check", var = "if_showAuraSpellIdAndRank", label = "오라 주문 및 령 ID표시", tip = "버프 및 디버프 툴팁에 주문ID와 등급 및 령 능력ID를 표시합니다.", x = 170 },
		{ type = "Check", var = "if_showItemLevel", label = "아이템 레벨 표시", tip = "아이템의 툴팁에 아이템 레벨을 표시합니다.", y = 12 },
		{ type = "Check", var = "if_showItemId", label = "아이템ID 표시", tip = "아이템의 툴팁에 아이템ID를 표시합니다. (아이템 레벨 표시와 함께 사용시 같이 표시합니다)", x = 170 },
		{ type = "Check", var = "if_showSpellIdAndRank", label = "주문ID 표시", tip = "주문의 툴팁에 주문ID를 표시합니다." }, -- 주문 레벨은 4.0 패치로 삭제되서 불필요한 내용이다.
		{ type = "Check", var = "if_showCurrencyId", label = "화폐ID 표시", tip = "화폐 아이템ID가 표시됩니다.", x = 170 },
		{ type = "Check", var = "if_showQuestLevel", label = "퀘스트 레벨 표시", tip = "퀘스트 툴팁에 퀘스트 레벨을 표시합니다." },
		{ type = "Check", var = "if_showQuestId", label = "퀘스트ID 표시", tip = "퀘스트 툴팁에 퀘스트ID를 표시합니다.", x = 170 },
		{ type = "Check", var = "if_modifyAchievementTips", label = "업적 툴팁 변경", tip = "업적 툴팁에 다양한 정보를 표시합니다.\n\n|cFFFF4646주의 : 다른 업적 관련 애드온들과 중복하여 오류를 발생시킬 수 있습니다." },
		{ type = "Check", var = "if_showAchievementIdAndCategoryId", label = "업적ID와 종류 표시", tip = "업적 툴팁에 업적ID와 종류가 표시됩니다.", x = 170 },
	{ type = "Check", var = "if_modifyKeystoneTips", label = "쐐기돌 툴팁 변경", tip = "좀 더 많은 정보를 표시하도록 쐐기돌 툴팁을 변경합니다.\n\n|cFFFF4646주의 : 다른 키스톤 애드온과 충돌할 수 있습니다." },
	{ type = "Check", var = "if_wccc", label = "색약 보정", tip = "색약이신 분들을 위한 |cffa335ee영웅 아이템|r의 이름과 테두리 색상을, |cff0070dd희귀 아이템|r과 구분하기 쉽도록 |cffff0000빨간색|r으로 바꿔 표시합니다.", y = 12 }, 
	{ type = "Check", var = "if_etcinfo", label = "추가 아이템 정보", tip = "아이템 툴팁에 아이템의 유형 및 속성에 대한 추가 정보를 표시합니다."},
	};
end
	
if (TipTacItemRef) then
	options[#options + 1] = {
		[0] = "정보강화 아이콘",
		{ type = "Check", var = "if_showIcon", label = "아이콘 표시 및 겹침 수량 표시 (겹침 표시가 가능한 것만)", tip = "툴팁의 아이콘에 해당 아이템의 최대 겹침 수량을 표시합니다.\n\n|cFFFF4646주의: 툴팁에 아이템이나 퀘스트, 업적 등의 속성에 따른 아이콘을 표시하지 않거나 이와 비슷한 기능을 하는 다른 애드온과 같이 사용할 때에는 해당 기능을 꺼주세요.",y = 8 },
	{ type = "Check", var = "if_itemStackCount", label = "아이템 겹침 수량 추가로 표시", tip = "툴팁의 내부에 아이템의 최대 겹침 수량을 추가로 표시합니다." },
		{ type = "Check", var = "if_smartIcons", label = "스마트 아이콘 표시", tip = "스마트 아이콘 표시 기능은 |cFFFFA500[아이콘 텍스처와 겹침 수량 표시]|r설정을 사용하여 아이콘을 표시할 때 해당 툴팁의 속성에 따른 아이콘을 행동바나 가방 등에서는 자동으로 표시되지 않도록 합니다.\n\n이는 행동바나 가방에서 툴팁 바깥으로 표시되는 아이콘이 행동바나 가방을 가려 방해하는 역기능을 줄이기 위함입니다.\n\n|cFF00FFFF참고: 모든 툴팁에 해당 속성을 표시 하려면 이 설정을 끄고 상단의|r |cFFFFA500[아이콘 텍스처와 겹침 수량 표시]|r |cFF00FFFF설정만 사용하세요.\n\n|cFFFFA500[툴팁 아이콘 내부 표시]|r|cFF00FFFF설정을 사용하면 적용되지 않습니다.|r" },
	{ type = "Check", var = "if_inIcon", label = "툴팁 아이콘 내부 표시", tip = "툴팁의 아이콘을 툴팁 외부가 아닌 내부에 표시합니다.\n\n|cFF00FFFF참고: |cFFFFA500[스마트 아이콘 표시]|r|cFF00FFFF의 기능은 적용되지 않습니다.|r"},
	{ type = "Check", var = "if_qIcon", label = "퀘스트 아이템 강조 표시", tip = "퀘스트 아이템의 테두리 색상과 퀘스트 아이콘을 툴팁 안쪽에 표시하며 퀘스트 관련 문자의 색상을 퀘스트 색상에 맞게 표시합니다."},
	{ type = "Check", var = "if_bIcon", label = "아이템 귀속여부 강조 표시", tip = "아이템의 귀속 여부에 따라 귀속여부 글자를 색상화 하고 아이콘을 표시합니다."},
		{ type = "Check", var = "if_borderlessIcons", label = "아이콘 테두리 생략", tip = "툴팁 외부의 아이콘에 테두리를 표시하지 않습니다." },
		{ type = "Slider", var = "if_iconSize", label = "아이콘 크기 |cffffffff(기본값 35)", min = 16, max = 128, step = 1 },
	{ type = "DropDown", var = "if_IconPosition", label = "툴팁 아이콘 위치 지정", list = { ["왼쪽 상단"] = "LEFT", ["상단 왼쪽"] = "TOP"} },
	};
end

if (TipTacItemRef) then
	options[#options + 1] = {
		[0] = "정보강화 기타",
		{ type = "Check", var = "if_runeforgePowerColoredBorder", label = "룬포지 파워 툴팁 테두리에 색상 표시", tip = "활성화하면 툴팁 테두리에 룬포지 파워 표준 색상이 표시됩니다.", y = 10 },
		{ type = "Check", var = "if_showRuneforgePowerId", label = "룬포지 파워ID 표시", tip = "툴팁에 룬포지 파워ID를 표시합니다." },
		{ type = "Check", var = "if_flyoutColoredBorder", label = "색상 테두리로 플라이아웃 툴팁 표시", tip = "활성화하면 툴팁 테두리에 플라이아웃 표준 색상이 표시됩니다.", y = 10 },
		{ type = "Check", var = "if_showFlyoutId", label = "플라이아웃ID 표시", tip = "툴팁에 플라이아웃ID 표시" },
		{ type = "Check", var = "if_showTransmogIllusionId", label = "형상변환 환상ID 표시", tip = "툴팁에 형상변환 환상ID를 표시합니다.", x = 170 },
		{ type = "Check", var = "if_showBattlePetLevel", label = "전투 애완 동물 레벨 표시", tip = "툴팁에 전투 애완 동물 레벨을 표시합니다. (petID와 결합)", y = 8 },
		{ type = "Check", var = "if_showBattlePetId", label = "전투 애완 동물ID 표시", tip = "툴팁에 전투 애완 동물 NpcID를 표시합니다. (petLevel과 결합)", x = 170 },
		{ type = "Check", var = "if_showBattlePetAbilityId", label = "전투 애완 동물의 능력ID 표시", tip = "툴팁에 전투 애완 동물의 능력ID를 표시합니다." },
--		{ type = "Check", var = "if_petActionColoredBorder", label = "소환수의 행동 요령에 색상 테두리 표시", tip = "활성화하면 소환수 툴팁 테두리에 표준 색상이 표시됩니다.", y = 10 },
		{ type = "Check", var = "if_showPetActionId", label = "소환수 행동ID 표시", tip = "소환수 툴팁에 행동ID를 표시합니다." },
	};
end

--------------------------------------------------------------------------------------------------------
--                                          Initialize Frame                                          --
--------------------------------------------------------------------------------------------------------

local f = CreateFrame("Frame",modName.."Options",UIParent,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate

UISpecialFrames[#UISpecialFrames + 1] = f:GetName();

f.options = options;

f:SetSize(460,420); --424, 378 크기 늘림
f:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
f:SetBackdropColor(0.1,0.22,0.35,1);
f:SetBackdropBorderColor(0.1,0.1,0.1,1);
f:EnableMouse(true);
f:SetMovable(true);
f:SetFrameStrata("DIALOG");
f:SetToplevel(true);
f:SetClampedToScreen(true);
f:SetScript("OnShow",function(self) self:BuildCategoryPage(); end);
f:Hide();
f:SetScale(cfg.TOScaleV); -- 설정창 크기 추가

f.outline = CreateFrame("Frame",nil,f,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate
f.outline:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
f.outline:SetBackdropColor(0.1,0.1,0.2,1);
f.outline:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
f.outline:SetPoint("TOPLEFT",12,-12);
f.outline:SetPoint("BOTTOMLEFT",12,12);
f.outline:SetWidth(96);

f:SetScript("OnMouseDown",f.StartMoving);
f:SetScript("OnMouseUp",function(self) self:StopMovingOrSizing(); cfg.optionsLeft = self:GetLeft(); cfg.optionsBottom = self:GetBottom(); end);

if (cfg.optionsLeft) and (cfg.optionsBottom) then
	f:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",cfg.optionsLeft,cfg.optionsBottom);
else
	f:SetPoint("CENTER");
end

f.header = f:CreateFontString(nil,"ARTWORK","GameFontHighlight");
f.header:SetFont(GameFontNormal:GetFont(),22,"THICKOUTLINE");
f.header:SetPoint("TOPLEFT",f.outline,"TOPRIGHT",10,-4);
f.header:SetText(modName.." 설정");

f.vers = f:CreateFontString(nil,"ARTWORK","GameFontNormal");
f.vers:SetPoint("TOPRIGHT",-20,-20);
f.vers:SetText(GetAddOnMetadata(modName,"Version"));
f.vers:SetTextColor(1,1,0.5);

-- 섬게이트 에디션 삽입구 : Start
f.info = f:CreateFontString(nil,"ARTWORK","GameFontHighlight");
f.info:SetFont(QuestFont:GetFont(),13,"OUTLINE");
f.info:SetPoint("TOPRIGHT",-25,-35);
--f.info:SetText("[섬게이트SE Ver FanFix - 러블리회복]");
f.info:SetText("[섬게이트 에디션 Ver FanFix]");
f.info:SetTextColor(1,1,7);
-- 섬게이트 에디션 삽입구 : End

--  Add Reset Popup Window : Start (friends님의 TUF의 코드를 인용했습니다.)
-- TipTac_Reset 함수를 실행
StaticPopupDialogs["TipTac_RESET1"] = {
      text = "|cffff6eedTipTac의 설정 페이지 별로 초기화를 진행 하게 됩니다. \n현재 페이지에 대한 TipTac의 설정값을 초기화 하시겠습니까?",
      button1 = "확인",
      button2 = "취소",
      OnAccept = function ()
      TipTac_Reset();
      end,
      timeout = 10,
      whileDead = 1,
      hideOnEscape = 1
  };	

-- 초기화 버튼 클릭시 팝업창 실행
function Reset_OnClick(self, button, down)
 if button == "LeftButton" then
  StaticPopup_Show("TipTac_RESET1")
 elseif button == "RightButton"then
  TipTac_Reset();
 else return nil;
 end
end

-- 초기화 팝업창에 따른 TipTac의 초기화 함수 재구성
function TipTac_Reset()
  for index, tbl in ipairs(options[activePage]) do
		if (tbl.var) then
			cfg[tbl.var] = nil;
		end
	end
	TipTac:ApplySettings();
	f:BuildCategoryPage();
end

-- 초기화 설정창 재구성 : Start
f.btnAnchor = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnAnchor:SetSize(90,24); -- 75,24
f.btnAnchor:SetPoint("BOTTOMLEFT",f.outline,"BOTTOMRIGHT",10, 2); -- 10, 3 
f.btnAnchor:RegisterForClicks("AnyUp");
--f.btnAnchor:SetPoint("BOTTOMLEFT",f.outline,"BOTTOMRIGHT",10,3);
--f.btnAnchor:SetScript("OnClick",function() if (TipTac:IsVisible()) then TipTac:Hide(); else TipTac:Show(); end end);
-- 툴팁 기준 프레임 초기화 팝업창
StaticPopupDialogs["TT_TTAR1"] = {
      text = "|cffff6eedTipTac의 툴팁 위치를 초기화 합니다.\n지금의 툴팁 위치를 무시하고 화면 중앙으로 초기화 하시겠습니까?",
      button1 = "확인",
      button2 = "취소",
      OnAccept = function ()
       TipTac:ClearAllPoints();
       TipTac:SetPoint("CENTER");
       TipTac:Show();
      end,
      timeout = 10,
      whileDead = 1,
      hideOnEscape = 1
  };	

-- 툴팁 기준 프레임 초기화 버튼별 기능, 확인시 TipTac_TTAR1펑션을 실행하여 초기화.
function AReset_OnClick(self, button, down)
 if button == "LeftButton" then
  if (TipTac:IsVisible()) then 
   TipTac:Hide();  
  else  
   TipTac:Show(); 
  end
 end
 if button == "RightButton" then
  StaticPopup_Show("TT_TTAR1")
 else return;
 end
end

-- 툴팁 표시 위치 버튼
f.btnAnchor:SetScript("OnClick", AReset_OnClick);

-- 툴팁 표시 위치 버튼 마우스 오버시 설명 툴팁 출력 : Start
f.btnAnchor:SetScript("OnEnter", function (self, motion)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10);
  GameTooltip:AddLine("== [툴팁 표시 위치] 버튼 기능 ==");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 좌클릭 |r: 툴팁 표시 위치 프레임 켜고 끄기(전환)");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 우클릭 |r: 툴팁 표시 위치 프레임 위치 초기화 (화면 정중앙)");
  GameTooltip:Show();
end);

f.btnAnchor:SetScript("OnLeave", function (self, motion)
  GameTooltip:Hide();
end);
-- 툴팁 표시 위치 버튼 마우스 오버시 설명 툴팁 출력 : End

f.btnAnchor:SetText("툴팁 표시 위치"); -- f.btnAnchor:SetText("Anchor");

-- 초기화 버튼
f.btnReset = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnReset:SetSize(75,24);
f.btnReset:SetPoint("LEFT",f.btnAnchor,"RIGHT",38,0);  -- 38,0
f.btnReset:SetScript("OnClick",Reset_OnClick);
--f.btnReset:SetText("Defaults");
-- 초기화 버튼 마우스 오버시 설명 툴팁 출력 : Start
f.btnReset:SetScript("OnEnter", function (self, motion)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10);
  GameTooltip:AddLine("== [초기값] 버튼 기능 ==");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 좌클릭 |r: 현재 페이지 초기화 경고창 확인 후 초기화");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 우클릭 |r: 현재 페이지 바로 초기화");
  GameTooltip:Show();
end);

f.btnReset:SetScript("OnLeave", function (self, motion)
  GameTooltip:Hide();
end);
-- 초기화 버튼 마우스 오버시 설명 툴팁 출력 : End

f.btnReset:SetText("초기값"); -- f.btnReset:SetText("Defaults");

-- 닫기 버튼
f.btnClose = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnClose:SetSize(75,24);
f.btnClose:SetPoint("BOTTOMRIGHT",-25,14);  -- -15, 15 
--f.btnClose:SetScript("OnClick",function() f:Hide(); end);
--f.btnClose:SetText("Close");
-- 닫기 버튼 클릭에 따른 기능 : Start
f.btnClose:SetScript("OnClick", function(self, button, down) 
 if (button == "LeftButton") then  
  f:Hide(); 
  f:SetScale(cfg.TOScaleV);
 elseif (button == "RightButton") then
 ReloadUI();
 else return;
 end
end); 
-- 닫기 버튼 클릭에 따른 기능 : End

-- 닫기 버튼 마우스 오버시 설명 툴팁 출력 : Start
f.btnClose:SetScript("OnEnter", function (self, motion)
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10);
  GameTooltip:AddLine("== [닫기] 버튼 기능 ==");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 좌클릭 |r: TipTac 옵션창 닫기");
  GameTooltip:AddLine(">> |cFF00FFFF마우스 우클릭 |r: 애드온 재시작");
  GameTooltip:Show();
end);

f.btnClose:SetScript("OnLeave", function (self, motion)
  GameTooltip:Hide();
end);
-- 닫기 버튼 마우스 오버시 설명 툴팁 출력 : End

f.btnClose:SetText("닫기"); -- f.btnClose:SetText("Close");

UISpecialFrames[#UISpecialFrames + 1] = f:GetName();
-- 초기화 설정창 재구성 : End

--------------------------------------------------------------------------------------------------------
--                                        Options Category List                                       --
--------------------------------------------------------------------------------------------------------

local listButtons = {};

local function CategoryButton_OnClick(self,button)
	listButtons[activePage].text:SetTextColor(1,0.82,0);
	listButtons[activePage]:UnlockHighlight();
	activePage = self.index;
	self.text:SetTextColor(1,1,1);
	self:LockHighlight();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);	-- "igMainMenuOptionCheckBoxOn"
	f:BuildCategoryPage();
end

local buttonWidth = (f.outline:GetWidth() - 8);
local function CreateCategoryButtonEntry(parent)
	local b = CreateFrame("Button",nil,parent);
	b:SetSize(buttonWidth,18);
	b:SetScript("OnClick",CategoryButton_OnClick);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:GetHighlightTexture():SetAlpha(0.7);
	b.text = b:CreateFontString(nil,"ARTWORK","GameFontNormal");
	b.text:SetPoint("LEFT",3,0);
	listButtons[#listButtons + 1] = b;
	return b;
end

for index, table in ipairs(options) do
	local button = listButtons[index] or CreateCategoryButtonEntry(f.outline);
	button.text:SetText(table[0]);
	button.index = index;
	if (index == 1) then
		button:SetPoint("TOPLEFT",f.outline,"TOPLEFT",5,-6);
	else
		button:SetPoint("TOPLEFT",listButtons[index - 1],"BOTTOMLEFT");
	end
	if (index == activePage) then
		button.text:SetTextColor(1,1,1);
		button:LockHighlight();
	end
end

--------------------------------------------------------------------------------------------------------
--                                        Build Option Category                                       --
--------------------------------------------------------------------------------------------------------

-- Get Setting
local function GetConfigValue(self,var)
	return cfg[var];
end

-- called when a setting is changed, do not allow
local function SetConfigValue(self,var,value)
	if (not self.isBuildingOptions) then
		cfg[var] = value;
		TipTac:ApplySettings();
	end
end

-- create new factory instance
local factory = AzOptionsFactory:New(f,GetConfigValue,SetConfigValue);
f.factory = factory; 

-- Build Page
function f:BuildCategoryPage()
	factory:BuildOptionsPage(options[activePage],f.outline,f.outline:GetWidth(),38);
end
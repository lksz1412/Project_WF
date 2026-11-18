
-------------------------------------------------------------------------------
--
--  Mod Name : BlinkMod v1.41
--  Author   : Blink
--  Date     : 2005/07/16
--  LastUpdate : 2008/10/26
--
-------------------------------------------------------------------------------

-- Hook function --------------------------------------------------------------
BlinkMod_Original_UnitPopup_ShowMenu = nil;
BlinkMod_Original_UnitPopup_OnUpdate = nil;

-- Variables ------------------------------------------------------------------
BlinkMod_DEBUG = false;

-- First Level Menus
BlinkMod_Menus = {};
BlinkMod_Menus["SELF"] = {};
BlinkMod_Menus["PET"] = {};
BlinkMod_Menus["PARTY"] = {};
BlinkMod_Menus["PLAYER"] = {};
BlinkMod_Menus["RAID_PLAYER"] = {};
BlinkMod_Menus["RAID"] = {};
BlinkMod_Menus["FRIEND"] = {};
BlinkMod_Menus["TEAM"] = {};
BlinkMod_Menus["RAID_TARGET_ICON"] = {};
BlinkMod_Menus["CHAT_ROSTER"] = {};
BlinkMod_Menus["VEHICLE"] = {};
BlinkMod_Menus["TARGET"] = {};
BlinkMod_Menus["FOCUS"] = {};

BlinkMod_Menus["ENEMY"] = {};
BlinkMod_Menus["NPC"] = {};

UnitPopupMenus["ENEMY"] = { "INSPECT", "RAID_TARGET_1", "RAID_TARGET_2", "RAID_TARGET_3", "RAID_TARGET_4", "RAID_TARGET_5", "RAID_TARGET_6", "RAID_TARGET_7", "RAID_TARGET_8", "RAID_TARGET_NONE" };
UnitPopupMenus["NPC"] = { "RAID_TARGET_1", "RAID_TARGET_2", "RAID_TARGET_3", "RAID_TARGET_4", "RAID_TARGET_5", "RAID_TARGET_6", "RAID_TARGET_7", "RAID_TARGET_8", "RAID_TARGET_NONE" };

-- Sencond Level Menus
BlinkMod_SecondMenus = {};

-- Third Level Menus
BlinkMod_ThirdMenus = {};

-- Show or Hide Menus
BlinkMod_Shown = {};

-- OnLoad ---------------------------------------------------------------------
function BlinkMod_OnLoad()
	BlinkMod_Original_UnitPopup_ShowMenu = UnitPopup_ShowMenu;
	UnitPopup_ShowMenu = BlinkMod_UnitPopup_ShowMenu;
	
	BlinkMod_Original_UnitPopup_OnUpdate = UnitPopup_OnUpdate;
	UnitPopup_OnUpdate = BlinkMod_UnitPopup_OnUpdate;

	UIDropDownMenu_Initialize(getglobal("TargetFrameDropDown"), BlinkMod_TargetFrameDropDown_Initialize, "MENU");

	for p, v in pairs(UnitPopupMenus) do
		for i = 1, #v do
			if v[i] == "SET_FOCUS" or v[i] == "CLEAR_FOCUS" or v[i] == "TARGET" then
				tremove(UnitPopupMenus[p], i)
			end
		end
	end
end

-- Debug Print ----------------------------------------------------------------
function BlinkMod_DebugPrint(msg)
	if ( BlinkMod_DEBUG == true ) then
		if(ChatFrame1) then
			ChatFrame1:AddMessage("BM : "..msg, 1.0, 0.2, 0.2);
		end
	end
end

-- BlinkMod_RemoveMenu --------------------------------------------------------
function BlinkMod_RemoveMenu(parent,key,level)
	local removeKey = -1;
	local t = nil;

	if ( not parent ) then
		return;
	end
	if ( not key ) then
		return;
	end
	if ( not level ) then
		level = 1;
	end

	if ( level == 1 ) then
		for i=1,#BlinkMod_Menus[parent],1 do
			if ( BlinkMod_Menus[parent][i].key == key ) then
				removeKey = i;
				break;
			end
		end
		if ( removeKey > -1 ) then
			table.remove(BlinkMod_Menus[parent],i);
		end
	elseif ( level == 2 ) then
		for i=1,#BlinkMod_SecondMenus[parent],1 do
			if ( BlinkMod_SecondMenus[parent][i].key == key ) then
				removeKey = i;
				break;
			end
		end
		if ( removeKey > -1 ) then
			table.remove(BlinkMod_SecondMenus[parent],i);
		end
	elseif ( level == 3 ) then
		for i=1,#BlinkMod_ThirdMenus[parent],1 do
			if ( BlinkMod_ThirdMenus[parent][i].key == key ) then
				removeKey = i;
				break;
			end
		end
		if ( removeKey > -1 ) then
			table.remove(BlinkMod_ThirdMenus[parent],i);
		end
	end
end

function BlinkMod_UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
	local server = nil;
	-- Init variables
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	if ( unit ) then
		name, server = UnitName(unit);
	elseif ( name ) then
		local n, s = strmatch(name, "^([^-]+)-(.*)");
		if ( n ) then
			name = n;
			server = s;
		end
	end
	dropdownMenu.name = name;
	dropdownMenu.userData = userData;
	dropdownMenu.server = server;

	-- Determine which buttons should be shown or hidden
	UnitPopup_HideButtons();
	BlinkMod_UnitPopup_HideButtons();
	
	-- If only one menu item (the cancel button) then don't show the menu
	local count = 0;
	if ( UnitPopupMenus[which] ) then
		for index, value in ipairs(UnitPopupMenus[which]) do
			if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 and value ~= "CANCEL" ) then
				count = count + 1;
			end
		end
	end
	if ( BlinkMod_Menus[which] ) then
		for index,value in ipairs(BlinkMod_Menus[which]) do
			if ( BlinkMod_Shown[index] == 1 ) then
				count = count + 1;
			end
		end
	end
	if ( count < 1 ) then
		return;
	end

	-- Determine which loot method and which loot threshold are selected and set the corresponding buttons to the same text
	dropdownMenu.selectedLootMethod = UnitLootMethod[GetLootMethod()].text;
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	UnitPopupButtons["LOOT_METHOD"].tooltipText = UnitLootMethod[GetLootMethod()].tooltipText;
	dropdownMenu.selectedLootThreshold = getglobal("ITEM_QUALITY"..GetLootThreshold().."_DESC");
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;
	-- This allows player to view loot settings if he's not the leader
	if ( ((GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0)) and IsPartyLeader() ) then
		-- If this is true then player is the party leader
		UnitPopupButtons["LOOT_METHOD"].nested = 1;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = 1;
	else
		UnitPopupButtons["LOOT_METHOD"].nested = nil;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = nil;
	end
	-- Set the selected opt out of loot option to the opt out of loot button text
	if ( GetOptOutOfLoot() ) then
		UnitPopupButtons["OPT_OUT_LOOT_TITLE"].text = format(OPT_OUT_LOOT_TITLE, UnitPopupButtons["OPT_OUT_LOOT_ENABLE"].text);
	else
		UnitPopupButtons["OPT_OUT_LOOT_TITLE"].text = format(OPT_OUT_LOOT_TITLE, UnitPopupButtons["OPT_OUT_LOOT_DISABLE"].text);
	end

	-- If level 2 dropdown
	local info;
	local color;
	local icon;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		-- Set which menu is being opened
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
		if UIDROPDOWNMENU_MENU_VALUE == "RAID_TARGET_ICON"
		or UIDROPDOWNMENU_MENU_VALUE == "CTRAID_DEFAULT_LOOT_TYPE"
		or UIDROPDOWNMENU_MENU_VALUE == "LOOT_METHOD"
		or UIDROPDOWNMENU_MENU_VALUE == "LOOT_THRESHOLD"
		or UIDROPDOWNMENU_MENU_VALUE == "PVP_FLAG"
		or UIDROPDOWNMENU_MENU_VALUE == "DUNGEON_DIFFICULTY"
		or UIDROPDOWNMENU_MENU_VALUE == "OPT_OUT_LOOT_TITLE"
		then
			info = UIDropDownMenu_CreateInfo();
			for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE]) do
				info.text = UnitPopupButtons[value].text;
				info.owner = UIDROPDOWNMENU_MENU_VALUE;
				-- Set the text color
				color = UnitPopupButtons[value].color;
				if ( color ) then
					info.colorCode = string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255);
				else
					info.colorCode = nil;
				end
				-- Icons
				info.icon = UnitPopupButtons[value].icon;
				info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
				info.tCoordRight = UnitPopupButtons[value].tCoordRight;
				info.tCoordTop = UnitPopupButtons[value].tCoordTop;
				info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
				-- Checked conditions
				info.checked = nil;
				if ( info.text == dropdownMenu.selectedLootMethod  ) then
					info.checked = 1;
				elseif ( info.text == dropdownMenu.selectedLootThreshold ) then
					info.checked = 1;
				elseif ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
					local raidTargetIndex = GetRaidTargetIndex(unit);
					if ( raidTargetIndex == index ) then
						info.checked = 1;
					end
				elseif ( strsub(value, 1, 18) == "DUNGEON_DIFFICULTY" and (strlen(value) > 18)) then
					local dungeonDifficulty = GetCurrentDungeonDifficulty();
					if ( dungeonDifficulty == index ) then
						info.checked = 1;
					end
					local inParty = 0;
					if ( (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0) ) then
						inParty = 1;
					end
					local isLeader = 0;
					if ( IsPartyLeader() ) then
						isLeader = 1;
					end
					local inInstance, instanceType = IsInInstance();
					if ( ( inParty == 1 and isLeader == 0 ) or inInstance ) then
						info.disabled = 1;	
					end

				-- Adds (Default) to the difficulty string.  Removed per request.
				--[[	local defaultDungeonDifficullty = GetDefaultDungeonDifficulty();
					if ( defaultDungeonDifficullty == index ) then
						info.text = info.text.." ("..DEFAULT..")";
					end   ]]
				elseif ( value == "PVP_ENABLE" ) then
					if ( GetPVPDesired() == 1 ) then
						info.checked = 1;
					end
				elseif ( value == "PVP_DISABLE" ) then
					if ( GetPVPDesired() == 0 ) then
						info.checked = 1;
					end
				elseif ( value == "OPT_OUT_LOOT_ENABLE" ) then
					if ( GetOptOutOfLoot() ) then
						info.checked = 1;
					end
				elseif ( value == "OPT_OUT_LOOT_DISABLE" ) then
					if ( not GetOptOutOfLoot() ) then
						info.checked = 1;
					end
				end
				
				info.value = value;
				info.func = UnitPopup_OnClick;
				-- Setup newbie tooltips
				info.tooltipTitle = UnitPopupButtons[value].text;
				info.tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		else
			if ( BlinkMod_SecondMenus[UIDROPDOWNMENU_MENU_VALUE] ) then
				info = UIDropDownMenu_CreateInfo();
				for index, value in ipairs(BlinkMod_SecondMenus[UIDROPDOWNMENU_MENU_VALUE]) do
					info = value;
					if ( not info.ShowHideFunction or (info.ShowHideFunction and info.ShowHideFunction(dropdownMenu) == true) ) then
						if ( info.GetNameFunction ) then
							info.text = info.GetNameFunction(info.text,dropdownMenu);
						end
						if ( info.CheckFunction and info.CheckFunction(dropdownMenu) == true ) then
							info.checked = 1;
						else
							info.checked = nil;
						end
						info.value = info.key;
						info.owner = info.parentkey;
						if value.ClickFunction and type(value.ClickFunction)=='function' then
							info.func = BlinkMod_Second_OnClick;
						end
						UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
					end
				end
			end
		end
		return;
	elseif ( UIDROPDOWNMENU_MENU_LEVEL == 3 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		if ( BlinkMod_ThirdMenus[UIDROPDOWNMENU_MENU_VALUE] ) then
			info = UIDropDownMenu_CreateInfo();
			for index, value in ipairs(BlinkMod_ThirdMenus[UIDROPDOWNMENU_MENU_VALUE]) do
				info = value;
				if ( not info.ShowHideFunction or (info.ShowHideFunction and info.ShowHideFunction(dropdownMenu) == true) ) then
					if ( info.GetNameFunction ) then
						info.text = info.GetNameFunction(info.text,dropdownMenu);
					end
					if ( info.CheckFunction and info.CheckFunction(dropdownMenu) == true ) then
						info.checked = 1;
					else
						info.checked = nil;
					end
					info.value = info.key;
					info.owner = info.parentkey;
					if value.ClickFunction and type(value.ClickFunction)=='function' then
						info.func = BlinkMod_Third_OnClick;
					end
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
		return;
	end

	-- Add dropdown title
	if ( unit or name ) then
		info = UIDropDownMenu_CreateInfo();
		if ( name ) then
			info.text = name;
		else
			info.text = UNKNOWN;
		end
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);
	end

	if ( UnitPopupMenus[which] ) then
		-- Set which menu is being opened
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
		-- Show the buttons which are used by this menu
		local tooltipText;
		info = UIDropDownMenu_CreateInfo();
		for index, value in ipairs(UnitPopupMenus[which]) do
			if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 and value ~= "CANCEL" ) then
				info.text = UnitPopupButtons[value].text;
				info.value = value;
				info.owner = which;
				info.func = UnitPopup_OnClick;
				if ( not UnitPopupButtons[value].checkable ) then
					info.notCheckable = 1;
				else
					info.notCheckable = nil;
				end
				-- Text color
				if ( value == "LOOT_THRESHOLD" ) then
					-- Set the text color
					info.colorCode = ITEM_QUALITY_COLORS[GetLootThreshold()].hex;
				else
					color = UnitPopupButtons[value].color;
					if ( color ) then
						info.colorCode = string.format("|cFF%02x%02x%02x",  color.r*255,  color.g*255,  color.b*255);
					else
						info.colorCode = nil;
					end
				end

				-- Icons
				info.icon = UnitPopupButtons[value].icon;
				info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
				info.tCoordRight = UnitPopupButtons[value].tCoordRight;
				info.tCoordTop = UnitPopupButtons[value].tCoordTop;
				info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
				-- Checked conditions
				info.checked = nil;
				if ( strsub(value, 1, 12) == "RAID_TARGET_" and value ~= "RAID_TARGET_ICON" ) then
					local raidTargetIndex = GetRaidTargetIndex("target");
					if ( raidTargetIndex == index ) then
						info.checked = 1;
					end
				end

				if ( UnitPopupButtons[value].nested ) then
					info.hasArrow = 1;
				else
					info.hasArrow = nil;
				end
				
				-- Setup newbie tooltips
				info.tooltipTitle = UnitPopupButtons[value].text;
				tooltipText = getglobal("NEWBIE_TOOLTIP_UNIT_"..value);
				if ( not tooltipText ) then
					tooltipText = UnitPopupButtons[value].tooltipText;
				end
				info.tooltipText = tooltipText;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	-- 추가적인 팝업메뉴들
	if ( BlinkMod_Menus[which] ) then
		for index,value in ipairs(BlinkMod_Menus[which]) do
			if ( not value.ShowHideFunction or (value.ShowHideFunction and value.ShowHideFunction(dropdownMenu) == true) ) then
				if ( value.GetNameFunction ) then
					value.text = value.GetNameFunction(value.text,dropdownMenu);
				end
				if ( value.CheckFunction and value.CheckFunction(dropdownMenu) == true ) then
					value.checked = 1;
				else
					value.checked = nil;
				end
				if value.ClickFunction and type(value.ClickFunction)=='function' then
					value.func = BlinkMod_OnClick;
				end
				value.value = value.key;
				value.owner = value.parentkey;
				UIDropDownMenu_AddButton(value);
			end
		end
	end

	-- 취소버튼
	info = UIDropDownMenu_CreateInfo();
	info.text = UnitPopupButtons["CANCEL"].text;
	info.value = "CANCEL";
	info.owner = which;
	info.func = UnitPopup_OnClick;
	info.notCheckable = 1;
	info.tooltipTitle = UnitPopupButtons["CANCEL"].text;
	info.tooltipText = nil;
	UIDropDownMenu_AddButton(info);

	PlaySound("igMainMenuOpen");
end

function BlinkMod_UnitPopup_OnUpdate(elapsed)
	if ( not DropDownList1:IsShown() ) then
		return;
	end

	-- If none of the untipopup frames are visible then return
	for index, value in ipairs(UnitPopupFrames) do
		if ( UIDROPDOWNMENU_OPEN_MENU == value ) then
			break;
		elseif ( index == #UnitPopupFrames ) then
			return;
		end
	end

	local dropdownFrame = getglobal(UIDROPDOWNMENU_OPEN_MENU);
	if ( not UnitPopupMenus[dropdownFrame.which] ) then
		return;
	end

	BlinkMod_Original_UnitPopup_OnUpdate(elapsed);
end

function BlinkMod_UnitPopup_HideButtons()
	local dropdownMenu = getglobal(UIDROPDOWNMENU_INIT_MENU);

	if ( not dropdownMenu or not dropdownMenu.which or not BlinkMod_Menus[dropdownMenu.which] ) then
		return;
	end
	for index, value in ipairs(BlinkMod_Menus[dropdownMenu.which]) do
		BlinkMod_Shown[index] = 1;
		if ( value.ShowHideFunction ) then
			if ( value.ShowHideFunction(dropdownMenu) == false ) then
				BlinkMod_Shown[index] = 0;
			end
		end
	end
end

--[[
List of button attributes
======================================================
info.key = [STRING] -- 버튼의 키값(필수)
info.parentkey = [STRING] -- 상위버튼의 키값(필수)

info.text = [STRING]  --  버튼이름(필수)
info.checked = [nil, 1]  --  버튼이 체크되어있는가?
info.isTitle = [nil, 1]  --  타이틀버튼인가? (타이틀버튼이라면 클릭이 안되며, 글자색은 노란색으로 보입니다.)
info.disabled = [nil, 1]  --  클릭할수 없는 버튼인가?
info.hasArrow = [nil, 1]  --  화살표가 있는 버튼인가? (하위메뉴를 가질수 있는가를 설정하는 변수)
info.hasColorSwatch = [nil, 1]  --  컬러색상을 선택하는 버튼인가?
info.r = [1 - 255]  --  선택된컬러값 Red
info.g = [1 - 255]  --  선택된컬러값 Green
info.b = [1 - 255]  --  선택된컬러값 Blue
info.textR = [1 - 255]  --  버튼글자색 Red
info.textG = [1 - 255]  --  버튼글자색 Green
info.textB = [1 - 255]  --  버튼글자색 Blue
info.swatchFunc = [function()]  --  컬러선택창에서 컬러값이 바뀔때마다 호출되는 함수
info.hasOpacity = [nil, 1]  --  컬러선택창에 투명도선택 슬라이드바를 보여줄것인지 선택하는 변수
info.opacity = [0.0 - 1.0]  --  선택된 투명도를 나타내는 값 1.0은 불투명, 0은 완전투명
info.opacityFunc = [function()]  --  투명도슬라이드값을 바꿀대마다 호출되는 함수
info.cancelFunc = [function(previousValues)] -- 컬러선택창에서 취소버튼을 눌렀을때 호출되는 함수 (이 함수는 이전값을 매개변수로 갖습니다. - it takes the previous values as its argument)
info.notClickable = [nil, 1]  --  클릭할수 없는 버튼으로 만드는 변수(글자색은 흰색)
info.notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
info.owner = [Frame]  --  현재 드롭다운리스트의 부모 드롭다운프레임(Dropdown frame that "owns" the current dropdownlist)
info.keepShownOnClick = [nil, 1]  --  버튼을 클릭해도 메뉴가 사라지지 않도록하는 변수
info.tooltipTitle = [nil, STRING] -- 버튼에 마우스를 올렸을때 나타나는 툴팁의 타이틀
info.tooltipText = [nil, STRING] -- 버튼에 마우스를 올렸을때 나타나는 툴팁내용
info.justifyH = [nil, "CENTER"] -- 버튼 정렬

info.ClickFunction = [function()] -- 버튼을 클릭하면 호출되는 함수
info.GetNameFunction = [function()] -- 버튼의 이름을 설정하는 함수
info.CheckFunction = [function()] -- 현재 버튼이 체크되어있는지 확인하는 함수
info.ShowHideFunction = [function()] -- 현재 버튼이 보여지는지 확인하는 함수
]]--
function BlinkMod_RegisterMenu( info, level )
	if ( not level ) then
		level = 1;
	end
	if ( type(info) ~= "table" ) then
		BlinkMod_DebugPrint("\"info\" is not table.");
		return;
	end

	if ( not info.key ) then
		BlinkMod_DebugPrint("\"key\" arg is nil.");
		return;
	end

	if ( level == 1 ) then
		if ( not info.parentkey ) then
			BlinkMod_DebugPrint("\"parentkey\" arg is nil.");
			return;
		end
		local dup = false;
		local dupkey = "dupkey";
		if ( BlinkMod_Menus[info.parentkey] ) then
			for idx,menu in pairs(BlinkMod_Menus[info.parentkey]) do
				if ( menu and menu.key == info.key ) then
					dup = true;
					dupkey = info.key;
					break;
				end
			end
		end
		if ( dup == true ) then
			BlinkMod_DebugPrint("1. Duplicated Key : "..dupkey);
			return;
		end
		table.insert(BlinkMod_Menus[info.parentkey],info);
	elseif ( level == 2 ) then
		if ( not info.parentkey ) then
			BlinkMod_DebugPrint("\"parentkey\" arg is nil.");
			return;
		end
		local dup = false;
		local dupkey = "dupkey";
		if ( BlinkMod_SecondMenus[info.parentkey] ) then
			for idx,menu in pairs(BlinkMod_SecondMenus[info.parentkey]) do
				if ( menu and menu.key == info.key ) then
					dup = true;
					dupkey = info.key;
					break;
				end
			end
		end
		if ( dup == true ) then
			BlinkMod_DebugPrint("2. Duplicated Key : "..dupkey);
			return;
		end
		if ( not BlinkMod_SecondMenus[info.parentkey] ) then
			BlinkMod_SecondMenus[info.parentkey] = {};
		end
		table.insert(BlinkMod_SecondMenus[info.parentkey],info);
	elseif ( level == 3 ) then
		if ( not info.parentkey ) then
			BlinkMod_DebugPrint("\"parentkey\" arg is nil.");
			return;
		end
		local dup = false;
		local dupkey = "dupkey";
		if ( BlinkMod_ThirdMenus[info.parentkey] ) then
			for idx,menu in pairs(BlinkMod_ThirdMenus[info.parentkey]) do
				if ( menu and menu.key == info.key ) then
					dup = true;
					dupkey = info.key;
					break;
				end
			end
		end
		if ( dup == true ) then
			BlinkMod_DebugPrint("3. Duplicated Key : "..dupkey);
			return;
		end
		if ( not BlinkMod_ThirdMenus[info.parentkey] ) then
			BlinkMod_ThirdMenus[info.parentkey] = {};
		end
		table.insert(BlinkMod_ThirdMenus[info.parentkey],info);
	else
		BlinkMod_DebugPrint("Wrong level value!");
	end
end

function BlinkMod_OnClick()
	local key = this.value;
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local clickfunc;
--	BlinkMod_DebugPrint("1. UIDROPDOWNMENU_INIT_MENU : "..UIDROPDOWNMENU_INIT_MENU);
--	BlinkMod_DebugPrint("1. this.owner : "..this.owner);
--	BlinkMod_DebugPrint("1. this.value : "..this.value);
--	BlinkMod_DebugPrint("1. this:Getname : "..this:GetName());
	for index, value in pairs(BlinkMod_Menus[this.owner]) do
		if ( value.key == key ) then
			clickfunc = value.ClickFunction;
			break;
		end
	end

	if ( clickfunc and type(clickfunc)=='function' ) then
		clickfunc(dropdownFrame);
	end
	PlaySound("UChatScrollButton");
end

function BlinkMod_Second_OnClick()
	local key = this.value;
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local clickfunc;
--	BlinkMod_DebugPrint("2. UIDROPDOWNMENU_INIT_MENU : "..UIDROPDOWNMENU_INIT_MENU);
--	BlinkMod_DebugPrint("2. this.owner : "..this.owner);
--	BlinkMod_DebugPrint("2. this.value : "..this.value);
	for index, value in pairs(BlinkMod_SecondMenus[this.owner]) do
		if ( value.key == key ) then
			clickfunc = value.ClickFunction;
			break;
		end
	end

	if ( clickfunc and type(clickfunc)=='function' ) then
		clickfunc(dropdownFrame);
	end
	PlaySound("UChatScrollButton");
end

function BlinkMod_Third_OnClick()
	local key = this.value;
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local clickfunc;
--	BlinkMod_DebugPrint("3. UIDROPDOWNMENU_INIT_MENU : "..UIDROPDOWNMENU_INIT_MENU);
--	BlinkMod_DebugPrint("3. this.owner : "..this.owner);
--	BlinkMod_DebugPrint("3. this.value : "..this.value);
	for index, value in pairs(BlinkMod_ThirdMenus[this.owner]) do
		if ( value.key == key ) then
			clickfunc = value.ClickFunction;
			break;
		end
	end

	if ( clickfunc and type(clickfunc)=='function' ) then
		clickfunc(dropdownFrame);
	end
	PlaySound("UChatScrollButton");
end


function BlinkMod_TargetFrameDropDown_Initialize(self)
	local menu;
	local name;
	local id = nil;
	if ( UnitIsUnit("target", "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit("target", "vehicle") ) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif ( UnitIsUnit("target", "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer("target") ) then
		id = UnitInRaid("target");
		if ( id ) then
			menu = "RAID_PLAYER";
			name = GetRaidRosterInfo(id +1);
		elseif ( UnitInParty("target") ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	elseif ( not UnitIsPlayer("target") ) then
		menu = "NPC";
	elseif ( UnitPlayerControlled("target") and UnitFactionGroup("target")~=UnitFactionGroup("player") ) then
		-- enemy
		menu = "ENEMY";
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, "target", name, id);
	end
end


-- start
BlinkMod_OnLoad();

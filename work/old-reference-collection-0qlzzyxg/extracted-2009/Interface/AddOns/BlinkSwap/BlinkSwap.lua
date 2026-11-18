-------------------------------------------------------------------------------
--
--  Mod Name : BlinkSwap v2.02
--  Author   : Blink
--  Date     : 2004/10/11
--  LastUpdate : 2008/10/23
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
BlinkSwap_Version = "v2.02";
BlinkSwap_Version_n = 2.02;

BlinkSwap_MainHandSlotID = 16;
BlinkSwap_OffHandSlotID = 17;
BlinkSwap_RangedSlotID = 18;
BlinkSwap_AmmoSlotID = 0;

local wswap = nil

-------------------------------------------------------------------------------
-- BlinkPrint
-------------------------------------------------------------------------------
if( not BlinkPrint ) then
	BlinkPrint = function(msg)
		if(ChatFrame1) then
			ChatFrame1:AddMessage(msg, 1.0, 1.0, 0.0);
		end
	end
end

function BSFirstCapStr(data)
	local firstletter = strsub(data, 1, 1);
	if( BSIsAlphabet(firstletter) == true )then
		local remainingdata = strsub(data, 2, strlen(data));		
		local capletter = string.upper(firstletter);
		local fixeddata = (capletter..string.lower(remainingdata));
		return fixeddata;
	else
		return data;
	end
end

function BSIsAlphabet(char)
	local b = string.byte(char);
	if( b>=65 and b<=122 )then
		return true;
	else
		return false;
	end
end

--*****************************************************************************
-- OnFoo functions
--*****************************************************************************

-------------------------------------------------------------------------------
-- BlinkSwap_OnLoad
-------------------------------------------------------------------------------
function BlinkSwap_OnLoad(self)
	BlinkWeaponSwap = {};

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");

	SlashCmdList["BLINKSWAPSAVE"] = function(msg) BlinkSwap_SaveCurrentWeapons(); end
	for i=1,getn(BLINK_SWAP_SAVE_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPSAVE"..i,BLINK_SWAP_SAVE_COMMAND[i]);
	end
	
	SlashCmdList["BLINKSWAPRANGEDSAVE"] = function(msg) BlinkSwap_SaveCurrentRangedWeapons(); end
	for i=1,getn(BLINK_SWAP_RANGED_SAVE_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPRANGEDSAVE"..i,BLINK_SWAP_RANGED_SAVE_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPSAVEFORM"] = function(msg) BlinkSwap_SaveCurrentWeapons_State(); end
	for i=1,getn(BLINK_SWAP_SAVE_FORM_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPSAVEFORM"..i,BLINK_SWAP_SAVE_FORM_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPUSEFORM"] = function(msg) BlinkSwap_ToggleFormSwap(); end
	for i=1,getn(BLINK_SWAP_USE_FORM_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPUSEFORM"..i,BLINK_SWAP_USE_FORM_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPSWAP"] = function(msg) BlinkSwap_Swapping(); end
	for i=1,getn(BLINK_SWAP_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPSWAP"..i,BLINK_SWAP_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPSWAPRANGED"] = function(msg) BlinkSwap_Swapping_Ranged(); end
	for i=1,getn(BLINK_SWAP_RANGED_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPSWAPRANGED"..i,BLINK_SWAP_RANGED_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPLIST"] = function(msg) BlinkSwapView(); end
	for i=1,getn(BLINK_SWAP_LIST_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPLIST"..i,BLINK_SWAP_LIST_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPRESET"] = function(msg) BlinkSwapReset(msg); end
	for i=1,getn(BLINK_SWAP_RESET_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPRESET"..i,BLINK_SWAP_RESET_COMMAND[i]);
	end

	SlashCmdList["BLINKSWAPHELP"] = function(msg) BlinkSwapHelp(); end
	for i=1,getn(BLINK_SWAP_HELP_COMMAND),1 do
		setglobal("SLASH_BLINKSWAPHELP"..i,BLINK_SWAP_HELP_COMMAND[i]);
	end
end


-------------------------------------------------------------------------------
-- BlinkSwap_OnEvent
-------------------------------------------------------------------------------
function BlinkSwap_OnEvent(self, event, ...)
	local arg1 = ...
	if (event == "VARIABLES_LOADED") then
		if ( BlinkMod_RegisterMenu ) then
			BS_BM_Register();
		end
		UIErrorsFrame:AddMessage("블링크의 무기스왑 애드온 "..BlinkSwap_Version.." 로딩완료!", 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME);

		local class, filename = UnitClass("player");
		if ( filename == "WARRIOR" ) then
			if ( LoadAddOn("BlinkSwapOverpower") ) then
				UIErrorsFrame:AddMessage("블링크의 자동 제압스왑 로딩완료!", 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
			end
		else
			local Filename = BSFirstCapStr(filename);
			if ( LoadAddOn("BlinkSwap"..Filename) ) then
				UIErrorsFrame:AddMessage("블링크의 "..class.." 스왑 로딩완료!", 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
			end
		end
		if ( filename == "HUNTER" or filename == "PALADIN" ) then
			self:RegisterEvent("UNIT_AURA");
		end
		if ( not BlinkWeaponSwap.version or BlinkWeaponSwap.version < BlinkSwap_Version_n ) then
			BlinkWeaponSwap = {
				version = BlinkSwap_Version_n
			};
		end
		BlinkSwap_MainHandSlotID = GetInventorySlotInfo("MainHandSlot");
		BlinkSwap_OffHandSlotID = GetInventorySlotInfo("SecondaryHandSlot");
		BlinkSwap_RangedSlotID = GetInventorySlotInfo("RangedSlot");
		BlinkSwap_AmmoSlotID = GetInventorySlotInfo("AmmoSlot");
	elseif event == "ITEM_LOCK_CHANGED" then
		return BlinkSwap_ExecuteSwapIteration();
	elseif( event == "UPDATE_BONUS_ACTIONBAR" )then
		BlinkSwap_ShapeShiftForm();
	elseif( event == "UNIT_AURA" and arg1 == "player" )then
		if ( UnitClass("player") == "사냥꾼" or UnitClass("player") == "성기사" ) then
			BlinkSwap_ChangeAura();
		end
	end
end


--*****************************************************************************
-- BlinkSwap functions
--*****************************************************************************


-------------------------------------------------------------------------------
-- BlinkSwap_ToggleFormSwap
-------------------------------------------------------------------------------
function BlinkSwap_ToggleFormSwap()
	if( not BlinkWeaponSwap ) then
		BlinkWeaponSwap = {};
		BlinkWeaponSwap["useForm"] = 0;
	end
	if( BlinkWeaponSwap["useForm"] ~= 1 )then
		BlinkWeaponSwap["useForm"] = 1;
		BlinkPrint("태세변환 무기스왑을 사용합니다.");
	else
		BlinkWeaponSwap["useForm"] = 0;
		BlinkPrint("태세변환 무기스왑을 사용하지 않습니다.");
	end
end

-------------------------------------------------------------------------------
-- BlinkSwap_SaveCurrentWeapons
-------------------------------------------------------------------------------
function BlinkSwap_SaveCurrentWeapons()
	local m,mid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
	local s,sid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);

	if( m == nil or ( m == nil and s == nil ) ) then return; end
	
	if( not BlinkWeaponSwap ) then
		BlinkWeaponSwap = {};
	end

	if( BlinkWeaponSwap["Set1"] == nil )then
		BlinkWeaponSwap["Set1"] = {};
		BlinkWeaponSwap["Set1"]["main"] = {name="",id=""};
		BlinkWeaponSwap["Set1"]["off"] = {name="",id=""};
	end
	if( BlinkWeaponSwap["Set2"] == nil )then
		BlinkWeaponSwap["Set2"] = {};
		BlinkWeaponSwap["Set2"]["main"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["off"] = {name="",id=""};
	end

	if( BlinkWeaponSwap["Set1"]["main"].name ~= "" and BlinkWeaponSwap["Set2"]["main"].name ~= "" ) then
		BlinkWeaponSwap["Set1"]["main"].name = BlinkWeaponSwap["Set2"]["main"].name;
		BlinkWeaponSwap["Set1"]["main"].id = BlinkWeaponSwap["Set2"]["main"].id;
		BlinkWeaponSwap["Set1"]["off"].name = BlinkWeaponSwap["Set2"]["off"].name;
		BlinkWeaponSwap["Set1"]["off"].id = BlinkWeaponSwap["Set2"]["off"].id;
		BlinkWeaponSwap["Set2"]["main"].name = m;
		BlinkWeaponSwap["Set2"]["main"].id = mid;
		BlinkWeaponSwap["Set2"]["off"].name = s;
		BlinkWeaponSwap["Set2"]["off"].id = sid;
	elseif( BlinkWeaponSwap["Set1"]["main"].name ~= "" and BlinkWeaponSwap["Set2"]["main"].name == "" ) then
		BlinkWeaponSwap["Set2"]["main"].name = m;
		BlinkWeaponSwap["Set2"]["main"].id = mid;
		BlinkWeaponSwap["Set2"]["off"].name = s;
		BlinkWeaponSwap["Set2"]["off"].id = sid;
	else
		BlinkWeaponSwap["Set1"]["main"].name = m;
		BlinkWeaponSwap["Set1"]["main"].id = mid;
		BlinkWeaponSwap["Set1"]["off"].name = s;
		BlinkWeaponSwap["Set1"]["off"].id = sid;
		BlinkWeaponSwap["Set2"]["main"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["off"] = {name="",id=""};
	end
	BlinkSwapView();
end

-------------------------------------------------------------------------------
-- BlinkSwap_SaveCurrentRangedWeapons
-------------------------------------------------------------------------------
function BlinkSwap_SaveCurrentRangedWeapons()
	local r,rid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
	local a,aid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);

	if( r == nil or ( r == nil and a == nil ) ) then return; end
	
	if( not BlinkWeaponSwap ) then
		BlinkWeaponSwap = {};
	end

	if( not BlinkWeaponSwap["Set1"] )then
		BlinkWeaponSwap["Set1"] = {};
		BlinkWeaponSwap["Set1"]["main"] = {name="",id=""};
		BlinkWeaponSwap["Set1"]["off"] = {name="",id=""};
		BlinkWeaponSwap["Set1"]["ranged"] = {name="",id=""};
		BlinkWeaponSwap["Set1"]["ammo"] = {name="",id=""};
	end
	if( not BlinkWeaponSwap["Set2"] )then
		BlinkWeaponSwap["Set2"] = {};
		BlinkWeaponSwap["Set2"]["main"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["off"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["ranged"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["ammo"] = {name="",id=""};
	end

	if ( not BlinkWeaponSwap["Set1"]["ranged"] ) then
		BlinkWeaponSwap["Set1"]["ranged"] = {name="",id=""};
		BlinkWeaponSwap["Set1"]["ammo"] = {name="",id=""};
	end
	if ( not BlinkWeaponSwap["Set2"]["ranged"] ) then
		BlinkWeaponSwap["Set2"]["ranged"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["ammo"] = {name="",id=""};
	end

	if( BlinkWeaponSwap["Set1"]["ranged"].name ~= "" and BlinkWeaponSwap["Set2"]["ranged"].name ~= "" ) then
		BlinkWeaponSwap["Set1"]["ranged"].name = BlinkWeaponSwap["Set2"]["ranged"].name;
		BlinkWeaponSwap["Set1"]["ranged"].id = BlinkWeaponSwap["Set2"]["ranged"].id;
		BlinkWeaponSwap["Set1"]["ammo"].name = BlinkWeaponSwap["Set2"]["ammo"].name;
		BlinkWeaponSwap["Set1"]["ammo"].id = BlinkWeaponSwap["Set2"]["ammo"].id;
		BlinkWeaponSwap["Set2"]["ranged"].name = r;
		BlinkWeaponSwap["Set2"]["ranged"].id = rid;
		BlinkWeaponSwap["Set2"]["ammo"].name = a;
		BlinkWeaponSwap["Set2"]["ammo"].id = aid;
	elseif( BlinkWeaponSwap["Set1"]["ranged"].name ~= "" and BlinkWeaponSwap["Set2"]["ranged"].name == "" ) then
		BlinkWeaponSwap["Set2"]["ranged"].name = r;
		BlinkWeaponSwap["Set2"]["ranged"].id = rid;
		BlinkWeaponSwap["Set2"]["ammo"].name = a;
		BlinkWeaponSwap["Set2"]["ammo"].id = aid;
	else
		BlinkWeaponSwap["Set1"]["ranged"].name = r;
		BlinkWeaponSwap["Set1"]["ranged"].id = rid;
		BlinkWeaponSwap["Set1"]["ammo"].name = a;
		BlinkWeaponSwap["Set1"]["ammo"].id = aid;
		BlinkWeaponSwap["Set2"]["ranged"] = {name="",id=""};
		BlinkWeaponSwap["Set2"]["ammo"] = {name="",id=""};
	end
	BlinkSwapView();
end

-------------------------------------------------------------------------------
-- BlinkSwap_SaveCurrentWeapons_State
-------------------------------------------------------------------------------
function BlinkSwap_SaveCurrentWeapons_State()
	if( UnitClass("player") == "사냥꾼" or UnitClass("player") == "성기사" )then
		BlinkSwap_SaveCurrentWeapons_Aura();
	else
		BlinkSwap_SaveCurrentWeapons_Form();
	end
end

-------------------------------------------------------------------------------
-- BlinkSwap_SaveCurrentWeapons_Form
-------------------------------------------------------------------------------
function BlinkSwap_SaveCurrentWeapons_Form()
	local form = BlinkSwap_GetForm();
	local m,mid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
	local s,sid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);
	local r,rid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
	local a,aid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);

	if( m == nil or ( m == nil and s == nil ) ) then return; end
	
	if( BlinkWeaponSwap == nil ) then
		BlinkWeaponSwap = {};
	end
	if( BlinkWeaponSwap[form] == nil ) then
		BlinkWeaponSwap[form] = {};
		BlinkWeaponSwap[form]["main"] = {name="",id=""};
		BlinkWeaponSwap[form]["off"] = {name="",id=""};
		BlinkWeaponSwap[form]["ranged"] = {name="",id=""};
		BlinkWeaponSwap[form]["ammo"] = {name="",id=""};
	end
	BlinkWeaponSwap[form]["main"].name = m;
	BlinkWeaponSwap[form]["main"].id = mid;
	BlinkWeaponSwap[form]["off"].name = s;
	BlinkWeaponSwap[form]["off"].id = sid;
	BlinkWeaponSwap[form]["ranged"].name = r;
	BlinkWeaponSwap[form]["ranged"].id = rid;
	BlinkWeaponSwap[form]["ammo"].name = a;
	BlinkWeaponSwap[form]["ammo"].id = aid;
	BlinkSwapView();
end

-------------------------------------------------------------------------------
-- BlinkSwap_SaveCurrentWeapons_Aura
-------------------------------------------------------------------------------
function BlinkSwap_SaveCurrentWeapons_Aura()
	local aura = BlinkSwap_GetAura();
	local m,mid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
	local s,sid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);
	local r,rid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
	local a,aid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);

	if( m == nil or ( m == nil and s == nil ) ) then return; end
	
	if( BlinkWeaponSwap == nil ) then
		BlinkWeaponSwap = {};
	end
	if( BlinkWeaponSwap[aura] == nil ) then
		BlinkWeaponSwap[aura] = {};
		BlinkWeaponSwap[aura]["main"] = {name="",id=""};
		BlinkWeaponSwap[aura]["off"] = {name="",id=""};
		BlinkWeaponSwap[aura]["ranged"] = {name="",id=""};
		BlinkWeaponSwap[aura]["ammo"] = {name="",id=""};
	end
	BlinkWeaponSwap[aura]["main"].name = m;
	BlinkWeaponSwap[aura]["main"].id = mid;
	BlinkWeaponSwap[aura]["off"].name = s;
	BlinkWeaponSwap[aura]["off"].id = sid;
	BlinkWeaponSwap[aura]["ranged"].name = r;
	BlinkWeaponSwap[aura]["ranged"].id = rid;
	BlinkWeaponSwap[aura]["ammo"].name = a;
	BlinkWeaponSwap[aura]["ammo"].id = aid;
	BlinkSwapView();
end

-------------------------------------------------------------------------------
-- BlinkSwapReset
-------------------------------------------------------------------------------
function BlinkSwapReset(set)
	BlinkWeaponSwap = {
		version = BlinkSwap_Version_n
	};
end

-------------------------------------------------------------------------------
-- BlinkSwapHelp
-------------------------------------------------------------------------------
function BlinkSwapHelp()
	BlinkPrint("블링크의 무기스왑 애드온 "..BlinkSwap_Version.." 도움말:");
	BlinkPrint(" /스왑도움말   : 도움말 메세지를 볼수 있습니다.");
	BlinkPrint(" /스왑설정     : 현재 장착하고있는 무기를 스왑할 무기로 저장합니다.");
	BlinkPrint(" /스왑원거리설정 : 현재 장착하고있는 원거리무기(우상,성서,토템)를 스왑할 원거리무기로 저장합니다.");
	BlinkPrint(" /스왑         : /스왑설정 명령어로 저장한 무기들을 스왑합니다.");
	BlinkPrint(" /스왑원거리   : /스왑원거리설정 명령어로 저장한 원거리무기들을 스왑합니다.");
	BlinkPrint(" /스왑목록     : /스왑설정 명령어로 저장한 무기들의 목록을 확인합니다.");
	BlinkPrint(" /태세스왑설정 : 태세,변신,은신형태에 따라 자동으로 무기를 스왑할것인지 여부를 선택합니다.");
	BlinkPrint(" /태세스왑저장 : 태세,변신,은신형태에 따라 자동으로 스왑할 무기를 저장합니다.");
	BlinkPrint(" /스왑초기화   : /스왑설정 명령어와 /태세스왑저장 명령어로 저장한 무기들을 초기화합니다.");
	BlinkPrint("단축설정에서 [무기스왑], [스왑무기저장], [태세,변신,은신 무기저장]키를 설정하시면 /스왑, /스왑설정, /태세스왑저장 명령어를 쉽게 사용하실 수 있습니다.");
end

-------------------------------------------------------------------------------
-- BlinkSwapView
-------------------------------------------------------------------------------
function BlinkSwapView()
	local sets = BlinkSwap_GetData();
	if( not sets ) then
		BlinkPrint(BS_NOT_SET_WEAPONS_DESC);
		return;
	end

	local lsetname = "";
	BlinkPrint(BLINK_WEAPON_SWAP_LIST1);
	BlinkPrint(BLINK_WEAPON_SWAP_LIST2);
	for setname, weapons in pairs(sets) do
		if( setname == "Set1" )then
			lsetname = "스왑세트1";
		elseif( setname == "Set2" )then
			lsetname = "스왑세트2";
		elseif( setname ~= "useForm" )then
			lsetname = setname;
		end
		if( weapons and type(weapons) == "table" )then
			if( not weapons["main"] or weapons["main"].name == "" )then
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"주무기","없음"));
			else
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"주무기",weapons["main"].name));
			end
			if( not weapons["off"] or weapons["off"].name == "" )then
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"보조장비","없음"));
			else
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"보조장비",weapons["off"].name));
			end
			if( not weapons["ranged"] or weapons["ranged"].name == "" )then
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"원거리무기","없음"));
			else
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"원거리무기",weapons["ranged"].name));
			end
			if( not weapons["ammo"] or weapons["ammo"].name == "" )then
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"탄환/총알","없음"));
			else
				BlinkPrint(format(BLINK_WEAPON_SWAP_LIST,lsetname,"탄환/총알",weapons["ammo"].name));
			end
		end
	end
	BlinkPrint(BLINK_WEAPON_SWAP_LIST2);
end


-------------------------------------------------------------------------------
-- BlinkSwap_ShapeShiftForm
-------------------------------------------------------------------------------
function BlinkSwap_ShapeShiftForm()
	if(UnitIsDeadOrGhost("player")) then
		return;
	end
	local sets = BlinkSwap_GetData();

	if( not sets )then return; end
	if( sets["useForm"] ~= 1 )then return; end

	local form = BlinkSwap_GetForm();
	BlinkSwap_Swapping_Form( form );
end

-------------------------------------------------------------------------------
-- BlinkSwap_Swapping_Form
-------------------------------------------------------------------------------
function BlinkSwap_Swapping_Form( form )
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return;
	end

	if( sets[form] == nil ) then
		return;
	end

	if ( sets[form]["ranged"] and sets[form]["ammo"] ) then
		BlinkEquipRanged(sets[form]["ranged"].id or "", sets[form]["ammo"].id or "");
	end

	-- 무기스왑 실행
	BlinkSwapExecute( sets[form]["main"].id or "", sets[form]["off"].id or "" );
end

-------------------------------------------------------------------------------
-- BlinkSwap_ChangeAura
-------------------------------------------------------------------------------
function BlinkSwap_ChangeAura()
	if(UnitIsDeadOrGhost("player")) then
		return;
	end
	local sets = BlinkSwap_GetData();

	if( not sets )then return; end
	if( sets["useForm"] ~= 1 )then return; end

	local aura = BlinkSwap_GetAura();
	BlinkSwap_Swapping_Form( aura );
end

-------------------------------------------------------------------------------
-- BlinkSwap_Swapping
-------------------------------------------------------------------------------
function BlinkSwap_Swapping()
	local player = UnitName("player");
	if ( player == nil or player == UKNOWNBEING or player == UNKNOWNOBJECT ) then return; end

	local sets = BlinkSwap_GetData();
	if( not sets )then
		BlinkPrint(BS_NOT_SET_WEAPONS_DESC);
		return;
	end

	if( sets["Set1"] == nil ) then
		BlinkPrint(BS_NOT_SET_WEAPONS_DESC);
		return;
	end

	-- 무기스왑 실행
	BlinkSwapExecute( sets["Set1"]["main"].id, sets["Set1"]["off"].id, sets["Set2"]["main"].id, sets["Set2"]["off"].id );
	return;
end

-------------------------------------------------------------------------------
-- BlinkSwap_Swapping_Ranged
-------------------------------------------------------------------------------
function BlinkSwap_Swapping_Ranged()
	local player = UnitName("player");
	if ( player == nil or player == UKNOWNBEING or player == UNKNOWNOBJECT ) then return; end

	local sets = BlinkSwap_GetData();
	if( not sets )then
		BlinkPrint(BS_NOT_SET_WEAPONS_DESC);
		return;
	end

	if( not sets["Set1"] or not sets["Set1"]["ranged"] ) then
		BlinkPrint(BS_NOT_SET_WEAPONS_DESC);
		return;
	end

	-- 원거리무기스왑
	--[[
	BlinkPrint(sets["Set1"]["ranged"].id.."*" or "nil")
	BlinkPrint(sets["Set1"]["ammo"].id.."*" or "nil")
	BlinkPrint(sets["Set2"]["ranged"].id.."*" or "nil")
	BlinkPrint(sets["Set2"]["ammo"].id.."*" or "nil")
	]]
	BlinkEquipRanged(sets["Set1"]["ranged"].id or "", sets["Set1"]["ammo"].id or "", sets["Set2"]["ranged"].id or "", sets["Set2"]["ammo"].id or "");
end

-------------------------------------------------------------------------------
-- BlinkSwap_GetForm
-------------------------------------------------------------------------------
function BlinkSwap_GetForm()
	for i=1, GetNumShapeshiftForms() do
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
		if(isActive) then
			return name;
		end
	end
	if(UnitClass("player") == "드루이드") then
		return "인간형";
	elseif(UnitClass("player") == "도적") then
		return "은신풀림";
	else
		return "보통형태";
	end
end

function BlinkSwap_GetAura()
	local i = 1
	local name
	if ( UnitClass("player") == "사냥꾼" ) then
		name = UnitAura("player", i, "HEALFUL|PLAYER")
		while name do
			if name == "원숭이의 상"
			or name == "매의 상"
			or name == "치타의 상"
			or name == "야수의 상"
			or name == "치타 무리의 상"
			or name == "야생의 상"
			or name == "치타의 상"
			or name == "독사의 상"
			then
				return name
			end
			i = i + 1
			name = UnitAura("player", i, "HEALFUL|PLAYER")
		end
	elseif ( UnitClass("player") == "성기사" ) then
		name = UnitAura("player", i, "HEALFUL|PLAYER")
		while name do
			if name == "기원의 오라"
			or name == "치료의 오라"
			or name == "지혜의 오라"
			or name == "암흑 저항의 오라"
			or name == "냉기 저항의 오라"
			or name == "화염 저항의 오라"
			or name == "성전사의 오라"
			or name == "응보의 오라"
			then
				return name
			end
			i = i + 1
			name = UnitAura("player", i, "HEALFUL|PLAYER")
		end
	end
	return "보통형태";
end

function BlinkSwap_GetData()
	if ( not BlinkWeaponSwap ) then
		return nil;
	end
	return BlinkWeaponSwap;
end


--*****************************************************************************
-- 이하 WeaponQuickSwap 모드에서 참고한 함수들
--*****************************************************************************

function BlinkSwap_ItemIsLocked(bag,slot)
	if bag == -1 and slot == -1 then return false; end

	if bag == -1 then
		return IsInventoryItemLocked(slot);
	else
		local _,_,retval = GetContainerItemInfo(bag,slot);
		return retval;
	end
end

function BlinkSwap_ExecuteSwapIteration()
	if not wswap then return; end

	if BlinkSwap_ItemIsLocked(wswap.sb, wswap.si) or
		BlinkSwap_ItemIsLocked(wswap.db, wswap.di) then
		return;
	end

	if wswap.sb == -1 then
		PickupInventoryItem(wswap.si);
	else
		PickupContainerItem(wswap.sb, wswap.si);
	end

	if wswap.db == -1 then
		if wswap.di == -1 then
			PutItemInBackpack();
		else
			PickupInventoryItem(wswap.di);
		end
	else
		PickupContainerItem(wswap.db, wswap.di);
	end

	wswap = swaplist_popfirst(wswap);
	if wswap then
		return BlinkSwap_ExecuteSwapIteration();
	end
end

function swaplist_push(list, sb, si, db, di)
	list = { next = list, sb = sb, si = si, db = db, di = di };
	return list;
end

function swaplist_popfirst(list)
	if not list then return; end

	list = list.next;
	return list;
end

function BlinkSwap_GetContainerItemName(bag,slot)
	local _,_,name = string.find(GetContainerItemLink(bag,slot) or "","%[(.+)%]");
	return name;
end

function BlinkSwap_GetItemName(bag, slot)
	local linktext,name,id,itemid;
	local i,j;

	--itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 

	if (bag == -1) then
		linktext = GetInventoryItemLink("player", slot);
	else
		linktext = GetContainerItemLink(bag, slot);
	end

	if linktext then
		_,_,id = string.find(linktext,"(item:%d+:%d+:%d+:%d+)");
		_,_,itemid = string.find(id or "","item:(%d+:%d+:%d+):%d+");
		_,_,name = string.find(linktext, "^.*%[(.*)%].*$");
		return name, itemid;
	else
		return "", "";
	end
end

function BlinkSwap_FindItem(name, skipcount)
	skipcount = skipcount or 0;

	local cname,cid;
	-- main hand
	cname,cid = BlinkSwap_GetItemName(-1,BlinkSwap_MainHandSlotID);
	if ( cname == name or cid == name ) then 
		if skipcount == 0 then return -1,BlinkSwap_MainHandSlotID; end
		skipcount = skipcount - 1;
	end
	-- off hand
	cname,cid = BlinkSwap_GetItemName(-1,BlinkSwap_OffHandSlotID);
	if ( cname == name or cid == name ) then 
		if skipcount == 0 then return -1,BlinkSwap_OffHandSlotID; end
		skipcount = skipcount - 1;
	end
	-- ranged
	cname,cid = BlinkSwap_GetItemName(-1,BlinkSwap_RangedSlotID);
	if ( cname == name or cid == name ) then 
		if skipcount == 0 then return -1,BlinkSwap_RangedSlotID; end
		skipcount = skipcount - 1;
	end
	-- ammo
	cname,cid = BlinkSwap_GetItemName(-1,BlinkSwap_AmmoSlotID);
	if ( cname == name or cid == name ) then 
		if skipcount == 0 then return -1,BlinkSwap_AmmoSlotID; end
		skipcount = skipcount - 1;
	end

	-- not found check bags
	for i=0, NUM_BAG_FRAMES do
		for j=1, GetContainerNumSlots(i) do
			cname,cid = BlinkSwap_GetItemName(i,j);
			if ( cname == name or cid == name ) then 
				if skipcount == 0 then return i,j; end
				skipcount = skipcount - 1;
			end
		end
	end
end

function BlinkSwap_FindEmptyBagSlot(skipcount, bagType)
	skipcount = skipcount or 0;
	bagType = bagType or 0;
	local skipbag = false;
	local freeSlots, bagFamily
	for i=0, NUM_BAG_FRAMES do
		freeSlots, bagFamily = GetContainerNumFreeSlots(i);
		if freeSlots > 0 then
			if bagType == bagFamily then
				for j=1, GetContainerNumSlots(i) do
					if not GetContainerItemInfo(i,j) then
						if skipcount == 0 then return i,j; end
						skipcount = skipcount - 1;
					end
				end
			elseif bagType == "AMMO" and (bagFamily == 0 or bagFamily == 1 or bagFamily == 2) then
				for j=1, GetContainerNumSlots(i) do
					if not GetContainerItemInfo(i,j) then
						if skipcount == 0 then return i,j; end
						skipcount = skipcount - 1;
					end
				end
			end
		end
	end
	-- not found return nil,nil implicitly
end

-- 무기스왑 핵심 함수
function BlinkSwapExecute(...)
	wswap = nil;

	local main, off = select(1,...),select(2,...); --arg[1], arg[2];
	local cm,cmid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
	local cs,csid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);

	--if ( cmid == main or cm == main ) and ( csid == off or cs == off ) then
	if ( cmid == main ) and ( csid == off ) then
		main, off = select(3,...),select(4,...);
	end

	if not (main and off) then
		return;
	end

	local m_sb, m_si;
	if main == "" then
		m_sb, m_si = -1, -1;
	else
		m_sb, m_si = BlinkSwap_FindItem(main);
	end
	if not (m_sb and m_si) then
		return;
	end

	local multiinst;
	-- if you're using 2 of the same weapon FindItem needs to 
	-- know not to just return the first
	if main == off then multiinst = 1; else multiinst = 0; end

	local o_sb, o_si;
	if off == "" then
		o_sb, o_si = -1, -1;
	else
		local offname, offid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);
		if ( offname == off or offid == off ) then
			o_sb, o_si = -1, BlinkSwap_OffHandSlotID;
			if( m_sb == -1 and m_si == BlinkSwap_OffHandSlotID )then
				m_sb, m_si = BlinkSwap_FindItem(main, multiinst);
			end
		else
			o_sb, o_si = BlinkSwap_FindItem(off, multiinst);
		end
	end
	if not (o_sb and o_si) then
		BlinkPrint("아이템(보조장비)을 찾을 수 없습니다 : "..off);
		return;
	end

	-- Moving both hands from bags, that's easy
	if m_sb ~= -1 and o_sb ~= -1 then
		-- Load main first because if it is a 2h and we try to load offhand
		-- we get a "Cannot Equip that with a Two-handed weapon" error
		PickupContainerItem(m_sb, m_si);
		PickupInventoryItem(BlinkSwap_MainHandSlotID);
		PickupContainerItem(o_sb, o_si);
		PickupInventoryItem(BlinkSwap_OffHandSlotID);
		return;
	end

	-- 주무기만 변경하는경우
	if m_sb ~= -1 and o_sb == -1 and o_si == BlinkSwap_OffHandSlotID then
		PickupContainerItem(m_sb, m_si);
		PickupInventoryItem(BlinkSwap_MainHandSlotID);
		return;
	end

	-- 보조장비만 변경하는경우
	if m_sb == -1 and m_si == BlinkSwap_MainHandSlotID and o_sb ~= -1 then
		PickupContainerItem(o_sb, o_si);
		PickupInventoryItem(BlinkSwap_OffHandSlotID);
		return;
	end

	-- Simple hand swap
	if m_sb == -1 and m_si == BlinkSwap_OffHandSlotID and o_sb == -1 and o_si == BlinkSwap_MainHandSlotID then
		PickupInventoryItem(BlinkSwap_MainHandSlotID);
		PickupInventoryItem(BlinkSwap_OffHandSlotID);
		return;
	end

	-- Push the list.  We want to:
	-- Take the mainhand weapon out if it isn't going to offhand
	-- Move from wherever to the offhand.  If offhand is supposed to be empty, empty it.
	-- Install the main hand weapon.  No blank main hand is supported unless are going to be.
	--
	-- Do it backward, the swaplist is a stack

	local skipcount = 0;


	-- Special Case: Moving off to main, and not main to off
	-- This is because maybe the main hand weapon is main only
	-- 주장비:주장비1,한손무기1 -> 주장비:한손무기1,보조장비:보조장비1
	if (m_sb == -1 and m_si == BlinkSwap_OffHandSlotID) and not (o_sb == -1 and o_si == BlinkSwap_MainHandSlotID) then

		-- Load offhand if not already there
		if not (o_sb == -1 and o_si == BlinkSwap_OffHandSlotID) then
			if (o_sb == -1 and o_si == -1) then
				if not (m_sb == -1 and m_si == BlinkSwap_OffHandSlotID) then
					local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
					if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
					skipcount = skipcount + 1;
					wswap = swaplist_push(wswap, -1, BlinkSwap_OffHandSlotID, bb, bi);
				end
			else
				wswap = swaplist_push(wswap, o_sb, o_si, -1, BlinkSwap_OffHandSlotID);
			end
		end

		-- Install main hand
		if not (m_sb == -1 and m_si == BlinkSwap_MainHandSlotID) then
			if (m_sb == -1 and m_si == -1) then
				if not (o_sb == -1 and o_si == BlinkSwap_MainHandSlotID) then
					local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
					if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
					skipcount = skipcount + 1;
					wswap = swaplist_push(wswap, -1, BlinkSwap_MainHandSlotID, bb, bi);
				end
			else
				wswap = swaplist_push(wswap, m_sb, m_si, -1, BlinkSwap_MainHandSlotID);
			end
		end

		-- Special Case: Moving off to main, and not main to off
		-- This is because maybe the main hand weapon is main only
		-- 주장비:주장비1,한손무기1 -> 주장비:한손무기1,보조장비:보조장비1
		if (m_sb == -1 and m_si == BlinkSwap_OffHandSlotID) and not (o_sb == -1 and o_si == BlinkSwap_MainHandSlotID) then
			local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
			if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
			skipcount = skipcount + 1;
			wswap = swaplist_push(wswap, -1, BlinkSwap_MainHandSlotID, bb, bi);
		end


	else

		-- Install main hand
		if not (m_sb == -1 and m_si == BlinkSwap_MainHandSlotID) then
			if (m_sb == -1 and m_si == -1) then
				if not (o_sb == -1 and o_si == BlinkSwap_MainHandSlotID) then
					local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
					if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
					skipcount = skipcount + 1;
					wswap = swaplist_push(wswap, -1, BlinkSwap_MainHandSlotID, bb, bi);
				end
			else
				wswap = swaplist_push(wswap, m_sb, m_si, -1, BlinkSwap_MainHandSlotID);
			end
		end

		-- Load offhand if not already there
		if not (o_sb == -1 and o_si == BlinkSwap_OffHandSlotID) then
			if (o_sb == -1 and o_si == -1) then
				if not (m_sb == -1 and m_si == BlinkSwap_OffHandSlotID) then
					local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
					if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
					skipcount = skipcount + 1;
					wswap = swaplist_push(wswap, -1, BlinkSwap_OffHandSlotID, bb, bi);
				end
			else
				wswap = swaplist_push(wswap, o_sb, o_si, -1, BlinkSwap_OffHandSlotID);
			end
		end

		-- Special Case: Moving main to off, and not off to main
		-- This is because maybe the equiped off hand item is off only
		-- 주장비:한손무기1,보조장비:방패 -> 주장비:한손무기2,보조장비:한손무기1
		if not (m_sb == -1 and m_si == BlinkSwap_OffHandSlotID) and (o_sb == -1 and o_si == BlinkSwap_MainHandSlotID) then
			local bb, bi = BlinkSwap_FindEmptyBagSlot(skipcount);
			if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
			skipcount = skipcount + 1;
			wswap = swaplist_push(wswap, -1, BlinkSwap_OffHandSlotID, bb, bi);
		end
	end

	-- Start moving
	return BlinkSwap_ExecuteSwapIteration(); 
end

function BlinkEquipRanged(...)
	if ( MerchantFrame:IsVisible() ) then
		BlinkPrint("상점이 열려있는 상태에서는 무기스왑이 작동하지 않습니다.(잘못해서 팔아버리면 안습-_-)");
		return false;
	end

	if( CursorHasItem() ) then
		BlinkPrint("BlinkSwap: 무언가를 이미 들고 있습니다.");
		return false;
	end

	local ranged, ammo = select(1,...),select(2,...);
	local cr, crid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
	local ca, caid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);
	if ( crid == ranged ) and ( caid == ammo ) then
		ranged, ammo = select(3,...),select(4,...);
	end
	if not (ranged and ammo) then
		return;
	end

	ranged = ranged or "";
	ammo = ammo or "";

	local rb, ri, ab, ai;
	if ( ranged ~= "" ) then
		if ( ranged ~= crid ) then
			rb, ri = BlinkSwap_FindItem(ranged);
			if ( rb and ri) then
				PickupContainerItem(rb, ri);
				AutoEquipCursorItem();
			end
		end
	else
		if ( crid ~= "" ) then
			local bb, bi = BlinkSwap_FindEmptyBagSlot();
			if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return false; end
			PickupInventoryItem(BlinkSwap_RangedSlotID);
			PickupContainerItem(bb, bi);
		end
	end
	if ( ammo ~= "" ) then
		if ( ammo ~= caid ) then
			ab, ai = BlinkSwap_FindItem(ammo);
			if ( ab and ai ) then
				PickupContainerItem(ab, ai);
				AutoEquipCursorItem();
			else
				BlinkPrint("탄환(화살)을 찾을 수 없어 교환하지 못했습니다.");
			end
		end
	else
		if ( caid ~= "" ) then
			local bb, bi = BlinkSwap_FindEmptyBagSlot(0, "AMMO");
			if not (bb and bi) then BlinkPrint("가방공간이 부족해서 무기스왑을 완료하지 못했습니다."); return; end
			PickupInventoryItem(BlinkSwap_AmmoSlotID);
			PickupContainerItem(bb, bi);
		end
	end
end

-- BlinkMod GUI Configuratioin ------------------------------------------------
function BS_BM_Register()
	local info;

	-- tier 1
	info = {};
	info.parentkey = "SELF";
	info.key = "BSMAIN";
	info.text = "무기스왑";
	info.hasArrow = 1;
	info.tooltipTitle = "무기스왑 애드온";
	info.notCheckable = 1;
	BlinkMod_RegisterMenu( info, 1 );

		-- tier 2 : parent = BSMAIN
		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSTITLE";
		info.text = "무기스왑";
		info.isTitle = 1;
		info.notCheckable = 1;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSSWAP";
		info.text = "무기스왑하기";
		info.tooltipTitle = "무기스왑하기";
		info.tooltipText = "설정되어있는 무기세트1과 무기세트2를 교체합니다.";
		info.ClickFunction = BlinkSwap_Swapping;
		info.GetNameFunction = BS_BM_SwapName;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSSAVECURRENTSET";
		info.text = "무기저장";
		info.tooltipTitle = "무기저장";
		info.tooltipText = "현재 장착하고있는 장비를 무기세트1 또는 무기세트2에 저장합니다.";
		info.ClickFunction = BlinkSwap_SaveCurrentWeapons;
		info.GetNameFunction = BS_BM_SaveCurrentWeaponsName;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSSWAPRANGED";
		info.text = "원거리스왑하기";
		info.tooltipTitle = "원거리무기스왑하기";
		info.tooltipText = "설정되어있는 원거리(우상,토템,성서)무기세트1과 원거리(우상,토템,성서)무기세트2를 교체합니다.";
		info.ClickFunction = BlinkSwap_Swapping_Ranged;
		info.GetNameFunction = BS_BM_SwapRangedName;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSSAVECURRENTRANGEDSET";
		info.text = "원거리무기저장";
		info.tooltipTitle = "원거리무기저장";
		info.tooltipText = "현재 장착하고있는 원거리장비(우상,토템,성서)를 원거리무기세트1 또는 원거리무기세트2에 저장합니다.";
		info.ClickFunction = BlinkSwap_SaveCurrentRangedWeapons;
		info.GetNameFunction = BS_BM_SaveCurrentRangedWeaponsName;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSFORM";
		info.text = "태새변환시 자동 무기스왑 사용";
		info.tooltipTitle = "태새변환시 자동 무기스왑 사용";
		info.tooltipText = "태새변환시 자동 무기스왑 사용/사용안함";
		info.ClickFunction = BS_BM_ToggleFormswap;
		info.GetNameFunction = BS_BM_FormswapName;
		info.ShowHideFunction = BS_BM_FormswapShow;
		info.CheckFunction = BS_BM_CheckForm;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSSAVEFORM";
		info.text = "태새별 무기저장";
		info.tooltipTitle = "태새별 무기저장";
		info.tooltipText = "태새별 자동으로 교체할 무기를 설정합니다.";
		info.ClickFunction = BlinkSwap_SaveCurrentWeapons_State;
		info.GetNameFunction = BS_BM_SaveFormswapName;
		info.ShowHideFunction = BS_BM_SaveFormswapShow;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSLIST";
		info.hasArrow = 1;
		info.text = "스왑 목록";
		info.tooltipTitle = "스왑 목록";
		info.tooltipText = "설정되어있는 스왑세트를 확인합니다.";
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

			-- tier 3 : parent = BSLIST
			info = {};
			info.parentkey = "BSLIST";
			info.key = "BSLISTSET1";
			info.text = "세트1";
			info.tooltipTitle = "세트1";
			info.tooltipText = "클릭하시면 해당무기를 장착합니다.";
			info.ClickFunction = BS_BM_SwapSet1;
			info.GetNameFunction = BS_BM_SwapSet1Name;
			info.ShowHideFunction = BS_BM_SwapSet1Show;
			info.CheckFunction = BS_BM_CheckSet1;
			BlinkMod_RegisterMenu( info, 3 );

			info = {};
			info.parentkey = "BSLIST";
			info.key = "BSLISTSET2";
			info.text = "세트2";
			info.tooltipTitle = "세트2";
			info.tooltipText = "클릭하시면 해당무기를 장착합니다.";
			info.ClickFunction = BS_BM_SwapSet2;
			info.GetNameFunction = BS_BM_SwapSet2Name;
			info.ShowHideFunction = BS_BM_SwapSet2Show;
			info.CheckFunction = BS_BM_CheckSet2;
			BlinkMod_RegisterMenu( info, 3 );

			info = {};
			info.parentkey = "BSLIST";
			info.key = "BSLISTRANGEDSET1";
			info.text = "원거리세트1";
			info.tooltipTitle = "원거리세트1";
			info.tooltipText = "클릭하시면 해당무기를 장착합니다.";
			info.ClickFunction = BS_BM_SwapRangedSet1;
			info.GetNameFunction = BS_BM_SwapRangedSet1Name;
			info.ShowHideFunction = BS_BM_SwapRangedSet1Show;
			info.CheckFunction = BS_BM_CheckRangedSet1;
			BlinkMod_RegisterMenu( info, 3 );

			info = {};
			info.parentkey = "BSLIST";
			info.key = "BSLISTRANGEDSET2";
			info.text = "원거리세트2";
			info.tooltipTitle = "원거리세트2";
			info.tooltipText = "클릭하시면 해당무기를 장착합니다.";
			info.ClickFunction = BS_BM_SwapRangedSet2;
			info.GetNameFunction = BS_BM_SwapRangedSet2Name;
			info.ShowHideFunction = BS_BM_SwapRangedSet2Show;
			info.CheckFunction = BS_BM_CheckRangedSet2;
			BlinkMod_RegisterMenu( info, 3 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSRESET";
		info.text = "무기스왑 초기화";
		info.tooltipTitle = "무기스왑 초기화";
		info.tooltipText = "무기스왑 애드온의 설정을 초기화합니다.";
		info.ClickFunction = BlinkSwapReset;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );
end

-- 스왑하기 -------------------------------------------------------------------
function BS_BM_SwapName()
	local bind = GetBindingText(GetBindingKey("BNK_SWAPWEAPON"), "KEY_");
	if ( bind ) then
		return "무기스왑하기 : "..bind;
	else
		return "무기스왑하기";
	end
end
function BS_BM_SaveCurrentWeaponsName()
	local bind = GetBindingText(GetBindingKey("BNK_SAVESWAP"), "KEY_");
	if ( bind ) then
		return "무기저장 : "..bind;
	else
		return "무기저장";
	end	
end

-- 원거리무기스왑하기 ---------------------------------------------------------
function BS_BM_SwapRangedName()
	local bind = GetBindingText(GetBindingKey("BNK_SWAPRANGEDWEAPON"), "KEY_");
	if ( bind ) then
		return "원거리스왑하기 : "..bind;
	else
		return "원거리스왑하기";
	end
end
function BS_BM_SaveCurrentRangedWeaponsName()
	local bind = GetBindingText(GetBindingKey("BNK_SAVESWAPRANGED"), "KEY_");
	if ( bind ) then
		return "원거리무기저장 : "..bind;
	else
		return "원거리무기저장";
	end	
end

-- 태세별 자동스왑사용 설정 ---------------------------------------------------
function BS_BM_ToggleFormswap()
	BlinkSwap_ToggleFormSwap();
end

function BS_BM_CheckForm()
	local sets = BlinkSwap_GetData();

	if( not sets )then return false; end
	if( sets["useForm"] == 1 )then
		return true;
	else
		return false;
	end
end

function BS_BM_FormswapName()
	if ( UnitClass("player") == "드루이드" ) then
		return "변신할때 자동 무기스왑 사용";
	elseif ( UnitClass("player") == "도적" ) then
		return "은신할때 자동 무기스왑 사용";
	elseif ( UnitClass("player") == "전사" ) then
		return "태세변환시 자동 무기스왑 사용";
	elseif ( UnitClass("player") == "사냥꾼" ) then
		return "상변환시 자동 무기스왑 사용";
	elseif ( UnitClass("player") == "성기사" ) then
		return "오라변환시 자동 무기스왑 사용";
	end
end

function BS_BM_FormswapShow()
	local c = UnitClass("player");
	if ( c == "드루이드" or c == "도적" or c == "전사" or c == "사냥꾼" or c == "성기사" ) then
		return true;
	else
		return false;
	end
end
function BS_BM_SaveFormswapName()
	local bind = GetBindingText(GetBindingKey("BNK_SAVESWAPFORM"), "KEY_");
	if ( bind ) then
		bind = " : "..bind;
	end
	if ( UnitClass("player") == "드루이드" ) then
		return "현재 변신폼의 무기세트 저장"..bind;
	elseif ( UnitClass("player") == "도적" ) then
		return "은신/비은신의 무기세트 저장"..bind;
	elseif ( UnitClass("player") == "전사" ) then
		return "현재 태세의 무기 저장"..bind;
	elseif ( UnitClass("player") == "사냥꾼" ) then
		return "현재 상의 무기세트 저장"..bind;
	elseif ( UnitClass("player") == "성기사" ) then
		return "현재 오라의 무기세트 저장"..bind;
	end
end
function BS_BM_SaveFormswapShow()
	if ( BS_BM_FormswapShow() == false ) then
		return false;
	end
	return BS_BM_CheckForm();
end

-- 무기세트1 ------------------------------------------------------------------
function BS_BM_SwapSet1()
	local sets = BlinkSwap_GetData();
	local mid, sid;
	if( not sets )then return; end
	if ( not sets["Set1"] ) then
		mid = "";
		sid = "";
	else
		if ( not sets["Set1"]["main"] ) then
			mid = "";
		else
			mid = sets["Set1"]["main"].id or "";
		end
		if ( not sets["Set1"]["off"] ) then
			sid = "";
		else
			sid = sets["Set1"]["off"].id or "";
		end
	end
	BlinkSwapExecute( mid, sid );
end

function BS_BM_SwapSet1Name()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return "세트1 : 미설정";
	else
		local m,s;
		if ( not sets["Set1"] ) then
			return "세트1 : 미설정";
		end
		if ( not sets["Set1"]["main"] ) then
			m = "";
		else
			m = sets["Set1"]["main"].name or "";
		end
		if ( not sets["Set1"]["off"] ) then
			s = "";
		else
			s = sets["Set1"]["off"].name or "";
		end
		local ms = "미설정";
		if ( m~="" and s~="" ) then
			ms = m..", "..s;
		elseif( m~="" and s=="" )then
			ms = m;
		elseif( m=="" and s~="" )then
			ms = s;
		elseif( m=="" and s=="" )then
			ms = "미설정";
		end
		return "세트1 : "..ms;
	end
end

function BS_BM_SwapSet1Show()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return false;
	else
		if ( not sets["Set1"] ) then
			return false;
		end
		local m,s;
		if ( not sets["Set1"]["main"] ) then
			m = "";
		else
			m = sets["Set1"]["main"].id or "";
		end
		if ( not sets["Set1"]["off"] ) then
			s = "";
		else
			s = sets["Set1"]["off"].id or "";
		end
		if ( m == "" and s == "" ) then
			return false;
		else
			return true;
		end
	end
end

function BS_BM_CheckSet1()
	local sets = BlinkSwap_GetData();
	if ( not sets ) then
		return false;
	else
		local m,s,mid,sid;
		if ( not sets["Set1"] ) then
			return false;
		end
		if ( not sets["Set1"]["main"] ) then
			m = "";
			mid = "";
		else
			m = sets["Set1"]["main"].name or "";
			mid = sets["Set1"]["main"].id or "";
		end
		if ( not sets["Set1"]["off"] ) then
			s = "";
			sid = "";
		else
			s = sets["Set1"]["off"].name or "";
			sid = sets["Set1"]["off"].id or "";
		end
		local cm,cmid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
		local cs,csid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);
		if ( cm == m and cmid == mid and cs == s and csid == sid ) then
			return true;
		else
			return false;
		end
	end
end

-- 무기세트2 ------------------------------------------------------------------
function BS_BM_SwapSet2()
	local sets = BlinkSwap_GetData();
	local mid, sid;
	if( not sets )then return; end
	if ( not sets["Set2"] ) then
		mid = "";
		sid = "";
	else
		if ( not sets["Set2"]["main"] ) then
			mid = "";
		else
			mid = sets["Set2"]["main"].id or "";
		end
		if ( not sets["Set2"]["off"] ) then
			sid = "";
		else
			sid = sets["Set2"]["off"].id or "";
		end
	end
	BlinkSwapExecute( mid, sid );
end

function BS_BM_SwapSet2Name()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return "세트2 : 미설정";
	else
		local m,s;
		if ( not sets["Set2"] ) then
			return "세트2 : 미설정";
		end
		if ( not sets["Set2"]["main"] ) then
			m = "";
		else
			m = sets["Set2"]["main"].name or "";
		end
		if ( not sets["Set2"]["off"] ) then
			s = "";
		else
			s = sets["Set2"]["off"].name or "";
		end
		local ms = "미설정";
		if ( m~="" and s~="" ) then
			ms = m..", "..s;
		elseif( m~="" and s=="" )then
			ms = m;
		elseif( m=="" and s~="" )then
			ms = s;
		elseif( m=="" and s=="" )then
			ms = "미설정";
		end
		return "세트2 : "..ms;
	end
end

function BS_BM_SwapSet2Show()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return false;
	else
		if ( not sets["Set2"] ) then
			return false;
		end
		local m,s;
		if ( not sets["Set1"]["main"] ) then
			m = "";
		else
			m = sets["Set1"]["main"].id or "";
		end
		if ( not sets["Set1"]["off"] ) then
			s = "";
		else
			s = sets["Set1"]["off"].id or "";
		end
		if ( m == "" and s == "" ) then
			return false;
		else
			return true;
		end
	end
end

function BS_BM_CheckSet2()
	local sets = BlinkSwap_GetData();
	if ( not sets ) then
		return false;
	else
		local m,s,mid,sid;
		if ( not sets["Set2"] ) then
			return false;
		end
		if ( not sets["Set2"]["main"] ) then
			m = "";
			mid = "";
		else
			m = sets["Set2"]["main"].name or "";
			mid = sets["Set2"]["main"].id or "";
		end
		if ( not sets["Set2"]["off"] ) then
			s = "";
			sid = "";
		else
			s = sets["Set2"]["off"].name or "";
			sid = sets["Set2"]["off"].id or "";
		end
		local cm,cmid = BlinkSwap_GetItemName(-1, BlinkSwap_MainHandSlotID);
		local cs,csid = BlinkSwap_GetItemName(-1, BlinkSwap_OffHandSlotID);
		if ( cm == m and cmid == mid and cs == s and csid == sid ) then
			return true;
		else
			return false;
		end
	end
end

-- 원거리무기세트1 ------------------------------------------------------------
function BS_BM_SwapRangedSet1()
	local sets = BlinkSwap_GetData();
	local rid, aid;
	if( not sets )then return; end
	if ( not sets["Set1"] ) then
		rid = "";
		aid = "";
	else
		if ( not sets["Set1"]["ranged"] ) then
			rid = "";
		else
			rid = sets["Set1"]["ranged"].id or "";
		end
		if ( not sets["Set1"]["ammo"] ) then
			aid = "";
		else
			aid = sets["Set1"]["ammo"].id or "";
		end
	end
	BlinkEquipRanged( rid, aid );
end

function BS_BM_SwapRangedSet1Name()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return "원거리세트1 : 미설정";
	else
		local r,a;
		if ( not sets["Set1"] ) then
			return "원거리세트1 : 미설정";
		end
		if ( not sets["Set1"]["ranged"] ) then
			r = "";
		else
			r = sets["Set1"]["ranged"].name or "";
		end
		if ( not sets["Set1"]["ammo"] ) then
			a = "";
		else
			a = sets["Set1"]["ammo"].name or "";
		end
		local ms = "미설정";
		if ( r~="" and a~="" ) then
			ms = r..", "..a;
		elseif( r~="" and a=="" )then
			ms = r;
		elseif( r=="" and a~="" )then
			ms = a;
		elseif( r=="" and a=="" )then
			ms = "미설정";
		end
		return "원거리세트1 : "..ms;
	end
end

function BS_BM_SwapRangedSet1Show()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return false;
	else
		local r,a;
		if ( not sets["Set1"] ) then
			return false;
		end
		if ( not sets["Set1"]["ranged"] ) then
			r = "";
		else
			r = sets["Set1"]["ranged"].id or "";
		end
		if ( not sets["Set1"]["ammo"] ) then
			a = "";
		else
			a = sets["Set1"]["ammo"].id or "";
		end
		if ( r == "" and a == "" ) then
			return false;
		else
			return true;
		end
	end
end

function BS_BM_CheckRangedSet1()
	local sets = BlinkSwap_GetData();
	if ( not sets ) then
		return false;
	else
		local r,a,rid,aid;
		if ( not sets["Set1"] ) then
			return false;
		end
		if ( not sets["Set1"]["ranged"] ) then
			r = "";
			rid = "";
		else
			r = sets["Set1"]["ranged"].name or "";
			rid = sets["Set1"]["ranged"].id or "";
		end
		if ( not sets["Set1"]["ammo"] ) then
			a = "";
			aid = "";
		else
			a = sets["Set1"]["ammo"].name or "";
			aid = sets["Set1"]["ammo"].id or "";
		end
		local cr,crid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
		local ca,caid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);
		if ( cr == r and crid == rid and ca == a and caid == aid ) then
			return true;
		else
			return false;
		end
	end
end

-- 원거리무기세트2 ------------------------------------------------------------
function BS_BM_SwapRangedSet2()
	local sets = BlinkSwap_GetData();
	local rid, aid;
	if( not sets )then return; end
	if ( not sets["Set2"] ) then
		rid = "";
		aid = "";
	else
		if ( not sets["Set2"]["ranged"] ) then
			rid = "";
		else
			rid = sets["Set2"]["ranged"].id or "";
		end
		if ( not sets["Set2"]["ammo"] ) then
			aid = "";
		else
			aid = sets["Set2"]["ammo"].id or "";
		end
	end
	BlinkEquipRanged( rid, aid );
end

function BS_BM_SwapRangedSet2Name()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return "원거리세트2 : 미설정";
	else
		local r,a;
		if ( not sets["Set2"] ) then
			return "원거리세트2 : 미설정";
		end
		if ( not sets["Set2"]["ranged"] ) then
			r = "";
		else
			r = sets["Set2"]["ranged"].name or "";
		end
		if ( not sets["Set2"]["ammo"] ) then
			a = "";
		else
			a = sets["Set2"]["ammo"].name or "";
		end
		local ms = "미설정";
		if ( r~="" and a~="" ) then
			ms = r..", "..a;
		elseif( r~="" and a=="" )then
			ms = r;
		elseif( r=="" and a~="" )then
			ms = a;
		elseif( r=="" and a=="" )then
			ms = "미설정";
		end
		return "원거리세트2 : "..ms;
	end
end

function BS_BM_SwapRangedSet2Show()
	local sets = BlinkSwap_GetData();
	if( not sets )then
		return false;
	else
		local r,a;
		if ( not sets["Set2"] ) then
			return false;
		end
		if ( not sets["Set2"]["ranged"] ) then
			r = "";
		else
			r = sets["Set2"]["ranged"].name or "";
		end
		if ( not sets["Set2"]["ammo"] ) then
			a = "";
		else
			a = sets["Set2"]["ammo"].name or "";
		end
		if ( r == "" and a == "" ) then
			return false;
		else
			return true;
		end
	end
end

function BS_BM_CheckRangedSet2()
	local sets = BlinkSwap_GetData();
	if ( not sets ) then
		return false;
	else
		local r,a,rid,aid;
		if ( not sets["Set2"] ) then
			return false;
		end
		if ( not sets["Set2"]["ranged"] ) then
			r = "";
			rid = "";
		else
			r = sets["Set2"]["ranged"].name or "";
			rid = sets["Set2"]["ranged"].id or "";
		end
		if ( not sets["Set2"]["ammo"] ) then
			a = "";
			aid = "";
		else
			a = sets["Set2"]["ammo"].name or "";
			aid = sets["Set2"]["ammo"].id or "";
		end
		local cr,crid = BlinkSwap_GetItemName(-1, BlinkSwap_RangedSlotID);
		local ca,caid = BlinkSwap_GetItemName(-1, BlinkSwap_AmmoSlotID);
		if ( cr == r and crid == rid and ca == a and caid == aid ) then
			return true;
		else
			return false;
		end
	end
end

--[[
function PaperDollFrameItemFlyoutButton_OnClick (self)
	if ( self.location == PDFITEMFLYOUT_IGNORESLOT_LOCATION ) then
		local slot = PaperDollFrameItemFlyout.button;
		EquipmentManagerIgnoreSlotForSave(slot:GetID());
		slot.ignored = true;
		PaperDollItemSlotButton_Update(slot);
		PaperDollFrameItemFlyout_Show(slot);
	elseif ( self.location == PDFITEMFLYOUT_UNIGNORESLOT_LOCATION ) then
		local slot = PaperDollFrameItemFlyout.button;
		EquipmentManagerUnignoreSlotForSave(slot:GetID());
		slot.ignored = nil;
		PaperDollItemSlotButton_Update(slot);
		PaperDollFrameItemFlyout_Show(slot);
	elseif ( self.location == PDFITEMFLYOUT_PLACEINBAGS_LOCATION ) then
		if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[PaperDollFrameItemFlyout.button:GetID()] ) then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			return;
		end
		local action = EquipmentManager_UnequipItemInSlot(PaperDollFrameItemFlyout.button:GetID());
		EquipmentManager_RunAction(action);
	elseif ( self.location ) then
		if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[PaperDollFrameItemFlyout.button:GetID()] ) then
			UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
			return;
		end
		local action = EquipmentManager_EquipItemByLocation(self.location, self.id);
		print(self.location.." / "..self.id)
		EquipmentManager_RunAction(action);
	end
	if ( PaperDollFrameItemFlyout.button.popoutButton.flyoutLocked ) then
		PaperDollFrameItemFlyout_Hide();
	end

	local it = {};
	GetInventoryItemsForSlot(16, it);
	for k, v in pairs(it) do
		print(k .. " => " .. v)
	end
end
]]
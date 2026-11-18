
BINDING_HEADER_BLIMKWARRIORSTANCE = "전사/죽기 태세/형상변환 단축키";
BINDING_NAME_TOGGLESTANCE1	= "전태<->방태 전환키";
BINDING_NAME_TOGGLESTANCE2	= "광태<->방태 전환키";
BINDING_NAME_TOGGLESTANCE3	= "전태<->광태 전환키";

BWS_BindButton1 = nil;
BWS_BindButton2 = nil;
BWS_BindButton3 = nil;

local needBindUpdate = false
local macro1 = "/cast [stance:1]방어 태세;전투 태세"
local macro2 = "/cast [stance:3]방어 태세;광폭 태세"
local macro3 = "/cast [stance:3]전투 태세;광폭 태세"
if select(2, UnitClass("player"))=="DEATHKNIGHT" then
	macro1 = "/cast [stance:1]냉기의 형상;혈기의 형상"
	macro2 = "/cast [stance:3]냉기의 형상;부정의 형상"
	macro3 = "/cast [stance:3]혈기의 형상;부정의 형상"
	BINDING_NAME_TOGGLESTANCE1	= "혈기<->냉기 전환키";
	BINDING_NAME_TOGGLESTANCE2	= "부정<->냉기 전환키";
	BINDING_NAME_TOGGLESTANCE3	= "혈기<->부정 전환키";
end

local function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

local function getButton(num,macrotext)
	local bind = getglobal("BWS_BindButton"..num);
	if ( bind ) then
		return bind;
	end
	bind = CreateFrame("Button", "BWS_BindButton"..num, UIParent, "SecureActionButtonTemplate");
	bind:SetAttribute("type", "macro");
	bind:SetAttribute("macrotext", macrotext);
	bind:RegisterForClicks("LeftButtonDown");
	bind:Hide();
	return bind;
end

local function getButton1()
	return getButton(1, macro1);
end

local function getButton2()
	return getButton(2, macro2);
end

local function getButton3()
	return getButton(3, macro3);
end

function BWS_UpdateBinding()
	local bindButton;
	local bindKeys = { GetBindingKey("TOGGLESTANCE1") };
	for i, keystr in ipairs(bindKeys) do
		if (keystr ~= "") then
			bindButton = getButton1();
			SetOverrideBindingClick(bindButton, true, keystr, bindButton:GetName());
		end
	end

	bindKeys = { GetBindingKey("TOGGLESTANCE2") };
	for i, keystr in ipairs(bindKeys) do
		if (keystr ~= "") then
			bindButton = getButton2();
			SetOverrideBindingClick(bindButton, true, keystr, bindButton:GetName());
		end
	end

	bindKeys = { GetBindingKey("TOGGLESTANCE3") };
	for i, keystr in ipairs(bindKeys) do
		if (keystr ~= "") then
			bindButton = getButton3();
			SetOverrideBindingClick(bindButton, true, keystr, bindButton:GetName());
		end
	end

end

-- event routine
local evFrame = CreateFrame("Frame",nil,nil);
evFrame:SetScript("OnEvent", function (self,event)
	if ((select(2,UnitClass("player"))) ~= "WARRIOR") then
		return;
	end
	if (event == "ADDON_LOADED" and arg1 == "BlinkWarriorStance") then
		getButton1();
		getButton2();
		getButton3();
	elseif ( event == "UPDATE_BINDINGS" ) then
		if not InCombatLockdown() then
			BWS_UpdateBinding()
		else
			needBindUpdate = true -- 키바인딩 예약
		end
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		if needBindUpdate then -- 키바인딩 적용
			BAT_UpdateBinding()
			needBindUpdate = false
		end
	end
end);
evFrame:RegisterEvent("UPDATE_BINDINGS");
evFrame:RegisterEvent("ADDON_LOADED");
evFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

--
--	Reagent Heaven Options
--

-- ReagentHeaven Options Frame
ReagentHeavenOptionsFrameCheckButtons = {};
ReagentHeavenOptionsFrameCheckButtons["RH_STR_USE_REAGENTHEAVEN"] = { index = 1, varname = "Enabled", tooltipText = RH_TT_USE_REAGENTHEAVEN };
ReagentHeavenOptionsFrameCheckButtons["RH_STR_SHOW_DETAIL_RECEIPE"] = { index  =2, varname = "ShowDetail", tooltipText = RH_TT_SHOW_DETAIL_RECEIPE };
ReagentHeavenOptionsFrameCheckButtons["RH_STR_SHOW_COLORED_RECEIPE"] = { index = 3, varname = "ShowColored", tooltipText = RH_TT_SHOW_COLORED_RECEIPE };
ReagentHeavenOptionsFrameCheckButtons["RH_STR_SHOW_UNLEARNED"] = { index = 4, varname = "ShowUnlearned", tooltipText = RH_TT_SHOW_COLORED_UNLEARNED };
ReagentHeavenOptionsFrameCheckButtons["RH_STR_SHOW_RECURSIVE_RECEIPE"] = { index = 5, varname = "ShowRecursive", tooltipText = RH_TT_SHOW_RECURSIVE_RECEIPE };
ReagentHeavenOptionsFrameCheckButtons["RH_STR_SHOW_PRODUCT"] = { index = 6, varname = "ShowProduct", tooltipText = RH_TT_SHOW_PRODUCT };

RH_OPT_OPTION		= 'O';
RH_OPT_MAXRANGE		= 'A';
RH_OPT_MINRANGE		= 'B';

function ReagentHeavenOptionSet( varname, value )
	if( not RH_OPTIONS ) then
		RH_OPTIONS = {};
	end
	if( not RH_OPTIONS[RH_OPT_OPTION] ) then
		RH_OPTIONS[RH_OPT_OPTION] = {};
	end
	RH_OPTIONS[RH_OPT_OPTION][varname] = value;
end

function ReagentHeavenOptionGet( varname )
	if( not RH_OPTIONS ) then
		return "1";
	end
	if( not RH_OPTIONS[RH_OPT_OPTION] ) then
		return "1";
	end
	if( not RH_OPTIONS[RH_OPT_OPTION][varname] ) then
		return "1";
	end
	return RH_OPTIONS[RH_OPT_OPTION][varname];
end

function ReagentHeaven_SetSkillRange( skillName, minValue, maxValue )
	local skillIndex = ReagentHeaven_GetSkillIndex( skillName );
	if( not skillIndex ) then
		return;
	end
	if( not RH_OPTIONS ) then
		RH_OPTIONS = {};
	end
	if( minValue ) then
		if( not RH_OPTIONS[RH_OPT_MINRANGE] ) then
			RH_OPTIONS[RH_OPT_MINRANGE] = {};
		end
		RH_OPTIONS[RH_OPT_MINRANGE][skillIndex] = minValue;
	end
	if( maxValue ) then
		if( not RH_OPTIONS[RH_OPT_MAXRANGE] ) then
			RH_OPTIONS[RH_OPT_MAXRANGE] = {};
		end
		RH_OPTIONS[RH_OPT_MAXRANGE][skillIndex] = maxValue;
	end
end

function ReagentHeaven_GetMinimumRange( skillType )
	if( not RH_OPTIONS ) then
		return 0;
	end
	if( not RH_OPTIONS[RH_OPT_MINRANGE] ) then
		return 0;
	end
	if( not RH_OPTIONS[RH_OPT_MINRANGE][skillType] ) then
		return 0;
	end
	return RH_OPTIONS[RH_OPT_MINRANGE][skillType];
end

-- !!리치킹의 분노 출시시에 스킬레벨 최고치를 450 으로 상향해줘야 함
function ReagentHeaven_GetMaximumRange( skillType )
	if( not RH_OPTIONS ) then
		return 375;
	end
	if( not RH_OPTIONS[RH_OPT_MAXRANGE] ) then
		return 375;
	end
	if( not RH_OPTIONS[RH_OPT_MAXRANGE][skillType] ) then
		return 375;
	end
	return RH_OPTIONS[RH_OPT_MAXRANGE][skillType];
end

function ReagentHeaven_IsVisibleRange( skillType, skillValue )
	if( skillValue == nil ) then
		return true;
	end
	if( ReagentHeaven_GetMaximumRange( skillType ) < skillValue ) then
		return false;
	end
	if( ReagentHeaven_GetMinimumRange( skillType ) > skillValue ) then
		return false;
	end
	return true;
end

function ReagentHeavenOptionsFrame_DisableCheckBox( checkBox )
	checkBox:Disable();
	getglobal( checkBox:GetName().."Text"):SetTextColor( GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b );
end

function ReagentHeavenOptionsFrame_EnableCheckBox( checkBox, checked, isWhite )
	checkBox:SetChecked( checked );
	checkBox:Enable();
	if( isWhite ) then
		getglobal(checkBox:GetName().."Text"):SetTextColor( HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b );
	else
		getglobal(checkBox:GetName().."Text"):SetTextColor( NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );
	end
end

function ReagentHeavenOptionsFrame_Load()
	local index, value, button, string, checked;

	for index, value in pairs( ReagentHeavenOptionsFrameCheckButtons ) do
		local button = getglobal("ReagentHeavenOptionsFrameCheckButton"..value.index);
		local string = getglobal("ReagentHeavenOptionsFrameCheckButton"..value.index.."Text");
		local checked = ReagentHeavenOptionGet( value.varname );

		button.disabled = nil;
		if( value.func ) then
			checked = value.func();
		elseif( value.varname == "Enabled" ) then
		elseif( value.varname == "ShowDetail" ) then
			if( ReagentHeavenOptionGet( "Enabled" ) == "0" ) then
				button.disabled = 1;
			end
		else
			if( ReagentHeavenOptionGet( "Enabled" ) == "0" or ReagentHeavenOptionGet( "ShowDetail" ) == "0" ) then
				button.disabled = 1;
			end
		end

		if( button.disabled ) then
			ReagentHeavenOptionsFrame_DisableCheckBox( button );
		else
			ReagentHeavenOptionsFrame_EnableCheckBox( button, checked );
		end
		button:SetChecked(checked);
		string:SetText(TEXT(getglobal(index)));
		button.tooltipText = value.tooltipText;
	end
end

function ReagentHeavenOptionsFrame_Save()
	local index, value;

	for index, value in pairs( ReagentHeavenOptionsFrameCheckButtons ) do
		local button = getglobal( "ReagentHeavenOptionsFrameCheckButton"..value.index );
		if( button:GetChecked() ) then
			ReagentHeavenOptionSet( value.varname, "1" );
		else
			ReagentHeavenOptionSet( value.varname, "0" );
		end
	end
end

function ReagentHeavenOptionsFrame_UpdateEnable( buttonEnabled )
	local index, value;

	for index, value in pairs( ReagentHeavenOptionsFrameCheckButtons ) do
		local button = getglobal( "ReagentHeavenOptionsFrameCheckButton"..value.index );
		if( value.varname ~= "Enabled" ) then
			if( buttonEnabled ) then
				ReagentHeavenOptionsFrame_EnableCheckBox( button );
				button:SetChecked( ReagentHeavenOptionGet( value.varname ) );
			else
				ReagentHeavenOptionsFrame_DisableCheckBox( button );
			end
		end
	end
end

function ReagentHeavenOptionsFrame_UpdateShowDetail( buttonEnabled )
	local index, value;

	for index, value in pairs( ReagentHeavenOptionsFrameCheckButtons ) do
		local button = getglobal( "ReagentHeavenOptionsFrameCheckButton"..value.index );
		if( (value.varname ~= "Enabled") and (value.varname ~= "ShowDetail") ) then
			if( buttonEnabled ) then
				ReagentHeavenOptionsFrame_EnableCheckBox( button );
				button:SetChecked( ReagentHeavenOptionGet( value.varname ) );
			else
				ReagentHeavenOptionsFrame_DisableCheckBox( button );
			end
		end
	end
end

function ReagentHeavenIsEnabled()
	if( ReagentHeavenOptionGet( "Enabled" ) == "0" ) then
		return false;
	end
	return true;
end

function ReagentHeavenIsShowDetail()
--	if( ReagentHeavenOptionGet( "Enabled" ) == "0" ) then
--		return false;
--	end
	if( ReagentHeavenOptionGet( "ShowDetail" ) == "0" ) then
		return false;
	end
	return true;
end

function ReagentHeavenIsShowColored()
	if( ReagentHeavenIsShowDetail() == false ) then
		return false;
	end
	if( ReagentHeavenOptionGet( "ShowColored" ) == "0" ) then
		return false;
	end
	return true;
end

function ReagentHeavenIsShowRecursive()
	if( ReagentHeavenIsShowDetail() == false ) then
		return false;
	end
	if( ReagentHeavenOptionGet( "ShowRecursive" ) == "0" ) then
		return false;
	end
	return true;
end

function ReagentHeavenIsShowProduct()
	if( ReagentHeavenIsShowDetail() == false ) then
		return false;
	end
	if( ReagentHeavenOptionGet( "ShowProduct" ) == "0" ) then
		return false;
	end
	return true;
end

function ReagentHeavenIsShowUnlearned()
	if( ReagentHeavenIsShowDetail() == false ) then
		return false;
	end
	if( ReagentHeavenOptionGet( "ShowUnlearned" ) == "0" ) then
		return false;
	end
	return true;
end

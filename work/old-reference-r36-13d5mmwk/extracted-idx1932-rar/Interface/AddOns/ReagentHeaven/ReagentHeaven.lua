--
--	Reagent Heaven v0.99c
--	by Standil (cpascal@cpascal.net)
--	* Character: [KOR] Prestol server Mony
--
--	Crafts codes are from ReagentsTips by Dylan Wolf (dylan@dylanwolf.com).
--

RH_VERSION = "0.99";
RH_REVISION = "d";

-- Global variables
local RH_HOOKED = false;
local RH_DisplayIndices;

local RH_TOOLTIP_CACHE;
local RH_TOOLTIP_CACHE_NAME;

-- Function hooking
local RH_ORG_SetItemRef;
local RH_ORG_PickupContainerItem;
local RH_ORG_PickupInventoryItem;
--local RH_ORG_ContainerFrameItemButton_OnClick;
--local RH_ORG_PaperDollItemSlotButton_OnClick;

-- Function hooking for Custom Interface 'AllInOneInventory'
--local RH_ORG_AllInOneInventoryFrameItemButton_OnEnter;

-- Function hooking for Custom Interface 'MyInventory'
local RH_ORG_MyInventoryFrame_Update = nil;

local RH_HOOKS = {};

RH_ITEM_HEIGHT	= 16;
RH_ITEMS_SHOWN	= 19;
RH_MAX_INDENT	= 6;
RH_MAX_HISTORY	= 10;

if not RH_ENABLED then
	RH_ENABLED = true;
end

if not RH_MAX_LINENUM then
	RH_MAX_LINENUM = 25;
end

local RH_HISTORY = {};
local RH_CURRENT_HISTORY = 0;

local RH_TypeColor			= { };
RH_TypeColor["product"]		= { r = 0.30, g = 0.63, b = 1.00 };
RH_TypeColor["violet"]		= { r = 0.63, g = 0.20, b = 0.92 };
RH_TypeColor["impossible"]	= { r = 1.00, g = 0.12, b = 0.12 };
RH_TypeColor["normal"]		= { r = 1.00, g = 1.00, b = 1.00 };
RH_TypeColor["optimal"]		= { r = 1.00, g = 0.50, b = 0.25 };
RH_TypeColor["medium"]		= { r = 1.00, g = 1.00, b = 0.00 };
RH_TypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25 };
RH_TypeColor["trivial"]		= { r = 0.50, g = 0.50, b = 0.50 };
RH_TypeColor["header"]		= { r = 1.00, g = 0.82, b = 0.00 };
RH_TypeColor["none"]		= { r = 0.25, g = 0.75, b = 0.25 };

RH_INT_SKILLS		= 's';
RH_INT_GATHER		= 'g';
RH_INT_EXTRA		= 'e';
RH_INT_NUMBER		= 'n';
RH_INT_LEVEL		= 'l';
RH_INT_COLOR		= 'c1';
RH_INT_COLOR2		= 'c2';
RH_INT_MSG		= 'm1';
RH_INT_MSG2		= 'm2';

function ReagentHeaven_IsIntCommand( cmd )
	if( (cmd == RH_INT_SKILLS) or
		(cmd == RH_INT_SKILLS) or
		(cmd == RH_INT_GATHER) or
		(cmd == RH_INT_EXTRA) or
		(cmd == RH_INT_NUMBER) or
		(cmd == RH_INT_LEVEL) or
		(cmd == RH_INT_COLOR) or
		(cmd == RH_INT_COLOR2) or
		(cmd == RH_INT_MSG) or
		(cmd == RH_INT_MSG2) ) then
		return true;
	else
		return false;
	end
end

function ReagentHeaven_HookGameTooltip( method_name )
	if( not RH_HOOKS[method_name] ) then
		RH_HOOKS[method_name] = GameTooltip[ method_name ];
		GameTooltip[ method_name ] = function(...)
			return ReagentHeaven_HandleHook( method_name, ... );
		end;
	end
end

function ReagentHeaven_SetTableCount( newtable )
	local maxcount = 0;

	for k, v in pairs( newtable ) do
		if( k > maxcount ) then
			maxcount = k;
		end
	end
	newtable.n = maxcount;
end

function ReagentHeaven_HandleHook( method_name, ... )
	if( RH_HOOKS[method_name] ) then
		local returnvalue;

		returnvalue = { RH_HOOKS[method_name]( ... ) };
		ReagentHeaven_SetTableCount( returnvalue );
		ReagentHeaven_AddGameTooltip();
		return unpack( returnvalue );
	end
end

function ReagentHeaven_Info( msg, bPrint )
	if( bPrint and DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( msg, 1.0, 0.5, 0.3 );
	end
end

function ReagentHeaven_Chat( msg )
	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( msg, 0.0, 1.0, 0.0 );
	end
end

-- OnShow Event function
function ReagentHeaven_OnShow()
-- "부분명칭 검색" 기본체크.. 검색창에 자동 포커스 기능 추가
	ReagentHeavenFrameSubtitleCheck:SetChecked();
	ReagentHeavenItemName:SetFocus();
end

-- OnHide Event function
function ReagentHeaven_OnHide()
end

-- OnLoad Event function
function ReagentHeaven_OnLoad()
	-- Events
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	-- Slash Commands
	SlashCmdList['REAGENTHEAVEN'] = ReagentHeaven_HandleSlashCmd;
	SLASH_REAGENTHEAVEN1 = '/reagentheaven';
	SLASH_REAGENTHEAVEN2 = '/rh';
	SLASH_REAGENTHEAVEN3 = REAGENTHEAVEN_LOCALIZED_COMMAND1;
	SLASH_REAGENTHEAVEN4 = REAGENTHEAVEN_LOCALIZED_COMMAND2;

	-- Hook all of GameTooltip's "Show...Item" methods
	-- Code adapted from ReagentTips by Dylan Wolf (dylan@dylanwolf.com)
	local func_id, func_name;

	for func_id, func_name in pairs( {
					'SetLootItem',
					'SetAuctionItem',
					'SetAuctionSellItem',
					'SetBagItem',
					'SetBuybackItem',
					'SetCraftItem',
					'SetCraftSpell',
					'SetHyperlink',
					'SetInventoryItem',
					'SetInboxItem',
					'SetMerchantItem',
					'SetQuestItem',
					'SetQuestLogItem',
					'SetSendMailItem',
					'SetTradeSkillItem',
					'SetTradeTargetItem',
					'SetTradePlayerItem',
					'SetTrainerService',
					'SetGuildBankItem',
--					'SetTradeTargetItem',
				} ) do
		ReagentHeaven_HookGameTooltip( func_name );
	end

	-- Function hooking
	RH_ORG_SetItemRef = SetItemRef;
	SetItemRef = ReagentHeaven_SetItemRef;

	UIPanelWindows["ReagentHeavenOptionsFrame"]	= { area = "center",	pushable = 1 };
	UIPanelWindows["ReagentHeavenFrame"]		= { area = "left",	pushable = 5 };

        -- Splash Messages
	ReagentHeaven_Chat( "Standil(Mony)'s ReagentHeaven(v"..RH_VERSION..RH_REVISION..") AddOn loaded." );
	if( RH_DATA_VERSION ) then
		ReagentHeaven_Chat( RH_DATA_VERSION );
		UIErrorsFrame:AddMessage( RH_DATA_VERSION, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME );
	end
	UIErrorsFrame:AddMessage( "Standil(Mony)'s ReagentHeaven(v"..RH_VERSION..RH_REVISION..") AddOn loaded", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME );
end

function ReagentHeaven_OnEvent( event )
	if( event == "VARIABLES_LOADED" ) then
		if( not RH_CUDATA ) then
			RH_CUDATA = {};
		end
		if( not RH_MISSED_PRODUCTS ) then
			RH_MISSED_PRODUCTS = {};
		end
		if( not RH_MISSED_REAGENTS ) then
			RH_MISSED_REAGENTS = {};
		end
		ReagentHeaven_MergeMissed();
	elseif( event == "PLAYER_ENTERING_WORLD" ) then
		ReagentHeaven_OtherAddonHook();
	end
end

--function ReagentHeaven_ContainerFrameItemButton_OnEnter()
--	RH_ORG_ContainerFrameItemButton_OnEnter();
--	ReagentHeaven_AddGameTooltip();
--end

function ReagentHeaven_SetItemRef( link, text, button )
	RH_ORG_SetItemRef( link, text, button );
	if( strsub( link, 1, 6 ) ~= "player" ) then
--		ItemRefTooltipMoneyFrame:SetPoint("LEFT", "ItemRefTooltipTextLeft1", "LEFT", 0, 0);
--		ItemRefTooltipMoneyFrame:Hide();

		if( ItemRefTooltip:IsVisible() ) then
			local field = getglobal("ItemRefTooltipTextLeft1");
			if( field and field:IsVisible() ) then
				ReagentHeaven_ModifyTooltip( ItemRefTooltip );
			end
		end
	end
end

function ReagentHeaven_AddGameTooltip()
	ReagentHeaven_ModifyTooltip( GameTooltip );
end

function ReagentHeaven_AddLine( linetable, line, color )
	local record = { [RH_INT_MSG] = line, [RH_INT_COLOR] = color };
	if linetable then
		table.insert( linetable, record );
	end
end

function ReagentHeaven_AddDoubleLine( linetable, line, line2, color, color2 )
	local record = { [RH_INT_MSG] = line, [RH_INT_MSG2] = line2, [RH_INT_COLOR] = color, [RH_INT_COLOR2] = color2 };
	if linetable then
		table.insert( linetable, record );
	end
end

function ReagentHeaven_BuildDisplayIndices( displayIndices, lineTable )
	local k, v;
	local i = displayIndices.onePastEnd;
	for k, v in pairs( lineTable ) do
		i = i + 1;
		displayIndices[i] = v;
	end
	displayIndices.onePastEnd = i;
end

function ReagentHeaven_PrintLines( frame, lineTable )
	local k, v;

	for k, v in pairs( lineTable ) do
		if( frame:NumLines() >= RH_MAX_LINENUM ) then
			return;
		end
		if( v[RH_INT_MSG2] ~= nil ) then
			frame:AddDoubleLine( v[RH_INT_MSG], v[RH_INT_MSG2],
				v[RH_INT_COLOR].r, v[RH_INT_COLOR].g, v[RH_INT_COLOR].b,
				v[RH_INT_COLOR2].r, v[RH_INT_COLOR2].g, v[RH_INT_COLOR2].b );
		else
			frame:AddLine( v[RH_INT_MSG], v[RH_INT_COLOR].r, v[RH_INT_COLOR].g, v[RH_INT_COLOR].b );
		end
	end
end

function ReagentHeaven_ItemList( allLines, itemName, bForce )
	local k1, v1, k2, v2, itemCount;
	local l_lineName, l_colorName;
	local l_AddedItemList = {};

	itemCount = 0;
	for k1, v1 in pairs( RH_PRODUCTS ) do
		if( string.find( k1, itemName ) ) then
			for k2, v2 in pairs( RH_PRODUCTS[k1] ) do
				itemCount = itemCount + 1;
				if( (bForce or ReagentHeavenIsShowColored()) and RH_CUDATA and RH_CUDATA[k2] ) then
					if( RH_CUDATA[k2][k1] ) then
						l_lineName = RH_CUDATA[k2][k1];
						l_colorName = RH_CUDATA[k2][k1];
					else
						l_lineName = "impossible";
						l_colorName = "impossible";
					end
				else
					l_lineName = "normal";
					l_colorName = "normal";
				end
				ReagentHeaven_AddLine( allLines[ l_lineName ], ReagentHeaven_GetSkillName(k2)..': '..k1..ReagentHeaven_GetCraftLevelString(k1, k2), RH_TypeColor[ l_colorName ] );
				l_AddedItemList[ k1 ] = true;
			end
		end
	end
	l_lineName = "normal";
	l_colorName = "normal";
	for k1, v1 in pairs( RH_REAGENTS ) do
		if( string.find( k1, itemName ) ) then
			if( not l_AddedItemList[ k1 ] ) then
				itemCount = itemCount + 1;
				ReagentHeaven_AddLine( allLines[ l_lineName ], "재료: "..k1, RH_TypeColor[ l_colorName ] );
				l_AddedItemList[ k1 ] = true;
			end
		end
	end
	ReagentHeaven_AddLine( allLines[ "header" ], "총 "..itemCount.."건이 발견되었습니다.", RH_TypeColor[ "header" ] );
end

function ReagentHeaven_ItemInfo( allLines, itemName, bForce )
	local l_CurrentLine;
	local l_ExtraLine;
	local l_ExtraLine2;
	local k1, v1, k2, v2;
	local l_bAdded = false;

	-- Product
	if( RH_PRODUCTS[itemName] and (bForce or ReagentHeavenIsShowProduct()) ) then
		l_bAdded = true;
		for k1, v1 in pairs( RH_PRODUCTS[itemName] ) do
			ReagentHeaven_AddLine( allLines["header"], "[완성품] "..ReagentHeaven_GetSkillName( k1 )..ReagentHeaven_GetCraftLevelString( itemName, k1 ), RH_TypeColor["product"] );
			for k2, v2 in pairs( RH_PRODUCTS[itemName][k1] ) do
				if( ReagentHeaven_IsIntCommand( k2 ) == false ) then
					if( v2[RH_INT_NUMBER] ~= nil ) then
						l_ExtraLine = v2[RH_INT_NUMBER];
					else
						l_ExtraLine = 1;
					end
					ReagentHeaven_AddDoubleLine( allLines["header"], "  + "..v2.r, l_ExtraLine, RH_TypeColor["product"], RH_TypeColor["normal"] );
				end
			end
		end
	end

	-- Reagents (Short)
	l_CurrentLine = nil;
	l_ExtraLine = nil;
	l_ExtraLine2 = nil;

	if( RH_REAGENTS[itemName] ) then
		l_bAdded = true;
		l_CurrentLine = ReagentHeaven_GetSkillNamesFromItem( RH_REAGENTS[itemName] );
		if( l_CurrentLine ~= nil ) then
			ReagentHeaven_AddLine( allLines["header"], "사용기술: "..l_CurrentLine, RH_TypeColor["header"] );
		end

		if( RH_REAGENTS[itemName][RH_INT_GATHER] ~= nil ) then
			l_ExtraLine = RH_REAGENTS[itemName][RH_INT_GATHER];
			ReagentHeaven_AddLine( allLines["header"], "수집방법: "..l_ExtraLine, RH_TypeColor["header"] );
		end
		if( RH_REAGENTS[itemName][RH_INT_EXTRA] ~= nil ) then
			l_ExtraLine2 = RH_REAGENTS[itemName][RH_INT_EXTRA];
			ReagentHeaven_AddLine( allLines["header"], l_ExtraLine2, RH_TypeColor["header"] );
		end
	end

	-- Reagents
	if( bForce or (ReagentHeavenIsShowDetail() == true) ) then
		ReagentHeaven_AddRecipeLine( allLines, '', itemName, 0, 1, nil, bForce )
	end
	return l_bAdded;
end

function ReagentHeaven_ModifyTooltip( frame )
	if( ReagentHeavenIsEnabled() == false ) then
		return;
	end
	if( not frame ) then
		return;
	end
	if( frame:IsVisible() == false ) then
		return;
	end
	local frame_name = frame:GetName();
	local frame_info = getglobal( frame_name.."TextLeft1" ):GetText()
	if( not frame_info ) then
		return;
	end

	if( frame_info ~= RH_TOOLTIP_CACHE_NAME ) then
		RH_TOOLTIP_CACHE_NAME = frame_info;
		RH_TOOLTIP_CACHE = {};
		RH_TOOLTIP_CACHE["header"] = {};			-- 금색
		RH_TOOLTIP_CACHE["impossible"] = {};			-- 빨간색
		RH_TOOLTIP_CACHE["optimal"] = {};			-- 주황색
		RH_TOOLTIP_CACHE["medium"] = {};			-- 노란색
		RH_TOOLTIP_CACHE["easy"] = {};				-- 녹색
		RH_TOOLTIP_CACHE["trivial"] = {};			-- 회색
		RH_TOOLTIP_CACHE["normal"] = {};			-- 일반
		ReagentHeaven_ItemInfo( RH_TOOLTIP_CACHE, frame_info, false );
	end
	-- Draw all
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["header"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["impossible"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["optimal"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["medium"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["easy"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["trivial"] );
	ReagentHeaven_PrintLines( frame, RH_TOOLTIP_CACHE["normal"] );
	if( frame:NumLines() >= RH_MAX_LINENUM ) then
--		frame:AddLine( "...", 1.0, 1.0, 1.0 );
	end

	frame:Show();
end

local function ReagentHeaven_GetSubtitleCount( itemName )
	local k, v, itemCount, foundItemName;

	itemCount = 0;
	-- Product
	for k, v in pairs( RH_PRODUCTS ) do
		if( string.find( k, itemName ) ) then
			itemCount = itemCount + 1;
			foundItemName = k;
		end
	end
	-- Reagents
	for k, v in pairs( RH_REAGENTS ) do
		if( string.find( k, itemName ) ) then
			itemCount = itemCount + 1;
			foundItemName = k;
		end
	end
	return itemCount, foundItemName;
end

function ReagentHeaven_InsertHistory( itemName, bSubtitle )
	local historyRecord = { name=itemName, subtitle=bSubtitle };

	if( RH_CURRENT_HISTORY > 1 ) then
		if( (RH_HISTORY[ RH_CURRENT_HISTORY - 1 ].name == itemName) and (RH_HISTORY[ RH_CURRENT_HISTORY - 1 ].subtitle == bSubtitle) ) then
			return;
		end
	end
	RH_CURRENT_HISTORY = RH_CURRENT_HISTORY + 1;
	RH_HISTORY[ RH_CURRENT_HISTORY ] = historyRecord;
	if( #RH_HISTORY > RH_MAX_HISTORY ) then
		table.remove( RH_HISTORY, 1 );
		RH_CURRENT_HISTORY = #RH_HISTORY;
	end
end

function ReagentHeaven_UpdateReagentHeavenFrame( itemName, bSubtitle, bNoHistory )
	local l_Lines = {};
	l_Lines["header"] = {};				-- 금색
	l_Lines["impossible"] = {};			-- 빨간색
	l_Lines["optimal"] = {};			-- 주황색
	l_Lines["medium"] = {};				-- 노란색
	l_Lines["easy"] = {};				-- 녹색
	l_Lines["trivial"] = {};			-- 회색
	l_Lines["normal"] = {};				-- 일반

	if( bSubtitle ) then
		local lCount, lName = ReagentHeaven_GetSubtitleCount( itemName );
		if( lCount <= 0 ) then
			ReagentHeaven_AddLine( l_Lines["header"], RH_MSG_NODATA, RH_TypeColor["header"] );
		else
			ReagentHeaven_ItemList( l_Lines, itemName, true );
			if( not bNoHistory ) then
				ReagentHeaven_InsertHistory( itemName, true );
			end
		end
	elseif( ReagentHeaven_ItemInfo( l_Lines, itemName, true ) ) then
		if( not bNoHistory ) then
			ReagentHeaven_InsertHistory( itemName, false );
		end
	else
		ReagentHeaven_AddLine( l_Lines["header"], RH_MSG_NODATA, RH_TypeColor["header"] );
	end
	-- Draw all
	RH_DisplayIndices = {};
	RH_DisplayIndices.onePastEnd = 0;
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["header"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["impossible"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["optimal"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["medium"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["easy"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["trivial"] );
	ReagentHeaven_BuildDisplayIndices( RH_DisplayIndices, l_Lines["normal"] );
end

function ReagentHeaven_Refresh()
	ReagentHeavenFrame_CanSend();
	if( not RH_DisplayIndices ) then
		RH_DisplayIndices = {};
		RH_DisplayIndices.onePastEnd = 0;
		return;
	end
	local iItem;
	local color;

	FauxScrollFrame_Update( ReagentHeavenListScrollFrame, RH_DisplayIndices.onePastEnd - 1, RH_ITEMS_SHOWN, RH_ITEM_HEIGHT);
	for iItem = 1, RH_ITEMS_SHOWN, 1 do
		local itemIndex = iItem + FauxScrollFrame_GetOffset( ReagentHeavenListScrollFrame );
		local cItem = getglobal( "ReagentHeavenItem"..iItem );
		local cItemtext = getglobal( "ReagentHeavenItem"..iItem.."Text" );
		local cItemRight = getglobal( "ReagentHeavenItemRight"..iItem );
		local cItemRighttext = getglobal( "ReagentHeavenItemRight"..iItem.."Text" );
		if( itemIndex <= RH_DisplayIndices.onePastEnd ) then
			local Indices = RH_DisplayIndices[itemIndex];


			cItem:SetText( Indices[RH_INT_MSG] );
--			cItem:SetTextColor( Indices[RH_INT_COLOR].r, Indices[RH_INT_COLOR].g, Indices[RH_INT_COLOR].b );
			cItemtext:SetTextColor( Indices[RH_INT_COLOR].r, Indices[RH_INT_COLOR].g, Indices[RH_INT_COLOR].b );

			cItem:Show();
			if( Indices[RH_INT_MSG2] ~= nil ) then
				cItemRight:SetText( Indices[RH_INT_MSG2] );
--				cItemRight:SetTextColor( Indices[RH_INT_COLOR2].r, Indices[RH_INT_COLOR2].g, Indices[RH_INT_COLOR2].b );
				cItemRighttext:SetTextColor( Indices[RH_INT_COLOR2].r, Indices[RH_INT_COLOR2].g, Indices[RH_INT_COLOR2].b );
				cItemRight:Show();
			else
				cItemRight:Hide();
			end
		else
			cItem:Hide();
			cItemRight:Hide();
		end
	end
end

function ReagentHeaven_AddRecipeLine( allLines, selectedLines, productName, indentLevel, multiplyCount, printedProductList, bForce )
	if( RH_REAGENTS[productName] == nil ) then
		return;
	end

	local l_lineName;
	local l_colorName;
	local l_neededCount;
	local k1, v1, k2, v2;
	local bLearned;

	if( indentLevel >= RH_MAX_INDENT ) then
		return;
	end
	if( not printedProductList ) then
		printedProductList = {};
	end
	printedProductList[ productName ] = true;
	for k1, v1 in pairs( RH_REAGENTS[productName] ) do
		if( ReagentHeaven_IsIntCommand( k1 ) == false ) then
			if( (bForce or (RH_CUDATA and RH_CUDATA[k1])) or ReagentHeavenIsShowUnlearned() )  then
				for k2, v2 in pairs( RH_REAGENTS[productName][k1] ) do
					local reagent_record = v2;

					if( RH_PRODUCTS[v2.p][k1] and (bForce or ReagentHeaven_IsVisibleRange( k1, RH_PRODUCTS[v2.p][k1][RH_INT_LEVEL] )) ) then
						local product_record = RH_PRODUCTS[v2.p][k1];

						if( (bForce or ReagentHeavenIsShowColored()) and RH_CUDATA and RH_CUDATA[k1] ) then
							if( RH_CUDATA[k1][v2.p] ) then
								l_lineName = RH_CUDATA[k1][v2.p];
								l_colorName = RH_CUDATA[k1][v2.p];
							else
								l_lineName = "impossible";
								l_colorName = "impossible";
							end
						else
							l_lineName = "normal";
							l_colorName = "normal";
						end
						if( selectedLines ~= '' ) then
							l_lineName = selectedLines;
						end
						if( v2.n ~= nil ) then
							l_neededCount = v2.n * multiplyCount;
						else
							l_neededCount = 1 * multiplyCount;
						end
						ReagentHeaven_AddDoubleLine( allLines[ l_lineName ], ReagentHeaven_GetIndentLevelString( indentLevel )..ReagentHeaven_GetSkillName(k1)..': '..v2.p..ReagentHeaven_GetCraftLevelString(v2.p, k1), l_neededCount, RH_TypeColor[ l_colorName ], RH_TypeColor[ "normal" ] );
						if( bForce or ReagentHeavenIsShowRecursive() ) then
							if( not printedProductList[ v2.p ] ) then
								ReagentHeaven_AddRecipeLine( allLines, l_lineName, v2.p, indentLevel+1, l_neededCount, printedProductList, bForce );
							else
								ReagentHeaven_AddLine( allLines[ l_lineName ], ReagentHeaven_GetIndentLevelString( indentLevel+1 ).."...", RH_TypeColor[ "normal" ] );
							end
						end
					end
				end
			end
		end
	end
end

function ReagentHeaven_GetIndentLevelString( indentLevel )
	if( indentLevel == 0 ) then
		return '';
	end
	return string.rep('  ', indentLevel)..'+ ';
end

function ReagentHeaven_GetCraftLevelString( productName, skillIndex )
	if( RH_PRODUCTS[productName] and RH_PRODUCTS[productName][skillIndex] and RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL] ) then
		return '('..RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL]..')';
	end
	return '';
end

function ReagentHeaven_ResetMissedData()
	RH_CUDATA = {};
end

function ReagentHeaven_CreateReagentData()
	local processed_tradeskills = {};
	local k, v;

	for spelltab_id = 1, GetNumSpellTabs() do
		local spelltab_name, spelltab_texture, spelltab_offset, spelltab_numSpells = GetSpellTabInfo( spelltab_id );
		if( spelltab_name == GENERAL ) then
			for spell_id = 1, spelltab_numSpells do
				local spellName, subSpellName = GetSpellName( spelltab_offset+spell_id, BOOKTYPE_SPELL );
				local skillCount;

				if( ReagentHeaven_IsInTable( RH_TRADESKILLS, spellName) ) then
					ReagentHeaven_OpenTradeSkillFrame( spelltab_offset+spell_id, spellName, subSpellName );
					ReagentHeaven_ListTradeSkill( spellName );
					if( TradeSkillFrame_Hide ) then
						TradeSkillFrame_Hide();
					end
				end
--				if( ReagentHeaven_IsInTable( RH_CRAFTS, spellName ) ) then
--					ReagentHeaven_OpenCraftFrame( spelltab_offset+spell_id, spellName, subSpellName );
--					ReagentHeaven_ListCraft( spellName );
--					if( CraftFrame_Hide ) then
--						CraftFrame_Hide();
--					end
--				end
			end
		elseif( ReagentHeaven_IsInTable( RH_CLASSSKILLS, spelltab_name ) ) then
			for spell_id = 1, spelltab_numSpells do
				local spellName, subSpellName = GetSpellName( spelltab_offset+spell_id, BOOKTYPE_SPELL );
				ReagentHeaven_ProcessClassSkill( spelltab_offset+spell_id, spellName, subSpellName );
			end
		end
	end
end

function ReagentHeaven_AddMissedProductValue( productName, skillIndex, index, value )
	if( RH_MISSED_PRODUCTS[productName] == nil ) then
		RH_MISSED_PRODUCTS[productName] = {};
	end
	if( RH_MISSED_PRODUCTS[productName][skillIndex] == nil ) then
		RH_MISSED_PRODUCTS[productName][skillIndex] = {};
	end
	RH_MISSED_PRODUCTS[productName][skillIndex][index] = value;
end

function ReagentHeaven_AddMissedProductReagentValue( productName, skillIndex, productRecord )
	if( RH_MISSED_PRODUCTS[productName] == nil ) then
		RH_MISSED_PRODUCTS[productName] = {};
	end
	if( RH_MISSED_PRODUCTS[productName][skillIndex] == nil ) then
		RH_MISSED_PRODUCTS[productName][skillIndex] = {};
	end
	local index = ReagentHeaven_IsExistReagentNameInProductTable( RH_MISSED_PRODUCTS[productName][skillIndex], productRecord.r );
	if( index ) then
		RH_MISSED_PRODUCTS[productName][skillIndex][index] = productRecord;
	else
		table.insert( RH_MISSED_PRODUCTS[productName][skillIndex], productRecord );
	end
end

function ReagentHeaven_ProcessProduct( spellName, productName, requiredLevel, bMakeMiss )
	local bAdded = false;
	local skillIndex = ReagentHeaven_GetSkillIndex( spellName );

	if( skillIndex == nil ) then
		return;
	end
	if( RH_PRODUCTS[productName] == nil ) then
		RH_PRODUCTS[productName] = {};
		bAdded = true;
	end
	if( RH_PRODUCTS[productName][skillIndex] == nil ) then
		RH_PRODUCTS[productName][skillIndex] = {};
		bAdded = true;
	end

	if( bAdded ) then
		ReagentHeaven_Info( "재료천국: [제품추가] "..spellName..": "..productName, bMakeMiss );
	end
	if( requiredLevel ) then
		if( RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL] == nil ) then
			RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL] = requiredLevel;
			if( bMakeMiss ) then
				ReagentHeaven_AddMissedProductValue( productName, skillIndex, RH_INT_LEVEL, requiredLevel );
				if( bAdded == false ) then
					ReagentHeaven_Info( "재료천국: [정보] "..productName.."의 요구레벨이 추가되었습니다. ("..requiredLevel..")", bMakeMiss );
				end
			end
		elseif( RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL] ~= requiredLevel ) then
			local oldLevel = RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL];
			RH_PRODUCTS[productName][skillIndex][RH_INT_LEVEL] = requiredLevel;

			if( bMakeMiss ) then
				ReagentHeaven_AddMissedProductValue( productName, skillIndex, RH_INT_LEVEL, requiredLevel );
				ReagentHeaven_Info( "재료천국: [정보] "..productName.."의 요구레벨이 수정되었습니다. ("..oldLevel.." => "..requiredLevel..")", bMakeMiss );
			end
		end
	end
end

function ReagentHeaven_ProcessUserData( skillName, productName, productUserGrade )
	local skillIndex = ReagentHeaven_GetSkillIndex( skillName );

	if( skillIndex == nil ) then
		return;
	end
	if( RH_CUDATA[skillIndex] == nil ) then
		RH_CUDATA[skillIndex] = {};
	end
	RH_CUDATA[skillIndex][productName] = productUserGrade;
end

function ReagentHeaven_ProcessReagent( spellName, skillName, productName, reagentName, neededCount, bMakeMiss )
	local bAdded = false;

	local skillIndex = ReagentHeaven_GetSkillIndex( spellName );

	if( skillIndex == nil ) then
		return;
	end

	if( skillName == '박격포 재장전' ) then
		return;
	end

	-- Process Product
	local product_record = { r=reagentName };
	if( neededCount > 1 ) then
		product_record[RH_INT_NUMBER] = neededCount;
	end
	local tmpCount;
	local index = ReagentHeaven_IsExistReagentNameInProductTable( RH_PRODUCTS[productName][skillIndex], reagentName );

	if( index ) then
		tmpCount = RH_PRODUCTS[productName][skillIndex][index][RH_INT_NUMBER];
		if( tmpCount == nil ) then
			tmpCount = 1;
		end
		if( tmpCount ~= neededCount ) then
			ReagentHeaven_Info( '재료천국: [정보] RH_PRODUCTS> '..productName..'의 재료 '..reagentName..'의 갯수가 잘못되었습니다. ('..tmpCount..' => '..neededCount..')', bMakeMiss );
			if( neededCount == 1 ) then
				RH_PRODUCTS[productName][skillIndex][index][RH_INT_NUMBER] = nil;
			else
				RH_PRODUCTS[productName][skillIndex][index][RH_INT_NUMBER] = neededCount;
			end
			ReagentHeaven_AddMissedProductReagentValue( productName, skillIndex, product_record );
		end
	else
		ReagentHeaven_AddMissedProductReagentValue( productName, skillIndex, product_record );
		table.insert( RH_PRODUCTS[productName][skillIndex], product_record );
		bAdded = true;
	end

	-- Process Reagents
	if( RH_REAGENTS[reagentName] == nil ) then
		RH_REAGENTS[reagentName] = {};
		bAdded = true;
	end
	if( RH_REAGENTS[reagentName][skillIndex] == nil ) then
		RH_REAGENTS[reagentName][skillIndex] = {};
		bAdded = true;
	end

	local reagent_record = { p=productName };
	if( neededCount > 1 ) then
		reagent_record[RH_INT_NUMBER] = neededCount;
	end
	index = ReagentHeaven_IsExistProductNameInReagentTable( RH_REAGENTS[reagentName][skillIndex], productName );
	if( index ) then
		tmpCount = RH_REAGENTS[reagentName][skillIndex][index][RH_INT_NUMBER];
		if( tmpCount == nil ) then
			tmpCount = 1;
		end
		if( tmpCount ~= neededCount ) then
			if( neededCount == 1 ) then
				RH_REAGENTS[reagentName][skillIndex][index][RH_INT_NUMBER] = nil;
			else
				RH_REAGENTS[reagentName][skillIndex][index][RH_INT_NUMBER] = neededCount;
			end
			ReagentHeaven_Info( '재료천국: [정보] RH_REAGENTS> '..productName..'의 재료 '..reagentName..'의 갯수가 잘못되었습니다. ('..tmpCount..' => '..neededCount..')', bMakeMiss );
		end
	else
		bAdded = true;
		table.insert( RH_REAGENTS[reagentName][skillIndex], reagent_record );
	end

	if( bAdded ) then
		ReagentHeaven_Info( '재료천국: [재료누락] '..productName..'의 재료 '..reagentName..'('..neededCount..')', bMakeMiss );
	end
end

local function ReagentHeaven_GetNameFromLink( link )
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gmatch(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	for name in string.gmatch(link, "|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end

function ReagentHeaven_ListTradeSkill( spellName )
	local product_id, numTradeSkills, totalCount;

	numTradeSkills = GetNumTradeSkills();
	totalCount = 0;
	for product_id = 1, numTradeSkills do
		local skillName, skillType, skillnumAvailable, skillisExpanded = GetTradeSkillInfo( product_id );
		if( skillName and skillType ~= 'header' ) then
			totalCount = totalCount + 1;
			local productName = ReagentHeaven_GetNameFromLink( GetTradeSkillItemLink( product_id ) );
			if( productName == nil ) then
				productName = skillName;
			end
			ReagentHeaven_ProcessProduct( spellName, productName, nil, true );
			ReagentHeaven_ProcessUserData( spellName, productName, skillType );
			for reagent_id = 1, GetTradeSkillNumReagents( product_id ) do
				local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo( product_id, reagent_id );
				if( reagentName ) then
					ReagentHeaven_ProcessReagent( spellName, skillName, productName, reagentName, reagentCount, true );
				end
			end
		end
	end
	if( totalCount == 0 ) then
		ReagentHeaven_Chat( "재료천국: "..spellName.."> 조사에 실패했습니다. 다시 한번 기술조사를 해주세요." );
	else
		ReagentHeaven_Chat( "재료천국: "..spellName.."> "..totalCount.."건을 조사했습니다." );
	end

end

function ReagentHeaven_ListCraft( spellName )
	local product_id, numCrafts, totalCount;

--	numCrafts = GetNumCrafts();
	numCrafts = GetNumTradeSkills();
	totalCount = 0;
	for product_id = 1, numCrafts do
--		local craftName, craftSubSpellName, craftType, craftnumAvailable, craftisExpanded, crafttrainingPointCost, craftrequiredLevel = GetCraftInfo( product_id );
		local craftName, craftSubSpellName, craftType, craftnumAvailable, craftisExpanded, crafttrainingPointCost, craftrequiredLevel = GetTradeSkillInfo( product_id );
--		local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
		if( craftName and craftType ~= 'header' ) then
			totalCount = totalCount + 1;
--			local productName = ReagentHeaven_GetNameFromLink( GetCraftItemLink( product_id ) );
			local productName = ReagentHeaven_GetNameFromLink( GetTradeSkillItemLink( product_id ) );
			if( productName == nil ) then
				productName = craftName;
			end
			ReagentHeaven_ProcessProduct( spellName, productName, nil, true );
			ReagentHeaven_ProcessUserData( spellName, productName, craftType );
--			for reagent_id = 1, GetCraftNumReagents( product_id ) do
			for reagent_id = 1, GetTradeSkillNumReagents( product_id ) do
--				local reagentName, reagentTexture, reagentCount, playerReagentCount = GetCraftReagentInfo( product_id, reagent_id );
				local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo( product_id, reagent_id );
				if( reagentName ) then
					ReagentHeaven_ProcessReagent( spellName, craftName, productName, reagentName, reagentCount, true );
				end
			end
		end
	end
	if( totalCount == 0 ) then
		ReagentHeaven_Chat( "재료천국: "..spellName.."> 조사에 실패했습니다. 다시 한번 기술조사를 해주세요." );
	else
		ReagentHeaven_Chat( "재료천국: "..spellName.."> "..totalCount.."건을 조사했습니다." );
	end
end

function ReagentHeaven_OpenTradeSkillFrame( tradeskill_id, spellName, subSpellName )
	if( TradeSkillFrame_Hide and TradeSkillFrame:IsVisible() ) then
		TradeSkillFrame_Hide();
	end
	CastSpell( tradeskill_id, BOOKTYPE_SPELL );
end

function ReagentHeaven_OpenCraftFrame( craft_id, spellName, subSpellName )
	if( CrafrFrame_Hide and CraftFrame:IsVisible() ) then
		CraftFrame_Hide();
	end
	CastSpell( craft_id, BOOKTYPE_SPELL );
end

function ReagentHeaven_ProcessClassSkill( spell_id, spellName, subSpellName )
	RHHiddenTooltip:SetSpell( spell_id, BOOKTYPE_SPELL );
	local tooltipName = getglobal( "RHHiddenTooltipTextLeft1" ):GetText();
	if( not tooltipName or tooltipName ~= spellName ) then
		return false;
	end

	local index, loop;
	local field, left, right, color, stext;
	local iStart, iEnd;
	local ClassRecipes;
	local fullName;

	if( subSpellName and (subSpellName ~= "") ) then
		fullName = spellName.."("..subSpellName..")";
	else
		fullName = spellName;
	end

	for index = 1, 30 do
		field = getglobal("RHHiddenTooltipTextLeft"..index);
		if( field and field:IsVisible() ) then
			left = field:GetText();
		else
			left = nil;
		end

		field = getglobal("RHHiddenTooltipTextRight"..index);
		if( field and field:IsVisible() ) then
			right = field:GetText();
		else
			right = nil;
		end

		if( not left ) then
			break;
		end
		iStart, iEnd, ClassRecipes = string.find( left, "재료: (.+)" );
		if( iStart ) then
			ReagentHeaven_ProcessProduct( UnitClass("player"), fullName, nil, true );

			if( ClassRecipes ~= nil ) then
				local reagentName, reagentCount, reagentText;
				local stext = string.gsub( ClassRecipes, ", ", "+" );
				stext = string.gsub( stext, "|c(%x+)(.+)|r", "%2" );

				for reagentText in string.gmatch( stext, "[^+]+" ) do
					reagentName = nil;
					reagentCount = nil;
					iStart, iEnd, reagentName, reagentCount= string.find( reagentText, "(.+) %((%d+)%)");
--					ReagentHeaven_Chat( reagentName );
					if( reagentName and reagentCount ) then
						ReagentHeaven_ProcessReagent( UnitClass("player"), fullName, fullName, reagentName, tonumber(reagentCount), true );
					else
						ReagentHeaven_ProcessReagent( UnitClass("player"), fullName, fullName, reagentText, 1, true );
					end
				end
			end
		end
	end
end

function ReagentHeaven_DisplayHelpText( frame )
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = TEXT(getglobal("REAGENTHEAVEN_HELP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("REAGENTHEAVEN_HELP_TEXT_LINE"..i));
	end
end

function ReagentHeaven_MergeMissed()
	local k1, v1, k2, v2, k3, v3, itemCount;

	for k1, v1 in pairs( RH_MISSED_PRODUCTS ) do
		for k2, v2 in pairs( RH_MISSED_PRODUCTS[k1] ) do
			ReagentHeaven_ProcessProduct( ReagentHeaven_GetSkillName( k2 ), k1, v2[RH_INT_LEVEL], false );
			for k3, v3 in pairs( RH_MISSED_PRODUCTS[k1][k2] ) do
				if( ReagentHeaven_IsIntCommand( k3 ) == false ) then
					itemCount = v3[RH_INT_NUMBER];
					if( not itemCount ) then
						itemCount = 1;
					end
					ReagentHeaven_ProcessReagent( ReagentHeaven_GetSkillName( k2 ), k1, k1, v3.r, itemCount, false );
				end
			end
		end
	end
	for k1, v1 in pairs( RH_MISSED_REAGENTS ) do
		for k2, v2 in pairs( RH_MISSED_REAGENTS[k1] ) do
			if( ReagentHeaven_IsIntCommand( k2 ) == true ) then
				ReagentHeaven_ProcessReagentMemo( k1, k2, v2 );
			end
		end
	end
end

function ReagentHeaven_IsExistReagentNameInProductTable( productTable, reagentName )
	if( productTable == nil ) then
		return false;
	end
	local k, v;

	for k, v in pairs( productTable ) do
		if( ReagentHeaven_IsIntCommand( k ) == false ) then
			if( v.r == reagentName ) then
				return k;
			end
		end
	end
	return nil;
end

function ReagentHeaven_IsExistProductNameInReagentTable( reagentTable, productName )
	if( reagentTable == nil ) then
		return false;
	end
	local k, v;

	for k, v in pairs( reagentTable ) do
		if( (k ~= RH_INT_SKILLS) and (k ~= RH_INT_GATHER) and (k ~= RH_INT_EXTRA) and (k ~= RH_INT_NUMBER) and (k ~= RH_INT_LEVEL) and (k ~= RH_INT_COLOR) and (k ~= RH_INT_COLOR2) and (k ~= RH_INT_MSG) and (k ~= RH_INT_MSG2) ) then
			if( v.p == productName ) then
				return k;
			end
		end
	end
	return nil;
end


-- ReagentHeaven_HandleSlashCmd( msg )
-- This function is called when a user types one of your slash commands
-- the text they enter after the command comes in msg
function ReagentHeaven_HandleSlashCmd( msg )
	local cmd = string.gsub( msg, "%s*([^%s]+)%s(.*)", "%1" );
	if( cmd == msg ) then
		msg = nil;
	else
		msg = string.sub( msg, strlen( cmd ) + 2 );
	end
	cmd = string.lower( cmd );
	if( (cmd == nil) or (cmd == "") or (cmd == "toggle") or (cmd == REAGENTHEAVEN_CMD_TOGGLE) ) then
		if( ReagentHeavenFrame:IsVisible() ) then
			HideUIPanel( ReagentHeavenFrame );
		else
			ShowUIPanel( ReagentHeavenFrame );
		end
	elseif( (cmd == "config") or (cmd == REAGENTHEAVEN_CMD_CONFIG) ) then
		if( ReagentHeavenOptionsFrame:IsVisible() ) then
			HideUIPanel( ReagentHeavenOptionsFrame );
		else
			ShowUIPanel( ReagentHeavenOptionsFrame );
		end
	else if( (cmd == "setrange") or (cmd == REAGENTHEAVEN_CMD_SETRANGE ) ) then
		if( not msg ) then
			ReagentHeaven_DisplayHelpText( this.chatFrame );
			return;
		end

		local strSkillName = gsub( msg, "%s*([^%s]+).*", "%1" );
		if( not strSkillName ) then
			ReagentHeaven_DisplayHelpText( this.chatFrame );
			return;
		end

		if( strSkillName == msg ) then
			msg = nil;
		else
			msg = string.sub( msg, strlen( strSkillName ) + 2 );
		end

		if( ReagentHeaven_GetSkillIndex( strSkillName ) == nil ) then
			ReagentHeaven_Chat( RH_MSG_NOSKILL );
			return;
		end
		local strMinValue = gsub( msg, "%s*([^%s]+).*", "%1" );
		if( not strMinValue ) then
			ReagentHeaven_DisplayHelpText( this.chatFrame );
			return;
		end
		if( tonumber( strMinValue ) == nil ) then
			ReagentHeaven_Chat( RH_MSG_NOTNUMBER_MINVALUE );
			return;
		end
		if( strMinValue == msg ) then
			msg = nil;
		else
			msg = string.sub( msg, strlen( strMinValue ) + 2 );
		end

		local strMaxValue = gsub( msg, "%s*([^%s]+).*", "%1" );
		if( not strMaxValue ) then
			ReagentHeaven_DisplayHelpText( this.chatFrame );
			return;
		end
		if( tonumber( strMaxValue ) == nil ) then
			ReagentHeaven_Chat( RH_MSG_NOTNUMBER_MAXVALUE );
			return;
		end
		if( strMaxValue == msg ) then
			msg = nil;
		else
			msg = string.sub( msg, strlen( strMaxValue ) + 2 );
		end

		ReagentHeaven_SetSkillRange( strSkillName, tonumber( strMinValue ), tonumber( strMaxValue ) );
	else
		ReagentHeaven_DisplayHelpText( this.chatFrame );
	end
end
end

function ReagentHeaven_IsInTable( table, value )
	if( table == nil ) then
		return false;
	end
	local k, v;

	for k, v in pairs( table ) do
		if( v == value ) then
			return true;
		end
	end
	return false;
end

-- Misc. Functions
function ReagentHeaven_GetSkillIndex( skillName )
	return RH_SKILLS_NT[skillName];
end

function ReagentHeaven_GetSkillNamesFromItem( item )
	local retLine = nil;
	local k, v;

	for k, v in pairs( item ) do
		if( (k ~= RH_INT_SKILLS) and (k ~= RH_INT_GATHER) and (k ~= RH_INT_EXTRA) and (k ~= RH_INT_NUMBER) and (k ~= RH_INT_LEVEL) and (k ~= RH_INT_COLOR) and (k ~= RH_INT_COLOR2) and (k ~= RH_INT_MSG) and (k ~= RH_INT_MSG2) ) then
			if( retLine == nil ) then
				retLine = ReagentHeaven_GetSkillName( k );
			else
				retLine = retLine..", "..ReagentHeaven_GetSkillName( k );
			end
		end
	end
	return retLine;
end

function ReagentHeaven_GetSkillName( skillIndex )
	if( not skillIndex ) then
		return nil;
	end

	local retSkillNames, skill;
	local RH_Temp1 = 0;
	for skill in string.gmatch( skillIndex, "(.)" ) do
		if( not RH_SKILLS[skill] ) then
			--DEFAULT_CHAT_FRAME:AddMessage( REAGENTHEAVEN_NAME..": [경고] 모르는 전문/보조기술 종류입니다. ("..skill..")" );
			RH_Temp1 = RH_Temp1 + 1;
		elseif( retSkillNames == nil ) then
			retSkillNames = RH_SKILLS[skill];
		else
			retSkillNames = retSkillNames..", "..RH_SKILLS[skill];
		end
	end
	if RH_Temp1 ~= 0 then
		DEFAULT_CHAT_FRAME:AddMessage( REAGENTHEAVEN_NAME.." 모르는 전문/보조기술 갯수: "..RH_Temp1 );
	end
	return retSkillNames;
end

-- TODO: support RH_PRODUCTS, too.
function ReagentHeaven_IsExistSkill( item, skillIndex )
	if( not item[RH_INT_SKILLS] or not skillIndex ) then
		return nil;
	end

	local skill;
	for skill in string.gmatch( item[RH_INT_SKILLS], "(.)") do
		if( skill == skillIndex ) then
			return true;
		end
	end

	return nil;
end

function ReagentHeaven_AddSkill( item, skillIndex )
	if( not skillIndex ) then
		DEFAULT_CHAT_FRAME:AddMessage( '재료천국: [에러] 기술이름이 인덱스에 존재하지 않습니다.', 1.0, 0.3, 0.3 );
		return nil;
	end
	if( not item[RH_INT_SKILLS] ) then
		item[RH_INT_SKILLS] = TEXT( skillIndex );
	elseif( not ReagentHeaven_IsExistSkill( item, skillIndex ) ) then
		item[RH_INT_SKILLS] = item[RH_INT_SKILLS]..skillIndex;
	end
	return true;
end

-- Support for Other Addons
--function ReagentHeaven_MyInventory_ContainerFrameItemButton_OnEnter()
--	RH_ORG_MyInventory_ContainerFrameItemButton_OnEnter();
--	ReagentHeaven_ModifyTooltip( GameTooltip );
--end

--function ReagentHeaven_MyInventoryFrame_Update( frame )
--	RH_ORG_MyInventoryFrame_Update( frame );
--	ReagentHeaven_ModifyTooltip( GameTooltip );
--end

local RH_TMP_BAG = -999;
local RH_TMP_SLOT = -1;
local RH_TMP_ITEMNAME = "";
local RH_TMP_TEXTURE = "";

-- Tracks the last spell picked up
function ReagentHeavenItem_Pickup( bag, slot, name, texture )
	RH_TMP_BAG = bag;
	RH_TMP_SLOT = slot;
	RH_TMP_ITEMNAME = name;
	RH_TMP_TEXTURE = texture;
end

function ReagentHeavenItem_Reset()
	RH_TMP_BAG = -999;
	RH_TMP_SLOT = -1;
	RH_TMP_ITEMNAME = "";
	RH_TMP_TEXTURE = "";
end

function ReagentHeavenItem_DropCursor()
	if CursorHasItem() then
		if( RH_TMP_BAG >= -1 ) then
			PickupContainerItem( RH_TMP_BAG, RH_TMP_SLOT );
	      	elseif( RH_TMP_SLOT >= 0 ) then
			PickupInventoryItem( RH_TMP_SLOT );
		end
	end
	ReagentHeavenItem_Reset();
end

function ReagentHeaven_GetItemName( bag, slot )
	local bagNumber = bag;
	local name = "";
	RHHiddenTooltip:SetOwner( UIParent, "ANCHOR_NONE" );
	if ( type( bagNumber ) ~= "number" ) then
		bagNumber = tonumber( bag );
	end
	if( bagNumber < 0 ) then
		RHHiddenTooltip:SetInventoryItem( "player", slot );
	else
		RHHiddenTooltip:SetBagItem( bag, slot );
	end
	name = RHHiddenTooltipTextLeft1:GetText();
	if name == nil then
		name = "";
	end
	return name;
end

function ReagentHeaven_PickupContainerItem( bag, slot )
	local bEmpty = true;

	--[[
	if( RH_ORG_PickupContainerItem ) then
		RH_ORG_PickupContainerItem( bag, slot )
	end
	]]
	if( CursorHasItem() ) then
		local texture, itemCount, locked = GetContainerItemInfo( bag, slot );
		if( texture ) then
			local name;

			if( bag == -1 ) then
				name = ReagentHeaven_GetItemName( bag, slot + 39 );
			else
				name = ReagentHeaven_GetItemName( bag, slot );
			end
			ReagentHeavenItem_Pickup( bag, slot, name, texture );
			bEmpty = false;
		end
	end
	if( bEmpty ) then
		ReagentHeavenItem_Reset();
	end
end

function ReagentHeaven_PickupInventoryItem( slot )
	local bEmpty = true;

	--[[
	if( RH_ORG_PickupInventoryItem ) then
		RH_ORG_PickupInventoryItem( slot );
	end
	]]
	if( CursorHasItem() ) then
		local texture = GetInventoryItemTexture( "player", slot );
		if( texture ) then
			local name = ReagentHeaven_GetItemName( -999, slot );
			ReagentHeavenItem_Pickup( -999, slot, name, texture );
			bEmpty = false;
		end
	end
	if( bEmpty ) then
		ReagentHeavenItem_Reset();
	end
end

function ReagentHeaven_OtherAddonHook()
	if( not RH_HOOKED ) then
		--[[
		RH_ORG_PickupContainerItem = PickupContainerItem;
		PickupContainerItem = ReagentHeaven_PickupContainerItem;

		RH_ORG_PickupInventoryItem = PickupInventoryItem;
		PickupInventoryItem = ReagentHeaven_PickupInventoryItem;
		]]

		hooksecurefunc( 'PickupContainerItem', ReagentHeaven_PickupContainerItem )
		hooksecurefunc( 'PickupInventoryItem', ReagentHeaven_PickupInventoryItem )

		if( (IsAddOnLoaded("LinkWrangler") ~= nil) and (LINK_WRANGLER_CALLER ~= nil) ) then
			LINK_WRANGLER_CALLER["ReagentHeaven"] = "ReagentHeaven_ModifyTooltip";
		end
		RH_HOOKED = true;
	end
end

-- Support for MyInventory addon


-- Support for ReagentHeavenFrame

-- Move the Item around
function ReagentHeaven_ButtonDragStart()
--	ReagentHeaven_Chat( 'ButtonOnDragStart' );
end

function ReagentHeaven_ButtonDragEnd()
	if( RH_TMP_TEXTURE ) then
		ReagentHeavenItemName:SetText( RH_TMP_ITEMNAME );
	end
	ReagentHeavenItem_DropCursor();
	ReagentHeaven_UpdateReagentHeavenFrame( ReagentHeavenItemName:GetText(), false );
	ReagentHeaven_Refresh();
--	ReagentHeaven_Chat( 'ButtonOnDragEnd' );
end


function ReagentHeaven_ButtonOnEnter()
--	ReagentHeaven_Chat( 'ButtonOnEnter' );
end

function ReagentHeaven_ButtonOnLeave()
--	ReagentHeaven_Chat( 'ButtonOnLeave' );
end

function ReagentHeaven_ButtonOnClick( button )
	if( RH_TMP_TEXTURE ) then
		ReagentHeavenItemName:SetText( RH_TMP_ITEMNAME );
	end
	ReagentHeavenItem_DropCursor();
	ReagentHeaven_UpdateReagentHeavenFrame( ReagentHeavenItemName:GetText(), false );
	ReagentHeaven_Refresh();
end

function ReagentHeaven_ButtonOnEvent( event )
--	ReagentHeaven_Chat( 'ButtonOnEvent' );
end

function ReagentHeaven_GetRawName( text )
	local iStart, iEnd, iName, iValue;

	iStart, iEnd, iName, iValue = string.find( text, ": (.+)%((%d+)%)" );
	if( iStart ) then
		return iName;
	end
	iStart, iEnd, iName = string.find( text, ": (.+)" );
	if( iStart ) then
		return iName;
	end
	iStart, iEnd, iName = string.find( text, "+ (.+)" );
	if( iStart ) then
		return iName;
	end
	return nil;
end

function ReagentHeavenItemButton_OnClick( button )
	if( button == "LeftButton" ) then
		local itemName = ReagentHeaven_GetRawName( this:GetText() );

		if( itemName and (RH_REAGENTS[ itemName ] or RH_PRODUCTS[ itemName ]) ) then
			ReagentHeavenItemName:SetText( itemName );
			ReagentHeaven_UpdateReagentHeavenFrame( itemName, false );
			ReagentHeaven_Refresh();
		end
	end
end

function ReagentHeavenFrame_CanSend()
	if( strlen( ReagentHeavenItemName:GetText() ) > 0 ) then
		if( RH_PRODUCTS[ ReagentHeavenItemName:GetText() ] ) then
			ReagentHeavenPasteReagentsButton:Enable();
		else
			ReagentHeavenPasteReagentsButton:Disable();
		end
		ReagentHeavenSearchButton:Enable();
		ReagentHeavenEditItemButton:Enable();
	else
		ReagentHeavenSearchButton:Disable();
		ReagentHeavenEditItemButton:Disable();
		ReagentHeavenPasteReagentsButton:Disable();
	end
	if( RH_CURRENT_HISTORY > 1 ) then
		ReagentHeavenFramePrevPageButton:Enable();
	else
		ReagentHeavenFramePrevPageButton:Disable();
	end
	if( RH_CURRENT_HISTORY < #RH_HISTORY) then
		ReagentHeavenFrameNextPageButton:Enable();
	else
		ReagentHeavenFrameNextPageButton:Disable();
	end
end

function ReagentHeaven_PasteReagents( itemName )
	if( itemName and strlen( itemName ) ) then
		if( RH_PRODUCTS[ itemName ]) then
			local k1, v1, k2, v2;
			local l_skillCount = 0;
			local l_ExtraLine;
			local messageResult = itemName..": ";

			for k1, v1 in pairs(RH_PRODUCTS[itemName]) do
				if( l_skillCount > 0 ) then
					messageResult = messageResult..".  ";
				end
				messageResult = messageResult.."<"..ReagentHeaven_GetSkillName(k1)..ReagentHeaven_GetCraftLevelString(itemName, k1).."> ";
				local l_reagentsCount = 0;
				for k2, v2 in pairs( v1 ) do
					if( ReagentHeaven_IsIntCommand( k2 ) == false ) then
						if( v2[RH_INT_NUMBER] ~= nil ) then
							l_ExtraLine = v2[RH_INT_NUMBER];
						else
							l_ExtraLine = 1;
						end
						if( l_reagentsCount > 0 ) then
							messageResult = messageResult..", ";
						end
						messageResult = messageResult..v2.r.."x"..l_ExtraLine;
						l_reagentsCount = l_reagentsCount + 1;
					end
				end
				l_skillCount = l_skillCount + 1;
			end
			return messageResult;
		end
	end
end

function ReagentHeavenFrame_PasteReagents()
	local itemName = ReagentHeavenItemName:GetText();
	local reagentsText = ReagentHeaven_PasteReagents( itemName );
	if( reagentsText ) then
		if( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert( reagentsText );
		else
			ChatFrame_OpenChat( reagentsText );
		end
	end
end

function ReagentHeavenFrame_Search()
	if( strlen( ReagentHeavenItemName:GetText() ) > 0 ) then
		ReagentHeaven_UpdateReagentHeavenFrame( ReagentHeavenItemName:GetText(), ReagentHeavenFrameSubtitleCheck:GetChecked() );
		ReagentHeaven_Refresh();
	end
end

function ReagentHeavenFrame_PrevButtonClick( button )
	if( button == "LeftButton" ) then
		this:Disable();
		if( RH_CURRENT_HISTORY > 1 ) then
			ReagentHeavenItemName:SetText( RH_HISTORY[ RH_CURRENT_HISTORY - 1 ].name );
			ReagentHeaven_UpdateReagentHeavenFrame( RH_HISTORY[ RH_CURRENT_HISTORY - 1 ].name, RH_HISTORY[ RH_CURRENT_HISTORY - 1 ].subtitle, true );
			ReagentHeaven_Refresh();
			RH_CURRENT_HISTORY = RH_CURRENT_HISTORY - 1;
		end
	end
end

function ReagentHeavenFrame_NextButtonClick( button )
	if( button == "LeftButton" ) then
		this:Disable();
		if( RH_CURRENT_HISTORY < #RH_HISTORY ) then
			ReagentHeavenItemName:SetText( RH_HISTORY[ RH_CURRENT_HISTORY + 1 ].name );
			ReagentHeaven_UpdateReagentHeavenFrame( RH_HISTORY[ RH_CURRENT_HISTORY + 1 ].name, RH_HISTORY[ RH_CURRENT_HISTORY + 1 ].subtitle, true );
			ReagentHeaven_Refresh();
			RH_CURRENT_HISTORY = RH_CURRENT_HISTORY + 1;
		end
	end
end

-- ReagentHeavenEditFrame
function ReagentHeavenFrame_EditItem()
	local itemName = ReagentHeavenItemName:GetText();

	if( (itemName == nil) or (itemName == "") ) then
		return;
	end
	ReagentHeavenEditFrameItemName:SetText( itemName );
	if( RH_REAGENTS[itemName] and RH_REAGENTS[itemName][RH_INT_GATHER] ) then
		ReagentHeavenEditFrameGatherEditBox:SetText( RH_REAGENTS[itemName][RH_INT_GATHER] );
	else
		ReagentHeavenEditFrameGatherEditBox:SetText( "" );
	end
	if( RH_REAGENTS[itemName] and RH_REAGENTS[itemName][RH_INT_EXTRA] ) then
		ReagentHeavenEditFrameExtraEditBox:SetText( RH_REAGENTS[itemName][RH_INT_EXTRA] );
	else
		ReagentHeavenEditFrameExtraEditBox:SetText( "" );
	end
	ReagentHeavenEditFrame:Show();
end

function ReagentHeaven_ProcessReagentMemo( reagentName, skillIndex, itemMemo )
	if( (itemMemo ~= nil) and (itemMemo ~= "") ) then
		if( RH_REAGENTS[reagentName] == nil ) then
			RH_REAGENTS[reagentName] = {};
		end
		if( RH_MISSED_REAGENTS[reagentName] == nil ) then
			RH_MISSED_REAGENTS[reagentName] = {};
		end
		RH_REAGENTS[reagentName][skillIndex] = itemMemo;
		RH_MISSED_REAGENTS[reagentName][skillIndex] = itemMemo;
	else
		if( RH_REAGENTS[reagentName] ) then
			RH_REAGENTS[reagentName][skillIndex] = nil;
		end
		if( RH_MISSED_REAGENTS[reagentName] ) then
			RH_MISSED_REAGENTS[reagentName][skillIndex] = nil;
		end
	end
end

function ReagentHeavenEditFrame_Save()
	local itemName = ReagentHeavenEditFrameItemName:GetText();

	if( (itemName == nil) or (itemName == "") ) then
		return;
	end

	ReagentHeaven_ProcessReagentMemo( itemName, RH_INT_GATHER, ReagentHeavenEditFrameGatherEditBox:GetText() );
	ReagentHeaven_ProcessReagentMemo( itemName, RH_INT_EXTRA, ReagentHeavenEditFrameExtraEditBox:GetText() );
	ReagentHeaven_UpdateReagentHeavenFrame( itemName, false );
	ReagentHeaven_Refresh();
end

-- Misc. Utility functions;
function ReagentHeaven_BreakLink( link )
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end

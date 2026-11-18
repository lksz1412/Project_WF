
-------------------------------------------------------------------------------
--
--  Mod Name : BlinkSwapOverpower v1.6
--  Author   : Blink
--  Date     : 2005/08/02
--  LastUpdate : 2008/10/23
--
-------------------------------------------------------------------------------

-- Variables ------------------------------------------------------------------

BSOP_Config_Loaded = 0;
BSOP_Before = {};
BSOP_SwapTime = {};

local cp = LibStub and LibStub("LibCombatParser-1.0")
local function parser(info)
	if info.type == 'miss' and (info.source.me or info.source.myGuardian or info.source.myObject) and info.missType == DODGE then
		BlinkSwapOverpower:Show();
		BSOP_DoSwapSet("제압");
	elseif info.type == 'hit' and info.source.me and info.spell.name == '제압' then
		BSOP_RestoreSet("제압");
		--BlinkSwapOverpower:Show();
	end
end
-------------------------------------------------------------------------------
-- OnFoo functions
-------------------------------------------------------------------------------

-- OnLoad ---------------------------------------------------------------------
function BlinkSwapOverpower_OnLoad(self)
	BlinkSwapOverpowerDB = {};
	if not cp then
		print("LibCombatParser-1.0이 실행되지 않아 BlinkSwapOverpower를 사용할 수 없습니다.")
		return
	end

	if ( UnitClass("player") == "전사" ) then
		cp:AddListener(parser)
		BSOP_BM_Register();
	end
end

-- OnUpdate -------------------------------------------------------------------
function BlinkSwapOverpower_OnUpdate()
	local current = GetTime();
	BSOP_DelayedRestoreSet( "제압", 5, current );
end


-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- BSOP_GetSet ----------------------------------------------------------------
function BSOP_GetSet(set)
	if ( not BlinkSwapOverpowerDB ) then
		return nil;
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		return nil;
	end
	return BlinkSwapOverpowerDB[set];
end

-- BSOP_HasUseSet -------------------------------------------------------------
function BSOP_HasUseSet()
	if ( not BlinkSwapOverpowerDB ) then
		return false;
	end
	for setname,set in pairs(BlinkSwapOverpowerDB) do
		if ( set.use == 1 ) then
			return true;
		end
	end
	return false;
end

-- BSOP_ToggleSwapSet ---------------------------------------------------------
function BSOP_ToggleSwapSet(set)
	if ( not BlinkSwapOverpowerDB ) then
		BlinkSwapOverpowerDB = {};
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		BlinkSwapOverpowerDB[set] = {
			use = 0,
			main = {name="",id=""},
			off = {name="",id=""},
			exceptDefensive = 1,
			exceptBerserker = 1,
			norestore = 0,
		}
	end
	if( BlinkSwapOverpowerDB[set].use == 1 )then
		BlinkSwapOverpowerDB[set].use = 0;
		if ( BSOP_HasUseSet() == false ) then
			BlinkSwapOverpower:Hide();
		end
	else
		BlinkSwapOverpowerDB[set].use = 1;
	end
end

-- BSOP_ToggleExceptDefensive -------------------------------------------------
function BSOP_ToggleExceptDefensive(set)
	if ( not BlinkSwapOverpowerDB ) then
		BlinkSwapOverpowerDB = {};
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		BlinkSwapOverpowerDB[set] = {
			use = 0,
			main = {name="",id=""},
			off = {name="",id=""},
			exceptDefensive = 1,
			exceptBerserker = 1,
			norestore = 0,
		}
	end
	if( BlinkSwapOverpowerDB[set].exceptDefensive == 1 )then
		BlinkSwapOverpowerDB[set].exceptDefensive = 0;
	else
		BlinkSwapOverpowerDB[set].exceptDefensive = 1;
	end
end

-- BSOP_ToggleExceptBerserker -------------------------------------------------
function BSOP_ToggleExceptBerserker(set)
	if ( not BlinkSwapOverpowerDB ) then
		BlinkSwapOverpowerDB = {};
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		BlinkSwapOverpowerDB[set] = {
			use = 0,
			main = {name="",id=""},
			off = {name="",id=""},
			exceptDefensive = 1,
			exceptBerserker = 1,
			norestore = 0,
		}
	end
	if( BlinkSwapOverpowerDB[set].exceptBerserker == 1 )then
		BlinkSwapOverpowerDB[set].exceptBerserker = 0;
	else
		BlinkSwapOverpowerDB[set].exceptBerserker = 1;
	end
end

-- BSOP_ToggleNoRestore -------------------------------------------------------
function BSOP_ToggleNoRestore(set)
	if ( not BlinkSwapOverpowerDB ) then
		BlinkSwapOverpowerDB = {};
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		BlinkSwapOverpowerDB[set] = {
			use = 0,
			main = {name="",id=""},
			off = {name="",id=""},
			exceptDefensive = 1,
			exceptBerserker = 1,
			norestore = 0,
		}
	end
	if( BlinkSwapOverpowerDB[set].norestore == 1 )then
		BlinkSwapOverpowerDB[set].norestore = 0;
		BlinkSwapOverpower:Hide();
	else
		BlinkSwapOverpowerDB[set].norestore = 1;
	end
end

-- BSOP_SaveSwapSet -----------------------------------------------------------
function BSOP_SaveSwapSet(set)
	local m, mid = BlinkSwap_GetItemName(-1, 16);
	local s, sid = BlinkSwap_GetItemName(-1, 17);

	if( m == nil or ( m == nil and s == nil ) ) then return; end
	
	if ( not BlinkSwapOverpowerDB ) then
		BlinkSwapOverpowerDB = {};
	end
	if ( not BlinkSwapOverpowerDB[set] ) then
		BlinkSwapOverpowerDB[set] = {
			use = 0,
			main = {name="",id=""},
			off = {name="",id=""},
			exceptDefensive = 1,
			exceptBerserker = 1,
			norestore = 0,
		};
	end
	BlinkSwapOverpowerDB[set].main = {name=m,id=mid};
	BlinkSwapOverpowerDB[set].off = {name=s,id=sid};
end

-- BSOP_DoSwapSet -------------------------------------------------------------
function BSOP_DoSwapSet(set)
	local sets = BSOP_GetSet(set);
	if ( not sets ) then
		return;
	end
	if ( sets.use ~= 1) then
		return;
	end
	if ( not sets.main or not sets.main.name or not sets.off or not sets.off.name ) then
		return;
	end
	if ( sets.exceptDefensive ~= 0 ) then
		if ( GetBonusBarOffset() == 2 ) then
			return;
		end
	end
	if ( sets.exceptBerserker ~= 0 ) then
		if ( GetBonusBarOffset() == 3 ) then
			return;
		end
	end
	if ( not BSOP_SwapTime[set] ) then
		BSOP_SwapTime[set] = 0;
	end
	if ( BSOP_SwapTime[set] > 0 ) then
		return;
	end
	if ( not BSOP_Before[set] ) then
		BSOP_Before[set] = { main = {name="none",id=""}, off = {name="none",id=""} };
	end
	local m, mid = BlinkSwap_GetItemName(-1, 16);
	local s, sid = BlinkSwap_GetItemName(-1, 17);
	if ( sets.main.id ~= mid or sets.off.id ~= sid ) then
		BSOP_Before[set].main = {name=m,id=mid};
		BSOP_Before[set].off = {name=s,id=sid};
		BlinkSwapExecute( sets.main.id, sets.off.id );
		BSOP_SwapTime[set] = GetTime();
	end
end

-- BSOP_RestoreSet ------------------------------------------------------------
function BSOP_RestoreSet(set)
	BSOP_SwapTime[set] = 0;
	if ( not BSOP_Before or not BSOP_Before[set] ) then
		return;
	end
	if ( BSOP_Before[set].main.name == "none" and BSOP_Before[set].off.name == "none" ) then
		return;
	end
	BlinkSwapExecute( BSOP_Before[set].main.id, BSOP_Before[set].off.id );
	BSOP_Before[set].main = {name="none",id=""};
	BSOP_Before[set].off = {name="none",id=""};
end

-- BSOP_DelayedRestoreSet -----------------------------------------------------
function BSOP_DelayedRestoreSet(set, delay, current)
	if ( BSOP_SwapTime[set] and BSOP_SwapTime[set] > 0 and (current - (BSOP_SwapTime[set] + delay))>=0 ) then
		BSOP_RestoreSet(set);
		BlinkSwapOverpower:Hide();
	end
end


-------------------------------------------------------------------------------
-- DropDown Menu Config
-------------------------------------------------------------------------------

-- BSOP_BM_Register -----------------------------------------------------------
function BSOP_BM_Register()

	if ( not BlinkMod_RegisterMenu ) then
		return;
	end

	local info;

	-- 제압스왑


		-- tier 2 : parent = BSMAIN
		
		-- Spacer
		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPSPACER1";
		info.disabled = 1;
		BlinkMod_RegisterMenu(info, 2);

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPTITLE";
		info.text = "제압스왑";
		info.isTitle = 1;
		info.notCheckable = 1;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPSWAP";
		info.text = "제압스왑사용";
		info.tooltipTitle = "제압스왑사용";
		info.tooltipText = "제압이 사용가능한 상태가 되면 자동으로 설정된 무기로 교체합니다.";
		info.ClickFunction = BSOP_BM_ToggleSwapOverpower;
		info.ShowHideFunction = BSOP_BM_OverpowerShow;
		info.CheckFunction = BSOP_BM_OverpowerCheck;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPEXCEPTDEFENSIVE";
		info.text = "방어태세에서 사용";
		info.tooltipTitle = "방어태세에서 사용";
		info.tooltipText = "방어태세에서 제압 발동시 자동으로 무기를 스왑합니다.";
		info.ClickFunction = BSOP_BM_ToggleExceptDefensive;
		info.ShowHideFunction = BSOP_BM_OverpowerShow;
		info.CheckFunction = BSOP_BM_ExceptDefensiveCheck;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPEXCEPTBERSERKER";
		info.text = "광폭태세에서 사용";
		info.tooltipTitle = "광폭태세에서 사용";
		info.tooltipText = "광폭태세에서 제압 발동시 자동으로 무기를 스왑합니다.";
		info.ClickFunction = BSOP_BM_ToggleExceptBerserker;
		info.ShowHideFunction = BSOP_BM_OverpowerShow;
		info.CheckFunction = BSOP_BM_ExceptBerserkerCheck;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPNORESTORE";
		info.text = "이전 무기로 자동 복귀";
		info.tooltipTitle = "이전 무기로 자동 복귀";
		info.tooltipText = "제압을 사용한 후에 스왑 이전무기로 자동으로 전환합니다.";
		info.ClickFunction = BSOP_BM_ToggleNoRestore;
		info.ShowHideFunction = BSOP_BM_OverpowerShow;
		info.CheckFunction = BSOP_BM_NoRestoreCheck;
		BlinkMod_RegisterMenu( info, 2 );

		info = {};
		info.parentkey = "BSMAIN";
		info.key = "BSOPSAVEOVERPOWER";
		info.text = "제압용 무기저장";
		info.tooltipTitle = "제압용 무기저장";
		info.tooltipText = "현재 장착하고있는 장비를 제압용 무기로 설정합니다.";
		info.ClickFunction = BSOP_BM_SaveSwapOverpower;
		info.ShowHideFunction = BSOP_BM_OverpowerShow;
		info.CheckFunction = function() return false; end
		BlinkMod_RegisterMenu( info, 2 );

			-- tier 3 : parent = BSLIST
			info = {};
			info.parentkey = "BSLIST";
			info.key = "BSOPLISTOVERPOWER";
			info.text = "제압용";
			info.tooltipTitle = "제압용";
			info.tooltipText = "클릭하시면 해당무기를 장착합니다.";
			info.ClickFunction = BSOP_BM_SwapOverpowerClick;
			info.GetNameFunction = BSOP_BM_SwapOverpowerName;
			info.ShowHideFunction = BSOP_BM_SwapOverpowerShow;
			info.CheckFunction = BSOP_BM_SwapOverpowerCheck;
			BlinkMod_RegisterMenu( info, 3 );

end

--
-- 제압스왑사용 토글
--
function BSOP_BM_ToggleSwapOverpower()
	BSOP_ToggleSwapSet("제압");
end

function BSOP_BM_OverpowerShow()
	if ( UnitClass("player") == "전사" ) then
		return true;
	else
		return false;
	end
end

--
-- 방태에서는 스왑사용
--
function BSOP_BM_ToggleExceptDefensive()
	BSOP_ToggleExceptDefensive("제압");
end

function BSOP_BM_ExceptDefensiveCheck()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return false;
	end
	if( sets.exceptDefensive ~= 1 )then
		return true;
	else
		return false;
	end
end

--
-- 광태에서는 스왑사용
--
function BSOP_BM_ToggleExceptBerserker()
	BSOP_ToggleExceptBerserker("제압");
end

function BSOP_BM_ExceptBerserkerCheck()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return false;
	end
	if( sets.exceptBerserker ~= 1 )then
		return true;
	else
		return false;
	end
end

--
-- 이전 무기로 자동 복귀
--
function BSOP_BM_ToggleNoRestore()
	BSOP_ToggleNoRestore("제압");
end

function BSOP_BM_NoRestoreCheck()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return false;
	end
	if( sets.norestore ~= 1 )then
		return true;
	else
		return false;
	end
end

--
-- 제압용 무기저장
--
function BSOP_BM_SaveSwapOverpower()
	BSOP_SaveSwapSet("제압");
end

--
-- 설정된 제압용 무기
--
function BSOP_BM_OverpowerCheck()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return false;
	end
	if( sets.use == 1 )then
		return true;
	else
		return false;
	end
end

function BSOP_BM_SwapOverpowerClick()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return;
	end
	if ( sets.use ~= 1) then
		return;
	end
	BlinkSwapExecute( sets.main.id, sets.off.id );
end

function BSOP_BM_SwapOverpowerName()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return "제압용 : 미설정";
	end
	local m = sets.main.name or "";
	local s = sets.off.name or "";
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
	return "제압용 : "..ms;
end

function BSOP_BM_SwapOverpowerCheck()
	local sets = BSOP_GetSet("제압");
	if ( not sets ) then
		return false;
	else
		local m = sets.main.name or "";
		local s = sets.off.name or "";
		local mid = sets.main.id or "";
		local sid = sets.off.id or "";
		local cm,cmid = BlinkSwap_GetItemName(-1, 16);
		local cs,csid = BlinkSwap_GetItemName(-1, 17);
		if ( cm == m and cmid == mid and cs == s and csid == sid ) then
			return true;
		else
			return false;
		end
	end
end

function BSOP_BM_SwapOverpowerShow()
	if ( BSOP_BM_OverpowerShow() == false ) then
		return false;
	end
	return BSOP_BM_OverpowerCheck();
end

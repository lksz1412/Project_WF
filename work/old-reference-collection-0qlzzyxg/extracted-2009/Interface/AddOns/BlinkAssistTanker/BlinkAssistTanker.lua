-------------------------------------------------------------------------------
--
--  Mod Name : Blink Assist Tanker v2.5
--  Author   : Blink
--  Date     : 2004/10/11
--  LastUpdate : 2009/08/11
--
-------------------------------------------------------------------------------

BAT_TANKER_NAME = ""

local needResetTanker = false
local tempSaved = ""
local frame
local needBindUpdate = false

local function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local function getFrame()
	if ( frame ) then
		return frame
	end
	frame = CreateFrame("Button", "BATButton", UIParent, "SecureActionButtonTemplate")
	frame:SetAttribute("type1", "macro")
	frame:SetAttribute("type2", "macro")
	frame:RegisterForClicks("LeftButtonUp","RightButtonUp")
	frame:Hide()
	return frame
end

local function setName(name)
	local f = getFrame()
	f:SetAttribute("macrotext1","/assist "..name)
	f:SetAttribute("macrotext2","/target "..name)
end

--/script BlinkPrint(BAT_ViewCurrent())
function BAT_ViewCurrent()
	if frame then
		print(frame:GetAttribute("macrotext1"))
		print(frame:GetAttribute("macrotext2"))
	end
end

local function unsetName()
	local f = getFrame()
	f:SetAttribute("macrotext1","/assist target")
	f:SetAttribute("macrotext2","")
end

function SetTanker(name)
	if not InCombatLockdown() then
		if ( name == "focus" ) then
			setName("focus")
			BAT_TANKER_NAME = "focus"
			print(string.format(SET_TANKER_TEXT_SUCCESS_FOCUS,UnitName("focus")))
		elseif ( name == "pet" ) then
			setName("pet")
			BAT_TANKER_NAME = "pet"
			print(SET_TANKER_TEXT_SUCCESS_PET)
		else
			setName(name)
			BAT_TANKER_NAME = name
			print(string.format(SET_TANKER_TEXT_SUCCESS,name))
		end
		needResetTanker = false
		tempSaved = name
	else
		print(BAT_MSG_CANT_SET_TANKER)
		needResetTanker = true
		tempSaved = name
	end
end

function UnsetTanker()
	if not InCombatLockdown() then
		unsetName()
		BAT_TANKER_NAME = ""
		print(BAT_MSG_UNSET_TANKER)
		needResetTanker = false
		tempSaved = ""
		return true
	else
		print(BAT_MSG_CANT_SET_TANKER)
		needResetTanker = true
		tempSaved = ""
		return false
	end
end

-- slash command
SLASH_SET_TANKER1 = "/settanker"
SLASH_SET_TANKER2 = "/st"
SLASH_SET_TANKER3 = "/탱커설정"
SlashCmdList["SET_TANKER"] = function(msg)
	if ( UnitExists("target") ) then
		if ( UnitIsUnit("target","focus") ) then
			SetTanker("focus")
			return
		elseif ( UnitIsUnit("target","pet") ) then
			SetTanker("pet")
			return
		else
			SetTanker(UnitName("target"))
			return
		end
	end
	if ( UnitExists("focus") ) then
		SetTanker("focus")
		return
	end
	if ( UnitExists("pet") ) then
		SetTanker("pet")
		return
	end
	print(BAT_MSG_INVALID_UNIT)
end

SLASH_UNSET_TANKER1 = "/unsettanker"
SLASH_UNSET_TANKER2 = "/ust"
SLASH_UNSET_TANKER3 = "/탱커해제"
SlashCmdList["UNSET_TANKER"] = function(msg)
	UnsetTanker()
end

function BAT_UpdateBinding()
	local bindButton = getFrame()
	local bindKeys = { GetBindingKey("ASSISTTANKER") }
	for i, keystr in ipairs(bindKeys) do
		if (keystr ~= "") then
			SetOverrideBindingClick(bindButton, true, keystr, bindButton:GetName(),"LeftButton")
		end
	end
	bindKeys = { GetBindingKey("TARGETTANKER") }
	for i, keystr in ipairs(bindKeys) do
		if (keystr ~= "") then
			SetOverrideBindingClick(bindButton, true, keystr, bindButton:GetName(),"RightButton")
		end
	end
end

-- event routine
local evFrame = CreateFrame("Frame",nil,nil)
evFrame:SetScript("OnEvent", function (self,event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		BAT_BM_Register()
		unsetName()
	elseif ( event == "UPDATE_BINDINGS" ) then
		if not InCombatLockdown() then
			BAT_UpdateBinding()
		else
			needBindUpdate = true -- 키바인딩 예약
		end
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		if ( BAT_TANKER_NAME == "focus" ) then
			if ( UnitExists("focus") ) then
				print(BAT_MSG_FOCUSUNIT_CHANGED)
			else
				print(BAT_MSG_FOCUSUNIT_DISAPPEAR)
				UnsetTanker()
			end
		end
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" ) then
		if ( needResetTanker ) then
			if ( tempSaved == "" ) then
				UnsetTanker()
			else
				SetTanker(tempSaved)
			end
		end
		if needBindUpdate then -- 키바인딩 적용
			BAT_UpdateBinding()
			needBindUpdate = false
		end
	end
end)
evFrame:RegisterEvent("UPDATE_BINDINGS")
evFrame:RegisterEvent("VARIABLES_LOADED")
evFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
evFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
evFrame:RegisterEvent("PLAYER_ENTERING_WORLD")


-------------------------------------------------------------------------------
function BAT_BM_Register()
	if ( not BlinkMod_RegisterMenu ) then
		return
	end
	local info

	-- tier 2 : parent = SELF
	info = {}
	info.parentkey = "SELF"
	info.key = "BATUNSET"
	info.text = UNSET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_UNSET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_UnsetTankerClick
	info.GetNameFunction = BAT_BM_UnsetTankerName
	info.ShowHideFunction = BAT_BM_UnsetTankerShow
	BlinkMod_RegisterMenu( info, 1 )

	info = {}
	info.parentkey = "SELF"
	info.key = "BATSETFOCUS"
	info.text = SET_TANKER_FOCUS
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER_FOCUS
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerFocusClick
	info.ShowHideFunction = BAT_BM_SetTankerFocusShow
	BlinkMod_RegisterMenu( info, 1 )

	-- parent = FRIEND
	info = {}
	info.parentkey = "FRIEND"
	info.key = "BATSETFRIEND"
	info.text = SET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerClick
	info.ShowHideFunction = BAT_BM_SetTankerShow
	BlinkMod_RegisterMenu( info, 1 )

	-- parent = PLAYER
	info = {}
	info.parentkey = "PLAYER"
	info.key = "BATSETPLAYER"
	info.text = SET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerClick
	info.ShowHideFunction = BAT_BM_SetTankerShow
	BlinkMod_RegisterMenu( info, 1 )

	-- parent = PET
	info = {}
	info.parentkey = "PET"
	info.key = "BATSETPET"
	info.text = SET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerPETClick
	info.ShowHideFunction = BAT_BM_SetTankerShow
	BlinkMod_RegisterMenu( info, 1 )

	-- parent = PARTY
	info = {}
	info.parentkey = "PARTY"
	info.key = "BATSETPARTY"
	info.text = SET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerClick
	info.ShowHideFunction = BAT_BM_SetTankerShow
	BlinkMod_RegisterMenu( info, 1 )

	-- parent = RAID_PLAYER
	info = {}
	info.parentkey = "RAID_PLAYER"
	info.key = "BATSETRAID"
	info.text = SET_TANKER
	info.tooltipText = BAT_TOOLTIP_UNIT_SET_TANKER
	info.notCheckable = 1
	info.ClickFunction = BAT_BM_SetTankerClick
	info.ShowHideFunction = BAT_BM_SetTankerShow
	BlinkMod_RegisterMenu( info, 1 )
end
-------------------------------------------------------------------------------
function BAT_BM_UnsetTankerClick()
	UnsetTanker()
end
function BAT_BM_UnsetTankerName()
	if ( BAT_TANKER_NAME and BAT_TANKER_NAME~="" ) then
		if( BAT_TANKER_NAME == "pet" )then
			return UNSET_TANKER .. " : " .. PET
		elseif ( BAT_TANKER_NAME == "focus" ) then
			return UNSET_TANKER .. " : " .. UnitName(BAT_TANKER_NAME).."(주시대상)"
		else
			return UNSET_TANKER .. " : " .. BAT_TANKER_NAME
		end
	else
		return UNSET_TANKER
	end
end
function BAT_BM_UnsetTankerShow()
	if ( BAT_TANKER_NAME and BAT_TANKER_NAME~="" ) then
		return true
	else
		return false
	end
end
-------------------------------------------------------------------------------
function BAT_BM_SetTankerFocusClick()
	if ( UnitExists("focus") ) then
		SetTanker("focus")
	else
		print(BAT_MSG_NOT_FOUND_FOCUS_UNIT)
	end
end

function BAT_BM_SetTankerFocusShow( dropdownMenu )
	if ( UnitExists("focus") and BAT_TANKER_NAME~="focus" ) then
		return true
	end
	return false
end
-------------------------------------------------------------------------------
function BAT_BM_SetTankerClick( dropdownFrame )
	if ( dropdownFrame.unit ) then
		if ( dropdownFrame.unit == "focus" ) then
			SetTanker("focus")
		elseif ( dropdownFrame.unit == "pet" ) then
			SetTanker("pet")
		else
			SetTanker(UnitName(dropdownFrame.unit))
		end
	elseif ( dropdownFrame.name ) then
		SetTanker(dropdownFrame.name)
	end
end

function BAT_BM_SetTankerPETClick( useless )
	SetTanker("pet")
end

function BAT_BM_SetTankerShow( dropdownMenu )
	if ( BAT_TANKER_NAME and BAT_TANKER_NAME~="" ) then
		if ( dropdownMenu.which == "PET" and BAT_TANKER_NAME == "pet" ) then
			return false
		elseif ( dropdownMenu.unit and BAT_TANKER_NAME == UnitName(dropdownMenu.unit) ) then
			return false
		elseif ( dropdownMenu.unit and BAT_TANKER_NAME == "focus" and UnitIsUnit(dropdownMenu.unit,"focus") ) then
			return false
		elseif ( dropdownMenu.name and BAT_TANKER_NAME == dropdownMenu.name ) then
			return false
		end
	end
	return true
end

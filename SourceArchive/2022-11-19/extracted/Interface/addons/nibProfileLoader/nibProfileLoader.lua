local frame = CreateFrame("FRAME");
frame:RegisterEvent("VARIABLES_LOADED");

-- BEGIN USER OPTIONS --
-- InterfaceName = Name to describe your UI
-- ProfileName = Addon profile name to use with /reflux switch
local InterfaceName  = "Devil UI 10.0.2 하단집중형"
local ProfileName = "loaf"

local UseClassProfiles = false	-- Use specific profile names for different classes
local ClassProfiles = {			-- Change profile names to suit
	["DEATHKNIGHT"] = "MyProfile",
	["DRUID"] = "MyProfile",
	["HUNTER"] = "MyProfile",
	["MAGE"] = "MyProfile",
	["PALADIN"] = "MyProfile",
	["PRIEST"] = "MyProfile",
	["ROGUE"] = "MyProfile",
	["SHAMAN"] = "MyProfile",
	["WARLOCK"] = "MyProfile",
	["WARRIOR"] = "MyProfile",
}
-- END USER OPTIONS --

local LocalizedMessages = {
	["enUS"] = {
		[1] = "New character detected! Do you wish to load the settings for %s?",
		[2] = "Yes",
		[3] = "No",
	},
	["koKR"] = {
		[1] = "새로운 캐릭터를 찾았습니다! %s 을 불러오시겠습니까?",
		[2] = "예",
		[3] = "아니오",
	},
}


local CID, CE, HasAdded = "", false, false

local function AddChar()
  if (CID ~= "") and not HasAdded then 
    tinsert(nibPLNames, CID)
	HasAdded = true
  end
end

local function CharAnswered(ans)
  AddChar()
  if ans then
	local _, class = UnitClass("player")
	local NewProfile = UseClassProfiles and ClassProfiles[class] or ProfileName
    local RefluxArg = string.format("%s %s", "switch", NewProfile)
    SlashCmdList.REFLUX(RefluxArg) -- This will cause a UI reload
  end
end

local function AskNewChar()
  local Locale = GetLocale() or "enUS"
  local MsgTexts = LocalizedMessages[Locale] or LocalizedMessages["enUS"]
  StaticPopupDialogs["PUDASKNEWCHAR"] = {
    text = MsgTexts[1],
    button1 = MsgTexts[2],
    button2 = MsgTexts[3],
    OnAccept = function()
      CharAnswered(true)
    end,
	OnCancel = function()
	  CharAnswered(false)
	end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
	notClosableByLogout = true,
  }
  StaticPopup_Show ("PUDASKNEWCHAR", InterfaceName);
end

local function CheckNewChar()
  CID = string.format("%s - %s", GetRealmName(), UnitName("player"))
  CE = false
  if (nibPLNames == nil) then nibPLNames = { }; end
  for i,v in pairs(nibPLNames) do
	if (v == CID) then CE = true; end
  end
  if not CE then AskNewChar(); end
end 

local function eventHandler(self, event, ...)
  if (event == "VARIABLES_LOADED") then
    CheckNewChar()
  end
end
frame:SetScript("OnEvent", eventHandler);
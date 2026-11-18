local MAJOR_VERSION = "LibRaidComm-1.0"
local MINOR_VERSION = 9

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

if not BluePrint then function BluePrint() end end

lib.EventFrame = lib.EventFrame or CreateFrame("Frame")
lib.EventFrame:SetScript("OnEvent", function(self, event, ...) lib[event](lib, ...) end)
lib.EventFrame:UnregisterAllEvents()
lib.EventFrame:RegisterEvent("PLAYER_LOGIN")
lib.EventFrame:RegisterEvent("CHAT_MSG_ADDON")

lib.Callbacks = LibStub("CallbackHandler-1.0"):New(lib)

local _G = _G
local tonumber, strmatch, strfind, gsub, format = _G.tonumber, _G.string.match, _G.string.find, _G.string.gsub, _G.format
local pairs, min, ceil, select, strlower, tconcat = _G.pairs, _G.math.min, _G.math.ceil, _G.select, _G.string.lower, _G.table.concat
local UnitName, UnitLevel, UnitClass, UnitRace, UnitSex, UnitStat = _G.UnitName, _G.UnitLevel, _G.UnitClass, _G.UnitRace, _G.UnitSex, _G.UnitStat
local SendAddonMessage, IsInInstance, GetRealmName, GetNumRaidMembers, GetNumPartyMembers = _G.SendAddonMessage, _G.IsInInstance, _G.GetRealmName, _G.GetNumRaidMembers, _G.GetNumPartyMembers
local IsRaidLeader, IsRaidOfficer, UnitIsPartyLeader = _G.IsRaidLeader, _G.IsRaidOfficer, _G.UnitIsPartyLeader
local GetNumTalents, GetTalentInfo, GetTalentLink, GetInventoryItemLink = _G.GetNumTalents, _G.GetTalentInfo, _G.GetTalentLink, _G.GetInventoryItemLink
local GetCombatRating, GetSpellBonusDamage, GetSpellCritChance, GetSpellInfo = _G.GetCombatRating, _G.GetSpellBonusDamage, _G.GetSpellCritChance, _G.GetSpellInfo
local playerName, playerFullName, playerClass, sendBusy, sendBusyPlayer, deny, playerMouseTarget
local libVersion, castingTarget, inspect, talent, prevRaid, prevParty = {}, {}, {}, {}, 0, 0
local delayer = GetTime()
local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12
local corpse = "^(.+)의 시체$"
local resurrectionSpell = { [GetSpellInfo(20777)] = true, [GetSpellInfo(25435)] = true, [GetSpellInfo(20773)] = true, [GetSpellInfo(50764)] = true, [GetSpellInfo(20484)] = true }

local function GetCommType()
	v1 = select(2, IsInInstance())
	if v1 == "arena" or v1 == "pvp" then
		if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 then
			return "BATTLEGROUND"
		else
			return nil
		end
	elseif GetNumRaidMembers() > 0 then
		return "RAID"
	elseif GetNumPartyMembers() > 0 then
		return "PARTY"
	else
		return "WHISPER"
	end
end

local function SendData(dbinfo, contents, whisper)
	if whisper then
		SendAddonMessage("LibRaidComm", dbinfo.."="..contents, "WHISPER", whisper)
	else
		v1 = GetCommType()
		if v1 then
			v2 = UnitName("player")..(v1 == "WHISPER" and "" or ("-"..GetRealmName()))
			SendAddonMessage("LibRaidComm", dbinfo.."="..contents, v1, v2)
		end
	end
end

function lib:PLAYER_LOGIN()
	playerName = UnitName("player")
	playerFullName = playerName.."-"..GetRealmName()
	playerClass = select(2, UnitClass("player"))
	lib.EventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
	lib.EventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	lib.EventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
	lib.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	lib.EventFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
	lib.EventFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
	WorldFrame:HookScript("OnMouseDown", function(self, button)
		if GameTooltip:IsShown() and GameTooltipTextLeft1:GetText() then
			playerMouseTarget = strmatch(GameTooltipTextLeft1:GetText(), corpse) or playerMouseTarget
		end
	end)
end

function lib:PLAYER_ENTERING_WORLD()
	lib.EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	lib:CreateOptionFrame()
end

function lib:CreateOptionFrame()
	local f = CreateFrame("Frame", "LibRaidCommOption", InterfaceOptionsFramePanelContainer)
	f.name = "인벤 전투정보실"
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	f.title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -16)
	f.title:SetText(f.name)
	f.subText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	f.subText:SetPoint("TOPLEFT", f.title, "TOPLEFT", 15, -40)
	f.subText:SetHeight(32)
	f.subText:SetJustifyH("LEFT")
	f.subText:SetJustifyV("TOP")
	f.subText:SetNonSpaceWrap(true)
	f.subText:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)
	f.subText:SetPoint("RIGHT", -32, 0)
	f.subText:SetText("LibRaidComm-1.0 라이브러리를 사용하여 다른 사람에게 사용자의 정보를 제공해주는 기능을 합니다. 정보 수집을 허용하지 않으면 인벤 전투정보실 애드온으로 타인의 정보도 확인할 수 없습니다.")
	f.option1 = CreateFrame("CheckButton", "LibRaidCommOption1", f, "InterfaceOptionsCheckButtonTemplate")
	f.option1:SetPoint("TOPLEFT", f.subText, "BOTTOMLEFT", -2, -8)
	LibRaidCommOption1Text:SetText("정보 수집 허용")
	if Blizzard_CombatLog_Filters then
		if Blizzard_CombatLog_Filters.InvenArmoryDenyInspect == nil then
			Blizzard_CombatLog_Filters.InvenArmoryDenyInspect = 0
		end
		if Blizzard_CombatLog_Filters.InvenArmoryDenyInspect == 0 then
			f.option1:SetChecked(true)
			deny = nil
		else
			f.option1:SetChecked(nil)
			deny = true
		end
	else
		f.option1:SetChecked(true)
		deny = nil
	end
	f.option1:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn")
			Blizzard_CombatLog_Filters.InvenArmoryDenyInspect = 0
			deny = nil
		else
			PlaySound("igMainMenuOptionCheckBoxOff")
			Blizzard_CombatLog_Filters.InvenArmoryDenyInspect = 1
			deny = true
		end
	end)
	InterfaceOptions_AddCategory(f)
end

function lib:PARTY_MEMBERS_CHANGED()
	if GetNumRaidMembers() > 0 then
		prevParty = 0
	elseif GetNumPartyMembers() > 0 then
		if prevParty == 0 then
			--SendData("CHECK", "LIBRARY")
		end
		prevParty = GetNumPartyMembers()
		prevRaid = 0
	else
		libVersion = {}
		castingTarget = {}
		prevParty = 0
		prevRaid = 0
	end
end

function lib:RAID_ROSTER_UPDATE()
	if GetNumRaidMembers() > 0 then
		if prevRaid == 0 then
			--SendData("CHECK", "LIBRARY")
		end
		prevRaid = GetNumRaidMembers()
		prevParty = 0
	elseif GetNumPartyMembers() > 0 then
		prevParty = 0
	else
		v1 = castingTarget[player]
		libVersion = {}
		castingTarget = {}
		castingTarget[playerName] = v1
		prevParty = 0
		prevRaid = 0
	end
end

function lib:PARTY_MEMBER_ENABLE(name)
	if name then
		SendData("ONLINE", name)
	end
end

function lib:PARTY_MEMBER_DISABLE(name)
	if name then
		SendData("OFFLINE", name)
	end
end

function lib:UNIT_SPELLCAST_SENT(unit, spellName, spellRank, target)
	if unit == "player" then
		if resurrectionSpell[spellName] and (target == nil or target == "무엇인가") and playerMouseTarget then
			target = playerMouseTarget
			playerMouseTarget = nil
		end
		if target and target ~= "" then
			if not strfind(target, "-") then
				target = target.."-"..GetRealmName()
			end
		else
			target = "*"
		end
		castingTarget[UnitName("player")] = target ~= "*" and target or nil
		SendData("CASTING", target)
	end
end

function lib:CHAT_MSG_ADDON(prefix, msg, distribution, sender)
	if prefix ~= "LibRaidComm" then return end
	sender = gsub(sender, "-"..GetRealmName(), "")
	if strfind(msg, "^CASTING=") then
		v1 = strmatch(msg, "^CASTING=(.+)")
		if v1 then
			v1 = gsub(v1, "-"..GetRealmName(), "")
			castingTarget[sender] = v1 ~= "*" and v1 or nil
		end
	elseif strfind(msg, "^ONLINE=(.+)") then
		self.Callbacks:Fire("LibRaidComm_OnLine", strmatch("^ONLINE=(.+)"))
	elseif strfind(msg, "^OFFLINE=") then
		self.Callbacks:Fire("LibRaidComm_OffLine", strmatch("^OFFLINE=(.+)"))
	elseif msg == "CHECK=LIBRARY" then
		SendData("LIBRARY", MINOR_VERSION)
	elseif strfind(msg, "^LIBRARY:") then
		libVersion[sender] = tonumber(strmatch(msg, "^LIBRARY=(%d+)") or 0)
		self.Callbacks:Fire("LibRaidComm_Library", libVersion[sender])
	end
	if distribution ~= "WHISPER" then return end
	if msg == "IM=DENY" then
		self.Callbacks:Fire("LibRaidComm_Deny", sender)
	elseif msg == "IM=BUSY" then
		self.Callbacks:Fire("LibRaidComm_Busy", sender)
	elseif msg == "CHECK=USING" then
		SendData("RCVERSION", MINOR_VERSION, sender)
	elseif strfind(msg, "RCVERSION=") then
		self.Callbacks:Fire("LibRaidComm_Using", sender, tonumber(strmatch(msg, "^RCVERSION=(%d+)")))
	elseif msg == "CHECK=INFO" then
		--if sendBusy then return end
		SendData("INFO", UnitLevel("player").."#"..UnitClass("player").."#"..UnitRace("player").."#"..UnitSex("player"), sender)
	elseif strfind(msg, "^INFO=") then
		-- 레벨, 직업, 종족, 성별
		v1, v2, v3, v4 = strmatch(msg, "^INFO=(.+)#(.+)#(.+)#(.+)")
		self.Callbacks:Fire("LibRaidComm_Info", sender, tonumber(v1), v2, v3, v4 == "2" and "남자" or "여자")
	elseif msg == "CHECK=INSPECT" then
		if delayer <= GetTime() then
			sendBusy = nil
			sendBusyPlayer = {}
			delayer = GetTime() + 2
			if deny then
				SendData("IM", "DENY", sender)
			else
				for i = 1, 19 do
					SendData("INSPECT", i.."_"..(GetInventoryItemLink("player", i) or "*"), sender)
				end
			end
		else
			sendBusy = true
			--SendData("IM", "BUSY", sender)
		end
	elseif strfind(msg, "^INSPECT=") then
		v1, v2 = strmatch(msg, "^INSPECT=(%d+)_(.+)")
		if v1 and v2 then
			v1 = tonumber(v1)
			if v1 == 1 then
				inspect[sender] = {}
			end
			inspect[sender][v1] = v2
			if v1 == 19 then
				self.Callbacks:Fire("LibRaidComm_InspectCheck", sender, inspect[sender])
				inspect[sender] = nil
			end
		end
	elseif msg == "CHECK=NEWTALENT" then
		--if sendBusy then return end
		if UnitLevel("player") < 11 then return end
		v1 = UnitClass("player")
		for i = 1, 3 do
			v2 = ""
			v3 = GetNumTalents(i)
			for j = 1, v3 do
				v2 = v2..select(5, GetTalentInfo(i, j))
			end
			v1 = v1.."#"..v2
		end
		SendData("NEWTALENT", v1, sender)
	elseif strfind(msg, "^NEWTALENT=") then
		self.Callbacks:Fire("LibRaidComm_Talent", sender, strmatch(msg, "^NEWTALENT=(.+)"))
	elseif msg == "CHECK=STAT" then
		--if sendBusy then return end
		v9 = format("%d#%d#%d#%d#%d#%d#%d#%d", UnitHealthMax("player"), UnitManaMax("player"), select(2, UnitStat("player", 1)), select(2, UnitStat("player", 2)), select(2, UnitStat("player", 3)), select(2, UnitStat("player", 4)), select(2, UnitStat("player", 5)), select(2, UnitArmor("player")))
		v1, v2 = UnitDamage("player")
		v9 = v9.."#"..format("%d-%d", v1, ceil(v2))
		v1, v2 = UnitAttackSpeed("player")
		v9 = v9.."#"..(v2 and format("%.2f/%.2f", v1, v2) or format("%.2f", v1))
		v1, v2, v3 = UnitAttackPower("player")
		v9 = v9.."#"..(v1 + v2 + v3)
		v9 = v9.."#"..GetCombatRating(6).."#"..format("%.2f%%", GetCritChance())
		v1, v2 = GetExpertise()
		v9 = v9.."#"..(v2 and v1 ~= v2 and (v1.."/"..v2) or v1)
		v1, v2, v3 = UnitRangedDamage("player")
		if v1 == 0 then
			v9 = v9.."#-#-"
		else
			v9 = v9..format("#%d-%d#%.2f", v2, ceil(v3), v1)
		end
		v1, v2, v3 = UnitRangedAttackPower("player")
		v9 = v9..format("#%d#%d#%.2f%%", v1 + v2 + v3, GetCombatRating(7), GetRangedCritChance())
		if playerClass == "ROGUE" or playerClass == "WARRIOR" then
			v9 = v9.."#-#-#-#-#-#-"
		else
			v1 = GetSpellBonusDamage(2)
			for i = 3, 7 do
				v1 = min(v1, GetSpellBonusDamage(i))
			end
			v9 = v9..format("#%d#%d#%d", v1, GetSpellBonusHealing(), GetCombatRating(8))
			v1 = GetSpellCritChance(2)
			for i = 3, 7 do
				v1 = min(v1, GetSpellCritChance(i))
			end
			v9 = v9..format("#%.2f%%#%d#%d", v1, GetCombatRating(20), GetManaRegen() * 5)
		end
		v1, v2 = UnitDefense("player")
		v9 = v9..format("#%d#%d#%.2f%%#%.2f%%#%.2f%%", select(2, UnitArmor("player")), v1 + v2, GetDodgeChance(), GetParryChance(), GetBlockChance())
		v1 = min(GetCombatRating(15), GetCombatRating(16))
		v1 = min(v1, GetCombatRating(17))
		v9 = v9.."#"..v1
		SendData("STAT", v9, sender)
	elseif strfind(msg, "^STAT=") then
		-- 생명력#마나#힘#민#체#지#정#방어도#최소데미지-최대데미지#공격속도/공격속도#전투력#적중도#치명타율#숙련/숙련#원거리공격력-공격력#원속도#원전투력#원적중도#원치명타#증뎀#치증#주문적중#극대#주문가속#마나회복#방어도#방숙#회피#무막#방막#탄력
		self.Callbacks:Fire("LibRaidComm_Stat", sender, strsplit("#", strmatch(msg, "^STAT=(.+)")))
	end
end

function lib:GetCastingTarget(caster)
	return castingTarget[caster]
end

function lib:GetVersion(name)
	return libVersion[name]
end

function lib:Checkable(name)
	if name then
		SendData("CHECK", "USING", name)
	end
end

function lib:Inspect(name)
	if name then
		SendData("CHECK", "INSPECT", name)
	end
end

function lib:Talent(name)
	if name then
		SendData("CHECK", "NEWTALENT", name)
	end
end

function lib:Stat(name)
	if name then
		SendData("CHECK", "STAT", name)
	end
end

function lib:Info(name)
	if name then
		SendData("CHECK", "INFO", name)
	end
end

function lib:IsDeny()
	return deny
end

function lib:IsGroupLeader()
	if GetNumRaidMembers() > 0 then
		if IsRaidLeader() or IsRaidOfficer() then
			return true
		end
	elseif GetNumPartyMembers() > 0 and UnitIsPartyLeader("player") then
		return true
	end
	return false
end

if IsLoggedIn() then
	lib:PLAYER_LOGIN()
end
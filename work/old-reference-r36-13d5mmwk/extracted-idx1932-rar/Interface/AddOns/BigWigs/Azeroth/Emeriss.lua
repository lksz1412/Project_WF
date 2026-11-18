------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Emeriss"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local pName = UnitName("player")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Emeriss",

	engage = "Engage Alert",
	engage_desc = ("Warn when %s is engaged"):format(boss),
	engage_message = "%s Engaged! - Noxious Breath every ~10sec",
	engage_trigger = "Hope is a DISEASE of the soul! This land shall wither and die!",

	corruption = "Corruption",
	corruption_desc = "Warn for incoming Corruption of the Earth.",
	corruption_trigger = "Taste your world's corruption!",
	corruption_message = "Incoming Corruption of the Earth!",

	noxious = "Noxious breath alert",
	noxious_desc = "Warn for noxious breath.",
	noxious_bar = "~Next Noxious Breath",

	volatileyou = "Volatile infection on you alert",
	volatileyou_desc = "Warn for volatile infection on you.",
	volatile_you = "You have Volatile Infection!",

	volatileother = "Volatile infection on others alert",
	volatileother_desc = "Warn for volatile infection on others.",
	volatile_other = "Volatile Infection on %s",

	icon = "Place Icon",
	icon_desc = "Place a Raid Icon on the person with Volatile Infection(requires promoted or higher).",
} end )

L:RegisterTranslations("frFR", function() return {
	engage = "Engagement",
	engage_desc = ("Préviens quand %s est engagé."):format(boss),
	engage_message = "%s engagé ! - Souffle nauséabond toutes les ~10 sec.",
	engage_trigger = "L'espoir est une MALADIE de l'âme ! Ces terres vont flétrir et mourir !",

	corruption = "Corruption",
	corruption_desc = "Préviens de l'arrivée des Corruptions de la Terre.",
	corruption_trigger = "Goûtez la corruption de votre monde !", -- à vérifier
	corruption_message = "Arrivée de la Corruption de la Terre !",

	noxious = "Souffle nauséabond",
	noxious_desc = "Préviens de l'arrivée des Souffles nauséabonds.",
	noxious_bar = "~Prochain Souffle",

	volatileyou = "Infection volatile sur vous",
	volatileyou_desc = "Préviens quand vous subissez les effets de l'Infection volatile.",
	volatile_you = "Infection volatile sur VOUS !",

	volatileother = "Infection volatile sur les autres",
	volatileother_desc = "Préviens quand un autre joueur subit les effets de l'Infection volatile.",
	volatile_other = "Infection volatile sur %s !",

	icon = "Icône",
	icon_desc = "Place une icône de raid sur le dernier joueur affecté par l'Infection volatile (nécessite d'être promu ou mieux).",
} end )

L:RegisterTranslations("deDE", function() return {
	noxious = "Giftiger Atem",
	noxious_desc = "Warnung vor Giftiger Atem.",

	volatileyou = "Fl\195\188chtige Infektion",
	volatileyou_desc = "Warnung, wenn Fl\195\188chtige Infektion auf Dir.",
	volatile_you = "Du bist von Fl\195\188chtige Infektion betroffen!",

	volatileother = "Fl\195\188chtige Infektion auf Anderen",
	volatileother_desc = "Warnung, wenn Fl\195\188chtige Infektion auf anderen Spielern.",
	volatile_other = "%s ist von Fl\195\188chtiger Infektion betroffen!",
} end )

L:RegisterTranslations("zhCN", function() return {
	engage = "激活警报",
	engage_desc = ("当%s激活时发出警报"):format(boss),
	engage_message = "%s 激活！ - 毒性吐息将在~10秒后发动",
	engage_trigger = "希望是灵魂染上的疾病！这片土地应该枯竭，从此死气腾腾！",

	corruption = "堕落",
	corruption_desc = "当进入大地的堕落状态发出警报",--大地的堕落
	corruption_trigger = "尝尝堕落的滋味吧！",
	corruption_message = "沉睡之雾来临！",

	noxious = "毒性吐息警报",
	noxious_desc = "毒性吐息警报",
	noxious_bar = "~毒性吐息 下次发动",

	volatileyou = "玩家快速传染警报",
	volatileyou_desc = "你中了快速传染时发出警报",
	volatile_you = "你中了快速传染！",

	volatileother = "队友快速传染警报",
	volatileother_desc = "队友中了快速传染时发出警报",
	volatile_other = "%s中了快速传染！",

	icon = "添加标记",
	icon_desc = "向受到感染的队员打上团队标记(需要助手A或者团长L权限)",
} end )

L:RegisterTranslations("zhTW", function() return {
	noxious = "毒性吐息警報",
	noxious_desc = "毒性吐息警報",
	noxious_bar = "毒性吐息",

	volatileyou = "玩家快速傳染警報",
	volatileyou_desc = "你中了快速傳染時發出警報",
	volatile_you = "你中了快速傳染！",

	volatileother = "隊友快速傳染警報",
	volatileother_desc = "隊友中了快速傳染時發出警報",
	volatile_other = "%s中了快速傳染！",
} end )

L:RegisterTranslations("koKR", function() return {
	engage = "전투 시작 알림",
	engage_desc = ("%s 전투 시작 시 알림"):format(boss),
	engage_message = "%s 광폭화! - 약 10초 마다 산성 숨결",
	engage_trigger = "희망은 영혼의 병! 이 땅은 말라 죽을 것이다!",

	corruption = "부패",
	corruption_desc = "대지의 부패에 대한 경고입니다.",
	corruption_trigger = "너희의 타락한 세상을 맛 보아라!",
	corruption_message = "잠시 후 대지의 부패!",

	noxious = "산성 숨결 경고",
	noxious_desc = "산성 숨결에 대한 경고",
	noxious_bar = "~다음 산성 숨결",

	volatileyou = "자신의 대지의 오염 경고",
	volatileyou_desc = "자신의 대지의 오염에 대한 경고",
	volatile_you = "당신에 대지의 오염!",

	volatileother = "타인의 대지의 오염 경고",
	volatileother_desc = "타인의 대지의 오염에 대한 경고",
	volatile_other = "%s에 대지의 오염",

	icon = "전술 표시",
	icon_desc = "대지의 오염에 걸린 사람에게 전술 표시를 지정합니다. (승급자 이상 요구)",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = {BZ["Ashenvale"], BZ["Duskwood"], BZ["The Hinterlands"], BZ["Feralas"]}
mod.otherMenu = "Azeroth"
mod.enabletrigger = boss
mod.toggleoptions = {"engage", "corruption", -1, "noxious", -1, "volatileyou", "volatileother", "icon", "bosskill"}
mod.revision = tonumber(("$Revision: 179 $"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddSyncListener("SPELL_MISSED", 24818, "EmeNox")
	self:AddSyncListener("SPELL_AURA_APPLIED", 24818, "EmeNox")
	self:AddSyncListener("SPELL_AURA_APPLIED", 24928, 43586, 3584, 18149, 3586, "EmeVola", 1)

	self:AddCombatListener("SPELL_AURA_APPLIED", "GetId", 24928, 43586, 3584, 18149, 3586) --XXX temp
	self:AddCombatListener("UNIT_DIED", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:RegisterEvent("BigWigs_RecvSync")
	self:Throttle(2, "EmeVola")
	self:Throttle(7, "EmeNox")
end

------------------------------
--      Event Handlers      --
------------------------------

local temp = true
function mod:GetId(_, spellID)
	if temp then
		BigWigs:Print("Debug: Report this on BigWigs forums >"..spellID)
		temp = nil
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if self.db.profile.engage and msg == L["engage_trigger"] then
		self:Message(L["engage_message"]:format(boss), "Attention")
		self:Bar(L["noxious_bar"], 10, 24818)
	elseif self.db.profile.corruption and msg == L["corruption_trigger"] then
		self:Message(L["corruption_message"], "Urgent")
		self:Bar(L["corruption"], 10, "Ability_Creature_Cursed_03")
	end
end

function mod:BigWigs_RecvSync(sync, rest, nick)
	if sync == "EmeVola" and rest then
		local other = L["volatile_other"]:format(rest)
		if self.db.profile.volatileyou and rest == pName then
			self:LocalMessage(L["volatile_you"], "Personal", 24928) --icon?
			self:WideMessage(other)
		elseif self.db.profile.volatileother then
			self:IfMessage(other, "Attention", 24928)
			self:Whisper(rest, L["volatile_you"])
		end
		self:Icon(rest, "icon")
	elseif sync == "EmeNox" and self.db.profile.noxious then
		self:Bar(L["noxious_bar"], 10, 24818)
	end
end


------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Hakkar"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local L2 = AceLibrary("AceLocale-2.2"):new("BigWigsCommonWords")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Hakkar",

	engage_trigger = "FACE THE WRATH OF THE SOULFLAYER!",
	flee = "Fleeing will do you no good, mortals!",

	drain = "Drain Alerts",
	drain_desc = "Warn for Drains",
	drain_trigger = "^Hakkar suffers (.+) from (.+) Blood Siphon",
	drain_warning = "%d sec to Life Drain!",
	drain_message = "Life Drain - 90 sec to next!",
	drain_bar = "Life Drain",

	enrage = "Enrage Alerts",
	enrage_desc = "Warn for Enrage",

	mc = "Mind Control",
	mc_desc = "Alert when someone is mind controlled.",
	mindcontrol_trigger = "^([^%s]+) ([^%s]+) afflicted by Cause Insanity.$",
	mindcontrol_message = "%s is mindcontrolled!",
	mindcontrol_bar = "MC: %s",

	icon = "Raid Icon",
	icon_desc = "Place a raid icon on the mind controlled person (requires promoted or higher)",
} end)

L:RegisterTranslations("deDE", function() return {
	engage_trigger = "^EURE \195\156BERHEBLICHKEIT K\195\156NDET BEREITS VOM ENDE DIESER WELT!",
	drain_trigger = "^Hakkar erleidet (.+) Naturschaden von (.+) %(durch Bluttrinker%).",
	mindcontrol_trigger = "(.*) (.*) von Wahnsinn verursachen betroffen.",

	flee = "Es ist sinnlos zu fl\195\188chten, Sterbliche!",

	drain_warning = "Bluttrinker in %d Sekunden!",
	drain_message = "Bluttrinker! N\195\164chster in 90 Sekunden!",
	drain_bar = "Bluttrinker",

	mindcontrol_message = "%s steht unter Gedankenkontrolle!",
	mindcontrol_bar = "MC: %s",

	drain = "Bluttrinker",
	drain_desc = "Warnung, wenn Hakkar Bluttrinker wirkt.",

	enrage = "Wutanfall",
	enrage_desc = "Warnung, wenn Hakkar w\195\188tend wird.",

	mc = "Gedankenkontrolle",
	mc_desc = "Warnung wenn jemand unter Gedankenkontrolle steht.",

	icon = "Symbol",
	icon_desc = "Platziert ein Symbol \195\188ber dem Spieler, der unter Gedankenkontrolle steht. (Ben\195\182tigt Anf\195\188hrer oder Bef\195\182rdert Status.)",
} end)

L:RegisterTranslations("frFR", function() return {
	-- Chat message triggers
	engage_trigger = "ANNONCE LA FIN DE VOTRE MONDE",
	drain_trigger = "^Siphon de sang .+ (.+) inflige \195\160 Hakkar (.+).",
	mindcontrol_trigger = "(.*) (.*) les effets de Rendre fou.",

	flee = "Fuir ne vous servira \195\160 rien, mortels !",

-- Warnings and bar texts
	drain_warning = "%d sec. avant le Drain de vie !",
	drain_message = "Drain de vie - 90 sec. avant le prochain !",
	drain_bar = "Drain de vie",

	mindcontrol_message = "%s est devenu fou !",
	mindcontrol_bar = "CM: %s",

	drain = "Alerte Drain",
	drain_desc = "Pr\195\169viens quand Hakkar fait ses drains de vie.",

	enrage = "Alerte Enrager",
	enrage_desc = "Pr\195\169viens quand Hakkar devient enrag\195\169.",

	mc = "Alerte Contr\195\180le Mental",
	mc_desc = "Pr\195\169viens quand quelqu'un est sous le contr\195\180le d'Hakkar.",

	icon = "Placer une ic\195\180ne",
	icon_desc = "Place une ic\195\180ne de raid sur la personne sous contr\195\180le mental (n\195\169cessite d'\195\170tre promu ou mieux).",
} end)

L:RegisterTranslations("koKR", function() return {
	engage_trigger = "자만심은 세상의 종말을 불러올 뿐이다. 오너라! 건방진 피조물들이여! 와서 신의 진노에 맞서 보아라!",
	flee = "도망쳐 봐야 소용없다, 어리석은 생명체여!",

	drain = "흡수 경고",
	drain_desc = "흡수에 대한 경고",
	drain_trigger = "학카르|1이;가; (.+)의 피의 착취에 의해 (.+)의 자연 피해를 입었습니다.",
	drain_warning = "생명력 흡수 %d초전",
	drain_message = "생명력 흡수 - 다음 시전은 90초후",
	drain_bar = "생명력 흡수",


	drain = "흡수 경고",
	drain_desc = "흡수에 대한 경고",

	enrage = "격노 경고",
	enrage_desc = "격노에 대한 경고",

	mc = "정신 지배",
	mc_desc = "정신 지배 되었을 때 경고",
	mindcontrol_trigger = "^([^|;%s]*)(.*)정신 착란에 걸렸습니다%.$",
	mindcontrol_message = "%s|1이;가; 정신 지배되었습니다!",
	mindcontrol_bar = "정신지배: %s",

	icon = "공격대 아이콘",
	icon_desc = "정신 지배된 사람에게 공격대 아이콘 지정 (승급자 이상 필요)",
} end)


--Chinese Translate by 月色狼影@CWDG
--CWDG site: http://Cwowaddon.com
L:RegisterTranslations("zhCN", function() return {
	engage_trigger = "^骄傲会将你送上绝路",
	flee = "逃跑",
	
	drain = "生命吸取警报",
	drain_desc = "生命吸取警报",
	drain_trigger = "^(.+)的酸性血液虹吸使哈卡受到了(.+)",
	drain_warning = "%d秒后发动生命吸取！",
	drain_message = "血液虹吸 - 90秒后再次发动",
	drain_bar = "生命吸取",
	
	enrage = "激怒警报",
	enrage_desc = "激怒警报",
	
	mc = "精神控制警报",
	mc_desc = "哈卡使用精神控制时警报。",
	mindcontrol_trigger = "^(.+)受(.+)了疯狂效果的影响",
	mindcontrol_message = "%s 被控制了",
	mindcontrol_bar = "精神控制: %s",
	
	icon = "标记精神控制",
	icon_desc = "团队标记被精神控制者 (需要助力或更高权限)",
} end)

L:RegisterTranslations("zhTW", function() return {
	-- Chat message triggers
	engage_trigger = "^驕傲會將你送上絕路",
	drain_trigger = "^(.+)的血液虹吸使哈卡受到了(.+)點自然傷害。$",
	mindcontrol_trigger = "^(.+)受到(.*)導致瘋狂",

	flee = "逃跑",

	-- Warnings and bar texts
	drain_warning = "%d 秒後開始生命吸取",
	drain_message = "血液虹吸 - 90秒後再次發動",
	drain_bar = "血液虹吸",

	mindcontrol_message = "%s 被控制了，法師快羊",
	mindcontrol_bar = "MC: %s",

	drain = "血液虹吸警報",
	drain_desc = "血液虹吸警報",

	enrage = "狂怒警報",
	enrage_desc = "狂怒警報",

	mc = "精神控制警報",
	mc_desc = "哈卡使用精神控制時警報。",

	icon = "標記被精神控制的隊友",
	icon_desc = "在被精神控制的隊友頭上設置標記 (需要助手或領隊權限)",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = BZ["Zul'Gurub"]
mod.enabletrigger = boss
mod.toggleoptions = {"drain", "enrage", -1, "mc", "icon", "bosskill"}
mod.revision = tonumber(("$Revision: 154 $"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self.prior = nil
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("BigWigs_Message")
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:find(L["engage_trigger"]) then
		if self.db.profile.drain then
			self:BeginTimers(true)
		end
		if self.db.profile.enrage then
			self:Message(L2["enrage_start"]:format(boss, 10), "Attention")
			self:DelayedMessage(300, L2["enrage_min"]:format(5), "Positive")
			self:DelayedMessage(420, L2["enrage_min"]:format(3), "Positive")
			self:DelayedMessage(540, L2["enrage_min"]:format(1), "Positive")
			self:DelayedMessage(570, L2["enrage_sec"]:format(30), "Positive")
			self:DelayedMessage(590, L2["enrage_sec"]:format(10), "Urgent")
			self:DelayedMessage(595, L2["enrage_sec"]:format(5), "Urgent")
			self:DelayedMessage(600, L2["enrage_end"]:format(boss), "Attention", nil, "Alarm")
			self:Bar(L2["enrage"], 600, "Spell_Shadow_UnholyFrenzy")
		end
	elseif msg:find(L["flee"]) then
		self:TriggerEvent("BigWigs_RebootModule", self)
	end
end

function mod:CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE(msg)
	if not self.prior and msg:find(L["drain_trigger"]) then
		self.prior = true
		self:BeginTimers()
	end
end

function mod:CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE(msg)
	local mcplayer, mctype = select(3, msg:find(L["mindcontrol_trigger"]))
	if mcplayer and mctype then
		if mcplayer == L2["you"] and mctype == L2["are"] then
			mcplayer = UnitName("player")
		end
		if self.db.profile.mc then
			self:Bar(L["mindcontrol_bar"]:format(mcplayer), 9.5, "Spell_Shadow_ShadowWordDominate")
			self:Message(L["mindcontrol_message"]:format(mcplayer), "Urgent")
		end
		if self.db.profile.icon then
			self:Icon(mcplayer)
		end
	end
end

function mod:BigWigs_Message(text)
	if text == L["drain_warning"]:format(60) then
		self.prior = nil
	end
end

function mod:BeginTimers(first)
	if self.db.profile.drain then
		if not first then self:Message(L["drain_message"], "Attention") end
		self:DelayedMessage(30, L["drain_warning"]:format(60), "Attention")
		self:DelayedMessage(45, L["drain_warning"]:format(45), "Attention")
		self:DelayedMessage(60, L["drain_warning"]:format(30), "Urgent")
		self:DelayedMessage(75, L["drain_warning"]:format(15), "Important")
		self:Bar(L["drain_bar"], 90, "Spell_Shadow_LifeDrain")
	end
end

------------------------------
--      Are you local?      --
------------------------------

local boss = BB["Azuregos"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Azuregos",

	engage_trigger = "^This place is under my protection",
	engage_message = "%s engaged!",

	teleport = "Teleport",
	teleport_desc = "Warn for teleport.",
	teleport_message = "Teleport!",

	shield = "Shield",
	shield_desc = "Warn for Magic Shield.",
	shield_down = "Magic Shield DOWN!",
	shield_up = "Magic Shield UP!",
	shield_bar = "Magic Shield",
} end )

L:RegisterTranslations("deDE", function() return {
	--engage_trigger = "^This place is under my protection",
	--engage_message = "%s engaged!",

	teleport = "Teleport",
	teleport_desc = "Warnung f\195\188r Azuregos Teleport.",
	teleport_message = "Teleport!",

	shield = "Magieschild",
	shield_desc = "Warnung, wenn Magieschild aktiv.",
	shield_down = "Magieschild: Aus!",
	shield_up = "Magieschild: Aktiv!",
	shield_bar = "Magieschild",
} end )

L:RegisterTranslations("frFR", function() return {
	engage_trigger = "^Cet endroit est sous ma protection",
	engage_message = "%s engagé !",

	teleport = "Téléportation",
	teleport_desc = "Préviens de l'arrivée des Téléportations.",
	teleport_message = "Téléportation !",

	shield = "Bouclier",
	shield_desc = "Préviens de l'arrivée des boucliers magiques.",
	shield_down = "Bouclier magique dissipé !",
	shield_up = "Bouclier magique en place !",
	shield_bar = "Bouclier magique",
} end )

L:RegisterTranslations("zhCN", function() return {
	engage_trigger = "^这就是好奇的代价",
	engage_message = "%s 激活!",

	teleport = "传送警报",
	teleport_desc = "传送警报",
	teleport_message = "传送发动！",

	shield = "护盾警报",
	shield_desc = "护盾警报",
	shield_down = "魔法护盾消失！",
	shield_up = "魔法护盾开启 - 不要施放法术！",
	shield_bar = "魔法护盾",
} end )

L:RegisterTranslations("zhTW", function() return {
	--engage_trigger = "^This place is under my protection",
	--engage_message = "%s engaged!",

	teleport = "傳送警報",
	teleport_desc = "傳送警報",
	teleport_message = "傳送發動！",

	shield = "護盾警報",
	shield_desc = "護盾警報",
	shield_down = "魔法護盾消失！",
	shield_up = "魔法護盾開啟 - 不要施放法術！",
	shield_bar = "魔法護盾",
} end )

L:RegisterTranslations("koKR", function() return {
	engage_trigger = "^여기는 내가 지킨다.",
	engage_message = "%s 전투 시작!",

	teleport = "소환 경고",
	teleport_desc = "소환에 대한 경고",
	teleport_message = "강제 소환!",

	shield = "보호막 경고",
	shield_desc = "보호막에 대한 경고",
	shield_down = "마법 보호막 소멸!",
	shield_up = "마법 보호막 동작 - 마법 공격 금지!",
	shield_bar = "마법 보호막",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

local mod = BigWigs:NewModule(boss)
mod.zonename = BZ["Azshara"]
mod.otherMenu = "Azeroth"
mod.enabletrigger = boss
mod.toggleoptions = {"teleport", "shield", "bosskill"}
mod.revision = tonumber(("$Revision: 177 $"):sub(12, -3))

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddSyncListener("SPELL_AURA_APPLIED", 22067, "AzuShield")
	self:AddSyncListener("SPELL_CAST_SUCCESS", 21147, "AzuPort")

	self:AddCombatListener("UNIT_DIED", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:RegisterEvent("BigWigs_RecvSync")
	self:Throttle(5, "AzuShield", "AzuPort")
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:find(L["engage_trigger"]) then
		self:Message(L["engage_message"]:format(boss), "Attention")
	end
end

function mod:BigWigs_RecvSync(sync)
	if sync == "AzuShield" and self.db.profile.shield then
		self:IfMessage(L["shield_up"], "Attention", 22067)
		self:Bar(L["shield_bar"], 10, 22067)
		self:DelayedMessage(10, L["shield_down"], "Positive")
	elseif sync == "AzuPort" and self.db.profile.teleport then
		self:IfMessage(L["teleport_message"], "Important", 21147)
	end
end


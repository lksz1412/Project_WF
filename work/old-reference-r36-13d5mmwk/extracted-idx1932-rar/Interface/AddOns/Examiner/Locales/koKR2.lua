-- Localized and Edited by 알끄(리나아르크/블랙무어), 08.10.24 / Base - omosiro(자매/노르간논), 07.09.19
if (GetLocale() == "koKR") then
--------------------------------------------------------------------------------------------------------
--                                                Misc                                                --
--------------------------------------------------------------------------------------------------------

BINDING_HEADER_EXAMINER = "Examiner";
BINDING_NAME_EXAMINER_TARGET = "대상 살펴보기";
BINDING_NAME_EXAMINER_MOUSEOVER = "마우스 대상 살펴보기";

Examiner.Classification = {
	["worldboss"] = "우두머리",
	["rareelite"] = "희귀정예",
	["elite"] = "정예",
	["rare"] = "희귀",
};

ExScanner.SetBonusTokenActive = "^세트 효과:";

--------------------------------------------------------------------------------------------------------
--                                           Stat Patterns                                            --
--------------------------------------------------------------------------------------------------------

ExScanner.Patterns = {
	-- Base stats
	{ p = "힘 %+(%d+)", s = "STR" },
	{ p = "민첩성 %+(%d+)", s = "AGI" },
	{ p = "체력 %+(%d+)", s = "STA" },
	{ p = "지능 %+(%d+)", s = "INT" },
	{ p = "정신력 %+(%d+)", s = "SPI" },
	{ p = "방어도 (%d+)", s = "ARMOR" },

	-- Resistances (Exclude the Resist-"ance" then it picks up armor patches as well)
	{ p = "비전 저항력 %+(%d+)", s = "ARCANERESIST" },
	{ p = "화염 저항력 %+(%d+)", s = "FIRERESIST" },
	{ p = "자연 저항력 %+(%d+)", s = "NATURERESIST" },
	{ p = "냉기 저항력 %+(%d+)", s = "FROSTRESIST" },
	{ p = "암흑 저항력 %+(%d+)", s = "SHADOWRESIST" },
	{ p = "모든 저항력 %+(%d+)", s = { "ARCANERESIST", "FIRERESIST", "NATURERESIST", "FROSTRESIST", "SHADOWRESIST" } },

	-- Equip (Other)
	{ p = ": 탄력도가 (%d+)만큼 증가합니다.", s = "RESILIENCE" },

	{ p = ": 방어 숙련도가 (%d+)만큼 증가합니다.", s = "DEFENSE" },
	{ p = ": 회피 숙련도가 (%d+)만큼 증가합니다.", s = "DODGE" },
	{ p = ": 무기 막기 숙련도가 (%d+)만큼 증가합니다.", s = "PARRY" },
	{ p = ": 방패 막기 숙련도가 (%d+)만큼 증가합니다.", s = "BLOCK" },

	{ p = ": 방패의 피해 방어량이 (%d+)만큼 증가합니다.", s = "BLOCKVALUE" },
	{ p = "^(%d+)의 피해 방어$", s = "BLOCKVALUE" }, 
	{ p = "5초당 (%d+)의 생명력 회복.", s = "HP5" }, 

	-- Equip (Melee)
	{ p = ": 전투력이 (%d+)만큼 증가합니다.", s = "AP" },
	{ p = ": 원거리 전투력이 (%d+)만큼 증가합니다.", s = "RAP" },
        { p = "숙련도가 (%d+)만큼 증가합니다.", s = "EXPERTISE" }, -- New 2.3 Stat
        { p = "공격 시 적의 방어도를 (%d+)만큼 무시합니다.", s = "ARMORPENETRATION" },
        { p = "방어구 관통력이 (%d+)만큼 증가합니다.", s = "ARMORPENETRATIONRATING" }, -- Armor Penetration in 3.0

	-- Equip (Magic)
	{ p = ": 주문 관통력이 (%d+)만큼 증가합니다.", s = "SPELLPENETRATION" },
	{ p = ": 주문력이 (%d+)만큼 증가합니다%.", s = { "SPELLDMG", "HEAL" } },
	{ p = ": 주문력이 약간 증가합니다%.", s = { "HEAL", "SPELLDMG" }, v = 6 }, -- Bronze Band of Force

	{ p = ": 비전 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "ARCANEDMG" },
	{ p = ": 화염 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "FIREDMG" },
	{ p = ": 자연 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "NATUREDMG" },
	{ p = ": 냉기 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "FROSTDMG" },
	{ p = ": 암흑 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "SHADOWDMG" },
	{ p = ": 신성 계열의 주문력이 최대 (%d+)만큼 증가합니다%.", s = "HOLYDMG" },

	--  장착: 주문 & 근접이 함께 사용하는 수치 --
	{ p = ": 치명타 적중도가 (%d+)만큼 증가합니다.", s = { "CRIT", "SPELLCRIT" } },
	{ p = ": 치명타 및 주문 극대화 적중도가 (%d+)만큼 증가합니다.", s = { "CRIT", "SPELLCRIT" } },
	{ p = ": 적중도가 (%d+)만큼 증가합니다.", s = { "HIT", "SPELLHIT" } },
	{ p = ": 가속도가 (%d+)만큼 증가합니다.", s = { "HASTE", "SPELLHASTE" } },

	-- Enchants / Gems / Socket Bonuses / Mixed / Misc
	{ p = "^생명력 %+(%d+)$", s = "HP" },
	{ p = "^마나 %+(%d+)$", s = "MP" },

	{ p = "^활력$", s = { "MP5", "HP5" }, v = 4 },
	{ p = "^전투력$", s = "AP", v = 70 },
	{ p = "^침착함$", s = "HIT", v = 10 },
	{ p = "^냉기의 영혼$", s = { "FROSTDMG", "SHADOWDMG" }, v = 54 },
	{ p = "^태양의 불꽃$", s = { "ARCANEDMG", "FIREDMG" }, v = 50 },

	{ p = "모든 능력치 %+(%d+)", s = { "STR", "AGI", "STA", "INT", "SPI" } },

	{ p = "5초당 마나 회복량 %+(%d+)", s = "MP5" },
	{ p = "매 5초마다 (%d+)의 마나 회복", s = "MP5" },
	{ p = "매 5초마다 (%d+)의 마나가 회복됩니다%.", s = "MP5" },
	{ p = "5초당 (%d+)의 마나 회복%.", s = "MP5" },
	{ p = "^마나 회복량 %+(%d+)", s = "MP5" },
	{ p = "/ 마나 회복량 %+(%d+)$", s = "MP5" }, 

	{ p = "5초당 생명력 회복량 +(%d)%.", s = "HP5" },

	{ p = "비전 주문력 %+(%d+)", s = "ARCANEDMG" },
	{ p = "화염 주문력 %+(%d+)", s = "FIREDMG" },
	{ p = "자연 주문력 %+(%d+)", s = "NATUREDMG" },
	{ p = "냉기 주문력 %+(%d+)", s = "FROSTDMG" },
	{ p = "암흑 주문력 %+(%d+)", s = "SHADOWDMG" },
	{ p = "신성 주문력 %+(%d+)", s = "HOLYDMG" },

	{ p = "방어 숙련도 %+(%d+)", s = "DEFENSE" }, -- Exclude "Rating" from this pattern due to Paladin ZG Enchant
	{ p = "회피 숙련도 %+(%d+)", s = "DODGE" },
	{ p = "무기 막기 숙련도 %+(%d+)", s = "PARRY" },
	{ p = "방패 막기 숙련도 %+(%d+)", s = "BLOCK" },
	{ p = "피해 방어량 %+(%d+)", s = "BLOCKVALUE" },

	{ p = "^전투력 %+(%d+)", s = "AP" },
	{ p = "/ 전투력 %+(%d+)", s = "AP" }, 
	{ p = "원거리 전투력 %+(%d+)", s = "RAP" },
	{ p = "^적중도 %+(%d+)", s = { "HIT", "SPELLHIT" } },
	{ p = "/ 적중도 %+(%d+)", s = { "HIT", "SPELLHIT" } }, 
	{ p = ": 적중도 %+(%d+)", s = { "HIT", "SPELLHIT" } }, 
	{ p = "치명타 적중도 %+(%d+)", s = { "CRIT", "SPELLCRIT" } },
	{ p = "^치명타 및 주문 극대화 적중도 %+(%d+)", s = { "CRIT", "SPELLCRIT" } },
	{ p = "/ 치명타 및 주문 극대화 적중도 %+(%d+)", s = { "CRIT", "SPELLCRIT" } },
	{ p = "탄력도 %+(%d+)", s = "RESILIENCE" },
        { p = "가속도 %+(%d+)", s = "HASTE" },
        { p = "숙련도%+(%d+)", s = "EXPERTISE" },

	{ p = "^치유량 %+(%d+)", s = "HEAL" },
	{ p = "/ 치유량 %+(%d+)", s = "HEAL" }, 
	{ p = "주문 치유량 %+(%d+)", s = "HEAL" },
	{ p = "치유 및 주문력 %+(%d+)", s = { "SPELLDMG", "HEAL" } }, -- Warlock ZG Enchant (Healing will be cought by the other pattern)
	{ p = "^주문력 %+(%d+)", s = { "SPELLDMG", "HEAL" } }, -- Infused Amethyst Workaround
	{ p = ": 주문력 %+(%d+)", s = { "SPELLDMG", "HEAL" } }, -- 보석 장착 보너스
	{ p = "/ 주문력 %+(%d+)", s = { "SPELLDMG", "HEAL" } }, -- Infused Amethyst Workaround
	{ p = "주문 관통력 %+(%d+)", s = "SPELLPENETRATION" },
	{ p = "주문력 및 치유량 %+(%d+)", s = { "SPELLDMG", "HEAL" } },
	{ p = "^가속도 %+(%d+)", s = { "HASTE", "SPELLHASTE" } },

	{ p = "무기 공격력 %+(%d+)", s = "WPNDMG" },
	{ p = "^조준경 %(공격력 %+(%d+)%)$", s = "RANGEDDMG" },

};

--------------------------------------------------------------------------------------------------------
--                                        Stat Order & Naming                                         --
--------------------------------------------------------------------------------------------------------

Examiner.StatEntryOrder = {
	{ name = "기본 능력치", stats = {"STR", "AGI", "STA", "INT", "SPI", "ARMOR"} },
	{ name = "생명력 및 마나", stats = {"HP", "MP", "HP5", "MP5"} },
	{ name = "근접 및 원거리 능력", stats = {"AP", "RAP", "APFERAL", "CRIT", "HIT", "HASTE", "WPNDMG", "RANGEDDMG", "ARMORPENETRATION"} },
	{ name = "무기 숙련", stats = { "WPNSKILL_SWORD", "WPNSKILL_MACE", "WPNSKILL_AXE", "WPNSKILL_DAGGER", "WPNSKILL_SWORD_2H", "WPNSKILL_MACE_2H", "WPNSKILL_AXE_2H", "WPNSKILL_FERAL", "WPNSKILL_HAND" } },
	{ name = "주문 능력", stats = {"HEAL", "SPELLDMG", "ARCANEDMG", "FIREDMG", "NATUREDMG", "FROSTDMG", "SHADOWDMG", "HOLYDMG", "SPELLCRIT", "SPELLHIT", "SPELLHASTE", "SPELLPENETRATION"} },
	{ name = "방어 능력", stats = {"DEFENSE", "DODGE", "PARRY", "BLOCK", "BLOCKVALUE", "RESILIENCE"} },
};

ExScanner.StatNames = {
	["STR"] = "힘",
	["AGI"] = "민첩성",
	["STA"] = "체력",
	["INT"] = "지능",
	["SPI"] = "정신력",

	["ARMOR"] = "방어도",

	["ARCANERESIST"] = "비전 저항",
	["FIRERESIST"] = "화염 저항",
	["NATURERESIST"] = "자연 저항",
	["FROSTRESIST"] = "냉기 저항",
	["SHADOWRESIST"] = "암흑 저항",

	["DODGE"] = "회피 숙련도",
	["PARRY"] = "무기막기 숙련도",
	["DEFENSE"] = "방어 숙련도",
	["BLOCK"] = "방패 막기 숙련도",
	["BLOCKVALUE"] = "방패 피해 방어량",
	["RESILIENCE"] = "탄력도",

	["AP"] = "전투력",
	["RAP"] = "원거리 전투력",
	["APFERAL"] = "전투력 (야성)",
	["CRIT"] = "치명타 적중도",
	["HIT"] = "적중도",
	["HASTE"] = "공격 가속도",
	["WPNDMG"] = "무기 공격력",
	["RANGEDDMG"] = "원거리 공격력",
        ["ARMORPENETRATION"] = "방어도 무시",
	["ARMORPENETRATION"] = "방어구 관통력",
        ["EXPERTISE"] = "숙련도",

	["SPELLCRIT"] = "주문 극대화 적중도",
	["SPELLHIT"] = "주문 적중도",
	["SPELLHASTE"] = "주문 시전 가속도",
	["SPELLPENETRATION"] = "주문 관통력",

	["HEAL"] = "치유량",
	["SPELLDMG"] = "주문력",
	["ARCANEDMG"] = "주문력 (비전)",
	["FIREDMG"] = "주문력 (화염)",
	["NATUREDMG"] = "주문력 (자연)",
	["FROSTDMG"] = "주문력 (냉기)",
	["SHADOWDMG"] = "주문력 (암흑)",
	["HOLYDMG"] = "주문력 (신성)",

	["HP"] = "생명력",
	["MP"] = "마나",

	["HP5"] = "5초당 생명력 회복",
	["MP5"] = "5초당 마나 회복",
};
end

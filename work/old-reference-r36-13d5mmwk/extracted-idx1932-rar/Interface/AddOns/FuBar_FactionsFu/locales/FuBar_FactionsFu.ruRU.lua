--ruRU by Swix. Report bugs to http://forums.playhard.ru/index.php?showforum=49
local L = AceLibrary("AceLocale-2.2"):new("FuBar_FactionsFu")

L:RegisterTranslations("ruRU", function() return {
	TOOLTIP_HINT = "\n|cffeda55fЛевый клик|r - изменение наблюдаемой фракции.\n|cffeda55fShift+Левый клик|r - вставить данные в строку ввода чата.\n|cffeda55fAlt+Левый клик|r - привязать фракцию к текущей зоне.\n|cffeda55fCtrl+Левый клик|r - переключить режим неактивности фракции.",

	["Text"] = "Текст",
	["Text Settings"] = "Настройки текста",
	["Show Name"] = "Показывать название",
	["Toggles display of watched faction's name"] = "Переключить отображение названия фракции",
	["Show Standing"] = "Показывать отношение",
	["Toggles display of watched faction's current standing"] = "Переключить отображение отношения фракции к вам",
	["Show Progress"] = "Показывать прогресс",
	["Toggles display of watched faction's progress toward next standing"] = "Переключить отображение репутации, необходимой для следующего уровня",
	["Show Progress (in percent)"] = "Показывать прогресс (в процентах)",
	["Toggles display of watched faction's progress toward next standing (in percent)"] = "Переключить отображение репутации, необходимой для следующего уровня (в процентах)",
	["Color"] = "Цвет",
	["Color Settings"] = "Настройки цвета",
	["Name"] = "Название",
	["Sets color of the faction name"] = "Установить цвет названия фракции",
	["Reputation"] = "Репутация",
	["Sets color of the faction reputation"] = "Установить цвет репутации фракции",
	["standing"] = "Отношение",
	["Sets color of the faction standing"] = "Установить цвет уровня отношения фракции",
	["Other"] = "Другое",
	["Other Settings"] =  "Другие настройки",
	["Auto-Zone"] = "Автозона",
	["Toggles automatical adjustment of watched faction on zone change"] = "Автоматически переключать наблюдаемую фракцию при переходе в другую локацию",
	["Auto-Gain"] = "Автосмена",
	["Toggles automatical adjustment of watched faction on faction gain"] = "Автоматически переключать наблюдаемую фракцию при получении репутации ",

	["None"] = "Нет",
	["War Condition"] = "Война!",
	["Blizzard's Default"] = "Умолчания Blizzard'a",
	["Incremental"] = "Увеличивающееся",
} end)

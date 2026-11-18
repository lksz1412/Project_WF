local L = AceLibrary("AceLocale-2.2"):new("MoneyFu")

L:RegisterTranslations("ruRU", function() return {
	["NAME"] = "FuBar - MoneyFu",
	["DESCRIPTION"] = "Отслеживает количество денег у всех ваших персонажей на сервере.",
	["COMMANDS"] = {"/monfu", "/moneyfu"},
	["TEXT_TOTAL"] = "Всего",
	["TEXT_SESSION_RESET"] = "Сброс сессии",
	["TEXT_THIS_SESSION"] = "Эта сессия",
	["TEXT_GAINED"] = "Получено",
	["TEXT_SPENT"] = "Потрачено",
	["TEXT_AMOUNT"] = "Колиичество",
	["TEXT_PER_HOUR"] = "В час",
	["This Week"] = "Эта неделя",


	["ARGUMENT_RESETSESSION"] = "сброс сесии",

	["MENU_RESET_SESSION"] = "Сброс сессии",
	["MENU_CHARACTER_SPECIFIC_CASHFLOW"] = "Показывать статистику по каждому персонажу",
	["MENU_PURGE"] = "Очистить",
	["MENU_SHOW_GRAPHICAL"] = "Показывать с монетами",
	["MENU_SHOW_FULL"] = "Полный стиль",
	["MENU_SHOW_SHORT"] = "Короткий стиль",
	["MENU_SHOW_CONDENSED"] = "Уплотнённый стиль",
	["SIMPLIFIED_TOOLTIP"] = "Упрощённое всплывающее окошко",
	["SHOW_PER_HOUR_CASHFLOW"] = "Поток денег в час",

	["TEXT_SESSION_RESET"] = "Сессия сброшена.",
	["TEXT_CHARACTERS"] = "Персонажи",
	["TEXT_PROFIT"] = "Прибыль",
	["TEXT_LOSS"] = "Потеря",

	["HINT"] = "Click to pick up money"
} end)

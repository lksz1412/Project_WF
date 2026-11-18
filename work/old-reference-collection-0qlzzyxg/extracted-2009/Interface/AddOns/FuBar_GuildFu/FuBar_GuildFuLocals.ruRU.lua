local revision = tonumber(string.sub("$Revision: 109 $", 12, -3)) or 1
if revision > FuBar_GuildFu.revision then FuBar_GuildFu.revision = revision end

local L = AceLibrary("AceLocale-2.2"):new("FuBar_GuildFu")

L:RegisterTranslations("ruRU", function() return {
	["Group"] = "Группа",
	["Name"] = "Имя",
	["Class"] = "Класс",
	["Level"] = "Уровень",
	["Zone"] = "Игровая Зона",
	["Notes"] = "Заметки",
	["Rank"] = "Звание",
	["Show"] = "Показ",
	["Align"] = "Выровнять",
	["Color"] = "Цвет",
	["None"] = "нету",
	["Left"] = "Лево",
	["Center"] = "Центр",
	["Right"] = "Право",
	["No Guild"] = "Нет гильдии",
	["Updating..."] = "Обновление...",
	["You aren't in a guild."] = "Вы не состоите в гильдии.",
	["All guild mates offline or filtered."] = "Все игроки гильдии в оффлайн или отфильтрованы.",
	["Text"] = "Tекст",
	["Text Settings"] = "Настройки Текста",
	["Show Guild Name"] = "Показать название гильдии",
	["Toggles display of the guild name"] = "Показывает название гильдии",
	["Show Displayed"] = "Показать присутвующих",
	["Toggles display of number of unfiltered guildmates"] = "Показывает количество пристувующих",
	["Show Online"] = "Отображать онлайн",
	["Toggles display of number of online guildmates"] = "Показывает на экране количество игроков онлайн",
	["Show Total"] = "Отображать всех",
	["Toggles display of number of total guildmates"] = "Отображать общее количество игроков в гильдии",
	["Tooltip"] = "Подсказки",
	["Tooltip Settings"] = "Настройка подсказок",
	["MOTD"] = "Сообщение дня",
	["MOTD Settings"] = "Настройки сообщения Гильдии",
	["Toggles display of guild MOTD"] = "Показывать на экране сообщение дня гильдии",
	["Sort"] = "Сорт",
	["Sets sorting"] = "Настр сорт",
	["Group Indicator Settings"] = "Настройки индикатора групп",
	["Toggles display of group indicators"] = "Показывать индикатор групп",
	["Name Column Settings"] = "Настройки Имен Колонок",
	["Sets color of name column"] = "Отображать в цвете названия колонок",
	["Status"] = "Статус",
	["Toggles display of status"] = "Иконка статуса на экране",
	["Class Column Settings"] = "Параметры настройки колонки",
	["Toggles display of class column"] = "Иконка по классам в колонке",
	["Sets alignment of class column"] = "Отобразить по классам в колонке",
	["Level Column Settings"] = "Настройка уровней колонки",
	["Toggles display of level column"] = "Иконка по уровням в колонке",
	["Sets alignment of level column"] = "Отобразить по уровням в колонке",
	["Sets color of level column"] = "Показывать цветом подходящий уровень",
	["Relative"] = "Вашего уровня",
	["Zone Column Settings"] = "Настройки Локации",
	["Toggles display of zone column"] = "Показывает людей в вашей Локации",
	["Sets alignment of zone column"] = "Показывает людей в вашей Локации в отельной колонке",
	["Sets color of zone column"] = "Показывать цветом в вашей локации",
	["Faction"] = "Фракция",
	["Notes Column Settings"] = "Настройки Колонки заметок",
	["Show Public"] = "Показать Общие",
	["Toggles diplay of public notes"] = "Показывает общие заметки",
	["Show Officer"] = "Показать Офицерские",
	["Toggles display of officer notes"] = "Показывает  Офицерские заметки",
	["Show AuldLangSyne"] = "Показать AuldLangSyne",
	["Toggles display of AuldLangSyne notes"] = "Отобращает на экране AuldLangSyne заметки",
	["Show CT_PlayerNotes"] = "Показать Ст Плеер заметки",
	["Toggles display of CT_PlayerNotes notes"] = "Показывает на экране CT_PlayerNotes заметки",
	["Sets alignment of notes column"] = "Установки выравнивания заметок в колонке",
	["Rank Column Settings"] = "Настройки ранга",
	["Toggles display of rank column"] = "Отображает на экране выбранный ранг",
	["Sets alignment of rank column"] = "Настройка выранивания колонки ряда",
	["Filter"] = "Фильтр",
	["Filter Settings"] = "Настройки фильтра",
	["Class Filter Settings"] = "Настройки фильтра класса",
--	["Death Knight"] = true,
--	["Toggles display of Death Knights"] = true,
	["Druid"] = "Друид",
	["Toggles display of Druids"] = "Отображает на экране Друидов",
	["Hunter"] = "Охотник",
	["Toggles display of Hunters"] = "Отображает на экране Охотников",
	["Mage"] = "Маг",
	["Toggles display of Mages"] = "Отображает на экране Магов",
	["Paladin"] = "Паладин",
	["Toggles display of Paladins"] = "Отображает на экране Паладинов",
	["Priest"] = "Жрец",
	["Toggles display of Priests"] = "Отображает на экране Жрецов",
	["Rogue"] = "Разбойник",
	["Toggles display of Rogues"] = "Отображает на экране Разбойников",
	["Shaman"] = "Шаман",
	["Toggles display of Shamans"] = "Отображает на экране Шаманов",
	["Warlock"] = "Чернокнижник",
	["Toggles display of Warlocks"] = "Отображает на экране Чернокнижников",
	["Warrior"] = "Воин",
	["Toggles display of Warriors"] = "Отображает на экране Воинов",
	["Level Filter Settings"] = "Настройки фильтрации Уровней",
	[" 1- 9"] = " 1- 9",
	["Toggles display of level 1 to 9 chars"] = "Отображает на экране игроков 1-9 уровня",
	["10-19"] = "10-19",
	["Toggles display of level 10 to 19 chars"] = "Отображает на экране игроков 10-19 уровня",
	["20-29"] = "20-29",
	["Toggles display of level 20 to 29 chars"] = "Отображает на экране игроков 20-29 уровня",
	["30-39"] = "30-39",
	["Toggles display of level 30 to 39 chars"] = "Отображает на экране игроков 30-39 уровня",
	["40-49"] = "40-49",
	["Toggles display of level 40 to 49 chars"] = "Отображает на экране игроков 40-49 уровня",
	["50-59"] = "50-59",
	["Toggles display of level 50 to 59 chars"] = "Отображает на экране игроков 50-59 уровня",
	["60-69"] = "60-69",
	["Toggles display of level 60 to 69 chars"] = "Отображает на экране игроков 60-69 уровня",
	["70-79"] = "70-79",
	["Toggles display of level 70 to 79 chars"] = "Отображает на экране игроков 70-79 уровня",
	["80"] = "80",
	["Toggles display of level 80 chars"] = "Отображает на экране игроков 80 уровня",
	["Zone Filter Settings"] = "Настройки Выбора Локации",
	["In Battleground"] = "На полях боев",
	["Toggles display of chars in battlegrounds"] = "Отображает на экране игроков на полях битв",
	["In Instance"] = "В Инстанте",
	["Toggles display of chars in instances"] = "Отображает на экране игроков в инстах",
	["In Open Field"] = "В открытой локации",
	["Toggles display of chars in open field"] = "Отображает на экране игроков в открытых локациях",
} end)

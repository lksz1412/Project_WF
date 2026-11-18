local MODNAME = "TalentSwitch"
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( MODNAME, "zhTW")
if not L then return end

L["ADDON_NAME"] = "Broker: TalentSwitch";

L["DEFAULT_PREFIX_OUTPUT"] = "現在設定: ";
L["DEFAULT_PRIMARY_ALIAS"] = "主要";
L["DEFAULT_SECONDARY_ALIAS"] = "次要";
L["DEFAULT_SUCCESS_MESSAGE"] = "天賦切換完成！";

L["GENERAL_INFO_DESC"] = "TalentSwitch是一個以LibDataBroker為基礎開發的插件。這是一個非常簡易的插件，讓您很簡易切換主要與次要天賦設定。";
L["General Information"] = "一般設定";
L["Version : "] = "版本 : ";
L["Author : "] = "作者 : ";
L["MSG_USAGE"] = "<您的訊息>";

L["Broker Prefix Label"] = "資料顯示器前置標籤";
L["PREFIX_OUTPUT_DESC"] = "此訊息在資料顯示器會顯示於主要與次要訊息前方。";

L["On Change"] = "切換時"
L["ONCHANGE_OUTPUT_DESC"] = "當'隱藏垃圾訊息'開啟時，此訊息會在您切換天賦完成時顯示。";

L["Hide Spam"] = "隱藏垃圾訊息";
L["HIDE_SPAM_DESC"] = "當此設定開啟時，將會隱藏在切換天賦設定時所產生的垃圾訊息";

L["Primary Talent Alias"] = "主要天賦別名";
L["PRIMARY_DESC"] = "此訊息將會使您的主要天賦以資訊欄方式呈現於您的資料顯示器。";

L["Secondary Talent Alias"] = "次要天賦別名";
L["SECONDARY_DESC"] = "此訊息將會使您的次要天賦以資訊欄方式呈現於您的資料顯示器。";

L["TOOLTIP_INSTRUCTIONS1"] = "點擊左鍵切換: |cffffff00";
L["TOOLTIP_INSTRUCTIONS2"] = "|r";
L["TOOLTIP_OPEN_CONFIG"] = "點擊右鍵開啟設定";
L["TOOLTIP_PRIMARY"] = "主要設定";
L["TOOLTIP_SECONDARY"] = "次要設定";

L["BTN_GET_TALENT"] = "取得天賦資訊";
L["BTN_GET_TALENT_DESC"] = "將您的天賦資訊預先填入設定欄";

L["BTN_RESET"] = "恢復預設"
L["BTN_RESET_DESC"] = "將您的主要與次要別名以及圖示還原至預設值";
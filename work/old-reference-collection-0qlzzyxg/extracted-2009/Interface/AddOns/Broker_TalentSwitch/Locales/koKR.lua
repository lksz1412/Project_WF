local MODNAME = "TalentSwitch"
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( MODNAME, "koKR")
if not L then return end

L["ADDON_NAME"] = "Broker: TalentSwitch";

L["DEFAULT_PREFIX_OUTPUT"] = "현재 특성: ";
L["DEFAULT_PRIMARY_ALIAS"] = "1특성";
L["DEFAULT_SECONDARY_ALIAS"] = "2특성";
L["DEFAULT_SUCCESS_MESSAGE"] = "특성 전환 완료!";

L["GENERAL_INFO_DESC"] = "TalentSwitch은 LibDataBroker에 기초를 둔 애드온입니다. 이것은 1특성과 2특성의 전환을 간단하고 쉽게 할 수 있는 매우 간단한 애드온입니다.";
L["General Information"] = "일반적인 정보";
L["Version : "] = "버전 : ";
L["Author : "] = "제작자 : ";
L["MSG_USAGE"] = "<당신의 메시지>";

L["Broker Prefix Label"] = "Broker 접두사 라벨";
L["PREFIX_OUTPUT_DESC"] = "1특성 및 2특성 메시지가 표시되기전 Broker 화면에 표시될 메시지입니다.";

L["On Change"] =" 특성 변경시"
L["ONCHANGE_OUTPUT_DESC"] = "특성 전환 완료시 표시될 메시지입니다. '스팸 숨김' 사용시 표시되지 않습니다.";

L["Hide Spam"] = "스팸 숨김";
L["HIDE_SPAM_DESC"] = "사용시, 특성 전환시 나오는 메시지를 숨깁니다.";

L["Primary Talent Alias"] = "1특성 별명";
L["PRIMARY_DESC"] = "Broker에 표시될 1특성의 별명을 입력합니다.";

L["Secondary Talent Alias"] = "2특성 별명";
L["SECONDARY_DESC"] = "Broker에 표시될 2특성의 별명을 입력합니다.";

L["TOOLTIP_INSTRUCTIONS1"] = "좌 클릭 - 특성 변경: |cffffff00";
L["TOOLTIP_INSTRUCTIONS2"] = "|r";
L["TOOLTIP_OPEN_CONFIG"] = "우 클릭 - 설정 창 열기";
L["TOOLTIP_PRIMARY"] = "1특성";
L["TOOLTIP_SECONDARY"] = "2특성";

L["BTN_GET_TALENT"] = "특정 정보 받아옴";
L["BTN_GET_TALENT_DESC"] = "당신의 특성 정보를 가지고 입력 박스에 프로필을 만듭니다.";

L["BTN_RESET"] = "기본값으로 복구"
L["BTN_RESET_DESC"] = "1특성, 2특성의 별명 및 아이콘을 복구합니다.";
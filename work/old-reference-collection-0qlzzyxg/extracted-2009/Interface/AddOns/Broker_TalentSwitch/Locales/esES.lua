local MODNAME = "TalentSwitch"
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale( MODNAME, "esES")
if not L then return end

L["ADDON_NAME"] = "Broker: TalentSwitch";

L["DEFAULT_PREFIX_OUTPUT"] = "Build actual: ";
L["DEFAULT_PRIMARY_ALIAS"] = "Primaria";
L["DEFAULT_SECONDARY_ALIAS"] = "Secundaria";
L["DEFAULT_SUCCESS_MESSAGE"] = "¡Cambio de talentos completo!";

L["GENERAL_INFO_DESC"] = "TalentSwitch es un addon informativo basado en LibDataBroker. Es un addon muy simple que proporciona una forma fácil y simple de cambiar entre una build de talentos Primaria y una Secundaria.";
L["General Information"] = "Información general";
L["Version : "] = "Versión : ";
L["Author : "] = "Autor : ";
L["MSG_USAGE"] = "<Tu mensaje>";

L["Broker Prefix Label"] = "Etiqueta prefijo";
L["PREFIX_OUTPUT_DESC"] = "Este es el mensaje mostrado en el display antes del mensaje de build Primaria o Secundaria.";

L["On Change"] = "Al cambiar"
L["ONCHANGE_OUTPUT_DESC"] = "Si 'Ocultar spam' está activado se generará este mensaje cuando se haya completado el cambio de build de talentos.";

L["Hide Spam"] = "Ocultar spam";
L["HIDE_SPAM_DESC"] = "Si está acivado ocultará el spam generado al cambiar de build de talentos.";

L["Primary Talent Alias"] = "Build Primaria";
L["PRIMARY_DESC"] = "Este mensaje se mostrará en el display y el tooltip cuando la build Primaria esté activa.";

L["Secondary Talent Alias"] = "Build Secundaria";
L["SECONDARY_DESC"] = "Este mensaje se mostrará en el display y el tooltip cuando la build Secundaria esté activa.";

L["TOOLTIP_INSTRUCTIONS1"] = "Click Izdo. para cambiar a: |cffffff00";
L["TOOLTIP_INSTRUCTIONS2"] = "|r";
L["TOOLTIP_OPEN_CONFIG"] = "Clich Dcho. para abrir la ventana de configuración";
L["TOOLTIP_PRIMARY"] = "Build Primaria";
L["TOOLTIP_SECONDARY"] = "Build Secundaria";

L["BTN_GET_TALENT"] = "Leer talentos";
L["BTN_GET_TALENT_DESC"] = "Rellena las casillas de texto anteriores con la información de tus talentos.";

L["BTN_RESET"] = "Restaurar configuración por defecto"
L["BTN_RESET_DESC"] = "Restaura los textos e iconos a sus valores por defecto.";
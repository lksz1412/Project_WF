------------------------------------------------ 초기 설정값 ------------------------------------------
local DefaultHotkeySettings = {
    font = {
            name = "Interface\\AddOns\\HotkeyText\\BOLONEWT.TTF",
            size = 14,
            flags = "OUTLINE"};
    offset = {x = -4, y = -6};
    upper = nil;
    ColorMode = nil;
    color = {r=0,g=1,b=0,a=1};
    hideMacroName = 1;
}

local DefaultActionButtonName = {
    {name = "ActionButton", type = "ACTIONBUTTON", apply = 1};                        -- 기본 행동 단축바
    {name = "MultiBarBottomLeftButton", type = "MULTIACTIONBAR1BUTTON", apply = 1};   -- 좌측 하단 행동 단축바
    {name = "MultiBarBottomRightButton", type = "MULTIACTIONBAR2BUTTON", apply = 1};  -- 우측 하단 행동 단축바
    {name = "MultiBarRightButton", type = "MULTIACTIONBAR3BUTTON", apply = 1};        -- 첫번째 우측 행동 단축바
    {name = "MultiBarLeftButton", type = "MULTIACTIONBAR4BUTTON", apply = 1};         -- 두번째 우측 행동 단축바
    {name = "BonusActionButton", type = "ACTIONBUTTON", apply = 1};                   -- 보너스 행동 단축바(태세 변환시 기본 행동단축바)
    {name = "ShapeshiftButton", type = "SHAPESHIFTBUTTON", apply = 1};                -- 태세바(특수 기술 단축키)
    {name = "PetActionButton", type = "BONUSACTIONBUTTON", apply = 1};                -- 소환수 기술 단축키(보조행동 단축키)
    {name = "ExtraBarButton", type = "EXTRABARBUTTON", apply = 1};                    -- 확장바 단축키
    {name = "AspectBarButton", type = "ASPECTBAR_BUTTON", apply = 1};                  -- 상바 단축키
}
-------------------------------------------------------------------------------------------------------
local LongNameKey = {
    ["Delete"] ="Dt";
    ["Del"] = "Dt";
    ["Page Down"] = "Pd";
    ["Page Up"] = "Pu";
    ["Insert"] = "In";
    ["End"]= "Ed";
    ["Home"] = "Hm";
    ["Capslock"] = "Ck";
    ["Num Lock"] = "Nk";
    ["Scroll Lock"] = "Sk";
    ["Clear"] = "Cl";
    ["Backspace"] = "Bs";
}

local function checkLongName(keyName)
    local keyName = string.gsub(keyName,"숫자패드","N");
    keyName = string.gsub(keyName,"마우스 가운데 버튼","M3");
    keyName = string.gsub(keyName,"(%d)번 마우스 버튼","M%1");
    keyName = string.gsub(keyName,"마우스 휠 위로","MU");
    keyName = string.gsub(keyName,"마우스 휠 아래로","MD");
    keyName = string.gsub(keyName,"마우스 왼쪽 버튼",M1);
    keyName = string.gsub(keyName,"마우스 오른쪽 버튼",M2);
    if HotkeySettings.upper then
      keyName = string.gsub(keyName,"^s%-","S-"); -- shift 약자 s 를 대문자 S 로 변경
      keyName = string.gsub(keyName,"^a%-","A-"); -- alt 약자 a 를 대문자 A 로 변경
      keyName = string.gsub(keyName,"^c%-","C-"); -- ctrl 약자 c 를 대문자 C 로 변경
    end
    local i,j = string.find(keyName,"-%a+");
    local kn = keyName;
    if i then
        kn = string.sub(keyName,i+1);
    end
    if LongNameKey[kn] then 
        return LongNameKey[kn];
    else
        return keyName;
    end
end

function User_ActionButton_UpdateHotkeys(self,actionButtonType)
	if ( not self or self:GetName()~="VehicleMenuBarActionButton6" ) then return end
	  local numBtns;
    for k,v in pairs(ActionButtonName) do
     	numBtns = v.type=="ASPECTBAR_BUTTON" and 16 or 12;
      if v.apply and (actionButtonType == v.type or actionButtonType == nil or actionButtonType == "COMMAND") then
        for i = 1, numBtns do
          local f =  getglobal(v.name..i);
          if not f then break end;
          local hotkey = getglobal(f:GetName().."HotKey");
          local key = GetBindingKey(v.type..i) or GetBindingKey("CLICK "..f:GetName()..":LeftButton");
          local text = GetBindingText(key, "KEY_", 1);
          text = checkLongName(text);
          hotkey.isApply = 1;
          if ( text == "" ) then
            hotkey:SetText(RANGE_INDICATOR);
            hotkey:SetPoint("TOPLEFT", f, "TOPLEFT", 1,  -2);
            hotkey:Hide();
          else
            hotkey:SetFont(HotkeySettings.font.name,HotkeySettings.font.size,HotkeySettings.font.flags);
            hotkey:SetText(text);
            hotkey:SetVertexColor(HotkeySettings.color.r,HotkeySettings.color.g,HotkeySettings.color.b,HotkeySettings.color.a);
            hotkey:SetPoint("TOPLEFT", f, "TOPLEFT", HotkeySettings.offset.x, HotkeySettings.offset.y);
            hotkey:Show();
          end
          if HotkeySettings.hideMacroName then
            getglobal(f:GetName().."Name"):Hide();
          else
            getglobal(f:GetName().."Name"):Show();
          end
        end
      elseif v.apply == nil then
        for i = 1, numBtns do
          local f =  getglobal(v.name..i);
          if not f then break end;
          local hotkey = getglobal(f:GetName().."HotKey");
          local key = GetBindingKey(v.type..i) --or GetBindingKey("CLICK "..f:GetName()..":LeftButton");
          local text = GetBindingText(key, "KEY_", 1);
          text = checkLongName(text);
          hotkey.isApply = nil;
          if ( text == "" ) then
            hotkey:SetText(RANGE_INDICATOR);
            hotkey:SetPoint("TOPLEFT", f, "TOPLEFT", 1,  -2);
            hotkey:Hide();
          else
            hotkey:SetFontObject(NumberFontNormalSmallGray);
            hotkey:SetText(text);
            hotkey:SetVertexColor(0.6,0.6,0.6,1);
            hotkey:SetPoint("TOPLEFT", f, "TOPLEFT", -2, -2);
            if HotkeySettings.hide then
              hotkey:Hide();
            else
              hotkey:Show();
            end
          end
        end
      end
    end
end
hooksecurefunc("ActionButton_UpdateHotkeys",User_ActionButton_UpdateHotkeys);

local function User_ActionButton_ChangeHotkeyColor(self,elapsed)
  if not HotkeySettings.ColorMode then return end;
  if ( self.rangeTimer ) then
    if ( self.rangeTimer >= TOOLTIP_UPDATE_TIME ) then
      local Hotkey = getglobal(self:GetName().."HotKey");
      local valid = IsActionInRange(self.action);
      if ( Hotkey:GetText() == RANGE_INDICATOR ) then
        if ( valid == 0 ) then
          Hotkey:Show();
          Hotkey:SetVertexColor(1.0, 0.1, 0.1);
        elseif ( valid == 1 ) then
          Hotkey:Show();
          if Hotkey.isApply then
            Hotkey:SetVertexColor(HotkeySettings.color.r, HotkeySettings.color.g, HotkeySettings.color.b);
          end
        else
          Hotkey:Hide();
        end
      else
        if ( valid == 0 ) then
          Hotkey:SetVertexColor(1.0, 0.1, 0.1);
        else
          if Hotkey.isApply then
            Hotkey:SetVertexColor(HotkeySettings.color.r, HotkeySettings.color.g, HotkeySettings.color.b);
          end
        end
      end
    end
  end
end

function HotkeyText_SetColorMode()
  if HotkeySettings.ColorMode and HotkeyTextColorOnFirst then
    hooksecurefunc("ActionButton_OnUpdate",User_ActionButton_ChangeHotkeyColor);
    HotkeyTextColorOnFirst = nil;
  end
end

function HotkeyText_Reset()
  HotkeySettings = {};
  for idx,v in pairs(DefaultHotkeySettings) do
    if not HotkeySettings[idx] then
      table.insert(HotkeySettings,idx);
      HotkeySettings[idx]=v;
    end
  end
  ActionButtonName = {}; 
  for idx,v in pairs(DefaultActionButtonName) do
    if not ActionButtonName[idx] then
      table.insert(ActionButtonName,idx);
      ActionButtonName[idx]=v;
    end
  end
  User_ActionButton_UpdateHotkeys(VehicleMenuBarActionButton6,"COMMAND");
  HotkeyTextFrame:Hide();
  HotkeyTextFrame:Show();
end

function HotkeyText_CheckRGBValue(value,c)
  if value then
    if value >= 0 and value <= 1 then 
      return value;
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000HotkeyText-> |r("..value..") 잘못된 색상값입니다.")
      return c;
    end
  end
  return c;
end

function HotkeyText_OnLoad(self)
  SLASH_HotkeyMenu1 = "/hotkey"; 
  SlashCmdList["HotkeyMenu"] = function (msg)
    HotkeyTextFrame:Show();
  end
  self:RegisterEvent("VARIABLES_LOADED");
  self:RegisterEvent("UPDATE_TICKET");
  self:RegisterEvent("UPDATE_BINDINGS");
end

function HotkeyText_OnEvent(self,event)
  if event == "UPDATE_TICKET" then
    User_ActionButton_UpdateHotkeys(VehicleMenuBarActionButton6,"COMMAND");
    HotkeyText_SetColorMode();
  elseif event == "UPDATE_BINDINGS" then
  	User_ActionButton_UpdateHotkeys(VehicleMenuBarActionButton6,"COMMAND");
  elseif event == "VARIABLES_LOADED" then
    if not HotkeySettings then
      HotkeySettings = DefaultHotkeySettings;
    else
      for idx,v in pairs(DefaultHotkeySettings) do
        if (not HotkeySettings[idx]) and (type(DefaultHotkeySettings[idx])=="table")  then
          table.insert(HotkeySettings,idx);
          HotkeySettings[idx]=v;
        end
      end
    end
    if not ActionButtonName then
      ActionButtonName = DefaultActionButtonName;
    else
      for idx,v in pairs(DefaultActionButtonName) do
        if not ActionButtonName[idx] then
          table.insert(ActionButtonName,idx);
          ActionButtonName[idx]=v;
        end
      end
    end 
    HotkeyTextColorOnFirst = true;
  end
end 


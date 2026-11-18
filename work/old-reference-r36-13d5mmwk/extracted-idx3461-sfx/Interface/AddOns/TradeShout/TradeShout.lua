-- 변수 선언
local ls_msg = ""
local ls_errmsg = ""
local ls_tag = ""
local ls_reason = ""
local ls_money = ""
local ls_TradeItem = ""
local ls_targetName = ""
local ll_playerMoney = 0
local ll_targetMoney = 0
local playerItems = {}
local targetItems = {}

-- 메세지 출력
local function TS_Print(msg)

  if (TSOptions.toggle == true) then
    if ls_targetName ~= nil then
      msg = "대상:"..ls_targetName.."-"..msg
    end

    if (GetNumGroupMembers() > 4) then
        SendChatMessage(msg, "RAID")
    elseif (GetNumSubgroupMembers() > 0) then
        SendChatMessage(msg, "PARTY")
    else
        SendChatMessage(msg, "SAY")
    end
  else
    if ls_targetName ~= nil then
      SendChatMessage(msg, "WHISPER", "Common", ls_targetName);
    else
      ChatFrame1:AddMessage(msg, 1.0, 1.0, 0.0);
    end
  end

  --변수 초기화
  ls_errmsg = ""
  ls_tag = ""
  ls_reason = ""
  ls_money = ""
  ls_targetName =""
  ll_playerMoney = 0
  ll_targetMoney = 0
  playerItems = {}
  targetItems = {}

end

-- 골드만 선택
local function truncGold(str)
  local ll_len = string.len(str)
  local ll_end = ll_len - 4
  local ll_gold = tonumber(string.sub(str, 1, ll_end))
  if ll_gold == nil then
    return 0
  else
    return ll_gold
  end
end

-- 골드확인
local function TS_UpdateMoney()
  ll_playerMoney = truncGold(GetPlayerTradeMoney());  --- ggggsscc (format)
  ll_targetMoney = truncGold(GetTargetTradeMoney());
end

-- 거래물품의 정보 처리
local function TS_UpdateItemInfo(id, unit, items)
  local funcInfo = getglobal("GetTrade"..unit.."ItemInfo");
  local funcLink = getglobal("GetTrade"..unit.."ItemLink");

  local name, texture, numItems, quality, isUsable, enchantment;

  if(unit=="Target") then
    name, texture, numItems, quality, isUsable, enchantment = funcInfo(id);
  else
    name, texture, numItems, quality, enchantment = funcInfo(id);
  end

  if(not name) then
    items[id] = nil;
    return;
  end

  items[id] = {
    name = name,       -- itemName
    enchantment = enchantment, --  마부여부
  }
end

-- 교환물품 수량 및 마부내역
local function TS_GetTradeList(msg, items, enchant)
  local ls_text = ""
  local count = 0
  for i = 1, 6 do
    if(items[i]) then
      count = count + 1
    end
  end
  if(count > 0) then
    ls_text = msg..string.gsub(" %d 가지 ", "%%d", count)
  end

  if(enchant and enchant.name and enchant.enchantment) then
    ls_text = ls_text.."["..enchant.name.."-"..enchant.enchantment.."]"
  end
  return ls_text;
end

-- 사용할 ERR EVENT 설정
local ErrEvents = {}

ErrEvents[ERR_TRADE_BAG] = true;              ErrEvents[ERR_TRADE_BAG_FULL] = true;
ErrEvents[ERR_TRADE_BLOCKED_S] = true;        ErrEvents[ERR_TRADE_BOUND_ITEM] = true;
ErrEvents[ERR_TRADE_GROUND_ITEM] = true;      ErrEvents[ERR_TRADE_MAX_COUNT_EXCEEDED] = true;
ErrEvents[ERR_TRADE_QUEST_ITEM] = true;       ErrEvents[ERR_TRADE_REQUEST_S] = true;
ErrEvents[ERR_TRADE_TARGET_BAG_FULL] = true;  ErrEvents[ERR_TRADE_TARGET_DEAD] = true;
ErrEvents[ERR_TRADE_TOO_FAR] = true;          ErrEvents[ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED] = true;

-- Event : OnLoad
function TradeShout_OnLoad(self)
  self:RegisterEvent("VARIABLES_LOADED");
  self:RegisterEvent("TRADE_SHOW");
  self:RegisterEvent("TRADE_CLOSED");
  self:RegisterEvent("TRADE_REQUEST_CANCEL");

  self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED");
  self:RegisterEvent("TRADE_ACCEPT_UPDATE");
  self:RegisterEvent("UI_INFO_MESSAGE");
  self:RegisterEvent("UI_ERROR_MESSAGE");
end

-- Event : OnEvent
function TradeShout_OnEvent(self, event, ...)
  local arg1 = ...;

  if (event == "VARIABLES_LOADED") then
    if not TSOptions then
      TS_Reset(false);
    end
    if TSOptions.toggle == true then
      ChatFrame1:AddMessage("거래알림: (사용중)", 1.0, 1.0, 1.0);
    else
      ChatFrame1:AddMessage("거래알림: (중지중)", 1.0, 1.0, 1.0);
    end
  end

  if (event=="UI_ERROR_MESSAGE") and (ErrEvents[arg1]) then
    ls_errmsg = "거래가 실패했습니다.  ("..arg1..")"
    ls_targetName = nil;
    TS_Print(ls_errmsg);
  elseif (event=="UI_INFO_MESSAGE" and ( arg1==ERR_TRADE_CANCELLED or arg1==ERR_TRADE_COMPLETE) ) then
    local ll_len = string.len(ls_tag)
    local ll_start = ll_len - 2

    if string.sub(ls_tag,ll_start) == "112" then
      ls_reason = "당신이 취소했습니다";
    elseif string.sub(ls_tag,ll_start) == "312" then
      ls_reason = "당신이 멀리 움직임";
    elseif string.sub(ls_tag,ll_start) == "211" then
      ls_reason = "상대방이 취소했습니다";
    elseif string.sub(ls_tag,ll_start) == "132" then
      ls_reason = "당신이 UI를 숨김";
    end

    local ls_target = ""
    local ls_player = ""
    ls_TradeItem = ""

    ls_target = TS_GetTradeList("받은물품:", targetItems, targetItems[7]);
    ls_player = TS_GetTradeList("보낸물품:", playerItems, playerItems[7]);

    if (string.len(ls_target) > 1) and (string.len(ls_player) > 1) then
      ls_TradeItem = ls_target.."/"..ls_player
    else
      if string.len(ls_target) > 1 then
        ls_TradeItem = ls_target;
      elseif string.len(ls_player) > 1 then
        ls_TradeItem = ls_player;
      end
    end

    ls_msg = "거래품목이 없음"
    if (string.len(ls_money) > 1) and (string.len(ls_TradeItem) > 1) then
      ls_msg = ls_money.." / "..ls_TradeItem
    else
      if string.len(ls_money) > 1 then
        ls_msg = ls_money;
      elseif string.len(ls_TradeItem) > 1 then
        ls_msg = ls_TradeItem;
      end
    end

    if (arg1==ERR_TRADE_CANCELLED) then
      ls_msg = "거래가 취소되었습니다 <"..ls_reason..">"
    else
      ls_msg = "거래가 완료되었습니다 ("..ls_msg..")"
    end
    TS_Print(ls_msg)

  elseif (event=="TRADE_CLOSED" or event=="TRADE_REQUEST_CANCEL" or event == "TRADE_SHOW") then
    if (event=="TRADE_CLOSED") then
      ls_tag = ls_tag.."1"
    elseif (event=="TRADE_REQUEST_CANCEL") then
      ls_tag = ls_tag.."2"
    elseif (event == "TRADE_SHOW") then
      ls_tag = ls_tag.."3"
      ls_targetName = GetUnitName("target");
    end
  elseif (event=="TRADE_TARGET_ITEM_CHANGED") then
    TS_UpdateItemInfo(arg1, "Target", targetItems);
  elseif (event=="TRADE_ACCEPT_UPDATE") then
    local ll_i
    for ll_i = 1, 7 do
      TS_UpdateItemInfo(ll_i, "Player", playerItems);
      TS_UpdateItemInfo(ll_i, "Target", targetItems);
    end

    TS_UpdateMoney();

    if (ll_playerMoney >= 1) and (ll_targetMoney >= 1) then
      ls_money = "건네줌 : "..ll_playerMoney.."골 --> 받음 : "..ll_targetMoney.."골"
    elseif (ll_playerMoney >= 1) then
      ls_money = "건네줌 : "..ll_playerMoney.."골"
    elseif (ll_targetMoney >= 1) then
      ls_money = "받음 : "..ll_targetMoney.."골"
    else
      ls_money = "";
    end
  end

end

local frame = CreateFrame("Frame");
frame:SetScript("OnEvent", TradeShout_OnEvent);
TradeShout_OnLoad(frame);

function TS_Reset(toggle)
  TSOptions = {};
  TSOptions.toggle = toggle
end
---------------------------------------------------------------------------------------------------
-- sequence      : 00018
-- function name : SlashCmdList
-- desc          : 명령어
---------------------------------------------------------------------------------------------------
SlashCmdList["TRADESHOUT"] = function(cmd)
  local c = string.split(" ",cmd)
  if (c == "on") or (c == "사용") then
    if TSOptions then
      TSOptions.toggle = true
    else
      TS_Reset(true);
    end

    ChatFrame1:AddMessage("거래내역을 주위에 알려줍니다..", 1.0, 1.0, 1.0);
  elseif (c == "off") or (c == "중지") then
    if TSOptions then
      TSOptions.toggle = false
    else
      TS_Reset(false);
    end
  
    ChatFrame1:AddMessage("거래내역을 혼자만 봅니다..", 1.0, 1.0, 1.0);
  else
    ChatFrame1:AddMessage("사용법: /거래알림 사용 | 중지", 1.0, 0.5, 1.0);
  end
end

SLASH_TRADESHOUT1 = "/거래알림"
SLASH_TRADESHOUT2 = "/ts"
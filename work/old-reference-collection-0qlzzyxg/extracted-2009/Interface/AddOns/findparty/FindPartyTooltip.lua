
FP_Tooltip_Func = {
    ["DEFAULT"] =function(msg, frame, anchor, pX, pY)
        GameTooltip:SetOwner(frame, anchor, pX, pY);
        GameTooltip:ClearLines();
        GameTooltip:AddLine(msg);
        GameTooltip:Show();
    end,
    ["ICON"] = function()
            local msg = "|cff00ff00왼쪽 클릭: |r파티찾기 도우미 열기";
            msg = msg.."\n|cff00ff00왼쪽 누르고 드래그 : |r아이콘이동";
            msg = msg.."\n|cff00ff00Alt + 왼쪽클릭: |r아이콘 고정/해제";
            msg = msg.."\n|cff00ff00Ctrl + 왼쪽클릭: |r광고 시작/정지";
            msg = msg.."\n|cff00ff00Shift + 왼쪽클릭: |r기능 정지/작동";
            msg = msg.."\n|cff00ff00오른쪽 클릭: |r옵션";
            msg = msg.."\n ";
            msg = msg.."\n현재:";
            if (FP_IsActivated()) then
                msg = msg.." 작동중";
            else
                msg = msg.." 작동정지";
            end
            if (FP_IsAnnoucing()) then
                msg = msg.." 광고중 "
            end
            if (FP_Options.iconLocked) then
                msg = msg.." 아이콘고정"
            end

            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOMLEFT", 50, 0);
    end,
    ["LIST"] = function()
          local text =getglobal(this:GetName().."MsgText"):GetText();
          if (text) then
            FP_Tooltip_Func.DEFAULT(text,
                                    getglobal(this:GetName().."Msg"),
                                    "ANCHOR_BOTTOMLEFT",
                                    getglobal(this:GetName().."Msg"):GetWidth(), 0);
          end
    end,
    ["SORTTIME"] = function()
            FP_Tooltip_Func.DEFAULT("시간순으로 정렬", this, "ANCHOR_BOTTOM", 80, 0);
    end,
    ["FILTERDUNGEON"] = function()
            local msg = "왼쪽 클릭 : 모든 던젼 정렬\n오른쪽 클릭 : 관심 던젼 광고만 골라냄";
            local desc = FP_GetDungeonFilterDesc();
            if (desc) then
                msg = msg.."\n선택 : "..desc;
            end
            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM", 170, 0);
    end,
    ["FILTERCLASS"] = function()
           local msg = "왼쪽 클릭 : 내 직업 골라냄\n오른쪽 클릭 : 관심 직업만 골라냄";
            local desc = FP_GetClassFilterInfo();
            if (desc) then
               msg = msg.."\n현재 선택 : "..desc;
            end
            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_TOPRIGHT", 0 - (this:GetWidth()/2- 120), 0);
    end,
    ["TITLEBAR"] = function()
            FP_Tooltip_Func.DEFAULT("마우스 왼쪽클릭 드래그 이동", this, "ANCHOR_TOPRIGHT",-250, 0);
    end,
    ["CLOSE"] = function()
            FP_Tooltip_Func.DEFAULT("창 닫기", this, "ANCHOR_BOTTOM", 50, 0);
    end,
    ["MAXMIZE"] = function()
            FP_Tooltip_Func.DEFAULT("창 최대화", this, "ANCHOR_BOTTOM", 50, 0);
    end,
    ["MINIMIZE"] = function()
            FP_Tooltip_Func.DEFAULT("창 최소화", this, "ANCHOR_BOTTOM", 50, 0);
    end,
    ["DECREASE"] = function()
            FP_Tooltip_Func.DEFAULT("창 줄이기", this, "ANCHOR_BOTTOM", 50, 0);
    end,
    ["INCREASE"] = function()
            FP_Tooltip_Func.DEFAULT("창 늘리기", this, "ANCHOR_BOTTOM", 50, 0);
    end,
    ["OPTION"] = function()
            FP_Tooltip_Func.DEFAULT("옵션", this, "ANCHOR_BOTTOM",40, 0);
    end,
    ["ACTIVATE"] = function()
            local msg;
            if (FP_Options.activated) then
               msg = "작동중\n클릭하면 작동 중단";
            else
               msg = "쉬는중\m클릭하면 다시 작동";
            end
            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",50, 0);

    end,
    ["ANNOUNCE"] = function()
            local msg;
            if (FP_IsAnnoucing()) then
               msg = "파티 광고중\n클릭하면 중단";
            else
               msg = "클릭하면 파티광고 시작";
            end
            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",80, 0);
    end,
    ["ACTIVATEBELLNWINDOW"] = function()
            local msg;
            if (FP_IsActiveBellnWindow()) then
               msg = "벨소리 & 팝업 모드 작동중\n클릭하면 중단";
            else
               msg = "벨소리 & 팝업 모드 쉬는중";
            end
            FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",80, 0);
    end,
    ["APPLYBINDING"] = function()
        local msg = "단축키 : Alt + Click";
        FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",80, 0);
    end,
    ["EXCEPTIONBINDING"] = function()
        local msg = "단축키 : Ctrl + Click";
        FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",80, 0);
    end,
    ["WHOBINDING"] = function()
        local msg = "단축키 : Shift + Click";
        FP_Tooltip_Func.DEFAULT(msg, this, "ANCHOR_BOTTOM",80, 0);
    end,
};

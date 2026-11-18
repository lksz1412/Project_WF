--GetRealmName(), UnitFactionGroup
BINDING_HEADER_FINDPARTY = "파티찾기 도우미(FindParty)";

tinsert(UISpecialFrames, "FP_Frame"); -- So we can close it with escape

local debugSwitch = nil;

FP_Scroll_Info = nil;
FP_Options = nil;
FP_Version = 1;
FP_DUNGEON_LIST = nil;
FP_Filter_Dungeon_Info = nil;
FP_UserDefinedAdMsg = nil;  --from 1.12
FP_Filter_Class = nil;

local FP_Datas = {};
local MAX_VIEW_LINE = 30;
local MIN_VIEW_LINE = 1;
local FP_Exceptions = {};

local FP_OPTION_LIST = {
    [1] = {["광고 주기"] ={"10","20","30","45","60","90","120","300","600"}},
    [2] = {["유효 시간"] ={"30","60", "90","120", "300", "600"}},
    [3] = {["파티찾기 채널"] ={}},
    [4] = {[""] = {}},
    [5] = {["전체 크기"] = {"2","1.9","1.8","1.7","1.6","1.5","1.4",
                "1.3","1.2","1.1","1", "0.9","0.8", "0.7", "0.6",
                "0.5"}
            },
    [6] = {["글자 크기"] = {"12","13", "14","15","16","17","18"}},
    [7] = {["창 색상 편집"] = {}},
    [8] = {[""] = {}},
    [9] = {["던젼 편집"] = {}},
    [10] = {[""] = {}},
    [11] = {["초기화"] = {"창 위치", "창 크기"}},
    [12] = {[""] = {}},
    [13] = {["귀속던전 제외"] = {}},
}

local FP_OPTION_NAME = {
    ["광고 주기"] = "interval" ,
    ["유효 시간"] = "valid"  ,
    ["파티찾기 채널"] = "channel",
    ["전체 크기"] = "scale",
    ["글자 크기"] = "fontsize",
    ["초기화"] = "reset",
    ["창 색상 편집"] = "color",
    ["귀속던전 제외"] = "belong",
}

local Party_Find_Info = {
        ["class"]={},
        ["mode"] = "일반",
        ["dungeon"] = "던전을 선택해주세요",
        ["selected"] = false,
        ["announcing"] = false,
        --["userdefine"] = false,
        --["userdefineWh"] = false,
};

local ShouterSelected = nil;

local ASCD = true;
local DESC = false;

local INC = 1;
local DEC = 2;
local MAX = 3;
local MIN = 4;

local FP_Sort_Info = {
        ["time"] = ASCD,
        ["dungeon"] = ASCD,
        ["name"] = ASCD,
        ["msg"] = ASCD,
        ["current_sort"] ="dungeon"
 };

local Col_Name = {"time", "dungeon", "name", "msg"}



local valdating_timer = 0;
local announce_timer = 0;

local User_Realm;
local User_Faction;

local FP_Default_Options= {
	["interval"] = 30,
	["valid"] = 60,
	["channel"] = { ["파티"] = true },
	["activated"] = true;
	["scale"] = 1,
	["fontsize"] = 13,
	["iconLocked"] = false,
	["color"] = { ["r"] = 0, ["g"] = 0,["b"] = 0,["opacity"] = 0.5, },
	["titlebarVisible"] = true,
	["menubarVisible"] = true,
	["activateBellnWindow"] = true,
};

local InfoDepository = {};

function FP_Init()
--    FP_Debug("Init");
--	FP_Debug("Version "..tostring(FP_Version).." / "..tostring(FP_CURRENT_VERSION));

    FP_GetChannels();

    if (not (FP_Version == FP_CURRENT_VERSION)) then
--	FP_Debug("--  New version Init");
        local oldOption = FP_Options;

        FP_Options = {};
        for k,v in pairs(FP_Default_Options) do
            FP_Options[k] = v;
        end
        FP_Options.channel = {};
        for k,v in pairs(FP_Default_Options.channel) do
            FP_Options.channel[k] = v;
        end
        FP_Options.color = {};
        for  k,v in pairs(FP_Default_Options.color) do
            FP_Options.color[k] = v;
        end

        if (oldOption) then
            for k,v in pairs(oldOption) do
              --  FP_Debug("Old option "..k.." / "..tostring(v));
                if (FP_Options[k] and type(FP_Options[k]) == type(v)) then
                    FP_Options[k] = v;
                end
            end
        end

        local oldScroll = FP_Scroll_Info;
        if (oldScroll) then
            for k, v in pairs(oldScroll) do
                FP_Scroll_Info[k] = v;
            end
        else
            FP_Scroll_Info = {
                ["max"] = MAX_VIEW_LINE,
                ["height"] = 25,
                ["viewLines"]=MAX_VIEW_LINE,
            };
        end

-- 던전리스트 변경으로 인한 버전변경(강제로 던전리스트 초기화)
        if (not FP_DUNGEON_LIST or FP_Version < 1.21) then
            FP_LoadDefaultDungeonList();
        end

        -- from 1.12
        FP_Filter_Dungeon_Info = {
            ["filtered"] = false,
            ["zones"] = {},
            ["dungeons"] = {},
            ["num"] = 0;
        }

        -- from 1.12
        FP_Filter_Class = "모두";

        FP_Version = FP_CURRENT_VERSION;
    end

    --FP_OPTION_LIST["던젼 편집"] = FP_DUNGEON_LIST;

    User_Realm = GetRealmName();
    User_Faction = UnitFactionGroup("player");

    FP_ListResize();
    FP_UIResize(FP_Options.scale);
    FP_FontResize();
    FP_SetListColor();

    FP_Activate(FP_Options.activated);

	if(FP_IsActiveBellnWindow()) then
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellActivated");
	else
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellDeactivated");
	end

    -- 타이틀바, 메뉴바 설정
    if (FP_Options.titlebarVisible) then
        FP_TitleFrame:Hide();
    else
        FP_TitleFrame:Show();
    end
    FP_ListFrameBridgeToTitle:GetScript("OnClick")();

    if (FP_Options.menubarVisible) then
        FP_MenuFrame:Hide();
    else
        FP_MenuFrame:Show();
    end
    FP_ListFrameBridgeToMenu:GetScript("OnClick")();

    --광고글 설정
    if (FP_UserDefinedAdMsg) then
        FP_FindFrameAdText:SetText(FP_UserDefinedAdMsg);
        if(FP_Options.userdefine) then FP_FindFrameEtc:SetChecked(true); end
    end
    if (FP_UserDefinedWhMsg) then
		FP_FindFrameWhText:SetText(FP_UserDefinedWhMsg);
		if(FP_Options.userdefineWh) then FP_FindFrameWhCheck:SetChecked(true); end
    end
	
    -- 던젼선택 설정
    FP_ListFrameFilterDungeonText:SetText("던전: "..FP_GetDungeonFilterDesc());

    -- 클래스선택 설정
    FP_ListFrameFilterClassText:SetText("직업 골라내기 : "..FP_Filter_Class);
	
end

function FP_Activate(active)
    FP_Options.activated = active;

    if (active) then
        FP_TitleFrameText:SetText(FP_C_TITLE);
        FP_TitleFrameActivation:SetNormalTexture("Interface\\AddOns\\FindParty\\activated");

        -- 재시작시 데이타 초기화
        FP_RemoveAllList();
        FP_Scroll();
    else
        FP_TitleFrameText:SetText(FP_C_TITLE.." (중단)");
        FP_TitleFrameActivation:SetNormalTexture("Interface\\AddOns\\FindParty\\deactivated");
        collectgarbage("collect");
    end
end

function FP_ActiveBellnWindow(active)

	if(active) then
		FP_Options["activateBellnWindow"] = false;
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellDeactivated");
	else
		FP_Options["activateBellnWindow"] = true;
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellActivated");
	end
end

function FP_CreateNewShoutingInfo()
    local info;
    local num = #InfoDepository;
    if (num > 0) then
        info = InfoDepository[num];
        table.remove(InfoDepository, num);
    else
        info ={["name"]= nil,
            ["class"] = nil,
            ["level"] = nil,
            ["msg"] = nil,
            ["time"] = 0,
            ["dungeon"]= nil,
            ["mode"]= nil,
			["user"]= nil,
        };
    end

    return info;
end

function FP_RestoreShoutingInfo(info)
    table.insert(InfoDepository, info);
end

function FP_GetChannels()
	FP_OPTION_LIST[3]["파티찾기 채널"] = {};

	for i=1, 20 do
		local id, name = GetChannelName(i);
		if (id and name) then
			table.insert(FP_OPTION_LIST[3]["파티찾기 채널"], tostring(name));
		end
	end
end

function FP_DungeonParse(msg)
    local dungeon = nil;
    local mode = "일반";
	local FP_dungeon_check = true;
	local FP_MODE_check = true;
	local dungeon_status = nil;

	--FP_Debug("msg : "..msg)
	for zone,dlist in pairs(FP_DUNGEON_LIST) do
		--FP_Debug("zone"..zone);
-- for in pairs문으로 리스트를 불러들일때 랜덤이라서.. 공격대 던전 모집의 경우 여러가지가 겹치니 (ex:마그 막공 모집시 카라잔 이상템..)
		if zone ~= "공격대" then
			--FP_Debug("==========="..zone.."============");
			for v,k in pairs(dlist) do
				for i=1, table.getn(k) do
					--FP_Debug("+++"..k[i])
					if (string.find(msg, k[i])) and FP_dungeon_check then
						
						dungeon = v;
 							
						FP_Debug("dungeon :: "..tostring(dungeon));
						FP_dungeon_check = nil;
						
						dungeon_status = "5인던전";
					end
				end
			end
		else
			--FP_Debug("----------"..zone.."------------");
			for k=1, table.getn(FP_RAID_ORDER) do
				FP_Debug("FP_RAID_ORDER["..k.."]")
				for n = 1, table.getn(dlist[FP_RAID_ORDER[k]]) do
					FP_Debug(">>>"..dlist[FP_RAID_ORDER[k]][n])
					if (string.find(msg, dlist[FP_RAID_ORDER[k]][n])) and FP_dungeon_check then
						dungeon = FP_RAID_ORDER[k];
						FP_dungeon_check = nil;
						dungeon_status = "25_10인던전";
					end
				end
			end
		end
    end

	for k=1, table.getn(FP_DUNGEON_MODE_ORDER) do
		for n = 1, table.getn(FP_DUNGEON_MODE[FP_DUNGEON_MODE_ORDER[k]]) do
			if (string.find(msg, FP_DUNGEON_MODE[FP_DUNGEON_MODE_ORDER[k]][n])) and FP_MODE_check then
				
				mode = FP_DUNGEON_MODE_ORDER[k];
				
				if( dungeon_status=="25_10인던전" ) then

					if( mode=="일반" ) then mode="10인"; end
					if( mode=="영웅" ) then mode="25인"; end

				end
				
				FP_Debug("mode :: "..mode)
				FP_Debug(FP_DUNGEON_MODE[FP_DUNGEON_MODE_ORDER[k]][n]);
				FP_MODE_check = nil;
			end
		end
	end


	-- 묶이지 않았을 경우만 작동하도록 수정 변경 2009.05.23 edited by 일분일초 - 스톰레이지
	if (dungeon and mode) then
		if( mode~="명예" and mode~="업적") then
			for j=1, GetNumSavedInstances() do
				local name, id, remaining, difficulty = GetSavedInstanceInfo(j);
				FP_Debug(name.." "..difficulty);
				--FP_Debug(dungeon.." "..FP_DUNGEON_NUM[mode]);

				if (FP_Options[FP_OPTION_NAME["귀속던전 제외"]] and name == dungeon and difficulty == FP_DUNGEON_NUM[mode]) then
					
--					if (string.find(msg, id)) then return dungeon, "귀속"; end	-- 묶였을 경우 묶인 던전 id가 메시지에 있을 경우 작동  2009.05.27 edited by 일분일초 - 스톰레이지
					dungeon = nil;
					mode = nil;
				end
			end
		end
	end

	-- 던전 및 모드값이 없어도 묶인 id값이 msg에 있으면 귀속던전 제외에서 예외적으로 작동하도록 추가 2009.05.25 by 일분일초 - 스톰레이지
	for i=1, GetNumSavedInstances() do
		local name, id, remaining, difficulty = GetSavedInstanceInfo(i);
		if (string.find(msg, id)) then return "귀속된 던전 ID", "귀속"; end	-- 묶였을 경우 묶인 던전 id가 메시지에 있을 경우 작동
	end	
	
	if(dungeon and string.find(dungeon, "일퀘")) then mode="일퀘"; end
	--FP_Debug("|cffff0000■■■■■■|r"..dungeon.."|cffff0000■■■■■■|r"..mode)
	return  dungeon, mode;

--    for v,k in pairs(FP_DUNGEON_MODE) do
----        if (string.find(msg, v)) then
----            mode = v;
----        else
--            for i=1, table.getn(k) do
--                if (string.find(msg, k[i])) then
--                    mode = v;
--					FP_Debug("mode : "..mode)
----                    break;
--				    return  dungeon, mode;
--                end
--            end
----        end
--    end

--    return  dungeon, mode;
end

function FP_FP_Filter_Class(msg, class, mode)
	FP_Debug("|cffff0000■■■■■■FP_FP_Filter_Class Start|r");
    if (class=="모두") then return true; end
	if (mode=="귀속" or mode=="일퀘") then return true; end		-- 클래스 상관 없는 항목.. mode는 FP_DungeonParse 메소드에서 변형한 것임. 2009.05.27 edited by 일분일초 - 스톰레이지
FP_Debug("Filtering : "..msg)
    for i=1, table.getn(FP_CLASS_LIST[class]) do
FP_Debug("Filtered by "..FP_CLASS_LIST[class][i]);
        if (string.find(msg, FP_CLASS_LIST[class][i])) then

            return true;
        end
    end
	FP_Debug("|cffff0000■■■■■■FP_FP_Filter_Class End|r");
    return false;
end

function FP_DungeonFilter(dungeon, mode)
    FP_Debug("|cffff0000■■■■■■FP_DungeonFilter Start|r");
    FP_Debug(dungeon);
    FP_Debug(mode);
    FP_Debug(FP_Filter_Dungeon_Info.dungeon);
    FP_Debug(FP_Filter_Dungeon_Info.mode);
	FP_Debug(FP_Filter_Dungeon_Info.filtered);
	--if (mode=="귀속") then return true; end	-- 귀속 던전인 경우 어떤 던전이든 상관없이 true. 2009.05.27 edited by 일분일초 - 스톰레이지
    if (FP_Filter_Dungeon_Info.filtered) then
        if (FP_Filter_Dungeon_Info.dungeons["ALL"]) then
            return FP_Filter_Dungeon_Info.dungeons["ALL"].mode == mode;
        else
            for d, m in pairs(FP_Filter_Dungeon_Info.dungeons) do
                if (dungeon == d) then
                    if (m.mode == "둘다") then
                        return true;
                    else
                        return m.mode == mode;
                    end
                end
            end

            return false;
        end
    end
	FP_Debug("|cffff0000■■■■■■FP_DungeonFilter End|r");
    return true;
end

function FP_ExceptionFilter(exception)
--    FP_Debug("Filtering");
--    FP_Debug(dungeon);
--    FP_Debug(mode);
--    FP_Debug(FP_Filter_Dungeon_Info.dungeon);
--    FP_Debug(FP_Filter_Dungeon_Info.mode);
--ShouterSelected.name
    if (FP_Exceptions) then

		for i=1,#FP_Exceptions,1 do
			if (FP_Exceptions[i]==exception) then
				return false;
			end
		end    	
    end

    return true;
end

function FP_AddList(name, msg)
	FP_Debug("FP_AddList");
	FP_Debug("msg : "..msg);
    local dungeon, mode = FP_DungeonParse(msg);

    if (dungeon) then
    	FP_Debug("dungeon : name - "..dungeon.." : "..name);
        if (FP_Datas[name]) then
            FP_Datas[name].dungeon = dungeon;
            FP_Datas[name].msg = msg;
            FP_Datas[name].time = 0;
            FP_Datas[name].mode = mode;
        else
            local info = FP_CreateNewShoutingInfo();
            info.name=name;
            info.class = nil;
            info.level = nil;
            info.msg = msg;
            info.time = 0;
            info.dungeon = dungeon;
            info.mode = mode;

            --for using Prat
            --[[
            if (PratDB) then
                if (not User_Realm) then
                    User_Realm = GetRealmName();
                    User_Faction = UnitFactionGroup("player");
                end

                if (User_Realm) then
                    local dbTable = tostring(User_Realm).." - "..tostring(User_Faction);

                    if (PratDB.namespaces.PlayerNames.realms[dbTable]
                        and PratDB.namespaces.PlayerNames.realms[dbTable].classes
                        and PratDB.namespaces.PlayerNames.realms[dbTable].levels)
                    then
                        info.class = PratDB.namespaces.PlayerNames.realms[dbTable].classes[name];
                        info.level = PratDB.namespaces.PlayerNames.realms[dbTable].levels[name];
                    end
                end

               -- FP_Debug(name.." > "..tostring(info.class).." / "..tostring(info.level));
            end
            ]]--
            if (Prat_PlayerNames and Prat_PlayerNames.Levels and Prat_PlayerNames.Classes) then
                info.level = Prat_PlayerNames.Levels[name];
                info.class = Prat_PlayerNames.Classes[name];
            end


            table.insert(FP_Datas,info);
            FP_Datas[name] = info;

        end

        FP_Scroll();
    end

end

function FP_RemoveList(name)
    if (FP_Datas[name]) then
        if (ShouterSelected and ShouterSelected.name == name) then
            ShouterSelected = nil;
        end

        for i=1, table.getn(FP_Datas) do
            FP_Debug("i = "..i.." / "..table.getn(FP_Datas).."  name = "..FP_Datas[i].name.." / "..name);
            if (FP_Datas[i].name == name) then
                FP_Debug("Matched");
                FP_RestoreShoutingInfo(FP_Datas[i]);
                table.remove(FP_Datas, i);
                break;
            end
        end
        FP_Datas[name] = nil;

	--collectgarbage("collect");
        FP_Scroll();
    end
end

function FP_RemoveAllList()
    FP_Datas = {};
    ShouterSelected = nil;
    InfoDepository = {};

    collectgarbage("collect");
end


function FP_Refresh(quick)
	FP_Debug("|cffff0000■■■■■■FP_Refresh Start|r");
    local listOffset = FauxScrollFrame_GetOffset(FP_ListFrameScrollFrame);
    if (not listOffset) then listOffset = 0; end

    if (not quick)  then
        local sort_col = FP_Sort_Info.current_sort;
        local ascd = FP_Sort_Info[sort_col];

        FP_ListSort(FP_Datas, sort_col, ascd);
    end

    local dataIdx =listOffset + 1;
    local rowIdx = 1;
    while (rowIdx <= MAX_VIEW_LINE) do
        --FP_Debug("while");
        --FP_Debug("row ="..rowIdx.." data ="..dataIdx);

        local rowName ="FP_ListFrameRow"..tostring(rowIdx);
        local info = nil;
        if (rowIdx <= FP_Scroll_Info.viewLines) then
            info = FP_Datas[dataIdx];
        end

        --FP_Debug("info "..tostring(info));

        if (info) then

        	FP_Debug("FP_DungeonFilter-FP_FP_Filter_Class-FP_ExceptionFilter :: "..tostring(FP_DungeonFilter(info.dungeon, info.mode)).."-"..tostring(FP_FP_Filter_Class(info.msg, FP_Filter_Class)).."-"..tostring(FP_ExceptionFilter(info.name)));
			if (not FP_DungeonFilter(info.dungeon, info.mode) or not FP_FP_Filter_Class(info.msg, FP_Filter_Class, info.mode) or not FP_ExceptionFilter(info.name)) then

                getglobal(rowName):Hide();
                rowIdx = rowIdx - 1;
                FP_Scroll_Info.max = FP_Scroll_Info.max - 1;
                FauxScrollFrame_Update(FP_ListFrameScrollFrame,
                            FP_Scroll_Info.max,
                            FP_Scroll_Info.viewLines,
                            FP_Scroll_Info.height);
                if (info == ShouterSelected) then ShouterSelected = nil; end
            else
				if(info.time<=0) then
					if(FP_Options["activateBellnWindow"]) then
						PlaySoundFile("Interface\\AddOns\\FindParty\\FindParty.wav");
						FP_Frame:Show();
						info.time=1;
					end
				end
                getglobal(rowName):Show();
                getglobal(rowName):SetID(dataIdx);
                -- Time
                getglobal(rowName.."TimeText"):SetText(info.time);

                --Message
                local msg = info.msg;
                for class, alias in pairs(FP_CLASS_LIST) do
                    for i=1, getn(alias) do
                        msg = string.gsub(msg, alias[i], "|cffffff00"..alias[i].."|r");
                    end
                end
                getglobal(rowName.."MsgText"):SetText(msg);

                getglobal(rowName.."DungeonText"):SetText(info.dungeon);

-- 색처리 세분화 / 수정
				if (info.mode == "25인") then
                    getglobal(rowName.."DungeonText"):SetTextColor(1.0, 0.7, 0);
                elseif (info.mode == "10인") then
                    getglobal(rowName.."DungeonText"):SetTextColor(0, 1, 0);
				elseif (info.mode == "명예") then
					getglobal(rowName.."DungeonText"):SetTextColor(1, 0, 0);
                elseif (info.mode == "영웅") then
                    getglobal(rowName.."DungeonText"):SetTextColor(0.5, 0.5, 0.8);
				elseif (info.mode == "귀속") then
					getglobal(rowName.."DungeonText"):SetTextColor(1, 0.75, 0.2);
                else
                    getglobal(rowName.."DungeonText"):SetTextColor(1,1,1);
                end

                -- Name
                local name = info.name;
                if (info.level) then name = name.." ("..tostring(info.level)..")"; end
                if (info.class) then
                    local color = FP_CLASS_COLORS[info.class];
                    if (color) then
                        getglobal(rowName.."NameText"):SetTextColor(color.r, color.g, color.b);
                    end
                else
                    getglobal(rowName.."NameText"):SetTextColor(1,1,1);
                end
                getglobal(rowName.."NameText"):SetText(name);

                -- Highlight
                if (info == ShouterSelected) then
                    getglobal(rowName):LockHighlight();
                else
                    getglobal(rowName):UnlockHighlight();
                end
            end
        else
            getglobal(rowName):Hide();
        end -- end of if

                -- for next
        dataIdx = dataIdx + 1;
        rowIdx = rowIdx + 1;
    end -- end of while
	FP_Debug("|cffff0000■■■■■■FP_Refresh End|r");
end

function FP_Scroll()
    if (not FP_Scroll_Info) then return; end

    FP_Scroll_Info.max = table.getn(FP_Datas);

    FauxScrollFrame_Update(FP_ListFrameScrollFrame,
                            FP_Scroll_Info.max,
                            FP_Scroll_Info.viewLines,
                            FP_Scroll_Info.height);


    FP_Debug("offset = "..tostring(FauxScrollFrame_GetOffset(FP_ListFrameScrollFrame)));
    FP_Refresh();
end

function FP_ListAdjust(adjust)
    local newNumRow;
    local curNumRow = FP_Scroll_Info.viewLines;
    if (not adjust) then
        local curHeight = FP_ListFrame:GetHeight();
        newNumRow = math.floor((curHeight - 40) / FP_Scroll_Info.height);
    elseif (adjust == INC) then
        newNumRow = math.min(MAX_VIEW_LINE, FP_Scroll_Info.viewLines + 1);
    elseif (adjust == DEC) then
        newNumRow = math.max(MIN_VIEW_LINE, FP_Scroll_Info.viewLines - 1);
    elseif (adjust == MAX) then
        newNumRow =MAX_VIEW_LINE;
    elseif (adjust == MIN) then
        newNumRow =MIN_VIEW_LINE;
    end

--    for i=newNumRow + 1, curNumRow, 1 do
 --       getglobal("FP_ListFrameRow"..i):Hide();
 --   end

    FP_Scroll_Info.viewLines = newNumRow;

    FP_ListResize();
end

local COLUMFRAME = {"DungeonText", "NameText", "MsgText"};
function FP_FontResize()
    for i=1, MAX_VIEW_LINE do
        rowName = "FP_ListFrameRow"..i;
        for j=1, 3 do
            local tempFrame = getglobal(rowName..COLUMFRAME[j]);
            local fontFile, unused, fontFlags = tempFrame:GetFont();
            tempFrame:SetFont(fontFile, FP_Options.fontsize, fontFlags);
        end
    end
end

function FP_SetListColor()
    FP_ListFrame:SetBackdropColor(FP_Options.color.r, FP_Options.color.g, FP_Options.color.b, FP_Options.color.opacity);
end

function FP_UIResize(scale)
    FP_Frame:SetScale(scale);
end

function FP_ListResize()
    local newListHeight = 40 + FP_Scroll_Info.viewLines * FP_Scroll_Info.height;
    --local newScrollHeight = 15 + FP_Scroll_Info.viewLines * FP_Scroll_Info.height;

    FP_ListFrame:SetHeight(newListHeight);
   -- FP_ListFrameScrollFrame:SetHeight(newScrollHeight)
    --FP_ListFrameScrollFrameMiddle:SetHeight(newScrollHeight - 50);

    FP_Scroll();
end

function FP_SortButtonClicked()
	local id = this:GetID();

	FP_Debug("sort "..tostring(id));
	column = Col_Name[id];

	FP_Sort_Info[column] = not FP_Sort_Info[column];
	FP_Sort_Info.current_sort = column;

    FP_Refresh();
    return FP_Sort_Info[column];
end

function FP_ListSort(list, col, ascd)
    if (list ~= nil and col ~= nil) then
        local endIdx = getn(list)
        for i=1, endIdx,1 do
            for j=i+1, endIdx, 1 do
                local pivot = list[i][col];
                local comp = list[j][col];

                if ((ascd and (pivot > comp)) or (not ascd and (pivot < comp))) then
                    local temp = list[i];
                    list[i] = list[j];
                    list[j] = temp;
                end
            end
        end
    end
end


function FP_Party_Find_Class(class, selected)
    local temp = Party_Find_Info.class;
    if (selected) then
        table.insert(temp, class);
    else
        for i=1, table.getn(temp) do
            if (temp[i]==class) then
                table.remove(temp, i);
                break;
            end
        end
    end
end

function FP_Announce()
	FP_Debug("파티모으기 "..tostring(Party_Find_Info.dungeon).."  "..tostring(table.getn(Party_Find_Info.class)));
    local msg = "";

    if (FP_Options.userdefine) then
        msg = FP_FindFrameAdText:GetText();
        FP_UserDefinedAdMsg = msg; -- For save
        if (not msg or string.len(msg) == 0) then
            FP_Debug("|cffffff00광고글을 작성하셔야 합니다.");
            FP_StopAnnounce();
            return;
        end
    else
        if (Party_Find_Info.selected and table.getn(Party_Find_Info.class) > 0) then
            msg = Party_Find_Info.dungeon.." ("..Party_Find_Info.mode.." )";
            msg = msg.." --> ";
            for v,k in pairs(Party_Find_Info.class) do
                msg = msg.." "..k;
            end
            msg = msg.." <-- 오세요";
    	else
            FP_Debug("|cffffff00던전을 선택하고 클래스가 최소한 1개 이상 선택되어야 합니다.");
            FP_StopAnnounce();
            return;
        end
    end

	FP_Debug(msg);
	for k,v in pairs(FP_Options.channel) do
		if (v) then
			local chaNum = GetChannelName(k);
			SendChatMessage(msg, "CHANNEL",  this.language, chaNum);
		end
	end
end

function FP_StopAnnounce()
    FP_Debug("|cffffff00파티 모으기를 중단합니다.")
    Party_Find_Info.announcing = false;

    FP_FindFrameAnnounce:SetText("광고 시작");
    FP_TitleFrameAnnouncing:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking");
end

function FP_StartAnnounce()
    FP_Debug("|cffffff00파티 모으기를 시작합니다.")

    announce_timer = GetTime() * 1000;
    Party_Find_Info.announcing = true;

--    FP_Debug(tostring(GetTime() * 1000));

    FP_FindFrameAnnounce:SetText("광고 중단");
    FP_TitleFrameAnnouncing:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupNeedMore");

    FP_Announce();
end

function FP_IsAnnoucing()
    return Party_Find_Info.announcing;
end

function FP_IsActivated()
    return FP_Options.activated;
end

function FP_IsActiveBellnWindow()
    return FP_Options["activateBellnWindow"];
end

function FP_IconClicked()
    if (arg1 == "LeftButton") then
        if (IsAltKeyDown()) then
            this:SetMovable(true);
            FP_Options.iconLocked = not FP_Options.iconLocked;
        elseif (IsShiftKeyDown()) then
            FP_Activate(not FP_IsActivated());
        elseif (IsControlKeyDown()) then
            if (FP_IsAnnoucing()) then
                FP_StopAnnounce();
            else
                FP_StartAnnounce();
            end
        else
            if (FP_Frame:IsShown()) then
                FP_Frame:Hide()
            else
                FP_Frame:Show();
            end
        end
    else
        FP_MenuClicked("MENU_OPTION");
    end
end


function FP_MenuClicked(menu, option)
	FP_Debug("Menu "..tostring(menu).." "..tostring(option));
	FP_Debug("click "..tostring(arg1).." / "..tostring(arg2).." //"..tostring(arg3));

    if (menu == "MENU_DUNGEON") then

        UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuFindDungeon_Initialize, "MENU");
        ToggleDropDownMenu(1, nil, FP_DropDownMenu, this, 0, 0);
    elseif (menu == "MENU_FILTERDUNGEON") then
        if (arg1 == "LeftButton") then
            local filtered = FP_Filter_Dungeon_Info.filtered;

			if (filtered or (not filtered and FP_Filter_Dungeon_Info.num < 1)) then
				FP_SortButtonClicked();
				FP_Filter_Dungeon_Info.filtered = false;
				FP_ListFrameFilterDungeonText:SetText("던젼: 모두(정렬)");
			else
				FP_Filter_Dungeon_Info.filtered = true;
				FP_ListFrameFilterDungeonText:SetText(FP_GetDungeonFilterDesc());
			end

            FP_Scroll();
        else
            if (arg2) then

                UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuFilterDungeon_Initialize, "MENU");

                ToggleDropDownMenu(1, nil, FP_DropDownMenu, this, 0, 0);
            else
                CloseDropDownMenus();
            end
        end
    elseif (menu=="MENU_CLASS") then
        if (arg1 == "LeftButton") then
            FP_Debug("class filter "..FP_Filter_Class);
            if (FP_Filter_Class == UnitClass("player")) then
                this.value = "모두";
            else
                this.value = UnitClass("player");
            end

            FP_ClassSelected();
        else
            if (arg2) then
                UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuClass_Initialize, "MENU");
            end;
            ToggleDropDownMenu(1, nil, FP_DropDownMenu, this, FP_ListFrameFilterClass:GetWidth()/2, 0);
        end
    elseif (menu=="MENU_OPTION") then
        FP_GetChannels();
        UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuOption_Initialize, "MENU");
        ToggleDropDownMenu(1, nil, FP_DropDownMenu, this, 0, 0);
    elseif (menu == "MENU_APPLY") then
		if (ShouterSelected) then
			local playerClass =UnitClass("player");
			local msg="";
			if (FP_Options.userdefineWh) then
				msg = FP_FindFrameWhText:GetText();
				FP_UserDefinedWhMsg = msg; -- For save
			else
				msg = playerClass.." 손 !!";
			end
			FP_Debug(msg);
			SendChatMessage(msg, "WHISPER", this.language, ShouterSelected.name);
		end
	elseif (menu == "MENU_WHO") then
        if (ShouterSelected) then
--            local ppp=0
--            if string.find(ShouterSelected.name, "[a-z]+") then ppp=1 end
--            if ppp==1 then SendWho(ShouterSelected.name) else SendWho(ShouterSelected.name.."....") end
            SendWho(ShouterSelected.name)
        end
	elseif (menu == "MENU_EXCEPTION") then
		if (ShouterSelected) then
			if ( FP_Exceptions ) then savePlace = #FP_Exceptions+1; end
			FP_Exceptions[savePlace] = ShouterSelected.name

			for i=1,#FP_Exceptions,1 do
				FP_Debug(FP_Exceptions[i])	
			end
		end
	elseif (menu == "MENU_EXCEPTION_DELETE") then

		FP_Exceptions = {};	

    elseif (menu == "MENU_ANNOUNCE") then
        if (Party_Find_Info.announcing) then
            FP_StopAnnounce();
        else
            FP_StartAnnounce();
        end
	elseif (menu == "MENU_ACTIVATE_BELLNWINDOW") then
		
		FP_ActiveBellnWindow(FP_Options.activateBellnWindow);

    elseif (menu == "MENU_ACTIVATION") then
       -- FP_Debug("Activation changed");
        FP_Activate(not FP_Options.activated);
    elseif (menu == "MENU_INC") then
        FP_ListAdjust(INC);
    elseif (menu == "MENU_DEC") then
        FP_ListAdjust(DEC);
    elseif (menu == "MENU_MAX") then
        FP_ListAdjust(MAX);
    elseif (menu == "MENU_MIN") then
        FP_ListAdjust(MIN);
    elseif (menu == "MENU_INFO") then
        for i=1, table.getn(FP_HELPS) do
            FP_Debug(FP_HELPS[i]);
        end
    elseif (menu == "SEL_SHOUT") then
        local index = this:GetID();
        local data = FP_Datas[index];

        if (IsAltKeyDown()) then
            ShouterSelected = data;
            FP_MenuClicked("MENU_APPLY");
        elseif (IsShiftKeyDown()) then
            ShouterSelected = data;
            FP_MenuClicked("MENU_WHO");
        elseif (IsControlKeyDown()) then
        	ShouterSelected = data;
        	FP_MenuClicked("MENU_EXCEPTION");
        else
            if (ShouterSelected == data) then
                ShouterSelected = nil;
            else
                ShouterSelected = data;
            end
        end

        FP_Refresh();
    elseif (menu=="SEL_ETC") then
        FP_Options.userdefine = option;
    elseif (menu=="SEL_ETC2") then
        FP_Options.userdefineWh = option;
		--Party_Find_Info.userdefineWh = option;
    elseif (menu=="SEL_WARRIOR") then FP_Party_Find_Class( "전사", option);
    elseif (menu=="SEL_PRIEST") then FP_Party_Find_Class("사제", option);
    elseif (menu=="SEL_PALADIN") then FP_Party_Find_Class("성기사", option);
    elseif (menu=="SEL_MAGE") then FP_Party_Find_Class("마법사", option);
    elseif (menu=="SEL_WARROCK") then FP_Party_Find_Class("흑마법사", option);
    elseif (menu=="SEL_HUNTER") then FP_Party_Find_Class("사냥꾼", option);
    elseif (menu=="SEL_DRUID") then FP_Party_Find_Class("드루이드", option);
    elseif (menu=="SEL_ROGUE") then FP_Party_Find_Class("도적", option);
    elseif (menu=="SEL_SHAMAN") then FP_Party_Find_Class("주술사", option);
	elseif (menu=="SEL_DEATHKNIGHT") then FP_Party_Find_Class("죽음의기사", option);
    end
end

function FP_LoadDefaultDungeonList()

    FP_Debug("|cffffff00 던전 리스트 기본값을 불러옵니다");
    FP_DUNGEON_LIST = {};
    sort(FP_DEFAULT_DUNGEON_LIST);
    for z, dTbl in pairs(FP_DEFAULT_DUNGEON_LIST) do
		FP_Debug("zone : "..z)
        FP_DUNGEON_LIST[z] = {};
        
        sort(dTbl);
        for d,aTbl in pairs(dTbl) do
        	FP_Debug("dungeon : "..d)
            FP_DUNGEON_LIST[z][d] = {};

			sort(aTbl);
            for i, alias in ipairs(aTbl) do
                FP_DUNGEON_LIST[z][d][i] = alias;
            end
        end
    end
    --FP_OPTION_LIST["던젼 편집"] = FP_DUNGEON_LIST;
end

function FP_AddDungeonList()
FP_Debug("FP_AddDungeonList start.");
    local value = UIDROPDOWNMENU_MENU_VALUE;

    -- trimming text
    local item = this:GetText();
    local useless, useless, str = string.find(item, "(%S+.*)");
    if (str) then
        useless, useless, str = string.find(str, "(.*%S+)");
    else
        return;
    end

    item = str;

    this:SetText(""); -- edit box
    info = {};
    info.notCheckable = true;
    info.hasArrow = true;
    info.value = {
        ["level"] = value.level,
        ["Zone"] = item,
    }

    if (value.level == 2) then
        FP_DUNGEON_LIST[item] = {};

        info.text = item;
        info.value.Zone = item;
        info.value.subarray = FP_DUNGEON_LIST[item];
    elseif (value.level == 3) then
        FP_DUNGEON_LIST[value.Zone][item] = {item};

        info.text = item;
        info.value.Zone = value.Zone;
        info.value.Dungeon = item;
        info.value.subarray = FP_DUNGEON_LIST[value.Zone][item];
    elseif (value.level == 4) then
        table.insert(FP_DUNGEON_LIST[value.Zone][value.Dungeon], item);
        info.text = item;
        info.value.Zone = value.Zone;
        info.value.Dungeon = value.Dungeon;
        info.value.Alias = item;
        info.value.index = #FP_DUNGEON_LIST[value.Zone][value.Dungeon];
    end

	FP_Debug("zone-dungeon-alias-index"..info.value.Zone.."-"..info.value.Dungeon.."-"..info.value.Alias.."-"..info.value.index);
    UIDropDownMenu_AddButton(info, value.level);
    UIDropDownMenu_Refresh(self, value, value.level);
end

function FP_RemoveDungeonList()

    value = this.value;

    if (value.level == 3) then
        if (next(FP_DUNGEON_LIST[value.Zone])) then
            FP_Debug("|cffffff00던젼 항목들이 하나도 없을 때에만 삭제가 가능합니다.");
        else
            FP_DUNGEON_LIST[value.Zone] = nil;

            HideDropDownMenu(value.level);
            for i=1,UIDROPDOWNMENU_MAXBUTTONS do
                local button = getglobal("DropDownList"..(value.level-1).."Button"..i);
                if (button and button.value and button.value.Zone == value.Zone) then
                    button:Hide();
                    break;
                end
            end
        end
    elseif (value.level == 4) then
        FP_DUNGEON_LIST[value.Zone][value.Dungeon] = nil;

        HideDropDownMenu(value.level);
        for i=1,UIDROPDOWNMENU_MAXBUTTONS do
            local button= getglobal("DropDownList"..(value.level-1).."Button"..i);
            if (button and button.value and button.value.Dungeon == value.Dungeon) then
                button:Hide();
                break;
            end
        end
    elseif (value.level == 5) then
        local array = FP_DUNGEON_LIST[value.Zone][value.Dungeon];
        for i=1, #FP_DUNGEON_LIST[value.Zone][value.Dungeon] do
            if (FP_DUNGEON_LIST[value.Zone][value.Dungeon][i] == value.Alias) then
                table.remove(FP_DUNGEON_LIST[value.Zone][value.Dungeon], i);
                break;
            end
        end

        HideDropDownMenu(value.level);
        for i=1,UIDROPDOWNMENU_MAXBUTTONS do
            local button= getglobal("DropDownList"..(value.level-1).."Button"..i);
            if (button and button.value and  button.value.Alias == value.Alias) then
                button:Hide();
                break;
            end
        end
    end
end

function FP_FindDungeonSelected()

    if (this.value) then
        Party_Find_Info.dungeon = this.value.Dungeon;
        Party_Find_Info.selected = true;

        if (this.value.Mode) then
            Party_Find_Info.mode = this.value.Mode;
        else
            Party_Find_Info.mode = "일반";
        end

        ToggleDropDownMenu(1, nil, FP_DropDownMenu, FP_FindFrameDungeon, 0, 0);
    end

    FP_FindFrameDungeonNameText:SetText(Party_Find_Info.dungeon);

-- 색처리 세분화 / 수정
	if (Party_Find_Info.mode == "25인") then
		FP_FindFrameDungeonNameText:SetTextColor(1.0, 0.7, 0);
	elseif (Party_Find_Info.mode == "10인") then
		FP_FindFrameDungeonNameText:SetTextColor(0, 1, 0);
	elseif (Party_Find_Info.mode == "명예") then
		FP_FindFrameDungeonNameText:SetTextColor(1, 0, 0);		
	elseif (Party_Find_Info.mode == "영웅") then
		FP_FindFrameDungeonNameText:SetTextColor(0.5, 0.5, 0.8);
	else
		FP_FindFrameDungeonNameText:SetTextColor(1,1,1);
	end


--	if (Party_Find_Info.mode =="영웅") then
--        FP_FindFrameDungeonNameText:SetTextColor(1.0, 0.82, 0);
--    else
--        FP_FindFrameDungeonNameText:SetTextColor(1,1,1);
--    end
end

function FP_FilterDungeonSelected(self)

    if (self.value) then
        if (self.value == "resetall") then
            FP_Filter_Dungeon_Info.dungeons = {};
            FP_Filter_Dungeon_Info.zones = {};
            FP_Filter_Dungeon_Info.filtered = false;
            FP_Filter_Dungeon_Info.num = 0;
        else
            FP_Filter_Dungeon_Info.filtered = true;

            local zone = self.value.Zone;
            local dungeon = self.value.Dungeon;
            local mode = self.value.Mode;

            if (not (dungeon == "ALL")) then -- dungeon이 ALL 인 경우는 영웅/일반 을 선택했을 경우
                -- 개별 던전이 선택되면 전체 선택(영웅 전체, 일반 전체)은 취소
                FP_Filter_Dungeon_Info.dungeons["ALL"] = nil;
            end

            if (not mode) then
                if (dungeon and FP_Filter_Dungeon_Info.dungeons[dungeon]) then
                    mode = FP_Filter_Dungeon_Info.dungeons[dungeon].mode;
                else
                    mode = "둘다";
                end
            end

            -- for Control
            --  변수값 조정
            if (dungeon) then
                if (FP_Filter_Dungeon_Info.dungeons[dungeon]) then
                    if (FP_Filter_Dungeon_Info.dungeons[dungeon].mode == mode) then
                        if (zone) then  -- 영웅/일반 모드 선택시에는 zone 정보가 nil
                            FP_Filter_Dungeon_Info.zones[zone] = nil;
                        end
                        FP_Filter_Dungeon_Info.dungeons[dungeon] = nil;
                        FP_Filter_Dungeon_Info.num = FP_Filter_Dungeon_Info.num - 1;
                        FP_Filter_Dungeon_Info.filtered = not (FP_Filter_Dungeon_Info.num == 0);
                    else
                        if (FP_Filter_Dungeon_Info.dungeons[dungeon].mode == "둘다") then
                            if (mode == "영웅") then
                                FP_Filter_Dungeon_Info.dungeons[dungeon].mode = "일반";
                            else
                                FP_Filter_Dungeon_Info.dungeons[dungeon].mode = "영웅";
                            end
							FP_RegistLFG(dungeon, "일반");	-- Looking For Group 자동 추가 메소드(예정)
							FP_RegistLFG(dungeon, "영웅");	-- Looking For Group 자동 추가 메소드(예정)
                        else
                            FP_Filter_Dungeon_Info.dungeons[dungeon].mode = mode;
							FP_RegistLFG(dungeon, mode);	-- Looking For Group 자동 추가 메소드(예정)
                        end
                    end
                else
                    FP_Filter_Dungeon_Info.dungeons[dungeon] = {["mode"] = mode, ["zone"]=zone};
                    FP_Filter_Dungeon_Info.num = FP_Filter_Dungeon_Info.num + 1;
                end
            else
                -- zone 영역 전체 선택
                if (not self.checked) then
                    FP_Filter_Dungeon_Info.zones[zone] = true;
                else
                    FP_Filter_Dungeon_Info.zones[zone] = nil;
                end

                for k,v in pairs(FP_DUNGEON_LIST[zone]) do
                    if (not self.checked) then
                        FP_Filter_Dungeon_Info.dungeons[k] = {["mode"] = mode, ["zone"] = zone};
                        FP_Filter_Dungeon_Info.num = FP_Filter_Dungeon_Info.num + 1;
                    else
                        FP_Filter_Dungeon_Info.dungeons[k] = nil;
                        FP_Filter_Dungeon_Info.num = FP_Filter_Dungeon_Info.num - 1;
                    end
                end
               -- ToggleDropDownMenu(self.value.level + 1, self.value, self);
            end

            -- For GUI
            ToggleDropDownMenu(self.value.level + 1, self.value, FP_DropDownMenu, self, 0, 0, nil, self);

			if (FP_Filter_Dungeon_Info.dungeons["ALL"]) then
				local button1 = getglobal("DropDownList1Button2");
				local button2 = getglobal("DropDownList1Button3");
				if (self == button1) then
					button2.checked = nil;
					getglobal("DropDownList1Button3Check"):Hide();
				elseif (self == button2) then
					button1.checked = nil;
					getglobal("DropDownList1Button2Check"):Hide();
				end
			else
				--getglobal("DropDownList1Button2").checked = nil;
				--getglobal("DropDownList1Button3").checked = nil;
				getglobal("DropDownList1Button3Check"):Hide();
				getglobal("DropDownList1Button2Check"):Hide();
			end

            if (self.value.level == 2) then
                local point, upLevelButton = self:GetParent():GetPoint();
                if (upLevelButton.checked) then
                    upLevelButton.checked = nil;
                    getglobal(upLevelButton:GetName().."Check"):Hide();
                end
            end

            if (self.value.level == 3) then
                local point, upLevelButton = self:GetParent():GetPoint();
                upLevelButton.checked = FP_Filter_Dungeon_Info.dungeons[dungeon];
                if (upLevelButton.checked) then
                    getglobal(upLevelButton:GetName().."Check"):Show();
                else
                    getglobal(upLevelButton:GetName().."Check"):Hide();
                end

				for i=1,2 do
					local button = getglobal("DropDownList3Button"..i);
					if (self ~= button) then
						if (FP_Filter_Dungeon_Info.dungeons[dungeon] and FP_Filter_Dungeon_Info.dungeons[dungeon].mode ~= button.value.Mode) then
							getglobal("DropDownList3Button"..i.."Check"):Hide();
							button.checked = ni;
						end
					end
				end
			end

		end -- end of if (self.value=="resetall")...
	end -- end of if (self.value) then...

    FP_ListFrameFilterDungeonText:SetText("던전: "..FP_GetDungeonFilterDesc());
end

function FP_GetDungeonFilterDesc()

    local desc = "모두(정렬)";

    if (FP_Filter_Dungeon_Info.filtered) then
        if (FP_Filter_Dungeon_Info.dungeons["ALL"]) then
            desc = FP_Filter_Dungeon_Info.dungeons["ALL"].mode.." 던젼";
        else
            desc_z = "";
            local count_z = 0;
            for z, v in pairs(FP_Filter_Dungeon_Info.zones) do
                if (count_z > 0) then desc_z = desc_z..","; end
                desc_z = desc_z..z;
                count_z = count_z + 1;
            end

            desc_d = "";
            count_d = 0;
            for d, m in pairs(FP_Filter_Dungeon_Info.dungeons) do
                if (not FP_Filter_Dungeon_Info.zones[m.zone]) then
                    if (count_d > 0) then desc_d = desc_d..","; end
                    desc_d = desc_d..d;
                    FP_Debug("desc = "..desc);
                    if (m and (m.zone == "아웃랜드" or m.zone == "노스랜드")) then
                        desc_d = desc_d.."("..m.mode..")";
                      --  FP_Debug("desc = "..desc);
                    end
                    count_d = count_d + 1;
                end
            end
            FP_Debug("desc = "..desc);
            if (count_d > 1) then
                desc_d = count_d.."곳:"..desc_d;
            end
            FP_Debug("desc = "..desc);

            if (count_z > 0) then
                if (count_d > 0 ) then
                    desc = desc_z..","..desc_d;
                else
                    desc = desc_z;
                end
            elseif (count_d > 0) then
                desc = desc_d;
            else
                desc = "선택 없음";
            end
        end
    end

    return desc;
end

function FP_GetClassFilterInfo()
    return FP_Filter_Class;
end

function FP_ClassSelected()
    FP_Debug("class sected "..this.value);
    if (this.value) then
        FP_Filter_Class = this.value;

 --       FP_Debug("class filter = "..FP_Filter_Class);

        FP_Scroll();
    end

    FP_ListFrameFilterClassText:SetText("직업 골라내기 : "..FP_Filter_Class);
end

function FP_ColorSelected(previousValues)
    if (not previousValues) then
        FP_Options.color.r, FP_Options.color.g, FP_Options.color.b = ColorPickerFrame:GetColorRGB();
        FP_Options.color.opacity = OpacitySliderFrame:GetValue();
    else
        FP_Options.color=previousValues;
    end

--    FP_Debug("color r="..FP_Options.color.r.." g="..FP_Options.color.g.." b="..FP_Options.color.b.." a="..FP_Options.color.opacity);
    FP_SetListColor();
end

function FP_OptionSelected()

    if (this.value) then
        local option = this.value.Option;
        local value = this.value.Value;

        local opName = FP_OPTION_NAME[option];
        local opType = type(FP_Options[opName]);

        if (opType == "number") then
            FP_Options[opName] = tonumber(value);
        elseif (opType == "string") then
            FP_Options[opName] = tostring(value);
        elseif (opType == "nil" or opType == "boolean") then
            FP_Options[opName] = not FP_Options[opName];
        elseif (opType == "table") then
            FP_Options[opName][value] = not this.checked;
        end

        if (opName == "scale") then
            FP_UIResize(FP_Options.scale);
        elseif (opName == "fontsize") then
            FP_FontResize()
        elseif (opName == "reset") then
            FP_Options[opName] = nil;

            if (value == "창 위치") then
                FP_ListFrame:SetPoint("TOPLEFT", UIParent,"TOP", -(FP_ListFrame:GetWidth()/2), -50);
            elseif (value  == "창 크기") then
                FP_Options.scale = 1;
                FP_UIResize(FP_Options.scale);
                FP_ListAdjust(MAX);
                FP_ListFrame:SetWidth(650);
            end
        end

       -- ToggleDropDownMenu(1, nil, FP_DropDownMenu, FP_TitleFrameOption, 0, 0);
    end

end

local function DropDownMenuFilterDungeonCheck(level, key, upLevelKey)
    if (level == 2) then
        return FP_Filter_Dungeon_Info.dungeons[key];
    elseif (level == 3) then
        return (FP_Filter_Dungeon_Info.dungeons[upLevelKey]
                and
                (
                    FP_Filter_Dungeon_Info.dungeons[upLevelKey].mode == "둘다"
                    or
                    key == FP_Filter_Dungeon_Info.dungeons[upLevelKey].mode
                )
            );
    end
    return false;
end

function FP_DropDownMenuFilterDungeon_Initialize(frame, level)

	level = level or 1;
	local info = {};
	info.func = FP_FilterDungeonSelected;
	info.keepShownOnClick = true;

    if (level == 1) then
        info.text = "난이도별 선택";
        info.notCheckable = true;
        info.isTitle = true;
        UIDropDownMenu_AddButton(info, level);

        info.disabled = false;
        info.notCheckable = false;
        info.isTitle = false;
        for key, subarray in pairs(FP_DUNGEON_MODE) do
            info.text = key.." 던전 모두";
            info.checked = (FP_Filter_Dungeon_Info.dungeons["ALL"] and
                            FP_Filter_Dungeon_Info.dungeons["ALL"].mode == key);
            info.value = {
                ["Dungeon"] = "ALL",
                ["Mode"] = key,
                ["level"] = level;
            };

            UIDropDownMenu_AddButton(info, level);
        end
        info.checked = false;

        -- 한줄 비움
        info.text = "";
        info.disabled = true;
        UIDropDownMenu_AddButton(info, level);
        info.text = "인던별 선택";
        info.notCheckable = true;
        info.isTitle = true;
        UIDropDownMenu_AddButton(info, level);
        info.disabled = false;
        info.isTitle = false;
        info.notCheckable = false;
        info.hasArrow = true; -- creates submenu
        for key, subarray in pairs(FP_DUNGEON_LIST) do
            info.text = key;
            info.checked = FP_Filter_Dungeon_Info.zones[key];
            info.value = {
                 ["Zone"] = key,
                 ["level"] = level,
            };

        	UIDropDownMenu_AddButton(info, level);
        end -- for key, subarray
    else

        FP_DropDownMenuDungeon_Initialize(
			self,
            level,
            info,
            FP_FilterDungeonSelected,
            DropDownMenuFilterDungeonCheck
        );
    end

    if (level == 1) then
        -- 한줄 비움
        info.text = "";
        info.disabled = true;
        info.checked = false;
        info.hasArrow = false;
        UIDropDownMenu_AddButton(info, level);

        info.text = "* 모두 초기화 *";
        info.value = "resetall";
        info.func = FP_FilterDungeonSelected;
        info.notCheckable = false;
        info.disabled = false;
        info.keepShownOnClick = false;
        info.textR = 0.95;
        info.textG = 0.30;
        info.textB = 0.30;
        UIDropDownMenu_AddButton(info, level);
    end
end

local function DropDownMenuFindDungeonCheck(level, key, upLevelKey)
    if (level == 2) then
        return Party_Find_Info.dungeon == key;
    elseif (level == 3) then
        return Party_Find_Info.dungeon == upLevelKey
                and
               Party_Find_Info.mode == key;
    end
end

function FP_DropDownMenuFindDungeon_Initialize(frame, level)
    FP_DropDownMenuDungeon_Initialize(
		self,
        level,
        {},
        FP_FindDungeonSelected,
        DropDownMenuFindDungeonCheck
    );
end

local inputEditBox;

function FP_DropDownMenuEditDungeon_Initialize(frame, level)
    local info = {};
    local menuValue = UIDROPDOWNMENU_MENU_VALUE;
    info.notCheckable = true;
    --info.keepShownOnClick = true;

    if (level == 2) then
        info.text = "기본값 불러오기";
        info.func = FP_LoadDefaultDungeonList;
        info.hasArrow = false;
        info.notCheckable = true;
        UIDropDownMenu_AddButton(info, level);

        -- 한줄 비움
        info.text = "";
        info.disabled = true;
        UIDropDownMenu_AddButton(info, level);
        info.disabled = false;
    end

    if (level > 2 and not menuValue["command"]) then
        if (inputEditBox) then inputEditBox:Hide(); end

        if (level == 3) then
            info.text= "<---"..menuValue["Zone"].." 삭제";
        elseif (level == 4) then
            info.text= "<---"..menuValue["Dungeon"].." 삭제";
        elseif (level == 5) then
            info.text= "<---"..menuValue["Alias"].." 삭제";
        end
        info.disabled = false;
        info.hasArrow = false;
        info.func = FP_RemoveDungeonList;
        info.level = level;
        info.value = {
            ["command"] = "remove",
            ["Zone"] = menuValue["Zone"],
            ["Dungeon"] = menuValue["Dungeon"],
            ["Alias"] = menuValue["Alias"],
            ["level"] = level
        }
        UIDropDownMenu_AddButton(info, level);
        info.func = nil;

        if (level < 5) then
            -- 한줄 비움
            info.text = "";
            info.disabled = true;
            info.hasArrow = false;
            UIDropDownMenu_AddButton(info, level);
            info.disabled = false;
        end
    end

    -- 레벨별 메뉴 제목
    if (level == 2) then
        info.text = "지역 구분";
    elseif (level == 3) then
        info.text = "던젼 이름";
    elseif (level == 4) then
        info.text = "던젼 별명";
    end
    if (level < 5 and not menuValue["command"]) then
        info.isTitle = true;
        info.justifyH = "CENTER";
        UIDropDownMenu_AddButton(info, level);
        info.isTitle = false;
        info.justifyH = nil;
    end
    info.isTitle = false;

    -- 각 레벨렬 추가 메뉴
    if (level < 5  and not menuValue["command"]) then
        -- 한줄 비움
        info.text = "------------------";
        info.isTitle = true;
        info.justifyH = "CENTER";
        UIDropDownMenu_AddButton(info, level);
        info.isTitle = false;
        info.justifyH = nil;

        info.disabled = false;
        info.text= "항목 추가";
        info.hasArrow = true;
        info.value = {
            ["Option"] = "던젼 편집",
            ["command"] = "add",
            ["Zone"] = menuValue["Zone"],
            ["Dungeon"] = menuValue["Dungeon"],
            ["Alias"] = menuValue["Alias"],
            ["level"] = level
        }
        UIDropDownMenu_AddButton(info, level);

        -- 한줄 비움
        info.text = "";
        info.disabled = true;
        info.hasArrow = false;
        UIDropDownMenu_AddButton(info, level);
        info.disabled = false;

        info.func = nil;
        info.hasArrow = true;
    end

    -- 던젼 리스트출력
    if (level == 2) then
        menuValue["subarray"] = FP_DUNGEON_LIST;
    end
    if (level > 1 and level < 6) then

        if (menuValue["command"] == "add") then
            info.text ="                            ";
            info.hasArrow = false;
            UIDropDownMenu_AddButton(info, level);

            local tempParent = getglobal("DropDownList"..level.."Button1");
            if (not inputEditBox) then
                inputEditBox = CreateFrame("EditBox", nil, tempParent , "InputBoxTemplate");
                inputEditBox:SetScript("OnEnterPressed", FP_AddDungeonList);
            end
            inputEditBox:SetParent(tempParent);
            inputEditBox:ClearAllPoints();
            inputEditBox:SetAllPoints(tempParent);
            inputEditBox:Show();

            inputEditBox:SetFocus();
        elseif (type(menuValue["subarray"]) == "table") then
            local subarray = menuValue["subarray"];
            local idx, v;
            while(true) do
                idx,v = next(subarray, idx);
                if (not idx) then break; end

                if (type(idx) == "number") then
                    info.text = v;
                else
                    info.text = idx;
                end
                info.value = {};
                info.value.subarray = v;
                info.level = level;

                if (not menuValue.Alias) then
                    if (not menuValue.Dungeon) then
                        if (not menuValue.Zone) then
                            info.value.Zone = idx;
                        else
                            info.value.Dungeon = idx;
                            info.value.Zone = menuValue.Zone;
                        end
                    else
                        info.value.Alias = v;
                        info.value.Zone = menuValue.Zone;
                        info.value.Dungeon = menuValue.Dungeon;
                    end
                end

                UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

function FP_DropDownMenuDungeon_Initialize(frame, level, info, targetFunc, checkFunc)
    level = level or 1;
    if (not checkFunc) then checkFunc = function() return false; end end

    if (level == 1) then
        info.hasArrow = true; -- creates submenu
        info.notCheckable = true;
        info.func = nil;

         for key, subarray in pairs(FP_DUNGEON_LIST) do
            info.text = key;
            info.value = {
             ["Zone"] = key,
             ["level"] = level
            };
            UIDropDownMenu_AddButton(info, level);
         end -- for key, subarray
    end -- if level 1

    if (level == 2) then
        -- getting values of first menu
        local Level1_Key = UIDROPDOWNMENU_MENU_VALUE["Zone"];
        subarray = FP_DUNGEON_LIST[Level1_Key];
        if (subarray) then

            info.hasArrow = (Level1_Key == "아웃랜드" or Level1_Key == "노스랜드" or Level1_Key == "아제로스" or Level1_Key == "공격대"); -- no submenues this time
            info.func =targetFunc;

            for key, subsubarray in pairs(subarray) do
                --info.notCheckable = (Level1_Key == "아웃랜드");
                info.text = key;
                info.checked = checkFunc(level, key);
                info.value = {
                 ["Zone"] = Level1_Key,
                 ["Dungeon"] = key,
                 ["level"] = level
                };
                UIDropDownMenu_AddButton(info, level);
            end -- for key,subsubarray
        end
    end -- if level 2

   if (level == 3) then
        local Level1_Key = UIDROPDOWNMENU_MENU_VALUE["Zone"];
        local Level2_Key = UIDROPDOWNMENU_MENU_VALUE["Dungeon"];
        info.func = targetFunc;

        for key, subarray in pairs(FP_DUNGEON_MODE) do
            info.text = Level2_Key.." "..key;
            info.checked = checkFunc(level, key, Level2_Key);
            info.value = {
                 ["Zone"] = Level1_Key,
                 ["Dungeon"] = Level2_Key,
                 ["Mode"] = key,
                 ["level"] = level
               };
            UIDropDownMenu_AddButton(info, level);
        end
    end
end

function FP_DropDownMenuClass_Initialize(frame, level)
    local info = UIDropDownMenu_CreateInfo();

    info.func = FP_ClassSelected;

    for key, subarray in pairs(FP_CLASS_LIST) do
        info.text = key;
        info.value = key;
        info.checked = (key == FP_Filter_Class);
        UIDropDownMenu_AddButton(info);
    end -- for key, subarray
end

function FP_DropDownMenuOption_Initialize(frame, level)
    level = level or 1;
    local info = UIDropDownMenu_CreateInfo();

    if (level == 1) then

         for idx, tbl in ipairs(FP_OPTION_LIST) do
            info.notCheckable = true;
            name = next(tbl);

            info.text = name;
            info.hasArrow = name ~= ""; -- creates submenu
            info.disabled = name == "";
            info.hasColorSwatch = false;
            info.hasOpacity = false;
            info.func = nil;

            info.value = {
             ["Option"] = name,
             ["subarray"] =FP_OPTION_LIST[idx][name],
            };
            if (name == "창 색상 편집") then
                info.hasArrow = false;
                info.hasColorSwatch = true;
                info.hasOpacity = true;
                info.r = FP_Options.color.r;
                info.g = FP_Options.color.g;
                info.b = FP_Options.color.b;
                info.opacity = FP_Options.color.opacity;
                info.func = UIDropDownMenuButton_OpenColorPicker
                info.swatchFunc = FP_ColorSelected;
                info.opacityFunc = FP_ColorSelected;
                info.cancelFunc = FP_ColorSelected;
            end
            
            if (name == "귀속던전 제외") then
                info.hasArrow = false;
                
                if (FP_Options[FP_OPTION_NAME[name]]) then
                	info.notCheckable = nil;
                	info.checked = true;
                end
                info.func = FP_OptionSelected;
            end
            UIDropDownMenu_AddButton(info, level);
         end -- for key, subarray
    end -- if level 1

    if (level == 2) then
        local Level1_Key = UIDROPDOWNMENU_MENU_VALUE["Option"];
        local opName = FP_OPTION_NAME[Level1_Key];
        if (Level1_Key == "던젼 편집") then
            FP_DropDownMenuEditDungeon_Initialize(frame, level);
        else
            subarray = UIDROPDOWNMENU_MENU_VALUE["subarray"];
            info.func =FP_OptionSelected;

            for i=1, table.getn(subarray) do
                local item = subarray[i];
                info.text = item;
                info.value = {
                 ["Option"] = Level1_Key,
                 ["Value"] = item,
                };

                if (opName == "channel") then
                    info.checked = FP_Options[opName][item];
--                    info.keepShownOnClick = true;
                else
                    info.checked = (item == tostring(FP_Options[opName]));
                end

                UIDropDownMenu_AddButton(info, level);
            end -- for key,subsubarray
        end
    end -- if level 2

    if (level > 2) then
        FP_DropDownMenuEditDungeon_Initialize(frame, level);
    end

end

function FP_WhTextSaveByOnEnter()
	FP_UserDefinedWhMsg = msg;
	FP_Debug("FP_WhTextSaveByOnEnter");
end

function FP_OnLoad()
	FP_InviteControlFrame:RegisterEvent("VARIABLES_LOADED");
	FP_InviteControlFrame:RegisterEvent("ADDON_LOADED");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_SAY");
    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_WHISPER");
    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_SYSTEM");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL_JOIN");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL_LIST");
--    FP_InviteControlFrame:RegisterEvent("RAID_ROSTER_UPDATE");
--    FP_InviteControlFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
--    FP_InviteControlFrame:RegisterEvent("PARTY_MEMBER_ENABLE");
    FP_InviteControlFrame:RegisterEvent("WHO_LIST_UPDATE");
--    FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");
    FP_InviteControlFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function FP_OnEvent(event)
	if (event=="ADDON_LOADED") then
		ADDON_LOADED();
	end
    if (event=="VARIABLES_LOADED") then
    	FP_InviteControlFrame:UnregisterEvent("VARIABLES_LOADED");
        FP_Init();
    end
    if (not FP_Options or not FP_Options.activated) then return; end

    if (event == "CHAT_MSG_CHANNEL" and FP_Options.channel[arg9]) then
        FP_AddList(arg2, arg1);
    elseif (event == "CHAT_MSG_SYSTEM" or event == "WHO_LIST_UPDATE") then
        if (GetNumWhoResults() > 0 and ShouterSelected) then
            for i=1,GetNumWhoResults() do
                local charname, guildname, level, race, class, zone = GetWhoInfo(i);
                if (ShouterSelected.name == charname) then
                    ShouterSelected.class = class;
                    ShouterSelected.level = level;

                    FP_Refresh(true);
                    break;
                end
            end
        end
--    elseif (event == "CHAT_MSG_CHANNEL_NOTICE") then
--        FP_GetChannels();
    elseif (event == "PLAYER_ENTERING_WORLD") then
        User_Realm = GetRealmName();
        User_Faction = UnitFactionGroup("player");
    end
end

-- Looking For Group 자동 추가 메소드(예정)
function FP_registLFG(dungeon, mode)

end

function FP_OnUpdate()
    if (not FP_Options.activated) then return; end

    local time = GetTime() * 1000;
    local elapsed =  time - valdating_timer;
    if (elapsed > 1000 and table.getn(FP_Datas) > 0) then
        local i=1;
        while(i <= table.getn(FP_Datas)) do
            FP_Datas[i].time = FP_Datas[i].time + 1;

            if (FP_Datas[i].time > FP_Options.valid) then
                FP_RemoveList(FP_Datas[i].name);
            else
                i = i +1;
            end
        end
        valdating_timer = time;

        FP_Refresh(true);
    end

    if (Party_Find_Info.announcing == true) then
--        FP_Debug("time = "..tostring(time).."  timer ="..tostring(announce_timer));
        elapsed = time - announce_timer;

--        FP_Debug(tostring(elapsed));
        if (elapsed > FP_Options.interval * 1000) then
            FP_Announce();
            announce_timer = time;
        end
    end
end

function FP_Debug(msg)
    if(debugSwitch) then DEFAULT_CHAT_FRAME:AddMessage(tostring(msg)); end
end

SLASH_FINDPARTY1 = "/FP";
SLASH_FINDPARTY2 = "/fp";
SLASH_FINDPARTY3 = "/findparty";

SlashCmdList["FINDPARTY"] = function(msg)
	FP_Debug("SlashCmdList");
	local _, _, command, args = string.find(msg, "(%S+)%s?(.*)");

	FP_Frame:Show();

end

function ADDON_LOADED()
	FP_InviteControlFrame:UnregisterEvent("ADDON_LOADED")
end
-- 기본 설정값 --
SCMSaved= {
  shortChannels=   true;  -- 짧은 채널명 (예. [1] 기존 [1. 공개]) 
  hideChannels=    false; -- 채널명 숨김
  enableWheel=     true;  -- 마우스 휠 스크롤 기능
  chatFade=        true; -- 대화내용 숨김 (일정시간 동안 새로운 내용이 없을결루 해당 대화창을 숨깁니다.)
  colorNicks=      true;  -- 아이디 색상
---------------- 위까진 메뉴설정, 아래는 직접 수정 ( true or false ) ---------------
  MoveEditBox=     false;  -- 대화입력창 위로 표시
  --TimeStamps=      true;  -- 시간표시
  FadeMenuButton=  true; -- 메뉴버튼 숨김
};

SCMDataBase= { };
SCM_actions = { banker=1, taxi=1, trainer=1, vendor=1 };
local real_ChatFrame_OnEvent= nil;
local raidChanged=            true;
local SCMTempDataBase=         { };   -- 유저 직업 색상 임시 캐시 주소

local function print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg);
end;

-- =================================================================================
-- 함수 정의
-- =================================================================================
  local function hide (h)
    h:SetScript('OnShow', h.Hide);
    h:Hide();
  end

  local function show(h)
    h:SetScript('OnShow', h.Show);
    h:Show();
  end

  function bottom()
    PlaySound("igChatBottom");
    this:GetParent():ScrollToBottom();
    hide(getglobal(this:GetParent():GetName()..'BottomButton'));
  end
--[[
  function scmButtons_setSize(frame, width, height)
	frame:SetWidth(width);
	frame:SetHeight(height);
  end

  function scmButtons_setPoint(frame, point, relative, relativePoint, xOfs, yOfs)
	frame:ClearAllPoints();
	frame:SetPoint(point, relative, relativePoint, xOfs, yOfs);
  end
]]
-- =================================================================================
-- 메뉴버튼 숨김
-- =================================================================================
if SCMSaved.FadeMenuButton then hide(ChatFrameMenuButton); 
end

  for i=1,7 do
    
    local x = getfenv(0);
    local iBtmButton = x['ChatFrame'..i..'BottomButton'];
    local iFrame = x['ChatFrame'..i];
    hide(x['ChatFrame'..i..'UpButton']);
    hide(x['ChatFrame'..i..'DownButton']);
    iBtmButton:ClearAllPoints();
    iBtmButton:SetPoint("RIGHT", iFrame, "RIGHT", 0, 0);
    iBtmButton:SetPoint("LEFT", iFrame, "RIGHT", -32, 0);
    iBtmButton:SetPoint("TOP", iFrame, "BOTTOM", 0, 28);
    iBtmButton:SetPoint("BOTTOM", iFrame, "BOTTOM", 0, -4);
--    scmButtons_setSize(x['ChatFrame'..i..'UpButton'], 24, 24);
--    scmButtons_setSize(x['ChatFrame'..i..'DownButton'], 24, 24);
--    scmButtons_setSize(ChatFrameMenuButton, 20, 20);
--    scmButtons_setPoint(ChatFrameMenuButton, "TOPRIGHT", "ChatFrame1", "TOPRIGHT", 0, 0);
--    ChatFrameMenuButton:SetAlpha(0.9);
    hide(iBtmButton);
-- 맨아래로 버튼 작동
    local cb = x['ChatFrame'..i..'BottomButton'];
    cb:SetScript("OnClick",bottom);
  
  end

  -- 대화 입력창 이동
  local eb = ChatFrameEditBox
  if (SCMSaved.MoveEditBox) then
  	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT",  "ChatFrame1", "TOPLEFT",  -5, 0)
	eb:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 5, 0)
  else
	eb:ClearAllPoints()
	eb:SetPoint("TOPLEFT",  "ChatFrame1", "BOTTOMLEFT",  -5, 0)
	eb:SetPoint("TOPRIGHT", "ChatFrame1", "BOTTOMRIGHT", 5, 0)
  end;

---- 방향키 기능 추가 ---
        eb:SetAltArrowKeyMode(false)

---- 채널 고정 기능 추가 ---
ChatTypeInfo["CHANNEL"].sticky = 1;
ChatTypeInfo["OFFICER"].sticky = 1;
ChatTypeInfo["RAID_WARNING"].sticky = 1;
ChatTypeInfo["WHISPER"].sticky 	= 0; 

--[[
  local BottomButton= getglobal(this:GetParent():GetName().."BottomButton");
  local DownButton=   getglobal(this:GetParent():GetName().."DownButton");
  local UpButton=     getglobal(this:GetParent():GetName().."UpButton");

	scmButtons_setSize(UpButton, 24, 24);	
	scmButtons_setSize(DownButton, 24, 24);
	scmButtons_setSize(BottomButton, 24, 24);
	scmButtons_setPoint(BottomButton, "BOTTOMRIGHT", this:GetParent(), "BOTTOMRIGHT", 0, 0);

	scmButtons_setSize(ChatFrameMenuButton, 20, 20);
	scmButtons_setPoint(ChatFrameMenuButton, "TOPRIGHT", "ChatFrame1", "TOPRIGHT", 0, 0);
	ChatFrameMenuButton:SetAlpha(0.9);
]]

function SCM_OnLoad()

  local _, myClass= UnitClass("player");
  local myName, _= UnitName("player");
  SCMDataBase[string.lower(myName)]= myClass;

  -- 슬래쉬 명령어
  SlashCmdList["SCM"]= SCM_Command;
  SLASH_SCM1= "/scm";
  SLASH_SCM2= "/sc";
  
  -- 귓속말 표시 설정
  SCM_CUSTOM_CHT_FROM				= "<FR>%s:\32";
  SCM_CUSTOM_CHT_TO				= "<To>%s:\32";
  SCM_CUSTOM_CHT_YELL                             = "[Y]%s:\32";
  scm_CustomizeChatString(1);

  real_ChatFrame_OnEvent= ChatFrame_OnEvent;
  ChatFrame_OnEvent=      SCM_ChatFrame_OnEvent;
  print(NORMAL_FONT_COLOR_CODE.."SisterChatMods"..FONT_COLOR_CODE_CLOSE.." 불러옴. "..NORMAL_FONT_COLOR_CODE.."/sc"..FONT_COLOR_CODE_CLOSE.." : 명령어 출력. ("..NORMAL_FONT_COLOR_CODE.."자매"..FONT_COLOR_CODE_CLOSE..",노르간논)");

  this:RegisterEvent("VARIABLES_LOADED");
  -- 직업 색상 정보 수집 루틴
  this:RegisterEvent("PARTY_MEMBERS_CHANGED");
  this:RegisterEvent("RAID_ROSTER_UPDATE");
  this:RegisterEvent("GUILD_ROSTER_UPDATE"); --9/7추가
end;


function SCM_OnUpdate(elapsed)
end;

-- 마우스 휠 스크롤
function SCM_OnMouseWheel(chatframe, value)
  if (SCMSaved.enableWheel) then
    if IsShiftKeyDown() then    -- Shift 스크롤
      if (value > 0) then
        for i = 1,5 do
          chatframe:ScrollUp();
        end;
      elseif (value < 0) then
        for i = 1,5 do 
	chatframe:ScrollDown(); end;
      end;
    elseif IsControlKeyDown() then        -- Ctrl 스크롤
      -- to top / to bottom
      if (value > 0) then
        chatframe:ScrollToTop();
      elseif (value < 0) then
        chatframe:ScrollToBottom();
      end;
    else                              -- 일반 스크롤
      if (value > 0) then
        chatframe:ScrollUp();
      elseif (value < 0) then
        chatframe:ScrollDown();
      end;
    end;
  end;
  if chatframe:AtBottom() then
        hide(getglobal(chatframe:GetName()..'BottomButton'));
  else
        show(getglobal(chatframe:GetName()..'BottomButton'));
  end
end;

function SCM_OnEvent(event)  
  if (event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE") then
    raidChanged= true;
   elseif strsub(event, 1, 19) == "GUILD_ROSTER_UPDATE" then
	SCM_InsertGuildMembers();
  end;
  if (event == "VARIABLES_LOADED") then
    SCM_ChatFade();
  end;
end;

function SCM_ChatFrame_OnEvent(event, ...)

  local arg= { ... };

  if (not this.real_AddMessage) then
    this.real_AddMessage= this.AddMessage;
    this.AddMessage= SCM_ChatFrame_AddMessage;
  end;

  this.SCM_Nickname= arg2;

  if arg8 and arg9 then
    local _, _, channelName= string.find(arg9, "(.-)%s.*");
    if (channelName) then
      this.SCM_ChannelName= channelName;
    else
      this.SCM_ChannelName= arg9;
    end;
    if (arg8 > 0) then
      this.SCM_ChannelID= arg8;
    else
      this.SCM_ChannelID= nil;
    end;
    this.SCM_Event= event;
  end;
  real_ChatFrame_OnEvent(event, unpack(arg));
end;

local function Clamp(value, minv, maxv)
  value= math.min(value, maxv);
  value= math.max(value, minv);
  return value;
end;

local function GetGroupDescriptor()
  if (GetNumRaidMembers() > 0) then
    return "raid", 40;
  elseif (GetNumPartyMembers() > 0) then
    return "party", 4;
  else
    return nil, 0;
  end;
end;

function ScanRaid()
  local param, num= GetGroupDescriptor();
  if (param) then
    for i= 1, num do
      local unitID= param..i;
      if (UnitExists(unitID)) then
        local unitName, unitServer= UnitName(unitID);
        unitName= string.lower(unitName);
        local _, unitClass= UnitClass(unitID);
        --if (unitServer) then 
	--  SCMDataBase[unitName.."-"..string.lower(unitServer)]= unitClass;
	--    SCMTempDataBase[unitName.."-"..string.lower(unitServer)]= unitClass;
        --else
          --SCMDataBase[unitName]= unitClass; --DB로 저장
	  SCMTempDataBase[unitName]= unitClass; --임시DB로 저장
        --end;
      end;
    end;
  end;
end;

local function GetClassColor(lowNick)
  local unitClass;
  
  if (raidChanged) then
    raidChanged= false;
    ScanRaid();
  end;
  
  if (SCMDataBase[lowNick]) then
    unitClass= SCMDataBase[lowNick];
  elseif (SCMTempDataBase[lowNick]) then
    unitClass= SCMTempDataBase[lowNick];
  end;
  
  if (unitClass) then
    local color= RAID_CLASS_COLORS[unitClass];
    if (color) then
      return color.r * 255, color.g * 255, color.b *255;
    end;
  end;
  return 204, 255, 204; -- 직업 정보없는 유저 색상 200,200,185
end;

local function GetColoredNick(nickname)
  local r, g, b;
  local lowNick= string.lower(nickname);
    r, g, b= GetClassColor(lowNick);
      
  local rCode= format("%02x", math.ceil(r));
  local gCode= format("%02x", math.ceil(g));
  local bCode= format("%02x", math.ceil(b));

  return "|cff"..rCode..gCode..bCode..nickname..FONT_COLOR_CODE_CLOSE;  
end;

local function GetLink(nickname, colored)
  if (colored) then
    return "|Hplayer:"..nickname.."|h["..GetColoredNick(nickname).."]|h";
  else
    return "|Hplayer:"..nickname.."|h["..nickname.."]|h";
  end;
end;

function SCM_ChatFrame_AddMessage(this, text, r, g, b, id, ...)
  local arg= { ... };

  if (this.SCM_Nickname and this.SCM_Event and text) then
    -- 채널명 줄임 
    if ((SCMSaved.shortChannels or SCMSaved.hideChannels) and this.SCM_ChannelID and this.SCM_ChannelName) then
      local chanName= "["..this.SCM_ChannelID..". "..string.lower(this.SCM_ChannelName).."]";
      local chanLen= string.len(chanName);
      local lowerText= string.lower(text);

      if (string.sub(lowerText, 1, chanLen) == chanName) then
        if (SCMSaved.shortChannels) then
          text= "["..this.SCM_ChannelID.."]"..string.sub(text, chanLen +1);
        elseif (SCMSaved.hideChannels) then
          text= string.sub(text, chanLen +2);
        end;
      end;
    end;

    -- 대화명 색상
    if (SCMSaved.colorNicks and string.len(this.SCM_Nickname) >= 2) then
      local fixedName= string.gsub(this.SCM_Nickname, "%-", "%%-"); 
      text= string.gsub(text, "%["..fixedName.."%]", "%["..GetColoredNick(this.SCM_Nickname).."%]", 1);
    end;
  end;
  -- 임시 캐시 초기화
  this.SCM_Nickname= nil;
  this.SCM_ChannelName= nil;
  this.SCM_ChannelID= nil;
  this.SCM_Event= nil;

  if (this.real_AddMessage) then
    this:real_AddMessage(text, r, g, b, id, unpack(arg));
  end;
end;

-- 명령어
function SCM_Command(msg)
  local cs= NORMAL_FONT_COLOR_CODE;
  local ce= FONT_COLOR_CODE_CLOSE;
  local header= cs.."SisterChatMods: "..ce;
  if (msg == "") then
    print(header.."설정을 위한 명령어들 입니다.:");
    print(cs.."/sc 채널"..ce.." 채널명 표시 형식 전환");
    print(cs.."/sc 색상"..ce.." 아이디 색상 기능 On/Off");
    print(cs.."/sc 휠"..ce.."  마우스 휠 스크롤 On/Off");
    print(cs.."/sc 잡담"..ce.." 잡담넘김 On/Off - 엔피시 와의 대화시\n           잡담화면을 넘깁니다.\n            '일시정지:Ctrl키를 누른채 대화'");
    print(cs.."/sc 지속"..ce.." 대화 지속 On/Off\n            '일정시간 후 대화내용이 숨겨짐을 방지합니다.'");
    print(cs.."/sc DB초기화"..ce.." 수집된 색상정보를 초기화 합니다.(복구불가)");
  elseif (msg == "채널") then
    if (not SCMSaved.shortChannels and not SCMSaved.hideChannels) then
     SCMSaved.shortChannels= true;
      print(header.."짧은 채널명 사용");
    elseif (SCMSaved.shortChannels and not SCMSaved.hideChannels) then
      SCMSaved.shortChannels= false;
      SCMSaved.hideChannels= true;
      print(header.."채널명 숨김");
    else
      SCMSaved.shortChannels= false;
      SCMSaved.hideChannels= false;
      print(header.."채널명 일반 표시");
    end;
  elseif (msg == "색상") then
    if (SCMSaved.colorNicks) then
      print(header.."아이디 색상 끔.");
      SCMSaved.colorNicks= false;
    else
      print(header.."아이디 색상 켬.");
      SCMSaved.colorNicks= true;
    end;    
  elseif (msg == "휠") then
    if (SCMSaved.enableWheel) then
      print(header.."마우스 휠 스크롤 끔");
      SCMSaved.enableWheel= false;
    else
      print(header.."마우스 휠 스크롤 켬");
      SCMSaved.enableWheel= true;
    end;
  elseif (msg == "지속") then
    if (SCMSaved.chatFade) then
      print(header.."대화 지속 기능 켬.");
      SCMSaved.chatFade= false;
      SCM_ChatFade()
    else
      print(header.."대화 지속 기능 끔 - 2분 동안 새글이 없으면 해당 대화창의 대화내용을 숨깁니다.");
      SCMSaved.chatFade= true;
      SCM_ChatFade()
    end;
  elseif (msg == "DB초기화") then
      print(header.."현재까지 수집된 모든 직업색상 정보가 삭제되었습니다.");
      SCMDataBase= { };
  end;
end;

--- 귓속말 수정 ---
function scm_CustomizeChatString(status)
	if OLD_CHAT_WHISPER_GET == nil then OLD_CHAT_WHISPER_GET = CHAT_WHISPER_GET; end
	if OLD_CHAT_WHISPER_INFORM_GET == nil then OLD_CHAT_WHISPER_INFORM_GET = CHAT_WHISPER_INFORM_GET; end;
	if( status == 1 ) then
		CHAT_WHISPER_GET = SCM_CUSTOM_CHT_FROM.." ";
		CHAT_WHISPER_INFORM_GET = SCM_CUSTOM_CHT_TO.." ";
	else
		-- restore original
		CHAT_WHISPER_GET = OLD_CHAT_WHISPER_GET;
		CHAT_WHISPER_INFORM_GET = OLD_CHAT_WHISPER_INFORM_GET;
	end
	if OLD_CHAT_YELL_GET == nil then OLD_CHAT_YELL_GET = CHAT_YELL_GET; end
	if( status == 1 ) then
		CHAT_YELL_GET = SCM_CUSTOM_CHT_YELL.." ";
	else
		-- restore original
		CHAT_YELL_GET = SCM_CUSTOM_CHT_YELL;
	end;
end;


--[[
-- 시간표시 --
if SCMSaved.TimeStamps then
local TimeStampsColor = "|cff00ffff"
local EndColor = "|r"
function Hooked_AddMessage(this, msg, r, g, b, id)
	if(not msg) then msg = ""; end
	local stamp = date("[%H:%M:%S]");
	--local tmsg = stamp..msg;
	local tmsg = TimeStampsColor..stamp..EndColor..msg;
	this:Original_AddMessage(tmsg, r, g, b, id);
end
for i = 2, 2 do
	getglobal("ChatFrame"..i).Original_AddMessage = getglobal("ChatFrame"..i).AddMessage;
	getglobal("ChatFrame"..i).AddMessage = Hooked_AddMessage;
end
end
]]--
  -- 현재 온라인 길드원 정보 수집
function SCM_prepName(name) --9/7추가
	if name then 
		return string.lower(name)
	end;
end;
function SCM_InsertGuildMembers() -- 9/7추가
  for i = 1, GetNumGuildMembers() do
	local name,_,_,level,class,zone = GetGuildRosterInfo(i);
	local LOWname = SCM_prepName(name);
	local class = SCM_ClassToEng(class);
	if( class ~= nil and name ~= nil and class ~= 0  ) then
		SCMDataBase[LOWname] = class;
	end;
  end;
end;
function SCM_ClassToEng(class) --9/7추가
	if(class == "흑마법사") then
		return "WARLOCK";
	elseif(class == "사냥꾼") then
		return "HUNTER";
	elseif(class == "사제") then
		return "PRIEST";
	elseif(class == "성기사") then		
		return "PALADIN";
	elseif(class == "마법사") then	
		return "MAGE";
	elseif(class == "도적") then
		return "ROGUE";
	elseif(class == "드루이드") then
		return "DRUID";
	elseif(class == "주술사") then
		return "SHAMAN";
	elseif(class == "전사") then
		return "WARRIOR";
	end
	return 0;
end;

-- 대화 지속--
function SCM_ChatFade()
	for i = 1, 7 do
		local chatframe = getglobal("ChatFrame"..i);
		chatframe:SetFading(SCMSaved.chatFade);
	end
end

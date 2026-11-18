local _G = getfenv(0);
local unpack = unpack;
local UnitName = UnitName;
local gtt = GameTooltip;

-- classic support
local isWoWClassic, isWoWBcc, isWoWWotlkc, isWoWSl, isWoWRetail = false, false, false, false, false;
if (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_CLASSIC"]) then
	isWoWClassic = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_BURNING_CRUSADE_CLASSIC"]) then
	isWoWBcc = true;
elseif (_G["WOW_PROJECT_ID"] == _G["WOW_PROJECT_WRATH_CLASSIC"]) then
	isWoWWotlkc = true;
else -- retail
	if (_G["LE_EXPANSION_LEVEL_CURRENT"] == _G["LE_EXPANSION_SHADOWLANDS"]) then
		isWoWSl = true;
	else
		isWoWRetail = true;
	end
end

local UnitIsWildBattlePet = UnitIsWildBattlePet or function() return false end;
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion or function() return false end;

-- TipTac refs
local tt = TipTac;
local cfg;

-- element registration
local ttStyle = tt:RegisterElement({},"Style");

-- vars
local lineName = tt:CreatePushArray();
local lineInfo = tt:CreatePushArray();

-- String Constants
local TT_LevelMatch = "^"..TOOLTIP_UNIT_LEVEL:gsub("%%[^s ]*s",".+"); -- Was changed to match other localizations properly, used to match: "^"..LEVEL.." .+" -- Doesn't actually match the level line on the russian client! [14.02.24] Doesn't match for Italian client either. [18.07.27] changed the pattern, might match non-english clients now
local TT_LevelMatchPet = "^"..TOOLTIP_WILDBATTLEPET_LEVEL_CLASS:gsub("%%[^s ]*s",".+");	-- "^Pet Level .+ .+"
local TT_NotSpecified = "Not specified";
local TT_Targeting = BINDING_HEADER_TARGETING;  -- "Targeting"
local TT_MythicPlusDungeonScore = CHALLENGE_COMPLETE_DUNGEON_SCORE; -- "Mythic+ Rating"
local TT_Reaction = {
	FACTION_STANDING_LABEL1,	-- Exceptionally hostile 매우 적대적
	FACTION_STANDING_LABEL2,	-- Very Hostile 적대적
	FACTION_STANDING_LABEL3,	-- Hostile 약간 적대적
	FACTION_STANDING_LABEL4,	-- Neutral 중립
	FACTION_STANDING_LABEL5,	-- Friendly 약간 우호적
	FACTION_STANDING_LABEL6,	-- Very Friendly 우호적
	FACTION_STANDING_LABEL7,	-- Exceptionally friendly 매우 우호적
	FACTION_STANDING_LABEL8,	-- Exalted 확고한 동맹
	DEAD,				-- Dead 죽음
	"선점됨",			-- No localized string of this
	--	"Tapped",		-- No localized string of this
-- 대상과의 우호관계를 평판용 용어로 통일 : End
};

-- colors
local CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS;  -- 직업 색상 변수 추가
local COL_WHITE = "|cffffffff";
local COL_LIGHTGRAY = "|cffc0c0c0";

-- 추가 색상 : Start
local COL_ORANGE = "|cffffa778";
-- 추가 색상 : End

local COL_LIGHTGRAY = "|cffc0c0c0";
local TT_ClassColors = {};
for class, color in next, CLASS_COLORS do
	TT_ClassColors[class] = ("|cff%.2x%.2x%.2x"):format(color.r*255,color.g*255,color.b*255);
end

--------------------------------------------------------------------------------------------------------
--                                           Style Tooltip                                            --
--------------------------------------------------------------------------------------------------------

-- Returns the correct difficulty color compared to the player
-- Az: Check out GetCreatureDifficultyColor, GetQuestDifficultyColor, GetScalingQuestDifficultyColor, GetRelativeDifficultyColor
-- Frozn45: The above functions belong to the old color api. GetDifficultyColor() with C_PlayerInfo.GetContentDifficultyCreatureForPlayer() or C_PlayerInfo.GetContentDifficultyQuestForPlayer() belongs to the new color api.
local function GetDifficultyLevelColor(unit, level) -- see GetDifficultyColor() in "UIParent.lua"
	local difficultyColor;
	
	if (level == -1) then
		difficultyColor = QuestDifficultyColors["impossible"];
	else
		difficultyColor = GetDifficultyColor and GetDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)) or GetCreatureDifficultyColor(level);
	end
	
	local difficultyColorMixin = CreateColor(difficultyColor.r, difficultyColor.g, difficultyColor.b, 1);
	
	return difficultyColorMixin:GenerateHexColorMarkup();
end

-- Add target
local function AddTarget(lineList,target,targetName)
	local targetReaction = cfg["colReactText"..tt:GetUnitReactionIndex(target)]; -- 하단에 있던 지역변수를 위쪽으로 올려 자신이 지정될때 색상표현 되도록 함
	
	-- 자신이 대상으로 지정된 경우에 캐릭터 이름을 표시하는 기능 추가 : Start
	if (UnitIsUnit("player",target)) then
		if cfg.targetName then
			lineList.next = (TT_ClassColors[targetClass]);
			lineList.next = targetReaction;
			lineList.next = "<< "..UnitName(SecureCmdOptionParse("player")).." >>"
		else
			lineList.next = COL_WHITE;
			lineList.next = cfg.targetYouText;
		end
	else
	-- 자신이 대상으로 지정된 경우에 캐릭터 이름을 표시하는 기능 추가 : End

		--local targetReaction = cfg["colReactText"..tt:GetUnitReactionIndex(target)];
		lineList.next = targetReaction;
		lineList.next = "[";
		if (UnitIsPlayer(target)) then
			local _, targetClassFile = UnitClass(target);
			lineList.next = (tt.ClassColorMarkup[targetClassFile] or COL_LIGHTGRAY);
			lineList.next = targetName;
			lineList.next = targetReaction;
		else
			lineList.next = targetName;
		end
		lineList.next = "]";
	end
end

-- TARGET
function ttStyle:GenerateTargetLines(unit,method)
	local target = unit.."target";
	local targetName = UnitName(target);
	if (targetName) and (targetName ~= UNKNOWNOBJECT and targetName ~= "" or UnitExists(target)) then
		if (method == "first") then
			lineName.next = COL_WHITE;
			lineName.next = " : |r";
			AddTarget(lineName,target,targetName);
		elseif (method == "second") then
			lineName.next = "\n|cffffd100대상: "; -- 한글화
			AddTarget(lineName,target,targetName);
		elseif (method == "last") then
			lineInfo.next = "\n|cffffd100대상: "; -- 한글화
			--lineInfo.next = TT_Targeting;
			--lineInfo.next = ": ";
			AddTarget(lineInfo,target,targetName);
		end
	end
end

-- PLAYER Styling
function ttStyle:GeneratePlayerLines(u,first,unit)
	local name, realm = UnitName(unit);
	-- 몹과 유닛을 구분 추가 : Start
	sex = UnitSex(u.token);
	UnitIsMob = not UnitIsPlayer(unit); -- 유저와 몬스터를 구분
	tm = UnitCreatureType(unit); -- 유닛의 속성을 검사하여 지역 변수로 적용
	-- 몹과 유닛을 구분 추가 : End
	
	-- gender
	if (cfg.showPlayerGender) then
		local sex = UnitSex(unit);
		if (sex == 2) or (sex == 3) then
			lineInfo.next = " ";
			lineInfo.next = cfg.colRace;
			lineInfo.next = (sex == 3 and FEMALE or MALE);
		end
	end
	-- race
	raceLoc, raceEng = UnitRace(unit); -- 종족에 대한 변수 지정
	lineInfo.next = " ";
	lineInfo.next = cfg.colRace;
	lineInfo.next = UnitRace(unit);
	-- class
	class, classEng = UnitClass(unit);
	lineInfo.next = " ";
	lineInfo.next = (tt.ClassColorMarkup[u.classFile] or COL_WHITE);
	lineInfo.next = u.class;
	-- name (이름 및 칭호)
-- 칭호의 색상 변경 및 설정 추가 : Start
-- # 변수, 프레임 등의 대소문자 구분은 확실히 # --

-- 캐릭터 이름과 칭호의 색상 분리 : Start (JoJoTooltip의 코드 사용, Hellmaker 님 도움)
	local utext = GameTooltipTextLeft1:GetText();
	if not utext then return end
	local utitle = strmatch(utext, "(.-)"..name);
-- 캐릭터 이름과 칭호의 색상 분리 : End
	
	if (cfg.nameType == "title") or (cfg.nameType == "original") then
			if (cfg.uncolTitle) then
				lineName.next = cfg.colTitle;
				lineName.next = utitle;
				lineName.next = (cfg.colorNameByClass and (tt.ClassColorMarkup[u.classFile] or COL_WHITE) or u.reactionColor);
				lineName.next = name;
			else
				lineName.next = (cfg.colorNameByClass and (tt.ClassColorMarkup[u.classFile] or COL_WHITE) or u.reactionColor);
				--lineOne[#lineOne + 1] = name;
				lineName.next = UnitPVPName(unit) or name;
			end
		else
			lineName.next = (cfg.colorNameByClass and (tt.ClassColorMarkup[u.classFile] or COL_WHITE) or u.reactionColor);
			lineName.next = (cfg.nameType == "marysueprot" and u.rpName) or (cfg.nameType == "original" and u.originalName) or (cfg.nameType == "title" and UnitPVPName(unit)) or u.name;
			--lineOne[#lineOne + 1] = (cfg.nameType == "original" and u.originalName) or name;
		end      
-- 칭호의 색상 변경 및 설정 추가 : End

	if (u.realm) and (u.realm ~= "") and (cfg.showRealm ~= "none") then
		if (cfg.showRealm == "show") then
			lineName.next = " - ";
			lineName.next = u.realm;
		else
			lineName.next = " (*)";
		end
	end
	-- dc, afk or dnd (플레이어 현 상태 표시)
	if (cfg.showStatus) then
		local status = (not UnitIsConnected(unit) and " <오프라인>") or (UnitIsAFK(unit) and " <자리비움>") or (UnitIsDND(unit) and " <다른 용무 중>");
		if (status) then
			lineName.next = COL_WHITE;
			lineName.next = status;
		end
	end
	-- guild
	guild, guildRank = GetGuildInfo(unit); -- local 삭제 (길드 정보에서 불러오기 위한 지역 변수 변경)
	if (guild) then
			local pGuild = GetGuildInfo("player");
			guildColor = (guild == pGuild and cfg.colSameGuild or cfg.colorGuildByReaction and u.reactionColor or cfg.colGuild);--local guildColor = (guild == pGuild and cfg.colSameGuild or cfg.colorGuildByReaction and u.reactionColor or cfg.colGuild); local 삭제
			GameTooltipTextLeft2:SetFormattedText(cfg.showGuildRank and guildRank and "%s<%s> %s%s" or "%s<%s>",guildColor,guild,COL_LIGHTGRAY,guildRank);
			lineInfo.Index = (lineInfo.Index + 1);
			hasGuildTitle = true;
		end
		if (guild) and (not cfg.showGuild) then 
			GameTooltipTextLeft2:SetFormattedText("");
			hasGuildTitle = true;
		end
		
		-- 길드 이름 짧게 표시할 때 한글이 깨져나오는 오류 수정 (friends님 도움)
		function utf8sub(str,index,endindex)
			local function findpos(str,nchar)
			local pos = 1;
			while ( nchar > 0 ) and ( pos <= #str ) do
				local ch = str.byte(str,pos);
				if ( ch < 192 ) then pos = pos + 1
				elseif ( ch < 224 ) then pos = pos + 2
				elseif ( ch < 240 ) then pos = pos + 3
				else pos = pos + 4 end;
				nchar = nchar - 1;
				end
			return min(pos,#str);
			end

			if not ( str ) then return end
			local utf8len = strlenutf8(str);
			if ( index ) and ( index > utf8len ) then return end
			endindex = endindex and min(endindex,utf8len);
			local spos = findpos(str,index-1);
			local epos = endindex and endindex < utf8len and ( findpos(str,endindex) - 1 ) or #str;
			return str:sub(spos,epos);
		end
		-- 긴 길드이름 짧게
		if (guild) and (cfg.showGuild) then 
			if (cfg.shortGname) and string.len(guild) > 35 then
				local gnl = utf8sub(guild, 1, 15);
				local sgn = gnl.."...";       
				GameTooltipTextLeft2:SetFormattedText(cfg.showGuildRank and guildRank and "%s<%s>|cffffffff : |r%s%s" or "%s<%s>",guildColor,sgn,guildColor,guildRank); 
				hasGuildTitle = true;
			else
				GameTooltipTextLeft2:SetFormattedText(cfg.showGuildRank and guildRank and "%s<%s>|cffffffff : |r%s%s" or "%s<%s>",guildColor,guild,guildColor,guildRank);
				hasGuildTitle = true;
			end
		end

-- 길드 표시, 색상 및 설정 추가 : End

-- Unit Speed (이동속도) 표시 추가 : Start (SSTip 코드 사용, 사슴님 도움)
	if cfg.Uspeed then
		ums = GetUnitSpeed(unit)
		if ums and ums > 0 then
			lineInfo.next = "\n|cffffd100";
			lineInfo.next = ">>> 이동속도 : ";
			lineInfo.next = cfg.colRace;
			lineInfo.next = format("%.0f%%", (ums / 7 * 100));
		end
	end
-- 이동속도 표시 추가 : End

-- FeignDeath (죽은척 하기) 표시 추가 : Start (SSTip 코드 사용, 사슴님 도움)
	local feignDeath = GetSpellInfo(5384); -- 죽은척 하기 주문ID
	if (classEng == "HUNTER") then
		if (AuraUtil.FindAuraByName(feignDeath, unit)) then
			lineInfo.next = " ";
			lineInfo.next = COL_ORANGE;
			lineInfo.next = "<";
			lineInfo.next = feignDeath;
			lineInfo.next = ">";
		end
	end
-- 사냥꾼의 죽은척 하기 추가 : End
end

-- PET Styling
function ttStyle:GeneratePetLines(u,first,unit)
	lineName.next = u.reactionColor;
	lineName.next = u.name;

	lineInfo.next = " ";
	lineInfo.next = cfg.colRace;
	local petType = UnitBattlePetType(unit) or 5;
	lineInfo.next = _G["BATTLE_PET_NAME_"..petType];

	if (u.isPetWild) then
		lineInfo.next = " ";
		lineInfo.next = UnitCreatureFamily(unit) or UnitCreatureType(unit);
	else
		if not (self.petLevelLineIndex) then
			for i = 2, gtt:NumLines() do
				local gttLineText = _G["GameTooltipTextLeft"..i]:GetText();
				if (type(gttLineText) == "string") and (gttLineText:find(TT_LevelMatchPet)) then
					self.petLevelLineIndex = i;
					break;
				end
			end
		end
		lineInfo.Index = self.petLevelLineIndex or 2;
		local expectedLine = 3 + (tt.isColorBlind and 1 or 0);
		if (lineInfo.Index > expectedLine) then
			GameTooltipTextLeft2:SetFormattedText("%s<%s>",u.reactionColor,u.title);
		end
	end
end

-- NPC Styling
function ttStyle:GenerateNpcLines(u,first,unit)
	-- name
	lineName.next = u.reactionColor;
	lineName.next = u.name;

	-- guild/title -- since WoD, npc title can be a single space character
	if (u.title) and (u.title ~= " ") then
		-- Az: this doesn't work with "Mini Diablo" or "Mini Thor", which has the format: 1) Mini Diablo 2) Lord of Terror 3) Player's Pet 4) Level 1 Non-combat Pet
		local gttLine = tt.isColorBlind and GameTooltipTextLeft3 or GameTooltipTextLeft2;
		gttLine:SetFormattedText("%s<%s>",u.reactionColor,u.title);
		-- 펫과 추종자가 고유 호칭 소지시 이름만 2줄 표시나는거 수정
			for i = 2, gtt:NumLines() do
			lineInfo.Index = (lineInfo.Index + 1);
			end
	end

	-- class
	local class = UnitCreatureFamily(unit) or UnitCreatureType(unit);
	if (not class or class == TT_NotSpecified) then
		class = UNKNOWN;
	end
	lineInfo.next = " ";
	lineInfo.next = cfg.colRace;
	lineInfo.next = class;
end

-- Modify Tooltip Lines (name + info)
function ttStyle:ModifyUnitTooltip(u,first)
	-- obtain unit properties
	local unit = u.token;
	u.name, u.realm = UnitName(unit);
	u.reactionColor = cfg["colReactText"..u.reactionIndex];
	u.isPetWild, u.isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit);

	-- this is the line index where the level and unit type info is
	lineInfo.Index = 2 + (tt.isColorBlind and UnitIsVisible(unit) and 1 or 0);

	-- Level + Classification
	local level = (u.isPetWild or u.isPetCompanion) and UnitBattlePetLevel(unit) or UnitLevel(unit) or -1;
	local classification = UnitClassification(unit) or "";
	lineInfo.next = (UnitCanAttack(unit, "player") or UnitCanAttack("player", unit)) and GetDifficultyLevelColor(unit, level) or cfg.colLevel;
	lineInfo.next = (cfg["classification_"..classification] or "%s? "):format(level == -1 and "??" or level);

	-- Generate Line Modification
	if (u.isPlayer) then
		self:GeneratePlayerLines(u,first,unit);
	elseif (cfg.showBattlePetTip) and (u.isPetWild or u.isPetCompanion) then
		self:GeneratePetLines(u,first,unit);
	else
		self:GenerateNpcLines(u,first,unit);
	end

	-- Reaction Text
	if (cfg.reactText) then
		lineInfo.next = "\n";
		lineInfo.next = u.reactionColor;
		lineInfo.next = TT_Reaction[u.reactionIndex];
	end

	-- Mythic+ Dungeon Score
	if (u.isPlayer) and (cfg.showMythicPlusDungeonScore) and (C_PlayerInfo.GetPlayerMythicPlusRatingSummary) then
		local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit);
		if (ratingSummary) then
			local mythicPlusDungeonScore = ratingSummary.currentSeasonScore;
			if (mythicPlusDungeonScore > 0) then
				lineInfo.next = "\n|cffffd100";
				lineInfo.next = TT_MythicPlusDungeonScore:format(C_ChallengeMode.GetDungeonScoreRarityColor(mythicPlusDungeonScore):WrapTextInColorCode(mythicPlusDungeonScore));
			end
		end
	end

	-- Target
	if (cfg.showTarget ~= "none") then
		self:GenerateTargetLines(unit,cfg.showTarget);
	end

	-- Name Line
	GameTooltipTextLeft1:SetText(lineName:Concat());
	lineName:Clear();

	-- Info Line
	gttLine = _G["GameTooltipTextLeft"..lineInfo.Index]; -- local 삭제 (직업 아이콘의 위치 지정)
	gttLine:SetText(lineInfo:Concat());
	gttLine:SetTextColor(1,1,1);
	lineInfo:Clear();

-- Elite Frame (정예 프레임)
 if (cfg.Eframe) and (not eliteFrame) then
  eliteFrame = gtt:CreateTexture(nil, "BACKGROUND");
 end
 
 if (eliteFrame) then
  if (cfg.Eframe) then
   eliteFrame:SetHeight(100);
   eliteFrame:SetWidth(100);
   eliteFrame:ClearAllPoints();
  else
   eliteFrame:Hide();
  end
 end

-- 정예 프레임 단독 설정으로 작동되도록 함수 위치 변경 시작
 if (cfg.Eframe) then
  function gtt:SetEliteTexture(classification)
   if (classification == "rare" or classification == "rareelite") then
    eliteFrame:SetTexture("Interface\\AddOns\\TipTac\\texture\\rare_graphic");
	eliteFrame:ClearAllPoints();
	eliteFrame:SetPoint("CENTER", gtt, "TOPLEFT", 13, -21);
	eliteFrame:Show();
   elseif (classification == "elite" or classification == "worldboss" or classification == "boss") then--elseif (classification == "elite" or classification == "worldboss" or classification == "boss") then
	eliteFrame:SetTexture("Interface\\AddOns\\TipTac\\texture\\elite_graphic");
	eliteFrame:ClearAllPoints();
	eliteFrame:SetPoint("CENTER", gtt, "TOPLEFT", 9, -21); -- 정예와 희귀 텍스쳐 위치값이 다르므로 위치 설정을 독립적 적용
	eliteFrame:Show();
   else
	eliteFrame:Hide();
   end
  end
  if (gtt.SetEliteTexture) then	gtt:SetEliteTexture(classification)
  end
 end
-- 정예 프레임 단독 설정으로 작동되도록 함수 위치 변경 끝

-- RaceIcon (종족 아이콘)
 if (cfg.raceIcon) and (not uri) then 
  uri = gtt:CreateTexture(nil, "BACKGROUND");
 end

 if (uri) then
  if (cfg.raceIcon) and (cfg.classType ~= "none" ) then
   if (cfg.clasIcon) then
    if (cfg.classType == "tl") then
     uri:SetWidth(cfg.piconSize - 5);
	   uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "TOPLEFT", -58, 16);
    elseif (cfg.classType == "tr") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "TOPRIGHT", 61, 16);
    elseif (cfg.classType == "bl") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "BOTTOMLEFT", -58, -16);
    elseif (cfg.classType == "br") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "BOTTOMRIGHT", 61, -16);
    else 
     uri:Hide();
    end
   elseif (not cfg.clasIcon) then
    if (cfg.classType == "tl") then
     uri:SetWidth(cfg.piconSize - 5);
	   uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "TOPLEFT", -20, 16);
    elseif (cfg.classType == "tr") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "TOPRIGHT", 18, 16);
    elseif (cfg.classType == "bl") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "BOTTOMLEFT", -20, -16);
    elseif (cfg.classType == "br") then
     uri:SetWidth(cfg.piconSize - 5);
		 uri:SetHeight(cfg.piconSize - 5);
     uri:ClearAllPoints();
     uri:SetPoint("CENTER", gtt, "BOTTOMRIGHT", 18, -16);
    else 
     uri:Hide();
    end
   else return end
  end
 end

-- Class Icon (직업 아이콘)
 if (cfg.clasIcon) and (not uci) then 
  uci = gtt:CreateTexture(nil, "BACKGROUND");
 end

 if (uci) then
  if (cfg.clasIcon) and (cfg.classType ~= "none" )then
   if (cfg.classType == "tl") then
    uci:SetWidth(cfg.piconSize - 1);
		uci:SetHeight(cfg.piconSize - 1);
    uci:ClearAllPoints();
    uci:SetPoint("CENTER", gtt, "TOPLEFT", -20, 16);
   elseif (cfg.classType == "tr") then
    uci:SetWidth(cfg.piconSize - 1);
		uci:SetHeight(cfg.piconSize - 1);
    uci:ClearAllPoints();
    uci:SetPoint("CENTER", gtt, "TOPRIGHT", 18, 16);
   elseif (cfg.classType == "bl") then
    uci:SetWidth(cfg.piconSize - 1);
		uci:SetHeight(cfg.piconSize - 1);
    uci:ClearAllPoints();
    uci:SetPoint("CENTER", gtt, "BOTTOMLEFT", -20, -16);
   elseif (cfg.classType == "br") then
    uci:SetWidth(cfg.piconSize - 1);
		uci:SetHeight(cfg.piconSize - 1);
    uci:ClearAllPoints();
    uci:SetPoint("CENTER", gtt, "BOTTOMRIGHT", 18, -16);
   else 
    uci:Hide();
   end
  end
 end

-- CreatureIcon (속성 아이콘)
 if (cfg.crtIcon) and (not ci) then
  ci = gtt:CreateTexture(nil, "BACKGROUND");
 end

 if (ci) then
  if (cfg.crtIcon) and (cfg.classType ~= "none" )then
   if (cfg.classType == "tl") then
    ci:SetWidth(cfg.piconSize - 5);
		ci:SetHeight(cfg.piconSize - 5);
    ci:ClearAllPoints();
    ci:SetPoint("CENTER", gtt, "TOPLEFT", -20, 16);
   elseif (cfg.classType == "tr") then
    ci:SetWidth(cfg.piconSize - 5);
		ci:SetHeight(cfg.piconSize - 5);
    ci:ClearAllPoints();
    ci:SetPoint("CENTER", gtt, "TOPRIGHT", 18, 16);
   elseif (cfg.classType == "bl") then
    ci:SetWidth(cfg.piconSize - 5);
		ci:SetHeight(cfg.piconSize - 5);
    ci:ClearAllPoints();
    ci:SetPoint("CENTER", gtt, "BOTTOMLEFT", -20, -16); 
   elseif (cfg.classType == "br") then
    ci:SetWidth(cfg.piconSize - 5);
		ci:SetHeight(cfg.piconSize - 5);
    ci:ClearAllPoints();
    ci:SetPoint("CENTER", gtt, "BOTTOMRIGHT", 18, -16);
   else  
     ci:Hide();
   end
  end
 --else  -- 직업 아이콘, 종족 아이콘 단독으로 적용되도록 주석처리
 --return;  -- 직업 아이콘, 종족 아이콘 단독으로 적용되도록 주석처리
 end
-- 정예 프레임, 직업 아이콘, 속성 아이콘 추가 : End

-- 직업, 종족, 속성 아이콘 추가 : Start
-- in ClassIcon (직업 아이콘)
  if (cfg.clasIcon) then
   if (cfg.IconPosition == "inIcon") then
		if (u.isPlayer) and (classEng == "DEATHKNIGHT") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\DEATHKNIGHT";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "MAGE") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\MAGE";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "ROGUE") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\ROGUE";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "WARRIOR") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\WARRIOR";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "WARLOCK") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\WARLOCK";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "HUNTER") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\HUNTER";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "PRIEST") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\PRIEST";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "SHAMAN") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\SHAMAN";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "DRUID") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\DRUID";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "PALADIN") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\PALADIN";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "MONK") then
			ucii = "Interface\\AddOns\\TipTac\\texture\\Class_Monk";
			_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "DEMONHUNTER") then
				ucii = "Interface\\AddOns\\TipTac\\texture\\DEMONHUNTER";
				_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		elseif (u.isPlayer) and (classEng == "EVOKER") then
				ucii = "Interface\\AddOns\\TipTac\\texture\\Evoker";
				_G["gttLine"]:SetText("|T"..ucii..":"..(cfg.piconSize - 13).."|t ".._G["gttLine"]:GetText());
		end
   end
  end

-- inRaceIcon (종족 아이콘)
 if (cfg.raceIcon) then
  if (cfg.IconPosition == "inIcon") then
    if (u.isPlayer) and (raceLoc == "인간") and (sex == 2) then -- 인간 남자
			fhri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Human";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fhri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "인간") and (sex == 3) then -- 인간 여자
			mhri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Human";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mhri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "드워프") and (sex == 2) then -- 드워프 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Dwarf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "드워프") and (sex == 3) then -- 드워프 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Dwarf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "나이트 엘프") and (sex == 2) then -- 나엘 남자
			nemri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-NightElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..nemri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "나이트 엘프") and (sex == 3) then -- 나엘 여자
			nefri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-NightElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..nefri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "노움") and (sex == 2) then -- 노움 남자
			gnmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Gnome";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gnmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "노움") and (sex == 3) then -- 노움 여자
			gnfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Gnome";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gnfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "드레나이") and (sex == 3) then -- 드레 여자
			drfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Draenei";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..drfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "드레나이") and (sex == 2) then -- 드레 남자
      drmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Draenei";
			_G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..drmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "늑대인간") and (sex == 2) then -- 늑인 남자
			wgmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Worgen";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..wgmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "늑대인간") and (sex == 3) then -- 늑인 여자
			wgfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Worgen";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..wgfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "오크") and (sex == 2) then -- 오크 남자
			omri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Orc";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..omri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "오크") and (sex == 3) then -- 오크 여자
			ofri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Orc";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..ofri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "언데드") and (sex == 2) then -- 언데드 남자
			umri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Scourge";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..umri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "언데드") and (sex == 3) then -- 언데드 여자
			ufri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Scourge";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..ufri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "타우렌") and (sex == 2) then -- 타우렌 남자
			tmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Tauren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..tmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "타우렌") and (sex == 3) then -- 타우렌 여자
			tfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Tauren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..tfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "트롤") and (sex == 2) then -- 트롤 남자
			trmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Troll";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..trmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "트롤") and (sex == 3) then -- 트롤 여자
		  trfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Troll";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..trfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "블러드 엘프") and (sex == 2) then -- 블엘 남자
			blmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-BloodElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..blmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "블러드 엘프") and (sex == 3) then -- 블엘 여자
			blfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-BloodElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..blfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "고블린") and (sex == 2) then -- 고블린 남자
			gmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Goblin";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "고블린") and (sex == 3) then -- 고블린 여자
			gfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Goblin";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gfri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "판다렌") and (sex == 2) then -- 판다렌 남자
			gmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Pandaren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "판다렌") and (sex == 3) then -- 판다렌 여자
			gfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Pandaren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gfri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "높은산 타우렌") and (sex == 2) then -- 높은산 타우렌 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-HighmountainTauren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "높은산 타우렌") and (sex == 3) then -- 높은산 타우렌 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-HighmountainTauren";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "빛벼림 드레나이") and (sex == 2) then -- 빛벼림 드레나이 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-LightforgedDraenei";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "빛벼림 드레나이") and (sex == 3) then -- 빛벼림 드레나이 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-LightforgedDraenei";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "나이트본") and (sex == 2) then -- 나이트본 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Nightborne";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "나이트본") and (sex == 3) then -- 나이트본 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Nightborne";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "공허 엘프") and (sex == 2) then -- 공허 엘프 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-VoidElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "공허 엘프") and (sex == 3) then -- 공허 엘프 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-VoidElf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "검은무쇠 드워프") and (sex == 2) then -- 검무드 남자
			mdri = "Interface\CHARACTERFRAME\\TemporaryPortrait-Male-DarkIronDwarf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "검은무쇠 드워프") and (sex == 3) then -- 검무드 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-DarkIronDwarf";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "마그하르 오크") and (sex == 2) then -- 마그하르 오크 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-MagharOrc";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "마그하르 오크") and (sex == 3) then -- 마그하르 오크 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-MagharOrc";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t "); 
      elseif (u.isPlayer) and (raceLoc == "쿨 티란") and (sex == 2) then -- 쿨 티란 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-KulTiran";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "쿨 티란") and (sex == 3) then -- 쿨 티란 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-KulTiran";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "잔달라 트롤") and (sex == 2) then -- 마그하르 오크 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-ZandalariTroll";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "잔달라 트롤") and (sex == 3) then -- 잔달라 트롤 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-ZandalariTroll";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "불페라") and (sex == 2) then -- 불페라 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Vulpera";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "불페라") and (sex == 3) then -- 불페라 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Vulpera";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "기계노움") and (sex == 2) then -- 기계노움 남자
			mdri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Mechagnome";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mdri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "기계노움") and (sex == 3) then -- 기계노움 여자
			fdri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Mechagnome";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..fdri..":"..(cfg.piconSize - 17).."|t ");
      elseif (u.isPlayer) and (raceLoc == "드랙티르") and (sex == 2) then -- 드랙티르 남자
			gmri = "Interface\\CharacterFrame\\TemporaryPortrait-Male-Dracthyr";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gmri..":"..(cfg.piconSize - 17).."|t ");
		elseif (u.isPlayer) and (raceLoc == "드랙티르") and (sex == 3) then -- 드랙티르 여자
			gfri = "Interface\\CharacterFrame\\TemporaryPortrait-Female-Dracthyr";
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gfri..":"..(cfg.piconSize - 17).."|t ");
	  end
	 end
 end

-- inCreatureIcon (속성 아이콘)
 if (cfg.crtIcon) then
  if (cfg.IconPosition == "inIcon") then	
	 if (not u.isPlayer) and (tm == "야수") then
			beasti = "Interface\\Icons\\Ability_Druid_FerociousBite"; ---------------------------------------- 야수 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..beasti..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "기계") then
			mecai = "Interface\\Icons\\INV_Gizmo_02"; ------------------------------------------------------- 기계 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..mecai..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "언데드") then
			udi = "Interface\\Icons\\Spell_Shadow_ShadowWordPain"; ---------------------------------------- 언데드 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..udi..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "동물") then
			ani = "Interface\\Icons\\Ability_Seal"; ------------------------------------------------------- 동물 텍스쳐 기본값
			_G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..ani..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "거인") then
			gai = "Interface\\Icons\\Ability_Racial_Avatar"; ---------------------------------------------- 거인 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..gai..":"..(cfg.piconSize - 18).."|t ");
   elseif (not u.isPlayer) and (tm == "정령") then
			eli = "Interface\\Icons\\Spell_Frost_SummonWaterElemental"; ----------------------------------- 정령 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..eli..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "악마") then
      dei = "Interface\\Icons\\Spell_Shadow_CurseOfTounges"; ---------------------------------------- 악마, 붉은 악마 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..dei..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "용족") then
			dri = "Interface\\Icons\\INV_Misc_Head_Dragon_Green"; ----------------------------------------- 용족, 녹색 용 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..dri..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "인간형") then
			hui = "Interface\\Icons\\Spell_Holy_PrayerofSpirit"; ------------------------------------------ 인간형, 인간형태 텍스쳐 기본값
      _G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..hui..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "애완동물") then
			pai = "Interface\\Icons\\INV_Misc_Rabbit_2"; -------------------------------------------------- 애완동물, 토끼 텍스쳐 기본값
			_G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..pai..":"..(cfg.piconSize - 18).."|t ");
	 elseif (not u.isPlayer) and (tm == "기타") then
			etci = "Interface\\Icons\\Spell_fire_ElementalDevastation"; ------------------------------------ 기타, 알 수 없는 형체 텍스쳐 기본값
			_G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..etci..":"..(cfg.piconSize - 18).."|t ");
   elseif (not u.isPlayer) and (tm == "토템") then
			toi = "Interface\\Icons\\Spell_Shaman_Dropall_03"; -------------------------------------------- 토템, 토템 텍스쳐 기본값
			_G["GameTooltipTextLeft1"]:SetText(_G["GameTooltipTextLeft1"]:GetText().." |T"..toi..":"..(cfg.piconSize - 18).."|t ");
	 end
	end
 end 
-- 직업, 종족, 속성 아이콘 추가 : End
 
-- Race Icon (종족 아이콘)
 if (cfg.raceIcon) then
  if (cfg.IconPosition == "outIcon") then
   if (not cfg.rIconinTT) then
  	function gtt:SetRaceIcon(raceLoc)
     sex = UnitSex(u.token);
	  	if (u.isPlayer) and (raceLoc == "인간") and (sex == 2) then -- 인간 남자
	  		uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Human");
		  	uri:Show();
	  	elseif (u.isPlayer) and (raceLoc == "인간") and (sex == 3) then -- 인간 여자
	 	 	 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Human");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드워프") and (sex == 2) then -- 드워프 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Dwarf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드워프") and (sex == 3) then -- 드워프 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Dwarf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "나이트 엘프") and (sex == 2) then -- 나엘 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-NightElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "나이트 엘프") and (sex == 3) then -- 나엘 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-NightElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "노움") and (sex == 2) then -- 노움 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Gnome");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "노움") and (sex == 3) then -- 노움 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Gnome");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드레나이") and (sex == 3) then -- 드레 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Draenei");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드레나이") and (sex == 2) then -- 드레 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Draenei");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "늑대인간") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Worgen");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "늑대인간") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Worgen");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "오크") and (sex == 2) then -- 오크 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Orc");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "오크") and (sex == 3) then -- 오크 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Orc");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "언데드") and (sex == 2) then -- 언데드 남자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Scourge");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "언데드") and (sex == 3) then -- 언데드 여자
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Scourge");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "타우렌") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Tauren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "타우렌") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Tauren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "트롤") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Troll");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "트롤") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Troll");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "블러드 엘프") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-BloodElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "블러드 엘프") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-BloodElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "고블린") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Goblin");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "고블린") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Goblin");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "판다렌") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Pandaren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "판다렌") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Pandaren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "높은산 타우렌") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-HighmountainTauren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "높은산 타우렌") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-HighmountainTauren");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "빛벼림 드레나이") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-LightforgedDraenei");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "빛벼림 드레나이") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-LightforgedDraenei");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "나이트본") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Nightborne");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "나이트본") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Nightborne");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "공허 엘프") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-VoidElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "공허 엘프") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-VoidElf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "검은무쇠 드워프") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-DarkIronDwarf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "검은무쇠 드워프") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-DarkIronDwarf");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "마그하르 오크") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-MagharOrc");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "마그하르 오크") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-MagharOrc");
			 uri:Show();			 
		  elseif (u.isPlayer) and (raceLoc == "쿨 티란") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-KulTiran");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "쿨 티란") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-KulTiran");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "잔달라 트롤") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-ZandalariTroll");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "잔달라 트롤") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-ZandalariTroll");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "기계노움") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Mechagnome");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "기계노움") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Mechagnome");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "불페라") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Vulpera");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "불페라") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Vulpera");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드랙티르") and (sex == 2) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Male-Dracthyr");
			 uri:Show();
		  elseif (u.isPlayer) and (raceLoc == "드랙티르") and (sex == 3) then
			 uri:SetTexture("Interface\\CharacterFrame\\TemporaryPortrait-Female-Dracthyr");
			 uri:Show();
			 uri:Hide();
		  end
	   end
     if (gtt.SetRaceIcon) then gtt:SetRaceIcon(raceLoc) end
   end
  end
 end

-- Class Icon (직업 아이콘)
 if (cfg.clasIcon) then
  if (cfg.IconPosition == "outIcon") then
	 function gtt:SetClassIcon(classEng)
		 if (u.isPlayer) and (classEng == "DEATHKNIGHT") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\DEATHKNIGHT");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "MAGE") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\MAGE");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "ROGUE") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\ROGUE");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "WARRIOR") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\WARRIOR");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "WARLOCK") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\WARLOCK");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "HUNTER") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\HUNTER");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "PRIEST") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\PRIEST");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "SHAMAN") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\SHAMAN");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "DRUID") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\DRUID");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "PALADIN") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\PALADIN");
			 uci:Show();
		 elseif (u.isPlayer) and (classEng == "MONK") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\Class_Monk");
			 uci:Show();
		elseif (u.isPlayer) and (classEng == "DEMONHUNTER") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\DEMONHUNTER");
			 uci:Show();
		elseif (u.isPlayer) and (classEng == "EVOKER") then
			 uci:SetTexture("Interface\\AddOns\\TipTac\\texture\\Evoker");
			 uci:Show();
		 else
			 uci:Hide();
		 end
	 end
	 if (gtt.SetClassIcon) then gtt:SetClassIcon(classEng) end
	end
 end
 
-- Creature Icon (속성 아이콘)
 if (cfg.crtIcon) then 
  if (cfg.IconPosition == "outIcon") then	
	 function gtt:SetCreatureIcon(tm)
	  if (not u.isPlayer) and (tm == "야수") then
			 ci:SetTexture("Interface\\Icons\\Ability_Druid_FerociousBite"); ---------------------------------------- 야수 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\Ability_Mount_JungleTiger"); ---------------------------------------- 인벤유닛프레임 야수 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "기계") then
--			 ci:SetTexture("Interface\\AddOns\\TipTac\\texture\\MECHANICAL");
			 ci:SetTexture("Interface\\Icons\\INV_Gizmo_02"); ------------------------------------------------------- 기계 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\INV_Misc_Head_ClockworkGnome_01"); ---------------------------------- 인벤유닛프레임 기계 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "언데드") then
--       ci:SetTexture("Interface\\AddOns\\TipTac\\texture\\UNDEAD");
			 ci:SetTexture("Interface\\Icons\\Spell_Shadow_ShadowWordPain"); ---------------------------------------- 언데드 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\INV_Misc_Head_Undead_01"); ------------------------------------------ 인벤유닛프레임 언데드 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "동물") then
			 ci:SetTexture("Interface\\Icons\\Ability_Seal"); ------------------------------------------------------- 동물 텍스쳐 기본값
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "거인") then
			 ci:SetTexture("Interface\\Icons\\Ability_Racial_Avatar"); ---------------------------------------------- 거인 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\Achievement_Dungeon_UlduarRaid_IronSentinel_01"); ------------------- 인벤유닛프레임 거인 텍스쳐
			 ci:Show();
    elseif (not u.isPlayer) and (tm == "정령") then
			 ci:SetTexture("Interface\\Icons\\Spell_Frost_SummonWaterElemental"); ----------------------------------- 정령 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\Spell_Frost_SummonWaterElemental"); --------------------------------- 인벤유닛프레임 정령 텍스쳐 (동일함)
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "악마") then
--			 ci:SetTexture("Interface\\AddOns\\TipTac\\texture\\DEMON");
       ci:SetTexture("Interface\\Icons\\Spell_Shadow_CurseOfTounges"); ---------------------------------------- 악마, 붉은 악마 텍스쳐 기본값
--       ci:SetTexture("Interface\\Icons\\Achievement_Boss_Kiljaedan"); --------------------------------------- 인벤유닛프레임 악마 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "용족") then
			 ci:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_Green"); ----------------------------------------- 용족, 녹색 용 텍스쳐 기본값
--			 ci:SetTexture("Interface\\Icons\\Achievement_Boss_Sartharion_01"); ----------------------------------- 인벤유닛프레임 용족 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "인간형") then
			 ci:SetTexture("Interface\\Icons\\Spell_Holy_PrayerofSpirit"); ------------------------------------------ 인간형, 인간형태 텍스쳐 기본값
--       ci:SetTexture("Interface\\Icons\\Achievement_Leader_King_Varian_Wrynn"); ----------------------------- 인벤유닛프레임 인간형 텍스쳐
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "애완동물") then
			 ci:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2"); -------------------------------------------------- 애완동물, 토끼 텍스쳐 기본값
			 ci:Show();
	  elseif (not u.isPlayer) and (tm == "기타") then
			 ci:SetTexture("Interface\\Icons\\Spell_fire_ElementalDevastation"); ------------------------------------ 기타, 알 수 없는 형체 텍스쳐 기본값
			 ci:Show();
    elseif (not u.isPlayer) and (tm == "토템") then
			 ci:SetTexture("Interface\\Icons\\Spell_Shaman_Dropall_03"); -------------------------------------------- 토템, 토템 텍스쳐 기본값
			 ci:Show();
	  else
			 ci:Hide();
	  end
	 end
	 if (gtt.SetCreatureIcon) then gtt:SetCreatureIcon(tm) end		
  end
 end 
-- 정예 프레임, 직업 아이콘, 속성 아이콘 추가 : End
end

--------------------------------------------------------------------------------------------------------
--                                           Element Events                                           --
--------------------------------------------------------------------------------------------------------

function ttStyle:OnLoad()
	cfg = TipTac_Config;
end

function ttStyle:OnStyleTip(tip,first)
	-- some things only need to be done once initially when the tip is first displayed
	if (first) then
		-- Store Original Name
		if (cfg.nameType == "original") then
			tip.ttUnit.originalName = GameTooltipTextLeft1:GetText();
		end

		-- Az: RolePlay Experimental (Mary Sue Protocol)
		if (tip.ttUnit.isPlayer) and (cfg.nameType == "marysueprot") and (msp) then
			local field = "NA";
			local name = UnitName(tip.ttUnit.token);
			msp:Request(name,field);	-- Az: does this return our request, or only storing it for later use? I'm guessing the info isn't available right away, but only after the person's roleplay addon replies.
			if (msp.char[name]) and (msp.char[name].field[field] ~= "") then
				tip.ttUnit.rpName = msp.char[name].field[field] or name;
			end
		end

		-- Find NPC Title -- 09.08.22: Should now work with colorblind mode
		if (not tip.ttUnit.isPlayer) then
			tip.ttUnit.title = (tt.isColorBlind and GameTooltipTextLeft3 or GameTooltipTextLeft2):GetText();
			if (tip.ttUnit.title) and (tip.ttUnit.title:find(TT_LevelMatch)) then
				tip.ttUnit.title = nil;
			end
		end
		self:ModifyUnitTooltip(tip.ttUnit,first);  -- '칭호 색상' 적용 시 몇 초 뒤에 이름까지 같이 적용되던 문제의 원인 --> 아래에서 위로 이동
	end
--	self:ModifyUnitTooltip(tip.ttUnit,first);  -- '칭호 색상' 문제로 위로 이동
end

function ttStyle:OnCleared(tip)
	if (gtt == tip) then
		self.petLevelLineIndex = nil;
	end
end
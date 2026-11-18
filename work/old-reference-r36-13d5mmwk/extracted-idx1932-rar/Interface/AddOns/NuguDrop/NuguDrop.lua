BINDING_HEADER_NUGUDROP = "누구드랍";
BINDING_NAME_NUGUDROPTOGGLE = "누구드랍 리스트 열기/닫기";
BINDING_NAME_NUGUDROPITEMIDTOGGLE = "누구드랍 아이템ID 조회창 열기/ 닫기";
BINDING_NAME_NUGUDROPFAVTOGGLE = "누구드랍 즐겨찾기창 열기/ 닫기";
ND_Version = "4.1";
NUGUDROP_BUTTON_TOOLTIP = "누구드랍"..ND_Version.."\n\n좌|cff2DE3ACclick|r : 브라우저 열기/닫기\n우|cff2DE3ACclick|r : 즐겨찾기 열기/닫기\n가운데|cff2DE3ACclick|r : 미니맵 아이콘 위치초기화\n|cffFFE378shift|r+가운데|cff2DE3ACclick|r : 고정/자유이동\n|cffFFE378shift|r+우|cff2DE3ACclick|r : 둥근 미니맵에 종속적인 위치이동";
NUGUDROP_ITEMID_BUTTON_TOOLTIP = "직접 ItemID 를 입력하여 \n아이템을 조회할 수 있습니다.";
ND_UKNOWN_TITLE = "미확인 아이템\n\n";
ND_UKNOWN_DESC = "이 아이템은 현재 컴퓨터 캐시에\n존재하지 않는 아이템입니다.\n\n";
ND_UKNOWN_WARN = "|cffff0000경고!!|r 클릭시 서버조회를 시도합니다.\n성공시 한번더 클릭하면 정상적으로 표시됩니다.\n\n";
NuguDropColor = { r=0, g=0.7, b=1 };
NuguDrop = {};
-- 확장팩 임시 데이터
NuguDropNorth = {};
NuguDropRep3 = {};
-----------------------------------------------------
-- [[ 초기화 ]] --
-----------------------------------------------------
	if (not NuguDropOption) then
		NuguDropOption = {};
	end

	-- 아이콘 상태 (기본: 자유이동)
	if (not NuguDropOption["ND_MoveFree"]) then
		NuguDropOption["ND_MoveFree"] = true;
	end

	if (not NuguDropOption["NuguDropButtonPos"]) then
		NuguDropOption["NuguDropButtonPos"] = -70;
	end

	-- 사전(1)/캐시(0) 어느것을 참조할 것인가 선택하는 변수 (기본: 캐시)
	if (not NuguDropOption["ND_whatref"]) then
		NuguDropOption["ND_whatref"] = 0;
	end

	-- 분류탭 지정 (기본: 아웃랜드)
	if (not NuguDropOption["SelectedTab"]) then
		NuguDropOption["SelectedTab"] = 2;
	end

	-- 아이템ID 보여주기 (기본: 보이기)
	if (not NuguDropOption["ShowItemID"]) then
		NuguDropOption["ShowItemID"] = true;
	end

	-- 아이템Level 보여주기 (기본: 보이기)
	if (not NuguDropOption["ShowItemLevel"]) then
		NuguDropOption["ShowItemLevel"] = true;
	end

	-- 즐겨찾기에서 마지막으로 선택한 class
	if (not NuguDropOption["lastseen"]) then
		NuguDropOption["lastseen"] = 1;
	end

	-- 기본폭 지정(100%)
	-- 넓은 너비의 폰트를 사용할 경우 100~150%까지 조정
	if (not NuguDropOption["ND_width"]) then
		NuguDropOption["ND_width"] = 100;
	end

	-- 누구드랍 툴팁이 존재하는 아이템(인던드랍템)들 중에서 랜덤 접두어가 붙는 아이템 정보 중에서
	-- 캐시에 저장된 랜덤접두어만 따로 저장
	if (not NDKnownSuffix) then
		NDKnownSuffix = {};
	end

	-- 각 랜덤 접두어에 관한 내용
	if (not ND_Suffix) then
		ND_Suffix = {};
	end

-------------------------------------------------------
function NuguDrop_OnLoad(self)
	SlashCmdList["NuguDropCOMMAND"] = function (msg)
		NuguDrop_SlashCmd(msg);
	end;
	SLASH_NuguDropCOMMAND1 = "/nd"
	SLASH_NuguDropCOMMAND2 = "/nugudrop"
	SLASH_NuguDropCOMMAND3 = "/누구드랍"
	local msgtext = "|cffff9C00누구드랍? v"..ND_Version.." (제작:시링크스흑마(얼라) [렉사르])|r"

	DEFAULT_CHAT_FRAME:AddMessage(msgtext);

--	self:RegisterEvent("VARIABLES_LOADED");
--	if (event == "VARIABLES_LOADED") then
--		if (LinkWrangler ~= nil) then
--			LinkWrangler.RegisterCallback ("NuguDrop", NuguDrop_OnShowPre, "refresh");
--		end
--	end

	-- LinkWrangler 지원
	if( (IsAddOnLoaded("LinkWrangler") ~= nil) and (LINK_WRANGLER_CALLER ~= nil) ) then
		LINK_WRANGLER_CALLER["NuguDrop"] = "NuguDrop_OnShowPre";
	end
end

function NuguDrop_Hide()
	if NuguDropListFrameItemList:IsVisible() then
		NuguDropListFrameItemList:Hide();
	end
	if NuguDropListFrameMobList:IsVisible() then
		NuguDropListFrameMobList:Hide();
	end
end

function NuguDrop_SlashCmd(msg)

--	local msg = gsub(msg, "%s*([^%s]+).*", "%1");
--
--	if ( strlen(cmd) <= 0 ) then
--		NuguDropListFrame_OnShow();
--		NuguDrop_HelpMsg();
--		return;
--	end
	msg = strlower(msg);
	if ( string.find(msg, "사전") ) then
		ND_CheckDic();
		if (dic_chk ~= 5 ) then
			NuguDropOption.ND_whatref = 1;
			NuguDrop_Print("이제부터 보유하고 있는 사전의 정보를 참조합니다.");
			ND_SpamCheck = 2;
			NuguDrop_Hide();
			return;
		else
			NuguDropOption.ND_whatref = 0;
			NuguDrop_Print("현재 아이템사전이 없거나 보유하고 있는 정보가 없습니다.");
			NuguDrop_Print("계속해서 캐시의 정보를 참조하게 합니다.");
			ND_SpamCheck = 2;
			NuguDrop_Hide();
			return;
		end

	elseif ( string.find(msg, "캐시") ) then
		NuguDropOption.ND_whatref = 0;
		NuguDrop_Print("이제부터 캐시의 정보를 참조합니다.");
		ND_SpamCheck = 2;
		NuguDrop_Hide();
		return;

	elseif ( string.find(msg, "폭 (%d+)") ) then
		NuguDropOption["ND_width"] = tonumber(string.match(msg, "폭 (%d+)"));
		if (NuguDropOption["ND_width"] < 100) or (NuguDropOption["ND_width"] >150) then
			NuguDrop_Print("100~150 사이의 숫자만 가능합니다.");
			NuguDropOption["ND_width"] = 100;
		else
			NuguDrop_Print("이제부터 몹/아이템 리스트의 폭이 |cff1eff00"..NuguDropOption["ND_width"].."|r% 로 조절됩니다.");
			NuguDrop_Hide();
		end

	elseif ( string.find(msg, "미니맵") ) then
		NuguDropButton_Toggle();

	elseif ( string.find(msg, "원위치") ) then
		NuguDrop_Print("누구드랍의 미니맵 버튼 위치가 초기화 되었습니다.(미니맵 제일 왼쪽)");
		NuguDrop_MoveButton(0);

	elseif ( string.find(msg, "위치 (%d+)") ) then
		local ND_position = string.match(msg, "위치 (%d+)");
		NuguDrop_MoveButton(ND_position);

	elseif ( string.find(msg, "고정") or string.find(msg, "락") ) then
		--local button = getglobal("NuguDropButton");
		-- 고정변수 토글
		if not NuguDropOption.ND_MoveFree then
			NuguDrop_Print("이제부터 미니맵 버튼을 고정시킵니다.");
			NuguDropOption.ND_MoveFree = not NuguDropOption.ND_MoveFree;
			-- 마우스 클릭 이벤트를 다 없앤다
			NuguDropButton:RegisterForDrag();
		else
			NuguDrop_Print("이미 미니맵 버튼이 고정되어 있습니다.");
		end

	elseif ( string.find(msg, "자유") or string.find(msg, "이동") ) then
		--local button = getglobal("NuguDropButton");
		if NuguDropOption.ND_MoveFree then
			NuguDropOption.ND_MoveFree = not NuguDropOption.ND_MoveFree;
			NuguDrop_Print("이제부터 미니맵 버튼을 자유롭게 이동시킬 수 있습니다.");
			-- 마우스 클릭 이벤트 등록
			NuguDropButton:RegisterForDrag("LeftButton", "RightButton");
		else
			NuguDrop_Print("이미 미니맵 버튼이 자유이동 상태입니다.");
		end

	elseif ( string.find(msg, "itemid") or string.find(msg, "아이템번호")) then
		NuguDropOption["ShowItemID"] = not NuguDropOption["ShowItemID"];
		if NuguDropOption["ShowItemID"] then
			NuguDrop_Print("이제부터 아이템ID 를 표시합니다.");
		else
			NuguDrop_Print("이제부터 아이템ID 를 표시하지 않습니다.");
		end

	elseif ( string.find(msg, "level") or string.find(msg, "아이템레벨")) then
		NuguDropOption["ShowItemLevel"] = not NuguDropOption["ShowItemLevel"];
		if NuguDropOption["ShowItemLevel"] then
			NuguDrop_Print("이제부터 아이템Level 을 표시합니다.");
		else
			NuguDrop_Print("이제부터 아이템Level 을 표시하지 않습니다.");
		end

	elseif ( string.find(msg, "아이템수") or string.find(msg, "갯수")) then
		NuguDrop_CountItemDB();

	elseif ( string.find(msg, "조회") ) then
		ND_ItemID_Button_OnClick();

	elseif ( string.find(msg, "즐겨찾기") or string.find(msg, "fav") ) then
		ND_Favorites();

	else
		NuguDropListFrame_OnShow();
		NuguDrop_HelpMsg();
	end
end

function NuguDrop_HelpMsg()
	NuguDrop_Print("|cffff0000━━━━━━━━━━━━━━|r");
	NuguDrop_Print("/누구드랍 |cff1eff00사전|r : 보유한 사전정보를 참조");
	NuguDrop_Print("/누구드랍 |cff1eff00캐시|r : 캐시정보를 참조");
	NuguDrop_Print("/누구드랍 |cffff9C00폭 [100-150]|r : 리스트의 가로폭 기준치를 설정(기본:100)");
	NuguDrop_Print("/누구드랍 |cffff9C00미니맵|r : 미니맵 아이콘 보기/감추기");
	NuguDrop_Print("/누구드랍 |cffff9C00원위치|r : 미니맵 아이콘 위치 초기화");
	NuguDrop_Print("/누구드랍 |cffff9C00위치 [0~360]|r : 버튼을 미니맵 주변에 지정위치");
	NuguDrop_Print("/누구드랍 |cffff9C00고정(락)|r : 미니맵 아이콘을 고정");
	NuguDrop_Print("/누구드랍 |cffff9C00자유(이동)|r : 미니맵 아이콘을 자유롭게 이동 가능");
	NuguDrop_Print("/누구드랍 |cffff9C00아이템번호(itemID)|r : 아이템ID 를 보여줍니다.");
	NuguDrop_Print("/누구드랍 |cffff9C00아이템레벨(level)|r : 아이템Level 을 보여줍니다.");
	NuguDrop_Print("/누구드랍 |cffff9C00즐겨찾기(fav)|r : 즐겨찾기 창 보기/감추기");
	NuguDrop_Print("/누구드랍 |cffff9C00조회|r : 아이템ID 를 직접 입력하여 링크확인 시도.");
	NuguDrop_Print("/누구드랍 |cffff9C00아이템수(갯수)|r : 현재 등록된 아이템수를 보여줍니다.");
	NuguDrop_Print("|cffff0000━━━━━━━━━━━━━━|r");
	NuguDrop_Print("/누구드랍 <|CFFFFFF66미니맵 아이콘 동작법|r>");
	NuguDrop_Print("/누구드랍 |cff7fffff좌클릭|r : 브라우저 열기");
	NuguDrop_Print("/누구드랍 |cff7fffff우클릭|r : 즐겨찾기 열기");
	NuguDrop_Print("/누구드랍 |cff7fffff휠버튼클릭|r : 위치 초기화(미니맵 제일 왼쪽)");
	NuguDrop_Print("/누구드랍 |cff7fffffShift + 휠버튼클릭|r : 아이콘 고정 토글");
	NuguDrop_Print("/누구드랍 |cff7fffffShift + 우클릭|r : 미니맵 주변에 버튼 부착/이동");
	NuguDrop_Print("|cffff0000━━━━━━━━━━━━━━|r");
end

function NuguDrop_GetComment(info, i)
	local comment = nil
	if (info[i])then
		comment = "|cffffffa4"..info[i].."|r";
		if (info[i+1]) then
			comment = comment.."|cffffffff-|r|cff00ffff"..info[i+1].."|r".." |cffffBC00";
			if (info[i+2]) then
				comment = comment.."<"..info[i+2]..">|r";
			end
		end
	end
	return comment;
end

function NuguDrop_AddLine(tooltip, comment, r, g, b)
	if (comment) then
		tooltip:AddLine(comment, NuguDropColor.r, NuguDropColor.g, NuguDropColor.b);
		return true;
	else
		return false;
	end
end

function NuguDrop_OnShowPre(frame)
	NuguDrop_OnShow(frame:GetName())
end

function NuguDrop_OnShow(tooltipString)
	if type(tooltipString) == "table" then return end
	local tooltip = getglobal(tooltipString);
	local textLeft1 = getglobal(tooltipString.."TextLeft1");

	if (not tooltip) or (not textLeft1) then
		return;
	end
	local firstLine = textLeft1:GetText();

	if firstLine then
-- 스킬명/몹이름/버프명/(퀘스트명) 이 동일한 경우 툴팁 2번째 줄로"아이템"인지 아닌지 선행 체크
	if ((firstLine == "용의 눈") or				-- 가장무도회 연계 퀘스트 이름
		(firstLine == "의지의 힘") or			-- 스킬명?;;;
		(firstLine == "무력의 손길") or			-- 스킬명?;;;
		(firstLine == "영혼의 약탈자") or		-- 줄구릅 몹 이름
		(firstLine == "폭풍의 눈") or			-- 모였더라?;;;
		(firstLine == "수정거미 송곳니") or		-- 단검 사용시 버프명
		(firstLine == "자연의 은총") or			-- 드루이드 스킬명
		(firstLine == "격노의 토템") or			-- 주술사 스킬명
		(firstLine == "까마귀의 발톱") or		-- 안주 소환
		(firstLine == "세나리우스의 천벌") or	-- 드루이드 특성
		(firstLine == "심판의 망치") or			-- 성기사 특성
		(firstLine == "죽음의 고리") or			-- 흑마 스킬명
		(firstLine == "연금술사의 돌") or
		(string.find(firstLine, "격노")) or
		(string.find(firstLine, "분노")) or
		(firstLine == "퀴라지 학살자")) then	-- 안퀴라즈 몹 이름
		local textLeft2 = getglobal(tooltipString.."TextLeft2");
		if textLeft2 then
			local secondLine = getglobal(tooltipString.."TextLeft2"):GetText();
			if secondLine then
				-- "아이템"의 경우 2번째 줄이 항상 "착용시 귀속"/"획득시 귀속"/"귀속 아이템" 으로 나오므로
				-- 공통인자인 "귀속"이란 단어로 체크 / "격노","분노"가 들어가는 도안류인 경우도 체크
				if not (string.find(secondLine, "귀속")  or string.find(secondLine, "요구 사항")) then return;
				end
			else
			-- 툴팁 2번째 줄이 없는경우
				return;
			end
		else return;
		end
	end
	end

local change = false;

	if firstLine and NuguDrop and NuguDropCustom then

		-- 누구드랍 정보 조사 / 툴팁 추가
		if NuguDrop[firstLine] then

			local _, link = tooltip:GetItem();

			-- 동일 이름 아이템의 경우 미리 기입한 ItemID(9번 항목) 체크
			-- 9번 항목이 없으면 그냥 처리
			if (not NuguDrop[firstLine][9]) then
				-- ItemID 랑 링크아이템의 ItemID 비교
				if NuguDrop[firstLine]["id"] then
					if (ND_getIdFromLink(link) == NuguDrop[firstLine]["id"]) then
						if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[firstLine], 1)) == true then
							change = true;
						end
					else
--							change = true;
					end
				end
			-- 9번 항목이 있으면(즉, 동일한 이름의 다른 아이템이 존재하는 경우)
			elseif NuguDrop[firstLine][9] then
				if (ND_getIdFromLink(link) == NuguDrop[firstLine][9]) then
					if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[firstLine], 1)) == true then
						change = true;
					end
				-- 지정된 고유아이템ID 와 틀릴경우 DB 에 저장된 동일이름아이템들 검색
				-- ex) 보랏빛 인장 / 청동용군단 반지 / 옥쇄 / 명예 아이템등을 고려해 추가 14개까지 >_<
				else
					for i = 1, 14 do
						if NuguDrop[firstLine.."@"..i] then
							if (ND_getIdFromLink(link) == NuguDrop[firstLine.."@"..i][9]) then
								if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[firstLine.."@"..i], 1)) == true then
									change = true;
								end
							end
						end
					end
				end
			elseif ((firstLine == "바위주먹") and (ND_getIdFromLink(link) == 11743)) then
				if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[firstLine.."@1"], 1)) == true then
					change = true;
				end
			end
		-- 커스텀 정보 조사 / 툴팁 추가
		elseif NuguDropCustom[firstLine] then
			if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDropCustom[firstLine], 1)) == true then
				change = true;
			end
		end

		-- 커스텀 정보만 으로 되어 있는 것 조사 / 툴팁 추가
		-- 캐시에 저장된 보석 링크(7번 태그[Boolean 값] 체크)는 추가정보를 제외시킨다.
		if NuguDropCustom[firstLine] and (not NuguDropCustom[firstLine][7]) then
			if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDropCustom[firstLine], 4)) == true then
				change = true;
			end
		end

--###############################
		if (not change) then

-- 랜덤 접두어 "~의" 아이템 처리
			local _, _, Prefix, BaseName = string.find(firstLine, "(.[^%s]+)의 (.+)")

			local _, link = tooltip:GetItem();
--if Prefix and BaseName then
--NuguDrop_Print("▶"..Prefix.." / "..BaseName);
--end

-- 누구드랍 툴팁이 존재하는 아이템(인던드랍템)들 중에서 랜덤 접두어가 붙는 아이템 정보 중
-- 캐시에 저장된 랜덤접두어만 따로 저장
			if link then
				if( string.find(link, "%d+:%d+:%d+:") ) then
					local _, _, itemString = string.find(link, "^|%x+|H(.+)|h%[.+%]")
					if itemString then
					local found, _, linkType, itemID, enchantID, jewelID1, jewelID2, jewelID3, jewelID4, suffixID, uniqueID = string.find(itemString, "^(.+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)")

	--	--"입찰을 선택했습니다: |cff1eff00|Hitem:24647:0:0:0:0:0:-37:1140654129|h[치료사의 아스트랄란 로브]|h|r", -- [151]
	--	--"입찰을 선택했습니다: |cff1eff00|Hitem:25052:0:0:0:0:0:-15:697827355|h[정신력의 남방석 반지]|h|r", -- [117]
	--	--"아이템을 획득했습니다: |cff1eff00|Hitem:24808:0:0:0:0:0:-33:737345573|h[냉기 보호의 불굴 사슬 조끼]|h|r", -- [380]
	--	--"아이템을 획득했습니다: |cffffffff|Hitem:28116:0:0:0:0:0:0:-2125448076|h[비행선 잔해]|h|r", -- [381]
	--	--"아이템을 획득했습니다: |cffffffff|Hitem:25433:0:0:0:0:0:0:-1588202921|h[흑요석 전투 목걸이]|h|r", -- [450]

					-- 아이템인 경우만 처리
					if (linkType == 'item') then

						local itemName = GetItemInfo(itemID);
						local suffixname;
						local fullitemName;
						local suffixFactor;
						local suffixtable = {};

						local SUFFIX_IDS_TO_NAME_KEYS = ND_Suffix.suffixIDsToNameKeys;
						local SUFFIX_NAMES_TO_NAME_KEYS = ND_Suffix.suffixNamesToNameKeys;
						local SUFFIX_NAME_KEYS_TO_NAMES = ND_Suffix.suffixNameKeysToNames;

						suffixID = tonumber(suffixID) or 0
						uniqueID = tonumber(uniqueID) or 0

						--bit.bnot(a) - returns the one's complement of a
						--bit.band(w1,...) - returns the bitwise and of the w's
						--bit.bor(w1,...) - returns the bitwise or of the w's
						--bit.bxor(w1,...) - returns the bitwise exclusive or of the w's
						--bit.lshift(a,b) - returns a shifted left b places
						--bit.rshift(a,b) - returns a shifted logically right b places
						--bit.arshift(a,b) - returns a shifted arithmetically right b places
						--bit.mod(a,b) - returns the integer remainder of a divided by b

						--  WOW 2.0 부터는 둘 다 음수인 경우 특별한 가중치값을 계산할 수 있도록 suffixFactor 값을 사용한다.(얼마없음;;)
						if (suffixID < 0 and uniqueID < 0) then
							-- suffixFactor
							-- b 와 and
							-- 65535 = 63336 - 1 = 2^16 -1 = 111111111111111 과 and
							-- 즉, uniqueID 의 2진수값이 그대로 전달
							-- 일단 조사만 해둔다 -_- 먼가 쓸데가 있을지도 -0-;;
							suffixFactor = bit.band(uniqueID, 65535)
						end
						-- suffixID 가 0 이 아니면 랜덤 접두어가 붙는 아이템이다.
						if (suffixID ~= 0) then
							suffixname = SUFFIX_NAME_KEYS_TO_NAMES[SUFFIX_IDS_TO_NAME_KEYS[suffixID]]
							if (suffixname) then
								itemName = (itemName:gsub(suffixname, "", 1)):trim();
								fullitemName = suffixname.." "..itemName

								-- 데이터 추가(itemID 기준)

								if (type(itemID) ~= "number") then
									NDKnownSuffix[itemID] = nil;
									itemID = tonumber(itemID);
								end

								if (not NDKnownSuffix[itemID]) then
									NDKnownSuffix[itemID] = suffixtable;
									NDKnownSuffix[itemID]["name"] = itemName;
								end

								if (not NDKnownSuffix[itemID][suffixID]) then
									NDKnownSuffix[itemID][suffixID] = {};
									NDKnownSuffix[itemID][suffixID][1] = suffixname;
									NDKnownSuffix[itemID][suffixID][2] = uniqueID;
								end
								if suffixFactor then
									NDKnownSuffix[itemID][suffixID][3] = suffixFactor;
								end
							end
						end
					end
					end
				end
			end


			if BaseName and NuguDrop[BaseName] then
				if NuguDrop[BaseName]["id"] then
--if ND_getIdFromLink(link) then
--NuguDrop_Print("▶Pre_ID: "..NuguDrop[BaseName]["id"].." ▶LinkID: "..ND_getIdFromLink(link));
--end
					if (ND_getIdFromLink(link) == NuguDrop[BaseName]["id"]) then
						if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[BaseName], 1)) == true then
							change = true;
						end
					end
				end
			end
			-- [랜덤속성] 저항'의' 열'의' 투구 체크 : "의"자가 2개 들어가서 생기는 -_-ㅋ
			local _, _, RRegist, YHead = string.find(firstLine, "(.+) 저항의 (.+)")
			if (YHead == "열의 투구") and (not change) then
				if NuguDrop_AddLine(tooltip, NuguDrop_GetComment(NuguDrop[YHead], 1)) == true then
					change = true;
				end
			end
		end
	end

	local iteminfo;
	-- 아이템ID 를 보여주기 위한 구문
	if NuguDropOption["ShowItemID"] then
		local _, link = tooltip:GetItem();
		if link then
			local itemID = ND_getIdFromLink(link);
			iteminfo = "ItemID : "..itemID.."   ";
		end
	end

	-- 아이템Level 을 보여주기 위한 구문
	if NuguDropOption["ShowItemLevel"] then
		local _, link = tooltip:GetItem();
		if link then
			local _, _, _, itemLevel = GetItemInfo(link)
			if iteminfo and itemLevel then
				iteminfo = iteminfo.."ItemLevel : "..itemLevel;
			elseif itemLevel then
				iteminfo = "ItemLevel : "..itemLevel;
			end
		end
	end

	if NuguDropOption["ShowItemID"] or NuguDropOption["ShowItemLevel"] then
		tooltip:AddLine(iteminfo, 1, 0.7, 0);
	end

	if change then
		tooltip:Show();
	end
end


--#########################################################
-- 패치가 이루어진 경우 초기화 해야 하나? 게임버전 체크?

do
	--local startTime, startMem = GetTime(), collectgarbage("count");
	local baseName;
	local baseID = 25; -- "낡은 쇼트쇼드", 일반아이템 중 가장 낮은 baseID

	while (baseID < 50000 and baseName == nil) do
		baseName = GetItemInfo(baseID);
		baseID = (baseID + 1);
	end

	baseID = (baseID - 1);

	ND_Suffix.suffixIDsToNameKeys = {};
	ND_Suffix.suffixNamesToNameKeys = {};
	ND_Suffix.suffixNameKeysToNames = {};

	if (baseName ~= nil) then

		local linkPrefix = ("item:"..baseID..":0:0:0:0:0:");
		local increment = 1;
		local nameWithSuffix;
		local suffixName;

		-- suffixid 는 -70 에서 2200까지 지정됨 WOWWiki 참조
		for index = -70, 2200 do
			nameWithSuffix = GetItemInfo(linkPrefix..index..":0");

			if (nameWithSuffix ~= baseName) then
				suffixName = string.trim((string.gsub(nameWithSuffix, baseName, "", 1)));

				if (suffixName ~= "") then
					if (ND_Suffix.suffixNamesToNameKeys[suffixName] == nil) then
						ND_Suffix.suffixNamesToNameKeys[suffixName] = increment;
						table.insert(ND_Suffix.suffixNameKeysToNames, suffixName);
						increment = (increment + 1);
					end
					ND_Suffix.suffixIDsToNameKeys[index] = ND_Suffix.suffixNamesToNameKeys[suffixName];
				end
			end
		end
	end
end

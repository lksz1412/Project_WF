SelectedZone = nil;
SelectedMob = nil;
ND_SpamCheck = 1;
ND_OldCheck = NuguDropOption["SelectedTab"]

-----------------------------
-- 각 Tab별로 해당되는 DB 이름 지정
-----------------------------

ND_DB = {NuguDropOri, NuguDropExp, NuguDropNorth, NuguDropEtc, NuguDropRep1, NuguDropRep2, NuguDropRep3, NuguDropJewel};

ND_DBName = {"아제로스", "아웃랜드", "노스렌드", "명예/기타", "평판(아제로스)", "평판(아웃랜드)", "평판(노스렌드)", "보석/전문기술"};

ND_DBZone = {NuguDropZoneList_Orig, NuguDropZoneList_Exp, NuguDropZoneList_North, NuguDropZoneList_Etc,
			NuguDropZoneList_Rep1, NuguDropZoneList_Rep2, NuguDropZoneList_Rep3, NuguDropZoneList_Jewel};

ND_DBMob = {NuguDropMobList_Orig, NuguDropMobList_Exp, NuguDropMobList_North, NuguDropMobList_Etc,
			NuguDropMobList_Rep1, NuguDropMobList_Rep2, NuguDropMobList_Rep3, NuguDropMobList_Jewel};

-----------------------------
-- 아이템 사전별 Link 반환 함수
-----------------------------
ND_LinkFuction = function (dic, name, id)
	-- 0. 최신버전 아이템싱크(ItemSync r25808 이상)
	if (dic == 0) then
		return ND_ItemSync_GetTextLink(name, id);

	-- 2. Saeris's LootLink
	elseif (dic == 2) then
		return ND_LootLink_GetLink(name, id);

	-- 3. LootLink (하늘아리)
	elseif (dic == 3) then
		return ND_LootLink_GetLink(name, id);

	-- 4. KC_Items와 LinkView모듈이 활성화 된경우
	elseif (dic == 4) then
		return NuguDropGetKC_ItemsLink(name, id);
	else
		ND_CheckDic();
	end
end

-----------------------------
-- 기본 화면 출력 함수
-----------------------------
function NuguDrop_Print(text)
	if (text) then DEFAULT_CHAT_FRAME:AddMessage("|cffff8000<누구드랍>|r "..text); end
end
-------------------------------------------------
-- 분류탭을 선택했을때 Zone/Mob List 변경
-------------------------------------------------
function ND_CheckTab()
	NuguDropZoneList = {};
	NuguDropMobList = {};
	ND_TempGroup = nil;

	NuguDropZoneList = ND_DBZone[NuguDropOption.SelectedTab];
	NuguDropMobList = ND_DBMob[NuguDropOption.SelectedTab];
end

--------------------------------------------------
-- 분류탭 변경시 기존 Zone/Mob List 초기화
--------------------------------------------------
function ND_FlushZoneList(check)
	local listsize1 = #NuguDropZoneList;
	for n=1,listsize1 do
		-- 차후 다른 Tab 에서 또다른 Title 바를 사용할 경우 수정해야 함 (최대치 7: 아웃랜드)
		if (not ND_Order) then ND_Order = 7; end
		for n=1,ND_Order do
			getglobal("NuguDropZoneTitle"..n):Hide();
		end
		getglobal("NuguDropZone"..n):Hide();
	end
	if (SelectedZone) then
		local listsize2 = #NuguDropMobList[NuguDropZoneList[SelectedZone]];
		for n=1,listsize2 do
			getglobal("NuguDropMob"..n):UnlockHighlight();
			getglobal("NuguDropMob"..n.."_Text"):SetText("");
			getglobal("NuguDropMob"..n):Disable();
			getglobal("NuguDropMob"..n):Hide();
		end
	end
	if (SelectedMob) then
		if (ND_Temp_Itemname) then
			local listsize3 = #ND_Temp_Itemname;
			for n=1,listsize3 do
				getglobal("NuguDropItem"..n):Hide();
			end
		end
	end
	SelectedZone = nil;
	SelectedMob = nil;
end

--------------------------------------------------
--[[ 사전 종류 체크 ]]
--------------------------------------------------
function ND_CheckDic()
	-- 0. 확장팩용 아이템싱크(ItemSync r25808 이상)
	if (ISyncDB) then
		dic_chk = 0;
		--local ISyncVer = ISyncDB["account"]["dboptions"]["version"][1];
		--NuguDrop_Print("ItemSync "..ISyncVer);
		--local ISyncItemCount = ISyncDB["account"][1]["options"]["ItemCount"];
		--NuguDrop_Print("ItemSync 가 보유한 Item 갯수 : "..ISyncItemCount);

	-- 2. Saeris's LootLink
	elseif (LootLink_Database) then
		-- Saeris's LootLink  버전일 경우 미니맵 아이콘이 있으므로.. 그중 X 좌표에 할당된 변수값이 존재하는지 체크
		--if (LootLink_Config.ToggleButtonX) then
		dic_chk = 2;

	-- 3. LootLink (하늘아리)
	elseif (LOOTLINK_VERSION) and (ItemLinks) then
		dic_chk = 3;

	-- 4. KC_Items와 LinkView모듈이 활성화 된경우 (by Creep7)
	elseif (KC_ITEMS_LOCALS) and (KC_ITEMS_LOCALS.modules.linkview) then
		dic_chk = 4;

	-- 5. 아이템사전이 없거나 인식을 못한경우
	else dic_chk = 5;
	end
	--NuguDrop_Print("사전 종류 : "..dic_chk);
end


--------------------------------------------------
--	기 본 함 수 --
--------------------------------------------------

function NuguDropListFrame_OnShow()
	PlaySound("igMainMenuOpen");
	if NuguDrop then
		NuguDropListFrame:Show();
		ND_ItemID_ButtonFrame:Show();
		NuguDropListFrameZoneList:Show();
		if NuguDropListFrameMobList:IsVisible() then
			NuguDropListFrameMobList:Hide();
			if NuguDropListFrameItemList:IsVisible() then
				NuguDropListFrameItemList:Hide();
			end
		end
		ND_CheckDic();
		NuguDropListFrame_ZoneList();
	else
		NuguDropListFrame:Hide();
		ND_ItemID_ButtonFrame:Hide();
		NuguDropListFrameMobList:Hide();
	end
	-- Escape Key 로 NuguDrop을 닫을 수 있도록 UISpecialFrames 에 등록 (By icecre4m)
	tinsert(UISpecialFrames,"NuguDropListFrame");
end

function NuguDropListFrame_OnHide()
	PlaySound("igMainMenuClose");
	NuguDropListFrameCloseButton_OnClick();
end

function NuguDropListFrame_OnLoad()
	-- 화면내 유지
	NuguDropListFrame:SetClampedToScreen(true);
	ND_CheckDic();
end

function NuguDropListFrame_OnMouseDown(arg1) if arg1=="LeftButton" then NuguDropListFrame:StartMoving(); end end
function NuguDropListFrame_OnMouseUp(arg1) if arg1=="LeftButton" then NuguDropListFrame:StopMovingOrSizing(); end end

function NuguDropListFrameCloseButton_OnClick()
	NuguDropListFrame_Close();
end

function NuguDropListFrame_Close()
	NuguDropListFrame:StopMovingOrSizing();
	HideUIPanel(NuguDropListFrame);
end

function NuguDropListFrame_Toggle()
	if(NuguDropListFrame:IsVisible()) then
		HideUIPanel(NuguDropListFrame);
	else
		ShowUIPanel(NuguDropListFrame);
	end
end

-----------------------------------
-- Zone을 출력하는 부분
-----------------------------------
--############# 아웃랜드/노스렌드일 경우
function NuguDropListFrame_ZoneList()
	ND_CheckTab();
	local i = #NuguDropZoneList;

	-- 아웃랜드/노스렌드일 경우(영웅모드가 있는 경우) Title 인지 Zone 인지 판별하여 다른 버튼 생성
	if (NuguDropOption["SelectedTab"] == 2) or (NuguDropOption["SelectedTab"] == 3) then
		TempGroup = {};
		for n=1,i do

			--############### 1. Title 이면~
			if NuguDropZoneList[n]["Order"] then
				local ZoneButton = getglobal("NuguDropZoneTitle"..NuguDropZoneList[n]["Order"]);
				local ZoneText = getglobal("NuguDropZoneTitle"..NuguDropZoneList[n]["Order"].."_Text");
				-- 첫번째 타이틀인 경우 상대위치를 Main 타이틀바 기준으로..
				if (NuguDropZoneList[n]["Order"] == 1) then
					ZoneButton:SetPoint("TOPLEFT", NuguDropListFrame, "BOTTOMLEFT", 5, -3);
				-- 그 외의 경우엔 이전 Zone 버튼을 상대위치로..
				else
					local relFrame = getglobal("NuguDropZone"..(n-1));
					ZoneButton:SetPoint("TOPLEFT", relFrame, "BOTTOMLEFT", 0, 0);
				end
				--ZoneButton:CreateFontString("TitleText", "OVERLAY", "GameFontHighlightLarge");
				--ZoneButton:SetBackdropColor(0, 0, 1, 1);
				-- 마우스 오버시 Texture(XML 에서 변경) 와 글자색 변경
				ZoneButton:SetScript("OnEnter", function()
													ZoneText:SetTextColor(1, 0, 0, 1);
													GameTooltip:SetOwner(this, "ANCHOR_LEFT");
													GameTooltip:SetText("클릭하시면 영웅모드 드랍템을\n살펴볼 수 있습니다.");
												end);
				-- 마우스를 치웠을 땐 기본 푸른 색으로
				ZoneButton:SetScript("OnLeave", function()
													ZoneText:SetTextColor(0, 0.3, 0.7, 1);
													GameTooltip:Hide();
												end);
				--ZoneButton:SetHighlightTexture(1, 0, 0, 1);
				ZoneText:SetText(NuguDropZoneList[n]["Title"]);
				ZoneText:SetTextColor(0, 0.3, 0.7, 1);
				ZoneButton:SetScript("OnClick", function() NuguDropZoneTitleButton_OnClick(n) end);
				ZoneButton:Enable();
				ZoneButton:Show();

				ND_TempGroup = NuguDropZoneList[n]["Group"];
				ND_Order = NuguDropZoneList[n]["Order"];


			--############### 2. Zone 이면~
			else
				if (getglobal("NuguDropZone"..n)) then
					getglobal("NuguDropZone"..n):UnlockHighlight();
				end
				local ZoneButton = getglobal("NuguDropZone"..n);
				local ZoneText = getglobal("NuguDropZone"..n.."_Text");
				-- Title 의 첫번째 그룹이면 상대위치를 해당 Title로..
				if (n == ND_TempGroup[1]) then
					local relFrame = getglobal("NuguDropZoneTitle"..ND_Order);
					ZoneButton:SetPoint("TOPLEFT", relFrame, "BOTTOMLEFT", 0, 0);
				else
					local relFrame = getglobal("NuguDropZone"..(n-1));
					ZoneButton:SetPoint("TOPLEFT", relFrame, "BOTTOMLEFT", 0, 0);
				end
				--Zone:CreateFontString("ZoneText", "OVERLAY", "GameFontHighlightLarge");
				ZoneText:SetText(NuguDropZoneList[n]);
				-- 색 구분
				if (string.find(NuguDropZoneList[n], "(아웃랜드)")) or
					(string.find(NuguDropZoneList[n], "(노스렌드)")) then
					ZoneText:SetTextColor(0, 0.7, 0.8, 1);
				elseif (string.find(NuguDropZoneList[n], "공>")) or
					(string.find(NuguDropZoneList[n], "필드Raid")) or
					(string.find(NuguDropZoneList[n], "명예")) or
					(string.find(NuguDropZoneList[n], "기타")) then
					ZoneText:SetTextColor(1, 0.7, 0, 1);
				elseif (string.find(NuguDropZoneList[n], "<영웅>")) then
					ZoneText:SetTextColor(1, 0.3, 0, 1);
				else
					ZoneText:SetTextColor(1, 1, 0.7, 1);
				end
				ZoneButton:SetScript("OnClick", function() NuguDropZoneButton_OnClick(n) end);
				ZoneButton:Enable();
				ZoneButton:Show();
			end
		end
	-- 아웃랜를 제외한 탭인 경우(기존방법)
	else
		for n=1,i do
			getglobal("NuguDropZone"..n):UnlockHighlight();
			NuguDropListFrame_ZoneInsert(n, NuguDropZoneList[n]);
		end
	end
	NuguDropListFrameZoneList:SetHeight(18 + (18*i));
end

------------------------------------
--############# 아웃랜드/노스렌드를 제외한 탭의 존을 나열할 때 사용하는 기존 함수
function NuguDropListFrame_ZoneInsert(n, zonename)
	local ZoneButton = getglobal("NuguDropZone"..n);
	local ZoneText = getglobal("NuguDropZone"..n.."_Text");
	ZoneText:SetText(zonename);
	-- 첫번째 존인 경우 타이틀바를 상대위치로..
	if (n == 1) then
		ZoneButton:SetPoint("TOPLEFT", NuguDropListFrame, "BOTTOMLEFT", 5, -3);
	else
		local relFrame = getglobal("NuguDropZone"..(n-1));
		ZoneButton:SetPoint("TOPLEFT", relFrame, "BOTTOMLEFT", 0, 0);
	end
	ZoneButton:SetScript("OnClick", function() NuguDropZoneButton_OnClick(n) end);
	-- 색 구분
	if (string.find(zonename, "공>")) or
		(string.find(zonename, "필드Raid")) or
		(string.find(zonename, "명예")) or
		(string.find(zonename, "던전셋")) or
		(string.find(zonename, "Tier")) or
		(string.find(zonename, "/")) then
		ZoneText:SetTextColor(1, 0.7, 0, 1);
	elseif (string.find(zonename, "기타")) then
		ZoneText:SetTextColor(0, 0.7, 0.8, 1);
	elseif (string.find(zonename, "투기장")) or
		(string.find(zonename, "<야외")) or
		(string.find(zonename, "<얼개")) or
		(string.find(zonename, "<평판")) then
		ZoneText:SetTextColor(0.8, 0.8, 1, 1);
	elseif (string.find(zonename, "<휘장")) or
		(string.find(zonename, "<조각")) or
		(string.find(zonename, "<무용문장")) or
		(string.find(zonename, "<용맹문장")) then
		ZoneText:SetTextColor(1, 0.3, 0.8, 1);
	else
		ZoneText:SetTextColor(1, 1, 0.7, 1);
	end
	ZoneButton:Enable();
	ZoneButton:Show();
end


-- Title 을 선택했을때 해당지역 존들만 영웅/일반모드로 전환
function NuguDropZoneTitleButton_OnClick(Title)
	if (not NuguDropZoneList) then return; end
	if (SelectedZone) then
		getglobal("NuguDropZone"..SelectedZone):UnlockHighlight();
		local i = #NuguDropMobList[NuguDropZoneList[SelectedZone]];
		for n=1,i do
			getglobal("NuguDropMob"..n):UnlockHighlight();
			getglobal("NuguDropMob"..n.."_Text"):SetText("");
			getglobal("NuguDropMob"..n):Disable();
			getglobal("NuguDropMob"..n):Hide();
		end
	end
	SelectedZone = nil;
	NuguDropListFrameItemList:Hide();
	NuguDropListFrameMobList:Hide();

	local S_Group = NuguDropZoneList[Title]["Group"];
	local i = #S_Group;
	for n=1,i do
		--제일 뒤에 공>이나 "제조법"이 없는 것들만 토글
		if ((not string.find(NuguDropZoneList[S_Group[n]], "공>"))
			and (not string.find(NuguDropZoneList[S_Group[n]], "제조법"))) then
			local ZoneButton = getglobal("NuguDropZone"..S_Group[n]);
			local ZoneText = getglobal("NuguDropZone"..S_Group[n].."_Text");
			-- 일반모드일 경우 제일 뒤에 <영웅>이라 붙인다.
			if (not string.find(NuguDropZoneList[S_Group[n]], "<영웅>")) then
				NuguDropZoneList[S_Group[n]] = NuguDropZoneList[S_Group[n]].."<영웅>"
				ZoneText:SetText(NuguDropZoneList[S_Group[n]]);
				ZoneText:SetTextColor(1, 0.5, 0, 1);
			-- 만약 이미 영웅모드라면 다시 일반모드로 전환
			else
				NuguDropZoneList[S_Group[n]] = string.gsub(NuguDropZoneList[S_Group[n]], "(.+)<영웅>", "%1")
				ZoneText:SetText(NuguDropZoneList[S_Group[n]]);
				ZoneText:SetTextColor(1, 1, 0.7, 1);
			end
		-- 노스렌드의 경우 10공> 25공> 구분
		else
			if (NuguDropOption["SelectedTab"] == 3) then
				local ZoneButton = getglobal("NuguDropZone"..S_Group[n]);
				local ZoneText = getglobal("NuguDropZone"..S_Group[n].."_Text");
				-- 10인공격대일 경우 25인공격대로 토글.
				if (not string.find(NuguDropZoneList[S_Group[n]], "<25공>")) then
					NuguDropZoneList[S_Group[n]] = string.gsub(NuguDropZoneList[S_Group[n]], "(.+)<10공>", "%1")
					NuguDropZoneList[S_Group[n]] = NuguDropZoneList[S_Group[n]].."<25공>"
					ZoneText:SetText(NuguDropZoneList[S_Group[n]]);
					ZoneText:SetTextColor(1, 0.3, 0, 1);
				-- 만약 이미 25인공격대라면 다시 10인공격대로 전환
				else
					NuguDropZoneList[S_Group[n]] = string.gsub(NuguDropZoneList[S_Group[n]], "(.+)<25공>", "%1")
					NuguDropZoneList[S_Group[n]] = NuguDropZoneList[S_Group[n]].."<10공>"
					ZoneText:SetText(NuguDropZoneList[S_Group[n]]);
					ZoneText:SetTextColor(1, 0.7, 0, 1);
				end
			end
		end
	end
end

-- 특정 Zone 을 선택했을때
function NuguDropZoneButton_OnClick(zone)
	if (not NuguDropZoneList) then return; end
	if (SelectedZone) then
		getglobal("NuguDropZone"..SelectedZone):UnlockHighlight();
		local i = #NuguDropMobList[NuguDropZoneList[SelectedZone]];
		for n=1,i do
			getglobal("NuguDropMob"..n):UnlockHighlight();
			getglobal("NuguDropMob"..n.."_Text"):SetText("");
			getglobal("NuguDropMob"..n):Disable();
			getglobal("NuguDropMob"..n):Hide();
		end
	end
	SelectedZone = zone;
	getglobal("NuguDropZone"..zone):LockHighlight();
	-- 몹 리스트 출력
	if (not NuguDropListFrameMobList:IsVisible()) then
		NuguDropListFrameMobList:Show();
		NuguDropListFrame_MobList(SelectedZone);
	else
		NuguDropListFrame_MobList(SelectedZone);
	end
	-- 아이템 리스트를 숨긴다
	NuguDropListFrameItemList:Hide();
end

-----------------------------------
-- Mob을 출력하는 부분
-----------------------------------
function NuguDropListFrame_MobList(SelectedZone)
	local i2 = #NuguDropMobList[NuguDropZoneList[SelectedZone]];

	-- 텍스트 길이에 따른 가변폭 설정
	ND_MaxWidth = 0;
	for n=1,i2 do
		-- 한글은 3 나머지 영문/특수문자 1 이므로 숫자/영문(LENGTH 1)을 "한"(LENGTH 3)으로 임시대처함
		local tlen_tmp = string.gsub(NuguDropMobList[NuguDropZoneList[SelectedZone]][n], "%w", "한")
--		local tlen_tmp2 = string.gsub(tlen_tmp, "%s", "한")
		local tlen = string.len(tlen_tmp)/3;
		ND_MaxWidth = math.max(ND_MaxWidth, tlen);
	end

	NuguDropListFrameMobList:SetHeight(18 + (18*i2));

	if (not NuguDropOption["ND_width"]) then
		NuguDropOption["ND_width"] = 100;
	end
--NuguDrop_Print("ND_MaxWidth : "..ND_MaxWidth);
	-- 폭 미세조정 >_<;;
	if ND_MaxWidth <= 6 then
		NuguDropListFrameMobList:SetWidth((ND_MaxWidth*15 + 13)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 + 13)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 폭1 : "..ND_MaxWidth);
	elseif ND_MaxWidth <= 10 then
		NuguDropListFrameMobList:SetWidth((ND_MaxWidth*15 + 3)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 + 3)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 폭2 : "..ND_MaxWidth);
	elseif ND_MaxWidth <= 15 then
		NuguDropListFrameMobList:SetWidth((ND_MaxWidth*15 - 6)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 - 6)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 폭3 : "..ND_MaxWidth);
	--elseif ND_MaxWidth <= 20 then
	else
		NuguDropListFrameMobList:SetWidth((ND_MaxWidth*14)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*14)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 폭4 : "..ND_MaxWidth);
	end

	for n=1,i2 do
		NuguDropListFrame_MobInsert(n, NuguDropMobList[NuguDropZoneList[SelectedZone]][n], ND_MaxWidth);
	end
end

function NuguDropListFrame_MobInsert(n, Mobname, ND_MaxWidth)
	local MobButton = getglobal("NuguDropMob"..n);
	local MobText = getglobal("NuguDropMob"..n.."_Text");
	MobButton:SetWidth(ND_MaxWidth-5);
	MobText:SetText(Mobname);
	-- 희귀몹/일반몹/퀘소환몹/기타 색깔변경
	if (string.find(Mobname, "희귀")) or
		(string.find(Mobname, "광란의경계")) or
		(string.find(Mobname, "중급")) or
		(string.find(Mobname, "알도르)")) or
		(string.find(Mobname, "(영웅드랍)")) or
		(string.find(Mobname, "<평판")) or
		(string.find(Mobname, "장군의 정원")) or
		(string.find(Mobname, "중간보스")) or
		(string.find(Mobname, "세트아이템")) or
		(string.find(Mobname, "only")) then
		MobText:SetTextColor(0.8, 0.8, 1, 1);
	elseif (string.find(Mobname, "일반")) or
		(string.find(Mobname, "<보석>")) or
		(string.find(Mobname, "상자")) or
		(string.find(Mobname, "공물함")) or
		(string.find(Mobname, "공통")) or
		(string.find(Mobname, "퀘")) or
		(string.find(Mobname, "인던내 드랍")) or
		(string.find(Mobname, "상급")) then
		MobText:SetTextColor(0.4, 0.9, 0.7, 1);
	elseif (string.find(Mobname, "현존X")) then
		MobText:SetTextColor(0.7, 0.7, 0.7, 1);
	elseif (string.find(Mobname, "Boss")) then
		MobText:SetTextColor(1, 0.5, 0, 1);
	-- 낙스 지역 구분
	elseif (string.find(Mobname, "골렘%d")) then
		--or (string.find(Mobname, "(얼라이언스)")) then
		MobText:SetTextColor(0.5, 0.8, 0.5, 1);
	elseif (string.find(Mobname, "거미%d")) then
		MobText:SetTextColor(0.8, 0.8, 1, 1);
	elseif (string.find(Mobname, "기사단%d")) then
		MobText:SetTextColor(0.8, 0.5, 0.5, 1);
	elseif (string.find(Mobname, "역병%d")) then
		MobText:SetTextColor(0.8, 0.5, 0.8, 1);
	-- <명예/기타> Tab 일 경우 직업별 색 구분
	elseif (NuguDropOption["SelectedTab"] == 4) or (NuguDropOption["SelectedTab"] == 6) then
		if (string.find(Mobname, "성기사")) then
			MobText:SetTextColor(0.96, 0.55, 0.73, 1);
		elseif (string.find(Mobname, "전사")) then
			MobText:SetTextColor(0.78, 0.61, 0.43, 1);
		elseif (string.find(Mobname, "주술사")) then
			MobText:SetTextColor(0.14, 0.35, 1, 1);
		elseif (string.find(Mobname, "사냥꾼")) then
			MobText:SetTextColor(0.67, 0.83, 0.45, 1);
		elseif (string.find(Mobname, "도적")) then
			MobText:SetTextColor(1, 0.96, 0.41, 1);
		elseif (string.find(Mobname, "드루이드")) then
			MobText:SetTextColor(1, 0.49, 0.04, 1);
		elseif (string.find(Mobname, "사제")) then
			MobText:SetTextColor(1, 1, 1, 1);
		elseif (string.find(Mobname, "마법사")) then
			if (string.find(Mobname, "흑마법사")) then
				MobText:SetTextColor(0.58, 0.51, 0.79, 1);
			else
				MobText:SetTextColor(0.41, 0.8, 0.94, 1);
			end
		else
			MobText:SetTextColor(1, 0.7, 0.7, 1);
		end
	-- 기본값
	else
		MobText:SetTextColor(1, 0.7, 0.7, 1);
	end
	MobButton:Enable();
	MobButton:Show();
end

-- 특정 Mob 을 선택했을 때
function NuguDropMobButton_OnClick(Mob)
	if (not NuguDropMobList) then return; end
	if (SelectedMob) then
		getglobal("NuguDropMob"..SelectedMob):UnlockHighlight();
		if (ND_Temp_Itemname) then
			i3 = #ND_Temp_Itemname;
			for n=1,i3 do
				getglobal("NuguDropItem"..n):Hide();
			end
		end
	end
	SelectedMob = Mob;
	getglobal("NuguDropMob"..Mob):LockHighlight();

	ND_MaxWidth = 0;
	local ZoneText = getglobal("NuguDropZone"..SelectedZone.."_Text"):GetText();
	local MobText = getglobal("NuguDropMob"..Mob.."_Text"):GetText();

	if string.find(MobText, "^도안(.+)$") then
		MobText = string.gsub(MobText, "^(.+)%((.+)%)$", "%1");
	end
	for ND_Itemname, ND_Iteminfo in pairs(ND_DB[NuguDropOption.SelectedTab]) do

		-- 재봉/가죽세공 분리
		if (NuguDropOption.SelectedTab == 1) and (ZoneText == "기타(아제로스)") then
			-- 도안(재봉)을 선택했으나 가죽세공 도안인 경우
			if (SelectedMob == 3) and (not ND_Iteminfo["Tailor"]) then
				ND_Itemname = "---";
			end
			-- 도안(가죽세공)을 선택했으나 재봉술 도안인 경우
			if (SelectedMob == 4) and ND_Iteminfo["Tailor"] then
				ND_Itemname = "---";
			end
		end

		if (NuguDropOption.SelectedTab == 2) and (ZoneText == "기타(아웃랜드)") then
			-- 아웃랜드 도안(재봉)을 선택했으나 가죽세공 도안인 경우
			if (SelectedMob == 3) and (not ND_Iteminfo["Tailor"]) then
				ND_Itemname = "---";
			end
			-- 아웃랜드 도안(가죽세공)을 선택했으나 재봉술 도안인 경우
			if (SelectedMob == 4) and ND_Iteminfo["Tailor"] then
				ND_Itemname = "---";
			end
		end

		if ((ND_Iteminfo[2] == ZoneText) and (ND_Iteminfo[3] == MobText)) then
			-- 한글은 3 나머지 영문/특수문자 1 이므로 숫자/영문(LENGTH 1)을 "한"(LENGTH 3)으로 임시대처함
--			local tlen_tmp = string.gsub(ND_Itemname, "%w", "한")
--NuguDrop_Print("ND_Itemname : "..ND_Itemname);
			local tlen_tmp2 = string.gsub(ND_Itemname, "%s", "한")
			local tlen = string.len(tlen_tmp2)/3;
			ND_MaxWidth = math.max(ND_MaxWidth, tlen);

		elseif ((NuguDropOption.SelectedTab == 1)
				or (NuguDropOption.SelectedTab == 2)
				or (NuguDropOption.SelectedTab == 3))
				and ((string.find( ND_Itemname, MobText..": " ))
				or (string.find( ND_Itemname, " "..MobText.."$" )))
			then
--NuguDrop_Print("ND_Itemname : "..ND_Itemname);
			local tlen_tmp2 = string.gsub(ND_Itemname, "%s", "한")
			local tlen = string.len(tlen_tmp2)/3;
			ND_MaxWidth = math.max(ND_MaxWidth, tlen);
		end
	end

--NuguDrop_Print("ItemND_MaxWidth : "..ND_MaxWidth);
	if (not NuguDropOption["ND_width"]) then
		NuguDropOption["ND_width"] = 100;
	end

	if ND_MaxWidth <= 6 then
		NuguDropListFrameItemList:SetWidth((ND_MaxWidth*15 + 13)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 + 13)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 아이템폭1 : "..ND_MaxWidth);
	elseif ND_MaxWidth <= 10 then
		NuguDropListFrameItemList:SetWidth((ND_MaxWidth*15 + 3)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 + 3)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 아이템폭2 : "..ND_MaxWidth);
	--elseif ND_MaxWidth <= 15 then
	else
		NuguDropListFrameItemList:SetWidth((ND_MaxWidth*15 - 6)*NuguDropOption["ND_width"]/100);
		ND_MaxWidth = (ND_MaxWidth*15 - 6)*NuguDropOption["ND_width"]/100;
--NuguDrop_Print("ND_MaxWidth 아이템폭3 : "..ND_MaxWidth);
	end

	if NuguDropListFrameItemList:IsVisible() then
		NuguDropListFrame_ItemList(SelectedMob, ND_MaxWidth);
	else
		NuguDropListFrameItemList:Show();
		NuguDropListFrame_ItemList(SelectedMob, ND_MaxWidth);
	end
end

-- Sorting
--function ND_ListSort()
--	table.sort(self._favbuildtable, function(a,b) return a.name<b.name end);
--end

-----------------------------------
-- link 에서 아이템ID 를 알아내는 함수
-----------------------------------
function ND_getIdFromLink(link)
	if not link then return end
	--  local _,_,id,name = strfind(link,"|Hitem:(%d+):.+%[(.+)%]")
	local _,_,id = strfind(link,"item:(%d+):")
	if id then return tonumber(id) end
end

--function ND_getNameFromLink(link)
--	return string.match(link, "^|%x+|H.+|h%[(.+)%]");
--end

-----------------------------------
-- Item을 출력하는 부분
-----------------------------------
function NuguDropListFrame_ItemList(SelectedMob, ND_MaxWidth)
	local ZoneText = getglobal("NuguDropZone"..SelectedZone.."_Text"):GetText();
	local MobText = getglobal("NuguDropMob"..SelectedMob.."_Text"):GetText();
	local cnt=0;				-- 선택한 몹이 드랍하는 아이템수
	ND_Temp_Itemname = {};		-- 선택몹의 드랍템 임시저장(다른몹 선택시 화면에 뿌려져 있는걸 지우기 위해서 필요)
	ND_Cache_ItemNums = {};		-- 선택한 몹의 아이템ID 임시저장
--		local texture = "Interface\\AddOns\\NuguDrop\\images\\NDFav_Highlight.tga";

	-- "도안(재봉)" / "도안(가죽세공)" 이름을 내부적으로 처리하기 위해 "도안"으로 변경
	if string.find(MobText, "^도안(.+)$") then
		MobText = string.gsub(MobText, "^(.+)%((.+)%)$", "%1");
	end

---- for 문 시작
	for ND_Itemname, ND_Iteminfo in pairs(ND_DB[NuguDropOption.SelectedTab]) do
		-- 재봉/가죽세공 분리
		if (NuguDropOption.SelectedTab == 1) and (ZoneText == "기타(아제로스)") then
			-- 도안(재봉)을 선택했으나 가죽세공 도안인 경우
			if (SelectedMob == 3) and (not ND_Iteminfo["Tailor"]) then
				ND_Itemname = "---";
			end
			-- 도안(가죽세공)을 선택했으나 재봉술 도안인 경우
			if (SelectedMob == 4) and ND_Iteminfo["Tailor"] then
				ND_Itemname = "---";
			end
		end

		if (NuguDropOption.SelectedTab == 2) and (ZoneText == "기타(아웃랜드)") then
			-- 아웃랜드 도안(재봉)을 선택했으나 가죽세공 도안인 경우
			if (SelectedMob == 3) and (not ND_Iteminfo["Tailor"]) then
				ND_Itemname = "---";
			end
			-- 아웃랜드 도안(가죽세공)을 선택했으나 재봉술 도안인 경우
			if (SelectedMob == 4) and ND_Iteminfo["Tailor"] then
				ND_Itemname = "---";
			end
		end

		-- NuguDrop 에서 해당존의 해당몹 체크하여.. [3] 부분만 추출
		if ((ND_Iteminfo[2] == ZoneText) and (ND_Iteminfo[3] == MobText))
			-- 제조법 정보를 보여주기 위한 조건문
			or (string.find( ND_Itemname, MobText..": " ))
			-- 성물(토템/성서/우상/인장) Filtering
			or ((NuguDropOption.SelectedTab == 1) and (string.find( ND_Itemname, " "..MobText.."$" )) and
				not (string.find( ND_Itemname, "모래약탈자" ) or	 -- 아제로스 제외템1
					 string.find( ND_Itemname, "맹독" ) or			-- 아제로스 제외템2
					 string.find( ND_Itemname, "껍질쐐기" ) or		-- 아제로스 제외템3
					 string.find( ND_Itemname, "학카리" )			-- 아제로스 제외템4
					)
				)
			or ((NuguDropOption.SelectedTab == 2) and (string.find( ND_Itemname, " "..MobText.."$" )) and
				not string.find( ND_Itemname, "죽은 자" ) -- 총독 말라다르 드랍 "죽은 자의 우상" 제외
				)
			or ((NuguDropOption.SelectedTab == 3) and (string.find( ND_Itemname, " "..MobText.."$" )) and
				not (string.find( ND_Itemname, "아라크나시드" ) or		-- 노스렌드 제외템1
					string.find( ND_Itemname, "키린 토의" ) or			-- 노스렌드 제외템2
					string.find( ND_Itemname, "악인의" ) or				-- 노스렌드 제외템3
					string.find( ND_Itemname, "외팔이 에드워드의" ) or	-- 노스렌드 제외템4
					string.find( ND_Itemname, "신전의" )				-- 노스렌드 제외템5
					)
			) then
			-- 갯수파악
			cnt = cnt + 1;

			----------------------------------------------------------------------
			--[[ 사전이 없거나 캐시정보를 참조하고자 할 경우 ]]
			if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
				-- 캐시로부터 생성한 데이터가 없을경우 생성
				if (not ND_Cache_ItemsAll) then
					NuguDrop_ItemDB_BuildItemsAll();
				end
				-- 캐시로부터 데이터를 갱신한지 3분이 지난경우 다시 아이템데이터 생성
				if (time() - NuguDrop_ItemDB_last_rebuild > 180) then
					NuguDrop_ItemDB_BuildItemsAll();
				end

				local id = ND_Iteminfo["id"] or ND_Iteminfo[9] or 99999
				if GetItemInfo(id) then
					local itemName, itemLink, itemRarity = GetItemInfo(id);
					if ( itemName ) then
						if (itemName == ND_Itemname) then
							-- 동일 이름 아이템의 경우 미리 기입한 ItemID 체크
							-- 9번 항목이 없으면 unique한 아이템이므로 이름비교만으로 저장
							if (not ND_Iteminfo[9]) then
								-- 해당 아이템의 ID 저장
								table.insert(ND_Cache_ItemNums, id);
								NuguDropCache_SWITCH = 1;
							-- 9번 항목이 존재하는 경우 9번항목(해당아이템의 고유 아이템ID)으로 비교
							elseif ND_Iteminfo[9] then
								local _, link2, itemRarity2 = GetItemInfo(ND_Iteminfo[9]);
								if itemLink == link2 then
									if (ND_getIdFromLink(itemLink) == ND_Iteminfo[9]) then
										table.insert(ND_Cache_ItemNums, id);
										NuguDropCache_SWITCH = 1;
									end
								else
									NuguDropCache_SWITCH = 2;
								end
							end
						-- 동일 아이템명을 가진 아이템의 경우 하나는 제일 뒤에 "@숫자"를 붙여서 표시했으므로 이것을 체크
						elseif string.find(ND_Itemname, itemName.."@") then
							if ND_Iteminfo[9] then
								local _, link2, itemRarity2 = GetItemInfo(ND_Iteminfo[9]);
								if itemLink == link2 then
									if (ND_getIdFromLink(itemLink) == ND_Iteminfo[9]) then
										table.insert(ND_Cache_ItemNums, id);
										NuguDropCache_SWITCH = 1;
									end
								end
							else
								NuguDropCache_SWITCH = 2;
							end
						else
							NuguDropCache_SWITCH = 2;
						end
					end
				else
					NuguDropCache_SWITCH = 2;
				end
				if NuguDropCache_SWITCH == 2 then
					-- 형식상 아무 아이템의 ID 저장 : 빈자리 채우기 >_< 1번 낡은 쇼트소드!!
					table.insert(ND_Cache_ItemNums, ND_Cache_ItemsAll[1]);
				end
			end
			----------------------------------------------------------------------
			-- 현재 선택한 몹의 드랍템리스트를 임시로 저장
			ND_Temp_Itemname[cnt] = ND_Itemname;

			-- 매칭된 갯수만큼 아이템버튼 보이기
			ItemButton = getglobal("NuguDropItem"..cnt);
			ItemText = getglobal("NuguDropItem"..cnt.."_Text");

			if (not ND_MaxWidth) or (ND_MaxWidth <= 30) then ND_MaxWidth = 200 end
			ItemButton:SetWidth(ND_MaxWidth-5);
----------------------------------------------------------------------
--[[ NuguDropListFrameItemList 에 표시하는 부분 ]]--
----------------------------------------------------------------------
			if (NuguDropOption.ND_whatref == 1) then
				-- 9번 항목이 존재하는 경우 아이템의 이름은 제일 뒤에 "@"를 빼고
				-- ItemID 를 해당 아이템의 9번 항목으로 지정, nil일 경우는 unique 아이템명
				if ND_Iteminfo[9] then
					itemID = ND_Iteminfo[9];
					ND_Itemname = string.gsub(ND_Itemname, "(.*)@(.*)", "%1");
				else
					itemID = ND_Iteminfo["id"] or nil;
				end

--		ItemButton:SetNormalTexture(texture);
				ItemText:SetText(ND_LinkFuction(dic_chk, ND_Itemname, itemID));
			end
			-- 5. 아이템사전이 없거나 캐시를 사용하고자 할 경우
			if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
				local id = ND_Iteminfo["id"] or ND_Iteminfo[9] or 99999
				if GetItemInfo(id) then
					local itemName, itemLink, itemRarity = GetItemInfo(id);
					if ( itemName ) then
						if (not ND_Iteminfo[9]) then
							if (itemName == ND_Itemname) then
								ItemText:SetText(itemLink);		-- 캐시 존재시 링크표시
								NuguDropCache_SWITCH = 1;
							else
								NuguDropCache_SWITCH = 2;
							end
						elseif ND_Iteminfo[9] then
							local _, link2, itemRarity2 = GetItemInfo(ND_Iteminfo[9]);
							if (itemName == ND_Itemname) then
								if itemLink == link2 then
									ItemText:SetText(link2);
									NuguDropCache_SWITCH = 1;
								else
									NuguDropCache_SWITCH = 2;
								end
							elseif string.find(ND_Itemname, itemName.."@") then
								if itemLink == link2 then
									ItemText:SetText(link2);
									NuguDropCache_SWITCH = 1;
								else
									NuguDropCache_SWITCH = 2;
								end
							else
								NuguDropCache_SWITCH = 2;
							end
						end
					end
				else
					NuguDropCache_SWITCH = 2;
				end
				if NuguDropCache_SWITCH == 2 then
--		ItemButton:SetNormalTexture(texture);
					ItemText:SetText(ND_Itemname);			-- 캐시에 존재하지 않을시 텍스트만 표시
				end
			end

		ItemButton:Enable();
--		ItemButton:SetBackdropColor(1, 1, 0, 1);
		ItemButton:Show();
		end
	end
-- for 문 끝

---------------------------------
-- 참고한 아이템사전 출력문구 --
---------------------------------
	if (ND_Temp_Itemname) then
		local dictext = "|cffffdfab참고한 아이템사전 : |r";
		if (NuguDropOption.ND_whatref == 1) then
			if (ND_SpamCheck > 0) then
				-- 0. 최신버전 아이템싱크(ItemSync r25808 이상)
				if dic_chk == 0 then
					local ISyncVer = ISyncDB["account"]["dboptions"]["version"][1];
					NuguDrop_Print(dictext.."ItemSync 버전 : "..ISyncVer);

				-- 2. Saeris's LootLink
				elseif dic_chk == 2 then
					NuguDrop_Print(dictext.."Saeris's LootLink v"..LootLink.VERSION);

				-- 3. LootLink (하늘아리)
				elseif dic_chk == 3 then
					NuguDrop_Print(dictext.."LootLink (하늘아리)");

				-- 4. KC_Items와 LinkView모듈이 활성화 된경우
				elseif dic_chk == 4 then
					NuguDrop_Print(dictext.."KC_Items");
				end
			end
			ND_SpamCheck = ND_SpamCheck  - 1;
		end
		if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
			if (ND_SpamCheck > 0) then
				NuguDrop_Print(dictext.."와우캐시로부터 생성");
				ND_SpamCheck = ND_SpamCheck - 1;
			end
		end
	end
	NuguDropListFrameItemList:SetHeight(18 + (18*cnt));
end


-----------------------------------------
-- 아이템 갯수 출력 함수
-----------------------------------------
function NuguDrop_CountItemDB()
	NuguDrop_Print("|cffff0000━━━━━━━━━━━━━━|r");
	local sum = 0;
	for i=1, #ND_DB do
		local n = 0;
		for k, v in pairs(ND_DB[i]) do
			n = n + 1;
		end
		if not n then n = 0; end
		NuguDrop_Print(ND_DBName[i].." 아이템 수 : |CFFFFFF66"..n.."|r");
		sum = sum + n;
	end
	NuguDrop_Print("|cff1eff00<총 아이템 수>|r : |cffff8077"..sum.."|r");
	NuguDrop_Print("|cffff0000━━━━━━━━━━━━━━|r");
end


-----------------------------------------
-- Item 클릭시 각종 반응
-----------------------------------------
function NuguDropItemButton_OnClick(arg1, SelectedItemIdx)
	ND_Itemname = ND_Temp_Itemname[SelectedItemIdx];
	if ND_DB[NuguDropOption.SelectedTab][ND_Itemname][9] then
		itemID = ND_DB[NuguDropOption.SelectedTab][ND_Itemname][9];
		ND_Itemname = string.gsub(ND_Itemname, "(.*)@(.*)", "%1");
	else
		itemID = ND_DB[NuguDropOption.SelectedTab][ND_Itemname]["id"] or nil;
	end
-----------------------------------------
-- 1. Item을 우 Click시 즐겨찾기 추가
-----------------------------------------
	if arg1=="RightButton" then
		ND_Favorites_ShowMenu(ND_Itemname, itemID);

	elseif arg1=="LeftButton" then
-----------------------------------------
-- 2. Item을 Shift + Click시 채팅창으로 링크
-----------------------------------------
		if ( IsShiftKeyDown() ) then
			ChatFrameEditBox:Show();
			-- 아이템 정보 링크를 입력창에 넣어준다.
			if (NuguDropOption.ND_whatref == 1) then
				local link = ND_LinkFuction(dic_chk, ND_Itemname, itemID);
				if link then
					if( string.find(link, "%d+:%d+:%d+:") ) then
						local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]");
						local itemID = ND_getIdFromLink(link);
						local itemName, link, itemRarity = GetItemInfo(tonumber(itemID));
						-- 랜덤 접두어 정보를 가진 아이템의 경우
						if NDKnownSuffix[itemID] then
							if NDKnownSuffix[itemID]["name"] == ND_Itemname then
								for suffixID, v in pairs(NDKnownSuffix[itemID]) do
									if (type(suffixID) == "number") then
										local suffixID = tonumber(suffixID);
										local uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
										local suffixName = NDKnownSuffix[itemID][suffixID][1];
										local itemString = "item:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0)
										link = "|"..Rarity   .."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..suffixName.." "..ND_Itemname.."]|h|r"
										ChatFrameEditBox:Insert(link);
									end
								end
							end
						else
							ChatFrameEditBox:Insert(link);
						end
					end
				else
--					NuguDrop_Print("현재 사전정보가 잘못되어 있습니다.");
--					NuguDrop_Print("|cff00ff00/누구드랍 캐시|r 명령어를 실행하여 주세요.");
					NuguDropOption.ND_whatref = 0;
				end
			end
			if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
				local itemName, link, itemRarity = GetItemInfo(ND_Cache_ItemNums[SelectedItemIdx]);
				if ( itemName ) then
					if (itemName == ND_Itemname) or string.find(ND_Itemname, itemName.."@") then
						local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]");
						local itemID = ND_Cache_ItemNums[SelectedItemIdx];
						-- 랜덤 접두어 정보를 가진 아이템의 경우
						if NDKnownSuffix[itemID] then
							if NDKnownSuffix[itemID]["name"] == itemName then
								--local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
								for suffixID, v in pairs(NDKnownSuffix[itemID]) do
									if (type(suffixID) == "number") then
										local suffixID = tonumber(suffixID);
										local uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
										local suffixName = NDKnownSuffix[itemID][suffixID][1];
										link = "|"..Rarity.."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..suffixName.." "..itemName.."]|h|r"
										ChatFrameEditBox:Insert(link);
									end
								end
							end
						else
							ChatFrameEditBox:Insert(link);
						end
					end
				end
			end
-----------------------------------------
-- 3. Item을 Control + Click시 미리 입어보기
-----------------------------------------
		elseif ( IsControlKeyDown() ) then
			if (NuguDropOption.ND_whatref == 1) then
				DressUpItemLink(ND_LinkFuction(dic_chk, ND_Itemname, itemID));

--				ShowUIPanel(AuctionDressUpFrame);
--				AuctionDressUpModel:SetUnit("player");
--				AuctionDressUpModel:TryOn(link);

--				ShowUIPanel(NDDressFrame);
--				NuguDropModel:ClearModel();
--				NuguDropModel:SetUnit(unit);
			end
			if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
				local itemName, itemLink, itemRarity = GetItemInfo(ND_Cache_ItemNums[SelectedItemIdx]);
				if ( itemName ) then
					if (itemName == ND_Itemname) or string.find(ND_Itemname, itemName.."@") then
						DressUpItemLink(itemLink);

--						ShowUIPanel(NDDressFrame);
--						NuguDropModel:ClearModel();
--						NuguDropModel:SetUnit("player");
--						NuguDropModel:TryOn(itemLink);
					end
				end
			end
		else
-----------------------------------------
-- 4. Item을 그냥 좌 Click시 링크창 생성
-----------------------------------------
		-- 기본 단일 툴팁 : SetItemRef(link, text, button);
		-- 툴팁 강화 애드온이 처리하도록 변경(LinkHeaven, WTT_IRTS, Links)

			local _, ilink = GameTooltip:GetItem();
			-- 현재 툴팁에 링크가 존재하면 그냥처리
			if ilink then
				if (NuguDropOption.ND_whatref == 1) then
					local link = ND_LinkFuction(dic_chk, ND_Itemname, itemID);
					if link then
						if( string.find(link, "%d+:%d+:%d+:") ) then
							local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]");
							local itemID = ND_getIdFromLink(link);
							-- 랜덤 접두어 정보를 가진 아이템의 경우
							if NDKnownSuffix[itemID] then
								if NDKnownSuffix[itemID]["name"] == ND_Itemname then
									for suffixID, v in pairs(NDKnownSuffix[itemID]) do
										if (type(suffixID) == "number") then
											local suffixID = tonumber(suffixID);
											local uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
											local itemString = "item:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0)
											link = "|"..Rarity   .."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..ND_Itemname.."]|h|r"
											ChatFrame_OnHyperlinkShow(self, itemString, link);
										end
									end
								end
							else
								ChatFrame_OnHyperlinkShow(self, itemString, link);
							end
						end
					else
--						NuguDrop_Print("현재 사전정보가 잘못되어 있습니다.");
--						NuguDrop_Print("|cff00ff00/누구드랍 캐시|r 명령어를 실행하여 주세요.");
						NuguDropOption.ND_whatref = 0;
					end
				end
				if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
					local itemName, link, itemRarity = GetItemInfo(ND_Cache_ItemNums[SelectedItemIdx]);
					if ( itemName ) then
						if (itemName == ND_Itemname) or (itemName.."@" == ND_Itemname) then
							local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]");
							local itemID = ND_Cache_ItemNums[SelectedItemIdx];
							-- 랜덤 접두어 정보를 가진 아이템의 경우
							if NDKnownSuffix[itemID] then
								if NDKnownSuffix[itemID]["name"] == itemName then
									--local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
									for suffixID, v in pairs(NDKnownSuffix[itemID]) do
										if (type(suffixID) == "number") then
											local suffixID = tonumber(suffixID);
											local uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
											local itemString = "item:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0)
											link = "|"..Rarity   .."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..itemName.."]|h|r"
											ChatFrame_OnHyperlinkShow(self, itemString, link);
										end
									end
								end
							else
								ChatFrame_OnHyperlinkShow(self, itemString, link);
							end
						end
					end
				end
			-- 존재하지 않는 경우 서버질의 시도
			else
-----------------------------------------
-- 5. 캐시에 없는 Item을 좌 Click시 서버질의
-----------------------------------------
				-- 데이터에 ItemID 가 있는 경우만 시도한다..
				if itemID then
					GameTooltip:SetHyperlink("item:"..tonumber(itemID)..":0:0:0:0:0:0:0");
					GameTooltip:Show();
					GameTooltip:Hide();
					--table.remove(ND_Cache_ItemNums, SelectedItemIdx);
					--table.insert(ND_Cache_ItemNums, tonumber(SelectedItemIdx), tonumber(itemID));
					--table.insert(ND_Cache_ItemsAll, tonumber(itemID));

					NuguDrop_ItemDB_BuildItemsAll(1);

					local itemName, link, itemRarity = GetItemInfo(tonumber(itemID));

					local ItemButton = getglobal("NuguDropItem"..SelectedItemIdx);
					local ItemText = getglobal("NuguDropItem"..SelectedItemIdx.."_Text");

					if link then
						if (NuguDropOption.ND_whatref == 1) then

							-- 확장팩용 아이템싱크(ItemSync r25808 이상)
							if (dic_chk == 0) then
								local _, _, is_color, itemString, is_name = string.find(link, "^|c(%x+)|Hitem:(.+)|h%[(.+)%]")
								ItemSync:_parselinks(itemString, is_color, is_name);

								NuguDropMobButton_OnClick(SelectedMob);
								NuguDropItemButton_OnEnter(SelectedItemIdx);
								ItemText:SetText(link);
								NuguDropMobButton_OnClick(SelectedMob);
								NuguDropItemButton_OnEnter(SelectedItemIdx);

							-- Saeris's LootLink 인 경우
							elseif (dic_chk == 2) then
								local linksTable = LootLink:Main_GetReusableTable(1);
								table.insert(linksTable, link);
								LootLink:Parsing_ParseFromTable(linksTable);
								LootLink:ItemTables_Populate(tonumber(itemID));

							-- LootLink(하늘아리) 인 경우
							elseif (dic_chk == 3) then
								name = LootLink_ProcessLinks(link, true);
								if( name and ItemLinks[name] ) then
									link = ND_LinkFuction(dic_chk, ND_Itemname, itemID);
								end
							end
						end
						ItemText:SetText(link);
					end

					NuguDropMobButton_OnClick(SelectedMob);
					NuguDropItemButton_OnEnter(SelectedItemIdx);

					if not link then
						ItemText:SetText("|cffff0000"..ND_Itemname.."|r-|cffffff00서버조회|r");
					end
				end
			end
		end
	end
end

-----------------------------------------
-- Item에 MouseOver 했을 때 ToolTip 표시
-----------------------------------------
function NuguDropItemButton_OnEnter(SelectedItemIdx)

	ND_Itemname = ND_Temp_Itemname[SelectedItemIdx];
	ND_Itemname_fix = ND_Itemname

	if ND_DB[NuguDropOption.SelectedTab][ND_Itemname][9] then
		itemID = ND_DB[NuguDropOption.SelectedTab][ND_Itemname][9];
		ND_Itemname = string.gsub(ND_Itemname, "(.*)@(.*)", "%1");
	else
		itemID = ND_DB[NuguDropOption.SelectedTab][ND_Itemname]["id"] or nil;
	end

	if (NuguDropOption.ND_whatref == 1) then
		local link = ND_LinkFuction(dic_chk, ND_Itemname, itemID);
		if link then
			if( string.find(link, "%d+:%d+:%d+:") ) then
				-- 동일 아이템명이 존재하는 경우 처리
				if itemID then
					if NDKnownSuffix[itemID] then
						if NDKnownSuffix[itemID]["name"] == ND_Itemname then
							local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
							-- 2개 이상의 아이템이 존재할 경우 링크창을 하단부에 여러개 보여주기 위해 counter 값을 넘긴다.
							local counter = 0;
							for suffixID, v in pairs(NDKnownSuffix[itemID]) do
								if (type(suffixID) == "number") then
									suffixID = tonumber(suffixID);
									uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
									counter = counter + 1;
									link = "|"..Rarity   .."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..ND_Itemname.."]|h|r"
									NuguDrop_ShowToolTip(link, SelectedItemIdx, counter);
								end
							end
						end
					else
						NuguDrop_ShowToolTip(link, SelectedItemIdx);
					end
				-- 랜덤 접두어 "~의" 아이템 처리
				else
					local itemID2 = ND_getIdFromLink(link);
					if NDKnownSuffix[itemID2] then
						if NDKnownSuffix[itemID2]["name"] == ND_Itemname then
							local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
							local counter = 0;
							for suffixID, v in pairs(NDKnownSuffix[itemID2]) do
								if (type(suffixID) == "number") then
									suffixID = tonumber(suffixID);
									uniqueID = tonumber(NDKnownSuffix[itemID2][suffixID][2] or 0)
									counter = counter + 1;
									link = "|"..Rarity   .."|Hitem:"..itemID2..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..ND_Itemname.."]|h|r"
									NuguDrop_ShowToolTip(link, SelectedItemIdx, counter);
								end
							end
						end
					else
						NuguDrop_ShowToolTip(link, SelectedItemIdx);
					end
				end
			else
				NuguDrop_FakeToolTip(ND_Itemname_fix,SelectedItemIdx);
			end
		else
			NuguDrop_Print("현재 사전정보가 잘못되어 있습니다.");
			NuguDrop_Print("|cff00ff00/누구드랍 캐시|r 명령어를 실행하여 주세요.");
		end
	end

	-- 5. 아이템사전이 없거나 캐시정보를 참조하고자 할 경우
	if (NuguDropOption.ND_whatref == 0) or (dic_chk == 5) then
		local itemName, link, itemRarity = GetItemInfo(ND_Cache_ItemNums[SelectedItemIdx]);
		if ( itemName ) then
			if (itemName == ND_Itemname) or string.find(ND_Itemname, itemName.."@") then
				-- 동일 아이템명이 존재하는 경우 처리
				if itemID then
					local _, link2, itemRarity2 = GetItemInfo(itemID);
					if link == link2 then
						-- 여기서 랜덤 접두어 "~의" 아이템 처리
						if NDKnownSuffix[itemID] then
							if NDKnownSuffix[itemID]["name"] == itemName then
								local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
								local counter = 0;
								for suffixID, v in pairs(NDKnownSuffix[itemID]) do
									if (type(suffixID) == "number") then
										suffixID = tonumber(suffixID);
										uniqueID = tonumber(NDKnownSuffix[itemID][suffixID][2] or 0)
										counter = counter + 1;
										link = "|"..Rarity   .."|Hitem:"..itemID..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..itemName.."]|h|r"
										NuguDrop_ShowToolTip(link, SelectedItemIdx, counter);
									end
								end
							end
						else
							NuguDrop_ShowToolTip(link, SelectedItemIdx);
						end
					else
						NuguDrop_FakeToolTip(ND_Itemname_fix,SelectedItemIdx);
					end
				-- 랜덤 접두어 "~의" 아이템 처리
				else
					local itemID2 = ND_Cache_ItemNums[SelectedItemIdx];
					if NDKnownSuffix[itemID2] then
						if NDKnownSuffix[itemID2]["name"] == itemName then
							local _, _, Rarity, itemString = string.find(link, "^|(%x+)|H(.+)|h%[.+%]")
							-- 2개 이상의 아이템이 존재할 경우 링크창을 하단부에 여러개 보여주기 위해 counter 값을 넘긴다.
							local counter = 0;
							for suffixID, v in pairs(NDKnownSuffix[itemID2]) do
								if (type(suffixID) == "number") then
									suffixID = tonumber(suffixID);
									uniqueID = tonumber(NDKnownSuffix[itemID2][suffixID][2] or 0)
									counter = counter + 1;
									link = "|"..Rarity   .."|Hitem:"..itemID2..":0:0:0:0:0:"..suffixID..":"..(uniqueID or 0).."|h["..itemName.."]|h|r"
									NuguDrop_ShowToolTip(link, SelectedItemIdx, counter);
								end
							end
						end
					else
						NuguDrop_ShowToolTip(link, SelectedItemIdx);
					end
				end
			else
			-- 해당링크가 캐시에 없을때 가상툴팁을 보여준다
				NuguDrop_FakeToolTip(ND_Itemname_fix,SelectedItemIdx);
			end
		end
	end
end

-----------------------------
-- 가상 ToolTip
-----------------------------
function NuguDrop_FakeToolTip(item,SelectedItemIdx)
	local item = tostring(item);

	if ( (string.find(item, "<아직 모름>")) or
		(string.find(item, "<일반과 동일")) ) then
		return;
	end

	NuguDropTooltipIconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
	NuguDropTooltipIcon:ClearAllPoints();
	NuguDropTooltipIcon:SetPoint("BOTTOMLEFT", getglobal("NuguDropItem"..SelectedItemIdx), "TOPRIGHT", 0, 6);
	NuguDropTooltipIcon:Show();
	GameTooltip:SetOwner(NuguDropTooltipIcon, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", NuguDropTooltipIcon, "BOTTOMLEFT", -2, 3);
	GameTooltip:AddLine(ND_UKNOWN_TITLE, 1, 0, 0);
	--GameTooltip:AddLine(item.."\n\n", 1, 1, 1);
	GameTooltip:AddLine(ND_UKNOWN_DESC, NuguDropColor.r, NuguDropColor.g, NuguDropColor.b);

	-- 데이터에 ItemID 가 있는 경우만 경고문구 표시
	if ND_DB[NuguDropOption.SelectedTab][item][9] or ND_DB[NuguDropOption.SelectedTab][item]["id"] then
		GameTooltip:AddLine(ND_UKNOWN_WARN);
		local iid = ND_DB[NuguDropOption.SelectedTab][item][9] or ND_DB[NuguDropOption.SelectedTab][item]["id"]
		GameTooltip:AddLine("ItemID "..iid);
	end
	if NuguDrop[item] then
		GameTooltip:AddLine(NuguDrop_GetComment(NuguDrop[item],1));
	elseif ND_DB[NuguDropOption.SelectedTab][item] then
		GameTooltip:AddLine(NuguDrop_GetComment(ND_DB[NuguDropOption.SelectedTab][item],1));
	end
	if NuguDropCustom[item] then
		GameTooltip:AddLine(NuguDrop_GetComment(NuguDropCustom[item],1));
	end
	if NuguDropCustom[item] then
		GameTooltip:AddLine(NuguDrop_GetComment(NuguDropCustom[item],4));
	end
	GameTooltip:Show();
end

-----------------------------
-- Item 위에서 마우스 치웠을 때
-----------------------------
function NuguDropItemButton_OnLeave()
	if NuguDropGameTooltip4:IsVisible() then NuguDropGameTooltip4:Hide(); end
	if NuguDropGameTooltip3:IsVisible() then NuguDropGameTooltip3:Hide(); end
	if NuguDropGameTooltip2:IsVisible() then NuguDropGameTooltip2:Hide(); end
	GameTooltip:Hide();
	NuguDropTooltipIcon:Hide();
end

-----------------------------------------
-- ToolTip 표시함수
-----------------------------------------
function NuguDrop_ShowToolTip(link, SelectedItemIdx, counter)

	-- 0. 최신버전 아이템싱크(ItemSync r25808 이상) 일 경우 설정값 조사해서 아이콘 표시여부 결정
	-- 아이템싱크 - 설정 - 위에서 3번째 - "아이템의 텍스쳐를 툴팁에 표시합니다." 체크시
	-- (xml/Option.xml) --> ItemSync:Click_Opt("SHOWMONEY",3,this:GetChecked());
	-- 체크시(xml/Option.lua) --> self.db.account[self.realm]["options"]["showmoney"][3] = 1;

	if (ISyncDB) then
		-- 서버에 관계없이 동일한 데이터베이스를 사용할 경우(체크한 경우)
		if (ISyncDB["account"]["dboptions"]["sameserv"][1] == 1) then
			ND_ISyncToolTipIconShow = ISyncDB["account"][1]["options"]["showmoney"][3];
		-- 서버마다 다른 데이터베이스를 사용할 경우(체크해제한 경우)
		else
			local server_realm = GetRealmName():trim();
			--NuguDrop_Print("server_realm : "..server_realm);
			ND_ISyncToolTipIconShow = ISyncDB["account"][server_realm]["options"]["showmoney"][3];
		end

		-- 아이템싱크 설정값이 0인 경우 "누구드랍"으로 아이콘 표시
		if (ND_ISyncToolTipIconShow == 0) then
			NuguDrop_AddTooltipTexture(SelectedItemIdx, link);
		else -- 누구드랍 아이콘은 표시하지 않고 "아이템싱크"가 표시하도록 한다.
			NuguDropTooltipIcon:ClearAllPoints();
			NuguDropTooltipIcon:SetPoint("BOTTOMLEFT", getglobal("NuguDropItem"..SelectedItemIdx), "TOPRIGHT", 0, 6);
		end
	else
		NuguDrop_AddTooltipTexture(SelectedItemIdx, link);
	end

	-- 랜덤 접두어 아이템이 2개 이상일 때
	if (not counter) or (counter == 1) then
		GameTooltip:SetOwner(NuguDropTooltipIcon, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", NuguDropTooltipIcon, "BOTTOMLEFT", -2, 3);
		GameTooltip:SetHyperlink(link);
		GameTooltip:Show();
	elseif (counter == 2) then
		NuguDropGameTooltip2:SetOwner(this, "ANCHOR_NONE");
		NuguDropGameTooltip2:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 0, 3);
		NuguDropGameTooltip2:SetHyperlink(link);
		NuguDropGameTooltip2:Show();
	elseif (counter == 3) then
		NuguDropGameTooltip3:SetOwner(this, "ANCHOR_NONE");
		NuguDropGameTooltip3:SetPoint("TOPLEFT", NuguDropGameTooltip2, "BOTTOMLEFT", 0, 3);
		NuguDropGameTooltip3:SetHyperlink(link);
		NuguDropGameTooltip3:Show();
	elseif (counter == 4) then
		NuguDropGameTooltip4:SetOwner(this, "ANCHOR_NONE");
		NuguDropGameTooltip4:SetPoint("TOPLEFT", NuguDropGameTooltip3, "BOTTOMLEFT", 0, 3);
		NuguDropGameTooltip4:SetHyperlink(link);
		NuguDropGameTooltip4:Show();
	end
end

-----------------------------
-- ToolTip에 Item Icon 표시
-----------------------------
function NuguDrop_AddTooltipTexture(SelectedItemIdx, link)
	if ( link ) then
		local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(link);
		if ( itemTexture ) then
			NuguDropTooltipIconTexture:SetTexture( itemTexture );
			NuguDropTooltipIcon:ClearAllPoints();
			NuguDropTooltipIcon:SetPoint("BOTTOMLEFT", getglobal("NuguDropItem"..SelectedItemIdx), "TOPRIGHT", 0, 6);
			NuguDropTooltipIcon:Show();
			return;
		end
	end
end

-----------------------------
-- 아이템사전이 없을경우 캐시데이터로 아이템리스트 생성하는 함수
-----------------------------
function NuguDrop_ItemDB_BuildItemsAll(c)

	if not c then
		NuguDrop_Print("아이템리스트 생성시작");
	end
	NuguDrop_ItemDB_last_rebuild = time();
	ND_Cache_ItemsAll = {};

	for i = 1, 50000 do
		local itemName, itemLink, itemRarity = GetItemInfo(i);
		-- 유효아이템인가 체크
		if ( itemName ) then
			table.insert(ND_Cache_ItemsAll, i);
		end
	end
	if ( DEFAULT_CHAT_FRAME and not c) then
--		NuguDrop_Print("아이템리스트 생성완료 - 캐시로부터 "..table.getn(ND_Cache_ItemsAll).." 개의 아이템 발견");
		NuguDrop_Print("아이템리스트 생성완료 - 캐시로부터 "..#ND_Cache_ItemsAll.." 개의 아이템 발견");
	end
end

--#######################################################
--////////// 각 아이템 사전별 Link 생성 함수 ///////////
--#######################################################
-----------------------------
-- 1. 확장팩 ItemSync용 함수
-----------------------------
function ND_ItemSync_GetTextLink(text, itemID)
	-- 서버에 관계없이 동일한 데이터베이스를 사용할 경우(체크한 경우)
	if (ISyncDB["account"]["dboptions"]["sameserv"][1] == 1) then
		for k, v in pairs(ISyncDB["account"][1]["names"]) do
			if (strfind(v, text)) then
				local name_X, link_X, quality_X, itemLevel_X, minLevel_X, class_X, subclass_X, maxStack_X, equipType_X, iconTexture_X  = GetItemInfo("item:"..k..":0:0:0:0:0:0:0");

				if itemID then
					if(name_X and link_X) and (itemID == k) then
						return link_X;
					end
				else
					if(name_X and link_X) then
						return link_X;
					end
				end
			end
		end
	else	-- 서버마다 다른 데이터베이스를 사용할 경우(체크해제한 경우)
		local server_realm = GetRealmName():trim();
		for k, v in pairs(ISyncDB["account"][server_realm]["names"]) do
			if (strfind(v, text)) then
				local name_X, link_X, quality_X, itemLevel_X, minLevel_X, class_X, subclass_X, maxStack_X, equipType_X, iconTexture_X  = GetItemInfo("item:"..k..":0:0:0:0:0:0:0");

				if itemID then
					if(name_X and link_X) and (itemID == k) then
						return link_X;
					end
				else
					if(name_X and link_X) then
						return link_X;
					end
				end
			end
		end
	end
	return text;
end

-----------------------------
-- 2. Saeris's LootLink용 함수
-- 아래와 동일(알아서 컨버팅 해준다 -0-), 단 몇가지 주의 +_+
-----------------------------
--function ND_LootLink_Matching_GetItemTableAndSuffixIDByName(tableToSearch, itemName)
--end
-----------------------------
-- 3. LootLink용 함수 (하늘아리)
-- 제작자가 모든 함수를 다 local 로 정의하는 바람에 다시 사용할 수 없기에 재정의함. >_<ㅋ
-----------------------------

-- 서버에 존재하는지 여부를 판단하는 함수는 LootLink에서 하므로 중복부분 주석처리/일시제거
	--
	--function ND_LootLink_GetDataVersion()
	--	if( not LootLinkState or not LootLinkState.DataVersion ) then
	--		return 0;
	--	end
	--	return LootLinkState.DataVersion;
	--end
	--
	--
	--function ND_LootLink_CheckItemServerRaw(item, serverIndex)
	--	if( not item.s ) then
	--		return nil;
	--	end
	--
	--	local server;
	--	for server in string.gmatch(item.s, "(%d+)") do
	--		if( tonumber(server) == serverIndex ) then
	--			return 1;
	--		end
	--	end
	--
	--	return nil;
	--end

	---- Use this function to check whether an ItemLinks[name] entry is valid for a given server index
	--function ND_LootLink_CheckItemServer(item, serverIndex)
	--	-- If we haven't converted and this item predates multiple server support, count it as valid
	--	if( ND_LootLink_GetDataVersion() < 110 and not item._ ) then
	--		return 1;
	--	end
	--	return ND_LootLink_CheckItemServerRaw(item, serverIndex);
	--end

function ND_LootLink_GetHyperlink(name, itemID)

	-- 2. Saeris's LootLink
	if (dic_chk == 2) and (itemID) then
		if LootLink_Database[itemID] then
			return "item:"..itemID..":0:0:0:0:0";
		else
			return nil
		end
	end

	-- 3. LootLink (하늘아리)
	local itemLink = ItemLinks[name];
	--  서버체크 제거
	--	if( itemLink and itemLink.i and ND_LootLink_CheckItemServer(itemLink, lServerIndex) ) then
	if( itemLink and itemLink.i ) then
		local item;
		if( string.find(itemLink.i, "^%d+:%d+:%d+:%d+$") ) then
			-- Upgrade old links, removing instance-specific data
			item = string.gsub(itemLink.i, "^(%d+):(%d+):(%d+):(%d+)$", "%1:0:0:0:0:0:%3:%4");
		else
			-- Remove instance-specific data that we captured from the link we return (2nd is enchantment, 3rd-5th are sockets)
			item = string.gsub(itemLink.i, "(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+):(%-?%d+)", "%1:0:0:0:0:%6:%7:%8");
		end
		--NuguDrop_Print("item : "..item);
		if itemID then
			if string.find(item, itemID) then
				return "item:"..item;
			else
				return nil;
			end
		else
			return "item:"..item;
		end
	end
	return nil;
end


function ND_LootLink_GetLink(name, itemID)
	local itemLink = ItemLinks[name];
	--  서버체크 제거
	--	if( itemLink and itemLink.c and itemLink.i and ND_LootLink_CheckItemServer(itemLink, lServerIndex) ) then
	if( itemLink and itemLink.c and itemLink.i ) then
		if ND_LootLink_GetHyperlink(name, itemID) then
			local link;
			if (dic_chk == 2) and (itemID) then
				local colorindex = tonumber(LootLink_Database[itemID][2]);
				link = ITEM_QUALITY_COLORS[colorindex].hex.."|H"..ND_LootLink_GetHyperlink(name, itemID).."|h["..name.."]|h|r";
			else
				link = "|c"..itemLink.c.."|H"..ND_LootLink_GetHyperlink(name, itemID).."|h["..name.."]|h|r";
			end
			return link;
		end
	end
	return name;
end

-----------------------------------------
-- 4. KC_Items 사용의 경우, 해당 Item에 대한 Link 반환함수 (By Creep7)
-----------------------------------------
function NuguDropGetKC_ItemsLink(ItemName, itemID)
	local KC_FIX_NAME, KC_FIX_LINK, KC_FIX_ID, KC_FIX_SWITCH = nil;
	for KC_FIX_ID in pairs(KC_ItemsDB) do
		KC_FIX_NAME = GetItemInfo(KC_FIX_ID)
		if ItemName == KC_FIX_NAME then
			if (not itemID) then
				KC_FIX_NAME, KC_FIX_LINK, KC_FIX_QUALITY = GetItemInfo(KC_FIX_ID);
				_,_,_,KC_FIX_COLOR = GetItemQualityColor(KC_FIX_QUALITY);
				KC_FIX_ITEMLINK = string.format("%s|h%s|r",KC_FIX_COLOR, KC_FIX_LINK);
				KC_FIX_SWITCH = 1;
				break;
			elseif itemID then
				KC_FIX_NAME, KC_FIX_LINK, KC_FIX_QUALITY = GetItemInfo(KC_FIX_ID);
				if ND_getIdFromLink(KC_FIX_LINK) == itemID then
					_,_,_,KC_FIX_COLOR = GetItemQualityColor(KC_FIX_QUALITY);
					KC_FIX_ITEMLINK = string.format("%s|h%s|r",KC_FIX_COLOR, KC_FIX_LINK);
					KC_FIX_SWITCH = 1;
					break;
				else
					KC_FIX_ITEMLINK = ItemName;
					KC_FIX_SWITCH = 2;
				end
			end
		else
			KC_FIX_ITEMLINK = ItemName;
			KC_FIX_SWITCH = 2;
		end
	end
	return KC_FIX_ITEMLINK;
end

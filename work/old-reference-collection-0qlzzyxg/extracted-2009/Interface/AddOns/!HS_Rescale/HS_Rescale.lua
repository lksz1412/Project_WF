local FailedAddOnLoad = {};

function UIParentLoadAddOn_Fix(name)
	local loaded, reason = LoadAddOn(name);
	if ( not loaded ) then
		if not reason then
			print(name.." 로딩 대기중입니다...")
		else
			if ( not FailedAddOnLoad[name] ) then
				print(name.." - "..tostring(loaded).." : "..tostring(reason))
				--message(format(ADDON_LOAD_FAILED, name, _G["ADDON_"..reason]));
				FailedAddOnLoad[name] = true;
			end
		end
	end
	return loaded;
end
UIParentLoadAddOn = UIParentLoadAddOn_Fix

function HSRescale_OnLoad()

	-- 깔끔하게 저장값을 테이블로 묶어버릴 수도 있겠으나, 추후 수정이 용이하게끔 개별적으로 분리하여 놔두는 것이 좋겠다. WTF 파일 삭제하지 않아도 되는 편리함.

	if (not HSRescaleSV_frame) then
		HSRescaleSV_frame = 1;
	end

	if (not HSRescaleSV_map) then
		HSRescaleSV_map = 1;
	end

	if (not HSRescaleSV_raid) then
		HSRescaleSV_raid = 1;
	end

	if (not HSRescaleSV_tip) then
		HSRescaleSV_tip = 1;
	end

	if (not HSRescaleSV_system) then
		HSRescaleSV_system = 1;
	end

	SlashCmdList["HsRescale"] = function(msg)
		HsRescale_SlashCommand(msg);
	end
	SLASH_HsRescale1 = "/hsr";
	SLASH_HsRescale2 = "/크기";
	SLASH_HsRescale3 = "/scale";

	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("ADDON_LOADED");

end


function HSRescale_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		HsRescale_frame(HSRescaleSV_frame);
		HsRescale_tip(HSRescaleSV_tip)
		HsRescale_system(HSRescaleSV_system);
		--[[
		if (not IsAddOnLoaded("Capping")) then
			HsRescale_map(HSRescaleSV_map);
		end
		]]
	end

	if (event == "ADDON_LOADED") then
		if(arg1 == "Blizzard_TalentUI") then
			if (not IsAddOnLoaded("FrameResized_TalentUI")) then
				PlayerTalentFrame:SetScale(HSRescaleSV_frame);	--특성창
			end
		end
		if(arg1 == "Blizzard_MacroUI") then
			MacroFrame:SetScale(HSRescaleSV_frame);		--매크로창
		end
		if(arg1 == "Blizzard_TradeSkillUI") then
			TradeSkillFrame:SetScale(HSRescaleSV_frame);	--전문기술창 관련일체
		end
		if(arg1 == "Blizzard_TrainerUI") then
			ClassTrainerFrame:SetScale(HSRescaleSV_frame);	--전문기술 npc 창
		end
		if(arg1 == "Blizzard_AuctionUI") then
			AuctionFrame:SetScale(HSRescaleSV_frame);		--경매창
			AuctionDressUpFrame:SetScale(HSRescaleSV_frame);	--경매장용 미리보기창
		end
		if(arg1 == "Blizzard_GuildBankUI") then
			GuildBankFrame:SetScale(HSRescaleSV_frame);	--길드은행 창
		end
		if(arg1 == "Blizzard_BindingUI") then
			KeyBindingFrame:SetScale(HSRescaleSV_frame);	--단축키 설정창
		end
		if(arg1 == "Blizzard_InspectUI") then
			InspectFrame:SetScale(HSRescaleSV_frame);	--살펴보기창
		end
		if(arg1 == "Blizzard_ItemSocketingUI") then
			ItemSocketingFrame:SetScale(HSRescaleSV_frame);	--아이템 소켓창
		end
		if(arg1 == "Blizzard_AchievementUI") then
			AchievementFrame:SetScale(HSRescaleSV_frame);	--업적창
		end
		--[[
		if(arg1 == "Blizzard_RaidUI") then
			hooksecurefunc("RaidPullout_GeneratePulloutFrame", function()		-- 공대창에서 파티창을 빼내올 때 후킹 함수
				HsRescale_raid(HSRescaleSV_raid);				-- 기본 공격대 파티창
			end)
		end
		]]
		if(arg1 == "Blizzard_Calendar") then
			CalendarFrame:SetScale(HSRescaleSV_frame);	--달력창
		end
		if(arg1 == "Blizzard_BattlefieldMinimap") then
			if (not IsAddOnLoaded("Capping")) then
				HsRescale_map(HSRescaleSV_map);
			end
		end
	end

end


function HsRescale_frame(n)
	FriendsFrame:SetScale(n);	--친구창 o (관련탭 모두)
	QuestFrame:SetScale(n);		--퀘스트창(npc한테 퀘받을 때나 완료할 때)
	QuestLogFrame:SetScale(n);	--퀘스트목록창 l (DoubleWide 지원)
	--WatchFrame:SetScale(n);	--퀘스트 및 업적추적창(보통 미니맵 밑에 뜨는거)

	ItemTextFrame:SetScale(n);	-- 편지 읽기, 책 읽기
	CharacterFrame:SetScale(n);	--캐릭터창 c 누르면 나오는거(관련 탭 모두)
	SpellBookFrame:SetScale(n);	--마법책 p
	LFGParentFrame:SetScale(n);	--파티찾기창 i
	MerchantFrame:SetScale(n);	--상인 창
	GossipFrame:SetScale(n);	--잡담 창(각종 npc 대화)
	TaxiFrame:SetScale(n);		--그리폰/와이번 창
	BattlefieldFrame:SetScale(n);	--전장 npc 참여창
	MailFrame:SetScale(n);		--우체통창
	PVPParentFrame:SetScale(n);		--명예점수/투기장
	PVPParentFrame:SetFrameStrata("HIGH");--명예점수/투기장 프레임 우선순위가 유닛프레임 뒤로 쳐지는 경향이 있어서 위로 올림
	BankFrame:SetScale(n);		--은행 기본창
	--KnowledgeBaseFrame:SetScale(n);	--지엠 기본창	2.4.3 패치이후 오류로 인한 주석처리
	HelpFrame:SetScale(n);		--지엠 도움창
	LootFrame:SetScale(n);		--루팅 창
	OpenMailFrame:SetScale(n);	--편지 창
	DressUpFrame:SetScale(n);	--미리보기 창
	TradeFrame:SetScale(n);		--거래창
end


function HsRescale_raid(r)
	for i=1, 8 do
		if getglobal("RaidPullout"..i) then
			getglobal("RaidPullout"..i):SetScale(r)
			getglobal("RaidPullout"..i):SetClampedToScreen(true)	-- 화면 벗어나지 않게 보호
		end
	end
end

function HsRescale_map(m)
	BattlefieldMinimap_LoadUI();
	BattlefieldMinimap.status = "active";
	BattlefieldMinimap:SetScale(m);
	BattlefieldMinimap:SetClampedToScreen(true)		-- 화면 벗어나지 않게 보호
	BattlefieldMinimapTab:SetScale(m);
end

local function tipScale(self)
	self:SetScale(HSRescaleSV_tip)
end

function HsRescale_tip(t)
	GameTooltip:SetScript("OnShow", tipScale)	-- 기본 툴팁창
	ShoppingTooltip1:SetScript("OnShow", tipScale)	-- Shift 키로 나타나는 비교 툴팁창1
	ShoppingTooltip2:SetScript("OnShow", tipScale)	-- Shift 키로 나타나는 비교 툴팁창2
end

-- archer1219 추가: 시스템 프레임
function HsRescale_system(s)
	ReadyCheckFrame:SetScale(s);		--전투준비 확인창
	StaticPopup1:SetScale(s);		--시스템 팝업창(1)
	StaticPopup2:SetScale(s);		--시스템 팝업창(2)
	GameMenuFrame:SetScale(s);		--게임 설정창
	StackSplitFrame:SetScale(s);		--아이템분할 갯수 선택창
	VideoOptionsFrame:SetScale(s);		--그래픽 설정창
	AudioOptionsFrame:SetScale(s);		--소리 및 음성 설정창
	InterfaceOptionsFrame:SetScale(s);	--인터페이스 설정창
end


function HsRescale_SlashCommand(msg)
	local cmd, num = strsplit(" ", msg)
	num = tonumber(num)
	if (cmd == "기본" or cmd == "f") then
		HSRescaleSV_frame = num;
		DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00HS |cff88ffaaRescale |cFFFFCC00팝업창:".." |c00ffffff"..HSRescaleSV_frame.."|cff88ffaa 배로 변경");
		HsRescale_frame(HSRescaleSV_frame);
	elseif (cmd == "지도" or cmd == "m") then
		if (not IsAddOnLoaded("Capping")) then
			HSRescaleSV_map = num;
			DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00HS |cff88ffaaRescale |cFFFFCC00지역지도:".." |c00ffffff"..HSRescaleSV_map.."|cff88ffaa 배로 변경");
			HsRescale_map(HSRescaleSV_map);
		else
			DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00ACE |cff88ffaaCapping |cFFFFCC00애드온이 활성화되어 있으므로 이 기능은 현재 사용하실 수 없습니다.")
		end
	elseif (cmd == "툴팁" or cmd == "t") then
		HSRescaleSV_tip = num;
		DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00HS |cff88ffaaRescale |cFFFFCC00게임 툴팁창:".." |c00ffffff"..HSRescaleSV_tip.."|cff88ffaa 배로 변경");
		HsRescale_tip(HSRescaleSV_tip);
	elseif (cmd == "공격대" or cmd == "r") then
		HSRescaleSV_raid = num;
		DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00HS |cff88ffaaRescale |cFFFFCC00공격대 파티창:".." |c00ffffff"..HSRescaleSV_raid.."|cff88ffaa 배로 변경");
		HsRescale_raid(HSRescaleSV_raid);
	elseif (cmd == "시스템" or cmd == "s") then
		HSRescaleSV_system = num;
		DEFAULT_CHAT_FRAME:AddMessage("|c0000CC00HS |cff88ffaaRescale |cFFFFCC00시스템 팝업창:".." |c00ffffff"..HSRescaleSV_system.."|cff88ffaa 배로 변경");
		HsRescale_system(HSRescaleSV_system);
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff88ffaa HS Rescale |c0000CC00사용법");
		DEFAULT_CHAT_FRAME:AddMessage("|cff88ffaa 명령어: |cFFFFCC00/크기 |c0000CC00또는 |cFFFFCC00/hsr |c0000CC00또는 |cFFFFCC00/scale");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFCC00/크기 |c0000CC00 기본(또는 f) |c00FF0000숫자 |c00FFFFFF  ~ 숫자 배수만큼 기본 팝업창 크기조절, 숫자 1(기본)");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFCC00/크기 |c0000CC00 지도(또는 m) |c00FF0000숫자 |c00FFFFFF  ~ 숫자 배수만큼 지역지도 크기조절, 숫자 1(기본)");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFCC00/크기 |c0000CC00 공격대(또는 r) |c00FF0000숫자 |c00FFFFFF  ~ 숫자 배수만큼 공격대 파티창 크기조절, 숫자 1(기본)");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFCC00/크기 |c0000CC00 시스템(또는 s) |c00FF0000숫자 |c00FFFFFF  ~ 숫자 배수만큼 시스템 팝업창 크기조절, 숫자 1(기본)");
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFCC00/크기 |c0000CC00 툴팁(또는 t) |c00FF0000숫자 |c00FFFFFF  ~ 숫자 배수만큼 게임 툴팁창 크기조절, 숫자 1(기본)");
	end
end
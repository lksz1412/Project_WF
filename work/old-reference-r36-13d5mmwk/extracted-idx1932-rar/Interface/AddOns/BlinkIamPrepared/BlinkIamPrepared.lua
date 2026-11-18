--[[---------------------------------------------------------------------------

	* 장착한 아이템 추가하는방법 *

		=> equipped_list 테이블에 장비번호를 추가한다. 숫자와 ,(쉼표)를 추가해줍니다.
		예) 5번(가슴보호구), 16번(주장비)를 추가한 예시
			local equipped_list = {
				13,
				14,
				5,
				16,
			}


	* 장착한 아이템 번호 *

		1 = 머리
		2 = 목
		3 = 어깨
		4 = 속옷 (필요없을듯, 사용효과있는 속옷본적없음)
		5 = 가슴
		6 = 허리
		7 = 다리
		8 = 발
		9 = 손목
		10 = 손
		11 = 반지1
		12 = 반지2
		13 = 장신구1
		14 = 장신구2
		15 = 등
		16 = 주장비
		17 = 보조장비,방패
		18 = 원거리무기
		19 = 휘장 (필요없을듯, 사용효과있는 휘장본적없음)


	* 쿨타임이 있는 스킬 추가하는 방법 *

		=> spell_list 테이블에 다음형식으로 스킬을 추가합니다.
		예) 기본 spell_list 테이블에 전사의 "도전의 외침", 도적의 "소멸", 사제의 "빛샘(4 레벨)" 을 추가한 예시
		local spell_list = {
			-- 마법사
			["발화"] = true,
			["얼음 방패"] = true,
			["환기"] = true,
			["화염 폭풍"] = true,

			-- 전사
			["위협의 외침"] = true,
			["도전의 외침"] = true,

			-- 드루이드
			["나무껍질"] = true,
			["평정"] = true,

			-- 도적
			["소멸"] = true,

			-- 사제
			["빛샘"] = "4 레벨",
		}

		자신이 필요하다싶은 스킬을 추가하시면 되며 기본적으로 등록되어있는 스킬중 필요없는 라인은 지우셔도됩니다.

		꼭 필요하다싶으신 스킬만 추가하는게 불필요한 부하를 줄이는데 좋으며 쿨타임이 없는 스킬을 추가할 필요는 없습니다.(당연하지)

		=> 형식은 다음과 같습니다. (맨끝네 ,쉼표는 잊지마세요)

			["스킬이름"] = true,			(true로 지정하면 스킬의 레벨에 상관없이 자동으로 찾습니다)
			또는
			["스킬이름"] = 2,				(숫자 2는 스킬의 레벨을 의미함)
			또는
			["스킬이름"] = "4 레벨",		("4 레벨"의 "스킬이름"을 등록합니다)


	* 남은 알림 시간 설정 방법 *

		변수중 local warntime = 10 라고 되어있는 수치를 변경해주시면 됩니다.

		단위는 "초"이며, 1보다 큰값을 적어주시면 됩니다.

		기본적으로 사용가능 10초전에 한번 알려주며 사용가능해지면 다시한번 더 알려줍니다.


	* 알림 *

		저장하실때는 필히 UTF-8로 저장하셔야 정상작동합니다.

		UTF-8로 저장하실 텍스트편집 툴이 없으시다면 아래 프로그램을 설치해보세요~_~(광고아님;;)

			- 에디트플러스 http://editplus.com/kr/index.html
			- 울트라에디트 http://www.ultraedit.com/


-----------------------------------------------------------------------------]]

-- 쿨타임 장비 설정 테이블 변수
local equipped_list = {
	1,2,3,4,5,6,
	13,
	14,
}

-- 쿨타임 스킬 설정 테이블 변수
local spell_list = {
	-- 마법사
	["발화"] = true,
	["얼음 방패"] = true,
	["환기"] = true,
	["화염 폭풍"] = true,
	["점멸"] = true,
	["마법 차단"] = true,

	-- 전사
	["위협의 외침"] = true,
	["돌진"] = true,
	["봉쇄"] = true,
	["죽음의 일격"] = true,
	["방패 밀쳐내기"] = true,
	["피의 갈증"] = true,
	["죽음의 소원"] = true,
	["소용돌이"] = true,
	["도전의 외침"] = true,

	-- 드루이드
	["나무 껍질"] = true,
	["평정"] = true,
}

local bScroll = LibStub and LibStub("LibScroller-1.0");
local spelltable = {}
local icontable = {}
local cooldownCountTime = 0
local update_time = 0.1 -- 1초에 한번씩 아이템 및 스펠 쿨타임 검사(수정할필요없음)
local warntime = 5 -- 5초전에 미리한번 알려준다. (초단위) : 원하는 시간으로 수정가능, 단 1보다 커야함
local color = {r=0.2, g=0.7, b=0.9} -- 기본 컬러값
local function update(self,arg1)
	cooldownCountTime = cooldownCountTime + arg1
	if cooldownCountTime > update_time then
		cooldownCountTime = 0

		-- 장착한 아이템 체크
		for k,v in pairs(equipped_list) do
			BIP_NotifyEquipped(v)
		end

		-- 스킬 체크
		for spell,id in pairs(spelltable) do
			BIP_NotifySpell(spell,id)
		end
	end
end

-- 장착하고있는 아이템 알림 함수
function BIP_NotifyEquipped(id)
	local start, duration, enable = GetInventoryItemCooldown("player",id)
	local icon = GetInventoryItemTexture("player", id)
	local cooldown = duration - (GetTime() - start)
	if ( start>0 and enable>0 and duration>3 ) then
		if ( cooldown < update_time ) then
			BIP_Alert("## "..GetItemInfo(GetInventoryItemLink("player", id)).." 사용 가능 ##",22,color.r,color.g,color.b, icon)
		elseif ( warntime > 1 and cooldown > (warntime-update_time) and cooldown <= warntime ) then
			BIP_Alert("## "..warntime.."초후 "..GetItemInfo(GetInventoryItemLink("player", id)).." 사용 가능 ##",18,color.r,color.g,color.b, icon)
		end
	end
end

-- 기술&주문 알림 함수
function BIP_NotifySpell(spell,id)
	local start, duration = GetSpellCooldown(id, "bookType")
	local cooldown = duration - (GetTime() - start)
	if ( start>0 and duration>3 ) then
		if ( cooldown < update_time ) then
			BIP_Alert("## "..spell.." 사용 가능 ##",22,color.r,color.g,color.b,icontable[spell])
		elseif ( warntime > 1 and cooldown > (warntime-update_time) and cooldown <= warntime ) then
			BIP_Alert("## "..warntime.."초후 "..spell.." 사용 가능 ##",18,color.r,color.g,color.b,icontable[spell])
		end
	end
end

-- 실제로 출력을 담당하는 함수
-- msg = 출력할 메세지
-- size = 출력메세지의 글자 크기(BCF에서만 사용:기본20)
-- r = 빨강색 (범위 0.0 ~ 1.0)
-- g = 녹색 (범위 0.0 ~ 1.0)
-- b = 파란색 (범위 0.0 ~ 1.0)
function BIP_Alert(msg,size,r,g,b,icon)
	if ( BCF_DisplayMessage and type(BCF_DisplayMessage)=='function' ) then -- BCF가 있다면 BCF를 통해서 메세지 출력
		BCF_DisplayMessage({
			text = msg,
			fontheight = (size or 18),
			rgb = {r=r,g=g,b=b},
			font = "Fonts\\2002b.TTF", -- 원하신다면 폰트도 수정하실수 있습니다
		})
	elseif SCT and SCT.CmdDisplay then -- SCT가 있다면 SCT를 통해서 메세지 출력
		--SCT:CmdDisplay("'"..msg.."' "..(r*10).." "..(g*10).." "..(b*10))
		SCT:DisplayText(msg, {r=r,g=g,b=b}, nil, "event", 1, nil, nil, icon)
	elseif ( MikSBT and MikSBT.DisplayMessage ) then -- MSBT가 있다면 MSBT를 통해서 메셎 출력
		MikSBT.DisplayMessage(msg, MikSBT.DISPLAYTYPE_NOTIFICATION, false, r*255, g*255, b*255, size, nil, 1)
	elseif SHOW_COMBAT_TEXT=="1" then
		CombatText_AddMessage(msg, CombatText_StandardScroll, r, g, b) -- 와우 기본 전투메세지를 사용한다면 이것을 통해서 출력
	elseif bScroll and bScroll.Display then
		local t,tp = math.random(1,3);
		if t==1 then
			tp = 'up';
		elseif t==2 then
			tp = 'down';
		else
			tp = 'sticky';
		end
		tp = 'sticky';
		bScroll:Display(
			'action', 'text',
			'message', msg,
			'r',r,'g',g,'b',b,
			'textsize', 24,
			'type', tp,
			'icon',icon,
			'font', "Fonts\\2002b.TTF",
			'outline', "OUTLINE"
		);
	else
		UIErrorsFrame:AddMessage(msg,r,g,b,1,UIERRORS_HOLD_TIME) -- 그것도 아니면 화면 상단쯤에 출력;
	end
end

-- 스킬의 id값을 찾는 함수
-- spell = 찾고자 하는 스킬명
-- rank = 찾고자 하는 스킬의 레벨 (지정하지 않으면 최초발견 레벨id값을 찾습니다) - nil, 숫자, "n 레벨"
function BIP_FindSpellId(spell,rank)
	local id = 1
	local spellName, subSpellName = GetSpellName(id, BOOKTYPE_SPELL)
	local icon = GetSpellTexture(id, BOOKTYPE_SPELL)
	while ( spellName ) do
		if ( spellName == spell ) then
			if ( subSpellName and (strlen(subSpellName) > 0) and strlen(rank or "")>0 ) then
				if ( subSpellName == rank ) or ( subSpellName == string.format("%d 레벨",tonumber(rank)) ) then
					return id, icon
				end
			else
				return id, icon
			end
		end
		id = id + 1
		spellName, subSpellName = GetSpellName(id, BOOKTYPE_SPELL)
		icon = GetSpellTexture(id, BOOKTYPE_SPELL)
	end
end

-- 저장된 정보가 있으면 그 정보를 불러들이고 없으면 기본 아이템, 스킬정보를 불러옵니다.
function BIP_setup()
	if ( BlinkIamPreparedDB and type(BlinkIamPreparedDB)=='table' ) then
		equipped_list = {}
		for k,v in pairs(BlinkIamPreparedDB) do
			local equip = tonumber(k)
			if type(k)=='number' then
				table.insert(equipped_list, k)
			else
				if ( k == "color" ) then
					color.r = v.r or color.r
					color.g = v.g or color.g
					color.b = v.b or color.b
				elseif ( k == "warntime" ) then
					warntime = v
				else
					spelltable[k], icontable[k] = BIP_FindSpellId(k)
				end
			end
		end
	else
		for spellname, rank in pairs(spell_list) do
			if rank and type(rank)=='boolean' then
				spelltable[spellname], icontable[spellname] = BIP_FindSpellId(spellname)
			elseif rank and (type(rank)=='string' or type(rank)=='number') then
				spelltable[spellname], icontable[spellname] = BIP_FindSpellId(spellname,rank)
			end
		end
	end
end

-- 이벤트를 처리할 frame생성
local frame = CreateFrame("Frame")

-- 이벤트를 처리할 frame에 OnEvent 함수 연결
frame:SetScript("OnEvent",function (self,event)
	BIP_setup()
end)

-- 시간을 잴 함수 연결
frame:SetScript("OnUpdate",update)

-- 이벤트 등록
frame:RegisterEvent("PLAYER_ENTERING_WORLD") -- 와우접속시 발생
frame:RegisterEvent("LEARNED_SPELL_IN_TAB") -- 새로운 스킬을 배우면 발생

--frame:Show()

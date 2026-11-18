
--_-

local equipped_list = {
	[1] = "머리",
	[2] = "목",
	[3] = "어깨",
	[4] = "속옷", -- (필요없을듯, 사용효과있는 속옷본적없음)
	[5] = "가슴",
	[6] = "허리",
	[7] = "다리",
	[8] = "발",
	[9] = "손목",
	[10] = "손",
	[11] = "반지1",
	[12] = "반지2",
	[13] = "장신구1",
	[14] = "장신구2",
	[15] = "등",
	[16] = "주장비",
	[17] = "보조장비,방패",
	[18] = "원거리무기",
	[19] = "휘장",
}

local racial_skills = {
	["언데드"] = {
		"시체먹기",
		"포세이큰의 의지", -- 언데드 액티브 스킬 2개나있네~_~ㅋㅋㅋ
	},
	["나이트 엘프"] = {
		"그림자 숨기",
	},
	["타우렌"] = {
		"전투 발구르기",
	},
	["오크"] = {
		"피의 격노",
	},
	["인간"] = {
		"인간의 자생력",
	},
	["노움"] = {
		"탈출의 명수",
	},
	["드워프"] = {
		"석화",
	},
	["트롤"] = {
		"광폭화",
	},
	["블러드 엘프"] = {
		"비전 격류",
	},
	["드레나이"] = {
		"나루의 선물",
	},
}
local class_spells = {
	["WARRIOR"] = {
		"돌진",
		"봉쇄",
		"가로막기",
		"도발",
		"도발의 일격",
		"도전의 외침",
		"위협의 외침",
		"죽음의 일격",
		"피의 갈증",
		"방패 밀쳐내기",
		"보복",
		"방패의 벽",
		"무모한 희생",
		"충격의 일격",
		"휩쓸기 일격",
		"광전사의 격노",
		"죽음의 소원",
		"무장 해제",
		"최후의 저항",
		"피의 분노",
		"칼날폭풍",
		"영웅의 격노",
		"방패 막기",
		"충격파",
		"영웅의 투척",
		"분노의 재생력",
	},
	["MAGE"] = {
		"발화",
		"투명화",
		"환기",
		"용의 숨결",
		"냉기 돌풍",
		"얼음 회오리",
		"화염 작렬",
		"화염계 수호",
		"냉기계 수호",
		"신비의 마법 강화",
		"화염 폭풍",
		"점멸",
		"매서운 한파",
		"마법 차단",
		"얼음 방패",
		"얼음 보호막",
		"냉정",
		"얼음 핏줄",
		"물의 정령 소환",
		"환영 복제",
		"동결",
	},
	["DRUID"] = {
		"나무 껍질",
		"강타",
		"도전의 포효",
		"웅크리기",
		"야성의 돌진 (곰)",
		"야성의 돌진 (표범)",
		"자연의 군대",
		"정신 자극",
		"환생",
		"평온",
		"자연의 신속함",
		"신속한 치유",
		"생존 본능",
		"광폭화",
		"태풍",
		"별똥별",
		"무력화",
		"맹공격",
		"자연의 손아귀",

	},
	["ROGUE"] = {
		"은신",
		"후려치기",
		"전력 질주",
		"소멸",
		"실명",
		"회피",
		"교란",
		"발차기",
		"급소 가격",
		"마음가짐",
		"사전계획",
		"냉혈",
		"그림자 일격",
		"그림자 걷기",
		"아드레날린 촉진",
		"폭풍의 칼날",
		"그림자 망토",
		"광기의 학살자",
		"장비 분해",
		"그림자 밟기",
		"속임수 거래",
		"혼란",
		"칼날 부채",
		"어둠의 춤",
	},
	["PRIEST"] = {
		"소실",
		"공포의 수호물",
		"마력 주입",
		"내면의 집중력",
		"고통 억제",
		"빛샘",
		"흡혈의 선물",
		"영혼의 절규",
		"신의 권능: 보호막",
		"정신 분열",
		"침묵",
	},
	["PALADIN"] = {
		"자유의 축복",
		"보호의 축복",
		"심판의 망치",
		"신성 충격",
		"응징의 방패",
		"참회",
	},
	["WARLOCK"] = {
		"죽음의 고리",
		"저주 증폭",
		"마의 지배",
		"점화",
		"어둠의 격노",
	},
	["SHAMAN"] = {
		"주술의 분노",
		"마나 해일 토템",

		-- 특성
		"자연의 신속함",
		"정기의 깨달음",
		-- 토템류
		"불의 정령 토템",
		"마법정화 토템",
		"속박의 토템",
		"대지의 정령 토템",
		"불꽃 회오리 토템",
		-- 주문
		"연쇄 번개",
		"대지 충격", -- 쿨타임 공유하는 스킬은 한개만 적어주심됩니다. 다 적으면 다 나올건데;;
		"화염 충격",
		"냉기 충격", 

		"피의 욕망",  -- 호드
		"영웅심",     -- 얼라이언스
	},

	["HUNTER"] = {
		"충격포",
		"죽은척하기",
		"만반의 준비",
		"평정의 사격",
		"위협",
		"야수의 격노",
		"산탄 사격",
		"침묵의 사격",
		"공격 저지",
		"비룡 쐐기",
		"속사",

		-- 덫류 -- 쿨타임 공유하므로 1개만 체크하시면 될겁니다. 다하면 스크롤압박;
		"제물의 덫",
		"얼음의 덫",
		"냉기의 덫",
		"폭발의 덫",
		"뱀 덫",
	},
}

local function getIcon(spell)
	local _, _, icon = GetSpellInfo(spell)
	if icon then
		return "|T"..icon..":20|t "
	end
	return ""
end
local function getItemIcon(id)
	local icon = GetInventoryItemTexture("player", id)
	if icon then
		return "|T"..icon..":20|t "
	end
	return ""
end

function BIP_Set(spell, value)
	if ( not BlinkIamPreparedDB ) then
		BlinkIamPreparedDB = {}
	end
	BlinkIamPreparedDB[spell] = value
	BIP_setup()
end

function BIP_Get(spell)
	if ( not BlinkIamPreparedDB ) then
		BlinkIamPreparedDB = {}
	end
	if ( not BlinkIamPreparedDB[spell] ) then
		return nil;
	end
	return BlinkIamPreparedDB[spell]
end

function BIP_GUI_Register()
	if _G.BlinkConfig then

		local class = strupper(select(2,UnitClass("player")))
		local race = UnitRace("player")
		
		_G.BlinkConfig:RegisterOptions{
			name = "나는 준비 됐다~",
			type = "root",
			command = {"나는준비됐다.","iamready"},
			options = {
				{
					type = "description",
					text = "블링크의 나는 준비 됐다~",
					fontobject = "QuestTitleFont",
					r = 1,
					g = 0.82,
					b = 0,
					justifyH = "LEFT",
				},
				{
					type = "description",
					text = "장착하고있는 아이템이나 스킬을 사용가능할때 알려줍니다.",
					fontobject = "ChatFontNormal",
					justifyH = "LEFT",
					justifyV = "TOP",
				},
				{
					type = "group",
					options = {
						{
							type = "range",
							text = "미리 알림시간",
							tooltip = "0초로 설정하면 미리 알려주지 않습니다.",
							min = 0,
							max = 30,
							step = 1,
							get = function ()
								return BIP_Get("warntime") or 5
							end,
							set = function (value)
								BIP_Set("warntime", value)
							end,
						},
						{
							type = "multiselect",
							text = "착용 아이템 부위별 설정",
							values = function ()
								local opt = {}
								for i=1,#equipped_list, 1 do
									table.insert(opt,{
										text = getItemIcon(i)..equipped_list[i],
										value = i,
										disable = function ()
											if getItemIcon(i)=="" then
												return true
											end
										end,
									})
								end
								return opt
							end,
							get = function ()
								local opt = {}
								for k,v in pairs(BlinkIamPreparedDB) do
									if type(k)=='number' then
										opt[k] = true
									end
								end
								return opt
							end,
							set = function (value)
								for k,v in pairs(BlinkIamPreparedDB) do
									if type(k)=='number' then
										BlinkIamPreparedDB[k] = nil
									end
								end
								for k, v in pairs(value) do
									BIP_Set(k, true)
								end
							end,
							col = 3,
						},
						{
							type = "multiselect",
							text = "종족 고유 기술 설정",
							values = function ()
								local opt = {}
								for i=1,#racial_skills[race], 1 do
									if ( racial_skills[race][i] and string.len(racial_skills[race][i])>0 ) then
										table.insert(opt,{
											text = getIcon(racial_skills[race][i])..racial_skills[race][i],
											value = racial_skills[race][i],
											disable = function ()
												if getIcon(racial_skills[race][i])=="" then
													return true
												end
											end,
										})
									end
								end
								return opt
							end,
							set = function (value)
								for i=1, #racial_skills[race] do
									BlinkIamPreparedDB[racial_skills[race][i]] = nil
								end
								for k, v in pairs(value) do
									BIP_Set(k, true)
								end
							end,
							get = function ()
								local opt = {}
								for i=1, #racial_skills[race] do
									if BlinkIamPreparedDB[racial_skills[race][i]] then
										opt[racial_skills[race][i]] = true
									end
								end
								return opt
							end,
							col = 3,
						},
						{
							type = "multiselect",
							text = "직업 기술 설정",
							values = function ()
								local opt = {}
								for i=1,#class_spells[class], 1 do
									if ( class_spells[class][i] and string.len(class_spells[class][i])>0 ) then
										table.insert(opt,{
											text = getIcon(class_spells[class][i])..class_spells[class][i],
											value = class_spells[class][i],
											disable = function ()
												if getIcon(class_spells[class][i])=="" then
													return true
												end
											end,
										})
									end
								end
								return opt
							end,
							set = function (value)
								for i=1, #class_spells[class] do
									BlinkIamPreparedDB[class_spells[class][i]] = nil
								end
								for k, v in pairs(value) do
									BIP_Set(k, true)
								end
							end,
							get = function ()
								local opt = {}
								for i=1, #class_spells[class] do
									if BlinkIamPreparedDB[class_spells[class][i]] then
										opt[class_spells[class][i]] = true
									end
								end
								return opt
							end,
							col = 3,
						},
					},
				},
			},
		}
	end
end

-- 실행
BIP_GUI_Register()



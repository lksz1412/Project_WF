-- Version : Korean

BINDING_HEADER_REAGENTHEAVENHEADER	= "재료천국";
BINDING_NAME_REAGENTHEAVEN		= "재료천국 설정 열기";
BINDING_NAME_REAGENTHEAVENFRAME		= "재료천국 창 열기";
BINDING_NAME_REAGENTHEAVENTOGGLE	= "재료천국 활성/비활성화";

REAGENTHEAVEN_NAME			= '재료천국';
REAGENTHEAVEN_LOCALIZED_COMMAND1	= '/재료천국';
REAGENTHEAVEN_LOCALIZED_COMMAND2	= '/고';

REAGENTHEAVEN_CMD_CONFIG		= "설정";
REAGENTHEAVEN_CMD_TOGGLE		= "전환";
REAGENTHEAVEN_CMD_HELP			= "도움말";
REAGENTHEAVEN_CMD_SETRANGE		= "범위설정";

REAGENTHEAVEN_HELP_TEXT_LINE1	= REAGENTHEAVEN_CMD_HELP..": 이 도움말을 봅니다.";
REAGENTHEAVEN_HELP_TEXT_LINE2	= REAGENTHEAVEN_CMD_CONFIG..": 설정창을 불러옵니다.";
REAGENTHEAVEN_HELP_TEXT_LINE3	= REAGENTHEAVEN_CMD_TOGGLE..": 재료천국 창을 토글(toggle)합니다.";
REAGENTHEAVEN_HELP_TEXT_LINE4	= REAGENTHEAVEN_CMD_SETRANGE.." <기술종류> <최소범위> <최대범위>: 툴팁에 나오는 기술종류의 범위를 지정합니다.";
REAGENTHEAVEN_HELP_TEXT_LINE5	= "";

RH_MSG_NODATA				= "데이터를 찾지 못하였습니다.";
RH_MSG_NOSKILL				= "전문기술 이름을 찾지 못했습니다. 전문기술 명칭에는 공백이 들어가면 안됩니다.";
RH_MSG_NOTNUMBER_MAXVALUE		= "기술범위 최대숫자가 잘못되었습니다. 숫자만 넣어주세요.";
RH_MSG_NOTNUMBER_MAXVALUE		= "기술범위 최소숫자가 잘못되었습니다. 숫자만 넣어주세요.";

RH_CLASSSKILLS = { '회복', '비전', '고양', '복원', '수양', '보호' };
--RH_TRADESKILLS = { '대장기술', '제련술', '기계공학', '가죽세공', '응급치료', '기계 공학', '가죽 세공', '재봉술', '보석세공', '요리', '연금술', '독 조제' };
RH_TRADESKILLS = { '대장기술', '제련술', '기계공학', '가죽세공', '응급치료', '기계 공학', '가죽 세공', '재봉술', '보석세공', '요리', '연금술', '독 조제', '마법부여', '주문각인' };
--RH_CRAFTS = { '마법부여' };
--RH_SKILLS = {
--	['A'] = "대장기술",
--	['B'] = "제련술",
--	['C'] = "기계공학",
--	['D'] = "가죽세공",
--	['E'] = "응급치료",
--	['F'] = "재봉술",
--	['G'] = "요리",
--	['H'] = "연금술",
--	['I'] = "독 조제",
--	['Z'] = "마법부여",
--	['Y'] = "보석세공",
--	['a'] = "드루이드",
--	['b'] = "마법사",
--	['c'] = "주술사",
--	['d'] = "사제",
--	['f'] = "성기사",
--	['z'] = "특수재료",
--};

--RH_SKILLS_NT = {
--	["대장기술"] = 'A',
--	["제련술"] = 'B',
--	["기계공학"] = 'C',
--	["기계 공학"] = 'C',
--	["가죽세공"] = 'D',
--	["가죽 세공"] = 'D',
--	["응급 치료"] = 'E',
--	["응급치료"] = 'E',
--	["재봉술"] = 'F',
--	["요리"] = 'G',
--	["연금술"] = 'H',
--	["독 조제"] = 'I',
--	["독조제"] = 'I',
--	["마법부여"] = 'Z',
--	["보석세공"] = 'Y',
--	["드루이드"] = 'a',
--	["마법사"] = 'b',
--	["주술사"] = 'c',
--	["사제"] = 'd',
--	["성기사"] = 'f',
--	["특수재료"] = 'z',
--};

RH_SKILLS = {
	['A'] = "약초 채집",
	['B'] = "제련술",
	['C'] = "무두질",
	['D'] = "대장기술",
	['E'] = "기계공학",
	['F'] = "연금술",
	['G'] = "가죽세공",
	['H'] = "재봉술",
	['I'] = "마법부여",
	['J'] = "요리",
	['K'] = "낚시",
	['L'] = "응급치료",
	['M'] = "제련술",
	['N'] = "독 제조",
	['O'] = "퀘스트",
	['P'] = "전사",
	['Q'] = "성기사",
	['R'] = "사제",
	['S'] = "드루이드",
	['T'] = "주술사",
	['U'] = "마법사",
	['V'] = "도적",
	['W'] = "흑마법사",
	['X'] = "사냥꾼",
	['Y'] = "보석세공",
	['Z'] = "주문각인",
};

RH_SKILLS_NT = {
	["약초 채집"] 	= 'A',
	["제련술"] 	= 'B',
	["무두질"] 	= 'C',
	["대장기술"]	= 'D',
	["기계공학"] 	= 'E',
	["연금술"] 	= 'F',
	["가죽세공"] 	= 'G',
	["재봉술"] 	= 'H',
	["마법부여"] 	= 'I',
	["요리"] 	= 'J',
	["낚시"] 	= 'K',
	["응급치료"] 	= 'L',
	["제련술"] 	= 'M',
	["독 제조"] 	= 'N',
	["퀘스트"] 	= 'O',
	["전사"] 	= 'P',
	["성기사"] 	= 'Q',
	["사제"] 	= 'R',
	["드루이드"] 	= 'S',
	["주술사"] 	= 'T',
	["마법사"] 	= 'U',
	["도적"] 	= 'V',
	["흑마법사"] 	= 'W',
	["사냥꾼"] 	= 'X',
	["보석세공"] 	= 'Y',
	["주문각인"] 	= 'Z',
};

RH_STR_BASIC_CONFIGRATION = '기본 설정';
RH_STR_REFRESH = "기술조사";
RH_STR_RESET = "기술 초기화";

RH_STR_USE_REAGENTHEAVEN = '재료천국 사용하기';
RH_STR_SUBTITLECHECK = '부분명칭 검색';
RH_STR_PASTE_REAGENTS = '대화창에 붙여넣기';
RH_STR_SHOW_DETAIL_RECEIPE = '조재법 자세하게 보여주기';
RH_STR_SHOW_COLORED_RECEIPE ='자신에게 맞는 숙련도 색으로 보여주기';
RH_STR_SHOW_UNLEARNED = '자신이 배우지 않은 다른 기술도 보여주기';
RH_STR_SHOW_RECURSIVE_RECEIPE = '재료 재귀호출';
RH_STR_SHOW_PRODUCT = '완성품 재료 보여주기';
RH_STR_MAX_LINES = '최대표시길이';

RH_TT_USE_REAGENTHEAVEN = '재료천국을 사용합니다.';
RH_TT_SHOW_DETAIL_RECEIPE = '전문/보조기술의 재료로 사용되는 아이템의 경우 기술 및 완성품의 이름을 보여줍니다.';
RH_TT_SHOW_COLORED_RECEIPE ='자신에게 맞는 기술색 보여주기';
RH_TT_SHOW_UNLEARNED = '자신이 배우지 않은 다른 전문/보조기술에 대한 것까지 보여줍니다.';
RH_TT_SHOW_RECURSIVE_RECEIPE = '재료의 완성품이 또 다른 것의 재료인 경우 끝까지 추적해서 보여줍니다.';
RH_TT_SHOW_PRODUCT = '보는 물품이 전문/보조기술의 완성품인 경우 그 재료를 보여줍니다.';
RH_TT_MAX_LINES = '최대표시길이';

RH_ITEMNAME = '아이템 명칭: ';

RH_STR_EDITFRAME_TITLE	= "재료천국 메모 편집기";
RH_STR_EDITFRAME_GATHER	= "수집방법:";
RH_STR_EDITFRAME_EXTRA = "기타:";
RH_STR_EDITITEM = "메모편집";


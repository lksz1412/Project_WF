
-- 메인탱커 지원

BINDING_HEADER_BLIMKASSISTANKER		= "블링크의 탱커지원";
BINDING_NAME_ASSISTTANKER			= "탱커로 지정한 플레이어의 타겟 어시스트 단축키";
BINDING_NAME_TARGETTANKER			= "탱커로 지정한 플레이어를 선택하는 단축키";
BINDING_NAME_TOGGLEPLAYERNAME		= "아군 플레이어 이름 토글";
BINDING_NAME_TOGGLEENEMYNAME		= "상대진영 플레이어 이름 토글";
BINDING_NAME_SETTANKER				= "탱커 지정";

SET_TANKER							= "탱커 지정";
SET_TANKER_FOCUS					= "주시대상 탱커로 지정";
SET_TANKER_TEXT_SUCCESS				= "%s님을 탱커로 선택하셨습니다.";
SET_TANKER_TEXT_SUCCESS_FOCUS		= "%s님(주시대상)을 탱커로 선택하셨습니다.";
SET_TANKER_TEXT_SUCCESS_PET			= "소환수를 탱커로 선택하셨습니다.";
SET_TANKER_TEXT_FAIL				= "%s님은 현재 같은 파티에 속해있지 않습니다.";
SET_TANKER_TEXT_ERROR				= "탱커 선택 오류 : 존재하지 않는 플레이어입니다.";
UNSET_TANKER						= "탱커 지정 해지";

--BAT_ASSISTTANKER					= "|cffffffff%s|r님을 지원합니다."
--BAT_ASSISTTANKER_PET				= "|cffffffff"..PET.."|r를 지원합니다."
--BAT_TARGETTANKER					= "|cffffffff%s|r님을 선택합니다."
--BAT_TARGETTANKER_NOT_YET			= "탱커를 설정하지않았습니다. 먼저 탱커를 설정해주십시오.";

BAT_TOOLTIP_UNIT_SET_TANKER			= "선택한 유저를 메인탱커로 설정합니다. 단축키설정에서 |cffffffff탱커 지원|r 또는 |cffffffff탱커 선택|r으로 설정한 단축키로 한번에 탱커의 타겟을 공유하거나 탱커를 선택할 수 있습니다.";
BAT_TOOLTIP_UNIT_SET_TANKER_FOCUS	= "주시대상(focus) 유저를 메인탱커로 설정합니다. 단축키설정에서 |cffffffff탱커 지원|r 또는 |cffffffff탱커 선택|r으로 설정한 단축키로 한번에 탱커의 타겟을 공유하거나 탱커를 선택할 수 있습니다.";
BAT_TOOLTIP_UNIT_UNSET_TANKER		= "선택한 탱커를 해지합니다.";

BAT_MSG_NOT_FOUND_FOCUS_UNIT		= "지정된 주시대상이 없습니다. 주시대상을 먼저 지정해주십시오.";
BAT_MSG_CANT_SET_TANKER				= "전투중에는 탱커를 설정하실 수 없습니다.";
BAT_MSG_INVALID_UNIT				= "탱커로 지정할 대상을 먼저 선택하십시오.";
BAT_MSG_UNSET_TANKER				= "지정된 탱커를 해제합니다.";
BAT_MSG_FOCUSUNIT_CHANGED			= "탱커로 지정되어있던 주시대상이 바뀌었습니다.";
BAT_MSG_FOCUSUNIT_DISAPPEAR			= "탱커로 지정되어있던 주시대상이 사라졌습니다. 주시대상 탱커지원을 해제합니다.";

if ( GetLocale() == "enUS" ) then
end

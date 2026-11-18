SisterChatMods 2.3.0 사용 설명서 -07.12.05-

-2.3.0 변경 사항

 몇가지 기능들의 경우 게임 실행 후 옵션 값 변경에 대한 지속적인 검색이 이루어 지도록 해서 옵션 변경이 바로 적용되도록
 만들었는대, 이 부분이 계속 시스템 자원을 차지하여 레이드 광구간에서와 같은 순간적으로 많은 데이터가 발생할때 AMD계열에서
 기대이상의 과부하를 발생시고 있었습니다.

  그래서 그런 과부하가 예상되는 기능들에 대해서 lua파일에서 직접 수정하거나 설정값을 없애버렸습니다.

 1. [버튼 숨김/최하단 아닐시 최하단 버튼 보이기]
    특별한 경우가 아니면 보통 그냥 쓰시기에 옵션 조절을 없앴습니다.
    버튼들을 숨기고, 최하단이 아닐경우만 최하단 버튼이 나타납니다.

    1-1. 메뉴버튼(말풍선버튼) 보기
      FadeMenuButton=  false; -- 메뉴버튼 숨김   <<false 부분을 true로 수정하세요.

 2. [대화 입력창 위로 표시]
    겜상 옵션을 제거하였고 lua파일의 저장값에서
      MoveEditBox=     true;  -- 대화입력창 위로 표시
    true 값을 false 값으로 수정하고 리로드하시면 아래로 표시됩니다.

 3. [시간표시(TimeStamps)] 전투로그 창에만 적용
     역시 게임상 옵션 제거. lua파일의 저장값에서
      TimeStamps=      true;  -- 시간표시
     true 값을 false로 수정하고 리로드 하면 표시되지 않습니다.
     
     3-1. 모든 창에 시간표시
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
	for i = 2, 2 do    <<<< 부분을 for i = 1, 7 do 로 수정하면 모든 창에 시간이 표시됩니다.
		getglobal("ChatFrame"..i).Original_AddMessage = getglobal("ChatFrame"..i).AddMessage;
		getglobal("ChatFrame"..i).AddMessage = Hooked_AddMessage;
	end
	end

4. [짧은 채널명/채널명 숨김/직업별 아이디 색상/잡담 넘김/대화내용 지속/마우스 휠 사용]
기본값: true        true          true            false        true         true      
    
   4-1. 잡담넘김 기능이 작동중일때 여관주인이나 특초시 (Ctrl+우클릭)으로 다른창으로 자동으로 넘어가는것을 막을 수 있습니다.


주의!! 2.2.0 버젼 사용자의 경우 WTF의 저장값을 삭제 후 사용해 주세요.



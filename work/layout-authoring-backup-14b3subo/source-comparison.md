# 原본 이미지와 회수 설정의 배열 대조

비교 기준: 첫 이미지3840×2160. 이미지 좌표는 좌상단 원점의 근사값, 제안 좌표는 별도 설계값. 원본 화면을 비례 확대·축소하지 않음. 직접 판독 근거는 original-image-geometry.md/.json; A1은 그 저장 기록과 실제 설정·소비 코드를 대조함. 아래 소스 경로 기준은 SourceArchive/2022-11-19/extracted/Interface/addons/.

| 시각 요소·원본 근사 범위 | 회수 설정·실제 소비 연결 | 일치와 한계 | 첫 제안의 처리 |
|---|---|---|---|
| 연속36열×1행, [421,1683,3481,1766], 버튼외곽약82/pitch85 | !DevilUI/Profile/Dominos.lua:938–1056(1번),1186–1270(5·6번). 각12버튼;1의TOPRIGHT→6TOPLEFT,5의TOPLEFT→6TOPRIGHT. core/buttonBar.lua:122–124는 columns가 없으면 numButtons,190–237은 행/크기 계산. core/frame.lua:728–771은 저장 anchor 복원 | 배열·접합 일치: 왼쪽1/가운데6/오른쪽5. 저장x/y는 화면pixel이 아님 | 36칸 한 줄 유지. 외곽80/gap3,폭2985. 검정dock 위에 배치; 생략·중앙미니바 대체 없음 |
| 하단8열×3행, [1845,1803,2557,2066], 버튼약85/pitch89 | Profile/Dominos.lua:1097–1185(3·4번). 각12버튼/4열,4의TOPLEFT→3TOPRIGHT. 두 bar 모두 isBottomToTop=true. buttonBar.lua:197–233은 각4×3과 순서 적용 | 4×3 두 개 접합=8×3,24칸 일치. 위의36칸 줄과 별도 | 외곽80/gap4,668×248. 바닥status→utility/bags→3행 순서로 적층. sourcebar3왼쪽·4오른쪽 구분 유지 |
| 좌우 floating각4열×3행, [1140,784,1437,1007] / [2404,784,2700,1007], 버튼약70 | Profile/Dominos.lua:1271–1442(7–10번). 각각6버튼/2열.9→7왼쪽,10→8오른쪽.7/8은 legacyanchor2TL/2TR;frame.lua:743–751은 legacy형식 지원 | 9+7 및8+10의2×3 접합으로 각4×3 설명. 숨겨진2번frame도 anchor참조이므로 화면에 없다고 데이터 삭제하지 않음. legacy기호의 상세FlyPaper 변환은 이번에 미독 | 원래 좌우floating배열 유지. 외곽68/gap4,각284×212. 게임장면 중앙을 새 HUD로 채우지 않음 |
| 큰 은색/파란색frame [1052,1389,1565,1506] | Profile/PitBull4.lua:16265–16358에 player·target설정과폭280·Glamour7. Health13008–13029/Power12090–12106/Border14563–14666. 두 unit이 enabled라는 설정 사실 | 이미지 큰frame은1개만 관측. player/target역할·마나정체는 이미지로 미확정. target설정 존재≠별도target이화면에보임 | player/target표시는 사용자 요구에 맞춘 제안. 원본의 보이는1개와 추가target자리 구분, target샘플은 가상 표시로 명시 |
| 하단bank우측 접합 미니맵 [2558,1800,2883,2131], 우측chat [2884,1802,3837,2134] | Profile/SexyMap.lua:3–147의BOTTOM/scale1.26,Profile/kgPanels.lua:493–586의미니맵틀. SexyMap.lua:575–600은140base와scale/anchor적용 | source상태와하단인접관계 일치. numeric130871/137057/137056은clientFileID. 원래화면과저장좌표의정확한scale은미검증 | bank→미니맵→우측chat 순서 유지. map외곽328정사각형. 오른쪽위미니맵으로 이동하지 않음 |
| 검정dock y1767–2160, 높이약393; framedpanel3곳·status높이30 | Profile/kgPanels.lua:23–775의8패널,1566–1568의layoutloaf. 하단이미지height문자열162/width100%,chat1scale1.59. kgPanels.lua:839–900,907–996은scale/크기·gradient·texture소비 | source162는한패널UI높이,393은이미지관측pixel. 동일한양으로취급불가. panel기능은부분미확정 | 버튼/utility/map내용으로dock높이392 산출. darkgradient·Devil2구획 유지; 빈panel은새broker기능으로채우지않음 |
| 좌측돌장식[245,1619,425,1778], 우측부분장식[3466,1618,3674,1778] | Profile/kgPanels.lua:211–304,399–492은demon/angel참조. media/sharedmedia.lua:6–13은실제자산등록 | 참조·파일확보와그림관측은확정. 두그림의정밀shape/alpha일치·가려진우측전체모양은미검증 | 동봉자산을작은끝장식으로참조. 우측숨은모양을추측하여새그림제작하지않음. 버튼모서리장식의의도적겹침만허용 |
| Onyx버튼테두리·Glamour7상태바 | Profile/Masque.lua:29–119은OnyxClassic. Masque_Onyx/Skins.lua:203–214는키글자TOPRIGHT,567–604는Frame-Classic/40×40. media/statusbar/Glamour7.tga존재 | 스킨명·자산연결확정. 현재Masque/Onyx지원과게임글꼴실측은미검증 | 기존검정/은색테두리참조,키글자22px·본문24px 설계값. 실제키/주문이름은미지정 |
| 시전·부가정보·다른화면요소 | Quartzloaf없음. imagegeometry에는독립시전바역할미확정. party-like tile/우측meter-like패널/상단아이콘/옆손잡이는관측만있음 | 없는target·시전바·addon정체를그림에서복원했다고하지않음 | 시전은작은예약영역만설계. meter/broker·party구현은이번core배치안에추가하지않음; 부가요소생략은비교누락과구분 |

원본에서 보이는action칸 합계36+24+12+12=84. 아이콘이 찬칸은21+3+2+0=26이라는 이미지관측이며 사용자의주문·키할당이 아님. 미리보기는같은빈칸밀도만 중립placeholder로 표현 가능. 공개캐릭터명·주문명·실제키는옮기지 않음. Geometry보고의target미관측·근사허용오차·가려진장식한계를유지함.

중대 0 · 중간 0 · 경미 0 — round10 신규 발견. 기존 L1 경미 1건은 root 판정으로 별도 유지한다.

Round10의 native 입력·창별 필터·숫자 ID·초기화 부작용·개인 데이터·설치 경계 검토를 완료했다. 보고서192행을 이 관점으로 대조했으며 새 결함은 발견하지 못했다. 이는 이전 입력 전체의 compaction 복구나 Step3 최종 수용을 선언하는 보고가 아니다.

아래 경로는 `D:/Projects/Project_WF/` 기준이며, source 별칭은 현재 발주서16–26행과 같다.

| 반증 시도 | 직접 대조한 원문 | 판정 |
|---|---|---|
| native 입력 보존을 입력창 제거로 과장했는가 | 보고서106행: **“native 입력은 남는다. 완전 무테·입력창 부재와 다르다.”** OLD `Interface/AddOns/DChat/DChat.lua:200`: `ChatFrameEditBox:SetPoint("BOTTOMLEFT",  ChatFrame1, "TOPLEFT", -5, 0)`;238행: `local ebf = CreateFrame("Button", nil, ChatFrameEditBox)`;243행: `edgeSize = 15,` | 기존 입력창의 위치·장식을 변경하고 새 border를 더한다. 보고서의 구별과 맞는다. |
| CAN이 항상 입력창을 위로 옮긴다고 했는가 | ALPHA `Interface/addons/CAN_Chat/CAN_Chat.lua:330`: `if CANChat["Edit"] ==1 then`; STANDARD `Profile/CAN_Chat.lua:8`: `["Edit"] = 0,`; 보고서106행: **“Alpha profile Edit0과 config 기본 Edit1도 구별”** | 조건부 이동과 profile 값을 분리한다. 이번 round에서 제외된 config 기본값의 재판정은 하지 않았다. |
| 탭 질감 제거를 완전 숨김으로 읽게 하는가 | ALPHA `chattab.lua:57`: `frame.leftTexture:Hide()`;76행: `frame:SetAlpha(1)`; V42 core1199행: `if tab then tab:Show() end`; 보고서107행: **“탭 질감 제거와 글자 완전 숨김은 다르다.”** | 보고서107·137·156·190행은 상태별 현재 동작을 미검증으로 유지한다. |
| 세 창 생성 코드를 필터 보존 기능으로 오인하게 하는가 | ALPHA SPECIAL initializer111행: `ChatFrame_RemoveAllMessageGroups(ChatFrame1)`;143행: `ChatFrame_RemoveAllMessageGroups(ChatFrame3)`;153행: `ChatFrame_RemoveAllMessageGroups(ChatFrame4)`; V42 core1178–1179행: `remove(chat)` / `clear_channels(chat)`; minimap818행: `remove(chat)` | 보고서109·111·155·161·188행은 옛 분담과 reset을 사용자 설정에 자동 적용하지 않는다. “외형만 변경하면서 필터 보존”이라는 과장은 없다. |
| 옛 숫자 ID를 현행 창 역할과 동일시하는가 | V42 core1050행: `for id = 3, window_limit() do`;1059–1061행은 저장된 `frameId`를 읽고 `< 3`을 거부한다. minimap813행: `for id = 1, 2 do`;1127–1138행은2번 전투창을 별도로 다룬다. | 보고서188행의 **“보존할 것은 독립 메시지창 세 개의 역할이지 옛 숫자 ID의 일괄 복사나 특정 채널 분담이 아니다.”**와 맞는다. |
| 메시지·gossip wrapper를 외형 복원에 함께 채택했는가 | ALPHA CAN core139행: `SendChatMessage = HEAD_SendChatMessage;`;256행: `if string.find(cont,v) then return Orig_AddMessage(self,"") end`; X2 Sister128행: `GossipFrame_OnEvent         = SCM_Gossip;`;434행은 `SCMSaved.SkipGossip` 조건을 검사 | 보고서111·173·188·192행은 이런 동작의 통째 이식을 요구하지 않는다. X2 네 변형의 실제 저장 `SkipGossip=false`도 직접 조회했다. |
| 메시지 fade를 창 전체 자동숨김으로 확대했는가 | X2 Sister515행: `chatframe:SetFading(SCMSaved.chatFade);`; ALPHA CAN344행: `chatframe:SetFading(CANChat["Fade"]);`; 보고서173행: **“전체 창·탭 자동숨김으로 해석하지 않았다.”** | source 주석보다 실제 호출을 기준으로 구별했다. |
| 통합 설치를 작은 외형 변경으로 취급했는가 | V42 core1618행: `import_presets(profile, seeds)`;1643–1644행: `set("useUiScale", "1")` / `set("uiScale", profile == "Wide_T" and "0.9" or "0.7")`;1667행: `pcall(SlashCmdList.REFLUX, "switch " .. profile)` | 보고서125·158·161·192행은 설치·전역 배율·profile 전환을 정적 참고와 구분한다. |
| 배포자 저장값을 사용자 현재 필터로 바꿔 적었는가 | 요청 대장12행은 세 대화창을 확인하고13행은 입력·장식 문제의 해결법 조사를 요청한다. 보고서5행: **“창별 채널·필터는 사용자 현재 설정이 확인되지 않았으므로 옛 배포본의 분담을 자동 적용하지 않는다.”** | 배포 template 조회와 현재 사용자 설정을 구분한다. live WTF·매크로·게임 입력을 확인했다고 주장하지 않는다. |

배포 template 데이터에서도 차이를 확인했다. OLD는1/3/4, X2 SPECIALW는1/2/3, SPECIAL은1/2, STANDARD·STANDARDW는1만 `SHOWN 1`이다. 특히 SPECIALW의2번은122행 `NAME 전투`,129–135행의 combat message 목록을 갖는다. 따라서 “세 창”의 역사적 존재와 사용자가 원하는 세 창의 현재 필터 분담은 같은 사실이 아니다. 보고서184·188행은 표시 개수와 역할 보존의 경계를 유지한다.

native 입력·필터 소비처에 한정해 **지도 밖 새 연결 결함은 발견하지 못했다.** V42의 `ConfigureChat`→`ConfigureExtraChat`→`AttachChannels`, 배치 저장과 installer 호출은 지정 core/minimap 전체에 포함되어 있었다. 외부 API와 addon의 실제 runtime 작동은 확인하지 않았으며 보고서도 보장하지 않는다.

이번 현재 입력의 실제 전문 독해 범위:

| 파일 | 읽은 창 |
|---|---|
| 현재 발주서 `b-round10-context-continuation.md` | 1–35 |
| 보고서 | 복구 시1–100,101–192를 읽었고 현재 context에서 유지 |
| 요청 대장 | 1–26 |
| static evidence / R36 evidence | 각각1–60 /1–118 |
| 보존된 `audit_rounds1-9_partial.md` | 1–68 |
| V42 `!DevilUI/!DevilUI.lua` | 1–280,281–560,561–840,841–1120,1121–1400,1401–1680,1681–1905 |
| V42 `!DevilUI/minimap.lua` | 1–260,261–520,521–780,781–1040,1041–1203 |
| V42 TOC / profile XML / ForeverCompat | 각각1–14 /1–17 /1–37 |
| ALPHA CAN core | 1–230,231–423 |
| ALPHA buttons / chattab / mouseover / TOC | 각각1–70 /1–126 /1–13 /1–16 |
| ALPHA STANDARD CAN profile | 1–12 |
| ALPHA SPECIAL initializer | 1–255 |
| OLD DChat Lua / TOC | 1–190,191–349 /1–6 |
| X2 Sister Lua | 1–260,261–517 |
| X2 Sister TOC / XML | 각각1–23 /1–39 |
| X2 Neon Lua / TOC | 각각1–57 /1–8 |

데이터 조회는 전문 독해로 세지 않았다.

- manifest는 archive template의 정확한 경로·행 수를 찾는 map으로 사용했다.
- B08 1개·X2 4개·OLD 1개 template에서 각각 WINDOW1–10 전체의 `NAME/DOCKED/SHOWN/MESSAGES/CHANNELS`를 구조화 조회했다. B08·X2·OLD의 현재 사용자 파일은 열지 않았다.
- `x2-four-variant-settings-compact.json`의 schema·대표 record를 확인하고, 네 변형 `SCMSaved`의 전체 전달 키와 값을 조회했다. 별도 닉네임 저장 자료는 출력하지 않았다.
- 기존 parser·압축·이미지·download 시험을 다시 실행하지 않았다.

열 관점의 활동은 다음처럼 구분한다.

| 관점 | 활동 상태 |
|---|---|
| 1 구조 | compaction 전 수행 기록, 보존된 부분 반환7행 |
| 2 사실·수치 | 같은 기록8행 |
| 3 연결·영향 지도 | 같은 기록9행 |
| 4 완결성·실패 경계 | 같은 기록10행 |
| 5 요청 뜻·범위 | 같은 기록11행 |
| 6 전체 글·이미지 분모 | 같은 기록12행 |
| 7 연대·버전·flavor | 같은 기록13행 |
| 8 목표 외형·제약 | 같은 기록14행. L1은 root가 직접 원판독을 대조해 경미로 판정했다고 전달받음 |
| 9 적대 | 같은 기록15행 |
| 10 native 입력·필터·개인/게임/설치 경계 | 이번 현재 입력 전문 독해와 위 반증 대조로 완료 |

1~9관점의 원천 전체를 현재 다시 복구했다고 주장하지 않는다. L1은 root의 직접 삼각검증 판정으로 유지하며 이번10관점에서 재판정하지 않았다. 최종 Step3 수용은 root가 보존된 기록과 실제 원문을 대조해 결정할 몫이다.

파일 변경·삭제·원본 코드 실행·게임 조작·개인 데이터 접근은 없었다. 설정상 역할은 `bada-b-auditor / gpt-6.1-sol / high`이며 실제 runtime model·effort·usage·context 수치는 미관측이다. 같은 B로 후속을 기다린다.
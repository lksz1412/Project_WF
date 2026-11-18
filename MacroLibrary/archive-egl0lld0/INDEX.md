# Macro Library

Original raw files are authoritative. Literal commands and conditions below are search keys.

## character-01-01 — 고정
Scope: character-01; original lines 1–6

````text
#showtooltip
/cast [nochannaeling][nomod] 고정 사격
/cast [nochannaeling][mod:alt] 고정 사격
/cast [nochannaeling][mod:shift] 고정 사격
````

## character-01-02 — 구속
Scope: character-01; original lines 7–11

````text
#showtooltip
/cast 구속의 사격
/changeactionbar [actionbar:2] 1
````

## character-01-03 — 날철
Scope: character-01; original lines 12–13

````text
````

## character-01-04 — 눈속
Scope: character-01; original lines 14–19

````text
#showtooltip
/cast [group:party, @party1] 눈속임
/cast [group:raid, @mouseover, nodead][@focus, raid] 눈속임
/cast [nogroup, @pet] 눈속임
````

## character-01-05 — 섬광
Scope: character-01; original lines 20–24

````text
#showtooltip
/cast 섬광
/changeactionbar [actionbar:2] 1
````

## character-01-06 — 신.일
Scope: character-01; original lines 25–29

````text
#showtooltip [mod:alt]일제 사격;신비한 사격
/cast [nochannaeling][mod:alt] 일제 사격
/cast [nochannaeling][nomod] 신비한 사격
````

## character-01-07 — 얼덫
Scope: character-01; original lines 30–34

````text
#showtooltip
/cast 빙결 덫
/changeactionbar [actionbar:2] 1
````

## character-01-08 — 연발
Scope: character-01; original lines 35–38

````text
#showtooltip
/cast [@CURSOR] 연발 공격
````

## character-01-09 — 조준
Scope: character-01; original lines 39–44

````text
#showtooltip
/cast [nochannaeling][nomod] 조준 사격
/cast [nochannaeling][mod:alt] 조준 사격
/cast [nochannaeling][mod:shift] 조준 사격
````

## character-01-10 — 죽척
Scope: character-01; original lines 45–52

````text
#showtooltip
/stopcasting
/stopcasting
/stop attack
/cast 죽은 척하기
/cast 죽은 체하기
````

## character-01-11 — 타르
Scope: character-01; original lines 53–57

````text
#showtooltip
/cast 타르 덫
/changeactionbar [actionbar:2] 1
````

## character-02-01 — 가막
Scope: character-02; original lines 1–6

````text
#showtooltip [mod:alt]돌진;가로막기
/run UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
/시전 [target=mouseover,help][help]가로막기
/시전 [target=mouseover,harm][harm]돌진
````

## character-02-02 — 고감
Scope: character-02; original lines 7–11

````text
#showtooltip
/startattack
/cast [mod:alt]투신;고통 감내
````

## character-02-03 — 도발
Scope: character-02; original lines 12–15

````text
#showtooltip
/시전 [@mouseovertarget,harm][@mouseover,harm][harm]도발;도발
````

## character-02-04 — 돌마격
Scope: character-02; original lines 16–22

````text
#showtooltip [mod:alt]돌진;마무리 일격
/run UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
/cast 마무리 일격
/stopcasting
/cast 돌진
````

## character-02-05 — 무기변환
Scope: character-02; original lines 23–30

````text
#showtooltip
/stopcasting
/equipslot [equipped:방패] 16 명예결속단 글라디우스
/equipslot [equipped:방패] 17 하수인 절단기
/equipslot [noequipped:방패] 16 명예결속단 글라디우스
/equipslot [noequipped:방패] 17 태양섬광 방패
````

## character-02-06 — 방밀
Scope: character-02; original lines 31–35

````text
#showtooltip
/startattack
/cast 방패 밀쳐내기
````

## character-02-07 — 방벽
Scope: character-02; original lines 36–40

````text
#showtooltip
/cast 방패의 벽
/use 생명석
````

## character-02-08 — 복수
Scope: character-02; original lines 41–45

````text
#showtooltip
/startattack
/cast 복수
````

## character-02-09 — 봉쇄
Scope: character-02; original lines 46–50

````text
#showtooltip 봉쇄
/cast [@mouseover,harm][harm]봉쇄
/cast [@mouseover,help][help]봉쇄
````

## character-02-10 — 분강
Scope: character-02; original lines 51–55

````text
#showtooltip 분노의 강타
/startattack
/시전 분노의 강타 
````

## character-02-11 — 분쇄
Scope: character-02; original lines 56–60

````text
#showtooltip
/startattack
/시전 분쇄
````

## character-02-12 — 쇠날
Scope: character-02; original lines 61–64

````text
#showtooltip
/시전 [@player] 쇠날발톱
````

## character-02-13 — 압도
Scope: character-02; original lines 65–69

````text
#showtooltip
/startattack
/cast 압도
````

## character-02-14 — 포딘
Scope: character-02; original lines 70–73

````text
#showtooltip
/연속시전 reset=3 천둥의 포효, 오딘의 격노
````

## character-02-15 — 피갈
Scope: character-02; original lines 74–78

````text
#showtooltip 피의 갈증
/startattack
/시전 피의 갈증
````

## character-02-16 — 필격
Scope: character-02; original lines 79–84

````text
#showtooltip 필사의 일격
/startattack
/시전 집중된 분노
/시전 필사의 일격
````

## character-03-01 — test
Scope: character-03; original lines 1–4

````text
#showtooltip
/cancelaura 혼합물: 죽음의 입맞춤
````

## character-03-02 — 독정화
Scope: character-03; original lines 5–8

````text
#showtooltip
/연속시전 reset=5 독 정화 토템, 토템의 귀환
````

## character-03-03 — 무기
Scope: character-03; original lines 9–14

````text
#showtooltip
/castsequence [spec:1] reset=3 천둥의 일격 수호물,불꽃혓바닥 무기,하늘의 격노
/castsequence [spec:2] reset=3 질풍의 무기,불꽃혓바닥 무기,하늘의 격노
/castsequence [spec:3] reset=3 파도소환사의 수호,대지생명의 무기,하늘의 격노
````

## character-03-04 — 번화
Scope: character-03; original lines 15–18

````text
#showtooltip
/cast [mod:alt]연쇄 번개;번개 화살
````

## character-03-05 — 승천
Scope: character-03; original lines 19–25

````text
#showtooltip 승천
/start attack
/use 13
/use 14
/cast 승천
````

## character-03-06 — 용채
Scope: character-03; original lines 26–30

````text
#showtooltip 
/start attack
/cast 용암 채찍
````

## character-03-07 — 정화
Scope: character-03; original lines 31–35

````text
#showtooltip
/시전 [target=mouseover,harm][harm]정화
/시전 [target=mouseover,help][help][target=player]영혼 정화
````

## character-03-08 — 폭격
Scope: character-03; original lines 36–41

````text
#showtooltip 폭풍의 일격
/start attack
/cast 고대의 인도
/cast 폭풍의 일격
````

## account-common-01 — 낚시
Scope: account-common; original lines 1–5

````text
#showtooltip
/click StaticPopup1Button1
/cast [nochanneling]낚시
````

## account-common-02 — 대상전환
Scope: account-common; original lines 6–8

````text
/target focus
````

## account-common-03 — 던지기
Scope: account-common; original lines 9–16

````text
#showtooltip
/Stopcasting
/target [@mouseover]
/click ExtraActionButton1
/s <%T>에게 눈 패스!
/targetlasttarget
````

## account-common-04 — 바진입
Scope: account-common; original lines 17–19

````text
/changeactionbar [actionbar:1] 2
````

## account-common-05 — 바탈출
Scope: account-common; original lines 20–23

````text
#showtooltip
/changeactionbar [actionbar:2] 1
````

## account-common-06 — 샘플
Scope: account-common; original lines 24–28

````text
#showtooltip
/시전 [target=mouseover,help][help][target=player]영혼 정화
/시전 [target=mouseover,harm][harm]정화
````

## account-common-07 — 액션바 변경
Scope: account-common; original lines 29–33

````text
#showtooltip
/cast 야생 영혼
/changeactionbar [actionbar:2] 1
````

## account-common-08 — 주시
Scope: account-common; original lines 34–37

````text
#showtooltip
/focus
````

## account-common-09 — 탈것
Scope: account-common; original lines 38–43

````text
#showtooltip
/script UIErrorsFrame:Hide()
/cast [flyable] 흑요석 밤날개표범; 회색 구룽지 무리지도자
/내리기 
````

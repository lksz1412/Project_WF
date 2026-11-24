# Audit log — Step 52 review (same review B), returned 2026-11-24 20:52 +0900

Saved by master from the reviewer's return text.

중대 0 · 중간 3 · 경미 5

## 중간

**M1. 확인 목록의 「물리 px 재기」 식은 화면 아래에서 잰 값을 내고, 기대 좌표는 화면 위에서 잰 값이다. 맞는 배치도 「다름」으로 판정된다.** (이번 변경에서 생김)
- 자리: `Collection/codex-briefs/phase27-game-check.md:33`
  - 원문: "`/run local f=Grid2LayoutFrame print(f:GetBottom()*f:GetEffectiveScale()*select(2,GetPhysicalScreenSize())/768)`"
  - 이 식을 쓰는 곳: `:38` "창 아래 끝 y(물리 px, 위 「물리 px 재기」): fhd 304 · qhd 452 · uhd 762 … fhd 347 · qhd 541 · uhd 904"
- 근거 1 (preset 값): Grid2 창의 기준점은 BOTTOMRIGHT 이고 PosY 는 화면 아래에서 잰 값이다.
  - `!DevilForever_Core/Presets/fhd.lua:272` 원문: `["anchor"]="BOTTOMRIGHT",…["PosY"]=776*factor`
  - qhd 는 `PosY"]=988*factor`, uhd 는 `PosY"]=1398*factor`.
  - 1080−776=304 · 1440−988=452 · 2160−1398=762. 기대값 304/452/762 는 화면 위에서 잰 값이다.
- 근거 2 (V2 계산): `V2.lua:154` 원문: `grid.values.PosX,grid.values.PosY=(xTarget+w-m.width)*factor,(m.height-m.gridBottom)*factor`. 여기서 gridBottom(347 등)도 위에서 잰 값이다.
- 근거 3 (Grid2 저장 규칙): `Grid2/GridLayout.lua:882` 원문: `local y = (a:find("BOTTOM") and f:GetBottom()*s)`. 기준점이 BOTTOM 이면 y 는 GetBottom, 곧 아래에서 잰 값이다.
- 결과: 확인하는 사람이 fhd 에서 776(qhd 988, uhd 1398)을 읽고 304 와 비교한다. 1번(Grid2 창 자리)과 V2 비교 항목이 맞게 배치돼 있어도 「다름」으로 적힌다.

**M2. 미러 중간 실패나 설치 뒤 대조 실패 때 게임이 반만 설치된 상태로 남는데, 스크립트 출력이 그렇다고 말하지 않는다.** (이번 변경에서 생김. Codex 스크립트에는 이름 바꾸기로 통째 교체하고 실패하면 되돌리는 장치가 있었다 — `live-015-pitbull-install-20261124.ps1:121–133`)
- 자리: `Collection/tools/install_local.ps1`
  - `:93` 원문: `if ($code -ge 8) { throw "robocopy failed ($code): $Label" }`
  - `:178` 원문: `Invoke-Robocopy $mirror "mirror $name"`
  - `:187` 원문: `Assert-SameTree (Get-TreeInventory (Join-Path $source $name)) (Get-TreeInventory (Join-Path $gameAddOns $name)) "installed $name"`
  - `:199–201` 원문: `} catch { Write-Output ("ERROR " + $_.Exception.Message); exit 1 }`
- 누가·언제·무엇: master 가 실제 설치를 돌리다가 k 번째 폴더(35개 중)에서 robocopy 가 8 이상을 돌려주거나(잠긴 파일, 백신·런처의 파일 잡기), 설치 뒤 해시 대조가 실패하는 경우.
  - 그때 1..k 폴더는 이미 새 판으로 바뀌었고 나머지는 옛 판이다. installation.json 도 쓰이지 않는다.
  - 출력은 `ERROR robocopy failed (n): mirror X` 또는 `installed X : entry differs: …` 한 줄뿐이다. 게임 폴더가 이미 일부 바뀌었다는 말도, 백업에서 되돌려야 한다는 말도 없다.
  - 백업 경로는 앞쪽 `backup … -> <backup>\AddOns` 줄에만 찍혀 있다.
- 연계: 되돌리는 방법은 `-Help`(:29–32)와 확인 목록 §0 :13 에 있다.

**M3. 확인 목록의 「원래 preset 으로 되돌린다」는 원래 상태로 돌아가는 방법이 아니다. preset 을 다시 적용해 사용자의 편집값과 애드온 설정을 preset 값으로 덮어쓴다.** (이번 변경에서 생김)
- 자리: `phase27-game-check.md`
  - `:38` 원문: "원래 preset 이름을 `/dfp status` 로 적어 두고 확인 뒤 `/dfp preset <원래 이름>` → `/dfp go` 로 되돌린다."
  - `:70` 원문: "확인 뒤 원래 preset 으로 되돌린다(1번과 같은 방법)."
  - `:4` 원문: "바꾼 설정은 원래 값을 적어 두고 확인 뒤 되돌린다."
- 근거 (`!DevilForever_Core/Presets.lua`):
  - Restore 는 preset 이 다루는 프레임의 편집값을 지운다. `:304–306` 원문: `for frameKey in pairs(def.edits) do local _, how = Core.Edit:Clear(frameKey)`
  - `/dfp go` 뒤에는 애드온 값을 쓴다. `:323–327` 원문: `"애드온 값은 다시 불러온 뒤 씀: " … " — /dfp go"`
  - 자동 적재 때만 기존 값을 남긴다. `:585–586` 원문: `"existing settings kept — /dfp preset " .. presetName .. " applies preset values"`
  - V2 의 `/dfp go` 도 PitBull4·Quartz·Grid2 자리 값을 쓴다(V2.lua:54–76).
- 누가·언제·무엇: 자기 캐릭터에서 상태띠·PitBull4·Grid2·Quartz 설정을 손본 사용자가 1번·6번을 따라 하면 그 값이 preset 값으로 바뀐다.
  - 원래대로 돌리는 길은 §0 의 WTF 백업 복원뿐인데, 확인 목록은 그 사실을 이 자리에서 말하지 않는다.

## 경미 (최대 5)
1. `phase27-game-check.md:89`: pushed 그림 기대가 "1 px 아래·조금 어둡게" 이다. 그런데 Step 51 경미 1(누르는 동안 hover BLEND 그림이 위에 겹침)대로라면 게임에서 「다름」이 나올 가능성이 크다. 추정이고 게임에서 확인하지 않았다.
2. `phase27-game-check.md:93`: 사양 §3 의 「띠 높이·글꼴 크기를 편집했을 때 글자 대체」 가운데 띠 높이(`size`) 편집 줄이 없다. 글꼴 크기만 있다.
3. `phase27-game-check.md:20`: `/dfp status` 의 출처로 `:262–263` 을 들었는데, 이 줄은 슬래시 등록(SLASH_DFPROFILE)이다. 실제 처리는 `Commands.lua:190`(help), `:192`(status)다.
4. `phase27-game-check.md:64`: "Swing 설정 `:329–334`" 은 어느 파일인지 흐리다. 실제는 `SwingForever.lua:329–334`(dfStandStill 설정)이다. `Swing.lua:329–334` 는 끌기 함수라 다른 것을 가리키게 읽힐 수 있다.
5. `install_local.ps1:2–6`: 아무 인자 없이 실행하면 Mandatory 매개변수를 대화형으로 묻는다. 자동 실행에서는 응답이 없어 멈추거나 실패한다. 다듬기 수준이다.

## brief 확인 항목별 판정 (요지)
1. 스크립트: 고정 루트·Wow.exe :10, :97–100 · 프로세스 :44–48, :152, :166 · 링크 :57–71, :125, :153–154, :104–107 · 백업 먼저 :157–164(게임 쓰기 :167 이후보다 앞) · 패키지 폴더만 :170, :142 · 남길 폴더 :146–150 · 설치 뒤 대조 :186–188 · installation.json :189–196 · DryRun = robocopy /L 만 · 종료 0/1 · PS 5.1·7 = work_log :69–70 판정 줄.
2. 적대: 백업 확인 전 쓰기 없음 · 패키지 폴더 밖 삭제 없음 · 영수증 대조 :112–138 · 반만 설치 = M2 · 긴 경로 최장 149자 · 같은 이름 파일이 있으면 M2 상태(드묾).
3. 확인 목록: Step 47 1–8 전부 있거나 이유와 함께 제외 · Hekili 없음 · 인용 file:line 확인 결과 맞음(경미 3·4 제외) · 좌표 숫자 같음, 재는 기준만 어긋남(M1).
4. DQ2(Hekili 가 스테이지에 들어감) = 결함 아님, 사용자·master 결정 · DQ3 = 결함 아님.

## 읽은 범위
brief-52-review.md 1–23 · brief-52.md 1–22 · work_log-52.md 1–97 · install_local.ps1 1–202 · phase27-game-check.md 1–96 · phase26-step47-check.md 1–12 · live-015-pitbull-install-20261124.ps1 1–136 · receipt.json(python, 필드만) · Commands.lua 28–46, 120–175, 186–192, 215–265 · Presets.lua 270–360, 442–446, 577–586, 595–640 · Presets/fhd.lua 272, 296–310 · V2.lua 50–60, :76, :154 · Edit.lua 100–215, 246–254, 270–296 · PitBull4 Options.lua 28–42, ConfigMode.lua 1–60 · Grid2 GridLayout.lua 214–220, 395–418, 856–868, 872–919, :1193 · GridCore.lua 310–316, 360–371 · GridUtilsCmd.lua 130–178 · GridLayouts.lua 60–100 · Defaults/Grid2.lua 50–56 · Quartz Config.lua 54–64, 186–205 · Quartz.lua 100–130 · SwingForever.lua 50–66, 145–180, 325–336 · Swing.lua 329–334 · Dominos slashCommands.lua 20–36 · Skin_Dominos/Skin.lua 30–34, 58–61, 160–166 · REQUEST_LEDGER_phase27.md R150–R155.

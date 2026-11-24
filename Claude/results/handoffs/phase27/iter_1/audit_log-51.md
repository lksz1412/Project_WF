# Audit log — Step 51 review (review B, bada-a3-reviewer), returned 2026-11-24 20:39 +0900

Saved by master from the reviewer's return text.

중대·중간 없음 (중대 0 · 중간 0 · 경미 4)

## 경미 (한 줄씩)
1. Collection/tools/theme_switcher_art.py:142–145 與 ThemeSwitcher.lua:161 — 눌린 그림을 보여 줄 기회가 거의 없음. 누르는 동안 마우스는 버튼 위에 있으므로 hover 그림(밝고, 1 px 내려가지 않은 완결 그림, BLEND)이 눌린 그림 위에 겹쳐 그려진다. 그래서 눌린 그림의 "18 % 어둡게 + 1 px 아래" 는 거의 가려지고, 아래쪽 1 px 테두리만 겹쳐 보일 수 있다. 이것은 추정이고 게임 안에서 확인하지 않았다. 원인은 brief §1(hover 완결 그림)과 §2-1(BLEND)의 조합이며 이번 코드가 사양에서 벗어난 것은 아니다.
2. ThemeSwitcher.lua:230 `if event == "PLAYER_LOGIN" then ready = true; dim(Core.InCombat()); apply()`: 전투 중 로그인이면 apply() 가 :176 `if Core.InCombat() then pending = true; return end` 에서 멈추고, panel 은 :48 `panel:Hide()` 상태로 남는다. 따라서 0.45 흐림은 화면에 나타나지 않는다. 전투가 끝나면 :229 가 alpha 를 1 로 되돌린 뒤에 패널이 처음 보인다. 사양 §2-5 가 요구한 줄이라 결함은 아니고, 효과가 보이지 않는 코드라는 관찰이다.
3. TGA 가장자리 기계 검사(그림 칸의 맨 바깥 줄·칸에서 alpha > 40 인 픽셀): 이름 39장 모두에서 윤곽선이 칸의 위·아래 끝줄에 닿는다(alpha 최대 227). 그림자는 칸 경계에서 잘린다(작업 판단 1 그대로). 화살표는 fhd·qhd 의 `arrow_prev_*` 만 끝줄에 닿고(alpha 70/44) `arrow_next_*` 는 닿지 않는다. 마스크는 좌우를 뒤집지만 그림자는 두 방향 모두 (+1, +1) 로 두기 때문에 좌우 짝의 그림자 모양이 조금 다르다. 다듬기 수준이다.
4. 작업 기록 work_log-51.md:75 는 Skin.lua 를 "full read" 로 적었다. 이번 검수에서 나는 Skin.lua 를 grep 줄(:51–52, :84, :109, :132, :147, :153)로만 확인했다. 연계 판정(Skin.lua 가 전환 칸의 FontString·버튼·자식을 만지지 않음)에는 충분했다. 다만 Skin.lua 전문을 다시 읽어 대조하지는 않았다.

## brief 확인 항목별 판정 (요지 그대로)
1. 사양 §2 1–6: 텍스처 객체 :86–93 한 번 생성 · SetTexture 결과 :146–151 확인 뒤 :158–161 부착 · BLEND :161 · FontString :136/:139, :162/:165 · 글자 대체 조건 :121–123(겉보기·편집 크기), :126(표에 없음), :132/:149(SetTexture false) · 화살표 한 쌍 대체 · apply() 안에서만 교체 · OnUpdate·C_Timer 없음 · 미끄러짐 두 묶음 :212–219 · 전투 alpha :225, :228–230 · Disable ≤1 :203–206 · 그 밖 변경 없음(`git diff HEAD --stat -- Collection/AddOns` = ThemeSwitcher.lua 하나, 줄바꿈 유지).
2. 그림: 이름·id·순서 = Theme.lua:27–33 · 63 TGA type 2 / 32 bpp / descriptor 8 / footer · 크기 256×32(fhd·qhd)·512×32(uhd)·화살표 32×32 · Appearance TGA 와 같은 헤더 · LICENSE-OFL.txt 하나, TTF 없음 · TexCoord :133/:156 · 칸 밖 투명은 시험 :204–209.
3. 지도 대조: 맞음. 지도 밖 찾기 — ThemeSwitcher 참조는 toc:8·시험뿐, Skin.lua·StatusStrip 은 전환 칸을 건드리지 않음, 설치기 엔진에 확장자·파일 수 필터 없음, ReleaseCatalog·verify_archives 는 폴더 이름만, build.py:256–271 은 .tga·.txt 를 남김, PIL 은 기존 의존.
4. 적대: nil 객체·재진입·전투 중 preset 변경·흰 사각형·짝 안 맞는 화살표·alpha 고착 — 깨지는 경로 못 찾음. 게임 클라이언트 API 동작(텍스처 객체를 받는 Set*Texture, SetTexture(nil), TexCoord 유지)은 미확인.
5. Decision Queue: 1 patches.py os.devnull = 범위 밖·원래 있던 문제 · 2 = Step 53 게임 확인 몫 · 3 OFL -text = 결함 아님(색인이 이미 CRLF).

## 읽은 범위
brief-51-review.md 1–44 · appearance-26-theme-switcher.md 1–60 · work_log-51.md 1–142 · ThemeSwitcher.lua 1–236 + diff · theme_switcher_art.py 1–375 · theme_switcher.py diff 덩어리(:26–39, :74–105, :178–316) · manifest diff · Theme.lua 1–60, 130–253 · Core.lua 190–200, 336–350 · Presets.lua 228–240, 270–312, 595–640 · Presets/{fhd,qhd,uhd}.lua :272 · V2.lua 머리 · Composition.lua 60–140 (+:7) · build.py 245–275, :65–66 · extract.py :159 · Skin.lua grep 줄 · index.md :15–20, :121.

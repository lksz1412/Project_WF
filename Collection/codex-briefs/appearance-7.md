# Codex 외관 발주문 — Phase 7 (시전바 · Quartz 3.8.0)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/7/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `d726a254197affceb9c8f3da892c97efb12ed76127d14ae988f000759a8e4846`) + Quartz 원본 `References/forever-addons/Quartz/Quartz-3.8.0.zip` + FUF 원본 `References/forever-addons/Forever Unit Frames/ForeverUnitFrames-0.65.2.zip`. Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 내 시전바·대상 시전바·주시·소환수 시전바와 전역 쿨다운 막대·휘두르기 막대의 자리·크기·막대 질감·글꼴·테두리·배경·아이콘 자리. 자리는 Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`)의 중앙 묶음 둘레에서 Codex 가 정하되 중앙 시야를 가리지 않게 한다.
- 시전 상태 색(시전·채널·완료·실패/차단)과 차단할 수 없는 시전 표시(방패 아이콘·테두리·색)의 모습. 상태가 색으로 구분되는 것은 그대로 둔다(색 하나로 합치지 않는다).
- Quartz 에는 자체 테마 API 가 없다. 외관 수단은 LibSharedMedia-3.0(막대 질감 `statusbar`·글꼴 `font`·테두리 `border` 를 이름으로 등록 — Quartz 는 `Quartz.lua:43–51` 에서 자기 질감을 이렇게 등록한다)과 Quartz 설정 값이다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음 · Quartz 항목)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `quartz.player` `quartz.target` `quartz.focus` `quartz.pet` | `Quartz3CastBarPlayer` / `Quartz3CastBarTarget` / `Quartz3CastBarFocus` / `Quartz3CastBarPet` | position · size |
| `quartz.gcd` `quartz.swing` | `Quartz3GCDBar` / `Quartz3SwingBar` | 없음 |

막대는 Quartz 가 모듈을 만들 때 생기고(`CastBarTemplate.lua:1240–1294`, 이름 `Quartz3CastBar<모듈>`), 주시 막대는 클라이언트에 `FocusFrameSpellBar` 가 있을 때만(`modules/Focus.lua:23`), 전역 쿨다운·휘두르기 막대는 그 모듈이 켜질 때 생긴다(`modules/GCD.lua:83`, Forever 전용 `modules/SwingForever.lua:82`). 크기 편집 범위는 등록 표에서 10–1500 하나로 묶였다(Quartz 자체 범위: 너비 50–1500, 높이 10–50 — `CastBarTemplate.lua:860–872`).

## 3. 값을 어디에 두나

- Quartz 설정은 AceDB 저장 변수 `Quartz3DB` 의 프로필 하나에 있다(`Quartz.lua:54` — 모든 캐릭터가 같은 「Default」 프로필을 쓴다). 막대마다의 값은 모듈 이름공간(`Player`·`Target`·`Focus`·`Pet`·`GCD`·`Swing` …)에, 공통 색은 최상위 프로필에 있다. 키 이름: 막대 `w`·`h`·`x`·`y`·`point`·`scale`·`alpha`·`strata`·`texture`·`border`·`font`·`fontsize`·`timefontsize`·`hideicon`·`iconposition`·`icongap`·`iconalpha`·`nametextposition`·`timetextposition` 등(`CastBarTemplate.lua:1201–1237`), 공통 색 `castingcolor`·`channelingcolor`·`completecolor`·`failcolor`·`sparkcolor`·`backgroundcolor`·`bordercolor`·`backgroundalpha`·`borderalpha`(`Quartz.lua:24–41`), 차단 불가 표시 `noInterruptChangeBorder`·`noInterruptBorder`·`noInterruptBorderColor`·`noInterruptBorderAlpha`·`noInterruptChangeColor`·`noInterruptColor`·`noInterruptShield`(옵션 키 `CastBarTemplate.lua:1115–1168` — 기본값 표의 `noInterruptBorderChange`·`noInterruptColorChange` 는 코드가 읽지 않는 이름이다).
- 외관 코드가 `Quartz3DB` 를 직접 쓰거나 Quartz 막대에 `SetPoint`·`SetSize` 를 직접 걸지 않는다(Quartz 가 설정을 다시 걸면 되돌아간다). Quartz 설정으로 되는 값은 **값 제안 파일** `quartz-profile.fragment.lua`(Lua 표 하나, `{profile = {...}, namespaces = {Player = {...}, Target = {...}, …}}` 꼴, Quartz 키 이름 그대로, 색은 `{r, g, b}` 또는 `{r, g, b, a}`)로 낸다. 이 값은 Claude 가 Core 기본값 주입(채워지지 않은 키만)으로 넣는다. LibSharedMedia 등록은 Skin 폴더에서 한다.
- 기능 설정은 바꾸지 않는다: `modules`(모듈 켜기·끄기), `hideblizz`, `showfriendly`·`showhostile`·`showtarget`, `showticks`, `targetname`. 시전바 담당 나눔(Quartz 가 맡는 대상의 FUF 시전바는 `DevilForever_Castbars` 가 숨김, Dominos_Cast 는 쓰지 않음)도 바꾸지 않는다.
- FUF 쪽 남는 자리: FUF 내 프레임은 자기 시전바 자리를 비워 둔 채 디버프를 그 밑에 둔다(FUF 기본 `castbarAlwaysShow`·`debuffsAnchor = "CASTBAR"` — FUF `Core/Preset.lua:38–43`). 숨긴 FUF 시전바 자리가 빈 틈으로 보이면 Phase 6 의 `fuf-profile.fragment.lua` 쪽에서 디버프 자리로 맞추는 값을 제안하고(FUF 의 `castbarEnabled` 는 바꾸지 않는다), 보고서에 적는다.

## 4. 올릴 것 (`References/codex-appearance/7/`)

- 새 폴더 `AddOns/DevilForever_Skin_Quartz/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Quartz`) — LibSharedMedia 등록과 Quartz 설정에 없는 부분만, `quartz-profile.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(고른 값, 4K 게임 화면 갈무리 경로 — 시전 중·실패/차단·차단 불가 방패를 하나씩, FUF 쪽 빈 틈 처리, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Quartz·FUF 파일 수정 0 + 3절의 기능 설정 변경 0 + `Quartz3DB`·`ForeverUnitFramesDB` 직접 쓰기 0.

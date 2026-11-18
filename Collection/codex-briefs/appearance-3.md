# Codex 외관 발주문 — Phase 3 (행동단축바 · Dominos 12.0.4)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/3/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `f89369f161b3c8f1a58905312068630aa35d138db61b1b478c5cc16e27d4cbef`) + Dominos 원본 `References/forever-addons/Dominos/Dominos-12.0.4.zip`. Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트 위에 얹는다.

## 1. 만들 것

- 바 배치·크기·간격·버튼 스킨. Step 5 설계(`Codex/docs/devil-ui-old-4k-layout.md`, `Codex/results/old-devil-layout/layout-spec.json` 의 `actionGroups`): 긴 윗줄 36×1, 중앙 아래 8×3(4×3 두 개를 붙인 꼴), 좌우 4×3 두 묶음 = 84칸, 버튼 외곽 80px(아이콘 64·여백 8·간격 2). 바 개수는 Dominos 기본값 8개 × 12칸 그대로다(Claude 기본값 파일은 바 개수를 바꾸지 않는다). 84칸에 7개를 쓰고 남는 바 8(`DominosFrame8`)은 `dominos-profile.fragment.lua` 의 `frames[8]` 에서 숨긴다(`hidden = true`) — 어느 바를 어느 묶음에 둘지는 Codex 판단.
- 태세·소환수·빙의·토템 바, 가방 바·메뉴 바·대기열 표시의 자리. 단축키 글자는 켜 둔 상태(`showBindingText = true`)이므로 글꼴·크기·위치만 정한다(4K 에서 읽히게).
- 버튼 스킨은 Masque 로 한다: Dominos 는 바마다 `Masque:Group("Dominos", <바 표시 이름>)` 로 버튼을 등록한다(`Dominos/plugins/buttonThemer.lua:59–95`). Masque 가 없을 때 쓰는 Dominos 자체 테마는 `applyButtonTheme`(기본 켬). Onyx 스킨을 쓰면 `appearance-2.md` 3절과 같이 Onyx 의 재배포 제한을 자산 목록에 적는다.

## 2. 프레임 이름 (등록 표 `registry_extra.json` 에 이미 넣음)

| key | 전역 프레임 | 편집 항목 |
|---|---|---|
| `dominos.bar1` … `dominos.bar7` | `DominosFrame1` … `DominosFrame7` | position, spacing(0–32) |
| `dominos.stance` · `dominos.pet` · `dominos.possess` · `dominos.totem` | `DominosFrameclass` · `DominosFramepet` · `DominosFramepossess` · `DominosFrametotem` | position, spacing(0–32) |
| `dominos.bags` · `dominos.menu` · `dominos.queue` | `DominosFramebags` · `DominosFramemenu` · `DominosFramequeue` | position(, spacing — queue 는 없음) |

프레임은 Dominos 가 PLAYER_LOGIN 의 Load 때 만든다. 토템 바는 주술사에서만 생긴다. `tokens` 칸은 비어 있다 — 필요한 토큰 연결은 조각 파일로 제안한다.

## 3. 값을 어디에 두나

- 위치·열 수·크기 배율·간격·빈 칸 표시(`showEmptyButtons`)처럼 Dominos 저장 값(`DominosDB.profiles[<프로필>].frames[<id>]`·프로필 칸)에 있는 것은 **값 제안 파일** `dominos-profile.fragment.lua`(Lua 표 하나, Dominos 키 이름 그대로)로 낸다. Claude 가 `Defaults/Dominos.lua` 에 넣는다(처음 한 번, 사용자 값 우선).
- 실행 중에 Dominos 함수(`SetFramePoint`·`SetSpacing` 등)를 부르는 외관 코드를 쓰면 `InCombatLockdown()` 가드와 `PLAYER_REGEN_ENABLED` 뒤 처리를 넣고, 사용자가 Dominos 설정 모드로 옮긴 값을 덮지 않는다.
- 키 배정·페이지 전환·바 개수는 바꾸지 않는다(기능 기본값 · Claude 몫).

## 4. 올릴 것 (`References/codex-appearance/3/`)

- 새 폴더 `AddOns/DevilForever_Skin_Dominos/`(TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core, Dominos`, Masque 를 쓰면 `## OptionalDeps: Masque`), `dominos-profile.fragment.lua`, `registry_extra.fragment.json`(토큰 연결·편집 항목 제안이 있을 때), `assets.md`, `report.md`(바→묶음 대응표, 고른 값, 4K 게임 화면 갈무리 경로, 남은 문제).
- 받아들이는 기준: `appearance-2.md` 4절과 같다 + Dominos 파일 수정 0.

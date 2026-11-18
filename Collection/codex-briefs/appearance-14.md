# Codex 외관 발주문 — Phase 14 (이름표 · 게임 기본 이름표)

받는 쪽: Codex. 보내는 쪽: Claude 세션. 외관 설계·판단은 Codex 에 맡긴다(R50·R53). 지켜야 할 약속(토큰으로만 값 읽기·`Edit:Get`·전투 중 보호 프레임 금지·등록으로 프레임 알리기·다른 애드온 수정 금지·V42 초기화 코드 금지)은 `Collection/codex-briefs/appearance-2.md` 2절 그대로이고, 세 겉보기 값의 꼴은 `Collection/codex-briefs/appearance-2-layouts.md` 그대로다. 게임 입력을 자동으로 보내는 도구는 쓰지 않는다.

- 결과를 올릴 자리: `References/codex-appearance/14/`. `Collection/` 은 고치지 않는다 — Claude 가 정적 대조 뒤 합친다.
- 기반: 설치 ZIP `outputs/collection/DevilForever-collection.zip`(sha256 `0ee2aca3f07fedf1b61431f6210bc5ac93fd206288f5021183ec13e9727a7e49` — `!DevilForever_Core`). Phase 2 외관 결과(`References/codex-appearance/2/`)의 토큰 세트와 세 겉보기(`References/codex-appearance/2-layouts/`) 위에 얹는다. 이름표 애드온은 넣지 않는다 — 게임 기본 이름표에 외관만 입힌다(R107 ③). 기본 이름표가 무엇을 보이는지(체력·위협 색, 시전바, 설정 항목·CVar)는 실사용 검증 `Collection/codex-briefs/phase14.md` 결과(`References/codex-verify/phase14/`)를 먼저 본다.

## 1. 만들 것

- 게임 기본 이름표(적·아군)의 체력 막대 질감·테두리·이름 글꼴·글자 크기·막대 크기를 FHD·QHD·UHD 세 겉보기마다 정한다(R107 ⑥). 크기는 `appearance-2-layouts.md` 2절 순서대로 그 해상도에서 따로 정하고 비율을 곱하지 않는다.
- 참고만: V42 `!DevilUI/Profile/Plater.lua`(Plater 자체는 V42 에 없다). 색 뜻(체력 색·위협 색)은 게임이 정한 그대로 두고 바꾸지 않는다.

## 2. 수단 — 작은 Skin 애드온

- 새 폴더 `DevilForever_Skin_Nameplates/`: TOC `## Interface: 16001`, `## Dependencies: !DevilForever_Core`.
- 값은 Core 약속으로만 읽는다: 질감·글꼴·색은 `DevilForever_Core.Theme:Get(token)`(예: `texture.statusbar`·`font.normal`·`font.number`·`border.size`), 겉보기마다 다른 크기는 `DevilForever_Core.Edit:Get(frameKey)`. 바뀜은 `Theme:RegisterCallback`·`Edit:RegisterCallback` 로 받는다(Core 는 전투 중 콜백을 보내지 않는다 — `API.lua` 머리 주석 「Callbacks」).
- 이름표는 하나의 전역 프레임이 아니라 게임이 몹마다 만드는 프레임이다. 등록 표(`registry_extra.json`)에 이름표 항목은 아직 없다. Codex 가 게임에서 이름표 프레임을 찾는 길(예: 이름표가 생길 때의 이벤트, `C_NamePlate` 함수 — 이 클라이언트에 있는지 확인 필요)을 정하고, frame key(기본 제안 `nameplates.enemy`·`nameplates.friendly`)와 편집 항목을 `registry_extra.fragment.json` 으로 제안한다. 등록 표에 넣는 것은 Claude 몫이다.
- **전투 중 taint·보호 위반 금지**: 전투 중(`InCombatLockdown()` 참)에는 이름표 바탕 프레임의 자리·크기·표시와 이름표 CVar 를 바꾸지 않는다. 그림 부분(질감·글꼴·테두리)만 바꾸고, 이것도 전투 중 이름표가 새로 생기고 사라질 때 오류를 내지 않는지 Codex 가 게임에서 본다: 몹 여럿과 싸우는 동안 BugSack 의 `ADDON_ACTION_BLOCKED`·`ADDON_ACTION_FORBIDDEN`·Lua 오류 0.
- **CVar**: 외관에 CVar 변경이 필요하면 보고서에 CVar 이름·원래 값·새 값·이유·겉보기마다의 값을 표로 적는다. CVar 는 게임 설정에 남으므로 **애드온을 끄기만 해서는 되돌아가지 않는다**. 그래서 코드는 ① 처음 바꾸기 전에 CVar 마다 원래 값을 이 애드온의 SavedVariables(TOC `## SavedVariables:` — 이름은 Codex 가 정해 보고서에)에 적어 두고 ② 우리 값은 한 번만 넣는다 — 접속할 때마다 다시 넣지 않는다(사용자가 나중에 바꾼 값은 그대로 둔다) ③ 원래 값을 모두 되돌리는 슬래시 명령(이름은 Codex 가 정해 보고서에)을 둔다. 바꾸는 일과 되돌리는 일 모두 전투 밖에서만 하고, 전투 중이면 `PLAYER_REGEN_ENABLED` 뒤로 미룬다.

## 3. 나눔 (같은 정보를 두 번 크게 보이지 않게)

| 정보 | 맡는 곳 | 이름표 쪽 |
|---|---|---|
| 시전 | Quartz (Phase 7) | 이름표 시전바가 있으면 끄거나 작게 둔다 — 판단과 이유를 보고서에. 남길지 최종 결정은 Phase 23 |
| 위협 수치 | Details 의 Tiny Threat (Phase 10) | 위협 색만 둔다. 숫자·비율을 이름표에 더하지 않는다 |
| 체력·위협 색 | 기본 이름표 (Phase 14) | 외관만 바꾸고 색 뜻은 그대로 |

Aurora(Phase 15)를 쓰기로 하면 Aurora 에도 기본 이름표 스킨 파일이 있다(`Collection/upstream/aurora-12.1.5.4/.extract-source.json:217–218`) — 두 스킨이 함께 걸리지 않는지 보고서에 적는다.

## 4. 올릴 것 · 받아들이는 기준 (`References/codex-appearance/14/`)

- `AddOns/DevilForever_Skin_Nameplates/`(TOC·Lua·자산), `layouts/fhd.lua`·`qhd.lua`·`uhd.lua` 의 이름표 frame key 값, `registry_extra.fragment.json`, `assets.md`, `report.md`(고른 토큰·값, CVar 표·SavedVariables 이름·되돌리기 명령, 나눔 판단, 세 겉보기 게임 갈무리 — 전투 중 몹 여럿의 이름표가 보이는 것 포함, 남은 문제).
- 기준: `appearance-2.md` 4절 + `appearance-2-layouts.md` 4절 + 전투 중 차단·Lua 오류 0 + 이름표 CVar 변경은 전투 밖에서만 + 바꾸기 전 원래 값이 SavedVariables 에 있고 우리 값은 한 번만 넣음 + 되돌리기 명령을 친 뒤 바꾼 CVar 가 모두 원래 값(Codex 가 게임에서 `GetCVar` 로 확인해 보고서에) + 체력·위협 색 뜻 변경 0 + 이름표에 위협 숫자 추가 0.

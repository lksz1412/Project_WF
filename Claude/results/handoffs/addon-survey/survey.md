# 기능별 상위권 애드온 조사표 (Phase 0 · R76)

- 조사 일시: 2026-11-18 01:05 UTC
- 실제로 열어 본 URL 수: **0** (페이지 본문을 확인한 URL 없음)
- WebSearch 로 받은 검색 결과 링크 수: 17 (열어 보지 못함 — 「검색 결과 목록에만 있음」으로 표기)
- 열기 실패 URL 목록 (WebFetch 시도 → 호스트 이름 해석 실패 `ENOTFOUND`):
  - https://www.curseforge.com/wow/addons/dominos
  - https://www.curseforge.com/wow/addons/sexymap
  - https://gamertagmythras.com/blog/world-of-warcraft/wow-forever-addons-guide
  - https://www.gfinityesports.com/article/8-best-curseforge-add-ons-you-need-to-install-for-world-of-warcraft-forever
  - https://warcraft.wiki.gg/wiki/Patch_1.60.1/API_changes/notes
- 실패 원인 (도구 응답 그대로): 이 클라우드 세션의 네트워크 허용 도메인 밖이거나 해석되지 않는 호스트다. 위 호스트들을 세션 네트워크 설정에서 허용해야 재조사가 가능하다. 사용자가 허용을 알리기 전에는 재시도하지 않았다.
- 셸 curl 은 쓰지 않았다(발주문 지시).

## 읽는 법

- 표의 **tier** 는 4-tier 다: 확정(페이지에서 봄 + URL) / 근거 미발견 / 추정 / 미확인.
- 이번 조사에서는 페이지를 한 장도 열지 못했으므로 **모든 행이 「미확인」**이다. 판·날짜·다운로드 수·Forever 지원 여부는 전부 미확인이다. 기억이나 추측으로 채우지 않았다.
- 「출처 URL」 칸의 「미확인(열지 못함)」은 실제 연 URL이 없다는 뜻이다. 검색 결과에만 나온 링크는 「비고」 칸에 적었다.
- 발주문의 시작점 애드온과 발주문 예시 목록은 발주문에 적힌 것을 옮긴 것이며, 이번 조사로 검증된 것이 아니다.

## 참고: 검색 결과 목록에서만 확인된 링크 (열지 않음, 근거 아님)

WebSearch 결과 제목·링크만 보였다. 페이지 본문은 열지 못했으므로 인기·갱신·Forever 지원 여부는 모두 미확인이다.

- UpQuest Forever — https://www.curseforge.com/wow/addons/upquest-forever (제목에 Forever 표기)
- Map Fix Forever — https://www.curseforge.com/wow/addons/map-fix-forever
- Darkfoxx MultiTool — https://www.curseforge.com/wow/addons/darkfoxx-multitool/files/8912127
- XE QoL Forever — https://www.curseforge.com/wow/addons/xe-qol-forever/files/8973772
- WoW XP Bar Forever Anniversary — https://www.curseforge.com/wow/addons/wow-xp-bar-forever-anniversary
- QuietUI — https://www.curseforge.com/wow/addons/quietui/files/9013423
- ClassicUI Forever — https://www.curseforge.com/wow/addons/classicui-forever/files/8928848
- GearQuest Forever — https://www.curseforge.com/wow/addons/gearquest-forever
- Easy Controller Forever — https://www.curseforge.com/wow/addons/easy-controller-forever
- WoWEUCN Plus — https://www.curseforge.com/wow/addons/woweucn-plus

(위 링크들은 검색 결과 제목 기준이다. 파일 페이지의 game version 표기는 확인하지 못했다.)

---

## 1. 전체 UI 통합 패키지 (ElvUI · TukUI · EllesmereUI · SUI · DevilUI 류)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| ElvUI | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| TukUI | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| EllesmereUI | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 시작점 외 추천 없음(검증 전). 설정 UI·profile 구조는 위 세 후보를 직접 열어 확인해야 한다. 「DevilUI」 는 발주문 명칭이며 이번에 찾은 페이지는 없다.

## 2. 행동단축바 (Dominos · Bartender4 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Dominos (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함, 호스트 해석 실패) | 미확인 |
| Bartender4 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 3. 미니맵 (SexyMap · Mapster · Basic Minimap 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| SexyMap (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함, 호스트 해석 실패) | 미확인 |
| Mapster | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Basic Minimap | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 4. 채팅 (Prat · Chattynator · Glass · BasicChatMods 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Prat-3.0 (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| Chattynator | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Glass | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| BasicChatMods | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 5. 유닛 프레임 (Forever Unit Frames · ShadowedUnitFrames · PitBull · Cell 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Forever Unit Frames (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| ShadowedUnitFrames | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| PitBull | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Cell | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 6. 시전바 (Quartz · Gnosis · ClassicCastbars 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Quartz (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| Gnosis | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| ClassicCastbars | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 7. 설정 저장·복원·profile 공유 (Reflux 류 · WowUp · Wago 류)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Reflux (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| WowUp (profile 공유 방식) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Wago (profile 공유 방식) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 8. UI 이동·편집 (MoveAnything · BlizzMove · EditModeExpanded 류)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| MoveAnything | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| BlizzMove | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| EditModeExpanded | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 9. 직업 전투보조·알림 (Hekili · WeakAuras · EventAlertMod · ProcDoc · TellMeWhen · MaxDps 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Hekili Forever (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| WeakAuras | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| EventAlertMod | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| ProcDoc | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| TellMeWhen | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| MaxDps | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 10. 재사용 대기시간 표시 (OmniCC · OmniCD · CooldownToGo 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| OmniCC | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| OmniCD | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| CooldownToGo | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 11. 공격대·파티 프레임 (Grid2 · VuhDo · Cell · Healbot 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Grid2 (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| VuhDo | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Cell | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Healbot | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 12. 데미지 미터 (Details! · Recount · Skada 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| Details! (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| Recount | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Skada | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

## 13. 어그로 미터 (ForeverThreat · ThreatClassic2 · Omen 등)

| 애드온 | 제작자 | Forever 지원 | 최근 갱신 | 인기 지표 | 특징 한 줄 | 출처 URL | tier |
|---|---|---|---|---|---|---|---|
| ForeverThreat (시작점) | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인(열지 못함) | 미확인 |
| ThreatClassic2 | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |
| Omen | 미확인 | 미확인 | 미확인 | 미확인 | 미확인 (발주문 예시 목록) | 미확인(열지 못함) | 미확인 |

참고 추천: 없음(검증 전).

---

## 미완 항목 (사용자 확인 필요)

1. 이 세션의 네트워크 허용 도메인에 `www.curseforge.com`, `gamertagmythras.com`, `www.gfinityesports.com`, `warcraft.wiki.gg` 를 추가해야 본 조사를 재개할 수 있다.
2. 허용 후 재조사 범위: 13개 기능 전부, CurseForge 파일 목록의 game version 에서 Forever / 1.60.1 표기 확인.

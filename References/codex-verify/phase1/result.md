# Phase 1 실사용 검증 중간 결과

기준 커밋은 `16b801b9f884c2675e8f58e53864d51693c81a13`이다. 2026-11-18에 파일 검증을 마쳤고 2026-11-19에 게임의 애드온 상태, 오류 창, 그래픽 설정, 직업과 특성을 확인했다.

## 0–8 결과

```text
0 | 통과 | 개인 백업은 로컬에 보관 | AddOns 최상위 폴더 수=16 | AddOns 하위 폴더 수=206 | AddOns 파일 수=1246 | WTF 하위 폴더 수=7 | WTF 파일 수=44 | 양쪽 상대 경로·종류·크기·SHA256 일치
1 | 통과 | 폴더 수=16 | 꺼짐=0 | 오래됨 표시=0 | 의존성 경고 표시=0 | 목록=References/codex-verify/phase1/addons.txt | 접속 중인 캐릭터 범위에서 전체 관측, 「구버전 애드온 불러오기」 켜짐
2 | 못 함 | 판=1.60.1(실행 파일·클라이언트 시작 로그) | 빌드=70938(실행 파일·클라이언트 시작 로그) | 날짜=미확인 | Interface=미확인 | 게임 안 GetBuildInfo 출력 미확인
3 | 못 함 | 물리 해상도=게임 API 미조회(클라이언트가 감지한 모니터 3840×2160) | 화면 단위=미확인 | useUiScale=미조회(설정 체크 꺼짐) | uiScale=미조회(설정에 비활성 100% 표시) | 실효 배율=미확인 | 창 모드=전체 화면 (창 모드) | 해상도=사용자 설정 | 렌더링 스케일=3862×2160 (100%)
4 | 통과 | 게임 직업 수=9 | 표에 없는 직업=없음 | 게임에 없는 표 직업=없음 | 특성 확인한 직업=주술사(정기·고양·복원) | 특성 이름이 다른 곳=없음(확인한 주술사 기준)
5 | 통과 | BugSack=애드온 창 체크됨(v12.1.9) | BugGrabber=애드온 창 체크됨(v12.1.1) | 창 열림=예 | 오류 수=0(사용자 보고 및 「모든 버그」 탭 화면 확인)
6 | 못 함 | TipTac=체크됨(26.11.11) | KalielsTracker=체크됨(8.11.1) | Details=체크됨(#Details.20261109.15410.172) | Mapster=체크됨(1.14.0) | 현재 BugSack 표시=0건 | 「구버전 애드온 불러오기」가 켜진 상태 관측, 실제 로드 여부 미확인
7 | 통과 | 안 함 | 파일 수=0 | 이름 지움 확인=해당 없음 | 선택 항목 미선택
8 | 못 함 | 로컬 작성 파일=result.md, addons.txt | 커밋=미생성 | 게임 내 관측 미완료, master 최종 대조·게시 대기
```

0번의 백업 생성과 당시 실제 Windows의 게임·런처 프로세스 0개 확인은 master가 앞선 작업에서 수행했다. 이번 정형 검증에서는 백업과 현재 파일을 다시 전수 대조했다. AddOns는 72,085,057바이트, WTF는 94,318바이트이며 양쪽의 누락·추가·해시 차이는 모두 0이다. 폴더 수는 각 루트를 제외한 하위 폴더 수다.

## 여섯 원본 ZIP과 설치 파일 대조

각 `SOURCE.txt`의 SHA256과 ZIP 파일 해시가 일치했고 ZIP 전체 CRC 검사와 경로 안전 검사를 통과했다. 아래 수는 압축 안 일반 파일 기준이다. 설치된 파일도 모두 비교했으며 여섯 묶음의 16개 최상위 폴더가 현재 AddOns 전체와 일치한다.

| 묶음 | 저장소 ZIP | 디스크 TOC Version | ZIP 파일 | 동일 파일 | 다른 파일 | 설치 누락 | 설치 추가 |
|---|---|---|---:|---:|---:|---:|---:|
| BugSack | `References/addon-sources/bugsack/BugSack-v12.1.9.zip` | `v12.1.9` | 25 | 25 | 0 | 0 | 0 |
| !BugGrabber | `References/addon-sources/bug-grabber/!BugGrabber-v12.1.1.zip` | `v12.1.1` | 4 | 4 | 0 | 0 | 0 |
| TipTac 4폴더 | `References/addon-sources/tiptac-reborn/TipTac-v26.11.11-release.zip` | `26.11.11` | 270 | 270 | 0 | 0 | 0 |
| Kaliel's Tracker | `References/addon-sources/kaliels-tracker/kaliels-tracker-8.11.1-forever.zip` | `8.11.1` | 188 | 188 | 0 | 0 | 0 |
| Mapster | `References/addon-sources/mapster/Mapster-1.14.0.zip` | `1.14.0` | 83 | 83 | 0 | 0 | 0 |
| Details 8폴더 | `References/forever-addons/Details/Details-Details.20261109.15410.172.zip` | `#Details.20261109.15410.172` | 676 | 676 | 0 | 0 | 0 |

16개 폴더 각각에 Interface `16001`을 포함하는 TOC가 있다. Mapster의 `Mapster.toc:10`은 `AllowLoadGameType: mainline`도 선언하므로 실제 애드온 창의 로드 상태는 미검증이다. TOC의 버전·Interface 표기는 파일 근거로 확정했으며 실행 여부는 게임에서 확인한다.

TipTac·Kaliel's Tracker·Mapster는 R100에 따라 최종 모음집에서 빠진 기능이다. 이번에는 기존 Phase 1 발주문의 현재 설치 상태만 기록했다. 여섯 묶음은 모두 이미 설치되어 있어 파일을 새로 설치하거나 덮어쓰는 작업이 발생하지 않았다.

## 접속 후 애드온 창 관측

- 상단에서 체크가 켜진 13행을 확인했다. BugGrabber, BugSack, TipTac, TipTacItemRef, TipTacOptions, TipTacTalents, Mapster, Kaliel’s Tracker, Details! Damage Meter, Details! Compare 2.0, Details! Encounter Breakdown, Details! Raid Check, Details! Storage다.
- 맨 아래까지 내려가 있던 후속 화면에서 Details!: Streamer (plugin), Details!: Tiny Threat (plugin), Details!: Vanguard (plugin)도 체크된 것을 확인했다. 상·하단의 중복 11행을 대조해 전체 16개를 확인했다.
- TipTacOptions와 Details! Storage에는 「요청 시 로드」가 표시됐다. 16행에서 오래됨·의존성 오류 표시를 관측하지 않았다. 이 결과의 범위는 접속 중인 캐릭터이며 「구버전 애드온 불러오기」가 이미 켜져 있었다. 실제 로드 여부와 구버전 허용을 끈 조건은 아직 미확인이다.
- 사용자가 열어 둔 애드온 창을 캡처해 이미지 판독과 로컬 PaddleOCR(문자 인식) 결과를 대조했다. 캐릭터명과 캡처 원본은 결과 파일에 포함하지 않았다.

## 사용자 확인과 4K 가독성

- 2026-11-19 사용자가 `/bugsack` 확인 뒤 버그가 없다고 보고했다. 이후 열린 BugSack의 활성 탭 「모든 버그」에서 「버그가 없습니다. 야호!」를 화면으로 확인했다.
- 사용자는 4K에서 퀘스트 추적기 글자를 읽기 어렵다고 보고했다. 공통 외관 작업의 4K 확인 항목에 퀘스트 제목과 목표 글자의 가독성을 포함한다. 사용자가 열거한 해상도는 FHD·QHD·UHD(4K)이며, 「4종」에서 추가할 프리셋과 4K 단독 여부는 미정이다.
- 현재 설치된 Kaliel’s Tracker에서 `/kt config`로 설정을 열고 `Options → Texts → Font size`에서 크기를 조정할 수 있다(범위 10–20). 설치본 `!KalielsTracker/Core/Modules/Options.lua`의 메뉴 정의와 도움말을 확인했다(438–440, 693–723, 1193–1202행). 적용값은 변경하지 않았다.

## 그래픽 설정과 직업·특성 확인

- 「사용자 제작 스크립트를 허용하시겠습니까?」 창은 Codex가 「아니요」로 닫았다. 그래픽 설정에서 화면 모드 「전체 화면 (창 모드)」, 해상도 「사용자 설정」, 렌더링 스케일 `3862×2160 (100%)`를 확인했다. 「UI 확대/축소 사용」은 꺼져 있었고 그 아래 100%는 회색으로 표시됐다. Windows의 주 화면 범위와 캡처 크기는 각각 2560×1440이었다.
- 2026-11-19 클라이언트 시작 로그 `_forever_/Logs/gx.log` 3·15행에서 빌드 `1.60.1.70938`과 감지된 모니터 `3840×2160 @ 60 Hz`를 확인했다. 모니터 해상도, 게임 그래픽 설정의 렌더링 크기, 화면 캡처 크기는 각각 해당 출처의 관측값이다.
- 기존 주술사의 특성 나무는 정기·고양·복원 순이다. `Collection/data/classes.md`의 elemental·enhancement·restoration과 순서 및 의미가 일치한다. 기존 캐릭터 목록에는 드루이드가 없어 야성 나무는 관측하지 않았다.
- 캐릭터 생성 미리보기에서 선택 가능한 직업 9개를 대조했다. 나이트 엘프에서 전사·사냥꾼·도적·사제·드루이드, 인간에서 전사·마법사·흑마법사·성기사, 오크에서 주술사가 선택 가능한 상태임을 확인했다. 셋을 합하면 저장소 표의 9개와 일치한다. 생성을 확정하지 않고 캐릭터 선택 화면으로 돌아왔다.

## 남은 실사용 검증

- 2번의 빌드 날짜·Interface 번호와 3번의 해상도·화면 단위·배율 변수·실효 배율은 게임 API로 조회하지 못했다. 창을 닫은 뒤 게임 스크립트는 다시 실행하지 않았다.
- 6번의 네 애드온은 모두 체크되어 있었고 관측 당시 BugSack 오류는 0건이었다. 구버전 허용 설정을 끈 조건의 상태와 실제 로드는 미확인이다.
- 2026-11-19 재확인 시 게임이 실행 중인 창을 찾지 못했고 사용자가 서버 점검 중이라고 알렸다. 이어서 접속해 확인할 항목은 2·3·6번이다.

## 읽은 범위와 실행 근거

- `Collection/codex-briefs/phase1.md:1–75`, `Claude/results/REQUEST_LEDGER_phase8.md:1–21` 전문을 읽었다.
- `Collection/data/classes.md:1–47`을 읽고 그래픽 설정, 특성 창, 종족별 미리보기 및 복귀 화면의 캡처를 로컬에서 대조했다. 그래픽 값, 직업·특성 이름은 이미지 판독과 PaddleOCR 결과가 일치했다.
- `feedback_full_file_read_required.md:1–57`, `feedback_confirmed_items_policy.md:1–62` 전문을 읽었다.
- 여섯 ZIP 폴더의 `SOURCE.txt:1–7`을 각각 전문으로 읽었다.
- 설치 AddOns 아래의 관련 TOC 전문을 읽었다. `BugSack/BugSack.toc:1–50`, `!BugGrabber/!BugGrabber.toc:1–33`, `TipTac/TipTac_Forever.toc:1–37`, `TipTacItemRef/TipTacItemRef_Forever.toc:1–25`, `TipTacOptions/TipTacOptions_Forever.toc:1–27`, `TipTacTalents/TipTacTalents_Forever.toc:1–25`, `!KalielsTracker/!KalielsTracker.toc:1–17`, `Mapster/Mapster.toc:1–57`.
- Details 관련 TOC 전문을 읽었다. `Details/Details_Camelot.toc:1–229`, `Details_Compare2/Details_Compare2_Camelot.toc:1–7`, `Details_DataStorage/Details_DataStorage_Camelot.toc:1–10`, `Details_EncounterDetails/Details_EncounterDetails_Camelot.toc:1–19`, `Details_RaidCheck/Details_RaidCheck_Camelot.toc:1–9`, `Details_Streamer/Details_Streamer_Camelot.toc:1–10`, `Details_TinyThreat/Details_TinyThreat_Camelot.toc:1–14`, `Details_Vanguard/Details_Vanguard_Camelot.toc:1–11`.
- Python 표준 라이브러리 `pathlib`·`os.walk`·`hashlib.file_digest`로 양쪽 상대 경로·종류·길이·SHA256을 전수 비교했다. `zipfile.ZipFile.testzip()`으로 CRC를 검사하고 ZIP 내 경로·중복·심볼릭 링크를 검사했다. 설치 폴더의 TOC 76개는 기계로 메타데이터를 읽었으며 위 16개를 전문 정독 근거로 사용했다. PowerShell `Get-Item`의 `VersionInfo`로 Wow.exe 버전을 읽었다.

## 자체 확인

결과 행 0–8, 설치 파일 합계 1,246개, 백업 파일 합계 1,290개, 여섯 원본 ZIP과 파일 비교 수치, 게임에서 확인한 값과 미확인 값을 대조했다. 작성한 결과물은 `addons.txt`와 이 문서 두 개다. 게임 설정은 그대로 두었다. 계정·캐릭터·서버 이름과 WTF 내부 경로·내용을 결과에 수집하지 않았다.

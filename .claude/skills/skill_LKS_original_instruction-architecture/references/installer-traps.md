# 참조 — 언어별 설치기 킬러

`SKILL.md` §9 설치기 계약의 하위 참조. **계약(재사용 규칙)은 §9에, 여기엔 언어·플랫폼 고유 킬러와 개별 사고.** 커스텀형 플러그인은 설치기를 자기가 소유하므로(§10) 그 소유물의 알려진 지뢰 목록도 스킴의 일부다. 근거 태그: `A L##`=transcript 대장 · `C L##`=committed 대장 — **두 대장은 개발 저장소에만 있고 배포본에 포함되지 않는다**(태그는 개발 이력 추적용 표시일 뿐 읽는 쪽이 열어볼 대상이 아니다).

## PowerShell / Windows 고유

- **`"메시지"; $false` 가 배열로 truthy** → 실패가 통과로 둔갑. 반환은 단일 bool로(C L69).
- **PS5.1 `Get-Content` 기본 인코딩이 UTF-8 아님** → BOM 없는 파일의 화살표(`→`) 깨져 포인터 0건 → "전건 해소" 오탐(C L70).
- **EAP=Stop 아래 외부 명령의 `stderr` 는 `2>&1` 이든 `2>$null` 이든 PS 5.1 이 `NativeCommandError` 로 바꾼다**(try 밖이면 설치 중단 · 모듈 하나 빠진 PC 의 `python -c "import …" 2>$null` 사전 확인이 그대로 멈춤 · pwsh 7 은 재현 못 함) → 외부 명령은 EAP 를 내린 감싸개(`Invoke-Native` · 성패 = 종료 코드) 안에서만 부르고 감싸개 밖 외부 명령 0 을 정적 검사로 잠근다(C L94 · 공유 PC 설치 실사례).
- **`.ps1`은 BOM+LF, `.md`는 BOM 없이.** `Set-Content -Encoding UTF8`은 5.1에서 BOM을 붙이므로 `Copy-Item`/`[IO.File]::WriteAllText` 사용(PS5.1 cp949 한글 깨짐, C L95).
- **Windows 파이프 캡처 시 Python stdout=ANSI(cp949), 콘솔 CP 아님** → `& python …` 로 출력을 파이프 캡처하면 Python 은 `chcp 65001` 콘솔 CP 가 아니라 시스템 ANSI(한국어=cp949)로 stdout 을 인코딩한다 → `—`(U+2014) 등 cp949 밖 문자에서 `UnicodeEncodeError` 크래시 → verify 가 무결성 FAIL 로 오계수(cp949 콘솔 Windows 설치 verify 실사례). **표준 가드**: 패키지 자체 CLI 도구는 import 직후 `for _s in (sys.stdout, sys.stderr): try: _s.reconfigure(encoding="utf-8")`(+win32 `SetConsoleOutputCP(65001)`)로 UTF-8 를 못박는다. 훅(BADA_recall)엔 있었으나 나머지 도구에 전파 안 돼 재발 → `check_win_encoding.py` 게이트가 tools/·setup/ 전수 강제(sync `--check`). ps1 소비자는 자식 출력을 UTF-8 로 디코딩(`[Console]::OutputEncoding=UTF8`). 계열 근본차단 = 개별 패치 아닌 표준+게이트.
- **`.msi`를 `Start-Process -FilePath`로 주면 `/i` 이중** → `msiexec` 1639 death → `msiexec` 직접 호출(C L96).
- **런타임 `throw`가 설정·rule·스킬 설치까지 중단** → `try/catch`. `Test-Admin` 선판별. exit 3010을 성공으로 오계수 말 것(C L97).
- **Windows Store 앱 별칭 `python.exe`가 PATH에 있어 `Get-Command`엔 보임** → 존재가 아니라 **버전 출력**으로 판정(`Get-PythonVersion`, C L89).
- **`winget`은 기업망 소스 차단·Store 팝업 부작용** → 공식 배포처 binary 직접(C L103).
- **`Add-Member -Force`가 사용자 hooks를 통째 덮음**(settings 병합 클로버). install.ps1이 원래 이 이유로 hooks를 제외했었다 → hooks union 병합으로(A L140).
- **PS5.1: `param()` 기본값 안의 `$PSScriptRoot` 는 빈 값일 수 있다.**
- **단일 PSCustomObject 에는 `.Count` 가 없다** → `@()` 로 감싼다.
- **`Get-Command` 는 여러 개가 맞으면 배열을 돌려준다** → 후보마다 따로 확인한다.
- **PowerShell 문자열 안의 `\"` 는 이스케이프가 아니다.**
- **bat 종료 코드 검사 = `if %errorlevel% neq 0`.**

## POSIX / 크로스-플랫폼

- **`cp tools/*.py`가 비-py 자산(예 `pptx_lint.js`) 누락** → `find ! -name '*.ps1'`로 포괄(C L99).
- **CRLF 오염이 설치 스크립트를 깨뜨림** → `.gitattributes` LF 고정, zip 복사물은 `^M` 검사(C L101).
- **non-UTF8 locale에서 한글 byte-grep 깨짐** → Python `utf-8` 추출(A L144).
- **인터프리터만 OS별 분기**(POSIX `python3` baseline / Windows 설치기가 `python` 치환) — 나머지 훅 본문은 공용(A L141·C L88).

## 설계·편집 규율

- **인스톨러가 절대경로 매핑표(21행)를 생성하지 마라** — USERPROFILE 공백·한글·OneDrive·기계간 이동에 깨져 새 표류 → **홈앵커 규약 1줄**(`memory:feedback_<주제>`→`~/.claude/BADA_HUB/feedback_<주제>.md`). master 과잉설계를 감사가 죽인 사례(A L131).
- **BOM 파일 편집 도구 규율**: `sed -i`가 BOM+LF 보존하는지 **사본서 먼저 검증** 후, 대량 순수삭제는 sed(아래→위 역순), 리네임은 Edit(A L138).
- **절 삭제 후 번호 재정렬 필수** — "5.연동" 삭제 후 6→5 재번호 + stale 주석 청소(A L139).
- **Profile/제외 배열을 스킬명 접두째 하드코드 금지** — 폴더 리네임 시 제외가 무력화되어 방법론이 조용히 설치됨(A L136).
- **Windows 앱에서 MCP 서버 기동 타임아웃** → `settings.json` 의 `env.MCP_TIMEOUT=60000`(C L102).
- **VSCode 확장 세션은 도구·스킬 목록을 세션 시작 때 고정한다** → 새 MCP 도구를 설치한 뒤 Reload Window 와 새 세션에서 로드한다(다른 세션·headless 실행으로도 확인할 수 있다).
- **훅 등록 점검과 설치 판정은 같은 기준을 쓴다**(phase 별 · 대소문자 무시 · 슬래시 양방향).
- **`settings.json` 병합은 백업 뒤에** — 병합은 사용자 항목을 지우지 않고(append-only) 멱등이다(위 hooks union 병합 · 아래 전 이벤트 sweep).

## 훅·파일 소유 식별 (UID 소유 모델)

설치 산출물의 "우리 것" 판정은 **두 축**이다 — 위치가 다르기 때문이다.

- **파일**(스킬·memory·커맨드·도구·서브 정의[agents]·CLAUDE.md) = 통째로 우리가 놓는 파일 → **외부 등록부** `.bada_manifest`(header `version` + `pkg_skill`/`bh`/`command`/`tool`/`agent`/`file` 목록)로 소유 추적. 재설치 = 지난 매니페스트 − 이번 설치집합 diff prune(rename·드롭 회수) + 레거시 `LKS_*`/`BH_LKS_*` sweep. 서브 정의(`agent`)는 스킬·커맨드와 같은 백업-후-덮기·매니페스트 회수 규약을 따른다. **사용자 표면 마크다운에 in-content UID 를 박지 않는다**(오염·frontmatter 스키마 위험) — 소유는 out-of-band 등록부가 맡는다(모든 패키지 매니저 방식).
- **훅** = 파일이 아니라 **사용자 공유 `settings.json` 에 병합되는 줄** → 매니페스트가 라인 단위로 못 잡는다. 그래서 명령 안에 **불변 소유 센티널** `_BADA_HOOK='<이름>@<버전>'`(예 `caveman@1`·`recall@1`)를 심는다. `_is_pkg_hook` = 센티널 `_BADA_HOOK=` prefix 매칭(+레거시 파일명 보조). **내용 해시가 아니다** — 훅 명령은 interp(`python`/`python3`)·경로로 정당하게 변하므로 해시로는 자기 훅을 놓친다.
- **전 이벤트 sweep**: `merge_settings.py` 는 소스 이벤트만이 아니라 사용자 설정의 **모든 이벤트**에서 pkg 훅을 걷어낸다 → 소스에서 폐기·드롭된 이벤트(1.1.8 폐기 `UserPromptSubmit` BADA_recall 유령)까지 정리(실배포 Windows 설치 verify 1-FAIL 실사례). 사용자 훅·env 보존, 우리 훅 정확히 1건(멱등).
- **버전 다이제스트 레지스트리**: `digests/<ver>-full.json`(단일 구성 · `gen_file_digests.py` 가 생성 · 명명 `-full` 은 1.2.1/1.2.2 이력 연속성)이 설치 verbatim 파일의 **개행 정규화 sha256** 을 `files{경로:{sha256, version?, updated?}}` 로, 훅 센티널 버전을 `hooks{이름:버전}` 로, 릴리스 날짜를 `date`(CHANGELOG 단일 출처)·프로파일 라벨을 `profile`(`"full"`) 로 담는다. **버전마다 파일이 누적**돼 그 자체가 버전 대장이다. 제외(구조·스탬프 검사가 커버): CLAUDE.md(인라인 스탬프 줄로 식별) · MEMORY.md(색인 · sync 미러·refcheck 로 커버) · settings.json(병합·interp·센티널) · `.ps1`(Windows 전용). install 이 `digests/` 를 `~/.claude` 에 심고, verify·`check_file_digests.py`(stdlib·크로스플랫폼)가 **전 레지스트리와 대조해 버전을 자동 식별**(동률 → 미설치 적은 쪽 → 높은 버전)한 뒤 매칭 레지스트리 기준 **원본(PRISTINE)/수정본(MODIFIED)/불완전(INCOMPLETE=누락)** 을 판정한다 — 레지스트리 기준 정상 결번은 0·**진짜 누락만 불완전**으로 잡힌다(레거시 compact 레지스트리도 자기 집합 기준 식별). 개행 정규화라 Windows autocrlf(CRLF)↔Linux(LF) 오탐 0·내용 변조엔 민감.
- **provenance 스탬프(우리 저작 지침만)**: 우리 저작 지침(CLAUDE.md·memory·우리 SKILL.md)은 본문에 `version`(마지막 실질수정 버전) + `updated`(최종수정일) 를 박는다 — memory·skill 은 frontmatter, CLAUDE.md 는 상단 1줄 · 언제 무엇을 올리나 = `SKILL.md` §14 원칙 7 갱신 규칙이 원본. 이건 소유 UID 가 아니라 **사람이 읽는 이력**이라 본문에 둔다(소유 식별은 위 매니페스트·센티널이 맡음 — 두 메타는 별개). **번들 공식 스킬 등 외부 저작엔 스탬프를 박지 않는다**(출처 왜곡 방지 · 단 digest 레지스트리엔 무결성용으로 포함). 스탬프 순서는 강제 — **① 지침에 스탬프 → ② 스탬프된 완성본을 digest·센티널로 취합 → ③ JSON 기재**(뒤집으면 설치본이 전부 MODIFIED).
- **드리프트 게이트**(이 줄이 게이트 설명의 원본): 패키징 시 `gen_file_digests.py --gate`(sync `--check` 가 함께 호출 · FAIL 이면 `--check` 도 실패) 가 **직전 버전 레지스트리와 대조** — 달라진 파일을 전수 보고하고, 내용이 바뀐 stamped 지침(헌법은 상단 스탬프 줄)의 `updated` 가 **이번 릴리스일(CHANGELOG 헤더 날짜)보다 과거**이거나 스탬프가 사라졌으면 **FAIL**("바꿨는데 스탬프 안 올림"). 못 잡는 자리: ① 같은 버전 라인 안에서 `updated` 를 이미 릴리스일 이상으로 올린 뒤의 재편집(사각 — 저자가 직접 올림) ② CHANGELOG 에 그 버전 헤더가 아직 없으면 릴리스일이 `0000-00-00` 이라 날짜 대조가 사실상 no-op(스탬프 삭제만 잡힘) ③ 첫 레지스트리(baseline) 버전엔 직전이 없어 no-op·다음 버전부터 실효. provenance 스탬프 줄만 고친 정정은 `updated` 를 올리지 않으므로 sha 는 바뀌고 `updated` 는 과거 날짜로 남아 그 버전 동안 FAIL 로 남는다(의도된 advisory-red — 날짜를 위조해 없애지 않는다 · 매니페스트 버전 bump 시 해소).
- **갱신 규율**: 버전업·파일 변경 시 소유 UID 최종값을 함께 갱신 — 매니페스트 `version`(원본 = `module.json` `version` 한 곳) + `digests/<ver>-full.json` 재생성(sync 자동 · `--check` 표류·게이트 강제), 훅 계약 변경 시 센티널 `@버전`. 지침 스탬프(`version`·`updated`) 갱신 규칙 원본 = `skill:skill_LKS_original_instruction-architecture` §14 원칙 7(절차 = 같은 §14 완료 게이트). 패키징은 스탬프를 재작성하지 않고 취합만 한다.

## 이 컨테이너의 검증 경계

- POSIX 설치기는 이 Linux 컨테이너서 `install→verify→uninstall` **실행 검증 가능**(이연 아님).
- `.ps1` **구문·로직·개행·.NET regex·헬퍼 동작은 이 컨테이너에 pwsh 7 설치해 실측 가능**(실증) — PS 5.1 **고유** 런타임 동작·PPT COM 렌더 게이트(gate2)·negtest 라이브·훅 라이브 작동만 **실배포 Windows 환경 이연**(A L143·C L110). 단순 컨테이너 Read 통과를 "확정"으로 마킹 금지 — pwsh 실측 또는 배포 OS 실측 전 "확정" 금지(A L132).

## 격하·통폐합 업그레이드 함정 (P7 감사 · 1.2.4 후보)

컴포넌트를 최상위에서 하위(references/)로 격하하거나 스킬을 삭제·통폐합할 때, **구 설치본 회수**가 정상 경로(매니페스트 기록 있는 1.2.1+ 설치)에선 완전하나 아래 비정상 경로에서 불완전하다. 코드 수정은 1.2.4 후보(정상 경로는 무해)이나 함정으로 등재한다.

- **user_skill 이름충돌 × 다단 업그레이드.** 사용자가 격하 대상과 동명(예: `hook-development`)의 자기 스킬을 가졌던 경우: (a) 다단 업그레이드(1.2.1→1.2.2→1.2.3)에서 `user_skill` 마커가 중간 매니페스트 재작성 때 소실될 수 있어(설치 루프가 현재 패키지 스킬만 재기록 · `install.sh:145-149`·`install.ps1:646-651`) 후속 prune 이 그 이름을 회수 → 사용자 원본은 최초 충돌 백업에만. (b) 직전 설치서 `user_skill` 마킹된 경우 prune 은 스킵하나, 디스크에 남는 건 사용자 원본이 아니라 **직전 패키지 사본**(설치가 덮어씀)이라 격하가 그 이름에 한해 무효·이후 매니페스트 미기재로 uninstall 도 못 걷음. → 후보: "패키지가 비운 이름 + user_skill 표시 → 백업에서 사용자 원본 복원" 경로.
- **매니페스트-리스 구설치.** `.bada_manifest` 없이 최상위 격하대상/삭제스킬이 남은 설치(수동 복사·매니페스트 삭제)는 prune 대상 0 · 레거시 sweep 은 `LKS_*`(prefixless)/`BH_LKS_*` 패턴이라 일반명 번들·`skill_LKS_original_*` 삭제스킬을 못 잡음 · verify 는 `>=` 비교(`verify.sh:40`·`verify.ps1:164`)라 침묵 PASS → 구 스킬이 신 소재(§14·references/bundle)와 병존·표류. → 후보: verify 에 "기지 격하·삭제 이름의 최상위 잔존"을 정보성 경고 1줄(사용자 동명과 구분 불가라 경고까지만).
- **Windows(install.ps1) prune 런타임 미실측.** upgrade-prune 시뮬은 POSIX(`install.sh`)만 실측(회수 9/9)·`install.ps1` 은 pwsh7 PARSE_OK 까지 — 실배포 Windows 검증 목록(G-PKG)에 "1.2.2→1.2.3 업그레이드 시 격하 9종 회수 실측"을 명시.

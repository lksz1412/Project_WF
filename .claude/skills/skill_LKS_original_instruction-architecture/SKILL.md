---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_original_instruction-architecture
description: >
  Claude Code 지침·설정 기전(auto-memory·native rules·CLAUDE.md·skill·command·hook·plugin·settings)의
  로드·저작·토큰·작동·함정 지도, 그리고 그것들을 하나로 묶어 "상시 헌법 + 상시 지침 memory" 같은 커스텀형
  플러그인을 저작·수정·검증·배포·업그레이드·제거하는 스킴. 새 지침을 어디에 둘지(memory냐 rule이냐 skill이냐
  hook이냐), memory 운용체계·MEMORY.md 색인·위키링크·저작·분할, 원본/사본·2버전 설치기, 공식 플러그인을 쓸지
  직접 지을지, 플러그인 구성물(스킬·훅·커맨드·설정) 저작 시 8종 공식 번들 문법 가이드(hook-development·
  skill-creator·plugin-structure 등 · references/bundle/ 경로 Read)+우리 오버레이(§13)를 함께 볼 때 쓴다.
  §14는 지침 개정 SOP를 겸한다 — 지침 상충 해소·버전업·재배치(memory↔rule↔skill↔hook), 개별 스킬·memory
  안전 제거·교체, 이 패키지(설치기·도구·게이트·덱) 수정·보완·유지보수 전반의 표준 절차: 원문 독립 확보·불신본
  근거화 금지, 규범 원본 단일화, 옳은/틀린 조각 분리 커밋, 누락 금지(소명 없는 삭제=FAIL), 소유 UID·완료 게이트.
  트리거: '지침 어디에 넣어', '이거 rule이야 skill이야', 'memory 운용체계', '상시 memory', '포인터/링크',
  '설정 패키지', '플러그인 만들', '스킬 작성', '훅 작성', '커맨드 작성', '원본 사본', '지침 운용체계',
  '지침 개정', '지침 상충', '버전업', '컴포넌트 제거'.
metadata:
  type: method
---

# 지침 운용체계 — 커스텀형 플러그인 저작 스킴

Claude Code 지침을 "어떻게 조직하고 하나의 배포 단위로 묶는가". 목적물이 아니라 **기전(mechanism)** 과 **번들 형상**이 대상이다 — 어떤 지침 그릇이 있고 각각의 진짜 성격(특히 함정)은 무엇이며, 그것들을 엮어 **커스텀형 플러그인**(§10)을 지을 때 무엇을 어느 폴더에 담아 어떻게 짓고·고치고·검증하고·내보내고·올리고·지우는가.

## 왜 — 지식이 아니라 준수·배치의 문제다

구조 지식이 문서에 다 있어도 실패는 그 지식을 안 지키거나(C3·C4) 기전을 잘못 골라서 난다. 그래서 이 스킬의 본체는 배치표가 아니라 **실패 모드를 강제로 막는 가드레일**이다.

- **C3** 재독 규칙을 배포본에만 → 활성 설정에 없어 강제력 0. **C4** 스킬을 저장소 낡은 사본으로 Read → 6조항 누락. **기록 0** → 같은 지적 3회 반복.
- 메타 교훈: **증상 말고 타입을 고쳐라.** 설치기 인코딩 버그(`.`·공백→`-`)는 표면 증상, 진짜 원인은 "전역 지침을 cwd-keyed auto-memory 통에 넣은 설계 자체". 인코딩만 패치(C안)=반창고.

---

## 0. 커스텀형 플러그인의 형상과 라이프사이클 (골격 먼저)

우리가 만든 것도 **플러그인**이다 — 단어 뜻대로. 다만 마켓플레이스에 올리는 **정통(마켓플레이스형)** 이 아니라, always-on 헌법 + 상시 지침 memory를 별도 설치기로 배포하는 **커스텀형**이다(§10). 범주를 "설정 뭉치"로 잡으면 **번들 형상·배포 계약·제거 계약**을 설계 대상으로 인식하지 못한다. 그러니 형상과 라이프사이클을 먼저 못 박는다.

**(가) 형상 — 무엇을 어디에.**

| 컴포넌트 | 원본(패키지 루트 기준) | 설치 위치(`~/.claude/`) | 비고 |
|---|---|---|---|
| 헌법(명령 인덱스) | `global/CLAUDE.md` | `CLAUDE.md` 전문 복사(백업 후 덮어씀) | 상시 전부 |
| settings | `global/settings.json` | `settings.json`(dict 병합·hooks union) | **통째 덮기 금지** |
| 지침 memory 원본 | `global/BADA_HUB/feedback_<주제>.md` (+색인 `MEMORY.md`) | 루트 BH `~/.claude/BADA_HUB/`(전 PC 공용 원본) → 세션시작 훅이 프로젝트 native 메모리 `~/.claude/projects/<slug>/memory/`에 확보(다이제스트 구동: 없으면 설치·바뀌면 갱신+prune·같으면 침묵) | **비예약** 폴더(예약 `rules/` 회피) · CC가 색인 상시+본문 on-demand native 로드 · native=**순수 파생 캐시**(개인화는 auto-memory·프로젝트 로컬이 우선, 갱신이 안 건드림) |
| skill | `skills/<name>/SKILL.md` | `skills/<name>/` | `name==folder` 런타임 불변식 |
| command | `commands/<name>.md` | `commands/` | opt-in |
| 서브 정의(agents) | `agents/bada-<역할>.md` | `agents/`(동명은 백업 후 덮음 · 매니페스트 기록) | frontmatter 가 모델·effort 를 고정 · 설치 뒤 새로 시작한 세션부터 읽힘 · 호출 = `subagent_type`(분업 스킬 「모델·effort 지정」) |
| **skill-결합 훅** | 그 skill의 `hooks/` 안 | 스킬과 **한 단위로 이동** | 예: caveman. SessionStart면 하드코딩 요약 말고 sibling SKILL.md 본문 주입(drift 방지) |
| **횡단 훅** | `tools/BADA_recall.py` | `tools/` | 한 스킬에 안 매임(예: 세션시작 native 메모리 다이제스트 구동 확보·갱신·prune·색인 주입[토글]·컴팩션 복구 주입) |
| 검증 스크립트 | `tools/`(refcheck·sync·recall_test) | `tools/`에 함께 설치됨 | 개발·검증용(런타임 무관). 설치기가 tools/ 전체 복사 → 홈에도 들어감(위생상 배포전용 분리 여지) |
| 설치기 | 모듈 진입점 `setup/module_*.ps1`(PS)·`setup-posix/module_*.sh`(POSIX) + 이 진입점을 부르는 통합 설치기(공용 층 `Settings_Installer/`) | — | 2버전, 병합은 공용 python |
| 사본 | `.claude/`(sync 생성) | — | **직접수정 금지** |
| 백업 | — | `~/.claude/.backups/` | `skills/` **밖** 격리(두 벌 로드 방지) |

**★ 형상 불변식**: settings.json은 훅을 **bare 경로**로 물므로, 스킬·도구 폴더를 리네임하면 settings의 경로·`name==folder`·`memory:` 포인터가 **같은 커밋에 함께** 안 바뀌면 매 세션 훅 실패·포인터 사망. 폴더 하나 바꾸면 연계 전부 따라 바뀐다.

**★ 헌법 설치 = 전문 복사 vs marker-`@import`.** 우리 설치기는 `~/.claude/CLAUDE.md`를 **전문 복사**(백업 후 덮어씀)한다 — 사용자가 그 전역 파일을 따로 안 쓴다는 전제. 사용자 전역 CLAUDE.md를 보존해야 하면 **마커 블록 안 `@import` 1줄**(멱등·원자 제거)이 더 안전하다. 배포 대상 환경에 맞춰 고른다.

**(나) 라이프사이클 6단계 + 완료 조건.**

| 단계 | 완료 조건 | 절 |
|---|---|---|
| ① 저작 | 배치 5단계 + **상시 memory 확보** 판정 | §2 |
| ② 수정 | 원본 `components/`만 · sync 재생성 · `--check` 표류 0 · 연결된 곳 전수 전파(정독으로 찾음) | §7 |
| ③ 검증 | 검증 삼각 + **0건=FAIL** 가드 + 회귀 재주입 | §8 |
| ④ 배포 | **재설계의 존재이유가 설치본에 있는가** + 배포 위생(개인 잔재 전수 제거, 설계근거는 보존) | §7 |
| ⑤ 업그레이드 | 이중로드·**매니페스트 기반 prune**(구버전 설치목록 − 신버전 = 삭제)·교차-interp 이중등록·구 확장자 등록 잔존 점검 | §9 |
| ⑥ 제거 | uninstall이 **훅 등록까지 해제** · 폴더 통째 `rm` 금지 · **매니페스트 기반 회수**(우리가 설치한 것만·사용자 동명 자산 보존) · 상태·캐시 파일 회수 | §9 |

⑥은 특히 잊힌다. 잔존 훅은 계속 작동하므로 **제거 실패가 곧 다음 세션의 먹통** — §6과 정확히 같은 축이다.

---

## 1. 지침 기전 지도 (★함정 열이 알맹이)

| 기전 | 로드 | 저작 의미 | 토큰 | 작동 | ★함정 |
|---|---|---|---|---|---|
| **auto-memory** `~/.claude/projects/<프로젝트 키>/memory/` | 상시(그 프로젝트) | **Claude 자기노트** | 상시 | 프로젝트 매칭(git 저장소면 최상위 — 하위 폴더·워크트리가 한 폴더를 함께 씀 · 저장소 밖이면 그 폴더) | 사용자 저작=오분류 · **경로 인코딩**(`.`·공백→`-`) 로드 끊김 · 옛 인스톨러가 여기 덮어써 Claude 자기노트를 밀고 있었다 |
| **native rules** `~/.claude/rules/` | **상시 전부(eager)** | 사용자 | **상시** | 항상(paths 없으면) | **예약 폴더=조건부 불가.** 매칭은 정확한 디렉터리명 `.claude/rules/`(부분열 아님 → `BADA_HUB`는 안 걸림) |
| **CLAUDE.md 헌법** | 상시 전부(`@import` 체인) | 사용자/프로젝트 | 상시 | 항상 | 상세 다 넣으면 상시 예산 폭증 · 공식 권고(200줄)를 넘기면 **각 지시 준수율 저하**(LLM 성질 · 공식 "Files over 200 lines consume more context and may reduce adherence") → 상세는 원본으로 뺀다 · 줄일 때는 앞뒤 대조로 뜻·조건 누락 0 인 것만(§14 원칙 6) |
| **skill** `skills/*/SKILL.md` | 트리거 시 | 사용자 | 트리거만 | `description` 매칭 | **완전 고정 절차층** → 적응 가능해야 할 지침엔 부적합 · 트리거는 `description` 안에(별도 키는 안 걸림) |
| **command** `commands/*.md` | 명시 호출 | 사용자 | 호출만 | `/name` | 조건 매칭 X(opt-in·상태전환 전용) |
| **hook** `settings.json` 등록 | 무조건(이벤트) | 사용자 | 매 이벤트 | 이벤트 | 죽으면 **세션 먹통** · OS 특정이면 잘못 깔려 죽음(§6) · 실행 자체는 토큰 0 |
| **plugin** `.claude-plugin/` | 설치 시 | **외부** | 구성 따라 | `claude plugin install` | **자기 CLAUDE.md를 context로 못 실음**(공식 명문·§10) → 헌법은 정통 플러그인으로 못 배포 |
| **settings.json** | 상시 | 사용자 | — | 항상 | 통째 덮으면 사용자 훅·env 소실(§9) |

**★ 전부 상시 memory + always-on 헌법 인라인 포인터 (단일 tier).** 지침 memory는 전부 상시층이다 — 상시형/상황형으로 나눠 조건부-Read를 씌우지 않는다. always-on 헌법이 각 지침을 인라인 `memory:` 포인터(backing 참조 이름)로 상시 참조하고, 세션시작 훅이 memory 실물을 프로젝트 native 메모리(`~/.claude/projects/<slug>/memory/`)에 복사한다(§3). **늘 실리는 것은 색인뿐이다** — 색인은 표면에 따라 native 로드 또는 훅 주입으로 매 세션 실리고, 본문은 모델이 Read 할 때만 실린다(공식 `code.claude.com/docs/en/memory` 「Claude Code doesn't load topic files … at startup. Claude reads them on demand」) — 그래서 매 응답에 걸려야 하는 규칙의 집행 요지는 헌법 줄에 둔다(§2 4·5). 단 **인덱스 한 줄은 양날**이다: 색인이 실려 있어도 인덱스·포인터를 본 모델이 "충분히 안다"고 오인해 **원본 Read를 오히려 억제**할 수 있다(§0 "안다고 판단하기" 함정) → 포인터를 만나면 요약·기억 대체 없이 전문 Read가 규범(헌법 §0-A).

**로드 원리(플랫폼 의존)**: 상시 파일은 플랫폼마다 **줄 수·바이트·문자**로 계측된다(CC·Cursor <200단어·Hermes 문자상한 등 플랫폼차). 상시층 모양(세미콜론 인라인·한 규칙=한 bullet)은 대개 하드 상한이 아니라 **신호를 진하게** 하려고 새로 넣는 문장을 그 모양으로 쓰는 것이다 — 이미 있는 문장을 줄이는 근거가 아니다. 공식이 준수율을 드는 문장("Longer files consume more context and reduce adherence" · "Files over 200 lines consume more context and may reduce adherence")도 공식 권고치(200줄)를 넘을 때 줄이는 이유다. **CC 는 공식 하드/권고 상한이 실재하므로**(아래 「공식 로드 한계」) 우리 self-impose 는 그 공식치에 정렬하고(구 임의값 폐기), 줄이는 것은 §14 원칙 6 의 무손실 대조를 통과한 것만이다. 헌법에 상시 실리는 것은 각 지침의 인라인 bullet(집행 요지)뿐이고 skill·memory **본문은 포인터 Read 시점 로드**라 상시 예산엔 인덱스 줄만 든다(전부 상시라도 본문이 상시 예산을 먹지 않는다). (수치는 시점에 따라 변하니 본문에 절대값을 하드코딩하지 말고 동적 카운트로 — §8 자기 조항.)

**★ 공식 로드 한계 (4종 · 2026-09 실측 · 2026-11-16 다시 확인 · `tools/check_line_budget.py` 강제).** 임의값(구 36,000B/20,500자)이 아니라 **공식 문서가 명시한 수치만** 강제한다:

| 대상 | 공식 한계 | 왜 그 대상 |
|---|---|---|
| **CLAUDE.md · rules** | **4 MiB 초과 = 통째 스킵**(하드) · **<200줄**(권고 — 넘으면 준수율↓ · 공식 "Files over 200 lines … may reduce adherence") · 필요할 때 실리는 하위 폴더 CLAUDE.md·rules 는 파일당 글자 한도(200K context = 40,000자)를 넘으면 앞부분만 실린다(공식 「Claude ignores the end of my subdirectory CLAUDE.md」 · 게이트 값은 그대로) | 매 세션 전문 로드(rules 는 CLAUDE.md 동급 우선순위) |
| **memory 색인 `MEMORY.md`** | **first 200줄 or 25KB**, 초과분 드롭(하드) | 세션시작 훅이 매 세션 주입 |
| **skill `name` / `description`** | **≤ 64 / ≤ 1024 "characters"** (= 유니코드 코드포인트 · **한글도 1자=1**, UTF-8 바이트 아님) — Platform API 규칙(name 은 소문자·숫자·하이픈만 · 예약어 `anthropic`·`claude` 금지) · Claude Code 목록은 description+`when_to_use` 를 1,536자에서 자른다 | 스킬 메타(name·desc)는 항상 로드 |

- 근거: CLAUDE.md·memory·rule = `code.claude.com/docs/en/memory` · skill = `platform.claude.com` Agent Skills overview·`api/beta/skills`(1,024·64 · name 글자 규칙) · Claude Code 목록 자르기 = `code.claude.com/docs/en/skills`(frontmatter 표 `description` · 우리 `skill_LKS_…` 이름의 대문자·밑줄은 Platform 규칙엔 안 맞고 Claude Code 는 받는다). 단위(코드포인트 vs 바이트)는 문서 미명시 → API/JSON "characters" 관행 + 실증(패키지 내 852 코드포인트/1601 바이트 스킬이 무절단 실재)으로 **코드포인트** 확정.
- **온디맨드는 캡 밖**: skill 본문(SKILL.md body)은 "under 5k tokens"(권고)·번들 리소스 "no practical limit" · memory 본문 `feedback_*.md` 도 온디맨드 → 셋 다 상시 예산 밖이라 하드캡 없음(로드에 문제 없으면 그대로 쓴다).
- `tools/check_line_budget.py` 가 이 4종(§14 완료 게이트)을 강제한다 — 「본문에 절대 수치 하드코딩 금지」(§8)의 준거를 **'임의 self-impose' 에서 '공식 실측치'로** 교체한 것.
- **줄이는 조건 = §14 원칙 6.** 늘 실리는 것(헌법·색인·스킬 description · memory description 은 그 파일을 읽을 때 함께 실려 상시가 아니다)은 위 공식 양식·한도(와 훅 값 한도처럼 싣는 틀의 한도 · §5)에 안 맞거나 같은 말이 여러 곳에 있거나 분량이 커서 읽는 쪽이 조건을 놓칠 때 줄일 수 있고, 그때도 앞뒤 대조로 뜻·조건 누락 0 인 것만이다(원본 = §14 원칙 6).

---

## 2. 배치 결정 — 이건 여기, 저건 저기

1. **매 응답/매 이벤트 무조건?** → **hook**(전역 압축 caveman·세션시작 native 메모리 복사). 조건 매칭으론 못 켜는 것만.
2. **명시 호출·모드 전환?** → **command**(`/caveman`).
3. **다단계 절차·방법(불러 실행)?** → **skill**. "특수 조건만."
4. **상시 참조 행동 규율·원칙?** → **memory 성격**. native `rules/`(예약·상시전부로드) 말고 비예약 루트 BH `~/.claude/BADA_HUB/` 원본 + 세션시작 훅이 프로젝트 native 메모리로 복사(색인은 늘 실리고 본문은 Read 할 때 실린다 · §3). ★ 조건부(토큰절약) 주입은 요구하지 않는다 — 신뢰성(도달성) 우선. ★ 매 응답 규칙은 memory 만으로 두지 않는다 — 집행 요지를 헌법 줄에 둔다(5).
5. **항상 켜질 짧은 명령·인덱스?** → **헌법** always-on 집행요지 + `memory:` 포인터(원본 backing). ★ 스킬 도달 경로의 판별 — **방법론·절차·환경형 스킬은 헌법의 조건부 라우팅 줄("적용 = ~시" + `skill:` 포인터)이 필수**다(상시 비용은 조건줄 한 줄 · 계획·검수·LaTeX·덱·문서 파일·보안망 Windows 도구 등). **description 자가트리거 단독에 맡기는 것은 라우팅 줄 없이도 도달이 직접 실증된 파일형 스킬만**(caveman 류). 라우팅 줄이 있는 스킬은 지금 하려는 작업이 그 줄의 적용 조건에 해당하면 불러 적용한다(조건에 해당하지 않는 줄은 읽지 않는다 — §0-A).

**★ 집행 요지는 헌법 상시층에, 원본 memory엔 근거·상세.** 각 지침의 집행 요지(적용·행동·금지)는 always-on 헌법 인라인 bullet에 상시 실려 매 세션 도달하고, 원본 memory는 그 근거·예시·판정 세부를 담는다. 도달은 훅 하드락이 아니라 **헌법 always-on 집행 요지 + 늘 실리는 색인**이 맡는다 — 세션시작 복사가 memory 실물을 프로젝트 native 메모리에 확보하면 색인은 늘 실리고(native 로드 또는 훅 주입) 본문은 모델이 Read 할 때 실린다(§3·§5).

**★ 스킬 도달 = 헌법 조건부 라우팅 + description 자가트리거 — 로드는 모델 재량이 아니다.** 라우팅 줄이 있는 스킬은 **그 줄의 적용 조건이 맞으면 예외 없이 로드**하고(방법론 스킬은 "필수 로드" 명기), 자기 `description` 트리거·교차링크가 보조 도달 경로다(plan-execution·review-chunking·secured-windows-tooling·visual-design·ocr 등). 라우팅 줄이 없는 파일형 스킬(caveman 류 — 자가트리거 도달 직접 실증)은 description 이 단독 도달 경로이며 헌법에 라우팅 줄을 새로 만들지 않는다. 강제는 주입 장치가 아니라 헌법 문구가 한다 — 스킬 로드를 결정론 주입으로 밀어넣는 넛지 훅(`nudge_triggers` frontmatter + `load_skill_nudges` 훅 계열)은 짓지 않는다. memory 규범이 "이 작업엔 해당 스킬을 로드하라"를 명시하면 그 지시를 따르되, 트리거 substring으로 로드를 강제하는 기전은 짓지 않는다.

**층 = 중복 방지(우선순위는 헌법 §0-A 지침 우선순위가 원본).** CLAUDE.md=명령 index / memory=원본 상세(행동 규율·원칙) / skill=절차 detail. **배치 판정 기준**(작업 기준이며 사용자 확정 지시는 아니다): 절차·방법=skill / 상시 규율·원칙=memory. "부서 공용 지침 시작점(baseline)" 프레임이 "절대 불가침 고정 원본"보다 옳다 — §0가 프롬프트를 최상위로 못박아, 프롬프트로 "아니야" 하면 헌법·memory·스킬 뭐든 진다(예외 = 계획 게이트 — 헌법 「지침 우선순위」).

---

## 3. 상시 memory 확보 — 루트 BH 공용 원본 + 세션시작 복사 훅 → 프로젝트 native 메모리

원함: **사용자 저작 + cwd 독립 + 상시 도달(신뢰성 우선) + 상시 인덱스.** ★ "조건부(토큰절약) 주입"은 이 요구 목록에 넣지 않는다 — 조건부 주입은 도달성을 확률화(모델 재량)해 "조용한 부재"를 낳는다. **토큰 절약보다 도달성을 택한다.**

| 후보 | 탈락 사유(핵심 하나) |
|---|---|
| auto-memory | cwd 종속 + Claude 자기노트 오분류(§1 함정 열) |
| native `rules/` | eager 전부 로드 자체는 상시성엔 부합하나 **예약 폴더**라 폴더명 자유·비예약 회피 불가 |
| skill | 상시 인덱스 아님 + 완전 고정이라 적응성 훼손 |
| plugin | 자기 CLAUDE.md·전역 rule 못 실음(§10) |

→ **루트 BH 공용 원본 `~/.claude/BADA_HUB/`(상시 memory 원본 + `MEMORY.md` 색인) + 헌법 always-on 집행요지 + 세션시작 복사 훅이 프로젝트 native 메모리 `~/.claude/projects/<slug>/memory/`에 실물을 확보 → 색인은 늘 실리고(native 로드 · 그 리더가 없는 표면은 훅 주입) 본문은 모델이 Read 할 때 실린다.** "메모리처럼 읽되 룰처럼 지속하고, 매 응답에 걸려야 할 요지는 헌법 줄이 늘 싣는다." 네이티브 auto-memory 패턴을 **복제하되 전 PC 공용 원본을 루트 BH에 두고 세션시작 복사로 프로젝트 native 메모리에 이관한 것**(플랫폼과 싸우는 게 아니라 검증된 패턴을 옳게 이관). ★ 이 커스텀 파생물을 §1 네이티브 기전 표에 **행으로 넣지 마라** — 표는 네이티브만, 파생물은 표 밖에서 소개한다.

**★ 조건부 recall·넛지·트리거 훅은 짓지 않는다 — 도달성은 native 메모리 색인 상시 주입과 헌법 always-on 이 담당한다.** 유일한 조건부 훅 = **컴팩션·재개 직후 SessionStart가 `feedback_compaction_recovery` 본문을 1회 주입**(넛지 아닌 순수 복구 · §5). 그 외 모든 지침은 세션시작 복사가 프로젝트 native 메모리에 실물을 확보하고(색인은 늘 · 본문은 Read 할 때), 헌법 always-on 집행요지가 그 위에 상시로 걸린다.

**명명 규약**: 폴더는 **`BADA_HUB`**(내부 부서 포털명 BADA · memory 그릇), 파일은 **`feedback_<주제>.md`**(auto-memory 네이티브 prefix 채널), 색인은 폴더 최상위 `MEMORY.md` 다. **소유 판별은 prefix 가 아니라 설치 매니페스트·다이제스트**다. 레거시 이름(`BH_LKS_*`·`memory_*`)은 prune·sweep 대상으로만 남긴다. 작성자별 폴더·저자 태그는 공동 풀에 2번째 저자가 합류할 때 도입한다.

---

## 4. memory 저작·분할 — 이 구조의 일상 유지 작업

memory를 새로 쓰거나 쪼개는 일은 이 체계의 상시 유지 작업이다(원본이 분할로 늘어난다). frontmatter·progressive-disclosure 등 **일반 스킬/rule 문법**은 `references/bundle/skill-creator/GUIDE.md`·`references/bundle/skill-development/GUIDE.md` 참조; 아래는 공식이 안 다루는 **memory 고유**부다.

- **DO memory 파일 frontmatter + 등록**: `name` · `description`. memory는 조건부 훅이 없으므로 **트리거 키가 불요**하다 — 도달성은 아래 "포인터·색인 등록"으로 준다. ★ SKILL.md는 별개 규약: 스킬 탐색은 `description`만 보므로 SKILL.md의 트리거는 반드시 description 안에 둔다(별도 키는 무작동 장식). YAML 값에 `:`·`§` 등 특수기호가 있으면 따옴표로 감싼다.
- **DO 정확한 색인·포인터 등록(memory 도달성의 두 축).** memory를 새로 만들거나 쪼개면 **① `MEMORY.md` 색인에 항목 추가**(CC가 native 로드하는 실제 도달 경로 — 색인 상시 + 본문 on-demand)하고 **② 헌법(CLAUDE.md) 해당 조항 끝에 `memory:feedback_<주제>` 인라인 포인터**(그 규칙의 backing 참조 이름)를 단다. 색인 누락 memory는 native 로드가 안 돼 그대로 "조용한 부재"가 된다(§5 명제).
- **DO memory 간 관계도 = `[[feedback_*]]` Obsidian 위키링크 상호연결.** 기능별로 분할된 memory는 **합치지 말고 분할을 유지**하되(방대 당위성 — 예: work_execution 3분할), 서로를 `[[feedback_<주제>]]` 위키링크로 상호 참조해 관계를 명확히 한다(골격 소유 파일 ↔ 파생 파일, 분할 3종 상호). **분할 유지 + 링크 연결이 규범** — 링크 없는 고립 memory나 섣부른 재병합은 금지.
- **DO description 재저작(스킬화 시).** memory를 스킬로 승격하면 그 스킬 `description`은 탐색 작동 신호가 되므로 요약형을 **"~할 때" 트리거형**으로 다시 쓴다(요약은 작동 신호가 아니다). memory 자체엔 트리거가 없으니 이 재저작은 스킬화 경로에만 해당.
- **DO 절은 실질 내용이 있을 때만 둔다.** memory 본문 절(적용 조건·핵심 원칙·이유·실행 방법·예외·금지) 중 **적용 조건·핵심 원칙은 필수**이고, **이유·실행 방법·예외·금지는 핵심 원칙의 재술로 채우지 않으며 채울 내용이 없으면 절을 생략**한다. 빈 절을 메우려는 재서술이 같은 명제를 한 파일 안에서 여러 번 적게 만든다.
- **DO 분할 기준 = 캡 아니라 "결".** 개념이 다른 방법론이 한 파일에 섞였을 때 쪼갠다(그래야 참조가 필요한 것만 걸린다). 개별 memory 본문(`feedback_*`)은 온디맨드라 공식 캡이 없다 — 용량 때문에 쪼개는 게 아니다(§1 「공식 로드 한계」).
- **DON'T 공유절 복제.** 분할 시 공유 표·절을 양쪽에 복붙하면 표류 원천 → 한 파일이 골격 소유 + 나머지는 `[[feedback_*]]` wikilink 참조.
- **DON'T 하위 섹션 orphan 방치.** 다른 절이 가리키던 하위 섹션이 분할로 미아가 된다 → 흡수·repoint.
- **DO 무손실 = 원본 전 라인 union 대조.** 분할 전/후를 라인 단위로 합쳐 대조해 누락 0 확인.
- **DO 분할 후 `memory:` dangling 전수 repoint.** 한 파일을 셋으로 쪼개면 그 파일을 가리키던 헌법·색인·wikilink 포인터가 전부 dangling → refcheck가 hard FAIL로 잡을 때까지 전수 수정. ★ 이 지점이 §8 refcheck 가드가 "언제 쓰는 도구"인지의 답이다.
- **미검증 주의**: 스킬 동시 노출 수가 늘 때(예 16→37) 하네스 목록 상한·페이지네이션이 있는지는 실측 대상.

---

## 5. 세션시작 native 메모리 복사 훅 + 컴팩션 복구 주입 (★ 도달성 기전)

지침 memory는 조건부 recall이 아니라 **상시 확보**된다. 세션시작 훅이 **memory 실물을 프로젝트 native 메모리 `~/.claude/projects/<slug>/memory/`에 확보**하고(색인은 늘 실림 · 본문은 모델이 Read 할 때 실림), 헌법 always-on 집행요지가 그 위에 상시로 걸린다 — **매 응답 도달 = 헌법 always-on 집행요지 + 색인 · 본문은 모델 Read**.

**★ 중심 명제.** **색인은 늘 실리고(native 로드 · 그 리더가 없는 표면은 훅 주입) 본문은 모델이 Read 할 때 실린다 — 매 응답에 걸려야 할 규칙의 도달은 헌법 always-on 집행요지가 맡는다** — 훅의 역할은 본문을 조건부로 밀어넣는 것이 아니라 **memory 실물을 프로젝트 native 메모리에 두는 것**(복사)이고, CC 가 색인을 자동 로드하지 않는 표면에서는 색인을 직접 싣는다(아래 2). 조건부 주입은 도달성 문제를 푸는 것이 아니라 확률화한다(§3 규칙).

**훅 파일 하나(`tools/BADA_recall.py` · SessionStart — settings 에 본체와 색인 전용으로 두 번 등록)가 세 가지를 한다:**

1. **세션시작 native 메모리 확보(무조건·본문 비주입).** native 메모리는 프로젝트 특화(`~/.claude/projects/<slug>/memory/`)라 전 PC 공용이 안 된다. 그래서 전 PC 공용 원본(**루트 BH 폴더** `~/.claude/BADA_HUB/`)을 SessionStart에서 현재 프로젝트 native 메모리 영역에 확보한다 — **콘텐츠 다이제스트 구동**: 소스 memory 집합의 SHA-256 을 native `.bada_sync.json` 에 저장하고 없으면 설치·다르면 갱신+prune·같으면 침묵. `<slug>` = 세션이 시작된 프로젝트 루트(`CLAUDE_PROJECT_DIR`)가 든 git 저장소의 최상위(워크트리면 주 저장소 · 저장소 밖이면 그 루트 · 루트를 모르면 훅 입력 `cwd`) 절대경로의 비영숫자를 `-` 로 치환 — Claude Code 규칙과 같게 하위 폴더·`cd` 뒤·워크트리가 한 폴더를 함께 쓴다. 그러면 색인 `MEMORY.md` 를 native 로드하는 표면에서는 색인이 늘 실리고, 개별 memory 본문은 모델이 Read 할 때 실린다(on-demand). 본문을 context에 주입하지 않는다 — native 메모리 실물만 확보. 트리거·dedup·aggregate 예산 개념 없음. **개인화 우선**: native `feedback_*.md` 는 순수 파생 캐시라 갱신·prune 이 덮되, auto-memory 개인화(`user_*/feedback_*/…`)는 글롭 밖이라 무손실이고 `MEMORY.md` 색인 줄도 병합 보존한다(개인화 > 공용 사본).
2. **색인 주입(매 세션 · 토글).** CC 가 native 색인 `MEMORY.md` 를 세션에 자동 로드하지 않는 표면(web·원격 repo 세션 등)이 있어, 훅이 매 세션 색인을 `additionalContext` 로 직접 싣는다 — 소스 색인을 읽어 native 미확보 첫 세션에도 실리고, 본문은 그대로 on-demand 다. 토글 = 환경변수 `BADA_NO_INDEX_INJECT`(`1`·`true`·`yes`·`on` = 끔 · `0`·빈값·미설정 = 켬 — 모르는 표면은 도달 보장 쪽) · 표면별 기본값 = 로컬 설치 끔(`settings.json` 이 `1` · CC 리더가 색인을 로드) / repo 미러 켬(sync 가 `.claude/settings.json` 에 `0` 을 적음). compact·resume·fork 에서는 복구 본문과 한 값에 다 안 들어가므로 색인 전용 등록(인자 `--index-only` · 센티널 `recall-index@1`)이 색인을 따로 싣는다 — 값마다 한도를 따로 세고, 두 등록은 같은 이벤트에 나란히 돌므로 색인 전용은 native 메모리를 쓰지 않고 읽기만 한다.
3. **컴팩션 복구 주입(유일 조건부·순수 복구).** 컴팩션·재개 직후 SessionStart(`source`=`compact`|`resume`|`fork` — fork = 앞 대화를 이어받아 가른 세션이라 재개와 같은 위험)에서 `feedback_compaction_recovery` 본문을 1회 주입하고, 본문 뒤에 다시 읽을 것의 실제 경로(헌법 파일 · 소통·흐름 memory · 방법론 스킬 두 개 이름 — 복구 memory 「복구 읽기 순서」 맨 앞 묶음이라 6-check 보다 먼저 읽는다)를 붙인다. 입력에 `agent_id` 가 있으면(서브 안에서 돈 훅 · 공식 hooks 문서 common input fields) 머리 라벨과 목록 머리(「서브 몫 재독보다 먼저」)를 서브 몫으로 적는다(규칙 파일 재독 뒤 6-check·나머지 복구 읽기 대신 자기 발주문·받은 메시지·발주문이 입력으로 정한 파일·기록[대상·연계 파일 + 자기 work_log·실행 출력 절처럼 발주문이 정한 기록] 전문 재독 · 요청 대장·계획 문건에 쓰지 않음 · 발주문 밖 기록을 읽지 않음 · 원본 = 복구 memory 「핵심 원칙」 머리 문단). 넛지가 아니다 — 컴팩션이 트랜스크립트를 날린 직후 복구 절차를 되살리는 것뿐(§4 컴팩션 6-check 규범과 짝).

**훅 배선(wire).** 등록 JSON·`matcher`·공통 stdin(`hook_event_name`·`session_id`·`agent_id`·`cwd`·`source`)·exit code(0 통과/2 차단/기타 비차단) 등 **표준 문법은 `references/bundle/hook-development/GUIDE.md` + 실물 `components/global/settings.json`** 참조. SessionStart stdin `source`(`startup|resume|clear|compact|fork`)가 세 동작의 분기 근거다 — 복사·색인 주입은 전 source, 복구 주입은 `compact`|`resume`|`fork`만. 복구 주입 출력은 plain stdout 또는 JSON `hookSpecificOutput.additionalContext`(캡 10,000자 · 문자 수[UTF-16 단위로 셈] — 넘으면 Claude Code 가 파일로 빼고 앞 2,000자 미리보기만 싣는다 · 한 값에 상태줄·복구 본문·색인이 함께 실릴 수 있어 훅이 한도 안에서 조립한다: 순서 = 상태줄 → 복구 본문(자르지 않음 · 뒤에 다시 읽을 것 목록) → 색인(남은 자리만큼 줄 단위로 · 잘리면 끝에 색인 파일 경로 한 줄) · compact·resume·fork 의 색인은 색인 전용 값).

**★ 훅 최소 계약 (기전 무관 — 이걸 어기면 훅이 조용히 죽는다).**

1. **어떤 예외도 `exit 0`.** 훅이 죽어 세션이 안 열리는 게 memory 미확보보다 훨씬 나쁘다. fail-open.
2. **셸 한 줄 fail-open은 파일 부재만 보장한다.** 손상 타깃은 `runpy` 예외로 exit1+traceback, `sys.exit(3)`도 전파된다 → 파일 부재만이 아니라 **손상까지 삼키려면 launcher/try-except 계층**이 필요하다.
3. **memory 본문 읽기·복사는 `utf-8-sig`.** BOM 붙은 원본을 `utf-8`로 읽으면 첫 키가 `﻿name`이 되어 **파싱이 침묵 실패** → 복구 주입 본문이 무음사 — 이 설계가 싸우는 "조용한 부재" 그 자체다. 복사는 바이트 보존(BOM·개행 유지 — installer-traps 참조). 그 밖 IO는 `utf-8` 명시 + `PYTHONUTF8`/stdout reconfigure(Windows cp949 mojibake 방지).
4. **복구 주입 frontmatter 파싱은 정규식(stdlib YAML 부재).** description의 따옴표·콜론·`§`·`①` 같은 특수기호가 파서를 깨뜨리므로 파싱 테스트 필수.
5. **malformed/read-error는 세션을 막지 않는 validated fallback.** `name`·`description`이 각 1회·비어있지 않을 때만 채택, 나머지는 조용히 건너뛰되 세션은 계속.
6. **훅 파일 부재 시 설치기가 등록을 생략**(no-op 가드: `runpy … if os.path.exists(f) else None`) + **상태·캐시 파일 GC**(`.cache/…` 세션당 파일 무한 증가, uninstall이 회수).

**그 위의 품질 do/don't:**

- **★ DO 훅 출력 표출 여부를 저작 시 반드시 결정한다(미결정 금지).** 훅이 stdout 으로 사용자 가시 메시지(`additionalContext`·plain)를 낼 수 있으면 「매 작동 표출 / 상태변화 시만 / 무음」 중 무엇인지 명시하고 근거를 남긴다. 특히 SessionStart 처럼 **매 세션 반복 작동**하는 훅은 **선별 표출이 기본** — 정상·무변화는 침묵, 상태 변화(신규 설치·컴팩션 복구·설치 이상)에만 표출한다. 커스텀형 플러그인 설치 도우미(§13)는 이 결정을 **저자에게 묻는 단계**로 강제해, 자체 개인화 시 반복 상태줄 오염 함정을 저자가 겪지 않게 한다.
- **DO 복구 주입 dedup 상태 파일을 `session_id(+agent_id)`로 스코핑.** 전역이면 동시 세션(master+subs)이 서로 주입 억제하는 race.
- **DO 컴팩션 × dedup 배선.** 인라인 컴팩션이 주입 본문을 트랜스크립트에서 날리는데 dedup은 "주입됨" 유지 → 다음 SessionStart까지 복구 절차 부재. SessionStart는 `compact` source에도 발화 → **compact 매처에 dedup 리셋**(복구 주입이 컴팩션마다 되살아난다).
- **DO fail-open을 가시화하되 선별 표출(계약 ①·⑥의 elaboration).** `exit 0`만으론 부족 — 빈 복사·빈 주입이 바로 "조용한 부재"다 → stderr/error.log 로깅은 **상시**(관측용, 사용자 비가시). 단 사용자 가시 stdout 은 **상태 변화 시에만**: native 메모리가 이미 확보돼 있으면 침묵, **신규 설치·설치 이상·컴팩션 복구**에만 표출한다(매 세션 반복 상태줄은 컨텍스트 오염·토큰 낭비 · 예외 = 색인 주입 — 켠 표면에서는 도달성을 위해 매 세션 싣고 토글로 끈다). "조용한 부재"는 error.log 상시 로깅이 잡고, 사용자 표출은 상태 변화로 한정한다.
- **DO 복구 주입 머리에 "상시 지침 시작점(적응 가능)" 라벨.** 모델이 불가침으로 오인·오토메모리 위로 격상하지 않게(위계 프롬프트>오토메모리>memory 보존).
- **★ DON'T 조건부 recall 고유 규율을 짓지 마라(§3 규칙).** 트리거 substring 매칭 · `description`→트리거 매핑(범주 오류) · keyword→memory 매핑표(제3 원본 = C3·C4식 표류) · 본문 aggregate 주입·pending queue · dedup-by-trigger · 어간 매칭 · 어휘충돌 필터 — 전부 조건부 주입을 전제하는 장치다. 도달은 트리거가 아니라 **헌법 always-on 집행요지 + 늘 실리는 색인**이 맡는다(본문은 Read 할 때 · 세션시작 복사가 프로젝트 native 메모리에 실물 확보 · §2 명제·§4 색인/포인터 등록).
- 오해 해소: **SessionStart 훅 실행 자체는 토큰 0**(복사는 순수 로컬 IO). 토큰은 복구 주입 본문에만.

---

## 6. 크로스-OS 훅 — "잘못 깔리면 세션 먹통"

**★ DON'T OS 특정 훅.** 훅은 매 이벤트마다 도는데 OS가 안 맞아 매번 죽으면 **세션 먹통**. (a) `.ps1` 훅 = Mac/Linux 실행기 없음. (b) 셸 변수 문법 = `python "%USERPROFILE%\...\x.py"`(Windows cmd)가 POSIX 셸에서 미확장·오파싱.

**★ DO OS-프리 파이썬 파일 훅**: settings에 `python3 -c "…"` 한 줄로 등록하되, 셸 변수 의존 대신 Python 안에서 `CLAUDE_PROJECT_DIR`(저장소) → `expanduser('~/.claude/…')`(설치본) 폴백 + `runpy … if os.path.exists(f) else None`(부재 시 no-op). 인터프리터만 설치기가 분기(POSIX=`python3` / Windows 설치기가 `python` 치환, Store alias 회피). Python으로 짠 이유 = 크로스플랫폼 + 복사·복구 분기 로직을 **Linux 컨테이너서 pos/neg 테스트로 계측 가능**(라이브 작동만 실환경 몫).

**★ 훅의 라이브 작동은 컨테이너 테스트로 잡히지 않는다 — 실환경에서만 터진다.** 위 OS-프리 파이썬 훅 처방은 컨테이너 계측으로 확정하되, 라이브 작동 실패 여부는 배포 환경 실측 전까지 미검증으로 남긴다(개별 사고 실측 = `references/gate-forensics.md`).

---

## 7. 원본/사본 + 배포 표면

- **★ DON'T 배포 표면 부재 = 재설계가 안 깔림.** 실제 사고 유형: 포인터 경로 규약(`memory:`→BADA_HUB 경로)이 **사본 전용 생성물 POINTERS.md에만** 있고 배포본으로 출하되지 않음 → 설치본에서 `memory:` 를 어디로 읽을지 아는 파일 **0개**. **사본에 있다 ≠ 배포된다.** 재설계의 존재이유가 배포 표면에 있어야 한다(→ 헌법 §0-A 본문에 규약을 실음).
- **★ DON'T 설치본이 사본을 그림자 처리하는 걸 잊지 마라.** 설치본 HUB가 repo 미러를 가린다 — 유지보수자가 **미러를 고쳐도 훅은 stale 설치본을 복사**한다. 배포(재설치) 없이 미러만 고치면 런타임은 안 바뀐다.
- **DON'T 배포본에만 규칙**(활성 `~/.claude`에 없으면 강제력 0, C3). **DON'T 사본(`.claude/`) 직접 수정**(sync 산출물, 다음 재생성서 소멸).
- **예외 주의**: 재생성기가 emit 하지 않는 **손유지 파일**(예: 사본 폴더 밖의 wrapper)은 "사본=직접수정 금지" 불변식의 예외다 — 그런 파일이 자기를 "생성물"이라 선언하면 stale 모순이 생기므로 자기선언을 실제 소유와 맞춘다.
- **DO 원본=`components/`, 수정 후 sync 재생성 + `--check` 표류 0.** 재생성기는 stage-then-swap(`rm -rf` 선행 후 빌드 실패하면 활성 설정 소멸 — 폴백 필수).
- **DON'T 의미 편집을 기계 치환 목록에 묻지 마라.** 헌법의 "자동 load" 서술이 조건부 설계에선 거짓이 되는데, 이런 의미 편집은 grep 치환에 안 잡히고 "전수 치환"에 묻으면 누락 → 별도 재작성 산출물로 명시.
- **DON'T 세 줄만 고치고 넘어가지 마라** — 정합 정정은 **연결된 곳 전수 전파**까지가 이행(구 규칙 8파일 잔존 실증 · 연결된 곳은 관련 문건 전문 정독으로 찾고 검색은 정독 뒤 보조 · `memory:feedback_change_impact_analysis` 영향 지도). **DO 상속-원본**(상위 문서 복사 말고 상속 참조 — 중복 사본이 표류 원천). **DON'T 외부 소유 파일 임의 생성**(`version.json` 0바이트여도 미결 표기).
- **DO 배포 위생(④의 완료조건).** 커밋해시·프로젝트명·절대경로·개인 자산(Obsidian·HW 스펙) 잔재를 전수 제거하되 **엔지니어링 설계근거는 보존**.

---

## 8. 검증 삼각 + 게이트 함정 — 게이트 통과 ≠ 지시 이행

최상위 함정: **검사가 안 보는 곳은 검사 안 된 것.** 재사용 규칙(개별 사고 실측은 `references/gate-forensics.md`):

- verify가 소스 0개인데 "설치본 ≥ 0"으로 항상 참 → 초록불. **소스 0을 FAIL로 가드.** refcheck에 `PointerCount>0`(0건=FAIL) 가드.
- **refcheck가 `components/`만 스캔** → 사본·deck·setup·negtest 미검증. `sync --check`는 stale heredoc도 **자기 자신과 일치**해 무조건 통과 → **검증 삼각 자체의 false-green.**
- **bijective(1:1) 게이트 문구는 틀림** → **surjective**(고아0 + 전건해소, 반복 허용).
- **기전 삭제 시 `@import`까지 sweep.** 삭제 후 루트 CLAUDE.md의 dangling `@import`가 세 게이트 다 green인 채 생존. "토큰을 잃어야 할 파일은 그 토큰을 잡는 **모든** sweep 스코프에."
- **"재계수 0"은 allowlist 없이 기계 판정 불가.** 정당 잔존 필연(잔재-WARN 코드·"왜 이 버킷 안 쓰나" 주석·CHANGELOG 역사·덱 교육 문장). **파일+내용패턴 allowlist**(파일:라인 아님 — 편집이 라인 밀어냄).
- **반쪽 전환 = false-green**: 새 정규식이 옛 스킴을 아예 못 봐 no-op 통과. + **맨 문자열 잔재**(MEMORY·feedback·메모리)는 스킴 정규식도 레이아웃 게이트도 못 잡음.
- **접두 차폐**: `skill_LKS_`·`BH_LKS_` ⊃ `LKS_` → `grep LKS_` 대량 false-red. `grep -v` 금지(경로 오염 false-green), **이중 lookbehind `(?<!skill_)(?<!BH_)LKS_`**. 게이트는 **판정 시점 트리 상태(시간축)로 시뮬** — `BH_LKS_`는 전이 전 0건이라 잠복.
- **negtest lockstep**: 픽스처가 헌법 헤딩·스킬 라인을 byte-exact assert로 물면 동반 1커밋. 정적 라인 열거는 반복 누락 → grep sweep + 의존 함수째 삭제.
- **헌법 self-count 표류**(권장 200줄↔실제 286·5조건↔8) → 자기 선언 수치는 기계 대조. **본문에 절대 memory 수를 하드코딩하지 말 것**(동적 카운트 `$srcMem`은 원본 증가를 자동 반영 = 안전한 반대 사례).
- **회귀 재주입(negative test)**: 알려진 결함 N종을 사본에 주입해 전건 FAIL 검출되는지 → 검사기 자체 false-green 방어. **G-SYNC**: 덱·README 수치 ↔ 패키지 실물 어긋나면 둘 다 틀림.
- **DO 서브·이전 세션 자기보고 불신 → master 삼각검증(실물 재현).** Opus 5.5 과대 적발 필터. 서브 모델·effort 는 정의 파일(`components/agents/bada-*.md` frontmatter `model` 전체 ID·`effort`)로 걸고 Agent 호출 인자 `model` 은 넘기지 않는다 — 별칭 `opus` 는 master 가 Opus 면 master 모델로 풀린다(공식 문서). `create_session`(전체 ID)은 사용자 지목 때만(silent substitution 금지). 다중모델 다양성이 blind spot 상보(Fable=시간축·업그레이드, Opus=grep·배포문서).
- **로컬 grep=0 ≠ negtest green/내부정합** — mixed-case(`$memoryIndex`)·undefined 참조는 실배포 Windows PC negtest 실행서만 판정(가장 비싼 이연 red).

---

## 9. 설치기·업그레이드·제거 계약

계약(재사용 규칙)만 여기 두고, 언어별 킬러와 개별 사고는 `references/installer-traps.md`.

- **DO 2버전 설치기**(Windows PS / Mac·Linux POSIX), 병합 로직은 공용 python 헬퍼(취약한 PS JSON 대신).
- **DON'T settings 통째 덮기**(hooks 클로버) → **hooks union/비클로버 병합**(사용자 훅 보존, 훅 먼저 깔기). **DON'T env·permissions 통째 대체**(사용자 `env.MY_VAR` 소실 F3) → dict 병합. **DON'T 단순 dedup**(교차-interp 이중등록·구 ps1 잔존) → `_PKG_HOOK_MARKERS` 스윕.
- **DON'T "clean install" 전제(신규 PC만).** 옛 버전 위에 덮으면 옛 `feedback_*` auto-memory 이중로드 + 스킬 이중로드(트리거 중복). 설치가 **백업만 하고 stale prune 안 하면** 옛+새 공존, verify `-ge`라 통과, uninstall은 현 패키지명만 지워 옛 파일 영구 고아. → **prune(선삭제) 필수.** ★ 단 접두 필터 prune(`skill_LKS_*` 아니면 삭제)은 **번들 도입 후 금지** — 자기 번들을 지운다. prune 은 **설치 매니페스트**(그 설치가 심은 파일 목록) 기반이어야 한다.
- **DON'T uninstall이 폴더 통째 `rm`**(무백업 자산 소실) → **매니페스트 기반 회수**(그 설치가 심은 목록만) + 빈 폴더만 rmdir. ★ 번들처럼 **일반명 컴포넌트**는 사용자가 동명으로 이미 가질 수 있으므로 "패키지 컴포넌트명=우리 것" 가정 금지 — 설치 시 무엇을 심었는지 기록해 그것만 회수·복원. **DON'T 훅 해제를 빠뜨리지 마라** — 잔존 훅이 계속 작동(⑥의 핵심). 상태·캐시 파일도 회수.
- **DON'T 절대경로 매핑표를 인스톨러가 생성**(USERPROFILE 공백·한글·OneDrive·기계간 이동에 깨져 새 표류) → **홈앵커 규약 1줄**(`memory:feedback_<주제>`→`~/.claude/BADA_HUB/feedback_<주제>.md`). (master 과잉설계를 감사가 죽인 사례.)
- **DON'T 컨테이너 실측 = Windows 실측으로 오인.** Linux서 `~` Read 통과했다고 "확정" 마킹 금지 → 배포 OS 실측 전 "확정" 금지. POSIX 문구엔 `%USERPROFILE%\.claude\` 병기.
- **DO POSIX 설치기는 Linux 환경에서 install→verify→uninstall 실행 검증**(이연 아님). PowerShell·gate2 렌더는 실배포 Windows PC 이연.

---

## 10. 정통(마켓플레이스형) vs 커스텀형 플러그인 — 정통 경로 밖이면 스캐폴딩은 네 것

공식 Claude Code가 이미 제공(WebFetch 확정): `.claude-plugin/plugin.json` 번들 · marketplace · `claude plugin init/install/validate` · SKILL.md/hooks/settings 스펙 · `${CLAUDE_PLUGIN_ROOT}`. → **표준 컴포넌트의 "문법 how-to"(스킬/훅/커맨드를 어떻게 쓰는가)는 공식과 중복이니 만들지 마라.** ★ 이 스킬은 그 how-to가 아니라 **여러 컴포넌트를 하나로 묶는 번들 저작 스킴**이다 — 범위가 다르다.

**이 패키지의 처리 — 번들.** 그 표준 컴포넌트 문법 스킬(공식 `hook-development`·`skill-creator`·`skill-development`·`plugin-structure`·`command-development`·`agent-development`·`mcp-integration`·`plugin-settings`)을 **패키지에 냉동 번들**하되, arch 스킬 밑 `references/bundle/<name>/GUIDE.md`(`SKILL.md`→`GUIDE.md` 리네임 · CC 가 형제 스킬로 재발견 못 하게)로 담는다. 이유: 잠긴 보안망은 공식 원격/마켓플레이스를 못 가져오므로(이 패키지 존재 이유와 동일) **ZIP 자기완결**이 필요하다 — 포인터만으론 받는 쪽이 못 쓴다. §4·§5가 그 로컬 번들을 `references/bundle/<name>/GUIDE.md` **경로 Read**로 가리킨다(`skill:<folder>` 아님 — 별도 스킬 로드가 아니라 온디맨드 자료). ★ §7의 "중복 사본=표류 원천" 리스크는 **upstream SHA·라이선스·출처 마커**(`VENDORED_SKILLS.md`)로 관리한다(라이선스: 8종 모두 Apache-2.0 재배포 허용 — skill-creator=`anthropics/skills` · plugin-dev 7종=`anthropics/claude-plugins-official`[옛 자리 `anthropics/claude-code`] · 라이선스 사본 동봉). 잠긴 망이 아니면 번들 대신 포인터가 표류 0이라 낫다.

**공식이 못 주는 것**(= 커스텀형 고유): 정통 plugin은 **자기 CLAUDE.md를 context로 로드 안 한다**(원문: *"A `CLAUDE.md` at the plugin root isn't loaded as context, and `claude plugin validate` warns when it finds one. To include instructions that load into Claude's context, put them in a skill."*, 출처 = 공식 `plugins-reference` 문서(plugin-structure 스킬 본문 아님) — 이 인용이 명문화하는 것은 **CLAUDE.md 한정**이며, 전역 rule 기여 여부는 인용 밖 확장 추론이다). 즉 always-on 헌법 + BADA_HUB 상시 지침 memory는 정통 플러그인 모델 밖 → `constitution`을 `claude plugin install`로 못 깐다.

**핵심**: 우리가 만든 것도 **플러그인 — 단 커스텀형**이다. always-on 헌법 + 상시 지침 memory를 원하는 순간 = **정통 배포 경로 밖 = 설치기·병합·검증 스캐폴딩을 네가 소유**(스킬·커맨드·훅은 정통 컴포넌트로, BADA_HUB·헌법은 별도 인스톨러 = 시스템이 강제하는 유일 경로, 우회 아님). 원본/사본 거버넌스·`memory:` 상시 규약·2버전 설치기가 바로 그 커스텀형 고유 영역이다. 그 비용을 처음부터 계산하라.

- **DO 외부 base 스킬 포크 규율.** 공식 SKILL.md 원형 유지(**`name` + provenance 스탬프[`version`·`updated`]만 변경**) + **델타 절만 프리펜드** + `scripts/` 바이트 동일. 예외 = 사용자 결정으로 본문·`scripts/` 를 제자리에서 고친 포크(Windows Office COM 경로 — `skill_LKS_custom_document` 의 `references/docx/`·`references/pptx/`·`references/xlsx/`): 고친 범위(스크립트·절 이름)를 그 GUIDE.md 머리 주석에 적고 고친 upstream 파일 머리에 변경 고지 한 줄(Apache §4(b) — 원본·라이선스·바꾼 범위)을 두며, 공식 새 판을 들일 때 그 범위를 다시 넣는다 · 세 포크의 `scripts/office/` 는 같은 파일 세 벌이라 함께 고친다(파일 전부 같게). 출처 표기는 **외부 원저작에만**(자체물엔 출처 창작 금지 · 규율 원본 = 헌법 「출처 표기」 절 · 원본 `ATTRIBUTION` 보존).
- **caveat**: SSL 인터셉션·winget 차단·`python3` Store 함정 있는 보안망이면 공식 install도 막힐 수 있다.

---

## 11. 명명·예약폴더

- **"rule" 개념 ≠ native `rules/` 폴더**(예약·상시로드). 이 혼동이 여정의 씨앗. ★ 그래서 **BADA_HUB 원본은 'rule'로 부르지 않는다 — 'memory'(또는 '지침')로 부르고 파일은 `feedback_<주제>.md`·포인터는 `memory:`다**: 'rule'이라는 말은 native `rules/` 폴더·추상 규율(행동 규율·원칙) 개념에만 남기고, 우리 상시 지침층(BADA_HUB의 memory)에 붙이면 그 예약 폴더와의 혼동이 되살아난다.
- 예약 매칭은 정확한 디렉터리명 → 비예약 이름(`BADA_HUB`)이 자동로드 함정 회피.
- 접두 차폐 이중 lookbehind → §8. 파일명·frontmatter 규약 창작 금지(사용자 확정 `Step <N> — <제목>.md`, `name==folder` 게이트).
- **유령 명령 금지**: 헌법이 존재하지 않는 커맨드/훅(예: 과거의 `/learn`) 나열 → 실물 대조서 제거. 문서가 구현보다 앞선 갭을 "문서 삭제"로 메우지 말고 실제 구현으로.
- 영문 파일명에 한글 음차 괄호 병기 금지("영단어 공부 시키냐"). stale-탐지 코드(옛 폴더 탐지용)를 리네임 sweep이 삼키면 탐지 사망 → 의도적 잔존 줄 식별.

---

## 12. 프로세스 함정

- **DON'T 지시 대장이 있어도 안 펼쳐보면 무용.** "수십 번" 준 지시가 재작업서 증발("내 지시 다 어디갔냐") — 원문은 `USER_DIRECTIVES_LEDGER`에 보존됐으나 **컴팩션 기억으로 작업**. 대장은 정독해야 원본.
- **DON'T 통째 재작성**(새 모순을 심는다 — 통합 재작성이 §간 상충 신설) → targeted 편집. 메타패턴: "게이트를 추가할 때마다 스코프/면제를 안 붙여 버그를 심었고 루프가 잡았다."
- **DON'T `git add -A` + 병렬 서브**(in-flight 편집 미검토 커밋, 서브 "diff 없음" 자기보고도 이 때문) → master 직접 대조.
- **DON'T "제거"를 "축소"로 오독**(모델 **대체**를 N=9→N=6 규모 축소로) → "슬롯 치환"과 "규모 축소" 구별.
- **DON'T 계획서에 결정 ID 참조하고 정의 안 함**(인계자 blocking). **DON'T 블라스트 반경 계수 재현 불가**(계획172↔실측139) → 계수 명령+스코프를 계획에 박아 재계수. **DON'T 선언한 산출물이 실물에 없는데 "완료" 마킹**(§0 자가판정 위반).
- **DO 독립 적대감사(Opus)+설계리뷰(Fable, 요청 시)가 master 자신의 과잉설계·과신을 교정** — 빈 통과 금지·refute mandate. 검수 절차(갈래별 검수 → 한 번에 고침 → 재검증) = 헌법 §3 · `memory:feedback_chunked_review`.
- **DO 결함 출처 3분류**(①선재/잠복 ②구조변경이 노출 ③계획 개정이 심음). **DO 사용자만 결정 가능한 충돌은 DECISION 분리**(다수결·억지 판정 금지). **DON'T 모델이 사용자 입장 변화를 과잉추종**하며 확정 결론을 여러 번 뒤집기.
- **DON'T cumulative step 번호를 두 트랙에 혼입** → 트랙별 번호공간 분리. **DO 계획 전제 않은 새 자산 출현 시 판정 게이트 선삽입.**

---

## 13. 허브 — 공식 번들 문법 가이드 + 우리 오버레이

이 스킬은 8종 공식 번들 문법 가이드의 **허브**다. 공식 8종은 컴포넌트 **문법 how-to**(스킬·훅·커맨드·플러그인을 *어떻게 쓰는가*)를 담당하며 외부 저작이라 **원형 그대로 두고 고치지 않는다** — arch 스킬 밑 `references/bundle/<name>/GUIDE.md` 로 냉동 번들돼(`SKILL.md`→`GUIDE.md` 리네임 · CC 가 형제 스킬로 재발견 못 함) **`skill:` 로드가 아니라 경로 Read 로 참조하는 온디맨드 자료**다. 우리 조직 규범은 공식을 고치는 대신 **여기에 오버레이로 얹는다.** 플러그인 구성물(스킬·훅·커맨드·설정)을 저작할 때는 **해당 공식 가이드(경로 Read) + 이 표의 우리 오버레이를 함께** 본다.

| 공식 번들 가이드(경로 Read) | 담당(문법 how-to) | 우리 오버레이(이 스킬의 절) |
|---|---|---|
| `references/bundle/hook-development/GUIDE.md` | 훅 등록 JSON·stdin·exit code·이벤트 | **출력 표출 여부 필수 결정(선별 표출 기본, §5)** · 훅 최소 계약(§5) · 크로스-OS 함정(§6) · 세션시작 복사/복구 기전(§5) |
| `references/bundle/skill-creator/GUIDE.md` · `references/bundle/skill-development/GUIDE.md` | SKILL.md·progressive-disclosure·description | memory 고유부(§4) · 헌법 포인터+MEMORY.md 색인 등록·`[[위키링크]]`(§4) · description "~할 때" 트리거 규약(§4) |
| `references/bundle/plugin-structure/GUIDE.md` | 번들 레이아웃·`plugin.json`·`${CLAUDE_PLUGIN_ROOT}` | 커스텀형 형상·배포/제거 계약(§0·§9) · 원본/사본(§7) · 번들 vs 포인터 판단(§10) |
| `references/bundle/plugin-settings/GUIDE.md` | settings.json 스키마 | model 핀·env 규율(헌법) · 매니페스트 기반 prune(§9) |
| `references/bundle/command-development/GUIDE.md` | 슬래시 커맨드 문법 | 흐름 보호(popup 회피) · 커맨드 배치(§2) |
| `references/bundle/agent-development/GUIDE.md` | 서브에이전트 정의 | 세션 분업·모델 배정(헌법·multi-session) |
| `references/bundle/mcp-integration/GUIDE.md` | MCP 서버 연결 | 연결 시 조직 보안·경계 규범 |

**운용 규칙.**
1. 공식 문법과 우리 오버레이가 **상충하면 우리 오버레이 우선**(조직 규범이 상위).
2. 공식 8종은 **원형 유지** — 고칠 게 생기면 공식을 고치지 말고 이 허브에 오버레이 절을 추가한다(§7 "중복 사본=표류 원천" 회피).
3. 신규 컴포넌트 저작은 **착수 전 체크리스트**(아래)로 공식 가이드(`references/bundle/`·경로 Read) + 우리 오버레이 양쪽을 점검한다. 특히 훅은 **출력 표출 여부**를 저자에게 반드시 묻고 결정한다(§5).

---

## 14. 지침 개정 절차 (SOP)

지침 체계(헌법·memory·skill·덱·settings)를 고칠 때의 작업 표준. 개정 사고의 4병인 — **게이트 없이 수행 · 불신본 근거화 · 규범 이중수록 · 옳은·틀린 변경을 한 커밋에 뭉침** — 을 막는다. **적용** = 지침 상충 해소 · 버전업(예: `vX.Y.Z` 마이너 올림) · 재배치(memory↔rule↔skill↔hook)뿐 아니라 **이 패키지(Settings_for_Claude) 관련 수정·보완·유지보수 전반** — 설치기·도구(`tools/`·`setup/`)·게이트·덱 변경도 이 게이트를 탄다(예: 도구 인코딩 수정). 경량(오타·1줄 문구 다듬기)은 SOP 생략 가능 — 단 고치기 전 영향 지도는 경량이어도 한다(한 줄 수정도 다른 곳과 이어져 있으면 · 원본 = `memory:feedback_change_impact_analysis`).

**핵심 원칙 (9).**

1. **원문·삭제이력 독립 확보 후 판단.** 현행 문구를 실물로 정독하고, 삭제·변경 이력은 git blob 등 1차 원천으로 확인한다. **불신 세션 산출물(revert된 커밋·참고본·이전 세션 결과)을 근거로 삼지 않는다** — 대조용으로만(§8 "서브·이전 세션 자기보고 불신 → master 삼각검증"과 짝).
2. **규범 원본 단일화.** 규범(무엇을·왜)=memory, 절차·양식(어떻게)=skill. 같은 규범 문구를 memory와 skill에 **verbatim 이중 수록하지 않는다** — 한쪽은 포인터. 예외 = 매 응답에 걸려야 하는 집행 요지(검수 갈래·관점 10개·10라운드·재검증 범위 같은 게이트 수치·검수 절차)는 헌법 줄 **한 곳**에 다시 적을 수 있다(원본 지정 동반). 스킬·다른 memory 는 다시 적지 않고 원본 포인터와 그 자리에서 실제로 쓰는 한 구만 둔다(예: 「재검증 = 같은 B · 범위 원본 = `memory:feedback_chunked_review` 「재검증」」) · 이미 다시 적힌 자리는 원칙 6 대조(뜻·조건 누락 0)를 통과한 것만 포인터로 바꾼다. **규칙·수치·용어를 바꾸면 원본 + 헌법 요지 + 다시 적힌·포인터 자리를 같은 커밋에 고치는 것이 완료 조건**(연결된 곳 찾기 = `memory:feedback_change_impact_analysis`).
3. **4-tier 보고.** 발견·판정은 확정 / 근거 미발견 / 추정 / 미검증으로 분리한다(`memory:feedback_confirmed_items_policy`).
4. **옳은 조각/틀린 조각 분리 커밋.** 여러 변경을 한 커밋에 뭉치지 않는다 — 방향이 옳은 조각과 틀린 조각을 섞으면 통째 revert돼 옳은 것까지 잃는다.
5. **근간 지침은 §0 변경 절차.** master=Opus 5.5 · medium·모델 배분·운용모델 등 근간 지침(헌법 §0 목록)은 자의 변경 금지 — 문제 발견 → 사용자 의견 → 피드백 → 진행.
6. **누락 금지(무손실 개정 · 최우선 렌즈).** 개정은 개선·수정이지 삭제가 아니다 — 기존 지침의 substantive(사고성) 규범을 지우지 않는다. 파일 삭제·리네임·문구 제거는 **사용자 명시 결정**에만 근거하고, 이동·통폐합 시 원 규범의 전 요소가 도착지 원본에 실존함을 **실물 대조**로 확인한다(요약 대체 금지). 개정 전 규범 인벤토리를 **baseline**으로 확보해 개정 후와 대조한다. **줄이기는 무손실 대조를 통과한 것만(원본 = 여기).** 가능하면 줄이지 않는다 — 뜻을 남겼다고 믿는 축약도 한정어·조건이 떨어져 뜻이 무뎌진다. 줄일 때(공식 양식·한도[§1 「공식 로드 한계」 · 훅 값 한도처럼 싣는 틀의 한도]에 안 맞음 · 같은 말이 여러 곳에 있음 · 분량이 커서 읽는 쪽이 조건을 놓침)는 줄이기 전·후 문장을 나란히 놓고 조건·한정어·예외·수치·포인터를 하나씩 대조해, 빠진 것이 0 이거나 빠진 것이 원본 자리에 실재하는 것만 남긴다 — 대조표를 그 스텝 기록에 둔다(빠진 것이 하나라도 있고 원본에 없으면 그 줄은 줄이지 않는다). 「짧을수록 준수율이 오른다」 는 줄이는 이유가 될 수 있으나 이 대조를 대신하지 않는다 · 「신호를 진하게」 는 새로 넣는 문장의 꼴 규칙이지 이미 있는 문장을 줄이는 근거가 아니다(§1 「로드 원리」). 규칙의 이유·사고 경위 문장과 기록 문건(CHANGELOG·Result·스텝 이력·대장)은 줄이거나 다른 파일로 옮기지 않는다 — 이유가 빠지면 다음 검토가 의도를 모르고 되돌리자고 한다.
7. **패키지 소유 UID.** 설치 산출물의 소유는 두 축 — **파일**(스킬·memory·커맨드·도구·CLAUDE.md)은 외부 등록부 매니페스트 `.bada_manifest`, **훅**은 명령 내 센티널 `_BADA_HOOK='<이름>@<버전>'`(예: `caveman@1`·`recall@1`). 사용자 표면 마크다운엔 in-content UID 를 박지 않는다(콘텐츠 오염·frontmatter 스키마 위험 · **내용 해시가 아님** — 훅 명령·경로가 interp 로 정당히 변하면 해시로는 자기 것을 놓친다). 우리 저작 지침엔 본문 provenance 스탬프(frontmatter, CLAUDE.md 상단 1줄 · **외부 번들엔 안 박음**)를 두고 **갱신 규칙(원본 = 여기)** 을 지킨다 — `version`(마지막 실질수정 버전 · last-modified)은 규범·본문을 실질로 고친 릴리스에서만 올리고, `updated`(최종수정일)는 내용이 바뀌면 실질·비실질(마커·주석 등 cosmetic) 불문 올린다 · 단 provenance 스탬프 줄(`version`·`updated`)만 고친 정정은 `updated` 를 올리지 않는다(날짜 위조 금지) · 릴리스를 자를 때 그 버전에서 내용이 바뀐 지침(provenance 줄만 고친 정정 제외)의 `updated` 가 릴리스일(CHANGELOG 헤더 날짜)보다 과거면 릴리스일로 올린다(드리프트 게이트가 과거 날짜를 FAIL 로 잡는다 · 게이트 기전 = `references/installer-traps.md` 「드리프트 게이트」). 순서도 지킨다 — **① 지침에 스탬프 → ② digest·센티널 취합 → ③ JSON 기재**(뒤집으면 설치본이 전부 MODIFIED). ★ **버전 라인 선행 상승**: 버전 컷 후 다음 버전 개발을 시작하기 전에 **설치 매니페스트 `version` 을 먼저 올린다** — 안 올리면 레지스트리 `digests/<ver>-full.json` 이 이전 릴리스 이름으로 갱신돼 그 릴리스의 다이제스트가 오염된다. ★ **기전 상세**(버전 레지스트리 `digests/<ver>-full.json`·개행정규화 sha256·PRISTINE/MODIFIED/INCOMPLETE 판별·`merge_settings.py` 전 이벤트 sweep·드리프트 게이트)는 **§9 · `references/installer-traps.md` 가 원본** — 여기서 재설명하지 않는다(원칙 2 자기적용). ★ **버전 번호는 스탬프·대장에만 · 지침 본문 금지.** 지침 본문(헌법 규범 줄·memory·skill·`tools/` 데이터)에는 패키지 버전 번호를 쓰지 않는다 — 조항은 **이름으로 지칭**하고(예: 「병렬 — 자의 동시성 게이트」), 도입 시점·변경 이력은 **관리 대장(CHANGELOG)** 에만 둔다. 예외 = 위 frontmatter `version`·`updated`·헌법 상단 최종수정 줄, 규범을 설명하려 버전을 예시로 드는 자리(`vX.Y.Z` 자리표시자 포함), 사고 이력 서술, 외부 벤더링. 이유 = 설치본·타 프로젝트엔 이 저장소의 버전 이력이 없어 '특정 버전' 지칭은 가리키는 대상이 없는 참조가 된다.

8. **오독 불가 문구(역방향 오독 차단).** 안전·규범·금지 문구는 단독 발췌·서브 gist 로 읽어도 의도와 반대로 행동할 수 없게 쓴다 — always-on 헌법·서브 노출 인덱스가 특히 취약(far-governor 의존·한정어 strand). 렌즈 T1~T10·콜드리드 프로브·교정 원리 = `references/reverse-misread.md`.

9. **작업 한정 지시는 지침으로 넓히지 않는다 · 지침 예외는 계획 §11 에 따로.** 사용자가 특정 작업에만 적용한다고 밝힌 운용 방식은 그 작업에만 적용하고 상시 지침(헌법·memory·skill)으로 넓히지 않는다. 작업 한정을 밝히지 않은 명령 — 일반 원칙으로 말한 명령 · 지침 위반 지적 — 은 작업 한정으로 좁히지 않고 지침 반영 계획으로 올린다(작업 한정 명시가 없으면 이쪽이 기본값). 어느 쪽인지 조금이라도 애매하면 그 작업에만 쓰고 최종 보고에서 지침에 넣을지 한 번 묻는다. 지침 규칙에 예외를 두려면 계획 §11 `Decisions Required` 에 「예외」로 따로 적어 결정받는다 — 멈출 일 표의 한 칸에 묻어 두지 않는다(절차 = `skill:skill_LKS_original_plan-execution` 1b). 이 규범이 사용자 요청 대장 처리 갈래 (다)의 원본이다(갈래·양식 = `skill:skill_LKS_original_plan-execution` 「② GO 직후」 2c-2 · `references/record-formats.md` 「늘 지킬 제약」 절).

**실행 순서.**

1. **상충·문제 인벤토리** — 헌법 지침줄 × memory × skill × 덱 교차 대조(정면 모순 / 경계 모호 / 이중 수록 / dangling) + 수정의 2차 부작용까지 도출 + **개정 전 규범 baseline**(무손실 · 원칙 6).
2. **before/after 문구 설계** — 각 건의 현행 문구(인용) → 제안 문구 + 부작용 예방 병기. **제안 문구를 역방향 오독 렌즈 T1~T10 으로 자체 스캔**(단독 발췌·서브 gist 로도 의도대로 읽히나 · `references/reverse-misread.md`). 사용자에게 가져와 의견 → 피드백.
3. **원본 수정** — `components/`(원본)만 고친다. `.claude`(사본) 직접 수정 X(§7).
4. **파생물 동기** — `MEMORY.md` 색인 · memory frontmatter description · 형제 `[[feedback_*]]` 링크를 같은 작업에서 함께 갱신(1:1·dangling 0 · §4).
5. **사본 재생성 + 참조·메모리 게이트** — `tools/sync_repo_claude.sh` → `--check` 표류 0 · refcheck(포인터↔색인↔파일 1:1·미참조 0) · recall/훅 실측 green(게이트 함정·기전 = §8·§7).
6. **덱·CHANGELOG** — 지침 변경이 덱 서술과 어긋나면 덱 갱신, CHANGELOG에 **왜** 기록.

**컴포넌트 개별 제거·교체 (단일 구성 · Compact 대체).** 단일 구성이라 "부분 설치"는 프로파일이 아니라 **원본에서 개별 컴포넌트를 빼서** 만든다. 1:1 불변식(헌법 포인터 ↔ `MEMORY.md` 색인 ↔ 파일 · dangling 0 · 미참조 0 · §4)을 지키고, 파일 삭제·리네임은 **사용자 명시 결정**에만 근거한다(원칙 6).

- **스킬 제거**: ① `components/skills/<이름>/` 삭제 ② 헌법의 `skill:<이름>` 포인터 줄 제거(규칙이 그 스킬 전용이면 줄째, 규칙이 남으면 포인터만 — 규범 소실 금지) ③ 다른 스킬·memory 본문·커맨드(`components/commands/*.md`)의 그 참조 전부 ④ refcheck → skill dangling 0 ⑤ sync → `--check` 표류 0. (다음 설치 때 매니페스트 회수가 구설치본에서 자동 제거 — bh·커맨드·도구 동일.)
- **memory 제거**: ① `components/global/BADA_HUB/feedback_<주제>.md` 삭제 ② 헌법의 `memory:feedback_<주제>` 포인터 줄 제거(규칙이 남으면 포인터만) ③ `MEMORY.md` 색인 항목 줄 ④ 다른 본문의 `memory:feedback_<주제>` 포인터 + 형제 `[[feedback_<주제>]]` 위키링크 전부 ⑤ refcheck → dangling 0 · 미참조(orphan) 0 · 색인↔파일 1:1(파일만 지우면 dangling/유령색인 · 포인터만 지우면 orphan/미색인 — 모두 refcheck 가 잡는다) ⑥ sync → `--check` 표류 0.
- **교체·수정**: 원본(`components/`)만 고치고, 우리 저작 지침이면 스탬프(frontmatter `version`·`updated` · 헌법은 상단 `최종수정` 줄)를 원칙 7 갱신 규칙대로 올린 뒤 → sync `--check` 표류 0 · refcheck dangling 0. 드리프트 게이트가 못 잡는 자리(같은 버전 라인 안에서 `updated` 를 이미 릴리스일 이상으로 올린 뒤의 재편집 등)는 저자가 직접 올린다 — 게이트가 무엇을 잡고 무엇을 못 잡는지 = `references/installer-traps.md` 「드리프트 게이트」.

개별 제거·교체도 개정이므로 아래 완료 게이트 전체가 적용된다(커밋 전 통과).

**완료 게이트 (커밋 전).**

- `sync --check` 표류 0 · refcheck dangling 0·미참조 0 · recall/훅 green.
- **검수** — 변경분 검증(고정 5 프리셋은 대상 종류로 고른다 — 지침·규범 문서 = P2 · 설치기·도구·게이트 = P3 · 덱 = P4 · 섞이면 주된 프리셋 + 다른 종류의 가장 다른 항목을 가변 5 에 · 가변 5) · 변경 갈래로 강도를 가른다(지침 한 줄 고침 = ② · 새 규칙·규칙끼리 관계·층 이동·지우거나 합침 = ③ · 뜻 그대로인 낱말 치환 = ① · 자리 이동 = ④ · 갈래마다 검수 강도·범위 원본 = `memory:feedback_chunked_review` 「검수 구분」) · 가변 5 후보 = 문서 렌즈셋(원본 = plan-execution audit 절) · **역방향 오독 T1~T10** · 규범 원본 = `memory:feedback_chunked_review` · 절차 = `skill:skill_LKS_original_review-chunking`. **고노출 후보(always-on 헌법·서브 노출 인덱스·최고심각)는 콜드리드 프로브로 실증**(모델 배분 안 콜드 서브로 · 후보 수로 서브를 늘리지 않되 같은 규범의 조각은 한 서브에 하나만 · 모델·절차 = `references/reverse-misread.md`).
- **★ 누락검출 게이트** — 개정 diff 의 삭제·축약 라인 전수 소명: 각 건이 ① 이동(도착지 원본 명시) ② 사용자 명시 결정 ③ 중복 해소(잔존 원본 명시) 중 어디인지 분류하고, 소명 안 되는 substantive 소실이 1건이라도 있으면 **FAIL**(파일 삭제·리네임 0 · 분량 급감 = 누락 신호).
- **소유 UID 최종값 갱신(원칙 7 연동)** — 매니페스트 `version`(원본 = `module.json` `version` 한 곳 — 진입점·설치 리포트가 거기서 읽는다) · 훅 계약 변경 시 센티널 `@버전` · `digests/<ver>-full.json` 재생성(sync 자동 · `--check`·드리프트 게이트 강제) · 지침을 고쳤으면 스탬프 갱신(`version` 은 실질 수정만 · `updated` 는 cosmetic 포함 · 규칙 원본 = 원칙 7). 파일 rename·확장자 변경은 매니페스트 diff + 레거시 sweep 이 자동 회수하므로 별도 UID 불요(훅만 센티널 버전 관리). 갱신 누락 = 소유 오판·유령 잔존·verify FAIL. 기전 = §9·installer-traps.
- **패키지 도구 stdout 인코딩 게이트** — `tools/`·`setup/` Python 도구가 Windows cp949 콘솔/파이프에서 UnicodeEncodeError 로 죽지 않도록 UTF-8 stdout 가드(`reconfigure(encoding="utf-8")`) 표준 · `tools/check_win_encoding.py` 가 `sync --check` 에서 강제(누락 시 FAIL). 상세 = §9·installer-traps.
- **지침 본문 버전 지칭 0** — 원칙 7 의 예외(스탬프·규범 설명 예시·이력 서술·벤더링)를 allowlist 로 두고, 그 밖의 패키지 버전 지칭이 지침 본문(`components/`·`tools/` 데이터)에 0건인지 grep 확인(있으면 FAIL → 조항 이름 지칭으로 치환하거나 관리 대장으로 이관).
- **공식 로드 한계 게이트** — `tools/check_line_budget.py` 가 CLAUDE.md(200줄·4 MiB)·MEMORY.md(200줄·25KB)·스킬(name 64자·desc 1024 코드포인트)·룰(CLAUDE.md 동급)의 **공식 상한** 준수를 `sync --check` 에서 강제(초과 = FAIL). 근거·표·단위(코드포인트 vs 바이트) = §1 「공식 로드 한계」. 임의 수치 self-impose 금지 — 공식 실측치만(§8 하드코딩 금지의 준거).
- **`.ps1` 변경은 pwsh 7 실측** — 구문·.NET regex·헬퍼·개행을 Linux 환경의 pwsh 7 로 재현·검증한 뒤 완료로 친다(PS 5.1 **고유** 런타임·PPT COM 렌더만 실배포 Windows 이연). "테스트 불가·나중에" 미루기 금지(§9 검증 경계).

**금지.** 불신본(revert된 커밋 등)을 "이미 검토됐다"며 근거로 채택 X · 규범을 memory·skill 양쪽에 verbatim 중복 X · 근간 지침을 사용자 의견 없이 자의로 변경 X · 옳은 변경과 틀린 변경을 한 커밋에 뭉침 X · 기존 지침 규범을 소명 없이 삭제·축소·통폐합 X(누락 금지 — 소명 없는 삭제 = FAIL).

---

## 착수 전 체크리스트

- [ ] **형상**: 새 컴포넌트를 §0 형상 표의 어느 칸에? 훅이면 skill-결합(스킬 폴더)인가 횡단(tools/)인가? 폴더 리네임이면 settings bare 경로·`name==folder`·`memory:` 동시 변경?
- [ ] **라이프사이클**: ①저작~⑥제거 중 어느 단계? 특히 ⑥제거(훅 해제·이름기준 회수·캐시 GC) 설계했나?
- [ ] 새 지침: §2 배치 5단계 + **상시 memory 확보** 판정? 집행 요지는 헌법 상시층·근거 상세는 memory?
- [ ] 상시로 넣나 → 넣은 뒤에도 공식 한도(줄 수 **AND 바이트** · §1 「공식 로드 한계」) 안인가(넘으면 인덱스+포인터로 뺄 수 있나)? 기존 문장을 줄였다면 §14 원칙 6 대조표(뜻·조건 누락 0)를 남겼나? 인덱스 한 줄이 원본 Read를 억제하지 않나?
- [ ] **역방향 오독**: 새/수정 문구를 단독 발췌·서브 gist 로 읽어도 의도대로 읽히나(T1~T10 · `references/reverse-misread.md`)? always-on·서브 노출·고손상이면 콜드리드로 확인했나?
- [ ] memory 저작·분할이면: frontmatter·**헌법 포인터+MEMORY.md 색인 등록**·`[[feedback_*]]` 위키링크 상호연결(분할 유지·재병합 X)·description "~할 때" 재저작·분할 기준 "결"·공유절 wikilink·orphan 흡수·union 무손실·`memory:` dangling repoint?
- [ ] 세션시작 훅이면 — **최소 계약**: 예외 exit 0 · 셸 fail-open 한계(launcher) · 복사·복구 읽기 **utf-8-sig**(복사는 바이트 보존) · 복구 정규식 파싱 테스트 · validated fallback · 부재 시 등록 생략+캐시 GC?
- [ ] 훅 품질: native 메모리 복사(본문 주입 아님·`~/.claude/projects/<slug>/memory/`·색인 상시+본문 on-demand)·색인 주입 토글(`BADA_NO_INDEX_INJECT` · 표면별 기본값)·복구 주입만 조건부(compact/resume/fork)·복구 dedup 스코프·compact 리셋·**출력 표출 여부 결정(선별 표출: 기설치 침묵 · 신규설치/복구/이상만 표출 · error.log 상시)**·복구 라벨("적응 가능")? 폐기된 recall 규율(트리거 매칭·aggregate·매핑표) 재건축 안 함?
- [ ] 컴포넌트 저작이면 §13 허브: 해당 **공식 번들 가이드(문법·`references/bundle/`·경로 Read) + 우리 오버레이(이 스킬의 절)를 함께** 봤나? 공식 8종은 원형 유지(고치지 말고 오버레이에 추가)?
- [ ] OS 특정 훅 아님(OS-프리 py·interp 분기·부재 no-op)?
- [ ] 재설계의 존재이유가 **배포 표면**(설치본)에 있나(사본에만 아님)? 미러만 고치고 배포 잊지 않았나?
- [ ] 원본(`components/`)만 고치고 sync 재생성 + `--check` 0? @import·의미편집·맨문자열까지 전파? 배포 위생(개인 잔재 제거)?
- [ ] 리네임·전환이면 이중 lookbehind·확장자 스코프·allowlist·시간축 시뮬? 게이트 통과를 이행으로 착각 안 함? 절대 수치 하드코딩 안 함?
- [ ] 업그레이드(옛 버전 위 덮기) 이중로드·prune? 제거(uninstall) 훅 해제·캐시 회수?
- [ ] 표준부는 공식 참조, 코어(헌법·BADA_HUB·설치기)만 커스텀 — 스캐폴딩 비용 계산? 외부 base 포크는 원형+델타·출처 외부만?
- [ ] 지시 대장 정독(컴팩션 기억 금지)? 스텝 이력 즉시 기록?

## 관련
- 방법론: `skill:skill_LKS_original_plan-execution`(계획 저작·단계 실행) · `skill:skill_LKS_original_multi-session-orchestration`(유닛 설계·서브 스폰) · `skill:skill_LKS_original_review-chunking`
- 규율: `memory:feedback_full_file_read_required` · `memory:feedback_post_edit_runtime_verification` · `memory:feedback_confirmed_items_policy`(4-tier 보고 · §14) · `skill:skill_LKS_original_secured-windows-tooling`
- 상세 함정: `references/installer-traps.md`(언어별 설치기 킬러) · `references/gate-forensics.md`(게이트 개별 사고 실측) · `references/reverse-misread.md`(역방향 오독 렌즈 T1~T10·콜드리드 프로브·교정 원리)
- 공식 참조(외부): Claude Code plugins-reference · agent-skills · hooks · settings

---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_original_project-scaffold
description: >
  Use when setting up a new project's folder layout and git operation,
  maintaining a project's structure map, or applying the git-safety
  procedures — git-initializing a non-git project folder, copy-based work
  on user data, commit-before-risk, and restore-after-breach. Covers the
  standard Claude/{plans,results,docs} layout (Claude-only, no _claude
  copy), the single-source structure map that replaces repeated grep/find
  rediscovery, and step-end commit staging. The folder layout applies to
  new projects only — never retrofit existing ones; the git-safety
  procedures apply anywhere files are modified or deleted (norm =
  memory:feedback_workspace_git_safety).
  트리거: "새 프로젝트", "프로젝트 생성", "프로젝트 구조", "폴더 구조",
  "index.md", "구조 맵", "git init", "git 없는 폴더", "사본 작업",
  "위험 전 커밋", "복원", "롤백".
metadata:
  type: method
---

# Project Scaffold (신규 프로젝트 구조·구조 맵)

Claude 단독 환경에서 신규 프로젝트의 표준 폴더 구조·구조 맵·git 운영, 그리고 작업물 보호(git-safety) 절차를 정할 때의 규율.

## 적용 조건

두 축으로 적용한다.

1. **폴더 구조·구조 맵** — 기존 구조가 없는 새 프로젝트를 생성할 때. **기존 프로젝트에 폴더 구조를 소급 적용하지 않는다**(신규 한정). 경량 작업엔 자동 설치하지 않는다.
2. **작업물 보호 절차(§3)** — git화·사본 작업·위험 전 commit·침범 복원이 필요한 모든 시점. **이 축은 신규·기존 프로젝트를 가리지 않는다**(파일 수정·삭제가 일어나는 곳이면 어디든 — 규범 원본 = `memory:feedback_workspace_git_safety`, 본 스킬은 그 절차·기전만 소유한다).

## 핵심 원칙

### 1. 신규 프로젝트 표준 폴더 구조

신규 프로젝트(사용자 별도 지시 없을 시) 기본 구조:

- `<프로젝트>/Claude/plans/` — 계획서
- `<프로젝트>/Claude/results/` — 산출물(코드·문건·도식·표) · 스텝 이력 · 핸드오프(`handoffs/` 하위)
- `<프로젝트>/Claude/docs/` — Claude 측 작업 대상 문건 · 인계(handover) 문건

에이전트 산출물은 `Claude/` 폴더로 격리한다 — repo 루트·`docs/` 직속에 섞어 두면 세션 간 복구·인계가 어렵다. 글로벌 지침·memory 는 `~/.claude` 단일 소스에서 자동 로드되므로 프로젝트별 사본(`_claude/`)을 만들지 않는다.

### 2. 구조 맵 유지 — 재조사 대신 참조

본격 프로젝트는 **폴더·파일·문서 구조 맵**을 원본 한 곳(마스터 플랜 또는 `Claude/docs/INDEX.md`)에 두고, 구조 변경(파일·폴더 추가·삭제·이동·이름변경)이 생길 때마다 **그 자리에서 즉시 맵을 갱신**한다(갱신 안 하면 그 단계는 미완).

- 구조를 알아야 할 때는 grep·find 재조사가 아니라 이 맵을 1차 참조한다.
- 맵과 실물 불일치가 의심될 때(또는 맵이 없을 때)만 실물을 1회 확인하고, 확인했으면 그 결과로 맵을 갱신한다.
- 맵이 없으면 매 세션·매 작업마다 grep·find로 구조를 재발견해 같은 토큰을 반복 소모한다 — 단일 원본 맵 + 변경 시 갱신이 그 반복 비용을 없앤다.

### 3. 작업물 보호 — 규범은 memory, 절차는 여기

파일 수정·삭제의 공간 규율(git 안에서만·위험 전 commit·밖은 읽기만·유일 예외·침범 복원)의 **규범 원본 = `memory:feedback_workspace_git_safety`** 다. 본 스킬은 그 규범을 실행하는 **절차·기전**(아래 실행 방법 3a~3e)만 소유하며 규범 문구를 재정의하지 않는다.

**★ 범위 구분(혼동 금지)** — 위 1·2 의 "폴더 구조·구조 맵 소급 금지"는 **`Claude/{plans,results,docs}` 레이아웃**을 기존 프로젝트에 강요하지 말라는 것이고(아래 「예외·금지」의 소급 금지 줄), 아래 안전용 `git init`·사본은 **작업물 파손을 막는 안전 절차라 신규/기존을 가리지 않는다.** "기존 프로젝트에 Claude/ 레이아웃을 소급하지 않는다"와 "수정 전 복원 지점을 위해 그 폴더를 git 확보한다"는 서로 다른 행위다(git init 은 `.git/` 하나를 새로 만들 뿐 사용자 파일을 건드리지 않는다 — 단 그 `.git/` 의 제거[`rm -rf .git`]는 커밋된 복원 지점을 소멸시키는 파괴 작업이라 ⑥의 평문 사전 확인 없이 행하지 않는다).

## 실행 방법

- 새 프로젝트 셋업(git init 직후) `Claude/plans/`·`Claude/results/` 신설, `.gitkeep`.
- 계획서는 무조건 `Claude/plans/<plan-name>.md`에 저장한다(대화 본문에만 적고 끝내지 말 것). 양식은 `skill:skill_LKS_original_plan-execution` 「① 계획 착수 시」의 11-section(비코드 작업은 부적합 section 을 **접을 수 있다 — 섹션명·순서는 보존**·삭제 아님 · 원본 = plan-execution 1b).
- 구조 맵은 트리(폴더·주요 파일) + 문서 목록(무엇이 어디에)으로 적고, 구조 변경 commit과 같은 단위에서 갱신한다.
- **스텝 끝 commit 시 staging**: 스텝이 끝날 때(스텝 체계가 없는 작업은 작업 토픽이 끝날 때) commit 한다. commit할 때 그 스텝에서 만들고 고친 파일과 `Claude/` 를 이름으로 staging 한다(`git add Claude/ <경로>…`) — `git add -A` 는 도는 서브(저부하 helper 포함)가 하나도 없을 때만(도는 서브의 편집이 검토 없이 들어간다 · `skill:skill_LKS_original_instruction-architecture` §12). 단 `_local_only/` 등 gitignore 대상을 확인한다. push·merge 시점은 헌법 「품질·원천·git」 줄(원본)을 따른다.

### 작업물 보호 절차 (3a~3e · 규범 원본 = memory:feedback_workspace_git_safety)

- **3a. 판정·경로 결정**: 대상 경로에서 `git rev-parse --is-inside-work-tree`(또는 `git -C <dir> rev-parse --is-inside-work-tree`) → true = git 안(통상 작업). false/에러 = git 밖 → 기존 파일의 수정·삭제가 필요하면: 프로젝트 폴더 → 3b / 사용자 데이터·git화 부적절 → 3c / 사용자가 해당 파일 명시 지정 → 백업(사본 확보) 먼저 후 직접 수정(유일 예외). 애매하면 3c 사본.
- **3b. 비-git 프로젝트 폴더의 git화**: ① 작업물이 사는 프로젝트 폴더인지 확인(사용자 데이터 폴더면 3c로) → ② `git init` → ③ 필요 시 `.gitignore`(대용량·비밀·캐시) → ④ `git add -A && git commit`(예: "baseline: pre-work state") — **작업 전 원상태가 최초 커밋**이 되게 한다(이 커밋이 최후 복원 지점) → ⑤ 이후 통상 commit 규율(스텝 끝 · 원본 = 헌법 「품질·원천·git」). 이 git init 은 복원 지점 확보이지 신규-프로젝트 구조 스캐폴딩 소급이 아니다(§3 범위 구분).
- **3c. 사용자 데이터 사본 작업**: ① 수용 repo 선택 — 현재 활성 프로젝트 repo 의 `Claude/results/work/<주제>/`, 없으면 세션 작업 공간에 임시 repo `git init`(휘발 공간이면 결과물 회수 계획을 먼저) → ② 원본을 사본으로 복사(원본 무손상) → ③ **사본을 즉시 commit = 원본 상태 보존**(이것이 백업) → ④ 사본 위에서 작업·commit → ⑤ **인도(write-back)**: 결과를 원위치에 반영해야 하고 **사용자가 그 반영을 지시·승인**했으면 그 원본 경로는 유일 예외(④) 경로다 — ③의 원본 보존 커밋이 백업 요건을 이미 충족한 상태에서 반영하고, 반영 사실을 보고한다. 지시·승인이 없으면 원본에 반영하지 않고 사본 위치·결과를 보고로 종료한다.
- **3d. 위험 전 commit**: 평문 사전 확인 대상인 파괴·비가역 작업(대량 삭제·일괄 치환·in-place 변환·`git reset --hard`·`git clean -fdx`·force-push·이력 조작 등)이면 전부 — ① `git status --porcelain` 확인 → ② 미커밋 변경이 있으면 commit(복원 지점 먼저) → ③ 실행. 그 평문 사전 확인을 언제 받고 실행 중 언제 멈추나는 다시 적지 않고 원본을 따른다(원본 = `memory:feedback_flow_interruption` 「사전 확인(원본)」 · git 이 그 확인을 면제하지 않는다 · 중첩 = `memory:feedback_workspace_git_safety` ⑥). 단 **일괄 치환·in-place 변환**은 이미 전부 커밋된 clean git 안이면 git 복원으로 가역이라 애초에 멈출 대상이 아니다(대량 삭제·`git reset --hard`·`rm -rf .git`·`git clean -fdx`·force-push·이력 조작은 clean status 여부와 무관하게 복원 지점을 먼저 만든다 — 대량 삭제·`git reset --hard` = 사전 커밋 · 나머지 넷 = 저장소 밖 사본·백업 · §11 에 없고 그 복원 지점도 못 만들 때만 멈춰 확인 · 원본 = `memory:feedback_workspace_git_safety` ②). commit 은 권한자(분업 시 master)가 한다. 이 위험-전 commit 은 스텝 끝 commit 과 **별개의 추가 트리거**다(스텝 끝을 기다리지 않는다).
- **3e. 침범 시 복원**: ① 침범 인지 즉시 추가 수정 중지 → ② **복원 전 스냅샷**: 현 상태를 commit(복원 조작 자체가 미커밋 변경을 소거할 수 있다) → ③ `git log --oneline` 으로 침범 없는 커밋 식별 → ④ 파일 단위 `git restore --source=<commit> -- <path>`(국소 우선) / 트리 단위 `git reset --hard <commit>` → ⑤ diff 로 복원 확인 후 재진행하고 보고에 복원 사실 명시 → ⑥ 비-git·복원 지점 없음·복원 불완전 = 그 작업 중지·사용자 보고(헌법 정지 조건 「보호영역 침범」 유지). 롤백 권한·격리는 `skill:skill_LKS_original_multi-session-orchestration` 「격리」(master git reset)와 정합.

## 예외·금지

- 기존 프로젝트에는 이 폴더 구조를 소급 적용하지 않는다.
- global 지침·memory의 project-local 사본인 `_claude/`를 새로 만들지 않는다.
- `_local_only/` 등 gitignore 대상은 사용자가 명시하지 않으면 staging하지 않는다.
- 사용자 홈·Downloads 등 사용자 데이터 공간을 사본(3c) 대신 리포화하지 않는다(3b 의 `git init` 은 프로젝트 폴더 전용의 정상 절차다) — 프로젝트/데이터 판별이 애매하면 3c 사본. commit 없이 파괴·비가역 강행 금지. git 안이라는 이유로 `rm -rf .git`·`git clean -fdx`·force-push 의 사전 확인을 면제하지 않는다 — 그 확인은 계획 §11 「멈출 일 미리 점검」에 따로 적어 받는다(git 은 undo 일 뿐).
- 3a~3e 는 절차일 뿐 규범을 대체하지 않는다 — 적용 여부·예외 판단은 `memory:feedback_workspace_git_safety` 를 따른다.

## 관련 문건

- `skill:skill_LKS_original_plan-execution` — 계획서 양식·저장 위치(「① 계획 착수 시」)
- `skill:skill_LKS_original_multi-session-orchestration` — 분업 상세
- `memory:feedback_workspace_git_safety` — 작업물 보호(git-safety) 규범 원본(본 스킬 §3·3a~3e 절차의 상위 규범)

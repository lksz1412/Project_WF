# 포인터 해석표 (생성물 — 직접 수정 금지)

헌법과 스킬이 쓰는 포인터 형식이 이 저장소에서 가리키는 실제 경로다.

| 포인터 | 실제 경로 |
|---|---|
| `memory:feedback_<stem>` | `.claude/BADA_HUB/feedback_<stem>.md`(설치 후 `~/.claude/BADA_HUB/`) — 세션시작 훅이 프로젝트 native 메모리 영역에 확보하고 색인 `MEMORY.md` 를 주입한다 |
| `skill:<name>` | `.claude/skills/<name>/SKILL.md` — **`Skill` 도구로 로드한다** |
| `tools/<name>`(예: `ab_precompare.py`·`banned_lexicon.json`) | 설치 후 `~/.claude/tools/<name>` · 이 저장소에선 `.claude/tools/<name>`(설치기 배포 구성과 같은 도구 묶음을 옮겨 둠 · SessionStart 훅도 여기의 `BADA_recall.py` 를 부른다) |
| 격하된 번들 문법 가이드 | `.claude/skills/skill_LKS_original_instruction-architecture/references/bundle/<name>/GUIDE.md` — **경로 `Read`**(Skill 도구 로드 아님) |

**`skill:` 는 파일을 직접 `Read` 하지 않는다** — 설치본이 아닌 저장소 사본을 읽으면
적용되는 지침이 실물과 갈라진다. Skill 도구가 로드하는 활성본이 판단 근거다.

## 이 환경의 제약

→ **`.claude/ENVIRONMENT.md`** 를 본다. 원격 Linux 컨테이너 선언과 PowerShell 자산
미실행 목록이 거기 있다.

# 이 저장소의 활성 지침 — 1.4.9 (저장소용 사본 · MATLAB 줄 없음)

이 저장소에서 여는 **모든 세션**(웹·로컬·앞으로 열릴 세션 전부)은 설정 패키지 1.4.9 의
헌법·BADA_HUB rule·스킬·커맨드·서브 정의를 **로컬 설치본과 같은 구성으로** 적용받는다.

@.claude/CLAUDE.md

@.claude/ENVIRONMENT.md

@.claude/POINTERS.md

---

## 경계

| 구분 | 경로 | 성격 |
|---|---|---|
| **원본** | `lksz1412/Project_skills` 의 `Settings_Installer/Settings_for_Claude/components/` | 지침을 고치는 곳은 여기뿐 |
| **사본** | 이 저장소 `.claude/` | Project_skills 의 저장소용 사본(`.claude/`) + 배포 구성 도구(`.claude/tools/`)를 옮겨 온 것. **직접 수정 금지** |
| **저장소 운용 문서** | 이 파일(루트 `CLAUDE.md`) | 손으로 관리 |

지침 판을 올릴 때 = Project_skills 에서 `components/` 를 고치고 `sync_repo_claude.sh` 로 그쪽 `.claude/` 를 다시 만든 뒤, 그 `.claude/` 와 배포 구성 `tools/` 를 이 저장소 `.claude/` 로 다시 옮긴다(훅 경로·`ENVIRONMENT.md`·`POINTERS.md`·`CLAUDE.md` 머리 배너는 이 저장소 경로 `.claude/tools/` 기준으로 맞춘다).

## 현재 버전 — 1.4.9

원본 커밋 = Project_skills `main` `fa59acc0`.

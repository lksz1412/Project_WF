#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""BADA_HUB memory sync hook — SessionStart 에서 상시 지침 memory 를 프로젝트 native 메모리 영역에 확보하고 색인을 주입한다.

동작 계약
  - 확보: 전 PC 공용 원본(루트 BH 폴더 `~/.claude/BADA_HUB/feedback_*.md`)을 현재
    프로젝트의 native 메모리 영역 `~/.claude/projects/<slug>/memory/` 에 확보한다.
    native 메모리는 프로젝트 특화라 전 PC 공용이 안 되므로, 공용 원본에서 프로젝트별로
    세션마다 확보해 색인 상시 + 본문 on-demand 로 작동시킨다.
    `<slug>` = 프로젝트 루트 경로의 비영숫자를 `-` 로 치환(예 `/home/user/skills`→`-home-user-skills`).
    프로젝트 루트 = 세션이 시작된 폴더(`CLAUDE_PROJECT_DIR` · 없으면 입력 `cwd`)가 든 git 저장소의
    최상위(워크트리면 주 저장소 · 저장소 밖이거나 판정 실패면 그 폴더) — Claude Code auto-memory 와
    같은 규칙이라 하위 폴더·`cd` 뒤·워크트리가 한 폴더를 함께 쓴다.
  - 갱신 구동 = 콘텐츠 다이제스트: 소스 memory 집합의 해시를 native `.bada_sync.json` 에
    저장하고, 다이제스트가 다르면(버전업·편집·추가·삭제) 재복사 + prune, 같으면 침묵한다.
    매니페스트 비의존이라 소스 폴백 사슬 전부에서 작동한다.
  - 색인 주입: CC auto-memory 리더가 native 색인을 세션에 자동 로드하지 않는 표면이
    있으므로, 리더에 기대지 않고 매 세션 색인(MEMORY.md)을 additionalContext 로 직접
    주입한다. 소스 색인을 읽어 주입하므로 native 미존재 첫 세션에서도 확보된다.
    본문은 on-demand. 리더가 정상인 표면은 BADA_NO_INDEX_INJECT=1 로 주입을 해제한다.
  - 조건부 recall 주입·스킬 넛지·트리거 매칭은 두지 않는다(컴팩션 복구 주입 1건만 예외).
  - 출력 한도: Claude Code 는 additionalContext 가 OUTPUT_CAP 문자를 넘으면 파일로 빼고 앞
    2,000자 미리보기만 대화에 싣는다(값 하나마다 따로 센다). 그래서 한 번에 내는 글을 OUTPUT_BUDGET
    안에서 조립한다 — 순서 = 상태줄 → 복구 본문(compact·resume·fork · 온전히 · 뒤에 다시 읽을 것 목록) →
    색인(남은 자리). 남은 자리에 다 안 들어가는 조각은 줄 단위로 잘라 들어가는 만큼만 싣고 끝에 그 파일
    경로 줄을 붙인다(복구 본문이 잘리면 경로 줄 뒤에 다시 읽을 것 목록을 남긴다). compact·resume·fork 에서는
    복구 본문과 색인이 한 값에 다 안 들어가므로 색인을 따로 싣는다 —
    settings 에 이 파일을 두 번 등록한다(본체 = 인자 없음 · 색인 전용 = --index-only). 두 등록은 같은
    이벤트에 나란히 돌므로 색인 전용은 native 메모리를 쓰지 않고 읽기만 한다.

개인화 우선순위(개인화 > 공용 사본)
  소유 판별 = 이름 목록이다(prefix 아님): 갱신·prune 은 (소스 파일명 집합 ∪ 스탬프에 기록된
  이전 소유 ∪ 레거시 memory_*.md)+`MEMORY.md`+`.bada_sync.json` 만 대상으로 한다. 소유 밖
  feedback_*·user_*·project_*·reference_* 파일(auto-memory 개인화)은 절대 건드리지 않는다.
  동명 충돌(소유 기록 없는 기존 파일을 소스가 덮어야 할 때)은 덮기 전 `.userbak` 백업을 남긴다.
  충돌 시 개인화가 공용 사본을 덮는다(헌법 §0-A: 프롬프트 > 프로젝트 오토메모리 > memory).

계약
  - stdin  = JSON {hook_event_name, cwd, source, ...}
  - stdout = JSON {"hookSpecificOutput": {"hookEventName": "SessionStart",
                    "additionalContext": <안내 문구>}}  (침묵 시 stdout 무출력)
  - fail-open: 어떤 오류도 세션을 막지 않는다 — 빈 출력 + exit 0,
    사유는 stderr 와 상태 디렉터리 error.log 에 남긴다(관측 가능).

경로
  source(공용 BH 원본) 해소 사슬: MEMORY_SRC|BADA_DIR env → ~/.claude/BADA_HUB →
    $CLAUDE_PROJECT_DIR/.claude/BADA_HUB(미러) →
    $CLAUDE_PROJECT_DIR/Settings_Installer/Settings_for_Claude/components/global/BADA_HUB(패키지 원본)
  target(프로젝트 native 메모리): ~/.claude/projects/<slug>/memory/
stdlib 전용(PyYAML 미사용). UTF-8 전수 명시(Windows cp949 기본 인코딩 함정 회피).
"""

import hashlib
import json
import os
import re
import shutil
import sys
import time
import traceback
from pathlib import Path

HOOK_VERSION = "v8-feedback"   # 다이제스트+훅버전 구동 갱신 · 개인화 실측 색인 등록 · 소유 판별 = 이름목록(prefix 아님)
MEMORY_GLOB = "feedback_*.md"   # 상시 지침 memory 파일. MEMORY.md 색인은 별도 동반 관리.
LEGACY_GLOBS = ("memory_*.md",)   # 구판 파생 캐시 prefix — 발견 시 회수(개인화가 쓴 적 없는 패키지 전용 prefix)
INDEX_NAME = "MEMORY.md"
SYNC_STAMP = ".bada_sync.json"   # native 에 남기는 동기화 스탬프(다이제스트·버전·시각·소유 이름목록)
RECOVERY_MEMORY = "feedback_compaction_recovery"   # compact·resume·fork 시 본문 1회 주입(순수 복구용 · 넛지 아님)
# 복구 라벨 = 한 순서(규칙 파일 재독 → 6-check → 나머지 복구 읽기)의 명령. 규범 원본 = 복구 memory 「핵심 원칙」.
LABEL = ("[컴팩션 복구 지침 — 새 편집 전 한 순서로 이행한다: 먼저 이 글 끝의 「다시 읽을 것」(규칙 파일)을 "
         "다시 읽고 → 아래 6-check(1 = 대기열 사용자 메시지 대조부터)를 순서대로 → 나머지 복구 읽기:]")
# 입력에 agent_id 가 있으면(서브 안에서 훅이 돈 것 · 공식 hooks 문서 common input fields) 서브 몫으로 적는다.
# 서브 몫 = 규칙 파일 재독 뒤 6-check·나머지 복구 읽기 대신 발주문·입력 파일·기록 재독(원본 = 복구 memory 「핵심 원칙」 머리 문단).
# 길이를 늘리지 않는다 — 상태줄이 붙는 세션에서도 라벨+복구 본문+목록이 OUTPUT_BUDGET 안에 온전히 들어가야 한다.
SUB_LABEL = ("[컴팩션 복구 지침 — 이 세션은 서브(Agent 도구로 뜬 세션)다: 새 편집 전 이 글 끝의 「다시 읽을 것」(규칙 파일)을 "
             "먼저 다시 읽고, 6-check·나머지 복구 읽기(master 몫) 대신 자기 발주문·받은 메시지·발주문이 입력으로 정한 "
             "파일·기록을 전문 재독한다 — 요청 대장·계획 문건에 쓰지 않고 발주문 밖 기록은 읽지 않는다:]")
INDEX_LABEL = ("[상시 지침 메모리 색인 — 이 세션에 로드됨(훅 주입). 지금 하려는 작업이 헌법 줄의 적용 조건에 "
               "해당하면(애매하면 해당으로 보고) 그 줄의 memory:feedback_<주제> 파일을 Read 해 정독한다:]")
# 복구 본문 뒤에 붙이는 다시 읽을 것 목록 — 규범(무엇을 왜)은 복구 memory 「복구 읽기 순서」, 여기는 실제 경로만.
READ_LIST_LABEL = "[컴팩션·재개 뒤 첫 판단 전에 다시 읽을 것(6-check 보다 먼저) — 훅이 찾은 경로:]"
# 서브는 6-check 를 하지 않으므로 목록이 앞서는 것은 서브 몫 재독이다(원본 = 복구 memory 「핵심 원칙」 머리 문단).
SUB_READ_LIST_LABEL = "[컴팩션·재개 뒤 첫 판단 전에 다시 읽을 것(서브 몫 재독보다 먼저) — 훅이 찾은 경로:]"
READ_LIST_MEMORIES = ("feedback_communication_style", "feedback_flow_interruption")
READ_LIST_SKILLS = ("skill_LKS_original_plan-execution", "skill_LKS_original_multi-session-orchestration")
INDEX_ONLY_FLAG = "--index-only"             # 색인 전용 등록의 인자
# 복구 본문을 싣는 source — 본체 값은 복구 본문이 차지하므로 색인은 색인 전용 값으로 싣는다.
SPLIT_SOURCES = ("compact", "resume", "fork")

# Claude Code 훅 출력 한도: additionalContext 필드 하나가 10,000 문자를 넘으면 파일로 빠지고 앞
# 2,000자 미리보기만 실린다(공식 hooks 문서 · 올릴 설정 없음). 문자 수 = UTF-16 단위로 센다
# (BMP 밖 글자 = 2 · 코드포인트보다 크거나 같아 보수적).
OUTPUT_CAP = 10000
OUTPUT_MARGIN = 500                          # 한도 여유(셈 방식·줄바꿈 정규화 차이 흡수)
OUTPUT_BUDGET = OUTPUT_CAP - OUTPUT_MARGIN   # 훅이 한 번에 내는 글의 상한
PART_SEP = "\n\n"
RECOVERY_REST = "[복구 본문 나머지 = {} — 훅 출력 한도로 여기까지만 실었다 · 지금 Read 해 마저 이행]"
INDEX_REST = "[색인 나머지 = {} — 훅 출력 한도로 여기까지만 실었다 · 컴팩션 뒤 첫 판단 전에 읽을 파일]"


# ---------------------------------------------------------------- 경로

def _source_dir():
    """memory 원본 디렉터리 해소. 설치본 → 저장소 미러 → 패키지 원본 폴백 사슬."""
    env = os.environ.get("MEMORY_SRC") or os.environ.get("BADA_DIR")
    if env:
        return Path(env)
    home = Path.home() / ".claude" / "BADA_HUB"
    if home.is_dir() and any(home.glob(MEMORY_GLOB)):
        return home
    proj = os.environ.get("CLAUDE_PROJECT_DIR")
    if proj:
        mirror = Path(proj) / ".claude" / "BADA_HUB"
        if mirror.is_dir() and any(mirror.glob(MEMORY_GLOB)):
            return mirror
        pkg = (Path(proj) / "Settings_Installer" / "Settings_for_Claude" / "components"
               / "global" / "BADA_HUB")
        if pkg.is_dir() and any(pkg.glob(MEMORY_GLOB)):
            return pkg
    return home  # 미존재 — SessionStart health 라인이 가시화한다


def _state_dir():
    return Path(os.environ.get("BADA_STATE_DIR")
                or (Path.home() / ".claude" / ".cache" / "BADA_recall"))


def _git_toplevel(path):
    """path 가 든 git 저장소의 최상위 폴더. 워크트리면 주 저장소의 최상위. 저장소 밖이거나
    판정할 수 없으면 None. 외부 명령 없이 파일로 판정한다 — path 에서 위로 올라가며 `.git` 을 찾고,
    디렉터리면 그 부모가 최상위 · 파일(워크트리·서브모듈)이면 `gitdir:` 이 가리키는 폴더의
    `commondir` 로 주 저장소 `.git` 을 찾아 그 부모(`commondir` 가 없거나 주 `.git` 이 아니면
    `.git` 파일이 든 폴더)."""
    try:
        cur = os.path.abspath(str(path))
        while True:
            dotgit = os.path.join(cur, ".git")
            if os.path.isdir(dotgit):
                return cur
            if os.path.isfile(dotgit):
                return _linked_worktree_main(cur, dotgit)
            parent = os.path.dirname(cur)
            if parent == cur:
                return None
            cur = parent
    except (OSError, ValueError):
        return None


def _linked_worktree_main(worktree, dotgit_file):
    """`.git` 파일(`gitdir: <경로>`)로 이어진 워크트리 → 주 저장소 최상위. 읽기·형식 실패면 None."""
    with open(dotgit_file, encoding="utf-8-sig") as f:
        first = f.readline().strip()
    if not first.startswith("gitdir:"):
        return None
    gitdir = first[len("gitdir:"):].strip()
    if not gitdir:
        return None
    gitdir = os.path.normpath(os.path.join(worktree, gitdir))   # 상대 경로는 워크트리 기준
    common_file = os.path.join(gitdir, "commondir")
    if not os.path.isfile(common_file):
        return worktree                   # 서브모듈 등 — 링크 폴더 자체가 저장소 최상위
    with open(common_file, encoding="utf-8-sig") as f:
        common = f.readline().strip()
    common = os.path.normpath(os.path.join(gitdir, common))   # 보통 "../.." → 주 저장소 .git
    if os.path.basename(common) == ".git" and os.path.isdir(common):
        return os.path.dirname(common)
    return worktree                       # 주 저장소가 bare 등 — 작업 폴더가 따로 없다


def _project_root(data):
    """native 메모리 폴더를 정할 프로젝트 루트. 세션이 시작된 폴더(CLAUDE_PROJECT_DIR — 세션 중
    `cd`·워크트리 진입에도 그대로) → 없으면 훅 입력 cwd(`cd` 뒤엔 하위 폴더일 수 있다) → 그 폴더가 든
    git 저장소 최상위(워크트리면 주 저장소). 저장소 밖이거나 판정 실패면 그 폴더 그대로."""
    base = os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or os.getcwd()
    return _git_toplevel(base) or base


def _native_memory_dir(root):
    """프로젝트 루트의 Claude Code native 메모리 영역 = ~/.claude/projects/<slug>/memory/.
    <slug> = 절대경로의 비영숫자(밑줄·점 포함 · [^A-Za-z0-9])를 '-' 로 치환 — Claude Code
    projectSlug() 규칙과 일치(밑줄 '_' 도 '-'). 예 /home/user/my_project → -home-user-my-project.
    (CC 는 200자 초과 시 절단+해시 append 하나 해시 함수 미공개라 그 경계는 미복제 · 희귀 경로.)"""
    slug = re.sub(r"[^A-Za-z0-9]", "-", str(root))
    return Path.home() / ".claude" / "projects" / slug / "memory"


def _source_set(source):
    """source 의 공용 사본 파일 목록(feedback_*.md + MEMORY.md), 이름 정렬. Path 리스트."""
    files = sorted(source.glob(MEMORY_GLOB), key=lambda p: p.name)
    idx = source / INDEX_NAME
    if idx.is_file():
        files.append(idx)
    return files


def _digest(files):
    """공용 사본 집합의 콘텐츠 다이제스트. 정렬된 (이름\\0바이트내용) 을 SHA-256.
    이름·개수·본문 어느 것이 바뀌어도 다이제스트가 변한다 → 버전업/편집/추가/삭제 감지."""
    h = hashlib.sha256()
    for f in sorted(files, key=lambda p: p.name):
        try:
            data = f.read_bytes()
        except OSError:
            continue
        h.update(f.name.encode("utf-8", "surrogateescape"))   # 비-UTF-8 파일명(서로게이트) 크래시 방어
        h.update(b"\0")
        h.update(str(len(data)).encode("ascii"))
        h.update(b"\0")
        h.update(data)
        h.update(b"\0")
    return h.hexdigest()


def _source_version(source):
    """안내 문구용 버전 문자열. 설치 홈이면 ~/.claude/.bada_manifest 의 version 줄,
    미해소면 None(호출측이 다이제스트 short-hash 로 갈음)."""
    # source 가 ~/.claude/BADA_HUB 이면 형제 ~/.claude/.bada_manifest 를 읽는다.
    for cand in (source.parent / ".bada_manifest",
                 Path.home() / ".claude" / ".bada_manifest"):
        try:
            if cand.is_file():
                for line in cand.read_text(encoding="utf-8").splitlines():
                    if line.startswith("version "):
                        parts = line.split(None, 1)   # 값 없는 "version " 줄 방어(IndexError 차단)
                        if len(parts) == 2 and parts[1].strip():
                            return parts[1].strip()
        except (OSError, UnicodeError):   # 손상 매니페스트의 디코드 오류도 강등(UnicodeError ⊂ ValueError)
            pass
    return None


def _read_stamp(target):
    """native 의 .bada_sync.json 을 읽어 {'digest':..,'version':..} 반환. 없으면 {}."""
    p = target / SYNC_STAMP
    try:
        if p.is_file():
            return json.loads(p.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        pass
    return {}


def _stamp_owned(stamp):
    """스탬프의 소유 이름목록(패키지가 심었던 이름) — 문자열만 · 없거나 형식이 다르면 빈 집합."""
    owned = stamp.get("owned") if isinstance(stamp, dict) else None
    if not isinstance(owned, list):
        return set()
    return {n for n in owned if isinstance(n, str)}


def _write_stamp(target, digest, version, owned=()):
    p = target / SYNC_STAMP
    try:
        p.write_text(json.dumps(
            {"digest": digest, "version": version,
             "owned": sorted(owned),   # 소유 이름목록(prune 스코프 · prefix 비의존)
             "hook": HOOK_VERSION,
             "synced_at": time.strftime("%Y-%m-%d %H:%M:%S")},
            ensure_ascii=False), encoding="utf-8")
    except (OSError, UnicodeError) as e:   # 스탬프는 캐시라 세션은 계속 · 소유 목록을 잃으므로 사유를 남긴다
        _log_error("BADA_recall {}: 동기화 스탬프 쓰기 실패 — {} ({}) · 다음 세션이 다시 갱신하고, "
                   "소유 기록이 없어 원본에서 사라진 공용 사본은 개인화로 남을 수 있다."
                   .format(HOOK_VERSION, p, e))


# 개인화 memory 색인 등록 — native 에 실재하는 auto-memory 개인화(사용자 저작)를 실측 스캔해
# 공용 색인에 전용 섹션으로 등록한다. 감지는 prefix 가 아니라 "공용 소유 밖 *.md" 차집합이라
# 하이픈·언더스코어·임의 이름을 모두 포착한다. frontmatter 파싱은 stdlib 정규식(PyYAML 없음).
PERSONAL_HEADER = "## 개인화 memory (이 환경 한정 · 훅 자동 등록)"

_FM_KEY_RE = re.compile(r"^([A-Za-z0-9_-]+):[ \t]*(.*)$")   # frontmatter 최상위 스칼라 키(컬럼0)


def _frontmatter_block(text):
    """맨 앞 --- … --- frontmatter 본문(사이 텍스트)만 반환. 없으면 "". 선행 BOM 허용."""
    if text[:1] == "\ufeff":
        text = text[1:]                       # 선행 BOM 제거(정규식 밖에서 판정)
    m = re.match(r"---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(?:\r?\n|$)", text, re.DOTALL)
    return m.group(1) if m else ""


def _unescape_dq(s):
    r"""YAML 큰따옴표 스칼라 이스케이프 해제. \" → " · \\ → \ · \n\t\r 는 공백(색인은 한 줄) ·
    나머지 \x 는 x 그대로. 한 번의 선형 스캔이라 중첩 치환 순서 오류가 없다."""
    out, i, n = [], 0, len(s)
    while i < n:
        c = s[i]
        if c == "\\" and i + 1 < n:
            out.append({"n": " ", "t": " ", "r": " "}.get(s[i + 1], s[i + 1]))
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def _unquote(raw):
    r"""YAML 스칼라 인용 해제. 큰따옴표(\" \\ 이스케이프)·작은따옴표('' 이스케이프)·비인용.
    description 의 : § ① " \ 를 안전 처리한다(값 한 줄을 통째 판정 · 정규식 split 아님)."""
    raw = raw.strip()
    if len(raw) >= 2 and raw[0] == '"' and raw[-1] == '"':
        return _unescape_dq(raw[1:-1]).strip()
    if len(raw) >= 2 and raw[0] == "'" and raw[-1] == "'":
        return raw[1:-1].replace("''", "'").strip()
    return raw


def _fm_scalar(block, field):
    """frontmatter block 에서 최상위(비들여쓰기) 스칼라 키 field 의 값. 없으면 None.
    들여쓴 중첩 키(metadata 하위)는 컬럼0 매칭이 아니라 자동 무시 · 첫 출현만."""
    for line in block.splitlines():
        m = _FM_KEY_RE.match(line)
        if m and m.group(1) == field:
            return _unquote(m.group(2))
    return None


def _personalization_files(target, source_names):
    """native target 의 개인화 memory 파일 목록(Path·이름 정렬). 개인화 = target 의 *.md 중
    (공용 소스 이름집합 ∪ MEMORY.md ∪ 레거시 memory_*.md) 에 없는 것. prefix 무관(하이픈·
    언더스코어·임의 포착). *.userbak 은 *.md 매칭이 아니라 자동 제외 · 동명 공용 사본도 제외."""
    if not target.is_dir():
        return []
    src_set = set(source_names)
    legacy = set()
    for g in LEGACY_GLOBS:
        legacy |= {p.name for p in target.glob(g)}
    out = []
    for p in sorted(target.glob("*.md"), key=lambda q: q.name):
        n = p.name
        if n == INDEX_NAME or n in src_set or n in legacy:
            continue
        out.append(p)
    return out


def _index_line(path):
    """개인화 파일 1개 → 공용 색인 줄과 동일 포맷 `- **`name`** — desc`. frontmatter name·
    description 를 정규식 추출한다. 읽기/디코드 실패나 name 미추출은 stem 폴백 + error.log 관측
    (개인화는 정상 시 frontmatter name 을 가진다). description 없으면 이름만(— 생략)."""
    name = desc = None
    failed = False
    try:
        block = _frontmatter_block(path.read_text(encoding="utf-8"))
        if block:
            name = _fm_scalar(block, "name")
            desc = _fm_scalar(block, "description")
    except (OSError, UnicodeError) as e:   # 손상·비-UTF-8 개인화 파일도 stem 폴백으로 강등
        failed = True
        _log_error("BADA_recall {}: 개인화 memory 읽기/디코드 실패 — {} ({})."
                   .format(HOOK_VERSION, path.name, e))
    name = (name or "").strip()
    desc = (desc or "").strip()
    if not name:
        if not failed:
            _log_error("BADA_recall {}: 개인화 memory frontmatter name 미추출 — {} (stem 폴백)."
                       .format(HOOK_VERSION, path.name))
        name = path.stem
    if desc:
        return "- **`{}`** — {}".format(name, desc)
    return "- **`{}`**".format(name)


def _personalization_section(target, source_names):
    """개인화 색인 섹션(헤더 + 각 줄) 반환. 개인화 0건이면 "". 개별 파일 실패는 _index_line 이
    stem 으로 흡수한다(전체 섹션은 계속 구성)."""
    files = _personalization_files(target, source_names)
    if not files:
        return ""
    lines = [_index_line(p) for p in files]
    return PERSONAL_HEADER + "\n\n" + "\n".join(lines) + "\n"


def _merge_index(source_index_text, target, source_names=()):
    """공용 BH 색인(source_index_text)을 베이스로, native 에 실재하는 auto-memory 개인화를
    실측 스캔해 전용 섹션으로 등록한 병합본을 반환한다. 개인화 = native *.md − (공용 소스 이름집합
    ∪ MEMORY.md ∪ 레거시 memory_*.md) — prefix 무관(하이픈·언더스코어 다 포착). 개인화 0건이면
    공용 색인 그대로. 베이스가 소스 색인이고 개인화는 매 병합 재스캔이라 중복 누적 없음(멱등).
    개인화 스캔의 어떤 실패도 공용 색인 확보를 폐기하지 못하게 강등한다(fail-open)."""
    try:
        section = _personalization_section(target, source_names)
    except Exception as e:
        _log_error("BADA_recall {}: 개인화 색인 병합 실패(공용 색인만 사용) — {}."
                   .format(HOOK_VERSION, e))
        return source_index_text
    if not section:
        return source_index_text
    return source_index_text.rstrip() + "\n\n" + section


def _sync_memories(source, target, prev_owned=()):
    """공용 사본(feedback_*.md + MEMORY.md)을 target 으로 재복사하고, **소유했던** 공용 사본 중
    소스에서 사라진 것과 레거시 파생 캐시(memory_*.md)만 prune 한다. 소유 판별 = 이름 목록
    (소스 집합 ∪ prev_owned) — 소유 밖 feedback_*(auto-memory 개인화)는 절대 건드리지 않는다.
    동명 충돌(소유 기록에 없는 기존 파일 위에 소스를 덮어야 할 때)은 덮기 전 `.userbak` 백업.
    MEMORY.md 는 통째 덮지 않고 auto-memory 개인화 색인 줄을 병합 보존한다.
    (복사 수, 소유 이름목록) 반환."""
    target.mkdir(parents=True, exist_ok=True)
    prev = set(prev_owned)
    src_files = sorted(source.glob(MEMORY_GLOB))
    src_names = {f.name for f in src_files}
    wanted = set()
    n = 0
    for f in src_files:
        dst = target / f.name
        if dst.is_file() and f.name not in prev:
            # 소유 기록에 없는 동명 기존 파일 = 사용자 개인화 가능성 — 덮기 전 백업(관측 가능).
            try:
                if dst.read_bytes() != f.read_bytes():
                    shutil.copy2(dst, target / (f.name + ".userbak"))
                    _log_error("BADA_recall {}: 동명 개인화 충돌 — {} 를 {}.userbak 으로 백업 후 "
                               "공용 사본으로 덮음(개인화는 auto-memory 다른 이름 권장)."
                               .format(HOOK_VERSION, f.name, f.name))
            except OSError:
                pass
        shutil.copy2(f, dst)
        wanted.add(f.name)
        n += 1
    idx = source / INDEX_NAME
    if idx.is_file():
        wanted.add(INDEX_NAME)
    # prune 을 색인 병합보다 먼저 한다 — 병합의 개인화 스캔이 지워질 옛 공용 사본을 개인화 줄로 담지 않게.
    # prune: (이전 소유 ∪ 레거시 memory_*.md) − 이번 소유. 소유 밖 feedback_* 은 후보에 안 들어간다.
    prune_names = (prev - wanted)
    for g in LEGACY_GLOBS:
        prune_names |= {p.name for p in target.glob(g)}
    for name in sorted(prune_names):
        p = target / name
        if p.is_file() and name not in wanted:
            try:
                p.unlink()
            except OSError:
                pass
    if idx.is_file():
        try:
            src_text = idx.read_text(encoding="utf-8")
            # 개인화 = 소유 밖 — 지우지 못한 옛 소유 사본도 개인화 줄로 담지 않는다.
            merged = _merge_index(src_text, target, src_names | prev)   # auto-memory 색인 줄 보존
            (target / INDEX_NAME).write_text(merged, encoding="utf-8")
        except (OSError, UnicodeError):   # 손상 색인 디코드 오류 포함 → 바이트 복사로 강등
            shutil.copy2(idx, target / INDEX_NAME)     # 병합 실패 시 최소한 소스 색인은 확보
    return n, sorted(wanted)


def _index_text_for_injection(source, target):
    """세션에 주입할 상시 색인 (텍스트, 읽은 파일 경로, 읽기 실패 경로 목록). native(auto-memory 개인화
    병합본) 우선, 없으면 소스 색인. 둘 다 없으면 ("", None, 실패 목록). 소스를 읽으므로 chicken-egg(native
    미존재 첫 세션)에서도 색인이 확보된다. 경로는 색인이 출력 한도로 잘릴 때 나머지를 Read 할 곳으로 쓴다."""
    failed = []
    for cand in (target / INDEX_NAME, source / INDEX_NAME):
        try:
            if cand.is_file():
                t = cand.read_text(encoding="utf-8-sig").strip()
                if t:
                    return t, cand, failed
        except (OSError, UnicodeError):   # 손상 색인 후보의 디코드 오류도 강등 → 다음 후보/""
            failed.append(cand)
    return "", None, failed


def _is_package_mirror(mirror, package_dir):
    """<부모>/.claude/CLAUDE.md 가 이 패키지의 sync 미러인가 — 머리 생성물 배너(「이 파일은 생성물이다」 ·
    「원본: <패키지 자리>/components/…」)의 패키지 자리를 그 부모 기준으로 풀어 package_dir 과 같을 때만. 읽기 실패 = 아님."""
    try:
        with open(mirror, encoding="utf-8-sig") as f:
            head = f.read(2048)
    except (OSError, UnicodeError):
        return False
    if "이 파일은 생성물이다" not in head:
        return False
    for line in head.splitlines():
        text = line.strip()
        if text.startswith("원본:") and "/components/" in text:
            rel = text[len("원본:"):].strip().split("/components/", 1)[0]
            try:
                return (mirror.parent.parent / rel).resolve() == package_dir
            except (OSError, ValueError):
                return False
    return False


def _constitution_path():
    """다시 읽을 것 목록에 적을 헌법 파일 = 훅이 있는 쪽. 설치본(~/.claude/tools/)이면 그 위의 CLAUDE.md,
    저장소(<프로젝트>/Settings_Installer/Settings_for_Claude/tools/ 등)면 위로 올라가며 만나는 <부모>/.claude/CLAUDE.md 가운데
    이 패키지의 sync 미러인 첫 것(_is_package_mirror). 판정 실패·맞는 것 없음이면 설치본 자리."""
    try:
        tools_dir = Path(__file__).resolve().parent
        if tools_dir.parent.name == ".claude":
            return tools_dir.parent / "CLAUDE.md"
        for parent in tools_dir.parents:
            mirror = parent / ".claude" / "CLAUDE.md"
            if mirror.is_file() and _is_package_mirror(mirror, tools_dir.parent):
                return mirror
    except (NameError, OSError, ValueError):
        pass
    return Path.home() / ".claude" / "CLAUDE.md"


def _read_list(memory_dir, index_injected=True, sub=False):
    """복구 본문 뒤에 붙일 다시 읽을 것 목록(실제 경로). memory 는 복구 본문을 읽은 폴더 기준.
    색인 줄은 색인을 훅이 따로 싣는 세션(주입 켜짐)에만 적는다 — 꺼진 세션에는 그 값이 없다.
    sub = 서브 안에서 돈 훅(입력 agent_id) — 목록 머리를 서브 몫으로 적는다."""
    lines = [SUB_READ_LIST_LABEL if sub else READ_LIST_LABEL, "- 헌법: {}".format(_constitution_path())]
    for name in READ_LIST_MEMORIES:
        lines.append("- memory: {}".format(Path(memory_dir) / (name + ".md")))
    if index_injected:
        lines.append("- 색인: 따로 실린 색인 값(잘렸으면 그 끝 줄의 나머지 파일)")
    lines.append("- 스킬(Skill 도구로 다시 부름): {}".format(" · ".join(READ_LIST_SKILLS)))
    return "\n".join(lines)


def _read_body(path):
    """memory 파일에서 frontmatter 제거한 본문 반환. 실패 시 "". 선행 BOM 은 utf-8-sig 로 벗긴다
    (BOM 이 남으면 frontmatter 경계를 못 찾아 frontmatter 까지 본문으로 주입된다)."""
    try:
        text = path.read_text(encoding="utf-8-sig")
    except (OSError, UnicodeError):   # 손상 복구파일의 디코드 오류도 강등 → 복구본만 스킵
        return ""
    if text.startswith("---"):
        parts = text.split("\n---", 1)
        if len(parts) == 2:
            return parts[1].lstrip("-\n").strip()
    return text.strip()


# ---------------------------------------------------------------- 출력 조립(한도 안)

def _ctx_len(text):
    """Claude Code 가 세는 문자 수의 보수적 추정 = UTF-16 단위 수(BMP 밖 글자 = 2)."""
    return len(text.encode("utf-16-le", "surrogatepass")) // 2


def _cut_units(text, limit):
    """text 를 앞에서부터 limit UTF-16 단위 이하로 자른다(글자 중간을 쪼개지 않는다)."""
    out, used = [], 0
    for ch in text:
        width = 2 if ord(ch) > 0xFFFF else 1
        if used + width > limit:
            break
        out.append(ch)
        used += width
    return "".join(out)


def _fit_block(label, text, rest_line, avail):
    """label + 줄바꿈 + text 를 avail(UTF-16 단위) 안에 맞춰 (블록, 잘렸나) 반환.
    다 들어가면 그대로. 넘치면 text 를 줄 단위로 앞에서부터 들어가는 만큼만 싣고 rest_line
    (나머지 파일 경로 줄)을 끝 줄로 붙인다. label 과 rest_line 조차 안 들어가면 rest_line 한 줄,
    그것도 안 들어가면 빈 블록."""
    whole = label + "\n" + text
    if _ctx_len(whole) <= avail:
        return whole, False
    tail = _ctx_len(rest_line)
    used = _ctx_len(label)
    kept = [label]
    for line in text.split("\n"):
        need = 1 + _ctx_len(line)
        if used + need + 1 + tail > avail:
            break
        kept.append(line)
        used += need
    if used + 1 + tail <= avail:
        return "\n".join(kept) + "\n" + rest_line, True
    if tail <= avail:
        return rest_line, True
    return "", True


def _assemble_context(status, recovery, index, budget=OUTPUT_BUDGET):
    """상태줄 → 복구 본문 → 색인 순으로 budget(UTF-16 단위) 안에서 이어 붙인다.
    recovery·index = (머리 라벨, 본문, 나머지 경로 줄) 또는 None. 앞 조각이 자리를 먼저 차지하고
    뒤 조각은 남은 자리만큼 줄 단위로 잘린다. (글, (복구 잘림, 색인 잘림)) 반환 · 글이 없으면 ""."""
    out = ""
    if status:
        out = status if _ctx_len(status) <= budget else _cut_units(status, budget)
    cut = []
    for piece in (recovery, index):   # 순서 = 복구 본문 먼저 → 색인(남은 자리만)
        if not piece:
            cut.append(False)
            continue
        sep = PART_SEP if out else ""
        avail = budget - _ctx_len(out) - _ctx_len(sep)
        block, was_cut = _fit_block(piece[0], piece[1], piece[2], avail)
        if block:
            out += sep + block
        cut.append(was_cut)
    return out, tuple(cut)


# ---------------------------------------------------------------- SessionStart

def handle_session_start(data):
    source_kind = data.get("source") or ""
    target = _native_memory_dir(_project_root(data))   # 프로젝트 루트의 native 메모리 영역
    source = _source_dir()             # 전 PC 공용 BH 원본

    # native 메모리 확보(복사)는 매 세션 조용히 수행한다. 갱신은 콘텐츠 다이제스트로 구동한다.
    # 표출 규칙:
    #  - 소스 다이제스트 == native 스탬프 → 침묵(최신 · 매 세션 반복 상태줄은 오염).
    #  - native 에 공용 사본 0개 → 신규 설치(전부 복사) → 안내 1회.
    #  - 다이제스트 불일치(버전업·편집·추가·삭제) → 갱신(재복사 + prune) → 안내 1회.
    #  - 공용 BH 원본 미존재(설치 이상) → 안내.
    #  - compact/resume/fork → 복구 안내(아래).
    # prune·재복사 = 소유 이름목록 + 레거시 memory_*.md 만 → auto-memory 개인화(소유 밖) 무손실.
    status = None
    memory_present = False
    if source.is_dir() and any(source.glob(MEMORY_GLOB)):
        memory_present = True
        src_digest = _digest(_source_set(source))
        version = _source_version(source) or ("dg-" + src_digest[:8])
        legacy = target.is_dir() and any(any(target.glob(g)) for g in LEGACY_GLOBS)
        present = (target.is_dir() and any(target.glob(MEMORY_GLOB))) or legacy
        stamp = _read_stamp(target)
        if (present and not legacy and stamp.get("digest") == src_digest
                and stamp.get("hook") == HOOK_VERSION):
            pass                              # 다이제스트·훅버전 모두 최신 — 상태줄 침묵(색인 주입은 아래서 별도)
        else:
            # native 확보 실패(권한·디스크·손상)를 격리한다 — 아래 색인 주입은 소스만 있으면
            # 되므로, sync 실패가 색인 주입까지 폐기하지 않게 블록을 가둔다(fail-open 강등).
            try:
                n, owned = _sync_memories(source, target, _stamp_owned(stamp))
                _write_stamp(target, src_digest, version, owned)
                if not present:
                    status = ("[BADA_HUB sync {} · native 메모리 {}개 신규 설치 (ver {}) · {}]"
                              .format(HOOK_VERSION, n, version, target))
                else:
                    old = stamp.get("version") or "unknown"
                    status = ("[BADA_HUB sync {} · native 메모리 갱신 {}→{} · 공용 사본 {}개 "
                              "(개인화 auto-memory 는 보존) · {}]"
                              .format(HOOK_VERSION, old, version, n, target))
            except Exception as e:
                _log_error("BADA_recall {}: native 메모리 확보 실패(색인 주입은 계속) — {}"
                           .format(HOOK_VERSION, e))
                status = ("[BADA_HUB sync {} — native 메모리 확보 실패 (색인 주입은 계속 · {})]"
                          .format(HOOK_VERSION, target))
    else:
        status = ("[BADA_HUB sync {} — 공용 BH 원본 미존재: {} "
                  "(native 메모리 확보 불가 — 설치 상태 점검 필요)]"
                  .format(HOOK_VERSION, source))

    # 조각마다 만들고(서로 격리 — 한 조각 실패가 다른 조각을 막지 않는다) 끝에 한도 안에서 조립한다.
    # 상시 색인 주입 — CC auto-memory 리더 비의존.
    # 배경: 일부 표면(Claude Code on the web·원격 repo 세션 등)에서 CC 가 native MEMORY.md
    # 색인을 세션에 자동 로드하지 않음이 실측됐다(헌법이 상정한 "색인 상시 로드" 미보장). 반면
    # 이 훅의 additionalContext 는 그 표면에서도 확실히 전달된다(상태줄·복구본문 실측). 그래서
    # 죽은 리더에 기대지 않고, 살아있는 채널로 색인을 실어 매 세션 색인 도달을 보장한다. 소스
    # 색인을 읽으므로 native 미존재 첫 세션(chicken-egg)에서도 확보된다. 본문(feedback_*.md)은
    # 그대로 on-demand(포인터→Read).
    # 토글: BADA_NO_INDEX_INJECT 가 1/true/yes/on 이면 주입 해제(CC 리더 정상 표면용).
    # 0/false/빈값/미설정은 주입 ON(안전 기본 — 미지 표면은 도달 보장 쪽으로 실패).
    # 표면별 기본값: 로컬 설치(대다수·CC 리더 정상)=OFF(1) 기본 · repo 미러(클라우드·리더 부재)=ON(0).
    inject_off = _inject_off()
    index_piece = None
    # compact·resume·fork 의 색인은 색인 전용 등록(handle_index_only)이 따로 싣는다 — 복구 본문과 한 값에 다 안 들어간다.
    if memory_present and not inject_off and source_kind not in SPLIT_SOURCES:
        # 색인 주입 실패가 status·복구 조각을 폐기하지 못하게 격리한다.
        try:
            idx_text, idx_path, idx_failed = _index_text_for_injection(source, target)
            for bad in idx_failed:
                _log_error("BADA_recall: 색인 MEMORY.md 읽기 실패(손상·디코드·입출력 오류) — {}".format(bad))
            if idx_text:
                index_piece = (INDEX_LABEL, idx_text, INDEX_REST.format(idx_path))
            else:
                # feedback_*.md 는 있으나 색인(MEMORY.md)이 없거나 비었거나 읽히지 않는 경우 — 색인 도달
                # 보장이 조용히 무력화되는 빈틈. 세션은 막지 않되(fail-open), 관측 가능하게 남긴다.
                _log_error("BADA_recall: feedback_*.md 존재하나 색인 MEMORY.md {} "
                           "— 색인 주입 스킵됨 (source={}).".format(
                               "읽기 실패" if idx_failed else "부재/빈 값", source))
        except Exception as e:
            _log_error("BADA_recall: 색인 주입 실패(status·복구는 유지) — {}".format(e))

    # 컴팩션·재개 직후 = 맥락 소실 최고위험 → 복구지침 본문을 1회 주입한다(넛지 아님 · 이벤트 훅).
    # 조용한 오토컴팩션(사용자 발화 없음)에도 SessionStart source=compact 로 도달한다.
    # 이 경우는 무음화 대상이 아니다 — 사용자가 컨텍스트 오염 가능을 인지하는 계기이므로 유지한다.
    recovery_piece = None
    if source_kind in SPLIT_SOURCES:
        # 복구본 주입 실패가 status·색인 조각을 폐기하지 못하게 격리한다.
        try:
            # native 우선, 없거나 본문이 비면(손상 포함) source 사본으로 폴백한다.
            # 손상된 native 파일이 멀쩡한 source 복구본을 가리지 못하게(존재만으로 폴백 차단 X).
            body, present, body_path = "", False, None
            for rp in (target / (RECOVERY_MEMORY + ".md"),
                       source / (RECOVERY_MEMORY + ".md")):
                if rp.is_file():
                    present = True
                    body = _read_body(rp)
                    if body:
                        body_path = rp
                        break
            if body:
                # 목록 조립 실패가 복구 본문을 폐기하지 못하게 격리한다(본문만이라도 싣는다).
                text, rest = body, RECOVERY_REST.format(body_path)
                try:
                    read_list = _read_list(body_path.parent, not inject_off, bool(data.get("agent_id")))
                    text = body + PART_SEP + read_list
                    rest = rest + "\n" + read_list   # 복구 본문이 한도에 잘려도 목록은 경로 줄 뒤에 남긴다
                except Exception as e:
                    _log_error("BADA_recall: 다시 읽을 것 목록 조립 실패(복구 본문만 싣는다) — {}".format(e))
                label = SUB_LABEL if data.get("agent_id") else LABEL
                recovery_piece = (label, text, rest)
            elif present:
                # 파일은 있으나 본문이 비거나 손상 — 최고위험(compact) 시점의 무음 강등을 관측화.
                _log_error("BADA_recall: 복구본 파일 존재하나 본문 비거나 손상 — 복구 주입 스킵 "
                           "(source_kind={}).".format(source_kind))
        except Exception as e:
            _log_error("BADA_recall: 복구본 주입 실패(status·색인은 유지) — {}".format(e))

    # 한도 안 조립: 상태줄 → 복구 본문(온전히 먼저) → 색인(남은 자리 · 넘치면 줄 단위로 자르고 경로 줄).
    try:
        context, (recovery_cut, _index_cut) = _assemble_context(status, recovery_piece, index_piece)
        if recovery_cut:
            # 복구 본문조차 한도에 다 안 들어감 = 복구 본문이 너무 커졌다 — 경로 줄로 강등하되 관측화.
            _log_error("BADA_recall {}: 복구 본문이 출력 한도({}) 를 넘어 잘림 — 나머지는 경로 줄로 안내."
                       .format(HOOK_VERSION, OUTPUT_BUDGET))
    except Exception as e:
        # 조립 실패도 세션을 막지 않는다 — 같은 순서로 이어 붙이고 코드포인트 기준 절반으로 잘라
        # UTF-16 셈으로도 한도를 넘지 않게 한다.
        _log_error("BADA_recall: 출력 조립 실패(순서대로 잘라 강등) — {}".format(e))
        pieces = [status] + [p[0] + "\n" + p[1] for p in (recovery_piece, index_piece) if p]
        context = PART_SEP.join(x for x in pieces if x)[:OUTPUT_BUDGET // 2]

    if not context:
        return None                       # 정상 startup — 무음(stdout 에 아무것도 쓰지 않는다)
    return {"hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context}}


def _inject_off():
    """BADA_NO_INDEX_INJECT 값 기반 토글(1·true·yes·on = 색인 주입 끔)."""
    return (os.environ.get("BADA_NO_INDEX_INJECT", "").strip().lower()
            in ("1", "true", "yes", "on"))


def handle_index_only(data):
    """색인 전용 등록 — compact·resume·fork 에서 색인만 한 값으로 싣는다(본체 값은 복구 본문이 차지).
    본체 등록과 같은 이벤트에 나란히 돌므로 native 메모리를 쓰지 않는다: 소스 색인을 읽고 native 의
    개인화 파일만 읽어 병합한다(native MEMORY.md 는 본체가 고쳐 쓰는 중일 수 있어 읽지 않는다)."""
    if (data.get("source") or "") not in SPLIT_SOURCES or _inject_off():
        return None
    source = _source_dir()
    if not (source.is_dir() and any(source.glob(MEMORY_GLOB))):
        return None
    src_index = source / INDEX_NAME
    try:
        text = src_index.read_text(encoding="utf-8-sig").strip() if src_index.is_file() else ""
    except (OSError, UnicodeError) as e:
        _log_error("BADA_recall: 색인 전용 — 색인 MEMORY.md 읽기 실패(손상·디코드·입출력 오류) — "
                   "색인 주입 스킵됨 (source={} · {}).".format(source, e))
        return None
    if not text:
        _log_error("BADA_recall: 색인 전용 — 색인 MEMORY.md 부재/빈 값 — 색인 주입 스킵됨 (source={})."
                   .format(source))
        return None
    target = _native_memory_dir(_project_root(data))
    # 개인화 = 소스 이름 ∪ 스탬프 소유 밖 — 원본에서 사라졌으나 본체가 아직 prune 하지 않은 공용 사본을 개인화로 싣지 않는다.
    names = {p.name for p in source.glob(MEMORY_GLOB)} | _stamp_owned(_read_stamp(target))
    text = _merge_index(text, target, names).strip()
    rest_path = target / INDEX_NAME if (target / INDEX_NAME).is_file() else src_index
    context, _cut = _assemble_context(None, None, (INDEX_LABEL, text, INDEX_REST.format(rest_path)))
    if not context:
        return None
    return {"hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": context}}


# ---------------------------------------------------------------- 진입점

def _log_error(exc_text):
    try:   # 로깅 자체가 fail-open 을 깨지 못하게(닫힌·BrokenPipe stderr 방어)
        sys.stderr.write("BADA_recall fail-open:\n" + exc_text + "\n")
    except Exception:
        pass
    try:
        state_dir = _state_dir()
        state_dir.mkdir(parents=True, exist_ok=True)
        # errors="backslashreplace": 서로게이트(비-UTF-8 파일명) 섞인 사유도 사유를 버리지 않고
        # 이스케이프해 기록한다 — 계약의 "사유를 error.log 에 관측 가능하게" 를 서로게이트에서도 지킨다.
        with open(state_dir / "error.log", "a", encoding="utf-8",
                  errors="backslashreplace") as f:
            f.write("[{}] {}\n".format(
                time.strftime("%Y-%m-%d %H:%M:%S"), exc_text))
    except (OSError, UnicodeError):
        pass


def main():
    try:  # fail-open: 훅이 죽어 세션을 막는 쪽이 복사 실패보다 훨씬 나쁘다.
        for stream in (sys.stdout, sys.stderr):
            if hasattr(stream, "reconfigure"):
                # errors="backslashreplace": 서로게이트 섞인 stderr 사유도 크래시 없이 관측 가능하게.
                stream.reconfigure(encoding="utf-8", errors="backslashreplace")
        data = json.loads(sys.stdin.buffer.read().decode("utf-8", errors="replace"))
        # 비-dict stdin(예 42·[]·"foo")은 무작업 강등 — .get AttributeError 대신 조용히 통과.
        if isinstance(data, dict) and data.get("hook_event_name") == "SessionStart":
            index_only = INDEX_ONLY_FLAG in sys.argv[1:]
            out = handle_index_only(data) if index_only else handle_session_start(data)
            if out is not None:
                sys.stdout.write(json.dumps(out, ensure_ascii=False))
                sys.stdout.write("\n")
    except BaseException:   # 계약 문구 "어떤 오류도" — 신호·SystemExit 까지 세션을 막지 않는다
        try:
            _log_error(traceback.format_exc())
        except Exception:
            pass
    sys.exit(0)


if __name__ == "__main__":
    main()

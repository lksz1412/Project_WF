# 참조 — 모델·effort 지정 샘플 (정의 파일·띄우기·실측)

`SKILL.md` 「② 첫 스폰 직전 → 모델·effort 지정」 절의 하위 참조. 서브의 모델·effort 를 **서브 정의 파일**로 거는 실물 형식과, 서브가 돌아온 뒤 **실제로 뜬 모델을 확인**하는 명령을 담는다. 표 1·2(거는 곳·고를 수 있는 값)는 `SKILL.md` 에 있다.

## 정의 파일 형식 (한 개)

역할별 정의는 `components/agents/bada-*.md`(설치 뒤 `~/.claude/agents/bada-*.md`)에 둔다. frontmatter 가 모델·effort·도구·최대 턴을 고정한다.

```markdown
---
name: bada-b-auditor
description: "B 적대 감사(읽기 전용 · 고치지 않음). master 가 subagent_type 으로 이 이름을 지정할 때만 쓴다."
model: claude-opus-5-5
effort: high
disallowedTools:
  - Edit
  - Write
  - NotebookEdit
  - Agent
---
너는 이 패키지 분업 배분의 B 적대 감사 서브다. 모델과 effort 는 이 정의가 고정한다.
(역할·경계·보고 형식 — 5항목 고지와 같은 뜻을 여기에 싣는다)
```

- `model` = 전체 ID(`claude-opus-5-5` 등) · 별칭 · `inherit`(=master 모델). 전체 ID 는 Claude Code 2.1.74 이상에서 먹고, Opus 4.7·4.8·Fable 5 의 `effort` 적용은 2.1.267 이상이다. 설정 `modelSettings`(모델별 effort)는 2.1.251 이상이다. Agent 도구 호출 인자 `effort`(정의 `effort` 를 이긴다)는 2.1.292 이상이다 — 이 패키지는 넘기지 않는다(공식 문서 `sub-agents`).
- 정의 폴더는 **세션 시작 때 있어야** 읽힌다 — 세션 도중 새로 만든 첫 정의는 재시작해야 잡힌다. 설치본은 `~/.claude/agents/` 에, 저장소에 미러(`.claude/agents/`)를 두는 경우는 그 저장소에서 새로 연 세션부터 정의가 읽힌다.
- 읽기 전용 역할(`bada-b-auditor`·`bada-a3-reviewer`·`bada-fable-auditor`)만 `disallowedTools` 로 편집·스폰 도구를 막는다. 나머지는 도구를 좁히지 않는다.

## 띄우기

- **정의 파일로**: Agent 도구 `subagent_type: "bada-b-auditor"` · 호출 인자 `model` 은 넘기지 않는다(넘기면 별칭이 정의를 이긴다). effort 는 정의 파일이 정한다.
- **새 세션으로**(사용자가 지목할 때만): `create_session(model: "claude-opus-5-5", source_url: <저장소>, source_revision: <브랜치>, prompt: <발주문>)` — effort 칸이 없어 모델 기본 effort 로 뜬다. 부른 세션에 답을 보낼 수 없으므로 결과는 커밋·푸시로 받는다.

## 다시 부르기 · 서브 상태 (같은 A·B 를 이어 쓸 때)

- **다시 부르기**: 끝난 서브에 `SendMessage(to: <띄울 때 준 이름 또는 agentId>, message: <다음 발주>)` — 그 서브가 자기 기록에서 이어 깨어 같은 context 로 일한다. 새 Agent 호출은 새 세션이라 다시 부르기가 아니다. 부를 서브의 이름·`agentId` 는 핸드오프 폴더 세션 대장 `SESSIONS.md` 에 적어 둔다(`SKILL.md` 「다시 부르는 법 · 세션 대장」).
- **서브 상태 확인**(다시 부르기 전 · master): 아래 명령이 이 세션의 서브마다 정의 이름 · `agentId` · 컴팩션 횟수 · 그 기록의 자동 컴팩션 문턱(`compactMetadata.preTokens`) · 마지막 응답의 입력 토큰 합(지금 context) · 쓰다 끊겨 건너뛴 기록 줄 수(`깨진 줄`)를 낸다. 판정 = 컴팩션됐나(→ 같은 서브를 다시 부르며 발주문에 입력 전문 재독을 싣는다 · 원본 = `memory:feedback_compaction_recovery` 「컴팩션된 서브」). 아래 두 명령의 첫 줄 `python3` 은 Mac/Linux 판이다 — Windows 에서는 `python` 으로 바꿔 실행한다(사람이 실행하는 명령 규칙 = 헌법 「Windows Python」 · 나머지 본문은 그대로).

```bash
python3 - <<'PY'
import glob, json, os, re, subprocess
def slug(p): return re.sub(r"[^A-Za-z0-9]", "-", p)                      # Claude Code 규칙(비영숫자 → '-')
roots = [os.environ.get("CLAUDE_PROJECT_DIR", "")]                         # ① 세션이 시작된 프로젝트 루트
try:                                                                       # ② git 저장소 최상위(워크트리면 주 저장소)
    g = subprocess.run(["git", "rev-parse", "--git-common-dir"], capture_output=True, text=True).stdout.strip()
    roots.append(os.path.dirname(os.path.abspath(g)) if g else "")
except OSError:
    pass
roots.append(os.getcwd())                                                  # ③ 지금 폴더
dirs = [os.path.expanduser("~/.claude/projects/" + slug(r)) for r in dict.fromkeys(r for r in roots if r)]
sid = os.environ.get("CLAUDE_CODE_SESSION_ID", "")
fs = [d + "/" + sid + ".jsonl" for d in dirs if sid and os.path.isfile(d + "/" + sid + ".jsonl")]
fs = fs or next((glob.glob(d + "/*.jsonl") for d in dirs if glob.glob(d + "/*.jsonl")), [])
if not fs:
    raise SystemExit("세션 기록(.jsonl)을 못 찾음 — 찾아본 폴더: " + ", ".join(dirs))
f = max(fs, key=os.path.getmtime)                                          # master 세션 기록 → 그 아래 subagents/
for a in sorted(glob.glob(f[:-len(".jsonl")] + "/subagents/agent-*.jsonl"), key=os.path.getmtime):
    rows, bad = [], 0
    for x in filter(str.strip, open(a, encoding="utf-8", errors="replace")):
        try:
            rows.append(json.loads(x))
        except ValueError:                                                 # 쓰다 끊긴 줄(재시작 직후 등)은 세고 건너뛴다
            bad += 1
    pre = [r["compactMetadata"].get("preTokens") for r in rows if r.get("subtype") == "compact_boundary" and r.get("compactMetadata")]
    use = [r["message"]["usage"] for r in rows if isinstance(r.get("message"), dict) and r["message"].get("usage")]
    ctx = sum(use[-1].get(k, 0) for k in ("input_tokens", "cache_read_input_tokens", "cache_creation_input_tokens")) if use else 0
    m = a[:-len(".jsonl")] + ".meta.json"
    meta = json.load(open(m, encoding="utf-8")) if os.path.isfile(m) else {}
    print(meta.get("agentType"), os.path.basename(a)[len("agent-"):-len(".jsonl")], "컴팩션", len(pre),
          "문턱", pre[-1] if pre else "-", "context", ctx, "깨진 줄", bad, "|", meta.get("description", ""))
PY
```

## 실제로 뜬 모델 확인 (서브가 돌아온 뒤 · 배분표와 다르면 그 결과를 쓰지 않고 멈춰 보고·재발주)

Windows 에서는 첫 줄 `python3` 을 `python` 으로 바꿔 실행한다(위 「서브 상태 확인」과 같은 규칙).

```bash
python3 - <<'PY'
import glob, json, os, re, subprocess
def slug(p): return re.sub(r"[^A-Za-z0-9]", "-", p)                      # Claude Code 규칙(비영숫자 → '-')
roots = [os.environ.get("CLAUDE_PROJECT_DIR", "")]                         # ① 세션이 시작된 프로젝트 루트
try:                                                                       # ② git 저장소 최상위(워크트리면 주 저장소)
    g = subprocess.run(["git", "rev-parse", "--git-common-dir"], capture_output=True, text=True).stdout.strip()
    roots.append(os.path.dirname(os.path.abspath(g)) if g else "")
except OSError:
    pass
roots.append(os.getcwd())                                                  # ③ 지금 폴더
dirs = [os.path.expanduser("~/.claude/projects/" + slug(r)) for r in dict.fromkeys(r for r in roots if r)]
sid = os.environ.get("CLAUDE_CODE_SESSION_ID", "")                         # 있으면 이 세션의 기록 파일을 바로 고른다
fs = [d + "/" + sid + ".jsonl" for d in dirs if sid and os.path.isfile(d + "/" + sid + ".jsonl")]
fs = fs or next((glob.glob(d + "/*.jsonl") for d in dirs if glob.glob(d + "/*.jsonl")), [])
if not fs:
    raise SystemExit("세션 기록(.jsonl)을 못 찾음 — 찾아본 폴더: " + ", ".join(dirs))
f = max(fs, key=os.path.getmtime)                                          # 가장 최근 세션 기록
meta = f[:-len(".jsonl")] + "/subagents/agent-{}.meta.json"                # 서브마다 정의 이름(agentType)이 남는 곳
for line in open(f, encoding="utf-8"):
    try:
        r = json.loads(line).get("toolUseResult")
    except (ValueError, AttributeError):
        continue
    if not (isinstance(r, dict) and r.get("resolvedModel")):
        continue
    kind = r.get("agentType")                                              # 백그라운드 발주 결과엔 없다 → meta 파일에서
    m = meta.format(r.get("agentId"))
    if not kind and os.path.isfile(m):
        kind = json.load(open(m, encoding="utf-8")).get("agentType")
    print(kind, r["resolvedModel"], r.get("agentId"), r.get("totalTokens"), r.get("totalDurationMs"))
PY
```

- 출력 = 정의 이름(`agentType`) · 실제 모델(`resolvedModel`) · `agentId` · `totalTokens` · `totalDurationMs`. 정의 이름이 결과 기록에 없으면(백그라운드 발주) 같은 세션 폴더의 `subagents/agent-<agentId>.meta.json` 에서 가져온다 — 이 짝으로 정의 이름과 실제 모델을 아래 표와 맞춰 본다. 백그라운드 발주 행은 발주 시점 기록이라 토큰·시간이 비어 있다. 세션 기록 폴더는 세션이 시작된 프로젝트 루트(`CLAUDE_PROJECT_DIR`) → 그 git 저장소 최상위(워크트리면 주 저장소) → 지금 폴더 순으로 찾는다.
- 배분표와 다르면(예: 정의가 안 읽혀 master 모델로 뜸) 그 결과를 쓰지 않는다 — 멈춰 사용자에게 보고하고, 원인을 바로잡은 뒤 다시 발주한다(임의 대체 금지 · 헌법 「배정 폴백·장애」 줄).
- **effort 는 이 결과 기록에는 없다**(결과 전체에 effort 필드가 없다) → 세션 기록의 assistant 행 `effort`·`perTurnEffort` 칸으로 본다(서브 = `subagents/agent-<agentId>.jsonl` · Claude Code 2.1.308 이상 실측) · 정의 파일이 그 값을 정하고, 사용자는 `/tasks`(2.1.243)에서도 서브가 실제로 돈 모델·effort 를 본다.
- 새 세션(`create_session`)의 모델은 세션 조회(`get_session`)의 `session_context.model` · `last_served_model` 로 확인한다.

## 서브 기록 대조 (master · 서브가 적은 읽은 범위·실행 판정 줄을 기록과 맞춰 봄 · 다시 돌리지 않음)

서브 기록(`subagents/agent-<agentId>.jsonl`)의 도구 호출과 그 결과를 짝지어 뽑는다 — `Read` 면 파일·`offset`·`limit` · 결과가 실제로 보인 줄 범위(`보임 <첫 줄>-<끝 줄>`) · 잘렸으면 그 알림(`잘림 [Truncated: PARTIAL view — …]` — 기록의 `attachment` 행 `read_truncation_notice`), `Bash` 면 명령 첫 줄 · 결과 끝 줄(`끝 줄 …` — 결과가 커서 파일로 빠졌으면[`<persisted-output>`] 끝 줄 대신 `결과 파일로 빠짐 — <경로>` · 판정 줄은 그 파일에서 찾는다). 결과가 오류면 `오류` 를 붙인다. 서브 work_log·보고의 「읽은 범위」·명령 줄·판정 줄과 맞춰 보고, 어긋나면(적었는데 호출이 없음 · 범위가 모자람 · 잘린 Read 를 전문으로 적음 · 판정 줄이 결과 끝 줄과 다름) 그 서브 산출을 열화 반환으로 다룬다(`SKILL.md` 「master의 통합 책임」). 판정 줄이 결과 끝 줄보다 앞에 찍힌 줄이면 그 서브의 스크래치 원 출력이나 기록 원문에서 그 줄을 찾는다. 첫 인자로 `agentId` 일부를 주면 그 서브만 낸다. Windows 에서는 첫 줄 `python3` 을 `python` 으로 바꾼다.

```bash
python3 - "$1" <<'PY'
import glob, json, os, re, subprocess, sys
def slug(p): return re.sub(r"[^A-Za-z0-9]", "-", p)                      # Claude Code 규칙(비영숫자 → '-')
roots = [os.environ.get("CLAUDE_PROJECT_DIR", "")]                         # ① 세션이 시작된 프로젝트 루트
try:                                                                       # ② git 저장소 최상위(워크트리면 주 저장소)
    g = subprocess.run(["git", "rev-parse", "--git-common-dir"], capture_output=True, text=True).stdout.strip()
    roots.append(os.path.dirname(os.path.abspath(g)) if g else "")
except OSError:
    pass
roots.append(os.getcwd())                                                  # ③ 지금 폴더
dirs = [os.path.expanduser("~/.claude/projects/" + slug(r)) for r in dict.fromkeys(r for r in roots if r)]
sid = os.environ.get("CLAUDE_CODE_SESSION_ID", "")
fs = [d + "/" + sid + ".jsonl" for d in dirs if sid and os.path.isfile(d + "/" + sid + ".jsonl")]
fs = fs or next((glob.glob(d + "/*.jsonl") for d in dirs if glob.glob(d + "/*.jsonl")), [])
if not fs:
    raise SystemExit("세션 기록(.jsonl)을 못 찾음 — 찾아본 폴더: " + ", ".join(dirs))
f = max(fs, key=os.path.getmtime)
want = sys.argv[1] if len(sys.argv) > 1 else ""
def text(c):                                                               # tool_result 내용 → 글(문자열 또는 글 조각 목록)
    s = c.get("content")
    if isinstance(s, list):
        s = "\n".join(p.get("text", "") for p in s if isinstance(p, dict) and p.get("type") == "text")
    return s if isinstance(s, str) else ""
for a in sorted(glob.glob(f[:-len(".jsonl")] + "/subagents/agent-*.jsonl"), key=os.path.getmtime):
    aid = os.path.basename(a)[len("agent-"):-len(".jsonl")]
    if want and want not in aid:
        continue
    print("==", aid)
    calls, out, cut = [], {}, {}
    for x in filter(str.strip, open(a, encoding="utf-8", errors="replace")):
        try:
            row = json.loads(x)
        except ValueError:                                                 # 쓰다 끊긴 줄은 건너뛴다
            continue
        at = row.get("attachment")
        if isinstance(at, dict) and at.get("type") == "read_truncation_notice":   # Read 가 파일 일부만 보였다는 알림
            cut[at.get("toolUseID")] = (at.get("banner") or "").split(". ")[0][:200]
        msg = row.get("message")
        if not (isinstance(msg, dict) and isinstance(msg.get("content"), list)):
            continue
        for c in msg["content"]:
            if not isinstance(c, dict):
                continue
            if c.get("type") == "tool_use" and c.get("name") in ("Read", "Bash"):
                calls.append(c)
            elif c.get("type") == "tool_result":
                out[c.get("tool_use_id")] = (text(c), bool(c.get("is_error")))
    for c in calls:
        i = c.get("input") or {}
        res, err = out.get(c.get("id"), (None, False))
        mark = " 오류" if err else ""
        if res is None:
            mark = " 결과 없음"                                            # 결과 행이 없음(끊김 등)
            res = ""
        if c["name"] == "Read":
            nums = re.findall(r"(?m)^\s*(\d+)\t", res)                     # 결과 줄 머리 = 「<줄 번호>\t」
            shown = nums[0] + "-" + nums[-1] if nums else "-"
            print("Read", i.get("file_path"), i.get("offset", "-"), i.get("limit", "-"), "| 보임", shown + mark,
                  ("| 잘림 " + cut[c.get("id")]) if c.get("id") in cut else "")
        else:
            first = (i.get("command") or "").splitlines()[0][:160] if i.get("command") else ""
            saved = re.search(r"Full output saved to: (\S+)", res) if "<persisted-output>" in res else None
            if saved:                                                      # 결과가 커서 파일로 빠짐 — 기록엔 앞부분만
                print("Bash", first, "| 결과 파일로 빠짐 —", saved.group(1) + mark)
                continue
            last = next((l.strip() for l in reversed(res.splitlines()) if l.strip()), "")
            print("Bash", first, "| 끝 줄", last[:160] + mark)
PY
```

## 이 패키지 정의 — 역할별 10개

| 정의 이름 | 역할 | model | effort | 도구 |
|---|---|---|---|---|
| `bada-a1-analyst` | A1 분석·설계·계획 초안 | `claude-opus-5-5` | `high` | 전부 |
| `bada-b-auditor` | B 적대 감사(읽기 전용) | `claude-opus-5-5` | `high` | 읽기 전용 |
| `bada-a2-coder` | A2 코드(설치기·도구·스크립트) | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a2-writer` | A2 지침·문서 편집 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-image-reader` | 이미지 판독 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a3-worker` | A3 정형 실무·단순 수정 | `claude-opus-5-5` | `medium` | 전부 |
| `bada-a3-reviewer` | A3 반복 검수(검증 1회 = 그 갈래의 검수 · ③ = 10라운드) | `claude-opus-5-5` | `medium` | 읽기 전용 + 기계 검사용 셸 |
| `bada-a3-helper` | 저부하 helper | `claude-opus-5-5` | `low` | 전부 |
| `bada-a4-helper` | A4 검색·기계 | `claude-opus-5-5` | `low` | 전부 |
| `bada-fallback` | 배정 폴백(역할 미매칭 · 쓰기 가능) | `claude-opus-5-5` | `medium` | 전부 |

배분 밖 정의(사용자가 Fable 을 요청할 때만):

| 정의 이름 | 역할 | model | effort | 도구 |
|---|---|---|---|---|
| `bada-fable-analyst` | Fable 분석·설계·검토 초안 | `claude-fable-5-2` | `high` | 전부 |
| `bada-fable-auditor` | Fable 적대·설계 감사(읽기 전용) | `claude-fable-5-2` | `high` | 읽기 전용 |

- 도구 칸 「전부」 = 정의에서 막지 않는다는 뜻이다. 서브가 다른 서브를 띄우는 것은 발주문·규범이 정하고 정의 파일로 막지 않는다(읽기 전용 세 정의만 편집·스폰 도구를 좁힌다).
- 이름은 사용자 동명 정의와 겹치지 않게 `bada-` 접두를 쓴다.
- **배정 폴백(`bada-fallback`)** = 역할별 정의 어디에도 안 맞는 작업용 쓰기 가능 정의다. master 상속 서브로 두지 않고 이 정의(Opus 5.5 · medium)로 고정한다 — 상속하면 master 의 모델·effort(사용자가 세션에서 바꾼 값 포함)를 그대로 받아 폴백의 Opus 5.5 · medium 이 보장되지 않는다.

## 실측 기록 요지 (패키지 개발 때 · Claude Code 2.1.281)

- 정의 9개의 `resolvedModel` 은 정의가 지정한 모델과 일치한다(Opus 정의는 1M 문맥 변형으로 표시될 수 있다).
- Agent 도구 호출 인자 `model` 은 별칭 4개(`sonnet`·`opus`·`haiku`·`fable`)만 받고 effort 칸이 없다 — 별칭 `opus` 는 master 가 Opus 면 master 모델로 풀린다. (2.1.292 부터는 호출 인자 `effort` 가 있다 — 공식 문서 `sub-agents` · 이 패키지는 넘기지 않는다.)
- 서브 한 번 띄울 때 고정 비용은 약 6.5만(Sonnet·Haiku)~8.5만(Opus) 토큰이다(헌법·시스템 지시 적재) → 검수 서브는 여러 번 띄우기보다 한 번에 묶는다.

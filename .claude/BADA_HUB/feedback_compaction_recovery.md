---
version: "1.4.6"
updated: "2026-11-03"
name: feedback_compaction_recovery
description: "컴팩션·세션 재개(fork 포함) 직후 새 편집 한 줄 전에 강제하는 복구 절차 — 한 순서: 먼저 규칙 파일 다시 읽기(복구 읽기 순서 맨 앞 = 헌법·소통·흐름 memory 다시 읽기 · 방법론 스킬 둘 다시 부르기) → 6-check(1 대기열 사용자 메시지 대조 — 세션 기록에서 직전 컴팩션 경계 근처의 사용자 enqueue 와 사용자 발화 행을 요청 대장과 대조하고 빠진 것부터 답함 · 빠진 요청의 대장 한 행은 그 자리에서 · 2 직전 Result·마스터플랜 본문 정독(이력 파일 아님) · 3 현재 작업 단위 전문 재정독 · 4 직전 작업 단위(산출물의 앞 단위) 재정독 · 5 계획 step 대조 · 6 분량 급감 = 누락 신호) → 나머지 복구 읽기 순서(마스터 플랜부터) · 6-check·나머지 복구 읽기는 master 몫 — 서브는 규칙 파일 재독 뒤 그 대신 자기 발주문·받은 메시지·발주문이 입력으로 정한 파일·기록(대상·연계 파일 + 자기 work_log·실행 출력 절처럼 발주문이 정한 기록)을 전문으로 다시 읽음(요청 대장·계획 문건에 쓰지 않고 발주문 밖 기록을 읽지 않음) · 복구 읽기(규칙 파일 재독 + 6-check)로 읽은 파일·줄 범위를 스텝 이력에 기록(없으면 미완) · 컴팩션된 서브를 계속 쓰면 편집 전 발주문이 입력으로 정한 파일·기록 전부 다시 전문. 훅이 SessionStart(compact·resume·fork) 시점에 이 본문을 결정론적으로 주입한다."
---
오토 컴팩션 이전의 상황에 대해 너는 아는 것 같아도, 실제로는 아는 것 하나도 없으니까 아는 척 하지 말고, 내 지침을 읽고 준수하라

## 적용 조건

컴팩션(오토컴팩션 포함)·세션 재개(앞 대화를 이어받아 가른 fork 세션 포함) 직후, 새 편집 한 줄을 넣기 전에 적용한다. 컨텍스트가 소실돼 누락·환각에 가장 취약한 순간이다. 훅이 SessionStart `source=compact`(및 `resume`·`fork`)에서 이 본문을 결정론적으로 주입한다 — 조용한 오토컴팩션(사용자 발화 없음)에도 도달한다. 재개 때는 본문 첫 줄의 「오토 컴팩션 이전」을 「세션 재개 이전」으로 읽는다.

## 핵심 원칙 — 새 편집 전 6-check(그 앞에 규칙 파일 재독 · 한 순서)

새 편집 한 줄 전에 한 순서로 이행한다 — **먼저 규칙 파일을 다시 읽고**(아래 「복구 읽기 순서」 맨 앞 묶음 · 컴팩션 뒤 다시 실린 헌법이 디스크 판과 다를 수 있어 옛 판으로 답하거나 대장을 적지 않게) → **6-check 를 순서대로** → 나머지 복구 읽기(마스터 플랜부터). **6-check·나머지 복구 읽기는 master 몫(서브 예외 원본 = 여기)** — 서브(Agent 도구로 뜬 세션)는 규칙 파일 재독 뒤 그 **대신** 자기 발주문·받은 메시지·발주문이 입력으로 정한 파일·기록(대상·연계 파일 + 자기 work_log·실행 출력 절처럼 발주문이 정한 기록)을 전문으로 다시 읽고, 요청 대장·계획 문건(마스터 플랜·세부 계획서·Ledger)에 쓰지 않으며 발주문 밖 기록을 읽지 않는다([[feedback_chunked_review]] 「검수 입력」). master 의 6-check:

1. **대기열 사용자 메시지 대조 — 빠진 것부터 답한다(master 만).** 서브는 이 1 을 포함한 6-check 를 하지 않는다(위 머리 문단) — 아래 명령이 뽑는 것은 master 의 사용자 메시지라 서브의 몫이 아니다. master 는 세션 기록 파일(대화 원문)에서 직전 컴팩션 경계 근처의 사용자 메시지 — 대기열로 들어온 것(`enqueue`)과 대기열을 거치지 않고 세션 기록에 바로 남은 사용자 발화 행(`type:"user"`) 둘 다 — 를 찾아 요청 대장(지금 Phase 파일 · 거기 없는 메시지는 앞 Phase 파일에서 확인 · 대장이 없으면 마스터 플랜·계획서·스텝 이력)과 대조하고, 대장·요약에 없는 메시지가 있으면 그 메시지부터 답한다(답은 그 턴의 마지막 글 — 원본 = [[feedback_communication_style]] 원칙 6). 그 요청의 요청 대장 한 행은 세션 기록 원문을 옮겨 적는 것이라 이 자리에서(나머지 check 전에도) 적는다 — 그 밖의 편집은 6-check 를 마친 뒤다. 작업 도중 보낸 메시지는 대기열에 들어갔다 처리되는데, 그 사이 컴팩션이 일어나면 요약에서 통째로 빠질 수 있다(찾는 명령·형식은 아래 「실행 방법」).
2. **직전 Result·마스터플랜(roadmap) 본문 정독**(이력 파일 아님).
3. **현재 작업 단위 산출물을 현재 파일 상태로 전문 재정독** — 직전 편집이 제자리에 있고 훼손·누락 0인지 확인.
4. **직전 작업 단위 재정독** — 현재 단위 바로 앞의 자연 작업 단위(산출물의 앞 단위 — 절·모듈·함수·문단·데이터블록 · [[feedback_unit_loop]])를 현재 파일 상태로 다시 읽는다. 스텝 이력 읽기는 아래 복구 읽기 순서의 최신 `Step <N>` 이력 파일(3순위)이 맡는다.
5. **계획 step 대조.**
6. **직전 대비 분량(줄/문단/식 수) 급감 = 누락 신호** → 이전 버전 재정독·재작업.

## 복구 읽기 순서

먼저 규칙 파일을 다시 읽는다 — 헌법 파일(설치본 `~/.claude/CLAUDE.md` · 헌법을 프로젝트 `.claude/CLAUDE.md` 로 싣는 저장소 세션이면 그 파일 · 컴팩션 뒤 다시 실린 헌법이 디스크 판과 다를 수 있다) → 소통·흐름 memory([[feedback_communication_style]] · [[feedback_flow_interruption]]) → 훅이 색인을 잘라 실었으면 그 나머지(끝 줄 경로) → 방법론 스킬 두 개를 Skill 도구로 다시 부른다(`skill:skill_LKS_original_plan-execution` · `skill:skill_LKS_original_multi-session-orchestration` — 컴팩션 뒤 스킬 본문이 다시 실리지 않을 수 있다). 훅은 이 본문 뒤에 그 파일들의 실제 경로를 적는다. 이 첫 묶음은 6-check 보다 앞이다(위 한 순서) — master 는 그 뒤 위 6-check 를 하고(서브는 위 머리 문단의 서브 몫으로), 이어서 마스터 플랜 본문(1순위 · 이력 파일 아님) → 현재 Phase 세부 계획서(2순위) → 최신 `Step <N>` 이력 파일(3순위) → 최신 Result(4순위) → 분업 중이면 그 유닛의 세션 대장 지금 Phase 절(5순위 · 다시 부를 서브의 역할·식별자 · 양식 = `skill:skill_LKS_original_multi-session-orchestration` 「같은 A ↔ 같은 B 왕복」)과 지금 Phase 처리표(다음 발주서의 「이미 정한 것」 · 양식 = `skill:skill_LKS_original_plan-execution` 의 `references/record-formats.md`) 순으로 읽어 추정 없이 복구한다.

## 이유

컴팩션 직후 훼손된 기억으로 산출물을 채우면 잘못된 전제·누락 위에 재작업이 쌓인다 — 이 체계가 막으려는 실패의 원형이다. 그 순간에는 "충분히 안다"는 오인이 가장 강하므로, 아는 것 같아도 위 절차를 먼저 이행한다.

대기열 대조(6-check 1)를 6-check 의 맨 앞에 두는 이유는 따로 있다: 작업 도중 사용자가 보낸 메시지는 대기열에 들어갔다 순서대로 처리되는데, 그 사이 컴팩션이 일어나면 요약에 담기지 못하고 사라진다. 실제로 한 세션에서 이렇게 대기열로 들어온 사용자 메시지 두 건이 요약에서 빠져 끝내 답하지 못한 일이 있었다 — 그래서 6-check 의 첫 단계로 세션 기록 원문에서 그 메시지들을 직접 찾아 대조한다.

## 실행 방법

- **6-check 1 — 대기열 사용자 메시지 대조 명령(master 몫).** 재개 직후 규칙 파일을 다시 읽은 뒤, 새 편집 전에 아래 명령으로 직전 컴팩션 경계 근처의 사용자 enqueue 와 사용자 발화 행을 뽑아 요청 대장(위치·양식 = `skill:skill_LKS_original_plan-execution` 의 `references/record-formats.md` 「사용자 요청 대장」)과 대조한다. 요청 대장이 없는 프로젝트면 사용자 발화를 마스터 플랜·계획서·스텝 이력과 대조한다. 대장·요약에 없는 메시지부터 답한다.

  ```python
  import json, glob, os, re, subprocess
  def slug(p): return re.sub(r"[^A-Za-z0-9]", "-", p)  # Claude Code 규칙(비영숫자 → '-')
  roots = [os.environ.get("CLAUDE_PROJECT_DIR", "")]  # ① 세션이 시작된 프로젝트 루트
  try:  # ② git 저장소 최상위(워크트리면 주 저장소)
      g = subprocess.run(["git", "rev-parse", "--git-common-dir"], capture_output=True, text=True).stdout.strip()
      roots.append(os.path.dirname(os.path.abspath(g)) if g else "")
  except OSError:
      pass
  roots.append(os.getcwd())  # ③ 지금 폴더
  dirs = [os.path.expanduser("~/.claude/projects/" + slug(r)) for r in dict.fromkeys(r for r in roots if r)]
  sid = os.environ.get("CLAUDE_CODE_SESSION_ID", "")  # 있으면 이 세션의 기록 파일을 바로 고른다
  fs = [d + "/" + sid + ".jsonl" for d in dirs if sid and os.path.isfile(d + "/" + sid + ".jsonl")]
  fs = fs or next((glob.glob(d + "/*.jsonl") for d in dirs if glob.glob(d + "/*.jsonl")), [])
  if not fs:
      raise SystemExit("세션 기록(.jsonl)을 못 찾음 — 찾아본 폴더: " + ", ".join(dirs) + " · ~/.claude/projects/ 에서 이 세션 기록을 직접 고른다")
  f = max(fs, key=os.path.getmtime)  # 가장 최근 세션 기록(subagents/ 는 한 단계 아래라 제외됨)
  rows, bad = [], 0
  for x in filter(str.strip, open(f, encoding="utf-8", errors="replace")):
      try: rows.append(json.loads(x))
      except ValueError: bad += 1  # 쓰다 끊긴 줄은 세고 건너뛴다
  print("깨진 줄 건너뜀:", bad)
  b = [r["timestamp"] for r in rows if r.get("subtype") == "compact_boundary"]
  last = b[-1] if b else None  # 경계가 여러 번이면 직전(가장 최근) 것
  prev = b[-2] if len(b) >= 2 else ""  # 그 이전 경계 = 조회 시작점
  def said(r):  # 사용자 발화 글: 대기열 enqueue 행 · 사용자 행(type "user")
      if r.get("type") == "queue-operation" and r.get("operation") == "enqueue":
          return r.get("content") or ""
      if r.get("type") == "user" and not (r.get("isMeta") or r.get("isCompactSummary")):
          c = (r.get("message") or {}).get("content")
          if isinstance(c, list):  # 도구 결과(tool_result)는 발화가 아니다 — 글 조각만
              c = " ".join(p.get("text", "") for p in c if isinstance(p, dict) and p.get("type") == "text")
          return c if isinstance(c, str) else ""
      return ""
  seen = set()
  for r in rows:
      c = said(r).lstrip()
      t = r.get("timestamp", "")
      if not c or c.startswith(("<", "[Request interrupted")) or (last and t < prev) or c[:80] in seen:
          continue  # <task-notification 등 꺾쇠 태그·중단 표시는 발화 아님 · 같은 글은 한 번만
      seen.add(c[:80])
      print(t, "뒤" if last and t >= last else "앞", "대기열" if r["type"] != "user" else "발화", "|", c[:80].replace("\n", " "))
  ```

  세션 기록 = `~/.claude/projects/<슬러그>/<세션 id>.jsonl` — `<슬러그>` 는 세션이 시작된 프로젝트 루트(`CLAUDE_PROJECT_DIR`) → 그 git 저장소 최상위(워크트리면 주 저장소) → 지금 폴더 순으로 찾는다(하위 폴더·`cd` 뒤에도 같은 폴더를 찾고, 못 찾으면 예외 대신 찾아본 폴더를 안내한다) · 컴팩션 경계 = `"type":"system","subtype":"compact_boundary"` · 대기열 = `"type":"queue-operation","operation":"enqueue"`(`timestamp`·`content`) · 사용자 발화 행 = `"type":"user"`(도구 결과·`isMeta`·컴팩션 요약 행은 빼고 글만). `뒤`/`앞` = 직전 경계의 뒤/앞 · 첫 줄 `깨진 줄 건너뜀:` = 쓰다 끊겨 읽지 못한 줄 수(0 이 아니면 그 줄의 메시지는 미확인으로 남긴다). 출력된 사용자 메시지를 요청 대장과 하나씩 대조해 빠진 것을 먼저 처리한다.
- 재개 직후 위 한 순서(규칙 파일 재독 → 6-check)를 이행하기 전에는 새 편집·완료 보고를 하지 않는다(master 가 6-check 1 에서 빠진 요청의 대장 한 행을 적는 것만 앞선다) · 서브는 서브 몫 재독(위 머리 문단)을 마치기 전에 새 편집·반환을 하지 않는다.
- **복구 읽기 범위를 적는다.** 복구 읽기(규칙 파일 재독 + 6-check)로 읽은 파일과 줄 범위를 그 스텝 이력에 적는다 — 없으면 그 스텝은 미완이다(서브는 서브 몫 재독도 work_log·보고에 · 원본 = [[feedback_full_file_read_required]] 「읽은 범위를 기록한다」). 요약에 남은 내용으로 발주문·기록을 쓰지 않는다.
- **컴팩션된 서브.** 서브가 컴팩션되면 그 서브를 계속 쓸 때 편집·판정 전에 입력 파일·기록을 전부 다시 전문으로 읽고 그 범위를 적는다(컴팩션은 새 서브 사유가 아니다 — 같은 서브를 다시 부르고, 새 서브를 띄우는 때 = [[feedback_session_division]] 「같은 A ↔ 같은 B」 ①–④). 그 서브가 컴팩션됐는지는 master 가 다시 부르기 전에 그 서브 기록(`~/.claude/projects/<슬러그>/<세션 id>/subagents/agent-<식별자>.jsonl`)의 `compact_boundary` 행으로 확인해, 컴팩션됐으면 발주문에 입력 전문 재독을 싣는다(명령 = 분업 스킬 `references/model_effort_sample.md` 「다시 부르기 · 서브 상태」). 서브 자신의 컴팩션 복구 = 위 「핵심 원칙」 머리 문단(규칙 파일 재독 → 자기 발주문·받은 메시지·입력 파일·기록 전문 재독) — 위 6-check 1 명령은 master 세션 기록용이다(서브 기록은 한 단계 아래라 고르지 않는다).
- **"기억으로는" 금지.** 근거 부재 시 "근거 미발견" 명시. 인용 시 path+line.
- Result를 매 Phase 별도 파일로 저장하는 이유가 이 복구다 — 훼손된 기억으로 채우지 말고 해당 Phase Result 를 직접 Read해 근거로 삼는다(정독 대상 = `RESULT.md` 본문 · 동반 `.json` 은 기계 판독 부본으로 md 정독을 대체 X · 저장은 **md+json 쌍 필수**).

## 예외·금지

- 컴팩션 후 재정독 없이 "직전에 다 했다"는 기억으로 이어서 편집하지 않는다.
- 분량 급감을 정상으로 간주하지 않는다(누락 신호로 취급).
- 검수 루프 중 컴팩션·세션 재개 시, 직전 라운드에 (첫 커버 이후) 발췌로 넘겼던 구간도 그 라운드는 전문 재정독으로 복원한다 — 발췌의 전제(직전 전독 커버가 현재 검수자 context 에 있음)를 컴팩션이 소실시키므로 "이미 읽었다"는 기억을 신뢰하지 않는다(라운드 정독 입도 규범 = [[feedback_chunked_review]] 「정독 입도」).

## 관련 memory·skill

- 계획·단계 실행·세 문건 복구 절차: `skill:skill_LKS_original_plan-execution`
- 세션 진입 정독(문건·인계 chain): [[feedback_session_entry_reading]] — 상보(진입 정독 = 문건·chain / 본 memory = 계획 대비 상태 복구)
- 인계 기록(부실하면 이 복구가 기댈 근거 없음): [[feedback_handover]]
- 전문 정독 원칙: [[feedback_full_file_read_required]]
- 검수 라운드 정독 입도(첫 커버 전독 · 이후 라운드 필요한 곳 · 고친 뒤 재검증은 전문) 규범: [[feedback_chunked_review]] — 검수 루프 중 컴팩션 시 발췌 구간 전독 복원이 그 리셋 축의 한 다리
- 작업물 보호(복원 지점): [[feedback_workspace_git_safety]] — 침범 시 직전 커밋으로 복원(② 위험 전 commit 이 전제)

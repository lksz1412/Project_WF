#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""A/B 비교 전처리 게이트 — 코멘트·공백 노이즈를 제거한 뒤 두 파일을 비교한다.

코멘트·띄어쓰기 차이는 비교 노이즈라, 걷어내고 봐야 "실제 코드/내용이 다른가"가
드러난다. 이 도구는 노이즈를 제거한 정규화본끼리 diff 해서, 실차가 있을 때만 A/B
비교 작업(한쪽 전독·다른쪽 diff 발췌)에 들어가게 하는 게이트다.

정규화 = 코멘트 제거 + 공백 정규화.
  코멘트: .py = tokenize 기반(문자열 안 `#` 오제거 방지) + 독스트링(모듈/클래스/함수
          첫 문장 문자열) 제거 · .js/.ts/.c/.h/.cpp/.cc/.go/.rs/.java·.json(JSONC/JSON5)
          = `//` 라인 · `/* */` 블록(문자열·char·템플릿·정규식 리터럴 안은 스캐너로
          보존) · .sh/.bash/.yaml/.yml/.toml/.ini = `#` 라인(문자열 안 보존) ·
          .m(MATLAB) = `%` 라인(`%%` 섹션 포함)·`%{`…`%}` 블록(문자열 안 보존 · `'` 가
          문자열/transpose 로 애매 → best-effort) · .md/.html/.htm/.xml = `<!-- -->`.
          미지원 확장자 = 공백만 정규화 + stderr 경고.
  공백: 각 줄 trailing whitespace 제거 · (문자열 밖) 빈 줄 제거 · CRLF/CR→LF.
        **string-aware** — 문자열 리터럴 안의 행끝 공백·빈 줄은 유의미하므로 보존한다
        (rstrip·빈줄제거는 마스크가 코드('.')인 부분에만 적용). 줄 내부·앞 공백은
        건드리지 않는다(토큰 병합·파이썬 들여쓰기 훼손 방지).

정확성 급소 = string-literal false positive 방지: .py 는 tokenize·ast 로, 타 언어는
스캐너(문자열/char/템플릿 리터럴·이스케이프 `\\` 추적 + 각 char 의 문자열-내부 여부를
마스크로 산출)로 문자열 안을 보존한다. JS 는 정규식 리터럴(`/…/flags`)을 식별해(표현식
위치·정규식 선행 키워드·`[…]` char class 인식) 그 안의 `//`·`/*` 를 코멘트로 오인·삭제
하지 않는다. MATLAB `'` 만은 문자열 시작과 transpose 연산자가 같은 글자라 휴리스틱
(식별자·숫자·`)`·`]`·`}`·`.` 뒤 = transpose · 그 외 = 문자열) 기반 best-effort —
희귀 케이스는 오제거 가능.

**fail-safe 계약(호출 규범 ② 와 짝 · 화이트리스트)**: 이 게이트는 노이즈 필터일 뿐 완전
  파서가 아니다. exit 0 을 "동일 → 양쪽 전독 불요"로 **신뢰하는 것은 파서 근거가 견고한
  유형뿐이다: `.py`(tokenize+ast)·`.json`.** 그 밖 휴리스틱 스캐너 유형(js/ts·c/cpp·go·
  rust·shell·yaml/toml/ini·MATLAB·md/html·미지원)은 정규식·heredoc·char 리터럴·유의미
  공백처럼 완전히 못 푸는 구성이 있어 exit 0 이어도 **기준 쪽 전독**으로 간다(노이즈 제거
  diff 는 exit 1 표시엔 유효). `[WARN]`(미지원·MATLAB best-effort·파이썬 파싱 실패)이면
  유형 불문 전독. 오판 방향은 "다른 걸 같다"(위험)가 아니라 "같은 걸 다르다 → 전독"(안전)
  이며, 이 안전은 스캐너 개별 정확도가 아니라 **화이트리스트 규칙**이 구조적으로 보장한다.

사용:
    python3 tools/ab_precompare.py A B            # 정규화본끼리 unified diff
    python3 tools/ab_precompare.py A B --lang py  # 언어 강제(선택: json js py c cpp
                                                  #   matlab 등 · 기본 auto=확장자)
    python3 tools/ab_precompare.py --show A [B]   # diff 대신 정규화본 자체 출력
    python3 tools/ab_precompare.py --selftest     # 자체 회귀 테스트
종료코드: 0 = 정규화 후 동일(노이즈성 차이뿐 → 비교 종결·양쪽 전독 불요 · 단 위 fail-safe
              계약의 유형·경고에서는 종결 근거로 쓰지 않는다) ·
          1 = 정규화 후에도 실차(A/B 비교 진행) · 2 = 사용 오류(파일 없음 등).
          --show 는 정규화 결과 출력 후 항상 0(비교 판정이 아니므로 exit 로 동일 여부를
              읽지 말 것) · --selftest 는 전건 PASS 시 0 · 하나라도 FAIL 시 1.
stdlib 전용 · UTF-8 명시 · Python 3.10+.
"""
import argparse
import ast
import difflib
import io
import os
import re
import sys
import tokenize

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
# 파이프로 캡처되면 Python 은 콘솔 CP 가 아니라 ANSI(한국어=cp949)로 인코딩 →
# '—'(U+2014) 등 cp949 밖 문자에서 UnicodeEncodeError. UTF-8 로 못박아 안전
# (BADA_recall 훅과 동일 방어를 전 CLI 도구로 표준화).
if sys.platform == "win32":
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8")
    except Exception:
        pass

# 확장자(소문자·점 제외) → 언어 계열. --lang 은 이 표의 키(확장자)나 계열명 둘 다 받는다.
# .m 은 MATLAB 로 본다(Objective-C .m 는 `--lang c`/`cpp` 로 강제).
EXT_FAMILY = {
    "py": "python", "pyw": "python",
    "js": "js", "mjs": "js", "cjs": "js", "jsx": "js", "ts": "js", "tsx": "js",
    "json": "json",
    "c": "cstyle", "h": "cstyle", "cc": "cstyle", "cpp": "cstyle",
    "cxx": "cstyle", "hpp": "cstyle", "hh": "cstyle", "java": "cstyle",
    "go": "go", "rs": "rust", "m": "matlab",
    "sh": "hash", "bash": "hash", "yaml": "hash", "yml": "hash",
    "toml": "hash", "ini": "hash",
    "md": "xml", "html": "xml", "htm": "xml", "xml": "xml",
}
FAMILIES = {"python", "cstyle", "js", "json", "go", "rust", "matlab", "hash", "xml"}

# --lang 명시 선택지. 확장자 키 + 계열명(python·cstyle·hash) 둘 다 노출해 _resolve_family
# 가 받는 값과 argparse choices 를 일치시킨다(도달 불가 분기 제거).
LANG_CHOICES = ["json", "js", "py", "c", "cpp", "matlab",
                "ts", "jsx", "tsx", "go", "rust", "java",
                "sh", "bash", "yaml", "yml", "toml", "ini",
                "md", "html", "htm", "xml",
                "python", "cstyle", "hash"]

# C 계열 스캐너 파라미터. 문자열/char 는 `\` 이스케이프, 백틱은 언어별로 다르다
# (js 템플릿 = 이스케이프 O · go raw string = 이스케이프 X · rust 는 백틱 문자열 없음·
#  lifetime `'a` 를 char 리터럴로 오인하지 않게 lifetime 인식). json(JSONC/JSON5)=cstyle 과
#  동일. regex=True 는 js 계열만(정규식 리터럴 식별 · C/JSON/go/rust 엔 정규식 리터럴 없음).
_CSTYLE_PARAMS = {
    "cstyle": dict(char_quote=True, lifetime=False, backtick=False, backtick_escape=False, regex=False),
    "json":   dict(char_quote=True, lifetime=False, backtick=False, backtick_escape=False, regex=False),
    "js":     dict(char_quote=True, lifetime=False, backtick=True,  backtick_escape=True,  regex=True),
    "go":     dict(char_quote=True, lifetime=False, backtick=True,  backtick_escape=False, regex=False),
    "rust":   dict(char_quote=True, lifetime=True,  backtick=False, backtick_escape=False, regex=False),
}

# MATLAB transpose 판정 — 이 문자들 바로 뒤의 `'` 는 문자열 아닌 전치 연산자로 본다.
_MATLAB_TRANSPOSE_PREV = set(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_)]}.")

# JS 정규식 리터럴 판정 — `/` 앞 직전 유의미 문자가 이 집합이면 표현식 위치라 정규식 시작
# 가능(아니면 나눗셈). 선행 키워드(return 등) 뒤도 정규식 위치.
_REGEX_PREV_CHARS = set("(),;:={[!&|?+-*%^~<>") | {""}
_REGEX_KEYWORDS = {"return", "typeof", "instanceof", "in", "of", "new", "delete",
                   "void", "do", "else", "yield", "await", "case", "throw"}


def _regex_allowed(prev_sig, prev_word):
    # `/` 가 정규식 리터럴 시작으로 허용되는 위치인가(표현식 위치).
    if prev_word in _REGEX_KEYWORDS:
        return True
    return prev_sig in _REGEX_PREV_CHARS


# ── 공백 정규화 (string-aware · 마스크 기반) ─────────────────────────────
def _ws_normalize_masked(out, mask, drop_blanks=True):
    # out = 정규화 대상 텍스트, mask = 동길이 문자열(문자별 'S'=문자열 내용 / '.'=코드 등).
    # 각 줄: 마스크 '.' 인 trailing whitespace 만 제거 · 빈 줄은 문자열이 안 걸친
    # 코드 줄일 때만 제거(drop_blanks). 문자열이 걸친 빈 줄(다줄 문자열 내부)은 보존.
    result = []
    cur = []
    curm = []
    prev_nl_s = [False]   # 직전 줄을 끝낸 개행이 문자열 안이었나(다줄 문자열 연속)

    def flush(nl_in_str):
        end = len(cur)
        while end > 0 and cur[end - 1] in " \t" and curm[end - 1] == ".":
            end -= 1
        txt = "".join(cur[:end])
        has_s = "S" in curm
        protected = has_s or nl_in_str or prev_nl_s[0]
        if not (drop_blanks and txt == "" and not protected):
            result.append(txt)
        prev_nl_s[0] = nl_in_str

    for ch, mk in zip(out, mask):
        if ch == "\n":
            flush(mk == "S")
            cur = []
            curm = []
        else:
            cur.append(ch)
            curm.append(mk)
    flush(False)
    return "\n".join(result) + ("\n" if result else "")


# ── Python: tokenize(코멘트·문자열) + ast(독스트링) ──────────────────────
def _byte_to_char(line, byte_col):
    # ast 의 col_offset 은 UTF-8 바이트 오프셋 → 문자 인덱스로 환산(ASCII 는 항등).
    return len(line.encode("utf-8")[:byte_col].decode("utf-8", "ignore"))


def _py_comment_spans(src):
    # COMMENT 토큰의 (start_row, start_col, end_row, end_col). tokenize 는 문자열 안 `#`
    # 을 COMMENT 로 내지 않으므로 string-safe. 파싱 실패 시 None(공백만 정규화로 폴백).
    spans = []
    try:
        for tok in tokenize.generate_tokens(io.StringIO(src).readline):
            if tok.type == tokenize.COMMENT:
                spans.append((tok.start[0], tok.start[1], tok.end[0], tok.end[1]))
    except (tokenize.TokenError, IndentationError, SyntaxError, ValueError):
        return None
    return spans


# 이 파이썬 tokenize 빌드에 존재하는 문자열 계열 토큰 타입(3.12+ 는 FSTRING_* 분할).
_PY_STRING_TOKS = {tokenize.STRING}
for _name in ("FSTRING_START", "FSTRING_MIDDLE", "FSTRING_END"):
    _t = getattr(tokenize, _name, None)
    if _t is not None:
        _PY_STRING_TOKS.add(_t)


def _py_string_spans(src):
    # 모든 문자열(STRING·f-string 조각) 토큰 span. 문자열 내용을 마스크 'S' 로 보존하는 데 쓴다.
    # tokenize 컬럼은 문자 기준이라 lines 문자 인덱싱과 정합. 파싱 실패 시 None.
    spans = []
    try:
        for tok in tokenize.generate_tokens(io.StringIO(src).readline):
            if tok.type in _PY_STRING_TOKS:
                spans.append((tok.start[0], tok.start[1], tok.end[0], tok.end[1]))
    except (tokenize.TokenError, IndentationError, SyntaxError, ValueError):
        return None
    return spans


def _py_docstring_spans(src, lines):
    # 모듈/클래스/함수 첫 문장이 문자열 표현식(= ast 독스트링 정의)이면 그 span.
    # 파싱 실패 시 None(독스트링만 스킵, 코멘트 제거는 유지).
    try:
        tree = ast.parse(src)
    except (SyntaxError, ValueError):
        return None
    spans = []
    for node in ast.walk(tree):
        if not isinstance(node, (ast.Module, ast.AsyncFunctionDef,
                                 ast.FunctionDef, ast.ClassDef)):
            continue
        body = getattr(node, "body", None)
        if not body:
            continue
        first = body[0]
        if (isinstance(first, ast.Expr) and isinstance(first.value, ast.Constant)
                and isinstance(first.value.value, str)):
            c = first.value
            sc = _byte_to_char(lines[c.lineno - 1], c.col_offset)
            ec = _byte_to_char(lines[c.end_lineno - 1], c.end_col_offset)
            spans.append((c.lineno, sc, c.end_lineno, ec))
    return spans


def _normalize_python(src, warn):
    lines = src.split("\n")
    comment_spans = _py_comment_spans(src)
    if comment_spans is None:
        warn("코멘트 미제거(파이썬 파싱 실패 — 공백만 정규화)")
        return _ws_normalize_masked(src, "." * len(src))
    string_spans = _py_string_spans(src) or []
    doc_spans = _py_docstring_spans(src, lines)
    if doc_spans is None:
        warn("독스트링 미제거(파이썬 AST 파싱 실패)")
        doc_spans = []

    # 원본 flat 오프셋 라벨: 'S'(보존 문자열) / 'D'(삭제: 코멘트·독스트링) / '.'(코드).
    line_start = [0]
    for ln in lines:
        line_start.append(line_start[-1] + len(ln) + 1)   # +1 = '\n'

    def flat(r, c):
        return line_start[r - 1] + c

    n = len(src)
    label = ["."] * n
    for (sr, sc, er, ec) in string_spans:                 # 문자열 먼저 'S'
        for k in range(flat(sr, sc), min(flat(er, ec), n)):
            label[k] = "S"
    for (sr, sc, er, ec) in list(comment_spans) + list(doc_spans):   # 삭제가 덮어씀
        for k in range(flat(sr, sc), min(flat(er, ec), n)):
            label[k] = "D"

    out = []
    mask = []
    for k in range(n):
        ch = src[k]
        lb = label[k]
        if lb == "D":
            if ch == "\n":            # 줄 구조 보존(다줄 독스트링 → 빈 줄로 남고 뒤에서 제거)
                out.append("\n")
                mask.append(".")
            continue
        out.append(ch)
        mask.append("S" if lb == "S" else ".")
    return _ws_normalize_masked("".join(out), "".join(mask))


# ── C 계열: quote-state + 정규식 리터럴 스캐너 (out, mask 산출) ───────────
def _rust_char_lit(s, i):
    # s[i] == "'". char 리터럴('x'·'\n')이면 True, lifetime('a·'static)이면 False.
    a = s[i + 1] if i + 1 < len(s) else ""
    if a == "\\":
        return True
    return (s[i + 2] if i + 2 < len(s) else "") == "'"


def _c_char_lit(s, i):
    # s[i] == "'". C/C++ char 리터럴이면 True. C++ 숫자 구분자(digit ' digit)·닫힘 없는
    # 어포스트로피는 False → 가짜 문자열을 열어 뒤 코멘트 제거를 무력화하지 않게 한다.
    prevc = s[i - 1] if i > 0 else ""
    nxt = s[i + 1] if i + 1 < len(s) else ""
    if prevc.isdigit() and nxt.isdigit():
        return False                          # 1'000 (C++14 digit separator)
    j = i + 2 if (i + 1 < len(s) and s[i + 1] == "\\") else i + 1
    return s.find("'", j, i + 8) != -1        # 짧은 창 안에 닫는 ' 가 있어야 char 리터럴


def _scan_cstyle(src, char_quote, lifetime, backtick, backtick_escape, regex):
    out = []
    mask = []
    i, n = 0, len(src)
    prev_sig = ""     # 직전 유의미(비공백) 문자
    prev_word = ""    # 직전 완결 식별자(정규식 선행 키워드 판정용)
    ws_gap = [False]  # 직전 유의미 문자 이후 공백이 끼었나(식별자 run 경계)

    def push(seg, m):
        out.append(seg)
        mask.append(m * len(seg))

    def advance_plain(ch):
        # prev_word 는 "직전 완결 식별자" — 공백/연산자로 끊기면 새 낱말로 시작한다.
        nonlocal prev_sig, prev_word
        if ch.isspace():
            ws_gap[0] = True
            return
        is_ident = ch.isalnum() or ch in "_$"
        if is_ident:
            cont = (not ws_gap[0]) and (prev_sig.isalnum() or prev_sig in "_$")
            prev_word = (prev_word + ch) if cont else ch
        else:
            prev_word = ""
        prev_sig = ch
        ws_gap[0] = False

    while i < n:
        c = src[i]
        d = src[i + 1] if i + 1 < n else ""
        if c == "/" and d == "/":                 # 라인 코멘트(빈 정규식은 불가라 //=코멘트)
            j = src.find("\n", i)
            if j == -1:
                break
            i = j
            continue
        if c == "/" and d == "*":                 # 블록 코멘트 — 내부 개행 수만 보존
            j = src.find("*/", i + 2)
            seg = src[i:] if j == -1 else src[i:j + 2]
            push("\n" * seg.count("\n"), ".")
            if j == -1:
                break
            i = j + 2
            continue
        if regex and c == "/" and _regex_allowed(prev_sig, prev_word):   # 정규식 리터럴
            k = i + 1
            in_class = False
            ok = False
            while k < n:
                rc = src[k]
                if rc == "\\" and k + 1 < n:
                    k += 2
                    continue
                if rc == "\n":                    # 한 줄 안에서 안 닫히면 정규식 아님
                    break
                if rc == "[":
                    in_class = True
                elif rc == "]":
                    in_class = False
                elif rc == "/" and not in_class:
                    k += 1
                    ok = True
                    break
                k += 1
            if ok:
                while k < n and src[k].isalpha():   # 플래그(g·i·m…)
                    k += 1
                push(src[i:k], "S")                 # 정규식 내용 보존(코멘트로 오인 방지)
                prev_sig = ")"                      # 정규식 = 값 → 뒤 `/` 는 나눗셈
                prev_word = ""
                ws_gap[0] = False
                i = k
                continue
            # 유효한 정규식 아님 → 나눗셈으로 흘려보냄
        if c == '"' or (char_quote and c == "'") or (backtick and c == "`"):
            if c == "'" and lifetime and not _rust_char_lit(src, i):
                push(c, ".")                        # rust lifetime → 문자열 아님
                advance_plain(c)
                i += 1
                continue
            if c == "'" and char_quote and not lifetime and not backtick \
                    and not _c_char_lit(src, i):    # C/JSON 가짜 char 리터럴(1'000 등)
                push(c, ".")
                advance_plain(c)
                i += 1
                continue
            esc = c in ('"', "'") or (c == "`" and backtick_escape)
            push(c, "S")
            i += 1
            # 리터럴 내용은 그대로 보존(false positive 급소). 템플릿 `${...}` 안까지
            # 파고들지 않아 그 안의 코멘트는 남지만, 이는 안전한 방향(코드를 지우지 않고
            # 실차로 판정 → 비교 진행)이다.
            while i < n:
                e = src[i]
                if esc and e == "\\" and i + 1 < n:
                    push(src[i:i + 2], "S")
                    i += 2
                    continue
                push(e, "S")
                i += 1
                if e == c:
                    break
            prev_sig = c
            prev_word = ""
            ws_gap[0] = False
            continue
        push(c, ".")
        advance_plain(c)
        i += 1
    return "".join(out), "".join(mask)


# ── 해시(#) 라인 코멘트 계열: shell·yaml·toml·ini (out, mask) ─────────────
# heredoc 시작 `<<[-] [따옴표]DELIM[따옴표]` — DELIM 은 식별자. `<<:`(yaml merge)·`<<2`
# (숫자 시프트)는 식별자 아니라 미매치. 시프트 `a << b`(변수)만 드물게 오매치하나 본문을
# 보존하는 안전 방향이다.
_HEREDOC_RE = re.compile(r'<<-?\s*(["\']?)([A-Za-z_][A-Za-z0-9_]*)\1')


def _scan_hash_line(line, in_str):
    # 한 줄에서 `#` 코멘트 제거 + 따옴표 문자열 보존. in_str 상태를 받아 갱신해 반환(줄 넘는
    # 따옴표 문자열 지원). 반환 = (out, mask, in_str_after).
    out = []
    mask = []
    i, n = 0, len(line)
    prev = "\n"     # 줄머리 = `#` 코멘트 허용 위치
    while i < n:
        c = line[i]
        if in_str is not None:
            if c == "\\" and in_str == '"' and i + 1 < n:
                out.append(line[i:i + 2]); mask.append("SS"); prev = line[i + 1]; i += 2; continue
            out.append(c); mask.append("S")
            if c == in_str:
                in_str = None
            prev = c; i += 1; continue
        if c == "#" and prev in " \t\n\r":     # 줄머리·공백 뒤 `#` 만 코멘트 — EOL 까지 버림
            break
        if c in ('"', "'"):
            in_str = c; out.append(c); mask.append("S"); prev = c; i += 1; continue
        out.append(c); mask.append("."); prev = c; i += 1
    return "".join(out), "".join(mask), in_str


def _scan_hash(src):
    # 줄 단위 — heredoc(`<<EOF … EOF`) 본문은 셸 코드가 아니라 리터럴이라 `#`·빈 줄을
    # 코멘트·노이즈로 지우지 않고 'S' 마스크로 보존한다. 그 밖 줄은 char 스캐너로
    # `#` 코멘트 제거 + 따옴표 보존.
    out = []
    mask = []
    in_str = None            # 줄 넘는 따옴표 문자열 상태
    heredoc = None           # (delim, strip_tabs) — 본문 안이면 not None
    lines = src.split("\n")
    for idx, line in enumerate(lines):
        if idx:              # 줄 사이 개행 — heredoc/문자열 안이면 'S'(빈 줄 보존)
            out.append("\n")
            mask.append("S" if (heredoc is not None or in_str is not None) else ".")
        if heredoc is not None:
            delim, strip_tabs = heredoc
            probe = line.lstrip("\t") if strip_tabs else line
            if probe == delim:               # 종료 구분자 = 코드
                heredoc = None
                out.append(line); mask.append("." * len(line))
            else:                            # 본문 = 보존
                out.append(line); mask.append("S" * len(line))
            continue
        lo, lm, in_str = _scan_hash_line(line, in_str)
        out.append(lo); mask.append(lm)
        if in_str is None:                   # 코드 문맥에서 heredoc 시작 탐지
            m = _HEREDOC_RE.search(line)
            if m and "<<" in lo:             # `<<` 가 코멘트·문자열에 안 먹혔을 때만
                heredoc = (m.group(2), line[m.start():m.start() + 3] == "<<-")
    return "".join(out), "".join(mask)


# ── XML/HTML/Markdown: <!-- --> (out, mask · 빈 줄 보존은 호출부에서) ─────
def _scan_xml(src):
    out = []
    mask = []
    i, n = 0, len(src)
    while i < n:
        if src.startswith("<!--", i):
            j = src.find("-->", i + 4)
            seg = src[i:] if j == -1 else src[i:j + 3]
            push_nl = "\n" * seg.count("\n")       # 내부 개행 수만 보존
            out.append(push_nl); mask.append("." * len(push_nl))
            if j == -1:
                break
            i = j + 3
            continue
        out.append(src[i]); mask.append("."); i += 1
    return "".join(out), "".join(mask)


# ── MATLAB: `%` 라인 · `%{` … `%}` 블록 (best-effort · out, mask) ────────
def _matlab_strip_line(line):
    # 한 줄에서 `%` 라인 코멘트를 자른다. 문자열(`'…'` char array·`"…"` string) 안 `%` 는
    # 보존. `'` 는 문자열/transpose 애매 → prev 문자 휴리스틱. 따옴표 escape 는 이중화(''/"").
    out = []
    mask = []
    i, n = 0, len(line)
    in_str = None
    prev = ""
    while i < n:
        c = line[i]
        if in_str is not None:
            if c == in_str:
                if i + 1 < n and line[i + 1] == in_str:   # 이중 따옴표 = 리터럴 따옴표
                    out.append(c); out.append(c); mask.append("S"); mask.append("S")
                    prev = c; i += 2; continue
                out.append(c); mask.append("S"); in_str = None; prev = c; i += 1; continue
            out.append(c); mask.append("S"); prev = c; i += 1
            continue
        if c == "%":                       # 라인 코멘트 — EOL 까지 버림
            break
        if c == '"':
            in_str = '"'; out.append(c); mask.append("S"); prev = c; i += 1; continue
        if c == "'":
            if prev in _MATLAB_TRANSPOSE_PREV:   # 전치 연산자 — 문자열 아님
                out.append(c); mask.append("."); prev = c; i += 1; continue
            in_str = "'"; out.append(c); mask.append("S"); prev = c; i += 1; continue
        out.append(c); mask.append("."); prev = c; i += 1
    return "".join(out), "".join(mask)


def _scan_matlab(src):
    # `%{`/`%}` 는 (공백 제외) 제 줄에 단독일 때만 블록 코멘트(중첩 허용). 아니면 `%` 라인.
    out_lines = []
    mask_lines = []
    in_block = False
    depth = 0
    for line in src.split("\n"):
        s = line.strip()
        if in_block:
            if s == "%{":
                depth += 1
            elif s == "%}":
                depth -= 1
                if depth <= 0:
                    in_block = False
            out_lines.append(""); mask_lines.append("")   # 블록 내부 줄 버림
            continue
        if s == "%{":
            in_block, depth = True, 1
            out_lines.append(""); mask_lines.append("")
            continue
        t, m = _matlab_strip_line(line)
        out_lines.append(t); mask_lines.append(m)
    out = []
    mask = []
    for idx, (t, m) in enumerate(zip(out_lines, mask_lines)):
        if idx:
            out.append("\n"); mask.append(".")
        out.append(t); mask.append(m)
    return "".join(out), "".join(mask)


# ── 디스패치 ─────────────────────────────────────────────────────────────
def _normalize(src, family, warn):
    src = src.replace("\r\n", "\n").replace("\r", "\n")
    if family == "python":
        return _normalize_python(src, warn)
    if family in _CSTYLE_PARAMS:
        out, mask = _scan_cstyle(src, **_CSTYLE_PARAMS[family])
        return _ws_normalize_masked(out, mask)
    if family == "hash":
        out, mask = _scan_hash(src)
        return _ws_normalize_masked(out, mask)
    if family == "xml":
        warn("md/html/xml — 공백·주석이 유의미할 수 있음(빈 줄 보존 · 게이트 신뢰 낮음 → 전독 권고)")
        out, mask = _scan_xml(src)
        return _ws_normalize_masked(out, mask, drop_blanks=False)
    if family == "matlab":
        warn("MATLAB ' 애매성 = best-effort(희귀 케이스 오제거 가능)")
        out, mask = _scan_matlab(src)
        return _ws_normalize_masked(out, mask)
    warn("코멘트 미제거(미지원 확장자)")
    return _ws_normalize_masked(src, "." * len(src))


def _resolve_family(path, forced):
    key = (forced or os.path.splitext(path)[1]).lower().lstrip(".")
    if key in EXT_FAMILY:
        return EXT_FAMILY[key]
    if key in FAMILIES:
        return key
    return None


def _read_text(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def normalize_path(path, forced):
    warnings = []
    text = _normalize(_read_text(path), _resolve_family(path, forced), warnings.append)
    return text, warnings


def _compare(pa, pb, forced):
    na, wa = normalize_path(pa, forced)
    nb, wb = normalize_path(pb, forced)
    diff = list(difflib.unified_diff(
        na.splitlines(), nb.splitlines(), fromfile=pa, tofile=pb, lineterm=""))
    return (1 if diff else 0), diff, wa, wb


# ── 자체 회귀 테스트 ─────────────────────────────────────────────────────
def _selftest():
    results = []

    def check(name, ok):
        results.append(ok)
        print("[%s] %s" % ("PASS" if ok else "FAIL", name))

    noop = lambda _m: None
    na = _normalize('x = "a # b"\n# comment\n', "python", noop)
    check("(a) Python 문자열 안 # 미제거", "a # b" in na and "comment" not in na)

    nb = _normalize('def f():\n    """doc here"""\n    return 1\n', "python", noop)
    check("(b) Python 독스트링 제거",
          "doc here" not in nb and "return 1" in nb and "def f():" in nb)

    nc = _normalize('var u = "http://x";\n// real comment\n', "js", noop)
    check("(c) JS 문자열 안 // 미제거", "http://x" in nc and "real comment" not in nc)

    nd = _normalize("a;\n/* c1\n c2 */\nb;\n", "cstyle", noop)
    check("(d) 다줄 block comment 제거",
          "c1" not in nd and "c2" not in nd and "a;" in nd and "b;" in nd)

    import tempfile
    with tempfile.TemporaryDirectory() as td:
        def wr(name, body):
            p = os.path.join(td, name)
            with open(p, "w", encoding="utf-8") as f:
                f.write(body)
            return p
        e_a = wr("e_a.py", "x = 1\n\n\ny = 2\n")
        e_b = wr("e_b.py", "x = 1   \ny = 2\n\n")
        check("(e) trailing WS·빈 줄만 다르면 exit 0", _compare(e_a, e_b, None)[0] == 0)
        f_a = wr("f_a.py", "x = 1\n")
        f_b = wr("f_b.py", "x = 2\n")
        check("(f) 코드 실차면 exit 1", _compare(f_a, f_b, None)[0] == 1)

        # (j) 회귀 — JS 정규식 안 `//` 를 코멘트로 오인해 뒤 코드를 지우지 않는다.
        j_a = wr("j_a.js", "const p = str.split(/\\/\\//); return ALPHA;\n")
        j_b = wr("j_b.js", "const p = str.split(/\\/\\//); return BETA;\n")
        check("(j) JS 정규식 리터럴 뒤 실차 검출(exit 1)", _compare(j_a, j_b, None)[0] == 1)

        # (k) 회귀 — 문자열 안 빈 줄 차이 검출(런타임 값 다름).
        k_a = wr("k_a.py", 'T = """a\n\nb"""\n')
        k_b = wr("k_b.py", 'T = """a\nb"""\n')
        check("(k) 문자열 안 빈 줄 차이 검출(exit 1)", _compare(k_a, k_b, None)[0] == 1)

        # (l) 회귀 — 문자열 안 행끝 공백 차이 검출.
        l_a = wr("l_a.py", 'T = """a \nb"""\n')
        l_b = wr("l_b.py", 'T = """a\nb"""\n')
        check("(l) 문자열 안 행끝 공백 차이 검출(exit 1)", _compare(l_a, l_b, None)[0] == 1)

        # (m) 회귀 — C++ 숫자 구분자 뒤 코멘트가 정상 제거된다(가짜 char 리터럴 X).
        m_a = wr("m_a.cpp", "int n = 1'000; // c1\n")
        m_b = wr("m_b.cpp", "int n = 1'000; // c2\n")
        check("(m) C++ digit separator 뒤 코멘트 제거(exit 0)", _compare(m_a, m_b, None)[0] == 0)

        # (n) 코드 빈 줄 차이는 여전히 노이즈(exit 0) — string-aware 가 코드 빈 줄엔 무영향.
        n_a = wr("n_a.py", "x = 1\ny = 2\n")
        n_b = wr("n_b.py", "x = 1\n\ny = 2\n")
        check("(n) 코드 빈 줄만 다르면 exit 0", _compare(n_a, n_b, None)[0] == 0)

        # (o) Markdown 문단 경계(빈 줄) 보존 — 문단 병합을 노이즈로 덮지 않는다(exit 1).
        o_a = wr("o_a.md", "a\nb\n")
        o_b = wr("o_b.md", "a\n\nb\n")
        check("(o) Markdown 빈 줄(문단 경계) 차이 검출(exit 1)", _compare(o_a, o_b, None)[0] == 1)

        # (q) 회귀 — 키워드 뒤 정규식 인식 실패 경로(prev_word 가 공백을 건너 오염)
        #     로 char class 안 `//` 를 코멘트로 오인·코드 삭제하지 않는다.
        q_a = wr("q_a.js", "let x = flag\nreturn /[//]/.test(s) ? ALPHA : BETA\n")
        q_b = wr("q_b.js", "let x = flag\nreturn /[//]/.test(s) ? GAMMA : DELTA\n")
        check("(q) 줄 넘긴 키워드 뒤 정규식 실차 검출(exit 1)", _compare(q_a, q_b, None)[0] == 1)

        # (r) 회귀 — `)` 선행 정규식 위치.
        r_a = wr("r_a.js", "const p = f(x)\n/[//]/.test(s) && ALPHA;\n")
        r_b = wr("r_b.js", "const p = f(x)\n/[//]/.test(s) && BETA;\n")
        check("(r) `)` 선행 정규식 뒤 실차 검출(exit 1)", _compare(r_a, r_b, None)[0] == 1)

        # (s) 회귀 — `.sh` heredoc 본문의 `#` 는 셸 코멘트가 아니라 리터럴이라 보존.
        s_a = wr("s_a.sh", "cat <<EOF\n# 포인터 해석표 (생성물)\nEOF\n")
        s_b = wr("s_b.sh", "cat <<EOF\n# 포인터 해석표 (원본)\nEOF\n")
        check("(s) heredoc 본문 `#` 라인 차이 검출(exit 1)", _compare(s_a, s_b, None)[0] == 1)

        # (t) heredoc 밖 실제 셸 코멘트는 여전히 제거(exit 0), 본문 밖 코드 실차는 검출.
        t_a = wr("t_a.sh", "cat <<EOF\nsame\nEOF\nX=1 # c1\n")
        t_b = wr("t_b.sh", "cat <<EOF\nsame\nEOF\nX=1 # c2\n")
        check("(t) heredoc 종료 후 셸 코멘트 제거(exit 0)", _compare(t_a, t_b, None)[0] == 0)

    ng = _normalize("x = 1;\n% section note\ny = 2;  % trailing\n", "matlab", noop)
    check("(g) MATLAB % 라인 코멘트 제거",
          "section note" not in ng and "trailing" not in ng
          and "x = 1;" in ng and "y = 2;" in ng)

    nh = _normalize("s = 'a % b';\n% real\n", "matlab", noop)
    # best-effort: FAIL 이면 PASS 처리하지 않고 그대로 노출(호출부가 known-limitation 판단).
    check("(h) MATLAB 문자열 안 % 보존(best-effort)", "a % b" in nh and "real" not in nh)

    ni = _normalize('{\n  "a": 1, // JSONC_NOTE\n  "b": "http://x"\n}\n', "json", noop)
    check("(i) JSON(JSONC) // 제거·문자열 안 // 보존",
          "JSONC_NOTE" not in ni and "http://x" in ni)

    # (p) JS 정규식 char class 안 `//` 보존 — 코드 삭제 없이 실차 검출.
    pa = _normalize("x = /[//]/.test(a);\nZED;\n", "js", noop)
    check("(p) JS 정규식 char class 뒤 코드 보존", "ZED" in pa)

    ok = all(results)
    print("\nselftest: %d/%d PASS" % (sum(results), len(results)))
    return 0 if ok else 1


def main():
    ap = argparse.ArgumentParser(
        description="코멘트·공백 노이즈 제거 후 두 파일을 비교하는 A/B 전처리 게이트.")
    ap.add_argument("files", nargs="*", help="비교할 두 파일 A B (--show 는 1~2개)")
    ap.add_argument("--show", action="store_true", help="diff 대신 정규화본 자체 출력(항상 exit 0)")
    ap.add_argument("--lang", default=None, choices=LANG_CHOICES, metavar="LANG",
                    help="언어 강제(기본 auto=확장자). 선택: " + " ".join(LANG_CHOICES))
    ap.add_argument("--selftest", action="store_true", help="자체 회귀 테스트")
    args = ap.parse_args()

    if args.selftest:
        return _selftest()

    def err(msg):
        sys.stderr.write("[ERROR] %s\n" % msg)

    for p in args.files:
        if not os.path.isfile(p):
            err("파일 없음(또는 파일 아님): %s" % p)
            return 2

    if args.show:
        if not 1 <= len(args.files) <= 2:
            err("--show 는 파일 1~2개가 필요하다.")
            return 2
        for k, p in enumerate(args.files):
            try:
                text, warns = normalize_path(p, args.lang)
            except (OSError, UnicodeDecodeError) as e:
                err("%s: %s" % (p, e))
                return 2
            for w in warns:
                sys.stderr.write("[WARN] %s: %s\n" % (p, w))
            if len(args.files) == 2:
                if k:
                    sys.stdout.write("\n")
                sys.stdout.write("==> %s <==\n" % p)
            sys.stdout.write(text)
        return 0

    if len(args.files) != 2:
        err("비교에는 파일 두 개(A B)가 필요하다.")
        return 2
    try:
        rc, diff, wa, wb = _compare(args.files[0], args.files[1], args.lang)
    except (OSError, UnicodeDecodeError) as e:
        err(str(e))
        return 2
    for p, ws in ((args.files[0], wa), (args.files[1], wb)):
        for w in ws:
            sys.stderr.write("[WARN] %s: %s\n" % (p, w))
    if diff:
        print("\n".join(diff))
    return rc


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""색 토큰 게이트 — CSS·HTML(<style>)의 사용자 정의 속성(--이름: 색)을 라이트·다크 두 모드로 읽어
대비·구조색 채도·유채 면적·사용처를 기계로 판정한다(사람 재계산 대체).

판정 4축:
  1. 대비 — 쌍(전경·배경·최소비)마다 WCAG 2.x 상대 휘도 대비비. 표준 토큰 이름(n-0 · n-10 이 있으면)을
     쓰는 파일은 기준 게이트 11쌍(web_page.md §5 표)을 자동 적용한다(--no-default-pairs 로 끔).
     쌍 추가 = --pair 이름:전경:배경:최소비(반복) · --pairs 파일.json(반복). 전경·배경 = 토큰 이름 또는 색 값.
  2. 구조색 채도 — 지정 토큰(기본 = 어느 모드에든 정의된 n-0…n-10 · 한 모드에만 없으면 그 칸 FAIL)의 OKLCH C ≤
     --max-chroma(기본 0.032).
  3. 유채 면적 — --area 스크린샷.png(반복): 픽셀별 OKLCH C > --area-chroma(기본 0.05) 인 비율 ≤ --area-max
     (기본 5%). PNG 는 zlib 으로 직접 디코드 — 8-bit RGB/RGBA · 비인터레이스만. --area 가 없으면 「미실행」.
  4. 사용처 — 토큰 정의(--이름: 값)가 아닌 모든 선언(규칙 · HTML style 속성)을 모드마다 var() 연쇄로 따라가:
     color·fill·stroke 가 장식 단계(--decor-tokens · 기본 n-5,n-6)를 가리키면 FAIL ·
     배경(background·background-color·background-image)이 틴트(--tint-tokens · 기본 = 이름이 -bg 로 끝나고
     중성 램프 n-* 를 가리키지 않는 토큰 — --accent-bg · 상태 --ok-bg 등)인데
     같은 규칙에 보이는 테두리(border·outline)가 없으면 경고(다른 규칙에서 받을 수 있어 FAIL 아님).
     테두리의 장식 단계·리터럴 색·루트 토큰의 규칙 범위 재정의·중첩 규칙(CSS nesting) 안 선언·
     <noscript>·<template> 안 스타일(선언형 shadow DOM 안은 브라우저에서 살아 있음)은 판정 밖(사람 몫). --no-usage 로 끔
     (끄면 「미실행」).

모드:
  라이트 = :root{…}(OS 라이트 · data-theme 속성 없음 · 화면에 적용되는 미디어만). 판정할 수 있는 라이트 정의가 없으면
           (다크·속성 조건 블록·판정 밖 선택자만 있음) FAIL.
  다크   = @media (prefers-color-scheme: dark){ :root…{…} }(OS 다크) 와 :root[data-theme="dark"]{…}(강제 다크).
           둘 다 있으면 같은 값이어야 한다 — 다르면 경고하고 둘 다 판정한다. 다크 정의가 없으면 FAIL
           (다크 블록을 만든다 — 웹 페이지·Artifact·도식은 다크 전환 필수 · 끄는 옵션 없음).
  var(--x[, 대체값]) 는 같은 모드 안에서 풀어서 판정한다(중첩 허용 · 순환 = 오류 · 미정의 + 대체값 없음 = 오류).
  캐스케이드 = !important > 명시도(specificity) > 나중 선언. 루트(:root·html)로 보지 않은 선택자와 판정할 수 없는 조건
  (@media 폭 조건·클래스 등)의 정의는 판정에서 빼고 알림으로 적는다. @supports 는 (color: 색) 조건만 판정한다 — 도구가
  읽는 색 표기(아래 「색 표기」)면 지원(참) · not 이면 반대 · 그 밖 조건(display·selector() · 도구가 못 읽는 색 등)은
  판정할 수 없는 조건이다. @layer 안 정의는 적용하되 층 순서는 선언 순서로 근사하고 알림으로 적는다.

HTML 읽기: 표준 파서(html.parser)로 한 번 훑어 브라우저가 살려 두는 <style> 내용과 style 속성만 판정한다.
  판정 밖 = HTML 주석 · <script> 내용 · 글자로만 읽히는 요소(title·textarea·xmp·iframe·noembed·noframes·noscript·
  plaintext)의 내용 · <template> 안(선언형 shadow DOM 포함 — 알림) · type 이 CSS 가 아닌 <style>. SVG 안 <style> 은
  살아 있다. 열린 요소는 표준대로 쌓는다 — 암묵 닫기(끝 태그 없이 닫히는 p·li 등) · 표 모드(칸·행이 암묵으로 닫히고
  표 밖에 온 td·tr 같은 표 부품은 버려짐) · form 포인터(template 밖에서 만든 form 은 </form> 이 올 때까지 — 그
  form 이 먼저 닫혀도 — 새 <form> 을 막음) · ruby.
  한계 = 다음 넷은 따라가지 않는다. ① 서식 요소(a·b·i·font 등)의 adoption agency·active formatting 재구성 — 암묵으로 닫혔다
  다시 열린 서식 요소의 끝 태그가 안 닫힌 SVG·MathML 위로 오면 브라우저는 SVG·MathML 을 닫고 도구는 열어 둔다.
  ② <select> 전용 규칙 — 예: select 안에 div 같은 special 요소(div·p·img·input 처럼 HTML 표준이 따로 분류한 요소)를 둔 채 </select> 가 오면 브라우저는 그 위 요소(안 닫힌 SVG
  포함)를 모두 닫고 도구는 열어 둔다. ①② 뒤에서는 <textarea> 안 <style>(도구는 SVG 로 읽어 살림)·<style>(도구는
  MathML 로 읽어 버림) 판정이 갈린다. ③ <frameset> — <body> 태그·본문 글자 등보다 먼저 온 <frameset> 은 브라우저가
  body 를(생겼으면) 떼어 내고 뒤 태그를 버려 그 안·뒤 스타일이 죽는데 도구는 살아 있다고 세고, 반대로 그 frameset 안
  <frame> 의 style 속성은 브라우저에선 살아 있는데 도구는 버린다(거짓 PASS 쪽). 그보다 늦게 온 <frameset> 은 브라우저가
  태그째 버려 자신의 style 속성도 죽는데 도구는 살아 있다고 센다(거짓 FAIL 쪽). ④ shadow root 를 붙일 수 있는
  부모인지(div·span·사용자 정의 요소 등은 붙고 head·table 등은 못 붙음) — 도구는 <template shadowrootmode> 를 모두
  선언형 shadow DOM 으로 본다. 붙은 경우 그 template 자신의 style 속성은 브라우저에선 문서에 들어가지 않아 죽는데
  도구는 살아 있다고 세고(거짓 FAIL 쪽), 못 붙는 부모 아래 것에도 「살아 있음」 알림을 낸다.

색 표기: #RGB · #RGBA · #RRGGBB · #RRGGBBAA · rgb()/rgba()(쉼표·공백 문법) · oklch(L C H[ / A])
  (L = 0–1 또는 % · C = 수 또는 %(100% = 0.4) · H = 수 또는 deg·rad·grad·turn) · white · black · transparent.
  OKLCH → sRGB 가 gamut 밖이면 채널을 0–1 로 clip 하고 표시한다. 판정은 8-bit 로 반올림한 sRGB
  (화면에 칠해지는 값) 기준 — 대비·채도 모두.
  반투명 전경은 배경 위에 합성해 대비를 잰다. 반투명 배경은 그 아래 색을 알 수 없어 판정 불가(FAIL).

쌍 파일(--pairs) 형식(UTF-8 · BOM 있어도 됨):
  {"pairs": [{"name": "…", "fg": "토큰|색", "bg": "토큰|색", "min": 4.5}, …],
   "chroma_tokens": ["토큰", …],                                   (선택 · 채도 판정 대상에 추가)
   "forbid_refs": {"tokens": ["n-5", "n-6"], "in": ["토큰", …]}}   (선택 · var() 연쇄에 금지 토큰이 끼면 FAIL)

사용(<설치경로> = 설치본은 홈의 .claude 를 펼친 절대 경로 · 패키지 저장소는 Settings_for_Claude 절대 경로 —
  원본 = visual-design 스킬 SKILL.md 「도구 경로」 · 입력 파일은 UTF-8):
  python <설치경로>/tools/check_color_tokens.py 페이지.html
  python <설치경로>/tools/check_color_tokens.py 페이지.html --pairs <설치경로>/tools/color_pairs_diagram.json
  python <설치경로>/tools/check_color_tokens.py 토큰.css --pair "포커스링:focus:n-0:3"
  python <설치경로>/tools/check_color_tokens.py 페이지.html --area light.png --area dark.png
  python <설치경로>/tools/check_color_tokens.py --area 스크린샷.png                 (면적만)
  python <설치경로>/tools/check_color_tokens.py 페이지.html --no-usage               (사용처 검사 끔)
  python <설치경로>/tools/check_color_tokens.py --fg "#1428A0" --bg "#FFFFFF" [--min 4.5]   (직접 모드)
  python <설치경로>/tools/check_color_tokens.py --selftest
출력 끝: [경고 N](판정에는 넣지 않음 · 전달 전 해소) · [알림 N](판정 밖 = 도구가 읽지 않는 것 · 근사 = 어림한 판정 ·
  사람 확인) · [판정 축] 4축마다 판정 · 판정 안 됨(이유) · 미실행(이유) · [요약] FAIL x · 경고 y · 알림 z →
  PASS|FAIL|판정 안 됨 (exit n).
  판정 안 됨 = 파일을 읽었는데 판정한 대비 쌍이 0 이거나(쌍 없음 · 넘긴 쌍이 전부 판정 밖) 채도 토큰이 0 — PASS 가 아니다.
  미실행 = 돌리지 않은 축(유채 면적 = --area 없음 · 사용처 = --no-usage · 면적만 모드의 파일 축) — 통과가 아니다.
종료코드: 0 = 판정한 축 전건 PASS · 1 = FAIL 1건 이상(판정 불가 포함) 또는 판정 안 됨 · 2 = 입력·사용 오류(파일 없음·
  UTF-8 아닌 파일·PNG 형식 미지원 등).
직접 모드는 --min 을 줄 때만 판정한다(없으면 정보 출력 · 0).
stdlib 전용 · UTF-8 명시 · Python 3.10+.
"""
import sys

# ── Windows stdout 인코딩 방어 (cp949 크래시 차단 · 패키지 CLI 도구 표준) ──
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

if sys.version_info < (3, 10):
    sys.stderr.write(
        "오류: Python 3.10 이상이 필요하다 (현재: {}.{}.{}).\n".format(*sys.version_info[:3]))
    sys.exit(1)

import argparse
import functools
import json
import math
import os
import re
import string
import struct
import unicodedata
import zlib
from collections import Counter
from dataclasses import dataclass, field
from html import unescape as _html_unescape
from html.entities import html5 as _HTML5
from html.parser import HTMLParser
from itertools import accumulate

DEFAULT_MAX_CHROMA = 0.032
DEFAULT_AREA_CHROMA = 0.05
DEFAULT_AREA_MAX = 5.0          # 퍼센트

RAMP = ["n-%d" % i for i in range(11)]

# web_page.md §5 「기준 블록 게이트 실측」 표와 같은 11쌍 — 표가 바뀌면 함께 바꾼다(--selftest 가 대조).
STANDARD_PAIRS = [
    ("본문 텍스트", "n-10", "n-0", 4.5),
    ("보조 본문", "n-9", "n-0", 4.5),
    ("약한 텍스트", "n-8", "n-0", 4.5),
    ("강조 텍스트·링크", "accent", "n-0", 4.5),
    ("포커스링·컴포넌트 경계", "n-7", "n-0", 3.0),
    ("요소배경 위 본문", "n-10", "n-2", 4.5),
    ("틴트 위 본문", "n-10", "accent-bg", 4.5),
    ("틴트 위 강조", "accent", "accent-bg", 4.5),
    ("요소배경 위 경계", "n-7", "n-2", 3.0),
    ("강조 hover", "accent-hover", "n-0", 4.5),
    ("틴트 위 강조 hover", "accent-hover", "accent-bg", 4.5),
]

# 판정 상태 = (OS 색 선호, data-theme 속성값 | None)
STATE_LIGHT = ("light", None)
STATE_DARK = ("dark", None)
STATE_FORCED_DARK = ("light", "dark")
STATE_FORCED_LIGHT_ON_DARK = ("dark", "light")


class InputError(Exception):
    """입력·사용 오류 — 종료코드 2."""


class ColorError(Exception):
    """색 판정 불가(미정의·순환·미지원 표기) — 그 행은 FAIL."""


# ═══════════════════════════ 색 변환 ═══════════════════════════

@dataclass
class Color:
    rgb: tuple                  # 8-bit sRGB (r, g, b)
    alpha: float = 1.0
    clipped: bool = False       # OKLCH → sRGB 에서 gamut 밖이라 clip 됨
    text: str = ""              # 전개된 원문(var() 풀린 값)

    @property
    def hex(self):
        return "#%02X%02X%02X" % self.rgb


def _lin(c8):
    # sRGB 8-bit → 선형 RGB. WCAG 2.x 상대 휘도·OKLab 공통(8-bit 값에서는 0.03928·0.04045 임계가 같은 결과).
    c = c8 / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _enc(v):
    # 선형 RGB → sRGB 감마(부호 보존 — gamut 밖 판정용).
    s = -1.0 if v < 0 else 1.0
    v = abs(v)
    e = 12.92 * v if v <= 0.0031308 else 1.055 * v ** (1 / 2.4) - 0.055
    return s * e


def _q8(e):
    # 0–1 감마값 → 8-bit(반올림 · 0–255 clamp).
    return max(0, min(255, int(math.floor(e * 255 + 0.5))))


def luminance(rgb):
    r, g, b = (_lin(v) for v in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(fg_rgb, bg_rgb):
    # WCAG 2.x: (L밝은 + 0.05) / (L어두운 + 0.05)
    la, lb = luminance(fg_rgb), luminance(bg_rgb)
    hi, lo = (la, lb) if la >= lb else (lb, la)
    return (hi + 0.05) / (lo + 0.05)


def _cbrt(x):
    return math.copysign(abs(x) ** (1.0 / 3.0), x)


def srgb8_to_oklch(rgb):
    # sRGB → 선형 → LMS → OKLab(Ottosson 행렬) → LCH. H 는 도(0–360).
    r, g, b = (_lin(v) for v in rgb)
    l_ = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
    m_ = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
    s_ = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
    L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    B = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    return L, math.hypot(A, B), math.degrees(math.atan2(B, A)) % 360.0


def oklch_to_srgb8(L, C, H):
    """OKLCH → 8-bit sRGB. 반환 (rgb, clipped) — clipped = gamut 밖이라 8-bit 값이 clip 으로 바뀜."""
    h = math.radians(H)
    a, b = C * math.cos(h), C * math.sin(h)
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_ ** 3, m_ ** 3, s_ ** 3
    lin = (4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
           -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
           -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)
    half = 0.5 / 255
    clipped = False
    out = []
    for v in lin:
        e = _enc(v)
        if e < -half or e > 1 + half:
            clipped = True
        out.append(_q8(min(1.0, max(0.0, e))))
    return tuple(out), clipped


def composite(fg, bg):
    # 반투명 전경을 불투명 배경 위에 감마 sRGB 공간에서 합성(브라우저 기본 합성).
    a = fg.alpha
    rgb = tuple(_q8((f * a + b * (1 - a)) / 255.0) for f, b in zip(fg.rgb, bg.rgb))
    return Color(rgb, 1.0, fg.clipped, fg.text)


# ═══════════════════════════ 색 표기 파싱 ═══════════════════════════

_NUM = r"[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?"
_NUM_UNIT = re.compile(r"(" + _NUM + r")(%|deg|rad|grad|turn)?")
_NAMED = {"white": (255, 255, 255, 1.0), "black": (0, 0, 0, 1.0), "transparent": (0, 0, 0, 0.0)}
_FUNC = re.compile(r"(rgba?|oklch)\((.*)\)", re.S)


def _num(tok):
    tok = tok.strip().lower()
    if tok == "none":
        return 0.0, None
    m = _NUM_UNIT.fullmatch(tok)
    if not m:
        raise ColorError("수가 아님: %r" % tok)
    return float(m.group(1)), m.group(2)


def _split_channels(inner):
    # "a b c / d" · "a, b, c, d" → ([a, b, c], d | None)
    inner = " ".join(inner.split())
    if "," in inner:
        parts = [p.strip() for p in inner.split(",")]
        if len(parts) not in (3, 4):
            raise ColorError("채널 수 오류: %r" % inner)
        return parts[:3], (parts[3] if len(parts) == 4 else None)
    alpha = None
    main = inner
    if "/" in inner:
        main, alpha = inner.split("/", 1)
        alpha = alpha.strip()
    parts = main.split()
    if len(parts) != 3:
        raise ColorError("채널 수 오류: %r" % inner)
    return parts, alpha


def _alpha(tok):
    if tok is None:
        return 1.0
    v, unit = _num(tok)
    if unit == "%":
        v /= 100.0
    elif unit is not None:
        raise ColorError("알파 단위 오류: %r" % tok)
    return min(1.0, max(0.0, v))


def parse_color(text):
    """색 값 문자열 → Color. 지원 밖 표기는 ColorError."""
    t = text.strip()
    low = t.lower()
    if low in _NAMED:
        r, g, b, a = _NAMED[low]
        return Color((r, g, b), a, False, t)
    if t.startswith("#"):
        hx = t[1:]
        if not re.fullmatch(r"[0-9A-Fa-f]+", hx) or len(hx) not in (3, 4, 6, 8):
            raise ColorError("hex 표기 오류: %r" % t)
        if len(hx) in (3, 4):
            hx = "".join(ch * 2 for ch in hx)
        rgb = tuple(int(hx[i:i + 2], 16) for i in (0, 2, 4))
        a = int(hx[6:8], 16) / 255.0 if len(hx) == 8 else 1.0
        return Color(rgb, a, False, t)
    m = _FUNC.fullmatch(low)
    if not m:
        raise ColorError("지원 밖 색 표기: %r" % t)
    fn, inner = m.group(1), m.group(2)
    chans, alpha_tok = _split_channels(inner)
    if fn in ("rgb", "rgba"):
        vals = []
        for tok in chans:
            v, unit = _num(tok)
            if unit == "%":
                v = v * 255.0 / 100.0
            elif unit is not None:
                raise ColorError("rgb() 단위 오류: %r" % tok)
            vals.append(max(0, min(255, int(math.floor(v + 0.5)))))
        return Color(tuple(vals), _alpha(alpha_tok), False, t)
    # oklch
    Lv, Lu = _num(chans[0])
    if Lu == "%":
        Lv /= 100.0
    elif Lu is not None:
        raise ColorError("oklch L 단위 오류: %r" % chans[0])
    Cv, Cu = _num(chans[1])
    if Cu == "%":
        Cv = Cv * 0.4 / 100.0
    elif Cu is not None:
        raise ColorError("oklch C 단위 오류: %r" % chans[1])
    Hv, Hu = _num(chans[2])
    if Hu == "rad":
        Hv = math.degrees(Hv)
    elif Hu == "grad":
        Hv = Hv * 0.9
    elif Hu == "turn":
        Hv = Hv * 360.0
    elif Hu not in (None, "deg"):
        raise ColorError("oklch H 단위 오류: %r" % chans[2])
    Lv = min(1.0, max(0.0, Lv))       # CSS: L 은 [0,1] 로 clamp · C 는 음수 clamp
    Cv = max(0.0, Cv)
    rgb, clipped = oklch_to_srgb8(Lv, Cv, Hv)
    return Color(rgb, _alpha(alpha_tok), clipped, t)


def looks_literal(spec):
    s = spec.strip().lower()
    return s.startswith("#") or s in _NAMED or bool(re.match(r"(rgba?|oklch)\(", s))


# ═══════════════════════════ CSS 파싱 ═══════════════════════════

@dataclass
class Rule:
    ctx: tuple                  # 바깥 at-rule 머리말들(예: "@media (prefers-color-scheme: dark)")
    selector: str
    decls: list                 # 사용자 정의 속성 [(이름(-- 뺌), 값, important)]
    order: int = 0
    plain: list = field(default_factory=list)   # 일반 선언 [(속성(소문자), 값, important)] — 사용처 검사용


def _strip_comments(css):
    out = []
    i, n, q = 0, len(css), None
    while i < n:
        c = css[i]
        if q:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(css[i + 1])
                i += 2
                continue
            if c == q:
                q = None
            i += 1
            continue
        if c in "\"'":
            q = c
            out.append(c)
            i += 1
            continue
        if css.startswith("/*", i):
            j = css.find("*/", i + 2)
            i = n if j < 0 else j + 2
            out.append(" ")
            continue
        out.append(c)
        i += 1
    return "".join(out)


def _skip_string(s, i):
    q = s[i]
    i += 1
    while i < len(s):
        if s[i] == "\\":
            i += 2
            continue
        if s[i] == q:
            return i + 1
        i += 1
    return i


def _match_close(s, i, open_ch="{", close_ch="}"):
    # s[i] 는 여는 괄호 바로 뒤. 짝 닫는 괄호 위치(없으면 len).
    depth = 1
    while i < len(s):
        c = s[i]
        if c in "\"'":
            i = _skip_string(s, i)
            continue
        if c == open_ch:
            depth += 1
        elif c == close_ch:
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return len(s)


_IMPORTANT = re.compile(r"!\s*important\s*$", re.I)


def _parse_decls(body, notes):
    parts, start, depth, i, n = [], 0, 0, 0, len(body)
    while i < n:
        c = body[i]
        if c in "\"'":
            i = _skip_string(body, i)
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth = max(0, depth - 1)
        elif c == "{":
            # 중첩 규칙(CSS nesting) — 판정 밖. 중첩 선택자 조각째 버린다.
            j = _match_close(body, i + 1)
            notes.add("중첩 규칙(CSS nesting) 안 선언은 판정 밖 — 토큰 정의·사용처 모두(참조는 대비 판정에 셈)")
            i = j + 1
            start = i
            continue
        elif c == ";" and depth == 0:
            parts.append(body[start:i])
            start = i + 1
        i += 1
    parts.append(body[start:])
    decls, plain = [], []
    for p in parts:
        name, sep, value = p.partition(":")
        name = name.strip()
        if not sep or not name:
            continue
        value = value.strip()
        imp = bool(_IMPORTANT.search(value))
        if imp:
            value = _IMPORTANT.sub("", value).strip()
        if name.startswith("--"):
            decls.append((name[2:], value, imp))
        else:
            plain.append((name.lower(), value, imp))
    return decls, plain


def parse_css(css, notes):
    css = _strip_comments(css)
    rules = []
    n = len(css)

    def block(i, ctx):
        start = i
        while i < n:
            c = css[i]
            if c in "\"'":
                i = _skip_string(css, i)
                continue
            if c == "{":
                prelude = " ".join(css[start:i].split())
                if prelude.startswith("@"):
                    i = block(i + 1, ctx + (prelude,))
                else:
                    j = _match_close(css, i + 1)
                    decls, plain = _parse_decls(css[i + 1:j], notes)
                    rules.append(Rule(ctx, prelude, decls, plain=plain))
                    i = j + 1
                start = i
                continue
            if c == "}":
                return i + 1
            if c == ";":
                start = i + 1
            i += 1
        return i

    i = 0
    while i < n:
        i = block(i, ())
    for k, r in enumerate(rules):
        r.order = k
    return rules


def _is_html(text, path):
    ext = os.path.splitext(path)[1].lower()
    return ext in (".html", ".htm") or bool(re.search(r"<(!doctype|html|style)\b", text[:4096], re.I))


# ── HTML 읽기 — 표준 파서(html.parser) 위에서 HTML 표준(브라우저) 규칙대로 ──
# 살아 있는 CSS = <style> 글자 내용 · 사용처 = 시작 태그의 style 속성(글자 요소 자신의 시작 태그 포함).
# 판정 밖 = HTML 주석 · bogus comment(<![CDATA[·<?·<!x — HTML 문맥) · <script> 내용 · 글자로만 읽히는 요소의 내용
# (title·textarea·xmp·iframe·noembed·noframes·noscript[스크립트 켜짐]·plaintext) · <template> 안(중첩·선언형 shadow DOM 포함) ·
# type 이 CSS 가 아닌 <style>. SVG·MathML 안(foreign content)은 태그째 읽고, CSS 는 SVG <style> 의 직계 글자만.

_WS = "\t\n\f\r "
_LOWER = str.maketrans(string.ascii_uppercase, string.ascii_lowercase)     # 태그·속성 이름은 ASCII 만 소문자로
_RAW_TEXT = ("style", "script", "title", "textarea", "xmp", "iframe", "noembed", "noframes", "noscript", "plaintext")
_RAW_END = {t: re.compile(r"</%s(?=[\t\n\f\r />])" % t, re.I | re.A) for t in _RAW_TEXT}
_SCRIPT_MARK = re.compile(r"<!--|-->|<(/?)script(?=[\t\n\f\r />])", re.I | re.A)
_COMMENT_END = re.compile(r"--!?>")
_ATTR_REF = re.compile(r"&(?:#[0-9]+;?|#[xX][0-9a-fA-F]+;?|([A-Za-z][A-Za-z0-9]*)(;?))")
_VOID = frozenset("area base basefont bgsound br col embed frame hr image img input keygen link meta param source "
                  "track wbr".split())
# foreign content 에서 이 시작 태그를 만나면 SVG·MathML 요소를 닫고 HTML 로 돌아간다(font 는 color·face·size 가 있을 때만)
_BREAKOUT = frozenset("b big blockquote body br center code dd div dl dt em embed h1 h2 h3 h4 h5 h6 head hr i img li "
                      "listing menu meta nobr ol p pre ruby s small span strong strike sub sup table tt u ul var"
                      .split())
_SPECIAL = frozenset("address applet area article aside base basefont bgsound blockquote body br button caption center "
                     "col colgroup dd details dir div dl dt embed fieldset figcaption figure footer form frame "
                     "frameset h1 h2 h3 h4 h5 h6 head header hgroup hr html iframe img input keygen li link listing "
                     "main marquee menu meta nav noembed noframes noscript object ol p param plaintext pre script "
                     "search section select source style summary table tbody td template textarea tfoot th thead "
                     "title tr track ul wbr xmp".split())
_SCOPE_EDGE = frozenset("applet caption html table td th marquee object template".split())
_BUTTON_EDGE = _SCOPE_EDGE | {"button"}
_LIST_EDGE = _SCOPE_EDGE | {"ol", "ul"}
# 이 끝 태그는 범위(_SCOPE_EDGE) 안의 같은 이름 요소까지 닫는다 — p(button 범위)·li(목록 범위)·제목(아무 제목)·form·
# 표 요소(표 모드)는 따로 · 그 밖 끝 태그는 special 요소(_SPECIAL)에서 멈춘다
_SCOPE_END = frozenset("address article aside blockquote button center details dialog dir div dl fieldset figcaption "
                       "figure footer header hgroup listing main menu nav ol pre search section summary ul dd dt "
                       "applet marquee object".split())
_HEADINGS = frozenset("h1 h2 h3 h4 h5 h6".split())
# generate implied end tags 가 닫는 요소 — 현재 요소가 이 중 하나인 동안 되풀이해 닫는다
_IMPLIED_END = frozenset("dd dt li optgroup option p rb rp rt rtc".split())
# 표 부품 시작 태그 — 표 밖(열린 표 요소·template 이 없을 때)에서는 무시돼 요소가 생기지 않고 style 속성도 죽는다 ·
# 표 모드에서는 칸·행·구역을 표준대로 닫고 빠진 것을 채운다(_table_start)
_TABLE_PARTS = frozenset("caption col colgroup tbody td tfoot th thead tr".split())
# 표 모드를 정하는 열린 HTML 요소 — 위에서 가장 가까운 것이 지금 모드(칸·행·구역·caption·colgroup·표 · template)
_TABLE_CTX = frozenset("caption colgroup table tbody td template tfoot th thead tr".split())
# 표 요소 끝 태그 → 그 태그가 닫는 표 모드(가장 가까운 열린 표 요소) — 다른 표 모드에서는 버린다
_CELL_ROW_BODY = frozenset("td th tr tbody thead tfoot".split())
_TABLE_END = {"table": _TABLE_CTX - {"template"}, "tbody": _CELL_ROW_BODY, "thead": _CELL_ROW_BODY,
              "tfoot": _CELL_ROW_BODY, "tr": frozenset("td th tr".split()), "td": frozenset("td th".split()),
              "th": frozenset("td th".split()), "caption": frozenset(["caption"]),
              "colgroup": frozenset(["colgroup"]), "col": frozenset()}
# 이 시작 태그는 button 범위 안에 열린 p 를 먼저 닫는다(table 은 quirks 모드가 아닐 때만)
_CLOSES_P = frozenset("address article aside blockquote center details dialog dir div dl fieldset figcaption figure "
                      "footer header hgroup main menu nav ol p search section summary ul h1 h2 h3 h4 h5 h6 pre "
                      "listing form plaintext hr xmp li dd dt".split())
_INTEGRATION = {("svg", "foreignobject"): "html", ("svg", "desc"): "html", ("svg", "title"): "html",
                ("math", "mi"): "text", ("math", "mo"): "text", ("math", "mn"): "text", ("math", "ms"): "text",
                ("math", "mtext"): "text"}
# DOCTYPE 이 quirks 모드를 여는 옛 공개 식별자(앞부분 · ASCII 소문자)
_QUIRKS_PUBLIC = ("+//silmaril//", "-//as//", "-//advasoft ltd//", "-//ietf//", "-//metrius//", "-//microsoft//",
                  "-//netscape comm. corp.//", "-//o'reilly and associates//", "-//sq//", "-//softquad",
                  "-//spyglass//", "-//sun microsystems corp.//", "-//w3c//dtd html 3",
                  "-//w3c//dtd html 4.0 frameset//", "-//w3c//dtd html 4.0 transitional//",
                  "-//w3c//dtd html experimental", "-//w3c//dtd w3 html//", "-//w3o//", "-//webtechs//")
_NOTE_LINK = "외부 스타일시트(<link rel=stylesheet>·@import)는 읽지 않음 — 그 안 토큰은 판정 밖"
_NOTE_INERT = ("<noscript>·<template> 안 <style>·style 속성은 판정 밖(사람 확인 — 스크립트를 끄거나 내용을 복제·"
               "shadow root 로 붙이면 살아남)")
_NOTE_SHADOW = ("선언형 shadow DOM(<template shadowrootmode>) 안 스타일 — 브라우저 파서가 붙여 살아 있음 · "
                "도구 판정 밖(사람 확인)")
_NOTE_TYPE = "type 이 CSS 가 아닌 <style> 은 읽지 않음 — 브라우저도 적용하지 않는다(type 이 비었거나 text/css 일 때만 적용)"
# CSS at-rule 이름 · @import 뒤 주소 첫머리(url( 또는 따옴표) — _has_import
_AT_KEYWORD = re.compile(r"@([A-Za-z0-9_-]+)")
_IMPORT_TARGET = re.compile(r"[\t\n\f\r ]*(?:url\(|[\"'])", re.I)


def _unescape_attr(v):
    """속성값 문자 참조를 브라우저처럼 푼다 — ';' 없는 옛 이름 참조 바로 뒤가 '=' 이거나 영숫자면 그대로 둔다."""
    if "&" not in v:
        return v

    def one(m):
        name = m.group(1)
        if name is None:                                  # 숫자 참조
            return _html_unescape(m.group(0))
        if m.group(2) and name + ";" in _HTML5:
            return _HTML5[name + ";"]
        k = len(name)
        while k and name[:k] not in _HTML5:              # ';' 없는 옛 이름(amp·lt·copy …) 중 가장 긴 앞부분
            k -= 1
        if k < len(name) or v.startswith("=", m.end(1)):
            return m.group(0)
        return _HTML5[name] + m.group(2)

    return _ATTR_REF.sub(one, v)


def _read_tag(s, k):
    """태그 이름 첫 글자(k)부터 → (태그 다음 위치, 이름, [(속성 이름, 값)], self-closing '/>'). 태그 안에서 문서가 끝나면
    None(브라우저는 그 태그를 버린다). 따옴표는 '=' 바로 뒤 값에서만 값을 가른다 · 값 없는 속성 = 빈 글자."""
    n = len(s)
    j = k
    while j < n and s[j] not in _WS and s[j] not in "/>":
        j += 1
    name, attrs, k = s[k:j].translate(_LOWER), [], j
    while True:
        while k < n and s[k] in _WS:
            k += 1
        if k >= n:
            return None
        if s[k] == ">":
            return k + 1, name, attrs, False
        if s[k] == "/":
            if s.startswith("/>", k):
                return k + 2, name, attrs, True
            k += 1
            continue
        j = k + 1                                         # 이름 첫 글자는 '=' · 따옴표여도 이름에 든다
        while j < n and s[j] not in _WS and s[j] not in "/>=":
            j += 1
        aname, k, value = s[k:j].translate(_LOWER), j, ""
        while k < n and s[k] in _WS:
            k += 1
        if k < n and s[k] == "=":
            k += 1
            while k < n and s[k] in _WS:
                k += 1
            if k >= n:
                return None
            if s[k] in "\"'":
                j = s.find(s[k], k + 1)
                if j < 0:
                    return None
                value, k = s[k + 1:j], j + 1
            elif s[k] != ">":
                j = k
                while j < n and s[j] not in _WS and s[j] != ">":
                    j += 1
                value, k = s[k:j], j
            value = _unescape_attr(value)
        attrs.append((aname, value))


def _script_end(s, k):
    """<script> 내용이 끝나는 '</script' 위치(없으면 문서 끝). '<!--' 안에서 '<script' 를 다시 열면 그 뒤 '</script' 는
    닫지 않고 '-->' 까지 이어진다(스크립트 데이터 이스케이프 규칙)."""
    state = 0                                             # 0 보통 · 1 '<!--' 뒤 · 2 '<!--' 뒤 '<script' 뒤
    while True:
        m = _SCRIPT_MARK.search(s, k)
        if not m:
            return len(s)
        tok, k = m.group(), m.end()
        if tok == "<!--":
            state, k = state or 1, m.start() + 2          # 여는 '--' 가 닫는 '-->' 를 겸할 수 있다('<!-->')
        elif tok == "-->":
            state = 0
        elif m.group(1):                                  # '</script'
            if state < 2:
                return m.start()
            state = 1
        elif state == 1:                                  # '<script'
            state = 2


def _raw_end(s, k, tag):
    """글자 요소의 내용(k 부터) → (내용 끝, 끝 태그 다음 위치). 맞는 끝 태그가 없으면 문서 끝까지."""
    n = len(s)
    if tag == "plaintext":
        return n, n
    if tag == "script":
        e = _script_end(s, k)
    else:
        m = _RAW_END[tag].search(s, k)
        e = m.start() if m else n
    got = _read_tag(s, e + 2) if e < n else None
    return e, (got[0] if got else n)


def _quirks_doctype(text):
    """'DOCTYPE …'(<! 와 > 사이) → quirks 모드인가 — 이름이 html 이 아님 · 식별자 문법이 깨짐 · 옛 공개 식별자."""
    m = re.match(r"(?is)doctype[\t\n\f\r ]*([^\t\n\f\r ]*)[\t\n\f\r ]*(.*)", text)
    if not m or m.group(1).translate(_LOWER) != "html":
        return True
    rest = m.group(2)
    if not rest:
        return False
    ids = [x.group(1) if x.group(1) is not None else x.group(2)
           for x in re.finditer(r'"([^"]*)"|\'([^\']*)\'', rest)]
    ibm = "http://www.ibm.com/data/dtd/v11/ibmxhtml1-transitional.dtd"
    kind = rest[:6].translate(_LOWER)
    if kind == "public" and ids:
        pub, system = ids[0].translate(_LOWER), (ids[1].translate(_LOWER) if len(ids) > 1 else None)
        return (pub.startswith(_QUIRKS_PUBLIC) or pub in ("-/w3c/dtd html 4.0 transitional/en", "html")
                or system == ibm or (system is None and pub.startswith(("-//w3c//dtd html 4.01 frameset//",
                                                                        "-//w3c//dtd html 4.01 transitional//"))))
    if kind == "system" and ids:
        return ids[0].translate(_LOWER) == ibm
    return True


class _HtmlScan(HTMLParser):
    """HTML 을 한 번 훑어 살아 있는 <style> 내용(css) · style 속성(attrs) · 판정 밖 알림(notes)을 모은다.
    열린 요소는 [태그, namespace(html·svg·math), integration point(html·text·None), SVG <style> 글자 조각 | None] 으로
    쌓는다 — foreign content 여닫기 · <template> 안인지 · 표 모드를 가르는 용도. 암묵 닫기(시작 태그: li·dd·dt · p ·
    제목 · button · option · ruby / 끝 태그: generate implied end tags) · 표 모드(close the cell · 빠진 tbody·tr·colgroup ·
    table scope) · form 포인터 · <html>·<head>·<body> 속성 병합은 표준대로 하고, adoption agency·active formatting
    재구성·select 전용 규칙·frameset·shadow root 를 붙일 부모 판별은 하지 않는다."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.css, self.attrs, self.notes, self.seen = [], [], set(), 0    # seen = 만난 <style>·style 속성 수
        self._open = []                         # 열린 요소
        self._templates = []                    # 열린 <template> 마다 선언형 shadow DOM(shadowrootmode)인가
        self._n_ctx = 0                         # 열린 표 요소·template(_TABLE_CTX) 수
        self._quirks = None                     # 첫 토큰이 DOCTYPE 이 아니면 quirks
        self._head_ok = True                    # <head> 가 아직 열릴 수 있는가(그 전의 다른 태그·글자는 head 를 암묵으로 연다)
        self._form = None                       # form 포인터 = template 밖에서 마지막으로 만든 form 요소 — 서면 새 <form> 은 무시
        self._styled_roots = set()              # style 속성이 이미 붙은 <html>·<body>

    def scan(self, text):
        self.feed(text)
        self.close()
        while self._open:
            self._pop()
        return self

    # 표준 파서에선 goahead(분기·줄 번호)만 쓰고 parse_* 는 다시 정의 — 주석 끝·글자 요소·태그 안 문서 끝 처리가 판마다 다름(3.10~3.14 확인)
    def parse_starttag(self, i):
        got = _read_tag(self.rawdata, i + 1)
        if got is None:
            return len(self.rawdata)
        end, tag, attrs, selfclose = got
        attr = dict(reversed(attrs))                          # 같은 이름 속성은 앞의 것
        if self._quirks is None:
            self._quirks = True
        if self._foreign(tag):
            if tag not in _BREAKOUT and not (tag == "font" and {"color", "face", "size"} & attr.keys()):
                self._style_attr(tag, attr)
                self._start_foreign(tag, attr, selfclose)
                return end
            self._close_foreign()
        return self._start_html(tag, attr, selfclose, end)

    def parse_endtag(self, i):
        s, n, k = self.rawdata, len(self.rawdata), i + 2
        if s.startswith(">", k):
            return k + 1                                      # '</>' 는 무시
        if k >= n or s[k] not in string.ascii_letters:
            e = s.find(">", k)                                # bogus comment · 문서 끝의 '</' 는 글자
            return n if e < 0 else e + 1
        got = _read_tag(s, k)
        if got is None:
            return n
        if self._quirks is None:
            self._quirks = True
        self._end(got[1])
        return got[0]

    def parse_comment(self, i, report=True):
        s, k = self.rawdata, i + 4
        if s.startswith(">", k) or s.startswith("->", k):
            return s.index(">", k) + 1                        # '<!-->' · '<!--->' 는 바로 닫힘
        m = _COMMENT_END.search(s, k)
        return m.end() if m else len(s)                       # '-->' · '--!>' · 안 닫히면 문서 끝까지

    def parse_html_declaration(self, i):
        s = self.rawdata
        if s.startswith("<!--", i):
            return self.parse_comment(i)
        if s.startswith("<![CDATA[", i) and self._open and self._open[-1][1] != "html":
            e = s.find("]]>", i + 9)                          # foreign content 의 CDATA 구간 = 글자
            self.handle_data(s[i + 9:] if e < 0 else s[i + 9:e])
            return len(s) if e < 0 else e + 3
        e = s.find(">", i + 2)                                # <!DOCTYPE …> · bogus comment
        if self._quirks is None and s[i + 2:i + 9].translate(_LOWER) == "doctype":
            self._quirks = e < 0 or _quirks_doctype(s[i + 2:e])
        return len(s) if e < 0 else e + 1

    def parse_pi(self, i):
        e = self.rawdata.find(">", i + 2)                     # '<? … >' = bogus comment
        return len(self.rawdata) if e < 0 else e + 1

    def handle_data(self, data):
        o = self._open
        if o and o[-1][3] is not None:
            o[-1][3].append(data)
        if data.strip(_WS):
            self._head_ok = False
            if self._quirks is None:
                self._quirks = True
            if o and o[-1][:2] == ["colgroup", "html"]:
                self._pop()                                   # colgroup 은 공백 아닌 글자를 만나면 닫힌다

    def _foreign(self, tag):
        """이 시작 태그를 foreign content(SVG·MathML) 규칙으로 읽는가 — 현재 요소가 SVG·MathML 요소이고
        integration point 가 아닐 때."""
        if not self._open:
            return False
        name, ns, ip, _css = self._open[-1]
        if ns == "html" or ip == "html":
            return False
        if ip == "text":
            return tag in ("mglyph", "malignmark")
        return not (ns == "math" and name == "annotation-xml" and tag == "svg")

    def _inert_note(self):
        """<template> 안 스타일의 알림 — 열린 template 이 모두 선언형 shadow DOM 이면 브라우저에선 살아 있어 따로 적는다."""
        return _NOTE_SHADOW if all(self._templates) else _NOTE_INERT

    def _style_element(self, attr):
        """<style>(HTML·SVG) → 살아 있으면 CSS 조각 목록(문서 순서 자리를 먼저 잡는다) · 아니면 None."""
        self.seen += 1
        if self._templates:
            self.notes.add(self._inert_note())
            return None
        kind = attr.get("type")
        if kind is not None and kind.translate(_LOWER) not in ("", "text/css"):
            self.notes.add(_NOTE_TYPE)
            return None
        chunks = []
        self.css.append((attr.get("media") or None, chunks))
        return chunks

    def _style_attr(self, tag, attr):
        if "style" not in attr:
            return
        self.seen += 1
        if self._templates:
            self.notes.add(self._inert_note())
        else:
            self.attrs.append(("<%s style> %d행" % (tag, self.getpos()[0]), attr["style"]))

    def _start_foreign(self, tag, attr, selfclose):
        ns = self._open[-1][1]
        chunks = self._style_element(attr) if tag == "style" and ns == "svg" else None
        if selfclose:
            return
        ip = _INTEGRATION.get((ns, tag))
        if ns == "math" and tag == "annotation-xml" and attr.get("encoding", "").translate(_LOWER) in (
                "text/html", "application/xhtml+xml"):
            ip = "html"
        self._push(tag, ns, ip, chunks)

    def _start_root(self, tag, attr, end):
        """<html>·<head>·<body> — 목록에 쌓지 않는다. 다시 오면 기존 요소에 없는 속성만 붙고(style 은 처음 것),
        head 는 다른 태그·글자보다 먼저 올 때만 열린다 · <template> 안에서는 무시."""
        if self._templates or (tag == "head" and not self._head_ok):
            return end
        if tag != "html":
            self._head_ok = False
        if tag not in self._styled_roots and "style" in attr:
            self._styled_roots.add(tag)
            self._style_attr(tag, attr)
        return end

    def _start_html(self, tag, attr, selfclose, end):
        if tag == "html":
            return self._start_root(tag, attr, end)
        if not self._table_start(tag, attr):
            self._head_ok = False
            return end                                        # 표 모드가 버리거나 끝낸 태그(표 밖 표 부품 · 표 안 <form>)
        if tag in ("head", "body"):
            return self._start_root(tag, attr, end)
        self._head_ok = False
        if tag == "frame" or (tag == "form" and self._form and not self._templates):
            return end                                        # frame 은 무시(frameset 은 모형 밖) · form 포인터가 서면 새 <form> 무시
        self._style_attr(tag, attr)
        self._close_implied(tag)
        if tag in ("svg", "math"):
            if not selfclose:
                self._push(tag, tag)
            return end
        if tag == "link" and not self._templates and "stylesheet" in re.split(
                r"[\t\n\f\r ]+", attr.get("rel", "").translate(_LOWER)):
            self.notes.add(_NOTE_LINK)
        if tag in _VOID:
            return end
        if tag not in _RAW_TEXT:
            self._push(tag, shadow=tag == "template" and attr.get("shadowrootmode", "").translate(_LOWER) in (
                "open", "closed"))
            if tag == "form" and not self._templates:
                self._form = self._open[-1]
            return end
        cend, after = _raw_end(self.rawdata, end, tag)       # 글자 요소 — 내용을 태그로 읽지 않고 건너뛴다
        if tag == "style":
            chunks = self._style_element(attr)
            if chunks is not None:
                chunks.append(self.rawdata[end:cend])
        elif tag == "noscript" and _HtmlScan().scan(self.rawdata[end:cend]).seen:
            self.notes.add(_NOTE_INERT)
        return after

    def _close_implied(self, tag):
        """HTML 시작 태그가 암묵으로 닫는 열린 요소를 닫는다 — li → 열린 li · dd·dt → 열린 dd·dt · 블록 → button 범위
        안 p · 제목 → 바로 위 제목 · button → 범위 안 button · option·optgroup → 바로 위 option · 범위 안에 ruby 가
        있으면 rb·rtc → generate implied end tags · rp·rt → 같은 것(rtc 는 남김)."""
        o = self._open
        if tag in ("li", "dd", "dt"):
            names = ("li",) if tag == "li" else ("dd", "dt")
            for k in range(len(o) - 1, -1, -1):
                if o[k][1] == "html" and o[k][0] in names:
                    self._pop_to(k)
                    break
                if self._edge(o[k], _SPECIAL) and not (o[k][1] == "html" and o[k][0] in ("address", "div", "p")):
                    break
        if tag in _CLOSES_P or (tag == "table" and not self._quirks):
            self._pop_to(self._find(("p",), _BUTTON_EDGE))
        if tag in _HEADINGS and o and o[-1][1] == "html" and o[-1][0] in _HEADINGS:
            self._pop()
        if tag == "button":
            self._pop_to(self._find(("button",), _SCOPE_EDGE))
        if tag in ("option", "optgroup") and o and o[-1][:2] == ["option", "html"]:
            self._pop()
        if tag in ("rb", "rp", "rt", "rtc") and self._find(("ruby",), _SCOPE_EDGE) >= 0:
            self._implied_end(("rtc",) if tag in ("rp", "rt") else ())

    def _implied_end(self, keep=()):
        """generate implied end tags — 현재 요소가 _IMPLIED_END(HTML)인 동안 닫는다(keep 에 든 이름은 남긴다)."""
        o = self._open
        while o and o[-1][1] == "html" and o[-1][0] in _IMPLIED_END and o[-1][0] not in keep:
            self._pop()

    def _table_ctx(self):
        """지금 표 모드 = 위에서 가장 가까운 열린 표 요소·template(HTML) → (위치, 이름) · 없으면 (-1, None)(본문)."""
        if self._n_ctx:
            o = self._open
            for k in range(len(o) - 1, -1, -1):
                if o[k][1] == "html" and o[k][0] in _TABLE_CTX:
                    return k, o[k][0]
        return -1, None

    def _find_table(self, names):
        """table scope — 위에서부터 names 중 하나인 열린 HTML 요소의 위치 · HTML table·template 을 먼저 만나거나 없으면 -1
        (SVG·MathML 요소는 경계가 아니다)."""
        o = self._open
        for k in range(len(o) - 1, -1, -1):
            if o[k][1] == "html":
                if o[k][0] in names:
                    return k
                if o[k][0] in ("table", "template"):
                    return -1
        return -1

    def _table_start(self, tag, attr):
        """표 모드의 시작 태그 → 본문 규칙으로 이어 넣으면 True · 버렸거나 여기서 끝났으면 False. 표 부품은 칸·caption·
        행·구역을 표준대로 닫고(close the cell 등) 빠진 tbody·tr·colgroup 을 채운다 · 표·구역·행 바로 안의 <table> 은 열린
        표를 닫고 · <form> 은 만들자마자 닫는다(form 포인터만 남음) · template 바로 안은 본문 규칙으로 근사."""
        while True:
            k, ctx = self._table_ctx()
            if ctx is None:
                return tag not in _TABLE_PARTS                # 표 밖 표 부품은 버림
            if ctx == "template":
                return True
            if ctx == "colgroup":
                if tag in ("col", "template"):
                    return True
                self._pop_to(k)                               # colgroup 은 col·template 밖의 태그를 만나면 닫힌다
                continue
            if ctx in ("td", "th", "caption"):
                if tag not in _TABLE_PARTS:
                    return True                               # 칸·caption 안 = 본문 규칙
                self._pop_to(k)                               # close the cell · caption 닫기 → 다시
                continue
            if tag == "table":
                t = self._find_table(("table",))
                if t < 0:
                    return False
                self._pop_to(t)
                continue
            if tag == "form":
                if not (self._templates or self._form):
                    self._style_attr(tag, attr)
                    self._form = [tag, "html", None, None]    # 열린 요소 목록 밖 form 을 가리킨다
                return False
            if tag not in _TABLE_PARTS:
                return True                                   # 표 안 다른 태그 = 본문 규칙(foster parenting)
            self._pop_to(k + 1)                               # clear the stack back to 표·구역·행
            if ctx == "table":
                if tag in ("tr", "td", "th"):
                    self._push("tbody")
                    continue
                if tag == "col":
                    self._push("colgroup")
                return True
            if tag in ("td", "th"):
                if ctx != "tr":
                    self._push("tr")
                return True
            if tag == "tr" and ctx != "tr":
                return True
            self._pop()                                       # 행·구역을 닫고 다시(caption·col·colgroup·구역·새 tr)

    def _table_end(self, tag):
        """표 모드의 끝 태그 → 여기서 끝났으면 True. 표 요소 끝 태그는 _TABLE_END 의 표 모드에서만 table scope 로 찾아
        닫고(칸 안의 </table>·</tr>·</tbody> 는 close the cell 을 거친 것과 같다) 그 밖에서는 버린다 · colgroup 은 다른
        끝 태그를 만나면 먼저 닫힌다."""
        k, ctx = self._table_ctx()
        if ctx == "colgroup" and tag not in ("colgroup", "col", "template"):
            self._pop_to(k)
            ctx = self._table_ctx()[1]
        if ctx in (None, "template") or tag not in _TABLE_END:
            return False
        if ctx in _TABLE_END[tag]:
            self._pop_to(self._find_table((tag,)))
        return True

    @staticmethod
    def _edge(e, names):
        """열린 요소 e 가 경계인가 — HTML 요소면 이름이 names 에 있을 때 · SVG·MathML 요소면 integration point 일 때."""
        name, ns, ip, _css = e
        return name in names if ns == "html" else (ip is not None or (ns == "math" and name == "annotation-xml"))

    def _find(self, names, edge):
        """위에서부터 names 중 하나인 열린 HTML 요소의 위치 · 경계(edge)를 먼저 만나거나 없으면 -1."""
        o = self._open
        for k in range(len(o) - 1, -1, -1):
            if o[k][1] == "html" and o[k][0] in names:
                return k
            if self._edge(o[k], edge):
                return -1
        return -1

    def _push(self, tag, ns="html", ip=None, css=None, shadow=False):
        """열린 요소를 쌓는다 — shadow = 선언형 shadow DOM 인 <template>."""
        self._open.append([tag, ns, ip, css])
        if ns == "html" and tag in _TABLE_CTX:
            self._n_ctx += 1
            if tag == "template":
                self._templates.append(shadow)

    def _pop(self):
        e = self._open.pop()
        if e[1] == "html" and e[0] in _TABLE_CTX:
            self._n_ctx -= 1
            if e[0] == "template":
                self._templates.pop()
        return e

    def _pop_to(self, k):
        """k 위치 요소까지 닫는다(k < 0 이면 그대로)."""
        while k >= 0 and len(self._open) > k:
            self._pop()

    def _close_foreign(self):
        """integration point·HTML 요소가 나올 때까지 SVG·MathML 요소를 닫는다."""
        while self._open and self._open[-1][1] != "html" and self._open[-1][2] is None:
            self._pop()

    def _end(self, tag):
        o = self._open
        if o and o[-1][1] != "html":                          # foreign content 규칙: 같은 이름까지 거슬러 닫는다
            if tag in ("br", "p"):                            # SVG·MathML 요소를 닫고 HTML 규칙으로 다시
                self._close_foreign()
            else:
                for k in range(len(o) - 1, -1, -1):
                    if o[k][1] == "html":
                        break
                    if o[k][0] == tag:
                        self._pop_to(k)
                        return
        if self._table_end(tag):
            return
        if tag in ("head", "body", "html", "br"):
            self._head_ok = False
        elif tag == "template":
            if self._templates:
                while self._pop()[:2] != ["template", "html"]:
                    pass
        elif tag == "form":
            if self._templates:
                self._pop_to(self._find(("form",), _SCOPE_EDGE))
            elif self._form:
                node, self._form = self._form, None
                for k in range(len(o) - 1, -1, -1):           # 포인터가 가리키는 그 form 이 범위 안에 있을 때만
                    if o[k] is node:
                        self._implied_end()
                        del o[k]                              # 암묵 끝 태그를 닫고 그 form 만 뺀다(그 위 요소는 열린 채)
                        break
                    if self._edge(o[k], _SCOPE_EDGE):
                        break
        elif tag == "p":
            self._pop_to(self._find(("p",), _BUTTON_EDGE))
        elif tag == "li":
            self._pop_to(self._find(("li",), _LIST_EDGE))
        elif tag in _HEADINGS:
            self._pop_to(self._find(_HEADINGS, _SCOPE_EDGE))
        elif tag in _SCOPE_END:
            self._pop_to(self._find((tag,), _SCOPE_EDGE))
        else:
            for k in range(len(o) - 1, -1, -1):
                if o[k][1] == "html" and o[k][0] == tag:
                    self._pop_to(k)
                    return
                if self._edge(o[k], _SPECIAL):
                    return


@functools.lru_cache(maxsize=4)
def _scan_html(text):
    """HTML 한 번 훑기 → (살아 있는 CSS [(media | None, 글자)], style 속성 [(표시 이름, 값)], 알림) — 두 추출기가 함께 쓴다.
    <style> 안 '<!--'·'-->'(CDO·CDC)는 CSS 에서 무시되므로 공백으로 · 머리의 @import 는 외부 스타일시트 알림."""
    p = _HtmlScan().scan(text)
    css = tuple((media, "".join(chunks).replace("<!--", " ").replace("-->", " ")) for media, chunks in p.css)
    if any(_has_import(body) for _media, body in css):
        p.notes.add(_NOTE_LINK)
    return css, tuple(p.attrs), frozenset(p.notes)


def _has_import(css):
    """스타일시트(<style> 하나 · CSS 파일) 머리에 브라우저가 읽는 @import 가 있는가 — 그 앞에 공백·CDO/CDC·블록 없는
    at-rule 문(@charset·@layer·다른 @import·모르는 at-rule · @namespace 는 빼고)만 있을 때. 규칙·블록 at-rule 뒤의
    @import 는 무효(선택자가 틀린 규칙 뒤처럼 브라우저가 읽는 경우도 여기선 무효로 본다)."""
    s = _strip_comments(css)
    i, n = 0, len(s)
    while i < n:
        if s[i] in _WS:
            i += 1
        elif s.startswith("<!--", i) or s.startswith("-->", i):
            i += 4 if s[i] == "<" else 3
        else:
            m = _AT_KEYWORD.match(s, i)
            name = m.group(1).lower() if m else ""
            if not m or name == "namespace":
                return False
            if name == "import" and _IMPORT_TARGET.match(s, m.end()):
                return True
            j = m.end()
            while j < n and s[j] not in ";{}":
                j += 1
            if j >= n or s[j] != ";":
                return False
            i = j + 1
    return False


def extract_inline_styles(text, path):
    """HTML 요소의 style 속성 → [(표시 이름, 선언 문자열)] — 살아 있는 것만(줄 번호 = 시작 태그 줄 · 원문 기준)."""
    if not _is_html(text, path):
        return []
    return list(_scan_html(text)[1])


def _with_notes(msg, notes):
    """입력 오류 문구 + 그때까지 모은 알림 전문 — 오류 경로는 [알림] 블록을 따로 찍지 않으므로 문구에 줄마다 싣는다."""
    return msg + "".join("\n  · " + n for n in sorted(notes))


def extract_css(text, path, notes):
    """HTML 이면 살아 있는 <style> 내용을 문서 순서대로 이어 붙인다(media 속성은 @media 로 감쌈). CSS 면 그대로.
    머리의 @import(외부 스타일시트)는 알림으로. 살아 있는 <style> 이 없으면 입력 오류 — 읽지 않는 곳과 이 페이지의
    알림을 문구에 붙인다."""
    if not _is_html(text, path):
        if _has_import(text):
            notes.add(_NOTE_LINK)
        return text
    css, _attrs, found = _scan_html(text)
    notes.update(found)
    if not css:
        raise InputError(_with_notes(
            "HTML 에 살아 있는 <style> 이 없다: %s — 주석·스크립트 안 스타일, 글자 요소(title·textarea 등)·<template>·"
            "<noscript> 안 스타일, type 이 CSS 가 아닌 <style>, 외부 스타일시트는 읽지 않음%s"
            % (path, " · 이 페이지에서 읽지 않은 것:" if found else ""), found))
    return "\n".join("@media %s{%s}" % (media, body) if media else body for media, body in css)


# ── 선택자·조건 평가 ──

_ATTR = re.compile(
    r"""\[\s*data-theme\s*(?:=\s*(?:"([^"]*)"|'([^']*)'|([^\]\s"']+))\s*(?:[iIsS]\s*)?)?\]""")
_UNKNOWN = "unknown"


def _split_top(s, sep=","):
    parts, depth, start, i = [], 0, 0, 0
    while i < len(s):
        c = s[i]
        if c in "\"'":
            i = _skip_string(s, i)
            continue
        if c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
        elif c == sep and depth == 0:
            parts.append(s[start:i])
            start = i + 1
        i += 1
    parts.append(s[start:])
    return [p.strip() for p in parts]


def compile_root_selector(sel):
    """단일 선택자 → (조건 목록, 명시도) · 루트 대상 아님 = None · 루트인데 판정 불가 조건 = 'unknown'.
    조건 = (값 | None, 긍정 여부): 값 None 은 [data-theme](존재) 검사."""
    s = sel.strip()
    depth = 0
    for c in s:
        if c in "([":
            depth += 1
        elif c in ")]":
            depth -= 1
        elif depth == 0 and (c.isspace() or c in ">+~"):
            return None                      # 자손·형제 선택자 = 루트 대상 아님
    conds, spec, is_root, unknown = [], [0, 0, 0], False, False
    i = 0
    while i < len(s):
        if s.startswith(":root", i) and not re.match(r"[\w-]", s[i + 5:i + 6]):
            is_root = True
            spec[1] += 1
            i += 5
        elif i == 0 and re.match(r"html(?![\w-])", s, re.I):
            is_root = True
            spec[2] += 1
            i += 4
        elif s[i] == "*":
            i += 1
        elif s[i] == "[":
            j = _match_close(s, i + 1, "[", "]")
            m = _ATTR.fullmatch(s[i:j + 1])
            if m:
                val = next((g for g in m.groups() if g is not None), None)
                conds.append((val, True))
                spec[1] += 1
            else:
                unknown = True
            i = j + 1
        elif s.lower().startswith(":not(", i):
            j = _match_close(s, i + 5, "(", ")")
            inner = [x for x in _split_top(s[i + 5:j]) if x]
            ms = [_ATTR.fullmatch(x) for x in inner]
            if inner and all(ms):
                for m in ms:
                    conds.append((next((g for g in m.groups() if g is not None), None), False))
                spec[1] += 1
            else:
                unknown = True
            i = j + 1
        else:
            m = re.match(r"[.#:]{1,2}[\w-]+(?:\([^)]*\))?|[\w-]+", s[i:])
            unknown = True
            i += m.end() if m else 1
    if not is_root:
        return None
    if unknown:
        return _UNKNOWN
    return conds, tuple(spec)


def _cond_ok(conds, theme):
    for val, positive in conds:
        hit = (theme is not None) if val is None else (theme == val)
        if hit != positive:
            return False
    return True


def _media_alt(alt, os_scheme):
    alt = alt.strip().lower()
    neg = False
    if alt.startswith("not "):
        neg, alt = True, alt[4:].strip()
    elif alt.startswith("only "):
        alt = alt[5:].strip()
    result = True
    for term in re.split(r"\s+and\s+", alt):
        term = term.strip()
        if term in ("all", "screen", ""):
            continue
        if term == "print":
            result = False
            continue
        m = re.fullmatch(r"\(\s*prefers-color-scheme\s*:\s*(light|dark)\s*\)", term)
        if m:
            result = result and (m.group(1) == os_scheme)
            continue
        if re.fullmatch(r"\(\s*prefers-color-scheme\s*\)", term):
            continue
        return None                          # 폭·방향 등 판정할 수 없는 조건
    return (not result) if neg else result


def _supports_ok(cond):
    """@supports 조건 → True / False / None(판정할 수 없음). 판정하는 조건 = (color: 색) — 도구가 읽는 색 표기면 참.
    not·and·or 는 세 값 논리로 푼다(and 와 or 를 괄호 없이 섞으면 CSS 문법 오류라 None)."""
    s = cond.strip()
    m = re.match(r"not(?=[\s(])", s, re.I)
    if m:
        r = _supports_ok(s[m.end():])
        return None if r is None else not r
    parts, ops, depth, start, i = [], [], 0, 0, 0
    while i < len(s):
        c = s[i]
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
        elif depth == 0:
            op = re.match(r"\s+(and|or)\s+", s[i:], re.I)
            if op:
                parts.append(s[start:i])
                ops.append(op.group(1).lower())
                i += op.end()
                start = i
                continue
        i += 1
    parts.append(s[start:])
    if len(parts) > 1:
        if len(set(ops)) > 1:
            return None
        rs = [_supports_ok(p) for p in parts]
        if ops[0] == "and":
            return False if False in rs else (None if None in rs else True)
        return True if True in rs else (None if None in rs else False)
    if not (s.startswith("(") and _match_close(s, 1, "(", ")") == len(s) - 1):
        return None                          # selector()·font-tech() 등 함수 조건
    inner = s[1:-1].strip()
    feature = re.fullmatch(r"color\s*:\s*(.+)", inner, re.I | re.S)
    if feature:
        try:
            parse_color(feature.group(1))
        except ColorError:
            return None
        return True
    if inner.startswith("(") or re.match(r"not(?=[\s(])", inner, re.I):
        return _supports_ok(inner)
    return None                              # display·그 밖 속성 조건


def _ctx_ok(ctx, os_scheme):
    """at-rule 머리말들 → True(적용) / False(미적용) / None(판정 불가)."""
    verdict = True
    for pre in ctx:
        low = pre.lower()
        if low.startswith("@media"):
            alts = _split_top(pre[6:])
            rs = [_media_alt(a, os_scheme) for a in alts]
            r = True if any(x is True for x in rs) else (None if any(x is None for x in rs) else False)
        elif low.startswith("@supports"):
            r = _supports_ok(pre[9:])
        elif low.startswith("@layer"):
            r = True                         # 층은 늘 적용 — 층 순서 근사는 Sheet 가 알림으로 적는다
        else:
            r = None
        if r is False:
            return False
        if r is None:
            verdict = None
    return verdict


# ═══════════════════════════ 모드별 토큰 ═══════════════════════════

class Sheet:
    """파싱된 규칙 → 상태별 루트 사용자 정의 속성 맵."""

    def __init__(self, rules, notes):
        self.rules = rules
        self.notes = notes
        self.compiled = []                   # [(rule, [(조건 목록, 명시도), …])] — 루트 선택자가 있는 규칙만
        outside = 0
        for r in rules:
            if not r.decls:
                continue
            sels = [compile_root_selector(x) for x in _split_top(r.selector)]
            roots = [x for x in sels if x not in (None, _UNKNOWN)]
            if not roots:
                if any(x == _UNKNOWN for x in sels):
                    notes.add("판정할 수 없는 루트 선택자 %r 의 정의 %d개는 판정 밖" % (r.selector, len(r.decls)))
                else:
                    outside += len(r.decls)
                continue
            if any(x == _UNKNOWN for x in sels):
                notes.add("선택자 목록 %r 중 판정할 수 없는 항목은 무시" % r.selector)
            self.compiled.append((r, roots))
            if any(p.lower().startswith("@layer") for p in r.ctx):
                notes.add("@layer 안 정의는 층 규칙 대신 나중 선언 우선으로 판정 — 브라우저는 층 밖 정의를 층 안 정의보다, "
                          "뒤에 선언된 층을 앞 층보다 앞세워 이 순서가 선언 순서와 다르면 값이 틀릴 수 있음(사람 확인)")
        if outside:
            notes.add("루트(:root·html)로 보지 않은 선택자의 사용자 정의 속성 %d개는 판정 밖" % outside)

    def props(self, state):
        os_scheme, theme = state
        best = {}
        for r, roots in self.compiled:
            ok = _ctx_ok(r.ctx, os_scheme)
            if ok is None:
                self.notes.add("판정할 수 없는 조건 %s 안 정의는 판정 밖" % " ".join(r.ctx))
                continue
            if not ok:
                continue
            specs = [spec for conds, spec in roots if _cond_ok(conds, theme)]
            if not specs:
                continue
            spec = max(specs)
            for name, value, imp in r.decls:
                key = (imp, spec, r.order)
                if name not in best or key >= best[name][0]:
                    best[name] = (key, value)
        return {k: v for k, (_key, v) in best.items()}

    def _rules_where(self, pred):
        return [r for r, roots in self.compiled if pred(r, roots)]

    def has_media_dark(self):
        def pred(r, roots):
            return (_ctx_ok(r.ctx, "dark") is True and _ctx_ok(r.ctx, "light") is False
                    and any(_cond_ok(c, None) for c, _s in roots))
        return bool(self._rules_where(pred))

    def has_forced(self, value):
        def pred(r, roots):
            return (_ctx_ok(r.ctx, "light") is True
                    and any(_cond_ok(c, value) and not _cond_ok(c, None) for c, _s in roots))
        return bool(self._rules_where(pred))

    def has_theme_attr(self):
        return any(c for _r, roots in self.compiled for c, _s in roots)


class Resolver:
    """한 상태의 토큰 맵에서 var() 를 풀어 색으로. 연쇄(chain) = 거친 토큰 이름들."""

    def __init__(self, props):
        self.props = props

    def expand(self, name, stack=()):
        if name in stack:
            raise ColorError("var() 순환: " + " → ".join("--" + x for x in stack + (name,)))
        if name not in self.props:
            raise ColorError("미정의 토큰 --%s" % name)
        text, chain = self._subst(self.props[name], stack + (name,))
        return text, [name] + chain

    def _subst(self, value, stack):
        out, chain, i = [], [], 0
        while True:
            m = re.compile(r"(?<![\w-])var\(", re.I).search(value, i)
            if not m:
                out.append(value[i:])
                break
            out.append(value[i:m.start()])
            j = _match_close(value, m.end(), "(", ")")
            ref, comma, fallback = value[m.end():j].partition(",")
            ref = ref.strip()
            if not ref.startswith("--"):
                raise ColorError("var() 인자 오류: %r" % value)
            name = ref[2:]
            if name in stack:
                raise ColorError("var() 순환: " + " → ".join("--" + x for x in stack + (name,)))
            if name in self.props:
                t, c = self.expand(name, stack)
                out.append(t)
                chain += c
            elif comma:
                t, c = self._subst(fallback.strip(), stack)
                out.append(t)
                chain += c
            else:
                raise ColorError("미정의 토큰 --%s(대체값 없음)" % name)
            i = j + 1
        return "".join(out).strip(), chain

    def color(self, spec):
        spec = spec.strip()
        if looks_literal(spec):
            return parse_color(spec), []
        if spec.lower().startswith("var("):
            text, chain = self._subst(spec, ())
            return parse_color(text), chain
        name = spec[2:] if spec.startswith("--") else spec
        text, chain = self.expand(name)
        c = parse_color(text)
        return c, chain

    def cycles(self):
        # 같은 순환을 다른 시작점에서 다시 세지 않도록 참여 토큰 집합으로 묶는다.
        found = {}
        for name in sorted(self.props):
            try:
                self.expand(name)
            except ColorError as e:
                msg = str(e)
                if "순환" in msg:
                    members = frozenset(re.findall(r"--([\w-]+)", msg.split(":", 1)[1]))
                    found.setdefault(members, msg)
        return list(found.values())


# ═══════════════════════════ PNG 디코드 ═══════════════════════════

_PNG_SIG = b"\x89PNG\r\n\x1a\n"
_CT_NAME = {0: "grayscale", 2: "RGB", 3: "palette", 4: "gray+alpha", 6: "RGBA"}
_SWAR = {}


def _add_bytes(x, y):
    # 바이트별 (x + y) mod 256 — 큰 정수 하나로 한 줄을 통째 더한다(Up 필터).
    n = len(x)
    if n not in _SWAR:
        _SWAR[n] = (int.from_bytes(b"\x7f" * n, "big"), int.from_bytes(b"\x80" * n, "big"))
    m7, m8 = _SWAR[n]
    a, b = int.from_bytes(x, "big"), int.from_bytes(y, "big")
    return (((a & m7) + (b & m7)) ^ ((a ^ b) & m8)).to_bytes(n, "big")


def _unfilter(ftype, line, prev, bpp, channels):
    # PNG 필터 역연산. 채널은 서로 독립이라 알파 채널(channels < bpp)은 복원하지 않는다.
    if ftype == 0:
        return line
    if ftype == 2:
        return _add_bytes(line, prev)
    out = bytearray(line)
    for c in range(channels):
        seg = line[c::bpp]
        if ftype == 1:                       # Sub: 채널별 누적합 mod 256
            out[c::bpp] = bytes(v & 255 for v in accumulate(seg))
            continue
        up = prev[c::bpp]
        res = bytearray(len(seg))
        a = cc = 0
        if ftype == 3:                       # Average: x + floor((왼 + 위) / 2)
            for k, (x, b) in enumerate(zip(seg, up)):
                a = (x + ((a + b) >> 1)) & 255
                res[k] = a
        elif ftype == 4:                     # Paeth: p = 왼 + 위 − 왼위, 가장 가까운 값
            for k, (x, b) in enumerate(zip(seg, up)):
                pa = b - cc if b >= cc else cc - b
                pb = a - cc if a >= cc else cc - a
                t = a + b - cc - cc
                pc = t if t >= 0 else -t
                if pa <= pb and pa <= pc:
                    pr = a
                elif pb <= pc:
                    pr = b
                else:
                    pr = cc
                a = (x + pr) & 255
                cc = b
                res[k] = a
        else:
            raise InputError("PNG 필터 유형 %d — 손상된 파일" % ftype)
        out[c::bpp] = res
    return bytes(out)


def read_png_counts(path):
    """PNG → (폭, 높이, Counter{(r,g,b): 픽셀 수}). 8-bit RGB/RGBA · 비인터레이스만."""
    try:
        data = open(path, "rb").read()
    except OSError as e:
        raise InputError("PNG 읽기 실패: %s (%s)" % (path, e))
    if data[:8] != _PNG_SIG:
        raise InputError("PNG 서명이 아니다: %s" % path)
    pos, ihdr, idat = 8, None, []
    while pos + 8 <= len(data):
        length = int.from_bytes(data[pos:pos + 4], "big")
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if ctype == b"IHDR":
            ihdr = struct.unpack(">IIBBBBB", chunk[:13])
        elif ctype == b"IDAT":
            idat.append(chunk)
        elif ctype == b"IEND":
            break
    if ihdr is None:
        raise InputError("IHDR 없음: %s" % path)
    w, h, depth, ctype_, comp, filt, inter = ihdr
    if depth != 8 or ctype_ not in (2, 6) or inter != 0 or comp != 0 or filt != 0:
        raise InputError(
            "미지원 PNG 형식: %s — 비트 깊이 %d · 색 유형 %d(%s) · 인터레이스 %d "
            "(지원 = 8-bit RGB(2)/RGBA(6) · 비인터레이스)"
            % (path, depth, ctype_, _CT_NAME.get(ctype_, "?"), inter))
    try:
        raw = zlib.decompress(b"".join(idat))
    except zlib.error as e:
        raise InputError("IDAT 압축 해제 실패: %s (%s)" % (path, e))
    bpp = 3 if ctype_ == 2 else 4
    stride = w * bpp
    if len(raw) < h * (stride + 1):
        raise InputError("IDAT 길이 부족 — 손상된 파일: %s" % path)
    counts = Counter()
    prev = bytes(stride)
    off = 0
    for _y in range(h):
        row = _unfilter(raw[off], raw[off + 1:off + 1 + stride], prev, bpp, 3)
        off += stride + 1
        counts.update(zip(row[0::bpp], row[1::bpp], row[2::bpp]))
        prev = row
    return w, h, counts


def area_ratio(counts, chroma_threshold):
    """(전체 픽셀, 유채 픽셀, 유채색별 픽셀 [(rgb, 수)…]) — 유채 = OKLCH C > 임계."""
    total = chromatic = 0
    hot = []
    for rgb, k in counts.items():
        total += k
        if srgb8_to_oklch(rgb)[1] > chroma_threshold:
            chromatic += k
            hot.append((rgb, k))
    hot.sort(key=lambda x: -x[1])
    return total, chromatic, hot


def rare_share(total, chromatic, hot, rare=5e-5):
    """유채 픽셀 중 '드문 색'(각각 전체의 0.005% 미만)에서 온 비율. 글자 서브픽셀 AA 번짐은
    수천 가지 드문 색으로 흩어져 이 값이 커진다(면 칠한 강조색은 몇 가지 색에 몰린다)."""
    if not chromatic:
        return 0.0
    return sum(k for _rgb, k in hot if k < rare * total) / chromatic


# ═══════════════════════════ 출력 도우미 ═══════════════════════════

def _dw(s):
    return sum(2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1 for ch in s)


def _table(headers, rows, right=()):
    cols = list(zip(headers, *rows)) if rows else [(h,) for h in headers]
    widths = [max(_dw(str(x)) for x in col) for col in cols]

    def fmt(r):
        cells = []
        for i, x in enumerate(r):
            x = str(x)
            gap = " " * (widths[i] - _dw(x))
            cells.append(gap + x if i in right else x + gap)
        return ("  " + "  ".join(cells)).rstrip()

    return [fmt(headers)] + [fmt(r) for r in rows]


def _ratio_str(r, mn):
    s = "%.2f" % r
    if (r < mn) != (float(s) < mn):          # 반올림이 판정을 뒤집어 보이면 한 자리 더
        s = "%.3f" % r
    return s


def _hex(rgb):
    return "#%02X%02X%02X" % rgb


# ═══════════════════════════ 게이트 본체 ═══════════════════════════

@dataclass
class Pair:
    name: str
    fg: str
    bg: str
    min: float
    origin: str = ""


AXES = ("대비", "채도", "유채 면적", "사용처")
JUDGED, UNJUDGED, UNRUN = "판정", "판정 안 됨", "미실행"


@dataclass
class Report:
    fails: int = 0
    warns: list = field(default_factory=list)       # 경고 — 판정에는 넣지 않으나 전달 전 해소 대상
    notes: list = field(default_factory=list)       # 알림 — 판정 밖(도구가 읽지 않는 것)·근사(어림한 판정) · 사람 확인
    lines: list = field(default_factory=list)
    axes: dict = field(default_factory=dict)        # 축 → (JUDGED | UNJUDGED | UNRUN, 이유)

    def out(self, s=""):
        self.lines.append(s)

    def axis(self, name, state, why=""):
        self.axes[name] = (state, why)

    def axis_names(self, state):
        return [a for a in AXES if self.axes.get(a, (None,))[0] == state]


def parse_pair_arg(s):
    parts = s.rsplit(":", 3)
    if len(parts) != 4 or not all(p.strip() for p in parts):
        raise InputError("--pair 형식 = 이름:전경:배경:최소비 (받은 값: %r)" % s)
    try:
        mn = float(parts[3])
    except ValueError:
        raise InputError("--pair 최소비가 수가 아니다: %r" % s)
    return Pair(parts[0].strip(), parts[1].strip(), parts[2].strip(), mn, "--pair")


def _not_utf8(kind, path, err):
    """UTF-8 로 풀리지 않는 입력의 오류 문구 — 어디서 깨졌는지와 고치는 법."""
    return ("%s이 UTF-8 이 아니다: %s (바이트 위치 %d · 0x%02X) — UTF-8 로 저장해 다시 돌린다(한국어 Windows 의 ANSI = cp949 "
            "저장이 흔한 원인)" % (kind, path, err.start, err.object[err.start]))


def load_pairs_file(path):
    try:
        with open(path, encoding="utf-8-sig") as f:
            data = json.load(f)
    except OSError as e:
        raise InputError("쌍 파일 읽기 실패: %s (%s)" % (path, e))
    except UnicodeDecodeError as e:
        raise InputError(_not_utf8("쌍 파일", path, e))
    except ValueError as e:
        raise InputError("쌍 파일 JSON 오류: %s (%s)" % (path, e))
    if not isinstance(data, dict) or not isinstance(data.get("pairs"), list):
        raise InputError("쌍 파일에 pairs 배열이 없다: %s" % path)
    pairs = []
    for k, p in enumerate(data["pairs"]):
        try:
            pairs.append(Pair(str(p["name"]), str(p["fg"]), str(p["bg"]), float(p["min"]),
                              os.path.basename(path)))
        except (KeyError, TypeError, ValueError):
            raise InputError("쌍 파일 %s 의 pairs[%d] 에 name·fg·bg·min 이 모두 있어야 한다" % (path, k))
    chroma = [str(x) for x in data.get("chroma_tokens", [])]
    forbid = data.get("forbid_refs")
    if forbid is not None:
        if not (isinstance(forbid, dict) and isinstance(forbid.get("tokens"), list)
                and isinstance(forbid.get("in"), list)):
            raise InputError("쌍 파일 %s 의 forbid_refs 는 {tokens: [...], in: [...]} 형식" % path)
        forbid = ([str(x) for x in forbid["tokens"]], [str(x) for x in forbid["in"]])
    return pairs, chroma, forbid


def _strip_dashes(name):
    return name[2:] if name.startswith("--") else name


def _token_list(s):
    # "a,b" → ["a", "b"] · 빈 값·None → None(기본값 사용)
    return [x.strip() for x in s.split(",") if x.strip()] if s else None


# ── 축 4: 사용처 — 토큰 정의(--이름: 값)가 아닌 선언이 무엇을 가리키는가 ──

DEFAULT_DECOR = ("n-5", "n-6")                      # web_page.md §1 장식 단계
TEXT_PROPS = ("color", "fill", "stroke")            # 글자·아이콘 색
BG_PROPS = ("background", "background-color", "background-image")
_BORDER_PROP = re.compile(
    r"(?:border(?:-(?:top|right|bottom|left|block|inline|block-start|block-end|inline-start|inline-end))?"
    r"|outline)(?:-(?:color|style|width))?")
_NO_BORDER = {"none", "hidden", "0", "0px", "transparent", "initial", "unset", "revert"}
_VAR_OPEN = re.compile(r"(?<![\w-])var\(", re.I)
HUMAN_ONLY = ("판정 밖(사람 몫): 테두리의 장식 단계(장식 구분선인지 정보 경계인지 — web_page.md §6-2) · "
              "다른 규칙에서 받는 테두리 · 리터럴 색 · 루트 토큰을 규칙 범위에서 다시 정의한 값(루트 정의를 따라감) · "
              "중첩 규칙(CSS nesting) 안 선언 · <noscript>·<template> 안 스타일(선언형 shadow DOM 안은 브라우저에서 "
              "살아 있음)")


def _var_refs(value):
    """값 안 var() 들 → [(이름, 대체값 | None)]. 대체값 안 var() 는 그 대체값을 따라갈 때 푼다."""
    out, i = [], 0
    while True:
        m = _VAR_OPEN.search(value, i)
        if not m:
            return out
        j = _match_close(value, m.end(), "(", ")")
        ref, comma, fallback = value[m.end():j].partition(",")
        ref = ref.strip()
        if ref.startswith("--"):
            out.append((ref[2:], fallback.strip() if comma else None))
        i = j + 1


def _usage_chains(value, lookup, stack=()):
    """value 가 var() 로 거치는 토큰 연쇄들. lookup(이름) = 그 자리에서 보이는 정의 값 목록(없으면 [])."""
    chains = []
    for name, fallback in _var_refs(value):
        if name in stack:
            continue                                     # 순환 — 대비 축이 FAIL 로 보고
        defs = lookup(name)
        if defs:
            for d in defs:
                subs = _usage_chains(d, lookup, stack + (name,))
                chains += [[name] + s for s in subs] if subs else [[name]]
        elif fallback is not None:
            chains += _usage_chains(fallback, lookup, stack)
    return chains


def _border_decl(plain):
    """같은 선언 묶음 안의 보이는 테두리(border·outline) 선언 — 없으면 None."""
    for prop, value, _imp in plain:
        if _BORDER_PROP.fullmatch(prop):
            toks = set(value.lower().replace(",", " ").split())
            if not toks & _NO_BORDER:
                return "%s: %s" % (prop, value)
    return None


def _short(s, n=40):
    s = " ".join(s.split())
    return s if len(s) <= n else s[:n - 1] + "…"


def judge_usage(units, scoped, modes, resolvers, opts, rep):
    """units = [(종류 "rule"|"attr", 표시 이름, at-rule 머리말, 같은 묶음 사용자 정의 속성 {이름: 값}, 일반 선언)]
    · scoped = 루트 밖 규칙의 사용자 정의 속성 {이름: [값…]}(루트에 없는 이름만 여기서 찾는다).
    글자·아이콘 색이 장식 단계를 가리키면 FAIL · 틴트 배경인데 같은 묶음에 테두리가 없으면 경고."""
    decor = {_strip_dashes(x) for x in (opts.decor_tokens or DEFAULT_DECOR)}
    known = set(scoped)
    for res in resolvers.values():
        known |= set(res.props)
    if opts.tint_tokens is not None:
        tints = {_strip_dashes(x) for x in opts.tint_tokens}
    else:
        def ramp_backed(t):
            # 모든 모드에서 중성 램프(n-*)를 가리키는 -bg 토큰(예 --card-bg: var(--n-2))은 틴트가 아님
            chains = []
            for res in resolvers.values():
                def lk(name, root=res.props):
                    return [root[name]] if name in root else scoped.get(name, [])
                chains += _usage_chains("var(--%s)" % t, lk)
            return bool(chains) and all(set(c[1:]) & set(RAMP) for c in chains)
        tints = {t for t in known if t.endswith("-bg") and not ramp_backed(t)}   # --accent-bg · 상태 --ok-bg 등

    text_rows, tint_rows = [], []
    n_decl = n_text = 0
    for _kind, label, ctx, local, plain in units:
        n_decl += len(plain)
        for prop, value, _imp in plain:
            is_text, is_bg = prop in TEXT_PROPS, prop in BG_PROPS
            if not (is_text or is_bg):
                continue
            n_text += is_text
            hit_modes, hit_chains, tint_hit = [], [], False
            for mlabel, st in modes:
                if _ctx_ok(ctx, st[0]) is False:
                    continue
                root = resolvers[mlabel].props

                def lookup(name, root=root):
                    if name in local:
                        return [local[name]]
                    if name in root:
                        return [root[name]]
                    return scoped.get(name, [])

                chains = _usage_chains(value, lookup)
                if is_text:
                    hits = [c for c in chains if decor & set(c)]
                    if hits:
                        hit_modes.append(mlabel)
                        for c in hits:
                            s = " → ".join("--" + x for x in c)
                            if s not in hit_chains:
                                hit_chains.append(s)
                elif any(tints & set(c) for c in chains):
                    tint_hit = True
            if hit_modes:
                rep.fails += 1
                text_rows.append((_short(label, 48), prop, _short(value), "·".join(hit_modes),
                                  " | ".join(hit_chains), "FAIL"))
            if tint_hit:
                border = _border_decl(plain)
                tint_rows.append((_short(label, 48), prop, _short(value),
                                  _short(border) if border else "없음", "PASS" if border else "경고"))
                if not border:
                    rep.warns.append("틴트 배경에 같은 규칙 테두리 없음: %s { %s: %s } — 틴트만으론 경계 3:1 미달 · "
                                     "다른 규칙에서 테두리를 받으면 무시" % (_short(label, 48), prop, _short(value)))

    n_rules = sum(1 for u in units if u[0] == "rule")
    n_attr = len(units) - n_rules
    rep.out("")
    rep.out("[사용처 — 토큰 정의 밖 선언 %d개 · 규칙 %d개%s]"
            % (n_decl, n_rules, " · style 속성 %d개" % n_attr if n_attr else ""))
    shown = ", ".join("--" + x for x in sorted(decor))
    if not decor & known:
        rep.out("  글자·아이콘 색 — 장식 단계 토큰(%s) 정의 없음 → 해당 없음" % shown)
    else:
        rep.out("  글자·아이콘 색(color·fill·stroke) %d개 — 장식 단계(%s)를 가리키면 FAIL(글자·아이콘 금지)"
                % (n_text, shown))
        if text_rows:
            rep.lines += ["  " + ln for ln in _table(("선택자", "속성", "값", "모드", "연쇄", "판정"), text_rows)]
        else:
            rep.out("    적중 0 → PASS")
    if not tints:
        rep.out("  틴트 배경 — 틴트 토큰(-bg) 없음 → 해당 없음")
    else:
        rep.out("  틴트 배경(%s) %d개 — 같은 규칙에 테두리(border·outline)가 없으면 경고(FAIL 아님)"
                % (", ".join("--" + x for x in sorted(tints)), len(tint_rows)))
        if tint_rows:
            rep.lines += ["  " + ln for ln in _table(("선택자", "속성", "값", "같은 규칙 테두리", "판정"), tint_rows)]
    rep.out("  " + HUMAN_ONLY)


def judge_file(path, css_text, opts, rep):
    notes = set()
    rules = parse_css(extract_css(css_text, path, notes), notes)
    sheet = Sheet(rules, notes)
    light = sheet.props(STATE_LIGHT)
    if not light and not sheet.has_media_dark() and not sheet.has_forced("dark"):
        raise InputError(_with_notes(
            "판정할 수 있는 루트 사용자 정의 속성이 없다: %s — 판정하는 정의 = 라이트는 화면에 적용되는 :root·html(data-theme "
            "속성 없음) · 다크는 @media (prefers-color-scheme: dark) 안 루트와 :root[data-theme=\"dark\"]%s"
            % (path, " · 이 입력의 알림(판정 밖·근사 — 토큰이 판정 밖 쪽에만 있을 수 있음):" if notes else ""), notes))

    # ── 모드 결정 ──
    modes = [("라이트", STATE_LIGHT)]
    media_dark, forced_dark = sheet.has_media_dark(), sheet.has_forced("dark")
    mode_note = []
    if media_dark and forced_dark:
        pd, pf = sheet.props(STATE_DARK), sheet.props(STATE_FORCED_DARK)
        diff = sorted(k for k in set(pd) | set(pf) if pd.get(k) != pf.get(k))
        if diff:
            rep.warns.append("OS 다크와 강제 다크의 값이 다르다(%d개): %s — 두 다크 블록 값이 다르거나, 다크 블록이 정하지 "
                             "않은 토큰이 두 상태에서 다른 값(라이트 쪽 정의)으로 남음 · 둘 다 판정"
                             % (len(diff), ", ".join("--" + d for d in diff[:12])))
            modes += [("다크(OS)", STATE_DARK), ("다크(강제)", STATE_FORCED_DARK)]
            mode_note.append("다크 = OS 다크 미디어 블록 · 강제 다크 블록(값 다름 → 둘 다 판정)")
        else:
            modes.append(("다크", STATE_DARK))
            mode_note.append("다크 = OS 다크 미디어 블록 = 강제 다크 블록(같은 값)")
    elif media_dark:
        modes.append(("다크(OS)", STATE_DARK))
        mode_note.append("다크 = OS 다크 미디어 블록(강제 다크 블록 없음 — OS 추종만)")
    elif forced_dark:
        modes.append(("다크(강제)", STATE_FORCED_DARK))
        mode_note.append("다크 = 강제 다크 블록(OS 다크 미디어 블록 없음)")
    if sheet.has_theme_attr() and media_dark:
        pl, pfl = sheet.props(STATE_LIGHT), sheet.props(STATE_FORCED_LIGHT_ON_DARK)
        diff = sorted(k for k in set(pl) | set(pfl) if pl.get(k) != pfl.get(k))
        if diff:
            rep.warns.append("강제 라이트(OS 다크 + data-theme=\"light\")가 라이트와 다르다(%d개): %s — OS 다크 블록 "
                             "선택자에 :not([data-theme=\"light\"]) 가 없거나, 라이트 토큰이 @media (prefers-color-scheme: "
                             "light) 안에만 있어 강제 라이트에 닿지 않음"
                             % (len(diff), ", ".join("--" + d for d in diff[:12])))

    mode_props = {label: sheet.props(st) for label, st in modes}
    resolvers = {label: Resolver(props) for label, props in mode_props.items()}

    # ── 쌍 모으기 ──
    pairs = []
    standard = any("n-0" in props and "n-10" in props for props in mode_props.values())
    if standard and not opts.no_default_pairs:
        pairs += [Pair(n, f, b, m, "기준 11쌍") for n, f, b, m in STANDARD_PAIRS]
    pairs += opts.extra_pairs

    rep.out("=== 색 토큰 게이트 — %s ===" % path)
    rep.out("모드: " + " · ".join(label for label, _st in modes)
            + ("" if not mode_note else "  (" + "; ".join(mode_note) + ")"))
    if standard and not opts.no_default_pairs:
        rep.out("기본 쌍: 표준 토큰 이름(n-0…n-10) 감지 → 기준 게이트 11쌍(web_page.md §5)")
    elif standard:
        rep.out("기본 쌍: 끔(--no-default-pairs)")
    else:
        rep.out("기본 쌍: 표준 토큰 이름(n-0·n-10)을 정의한 모드 없음 → 적용 안 함")
    for src, cnt in Counter(p.origin for p in opts.extra_pairs).items():
        rep.out("추가 쌍: %s %d쌍" % (src, cnt))

    if not light:
        rep.fails += 1
        rep.out("[FAIL] 판정할 수 있는 라이트 정의 없음 — 화면에 적용되는 :root·html(data-theme 속성 없음) 블록이 필요"
                "(다크·속성 조건 블록이나 판정 밖 선택자만으로는 라이트가 판정되지 않는다)")
    if len(modes) == 1:
        rep.fails += 1
        rep.out("[FAIL] 다크 모드 정의 없음 — 다크 블록을 만든다: @media (prefers-color-scheme: dark) 블록과 "
                ":root[data-theme=\"dark\"] 블록(같은 값 한 벌 · web_page.md §5 · 웹 페이지·Artifact·도식은 다크 전환 필수)")

    # ── 순환 참조 ──
    cyc = sorted({c for r in resolvers.values() for c in r.cycles()})
    for c in cyc:
        rep.fails += 1
        rep.out("[FAIL] " + c)

    clip_seen = set()

    def note_clip(label, name, col):
        if col.clipped and (label, name) not in clip_seen:
            clip_seen.add((label, name))
            rep.warns.append("gamut 밖 → clip: %s %s = %s → %s" % (label, name, col.text, col.hex))

    # ── 축 1: 대비 ──
    # 페이지가 정의도 참조도 하지 않는 토큰을 가리키는 쌍 = 판정 밖(쓰지 않는 상태색 등) · 참조만 하고 정의가 없으면 FAIL 유지
    # 참조 = 주석을 뺀 살아 있는 CSS(<style> 내용 · nesting·at-rule 안 포함) + HTML style 속성 안 var() — 본문 글자·
    # <code>·<script>·HTML 주석 속 글자는 참조 아님 · CSS 문자열 값 안 var() 글자는 참조로 센다(거짓 FAIL 쪽으로만 보수적)
    defined_any = set()
    for _label, st in modes:
        defined_any |= set(sheet.props(st))
    ref_sources = [_strip_comments(extract_css(css_text, path, set()))]
    ref_sources += [body for _label, body in extract_inline_styles(css_text, path)]
    referenced = set()
    for src in ref_sources:
        referenced.update(re.findall(r"var\(\s*--([A-Za-z0-9_-]+)", src))

    def idle_tokens(p):
        out = []
        for side in (p.fg, p.bg):
            if looks_literal(side):
                continue
            tok = _strip_dashes(side)
            if tok in defined_any:
                continue
            if tok in referenced:
                return []                   # 참조하는데 정의 없음 → 판정해서 FAIL
            if tok not in out:
                out.append(tok)
        return out

    idle_pairs = 0
    judged_pairs = [p for p in pairs if not idle_tokens(p)]
    if not pairs:
        rep.out("")
        rep.out("[대비] 판정할 쌍 없음(기본 쌍 %s · --pair/--pairs 없음)"
                % ("끔" if standard else "해당 없음"))
        rep.axis("대비", UNJUDGED, "판정할 쌍 없음")
    elif not judged_pairs:
        rep.axis("대비", UNJUDGED, "넘긴 쌍 전부 판정 밖")
    else:
        rep.axis("대비", JUDGED)
    for label, _st in modes:
        res = resolvers[label]
        rows = []
        for p in pairs:
            idle = idle_tokens(p)
            if idle:
                idle_pairs += 1
                rows.append((p.name, p.fg, p.bg, "-", "%g" % p.min, "판정 밖",
                             "페이지가 %s 를 정의·참조하지 않음" % ", ".join("--" + x for x in idle)))
                continue
            verdict, ratio_s, fg_s, bg_s, extra = "FAIL", "-", p.fg, p.bg, ""
            try:
                fgc, _fch = res.color(p.fg)
                bgc, _bch = res.color(p.bg)
                note_clip(label, p.fg, fgc)
                note_clip(label, p.bg, bgc)
                fg_s = "%s %s" % (p.fg, fgc.hex) if not looks_literal(p.fg) else fgc.hex
                bg_s = "%s %s" % (p.bg, bgc.hex) if not looks_literal(p.bg) else bgc.hex
                if bgc.alpha < 1:
                    extra = "배경 반투명 — 판정 불가"
                else:
                    if fgc.alpha < 1:
                        fgc = composite(fgc, bgc)
                        extra = "전경 알파 합성 → %s" % fgc.hex
                    r = contrast(fgc.rgb, bgc.rgb)
                    ratio_s = _ratio_str(r, p.min)
                    verdict = "PASS" if r >= p.min else "FAIL"
            except ColorError as e:
                extra = "판정 불가: %s" % e
            if verdict == "FAIL":
                rep.fails += 1
            rows.append((p.name, fg_s, bg_s, ratio_s, "%g" % p.min, verdict, extra))
        if pairs:
            rep.out("")
            rep.out("[대비 — %s]" % label)
            rep.lines += _table(("쌍", "전경", "배경", "비", "최소", "판정", "비고"), rows, right=(3, 4))
    if idle_pairs:
        rep.out("  판정 밖 %d행 = 페이지가 정의도 참조도 하지 않는 토큰의 쌍(FAIL 아님 · 그 토큰을 쓰기 시작하면 판정됨)"
                % idle_pairs)
    if pairs and not judged_pairs:
        rep.out("[대비] 판정할 쌍 없음 — 넘긴 쌍 %d개가 모두 판정 밖(페이지가 쓰는 전경/배경 조합을 --pair 로 넘긴다)"
                % len(pairs))

    # ── 축 2: 구조색 채도 ──
    if opts.chroma_tokens is not None:
        ctoks = [_strip_dashes(x) for x in opts.chroma_tokens]
    else:
        ctoks = [t for t in RAMP if any(t in props for props in mode_props.values())]
    for t in opts.extra_chroma:
        t = _strip_dashes(t)
        if t not in ctoks:
            ctoks.append(t)
    rep.out("")
    if not ctoks:
        rep.out("[채도] 판정 대상 토큰 없음(n-0…n-10 없음 · --chroma-tokens 없음)")
        rep.axis("채도", UNJUDGED, "판정 대상 토큰 없음")
    else:
        rep.axis("채도", JUDGED)
        rep.out("[채도 — 구조색 OKLCH C ≤ %g (판정 = 소수 넷째 자리 값)]" % opts.max_chroma)
        headers = ["토큰"]
        for label, _st in modes:
            headers += [label, "C", "판정"]
        rows = []
        for t in ctoks:
            row = ["--" + t]
            for label, _st in modes:
                try:
                    col, _ch = resolvers[label].color(t)
                    note_clip(label, t, col)
                    C = round(srgb8_to_oklch(col.rgb)[1], 4)
                    ok = C <= opts.max_chroma
                    row += [col.hex, "%.4f" % C, "PASS" if ok else "FAIL"]
                    if not ok:
                        rep.fails += 1
                except ColorError as e:
                    row += ["판정 불가", str(e), "FAIL"]
                    rep.fails += 1
            rows.append(row)
        rep.lines += _table(headers, rows)

    # ── 참조 금지(쌍 파일 forbid_refs) ──
    for tokens, targets in opts.forbid:
        forbidden = {_strip_dashes(x) for x in tokens}
        rep.out("")
        rep.out("[참조 금지 — %s 를 var() 연쇄에 쓰지 않음]" % ", ".join("--" + x for x in sorted(forbidden)))
        rows = []
        for t in targets:
            t = _strip_dashes(t)
            row = ["--" + t]
            for label, _st in modes:
                try:
                    _txt, chain = resolvers[label].expand(t)
                    hit = [c for c in chain[1:] if c in forbidden]
                    shown = " → ".join("--" + c for c in chain)
                    row += [shown, "FAIL" if hit else "PASS"]
                    if hit:
                        rep.fails += 1
                except ColorError as e:
                    row += [str(e), "FAIL"]
                    rep.fails += 1
            rows.append(row)
        headers = ["토큰"]
        for label, _st in modes:
            headers += [label + " 연쇄", "판정"]
        rep.lines += _table(headers, rows)

    # ── 축 4: 사용처 ──
    if opts.usage:
        root_ids = {id(r) for r, _roots in sheet.compiled}
        scoped = {}
        for r in rules:
            if id(r) not in root_ids:
                for name, value, _imp in r.decls:
                    scoped.setdefault(name, []).append(value)
        units = []
        for r in rules:
            if r.plain:
                label = r.selector if not r.ctx else " ".join(r.ctx) + " › " + r.selector
                units.append(("rule", label, r.ctx, {n: v for n, v, _i in r.decls}, r.plain))
        for label, body in extract_inline_styles(css_text, path):
            decls, plain = _parse_decls(body, notes)
            if plain:
                units.append(("attr", label, (), {n: v for n, v, _i in decls}, plain))
        judge_usage(units, scoped, modes, resolvers, opts, rep)
        rep.axis("사용처", JUDGED)
    else:
        rep.out("")
        rep.out("[사용처] 미실행(--no-usage) — 장식 단계 글자·틴트 테두리를 판정하지 않음 · 사용처 전부 사람 확인")
        rep.axis("사용처", UNRUN, "--no-usage")

    rep.notes += sorted(notes)


def judge_area(paths, opts, rep):
    rep.out("")
    rep.out("[유채 면적 — 픽셀 OKLCH C > %g 인 비율 ≤ %g%%]" % (opts.area_chroma, opts.area_max))
    rows = []
    tops = []
    for p in paths:
        w, h, counts = read_png_counts(p)
        total, chromatic, hot = area_ratio(counts, opts.area_chroma)
        pct = 100.0 * chromatic / total if total else 0.0
        ok = pct <= opts.area_max
        if not ok:
            rep.fails += 1
        rows.append((os.path.basename(p), "%dx%d" % (w, h), chromatic, "%.2f%%" % pct,
                     "%g%%" % opts.area_max, "PASS" if ok else "FAIL"))
        shown = [(rgb, k) for rgb, k in hot[:4] if total and 100.0 * k / total >= 0.005]
        if shown:
            tops.append("  %s 주요 유채색: %s" % (os.path.basename(p), " · ".join(
                "%s %.2f%%" % (_hex(rgb), 100.0 * k / total) for rgb, k in shown)))
        share = rare_share(total, chromatic, hot)
        if pct >= 0.1 and share >= 0.5:
            rep.warns.append(
                "%s: 유채 픽셀의 %.0f%%가 드문 색(각 0.005%% 미만)에서 옴 — 글자 서브픽셀 AA 색 번짐 의심 "
                "· 캡처를 --disable-lcd-text 로 다시 떠서 판정" % (os.path.basename(p), 100 * share))
    rep.lines += _table(("파일", "크기", "유채 픽셀", "비율", "상한", "판정"), rows, right=(2, 3, 4))
    rep.lines += tops
    rep.axis("유채 면적", JUDGED)


def direct_mode(args):
    try:
        fg, bg = parse_color(args.fg), parse_color(args.bg)
    except ColorError as e:
        sys.stderr.write("[ERROR] %s\n" % e)
        return 2
    note = ""
    if bg.alpha < 1:
        sys.stderr.write("[ERROR] 배경 반투명 — 대비 판정 불가\n")
        return 2
    if fg.alpha < 1:
        fg = composite(fg, bg)
        note = " (전경 알파 합성)"
    r = contrast(fg.rgb, bg.rgb)
    print("=== 색 대비 직접 계산 ===")
    for label, c in (("전경", fg), ("배경", bg)):
        L, C, H = srgb8_to_oklch(c.rgb)
        clip = " · gamut 밖 → clip" if c.clipped else ""
        hue = "%.1f" % H if C >= 0.0005 else "-"          # 무채색의 H 는 의미 없음
        print("  %s  %-24s → %s  OKLCH L=%.3f C=%.4f H=%s%s" % (label, c.text, c.hex, L, C, hue, clip))
    print("  대비비 %s:1%s" % (_ratio_str(r, args.min) if args.min is not None else "%.2f" % r, note))
    print("  본문 4.5:1 %s · 큰 글자·비텍스트 3:1 %s" % ("PASS" if r >= 4.5 else "FAIL",
                                                  "PASS" if r >= 3.0 else "FAIL"))
    if args.min is not None:
        ok = r >= args.min
        print("  최소 %g → %s" % (args.min, "PASS" if ok else "FAIL"))
        return 0 if ok else 1
    return 0


# ═══════════════════════════ 자가 시험 ═══════════════════════════

_SELFTEST_BLOCK = """
:root{
  --n-0:  oklch(1.000 0.000 264);  --n-1:  oklch(0.985 0.002 264);  --n-2:  oklch(0.967 0.004 264);
  --n-3:  oklch(0.928 0.007 264);  --n-4:  oklch(0.872 0.010 264);  --n-5:  oklch(0.809 0.014 264);
  --n-6:  oklch(0.714 0.019 264);  --n-7:  oklch(0.551 0.023 264);  --n-8:  oklch(0.446 0.028 264);
  --n-9:  oklch(0.373 0.031 264);  --n-10: oklch(0.210 0.032 264);
  --accent:       oklch(0.546 0.215 264);
  --accent-hover: oklch(0.488 0.215 264);
  --accent-bg:    oklch(0.967 0.015 264);
  --font: "Pretendard GOV","Pretendard","Malgun Gothic","Apple SD Gothic Neo","Noto Sans KR","Noto Sans CJK KR",system-ui,-apple-system,sans-serif;
  --font-mono: ui-monospace,"D2Coding","Cascadia Mono",Consolas,"Noto Sans Mono CJK KR",monospace;
  --s-1:4px; --r-m:6px;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --n-0:  oklch(0.178 0.014 264);  --n-1:  oklch(0.213 0.017 264);  --n-2:  oklch(0.255 0.020 264);
    --n-3:  oklch(0.304 0.022 264);  --n-4:  oklch(0.356 0.024 264);  --n-5:  oklch(0.410 0.025 264);
    --n-6:  oklch(0.487 0.026 264);  --n-7:  oklch(0.573 0.026 264);  --n-8:  oklch(0.715 0.022 264);
    --n-9:  oklch(0.840 0.016 264);  --n-10: oklch(0.949 0.010 264);
    --accent:       oklch(0.715 0.140 264);
    --accent-hover: oklch(0.780 0.111 264);
    --accent-bg:    oklch(0.285 0.055 264);
  }
}
:root[data-theme="dark"]{
  --n-0:  oklch(0.178 0.014 264);  --n-1:  oklch(0.213 0.017 264);  --n-2:  oklch(0.255 0.020 264);
  --n-3:  oklch(0.304 0.022 264);  --n-4:  oklch(0.356 0.024 264);  --n-5:  oklch(0.410 0.025 264);
  --n-6:  oklch(0.487 0.026 264);  --n-7:  oklch(0.573 0.026 264);  --n-8:  oklch(0.715 0.022 264);
  --n-9:  oklch(0.840 0.016 264);  --n-10: oklch(0.949 0.010 264);
  --accent:       oklch(0.715 0.140 264);
  --accent-hover: oklch(0.780 0.111 264);
  --accent-bg:    oklch(0.285 0.055 264);
}
"""

# web_page.md §5 표의 실측값(라이트, 다크) — STANDARD_PAIRS 순서.
_SELFTEST_EXPECT = [(17.74, 16.27), (10.28, 11.59), (7.61, 7.46), (5.19, 7.36), (4.83, 4.26),
                    (16.13, 13.56), (16.10, 12.45), (4.71, 5.63), (4.40, 3.55), (6.67, 9.41), (6.06, 7.20)]

# HTML 읽기 회귀 사례 — (이름, 입력, 옵션, 기대 FAIL 수 | "입력 오류", 알림 조각 "a|b|!c" — a·b 는 알림(입력 오류면 오류
# 문구)에 있어야 하고 c 는 없어야 한다). 기대값 = 브라우저(크로미움) 판정 · 닫히지 않은 요소·bogus comment 처럼 화면에 글자로
# 드러나는 것도 글자 = 살아 있지 않음. 옵션 nd = 기본 쌍 끔 · warn = 「warn 테두리」 쌍 추가(정의 없는 --warn 을 참조하면 두 모드
# FAIL 2). 알림 칸에 <noscript>·<template> 이 없으면 그 알림이 나오면 안 된다.
# 입력 줄임: {H} = 토큰 블록 <style> 을 연 head · {h} = {H} 를 닫고 body 까지 · {B} = 토큰 블록 · {L}·{K} = 토큰 블록의
# 라이트·다크 부분 <style> · {P} = 라이트만(흰 배경) 있는 문서 앞부분 · {D} = 다크 CSS · {d} = <style>{D}</style> ·
# {U} = 장식 단계 글자 <style> · {R} = --warn 참조 <style> · {Z} = </body></html>
_HTML_CASES = (
    ("<style media=print> 안 참조", '{H}</style><style media="print">.x{border-color:var(--warn)}</style>'
     "</head><body>{Z}", "warn", 2, ""),
    ("CSS 문자열 값 안 var() — 참조로 셈", '{H}.x::after{content:"var(--warn)"}</style></head><body>{Z}', "warn", 2, ""),
    ("대체값 안 중첩 var()", "{H}.x{border-color:var(--accent, var(--warn))}</style></head><body>{Z}", "warn", 2, ""),
    ("CSS nesting 안 참조", "{H}.card{border:1px solid var(--n-7); &:hover{border-color:var(--warn)}}</style>"
     "</head><body>{Z}", "warn", 2, "중첩 규칙"),
    ("SVG style 속성 참조", '{h}<svg width="10" height="10"><rect width="10" height="10" style="fill:var(--warn)"/>'
     "</svg>{Z}", "warn", 2, ""),
    ("hex 토큰 + @supports 로 oklch 덮기", "<!DOCTYPE html><html><head><style>:root{--n-0:#fff;--n-10:#1f2430} "
     '@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--n-0:#16181d;--n-10:#eceef2}} '
     "@supports (color: oklch(0 0 0)){{B}}</style></head><body>{Z}", "", 0, ""),
    ("oklch 토큰 뒤 @supports not 으로 hex 덮기(역순) — 브라우저가 칠하는 oklch 로 판정 → 채도 FAIL",
     "<!DOCTYPE html><html><head><style>:root{--n-0:oklch(1 0 264);--n-10:oklch(0.300 0.090 264)} "
     "@supports not (color: oklch(0 0 0)){:root{--n-0:#fff;--n-10:#1f2430}} "
     '@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--n-0:#16181d;--n-10:#eceef2}} '
     ':root[data-theme="dark"]{--n-0:#16181d;--n-10:#eceef2}</style></head><body>{Z}', "", 1, ""),
    ("@supports (display: grid) 안 루트 토큰 = 판정할 수 없는 조건(판정 밖 · 알림)",
     "{H}</style><style>@supports (display: grid){:root{--n-10:#9ca3af}}</style></head><body>{Z}", "", 0,
     "판정할 수 없는 조건 @supports (display: grid)"),
    ("@media(min-width) 안 참조", "{H}@media (min-width: 600px){ .a{ color: var(--warn) } }</style></head><body>"
     "<p>본문</p>{Z}", "warn", 2, ""),
    ("@supports 안 참조", "{H}@supports (display: grid){ .a{ border-color: var(--warn) } }</style></head><body>"
     "<p>본문</p>{Z}", "warn", 2, ""),
    ("@layer 안 참조", "{H}@layer base { .a{ color: var(--warn) } }</style></head><body><p>본문</p>{Z}", "warn", 2, ""),
    ("@container 안 참조", "{H}@container card (min-width: 400px){ .a{ color: var(--warn) } }</style></head>"
     "<body><p>본문</p>{Z}", "warn", 2, ""),
    ("HTML 주석 안 style 속성", '{h}<p>본문</p><!-- <p style="border-color:var(--warn)">옛 문단</p> -->{Z}',
     "warn", 0, ""),
    ("HTML 주석 안 <style>", "{h}<p>본문</p><!-- <style>.old{border-color:var(--warn)}</style> -->{Z}", "warn", 0, ""),
    ("살아 있는 참조 · 정의 없음", "{H}.a{border-color:var(--warn)}</style></head><body><p>본문</p>{Z}", "warn", 2, ""),
    ("살아 있는 참조 + 주석 안 <style> 에만 정의", "{H}.a{border-color:var(--warn)}</style></head><body><p>본문</p>"
     '<!-- <style>:root{--warn:#8a1c00} @media (prefers-color-scheme: dark){:root:not([data-theme="light"])'
     '{--warn:#ffb4a0}} :root[data-theme="dark"]{--warn:#ffb4a0}</style> -->{Z}', "warn", 2, ""),
    ("<script> 문자열 안 <style>", "{h}<p>본문</p><script>const css = '<style>.x{border-color:var(--warn)}</style>';"
     "</script>{Z}", "warn", 0, ""),
    ("nesting 안 color → 장식 단계(판정 밖)", "{B}.card{border:1px solid var(--n-7); &:hover{color:var(--n-5)}}",
     "", 0, "중첩 규칙"),
    ("평범한 규칙 color → 장식 단계", "{B}.card{border:1px solid var(--n-7)} .card:hover{color:var(--n-5)}", "", 1, ""),
    ("@media(min-width) 안 color → 장식 단계", "{B}@media (min-width: 600px){ .card{ color: var(--n-5) } }", "", 1, ""),
    ("<title> 안 '<script' 글자 뒤 <style>", "{H}</style><title>The <script> element</title>{U}</head><body>"
     "<script>var a=1</script>{Z}", "", 1, ""),
    ("<title> 안 '<script' 글자 뒤 참조 <style>", "{H}</style><title>The <script> element</title>{R}</head><body>"
     "<script>var a=1</script>{Z}", "warn", 2, ""),
    ("속성값 안 '<script' 글자", '{H}</style><meta name="description" content="How the <script> tag works">{U}'
     "</head><body><script>1</script>{Z}", "", 1, ""),
    ("<title> 안 '<!--' 글자", "{H}</style><title>Start with <!-- in HTML</title>{U}</head><body><!-- end -->{Z}",
     "", 1, ""),
    ("'<!-->' 은 바로 닫힘", "{H}</style><!-->{U}</head><body><!-- end -->{Z}", "", 1, ""),
    ("'--!>' 로 닫힘", "{H}</style><!-- note --!>{U}</head><body><!-- end -->{Z}", "", 1, ""),
    ("<textarea> 안 다크 정의", "<!DOCTYPE html><html><head>{L}</head><body><textarea>{K}</textarea>{Z}", "", 1, ""),
    ("<xmp> 안 다크 정의", "<!DOCTYPE html><html><head>{L}</head><body><xmp>{K}</xmp>{Z}", "", 1, ""),
    ("<noscript> 안 다크 정의", "<!DOCTYPE html><html><head>{L}</head><body><noscript>{K}</noscript>{Z}", "", 1,
     "<noscript>·<template>"),
    ("<template> 안 다크 정의", "<!DOCTYPE html><html><head>{L}</head><body><template>{K}</template>{Z}", "", 1,
     "<noscript>·<template>"),
    ("<title> 안 다크 정의", "<!DOCTYPE html><html><head>{L}<title>{K}</title></head><body>x{Z}", "", 1, ""),
    ("<textarea> 안 사용처", "{h}<textarea>{U}</textarea>{Z}", "", 0, ""),
    ("인라인 SVG <style>", "{h}<svg><style>.y{fill:var(--n-6)}</style></svg>{Z}", "", 1, ""),
    ("SVG <style> 의 CDATA 구간", "{h}<svg><style><![CDATA[.y{fill:var(--n-6)}]]></style></svg>{Z}", "", 1, ""),
    ("SVG <style> 안 <!-- --> 는 주석", "{h}<svg><style><!-- .y{fill:var(--n-6)} --></style></svg>{Z}", "", 0, ""),
    ("<style> 안 /* <!-- */", "{H} /* <!-- */ .x{color:var(--n-5)} /* --> */</style></head><body>x{Z}", "", 1, ""),
    ("대소문자 섞인 태그 — .z 만 살아 있음", '<!DOCTYPE html><html><head><STYLE>{B}</STYLE ><SCRIPT>s="<style>'
     '.x{color:var(--n-5)}</style>"</SCRIPT><Style>.z{color:var(--n-6)}</sTyle></head><body>x{Z}', "", 1, ""),
    ("닫히지 않은 주석 안 다크", "<!DOCTYPE html><html><head>{L}<!-- {K}</head><body>x{Z}", "", 1, ""),
    ("<noembed> 안 다크", "{P}<noembed>{d}</noembed>{Z}", "nd", 1, ""),
    ("<iframe> 안 다크", "{P}<iframe>{d}</iframe>{Z}", "nd", 1, ""),
    ("<noframes> 안 다크", "{P}<noframes>{d}</noframes>{Z}", "nd", 1, ""),
    ("<plaintext> 뒤 다크(문서 끝까지 글자)", "{P}<plaintext>{d}{Z}", "nd", 1, ""),
    ("중첩 <template> 안 다크", "{P}<template><template></template>{d}</template>{Z}", "nd", 1,
     "<noscript>·<template>"),
    ("HTML 문맥 <![CDATA[ 는 bogus comment", "{P}<![CDATA[{d}]]>{Z}", "nd", 1, ""),
    ("<? … > 는 bogus comment", "{P}<?x {d} ?>{Z}", "nd", 1, ""),
    ("닫히지 않은 <textarea> 안 다크", "{P}<textarea>{d}{Z}", "nd", 1, ""),
    ("닫히지 않은 <script> 안 다크", "{P}<script>{d}{Z}", "nd", 1, ""),
    ("<script type=text/template> 안 다크", '{P}<script type="text/template">{d}</script>{Z}', "nd", 1, ""),
    ("살아 있는 다크(대조)", "{P}{d}{Z}", "nd", 0, ""),
    ("짝 안 맞는 따옴표 뒤 <style>", '{h}<div class="a"">q</div>{U}<p title="a>b">y</p><span class="x">t</span>{Z}',
     "", 1, ""),
    ("글자 속 a<b · 따옴표 뒤 <style>", "{h}<p>if a<b isn't true</p>{U}<p>don't</p><span class=\"x\">t</span>{Z}",
     "", 1, ""),
    ("앞 속성값 안 '>' 뒤 style 속성", '{h}<div title="a>b" style="color:var(--n-5)" class="x">t</div>{Z}', "", 1, ""),
    ("대문자 STYLE 속성", '{h}<div class="x" STYLE="color:var(--n-5)">t</div>{Z}', "", 1, ""),
    ("<style> 속성값 안 '>'", '{h}<style data-x="a>b">.x{color:var(--n-5)}</style><span class="x">t</span>{Z}',
     "", 1, ""),
    ("따옴표 없는 style 속성", "{h}<div class=x style=color:var(--n-5)>t</div>{Z}", "", 1, ""),
    ("<textarea> 자신의 style 속성", '{h}<textarea class="x" style="color:var(--n-5)">abc</textarea>{Z}', "", 1, ""),
    ("<template> 안 요소의 style 속성", '{h}<template id="t"><span class="x" style="color:var(--n-5)">abc</span>'
     "</template>{Z}", "", 0, "<noscript>·<template>"),
    ("외부 스타일시트 · nesting · <template> 안 <style> = 알림만", '<!DOCTYPE html><html><head><link rel="stylesheet" '
     'href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR"><style>{B}.card{color:var(--n-10); & .t{color:'
     'var(--n-9)}}</style></head><body><template id="c"><style>.t{color:var(--n-9)}</style></template>'
     '<p class="card">x</p>{Z}', "", 0, "외부 스타일시트|중첩 규칙|<noscript>·<template>"),
    ("data-media 는 media 아님 → 다크 없음", '<!DOCTYPE html><html><head><style data-media="(prefers-color-scheme: '
     'dark)">:root{--n-0:#fff;--n-10:#111827}</style></head><body><p>t</p>{Z}', "", 1, ""),
    # 표준 경계 — 스크립트 이스케이프 · 주석 끝 · 태그 안 문서 끝 · type·media 속성 · 문자 참조 · foreign content(SVG·MathML)
    ("<script> 문자열 '</script>' 에서 닫힘", '{h}<script>var s="</script>{U}";</script>{Z}', "", 1, ""),
    ("<style> 안 CSS 문자열 '</style>' 에서 닫힘", '{h}<style>.q::after{content:"</style>"} .x{color:var(--n-5)}'
     "</style>{Z}", "", 0, ""),
    ("<script> 안 <!--<script> 뒤 </script> 는 닫지 않음", "{h}<script><!--<script></script>{U}--></script>{Z}", "", 0, ""),
    ("<script> 안 <!-- 뒤 </script> 는 닫음", "{h}<script><!--</script>{U}-->{Z}", "", 1, ""),
    ("'<!--->' 은 바로 닫힘", "{h}<!--->{U}<!-- end -->{Z}", "", 1, ""),
    ("주석 '-- >' 는 닫지 않음", "{h}<!-- a -- >{U} -->{Z}", "", 0, ""),
    ("조건부 주석 <!--[if IE]> 안 <style>", "{h}<!--[if IE]>{U}<![endif]-->{Z}", "", 0, ""),
    ("<![if !IE]> 사이 <style> 은 살아 있음", "{h}<![if !IE]>{U}<![endif]>{Z}", "", 1, ""),
    ("속성값 따옴표가 문서 끝까지 — 뒤 <style> 없음", '{h}<p title="x>{U}', "", 0, ""),
    ("'</ textarea>' 는 끝 태그 아님", "{h}<textarea></ textarea>{U}{Z}", "", 0, ""),
    ("끝 태그 속성값 안 '>'", '{h}<textarea></textarea title=">">{U}{Z}', "", 1, ""),
    ("'<a <style>' 의 <style 은 속성 이름", "{h}<a <style>.x{color:var(--n-5)}</style>{Z}", "", 0, ""),
    ("HTML <style/> 은 self-closing 아님", "{h}<style/>.x{color:var(--n-5)}</style>{Z}", "", 1, ""),
    ("<style type=text/template> 은 CSS 아님", '{P}<style type="text/template">{D}</style>{Z}', "nd", 1, ""),
    ("<style type=TEXT/CSS> 는 CSS", '{P}<style type="TEXT/CSS">{D}</style>{Z}', "nd", 0, ""),
    ("<style type=' text/css '> 은 CSS 아님", "{P}<style type=' text/css '>{D}</style>{Z}", "nd", 1, ""),
    ("<style media> 로 감싼 다크", '{P}<style media="(prefers-color-scheme: dark)">:root{--n-0:#000;--n-10:#eee}'
     "</style>{Z}", "nd", 0, ""),
    ("대문자·작은따옴표 MEDIA 속성", "{P}<style MEDIA='(prefers-color-scheme: dark)'>:root{--n-0:#000;--n-10:#eee}"
     "</style>{Z}", "nd", 0, ""),
    ("같은 style 속성 두 번 — 앞의 것", '{h}<p style="color:red" style="color:var(--n-5)">x</p>{Z}', "", 0, ""),
    ("style 속성 문자 참조 풀림", '{h}<p style="color:var(--n&#45;5)">x</p>{Z}', "", 1, ""),
    ("data-style 은 style 속성 아님", '{h}<p data-style="color:var(--n-5)">x</p>{Z}', "", 0, ""),
    ("작은따옴표 값 안 큰따옴표", "{h}<p title='a\"b'>{U}</p>{Z}", "", 1, ""),
    ("<template> 자신의 style 속성", '{h}<template style="color:var(--n-5)"></template>{Z}', "", 1, ""),
    ("<noscript> 자신의 style 속성", '{h}<noscript style="color:var(--n-5)">x</noscript>{Z}', "", 1, ""),
    ("<noscript> 안 style 속성", '{h}<noscript><p style="color:var(--n-5)">x</p></noscript>{Z}', "", 0,
     "<noscript>·<template>"),
    ("<select> 안 <style>", "{h}<select>{U}</select>{Z}", "", 1, ""),
    ("SVG <title> 안 <style> = HTML <style>(integration point)", "{h}<svg><title>{U}</title></svg>{Z}", "", 1, ""),
    ("SVG <foreignObject> 안 <style>", "{h}<svg><foreignObject>{U}</foreignObject></svg>{Z}", "", 1, ""),
    ("SVG 안 <textarea> 는 SVG 요소", "{h}<svg><textarea>{U}</textarea></svg>{Z}", "", 1, ""),
    ("SVG 안 <template> 은 SVG 요소", "{h}<svg><template>{U}</template></svg>{Z}", "", 1, ""),
    ("<template> 안 SVG <style>", "{h}<template><svg>{U}</svg></template>{Z}", "", 0, "<noscript>·<template>"),
    ("</svg> 뒤 <textarea> 는 다시 글자 요소", "{h}<svg></svg><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("SVG 안 <p> 는 SVG 를 닫음", "{h}<svg><p><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("SVG 안 </br> 는 SVG 를 닫음", "{h}<svg></br><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("SVG 안 <font color> 는 SVG 를 닫음", '{h}<svg><font color="red"><textarea>{U}</textarea></font></svg>{Z}',
     "", 0, ""),
    ("SVG 안 속성 없는 <font> 는 SVG 요소", "{h}<svg><font><textarea>{U}</textarea></font></svg>{Z}", "", 1, ""),
    ("<div><svg></div> — 끝 태그가 SVG 도 닫음", "{h}<div><svg></div><style><!-- .x{color:var(--n-5)} --></style>{Z}",
     "", 1, ""),
    ("SVG <style> 안 주석만 빠짐", "{h}<svg><style><!-- .z{color:var(--n-6)} --> .x{color:var(--n-5)}</style></svg>{Z}",
     "", 1, ""),
    ("SVG <style> 안 문자 참조는 풀림", "{h}<svg><style>.x{color:var(--n&#45;5)}</style></svg>{Z}", "", 1, ""),
    ("SVG <style/> 은 비어 있음", "{h}<svg><style/>.x{color:var(--n-5)}</svg>{Z}", "", 0, ""),
    ("SVG <style> 안 자식 요소 글자는 CSS 아님", "{h}<svg><style><a>.x{color:var(--n-5)}</a></style></svg>{Z}", "", 0, ""),
    ("MathML 안 <style> 은 CSS 아님", "{h}<math>{U}</math>{Z}", "", 0, ""),
    ("MathML <mi> 안 <style> = HTML <style>", "{h}<math><mi>{U}</mi></math>{Z}", "", 1, ""),
    ("MathML annotation-xml(text/html) 안 <style>", '{h}<math><annotation-xml encoding="text/html">{U}'
     "</annotation-xml></math>{Z}", "", 1, ""),
    # 시작 태그의 암묵 닫기 · form 포인터 · <html>·<head>·<body> 속성 병합
    ("<dt> 가 닫은 <dd> 의 </dd> 는 SVG 를 닫지 않음", "{h}<dl><dd>a<dt><svg></dd><textarea>{U}</textarea></svg></dl>{Z}",
     "", 1, ""),
    ("명시로 닫은 <dd> 뒤 </dd> 도 SVG 를 닫지 않음", "{h}<dl><dd>a</dd><dt><svg></dd><textarea>{U}</textarea></svg></dl>"
     "{Z}", "", 1, ""),
    ("<div> 가 닫은 <p> 뒤 </span> 은 SVG 를 닫음", "{h}<span><p>a<div>b</div><svg></span><textarea>{U}</textarea>{Z}",
     "", 0, ""),
    ("</h3> 은 열린 <h2> 와 SVG 를 닫음", "{h}<h2><svg></h3><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("</form> 은 form 만 빼고 SVG 는 열어 둠", "{h}<form><div><svg></form><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("<body style> 은 body 에 붙음", '{h}<body style="color:var(--n-5)">x{Z}', "", 1, ""),
    ("<body style> 이 두 번이면 앞의 것", '{H}</style></head><body style="color:red"><body style="color:var(--n-5)">x{Z}',
     "", 0, ""),
    ("늦게 온 <head style> 은 무시", '{h}<head style="color:var(--n-5)">x{Z}', "", 0, ""),
    ("<html style> 은 뿌리 요소에 붙음", '{h}<html style="color:var(--n-5)">x{Z}', "", 1, ""),
    ("표 밖 <td style> 은 무시", '{h}<div><td style="color:var(--n-5)">x</td></div>{Z}', "", 0, ""),
    ("표 밖 <td> 는 </div> 를 막지 않음", "{h}<div><td><svg></div><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("표 안 <td style> 은 살아 있음", '{h}<table><tr><td style="color:var(--n-5)">x</td></tr></table>{Z}', "", 1, ""),
    ("<frame style> 은 무시", '{h}<frame style="color:var(--n-5)">{Z}', "", 0, ""),
    ("표 칸 안 SVG foreignObject 의 <td style>", "{h}<table><tr><td><svg><foreignObject><td style=\"color:var(--n-5)\">"
     "x</td></foreignObject></svg></td></tr></table>{Z}", "", 1, ""),
    ("DOCTYPE 없으면(quirks) <table> 이 <p> 를 안 닫음", "<html><head><style>{B}</style></head><body><span><p>a<table>"
     "</table><svg></span><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("<!DOCTYPE html> 이면 <table> 이 <p> 를 닫음", "{h}<span><p>a<table></table><svg></span><textarea>{U}</textarea>{Z}",
     "", 0, ""),
    # 끝 태그의 암묵 닫기 · 표 모드(close the cell · table scope) · ruby · @import·@layer 알림 · 입력 오류 이유 · 선언형 shadow DOM
    ("</form> 은 암묵 끝 태그(열린 <p>)를 닫고 form 을 뺌", "{P}<span><form><p>x</form><svg></span><textarea>{d}</textarea>{Z}",
     "nd", 1, ""),
    ("명시로 닫은 <p> 뒤 </form>(대조)", "{P}<span><form><p>x</p></form><svg></span><textarea>{d}</textarea>{Z}", "nd", 1, ""),
    ("포인터가 칸 안에서 닫힌 form 이면 </form> 은 버림 — 바깥 form·열린 <p> 가 남아 SVG 도 열린 채",
     "{h}<form><table><tr><td></form><form></td></table><span><p>x</form><svg></span><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("포인터가 표 안에서 바로 닫힌 form 이면 </form> 은 버림",
     "{h}<form><table></form><form></table><span><p>x</form><svg></span><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("칸 안 </table> 은 표를 닫음 — 뒤 표 밖 <td style> 은 무시",
     '{h}<table><tr><td>x</table><td style="color:var(--n-5)">y</td>{Z}', "", 0, ""),
    ("</td></tr> 을 쓴 표 뒤 표 밖 <td style>(대조)",
     '{h}<table><tr><td>x</td></tr></table><td style="color:var(--n-5)">y</td>{Z}', "", 0, ""),
    ("칸 안 <tr> 은 칸·행을 닫음 — 뒤 </td> 는 무시돼 SVG 가 열린 채",
     "{h}<table><tr><td>a<tr><svg></td><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("칸 안 </tr> 은 칸·행을 닫음 — 뒤 </td> 는 무시", "{h}<table><tr><td>a</tr><svg></td><textarea>{U}</textarea>{Z}",
     "", 1, ""),
    ("칸 안 </tbody> 는 칸·행·구역을 닫음 — 뒤 </td> 는 무시",
     "{h}<table><tr><td>a</tbody><svg></td><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("표 바로 안 <table> 은 열린 표를 닫음", '{h}<table><table></table><td style="color:var(--n-5)">x</td>{Z}', "", 0, ""),
    ("caption 안 <tr> 은 caption 을 닫음 — 뒤 </caption> 은 무시",
     "{h}<table><caption>x<tr><svg></caption><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("칸 안 <td> 는 앞 칸을 닫음 — 두 번째 </td> 는 무시",
     "{h}<table><tr><td>a<td>b</td><svg></td><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("구역 바로 안 <td> 는 빠진 <tr> 을 채움 — 뒤 </tr> 이 SVG 를 닫음",
     "{h}<table><tbody><td>a</td><svg></tr><textarea>{U}</textarea>{Z}", "", 0, ""),
    ("행 안 새 <tr> 은 앞 행을 닫음 — 두 번째 </tr> 은 무시",
     "{h}<table><tr><td>a</td><tr><td>b</td></tr><svg></tr><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("colgroup 은 다른 시작 태그에서 닫힘 — 뒤 </colgroup> 은 무시",
     "{h}<table><colgroup><svg></colgroup><textarea>{U}</textarea>{Z}", "", 1, ""),
    ("표 바로 안 <table style> 은 새 표로 살아 있음", '{h}<table><table style="color:var(--n-5)"></table>{Z}', "", 1, ""),
    ("ruby 안 <rt> 는 열린 <p> 를 닫음", "{h}<span><ruby><p>x<rt>y</ruby><svg></span><textarea>{U}</textarea>{Z}",
     "", 0, ""),
    ("머리 @import(@charset·@layer 문 뒤) = 외부 스타일시트 알림", '{H}</style><style>@charset "utf-8"; @layer base; '
     '@import url("x.css");</style></head><body>{Z}', "", 0, "외부 스타일시트"),
    ("규칙 뒤 @import 는 무효 — 알림 없음", '{H}</style><style>.a{color:red} @import url("x.css");</style></head><body>{Z}',
     "", 0, "!외부 스타일시트"),
    ("CSS 파일 머리 @import = 외부 스타일시트 알림", '@import url("x.css");{B}', "", 0, "외부 스타일시트"),
    ("@layer 안 토큰 정의 = 근사 알림", "@layer base{{B}}", "", 0, "@layer 안 정의는 층 규칙 대신|층 밖 정의를 층 안 정의보다"),
    ("<template> 안 <style>·<link> 만 → 입력 오류 · 이 페이지의 읽지 않은 것", '<!DOCTYPE html><html><head><link '
     'rel="stylesheet" href="t.css"></head><body><template><style>{B}</style></template>{Z}', "", "입력 오류",
     "살아 있는 <style> 이 없다|이 페이지에서 읽지 않은 것|<noscript>·<template>|외부 스타일시트(<link"),
    ("주석 안 <style> 만 → 입력 오류 · 읽지 않는 곳", "<!DOCTYPE html><html><head><!-- <style>{B}</style> --></head><body>x{Z}",
     "", "입력 오류", "주석·스크립트 안 스타일|!이 페이지에서 읽지 않은 것"),
    ("외부 스타일시트(<link>)에만 토큰 → 루트 토큰 없음 입력 오류 · 이 페이지의 읽지 않은 것", '<!DOCTYPE html><html><head><link '
     'rel="stylesheet" href="t.css"><style>.a{color:var(--n-9)}</style></head><body><p class="a">x</p>{Z}', "", "입력 오류",
     "판정할 수 있는 루트 사용자 정의 속성이 없다|이 입력의 알림(판정 밖·근사|외부 스타일시트(<link"),
    ("CSS 파일의 @import 에만 토큰 → 루트 토큰 없음 입력 오류 · 이 파일의 읽지 않은 것", '@import url("t.css"); .a{color:var(--n-9)}',
     "", "입력 오류", "판정할 수 있는 루트 사용자 정의 속성이 없다|외부 스타일시트(<link|!이 페이지"),
    ("type 이 CSS 가 아닌 <style> 만 → 입력 오류 · 읽지 않는 곳", '<!DOCTYPE html><html><head><style type="text/scss">{B}'
     "</style></head><body>x{Z}", "", "입력 오류", "살아 있는 <style> 이 없다|이 페이지에서 읽지 않은 것|type 이 CSS 가 아닌 "
     "<style> 은 읽지 않음"),
    ("판정할 수 없는 루트 선택자에만 토큰 → 입력 오류 · 원인", "<!DOCTYPE html><html><head><style>html.light{--n-0:#fff;"
     "--n-10:#111827}</style></head><body>x{Z}", "", "입력 오류",
     "판정할 수 있는 루트 사용자 정의 속성이 없다|판정할 수 없는 루트 선택자 'html.light'|!하나도 없다"),
    ("판정할 수 없는 조건 안에만 토큰 → 입력 오류 · 원인", "<!DOCTYPE html><html><head><style>@media (min-width: 1px)"
     "{:root{--n-0:#fff;--n-10:#111827}}</style></head><body>x{Z}", "", "입력 오류",
     "판정할 수 있는 루트 사용자 정의 속성이 없다|판정할 수 없는 조건|!하나도 없다"),
    ("루트 밖 선택자에만 토큰 → 입력 오류 · 원인", "<!DOCTYPE html><html><head><style>body{--n-0:#fff;--n-10:#111827}"
     "</style></head><body>x{Z}", "", "입력 오류", "판정할 수 있는 루트 사용자 정의 속성이 없다|루트(:root·html)로 보지 않은 "
     "선택자|!하나도 없다"),
    ("CSS nesting 안에만 루트 토큰 → 입력 오류 · 중첩 알림", "<!DOCTYPE html><html><head><style>:root{@media (prefers-"
     "color-scheme: light){--n-0:#fff;--n-10:#111827}}</style></head><body>x{Z}", "", "입력 오류",
     "판정할 수 있는 루트 사용자 정의 속성이 없다|중첩 규칙(CSS nesting)|!하나도 없다"),
    ("라이트 정의 없이 속성 조건 두 블록(light·dark)만 → FAIL 4(라이트 정의 없음 · 라이트 본문 쌍 · 라이트 채도 n-0·n-10)",
     "<!DOCTYPE html><html><head><style>:root[data-theme=\"light\"]{--n-0:#fff;--n-10:#9ca3af}:root[data-theme=\"dark\"]{"
     "--n-0:#000;--n-10:#eee}</style></head><body>x{Z}", "", 4, ""),
    ("다크 미디어 블록만 → FAIL 4(라이트 정의 없음 · 라이트 본문 쌍 · 라이트 채도 n-0·n-10)", "<!DOCTYPE html><html><head>"
     "<style>{D}</style></head><body>x{Z}", "", 4, ""),
    ("라이트엔 표준 이름 없고 다크에만 n-0·n-10 → FAIL 6(라이트 쌍 판정 불가 2 · 라이트 채도 2 · 다크 본문 1.66·강조 4.05)", "<!DOCTYPE html><html><head><style>:root{"
     "--accent:#2b62eb}@media (prefers-color-scheme: dark){:root{--n-0:#000;--n-10:#333}}body{background:var(--n-0);"
     "color:var(--n-10)}</style></head><body><p>x</p>{Z}", "", 6, ""),
    ("속성 조건 루트(data-theme=light)에만 토큰 → 입력 오류 · 판정하는 정의 안내", "<!DOCTYPE html><html><head><style>"
     ':root[data-theme="light"]{--n-0:#fff;--n-10:#111827}</style></head><body>x{Z}', "", "입력 오류",
     '판정할 수 있는 루트 사용자 정의 속성이 없다|:root[data-theme="dark"]|!이 입력의 알림'),
    (":where(html) 에만 토큰 → 입력 오류 · 루트로 보지 않은 선택자", "<!DOCTYPE html><html><head><style>:where(html){"
     "--n-0:#fff;--n-10:#111827}</style></head><body>x{Z}", "", "입력 오류", "루트(:root·html)로 보지 않은 선택자"),
    ("웹폰트 <link> + type 이 CSS 가 아닌 <style> → 입력 오류 · 알림 둘 다", '<!DOCTYPE html><html><head><link '
     'rel="stylesheet" href="f.css"><style type="text/scss">{B}</style></head><body>x{Z}', "", "입력 오류",
     "살아 있는 <style> 이 없다|type 이 CSS 가 아닌 <style> 은 읽지 않음|외부 스타일시트(<link"),
    ("선언형 shadow DOM 안 스타일 = 따로 알림(일반 template 알림 없음)", '{h}<div><template shadowrootmode="open"><style>'
     '.y{margin:0}</style><p style="margin:0">x</p></template></div>{Z}', "", 0, "선언형 shadow DOM"),
)


def _html_case(src):
    """_HTML_CASES 입력 줄임말을 편다."""
    light, dark = _SELFTEST_BLOCK.split("@media", 1)
    for key, val in (("{h}", "{H}</style></head><body>"), ("{H}", "<!DOCTYPE html><html><head><style>{B}"),
                     ("{d}", "<style>{D}</style>"), ("{L}", "<style>" + light + "</style>"),
                     ("{K}", "<style>@media" + dark + "</style>"),
                     ("{P}", "<!DOCTYPE html><html><head><style>:root{--n-0:#fff;--n-10:#111827}</style></head><body>"
                             "<p>t</p>"),
                     ("{D}", "@media (prefers-color-scheme: dark){:root{--n-0:#000;--n-10:#eee}}"),
                     ("{U}", "<style>.x{color:var(--n-5)}</style>"),
                     ("{R}", "<style>.a{border-color:var(--warn)}</style>"),
                     ("{Z}", "</body></html>"), ("{B}", _SELFTEST_BLOCK)):
        src = src.replace(key, val)
    return src


def _find_visual_doc(name):
    """visual-design 스킬 문서(web_page.md·html_css.md) — 설치본(~/.claude/tools → ~/.claude/skills) · 패키지(tools →
    components/skills)."""
    here = os.path.dirname(os.path.abspath(__file__))
    rel = os.path.join("skills", "skill_LKS_original_visual-design", name)
    for base in (os.path.join(here, os.pardir), os.path.join(here, os.pardir, "components")):
        p = os.path.normpath(os.path.join(base, rel))
        if os.path.isfile(p):
            return p
    return None


_GATE_ROW = re.compile(r"^\|\s*(.+?)\s*\(`([\w-]+)`\s*/\s*`([\w-]+)`\)\s*\|\s*≥([\d.]+)\s*\|\s*([\d.]+)\s*\|\s*([\d.]+)\s*\|\s*$")


def _web_page_section5(path):
    """web_page.md §5 → (기준 블록 CSS | "", [(쌍 이름, 전경, 배경, 최소비, 라이트, 다크)])."""
    with open(path, encoding="utf-8-sig") as f:
        text = f.read()
    if "\n## 5." not in text:
        return "", []
    sec = text.split("\n## 5.", 1)[1].split("\n## 6.", 1)[0]
    m = re.search(r"```css\n(.*?)```", sec, re.S)
    rows = []
    for ln in sec.splitlines():
        g = _GATE_ROW.match(ln)
        if g:
            rows.append((g.group(1), g.group(2), g.group(3), float(g.group(4)), float(g.group(5)), float(g.group(6))))
    return (m.group(1) if m else ""), rows


def _web_page_norms(path):
    """web_page.md 규범 수치 → {이름: [문서에 적힌 값…]} — §1 구조색 채도 상한·유채 면적 상한 · §7 G3 행 · §7 면적 픽셀 임계."""
    with open(path, encoding="utf-8-sig") as f:
        text = f.read()
    sec1 = text.split("\n## 1.", 1)[-1].split("\n## 2.", 1)[0]
    sec7 = text.split("\n## 7.", 1)[-1].split("\n## 8.", 1)[0]
    g3 = re.search(r"(?m)^\| G3 채도 예산 \|[^|\n]*?C ≤ ([\d.]+)[^|\n]*?유채 면적 ≤ ([\d.]+)%", sec7)
    return {
        "채도 상한": [float(x) for x in re.findall(r"채도 C ≤ ([\d.]+)", sec1)[:1]] + ([float(g3.group(1))] if g3 else []),
        "면적 상한": [float(x) for x in re.findall(r"유채 면적 \*\*([\d.]+)% 이하\*\*", sec1)[:1]]
                     + ([float(g3.group(2))] if g3 else []),
        "면적 픽셀 임계": [float(x) for x in re.findall(r"픽셀 임계 = OKLCH C > ([\d.]+)", sec7)],
    }


def _html_css_61(path):
    """html_css.md §6-1 → (판정 칸의 쌍 {(전경, 배경, 최소비)}, 중성 변수 {이름}, 장식 금지 토큰 {이름}, 대응 CSS 블록,
    실측 최저값 행 | None). 판정 칸 = 「vs A·B ≥ m:1」(행 변수 → A·B) · 상태 행의 「테두리 vs 자기 `-bg`·B」·
    「`-bg` 위 A·B ≥ m:1」(A·B → 상태마다 자기 -bg) · 「상태 `-bg`」 = 상태 행의 모든 -bg."""
    with open(path, encoding="utf-8-sig") as f:
        text = f.read()
    sec = text.split("\n### 6-1.", 1)[-1].split("\n### 6-2.", 1)[0]
    rows = [[c.strip() for c in ln.strip().strip("|").split("|")] for ln in sec.splitlines()
            if ln.startswith("| `") or ln.startswith("| (")]
    names = [re.findall(r"`--([\w-]+)`", r[0]) or re.findall(r"`--([\w-]+)`", r[1]) for r in rows]
    status = next((n for r, n in zip(rows, names) if "+ `-bg`" in r[0]), [])
    neutral = {n[0] for r, n in zip(rows, names) if len(n) == 1 and re.fullmatch(r"`var\(--n-\d+\)`", r[1])}

    def targets(s, own):
        out = []
        for tok, own_bg, all_bg in re.findall(r"`--([\w-]+)`|(자기 `-bg`)|(상태 `-bg`)", s):
            out += [tok] if tok else ([own + "-bg"] if own_bg else [x + "-bg" for x in status])
        return out

    pairs = set()
    for r, n in zip(rows, names):
        for clause in r[3].split(" · "):
            m = re.fullmatch(r"(?:테두리 )?vs (.+?) ≥ ([\d.]+):1", clause.strip())
            on_bg = re.fullmatch(r"`-bg` 위 (.+?) ≥ ([\d.]+):1", clause.strip())
            for own in n:
                if m:
                    pairs |= {(own, bg, float(m.group(2))) for bg in targets(m.group(1), own)}
                elif on_bg:
                    pairs |= {(fg, own + "-bg", float(on_bg.group(2))) for fg in targets(on_bg.group(1), own)}
    rule = next((ln for ln in sec.splitlines() if "장식 단계" in ln and "도식 변수에 쓰지 않는다" in ln), "")
    decor = set(re.findall(r"`--(n-\d+)`", rule))
    block = re.search(r"```css\n(.*?)```", sec, re.S)
    measured = re.search(r"3:1 쌍 최저 라이트 ([\d.]+)\(([^)]*)\) · 다크 ([\d.]+)\(([^)]*)\) · 글자 쌍 최저 라이트 ([\d.]+)"
                         r" · 다크 ([\d.]+)", sec)
    return pairs, neutral, decor, (block.group(1) if block else ""), measured


class _Opts:
    def __init__(self, **kw):
        self.no_default_pairs = False
        self.extra_pairs = []
        self.max_chroma = DEFAULT_MAX_CHROMA
        self.chroma_tokens = None
        self.extra_chroma = []
        self.forbid = []
        self.area_chroma = DEFAULT_AREA_CHROMA
        self.area_max = DEFAULT_AREA_MAX
        self.usage = True
        self.decor_tokens = None            # None = DEFAULT_DECOR
        self.tint_tokens = None             # None = 이름이 -bg 로 끝나고 n-* 를 가리키지 않는 토큰
        self.__dict__.update(kw)


def _run_text(css, opts=None, name="selftest.css"):
    rep = Report()
    judge_file(name, css, opts or _Opts(), rep)
    return rep


def _png_bytes(w, h, pixels, bpp, filters):
    # 자가 시험용 PNG 인코더 — 줄마다 filters[y % len] 필터를 건다.
    def paeth(a, b, c):
        p = a + b - c
        pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
        return a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)

    stride = w * bpp
    raw = bytearray()
    prev = bytes(stride)
    for y in range(h):
        line = bytes(pixels[y * stride:(y + 1) * stride])
        f = filters[y % len(filters)]
        out = bytearray()
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            pred = {0: 0, 1: a, 2: b, 3: (a + b) >> 1, 4: paeth(a, b, c)}[f]
            out.append((line[i] - pred) & 255)
        raw.append(f)
        raw += out
        prev = line

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    ct = 2 if bpp == 3 else 6
    return (_PNG_SIG + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, ct, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(bytes(raw))) + chunk(b"IEND", b""))


def _selftest():
    import tempfile
    results = []

    def check(name, ok, detail=""):
        results.append(bool(ok))
        print("[%s] %s%s" % ("PASS" if ok else "FAIL", name, ("" if ok or not detail else "  — " + detail)))

    def near(x, want, tol):
        return abs(x - want) <= tol + 1e-9

    white = parse_color("#FFFFFF")
    deck = parse_color("#1428A0")
    r = contrast(deck.rgb, white.rgb)
    check("(1) #1428A0 vs #FFFFFF = 11.41", near(r, 11.41, 0.01), "%.4f" % r)
    c = srgb8_to_oklch(deck.rgb)[1]
    check("(2) #1428A0 C = 0.1908", near(c, 0.1908, 0.0001), "%.4f" % c)
    c = srgb8_to_oklch(parse_color("#374151").rgb)[1]
    check("(3) #374151 C = 0.0306", near(c, 0.0306, 0.0001), "%.4f" % c)
    r = contrast(parse_color("#E7EAF5").rgb, white.rgb)
    check("(4) #E7EAF5 vs 흰색 = 1.20", near(r, 1.20, 0.01), "%.4f" % r)

    notes = set()
    sheet = Sheet(parse_css(_SELFTEST_BLOCK, notes), notes)
    for label, st, col in (("라이트", STATE_LIGHT, 0), ("다크", STATE_DARK, 1)):
        res = Resolver(sheet.props(st))
        for (name, f, b, _m), exp in zip(STANDARD_PAIRS, _SELFTEST_EXPECT):
            got = contrast(res.color(f)[0].rgb, res.color(b)[0].rgb)
            check("(5) %s %s (%s/%s) = %.2f" % (label, name, f, b, exp[col]),
                  near(got, exp[col], 0.01), "%.4f" % got)
    same = sheet.props(STATE_DARK) == sheet.props(STATE_FORCED_DARK)
    check("(6) OS 다크 블록 = 강제 다크 블록(모드 판별)", same and sheet.has_media_dark() and sheet.has_forced("dark"))
    check("(6b) 강제 라이트(OS 다크) = 라이트", sheet.props(STATE_FORCED_LIGHT_ON_DARK) == sheet.props(STATE_LIGHT))

    rep = _run_text(_SELFTEST_BLOCK)
    check("(7) 기준 블록 전건 PASS(대비 11쌍 × 2모드 · 채도 11토큰 × 2모드)", rep.fails == 0,
          "FAIL %d" % rep.fails)

    # 파서·표기
    res = Resolver({"a": "var(--b)", "b": "var(--c, #fff)", "x": "var(--y)", "y": "var(--x)",
                    "k": "var(--missing)"})
    check("(8) var() 중첩 + 대체값", res.color("a")[0].rgb == (255, 255, 255) and res.color("a")[1] == ["a", "b"])
    try:
        res.color("x")
        ok = False
    except ColorError as e:
        ok = "순환" in str(e)
    check("(9) var() 순환 = 오류", ok)
    check("(9b) 같은 순환은 한 번만 보고", len(res.cycles()) == 1)
    try:
        res.color("k")
        ok = False
    except ColorError as e:
        ok = "미정의" in str(e)
    check("(10) 미정의 + 대체값 없음 = 오류", ok)
    check("(11) #RGB = #RRGGBB", parse_color("#fff").rgb == parse_color("#FFFFFF").rgb)
    check("(12) rgb() 쉼표·공백 문법 = hex",
          parse_color("rgb(17, 24, 39)").rgb == parse_color("rgb(17 24 39)").rgb == parse_color("#111827").rgb)
    check("(13) oklch L % = 0–1", parse_color("oklch(54.6% 0.215 264)").rgb == parse_color("oklch(0.546 0.215 264)").rgb)
    check("(14) gamut 밖 → clip 표시", parse_color("oklch(0.9 0.3 140)").clipped
          and not parse_color("oklch(0.5 0.05 264)").clipped)
    a = parse_color("rgb(0 0 0 / 0.5)")
    check("(15) 알파 합성(검정 50% on 흰색 = #808080)", composite(a, white).rgb == (128, 128, 128))

    # 음성 시험 3종 — 각각 FAIL 로 잡혀야 도구가 유효
    deckblock = _SELFTEST_BLOCK.replace("--n-9:  oklch(0.373 0.031 264);", "--n-9:  #1428A0;", 1)
    rep = _run_text(deckblock)
    chroma_fail = any("--n-9" in ln and "FAIL" in ln for ln in rep.lines)
    contrast_ok = not any(ln.lstrip().startswith("보조 본문") and "FAIL" in ln for ln in rep.lines)
    check("(16) 음성: 덱 블루를 구조색(n-9)에 → 채도 FAIL · 대비는 통과", chroma_fail and contrast_ok and rep.fails > 0)
    focus = _SELFTEST_BLOCK.replace("--n-7:  oklch(0.551 0.023 264);", "--n-7:  oklch(0.714 0.019 264);", 1)
    rep = _run_text(focus)
    check("(17) 음성: 포커스링을 n-6 값에 → 라이트 대비 FAIL",
          any(ln.lstrip().startswith("포커스링") and "FAIL" in ln for ln in rep.lines))
    no_n8 = re.sub(r"--n-8:  oklch\(0\.715 0\.022 264\);", "", _SELFTEST_BLOCK)
    rep = _run_text(no_n8)
    dark_sec = "\n".join(rep.lines).split("[대비 — 다크]")[-1].split("[채도")[0]
    check("(18) 음성: 다크에서 n-8 만 안 바꿈 → 다크 대비 FAIL",
          any(ln.lstrip().startswith("약한 텍스트") and "FAIL" in ln for ln in dark_sec.splitlines()))
    rep = _run_text(_SELFTEST_BLOCK + ":root{--fg2: var(--n-6);}",
                    _Opts(forbid=[(["n-5", "n-6"], ["fg2"])]))
    check("(19) 참조 금지: --fg2 → --n-6 → FAIL", rep.fails > 0)
    rep = _run_text(":root{--n-0:#fff;--n-10:#111827;}", _Opts(no_default_pairs=True))
    check("(20) 다크 정의 없음 = FAIL · 안내 = 다크 블록을 만든다(끄는 옵션 안내 없음)",
          rep.fails == 1 and any("다크 블록을 만든다" in ln for ln in rep.lines)
          and not any("light-only" in ln for ln in rep.lines))

    # PNG — 필터 0~4 왕복 · RGB/RGBA · 면적 · 미지원 형식
    with tempfile.TemporaryDirectory() as td:
        ok_all = True
        for bpp in (3, 4):
            w, h = 7, 10
            px = bytearray()
            for y in range(h):
                for x in range(w):
                    px += bytes(((x * 37 + y * 11) % 256, (x * 5 + y * 90) % 256, (x * y * 13) % 256))
                    if bpp == 4:
                        px.append((x * 29 + y) % 256)
            p = os.path.join(td, "t%d.png" % bpp)
            with open(p, "wb") as f:
                f.write(_png_bytes(w, h, px, bpp, [0, 1, 2, 3, 4]))
            gw, gh, counts = read_png_counts(p)
            want = Counter(tuple(px[i:i + 3]) for i in range(0, len(px), bpp))
            ok_all = ok_all and (gw, gh) == (w, h) and counts == want
        check("(21) PNG 필터 0~4 역연산 왕복(RGB·RGBA)", ok_all)
        w, h = 10, 10
        px = bytearray()
        for i in range(w * h):
            px += bytes((43, 98, 235)) if i < 3 else bytes((243, 244, 247))
        p = os.path.join(td, "area.png")
        with open(p, "wb") as f:
            f.write(_png_bytes(w, h, px, 3, [4, 1]))
        _w, _h, counts = read_png_counts(p)
        total, chrom, _hot = area_ratio(counts, DEFAULT_AREA_CHROMA)
        check("(22) 면적: 100 픽셀 중 강조 3 = 3.00%", total == 100 and chrom == 3)
        fringe = [((200, 120 + k, 60), 1) for k in range(60)] + [((43, 98, 235), 40)]
        solid = [((43, 98, 235), 100)]
        check("(22b) 드문 색 비율 — 흩어진 번짐 색 0.6 · 한 색으로 칠한 면 0",
              near(rare_share(100000, 100, fringe), 0.6, 1e-9) and rare_share(100000, 100, solid) == 0)
        gray = _PNG_SIG + b"\x00\x00\x00\x0dIHDR" + struct.pack(">IIBBBBB", 1, 1, 8, 0, 0, 0, 0) + b"\x00" * 4
        p = os.path.join(td, "gray.png")
        with open(p, "wb") as f:
            f.write(gray)
        try:
            read_png_counts(p)
            ok = False
        except InputError as e:
            ok = "미지원 PNG 형식" in str(e)
        check("(23) 미지원 PNG(grayscale) = 명확한 오류", ok)

    # 사용처 — 장식 단계를 글자·아이콘에(FAIL) · 틴트 배경에 같은 규칙 테두리 없음(경고)
    def usage_rows(rep):
        sec = "\n".join(rep.lines).split("[사용처")[-1]
        return [ln for ln in sec.splitlines() if ln.rstrip().endswith(("FAIL", "경고"))]

    rep = _run_text(_SELFTEST_BLOCK + "body{color:var(--n-10);background:var(--n-0)} .prose{max-width:40em}")
    check("(24) 사용처 양성: 기준 블록 + body 규칙 → FAIL 0 · 경고 0", rep.fails == 0 and not rep.warns)
    rep = _run_text(_SELFTEST_BLOCK + ".empty{color:var(--n-6)}")
    check("(25) 사용처 음성: color → --n-6 직접 = FAIL", rep.fails == 1 and len(usage_rows(rep)) == 1)
    rep = _run_text(_SELFTEST_BLOCK + ":root{--muted:var(--n-5)} .icon{fill:var(--muted)} "
                    ".x{--c:var(--n-6);stroke:var(--c)} .y{color:var(--nope, var(--n-6))}")
    check("(26) 사용처 음성: 연쇄(--muted → --n-5)·같은 규칙 정의·대체값 = FAIL 3", rep.fails == 3)
    dark_only = _SELFTEST_BLOCK.replace(":root{\n", ":root{\n  --muted: var(--n-8);\n", 1).replace(
        ":root[data-theme=\"dark\"]{\n", ":root[data-theme=\"dark\"]{\n  --muted: var(--n-6);\n", 1).replace(
        ":root:not([data-theme=\"light\"]){\n", ":root:not([data-theme=\"light\"]){\n    --muted: var(--n-6);\n", 1)
    rep = _run_text(dark_only + ".note{color:var(--muted)}")
    rows = usage_rows(rep)
    check("(27) 사용처 음성: 다크에서만 장식 단계 → 모드 = 다크만",
          rep.fails == 1 and len(rows) == 1 and "다크" in rows[0] and "라이트" not in rows[0])
    rep = _run_text(_SELFTEST_BLOCK + ".row{border-bottom:1px solid var(--n-5)} .chip{border:1px solid var(--n-6)} "
                    ".empty{color:var(--n-8)}")
    check("(28) 사용처 양성: 테두리의 장식 단계 = FAIL 아님 · 글자 --n-8 통과", rep.fails == 0)
    rep = _run_text(_SELFTEST_BLOCK + ".badge{background:var(--accent-bg);border:1px solid var(--n-7)} "
                    ".note{background:var(--accent-bg)} .flat{background-color:var(--accent-bg);border:none}")
    tint_warns = [w for w in rep.warns if w.startswith("틴트 배경")]
    check("(29) 틴트: 테두리 동반 PASS · 테두리 없음·none = 경고 2(FAIL 아님)",
          rep.fails == 0 and len(tint_warns) == 2 and ".badge" not in " ".join(tint_warns))
    rep = _run_text(_SELFTEST_BLOCK + ":root{--card-bg:var(--n-2)} .card{background:var(--card-bg)}")
    check("(29b) 중성 램프를 가리키는 -bg 토큰(--card-bg → --n-2)은 틴트 아님 → 경고 0",
          rep.fails == 0 and not rep.warns)
    rep = _run_text(_SELFTEST_BLOCK + ".empty{color:var(--n-6)} .note{background:var(--accent-bg)}",
                    _Opts(usage=False))
    check("(30) 사용처 끔(--no-usage) → 사용처 FAIL·경고 0", rep.fails == 0 and not rep.warns)
    html_page = ("<!DOCTYPE html><html><head><style>:root{--n-0:#fff;--n-6:#9da3af;--n-10:#111827}"
                 "@media (prefers-color-scheme: dark){:root{--n-0:#0e1117;--n-6:#58606f;--n-10:#ebeef5}}</style>"
                 "</head><body><p style=\"color: var(--n-6)\">빈 값</p><script>x='style=\"color:var(--n-6)\"'</script>"
                 "</body></html>")
    rep = _run_text(html_page, _Opts(no_default_pairs=True), name="page.html")
    rows = usage_rows(rep)
    check("(31) HTML style 속성도 사용처(스크립트 안 문자열 제외) → FAIL 1",
          rep.fails == 1 and len(rows) == 1 and "<p style>" in rows[0])

    status_pairs = [Pair("ok 테두리 / ok 면", "ok", "ok-bg", 3.0, "시험")]
    rep = _run_text(_SELFTEST_BLOCK, _Opts(extra_pairs=status_pairs))
    check("(32) 쌍이 가리키는 토큰을 페이지가 정의·참조 안 함 → 판정 밖(FAIL 0)",
          rep.fails == 0 and any("판정 밖" in ln for ln in rep.lines))
    rep = _run_text(_SELFTEST_BLOCK + ".done{border-color:var(--ok)}", _Opts(extra_pairs=status_pairs))
    check("(33) 참조는 하는데 정의 없음 → FAIL 유지", rep.fails > 0)

    warn_pairs = [Pair("warn 테두리", "warn", "n-0", 3.0, "시험")]
    doc_page = ("<!DOCTYPE html><html><head><style>" + _SELFTEST_BLOCK + "/* .x{border-color:var(--warn)} */"
                "</style></head><body><p><code>border-color: var(--warn)</code></p>"
                "<script>s='var(--warn)'</script></body></html>")
    rep = _run_text(doc_page, _Opts(extra_pairs=warn_pairs), name="doc.html")
    check("(34) CSS 주석·본문 <code>·<script> 속 var(--warn) 글자 = 참조 아님 → 판정 밖(FAIL 0)",
          rep.fails == 0 and any("판정 밖" in ln for ln in rep.lines), "FAIL %d" % rep.fails)
    rep = _run_text(doc_page.replace("<p>", "<p style=\"border-color:var(--warn)\">", 1),
                    _Opts(extra_pairs=warn_pairs), name="doc.html")
    check("(35) style 속성에서 참조 + 정의 없음 → FAIL 유지", rep.fails > 0)
    rep = _run_text(_SELFTEST_BLOCK + ".card{border:1px solid var(--n-7); &:hover{border-color:var(--warn)}}",
                    _Opts(extra_pairs=warn_pairs))
    check("(35b) CSS nesting 안에서 참조 + 정의 없음 → FAIL 유지", rep.fails > 0)
    live = "<!DOCTYPE html><html><head><style>" + _SELFTEST_BLOCK + ".a{border-color:var(--warn)}</style>"
    dead = ("<!-- <style>:root{--warn:#8a1c00} @media (prefers-color-scheme: dark){:root:not([data-theme=\"light\"])"
            "{--warn:#ffb4a0}} :root[data-theme=\"dark\"]{--warn:#ffb4a0}</style> -->")
    rep = _run_text(live + dead + "</head><body></body></html>",
                    _Opts(extra_pairs=warn_pairs), name="c.html")
    check("(35c) HTML 주석 안 <style> 의 정의는 살아 있는 정의가 아님 → 참조 + 정의 없음 = FAIL", rep.fails > 0)
    rep = _run_text("<!DOCTYPE html><html><head><style>" + _SELFTEST_BLOCK + "</style></head><body>"
                    "<script>s='<style>.x{color:var(--warn)}</style>'</script></body></html>",
                    _Opts(extra_pairs=warn_pairs), name="s.html")
    check("(35d) <script> 문자열 안 <style> 의 var() 는 참조 아님 → 판정 밖(FAIL 0)",
          rep.fails == 0 and any("판정 밖" in ln for ln in rep.lines), "FAIL %d" % rep.fails)
    head = "<!DOCTYPE html><html><head><style>" + _SELFTEST_BLOCK + "</style>"
    rep = _run_text(head + "<title>The <script> element</title><style>.x{color:var(--n-5)}</style></head>"
                    "<body><script>var a=1</script></body></html>", name="t.html")
    check("(35e) <title> 안 '<script' 글자가 뒤의 살아 있는 <style> 을 삼키지 않음 → 사용처 FAIL", rep.fails == 1,
          "FAIL %d" % rep.fails)
    rep = _run_text(head + "<!--><style>.x{color:var(--n-5)}</style></head><body><!-- end --></body></html>",
                    name="c.html")
    check("(35f) 짧게 닫히는 주석 <!--> 뒤 <style> 은 살아 있음 → 사용처 FAIL", rep.fails == 1, "FAIL %d" % rep.fails)
    rep = _run_text(head + "<title>The <script> element</title></head><body><div style=\"color:var(--n-5)\">x</div>"
                    "<script>var a=1</script></body></html>", name="a.html")
    check("(35g) style 속성 경로도 같은 스캔 → 사용처 FAIL", rep.fails == 1, "FAIL %d" % rep.fails)
    rep = _run_text("<!DOCTYPE html><html><head><style>:root{--n-0:#fff;--n-10:#111827}</style></head><body>"
                    "<textarea><style>@media (prefers-color-scheme: dark){:root{--n-0:#000;--n-10:#eee}}</style>"
                    "</textarea></body></html>", _Opts(no_default_pairs=True), name="r.html")
    check("(35h) <textarea> 안 <style> 은 정의가 아님 → 다크 정의 없음 FAIL", rep.fails == 1, "FAIL %d" % rep.fails)

    # 기준 블록 사본 3벌(STANDARD_PAIRS · _SELFTEST_BLOCK · _SELFTEST_EXPECT) ↔ 원본 web_page.md §5
    wp = _find_visual_doc("web_page.md")
    if wp is None:
        print("[건너뜀] (36)(37) 기준 블록 원본 web_page.md 를 못 찾음 — 설치본·패키지 저장소에서만 대조")
    else:
        css, rows = _web_page_section5(wp)
        mine = Sheet(parse_css(_SELFTEST_BLOCK, set()), set())
        src = Sheet(parse_css(css, set()), set())
        diff = set()
        for st in (STATE_LIGHT, STATE_DARK, STATE_FORCED_DARK):
            a, b = mine.props(st), src.props(st)
            diff |= {k for k in a if " ".join(b.get(k, "").split()) != " ".join(a[k].split())}
        check("(36) 도구 기준 블록 사본 = web_page.md §5 값(라이트·OS 다크·강제 다크)", css and not diff,
              "%s — %s" % (wp, ", ".join("--" + k for k in sorted(diff)[:8]) if css else "§5 css 블록 없음"))
        want = [(n, f, b, m, e[0], e[1]) for (n, f, b, m), e in zip(STANDARD_PAIRS, _SELFTEST_EXPECT)]
        check("(37) 기본 쌍·실측값 = web_page.md §5 게이트 표(순서 포함)",
              rows == want and len(STANDARD_PAIRS) == len(_SELFTEST_EXPECT),
              "%s — 표 %d행 · 도구 %d쌍" % (wp, len(rows), len(STANDARD_PAIRS)))

    # HTML 읽기 회귀 사례 표 — 브라우저 판정과 같은가(어긋난 행만 찍고 표 전체는 한 줄)
    inert = "<noscript>·<template>"
    passed_rows = 0
    for name, src, opt, want, want_notes in _HTML_CASES:
        text = _html_case(src)
        opts = {"nd": _Opts(no_default_pairs=True), "warn": _Opts(extra_pairs=warn_pairs)}.get(opt, _Opts())
        try:
            rep = _run_text(text, opts, name="case.html" if text.lstrip().startswith("<") else "case.css")
            got, notes = rep.fails, rep.notes
        except InputError as e:
            got, notes = "입력 오류", [str(e)]
        need = [x for x in want_notes.split("|") if x and not x.startswith("!")]
        ban = [x[1:] for x in want_notes.split("|") if x.startswith("!")] + ([] if inert in need else [inert])
        if (got == want and all(any(x in n for n in notes) for x in need)
                and not any(x in n for x in ban for n in notes)):
            passed_rows += 1
        else:
            print("[FAIL] (38) %s → 기대 FAIL %s%s  — 실제 FAIL %s · 알림 %s"
                  % (name, want, " · 알림 " + want_notes if want_notes else "", got, notes))
    check("(38) HTML 회귀 표 %d/%d" % (passed_rows, len(_HTML_CASES)), passed_rows == len(_HTML_CASES))

    # 알림(판정 밖)과 경고(해소 대상) 출력 분리
    import contextlib
    import io
    w_src = next(src for name, src, *_rest in _HTML_CASES if name.startswith("외부 스타일시트"))
    outs = []
    with tempfile.TemporaryDirectory() as td:
        for fname, text in (("w.html", _html_case(w_src)),
                            ("t.css", _SELFTEST_BLOCK + ".note{background:var(--accent-bg)}")):
            p = os.path.join(td, fname)
            with open(p, "w", encoding="utf-8") as f:
                f.write(text)
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                code = main([p])
            outs.append((code, buf.getvalue()))
    (c1, o1), (c2, o2) = outs
    unrun_tail = " · 미실행 축(유채 면적)은 통과 아님"
    ok1 = (c1 == 0 and "[알림 3 — 판정 밖·근사 · 사람 확인]" in o1 and "[경고" not in o1 and "해소 대상" not in o1
           and o1.rstrip().endswith("[요약] FAIL 0 · 경고 0 · 알림 3 → PASS (exit 0)" + unrun_tail))
    ok2 = (c2 == 0 and "[경고 1 — 판정에는 넣지 않음 · 해소 대상]" in o2 and "[알림" not in o2
           and o2.rstrip().endswith("[요약] FAIL 0 · 경고 1 · 알림 0 → PASS (exit 0)" + unrun_tail
                                    + " · 경고는 전달 전 해소"))
    check("(39) 판정 밖 알림은 [알림 N](해소 요구 없음) · 「해소 대상」·「전달 전 해소」는 경고에만 · 요약 = FAIL·경고·알림 수",
          ok1 and ok2, "%r | %r" % (o1.strip().splitlines()[-1:], o2.strip().splitlines()[-1:]))

    got = extract_inline_styles('<!DOCTYPE html>\n<textarea>\n<p style="x">\n</textarea>\n<p\n  style="color:red">'
                                "<svg>\n<rect style='fill:red'/></svg>", "l.html")
    check("(40) style 속성 표시 이름 = 시작 태그 줄(글자 요소 내용 건너 · 여러 줄 태그 · SVG)",
          got == [("<p style> 5행", "color:red"), ("<rect style> 7행", "fill:red")], repr(got))
    doctypes = [("DOCTYPE html", False), ('doctype HTML SYSTEM "about:legacy-compat"', False),
                ('DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"', False),
                ('DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"',
                 False),
                ('DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"', True),
                ('DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"', True), ("DOCTYPE svg", True),
                ("DOCTYPE", True), ("DOCTYPE html foo", True), ("DOCTYPE html PUBLIC", True)]
    wrong = [t for t, q in doctypes if _quirks_doctype(t) != q]
    check("(41) DOCTYPE → quirks 모드 판별(<table> 이 열린 <p> 를 닫는지 가름)", not wrong, repr(wrong))

    # 명령줄 전체(종료코드·[판정 축]·[요약]) — 트레이스백으로 죽는 경로도 실패로 센다
    def cli(argv):
        out, err = io.StringIO(), io.StringIO()
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                code = main(argv)
        except Exception as e:
            code = "예외 %s" % type(e).__name__
        return code, out.getvalue(), err.getvalue()

    def last(o):
        return (o.strip().splitlines() or [""])[-1]

    brand = (":root{--brand-primary:#1428A0;--ink:#1F2937;--bg:#FFFFFF;}"
             '@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--brand-primary:#1428A0;--ink:#F9FAFB;'
             '--bg:#0E1117;}}:root[data-theme="dark"]{--brand-primary:#1428A0;--ink:#F9FAFB;--bg:#0E1117;}'
             "body{background:var(--bg);color:var(--ink)}")
    with tempfile.TemporaryDirectory() as td:
        def put(fname, data):
            p = os.path.join(td, fname)
            with open(p, "wb") as f:
                f.write(data if isinstance(data, bytes) else data.encode("utf-8"))
            return p

        page = put("brand.css", brand)
        std = put("std.css", _SELFTEST_BLOCK)
        runs = {
            "옵션 없음": cli([page]),
            "--pair 만(채도 0)": cli([page, "--pair", "본문:ink:bg:4.5"]),
            "--chroma-tokens 만(대비 0)": cli([page, "--chroma-tokens", "ink,bg"]),
            "쌍 전부 판정 밖": cli([std, "--no-default-pairs", "--pair", "상태:ok:ok-bg:3"]),
        }
        bad = [k for k, (c, o, _e) in runs.items()
               if not (c == 1 and "→ 판정 안 됨 (exit 1)" in last(o) and "판정 안 됨(" in o)]
        both = runs["옵션 없음"][1]
        c_ok, o_ok, _e = cli([page, "--pair", "본문:ink:bg:4.5", "--chroma-tokens", "ink,bg"])
        check("(42) 판정한 대비 쌍·채도 토큰이 0 = 「판정 안 됨」 exit 1(한 축만 0 · 쌍 전부 판정 밖 포함) · 둘 다 넘기면 PASS",
              not bad and "대비 판정 안 됨(판정할 쌍 없음) · 채도 판정 안 됨(판정 대상 토큰 없음)" in both
              and c_ok == 0 and last(o_ok).startswith("[요약] FAIL 0") and "→ PASS (exit 0)" in last(o_ok),
              "어긋남=%s · 둘 다 넘김 %r" % (bad, c_ok))

        area = os.path.join(td, "a.png")
        with open(area, "wb") as f:
            f.write(_png_bytes(10, 10, bytes((243, 244, 247)) * 100, 3, [0]))
        c1, o1, _e = cli([std])
        c2, o2, _e = cli([std, "--no-usage"])
        c3, o3, _e = cli(["--area", area])
        check("(43) 돌리지 않은 축 = 「미실행(이유)」 — 면적(--area 없음)·사용처(--no-usage)·면적만 모드의 파일 축",
              c1 == 0 and "[판정 축] 대비 판정 · 채도 판정 · 유채 면적 미실행(--area 없음) · 사용처 판정" in o1
              and last(o1).endswith("미실행 축(유채 면적)은 통과 아님")
              and c2 == 0 and "[사용처] 미실행(--no-usage)" in o2 and "사용처 미실행(--no-usage)" in o2
              and last(o2).endswith("미실행 축(유채 면적·사용처)은 통과 아님")
              and c3 == 0 and "대비 미실행(CSS·HTML 파일 없음 — 면적만)" in o3 and "유채 면적 판정" in o3,
              "%r %r %r" % (last(o1), last(o2), last(o3)))

        cp949 = put("cp949.css", (_SELFTEST_BLOCK + "/* 한글 본문 */").encode("cp949"))
        pairs_json = json.dumps({"pairs": [{"name": "본문", "fg": "n-10", "bg": "n-0", "min": 4.5}]}, ensure_ascii=False)
        bom = put("bom.json", b"\xef\xbb\xbf" + pairs_json.encode("utf-8"))
        ansi = put("ansi.json", pairs_json.encode("cp949"))
        c4, _o, e4 = cli([cp949])
        c5, _o, _e = cli([std, "--pairs", bom])
        c6, _o, e6 = cli([std, "--pairs", ansi])
        check("(44) UTF-8 아닌 입력·쌍 파일 = 입력 오류(exit 2) + 「UTF-8 로 저장해 다시」 · BOM 붙은 쌍 파일은 읽음",
              c4 == 2 and "입력 파일이 UTF-8 이 아니다" in e4 and "UTF-8 로 저장해" in e4
              and c5 == 0 and c6 == 2 and "쌍 파일이 UTF-8 이 아니다" in e6, "%r %r %r" % (c4, c5, c6))

        # 상한 경계 — 구조색 채도(소수 넷째 자리 0.0320 = PASS · 0.0321 = FAIL) · 유채 면적(5.00% = PASS · 5.01% = FAIL)
        def n9(hexv):
            return _run_text(_SELFTEST_BLOCK.replace("--n-9:  oklch(0.373 0.031 264);", "--n-9:  %s;" % hexv, 1))

        at, over = n9("#294148"), n9("#284047")
        areas = []
        for hot in (500, 501):
            p = os.path.join(td, "edge%d.png" % hot)
            with open(p, "wb") as f:
                f.write(_png_bytes(100, 100, bytes((43, 98, 235)) * hot + bytes((243, 244, 247)) * (10000 - hot), 3, [1]))
            rep = Report()
            judge_area([p], _Opts(), rep)
            areas.append(rep.fails)
        check("(45) 상한 경계: 채도 C 0.0320 PASS · 0.0321 FAIL / 유채 면적 5.00% PASS · 5.01% FAIL",
              at.fails == 0 and over.fails == 1 and any("--n-9" in ln and "0.0321" in ln and "FAIL" in ln
                                                         for ln in over.lines) and areas == [0, 1],
              "채도 %d·%d · 면적 %s" % (at.fails, over.fails, areas))

    # 규범 수치·도식 쌍 원본 ↔ 도구 상수·쌍 파일(원본 = web_page.md §1·§7 · html_css.md §6-1)
    wp, hc = _find_visual_doc("web_page.md"), _find_visual_doc("html_css.md")
    pairs_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "color_pairs_diagram.json")
    if wp is None:
        print("[건너뜀] (46) 규범 수치 원본 web_page.md 를 못 찾음 — 설치본·패키지 저장소에서만 대조")
    else:
        norms = _web_page_norms(wp)
        want = {"채도 상한": DEFAULT_MAX_CHROMA, "면적 상한": DEFAULT_AREA_MAX, "면적 픽셀 임계": DEFAULT_AREA_CHROMA}
        off = {k: v for k, v in norms.items() if len(v) != (2 if k != "면적 픽셀 임계" else 1) or any(x != want[k] for x in v)}
        check("(46) 도구 상수 = web_page.md 규범 수치(§1 채도·면적 상한 · §7 G3 · 면적 픽셀 임계)", not off,
              "%s — 문서 %s · 도구 %s" % (wp, off, want))
    if hc is None or wp is None or not os.path.isfile(pairs_path):
        print("[건너뜀] (47)(48) html_css.md·web_page.md·color_pairs_diagram.json 을 못 찾음 — 설치본·패키지 저장소에서만 대조")
    else:
        doc_pairs, neutral, decor, block61, measured = _html_css_61(hc)
        file_pairs, file_chroma, file_forbid = load_pairs_file(pairs_path)
        got = {(p.fg, p.bg, p.min) for p in file_pairs}
        check("(47) 쌍 파일 = html_css.md §6-1 판정 칸(쌍·최소비 · chroma_tokens = 중성 변수 · forbid_refs = 장식 단계 × 중성 변수)",
              len(doc_pairs) >= 20 and got == doc_pairs and len(got) == len(file_pairs)
              and set(file_chroma) == neutral and len(file_chroma) == len(neutral) and file_forbid is not None
              and set(file_forbid[0]) == decor and set(file_forbid[1]) == neutral,
              "쌍 파일만 %s · 문서만 %s · chroma %s/%s · forbid %s/%s"
              % (sorted(got - doc_pairs), sorted(doc_pairs - got), file_chroma, sorted(neutral), file_forbid, sorted(decor)))
        sheet = Sheet(parse_css(_web_page_section5(wp)[0] + "\n" + block61, set()), set())
        lows = []
        for st in (STATE_LIGHT, STATE_DARK):
            res = Resolver(sheet.props(st))
            for mn in (3.0, 4.5):
                vals = [(contrast(res.color(p.fg)[0].rgb, res.color(p.bg)[0].rgb), p.name) for p in file_pairs if p.min == mn]
                lows.append(min(vals) if vals else (0.0, ""))
        doc_low = (measured.groups() if measured else ())
        calc = ("%.2f" % lows[0][0], lows[0][1], "%.2f" % lows[2][0], lows[2][1], "%.2f" % lows[1][0], "%.2f" % lows[3][0])
        check("(48) html_css.md §6-1 블록 + web_page.md §5 로 다시 잰 쌍 파일 최저값 = §6-1 실측 행(3:1 라이트·다크 · 글자 라이트·다크)",
              doc_low == calc, "문서 %s · 계산 %s" % (doc_low, calc))

    passed = sum(results)
    print("\nselftest: %d/%d PASS" % (passed, len(results)))
    return 0 if passed == len(results) else 1


# ═══════════════════════════ CLI ═══════════════════════════

def main(argv=None):
    ap = argparse.ArgumentParser(
        description="색 토큰 게이트 — 대비(WCAG 2.x)·구조색 채도(OKLCH C)·유채 면적(PNG)·사용처를 라이트·다크로 판정.",
        epilog="종료코드: 0 = 판정한 축 전건 PASS · 1 = FAIL 1건 이상 또는 판정 안 됨(판정한 대비 쌍·채도 토큰 0) · "
               "2 = 입력·사용 오류 — 돌리지 않은 축은 [판정 축] 줄에 미실행으로 적는다")
    ap.add_argument("file", nargs="?", help="CSS 또는 HTML(<style>) 파일")
    ap.add_argument("--pair", action="append", default=[], metavar="이름:전경:배경:최소비",
                    help="대비 쌍 추가(반복) · 전경·배경 = 토큰 이름(-- 생략 가능) 또는 색 값")
    ap.add_argument("--pairs", action="append", default=[], metavar="파일.json",
                    help="쌍 파일(반복) — pairs · chroma_tokens · forbid_refs")
    ap.add_argument("--no-default-pairs", action="store_true", help="표준 이름 기준 11쌍 자동 적용 끔")
    ap.add_argument("--max-chroma", type=float, default=DEFAULT_MAX_CHROMA,
                    help="구조색 채도 상한 C (기본 %(default)s)")
    ap.add_argument("--chroma-tokens", default=None, metavar="a,b,…",
                    help="채도 판정 토큰(기본 = 어느 모드에든 정의된 n-0…n-10)")
    ap.add_argument("--area", action="append", default=[], metavar="스크린샷.png",
                    help="유채 면적 판정할 렌더 스크린샷(반복)")
    ap.add_argument("--area-chroma", type=float, default=DEFAULT_AREA_CHROMA,
                    help="유채로 셀 픽셀 C 임계(기본 %(default)s)")
    ap.add_argument("--area-max", type=float, default=DEFAULT_AREA_MAX,
                    help="유채 면적 상한 %% (기본 %(default)s)")
    ap.add_argument("--no-usage", action="store_true", help="사용처 검사(장식 단계 글자·틴트 테두리) 끔 — 미실행으로 적는다")
    ap.add_argument("--decor-tokens", default=None, metavar="a,b,…",
                    help="장식 단계 토큰(기본 n-5,n-6) — color·fill·stroke 가 가리키면 FAIL")
    ap.add_argument("--tint-tokens", default=None, metavar="a,b,…",
                    help="틴트 토큰(기본 = 이름이 -bg 로 끝나고 n-* 를 가리키지 않는 토큰) — 배경인데 같은 규칙에 "
                         "테두리 없으면 경고")
    ap.add_argument("--fg", help="직접 모드 전경색")
    ap.add_argument("--bg", help="직접 모드 배경색")
    ap.add_argument("--min", type=float, default=None, help="직접 모드 최소 대비(주면 판정)")
    ap.add_argument("--selftest", action="store_true", help="자가 시험")
    args = ap.parse_args(argv)

    if args.selftest:
        return _selftest()
    if args.fg or args.bg:
        if not (args.fg and args.bg):
            sys.stderr.write("[ERROR] 직접 모드는 --fg 와 --bg 가 둘 다 필요하다.\n")
            return 2
        return direct_mode(args)
    if not args.file and not args.area:
        ap.print_usage(sys.stderr)
        sys.stderr.write("[ERROR] 판정할 파일(CSS·HTML) 또는 --area 스크린샷이 필요하다.\n")
        return 2

    rep = Report()
    try:
        extra, extra_chroma, forbid = [], [], []
        for s in args.pair:
            extra.append(parse_pair_arg(s))
        for pf in args.pairs:
            ps, ch, fb = load_pairs_file(pf)
            extra += ps
            extra_chroma += ch
            if fb:
                forbid.append(fb)
        opts = _Opts(no_default_pairs=args.no_default_pairs, extra_pairs=extra,
                     max_chroma=args.max_chroma,
                     chroma_tokens=_token_list(args.chroma_tokens),
                     extra_chroma=extra_chroma, forbid=forbid,
                     area_chroma=args.area_chroma, area_max=args.area_max,
                     usage=not args.no_usage, decor_tokens=_token_list(args.decor_tokens),
                     tint_tokens=_token_list(args.tint_tokens))
        if args.file:
            try:
                with open(args.file, encoding="utf-8-sig") as f:
                    text = f.read()
            except OSError as e:
                raise InputError("파일 읽기 실패: %s (%s)" % (args.file, e))
            except UnicodeDecodeError as e:
                raise InputError(_not_utf8("입력 파일", args.file, e))
            judge_file(args.file, text, opts, rep)
        elif extra or forbid:
            raise InputError("--pair/--pairs 는 판정할 CSS·HTML 파일이 있어야 한다.")
        else:
            rep.out("=== 색 토큰 게이트 — 면적만 ===")
            for axis in ("대비", "채도", "사용처"):
                rep.axis(axis, UNRUN, "CSS·HTML 파일 없음 — 면적만")
        if args.area:
            judge_area(args.area, opts, rep)
        else:
            rep.out("")
            rep.out("[유채 면적] 미실행(--area 없음) — 렌더 스크린샷을 --area 로 주면 판정(web_page.md §7 G3 · 면적 해석)")
            rep.axis("유채 면적", UNRUN, "--area 없음")
    except InputError as e:
        for ln in rep.lines:
            print(ln)
        sys.stderr.write("[ERROR] %s\n" % e)
        return 2

    for ln in rep.lines:
        print(ln)
    if rep.warns:
        print("")
        print("[경고 %d — 판정에는 넣지 않음 · 해소 대상]" % len(rep.warns))
        for w in rep.warns:
            print("  ~ " + w)
    if rep.notes:
        print("")
        print("[알림 %d — 판정 밖·근사 · 사람 확인]" % len(rep.notes))
        for n in rep.notes:
            print("  · " + n)
    print("")
    unjudged, unrun = rep.axis_names(UNJUDGED), rep.axis_names(UNRUN)
    print("[판정 축] " + " · ".join(
        "%s %s%s" % (a, rep.axes[a][0], "(%s)" % rep.axes[a][1] if rep.axes[a][1] else "") for a in AXES if a in rep.axes))
    verdict = "FAIL" if rep.fails else ("판정 안 됨" if unjudged else "PASS")
    code = 1 if (rep.fails or unjudged) else 0
    tail = ""
    if unjudged:
        tail += (" · 판정 안 됨 축(%s)은 PASS 아님 — 표준 토큰 이름(web_page.md §5)을 쓰거나 --chroma-tokens·--pair 로 "
                 "넘긴다" % "·".join(unjudged))
    if unrun:
        tail += " · 미실행 축(%s)은 통과 아님" % "·".join(unrun)
    if rep.warns:
        tail += " · 경고는 전달 전 해소"
    print("[요약] FAIL %d · 경고 %d · 알림 %d → %s (exit %d)%s"
          % (rep.fails, len(rep.warns), len(rep.notes), verdict, code, tail))
    return code


if __name__ == "__main__":
    sys.exit(main())

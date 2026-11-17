# -*- coding: utf-8 -*-
"""판독↔엔진 대조 — Claude 판독본(판독 서브 산출) vs OCR 엔진(PaddleOCR).

두 방향을 모두 본다. 한쪽만 보면 절반을 놓친다. (EasyOCR 배제 → 엔진 Paddle 단일,
판독↔엔진 2-way. --ocr 을 2개 이상 줘도 동작하나 통상은 paddle 하나.)

  (A) 오독·환각 후보 — Claude 판독본에만 있고 OCR 어디에도 없는 조각
  (B) 누락 후보     — OCR 이 읽었는데 Claude 판독본에 없는 조각

사용:
    python crosscheck.py --mine 추출본.md --ocr paddle=./ocr_paddle
    python crosscheck.py --mine a.md --mine b.js --ocr paddle=./ocr_paddle --min-len 12

--mine 에 넣는 것은 판독 서브(`bada-image-reader`)가 낸 추출본이다. master 가 스스로 판독해 만든
파일이 아니다(헌법 「이미지 판독」 = master 직접 판독 X). 플래그 이름은 기존 호출 호환을
위해 유지한다.

--ocr 는 `이름=폴더` 형태다(통상 paddle 하나). 폴더 안의 `*.txt` 를 전부 이어 붙여 쓴다.
배치 스크립트(paddleocr_parallel.py)가 같은 폴더에 남긴 `<이름>.lines.json`(줄마다 text·score·box)이
있으면 (B) 후보 옆에 그 줄의 인식 점수·쪽 이미지·상자 좌표를 보조로 붙인다.

(B) 후보에는 이미지 경계에서 잘린 글자 조각에서 나온 엔진 결과(엉뚱한 글자·낮은 점수)가 섞일 수 있다.
그것을 가려 버리는 것은 이미지를 보는 재확인 판독 서브 몫이다 — master 는 이미지를 보지 않고 이 요약만
넘긴다. 점수·상자 좌표(가장자리에 붙은 상자)는 그 판단의 보조 근거일 뿐 자동으로 빼지 않는다.

★ 이 스크립트의 요약이 master 의 유일한 검증 근거가 되는 자리에 있다(master 는 판독하지
  않고 이 요약만 읽는다 — 판독·재확인은 서브 몫). 그래서 "비교 대상이 0건" 인 상태를
  절대 조용히 통과시키지 않는다 — 0건이면 경고하고 종료코드 2 로 끝낸다(파일·폴더가 없으면 1).
  대조를 안 한 것과 대조해서 이상이 없는 것은 다르다.
"""
import io as _io
import sys as _sys

# Windows 기본 콘솔은 cp949 다. 한글·기호를 찍으면 UnicodeEncodeError 로 죽는다.
if hasattr(_sys.stdout, 'reconfigure'):
    _sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    _sys.stderr.reconfigure(encoding='utf-8', errors='replace')

import argparse
import glob
import json
import os
import re
import sys

HANGUL = re.compile(r'[가-힣]')
QUOTED = re.compile(r'"([^"\n]*[가-힣][^"\n]*)"')
LIST_PREFIX = re.compile(r'^[#>*\-\d.\s|`]+')


def norm(s):
    return re.sub(r'\s+', '', s)


def load_ocr(folder):
    """(정규화본, 원문, 파일수) 를 돌려준다.

    (A) 는 공백 무시 비교라 정규화본을, (B) 는 라인 단위라 원문을 쓴다.
    """
    parts = []
    for f in sorted(glob.glob(os.path.join(folder, '*.txt'))):
        with open(f, encoding='utf-8', errors='replace') as fp:
            parts.append(fp.read())
    raw = '\n'.join(parts)
    return norm(raw), raw, len(parts)


def load_lines(folder):
    """곁 파일(<이름>.lines.json)에서 정규화한 줄 글자 → (점수, 쪽 이미지, 상자) 첫 출현. 없거나 못 읽으면 빈 dict."""
    info = {}
    for f in sorted(glob.glob(os.path.join(folder, '*.lines.json'))):
        try:
            with open(f, encoding='utf-8') as fp:
                data = json.load(fp)
            for ln in data.get('lines') or []:
                key = norm(str(ln.get('text') or ''))
                if key and key not in info:
                    info[key] = (ln.get('score'), data.get('image'), ln.get('box'))
        except (OSError, ValueError, AttributeError):
            continue
    return info


def describe(info):
    score, image, box = info
    parts = []
    if isinstance(score, (int, float)):
        parts.append(f'점수 {score:.2f}')
    if image:
        parts.append(str(image))
    if isinstance(box, list) and len(box) == 4:
        parts.append('상자 ' + ','.join(str(v) for v in box))
    return '[' + ' · '.join(parts) + ']' if parts else ''


def extract_fragments(text, min_len):
    """따옴표 리터럴 + 한글이 든 일반 라인을 모두 후보로 잡는다."""
    frags = set()
    for lit in QUOTED.findall(text):
        if len(norm(lit)) >= min_len:
            frags.add(lit.strip())
    for line in text.splitlines():
        s = line.strip()
        if not s or not HANGUL.search(s):
            continue
        s = LIST_PREFIX.sub('', s).strip()
        if len(norm(s)) >= min_len:
            frags.add(s)
    return sorted(frags)


def ngram_hit(needle, hay, n=8, thresh=0.5):
    key = norm(needle)
    if not key:
        return True
    if len(key) < n:
        return key in hay
    step = max(1, n // 2)
    grams = [key[i:i + n] for i in range(0, len(key) - n + 1, step)]
    if not grams:
        return key in hay
    hit = sum(1 for g in grams if g in hay)
    return hit / len(grams) >= thresh


def main():
    ap = argparse.ArgumentParser(description='Claude 판독본(판독 서브 산출)과 OCR 엔진 결과를 양방향 대조')
    ap.add_argument('--mine', action='append', required=True,
                    help='Claude 판독본 — 판독 서브가 낸 추출본 파일 (여러 번 지정 가능)')
    ap.add_argument('--ocr', action='append', required=True, metavar='이름=폴더',
                    help='OCR 엔진 결과 폴더. `paddle=./ocr_paddle` 형태 (통상 paddle 하나).')
    ap.add_argument('--min-len', type=int, default=10, help='비교할 조각의 최소 길이 (공백 제외, 기본 10)')
    ap.add_argument('--show', type=int, default=40, help='방향별 출력 개수 (기본 40)')
    args = ap.parse_args()

    engines = {}
    engines_raw = {}
    line_info = {}
    for spec in args.ocr:
        if '=' not in spec:
            sys.exit(f'--ocr 는 `이름=폴더` 형태여야 한다: {spec}')
        name, folder = spec.split('=', 1)
        if not os.path.isdir(folder):
            sys.exit(f'OCR 폴더가 없다: {folder}')
        text, raw, nfile = load_ocr(folder)
        engines[name] = text
        engines_raw[name] = raw
        for k, v in load_lines(folder).items():
            line_info.setdefault(k, v)
        print(f'OCR 로드 - {name}: {nfile}개 파일 / {len(text)}자')
        if nfile == 0:
            print(f'  ! {name} 폴더에 *.txt 가 없다. 엔진 배치가 끝났는지 확인한다.')

    if len(engines) < 1:
        print('! 엔진 결과가 없다. 판독↔엔진 대조 불가.')
    elif len(engines) == 1:
        print('· 엔진 1종(Paddle) — 판독↔엔진 2-way 대조(기본 모드).')
    if all(len(t) == 0 for t in engines.values()):
        print('! OCR 결과가 전부 비어 있다 - 대조할 것이 없다. 종료코드 2', file=sys.stderr)
        sys.exit(2)

    exit_code = 0
    for path in args.mine:
        if not os.path.exists(path):
            print(f'[{path}] 파일 없음 - skip')
            exit_code = max(exit_code, 1)
            continue
        with open(path, encoding='utf-8', errors='replace') as f:
            mine_raw = f.read()
        mine_norm = norm(mine_raw)
        frags = extract_fragments(mine_raw, args.min_len)

        print(f'\n===== {os.path.basename(path)} =====')
        if not frags:
            # 대조 대상이 없다는 것은 통과가 아니다. 조용히 넘기지 않는다.
            print(f'  ! 비교 가능한 한글 조각 0개 (min-len={args.min_len}). 대조하지 않았다.')
            exit_code = max(exit_code, 2)
            continue

        only_mine = [fr for fr in frags
                     if not any(ngram_hit(fr, t) for t in engines.values())]
        print(f'  (A) 오독·환각 후보 - 판독본 조각 {len(frags)}개 중 OCR 어디에도 없는 것: {len(only_mine)}')
        for m in only_mine[:args.show]:
            print(f'      ? {m[:60]}')

        common = None
        for raw in engines_raw.values():
            lines = {norm(l) for l in re.split(r'[\r\n]+', raw) if len(norm(l)) >= args.min_len}
            common = lines if common is None else (common & lines)
        common = common or set()
        only_ocr = [c for c in sorted(common) if not ngram_hit(c, mine_norm)]
        print(f'  (B) 누락 후보 - OCR {len(engines)}종 공통 조각 {len(common)}개 중 판독본에 없는 것: {len(only_ocr)}')
        if only_ocr:
            print('      (경계에서 잘린 조각의 엔진 결과가 섞일 수 있다 — 가려 버리는 것은 이미지를 보는 재확인 판독 서브 몫 · 점수·상자는 보조 근거)')
        for m in only_ocr[:args.show]:
            extra = describe(line_info[m]) if m in line_info else ''
            print(f'      ! {m[:60]}' + (f'  {extra}' if extra else ''))

    sys.exit(exit_code)


if __name__ == '__main__':
    main()

# -*- coding: utf-8 -*-

import io as _io, sys as _sys
# Windows 기본 콘솔은 cp949 다. 한글·기호를 찍으면 UnicodeEncodeError 로 죽는다.
if hasattr(_sys.stdout, 'reconfigure'):
    _sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    _sys.stderr.reconfigure(encoding='utf-8', errors='replace')

import os
os.environ['FLAGS_use_mkldnn'] = '0'
os.environ['FLAGS_enable_pir_api'] = '0'
os.environ['GLOG_minloglevel'] = '2'
os.environ['OMP_NUM_THREADS'] = '1'  # OpenBlas 빌드 deadlock 회피 (OMP>1 + OpenBlas = hang 실측)
import json, sys
from multiprocessing import Pool

_ocr = None
_out = None

def init_worker(out):
    global _ocr, _out
    _out = out
    try:
        import psutil
        psutil.Process().nice(psutil.BELOW_NORMAL_PRIORITY_CLASS)  # 시스템에 CPU 양보
    except Exception:
        pass
    from paddleocr import PaddleOCR
    for kwargs in (
        dict(lang='korean', text_detection_model_name='PP-OCRv5_mobile_det', text_recognition_model_name='korean_PP-OCRv5_mobile_rec', use_doc_orientation_classify=False, use_doc_unwarping=False, use_textline_orientation=False, enable_mkldnn=False),
        dict(lang='korean', text_detection_model_name='PP-OCRv5_mobile_det', use_textline_orientation=False, enable_mkldnn=False),
        dict(lang='korean', enable_mkldnn=False),
        dict(lang='korean'),
    ):
        try:
            _ocr = PaddleOCR(**kwargs); break
        except TypeError:
            continue

# 쪽 이미지로 받는 확장자: rotate_exif.py 기본 확장자와 같다(PDF 스캔을 뽑은 쪽 이미지 = PNG).
IMAGE_EXTS = ('.jpg', '.jpeg', '.png', '.webp')


def _as_list(v):
    """numpy 배열·목록 → 파이썬 목록(없으면 빈 목록)."""
    if v is None:
        return []
    tolist = getattr(v, 'tolist', None)
    return tolist() if callable(tolist) else list(v)


def _num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def _result_dict(r):
    """predict 결과 한 개 → 결과 키가 든 dict. 결과 객체(dict)나 json 속성({'res': {...}})을 받는다."""
    d = r if isinstance(r, dict) else getattr(r, 'json', None) or {}
    if isinstance(d, dict) and 'rec_texts' not in d and isinstance(d.get('res'), dict):
        d = d['res']
    return d if isinstance(d, dict) else {}


def _box_of(box, poly):
    """줄 위치 = rec_boxes 한 행 [x_min, y_min, x_max, y_max] · 없으면 rec_polys 꼭짓점의 최소·최대 · 못 읽으면 None."""
    try:
        b = _as_list(box)
        if len(b) == 4:
            return [int(x) for x in b]
        pts = _as_list(poly)
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        return [int(min(xs)), int(min(ys)), int(max(xs)), int(max(ys))] if pts else None
    except (TypeError, ValueError, IndexError):
        return None


def process(f):
    """이미지 한 장 → <이름>.txt(줄마다 인식 글자) + <이름>.lines.json(줄마다 text·score·box).
    (이름, 상태 ok|empty|error, 사유 또는 None) 을 돌려준다: 사유는 부모가 stderr 에 남긴다."""
    global _ocr, _out
    text, lines, reason = None, [], None
    try:
        res = _ocr.predict(f)
        texts, seen = [], False
        for r in res:
            d = _result_dict(r)
            if 'rec_texts' not in d:
                continue
            seen = True   # 결과 키가 있으면 글자 0줄이어도 읽은 것이다(빈 장): 아래 ocr() 로 다시 읽지 않는다
            rt = d.get('rec_texts') or []
            scores = _as_list(d.get('rec_scores'))
            boxes = _as_list(d.get('rec_boxes'))
            polys = _as_list(d.get('rec_polys'))
            for i, t in enumerate(rt):
                texts.append(t)
                lines.append({'text': t,
                              'score': _num(scores[i]) if i < len(scores) else None,
                              'box': _box_of(boxes[i] if i < len(boxes) else None,
                                             polys[i] if i < len(polys) else None)})
        if seen:
            text = "\n".join(texts)
    except Exception as e:
        text, lines = None, []
        reason = 'predict 실패: {}: {}'.format(type(e).__name__, e)
    if text is None:
        try:
            res = _ocr.ocr(f)
            texts, lines = [], []
            for page in (res or []):
                if isinstance(page, dict):   # 결과 키 없는 새 판 결과 객체: 줄 목록이 아니다
                    continue
                for line in (page or []):
                    try:
                        t = line[1][0]
                    except Exception:
                        continue
                    texts.append(t)
                    try:
                        score, box = _num(line[1][1]), _box_of(None, line[0])
                    except Exception:
                        score, box = None, None
                    lines.append({'text': t, 'score': score, 'box': box})
            text = "\n".join(texts)
            if reason:
                reason += ' (ocr() 로 대신 읽음)'
        except Exception as e:
            text = f"__ERROR__ {e}"
            reason = (reason + ' · ' if reason else '') + 'ocr() 실패: {}: {}'.format(type(e).__name__, e)
    base = os.path.splitext(os.path.basename(f))[0]
    with open(os.path.join(_out, base + ".txt"), "w", encoding="utf-8") as fp:
        fp.write(text)
    if text.startswith("__ERROR__"):
        return base, 'error', reason
    with open(os.path.join(_out, base + ".lines.json"), "w", encoding="utf-8") as fp:
        json.dump({'image': os.path.basename(f), 'lines': lines}, fp, ensure_ascii=False)
    return base, ('ok' if text.strip() else 'empty'), reason

if __name__ == "__main__":
    src, out = sys.argv[1], sys.argv[2]
    try:
        import psutil as _ps
        _default_w = max(1, (_ps.cpu_count(logical=False) or 2) // 2)  # 기본 = 물리코어 ÷ 2 (CPU 절반)
    except Exception:
        _default_w = 4
    nworkers = int(sys.argv[3]) if len(sys.argv) > 3 else _default_w
    if not os.path.isdir(src):
        sys.exit(f'src 폴더가 없다: {src}')
    os.makedirs(out, exist_ok=True)
    files = sorted(os.path.join(src, n) for n in os.listdir(src)
                   if n.lower().endswith(IMAGE_EXTS) and os.path.isfile(os.path.join(src, n)))
    # 조용히 0장으로 끝내면 "처리 완료" 로 오해된다. 확장자 불일치가 흔한 원인이다.
    if not files:
        sys.exit(f'대상 이미지 0장: {src} 에 {IMAGE_EXTS} 확장자가 없다')
    def _ok(f):
        p = os.path.join(out, os.path.splitext(os.path.basename(f))[0] + ".txt")
        if os.path.exists(p):
            try:
                c = open(p, encoding="utf-8").read()
                return bool(c.strip()) and "__ERROR__" not in c
            except Exception:
                return False
        return False
    files = [f for f in files if not _ok(f)]  # 이미 정상 처리분 skip
    print(f"files(남은 것): {len(files)}  workers: {nworkers}", flush=True)
    done = 0
    count = {'ok': 0, 'empty': 0, 'error': 0}
    if files:
        with Pool(nworkers, initializer=init_worker, initargs=(out,)) as p:
            for base, status, reason in p.imap_unordered(process, files):
                done += 1
                count[status] += 1
                print(f"[{done}/{len(files)}] {base}", flush=True)
                if reason:
                    print(f"! {base}: {reason}", file=sys.stderr, flush=True)
    print(f"정상 {count['ok']} · 빈 결과 {count['empty']} · 실패 {count['error']} (빈 결과·실패는 다시 돌리면 다시 처리한다)", flush=True)
    print("DONE paddleocr_par", flush=True)
    if files and count['error'] == len(files):
        sys.exit(f'이번에 처리한 {len(files)}장이 전부 실패했다: 위 사유(stderr)를 확인한다')

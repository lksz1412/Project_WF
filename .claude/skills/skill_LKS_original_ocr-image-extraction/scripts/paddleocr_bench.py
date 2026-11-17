# -*- coding: utf-8 -*-

import io as _io, sys as _sys
# Windows 기본 콘솔은 cp949 다. 한글·기호를 찍으면 UnicodeEncodeError 로 죽는다.
if hasattr(_sys.stdout, 'reconfigure'):
    _sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    _sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# 단일 프로세스 실측: server det 1워커의 peak 메모리 + 시간
import os
os.environ['FLAGS_use_mkldnn'] = '0'
os.environ['FLAGS_enable_pir_api'] = '0'
os.environ['GLOG_minloglevel'] = '2'
os.environ['OMP_NUM_THREADS'] = '1'
import sys, time, threading, psutil
from paddleocr import PaddleOCR

img = sys.argv[1]
proc = psutil.Process()
peak = [0.0]
run = [True]
def mon():
    while run[0]:
        try:
            peak[0] = max(peak[0], proc.memory_info().rss)
        except Exception:
            pass
        time.sleep(0.1)
threading.Thread(target=mon, daemon=True).start()

base_mem = proc.memory_info().rss / 1e9
t0 = time.time()
_det = sys.argv[2] if len(sys.argv) > 2 else None
_kw = dict(lang='korean', use_doc_orientation_classify=False,
           use_doc_unwarping=False, use_textline_orientation=False, enable_mkldnn=False)
if _det:
    _kw['text_detection_model_name'] = _det
_rec = sys.argv[3] if len(sys.argv) > 3 else None
if _rec:
    _kw['text_recognition_model_name'] = _rec
print(f"[det = {_det or 'default'} | rec = {_rec or 'default'}]", flush=True)
ocr = PaddleOCR(**_kw)
t_load = time.time() - t0
mem_loaded = proc.memory_info().rss / 1e9

t1 = time.time()
res = ocr.predict(img)
t_infer = time.time() - t1
run[0] = False
time.sleep(0.2)
mem_peak = peak[0] / 1e9

ntext = 0
for r in res:
    d = r if isinstance(r, dict) else getattr(r, 'json', None) or {}
    if isinstance(d, dict) and d.get('rec_texts'):
        ntext += len(d['rec_texts'])

print("=== PaddleOCR 단일 프로세스 실측 (server det, 경량 파이프라인, OMP=1) ===")
print(f"이미지        : {os.path.basename(img)}")
print(f"기본 메모리   : {base_mem:.2f} GB")
print(f"모델 로드후   : {mem_loaded:.2f} GB   (로드 {t_load:.1f}s)")
print(f"PEAK 메모리   : {mem_peak:.2f} GB   (추론 {t_infer:.1f}s)")
print(f"인식 라인수   : {ntext}")
print(f"--> 워커당 예산 기준 PEAK = {mem_peak:.2f} GB / 장당 시간 = {t_load + t_infer:.1f}s (로드+추론)")

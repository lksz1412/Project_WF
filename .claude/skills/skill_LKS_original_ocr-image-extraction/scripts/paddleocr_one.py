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
os.environ['OMP_NUM_THREADS'] = '1'
import sys
from paddleocr import PaddleOCR

img, out = sys.argv[1], sys.argv[2]
ocr = PaddleOCR(lang='korean', use_doc_orientation_classify=False,
                use_doc_unwarping=False, use_textline_orientation=False, enable_mkldnn=False)
text = None
try:
    res = ocr.predict(img)
    texts = []
    for r in res:
        d = r if isinstance(r, dict) else getattr(r, 'json', None) or {}
        rt = d.get('rec_texts') if isinstance(d, dict) else None
        if rt:
            texts.extend(rt)
    if texts:
        text = "\n".join(texts)
except Exception:
    text = None
if text is None:
    try:
        res = ocr.ocr(img)
        texts = []
        for page in (res or []):
            for line in (page or []):
                try:
                    texts.append(line[1][0])
                except Exception:
                    pass
        text = "\n".join(texts)
    except Exception as e:
        text = f"__ERROR__ {e}"
base = os.path.splitext(os.path.basename(img))[0]
with open(os.path.join(out, base + ".txt"), "w", encoding="utf-8") as fp:
    fp.write(text)
print("OK", base, "len=", len(text))

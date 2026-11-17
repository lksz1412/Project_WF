# wheels/ — PaddleOCR GPU 오프라인 휠 슬롯

제한 네트워크에서는 paddle 본체 GPU 휠을 CDN에서 받기가 극히 느리다(실측 ~130KB/s → 552MB에 ~70분·timeout). 그래서 미리 받은 휠을 여기 두면 `scripts/setup_ocr_engines_windows.ps1`이 **로컬 설치**로 우회한다(없으면 인덱스에서 시도).

## 넣는 파일

- `paddlepaddle_gpu-<버전>-cp<파이썬>-cp<파이썬>-win_amd64.whl`
  - 이 PC 조합 예: `paddlepaddle_gpu-3.3.1-cp312-cp312-win_amd64.whl` (CUDA 12.6 / Python 3.12).
  - 받는 곳: `https://www.paddlepaddle.org.cn/packages/stable/<cuXXX>/paddlepaddle-gpu/`

## 주의

- 휠은 **환경 특정적**이다(CUDA 태그·파이썬 cp 버전·win_amd64). 다른 조합 PC엔 안 맞으니, 대상 PC 조합에 맞는 휠을 넣는다.
- `.whl`은 git에 커밋하지 않는다(`.gitignore` — 수백 MB). 로컬 오프라인 캐시로만 쓴다.
- OCR 엔진 설치는 **opt-in**(스크립트 직접 실행). 패키지 기본 설치엔 포함되지 않는다(문서 base만 자동).

# OCR 엔진 운용 (로컬 도구 교차검증)

`SKILL.md`의 **판독**(Claude 비전)을 보조하는 **로컬 OCR 엔진(PaddleOCR)** 운용 문건. 환경 탐색·셋업·GPU·워커수 산정·병렬화 함정·판독↔엔진 대조를 다룬다. **대량(수십 장 이상) 처리에 들어가기 전에 이 문건을 정독한다.**

## 대원칙

- **엔진 위치는 규모가 가른다**(원본 = `SKILL.md` §규모·화질 분기) — **소량·정밀·코드 밀집** = 판독 3단계 cross-check 가 1차·엔진은 사후 교차검증(2차) / **대량(수십 장+)·양호** = 엔진(Paddle)이 메인 추출·판독은 저신뢰(`rec_scores` 임계 미만)·불일치 지점만. 어느 경로든 **엔진 결과를 무조건 진실로 두지 않는다**(엔진도 틀린다 — 저신뢰·불일치는 판독이 확인).
- **토큰 경제**: 엔진 추론은 **로컬 자원**(사전학습 가중치 + 사용자 CPU/GPU)으로 돈다 — master 컨텍스트 토큰과 무관하다. 대조도 스크립트가 로컬에서 하고 master는 **"불일치 N건" 요약만** 읽는다. → 수십~수백 장의 육안 재대조는 엔진+스크립트에 위임한다(master 직접 판독은 토큰 문제 이전에 금지 대상 — 헌법 「이미지 판독」).
- **원본 불가침**: 회전·리사이즈·크롭은 사본(scratchpad)에만 한다. **리사이즈로 정확도를 깎지 않는다** — 속도는 GPU·병렬로 해결한다.

## 환경 판별 — CPU-only vs GPU (가장 먼저)

이 문건은 **CPU만 있는 환경**과 **NVIDIA GPU + CUDA 환경**을 둘 다 커버한다. 순서:

1. **GPU 빌드 유효성부터 판별**(§GPU 가속): `paddle.is_compiled_with_cuda()`가 True면 → **GPU 경로**(장당 ~0.1초(대형·다단계 ~1.65초), CPU 병렬 불필요).
2. False(= 라이브러리가 CPU 빌드이거나 GPU 없음)면 → **CPU 경로**: §사양 기반 옵션 산정 + §병렬화 + ⚠ 실측 함정(OMP=1·워치독)을 따른다.

> **CPU 경로** 옵션은 실측으로 취합한 확정분이다. **GPU 경로**는 PC마다 GPU·CUDA가 제각각이라 일괄 불가 — 기준은 **설치된 CUDA에 맞는 구조변화 최소 wheel**(설치 CUDA 이하 최근접 stable 우선, 없는 최신 아키텍처만 dev 우회)이고, GPU/CUDA 미설치 PC는 **CUDA 12.8+**를 깐다. 2026-08-10 양 끝단 실측(A 일반 RTX4050·cu126 / B Blackwell sm_120·cu129)으로 **검증 완료** — 절차·함정·측정치는 아래 **§Windows GPU 셋업 — 실측 레시피**.

## 엔진 선택 (한글 + 회전사진 + 코드 기준 실측 순위)

| 엔진 | 강점/약점 | 판정 |
|---|---|---|
| **PaddleOCR** (`korean_PP-OCRv5`) | `§`·diff `±`마커·중점(·)·한글 전부 정확 | **유일 주력** |
| ~~EasyOCR~~ (제외) | 한글은 읽으나 `§`→`8`/`81`, `±`마커 놓침, 오탈자 — 거짓 불일치만 양산 | 배제 |
| rapidocr (onnx) | 회전·밀집 이미지서 한글이 한자로 깨짐 | 회전사진 부적합 |
| Windows.Media.Ocr | 내장이나 코드/기호 약함. **pwsh(PS7)에서 WinRT 로딩 실패 → PS 5.1 필요** | 비권장 |

- 엔진은 **PaddleOCR 단일**이다(EasyOCR 은 정확도 미달로 배제 — 거짓 불일치가 대조 비용만 키웠다). 대조는 **판독(Claude) ↔ 엔진(Paddle) 2-way**.
- 문서가 **코드/diff/기호 밀집**이면 PaddleOCR을 반드시 쓴다(`§`·마커·특수문자 때문).
- **판독과 엔진이 함께 지적한 곳**을 우선 후보로 본다. 한쪽 단독 지적은 정밀 재검 후 반영(엔진 단독 미매칭 다수는 대개 엔진 부정확).

## 환경 탐색 (사용자가 이미 설치한 엔진 찾기)

표준 위치에 없어도 **홈 캐시 흔적**으로 찾는다:

- `~/.paddlex/official_models/`(korean_PP-OCRv5 등) → 설치·실행 이력.
- **다른 python에 설치됐을 수 있다**(사용자 표현 "샌드박스"): `py -0p`로 인터프리터 목록 → `py -3.10 -m pip list | Select-String 'ocr|paddle'`.
- 캐시는 홈 공유라, 캐시만 있고 현재 python엔 패키지가 없을 수 있다 → 그 패키지가 있는 python 버전을 찾아 그걸로 실행한다.

## 설치 (미설치 시 유도 — 인스톨러가 강제로 깔지 않는다)

패키지 인스톨러는 base 문서 라이브러리만 자동 설치하고 **OCR 엔진은 깔지 않는다**(paddle+모델이 GB급이라 상시 부담). 이미지 대량 판독이 실제로 필요해진 시점에만 이 절을 따라 설치한다. 설치할 패키지 = `paddleocr` · `paddlepaddle`(GPU 경로면 `paddlepaddle-gpu`) · `psutil`. 위 §환경 탐색으로 이미 있는지 먼저 확인하고, 없을 때만 아래로 설치한다.

### 1. GPU 유무·VRAM 판정 (설치 분기의 근거)

- `nvidia-smi` → GPU 존재 + VRAM 용량(예: 출력의 `8192MiB`). 명령이 없거나 실패면 GPU 없음으로 본다.
- 이미 paddle 이 있으면 빌드까지 본다: `python -c "import paddle; print(paddle.is_compiled_with_cuda())"`. **GPU 가 있어도 False 면 CPU 빌드라 GPU 를 못 쓴다** → GPU 쓰려면 GPU 경로로 재설치(§GPU 가속).

### 2. 설치 — CPU 경로 (GPU 없음 / CPU 로 충분)

```
python -m pip install --user paddleocr paddlepaddle psutil
```

`paddleocr` 백엔드 = `paddlepaddle`(CPU). torch 불요(EasyOCR 배제로 PyTorch 의존이 통째로 빠졌다 — 설치가 가볍다).

### 3. 설치 — GPU 경로 (NVIDIA + CUDA)

설치된 CUDA 버전에 맞춰 GPU 빌드로 받는다(§GPU 가속의 재설치와 동일 계열):

```
python -m pip install --user paddlepaddle-gpu    # 설치된 CUDA 버전 맞춤(§Windows GPU 셋업)
python -m pip install --user paddleocr psutil
```

torch 불요 — Paddle GPU 가속은 `paddlepaddle-gpu`(자체 cudnn·cublas 번들)가 담당한다(PyTorch 무관).

기업/보안망(TLS 인터셉션)은 다운로드가 크고 실패하기 쉽다 → PowerShell·프록시·재시도로 받거나, 이번 작업이 CPU 로 곧 끝나면 CPU 로 마치고 GPU 셋업은 별도로 한다(→ `skill:skill_LKS_original_secured-windows-tooling`).

### 4. det 모델 — GPU VRAM tier vs CPU

GPU 실측(§Windows GPU 셋업 실측 레시피)에서 server det 는 6GB GPU 에서 **573MB 만 쓰고 정확도 최상**이었다 — GPU 는 **VRAM ≥ 2GB 면 server det**. mobile 강제는 **VRAM < 2GB**(그 이하 server det OOM). CPU 는 별개 — server det 가 oneDNN 미지원으로 **CPU 크래시**하므로 항상 mobile det + `enable_mkldnn=False`.

| 환경 | det 모델 | 근거 |
|---|---|---|
| GPU · VRAM ≥ 2GB | **server det** + korean mobile rec | 6GB 실측 573MB·정확도 최상 |
| GPU · VRAM < 2GB | mobile det + korean mobile rec | server det OOM |
| CPU | mobile det + `enable_mkldnn=False` | server det CPU 크래시(oneDNN) |

(korean rec 은 mobile 만 존재 — det 만 선택 대상.) GPU 기준은 §Windows GPU 셋업 실측 레시피와 일치한다. **CPU 병렬**의 워커·RAM 상한과 CPU 밀집 이미지에서의 mobile det 우위는 §사양 기반 옵션 산정을 따른다. 설치 직후 §PaddleOCR 3.x 셋업의 oneDNN·경량 파이프라인 함정을 함께 확인한다.

## 회전 보정 (선행, 필수)

휴대폰 사진은 **EXIF Orientation=6**(카메라 시계90° 촬영)이 흔하다. pwsh의 Read나 일부 도구는 EXIF를 무시해 눕혀 보인다.

- Pillow: `im.transpose(Image.ROTATE_270)` = **CW 90°** 정방향. 저장 시 EXIF 미포함(이중회전 방지).
- 원본은 건드리지 않고 `scratchpad/rotated/`에 사본을 만든다. **판독·엔진 처리 모두 이 정방향 사본으로.**
- → `scripts/rotate_exif.py`

## PaddleOCR 3.x 셋업 (실측 함정)

- **oneDNN 에러** `(Unimplemented) ConvertPirAttribute2RuntimeAttribute not support`: PIR/oneDNN 조합 버그. 해소는 **둘 다** 필요 —
  - 환경변수(import 전): `os.environ['FLAGS_use_mkldnn']='0'`, `os.environ['FLAGS_enable_pir_api']='0'`
  - 생성자: `PaddleOCR(..., enable_mkldnn=False)`
  - 하나만 빠져도 전부 `__ERROR__`가 난다 — 재실행 전 반드시 확인.
- **경량 파이프라인**(이미 정방향 회전했으면): `use_doc_orientation_classify=False, use_doc_unwarping=False, use_textline_orientation=False` → det+rec만 돌아 방향분류·왜곡보정(UVDoc) 모델을 안 띄운다.
- 결과 파싱: `ocr.predict(f)` → 결과 한 개마다 결과 키가 든 dict 를 얻고(결과 객체의 `json` 속성이면 `{'res': {...}}` 의 `res` 를 벗긴다) 줄마다 `rec_texts`(인식 글자)·`rec_scores`(인식 점수)·`rec_boxes`(상자 `[x_min, y_min, x_max, y_max]` · 없으면 `rec_polys` 꼭짓점의 최소·최대)를 함께 모은다 — 키 이름 = PaddleOCR 공식 문서의 OCR 파이프라인 결과 설명. `predict` 가 예외를 내거나 결과 키가 없으면 그 장은 실패·빈 결과로 보고 원인(§PaddleOCR 3.x 셋업 함정)부터 본다 — PaddleOCR 3.x 의 `ocr.ocr(f)` 는 `predict` 를 그대로 부르는 지원 중단 별칭(`@deprecated`)이라 대신 읽어도 같은 결과가 나와 폴백 효과가 없다(배치 스크립트의 `ocr()` 다시 읽기는 줄마다 `[상자, (글자, 점수)]` 를 내는 옛 판 결과 꼴만 읽는다 · 결과 키가 있고 글자만 0줄인 빈 장은 다시 읽지 않는다).
- 생성자 kwargs는 버전마다 다르니 kwargs 후보 tuple을 순회하며 `TypeError` 시 다음 후보로 폴백한다.

## GPU 가속 (가능하면 최우선 — CPU 병렬보다 먼저 검토)

NVIDIA GPU + CUDA가 있으면 CPU 병렬보다 훨씬 빠르고(장당 ~0.1초(대형·다단계 ~1.65초)) CPU 룸도 남는다. **단 설치된 paddle이 GPU 빌드여야 한다** — 사용자가 설치한 paddle이 CPU 빌드인 경우가 흔하다(CPU 빌드면 GPU가 있어도 못 쓴다).

- 확인: `nvidia-smi`(GPU·VRAM), `paddle.is_compiled_with_cuda()`. **GPU가 있어도 False면 CPU 빌드다.**
- GPU를 쓰려면 재설치: `paddlepaddle-gpu`(CUDA 버전에 맞춰). 다운로드가 크고 네트워크(TLS 인터셉션) 리스크가 있으니, 진행 중 작업이 CPU로 곧 끝나면 이번은 CPU로 마치고 GPU 셋업은 별도로 한다.
- GPU 활성 시: PaddleOCR은 GPU 빌드면 자동 GPU. 이때 CPU 워커 병렬은 불필요하다.

## Windows GPU 셋업 — 실측 레시피 (2종 환경 검증 · 2026-08-10)

**대원칙 — CUDA는 PC마다 다르다.** 부서·개인 PC는 GPU 유무·세대·종류가 제각각이라 일괄 불가하다. 기준은 하나: **이미 설치된 CUDA에 맞춰 paddle 구조 변화가 최소인 wheel**을 고른다(설치 CUDA 이하 최근접 stable 우선 → stable이 없는 최신 아키텍처만 dev로 우회). GPU/CUDA **미설치 PC는 CUDA 12.8 이상**을 설치해 쓴다. 아래 A/B는 그 양 끝단 실측 — **A = 흔한 일반 GPU**(대부분 PC), **B = 최신 Blackwell**. 자동화 = `scripts/setup_ocr_engines_windows.ps1`(1~6단계, `-Cpu` 스위치).

| 검증 환경 | GPU | CUDA(휠) | 특이 |
|---|---|---|---|
| **A 일반** | RTX 4050 6GB (Ada sm_89) | cu126 stable | nvrtc 별도·모델 선다운 |
| **B Blackwell** | Blackwell 워크스테이션 (sm_120) | cu129 dev `--no-deps` + 시스템 12.8 | 순정 wheel sm_120 미지원 |

측정(A, korean server det + mobile rec): 장당 **0.09~0.15s** · warmup ~48s · **VRAM 573MB** · score **0.93~1.00**. paddle GPU 휠 CDN이 제한 네트워크에서 극히 느림(~130KB/s·552MB→~70분·timeout) → 미리 받은 `wheels/*.whl` 로컬 설치 우선. 네트워크는 Invoke-WebRequest(Windows 인증서)로만 — 제한 네트워크 TLS 인터셉션 통과.

### 공통 함정 (A·B 모두)

1. **paddlex → modelscope → torch import 차단 (핵심).** `paddlex`가 `modelscope`를 하드 import → `modelscope`가 `torch` import. **EasyOCR 배제로 torch 를 안 깔므로 이 체인이 `ImportError`로 paddleocr 로드를 깨뜨린다**(과거엔 torch·paddle 이 각자 번들한 `cudnn_cnn64_9.dll` ABI 충돌 `WinError 127` 이었으나 — torch 가 사라져 그 DLL 충돌 자체는 소멸, 대신 미설치 torch import 실패가 남는다). 차단은 동일: `scripts/_ms_stub`에 빈 `modelscope/__init__.py`를 두고 `PYTHONPATH`로 얹거나 `sys.modules["modelscope"]=types.ModuleType("modelscope")` 런타임 더미(paddleocr import 이전). (엔진이 Paddle 단일이라 "두 엔진 별도 프로세스" 요구는 해소됐다.) **stub 이 안전한 근거**: 모델은 최초 다운로드 후 `~/.paddlex/official_models`에 캐시되므로 런타임에 modelscope 가 불요하고, `official_models.py`의 `import modelscope.hub.errors`는 try/except 라 더미여도 안전하다(실측: paddlex 3.7.2 · 2026-08). torch 가 **공존하는** ML 워크스테이션(예: paddle cudnn 9.9 + torch cudnn 9.19)에선 이 체인이 `WinError 127`(동명 `cudnn_cnn64_9.dll` ABI 불일치)로 나타나며, 같은 stub + paddle 번들 `nvidia/*/bin` 을 `os.add_dll_directory`로 선등록해 회피한다(같은 프로세스에서 torch 미import).
2. **모델 소스 healthcheck.** `paddlex` 첫 실행의 연결성 체크가 1초 timeout이라 프록시·TLS 인터셉션 환경에서 "No available model hosting platforms"로 실패. 우회: 모델 tar 미리 수령(`https://paddle-model-ecology.bj.bcebos.com/paddlex/official_inference_model/paddle3.0.0/<모델명>_infer.tar`, server_det 84MB·korean rec 13MB) → `~/.paddlex/official_models/<모델명>/`에 풀고 실행 시 `PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True`.
3. **모델 선택.** korean 기본 = `PP-OCRv5_server_det` + `korean_PP-OCRv5_mobile_rec`(korean rec은 mobile만). 저VRAM(<2GB)/CPU면 det도 `PP-OCRv5_mobile_det`(→ §4 det 모델).

### 분기 A — 일반 NVIDIA (cu126 stable 유효; Ada·Ampere 등)

1. **CUDA 태그 확인**: `nvidia-smi`의 `CUDA Version` → 이하 태그(상위호환) cu126/cu124/cu121/cu118. paddle 빌드 태그를 여기에 맞춘다(**드라이버가 상위(13.x)여도 paddle 빌드 태그, 예 cu126 에 맞춘다**).
2. **nvrtc 필수**: paddle이 `nvidia-cuda-nvrtc-cu12`를 Requires에 안 넣어 cudnn runtime 엔진 로드가 `WinError 127`. `pip install --user "nvidia-cuda-nvrtc-cu12==<CUDA major.minor, 예 12.6.*>"` 별도.
3. **paddlepaddle-gpu**: 미리 받은 `wheels/paddlepaddle_gpu-3.3.1-cp312-cp312-win_amd64.whl` 로컬 설치 우선(CDN 느림), 없으면 인덱스 `https://www.paddlepaddle.org.cn/packages/stable/<태그>/`.
4. `pip install --user paddleocr`.
5. 모델 선다운(공통 2) + modelscope stub(공통 1).

### 분기 B — Blackwell (sm_120; RTX 50-series 등)

순정 wheel로는 안 된다: stable cu126·nightly cu128 Windows wheel은 **sm_120 커널 미포함** → `matmul` 결과가 조용히 0(paddle "compute capability 120 not supported" 경고). stable cu130은 CUDA13 계열이라 시스템 12.8 런타임과 불일치.
- **해결**: 공식 PaddleX Blackwell 전용 **cu129 dev wheel**(`paddlepaddle-gpu==3.0.0.dev20250717`)을 `--no-deps`로 설치해 paddle 바이너리(sm_120 포함)만 취하고 **시스템 `nvidia-*-cu12` 12.8 런타임으로 구동**(드라이버 13.2가 12.9 커버).
  - **cudnn 정확 매칭**: cu129 paddle이 요구하는 `nvidia-cudnn-cu12==9.9.0.52`. 상위(9.20)도 실패(JIT 엔진 DLL ABI 불일치) — matmul(cublas)엔 안 드러나고 **conv2d/OCR(cudnn)에서 드러난다** → cudnn 연산으로 검증한다.
  - modelscope 차단: 공통 1 런타임 더미(torch 미설치라 paddlex→modelscope→torch import 실패 방지).
- 측정: 장당 ~1.65초(2252×4000·4단계). 116장 190.9초·평균 score 0.90.

### 상충 주의 — DLL 경로 prepend

분기 A 실측은 **"`nvidia/*/bin`을 `PATH`·`add_dll_directory`에 prepend 하지 마라 — DLL 탐색 순서를 깨 오히려 `WinError 127`. paddle 자체 로더에 맡겨라"**로 확정됐다. 분기 B(`--no-deps`)는 시스템 nvidia 경로 등록이 필요해 보여 prepend해 성공했으나, 최종 성공의 본질은 **cudnn 정확 매칭 + modelscope 더미**였다 → prepend는 **최후수단**으로만, 먼저 정확 매칭+더미로 paddle 로더에 맡겨 되는지 확인한다(B 환경 prepend 불요 여부는 재실측 대상).

## 사양 기반 옵션 산정 (CPU 병렬 실행 전 필수 — 추측 금지)

**아무 옵션이나 넣고 병렬 실행하면 안 된다.** 반드시 **사양 확인 → 단일 실측 → 계산**의 순서를 밟는다. (대형 det 워커를 과다 투입하면 RAM 한계로 시스템이 멈출 수 있다.)

1. **모델 선택 — 가장 중요.** `lang='korean'` 기본은 **`PP-OCRv5_server_det`(대형 det)** 를 로드한다. 이게 장당 수 분·수 GB로 병렬 폭주의 주범이다. **반드시 mobile로 명시**한다:
   `text_detection_model_name='PP-OCRv5_mobile_det'`, `text_recognition_model_name='korean_PP-OCRv5_mobile_rec'`
   - 실측(밀집 코드 대형 이미지 1장): mobile det 가 server det 대비 약 5~6배 빠르고 4배 가볍다.
   - 정확도도 mobile이 낫다: server는 워터마크·상태바·페이지번호를 텍스트로 오검출하는 반면, mobile은 실제 내용 위주로 깨끗했다.
2. **단일 프로세스 실측.** `scripts/paddleocr_bench.py`로 무거운 대표 이미지 1장의 **워커당 PEAK 메모리 + 장당 시간**을 psutil peak 스레드로 잰다. **절대 안 재고 워커 수부터 정하지 않는다.**
3. **워커수 산정 공식**: `N = min(물리코어 ÷ 2, floor(안전 RAM 예산 / 워커 PEAK))` — **CPU 절반**을 상한으로 둔다. 예: 12코어 → **N=6**. RAM이 작으면 두 번째 항이 지배한다.
   - 실측 교훈: 코어−2 는 CPU 점유가 과해 **시스템 정지(재부팅)** 위험이 있었다. **코어÷2(CPU 절반)** + 워커 우선순위 Below-Normal(`psutil.Process().nice(psutil.BELOW_NORMAL_PRIORITY_CLASS)`)이 시스템 반응성을 지키는 안전선이다. mobile det 는 워커당 메모리가 작아 통상 RAM 은 여유 — **제약은 RAM이 아니라 CPU 점유**였다.
   - **OMP는 반드시 `OMP_NUM_THREADS=1`.** 워커수를 줄여도 OMP>1이면 OpenBlas deadlock으로 hang한다. 워커수 공식과 OMP=1은 **항상 함께** 적용한다.
4. **재실행 전 프로세스 정리 필수.** hang·중단 후 `Get-Process python`이 0인지 확인하고 재실행한다. **죽지 않은 워커가 누적되면 메모리가 재실행 횟수만큼 곱해진다**(죽지 않은 워커가 재실행마다 쌓인 것이 RAM 폭주의 직접 원인이었다).
5. **워치독 STALL 임계 = (장당 시간) × 2 이상.** 너무 짧으면 정상 처리를 hang으로 오판한다(장당 시간보다 짧은 임계는 정상 처리를 STALL로 오판한다).

## 병렬화 (GPU 불가 시)

큰 이미지(3000×4000)는 det가 느려 **장당 수 분**까지 간다. 직렬 `for`는 1코어만 쓴다 → **반드시 병렬화**한다.

- `multiprocessing.Pool(N, initializer=..., initargs=(out,))`, 워커 initializer에서 **워커별 OCR 인스턴스 1개** 생성(모델은 워커당 1회 로드 후 재사용).
- **워커 N = 물리 코어 ÷ 2 (CPU 절반).** 예: 12코어 → 6. 코어−2 는 CPU 점유 과다로 **시스템 정지(재부팅)** 위험 → **코어÷2** + 워커 우선순위 Below-Normal이 안정선. **`os.environ['OMP_NUM_THREADS']='1'` 필수**(OpenBlas deadlock 회피 — 워커를 줄여도 이게 빠지면 hang. 아래 ⚠ 참조).
- Windows는 `if __name__=='__main__'` 가드 + spawn. 진행 로그는 `imap_unordered`. **이미 정상 처리된 파일은 skip**하도록 필터를 둔다(재실행·중단복구 대비).
- RAM은 워커 수 × 모델(수백MB~1GB) — **RAM이 부족하면 워커를 더 줄인다**(RAM이 넉넉해도 CPU 룸을 위해 코어÷2는 유지).
- 코어 수 확인: `Get-CimInstance Win32_Processor`의 NumberOfCores / NumberOfLogicalProcessors.
- **리사이즈는 사용자가 명시 선택하기 전엔 하지 않는다 — 원본 해상도가 디폴트.** 텍스트 정확도 우선, 속도는 GPU·코어 병렬로만 해결한다. 리사이즈는 옵션으로만 노출한다.

### ⚠ 병렬화 실측 함정 (반드시 준수)

- **OpenBlas 빌드 + `OMP_NUM_THREADS`>1 = deadlock/hang.** paddlepaddle CPU 빌드가 OpenBlas면 워커가 OMP 멀티스레드에서 교착한다. 실행 초기 로그의 경고 —
  `WARNING: OMP_NUM_THREADS set to 2, not 1. ... It will fail if this PaddlePaddle binary is compiled with OpenBlas since OpenBlas does not support multi-threads` —
  **를 절대 무시하지 말 것.** `OMP_NUM_THREADS=1`로 고정한다.
  - 실측 사고: OMP>1·과병렬이면 일부 장에서 **장시간 hang**(프로세스는 살아있으나 CPU idle·로그 정체). OMP=1로 재실행해 해소했다.
- **hang 능동 감시 필수 — silence ≠ success.** 병렬 배치는 **완료 알림만 믿으면 안 된다**. hang은 로그가 안 나와 "진행 중"과 구별되지 않는다. 별도 **워치독**을 백그라운드로 걸어 "정상 처리 수"를 주기(20~30초) 폴링하고, **전부 도달(완료) / N분 무진행(STALL)** 둘 다에서 알림을 내게 한다. 예: `$ok`가 목표치면 `COMPLETE`, 연속 8회(~2.7분) 무변화면 `STALLED` 출력 후 종료.
- **중단·복구 대비 skip.** 재실행 시 이미 정상(비-`__ERROR__`·비어있지 않음) 처리된 파일은 건너뛰어, hang·중단 후 남은 것만 이어서 처리한다.

→ 재사용 스크립트: `scripts/paddleocr_parallel.py`, `scripts/rotate_exif.py`

### 배치 스크립트 입출력 (`scripts/paddleocr_parallel.py`)

- **실행**: `python scripts/paddleocr_parallel.py <쪽 이미지 폴더> <결과 폴더> [워커 수]` — 워커 수를 안 주면 물리 코어 ÷ 2(psutil 이 없으면 4).
- **입력**: 폴더 안의 `.jpg`·`.jpeg`·`.png`·`.webp`(대소문자 무시 · `scripts/rotate_exif.py` 기본 확장자와 같다). PDF 스캔에서 뽑은 PNG 쪽 이미지도 그대로 받는다(`SKILL.md` 실행 방법 1). 확장자만 다른 같은 이름(`a.jpg`·`a.png`)은 결과 파일이 겹치므로 쪽 이미지 이름을 서로 다르게 둔다.
- **산출(장마다 둘)**: `<이름>.txt` = 줄마다 인식 글자(대조 스크립트 입력) · `<이름>.lines.json` = `{"image": 쪽 이미지 파일 이름, "lines": [{"text", "score", "box"}]}`(`box` = `[x_min, y_min, x_max, y_max]` · 점수·상자를 못 읽은 줄은 `null`). 실패한 장은 `<이름>.txt` 에 `__ERROR__ …` 만 남고 곁 파일이 없다.
- **종료코드**: 처리할 이미지 0장(「대상 이미지 0장」) · 쪽 이미지 폴더 없음 · 이번에 처리한 장이 전부 실패 = **1** · 일부만 실패 = **0**. 실패한 장과 `ocr()` 로 대신 읽은 장의 사유는 stderr 에 `! <이름>: <사유>` 로 나오고, 끝에 요약 줄 「정상 n · 빈 결과 n · 실패 n」이 나온다 — 0 으로 끝나도 요약 줄의 실패·빈 결과 수를 본다(아래 「운용」).
- **다시 돌리면**: 이미 정상(글자가 있고 `__ERROR__` 없음) 처리된 장은 건너뛰고 빈 결과·실패 장만 다시 처리한다(남은 장이 0이면 처리 없이 0 으로 끝난다).

## 판독↔엔진 대조 (판독 결과 vs PaddleOCR)

정규화(공백 제거) 후 **한글 리터럴 n-gram 매칭**:

- **(A) 판독 결과에만 있고 엔진(Paddle)에 근사매칭 안 됨** → 잠재 환각/오독. 그 지점만 **재확인용 판독 서브(`bada-image-reader`)가 원본 이미지를 재확인**한다(master 직접 판독 X).
- **(B) 엔진(Paddle)엔 있는데 판독 결과에 없음** → 누락 후보. (A)와 같은 재확인 판독 서브에 함께 넘긴다. 대조 스크립트는 배치 곁 파일(`<이름>.lines.json`)이 있으면 (B) 후보 옆에 그 줄의 `[점수 · 쪽 이미지 · 상자]` 를 보조로 붙인다.
- **오탐 걸러내기**: (a) 메타 주석·각주는 대조 대상에서 제외 (b) 엔진이 특수문자(`→`,`·`,`§`)·회전·밀집코드에서 약한 것을 감안한다 — 미매칭 다수는 대개 엔진 부정확이지 환각이 아니다 (c) 이미지 경계에서 잘린 글자 조각에서 나온 엔진 결과(엉뚱한 글자·낮은 `rec_scores`)는 불일치·재확인 대상에서 뺀다 — 이 판단은 이미지를 봐야 하므로 (B) 목록을 받은 **재확인 판독 서브**가 한다(master 는 이미지를 보지 않고 목록을 그대로 넘긴다 · 대조 스크립트는 자동으로 빼지 않고, 점수·상자[가장자리에 붙은 상자]는 그 판단의 보조 근거일 뿐이다). 뺀 조각은 확대·판정하지 않고, 그 자리는 겹쳐 찍은 다른 이미지의 온전한 같은 줄로 대조한다(원본 = `SKILL.md` 「경계에서 잘린 글자」).
- 스크립트가 로컬 처리, master는 요약만 읽는다 → `scripts/crosscheck.py`. 종료코드: **0** = 대조함(후보 수·목록은 출력으로 본다) · **2** = 대조할 것이 없음(OCR 결과가 전부 비었거나 판독본에 비교할 한글 조각이 0개) · **1** = `--mine` 파일이나 OCR 폴더가 없음·`--ocr` 형식 오류(판독본을 여럿 주면 그중 큰 값).

### 신뢰도로 재확인 지점 좁히기

PaddleOCR `predict` 결과에는 라인별 인식 텍스트(`rec_texts`)와 함께 **신뢰도 점수(`rec_scores`)** 가 있다. 배치 스크립트가 이를 줄마다 곁 파일 `<이름>.lines.json` 의 `score` 로 남긴다(위 「배치 스크립트 입출력」) — 이것으로 **점수가 낮은(예: < 0.9) 라인 = 엔진도 자신 없는 곳**으로 보고 재확인 판독 서브 투입 우선순위를 매긴다. "어디를 다시 볼지"를 전수 재대조 없이 자동으로 좁혀 토큰을 아낀다. 엔진이 Paddle 단일이므로 이 신뢰도 신호가 2번째 엔진 표를 대신한다(EasyOCR 배제 후에도 "어디를 다시 볼지"는 살아있다). 저신뢰 라인을 재확인 판독 서브에 넘길 때는 엔진이 그 줄을 검출한 위치(곁 파일의 `box` 상자 좌표)로 위아래 한두 줄을 포함한 영역을 원본 해상도로 잘라(사본) 함께 준다 — 재확인이 줄어든 전체 이미지가 아니라 확대 재판독이 되게 한다(순서·대상 원본 = `SKILL.md` 「경계 안의 불확실 글자」).

## 운용 (백그라운드 모니터링)

- 엔진 배치는 오래 걸리니 background 실행 + **능동 모니터링**: 정상/에러 카운트를 폴링해 초기 몇 장으로 정상 작동을 확인한다(전부 에러를 조기 포착). **"완료(exit 0)"가 곧 "정상 결과"는 아니다** — 배치 스크립트는 0장·전부 실패일 때만 0 아닌 종료코드로 끝나고 일부 실패는 0 으로 끝나므로, 끝의 요약 줄(정상·빈 결과·실패 수)과 stderr 사유(`! <이름>: <사유>`)·`__ERROR__` 개수를 반드시 확인한다.
- 느리면 원인부터: **직렬 아닌지**(병렬화), **무거운 파이프라인 아닌지**(경량화·mobile det). 리사이즈는 최후 수단이자 정확도 트레이드라 기본 배제한다.

## 촬영 메타 마스킹 (선택)

휴대폰 화면촬영본은 하단 카메라 워터마크(기기명·타임스탬프)·상단 상태바가 엔진 노이즈가 된다. **회전 보정 후** 고정 영역을 Pillow로 crop하거나 흰색 overlay하면 엔진 결과가 깨끗해지고 출처 단서도 자동 일반화된다. 단 회전·해상도가 섞이면 좌표가 어긋나니 동일 촬영셋에만 적용한다.

> 마스킹은 **엔진 입력용 사본**에만 한다. 판독용 이미지는 가리지 않는다 — 워터마크에 **가려진 글자**를 판독이 복원해야 하는 경우가 있다(→ `SKILL.md` 프레임 전체 스캔).

## 관련

- `SKILL.md` (이 스킬) — 판독 방법론. 이 문건의 전제.
- `skill:skill_LKS_original_multi-session-orchestration` — 검수 세션 분리.
- `skill:skill_LKS_original_secured-windows-tooling` — PowerShell 우선, winget 회피(도구 설치 시).

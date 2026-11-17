<#
.SYNOPSIS
  PaddleOCR 로컬 OCR 엔진을 Windows 보안 통제 환경에서 셋업한다(EasyOCR·torch 제외).
  ocr_engine_ops.md §"Windows GPU 셋업 — 실측 레시피"의 자동화.

.DESCRIPTION
  실측(2026-08-10, RTX 4050 6GB, CUDA 13.0)으로 확정한 순서/함정을 그대로 수행한다:
  1) CUDA 판별(paddle GPU 휠 태그)   2) nvidia-cuda-nvrtc-cu12(필수)
  3) paddlepaddle-gpu(로컬 wheels/ 우선, 없으면 인덱스)   4) paddleocr
  5) 모델 tar을 IWR로 BOS에서 받아 ~/.paddlex/official_models/ 에 배치
  6) modelscope stub 생성(paddlex→modelscope→torch import 실패 방지 · torch 미설치)
  네트워크는 Invoke-WebRequest(Windows 인증서)로만 — 제한 네트워크 TLS 인터셉션 통과.
  torch 불요 — Paddle GPU 가속은 paddlepaddle-gpu 자체 cudnn·cublas 번들이 담당(PyTorch 무관).

.PARAMETER Cpu
  GPU가 있어도 CPU 빌드로 강제(디버깅용).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File setup_ocr_engines_windows.ps1
#>
[CmdletBinding()]
param([switch]$Cpu)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
function Info($m){ Write-Host "  $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  OK  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  주의 $m" -ForegroundColor Magenta }

$SkillRoot = Split-Path -Parent $PSScriptRoot
$Py = (Get-Command python -ErrorAction SilentlyContinue).Source
if (-not $Py) { throw "python 을 PATH 에서 찾지 못했다." }

# --- 1. CUDA 판별 → paddle GPU 휠 태그 (torch 아님 — paddlepaddle-gpu 인덱스용) ---

function Get-CudaTag {
    if ($Cpu) { return 'cpu' }
    if (-not (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) { return 'cpu' }
    $smi = (nvidia-smi | Out-String)
    $m = [regex]::Match($smi, 'CUDA Version:\s*(\d+)\.(\d+)')
    if (-not $m.Success) { return 'cpu' }
    $cuda = [int]$m.Groups[1].Value * 10 + [Math]::Min([int]$m.Groups[2].Value, 9)
    if ($cuda -ge 126) { 'cu126' } elseif ($cuda -ge 124) { 'cu124' }
    elseif ($cuda -ge 121) { 'cu121' } elseif ($cuda -ge 118) { 'cu118' } else { 'cpu' }
}
$tag = Get-CudaTag
$vram = $null
if ($tag -ne 'cpu') {
    try { $vram = [int]((nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits) -split "`n")[0].Trim() } catch {}
}
Info "환경: CUDA 태그=$tag $(if($vram){"· VRAM ${vram}MB"}) (torch 미설치 — Paddle 단일)"

# --- 2. paddle: nvrtc(필수) → paddlepaddle-gpu(로컬 wheels 우선) ---

if ($tag -ne 'cpu') {
    Info '2) nvidia-cuda-nvrtc-cu12 (cudnn runtime 엔진 필수 의존 — paddle 이 pin 안 함)'
    & $Py -m pip install --user --disable-pip-version-check -q "nvidia-cuda-nvrtc-cu12==12.6.*"
    if ($LASTEXITCODE -eq 0) { Ok 'nvrtc' } else { Warn 'nvrtc 설치 실패 — GPU paddle 이 WinError 127 로 죽을 수 있다' }
}

Info '3) paddlepaddle'
$localWhl = @(Get-ChildItem -LiteralPath (Join-Path $SkillRoot 'wheels') -Filter '*paddlepaddle_gpu*win_amd64.whl' -EA SilentlyContinue)
if ($tag -ne 'cpu' -and $localWhl.Count) {
    Ok "로컬 wheel 사용: $($localWhl[0].Name)"
    & $Py -m pip install --user --disable-pip-version-check -q "$($localWhl[0].FullName)"
} elseif ($tag -ne 'cpu') {
    Warn 'wheels/ 에 로컬 paddle GPU 휠이 없다 — paddle 인덱스에서 시도(제한 네트워크에서 느릴 수 있음)'
    & $Py -m pip install --user --disable-pip-version-check -q paddlepaddle-gpu -i "https://www.paddlepaddle.org.cn/packages/stable/$tag/"
} else {
    & $Py -m pip install --user --disable-pip-version-check -q paddlepaddle
}
if ($LASTEXITCODE -eq 0) { Ok 'paddlepaddle' } else { Warn 'paddlepaddle 설치 실패' }

Info '4) paddleocr'
& $Py -m pip install --user --disable-pip-version-check -q paddleocr
if ($LASTEXITCODE -eq 0) { Ok 'paddleocr' } else { Warn 'paddleocr 설치 실패' }

# --- 5. 모델 IWR 선다운로드 → ~/.paddlex/official_models/ ---

Info '5) 모델 provisioning (IWR → BOS → 캐시)'
$cache = Join-Path $env:USERPROFILE '.paddlex\official_models'
New-Item -ItemType Directory -Force -Path $cache | Out-Null
$base = 'https://paddle-model-ecology.bj.bcebos.com/paddlex/official_inference_model/paddle3.0.0'
# korean 기본: server det + korean mobile rec. 저VRAM/CPU 면 mobile det 도.
$models = @('PP-OCRv5_server_det', 'korean_PP-OCRv5_mobile_rec')
if ($tag -eq 'cpu' -or ($vram -and $vram -lt 2000)) { $models += 'PP-OCRv5_mobile_det' }
foreach ($name in $models) {
    $dst = Join-Path $cache $name
    if ((Test-Path (Join-Path $dst 'inference.yml'))) { Ok "캐시 존재: $name"; continue }
    $tar = Join-Path $env:TEMP "${name}_infer.tar"
    try {
        Invoke-WebRequest -Uri "$base/${name}_infer.tar" -OutFile $tar -UseBasicParsing
        & $Py -c "import tarfile,os,shutil; t=tarfile.open(r'$tar'); t.extractall(os.environ['TEMP']); s=os.path.join(os.environ['TEMP'], r'${name}_infer'); d=r'$dst'; shutil.rmtree(d,ignore_errors=True); shutil.move(s,d)"
        Remove-Item $tar -Force -EA SilentlyContinue
        Ok "받음·배치: $name"
    } catch { Warn "모델 다운로드 실패: $name — $($_.Exception.Message)" }
}

# --- 6. modelscope stub (paddlex→modelscope→torch import 실패 방지) ---

Info '6) modelscope stub (paddlex 의 modelscope→torch import 차단)'
$stub = Join-Path $SkillRoot 'scripts\_ms_stub'
New-Item -ItemType Directory -Force -Path (Join-Path $stub 'modelscope') | Out-Null
Set-Content -LiteralPath (Join-Path $stub 'modelscope\__init__.py') -Encoding utf8 -Value '# stub: paddlex 가 import 만 하므로 빈 모듈로 둔다. torch 미설치(EasyOCR 배제)라 modelscope->torch import 실패를 막는다.'
Ok "stub: $stub"

Write-Host ''
Write-Host ' 완료. PaddleOCR 실행 시 아래 환경으로:' -ForegroundColor Green
Write-Host "  `$env:PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK='True'" -ForegroundColor Gray
Write-Host "  `$env:PYTHONPATH='$stub'  # modelscope stub (torch import 실패 방지)" -ForegroundColor Gray

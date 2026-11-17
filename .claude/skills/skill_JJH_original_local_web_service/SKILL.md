---
version: "1.3.0"
updated: "2026-09-07"
name: skill_JJH_original_local_web_service
description: >
  로컬 PC를 서버 삼아 내부망에 Python 웹앱·도구를 배포하고 운용할 때 사용한다.
  Streamlit·FastAPI·React 선택 기준, FastAPI 시작 골격(CORSMiddleware·StaticFiles·
  HTMLResponse·uvicorn host 0.0.0.0 port 8013), "나는 되는데 옆자리는 안 된다"
  3함정(host·__file__ 절대경로·방화벽 인바운드), 로컬 포트 개발 루프, 작업 스케줄러
  부팅 기동과 /health 감시 재기동, JSONL 로깅, 내부 LLM API 연동 래퍼, lru_cache 엑셀
  읽기를 다룬다. 파일 경로·인코딩(UNC·cp949) 세부는 skill_LKS_original_secured-windows-tooling.
  트리거: "내부 웹앱 배포", "FastAPI 내부 서버", "로컬 PC 서버화", "포트가 옆자리서 안 열림",
  "uvicorn 0.0.0.0", "작업 스케줄러로 서버 기동", "/health 감시".
metadata:
  type: method
---

# Local Web Service (로컬 PC 웹 서비스 운용)

개인 Windows PC를 서버 삼아 내부망에 Python 웹앱·도구를 올리고 운용할 때의 규율. "만들면 되는데 남이 못 쓰는" 지점, 배포·감시·로깅·내부 LLM 연동에서 반복되는 함정을 미리 고정한다. 경로·인코딩·PowerShell·설치 세부는 `skill:skill_LKS_original_secured-windows-tooling`이 맡는다.

## 적용 조건

내부망(제한 네트워크)에서 개인 PC를 서버로 삼아 웹 화면 또는 API를 다른 사람이 쓰게 배포·운용하는 작업. Streamlit/FastAPI 선택, 로컬 포트로 브라우저 확인, 부팅 자동 기동·감시, 로깅, 내부 LLM API 연동이 포함될 때 적용한다. 순수 스크립트·화면 없는 배치 작업에는 적용하지 않는다.

## 폴더 구조 (관리가 편해지는 형태)

이 구조는 **웹페이지·서버 설계 전용**이다 — 통상 작업 폴더 구조가 아니다. 이 스킬로 만드는 산출물(앱)은 아래 구조를 반영해야 한다.

```
프로젝트/
  Frontend/   # 화면 코드(HTML/CSS/JS, 필요하면 React)
  Backend/    # 서버·처리 로직, requirements.txt, main.py
  DB/         # 앱이 읽고 쓰는 데이터 파일
  Material/   # 참고 자료·매뉴얼·샘플
  etc/        # 임시·일회성 스크립트 (지워도 서비스가 안 죽는 것)
```

- **Frontend·Backend = 필수 핵심 폴더** — 이 둘은 무조건 있어야 한다(웹/서버 앱의 뼈대). 나머지(DB·Material·etc)는 앱에 따라 없어도 된다. 화면만 React로 교체하거나 백엔드만 다른 앱에서 재사용할 때, Frontend/Backend 분리가 안 되어 있으면 손댈 수가 없다.
- **etc/** — `inspect_excel.py`·`test2.py`·`결과_최종_v3.xlsx` 같은 일회성 파일이 루트에 쌓이면 몇 달 뒤 무엇이 운영 코드인지 구분이 안 된다. "지워도 서비스가 안 죽는 것"은 전부 여기로.
- 백업본은 `_backup.py`·`_복사본.py`로 남기기보다 별도 폴더로 빼거나 날짜를 `_YYMMDD`로 통일해 정렬되게 둔다.
- 앱을 남에게 넘길 가능성이 있으면 `STRUCTURE.md` 한 장(목적·포트·실행·Input/Output·외부 의존)을 두면 6개월 뒤 본인과 LLM 모두에게 가장 요긴하다. 예: `- 포트: 8013 / - 실행: Backend/run.bat / - 외부 의존: 내부 LLM API`.

## 무엇으로 만들까 — Streamlit vs FastAPI vs +React

| 상황 | 추천 |
|---|---|
| 나 혼자 쓸 분석 도구, 화면은 대충 되면 됨 | **Streamlit** (훨씬 빠르게 만든다) |
| 여러 사람이 접속, 화면을 원하는 대로 만들고 싶음 | **FastAPI** |
| 프런트가 복잡한 SPA | **FastAPI + React/Vite** |
| 화면이 아예 필요 없음 | 그냥 스크립트 (억지로 웹으로 만들 필요 없다) |

Streamlit으로 시작해도 된다. 다만 **여러 명이 동시에 쓰기 시작하면** 상태 관리와 화면 커스터마이징에서 막히는 지점이 온다 — 그때 FastAPI로 옮긴다.

## FastAPI 시작 골격 (복사해서 쓴다)

```python
# Backend/main.py
import os
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse

app = FastAPI(title="My App API")

# 내부망 전용이면 이대로 두고, 외부 공개 시 allow_origins를 명시 목록으로 좁힌다.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,   # '*' + credentials 조합은 브라우저가 거부한다(아래 주석)
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Frontend/ 가 이 파일의 상위(프로젝트 루트)에 있으면 "..", 같은 폴더면 "." 로 맞춘다.
FRONTEND_DIR = os.path.join(BASE_DIR, "..", "Frontend")
app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

@app.get("/", response_class=HTMLResponse)
def index():
    with open(os.path.join(FRONTEND_DIR, "index.html"), encoding="utf-8") as f:
        return f.read()

@app.get("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    # 서비스·스케줄러 기동용(리로드 없음). 개발 중에는 CLI로 --reload 를 쓴다.
    uvicorn.run(app, host="0.0.0.0", port=8013)
```

- 포트는 `8000`·`8013`처럼 다른 앱과 겹치지 않는 값으로 고정한다.
- 인증 쿠키까지 써야 하면 `allow_origins`를 실제 origin 목록으로 좁히고 `allow_credentials=True`로 둔다(와일드카드+credentials는 규격상 불가).

## "나는 되는데 옆자리는 안 된다" — 3함정

여기서 90%가 걸린다.

1. **`host="0.0.0.0"`** — `127.0.0.1`로 두면 본인 PC에서만 열린다. 옆자리서 안 열리는 대부분이 이것.
2. **경로는 `__file__` 기준 절대경로로** — 배치파일이나 작업 스케줄러로 돌리면 작업 디렉터리가 달라져 상대경로가 전부 깨진다. `os.path.dirname(os.path.abspath(__file__))`를 기준으로 잡는다.
3. **방화벽 인바운드 허용** — 해당 포트를 인바운드 허용하지 않으면 `0.0.0.0`으로 열어도 다른 PC에서 접속이 막힌다.

(한글 깨짐을 부르는 `encoding="utf-8"` 누락은 별개 함정 — → `skill:skill_LKS_original_secured-windows-tooling` 인코딩 절.)

## 로컬 포트 개발 루프

고칠 때마다 브라우저에서 눈으로 확인하는 게 결국 가장 빠르다. LLM에게 시킬 때도 "포트 열고 크롬으로 확인까지 해줘"라고 하면 추측으로 끝내지 않는다.

```bat
REM run_dev.bat — 브라우저를 띄운다 (서버는 아래 uvicorn 으로 별도 기동)
@echo off
cd /d "%~dp0"
start "" chrome "http://localhost:8013"
```

```
REM 개발 서버(자동 재기동): Backend/ 에서
uvicorn main:app --reload --host 0.0.0.0 --port 8013
```

- **`--reload`** — 저장하면 서버가 알아서 재기동된다(개발용).
- **프런트 수정은 Ctrl+F5(강력 새로고침)** — 캐시 때문에 "안 고쳐졌다"고 헤매는 경우가 정말 많다.
- 에러가 나면 크롬 개발자도구 **Console/Network**를 먼저 보고, 500이면 서버 콘솔의 traceback을 본다.
- 남에게 보이기 전 한 바퀴:
  - 다른 PC에서 `http://<내 IP>:<포트>/` 접속(방화벽·`0.0.0.0` 확인).
  - **실제 업무 파일**로 업로드→처리→다운로드 한 바퀴(샘플만으론 실제 파일에서만 나는 인코딩·형식·권한 문제를 놓친다).
  - 이상한 파일·빈 파일을 넣었을 때 에러 메시지가 화면에 보이는지.
  - 운영 중인 앱을 고칠 땐 복제본을 다른 포트로 띄워 확인한 뒤 반영한다.

## 로컬 PC를 서버로

조직 내부에서 서버를 배정받기는 어렵다 — 개인 PC를 서버로 쓰는 게 현실적인 방법이다.

- 배치파일 + Windows 작업 스케줄러로 **부팅 시 자동 기동**.
- 방화벽에서 해당 포트 **인바운드 허용**(사유·상세 = 위 「3함정」 절이 원본).
- **PC 절전/최대 절전 끄기** — 절전에 들어가면 서비스가 죽는다.
- 죽었을 때 알아서 살아나게 `/health`를 주기적으로 찔러 실패 시 재기동한다:

```powershell
$fail = 0
while ($true) {
    try { Invoke-WebRequest "http://localhost:8013/health" -TimeoutSec 5 -UseBasicParsing | Out-Null; $fail = 0 }
    catch {
        $fail++   # 일시 실패(타임아웃·순간 5xx) 1~2회는 무시 — 연속 3회부터 진짜 장애로 판정
        if ($fail -ge 3) {
            Get-NetTCPConnection -LocalPort 8013 -State Listen -ErrorAction SilentlyContinue |
                ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }   # 행(hang) 프로세스 선종료 — 포트 충돌로 새 인스턴스가 조용히 죽는 것 방지
            Start-Process python -ArgumentList "Backend\main.py" -WorkingDirectory "C:\apps\myapp" -WindowStyle Hidden
            $fail = 0
        }
    }
    Start-Sleep -Seconds 60
}
```

- 앱이 여러 개면 한 번에 올리는 `run_all.bat` / 내리는 `stop_all.bat` 쌍이 편하다.

## 로깅 — JSONL

```python
import json, datetime

def log_event(path: str, **fields):
    rec = {"ts": datetime.datetime.now().isoformat(), **fields}
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")   # 한 줄 = 한 이벤트
```

- 접속 IP·기능 사용 이력을 **JSONL(한 줄 = 한 이벤트)**로 남기면 나중에 `pandas.read_json(path, lines=True)`로 바로 분석된다.
- traceback을 화면에 그대로 보여주지 말고, 사용자에겐 "무엇을 하면 되는지"를 보여준다.
- 로그 파일·업로드 원본은 용량·개인정보 때문에 버전 관리·백업 대상에서 제외한다.

## 내부 LLM API 연동 래퍼

호출 래퍼를 하나 만들어 **타임아웃·재시도·토큰 초과·JSON 폴백**을 한곳에 모아두면 앱마다 다시 짤 필요가 없다.

```python
import os, json, time, requests

API_URL = os.environ["INTERNAL_LLM_URL"]   # 엔드포인트·키는 코드에 박지 말고 환경/별도 파일로
API_KEY = os.environ["INTERNAL_LLM_KEY"]

def call_llm(prompt: str, *, retries: int = 2, timeout: int = 30) -> str:
    last_err = None
    for attempt in range(retries + 1):
        try:
            r = requests.post(
                API_URL,
                headers={"Authorization": f"Bearer {API_KEY}"},
                json={"prompt": prompt},
                timeout=timeout,
            )
            r.raise_for_status()
            return r.json()["text"]
        except Exception as e:
            last_err = e
            time.sleep(1.5 * (attempt + 1))   # 점증 백오프
    raise RuntimeError(f"내부 LLM 호출 실패: {last_err}")

def call_llm_json(prompt: str, fallback: dict) -> dict:
    raw = call_llm(prompt)
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return fallback   # LLM이 JSON을 준다고 믿지 않는다 — 파싱 실패 폴백
```

- API 키·엔드포인트는 코드에 넣지 말고 환경변수/별도 파일로 빼고 버전 관리에서 제외한다.
- 대용량 문서를 통째로 넣지 말고, 파싱·요약한 **구조화 데이터**를 넣으면 품질과 비용이 같이 좋아진다.
- **토큰 초과**가 나면 입력을 더 줄인(요약·발췌) 구조화 데이터로 재호출한다.
- 프롬프트도 코드다 — 파일로 빼두면 무엇을 바꿔서 좋아졌는지 추적된다.

## 엑셀 읽기 캐시·인코딩

같은 엑셀을 반복해 읽으면 `lru_cache`로 캐시하되, **파일이 바뀌면 자동 무효화**되도록 (mtime, size)를 키에 넣는다.

```python
import os
import pandas as pd
from functools import lru_cache

@lru_cache(maxsize=16)
def _read_excel_cached(path, mtime_ns, size):
    return pd.read_excel(path, engine="openpyxl")

def read_excel(path):
    st = os.stat(path)
    return _read_excel_cached(path, st.st_mtime_ns, st.st_size).copy()   # 복사본 반환
```

- `.copy()`를 빼면 호출한 쪽에서 DataFrame을 건드렸을 때 캐시가 오염된다.
- 파일을 열 때는 `encoding="utf-8"`을 명시한다(내부 PC 기본은 cp949). CSV 폴백·UNC 경로 등 세부는 아래 관련 문건.

## 관련 문건

- `skill:skill_LKS_original_secured-windows-tooling` — 파일 경로(UNC·260자 제한)·인코딩(cp949 폴백)·PowerShell 우선·공식 릴리스 설치 규율. 이 스킬의 경로·인코딩 세부는 여기에 위임한다.

---

출처: JJH

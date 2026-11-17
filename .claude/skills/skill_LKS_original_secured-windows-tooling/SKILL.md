---
version: "1.2.7"
updated: "2026-08-30"
name: skill_LKS_original_secured-windows-tooling
description: >
  Use on a locked-down Windows environment where SSL/TLS interception, blocked
  package sources, or Microsoft Store execution aliases interfere with tooling —
  prefer PowerShell (Invoke-WebRequest/RestMethod) for network calls, avoid
  winget, and use `python` (not `python3`) for human-run commands. Covers why
  Git Bash curl fails TLS there and how to install system tools from official
  releases instead of winget. 파일 경로(UNC·260자 MAX_PATH)와 cp949 인코딩 폴백도 다룬다.
  트리거(통제 Windows 환경일 때만 — 비-Windows 에선 이 낱말들에 반응하지 않는다):
  "powershell", "winget", "인증서", "보안망", "TLS 인터셉션",
  "프록시", "proxy", "패키지 차단", "다운로드", "download", "설치해",
  "cp949", "인코딩", "encoding", "UNC 경로", "260자", "한글 깨짐".
metadata:
  type: method
---

# Secured Windows Tooling (보안 통제 Windows 환경 도구 규율)

SSL/TLS 인터셉션·패키지 소스 차단·Microsoft Store alias가 존재할 수 있는 보안 통제 Windows 환경의 네트워크·패키지·Python 실행 규율.

## 적용 조건

트래픽을 보안 루트 인증서로 재서명(SSL 인터셉션)하거나, 패키지 소스가 차단됐거나, Store 실행 별칭이 낀 통제 Windows 환경에서 다운로드·API 호출·도구 설치를 할 때 적용한다.

## 핵심 원칙 — PowerShell 우선

Bash·PowerShell 둘 다 가능한 네트워크 작업은 PowerShell로 실행한다.

- SSL 인터셉션 환경은 보안 루트 인증서로 트래픽을 재서명한다. Git Bash의 curl은 이 인증서를 신뢰하지 않아 TLS 핸드셰이크 자체가 실패한다(예: `curl -s https://api.github.com/...` → exit 35). PowerShell의 Invoke-WebRequest/Invoke-RestMethod는 Windows 인증서 저장소를 쓰므로 같은 요청이 정상 동작한다.
- 네트워크 요청(다운로드, API 호출, 외부 사이트 접근)은 처음부터 PowerShell(Invoke-WebRequest/Invoke-RestMethod)로 시도한다.

## 실행 방법

### winget을 쓰지 않는다

- 통제 네트워크에서 winget의 패키지 소스(cdn.winget.microsoft.com)가 막혀 있다(source list 상 msstore는 갱신되나 winget 소스는 실패). winget install이 실패를 반복하며 일부 패키지에 msstore 소스로 자동 폴백하는 과정에서 그래픽 Microsoft Store 앱(WinStore.App)이 예고 없이 반복적으로 열리는 부작용이 확인됐다.
- 시스템 도구 설치가 필요하면 winget 대신 각 도구의 **공식 GitHub Releases/공식 다운로드 페이지에서 직접 바이너리(zip 우선, 없으면 공식 installer)**를 받아 설치한다.

### Windows Python 실행 명령

- **사용자가 실행하는 Python 명령·사람용 예시는 `python`을 쓰고 `python3`을 쓰지 않는다.** Windows의 `python3.exe`는 실제 Python이 아니라 Microsoft Store App Execution Alias의 `WindowsApps` Store 스텁으로 resolve될 수 있어, 명령이 실패하거나 Store로 유도된다.
- 먼저 `Get-Command python, python3 -ErrorAction SilentlyContinue | Select-Object Name,Source,Path`로 resolution만 확인하고, 실제 실행은 `python --version` / `python -c "import sys; print(sys.executable)"`로 검증한 뒤 사용자 명령·문서 예시는 `python`으로 작성한다.
- **적용 범위** = Windows 사람용 실행 명령에만. cross-platform Python shebang(`#!/usr/bin/env python3`), shell runtime resolver, `CLV2_PYTHON_CMD` fallback은 이 규칙으로 일괄 치환하지 않는다 — 지침층이 자기 패키지의 산출물을 금지하면 안 된다.

### 파일 경로 — UNC 우선·긴 경로(260자)

- 공유 폴더는 드라이브 문자(`P:\`)보다 UNC 경로(`\\server\share`)로 참조한다. 작업 스케줄러 세션에는 대화형 로그온에서 매핑한 드라이브가 없어서 `P:\`가 존재하지 않는 경로가 된다 — 스케줄러로 도는 코드가 갑자기 경로를 못 찾는 전형적 원인이다.
- 한글·공백이 든 경로가 흔하므로 배치/PowerShell에서는 큰따옴표로 감싼다(`"\\server\share\보고 자료\..."`).
- 파일명이 길어 260자 제한(MAX_PATH)에 걸리면, 저장은 정규화한 짧은 이름으로 하고 원본 파일명·경로는 사이드카 메타파일에 보관한다(`<파일>.xlsx` + `<파일>_meta.json` 패턴).

### 인코딩 — 파일 열 때 cp949 폴백

- 파이썬에서 파일을 열 때 `encoding="utf-8"`을 명시한다. 통제 Windows PC의 기본 인코딩은 cp949라, 생략하면 한글이 깨지거나 `UnicodeDecodeError`가 난다.
- 내부에서 만든 CSV는 대개 cp949이므로, 읽을 때 3단 폴백을 두면 거의 다 읽힌다:

  ```python
  for enc in ("utf-8-sig", "cp949", "utf-8"):
      try:
          return pd.read_csv(path, encoding=enc)
      except UnicodeDecodeError:
          continue
  ```

- 반대로 엑셀에서 열 CSV를 만들 때는 `utf-8-sig`(BOM 포함)로 저장해야 엑셀이 한글을 안 깨고 연다.

## 예외·금지

- 파일 검색·grep·단순 텍스트 처리처럼 네트워크가 개입하지 않는 작업은 기존대로 Bash/dedicated tool을 쓸 수 있다. **이 규칙(PowerShell 우선)은 네트워크·인증서가 개입하는 작업에 한정**한다 — 그 밖으로 확대 적용하지 않는다.
- winget으로 시스템 도구를 설치하지 않는다(공식 릴리스 직접 설치).
- 패키지가 실제로 출하하는 `tools/*.py`의 `python3` shebang을 이 규칙으로 금지하지 않는다.

## 관련 문건

- `skill:skill_LKS_original_instruction-architecture` — 패키지·설치기 저작 시 이 제약 반영
- `skill:skill_JJH_original_local_web_service` — 로컬 PC 웹 서비스 운용(이 규율의 경로·인코딩을 소비)

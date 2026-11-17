# 이 런타임의 환경 선언 (생성물 — 직접 수정 금지)

**이 저장소에서 여는 세션은 원격 Linux 컨테이너다.** 실배포 Windows PC 가 아니다.
아래는 세션마다 다시 판단하지 말고 **확정 사실로 취급한다.**

## 플랫폼 제약 1 — PowerShell 런타임 자산

| 대상 | 사유 |
|---|---|
| `.claude/tools/render_pptx.ps1` | PowerPoint COM 필요 — 최종 렌더는 로컬 Windows PC. 이 컨테이너의 덱 렌더 게이트(게이트 2·3 — visual-design 스킬 `references/pptx/qa_procedure.md` §2-1)는 LibreOffice(Impress 부품) → PDF → 래스터 근사 경로로 돈다 |

단 **정적·로직 검증은 이 컨테이너에서 가능**하다 — pwsh(7)를 설치하면 `.ps1` 구문 파싱·.NET regex·헬퍼 동작을 실측할 수 있다(실증됨). **PS 5.1 특유 런타임 동작**(예: `$ErrorActionPreference='Stop'` 하 네이티브 stderr 격상)만 pwsh 로 재현 불가라 실배포 Windows 5.1 몫이다. 덱 PPTX 생성(pptxgenjs `node deck.js`)도 Linux 가능하다. Office 문서 렌더는 이 컨테이너(클라우드)에서 LibreOffice(형식별 부품) → PDF → 래스터로 근사하고 최종 렌더(Office COM — PowerPoint·Word·Excel)는 로컬 Windows PC 몫이다. 재계산·변환·변경 추적 수락은 이 컨테이너에선 LibreOffice 가 처리하고 그 결과를 그대로 쓴다(같은 명령이 Windows 에선 Office COM — 각 문서 스킬).

## 플랫폼 제약 2 — Windows 지향 스킬·지침은 "내용"도 이 환경에선 N/A (Linux 등가물)

이 패키지는 사용자 Windows(기업 보안망) 기준으로 저작됐다. **방법론 계열**(세션 분업·계획·검수·단위 루프·모델 배분 등)은 플랫폼 무관하게 그대로 적용되나, 아래 **Windows 운영 세부**는 이 Linux 컨테이너에서 그대로 따르지 않고 Linux 등가물을 쓴다:

| Windows 지향 지침·스킬 | 이 환경(Linux)에선 |
|---|---|
| `skill:skill_LKS_original_secured-windows-tooling` · 헌법 PowerShell·winget·Windows Python 줄 | PowerShell→`bash`·`curl` / winget→`apt`·공식 릴리스 / `python`→`python3`. **`다운로드·설치해·인코딩` 트리거에 반응해 PowerShell 로 끌지 말 것** |
| `skill:skill_JJH_original_local_web_service` (작업 스케줄러·방화벽 인바운드) | `systemd`·`ufw` 등가물 |
| `skill:skill_LKS_original_ocr-image-extraction` 의 `ocr_engine_ops.md`·`setup_ocr_engines_windows.ps1` (Windows GPU 셋업) | Linux PaddleOCR = `apt`/`pip` 설치. Windows GPU 레시피(nvidia-*-cu12 wheel·modelscope stub·nvrtc)는 미적용. **판독 방법론(3단계 cross-check·프레임 스캔)은 그대로 유효** |
| `skill:skill_LKS_original_visual-design` 의 PPTX 어댑터 PPT COM 렌더 | pptxgenjs 빌드는 Linux 가능 · 렌더는 LibreOffice(Impress 부품) → PDF → 래스터로 근사(부품 없으면 `sudo apt-get install -y libreoffice-impress`) · 최종 렌더(Office COM)는 로컬 Windows PC |

헌법의 Windows 지침 대부분은 `적용 = Windows·보안망일 때` 로 **조건부 게이트**돼 Linux 조건 불충족 시 자동 미적용이다. 위 표는 그 게이트가 넓은 트리거로 **오발하는 것을 막는 명시 확인**이다. (docx·pdf·xlsx·decrypt 는 python 라이브러리라 cross-platform — 그대로 유효.)

## 사본 구성

이 사본은 Mac·Linux 설치본과 같은 구성이다(MATLAB 줄 제외 · 원본 = lksz1412/Project_skills 1.4.9 의 저장소용 사본 · 도구는 배포 구성대로 `.claude/tools/` 에 둠). MATLAB·Simulink 는 Windows 의 MATLAB 계열(Settings_for_MATLAB_MCP) 몫이라 이 컨테이너에 없다.

## master effort

이 클라우드 세션의 effort 는 앱에서 세션을 열 때 고른 값(명령 줄 층)이 저장소 `.claude/settings.json` 의 `modelSettings` 보다 앞선다 — 세션 기록 assistant 행 `effort` 칸이 medium 이 아니면 사용자에게 앱에서 medium 을 고르라고 알린다.

## 휘발성

컨테이너는 세션마다 새로 뜨고 종료·유휴 시 회수된다. 전역 설치물과 홈 디렉터리는 남지 않는다.
**남는 것은 이 저장소에 커밋된 것뿐이다.**

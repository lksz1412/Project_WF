---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_original_source-research
description: >
  논문·학술 자료를 조사하거나 유튜브·커뮤니티·웹에서 정보를 수집·검토하고
  출처를 검증할 때 사용한다. 진입 시 프로젝트 성격으로 두 모드 중 하나를 고른다 —
  모드 A(학술/논문)는 arXiv·Crossref·Semantic Scholar·PubMed 공개 API 를 무인증으로
  직접 조회하고 인용 URL/DOI 가 실제 resolve 되는지 기계 검증해 허위 인용을 잡는다;
  모드 B(유튜브·커뮤니티)는 시간창·발견→정밀타격 2단계·참여도 가중으로 검색하고
  자막을 우선 추출·요약한다(무자막은 전사 폴백 — 설계만). 근거는 4-tier 로 보고한다.
  트리거: "논문 찾아줘", "학술 자료 조사", "arXiv 검색", "DOI 확인", "인용 검증",
  "레퍼런스 수집", "유튜브 찾아 요약", "자막 추출", "커뮤니티 반응 조사", "레딧 검색",
  "최신 정보 수집", "출처 검증", "paper search", "citation check", "youtube transcript",
  "source research".
metadata:
  type: method
---

# Source Research (자료 수집·검토)

논문·학술 원천이나 유튜브·커뮤니티·웹에서 **자료를 모으고, 통일된 형식으로 정리하고, 출처가 실재하는지 검증**하는 상류(上流) 수집 스킬. 이미지 판독(`ocr-image-extraction`)·문서 파일 읽기(`decrypt`)·논문 저작(`visual-design` 의 LaTeX 어댑터)이 맡는 하류(판독·저작)와 역할이 다르다 — 이 스킬은 "무엇을·어디서·어떻게 가져오고, 그것이 실재하는가"까지다.

**내부 두 모드는 배타적이다.** 진입 시 프로젝트 성격으로 하나를 고르고, 한 작업에서 두 절차를 섞지 않는다.

## 적용 조건

학술 논문·레퍼런스를 찾거나, 유튜브·커뮤니티·웹에서 정보를 수집·교차검토하거나, 이미 확보한 인용·링크가 실재하는지 검증할 때 적용한다. 단발 사실 즉답(현재 세션에서 바로 답할 수 있는 것)은 대상이 아니다 — 헌법 「검색」 줄로 충분하다.

## 핵심 원칙

- **무인증·공개 경로 우선.** 키가 필요 없는 공개 API·엔드포인트를 먼저 쓴다. 키가 있어야 하는 경로(예: YouTube Data API)는 키가 없으면 무인증 대체 경로로 우회하고, **키를 지어내지 않는다.**
- **최신 원천.** 질문 시점 기준으로 다시 조회한다. 학습 시점의 기억을 "조사 결과"로 부르지 않는다.
- **출처는 실물 링크로 기록.** 모든 확정 사실에 원천 URL(학술은 DOI 우선)과 취득일을 붙인다.
- **4-tier 근거로 보고.** 확정(근거 첨부) · 근거미발견 · 추정(추정이라 명시) · 미검증 으로 가른다. 못 찾으면 빈칸을 추측으로 채우지 않고 "근거미발견"으로 보고한다.
- **모드 배타.** 진입에서 고른 한 모드의 절차만 밟는다. 한 작업이 학술과 커뮤니티를 모두 요구하면 **별도 패스로 순차** 수행하고 두 절차를 한 흐름에 섞지 않는다.

## 실행 방법

### 진입 — 모드 판별 (택1)

자료의 성격으로 하나를 고른다:

- **모드 A (학술/논문)** — 논문·프리프린트·학술 레퍼런스·DOI·인용 검증이 대상일 때.
- **모드 B (유튜브·커뮤니티)** — 영상·커뮤니티 글·블로그·최신 여론 등 비학술 웹 정보가 대상일 때.

애매하면: 검증 가능한 학술 식별자(DOI·arXiv ID)가 오가면 A, 아니면 B.

---

### 모드 A — 학술/논문

#### 소스·API (무인증 직접 조회)

런타임에서 `curl`(또는 WebFetch)로 아래 공개 API 를 직접 친다. 여러 소스를 병렬로 조회한 뒤 DOI 로 병합한다.

| 소스 | 엔드포인트 | 용도 | 비고 |
|---|---|---|---|
| **arXiv** | `https://export.arxiv.org/api/query?search_query=...&max_results=N` | 프리프린트 검색 | Atom XML · 리다이렉트 따름(`curl -L`) |
| **Crossref** | 검색 `https://api.crossref.org/works?query=...&rows=N` · DOI `https://api.crossref.org/works/{DOI}` | 발행물·DOI 메타 | `mailto=<you>` 붙여 polite pool |
| **Semantic Scholar** | `https://api.semanticscholar.org/graph/v1/paper/search?query=...&fields=title,authors,year,externalIds,url` | 인용·필드 | 무인증은 공유 rate — **429 잦음**(백오프·키·Crossref 대체) |
| **PubMed E-utilities** | esearch `.../esearch.fcgi?db=pubmed&term=...&retmode=json` → 결과 PMID 로 esummary/efetch | 생의학 | 키는 rate 상향만 |

```bash
curl -sL "https://export.arxiv.org/api/query?search_query=all:graphene&max_results=5"
curl -s  "https://api.crossref.org/works/10.1038/nature12373?mailto=<you>"
```

#### 결과 정리 양식 (통일)

모든 히트를 같은 필드로 정규화한다: **제목 · 저자 · 연도 · DOI(있으면) · URL · (출처 API)**. 여러 API 병합 시 **DOI 로 중복 제거**한다(같은 논문이 arXiv·Crossref 양쪽에 잡히면 하나로).

#### 인용 게이트 (필수 — 허위 인용 검출)

확보했거나 초안에서 생성된 **모든 인용은 사용자에게 제시하기 전에 실재를 기계 검증**한다:

- **DOI** — `curl -sI -o /dev/null -w "%{http_code}" https://doi.org/{DOI}` → **30x(예 302) = resolve, 404 = 미존재.** (게이트에서는 리다이렉트를 따르지 않는다 — 첫 홉으로 존재만 판정.) 확실히 하려면 Crossref `/works/{DOI}` 를 200/404 로 교차확인하고, **반환 메타의 제목·저자를 대조**해 "DOI 는 실재하나 제목이 다른" 허위를 잡는다.
- **arXiv ID** — `https://arxiv.org/abs/{ID}` HEAD 200 확인.
- **일반 URL** — HEAD 200/30x 확인, 죽은 링크(404·타임아웃)는 표시.

검증 실패한 인용은 **"미검증" 또는 "근거미발견"으로 강등**하고, 실재 확인 전에는 확정으로 제시하지 않는다. 모델이 그럴듯하게 지어낸 DOI·제목은 이 게이트에서 걸린다.

#### general web

논문 초록·저자 소속 등 **보조 맥락에만** 일반 웹을 쓴다. 일반 웹 페이지를 1차 학술 근거로 승격하지 않는다 — 반드시 원천 논문·DOI 로 환원한다.

---

### 모드 B — 유튜브·커뮤니티

#### 검색 (시간창 · 발견→정밀타격 2단계 · 가중)

1. **시간창 명시** — 쿼리에 기간을 못박는다(예: 최근 30일 · 최근 1년). 보고에도 창을 밝힌다. 시효 지난 결과가 최신으로 위장하는 것을 막는다.
2. **발견(광역)** — 넓게 훑어 지형을 그린다. 다수 원천·낮은 깊이 · 검색어 변주 · 플랫폼 교차.
3. **정밀타격(협역)** — 신호가 가장 센 소수로 좁혀 깊게 읽고 추출한다.
4. **가중** — 참여도(조회·추천·댓글)와 **교차출처 확증**이 높은 항목을 우선한다. 단일 출처·미확증 주장은 후순위이자 "미검증".

#### 추출·요약 (필수 — 자막 우선)

링크만 모으지 말고 **내용을 뽑아 요약까지** 낸다.

- **자막 우선(경량 경로)** — 유튜브는 자막/캡션을 먼저 취득한다. **자막 전용 경량 라이브러리(pure-Python · yt-dlp·ffmpeg 불요)** 예: `youtube-transcript-api`. 미설치면 그 하나만 설치하거나, 자막 트랙(플레이어 응답의 caption track · `timedtext` URL)을 직접 받거나, WebFetch 로 페이지·자막을 읽는다(사내망 pip 차단 시 → 「관련」 secured-windows-tooling).

```bash
pip install youtube-transcript-api
# 현행 API = 인스턴스화 후 .fetch() · 스니펫은 s.text (버전 바뀌면 라이브러리 README 확인)
python -c "from youtube_transcript_api import YouTubeTranscriptApi as A; print(' '.join(s.text for s in A().fetch('<VIDEO_ID>')))"
```
> 자막 fetch 는 datacenter·클라우드 IP 에서 차단(`IpBlocked`)될 수 있다 — 실사용 개인 PC 네트워크에서 돌리고, 막히면 WebFetch·`timedtext` 로 대체.
- **커뮤니티 글**은 본문·상위 댓글을 읽어 논점·합의·반론을 요약한다.
- 요약에도 **4-tier · 출처 링크 · (영상)타임스탬프**를 유지한다.

#### 무자막 전사 폴백 (이 스킬 = 설계·조건만)

자막이 없는 영상만 오디오 전사로 폴백한다 — **무겁다.** 이 스킬에는 전사 절차가 없다 — 필요 도구·조건만 적어 둔다:

- 필요: 오디오 추출기(yt-dlp 계열) + 디코더(ffmpeg) + ASR(Whisper 계열).
- 셋이 그 환경에 깔려 있어도 이 스킬로는 이 경로에 들어가지 않고 **"자막 없음 → 전사 필요(미수행)"로 보고**한다.

#### 플랫폼 라우팅표 (1차 → 대체)

| 플랫폼 | 1차 경로 | 대체(fallback) |
|---|---|---|
| **YouTube** | 검색 = WebSearch `site:youtube.com`(키 있으면 Data API) · 내용 = 자막 우선 | 자막 없음 → 전사 폴백(설계만) / 페이지 WebFetch |
| **Reddit** | `https://www.reddit.com/search.json?q=...` · 스레드 `<url>.json` | **datacenter IP 는 403 잦음** → WebSearch `site:reddit.com` 우선(안정) · `old.reddit.com` 은 로그인월(302→403)에 막힐 수 있어 후순위 |
| **Hacker News** | Algolia `https://hn.algolia.com/api/v1/search?query=...&tags=story`(최신순 `search_by_date`) | WebFetch 스레드 |
| **X·기타 SNS** | 무인증 API 없음 → WebSearch + WebFetch | 미러 불안정 — 확보분만·"미검증" 표기 |
| **일반 커뮤니티·블로그** | WebSearch 발견 → WebFetch 정독 | 캐시·아카이브 링크 |

어떤 경로든 실패하면 다음 대체로 내려가고, **전부 실패하면 "근거미발견"으로 정직 보고**한다(무한 재시도·추측 금지).

## 검증

사용자 보고 전에 확인한다:

- **모드 A** — 제시하는 모든 인용이 인용 게이트(DOI/URL resolve)를 통과했는가. 미존재·죽은 링크를 확정으로 올리지 않았는가. 병합 결과에 DOI 중복이 남지 않았는가.
- **모드 B** — 각 항목에 출처 링크·취득일·(영상)타임스탬프가 있는가. 시간창을 밝혔는가. 단일 출처 주장을 교차확증 없이 확정으로 올리지 않았는가.
- **공통** — 4-tier 분류가 붙었는가. 확정에 근거 URL 이 있는가. 못 찾은 것을 추측으로 채우지 않았는가.

## 예외·금지

- 두 모드를 한 흐름에 섞지 않는다(순차 별도 패스는 허용).
- 무인증 rate limit(예: Semantic Scholar 429)을 무시하고 연타하지 않는다 — 백오프·대체 경로·`mailto` polite pool 을 쓴다.
- 검증 안 된 인용·링크를 확정으로 제시하지 않는다(인용 게이트 미통과 = 강등).
- 없는 API 키를 지어내거나, 무인증으로 안 되는 것을 된다고 가정하지 않는다.
- 이 스킬로 무자막 오디오 전사를 실제 수행하지 않는다(전사 절차 없음 · 설계·조건만).
- 학습 시점 기억을 "조사 결과"로 제시하지 않는다.
- 라우팅 전 경로 실패 시 무한 재시도·빈칸 추측 금지 — "근거미발견"으로 보고한다.

## 관련

- 헌법 「자료 수집·검토」 줄이 이 스킬을 라우팅한다 — 이 스킬이 그 절차의 원본이다(단발 즉답·경량 검색은 「검색」 줄 소관).
- `memory:feedback_confirmed_items_policy`(4-tier 보고 규범) · `memory:feedback_communication_style`(용어·조용한 적용).
- 하류 연계: `skill:skill_LKS_original_ocr-image-extraction`(이미지·스캔에서 텍스트) · `skill:skill_LKS_custom_document` `references/decrypt/GUIDE.md`(문서 파일 읽기) · `skill:skill_LKS_original_data-pipeline`(확보한 데이터의 파싱·처리·산출)<!--ih--> · `skill:skill_LKS_original_visual-design`(수집한 논문으로 저작)<!--/ih-->.
- 런타임 도구: WebSearch·WebFetch(발견·페이지 읽기) · Bash `curl`(API 직접 조회).
- 사내망 설치 장벽: pip·바이너리 설치가 TLS 인터셉션·패키지 차단에 막히면 → `skill:skill_LKS_original_secured-windows-tooling`.

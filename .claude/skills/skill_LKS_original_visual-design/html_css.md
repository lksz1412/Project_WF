# HTML/CSS 도식 어댑터 (플로우차트·페이지 속 흐름도 — 상속 CSS 컴포넌트)

코어 규칙(압축·통일·타이포 원리·다이어그램·정렬)은 `core_principles.md`, 접근성은 `accessibility.md`, **페이지 전체 토큰(배경·본문·색 램프·다크·한글 타이포·간격)은 `web_page.md`**. 여기는 **HTML 도식 매체 수단** — 페이지 토큰을 먼저 고정하고 도식이 그것을 상속한다.

**대상 분기**:

| 대상 | 외부 의존 | 이 어댑터 |
|---|---|---|
| 오프라인 자기완결 HTML | CDN·웹폰트·MathJax **금지**(§4) | 전 절 적용 |
| claude.ai **Artifact**(별도 환경 — CDN 허용) | 그 환경 규칙 — Anthropic `artifact-design` 스킬에는 **매체 수단만** 위임 | §4(오프라인 규칙)만 빼고 적용 |

---

## 1. 손코딩 SVG 금지 → 상속 CSS 컴포넌트

| 규칙 |
|---|
| 손좌표 SVG 도식 = viewBox·폰트·박스폭·여백이 제각각 → **절대 통일 안 됨**(뷰박스 폭 다르면 같은 font-size 도 다른 크기로 렌더) |
| 해법 = **HTML/CSS div 박스** — 폰트·여백·폭이 문서 CSS 상속·공유해 구조적 100% 통일 |
| 반복 도식은 상속 컴포넌트로. 상태 글리프 벡터는 허용(금지 대상 = 통일 깨는 손좌표 도식) |

| 요소 | 클래스 |
|---|---|
| 노드 | `div.fbox` |
| 세로 흐름 | `div.flowcol` |
| 분기·병렬(가로) | `div.frow` |
| 가로 순차 흐름(좌→우) | `div.hflow` |
| 행 대응(행마다 좌→우 짝) | `div.hmap` · 열 머리 `div.colh` |
| 아래 화살표 | `div.farrow` |
| 오른쪽 화살표 · 위 라벨 | `div.harrow` · 라벨 `span.lbl` |
| 구역 라벨 | `div.zone` |
| 전체 틀 | `div.flowframe` |
| 상태색 | 클래스(`.rx/.px/.mx/.goal/.plain`) |
| 강조(시각 단위당 한 곳) | 클래스 `.emph` |
| 숨김 글자(스크린리더 전용) | `span.sr-only` |

## 2. 도식 내부 타이포 — 2단계 상속 (px)

**페이지 본문은 `web_page.md` §3(한글 본문 17px)을 따른다** — 이 절은 도식 박스 안에만 적용(도식 크기가 페이지 본문 크기를 정하지 않는다).

| 층 | 크기 |
|---|---|
| 도식 본문(박스 설명·항목) | 예 15px(KRDS Body-s) |
| 박스 제목/항목명(절 제목급) | 예 19px(KRDS Heading-s) |

**딱 두 크기만.** 15/15.5/14.5/13 처럼 잡다한 크기 섞이면 도식마다 달라 보임. HTML/CSS 상속이면 자동 보장(SVG 는 수동이라 실패).

## 3. 레이아웃·정렬

| 규칙 |
|---|
| 프레임 폭 = 본문 컬럼 폭 · **단일 프레임** — 같은 영역을 테두리 두 겹으로 감싸지 않음(구획 테두리 + 틀 테두리 금지 · 틀 안 노드 테두리는 해당 없음 — §6-2) |
| 박스 폭 = `max-width` 고정 + 중앙. 한 도식 안 모든 박스 동일 폭 |
| **분기(`.frow`)도 단일 박스와 동일 `max-width` 중앙** — 전체 폭 채우면 위아래 박스와 외곽 어긋남 |
| 수직 리듬 균일 — 구역→첫박스 0px 붙임 금지, 분기 지점에도 화살표 삽입해 간격 통일 |
| 한글 줄바꿈 = 페이지 규칙 그대로(`keep-all` + `overflow-wrap:anywhere` 병행 · 병행 이유·표 칸·가운뎃점 예외의 원본 = `web_page.md` §3) — 도식 박스(`.fbox`)도 같은 2줄(§6-2) · 오버플로(2줄 감김) 방치 금지 |

## 4. 오프라인 자기완결

페이지 규칙 그대로 — 외부 CDN·MathJax·웹폰트 금지 · 수식·아이콘 표기 · 외부 의존 0 검사의 원본 = `web_page.md` 「대상 분기」 오프라인 행(검사 = 같은 파일 §7 「외부 의존」 행). 도식에 따로 더하는 오프라인 규칙은 없다.

**Artifact 예외**: claude.ai Artifact 는 CDN 허용 환경 → **이 §4 만 제외**(외부 의존은 그 환경 규칙 · `artifact-design` 스킬에는 매체 수단만 위임) · 나머지 절(컴포넌트·타이포·정렬·검증)은 그대로 적용.

## 5. 검증 (HTML)

| 방법 |
|---|
| 만들거나 고칠 때마다 **브라우저 렌더 → 육안 → 통과 시에만 전달** |
| JS 객관 측정 — 모든 프레임 `getBoundingClientRect().width` 동일 · `computed font-size` 집합이 의도한 2값뿐 · 오버플로 0(숨김 글자 `.sr-only` 는 측정에서 뺌) · 콘솔 에러 0 · 테두리 굵기는 배율 1·2 렌더 둘 다(§6-1 · 배율 2 = 크롬 `--force-device-scale-factor=2` — `web_page.md` §7 캡처 조건과 같게) |
| 페이지 공통 측정(정적 스냅샷 강제 스크롤 · 판정 폭 1280px + 640px 1회 · 콘솔 에러 0)·외부 의존 0 검사 = `web_page.md` §7 「렌더」·「외부 의존」 행 — 도식도 그대로 |
| 색·한글 게이트(대비·채도·유채 면적·한글 타이포 · 라이트·다크 각각) = `web_page.md` §7 — 도식의 테두리·상태면 색도 같은 게이트(도식 변수 쌍 = §6-1 「도식 게이트」) |

## 6. 재사용 CSS 컴포넌트 (플로우차트 시스템 · 렌더로 검증한 값)

> 색은 문서의 CSS 변수(중성 `--bg2`·`--bg3`·`--border2`·`--fg2`·`--fg3`·`--shadow` · 상태 `--ok`·`--ok-bg`·`--warn`·`--warn-bg`·`--ext`·`--ext-bg`·`--crit` · 강조 = 페이지 토큰 `--accent`)를 상속 — 값 = §6-1 대응 블록(중성은 **웹 매체용 팔레트** `web_page.md` 토큰을 가리키고 상태색은 웹 매체 기준값) · 덱 등 타 매체 팔레트 이식 금지(코어 §2) · 상태색은 의미·데이터색(`accessibility.md` §3 — 채도 예산 밖 · 명시값). **크기 값 = 페이지 토큰**(`web_page.md` §5 · 리터럴 금지 — 코어 §2): 간격(margin·padding·gap) = 8pt 격자 `--s-*`(`web_page.md` §4) · 글자 = 19·15px 두 크기 `--fs-h-s`·`--fs-body-s`(§2) · 행간 `--lh` · 반경 = 유형별 토큰(`web_page.md` §4 — 틀 `--r-xl` 12 · 박스 `--r-l` 10 · 구역 `--r-m` 6px · 같은 유형은 높이가 달라도 같은 토큰). 토큰 없는 값만 리터럴 = 테두리 굵기(정수 1·2·4px — §6-1) · 화살표 삼각형 치수 · 레이아웃 폭(`max-width`·`flex-basis`·화살표 칸 `width`) · 이중선 틈(`outline-offset`) · 숨김 글자(`.sr-only`) 1px · 그림자.

### 6-1. 도식 변수 ↔ 페이지 토큰 대응 블록

페이지 토큰 블록(`web_page.md` §5) **뒤에** 둔다 — 중성 변수는 `var(--n-*)` 로 가리켜 다크가 자동으로 따라오고, 상태색은 웹 매체 기준값을 라이트·다크 두 벌로 둔다.

| 변수 | 값 | 쓰임 | 판정(라이트·다크 각각) |
|---|---|---|---|
| `--bg2` | `var(--n-1)` | 틀(`.flowframe`) 배경 | 경계·화살표·상태 테두리의 인접 배경 |
| `--bg3` | `var(--n-2)` | 박스·구역 배경 | 글자·경계의 배경 |
| `--border2` | `var(--n-7)` | 틀·박스·구역 테두리(정보 경계) | vs `--n-0`·`--bg2`·`--bg3` ≥ 3:1 |
| `--fg2` | `var(--n-9)` | 박스 설명 글자(`.d`) · 화살표 라벨·열 머리(`.lbl`·`.colh` — 틀 배경 위) | vs `--bg3`·`--bg2`·상태 `-bg` ≥ 4.5:1 |
| `--fg3` | `var(--n-7)` | 화살표(`.farrow`·`.harrow` · 비텍스트) | vs `--bg2` ≥ 3:1 |
| (상속) | `--n-10` | 박스 제목·본문·구역 라벨 글자 | vs `--bg3`·상태 `-bg` ≥ 4.5:1 |
| (페이지 토큰) | `--accent` | 강조 노드 테두리(`.emph`) | vs `--bg3`·`--bg2` ≥ 3:1 |
| `--shadow` | 라이트 `oklch(0 0 0 / 0.08)` · 다크 `transparent` | 틀 그림자 | 판정 없음 — 다크 층 = 표면 명도 차이(`web_page.md` §2) |
| `--ok`·`--warn`·`--ext` + `-bg` | 아래 블록 | 상태 박스 테두리·면(`.rx`·`.px`·`.mx`) | 테두리 vs 자기 `-bg`·`--bg2` ≥ 3:1 · `-bg` 위 `--n-10`·`--fg2` ≥ 4.5:1 |
| `--crit` | 아래 블록 | 목표 박스 테두리(`.goal` · 면 = `--bg3`) | vs `--bg3`·`--bg2` ≥ 3:1 |

| 규칙 |
|---|
| 장식 단계 `--n-5`·`--n-6` 은 도식 변수에 쓰지 않는다 — 정보 경계·글자 금지(`web_page.md` §6-5) |
| 상태색 = 상태마다 hue 고정(ok 150 · warn 75 · ext 305 · crit 25) · 다크 = 테두리색은 명도↑(채도는 같거나 낮춤 — ok·warn 유지 · ext·crit 낮춤) · 면(`-bg`)은 어둡게(L 0.96 → 0.29)·채도 0.045~0.050(어두운 면에서 색이 보이도록) · 전부 sRGB 안(clip 없음) · 라이트·다크 두 벌 = 웹 매체 정책(`accessibility.md` §6 ②) |
| **상태 = 색 + 모양** — 색을 빼도 4종이 갈린다(SC 1.4.1 · `accessibility.md` §1): 완료 `.rx` 실선 ✓ · 경고 `.px` 실선 + 왼쪽 띠 ▲ · 외부 `.mx` 점선(dashed) ↗ · 목표 `.goal` 이중선 ◎ · 기호 = 제목 앞 `::before` + 스크린리더용 대체 글자(상태 이름) — **상태 상자는 제목(`.t`) 필수**(제목이 없으면 기호가 사라져 흑백에서 색만 남음) · 테두리 굵기 = 노드와 같은 2px — 이중선 = 테두리 2 + 틈 2 + 안쪽 `outline` 2(`double` 은 2px 에서 배율 1 이면 실선 · 배율 2 면 가는 이중선 — 배율마다 모양이 갈림), 띠 = 안쪽 `box-shadow` 4px(박스 크기 그대로) · 확인 = 렌더를 흑백으로 바꿔 4종 구분 — 배율 1(100%)·2 둘 다 |
| **테두리 굵기 = 정수 px 3단** — 1px 틀·구역(가벼운 경계) · 2px 노드·상태(정보 단위) · 4px 강조(테두리 2 + 안쪽 2)(2배씩) · 경고 띠 = 안쪽 4px(왼쪽은 테두리 2 와 같은 색이라 합쳐 6px 로 보임 — 흑백 구분은 이 모양으로 확인됨) · 소수 px 금지와 그 이유의 원본 = `web_page.md` §4 「테두리 굵기」(도식에선 틀과 노드 무게가 같아지고 이중선·띠가 얇아짐) · 확인 = 배율 1·2 렌더 |
| **도식 게이트** = `python <설치경로>/tools/check_color_tokens.py <페이지.html> --pairs <설치경로>/tools/color_pairs_diagram.json`(`<설치경로>` = SKILL.md 「도구 경로」) — 위 판정 쌍 · 장식 단계 참조 금지 · 중성 변수 채도를 라이트·다크 각각 기계 판정(페이지 기준 11쌍 포함 · 사용법 = `web_page.md` §7) · 상태색을 안 쓰는 도식은 상태 쌍이 "판정 밖"으로 표시(FAIL 아님 · 참조하는데 정의가 없으면 FAIL — 상태색 정의를 빼려면 §6-2 의 상태 규칙 `.rx`·`.px`·`.mx`·`.goal` 과 그 `::before` 줄도 함께 뺀다 · 가장 쉬운 길은 §6-1 블록 통째 유지) · 값을 바꾸면 재실행 |
| 아래 기준값 실측(도구 · `web_page.md` §5 페이지 토큰과 함께) = 3:1 쌍 최저 라이트 3.86(warn 테두리 / warn 면) · 다크 3.55(박스 경계 / 박스 배경) · 글자 쌍 최저 라이트 9.10 · 다크 8.47 — 전건 PASS |

```css
/* 도식 변수 ↔ 페이지 토큰 — web_page.md §5 블록 뒤에 둔다 */
:root{
  --bg2:     var(--n-1);   /* 틀 배경 */
  --bg3:     var(--n-2);   /* 박스·구역 배경 */
  --border2: var(--n-7);   /* 정보 경계 — 인접 배경 대비 3:1 */
  --fg2:     var(--n-9);   /* 박스 설명 글자 — 4.5:1 */
  --fg3:     var(--n-7);   /* 화살표(비텍스트) — 3:1 */
  --shadow:  oklch(0 0 0 / 0.08);

  /* 상태색(의미색 · 채도 예산 밖) — 웹 매체 기준값 */
  --ok:   oklch(0.560 0.130 150);  --ok-bg:   oklch(0.960 0.030 150);  /* #2D8949 / #E4F8E7 */
  --warn: oklch(0.580 0.115 75);   --warn-bg: oklch(0.960 0.030 75);   /* #A26F17 / #FEEFDC */
  --ext:  oklch(0.560 0.150 305);  --ext-bg:  oklch(0.960 0.020 305);  /* #8959BA / #F5EFFD */
  --crit: oklch(0.560 0.190 25);                                        /* #CC3336 */
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --shadow: transparent;   /* 다크 층 = 표면 명도 차이 */
    --ok:   oklch(0.720 0.130 150);  --ok-bg:   oklch(0.290 0.045 150);  /* #62BB78 / #1A321F */
    --warn: oklch(0.760 0.115 75);   --warn-bg: oklch(0.290 0.045 75);   /* #DCA657 / #382810 */
    --ext:  oklch(0.720 0.130 305);  --ext-bg:  oklch(0.290 0.050 305);  /* #B88FE6 / #31253F */
    --crit: oklch(0.700 0.150 25);                                        /* #ED756E */
  }
}
:root[data-theme="dark"]{   /* 강제 다크 — 위 미디어 블록과 같은 값 한 벌 */
  --shadow: transparent;
  --ok:   oklch(0.720 0.130 150);  --ok-bg:   oklch(0.290 0.045 150);
  --warn: oklch(0.760 0.115 75);   --warn-bg: oklch(0.290 0.045 75);
  --ext:  oklch(0.720 0.130 305);  --ext-bg:  oklch(0.290 0.050 305);
  --crit: oklch(0.700 0.150 25);
}
```

### 6-2. 컴포넌트

```css
/* 전체 틀 = 본문 컬럼 폭, 대칭 패딩, 단일 테두리 1px(가벼운 경계 — 노드 2px 보다 가볍게) */
.flowframe{box-sizing:border-box;border:1px solid var(--border2);border-radius:var(--r-xl);background:var(--bg2);
  box-shadow:0 1px 3px var(--shadow);padding:var(--s-5);margin:var(--s-4) 0;
  font-size:var(--fs-body-s)}   /* 도식 안 기준 크기 15px — 페이지 본문 17px 을 물려받지 않게 */

/* 세로 흐름 / 분기(가로) */
.flowcol{display:flex;flex-direction:column;align-items:center;gap:0}
.frow{display:flex;gap:var(--s-4);justify-content:center;flex-wrap:wrap;align-items:stretch;
  width:100%;max-width:660px;margin:0 auto}          /* ★ 단일 박스와 좌우 정렬 */
.frow>.fbox,.frow>.flowcol{flex:1 1 240px;width:auto}

/* 노드 박스 — 폭 고정·중앙, 테두리 2px(정보 단위), 한글 keep-all */
.fbox{box-sizing:border-box;width:100%;max-width:660px;border:2px solid var(--border2);border-radius:var(--r-l);
  background:var(--bg3);padding:var(--s-3) var(--s-4);text-align:center;
  word-break:keep-all;overflow-wrap:anywhere}
/* 상태 = 색(단일 의미축) + 모양 — 색을 빼도 4종이 갈린다: 테두리 모양 4종 + 제목 앞 기호 4종
   (테두리는 노드와 같은 2px · 이중선 = 테두리 2 + 틈 2 + 안쪽 outline 2 · 띠 = 안쪽 box-shadow 4 — 박스 크기 그대로) */
.fbox.rx{border-color:var(--ok);background:var(--ok-bg)}                        /* 완료 = 실선 + ✓ */
.fbox.px{border-color:var(--warn);background:var(--warn-bg);
  box-shadow:inset 4px 0 0 var(--warn)}                                         /* 경고 = 실선 + 왼쪽 띠 + ▲ */
.fbox.mx{border-color:var(--ext);background:var(--ext-bg);border-style:dashed}  /* 외부 = 점선 + ↗ */
.fbox.goal{border-color:var(--crit);
  outline:2px solid var(--crit);outline-offset:-6px}                           /* 목표 = 이중선 + ◎ */
.fbox.plain{background:var(--bg3)}          /* 구조 도식 중립 */
.fbox.rx .t::before,.fbox.px .t::before,.fbox.mx .t::before,.fbox.goal .t::before{margin-right:var(--s-1)}
.fbox.rx .t::before{content:"✓";content:"✓" / "완료 "}      /* 두 번째 선언 = 스크린리더용 대체 글자 */
.fbox.px .t::before{content:"▲";content:"▲" / "경고 "}
.fbox.mx .t::before{content:"↗";content:"↗" / "외부 "}
.fbox.goal .t::before{content:"◎";content:"◎" / "목표 "}
/* 강조(시각 단위당 한 곳 · 구조 도식) — 테두리 2 + 안쪽 2 = 4px 강조색 · 박스 크기 그대로 */
.fbox.emph{border-color:var(--accent);box-shadow:inset 0 0 0 2px var(--accent)}

/* 타이포 — 2단계만: 제목 19px(--fs-h-s · KRDS Heading-s) · 본문 15px(--fs-body-s · Body-s) · 행간 --lh(1.5) */
.fbox .t{font-size:var(--fs-h-s);font-weight:700;line-height:var(--lh)}
.fbox .d,.fbox .n{font-size:var(--fs-body-s);line-height:var(--lh)}
.fbox .d{color:var(--fg2)}
.fbox .n{font-weight:700}
/* 줄 사이만 4px — 첫 줄 위·끝 줄 아래 바깥 여백 0 → 위아래 = 패딩 12px 대칭(제목만 있는 상자 포함) */
.fbox>*{margin:0}
.fbox>*+*{margin-top:var(--s-1)}

/* 아래 화살표(분기 지점에도 삽입해 간격 통일) */
.farrow{width:0;height:0;border-left:7px solid transparent;border-right:7px solid transparent;
  border-top:10px solid var(--fg3);margin:var(--s-2) auto}

/* 구역 라벨 — 박스와 동일 폭, 간격 리듬 일치, 테두리 1px(라벨 — 노드보다 가볍게) */
.zone{box-sizing:border-box;display:flex;align-items:center;gap:var(--s-2);justify-content:center;
  font-size:var(--fs-body-s);font-weight:700;background:var(--bg3);border:1px solid var(--border2);
  border-radius:var(--r-m);padding:var(--s-2) var(--s-4);margin:var(--s-1) auto var(--s-4);width:100%;max-width:660px}

/* 가로 순차 흐름(좌→우) · 행 대응(행마다 좌→우 짝) — 상자 폭 균등 · 화살표 칸 폭 고정(간격 균일) */
.hflow{display:flex;align-items:stretch;width:100%;max-width:660px;margin:0 auto}
.hflow>.fbox{flex:1 1 0}
.hflow>.fbox,.hmap>.fbox{width:auto;min-width:0;display:flex;flex-direction:column;justify-content:center}
.hmap{display:grid;grid-template-columns:minmax(0,1fr) auto minmax(0,1fr);   /* 가운데 열 = 화살표 칸 폭 */
  row-gap:var(--s-4);width:100%;max-width:660px;margin:0 auto}
.hmap .colh{font-size:var(--fs-body-s);font-weight:700;line-height:var(--lh);color:var(--fg2);text-align:center}
.hmap .colh+.colh{grid-column:3}                /* 오른쪽 열 머리 = 3열(화살표 열 비움) */

/* 오른쪽 화살표 — 칸 폭 112px = 라벨 한 줄 6자(15px × 6 + 띄어쓰기 ≈ 96) + 양옆 8 · 삼각형 = .farrow 를 오른쪽으로
   · 라벨 = 화살표 위(칸 위아래를 같게 잡아 삼각형이 상자 세로 가운데) */
.harrow{flex:none;width:112px;display:grid;grid-template-areas:"lbl" "arw" ".";
  grid-template-rows:1fr auto 1fr;justify-items:center;align-items:center;
  font-size:var(--fs-body-s);line-height:var(--lh)}
.harrow::before{content:"";grid-area:arw;width:0;height:0;
  border-top:7px solid transparent;border-bottom:7px solid transparent;border-left:10px solid var(--fg3)}
.harrow .lbl{grid-area:lbl;align-self:end;margin:0 var(--s-2) var(--s-1);color:var(--fg2);text-align:center}

/* 숨김 글자 — 화면엔 안 보이고 스크린리더만 읽음(비텍스트 대체) · 1px 상자라 넘침 측정에서 뺌 */
.sr-only{position:absolute;width:1px;height:1px;overflow:hidden;
  clip:rect(0 0 0 0);clip-path:inset(50%);white-space:nowrap}

/* 좁은 폭(768px 미만) — 가로 순차는 도식 전체를 위→아래로(화살표 아래 · 라벨은 화살표 오른쪽)
   · 행 대응은 좌→우 유지(화살표 칸만 좁게) — 회전은 .hflow 직계에만 */
@media (max-width:767.98px){
  .hflow{flex-direction:column}
  .hflow>.fbox{flex:0 0 auto}
  .hflow>.harrow{width:auto;grid-template-areas:". arw lbl";
    grid-template-rows:minmax(calc(var(--fs-body-s) * var(--lh)),auto);   /* 라벨 유무와 관계없이 칸 높이 같게 */
    grid-template-columns:1fr auto 1fr;padding:var(--s-2) 0}
  .hflow>.harrow::before{border-top:10px solid var(--fg3);border-right:7px solid transparent;
    border-bottom:0;border-left:7px solid transparent}
  .hflow>.harrow .lbl{align-self:center;justify-self:start;margin:0 0 0 var(--s-2);text-align:left}
  .hmap>.harrow{width:32px}
}

/* 강제 색 모드(Windows 고대비) — 투명 테두리 삼각형이 사각형으로 칠해지지 않게 */
@media (forced-colors: active){ .farrow,.harrow::before{forced-color-adjust:none} }
```

**쓰는 법 (가로 흐름 · 행 대응 · 강조 · 숨김 글자 · 좁은 폭):**

| 규칙 |
|---|
| **순차 vs 분기** — 가로 순차 = `.hflow`(짧은 순차 · 680px 컬럼에 상자 3개까지 — 4개면 상자 폭 73px 로 제목이 글자 단위로 끊기는데 넘침 측정엔 안 잡힘 · 길면 세로 `.flowcol`) · 분기·병렬 = `.frow` — 순차를 `.frow` 로 만들면 분기로 읽힘 · 한 도식 한 방향(코어 §5 — 세로 흐름 안에 가로 흐름 넣지 않음) |
| **화살표 칸**(`.harrow`) = 폭 고정 112px — 라벨 없는 칸도 같은 폭(간격 균일) · 삼각형 = 상자 세로 가운데 |
| **화살표 라벨**(`.lbl`) = 15px 짧은 명사구(한 줄 6자 안팎 · 넘으면 의미 경계에서 2줄 → 그 행이 높아짐 · 상자와 겹침 없음) · 보이는 라벨이 곧 화살표의 대체 글자 |
| **행 대응**(`.hmap`) = 행마다 왼쪽 → 오른쪽 짝 · 대응 뜻 = 열 머리(`.colh`) · 화살표 라벨 없음 |
| **좁은 폭**(768px 미만 — 예 1280px 창의 200% 확대 = 640px) = `.hflow` 는 도식 전체 위→아래(화살표 아래 · 라벨은 화살표 오른쪽) · `.hmap` 은 좌→우 유지(화살표 칸만 32px) — 규칙 원본 = 코어 §5 「좁은 폭 방향 전환」(이 행은 컴포넌트 구현) |
| **강조**(`.emph`) = 시각 단위당 한 곳(코어 §4) · 구조 도식(`.plain`)에만 — 상태 클래스와 겹쳐 쓰지 않음(색 의미축 하나 · `accessibility.md` §4) · 글자색 그대로(강조색 글자는 흑백에서 옅어짐 · `web_page.md` §6-3) |
| **비텍스트 대체**(`accessibility.md` §5) = 화살표는 빈 요소라 읽히지 않음 → 관계를 말해야 하면 숨김 글자(`.sr-only` "다음 단계") · 대응 뜻을 열 머리가 말하면 `aria-hidden="true"` · 강조 노드 = 제목 안 맨 앞 숨김 글자 "핵심: "(상자 직계 자식으로 두면 줄 사이 규칙이 첫 줄 위 여백을 늘림) |

**HTML 사용 예 (분기):**

```html
<div class="flowframe"><div class="flowcol">
  <div class="fbox rx"><div class="t">① 단계</div><div class="d">입력 → 출력</div></div>
  <div class="farrow"></div>
  <div class="fbox plain"><div class="t">분기 조건?</div></div>
  <div class="farrow"></div>
  <div class="frow">
    <div class="fbox plain"><div class="t">예</div><div class="d">…</div></div>
    <div class="fbox plain"><div class="t">아니오</div><div class="d">…</div></div>
  </div>
</div></div>
```

**HTML 사용 예 (가로 순차 · 화살표 라벨 · 숨김 글자):**

```html
<div class="flowframe"><div class="hflow">
  <div class="fbox rx"><div class="t">① 수집</div><div class="d">입력 → 정규화</div></div>
  <div class="harrow"><span class="lbl">검사 통과</span></div>
  <div class="fbox plain"><div class="t">② 처리</div></div>
  <div class="harrow"><span class="sr-only">다음 단계</span></div>
  <div class="fbox plain"><div class="t">③ 산출</div></div>
</div></div>
```

**HTML 사용 예 (행 대응 · 강조 한 곳):**

```html
<div class="flowframe"><div class="hmap">
  <div class="colh">기존</div><div class="colh">대체</div>
  <div class="fbox plain"><div class="d">손으로 복사</div></div>
  <div class="harrow" aria-hidden="true"></div>
  <div class="fbox plain emph"><div class="t"><span class="sr-only">핵심: </span>설치기</div></div>
  <div class="fbox plain"><div class="d">눈대중 확인</div></div>
  <div class="harrow" aria-hidden="true"></div>
  <div class="fbox plain"><div class="t">기계 게이트</div></div>
</div></div>
```

## 7. 안티패턴 (재발 실수)

| 안티패턴 | 증상 | 교정 |
|---|---|---|
| 손코딩 SVG 도식 | 도식마다 폰트·폭·여백 제각각 | HTML/CSS 컴포넌트 |
| 이중 프레임 | 테두리 폭·모양 불일치 | 단일 컨테이너 프레임 |
| 뷰박스 폭 불통일 | 같은 font-size 가 다른 크기로 렌더 | 폭 통일 or CSS 상속 |
| 분기가 전체 폭 채움 | 위아래 박스와 좌우 외곽 어긋남 | frow 도 max-width 중앙 |
| 구역→첫 박스 0px 붙임 | 라벨과 박스 크램프 | 간격/화살표로 리듬 통일 |
| 제목에 `— 부연` | 길어져 줄바꿈·산만 | 제목 단어만, 부연은 본문 |
| 색 스킴 중간 교체 | 계층색↔상태색 혼동 | 단일 의미축, 구조는 중립 |
| 특정 박스만 넓힘 | 정렬 깨짐 | 폭 통일, 내용은 축약/높이 |
| grep 만으로 완료 보고 | 시각 결함 누락 | 브라우저 렌더 필수 |
| 소수 px 테두리(1.5px 등) | 배율 1 화면에서 1px 로 내려가 틀·노드 무게가 같아지고 이중선·띠가 얇아짐 | 정수 굵기 1·2·4px(§6-1) · 배율 1·2 렌더 확인 |
| 좁은 폭 회전을 행 대응까지 | 대응 화살표가 아래를 가리켜 순차로 오독 | 회전은 `.hflow` 직계만 · `.hmap` 은 좌→우 유지(§6-2) |

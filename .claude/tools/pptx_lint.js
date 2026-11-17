// pptx_lint.js — 게이트1 정적 린트 (자체 구현, 의존성 0)
// 대상: pptxgenjs 슬라이드 객체. 렌더 전에 경계 이탈·요소 겹침·상자 넘침(추정)·
//       표 셀 단어 중간 끊김을 검출한다.
// 설계 근거: 렌더 후 픽셀 분석으로는 "textbox 내부 넘침"과 "의도적 full-bleed"를
//            구분할 수 없다. 좌표는 생성 시점에 알고 있으므로 여기서 판정한다.
"use strict";

const DEFAULT_DIMS = { w: 13.333, h: 7.5 }; // LAYOUT_WIDE 기준(inch)
const EPS = 0.005;                          // 부동소수 오차 흡수(≈0.13mm)

// pptxgenjs 내부 구조에서 요소 배열을 얻는다. 버전에 따라 키가 다를 수 있어 순차 탐색.
// 검증 버전: pptxgenjs 4.0.1.
//
// 이 함수는 공개 API가 아닌 내부 구조에 의존한다. 상위 버전에서 키 이름이 바뀌면
// 요소를 하나도 못 찾고 "결함 0"으로 조용히 통과할 수 있다 — 게이트가 통째로
// 무력해지는데 아무 표시가 없는 상태다. 그래서 "인식 실패"와 "빈 슬라이드"를
// 구분해, 인식 실패는 소리 내어 알린다.
const UNRECOGNIZED = Symbol("unrecognized-slide-structure");
let warnedUnrecognized = false;

function getObjects(slide) {
  const cands = ["_slideObjects", "data", "_slide", "objects"];
  for (const k of cands) {
    const v = slide && slide[k];
    if (Array.isArray(v)) return v;
    if (v && Array.isArray(v.data)) return v.data;
  }
  if (!warnedUnrecognized) {
    warnedUnrecognized = true;
    console.error(
      "[pptx_lint] 슬라이드 내부 구조를 인식하지 못했다. pptxgenjs 버전이 바뀐 것으로 보인다.\n" +
      "           이 상태의 '결함 0'은 통과가 아니라 미검사다.\n" +
      "           tools/negtest/lint_cases.js 를 돌려 확인하고, 필요하면 getObjects()의 키 목록을 갱신한다.",
    );
  }
  return UNRECOGNIZED;
}

// 인식 실패는 검사를 건너뛰되, 위에서 이미 경고했으므로 조용히 통과하지는 않는다.
const objectsOf = (slide) => {
  const v = getObjects(slide);
  return v === UNRECOGNIZED ? [] : v;
};

// pptxgenjs는 요소 종류마다 좌표 단위가 다르다. addText/addShape/addImage는 인치를
// 그대로 두지만 addTable은 EMU(914400 = 1인치)로 변환해 저장한다. 단위를 구분하지
// 않으면 정상 표가 "right=11521440 > 13.333"으로 잡혀 빌드가 멈춘다(실측).
const EMU_PER_INCH = 914400;
const EMU_THRESHOLD = 1000;   // 1000인치짜리 슬라이드는 없으므로 이 이상은 EMU다

function toInches(v) {
  if (typeof v !== "number") return undefined;
  return Math.abs(v) >= EMU_THRESHOLD ? v / EMU_PER_INCH : v;
}

// "50%" 같은 백분율은 캔버스 크기에 대한 비율이다 — 환산해서 검사한다.
function resolveLen(v, span) {
  if (typeof v === "number") return toInches(v);
  if (typeof v === "string") {
    const m = /^\s*(-?\d+(?:\.\d+)?)\s*%\s*$/.exec(v);
    if (m && typeof span === "number") return (parseFloat(m[1]) / 100) * span;
  }
  return undefined;
}

// 표는 h 대신 rowH로 높이를 지정하는 경우가 흔하다. 그때 h가 없다고 통째로
// 건너뛰면 표는 영영 검사되지 않는다 — rowH × 행수로 높이를 채운다.
// 행 배열은 options가 아니라 요소 자체에 붙어 있다(pptxgenjs 4.0.1: arrTabRows).
// rowH는 x·y·w와 달리 인치로 남으므로 toInches의 임계값 판정이 그대로 맞는다.
function tableHeight(obj, o) {
  const rowH = toInches(o.rowH);
  const rowsArr = ["arrTabRows", "rows", "_rows"]
    .map((k) => obj && obj[k])
    .find(Array.isArray);
  if (typeof rowH === "number" && rowsArr) return rowH * rowsArr.length;
  return undefined;
}

/** 기하 정보를 인치로 정규화해 돌려준다. 계산할 수 없으면 null. */
function geomOf(obj, dims = DEFAULT_DIMS) {
  const o = obj && (obj.options || obj.opts || obj);
  if (!o) return null;
  const x = resolveLen(o.x, dims.w);
  const y = resolveLen(o.y, dims.h);
  // addImage({sizing:{w,h}})는 실제 크기를 sizing에만 넣고 options.w/h는 1로
  // 채워 둔다. sizing을 보지 않으면 4"×3" 이미지를 1"×1"로 판정한다.
  const sizing = o.sizing || {};
  const w = resolveLen(sizing.w, dims.w) ?? resolveLen(o.w, dims.w);
  let h = resolveLen(sizing.h, dims.h) ?? resolveLen(o.h, dims.h);
  if (h === undefined) h = tableHeight(obj, o);
  if ([x, y, w, h].some((v) => v === undefined || Number.isNaN(v))) return null;
  return { x, y, w, h };
}

// 슬라이드가 자기 캔버스 크기를 알고 있으면 그것을 쓴다. 호출 측이 dims를
// 넘기는 것을 잊으면 10" 덱 전체가 13.333" 기준으로 판정돼 경계 검사가
// 통째로 무의미해진다 — 잊을 수 있는 것에 정확성을 걸지 않는다.
function dimsOf(slide, dims) {
  if (dims !== DEFAULT_DIMS) return dims;          // 호출 측이 명시했으면 존중
  const lay = slide && slide._presLayout;
  const w = lay && lay._sizeW, h = lay && lay._sizeH;
  if (typeof w === "number" && typeof h === "number" && w > 0 && h > 0) {
    return { w: w / EMU_PER_INCH, h: h / EMU_PER_INCH };
  }
  return dims;
}

// 마스터에 둔 요소는 slide._slideObjects 가 아니라 레이아웃 쪽에 있다.
// 마스터는 전 슬라이드에 반복되므로 한 번 어긋나면 덱 전체가 어긋난다.
function layoutObjects(slide) {
  const lay = slide && slide._slideLayout;
  const v = lay && lay._slideObjects;
  return Array.isArray(v) ? v : [];
}

// pptxgenjs는 도형(addShape)도 _type을 "text"로 저장하고 shape 속성만 채운다.
// 따라서 _type만으로는 텍스트/도형을 구분할 수 없다 — 실제 글자 유무로 판정한다.
// (배경 카드 위에 텍스트를 얹는 것은 정상 레이아웃이므로 겹침 판정에서 제외해야 한다.)
// addText(12, …)는 "12"을 그린다 — 숫자도 글자다. 문자열만 인정하면 쪽번호가
// 도형으로 분류돼 겹침·넘침 판정에서 통째로 빠진다.
const asText = (v) =>
  typeof v === "string" ? v
    : (typeof v === "number" && Number.isFinite(v) ? String(v) : "");

const runText = (r) => asText(r && typeof r === "object" ? r.text : r);

function hasRealText(obj) {
  const t = obj && obj.text;
  const direct = asText(t);
  if (direct) return direct.trim().length > 0;
  if (Array.isArray(t)) return t.some((r) => runText(r).trim().length > 0);
  return false;
}

function kindOf(obj) {
  const t = String(obj && (obj._type || obj.type) || "").toLowerCase();
  if (t.includes("table")) return "table";
  if (t.includes("image")) return "image";
  if (t.includes("chart")) return "chart";
  if (t.includes("media")) return "media";
  // _type이 "text"여도 실제 글자가 없으면 도형(배경 카드·rail·구분선)으로 본다.
  if (t.includes("text")) return hasRealText(obj) ? "text" : "shape";
  if (t.includes("shape") || t.includes("rect") || t.includes("line")) return "shape";
  return t || "unknown";
}

// 예외 마킹: 요소 options에 fullBleed / overlapOk 를 달면 해당 검사에서 면제한다.
const isFullBleed = (obj) => !!(obj && (obj.options || {}).fullBleed);
const isOverlapOk = (obj) => !!(obj && (obj.options || {}).overlapOk);

/** 캔버스 경계 이탈 검출. 반환: 결함 배열(빈 배열이면 통과) */
function checkBounds(slide, dims = DEFAULT_DIMS, opts = {}) {
  dims = dimsOf(slide, dims);
  const { w: SW, h: SH } = dims;
  const out = [];
  // 마스터 요소도 함께 본다. index 는 마스터분을 음수로 표기해 구분한다.
  const own = objectsOf(slide);
  const master = layoutObjects(slide);
  [...own, ...master].forEach((obj, idx) => {
    const i = idx < own.length ? idx : `master[${idx - own.length}]`;
    if (isFullBleed(obj)) return;                 // 의도적 full-bleed 면제
    // 발표자 노트는 캔버스 위에 없으므로 좌표가 없는 것이 정상이다.
    // "검사 못 함"으로 보고하면 노트를 다는 좋은 습관이 매 슬라이드 경고가 된다.
    if (String((obj && (obj._type || obj.type)) || "").toLowerCase().includes("notes")) return;
    const g = geomOf(obj, dims);
    if (!g) {
      // 좌표를 계산할 수 없는 요소를 조용히 넘기면 "검사했는데 문제 없음"과
      // 구분되지 않는다. 미검사 사실을 남긴다.
      out.push({
        rule: "unchecked", severity: "WARN", index: i, kind: kindOf(obj),
        detail: "x·y·w·h 중 일부를 계산할 수 없어 경계 검사를 못 했다",
        suggestion: "좌표와 크기를 숫자(인치)로 명시한다. 표는 h 또는 rowH를 준다.",
      });
      return;
    }
    if (g.w < 0 || g.h < 0) {
      // PowerPoint는 음수 크기를 아예 거부한다 — 렌더가 되지 않으므로
      // 게이트2·3은 이 파일을 볼 기회조차 없다. 여기가 유일한 방어선이다.
      out.push({
        rule: "bounds", severity: "FAIL", index: i, kind: kindOf(obj),
        detail: `w=${g.w.toFixed(3)}, h=${g.h.toFixed(3)} — 음수 크기`,
        suggestion: "크기를 양수로 바꾼다. 음수 크기는 열리지 않는 파일을 만든다.",
      });
      return;
    }
    const over = [];
    if (g.x < -EPS) over.push(`left=${g.x.toFixed(3)} < 0`);
    if (g.y < -EPS) over.push(`top=${g.y.toFixed(3)} < 0`);
    if (g.x + g.w > SW + EPS) over.push(`right=${(g.x + g.w).toFixed(3)} > width=${SW.toFixed(3)}`);
    if (g.y + g.h > SH + EPS) over.push(`bottom=${(g.y + g.h).toFixed(3)} > height=${SH.toFixed(3)}`);
    if (over.length) {
      out.push({
        rule: "bounds", severity: "FAIL", index: i, kind: kindOf(obj),
        detail: over.join(", "),
        suggestion: "요소를 캔버스 안으로 이동하거나 크기를 줄인다. 의도적이면 options에 fullBleed:true 표기.",
      });
    }
  });
  return out;
}

/** 요소 겹침 검출. 텍스트↔텍스트만 FAIL, 그 외 조합은 보고하지 않는다(배경 카드 위 텍스트는 정상). */
function checkOverlaps(slide, dims = DEFAULT_DIMS, opts = {}) {
  dims = dimsOf(slide, dims);
  const minArea = typeof opts.minArea === "number" ? opts.minArea : 0.01; // inch^2, 미세 접촉 무시
  const objs = objectsOf(slide);
  const out = [];
  for (let i = 0; i < objs.length; i++) {
    for (let j = i + 1; j < objs.length; j++) {
      const a = objs[i], b = objs[j];
      if (isOverlapOk(a) || isOverlapOk(b)) continue;      // 의도적 중첩 면제
      if (isFullBleed(a) || isFullBleed(b)) continue;      // 전면 요소는 겹치는 것이 정상
      if (kindOf(a) !== "text" || kindOf(b) !== "text") continue; // 텍스트끼리만 판정
      const ga = geomOf(a, dims), gb = geomOf(b, dims);
      if (!ga || !gb) continue;
      const ox = Math.min(ga.x + ga.w, gb.x + gb.w) - Math.max(ga.x, gb.x);
      const oy = Math.min(ga.y + ga.h, gb.y + gb.h) - Math.max(ga.y, gb.y);
      if (ox > EPS && oy > EPS && ox * oy >= minArea) {
        out.push({
          rule: "overlap", severity: "FAIL", index: i, index2: j, kind: "text/text",
          detail: `overlap_w=${ox.toFixed(3)}, overlap_h=${oy.toFixed(3)}, area=${(ox * oy).toFixed(3)}`,
          suggestion: oy < ox ? "세로로 분리한다(y 조정)." : "가로로 분리한다(x 조정).",
        });
      }
    }
  }
  return out;
}

// ── 텍스트 상자 넘침 추정 ────────────────────────────────────────────────
// 픽셀 검사로는 볼 수 없는 결함이다(넘친 글자도 캔버스 안이면 정상 픽셀과 같다).
// 좌표·글자수·글자크기는 생성 시점에 알고 있으므로 여기서 추정한다.
// 어디까지나 추정이므로 severity 는 WARN 이고, 여유(OVERFLOW_SLACK)를 크게 잡아
// 오탐보다 미탐 쪽으로 치우치게 했다 — 확정 판정은 게이트3(육안)이 한다.
const PT_PER_INCH = 72;
const DEFAULT_FONT_SIZE = 18;    // pptxgenjs 기본값
const DEFAULT_LINE_SPACING = 1.2;
const TEXTBOX_INSET_IN = 0.1;    // 좌우 각 0.05" 기본 여백
const BULLET_INDENT_IN = 0.3;    // 글머리 기호 + 들여쓰기가 먹는 폭
const OVERFLOW_SLACK = 1.25;     // 추정 높이가 상자의 이 배를 넘을 때만 보고

// 한글·한자·가나는 전각(글자크기와 폭이 거의 같다), 라틴·숫자는 대략 절반.
function estimateWidthPt(str, fontSize) {
  let w = 0;
  for (const ch of str) {
    const code = ch.codePointAt(0);
    const wide =
      (code >= 0x1100 && code <= 0x11ff) || (code >= 0x2e80 && code <= 0xa4cf) ||
      (code >= 0xac00 && code <= 0xd7a3) || (code >= 0xf900 && code <= 0xfaff) ||
      (code >= 0xff00 && code <= 0xff60) ||
      // 이모지·CJK 확장은 BMP 밖에 있다. 반각으로 세면 필요 높이가 절반으로
      // 나와 이모지가 많은 텍스트에서 판정이 뒤집힌다.
      (code >= 0x1f300 && code <= 0x1faff) || (code >= 0x20000 && code <= 0x3ffff);
    w += fontSize * (wide ? 1.0 : 0.5);
  }
  return w;
}

// 텍스트를 "줄" 단위로 펴서 돌려준다. pptxgenjs의 불릿·문단은 run 배열이고
// 줄바꿈은 run 옵션 breakLine 으로 표현된다. 이것을 무시하고 문자열을 이어붙이면
// 불릿 5개가 한 줄로 계산되어, 정작 가장 흔한 넘침 형태를 놓친다.
function linesOf(obj, boxFontSize) {
  const t = obj && obj.text;
  const out = [];
  let cur = { text: "", size: boxFontSize };

  const pushCur = () => { out.push(cur); cur = { text: "", size: boxFontSize }; };

  const flat = asText(t);
  if (flat) {
    flat.split(/\r?\n/).forEach((s, i, arr) => {
      cur.text += s;
      if (i < arr.length - 1) pushCur();
    });
  } else if (Array.isArray(t)) {
    t.forEach((r) => {
      const s = runText(r);
      const ro = (r && r.options) || {};
      // bullet 은 문단의 **시작** 표시다. 그러므로 run 을 처리하기 전에 끊는다.
      // 뒤에서 끊으면 breakLine 없이 bullet 만 단 run 열거(가장 흔한 리스트
      // 형태)가 통째로 한 줄로 세어져 넘침을 놓친다. 반대로 "굵은 머리말 run +
      // 설명 run" 한 줄은 머리말에만 bullet 이 붙으므로 여기서 한 번만 끊긴다.
      if (ro.bullet && cur.text.length) pushCur();
      const size = typeof ro.fontSize === "number" ? ro.fontSize : boxFontSize;
      const parts = String(s).split(/\r?\n/);
      parts.forEach((p, i) => {
        cur.text += p;
        cur.size = Math.max(cur.size, size);       // 한 줄 안에서 가장 큰 글자가 줄 높이를 정한다
        if (i < parts.length - 1) pushCur();
      });
      if (ro.breakLine) pushCur();
    });
  }
  if (cur.text.length || !out.length) out.push(cur);
  return out;
}

/** 텍스트가 자기 상자를 넘칠 것으로 보이는 요소를 보고한다(추정, WARN). */
function checkOverflow(slide, dims = DEFAULT_DIMS, opts = {}) {
  dims = dimsOf(slide, dims);
  const slack = typeof opts.slack === "number" ? opts.slack : OVERFLOW_SLACK;
  const out = [];
  objectsOf(slide).forEach((obj, i) => {
    if (!hasRealText(obj)) return;
    const o = (obj && obj.options) || {};
    // 저작자가 다른 방식으로 처리하기로 한 요소는 판정하지 않는다.
    // fit:"none"은 자동 축소를 **끄는** 값이라 오히려 넘친다. truthy 검사로 두면
    // 정확히 그 경우를 면제해 버린다.
    const autofits = o.shrinkText || o.autoFit
                  || o.fit === "shrink" || o.fit === "resize";
    if (o.overflowOk || autofits) return;

    const g = geomOf(obj, dims);
    // 넘침 판정에는 w·h만 있으면 된다. x·y가 없다는 이유로 건너뛰지 않는다.
    const w = g ? g.w : resolveLen(o.w, dims.w);
    const h = g ? g.h : resolveLen(o.h, dims.h);
    if (!(w > 0)) return;
    if (!(h > 0)) {
      // h가 없으면 상자가 내용에 맞춰 늘어난다 — 캔버스를 벗어날 수 있으나
      // 여기서는 판정할 수 없다. 미검사로 남긴다.
      out.push({
        rule: "unchecked", severity: "WARN", index: i, kind: "text",
        detail: "h가 없어 넘침을 판정할 수 없다(자동 높이)",
        suggestion: "h를 명시해 검사 대상으로 만든다.",
      });
      return;
    }

    const boxFontSize = typeof o.fontSize === "number" ? o.fontSize : DEFAULT_FONT_SIZE;
    // lineSpacing(pt 절대값)이 있으면 그것이 우선, 없으면 배수를 쓴다.
    const absSpacingPt = typeof o.lineSpacing === "number" ? o.lineSpacing : undefined;
    const multiple = typeof o.lineSpacingMultiple === "number"
      ? o.lineSpacingMultiple : DEFAULT_LINE_SPACING;

    // 불릿이 붙으면 글머리 기호와 들여쓰기만큼 쓸 수 있는 폭이 줄어든다.
    const bulletIndent = o.bullet ? BULLET_INDENT_IN : 0;
    const usableW = Math.max(0.1, w - TEXTBOX_INSET_IN - bulletIndent) * PT_PER_INCH;

    let neededPt = 0;
    let lineCount = 0;
    linesOf(obj, boxFontSize).forEach((ln) => {
      const wrapped = Math.max(1, Math.ceil(estimateWidthPt(ln.text, ln.size) / usableW));
      lineCount += wrapped;
      neededPt += wrapped * (absSpacingPt !== undefined ? absSpacingPt : ln.size * multiple);
    });

    const neededIn = neededPt / PT_PER_INCH;
    if (neededIn > h * slack) {
      // 기본은 WARN(추정이므로 범용 안전). 저작자가 opts.overflowFail 로 옵트인하면
      // FAIL 로 승격해 빌드를 막는다 — 넘침을 반드시 잡아야 하는 덱 gate 용도.
      out.push({
        rule: "overflow", severity: opts.overflowFail ? "FAIL" : "WARN", index: i, kind: "text",
        detail: `est_lines=${lineCount}, est_height=${neededIn.toFixed(2)}in > box_h=${h.toFixed(2)}in `
              + `(fontSize=${boxFontSize})`,
        suggestion: "상자를 키우거나 내용을 덜어낸다. 추정이므로 렌더 후 눈으로 확인한다. "
                  + "의도적이면 options에 overflowOk:true 표기.",
      });
    }
  });
  return out;
}

// ── 표 셀 단어 중간 끊김 ────────────────────────────────────────────────
// 표는 셀 내용을 행 배열(arrTabRows)에 담고 obj.text 가 없어 checkOverflow 대상이 아니다.
// 셀이 여러 줄로 감기는 것은 행 높이가 늘 뿐이라 결함으로 보지 않는다. 공백 없는 토큰
// 하나가 (열 폭 − 좌우 셀 여백)보다 넓을 때만 FAIL — 그 토큰은 반드시 단어 중간에서 끊긴다.
// 오탐을 낮추려고 판정을 이 한 경우로 좁혔다. 폭 추정은 넘침 검사와 같은 estimateWidthPt.
// FAIL 이 아니어도 추정 폭이 가용 폭의 WORDBREAK_TIGHT_RATIO 를 넘으면 WARN(빠듯함) — 추정 오차로
// FAIL 을 놓칠 수 있는 대역이다. 표 options 의 wordbreakOk 는 표 전체, 셀 options 의 것은 그 셀만 면제.
const TABLE_DEFAULT_FONT_SIZE = 12;                      // pptxgenjs addTable 기본 글자 크기
const TABLE_DEFAULT_MARGIN_IN = [0.05, 0.1, 0.05, 0.1];  // pptxgenjs 기본 셀 여백 [상, 우, 하, 좌]
const TOKEN_BREAK = /[\s\u200b]/;                        // 줄을 끊을 수 있는 자리(공백·줄바꿈·ZWSP)
// 빠듯함 기준(추정 폭 ÷ 가용 폭). 실제 폭이 추정의 1.25배(= 1/0.8)까지 넓어도 놓치지 않는다.
// 실측(덱 표 셀의 10자 이상 라틴 토큰 91개, 실제 ÷ 추정): DejaVu Sans 는 90% 가 1.20 이하 ·
// Liberation Sans 최대 1.21. 대문자 위주 토큰(DejaVu Sans 최대 1.55)은 이 대역으로도 못 덮는다 — 렌더 확정 몫.
const WORDBREAK_TIGHT_RATIO = 0.8;

// 셀 여백을 [상, 우, 하, 좌] 인치로. pptxgenjs 는 첫 값이 1 이상이면 네 값을 pt 로 읽는다.
function cellMarginIn(m) {
  const arr = typeof m === "number" ? [m, m, m, m] : m;
  if (!Array.isArray(arr) || arr.length !== 4 || arr.some((v) => typeof v !== "number")) {
    return TABLE_DEFAULT_MARGIN_IN;
  }
  return arr[0] >= 1 ? arr.map((v) => v / PT_PER_INCH) : arr;
}

// writeFile 을 거친 표는 pptxgenjs 가 병합 자리표시자(_hmerge·_vmerge)를 행에 끼워 둔다.
// 그때는 자리표시자가 곧 점유 표시라 한 항목 = 한 열이다.
const isMergePlaceholder = (c) => !!(c && (c._hmerge || c._vmerge));

// 셀마다 열 번호를 정한다. rowspan 으로 위 행에서 내려온 칸은 건너뛴다(expanded 면 점유표 불필요).
function placeCells(rows, expanded) {
  const taken = [];
  const out = [];
  rows.forEach((row, ri) => {
    if (!Array.isArray(row)) return;
    let col = 0;
    row.forEach((cell) => {
      if (isMergePlaceholder(cell)) { col += 1; return; }
      if (!expanded) while (taken[ri] && taken[ri].has(col)) col += 1;
      const co = (cell && cell.options) || {};
      const span = Math.max(1, Number(co.colspan) || 1);
      const down = Math.max(1, Number(co.rowspan) || 1);
      out.push({ cell, row: ri, col, span });
      if (!expanded) {
        for (let k = 1; k < down; k++) {
          taken[ri + k] = taken[ri + k] || new Set();
          for (let c = col; c < col + span; c++) taken[ri + k].add(c);
        }
      }
      col += expanded ? 1 : span;
    });
  });
  return out;
}

// 셀에서 폭이 가장 넓은 토큰. run 경계는 줄을 끊지 않으므로 run 을 이어 붙여 토큰을 만들고,
// 글자마다 그 run 의 글자 크기로 폭을 잰다. breakLine 은 끊는 자리다.
function widestToken(text, baseSize) {
  const segs = [];
  const flat = asText(text);
  if (flat) segs.push({ text: flat, size: baseSize, brk: false });
  else if (Array.isArray(text)) {
    text.forEach((r) => {
      const ro = (r && r.options) || {};
      segs.push({
        text: runText(r),
        size: typeof ro.fontSize === "number" ? ro.fontSize : baseSize,
        brk: !!ro.breakLine,
      });
    });
  }
  let best = { token: "", widthPt: 0, size: baseSize };
  let cur = { token: "", widthPt: 0, size: 0 };
  const close = () => {
    if (cur.widthPt > best.widthPt) best = cur;
    cur = { token: "", widthPt: 0, size: 0 };
  };
  segs.forEach((sg) => {
    for (const ch of sg.text) {
      if (TOKEN_BREAK.test(ch)) { close(); continue; }
      cur.token += ch;
      cur.widthPt += estimateWidthPt(ch, sg.size);
      cur.size = Math.max(cur.size, sg.size);
    }
    if (sg.brk) close();
  });
  close();
  return best;
}

/** 표 셀에서 단어 중간 끊김이 확정되는 토큰(FAIL)과 한계 근처 토큰(WARN 빠듯함)을 보고한다. */
function checkTableWordBreak(slide, dims = DEFAULT_DIMS, opts = {}) {
  const out = [];
  objectsOf(slide).forEach((obj, i) => {
    if (kindOf(obj) !== "table") return;
    const rows = ["arrTabRows", "rows", "_rows"].map((k) => obj && obj[k]).find(Array.isArray);
    if (!rows || !Array.isArray(rows[0])) return;
    const to = obj.options || {};
    if (to.wordbreakOk) return;                                      // 의도적 예외 — 표 전체
    const expanded = rows.some((r) => Array.isArray(r) && r.some(isMergePlaceholder));
    // 열 수 = 첫 행의 colspan 합(pptxgenjs 가 표 격자를 만드는 방식) · expanded 면 첫 행 항목 수.
    const colCount = expanded ? rows[0].length
      : rows[0].reduce((n, c) => n + (Number(c && c.options && c.options.colspan) || 1), 0);
    let widths = null;
    if (Array.isArray(to.colW) && to.colW.length === colCount && to.colW.every((v) => typeof v === "number")) {
      widths = to.colW.map(toInches);
    } else if (typeof to.w === "number" && colCount > 0) {
      widths = Array(colCount).fill(toInches(to.w) / colCount);
    }
    if (!widths) {
      out.push({
        rule: "unchecked", severity: "WARN", index: i, kind: "table",
        detail: "열 폭(colW 또는 w)을 알 수 없어 셀 단어 끊김 검사를 못 했다",
        suggestion: "colW(열 수와 같은 길이의 인치 배열) 또는 w 를 숫자로 준다.",
      });
      return;
    }
    placeCells(rows, expanded).forEach(({ cell, row, col, span }) => {
      const co = (cell && cell.options) || {};
      if (co.textDirection && co.textDirection !== "horz") return;   // 세로 쓰기 셀은 폭 축이 다르다
      if (co.wordbreakOk) return;                                    // 의도적 예외 — 그 셀만
      const size = typeof co.fontSize === "number" ? co.fontSize
        : (typeof to.fontSize === "number" ? to.fontSize : TABLE_DEFAULT_FONT_SIZE);
      const tok = widestToken(cell && cell.text, size);
      if (!tok.token) return;
      const colW = widths.slice(col, col + span).reduce((a, b) => a + b, 0);
      const m = cellMarginIn(co.margin === 0 || co.margin ? co.margin : to.margin);
      const availIn = colW - m[1] - m[3];
      const needIn = tok.widthPt / PT_PER_INCH;
      if (needIn > availIn + EPS) {
        out.push({
          rule: "wordbreak", severity: "FAIL", index: i, kind: "table",
          detail: `단어 중간 끊김 — 셀(${row + 1}행 ${col + 1}열) "${tok.token}" `
                + `필요폭 ${needIn.toFixed(2)}in > 가용폭 ${availIn.toFixed(2)}in `
                + `(열폭 ${colW.toFixed(2)} − 좌우 여백 ${(m[1] + m[3]).toFixed(2)} · ${tok.size}pt)`,
          suggestion: "열 폭을 재배분하거나(합계 유지) 글자를 줄이거나, 토큰 안에 끊을 자리(공백·줄바꿈)를 둔다. "
                    + "여러 줄 감김 자체는 결함이 아니다. 의도적이면 표 또는 셀 options에 wordbreakOk:true 표기.",
        });
      } else if (needIn > availIn * WORDBREAK_TIGHT_RATIO) {
        out.push({
          rule: "wordbreak", severity: "WARN", index: i, kind: "table",
          detail: `빠듯함 — 셀(${row + 1}행 ${col + 1}열) "${tok.token}" `
                + `추정폭 ${needIn.toFixed(2)}in = 가용폭 ${availIn.toFixed(2)}in 의 ${Math.round((needIn / availIn) * 100)}% `
                + `(기준 ${Math.round(WORDBREAK_TIGHT_RATIO * 100)}% · 열폭 ${colW.toFixed(2)} − 좌우 여백 ${(m[1] + m[3]).toFixed(2)} · ${tok.size}pt)`,
          suggestion: "추정 폭은 글자에 따라 실제와 어긋난다(대문자·숫자 위주는 실제보다 좁게 잡힌다). "
                    + "Windows PowerPoint 렌더로 한 줄에 들어가는지 확정하거나 여유를 둔다(열 폭 재배분 · 글자 크기 · 끊을 자리). "
                    + "의도적이면 표 또는 셀 options에 wordbreakOk:true 표기.",
        });
      }
    });
  });
  return out;
}

/** 슬라이드 1장 종합 검사 */
function lintSlide(slide, dims = DEFAULT_DIMS, opts = {}) {
  return [
    ...checkBounds(slide, dims, opts),
    ...checkOverlaps(slide, dims, opts),
    ...checkOverflow(slide, dims, opts),
    ...checkTableWordBreak(slide, dims, opts),
  ];
}

/**
 * 콘솔 출력 헬퍼.
 * 반환: **차단해야 할 결함(FAIL)이 있으면 true.** WARN은 출력하되 막지 않는다.
 *
 * 넘침·미검사는 추정이거나 정보이므로 WARN이다. 이것까지 true로 돌려주면
 * `if (dirty) process.exit(1)` 패턴에서 추정치가 빌드를 멈추게 되어,
 * severity를 나눈 의미가 사라진다.
 * 경고까지 막고 싶으면 opts.failOn = ["FAIL", "WARN"].
 */
function reportSlide(slide, slideNo, dims = DEFAULT_DIMS, opts = {}) {
  const failOn = Array.isArray(opts.failOn) ? opts.failOn : ["FAIL"];
  const issues = lintSlide(slide, dims, opts);
  _track(slideNo, issues);
  issues.forEach((it) => {
    const who = it.index2 !== undefined ? `element ${it.index}&${it.index2}` : `element ${it.index}`;
    console.log(`[${it.severity}] Slide ${slideNo}: ${it.rule} — ${who} (${it.kind}) ${it.detail}`);
    console.log(`         → ${it.suggestion}`);
  });
  return issues.some((it) => failOn.includes(it.severity));
}

/** 심각도별 집계. 완료 조건 판정에 쓴다. */
function countBySeverity(issues) {
  return issues.reduce((acc, it) => {
    acc[it.severity] = (acc[it.severity] || 0) + 1;
    return acc;
  }, {});
}

// 통과했을 때 아무 말도 하지 않으면 "검사해서 깨끗함"과 "검사를 안 부름"이
// 출력상 같아진다.
// 슬라이드마다 떠들지는 않고, 마지막에 한 줄로 집계를 남긴다.
const _tally = { slides: 0, FAIL: 0, WARN: 0 };

function _track(slideNo, issues) {
  _tally.slides += 1;
  issues.forEach((it) => { _tally[it.severity] = (_tally[it.severity] || 0) + 1; });
}

/** 게이트1 집계를 한 줄로 출력하고, 차단 결함이 있으면 true를 돌려준다. */
function lintSummary(expectedSlides) {
  const { slides, FAIL, WARN } = _tally;
  const reset = () => { _tally.slides = 0; _tally.FAIL = 0; _tally.WARN = 0; };

  if (!slides) {
    console.error("[pptx_lint] 게이트1이 한 번도 호출되지 않았다 — 미검사 상태다.");
    reset();
    return true;
  }
  console.log(`[pptx_lint] 게이트1: 슬라이드 ${slides}장 검사 · FAIL ${FAIL} · WARN ${WARN}`);

  // 덱 장수를 넘겨주면 부분 호출도 잡는다. 넘기지 않으면 0회 호출만 막는다.
  let short = false;
  if (typeof expectedSlides === "number" && slides !== expectedSlides) {
    console.error(`[pptx_lint] 검사한 슬라이드 ${slides}장 ≠ 덱 ${expectedSlides}장 — 일부가 검사되지 않았다.`);
    short = true;
  }
  // 한 프로세스에서 덱을 여러 개 만들 수 있다. 집계를 비우지 않으면 앞 덱의
  // FAIL 이 남아 이후 덱이 깨끗해도 계속 차단된다.
  reset();
  return FAIL > 0 || short;
}

module.exports = {
  checkBounds, checkOverlaps, checkOverflow, checkTableWordBreak,
  lintSlide, reportSlide, lintSummary, countBySeverity, DEFAULT_DIMS,
};

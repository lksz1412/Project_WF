---
version: "1.4.9"
updated: "2026-11-16"
name: skill_LKS_custom_pptx
description: "Use this skill any time a .pptx or .potx file is involved in any way — as input, output, or both. This includes: creating slide decks, pitch decks, or presentations; reading, parsing, or extracting text from any .pptx or .potx file (even if the extracted content will be used elsewhere, like in an email or summary); editing, modifying, or updating existing presentations; combining or splitting slide files; working with templates (.potx), layouts, speaker notes, or comments. Trigger whenever the user mentions \"deck,\" \"slides,\" \"presentation,\" or references a .pptx or .potx filename, regardless of what they plan to do with the content afterward. If a .pptx or .potx file needs to be opened, created, or touched, use this skill."
license: Complete terms in LICENSE.txt
---

<!-- 애드온: Anthropic 공식 skills/pptx 원본 기반(base = anthropics/skills `1780c5e5a552`) + name을 skill_LKS_custom_pptx로 변경 + 아래 "기존 파일 읽기" 절 추가 + 본문·scripts 일부 수정·추가(Windows Office COM 경로 등 · 내역 = 패키지 CHANGELOG). 고친 범위(공식 새 판을 들일 때 다시 넣는다) = 본문: 「Scripts」(Windows COM 문단·표의 soffice·office_com 행) · 「Editing existing decks and templates」(풀기 줄 `python`·zip[`rm` 없이 `-FS`]·`.ppt` 변환) · 「Typography」 · 「Converting to Images」 · 「Dependencies」 / scripts: `thumbnail.py`(수정) · `office/soffice.py`(수정 — `soffice` 가 PATH 에 없으면 `soffice_available()` 이 거짓이고 `run_soffice` 가 `FileNotFoundError` 를 내 그 단계를 건너뜀) · `office/office_com.ps1`(추가 — docx·pptx·xlsx 세 포크의 `scripts/office/` 는 같은 파일이라 함께 고친다) · 고친 upstream 스크립트는 파일 머리에 변경 고지 한 줄(Apache-2.0 §4(b) — 원본·라이선스·바꾼 범위). -->

## ★ 덱을 새로 설계하거나 품질을 올리는 작업이면 <!--profile:inhouse-->

이 스킬은 **파일 조작**(읽기·쓰기·템플릿·포맷)을 맡는다. 슬라이드의 **논리 구조·제목·근거·문체·검증 절차**를 정하는 일은 → **`skill:skill_LKS_original_visual-design`**. 기존 덱을 읽어야 하면 여기서 내용을 확보한 뒤 그 스킬로 넘긴다. **아래 본문의 색·타이포·여백 수치는 범용 예시다 — 우리 덱 저작에는 `skill:skill_LKS_original_visual-design` 의 `references/pptx/content_rules.md` §7(본문 27pt 하한 등)이 우선한다.** <!--profile:inhouse-->

## ★ 기존 파일 읽기

기존 `.pptx` / `.potx`의 내용을 **읽거나 데이터를 추출**해야 할 때는 `skill:skill_LKS_custom_document` `references/decrypt/GUIDE.md`의 read-only 경로(`python-pptx`로 파싱)가 원본이다. 아래 본문의 읽기·추출 지침은 그 경로의 상세이지 다른 경로가 아니다. **변환·편집·생성** 작업은 아래 공식 절차를 그대로 쓴다 — 파싱 안전 추출과 변환·편집은 목적이 다르다. 사용자가 기존 덱 편집을 요청했다면 새 파일 생성을 강제하지 않는다. 새 덱을 처음부터 생성하는 작업도 아래 규칙을 그대로 쓴다.

# PPTX creation, editing, and analysis

A `.pptx` is a ZIP archive of XML files. Choose your approach by task:

| Task | Approach |
|---|---|
| **Create** a new deck | Write a `pptxgenjs` script — see gotchas below — and build it as a [structured deck](#structured-decks) unless the user asks for a quick throwaway |
| **Edit** an existing deck, or build from a template | unzip → edit `ppt/slides/slideN.xml` → zip |
| **Read** content | `python scripts/slide_text.py deck.pptx` (one block per slide under `<!-- Slide number: N -->` markers); visual grid: `python scripts/thumbnail.py deck.pptx` |

## Scripts

Paths are relative to this skill's directory. Everything else is plain Python, `node`, or shell.

On a Windows PC, rendering and conversion drive Microsoft PowerPoint itself through COM (assumed installed — if PowerPoint cannot be used, because it will not start or cannot open or write the deck, the premise is broken: do not switch to LibreOffice and do not try to repair or reinstall Office; record the step as not run and tell the user); elsewhere they use LibreOffice. A refusal the user can clear is not a broken premise: when the error says the deck is already open in PowerPoint (`save and close it, then retry`), ask the user to save and close it, then run the step again. Password-protected presentations are not supported on the COM path: PowerPoint waits on a hidden password prompt — `thumbnail.py` gives up at its timeout, a direct `office_com.ps1` call waits until the prompt goes away. Either way, PowerPoint reuses a PowerPoint you have open — then handle the prompt there instead of ending `POWERPNT.EXE` (after `thumbnail.py` has given up, cancel it — answering would leave a windowless copy open with nothing to close it; for a direct call, answer it); otherwise end the windowless `POWERPNT.EXE` the run started. `thumbnail.py` picks the engine on its own; for the manual steps below, use the block for your environment.

| Script | What it does |
|---|---|
| `scripts/slide_text.py deck.pptx` | Every slide's title, text, tables, chart data (scatter and bubble charts: series names only), picture alt text and speaker notes, as markdown. Reads `.potx` too |
| `scripts/thumbnail.py deck.pptx [prefix]` | Labeled grid of every slide, for picking template layouts. `.pptx` only. Pass `prefix` — it defaults to `thumbnails`, which overwrites the grids of any other deck done in the same directory |
| `scripts/add_slide.py unpacked/ slide2.xml [--after slideN.xml]` | Duplicate a slide (or a `slideLayoutN.xml`) with all the package bookkeeping. Also takes a `.pptx` directly with `-o out.pptx` |
| `scripts/clean.py unpacked/` | Delete slides, media, and rels no longer referenced. Run **after** `<p:sldIdLst>` is final |
| `scripts/apply_theme.js` | Node module: `const { applyTheme } = require("<this skill's directory>/scripts/apply_theme.js")`. `await applyTheme("deck.pptx", THEME)` after `pres.writeFile()` writes `THEME`'s colors and name (escaped for XML) into the deck's theme, for [structured decks](#structured-decks). Also a CLI: `node scripts/apply_theme.js deck.pptx theme.json` |
| `scripts/office/validate.py deck.pptx [--original src.pptx]` | Schema, relationship, content-type, chart and slide checks; each failure names its fix. Pass `--original` for any template-derived deck — it baselines the schema checks against the template, so the template's own XSD errors don't read as yours |
| `scripts/office/soffice.py --headless --convert-to pdf deck.pptx` | LibreOffice wrapper for cloud/Linux environments (not used on a Windows PC) — bare `soffice` hangs in this sandbox |
| `scripts/office/office_com.ps1 export-pdf -In deck.pptx -Out deck.pdf` | Windows PC only — drives PowerPoint (or Word, Excel, chosen by the `-In` extension) through COM: `export-pdf`, `convert` (legacy format to current), `accept-revisions`, `recalc`. Run it with `powershell -NoProfile -ExecutionPolicy Bypass -File …`; exit code 0 means success, and `-ResultJson <path>` writes `{ok, app, output, error}` |

## Creating with pptxgenjs — gotchas

`pptxgenjs` is preinstalled — do not run `npm install` first; write the script and `require('pptxgenjs')` directly. Only if that require fails: `npm install pptxgenjs`. The model knows the API; these are the footguns:

- **Set `pres.layout` before adding slides.** The default canvas is `LAYOUT_16x9` = **10" × 5.625"**, not 13.3" wide. Coordinates past the edge are written, not clamped — the shape just isn't on the slide. (`LAYOUT_WIDE` is 13.3" × 7.5".)
- **Hex colors: never `#`, never 8 digits.** `color: "FF0000"`. Both `"#FF0000"` and alpha baked into the hex (`"00000020"`) **corrupt the file**. For translucency: `transparency: 0-100` on fills and images, `opacity: 0.0-1.0` on shadows — each is silently ignored on the other.
- **pptxgenjs mutates option objects in place** (converts values to EMU on first use). Never share one `shadow`/options object across two `add*` calls — build a fresh object each time.
- **Shadow `offset` must be ≥ 0** — a negative offset corrupts the file. To cast a shadow upward, use `angle: 270` with a positive offset.
- **`letterSpacing` is silently ignored** — the real option is `charSpacing`.
- **Lists:** `bullet: true` on each item, never a literal `•` (renders double bullets). Set `breakLine: true` on every array item except the last. Space bulleted paragraphs with `paraSpaceAfter`, not `lineSpacing` (huge gaps).
- **One `new pptxgen()` per output file** — never reuse an instance.
- **`rectRadius` only works on `ROUNDED_RECTANGLE`**, not `RECTANGLE`.
- **Gradient fills aren't supported** — use a gradient image as the background instead.
- **Every `addText` call without a `placeholder` needs `isTextBox: true`** — without it the shape lacks `txBox="1"`, so screen readers announce the text as a "graphic" instead of a text box. No visual change.
- **Text boxes have built-in internal padding** — set `margin: 0` whenever text must align with a shape, line, or icon at the same x.
- **Speaker notes go in `slide.addNotes("...")`** (plain text, once per slide), never in a text box on the slide.
- **Keep charts native.** Use `addChart()` for everything PowerPoint can chart (pass an array of `{type, data, options}` for combos). For PowerPoint-native features the library doesn't expose (trendlines, error bars), compute the extra series yourself or post-process the generated OOXML — do not fall back to a rendered image. Only chart types PowerPoint has no native form for (Sankey, network, chord) go in as images.
- **Default charts render bare** — no title, no data labels, dated palette. Set `showTitle` + `title`, `showValue: true` + `dataLabelPosition`, `chartColors: [...]` from your palette, and quiet the frame (`catAxisLabelColor`/`valAxisLabelColor`, `valGridLine: { color, size }`, `catGridLine: { style: "none" }`, `showLegend: false` for a single series).
- **On a stacked bar or column chart, `dataLabelPosition` must be `ctr`, `inEnd`, or `inBase`.** `outEnd` **corrupts the file**.
- **A combo series using `secondaryValAxis`/`secondaryCatAxis` needs both `valAxes` and `catAxes` on the chart options, two entries each.** Without them pptxgenjs writes axis *ids* it never declares, and PowerPoint **discards that chart** and reports the file as corrupt. Supplying only `valAxes` is not enough.
- **After `writeFile()`, run `python scripts/office/validate.py deck.pptx`.** It reports many of the chart and slide-XML faults PowerPoint refuses or repairs, the two above among them, and names the fix for each. Fix them in your generator, not by hand-editing the packed XML.
- **Never reorder the children of `<p:presentation>`.** pptxgenjs writes `<p:notesMasterIdLst>` right after `<p:sldIdLst>` and points both masters at one theme part. PowerPoint reads that happily — move the element and the same deck becomes unopenable.
- **Icons:** render `react-icons` to SVG (`ReactDOMServer.renderToStaticMarkup`), rasterize with `sharp` at ≥256px, and insert via `addImage({ data: "image/png;base64," + buf.toString("base64") })` — the `image/png;base64,` prefix is required (`react-icons`, `react`, `react-dom`, and `sharp` are preinstalled — `npm install react-icons react react-dom sharp` only if a require fails).
- **`defineSlideMaster()` creates a slide *layout*, not a master** — one `slideLayoutN.xml` per call, under a single master you cannot change. Call them layouts when talking to the user.
- **`pres.company` and a `defineSlideMaster()` `title` are written into the XML unescaped** — an `&` in either (`"Harrow & Sons"`) leaves `docProps/app.xml` or the layout unparseable, and `validate.py` fails. Write `&amp;` there, and in the matching `masterName`. `title`, `subject`, `author`, section titles, `objectName`, notes and slide text are escaped for you.

### Structured decks

A deck built on a theme, layouts, placeholders and sections can be restyled in one place and edited in PowerPoint without fighting it. Build every new deck this way unless the user asks for a quick throwaway.

1. **Theme first:** `const THEME = { name, headFontFace, bodyFontFace, colors: { dk1, lt1, dk2, lt2, accent1 … accent6, hlink, folHlink } }`, colors in hex. `pres.theme` takes the two fonts and nothing else. Name no font after that — titles get the heading font, other text the body font — except on chart text, which is hard-coded Arial: give its `*FontFace` options `"+mn-lt"` (theme body font; `"+mj-lt"` is the heading font).
2. **`const C = pres.SchemeColor` for every color** — `C.text1`/`C.text2` are `dk1`/`dk2`, `C.background1`/`C.background2` are `lt1`/`lt2`. These take hex only, read from `THEME`: `valGridLine.color`, `catGridLine.color`, `shadow.color`, and on a one-series bar chart `invertedColors` or more than one `chartColors`. A scheme color there is written as `<a:srgbClr val="bg2"/>` without complaint, and being hex, these will not follow a later change of theme.
3. **Sections:** `pres.addSection({ title })` just before that section's first slide, then `sectionTitle` on every `addSlide`. A slide without one — or, when sections are all declared up front, a table's auto-paged continuation slides — lands in a stray "Default-N" section.
4. **One layout per slide frame** (`defineSlideMaster()`): title, section divider, title only, chart + commentary, table; dark and light variants if the design alternates. Text regions are named placeholders carrying position, size, weight and `color` — chart, image and table placeholders need a `color` too, or prompt text and arrays of runs come out hard-coded `000000`. Footer text, logo and `slideNumber` go on the layout, never on a slide.
5. **Fill by name:** `addSlide({ masterName, sectionTitle })`, then `addText("…", { placeholder: "title" })` with no position, size or color — the placeholder's own options win, and anything it doesn't set (italic, `align`, `fontFace`) still applies; style one run with `[{ text, options }]`. A misspelt `placeholder` or `masterName` fails silently (a stray text box at 0,0; the blank layout). Only `title`, `body` and `chart` placeholders fill by name alone: `addImage({ placeholder })` takes the placeholder's x and y but not its size (a 1" × 1" picture) — pass `w`/`h` too. `addTable({ placeholder })` takes its x and y only — always pass `w`; when it auto-pages it ignores the placeholder and runs off the slide, so also pass `x`, `y` and `autoPageSlideStartY` (same as `y`, or continuation pages are laid out from the top margin), give the layout a `margin` whose bottom clears the footer, and fill the continuation slides' titles through `slide.newAutoPagedSlides`.
6. **A layout is the frame, not the "layout" Design Ideas means.** Cards, icons, stat callouts and images are still composed slide by slide on top of it, in scheme colors, each with an `objectName` — every Design Idea applies, and most content slides sit on the title-only layout.
7. **Write, then apply the theme:** `await pres.writeFile({ fileName: "deck.pptx" })`, then `await applyTheme("deck.pptx", THEME)`. pptxgenjs cannot write theme colors: until this runs, scheme colors resolve to Office's stock palette. It throws, changing nothing, on a scheme color in a hex-only option — fix what it names and rebuild.

## Editing existing decks and templates

Pick layouts first: `python scripts/thumbnail.py template.pptx template-thumbs` writes a labeled grid of every slide and prints the file(s) it created — `template-thumbs.jpg`, split into `template-thumbs-N.jpg` past 12 slides. **Always pass that second argument, named after the deck.** It defaults to `thumbnails`, so two decks thumbnailed in one directory silently overwrite each other's grids — the first deck's are simply gone (template analysis only — visual QA needs the full-resolution renders from [Converting to Images](#converting-to-images); it only accepts `.pptx`, so copy a `.potx` to a `.pptx` name first). Use it with `slide_text.py` to map each content section onto a template slide, and vary the layouts — don't put every section on the same title-and-bullets slide.

```bash
python -c "import sys,zipfile; zipfile.ZipFile(sys.argv[1]).extractall('unpacked')" deck.pptx
python scripts/add_slide.py unpacked/ slide2.xml --after slide2.xml   # duplicate a slide (or slideLayoutN.xml); prints the new slide's path
# reorder / delete slides = edit <p:sldIdLst> in ppt/presentation.xml
python scripts/clean.py unpacked/                                     # after deletions: removes orphaned slides, media, rels
# edit slide content in ppt/slides/slideN.xml
(cd unpacked && zip -FSXrD ../out.pptx .)                           # zip from INSIDE the dir; -FS drops parts deleted from unpacked/ (no rm) · -D writes no folder entries
python scripts/office/validate.py out.pptx --original deck.pptx
```

- **Do all structural work — add, delete, reorder — before editing any slide's content.** `add_slide.py` copies a slide file verbatim, so duplicating after you edit clones the edited content; and `clean.py` deletes any slide missing from `<p:sldIdLst>`, including one you just wrote.
- **Never copy a slide file by hand** — `add_slide.py` does every registration a new slide needs and reports what it made (`Created ppt/slides/slide17.xml from slide2.xml`). It also works directly on a file: `add_slide.py deck.pptx slide2.xml -o out.pptx` — **pass `-o`, or it rewrites the input deck in place.** A duplicated slide still *references* its source's chart/SmartArt/embedded-object parts rather than cloning them, so editing one slide's chart changes the other's.
- **If you use `python-pptx`**, three things it won't do: duplicate a slide (its only entry point is `add_slide(layout)`), preserve formatting through `text_frame.text = "..."` (that collapses the paragraph to a single unstyled run — assign `run.text` instead), or read the SVG/EMF most template art uses (`add_picture` raises `UnidentifiedImageError`).
- Legacy `.ppt` must be converted first — on a Windows PC: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/office/office_com.ps1 convert -In file.ppt -Out file.pptx`; elsewhere: `python scripts/office/soffice.py --headless --convert-to pptx file.ppt`. `.potx` templates unpack and pack identically — keep the `.potx` extension on the output.
- To reuse a template icon or image, duplicate a slide or layout that already contains it.

When filling in a template:

- If you script an XML transform, parse with `defusedxml.minidom` — round-tripping OOXML through `xml.etree.ElementTree` rewrites namespace prefixes and corrupts the deck.
- **Template slots ≠ source items.** If the template shows 4 team members and you have 3, delete the 4th member's entire group (image + text boxes), not just its text — then check for orphaned visuals in QA.
- One `<a:p>` per list item — never concatenate items into a single paragraph. Copy the sibling `<a:pPr>` to preserve spacing, and put `b="1"` on the `<a:rPr>` of titles, section headers, and inline labels (`Status:`, `Owner:`).
- Let bullets inherit from the layout; only add `<a:buChar>`, `<a:buAutoNum>` (numbered), or `<a:buNone>` to override — never a literal `•` in the text.
- Text with leading or trailing spaces needs `xml:space="preserve"` on its `<a:t>`.

## Deck content and flow

- **One message per slide.** A deck goes theme by theme, message by message.
- **A common structure is the pyramid:** the main message up front, an executive summary that previews the sections, the sections themselves, then a conclusion, usually with next steps that act on the findings.
- **Match the structure to the size of the deck.** A short deck might not need an introduction and a conclusion; a long deck might need dividers between topics.
- **Build toward what the deck is for:** a decision, consensus, a celebration, resolving a disagreement, or opening a discussion.
- **Build for how it will be used.** A live deck gets narration and possibly discussion; a pre-read has to carry the whole narrative itself. An executive audience in a live meeting needs few words and highly visual slides. Detailed, word-heavy slides are sometimes right for subject-matter experts or for a deck read offline. Analytical reports lean on charts and tables.
- **Size a live deck to the talk:** about 1.5 to 2 minutes per slide, with time left for questions if there will be any.

## Design Ideas

**Don't create boring slides.** Plain bullets on a white background won't impress anyone. Consider ideas from this list for each slide.

### Before Starting

- **Pick a bold, content-informed color palette**: The palette should feel designed for THIS topic. If swapping your colors into a completely different presentation would still "work," you haven't made specific enough choices.
- **Dominance over equality**: One color should dominate (60-70% visual weight), with 1-2 supporting tones and one sharp accent. Never give all colors equal weight.
- **Dark/light contrast**: Dark backgrounds for title + conclusion slides, light for content ("sandwich" structure). Or commit to dark throughout for a premium feel.
- **Commit to a visual motif**: Pick ONE distinctive element and repeat it — rounded image frames, icons in colored circles. Carry it across every slide. **Do not use a color bar or accent stripe as your motif** (see Avoid list).

### Color Palettes

Choose colors that match your topic — don't default to generic blue. Use these palettes as inspiration:

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| **Midnight Executive** | `1E2761` (navy) | `CADCFC` (ice blue) | `FFFFFF` (white) |
| **Forest & Moss** | `2C5F2D` (forest) | `97BC62` (moss) | `F5F5F5` (cream) |
| **Coral Energy** | `F96167` (coral) | `F9E795` (gold) | `2F3C7E` (navy) |
| **Warm Terracotta** | `B85042` (terracotta) | `E7E8D1` (sand) | `A7BEAE` (sage) |
| **Ocean Gradient** | `065A82` (deep blue) | `1C7293` (teal) | `21295C` (midnight) |
| **Charcoal Minimal** | `36454F` (charcoal) | `F2F2F2` (off-white) | `212121` (black) |
| **Teal Trust** | `028090` (teal) | `00A896` (seafoam) | `02C39A` (mint) |
| **Berry & Cream** | `6D2E46` (berry) | `A26769` (dusty rose) | `ECE2D0` (cream) |
| **Sage Calm** | `84B59F` (sage) | `69A297` (eucalyptus) | `50808E` (slate) |
| **Cherry Bold** | `990011` (cherry) | `FCF6F5` (off-white) | `2F3C7E` (navy) |

### For Each Slide

**Every slide needs a visual element** — image, chart, icon, or shape. Text-only slides are forgettable.

**Layout options:**
- Two-column (text left, illustration on right)
- Icon + text rows (icon in colored circle, bold header, description below)
- 2x2 or 2x3 grid (image on one side, grid of content blocks on other)
- Half-bleed image (full left or right side) with content overlay

**Data display:**
- Large stat callouts (big numbers 60-72pt with small labels below)
- Comparison columns (before/after, pros/cons, side-by-side options)
- Timeline or process flow (numbered steps, arrows)

**Visual polish:**
- Icons in small colored circles next to section headers
- Italic accent text for key stats or taglines

### Typography

**Font names you write into the .pptx are rendered by the user's PowerPoint.** How faithful your visual QA is depends on where it renders. On a Windows PC the QA renders come from PowerPoint itself, so nothing is substituted and the preview shows the real fit (for fonts installed on that PC). In a cloud environment they come from LibreOffice, which substitutes fonts it doesn't have — and for some fonts the substitute has different widths, so your QA preview can show text overflow (or fit) that the real deck won't have. The rules below keep that cloud preview trustworthy; they cost nothing on Windows, since the safe fonts ship with Office:

- **Safe fonts** (render true-to-width in QA *and* ship with Office): **Arial, Calibri, Cambria, Times New Roman, Courier New, Bookman Old Style, Century Schoolbook**. Use these for body text and anything where fit matters.
- **Headers with personality at zero QA risk**: pair a safe-list serif header (Cambria, Bookman Old Style, Century Schoolbook) with a safe-list sans body (Calibri or Arial). You get visual contrast without giving up reliable overflow checks.
- **If the user asks for a font outside the safe list** (e.g. Georgia or Trebuchet MS): use it where the user asked, but size those containers with extra slack (~10%) and don't trust QA text-fit on those elements — the preview of that font is approximate. If the user hasn't specified, prefer safe-list fonts for body text.
- **QA-unreliable fonts** (substitute has different widths — overflow checks can be wrong): Georgia, Trebuchet MS, Impact, Arial Black, Garamond, Consolas, Palatino Linotype. Calibri Light substitution varies by environment; treat as QA-unreliable. Fine for titles/accents with slack; don't trust QA text-fit on these.
- **Never default to Aptos** — Office's post-2023 default has no metric-compatible substitute in LibreOffice *and* is missing from older Office installs, so it's unreliable on both ends.

| Element | Size |
|---------|------|
| Slide title | 36-44pt bold |
| Section header | 20-24pt bold |
| Body text | 14-16pt |
| Captions | 10-12pt muted |

### Spacing

- 0.5" minimum margins
- 0.3-0.5" between content blocks
- Leave breathing room—don't fill every inch

### Avoid (Common Mistakes)

- **Don't repeat the same layout** — vary columns, cards, and callouts across slides
- **Don't end a slide title with a period**
- **Don't let titles drift between slides of the same type** — content slides with the title at the top put it at the same position, font, size, and alignment on every slide; a different slide type (a section divider with the title mid-slide) can place it differently
- **Don't change how chart labels look from chart to chart** — axis and data labels use the same color, font, and size on every chart in the deck; vary one only where a chart needs it (a second axis, a highlighted series, a label sitting on a dark bar)
- **Don't center body text** — left-align paragraphs and lists; center only titles
- **Don't skimp on size contrast** — titles need 36pt+ to stand out from 14-16pt body
- **Don't default to blue** — pick colors that reflect the specific topic
- **Don't mix spacing randomly** — choose 0.3" or 0.5" gaps and use consistently
- **Don't style one slide and leave the rest plain** — commit fully or keep it simple throughout
- **Don't create text-only slides** — add images, icons, charts, or visual elements; avoid plain title + bullets
- **Don't forget text box padding** — when aligning lines or shapes with text edges, set `margin: 0` on the text box or offset the shape to account for padding
- **Don't use low-contrast elements** — icons AND text need strong contrast against the background; avoid light text on light backgrounds or dark text on dark backgrounds
- **NEVER use accent lines under titles** — these are a hallmark of AI-generated slides; use whitespace or background color instead
- **NEVER add decorative color bars or accent stripes** — this includes: header/footer bars spanning the slide width, vertical sidebar stripes down one edge of the slide, thin accent stripes along one edge of a card or content block, and "single-side borders" on rectangles. These read as AI-generated filler. If you want to set a card apart, use a subtle background tint, a drop shadow, or an icon — not an edge stripe.
- **Don't default to cream/beige backgrounds** — when no background is specified, use white (`FFFFFF`) or the user's brand palette; avoid warm-neutral defaults like `F5F5DC`, `FAF0E6`, `FAEBD7`, `FFF8E1`
- **Don't ship text that overflows its shape** — if text doesn't fit, reduce font size, split across slides, or enlarge the container; never leave content cut off or spilling past bounds. **Don't shrink below the sizes in the Typography table** (body text 14pt, captions 10pt) in a deck you create — once you reach that floor, cut words, enlarge the container, or split the slide instead; when editing an existing deck or template, match its sizes

## QA (Required)

Your first render usually has a few real issues — overlaps, overflow, misalignment. Find and fix those, re-render only the slides you changed, and stop.

### Content QA (required)

```bash
python scripts/slide_text.py output.pptx
```

Check for missing content, typos, wrong order.

**When using templates, check for leftover placeholder text:**

```bash
python scripts/slide_text.py output.pptx | grep -iE "\bx{3,}\b|lorem|ipsum|\bTODO|\[insert|this.*(page|slide).*layout"
```

If grep returns results, fix them before declaring success.

### File QA (required)

```bash
python scripts/office/validate.py output.pptx                      # built from scratch
python scripts/office/validate.py output.pptx --original src.pptx  # built from a template
```

**If the deck came from a template, always pass `--original`.** A template may itself
contain parts the XSD rejects, so a bare run can report failures you never caused — and
a genuine regression can hide among them. `--original` baselines
the schema and slide checks against the template, suppressing errors it already had.
The structural checks — relationships, content types, charts — ignore `--original` and
report template-inherited problems either way, so read those on their own merits.

pptxgenjs emits chart XML PowerPoint refuses to open, and every other tool
accepts: python-pptx opens those decks, LibreOffice renders them, the XSD
passes them. Every failure names its fix. Fix it in the generator and rebuild.

**A pass is not proof of a valid file:** `validate.py` does not catch everything PowerPoint repairs (a chart element repeated past its limit passes); when you delete an animated shape from a template slide, delete the slide's `<p:timing>` element too (its animations go with it), or PowerPoint offers to repair the deck.

### Visual QA (required)

Convert the slides to images (see [Converting to Images](#converting-to-images)) and inspect every one. After staring at the generating code you tend to see what you expect rather than what rendered, so look at the images fresh (a subagent works well for this if you have one). User-visible defects to look for:

- **Text overflow or text cut off at a box or slide boundary — check this first.** It is the most common defect and always user-visible. (For a font the previewer renders unreliably per Typography, the preview is approximate: trust the ~10% slack you left, not its apparent fit.)
- Overlapping elements (text through shapes, lines through words, stacked elements)
- Source citations or footers colliding with content above
- Elements too close (< 0.3" gaps) or cards/sections nearly touching
- Uneven gaps (large empty area in one place, cramped in another)
- Insufficient margin from slide edges (< 0.5")
- Columns or similar elements not aligned consistently
- Low-contrast text (e.g., light gray text on cream-colored background)
- Template decoration mispositioned after text replacement — e.g., a title underline positioned for one line, but the replaced title wrapped to two
- Low-contrast icons (e.g., dark icons on dark backgrounds without a contrasting circle)
- Text boxes too narrow causing excessive wrapping
- Titles at different heights, or chart labels that look different from chart to chart, across slides of the same type — compare slides with each other, not only each slide with itself
- A word or number broken across two lines — a word split mid-word, or a figure separated from its unit ("26" on one line, "M" on the next)
- Leftover placeholder content

## Converting to Images

Convert presentations to individual slide images for visual inspection. Rendering always goes through a PDF — LibreOffice's `--convert-to png` exports only the first slide. Each run writes the PDF and its slide images into a new folder — `render-1`, then `render-2` after a fix, and so on (`mkdir` refuses a name already used) — so neither a PDF nor images from an earlier run mix in: if the conversion fails, the new folder has no PDF.

**Step 1 — PDF.** On a Windows PC, PowerPoint renders it (if PowerPoint cannot be used, the premise is broken: record both steps as not run and tell the user — LibreOffice is not the fallback, and do not try to repair Office; if the deck is already open in PowerPoint, ask the user to save and close it, then render again — see [Scripts](#scripts)):

```bash
mkdir render-1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/office/office_com.ps1 export-pdf -In output.pptx -Out render-1/output.pdf
```

Elsewhere, LibreOffice renders it, substituting fonts it lacks (see [Typography](#typography)):

```bash
mkdir render-1
python scripts/office/soffice.py --headless --convert-to pdf --outdir render-1 output.pptx
```

If LibreOffice prints `Error: source file could not be loaded` and writes nothing, its Impress component is missing (e.g. the `libreoffice-impress` package) — install it. The file name is not the cause: names with spaces or Korean characters convert fine.

**Step 2 — slide images**, the same in every environment, from the PDF in that run's folder:

```bash
pdftoppm -jpeg -r 150 render-1/output.pdf render-1/slide
ls -1 "$PWD"/render-1/slide-*.jpg
```

Without `pdftoppm` (Poppler), run this pypdfium2 line in its place — same file names, same 150 DPI:

```bash
python -c "import sys, pypdfium2 as p; d = p.PdfDocument(sys.argv[1]); w = len(str(len(d))); [d[i].render(scale=150 / 72).to_pil().save(f'{sys.argv[2]}-{i + 1:0{w}d}.jpg') for i in range(len(d))]" render-1/output.pdf render-1/slide
```

**Pass the absolute paths printed above directly to the view tool.** Keep the earlier folders while you work — they let you compare before and after a fix — and clear them once, when the work is done. `pdftoppm` zero-pads based on page count, and the pypdfium2 line does the same: `slide-1.jpg` for decks under 10 pages, `slide-01.jpg` for 10-99, `slide-001.jpg` for 100+.

**After fixes, rerun both steps** into the next folder — the PDF must be regenerated from the edited `.pptx` before the images can reflect your changes.

## Dependencies

`pptxgenjs` (npm, preinstalled — install only if `require('pptxgenjs')` fails) · `python-pptx`, `Pillow`, `defusedxml`, `lxml` (pip — slide_text, thumbnail, clean, validate) · rendering and `.ppt` conversion: on a Windows PC, Microsoft PowerPoint through COM (`scripts/office/office_com.ps1`, run with Windows PowerShell); elsewhere LibreOffice with its Impress component (`soffice`, auto-configured for sandboxed environments via `scripts/office/soffice.py`) · rasterizing: `pdftoppm` (Poppler), or `pypdfium2` (pip) where Poppler is absent

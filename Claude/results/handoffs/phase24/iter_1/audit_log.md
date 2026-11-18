# Audit log — Phase 24 Step 39 — review B (bada-a3-reviewer) — appearance-24.md ② local

Counts: 중대 0 · 중간 3 · 경미 6 (report saved verbatim in substance below)

- M1 appearance-24.md:52 — "설계 좌표의 빈 테두리" fallback unusable for regions with no Step 5 coordinate (Quartz 7, Hekili/CDM 8, Details 10, Experience Forever 19 — not in devil-ui-old-4k-layout.md:45–56).
- M2 appearance-24.md:24–25 — forbids only "게임 세계 갈무리"; appearance results contain real game screenshots (appearance-4.md:32, appearance-10.md:31, appearance-22.md:26, appearance-2.md:32, appearance-9.md:29); layout-spec rendererContract.referenceScreenshotInRenderedScene=false → cut-and-paste path open.
- M3 appearance-24.md:44–50 — inputs miss manifest (plan 351) and frame-name list (plan 433); Collection/manifest.json·.md and registry_extra.json exist.
- m1 :6 "모두 … 올릴 자리" — Step 5 design, install.json, classes.md already exist.
- m2 :23 label spot defined only for UHD; crop corner size undefined.
- m3 R109 not in master plan (it is in REQUEST_LEDGER_phase19.md:7 — master check).
- m4 :25/:28 UHD from Step 5 vs uhd.lua preset — no rule when they differ.
- m5 :16/:24 keybind glyph source undefined (text-metrics.json sample keys?).
- m6 :14 solo state — combat/target/cast states undefined.

Read: appearance-24 1–62; plan 90–98,135–166,335–355,405–413,433–434,452–458; devil-ui-old-4k-layout 1–105; install.json 1–36; 설치안내 1–53; classes 1–47; appearance-2,2-layouts,4,9,10,22 full; work_log-a2 1–64; layout-spec keys via python.

## Re-check 1 (same B) — 중대 0 · 중간 1 · 경미 3
- M1′ :40 class-resource fallback 「외관 미완 — 설계 좌표만」 conflicts with :55 for Dominos stance/totem bars (:35, :37) — no Step 5 position (devil-ui-old-4k-layout.md:60); A2 impact map marked :40 "check only" without these.
- m1 :51 says write frame names in index, :61 column list has no frame-name column; not-made images (:19, :56) have no row.
- m2 :55 example reads as Step 5-only though :54 accepts preset coordinates.
- m3 :29 cites R109 for "unit default may change" — R109 is "Codex on hold, finish Claude part first".
Fixed confirmed: M1, M2, M3, :6, UHD preset rule, key glyph source.

## Re-check 2 (same B) — 중대 0 · 중간 0 · 경미 2
- M1′, m1, m2, m3 fixed; :40 agrees with :54–55, §2-7 (:29), :61.
- m-a :29 cites 설치안내.md:28 which says only 「모음집 기본은 PitBull4 다」; 「Phase 23」「임시」 not on that line (content correct — plan 457).
- m-b :17 crop 「unit 프레임 둘레」 may exclude Dominos stance/totem bars now read per :40; no rule to widen crop or note in index.

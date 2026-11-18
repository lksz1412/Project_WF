"""Render the fixed-pixel offline layout proposal using Pillow and local assets."""
import argparse
import hashlib
import json
from collections import Counter
from itertools import combinations
from pathlib import Path

from PIL import Image, ImageChops, ImageColor, ImageDraw, ImageFont, ImageOps


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def overlap(a, b):
    return (min(a[0] + a[2], b[0] + b[2]) > max(a[0], b[0])
            and min(a[1] + a[3], b[1] + b[3]) > max(a[1], b[1]))


def contrast(a, b):
    def luminance(rgb):
        linear = [c / 255 / 12.92 if c / 255 <= .04045
                  else ((c / 255 + .055) / 1.055) ** 2.4 for c in rgb]
        return sum(c * w for c, w in zip(linear, (.2126, .7152, .0722)))
    first, second = sorted((luminance(a), luminance(b)))
    return (second + .05) / (first + .05)


class Renderer:
    def __init__(self, project, spec_path):
        self.project = project
        self.spec_path = spec_path
        self.spec = json.loads(spec_path.read_text(encoding="utf-8"))
        self.width = self.spec["canvas"]["width"]
        self.height = self.spec["canvas"]["height"]
        self.rects = self.spec["rectangles"]
        self.by_id = {r["id"]: r for r in self.rects}
        self.colors = {k: ImageColor.getrgb(v) for k, v in self.spec["color_tokens"].items()}
        self.font_path = Path(self.spec["font"]["preferred_file"])
        self.fonts = {}
        self.text_records = []
        self.manifest = []
        self.annotation_rects = []
        self.assets = {}
        self.asset_records = {}
        for key in ("button_frame", "statusbar", "decor_left", "decor_right", "border"):
            item = self.spec["assets"][key]
            path = Path(self.spec["asset_base"]) / item["path"]
            with Image.open(path) as source:
                texture = source.convert("RGBA")
            self.asset_records[key] = {"path": str(path), "sha256": digest(path),
                                       "original_size": list(texture.size),
                                       "alpha_bbox": list(texture.getbbox())}
            if "alpha_bbox" in item:
                texture = texture.crop(item["alpha_bbox"])
            self.assets[key] = texture
        self.image = Image.new("RGBA", (self.width, self.height))

    def font(self, px):
        if px not in self.fonts:
            self.fonts[px] = ImageFont.truetype(str(self.font_path), px)
        return self.fonts[px]

    def label(self, layer, text, px, owner, align="center", pad=2, region=None):
        font = self.font(px)
        glyph = font.getbbox(text)
        gw, gh = glyph[2] - glyph[0], glyph[3] - glyph[1]
        region = region or (0, 0, layer.width, layer.height)
        rx, ry, rw, rh = region
        plate_w, plate_h = gw + 2 * pad, gh + 2 * pad
        if plate_w > rw or plate_h > rh:
            raise ValueError(f"label does not fit: {owner}: {text!r} {plate_w}x{plate_h} in {rw}x{rh}")
        x = rx if align == "left" else rx + rw - plate_w if align == "right" else rx + (rw - plate_w) // 2
        y = ry + (rh - plate_h) // 2
        draw = ImageDraw.Draw(layer)
        draw.rectangle((x, y, x + plate_w - 1, y + plate_h - 1), fill=self.colors["text_plate"])
        draw.text((x + pad - glyph[0], y + pad - glyph[1]), text, font=font, fill=self.colors["text"])
        self.text_records.append({"owner": owner, "text": text, "font_px": px,
                                  "glyph_bounds": list(glyph), "plate_local": [x, y, plate_w, plate_h],
                                  "layer_size": list(layer.size), "fits": True})

    def border(self, layer, width, dashed=False):
        draw = ImageDraw.Draw(layer)
        color = self.colors["border"]
        w, h = layer.size
        if dashed:
            for x in range(0, w, 16):
                draw.rectangle((x, 0, min(x + 9, w - 1), width - 1), fill=color)
                draw.rectangle((x, h - width, min(x + 9, w - 1), h - 1), fill=color)
            for y in range(0, h, 16):
                draw.rectangle((0, y, width - 1, min(y + 9, h - 1)), fill=color)
                draw.rectangle((w - width, y, w - 1, min(y + 9, h - 1)), fill=color)
        else:
            draw.rectangle((0, 0, w - 1, h - 1), outline=color, width=width)
            if w > 2 * width and h > 2 * width:
                draw.rectangle((width, width, w - width - 1, h - width - 1), outline=(30, 30, 30))

    def paint(self, r):
        w, h, kind = r["w"], r["h"], r["kind"]
        layer = Image.new("RGBA", (w, h))
        draw = ImageDraw.Draw(layer)
        if kind == "background":
            if "color_token" in r:
                draw.rectangle((0, 0, w - 1, h - 1), fill=self.colors[r["color_token"]])
            else:
                top = self.colors[r["gradient_top_token"]]
                bottom = self.colors[r["gradient_bottom_token"]]
                for y in range(h):
                    f = y / (h - 1)
                    color = tuple(round(a + (b - a) * f) for a, b in zip(top, bottom))
                    alpha = round(255 * (r["alpha_top"] + (r["alpha_bottom"] - r["alpha_top"]) * f))
                    draw.line((0, y, w - 1, y), fill=color + (alpha,))
        elif kind in ("rail", "status_strip"):
            fill = r.get("fill_token", r.get("color_token"))
            draw.rectangle((0, 0, w - 1, h - 1), fill=self.colors[fill])
            if r.get("text"):
                self.label(layer, r["text"], r["font_px"], r["id"], align="left", region=(8, 0, w - 16, h))
        elif kind == "framed_panel":
            draw.rectangle((0, 0, w - 1, h - 1), fill=self.colors[r["fill_token"]] + (round(255 * r["fill_alpha"]),))
            self.border(layer, r["border_px"])
        elif kind == "minimap_placeholder":
            draw.rectangle((0, 0, w - 1, h - 1), fill=(39, 39, 39))
            for offset in range(24, w - 4, 40):
                draw.line((offset, 4, offset, h - 5), fill=(57, 57, 57))
                draw.line((4, offset, w - 5, offset), fill=(57, 57, 57))
            self.border(layer, r["border_px"])
            self.label(layer, r["text"], r["font_px"], r["id"])
        elif kind == "label":
            self.label(layer, r["text"], r["font_px"], r["id"], pad=0)
        elif kind in ("utility_placeholder", "bag_placeholder"):
            if kind == "bag_placeholder":
                draw.rectangle((3, 3, w - 4, h - 4), fill=(24, 24, 24), outline=self.colors["border"], width=2)
                draw.rectangle((12, 12, w - 13, h - 13), outline=(153, 153, 153), width=2)
            else:
                draw.rectangle((6, 17, w - 7, h - 18), outline=(163, 163, 163), width=2)
                draw.line((10, h // 2, w - 11, h // 2), fill=(163, 163, 163), width=2)
        elif kind == "action_slot":
            if r["source_observed_icon"]:
                inset = r["icon_inset"]
                draw.rectangle((inset, inset, w - inset - 1, h - inset - 1), fill=self.colors["placeholder_icon"])
                cx, cy, radius = w // 2, h // 2, w // 5
                draw.polygon(((cx, cy - radius), (cx + radius, cy), (cx, cy + radius), (cx - radius, cy)),
                             fill=(146, 149, 154), outline=(197, 198, 201))
            frame = ImageOps.contain(self.assets[r["frame_asset"]], (w, h), Image.Resampling.LANCZOS)
            layer.alpha_composite(frame, ((w - frame.width) // 2, (h - frame.height) // 2))
            if r["key_label"]:
                self.label(layer, r["key_label"], r["key_font_px"], r["id"], align="right",
                           region=(4, 4, w - 8, 32))
        elif kind == "unit_frame":
            draw.rectangle((0, 0, w - 1, h - 1), fill=self.colors["panel"])
            self.border(layer, r["border_px"], dashed=r["outline"].startswith("dashed"))
        elif kind == "resource_bar":
            texture = self.assets[r["asset"]].resize((w, h), Image.Resampling.LANCZOS).convert("RGB")
            tinted = ImageChops.multiply(texture, Image.new("RGB", (w, h), self.colors[r["tint_token"]]))
            layer.alpha_composite(tinted.convert("RGBA"))
            self.label(layer, r["text"], r["font_px"], r["id"], align="right", pad=0,
                       region=(8, 0, w - 16, h))
        elif kind == "decor":
            art = ImageOps.contain(self.assets[r["asset"]], (w, h), Image.Resampling.LANCZOS)
            layer.alpha_composite(art, ((w - art.width) // 2, h - art.height))
        else:
            raise ValueError(f"unhandled kind {kind}")
        return layer

    def render(self):
        for r in sorted(self.rects, key=lambda value: value["z"]):
            position = (r["x"], self.height - r["y"] - r["h"])
            record = {"id": r["id"], "spec_xywh_bottom_left": [r[k] for k in ("x", "y", "w", "h")],
                      "painted": bool(r["visible"] and r.get("draw", True))}
            if record["painted"]:
                layer = self.paint(r)
                self.image.alpha_composite(layer, position)
                record["actual_paste_xywh_top_left"] = [*position, *layer.size]
                record["local_alpha_bbox"] = layer.getbbox()
            self.manifest.append(record)
        for identity in ("player", "target"):
            r = self.by_id[identity]
            overlay = Image.new("RGBA", (r["w"], r["h"]))
            self.label(overlay, r["text"], r["font_px"], identity, align="left", region=(12, 10, 248, 36))
            self.image.alpha_composite(overlay, (r["x"], self.height - r["y"] - r["h"]))
        self.annotate("제안 배치 · 모든 아이콘·값은 자리표시", (80, 72, 980, 40))
        self.annotate("3840×2160 작업판 · 게임 적용 전", (80, 120, 980, 40))
        self.annotate("제안 배치 · 체력·마나·지도는 자리표시", (80, 1372, 900, 40))
        self.annotate("점선 대상창 = 추가 제안 · 키 = 글자 예시", (80, 1420, 900, 40))
        self.image = self.image.convert("RGB")
        return self.image

    def annotate(self, text, bounds):
        x, y, w, h = bounds
        layer = Image.new("RGBA", (w, h))
        self.label(layer, text, 24, "proposal_legend", align="left")
        self.image.alpha_composite(layer, (x, y))
        self.annotation_rects.append(list(bounds))

    def validate(self):
        t, failures = self.spec["tokens_px"], []
        def require(condition, detail):
            if not condition:
                failures.append(detail)
        require(self.spec["schema"] == "devil-ui-layout/1", "schema")
        require((self.width, self.height) == (3840, 2160), "canvas3840x2160")
        require(len(self.rects) == len(self.by_id) == 122, "122 unique rectangles")
        require(self.spec["canvas"]["origin"] == "bottom-left", "origin")
        require(self.spec["canvas"]["global_layout_scale"] is None, "no global layout scale")
        groups = {}
        for name, columns, rows, size, gap in (("strip_36", 36, 1, 80, 3), ("bank_8x3", 8, 3, 80, 4),
                                                ("floating_left", 4, 3, 68, 4), ("floating_right", 4, 3, 68, 4)):
            parent = self.by_id[name]
            slots = [r for r in self.rects if r.get("parent_id") == name]
            require(len(slots) == columns * rows, name + " count")
            require((parent["w"], parent["h"]) == (columns * size + (columns - 1) * gap,
                                                       rows * size + (rows - 1) * gap), name + " outer size")
            for r in slots:
                expected = [parent["x"] + (r["column_from_left"] - 1) * (size + gap),
                            parent["y"] + (rows - r["row_from_top"]) * (size + gap), size, size]
                require([r[k] for k in ("x", "y", "w", "h")] == expected, r["id"] + " pitch")
            groups[name] = {"slots": len(slots), "occupied_placeholders": sum(r["source_observed_icon"] for r in slots),
                            "rows": rows, "columns": columns, "slot_px": size, "gap_px": gap}
        require(sum(g["slots"] for g in groups.values()) == 84, "84 slots")
        require([g["occupied_placeholders"] for g in groups.values()] == [21, 3, 2, 0], "26 occupied placeholders")
        bank_bottom = t["status_height"] + t["utility_lower_gap"] + t["utility_height"] + t["utility_upper_gap"]
        bank_height = 3 * t["action_slot"] + 2 * t["bank_gap"]
        dock_height = bank_bottom + bank_height + t["bank_top_padding"] + t["rail_height"]
        require((bank_bottom, bank_height, dock_height) == (104, 248, 392), "bottom-up104/248/392")
        require(self.by_id["bank_8x3"]["y"] == bank_bottom and self.by_id["dock"]["h"] == dock_height,
                "bank/dock baseline")
        require(self.by_id["strip_36"]["y"] == dock_height, "main strip baseline")
        require(self.by_id["player"]["y"] == t["strip_top"] + t["unit_bottom_offset_from_strip_top"], "unit baseline")
        for r in self.rects:
            require(r["w"] > 0 and r["h"] > 0 and r["x"] >= 0 and r["y"] >= 0
                    and r["x"] + r["w"] <= self.width and r["y"] + r["h"] <= self.height, r["id"] + " bounds")
        interactive = [r for r in self.rects if r["visible"] and r["interactive"]]
        input_collisions = []
        for a, b in combinations(interactive, 2):
            if overlap([a[k] for k in ("x", "y", "w", "h")], [b[k] for k in ("x", "y", "w", "h")]):
                input_collisions.append([a["id"], b["id"]])
        require(not input_collisions, "interactive collisions")
        decor_overlaps = []
        for art in (self.by_id["decor_left"], self.by_id["decor_right"]):
            for r in interactive:
                if overlap([art[k] for k in ("x", "y", "w", "h")], [r[k] for k in ("x", "y", "w", "h")]):
                    pair = [art["id"], r["id"]]
                    decor_overlaps.append(pair)
                    require(pair == ["decor_right", "strip_36_slot_36"], "undeclared art/input overlap")
        def ancestor(a, b):
            parent = b.get("parent_id")
            while parent:
                if parent == a["id"]:
                    return True
                parent = self.by_id[parent].get("parent_id")
            return False
        painted = [r for r in self.rects if r["visible"] and r.get("draw", True)]
        layer_collisions, allowed_layers = [], Counter()
        for a, b in combinations(painted, 2):
            if not overlap([a[k] for k in ("x", "y", "w", "h")], [b[k] for k in ("x", "y", "w", "h")]):
                continue
            ids = {a["id"], b["id"]}
            if a["kind"] == "background" or b["kind"] == "background":
                allowed_layers["background_underlay"] += 1
            elif ancestor(a, b) or ancestor(b, a):
                allowed_layers["ancestor_child"] += 1
            elif ("rail" in ids and any(r["kind"] == "decor" for r in (a, b))) or ids == {"decor_right", "strip_36_slot_36"}:
                allowed_layers["declared_art_overlap"] += 1
            else:
                layer_collisions.append(sorted(ids))
        require(not layer_collisions, "undeclared painted-layer collisions")
        annotation_collisions = []
        for annotation in self.annotation_rects:
            for r in interactive:
                target = [r["x"], self.height - r["y"] - r["h"], r["w"], r["h"]]
                if overlap(annotation, target):
                    annotation_collisions.append(r["id"])
        require(not annotation_collisions, "annotation/input collisions")
        for record in self.manifest:
            if record["painted"]:
                x, y, w, h = record["spec_xywh_bottom_left"]
                require(record["actual_paste_xywh_top_left"] == [x, self.height - y - h, w, h], record["id"] + " render rect")
        require(len(self.manifest) == 122, "all rectangles consumed")
        return {"status": "PASS" if not failures else "FAIL", "failures": failures,
                "rectangles_consumed": len(self.manifest), "painted_rectangles": sum(r["painted"] for r in self.manifest),
                "grids": groups, "bottom_up": {"bank_bottom": bank_bottom, "bank_height": bank_height, "dock_height": dock_height},
                "interactive_rectangles": len(interactive), "input_collisions": input_collisions,
                "declared_decor_input_overlaps": decor_overlaps, "layer_collisions": layer_collisions,
                "allowed_layer_overlap_counts": dict(allowed_layers), "annotation_collisions": annotation_collisions,
                "render_manifest": self.manifest}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--spec", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    output = args.output_dir.resolve()
    protected = (args.project_root.resolve() / "SourceArchive", args.project_root.resolve() / "World of Warcraft")
    if any(output == p or p in output.parents for p in protected):
        parser.error("output must be a preview directory, outside game/source")
    output.mkdir(parents=True, exist_ok=True)
    renderer = Renderer(args.project_root, args.spec)
    full = renderer.render()
    checks = renderer.validate()
    full_path = output / "preview-full-4k.png"
    crop_path = output / "preview-bottom-native.png"
    full.save(full_path)
    with Image.open(full_path) as saved:
        saved.crop((0, 1360, 3840, 2160)).save(crop_path)
    with Image.open(full_path) as saved, Image.open(crop_path) as cropped:
        dimensions_ok = saved.size == (3840, 2160) and cropped.size == (3840, 800)
        crop_identical = saved.crop((0, 1360, 3840, 2160)).tobytes() == cropped.tobytes()
    label_plate = renderer.text_records[-2]["plate_local"]
    ax, ay = renderer.annotation_rects[2][:2]
    lx, ly, lw, lh = label_plate
    measured_plate = full.getpixel((ax + lx, ay + ly))
    measured_foreground = max(full.crop((ax + lx, ay + ly, ax + lx + lw, ay + ly + lh)).getdata(), key=sum)
    checks.update({"full_png": {"path": full_path.name, "size": [3840, 2160], "sha256": digest(full_path)},
                   "bottom_png": {"path": crop_path.name, "size": [3840, 800], "sha256": digest(crop_path),
                                  "crop_top_left": [0, 1360, 3840, 2160], "identical_native_pixels": crop_identical},
                   "dimensions_verified": dimensions_ok, "spec_sha256": digest(args.spec),
                   "font": {"path": str(renderer.font_path), "sha256": digest(renderer.font_path),
                            "loaded_px": sorted(renderer.fonts)}, "labels": renderer.text_records,
                   "assets": renderer.asset_records, "annotation_rects_top_left": renderer.annotation_rects,
                   "contrast": {"text_vs_solid_plate": round(contrast(renderer.colors["text"], renderer.colors["text_plate"]), 4),
                                "method": "sRGB relative luminance; opaque glyph foreground and plate; antialias edge excluded",
                                "render_plate_sample_rgb": list(measured_plate),
                                "render_foreground_sample_rgb": list(measured_foreground),
                                "sample_xy": [ax + lx, ay + ly],
                                "sampled_render_contrast": round(contrast(measured_foreground, measured_plate), 4)},
                   "visual_inspection": "pending independent image-reader and B review", "game_runtime": "NOT_RUN",
                   "limitations": ["Devil2 edge texture read but neutral4px border drawn; no exact WoW eight-segment edge simulation",
                                   "Glamour7 tint/stretch is offline composition, not runtime shader verification",
                                   "Recovered art is proposed reference; hidden screenshot shape not reconstructed",
                                   "Native crop includes lower800pixels; floating banks remain in full image only"]})
    if not dimensions_ok or not crop_identical:
        checks["failures"].append("PNG dimensions/native crop")
    checks["status"] = "PASS" if not checks["failures"] else "FAIL"
    (output / "preview-checks.json").write_text(json.dumps(checks, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    notes = f"""# 오프라인 배치 미리보기

이 이미지는 게임 적용 전 제안입니다. 아이콘·체력·마나·지역·지도와 ‘키’는 자리표시입니다. 실제 주문·특성·단축키를 배정하지 않았습니다. 점선 대상 창은 원본에서 별도로 관측된 창이 아니라 추가 배치 제안입니다.

- 전체: preview-full-4k.png, 3840×2160. 실제 모니터·게임 해상도와 UI scale은 미검증입니다.
- 하단: preview-bottom-native.png, 전체 이미지의 y1360–2159를 그대로 자른 3840×800. 확대·축소하지 않았으며 본인·대상 제안을 포함합니다.
- 긴 줄36칸, 하단8×3의24칸, 좌우4×3의12칸씩, 총84칸. 중립 아이콘26개, 나머지는 빈 프레임입니다.
- 버튼 외곽80px·작은 버튼68px·하단 묶음248px·검정 하단부392px. 전체 화면 비율 변환 없이 layout-spec.json의 명시 좌표를 사용했습니다.
- 글자22/24px, 회수2002.TTF 사용. 밝은 글자/어두운 바탕 계산 대비 {checks['contrast']['text_vs_solid_plate']:.2f}:1. 실제 거리·긴 단축키 문자열 가독성은 미검증입니다.

원본 참고: [2022년 공개 게시물](https://www.inven.co.kr/board/wow/1636/31588). 이미지 확보 기록은 reference-acquisition.json, 원본 근사 좌표는 original-image-geometry.md, 회수 설정 대조는 source-comparison.md입니다.

회수한 Onyx Classic·Glamour7·좌우 장식 파일을 읽기 전용으로 합성했습니다. Devil2 파일은 확인했지만 정확한 게임식8구획 테두리 대신 중립4px 경계를 사용했습니다. 우측 장식의 가려진 모양을 복원한 결과가 아닙니다. 게임 배경은 단색 자리표시이며 개인 채팅·캐릭터명·원본 주문 아이콘을 옮기지 않았습니다.

기계 검사 결과: {checks['status']}, 122개 사각형 처리·84칸·입력 요소 충돌0·원본 크기 crop 픽셀 일치. 상세 좌표·글자 경계·자산 해시는 preview-checks.json에 있습니다. 독립 이미지 판독·B 검수는 대기 중입니다. 실제 게임 입력·프로필 수용·전투·재접속·미니맵 작동은 실행하지 않았습니다.

다시 생성하려면 기존 Python과 Pillow로 다음을 실행합니다. 출력은 새 빈 폴더를 지정합니다.

```powershell
$env:PYTHONIOENCODING='utf-8'
python render-layout.py --project-root D:/Projects/Project_WF --spec D:/Projects/Project_WF/Codex/results/layout-design/layout-spec.json --output-dir <새_출력_폴더>
```
"""
    (output / "preview-notes.md").write_text(notes, encoding="utf-8")
    print(f"{checks['status']} rectangles={len(renderer.manifest)} slots=84 occupied=26 input_collisions={len(checks['input_collisions'])} full=3840x2160 crop=3840x800 native_equal={crop_identical} labels={len(renderer.text_records)}")
    return 0 if checks["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

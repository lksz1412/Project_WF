"""Render proposed Phase 25 placement over the approved artwork and compare independent art pieces."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = Path.cwd()
APPROVED = ROOT / "References/codex-appearance/24"
ADDONS = ROOT / "Collection/AddOns"
APPEARANCE = ADDONS / "DevilForever_Appearance"
THEMES = (
    "devil", "horde", "alliance", "orc", "troll", "undead", "tauren", "human",
    "dwarf", "gnome", "nightelf", "skyborne", "skyborne-horde",
)
PRESETS = ("fhd", "qhd", "uhd")
GRID = ADDONS / "Grid2/media"
TOTEM_BORDER = ADDONS / "PitBull4/Modules/Totems/border.tga"
STATUS_TEXTURE = APPEARANCE / "Themes/devil/statusbar.tga"
P = {
    "fhd": {"gridGap": 4, "gridFont": 12, "gridBorder": 2, "totemMargin": 6, "totemIcon": 24, "totemGap": 4, "totemFont": 12, "petWidth": 160, "petHeight": 28, "petY": 680},
    "qhd": {"gridGap": 4, "gridFont": 14, "gridBorder": 3, "totemMargin": 6, "totemIcon": 28, "totemGap": 4, "totemFont": 14, "petWidth": 160, "petHeight": 32, "petY": 994},
    "uhd": {"gridGap": 6, "gridFont": 18, "gridBorder": 4, "totemMargin": 8, "totemIcon": 36, "totemGap": 6, "totemFont": 18, "petWidth": 190, "petHeight": 36, "petY": 1540},
}

def load_json(path):
    return json.loads(path.read_text(encoding="utf-8"))

def save_json(path, body):
    with path.open("x", encoding="utf-8", newline="\n") as stream:
        json.dump(body, stream, indent=2, ensure_ascii=False)
        stream.write("\n")

def image(path):
    with Image.open(path) as source:
        return source.convert("RGBA")

def tint(source, w, h, color):
    scaled = source.resize((w, h), Image.Resampling.BILINEAR)
    result = ImageChops.multiply(scaled, Image.new("RGBA", (w, h), color))
    result.putalpha(scaled.getchannel("A"))
    return result

def overlaps(a, b):
    x,y,w,h=a
    X,Y,W,H=b
    return x<X+W and X<x+w and y<Y+H and Y<y+h

def size(box):
    x,y,r,b=box
    return [x,y,r-x,b-y]

def stack_rules(preset, screen, geometry):
    button, padding, status_height, deck_height, ribbon, font_size = {
        "fhd": (48, 6, 22, 192, 10, 18),
        "qhd": (56, 6, 24, 224, 12, 22),
        "uhd": (80, 8, 28, 304, 16, 28),
    }[preset]
    slot_gap = 2
    status_bottom = screen[1] - padding
    status_top = status_bottom - status_height
    deck_top = status_top - deck_height
    upper_bottom = deck_top - ribbon
    upper_top = upper_bottom - button
    aux_bottom = upper_top - padding
    assert geometry["status"][1:4:2] == [status_top, status_bottom]
    assert geometry["chat1"][1:4:2] == [deck_top, status_top]
    assert geometry["upper"][1:4:2] == [upper_top, upper_bottom]
    assert geometry["aux"][1:4:2] == [aux_bottom - button, aux_bottom]
    assert size(geometry["action"])[2] == 8 * button + 7 * slot_gap + 2 * padding
    assert size(geometry["upper"])[2] == 36 * button + 35 * slot_gap
    return {
        "slotPx": button, "gapPx": slot_gap, "paddingPx": padding,
        "bottomMarginPx": padding, "statusHeightPx": status_height,
        "deckHeightPx": deck_height, "ribbonPx": ribbon,
        "auxGapPx": padding, "chatFontPx": font_size,
    }


def planned_positions(layout, screen, geometry, config):
    r=layout["rects"]
    gx,gy,gw,gh=r["grid2.button"]
    tx,_,_,_=r["target"]
    px,py,_,_=r["player"]
    s=config["totemIcon"]
    gap=config["totemGap"]
    margin=config["totemMargin"]
    width=4*s+3*gap
    new={
        "grid2Party":[gx,gy,gw,5*gh+4*config["gridGap"]],
        "targetpet":[tx-8-config["petWidth"],config["petY"],config["petWidth"],config["petHeight"]],
        "shamanTotems":[px-margin-width,py-margin,width,s],
    }
    other={name: rect for name,rect in r.items() if not name.startswith(("party","grid2."))}
    other.update({f"ui.{k}":v for k,v in layout["interfaceDraft"].items() if isinstance(v,list) and len(v)==4})
    other.update({k:size(box) for k,box in geometry.items() if k not in ("unitUpper","unitLower")})
    for label,rect in new.items():
        x,y,w,h=rect
        assert 0<=x<x+w<=screen[0] and 0<=y<y+h<=screen[1], (label,rect)
        assert not any(overlaps(rect,other_rect) for other_rect in other.values()), (label,rect)
        assert not any(overlaps(rect,other_rect) for name,other_rect in new.items() if name!=label), label
    return dict(new, grid2Button=[gw,gh], screen=screen, **config)

def paint_mockup(preset, position, font, output):
    backdrop = image(APPROVED / f"racial-appearance/screens/{preset}-devil.png")
    assert list(backdrop.size)==position["screen"]
    drawing=ImageDraw.Draw(backdrop)
    title_size = {"fhd": 22, "qhd": 26, "uhd": 34}[preset]
    title_top, title_left = 64, 24
    title_width = title_size * 13
    title_bottom = title_top + title_size * 2
    background = backdrop.crop((title_left + title_width, title_top,
                                title_left + 2 * title_width, title_bottom))
    backdrop.paste(background, (title_left, title_top))
    drawing.text((title_left, title_top + title_size // 3), "파티 · 적 소환수 · 토템",
                 font=ImageFont.truetype(str(font), title_size), fill=(238, 240, 240))
    text_font=ImageFont.truetype(str(font),position["gridFont"])
    timer_font=ImageFont.truetype(str(font),position["totemFont"])
    gradient=image(GRID/"gradient32x32.tga")
    unit_texture=image(STATUS_TEXTURE)
    totem_border=image(TOTEM_BORDER)
    w,h=position["grid2Button"]
    x,y,_,_=position["grid2Party"]
    for index,label in enumerate(("탱커","치유","공격 1","공격 2","공격 3")):
        y1=y+index*(h+position["gridGap"])
        active=index!=3
        edge=(89,211,238) if index==2 else ((83,98,104) if active else (74,78,82))
        drawing.rectangle((x,y1,x+w-1,y1+h-1), fill=(14,21,24))
        b=position["gridBorder"] if index==2 else 1
        ink=(83,130,96,255) if active else (57,70,64,255)
        fill=int((w-2*b)*(0.76,0.98,0.52,0.63,0.88)[index])
        backdrop.alpha_composite(tint(gradient,fill,h-2*b,ink),(x+b,y1+b))
        if index==2:
            ahead=min(w-fill-2*b,int(w*.26))
            backdrop.alpha_composite(tint(gradient,ahead,h-2*b,(139,210,153,255)),(x+b+fill,y1+b))
        drawing.rectangle((x,y1,x+w-1,y1+h-1),outline=edge,width=b)
        label=label+(" · 거리 밖" if not active else "")
        drawing.text((x+6,y1+h//2),label,font=text_font,fill=(200,208,203) if not active else (248,250,247),stroke_width=1,stroke_fill=(11,17,17),anchor="lm")
    x,y,w,h=position["targetpet"]
    drawing.rectangle((x,y,x+w-1,y+h-1),fill=(18,18,19),outline=(104,95,92))
    backdrop.alpha_composite(tint(unit_texture,(w-2)*3//4,h-4,(145,51,43,255)),(x+1,y+2))
    drawing.text((x+6,y+h//2),"적 소환수",font=text_font,fill=(255,240,231),stroke_width=1,stroke_fill=(17,12,11),anchor="lm")
    x,y,_,_=position["shamanTotems"]
    s,g=position["totemIcon"],position["totemGap"]
    for i,timer in enumerate(("18","9","25",None)):
        left=x+i*(s+g)
        drawing.rectangle((left,y,left+s-1,y+s-1),fill=(36,38,39) if timer else (19,22,24))
        if timer:
            backdrop.alpha_composite(tint(unit_texture,s-2,s-2,(56,65,60,255)),(left+1,y+1))
        backdrop.alpha_composite(totem_border.resize((s,s),Image.Resampling.BILINEAR),(left,y))
        if timer:
            drawing.text((left+s//2,y+s-2),timer,font=timer_font,fill=(238,245,235),stroke_width=1,stroke_fill=(9,12,11),anchor="mb")
    backdrop.convert("RGB").save(output / (preset+"-party-targetpet-totems.png"),optimize=True)

def compare_split(geometry, preset, theme, width):
    source=APPEARANCE/"Themes"/theme/"Composition"
    aux, chat, status=geometry["aux"],geometry["chat1"],geometry["status"]
    top=aux[1]-(aux[3]-aux[1])//4
    deck_file=source/f"{preset}_deck_reviewed.tga"
    if not deck_file.is_file():
        deck_file=source/f"{preset}_deck.tga"
    surfaces=[
        (source/f"{preset}_top.tga",chat[1]-top,[0,geometry["upper"][0],geometry["upper"][2],width]),
        (deck_file,status[3]-chat[1],[0,geometry["chat2"][0],geometry["action"][0],
                                    geometry["minimap"][0],geometry["chat3"][0],width]),
    ]
    record=[]
    for path,height,bounds in surfaces:
        combined=image(path).resize((width,height),Image.Resampling.BILINEAR)
        joined=Image.new("RGBA",combined.size)
        for left,right in zip(bounds,bounds[1:]):
            tile=combined.crop((left,0,right,height))
            joined.alpha_composite(tile,(left,0))
        difference=ImageChops.difference(combined,joined)
        extrema=difference.getextrema()
        # Alpha blending can alter RGB underneath zero-alpha pixels. Compare the pixels that draw,
        # and confirm exact raw channels with the same non-overlapping writes when needed.
        physical=Image.new("RGBA",combined.size)
        for left,right in zip(bounds,bounds[1:]):
            physical.paste(combined.crop((left,0,right,height)),(left,0))
        assert combined.tobytes()==physical.tobytes(), path
        assert extrema[3]==(0,0), path
        for bg in ((18,19,21,255),(217,225,235,255)):
            old=Image.alpha_composite(Image.new("RGBA",combined.size,bg),combined)
            new=Image.alpha_composite(Image.new("RGBA",joined.size,bg),joined)
            assert old.tobytes()==new.tobytes(), path
        record.append({"source":path.relative_to(ROOT).as_posix(),"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),
                       "physicalSize":[width,height],"xBoundaries":bounds,"changedPixels":0})
    return record

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--font",type=Path,required=True,help="Path to a Korean font for example labels.")
    parser.add_argument("--output",type=Path,required=True,help="A new output directory.")
    args=parser.parse_args()
    args.output.mkdir(parents=True,exist_ok=False)
    geometry=load_json(APPROVED/"geometry-checks.json")
    placements=load_json(APPROVED/"feature-positions.json")["layouts"]
    position_report={}
    pieces={}
    for preset in PRESETS:
        screen=geometry[preset]["canvas"]
        g=geometry[preset]["rectangles"]
        position_report[preset] = planned_positions(placements[preset], screen, g, P[preset])
        position_report[preset]["stackRules"] = stack_rules(preset, screen, g)
        paint_mockup(preset,position_report[preset],args.font,args.output)
        pieces[preset]={theme:compare_split(g,preset,theme,screen[0]) for theme in THEMES}
    save_json(args.output/"positions.json",{"base":"477eb06","space":"physical-pixels-top-left","liveVerified":False,"layouts":position_report})
    save_json(args.output/"piece-comparison.json",{"mode":"fixed approved physical size; disjoint independent pieces", "themes":13,"presets":3,"inGameMeasured":False,"results":pieces})
    print("PASS 9 proposed frame groups on 3 approved canvases, no modeled overlaps")
    print("PASS bottom-up stacking and slot widths reproduce 3 approved canvases")
    print("PASS 39 themes and presets: 78 assembled surfaces, changed visible pixels 0")

if __name__=="__main__":
    main()

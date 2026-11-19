"""Pack the sourced Warcraft emblems without redrawing them."""

import argparse
from hashlib import md5, sha256
import json
from pathlib import Path

from PIL import Image, ImageOps


NAMES = {
    "alliance": "Alliance_Crest.png",
    "horde": "Horde_Crest.png",
    "human": "Human_Crest.png",
    "dwarf": "Dwarf_Crest.png",
    "gnome": "Gnome_Crest.png",
    "nightelf": "Night_Elf_Crest.png",
    "orc": "Orc_Crest.png",
    "tauren": "Tauren_Crest.png",
    "troll": "Troll_Crest.png",
    "undead": "Forsaken_Crest.png",
    "skyborne": "skyborne-pins.jpg",
}
SKYBORNE_URL = "https://gear.blizzard.com/cdn/shop/files/wow-horizontal-panel-2_1.jpg?v=1789235696&width=1946"


def source_url(name):
    if name == NAMES["skyborne"]:
        return SKYBORNE_URL
    digest = md5(name.encode("utf-8")).hexdigest()
    return f"https://warcraft.wiki.gg/images/{digest[0]}/{digest[:2]}/{name}"


def skyborne_crest(source):
    # Separate the blue Skyborne pin at lower left from its parchment backing.
    # The Warcraft compass is the other pin in the official product photograph.
    if source.size != (1500, 1500):
        raise ValueError(f"Unexpected Skyborne reference size: {source.size}")
    crop = source.convert("RGB").crop((130, 455, 825, 1420))
    mask = Image.new("L", crop.size)
    opacity = []
    for red, _, blue in crop.get_flattened_data():
        opacity.append(max(0, min(255, (blue - red + 16) * 14)))
    mask.putdata(opacity)
    crop.putalpha(mask)
    return crop


def emblem(source):
    sample = source.convert("RGBA")
    coverage = sample.getchannel("A").getbbox()
    if coverage is None:
        raise ValueError("Empty crest")
    isolated = ImageOps.contain(sample.crop(coverage), (252, 252), Image.Resampling.LANCZOS)
    output = Image.new("RGBA", (256, 256))
    output.paste(isolated, ((256 - isolated.width) // 2, (256 - isolated.height) // 2))
    return output


def file_digest(path):
    return sha256(path.read_bytes()).hexdigest()


def run():
    parser = argparse.ArgumentParser()
    parser.add_argument("sources", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    receipt = {}
    for crest, name in NAMES.items():
        original = args.sources / name
        target = args.output / (crest + ".tga")
        if target.exists():
            raise FileExistsError(target)
        with Image.open(original) as image:
            raster = emblem(skyborne_crest(image) if crest == "skyborne" else image)
            original_size = image.size
        if raster.crop((0, 0, 179, 179)).getchannel("A").getbbox() is None:
            raise ValueError(f"Cropped crest would be blank: {target}")
        raster.save(target)
        receipt[crest] = {"source_url": source_url(name), "original_size": original_size,
                          "source_sha256": file_digest(original), "texture_sha256": file_digest(target)}
        print(crest, original_size, raster.getchannel("A").getbbox())
    (args.output / "original-crests.json").write_text(
        json.dumps(receipt, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    run()

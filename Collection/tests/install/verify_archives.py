"""Check each staged ZIP against its own install manifest and checksums."""

import argparse
import hashlib
import json
from io import BytesIO
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tempfile
import zipfile

from lupa.lua51 import LuaRuntime
from PIL import Image


def verify_theme_assets(archive):
    appearance = "Interface/AddOns/DevilForever_Appearance/"
    names = set(archive.namelist())
    themes = ("devil", "horde", "alliance")
    actual = {name for name in names if name.startswith(appearance + "Themes/") and name.endswith(".lua")}
    assert actual == {appearance + f"Themes/{theme}.lua" for theme in themes}, actual
    toc = archive.read(appearance + "DevilForever_Appearance.toc").decode("utf-8-sig")
    loaded = [line.replace("\\", "/") for line in toc.splitlines() if line.startswith("Themes")]
    assert loaded == [f"Themes/{theme}.lua" for theme in themes], loaded
    schema = archive.read("Interface/AddOns/!DevilForever_Core/Theme.lua").decode("utf-8-sig")
    kinds = dict(re.findall(r'^\s*\["([^"\n]+)"\]\s*=\s*"(color|texture|font|size|number)"', schema, re.MULTILINE))
    assert len(kinds) == 20
    runtime = LuaRuntime()
    runtime.execute('STANDARD_TEXT_FONT="Fonts\\\\2002.TTF";UNIT_NAME_FONT="Fonts\\\\2002B.TTF"; '
                    'sets={};DevilForever_Core={Theme={RegisterSet=function(self,name,values) '
                    'assert(sets[name]==nil);sets[name]=values end}}')
    caps, surfaces = set(), set()
    for theme in themes:
        runtime.execute(archive.read(appearance + f"Themes/{theme}.lua").decode("utf-8-sig"))
        values = runtime.globals().sets[theme]
        assert values is not None and set(values.keys()) == set(kinds)
        expected = {
            "texture.ornament.left": "left_cap.tga", "texture.ornament.right": "right_cap.tga",
            "texture.panel": "panel.tga", "texture.divider": "divider.tga", "texture.statusbar": "statusbar.tga",
        }
        for token, filename in expected.items():
            member = appearance + f"Themes/{theme}/{filename}"
            assert values[token].replace("\\", "/") == member and member in names, (theme, token, member)
            with Image.open(BytesIO(archive.read(member))) as image:
                assert image.format == "TGA" and image.width > 0 and image.height > 0
                if filename == "statusbar.tga":
                    neutral = image.convert("RGB")
                    red, green, blue = neutral.split()
                    assert red.tobytes() == green.tobytes() == blue.tobytes(), member
            if filename.endswith("_cap.tga"):
                caps.add(member)
            else:
                surfaces.add(member)
    assert len(caps) == 6 and len(surfaces) == 9
    retired = {"demon.tga", "angel.tga", "demon_wing.tga", "angel_wing.tga", "brush_left.tga", "brush_right.tga",
               "stage_left.tga", "stage_right.tga", "stage_panel.tga", "stage_divider.tga", "stage_bar.tga", "paper.tga", "flat_bar.tga"}
    assert not any(appearance + "Media/" + name in names for name in retired)
    assert not any(name.startswith((appearance + "Themes/ink/", appearance + "Themes/stage/")) for name in names)
    return len(caps), len(surfaces)


RACE_SURFACES = ("human", "dwarf", "gnome", "nightelf", "orc", "tauren", "troll", "undead", "skyborne", "skyborne-horde")


SOURCE_ADDONS = Path(__file__).resolve().parents[2] / "AddOns"


def verify_composition_assets(archive, races, reviewed_chat=False, reviewed_only=False):
    """reviewed_only (0.1.5+): a theme with a reviewed deck ships no _deck.tga; the
    comparison uses the source tree's _deck.tga (Collection/AddOns)."""
    root = "Interface/AddOns/DevilForever_Appearance/"
    runtime = LuaRuntime()
    runtime.execute(archive.read(root + "Crests.lua").decode("utf-8-sig"))
    crests = runtime.globals().DevilForever_ChatCrests
    expected = {"horde": "horde", "alliance": "alliance", "human": "alliance", "dwarf": "alliance",
                "gnome": "alliance", "nightelf": "alliance", "orc": "horde", "tauren": "horde",
                "troll": "horde", "undead": "horde", "skyborne": "alliance", "skyborne-horde": "horde"}
    assert set(crests.keys()) == set(expected) and crests["devil"] is None
    assert crests["skyborne"].texture == crests["skyborne-horde"].texture
    unique_paths = set()
    for id, crest in crests.items():
        assert crest.family == expected[id]
        path = crest.texture.replace("\\", "/")
        filename = "skyborne" if id == "skyborne-horde" else id
        assert path == root + f"Themes/Crests/{filename}.tga"
        if id in RACE_SURFACES:
            assert crest.composition.replace("\\", "/") == root + f"Themes/{id}/Composition/"
            assert crest.petEdge.replace("\\", "/") == root + f"Themes/{id}/PetEdge.tga"
        unique_paths.add(path)
        with Image.open(BytesIO(archive.read(path))) as image:
            assert image.format == "TGA" and image.width > 0 and image.height > 0
    assert len(unique_paths) == 11
    variants = ("devil", "horde", "alliance", *races)
    paths = set(archive.namelist())
    actual = {name.removeprefix(root + "Themes/").split("/")[0] for name in paths
              if name.startswith(root + "Themes/") and "/Composition/" in name}
    assert actual == set(variants), actual
    for variant in variants:
        path = root + f"Themes/{variant}/PetEdge.tga"
        with Image.open(BytesIO(archive.read(path))) as image:
            alpha = image.convert("RGBA").getchannel("A")
            assert image.size == (64, 64) and alpha.getbbox() and not alpha.crop((5, 5, 59, 59)).getbbox(), path
    count = 0
    reviewed_paths = set()
    for preset in ("fhd", "qhd", "uhd"):
        source = archive.read(f"Interface/AddOns/!DevilForever_Core/Presets/{preset}.lua").decode("utf-8-sig")
        marker = "\ndef.fragments = {}"
        assert source.count(marker) == 1
        definition = runtime.execute(source.split(marker, 1)[0] + "\nreturn def")
        edits = definition.edits
        aux, chat, right, status = (edits["appearance." + key] for key in ("aux", "chat1", "chat3", "status"))
        top = -aux.position.y - aux.size.height // 4
        split = -chat.position.y
        bottom = -status.position.y + status.size.height
        width = right.position.x + right.size.width
        for family in variants:
            for suffix, height in (("top", split - top), ("deck", bottom - split)):
                path = root + f"Themes/{family}/Composition/{preset}_{suffix}.tga"
                replaced = reviewed_only and suffix == "deck" and family != "devil"
                if replaced:
                    assert path not in paths, path
                    data = (SOURCE_ADDONS / path.removeprefix("Interface/AddOns/")).read_bytes()
                else:
                    data = archive.read(path)
                with Image.open(BytesIO(data)) as image:
                    storage = (2048, 256) if suffix == "top" else (2048, 512)
                    assert image.format == "TGA" and image.size == storage, (path, image.size, storage)
                    assert width > 0 and height > 0
                    if suffix == "deck":
                        alpha = image.convert("RGBA").getchannel("A")
                        for panel in (chat, edits["appearance.chat2"], right):
                            x = round((panel.position.x + panel.size.width / 2) * image.width / width)
                            y = round(panel.size.height / 2 * image.height / height)
                            assert 186 <= alpha.getpixel((x, y)) <= 208, (path, x, y)
                        if reviewed_chat and family != "devil":
                            reviewed = path.removesuffix(".tga") + "_reviewed.tga"
                            reviewed_paths.add(reviewed)
                            with Image.open(BytesIO(archive.read(reviewed))) as new:
                                assert new.format == "TGA" and new.size == storage, reviewed
                                previous, revised = image.convert("RGBA"), new.convert("RGBA")
                                middle = edits["appearance.chat2"]
                                center_left = round((middle.position.x + middle.size.width) * image.width / width) + 2
                                center_right = round(right.position.x * image.width / width) - 2
                                center = (center_left, 0, center_right, image.height)
                                assert previous.crop(center).tobytes() == revised.crop(center).tobytes(), reviewed
                                assert previous.tobytes() != revised.tobytes(), reviewed
                count += 1
    toc = archive.read(root + "DevilForever_Appearance.toc").decode("utf-8-sig")
    lines = toc.splitlines()
    assert lines.index("Crests.lua") < lines.index("Composition.lua") < lines.index("Appearance.lua")
    assert count == 6 * len(variants)
    if reviewed_chat:
        assert {path for path in paths if path.endswith("_deck_reviewed.tga")} == reviewed_paths
        assert len(reviewed_paths) == 3 * len(expected)
    return count, len(list(crests.keys()))


def verify(path, variant, races, version, reviewed_chat):
    prefix = "DevilForever-install/"
    addons = "Interface/AddOns/"
    with zipfile.ZipFile(path) as archive:
        names = [entry.filename for entry in archive.infolist() if not entry.is_dir()]
        assert len(names) == len(set(name.casefold() for name in names))
        assert archive.testzip() is None
        for name in names:
            member = PurePosixPath(name)
            assert not member.is_absolute() and ".." not in member.parts and "\\" not in name
            assert name.startswith((prefix, addons)), name
        installed = {name.removeprefix(addons).split("/", 1)[0] for name in names if name.startswith(addons)}
        must_ship = {"!DevilForever_Core", "DevilForever_Appearance", "DevilForever_Skin_StatusStrip",
                     "Dominos", "DevilForever_ChatSetup", "DevilForever_Skin_NativeChat", "Chattynator",
                     "SexyMap", "Quartz", "Grid2", "Details",
                     "Details_TinyThreat", "DevilForever_DetailsLayout", "ExperienceForever"}
        assert must_ship.issubset(installed), must_ship - installed
        assert {"Aurora", "KalielsTracker", "!KalielsTracker", "Mapster", "TipTac",
                "Prat-3.0", "DevilForever_Skin_Prat", "Hekili", "Hekili_Shared", "Hekili_Shaman"}.isdisjoint(installed)
        expected = {"pitbull4": (True, False), "fuf": (False, True), "one-session": (True, True)}
        assert ("PitBull4" in installed, "ForeverUnitFrames" in installed) == expected[variant]
        assert not any("/Tests/" in name or name.endswith(".pyc") for name in names)
        manifest = json.loads(archive.read(prefix + "manifest.json"))
        assert manifest["version"] == version, manifest.get("version")
        assert manifest["unit_frames"] == variant, manifest.get("unit_frames")
        if variant == "one-session":
            assert not manifest["review"]["simultaneous"]
            guide = archive.read(prefix + "설치안내.md").decode("utf-8")
            assert "PitBull4만 켜고" in guide and "/dfcheck comparison" in guide
        assert verify_theme_assets(archive) == (6, 9)
        assert verify_composition_assets(archive, races, reviewed_chat,
                                         version_at_least(version, (0, 1, 5))) == (6 * (3 + len(races)), 12)
        dev_only = {"Interface/AddOns/DevilForever_Skin_Nameplates/SessionProbe.lua",
                    "Interface/AddOns/DevilForever_Skin_Nameplates/Probe.lua",
                    "Interface/AddOns/!DevilForever_Core/registry_extra.json"}
        if version_at_least(version, (0, 1, 5)):
            assert dev_only.isdisjoint(names), dev_only & set(names)
        else:
            assert "Interface/AddOns/DevilForever_Skin_Nameplates/SessionProbe.lua" in names
        assert {entry["folder"] for entry in manifest["folders"]} == installed
        checksums = archive.read(prefix + "SHA256SUMS.txt").decode("utf-8").splitlines()
        checked = set()
        for line in checksums:
            digest, member = line.split("  ", 1)
            assert member not in checked
            assert hashlib.sha256(archive.read(member)).hexdigest() == digest, member
            checked.add(member)
        assert checked == set(names) - {prefix + "SHA256SUMS.txt"}
        root = Path(tempfile.mkdtemp(prefix=f"verify-{variant}-", dir=path.parent.parent))
        archive.extractall(root)
    workspace = Path(__file__).resolve().parents[3]
    collection = workspace / "Collection" / "tools"
    addon_root = root / "Interface" / "AddOns"
    for check in ("luacheck.py", "tocdeps.py"):
        proc = subprocess.run([sys.executable, "-I", str(collection / check), str(addon_root)],
                              cwd=workspace, capture_output=True, encoding="utf-8", errors="replace")
        assert proc.returncode == 0, proc.stdout + proc.stderr
        print(variant, proc.stdout.splitlines()[-1])
    with path.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    print(f"{variant} folders={len(installed)} files={len(names)} internal_hashes={len(checked)} sha256={digest}")


def version_at_least(version, minimum):
    return tuple(int(part) for part in version.split(".")[:3]) >= minimum


def verify_variant_payloads(primary, alternate, comparison):
    def verify_members(archive):
        rows = archive.read("DevilForever-install/SHA256SUMS.txt").decode("utf-8").splitlines()
        pairs = (row.split("  ", 1) for row in rows)
        return {member: digest for digest, member in pairs if member.startswith("Interface/AddOns/")}

    with zipfile.ZipFile(primary) as a, zipfile.ZipFile(alternate) as b, zipfile.ZipFile(comparison) as c:
        default, fuf, both = map(verify_members, (a, b, c))
        assert all(default[member] == fuf[member] for member in default.keys() & fuf.keys())
        assert default | fuf == both


def verify_shared_payload(primary, alternate):
    """The two release ZIPs carry the same bytes for every addon file they share."""
    with zipfile.ZipFile(primary) as a, zipfile.ZipFile(alternate) as b:
        rows = [dict((m, d) for d, m in (r.split("  ", 1) for r in z.read("DevilForever-install/SHA256SUMS.txt")
                                         .decode("utf-8").splitlines()) if m.startswith("Interface/AddOns/"))
                for z in (a, b)]
    assert all(rows[0][m] == rows[1][m] for m in rows[0].keys() & rows[1].keys())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("zip_directory", type=Path)
    parser.add_argument("--version", default="0.1.0")
    parser.add_argument("--reviewed-chat", action="store_true")
    args = parser.parse_args()
    zip_dir = args.zip_directory.resolve()
    prefix = f"DevilForever-{args.version}"
    primary = zip_dir / f"{prefix}.zip"
    alternate = zip_dir / f"{prefix}-fuf.zip"
    comparison = zip_dir / f"{prefix}-one-session.zip"
    verify(primary, "pitbull4", RACE_SURFACES, args.version, args.reviewed_chat)
    verify(alternate, "fuf", RACE_SURFACES, args.version, args.reviewed_chat)
    if comparison.exists() or not version_at_least(args.version, (0, 1, 5)):
        verify(comparison, "one-session", RACE_SURFACES, args.version, args.reviewed_chat)
        verify_variant_payloads(primary, alternate, comparison)
    else:
        print("one-session: not built for %s (optional from 0.1.5)" % args.version)
        verify_shared_payload(primary, alternate)


if __name__ == "__main__":
    main()

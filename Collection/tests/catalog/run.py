"""Tests of Collection/tools/catalog.py (installer catalog generated from the release ZIPs).

Usage:  python3 -I Collection/tests/catalog/run.py

Small ZIPs in the release layout (DevilForever-install/manifest.json and
Interface/AddOns/<folder>/...) are written to a temporary folder; the tool runs
as a command. ``--write`` then ``--check`` match; a ZIP whose member bytes were
changed after the catalog was written, a ZIP with one more file, and a third
(comparison) ZIP given in place of a release ZIP no longer match. The
installer's own refusal of such ZIPs is C# (Collection/Installer) and needs
dotnet, which this check does not run. The last case compares
Collection/Installer/ReleaseCatalog.json with outputs/collection/DevilForever-
<version>.zip and -fuf.zip when both exist (install.json version); it is
reported as SKIP otherwise.
"""

import json
import os
import subprocess
import sys
import tempfile
import traceback
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
TOOL = os.path.join(REPO, "Collection", "tools", "catalog.py")


def make_zip(path, variant, files):
    folders = sorted({name.split("/", 1)[0] for name in files})
    manifest = {"schema": "devil-forever-install-manifest/1", "name": "DevilForever", "version": "9.9.9",
                "interface": 16001, "unit_frames": variant, "folders": [{"folder": f} for f in folders]}
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("Interface/", b"")
        zf.writestr("Interface/AddOns/", b"")
        for name, data in sorted(files.items()):
            zf.writestr("Interface/AddOns/" + name, data)
        zf.writestr("DevilForever-install/manifest.json", json.dumps(manifest))


def tool(*args):
    proc = subprocess.run([sys.executable, "-I", TOOL] + list(args), capture_output=True, text=True)
    return proc.returncode, proc.stdout + proc.stderr


BASE = {"A/A.toc": b"## Interface: 16001\n", "A/a.lua": b"print(1)\n", "B/b.lua": b"x" * 100}
FUF = {"A/A.toc": b"## Interface: 16001\n", "A/a.lua": b"print(1)\n", "C/c.lua": b"y" * 10}

CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


class Skip(Exception):
    pass


def release_pair(tmp):
    a, b = os.path.join(tmp, "R-9.9.9.zip"), os.path.join(tmp, "R-9.9.9-fuf.zip")
    make_zip(a, "pitbull4", BASE)
    make_zip(b, "fuf", FUF)
    return a, b


@case
def write_then_check_matches():
    with tempfile.TemporaryDirectory(prefix="cat.") as tmp:
        a, b = release_pair(tmp)
        cat = os.path.join(tmp, "ReleaseCatalog.json")
        eq(tool(a, b, "--write", cat)[0], 0, "write")
        data = json.load(open(cat, encoding="utf-8"))
        eq((data["interface"], data["defaultVariant"], [p["variant"] for p in data["packages"]]),
           (16001, "pitbull4", ["pitbull4", "fuf"]), "catalog head")
        p = data["packages"][0]
        eq((p["zip"], p["zipBytes"], p["addonFiles"], p["addonBytes"], p["folders"]),
           ("R-9.9.9.zip", os.path.getsize(a), 3, sum(len(v) for v in BASE.values()), ["A", "B"]), "pitbull4 row")
        eq(tool(a, b, "--check", cat)[0], 0, "check right after write")


@case
def modified_zip_no_longer_matches():
    with tempfile.TemporaryDirectory(prefix="cat.") as tmp:
        a, b = release_pair(tmp)
        cat = os.path.join(tmp, "ReleaseCatalog.json")
        tool(a, b, "--write", cat)
        changed = dict(BASE, **{"A/a.lua": b"print(2)\n"})
        make_zip(a, "pitbull4", changed)
        rc, out = tool(a, b, "--check", cat)
        eq((rc, "DIFFERS" in out), (1, True), "same names and sizes, one member changed")
        make_zip(a, "pitbull4", dict(BASE, **{"B/extra.lua": b"z"}))
        eq(tool(a, b, "--check", cat)[0], 1, "one more file")
        make_zip(a, "pitbull4", BASE)
        eq(tool(a, b, "--check", cat)[0], 0, "rebuilt from the same inputs matches again")


@case
def comparison_zip_in_place_of_release_does_not_match():
    with tempfile.TemporaryDirectory(prefix="cat.") as tmp:
        a, b = release_pair(tmp)
        cat = os.path.join(tmp, "ReleaseCatalog.json")
        tool(a, b, "--write", cat)
        c = os.path.join(tmp, "R-9.9.9-one-session.zip")
        make_zip(c, "one-session", dict(BASE, **FUF))
        eq(tool(a, c, "--check", cat)[0], 1, "one-session ZIP is not the fuf row")


@case
def repository_catalog_matches_built_zips():
    with open(os.path.join(REPO, "Collection", "install.json"), encoding="utf-8") as fh:
        version = json.load(fh)["version"]
    out = os.path.join(REPO, "outputs", "collection")
    zips = [os.path.join(out, "DevilForever-%s.zip" % version), os.path.join(out, "DevilForever-%s-fuf.zip" % version)]
    if not all(os.path.isfile(z) for z in zips):
        raise Skip("built ZIPs for %s not in outputs/collection" % version)
    rc, text = tool(*(zips + ["--check"]))
    eq(rc, 0, "Collection/Installer/ReleaseCatalog.json from the built ZIPs (%s)" % text.strip())


def main():
    passed, failed, skipped = 0, [], 0
    for fn in CASES:
        try:
            fn()
            passed += 1
            print("PASS %s" % fn.__name__)
        except Skip as exc:
            skipped += 1
            print("SKIP %s: %s" % (fn.__name__, exc))
        except Exception:  # noqa: BLE001 - report every failing case
            failed.append(fn.__name__)
            print("FAIL %s" % fn.__name__)
            traceback.print_exc(limit=4)
    print("cases=%d passed=%d failed=%d skipped=%d" % (len(CASES), passed, len(failed), skipped))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

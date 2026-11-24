"""Tests of Collection/tools/patches.py (originals, patches, version-up path).

Usage:  python3 -I Collection/tests/patches/run.py

One case runs ``verify`` on the repository (extracted originals under
Collection/upstream, shipped folders under Collection/AddOns, the patches
under Collection/patches). The other cases build a small fake repository in a
temporary folder (an upstream package with two addon folders, one shipped
unmodified and one patched with a changed CRLF file, an added and a removed
file) and point the tool's REPO/ADDONS there: regenerate writes a patch that
verify accepts and that a second regenerate leaves unchanged; a changed
shipped file, a hand-edited patch body or a changed unmodified folder fail
verify; reapply onto a new upstream with an unrelated change is clean, and
onto a new upstream that changed a patched line reports that one conflict.
Needs GNU diff and patch on PATH.
"""

import json
import os
import sys
import tempfile
import traceback

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(REPO, "Collection", "tools"))
import patches  # noqa: E402

REAL = (patches.REPO, patches.ADDONS)

A_LUA = b"".join(b"line %d\r\n" % i for i in range(1, 41))


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as fh:
        fh.write(data)


def read(path):
    with open(path, "rb") as fh:
        return fh.read()


def fake_repo(root):
    """Fake repository with package Pkg (folders Foo patched, Bar unmodified); returns the manifest."""
    up = os.path.join(root, "Collection", "upstream", "Pkg-1")
    ship = os.path.join(root, "Collection", "AddOns")
    for base in (up, ship):
        write(os.path.join(base, "Foo", "Foo.toc"), b"## Interface: 16001\r\na.lua\r\n")
        write(os.path.join(base, "Bar", "Bar.toc"), b"## Interface: 16001\nbar.lua\n")
        write(os.path.join(base, "Bar", "bar.lua"), b"print(1)\n")
        write(os.path.join(base, "Foo", "a.lua"), A_LUA)
        write(os.path.join(base, "Foo", "media", "tex.tga"), b"\x00\x01binary")
    write(os.path.join(up, "Foo", "gone.lua"), b"old\n")
    write(os.path.join(ship, "Foo", "a.lua"), A_LUA.replace(b"line 5\r\n", b"line 5 changed\r\n"))
    write(os.path.join(ship, "Foo", "new.lua"), b"new file\nno newline at end")
    manifest = {
        "packages": [{"name": "Pkg", "upstream_dir": "Collection/upstream/Pkg-1",
                      "addons": [{"folder": "Foo", "path": "Foo"}, {"folder": "Bar", "path": "Bar"}]}],
        "collection": [],
        "third_party": [
            {"folder": "Bar", "package": "Pkg", "upstream_path": "Collection/upstream/Pkg-1/Bar",
             "state": "unmodified", "patch": None},
            {"folder": "Foo", "package": "Pkg", "upstream_path": "Collection/upstream/Pkg-1/Foo",
             "state": "patched", "patch": "Collection/patches/Pkg.patch"},
        ],
    }
    write(os.path.join(root, "Collection", "manifest.json"), json.dumps(manifest).encode("utf-8"))
    return manifest


def point_at(root):
    patches.REPO = root
    patches.ADDONS = os.path.join(root, "Collection", "AddOns")


def restore():
    patches.REPO, patches.ADDONS = REAL


def run_verify(manifest, names=()):
    lines = []
    rc = patches.verify(manifest, list(names), out=lines.append)
    return rc, lines


CASES = []


def case(fn):
    CASES.append(fn)
    return fn


def eq(actual, expected, what):
    if actual != expected:
        raise AssertionError("%s: expected %r, got %r" % (what, expected, actual))


@case
def repository_patches_verify():
    restore()
    manifest = patches.load_manifest()
    rc, lines = run_verify(manifest)
    eq(rc, 0, "verify on the repository (%s)" % [l for l in lines if l.startswith("FAIL")])
    declared = {t["patch"] for t in manifest["third_party"] if t["state"] == "patched"}
    declared |= {c["base"]["patch"] for c in manifest.get("collection") or [] if c.get("kind") == "fork"}
    eq(sum(1 for l in lines if l.startswith("OK patched")), len(declared),
       "every patch the manifest declares (packages and forks) verified")
    eq(sorted(declared), sorted("Collection/patches/" + n for n in os.listdir(os.path.join(patches.REPO, "Collection", "patches")) if n.endswith(".patch")),
       "no patch file outside the manifest")


@case
def regenerate_then_verify_and_idempotent():
    with tempfile.TemporaryDirectory(prefix="pt.") as root:
        manifest = fake_repo(root)
        point_at(root)
        try:
            eq(patches.regenerate(manifest, []), 0, "regenerate")
            path = os.path.join(root, "Collection", "patches", "Pkg.patch")
            first = read(path)
            eq(first.startswith(b"Pkg for WoW Forever"), True, "default header written")
            eq(b"line 5 changed\r\n" in first, True, "CRLF kept in the hunk")
            eq(b"--- a/Foo/gone.lua\n" in first and b"+++ b/Foo/gone.lua\t1970-01-01" in first, True,
               "removed file: epoch on the absent side")
            eq(b"--- a/Foo/new.lua\t1970-01-01" in first, True, "added file: epoch on the absent side")
            eq(b"Bar/" in first, False, "unmodified folder not in the patch")
            rc, lines = run_verify(manifest)
            eq(rc, 0, "verify after regenerate %s" % lines)
            eq(patches.regenerate(manifest, []), 0, "second regenerate")
            eq(read(path), first, "second regenerate gives the same bytes")
            edited = first.replace(b"Pkg for WoW Forever", b"Pkg - edited header")
            write(path, edited)
            patches.regenerate(manifest, [])
            eq(read(path).startswith(b"Pkg - edited header"), True, "hand-written header kept")
        finally:
            restore()


@case
def verify_fails_on_drift():
    with tempfile.TemporaryDirectory(prefix="pt.") as root:
        manifest = fake_repo(root)
        point_at(root)
        try:
            patches.regenerate(manifest, [])
            path = os.path.join(root, "Collection", "patches", "Pkg.patch")
            good = read(path)
            ship_a = os.path.join(root, "Collection", "AddOns", "Foo", "a.lua")
            write(ship_a, read(ship_a) + b"extra\r\n")
            rc, lines = run_verify(manifest)
            eq((rc, any("body differs" in l for l in lines)), (1, True), "shipped file changed after the patch")
            patches.regenerate(manifest, [])
            write(path, read(path).replace(b"+line 5 changed", b"+line 5 edited"))
            rc, lines = run_verify(manifest)
            eq((rc, any("body differs" in l for l in lines)), (1, True), "patch body edited by hand")
            write(path, good)
            write(ship_a, A_LUA.replace(b"line 5\r\n", b"line 5 changed\r\n"))
            write(os.path.join(root, "Collection", "AddOns", "Bar", "bar.lua"), b"print(2)\n")
            rc, lines = run_verify(manifest)
            eq((rc, any("Bar (Pkg) is not byte-identical" in l for l in lines)), (1, True), "unmodified folder changed")
            write(os.path.join(root, "Collection", "AddOns", "Bar", "bar.lua"), b"print(1)\n")
            os.makedirs(os.path.join(root, "Collection", "AddOns", "Stray"))
            rc, lines = run_verify(manifest)
            eq((rc, any("Stray is neither" in l for l in lines)), (1, True), "folder outside the manifest")
            os.rmdir(os.path.join(root, "Collection", "AddOns", "Stray"))
            write(os.path.join(root, "Collection", "AddOns", "Foo", "media", "tex.tga"), b"\x00\x02binary")
            try:
                patches.regenerate(manifest, [])
            except patches.PatchError as exc:
                eq("not text" in str(exc), True, "binary difference refused")
            else:
                raise AssertionError("binary difference accepted")
        finally:
            restore()


@case
def reapply_clean_and_with_one_conflict():
    with tempfile.TemporaryDirectory(prefix="pt.") as root:
        manifest = fake_repo(root)
        point_at(root)
        try:
            patches.regenerate(manifest, [])
            clean = os.path.join(root, "new-clean")
            write(os.path.join(clean, "Pkg", "Foo", "Foo.toc"), b"## Interface: 16001\r\na.lua\r\n")
            write(os.path.join(clean, "Pkg", "Foo", "a.lua"), A_LUA.replace(b"line 30\r\n", b"line 30 upstream\r\n"))
            write(os.path.join(clean, "Pkg", "Foo", "gone.lua"), b"old\n")
            write(os.path.join(clean, "Pkg", "Foo", "media", "tex.tga"), b"\x00\x01binary")
            out = os.path.join(root, "out-clean")
            eq(patches.reapply(manifest, "Pkg", clean, out), 0, "unrelated upstream change applies cleanly")
            got = read(os.path.join(out, "Foo", "a.lua"))
            eq((b"line 5 changed\r\n" in got, b"line 30 upstream\r\n" in got), (True, True), "both changes kept")
            eq(os.path.exists(os.path.join(out, "Foo", "gone.lua")), False, "removed file removed")
            eq(read(os.path.join(out, "Foo", "new.lua")), b"new file\nno newline at end", "added file created")
            try:
                patches.reapply(manifest, "Pkg", clean, out)
            except patches.PatchError:
                pass
            else:
                raise AssertionError("existing --out accepted")
            conflict = os.path.join(root, "new-conflict")
            write(os.path.join(conflict, "Pkg", "Foo", "Foo.toc"), b"## Interface: 16001\r\na.lua\r\n")
            write(os.path.join(conflict, "Pkg", "Foo", "a.lua"), A_LUA.replace(b"line 5\r\n", b"line 5 upstream\r\n"))
            write(os.path.join(conflict, "Pkg", "Foo", "gone.lua"), b"old\n")
            out2 = os.path.join(root, "out-conflict")
            lines = []
            stdout = sys.stdout
            try:
                class Capture:
                    def write(self, text):
                        lines.append(text)

                    def flush(self):
                        pass
                sys.stdout = Capture()
                rc = patches.reapply(manifest, "Pkg", conflict, out2)
            finally:
                sys.stdout = stdout
            text = "".join(lines)
            eq(rc, 1, "conflict reported by exit code")
            eq(text.count("CONFLICT "), 1, "exactly one conflicting file (%s)" % text)
            eq("CONFLICT Foo/a.lua: 1 hunk(s) failed" in text, True, "the conflicting file is named")
            eq(os.path.isfile(os.path.join(out2, "Foo", "a.lua.rej")), True, "reject file left for the fix")
            eq(read(os.path.join(out2, "Foo", "new.lua")), b"new file\nno newline at end", "other hunks applied")
            missing = os.path.join(root, "new-missing")
            write(os.path.join(missing, "Pkg", "Other", "Other.toc"), b"## Interface: 16001\n")
            eq(patches.reapply(manifest, "Pkg", missing, os.path.join(root, "out-missing")), 1, "folder missing")
        finally:
            restore()


def main():
    passed, failed = 0, []
    for fn in CASES:
        try:
            fn()
            passed += 1
            print("PASS %s" % fn.__name__)
        except Exception:  # noqa: BLE001 - report every failing case
            failed.append(fn.__name__)
            print("FAIL %s" % fn.__name__)
            traceback.print_exc(limit=4)
    print("cases=%d passed=%d failed=%d" % (len(CASES), passed, len(failed)))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())

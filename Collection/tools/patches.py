"""Third-party originals, our patches, and the version-up path.

Usage:
  python3 -I Collection/tools/patches.py verify [--package NAME ...]
  python3 -I Collection/tools/patches.py regenerate [--package NAME ...]
  python3 -I Collection/tools/patches.py reapply --package NAME --upstream DIR --out DIR

Inputs: ``Collection/manifest.json`` (written by extract.py) — section
``third_party`` (shipped third-party folders: state "unmodified" or "patched"
with the package patch) and the ``collection`` forks (kind "fork", base patch);
the extracted originals under ``Collection/upstream/`` (extract.py); the shipped
folders under ``Collection/AddOns/``.

verify      every folder of Collection/AddOns is ours (manifest collection) or a
            third-party folder of the manifest; each unmodified folder has the
            same file list and bytes as its upstream folder; each patch file's
            body equals the diff regenerated now (upstream -> shipped), names
            only its package's declared folders, is not empty, and applied with
            ``patch`` to a copy of the upstream folders gives the shipped folders
            byte for byte. Exit 1 on any failure.
regenerate  rewrites each patch body from upstream -> shipped and keeps the
            hand-written header (text before the first ``diff `` line; a short
            header is written for a new file).
reapply     version-up: copies the patch's folders from DIR (a new upstream
            package root, searched for addon folders by name) into the new
            directory ``--out``, applies the patch there and lists every file
            whose hunks failed (``.rej`` files are left next to them). Exit 1
            when a hunk fails or a folder is missing in DIR.

Patch body format: one ``diff -u`` block per changed file, sorted by path,
labels ``a/<Folder>/<path>`` and ``b/<Folder>/<path>`` without timestamps; an
absent side carries the epoch timestamp so ``patch`` creates or removes the
file. Bytes are kept as they are (CRLF stays in the hunks). Apply from the
folder that holds the addon folders: ``patch -p1 --binary -E < X.patch``.
A file that differs and is not text (``diff`` reports binary) stops the tool.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import toclib  # noqa: E402

ADDONS = os.path.join(REPO, "Collection", "AddOns")
MANIFEST = os.path.join(REPO, "Collection", "manifest.json")
MARKER = ".extract-source.json"
EPOCH = "\t1970-01-01 00:00:00.000000000 +0000"
BODY_RE = re.compile(rb"^diff ", re.M)
TARGET_RE = re.compile(rb"^diff -u a/([^/\n]+)/", re.M)
FAILED_RE = re.compile(r"^Hunk #\d+ FAILED", re.M)
PATCHING_RE = re.compile(r"^(?:patching|checking) file (.+)$", re.M)
ENV = dict(os.environ, LC_ALL="C")


class PatchError(Exception):
    pass


def load_manifest(path=MANIFEST):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def units(manifest, root=None):
    """{patch path: {"package", "folders": [(folder, upstream dir, shipped dir)]}} and the unmodified list."""
    root = root or REPO
    packages = {p["name"]: p for p in manifest["packages"]}
    out = {}
    unmodified = []
    for item in manifest.get("third_party") or []:
        entry = (item["folder"], os.path.join(root, item["upstream_path"]), os.path.join(root, "Collection", "AddOns",
                                                                                     item["folder"]))
        if item["state"] == "patched":
            unit = out.setdefault(item["patch"], {"package": item["package"], "folders": []})
            unit["folders"].append(entry)
        elif item["state"] == "unmodified":
            unmodified.append((item["package"],) + entry)
        else:
            raise PatchError("manifest third_party %s: unknown state %r" % (item["folder"], item["state"]))
    for item in manifest.get("collection") or []:
        if item.get("kind") != "fork":
            continue
        base = item["base"]
        pkg = packages.get(base["package"])
        addon = next((a for a in (pkg or {}).get("addons") or [] if a["folder"] == item["folder"]), None)
        if pkg is None or addon is None or not pkg.get("upstream_dir"):
            raise PatchError("fork %s: base package %s has no extracted folder %s" % (
                item["folder"], base["package"], item["folder"]))
        unit = out.setdefault(base["patch"], {"package": base["package"], "folders": []})
        unit["folders"].append((item["folder"], os.path.join(root, pkg["upstream_dir"], addon["path"]),
                                os.path.join(root, "Collection", "AddOns", item["folder"])))
    for unit in out.values():
        unit["folders"].sort(key=lambda f: f[0].lower())
    unmodified.sort(key=lambda f: f[1].lower())
    return out, unmodified


def tree_files(folder):
    """{relative path with "/": absolute path} of the regular files under ``folder``."""
    found = {}
    for dirpath, dirnames, filenames in os.walk(folder):
        dirnames.sort()
        for name in list(dirnames):
            if os.path.islink(os.path.join(dirpath, name)):
                raise PatchError("symlink: %s" % os.path.join(dirpath, name))
        for name in filenames:
            full = os.path.join(dirpath, name)
            if os.path.islink(full):
                raise PatchError("symlink: %s" % full)
            rel = os.path.relpath(full, folder).replace(os.sep, "/")
            if rel == MARKER:
                continue
            found[rel] = full
    return found


def read_bytes(path):
    with open(path, "rb") as fh:
        return fh.read()


def compare_trees(left, right):
    """(only in left, only in right, different) relative paths, each sorted."""
    a, b = tree_files(left), tree_files(right)
    differ = sorted(k for k in set(a) & set(b) if read_bytes(a[k]) != read_bytes(b[k]))
    return sorted(set(a) - set(b)), sorted(set(b) - set(a)), differ


def file_diff(folder, rel, old, new):
    """``diff -u`` block (bytes) for one file; ``old``/``new`` None when that side is absent."""
    label_a = "a/%s/%s" % (folder, rel) + ("" if old else EPOCH)
    label_b = "b/%s/%s" % (folder, rel) + ("" if new else EPOCH)
    cmd = ["diff", "-u", "--label", label_a, "--label", label_b, old or os.devnull, new or os.devnull]
    proc = subprocess.run(cmd, capture_output=True, env=ENV)
    if proc.returncode == 0:
        return b""
    if proc.returncode != 1:
        raise PatchError("diff failed for %s/%s: %s" % (folder, rel, proc.stderr.decode("utf-8", "replace")))
    if proc.stdout.startswith(b"Binary files ") or not proc.stdout.startswith(b"--- "):
        raise PatchError("%s/%s differs and is not text; a patch cannot carry it" % (folder, rel))
    return ("diff -u a/%s/%s b/%s/%s\n" % (folder, rel, folder, rel)).encode("utf-8") + proc.stdout


def patch_body(folders):
    chunks = []
    for folder, upstream, shipped in folders:
        if not os.path.isdir(upstream):
            raise PatchError("upstream folder missing, run extract.py: %s" % os.path.relpath(upstream, REPO))
        a, b = tree_files(upstream), tree_files(shipped)
        for rel in sorted(set(a) | set(b)):
            if rel in a and rel in b and read_bytes(a[rel]) == read_bytes(b[rel]):
                continue
            chunks.append(file_diff(folder, rel, a.get(rel), b.get(rel)))
    return b"".join(chunks)


def split_patch(data):
    match = BODY_RE.search(data)
    if match is None:
        return data, b""
    return data[:match.start()], data[match.start():]


def default_header(package, folders):
    names = ", ".join(f[0] for f in folders)
    return ("%s for WoW Forever (TOC Interface 16001) - DevilForever patch\n"
            "Folders: %s (upstream: Collection/upstream, shipped: Collection/AddOns).\n"
            "Apply from the folder that holds the addon folders:\n"
            "    patch -p1 --binary -E < %s\n"
            "Generated with: python3 -I Collection/tools/patches.py regenerate\n\n"
            % (package, names, "%s.patch" % package.replace(" ", "_"))).encode("utf-8")


def apply_patch(patch_file, cwd):
    """Run ``patch`` in ``cwd``; returns (ok, {file: failed hunks}, output text)."""
    proc = subprocess.run(["patch", "-p1", "--binary", "--batch", "--forward", "-E", "--no-backup-if-mismatch",
                           "-i", patch_file], cwd=cwd, capture_output=True, env=ENV)
    text = (proc.stdout + proc.stderr).decode("utf-8", "replace")
    failed = {}
    current = None
    for line in text.splitlines():
        m = PATCHING_RE.match(line)
        if m:
            current = m.group(1).strip().strip("'")
            continue
        if FAILED_RE.match(line) or "Reversed (or previously applied) patch detected" in line:
            failed[current] = failed.get(current, 0) + 1
    return proc.returncode == 0 and not failed, failed, text


def selected(all_units, names):
    if not names:
        return sorted(all_units.items())
    wanted = {n.lower() for n in names}
    picked = [(p, u) for p, u in sorted(all_units.items()) if u["package"].lower() in wanted]
    missing = wanted - {u["package"].lower() for _p, u in picked}
    if missing:
        raise PatchError("no patch for package %s" % ", ".join(sorted(missing)))
    return picked


def verify(manifest, names, tmp_root=None, out=print):
    all_units, unmodified = units(manifest)
    failures = []
    known = {c["folder"] for c in manifest.get("collection") or []}
    known.update(t["folder"] for t in manifest.get("third_party") or [])
    if not names:
        for name in sorted(os.listdir(ADDONS)):
            if os.path.isdir(os.path.join(ADDONS, name)) and name not in known:
                failures.append("Collection/AddOns/%s is neither ours nor a manifest third-party folder" % name)
        for package, folder, upstream, shipped in unmodified:
            if not os.path.isdir(upstream):
                failures.append("%s: upstream folder missing, run extract.py" % folder)
                continue
            only_up, only_ship, differ = compare_trees(upstream, shipped)
            if only_up or only_ship or differ:
                failures.append("%s (%s) is not byte-identical to upstream: missing %s, added %s, changed %s" % (
                    folder, package, only_up[:5], only_ship[:5], differ[:5]))
            else:
                out("OK unmodified %-22s %s" % (folder, package))
    for patch, unit in selected(all_units, names):
        path = os.path.join(REPO, patch)
        if not os.path.isfile(path):
            failures.append("%s: patch file missing" % patch)
            continue
        _header, body = split_patch(read_bytes(path))
        declared = {f[0] for f in unit["folders"]}
        named = {m.decode("utf-8") for m in TARGET_RE.findall(body)}
        if named - declared:
            failures.append("%s names folders outside its declaration: %s" % (patch, sorted(named - declared)))
        fresh = patch_body(unit["folders"])
        if not fresh:
            failures.append("%s: declared patched, but the shipped folders equal upstream" % patch)
            continue
        if body != fresh:
            failures.append("%s: body differs from the regenerated diff (run regenerate)" % patch)
            continue
        with tempfile.TemporaryDirectory(prefix="dfpatch.", dir=tmp_root) as tmp:
            for folder, upstream, _shipped in unit["folders"]:
                shutil.copytree(upstream, os.path.join(tmp, folder), symlinks=True,
                                ignore=shutil.ignore_patterns(MARKER))
            ok, failed, text = apply_patch(path, tmp)
            if not ok:
                failures.append("%s does not apply to upstream: %s %s" % (patch, failed, text.strip()[-300:]))
                continue
            for folder, _upstream, shipped in unit["folders"]:
                only_a, only_b, differ = compare_trees(os.path.join(tmp, folder), shipped)
                if only_a or only_b or differ:
                    failures.append("%s applied to upstream does not give %s: extra %s, missing %s, changed %s" % (
                        patch, folder, only_a[:5], only_b[:5], differ[:5]))
                    break
            else:
                out("OK patched    %-22s %s (%d files, %s)" % (
                    ", ".join(sorted(declared)), unit["package"], body.count(b"\ndiff -u ") + 1, patch))
    for line in failures:
        out("FAIL " + line)
    out("verify patches=%d unmodified=%d failures=%d" % (len(selected(all_units, names)),
                                                           0 if names else len(unmodified), len(failures)))
    return 1 if failures else 0


def regenerate(manifest, names):
    all_units, _unmodified = units(manifest)
    for patch, unit in selected(all_units, names):
        path = os.path.join(REPO, patch)
        old = read_bytes(path) if os.path.isfile(path) else b""
        header, _body = split_patch(old)
        if not header.strip():
            header = default_header(unit["package"], unit["folders"])
        body = patch_body(unit["folders"])
        if not body:
            raise PatchError("%s: shipped folders equal upstream, nothing to write" % patch)
        new = header + body
        if new != old:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "wb") as fh:
                fh.write(new)
        print("%s %s (%d bytes)" % ("wrote" if new != old else "unchanged", patch, len(new)))
    return 0


def reapply(manifest, package, upstream_root, out):
    all_units, _unmodified = units(manifest)
    (patch, unit), = selected(all_units, [package])
    if os.path.exists(out):
        raise PatchError("--out must be a new directory: %s" % out)
    found = {os.path.basename(f).lower(): f for f in toclib.find_addon_folders(upstream_root)}
    missing = [f[0] for f in unit["folders"] if f[0].lower() not in found]
    if missing:
        print("MISSING folders in %s: %s" % (upstream_root, ", ".join(missing)))
        return 1
    os.makedirs(out)
    for folder, _upstream, _shipped in unit["folders"]:
        shutil.copytree(found[folder.lower()], os.path.join(out, folder), symlinks=True,
                        ignore=shutil.ignore_patterns(MARKER))
    ok, failed, text = apply_patch(os.path.join(REPO, patch), out)
    for name, count in sorted(failed.items(), key=lambda kv: str(kv[0])):
        print("CONFLICT %s: %d hunk(s) failed (see %s.rej)" % (name, count, name))
    if not ok and not failed:
        print(text.strip())
    print("reapply %s -> %s: %s" % (patch, out, "clean" if ok else "conflicts=%d" % len(failed)))
    return 0 if ok else 1


def main():
    parser = argparse.ArgumentParser(description="Verify, regenerate and re-apply the third-party patches")
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("verify", "regenerate"):
        p = sub.add_parser(name)
        p.add_argument("--package", nargs="*", default=[], help="package names (default: all)")
    p = sub.add_parser("reapply")
    p.add_argument("--package", required=True)
    p.add_argument("--upstream", required=True, help="new upstream package root (extracted ZIP)")
    p.add_argument("--out", required=True, help="new directory for the patched folders")
    args = parser.parse_args()
    try:
        manifest = load_manifest()
        if args.command == "verify":
            return verify(manifest, args.package)
        if args.command == "regenerate":
            return regenerate(manifest, args.package)
        return reapply(manifest, args.package, os.path.abspath(args.upstream), os.path.abspath(args.out))
    except PatchError as exc:
        print("ERROR " + str(exc))
        return 2


if __name__ == "__main__":
    sys.exit(main())

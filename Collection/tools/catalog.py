"""Installer catalog values read from built release ZIPs.

Usage:
  python3 -I Collection/tools/catalog.py ZIP [ZIP ...] [--default VARIANT] [--out FILE]

Per ZIP (shape of a ``packages`` entry of Collection/Installer/ReleaseCatalog.json):
variant and version from ``DevilForever-install/manifest.json`` (``unit_frames``,
``version``), the ZIP file name, full sha256 and byte count, and inside the
archive the regular files under ``Interface/AddOns/``: their count, the sum of
their uncompressed sizes and the sorted top-level folder names. The values are
what the installer compares (ApprovedPackage: manifest folders, AddonBytes,
AddonFiles). Every ZIP must carry the same manifest ``interface``; the output
object holds it once, with ``defaultVariant`` (default: the first ZIP's variant).
Printed as JSON; ``--out`` also writes it to a new file.
"""

import argparse
import hashlib
import json
import os
import sys
import zipfile

ADDON_PREFIX = "Interface/AddOns/"
MANIFEST = "DevilForever-install/manifest.json"


def package_entry(path):
    with open(path, "rb") as fh:
        data = fh.read()
    with zipfile.ZipFile(path) as zf:
        manifest = json.loads(zf.read(MANIFEST))
        files = [i for i in zf.infolist() if not i.is_dir() and i.filename.startswith(ADDON_PREFIX)]
        folders = sorted({i.filename[len(ADDON_PREFIX):].split("/", 1)[0] for i in files})
        listed = sorted(f["folder"] for f in manifest["folders"])
    if folders != listed:
        raise ValueError("%s: archive folders differ from its manifest" % path)
    return manifest["interface"], {
        "variant": manifest["unit_frames"],
        "version": manifest["version"],
        "zip": os.path.basename(path),
        "sha256": hashlib.sha256(data).hexdigest(),
        "zipBytes": len(data),
        "addonBytes": sum(i.file_size for i in files),
        "addonFiles": len(files),
        "folders": folders,
    }


def main():
    parser = argparse.ArgumentParser(description="Installer catalog values from release ZIPs")
    parser.add_argument("zips", nargs="+")
    parser.add_argument("--default", help="defaultVariant (default: the first ZIP's variant)")
    parser.add_argument("--out", help="also write the JSON to this new file")
    args = parser.parse_args()
    interfaces, packages = set(), []
    for path in args.zips:
        interface, entry = package_entry(path)
        interfaces.add(interface)
        packages.append(entry)
    if len(interfaces) != 1:
        print("ERROR the ZIPs name different interfaces: %s" % sorted(interfaces))
        return 1
    catalog = {"schema": "devil-forever-installer-catalog/1", "interface": interfaces.pop(),
               "defaultVariant": args.default or packages[0]["variant"], "packages": packages}
    text = json.dumps(catalog, indent=2, ensure_ascii=False) + "\n"
    if args.out:
        with open(args.out, "x", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())

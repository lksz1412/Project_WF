"""Verify the 0.1.4 review sources and build local comparison archives."""

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
from zipfile import ZIP_DEFLATED, ZipFile


REVIEW = Path(__file__).resolve().parents[1]
ROOT = REVIEW.parents[1]
ADDONS = ROOT / "Collection/AddOns"
ADDON_PREFIX = "Interface/AddOns/"
INSTALL_PREFIX = "DevilForever-install/"
CHECKSUMS = INSTALL_PREFIX + "SHA256SUMS.txt"


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def release_rows():
    return read_json(REVIEW / "trial-receipt.json")["packages"]


def install_folders(part):
    return set(part["own"]).union(*part["upstream"].values())


def verify_source():
    install = read_json(ROOT / "Collection/install.json")
    variants = read_json(REVIEW / "addon-files.json")["variants"]
    shared = variants["one-session"]
    for row in release_rows():
        variant = row["variant"]
        folders = install_folders(install) | install_folders(install["unit_frame_variants"][variant])
        if folders != set(row["folders"]) or install["version"] != row["version"]:
            raise ValueError(f"Collection/install.json differs from the original {variant} release")
        members = variants[variant]
        assert len(members) == row["addonFiles"], row["variant"]
        assert {name.split("/")[0] for name in members} == set(row["folders"]), row["variant"]
        assert all(shared.get(name) == digest for name, digest in members.items()), row["variant"]
    mismatches = [name for name, digest in shared.items()
                  if not (ADDONS / name).is_file() or sha256(ADDONS / name) != digest]
    if mismatches:
        raise ValueError("Source differs from the frozen 0.1.4 baseline: " + ", ".join(mismatches[:12]))
    for item in read_json(REVIEW / "candidates/receipt.json"):
        if sha256(REVIEW / "candidates" / item["zip"]) != item["sha256"]:
            raise ValueError("Candidate archive digest mismatch: " + item["zip"])
    print(f"PASS original source payload: {len(shared)} files and four candidate ZIPs")


def verify_release(directory):
    for row in [*release_rows(), read_json(REVIEW / "perf-probe-zip.json")]:
        archive = directory / row["zip"]
        if sha256(archive) != row["sha256"]:
            raise ValueError(f"Release archive digest mismatch: {archive}")
        print(f"PASS published SHA-256: {archive.name}")


def safe_addon_folder(name):
    folder = PurePosixPath(name)
    if len(folder.parts) != 1 or name in (".", "..") or ":" in name or "\\" in name:
        raise ValueError(f"Invalid addon folder: {name!r}")
    path = ADDONS / name
    if not path.is_dir() or path.is_symlink():
        raise ValueError(f"Addon folder missing or symbolic: {path}")
    return path


def package_sources(folders):
    for folder in sorted(folders):
        for path in sorted(safe_addon_folder(folder).rglob("*")):
            if path.is_symlink():
                raise ValueError(f"Unexpected symbolic path: {path}")
            if path.is_file() and "__pycache__" not in path.parts and path.name not in (".DS_Store", "Thumbs.db"):
                yield ADDON_PREFIX + path.relative_to(ADDONS).as_posix(), path


def build_archives(output):
    output.mkdir(parents=True, exist_ok=False)
    for row in release_rows():
        variant = row["variant"]
        metadata = REVIEW / "packages" / variant
        manifest = read_json(metadata / "manifest.json")
        folders = [entry["folder"] for entry in manifest["folders"]]
        if set(folders) != set(row["folders"]) or len(folders) != len(set(folders)):
            raise ValueError(f"Variant folder list differs from the review manifest: {variant}")
        sources = dict(package_sources(folders))
        for path in sorted(metadata.iterdir()):
            if path.is_file() and path.name != "SHA256SUMS.txt":
                sources[INSTALL_PREFIX + path.name] = path
        if len({name.casefold() for name in sources}) != len(sources):
            raise ValueError(f"Case-insensitive name collision in {variant}")
        archive_path = output / row["zip"]
        digest_lines = []
        with ZipFile(archive_path, "x", compression=ZIP_DEFLATED) as archive:
            for name, path in sorted(sources.items()):
                raw = path.read_bytes()
                archive.writestr(name, raw)
                digest_lines.append(f"{hashlib.sha256(raw).hexdigest()}  {name}\n")
            archive.writestr(CHECKSUMS, "".join(digest_lines).encode("utf-8"))
        print(f"BUILT {variant}: {archive_path} sha256={sha256(archive_path)}")
    probe = read_json(REVIEW / "perf-probe-zip.json")
    archive_path = output / probe["zip"]
    with ZipFile(archive_path, "x", compression=ZIP_DEFLATED) as archive:
        for member in probe["files"]:
            archive.write(REVIEW / "diagnostics" / member.removeprefix(ADDON_PREFIX), member)
    print(f"BUILT frame-time probe: {archive_path} sha256={sha256(archive_path)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("verify-source", help="Compare the checkout with the 0.1.4 SHA-256 manifest.")
    commands.add_parser("verify-release", help="Verify the four original downloaded release ZIPs.").add_argument(
        "directory", type=Path)
    commands.add_parser("build", help="Build the three trial variants and the probe in a new directory.").add_argument(
        "output", type=Path)
    args = parser.parse_args()
    if args.command == "verify-source":
        verify_source()
    elif args.command == "verify-release":
        verify_release(args.directory)
    else:
        build_archives(args.output.resolve())


if __name__ == "__main__":
    main()

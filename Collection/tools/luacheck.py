"""Lua 5.1 syntax check: compile every .lua file without running it.

Usage:  python3 -I Collection/tools/luacheck.py <file-or-dir> [...] [--json OUT]

Each file is compiled with Lua 5.1 ``loadstring`` through lupa (``lupa.lua51``);
the returned chunk is discarded, so no addon code runs. A leading UTF-8 BOM is
stripped before compiling; a file starting with ``\x1b`` (precompiled
bytecode) is a failure and is not handed to Lua. Exit code 1 when any file fails to compile.
"""

import argparse
import json
import os
import sys

try:
    import lupa
    from lupa import lua51
except ImportError as exc:  # pragma: no cover - environment check
    sys.stderr.write("lupa with Lua 5.1 is required (pip install lupa): %s\n" % exc)
    sys.exit(2)


def iter_lua_files(paths):
    seen = set()
    for path in paths:
        if os.path.isfile(path):
            candidates = [path]
        elif os.path.isdir(path):
            candidates = []
            for dirpath, dirnames, filenames in os.walk(path):
                dirnames.sort()
                for name in sorted(filenames):
                    if name.lower().endswith(".lua"):
                        candidates.append(os.path.join(dirpath, name))
        else:
            raise FileNotFoundError(path)
        for item in candidates:
            real = os.path.realpath(item)
            if real not in seen:
                seen.add(real)
                yield item


def make_compiler():
    runtime = lua51.LuaRuntime(encoding=None, register_eval=False, register_builtins=False)
    version = runtime.eval(b"_VERSION")
    is_jit = runtime.eval(b"type(jit) == 'table'")
    loadstring = runtime.globals()[b"loadstring"]
    return loadstring, version, bool(is_jit)


def check(paths):
    loadstring, version, is_jit = make_compiler()
    results = {"lua_version": version.decode() if isinstance(version, bytes) else str(version),
               "luajit": is_jit, "lupa": lupa.__version__, "checked": 0, "failed": []}
    for path in iter_lua_files(paths):
        with open(path, "rb") as fh:
            src = fh.read()
        if src.startswith(b"\xef\xbb\xbf"):
            src = src[3:]
        results["checked"] += 1
        if src.startswith(b"\x1b"):
            results["failed"].append({"file": path, "error": "precompiled Lua bytecode, not source"})
            continue
        chunk = loadstring(src, ("@" + path).encode("utf-8", "replace"))
        if isinstance(chunk, tuple):
            fn, err = chunk[0], chunk[1] if len(chunk) > 1 else None
        else:
            fn, err = chunk, None
        if fn is None:
            message = err.decode("utf-8", "replace") if isinstance(err, bytes) else str(err)
            results["failed"].append({"file": path, "error": message})
    return results


def main():
    parser = argparse.ArgumentParser(description="Lua 5.1 compile-only syntax check")
    parser.add_argument("paths", nargs="+")
    parser.add_argument("--json", help="write the full result to this JSON file")
    args = parser.parse_args()
    results = check(args.paths)
    for item in results["failed"]:
        print("FAIL %s :: %s" % (item["file"], item["error"]))
    print("runtime=%s luajit=%s lupa=%s checked=%d failed=%d" % (
        results["lua_version"], results["luajit"], results["lupa"],
        results["checked"], len(results["failed"])))
    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(results, fh, indent=1, ensure_ascii=False)
            fh.write("\n")
    return 1 if results["failed"] else 0


if __name__ == "__main__":
    sys.exit(main())

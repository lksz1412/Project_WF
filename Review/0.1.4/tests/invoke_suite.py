"""Apply explicit build-only exclusions to an unchanged suite in scratch."""

import json
from pathlib import Path
import runpy
import sys


def main():
    entry = Path(sys.argv[1])
    excluded = set(json.loads(sys.argv[2]))
    scope = runpy.run_path(str(entry))
    pool = scope["CASES"]
    actual = {fn.__name__ for fn in pool}
    if not excluded <= actual:
        raise ValueError("Excluded build cases missing from source: " + repr(excluded - actual))
    pool[:] = [fn for fn in pool if fn.__name__ not in excluded]
    if len(sys.argv) == 4:
        scope["main"].__globals__["UPSTREAM"] = str(Path(sys.argv[3]))
    return scope["main"]()


if __name__ == "__main__":
    sys.exit(main())

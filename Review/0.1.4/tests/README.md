# Portable regression tests

Run from the repository root with Python 3.12 and Lua 5.1 supplied by lupa.

```text
python -m pip install -r Review/0.1.4/tests/requirements.txt
python Review/0.1.4/tests/run.py --output ../wf-review-test-output
```

Choose a new output directory outside the checkout. The runner refuses an existing directory and leaves all output intact. It creates a physical snapshot of the current `Collection/AddOns`, the eight test sources, and required fixtures below that directory. It does not install anything into the game or modify checked-out AddOns. Every copied addon file is listed with its SHA256 in `tested-sources.json`. Logs and `results.json` remain in the output directory.

| Suite | Expected result |
|---|---|
| core | 104 cases |
| chatsetup | 28 cases |
| statusstrip | 20 cases |
| pitbull4 | 5 cases |
| castbars | 16 cases |
| fufdefaults | 22 cases, including shipped native FUF commands |
| detailslayout | 6 preset/scale pairs, 28 refusal cases, native error rollback |
| performance | Existing preset batching, notification equivalence and pet update gates |

The counted cases total 195. Details and performance use their existing final assertion markers instead of a case counter. A zero process exit alone is insufficient for the runner to report success.

The performance comparison preserves its existing fixed limits. Preset changes render appearance once instead of 39 times, unrelated Dominos bar calls fall from 20 to zero, and pet button calls fall from 100 to 10. These are Lua stub call counts. They do not measure in-game frame time, FPS, visual placement or game client compatibility.

## Fixtures and native source identity

`fixtures/provenance.json` records the baseline archive SHA256, every copied member name, byte count and SHA256. The runner verifies each fixture before executing a suite. It reconstructs a small ZIP containing only the 33 archive members the performance test opens. Their contents are exact bytes from the previous `DevilForever-0.1.1.zip`. The complete archive SHA256 is `dd78f96bdf8d8e690bbc0aefc9a5b0b7a1d9f6edffb0b3179696c171123ee23b`.

Four PitBull TOCs are untouched v4.2.50 upstream bytes. The PitBull wrapper points its upstream comparison at these fixtures. The three Details layout fragments are copied unchanged from the existing `References/codex-appearance/10` reference data and staged into the output snapshot. Core Lua fixtures are copied unchanged from `Collection/tests/core/fixtures`.

FUF and Details execute native methods from the copied checked-out `Collection/AddOns/ForeverUnitFrames` and `Collection/AddOns/Details` files. The FUF test's old upstream path is replaced only in its scratch test copy. No modified shipped addon is presented as an untouched upstream version. The performance test reads the old Core and Appearance TOCs from the baseline ZIP and current TOCs from the checkout snapshot.

## Five existing build-only exclusions

These are the same exclusions used for the prior 0.1.4 runtime verification. They remain in their original suite source and are reported by name and reason in `results.json`.

| Case | Reason |
|---|---|
| core `genregistry_extra_applied_and_checked` | Build generator validation, outside the shipped runtime suite |
| core `genregistry_output_matches_file` | Requires complete upstream build inputs to regenerate the registry |
| core `genregistry_editable_frame_and_default_checked` | Build generator validation, outside the shipped runtime suite |
| core `genregistry_t28_restore_options` | Build generator validation, outside the shipped runtime suite |
| pitbull4 `patch_reproduces_the_copy` | Requires complete original upstream tree and the patch utility |

These tests make no claim that excluded build operations were executed. In-game checks remain separate.

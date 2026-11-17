# 변경 고지(Apache License 2.0 §4(b)): Anthropic `anthropics/skills` 의 skills/docx/scripts/accept_changes.py(라이선스 = 이 하위 문서 폴더 LICENSE.txt)를 고친 파일 — Windows 에서 Word COM(office/office_com.ps1)으로 수락 · LibreOffice 경로의 Writer 안내·시간 한도·변경 추적이 남지 않았는지 확인.
"""Accept all tracked changes in a DOCX file.

On Windows, Microsoft Word accepts them through COM (scripts/office/office_com.ps1).
Elsewhere a LibreOffice macro does, which requires LibreOffice (soffice) with its
Writer component to be installed; the run succeeds only if the written document
has no tracked change left (a timeout is a failure).
BADA_OFFICE_COM_RUNNER: test seam - a program run in place of PowerShell on the Windows path.
"""

import argparse
import json
import logging
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

from office.soffice import get_soffice_env

logger = logging.getLogger(__name__)

LIBREOFFICE_PROFILE = "/tmp/libreoffice_docx_profile"
MACRO_DIR = f"{LIBREOFFICE_PROFILE}/user/basic/Standard"

OFFICE_COM_SCRIPT = Path(__file__).resolve().parent / "office" / "office_com.ps1"
OFFICE_COM_RUNNER_ENV = "BADA_OFFICE_COM_RUNNER"
OFFICE_COM_TIMEOUT = 300
OFFICE_COM_REQUIRED = (
    "On Windows this step drives Microsoft Office through COM; it does not fall back to "
    "LibreOffice. If the error before this names something the user can clear - the file is "
    "already open or opened read-only, or other workbooks are open - ask the user to save "
    "and close it, then run this again; after a timeout, follow that error's advice. Any "
    "other failure means Office cannot be used here, which breaks the premise that it is "
    "installed and usable: record this step as not run and tell the user."
)

LIBREOFFICE_TIMEOUT = 30
WRITER_REQUIRED = (
    "LibreOffice needs its Writer component for this (e.g. the libreoffice-writer "
    "package): without Writer the document never opens, nothing is accepted, and the "
    "run times out"
)

WORD_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
# WordprocessingML tracked-change marks: content, move, property and table-cell changes.
TRACKED_CHANGE_TAGS = frozenset(
    f"{{{WORD_NS}}}{name}"
    for name in (
        "ins", "del", "moveFrom", "moveTo",
        "rPrChange", "pPrChange", "sectPrChange", "tblPrChange", "tblPrExChange",
        "tblGridChange", "trPrChange", "tcPrChange", "numberingChange",
        "cellIns", "cellDel", "cellMerge",
    )
)

ACCEPT_CHANGES_MACRO = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE script:module PUBLIC "-//OpenOffice.org//DTD OfficeDocument 1.0//EN" "module.dtd">
<script:module xmlns:script="http://openoffice.org/2000/script" script:name="Module1" script:language="StarBasic">
    Sub AcceptAllTrackedChanges()
        Dim document As Object
        Dim dispatcher As Object

        document = ThisComponent.CurrentController.Frame
        dispatcher = createUnoService("com.sun.star.frame.DispatchHelper")

        dispatcher.executeDispatch(document, ".uno:AcceptAllTrackedChanges", "", 0, Array())
        ThisComponent.store()
        ThisComponent.close(True)
    End Sub
</script:module>"""


def accept_changes(
    input_file: str,
    output_file: str,
) -> tuple[bool, str]:
    """Return (True, message) when the output has every tracked change accepted, else (False, message)."""
    input_path = Path(input_file)
    output_path = Path(output_file)

    if not input_path.exists():
        return False, f"Error: Input file not found: {input_file}"

    if not input_path.suffix.lower() == ".docx":
        return False, f"Error: Input file is not a DOCX file: {input_file}"

    if sys.platform == "win32":
        return _accept_changes_with_word(input_file, output_file)

    try:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(input_path, output_path)
    except Exception as e:
        return False, f"Error: Failed to copy input file to output location: {e}"

    if not _setup_libreoffice_macro():
        return False, "Error: Failed to setup LibreOffice macro"

    cmd = [
        "soffice",
        "--headless",
        f"-env:UserInstallation=file://{LIBREOFFICE_PROFILE}",
        "--norestore",
        "vnd.sun.star.script:Standard.Module1.AcceptAllTrackedChanges?language=Basic&location=application",
        str(output_path.absolute()),
    ]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=LIBREOFFICE_TIMEOUT,
            check=False,
            env=get_soffice_env(),
        )
    except subprocess.TimeoutExpired:
        return (
            False,
            f"Error: LibreOffice timed out after {LIBREOFFICE_TIMEOUT}s, so the tracked changes "
            f"were NOT confirmed accepted - do not use {output_file} as the clean copy. "
            f"Re-run it; {WRITER_REQUIRED}.",
        )

    if result.returncode != 0:
        return False, f"Error: LibreOffice failed: {result.stderr}"

    try:
        left = _tracked_changes_left(output_path)
    except Exception as e:
        return (
            False,
            f"Error: could not read {output_file} to confirm the tracked changes were accepted: {e}",
        )
    if left:
        return (
            False,
            f"Error: LibreOffice finished, but {left} tracked change(s) are still in "
            f"{output_file}, so the tracked changes were NOT accepted - do not use it as the "
            f"clean copy. {WRITER_REQUIRED}; if Writer is installed, a headless LibreOffice "
            f"left running by an earlier timed-out run may have taken the file - end it, then "
            f"retry.",
        )

    return (
        True,
        f"Successfully accepted all tracked changes: {input_file} -> {output_file}",
    )


def _tracked_changes_left(docx_path: Path) -> int:
    """Count tracked-change marks in the word/*.xml parts; raises if the file cannot be read."""
    from defusedxml.ElementTree import fromstring

    left = 0
    with zipfile.ZipFile(docx_path) as archive:
        for name in archive.namelist():
            if name.startswith("word/") and name.endswith(".xml"):
                root = fromstring(archive.read(name))
                left += sum(1 for elem in root.iter() if elem.tag in TRACKED_CHANGE_TAGS)
    return left


def _accept_changes_with_word(input_file: str, output_file: str) -> tuple[bool, str]:
    _, error = run_office_com(
        "accept-revisions", input_file, output_file, timeout=OFFICE_COM_TIMEOUT
    )
    if error is None and not Path(output_file).exists():
        error = f"no document was written to {output_file}"
    if error is not None:
        return (
            False,
            f"Error: Word could not accept the tracked changes: {error}. {OFFICE_COM_REQUIRED}",
        )

    return (
        True,
        f"Successfully accepted all tracked changes: {input_file} -> {output_file}",
    )


def run_office_com(action, source, target=None, timeout=None):
    """Run office_com.ps1 and return (result, None), or (None, error text) on failure."""
    runner = os.environ.get(OFFICE_COM_RUNNER_ENV)
    if runner:
        cmd = [runner]
    else:
        shell = shutil.which("powershell.exe") or shutil.which("pwsh")
        if shell is None:
            return None, "neither powershell.exe nor pwsh was found on PATH"
        cmd = [shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File"]
    cmd += [str(OFFICE_COM_SCRIPT), action, "-In", os.path.abspath(source)]
    if target is not None:
        cmd += ["-Out", os.path.abspath(target)]

    with tempfile.TemporaryDirectory(prefix="office_com_", ignore_cleanup_errors=True) as tmp:
        result_path = os.path.join(tmp, "result.json")
        cmd += ["-ResultJson", result_path]
        try:
            proc = subprocess.run(
                cmd, capture_output=True, text=True, errors="replace", timeout=timeout
            )
        except subprocess.TimeoutExpired:
            return None, (
                f"no result within {timeout}s - Office may still be starting, a hidden Office "
                "dialog may be waiting (e.g. a password prompt), or the work needs longer (a direct "
                "scripts/office/office_com.ps1 call has no time limit); an Office process this run "
                "started (EXCEL.EXE / WINWORD.EXE / POWERPNT.EXE with no window) may be left running - "
                "end only that one, never an Office app you have open, then re-run"
            )
        except OSError as e:
            return None, f"could not run {cmd[0]}: {e}"
        try:
            with open(result_path, encoding="utf-8") as f:
                result = json.load(f)
        except (OSError, ValueError):
            result = None

    if not isinstance(result, dict):
        result = {}
    if proc.returncode == 0 and result.get("ok") is True:
        return result, None
    detail = result.get("error") or (proc.stderr or proc.stdout or "").strip()
    detail = detail.strip().rstrip(".") if detail else ""
    return None, detail or f"{cmd[0]} exited with code {proc.returncode}"


def _setup_libreoffice_macro() -> bool:
    macro_dir = Path(MACRO_DIR)
    macro_file = macro_dir / "Module1.xba"

    if macro_file.exists() and "AcceptAllTrackedChanges" in macro_file.read_text():
        return True

    if not macro_dir.exists():
        subprocess.run(
            [
                "soffice",
                "--headless",
                f"-env:UserInstallation=file://{LIBREOFFICE_PROFILE}",
                "--terminate_after_init",
            ],
            capture_output=True,
            timeout=10,
            check=False,
            env=get_soffice_env(),
        )
        macro_dir.mkdir(parents=True, exist_ok=True)

    try:
        macro_file.write_text(ACCEPT_CHANGES_MACRO)
        return True
    except Exception as e:
        logger.warning(f"Failed to setup LibreOffice macro: {e}")
        return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Accept all tracked changes in a DOCX file"
    )
    parser.add_argument("input_file", help="Input DOCX file with tracked changes")
    parser.add_argument(
        "output_file", help="Output DOCX file (clean, no tracked changes)"
    )
    args = parser.parse_args()

    accepted, message = accept_changes(args.input_file, args.output_file)
    print(message)

    if not accepted:
        raise SystemExit(1)

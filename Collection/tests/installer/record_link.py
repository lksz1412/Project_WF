"""Check that active metadata must match the recorded completed payload."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def snapshot(root):
    entries = {}
    for path in sorted(root.rglob('*')):
        relative = path.relative_to(root).as_posix()
        if path.is_dir():
            entries[relative + '/'] = None
        else:
            with path.open('rb') as stream:
                entries[relative] = hashlib.file_digest(stream, 'sha256').hexdigest()
    return entries


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--exe', type=Path, required=True)
    parser.add_argument('--modified-install', type=Path, required=True)
    parser.add_argument('--valid-install', type=Path, required=True)
    parser.add_argument('--package', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    args = parser.parse_args()
    output = Path(tempfile.mkdtemp(prefix='record-link-', dir=args.scratch.resolve()))
    modified = args.modified_install.resolve()
    valid = args.valid_install.resolve()
    before = snapshot(modified)
    assert 'Interface/AddOns/PitBull4/User-only.txt' in before
    calls = []
    for action, options in (('verify', []), ('plan', ['--package', str(args.package.resolve())])):
        command = [str(args.exe.resolve()), action, '--game', str(modified), *options, '--json']
        process = subprocess.run(command, capture_output=True, encoding='utf8')
        result = json.loads(process.stdout)
        calls.append({'arguments': command, 'exitCode': process.returncode, 'result': result})
        assert process.returncode == 2 and result['status'] == 'blocked', calls[-1]
        assert any(issue['code'] == 'invalid-record' for issue in result['issues']), calls[-1]
    assert snapshot(modified) == before
    command = [str(args.exe.resolve()), 'verify', '--game', str(valid), '--json']
    process = subprocess.run(command, capture_output=True, encoding='utf8')
    result = json.loads(process.stdout)
    calls.append({'arguments': command, 'exitCode': process.returncode, 'result': result})
    assert process.returncode == 0 and result['status'] == 'ready', calls[-1]
    (output / 'result.json').write_text(json.dumps({'passed': 3, 'modifiedTargetWrites': 0, 'calls': calls},
                                                ensure_ascii=False, indent=2), encoding='utf8')
    print('PASS altered active rejected by verify and variant plan; original files unchanged')
    print('PASS valid installed payload still verifies')
    print(json.dumps({'passed': 3, 'receipt': str(output / 'result.json')}))


if __name__ == '__main__':
    main()

"""Run the installer through its public executable on isolated game fixtures."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile


def digest_tree(root):
    result = {}
    for path in sorted(root.rglob('*')):
        relative = path.relative_to(root).as_posix()
        if path.is_dir():
            result[relative + '/'] = None
        else:
            with path.open('rb') as stream:
                result[relative] = hashlib.file_digest(stream, 'sha256').hexdigest()
    return result


def fixture(parent, name, pristine=False):
    root = parent / name / '_forever_'
    root.mkdir(parents=True)
    (root / 'Wow.exe').write_bytes(b'isolated installer fixture\n')
    if not pristine:
        (root / 'Interface/AddOns/ExistingAddon').mkdir(parents=True)
        (root / 'Interface/AddOns/ExistingAddon/Keep.lua').write_bytes(b'original local addon\n')
    (root / 'WTF/Account/Fixture').mkdir(parents=True)
    (root / 'WTF/Account/Fixture/Keep.lua').write_bytes(b'original private settings\n')
    return root


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--exe', required=True, type=Path)
    parser.add_argument('--packages', required=True, type=Path)
    parser.add_argument('--scratch', required=True, type=Path)
    parser.add_argument('--version', default='0.1.0')
    args = parser.parse_args()
    args.exe = args.exe.resolve()
    args.packages = args.packages.resolve()
    root = Path(tempfile.mkdtemp(prefix='public-cli-', dir=args.scratch.resolve()))
    calls = []

    def call(game, action, *options, expect=0):
        command = [str(args.exe), action, '--game', str(game), *options, '--json']
        process = subprocess.run(command, capture_output=True, encoding='utf-8')
        output = json.loads(process.stdout)
        record = {'command': command, 'exitCode': process.returncode, 'result': output,
                  'stderr': process.stderr}
        calls.append(record)
        (root / 'calls.json').write_text(json.dumps(calls, ensure_ascii=False, indent=2), encoding='utf-8')
        assert process.returncode == expect == output['exitCode'], record
        return output

    package_name = f'DevilForever-{args.version}'
    pitbull = str(args.packages / f'{package_name}.zip')
    fuf = str(args.packages / f'{package_name}-fuf.zip')
    passed = []

    game = fixture(root, '한글 새 설치')
    before = digest_tree(game)
    assert call(game, 'inspect')['managedState'] == 'none'
    plan = call(game, 'plan', '--package', pitbull)
    assert len(plan['changes']) == 35 and plan['status'] == 'ready'
    assert digest_tree(game) == before
    repeated = call(game, 'plan', '--package', pitbull)
    assert repeated['planToken'] == plan['planToken']
    passed.append('inspect and repeated preview are read-only and deterministic')
    apply = call(game, 'apply', '--package', pitbull, '--confirm', plan['planToken'])
    assert apply['status'] == 'completed'
    assert call(game, 'verify')['status'] == 'ready'
    assert (game / 'Interface/AddOns/ExistingAddon/Keep.lua').read_bytes() == b'original local addon\n'
    assert (game / 'WTF/Account/Fixture/Keep.lua').read_bytes() == b'original private settings\n'
    passed.append('actual approved PitBull4 installs and verifies with unrelated addon and WTF preserved')
    before = digest_tree(game)
    plan = call(game, 'plan', '--package', pitbull)
    assert plan['status'] == 'no-change'
    assert call(game, 'apply', '--package', pitbull, '--confirm', plan['planToken'])['status'] == 'no-change'
    assert digest_tree(game) == before
    passed.append('same installed package does not create new files or records')
    (game / 'Interface/AddOns/DevilForever_ChatSetup/Changed.txt').write_bytes(b'user change\n')
    before = digest_tree(game)
    assert call(game, 'plan', '--package', pitbull, expect=2)['status'] == 'blocked'
    assert call(game, 'apply', '--package', pitbull, '--confirm', plan['planToken'], expect=2)['status'] == 'blocked'
    assert digest_tree(game) == before
    passed.append('modified managed folder blocks writes')

    stale = fixture(root, '古い 確認値')
    plan = call(stale, 'plan', '--package', pitbull)
    folder = stale / 'Interface/AddOns/SexyMap'
    folder.mkdir()
    (folder / 'User.txt').write_bytes(b'keep\n')
    before = digest_tree(stale)
    assert call(stale, 'apply', '--package', pitbull, '--confirm', plan['planToken'], expect=2)['status'] == 'blocked'
    assert digest_tree(stale) == before
    assert not (stale / 'DevilForever-installer').exists()
    passed.append('changed overlap after preview blocks without a management directory')

    takeover = fixture(root, '기존 폴더 선택')
    overlap = takeover / 'Interface/AddOns/DevilForever_ChatSetup'
    overlap.mkdir()
    (overlap / 'Only-user.txt').write_bytes(b'preserve original\n')
    before = digest_tree(takeover)
    assert call(takeover, 'plan', '--package', pitbull, expect=2)['status'] == 'blocked'
    assert digest_tree(takeover) == before
    plan = call(takeover, 'plan', '--package', pitbull, '--replace', 'DevilForever_ChatSetup')
    assert any(change['operation'] == 'take-over' for change in plan['changes'])
    result = call(takeover, 'apply', '--package', pitbull, '--replace', 'DevilForever_ChatSetup', '--confirm', plan['planToken'])
    backup = takeover / 'DevilForever-installer/runs' / result['runId'] / 'before/DevilForever_ChatSetup/Only-user.txt'
    assert backup.read_bytes() == b'preserve original\n'
    assert call(takeover, 'verify')['status'] == 'ready'
    passed.append('only explicitly selected overlap is backed up and taken over')

    opposite = fixture(root, '반대 판 충돌')
    (opposite / 'Interface/AddOns/ForeverUnitFrames').mkdir()
    (opposite / 'Interface/AddOns/ForeverUnitFrames/Keep.lua').write_bytes(b'keep fuf\n')
    before = digest_tree(opposite)
    blocked = call(opposite, 'plan', '--package', pitbull, expect=2)
    assert any(item['code'] == 'unmanaged-opposite-variant' for item in blocked['conflicts'])
    call(opposite, 'apply', '--package', pitbull, '--confirm', 'invalid', expect=2)
    assert digest_tree(opposite) == before
    passed.append('unmanaged opposite variant blocks all target and management writes')

    pristine = fixture(root, '폴더 없는 FUF 설치', pristine=True)
    before = digest_tree(pristine)
    plan = call(pristine, 'plan', '--package', fuf)
    assert len(plan['changes']) == 37 and digest_tree(pristine) == before
    assert call(pristine, 'apply', '--package', fuf, '--confirm', 'stale', expect=2)['status'] == 'blocked'
    assert digest_tree(pristine) == before
    assert call(pristine, 'apply', '--package', fuf, '--confirm', plan['planToken'])['status'] == 'completed'
    assert call(pristine, 'verify')['status'] == 'ready'
    assert not (pristine / 'Interface/AddOns/PitBull4').exists()
    passed.append('pristine game gets FUF directories only after a current confirmation')

    unknown = fixture(root, '패키지 거부')
    before = digest_tree(unknown)
    comparison = str(args.packages / f'{package_name}-one-session.zip')
    assert call(unknown, 'plan', '--package', comparison, expect=2)['status'] == 'blocked'
    changed_zip = root / 'Changed.zip'
    shutil.copyfile(pitbull, changed_zip)
    with changed_zip.open('ab') as stream:
        stream.write(b'changed\n')
    assert call(unknown, 'apply', '--package', str(changed_zip), '--confirm', 'invalid', expect=2)['status'] == 'blocked'
    assert digest_tree(unknown) == before
    passed.append('comparison ZIP and tampered input are refused before writes')

    receipt = {'passed': len(passed), 'cases': passed, 'calls': len(calls), 'callLog': str(root / 'calls.json'),
               'gameRoot': str(root), 'actualGameTouched': False}
    (root / 'result.json').write_text(json.dumps(receipt, ensure_ascii=False, indent=2), encoding='utf-8')
    for case in passed:
        print('PASS', case)
    print(json.dumps({'passed': len(passed), 'calls': len(calls), 'receipt': str(root / 'result.json')}))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

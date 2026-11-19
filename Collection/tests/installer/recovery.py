"""Exercise install switching, rollback, removal, and recorded recovery states."""

import argparse
import json
from pathlib import Path
import runpy
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--exe', type=Path, required=True)
    parser.add_argument('--packages', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    args = parser.parse_args()
    exe, packages = args.exe.resolve(), args.packages.resolve()
    output = Path(tempfile.mkdtemp(prefix='recovery-cli-', dir=args.scratch.resolve()))
    helpers = runpy.run_path(str(Path(__file__).with_name('run.py')))
    fixture, digest_tree = helpers['fixture'], helpers['digest_tree']
    calls, passed = [], []

    def call(game, action, *options, expect=0):
        command = [str(exe), action, '--game', str(game), *options, '--json']
        process = subprocess.run(command, capture_output=True, encoding='utf8')
        try:
            result = json.loads(process.stdout)
        except ValueError:
            raise AssertionError((command, process.returncode, process.stdout, process.stderr))
        calls.append({'command': command, 'exitCode': process.returncode, 'result': result, 'stderr': process.stderr})
        (output / 'calls.json').write_text(json.dumps(calls, ensure_ascii=False, indent=2), encoding='utf8')
        assert process.returncode == expect == result['exitCode'], calls[-1]
        return result

    def install(game, name):
        archive = str(packages / name)
        plan = call(game, 'plan', '--package', archive)
        assert plan['status'] == 'ready', plan
        result = call(game, 'apply', '--package', archive, '--confirm', plan['planToken'])
        assert result['status'] == 'completed', result
        return result

    def run_action(game, action):
        plan = call(game, 'plan', '--action', action)
        return call(game, action, '--confirm', plan['planToken'])

    def journal_path(game, run_id):
        return game / 'DevilForever-installer/runs' / run_id / 'journal.json'

    def write(path, value):
        path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf8')

    def move(source, destination):
        assert source.resolve().is_relative_to(output) and destination.resolve().is_relative_to(output)
        destination.parent.mkdir(parents=True, exist_ok=True)
        assert not destination.exists()
        source.rename(destination)

    game = fixture(output, '두 단독판의 전환과 복원')
    install(game, 'DevilForever-0.1.0.zip')
    install(game, 'DevilForever-0.1.0-fuf.zip')
    assert not (game / 'Interface/AddOns/PitBull4').exists()
    assert (game / 'Interface/AddOns/ForeverUnitFrames').exists()
    install(game, 'DevilForever-0.1.0.zip')
    assert (game / 'Interface/AddOns/PitBull4').exists()
    assert not (game / 'Interface/AddOns/ForeverUnitFrames').exists()
    result = run_action(game, 'rollback')
    assert result['status'] == 'restored' and result['managedState'] == 'fuf'
    assert call(game, 'verify')['status'] == 'ready'
    before = digest_tree(game)
    result = run_action(game, 'rollback')
    assert result['status'] == 'no-change' and digest_tree(game) == before
    passed.append('PB to FUF to PB and previous rollback preserve exclusive folders; repeated rollback writes nothing')

    user = game / 'Interface/AddOns/DevilForever_ChatSetup/User-only.txt'
    user.write_bytes(b'user modification before remove\n')
    result = run_action(game, 'remove')
    assert result['status'] == 'completed' and 'DevilForever_ChatSetup' in result['preserved']
    assert user.read_bytes() == b'user modification before remove\n'
    assert (game / 'WTF/Account/Fixture/Keep.lua').read_bytes() == b'original private settings\n'
    assert (game / 'Interface/AddOns/ExistingAddon/Keep.lua').read_bytes() == b'original local addon\n'
    conflicting = game / 'Interface/AddOns/Details'
    conflicting.mkdir()
    (conflicting / 'User-only.txt').write_bytes(b'new after remove\n')
    before = digest_tree(game)
    blocked = call(game, 'plan', '--action', 'rollback', expect=2)
    assert any(item['code'] == 'restore-target-changed' for item in blocked['conflicts'])
    assert digest_tree(game) == before
    move(conflicting, output / 'collision preserved')
    result = run_action(game, 'rollback')
    assert result['status'] == 'restored' and result['managedState'] == 'fuf'
    assert user.read_bytes() == b'user modification before remove\n'
    assert call(game, 'verify', expect=4)['status'] == 'differences'
    before = digest_tree(game)
    assert run_action(game, 'rollback')['status'] == 'no-change'
    assert digest_tree(game) == before
    passed.append('remove preserves user edits; later collision blocks; removal rollback restores prior physical state')

    takeover = fixture(output, '명시 인수의 원래 파일')
    old = takeover / 'Interface/AddOns/DevilForever_ChatSetup'
    old.mkdir()
    (old / 'Original.txt').write_bytes(b'originally unmanaged\n')
    archive = str(packages / 'DevilForever-0.1.0.zip')
    plan = call(takeover, 'plan', '--package', archive, '--replace', 'DevilForever_ChatSetup')
    installed = call(takeover, 'apply', '--package', archive, '--replace', 'DevilForever_ChatSetup', '--confirm', plan['planToken'])
    result = run_action(takeover, 'rollback')
    assert result['status'] == 'restored' and result['managedState'] == 'none'
    assert (old / 'Original.txt').read_bytes() == b'originally unmanaged\n'
    backup = takeover / 'DevilForever-installer/runs' / installed['runId'] / 'before/DevilForever_ChatSetup/Original.txt'
    assert backup.read_bytes() == b'originally unmanaged\n'
    passed.append('rollback restores explicitly taken over original and keeps the original backup')

    pending = fixture(output, '기록 경계와 중단 복원')
    installed = install(pending, 'DevilForever-0.1.0.zip')
    record_path = journal_path(pending, installed['runId'])
    original = json.loads(record_path.read_text(encoding='utf8'))
    original['state'] = 'verifying'
    write(record_path, original)
    addon_before = digest_tree(pending / 'Interface/AddOns')
    result = run_action(pending, 'rollback')
    assert result['status'] == 'completed' and result['runId'] == installed['runId']
    assert any(item['code'] == 'finalize-completed-run' for item in result['issues'])
    assert digest_tree(pending / 'Interface/AddOns') == addon_before
    original['state'] = 'applying'
    write(record_path, original)
    move(pending / 'DevilForever-installer/active.json', output / 'before active finalization.json')
    result = run_action(pending, 'rollback')
    assert result['status'] == 'restored' and result['managedState'] == 'none'
    restored_id = result['runId']
    assert list((pending / 'Interface/AddOns').iterdir()) == [pending / 'Interface/AddOns/ExistingAddon']
    passed.append('pending final active commits only journal; pre-active pending application reverses all actual files')

    restored_path = journal_path(pending, restored_id)
    restored = json.loads(restored_path.read_text(encoding='utf8'))
    restored['state'] = 'restoring'
    write(restored_path, restored)
    original['state'] = 'applying'
    write(record_path, original)
    folder = 'PitBull4'
    move(pending / 'DevilForever-installer/runs' / restored_id / 'displaced' / folder,
         pending / 'Interface/AddOns' / folder)
    result = run_action(pending, 'rollback')
    assert result['status'] == 'restored' and result['runId'] == restored_id
    assert not (pending / 'Interface/AddOns/PitBull4').exists()
    before = digest_tree(pending)
    assert run_action(pending, 'rollback')['status'] == 'no-change'
    assert digest_tree(pending) == before
    passed.append('partially progressed rollback resumes the same run and repeated completion changes no files')

    receipt = {'passed': len(passed), 'cases': passed, 'calls': len(calls), 'scope': 'isolated actual ZIPs and synthetic journal boundaries',
               'actualForceKill': False, 'actualGameTouched': False}
    (output / 'result.json').write_text(json.dumps(receipt, ensure_ascii=False, indent=2), encoding='utf8')
    for case in passed:
        print('PASS', case)
    print(json.dumps({'passed': len(passed), 'calls': len(calls), 'receipt': str(output / 'result.json')}))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

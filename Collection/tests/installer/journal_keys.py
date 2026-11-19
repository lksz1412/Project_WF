"""Check damaged journal relations through the public rollback planner."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import uuid


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--exe', type=Path, required=True)
    parser.add_argument('--template-game', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    parser.add_argument('--case', action='append', choices=('mismatched-maps', 'missing-restore-target',
                        'absent-restore-target', 'non-restore-sources', 'normal-pending'))
    args = parser.parse_args()
    output = Path(tempfile.mkdtemp(prefix='journal-key-cases-', dir=args.scratch.resolve()))
    originals = [json.loads(path.read_text(encoding='utf8')) for path in
                 (args.template_game / 'DevilForever-installer/runs').glob('*/journal.json')]
    template = next(record for record in originals if record['action'] == 'install'
                    and record['beforeActive'] is None and len(record['after']) == 35)
    calls = []
    fixtures = []

    def call(game, action, *options):
        command = [str(args.exe.resolve()), action, '--game', str(game), *options, '--json']
        process = subprocess.run(command, capture_output=True, encoding='utf8')
        result = json.loads(process.stdout)
        calls.append({'command': command, 'exitCode': process.returncode, 'result': result})
        return process.returncode, result

    def write(path, value):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf8')

    def fingerprint(game):
        return {str(path.relative_to(game)) + ('/' if path.is_dir() else ''):
                None if path.is_dir() else hashlib.sha256(path.read_bytes()).hexdigest()
                for path in game.rglob('*')}

    cases = ('mismatched-maps', 'missing-restore-target', 'absent-restore-target', 'non-restore-sources', 'normal-pending')
    if args.case:
        cases = tuple(case for case in cases if case in args.case)
    for case in cases:
        game = output / case / '_forever_'
        game.mkdir(parents=True)
        (game / 'Wow.exe').write_bytes(b'isolated journal test\n')
        code, result = call(game, 'inspect')
        assert code == 0
        target = result['target']
        original = json.loads(json.dumps(template))
        original['target'] = target
        original['afterActive']['target'] = target
        original['state'] = 'recovery-required'
        original['failure'] = 'preparation-in-progress'
        original['restoreSources'] = {}
        store = game / 'DevilForever-installer'
        write(store / 'format.json', {'schema':'devil-forever-installer-store/1', 'target':target})
        if case == 'mismatched-maps':
            original['after'].pop('PitBull4')
        elif case == 'non-restore-sources':
            original['restoreSources']['PitBull4'] = f"DevilForever-installer/runs/{original['runId']}/before/PitBull4"
        elif case in ('missing-restore-target', 'absent-restore-target'):
            original['state'] = 'completed'
            rollback = json.loads(json.dumps(original))
            rollback['runId'] = uuid.uuid4().hex
            rollback['action'] = 'rollback'
            rollback['state'] = 'restoring'
            rollback['revertsRunId'] = original['runId']
            rollback['afterActive']['lastRunId'] = rollback['runId']
            rollback['afterActive']['lastAction'] = 'rollback'
            for move in rollback['moves']:
                for key in ('source', 'destination'):
                    move[key] = move[key].replace(f"/runs/{original['runId']}/", f"/runs/{rollback['runId']}/")
            rollback['moves'] = [move for move in rollback['moves'] if move['folder'] != 'PitBull4']
            rollback['restoreSources'] = {'PitBull4':f"DevilForever-installer/runs/{original['runId']}/before/PitBull4"}
            if case == 'missing-restore-target':
                rollback['before'].pop('PitBull4')
                rollback['after'].pop('PitBull4')
                assert 'PitBull4' not in rollback['after']
            else:
                rollback['after']['PitBull4'] = rollback['before']['PitBull4']
                assert not rollback['after']['PitBull4']['exists']
            assert rollback['before'].keys() == rollback['after'].keys()
            fixtures.append({'case':case, 'beforeFolders':len(rollback['before']), 'afterFolders':len(rollback['after']),
                             'sourceFolder':'PitBull4', 'targetPresent':'PitBull4' in rollback['after'],
                             'targetExists':rollback['after'].get('PitBull4', {}).get('exists'),
                             'expectedDetail':'복원 원본 경로가 잘못되었습니다.'})
            write(store / 'runs' / rollback['runId'] / 'journal.json', rollback)
            write(store / 'active.json', rollback['afterActive'])
        write(store / 'runs' / original['runId'] / 'journal.json', original)
        before = fingerprint(game)
        code, result = call(game, 'plan', '--action', 'rollback')
        if case == 'normal-pending':
            assert code == 0 and result['status'] == 'ready', result
        else:
            assert code == 2 and result['status'] == 'blocked', result
            assert any(issue['code'] == 'invalid-record' for issue in result['issues']), result
            if case in ('missing-restore-target', 'absent-restore-target'):
                assert any(issue['code'] == 'invalid-record' and issue['detail'] == '복원 원본 경로가 잘못되었습니다.'
                           for issue in result['issues']), result
        assert fingerprint(game) == before
        print('PASS', case, 'target and management hashes unchanged', result['issues'])
    (output / 'result.json').write_text(json.dumps({'passed':len(cases),'cases':cases,'fixtures':fixtures,'calls':calls},
                                                 ensure_ascii=False,indent=2),encoding='utf8')
    print(json.dumps({'passed':len(cases),'receipt':str(output/'result.json')}))


if __name__ == '__main__':
    main()

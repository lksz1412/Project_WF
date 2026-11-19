using System.Security.Cryptography;
using System.Text.Json;

namespace DevilForever.Installer;

public sealed partial class InstallerEngine
{
    private sealed class RecoveryPlan
    {
        public required InstallerResult Result { get; init; }
        public required TargetInfo Target { get; init; }
        public ActiveState? Active { get; init; }
        public string? ActiveHash { get; init; }
        public Journal? Selected { get; set; }
        public bool Resume { get; set; }
        public bool FinalizeOnly { get; set; }
        public ActiveState Goal { get; set; } = new();
        public SortedDictionary<string, FolderSnapshot> Current { get; } = new(StringComparer.Ordinal);
        public SortedDictionary<string, FolderSnapshot> Desired { get; } = new(StringComparer.Ordinal);
        public SortedDictionary<string, FolderSnapshot> Sources { get; } = new(StringComparer.Ordinal);
        public SortedDictionary<string, string> RestoreSources { get; } = new(StringComparer.Ordinal);
    }

    private InstallerResult PlanRecovery(InstallerRequest request, TargetInfo target)
    {
        var result = BuildRecovery(request.PlanAction, target).Result;
        result.Action = "plan";
        return result;
    }

    private RecoveryPlan BuildRecovery(string action, TargetInfo target)
    {
        var store = new InstallationStore(target, catalog);
        var (active, hash, pending) = store.Read();
        var result = new InstallerResult { Action = action, Target = target,
            Package = active?.Package, ManagedState = active?.Package?.Variant ?? "none" };
        var plan = new RecoveryPlan { Result = result, Target = target, Active = active, ActiveHash = hash };
        if (action == "remove")
        {
            if (pending.Count != 0) { Pending(result, pending); return plan; }
            BuildRemoval(plan);
        }
        else
        {
            var restores = pending.Where(item => item.Action == "rollback").ToArray();
            if (restores.Length > 1 || (restores.Length == 1 && pending.Any(item =>
                    item.RunId != restores[0].RunId && item.RunId != restores[0].RevertsRunId)))
                throw new InstallerException("ambiguous-recovery", "서로 연결되지 않은 미완 실행이 있습니다.");
            if (restores.Length == 1)
            {
                plan.Selected = restores[0];
                plan.Resume = true;
                BuildResume(plan, store);
            }
            else if (pending.Count > 1)
                throw new InstallerException("ambiguous-recovery", "복원할 미완 실행을 한 개로 정할 수 없습니다.");
            else if (pending.Count == 1)
            {
                plan.Selected = pending[0];
                BuildReverse(plan, store, false);
            }
            else if (active is null)
                result.Status = "no-change";
            else if (active.LastAction == "rollback")
            {
                var last = store.LoadJournal(active.LastRunId);
                foreach (var (folder, snapshot) in ExpectedFiles(last))
                {
                    var actual = Snapshots.Read(AddonPath(target, folder));
                    plan.Current.Add(folder, actual);
                    if (!Snapshots.Equal(actual, snapshot)) result.Conflicts.Add(new("restore-target-changed", folder));
                }
                plan.Selected = last;
                result.Status = "no-change";
            }
            else
            {
                plan.Selected = store.LoadJournal(active.LastRunId);
                BuildReverse(plan, store, true);
            }
        }
        result.RunId = plan.Selected?.RunId;
        if (result.Conflicts.Count != 0)
        {
            result.Status = "blocked";
            result.ExitCode = 2;
            return plan;
        }
        result.PlanToken = Token(new
        {
            target,
            action,
            activeHash = hash,
            selected = plan.Selected?.RunId,
            journalHash = plan.Selected is null ? null : store.JournalHash(plan.Selected.RunId),
            originalHash = plan.Resume ? store.JournalHash(plan.Selected!.RevertsRunId!) : null,
            current = plan.Current,
            sources = plan.Sources,
            desired = plan.Desired,
            plan.FinalizeOnly,
        });
        if (result.Status == "no-change") return plan;
        WindowsPaths.GameStopped();
        WindowsPaths.WritableDirectory(WindowsPaths.Under(target.Path, InstallationStore.DirectoryName));
        WindowsPaths.WritableDirectory(WindowsPaths.Under(target.Path, "Interface/AddOns"));
        foreach (var change in result.Changes.Where(change => plan.Current[change.Folder].Exists))
            WindowsPaths.MovableDirectory(AddonPath(target, change.Folder));
        result.RequiredBytes = checked((plan.FinalizeOnly ? 0
            : plan.RestoreSources.Keys.Sum(folder => plan.Desired[folder].Bytes)) + 16 * 1024 * 1024);
        if (new DriveInfo(Path.GetPathRoot(target.Path)!).AvailableFreeSpace < result.RequiredBytes)
            throw new InstallerException("insufficient-space", "복원 준비 파일을 저장할 공간이 부족합니다.");
        return plan;
    }

    private static ActiveState CloneActive(ActiveState? source, TargetInfo target) => source is null
        ? new ActiveState { Target = target }
        : JsonSerializer.Deserialize<ActiveState>(InstallerJson.Serialize(source), InstallerJson.Options)!;

    private static SortedDictionary<string, FolderSnapshot> ExpectedFiles(Journal journal)
    {
        var files = new SortedDictionary<string, FolderSnapshot>(StringComparer.Ordinal);
        foreach (var item in journal.AfterActive.Folders) files[item.Key] = item.Value;
        foreach (var item in journal.After) files[item.Key] = item.Value;
        return files;
    }

    private static void BuildRemoval(RecoveryPlan plan)
    {
        plan.Goal = new ActiveState { Target = plan.Target };
        if (plan.Active is null)
        {
            plan.Result.Status = "no-change";
            return;
        }
        foreach (var item in plan.Active.Preserved) plan.Goal.Preserved.Add(item.Key, item.Value);
        plan.Result.Preserved.AddRange(plan.Active.Preserved.Keys);
        foreach (var (folder, expected) in plan.Active.Folders)
        {
            var actual = Snapshots.Read(AddonPath(plan.Target, folder));
            plan.Current.Add(folder, actual);
            if (Snapshots.Equal(actual, expected))
            {
                plan.Desired.Add(folder, new());
                plan.Result.Changes.Add(new(folder, "remove"));
            }
            else
            {
                plan.Desired.Add(folder, actual);
                plan.Goal.Preserved[folder] = "modified-managed-folder";
                plan.Result.Preserved.Add(folder);
            }
        }
        if (plan.Result.Changes.Count == 0) plan.Result.Status = "no-change";
    }

    private static void BuildReverse(RecoveryPlan plan, InstallationStore store, bool completed)
    {
        var original = plan.Selected!;
        if (original.Action == "rollback") throw new InstallerException("invalid-recovery", "복원 실행의 처리 경로가 잘못되었습니다.");
        plan.Goal = CloneActive(original.BeforeActive, plan.Target);
        var afterFiles = ExpectedFiles(original);
        var beforeFiles = new SortedDictionary<string, FolderSnapshot>(StringComparer.Ordinal);
        if (original.BeforeActive is not null)
            foreach (var item in original.BeforeActive.Folders) beforeFiles[item.Key] = item.Value;
        foreach (var item in original.Before) beforeFiles[item.Key] = item.Value;
        foreach (var folder in beforeFiles.Keys.Union(afterFiles.Keys, StringComparer.Ordinal).Order(StringComparer.Ordinal))
        {
            var old = beforeFiles.GetValueOrDefault(folder) ?? new FolderSnapshot();
            var next = afterFiles.GetValueOrDefault(folder) ?? new FolderSnapshot();
            var now = Snapshots.Read(AddonPath(plan.Target, folder));
            plan.Current.Add(folder, now);
            plan.Desired.Add(folder, old);
            var sameOld = Snapshots.Equal(now, old);
            var sameNew = Snapshots.Equal(now, next);
            if (completed && !sameNew || !completed && !sameOld && !sameNew && now.Exists)
            {
                plan.Result.Conflicts.Add(new("restore-target-changed", folder));
                continue;
            }
            if (original.Before.ContainsKey(folder) && old.Exists)
            {
                var relative = $"{InstallationStore.DirectoryName}/runs/{original.RunId}/before/{folder}";
                var backup = Snapshots.Read(WindowsPaths.Under(plan.Target.Path, relative));
                plan.Sources[relative] = backup;
                if (backup.Exists && !Snapshots.Equal(backup, old) || !sameOld && !Snapshots.Equal(backup, old))
                {
                    plan.Result.Conflicts.Add(new("restore-backup-changed", folder));
                    continue;
                }
                if (!sameOld) plan.RestoreSources.Add(folder, relative);
            }
            if (!sameOld)
            {
                if (old.Exists && !plan.RestoreSources.ContainsKey(folder))
                    plan.Result.Conflicts.Add(new("missing-restore-source", folder));
                else plan.Result.Changes.Add(new(folder, "restore"));
            }
        }
        if (!completed && plan.Active is not null
            && InstallerJson.Serialize(plan.Active) == InstallerJson.Serialize(original.AfterActive)
            && afterFiles.All(item => Snapshots.Equal(plan.Current[item.Key], item.Value)))
        {
            plan.FinalizeOnly = true;
            plan.Result.Changes.Clear();
            plan.Result.Issues.Add(new("finalize-completed-run", "이미 적용된 파일과 활성 기록을 확인해 완료 기록만 확정합니다."));
        }
    }

    private static void BuildResume(RecoveryPlan plan, InstallationStore store)
    {
        var selected = plan.Selected!;
        var original = store.LoadJournal(selected.RevertsRunId!);
        if (original.Action == "rollback") throw new InstallerException("invalid-recovery", "중첩된 복원 연결은 허용하지 않습니다.");
        plan.Goal = selected.AfterActive;
        foreach (var (folder, desired) in selected.After)
        {
            var actual = Snapshots.Read(AddonPath(plan.Target, folder));
            plan.Current.Add(folder, actual);
            plan.Desired.Add(folder, desired);
        }
        foreach (var (folder, relative) in selected.RestoreSources)
        {
            var backup = Snapshots.Read(WindowsPaths.Under(plan.Target.Path, relative));
            plan.Sources.Add(relative, backup);
            if (!Snapshots.Equal(backup, selected.After[folder])) plan.Result.Conflicts.Add(new("restore-backup-changed", folder));
            plan.RestoreSources.Add(folder, relative);
        }
        foreach (var folder in selected.Before.Keys)
        {
            if (!IsResumable(plan.Target, selected, folder)) plan.Result.Conflicts.Add(new("restore-progress-conflict", folder));
            else if (!Snapshots.Equal(plan.Current[folder], selected.After[folder])) plan.Result.Changes.Add(new(folder, "resume-restore"));
        }
    }

    private static bool IsResumable(TargetInfo target, Journal journal, string folder)
    {
        var initial = journal.Before[folder];
        var goal = journal.After[folder];
        var current = Snapshots.Read(AddonPath(target, folder));
        if (Snapshots.Equal(initial, goal)) return Snapshots.Equal(current, goal);
        var displaced = Snapshots.Read(WindowsPaths.Under(target.Path,
            $"{InstallationStore.DirectoryName}/runs/{journal.RunId}/displaced/{folder}"));
        var stage = Snapshots.Read(WindowsPaths.Under(target.Path,
            $"{InstallationStore.DirectoryName}/runs/{journal.RunId}/stage/{folder}"));
        if (!IsPartial(stage, goal)) return false;
        if (Snapshots.Equal(current, goal) && (!initial.Exists || Snapshots.Equal(displaced, initial)))
            return !stage.Exists;
        if (Snapshots.Equal(current, initial) && !displaced.Exists) return true;
        return !current.Exists && (initial.Exists ? Snapshots.Equal(displaced, initial) : !displaced.Exists);
    }

    private static bool IsPartial(FolderSnapshot partial, FolderSnapshot expected) =>
        !partial.Exists || expected.Exists && partial.Files.All(item =>
            expected.Files.TryGetValue(item.Key, out var digest) && digest == item.Value)
            && partial.Directories.All(directory => expected.Directories.Contains(directory, StringComparer.Ordinal));

    private InstallerResult ExecuteRecovery(InstallerRequest request, TargetInfo target)
    {
        using var mutex = WindowsPaths.Acquire(target);
        try
        {
            if (WindowsPaths.Target(target.Path) != target)
                throw new InstallerException("target-changed", "대상 경로의 식별값이 바뀌었습니다.");
            var plan = BuildRecovery(request.Action, target);
            if (plan.Result.ExitCode != 0) return plan.Result;
            if (string.IsNullOrEmpty(request.Confirm) || request.Confirm != plan.Result.PlanToken)
                return Fail(plan.Result, "stale-plan", "현재 미리보기의 확인값을 사용해 주세요.");
            if (plan.Result.Status == "no-change") return plan.Result;
            var store = new InstallationStore(target, catalog);
            if (plan.FinalizeOnly)
            {
                plan.Selected!.State = "completed";
                plan.Selected.Failure = null;
                store.Save(plan.Selected);
                plan.Result.Status = "completed";
                return plan.Result;
            }
            return RunRecovery(plan, store, request.Action);
        }
        finally { mutex.ReleaseMutex(); }
    }

    private InstallerResult RunRecovery(RecoveryPlan plan, InstallationStore store, string action)
    {
        var result = plan.Result;
        var id = plan.Resume ? plan.Selected!.RunId : Guid.NewGuid().ToString("N");
        var next = CloneActive(plan.Goal, plan.Target);
        next.LastRunId = id;
        next.LastAction = action;
        var journal = plan.Resume ? plan.Selected! : new Journal
        {
            RunId = id, Action = action, State = "recovery-required", Failure = "preparation-in-progress",
            Target = plan.Target, Package = next.Package, PlanToken = result.PlanToken!,
            BeforeActive = plan.Active, AfterActive = next,
            RevertsRunId = action == "rollback" ? plan.Selected!.RunId : null,
            Before = plan.Current, After = plan.Desired, RestoreSources = plan.RestoreSources,
        };
        if (!plan.Resume)
        {
            foreach (var change in result.Changes)
            {
                var folder = change.Folder;
                var actual = plan.Current[folder];
                var desired = plan.Desired[folder];
                if (actual.Exists)
                {
                    var location = action == "rollback" ? "displaced" : "before";
                    journal.Moves.Add(Move(id, folder, $"Interface/AddOns/{folder}", location, actual, false));
                }
                if (desired.Exists)
                    journal.Moves.Add(Move(id, folder, $"Interface/AddOns/{folder}", "stage", desired, true));
            }
        }
        try
        {
            store.Initialize();
            store.Save(journal);
            foreach (var (folder, relative) in journal.RestoreSources)
            {
                var destination = WindowsPaths.Under(store.RunDirectory(id), "stage/" + folder);
                if (Snapshots.Equal(Snapshots.Read(AddonPath(plan.Target, folder)), journal.After[folder])) continue;
                CopyFolder(WindowsPaths.Under(plan.Target.Path, relative), destination,
                    WindowsPaths.Under(store.RunDirectory(id), "work"), journal.After[folder]);
            }
            WindowsPaths.GameStopped();
            if (WindowsPaths.Target(plan.Target.Path) != plan.Target)
                throw new InstallerException("target-changed", "복원 준비 중 대상 경로가 바뀌었습니다.");
            store.RequireActiveHash(plan.ActiveHash);
            foreach (var (folder, expected) in plan.Current) Snapshots.Require(AddonPath(plan.Target, folder), expected);
            journal.State = action == "rollback" ? "restoring" : "applying";
            journal.Failure = null;
            store.Save(journal);
            foreach (var folder in journal.Before.Keys)
            {
                if (Snapshots.Equal(Snapshots.Read(AddonPath(plan.Target, folder)), journal.After[folder])) continue;
                foreach (var move in journal.Moves.Where(move => move.Folder == folder)) ExecuteMove(plan.Target, store, journal, move);
            }
            journal.State = "verifying";
            store.Save(journal);
            foreach (var (folder, expected) in ExpectedFiles(journal)) Snapshots.Require(AddonPath(plan.Target, folder), expected);
            store.SaveActive(journal.AfterActive);
            if (action == "rollback")
            {
                var original = store.LoadJournal(journal.RevertsRunId!);
                original.State = "restored";
                original.Failure = null;
                store.Save(original);
            }
            journal.State = action == "rollback" ? "restored" : "completed";
            store.Save(journal);
            result.RunId = id;
            result.Status = action == "rollback" ? "restored" : "completed";
            result.Package = journal.AfterActive.Package;
            result.ManagedState = result.Package?.Variant ?? "none";
            return result;
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or InstallerException)
        {
            journal.State = "recovery-required";
            journal.Failure = exception.Message;
            try { store.Save(journal); }
            catch (Exception saveError) when (saveError is IOException or UnauthorizedAccessException or InstallerException)
            { result.Issues.Add(new("journal-write-failed", "현재 폴더와 복원 원본을 보존했습니다.")); }
            result.Status = "recovery-required";
            result.ExitCode = 3;
            result.RunId = id;
            result.Recovery.Add(id);
            result.Issues.Add(new(exception is InstallerException error ? error.Code : "write-failed", exception.Message));
            return result;
        }
    }

    private static void ExecuteMove(TargetInfo target, InstallationStore store, Journal journal, MoveRecord move)
    {
        var source = WindowsPaths.Under(target.Path, move.Source);
        var destination = WindowsPaths.Under(target.Path, move.Destination);
        var currentSource = Snapshots.Read(source);
        var currentDestination = Snapshots.Read(destination);
        if (!currentSource.Exists && Snapshots.Equal(currentDestination, move.Expected))
        {
            move.Intent = true;
            move.Done = true;
            store.Save(journal);
            return;
        }
        if (!Snapshots.Equal(currentSource, move.Expected) || currentDestination.Exists)
            throw new InstallerException("restore-move-conflict", "복원 이동의 현재 위치가 기록과 다릅니다.");
        Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
        move.Intent = true;
        store.Save(journal);
        Directory.Move(source, destination);
        Snapshots.Require(destination, move.Expected);
        move.Done = true;
        store.Save(journal);
    }

    private static void CopyFolder(string source, string destination, string work, FolderSnapshot expected)
    {
        Snapshots.Require(source, expected);
        if (!IsPartial(Snapshots.Read(destination), expected))
            throw new InstallerException("restore-stage-conflict", "복원 준비본에 다른 파일이 있습니다.");
        Directory.CreateDirectory(destination);
        Directory.CreateDirectory(work);
        foreach (var directory in expected.Directories) Directory.CreateDirectory(WindowsPaths.Under(destination, directory));
        foreach (var (relative, digest) in expected.Files)
        {
            var target = WindowsPaths.Under(destination, relative);
            if (File.Exists(target)) continue;
            var original = WindowsPaths.Under(source, relative);
            var temporary = WindowsPaths.Under(work, Guid.NewGuid().ToString("N") + ".tmp");
            using (var input = new FileStream(original, FileMode.Open, FileAccess.Read, FileShare.Read))
            using (var output = new FileStream(temporary, FileMode.CreateNew, FileAccess.Write, FileShare.None))
            {
                input.CopyTo(output);
                output.Flush(true);
            }
            using (var check = new FileStream(temporary, FileMode.Open, FileAccess.Read, FileShare.Read))
                if (Convert.ToHexStringLower(SHA256.HashData(check)) != digest)
                    throw new InstallerException("restore-copy-hash", "복원 준비 파일의 해시가 다릅니다.");
            File.Move(temporary, target);
        }
        Snapshots.Require(source, expected);
        Snapshots.Require(destination, expected);
    }
}

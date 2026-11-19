using System.Text;

namespace DevilForever.Installer;

public sealed partial class InstallerEngine
{
    private readonly Catalog catalog = ApprovedPackage.LoadCatalog();

    public InstallerResult Execute(InstallerRequest request)
    {
        var result = new InstallerResult { Action = request.Action };
        try
        {
            ValidateRequest(request);
            var target = WindowsPaths.Target(request.Game);
            result.Target = target;
            return request.Action switch
            {
                "inspect" => Inspect(target),
                "verify" => Verify(target),
                "plan" when request.PlanAction == "install" => PlanInstall(request, target),
                "plan" => PlanRecovery(request, target),
                "apply" => Apply(request, target),
                "rollback" or "remove" => ExecuteRecovery(request, target),
                _ => Fail(result, "not-implemented", "이 실행판에서 해당 작업은 아직 제공되지 않습니다."),
            };
        }
        catch (InstallerException exception) { return Fail(result, exception.Code, exception.Message); }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException
            or System.Text.Json.JsonException or InvalidDataException or System.ComponentModel.Win32Exception)
        {
            return Fail(result, "input-access", exception.Message);
        }
    }

    private static void ValidateRequest(InstallerRequest request)
    {
        if (request.Action is not ("inspect" or "plan" or "apply" or "verify" or "rollback" or "remove")
            || request.PlanAction is not ("install" or "rollback" or "remove"))
            throw new InstallerException("invalid-action", "지원하는 작업을 선택해 주세요.");
        if (request.Replace.Count != request.Replace.Distinct(StringComparer.OrdinalIgnoreCase).Count())
            throw new InstallerException("duplicate-replace", "교체 폴더를 중복 선택했습니다.");
        foreach (var name in request.Replace) WindowsPaths.Component(name);
        var installing = request.Action == "apply" || request.Action == "plan" && request.PlanAction == "install";
        if (!installing && (request.Package is not null || request.Replace.Count != 0))
            throw new InstallerException("unexpected-option", "이 작업에는 ZIP 또는 교체 선택을 사용하지 않습니다.");
    }

    private InstallerResult Inspect(TargetInfo target)
    {
        var result = new InstallerResult { Action = "inspect", Target = target };
        var (active, _, pending) = new InstallationStore(target, catalog).Read();
        result.Package = active?.Package;
        result.ManagedState = active?.Package?.Variant ?? "none";
        result.RunId = active?.LastRunId;
        if (pending.Count != 0) Pending(result, pending);
        return result;
    }

    private InstallerResult Verify(TargetInfo target)
    {
        var result = new InstallerResult { Action = "verify", Target = target };
        var (active, _, pending) = new InstallationStore(target, catalog).Read();
        if (pending.Count != 0) return Pending(result, pending);
        if (active is null) return Fail(result, "not-managed", "이 위치에 확인할 관리 기록이 없습니다.");
        result.Package = active.Package;
        result.ManagedState = active.Package?.Variant ?? "none";
        foreach (var (folder, expected) in active.Folders)
        {
            if (!Snapshots.Equal(Snapshots.Read(AddonPath(target, folder)), expected))
                result.Conflicts.Add(new("managed-difference", folder));
        }
        result.Preserved.AddRange(active.Preserved.Keys);
        if (result.Conflicts.Count != 0)
        {
            result.Status = "differences";
            result.ExitCode = 4;
        }
        return result;
    }

    private InstallerResult PlanInstall(InstallerRequest request, TargetInfo target)
    {
        using var package = OpenPackage(request);
        return BuildPlan(request, target, package).Result;
    }

    private ApprovedPackage OpenPackage(InstallerRequest request)
    {
        var path = request.Package ?? Path.Combine(AppContext.BaseDirectory,
            catalog.Packages.Single(package => package.Variant == catalog.DefaultVariant).Zip);
        return new ApprovedPackage(Path.GetFullPath(path), catalog);
    }

    private InstallationPlan BuildPlan(InstallerRequest request, TargetInfo target, ApprovedPackage package)
    {
        var result = new InstallerResult
        {
            Action = request.Action == "apply" ? "apply" : "plan",
            Target = target,
            Package = package.Definition.Summary(),
        };
        var (active, activeHash, pending) = new InstallationStore(target, catalog).Read();
        var plan = new InstallationPlan { Result = result, Target = target, Active = active, ActiveHash = activeHash };
        result.ManagedState = active?.Package?.Variant ?? "none";
        if (pending.Count != 0)
        {
            Pending(result, pending);
            return plan;
        }
        if (active?.Package is { } current && Version.Parse(current.Version) > Version.Parse(package.Definition.Version))
            result.Conflicts.Add(new("newer-managed-version", current.Version));
        var desiredNames = package.Folders.Keys.ToHashSet(StringComparer.Ordinal);
        var allNames = catalog.Packages.SelectMany(value => value.Folders)
            .Concat(active?.Folders.Keys ?? Enumerable.Empty<string>()).Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal);
        foreach (var folder in allNames)
        {
            var now = Snapshots.Read(AddonPath(target, folder));
            plan.Current.Add(folder, now);
            FolderSnapshot? expected = null;
            var managed = active?.Folders.TryGetValue(folder, out expected) == true;
            if (managed && !Snapshots.Equal(now, expected!))
            {
                result.Conflicts.Add(new("modified-managed-folder", folder));
                continue;
            }
            if (active?.Preserved.ContainsKey(folder) == true && now.Exists)
            {
                result.Conflicts.Add(new("previously-preserved-folder", folder));
                continue;
            }
            if (!desiredNames.Contains(folder))
            {
                if (now.Exists && !managed) result.Conflicts.Add(new("unmanaged-opposite-variant", folder));
                else if (now.Exists)
                {
                    result.Changes.Add(new(folder, "switch-out"));
                    plan.MovingFolders.Add(folder);
                }
                continue;
            }
            var desired = package.Folders[folder];
            plan.Desired.Add(folder, desired);
            if (!now.Exists)
            {
                result.Changes.Add(new(folder, "add"));
                plan.MovingFolders.Add(folder);
            }
            else if (!managed && !request.Replace.Contains(folder, StringComparer.Ordinal))
                result.Conflicts.Add(new("unmanaged-overlap", folder));
            else if (!managed || !Snapshots.Equal(now, desired))
            {
                result.Changes.Add(new(folder, managed ? "replace" : "take-over"));
                plan.MovingFolders.Add(folder);
            }
        }
        foreach (var selected in request.Replace)
        {
            if (!desiredNames.Contains(selected) || !plan.Current[selected].Exists || active?.Folders.ContainsKey(selected) == true)
                result.Conflicts.Add(new("invalid-replace-choice", selected));
        }
        var addonRoot = WindowsPaths.Under(target.Path, "Interface/AddOns");
        if (Directory.Exists(addonRoot))
        {
            foreach (var folder in Directory.EnumerateFileSystemEntries(addonRoot).Select(Path.GetFileName))
                if (folder is not null && !plan.Current.ContainsKey(folder)) result.Preserved.Add(folder);
        }
        result.RequiredBytes = checked(package.Definition.AddonBytes + 16 * 1024 * 1024);
        if (result.Conflicts.Count != 0)
        {
            result.Status = "blocked";
            result.ExitCode = 2;
            return plan;
        }
        WindowsPaths.GameStopped();
        result.PlanToken = Token(new
        {
            target,
            action = "install",
            package = package.Definition.Sha256,
            replacements = request.Replace.Order(StringComparer.Ordinal).ToArray(),
            activeHash,
            folders = plan.Current,
        });
        var samePackage = active?.Package == package.Definition.Summary();
        if (result.Changes.Count == 0 && samePackage)
        {
            result.Status = "no-change";
            result.RequiredBytes = 0;
            return plan;
        }
        WindowsPaths.WritableDirectory(addonRoot);
        WindowsPaths.WritableDirectory(WindowsPaths.Under(target.Path, InstallationStore.DirectoryName));
        foreach (var folder in plan.MovingFolders.Where(folder => plan.Current[folder].Exists))
            WindowsPaths.MovableDirectory(AddonPath(target, folder));
        if (new DriveInfo(Path.GetPathRoot(target.Path)!).AvailableFreeSpace < result.RequiredBytes)
            throw new InstallerException("insufficient-space", "준비 파일을 저장할 공간이 부족합니다.");
        return plan;
    }

    private InstallerResult Apply(InstallerRequest request, TargetInfo target)
    {
        using var mutex = WindowsPaths.Acquire(target);
        try
        {
            using var package = OpenPackage(request);
            var currentTarget = WindowsPaths.Target(target.Path);
            if (currentTarget != target) throw new InstallerException("target-changed", "게임 경로의 식별값이 바뀌었습니다.");
            var plan = BuildPlan(request, currentTarget, package);
            if (plan.Result.ExitCode != 0) return plan.Result;
            if (request.Confirm != plan.Result.PlanToken || string.IsNullOrEmpty(request.Confirm))
                return Fail(plan.Result, "stale-plan", "미리보기를 다시 확인하고 현재 확인값으로 적용해 주세요.");
            if (plan.Result.Status == "no-change") return plan.Result;
            return ApplyPlan(plan, package);
        }
        finally { mutex.ReleaseMutex(); }
    }

    private InstallerResult ApplyPlan(InstallationPlan plan, ApprovedPackage package)
    {
        var store = new InstallationStore(plan.Target, catalog);
        var result = plan.Result;
        var id = Guid.NewGuid().ToString("N");
        var next = new ActiveState
        {
            Target = plan.Target,
            LastRunId = id,
            LastAction = "install",
            Package = package.Definition.Summary(),
            Folders = package.Folders,
        };
        var journal = new Journal
        {
            RunId = id,
            Target = plan.Target,
            Package = next.Package,
            PlanToken = result.PlanToken!,
            BeforeActive = plan.Active,
            AfterActive = next,
            State = "recovery-required",
            Failure = "preparation-in-progress",
        };
        foreach (var folder in plan.MovingFolders)
        {
            var before = plan.Current[folder];
            var after = plan.Desired.GetValueOrDefault(folder) ?? new FolderSnapshot();
            journal.Before.Add(folder, before);
            journal.After.Add(folder, after);
            if (before.Exists)
                journal.Moves.Add(Move(id, folder, $"Interface/AddOns/{folder}", "before", before, false));
            if (after.Exists)
                journal.Moves.Add(Move(id, folder, $"Interface/AddOns/{folder}", "stage", after, true));
        }
        try
        {
            store.Initialize();
            store.Save(journal);
            var runDirectory = store.RunDirectory(id);
            package.Stage(WindowsPaths.Under(runDirectory, "stage"), WindowsPaths.Under(runDirectory, "package"));
            journal.State = "prepared";
            journal.Failure = null;
            store.Save(journal);
            WindowsPaths.GameStopped();
            if (WindowsPaths.Target(plan.Target.Path) != plan.Target)
                throw new InstallerException("target-changed", "준비 중 게임 경로의 식별값이 바뀌었습니다.");
            store.RequireActiveHash(plan.ActiveHash);
            foreach (var (folder, expected) in plan.Current) Snapshots.Require(AddonPath(plan.Target, folder), expected);
            Directory.CreateDirectory(WindowsPaths.Under(plan.Target.Path, "Interface/AddOns"));
            journal.State = "applying";
            store.Save(journal);
            foreach (var move in journal.Moves)
            {
                var source = WindowsPaths.Under(plan.Target.Path, move.Source);
                var destination = WindowsPaths.Under(plan.Target.Path, move.Destination);
                Snapshots.Require(source, move.Expected);
                if (Path.Exists(destination)) throw new InstallerException("move-conflict", "옮길 위치에 기존 항목이 있습니다.");
                Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
                move.Intent = true;
                store.Save(journal);
                Directory.Move(source, destination);
                Snapshots.Require(destination, move.Expected);
                move.Done = true;
                store.Save(journal);
            }
            journal.State = "verifying";
            store.Save(journal);
            foreach (var (folder, expected) in package.Folders) Snapshots.Require(AddonPath(plan.Target, folder), expected);
            foreach (var (folder, expected) in journal.After.Where(value => !value.Value.Exists))
                Snapshots.Require(AddonPath(plan.Target, folder), expected);
            store.SaveActive(next);
            journal.State = "completed";
            store.Save(journal);
            result.Status = "completed";
            result.ManagedState = next.Package!.Variant;
            result.RunId = id;
            return result;
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or InstallerException)
        {
            journal.State = "recovery-required";
            journal.Failure = exception.Message;
            try { store.Save(journal); }
            catch (Exception saveError) when (saveError is IOException or UnauthorizedAccessException or InstallerException)
            {
                result.Issues.Add(new("journal-write-failed", "원래 상태와 준비본을 보존했습니다. 기록 저장을 확인해야 합니다."));
            }
            result.Status = "recovery-required";
            result.ExitCode = 3;
            result.RunId = id;
            result.Recovery.Add(id);
            result.Issues.Add(new(exception is InstallerException error ? error.Code : "write-failed", exception.Message));
            return result;
        }
    }

    private static MoveRecord Move(string id, string folder, string addon, string location, FolderSnapshot expected, bool fromStage)
    {
        var managed = $"{InstallationStore.DirectoryName}/runs/{id}/{location}/{folder}";
        return new MoveRecord { Folder = folder, Source = fromStage ? managed : addon,
            Destination = fromStage ? addon : managed, Expected = expected };
    }

    private static string AddonPath(TargetInfo target, string folder) => WindowsPaths.Under(target.Path, "Interface/AddOns/" + folder);
    private static string Token<T>(T value) => WindowsPaths.Hash(Encoding.UTF8.GetBytes(InstallerJson.Serialize(value)));

    private static InstallerResult Pending(InstallerResult result, IEnumerable<Journal> pending)
    {
        result.Status = "recovery-required";
        result.ExitCode = 3;
        result.Recovery.AddRange(pending.Select(value => value.RunId));
        result.Issues.Add(new("unfinished-run", "미완 실행의 상태를 확인하고 복원해 주세요."));
        return result;
    }

    private static InstallerResult Fail(InstallerResult result, string code, string detail)
    {
        result.Status = "blocked";
        result.ExitCode = 2;
        result.Issues.Add(new(code, detail));
        return result;
    }
}

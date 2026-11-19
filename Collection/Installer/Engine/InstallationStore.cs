using System.Security.Cryptography;
using System.Text;

namespace DevilForever.Installer;

internal sealed class InstallationStore(TargetInfo target, Catalog catalog)
{
    public const string DirectoryName = "DevilForever-installer";
    public string Root => WindowsPaths.Under(target.Path, DirectoryName);
    public string ActivePath => WindowsPaths.Under(Root, "active.json");

    public (ActiveState? Active, string? Hash, List<Journal> Pending) Read()
    {
        if (!Path.Exists(Root)) return (null, null, []);
        var marker = WindowsPaths.Under(Root, "format.json");
        if (!File.Exists(marker))
            throw new InstallerException("unrecognized-store", "동일 이름의 기존 폴더에 설치 기록이 없습니다.");
        var format = Read<StoreFormat>(marker);
        if (format.Schema != "devil-forever-installer-store/1" || format.Target != target)
            throw new InstallerException("invalid-record", "관리 폴더의 대상 식별값이 다릅니다.");
        var allowed = new HashSet<string>(StringComparer.Ordinal) { "format.json", "active.json", "runs" };
        foreach (var entry in Directory.EnumerateFileSystemEntries(Root))
        {
            if (!allowed.Contains(Path.GetFileName(entry)) && !IsAtomicRemainder(entry))
                throw new InstallerException("unrecognized-store", "관리 폴더에 확인되지 않은 항목이 있습니다.");
        }
        ActiveState? active = null;
        string? hash = null;
        if (File.Exists(ActivePath))
        {
            active = Read<ActiveState>(ActivePath);
            ValidateActive(active);
            using var file = new FileStream(ActivePath, FileMode.Open, FileAccess.Read, FileShare.Read);
            hash = Convert.ToHexStringLower(SHA256.HashData(file));
        }
        var pending = new List<Journal>();
        var runs = WindowsPaths.Under(Root, "runs");
        var journals = new Dictionary<string, Journal>(StringComparer.Ordinal);
        if (Directory.Exists(runs))
        {
            WindowsPaths.CheckChildren(runs);
            foreach (var entry in Directory.EnumerateFileSystemEntries(runs))
            {
                var id = Path.GetFileName(entry);
                ValidateId(id);
                WindowsPaths.CheckAncestors(entry);
                var journal = Read<Journal>(WindowsPaths.Under(entry, "journal.json"));
                ValidateJournal(journal, id);
                journals.Add(id, journal);
                if (journal.State is not ("completed" or "restored")) pending.Add(journal);
            }
        }
        if (active is not null && (!journals.TryGetValue(active.LastRunId, out var last)
            || last.Action != active.LastAction
            || InstallerJson.Serialize(active) != InstallerJson.Serialize(last.AfterActive)))
            throw new InstallerException("invalid-record", "활성 기록의 완료 실행을 찾지 못했습니다.");
        return (active, hash, pending);
    }

    public void Initialize()
    {
        WindowsPaths.CheckAncestors(Root);
        if (Path.Exists(Root)) return;
        Directory.CreateDirectory(Root);
        Write(WindowsPaths.Under(Root, "format.json"), new StoreFormat { Target = target });
    }

    public string RunDirectory(string id)
    {
        ValidateId(id);
        return WindowsPaths.Under(Root, "runs/" + id);
    }

    public void Save(Journal journal) => Write(WindowsPaths.Under(RunDirectory(journal.RunId), "journal.json"), journal);
    public void SaveActive(ActiveState state) => Write(ActivePath, state);

    public Journal LoadJournal(string id)
    {
        var journal = Read<Journal>(WindowsPaths.Under(RunDirectory(id), "journal.json"));
        ValidateJournal(journal, id);
        return journal;
    }

    public string JournalHash(string id)
    {
        using var stream = new FileStream(WindowsPaths.Under(RunDirectory(id), "journal.json"),
            FileMode.Open, FileAccess.Read, FileShare.Read);
        return Convert.ToHexStringLower(SHA256.HashData(stream));
    }

    public void RequireActiveHash(string? expected)
    {
        string? current = null;
        if (File.Exists(ActivePath))
        {
            using var stream = new FileStream(ActivePath, FileMode.Open, FileAccess.Read, FileShare.Read);
            current = Convert.ToHexStringLower(SHA256.HashData(stream));
        }
        if (current != expected) throw new InstallerException("active-changed", "준비 중 활성 기록이 바뀌었습니다.");
    }

    private static bool IsAtomicRemainder(string path)
    {
        var name = Path.GetFileName(path);
        const string prefix = "active.json.";
        if (!name.StartsWith(prefix, StringComparison.Ordinal) || !name.EndsWith(".tmp", StringComparison.Ordinal)
            || name.Length != prefix.Length + 32 + 4) return false;
        if (name.AsSpan(prefix.Length, 32).ContainsAnyExcept("0123456789abcdefABCDEF")) return false;
        var attributes = File.GetAttributes(path);
        return (attributes & (FileAttributes.Directory | FileAttributes.ReparsePoint)) == 0;
    }

    public static T Read<T>(string path)
    {
        WindowsPaths.CheckAncestors(path);
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
        return InstallerJson.Read<T>(stream);
    }

    public static void Write<T>(string path, T value)
    {
        WindowsPaths.CheckAncestors(path);
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        var temporary = path + "." + Guid.NewGuid().ToString("N") + ".tmp";
        using (var output = new FileStream(temporary, FileMode.CreateNew, FileAccess.Write, FileShare.None))
        {
            output.Write(Encoding.UTF8.GetBytes(InstallerJson.Serialize(value)));
            output.Flush(true);
        }
        File.Move(temporary, path, true);
    }

    private void ValidateActive(ActiveState active)
    {
        if (active.Schema != "devil-forever-installer-active/1" || active.Target != target
            || active.Folders is null || active.Preserved is null
            || active.LastAction is not ("install" or "remove" or "rollback"))
            throw new InstallerException("invalid-record", "활성 설치 기록의 형식이 잘못되었습니다.");
        ValidateId(active.LastRunId);
        if (active.Package is not null)
        {
            if (!Version.TryParse(active.Package.Version, out _)
                || !catalog.Packages.Any(package => package.Variant == active.Package.Variant))
                throw new InstallerException("invalid-record", "활성 기록의 판이 잘못되었습니다.");
        }
        var permitted = catalog.Packages.SelectMany(package => package.Folders).ToHashSet(StringComparer.Ordinal);
        foreach (var (folder, snapshot) in active.Folders)
        {
            WindowsPaths.Component(folder);
            if (!permitted.Contains(folder) || snapshot is null || !snapshot.Exists)
                throw new InstallerException("invalid-record", "관리 폴더 기록이 승인 범위를 벗어납니다.");
            Snapshots.Validate(snapshot);
        }
        foreach (var folder in active.Preserved.Keys)
        {
            if (!permitted.Contains(folder))
                throw new InstallerException("invalid-record", "보존 기록의 폴더가 승인 범위를 벗어납니다.");
        }
        if (active.Folders.Keys.Intersect(active.Preserved.Keys, StringComparer.Ordinal).Any())
            throw new InstallerException("invalid-record", "관리와 보존 폴더가 겹칩니다.");
    }

    private void ValidateJournal(Journal journal, string id)
    {
        if (journal.Schema != "devil-forever-installer-journal/1" || journal.RunId != id
            || journal.AfterActive is null || journal.Before is null || journal.After is null || journal.Moves is null
            || journal.RestoreSources is null
            || journal.Target != target || journal.Action is not ("install" or "remove" or "rollback")
            || journal.State is not ("prepared" or "applying" or "verifying" or "completed"
                or "recovery-required" or "restoring" or "restored"))
            throw new InstallerException("invalid-record", "실행 기록의 형식이 잘못되었습니다.");
        if (journal.BeforeActive is not null) ValidateActive(journal.BeforeActive);
        ValidateActive(journal.AfterActive);
        if (journal.AfterActive.LastRunId != id || journal.AfterActive.LastAction != journal.Action)
            throw new InstallerException("invalid-record", "실행 기록과 예정 활성 기록의 연결이 다릅니다.");
        var folders = catalog.Packages.SelectMany(package => package.Folders).ToHashSet(StringComparer.Ordinal);
        foreach (var (folder, snapshot) in journal.Before.Concat(journal.After))
        {
            if (!folders.Contains(folder)) throw new InstallerException("invalid-record", "실행 폴더가 승인 범위를 벗어납니다.");
            Snapshots.Validate(snapshot);
        }
        if (!journal.Before.Keys.ToHashSet(StringComparer.Ordinal).SetEquals(journal.After.Keys))
            throw new InstallerException("invalid-record", "이전 상태와 이후 상태의 폴더 목록이 다릅니다.");
        if (journal.Action != "rollback" && journal.RestoreSources.Count != 0)
            throw new InstallerException("invalid-record", "복원 이외의 실행에 복원 원본이 있습니다.");
        foreach (var move in journal.Moves)
        {
            if (move is null) throw new InstallerException("invalid-record", "비어 있는 이동 기록입니다.");
            if (!folders.Contains(move.Folder)) throw new InstallerException("invalid-record", "이동 폴더가 승인 범위를 벗어납니다.");
            ValidateMovePath(move.Source, id, move.Folder);
            ValidateMovePath(move.Destination, id, move.Folder);
            Snapshots.Validate(move.Expected);
        }
        if (journal.Action == "rollback")
        {
            ValidateId(journal.RevertsRunId!);
            foreach (var (folder, source) in journal.RestoreSources)
            {
                if (!folders.Contains(folder) || !journal.After.TryGetValue(folder, out var expected) || !expected.Exists
                    || source != $"{DirectoryName}/runs/{journal.RevertsRunId}/before/{folder}")
                    throw new InstallerException("invalid-record", "복원 원본 경로가 잘못되었습니다.");
            }
        }
    }

    private static void ValidateMovePath(string path, string id, string folder)
    {
        var choices = new[] { $"Interface/AddOns/{folder}",
            $"{DirectoryName}/runs/{id}/stage/{folder}", $"{DirectoryName}/runs/{id}/before/{folder}",
            $"{DirectoryName}/runs/{id}/displaced/{folder}" };
        if (!choices.Contains(path, StringComparer.Ordinal))
            throw new InstallerException("invalid-record", "실행 기록의 이동 경로가 잘못되었습니다.");
    }

    public static void ValidateId(string id)
    {
        if (string.IsNullOrEmpty(id) || id.Length != 32 || id.Any(character => !Uri.IsHexDigit(character)))
            throw new InstallerException("invalid-record", "실행 ID가 잘못되었습니다.");
    }

    private sealed class StoreFormat
    {
        public string Schema { get; set; } = "devil-forever-installer-store/1";
        public TargetInfo Target { get; set; } = new("", "");
    }
}

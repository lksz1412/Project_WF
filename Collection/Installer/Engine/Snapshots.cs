using System.Security.Cryptography;

namespace DevilForever.Installer;

internal static class Snapshots
{
    public static FolderSnapshot Read(string path)
    {
        WindowsPaths.CheckAncestors(path);
        if (File.Exists(path)) throw new InstallerException("path-type", "애드온 폴더 위치에 파일이 있습니다.");
        if (!Directory.Exists(path)) return new();
        var snapshot = new FolderSnapshot { Exists = true };
        Walk(path, path, snapshot);
        snapshot.Directories.Sort(StringComparer.Ordinal);
        return snapshot;
    }

    private static void Walk(string root, string current, FolderSnapshot snapshot)
    {
        WindowsPaths.CheckChildren(current);
        foreach (var path in Directory.EnumerateFileSystemEntries(current).Order(StringComparer.Ordinal))
        {
            WindowsPaths.Component(Path.GetFileName(path));
            var attributes = File.GetAttributes(path);
            if ((attributes & FileAttributes.ReparsePoint) != 0)
                throw new InstallerException("linked-path", "관리할 폴더에 링크 또는 재분석 지점이 있습니다.");
            var relative = Path.GetRelativePath(root, path).Replace('\\', '/');
            if ((attributes & FileAttributes.Directory) != 0)
            {
                snapshot.Directories.Add(relative);
                Walk(root, path, snapshot);
            }
            else
            {
                using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
                snapshot.Bytes += stream.Length;
                snapshot.Files.Add(relative, Convert.ToHexStringLower(SHA256.HashData(stream)));
            }
        }
    }

    public static bool Equal(FolderSnapshot a, FolderSnapshot b) =>
        a.Exists == b.Exists && a.Bytes == b.Bytes && a.Files.Count == b.Files.Count
        && a.Files.All(item => b.Files.TryGetValue(item.Key, out var digest) && digest == item.Value)
        && a.Directories.SequenceEqual(b.Directories);

    public static void Require(string path, FolderSnapshot expected)
    {
        if (!Equal(Read(path), expected))
            throw new InstallerException("folder-changed", "미리보기 또는 이동 기록 뒤 폴더 내용이 달라졌습니다.");
    }

    public static void Validate(FolderSnapshot value)
    {
        if (value is null || value.Files is null || value.Directories is null)
            throw new InstallerException("invalid-record", "폴더 기록이 비어 있습니다.");
        if (!value.Exists && (value.Bytes != 0 || value.Files.Count != 0 || value.Directories.Count != 0))
            throw new InstallerException("invalid-record", "없는 폴더의 기록에 파일이 있습니다.");
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var name in value.Directories)
        {
            Relative(name);
            if (!names.Add(name)) throw new InstallerException("invalid-record", "기록의 폴더 이름이 겹칩니다.");
        }
        foreach (var (name, digest) in value.Files)
        {
            Relative(name);
            if (!names.Add(name) || digest is null || digest.Length != 64 || digest.Any(character => !Uri.IsHexDigit(character)))
                throw new InstallerException("invalid-record", "기록의 파일 이름 또는 해시가 잘못되었습니다.");
        }
        if (value.Bytes < 0) throw new InstallerException("invalid-record", "기록의 크기가 잘못되었습니다.");
    }

    public static void Relative(string relative)
    {
        if (string.IsNullOrEmpty(relative))
            throw new InstallerException("unsafe-path", "상대 경로가 비어 있습니다.");
        foreach (var part in relative.Split('/')) WindowsPaths.Component(part);
    }
}

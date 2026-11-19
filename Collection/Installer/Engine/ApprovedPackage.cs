using System.IO.Compression;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace DevilForever.Installer;

internal sealed class ApprovedPackage : IDisposable
{
    private const string AddonPrefix = "Interface/AddOns/";
    private const string MetadataPrefix = "DevilForever-install/";
    private const string SumsName = MetadataPrefix + "SHA256SUMS.txt";
    private readonly FileStream stream;
    private readonly ZipArchive archive;
    private readonly Dictionary<string, string> hashes = new(StringComparer.Ordinal);
    private readonly Dictionary<string, ZipArchiveEntry> files = new(StringComparer.Ordinal);
    public CatalogPackage Definition { get; }
    public SortedDictionary<string, FolderSnapshot> Folders { get; } = new(StringComparer.Ordinal);

    public static Catalog LoadCatalog()
    {
        using var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("DevilForever.ReleaseCatalog.json")
            ?? throw new InstallerException("missing-catalog", "실행 파일의 승인 카탈로그가 없습니다.");
        var catalog = InstallerJson.Read<Catalog>(stream);
        if (catalog.Schema != "devil-forever-installer-catalog/1" || catalog.Interface != 16001
            || catalog.DefaultVariant != "pitbull4" || catalog.Packages.Count != 2
            || !catalog.Packages.Select(value => value.Variant).Order().SequenceEqual(new[] { "fuf", "pitbull4" }))
            throw new InstallerException("invalid-catalog", "설치기 승인 카탈로그가 잘못되었습니다.");
        foreach (var package in catalog.Packages)
        {
            if (package.Sha256.Length != 64 || package.ZipBytes <= 0 || !Version.TryParse(package.Version, out _)
                || package.Folders.Count != package.Folders.Distinct(StringComparer.OrdinalIgnoreCase).Count())
                throw new InstallerException("invalid-catalog", "카탈로그의 판 또는 폴더가 잘못되었습니다.");
            foreach (var folder in package.Folders) WindowsPaths.Component(folder);
        }
        return catalog;
    }

    public ApprovedPackage(string path, Catalog catalog)
    {
        stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
        ZipArchive? opened = null;
        try
        {
            WindowsPaths.CheckAncestors(Path.GetFullPath(path));
            var digest = Convert.ToHexStringLower(SHA256.HashData(stream));
            Definition = catalog.Packages.SingleOrDefault(value => value.Sha256 == digest && value.ZipBytes == stream.Length)
                ?? throw new InstallerException("unapproved-package", "승인한 단독판 ZIP의 해시와 일치하지 않습니다.");
            stream.Position = 0;
            opened = new ZipArchive(stream, ZipArchiveMode.Read, true);
            archive = opened;
            ReadEntries();
            ReadChecksums();
            ReadManifest(catalog);
            VerifyEntries();
        }
        catch
        {
            opened?.Dispose();
            stream.Dispose();
            throw;
        }
    }

    private void ReadEntries()
    {
        var allNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var directories = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var entry in archive.Entries)
        {
            var directory = entry.FullName.EndsWith('/');
            var name = directory ? entry.FullName[..^1] : entry.FullName;
            Snapshots.Relative(name);
            if (!allNames.Add(name)) throw new InstallerException("archive-collision", "압축 항목 이름이 겹칩니다.");
            var mode = (entry.ExternalAttributes >> 16) & 0xf000;
            if ((directory && mode is not (0 or 0x4000)) || (!directory && mode is not (0 or 0x8000))
                || ((FileAttributes)entry.ExternalAttributes & FileAttributes.ReparsePoint) != 0)
                throw new InstallerException("archive-file-type", "링크 또는 특수 파일을 포함한 ZIP입니다.");
            if (directory)
            {
                if (entry.FullName is not ("Interface/" or "Interface/AddOns/" or "DevilForever-install/"))
                    throw new InstallerException("archive-directory", "승인 포맷 밖의 디렉터리입니다.");
                directories.Add(name);
                continue;
            }
            if (name.StartsWith(AddonPrefix, StringComparison.Ordinal))
            {
                var relative = name[AddonPrefix.Length..];
                var slash = relative.IndexOf('/');
                if (slash < 1 || !Definition.Folders.Contains(relative[..slash], StringComparer.Ordinal))
                    throw new InstallerException("archive-folder", "승인 목록 밖의 애드온 폴더입니다.");
            }
            else if (!name.StartsWith(MetadataPrefix, StringComparison.Ordinal)
                || name[MetadataPrefix.Length..].Contains('/'))
                throw new InstallerException("archive-path", "승인 포맷 밖의 압축 경로입니다.");
            files.Add(name, entry);
            var parent = Path.GetDirectoryName(name.Replace('/', Path.DirectorySeparatorChar));
            while (!string.IsNullOrEmpty(parent))
            {
                directories.Add(parent.Replace(Path.DirectorySeparatorChar, '/'));
                parent = Path.GetDirectoryName(parent);
            }
        }
        if (files.Keys.Any(name => directories.Contains(name)))
            throw new InstallerException("archive-collision", "압축 파일과 디렉터리의 경로가 겹칩니다.");
    }

    private void ReadChecksums()
    {
        if (!files.TryGetValue(SumsName, out var sums))
            throw new InstallerException("missing-checksums", "ZIP의 파일 해시 목록이 없습니다.");
        using var reader = new StreamReader(sums.Open(), new UTF8Encoding(false, true));
        while (reader.ReadLine() is { } line)
        {
            if (line.Length < 67 || line[64..66] != "  ")
                throw new InstallerException("invalid-checksums", "파일 해시 목록의 형식이 잘못되었습니다.");
            var digest = line[..64];
            var name = line[66..];
            if (digest.Any(character => !Uri.IsHexDigit(character)) || !files.ContainsKey(name)
                || name == SumsName || !hashes.TryAdd(name, digest.ToLowerInvariant()))
                throw new InstallerException("invalid-checksums", "파일 해시 목록의 항목이 잘못되었습니다.");
        }
        if (hashes.Count != files.Count - 1)
            throw new InstallerException("invalid-checksums", "압축 파일의 해시가 빠졌습니다.");
    }

    private void ReadManifest(Catalog catalog)
    {
        if (!files.TryGetValue(MetadataPrefix + "manifest.json", out var manifestEntry))
            throw new InstallerException("missing-manifest", "ZIP의 매니페스트가 없습니다.");
        using var input = manifestEntry.Open();
        using var document = JsonDocument.Parse(input);
        var root = document.RootElement;
        var folders = root.GetProperty("folders").EnumerateArray()
            .Select(value => value.GetProperty("folder").GetString() ?? "").Order(StringComparer.Ordinal).ToArray();
        if (root.GetProperty("schema").GetString() != "devil-forever-install-manifest/1"
            || root.GetProperty("name").GetString() != "DevilForever"
            || root.GetProperty("interface").GetInt32() != catalog.Interface
            || root.GetProperty("version").GetString() != Definition.Version
            || root.GetProperty("unit_frames").GetString() != Definition.Variant
            || !folders.SequenceEqual(Definition.Folders.Order(StringComparer.Ordinal)))
            throw new InstallerException("manifest-mismatch", "ZIP 매니페스트가 승인판과 다릅니다.");
    }

    private void VerifyEntries()
    {
        foreach (var folder in Definition.Folders) Folders.Add(folder, new FolderSnapshot { Exists = true });
        foreach (var (name, entry) in files)
        {
            if (name == SumsName) continue;
            using var content = entry.Open();
            var digest = Convert.ToHexStringLower(SHA256.HashData(content));
            if (digest != hashes[name])
                throw new InstallerException("member-hash", "ZIP 안의 파일이 해시 목록과 다릅니다.");
            if (!name.StartsWith(AddonPrefix, StringComparison.Ordinal)) continue;
            var relative = name[AddonPrefix.Length..];
            var slash = relative.IndexOf('/');
            var folder = Folders[relative[..slash]];
            var file = relative[(slash + 1)..];
            folder.Files.Add(file, digest);
            folder.Bytes += entry.Length;
            var parent = Path.GetDirectoryName(file.Replace('/', Path.DirectorySeparatorChar));
            while (!string.IsNullOrEmpty(parent))
            {
                var directory = parent.Replace(Path.DirectorySeparatorChar, '/');
                if (!folder.Directories.Contains(directory, StringComparer.Ordinal)) folder.Directories.Add(directory);
                parent = Path.GetDirectoryName(parent);
            }
        }
        foreach (var folder in Folders.Values)
        {
            folder.Directories.Sort(StringComparer.Ordinal);
            if (folder.Files.Count == 0) throw new InstallerException("empty-package-folder", "빈 애드온 폴더입니다.");
        }
        if (Folders.Sum(value => value.Value.Bytes) != Definition.AddonBytes
            || Folders.Sum(value => value.Value.Files.Count) != Definition.AddonFiles)
            throw new InstallerException("package-counts", "승인판의 파일 수 또는 크기가 다릅니다.");
    }

    public void Stage(string stage, string metadata)
    {
        foreach (var (name, entry) in files)
        {
            var addon = name.StartsWith(AddonPrefix, StringComparison.Ordinal);
            var relative = name[(addon ? AddonPrefix.Length : MetadataPrefix.Length)..];
            var path = WindowsPaths.Under(addon ? stage : metadata, relative);
            Directory.CreateDirectory(Path.GetDirectoryName(path)!);
            using var input = entry.Open();
            using (var output = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.None))
            {
                input.CopyTo(output);
                output.Flush(true);
            }
            if (name != SumsName)
            {
                using var output = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read);
                if (Convert.ToHexStringLower(SHA256.HashData(output)) != hashes[name])
                    throw new InstallerException("stage-hash", "준비 파일의 해시가 다릅니다.");
            }
        }
        foreach (var (folder, expected) in Folders) Snapshots.Require(WindowsPaths.Under(stage, folder), expected);
    }

    public void Dispose()
    {
        archive.Dispose();
        stream.Dispose();
    }
}

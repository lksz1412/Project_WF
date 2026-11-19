using System.Text.Json;
using System.Text.Json.Serialization;

namespace DevilForever.Installer;

public sealed class InstallerRequest
{
    public string Action { get; set; } = "inspect";
    public string PlanAction { get; set; } = "install";
    public string Game { get; set; } = "";
    public string? Package { get; set; }
    public List<string> Replace { get; set; } = [];
    public string? Confirm { get; set; }
}

public sealed class InstallerResult
{
    public string Schema { get; set; } = "devil-forever-installer-result/1";
    public string Action { get; set; } = "";
    public string Status { get; set; } = "ready";
    public int ExitCode { get; set; }
    public TargetInfo? Target { get; set; }
    public PackageInfo? Package { get; set; }
    public string? RunId { get; set; }
    public string? PlanToken { get; set; }
    public List<FolderChange> Changes { get; set; } = [];
    public List<string> Preserved { get; set; } = [];
    public List<Problem> Conflicts { get; set; } = [];
    public List<Problem> Issues { get; set; } = [];
    public List<string> Recovery { get; set; } = [];
    public long RequiredBytes { get; set; }
    public string ManagedState { get; set; } = "none";
}

public sealed record Problem(string Code, string Detail);
public sealed record TargetInfo(string Path, string Identity);
public sealed record PackageInfo(string Variant, string Version, string Sha256);
public sealed record FolderChange(string Folder, string Operation);

public sealed class Catalog
{
    public string Schema { get; set; } = "";
    public int Interface { get; set; }
    public string DefaultVariant { get; set; } = "";
    public List<CatalogPackage> Packages { get; set; } = [];
}

public sealed class CatalogPackage
{
    public string Variant { get; set; } = "";
    public string Version { get; set; } = "";
    public string Zip { get; set; } = "";
    public string Sha256 { get; set; } = "";
    public long ZipBytes { get; set; }
    public long AddonBytes { get; set; }
    public int AddonFiles { get; set; }
    public List<string> Folders { get; set; } = [];
    public PackageInfo Summary() => new(Variant, Version, Sha256);
}

public sealed class FolderSnapshot
{
    public bool Exists { get; set; }
    public SortedDictionary<string, string> Files { get; set; } = new(StringComparer.Ordinal);
    public List<string> Directories { get; set; } = [];
    public long Bytes { get; set; }
}

public sealed class ActiveState
{
    public string Schema { get; set; } = "devil-forever-installer-active/1";
    public TargetInfo Target { get; set; } = new("", "");
    public string LastRunId { get; set; } = "";
    public string LastAction { get; set; } = "";
    public PackageInfo? Package { get; set; }
    public SortedDictionary<string, FolderSnapshot> Folders { get; set; } = new(StringComparer.Ordinal);
    public SortedDictionary<string, string> Preserved { get; set; } = new(StringComparer.Ordinal);
}

public sealed class MoveRecord
{
    public string Folder { get; set; } = "";
    public string Source { get; set; } = "";
    public string Destination { get; set; } = "";
    public FolderSnapshot Expected { get; set; } = new();
    public bool Intent { get; set; }
    public bool Done { get; set; }
}

public sealed class Journal
{
    public string Schema { get; set; } = "devil-forever-installer-journal/1";
    public string RunId { get; set; } = "";
    public string Action { get; set; } = "install";
    public string State { get; set; } = "prepared";
    public TargetInfo Target { get; set; } = new("", "");
    public PackageInfo? Package { get; set; }
    public string PlanToken { get; set; } = "";
    public string? RevertsRunId { get; set; }
    public ActiveState? BeforeActive { get; set; }
    public ActiveState AfterActive { get; set; } = new();
    public SortedDictionary<string, FolderSnapshot> Before { get; set; } = new(StringComparer.Ordinal);
    public SortedDictionary<string, FolderSnapshot> After { get; set; } = new(StringComparer.Ordinal);
    public List<MoveRecord> Moves { get; set; } = [];
    public string? Failure { get; set; }
    public SortedDictionary<string, string> RestoreSources { get; set; } = new(StringComparer.Ordinal);
}

internal sealed class InstallationPlan
{
    public required InstallerResult Result { get; init; }
    public required TargetInfo Target { get; init; }
    public ActiveState? Active { get; init; }
    public string? ActiveHash { get; init; }
    public SortedDictionary<string, FolderSnapshot> Current { get; } = new(StringComparer.Ordinal);
    public SortedDictionary<string, FolderSnapshot> Desired { get; } = new(StringComparer.Ordinal);
    public List<string> MovingFolders { get; } = [];
}

internal sealed class InstallerException(string code, string detail) : Exception(detail)
{
    public string Code { get; } = code;
}

public static class InstallerJson
{
    public static JsonSerializerOptions Options { get; } = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = false,
        WriteIndented = true,
        UnmappedMemberHandling = JsonUnmappedMemberHandling.Disallow,
    };

    public static string Serialize<T>(T value) => JsonSerializer.Serialize(value, Options);
    public static T Read<T>(Stream stream) => JsonSerializer.Deserialize<T>(stream, Options)
        ?? throw new InstallerException("invalid-json", "기록의 JSON 객체가 비어 있습니다.");
}

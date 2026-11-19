using System.Text;

namespace DevilForever.Installer;

internal static class InstallerText
{
    public static string Action(string value) => value switch
    {
        "install" or "apply" => "설치·갱신",
        "rollback" => "직전 상태 복원",
        "remove" => "관리 항목 제거",
        "verify" => "설치 확인",
        "inspect" => "현재 상태 확인",
        "plan" => "미리보기",
        _ => value,
    };

    public static string Status(string value) => value switch
    {
        "ready" => "확인 완료",
        "blocked" => "진행할 수 없음",
        "no-change" => "변경 없음",
        "completed" => "처리 완료",
        "restored" => "복원 완료",
        "recovery-required" => "복구 필요",
        "differences" => "설치 후 변경 발견",
        _ => value,
    };

    public static string Operation(string value) => value switch
    {
        "add" => "추가",
        "replace" => "교체",
        "take-over" => "원본 보관 후 교체",
        "switch-out" => "이전 판 보관",
        "remove" => "보관 후 제거",
        "restore" => "복원",
        "resume-restore" => "복원 이어서 진행",
        _ => value,
    };

    public static string Reason(string code) => code switch
    {
        "unmanaged-overlap" => "기존 폴더가 있습니다. 원본을 보관하고 교체하려면 인수를 선택하세요.",
        "unmanaged-opposite-variant" => "소유 기록이 없는 반대 판 폴더가 있습니다.",
        "modified-managed-folder" => "사용자가 바꾼 파일이 있어 이 폴더를 보존합니다.",
        "previously-preserved-folder" => "이전 작업에서 보존한 폴더입니다.",
        "newer-managed-version" => "더 새로운 관리 버전이 설치되어 있습니다.",
        "restore-target-changed" => "복원 이후 위치에 새 파일이나 변경이 있습니다.",
        "restore-backup-changed" => "복원 원본이 기록과 다릅니다.",
        "managed-difference" => "설치 기준과 현재 파일이 다릅니다.",
        "invalid-replace-choice" => "현재 미리보기에서 인수할 수 없는 폴더입니다.",
        "restore-progress-conflict" => "복원 중간 상태가 기록과 다릅니다.",
        _ => code,
    };

    public static string Package(PackageInfo? package) => package is null ? "관리 중인 묶음 없음"
        : $"{(package.Variant == "pitbull4" ? "PitBull4" : "Forever Unit Frames")} · {package.Version}";

    public static string ManagedState(string value) => value switch
    {
        "none" => "관리 중인 묶음 없음",
        "pitbull4" => "PitBull4",
        "fuf" => "Forever Unit Frames",
        _ => "확인 필요",
    };

    public static string PackageSummary(InstallerResult result) => result.Package is null
        && result.Status is "blocked" or "recovery-required"
            ? "현재 설치 상태를 확인하지 못했습니다."
            : Package(result.Package);

    public static string SharedReport(InstallerResult result)
    {
        var text = new StringBuilder();
        text.AppendLine("Devil Forever 설치 결과");
        text.AppendLine($"{Action(result.Action)} · {Status(result.Status)} · 종료 {result.ExitCode}");
        text.AppendLine(PackageSummary(result));
        if (result.RunId is not null) text.AppendLine("실행 " + result.RunId);
        foreach (var change in result.Changes) text.AppendLine($"{Operation(change.Operation)} · {RelativeName(change.Folder)}");
        foreach (var folder in result.Preserved) text.AppendLine("보존 · " + RelativeName(folder));
        foreach (var problem in result.Conflicts.Concat(result.Issues)) text.AppendLine("원인 · " + problem.Code);
        foreach (var run in result.Recovery) text.AppendLine("복구 대상 · " + run);
        return text.ToString();
    }

    private static string RelativeName(string value) => value.Any(character => char.IsControl(character)
        || "/\\:".Contains(character)) ? "관리 항목" : value;
}

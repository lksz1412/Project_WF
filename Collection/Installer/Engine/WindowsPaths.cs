using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Win32.SafeHandles;

namespace DevilForever.Installer;

internal static class WindowsPaths
{
    private const uint ShareAll = 7;
    private const uint OpenExisting = 3;
    private const uint BackupSemantics = 0x02000000;
    private static readonly HashSet<string> Reserved = new(StringComparer.OrdinalIgnoreCase)
        { "CON", "PRN", "AUX", "NUL", "CONIN$", "CONOUT$" };

    public static void Component(string value)
    {
        if (value.Length == 0 || value is "." or ".." || value.EndsWith(' ') || value.EndsWith('.')
            || value.Any(character => character < 32 || "<>:\"/\\|?*".Contains(character)))
            throw new InstallerException("unsafe-path", "허용하지 않는 파일 이름입니다.");
        var stem = value.Split('.')[0];
        if (Reserved.Contains(stem) || (stem.Length == 4
            && (stem.StartsWith("COM", StringComparison.OrdinalIgnoreCase)
                || stem.StartsWith("LPT", StringComparison.OrdinalIgnoreCase))
            && "123456789¹²³".Contains(stem[3])))
            throw new InstallerException("unsafe-path", "Windows 예약 파일 이름입니다.");
    }

    public static TargetInfo Target(string path)
    {
        if (!OperatingSystem.IsWindows())
            throw new InstallerException("unsupported-platform", "Windows x64에서 실행해 주세요.");
        if (string.IsNullOrWhiteSpace(path) || !Path.IsPathFullyQualified(path)
            || path.StartsWith(@"\\", StringComparison.Ordinal))
            throw new InstallerException("invalid-target", "로컬 게임 에디션의 절대경로가 필요합니다.");
        var full = Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar);
        if (!string.Equals(Path.GetFileName(full), "_forever_", StringComparison.Ordinal)
            || !Directory.Exists(full))
            throw new InstallerException("invalid-target", "Wow.exe가 있는 _forever_ 폴더를 선택해 주세요.");
        CheckAncestors(full);
        CheckChildren(full);
        var executable = Path.Combine(full, "Wow.exe");
        if (!File.Exists(executable))
            throw new InstallerException("invalid-target", "선택한 에디션에 Wow.exe가 없습니다.");
        CheckAncestors(executable);
        if (Directory.Exists(executable))
            throw new InstallerException("invalid-target", "Wow.exe가 일반 파일이어야 합니다.");
        using var handle = OpenDirectory(full, 0);
        if (!GetFileInformationByHandleEx(handle, 18, out var information, (uint)Marshal.SizeOf<FileIdInformation>()))
            throw NativeError("target-identity", "게임 경로 식별값을 읽지 못했습니다.");
        var identity = $"{information.VolumeSerialNumber:x16}-{information.FileIdLow:x16}{information.FileIdHigh:x16}";
        return new TargetInfo(full, identity);
    }

    public static string Under(string root, string relative)
    {
        var components = relative.Split('/');
        foreach (var component in components) Component(component);
        var full = Path.GetFullPath(Path.Combine(root, Path.Combine(components)));
        var prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!full.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
            throw new InstallerException("unsafe-path", "관리 경로 밖의 항목입니다.");
        CheckAncestors(full);
        return full;
    }

    public static void CheckAncestors(string path)
    {
        var root = Path.GetPathRoot(path)
            ?? throw new InstallerException("invalid-path", "파일의 드라이브를 확인할 수 없습니다.");
        var current = root;
        foreach (var component in path[root.Length..].Split(Path.DirectorySeparatorChar, StringSplitOptions.RemoveEmptyEntries))
        {
            Component(component);
            if (!Directory.Exists(current)) break;
            CheckChildren(current);
            current = Path.Combine(current, component);
            if (!Path.Exists(current)) break;
            if ((File.GetAttributes(current) & FileAttributes.ReparsePoint) != 0)
                throw new InstallerException("linked-path", "재분석 지점이 있는 경로입니다.");
        }
    }

    public static void CheckChildren(string directory)
    {
        if (!Directory.Exists(directory)) return;
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var path in Directory.EnumerateFileSystemEntries(directory))
        {
            var name = Path.GetFileName(path);
            if (!names.Add(name))
                throw new InstallerException("case-collision", "대소문자만 다른 파일 이름이 겹칩니다.");
        }
    }

    public static void WritableDirectory(string desired)
    {
        var existing = desired;
        while (!Directory.Exists(existing))
        {
            if (Path.Exists(existing))
                throw new InstallerException("path-type", "폴더 위치에 파일이 있습니다.");
            existing = Path.GetDirectoryName(existing)
                ?? throw new InstallerException("invalid-path", "기존 부모 폴더가 없습니다.");
        }
        CheckAncestors(existing);
        using var handle = OpenDirectory(existing, 0x0002 | 0x0004);
    }

    public static void MovableDirectory(string path)
    {
        CheckAncestors(path);
        using var handle = OpenDirectory(path, 0x00010000);
    }

    public static Mutex Acquire(TargetInfo target)
    {
        var name = "Global\\DevilForever-" + Hash(Encoding.UTF8.GetBytes(target.Identity));
        var mutex = new Mutex(false, name);
        try
        {
            bool acquired;
            try { acquired = mutex.WaitOne(0); }
            catch (AbandonedMutexException) { acquired = true; }
            if (!acquired) throw new InstallerException("target-busy", "이 게임 폴더에서 다른 작업이 실행 중입니다.");
            return mutex;
        }
        catch { mutex.Dispose(); throw; }
    }

    public static void GameStopped()
    {
        foreach (var process in System.Diagnostics.Process.GetProcesses())
        {
            using (process)
            {
                var name = process.ProcessName;
                if (name.Equals("Wow", StringComparison.OrdinalIgnoreCase)
                    || name.Equals("WowClassic", StringComparison.OrdinalIgnoreCase)
                    || name.Equals("WowClassicT", StringComparison.OrdinalIgnoreCase)
                    || name.Equals("WowB", StringComparison.OrdinalIgnoreCase))
                    throw new InstallerException("game-running", "게임을 종료한 뒤 다시 실행해 주세요.");
            }
        }
    }

    public static string Hash(byte[] bytes) => Convert.ToHexStringLower(SHA256.HashData(bytes));

    private static SafeFileHandle OpenDirectory(string path, uint access)
    {
        var handle = CreateFile(path, access, ShareAll, IntPtr.Zero, OpenExisting, BackupSemantics, IntPtr.Zero);
        if (!handle.IsInvalid) return handle;
        handle.Dispose();
        throw NativeError("path-access", "폴더 접근 권한을 확인하지 못했습니다.");
    }

    private static InstallerException NativeError(string code, string message) =>
        new(code, message + " " + new Win32Exception(Marshal.GetLastWin32Error()).Message);

    [StructLayout(LayoutKind.Sequential)]
    private struct FileIdInformation
    {
        public ulong VolumeSerialNumber;
        public ulong FileIdLow;
        public ulong FileIdHigh;
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true, EntryPoint = "CreateFileW")]
    private static extern SafeFileHandle CreateFile(string name, uint access, uint share,
        IntPtr security, uint creation, uint flags, IntPtr template);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetFileInformationByHandleEx(SafeFileHandle handle, int informationClass,
        out FileIdInformation information, uint size);
}

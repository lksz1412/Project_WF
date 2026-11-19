using System.Runtime.InteropServices;
using System.Text;

namespace DevilForever.Installer;

internal static class ConsoleConnection
{
    public static void ConnectWhenNeeded()
    {
        var output = GetStdHandle(-11);
        var error = GetStdHandle(-12);
        if (!Usable(output) && AttachConsole(uint.MaxValue) && Redirected(error))
            SetStdHandle(-12, error);
        Console.OutputEncoding = new UTF8Encoding(false);
    }

    private static bool Usable(IntPtr handle) => handle != IntPtr.Zero && handle != new IntPtr(-1)
        && GetFileType(handle) != 0;

    private static bool Redirected(IntPtr handle) => Usable(handle) && GetFileType(handle) is 1 or 3;

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetStdHandle(int standardHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern uint GetFileType(IntPtr handle);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool AttachConsole(uint processId);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool SetStdHandle(int standardHandle, IntPtr handle);
}

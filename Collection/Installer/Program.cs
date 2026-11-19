using DevilForever.Installer;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new InstallerForm());
            return 0;
        }
        ConsoleConnection.ConnectWhenNeeded();
        return CommandLine.Run(args);
    }
}

internal static class CommandLine
{
    public static int Run(string[] args)
    {
        var request = new InstallerRequest();
        var json = false;
        try
        {
            if (args[0] is "--help" or "help")
            {
                Console.WriteLine("Devil Forever 설치기");
                Console.WriteLine("inspect|verify --game <폴더> [--json]");
                Console.WriteLine("plan --game <폴더> [--action install|rollback|remove] [--package <ZIP>] [--replace <폴더>] [--json]");
                Console.WriteLine("apply --game <폴더> [--package <ZIP>] [--replace <폴더>] --confirm <값> [--json]");
                Console.WriteLine("rollback|remove --game <폴더> --confirm <값> [--json]");
                return 0;
            }
            request.Action = args[0];
            var singles = new HashSet<string>(StringComparer.Ordinal);
            for (var index = 1; index < args.Length; index++)
            {
                var option = args[index];
                if (option == "--json")
                {
                    if (json) throw new ArgumentException("--json이 중복되었습니다.");
                    json = true;
                    continue;
                }
                if (option is not ("--game" or "--action" or "--package" or "--replace" or "--confirm")
                    || index + 1 == args.Length)
                    throw new ArgumentException("알 수 없는 옵션 또는 빠진 값입니다.");
                if (option != "--replace" && !singles.Add(option)) throw new ArgumentException("옵션이 중복되었습니다.");
                var value = args[++index];
                switch (option)
                {
                    case "--game": request.Game = value; break;
                    case "--action": request.PlanAction = value; break;
                    case "--package": request.Package = value; break;
                    case "--replace": request.Replace.Add(value); break;
                    case "--confirm": request.Confirm = value; break;
                }
            }
            if (request.Action != "plan" && singles.Contains("--action"))
                throw new ArgumentException("--action은 plan에서만 사용합니다.");
            if (request.Action is not ("apply" or "rollback" or "remove") && singles.Contains("--confirm"))
                throw new ArgumentException("--confirm은 파일을 바꾸는 명령에서 사용합니다.");
            var result = new InstallerEngine().Execute(request);
            if (json) Console.WriteLine(InstallerJson.Serialize(result));
            else
            {
                Console.WriteLine($"{result.Action} {result.Status}");
                if (result.Package is { } package) Console.WriteLine($"{package.Variant} {package.Version}");
                foreach (var change in result.Changes) Console.WriteLine($"{change.Operation} {change.Folder}");
                foreach (var issue in result.Issues.Concat(result.Conflicts)) Console.Error.WriteLine($"{issue.Code} {issue.Detail}");
                if (result.PlanToken is not null) Console.WriteLine($"confirm {result.PlanToken}");
            }
            return result.ExitCode;
        }
        catch (ArgumentException exception)
        {
            var result = new InstallerResult { Action = request.Action, Status = "blocked", ExitCode = 2,
                Issues = [new("invalid-arguments", exception.Message)] };
            if (args.Contains("--json", StringComparer.Ordinal)) Console.WriteLine(InstallerJson.Serialize(result));
            else Console.Error.WriteLine(exception.Message);
            return 2;
        }
    }
}

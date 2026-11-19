using System.Reflection;
using DevilForever.Installer;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length != 2) throw new ArgumentException("A fixture game and an approved ZIP are required.");
        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Control.CheckForIllegalCrossThreadCalls = true;
        Application.ThreadException += (_, error) =>
        {
            Console.Error.WriteLine(error.Exception);
            Environment.Exit(1);
        };
        var started = false;
        var exitCode = 0;
        Application.Idle += RunOnce;
        Application.Run(new ApplicationContext());
        return exitCode;

        async void RunOnce(object? sender, EventArgs eventArgs)
        {
            if (started) return;
            started = true;
            try { await RunChecks(args); }
            catch (Exception exception)
            {
                Console.Error.WriteLine(exception);
                exitCode = 1;
            }
            finally { Application.ExitThread(); }
        }
    }

    private static async Task RunChecks(string[] args)
    {
        Console.WriteLine("RUN actual Form event checks");
        using var form = new InstallerForm();
        form.CreateControl();
        _ = form.Handle;
        foreach (var width in new[] { 880, 1100 })
        {
            form.ClientSize = new Size(width, 650);
            form.PerformLayout();
            var label = Find<Label>(form, "게임 폴더");
            if (label.Width < label.PreferredSize.Width)
                throw new InvalidOperationException("The game folder label does not fit its natural width.");
        }
        var game = Find<TextBox>(form, "GamePath");
        var package = Find<TextBox>(form, "PackagePath");
        var operation = Find<ComboBox>(form, "Operation");
        var apply = Find<Button>(form, "미리보기 실행");
        var preview = Find<Button>(form, "미리보기");
        var busyField = typeof(InstallerForm).GetField("busy", BindingFlags.NonPublic | BindingFlags.Instance)!;
        game.Text = args[0];
        package.Text = args[1];
        if (apply.Enabled) throw new InvalidOperationException("Apply must wait for a preview.");
        Click(preview);
        if (!(bool)busyField.GetValue(form)! || game.Enabled || apply.Enabled)
            throw new InvalidOperationException("The real async engine call must gate concurrent input.");
        await Wait(() => !(bool)busyField.GetValue(form)!);
        if (!apply.Enabled || Find<DataGridView>(form, "Changes").Rows.Count != 35)
            throw new InvalidOperationException("The form did not consume the actual approved package plan.");
        Console.WriteLine("PASS actual Form controls consume the approved package engine plan and gate busy state");
        game.Text += " ";
        if (apply.Enabled) throw new InvalidOperationException("A changed setting retained its confirmation.");
        operation.SelectedIndex = 1;
        if (package.Enabled) throw new InvalidOperationException("Rollback must not edit package selection.");
        operation.SelectedIndex = 0;
        if (!package.Enabled || apply.Enabled) throw new InvalidOperationException("Mode changes retained an old plan.");
        Console.WriteLine("PASS input and mode changes invalidate the real preview state");
        var textType = typeof(InstallerForm).Assembly.GetType("DevilForever.Installer.InstallerText")!;
        var report = (string)textType.GetMethod("SharedReport", BindingFlags.Static | BindingFlags.Public)!.Invoke(null,
            [new InstallerResult { Action = "verify", Status = "blocked", ExitCode = 2,
                Target = new TargetInfo(@"C:\private-user\_forever_", "fixture"),
                Issues = [new("input-access", @"C:\private-user\secret.txt")],
                Preserved = ["RelativeAddon"] }])!;
        if (report.Contains("private-user") || report.Contains("secret.txt") || !report.Contains("RelativeAddon")
            || !report.Contains("input-access") || !report.Contains("현재 설치 상태를 확인하지 못했습니다.")
            || report.Contains("관리 중인 묶음 없음")) throw new InvalidOperationException("The unknown report is misleading or leaked private details.");
        var noneReport = (string)textType.GetMethod("SharedReport", BindingFlags.Static | BindingFlags.Public)!.Invoke(null,
            [new InstallerResult { Action = "inspect", Status = "ready", Package = null }])!;
        var recoveryReport = (string)textType.GetMethod("SharedReport", BindingFlags.Static | BindingFlags.Public)!.Invoke(null,
            [new InstallerResult { Action = "inspect", Status = "recovery-required", Package = null }])!;
        if (!noneReport.Contains("관리 중인 묶음 없음") || noneReport.Contains("확인하지 못했습니다")
            || !recoveryReport.Contains("현재 설치 상태를 확인하지 못했습니다."))
            throw new InvalidOperationException("Known none and unknown recovery summaries are not distinct.");
        Console.WriteLine("PASS shared report keeps codes and relative names while excluding local paths");
        Click(preview);
        form.Close();
        if (form.IsDisposed) throw new InvalidOperationException("The window closed during a real engine task.");
        await Wait(() => form.IsDisposed);
        Console.WriteLine("PASS close during a real task waits until the result is complete");
        var overlap = Path.Combine(args[0], "Interface", "AddOns", "DevilForever_ChatSetup");
        Directory.CreateDirectory(overlap);
        File.WriteAllText(Path.Combine(overlap, "Ui-smoke-user.txt"), "preserve this fixture file");
        using var takeover = new InstallerForm();
        takeover.CreateControl();
        _ = takeover.Handle;
        Find<TextBox>(takeover, "GamePath").Text = args[0];
        Find<TextBox>(takeover, "PackagePath").Text = args[1];
        Click(Find<Button>(takeover, "미리보기"));
        await Wait(() => !(bool)busyField.GetValue(takeover)!);
        var changes = Find<DataGridView>(takeover, "Changes");
        var selected = changes.Rows.Cast<DataGridViewRow>().Single(row => row.Tag as string == "DevilForever_ChatSetup");
        selected.Cells[0].Value = true;
        if (Find<Button>(takeover, "미리보기 실행").Enabled) throw new InvalidOperationException("A checkbox edit retained a stale plan.");
        Click(Find<Button>(takeover, "미리보기"));
        await Wait(() => !(bool)busyField.GetValue(takeover)!);
        if (!Find<Button>(takeover, "미리보기 실행").Enabled)
            throw new InvalidOperationException("The selected overlap was not sent through the actual engine. "
                + Find<TextBox>(takeover, "ResultDetails").Text + " selected="
                + string.Join(",", (HashSet<string>)typeof(InstallerForm).GetField("takeovers",
                    BindingFlags.Instance | BindingFlags.NonPublic)!.GetValue(takeover)!));
        Console.WriteLine("PASS the declared overlap checkbox invalidates and rebuilds the actual takeover plan");
        Click(Find<Button>(takeover, "미리보기 실행"));
        await Wait(() => !(bool)busyField.GetValue(takeover)!, 180);
        if (Find<Label>(takeover, "Status").Text != "처리 완료")
            throw new InvalidOperationException("The actual takeover installation did not complete. " + Find<TextBox>(takeover, "ResultDetails").Text);
        var selectedFolders = (HashSet<string>)typeof(InstallerForm).GetField("takeovers",
            BindingFlags.Instance | BindingFlags.NonPublic)!.GetValue(takeover)!;
        if (selectedFolders.Count != 0) throw new InvalidOperationException("Completed installation retained takeover choices.");
        Click(Find<Button>(takeover, "미리보기"));
        await Wait(() => !(bool)busyField.GetValue(takeover)!);
        if (Find<Label>(takeover, "Status").Text != "변경 없음" || Find<Button>(takeover, "미리보기 실행").Enabled)
            throw new InvalidOperationException("The same-input preview is not a clean no-change. " + Find<TextBox>(takeover, "ResultDetails").Text);
        Console.WriteLine("PASS actual takeover install clears choices and same-input preview reports no-change");
    }

    private static T Find<T>(Control root, string name) where T : Control =>
        root.Controls.Find(name, true).OfType<T>().Single();

    private static void Click(Button button) => typeof(Button).GetMethod("OnClick",
        BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(button, [EventArgs.Empty]);

    private static async Task Wait(Func<bool> complete, int timeoutSeconds = 45)
    {
        var timer = System.Diagnostics.Stopwatch.StartNew();
        while (!complete())
        {
            if (timer.Elapsed > TimeSpan.FromSeconds(timeoutSeconds)) throw new TimeoutException("The form task did not finish.");
            await Task.Delay(10);
        }
    }
}

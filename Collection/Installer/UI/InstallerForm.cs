using System.Runtime.InteropServices;

namespace DevilForever.Installer;

public sealed class InstallerForm : Form
{
    private readonly InstallerEngine engine = new();
    private readonly TextBox gamePath = new() { Name = "GamePath", Dock = DockStyle.Fill, AccessibleName = "게임 폴더" };
    private readonly TextBox packagePath = new() { Name = "PackagePath", Dock = DockStyle.Fill, AccessibleName = "설치 ZIP" };
    private readonly ComboBox operation = new() { Name = "Operation", Dock = DockStyle.Fill,
        DropDownStyle = ComboBoxStyle.DropDownList, AccessibleName = "작업" };
    private readonly Button browseGame = Button("게임 폴더 선택", "폴더 선택(&G)");
    private readonly Button browsePackage = Button("설치 ZIP 선택", "ZIP 선택(&Z)");
    private readonly Button defaultPackage = Button("기본 PitBull4 ZIP", "기본 ZIP(&D)");
    private readonly Button inspect = Button("현재 상태 확인", "상태 확인(&S)");
    private readonly Button verify = Button("설치 확인", "설치 확인(&V)");
    private readonly Button preview = Button("미리보기", "미리보기(&P)");
    private readonly Button execute = Button("미리보기 실행", "설치·갱신 실행(&A)");
    private readonly Button copy = Button("공유용 결과 복사", "결과 복사(&C)");
    private readonly Label current = new() { Name = "CurrentState", AutoSize = true, Dock = DockStyle.Fill,
        Text = "게임 폴더를 선택해 현재 설치 상태를 확인하세요.", Margin = new Padding(0, 10, 0, 4) };
    private readonly Label summary = new() { Name = "PlanSummary", AutoSize = true, Dock = DockStyle.Fill,
        Text = "미리보기를 만들면 변경·보존·충돌 항목이 표시됩니다.", Margin = new Padding(0, 14, 0, 6) };
    private readonly Label status = new() { Name = "Status", AutoSize = true, Dock = DockStyle.Fill,
        Text = "준비", Margin = new Padding(0, 8, 0, 4) };
    private readonly TextBox detail = new() { Name = "ResultDetails", Dock = DockStyle.Fill, Multiline = true,
        ReadOnly = true, ScrollBars = ScrollBars.Vertical, AccessibleName = "결과 상세", TabStop = true };
    private readonly ProgressBar progress = new() { Name = "Working", Dock = DockStyle.Fill,
        Style = ProgressBarStyle.Marquee, MarqueeAnimationSpeed = 0, Visible = false, Margin = Padding.Empty };
    private readonly DataGridView rows = new() { Name = "Changes", Dock = DockStyle.Fill, RowHeadersVisible = false,
        AllowUserToAddRows = false, AllowUserToDeleteRows = false, AllowUserToResizeRows = false,
        AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells, MultiSelect = false,
        SelectionMode = DataGridViewSelectionMode.FullRowSelect, AccessibleName = "변경과 보존 목록",
        ClipboardCopyMode = DataGridViewClipboardCopyMode.Disable, BackgroundColor = SystemColors.Window };
    private readonly HashSet<string> takeovers = new(StringComparer.Ordinal);
    private readonly HashSet<string> eligibleTakeovers = new(StringComparer.Ordinal);
    private readonly string defaultZipPath;
    private InstallerResult? prepared;
    private InstallerResult? lastResult;
    private bool busy;
    private bool rendering;
    private bool closeAfterWork;

    public InstallerForm()
    {
        Name = "DevilForeverInstaller";
        Text = "Devil Forever 설치기";
        Font = SystemFonts.MessageBoxFont;
        AutoScaleMode = AutoScaleMode.Dpi;
        ClientSize = new Size(1030, 720);
        MinimumSize = new Size(880, 620);
        StartPosition = FormStartPosition.CenterScreen;
        var catalog = ApprovedPackage.LoadCatalog();
        defaultZipPath = Path.Combine(AppContext.BaseDirectory,
            catalog.Packages.Single(package => package.Variant == catalog.DefaultVariant).Zip);
        BuildLayout();
        packagePath.Text = defaultZipPath;
        operation.Items.AddRange(["설치·갱신", "직전 상태 복원", "관리 항목 제거"]);
        operation.SelectedIndex = 0;
        ConnectEvents();
        UpdateControls();
    }

    private static Button Button(string name, string text) => new()
    {
        Name = name, Text = text, AccessibleName = name, AutoSize = true,
        AutoSizeMode = AutoSizeMode.GrowAndShrink, MinimumSize = new Size(112, 32),
        UseVisualStyleBackColor = true, Margin = new Padding(4, 2, 0, 2),
    };

    private static Label Field(string text) => new()
    {
        Name = text, Text = text, AutoSize = true, Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft,
        Margin = new Padding(0, 2, 8, 2),
    };

    private void BuildLayout()
    {
        var outer = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 7,
            Padding = new Padding(18), Margin = Padding.Empty };
        outer.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        outer.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        outer.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        outer.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        outer.RowStyles.Add(new RowStyle(SizeType.Absolute, 102));
        outer.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        outer.RowStyles.Add(new RowStyle(SizeType.Absolute, 8));
        outer.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var fields = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, ColumnCount = 4,
            RowCount = 4, Margin = Padding.Empty };
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        fields.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        for (var index = 0; index < 4; index++) fields.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        fields.Controls.Add(Field("게임 폴더"), 0, 0);
        fields.Controls.Add(gamePath, 1, 0);
        fields.Controls.Add(browseGame, 2, 0);
        fields.Controls.Add(inspect, 3, 0);
        fields.Controls.Add(Field("설치 ZIP"), 0, 1);
        fields.Controls.Add(packagePath, 1, 1);
        fields.Controls.Add(browsePackage, 2, 1);
        fields.Controls.Add(defaultPackage, 3, 1);
        fields.Controls.Add(Field("작업"), 0, 2);
        fields.Controls.Add(operation, 1, 2);
        fields.Controls.Add(verify, 3, 2);
        fields.Controls.Add(current, 0, 3);
        fields.SetColumnSpan(current, 4);
        rows.Columns.Add(new DataGridViewCheckBoxColumn { Name = "TakeOver", HeaderText = "인수", Width = 56, SortMode = DataGridViewColumnSortMode.NotSortable });
        rows.Columns.Add(new DataGridViewTextBoxColumn { Name = "Folder", HeaderText = "항목", ReadOnly = true,
            AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill, FillWeight = 40, MinimumWidth = 170 });
        rows.Columns.Add(new DataGridViewTextBoxColumn { Name = "Operation", HeaderText = "처리", ReadOnly = true, Width = 140 });
        rows.Columns.Add(new DataGridViewTextBoxColumn { Name = "Reason", HeaderText = "설명", ReadOnly = true,
            AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill, FillWeight = 60, MinimumWidth = 220 });
        rows.DefaultCellStyle.WrapMode = DataGridViewTriState.True;
        rows.DefaultCellStyle.BackColor = SystemColors.Window;
        rows.DefaultCellStyle.ForeColor = SystemColors.WindowText;
        rows.DefaultCellStyle.SelectionBackColor = SystemColors.Highlight;
        rows.DefaultCellStyle.SelectionForeColor = SystemColors.HighlightText;
        rows.DefaultCellStyle.Padding = new Padding(3);
        var actions = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true,
            FlowDirection = FlowDirection.RightToLeft, WrapContents = true, Margin = new Padding(0, 8, 0, 0) };
        actions.Controls.Add(execute);
        actions.Controls.Add(preview);
        actions.Controls.Add(copy);
        outer.Controls.Add(fields, 0, 0);
        outer.Controls.Add(summary, 0, 1);
        outer.Controls.Add(rows, 0, 2);
        outer.Controls.Add(detail, 0, 3);
        outer.Controls.Add(status, 0, 4);
        outer.Controls.Add(progress, 0, 5);
        outer.Controls.Add(actions, 0, 6);
        Controls.Add(outer);
        AcceptButton = preview;
    }

    private void ConnectEvents()
    {
        gamePath.TextChanged += (_, _) => InputChanged();
        packagePath.TextChanged += (_, _) => InputChanged();
        operation.SelectedIndexChanged += (_, _) => InputChanged();
        browseGame.Click += async (_, _) =>
        {
            using var dialog = new FolderBrowserDialog { Description = "Wow.exe가 있는 _forever_ 폴더 선택",
                UseDescriptionForTitle = true, ShowNewFolderButton = false };
            if (Directory.Exists(gamePath.Text)) dialog.SelectedPath = gamePath.Text;
            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                gamePath.Text = dialog.SelectedPath;
                await RunRequest(Request("inspect"), false);
            }
        };
        browsePackage.Click += (_, _) =>
        {
            using var dialog = new OpenFileDialog { Title = "승인된 PitBull4 또는 FUF ZIP 선택",
                Filter = "애드온 설치 ZIP (*.zip)|*.zip", CheckFileExists = true, Multiselect = false };
            if (dialog.ShowDialog(this) == DialogResult.OK) packagePath.Text = dialog.FileName;
        };
        defaultPackage.Click += (_, _) => packagePath.Text = defaultZipPath;
        inspect.Click += async (_, _) => await RunRequest(Request("inspect"), false);
        verify.Click += async (_, _) => await RunRequest(Request("verify"), false);
        preview.Click += async (_, _) => await RunRequest(Request("plan"), true);
        execute.Click += async (_, _) =>
        {
            if (prepared?.PlanToken is not { } token) return;
            var request = Request(SelectedAction == "install" ? "apply" : SelectedAction);
            request.Confirm = token;
            await RunRequest(request, false);
        };
        copy.Click += (_, _) => CopyResult();
        rows.CurrentCellDirtyStateChanged += (_, _) =>
        {
            if (rows.IsCurrentCellDirty) rows.CommitEdit(DataGridViewDataErrorContexts.Commit);
        };
        rows.CellBeginEdit += (_, editing) =>
        {
            if (editing.ColumnIndex != 0 || editing.RowIndex < 0
                || rows.Rows[editing.RowIndex].Tag is not string folder || !eligibleTakeovers.Contains(folder))
                editing.Cancel = true;
        };
        rows.CellValueChanged += (_, change) =>
        {
            if (rendering || busy || change.RowIndex < 0 || change.ColumnIndex != 0) return;
            var row = rows.Rows[change.RowIndex];
            if (row.Tag is not string folder || !eligibleTakeovers.Contains(folder)) return;
            if (row.Cells[0].Value is true) takeovers.Add(folder);
            else takeovers.Remove(folder);
            InvalidatePreview();
        };
        FormClosing += (_, closing) =>
        {
            if (!busy) return;
            closing.Cancel = true;
            closeAfterWork = true;
            status.Text = "작업이 끝날 때까지 기다립니다. 완료 후 창을 닫습니다.";
        };
    }

    private string SelectedAction => operation.SelectedIndex switch { 1 => "rollback", 2 => "remove", _ => "install" };

    private InstallerRequest Request(string action) => new()
    {
        Action = action,
        Game = gamePath.Text.Trim(),
        PlanAction = SelectedAction,
        Package = (action == "apply" || action == "plan" && SelectedAction == "install")
            && !string.IsNullOrWhiteSpace(packagePath.Text) ? packagePath.Text.Trim() : null,
        Replace = action == "apply" || action == "plan" && SelectedAction == "install" ? takeovers.Order(StringComparer.Ordinal).ToList() : [],
    };

    private void InputChanged()
    {
        if (busy) return;
        takeovers.Clear();
        eligibleTakeovers.Clear();
        rows.Rows.Clear();
        current.Text = "현재 설치 미확인. 상태 확인 또는 미리보기를 실행하세요.";
        summary.Text = "선택한 입력으로 미리보기를 만들어 주세요.";
        detail.Clear();
        InvalidatePreview();
    }

    private void InvalidatePreview()
    {
        prepared = null;
        lastResult = null;
        status.Text = "선택이 바뀌었습니다. 미리보기를 다시 확인하세요.";
        UpdateControls();
    }

    private void UpdateControls()
    {
        gamePath.Enabled = !busy;
        browseGame.Enabled = !busy;
        inspect.Enabled = !busy;
        operation.Enabled = !busy;
        var choosingPackage = !busy && SelectedAction == "install";
        packagePath.Enabled = choosingPackage;
        browsePackage.Enabled = choosingPackage;
        defaultPackage.Enabled = choosingPackage;
        verify.Enabled = !busy;
        preview.Enabled = !busy;
        rows.Enabled = !busy;
        execute.Enabled = !busy && prepared is { Status: "ready", ExitCode: 0, PlanToken: not null };
        execute.Text = InstallerText.Action(SelectedAction) + " 실행(&A)";
        copy.Enabled = !busy && lastResult is not null;
        progress.Visible = busy;
        progress.MarqueeAnimationSpeed = busy ? 30 : 0;
        UseWaitCursor = busy;
    }

    private async Task RunRequest(InstallerRequest request, bool isPreview)
    {
        if (busy) return;
        prepared = null;
        busy = true;
        status.Text = InstallerText.Action(request.Action == "plan" ? request.PlanAction : request.Action) + " 처리 중";
        UpdateControls();
        InstallerResult result;
        try
        {
            result = await Task.Run(() => engine.Execute(request));
        }
        catch (Exception exception)
        {
            var writing = request.Action is "apply" or "rollback" or "remove";
            result = new InstallerResult { Action = request.Action, Status = writing ? "recovery-required" : "blocked",
                ExitCode = writing ? 3 : 2, Issues = [new("unexpected-error", exception.Message)] };
        }
        busy = false;
        if (result.ExitCode == 0 && request.Action is "apply" or "rollback" or "remove")
        {
            takeovers.Clear();
            eligibleTakeovers.Clear();
        }
        lastResult = result;
        if (isPreview && result.Status == "ready" && result.ExitCode == 0) prepared = result;
        RenderResult(result);
        UpdateControls();
        if (closeAfterWork)
        {
            closeAfterWork = false;
            if (result.ExitCode == 0) Close();
            else status.Text += " · 결과를 확인한 뒤 닫아 주세요.";
        }
    }

    private void RenderResult(InstallerResult result)
    {
        rendering = true;
        try
        {
            rows.Rows.Clear();
            foreach (var change in result.Changes)
                AddRow(change.Folder, InstallerText.Operation(change.Operation), "", result.Action == "plan"
                    && change.Operation == "take-over" && eligibleTakeovers.Contains(change.Folder));
            foreach (var folder in result.Preserved) AddRow(folder, "보존", "현재 파일 유지", false);
            foreach (var problem in result.Conflicts)
            {
                var eligible = SelectedAction == "install" && problem.Code == "unmanaged-overlap";
                var clearSelection = SelectedAction == "install" && problem.Code == "invalid-replace-choice"
                    && takeovers.Contains(problem.Detail) && eligibleTakeovers.Contains(problem.Detail);
                if (eligible) eligibleTakeovers.Add(problem.Detail);
                var action = eligible ? "인수 선택 필요" : clearSelection ? "인수 선택 해제" : "충돌";
                AddRow(problem.Detail, action, InstallerText.Reason(problem.Code), eligible || clearSelection);
            }
            summary.Text = $"변경 {result.Changes.Count}개 · 보존 {result.Preserved.Count}개 · 충돌 {result.Conflicts.Count}개";
            if (result.Target is null || result.Status == "blocked"
                || result.Package is null && result.Status == "recovery-required")
                current.Text = "현재 설치 상태를 확인하지 못했습니다.";
            else if (result.Action == "plan")
                current.Text = "현재 관리 상태 · " + InstallerText.ManagedState(result.ManagedState);
            else
                current.Text = "현재 관리 상태 · " + InstallerText.Package(result.Package);
            status.Text = InstallerText.Status(result.Status);
            var messages = new List<string>();
            if (result.Action == "plan" && result.Package is not null) messages.Add("확인한 묶음 · " + InstallerText.Package(result.Package));
            if (result.RunId is not null) messages.Add("실행 · " + result.RunId);
            foreach (var issue in result.Issues) messages.Add(issue.Detail);
            foreach (var run in result.Recovery) messages.Add("복구 대상 · " + run);
            if (result.Status == "ready" && result.Action == "plan") messages.Add("목록을 확인한 뒤 실행하세요.");
            if (result.Status == "blocked") messages.Add("표시된 원인을 해결한 뒤 미리보기를 다시 확인하세요.");
            if (result.Status == "recovery-required") messages.Add("작업을 직전 상태 복원으로 바꿔 미리보기를 확인하세요.");
            detail.Text = string.Join(Environment.NewLine, messages);
        }
        finally { rendering = false; }
    }

    private void AddRow(string folder, string action, string reason, bool eligible)
    {
        var index = rows.Rows.Add(takeovers.Contains(folder), folder, action, reason);
        var row = rows.Rows[index];
        row.Tag = eligible ? folder : null;
        if (!eligible) row.Cells[0] = new DataGridViewTextBoxCell { Value = "" };
    }

    private void CopyResult()
    {
        if (lastResult is null) return;
        try
        {
            Clipboard.SetText(InstallerText.SharedReport(lastResult));
            status.Text = "공유용 결과를 복사했습니다.";
        }
        catch (ExternalException)
        {
            status.Text = "클립보드를 사용 중입니다. 잠시 뒤 다시 복사해 주세요.";
        }
    }
}

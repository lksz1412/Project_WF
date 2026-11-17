<#
  office_com.ps1 - drive Microsoft Office through COM (Windows PC only).

    office_com.ps1 export-pdf       -In <file>      -Out <file.pdf>  [-ResultJson <path>]
    office_com.ps1 convert          -In <file>      -Out <file.pptx|file.docx|file.xlsx> [-ResultJson <path>]
    office_com.ps1 accept-revisions -In <file.docx> -Out <file.docx> [-ResultJson <path>]
    office_com.ps1 recalc           -In <file.xlsx> [-ResultJson <path>]

  The -In extension picks the application: .pptx .ppt .potx -> PowerPoint,
  .docx .doc .dotx -> Word, .xlsx .xls .xlsm -> Excel. convert writes that
  application's current format (.pptx, .docx or .xlsx).

  Result: exit code 0 on success and 1 on any failure, plus one JSON object
  {ok, app, output, error} written as UTF-8 without BOM to -ResultJson (to
  stdout when -ResultJson is omitted). Non-ASCII characters are written as \u
  escapes, so the console code page never touches the result.

  Application lifetime: an instance that was already running is used and left
  running; an instance this script started is quit, and only once no document
  is open in it. Only the document this script opened is closed. Only recalc
  saves its input; every other action writes a new file. Alerts are off, links
  are not updated, macros in the opened file are disabled, no window is shown,
  and every application setting changed here is restored before release.
#>
param(
    [string]$Action,
    [string]$In,
    [string]$Out,
    [string]$ResultJson
)

$ErrorActionPreference = 'Stop'

$msoTrue = -1
$msoFalse = 0
$msoAutomationSecurityForceDisable = 3
$ppAlertsNone = 1
$ppSaveAsOpenXMLPresentation = 24
$ppSaveAsPDF = 32
$wdAlertsNone = 0
$wdDoNotSaveChanges = 0
$wdFormatDocumentDefault = 16
$wdExportFormatPDF = 17
$xlOpenXMLWorkbook = 51
$xlTypePDF = 0
$missing = [Type]::Missing

$apps = [ordered]@{
    PowerPoint = @{ ProgId = 'PowerPoint.Application'; Process = 'POWERPNT'; Inputs = @('.pptx', '.ppt', '.potx'); Current = '.pptx' }
    Word       = @{ ProgId = 'Word.Application'; Process = 'WINWORD'; Inputs = @('.docx', '.doc', '.dotx'); Current = '.docx' }
    Excel      = @{ ProgId = 'Excel.Application'; Process = 'EXCEL'; Inputs = @('.xlsx', '.xls', '.xlsm'); Current = '.xlsx' }
}

function ConvertTo-AsciiJson($Value) {
    $json = $Value | ConvertTo-Json -Compress
    $escape = [System.Text.RegularExpressions.MatchEvaluator] { param($m) '\u{0:x4}' -f [int][char]$m.Value }
    return [regex]::Replace($json, '[^\x00-\x7F]', $escape)
}

function Resolve-FullPath([string]$Path) {
    # COM resolves a relative path against the application's current folder, not ours.
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Get-ProcessIds([string]$Name) {
    return @(Get-Process -Name $Name -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
}

function Get-FileStamp([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    $item = Get-Item -LiteralPath $Path
    return '{0}:{1}' -f $item.LastWriteTimeUtc.Ticks, $item.Length
}

function Get-OpenDocuments($App, [string]$Name) {
    switch ($Name) {
        'PowerPoint' { $App.Presentations }
        'Word' { $App.Documents }
        'Excel' { $App.Workbooks }
    }
}

function Test-DocumentOpen($App, [string]$Name, [string]$Path) {
    foreach ($openDoc in @(Get-OpenDocuments $App $Name)) {
        if ([string]::Equals([string]$openDoc.FullName, $Path, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    }
    return $false
}

$result = [ordered]@{ ok = $false; app = $null; output = $null; error = $null }
$step = 'check the arguments'
$app = $null
$doc = $null
$appName = $null
$weStartedApp = $false
$restore = [ordered]@{}

try {
    if ($args.Count -gt 0) { throw "unexpected arguments: $($args -join ' ')" }
    $actions = @('export-pdf', 'convert', 'accept-revisions', 'recalc')
    if ($actions -notcontains $Action) { throw "unknown action '$Action'; expected one of: $($actions -join ', ')" }
    if (-not $In) { throw '-In is required' }
    $inPath = Resolve-FullPath $In
    if (-not (Test-Path -LiteralPath $inPath -PathType Leaf)) { throw "input file not found: $inPath" }
    $inExt = [System.IO.Path]::GetExtension($inPath).ToLowerInvariant()
    foreach ($name in $apps.Keys) {
        if ($apps[$name].Inputs -contains $inExt) { $appName = $name }
    }
    if (-not $appName) { throw "unsupported input type '$inExt'" }
    $result.app = $appName
    $spec = $apps[$appName]

    if ($Action -eq 'recalc') {
        if ($appName -ne 'Excel') { throw 'recalc needs an Excel workbook (.xlsx .xls .xlsm)' }
        if ($Out) { throw 'recalc rewrites -In in place and takes no -Out' }
        $target = $inPath
    } else {
        if ($Action -eq 'accept-revisions' -and $appName -ne 'Word') { throw 'accept-revisions needs a Word document (.docx .doc .dotx)' }
        if (-not $Out) { throw "-Out is required for $Action" }
        $target = Resolve-FullPath $Out
        $wanted = if ($Action -eq 'export-pdf') { '.pdf' } else { $spec.Current }
        if ([System.IO.Path]::GetExtension($target).ToLowerInvariant() -ne $wanted) { throw "-Out must end in $wanted for $Action from $appName" }
        if ([string]::Equals($target, $inPath, [System.StringComparison]::OrdinalIgnoreCase)) { throw '-Out must differ from -In' }
    }
    $targetBefore = Get-FileStamp $target

    $step = "start $($spec.ProgId)"
    $pidsBefore = Get-ProcessIds $spec.Process
    $app = New-Object -ComObject $spec.ProgId
    # PowerPoint attaches to a running instance; Word and Excel usually start another
    # process even when one is running. Only a new process id means this script started it.
    $weStartedApp = @(Get-ProcessIds $spec.Process | Where-Object { $pidsBefore -notcontains $_ }).Count -gt 0

    $step = 'check the open documents'
    if (Test-DocumentOpen $app $appName $inPath) { throw "$inPath is already open in $appName; save and close it, then retry" }

    $step = 'set the application options'
    $restore.DisplayAlerts = $app.DisplayAlerts
    $restore.AutomationSecurity = $app.AutomationSecurity
    switch ($appName) {
        'PowerPoint' { $app.DisplayAlerts = $ppAlertsNone }
        'Word' { $app.DisplayAlerts = $wdAlertsNone }
        'Excel' {
            $app.DisplayAlerts = $false
            $restore.AskToUpdateLinks = $app.AskToUpdateLinks
            $app.AskToUpdateLinks = $false
        }
    }

    $step = "open $inPath"
    $namesBefore = @(@(Get-OpenDocuments $app $appName) | ForEach-Object { [string]$_.FullName })
    $app.AutomationSecurity = $msoAutomationSecurityForceDisable
    try {
        switch ($appName) {
            'PowerPoint' { $opened = $app.Presentations.Open($inPath, $msoTrue, $msoFalse, $msoFalse) }
            'Word' { $opened = $app.Documents.Open($inPath, $false, $true, $false, $missing, $missing, $missing, $missing, $missing, $missing, $missing, $false) }
            'Excel' { $opened = $app.Workbooks.Open($inPath, 0, ($Action -ne 'recalc'), $missing, $missing, $missing, $true, $missing, $missing, $missing, $false, $missing, $false) }
        }
    } finally {
        $app.AutomationSecurity = $restore.AutomationSecurity
    }
    # Word hands back an already open document instead of opening it again, so an open under
    # another spelling of the path would return the user's document. That one is not ours to close.
    # Ours = a document whose name was not open before (a count is fooled when the user opens or closes another meanwhile).
    if ($null -eq $opened) { throw "$appName returned no document for $inPath" }
    if ($namesBefore -contains [string]$opened.FullName) {
        throw "$inPath is already open in $appName (under another path); save and close it, then retry"
    }
    $doc = $opened

    $step = "$Action with $appName"
    if ($Action -ne 'recalc') { [void][System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($target)) }
    switch ("$appName $Action") {
        'PowerPoint export-pdf' { $doc.SaveAs($target, $ppSaveAsPDF) }
        'PowerPoint convert' { $doc.SaveAs($target, $ppSaveAsOpenXMLPresentation) }
        'Word export-pdf' { $doc.ExportAsFixedFormat($target, $wdExportFormatPDF, $false) }
        'Word convert' { $doc.SaveAs2($target, $wdFormatDocumentDefault, $missing, $missing, $false) }
        'Word accept-revisions' {
            $doc.AcceptAllRevisions()
            $left = $doc.Revisions.Count
            if ($left -gt 0) { throw "$left tracked change(s) could not be accepted" }
            $doc.SaveAs2($target, $wdFormatDocumentDefault, $missing, $missing, $false)
        }
        'Excel export-pdf' { $doc.ExportAsFixedFormat($xlTypePDF, $target, $missing, $missing, $missing, $missing, $missing, $false) }
        'Excel convert' { $doc.SaveAs($target, $xlOpenXMLWorkbook) }
        'Excel recalc' {
            if ($doc.ReadOnly) { throw "$inPath opened read-only (is it open elsewhere?); nothing was recalculated" }
            # CalculateFull recalculates every open workbook - refuse while any other workbook is open in this instance.
            if ($app.Workbooks.Count -gt 1) { throw "Excel has other workbooks open; recalculating would change them too - close them (or Excel), then retry; nothing was recalculated" }
            $app.CalculateFull()
            # Mark the workbook changed so Save() always rewrites the file; the check below relies on it.
            $doc.Saved = $false
            $doc.Save()
        }
    }

    $step = 'check the output'
    $targetAfter = Get-FileStamp $target
    if ($null -eq $targetAfter -or $targetAfter -eq $targetBefore) { throw "$appName reported success but did not write $target" }
    $result.ok = $true
    $result.output = $target
}
catch {
    $result.error = "$step failed: $($_.Exception.Message)"
}
finally {
    if ($null -ne $doc) {
        try {
            switch ($appName) {
                'PowerPoint' { $doc.Close() }
                'Word' { $doc.Close($wdDoNotSaveChanges) }
                'Excel' { $doc.Close($false) }
            }
        } catch { }
        try { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($doc) } catch { }
    }
    if ($null -ne $app) {
        foreach ($name in $restore.Keys) {
            try { $app.$name = $restore[$name] } catch { }
        }
        if ($weStartedApp) {
            try {
                if (@(Get-OpenDocuments $app $appName).Count -eq 0) {
                    if ($appName -eq 'Word') { $app.Quit($wdDoNotSaveChanges) } else { $app.Quit() }
                }
            } catch { }
        }
        try { [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($app) } catch { }
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

$exitCode = if ($result.ok) { 0 } else { 1 }
$json = ConvertTo-AsciiJson $result
if ($ResultJson) {
    try {
        [System.IO.File]::WriteAllText((Resolve-FullPath $ResultJson), $json, (New-Object System.Text.UTF8Encoding($false)))
    } catch {
        $result.ok = $false
        $result.error = (@($result.error, "could not write -ResultJson: $($_.Exception.Message)") | Where-Object { $_ }) -join '; '
        Write-Output (ConvertTo-AsciiJson $result)
        $exitCode = 1
    }
} else {
    Write-Output $json
}
exit $exitCode

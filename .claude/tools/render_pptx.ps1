<#
  render_pptx.ps1 - Gate 3 renderer (PowerPoint COM)
  Exports a PPTX to per-slide PNG (+ optional PDF). No LibreOffice required.

  Note (measured 2026-07-26): PowerPoint COM Export() writes locale-dependent file
  names (Korean environment produces "슬라이드1.PNG"). Globbing for 'Slide*.PNG'
  silently finds zero files, so we collect by extension, sort by the trailing
  number, and normalize to slide-001.png so downstream tools stay locale independent.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Pptx,
    [Parameter(Mandatory = $true)][string]$OutDir,
    [ValidateRange(320, 8192)][int]$Width = 1920,
    [switch]$NoPdf
)

$ErrorActionPreference = 'Stop'
$ppSaveAsPDF = 32

function Get-TrailingNumber {
    param([string]$Name)
    $m = [regex]::Match($Name, '(\d+)\s*$')
    if ($m.Success) { return [int]$m.Groups[1].Value }
    return [int]::MaxValue
}

$Pptx = (Resolve-Path -LiteralPath $Pptx).Path
if (-not (Test-Path -LiteralPath $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
}
$OutDir = (Resolve-Path -LiteralPath $OutDir).Path
$pngDir = Join-Path $OutDir 'png'
if (-not (Test-Path -LiteralPath $pngDir)) {
    New-Item -ItemType Directory -Force -Path $pngDir | Out-Null
}
# Note: clearing old PNGs happens inside the try block, immediately before Export.
# Doing it here would delete a good previous render even when the COM call fails,
# leaving nothing at all.

$app = $null
$pres = $null
$exitCode = 0
$weOpenedApp = $false

try {
    # Track whether PowerPoint was already running. Quitting a session the user
    # opened would close their unsaved work - it is a single-instance automation
    # server, so New-Object attaches to an existing process rather than starting
    # a second one.
    #
    # Marshal::GetActiveObject does not exist on .NET Core, so on pwsh 7 it always
    # throws and every run would look like "we started it". Ask the OS instead,
    # which works on both editions.
    $alreadyRunning = [bool](Get-Process -Name POWERPNT -ErrorAction SilentlyContinue)
    $app = New-Object -ComObject PowerPoint.Application
    $weOpenedApp = -not $alreadyRunning
    $pres = $app.Presentations.Open($Pptx, $true, $false, $false)

    $slideCount = $pres.Slides.Count
    if ($slideCount -lt 1) {
        # `return` at script scope skips the trailing `exit $exitCode`, so the
        # process would end with code 0 and the caller would read it as success.
        Write-Warning "Presentation has no slides - nothing to render"
        throw "no slides"
    }
    $height = [int][math]::Round($Width * $pres.PageSetup.SlideHeight / $pres.PageSetup.SlideWidth)
    Write-Output "slides=$slideCount export=${Width}x${height}"

    # Clear stale PNGs only now, once we know the export is about to run. Without
    # this a shorter re-render leaves old slide-NNN.png behind, and because
    # normalisation sorts by trailing number the leftovers collide with the new
    # export and the slide mapping silently shifts.
    Get-ChildItem -LiteralPath $pngDir -File -Filter '*.png' -ErrorAction SilentlyContinue |
        Remove-Item -Force -Confirm:$false

    $pres.Export($pngDir, 'PNG', $Width, $height)

    $pngs = Get-ChildItem -LiteralPath $pngDir -File | Where-Object { $_.Extension -ieq '.png' }
    $sorted = $pngs | Sort-Object -Property @{ Expression = { Get-TrailingNumber $_.BaseName } }, Name

    # Two-stage rename. Renaming straight to slide-NNN.png can overwrite a file
    # still waiting in the list, and because the loop counter is what gets
    # compared afterwards the loss would not be noticed.
    $i = 0
    foreach ($f in $sorted) {
        $i = $i + 1
        Rename-Item -LiteralPath $f.FullName -NewName ('tmp-{0:D5}.png' -f $i) -Force
    }
    $j = 0
    foreach ($f in (Get-ChildItem -LiteralPath $pngDir -File -Filter 'tmp-*.png' | Sort-Object Name)) {
        $j = $j + 1
        Rename-Item -LiteralPath $f.FullName -NewName ('slide-{0:D3}.png' -f $j) -Force
    }
    $actual = @(Get-ChildItem -LiteralPath $pngDir -File -Filter 'slide-*.png').Count
    Write-Output "png=$actual dir=$pngDir"

    if ($actual -ne $slideCount) {
        Write-Warning "PNG count ($actual) does not match slide count ($slideCount)"
        $exitCode = 1
    }

    # Only write the PDF when the PNG export was sound. A PDF from a failed render
    # would fill the deliverable list and make the run look complete.
    if (-not $NoPdf -and $exitCode -eq 0) {
        $pdf = Join-Path $OutDir ([System.IO.Path]::GetFileNameWithoutExtension($Pptx) + '.pdf')
        $pres.SaveAs($pdf, $ppSaveAsPDF)
        Write-Output "pdf=$pdf"
    }
}
catch {
    # Set the code first: under $ErrorActionPreference='Stop', Write-Error itself
    # throws, so any statement after it in this block never runs.
    $exitCode = 1
    Write-Error -ErrorAction Continue $_
}
finally {
    if ($pres) {
        try { $pres.Close() } catch { }
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($pres)
    }
    if ($app) {
        # Only quit the application if we started it, and only if no other
        # presentation is still open in it.
        if ($weOpenedApp) {
            try {
                if ($app.Presentations.Count -eq 0) { $app.Quit() }
            } catch { }
        }
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($app)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

exit $exitCode

[CmdletBinding(DefaultParameterSetName = 'Run')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Run')] [string] $StagedAddOns,
    [Parameter(Mandatory, ParameterSetName = 'Run')] [string] $BackupRoot,
    [Parameter(ParameterSetName = 'Run')] [switch] $DryRun,
    [Parameter(ParameterSetName = 'Run')] [switch] $AllowRunningGame,
    [Parameter(Mandatory, ParameterSetName = 'Help')] [switch] $Help
)

$ErrorActionPreference = 'Stop'
$gameWriteStarted = $false
$GameRoot = 'C:\Program Files (x86)\World of Warcraft\_forever_'
$Workspace = 'D:\Projects\Project_WF\_local_only'

function Get-RestoreText([string] $Backup) {
    return @"
  robocopy "$Backup\AddOns" "$GameRoot\Interface\AddOns" /MIR /COPY:DAT
  robocopy "$Backup\WTF" "$GameRoot\WTF" /MIR /COPY:DAT
/MIR makes each target equal to the backup (files added since the backup are removed).
"@
}

$Usage = @"
install_local.ps1 - copy a staged DevilForever AddOns tree into the WoW Forever game folder.

  install_local.ps1 -StagedAddOns <stage>\AddOns -BackupRoot $Workspace\claude-p27-backup-<8 hex> [-DryRun] [-AllowRunningGame]
  install_local.ps1 -Help

<stage> is a folder $Workspace\claude-p27-stage-<8 hex> holding AddOns\ and receipt.json.
Steps: checks (game folder, Wow.exe, game closed, no links, staged tree = receipt.json),
backup of Interface\AddOns and WTF into the new backup root with an inventory check,
then each package folder is mirrored into Interface\AddOns\<folder> (files of that folder
that are not in the package are removed), checked against the staged tree, and
installation.json is written into the backup root. Other folders of Interface\AddOns
(for example !BugGrabber, BugSack) and everything outside Interface\AddOns are left alone.
-DryRun prints every action and writes nothing (no backup folder either).
-AllowRunningGame skips only the "Wow or WowClassic is running" refusal, for a player who stays
logged in and types /reload afterwards. Everything else is the same: AddOns and WTF are backed up
first, only the package folders of Interface\AddOns are written, WTF is never written. The running
game may rewrite WTF when it reloads or logs out; the backup is the state before the install.
Exit code 0 = done, 1 = stopped by a check or a failed step.

Restore (game closed): copy the backup back
$(Get-RestoreText '<backup>')
"@

if ($PSCmdlet.ParameterSetName -eq 'Help') {
    Write-Output $Usage
    exit 0
}

function Write-Step([string] $Text) {
    Write-Output ($(if ($DryRun) { '[dry-run] ' } else { '' }) + $Text)
}

function Assert-GameClosed {
    if ($AllowRunningGame) { return }
    if (Get-Process -Name Wow, WowClassic -ErrorAction SilentlyContinue) {
        throw 'Wow or WowClassic is running; close the game first.'
    }
}

function Assert-NotLink([string] $Path, [string] $Label) {
    if ((Get-Item -LiteralPath $Path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "$Label is a link: $Path"
    }
}

# Relative path -> 'directory' or '<bytes>:<SHA256>' for every entry under $Path; stops on a link.
function Get-TreeInventory([string] $Path) {
    $root = (Get-Item -LiteralPath $Path -Force)
    if (-not $root.PSIsContainer) { throw "Not a folder: $Path" }
    Assert-NotLink $root.FullName 'Folder'
    $prefix = $root.FullName.TrimEnd('\').Length + 1
    $inventory = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in (Get-ChildItem -LiteralPath $root.FullName -Recurse -Force)) {
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Link inside $Path : $($entry.FullName)" }
        $relative = $entry.FullName.Substring($prefix)
        if ($entry.PSIsContainer) {
            $inventory.Add($relative, 'directory')
        } else {
            $inventory.Add($relative, ('{0}:{1}' -f $entry.Length, (Get-FileHash -LiteralPath $entry.FullName -Algorithm SHA256).Hash))
        }
    }
    return ,$inventory
}

function Get-FileCount($Inventory) {
    return @($Inventory.Values | Where-Object { $_ -ne 'directory' }).Count
}

function Assert-SameTree($Expected, $Actual, [string] $Label) {
    if ($Expected.Count -ne $Actual.Count) {
        throw "$Label : entry count $($Actual.Count) differs from $($Expected.Count)"
    }
    foreach ($key in $Expected.Keys) {
        if (-not $Actual.ContainsKey($key) -or $Expected[$key] -ne $Actual[$key]) {
            throw "$Label : entry differs: $key"
        }
    }
}

function Invoke-Robocopy([string[]] $Arguments, [string] $Label) {
    & robocopy.exe @Arguments
    $code = $LASTEXITCODE
    if ($code -ge 8) { throw "robocopy failed ($code): $Label" }
}

try {
    $game = (Resolve-Path -LiteralPath $GameRoot).Path
    if ($game -ine $GameRoot -or -not (Test-Path -LiteralPath (Join-Path $game 'Wow.exe') -PathType Leaf)) {
        throw "Wow.exe not found in $GameRoot"
    }
    $interface = Join-Path $game 'Interface'
    $gameAddOns = Join-Path $interface 'AddOns'
    $wtf = Join-Path $game 'WTF'
    foreach ($path in @($game, $interface, $gameAddOns, $wtf)) {
        if (-not (Test-Path -LiteralPath $path -PathType Container)) { throw "Missing game folder: $path" }
        Assert-NotLink $path 'Game folder'
    }

    $workspace = (Resolve-Path -LiteralPath $Workspace).Path
    $source = (Resolve-Path -LiteralPath $StagedAddOns).Path.TrimEnd('\')
    $stage = Split-Path -Parent $source
    if ((Split-Path -Leaf $source) -ne 'AddOns' -or (Split-Path -Parent $stage) -ine $workspace -or
        (Split-Path -Leaf $stage) -notmatch '^claude-p27-stage-[0-9a-f]{8}$') {
        throw "StagedAddOns must be $workspace\claude-p27-stage-<8 hex>\AddOns"
    }
    Assert-NotLink $stage 'Stage folder'
    $backup = [IO.Path]::GetFullPath($BackupRoot).TrimEnd('\')
    if ((Split-Path -Parent $backup) -ine $workspace -or (Split-Path -Leaf $backup) -notmatch '^claude-p27-backup-[0-9a-f]{8}$') {
        throw "BackupRoot must be $workspace\claude-p27-backup-<8 hex>"
    }
    if (Test-Path -LiteralPath $backup) { throw "BackupRoot already exists: $backup" }

    $receiptPath = Join-Path $stage 'receipt.json'
    $receipt = Get-Content -Raw -Encoding UTF8 -LiteralPath $receiptPath | ConvertFrom-Json
    $staged = Get-TreeInventory $source
    $receiptFiles = @{}
    foreach ($file in $receipt.files) {
        $receiptFiles[$file.path.Replace('/', '\')] = ('{0}:{1}' -f $file.bytes, $file.sha256.ToUpperInvariant())
    }
    $stagedFiles = @($staged.Keys | Where-Object { $staged[$_] -ne 'directory' })
    if ($stagedFiles.Count -ne $receiptFiles.Count -or $stagedFiles.Count -ne $receipt.file_count) {
        throw "Staged tree has $($stagedFiles.Count) files, receipt.json lists $($receiptFiles.Count) (file_count $($receipt.file_count))"
    }
    foreach ($key in $stagedFiles) {
        if (-not $receiptFiles.ContainsKey($key) -or $receiptFiles[$key] -ne $staged[$key]) {
            throw "Staged file differs from receipt.json: $key"
        }
    }
    $folders = @(Get-ChildItem -LiteralPath $source -Directory -Force | Select-Object -ExpandProperty Name | Sort-Object)
    if (Compare-Object $folders @($receipt.folders | Sort-Object)) { throw 'Staged folders differ from receipt.json folders.' }
    foreach ($name in $folders) {
        if ($name -notmatch '^[A-Za-z0-9!_.-]+$' -or $name -match '^\.+$') { throw "Unexpected folder name: $name" }
    }
    $loose = @(Get-ChildItem -LiteralPath $source -File -Force)
    if ($loose.Count) { throw 'The staged AddOns folder holds files outside the package folders.' }
    $leftAlone = @(Get-ChildItem -LiteralPath $gameAddOns -Directory -Force | Select-Object -ExpandProperty Name |
        Where-Object { $folders -notcontains $_ } | Sort-Object)
    Write-Step ("staged {0} folders, {1} files, commit {2}, variant {3}, version {4}" -f
        $folders.Count, $stagedFiles.Count, $receipt.commit, $receipt.variant, $receipt.version)
    Write-Step ("left alone in {0}: {1}" -f $gameAddOns, ($leftAlone -join ', '))

    Assert-GameClosed
    $oldAddOns = Get-TreeInventory $gameAddOns
    $oldWtf = Get-TreeInventory $wtf
    Write-Step ("backup {0} ({1} entries, {2} files) -> {3}\AddOns" -f $gameAddOns, $oldAddOns.Count, (Get-FileCount $oldAddOns), $backup)
    Write-Step ("backup {0} ({1} entries, {2} files) -> {3}\WTF" -f $wtf, $oldWtf.Count, (Get-FileCount $oldWtf), $backup)
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $backup | Out-Null
        Invoke-Robocopy @($gameAddOns, (Join-Path $backup 'AddOns'), '/E', '/COPY:DAT', '/R:1', '/W:1', '/XJ', '/NFL', '/NDL', '/NJH', '/NJS', '/NP') 'AddOns backup'
        Invoke-Robocopy @($wtf, (Join-Path $backup 'WTF'), '/E', '/COPY:DAT', '/R:1', '/W:1', '/XJ', '/NFL', '/NDL', '/NJH', '/NJS', '/NP') 'WTF backup'
        Assert-SameTree $oldAddOns (Get-TreeInventory (Join-Path $backup 'AddOns')) 'AddOns backup'
        Assert-SameTree $oldWtf (Get-TreeInventory (Join-Path $backup 'WTF')) 'WTF backup'
        Write-Step 'backup inventories equal the game folders'
    }

    Assert-GameClosed
    $gameWriteStarted = $false
    foreach ($name in $folders) {
        $from = Join-Path $source $name
        $to = Join-Path $gameAddOns $name
        if ((Split-Path -Parent $to) -ine $gameAddOns) { throw "Target outside Interface\AddOns: $to" }
        if (Test-Path -LiteralPath $to) { Assert-NotLink $to 'Game add-on folder' }
        $mirror = @($from, $to, '/MIR', '/COPY:DAT', '/R:1', '/W:1', '/XJ', '/NJH', '/NJS', '/NDL', '/NP', '/FP')
        if ($DryRun) {
            Write-Step "mirror $from -> $to; robocopy /L lists:"
            Invoke-Robocopy ($mirror + '/L') "list $name"
        } else {
            Write-Step "mirror $from -> $to"
            $gameWriteStarted = $true
            Invoke-Robocopy $mirror "mirror $name"
        }
    }

    if ($DryRun) {
        Write-Step ("would check {0} package folders against the staged tree and write {1}\installation.json" -f $folders.Count, $backup)
        exit 0
    }
    foreach ($name in $folders) {
        Assert-SameTree (Get-TreeInventory (Join-Path $source $name)) (Get-TreeInventory (Join-Path $gameAddOns $name)) "installed $name"
    }
    $installation = [ordered]@{
        game = $game; staged = $source; commit = $receipt.commit; variant = $receipt.variant; version = $receipt.version
        packageFolders = $folders; fileCount = $stagedFiles.Count
        backupAddOnsEntries = $oldAddOns.Count; backupAddOnsFiles = (Get-FileCount $oldAddOns)
        backupWtfEntries = $oldWtf.Count; backupWtfFiles = (Get-FileCount $oldWtf)
        leftAlone = $leftAlone; allowRunningGame = [bool]$AllowRunningGame; time = (Get-Date).ToString('o')
    }
    $installation | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $backup 'installation.json') -Encoding UTF8
    Write-Step ("installed {0} folders, {1} files; installation.json in {2}" -f $folders.Count, $stagedFiles.Count, $backup)
    exit 0
} catch {
    Write-Output ("ERROR " + $_.Exception.Message)
    if ($gameWriteStarted) {
        Write-Output "The game folder $gameAddOns is partly changed: the install stopped after it began copying."
        Write-Output "Backup of the state before the install: $backup"
        Write-Output "Restore (game closed):"
        Write-Output (Get-RestoreText $backup)
    }
    exit 1
}

param(
    [Parameter(Mandatory)]
    [string] $PackageDirectory,
    [Parameter(Mandatory)]
    [string] $OutputDirectory,
    [string] $NuGetConfig,
    [string] $PackagesPath,
    [switch] $IncludeFuf
)

$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$packageRoot = (Resolve-Path -LiteralPath $PackageDirectory).Path
$finalRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
if (Test-Path -LiteralPath $finalRoot) { throw 'Choose a new output directory.' }
$parent = Split-Path -Parent $finalRoot
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'Create the parent output directory first.' }
$catalog = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'ReleaseCatalog.json') | ConvertFrom-Json
$selected = @($catalog.packages | Where-Object { $_.variant -eq $catalog.defaultVariant -or ($IncludeFuf -and $_.variant -eq 'fuf') })
if ($selected.Count -ne (1 + [int]$IncludeFuf.IsPresent)) { throw 'Unexpected release catalog.' }
foreach ($package in $selected) {
    $source = Join-Path $packageRoot $package.zip
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing approved ZIP: $($package.zip)" }
    $sourceFile = Get-Item -LiteralPath $source
    $sourceHash = Get-FileHash -LiteralPath $source -Algorithm SHA256
    if ($sourceFile.Length -ne $package.zipBytes -or $sourceHash.Hash -ine $package.sha256) {
        throw "ZIP does not match the approved catalog: $($package.zip)"
    }
}

$buildRoot = Join-Path $parent ('.devil-forever-build-' + [guid]::NewGuid().ToString('N'))
$publishRoot = Join-Path $buildRoot 'publish'
New-Item -ItemType Directory -Path $buildRoot | Out-Null
$project = Join-Path $projectRoot 'DevilForever.Installer.csproj'
$artifacts = Join-Path $buildRoot 'artifacts'
$arguments = @($project, '--artifacts-path', $artifacts, '-r', 'win-x64', '-p:SelfContained=true',
    '-p:PublishSingleFile=true', '-p:IncludeNativeLibrariesForSelfExtract=true', '-p:EnableCompressionInSingleFile=true')
$restoreOptions = @()
if ($NuGetConfig) { $restoreOptions += @('--configfile', (Resolve-Path -LiteralPath $NuGetConfig).Path) }
if ($PackagesPath) { $restoreOptions += @('--packages', (Resolve-Path -LiteralPath $PackagesPath).Path) }

dotnet restore @arguments @restoreOptions
if ($LASTEXITCODE -ne 0) { throw "Installer restore exited $LASTEXITCODE." }
dotnet publish @arguments --no-restore -c Release -p:DebugType=None -o $publishRoot
if ($LASTEXITCODE -ne 0) { throw "Installer publish exited $LASTEXITCODE." }
$generated = @(Get-ChildItem -LiteralPath $publishRoot -Force)
if ($generated.Count -ne 1 -or $generated[0].Name -cne 'DevilForeverSetup.exe' -or $generated[0].PSIsContainer) {
    throw 'Publish output does not contain exactly the expected standalone executable.'
}

foreach ($package in $selected) {
    $publishedZip = Join-Path $publishRoot $package.zip
    Copy-Item -LiteralPath (Join-Path $packageRoot $package.zip) -Destination $publishedZip
    if ((Get-FileHash -LiteralPath $publishedZip -Algorithm SHA256).Hash -ine $package.sha256) {
        throw "Packaged file did not match the catalog: $($package.zip)"
    }
}
Copy-Item -LiteralPath (Join-Path $projectRoot '사용안내.md') -Destination (Join-Path $publishRoot '사용안내.md')
$receipt = Get-ChildItem -LiteralPath $publishRoot -File | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{ name = $_.Name; bytes = $_.Length; sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant() }
}
$receipt | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $publishRoot 'release-files.json') -Encoding utf8
$resolvedBuild = (Resolve-Path -LiteralPath $buildRoot).Path
$resolvedPublish = (Resolve-Path -LiteralPath $publishRoot).Path
$resolvedParent = (Resolve-Path -LiteralPath $parent).Path
if ((Split-Path -Parent $resolvedPublish) -ne $resolvedBuild -or (Split-Path -Parent $resolvedBuild) -ne $resolvedParent) {
    throw 'Build or release directory did not resolve under the selected parent.'
}
if (Test-Path -LiteralPath $finalRoot) { throw 'The destination appeared during the build.' }
[IO.Directory]::Move($resolvedPublish, $finalRoot)
Write-Output $finalRoot

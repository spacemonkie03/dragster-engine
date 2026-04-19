param(
    [string]$Ets2ModRoot = "C:\Users\SSS\Documents\Euro Truck Simulator 2\mod",
    [switch]$RefreshDefinitions,
    [switch]$SkipInstallCopy
)

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$modRoot = Join-Path $projectRoot "mod_root"
$distRoot = Join-Path $projectRoot "dist"
$zipPath = Join-Path $distRoot "dragster_engine.zip"
$scsPath = Join-Path $distRoot "dragster_engine.scs"
$installedPath = Join-Path $Ets2ModRoot "dragster_engine.scs"

if (-not (Test-Path $modRoot)) {
    throw "Mod root not found: $modRoot"
}

if ($RefreshDefinitions) {
    & (Join-Path $projectRoot "generate_all_truck_defs.ps1")
}

New-Item -ItemType Directory -Path $distRoot -Force | Out-Null

foreach ($path in @($zipPath, $scsPath)) {
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Force
    }
}

Compress-Archive -Path (Join-Path $modRoot "*") -DestinationPath $zipPath -Force
Move-Item -LiteralPath $zipPath -Destination $scsPath

Write-Host "Built mod package:"
Write-Host "  $scsPath"

if (-not $SkipInstallCopy -and (Test-Path $Ets2ModRoot)) {
    Copy-Item -LiteralPath $scsPath -Destination $installedPath -Force
    Write-Host ""
    Write-Host "Installed copy:"
    Write-Host "  $installedPath"
}
elseif (-not $SkipInstallCopy) {
    Write-Host ""
    Write-Host "ETS2 mod folder not found, so only the dist package was created."
}

Write-Host ""
Write-Host "Share this file:"
Write-Host "  $scsPath"

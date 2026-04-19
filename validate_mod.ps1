param()

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$modRoot = Join-Path $projectRoot "mod_root"
$truckRoot = Join-Path $modRoot "def\vehicle\truck"

$requiredFiles = @(
    (Join-Path $modRoot "manifest.sii"),
    (Join-Path $modRoot "mod_description.txt")
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        throw "Required file missing: $file"
    }
}

if (-not (Test-Path $truckRoot)) {
    throw "Truck definitions folder missing: $truckRoot"
}

$engineFiles = Get-ChildItem -Path $truckRoot -Recurse -File -Filter "dragster_engine.sii"
if ($engineFiles.Count -eq 0) {
    throw "No dragster engine defs were found."
}

foreach ($file in $engineFiles) {
    $truckName = Split-Path (Split-Path $file.DirectoryName -Parent) -Leaf
    $content = Get-Content -LiteralPath $file.FullName -Raw

    if ($content -notmatch [regex]::Escape("accessory_engine_data : dragster_engine.$truckName.engine")) {
        throw "Engine id does not match truck folder in $($file.FullName)"
    }

    if ($content -notmatch '(?m)^\s*name:\s*"Dragster engine"\s*$') {
        throw "Missing Dragster engine display name in $($file.FullName)"
    }

    if ($content -notmatch '(?m)^\s*torque:\s*13558\s*$') {
        throw "Unexpected torque value in $($file.FullName)"
    }

    if ($content -notmatch '(?m)^\s*(?:@include\s+".*"|sounds:)\s*$') {
        throw "Missing stock sound configuration in $($file.FullName)"
    }
}

Write-Host "Validation passed:"
Write-Host "  $($engineFiles.Count) dragster engine defs"

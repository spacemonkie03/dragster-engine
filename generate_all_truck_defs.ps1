param(
    [string[]]$SourceTruckRoots = @(
        "C:\Users\SSS\Documents\Playground\def_extract\def\vehicle\truck",
        "C:\Users\SSS\Documents\Playground\volvo2024_extract\def\vehicle\truck"
    )
)

$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot
$targetTruckRoot = Join-Path $projectRoot "mod_root\def\vehicle\truck"
$resolvedSourceTruckRoots = $SourceTruckRoots | Where-Object { Test-Path $_ }

$customTorqueCurve = @(
    '	torque_curve[]: (300, 0)',
    '	torque_curve[]: (600, 0.08)',
    '	torque_curve[]: (900, 0.10)',
    '	torque_curve[]: (1200, 0.12)',
    '	torque_curve[]: (1500, 0.16)',
    '	torque_curve[]: (1800, 0.24)',
    '	torque_curve[]: (2100, 0.34)',
    '	torque_curve[]: (2300, 0.48)',
    '	torque_curve[]: (2450, 0.68)',
    '	torque_curve[]: (2550, 0.86)',
    '	torque_curve[]: (2650, 1)',
    '	torque_curve[]: (3000, 1)',
    '	torque_curve[]: (4000, 0.97)',
    '	torque_curve[]: (5000, 0.92)',
    '	torque_curve[]: (6000, 0.80)',
    '	torque_curve[]: (7000, 0.62)',
    '	torque_curve[]: (7500, 0.55)',
    '	torque_curve[]: (8000, 0)'
)

function Get-FirstMatch {
    param(
        [string]$Content,
        [string]$Pattern
    )

    $match = [regex]::Match($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if ($match.Success) {
        return $match.Value.TrimEnd()
    }

    return $null
}

function Get-MatchValues {
    param(
        [string]$Content,
        [string]$Pattern
    )

    return [regex]::Matches(
        $Content,
        $Pattern,
        [System.Text.RegularExpressions.RegexOptions]::Multiline
    ) | ForEach-Object { $_.Value.TrimEnd() }
}

function Get-DonorFile {
    param(
        [string]$EngineDir
    )

    $donors = Get-ChildItem -LiteralPath $EngineDir -File -Filter "*.sii" |
        Where-Object { $_.Name -notlike "sound*" -and $_.BaseName -ne "dragster_engine" }

    if (-not $donors) {
        return $null
    }

    $ranked = foreach ($file in $donors) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $priceMatch = [regex]::Match($content, '(?m)^\s*price:\s*(\d+)\s*$')
        $torqueMatch = [regex]::Match($content, '(?m)^\s*torque:\s*(\d+)\s*$')

        [PSCustomObject]@{
            File = $file
            Price = if ($priceMatch.Success) { [int]$priceMatch.Groups[1].Value } else { 0 }
            Torque = if ($torqueMatch.Success) { [int]$torqueMatch.Groups[1].Value } else { 0 }
        }
    }

    return $ranked |
        Sort-Object -Property @{ Expression = "Price"; Descending = $true }, @{ Expression = "Torque"; Descending = $true } |
        Select-Object -First 1 -ExpandProperty File
}

if (Test-Path $targetTruckRoot) {
    Remove-Item -LiteralPath $targetTruckRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $targetTruckRoot -Force | Out-Null

$generatedCount = 0

if ($resolvedSourceTruckRoots.Count -eq 0) {
    throw "No source truck roots were found. Pass -SourceTruckRoots with extracted ETS2 truck definition folders."
}

foreach ($sourceRoot in $resolvedSourceTruckRoots) {

    $truckDirs = Get-ChildItem -LiteralPath $sourceRoot -Directory

    foreach ($truckDir in $truckDirs) {
        $engineDir = Join-Path $truckDir.FullName "engine"
        if (-not (Test-Path $engineDir)) {
            continue
        }

        $donorFile = Get-DonorFile -EngineDir $engineDir
        if ($null -eq $donorFile) {
            continue
        }

        $content = Get-Content -LiteralPath $donorFile.FullName -Raw
        $truckId = $truckDir.Name
        $targetDir = Join-Path $targetTruckRoot "$truckId\engine"
        $targetFile = Join-Path $targetDir "dragster_engine.sii"

        $iconLine = Get-FirstMatch -Content $content -Pattern '(?m)^\s*icon:\s*".*"\s*$'
        $partTypeLine = Get-FirstMatch -Content $content -Pattern '(?m)^\s*part_type:\s*.*$'
        $volumeLine = Get-FirstMatch -Content $content -Pattern '(?m)^\s*volume:\s*.*$'
        $adblueLine = Get-FirstMatch -Content $content -Pattern '(?m)^\s*adblue_consumption:\s*.*$'
        $noAdblueLine = Get-FirstMatch -Content $content -Pattern '(?m)^\s*no_adblue_power_limit:\s*.*$'
        $includeLines = @(Get-MatchValues -Content $content -Pattern '(?m)^\s*@include\s+".*"\s*$')
        $soundLines = @(Get-MatchValues -Content $content -Pattern '(?m)^\s*sounds(?:\[\])?:\s*.*$')
        $overrideLines = @(Get-MatchValues -Content $content -Pattern '(?m)^\s*overrides\[\]:\s*".*"\s*$')

        if (-not $iconLine) {
            $iconLine = '	icon: "engine_01"'
        }

        if (-not $partTypeLine) {
            $partTypeLine = '	part_type: factory'
        }

        if (-not $volumeLine) {
            $volumeLine = '	volume: 15.0'
        }

        if (-not $noAdblueLine) {
            $noAdblueLine = '	no_adblue_power_limit: 0.5'
        }

        $bodyLines = @(
            "SiiNunit",
            "{",
            "accessory_engine_data : dragster_engine.$truckId.engine",
            "{",
            '	name: "Dragster engine"',
            '	price: 50000',
            '	unlock: 0',
            '	info[]: "8@@dg@@600 @@hp@@ (6@@dg@@414 @@kw@@)"',
            '	info[]: "10@@dg@@000 @@lb_ft@@ (13@@dg@@558 @@nm@@)"',
            '	info[]: "2@@dg@@650-5@@dg@@500 @@rpm@@"',
            $iconLine,
            $partTypeLine,
            "",
            '	torque: 13558',
            $volumeLine
        )

        $bodyLines += $customTorqueCurve
        $bodyLines += @(
            '',
            '	rpm_idle: 500',
            '	rpm_limit: 7500',
            '	rpm_limit_neutral: 7500',
            '	rpm_range_low_gear: (1700, 4800)',
            '	rpm_range_high_gear: (2400, 5200)',
            '	rpm_range_power: (3000, 7200)',
            '	rpm_range_engine_brake: (2200, 7500)',
            '',
            '	engine_brake: 2.4',
            '	engine_brake_downshift: 1',
            '	engine_brake_positions: 3'
        )

        if ($adblueLine) {
            $bodyLines += @('', $adblueLine)
        }

        $bodyLines += @('', $noAdblueLine)

        if ($includeLines.Count -gt 0) {
            $bodyLines += @('')
            $bodyLines += $includeLines
        }
        elseif ($soundLines.Count -gt 0) {
            $bodyLines += @('')
            $bodyLines += $soundLines
        }

        if ($overrideLines.Count -gt 0) {
            $bodyLines += @('')
            $bodyLines += $overrideLines
        }

        $bodyLines += @(
            "}",
            "}"
        )

        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Set-Content -LiteralPath $targetFile -Value ($bodyLines -join "`r`n")
        $generatedCount += 1
    }
}

Write-Host "Generated Dragster engine defs:"
Write-Host "  $generatedCount truck families"

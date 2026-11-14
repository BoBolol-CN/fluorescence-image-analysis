$ErrorActionPreference = 'Stop'
$skillName = 'fluorescence-image-analysis'
$skillBase = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'skills' } else { Join-Path $HOME '.codex\skills' }
$skillTarget = Join-Path $skillBase $skillName
if (Test-Path -LiteralPath $skillTarget) { throw "Skill already exists: $skillTarget. Back it up or remove it before reinstalling." }
$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$stagePath = [IO.Path]::GetFullPath((Join-Path $tempBase ('fluorescence-skill-' + [guid]::NewGuid().ToString('N'))))
if (-not $stagePath.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected temporary path' }
New-Item -ItemType Directory -Path $stagePath | Out-Null
try {
    $archivePath = Join-Path $stagePath 'skill.zip'
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BoBolol-CN/fluorescence-image-analysis/main/fluorescence-image-analysis.zip' -OutFile $archivePath
    $actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -ne '1dd9670ad23d0d888dd57e6164e40188c0100184a062348c35d556860da6da5e') { throw 'Archive checksum mismatch. Installation stopped.' }
    Expand-Archive -LiteralPath $archivePath -DestinationPath $stagePath
    $unpacked = Join-Path $stagePath $skillName
    if (-not (Test-Path -LiteralPath (Join-Path $unpacked 'SKILL.md'))) { throw 'SKILL.md not found in package' }
    New-Item -ItemType Directory -Path $skillBase -Force | Out-Null
    Move-Item -LiteralPath $unpacked -Destination $skillTarget
    Write-Host "Installed: $skillTarget" -ForegroundColor Green
    Write-Host 'Open a new Codex chat and use $fluorescence-image-analysis.'
}
finally {
    $resolvedStage = [IO.Path]::GetFullPath($stagePath)
    if ($resolvedStage -eq $stagePath -and $resolvedStage.StartsWith($tempBase, [StringComparison]::OrdinalIgnoreCase) -and (Split-Path $resolvedStage -Leaf) -like 'fluorescence-skill-*') {
        Remove-Item -LiteralPath $resolvedStage -Recurse -Force
    }
}

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$ConfigPath,
  [string]$ArtifactDirectory = '.\artifacts'
)
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\validate-config.ps1" -ConfigPath $ConfigPath
#if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw 'Config validation failed.' }
if (-not $?) { throw 'Config validation failed.' }

$raw = Get-Content -LiteralPath $ConfigPath -Raw
function Get-Scalar([string]$Key, [string]$Default='') {
  $m = [regex]::Match($raw, "(?m)^$([regex]::Escape($Key)):\s*(.*?)\s*$")
  if ($m.Success) { return $m.Groups[1].Value.Trim('"').Trim("'") }
  return $Default
}
$device = Get-Scalar 'device'
$driverVersion = Get-Scalar 'driver_version' 'v1'
$mode = 'simulation'
New-Item -ItemType Directory -Force -Path $ArtifactDirectory | Out-Null
$manifest = [ordered]@{
  project = 'image-factory-demo'
  build_id = [guid]::NewGuid().ToString()
  created_utc = [DateTime]::UtcNow.ToString('o')
  device = $device
  driver_version = $driverVersion
  mode = $mode
  source_config = (Resolve-Path $ConfigPath).Path
  outputs = @('build-manifest.json', 'build-summary.txt')
  warning = 'Simulation only. No bootable WIM/ISO was generated.'
}
$manifestPath = Join-Path $ArtifactDirectory 'build-manifest.json'
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
@"
Image Factory Demo Summary
Device: $device
Driver version: $driverVersion
Mode: SIMULATION
This is not a bootable Windows image.
"@ | Set-Content -LiteralPath (Join-Path $ArtifactDirectory 'build-summary.txt') -Encoding UTF8
Write-Host "Simulation complete. Artifacts written to $ArtifactDirectory" -ForegroundColor Green

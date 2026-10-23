[CmdletBinding()]
param([string]$ArtifactDirectory = '.\artifacts')
$ErrorActionPreference = 'Stop'
$manifest = Join-Path $ArtifactDirectory 'build-manifest.json'
$summary = Join-Path $ArtifactDirectory 'build-summary.txt'
foreach ($p in @($manifest,$summary)) {
  if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Expected artifact missing: $p" }
}
$data = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
if (-not $data.device -or -not $data.driver_version) { throw 'Manifest missing device or driver_version.' }
Write-Host "Artifact validation passed for device=$($data.device), driver_version=$($data.driver_version)" -ForegroundColor Green

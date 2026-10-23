[CmdletBinding()]
param([string]$ArtifactDirectory = '.\artifacts')
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $ArtifactDirectory 'build-manifest.json'
if (-not (Test-Path $manifestPath)) { throw "Build manifest missing. Run simulate-build.ps1 first." }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$pkgDir = Join-Path $ArtifactDirectory 'tanium-package-simulation'
New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
$install = @'
# Tanium package simulation wrapper
$ErrorActionPreference = "Stop"
Write-Output "SIMULATION ONLY: replace this with approved deployment/install actions."
Write-Output "No image is installed or deployed by this wrapper."
exit 0
'@
Set-Content -LiteralPath (Join-Path $pkgDir 'install.ps1') -Value $install -Encoding UTF8
$metadata = [ordered]@{
  package_name = "image-factory-$($manifest.device.ToLower())"
  device = $manifest.device
  driver_version = $manifest.driver_version
  package_type = 'simulation'
  generated_utc = [DateTime]::UtcNow.ToString('o')
  payload = @('install.ps1','build-manifest.json')
  note = 'Not a native Tanium package. Import/format/signing must follow your Tanium environment standards.'
}
$metadata | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $pkgDir 'package-metadata.json') -Encoding UTF8
Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $pkgDir 'build-manifest.json') -Force
$zip = Join-Path $ArtifactDirectory 'tanium-package-simulation.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path (Join-Path $pkgDir '*') -DestinationPath $zip
Write-Host "Created Tanium package simulation: $zip" -ForegroundColor Green

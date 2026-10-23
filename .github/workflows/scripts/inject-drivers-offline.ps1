[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$MountedWindowsImage,
  [Parameter(Mandatory=$true)][string]$DriverRoot
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path (Join-Path $MountedWindowsImage 'Windows'))) {
  throw "Expected mounted Windows image at '$MountedWindowsImage' (must contain Windows folder)."
}
if (-not (Test-Path $DriverRoot)) { throw "Driver root not found: $DriverRoot" }
$infFiles = Get-ChildItem -Path $DriverRoot -Filter '*.inf' -Recurse -File
if (-not $infFiles) { throw "No .inf files found under $DriverRoot; refusing to run DISM." }
foreach ($dir in (Get-ChildItem $DriverRoot -Directory)) {
  $hasInf = Get-ChildItem $dir.FullName -Filter '*.inf' -Recurse -File | Select-Object -First 1
  if ($hasInf) {
    Write-Host "Injecting drivers from $($dir.FullName)"
    & dism.exe /Image:$MountedWindowsImage /Add-Driver /Driver:$($dir.FullName) /Recurse
    if ($LASTEXITCODE -ne 0) { throw "DISM failed for $($dir.FullName), exit code $LASTEXITCODE" }
  }
}
& dism.exe /Image:$MountedWindowsImage /Get-Drivers /Format:Table
if ($LASTEXITCODE -ne 0) { throw 'DISM driver enumeration failed.' }

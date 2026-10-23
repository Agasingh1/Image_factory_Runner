[CmdletBinding()]
param([string]$AppsRoot = "$PSScriptRoot\..\apps")
$ErrorActionPreference = 'Stop'
Write-Host "Application installation stage"
Write-Host "Apps root: $((Resolve-Path $AppsRoot -ErrorAction SilentlyContinue).Path)"
Write-Warning "No vendor installers are bundled. Add approved installers and a reviewed per-app silent argument map before enabling installation."
# Intentionally does not install arbitrary executables automatically.

$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\..\scripts\validate-config.ps1" -ConfigPath "$PSScriptRoot\..\configs\device.yaml"
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw 'Config test failed.' }
Write-Host 'Project smoke test passed.' -ForegroundColor Green

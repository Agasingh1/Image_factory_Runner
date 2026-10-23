[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ConfigPath)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Configuration file not found: $ConfigPath"
}
$content = Get-Content -LiteralPath $ConfigPath -Raw
$required = @('device:', 'driver_version:', 'drivers:', 'apps:', 'registry:', 'autologin:')
foreach ($token in $required) {
    if ($content -notmatch [regex]::Escape($token)) { throw "Missing required YAML key/token: $token" }
}
if ($content -notmatch '(?m)^device:\s*(POS|KIOSK)\s*$') {
    throw "device must be POS or KIOSK for this prototype."
}
if ($content -notmatch '(?m)^driver_version:\s*[A-Za-z0-9._-]+\s*$') {
    throw "driver_version must have a simple version value."
}
if ($content -notmatch '(?m)^\s+autologin:\s*(true|false)\s*$') {
    throw "registry.autologin must be true or false."
}
Write-Host "Configuration validation passed: $ConfigPath" -ForegroundColor Green
Write-Host "Note: this lightweight starter validator checks required YAML structure; use a real YAML parser/schema in production."

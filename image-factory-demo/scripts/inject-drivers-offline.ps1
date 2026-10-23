
param(
    [string]$DriverRoot = "C:\ImageFactory\drivers"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $DriverRoot)) {
    throw "Driver directory not found: $DriverRoot"
}

$InfFiles = Get-ChildItem -Path $DriverRoot -Filter "*.inf" -Recurse -File

if (-not $InfFiles) {
    throw "No INF driver packages found under $DriverRoot"
}

foreach ($Inf in $InfFiles) {
    Write-Host "Installing driver package: $($Inf.FullName)"

    $Output = & pnputil.exe /add-driver $Inf.FullName /install 2>&1
    $ExitCode = $LASTEXITCODE

    $Output | ForEach-Object { Write-Host $_ }

    if ($ExitCode -ne 0) {
        throw "pnputil failed for $($Inf.FullName), exit code $ExitCode"
    }
}

# Report installed third-party driver packages for build logs.
& pnputil.exe /enum-drivers
if ($LASTEXITCODE -ne 0) {
    throw "Failed to enumerate installed driver packages."
}

Write-Host "Driver package installation completed."
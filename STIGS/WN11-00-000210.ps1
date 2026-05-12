<#
.SYNOPSIS
    Disables Bluetooth on Windows 11 systems.

.DESCRIPTION
    This script disables Bluetooth services, Bluetooth devices,
    and enforces the Windows policy setting required for
    DISA STIG WN11-00-000210 compliance.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 2.0
    STIG-ID         : WN11-00-000210
#>

# =========================
# 1. AUTO ELEVATION
# =========================
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell `
        -Verb RunAs `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# =========================
# 2. STIG POLICY REGISTRY KEY
# =========================
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Connectivity"

New-Item `
    -Path $RegistryPath `
    -Force | Out-Null

Set-ItemProperty `
    -Path $RegistryPath `
    -Name "AllowBluetooth" `
    -Type DWord `
    -Value 0

Write-Host "Configured STIG Bluetooth policy registry key"

# =========================
# 3. DISABLE BLUETOOTH SERVICES
# =========================
$BluetoothServices = @(
    "bthserv",
    "BTAGService",
    "BluetoothUserService"
)

foreach ($Service in $BluetoothServices) {

    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {

        Stop-Service `
            -Name $Service `
            -Force `
            -ErrorAction SilentlyContinue

        Set-Service `
            -Name $Service `
            -StartupType Disabled

        Write-Host "Disabled service: $Service"
    }
}

# =========================
# 4. DISABLE BLUETOOTH DEVICES
# =========================
$BluetoothDevices = Get-PnpDevice |
Where-Object {
    $_.Class -eq "Bluetooth" -or
    $_.FriendlyName -match "Bluetooth"
}

foreach ($Device in $BluetoothDevices) {

    Disable-PnpDevice `
        -InstanceId $Device.InstanceId `
        -Confirm:$false `
        -ErrorAction SilentlyContinue

    Write-Host "Disabled device: $($Device.FriendlyName)"
}

# =========================
# 5. FINAL VERIFICATION
# =========================
$Verify = Get-ItemProperty `
    -Path $RegistryPath `
    -Name "AllowBluetooth"

if ($Verify.AllowBluetooth -eq 0) {

    Write-Host "COMPLIANT: Bluetooth disabled per STIG policy." `
        -ForegroundColor Green
}
else {

    Write-Host "NON-COMPLIANT: Bluetooth policy still enabled." `
        -ForegroundColor Red
}

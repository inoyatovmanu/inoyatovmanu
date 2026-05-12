<#
.SYNOPSIS
    Disables Bluetooth functionality on Windows 11 systems.

.DESCRIPTION
    This PowerShell script disables Bluetooth services and Bluetooth radio
    devices to reduce the risk of unauthorized wireless communication and
    data transfer.

    This configuration complies with DISA STIG WN11-00-000210.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-00-000210

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-00-000210.ps1
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
# 2. DISABLE BLUETOOTH SERVICES
# =========================
$BluetoothServices = @(
    "bthserv",
    "BTAGService"
)

foreach ($Service in $BluetoothServices) {

    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {

        Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue

        Set-Service `
            -Name $Service `
            -StartupType Disabled

        Write-Host "Disabled service: $Service" -ForegroundColor Yellow
    }
}

# =========================
# 3. DISABLE BLUETOOTH DEVICES
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

    Write-Host "Disabled Bluetooth device: $($Device.FriendlyName)" `
        -ForegroundColor Yellow
}

# =========================
# 4. VERIFICATION
# =========================
$RemainingDevices = Get-PnpDevice |
Where-Object {
    ($_.Class -eq "Bluetooth" -or
    $_.FriendlyName -match "Bluetooth") `
    -and $_.Status -eq "OK"
}

if (-not $RemainingDevices) {
    Write-Host "COMPLIANT: Bluetooth disabled." -ForegroundColor Green
}
else {
    Write-Host "NON-COMPLIANT: Some Bluetooth devices remain enabled." `
        -ForegroundColor Red
}

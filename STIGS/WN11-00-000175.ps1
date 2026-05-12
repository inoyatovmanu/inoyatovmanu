<#
.SYNOPSIS
    Disables the Secondary Logon service on Windows 11 systems.

.DESCRIPTION
    Disables the "seclogon" service to comply with
    DISA STIG WN11-00-000175.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    STIG-ID         : WN11-00-000175
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
# 2. STOP SERVICE
# =========================
Stop-Service `
    -Name "seclogon" `
    -Force `
    -ErrorAction SilentlyContinue

# =========================
# 3. DISABLE SERVICE
# =========================
sc.exe config seclogon start= disabled | Out-Null

# =========================
# 4. REGISTRY HARDENING
# =========================
Set-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\seclogon" `
    -Name "Start" `
    -Value 4

# =========================
# 5. WAIT FOR SCM REFRESH
# =========================
Start-Sleep -Seconds 5

# =========================
# 6. REFRESH SERVICE INFO
# =========================
$Service = Get-CimInstance Win32_Service `
    -Filter "Name='seclogon'"

$Registry = Get-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\seclogon"

Write-Host "`n========== VERIFICATION =========="

Write-Host "State      : $($Service.State)"
Write-Host "StartMode  : $($Service.StartMode)"
Write-Host "Registry   : $($Registry.Start)"

# =========================
# 7. FINAL COMPLIANCE CHECK
# =========================
if (
    $Service.StartMode -eq "Disabled" -and
    $Registry.Start -eq 4
) {

    Write-Host "`nCOMPLIANT: Secondary Logon service disabled." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: Secondary Logon service still enabled." `
        -ForegroundColor Red
}

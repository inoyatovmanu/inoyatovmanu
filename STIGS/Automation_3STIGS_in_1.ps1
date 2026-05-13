<#
.SYNOPSIS
    Configures Windows 11 account lockout policies in accordance with DISA STIG requirements.

.DESCRIPTION
    This PowerShell script configures the following account lockout policies:

    - WN11-AC-000010
        Account lockout threshold = 3 invalid logon attempts

    - WN11-AC-000020
        Account lockout duration = 15 minutes

    - WN11-AC-000030
        Reset account lockout counter after = 15 minutes

    These settings help mitigate brute-force password attacks and unauthorized
    authentication attempts.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A

    STIG-ID(s)      :
        WN11-AC-000010
        WN11-AC-000020
        WN11-AC-000030

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\Windows11-AccountLockout-STIG-Baseline.ps1
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

Write-Host "`n========== CONFIGURING ACCOUNT LOCKOUT POLICIES ==========" `
    -ForegroundColor Cyan

# =========================
# 2. ACCOUNT LOCKOUT THRESHOLD
# WN11-AC-000010
# =========================
net accounts /lockoutthreshold:3

Write-Host "Configured lockout threshold: 3 attempts" `
    -ForegroundColor Yellow

# =========================
# 3. ACCOUNT LOCKOUT DURATION
# WN11-AC-000020
# =========================
net accounts /lockoutduration:15

Write-Host "Configured lockout duration: 15 minutes" `
    -ForegroundColor Yellow

# =========================
# 4. RESET LOCKOUT COUNTER
# WN11-AC-000030
# =========================
net accounts /lockoutwindow:15

Write-Host "Configured reset lockout counter: 15 minutes" `
    -ForegroundColor Yellow

# =========================
# 5. VERIFICATION
# =========================
Write-Host "`n========== VERIFICATION ==========" `
    -ForegroundColor Cyan

$Policy = net accounts

$Threshold = $Policy | Where-Object {
    $_ -match "Lockout threshold"
}

$Duration = $Policy | Where-Object {
    $_ -match "Lockout duration"
}

$Window = $Policy | Where-Object {
    $_ -match "Lockout observation window"
}

Write-Host "`n$Threshold"
Write-Host $Duration
Write-Host $Window

# =========================
# 6. COMPLIANCE CHECK
# =========================
if (
    ($Threshold -match "3") -and
    ($Duration -match "15") -and
    ($Window -match "15")
) {

    Write-Host "`nCOMPLIANT: Account lockout policies configured correctly." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: One or more account lockout policies failed." `
        -ForegroundColor Red
}

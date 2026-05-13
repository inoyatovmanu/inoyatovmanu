<#
.SYNOPSIS
    Configures the account lockout threshold to 3 invalid logon attempts.

.DESCRIPTION
    This PowerShell script configures the Windows account lockout threshold
    to 3 invalid logon attempts in accordance with DISA STIG
    WN11-AC-000010.

    Configuring account lockout policies helps protect systems against
    brute-force password attacks and unauthorized authentication attempts.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AC-000010

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-AC-000010.ps1
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
# 2. CONFIGURE ACCOUNT LOCKOUT THRESHOLD
# =========================
net accounts /lockoutthreshold:3

Write-Host "Configured account lockout threshold to 3 attempts." `
    -ForegroundColor Yellow

# =========================
# 3. VERIFICATION
# =========================
$LockoutPolicy = net accounts

$ThresholdLine = $LockoutPolicy |
Where-Object { $_ -match "Lockout threshold" }

Write-Host "`n========== VERIFICATION =========="

Write-Host $ThresholdLine

if ($ThresholdLine -match "3") {

    Write-Host "`nCOMPLIANT: Lockout threshold configured correctly." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: Lockout threshold not configured correctly." `
        -ForegroundColor Red
}

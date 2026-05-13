<#
.SYNOPSIS
    Configures password history to remember 24 previous passwords.

.DESCRIPTION
    This PowerShell script configures the Windows password history policy
    to remember 24 previous passwords in accordance with
    DISA STIG WN11-AC-000020.

    Enforcing password history helps prevent users from reusing old passwords
    and strengthens account security by encouraging unique password rotation.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AC-000020

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-AC-000020.ps1
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
# 2. CONFIGURE PASSWORD HISTORY
# =========================
net accounts /uniquepw:24

Write-Host "Configured password history to remember 24 passwords." `
    -ForegroundColor Yellow

# =========================
# 3. VERIFICATION
# =========================
$PasswordPolicy = net accounts

$HistoryLine = $PasswordPolicy |
Where-Object { $_ -match "Length of password history maintained" }

Write-Host "`n========== VERIFICATION =========="
Write-Host $HistoryLine

if ($HistoryLine -match "24") {

    Write-Host "`nCOMPLIANT: Password history configured correctly." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: Password history not configured correctly." `
        -ForegroundColor Red
}

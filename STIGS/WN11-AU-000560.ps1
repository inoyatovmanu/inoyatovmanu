<#
.SYNOPSIS
    Enables auditing for Special Logon events.

.DESCRIPTION
    This PowerShell script configures Advanced Audit Policy
    to audit successful Special Logon events in accordance
    with DISA STIG WN11-AU-000560.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-14
    Last Modified   : 2026-05-14
    Version         : 1.1
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000560

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-AU-000560.ps1
#>

# =========================
# ADMIN CHECK
# =========================

$currentUser = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $currentUser.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host "Run PowerShell as Administrator." `
        -ForegroundColor Red

    exit
}

# =========================
# CONFIGURE AUDIT POLICY
# =========================

auditpol /set `
/subcategory:"Special Logon" `
/success:enable `
/failure:disable

Write-Host "Configured Audit Special Logon policy." `
    -ForegroundColor Yellow

# =========================
# VERIFICATION
# =========================

$Result = auditpol /get `
/subcategory:"Special Logon"

Write-Host "`n========== VERIFICATION =========="
$Result

# =========================
# COMPLIANCE CHECK
# =========================

if ($Result -match "Success") {

    Write-Host "`nCOMPLIANT" `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT" `
        -ForegroundColor Red
}

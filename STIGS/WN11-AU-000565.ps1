<#
.SYNOPSIS
    Configures Audit Other Logon/Logoff Events for DISA STIG compliance.
.DESCRIPTION
    Enables "Failure" auditing for Other Logon/Logoff Events
    in accordance with DISA STIG WN11-AU-000565.
.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatovmanu/
    GitHub          : https://github.com/inoyatovmanu
    STIG-ID         : WN11-AU-000565
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
# APPLY AUDIT POLICY
# =========================
# STIG requires Failure auditing for Other Logon/Logoff Events
auditpol /set /subcategory:"Other Logon/Logoff Events" /failure:enable
# =========================
# VERIFICATION
# =========================
Write-Host "`n========== VERIFICATION =========="
$AuditResult = auditpol /get /subcategory:"Other Logon/Logoff Events"
$AuditResult
# =========================
# COMPLIANCE CHECK
# =========================
if ($AuditResult | Select-String "Failure") {
    Write-Host "`nCOMPLIANT" `
        -ForegroundColor Green
} else {
    Write-Host "`nNON-COMPLIANT" `
        -ForegroundColor Red
}

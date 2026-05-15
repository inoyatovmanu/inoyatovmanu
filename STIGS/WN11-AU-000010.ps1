<#
.SYNOPSIS
    Configures the Application Event Log maximum size to 32768 KB (32 MB).

.DESCRIPTION
    This PowerShell script configures the Windows Application Event Log
    maximum size to at least 32768 KB (32 MB) in accordance with
    DISA STIG WN11-AU-000010.

    Proper log sizing helps ensure sufficient retention of application
    audit events for troubleshooting, monitoring, and forensic analysis.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-14
    Last Modified   : 2026-05-14
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000010

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-AU-000010.ps1
#>

# =========================
# 1. AUTO ELEVATION
# =========================

$currentUser = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $currentUser.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Start-Process powershell `
        -Verb RunAs `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""

    exit
}

# =========================
# 2. POLICY REGISTRY CONFIGURATION
# =========================

$PolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"

New-Item `
    -Path $PolicyPath `
    -Force | Out-Null

New-ItemProperty `
    -Path $PolicyPath `
    -Name "MaxSize" `
    -PropertyType DWord `
    -Value 32768 `
    -Force | Out-Null

Write-Host "Configured policy registry value."

# =========================
# 3. LIVE SYSTEM CONFIGURATION
# =========================

$SystemPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application"

# 32768 KB = 33554432 bytes
Set-ItemProperty `
    -Path $SystemPath `
    -Name "MaxSize" `
    -Value 33554432

Write-Host "Configured live Application Event Log size."

# =========================
# 4. APPLY LIVE EVENT LOG SIZE
# =========================

wevtutil sl Application /ms:33554432

Write-Host "Applied live event log configuration."

# =========================
# 5. VERIFICATION
# =========================

$PolicyVerify = Get-ItemProperty `
    -Path $PolicyPath

$SystemVerify = Get-ItemProperty `
    -Path $SystemPath

Write-Host "`n========== VERIFICATION =========="

Write-Host "Policy MaxSize : $($PolicyVerify.MaxSize) KB"
Write-Host "System MaxSize : $($SystemVerify.MaxSize) Bytes"

wevtutil gl Application | Select-String "maxSize"

# =========================
# 6. COMPLIANCE CHECK
# =========================

if (
    $PolicyVerify.MaxSize -ge 32768 -and
    $SystemVerify.MaxSize -ge 33554432
) {

    Write-Host "`nCOMPLIANT: Application Event Log configured correctly." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: Application Event Log configuration failed." `
        -ForegroundColor Red
}

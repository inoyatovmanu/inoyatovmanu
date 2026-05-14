<#
.SYNOPSIS
    Configures the Security Event Log maximum size to 1024000 KB (1 GB).

.DESCRIPTION
    This PowerShell script configures the Windows Security Event Log
    maximum size to at least 1024000 KB (1 GB) in accordance with
    DISA STIG WN11-AU-000005.

    Increasing the Security Event Log size helps ensure audit records
    are retained long enough for security investigations, incident
    response, and forensic analysis.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000005

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-AU-000005.ps1
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
# 2. CONFIGURE SECURITY EVENT LOG SIZE
# =========================

# Registry value uses KB
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"

# Create path if missing
New-Item `
    -Path $RegistryPath `
    -Force | Out-Null

# Set log size to 1024000 KB (1 GB)
Set-ItemProperty `
    -Path $RegistryPath `
    -Name "MaxSize" `
    -Type DWord `
    -Value 1024000

Write-Host "Configured Security Event Log registry policy." `
    -ForegroundColor Yellow

# =========================
# 3. APPLY LIVE EVENT LOG SIZE
# =========================

# wevtutil uses BYTES
wevtutil sl Security /ms:1048576000

Write-Host "Applied Security Event Log size to live configuration." `
    -ForegroundColor Yellow

# =========================
# 4. VERIFICATION
# =========================
$RegistryVerify = Get-ItemProperty `
    -Path $RegistryPath `
    -Name "MaxSize"

$LiveLog = wevtutil gl Security

Write-Host "`n========== VERIFICATION =========="

Write-Host "Registry MaxSize : $($RegistryVerify.MaxSize) KB"

$LiveLog | Select-String "maxSize"

# =========================
# 5. COMPLIANCE CHECK
# =========================
if ($RegistryVerify.MaxSize -ge 1024000) {

    Write-Host "`nCOMPLIANT: Security Event Log size configured correctly." `
        -ForegroundColor Green
}
else {

    Write-Host "`nNON-COMPLIANT: Security Event Log size not configured correctly." `
        -ForegroundColor Red
}

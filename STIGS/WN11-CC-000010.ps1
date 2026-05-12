<#
.SYNOPSIS
    Disables lock screen slide shows on Windows 11 systems.

.DESCRIPTION
    This PowerShell script disables the display of slide shows on the Windows
    lock screen to prevent the potential exposure of sensitive information
    to unauthorized users.

    This configuration complies with DISA STIG WN11-CC-000010.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-12
    Last Modified   : 2026-05-12
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000010

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-CC-000010.ps1
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
# 2. REGISTRY CONFIGURATION
# =========================
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"

# Create registry path if missing
New-Item -Path $RegistryPath -Force | Out-Null

# Disable lock screen slideshow
Set-ItemProperty `
    -Path $RegistryPath `
    -Name "NoLockScreenSlideshow" `
    -Type DWord `
    -Value 1

# =========================
# 3. VERIFICATION
# =========================
$Verify = Get-ItemProperty `
    -Path $RegistryPath `
    -Name "NoLockScreenSlideshow"

if ($Verify.NoLockScreenSlideshow -eq 1) {
    Write-Host "COMPLIANT: Lock screen slideshow disabled." -ForegroundColor Green
} else {
    Write-Host "NON-COMPLIANT: Configuration failed." -ForegroundColor Red
}

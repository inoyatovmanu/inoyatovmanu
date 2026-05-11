<#
.SYNOPSIS
    This PowerShell script disables the Windows Installer AlwaysInstallElevated policy by setting the registry value to 0.

.DESCRIPTION
    The "AlwaysInstallElevated" policy allows MSI packages to install with elevated
    privileges when enabled. If this setting is configured in both HKLM and HKCU,
    non-privileged users may execute malicious MSI installers with SYSTEM-level
    permissions, resulting in local privilege escalation.

    This script ensures the policy is disabled in accordance with DISA STIG
    WN11-CC-000315 to reduce the risk of unauthorized privilege escalation.

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-11
    Last Modified   : 2026-05-11
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000315

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Run this script with administrative privileges.

    Example syntax:
    PS C:\> .\STIG-ID-WN11-CC-000315.ps1
#>
# Run PowerShell as Administrator

$Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"

# Create the registry path if it does not exist
New-Item -Path $Path -Force | Out-Null

# Set AlwaysInstallElevated to 0 (disabled)
Set-ItemProperty `
    -Path $Path `
    -Name "AlwaysInstallElevated" `
    -Type DWord `
    -Value 0

<#
.SYNOPSIS
    Enables BitLocker full disk encryption on Windows 11 system drive.

.DESCRIPTION
    This script enables BitLocker using a safe, enterprise-grade approach:
    - Prevents duplicate TPM/recovery protector errors
    - Fixes Enable-BitLocker parameter set conflict
    - Ensures idempotent execution (safe to re-run)
    - Validates TPM readiness
    - Complies with DISA STIG WN11-00-000030

.NOTES
    Author          : Manuchehr Inoyatov
    LinkedIn        : https://www.linkedin.com/in/inoyatov-manu/
    GitHub          : https://github.com/inoyatovmanu
    Date Created    : 2026-05-11
    Last Modified   : 2026-05-11
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-00-000030

.TESTED ON
    Date(s) Tested  :
    Tested By       :
    Systems Tested  :
    PowerShell Ver. :

.USAGE
    Run this script as Administrator.

    Example:
    PS C:\> .\STIG-ID-WN11-00-000030.ps1
#>

# =========================
# 1. AUTO ELEVATION
# =========================
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# =========================
# 2. TPM CHECK
# =========================
$TPM = Get-Tpm

if (-not $TPM.TpmPresent) {
    Write-Host "ERROR: TPM not detected" -ForegroundColor Red
    exit
}

if (-not $TPM.TpmReady) {
    Write-Host "ERROR: TPM not ready. Enable in BIOS/UEFI." -ForegroundColor Yellow
    exit
}

# =========================
# 3. GET BITLOCKER STATUS
# =========================
$bitlocker = Get-BitLockerVolume -MountPoint "C:"

# =========================
# 4. ENABLE BITLOCKER (FIXED LOGIC)
# =========================
if ($bitlocker.VolumeStatus -eq "FullyDecrypted") {
    Enable-BitLocker `
        -MountPoint "C:" `
        -EncryptionMethod XtsAes256 `
        -UsedSpaceOnly `
        -SkipHardwareTest
}

# =========================
# 5. TPM PROTECTOR (NO DUPLICATES)
# =========================
$bitlocker = Get-BitLockerVolume -MountPoint "C:"

$existingTPM = $bitlocker.KeyProtector | Where-Object {
    $_.KeyProtectorType -eq "Tpm"
}

if (-not $existingTPM) {
    Add-BitLockerKeyProtector -MountPoint "C:" -TpmProtector
} else {
    Write-Host "TPM protector already exists"
}

# =========================
# 6. RECOVERY KEY PROTECTOR (NO DUPLICATES)
# =========================
$existingRecovery = $bitlocker.KeyProtector | Where-Object {
    $_.KeyProtectorType -eq "RecoveryPassword"
}

if (-not $existingRecovery) {
    Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
}

# =========================
# 7. ENSURE ENCRYPTION RUNS
# =========================
Resume-BitLocker -MountPoint "C:"

# =========================
# 8. FINAL STATUS
# =========================
Get-BitLockerVolume -MountPoint "C:"

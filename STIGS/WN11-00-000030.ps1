<#
.SYNOPSIS
    Enables BitLocker full disk encryption on Windows 11 system drive.

.DESCRIPTION
    This script enables BitLocker using a safe, enterprise-grade approach:
    - Prevents duplicate TPM/recovery protector errors
    - Fixes Enable-BitLocker parameter set conflict
    - Ensures idempotent execution (safe to re-run)
    - Complies with DISA STIG WN11-00-000031 / WN11-00-000032

.NOTES
    Author  : Manuchehr Inoyatov
    STIG-ID : WN11-00-000031
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
    Write-Host "ERROR: TPM not ready. Enable in BIOS." -ForegroundColor Yellow
    exit
}

# =========================
# 3. ENABLE BITLOCKER (FIXED PARAMETER ISSUE)
# =========================
$bitlocker = Get-BitLockerVolume -MountPoint "C:"

if ($bitlocker.VolumeStatus -eq "FullyDecrypted") {
    Enable-BitLocker `
        -MountPoint "C:" `
        -EncryptionMethod XtsAes256 `
        -UsedSpaceOnly `
        -SkipHardwareTest
}

# =========================
# 4. TPM PROTECTOR (NO DUPLICATES)
# =========================
$existingTPM = $bitlocker.KeyProtector | Where-Object {
    $_.KeyProtectorType -eq "Tpm"
}

if (-not $existingTPM) {
    Add-BitLockerKeyProtector -MountPoint "C:" -TpmProtector
} else {
    Write-Host "TPM protector already exists"
}

# =========================
# 5. RECOVERY KEY PROTECTOR (SAFE)
# =========================
$existingRecovery = $bitlocker.KeyProtector | Where-Object {
    $_.KeyProtectorType -eq "RecoveryPassword"
}

if (-not $existingRecovery) {
    Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
}

# =========================
# 6. RESUME ENCRYPTION
# =========================
Resume-BitLocker -MountPoint "C:"

# =========================
# 7. STATUS OUTPUT
# =========================
Get-BitLockerVolume -MountPoint "C:"

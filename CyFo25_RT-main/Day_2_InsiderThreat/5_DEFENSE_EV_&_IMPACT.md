
# Step 6: Trigger Execution of Payloads

**Objective**: Activate the previously deployed defense evasion and wiper payloads by dropping trigger files onto target systems. This initiates execution of `disable_defender_triggered.ps1` (via GPO) and `wiper_triggered.ps1` (via scheduled task).

---

## Context

- The Defender-disable script is already deployed via GPO and configured to run on startup
- The wiper script is deployed to key infrastructure and scheduled to execute
- Both scripts require presence of specific trigger files to activate their logic

---

## Execution

### 1. Drop the AV/EDR Disable Trigger File

On each targeted workstation (covered by the GPO):

```powershell
New-Item "C:\Windows\Temp\run_trigger.txt" -Force
```

### 2. Drop the Wiper Trigger File

On each HVT with a scheduled task (`infra-file`, `infra-sql`, `rnd-infra`):

```powershell
New-Item "C:\Windows\Temp\wipe_trigger.txt" -Force
```

### 3. Reboot Systems or Wait for Scheduled Time

- For Defender disablement: reboot or wait for natural GPO startup execution
- For wiper activation: wait until scheduled task time (e.g., 02:00 AM)

```powershell
Restart-Computer
```

---

## Result

- Defender is disabled on workstations with the trigger file in place
- Wiper executes on high-value targets, destroying files or causing disruption
- Red Team achieves timed impact while avoiding early detection

---

## Detection Opportunities

| Vector | Description |
|--------|-------------|
| File System | Creation of `run_trigger.txt` or `wipe_trigger.txt` |
| Event ID 7036 | Service stop (WinDefend or Sense) |
| Behavior | Mass deletions, unexpected task execution, reboots |

---

## Defensive Countermeasures

- Monitor `C:\Windows\Temp\` for suspicious file creations
- Alert on startup script execution or tampering in GPO
- Enable scheduled task logging and block unapproved task creation

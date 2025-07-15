
# Red Team Day 2: Issues and Improvement Tracker

This document is used to track open questions, pending decisions, and stealth improvements for the Day 2 Insider Threat simulation.

---

## Open Questions

### 1. Cleanup Plan
- What are the procedures for safely removing:
  - Beacon artifacts
  - Startup scripts in SYSVOL
  - Created backdoor accounts (e.g., `svc_account`)
  - Scheduled tasks for wiper payloads

### 2. Trigger File Naming
- Consider renaming:
  - `run_trigger.txt` → something less suspicious (e.g., `config_update.flag`)
  - `wipe_trigger.txt` → something plausible (e.g., `system_health.chk`)
- Goal: Blend in with legitimate temp/config files

### 3. HVT
- Finalize HVTs:
  - File
  - Web
  - HR Subnet 

---

## Additional Stealth Options

- **GPO Stealth:**
  - Use existing GPO names or modify legitimate ones
  - Place startup scripts deeper in legitimate-looking folder structures

- **Account Obfuscation:**
  - Use naming convention consistent with service accounts (e.g., `svc_websvc01`)
  - Apply "description" fields that match real services

- **Persistence Hygiene:**
  - Use Scheduled Task names that match Windows update behavior
  - Time beacon callbacks to off-peak hours

- **Execution Timing:**
  - Deploy payloads during change windows or patch reboots
  - Trigger wiper just after business hours to delay detection

- **Detection Resistance:**
  - Compress/encrypt scripts in SYSVOL and decrypt at runtime
  - Use encoded PowerShell for script execution

---

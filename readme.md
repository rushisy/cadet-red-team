# 🔴 Red Team Personas — CF25

> Contribute daily mock personas for our CF25 Red Team exercise.

---

## 📂 Table of Contents

1. [Getting Started](#getting-started)  
2. [Assumptions](#assumptions)  
3. [Key Questions](#key-questions)  
4. [Hierarchy Overview](#hierarchy-overview)  
5. [Preview](#preview)  

---

## 🛠 Getting Started

- **Collaborators:**  
  Request to be added, or fork this repo and open a PR against **main**.  
- **Structure:**  
  Personas are grouped by “day” folders under `personas/`.  

---

## 🤔 Assumptions

- Client-to-server connectivity is still in progress.  
  > _Assuming JV will configure VMs manually and handle persona uploads._  
- Each JSON persona file lives in its respective `personas/dayX/` directory.  

---

## ❓ Key Questions

1. **Timelines:**  
   Do we need in-depth timelines for each persona?  
2. **Data Source → Grafana:**  
   - How do we connect our client data source to the Grafana frontend?  
   - Will our VM use the same PostgreSQL backend regardless of OS?  
3. **Role Assignment:**  
   Where should we map the “Role” field from `Enrichment_Reqs.xlsx`?  
4. **Enclave Mapping:**  
   Which enclave houses all Red Team personas within our infrastructure?  

---

## 🌳 Campaign → Enclave → Team Hierarchy

```text
CF25
|---- day#
|    |---- Red Team
|    |    |---- Machine

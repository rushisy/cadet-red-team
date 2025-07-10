# 🔴 Red Team Personas — CF25

> Request to be added as a collaborator, or fork the repo and open a pull request to contribute to `main`.

- Mock personas are populated by day.

---

## 🧠 Assumptions

- Still figuring out how to connect client to server.  
  _(Assuming JV will take care of this if he is manually configuring virtual machines.)_  
  - **JV:** You should hopefully be able to download each persona (`.json`) file and upload to respective client.

---

## ❓ Questions

- Do we need to make timelines for each persona?
- How do we connect a data source (client) to Grafana (frontend server)?
  - The example (admin sequence from documentation) uses a PostgreSQL data source.  
    Is it the same backend on our virtual machine regardless of operating system?
- We winged the file structure — where do we assign the specific "Role" (from `Enrichment_Reqs.xlsx`)?
- Which enclave in red team infrastructure has all the red team personas?

---

## 🗂 Campaign-Enclave-Team Hierarchy

From my understanding...  
_(Will ask for pipeline from client (machine) to Cyber Fortress)_

```text
CF25
|---- day#
|    |---- Red Team
|    |    |---- Machine

![Localhost8080 NPC Previews](docs/localhost8080%20preview.png)
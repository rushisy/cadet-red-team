# Red Team Personas CF25

request to be added as a collaborator, or fork the repo and open a pull request to contribute to main.

- mock personas are populated by day

## Assumptions

- still figuring out how to connect client to server (assmuing JV will take care of this if he is manually configuring virtual machines)
    - JV, you should hopefully be able to download each persona (json) file and upload to respective client
- if you are a contributor (cadet), you have ghost server api installed properly: https://cmu-sei.github.io/GHOSTS/core/api/

## Questions

- do we need to make timelines for each persona?
- how do we connect a data source (client) to grafana (frontend server)?
    - the example (admin sequence from documentation) uses a postgresql data source, is it the same backend on our virtual machine regardless of operating system?
- we winged the file structure, where do we assign the specific "Role" (from [Enrichment_Reqs.xlsx](docs/Enrichment_Reqs.xlsx))?
- which enclave in red team infrastructure has all the red team personas?

## Campaign-Enclave-Team Hierarchy

from my understanding... (will ask for pipeline from client (machine) to Cyber Fortress)
```text
CF25
|---- day#
|    |---- Red Team
|    |    |---- Machine
```

![Localhost8080 NPC Previews](docs/localhost8080%20preview.png)
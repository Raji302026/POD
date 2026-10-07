# Azure DevOps Learning Log

Owner: Raji
Started: 2026-10-07

## 2026-10-07 - JMESPath queries (the --query syntax of the az CLI)
- What it does: filters and reshapes JSON output. [?result=='failed'] keeps matching rows, and {pipeline:name, branch:branch} picks and renames fields.
- Commands I ran: jp.py -f runs.json "[?result=='failed'].{pipeline:name, branch:branch}" returned build-web (dev) and deploy-api (main).
- What went wrong and how I fixed it: file not found because my terminal was in /workspaces/POD and the file was in ~/cli-practice. Fixed with cd ~/cli-practice, and I use pwd to check my folder.
- How it applies to Robility: filter ~400 pipeline runs for failures and show only name and branch.
- Status: tried (offline practice, not yet against real Azure DevOps)
- Summary line for Webex: Practiced JMESPath filtering and field selection used by the az devops CLI (Azure DevOps automation); mapped to Robility pipeline audit.

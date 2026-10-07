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

## 2026-10-07 - GitHub CLI (gh) workflow runs and --jq filtering
- What it does: gh lists and queries workflow runs from the terminal. --json picks fields and --jq filters them using jq syntax (not JMESPath).
- Commands I ran: gh workflow list; gh run list --limit 5; gh run list --limit 5 --json databaseId,name,conclusion --jq '.[] | select(.conclusion=="failure")' returned 1 failed run; counted failures with length.
- What went wrong and how I fixed it: gh workflow run returned HTTP 403 (Resource not accessible by integration) because the Codespaces token cannot start workflows. Fixed by signing in on github.com and using the Run workflow button on the Actions page. Also had a typo in my first command (should_fail=fals).
- What I noticed: GitHub showed a notice that ubuntu-latest will move to Ubuntu 26 on 2026-10-19. Pinning a version (for example ubuntu-24.04) avoids surprise changes.
- Difference to remember: az --query uses JMESPath; gh --jq uses jq.
- How it applies to Robility: same filter-and-pick pattern for auditing failed pipeline runs; pinning the agent image (vmImage) in Azure DevOps pipelines avoids breakage when latest changes.
- Status: tried (real runs on GitHub; Azure DevOps not yet)
- Summary line for Webex: Practiced GitHub CLI (gh) workflow runs, jq filtering and manual workflow_dispatch triggers (CI/CD automation); mapped to Robility pipeline failure audit.

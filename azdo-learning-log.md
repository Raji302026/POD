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

## 2026-10-07 - Branch protection with a required status check (GitHub ruleset)
- What it does: a ruleset on main requires changes to come through a pull request and requires the build-check status check to pass before merge. This is the GitHub equivalent of an Azure DevOps branch policy with build validation.
- Commands I ran: created pr-check.yml (runs on pull_request, pinned to ubuntu-24.04); opened PR 1 (check passed, merged with gh pr merge 1 --merge); tried git push straight to main (rejected with GH013); opened PR 2 containing the forbidden word (check failed, mergeStateStatus BLOCKED, gh pr merge refused); read the failure with gh run view --log-failed; fixed it, check passed, merged.
- What went wrong and how I fixed it: I left a quote open in a commit message and the terminal showed a > prompt; Ctrl+C cancelled it and I retyped the command. I also noticed gh offers an --admin flag to override a policy, which only works if the bypass list allows it.
- Key learning: the merge commit keeps the branch history (seen with git log --graph). A required check should have run at least once before it can be selected in the ruleset.
- How it applies to Robility: put build validation branch policies on main of shared repos such as pipeline-templates so a broken template cannot merge, and keep the bypass list small.
- Status: proven in a sandbox repo on GitHub; the Azure DevOps equivalent is not yet tried
- Summary line for Webex: Practiced branch protection rulesets with a required status check and PR-based merging on GitHub (branch policies and build validation); mapped to Robility shared pipeline-templates repo.

## 2026-10-07 - Scanning for secrets before pushing to a public repo, and organizing practice files
- What it does: before pushing files to a public repo, search them for passwords, tokens and keys so nothing sensitive is published.
- Commands I ran: gitleaks dir k8s-practice (the tool was not installed in this Codespace); used grep -rniE "password|passwd|token|api[_-]?key|secret|BEGIN .*PRIVATE KEY|AKIA[0-9A-Z]{16}" k8s-practice/ instead; moved 19 manifests into k8s-practice with mkdir and mv; committed them through PR 4 (check passed, merged).
- What went wrong and how I fixed it: gitleaks was missing, so I used grep as a backup. I also mistyped git checkout main. with a dot, stayed on the wrong branch, and fixed it with git checkout main followed by git checkout -B to restart the branch from main.
- Key learning: matches such as secretKeyRef are only names and are fine; a real value is the problem. A secret pushed to a public repo should be treated as leaked even if deleted later, so scan before the first push.
- How it applies to Robility: add a secret-scanning step to PR validation pipelines so credentials are caught before code reaches main.
- Status: tried (sandbox repo)
- Summary line for Webex: Scanned Kubernetes manifests for secrets before publishing and organized them into a repo folder via a protected-branch PR (secret scanning, DevSecOps hygiene); mapped to Robility PR validation pipelines.

## 2026-10-07 - Secret scanning as a required PR check (gitleaks)
- What it does: a second job, secret-scan, runs gitleaks on every pull request and fails the check if it finds a credential. I made it a required check in the ruleset so a leak cannot be merged.
- Commands I ran: added the secret-scan job to pr-check.yml (gitleaks pinned to v8.30.1, runner pinned to ubuntu-24.04); opened PR 6 (both checks passed, merged); added both checks as required in the ruleset in the browser; opened PR 7 with a fake credential in fake-config.txt (secret-scan failed, merge state BLOCKED, gh pr merge refused); closed it with gh pr close 7 --delete-branch instead of merging; added --verbose to the scan so the log names the file that matched.
- What went wrong and how I fixed it: I typed job names as commands by mistake (command not found, harmless); a gh command with a cut-off quote was cancelled with Ctrl+C and retyped; a stale remote branch bookmark was removed with git fetch --prune.
- Key learning: deleting the file in a later commit does not remove a secret from Git history, so the right response is to close the PR, delete the branch and rotate a real credential. Scanning only protects the repo when it is a required check.
- How it applies to Robility: add a secret-scan stage to PR validation pipelines for shared repos and make it a required build policy on main.
- Status: proven in a sandbox repo on GitHub; the Azure DevOps equivalent is not yet tried
- Summary line for Webex: Added a gitleaks secret-scan as a required PR check and proved it blocks a merge containing a fake credential (secret scanning, branch policies, DevSecOps); mapped to Robility PR validation pipelines.

## 2026-10-07 - Environments with required reviewers (deployment approval gate)
- What it does: a job linked to an environment with required reviewers pauses until a reviewer approves. The staging environment has no rules; production requires an approval.
- Commands I ran: created staging and production environments in repo settings (production with a required reviewer); added deploy-demo.yml with deploy-staging and deploy-production (needs: deploy-staging); merged it through PR 9; ran it from the Actions page and approved production with a comment; verified with gh run list, gh run view --json jobs --jq, and gh api .../approvals (state approved, user Raji302026, comment "approved for practice").
- What I noticed: the production job showed a Waiting status until I approved it, and the total run time of 3m50s included the time spent waiting. Approvals are recorded and can be queried through the API.
- What went wrong and how I fixed it: nothing broke in this block. gh workflow run cannot start workflows from Codespaces (403), so I started it from the Actions page.
- Key learning: I left Prevent self-review off so I could approve my own deployment while practicing; on a real team it should be on so a different person approves.
- How it applies to Robility: Azure DevOps environments with approvals and checks gate deployments to SIT and Production, and this is the same pattern.
- Status: proven in a sandbox repo on GitHub; Azure DevOps environments not yet tried
- Summary line for Webex: Configured GitHub environments with required reviewers and ran a two-stage deploy that paused for production approval (deployment gates, approvals); mapped to Robility SIT and Production deployments.

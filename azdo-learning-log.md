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

## 2026-10-08 - Reusable workflows with inputs (twin of Azure Pipelines templates)
- What it does: A reusable workflow (`on: workflow_call`) declares inputs, and a caller workflow uses it with `uses:` and `with:`. One shared definition can run many times with different values, the same idea as `template:` with `parameters:` in Azure Pipelines.
- Commands run: created `reusable-build.yml` (inputs `app-name` and `run-tests`) and `call-reusable.yml` (two calls: ticketing-portal with tests, robility-docs without). Merged through PR #11 with both required checks passing, then ran the caller. Verified with `gh run view <id> --json jobs --jq`: "Run tests" was `success` in build-portal and `skipped` in build-docs.
- What went wrong and how I fixed it: nothing failed in this lab. Earlier cleanup typo (trailing dot in the branch name) was fixed by retyping the delete command without it.
- How it applies to Robility: the shared pipeline-templates repo does the same job. Teams call one template with parameters instead of copying YAML, so a fix in one place reaches all callers. Next step is to compare with Azure Pipelines `template:` and `extends`.
- Status: [x] tried
- Summary line for Webex: "Practiced reusable workflows with inputs (twin of Azure Pipelines templates) and verified conditional steps with the GitHub CLI; mapped to Robility shared pipeline templates."

## 2026-10-08 - Variables, secrets and OIDC (twin of variable groups, secret variables and workload identity federation)
- What it does: Repo variables are plain values, secrets are write-only and masked in logs, and OIDC lets a job prove its identity with a short-lived signed token instead of a stored password. Azure trusts the token by matching its issuer and subject.
- Commands run: created variable APP_ENV and secret DEMO_SECRET (fake value), ran vars-and-secrets.yml and saw the variable in plain text and the secret as *** with length 21. Ran oidc-claims.yml with `permissions: id-token: write` and printed only the claims (iss, sub, aud, repository, ref). Merged through PRs #13 and #14.
- What went wrong and how I fixed it: pasted the placeholder `<ID>` and `12345` into `gh run view`, which gave a shell error and HTTP 404. Fixed by running `gh run list` first and using the real run ID. Also ran the log command before clicking Run workflow, which returned "no runs found".
- How it applies to Robility: service connections that use a client secret can expire and break pipelines. Workload identity federation removes the secret. Secret variables in variable groups should be mapped into env explicitly, and the token itself must never be printed.
- Status: [x] tried
- Summary line for Webex: "Practiced repo variables, masked secrets and OIDC token claims (twin of variable groups and workload identity federation); mapped to Robility service connections."

## 2026-10-08 - Azure Pipelines YAML offline: templates, parameters and extends
- What it does: A steps template declares typed parameters (string, boolean, stepList) with defaults and allowed values, and a pipeline inserts it with `- template:`. With `extends:`, the pipeline must run inside a parent template that wraps the team's steps with mandatory ones (for example a secret scan), so teams cannot skip them. `${{ if }}` is a compile-time condition, so a false condition removes the step from the pipeline entirely, unlike a GitHub Actions `if:` which skips at runtime.
- Commands run: wrote azure-pipelines-practice/ with templates/build-steps.yml, azure-pipelines.yml (two template calls with different parameters), templates/secure-pipeline.yml and azure-pipelines-extends.yml. Checked all four files parse as YAML with PyYAML.
- What went wrong and how I fixed it: a long paste was cut off and repeated, leaving the shell mid-heredoc. Fixed with Ctrl+C and `ls` to see which files existed. Limitation: this only proves the YAML syntax is valid. I could not run the pipelines in Azure DevOps, so the schema and behavior are untested.
- How it applies to Robility: the shared pipeline-templates repo can use `extends` so every pipeline gets the same mandatory steps. In Azure DevOps, pair it with a Required template check on environments or service connections so pipelines that do not extend the approved template are blocked.
- Status: [x] read only  [x] tried (syntax only)  [ ] proven in sandbox
- Summary line for Webex: "Wrote Azure Pipelines templates with typed parameters and an extends template that enforces mandatory steps (syntax checked offline); mapped to Robility shared pipeline templates."

## 2026-10-08 - Containers in CI: Dockerfile, SHA tags and Trivy image scan gate
- What it does: A Dockerfile packages an app into an image, and a container is a running copy of that image. A CI workflow builds the image on every PR, tags it with the commit SHA so each image is traceable to its code, and scans it with Trivy, failing the job on fixable HIGH and CRITICAL CVEs.
- Commands run: wrote docker-practice/ (nginx:1.27-alpine with one HTML file), built and ran it locally and tested with curl, then added .github/workflows/docker-build.yml with a build step and a Trivy scan (aquasec/trivy:0.57.1, severity CRITICAL,HIGH, --ignore-unfixed, --exit-code 1). The scan failed on libxml2, musl, nghttp2-libs and zlib in the old base layer. Added `RUN apk upgrade --no-cache` to the Dockerfile and the scan passed. Merged through PR #18.
- What went wrong and how I fixed it: the first scan failed as intended, and I read the CVE table (package, CVE, installed version, fixed version). Running Trivy locally pegged the Codespace CPU and re-downloaded the database each time because of --rm, and returned exit code 2 with no results table, which I did not diagnose. I used CI as the source of truth instead. I also used the placeholder 12345 instead of a real run ID and got HTTP 404; fixed with `gh run list` first.
- How it applies to Robility: the container inventory and VAPT work. A scan gate stops images with known fixable CVEs from reaching deployment, and SHA tags make rollbacks traceable. apk upgrade is a quick fix, but a newer pinned base image is the cleaner long-term fix because builds stay reproducible.
- Status: [x] tried
- Summary line for Webex: "Built a container image in CI with SHA tags and a Trivy vulnerability gate, fixed failing CVEs, and merged through a protected PR; mapped to Robility container inventory and VAPT remediation."

## 2026-10-08 - Dependabot and CodeQL (dependency and code scanning)
- What it does: Dependabot watches dependencies and opens PRs to update them. Version updates are controlled by .github/dependabot.yml, and security updates and alerts are turned on in repo settings. CodeQL default setup scans the repo for code problems, and for this repo it scans the workflow files themselves.
- Commands run: added .github/dependabot.yml (weekly updates for github-actions and the docker folder) and merged it through PR #20. Dependabot opened PR #21 (nginx 1.27-alpine to 1.31-alpine) and PR #22 (actions/checkout 4 to 7) within minutes. Reviewed each with `gh pr view`, `gh pr checks` and `gh pr diff`, merged both, then ran call-reusable and docker-build by hand to prove the untested workflows still passed. Enabled CodeQL default setup in the browser. Its first run completed successfully in 44 seconds.
- What went wrong and how I fixed it: tested removing `apk upgrade` after the nginx bump (PR #23). The Trivy gate failed on 2 fixable HIGH CVEs (libexpat and pcre2) even in the newer base image, so I closed the PR without merging and kept the workaround. `gh api` for code scanning alerts returned HTTP 403 because the Codespace token cannot read security data. I did not check the CodeQL alert count or the Dependabot alerts page, so those results are not recorded here.
- How it applies to Robility: Dependabot-style updates for shared actions and base images would keep ~400 pipelines current, but major version bumps like checkout 4 to 7 need a diff review and a test run first. A newer base image does not guarantee a clean scan, so keep the image scan gate.
- Status: [x] tried
- Summary line for Webex: "Set up Dependabot and CodeQL, reviewed and merged dependency update PRs, and verified with an image scan gate; mapped to Robility pipeline and container maintenance."

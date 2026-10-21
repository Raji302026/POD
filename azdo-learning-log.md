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

## 2026-10-08 - Release strategies: canary with verify, promote and rollback
- What it does: A canary release sends a small share of traffic to the new version, checks its health, and then either promotes it to everyone or rolls back. In GitHub Actions I built it with job dependencies (`needs`), a production environment approval, and a rollback job with `if: failure()`. The Azure Pipelines version is a `deployment` job with `strategy: canary`, `increments`, lifecycle hooks (preDeploy, deploy, routeTraffic, postRouteTraffic) and `on: failure` and `on: success`.
- Commands run: wrote .github/workflows/deploy-canary.yml with a simulated health input and merged it through PR #25. Ran it three times from the browser. The healthy run had canary, verify and promote succeed and rollback skipped. I rejected the approval on a second healthy run. The unhealthy run had verify fail, rollback succeed and promote skipped. Checked every result with `gh run view <id> --json jobs --jq`. Also wrote azure-pipelines-practice/azure-pipelines-canary.yml.
- What went wrong and how I fixed it: my first paste of the workflow file was cut off and the heredoc broke, so I deleted the file and pasted it in three smaller parts. My second run was healthy because the box was still ticked, so it waited for approval, and `gh run cancel` returned HTTP 403 because the Codespace token cannot change runs, so I rejected it in the browser. Inputs go through env instead of directly inside run, to avoid script injection. The Azure YAML was checked as YAML only and not run in Azure DevOps, and PyYAML shows the `on` key as True, which is a library quirk.
- How it applies to Robility: production releases on Robility could use a canary or rolling strategy with a health check and an automatic rollback, instead of an all-at-once deploy. The environment approval stays as the gate before promotion.
- Status: [x] tried (GitHub), [x] read only (Azure YAML, syntax checked offline)
- Summary line for Webex: "Built and tested a canary release with health verification, approval-gated promotion and automatic rollback in GitHub Actions, and wrote the Azure Pipelines canary strategy YAML; mapped to Robility release practices."

## 2026-10-08 - Faster pipelines: matrix builds and caching, measured
- What it does: A matrix runs the same job for several values at the same time on separate runners, so wall-clock time drops. A cache saves a slow step's output, such as installed dependencies, and restores it on the next run. The Azure Pipelines equivalents are `strategy: matrix` with `maxParallel`, and the `Cache@2` task.
- Commands run: wrote .github/workflows/speed-test.yml with three jobs (sequential, matrix, cached) using sleep to simulate work, merged through PR #27 and ran it twice from the browser. Measured each job with `gh run view <id> --json jobs --jq` using startedAt and completedAt. Sequential took 62 to 63 seconds, each matrix job took 22 to 24 seconds (about 2.7 times faster in wall-clock time for the same work), and the cached job took 34 seconds on a miss and 4 seconds on a hit.
- What went wrong and how I fixed it: the total workflow time was 1m7s in both runs because the sequential job set the overall time, so the workflow total hid the differences. I measured per-job durations instead. I also miscounted the file lines when checking the paste, but the job list check was correct. The work is simulated with sleep, so real builds will differ.
- How it applies to Robility: pipeline optimization across ~400 pipelines. Matrix builds shorten runs but use more parallel capacity, so check the agent pool size and parallel job limit first. Caching package restores saves time on every run, and the results should be measured per job, not by total time.
- Status: [x] tried
- Summary line for Webex: "Measured matrix builds and caching against a sequential baseline (about 2.7x faster wall-clock, cache saved 30s per run); mapped to Robility pipeline optimization."

## 2026-10-08 - Runner security and Actions hardening (self-hosted and ephemeral runners)
- What it does: Self-hosted runners execute workflow code on your own machine, so they are risky on public repos where fork pull requests can try to run code. Ephemeral runners take one job and are discarded, so no state or credentials carry over. Actions Runner Controller on Kubernetes creates a fresh pod per job. Repo-level settings reduce the risk: approval for outside contributors' workflows and a read-only default GITHUB_TOKEN.
- Commands run: checked repo visibility with `gh repo view --json visibility` (PUBLIC), so I did not register a runner. Set the Actions settings in the browser: approval required for external contributors' workflows, read-only default workflow permissions, and no permission for Actions to approve pull requests. Verified the token permissions a real job received by reading the "GITHUB_TOKEN Permissions" section of the job log with `gh run view <id> --log | grep`: only Contents, Metadata and Packages read.
- What went wrong and how I fixed it: the settings API returned HTTP 403 because the Codespace token cannot read admin settings, so I verified through a job log instead. I again pasted a placeholder run ID (1234) instead of the real one. The job log shows the default is read-only now, but it does not show whether it was changed today, and it cannot show the fork approval setting, so that one is checked on the settings page only.
- How it applies to Robility: this feeds the AKS ephemeral agents spike. Ephemeral agents avoid state leaking between pipelines, and the same least-privilege rules apply to agent pools and service connections in Azure DevOps. I did not run a real self-hosted runner, so this is read only for runners.
- Status: [x] read only (runners), [x] tried (settings hardening)
- Summary line for Webex: "Reviewed self-hosted and ephemeral runner security and hardened Actions settings (read-only token, outside contributor approval); mapped to the Robility AKS ephemeral agents spike."

## 2026-10-14: Infrastructure as Code with Terraform

What it does:
- Terraform describes infrastructure in files, then previews (plan) and creates (apply) it. A state file maps the code to what exists.
- Practiced with the built-in terraform_data resource, so nothing was created in any cloud.

Commands run:
- terraform init, fmt, validate, plan, plan -var="environment=prod", apply, then plan again (No changes).
- git check-ignore -v terraform.tfstate to prove state is not committed.
- Added a terraform-check PR workflow (fmt -check, init -backend=false, validate).

What went wrong:
- I typed the RUNID placeholder literally in gh run view. Fixed by using the real ID from gh run list.
- I said a plan would show the output value, but it shows (known after apply) until apply.

Proof the gate works:
- I pushed a badly formatted line on purpose. terraform-check failed (fmt exit code 3), the other checks stayed green.
- I ran terraform fmt locally, removed the test line, and the check passed again.

Robility application:
- Same pattern for Azure resources: fmt and validate on every PR, plan reviewed before approval, apply only from main after an environment approval.
- State would live in a remote backend (Azure storage account with locking), never in Git.
- Required checks must not use path filters, or PRs that skip the filter wait forever.

Honest limits:
- No real Azure resources, no remote backend, and no Bicep yet. Apply ran only on a built-in resource.

Status: done.

Webex summary: Practiced Terraform (init, validate, plan, state) and added a Terraform validation check to the PR pipeline gate.

## 2026-10-14: Infrastructure as Code with Bicep

What it does:
- Bicep is Azure's own language for infrastructure. It compiles to an ARM template (JSON) that Azure deploys. It has no state file because Azure Resource Manager tracks what is deployed.
- Wrote a storage account with param, var, resource and output, plus secure settings: HTTPS only, TLS 1.2 minimum, no public blob access.

Commands run:
- bicep --version, bicep lint, bicep build, and head on the compiled storage.json.
- Added a bicep-check PR workflow (install Bicep, lint, build).
- Changed the environment default to an invalid value (qa) and bicep build failed with BCP033, caught by the @allowed decorator before any deployment.

What went wrong:
- az was not installed in the Codespace. I used the standalone Bicep CLI instead, which is enough for lint and build.

Terraform vs Bicep:
- Terraform: multi-cloud, has a state file, preview with plan.
- Bicep: Azure only, no state file, preview with az deployment group what-if.

Robility application:
- Same PR-gate pattern for Azure resources: lint and build on every PR so invalid templates cannot merge.
- Secure defaults (TLS, no public access) can be enforced in the template, which also supports VAPT remediation.

Honest limits:
- Nothing was deployed. what-if was not run because there is no Azure subscription in this lab.

Status: done.

Webex summary: Practiced Bicep (lint, build, parameter validation) and added a Bicep validation check to the PR pipeline gate.

## 2026-10-14: Kubernetes debugging (pod failures)

What it does:
- Practiced the debug routine on a local kind cluster: kubectl get pods (status), describe (events), logs, and logs --previous for crashes.
- Reproduced three failures: ImagePullBackOff, CrashLoopBackOff, Pending.

Commands run:
- kind create cluster, kubectl apply, get, describe, logs, set image, rollout restart, delete.
- ImagePullBackOff: the event showed a DNS i/o timeout to registry-1.docker.io, not only a bad tag. A valid tag failed too, so the cause was the node network, not the manifest.
- CrashLoopBackOff: logs showed "fatal: DB_URL is not set" and describe showed Exit Code 1. Fixed by adding the env value in the manifest and re-applying.
- Pending: the event showed Insufficient cpu and memory because the pod requested 64 CPU and 256Gi.

What went wrong:
- kind load docker-image failed with "content digest not found" (multi-architecture image). Fixed by docker save --platform linux/amd64 and kind load image-archive.
- I interrupted kind create cluster with Ctrl+C by typing while it was still pulling the node image; deleting and recreating it fixed that.
- kubectl was pointing at an old cluster until the new context was set.

Debug routine to remember:
- get pods for status, describe pod for the Events section, logs for the app output, logs --previous for a crashed container.
- ImagePullBackOff: wrong tag, registry login, or network/DNS. Read the event text.
- CrashLoopBackOff: read the logs and exit code.
- Pending: read the scheduler event (Insufficient cpu or memory, taints, or an unbound volume).

Robility application:
- Same routine applies to Harmony and other containers: check status, events and logs before changing anything, then fix the cause in the manifest or pipeline and redeploy.

Honest limits:
- Local kind cluster only. No AKS, no ingress, and no production incident handled this way.

Status: done.

Webex summary: Practiced Kubernetes troubleshooting (ImagePullBackOff, CrashLoopBackOff, Pending) using describe and logs on a local cluster.

## 2026-10-14: Observability with Prometheus alert rules

What it does:
- Prometheus scrapes metrics from targets on an interval and stores them. The up metric is 1 when a target is reachable and 0 when it is not.
- Alert rules are code: an expression plus a for: duration. An alert moves from inactive to pending to firing.
- promtool (inside the Prometheus image) validates rules and config before they run.

Commands run:
- docker pull prom/prometheus, promtool check rules and check config via docker run.
- Started Prometheus in a container and queried the HTTP API with curl (up, /api/v1/rules, /api/v1/alerts).
- Added a fake target on port 9999. up went to 0 and TargetDown went pending then firing.
- Added a prometheus-check PR workflow (promtool check rules and check config).
- Broke an alert expression on purpose (up ==). promtool failed locally and in CI with a parse error naming the file, line, group and rule; the other checks stayed green. Fixed it and the check passed.

What went wrong:
- The alert did not fire right away. Rules are evaluated every evaluation_interval (default 1 minute), so pending then firing took a couple of minutes even with for: 15s.
- The alert summary text said "5 minutes" after I changed the rule to 15s. Annotations should not hard-code durations.
- curl prints no final newline, so the next prompt landed on the same line; adding echo after curl fixes it.
- The check uses prom/prometheus:latest. It should be pinned to a version or digest so a new release cannot change the check silently.

Concepts for interviews:
- Metrics, logs and traces are the three pillars; metrics for trends and alerts, logs for detail, traces for request paths.
- SLI is what you measure (for example the percentage of successful pipeline runs), SLO is the target (for example 99 percent), SLA is the promise to a customer with consequences.
- Alert on symptoms (target down, restarts, error rate), not on every CPU spike, and use a for: time to avoid noisy alerts.

Robility application:
- Alerts for container restarts (CrashLoopBackOff from the Kubernetes lab) and for agent or service targets going down, validated in the PR like any other code.

Honest limits:
- Prometheus ran locally against itself and one fake target. No Alertmanager, no Grafana, and no Azure Monitor or KQL (no subscription in this lab).

Status: done.

Webex summary: Practiced Prometheus alert rules (scrape, up metric, pending and firing alerts) and added a promtool validation check to the PR pipeline gate.

## 2026-10-15: Git for interviews (conflicts, rebase, revert, reflog)

What it does:
- Practiced on a throwaway local repo (not the real repo) so main was never at risk.
- Merge keeps the branch history and adds a merge commit; rebase replays commits on top of the latest main for a straight line, and rewrites the commit IDs.
- revert adds a new commit that undoes an earlier one and is safe on shared branches; reset --hard moves the branch back and discards changes, so it is only for local work.
- reflog records where HEAD has been, so a commit that looks lost after reset can usually be recovered.

Commands run:
- Created two branches that changed the same line, merged them, and got CONFLICT (content). Read the markers (HEAD side, =======, other side), edited the file to the final value, checked no markers remained with grep, then git add and git commit.
- git rebase main on a feature branch; the commit ID changed (5306f42 to 29307fe) and the history became a straight line.
- Committed a mistake, undid it with git revert HEAD, and saw both commits remain in history.
- Made a commit, destroyed it with git reset --hard HEAD~1, found it with git reflog, and restored it with git reset --hard HEAD@{1}.

What went wrong:
- Nothing failed this time. The conflict was created on purpose, and the first reflog attempt just needed me to read the entries before restoring.

Interview answers:
- Merge vs rebase: merge preserves history, rebase gives a linear history; never rebase commits others already have.
- Reset vs revert: revert is safe on shared branches because it adds a commit; reset rewrites history, so use it only on local work.
- If I think I lost a commit: git reflog, find the commit, then git reset --hard to that entry or create a branch at it.
- Merge conflict routine: read the markers, decide the final content (ask the authors if unsure), remove all markers, git add, git commit. git merge --abort is the safe exit.

Robility application:
- Same routine applies to pipeline YAML conflicts in the shared pipeline-templates repo; protected branches and pull requests mean mistakes are undone with revert, not force pushes.

Honest limits:
- Practiced locally in a scratch repo. No force push, no remote history rewrite, and no team conflicts.

Status: done.

Webex summary: Practiced Git for DevOps work (merge conflicts, rebase, revert, reset and reflog recovery) in a safe scratch repo.

## 2026-10-15: Reviewing Dependabot major version PRs

What it does:
- Dependabot opened two weekly PRs: hashicorp/setup-terraform 3 to 4 and actions/cache 4 to 6. Both were major version bumps, so I reviewed them instead of merging on green checks alone.

Commands run:
- gh pr list, then gh pr view, gh pr checks and gh pr diff for each PR. Read the release notes for breaking changes, checked the diff was a one-line version change, and checked which checks actually exercised the changed action.
- setup-terraform v4: the only breaking change is the Node.js 24 runtime, fine on GitHub-hosted runners. terraform-check ran the new version and passed, so merged.
- actions/cache v6: no breaking change listed for the inputs I use. The only workflow using it (speed-test) is manual, so the green PR checks did not prove it works. Merged, then ran speed-test from the browser and the cached job passed.

What went wrong:
- I once ran gh pr checks without a PR number while on main and got "no pull requests found"; the number is needed when not on the PR branch.

Robility application:
- Same review habit for Azure DevOps task versions and shared template changes: read what changed, check the runtime requirement on self-hosted agents, and verify with a real run when no check covers the change.

Honest limits:
- The v5 release notes were cut off in my output, so I could not read every intermediate release. Checks only prove what they run.

Status: done.

Webex summary: Reviewed and merged Dependabot major version updates after checking release notes, diffs and a manual verification run.

## 2026-10-15: Azure Monitor and KQL basics

What it does:
- Azure Monitor stores logs in a Log Analytics workspace, in tables such as Heartbeat and KubePodInventory. KQL reads like a pipeline: start with a table and pipe through where, summarize, project, order by and take.
- where filters rows (filter raw columns before summarize), summarize groups and aggregates, and a where after summarize filters on the computed value, like HAVING in SQL. ago(1h) means one hour back.

Commands run:
- Wrote five queries in kql-practice/queries.kql: failed pipelines per day (example table), containers restarting more than 3 times, servers with no heartbeat for 10 minutes, top 5 computers by heartbeat count, and pods with more than 5 restarts in 24 hours.

What went wrong:
- Fill-in-the-blank text pasted into the terminal went into the file literally (twice), so I removed those lines with head -n and added the finished queries.
- The project operator in my last query was redundant, because summarize already outputs only the grouped and computed columns.

Robility application:
- The same questions map to alerts: which pipelines fail most, which containers keep restarting (like the CrashLoopBackOff lab), and which servers stopped reporting.

Honest limits:
- No Azure subscription or Log Analytics workspace, so none of these queries were run. PipelineRuns is an example table, not a built-in one. Table and column names should be checked against a real workspace.

Status: done.

Webex summary: Learned Azure Monitor and KQL basics and wrote five practice queries for pipeline failures, container restarts and server heartbeats.

## 2026-10-15: Kubernetes deployments, probes and rollbacks

What it does:
- Deployment keeps the desired number of pods and replaces failed ones; Service gives the pods one stable address and sends traffic only to ready pods.
- Readiness probe decides whether a pod gets traffic; liveness probe decides whether a container is restarted. Requests are reserved by the scheduler; limits are the maximum a container may use.

Commands run:
- kubectl apply of a 2-replica nginx Deployment with probes and resource limits plus a Service; checked get pods, get svc and get endpoints.
- Rolling update with kubectl set env; rollout status and rollout history showed revisions.
- Bad update (image tag that does not exist): rollout stalled at 1 of 2 new replicas, the old pods kept serving and the endpoints still listed both IPs. kubectl rollout undo restored the working version.
- Pod with a failing readiness probe stayed Running 0/1 and was kept out of the Service endpoints. Pod with a failing liveness probe was killed and restarted repeatedly and reached CrashLoopBackOff although nginx itself was healthy.

What went wrong:
- The first paste of the Deployment manifest was cut off and the kubectl apply line ended up inside the file, so I removed the file and pasted it again in two smaller parts.
- kubectl rollout undo warned that it does not update the last-applied annotation; the manifest file and the cluster no longer matched.
- The nginx image could not be pulled by the cluster node (DNS timeout), so I loaded it with docker save --platform linux/amd64 and kind load image-archive.

Interview answers:
- Zero-downtime deployment: a rolling update with readiness probes. Old pods keep serving until new pods are ready, and a failed rollout stalls instead of causing an outage.
- Rollback: kubectl rollout undo (or revert the Git commit and redeploy, which keeps Git as the source of truth).
- Readiness vs liveness: readiness controls traffic, liveness controls restarts. A wrong liveness probe can put a healthy app into CrashLoopBackOff, so check describe events as well as logs.

Robility application:
- Same checks for containerised services: probes and resource limits in manifests, and roll back by reverting the commit and letting the pipeline redeploy.

Honest limits:
- Local kind cluster only. No AKS, no ingress, no autoscaling, and no real production rollback.

Status: done.

Webex summary: Practiced Kubernetes deployments (Service, probes, resource limits, rolling update and rollback) on a local cluster.

## 2026-10-15: Terraform modules, environments and the moved block

What it does:
- A module is a reusable folder of Terraform code with variables as inputs and outputs as results. One module (terraform-modules/app) was called twice from terraform-envs, for dev and prod, with different inputs.
- terraform plan shows what would change; the state maps module and resource addresses to real resources.

Commands run:
- terraform init, fmt, validate, plan, apply for a root that calls the module twice; terraform state list and terraform output.
- Renamed module "prod" to "production". The plan wanted to destroy module.prod and create module.production (1 to add, 1 to destroy), because the state knew the resource only by its old name.
- Added a moved block (from module.prod to module.production). The plan became 0 to add, 0 to change, 0 to destroy, the resource ID stayed the same, and terraform apply recorded the move in the state.
- Extended the terraform-check workflow: fmt -check -recursive for all folders, then init -backend=false and validate for each root folder.

What went wrong:
- After renaming the module, terraform plan failed with "Module not installed". A new module name needs terraform init again.
- The first plan after the rename looked harmless in the code but would have destroyed and recreated the resource, which is why the plan must be read in review.

Interview answers:
- Several environments: one module called per environment with different inputs (or separate state per environment), so the same code is reused and only variables differ.
- Renaming safely: use a moved block or terraform state mv; otherwise Terraform destroys the old address and creates the new one.
- State for a team: a remote backend (for example an Azure storage account with locking), never in Git. Also read the plan in the pull request and apply only from main after approval.

Robility application:
- Same shape as shared pipeline templates: one reviewed module, many environments, and checks that block bad changes before merge.

Honest limits:
- Used the built-in terraform_data resource only. No real Azure resources, no remote backend, and no import or workspace practice.

Status: done.

Webex summary: Practiced Terraform modules for dev and prod, the moved block for safe renames, and extended the PR check to validate all Terraform folders.

## Module 13: Secure pipeline template with extends (Oct 15)

**What it does:** An `extends` template locks the pipeline structure (pool, stages, mandatory steps). Teams pass only a `stepList` parameter, so they cannot remove the secret scan or the compliance step.

**Commands run:**
- Read `azure-pipelines-extends.yml` (consumer) and `templates/secure-pipeline.yml` (enforcer).
- Replaced the echo placeholder with a real gitleaks scan via docker.
- Added `condition: always()` to the compliance step so it runs even when a team step fails.
- Checked the YAML parses with Python (4 steps found).

**What went wrong:** I wrote `gh pr checks NN --watch` with a placeholder instead of the PR number 41. Fixed by using the real number.

**Robility application:** Shared templates in pipeline-templates can be made mandatory with an extends template, so security steps cannot be skipped by individual teams.

**Honest limits:**
- Not run in Azure DevOps (no access from the work network). Only YAML parsing was checked.
- None of the GitHub checks cover this folder, so green checks prove nothing about it.
- Enforcing that teams must use the template needs the "Extends template required check" on the environment or service connection, which is a portal setting, not YAML.
- The gitleaks image uses `latest`, which should be pinned in real use.

**Status:** Template updated, PR #41.

**Webex summary:** Extended the Azure Pipelines secure template: real secret scan, compliance step always runs. Reviewed how extends and required checks enforce it.

## Module 14: Terraform state commands (Oct 15)

**What it does:** State is how Terraform maps code to real objects. The state commands fix that mapping without touching the real objects.

**Commands run (in a scratch folder outside the repo):**
- `terraform state list` and `terraform state show` to inspect what is tracked.
- Renamed a resource in code only. The plan showed 1 to destroy and 1 to add.
- `terraform state mv` moved the state entry to the new name. The plan then showed no changes and the id stayed the same.
- `terraform state rm` made Terraform forget a resource without deleting it. The plan then wanted to create it again, because the code still declared it.
- `terraform import` adopted the object back into state.

**What went wrong:** I expected `No changes` after the import. The plan showed an in-place update, because `terraform_data` keeps `input` only in state, so the import could not bring it in. Lesson: after an import, read the first plan carefully and reconcile code and real settings before applying.

**Robility application:** If a Terraform resource is renamed or moved into a module, a plan that shows destroy plus create must be stopped in review. Fix it with a `moved` block in the PR, or `state mv` when the code cannot change.

**Interview answers:**
- Rename shows destroy and create: do not apply. Add a `moved` block, or run `state mv`, then confirm the plan says no changes.
- `state rm` does not delete real resources. The code must also be changed, or the resource is created again as a duplicate.
- `import` adopts an existing object, but the first plan can still show differences. Read them before applying.

**Honest limits:**
- Done on the built-in `terraform_data` resource with local state, not on real Azure resources.
- No remote backend, locking or workspaces were used.
- Back up real state before any `state mv` or `state rm`.

**Status:** Lab done in a scratch folder and cleaned up, PR pending.

**Webex summary:** Practised Terraform state commands: state list/show, state mv for renames, state rm and import. Learned to stop destroy-and-create plans in review.

## Module 15: Helm chart with per-environment values (Oct 15)

**What it does:** A Helm chart packages Kubernetes manifests as templates with placeholders. One chart serves every environment, and a values file per environment changes only what differs.

**Commands run:**
- `helm create webapp` generated a starter chart.
- `helm lint` checked the chart for errors.
- `helm template demo webapp` rendered the final YAML locally, with no cluster. The release name filled the `{{ }}` placeholders.
- Created `values-dev.yaml` (1 replica) and `values-prod.yaml` (3 replicas), then rendered both and compared them with `diff`. Only the replica count differed.
- Added `helm-check.yml` so every PR lints and renders the chart for each environment.
- Pushed a deliberately broken values file. `helm-check` failed (the other 7 checks stayed green). Fixed with `git revert`, not a reset, because the bad commit was already pushed.

**What went wrong:** I expected `[ERROR]` output from lint, but Helm failed earlier while parsing the YAML. The image tag was empty by default and silently fell back to the chart `appVersion`, so I set the tag explicitly in each values file.

**Robility application:** The same pattern fits many services with the same shape: one chart, with a values file per environment (Development, Testing, SIT, Production). A CI check that lints and renders each values file catches broken charts before deployment.

**Interview answers:**
- Helm vs raw manifests: templates remove copy-paste between environments, and a values file shows exactly what differs.
- How to review a chart change: render with `helm template` for each environment and diff the output.
- Chart versioning: bump `version` when the chart changes, and `appVersion` for the app.

**Honest limits:**
- Nothing was installed on a cluster. Only lint and template were used, so no `helm install`, `upgrade` or `rollback` was practised.
- No chart repository, OCI registry or dependency charts were used.
- `helm-check` is not a required check in the ruleset yet.
- Starter-chart files such as the ingress, hpa and httproute templates were left unmodified.

**Status:** Chart and CI check added, PR #43.

**Webex summary:** Built a Helm chart with dev and prod values, rendered and compared them locally, and added a CI check that fails on a broken chart.

## Module 16: Helm release lifecycle on kind (Oct 15)

**What it does:** Helm tracks every install and upgrade as a numbered revision, so a bad release can be rolled back without redeploying by hand.

**Commands run:**
- Created a kind cluster and loaded `nginx:1.27-alpine` with `docker save` and `kind load image-archive`, because the node cannot reach Docker Hub.
- `helm install web helm-practice/webapp -f values-dev.yaml` gave revision 1 with 1 pod.
- `helm upgrade` with `values-prod.yaml` gave revision 2 and scaled to 3 pods.
- Upgraded with a tag that does not exist and `--wait --timeout 40s`. It failed (revision 3), the 3 old pods kept serving, and revision 2 stayed deployed.
- `helm rollback web 2` created revision 4 (`Rollback to 2`). Failed revisions stay in history.
- Repeated the bad upgrade with `--atomic`. Helm rolled back by itself to the last good revision (4) with no one watching.

**What went wrong:** I expected `ErrImagePull` on the broken pod, but it was still in `ContainerCreating` when I looked. `helm uninstall` at the end failed with "cluster unreachable" because kubectl had no current context. I did not find out why. Deleting the cluster removed the release anyway.

**Robility application:** For a service deployed to Development and Testing, `helm upgrade --atomic --timeout` in a pipeline stage gives a safe default: a release that never becomes ready is rolled back automatically, and the history records why.

**Interview answers:**
- Upgrade fails halfway: with `--wait` or `--atomic`, Helm marks the revision `failed`. The old pods keep serving until the new ones are ready.
- Rollback: `helm rollback RELEASE REVISION` creates a new revision, so history is never rewritten.
- `--wait` only reports failure. `--atomic` also rolls back for you, which suits pipelines.
- Always set `--timeout`, or a stuck release hangs the pipeline for a long time.

**Honest limits:**
- Local kind cluster only, one release, one namespace, an nginx image from the local machine.
- No Helm repository, OCI registry, chart dependencies or Helm hooks.
- No AKS, no Azure DevOps deployment task and no Helm secrets or values from Key Vault.
- A rollback restores the Kubernetes objects but never data, so databases need their own backup plan.

**Status:** Lab done and cluster deleted, PR pending.

**Webex summary:** Practised the Helm release lifecycle on kind: install, upgrade, failed upgrade, manual rollback and automatic rollback with --atomic.

## Module 17: Pinning tool versions (Oct 15)

**What it does:** An unpinned `latest` tag means a CI check can start failing one day with no change in our code. Pinning makes every run use the same tool version, and upgrades become a reviewed change.

**Commands run:**
- `grep -rn "latest"` over the workflows found 4 unpinned uses in 3 files: `prom/prometheus:latest` (twice), the Bicep download from `releases/latest`, and `gitleaks:latest`.
- Read the real versions from the tools instead of guessing: promtool 3.15.0, Bicep 0.48.1, gitleaks v8.30.1.
- Verified each pinned version exists before editing: `docker pull`, `docker run ... version`, and `curl -I` on the Bicep URL (302 then 200).
- Changed the files with `sed`, then PR #45 ran `prometheus-check` and `bicep-check` on the pinned versions. All 8 checks passed.

**What went wrong:** I expected about 2 lines from the first `grep` and there were 4 (the Bicep download was a third file). My first Bicep check used `head -n 1`, which showed only the `302` redirect, so I re-ran it with `grep "^HTTP"` to see the final `200`.

**Robility application:** Shared pipeline templates and build agents should pin the versions of scanners and tools they call. Then one template update cannot silently change what ~400 pipelines run, and a scanner upgrade becomes one reviewed PR.

**Interview answers:**
- Why pin: reproducible builds. A `latest` tag can change under you and break or weaken a check without any change in your repo.
- Cost of pinning: someone must upgrade on purpose. Dependabot can open PRs for Docker and Actions versions to automate that.
- Stronger than a tag: pin by digest (`image@sha256:...`), because tags can be moved.

**Honest limits:**
- The gitleaks pin in `azure-pipelines-practice/` is not run by any GitHub check. I only checked that the tag exists and prints the right version.
- I pinned by tag, not by digest.
- Runner labels like `ubuntu-latest` and the `actions/*` versions were not changed here.
- Open gap: `terraform-check`, `bicep-check`, `prometheus-check` and `helm-check` are still not required checks in the ruleset. Adding them needs the browser (Settings, Rules, protect-main), which I have not done yet.

**Status:** Three files pinned, PR #45.

**Webex summary:** Pinned the Prometheus, Bicep and gitleaks versions used in CI after verifying each version exists, and logged the remaining ruleset gap.

## Module 18: Docker image hardening (Oct 16)

**What it does:** Reduces what an attacker can do if the container is compromised: run as a normal user, add a health check, and drop privileges at run time.

**Commands run:**
- Built the old image as the baseline: 103 MB, `id` showed `uid=0(root)`.
- Switched the base to `nginxinc/nginx-unprivileged:1.31-alpine` after checking the tag exists (it runs as `uid=101`, port 8080). Used `USER root` only for `apk upgrade`, then `USER nginx`.
- Added `COPY --chown`, a `HEALTHCHECK`, and a `.dockerignore`.
- New image: 91.5 MB, runs as `uid=101(nginx)`, returned HTTP 200 and showed `(healthy)`.
- Ran it with `--read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges`. It still served HTTP 200.
- Trivy image scan (0.57.1): both images showed 0 HIGH or CRITICAL findings.
- Trivy config scan of the Dockerfile: the old one failed 2 checks (HIGH: no non-root USER, LOW: no HEALTHCHECK), the new one passed. Exit codes were 1 for old and 0 for new.
- Added `dockerfile-check.yml` so a Dockerfile that runs as root fails the PR. PR #46 showed 10 successful checks.

**What went wrong:** I guessed the old image was about 50 MB, and `docker images` showed 103 MB. I pressed Ctrl+C during the first baseline image scan, so I had to run it again. I used `--no-progress` with `trivy config`, which does not accept it, so I switched to `--quiet`.

**Robility application:** Container images for the Robility services should run as a non-root user, and a Dockerfile scan in the PR gate stops a root-running image before it reaches a registry. The runtime flags (read-only filesystem, dropped capabilities) are for the container spec or Helm values.

**Interview answers:**
- A clean vulnerability scan does not mean a secure image. Both my images had 0 CVEs, but only one ran as non-root. Image scans and Dockerfile or config scans find different problems.
- Why non-root: if the app is compromised or the container escapes, the attacker does not start as root.
- Ports below 1024 need root, so an unprivileged image listens on 8080 and the service maps the port.
- Multi-stage builds only help when there is a build step. A static page has none, so I did not force one.

**Honest limits:**
- Local Docker only. No registry push, image signing, SBOM or base-image digest pinning.
- The base image is pinned by tag, not by digest.
- `dockerfile-check` is not a required check yet (the ruleset still needs the browser change), and I never made it fail in CI. I only showed the old Dockerfile fails with exit code 1 locally.
- In Kubernetes the same limits would be set with `securityContext` (runAsNonRoot, readOnlyRootFilesystem, drop capabilities). I did not test that here.
- The lab used a small static nginx page, not a real Robility service.

**Status:** Dockerfile hardened and Dockerfile scan added, PR #46.

**Webex summary:** Hardened the Docker image (non-root, health check, locked-down runtime flags) and added a CI scan that fails a Dockerfile running as root.

**Robility application:** Container images for the Robility services should run as a non-root user, and a Dockerfile scan in the PR gate stops a root-running image before it reaches a registry. The runtime flags (read-only filesystem, dropped capabilities) are for the container spec or Helm values.

**Interview answers:**
- A clean vulnerability scan does not mean a secure image. Both my images had 0 CVEs, but only one ran as non-root. Image scans and Dockerfile or config scans find different problems.
- Why non-root: if the app is compromised or the container escapes, the attacker does not start as root.
- Ports below 1024 need root, so an unprivileged image listens on 8080 and the service maps the port.
- Multi-stage builds only help when there is a build step. A static page has none, so I did not force one.

**Honest limits:**
- Local Docker only. No registry push, image signing, SBOM or base-image digest pinning.
- The base image is pinned by tag, not by digest.
- `dockerfile-check` is not a required check yet (the ruleset still needs the browser change), and I never made it fail in CI. I only showed the old Dockerfile fails with exit code 1 locally.
- In Kubernetes the same limits would be set with `securityContext` (runAsNonRoot, readOnlyRootFilesystem, drop capabilities). I did not test that here.
- The lab used a small static nginx page, not a real Robility service.

**Status:** Dockerfile hardened and Dockerfile scan added, PR #46.

**Webex summary:** Hardened the Docker image (non-root, health check, locked-down runtime flags) and added a CI scan that fails a Dockerfile running as root.

## Module 19: Alertmanager routing and the Grafana stack (Oct 16)

**What it does:** Prometheus decides when an alert fires. Alertmanager decides who hears about it: grouping, routing by severity, and inhibition so one failure does not page you ten times. Grafana shows the same data as dashboards.

**Commands run:**
- Read the real tool versions from the images before pinning: Alertmanager 0.34.1, Grafana 13.2.4 (Prometheus v3.15.0 from Module 17), and checked each pinned tag exists with `docker pull`.
- Wrote `alertmanager.yml` (group_by alertname and job, critical alerts to a separate receiver, one inhibit rule), `docker-compose.yml` bound to 127.0.0.1, and a Grafana data source file. The webhook URL is a placeholder on `example.invalid`.
- Validated offline with `promtool check config`, `amtool check-config` and `docker compose config`. All passed.
- Started the stack. Prometheus, Alertmanager and Grafana all answered their health endpoints.
- `amtool config routes test` showed critical goes to `critical-oncall` and warning goes to `default`.
- Posted a critical and a warning alert for the same service to the Alertmanager API. The warning showed `suppressed` and the critical was `active`, which proves the inhibit rule works.
- Added an Alertmanager config check and a compose validation step to `prometheus-check.yml`, and proved the check fails on a config that routes to an undefined receiver (exit code 1).

**What went wrong:**
- Prometheus showed the `alertmanager` scrape target as down with `context deadline exceeded`. Inside the Prometheus container the name `alertmanager` did not resolve, and a request to the container IP also timed out. In this Codespace, containers cannot reach each other. I did not find a fix, so the full stack was not tested end to end.
- I thought `prometheus.yml` was cut off by the paste, but the file was fine and only the terminal display was garbled.
- My first failure test for `amtool` gave `permission denied` on the file instead of a config error, so it proved nothing. I fixed the permissions and the second run failed with the correct message.

**Robility application:** For Robility services, alerts should be routed by severity and grouped by service, with a critical alert suppressing the warnings for the same failure. That cuts pages during an incident, and the config is checked in the PR before it goes live.

**Interview answers:**
- Prometheus vs Alertmanager: Prometheus evaluates rules and fires alerts. Alertmanager groups, routes, silences and inhibits them, and sends the notifications.
- Alert fatigue: group related alerts, route only critical alerts to the on-call receiver, inhibit warnings when a critical alert is firing, and use `for:` so short blips do not page anyone.
- Debugging a target that is down: read the target's `lastError` in Prometheus, check whether the name resolves from inside the container, then test by IP to separate DNS from network.
- Metrics, logs and traces: metrics show that something is wrong and how much, logs show what happened, and traces show where time went across services.

**Honest limits:**
- The full stack was never confirmed working end to end: containers could not reach each other in the Codespace, so Prometheus did not scrape Alertmanager and Grafana never reached Prometheus. No dashboard was built or checked.
- No real notification receiver (Teams, Webex or email) was used. The webhook is a placeholder and a real one is a secret.
- Grafana runs with default login on localhost only. A real setup needs proper credentials and persistent storage.
- No Loki, tracing or Azure Monitor integration.
- The routing and inhibition tests used manually posted alerts, not alerts generated by Prometheus rules.
- `prometheus-check` is still not a required check in the ruleset.

**Status:** Alerting config added and checked in CI, PR pending.

**Webex summary:** Set up Alertmanager routing and inhibition, validated the monitoring configs offline and added an Alertmanager check to CI. The full stack could not run end to end because container networking is blocked in the Codespace.

## Module 20: DORA metrics from my own repo (Oct 16)

**What it does:** DORA metrics measure delivery performance: deployment frequency, lead time for changes, change failure rate and time to restore. I calculated the first two from the real PR history of this repo.

**Commands run:**
- `gh pr list --state merged --json number,createdAt,mergedAt,author` to get the data (45 merged PRs).
- Wrote `dora-practice/dora.py` (pure Python, reads a JSON file) with unit tests built from sample data with known answers (median 20, max 60, two active days). All 3 tests passed before I used it on real data.
- Results for all 45 PRs: 9 day span, 5 active days, about 5 merges per day, median lead time 2.1 min, 90th percentile 47.4 min, maximum 320.8 min.
- Found the slowest PRs were Dependabot bumps (#34 and #35, about 5 hours) that I left open on purpose to review major-version changes.
- Split the data into human and bot PRs. Human: 41 PRs, p90 16.3 min, max 54.3 min. Bot: 4 PRs, median 162.3 min.
- Added `dora-check.yml` so the unit tests run on every PR.

**What went wrong:** My first `py_compile` created a `__pycache__` folder in the repo folder, so I added a `.gitignore` before committing. I also nearly quoted a 90th percentile from only 4 bot PRs, which is just the maximum.

**Robility application:** The same approach could report how long Robility pipeline PRs wait for review and how often changes ship, pulled from Azure DevOps instead of GitHub. That turns "we feel slow" into numbers a manager can act on.

**Interview answers:**
- The four DORA metrics: deployment frequency, lead time for changes, change failure rate, and time to restore service. The first two measure speed, and the last two measure stability.
- My lead time is understated: I measured from PR opened to merged, but the real metric starts at the first commit.
- Bots and one-off outliers can distort a metric, so I split Dependabot PRs from human PRs before drawing conclusions.
- Percentiles need enough data: a 90th percentile from 4 samples is meaningless.
- Measuring one person's learning repo is not the same as measuring a team. Metrics should guide improvement, not rank people.

**Honest limits:**
- Merges to `main` stand in for deployments. Nothing here is actually deployed, so deployment frequency is only a proxy.
- Change failure rate and time to restore were not measured, because there are no production incidents or failed deployments in this repo.
- Lead time starts when the PR is opened, not at the first commit.
- One person's learning repo, 9 days of data, 45 PRs. Not a team or a production system.
- The script was tested on sample data only, not on edge cases like PRs merged on the same second or time zone changes.

**Status:** Script, tests and CI check added, PR pending.

**Webex summary:** Calculated deployment frequency and lead time from my own PR history with a tested Python script, and learned how bots, outliers and small samples distort delivery metrics.

## Module 21: Policy as code with Conftest (Oct 16)

**What it does:** Conftest checks configuration files (Kubernetes manifests, rendered Helm output) against rules written in Rego. A rule that fails turns the PR check red, so unsafe config is blocked before it is deployed.

**Commands run:**
- Read the real version from the image before pinning: Conftest v0.71.1 (OPA 1.21.1), and checked the pinned tag exists. OPA 1.x needs the newer Rego syntax (`deny contains msg if { ... }`).
- Wrote `policy/k8s.rego` with three `deny` rules (no resources.limits, image without a tag, image with the latest tag) and one `warn` rule (no runAsNonRoot). A `deny` fails the check, and a `warn` only reports.
- Ran it on `k8s-deploy/` and `k8s-practice/no-resources-pod.yaml`. The deliberately broken demo pods failed as expected, and `web.yaml` passed with one warning.
- Rendered my Helm chart with `helm template` and piped it into Conftest. The policy found 3 real failures in my own chart: no limits on the Deployment, no limits on the Helm test pod, and the test pod image `busybox` had no tag.
- Fixed them: added `resources` to `values-dev.yaml` and `values-prod.yaml`, pinned `busybox:1.37.0` (checked the tag exists and prints BusyBox v1.37.0), and added limits to the test pod. Both environments then passed with exit code 0.
- Added `policy-check.yml` so every PR renders the chart for dev and prod and runs the policy.

**What went wrong:** My first policy run exited with 1 because the demo manifests are deliberately broken, so I limited CI to files that should be clean. My first attempt to read the busybox version only showed the pull message, so I confirmed it with a second command. The policy file I pasted was not written the first time because only the pull command ran.

**Robility application:** The same rules can be run against the Kubernetes or Helm output for any Robility service before deployment, so a missing resource limit or a latest tag is caught in the PR. The rules live in one folder, so one change updates the standard everywhere.

**Interview answers:**
- What policy as code is: rules written as code, versioned and reviewed like any other code, and enforced automatically in the pipeline instead of by a person remembering a checklist.
- `deny` vs `warn`: deny fails the check, warn only reports. Start new rules as warnings so you can improve gradually, then promote them to deny.
- Why check the rendered output, not just the templates: the templates contain placeholders, and what actually gets deployed is the rendered YAML.
- Conftest checks files before deployment. Admission controllers such as OPA Gatekeeper or Azure Policy for Kubernetes enforce the same kind of rules inside the cluster at deploy time. A good setup uses both.

**Honest limits:**
- Only a handful of simple rules for two workload kinds (Pod and Deployment). StatefulSet, DaemonSet, Job and init containers are not covered.
- The "no tag" rule is naive: an image from a registry with a port (host:5000/image) would count as tagged.
- `runAsNonRoot` is only a warning, so the chart still runs as root by default.
- Rules were tested only on my own manifests, with no automated tests for the rules themselves (Conftest has a `verify` command for that).
- Nothing was deployed. I did not test admission control inside a cluster.
- `policy-check` is not a required check in the ruleset yet.

**Status:** Policy added, chart fixed and CI check added, PR pending.

**Webex summary:** Wrote policy-as-code rules with Conftest, found and fixed three real issues in my Helm chart (missing resource limits and an untagged image), and added a CI check that blocks them.

## Module 22: Blameless postmortem (Oct 16)

**What it does:** A postmortem records what happened in an incident, why, and what will change, without blaming a person. The aim is to fix the system and the process so the same problem does not repeat.

**Commands run:**
- Wrote `postmortems/2026-10-16-container-network.md` about a real problem from this morning: Prometheus could not scrape Alertmanager because containers on one Docker network could not reach each other in the Codespace.
- Sections: summary, impact, timeline with exact times, root cause, what went well, what went poorly, action items.
- Separated what is known (container to container traffic times out, by name and by IP) from what is not known (why, and whether it is the same cause as the earlier kind DNS problem).
- Action items are concrete: a 30 second network smoke test before building any multi-container stack, keep the config checks in CI, and finish the end-to-end test on a machine with normal container networking.

**What went wrong:** I pasted the second half of the document twice, so the file had 11 headings instead of 7. I found it with `grep -c`, looked at the line numbers with `grep -n`, and cut the file to the first 54 lines.

**Robility application:** The same format fits a real incident on the Robility platform, such as a failed deployment or a pipeline outage. A shared template makes the write-ups consistent, and the action items become tracked work instead of good intentions.

**Interview answers:**
- What blameless means: the write-up asks what in the system, the process or the tooling allowed the mistake, instead of who made it. People then report problems early instead of hiding them.
- A postmortem is useful when the action items are specific, have an owner and are actually done. "Be more careful" is not an action item.
- Say what you do not know. "Root cause partly known" is more honest and more useful than a confident guess.
- Typical structure: summary, impact, timeline, root cause, what went well, what went poorly, action items.

**Honest limits:**
- This was a low severity problem in a personal lab with no users, so there was no on-call response, no customer impact and no incident commander.
- The root cause is only partly known: the Codespace network may block container traffic, but I did not verify that.
- The action items have no owner or due date beyond me, and none has been done yet.
- I have not written a postmortem for a real production incident at work, and none of this has been reviewed by anyone else.

**Status:** Postmortem written, PR pending.

**Webex summary:** Wrote a blameless postmortem for the container networking problem found while testing the monitoring stack, separating what is known from what is not and listing concrete action items.

## Module 23: Required status checks (governance)

Date: 2026-10-16

What I did:
- Edited the protect-main ruleset in the GitHub browser UI to require nine status checks before merging: build-check, secret-scan, terraform-check, bicep-check, prometheus-check, helm-check, dockerfile-check, dora-check, policy-check.
- Verified the saved rule from the terminal with a read-only call: gh api repos/Raji302026/POD/rulesets/24634824.
- Proved the rule works with a throwaway PR (#51). I added an invalid line to helm-practice/webapp/values-dev.yaml.

What happened:
- helm-check failed. The other 11 checks passed.
- gh pr merge 51 --squash was refused: "the base branch policy prohibits the merge."
- I did not use --auto (it merges as soon as the check passes) or --admin (it bypasses the rule).
- I closed PR #51, deleted the branch, and confirmed main has no broken line (grep count 0).

What I learned:
- A check only protects main once it is marked required in the ruleset. A check that runs but is not required can be ignored.
- Always test a gate with a deliberately bad change. Seeing green checks proves nothing about blocking.
- Required checks are matched by job name, so a renamed job can silently stop being required.
- This is the same idea as Azure DevOps branch policies with build validation, plus the "Extends template required check" for pipeline templates.

Limits (honest):
- docker-build and CodeQL are not required. docker-build is path-filtered, so it does not run on every PR and would block unrelated PRs.
- The "require branch to be up to date" setting is off, so a PR can merge without being re-tested against the latest main.
- The checks only cover what they run. A passing check does not mean the change is safe.
- This is a one-person repo with an empty bypass list. In a team, I would decide carefully who can bypass.
- This is a GitHub lab. I could not practice Azure DevOps branch policies directly because Azure DevOps is blocked on the work network.

## Module 24: SBOM and supply chain scanning

Date: 2026-10-16

What I did:
- Rebuilt webapp:hardened in a fresh Codespace. The first build failed with "content digest not found" (a half-downloaded base layer). Running docker pull on the base image fixed it.
- Trivy was not installed, so I ran it as a container pinned to 0.57.1, the same version CI uses.
- Generated a CycloneDX SBOM: trivy image --format cyclonedx --output sbom.cdx.json webapp:hardened.
- The SBOM lists 71 packages on Alpine 3.24.2.
- Scanned the SBOM file itself: trivy sbom --severity HIGH,CRITICAL. Result: 0 HIGH, 0 CRITICAL.

What I learned:
- An SBOM is an inventory of every package in an image. It can be stored and rescanned later without rebuilding.
- CycloneDX output has no vulnerability data. The scan is a separate step against the SBOM.
- Same reason as before for pinning the Trivy version: results should be repeatable.

Limits (honest):
- A clean result means no known HIGH/CRITICAL issues today. It must be rescanned as new vulnerabilities are published.
- The SBOM was not signed or attested, so nothing proves it matches the image.
- It covers OS packages only. No language-specific files were found (num=0).
- The SBOM file is generated output, so it is not committed.

## Module 25: Kubernetes RBAC (Role and RoleBinding)

Date: 2026-10-21

What I did:
- Created a kind cluster, a namespace (rbac-demo) and a service account (viewer).
- Checked its permissions before any Role: kubectl auth can-i list pods returned no. A new service account has no permissions.
- Created a Role (pod-reader: get, list, watch on pods) and a RoleBinding (viewer-binding) in rbac-demo.
- Tested with kubectl auth can-i --as=system:serviceaccount:rbac-demo:viewer. List pods in rbac-demo: yes. Delete pods in rbac-demo: no. List pods in default: no.

What I learned:
- RBAC is deny by default. A Role lists allowed verbs on resources, and a RoleBinding gives it to a subject.
- A Role only works inside its own namespace. A ClusterRole is needed for cluster-wide access.
- kubectl auth can-i --as=... tests permissions without logging in as that account.
- Least privilege: grant only the verbs needed (read, not delete).

Problem hit and limits (honest):
- The kind cluster from 4 days earlier did not survive the Codespace restart. Docker reported the container storage layer as missing, so the container could not start. I deleted and recreated the cluster. Labs should be scripted so they can be rebuilt quickly.
- I tested permissions with can-i only. I did not run a real pod using the service account token.
- ClusterRole and group bindings were not practiced.

## Module 26: Blue/green release with a Service selector

Date: 2026-10-21

What I did:
- Built plain Kubernetes files in bluegreen-practice/: two Deployments (web-blue, web-green) and one Service (web). Pods carry a slot label (blue or green).
- The Helm chart selects pods only by name and instance, so it cannot switch between two versions. I left the chart unchanged.
- Loaded the nginx image into kind with docker save --platform linux/amd64 and kind load image-archive, because kind load docker-image failed with "content digest not found" again.
- Service pointed at blue: endpoint 10.244.0.5. Patched the selector to green: endpoint 10.244.0.6. No pods restarted.
- Switched back to blue to roll back (endpoint back to 10.244.0.5).
- Ran the files through my Conftest policies: 4 tests passed.

What I learned:
- Blue/green runs two full versions at once and switches traffic by changing the Service selector. Rollback is one command and takes about a second.
- Cost: you pay for double the pods while both run. Canary sends only part of the traffic to the new version.
- The nginx tag 1.31-alpine now has a different digest than on Oct 16 (b5047b9b vs 378d0c32), so a tag can move. Pinning by digest would make builds repeatable.

Limits (honest):
- I switched the Service but did not send real requests to compare the two versions.
- Both versions ran the same image, so the lab shows the mechanism, not a real release.
- There was no readiness gate or automated check before the switch.
- Database changes (the hard part of blue/green) were not covered.

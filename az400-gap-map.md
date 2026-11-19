# AZ-400 gap map

Date: 2026-10-16 (updated 2026-11-19)

Marks are based on files in this repo. "Practiced" means a lab or workflow exists. Azure DevOps itself is blocked at work, so most labs use GitHub equivalents.

## Practiced
- Branch policies and protection (ruleset, required checks, proof of blocking)
- Secret scanning (gitleaks in CI, secret-scan check)
- Templates and reuse (extends template, reusable workflows)
- Environments, approvals and deployment strategies (deploy-canary workflow, azure-pipelines-canary.yml)
- Identity (OIDC claims workflow)
- Variables and secrets (vars-and-secrets workflow)
- Infrastructure as code (Terraform modules, state, import; Bicep checks)
- Containers and Kubernetes (Helm, probes, affinity, PDB, quotas, network policy, PV/PVC, debugging)
- Observability (Prometheus, Alertmanager, Grafana, KQL queries)
- Metrics and incident process (DORA script, blameless postmortem)
- Policy as code (Conftest/OPA)
- Image hardening and scanning (Trivy)
- SBOM generation and scanning (CycloneDX via Trivy, trivy sbom)
- Kubernetes RBAC (Role, RoleBinding, kubectl auth can-i --as)
- Blue/green releases (Service selector switching between slot-labelled Deployments in kind, not Helm)
- Advanced Git (rebase, cherry-pick, reflog recovery, conflict resolution, in a practice repo)
- ConfigMaps and Secrets (env vars vs mounted files, a Secret is only base64, missing-Secret failure)
- Linux troubleshooting (disk usage, deleted files held open, runaway processes, kill vs kill -9; no systemd or journalctl practice)
- Kustomize (base, overlays, patches; dev applied in kind, prod only printed)

## Partly practiced
- Azure Artifacts (cheatsheet notes only, no hands-on)
- Azure Pipelines YAML (files exist, but never run in Azure DevOps)
- Azure Key Vault with pipelines (pipeline YAML and a CI rule blocking hardcoded secrets, never run against a real Key Vault)

## Not practiced yet
- Pipeline performance and cost tuning at scale
- GitOps (blocked by Codespace networking)
- StatefulSets, DaemonSets and Jobs

## Next labs, in order
1. Pipeline performance and cost tuning (reading and notes)
2. StatefulSets, DaemonSets and Jobs (lesson, then a lab in kind)
3. Azure basics: identity, networking, Key Vault (needs a subscription or a Learn sandbox)
4. Networking basics: DNS, TLS, load balancers (reading)

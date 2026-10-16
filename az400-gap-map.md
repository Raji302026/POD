# AZ-400 gap map

Date: 2026-10-16

Marks are based on files in this repo. "Practiced" means a lab or workflow exists. Azure DevOps itself is blocked at work, so most labs use GitHub equivalents.

## Practiced
- Branch policies and protection (ruleset, required checks, proof of blocking)
- Secret scanning (gitleaks in CI, secret-scan check)
- Templates and reuse (extends template, reusable workflows)
- Environments, approvals and deployment strategies (deploy-canary workflow, azure-pipelines-canary.yml)
- Identity (OIDC claims workflow)
- Variables and secrets (vars-and-secrets workflow)
- Infrastructure as code (Terraform modules, state, import; Bicep checks)
- Containers and Kubernetes (Helm, probes, affinity, PDB, quotas, network policy, PV/PVC, StatefulSet, debugging)
- Observability (Prometheus, Alertmanager, Grafana, KQL queries)
- Metrics and incident process (DORA script, blameless postmortem)
- Policy as code (Conftest/OPA)
- Image hardening and scanning (Trivy)

## Partly practiced
- Azure Artifacts (cheatsheet notes only, no hands-on)
- Azure Pipelines YAML (files exist, but never run in Azure DevOps)

## Not practiced yet
- SBOM and dependency/supply chain scanning
- Kubernetes RBAC (roles and bindings)
- Azure Key Vault integration with pipelines
- Blue/green releases (canary exists)
- Pipeline performance and cost tuning at scale
- GitOps (blocked by Codespace networking)

## Next labs, in order
1. SBOM with Trivy
2. Kubernetes RBAC in kind
3. Blue/green with Helm

# AZ-400 gap map

Date: 2026-10-16 (updated 2026-11-26)

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
- StatefulSets, DaemonSets and Jobs (stable pod names and volumes, Job retries, one DaemonSet pod on a single node)
- Networking basics (DNS, TCP refused vs timeout, TLS certificates; load balancers and 502/504 only read)
- Pipeline caching (GitHub Actions pip cache, cache hit proven in the logs, about 12 s down to 8 s on a small package set; Azure DevOps Cache task not tried)
- Docker multi-stage builds (413MB single-stage vs 15.6MB multi-stage, Trivy findings down to zero with a newer Go toolchain and apk upgrade; base images not pinned by digest in the lab)
- Ingress with Traefik in kind (path routing to two apps, 404 vs 503 behaviour; the NGINX ingress controller is retired so Traefik was used; host routing and TLS not tried)
- CronJobs and StatefulSet updates (CronJob history limit, Allow vs Forbid, suspend; StatefulSet partition canary, a bad image and a stuck pod that needed a manual delete; Replace policy, timeZone and OnDelete not tried)
- Resource requests and limits (OOMKilled with exit code 137, Pending from Insufficient cpu, node allocated resources, QoS Burstable; CPU throttling, Guaranteed and BestEffort classes and eviction not tried)
- Gateway API with Traefik (GatewayClass, Gateway and HTTPRoute; a refused route fixed through the namespace policy, a BackendNotFound status; weighted splitting, TLS, ReferenceGrant and ListenerSet not tried)
- HPA autoscaling with metrics-server (kind needed the kubelet insecure TLS flag, lab only; scale up to 4 and back down to 1, a missing CPU request leaves the target unknown; memory and custom metrics, KEDA and a real request load not tried)

## Partly practiced
- Azure Artifacts (cheatsheet notes only, no hands-on)
- Azure Pipelines YAML (files exist, but never run in Azure DevOps)
- Azure Key Vault with pipelines (pipeline YAML and a CI rule blocking hardcoded secrets, never run against a real Key Vault)

## Not practiced yet
- Pipeline performance and cost tuning at scale (only a small caching lab; parallel jobs, agent sizing and cost tracking not practiced)
- GitOps (blocked by Codespace networking)

## Next labs, in order
1. Azure basics: identity, networking, Key Vault (needs a subscription or a Learn sandbox)
2. GenAI reading: LLM gateway, tokens and Langfuse traces (links to LiteLLM)

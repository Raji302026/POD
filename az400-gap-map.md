# AZ-400 gap map

Date: 2026-10-16 (updated 2026-11-26)

Marks are based on files in this repo. "Practiced" means a lab or workflow exists. Azure DevOps itself is blocked at work, so most labs use GitHub equivalents.

## Practiced
- Branch policies and protection (ruleset, required checks, proof of blocking)
- Secret scanning (gitleaks in CI, secret-scan check)
- Templates and reuse (extends template, reusable workflows, composite actions)
- Environments, approvals and deployment strategies (deploy-canary workflow, azure-pipelines-canary.yml)
- Identity (OIDC claims workflow)
- Variables and secrets (vars-and-secrets workflow)
- Infrastructure as code (Terraform modules, state, import; Bicep checks)
- Containers and Kubernetes (Helm, init containers and sidecars, probes (readiness, liveness and startup, exec probes only), taints and tolerations, affinity, PDB, quotas, network policy, PV/PVC, debugging)
- Observability (Prometheus, Alertmanager, Grafana, KQL queries)
- Metrics and incident process (DORA script, blameless postmortem)
- Policy as code (Conftest/OPA)
- Image hardening and scanning (Trivy)
- SBOM generation and scanning (CycloneDX via Trivy, trivy sbom)
- Kubernetes RBAC (Role, RoleBinding, ClusterRoleBinding, built-in view role, scope, kubectl auth can-i --as: a cluster binding survived deleting its namespace; custom ClusterRole, a real pod using a service account token and Azure RBAC not tried)
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
- Pod security (securityContext and Pod Security Admission in kind: restricted rejects a plain pod, a fixed pod runs as non-root, a Deployment is blocked at the ReplicaSet, baseline vs restricted with warn mode; audit mode, exemptions and Kyverno or Gatekeeper not tried)
- GitOps with Argo CD (an Application tracking a Git branch with automated sync, prune and selfHeal in kind: a Git change reached the cluster on its own polling timer, a manual scale was reverted within seconds, a bad image tag showed Synced but Progressing while old pods kept running, and a Git fix recovered it; prune, invalid YAML, private repos, UI or CLI login, Helm or Kustomize sources and ApplicationSet not tried)

## Partly practiced
- Azure Artifacts (cheatsheet notes only, no hands-on)
- Azure Pipelines YAML (files exist, but never run in Azure DevOps)
- Azure Key Vault with pipelines (pipeline YAML and a CI rule blocking hardcoded secrets, never run against a real Key Vault)
- Pipeline performance (GitHub Actions: caching, a parallel matrix vs sequential jobs, cancelling superseded runs, path filters, job timeouts; agent sizing, cost tracking and Azure DevOps equivalents not tried)
- LLM gateway basics (LiteLLM in front of a fake model: one endpoint, model name mapping, a bad key and an unknown model rejected before the backend, backend down gives HTTP 500 while the gateway stays alive; two fake backends behind one model name (one down gave no client errors, both down gave 500); no database so no virtual keys or budgets; fallbacks to another model, retry settings, real models and Langfuse not tried)

## Not practiced yet
- Nothing listed right now

## Next labs, in order
1. Azure basics: identity, networking, Key Vault (needs a subscription or a Learn sandbox)
2. GenAI reading: tokens in detail and Langfuse traces; the gateway basics are done with a fake model (links to LiteLLM)

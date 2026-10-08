# AZ-400 Cheat Sheet (built from hands-on labs)

## Branch policies and protection
- Azure DevOps branch policy with build validation = GitHub ruleset with required status checks.
- Require a PR, require checks to pass, keep the bypass list empty.

## Secret scanning
- Run a scanner (gitleaks) as a required PR check. Close, do not merge, a PR that leaked a secret.
- Masking only hides the exact value in logs. Prefer OIDC to storing secrets.

## Environments and approvals
- Environment approvals gate deployments (staging free, production needs a reviewer).

## Templates
- Azure Pipelines: `template:` with `parameters:`; types include string, boolean, stepList.
- `${{ if }}` is compile-time and removes the step. GitHub `if:` skips at runtime.
- `extends:` forces a pipeline to run inside an approved template. Pair with a Required template check.

## Identity
- Workload identity federation: no client secret to expire. Azure matches issuer and subject claims.

## Deployment strategies
- Rolling: batches, slow rollback. Blue-green: instant rollback, double cost.
- Canary: small share first, needs monitoring. Feature flags: ship off, enable later.

## Azure Artifacts
- Feeds for NuGet, npm, Maven, Python, Universal. Upstream sources cache public packages.
- Views (@local, @prerelease, @release) promote versions. Build service needs Contributor to publish.
- Package feeds are not the same as pipeline artifacts.

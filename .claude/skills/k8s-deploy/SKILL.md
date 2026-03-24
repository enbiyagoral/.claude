---
name: k8s-deploy
description: >
  Kubernetes deployment, rollout, scaling and pod management.
  Use this skill whenever the user mentions deploy, rollout, scale, pod, replica,
  namespace, helm, manifest, or anything related to Kubernetes/k8s —
  even if they don't explicitly say "deploy".
argument-hint: "[namespace] [manifest-path]"
allowed-tools: Bash(kubectl *), Bash(helm *)
disable-model-invocation: true
---

# Kubernetes deployment workflow

Deploy target: $ARGUMENTS

## Pre-deployment checks
1. Verify target namespace: `kubectl config current-context`
2. Check current state: `kubectl get pods -n <namespace>`
3. Check resource quotas: `kubectl describe quota -n <namespace>`

## Deployment steps
1. Validate manifest with dry-run:
   ```bash
   kubectl apply --dry-run=client -f <manifest>
   ```
2. Review changes with diff:
   ```bash
   kubectl diff -f <manifest>
   ```
3. Get user approval, then apply
4. Monitor rollout status:
   ```bash
   kubectl rollout status deployment/<name> -n <namespace>
   ```

## Rollback procedure
In case of failure:
```bash
kubectl rollout undo deployment/<name> -n <namespace>
```

## Environment-specific differences
- Staging details: see [references/staging.md](references/staging.md)
- Production details: see [references/production.md](references/production.md)

IMPORTANT: Always get explicit user approval before deploying to the production namespace.

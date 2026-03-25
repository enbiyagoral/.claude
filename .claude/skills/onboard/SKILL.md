---
name: onboard
description: >
  Project onboarding and template setup. Use when the user says onboard, setup,
  initialize, init, configure this project, or first-time setup.
argument-hint: "[project-path]"
allowed-tools: Read, Glob, Grep, Bash(ls *), Edit, Write
disable-model-invocation: true
---

# Project onboarding

Target: $ARGUMENTS

Run these three phases in order. Do NOT skip ahead — each phase informs the next.

---

## Phase 1 — Discovery (automatic, no user input needed)

Scan the project root and detect everything you can:

### Stack detection
Look for these files and infer the stack:
- `package.json` → Node.js (check for `next`, `react`, `vue`, `angular`, `express`, `nestjs`)
- `tsconfig.json` → TypeScript
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pyproject.toml`, `requirements.txt`, `setup.py` → Python (check for `django`, `flask`, `fastapi`)
- `Gemfile` → Ruby
- `pom.xml`, `build.gradle` → Java/Kotlin
- `*.csproj`, `*.sln` → .NET

### Project structure
- `src/`, `app/`, `pages/`, `components/` → frontend patterns
- `api/`, `server/`, `cmd/`, `internal/` → backend patterns
- `test/`, `tests/`, `__tests__/`, `spec/` → test location and framework
- `migrations/`, `prisma/`, `alembic/` → database tooling

### Infrastructure
- `Dockerfile`, `docker-compose.yml` → Docker
- `k8s/`, `helm/`, `charts/`, `manifests/` → Kubernetes
- `.github/workflows/` → GitHub Actions CI/CD
- `terraform/`, `*.tf` → Terraform (check for `terragrunt.hcl` → Terragrunt)
- `pulumi/`, `Pulumi.yaml` → Pulumi
- `serverless.yml`, `cdk.json` → Serverless/CDK
- `ansible/`, `playbook*.yml` → Ansible
- `.gitlab-ci.yml` → GitLab CI/CD
- `Jenkinsfile` → Jenkins
- `bitbucket-pipelines.yml` → Bitbucket Pipelines

### Existing documentation
- `README.md` → project description, setup instructions
- `docs/` → existing documentation
- `.env.example` → environment variables

Summarize all findings before proceeding.

---

## Phase 2 — Clarification (ask only what you couldn't detect)

Ask the user ONLY about things you could not determine from Phase 1. Skip questions you already have answers to.

Possible questions (ask only if needed):
1. "What does this project do in one sentence?" — only if README is missing or unclear
2. "Any team conventions I should know?" — coding style, PR rules, branch naming
3. "What environments do you deploy to?" — only if infra files weren't found
4. "Any areas of the codebase that are fragile or need extra care?"

Keep it to 3-4 questions maximum. If Phase 1 gave you enough, say so and move to Phase 3.

---

## Phase 3 — Apply (configure the template)

Make all changes based on Phase 1 findings and Phase 2 answers.

### 3a. Update CLAUDE.md
- Replace "What this repo is" with actual project description
- Replace "Structure" with detected project structure
- Update build/test/lint commands based on detected tooling
- Keep token efficiency, context management, permissions, and boundaries sections as-is

### 3b. Update .claude/settings.json permissions

- Remove permissions for tools not in use (no k8s? remove kubectl allows and deny rules)
- Add permissions for detected tools. Common mappings:
  - Go → `Bash(go *)`
  - Rust → `Bash(cargo *)`
  - Python → `Bash(pip *)`, `Bash(python *)`
  - Terraform → `Bash(terraform plan *)`, `Bash(terraform validate *)` (keep `terraform apply` out of allow — requires approval)
  - Terragrunt → `Bash(terragrunt plan *)`, `Bash(terragrunt validate *)`
  - Pulumi → `Bash(pulumi preview *)` (keep `pulumi up` out of allow)
  - Ansible → `Bash(ansible-lint *)`, `Bash(ansible-playbook --check *)`
- Update deny list for detected infra (e.g., `Bash(terraform destroy *)`, `Bash(terragrunt apply *production*)`)

### 3c. Update .claude/hooks/scripts/post-edit-lint.sh
- Remove linter cases for languages not in the project
- Add linter cases for detected languages if missing
- Verify the linter tools referenced are in the project's devDependencies or toolchain

### 3d. Update .claude/rules/
- **code-quality.md** — adjust rules to match detected stack conventions
- **common-mistakes.md** — leave the existing items, add any stack-specific ones if obvious
- **frontend-example.md** — if frontend detected, update paths to match actual structure. If no frontend, delete the file
- Add new path-specific rules if warranted (e.g., `api-rules.md` with `paths: ["api/**"]`)

### 3e. Clean up skills
- No Docker in project? Delete `.claude/skills/docker-debug/`
- No Kubernetes in project? Delete `.claude/skills/k8s-deploy/`
- Keep empty directories for skills the user may add later? No — delete what's not needed

### 3f. Update docs/architecture/OVERVIEW.md
- Fill in the template with detected architecture (services, dependencies, data flow)
- If the project is simple (single service), simplify the template accordingly

### 3g. Update .claudeignore
- Add any large directories specific to this project's stack
- Remove patterns that don't apply

---

## Final summary

After all changes, print:
1. List of files modified
2. List of files deleted
3. Any manual steps the user should take (e.g., "fill in API keys in .env")
4. Suggest: "Run `git diff` to review, then commit when ready"
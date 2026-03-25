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

First, check if `memory/onboard.md` exists — if it does, this is a **re-onboard**. Read it to understand previous setup, then only update what changed (new services, stack changes, etc.). Preserve any custom rules or settings the user added after the initial onboard.

Run these phases in order. Do NOT skip ahead — each phase informs the next.

---

## Phase 1 — Detect mode and stack (automatic)

### Step 1: Determine project mode

Scan the project root to understand what kind of project this is:

1. Check if `CLAUDE.md` contains template placeholders ("A reusable Claude Code project scaffolding")
2. Look for source/config files: `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `*.tf`, etc.
3. Check for multiple `.git/` directories in subdirectories (indicates independently cloned repos)
4. Check for monorepo markers: `turbo.json`, `nx.json`, `lerna.json`, `pnpm-workspace.yaml`, `Cargo.toml` with `[workspace]`

Determine the mode:

**Mode A — Single project**: One stack file at root, one `.git/`. Most common case.

**Mode B — Fresh project**: Template placeholders present, no source files yet. In Phase 2, ask what they're building. In Phase 3, configure with sensible defaults.

**Mode C — Monorepo**: Monorepo marker found at root (`turbo.json`, `nx.json`, etc.) with multiple packages/services sharing a build system.

**Mode D — Multi-service**: Multiple subdirectories each with their own stack file (`go.mod`, `package.json`, etc.) but sharing a single `.git/`. Independent services in one repo.

**Mode E — Modular monolith**: Single stack file at root but domain-separated folders (`src/modules/`, `internal/domains/`, etc.). One deployable, organized by domain.

**Mode F — Multi-repo**: Subdirectories each have their own `.git/` — independently cloned repos living side by side. No root-level stack file.

Print detected mode and ask user to confirm before continuing.

### Step 2: Detect stack (skip for Mode B)

Scan for stack indicators:

**Languages/frameworks:**

- `package.json` → Node.js (inspect deps for `next`, `react`, `vue`, `angular`, `express`, `nestjs`, `hono`)
- `tsconfig.json` → TypeScript
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pyproject.toml`, `requirements.txt` → Python (inspect for `django`, `flask`, `fastapi`)
- `Gemfile` → Ruby (inspect for `rails`, `sinatra`)
- `pom.xml`, `build.gradle` → Java/Kotlin
- `*.csproj`, `*.sln` → .NET
- `mix.exs` → Elixir
- `composer.json` → PHP

**Project structure:**

- `src/`, `app/`, `pages/`, `components/` → frontend patterns
- `api/`, `server/`, `cmd/`, `internal/` → backend patterns
- `test/`, `tests/`, `__tests__/`, `spec/` → test location and framework
- `migrations/`, `prisma/`, `alembic/`, `drizzle/` → database tooling

**Infrastructure:**

- `Dockerfile`, `docker-compose.yml` → Docker
- `k8s/`, `helm/`, `charts/`, `manifests/` → Kubernetes
- `*.tf` → Terraform; also check for `terragrunt.hcl` → Terragrunt
- `pulumi/`, `Pulumi.yaml` → Pulumi
- `ansible/`, `playbook*.yml` → Ansible
- `serverless.yml`, `cdk.json` → Serverless/CDK

**CI/CD (check inside each subdirectory too, not just root):**

- `.github/workflows/` → GitHub Actions
- `.gitlab-ci.yml` → GitLab CI
- `Jenkinsfile` → Jenkins
- `bitbucket-pipelines.yml` → Bitbucket Pipelines
- `.circleci/` → CircleCI
- `.pre-commit-config.yaml` → pre-commit hooks
- `semantic-release` config in `package.json` or `.releaserc` → semantic versioning

**Conventions (detect from files, don't ask):**

- Read `README.md` in 2-3 representative subdirectories to understand project purpose
- Check `git branch -r` in subdirectories for branch naming patterns
- Check `.github/PULL_REQUEST_TEMPLATE.md` for PR conventions
- Check `.editorconfig`, `.prettierrc`, `.eslintrc`, `.terraform-docs.yml` for style conventions
- Check `Makefile` or `justfile` for build/test/lint commands

**Existing docs:**

- `README.md` → project description
- `docs/` → documentation
- `.env.example` → environment variables

Summarize all findings before proceeding. The goal is to make Phase 2 unnecessary — detect everything you can from files.

---

## Phase 2 — Clarification (ONLY if Phase 1 left gaps)

STRICT RULES:

- Do NOT ask about anything you can detect from files (README, configs, git history, directory structure)
- Do NOT ask the user to confirm what you already found — state it and move on
- Do NOT ask about project purpose if README exists
- Do NOT ask about conventions if config files exist (`.editorconfig`, linter configs, `Makefile`)
- Do NOT ask about CI/CD if workflow files exist in any subdirectory

The only valid questions are things truly undetectable from code:

1. "Are there areas that need extra caution?" — fragile code, production-critical modules
2. "Any external dependencies or services not visible in the code?" — private registries, internal APIs

For **Mode B** (fresh project), ask:

1. "What are you building and with what stack?"
2. "Will this be a monorepo, multi-service, or single project?"

Ask mode confirmation once, then proceed. If Phase 1 covered everything, skip Phase 2 entirely and say so.

---

## Phase 3 — Apply (configure the template)

Make all changes based on Phase 1 findings and Phase 2 answers.

### 3a. Update CLAUDE.md

- Replace "What this repo is" with actual project description
- Replace "Structure" section with detected project structure
- Add build/test/lint commands based on detected tooling
- Keep token efficiency, context management, permissions, and boundaries sections as-is
- For **Mode F** (multi-repo): create a lightweight root CLAUDE.md listing each repo and its purpose

### 3b. Update .claude/settings.json permissions

- Remove permissions for tools not in use (no k8s? remove kubectl allows and deny rules)
- Add permissions for detected tools:
  - Go → `Bash(go *)`
  - Rust → `Bash(cargo *)`
  - Python → `Bash(pip *)`, `Bash(python -m *)`
  - Terraform → `Bash(terraform plan *)`, `Bash(terraform validate *)` (keep `terraform apply` out — requires approval)
  - Terragrunt → `Bash(terragrunt plan *)`, `Bash(terragrunt validate *)`
  - Pulumi → `Bash(pulumi preview *)` (keep `pulumi up` out)
  - Ansible → `Bash(ansible-lint *)`, `Bash(ansible-playbook --check *)`
- Update deny list for detected infra (e.g., `Bash(terraform destroy *)`, `Bash(terragrunt apply *production*)`)

### 3c. Update .claude/hooks/scripts/post-edit-lint.sh

- Remove linter cases for languages not in the project
- Add cases for detected languages if missing
- Verify the referenced linter tools exist in the project's devDependencies or toolchain

### 3d. Update .claude/rules/

- **code-quality.md** — adjust rules to match detected stack conventions
- **common-mistakes.md** — do NOT auto-fill. This is user-curated over time. Just leave the template as-is and remind the user to add their own patterns as they encounter them
- **frontend-example.md** — if frontend detected, update paths to match actual structure; if no frontend, delete the file
- Add new path-specific rules if warranted (e.g., `api-rules.md` with `paths: ["api/**"]`)
- For **Mode C/D** (monorepo/multi-service): add per-service path rules

### 3e. Clean up example skills

- List which example skills are not relevant to this project
- Ask user for confirmation before deleting any skill directories
- Do NOT delete this onboard skill — it's reusable for re-onboarding when the project evolves

### 3e-2. Suggest autonomous agents for DevOps projects

If the detected stack includes any of: Terraform, Terragrunt, Pulumi, Ansible, k8s, Helm, GitHub Actions, GitLab CI, Jenkins, AWS, GCP, Azure — ask:

```text
I noticed this is a DevOps/infrastructure project. Would you like to set up any autonomous agents?
These run on a schedule and track KPIs over time. A few useful examples for your stack:

• pipeline-monitor — tracks CI/CD failure rates and flaky tests
• drift-detector — detects infra drift between Terraform state and actual resources
• cost-tracker — monitors cloud spend against budget targets
• incident-logger — summarizes alerts and incident patterns from logs

Type `/new-agent <name>` to set one up, or say "skip" to continue.
```

If the user responds with a name or "yes" → immediately invoke the `/new-agent` workflow with that name.
If the user says "skip" or responds negatively → continue to Phase 4 without comment.

### 3f. Update docs/architecture/OVERVIEW.md

- Fill in with detected architecture (services, dependencies, data flow)
- For simple projects (single service), simplify the template accordingly
- For **Mode C/D/F**: document service boundaries and inter-service communication

### 3g. Update .claudeignore

- Add large directories specific to this project's stack
- Remove patterns that don't apply (e.g., no Go? remove `go/pkg/`)

---

## Phase 4 — Save to memory

Write `memory/onboard.md` with the following content so future sessions and re-onboards have context:

```markdown
---
name: onboard-result
description: Project onboarding results — mode, stack, services, and key decisions
type: project
---

- **Mode**: [detected mode A-F]
- **Stack**: [languages, frameworks, versions]
- **Services**: [list of services/packages if multi-service]
- **Infrastructure**: [Docker, K8s, Terraform, CI/CD, etc.]
- **Key decisions**: [any non-obvious choices made during onboard]
- **Last onboarded**: [date]
```

Update `memory/MEMORY.md` index to include a link to `onboard.md`.

---

## Final summary

After all changes, print:

1. Detected mode and stack
2. List of files modified
3. List of files deleted
4. Any manual steps the user should take (e.g., "add your API keys to .env")
5. Suggest: "Run `git diff` to review, then commit when ready"
---
name: onboard
description: >
  Project onboarding and template setup. Use when the user says onboard, setup,
  initialize, init, configure this project, or first-time setup. Guides through
  detecting project mode and stack, configuring CLAUDE.md, permissions, hooks,
  rules, and architecture docs.
argument-hint: "[project-path]"
allowed-tools: Read, Glob, Grep, Bash(ls *), Bash(find *), Bash(git branch -r *), Edit, Write, AskUserQuestion
disable-model-invocation: true
---

# Project Onboarding for Claude Code

This skill configures the Claude Code template for a specific project. It detects the project's mode, stack, and conventions, then tailors CLAUDE.md, permissions, hooks, rules, and docs to match.

## Before You Begin: Understand the Onboarding Model

Onboarding transforms a generic template into a project-specific Claude Code setup. The goal is **maximum auto-detection, minimum questions**.

### Onboarding principles

1. **Detect, don't ask.** Everything derivable from files (stack, conventions, CI/CD, structure) should be auto-detected. Only ask about things truly invisible in code.
2. **Confirm mode once, then proceed.** Don't ask the user to validate every finding — state what you found and move on.
3. **Preserve user customizations on re-onboard.** If `memory/onboard.md` exists, this is a re-onboard. Read it, detect what changed, update only what's new.
4. **One pass, all surfaces.** Configure CLAUDE.md, permissions, hooks, rules, and docs together — don't make the user run multiple setup commands.
5. **Leave room for growth.** Don't auto-fill `common-mistakes.md` or create rules for hypothetical problems. Set up the structure; let the user populate it through real usage.

### What gets configured

| File                            | What changes                                             | Why                                                  |
| ------------------------------- | -------------------------------------------------------- | ---------------------------------------------------- |
| `CLAUDE.md`                     | Project description, structure, build/test/lint commands | Agent needs project context every session            |
| `.claude/settings.json`         | Permissions for detected tools                           | Security: only allow what's needed                   |
| `.claude/hooks/scripts/`        | Linter cases for detected languages                      | Post-edit quality checks                             |
| `.claude/rules/`                | Stack-specific rule files                                | Coding conventions, architecture boundaries          |
| `docs/architecture/OVERVIEW.md` | Service map, dependencies, data flow                     | Agent needs system context for cross-cutting changes |
| `.claudeignore`                 | Stack-specific large directories                         | Token efficiency                                     |

---

Target: $ARGUMENTS

First, check if `memory/onboard.md` exists — if it does, this is a **re-onboard**. Read it to understand previous setup, then only update what changed (new services, stack changes, etc.). Preserve any custom rules or settings the user added after the initial onboard.

Run these phases in order. Do NOT skip ahead — each phase informs the next.

---

## Phase 1 — Detect Mode and Stack

### Step 1: Determine project mode

Scan the project root to understand what kind of project this is:

1. Check if `CLAUDE.md` contains template placeholders ("A reusable Claude Code project scaffolding")
2. Look for source/config files: `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `*.tf`, etc.
3. Check for multiple `.git/` directories in subdirectories (indicates independently cloned repos)
4. Check for monorepo markers: `turbo.json`, `nx.json`, `lerna.json`, `pnpm-workspace.yaml`, `Cargo.toml` with `[workspace]`

Determine the mode:

| Mode  | Name             | Indicators                                              | Key difference                          |
| ----- | ---------------- | ------------------------------------------------------- | --------------------------------------- |
| **A** | Single project   | One stack file at root, one `.git/`                     | Most common case                        |
| **B** | Fresh project    | Template placeholders present, no source files          | Ask what they're building               |
| **C** | Monorepo         | Monorepo marker at root (`turbo.json`, `nx.json`, etc.) | Multiple packages, shared build system  |
| **D** | Multi-service    | Multiple subdirs with own stack files, single `.git/`   | Independent services in one repo        |
| **E** | Modular monolith | Single stack file, domain-separated folders             | One deployable, organized by domain     |
| **F** | Multi-repo       | Subdirs each have own `.git/`                           | Independently cloned repos side by side |

Print detected mode and ask user to confirm before continuing.

### Step 2: Detect stack (skip for Mode B)

Scan for stack indicators across these categories:

#### Languages and frameworks

| File                                 | Stack       | Also check                                                              |
| ------------------------------------ | ----------- | ----------------------------------------------------------------------- |
| `package.json`                       | Node.js     | deps for `next`, `react`, `vue`, `angular`, `express`, `nestjs`, `hono` |
| `tsconfig.json`                      | TypeScript  | —                                                                       |
| `go.mod`                             | Go          | —                                                                       |
| `Cargo.toml`                         | Rust        | —                                                                       |
| `pyproject.toml`, `requirements.txt` | Python      | deps for `django`, `flask`, `fastapi`                                   |
| `Gemfile`                            | Ruby        | deps for `rails`, `sinatra`                                             |
| `pom.xml`, `build.gradle`            | Java/Kotlin | —                                                                       |
| `*.csproj`, `*.sln`                  | .NET        | —                                                                       |
| `mix.exs`                            | Elixir      | —                                                                       |
| `composer.json`                      | PHP         | —                                                                       |

#### Project structure patterns

| Pattern                                          | Indicates                   |
| ------------------------------------------------ | --------------------------- |
| `src/`, `app/`, `pages/`, `components/`          | Frontend patterns           |
| `api/`, `server/`, `cmd/`, `internal/`           | Backend patterns            |
| `test/`, `tests/`, `__tests__/`, `spec/`         | Test location and framework |
| `migrations/`, `prisma/`, `alembic/`, `drizzle/` | Database tooling            |

#### Infrastructure

| File                                     | Stack          | Notes                           |
| ---------------------------------------- | -------------- | ------------------------------- |
| `Dockerfile`, `docker-compose.yml`       | Docker         | —                               |
| `k8s/`, `helm/`, `charts/`, `manifests/` | Kubernetes     | —                               |
| `*.tf`                                   | Terraform      | Also check for `terragrunt.hcl` |
| `pulumi/`, `Pulumi.yaml`                 | Pulumi         | —                               |
| `ansible/`, `playbook*.yml`              | Ansible        | —                               |
| `serverless.yml`, `cdk.json`             | Serverless/CDK | —                               |

#### CI/CD (check inside subdirectories too, not just root)

| File                      | Platform            |
| ------------------------- | ------------------- |
| `.github/workflows/`      | GitHub Actions      |
| `.gitlab-ci.yml`          | GitLab CI           |
| `Jenkinsfile`             | Jenkins             |
| `bitbucket-pipelines.yml` | Bitbucket Pipelines |
| `.circleci/`              | CircleCI            |
| `.pre-commit-config.yaml` | Pre-commit hooks    |
| `semantic-release` config | Semantic versioning |

#### Conventions (detect from files, don't ask)

- Read `README.md` in 2-3 representative subdirectories to understand project purpose
- Check `git branch -r` in subdirectories for branch naming patterns
- Check `.github/PULL_REQUEST_TEMPLATE.md` for PR conventions
- Check `.editorconfig`, `.prettierrc`, `.eslintrc`, `.terraform-docs.yml` for style conventions
- Check `Makefile` or `justfile` for build/test/lint commands

#### Existing docs

- `README.md` → project description
- `docs/` → documentation
- `.env.example` → environment variables

Summarize all findings before proceeding. The goal is to make Phase 2 unnecessary — detect everything you can from files.

---

## Phase 2 — Clarification (ONLY if Phase 1 left gaps)

### Strict rules — what NOT to ask

- Do NOT ask about anything you can detect from files (README, configs, git history, directory structure)
- Do NOT ask the user to confirm what you already found — state it and move on
- Do NOT ask about project purpose if README exists
- Do NOT ask about conventions if config files exist (`.editorconfig`, linter configs, `Makefile`)
- Do NOT ask about CI/CD if workflow files exist in any subdirectory

### The only valid questions

Things truly undetectable from code:

1. "Are there areas that need extra caution?" — fragile code, production-critical modules
2. "Any external dependencies or services not visible in the code?" — private registries, internal APIs

For **Mode B** (fresh project), ask:

1. "What are you building and with what stack?"
2. "Will this be a monorepo, multi-service, or single project?"

Ask mode confirmation once, then proceed. If Phase 1 covered everything, **skip Phase 2 entirely** and say so.

---

## Phase 3 — Apply Configuration

Make all changes based on Phase 1 findings and Phase 2 answers. Apply everything in one pass.

### 3a. Update CLAUDE.md

- Replace "What this repo is" with actual project description
- Replace "Structure" section with detected project structure
- Add build/test/lint commands based on detected tooling
- Keep token efficiency, context management, permissions, and boundaries sections as-is
- For **Mode F** (multi-repo): create a lightweight root CLAUDE.md listing each repo and its purpose

**Principle:** CLAUDE.md is Tier 1 — loaded every session. Keep it dense and under budget (~1500 tokens with rule files combined). Put detailed docs in `docs/architecture/OVERVIEW.md` instead.

### 3b. Update .claude/settings.json permissions

Configure permissions based on detected tools:

| Stack      | Allow                                                      | Deny (keep out)                       |
| ---------- | ---------------------------------------------------------- | ------------------------------------- |
| Go         | `Bash(go *)`                                               | —                                     |
| Rust       | `Bash(cargo *)`                                            | —                                     |
| Python     | `Bash(pip *)`, `Bash(python -m *)`                         | —                                     |
| Terraform  | `Bash(terraform plan *)`, `Bash(terraform validate *)`     | `terraform apply` (requires approval) |
| Terragrunt | `Bash(terragrunt plan *)`, `Bash(terragrunt validate *)`   | `terragrunt apply *production*`       |
| Pulumi     | `Bash(pulumi preview *)`                                   | `pulumi up` (requires approval)       |
| Ansible    | `Bash(ansible-lint *)`, `Bash(ansible-playbook --check *)` | —                                     |

- Remove permissions for tools not in use (no k8s? remove kubectl allows and deny rules)
- Update deny list for detected infra (e.g., `Bash(terraform destroy *)`)

**Principle:** Permissions are deterministic enforcement — always run, can't be skipped. Keep `permissions.allow` minimal; add only what the active workflow needs. `git push` stays out of allow (requires approval every time).

### 3c. Update .claude/hooks/scripts/post-edit-lint.sh

- Remove linter cases for languages not in the project
- Add cases for detected languages if missing
- Verify the referenced linter tools exist in the project's devDependencies or toolchain

**Principle:** Hooks are deterministic — they always fire. Only include linters that are actually installed. A broken hook that fails on every edit is worse than no hook.

### 3d. Update .claude/rules/

Follow the control-surface matrix in `.claude/rules/README.md`:

- **README.md** — keep as guidance; do not treat it as an enforcement rule
- **common-mistakes.md** — do NOT auto-fill. This is user-curated over time. Leave the template as-is and remind the user to add patterns as they encounter them
- **safety-baseline.md** — keep as reference-only; enforcement lives in `settings.json` + `pre-bash-guard.sh`

Add stack-specific rule files based on detected conventions:

#### When to create a rule file

| Detected signal              | Rule to create                            | Example content                                        |
| ---------------------------- | ----------------------------------------- | ------------------------------------------------------ |
| TypeScript + strict tsconfig | `typescript.md`                           | "Never use `any`; prefer unknown + type guards"        |
| React/Vue/Angular detected   | `frontend.md`                             | "Prefer functional components; colocate styles"        |
| Go detected                  | `go.md`                                   | "Always handle errors; never use `_` for error return" |
| Terraform detected           | `terraform.md`                            | "Always run `terraform validate` before plan"          |
| API directory found          | `api-rules.md` (with `paths: ["api/**"]`) | "Always return structured error responses"             |
| Monorepo/multi-service       | Per-service path rules                    | `paths: ["services/auth/**"]`                          |

**Principle:** One concern per file. Keep each rule under 10 directive lines. Include a `Why` comment. Reference enforcement sources (settings/hook), don't restate them.

If frontend is detected, check for `examples/frontend-rule-example.md` — if found, copy to `.claude/rules/frontend.md` and update paths to match actual structure.

### 3e. Clean up example skills

- Glob `.claude/skills/` for any skill whose `SKILL.md` contains `<!-- example` or `# Example` in the first 5 lines
- If no example skills found → skip entirely
- If found: list them and ask the user which to keep or retire
- Do NOT delete this onboard skill — it's reusable for re-onboarding

### 3f. Suggest autonomous agents for DevOps projects

If the detected stack includes any of: Terraform, Terragrunt, Pulumi, Ansible, k8s, Helm, GitHub Actions, GitLab CI, Jenkins, AWS, GCP, Azure — suggest:

```text
I noticed this is a DevOps/infrastructure project. Would you like to set up any
autonomous agents? These run on a schedule and track KPIs over time:

• pipeline-monitor — tracks CI/CD failure rates and flaky tests
• drift-detector — detects infra drift between Terraform state and actual resources
• cost-tracker — monitors cloud spend against budget targets
• incident-logger — summarizes alerts and incident patterns from logs

Type /new-agent <name> to set one up, or say "skip" to continue.
```

If the user responds with a name → invoke `/new-agent` workflow immediately.
If skip → continue without comment.

### 3g. Deep architecture discovery — `docs/architecture/OVERVIEW.md`

This is the most important step of onboarding. Your goal is to **genuinely understand** the project — not scan for keywords, but figure out how the system actually works. Write the OVERVIEW.md as if explaining the system to a senior engineer on their first day.

#### How to approach this

You already know what technologies look like. Don't follow a checklist — follow your curiosity. Read the code, trace connections, and build a mental model. Then write down what you learned.

Start by answering these questions. Skip any that don't apply. Go deep on the ones that matter most for this specific project.

**How does a request enter the system and what happens to it?**

Trace a real request end to end. Find the entry point (API route, event handler, CLI command), follow it through middleware, business logic, and data access. Document the actual path with file names and function names. If there are multiple entry points (REST API, GraphQL, gRPC, message consumers), trace each one.

**How does someone get authenticated and authorized?**

Figure out the actual auth model. Is it JWT? Sessions? API keys? OAuth? What issues the tokens? What validates them? Where are roles and permissions defined? Is there an external identity provider or is it custom? Follow the middleware chain — what happens when a request arrives without valid credentials?

**How does a change get from a developer's machine to production?**

Map the entire delivery pipeline. What happens when someone pushes to main? Is there a staging environment? How are releases cut — tags, branches, manual? Is there GitOps (ArgoCD, FluxCD)? Helm charts? Raw manifests? Terraform? Understand the environment progression and what gates exist between them.

**Where does data live and how does it move?**

Identify every data store — not just "uses PostgreSQL" but which tables/collections matter, what ORM or query layer is used, how migrations work. Is there caching? Message queues? Event streaming? How does data flow between services? Are there any consistency boundaries or eventual consistency patterns?

**What's the network topology?**

Is there a VPN? API gateway? Load balancer? Service mesh? How do services find each other — DNS, service discovery, hardcoded URLs? Are there network policies or firewall rules? What's exposed to the internet vs internal-only?

**How are secrets and configuration managed?**

Where do environment variables come from? Is there a secrets manager (Vault, AWS Secrets Manager, sealed-secrets)? How does config differ between environments? Are there feature flags? How does a developer set up their local environment?

**How do you know when something is broken?**

What monitoring exists? Structured logging? Metrics? Distributed tracing? Alerting? Where do you look when something goes wrong at 3am? Dashboards? Log aggregation?

**What would break if the wrong thing changed?**

This is about understanding blast radius. Which services depend on which? What are the single points of failure? Are there any shared databases that multiple services write to? What changes require coordinated deployments?

#### Writing the OVERVIEW.md

For each question you could answer, write a section in `docs/architecture/OVERVIEW.md`. Be specific:

- **Good:** "Auth uses JWT issued by `src/services/auth.ts:generateToken()`. Tokens are validated by Express middleware in `src/middleware/auth.ts`. Refresh tokens are stored in Redis (`auth:refresh:{userId}`) with 7-day TTL. Roles are defined in `src/config/roles.ts` — currently `admin`, `editor`, `viewer`."
- **Bad:** "The project uses JWT-based authentication with Redis for session storage."

The difference is that the good version lets the next Claude session make changes confidently. The bad version tells you nothing you couldn't guess.

**For simple projects (Mode A):** You might only need 3-4 sections. Don't force complexity.
**For multi-service (Mode C/D/F):** Document each service's role, how they communicate, and which ones can be changed independently vs require coordinated changes.

See `examples/architecture-overview-example.md` for the expected depth and format.

### 3h. Update .claudeignore

- Add large directories specific to this project's stack
- Remove patterns that don't apply (e.g., no Go? remove `go/pkg/`)

---

## Phase 4 — Save to Memory

Write `memory/onboard.md` so future sessions and re-onboards have context:

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

### Feedback loop tip

After writing the onboard memory, print:

```text
The knowledge lifecycle is now automatic:

  1. As you work, Claude saves corrections and discoveries to memory (every session)
  2. When feedback patterns accumulate, the Stop hook promotes them to rules (automatic)
  3. When common-mistakes.md fills up, resolved items graduate to docs/learnings/ (automatic)
  4. Old learnings (6+ months) get archived to docs/archive/ (automatic)

You don't need to manage this — just work normally and correct Claude when it's wrong.
The system improves itself. Run /improve manually if you want to force a review cycle.
```

---

## Phase 5 — Final Summary

After all changes, print:

1. Detected mode and stack
2. List of files modified
3. List of files deleted (if any)
4. Any manual steps the user should take (e.g., "add your API keys to .env")
5. Suggest: "Run `git diff` to review, then commit when ready"

---

## Re-Onboarding Workflow

When `memory/onboard.md` already exists, follow this modified flow:

1. **Read previous state** from `memory/onboard.md`
2. **Detect current state** using Phase 1
3. **Diff the two**: what's new, what's removed, what changed?
4. **Update only what changed** — don't regenerate everything
5. **Preserve user customizations**: any rules, permissions, or hooks the user added after initial onboard should be kept
6. **Update `memory/onboard.md`** with new state and date

Ask: "I found these changes since last onboard: [list]. Should I apply all of them?"

---

## Anti-Patterns to Avoid

| Anti-pattern                                  | Problem                                 | Fix                                                         |
| --------------------------------------------- | --------------------------------------- | ----------------------------------------------------------- |
| Asking about things visible in files          | Wastes time, annoys user                | Detect from README, configs, git history                    |
| Auto-filling `common-mistakes.md`             | Creates rules for hypothetical problems | Leave empty; user fills from real experience                |
| Adding permissions for unused tools           | Security surface expansion              | Only allow what's detected and needed                       |
| Creating rules for every detected pattern     | Token budget blown, noise               | Only create rules for strong conventions with clear signals |
| Overwriting user customizations on re-onboard | Destroys manual tuning                  | Read previous state, update only diffs                      |
| Putting detailed docs in CLAUDE.md            | Tier 1 budget exceeded                  | CLAUDE.md for essentials; details in `docs/architecture/`   |
| Including broken linters in hooks             | Every edit fails the hook               | Verify tool exists before adding to hook                    |
| Asking the user to validate every finding     | Tedious, no value added                 | State what you found, move on                               |

---

## Complete Example

**Scenario:** Onboarding a Node.js + TypeScript monorepo with React frontend and Express API.

### Phase 1 detection output

```text
Mode: C (Monorepo — turbo.json detected)
Stack:
  - TypeScript (tsconfig.json, strict mode)
  - React 18 (packages/web/package.json)
  - Express + Prisma (packages/api/package.json)
  - PostgreSQL (prisma/schema.prisma)
Infrastructure:
  - Docker (docker-compose.yml)
  - GitHub Actions (.github/workflows/)
CI/CD:
  - PR checks: lint + test + build
  - Deploy: main → staging, tags → production
Conventions:
  - ESLint + Prettier configured
  - Conventional commits (commitlint config found)
  - Jest for testing
Build commands:
  - turbo run build
  - turbo run test
  - turbo run lint
```

### Files modified

```text
Modified:
  CLAUDE.md                              — project description, structure, commands
  .claude/settings.json                  — npm/turbo/prisma permissions added
  .claude/hooks/scripts/post-edit-lint.sh — TypeScript + ESLint cases
  .claude/rules/typescript.md            — strict TS conventions
  .claude/rules/frontend.md              — React patterns (paths: packages/web/**)
  .claude/rules/api-rules.md             — API conventions (paths: packages/api/**)
  .claudeignore                          — node_modules, .next, dist
  docs/architecture/OVERVIEW.md          — service map, API → DB flow
  memory/onboard.md                      — onboard results saved
  memory/MEMORY.md                       — index updated
```

---

## Verification Checklist

- [ ] Mode correctly detected and confirmed by user
- [ ] Stack detection covers languages, frameworks, infra, CI/CD, and conventions
- [ ] Phase 2 only asked about things not detectable from files
- [ ] CLAUDE.md updated with project-specific content, stays within token budget
- [ ] Permissions match detected tools — nothing extra, nothing missing
- [ ] Hook linters verified to exist before adding
- [ ] Rule files are concise (under 10 lines each), one concern per file
- [ ] `common-mistakes.md` left as template (not auto-filled)
- [ ] Architecture doc filled in
- [ ] `.claudeignore` updated for detected stack
- [ ] Memory saved with mode, stack, and key decisions
- [ ] User customizations preserved (on re-onboard)
- [ ] Final summary printed with files modified and manual steps

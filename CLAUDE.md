# Project: [PROJECT_NAME]

[Domain, core concept, and main flow in 2-3 sentences. Example:
"E-commerce order processing service. Receives orders via REST API,
validates inventory through warehouse service, and dispatches
fulfillment events to Kafka. Handles ~50K orders/day."]

## Tech stack

- [Language/framework]
- [Database]
- [Infrastructure]
- [CI/CD]

## Quick reference

- Entry point: [e.g. src/index.ts, cmd/main.go, main.tf]
- Core logic: [e.g. src/application/, modules/]
- Config: [e.g. config/, helm/values.yaml]
- System design: @docs/architecture/OVERVIEW.md

## Common commands

```bash
# Build
[your build command]

# Test (single file — prefer this over full suite)
[your single test command]

# Lint
[your lint command]

# Type check
[your typecheck command]

# Deploy (dry-run)
[your dry-run deploy command]
```

## Code style

- Use ES modules (import/export) syntax
- Prefer functional components with hooks
- Add explicit return types to all functions
- Handle errors with custom error classes
- Use structured logging with context fields (never raw print/console.log)

## Architecture

- `src/` — Source code
- `tests/` — Test files (mirrors src/ structure)
- `deploy/` — Kubernetes manifests and Helm charts
- `docs/` — Detailed docs (read on demand: @docs/architecture/)

## Boundaries

- IMPORTANT: Always create a feature branch for changes; merge to `main` via PR
- Route production deploys through `deploy/staging/` first; only CI touches `deploy/production/`
- Keep secrets in vault/env manager; reference them by name (never log or commit secret values)
- Create new migration files for schema changes; treat existing migrations as immutable history
- Regenerate generated files from source; treat them as read-only (never edit directly)

## Output preferences

- Explain what you will change and why before implementing
- Show dry-run or diff output before destructive operations
- [Add your own non-default preferences here]

## Workflow

- Run typecheck and lint after every code change
- Run the single relevant test file, not the full suite
- For complex tasks: plan first, get approval, then implement

## Additional context

- Git workflow: @docs/git-workflow.md
- API conventions: @docs/api-conventions.md
- Personal overrides: @~/.claude/CLAUDE.md

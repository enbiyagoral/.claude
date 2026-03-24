# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A reusable Claude Code project scaffolding template. Provides a 3-tier context architecture — skills, agents, hooks, and rules — designed to be copied into any project and customized.

The repo itself IS the `.claude` directory structure that lives at a project root. When working here, you are editing the template, not a running application.

## Structure

- `CLAUDE.md` + `.claude/rules/` — Tier 1: always loaded each session
- `.claude/skills/`, `.claude/agents/`, `docs/learnings/` — Tier 2: loaded only when triggered
- `docs/archive/`, `.claude/skills/*/references/` — Tier 3: loaded only on explicit request
- `docs/architecture/OVERVIEW.md` — system design template (fill in when copied to a project)
- `examples/` — Reference templates (not loaded automatically)

## Key files

- `.claude/settings.json` — permissions, PostToolUse hooks, and SessionStart compact hook
- `.claude/rules/code-quality.md` — always-loaded team coding standards
- `.claude/rules/common-mistakes.md` — top active bugs (max 10 items; graduate resolved ones to `docs/learnings/`)
- `.claude/hooks/scripts/post-edit-lint.sh` — runs after every Write/Edit; auto-lints TS/JS, Python, Go
- `.claude/skills/k8s-deploy/` — Kubernetes deploy workflow (triggered by: deploy, rollout, helm, pod, etc.)
- `.claude/skills/docker-debug/` — Docker debug workflow (triggered by: container, crash, OOMKilled, etc.)
- `.claude/agents/code-reviewer.md` — subagent for code review (runs in its own context window, has persistent memory)
- `.claude/rules/frontend-example.md` — path-specific rule example (only loads for matching file patterns)

## Customization workflow

When adding or modifying this template:

1. **New skill** — create `.claude/skills/<name>/SKILL.md` with a trigger description and workflow steps; add environment-specific detail to `references/` (Tier 3)
2. **New rule** — add to `.claude/rules/`; keep files short. Use `paths` frontmatter to scope rules to specific file patterns (see `frontend-example.md`)
3. **New hook** — add script to `.claude/hooks/scripts/`, wire it in `settings.json` under the appropriate event
4. **Graduating a common mistake** — move the item from `common-mistakes.md` to a `docs/learnings/YYYY-MM-DD-<slug>.md` file using the template in `docs/learnings/README.md`
5. **New agent** — add to `.claude/agents/`; use agents (not skills) for tasks that would pollute the main conversation context

## Design constraints

- `CLAUDE.md` + all `rules/` files combined should stay under ~500 tokens — keep them dense and non-redundant
- `common-mistakes.md` must stay under 10 items
- Hooks are deterministic (always run); CLAUDE.md instructions are advisory (Claude may skip)
- Scripts in `skills/*/scripts/` should be deterministic status checks or formatters — not reconstruction of logic Claude should reason through
- `docs/archive/` is listed in `.claudeignore` — 0 token cost; anything superseded goes there

## Context management

When compacting, always preserve: the list of modified files, test commands that were run, and any architectural decisions made during the session.

## Permissions notes

`git push` is intentionally NOT in the allow list — Claude should ask for approval every time before pushing. Force push and `git reset --hard` are in the deny list. If your project needs `git push` auto-allowed, add it to `settings.local.json` (not the shared settings).

## Boundaries

- Never commit `.claude/settings.local.json` — it's gitignored for personal overrides
- Keep secrets out of all tracked files; reference by name only
- `docs/archive/` is for superseded content only — never delete outright, archive it

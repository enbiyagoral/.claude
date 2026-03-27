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
- `examples/` — Reference templates (not loaded automatically; copy and customize for your project)

## Customization workflow

When adding or modifying this template:

1. **New skill** — create `.claude/skills/<name>/SKILL.md` with a trigger description and workflow steps; add environment-specific detail to `references/` (Tier 3)
2. **New control** — choose the correct surface using `.claude/rules/README.md`: rule file for policy intent, `settings.json` for command permissions, hook script for advanced runtime guards
3. **New hook** — add script to `.claude/hooks/scripts/`, wire it in `settings.json` under the appropriate event
4. **Graduating a common mistake** — move the item from `common-mistakes.md` to a `docs/learnings/YYYY-MM-DD-<slug>.md` file using the template in `docs/learnings/README.md`
5. **New agent** — add to `.claude/agents/`; use agents (not skills) for tasks that would pollute the main conversation context

## Design constraints

- `CLAUDE.md` + all `rules/` files combined should stay under ~1500 tokens — keep them dense and non-redundant
- `common-mistakes.md` must stay under 10 items
- Hooks are deterministic (always run); CLAUDE.md instructions are advisory (Claude may skip)
- Scripts in `skills/*/scripts/` should be deterministic status checks or formatters — not reconstruction of logic Claude should reason through
- `docs/archive/` is listed in `.claudeignore` — 0 token cost; anything superseded goes there
- Memory is proactive: save project learnings and user corrections every session — enforced by Stop hook and `.claude/rules/proactive-memory.md`

## Token efficiency

### Search behavior

- Read only the relevant section of large files — use `offset` and `limit` parameters
- Prefer Grep/Glob over Bash for file search — dedicated tools are cheaper and don't fill context
- Don't re-read files you already read in this session — use the information you have
- Be specific in searches: target `file:line` instead of scanning entire directories
- Stop searching once you have enough information to act — don't explore "just in case"

### Model selection

- Default to **Sonnet** for everyday tasks (edits, tests, simple bugs)
- Use **Opus** only for complex architecture, multi-file refactoring, or deep debugging
- Use **plan mode** (Shift+Tab) for analysis — it halves token consumption vs execute mode
- Proactively recommend the optimal model before starting a task — enforced by `.claude/rules/model-guidance.md`

### Session hygiene

- One task per session: a bug fix OR a feature OR a refactor — not all three
- `/clear` when switching to unrelated work — stale context wastes tokens on every subsequent message
- `/compact Focus on <topic>` at ~40 messages or ~50% context usage
- Keep sessions focused: 30-45 minutes, then start fresh

### Context protection

- Delegate verbose tasks (test runs, log analysis, research) to subagents — output stays in their context
- Don't echo back file contents — summarize findings instead
- Audit MCP servers with `/context` — each MCP adds tool definitions even when idle. Prefer CLI tools (`gh`, `aws`) over MCPs when possible
- Set `MAX_THINKING_TOKENS=10000` for simple tasks; use `/effort` to lower effort level

## Context management

When compacting, always preserve: the list of modified files, test commands that were run, and any architectural decisions made during the session. Drop verbose tool outputs and intermediate exploration results.

## Permissions notes

`git push` is intentionally NOT in the allow list — Claude should ask for approval every time before pushing. Force push and `git reset --hard` are in the deny list. If your project needs `git push` auto-allowed, add it to `settings.local.json` (not the shared settings).

## Boundaries

- Never commit `.claude/settings.local.json` — it's gitignored for personal overrides
- Keep secrets out of all tracked files; reference by name only
- `docs/archive/` is for superseded content only — never delete outright, archive it

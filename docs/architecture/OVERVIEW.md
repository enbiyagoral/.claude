# Architecture overview

<!-- This file dogfoods the template: it describes the scaffolding's own architecture.
     When you copy this template to a project, replace this content with YOUR project's architecture. -->

## System architecture

A 3-tier context architecture for Claude Code projects. Controls token budget by loading information at the right time — not all at once.

```
Tier 1 (always loaded, ~500 tokens)
├── CLAUDE.md              — project conventions & constraints
└── .claude/rules/*.md     — hard rules (code-quality, common-mistakes)

Tier 2 (loaded on demand)
├── .claude/skills/        — deterministic workflows triggered by user
├── .claude/agents/        — subagent & autonomous agent definitions
└── docs/learnings/        — graduated lessons from past mistakes

Tier 3 (loaded on explicit request, zero idle cost)
├── docs/archive/          — superseded content (.claudeignore'd)
├── .claude/skills/*/references/  — environment-specific detail
└── examples/              — reference templates
```

## Component map

- **Skills** — Deterministic SKILL.md files with frontmatter. `disable-model-invocation: true` means Claude follows steps exactly. Organized by lifecycle: scaffold (new-_), manage (update-_, list-\*), retire/restore, and utility (recall, graduate, context-check).
- **Agents** — Type A (single .md, subagent) or Type B (directory with AGENT.md + HEARTBEAT.md, autonomous). Currently: code-reviewer (Type A).
- **Hooks** — Shell scripts in `.claude/hooks/scripts/`, wired via `.claude/settings.json`. Deterministic (always run), unlike CLAUDE.md instructions (advisory). Events: PreToolUse, PostToolUse, Stop, SessionStart.
- **Rules** — Short, directive files in `.claude/rules/`. Scoped globally or to file patterns via `paths` frontmatter. Combined budget with CLAUDE.md: ~500 tokens.

## Data flow

```
User request
  │
  ├─ Tier 1 loaded automatically (CLAUDE.md + rules/)
  │
  ├─ /skill-name triggered?
  │    └─ Yes → Load SKILL.md, follow steps deterministically
  │
  ├─ Agent needed?
  │    └─ Yes → Spawn subagent with AGENT.md context
  │
  ├─ Tool used? (Bash, Write, Edit)
  │    └─ Hook fires (PreToolUse → guard, PostToolUse → lint/format)
  │
  └─ Session ends → Stop hook checks uncommitted changes
```

## Key design decisions

1. **Hooks over CLAUDE.md for enforcement** — CLAUDE.md is advisory; Claude may skip instructions under pressure. Hooks are deterministic shell scripts that always execute. Use hooks for anything that MUST happen.
2. **Archive over delete** — `retire-skill` and `retire-agent` move to `archive/` instead of deleting. Zero token cost (`.claudeignore`), fully reversible via `restore-*`.
3. **Stdin JSON, not positional args** — Claude Code passes hook context via stdin as JSON. All hook scripts use `jq` to parse, never `$1`. This is the #1 gotcha for new hook authors.
4. **Token budget cap** — Tier 1 stays under ~500 tokens. If rules grow, archive or graduate the least critical ones. Skills/agents are Tier 2 and don't count toward this budget.
5. **Deterministic skills by default** — `disable-model-invocation: true` ensures skills follow their steps exactly. Only remove this for skills that genuinely need creative interpretation.

## Dependency map

```
CLAUDE.md ← references rules/, docs/architecture/
rules/    ← independent, no cross-references
skills/   ← some reference other skills (retire → restore, graduate → learnings)
agents/   ← Type B agents reference skills in their Skills table
hooks/    ← wired in settings.json, scripts are independent
```

No circular dependencies. Skills may reference each other by name but never import or include.

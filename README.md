# Claude Code Project Template

Token-efficient project structure template for Claude Code, following best practices.

## Structure and purpose of each file

```
my-project/
│
├── CLAUDE.md                          # [TIER 1] Loaded every session (~450 tokens)
├── .claudeignore                      # Prevents context pollution
│
├── .claude/
│   ├── settings.json                  # Permissions, hooks (committed to git)
│   ├── settings.local.json            # Personal settings (in gitignore)
│   │
│   ├── rules/                         # [TIER 1] Loaded alongside CLAUDE.md
│   │   └── code-quality.md            # Team-wide coding standards
│   │
│   ├── skills/                        # [TIER 2] Loaded only when triggered
│   │   └── k8s-deploy/
│   │       ├── SKILL.md               # Frontmatter + instructions
│   │       └── references/            # [TIER 3] Loaded only when going deeper
│   │           ├── staging.md
│   │           └── production.md
│   │
│   ├── agents/                        # Independent subtasks
│   │   └── code-reviewer.md           # Runs in its own context
│   │
│   └── hooks/                         # Deterministic — runs every time
│       └── scripts/
│           └── post-edit-lint.sh      # Auto-lint after file edits
│
├── docs/
│   ├── architecture/                  # Pulled in as needed via @import
│   │   └── OVERVIEW.md
│   ├── learnings/                     # Mistakes Claude shouldn't repeat
│   └── archive/                       # In claudeignore — 0 tokens
│
├── src/                               # Source code
└── tests/                             # Tests
```

## 3-tier token strategy

### Tier 1 — Loaded every session (~800 tokens)
- `CLAUDE.md` — Project identity, commands, code style, constraints
- `.claude/rules/*.md` — Team-wide rules
- Goal: 85%+ relevant context

### Tier 2 — Loaded on demand (0 tokens at startup)
- `.claude/skills/*/SKILL.md` — Only metadata (~100 tokens/skill) is scanned; body is loaded only when triggered
- `.claude/agents/*.md` — Runs as a subtask, doesn't pollute the main context
- `docs/` — Referenced via @import from CLAUDE.md

### Tier 3 — Never auto-loaded (0 tokens)
- `docs/archive/` — In .claudeignore
- `.claude/sessions/`, `.claude/completions/` — In .claudeignore
- Skill `references/` folders — Claude reads only when necessary

## Setup

1. Copy this template to the root of your project
2. Fill in the `[placeholder]` values in `CLAUDE.md`
3. Adjust permissions in `.claude/settings.json` to fit your project
4. Delete any skills/agents you don't need
5. Add new skills you do need
6. Commit to git

## Customization guide

### When editing CLAUDE.md
- For every line, ask: "Would removing this cause Claude to make a mistake?"
- If no → delete it
- If yes → keep it, but write it as concisely as possible
- Don't exceed 200 lines — if you do, move details out via @import
- Write positive instructions: "use X" > "don't use Y"
- Add IMPORTANT to critical rules (but not everything can be IMPORTANT)

### When adding a new skill
- Create `.claude/skills/[skill-name]/SKILL.md`
- `name` and `description` are required in frontmatter
- Write the description assertively — Claude tends to undertrigger
- Keep SKILL.md under 500 lines
- Put large reference files under `references/`
- Add executables under `scripts/` for deterministic tasks

### When adding a new agent
- Create `.claude/agents/[agent-name].md`
- Frontmatter: tools, model, permissionMode, maxTurns
- Runs independently from the main context — ideal for research/review tasks

### When adding a hook
- Add to the hooks section in `.claude/settings.json`
- PreToolUse: block dangerous commands
- PostToolUse: auto-format/lint
- Stop: verification after a run completes

## Context management tips

- Run `/compact` before context reaches 50%
- Use `/clear` to reset when switching tasks
- Delegate research tasks to a subagent
- If you've fixed the same bug 2+ times — `/clear` and start fresh
- Monitor context window usage with `/context`

## Hierarchical file loading

```
~/.claude/CLAUDE.md          → Applies to all projects (personal)
./CLAUDE.md                  → This project (shared with team)
./src/api/CLAUDE.md          → Only active when working under src/api/
./src/frontend/CLAUDE.md     → Only active when working under src/frontend/
```

A CLAUDE.md in a subdirectory can override the one in its parent directory.
In monorepos, you can place a dedicated CLAUDE.md in each module.
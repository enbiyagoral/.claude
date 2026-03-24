# .claude

Token-efficient Claude Code project scaffolding. 3-tier context architecture with skills, agents, hooks, and rules — ready to drop into any project.

## Structure

```
your-project/
├── CLAUDE.md                              # Tier 1 — loaded every session (~500 tokens)
├── .claudeignore                          # Keeps noise out of context
├── .gitignore                             # Claude-aware git ignores
│
├── .claude/
│   ├── settings.json                      # Permissions + hooks (commit to git)
│   ├── settings.local.json                # Personal overrides (gitignored)
│   │
│   ├── rules/                             # Tier 1 — loaded alongside CLAUDE.md
│   │   ├── code-quality.md                # Team-wide coding standards
│   │   ├── common-mistakes.md             # Top 10 active bugs (graduate to learnings/)
│   │   └── frontend-example.md            # Path-specific rule (loads only for matching files)
│   │
│   ├── skills/                            # Tier 2 — only metadata scanned at startup
│   │   ├── k8s-deploy/
│   │   │   ├── SKILL.md                   # Loaded when triggered (~100 token scan)
│   │   │   └── references/                # Tier 3 — loaded only when needed
│   │   │       ├── staging.md
│   │   │       └── production.md
│   │   └── docker-debug/
│   │       ├── SKILL.md
│   │       └── scripts/
│   │           └── container-status.sh    # Deterministic — runs, not reconstructed
│   │
│   ├── agents/                            # Independent subagents with own context
│   │   └── code-reviewer.md
│   │
│   └── hooks/                             # Deterministic — always runs, can't be skipped
│       └── scripts/
│           └── post-edit-lint.sh
│
├── memory/
│   └── MEMORY.md                          # Memory index template (tracked; actual memories gitignored)
│
├── docs/
│   ├── architecture/
│   │   └── OVERVIEW.md                    # @imported from CLAUDE.md on demand
│   ├── learnings/                         # Detailed post-mortems (Tier 2)
│   │   ├── README.md                      # Template + graduation flow
│   │   └── 2026-03-24-helm-values-override-order.md
│   └── archive/                           # Claudeignored — 0 tokens
│       └── README.md
│
└── examples/
    └── personal-claude.md                 # Template for ~/.claude/CLAUDE.md
```

## 3-tier token strategy

### Tier 1 — Always loaded (~500 tokens)
| File | Purpose | Token cost |
|------|---------|------------|
| `CLAUDE.md` | Project identity, commands, style, boundaries | ~400 |
| `.claude/rules/*.md` | Team standards + common mistakes | ~100 |

### Tier 2 — Loaded on trigger (0 tokens at startup)
| File | Purpose | When loaded |
|------|---------|-------------|
| `.claude/skills/*/SKILL.md` | Specialized workflows | User request matches description |
| `.claude/agents/*.md` | Independent subtasks | Delegated by main session |
| `docs/learnings/*.md` | Bug post-mortems | Working in related area |
| `docs/architecture/` | System design | @imported from CLAUDE.md |
| `memory/*.md` | Persistent Claude memory | Auto-loaded via MEMORY.md index |

### Tier 3 — Never auto-loaded (0 tokens)
| File | Purpose | How to access |
|------|---------|---------------|
| `docs/archive/` | Outdated docs | Explicitly ask Claude to read |
| `skills/*/references/` | Environment-specific detail | Claude reads when drilling down |

## Setup

```bash
# Clone into your project root
git clone https://github.com/[you]/.claude.git /tmp/.claude-template

# Copy structure (preserves dotfiles)
cp -r /tmp/.claude-template/{CLAUDE.md,.claude,.claudeignore,.gitignore,docs,memory} your-project/

# Clean up
rm -rf /tmp/.claude-template
```

1. Fill in `CLAUDE.md` placeholders
2. Adjust `.claude/settings.json` permissions for your stack
3. Delete example skills/agents you don't need
4. Add skills for your actual workflows
5. Commit to git

## Key design decisions

**Why `common-mistakes.md` AND `docs/learnings/`?**

Common mistakes is Tier 1 (max 10 items, always loaded). When it gets crowded,
graduate rare/resolved items to learnings/ with full detail. Learnings is Tier 2
(loaded on demand). This keeps session startup lean.

**Why `scripts/` inside skills?**

Deterministic tasks (status checks, lint, format) go in scripts so Claude runs
them instead of reconstructing the logic each time. Saves tokens + ensures consistency.

**Why agents instead of more skills?**

Agents run in their own context window. Use them for tasks that would pollute
your main conversation (code review, research, large refactors).

**Why hooks instead of CLAUDE.md instructions?**

CLAUDE.md is advisory — Claude might forget. Hooks are deterministic — they
always run. Use hooks for things that must happen every time without exception.

## Customization

See `examples/personal-claude.md` for a `~/.claude/CLAUDE.md` template
that applies your personal preferences across all projects.

## License

MIT

<p align="center">
  <h1 align="center">.claude</h1>
  <p align="center">
    Token-efficient Claude Code project scaffolding.<br>
    3-tier context architecture with skills, agents, hooks, and rules — drop into any project.
  </p>
  <p align="center">
    <a href="https://github.com/enbiyagoral/.claude/stargazers"><img src="https://img.shields.io/github/stars/enbiyagoral/.claude?style=flat&color=yellow" alt="Stars"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
    <a href="https://github.com/enbiyagoral/.claude/forks"><img src="https://img.shields.io/github/forks/enbiyagoral/.claude?style=flat" alt="Forks"></a>
  </p>
</p>

---

## Why this exists

Claude Code without structure burns tokens fast. Community reports show:

- A single "edit this file" command can consume **50k–150k tokens** because the entire conversation history is sent each time
- After 15 iterative commands, the final call can send **200k+ input tokens**
- **40–60% of Read token usage** comes from re-reading files Claude already saw
- Sessions regularly hit **50–80+ tool calls** for tasks that should take 10

This template gives Claude the structure it needs to stay focused: what to load when, what to ignore, and how to search efficiently — so you spend tokens on actual work, not exploration.

## Quick start

```bash
# 1. Clone the template
git clone https://github.com/enbiyagoral/.claude.git /tmp/.claude-template

# 2. Copy into your project
cp -r /tmp/.claude-template/{CLAUDE.md,.claude,.claudeignore,.gitignore,docs,memory} your-project/

# 3. Clean up
rm -rf /tmp/.claude-template
```

Then run the onboarding skill — it auto-detects your stack, asks a few questions, and configures everything:

```
/onboard
```

## How it works — 3-tier token strategy

```
your-project/
├── CLAUDE.md                              # Tier 1 — loaded every session (~500 tokens)
├── .claudeignore                          # Keeps noise out of context
├── .claude/
│   ├── settings.json                      # Permissions + hooks
│   ├── rules/                             # Tier 1 — coding standards, common mistakes
│   ├── skills/                            # Tier 2 — loaded only when triggered
│   │   ├── onboard/                       #   Auto-detects stack, configures template
│   │   ├── k8s-deploy/                    #   Deploy workflow + env-specific references
│   │   └── docker-debug/                  #   Container troubleshooting + status script
│   ├── agents/                            # Tier 2 — independent subagents (own context)
│   │   └── code-reviewer.md
│   └── hooks/scripts/                     # Deterministic — always runs, can't be skipped
│       └── post-edit-lint.sh
├── memory/                                # Persistent cross-session memory
├── docs/
│   ├── architecture/                      # System design (Tier 2 — @imported on demand)
│   ├── learnings/                         # Post-mortems (Tier 2)
│   └── archive/                           # Claudeignored — 0 tokens
└── examples/
    └── personal-claude.md                 # Template for ~/.claude/CLAUDE.md
```

| Tier | What | Token cost | When loaded |
|------|------|-----------|-------------|
| **1** | `CLAUDE.md` + `rules/` | ~500 | Every session |
| **2** | Skills, agents, learnings, memory | 0 at startup | On trigger or delegation |
| **3** | Archive, skill references | 0 | Only on explicit request |

## What's included

| Component | What it does |
|-----------|-------------|
| **`CLAUDE.md`** | Project identity, token efficiency rules, permission policy, boundaries |
| **`settings.json`** | Granular permissions (12 git commands, kubectl, docker), PostToolUse lint hook, SessionStart compact hook |
| **`rules/code-quality.md`** | Language-agnostic coding standards (Tier 1, always loaded) |
| **`rules/common-mistakes.md`** | Top recurring Claude pitfalls — max 10 items, graduate resolved ones to learnings/ |
| **`rules/frontend-example.md`** | Path-specific rule example — only loads for matching file patterns |
| **`skills/onboard/`** | Auto-detects stack, asks clarifying questions, configures CLAUDE.md + settings + rules for your project |
| **`skills/k8s-deploy/`** | Kubernetes deploy workflow with `$ARGUMENTS`, dry-run → diff → apply flow |
| **`skills/docker-debug/`** | Container troubleshooting with deterministic status check script |
| **`agents/code-reviewer.md`** | Code review subagent — runs in own context window with persistent memory |
| **`hooks/post-edit-lint.sh`** | Auto-lints TS/JS, Python, Go after every Write/Edit via stdin JSON + jq |
| **`.claudeignore`** | Keeps deps, build artifacts, large assets, and archive out of context |
| **`memory/MEMORY.md`** | Memory index template — actual memory files gitignored |
| **`examples/personal-claude.md`** | Template for `~/.claude/CLAUDE.md` (personal preferences across all projects) |

## Key design decisions

<details>
<summary><b>Why <code>common-mistakes.md</code> AND <code>docs/learnings/</code>?</b></summary>

Common mistakes is Tier 1 (max 10 items, always loaded). When it gets crowded, graduate rare/resolved items to learnings/ with full detail. Learnings is Tier 2 (loaded on demand). This keeps session startup lean.
</details>

<details>
<summary><b>Why <code>scripts/</code> inside skills?</b></summary>

Deterministic tasks (status checks, lint, format) go in scripts so Claude runs them instead of reconstructing the logic each time. Saves tokens + ensures consistency.
</details>

<details>
<summary><b>Why agents instead of more skills?</b></summary>

Agents run in their own context window. Use them for tasks that would pollute your main conversation (code review, research, large refactors).
</details>

<details>
<summary><b>Why hooks instead of CLAUDE.md instructions?</b></summary>

CLAUDE.md is advisory — Claude might forget. Hooks are deterministic — they always run. Use hooks for things that must happen every time without exception.
</details>

<details>
<summary><b>Why is <code>git push</code> not in the allow list?</b></summary>

Pushing affects shared state. Claude should ask for approval every time. If your project needs auto-push, add it to `settings.local.json` (not the shared settings).
</details>

## Customization

See [`examples/personal-claude.md`](examples/personal-claude.md) for a `~/.claude/CLAUDE.md` template that applies your personal preferences across all projects.

## License

[MIT](LICENSE)

---

<p align="center">
  If this saves you tokens, consider giving it a ⭐
</p>
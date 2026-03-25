# .claude

Token-efficient Claude Code project scaffolding.
3-tier context architecture with skills, agents, hooks, and rules — drop into any project.

[![Stars](https://img.shields.io/github/stars/enbiyagoral/.claude?style=flat&color=yellow)](https://github.com/enbiyagoral/.claude/stargazers)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Forks](https://img.shields.io/github/forks/enbiyagoral/.claude?style=flat)](https://github.com/enbiyagoral/.claude/forks)

---

## Quick start

```bash
git clone https://github.com/enbiyagoral/.claude.git /tmp/.claude-template
cp -r /tmp/.claude-template/{CLAUDE.md,.claude,.claudeignore,.gitignore,docs,memory} your-project/
rm -rf /tmp/.claude-template
```

Open Claude Code in your project, then:

```text
/onboard
```

Detects your stack, configures `CLAUDE.md` + `settings.json` + rules + hooks. For DevOps projects, suggests autonomous agents. Re-run when the project evolves.

## How it works

| Tier | What | When loaded |
| --- | --- | --- |
| **1** | `CLAUDE.md` + `rules/` | Every session (~500 tokens) |
| **2** | Skills, agents, learnings, memory | On trigger or delegation |
| **3** | Archive, skill references | Only on explicit request |

## Skills

### Setup

| Trigger | What it does |
| --- | --- |
| `/onboard` | Detect stack → configure everything → suggest agents |

### Scaffold

| Trigger | What it does |
| --- | --- |
| `/new-skill <name>` | Create SKILL.md, optionally add references/ and scripts/ |
| `/new-agent <name>` | 2-turn interview → Type A (subagent) or Type B (autonomous: AGENT.md + HEARTBEAT.md + MEMORY.md + RULES.md) |
| `/new-rule <name>` | Create global or path-scoped rule |
| `/new-hook <name>` | Write hook script + wire into settings.json |

### Manage

| Trigger | What it does |
| --- | --- |
| `/update-rule <name>` | Edit rule, optionally record why in docs/learnings/ |
| `/update-permissions` | Add allow/deny to settings.json |
| `/graduate <item>` | Move common-mistakes item to docs/learnings/ |
| `/retire-agent <name>` | Archive agent (reversible) — moves to agents/archive/ |
| `/retire-skill <name>` | Archive skill (reversible) — moves to skills/archive/ |

### Observe

| Trigger | What it does |
| --- | --- |
| `/list-agents` | List all agents with missions and KPIs |
| `/agent-status <name>` | Last journal entry, KPI progress, recent outputs |
| `/context-check` | Session health — compact/commit recommendation |

## License

[MIT](LICENSE)

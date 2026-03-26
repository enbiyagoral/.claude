# Deep Dive README

This page keeps detailed documentation out of the main README.

## Context Architecture

| Tier | What | When loaded |
| --- | --- | --- |
| **1** | `CLAUDE.md` + `rules/` | Every session (target: lean) |
| **2** | Skills, agents, learnings, memory | On trigger or delegation |
| **3** | Archive, skill references | Only on explicit request |

## Full Skill Matrix

### Setup

| Trigger | What it does |
| --- | --- |
| `/onboard` | Detect stack, configure core files, suggest agents |

### Scaffold

| Trigger | What it does |
| --- | --- |
| `/new-skill <name>` | Create SKILL.md with optional references/scripts |
| `/new-agent <name>` | 2-turn interview for Type A or Type B agent |
| `/new-rule <name>` | Pick right control surface and create rule |
| `/new-hook <name>` | Create hook script and wire settings |

### Manage

| Trigger | What it does |
| --- | --- |
| `/update-rule <name>` | Update rule text and enforcement surfaces |
| `/update-permissions` | Update allow/deny in settings |
| `/graduate <item>` | Move mistake into learnings docs |
| `/retire-agent <name>` | Archive agent (reversible) |
| `/retire-skill <name>` | Archive skill (reversible) |

### Observe

| Trigger | What it does |
| --- | --- |
| `/list-agents` | List agents with mission and KPIs |
| `/agent-status <name>` | Show latest status and outputs |
| `/context-check` | Session health and compact guidance |

## Design Notes

1. Keep Tier 1 compact to reduce token overhead.
2. Prefer hooks for deterministic enforcement.
3. Archive instead of deleting for reversibility.
4. Keep skills generic in the template.

## Useful Links

- [Main README](../README.md)
- [Architecture Overview](architecture/OVERVIEW.md)
- [Contributing](../CONTRIBUTING.md)
- [Examples](../examples/)

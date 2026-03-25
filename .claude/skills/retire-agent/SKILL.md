---
name: retire-agent
description: >
  Archive an agent instead of deleting it — fully reversible. Use when the user says
  "retire agent", "archive agent", "deactivate agent", "disable agent", or "agenti kaldır".
argument-hint: "<agent-name>"
allowed-tools: Read, Glob, Edit, Bash(git mv *), Bash(mkdir *)
disable-model-invocation: true
---

# Retire agent

Target agent: $ARGUMENTS

## Step 1 — Find the agent

If no argument given, Glob `.claude/agents/` and list available agents, then ask which to retire.

Otherwise check:
- `.claude/agents/<name>.md` → Type A
- `.claude/agents/<name>/` → Type B

If neither found, stop and say so.

## Step 2 — Confirm

```text
Retiring: <agent-name> (<Type A / Type B>)

This will move the agent to .claude/agents/archive/<agent-name>.
It will no longer be active, but nothing is deleted — you can restore it with /restore-agent <name>.

Proceed? (yes / no)
```

Wait for confirmation.

## Step 3 — Archive

Ensure `.claude/agents/archive/` exists (create if needed).

**Type A:**
```bash
git mv .claude/agents/<name>.md .claude/agents/archive/<name>.md
```

**Type B:**
```bash
git mv .claude/agents/<name> .claude/agents/archive/<name>
```

If git mv is unavailable (untracked files), use Bash mv instead.

## Step 4 — Check skill references (Type B only)

Before archiving, check if this agent's `AGENT.md` Skills table lists any skills:

1. Read `.claude/agents/<name>/AGENT.md` and scan the Skills table
2. If skills are listed, warn the user:

```text
Warning: <agent-name> has skills listed in its AGENT.md Skills table:
  - <skill-1>
  - <skill-2>

These skills will become orphaned (no parent agent).

Options:
  a) Retire those skills too with /retire-skill (recommended)
  b) Keep the skills and archive the agent anyway
  c) Cancel
```

Wait for answer. If (a), run `/retire-skill` for each listed skill.

## Step 5 — Print summary

```text
Retired: <agent-name>
Archived to: .claude/agents/archive/<name>[.md]

[Skills also retired: <list>]  ← if applicable

To restore: move back to .claude/agents/
```

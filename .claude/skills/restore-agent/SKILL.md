---
name: restore-agent
description: >
  Restore an archived agent back to active use — reverses a retire-agent action. Use when the user says
  "restore agent", "unarchive agent", "reactivate agent", or "agenti geri getir".
argument-hint: "<agent-name>"
allowed-tools: Read, Glob, Edit, Bash(git mv *), Bash(mkdir *)
disable-model-invocation: true
---

# Restore agent

Target agent: $ARGUMENTS

## Step 1 — Find the archived agent

If no argument given, Glob `.claude/agents/archive/` and list available archived agents, then ask which to restore.

Otherwise check:
- `.claude/agents/archive/<name>.md` → Type A
- `.claude/agents/archive/<name>/` → Type B

If neither found, stop and say so.

## Step 2 — Check for name conflicts

Check if the agent already exists as active:
- `.claude/agents/<name>.md` (Type A)
- `.claude/agents/<name>/` (Type B)

If it does, stop and warn:

```text
Conflict: .claude/agents/<name> already exists as an active agent.
Cannot restore — rename or retire the active one first.
```

## Step 3 — Confirm

```text
Restoring: <agent-name> (<Type A / Type B>)

This will move the agent from .claude/agents/archive/ back to .claude/agents/.
It will become active again.

Proceed? (yes / no)
```

Wait for confirmation.

## Step 4 — Restore

**Type A:**
```bash
git mv .claude/agents/archive/<name>.md .claude/agents/<name>.md
```

**Type B:**
```bash
git mv .claude/agents/archive/<name> .claude/agents/<name>
```

If git mv is unavailable (untracked files), use Bash mv instead.

## Step 5 — Restore orphaned skills (Type B only)

If the agent is Type B, read its `AGENT.md` Skills table. For each listed skill:

1. Check if the skill exists in `.claude/skills/archive/<skill-name>/`
2. If found, offer to restore:

```text
Found archived skills that belong to this agent:
  - <skill-1> (in .claude/skills/archive/)
  - <skill-2> (in .claude/skills/archive/)

Options:
  a) Restore those skills too (recommended)
  b) Keep them archived
```

Wait for answer. If (a), run the restore for each skill using `git mv`.

## Step 6 — Print summary

```text
Restored: <agent-name>
Moved from: .claude/agents/archive/<name>[.md]
Active at:  .claude/agents/<name>[.md]

[Skills also restored: <list>]  ← if applicable

The agent is now active and will appear in /list-agents.
```

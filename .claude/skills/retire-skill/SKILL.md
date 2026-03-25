---
name: retire-skill
description: >
  Archive a skill instead of deleting it — fully reversible. Use when the user says
  "retire skill", "archive skill", "deactivate skill", "disable skill", or "skill'i kaldır".
argument-hint: "<skill-name>"
allowed-tools: Read, Glob, Edit, Bash(git mv *), Bash(mkdir *)
disable-model-invocation: true
---

# Retire skill

Target skill: $ARGUMENTS

## Step 1 — Find the skill

If no argument given, Glob `.claude/skills/` and list available skills, then ask which to retire.

Otherwise check for `.claude/skills/<name>/SKILL.md`. If not found, stop and say so.

## Step 2 — Check parent agent references

Before archiving, check if any Type B agent's `AGENT.md` references this skill:

1. Glob `.claude/agents/` for directories
2. For each, read `AGENT.md` and scan the Skills table
3. If referenced, warn the user:

```text
Warning: <skill-name> is listed in <agent-name>'s AGENT.md Skills table.
Retiring it will leave a broken reference.

Options:
  a) Remove from AGENT.md too (recommended)
  b) Keep the reference and archive anyway
  c) Cancel
```

Wait for answer. If (a), edit the parent AGENT.md to remove the row.

## Step 3 — Confirm

```text
Retiring: <skill-name>

This will move the skill to .claude/skills/archive/<skill-name>/.
It will no longer appear in skill lists or be triggered.
Nothing is deleted — move it back to .claude/skills/ to restore.

Proceed? (yes / no)
```

Wait for confirmation.

## Step 4 — Archive

Ensure `.claude/skills/archive/` exists (create if needed).

```bash
git mv .claude/skills/<name> .claude/skills/archive/<name>
```

If git mv is unavailable (untracked files), use Bash mv instead.

## Step 5 — Print summary

```text
Retired: <skill-name>
Archived to: .claude/skills/archive/<skill-name>/

[Removed from: .claude/agents/<agent-name>/AGENT.md Skills table]  ← if applicable

To restore: move back to .claude/skills/
```

---
name: restore-skill
description: >
  Restore an archived skill back to active use — reverses a retire-skill action. Use when the user says
  "restore skill", "unarchive skill", "reactivate skill", or "skill'i geri getir".
argument-hint: "<skill-name>"
allowed-tools: Read, Glob, Edit, Bash(git mv *), Bash(mkdir *)
disable-model-invocation: true
---

# Restore skill

Target skill: $ARGUMENTS

## Step 1 — Find the archived skill

If no argument given, Glob `.claude/skills/archive/` and list available archived skills, then ask which to restore.

Otherwise check for `.claude/skills/archive/<name>/SKILL.md`. If not found, stop and say so.

## Step 2 — Check for name conflicts

Check if `.claude/skills/<name>/` already exists as an active skill.

If it does, stop and warn:

```text
Conflict: .claude/skills/<name>/ already exists as an active skill.
Cannot restore — rename or retire the active one first.
```

## Step 3 — Confirm

```text
Restoring: <skill-name>

This will move the skill from .claude/skills/archive/<name>/ back to .claude/skills/<name>/.
It will become active and appear in skill lists again.

Proceed? (yes / no)
```

Wait for confirmation.

## Step 4 — Restore

```bash
git mv .claude/skills/archive/<name> .claude/skills/<name>
```

If git mv is unavailable (untracked files), use Bash mv instead.

## Step 5 — Check agent references

After restoring, check if any Type B agent previously referenced this skill:

1. Glob `.claude/agents/` for directories
2. For each, read `AGENT.md` and scan the Skills table
3. If no agent references this skill, suggest:

```text
Tip: If this skill was previously part of a Type B agent, you may want to
re-add it to that agent's AGENT.md Skills table manually.
```

## Step 6 — Print summary

```text
Restored: <skill-name>
Moved from: .claude/skills/archive/<name>/
Active at:  .claude/skills/<name>/

The skill is now active and will appear in /list-skills.
```

---
name: update-skill
description: >
  Update an existing skill's SKILL.md content or frontmatter. Use when the user says
  "update skill", "change skill", "skill güncelle", "modify skill", or "update-skill <name>".
argument-hint: "<skill-name>"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# Update skill

Target skill: $ARGUMENTS

## Step 1 — Find the skill

If no argument given, Glob `.claude/skills/` for directories containing `SKILL.md`, then list them and ask which one to update.

Otherwise, look for `.claude/skills/<skill-name>/SKILL.md`. If not found, stop and say so.

## Step 2 — Read and show the current skill

Read the SKILL.md file. Print the current frontmatter and workflow to the user so they can see what they're changing.

## Step 3 — Ask what to change

```text
Current skill: <skill-name>

What would you like to change?
1. Frontmatter (name, description, triggers, allowed-tools)
2. Workflow steps
3. Both

Also: Why is this changing?
```

Wait for answer.

## Step 4 — Apply the change

Edit `.claude/skills/<skill-name>/SKILL.md` with the requested changes.

Preserve conventions:

- Keep `disable-model-invocation: true` unless user explicitly asks to remove it
- Keep `allowed-tools` to minimum required set
- Keep workflow steps numbered and actionable
- Use `$ARGUMENTS` placeholder where the skill accepts input

## Step 5 — Validate consistency

After editing, verify:

- Frontmatter YAML is valid (name, description, allowed-tools all present)
- `argument-hint` is present if skill uses `$ARGUMENTS`
- Workflow steps reference only tools listed in `allowed-tools`

If anything is inconsistent, fix it and inform the user.

## Step 6 — Print summary

```text
Updated: .claude/skills/<skill-name>/SKILL.md
Changed: <frontmatter / workflow / both>
Reason:  <user's reason>
```

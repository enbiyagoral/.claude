---
name: new-skill
description: >
  Create a new Claude Code skill following project conventions. Use when the user
  says "new skill", "add skill", "create skill", or "yeni skill ekle".
argument-hint: "<skill-name> [description of what it does]"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# New skill scaffold

Target skill name: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, extract:
- **skill-name**: lowercase, hyphen-separated (e.g., `tf-plan-review`)
- **purpose**: what the skill does in one sentence (if not given, ask)

If skill-name is missing, stop and ask.

## Step 2 — Check for conflicts

- Run Glob on `.claude/skills/` to list existing skills
- If a skill with the same name already exists, stop and tell the user

## Step 3 — Determine skill structure

Ask (or infer from purpose):
1. Does this skill need **reference files**? (environment-specific config, runbooks, templates) → if yes, create `references/` subfolder
2. Does this skill need a **deterministic script**? (status check, lint, formatter — not logic Claude should reason through) → if yes, create `scripts/` subfolder

## Step 4 — Create files

### 4a. Create `.claude/skills/<skill-name>/SKILL.md`

Use this template — fill in every field, no placeholders left blank:

```markdown
---
name: <skill-name>
description: >
  <One sentence. Include trigger phrases the user would naturally say.>
argument-hint: "<what arguments this skill accepts, if any>"
allowed-tools: <comma-separated list — only tools this skill actually needs>
disable-model-invocation: true
---

# <Skill title>

## Purpose

<One paragraph. What does this skill do and why does it exist?>

## When to use

- <Trigger scenario 1>
- <Trigger scenario 2>

## Inputs

- <Input 1: what it is, where it comes from>
- <Input 2>

## Process

1. <Step 1 — clear action>
2. <Step 2>
3. <Step 3>
4. <Step 4 — what to produce and where>

## Output

<What the skill produces. Format, location, naming convention.>

## Quality bar

<Minimum standard for acceptable output. What does "done" look like?>
```

### 4b. If references needed — create `.claude/skills/<skill-name>/references/README.md`

```markdown
# <skill-name> references

Add environment-specific reference files here. These are Tier 3 — loaded only on explicit request.

Example files to add:
- `staging.md` — staging environment details
- `production.md` — production environment details
- `runbook.md` — step-by-step runbook
```

### 4c. If script needed — create `.claude/skills/<skill-name>/scripts/<script-name>.sh`

Scripts must be:
- Deterministic status checks or formatters only
- NOT reconstruction of logic Claude should reason through
- Executable (`chmod +x` reminder to user)

## Step 5 — Print summary

```
Created:
  .claude/skills/<skill-name>/SKILL.md
  [.claude/skills/<skill-name>/references/README.md]  ← if applicable
  [.claude/skills/<skill-name>/scripts/<name>.sh]     ← if applicable

Trigger phrases: "<what you said in description>"

Next: Fill in the Process steps with your actual workflow.
If you need environment-specific config, add files to references/.
```

Do NOT auto-add the skill anywhere else — skill discovery is file-based, no registry needed.

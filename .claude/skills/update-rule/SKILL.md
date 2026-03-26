---
name: update-rule
description: >
  Update an existing Claude Code rule and keep enforcement surfaces consistent.
  Use when the user says "update rule", "change rule", "rule güncelle", or
  "update-rule <name>". This workflow can update rule text, settings.json,
  and hooks together when needed.
argument-hint: "<rule-name>"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# Update rule / control

Target rule: $ARGUMENTS

## Step 1 — Find and read current state

- If no argument is given, glob `.claude/rules/*.md`, list available rules, and ask which one to update.
- Read the selected rule.
- Read `.claude/rules/README.md`, `.claude/settings.json`, and `.claude/hooks/scripts/pre-bash-guard.sh`.

If the file is missing, stop and say so.

## Step 2 — Show current rule and ask for change

Print the current rule content, then ask:

```text
What should change in this control?

1. Rule text/scope only
2. Enforcement only (settings.json and/or hook)
3. Both rule text and enforcement

Also: why is this changing?
```

If the user asks for command restrictions or runtime guards, classify as enforcement work automatically.

## Step 3 — Apply requested change

### 3A) Rule text/scope updates

Edit `.claude/rules/<rule-name>.md`:

- Keep directives concise.
- Keep under 10 lines.
- Keep or update `paths` frontmatter only when needed.
- Keep a single `Why` comment.

### 3B) Permissions updates (if needed)

Edit `.claude/settings.json`:

- Add/remove entries in `permissions.allow` and/or `permissions.deny`.
- Avoid duplicates.
- If a pattern exists in the opposite list, ask before removing.

### 3C) Hook updates (if needed)

Edit `.claude/hooks/scripts/pre-bash-guard.sh` when advanced patterns are required.

- Keep only patterns not representable in permissions.
- Avoid duplicating settings deny entries.
- Keep guard list short.

## Step 3.5 — Cross-rule overlap check (mandatory when rule text changes)

When rule content or scope changes, quickly scan other files in `.claude/rules/*.md` (exclude `README.md` and the target rule):

- Check for duplicated directives.
- Check for contradictory directives.
- Check for overlapping path scopes that would make one rule redundant.

If overlap exists, prefer consolidation:

- Merge into the stronger existing rule, or
- Keep both only if scopes are clearly distinct and documented in each `Why` comment.

## Step 4 — Consistency and dedup checks (mandatory)

Before finishing, enforce all:

1. No exact command restriction duplicated between rule text and settings/hook.
2. No duplicate patterns inside allow/deny or hook case blocks.
3. If hybrid control is used, rule text references the enforcement source of truth (`settings.json` and/or guard hook) without restating exact patterns.
4. No unresolved overlap/contradiction with other rule files.

If the updated rule became pure command enforcement with no behavioral value, ask whether to:

- keep a short reference rule, or
- retire the rule and keep enforcement only in settings/hook.

## Step 5 — Decide whether to record learning

Ask:

```text
Should I record why this control changed in docs/learnings/?
```

If yes, create `docs/learnings/YYYY-MM-DD-<rule-name>-update.md` with:

- what changed
- why
- before (rule text)
- after (rule text)
- enforcement changes in settings/hook

## Step 6 — Print summary

```text
Updated controls:
- Rule: .claude/rules/<rule-name>.md (or "unchanged")
- Permissions: <changed keys or "unchanged">
- Hook: <changed script or "unchanged">

Consistency checks:
- Rule/enforcement duplication: cleared
- Source of truth references: verified
[Recorded: docs/learnings/YYYY-MM-DD-<rule-name>-update.md]
```

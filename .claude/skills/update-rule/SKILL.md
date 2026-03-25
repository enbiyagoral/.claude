---
name: update-rule
description: >
  Update an existing Claude Code rule and optionally graduate it to docs/learnings/.
  Use when the user says "update rule", "change rule", "rule güncelle", or
  "update-rule <name>".
argument-hint: "<rule-name>"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# Update rule

Target rule: $ARGUMENTS

## Step 1 — Find the rule

If no argument given, Glob `.claude/rules/` and list available rules, then ask which one to update.

Otherwise, look for `.claude/rules/<rule-name>.md`. If not found, stop and say so.

## Step 2 — Read and show the current rule

Read the file. Print the current content to the user so they can see what they're changing.

## Step 3 — Ask what to change

```text
Current rule: <rule-name>

What would you like to change?
1. The rule content itself
2. The scope (add/change path restrictions)
3. Both

Also: Why is this changing?
(Knowing the reason helps decide whether this belongs in docs/learnings/ as a permanent record.)
```

Wait for answer.

## Step 4 — Apply the change

Edit `.claude/rules/<rule-name>.md` with the requested changes.

Keep the same formatting conventions:
- Under 10 lines
- Directives only ("Always X", "Never Y")
- Motivation in a `<!-- Why: ... -->` comment at the bottom

If the scope is changing to path-specific, add frontmatter:

```markdown
---
paths:
  - "<glob pattern>"
---
```

If removing path restriction, remove the frontmatter block.

## Step 5 — Decide whether to graduate to docs/learnings/

After applying the change, ask:

```text
Should I record why this rule was changed in docs/learnings/?

Graduate if:
- The old rule caused a real incident or recurring problem
- The reasoning behind the change is non-obvious
- Future team members would benefit from knowing the history

Skip if:
- It's a minor wording fix
- The reason is obvious from the rule itself
```

If yes → create `docs/learnings/YYYY-MM-DD-<rule-name>-update.md`:

```markdown
# Rule update: <rule-name>

**Date**: <today's date>

## What changed

<brief diff in plain language — not the raw diff>

## Why

<the reason the user gave>

## Before

<old rule content>

## After

<new rule content>
```

## Step 6 — Token check

After editing, check if `rules/` is growing large. If the combined rules are approaching verbose, suggest archiving the least-used rule.

## Step 7 — Print summary

```text
Updated: .claude/rules/<rule-name>.md
Scope: <global / path-specific>
[Recorded: docs/learnings/YYYY-MM-DD-<rule-name>-update.md]
```

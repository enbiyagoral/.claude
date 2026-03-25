---
name: graduate
description: >
  Graduate a common-mistakes.md item to docs/learnings/ as a permanent record.
  Use when the user says "graduate", "graduate mistake", "common-mistakes doldu",
  or the list reaches 10 items.
argument-hint: "<item-number or keyword>"
allowed-tools: Read, Edit, Write, Glob
disable-model-invocation: true
---

# Graduate a common mistake

Target item: $ARGUMENTS

## Step 1 — Read common-mistakes.md

Read `.claude/rules/common-mistakes.md`. Show the current list.

## Step 2 — Identify the item to graduate

From `$ARGUMENTS`:

- If a number → graduate that numbered item
- If a keyword → find the item that matches, confirm with user
- If no argument → list all items and ask which to graduate

If the list has fewer than 8 items, ask: "The list isn't full yet — are you sure you want to graduate this now, or is it no longer relevant?"

## Step 3 — Check docs/learnings/ template

Read `docs/learnings/README.md` if it exists to understand the expected format.

## Step 4 — Ask for context before writing

```text
Before I graduate "<item>", a few things:

1. Why is this being graduated?
   a) It's fully resolved — we fixed the root cause
   b) It happened enough times that it needs a proper write-up
   c) It's no longer relevant to this project

2. Is there a specific incident or PR where this came up?
   (optional — helps future readers understand the severity)

3. Any additional detail beyond what's in the mistake entry?
```

Wait for answers.

## Step 5 — Write docs/learnings/YYYY-MM-DD-<slug>.md

Use today's date. Slug = kebab-case version of the mistake title.

```markdown
# <Mistake title>

**Graduated**: <today's date>
**Source**: common-mistakes.md

## The mistake

<Original text from common-mistakes.md>

## Why it matters

<User's answer from Step 4 — what went wrong, what was the impact>

## Root cause

<What causes this mistake to happen — be specific>

## How to avoid it

<Concrete steps or pattern to prevent recurrence>

## Reference

<Incident, PR, or session where this was observed — if provided>
```

## Step 6 — Remove from common-mistakes.md

Edit `.claude/rules/common-mistakes.md`:

- Remove the graduated item
- Renumber the remaining items (1, 2, 3...)
- Do not leave a gap or placeholder

## Step 7 — Print summary

```text
Graduated: "<mistake title>"
Written to: docs/learnings/YYYY-MM-DD-<slug>.md
Removed from: .claude/rules/common-mistakes.md
Remaining items: <N>/10

The learning is now in Tier 2 (docs/learnings/) — loaded when relevant,
not every session. This frees up a slot in common-mistakes.md.
```

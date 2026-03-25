---
name: new-rule
description: >
  Add a new Claude Code rule following project conventions. Use when the user
  says "new rule", "add rule", "create rule", "yeni rule ekle", or wants to
  enforce a consistent behavior across sessions.
argument-hint: "<rule-name> [description]"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# New rule scaffold

Target rule name: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, extract:

- **rule-name**: lowercase, hyphen-separated (e.g., `no-direct-db-writes`)
- **purpose**: what behavior this rule enforces (if not given, ask)

If rule-name is missing, stop and ask.

## Step 2 — Check for conflicts

Glob `.claude/rules/` — list existing rule files.

If a rule with the same name exists, stop and say so. If the purpose overlaps with an existing rule, point it out and ask: "Should I update the existing rule instead?"

## Step 3 — Gather information (ask all at once)

```text
A few things before I write the rule:

1. **Scope**: Should this apply everywhere, or only to specific file paths?
   - Global → loads every session
   - Path-specific → only loads when Claude touches matching files
   If path-specific, which paths? (e.g., "api/**", "*.tf", "src/db/**")

2. **The rule itself**: What should Claude always do, never do, or be aware of?
   Write it as you'd say it out loud — I'll format it properly.

3. **Why**: What's the motivation? A past incident, a team convention, a risk you want to avoid?
   This goes into the rule as context so future-you understands why it exists.

4. **Token sensitivity**: Is this rule critical enough to load every session,
   or is it reference material that can live in references/?
   (Critical = always loaded. Reference = loaded on explicit request.)
```

Wait for answers before proceeding.

## Step 4 — Write the rule file

### Global rule → `.claude/rules/<rule-name>.md`

```markdown
<!-- <rule-name>.md -->
<!-- Scope: global — loads every session -->

# <Rule title>

<The rule, written as clear directives. Use bullet points for multiple items.>

<!-- Why: <motivation — incident, convention, or risk> -->
```

### Path-specific rule → `.claude/rules/<rule-name>.md` with frontmatter

```markdown
---
paths:
  - "<glob pattern>"
  - "<glob pattern>"
---

# <Rule title>

<The rule content.>

<!-- Why: <motivation> -->
```

**Formatting rules:**

- Keep it under 10 lines — rules load every session, token cost matters
- Use directives ("Always X", "Never Y", "Prefer X over Y") not explanations
- If the rule needs more context, put the explanation in a `Why:` comment at the bottom, not in the rule itself
- Do NOT add rules that duplicate what's already in `code-quality.md` or `common-mistakes.md`

## Step 5 — Token check

After writing, count the approximate lines added across all `rules/` files.

If the combined `CLAUDE.md` + `rules/` content is approaching 500 tokens (rough guide: ~400 lines total), warn:
"The rules/ directory is getting large. Consider archiving the least-used rule to `docs/archive/` before adding new ones."

## Step 6 — Print summary

```text
Created: .claude/rules/<rule-name>.md
Scope: <global / path-specific: "pattern">
Loads: <every session / only when touching matching files>

If this rule addresses a recurring mistake, also add it to:
  .claude/rules/common-mistakes.md  (if under 10 items)
```

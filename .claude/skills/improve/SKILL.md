---
name: improve
description: >
  Analyze accumulated feedback memories and turn recurring patterns into
  permanent rules or common-mistakes entries. Use when the user says "improve",
  "iyileştir", "apply feedback", "kurallaştır", or "turn feedback into rules".
argument-hint: "[area-keyword]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(rm *)
disable-model-invocation: true
---

# Improve

Target area: $ARGUMENTS

## Step 1 — Collect feedback memories

Glob `memory/*.md`. For each file, read the YAML frontmatter. Keep only files where `type: feedback`.

If no feedback memories exist, stop:

```text
No feedback memories found in memory/.
Feedback memories are created automatically when you correct Claude during a session.
Nothing to improve yet — keep working and check back later.
```

## Step 2 — Group by area

Read the content of each feedback memory. Extract the area/topic from:

- The `description` field in frontmatter
- Keywords in the content (testing, imports, lint, naming, formatting, security, etc.)

Group feedback files by area. Count entries per area.

## Step 3 — Filter by argument

If `$ARGUMENTS` is not empty, filter to only the matching area. If no match, list available areas and ask which one.

If `$ARGUMENTS` is empty, continue with all areas.

## Step 4 — Analyze and recommend

For each area, apply thresholds:

| Count | Recommendation                                    |
| ----- | ------------------------------------------------- |
| 1-2   | Skip — not a pattern yet, memory is sufficient    |
| 3-4   | Suggest adding to `common-mistakes.md`            |
| 5+    | Suggest creating a permanent rule via `/new-rule` |

Print a summary:

```text
=== Feedback Analysis ===

<area>: <N> feedback entries → <recommendation>
<area>: <N> feedback entries → <recommendation>
<area>: <N> feedback entries → Skip (not a pattern yet)

Which area do you want to act on? (or "all" for batch processing)
```

If only one area qualifies (3+), print the recommendation and proceed directly to Step 5 without asking.

## Step 5 — Pre-flight checks

Before acting, verify constraints:

1. Read `.claude/rules/common-mistakes.md` — count current items
   - If at 10 items and action is "add to common-mistakes" → suggest `/graduate` first
   - If at 8-9 items → warn that capacity is almost full

2. Glob `.claude/rules/*.md` — estimate total token budget
   - If approaching ~500 tokens → warn before creating a new rule

3. Check if a rule already exists for this area
   - Glob `.claude/rules/` for files matching the area keyword
   - If found → suggest updating the existing rule instead of creating a new one

## Step 6 — Execute action

### For common-mistakes (3-4 feedback entries):

1. Synthesize the feedback entries into a single, concise mistake description
2. Show the proposed entry to the user:

   ```text
   Proposed common-mistakes entry:

   N. **<Title>** — <What goes wrong and the correct approach>

   Source: <N> feedback memories (<list file names>)

   Add this to common-mistakes.md?
   ```

3. Wait for user approval. If rejected, stop — leave memories unchanged.
4. Edit `.claude/rules/common-mistakes.md` — append the new numbered item
5. Proceed to Step 7 (cleanup)

### For rules (5+ feedback entries):

1. Synthesize feedback entries into a rule description
2. Show the proposed rule to the user:

   ```text
   Proposed rule from <N> feedback entries:

   Name: <area>-conventions
   Scope: <global or path-specific based on feedback context>
   Content:
     - <directive 1>
     - <directive 2>
     - ...

   Create this rule? (I'll use /new-rule to scaffold it properly)
   ```

3. Wait for user approval. If rejected, stop — leave memories unchanged.
4. Provide the rule details so the user can invoke `/new-rule <name>` with context,
   or directly write the rule file following the same format as `/new-rule` Step 4

## Step 7 — Clean up resolved feedback

After successfully creating a rule or common-mistake entry:

1. List the feedback memory files that were consumed
2. Ask the user:

   ```text
   These feedback memories are now captured as a <rule/common-mistake>:
     - memory/<file1>.md
     - memory/<file2>.md
     - ...

   Delete them? (They're redundant now — the rule enforces the behavior every session)
   ```

3. If yes → delete the files and remove their entries from `memory/MEMORY.md`
4. If no → leave them (user may want to keep for reference)

## Step 8 — Print summary

```text
=== Done ===

Action: <Added to common-mistakes.md / Created rule <name>.md>
Source: <N> feedback memories from <area>
Cleaned up: <N files deleted / no files deleted>

Remaining feedback areas with patterns:
  <area>: <N> entries (run /improve <area> to process)
```

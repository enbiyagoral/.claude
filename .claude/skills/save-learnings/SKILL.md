---
name: save-learnings
description: >
  Save session learnings, patterns, and corrections to persistent memory.
  Use when the user says "save learnings", "save memory", "remember this session",
  or at the end of a productive session.
argument-hint: "[optional: specific topic to save]"
allowed-tools: Read, Write, Edit, Glob
disable-model-invocation: true
---

# Save Session Learnings

## Purpose

Review the current session and persist any valuable learnings, corrections, patterns, or project knowledge to the memory system. This ensures future sessions benefit from today's discoveries.

## When to use

- End of a productive session with new discoveries
- After receiving user corrections or feedback
- After debugging a tricky issue
- When Stop hook reminds you to save learnings
- When user explicitly asks to save

## Process

1. **Read current memory state**
   - Read `MEMORY.md` index to see what already exists
   - Glob memory files to understand current coverage

2. **Identify what's new this session**
   - User corrections/feedback → `feedback` type memory
   - Project patterns discovered → `project` type memory
   - External resources/tools found → `reference` type memory
   - User preferences/role info → `user` type memory

3. **Check for updates vs new files**
   - If an existing memory covers the same topic, update it
   - Only create a new file if the topic is genuinely new
   - Keep memory file names descriptive: `feedback_testing.md`, `project_api_patterns.md`

4. **Write memory files**
   - Use frontmatter format: `name`, `description`, `type`
   - Keep content concise and actionable
   - Focus on "what" + "how to apply" — not verbose narratives

5. **Update MEMORY.md index**
   - Add one-line pointer for each new file
   - Keep entries under 150 chars
   - Keep total index under 200 lines

## Output

List of memory files created or updated, with a one-line summary of each.

## Quality bar

- Every saved memory has a clear "how to apply" — not just a fact dump
- No duplicate memories — always check existing files first
- MEMORY.md index stays clean and scannable
- Memory descriptions are specific enough to judge relevance in future sessions

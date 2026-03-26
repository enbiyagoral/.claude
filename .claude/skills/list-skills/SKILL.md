---
name: list-skills
description: >
  List all skills and their descriptions. Use when the user says "list skills",
  "show skills", "what skills do we have", "skill listesi", or "mevcut skill'ler".
allowed-tools: Read, Glob
disable-model-invocation: true
---

# List skills

## Process

1. Glob `.claude/skills/` for directories containing `SKILL.md` files.
   - Exclude `archive/` subdirectory from active list.

2. For each **active skill** (`.claude/skills/<name>/SKILL.md`):
   - Read the file, extract: `name`, `description` (first sentence only)
   - Output as a single line entry

3. Glob `.claude/skills/archive/` for directories containing `SKILL.md` files (if archive dir exists).

4. For each **archived skill** (`.claude/skills/archive/<name>/SKILL.md`):
   - Read the file, extract: `name`, `description` (first sentence only)
   - Output as a single line entry

5. If no active skills found → print: "No skills found. Use `/new-skill` to create one."

## Output format

```text
=== Active Skills ===

• <name>: <description first sentence>
• <name>: <description first sentence>

=== Archived Skills ===

• <name>: <description first sentence>
• <name>: <description first sentence>
```

If no archived skills: omit the "Archived Skills" section entirely.

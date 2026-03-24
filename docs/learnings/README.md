# Learnings

Detailed post-mortems from real debugging sessions. Claude reads these
files on demand when working in a related area.

## How this works with common-mistakes.md

```
Bug happens
    │
    ▼
Is Claude repeating this? ──yes──▶ Add short rule to
    │                               .claude/rules/common-mistakes.md
    no                              (Tier 1, loads every session)
    │
    ▼
Did it take >1hr to find? ──yes──▶ Add detailed file here
    │                               docs/learnings/YYYY-MM-DD-desc.md
    no                              (Tier 2, loaded on demand)
    │
    ▼
Skip — not worth documenting


When common-mistakes.md exceeds 10 items:
    → Graduate rare/resolved ones here with full detail
    → Keep only active, frequent ones in common-mistakes.md
```

## Naming convention

```
YYYY-MM-DD-short-description.md
```

Example: `2026-03-24-helm-values-override-order.md`

## Template for each learning

```markdown
# [What went wrong — one line]

## Context
[What were you trying to do?]

## Root cause
[Why did it fail?]

## Fix
[What resolved it?]

## Prevention
[How to avoid this in the future — rule, check, or test]
```

## Referencing from CLAUDE.md

Add to your CLAUDE.md if a specific learning is broadly relevant:

```markdown
## Additional context
- Helm override pitfall: @docs/learnings/2026-03-24-helm-values-override-order.md
```

Claude will only load it when it encounters related work.

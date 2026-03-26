---
name: list-hooks
description: >
  List all configured hooks from settings.json with their events, matchers, and scripts.
  Use when the user says "list hooks", "show hooks", "what hooks are active",
  "hook listesi", or "mevcut hook'lar".
allowed-tools: Read, Glob
disable-model-invocation: true
---

# List hooks

## Process

1. Read `.claude/settings.json` and parse the `hooks` object.

2. For each hook event (PreToolUse, PostToolUse, Stop, SessionStart, etc.):
   - List the matcher pattern
   - List each hook command (extract script name from the command string)
   - Note the hook type

3. If `.claude/settings.local.json` exists, read it too and list any additional local-only hooks separately.

4. Glob `.claude/hooks/scripts/` to find any orphaned scripts not referenced in settings.json.

5. If no hooks configured → print: "No hooks configured. Use `/new-hook` to create one."

## Output format

```text
=== Active Hooks ===

Event: <event-name>
  Matcher: <pattern>
    - <script-name.sh> (<type>)
    - <script-name.sh> (<type>)

Event: <event-name>
  Matcher: <pattern>
    - <script-name.sh> (<type>)

=== Local-Only Hooks (settings.local.json) ===

Event: <event-name>
  ...

=== Orphaned Scripts (not in settings.json) ===

  - <script-name.sh>
```

If no local hooks: omit "Local-Only Hooks" section.
If no orphaned scripts: omit "Orphaned Scripts" section.

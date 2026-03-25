---
name: new-hook
description: >
  Add a new Claude Code hook — shell script wired into settings.json.
  Use when the user says "new hook", "add hook", "yeni hook ekle", or wants
  to automate something that runs on every tool use, session start, or stop.
argument-hint: "<hook-name> [description of what it should do]"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# New hook scaffold

Target hook name: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, extract:

- **hook-name**: lowercase, hyphen-separated (e.g., `pre-edit-backup`)
- **purpose**: what the hook should do (if not given, ask)

If hook-name is missing, stop and ask.

## Step 2 — Read current hooks

Read `.claude/settings.json` to understand what hooks already exist.
Glob `.claude/hooks/scripts/` to see existing scripts.

If a hook with the same name or same purpose already exists, stop and say so.

## Step 3 — Gather information (ask all at once)

```text
Before I write the hook, a few things:

1. **Event**: When should this hook fire?
   - PreToolUse   → before a tool runs (can block/modify)
   - PostToolUse  → after a tool runs (observe, lint, log)
   - Stop         → when Claude finishes a response
   - SessionStart → when a new session begins

2. **Matcher** (for PreToolUse/PostToolUse): Which tool(s) should trigger it?
   Examples: "Write|Edit", "Bash", "Read", "*" (all tools)
   Leave blank if this is a SessionStart or Stop hook.

3. **What it does**: Describe the behavior in plain language.
   I'll write the script — just tell me what it needs to do.

4. **Inputs needed**: Does the script need to know which file was edited?
   Which command was run? The tool output?
   (Claude Code passes the full tool context as JSON via stdin — I'll handle the parsing.)

5. **On failure**: Should a failure block Claude (exit 1) or just warn (exit 0)?
   Block = hard stop, use for critical checks.
   Warn = log and continue, use for informational hooks.
```

Wait for answers before proceeding.

## Step 4 — Write the script

Create `.claude/hooks/scripts/<hook-name>.sh`:

```bash
#!/bin/bash
# <hook-name>.sh — <one-line description>
# Event: <PreToolUse|PostToolUse|Stop|SessionStart>
# Matcher: <matcher or "n/a">
#
# Claude Code passes hook input as JSON via stdin.
# Parse with jq — never use positional args ($1, $2).

INPUT=$(cat)

# Extract relevant fields based on event type:
# PreToolUse/PostToolUse:
#   tool_name:        which tool fired (e.g., "Edit", "Bash")
#   tool_input:       the tool's input parameters
#   tool_input.file_path: for Write/Edit hooks
#   tool_input.command:   for Bash hooks
#   tool_response:    the tool's output (PostToolUse only)
#
# Stop:
#   stop_reason: why Claude stopped

# <script logic here>

exit 0
```

**Script rules:**

- Always read from stdin: `INPUT=$(cat)`
- Always parse with `jq`, never use `$1` or positional args
- Keep scripts deterministic: same input → same output, no side effects beyond intended action
- Scripts are for status checks, formatters, and loggers — not for logic Claude should reason through
- Add a comment explaining what each `jq` extraction does
- Exit 0 unless the hook is intentionally blocking (PreToolUse guard)

## Step 5 — Wire into settings.json

Read `.claude/settings.json`. Add the hook under the correct event key.

**For PreToolUse / PostToolUse:**

```json
{
  "matcher": "<matcher>",
  "hooks": [
    {
      "type": "command",
      "command": "bash .claude/hooks/scripts/<hook-name>.sh"
    }
  ]
}
```

**For Stop / SessionStart:**

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "bash .claude/hooks/scripts/<hook-name>.sh"
    }
  ]
}
```

Append to the existing array for that event — do not overwrite existing hooks.

If the event key doesn't exist yet in settings.json, add it at the same level as existing event keys.

## Step 6 — Print summary

```text
Created: .claude/hooks/scripts/<hook-name>.sh
Wired:   .claude/settings.json → <Event> → matcher: "<matcher>"
Behavior: <what it does>
On failure: <blocks / warns>

Run a quick test:
  echo '{"tool_name":"Edit","tool_input":{"file_path":"test.md"}}' | bash .claude/hooks/scripts/<hook-name>.sh
```

Remind the user: hooks are guarantees (run every time), unlike CLAUDE.md instructions which are advisory. Keep them fast — slow hooks block every tool call.

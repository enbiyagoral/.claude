---
name: retire-agent
description: >
  Archive an agent instead of deleting it — fully reversible. Use when the user says
  "retire agent", "archive agent", "deactivate agent", "disable agent", or "agenti kaldır".
argument-hint: "<agent-name>"
allowed-tools: Read, Glob, Edit, Bash(git mv *), Bash(mkdir *)
disable-model-invocation: true
---

# Retire agent

Target agent: $ARGUMENTS

## Step 1 — Find the agent

If no argument given, Glob `.claude/agents/` and list available agents, then ask which to retire.

Otherwise check:
- `.claude/agents/<name>.md` → Type A
- `.claude/agents/<name>/` → Type B

If neither found, stop and say so.

## Step 2 — Confirm

```text
Retiring: <agent-name> (<Type A / Type B>)

This will move the agent to .claude/agents/archive/<agent-name>.
It will no longer be active, but nothing is deleted — you can restore it with /restore-agent <name>.

Proceed? (yes / no)
```

Wait for confirmation.

## Step 3 — Archive

Ensure `.claude/agents/archive/` exists (create if needed).

**Type A:**
```bash
git mv .claude/agents/<name>.md .claude/agents/archive/<name>.md
```

**Type B:**
```bash
git mv .claude/agents/<name> .claude/agents/archive/<name>
```

If git mv is unavailable (untracked files), use Bash mv instead.

## Step 4 — Update dependent skills (Type B only)

For Type B agents that had skills listed in `AGENT.md`:
- Glob `.claude/skills/` for skills that reference this agent
- If found, add a comment at the top of each SKILL.md:
  ```
  <!-- Agent retired: <agent-name> — this skill is inactive. Restore with /restore-agent -->
  ```

## Step 5 — Print summary

```text
Retired: <agent-name>
Archived to: .claude/agents/archive/<name>[.md]

To restore: move back to .claude/agents/ (or use /restore-agent <name> if that skill exists)
Dependent skills flagged: <list, or "none">
```

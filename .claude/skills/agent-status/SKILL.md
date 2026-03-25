---
name: agent-status
description: >
  Show the current status of a specific autonomous agent — last journal entry,
  KPI progress, and recent outputs. Use when the user says "agent status",
  "how is <agent> doing", "<agent> durumu", or "agent-status <name>".
argument-hint: "<agent-name>"
allowed-tools: Read, Glob
disable-model-invocation: true
---

# Agent status

Target agent: $ARGUMENTS

## Step 1 — Validate

- If no argument given → stop and ask: "Which agent? Run `/list-agents` to see available agents."
- Glob `.claude/agents/<agent-name>/` — if directory doesn't exist, stop and say agent not found.
- This skill only works for **Type B** autonomous agents (folder structure). Type A subagents have no journal or outputs.

## Step 2 — Read agent state

Read the following files in order:

1. `.claude/agents/<agent-name>/AGENT.md` — extract: Mission, Goals & KPIs table
2. `.claude/agents/<agent-name>/MEMORY.md` — extract: "What Works" and "Last Updated" sections
3. `.claude/agents/<agent-name>/outputs/` — Glob for all files, sort by name (date-prefixed), take the 3 most recent
4. `journal/` — Glob for all files, sort by name, take the most recent entry that mentions this agent name

## Step 3 — Summarize

Output:

```text
=== <agent-name> status ===

Mission: <mission>

KPI Progress:
  • <Goal> | KPI: <metric> | Baseline: <X> | Target: <Y> | Current: <Z or "unknown — no data yet">

Last activity:
  • Journal: <date> — <one-line summary of what happened>
  • Last output: <filename> (<date>)

Memory (what's working):
  <What Works section content, or "No patterns recorded yet">

Last updated: <date from MEMORY.md>
```

If `journal/` is empty or has no entries mentioning this agent → print: "No journal entries found. Has the first cycle run yet?"

If `outputs/` is empty → print: "No outputs generated yet."

## Notes

- Do NOT read all journal files — only the most recent one that mentions the agent name
- Current KPI value comes from the most recent output file or journal entry — if not found, show "unknown"

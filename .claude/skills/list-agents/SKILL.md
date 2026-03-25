---
name: list-agents
description: >
  List all agents and their KPIs. Use when the user says "list agents",
  "show agents", "what agents do we have", "agent listesi", or "mevcut agentlar".
allowed-tools: Read, Glob
disable-model-invocation: true
---

# List agents

## Process

1. Glob `.claude/agents/` for:
   - `*.md` files → Type A subagents
   - subdirectories → Type B autonomous agents

2. For each **Type A** agent (`.claude/agents/<name>.md`):
   - Read the file, extract: `name`, `description` (first sentence only)
   - Output as a single line entry

3. For each **Type B** agent (`.claude/agents/<name>/AGENT.md`):
   - Read `AGENT.md`, extract:
     - Mission (one sentence)
     - Goals & KPIs table (all rows)
     - Skills list
   - Read `HEARTBEAT.md`, extract: Schedule line only

4. If no agents found in either location → print: "No agents found. Use `/new-agent` to create one."

## Output format

```text
=== Type A — Claude Code Subagents ===

• <name>: <description first sentence>
• <name>: <description first sentence>

=== Type B — Autonomous Agents ===

┌─ <agent-name>
│  Mission:   <mission>
│  Schedule:  <heartbeat schedule>
│  Goals:
│    • <Goal> | KPI: <metric> | <baseline> → <target>
│    • <Goal> | KPI: <metric> | <baseline> → <target>
│  Skills:    <skill1>, <skill2>
└─

┌─ <agent-name>
│  ...
└─
```

If no Type A agents: omit that section.
If no Type B agents: omit that section.

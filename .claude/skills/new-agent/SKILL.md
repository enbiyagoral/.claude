---
name: new-agent
description: >
  Create a new Claude Code subagent following project conventions. Use when the user
  says "new agent", "add agent", "create agent", "yeni agent ekle", or needs a
  background task that would pollute the main conversation context.
argument-hint: "<agent-name> [description of what it does]"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# New agent scaffold

Target agent name: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, extract:
- **agent-name**: lowercase, hyphen-separated (e.g., `tf-drift-detector`)
- **purpose**: what the agent does (if not given, ask one question: "What should this agent do?")

If agent-name is missing, stop and ask.

## Step 2 — Determine agent type

Ask the user (or infer from purpose):

**Type A — Claude Code subagent** (`.claude/agents/<name>.md`)
Use when: background task, context isolation, specialized tool access, reusable across sessions.
Example: code-reviewer, security-scanner, doc-generator

**Type B — Autonomous agent** (full folder structure)
Use when: scheduled/heartbeat operation, multi-skill coordination, has its own memory/KPIs, runs independently.
Example: pipeline-monitor, cost-tracker, drift-detector

If unclear, default to **Type A** (simpler, more common in Claude Code).

## Step 3 — Check for conflicts

Glob `.claude/agents/` — if an agent with the same name exists, stop and tell the user.

## Step 4a — Create Type A agent (Claude Code subagent)

Create `.claude/agents/<agent-name>.md`:

```markdown
---
name: <agent-name>
description: >
  <One sentence. Include trigger phrases. Be specific about WHEN to use this agent
  vs. when NOT to use it — helps Claude decide correctly.>
tools: <comma-separated — only tools this agent actually needs>
model: sonnet
---

# <Agent title>

You are a <role>. <One sentence on expertise and approach.>

## Mission

<What does this agent optimize for? One sentence, specific and measurable if possible.>

## When to use

- <Scenario 1>
- <Scenario 2>

## When NOT to use

- <Anti-scenario 1 — common confusion case>
- <Anti-scenario 2>

## Process

<Numbered steps the agent follows. Each step is a clear action.>

1.
2.
3.

## Output format

<What the agent produces. Structure, format, where it goes.>

## Boundaries

- NEVER <hard boundary 1>
- NEVER <hard boundary 2>
- Always escalate to human when: <escalation condition>
```

## Step 4b — Create Type B agent (autonomous, full folder)

### Phase 1 — Gather information (ask all at once, single message)

Ask these questions in one go — do NOT ask one by one:

```text
Before I build the agent, a few quick questions:

1. **Mission**: What does this agent optimize for? (one sentence)
2. **Goals**: What are 2–4 measurable outcomes? For each, give a KPI + current baseline + target.
   Example: "Deploy failure rate | Baseline: 8% | Target: <2%"
3. **Skills**: What capabilities does this agent need? (e.g., "scan Terraform plans", "parse CI logs")
4. **Schedule**: How often does it run? (daily, weekly, on-demand?)
5. **Inputs**: What data does it read? (files, logs, API outputs, Slack messages?)
6. **Hard boundaries**: What should it NEVER do? (e.g., "never apply changes", "never push to prod")
7. **Escalation**: When should it stop and ask a human?
```

Wait for user answers. Then use the answers to fill every field below — no placeholders left blank.

If the user gives partial answers, infer reasonable defaults for DevOps context and note what you inferred.

### Phase 2 — Create files

Create the following structure under `.claude/agents/<agent-name>/`:

### `AGENT.md`
```markdown
---
name: <agent-name>
type: autonomous
---

# <Agent title>

## Mission

<One sentence. What does this agent optimize for?>

## Goals & KPIs

| Goal | KPI | Baseline | Target |
|------|-----|----------|--------|
| <Goal 1> | <Measurable metric> | <Current value> | <Target value> |
| <Goal 2> | <Measurable metric> | <Current value> | <Target value> |

## Non-Goals

- <What this agent explicitly does NOT do — min 2>

## Skills

| Skill | File | Serves Goal |
|-------|------|-------------|
| <Skill name> | skills/<SKILL_NAME>.md | <Goal name> |

## Input Contract

- <Data source 1: what it is, where it comes from>

## Output Contract

- <Output 1: what it produces, format, location, naming: YYYY-MM-DD_<agent>_<desc>.md>

## What Success Looks Like

<Concrete, measurable outcomes. No aspirational language.>

## What This Agent Should Never Do

- <Hard boundary 1>
- <Hard boundary 2>
- <Hard boundary 3>
```

### `HEARTBEAT.md`
```markdown
# <Agent name> heartbeat

## Schedule

<Daily / Weekly / Custom — be specific>

## Each Cycle

1. **Read context** — <what to read: journal, data/imports/, shared knowledge>
2. **Assess state** — <what to evaluate before acting>
3. **Execute skill** — <which skill runs and under what condition>
4. **Log to journal** — write dated entry to journal/ with findings

## Decision Tree

- If <condition A> → run <SKILL_NAME>
- If <condition B> → run <OTHER_SKILL>
- If <condition C> → escalate to human

## Weekly Review

1. Gather data from outputs/ for the past 7 days
2. Score against KPI targets in AGENT.md
3. Analyze gaps
4. Update MEMORY.md with confirmed patterns
5. Log summary to journal/

## Escalation Rules

Escalate to human when:
- <Escalation trigger 1>
- <Escalation trigger 2>
```

### `MEMORY.md`
```markdown
# <Agent name> memory

<!-- Memory is earned from real data. Do not pre-fill with assumptions. -->

## What Works

## What Doesn't Work

## Patterns Noticed

## Process Improvements

## Last Updated

—
```

### `RULES.md`
```markdown
# <Agent name> rules

## This agent CAN

- Read from: journal/, knowledge/, data/imports/
- Write outputs to: outputs/ (dated files only)
- Update: MEMORY.md (in-place updates allowed)
- Log findings to: journal/
- Request human approval via journal entry

## This agent CANNOT

- Publish or send anything externally without human approval
- Modify files outside its own agent folder (except journal/)
- Write directly to knowledge/ — propose changes via journal entry
- Modify other agents' files

## Hand off to HUMAN when

- <Condition 1>
- <Condition 2 — strategic decision needed>

## Hand off to ORCHESTRATOR when

- Task doesn't fit this agent's mission
- Output affects multiple agents

## Sync Safety

- All output files use date-prefix: YYYY-MM-DD_<agent>_<desc>.md
- MEMORY.md is the only file updated in-place
```

### `skills/_SKILL_TEMPLATE.md`
```markdown
# Skill template

## Purpose

## Serves Goals

## Inputs

## Process

1.
2.
3.

## Outputs

## Quality Bar
```

### Create empty dirs:
- `data/imports/` with `HOW_TO_EXPORT.md` (brief note on how to drop data)
- `outputs/`

## Step 5 — Print summary

```
Created (<type>):
  .claude/agents/<agent-name>.md          ← Type A
  OR
  .claude/agents/<agent-name>/
    ├── AGENT.md
    ├── HEARTBEAT.md
    ├── MEMORY.md
    ├── RULES.md
    ├── skills/_SKILL_TEMPLATE.md
    ├── data/imports/HOW_TO_EXPORT.md
    └── outputs/                          ← Type B

Next steps:
1. Fill in all <placeholder> fields
2. Add at least one real skill: /new-skill <skill-name>
3. For Type B: define the decision tree in HEARTBEAT.md
```

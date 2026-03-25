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

### Phase 1 — Tur 1: Mission + context (2 soru, tek mesaj)

```text
Before I build the agent, let's start with two things:

1. Mission: What does this agent optimize for? (one sentence — be specific)
   Bad:  "monitor infrastructure"
   Good: "detect Terraform drift before it causes production incidents"

2. Context (optional but helpful): What tools, systems, or data sources is it working with?
   If none apply or it's not tool-specific, just describe the domain.
   Example: "Terraform + AWS, reads plan output files"
   Example: "reads Slack incident channel messages"
   Example: "no specific tools — reads markdown status reports"
```

Wait for the answer. Then proceed to Tur 2.

---

### Phase 1 — Tur 2: Shaped questions based on Tur 1

Read the mission and context carefully. Ask targeted follow-up questions shaped by what you learned — not a generic list.

**How to shape the questions:**

Before writing a single question, reason through these four things based on the mission + context:

1. **What is being tracked?** — Is this about rates, counts, durations, costs, quality scores, states? The KPI format follows from this.
2. **What does the agent "see"?** — What raw material does it consume? Files it reads, APIs it calls, logs it parses, messages it receives. The input contract follows from this.
3. **What does the agent "do"?** — Is it detecting anomalies, summarizing reports, generating artefacts, alerting on thresholds? The skill list and decision tree follow from this.
4. **What could go wrong?** — Where might it take an irreversible or high-impact action? The boundaries and escalation rules follow from this.

The context (tools, systems) is just evidence — use it to sharpen your reasoning, not as a lookup table. Two agents using the same tool can have completely different KPIs, skills, and risk profiles depending on their mission. Let the mission drive the shape; let the context add precision.

Then ask only what you can't infer. Always include these five:

**1. Goals & KPIs** — propose 2–3 specific KPI candidates based on the mission, ask user to confirm or replace:

```text
Based on your mission, here are likely KPIs — confirm, adjust, or replace:
  [inferred KPI 1] | Baseline: ? | Target: ?
  [inferred KPI 2] | Baseline: ? | Target: ?
Both baseline AND target required. Write "unknown" if baseline isn't measured yet.
```

**2. Skills** — propose 1–2 skill names based on the mission, ask which goals they serve:

```text
Likely skills for this agent:
  [inferred skill 1] — serves [inferred goal]?
  [inferred skill 2] — serves [inferred goal]?
Confirm, rename, or add to this list.
```

**3. Schedule** — suggest a default based on the mission cadence, then ask to confirm:

- "detect/alert" type → daily
- "review/summarize" type → weekly
- "on-change" type → on-demand

**4. Inputs** — propose based on context, ask to confirm:

```text
Expected inputs based on what you described:
  [inferred input source]
Does this match? Anything else it should read?
```

**5. Escalation** — ask with a concrete example relevant to the mission:

```text
When should this agent stop and ask you directly?
Example for this type of agent: "[mission-relevant escalation scenario]"
Give at least 2 conditions.
```

Only ask about production exposure if the mission or context implies write access or destructive potential. Skip it for read-only agents.

Wait for answers. **Do not generate files until Tur 2 answers are received.**

---

### Phase 1 — Validation before generating

**KPI validation:**

- If any goal is missing baseline or target → stop and ask specifically for that goal's missing value
- Do not accept vague targets like "improve" or "reduce" — require a number or an explicit "unknown"

**Skill-to-goal mapping:**

- Every skill must map to at least one goal
- If a skill doesn't map to any goal → ask "Which goal does `<skill>` serve, or should we add a goal for it?"
- Build the AGENT.md Skills table only after all mappings are confirmed

**Decision tree generation (HEARTBEAT.md):**

- For each skill, derive the trigger condition from Tur 2 answers
- Pattern: "If [state condition from inputs] → run SKILL_NAME"
- If trigger is unclear → ask "When exactly should `<skill>` run?"
- Do not leave decision tree entries as placeholders

**Auto-add hard boundaries when applicable:**

Don't use a checklist — reason from the mission and context:

- Does the agent's "doing" (step 3 above) involve writing, applying, deleting, deploying, or triggering something? → Add a boundary that prevents it from doing that without human approval.
- Does the agent have access to production systems, sensitive data, or shared state? → Add a boundary scoped to that specific risk.
- Could the agent's output be consumed by another system automatically? → Add a boundary around unreviewed output propagation.

Example reasoning (not a template to copy):
"This agent reads CI logs and could theoretically re-trigger a pipeline — so: NEVER trigger pipeline runs without human confirmation."
"This agent generates Terraform plans — NEVER run apply or destroy."
"This agent only reads and summarizes — no write-access boundaries needed beyond the standard RULES.md defaults."

Merge inferred boundaries with any the user explicitly listed. If nothing risky is implied, state that and skip.

If user gives partial answers, state what you're inferring and ask for confirmation before generating.

### Phase 2 — Create files

Create the following structure under `.claude/agents/<agent-name>/`:

#### `AGENT.md`

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

- <Output 1: what it produces, format, location, naming: YYYY-MM-DD_agent_desc.md>

## What Success Looks Like

<Concrete, measurable outcomes. No aspirational language.>

## What This Agent Should Never Do

- <Hard boundary 1>
- <Hard boundary 2>
- <Hard boundary 3>
```

#### `HEARTBEAT.md`

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

#### `MEMORY.md`

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

#### `RULES.md`

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

- All output files use date-prefix: YYYY-MM-DD_agent_desc.md
- MEMORY.md is the only file updated in-place
```

#### `skills/_SKILL_TEMPLATE.md`

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

Create empty dirs:

- `data/imports/` with `HOW_TO_EXPORT.md` (brief note on how to drop data)
- `outputs/`

## Step 5 — Print summary

```text
Created (Type B):
  .claude/agents/<agent-name>/
    AGENT.md
    HEARTBEAT.md
    MEMORY.md
    RULES.md
    skills/_SKILL_TEMPLATE.md
    data/imports/HOW_TO_EXPORT.md
    outputs/

Next steps:
1. Add at least one real skill: /new-skill <skill-name>
2. Run first cycle manually to verify the decision tree works
```

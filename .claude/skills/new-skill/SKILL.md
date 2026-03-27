---
name: new-skill
description: >
  Create a new Claude Code skill following project conventions. Use when the user
  says "new skill", "add skill", "create skill", or "yeni skill ekle". Guides
  through gathering requirements, writing effective SKILL.md files, and structuring
  skill directories.
argument-hint: "<skill-name> [description of what it does]"
allowed-tools: Read, Glob, Write, Edit, AskUserQuestion
---

# Creating Skills in Claude Code

This skill guides you through creating effective skills for Claude Code. Skills are markdown files that teach the agent how to perform specific tasks: reviewing PRs, generating commit messages, querying databases, or any specialized workflow.

## Phase 1 — Gather Requirements

Before creating a skill, gather essential information. If `$ARGUMENTS` provides a name and description, infer what you can. For anything unclear, ask the user.

### Required information

1. **skill-name**: lowercase, hyphen-separated (e.g., `tf-plan-review`). Max 64 chars.
2. **Purpose**: What specific task or workflow should this skill help with?
3. **Trigger scenarios**: When should the agent automatically apply this skill? What would the user say?
4. **Key domain knowledge**: What specialized information does the agent need that it wouldn't already know?

### Optional information

1. **Output format**: Are there specific templates, formats, or styles required?
2. **Reference files needed?** Environment-specific config, runbooks, API docs → `references/` subfolder (Tier 3)
3. **Deterministic scripts needed?** Status checks, linters, formatters → `scripts/` subfolder
4. **Existing patterns**: Are there existing examples or conventions to follow?

### Inferring from context

If you have previous conversation context, infer the skill from what was discussed. Create skills based on workflows, patterns, or domain knowledge that emerged in the conversation.

If skill-name is missing from `$ARGUMENTS`, stop and ask.

---

## Phase 2 — Check for Conflicts

1. Glob `.claude/skills/` to list existing skills
2. If a skill with the same name exists, stop and tell the user
3. Quick overlap check: does an existing skill already cover this purpose? If so, suggest updating it instead

---

## Phase 3 — Design the Skill

### Directory layout

Skills are stored as directories containing a `SKILL.md` file:

```text
.claude/skills/<skill-name>/
├── SKILL.md              # Required — main instructions
├── references/           # Optional — Tier 3, loaded only on explicit request
│   ├── README.md
│   └── <env-specific>.md
└── scripts/              # Optional — deterministic checks/formatters only
    └── <script-name>.sh
```

### Writing the description (critical for discovery)

The description determines when Claude applies the skill. It must include both WHAT and WHEN.

**Rules:**

- Write in third person (injected into system prompt)
- Be specific, include trigger terms the user would naturally say
- Include Turkish trigger phrases if the user works in Turkish
- Max 1024 chars

**Good examples:**

```yaml
# Concise and trigger-rich
description: >
  Review Terraform plan output for cost, security, and drift issues. Use when
  the user says "review plan", "tf plan check", or pastes terraform plan output.

# Multi-language triggers
description: >
  Generate conventional commit messages by analyzing staged changes. Use when
  the user says "commit message", "write commit", or "commit yaz".
```

**Bad examples:**

```yaml
# Too vague — agent won't know when to trigger
description: "Helps with infrastructure"

# First person — wrong voice
description: "I review your Terraform plans"
```

### Choosing the right degree of freedom

Match specificity to the task's fragility:

| Freedom | When to use | Example |
| --- | --- | --- |
| **High** (text guidance) | Multiple valid approaches | Code review guidelines |
| **Medium** (templates/pseudocode) | Preferred pattern with variation OK | Report generation |
| **Low** (exact scripts) | Fragile ops, consistency critical | DB migrations, deployments |

---

## Phase 4 — Create Files

### 4a. Create `.claude/skills/<skill-name>/SKILL.md`

Use this template — fill in every field, no placeholders left blank:

```markdown
---
name: <skill-name>
description: >
  <One sentence. What it does + when to trigger. Include natural trigger phrases.>
argument-hint: "<what arguments this skill accepts, if any>"
allowed-tools: <comma-separated — only tools this skill actually needs>
disable-model-invocation: true
---

# <Skill title>

## Purpose

<One paragraph. What does this skill do and why does it exist?>

## When to use

- <Trigger scenario 1>
- <Trigger scenario 2>

## Inputs

- <Input 1: what it is, where it comes from>

## Process

1. <Step 1 — clear action>
2. <Step 2>
3. <Step 3>
4. <Step 4 — what to produce and where>

## Output

<What the skill produces. Format, location, naming convention.>

## Quality bar

<Minimum standard for acceptable output. What does "done" look like?>
```

#### Key authoring principles

**Concise is key.** The context window is shared with conversation history, other skills, and user requests. Every token competes for space. The agent is already smart — only add context it doesn't already have.

Challenge each piece of information:

- "Does the agent really need this?"
- "Can I assume the agent knows this?"
- "Does this paragraph justify its token cost?"

**Keep SKILL.md under 500 lines.** Use progressive disclosure — put essential info in SKILL.md, detailed reference in separate files.

```markdown
## Additional resources

- For complete API details, see [reference.md](references/api.md)
- For usage examples, see [references/examples.md](references/examples.md)
```

Keep references **one level deep** — link directly from SKILL.md. Deeply nested references may result in partial reads.

### Common SKILL.md patterns

#### Template pattern — when output format matters

```markdown
## Report structure

\`\`\`markdown

# [Analysis Title]

## Executive summary

[One-paragraph overview]

## Key findings

- Finding 1 with data
- Finding 2 with data

## Recommendations

1. Actionable recommendation
   \`\`\`
```

#### Examples pattern — when output quality depends on seeing examples

```markdown
## Commit format

**Example 1:**
Input: Added JWT authentication
Output: `feat(auth): implement JWT-based authentication`

**Example 2:**
Input: Fixed timezone bug in reports
Output: `fix(reports): correct date formatting in timezone conversion`
```

#### Workflow pattern — when steps must happen in order

```markdown
## Checklist

- [ ] Step 1: Analyze input
- [ ] Step 2: Generate mapping
- [ ] Step 3: Validate
- [ ] Step 4: Produce output
- [ ] Step 5: Verify
```

#### Feedback loop pattern — for quality-critical tasks

```markdown
1. Make edits
2. **Validate**: `scripts/validate.sh output/`
3. If validation fails → fix → re-validate
4. Only proceed when validation passes
```

### 4b. If references needed — create `references/README.md`

```markdown
# <skill-name> references

Add environment-specific reference files here. These are Tier 3 — loaded only on explicit request.

Example files:

- `staging.md` — staging environment details
- `production.md` — production environment details
- `runbook.md` — step-by-step operational runbook
```

### 4c. If scripts needed — create `scripts/<name>.sh`

Scripts must be:

- **Deterministic** status checks or formatters only
- **NOT** reconstruction of logic Claude should reason through
- **Executable** — remind user to `chmod +x`
- Document required packages/dependencies

---

## Phase 5 — Update Parent Agent (if applicable)

1. Glob `.claude/agents/` for directories (not `.md` files — those are Type A agents)
2. For each agent directory, read its `AGENT.md`
3. If the skill matches the agent's domain, ask:
   "This looks related to `<agent-name>`. Should I add this skill to its AGENT.md Skills table?"
4. If yes, also ask which goal it serves — do not guess

---

## Phase 6 — Print Summary

```text
Created:
  .claude/skills/<skill-name>/SKILL.md
  [.claude/skills/<skill-name>/references/README.md]  ← if applicable
  [.claude/skills/<skill-name>/scripts/<name>.sh]      ← if applicable

[Updated: .claude/agents/<agent-name>/AGENT.md]        ← if applicable

Trigger phrases: "<from description>"

Next steps:
  → Fill in the Process steps with your actual workflow
  → Add reference files to references/ if you need env-specific config
  → Test the skill by invoking its trigger phrases
```

---

## Anti-Patterns to Avoid

| Anti-pattern | Problem | Fix |
| --- | --- | --- |
| Vague skill name (`helper`, `utils`) | Agent can't match intent | Use specific names: `pdf-extract`, `pr-review` |
| Too many tool options | Confusing, wastes tokens | Provide one default, mention alternatives only for edge cases |
| Verbose explanations | Token waste | The agent is smart — only add what it doesn't know |
| Time-sensitive info ("before August 2025...") | Goes stale | Use "current" vs "deprecated" sections |
| Inconsistent terminology | Confusing | Pick one term, use it throughout |
| Deep reference nesting (ref → ref → ref) | Partial reads | Keep references one level deep from SKILL.md |
| Scripts that duplicate Claude's reasoning | Fragile, hard to maintain | Scripts for deterministic ops only |

---

## Complete Example

```text
pr-review/
├── SKILL.md
└── references/
    └── standards.md
```

**SKILL.md:**

```markdown
---
name: pr-review
description: >
  Review pull requests for quality, security, and maintainability. Use when
  the user says "review PR", "check this PR", or "PR review".
argument-hint: "<PR number or URL>"
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
---

# PR Review

## Purpose

Review code changes in a pull request against team standards, checking for
correctness, security, readability, and test coverage.

## Process

1. Fetch PR diff via `gh pr diff <number>`
2. Identify changed files and categorize (new, modified, deleted)
3. For each file, check against standards in [standards.md](references/standards.md)
4. Produce review summary

## Output

Structured review with severity levels:

- 🔴 **Critical** — must fix before merge
- 🟡 **Suggestion** — consider improving
- 🟢 **Nitpick** — optional enhancement

## Quality bar

Every critical issue must include: file path, line number, what's wrong, and a fix suggestion.
```

---

## Verification Checklist

Before finalizing, verify:

- [ ] Description is specific, includes trigger terms, written in third person
- [ ] SKILL.md body is under 500 lines
- [ ] Consistent terminology throughout
- [ ] `allowed-tools` lists only what the skill actually needs
- [ ] File references are one level deep
- [ ] No time-sensitive information
- [ ] Scripts (if any) are deterministic, not reasoning
- [ ] No conflict with existing skills

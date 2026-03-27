---
name: new-rule
description: >
  Add a new Claude Code control following project conventions. Use when the user
  says "new rule", "add rule", "create rule", "yeni rule ekle", or wants to
  enforce behavior consistently. Guides through choosing enforcement surfaces,
  writing effective rule files, and keeping controls consistent.
argument-hint: "<rule-name> [description]"
allowed-tools: Read, Glob, Write, Edit, AskUserQuestion
disable-model-invocation: true
---

# Creating Rules & Controls in Claude Code

This skill guides you through creating effective rules and controls for Claude Code. Rules provide persistent AI guidance — coding standards, architectural conventions, safety policies, or file-specific patterns. Claude Code uses a **three-surface enforcement model** where different mechanisms serve different purposes.

## Before You Begin: Understand the Control Surfaces

Claude Code has three enforcement surfaces. Choose the right one (or combine them) based on what you're controlling:

| Surface         | Path                         | Purpose                           | When to use                                                                   |
| --------------- | ---------------------------- | --------------------------------- | ----------------------------------------------------------------------------- |
| **Rule file**   | `.claude/rules/*.md`         | Behavioral guidance, conventions  | What Claude should prefer/avoid in reasoning and edits                        |
| **Permissions** | `.claude/settings.json`      | Command-level access control      | What commands can or cannot run                                               |
| **Hook script** | `.claude/hooks/scripts/*.sh` | Runtime guards, advanced patterns | Patterns not expressible in permissions (e.g., `curl\|bash`, destructive SQL) |

**Key principle:** Use one primary mechanism for enforcement, then optionally add a small reference rule. Never duplicate command restrictions in rule files that are already enforced in settings/hooks.

---

## Phase 1 — Gather Requirements

From `$ARGUMENTS`, extract:

- **name**: lowercase, hyphen-separated (e.g., `no-direct-db-writes`)
- **purpose**: what behavior or risk should be controlled

If name is missing, stop and ask.

### Required information

1. **Purpose**: What should this rule enforce or teach?
2. **Scope**: Should it always apply, or only for specific file paths?
3. **Path patterns**: If scoped, which glob patterns? (e.g., `src/api/**`, `**/*.test.ts`)
4. **Enforcement type**: Guidance only? Command restriction? Runtime guard? Combination?

### Inferring from context

If you have previous conversation context, infer the rule from what was discussed. You can create rules based on patterns, mistakes, or conventions that emerged in the conversation. Don't ask redundant questions if the context already provides the answers.

### When to ask

If the intent is ambiguous between guidance vs enforcement, ask one question:

```text
Should this be enforced as:
1) guidance in a rule file (advisory — Claude may weigh against other context),
2) command restriction in settings.json (deterministic — always blocked/allowed),
3) runtime guard in a hook (deterministic — pattern-matched at execution time),
or a combination?
```

---

## Phase 2 — Read Current State & Check Conflicts

Read these files before proposing anything:

1. `.claude/rules/README.md`
2. `.claude/settings.json`
3. `.claude/hooks/scripts/pre-bash-guard.sh`
4. Glob `.claude/rules/*.md` and list existing rule files

### Overlap check (mandatory)

Scan existing rules in `.claude/rules/*.md` (exclude `README.md`):

- Compare **intent**: does an existing rule already enforce the same behavior?
- Compare **scope**: are the same paths/files targeted?
- Compare **directives**: do "Always/Never/Prefer" lines overlap or contradict?

If overlap is found:

```text
I found overlap with <existing-rule>. Should I update that rule instead of creating a new one?
```

If overlap is partial, merge missing directives into the existing rule when possible — keep one source of truth.

---

## Phase 3 — Choose Enforcement Surface

Classify the request using this decision tree:

```text
Is this about WHAT Claude should think/prefer/avoid?
  → Rule file (.claude/rules/*.md)

Is this about WHICH COMMANDS can run?
  → Permissions (.claude/settings.json)

Is this about RUNTIME PATTERNS not expressible as simple command allow/deny?
  → Hook script (.claude/hooks/scripts/*.sh)

Does it mix concerns?
  → Hybrid: policy intent in rule file + enforcement in settings/hook
```

### Hybrid controls

When a request mixes concerns, apply multiple mechanisms in one change:

- **Policy intent** in a rule file (high-level, no command pattern duplication)
- **Exact command enforcement** in `settings.json`
- **Pattern/runtime guard** logic in hook scripts

The rule file should reference the enforcement source of truth, not restate it:

```markdown
# No direct database writes

- Never run raw SQL mutations outside of migration scripts
- Command restrictions enforced in `.claude/settings.json` and `.claude/hooks/scripts/pre-bash-guard.sh`

<!-- Why: production incident from unreviewed schema change -->
```

---

## Phase 4 — Create the Control

### 4A) Rule file (`.claude/rules/<name>.md`)

#### Rule file structure

```markdown
---
paths:
  - "<glob pattern>" # Omit frontmatter entirely if global
---

# <Rule title>

- Always <directive>
- Never <directive>
- Prefer <approach> over <alternative>

<!-- Why: <motivation — incident, convention, or risk> -->
```

#### Writing effective rules

**Rules vs descriptions:** Rules are directives, not documentation. Write them as clear commands the agent should follow.

**Good (directive):**

```markdown
- Never import from `internal/` packages in test files
- Always use parameterized queries for database access
- Prefer composition over inheritance for service classes
```

**Bad (descriptive):**

```markdown
This project uses parameterized queries because SQL injection is a common
vulnerability. The team decided in Q3 2024 to standardize on this approach
after a security audit found several raw query usages...
```

#### Key authoring principles

**Concise is key.** Keep rules under 10 lines of directives. The agent reads all Tier 1 rules every session — every token competes for space. `CLAUDE.md` + all rule files combined should stay under ~1500 tokens.

**One concern per file.** Don't create a "coding-standards.md" that covers testing, naming, imports, and error handling. Split into focused rules:

- `testing-conventions.md`
- `import-boundaries.md`
- `error-handling.md`

**Use `paths` frontmatter for scoped rules.** If a rule only applies to certain files, scope it:

```yaml
---
paths:
  - "src/api/**"
  - "src/services/**"
---
```

If the rule is global, omit frontmatter entirely — don't add `paths: ["**"]`.

**Include a `Why` comment.** Future maintainers (and Claude) need to understand motivation, not just the directive. This helps judge edge cases.

**Reference enforcement sources.** If command restrictions exist in settings/hook, don't restate them — reference the source of truth:

```markdown
- Command restrictions enforced in `.claude/settings.json`
```

#### Common rule patterns

##### Convention pattern — coding standards

```markdown
# API error handling

- Always return structured error responses with `code`, `message`, and `details`
- Never expose internal stack traces in API responses
- Prefer custom error classes over generic Error

<!-- Why: API consumers depend on consistent error shape for automated handling -->
```

##### Boundary pattern — import/dependency rules

```markdown
---
paths:
  - "src/frontend/**"
---

# Frontend isolation

- Never import from `src/backend/` or `src/infrastructure/`
- Always use API client for backend communication

<!-- Why: frontend/backend boundary enforced for future service extraction -->
```

##### Safety pattern — hybrid rule + enforcement

```markdown
# No production data in dev

- Never use production connection strings outside of deployment configs
- Command restrictions enforced in `.claude/settings.json`

<!-- Why: compliance requirement — dev environments must use synthetic data -->
```

##### Review pattern — PR/code review standards

```markdown
# Code review checklist

- Always check for missing error handling at system boundaries
- Always verify test coverage for new public functions
- Prefer explicit types over `any` in TypeScript

<!-- Why: team standard from Q4 retro — top 3 recurring review findings -->
```

### 4B) Permissions (`.claude/settings.json`)

Edit `.claude/settings.json`:

- Add exact entries to `permissions.allow` or `permissions.deny`
- Use format: `Bash(<pattern>)` (e.g., `Bash(npm test*)`, `Bash(rm -rf*)`)
- Keep existing entries intact
- If an entry exists in the opposite list, ask whether to remove it
- Avoid duplicates

### 4C) Hook guard (`.claude/hooks/scripts/*.sh`)

Prefer updating `.claude/hooks/scripts/pre-bash-guard.sh` unless user explicitly requested a new hook.

- Add only advanced patterns not representable as permission patterns
- Keep guard list short and security-focused
- Avoid duplicating settings deny entries

If a new hook is explicitly requested, create script in `.claude/hooks/scripts/` and wire it in `.claude/settings.json`.

---

## Phase 5 — Consistency Checks (mandatory)

Before finishing, verify all of these:

1. **No duplication**: No exact command restriction duplicated between rule text and settings/hook
2. **No duplicates in lists**: No duplicate patterns inside allow/deny or hook case blocks
3. **Source of truth references**: Rule text references enforcement sources when hybrid
4. **Tier 1 budget**: `CLAUDE.md` + all rule files still under ~1500 tokens
5. **No overlap**: No semantic overlap or contradiction with existing rule files (except intentional supersets documented in `Why`)
6. **Scope correctness**: Path-scoped rules have correct glob patterns

---

## Phase 6 — Print Summary

```text
Created/Updated controls:
- Rule: <path or "none">
- Permissions: <changed keys or "none">
- Hook: <changed script or "none">

Enforcement mapping:
- Intent/policy: <rule file or "n/a">
- Command-level enforcement: .claude/settings.json
- Runtime/pattern guard: <hook path or "n/a">
```

If this addresses a recurring mistake, suggest adding one concise item to `.claude/rules/common-mistakes.md` (max 10).

---

## Anti-Patterns to Avoid

| Anti-pattern                                      | Problem                            | Fix                                               |
| ------------------------------------------------- | ---------------------------------- | ------------------------------------------------- |
| Verbose rule text (paragraphs of explanation)     | Token waste, Tier 1 budget blown   | Keep under 10 directive lines + one `Why` comment |
| Duplicating command restrictions in rule text     | Two sources of truth that drift    | Rule references settings/hook, doesn't restate    |
| One mega-rule covering many concerns              | Hard to scope, hard to maintain    | One concern per file                              |
| Rules without `Why` comment                       | Can't judge edge cases             | Always include motivation                         |
| Path-scoped rules without `paths` frontmatter     | Rule loads globally, wastes tokens | Add frontmatter or make it explicitly global      |
| Creating a new rule when an existing one overlaps | Contradictions, redundancy         | Update existing rule instead                      |
| Time-sensitive content ("until Q2 migration...")  | Goes stale silently                | Use "current" vs "deprecated" framing             |

---

## Complete Example

**Scenario:** Team wants to prevent direct database writes outside migrations.

### Created files

**`.claude/rules/no-direct-db-writes.md`:**

```markdown
---
paths:
  - "src/**"
---

# No direct database writes

- Never execute DDL or raw INSERT/UPDATE/DELETE outside of `migrations/`
- Always use the repository pattern for data access
- Command enforcement in `.claude/settings.json` and hook guard

<!-- Why: production incident from unreviewed schema change in Nov 2025 -->
```

**`.claude/settings.json`** (added to deny):

```json
"Bash(psql*)",
"Bash(mysql*)"
```

**`.claude/hooks/scripts/pre-bash-guard.sh`** (added pattern):

```bash
*DROP*TABLE*|*TRUNCATE*|*ALTER*TABLE*)
```

**Summary:**

```text
Created/Updated controls:
- Rule: .claude/rules/no-direct-db-writes.md
- Permissions: added psql/mysql to deny list
- Hook: added DROP/TRUNCATE/ALTER patterns to pre-bash-guard.sh

Enforcement mapping:
- Intent/policy: .claude/rules/no-direct-db-writes.md
- Command-level enforcement: .claude/settings.json
- Runtime/pattern guard: .claude/hooks/scripts/pre-bash-guard.sh
```

---

## Verification Checklist

- [ ] Rule text is under 10 directive lines
- [ ] One concern per file
- [ ] `paths` frontmatter used for scoped rules (or omitted for global)
- [ ] `Why` comment included with motivation
- [ ] No command restrictions duplicated between rule text and settings/hook
- [ ] Tier 1 token budget still within ~1500 tokens
- [ ] Overlap check passed against existing rules
- [ ] Enforcement sources referenced (not restated) in hybrid controls

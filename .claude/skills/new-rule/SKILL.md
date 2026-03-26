---
name: new-rule
description: >
  Add a new Claude Code control following project conventions. Use when the user
  says "new rule", "add rule", "create rule", "yeni rule ekle", or wants
  to enforce behavior consistently. This workflow can update rule files,
  settings.json permissions, and hooks in one pass.
argument-hint: "<rule-name> [description]"
allowed-tools: Read, Glob, Write, Edit
disable-model-invocation: true
---

# New rule / control scaffold

Target name: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, extract:

- **name**: lowercase, hyphen-separated (e.g., `no-direct-db-writes`)
- **purpose**: what behavior or risk should be controlled (if not given, ask)

If name is missing, stop and ask.

## Step 2 — Read current control surfaces

Read these files before proposing anything:

- `.claude/rules/README.md`
- `.claude/settings.json`
- `.claude/hooks/scripts/pre-bash-guard.sh`
- Glob `.claude/rules/*.md` and list existing rule files

If a same-name file already exists, stop and suggest `/update-rule <name>`.

## Step 2.5 — Quick overlap check (mandatory for rule text)

If a rule file will be created or updated, run a fast overlap scan across `.claude/rules/*.md` (exclude `README.md`):

- Compare **intent**: does an existing rule already enforce the same behavior?
- Compare **scope**: are the same paths/files targeted?
- Compare **directives**: do "Always/Never/Prefer" lines overlap or contradict?

If overlap is found, do not create a parallel rule by default. Ask:

```text
I found overlap with <existing-rule>. Should I update that rule instead of creating a new one?
```

If overlap is partial, merge missing directives into the existing rule when possible and keep one source of truth.

## Step 3 — Choose enforcement surface (required)

Classify the request with this matrix:

- **Rule file (`.claude/rules/*.md`)**:
  Use for behavioral guidance, architecture conventions, review expectations, and path-scoped coding rules.
- **Permissions (`.claude/settings.json`)**:
  Use for command-level allow/deny controls.
- **Hook (`.claude/hooks/scripts/*.sh`)**:
  Use for runtime checks and advanced patterns not expressible in permissions.
- **Hybrid (Rule + Permissions and/or Hook)**:
  Use when policy intent and technical enforcement are both needed.

If the intent is ambiguous, ask one question:

```text
Should this be enforced as:
1) guidance in a rule file,
2) command restriction in settings.json,
3) runtime guard in a hook,
or a combination?
```

## Step 4 — Gather missing details (ask once)

Ask only for missing fields:

```text
To create this cleanly, I need:

1. Scope for rule text (global or path-specific, and path globs if scoped)
2. Directives (Always/Never/Prefer ...)
3. Command patterns to allow/deny (if permissions update is needed)
4. Advanced risky patterns (if hook update is needed)
5. Why this exists (incident/convention/risk)
```

## Step 5 — Apply all required changes in one pass

### 5A) Rule file (if selected)

Create `.claude/rules/<name>.md`.

- Use concise directives.
- Keep under 10 lines.
- If scoped, add `paths` frontmatter.
- Add one `Why` comment.
- If command restrictions are enforced in settings/hook, keep rule text high-level and reference source of truth.

Template:

```markdown
---
paths:
  - "<glob pattern>"
---

# <Rule title>

- Always <directive>
- Never <directive>

<!-- Why: <motivation> -->
```

If global, omit frontmatter.

### 5B) Permissions (if selected)

Edit `.claude/settings.json`:

- Add exact entries to `permissions.allow` or `permissions.deny`.
- Keep existing entries intact.
- If an entry exists in the opposite list, ask whether to remove the opposite entry.
- Avoid duplicates.

Use format: `Bash(<pattern>)`.

### 5C) Hook guard (if selected)

Prefer updating `.claude/hooks/scripts/pre-bash-guard.sh` unless user explicitly requested a new hook.

- Add only advanced patterns not representable as permission patterns.
- Keep guard list short and security-focused.
- Avoid duplicating settings deny entries.

If a new hook is explicitly requested, create script in `.claude/hooks/scripts/` and wire it in `.claude/settings.json`.

## Step 6 — Consistency checks (mandatory)

Before finishing:

1. No exact command restriction duplicated between rule text and settings/hook.
2. No duplicate patterns inside allow/deny or hook case blocks.
3. Rule text references enforcement sources when hybrid:
   - `.claude/settings.json`
   - `.claude/hooks/scripts/pre-bash-guard.sh`
4. Tier 1 remains concise.
5. No semantic overlap or contradiction with existing rule files (except intentional supersets documented in `Why`).

## Step 7 — Print summary

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

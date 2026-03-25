---
name: update-permissions
description: >
  Add or remove permissions in .claude/settings.json. Use when the user says
  "add permission", "allow X", "deny X", "block X", "izin ver", "engelle",
  or "update-permissions".
argument-hint: "[allow|deny] <command-pattern>"
allowed-tools: Read, Edit
disable-model-invocation: true
---

# Update permissions

Request: $ARGUMENTS

## Step 1 — Parse intent

From `$ARGUMENTS`, determine:

- **Action**: allow or deny
- **Pattern**: the command pattern (e.g., `terraform apply *`, `kubectl delete *`)

If either is missing or ambiguous, ask one question:

```text
What would you like to do?
  allow <pattern>  — let Claude run this without asking
  deny <pattern>   — always block this, even if user approves

Example: "allow terraform plan *"
Example: "deny kubectl delete *"
```

## Step 2 — Read current settings

Read `.claude/settings.json`. Show the user the current allow and deny lists so they can confirm the change makes sense.

## Step 3 — Validate the pattern

Before adding, check:

- Is this pattern already in the allow or deny list? → Stop and tell the user.
- Is this pattern in the **opposite** list? (e.g., adding to allow but it's already in deny) → Warn: "This pattern is currently in the deny list. Adding it to allow won't override the deny — remove it from deny first?"
- Does the pattern use `*` correctly? A pattern like `terraform *` covers all terraform subcommands. A pattern like `terraform apply` (no wildcard) only matches that exact string.

## Step 4 — Apply the change

Edit `.claude/settings.json`:

- Add to `permissions.allow[]` or `permissions.deny[]` as appropriate
- Preserve existing entries and formatting
- Keep entries sorted roughly by tool category (git, terraform, k8s, docker, etc.) for readability

## Step 5 — Print summary

```text
Updated: .claude/settings.json
Added to <allow|deny>: "Bash(<pattern>)"

Note: allow = Claude proceeds without prompting
      deny  = always blocked, even with user approval
      Conflicts: deny takes precedence over allow.
```

If the change was to deny a previously allowed pattern, remind:
"You may also want to remove it from the allow list to keep settings clean."

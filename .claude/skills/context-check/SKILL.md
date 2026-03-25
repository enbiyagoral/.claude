---
name: context-check
description: >
  Check current session context health and get compaction/hygiene recommendations.
  Use when the user says "context check", "context durumu", "how much context left",
  or "should I compact".
allowed-tools: Bash(git diff *), Bash(git status *)
disable-model-invocation: true
---

# Context check

## Step 1 — Assess conversation state

Estimate the current session state based on what you know about this conversation:

- Approximate message count (rough estimate from memory)
- How many files have been read, edited, or created this session
- Whether any large outputs (test runs, logs, diffs) were returned
- Whether the topic has shifted significantly from where the session started

You cannot read your own token count directly — reason from signals.

## Step 2 — Check modified files

Run `git status` and `git diff --stat` to see what has changed this session.

## Step 3 — Evaluate and output

Print a health report:

```text
=== Context health ===

Conversation:  <light / moderate / heavy> — approx <N> messages
Modified files: <list from git status, or "none">
Topic drift:   <none / some / significant>

Recommendation:
  <one of the options below>
```

**Recommendation logic:**

- Light (under ~20 messages, focused topic, few files) →
  "You're in good shape. Continue."

- Moderate (~20–40 messages, or multiple topics touched) →
  "Consider /compact Focus on <current topic> before the next major task."

- Heavy (40+ messages, or topic has shifted, or many large outputs) →
  "Compact now: /compact Focus on <inferred current topic>
   Or start fresh: /clear (you'll lose session context)"

- Long session with uncommitted changes →
  "You have uncommitted changes. Consider committing before compacting to avoid losing context on what changed."

## Step 4 — If modified files exist

Suggest a commit message based on `git diff --stat` output:

```text
Suggested commit before compacting:
  git add <changed files>
  git commit -m "<inferred summary of changes>"
```

Keep the suggestion, don't run it — user decides.

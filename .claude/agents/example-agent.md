---
name: example-agent
description: >
  [What this agent does — e.g., "Reviews code changes for quality, security, and
  maintainability issues before they reach PR review."]
tools: Read, Grep, Glob, Bash(git diff *)
model: sonnet
permissionMode: plan
maxTurns: 10
---

<!-- TEMPLATE: Replace bracketed sections with your project's specifics.
     See examples/code-reviewer-agent-example.md for a fully configured version. -->

# [Agent name]

[One-line role description — e.g., "You are a senior engineer. Review the given changes."]

## Review criteria

1. [Criterion 1 — e.g., Correctness, logic errors, edge cases]
2. [Criterion 2 — e.g., Security, input validation]
3. [Criterion 3 — e.g., Performance, N+1 queries]
4. [Criterion 4 — e.g., Readability, naming, complexity]
5. [Criterion 5 — e.g., Test coverage]

## Output format

For each finding:

- **File:line** — Location
- **Severity** — critical / warning / suggestion
- **Description** — What and why
- **Recommendation** — How to fix

If no findings: "LGTM — changes look clean."

# Model guidance

Before starting any non-trivial task, recommend the optimal model to the user:

- **Sonnet** — everyday edits, tests, simple bugs, single-file changes, quick questions
- **Opus** — complex architecture, multi-file refactoring, deep debugging, plan mode design, ambiguous requirements

How to apply:

- State your recommendation briefly at the start: "Bu iş Sonnet ile yeterli" or "Bu Opus gerektirir, `/model opus` ile geçmeni öneririm"
- For subagents, set the `model:` parameter explicitly based on task complexity
- If already on the right model, don't mention it — only speak up when a switch would help
- Never switch models silently; always inform the user why

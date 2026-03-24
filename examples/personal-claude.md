# Personal preferences (applies to all projects)

<!-- Place this file at ~/.claude/CLAUDE.md -->

## Communication
- Explain in English, keep code and commands in English
- Give short and clear answers — no unnecessary padding
- Summarize the plan before making changes, get approval

## Coding style
- Comments in English
- Commit messages in conventional commits format (feat:, fix:, chore:)
- Variable names in camelCase (JS/TS) or snake_case (Python/Go)

## Workflow
- Always work on a feature branch
- Don't open a PR without writing tests
- Use plan mode first for complex changes

## Token efficiency

- Default to Sonnet for everyday tasks; Opus only for complex architecture or multi-file refactoring
- Use plan mode (Shift+Tab) for analysis before execution
- One task per session — `/clear` when switching topics
- `/compact Focus on <topic>` at ~40 messages or ~50% context
- Don't re-read files already in context — use what you have
- Delegate verbose tasks (tests, logs, research) to subagents
- Audit MCP servers with `/context` — prefer CLI tools over MCPs

## Imports
<!-- Use @path syntax to pull in project-specific or shared docs -->
<!-- Example: @~/notes/api-conventions.md -->

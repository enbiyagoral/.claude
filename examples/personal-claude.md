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

## Context management
- When compacting, preserve: modified file list, test results, and key decisions. Drop verbose tool outputs.
- Use `/compact Focus on <topic>` proactively when context grows large
- Read only relevant sections of large files — use offset/limit parameters
- Delegate research-heavy tasks to subagents to protect main context

## Imports
<!-- Use @path syntax to pull in project-specific or shared docs -->
<!-- Example: @~/notes/api-conventions.md -->

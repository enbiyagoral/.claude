#!/bin/bash
# PostToolUse hook — auto-lint after file edits
# Claude Code passes hook input as JSON via stdin.
# This script extracts the file path with jq and runs the appropriate linter.
#
# Hooks differ from CLAUDE.md instructions:
# - CLAUDE.md = "advice" (Claude may occasionally forget)
# - Hook = "guarantee" (runs every single time)
#
# Usage: add under PostToolUse in .claude/settings.json
#
# Requires: jq (brew install jq / apt-get install jq)

INPUT=$(cat)
CHANGED_FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if no file path found
if [ -z "$CHANGED_FILE" ]; then
  exit 0
fi

# Run lint only for source files
case "$CHANGED_FILE" in
  *.ts|*.tsx|*.js|*.jsx)
    npx eslint --fix "$CHANGED_FILE" 2>/dev/null
    ;;
  *.py)
    python -m ruff check --fix "$CHANGED_FILE" 2>/dev/null
    ;;
  *.go)
    gofmt -w "$CHANGED_FILE" 2>/dev/null
    ;;
esac

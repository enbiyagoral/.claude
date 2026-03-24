#!/bin/bash
# PostToolUse hook — auto-lint after file edits
# This script runs after every Write/Edit operation.
#
# Hooks differ from CLAUDE.md instructions:
# - CLAUDE.md = "advice" (Claude may occasionally forget)
# - Hook = "guarantee" (runs every single time)
#
# Usage: add under PostToolUse in .claude/settings.json

CHANGED_FILE="$1"

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
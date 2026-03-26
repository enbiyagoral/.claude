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

if ! command -v jq >/dev/null 2>&1; then
  echo "HOOK WARN: jq not found; skipped lint hook."
  exit 0
fi

if ! CHANGED_FILE=$(echo "$INPUT" | jq -er '.tool_input.file_path // empty' 2>/dev/null); then
  echo "HOOK WARN: Could not parse edited file path; skipped lint hook."
  exit 0
fi

# Exit if no file path found
if [ -z "$CHANGED_FILE" ]; then
  exit 0
fi

# Run lint only for source files
case "$CHANGED_FILE" in
  *.ts|*.tsx|*.js|*.jsx)
    if ! command -v npx >/dev/null 2>&1; then
      echo "HOOK WARN: npx not found; skipped eslint for $CHANGED_FILE"
      exit 0
    fi
    if npx eslint --fix "$CHANGED_FILE"; then
      echo "HOOK: eslint --fix completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: eslint --fix failed for $CHANGED_FILE"
    fi
    ;;
  *.py)
    if ! command -v python >/dev/null 2>&1; then
      echo "HOOK WARN: python not found; skipped ruff for $CHANGED_FILE"
      exit 0
    fi
    if python -m ruff check --fix "$CHANGED_FILE"; then
      echo "HOOK: ruff --fix completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: ruff --fix failed for $CHANGED_FILE"
    fi
    ;;
  *.go)
    if ! command -v gofmt >/dev/null 2>&1; then
      echo "HOOK WARN: gofmt not found; skipped formatting for $CHANGED_FILE"
      exit 0
    fi
    if gofmt -w "$CHANGED_FILE"; then
      echo "HOOK: gofmt completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: gofmt failed for $CHANGED_FILE"
    fi
    ;;
esac

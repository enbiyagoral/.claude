#!/bin/bash
# PostToolUse hook — auto-format after new file creation (Write tool)
# Complements post-edit-lint.sh: that one fixes lint issues,
# this one ensures consistent formatting (indentation, trailing whitespace).
#
# Usage: add under PostToolUse in .claude/settings.json with matcher "Write"
#
# Requires: jq (brew install jq / apt-get install jq)

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "HOOK WARN: jq not found; skipped format hook."
  exit 0
fi

if ! CHANGED_FILE=$(echo "$INPUT" | jq -er '.tool_input.file_path // empty' 2>/dev/null); then
  echo "HOOK WARN: Could not parse written file path; skipped format hook."
  exit 0
fi

if [ -z "$CHANGED_FILE" ]; then
  exit 0
fi

case "$CHANGED_FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.scss|*.html|*.md|*.yaml|*.yml)
    if ! command -v npx >/dev/null 2>&1; then
      echo "HOOK WARN: npx not found; skipped prettier for $CHANGED_FILE"
      exit 0
    fi
    if npx prettier --write "$CHANGED_FILE"; then
      echo "HOOK: prettier completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: prettier failed for $CHANGED_FILE"
    fi
    ;;
  *.py)
    if ! command -v python >/dev/null 2>&1; then
      echo "HOOK WARN: python not found; skipped black for $CHANGED_FILE"
      exit 0
    fi
    if python -m black --quiet "$CHANGED_FILE"; then
      echo "HOOK: black completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: black failed for $CHANGED_FILE"
    fi
    ;;
  *.go)
    if ! command -v goimports >/dev/null 2>&1; then
      echo "HOOK WARN: goimports not found; skipped go formatting for $CHANGED_FILE"
      exit 0
    fi
    if goimports -w "$CHANGED_FILE"; then
      echo "HOOK: goimports completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: goimports failed for $CHANGED_FILE"
    fi
    ;;
  *.rs)
    if ! command -v rustfmt >/dev/null 2>&1; then
      echo "HOOK WARN: rustfmt not found; skipped rust formatting for $CHANGED_FILE"
      exit 0
    fi
    if rustfmt "$CHANGED_FILE"; then
      echo "HOOK: rustfmt completed for $CHANGED_FILE"
    else
      echo "HOOK WARN: rustfmt failed for $CHANGED_FILE"
    fi
    ;;
esac

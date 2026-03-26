#!/bin/bash
# PostToolUse hook — auto-format after new file creation (Write tool)
# Complements post-edit-lint.sh: that one fixes lint issues,
# this one ensures consistent formatting (indentation, trailing whitespace).
#
# Usage: add under PostToolUse in .claude/settings.json with matcher "Write"
#
# Requires: jq (brew install jq / apt-get install jq)

INPUT=$(cat)
CHANGED_FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$CHANGED_FILE" ]; then
  exit 0
fi

case "$CHANGED_FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.scss|*.html|*.md|*.yaml|*.yml)
    npx prettier --write "$CHANGED_FILE" 2>/dev/null
    ;;
  *.py)
    python -m black --quiet "$CHANGED_FILE" 2>/dev/null
    ;;
  *.go)
    goimports -w "$CHANGED_FILE" 2>/dev/null
    ;;
  *.rs)
    rustfmt "$CHANGED_FILE" 2>/dev/null
    ;;
esac

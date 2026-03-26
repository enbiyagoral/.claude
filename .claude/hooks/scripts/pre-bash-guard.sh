#!/bin/bash
# PreToolUse hook — advanced Bash guard.
# Single-source policy lives in .claude/settings.json (allow/deny).
# This hook only blocks patterns that are hard to model in permissions.

INPUT=$(cat 2>/dev/null || true)

if [ -z "$INPUT" ]; then
  echo "BLOCKED: Empty hook payload for Bash command."
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: jq is required by pre-bash-guard.sh but is not installed."
  exit 2
fi

if ! COMMAND=$(echo "$INPUT" | jq -er '.tool_input.command // empty' 2>/dev/null); then
  echo "BLOCKED: Could not parse Bash command from hook payload."
  exit 2
fi

if [ -z "$COMMAND" ]; then
  echo "BLOCKED: Bash command payload is empty."
  exit 2
fi

# Convert to lowercase for case-insensitive matching.
CMD_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

# Keep this list small: pipe-to-shell and destructive SQL keywords.
BLOCKED=""

case "$CMD_LOWER" in
  *":(){ :|:& };:"*)  BLOCKED="fork bomb" ;;
  *"drop table"*)     BLOCKED="DROP TABLE" ;;
  *"drop database"*)  BLOCKED="DROP DATABASE" ;;
  *"truncate table"*) BLOCKED="TRUNCATE TABLE" ;;
  *"curl "*"|"*"bash"*) BLOCKED="curl pipe to bash" ;;
  *"curl "*"|"*" sh"*)  BLOCKED="curl pipe to sh" ;;
  *"wget "*"|"*"bash"*) BLOCKED="wget pipe to bash" ;;
  *"wget "*"|"*" sh"*)  BLOCKED="wget pipe to sh" ;;
esac

if [ -n "$BLOCKED" ]; then
  echo "BLOCKED: Command matches dangerous pattern '$BLOCKED'. Review and run manually if intended."
  exit 2
fi

exit 0

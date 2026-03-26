#!/bin/bash
# PreToolUse hook — block dangerous Bash commands before execution
# Claude Code passes hook input as JSON via stdin.
# Returns exit code 2 to block the command with a reason message.
#
# Usage: add under PreToolUse in .claude/settings.json with matcher "Bash"
#
# Requires: jq (brew install jq / apt-get install jq)

INPUT=$(cat 2>/dev/null || true)

if [ -z "$INPUT" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Convert to lowercase for case-insensitive matching
CMD_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

# Block dangerous patterns using bash built-in matching
BLOCKED=""

case "$CMD_LOWER" in
  *"rm -rf /"*)       BLOCKED="rm -rf /" ;;
  *"rm -rf ~"*)       BLOCKED="rm -rf ~" ;;
  *"rm -rf .."*)      BLOCKED="rm -rf .." ;;
  *"mkfs."*)          BLOCKED="mkfs" ;;
  *"dd if="*)         BLOCKED="dd if=" ;;
  *"> /dev/sd"*)      BLOCKED="> /dev/sd" ;;
  *"chmod -r 777 /"*) BLOCKED="chmod -R 777 /" ;;
  *":(){ :|:& };:"*)  BLOCKED="fork bomb" ;;
  *"drop table"*)     BLOCKED="DROP TABLE" ;;
  *"drop database"*)  BLOCKED="DROP DATABASE" ;;
  *"truncate table"*) BLOCKED="TRUNCATE TABLE" ;;
  *"no-preserve-root"*) BLOCKED="--no-preserve-root" ;;
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

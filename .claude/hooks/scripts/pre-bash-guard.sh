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

# Patterns that should never run unintentionally
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \.\."
  "mkfs\."
  "dd if="
  "> /dev/sd"
  "chmod -R 777 /"
  ":(){ :|:& };:"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "--no-preserve-root"
  "curl.*| *bash"
  "curl.*| *sh"
  "wget.*| *bash"
  "wget.*| *sh"
)

for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$PATTERN"; then
    echo "BLOCKED: Command matches dangerous pattern '$PATTERN'. Review and run manually if intended."
    exit 2
  fi
done

exit 0

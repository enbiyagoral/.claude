#!/bin/bash
# Stop hook — remind Claude to save session learnings to memory
# Fires when Claude finishes responding. Uses exit 2 to block and inject
# a memory-saving reminder that Claude will see and act on.
#
# Prevents infinite loops via stop_hook_active check.
#
# Usage: add under Stop in .claude/settings.json
#
# Requires: jq

INPUT=$(cat)

# Prevent infinite loop — if hook already fired once, let Claude exit
HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$HOOK_ACTIVE" = "true" ]; then
  exit 0
fi

# First invocation — block Claude and request memory save
cat >&2 <<'MSG'
Session ending. Before you stop, check if you learned anything worth remembering:

1. Did the user correct your approach? → save as feedback memory
2. Did you discover how something works in this project? → save as project memory
3. Did you find a useful external resource or tool? → save as reference memory
4. Did you learn something about the user's preferences? → save as user memory

If nothing new was learned this session, you may stop without saving.
Update existing memory files when possible instead of creating new ones.
MSG
exit 2

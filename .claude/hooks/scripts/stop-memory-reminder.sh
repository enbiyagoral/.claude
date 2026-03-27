#!/bin/bash
# Stop hook — self-driving knowledge lifecycle engine
#
# Fires when Claude finishes responding. Observes the state of memory,
# common-mistakes, and learnings, then tells Claude exactly what actions
# to take before the session ends.
#
# This is the ENGINE that drives the lifecycle:
#   feedback memories → common-mistakes/rules → learnings → archive
#
# The script is the eyes (observes state). Claude is the executor (acts).
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

# --- Observe system state ---

# Find the memory directory (user-level project memory)
# Claude Code stores these at ~/.claude/projects/<project-hash>/memory/
MEMORY_DIR=""
for dir in "$HOME"/.claude/projects/*/memory; do
  if [ -d "$dir" ]; then
    MEMORY_DIR="$dir"
    break
  fi
done

# Count feedback memories
FEEDBACK_COUNT=0
if [ -n "$MEMORY_DIR" ] && [ -d "$MEMORY_DIR" ]; then
  FEEDBACK_COUNT=$(grep -rl 'type: feedback' "$MEMORY_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
fi

# Count common-mistakes items (numbered list items in the file)
MISTAKES_FILE=".claude/rules/common-mistakes.md"
MISTAKES_COUNT=0
if [ -f "$MISTAKES_FILE" ]; then
  MISTAKES_COUNT=$(grep -cE '^\d+\.\s+\*\*' "$MISTAKES_FILE" 2>/dev/null || echo 0)
fi

# Find old learnings (files with YYYY-MM-DD prefix older than 6 months)
OLD_LEARNINGS=""
LEARNINGS_DIR="docs/learnings"
if [ -d "$LEARNINGS_DIR" ]; then
  SIX_MONTHS_AGO=$(date -v-6m +%Y-%m-%d 2>/dev/null || date -d '6 months ago' +%Y-%m-%d 2>/dev/null || echo "")
  if [ -n "$SIX_MONTHS_AGO" ]; then
    for f in "$LEARNINGS_DIR"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*.md; do
      [ -f "$f" ] || continue
      FILE_DATE=$(basename "$f" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}')
      if [ -n "$FILE_DATE" ] && [ "$FILE_DATE" \< "$SIX_MONTHS_AGO" ]; then
        OLD_LEARNINGS="$OLD_LEARNINGS  - $f\n"
      fi
    done
  fi
fi

# --- Build context-aware message ---

MSG="Session ending. Before you stop:\n\n"

# Always: save new memories
MSG="${MSG}1. SAVE MEMORIES: Check if you learned anything new this session.\n"
MSG="${MSG}   - User corrections → feedback memory\n"
MSG="${MSG}   - Project discoveries → project memory\n"
MSG="${MSG}   - User preferences → user memory\n"
MSG="${MSG}   If nothing new was learned, skip this step.\n\n"

# If feedback memories have accumulated: promote patterns
if [ "$FEEDBACK_COUNT" -ge 3 ]; then
  MSG="${MSG}2. PROMOTE PATTERNS: You have ${FEEDBACK_COUNT} feedback memories accumulated.\n"
  MSG="${MSG}   Review them now. If you see recurring patterns (3+ on the same topic),\n"
  MSG="${MSG}   promote them to a common-mistakes entry or a rule file.\n"
  MSG="${MSG}   Don't just note this — actually create the rule or common-mistake entry now.\n\n"
fi

# If common-mistakes is getting full: graduate
if [ "$MISTAKES_COUNT" -ge 8 ]; then
  MSG="${MSG}3. GRADUATE: common-mistakes.md has ${MISTAKES_COUNT}/10 items.\n"
  MSG="${MSG}   Check if any are fully resolved or no longer relevant.\n"
  MSG="${MSG}   Graduate them to docs/learnings/ to free up space.\n\n"
fi

# If old learnings exist: suggest archive
if [ -n "$OLD_LEARNINGS" ]; then
  MSG="${MSG}4. ARCHIVE: These learnings are older than 6 months:\n"
  MSG="${MSG}${OLD_LEARNINGS}"
  MSG="${MSG}   If they're no longer relevant, move them to docs/archive/.\n\n"
fi

# Final note
MSG="${MSG}Act on all applicable items above, then you may stop."

printf "%b" "$MSG" >&2
exit 2

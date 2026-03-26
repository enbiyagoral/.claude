#!/bin/bash
# Stop hook — warn if there are uncommitted changes when session ends
# Prevents accidentally losing work by reminding the user to commit.
#
# Usage: add under Stop in .claude/settings.json
#
# No external dependencies required.

STAGED=$(git diff --cached --stat 2>/dev/null)
UNSTAGED=$(git diff --stat 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | head -5)

HAS_CHANGES=false

if [ -n "$STAGED" ] || [ -n "$UNSTAGED" ] || [ -n "$UNTRACKED" ]; then
  HAS_CHANGES=true
fi

if [ "$HAS_CHANGES" = true ]; then
  echo ""
  echo "⚠ Uncommitted changes detected:"
  [ -n "$STAGED" ] && echo "  Staged: $(echo "$STAGED" | tail -1)"
  [ -n "$UNSTAGED" ] && echo "  Unstaged: $(echo "$UNSTAGED" | tail -1)"
  [ -n "$UNTRACKED" ] && echo "  Untracked: $(echo "$UNTRACKED" | wc -l | tr -d ' ') file(s)"
  echo ""
  echo "  Consider committing before ending the session."
fi

exit 0

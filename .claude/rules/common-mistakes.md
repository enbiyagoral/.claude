# Common mistakes

<!-- Keep under 10 items. Graduate resolved ones to docs/learnings/.
     This file loads every session — keep it lean. -->

1. **Hook stdin, not args** — Claude Code hooks receive JSON via stdin, not positional arguments. Use `jq` to parse, not `$1`.
2. **Don't use `cat/grep/find` in Bash** — Claude has dedicated Read/Grep/Glob tools that are cheaper and more reliable.
3. **Read before Edit** — the Edit tool fails if you haven't Read the file first in the same session.

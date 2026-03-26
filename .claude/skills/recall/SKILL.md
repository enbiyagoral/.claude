---
name: recall
description: >
  Search and browse graduated learnings in docs/learnings/. Use when the user says
  "recall", "what did we learn about", "learnings about", "hatirla", "dersler",
  "past lessons", or "recall <keyword>".
argument-hint: "<search-keyword>"
allowed-tools: Read, Glob, Grep
disable-model-invocation: true
---

# Recall

Search query: $ARGUMENTS

## Step 1 — Gather learnings

Glob `docs/learnings/` for `*.md` files (exclude `README.md`).

If no learnings found, stop and print:

```text
No learnings recorded yet.
Use /graduate to promote a common-mistakes entry to a permanent learning.
```

## Step 2 — Search or list

**If a search keyword was given** ($ARGUMENTS is not empty):

Grep `docs/learnings/*.md` for the keyword (case-insensitive). For each match:

- Read the file
- Extract: title (H1), date, "Why" section (first sentence)
- Show the matching context

**If no keyword given** (browsing mode):

Read each learning file and extract: title (H1), date, one-line summary.
List them chronologically (newest first).

## Step 3 — Output

### Search results format

```text
=== Learnings matching "<keyword>" ===

[1] <title> (<date>)
    Why: <first sentence of Why section>
    File: docs/learnings/<filename>.md

[2] <title> (<date>)
    Why: <first sentence of Why section>
    File: docs/learnings/<filename>.md

Found <N> result(s). Read a file number for full details.
```

### Browse format

```text
=== All Learnings (<N> total) ===

<date>  <title>
<date>  <title>
<date>  <title>

Say "recall <keyword>" to search, or ask me to read a specific one.
```

If more than 20 learnings, show only the 20 most recent and note: "Showing 20 of <N>. Use a search keyword to narrow down."

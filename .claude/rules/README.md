# Rules guide

This directory is intentionally minimal in the base template.

- Keep Tier 1 short: `CLAUDE.md` + rule files should stay concise and non-redundant.
- `common-mistakes.md` is the only required starter rule file. Fill it with recurring project-specific mistakes over time.
- `safety-baseline.md` explains the safety model and points to enforcement sources.
- Add stack or area specific rules only after copying this template into a real project.

## Control surface decision matrix

Use one primary mechanism for enforcement, then optionally add a small reference rule.

- Use `.claude/rules/*.md` for behavioral guidance and scoped conventions (what Claude should prefer/avoid in reasoning and edits).
- Use `.claude/settings.json` `permissions.allow/deny` for command-level access control (what can or cannot run).
- Use `.claude/hooks/scripts/*.sh` for deterministic runtime checks and advanced patterns not expressible in permissions (for example `curl|bash`, destructive SQL keywords).

If a request mixes concerns, apply multiple mechanisms in one change:

- Policy intent in a rule file (high-level, no command pattern duplication).
- Exact command enforcement in `settings.json`.
- Pattern/runtime guard logic in hook scripts.

When adding a new rule:

- Prefer one concern per file.
- Use short, directive statements.
- Use `paths` frontmatter for path-specific rules.
- Avoid duplicating command restrictions already enforced in `.claude/settings.json` and `.claude/hooks/scripts/pre-bash-guard.sh`.
- Run a quick overlap check against existing rule files (intent, scope, directives) and prefer updating an existing rule over creating a parallel one.

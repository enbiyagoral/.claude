# Safety baseline

- Safety enforcement source of truth is `.claude/settings.json` permissions.
- Keep `permissions.allow` minimal; add only commands needed for the active workflow.
- Use `.claude/hooks/scripts/pre-bash-guard.sh` only for advanced patterns that permissions cannot model (for example pipe-to-shell and destructive SQL keywords).
- Do not duplicate command deny lists in rule files; reference settings + hook instead.

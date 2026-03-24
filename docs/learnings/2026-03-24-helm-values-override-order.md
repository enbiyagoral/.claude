# Helm values override order ignored during upgrade

## Context
Ran `helm upgrade` with multiple `-f` flags expecting last file to win.

## Root cause
Helm applies values files left-to-right, but inline `--set` flags override
everything. A `--set image.tag=latest` from CI was silently overriding the
pinned version in `values-production.yaml`.

## Fix
Removed `--set` from CI pipeline; moved all overrides into values files.

## Prevention
Use values files only; avoid mixing `--set` with `-f` in the same command.

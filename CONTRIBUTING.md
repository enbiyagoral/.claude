# Contributing

Thanks for considering a contribution! This template aims to stay lean and generic — every addition should benefit any project, not just a specific stack.

## How to contribute

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/your-change`)
3. Make your changes
4. Ensure your changes follow the [design constraints](#design-constraints)
5. Commit using conventional commits (`feat:`, `fix:`, `docs:`, `chore:`)
6. Open a PR against `main`

## Design constraints

Before submitting, check that your changes respect these limits:

- **`CLAUDE.md` + all `rules/` files** must stay under ~500 tokens combined
- **`common-mistakes.md`** must stay under 10 items
- **Skills** should be generic examples, not stack-specific — users customize for their own project
- **Hooks** must be deterministic — always run, no conditional skipping
- **Scripts** should be status checks or formatters — not logic Claude should reason through
- **No secrets** in any tracked file — reference by name only

## What we're looking for

- Bug fixes (broken references, incorrect hook behavior, permission gaps)
- Documentation improvements (clearer examples, better explanations)
- Token efficiency improvements (reducing Tier 1 cost, better `.claudeignore` patterns)
- New generic examples (hooks, rules) that benefit any project

## What we're NOT looking for

- Stack-specific skills (React, Django, Rails, etc.) — users create these for their own projects
- Large dependencies or tooling requirements
- Changes that increase Tier 1 token cost without clear justification

## Code review

All PRs are reviewed by [@enbiyagoral](https://github.com/enbiyagoral). Keep PRs focused — one concern per PR.
---
paths:
  - "src/components/**/*.{tsx,jsx}"
  - "src/pages/**/*.{tsx,jsx}"
---

# Frontend rules (example — customize for your stack)

<!-- This is a path-specific rule: it only loads when Claude works
     with files matching the paths above. Copy to .claude/rules/,
     rename, and adjust the paths for your project. -->

- Use functional components with hooks
- Co-locate component tests in __tests__/ next to the component
- Prefer CSS modules or Tailwind over inline styles

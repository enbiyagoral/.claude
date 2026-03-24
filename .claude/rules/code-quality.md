# Code quality rules

- Write JSDoc/docstring for every public function
- No magic numbers — define as a named const with a meaningful name
- Functions must not exceed 50 lines — if they do, break them up
- Prefer async/await over nested callbacks
- Error messages should be user-facing and actionable
- Use a structured logger instead of console.log (e.g. pino, winston)
- Add input validation whenever you add a new endpoint
- Follow existing test patterns — don't invent new ones
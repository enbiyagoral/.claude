# Code quality rules

<!-- Customize these for your stack. Examples below are language-agnostic
     starting points — replace with your project's conventions. -->

- Write docstrings/comments for every public function
- No magic numbers — define as a named constant with a meaningful name
- Functions must not exceed 50 lines — if they do, break them up
- Prefer async patterns over nested callbacks where applicable
- Error messages should be user-facing and actionable
- Use a structured logger instead of raw print/console.log
- Add input validation whenever you add a new endpoint or public interface
- Follow existing test patterns — don't invent new ones

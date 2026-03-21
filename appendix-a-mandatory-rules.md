# Приложение A — Обязательный блок правил для AI_RULES.md проекта

Следующий блок **обязателен к вставке** в `AI_RULES.md` каждого проекта без изменений.
Дополнительные правила, специфичные для проекта, добавляются после этого блока.

**Важно:** `AI_RULES.md` должен содержать не более 200 строк. Детали выносить через `@imports` и `.ai/rules/`.

> **Маппинг на инструменты:** при инициализации проекта `import.sh` транслирует `AI_RULES.md` в формат конкретного инструмента (`CLAUDE.md`, `.cursorrules` и др.).

---

```markdown
## Corporate Mandatory Rules

### Testing — TDD

All code must be written strictly following the TDD pattern. No exceptions.

Development cycle:
1. Write a failing test based on acceptance criteria (Red)
2. Write minimal implementation to make the test pass (Green)
3. Refactor without breaking tests (Refactor)

Rules:
- NEVER write implementation code before a failing test exists
- Tests must be based on acceptance criteria from docs/qa/acceptance-criteria.md
- PR without tests for new functionality is rejected without review

### Test Coverage

- Minimum threshold: 80% coverage
- CRUD operations are excluded from the coverage threshold
- Coverage is validated automatically in CI before human review

### Agentic Workflow

- Always: Explore → Plan → Implement → Verify. Never skip steps.
- Use Plan Mode (read-only) before any significant implementation task
- Minimal blast radius: change only what is required for the current task, nothing more
- If blocked, stop and report — do not attempt to brute-force past errors or safety checks
- Use subagents for codebase investigation to preserve main context
- If you discover a bug outside the current task scope: stop, create an issue, report it — do not fix it without explicit instruction

### Context Management

- Run /clear between unrelated tasks
- After 2 failed corrections — /clear and start fresh with a better prompt
- Use MCP servers for code navigation (go to definition, find references) instead of reading entire files
- Use subagents for broad codebase investigation to preserve main context
- Use MCP servers for library docs instead of pasting documentation
- Use MCP memory server to persist context between sessions
- Use MCP servers for git operations (diffs, logs) instead of raw bash output
- Use MCP servers for task tracker and knowledge base operations instead of manual copy-paste

### Code Quality

- Each module, function, and class has a single responsibility
- Prefer editing existing files over creating new ones
- No over-engineering: implement the minimum needed for the current task
- No speculative abstractions, future-proofing, or unused code

### Security Baseline

- Never hardcode credentials, API keys, tokens, or secrets
- All user inputs must be validated at system boundaries
- SQL and other queries must use parameterized statements only
- Never log sensitive data (passwords, tokens, PII)

### Git Discipline

- Each branch corresponds to a single task or fix
- Commits must be atomic and have a clear, descriptive message
- Follow Gitflow: feature/* → dev → release/* → main

### Documentation

- All significant architectural decisions must be recorded as ADR in docs/architecture/adr/
- Any change that affects system behaviour must be reflected in docs/ synchronously with the code
- Do not modify requirements documents without explicit human approval
- Each docs/ file has a single owner by role (see ownership table in standard section 5.1). NEVER edit files owned by another role — create an issue for the file owner in the task tracker instead
- Sync all docs changes to the corporate knowledge base via MCP immediately after every update. This is mandatory — git and knowledge base must always be in sync. If sync fails, report it and retry before proceeding

### AI_RULES.md Maintenance

- Keep this file under 200 lines
- Use @path/to/file imports for detailed instructions
- Use .ai/rules/ for path-specific rules
- Review periodically: if AI does it correctly without a rule — remove the rule
```

---

## Структура AI_RULES.md проекта

```markdown
# Project: [название]
# Level: [L1 / L2 / L3]
# Type: [frontend / backend / fullstack / mobile / data / infra]

## Corporate Mandatory Rules
[блок выше]

## Project-Specific Rules
[правила специфичные для проекта]

## References
- @docs/architecture/overview.md
- @docs/qa/acceptance-criteria.md
- @docs/dev/technical-notes.md
```

# Приложение G — CI/CD интеграция AI code review

Автоматический AI code review в pipeline MR через non-interactive режим Claude Code CLI.

---

## Принцип

При создании MR в `dev` ветку CI/CD pipeline автоматически запускает AI code review. Результат — комментарий к MR с замечаниями. Разработчик получает замечания до ревью человека.

**Writer/Reviewer паттерн:** AI review выполняется в свежей сессии — ИИ не предвзят к коду, который он же мог написать в другой сессии.

---

## Pipeline конфигурация

### GitLab CI

```yaml
ai-code-review:
  stage: review
  rules:
    - if: $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "dev"
  script:
    - |
      claude -p "
        You are a code reviewer. Review the diff for this MR.

        Run: git diff origin/dev...HEAD

        Review checklist:
        1. TDD: are there tests for all new functionality?
        2. Coverage: does the change maintain 80% threshold?
        3. Security: no hardcoded secrets, validated inputs, parameterized queries?
        4. Single responsibility: minimal changes for the task?
        5. Git discipline: atomic commits, clear messages?
        6. Documentation: ADR updated if architecture changed?

        Output format:
        - PASS / WARN / FAIL for each item
        - For WARN and FAIL: file:line and description
        - Summary: APPROVED / CHANGES REQUESTED
      " --output-format json > review.json
    - # Парсинг и пост комментария к MR
    - python scripts/post-review-comment.py review.json
  allow_failure: true
```

### GitHub Actions

```yaml
name: AI Code Review
on:
  pull_request:
    branches: [dev]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: AI Code Review
        run: |
          claude -p "
            You are a code reviewer. Review the diff for this PR.
            Run: git diff origin/dev...HEAD

            Review checklist:
            1. TDD: are there tests for all new functionality?
            2. Coverage: does the change maintain 80% threshold?
            3. Security: no hardcoded secrets, validated inputs, parameterized queries?
            4. Single responsibility: minimal changes for the task?
            5. Git discipline: atomic commits, clear messages?
            6. Documentation: ADR updated if architecture changed?

            Output as markdown comment.
          " --output-format text > review.md

      - name: Post review comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## AI Code Review\n\n${review}`
            });
```

---

## Автоисправление

Для автоматического исправления замечаний ИИ добавить второй шаг:

```bash
claude -p "
  Read review.json. Fix all WARN and FAIL items.
  Follow TDD: update tests first if needed.
  Run tests after fixing. Commit fixes as 'fix: address AI review feedback'.
" --allowedTools "Read,Edit,Bash(git diff *),Bash(git commit *),Bash(${PROJECT_TEST_CMD:-npm test} *)"
```

> Замените `${PROJECT_TEST_CMD}` на команду запуска тестов для вашего стека.

**Ограничения:**
- `--allowedTools` ограничивает разрешённые операции
- Автоисправление не заменяет ревью человека — финальное утверждение всегда за разработчиком
- При L3 проектах — использовать self-hosted CLI

---

## Метрики

Собирать с каждого AI review:
- Количество замечаний (PASS / WARN / FAIL)
- % MR прошедших без замечаний
- Среднее время AI review (для оценки стоимости)
- Стоимость в токенах на один review

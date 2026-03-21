# Приложение F — Корпоративное хранилище AI-конфигураций

**Репозиторий:** `company-ai-toolkit`
**Владелец:** Отдел по внедрению ИИ

---

## Структура хранилища

```
company-ai-toolkit/
├── README.md
├── registry.md                          # Реестр всех файлов с пометками обязательности
├── import.sh                            # Скрипт автоматического импорта в проект
│
├── skills/
│   ├── core/                            # Обязательные для всех проектов
│   │   ├── fix-issue/SKILL.md
│   │   ├── code-review/SKILL.md
│   │   └── security-review/SKILL.md
│   ├── backend/                         # Для backend-проектов
│   │   ├── api-design/SKILL.md
│   │   └── db-migration/SKILL.md
│   ├── frontend/                        # Для frontend-проектов
│   │   ├── component-review/SKILL.md
│   │   └── a11y-check/SKILL.md
│   └── devops/                          # Для инфраструктурных проектов
│       └── deploy/SKILL.md
│
├── agents/
│   ├── core/                            # Обязательные для всех проектов
│   │   ├── security-reviewer.md
│   │   └── code-reviewer.md
│   └── backend/
│       └── api-reviewer.md
│
├── hooks/
│   ├── core/                            # Обязательные для всех проектов
│   │   ├── lint-on-edit.json
│   │   ├── block-docs-write.json
│   │   └── test-after-impl.json
│   └── l3/                              # Дополнительные для L3 проектов
│       ├── block-external-requests.json
│       └── sast-on-commit.json
│
├── rules/
│   ├── core/                            # Обязательные для всех проектов
│   │   ├── security.md
│   │   └── testing.md
│   ├── backend/
│   │   └── api.md
│   ├── frontend/
│   │   └── components.md
│   └── l3/
│       └── restricted-security.md
│
└── mcp/
    ├── l1.mcp.json
    ├── l2.mcp.json
    └── l3.mcp.json
```

---

## Реестр файлов (registry.md)

Каждый файл помечен YAML-frontmatter:

```yaml
---
required-for:
  levels: [all]          # L1, L2, L3 или all
  types: [all]           # frontend, backend, fullstack, mobile, data, infra или all
description: "Краткое описание назначения"
---
```

### Обязательные Skills (core)

| Skill | Описание | Уровни | Типы проектов |
|-------|---------|--------|---------------|
| `/fix-issue` | Issue → анализ → fix → тесты → PR | all | all |
| `/code-review` | Code review по корпоративному чеклисту | all | all |
| `/security-review` | Проверка кода на OWASP уязвимости | all | all |

### Обязательные Subagents (core)

| Agent | Описание | Уровни | Типы проектов |
|-------|---------|--------|---------------|
| `security-reviewer` | Проверка инъекций, хардкод секретов, авторизации | all | all |
| `code-reviewer` | Проверка SRP, code quality, паттерны | all | all |

### Обязательные Hooks (core)

| Hook | Событие | Описание | Уровни | Типы проектов |
|------|---------|---------|--------|---------------|
| `lint-on-edit` | PostToolUse (Edit/Write) | Прогон линтера после каждого редактирования файла | all | all |
| `block-docs-write` | PreToolUse (Edit/Write) | Блокировка записи в `docs/` без явного одобрения | all | all |
| `test-after-impl` | PostToolUse (Edit/Write) | Прогон тестов после имплементации | all | all |

### Обязательные Hooks (L3)

| Hook | Событие | Описание | Уровни | Типы проектов |
|------|---------|---------|--------|---------------|
| `block-external-requests` | PreToolUse (Bash/Fetch) | Блокировка внешних сетевых запросов | L3 | all |
| `sast-on-commit` | PostToolUse (Bash: git commit) | SAST-сканирование при каждом коммите | L3 | all |

### Обязательные Rules (core)

| Rule | Paths | Описание | Уровни | Типы проектов |
|------|-------|---------|--------|---------------|
| `security.md` | все файлы | Базовые правила безопасности | all | all |
| `testing.md` | `**/*.test.*`, `**/*.spec.*` | Правила написания тестов | all | all |

---

## Содержание обязательных файлов

### Skill: `/fix-issue`

```markdown
---
name: fix-issue
description: Fix a task tracker issue following corporate standards
required-for:
  levels: [all]
  types: [all]
---
Analyze and fix the issue: $ARGUMENTS.

1. Use issue tracker to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files using subagents
4. Write failing tests based on the issue description (Red)
5. Implement the minimal fix to make tests pass (Green)
6. Refactor without breaking tests (Refactor)
7. Ensure code passes linting and type checking
8. Run full test suite
9. Create an atomic commit with a descriptive message
10. Push and create a PR with the issue reference
```

### Skill: `/code-review`

```markdown
---
name: code-review
description: Review code changes against corporate quality standards
required-for:
  levels: [all]
  types: [all]
---
Review the code changes: $ARGUMENTS.

Checklist:
1. TDD compliance: are there tests for all new functionality?
2. Coverage: does coverage meet the 80% threshold?
3. Single responsibility: does each function/class have one job?
4. No over-engineering: is the solution minimal for the task?
5. Security: no hardcoded secrets, validated inputs, parameterized queries?
6. Git discipline: atomic commits, clear messages?
7. Documentation: ADR updated if architecture changed?

Report findings as: PASS / WARN / FAIL for each item.
```

### Skill: `/security-review`

```markdown
---
name: security-review
description: Review code for security vulnerabilities (OWASP Top 10)
required-for:
  levels: [all]
  types: [all]
---
Review the code for security vulnerabilities: $ARGUMENTS.

Check for:
1. Injection (SQL, XSS, command injection, path traversal)
2. Broken authentication and session management
3. Sensitive data exposure (PII, secrets in logs or code)
4. Security misconfiguration
5. Insecure deserialization
6. Components with known vulnerabilities
7. Insufficient logging and monitoring

Provide specific file:line references and suggested fixes.
Severity levels: CRITICAL / HIGH / MEDIUM / LOW.
```

### Subagent: `security-reviewer`

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities in isolation
tools: Read, Grep, Glob, Bash
model: most-capable
required-for:
  levels: [all]
  types: [all]
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling
- OWASP Top 10 violations

Provide specific file:line references and suggested fixes.
```

### Subagent: `code-reviewer`

```markdown
---
name: code-reviewer
description: Reviews code quality, patterns, and compliance with standards
tools: Read, Grep, Glob
model: balanced
required-for:
  levels: [all]
  types: [all]
---
You are a senior code reviewer. Review for:
- Single responsibility principle violations
- Over-engineering and speculative abstractions
- Missing tests for new functionality
- Duplicated code that should be extracted
- Compliance with project architecture in docs/architecture/

Report as: PASS / WARN / FAIL with specific file:line references.
```

### Hook: `lint-on-edit`

Команда линтера зависит от стека проекта. Примеры:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "PROJECT_LINT_CMD=${AI_LINT_CMD:-npm run lint} && $PROJECT_LINT_CMD -- $AI_FILE_PATH 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

> Переменная окружения `AI_LINT_CMD` позволяет переопределить команду линтера под стек проекта:
> - JS/TS: `npm run lint` / `yarn lint` / `pnpm lint`
> - Python: `ruff check` / `flake8`
> - Go: `golangci-lint run`
> - Java: `./gradlew checkstyleMain`
>
> Установить в `.env` или CI-переменных проекта.

### Hook: `block-docs-write`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo $AI_FILE_PATH | grep -q '^docs/' && echo 'BLOCK: docs/ files require explicit human approval. Ask the user first.' && exit 1 || exit 0"
          }
        ]
      }
    ]
  }
}
```

### Hook: `test-after-impl`

Команда запуска тестов зависит от стека проекта. Примеры:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo $AI_FILE_PATH | grep -qv '\\.test\\.' && echo $AI_FILE_PATH | grep -qv '\\.spec\\.' && PROJECT_TEST_CMD=${AI_TEST_CMD:-npm test} && $PROJECT_TEST_CMD 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

> Переменная окружения `AI_TEST_CMD` позволяет переопределить команду тестов:
> - JS/TS: `npm test` / `yarn test` / `vitest run`
> - Python: `pytest`
> - Go: `go test ./...`
> - Java: `./gradlew test`
>
> Установить в `.env` или CI-переменных проекта.

### Rule: `security.md`

```markdown
---
required-for:
  levels: [all]
  types: [all]
---
# Security Rules

- Never hardcode credentials, API keys, tokens, or secrets
- All user inputs must be validated at system boundaries
- SQL and other queries must use parameterized statements only
- Never log sensitive data (passwords, tokens, PII)
- Use secure defaults: HTTPS, encrypted storage, minimal permissions
- Report any discovered vulnerability before proceeding with other work
```

### Rule: `testing.md`

```markdown
---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/__tests__/**"
required-for:
  levels: [all]
  types: [all]
---
# Testing Rules

- Follow TDD: failing test first, then implementation, then refactor
- Tests must be based on acceptance criteria from docs/qa/acceptance-criteria.md
- Each test must test one behaviour — no multi-assertion tests without clear reason
- Use descriptive test names: "should [expected behaviour] when [condition]"
- Prefer real implementations over mocks where feasible
- CRUD operations are excluded from 80% coverage threshold
- Clean up test data after each test run
```

---

## Версионирование хранилища

`company-ai-toolkit` использует **семантическое версионирование** (SemVer):

| Тип изменения | Версия | Примеры |
|---------------|--------|---------|
| Breaking change | `MAJOR` (1.x.x → 2.0.0) | Изменение формата hooks, удаление обязательного skill |
| Новый файл / расширение | `MINOR` (1.2.x → 1.3.0) | Новый skill, новый subagent |
| Исправление / уточнение | `PATCH` (1.2.3 → 1.2.4) | Правка в правиле, исправление команды в hook |

Каждый релиз тегируется в Git: `v1.3.0`. Поддерживается `CHANGELOG.md`.

**Правило:** проекты могут оставаться на любой версии, но **MAJOR-обновления обязательны** — срок миграции устанавливается отделом по внедрению ИИ.

---

## Подключение к проекту (Git Submodule)

### Первоначальная инициализация

Toolkit подключается как **git submodule** в директорию `.ai/toolkit`:

```bash
# 1. Добавить submodule (при инициализации проекта)
git submodule add https://git.company.internal/ai/company-ai-toolkit .ai/toolkit

# 2. Зафиксировать конкретную версию (тег)
cd .ai/toolkit
git checkout v1.3.0
cd ../..
git add .gitmodules .ai/toolkit
git commit -m "chore: add company-ai-toolkit v1.3.0 as submodule"

# 3. Запустить импорт — скопировать нужные файлы в .ai/
.ai/toolkit/import.sh --level L2 --type backend
git add .ai/
git commit -m "chore: import ai toolkit files for L2 backend"
```

После этого `.gitmodules` будет содержать:

```ini
[submodule ".ai/toolkit"]
    path = .ai/toolkit
    url = https://git.company.internal/ai/company-ai-toolkit
    branch = main
```

### Клонирование проекта (для новых участников)

```bash
git clone --recurse-submodules https://git.company.internal/team/project.git

# Или если клонировали без флага:
git submodule update --init --recursive
```

### Структура после инициализации

```
.ai/
├── toolkit/                     ← git submodule (company-ai-toolkit, зафиксирован на теге)
│   ├── skills/
│   ├── agents/
│   ├── hooks/
│   ├── rules/
│   ├── mcp/
│   ├── registry.md
│   └── import.sh
├── skills/                      ← скопированы import.sh из toolkit (под контролем проекта)
├── agents/
├── rules/
└── settings.json                ← hooks смерджены import.sh
```

> Файлы в `.ai/skills/`, `.ai/agents/`, `.ai/rules/` — **копии**, а не симлинки. Это обеспечивает работу на всех ОС включая Windows.

---

## Обновление toolkit в проекте

### Ручное обновление (рекомендуется для MAJOR)

```bash
# 1. Обновить submodule до новой версии
cd .ai/toolkit
git fetch --tags
git checkout v2.0.0          # или конкретный тег
cd ../..

# 2. Запустить импорт для применения изменений
.ai/toolkit/import.sh --level L2 --type backend --update

# 3. Проверить diff — особенно важно при MAJOR
git diff .ai/

# 4. Зафиксировать обновление
git add .ai/
git commit -m "chore: update ai toolkit to v2.0.0

Breaking changes: <описать что изменилось>"
```

### Автоматическое обновление через CI (для MINOR и PATCH)

CI-задача запускается по расписанию (раз в неделю) и создаёт MR при наличии новых MINOR/PATCH версий:

#### GitLab CI

```yaml
update-ai-toolkit:
  stage: maintenance
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  script:
    - cd .ai/toolkit && git fetch --tags
    - CURRENT=$(git describe --tags)
    - LATEST=$(git tag --sort=-v:refname | grep -v "^v[0-9]*\.0\.0$" | head -1)
    - |
      if [ "$CURRENT" != "$LATEST" ]; then
        git checkout $LATEST
        cd ../..
        .ai/toolkit/import.sh --level $PROJECT_LEVEL --type $PROJECT_TYPE --update
        git config user.email "ci@company.internal"
        git config user.name "AI Toolkit Bot"
        git checkout -b "chore/update-ai-toolkit-$LATEST"
        git add .ai/
        git commit -m "chore: update ai toolkit to $LATEST"
        git push origin "chore/update-ai-toolkit-$LATEST"
        # Создать MR через API
        curl -X POST "$CI_API_V4_URL/projects/$CI_PROJECT_ID/merge_requests" \
          -H "PRIVATE-TOKEN: $BOT_TOKEN" \
          -d "source_branch=chore/update-ai-toolkit-$LATEST&target_branch=dev&title=chore: update ai toolkit to $LATEST"
      fi
  variables:
    PROJECT_LEVEL: "L2"     # переопределить в настройках проекта
    PROJECT_TYPE: "backend"  # переопределить в настройках проекта
```

#### GitHub Actions

```yaml
name: Update AI Toolkit
on:
  schedule:
    - cron: '0 9 * * 1'  # каждый понедельник в 9:00

jobs:
  update-toolkit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
          token: ${{ secrets.BOT_TOKEN }}

      - name: Check for toolkit updates
        run: |
          cd .ai/toolkit
          git fetch --tags
          CURRENT=$(git describe --tags)
          LATEST=$(git tag --sort=-v:refname | grep -v "^v[0-9]*\.0\.0$" | head -1)
          echo "CURRENT=$CURRENT" >> $GITHUB_ENV
          echo "LATEST=$LATEST" >> $GITHUB_ENV

      - name: Apply update if available
        if: env.CURRENT != env.LATEST
        run: |
          cd .ai/toolkit && git checkout ${{ env.LATEST }} && cd ../..
          .ai/toolkit/import.sh --level ${{ vars.PROJECT_LEVEL }} --type ${{ vars.PROJECT_TYPE }} --update

      - name: Create Pull Request
        if: env.CURRENT != env.LATEST
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.BOT_TOKEN }}
          branch: chore/update-ai-toolkit-${{ env.LATEST }}
          base: dev
          title: "chore: update ai toolkit to ${{ env.LATEST }}"
          body: |
            Automatic update of company-ai-toolkit from ${{ env.CURRENT }} to ${{ env.LATEST }}.
            Review the diff in .ai/ before merging.
```

---

## Импорт в проект

### Автоматический (рекомендуемый)

```bash
# Из корня проекта — после добавления submodule
.ai/toolkit/import.sh --level L2 --type backend
```

Скрипт:
1. Читает `registry.md`
2. Фильтрует файлы по уровню и типу проекта
3. Копирует обязательные файлы в `.ai/` проекта
4. Генерирует `.mcp.json` по уровню
5. Смерджирует hooks в `.ai/settings.json`
6. Выводит список импортированных и пропущенных файлов

### Ручной

1. Скопировать файлы из `core/` в `.ai/` проекта
2. Скопировать файлы специфичные для типа проекта
3. Для L3 — добавить файлы из `l3/`
4. Смержить hooks в `.ai/settings.json`
5. Скопировать `.mcp.json` по уровню

---

## Особенности для L3 проектов

L3-проекты не имеют доступа к внешним сетям. Для них:

1. Отдел по внедрению ИИ поддерживает **self-hosted зеркало** `company-ai-toolkit` внутри периметра
2. URL submodule указывает на внутренний сервер: `https://git.company.internal/ai/company-ai-toolkit`
3. CI-автоматизация обновлений работает аналогично, но через внутренний CI
4. MAJOR-обновления проходят дополнительную проверку службой безопасности перед публикацией в зеркало

---

## Политика обновлений

| Тип | Применение | Срок |
|-----|-----------|------|
| PATCH | Автоматический MR от бота, merge без блокеров | В течение недели |
| MINOR | Автоматический MR от бота, ревью разработчика | В течение спринта |
| MAJOR | Ручное обновление, ревью команды + архитектора | Срок устанавливает отдел по внедрению ИИ |

> Отдел по внедрению ИИ публикует release notes в корпоративной базе знаний при каждом релизе toolkit'а. MAJOR-релизы сопровождаются migration guide.

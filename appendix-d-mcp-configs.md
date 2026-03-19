# Приложение D — Шаблоны .mcp.json по уровням проекта

Файл `.mcp.json` размещается в корне каждого проекта.
Конфигурация зависит от уровня проекта (см. раздел 2 стандарта).

**Принципы выбора MCP-серверов:**
- Каждый сервер должен экономить контекстное окно, а не засорять его
- Предпочитать MCP-серверы, которые возвращают точечные данные (context7, serena), а не сырые массивы (fetch)
- Не подключать серверы, дублирующие встроенные возможности модели

---

## L1 — Public / Internal

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    },
    "atlassian": {
      "type": "url",
      "url": "https://mcp.atlassian.com/v1/mcp"
    },
    "serena": {
      "command": "uvx",
      "args": ["serena"]
    }
  }
}
```

> **Atlassian MCP** покрывает и Jira, и Confluence через единый облачный endpoint. Аутентификация — OAuth 2.1 (браузерный consent flow) или API token (для CI/headless-сценариев, требует активации администратором организации).

---

## L2 — Confidential

Отличия от L1: добавлен `postgres` для работы с корпоративными данными через контролируемый интерфейс.

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    },
    "atlassian": {
      "type": "url",
      "url": "https://mcp.atlassian.com/v1/mcp"
    },
    "serena": {
      "command": "uvx",
      "args": ["serena"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "${POSTGRES_CONNECTION_STRING}"
      }
    }
  }
}
```

---

## L3 — Restricted

Отличия от L2:
- `context7` **отключён** — запрещены внешние сетевые запросы из ИИ-инструмента
- `atlassian` **отключён** — облачный endpoint запрещён для L3
- Вместо `atlassian` подключаются self-hosted MCP-серверы для Jira и Confluence
- Все инструменты должны быть развёрнуты внутри периметра компании

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    },
    "jira": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-jira"],
      "env": {
        "JIRA_BASE_URL": "${JIRA_INTERNAL_URL}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}",
        "JIRA_USER_EMAIL": "${JIRA_USER_EMAIL}"
      }
    },
    "confluence": {
      "command": "npx",
      "args": ["-y", "mcp-confluence"],
      "env": {
        "CONFLUENCE_BASE_URL": "${CONFLUENCE_INTERNAL_URL}",
        "CONFLUENCE_TOKEN": "${CONFLUENCE_TOKEN}"
      }
    },
    "serena": {
      "command": "uvx",
      "args": ["serena"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "${POSTGRES_CONNECTION_STRING}"
      }
    }
  }
}
```

> **L3:** Конкретные MCP-серверы для self-hosted Jira и Confluence определяются отделом безопасности. Пакеты в примере выше — placeholder, заменить на утверждённые внутренние аналоги.

> Все переменные окружения (`${...}`) задаются через корпоративное хранилище секретов. Никаких значений в `.mcp.json` напрямую.

---

## Сравнительная таблица

### Обязательные MCP-серверы

| MCP-сервер | L1 | L2 | L3 | Назначение | Влияние на контекст |
|------------|----|----|-----|-----------|-------------------|
| memory | + | + | + | Персистентная память между сессиями | Минимальное — key-value хранилище |
| context7 | + | + | — | Документация библиотек без засорения контекста | Экономит — точечные фрагменты вместо полной доки |
| git | + | + | + | Структурированные git-операции (diff, log, branch) | Экономит — точечные данные вместо сырого вывода терминала |
| atlassian | + | + | — | Jira + Confluence через единый облачный endpoint | Минимальное — структурированные запросы |
| jira (self-hosted) | — | — | + | Issue Lifecycle для L3 (self-hosted Jira) | Минимальное |
| confluence (self-hosted) | — | — | + | Синхронизация docs/ для L3 (self-hosted Confluence) | Минимальное |
| serena | + | + | + | Семантическая навигация по коду (go to definition, find references) | Экономит — точечная навигация вместо чтения целых файлов |

### Опциональные MCP-серверы

| MCP-сервер | L1 | L2 | L3 | Назначение | Когда подключать |
|------------|----|----|-----|-----------|-----------------|
| fetch | + | + | — | Загрузка внешних ресурсов и API | Когда нужен доступ к внешним URL (документация, API specs) |
| postgres | — | + | + | Доступ к БД через контролируемый интерфейс | Когда проект работает с PostgreSQL |

### Удалённые MCP-серверы (не рекомендуются)

| MCP-сервер | Причина удаления |
|------------|-----------------|
| sequential-thinking | Дублирует native extended thinking в Claude 4.x. Каждая «мысль» — это tool call с input/output, что тратит токены и засоряет контекст. Встроенное мышление модели эффективнее. |
| time | Claude получает текущую дату/время из system prompt. MCP-сервер не даёт дополнительной ценности для задач разработки. |

# Приложение D — Шаблоны .mcp.json по уровням проекта

Файл `.mcp.json` размещается в корне каждого проекта.
Конфигурация зависит от уровня проекта (см. раздел 2 стандарта).

> **MCP (Model Context Protocol)** — открытый протокол для подключения ИИ-агентов к внешним инструментам и источникам данных. Конкретные MCP-серверы выбираются исходя из инструментов, принятых в компании. Примеры ниже — референсная конфигурация.

**Принципы выбора MCP-серверов:**
- Каждый сервер должен экономить контекстное окно, а не засорять его
- Предпочитать MCP-серверы, которые возвращают точечные данные, а не сырые массивы
- Не подключать серверы, дублирующие встроенные возможности модели

---

## Обязательные категории MCP-серверов

Независимо от конкретных продуктов, каждый проект должен иметь MCP-серверы следующих категорий:

| Категория | Назначение | L1 | L2 | L3 | Примеры реализаций |
|-----------|-----------|----|----|----|--------------------|
| **Память** | Персистентный контекст между сессиями | + | + | + | @modelcontextprotocol/server-memory |
| **Документация библиотек** | Точечный доступ к документации без засорения контекста | + | + | -- | context7, devdocs |
| **Git** | Структурированные git-операции (diff, log, branch) | + | + | + | mcp-server-git |
| **Трекер задач** | Управление задачами, issue lifecycle | + | + | + | Atlassian MCP, Linear MCP, self-hosted |
| **База знаний** | Синхронизация docs/ с корпоративной wiki | + | + | + | Atlassian MCP, Notion MCP, self-hosted |
| **Навигация по коду** | Семантическая навигация (go to definition, find references) | + | + | + | serena, sourcegraph |

> Для L3 все MCP-серверы должны быть развёрнуты внутри периметра компании. Облачные endpoint'ы запрещены.

### Опциональные категории

| Категория | Назначение | L1 | L2 | L3 | Примеры реализаций |
|-----------|-----------|----|----|----|--------------------|
| **HTTP-клиент** | Загрузка внешних ресурсов и API | + | + | -- | fetch |
| **БД** | Доступ к базе данных через контролируемый интерфейс | -- | + | + | server-postgres, server-mysql |

---

## Референсные конфигурации

### L1 — Public / Internal

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
    "task-tracker": {
      "type": "url",
      "url": "${TASK_TRACKER_MCP_URL}"
    },
    "knowledge-base": {
      "type": "url",
      "url": "${KNOWLEDGE_BASE_MCP_URL}"
    },
    "code-navigation": {
      "command": "uvx",
      "args": ["serena"]
    }
  }
}
```

> Для Atlassian-стека: единый MCP endpoint `https://mcp.atlassian.com/v1/mcp` покрывает и трекер задач (Jira), и базу знаний (Confluence). Аутентификация — OAuth 2.1 или API token.

---

### L2 — Confidential

Отличия от L1: добавлен MCP для работы с БД через контролируемый интерфейс.

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
    "task-tracker": {
      "type": "url",
      "url": "${TASK_TRACKER_MCP_URL}"
    },
    "knowledge-base": {
      "type": "url",
      "url": "${KNOWLEDGE_BASE_MCP_URL}"
    },
    "code-navigation": {
      "command": "uvx",
      "args": ["serena"]
    },
    "database": {
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

### L3 — Restricted

Отличия от L2:
- **Документация библиотек** отключена — запрещены внешние сетевые запросы
- Все MCP-серверы — **self-hosted** внутри периметра компании
- Трекер задач и база знаний подключаются через внутренние endpoint'ы

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
    "task-tracker": {
      "command": "npx",
      "args": ["-y", "${TASK_TRACKER_MCP_PACKAGE}"],
      "env": {
        "TRACKER_BASE_URL": "${TRACKER_INTERNAL_URL}",
        "TRACKER_API_TOKEN": "${TRACKER_API_TOKEN}"
      }
    },
    "knowledge-base": {
      "command": "npx",
      "args": ["-y", "${KNOWLEDGE_BASE_MCP_PACKAGE}"],
      "env": {
        "KB_BASE_URL": "${KB_INTERNAL_URL}",
        "KB_TOKEN": "${KB_TOKEN}"
      }
    },
    "code-navigation": {
      "command": "uvx",
      "args": ["serena"]
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "${POSTGRES_CONNECTION_STRING}"
      }
    }
  }
}
```

> **L3:** Конкретные MCP-пакеты для self-hosted трекера и базы знаний определяются отделом безопасности. Пакеты в примере выше — placeholder.

> Все переменные окружения (`${...}`) задаются через корпоративное хранилище секретов. Никаких значений в `.mcp.json` напрямую.


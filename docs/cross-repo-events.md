# Межрепозиторные события

Автоматизация между PDE, ASE и QSRE сначала создаёт уведомление. Она не заменяет человеческое решение.

## Разрешённые события

```text
PDE Ready            → Issue в ASE
ASE Evidence Ready   → Issue в QSRE
QSRE Feedback        → Issue в PDE
```

Машиночитаемый контракт: [`contracts/cross-repo-event.schema.json`](../contracts/cross-repo-event.schema.json). Пример: [`contracts/examples/cross-repo-event.example.json`](../contracts/examples/cross-repo-event.example.json).

## Что автоматизация может и не может

Разрешено:

- создать Issue в целевой среде;
- приложить полный source SHA, путь артефакта и идентификатор Outcome;
- запросить действие человека.

Запрещено:

- объединять Pull Request;
- менять Pack, AC, NFR или scope;
- принимать Ready, ACK или release decision;
- обновлять pin `engineering-control`;
- использовать `repository_dispatch` с правом `contents: write`.

`repository_dispatch` намеренно не включён: GitHub требует `contents: write` на целевой репозиторий, а это уже позволяет менять файлы. Пока событием считается структурированный Issue.

## Порядок включения

1. Проверить ручной процесс handoff без автоматизации.
2. Подключить GitHub App по [github-app.md](github-app.md).
3. Запускать notify-workflow только через `workflow_dispatch`.
4. После нескольких успешных ручных циклов можно добавить path-фильтр. Автоматический merge по-прежнему запрещён.

Секреты хранятся только в GitHub Secrets / GitHub Environments исходной среды. В Git их нет.

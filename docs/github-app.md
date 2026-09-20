# Ограниченный GitHub App

Автоматический доступ между средами выдаётся **тремя отдельными GitHub App**, а не одним глобальным токеном. Каждое приложение устанавливается только на целевую среду и хранит секреты только в исходной среде.

## Приложения

| App | Где установлен | Откуда вызывается | Права на цель | Секреты |
| --- | --- | --- | --- | --- |
| `pde-to-ase-notify` | `ase-environment` | PDE Environment `notify-ase` | `issues: write`, `metadata: read` | `ASE_NOTIFY_APP_ID`, `ASE_NOTIFY_APP_PRIVATE_KEY` |
| `ase-to-qsre-notify` | `qsre-environment` | ASE Environment `notify-qsre` | `issues: write`, `metadata: read` | `QSRE_NOTIFY_APP_ID`, `QSRE_NOTIFY_APP_PRIVATE_KEY` |
| `qsre-to-pde-notify` | `pde-environment` | QSRE Environment `notify-pde` | `issues: write`, `metadata: read` | `PDE_NOTIFY_APP_ID`, `PDE_NOTIFY_APP_PRIVATE_KEY` |

`engineering-control` приложением не устанавливается, пока не потребуется отдельная read-only проверка совместимости. Для validate-* callers достаточно `GITHUB_TOKEN` с `contents: read`.

## Что не выдавать

- `contents: write`;
- `pull_requests: write`;
- `administration`;
- `workflows`;
- доступ сразу ко всем четырём репозиториям одним ключом;
- personal access token пользователя;
- секреты в файлах Git.

## Создание App

1. GitHub → Settings → Developer settings → GitHub Apps → New GitHub App.
2. Задайте имя из таблицы, Homepage URL репозитория `engineering-control`.
3. Webhook отключите.
4. Repository permissions: Metadata Read, Issues Write. Остальное — No access.
5. Where can this App be installed: Only on this account.
6. Создайте App, сохраните App ID, сгенерируйте private key. Ключ в Git не кладётся.
7. Install App **только** на целевой репозиторий.
8. В исходном репозитории создайте GitHub Environment (`notify-ase`, `notify-qsre` или `notify-pde`) и положите туда App ID и private key.

После установки проверьте, что токен создаётся только для одного `repositories:` значения. Если установка видна на лишнем репозитории — удалите её.

Подробности вызова: [reusable-workflows.md](reusable-workflows.md) и [cross-repo-events.md](cross-repo-events.md).

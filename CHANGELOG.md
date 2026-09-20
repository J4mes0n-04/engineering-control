# История изменений

## 1.0.0-rc.2 — Unreleased

- Добавлены reusable workflows `validate-pde.yml`, `validate-ase.yml`, `validate-qsre.yml` и `notify-peer.yml`.
- Добавлен draft-контракт межрепозиторного уведомления `cross-repo-event`.
- Автоматизация между средами ограничена созданием Issue; merge, изменение Pack и Ready-решение запрещены.
- Документированы три ограниченных GitHub App и хранение секретов только в GitHub Environments.

Версия не выпускается, пока изменение не прошло Pull Request. Среды не должны вызывать новые workflows по SHA `v1.0.0-rc.1`. Репозиторий остаётся `staging` и `authoritative: false`.

## 1.0.0-rc.1 — 2026-09-20

- Подготовлен staging snapshot нормативной основы PDE.
- Добавлена Pack Schema и общие contract templates.
- Формализованы контракты PDE → ASE, ASE → QSRE и QSRE → PDE версии 1.0.0.
- Добавлены матрица совместимости, примеры и локальные validators.
- Добавлены GitHub Actions, CODEOWNERS и change control для Pull Request.

Версия опубликована как предварительный release candidate для подключения сред в shadow mode. Репозиторий остаётся `staging`, `authoritative: false`, а контракты — `draft` до успешного сквозного пилота и отдельного решения о production cutover.

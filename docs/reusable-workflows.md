# Reusable workflows

Общие GitHub Actions workflows живут в этом репозитории и вызываются средами **только по tag или полному commit SHA**. Вызов с плавающей ветки `main` запрещён.

Канонические интерфейсы:

```text
uses: J4mes0n-04/engineering-control/.github/workflows/validate-pde.yml@<SHA>
uses: J4mes0n-04/engineering-control/.github/workflows/validate-ase.yml@<SHA>
uses: J4mes0n-04/engineering-control/.github/workflows/validate-qsre.yml@<SHA>
uses: J4mes0n-04/engineering-control/.github/workflows/notify-peer.yml@<SHA>
```

`<SHA>` — полный 40-символьный commit, в котором эти файлы уже существуют. Текущий pin сред `v1.0.0-rc.1` / `abd0982171341438cab80267099b951a2027be0b` этих workflows ещё не содержит. Подключать callers в PDE, ASE и QSRE можно только после merge этого изменения и отдельного обновления pin, например будущим `v1.0.0-rc.2`.

Если репозитории приватные, в `engineering-control` нужно разрешить Actions access для вызывающих репозиториев: Settings → Actions → General → Access. Без этого `uses:` не найдёт workflow.

## Что проверяют validate-* workflows

Reusable workflow проверяет **вызывающий** репозиторий: выполняет его `scripts/doctor.ps1` и `scripts/validate-repository.ps1`. Скрипты не копируются в `engineering-control`. Pack, Evidence и governance-change PDE остаются локальными workflow до конца shadow-периода.

Текущие workflow в PDE/ASE/QSRE не удаляются. Новые callers добавляются рядом и сначала работают как дополнительная проверка.

## Уведомления

`notify-peer.yml` создаёт Issue в целевой среде. Он не объединяет Pull Request, не меняет Pack и не принимает Ready-решение. Разрешённые маршруты:

| event_type | Цель |
| --- | --- |
| `pde-ready` | `J4mes0n-04/ase-environment` |
| `ase-evidence-ready` | `J4mes0n-04/qsre-environment` |
| `qsre-feedback` | `J4mes0n-04/pde-environment` или `J4mes0n-04/PDE_ENVIRONMENT` |

Примеры callers: [examples/environment-callers/README.md](../examples/environment-callers/README.md). Ограниченный GitHub App: [github-app.md](github-app.md). Контракт события: [cross-repo-events.md](cross-repo-events.md).

## Права

Caller задаёт `permissions.contents: read`. Запись в целевой репозиторий идёт только через GitHub App token с правом `issues: write` на одну целевую среду. Глобальный токен на все репозитории не используется.

# engineering-control

Защищённая общая нормативная основа для сред PDE, ASE и QSRE.

Репозиторий синхронизирован с https://github.com/J4mes0n-04/engineering-control.git. Он не содержит рабочие проекты, Pack конкретных Outcomes, код продуктов или локальное состояние OpenSpace.

## Статус

| Поле | Значение |
| --- | --- |
| `status` | `staging` |
| `authoritative` | `false` |
| Источник истины | `governance/` в репозитории PDE (`pde-environment`) |

Пока snapshot не утверждён, нормы PDE не заменяются этой копией. Происхождение зафиксировано в `source-baseline.yaml`.

## Содержимое

Скопировано из PDE baseline `pde-baseline-v0.1.0` без изменения содержания:

- `governance/**` — полный нормативный контур PDE
- `schemas/pack.schema.json` — контракт Pack
- `templates/ase-handoff.md`
- `templates/qsre-feedback.md`
- `templates/evidence-bundle.md`
- `templates/definition-change.md`
- `templates/decision-log.md`
- `templates/outcome-check.md`
- `templates/release-plan.md`
- `integrations/redmine/field-mapping.yaml` — reference dependency нормативного Redmine workflow
- `.editorconfig`

Дополнительно подготовлены draft-контракты обмена в `contracts/`, нейтральные примеры, матрица совместимости, reusable GitHub Actions workflows и локальная проверка `scripts/validate-contracts.ps1`.

## Проверка репозитория

Перед Pull Request выполните:

```powershell
pwsh ./scripts/validate-control.ps1
```

GitHub Actions запускает ту же проверку для Pull Request и `main`. Изменения governance, contracts, schemas, templates, shared skills, docs и CI требуют содержательных полей `Reason:` и `Governance impact:` в описании Pull Request.

Reusable workflows для PDE, ASE и QSRE описаны в [`docs/reusable-workflows.md`](docs/reusable-workflows.md). Среды вызывают их только по tag или полному SHA после отдельного обновления pin. Текущий `v1.0.0-rc.1` этих workflows ещё не содержит.

PDE-specific templates (`pack-mini.md`, `pack-full.md`, `pack.json`, `redmine-outcome.md`) не переносились.

## Что намеренно отсутствует

- `workspaces/` и конкретные Outcomes;
- PDE-specific agent rules и skills;
- локальные конфигурации Cursor, Codex и OpenSpace;
- готовые среды ASE и QSRE как содержимое этого репозитория;
- автоматический merge, изменение Pack и Ready-решения.

## Правила работы

1. Пока `authoritative: false`, snapshot нельзя использовать как замену действующему `governance/` PDE.
2. Нормативные изменения проходят отдельный Pull Request и одобрение человека.
3. OpenSpace и другие агенты не изменяют `governance/` автоматически.
4. Среды ссылаются на утверждённую версию по tag и полному commit SHA.
5. Переключение источника истины выполняется только после проверки совместимости и shadow-периода.
6. Межрепозиторная автоматизация создаёт только Issue. Она не объединяет Pull Request, не меняет Pack и не принимает решения за человека.

Происхождение и состав копии зафиксированы в [`source-baseline.yaml`](source-baseline.yaml).

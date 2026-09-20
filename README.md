# engineering-control

Общая нормативная основа engineering control.

Репозиторий синхронизирован с https://github.com/J4mes0n-04/engineering-control.git.

## Статус

| Поле | Значение |
| --- | --- |
| `status` | `staging` |
| `authoritative` | `false` |
| Источник истины | `governance/` в репозитории PDE (`PDE_ENVIRONMENT`) |

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
- `.editorconfig`

PDE-specific templates (`pack-mini.md`, `pack-full.md`, `pack.json`, `redmine-outcome.md`) не переносились.

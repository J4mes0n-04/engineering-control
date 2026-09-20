# Примеры callers для рабочих сред

Эти файлы **не являются** действующими GitHub Actions этого репозитория. Их копируют в `.github/workflows/` PDE, ASE или QSRE **после** merge reusable workflows в `engineering-control` и появления полного SHA.

До замены `PIN_SHA` на реальный 40-символьный commit caller запускать нельзя: GitHub не найдёт workflow в `v1.0.0-rc.1`.

Текущие локальные `validate-*.yml` в средах сохраняются до конца shadow-периода. Caller — дополнительная проверка, а не замена.

| Файл | Куда копировать | Назначение |
| --- | --- | --- |
| `pde-call-validate.yml` | PDE `.github/workflows/` | Вызов `validate-pde.yml` |
| `ase-call-validate.yml` | ASE `.github/workflows/` | Вызов `validate-ase.yml` |
| `qsre-call-validate.yml` | QSRE `.github/workflows/` | Вызов `validate-qsre.yml` |
| `pde-notify-ase.yml` | PDE `.github/workflows/` | `pde-ready` после появления SHA |
| `ase-notify-qsre.yml` | ASE `.github/workflows/` | `ase-evidence-ready` после появления SHA |
| `qsre-notify-pde.yml` | QSRE `.github/workflows/` | `qsre-feedback` после появления SHA |

Пока pin не обновлён, среды используют локальные `workflow_dispatch` notify/listen workflows без `uses:`. Документация App: [../../docs/github-app.md](../../docs/github-app.md).

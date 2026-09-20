# Контракты сред

Каталог предназначен для версионируемых машиночитаемых контрактов обмена между PDE, ASE и QSRE.

Текущий состав:

```text
contracts/
├── pde-to-ase.schema.json
├── ase-to-qsre.schema.json
├── qsre-to-pde.schema.json
├── compatibility.yaml
└── examples/
```

На текущем этапе нормативное описание передачи находится в `governance/19-ase-qsre-interface-contract.md`, а общие Markdown templates — в `templates/`.

Все три контракта имеют версию `1.0.0`, запрещают неизвестные корневые поля и требуют immutable references с полным commit SHA. Примеры содержат русский человекочитаемый текст и нейтральные технические identifiers.

`compatibility.yaml` фиксирует, какая среда создаёт и потребляет контракт. Статусы ASE и QSRE остаются `not-deployed`; наличие Schema не означает, что эти среды уже подключены.

Проверка:

```powershell
pwsh ./scripts/validate-contracts.ps1
```

До отдельного утверждения контракты имеют статус `draft`, а весь репозиторий остаётся `staging` и `authoritative: false`.

# Контракты сред

Каталог предназначен для версионируемых машиночитаемых контрактов обмена между PDE, ASE и QSRE.

Планируемый состав:

```text
contracts/
├── pde-to-ase.schema.json
├── ase-to-qsre.schema.json
├── qsre-to-pde.schema.json
└── compatibility.yaml
```

На текущем этапе нормативное описание передачи находится в `governance/19-ase-qsre-interface-contract.md`, а общие Markdown templates — в `templates/`.

JSON Schema не создаются формально до согласования обязательных полей и правил версионирования. Пустой каталог контрактов не означает, что отдельные ASE и QSRE среды уже подключены.

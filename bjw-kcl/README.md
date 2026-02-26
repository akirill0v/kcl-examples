# bjw-kcl

`bjw-kcl` — KCL library-style module для генерации универсальных Kubernetes-манифестов в духе `bjw-s` common chart.

## Что поддержано в v0

- Controllers: `Deployment`, `StatefulSet`
- Multi-controller приложения
- Services c привязкой к controller
- Ingress (rules + tls)
- Persistence: `pvc`, `emptyDir`, `configMap`, `secret`
- `globalMounts` и `advancedMounts`
- Naming policy: `forceRename`, `prefix`, `suffix`
- Default options + стратегии `overwrite|merge` для контейнеров

## Структура

- `modules/common/schemas/*` — типы и валидации входного контракта
- `modules/common/render/resources.k` — placeholder для будущего split рендера
- `modules/common/core.k` — композиция входного контракта
- `main.k` — entrypoint и рендер Kubernetes ресурсов через `k8s` модуль

## Запуск

```bash
kcl run . -D "app=$(yq -c '.app' values.yaml)"
```

`k8s` dependency обязательна и подключается через `kcl.mod`.

## Контракт (сокращенно)

Корневой объект: `app`

- `name`, `namespace`
- `controllers[]`
- `service[]`
- `ingress[]`
- `persistence[]`
- `defaultContainerOptions`, `defaultPodOptions`
- `strategy.container` = `overwrite|merge`
- `naming.forceRename|prefix|suffix`

См. примеры:

- `values.yaml`
- `examples/multi-controller-values.yaml`
- `examples/stateful-values.yaml`

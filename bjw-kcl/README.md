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
- `modules/common/core.k` — композиция входного контракта
- `modules/common/render/input.k` — общий render context
- `modules/common/render/deployments.k` — рендер `Deployment`
- `modules/common/render/statefulsets.k` — рендер `StatefulSet`
- `modules/common/render/services.k` — рендер `Service`
- `modules/common/render/ingresses.k` — рендер `Ingress`
- `modules/common/render/pvcs.k` — рендер `PersistentVolumeClaim`
- `main.k` — подготовка контекста + default Kubernetes render
- `renderer/kubernetes.k` — явный Kubernetes renderer entrypoint
- `renderer/compose.k` — Docker Compose renderer entrypoint

## Запуск

```bash
# default (Kubernetes)
kcl run . -D "app=$(yq -c '.app' values.yaml)"

# explicit Kubernetes renderer
kcl run . -D "app=$(yq -c '.app' values.yaml)" ./renderer/kubernetes.k

# Docker Compose renderer
kcl run . -D "app=$(yq -c '.app' values.yaml)" ./renderer/compose.k
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

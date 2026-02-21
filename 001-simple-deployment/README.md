# 001-simple-deployment

Простой пример KCL-манифестов для Kubernetes с зависимостью `k8s = "1.32.4"`:

- `ConfigMap` с конфигом Nginx
- `Deployment` c Nginx, который монтирует конфиг из `ConfigMap`
- `Service` для доступа к Deployment

## Файлы

- `kcl.mod` — пакет и зависимости
- `main.k` — описание ресурсов
- `values.debug.yaml` — settings-файл для передачи overrides в `kcl run -Y`

## Запуск

```bash
kcl run .
```

## Переопределение параметров

В `main.k` поддерживается входной параметр `server` со структурой:

```yaml
image:
  tag: v0.1.1
listen:
  port: 443
```

По умолчанию используются:
- `image.tag = 1.27`
- `listen.port = 80`

Зафиксированный запуск с файлом значений:

```bash
kcl run . -D "server=$(yq -c '.server' values.yaml)"
```

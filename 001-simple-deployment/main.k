import k8s.api.apps.v1 as apps
import k8s.api.core.v1 as core

_name = "nginx"
_namespace = "default"
_app_labels = {
    "app": _name
}

schema ImageConfig:
    tag: str = "1.27"

schema ListenConfig:
    port: int = 80

schema ServerConfig:
    image: ImageConfig = {}
    listen: ListenConfig = {}

_cfg = ServerConfig {**(option("server") or {})}
_image = "nginx:${_cfg.image.tag}"
_port = _cfg.listen.port

_config = core.ConfigMap {
    metadata.name = "${_name}-config"
    metadata.namespace = _namespace
    data = {
        "default.conf": '''
server {
  listen ${_port};
  server_name _;

  location / {
    add_header Content-Type text/plain;
    return 200 'hello from nginx + configmap';
  }
}
'''
    }
}

_deployment = apps.Deployment {
    metadata.name = _name
    metadata.namespace = _namespace
    spec.replicas = 1
    spec.selector.matchLabels = _app_labels
    spec.template.metadata.labels = _app_labels
    spec.template.spec.containers = [
        {
            name = _name
            image = _image
            ports = [
                {
                    containerPort = _port
                }
            ]
            volumeMounts = [
                {
                    name = "nginx-config"
                    mountPath = "/etc/nginx/conf.d/default.conf"
                    subPath = "default.conf"
                }
            ]
        }
    ]
    spec.template.spec.volumes = [
        {
            name = "nginx-config"
            configMap = {
                name = _config.metadata.name
            }
        }
    ]
}

_service = core.Service {
    metadata.name = _name
    metadata.namespace = _namespace
    spec.selector = _app_labels
    spec.ports = [
        {
            port = _port
            targetPort = _port
            protocol = "TCP"
        }
    ]
    spec.type = "ClusterIP"
}

[
    _config
    _deployment
    _service
]

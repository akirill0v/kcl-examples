import k8s.api.apps.v1 as apps
import k8s.api.core.v1 as core
import k8s.api.networking.v1 as netv1
import modules.common.core as common

_spec = common.AppSpec {**(option("app") or {})}

_full_name = _spec.naming.forceRename if _spec.naming.forceRename != "" else "${_spec.naming.prefix}${_spec.name}${_spec.naming.suffix}"
_base_labels = {
    "app.kubernetes.io/name": _spec.name
    "app.kubernetes.io/managed-by": "kcl"
}
_labels = _base_labels | _spec.labels
_default_env = _spec.defaultContainerOptions.env or {}
_default_command = _spec.defaultContainerOptions.command or []
_default_args = _spec.defaultContainerOptions.args or []
_pod_annotations = _spec.defaultPodOptions.annotations or {}
_container_strategy = _spec.strategy.container or "overwrite"
_persistence = _spec.persistence if _spec.persistence != Undefined else []
_services_input = _spec.service if _spec.service != Undefined else []
_ingress_input = _spec.ingress if _spec.ingress != Undefined else []

_volumes = [{
    "name": p.name
    "emptyDir": {}
} if p.type == "emptyDir" else {
    "name": p.name
    "configMap": {
        "name": p.configMapName
    }
} if p.type == "configMap" else {
    "name": p.name
    "secret": {
        "secretName": p.secretName
    }
} if p.type == "secret" else {
    "name": p.name
    "persistentVolumeClaim": {
        "claimName": p.name
    }
} for p in _persistence]

_deployments = [apps.Deployment {
    metadata.name = "${_full_name}-${c.name}"
    metadata.namespace = _spec.namespace
    metadata.labels = _labels | {"app.kubernetes.io/controller": c.name} | c.labels
    metadata.annotations = c.annotations
    spec.replicas = c.replicas
    spec.selector.matchLabels = _labels | {"app.kubernetes.io/controller": c.name}
    spec.template.metadata.labels = _labels | {"app.kubernetes.io/controller": c.name}
    spec.template.metadata.annotations = _pod_annotations
    spec.template.spec.volumes = _volumes
    spec.template.spec.containers = [{
        "name": ct.name
        "image": ct.image
        "command": (ct.command if len(ct.command) > 0 else _default_command) if _container_strategy == "merge" else ct.command
        "args": (ct.args if len(ct.args) > 0 else _default_args) if _container_strategy == "merge" else ct.args
        "ports": [{"containerPort": p} for p in ct.ports]
        "env": [{"name": k, "value": v} for k, v in (_default_env | ct.env if _container_strategy == "merge" else ct.env)]
        "volumeMounts": [{
            "name": m.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for m in ct.volumeMounts] + [{
            "name": p.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for p in _persistence if p.globalMounts != Undefined for m in p.globalMounts if m.container == "*" or m.container == ct.name] + [{
            "name": p.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for p in _persistence if p.advancedMounts != Undefined for m in p.advancedMounts if m.controller == c.name and (m.container == "*" or m.container == ct.name)]
    } for ct in c.containers]
} for c in _spec.controllers if c.type == "Deployment"]

_statefulsets = [apps.StatefulSet {
    metadata.name = "${_full_name}-${c.name}"
    metadata.namespace = _spec.namespace
    metadata.labels = _labels | {"app.kubernetes.io/controller": c.name} | c.labels
    metadata.annotations = c.annotations
    spec.replicas = c.replicas
    spec.serviceName = "${_full_name}-${c.name}"
    spec.selector.matchLabels = _labels | {"app.kubernetes.io/controller": c.name}
    spec.template.metadata.labels = _labels | {"app.kubernetes.io/controller": c.name}
    spec.template.metadata.annotations = _pod_annotations
    spec.template.spec.volumes = _volumes
    spec.template.spec.containers = [{
        "name": ct.name
        "image": ct.image
        "command": (ct.command if len(ct.command) > 0 else _default_command) if _container_strategy == "merge" else ct.command
        "args": (ct.args if len(ct.args) > 0 else _default_args) if _container_strategy == "merge" else ct.args
        "ports": [{"containerPort": p} for p in ct.ports]
        "env": [{"name": k, "value": v} for k, v in (_default_env | ct.env if _container_strategy == "merge" else ct.env)]
        "volumeMounts": [{
            "name": m.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for m in ct.volumeMounts] + [{
            "name": p.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for p in _persistence if p.globalMounts != Undefined for m in p.globalMounts if m.container == "*" or m.container == ct.name] + [{
            "name": p.name
            "mountPath": m.mountPath
            "readOnly": m.readOnly
            "subPath": m.subPath
        } for p in _persistence if p.advancedMounts != Undefined for m in p.advancedMounts if m.controller == c.name and (m.container == "*" or m.container == ct.name)]
    } for ct in c.containers]
} for c in _spec.controllers if c.type == "StatefulSet"]

_services = [core.Service {
    metadata.name = "${_full_name}-${s.name}"
    metadata.namespace = _spec.namespace
    metadata.labels = _labels
    spec.type = s.type
    spec.selector = _labels | {"app.kubernetes.io/controller": s.controller}
    spec.ports = [{
        "name": p.name
        "port": p.port
        "targetPort": p.targetPort
        "protocol": p.protocol
    } for p in s.ports]
} for s in _services_input]

_ingresses = [netv1.Ingress {
    metadata.name = "${_full_name}-${ing.name}"
    metadata.namespace = _spec.namespace
    metadata.labels = _labels
    metadata.annotations = ing.annotations
    spec = {
        "ingressClassName": ing.className
        "rules": [{
            "host": h.host
            "http": {
                "paths": [{
                    "path": p.path
                    "pathType": p.pathType
                    "backend": {
                        "service": {
                            "name": "${_full_name}-${p.service}"
                            "port": {
                                "name": p.servicePortName
                            }
                        }
                    }
                } for p in h.paths]
            }
        } for h in ing.hosts]
        "tls": [{
            "secretName": t.secretName
            "hosts": t.hosts
        } for t in ing.tls]
    } if ing.className != "" else {
        "rules": [{
            "host": h.host
            "http": {
                "paths": [{
                    "path": p.path
                    "pathType": p.pathType
                    "backend": {
                        "service": {
                            "name": "${_full_name}-${p.service}"
                            "port": {
                                "name": p.servicePortName
                            }
                        }
                    }
                } for p in h.paths]
            }
        } for h in ing.hosts]
        "tls": [{
            "secretName": t.secretName
            "hosts": t.hosts
        } for t in ing.tls]
    }
} for ing in _ingress_input if len(ing.hosts) > 0]

_pvcs = [core.PersistentVolumeClaim {
    metadata.name = p.name
    metadata.namespace = _spec.namespace
    metadata.labels = _labels
    spec = {
        "accessModes": [p.accessMode]
        "resources": {
            "requests": {
                "storage": p.size
            }
        }
        "storageClassName": p.storageClass
    } if p.storageClass != "" else {
        "accessModes": [p.accessMode]
        "resources": {
            "requests": {
                "storage": p.size
            }
        }
    }
} for p in _persistence if p.type == "pvc"]

_deployments + _statefulsets + _services + _ingresses + _pvcs

import k8s.api.apps.v1 as apps
import modules.common.render.input as ri

schema StatefulSets(ri.RenderInput):
    items: [any]
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
    } for p in persistence]

    items = [apps.StatefulSet {
        metadata.name = "${fullName}-${c.name}"
        metadata.namespace = namespace
        metadata.labels = labels | {"app.kubernetes.io/controller": c.name} | c.labels
        metadata.annotations = c.annotations
        spec.replicas = c.replicas
        spec.serviceName = "${fullName}-${c.name}"
        spec.selector.matchLabels = labels | {"app.kubernetes.io/controller": c.name}
        spec.template.metadata.labels = labels | {"app.kubernetes.io/controller": c.name}
        spec.template.metadata.annotations = podAnnotations
        spec.template.spec.volumes = _volumes
        spec.template.spec.containers = [{
            "name": ct.name
            "image": ct.image
            "command": (ct.command if len(ct.command) > 0 else defaultCommand) if containerStrategy == "merge" else ct.command
            "args": (ct.args if len(ct.args) > 0 else defaultArgs) if containerStrategy == "merge" else ct.args
            "ports": [{"containerPort": p} for p in ct.ports]
            "env": [{"name": k, "value": v} for k, v in (defaultEnv | ct.env if containerStrategy == "merge" else ct.env)]
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
            } for p in persistence if p.globalMounts != Undefined for m in p.globalMounts if m.container == "*" or m.container == ct.name] + [{
                "name": p.name
                "mountPath": m.mountPath
                "readOnly": m.readOnly
                "subPath": m.subPath
            } for p in persistence if p.advancedMounts != Undefined for m in p.advancedMounts if m.controller == c.name and (m.container == "*" or m.container == ct.name)]
        } for ct in c.containers]
    } for c in controllers if c.type == "StatefulSet"]

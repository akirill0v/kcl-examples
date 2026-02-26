import k8s.api.core.v1 as core
import modules.common.render.input as ri

schema Services(ri.RenderInput):
    items: [any]
    items = [core.Service {
        metadata.name = "${fullName}-${s.name}"
        metadata.namespace = namespace
        metadata.labels = labels
        spec.type = s.type
        spec.selector = labels | {"app.kubernetes.io/controller": s.controller}
        spec.ports = [{
            "name": p.name
            "port": p.port
            "targetPort": p.targetPort
            "protocol": p.protocol
        } for p in s.ports]
    } for s in services]

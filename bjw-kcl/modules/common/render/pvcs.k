import k8s.api.core.v1 as core
import modules.common.render.input as ri

schema PVCs(ri.RenderInput):
    items: [any]
    items = [core.PersistentVolumeClaim {
        metadata.name = p.name
        metadata.namespace = namespace
        metadata.labels = labels
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
    } for p in persistence if p.type == "pvc"]

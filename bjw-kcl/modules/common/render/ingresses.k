import k8s.api.networking.v1 as netv1
import modules.common.render.input as ri

schema Ingresses(ri.RenderInput):
    items: [any]
    items = [netv1.Ingress {
        metadata.name = "${fullName}-${ing.name}"
        metadata.namespace = namespace
        metadata.labels = labels
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
                                "name": "${fullName}-${p.service}"
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
                                "name": "${fullName}-${p.service}"
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
    } for ing in ingresses if len(ing.hosts) > 0]

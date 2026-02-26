schema ServicePort:
    name: str = "http"
    port: int = 80
    targetPort: int = 80
    protocol: str = "TCP"

    check:
        port > 0 and port < 65536
        targetPort > 0 and targetPort < 65536
        protocol in ["TCP", "UDP"]

schema Service:
    name: str = "main"
    controller: str = "main"
    type: str = "ClusterIP"
    ports: [ServicePort] = [{name = "http", port = 80, targetPort = 80}]

    check:
        len(name) > 0
        len(controller) > 0
        type in ["ClusterIP", "NodePort", "LoadBalancer"]
        len(ports) > 0

schema IngressHostPath:
    path: str = "/"
    pathType: str = "Prefix"
    service: str = "main"
    servicePortName: str = "http"

    check:
        len(path) > 0
        pathType in ["Prefix", "Exact", "ImplementationSpecific"]
        len(service) > 0

schema IngressHost:
    host: str
    paths: [IngressHostPath] = [{}]

    check:
        len(host) > 0
        len(paths) > 0

schema IngressTLS:
    secretName: str
    hosts: [str] = []

    check:
        len(secretName) > 0
        len(hosts) > 0

schema Ingress:
    name: str = "main"
    className: str = ""
    hosts: [IngressHost] = []
    tls: [IngressTLS] = []
    annotations: {str: str} = {}

    check:
        len(name) > 0

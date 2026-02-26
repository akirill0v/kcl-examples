schema VolumeMount:
    name: str
    mountPath: str
    readOnly: bool = False
    subPath: str = ""

    check:
        name != ""
        mountPath != ""

schema Container:
    name: str = "main"
    image: str
    ports: [int] = []
    env: {str: str} = {}
    command: [str] = []
    args: [str] = []
    volumeMounts: [VolumeMount] = []

    check:
        image != ""
        len(name) > 0
        len([p for p in ports if p > 0 and p < 65536]) == len(ports)

schema Controller:
    name: str = "main"
    type: str = "Deployment"
    replicas: int = 1
    labels: {str: str} = {}
    annotations: {str: str} = {}
    containers: [Container] = []

    check:
        len(name) > 0
        type in ["Deployment", "StatefulSet"]
        replicas >= 1 and replicas <= 20
        len(containers) > 0

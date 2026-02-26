import modules.common.schemas.controllers as ctl
import modules.common.schemas.networking as net
import modules.common.schemas.persistence as ps
import modules.common.schemas.naming as nm

schema StrategyOptions:
    pod: str = "overwrite"
    container: str = "overwrite"

    check:
        pod in ["overwrite", "merge"]
        container in ["overwrite", "merge"]

schema DefaultContainerOptions:
    env: {str: str} = {}
    command: [str] = []
    args: [str] = []

schema DefaultPodOptions:
    annotations: {str: str} = {}

schema AppSpec:
    name: str
    namespace: str = "default"
    naming: nm.NamingPolicy = {}
    labels: {str: str} = {}
    controllers: [ctl.Controller]
    service: [net.Service] = []
    ingress: [net.Ingress] = []
    persistence: [ps.Persistence] = []
    defaultContainerOptions: DefaultContainerOptions = {}
    defaultPodOptions: DefaultPodOptions = {}
    strategy: StrategyOptions = {}

    check:
        len(name) > 0
        len(namespace) > 0
        len(controllers) > 0

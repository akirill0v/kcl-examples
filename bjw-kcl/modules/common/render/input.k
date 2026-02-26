import modules.common.schemas.controllers as ctl
import modules.common.schemas.networking as nw
import modules.common.schemas.persistence as ps

schema RenderInput:
    fullName: str
    namespace: str
    labels: {str: str}
    podAnnotations: {str: str} = {}
    containerStrategy: str = "overwrite"
    defaultEnv: {str: str} = {}
    defaultCommand: [str] = []
    defaultArgs: [str] = []
    controllers: [ctl.Controller]
    services: [nw.Service] = []
    ingresses: [nw.Ingress] = []
    persistence: [ps.Persistence] = []

    check:
        containerStrategy in ["overwrite", "merge"]

import modules.common.core as common
import modules.common.render.input as rinput
import modules.common.render.deployments as rdep
import modules.common.render.statefulsets as rsts
import modules.common.render.services as rsvc
import modules.common.render.ingresses as ring
import modules.common.render.pvcs as rpvc

_spec = common.AppSpec {**(option("app") or {})}

_full_name = _spec.naming.forceRename if _spec.naming.forceRename != "" else "${_spec.naming.prefix}${_spec.name}${_spec.naming.suffix}"
_base_labels = {
    "app.kubernetes.io/name": _spec.name
    "app.kubernetes.io/managed-by": "kcl"
}
_labels = _base_labels | _spec.labels

_ctx = rinput.RenderInput {
    fullName = _full_name
    namespace = _spec.namespace
    labels = _labels
    podAnnotations = _spec.defaultPodOptions.annotations or {}
    containerStrategy = _spec.strategy.container or "overwrite"
    defaultEnv = _spec.defaultContainerOptions.env or {}
    defaultCommand = _spec.defaultContainerOptions.command or []
    defaultArgs = _spec.defaultContainerOptions.args or []
    controllers = _spec.controllers
    services = _spec.service if _spec.service != Undefined else []
    ingresses = _spec.ingress if _spec.ingress != Undefined else []
    persistence = _spec.persistence if _spec.persistence != Undefined else []
}

_resources = rdep.Deployments {**_ctx}.items + rsts.StatefulSets {**_ctx}.items + rsvc.Services {**_ctx}.items + ring.Ingresses {**_ctx}.items + rpvc.PVCs {**_ctx}.items

_resources

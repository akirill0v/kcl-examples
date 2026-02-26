import main as m

_ctx = m._ctx

_service_items = [{
    "key": "${_ctx.fullName}-${c.name}-${ct.name}"
    "value": {
        "image": ct.image
        "command": ct.command if len(ct.command) > 0 else _ctx.defaultCommand
        "environment": _ctx.defaultEnv | ct.env if _ctx.containerStrategy == "merge" else ct.env
        "ports": ["${p.port}:${p.targetPort}/${p.protocol.lower()}" for s in _ctx.services if s.controller == c.name for p in s.ports]
        "volumes": ["${vm.name}:${vm.mountPath}${':ro' if vm.readOnly else ''}" for vm in ct.volumeMounts] + ["${p.name}:${gm.mountPath}${':ro' if gm.readOnly else ''}" for p in _ctx.persistence if p.globalMounts != Undefined for gm in p.globalMounts if gm.container == "*" or gm.container == ct.name] + ["${p.name}:${am.mountPath}${':ro' if am.readOnly else ''}" for p in _ctx.persistence if p.advancedMounts != Undefined for am in p.advancedMounts if am.controller == c.name and (am.container == "*" or am.container == ct.name)]
    }
} for c in _ctx.controllers for ct in c.containers]

_services = {item.key: item.value for item in _service_items}
_volumes = {p.name: {} for p in _ctx.persistence if p.type in ["pvc", "emptyDir"]}

_out = {
    "name": _ctx.fullName
    "services": _services
    "volumes": _volumes
}

_out

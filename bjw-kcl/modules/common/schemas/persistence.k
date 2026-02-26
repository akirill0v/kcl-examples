schema GlobalMount:
    container: str = "*"
    mountPath: str
    readOnly: bool = False
    subPath: str = ""

    check:
        len(container) > 0
        len(mountPath) > 0

schema AdvancedMount:
    controller: str
    container: str = "*"
    mountPath: str
    readOnly: bool = False
    subPath: str = ""

    check:
        len(controller) > 0
        len(container) > 0
        len(mountPath) > 0

schema Persistence:
    name: str
    type: str = "pvc"
    size: str = "1Gi"
    storageClass: str = ""
    accessMode: str = "ReadWriteOnce"
    configMapName: str = ""
    secretName: str = ""
    globalMounts: [GlobalMount] = []
    advancedMounts: [AdvancedMount] = []

    check:
        len(name) > 0
        type in ["pvc", "emptyDir", "configMap", "secret"]
        accessMode in ["ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany"]
        type != "configMap" or len(configMapName) > 0
        type != "secret" or len(secretName) > 0

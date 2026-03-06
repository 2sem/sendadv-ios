import ProjectDescription

let tuist = Tuist(
    fullHandle: "gamehelper/sendadv",
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("26.0"),
//                    swiftVersion: "",
//                    plugins: <#T##[PluginLocation]#>,
        generationOptions: .options(
            enableCaching: true,
            registryEnabled: true
        )
//                    installOptions: <#T##Tuist.InstallOptions#>)
    )
)

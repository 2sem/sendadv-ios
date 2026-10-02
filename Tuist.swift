import ProjectDescription

let tuist = Tuist(
    fullHandle: "gamehelper/sendadv",
    project: .tuist(
        compatibleXcodeVersions: .list([.upToNextMajor("26.0"), .upToNextMajor("27.0")]),
//                    swiftVersion: "",
//                    plugins: <#T##[PluginLocation]#>,
        generationOptions: .options(
            enableCaching: true,
            registryEnabled: true
        )
//                    installOptions: <#T##Tuist.InstallOptions#>)
    )
)

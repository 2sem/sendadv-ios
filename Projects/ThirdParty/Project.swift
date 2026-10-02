import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "ThirdParty",
    packages: [
        .remote(url: "https://github.com/2sem/LSExtensions",
                requirement: .exact("0.1.24")),
//        .remote(url: "https://github.com/SDWebImage/SDWebImage",
//                requirement: .upToNextMajor(from: "5.21.7")),
//        .local(path: "../../../../../spms/DownPicker")
    ],
    targets: [
        .target(
            name: "ThirdParty",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: .appBundleId.appending(".thirdparty"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [.external(name: "KakaoSDK"),
                           .package(product: "LSExtensions", type: .runtime)
            ]
        ),
    ]
)
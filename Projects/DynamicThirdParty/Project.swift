import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    packages: [.remote(url: "https://github.com/SDWebImage/SDWebImage.git",
                       requirement: .upToNextMajor(from: "5.1.0")),
               .remote(url: "https://github.com/firebase/firebase-ios-sdk",
                       requirement: .upToNextMajor(from: "10.4.0")),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: .appBundleId.appending(".thirdparty.dynamic"),
            dependencies: [.package(product: "SDWebImage", type: .runtime),
                           .package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "FirebaseMessaging", type: .runtime),
                           .package(product: "FirebaseRemoteConfig", type: .runtime)
            ]
        ),
    ]
)

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "DynamicThirdParty",
    packages: [        .package(id: "sdwebimage.sdwebimage", from: "5.21.7"),
                       .package(id: "firebase.firebase-ios-sdk", from: "11.15.0"),
    ],
    targets: [
        .target(
            name: "DynamicThirdParty",
            destinations: .iOS,
            product: .framework,
            bundleId: .appBundleId.appending(".thirdparty.dynamic"),
            deploymentTargets: .iOS("18.0"),
            dependencies: [.package(product: "SDWebImage", type: .runtime),
                           .package(product: "FirebaseCrashlytics", type: .runtime),
                           .package(product: "FirebaseAnalytics", type: .runtime),
                           .package(product: "FirebaseMessaging", type: .runtime),
                           .package(product: "FirebaseRemoteConfig", type: .runtime)
            ]
        ),
    ]
)

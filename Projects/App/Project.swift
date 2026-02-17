import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    options: .options(defaultKnownRegions: ["en"],
                     developmentRegion: "en"),
    packages: [
        .remote(url: "https://github.com/2sem/GADManager",
                requirement: .upToNextMajor(from: "1.3.6")),
        // .local(path: "../../../../../pods/GADManager/src/GADManager"),
//        .remote(url: "https://github.com/firebase/firebase-ios-sdk",
//                requirement: .upToNextMajor(from: "10.4.0")),
    ],
    settings: .settings(configurations: [
        .debug(
            name: "Debug",
            xcconfig: "Configs/app.debug.xcconfig"),
        .release(
            name: "Release",
            xcconfig: "Configs/app.release.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: .appBundleId,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "GADApplicationIdentifier": "ca-app-pub-9684378399371172~3075360846",
                    "GADUnitIdentifiers": [
                                            "FullAd" : "ca-app-pub-9684378399371172/2975452443",
                                            // "FullAd" : "ca-app-pub-3940256099942544/4411468910", // test
                                           "Launch" : "ca-app-pub-9684378399371172/6626536187",
                                           "Native" : "ca-app-pub-9684378399371172/8770326405"
                                            // "Native" : "ca-app-pub-3940256099942544/3986624511" // test
                                           ],
                    "Itunes App Id": "1195349333",
                    "NSUserTrackingUsageDescription": "Use location information to explore nearby attractions.",
                    "ITSAppUsesNonExemptEncryption": "NO",
                    "CFBundleShortVersionString": "${MARKETING_VERSION}",
                    "CFBundleDisplayName": "Send Multi SMS",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "KAKAO_APP_KEY": "c7ebdb09664b7c7bd73eeab5ccd48589",
                    // UIApplicationSceneManifest is not needed for SwiftUI App
                    // SwiftUI App handles scene management automatically
                    "NSContactsUsageDescription": "This app requires access to your contacts to create a recipient list for sending messages.",
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                .glob(pattern: "Resources/**",
                      excluding: ["Resources/Datas/sendadv.xcdatamodeld/**"])
            ],
            //            entitlements: .file(path: .relativeToCurrentFile("Sources/gersanghelper.entitlements")),
            scripts: [
                .pre(script: "\"${SRCROOT}/Scripts/merge_skadnetworks.sh\"",
                     name: "Merge SKAdNetworkItems",
                     inputPaths: ["$(SRCROOT)/Resources/skNetworks.plist"],
                     outputPaths: []),
                .post(script: "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run",
                            name: "Upload dSYM for Crashlytics",
                            inputPaths: ["${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
                                         "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
                                         "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
                                         "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
                                         "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"],
                            runForInstallBuildsOnly: true)],
            dependencies: [
                .Projects.ThirdParty,
                .Projects.DynamicThirdParty,
                .package(product: "GADManager", type: .runtime)
            ],
            settings: .settings(configurations: [
                .debug(
                    name: "Debug",
                    xcconfig: "Configs/app.debug.xcconfig"),
                .release(
                    name: "Release",
                    xcconfig: "Configs/app.release.xcconfig")
            ])
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: .appBundleId.appending(".tests"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "App")]
        ),
    ], resourceSynthesizers: []
)

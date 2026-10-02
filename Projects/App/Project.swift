import ProjectDescription
import ProjectDescriptionHelpers

let skAdNetworkIDs: [String] = [
    "cstr6suwn9", "4fzdc2evr5", "2fnua5tdw4", "ydx93a7ass", "p78axxw29g",
    "v72qych5uu", "ludvb6z3bs", "cp8zw746q7", "3sh42y64q3", "c6k4g5qg8m",
    "s39g8k73mm", "wg4vff78zm", "3qy4746246", "f38h382jlk", "hs6bdukanm",
    "mlmmfzh3r3", "v4nxqhlyqp", "wzmmz9fp6w", "su67r6k2v3", "yclnxrl5pm",
    "t38b2kh725", "7ug5zh24hu", "gta9lk7p23", "vutu7akeur", "y5ghdn5j9k",
    "v9wttpbfk9", "n38lu8286q", "47vhws6wlr", "kbd757ywx3", "9t245vhmpl",
    "a2p9lx4jpn", "22mmun2rn5", "44jx6755aq", "k674qkevps", "4468km3ulz",
    "2u9pt9hc89", "8s468mfl3y", "klf5c3l5u5", "ppxm28t8ap", "kbmxgpxpgc",
    "uw77j35x4d", "578prtvx9j", "4dzt52r2t5", "tl55sbb4fm", "c3frkrj4fj",
    "e5fvkxwrpn", "8c4e2ghe7u", "3rd42ekr43", "97r2b46745", "3qcr597p9d"
]

let skAdNetworks: [Plist.Value] = skAdNetworkIDs
    .map { .dictionary(["SKAdNetworkIdentifier": .string("\($0).skadnetwork")]) }

let project = Project(
    name: "App",
    options: .options(defaultKnownRegions: ["en"],
                     developmentRegion: "en"),
    packages: [
        // .local(path: "../../../../../pods/GADManager/src/GADManager"),
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
                    "SKAdNetworkItems": .array(skAdNetworks),
                    "NSUserTrackingUsageDescription": "Use location information to explore nearby attractions.",
                    "ITSAppUsesNonExemptEncryption": "NO",
                    "CFBundleShortVersionString": "${MARKETING_VERSION}",
                    "CFBundleDisplayName": "Group SMS",
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
                      excluding: ["Resources/Datas/sendadv.xcdatamodeld/sendadv.xcdatamodel"])
            ],
            //            entitlements: .file(path: .relativeToCurrentFile("Sources/gersanghelper.entitlements")),
            scripts: [
                .pre(script: "/bin/sh \"${SRCROOT}/Scripts/merge_skadnetworks.sh\"",
                     name: "Merge SKAdNetworkItems",
                     inputPaths: ["$(SRCROOT)/Resources/skNetworks.plist"],
                     basedOnDependencyAnalysis: false),
                .post(
                    script: """
                        # Firebase is a Tuist-integrated dependency (Tuist/Package.swift),
                        # so its checkout lives under Tuist/.build. Path is relative to
                        # $(SRCROOT) (Projects/App).
                        CRASHLYTICS_RUN_SCRIPT="${SRCROOT}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"

                        if [ ! -f "$CRASHLYTICS_RUN_SCRIPT" ]; then
                          echo "error: Firebase Crashlytics run script not found at $CRASHLYTICS_RUN_SCRIPT - run 'tuist install' first"
                          exit 1
                        fi

                        "$CRASHLYTICS_RUN_SCRIPT"
                        """,
                    name: "Upload dSYM for Crashlytics",
                    inputPaths: ["${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
                                 "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
                                 "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
                                 "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
                                 "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"],
                    runForInstallBuildsOnly: true)],
            dependencies: [
                .Projects.ThirdParty,
                .external(name: "GADManager"),
                // Firebase links directly into App rather than through an intermediate
                // dynamic wrapper framework: Tuist's SPM integration doesn't reliably
                // propagate Firebase's binary XCFrameworks through such a wrapper.
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebaseRemoteConfig"),
            ],
            settings: .settings(
                base: [
                    // The Crashlytics "run" tool lives under Tuist/.build/checkouts,
                    // outside $(SRCROOT), so User Script Sandboxing would block it.
                    "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
                ],
                configurations: [
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

// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription

    // SwiftUI previews (ENABLE_DEBUG_DYLIB) crash with static ObjC frameworks
    // (duplicate/unrealized classes), so link every external target dynamically.
    let dynamicTargets = [
        "Firebase",
        "FirebaseCore",
        "FirebaseCoreExtension",
        "FirebaseCoreInternal",
        "FirebaseInstallations",
        "FirebaseCrashlytics",
        "FirebaseCrashlyticsSwift",
        "FirebaseSessions",
        "FirebaseSessionsObjC",
        "FirebaseRemoteConfigInterop",
        "FirebaseRemoteConfig",
        "FirebaseRemoteConfigInternal",
        "FirebaseABTesting",
        "FirebaseSharedSwift",
        "FirebaseMessaging",
        "GoogleDataTransport",
        "FBLPromises",
        "nanopb",
        "GoogleUtilities-AppDelegateSwizzler",
        "GoogleUtilities-Environment",
        "GoogleUtilities-Logger",
        "GoogleUtilities-MethodSwizzler",
        "GoogleUtilities-Network",
        "GoogleUtilities-NSData",
        "GoogleUtilities-Reachability",
        "GoogleUtilities-UserDefaults",
        "third-party-IsAppEncrypted",
    ]

    // Wrappers around prebuilt static XCFrameworks have no sources of their own;
    // as dylibs they'd link nothing, so keep them static to fold into their consumer.
    let staticBinaryWrappers = [
        "FirebaseAnalyticsTarget",
        "FirebaseAnalyticsWrapper",
        "GoogleAppMeasurementTarget",
        "GoogleAdsOnDeviceConversionTarget",
    ]

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        productTypes: Dictionary(uniqueKeysWithValues: dynamicTargets.map { ($0, .framework) }),
            // .merging(staticBinaryWrappers.map { ($0, .staticFramework) }) { $1 },
        baseSettings: .settings(
            // Firebase links dynamically here (see productTypes above), so each
            // framework is embedded in the app and Crashlytics needs a dSYM of its
            // own to symbolicate frames inside it. Release already defaults to
            // dwarf-with-dsym; pin it so an xcconfig or Xcode default can't drop
            // it silently. Debug stays on plain `dwarf` - local builds don't need
            // dSYMs and generating them is not free.
            configurations: [
                .debug(
                    name: .debug
                ),
                .release(
                    name: .release,
                    settings: ["DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym"]
                ),
            ]
        ),
        targetSettings: [
            // FirebaseSessions uses FirebaseCoreInternal.UnfairLock without
            // declaring FirebaseCoreInternal as a target dependency in Firebase's
            // own manifest (only transitively available via FirebaseCore/Firebase
            // itself). That's invisible while everything links statically into one
            // binary, but as a standalone dynamic framework FirebaseSessions can't
            // resolve those symbols on its own, failing at its *own* link step
            // ("Undefined symbols ... FirebaseCoreInternal.UnfairLock"). Force-link
            // it; FirebaseCoreInternal.framework is already built as a dependency
            // of FirebaseCore, so it's present to link against.
            "FirebaseSessions": .settings(base: [
                "OTHER_LDFLAGS": "$(inherited) -framework FirebaseCoreInternal",
            ]),
        ]
    )
#endif

let package = Package(
    name: "sendadv",
    dependencies: [
        // Migrating from Project.swift `packages:` one package at a time;
        // consumed via `.external(name:)`.
        .package(url: "https://github.com/2sem/GADManager", from: "1.5.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.28.0"),
        .package(url: "https://github.com/2sem/LSExtensions", exact: "0.1.24"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "12.17.0")),
    ]
)

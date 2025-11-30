# Codebase Structure

## Workspace Organization

This is a **Tuist-managed multi-project workspace** named `sendadv` with three separate projects:

### 1. App (`Projects/App/`)
Main application target containing all business logic and UI.

**Key Files:**
- `Project.swift`: Tuist project definition
- `App.swift`: SwiftUI App entry point with app lifecycle
- `AppDelegate.swift`: UIKit delegate for legacy support
- `ContentView.swift`: Root SwiftUI view (though navigation starts from RecipientRuleListScreen)
- `MainViewController.swift`: UIKit main controller

**Directory Structure:**
```
Projects/App/
├── Project.swift
├── Configs/
│   ├── app.debug.xcconfig    # Debug build configuration
│   └── app.release.xcconfig  # Release build configuration
├── Sources/
│   ├── App.swift
│   ├── AppDelegate.swift
│   ├── ContentView.swift
│   ├── MainViewController.swift
│   ├── ViewModels/
│   ├── Models/
│   ├── Repositories/
│   ├── Datas/
│   ├── Screens/
│   ├── Views/
│   ├── Controllers/
│   └── Extensions/
├── Resources/         # Assets, storyboards, etc.
├── Tests/            # Unit tests
└── Docs/             # Documentation
```

### 2. ThirdParty (`Projects/ThirdParty/`)
Static framework bundling most third-party dependencies.

**Dependencies:**
- KakaoSDK
- MBProgressHUD
- LSExtensions
- Material

### 3. DynamicThirdParty (`Projects/DynamicThirdParty/`)
Dynamic framework specifically for Firebase and SDWebImage.

**Dependencies:**
- SDWebImage
- FirebaseCrashlytics
- FirebaseAnalytics
- FirebaseMessaging
- FirebaseRemoteConfig

## Tuist Configuration

### Root Files
- **`Workspace.swift`**: Defines the workspace and included projects
- **`Tuist.swift`**: Tuist configuration (Xcode 26.0 compatibility)
- **`mise.toml`**: Tool version specification (Tuist 4.43.1)

### Helpers (`Tuist/ProjectDescriptionHelpers/`)
Custom Swift extensions for Tuist project definitions:

- **`String+.swift`**: Defines `.appBundleId` = "com.credif.sendadv"
- **`Path+.swift`**: Path helper for referencing project paths
- **`TargetDependency+.swift`**: Defines `.Projects.ThirdParty` and `.Projects.DynamicThirdParty` dependencies

**Usage Pattern:**
When adding new shared projects, update these helpers to maintain consistency across project definitions.

## Deployment Configuration

### Fastlane (`fastlane/`)
- **`Fastfile`**: Deployment automation
  - Certificate and provisioning profile management
  - Version and build number management
  - TestFlight and App Store upload

### GitHub Actions (`.github/workflows/`)
- **`deploy-ios.yml`**: CI/CD pipeline
  - Runs on macOS 15 with Xcode 16.2
  - Uses mise for tool management
  - Runs Tuist build verification
  - Deploys via Fastlane

## Build Configurations

### Debug (`Configs/app.debug.xcconfig`)
- Automatic code signing
- DWARF debug format (not dsym)
- Development team: M29A6H95KD

### Release (`Configs/app.release.xcconfig`)
- Manual code signing
- DWARF with dSYM
- iPhone Distribution certificate
- Provisioning profile: "sendadv"

## Key Integrations

### Google AdMob
Ad units configured in `Project.swift`:
- **FullAd**: ca-app-pub-9684378399371172/2975452443
- **Launch**: ca-app-pub-9684378399371172/6626536187
- **Native**: ca-app-pub-9684378399371172/8770326405

### Kakao
- **App Key**: c7ebdb09664b7c7bd73eeab5ccd48589

### Firebase
Post-build script uploads dSYM to Crashlytics for crash symbolication.

### Network Security
App allows arbitrary loads (`NSAllowsArbitraryLoads: true`).

## Entry Points

### SwiftUI App Entry
`App.swift` → `SendadvApp` struct:
- Uses `@UIApplicationDelegateAdaptor` for AppDelegate
- Root view: `RecipientRuleListScreen()` wrapped in `NavigationStack`
- SwiftData model container setup
- Environment objects injection (AdManager, ReviewManager)
- Splash screen overlay
- Ad setup and scene phase handling

### UIKit Support
`AppDelegate.swift` handles:
- Legacy app lifecycle events
- Background task registration (if needed)

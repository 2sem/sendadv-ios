# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Setup & Build Commands

### Initial Setup
```bash
# Install mise (if not already installed)
brew install mise

# Install Tuist via mise
mise install tuist

# Install project dependencies
mise x -- tuist install

# Generate Xcode workspace
mise x -- tuist generate

# Generate and open in Xcode
mise x -- tuist generate --open
```

### Build & Clean
```bash
# Build the project
mise x -- tuist build

# Clean build artifacts
mise x -- tuist clean

# Build from command line (after generate)
xcodebuild -workspace sendadv.xcworkspace -scheme App -configuration Debug build
```

### After Pulling Changes
Always regenerate the project after pulling changes:
```bash
mise x -- tuist install
mise x -- tuist generate
```

### Deployment
```bash
# Deploy to TestFlight only
fastlane ios release description:'변경사항 설명' isReleasing:false

# Deploy to App Store for review
fastlane ios release description:'변경사항 설명' isReleasing:true
```

## Project Architecture

### Tuist Multi-Project Workspace
This is a Tuist-managed workspace with three separate projects:

1. **App** (`Projects/App/`): Main application with all business logic and UI
2. **ThirdParty** (`Projects/ThirdParty/`): Static framework with KakaoSDK, MBProgressHUD, LSExtensions, Material
3. **DynamicThirdParty** (`Projects/DynamicThirdParty/`): Dynamic framework with Firebase and SDWebImage

**CRITICAL**: Never regenerate Xcode projects manually without file insert/delete. Always use `mise x -- tuist generate` instead of direct Xcode operations.

### MVVM Architecture
- **ViewModels/**: View models for each screen
- **Models/**: SwiftData models (`RecipientsRule`, `RecipientsFilter`)
- **Repositories/**: Data access layer abstraction
- **Screens/**: Full-screen SwiftUI views (suffix: `Screen`)
- **Views/**: Reusable SwiftUI components (suffix: `View`)
- **Controllers/**: UIKit controllers (legacy support)

### App Entry Point
- **File**: `Projects/App/Sources/App.swift`
- **Main struct**: `SendadvApp` (SwiftUI App lifecycle)
- **Root view**: `RecipientRuleListScreen()` wrapped in `NavigationStack`
- **Environment objects**: `SwiftUIAdManager`, `ReviewManager`, `SwiftUIRewardAdManager`
- **Data**: SwiftData container for `RecipientsRule` and `RecipientsFilter`

### Key Screens
1. **SplashScreen** - Data migration handling on app start
2. **RecipientRuleListScreen** - Main screen, recipient rules list
   - ViewModel: `RecipientListScreenModel`
3. **RuleDetailScreen** - Edit recipient rules (department/position/organization filters)
   - ViewModel: `RuleDetailScreenModel`
4. **RuleFilterScreen** - Select filter items
   - ViewModel: `RuleFilterScreenModel`

## Coding Standards

### Language & Style
- Swift 6.0+ syntax required
- Indentation: Tabs (not spaces)
- Naming: camelCase for variables/functions, PascalCase for classes/structs
- Use `let` for constants, `var` for variables

### UI Development
- SwiftUI-based (minimum iOS 18.0)
- Use `NavigationStack` (not `NavigationView`)
- All ViewControllers are suffixed with `Screen` for full views, `View` for subviews
- Accessibility must be considered

### Localization (Korean + English)
- **Pattern**: `"Localized String Name".localized()`
- **Location**:
  - `Projects/App/Resources/Strings/en.lproj/Localizable.strings`
  - `Projects/App/Resources/Strings/ko.lproj/Localizable.strings`
- **Key naming**: English, concise, meaningful (e.g., `"Rule Title"`, `"Enter rule title"`)
- Reuse existing keys, avoid duplicates
- Format strings: `"Formatted Key".localized().asFormat(...)`

### Safe Editing Rules
- **NEVER** insert code markers like `{{ ... }}`, `...`, `<snip>` into code
- **NEVER** change structure for localization purposes (layout, gestures, control flow, function signatures)
- Preserve Swift syntax balance (braces, parentheses, generics)
- Don't modify ViewBuilder block scopes (`.toolbar {}`, `.sheet {}`)
- Only replace user-facing text: `"string"` → `"Key".localized()`
- Include at least 3 lines of context before/after changes for unique identification
- Post-verification: Always check that no markers were inserted

### Memory Management
- Use ARC properly
- Prevent strong reference cycles
- Use `weak` and `unowned` appropriately

### Error Handling
- Use `do-catch` for error handling
- Leverage Optional types
- Use `guard` for early returns

## Third-Party Integrations

### Google AdMob
Ad units are defined in `Projects/App/Project.swift`:
- **FullAd**: `ca-app-pub-9684378399371172/2975452443`
- **Launch**: `ca-app-pub-9684378399371172/6626536187`
- **Native**: `ca-app-pub-9684378399371172/8770326405`

Ad manager setup is in `SendadvApp.setupAds()` with different intervals for debug/release builds.

### Firebase
- Crashlytics: dSYM upload via post-build script
- Analytics, Messaging, RemoteConfig available
- Framework: DynamicThirdParty

### Kakao SDK
- **App Key**: `c7ebdb09664b7c7bd73eeab5ccd48589`
- Framework: ThirdParty

## Important Notes

- **Answer in Korean**: All responses should be in Korean (as per cursor rules)
- **Think like Paul Hudson or Antoine van der Lee**: Apply their iOS development principles
- **Minimum iOS**: 18.0 (target deployment)
- **No unauthorized renaming**: Always confirm before renaming symbols/files not explicitly requested
- **Tuist helpers**: When adding shared projects, update `Tuist/ProjectDescriptionHelpers/` files
- **CI/CD**: GitHub Actions on macOS 15 + Xcode 16.2, manually triggered

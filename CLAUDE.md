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
fastlane ios release description:'Change description' isReleasing:false

# Deploy to App Store for review
fastlane ios release description:'Change description' isReleasing:true
```

## Project Architecture

**Send Multi SMS**: An iOS app for sending bulk SMS messages to multiple recipients. Users create contact filters (based on department, position, organization) to organize and manage recipient lists.

### Tuist Multi-Project Workspace
This is a Tuist-managed workspace with three separate projects:

1. **App** (`Projects/App/`): Main application with all business logic and UI
2. **ThirdParty** (`Projects/ThirdParty/`): Static framework with KakaoSDK, MBProgressHUD, LSExtensions, Material
3. **DynamicThirdParty** (`Projects/DynamicThirdParty/`): Dynamic framework with Firebase and SDWebImage

**CRITICAL**: Don't regenerate Xcode projects manually without file insert/delete. Always use `mise x -- tuist generate` instead of direct Xcode operations.

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
2. **RecipientRuleListScreen** - Main screen showing contact filters list
   - ViewModel: `RecipientListScreenModel`
   - User-facing label: "Contact Filter List" (연락처 필터 목록)
3. **RuleDetailScreen** - Edit contact filters (department/position/organization criteria)
   - ViewModel: `RuleDetailScreenModel`
   - User-facing label: "Edit Contact Filter" (연락처 필터 수정)
4. **RuleFilterScreen** - Select filter items
   - ViewModel: `RuleFilterScreenModel`

**Note**: Code uses `RecipientsRule`/`RecipientsFilter` naming, but user-facing terminology is "Contact Filter" (연락처 필터) for better UX clarity.

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
- **Key naming**: English, concise, meaningful (e.g., `"Filter Title"`, `"Enter filter title"`)
- Reuse existing keys, avoid duplicates
- Format strings: `"Formatted Key".localized().asFormat(...)`
- **Terminology**: User-facing strings use "Contact Filter" (not "Recipient Rule") for better UX

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

- **Response language**: Respond in Korean when working with this codebase (as per cursor rules)
- **Development approach**: Think and implement like Paul Hudson or Antoine van der Lee - apply their iOS development principles
- **Minimum iOS**: 18.0 (target deployment)
- **No unauthorized renaming**: Always confirm before renaming symbols/files not explicitly requested
- **Tuist project regeneration**: Don't regenerate project without any file insert/delete - always use `mise x -- tuist generate`
- **Tuist helpers**: When adding shared projects, update `Tuist/ProjectDescriptionHelpers/` files
- **CI/CD**: GitHub Actions on macOS 15 + Xcode 16.2, manually triggered from GitHub UI
- **Terminology**: Code uses `RecipientsRule`/`RecipientsFilter`, but UI displays "Contact Filter" (연락처 필터)

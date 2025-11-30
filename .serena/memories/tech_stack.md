# Tech Stack

## Build System
- **Tuist**: 4.43.1 (project generation and dependency management)
- **mise**: Tool version manager (manages Tuist installation)
- **Fastlane**: Deployment automation
- **GitHub Actions**: CI/CD pipeline

## UI Framework
- **SwiftUI**: Primary UI framework (SwiftUI App lifecycle)
- **UIKit**: Supporting framework (AppDelegate, some view controllers)
- **Architecture**: Hybrid SwiftUI + UIKit approach

## Data & Persistence
- **SwiftData**: Primary data persistence layer
  - Models: `RecipientsRule`, `RecipientsFilter`
  - Configuration: Not in-memory, autosave disabled, undo enabled

## Third-Party Dependencies

### ThirdParty (Static Framework)
- **KakaoSDK** (2.22.2+): Kakao platform integration
- **MBProgressHUD** (1.2.0+): Loading indicators
- **LSExtensions** (0.1.22 exact): Custom Swift extensions
- **Material** (3.1.8+): Material Design components

### DynamicThirdParty (Dynamic Framework)
- **SDWebImage** (5.1.0+): Image loading and caching
- **Firebase iOS SDK** (11.8.1+):
  - FirebaseCrashlytics: Crash reporting
  - FirebaseAnalytics: Analytics tracking
  - FirebaseMessaging: Push notifications
  - FirebaseRemoteConfig: Remote configuration

### App-Level Dependencies
- **GADManager** (1.3.6+): Google AdMob wrapper library
- **Google Mobile Ads**: Ad serving platform

## Architecture Pattern
- **MVVM**: Model-View-ViewModel pattern
- **Environment Objects**: Shared state management
  - `SwiftUIAdManager`: Ad lifecycle management
  - `ReviewManager`: App review prompts
  - `SwiftUIRewardAdManager`: Reward ad management
- **Repository Pattern**: Data layer abstraction (Repositories folder)

## Source Organization
```
Sources/
├── ViewModels/     # View models for MVVM
├── Models/         # Data models
├── Repositories/   # Data access layer
├── Datas/          # Data structures
├── Screens/        # Screen-level views
├── Views/          # Reusable view components
├── Controllers/    # UIKit controllers
└── Extensions/     # Swift extensions
```

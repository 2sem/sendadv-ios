# Code Style and Conventions

## Language and Comments
- **Code**: Written in English (variable names, function names, types)
- **Comments**: Mix of Korean and English
  - Korean often used for user-facing descriptions and changelog
  - English for technical comments
- **Localization**: Korean UI strings

## Swift Style

### General Conventions
- **Swift Version**: 5.0
- **No Automated Linting**: No SwiftLint or SwiftFormat configured
- **Follow Existing Patterns**: Manually match the style of surrounding code

### Naming Conventions
- **Types**: PascalCase (e.g., `SendadvApp`, `SwiftUIAdManager`, `RecipientRuleListScreen`)
- **Variables/Properties**: camelCase (e.g., `isSplashDone`, `isSetupDone`, `scenePhase`)
- **Constants**: camelCase (e.g., `appBundleId`)
- **Enums**: PascalCase for type, camelCase for cases
  ```swift
  enum GADUnitName: String {
      case full = "FullAd"
      case launch = "Launch"
      case native = "Native"
  }
  ```

### Code Organization

#### MARK Comments
Use `// MARK: -` to organize code sections:
```swift
// MARK: - SwiftUI Ad Manager
class SwiftUIAdManager { }

// MARK: - Testing Flags
func isTesting(unit: GADUnitName) -> Bool { }
```

#### File Structure
Typical Swift file structure:
1. Imports
2. Type definition (struct/class/enum)
3. Properties
4. Initializers
5. Lifecycle methods
6. Public methods
7. Private methods
8. Extensions (often in same file)

#### Extensions
- Extensions often defined in the same file as the main type
- Use extensions to conform to protocols
- Example:
  ```swift
  extension SwiftUIAdManager: GADManagerDelegate {
      // Protocol implementation
  }
  ```

### SwiftUI Patterns

#### Property Wrappers
Common property wrappers used:
- `@State`: Local view state
- `@StateObject`: Owned observable objects
- `@ObservedObject`: Shared observable objects
- `@EnvironmentObject`: Environment-injected objects
- `@Environment`: Environment values
- `@UIApplicationDelegateAdaptor`: UIKit delegate adaptor

#### View Structure
```swift
struct MyView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        // View content
    }
    
    // Helper methods
    private func setupSomething() { }
}
```

### Async/Await Patterns
Modern async/await syntax is used:
```swift
@MainActor
@discardableResult
func show(unit: GADUnitName) async -> Bool {
    await withCheckedContinuation { continuation in
        // Implementation
    }
}
```

### Error Handling
- Use `guard` for early returns
- `defer` for cleanup
- `try/catch` where appropriate

### Type Safety
- Explicit type annotations when clarity is needed
- Type inference where obvious
- Generics used appropriately (e.g., `GADManager<GADUnitName>`)

## Project-Specific Patterns

### Tuist Helpers
When extending Tuist helpers (`Tuist/ProjectDescriptionHelpers/`):
```swift
import Foundation
import ProjectDescription

public extension String {
    static var appBundleId: String { "com.credif.sendadv" }
}
```

### Manager Classes
Observable manager classes pattern:
```swift
class SomeManager: NSObject, ObservableObject {
    @Published var property: Type
    static var shared: SomeManager?
    
    func setup() { }
}
```

### Delegates
Delegate conformance often via extensions:
```swift
extension SwiftUIAdManager: GADManagerDelegate {
    typealias E = GADUnitName
    // Implementation
}
```

## Documentation

### Comments
- Add comments for complex logic
- Korean acceptable for business logic explanations
- Document public APIs
- Explain "why" not just "what"

### TODO/FIXME
Use standard markers when needed:
```swift
// TODO: Implement feature
// FIXME: Handle edge case
```

## Best Practices

### Memory Management
- Use `[weak self]` in closures to avoid retain cycles
- Example:
  ```swift
  MobileAds.shared.start { [weak adManager, weak rewardAd] status in
      guard let adManager = adManager,
            let rewardAd = rewardAd else { return }
      // Use safely
  }
  ```

### Conditional Compilation
Use `#if DEBUG` for debug-only code:
```swift
#if DEBUG
adManager.prepare(openingUnit: .launch, interval: 60.0)
#else
adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
#endif
```

### Privacy and Tracking
Handle permission requests appropriately:
- App Tracking Transparency
- Contact access
- User defaults for tracking state

## File Naming
- Swift files: PascalCase matching main type name
- Extensions: `TypeName+Extension.swift` if in separate file
- Protocols: Descriptive name ending in `Delegate`, `DataSource`, etc.

## No Strict Rules
Since there's no automated linting:
- Be consistent within each file
- Match the style of nearby code
- Prioritize readability
- Follow Swift API Design Guidelines where possible

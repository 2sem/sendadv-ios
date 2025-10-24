import SwiftUI

private struct OnceAppearModifier: ViewModifier {
    private let action: () -> Void
    @State private var hasAppeared = false
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            action()
            hasAppeared = true
        }
    }
}

extension View {
    /// Performs an action only once when the view appears during app launch
    /// - Parameter action: The action to perform
    func onAppearOnce(perform action: @escaping () -> Void) -> some View {
        modifier(OnceAppearModifier(action: action))
    }
}
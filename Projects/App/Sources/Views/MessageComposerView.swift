import SwiftUI
import MessageUI
import Combine

public enum MessageComposeState {
    case unknown
    case sent
    case cancelled
    case failed
}

struct MessageComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    @Binding var composeState: MessageComposeState
    @Binding var isLoading: Bool
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.recipients = recipients
        controller.messageComposeDelegate = context.coordinator
        
        // Combine Publisher로 키보드 이벤트 구독
		context.coordinator.keyboardCancellable = NotificationCenter.default
			.publisher(for: UIResponder.keyboardWillShowNotification)
			.receive(on: RunLoop.main)
            .sink { _ in 
				print("keyboard will show in message composer")
				self.isLoading = false
			}
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposerView
        var keyboardCancellable: AnyCancellable?
        
        init(_ parent: MessageComposerView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            // Publisher 구독 취소
            keyboardCancellable?.cancel()
            keyboardCancellable = nil
            
            controller.dismiss(animated: true) {
                // Convert MFMessageComposeResult to MessageComposeState
                let state: MessageComposeState
                switch result {
                case .sent:
                    state = .sent
                case .cancelled:
                    state = .cancelled
                case .failed:
                    state = .failed
                @unknown default:
                    state = .unknown
                }
                
                // Update binding with new state
                self.parent.composeState = state
            }
        }
    }
}

// Preview Provider for SwiftUI previews
struct MessageComposerView_Previews: PreviewProvider {
    @State static var composeState: MessageComposeState = .unknown
    @State static var isLoading: Bool = true
    
    static var previews: some View {
        MessageComposerView(recipients: ["010-1234-5678"], composeState: $composeState, isLoading: $isLoading)
    }
}

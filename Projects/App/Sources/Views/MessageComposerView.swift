import SwiftUI
import MessageUI

public enum MessageComposeState {
    case unknown
    case sent
    case cancelled
    case failed
}

struct MessageComposerView: UIViewControllerRepresentable {
    let recipients: [String]
    var onComplete: ((MessageComposeState) -> Void)?
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.recipients = recipients
        controller.messageComposeDelegate = context.coordinator
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
        
        init(_ parent: MessageComposerView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, 
                                        didFinishWith result: MessageComposeResult) {
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
                
                // Call completion handler if set
                self.parent.onComplete?(state)
            }
        }
    }
}

// Preview Provider for SwiftUI previews
struct MessageComposerView_Previews: PreviewProvider {
    static var previews: some View {
        MessageComposerView(recipients: ["010-1234-5678"]) { result in
            print("Message compose result: \(result)")
        }
    }
}
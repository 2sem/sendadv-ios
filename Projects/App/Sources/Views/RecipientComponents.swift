//
//  RecipientComponents.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import MessageUI

// MARK: - Supporting Views
struct EmptyStateView: View {
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "person.3.fill")
				.font(.system(size: 60))
				.foregroundColor(.gray)
			
            Text("rules.empty".localized())
				.font(.title2)
				.foregroundColor(.gray)
			
            Text("rules.empty.description".localized())
				.font(.body)
				.foregroundColor(.gray)
		}
	}
}



struct SendButton: View {
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			Image(systemName: "paperplane.fill")
				.font(.title2)
				.foregroundColor(.black)
				.frame(width: 56, height: 56)
				.background(Color.yellow)
				.clipShape(Circle())
				.shadow(radius: 4)
		}
	}
}

struct AdsView: View {
	var body: some View {
		HStack {
			Text("ads.label")
				.font(.headline)
			Spacer()
		}
		.padding()
		.background(Color.gray.opacity(0.1))
		.cornerRadius(8)
	}
}

struct MessageComposerView: UIViewControllerRepresentable {
	let recipients: [String]
	
	func makeUIViewController(context: Context) -> MFMessageComposeViewController {
		let controller = MFMessageComposeViewController()
		controller.recipients = recipients
		controller.messageComposeDelegate = context.coordinator
		return controller
	}
	
	func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
		func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
			controller.dismiss(animated: true)
		}
	}
}

struct RuleEditView: View {
	let rule: RecipientsRule
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		Text("recipients.rules.edit.screen")
			.navigationTitle(Text("recipients.rules.edit.title"))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("done") {
						dismiss()
					}
				}
			}
	}
} 


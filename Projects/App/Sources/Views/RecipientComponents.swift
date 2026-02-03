//
//  RecipientComponents.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import MessageUI
import Foundation
import Combine

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

// MARK: - 발송 성공 팝업 (5회 성공 시 리뷰 유도)
struct SuccessPopupView: View {
	let recipientCount: Int
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		VStack(spacing: 32) {
			Spacer()

			Text("🎉")
				.font(.system(size: 64))

			Text("success.popup.title".localized())
				.font(.title)
				.fontWeight(.bold)

			Text(String(format: "success.popup.message".localized(), recipientCount))
				.font(.title2)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)

			Button("success.popup.dismiss".localized()) {
				dismiss()
			}
			.font(.headline)
			.foregroundColor(.white)
			.padding(.horizontal, 32)
			.padding(.vertical, 14)
			.background(Color.accent)
			.clipShape(Capsule())

			Spacer()
		}
		.padding()
		.presentationDetents([.medium])
		.presentationDragIndicator(.visible)
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


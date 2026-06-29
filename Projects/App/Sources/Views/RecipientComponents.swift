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
	let onAddTapped: () -> Void

	var body: some View {
		VStack(spacing: 22) {
			ZStack {
				Circle()
					.fill(Color.softAccent.opacity(0.12))
					.frame(width: 92, height: 92)

				Image(systemName: "person.crop.circle.badge.plus")
					.font(.system(size: 42, weight: .semibold))
					.foregroundStyle(Color.softAccent)
			}

			Text("rules.empty".localized())
				.font(.title2.weight(.bold))
				.foregroundStyle(Color.softPrimaryText)

			Text("rules.empty.description".localized())
				.font(.body)
				.foregroundStyle(Color.softSecondaryText)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 12)

			Button(action: onAddTapped) {
				Text("rules.empty.cta".localized())
			}
			.buttonStyle(SoftFriendlyPrimaryButtonStyle())
		}
		.padding(28)
		.frame(maxWidth: 340)
		.softFriendlyCard()
		.padding(.horizontal, 24)
	}
}



struct SendButton: View {
	var title: String = "send.action".localized()
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Image(systemName: "paperplane.fill")
					.font(.headline.weight(.bold))
				Text(title)
			}
		}
		.buttonStyle(SoftFriendlyPrimaryButtonStyle())
		.accessibilityLabel(title)
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

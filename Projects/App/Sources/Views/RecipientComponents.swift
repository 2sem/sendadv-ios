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
		VStack(spacing: 0) {
			ZStack {
				RoundedRectangle(cornerRadius: 40, style: .continuous)
					.fill(Color.softSurface)
					.frame(width: 128, height: 128)
					.shadow(color: Color.softAccent.opacity(0.14), radius: 40, x: 0, y: 14)

				Image(systemName: "person.2")
					.font(.system(size: 58, weight: .medium))
					.foregroundStyle(Color.softAccent)

				Circle()
					.fill(Color.dynamic(light: "#E8895B", dark: "#E8A07B"))
					.frame(width: 38, height: 38)
					.shadow(color: Color.dynamic(light: "#E8895B", dark: "#000000").opacity(0.4), radius: 16, x: 0, y: 6)
					.overlay {
						Image(systemName: "plus")
							.font(.system(size: 19, weight: .bold))
							.foregroundStyle(Color.dynamic(light: "#FFFFFF", dark: "#1A1320"))
					}
					.offset(x: 58, y: -58)
			}

			Text("rules.empty".localized())
				.font(.system(size: 22, weight: .bold, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.padding(.top, 30)

			Text("rules.empty.description".localized())
				.font(.system(size: 15, weight: .regular, design: .rounded))
				.foregroundStyle(Color.softSecondaryText)
				.multilineTextAlignment(.center)
				.lineSpacing(4)
				.padding(.top, 10)

			Button(action: onAddTapped) {
				HStack(spacing: 9) {
					Image(systemName: "plus")
						.font(.system(size: 16.5, weight: .bold))
					Text("rules.empty.cta".localized())
				}
			}
			.buttonStyle(SoftFriendlyPrimaryButtonStyle())
			.frame(maxWidth: 286)
			.padding(.top, 30)
		}
		.padding(.horizontal, 36)
		.frame(maxWidth: .infinity)
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

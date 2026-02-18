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
import TipKit

// MARK: - Supporting Views
struct EmptyStateView: View {
	private let addFirstFilterTip = AddFirstFilterTip()
	@AppStorage("LaunchCount") private var launchCount: Int = 0

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

			TipView(addFirstFilterTip, arrowEdge: .top) { _ in
					addFirstFilterTip.logActionTaken()
				}
				.padding(.horizontal, 20)
				.task {
					for await shouldDisplay in addFirstFilterTip.shouldDisplayUpdates {
						if shouldDisplay {
							addFirstFilterTip.logShown(isFirstLaunch: launchCount <= 1)
						}
					}
				}
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


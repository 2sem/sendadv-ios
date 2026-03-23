//
//  WatchAdButton.swift
//  sendadv
//
//  Created by 영준 이 on 3/23/26.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct WatchAdButton: View {
	@EnvironmentObject private var adManager: SwiftUIAdManager
	@Binding var isAdFree: Bool
	var onAdFreeActivated: (() -> Void)?

	@State private var showConfirmation = false

	var body: some View {
		if !isAdFree {
			Button(action: {
				showConfirmation = true
			}) {
				ZStack {
					Circle()
						.fill(Color(.tertiarySystemBackground))
						.shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
					Image(systemName: "gift.fill")
						.font(.system(size: 18, weight: .medium))
						.foregroundStyle(Color.accent)
				}
				.frame(width: 44, height: 44)
			}
			.buttonStyle(.plain)
			.accessibilityLabel("watch.ad.accessibility.label".localized())
			.accessibilityHint("watch.ad.accessibility.hint".localized())
			.transition(.opacity.combined(with: .scale(scale: 0.85)))
			.confirmationDialog(
				"watch.ad.title".localized(),
				isPresented: $showConfirmation,
				titleVisibility: .visible
			) {
				Button("watch.ad.action".localized()) {
					Task { @MainActor in
						adManager.showRewarded { rewarded in
							if rewarded {
								LSDefaults.activateAdFree()
								withAnimation(.easeInOut(duration: 0.25)) {
									isAdFree = true
								}
								onAdFreeActivated?()
							}
						}
					}
				}
				Button(role: .cancel) {
				} label: { Text("Cancel".localized()) }
			} message: {
				Text("watch.ad.message".localized())
			}
		}
	}
}
